class counter_trans extends uvm_sequence_item;

`uvm_object_utils(counter_trans);

rand bit rst;
rand bit mode;
rand bit load;
rand bit [3:0] data_in;
bit [3:0] data_out;

static int trn_id;

/*
`uvm_object_utils_begin(counter_trans)
	`uvm_field_int(rst,UVM_ALL_ON)
	`uvm_field_int(mode,UVM_ALL_ON)
	`uvm_field_int(load,UVM_ALL_ON)
	`uvm_field_int(data_in,UVM_ALL_ON)
	`uvm_field_int(data_out,UVM_ALL_ON)
`uvm_object_utils_end
*/

constraint data_range {data_in inside {[0:11]};}
constraint reset_freq {rst dist {0:=4,1:=1};}
constraint mode_freq {mode dist {0:=2,1:=2};}
constraint load_freq {load dist {0:=3,1:=1};}

function new(string name = "counter_trans");
	super.new(name);
endfunction

///*
function void do_copy(uvm_object rhs);
	counter_trans th;
	if(!$cast(th,rhs))
	begin
		`uvm_fatal("DO COPY","CASTING NOT COMPATABILE");
	end
	else
	begin
		super.do_copy(rhs);
		this.rst=th.rst;
		this.load=th.load;
		this.mode=th.mode;
		this.data_in=th.data_in;
		//this.data_out=th.data_out;
	end
endfunction

function bit do_compare(uvm_object rhs,uvm_comparer comparer);
	counter_trans th;
	if(!$cast(th,rhs))
	begin
		`uvm_fatal("DO COMAPRE","CASTING NOT COMPATABILE");
		return 0;
	end
	return (super.do_compare(rhs,comparer) && this.data_out==th.data_out);
endfunction

function void do_print(uvm_printer printer);
	super.do_print(printer);
	printer.print_field("RESET",rst,1,UVM_UNSIGNED);
	printer.print_field("MODE",mode,1,UVM_UNSIGNED);	
	printer.print_field("LOAD",load,1,UVM_UNSIGNED);
	printer.print_field("DATA_IN",data_in,4,UVM_UNSIGNED);	printer.print_field("DATA_OUT",data_out,4,UVM_UNSIGNED);
endfunction
//*/

function void post_randomize();
	trn_id++;
	`uvm_info("RANDOMIZED DATA:-\n",$sformatf("Transaction-[%0d] :-\n%s",trn_id,this.sprint()),UVM_LOW);
endfunction

endclass

