This repository contains the implementation of the design of loadable mod-12 counter in Verilog and layered testbench in SystemVerilog and UVM to verify the design by integrating functional coverage and assertions using Siemens Questasim.

The SV folder contains 2 files :-
1) "counter.sv" - this file contains the design code of loadable mod-12 counter, assertions module code and layered testbench code which integrates functional coverage and assertions.
2) "Makefile" - this file is used to compile the program, run the program, perform regression testing, generate code, functional and combined coverage reports view these reports in firefox.

The UVM folder contains 6 folders :-
1) "rtl" - this folder contains verilog code of mod-12 counter and interface of counter written in SystemVerilog.
2) "write_agent" - this folder contains SystemVerilog code of transaction, sequence, sequencer, driver, write monitor and write agent.
3) "read_Agent" - this folder contains SystemVerilog code of read monitor and read agent.
4) "tb" - this folder contains SystemVerilog code of scoreboard, environment, configuration class and top module.
5) "test" - this folder contains SystemVerilog code of counter package and test class.
6) "sim" - this folder contains the Makefile, this file is used to compile the program, run the program, perform regression testing, generate code, functional and combined coverage reports view these reports in firefox.
