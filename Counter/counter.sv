`timescale 1ns/1ps

int number_of_transactions=20;

module mod_12_counter
(
clk,rst,mode,load,data_in,
data_out
);

input wire clk;
input wire rst,mode,load;
input wire [3:0] data_in;
output reg [3:0] data_out;

always@(posedge clk)
begin
	if(rst==1'b1) //reset
	begin
		data_out <= 4'b0000;
	end
	else
	begin
		if(load==1'b1) //loading_data
		begin
			data_out <= data_in;
		end
		else
		begin
			if(mode==1'b1) //up_counter
			begin
				if(data_out==4'b1011) //mod-12
				begin
					data_out <= 4'b0000;
				end
				else
				begin
					data_out <= data_out + 4'b0001;
				end
			end			
			else //down_counter
			begin
				if(data_out==4'b0000) //mod-12
				begin
					data_out <= 4'b1011;
				end
				else
				begin
					data_out <= data_out - 4'b0001;
				end
			end
		end
	end
end

endmodule


interface counter_if(input bit clk);
logic rst;
logic mode;
logic load;
logic [3:0] data_in;
logic [3:0] data_out;

clocking wdrv_cb@(posedge clk);
		default input #1 output #1;
		output rst;
		output mode;
		output load;
		output data_in;
endclocking

clocking wmon_cb@(posedge clk);
		default input #1 output #1;
		input rst;
		input mode;
		input load;
		input data_in;
endclocking

clocking rmon_cb@(posedge clk);
		default input #1 output #1;
		input data_out;
endclocking

modport wdrv_mp(clocking wdrv_cb);
modport wmon_mp(clocking wmon_cb);
modport rmon_mp(clocking rmon_cb);

endinterface


class counter_trans;
rand bit rst;
rand bit mode;
rand bit load;
rand bit [3:0] data_in;
bit [3:0] data_out;

int trn_id;

constraint data_range {data_in inside {[0:11]};}
constraint reset_freq {rst dist {0:=4,1:=1};}
constraint mode_freq {mode dist {0:=2,1:=2};}
constraint load_freq {load dist {0:=3,1:=1};}

function void display(input string str);
	$display("====================================================================");
	$display("%s",str);
	$display("====================================================================");
	$display("TRANSACTION NUMBER = %0d",trn_id);
	$display("==================================");
	$display("RESET = %d",rst);
	$display("MODE = %d",mode);
	$display("LOAD = %d",load);
	$display("INPUT DATA = %d",data_in);
	$display("==================================");
	$display("OUTPUT DATA = %d",data_out);
	$display("====================================================================");
endfunction

function void post_randomize;
	display("RANDOMIZED DATA");
endfunction

endclass
	
class extended_counter_trans extends counter_trans;

constraint data_range {data_in inside {3,6,8};}

endclass

	
class counter_gen;

counter_trans trans_gen;
counter_trans trans_gen_copy;
mailbox #(counter_trans) gen2wdrv;

function new(mailbox #(counter_trans) gen2wdrv);
	this.gen2wdrv=gen2wdrv;
	trans_gen=new;
endfunction

virtual task start;
	fork
		begin
			for(int i=0;i<number_of_transactions;i=i+1)
			begin
				trans_gen.trn_id++;
				assert(trans_gen.randomize());
				trans_gen_copy = new;
				trans_gen_copy.rst      = trans_gen.rst;
				trans_gen_copy.mode     = trans_gen.mode;
				trans_gen_copy.load     = trans_gen.load;
				trans_gen_copy.data_in  = trans_gen.data_in;
				trans_gen_copy.data_out = trans_gen.data_out;
				trans_gen_copy.trn_id   = trans_gen.trn_id;
				gen2wdrv.put(trans_gen_copy);
			end
		end
	join_none
endtask

endclass


class counter_wdrv;

virtual counter_if.wdrv_mp wdrv_if;
counter_trans trans_wdrv;
mailbox #(counter_trans) gen2wdrv;

function new(virtual counter_if.wdrv_mp wdrv_if,mailbox #(counter_trans) gen2wdrv);
	this.wdrv_if=wdrv_if;
	this.gen2wdrv=gen2wdrv;
endfunction

virtual task start;
	fork
		forever
			begin
				gen2wdrv.get(trans_wdrv);
				trans_wdrv.display("WRITE DRIVER");
				drive;
			end
	join_none
endtask

virtual task drive;
	@(wdrv_if.wdrv_cb)
		wdrv_if.wdrv_cb.mode<=trans_wdrv.mode;
		wdrv_if.wdrv_cb.load<=trans_wdrv.load;
		wdrv_if.wdrv_cb.data_in<=trans_wdrv.data_in;
endtask

endclass


class counter_wmon;

virtual counter_if.wmon_mp wmon_if;
counter_trans trans_wmon;
counter_trans trans_wmon_copy;
mailbox #(counter_trans) wmon2rm;

int trn_id_wmon;

function new(virtual counter_if.wmon_mp wmon_if,mailbox #(counter_trans) wmon2rm);
	this.wmon_if=wmon_if;
	this.wmon2rm=wmon2rm;
	trans_wmon=new;
endfunction

virtual task start;
	fork
		for(int i=0;i<number_of_transactions;i=i+1)
			begin
				monitor;
				trans_wmon_copy = new;
				trans_wmon_copy.mode     = trans_wmon.mode;
				trans_wmon_copy.load     = trans_wmon.load;
				trans_wmon_copy.data_in  = trans_wmon.data_in;
				trans_wmon_copy.trn_id   = trans_wmon.trn_id;
				wmon2rm.put(trans_wmon_copy);
			end
	join_none
endtask

virtual task monitor;
	@(wmon_if.wmon_cb)
		trans_wmon.mode=wmon_if.wmon_cb.mode;
		trans_wmon.load=wmon_if.wmon_cb.load;
		trans_wmon.data_in=wmon_if.wmon_cb.data_in;
		trn_id_wmon++;
		trans_wmon.trn_id=trn_id_wmon;
		trans_wmon.display("WRITE MONITOR");
endtask

endclass


class counter_rmon;

virtual counter_if.rmon_mp rmon_if;
counter_trans trans_rmon;
counter_trans trans_rmon_copy;
mailbox #(counter_trans) rmon2sb;

int trn_id_rmon;

function new(virtual counter_if.rmon_mp rmon_if,mailbox #(counter_trans) rmon2sb);
	this.rmon_if=rmon_if;
	this.rmon2sb=rmon2sb;
	trans_rmon=new;
endfunction

virtual task start;
	fork
		for(int i=0;i<number_of_transactions;i=i+1)
			begin
				monitor;
				trans_rmon_copy = new;
				trans_rmon_copy.data_out = trans_rmon.data_out;
				trans_rmon_copy.trn_id = trans_rmon.trn_id;
				rmon2sb.put(trans_rmon_copy);
			end
	join_none
endtask

task monitor;
		@(rmon_if.rmon_cb)
			trans_rmon.data_out=rmon_if.rmon_cb.data_out;
			trn_id_rmon++;
			trans_rmon.trn_id=trn_id_rmon;
			trans_rmon.display("READ MONITOR");
endtask

endclass


class counter_rm;
	counter_trans trans_rm;
	mailbox #(counter_trans) wmon2rm;
	mailbox #(counter_trans) rm2sb;

	bit [3:0] ref_data = 4'd0;

	function new(mailbox #(counter_trans) wmon2rm,mailbox #(counter_trans) rm2sb);
		this.wmon2rm=wmon2rm;
		this.rm2sb=rm2sb;
	endfunction

	virtual task start;
		fork
			fork				
				begin
					forever
						begin
							wmon2rm.get(trans_rm);
							counter_copy(trans_rm);
							trans_rm.data_out = ref_data;
							rm2sb.put(trans_rm);
						end
				end
			join
		join_none
	endtask

	virtual task counter_copy(counter_trans trans_h);
			if(trans_h.load==1'd1)
			begin
				ref_data<=trans_h.data_in;
			end
			else
			begin
				if(trans_h.mode==1'd1)
				begin
					if(ref_data==4'd11)
					begin
						ref_data<=4'd0;
					end
					else
					begin
						ref_data<=ref_data+4'd1;
					end
				end				
				else
				begin
					if(ref_data==4'd0)
					begin
					ref_data<=4'd11;
					end
					else
					begin
					ref_data<=ref_data-4'd1;
					end
				end
			end
	endtask

endclass

class counter_sb;
	event done;
	counter_trans trans_rm2sb;
	counter_trans trans_rmon2sb;
	counter_trans cov;
	mailbox #(counter_trans) rm2sb;
	mailbox #(counter_trans) rmon2sb;
	
	static int data_verified;

	covergroup counter_cg;
		cp_mode : coverpoint cov.mode {bins b_mode [] = {0,1};}
		cp_load : coverpoint cov.load {bins b_load [] = {0,1};}
		cp_data_in : coverpoint cov.data_in {bins b_data_in [] = {[0:11]}; illegal_bins ib1 = {[12:15]}; }
		cp_data_out : coverpoint cov.data_out {bins b_data_out [] = {[0:11]}; illegal_bins ib2 = {[12:15]};} 
	endgroup

	function new(mailbox #(counter_trans) rm2sb,mailbox #(counter_trans) rmon2sb);
		this.rm2sb=rm2sb;
		this.rmon2sb=rmon2sb;	
		counter_cg=new;
	endfunction

	virtual task start;
		fork
			forever
				begin
					rm2sb.get(trans_rm2sb);
					rmon2sb.get(trans_rmon2sb);
					check(trans_rmon2sb);
				end
		join_none
	endtask
	
	virtual task check(counter_trans trans_h);
		if(trans_rm2sb.data_out==trans_rmon2sb.data_out)
		begin
			$display("====================================================================");
			trans_rm2sb.display("REFERENCE MODEL");
			$display("====================================================================");
			$display("COUNTER WORKING");
			$display("====================================================================");
		end
		else
		begin
			$display("====================================================================");
			trans_rm2sb.display("REFERENCE MODEL");
			$display("====================================================================");
			$display("COUNTER NOT WORKING");
			$display("====================================================================");
		end
		//functional_coverage
		cov = new;
		cov.mode = trans_rm2sb.mode;
		cov.load = trans_rm2sb.load;
		cov.data_in = trans_rm2sb.data_in;
		cov.data_out = trans_rm2sb.data_in;
		counter_cg.sample;


		data_verified++;
		if(data_verified>=number_of_transactions)
		begin
			->done;
		end
	endtask

	function void fc_report;
			$display("====================================================================");
			$display("FUNCTIONAL COVERAGE = %0.2f",counter_cg.get_coverage);
			$display("====================================================================");
	endfunction

endclass


class counter_env;
	virtual counter_if.wdrv_mp wdrv_if;
	virtual counter_if.wmon_mp wmon_if;
	virtual counter_if.rmon_mp rmon_if;

	mailbox #(counter_trans) gen2wdrv=new;
	mailbox #(counter_trans) wmon2rm=new;
	mailbox #(counter_trans) rm2sb=new;
	mailbox #(counter_trans) rmon2sb=new;

	counter_gen gen;
	counter_wdrv wdrv;
	counter_wmon wmon;
	counter_rmon rmon;	
	counter_rm rm;
	counter_sb sb;

	function new(virtual counter_if.wdrv_mp wdrv_if,virtual counter_if.wmon_mp wmon_if,virtual counter_if.rmon_mp rmon_if);
		this.wdrv_if=wdrv_if;
		this.wmon_if=wmon_if;
		this.rmon_if=rmon_if;
	endfunction

	virtual task build;
		gen=new(gen2wdrv);
		wdrv=new(wdrv_if,gen2wdrv);
		wmon=new(wmon_if,wmon2rm);
		rmon=new(rmon_if,rmon2sb);
		rm=new(wmon2rm,rm2sb);
		sb=new(rm2sb,rmon2sb);
	endtask

	virtual task start;
		gen.start();
		wdrv.start();
		wmon.start();		
		rmon.start();
		rm.start();
		sb.start();
	endtask	

	virtual task stop;
		wait(sb.done.triggered);
	endtask

	virtual task reset_dut;
		@(wdrv_if.wdrv_cb)
			wdrv_if.wdrv_cb.rst<=1'b1;
			repeat(2)
				@(wdrv_if.wdrv_cb)
			wdrv_if.wdrv_cb.rst<=1'b0;
	endtask

	virtual task run;
		reset_dut;
		start;
		stop;
		sb.fc_report;
	endtask	
endclass


class counter_test;
	virtual counter_if.wdrv_mp wdrv_if;
	virtual counter_if.wmon_mp wmon_if;
	virtual counter_if.rmon_mp rmon_if;
	counter_env env_h;
	
	function new(virtual counter_if.wdrv_mp wdrv_if,virtual counter_if.wmon_mp wmon_if,virtual counter_if.rmon_mp rmon_if);
		this.wdrv_if=wdrv_if;
		this.wmon_if=wmon_if;
		this.rmon_if=rmon_if;
		env_h=new(wdrv_if,wmon_if,rmon_if);
	endfunction

	virtual task build;
		env_h.build;
	endtask

	virtual task run;
		env_h.run;
	endtask
endclass

	class extended_counter_test extends counter_test;
	extended_counter_trans ecth;
	
	function new(virtual counter_if.wdrv_mp wdrv_if,virtual counter_if.wmon_mp wmon_if,virtual counter_if.rmon_mp rmon_if);
		super.new(wdrv_if,wmon_if,rmon_if);
	endfunction

	virtual task build;
		super.build;
	endtask

	virtual task run;
		ecth=new();
		env_h.gen.trans_gen=ecth;
		super.run;
	endtask
endclass
	

module counter_assertions
(
clk,rst,mode,load,data_in,
data_out
);

input logic clk,rst,mode,load;
input logic [3:0] data_in,data_out;

property reset;
	@(posedge clk)
		rst |-> data_out==0;
endproperty

property up_count;
	@(posedge clk)
		disable iff(rst)
			(mode && !load && data_out!=11)|=> data_out == $past(data_out,1) + 1;
endproperty

property down_count;
	@(posedge clk)		
		disable iff(rst)
			(!mode && !load && data_out!=0) |=> data_out == $past(data_out,1) - 1;
endproperty

property load_data;
	@(posedge clk)
		disable iff(rst)
			load |-> data_out == data_in;	
endproperty

property upper_bound;
	@(posedge clk)
		disable iff(rst)
			(data_out==11 && mode && !load)  |=> data_out == 0;
endproperty

property lower_bound;
	@(posedge clk)
		disable iff(rst)
			(data_out==0 && !mode && !load)  |=> data_out ==11;
endproperty

a_rst : assert property (reset)
		$display("Reset Assertion Pass at",$time);
	else
		$display("Reset Assertion Fail at",$time);

a_up : assert property (up_count)
		$display("Up Count Assertion Pass at",$time);
		//$strobe("Up Count Assertion Pass at",$time);
	else
		$display("Up Count Assertion Fail at",$time);
		//$strobe("Up Count Assertion Fail at",$time);

a_down : assert property (down_count)
		$display("Down Count Assertion Pass at",$time);
	else
		$display("Down Count Assertion Fail at",$time);

a_load : assert property (load_data)
		$display("Loading Data Assertion Pass at",$time);
	else
		$display("Loading Data Assertion Fail at",$time);

a_11_to_0 : assert property (upper_bound)
		$display("Upper Bound Wraparound Assertion Pass at",$time);
	else
		$display("Upper Bound Wraparound Assertion Fail at",$time);

a_0_to_11 : assert property (lower_bound)
		$display("Lower Bound Wraparound Assertion Pass at",$time);
	else
		$display("Lower Bound Wraparound Assertion Fail at",$time);
endmodule


module counter_top;
	reg clk;
	
	counter_if vif(clk);
	
	counter_test test_h;
	extended_counter_test etest_h;

	mod_12_counter dut(.clk(clk),.rst(vif.rst),.mode(vif.mode),.load(vif.load),.data_in(vif.data_in),.data_out(vif.data_out));
	bind mod_12_counter counter_assertions fv(.clk(clk),.rst(vif.rst),.mode(vif.mode),.load(vif.load),.data_in(vif.data_in),.data_out(vif.data_out));
	
	parameter period = 20;

	always
	begin
		clk=1'd0;
		#(period/2);
		clk=1'd1;
		#(period/2);
	end
	
	initial
	begin   
		if($test$plusargs("TEST1"))
           	begin
                	test_h=new(vif,vif,vif);
			test_h.build();
               		test_h.run();
			$display("====================================================================");
			$display("VERIFICATION COMPLETED");
			$display("====================================================================");
               		$stop;
               end

         	if($test$plusargs("TEST2"))
            	begin
               		etest_h=new(vif,vif,vif);
               		etest_h.build();
               		etest_h.run(); 
			$display("====================================================================");
			$display("VERIFICATION COMPLETED");
			$display("====================================================================");
               		$stop;
            	end
	end
endmodule



