class counter_scoreboard extends uvm_scoreboard;
	
	`uvm_component_utils(counter_scoreboard);

	uvm_tlm_analysis_fifo#(counter_trans) fwep;
	uvm_tlm_analysis_fifo#(counter_trans) frep;

	counter_trans trans_wmon;
	counter_trans trans_rmon;
	counter_trans trans_ref;
	counter_trans trans_fc;

	covergroup counter_cg;
		cp_mode : coverpoint trans_fc.mode {bins b_mode [] = {0,1};}
		cp_load : coverpoint trans_fc.load {bins b_load [] = {0,1};}
		cp_data_in : coverpoint trans_fc.data_in {bins b_data_in [] = {[0:11]}; illegal_bins ib1 = {[12:15]}; }
		cp_data_out : coverpoint trans_fc.data_out {bins b_data_out [] = {[0:11]}; illegal_bins ib2 = {[12:15]};} 
	endgroup

	function new(string name = "counter_scoreboard",uvm_component parent);
		super.new(name,parent);
		fwep=new("fwep",this);
		frep=new("frep",this);
		trans_ref=counter_trans::type_id::create("trans_ref");
		trans_wmon=counter_trans::type_id::create("trans_wmon");
		trans_rmon=counter_trans::type_id::create("trans_rmon");
		trans_fc=counter_trans::type_id::create("trans_fc");
		counter_cg=new;
	endfunction

	task run_phase(uvm_phase phase);
		forever
		begin
			fwep.get(trans_wmon);
			`uvm_info("counter_scoreboard",$sformatf("DATA RECEIVED FROM WRITE MONITOR :- \n%s",trans_wmon.sprint()),UVM_LOW);			

			frep.get(trans_rmon);
			`uvm_info("counter_scoreboard",$sformatf("DATA RECEIVED FROM READ MONITOR :- \n%s",trans_rmon.sprint()),UVM_LOW);
			
			ref_counter();

			verify_result();
		end
	endtask

	task ref_counter();
		if(trans_wmon.rst==1'b1) //reset
		begin
			trans_ref.data_out <= 4'b0000;
		end
		else
		begin
			if(trans_wmon.load==1'b1) //loading_data
			begin
				trans_ref.data_out <= trans_wmon.data_in;
			end
			else
			begin
				if(trans_wmon.mode==1'b1) //up_counter
				begin
					if(trans_ref.data_out==4'b1011) //mod-12
					begin
						trans_ref.data_out <= 4'b0000;
					end
					else
					begin
						trans_ref.data_out <= trans_ref.data_out + 4'b0001;
					end
				end			
				else //down_counter
				begin
					if(trans_ref.data_out==4'b0000) //mod-12
					begin
						trans_ref.data_out <= 4'b1011;
					end
					else
					begin
						trans_ref.data_out <= trans_ref.data_out - 4'b0001;
					end
				end
			end
		end
	endtask

	task verify_result();
		if(!trans_ref.compare(trans_rmon))
		begin
			`uvm_info("counter_scoreboard",$sformatf("OUTPUT DATA RECEIVED FROM READ MONITOR=%0d", trans_rmon.data_out),UVM_LOW);
			`uvm_info("counter_scoreboard",$sformatf("OUTPUT DATA RECEIVED FROM REFERENCE MODEL = %0d",trans_ref.data_out),UVM_LOW);
		end
		else
		begin
			`uvm_info("counter_scoreboard","SUCESS",UVM_LOW);
		end
		trans_fc.copy(trans_wmon);
		trans_fc.data_out=trans_rmon.data_out;
		counter_cg.sample();
	endtask

	function void report_phase(uvm_phase phase);
		`uvm_info("uvm_scoreboard",$sformatf("functional coverage = %0.2f",counter_cg.get_coverage()),UVM_LOW);
	endfunction


endclass
