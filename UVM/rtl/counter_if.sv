interface counter_if(input bit clk);
logic rst;
logic mode;
logic load;
logic [3:0] data_in;
logic [3:0] data_out;

clocking drv_cb@(posedge clk);
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

modport drv_mp(clocking drv_cb);
modport wmon_mp(clocking wmon_cb);
modport rmon_mp(clocking rmon_cb);

endinterface

