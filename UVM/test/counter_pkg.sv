package counter_pkg;
	
	import uvm_pkg::*;
	
	int no_of_trans=40;

	`include "uvm_macros.svh";
	`include "counter_trans.sv";
	`include "counter_sequence.sv";
	`include "counter_env_config.sv";
	`include "counter_rmon.sv";
	`include "counter_ragent.sv";
	`include "counter_sequencer.sv";
	`include "counter_driver.sv"	
	`include "counter_wmon.sv";
	`include "counter_wagent.sv";
	`include "counter_scoreboard.sv";
	`include "counter_env.sv";
	`include "counter_test.sv";

endpackage


