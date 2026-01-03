This repository contains the implementation of the design of loadable mod-12 counter in Verilog and layered testbench in SystemVerilog and UVM to verify the design by integrating functional coverage and assertions using Siemens Questasim.

The SV folder contains 2 files :-
1) "counter.sv" - this file contains the following design, interface, package, layered testbench and assertion programs that integrates functional coverage and assertions.
    1) design module of loadable mod-12 counter.
    2) interface of loadable mod-12 counter.
    3) transaction class of loadable mod-12 counter.
    4) sequence class of loadable mod-12 counter.
    5) generator class of loadable mod-12 counter.
    6) driver class of loadable mod-12 counter.
    7) write monitor class of loadable mod-12 counter.
    8) read monitor class of loadable mod-12 counter.
    9) environment class of loadable mod-12 counter.
    10) scoreboard class of loadable mod-12 counter.
    11) test class of loadable mod-12 counter.
    12) package of loadable mod-12 counter.
    13) assertion module of loadable mod-12 counter.
    14) top tb module of loadable mod-12 counter.
2) "Makefile" - this file is used to compile the program, run the program, perform regression testing, generate code, functional and combined coverage reports view these reports in firefox.

The UVM folder contains 6 folders :-
1) "rtl" - this folder contains verilog code of mod-12 counter and interface of counter written in SystemVerilog.
2) "write_agent" - this folder contains SystemVerilog code of transaction, sequence, sequencer, driver, write monitor and write agent.
3) "read_Agent" - this folder contains SystemVerilog code of read monitor and read agent.
4) "tb" - this folder contains SystemVerilog code of scoreboard, environment, configuration class and top module.
5) "test" - this folder contains SystemVerilog code of counter package and test class.
6) "sim" - this folder contains the Makefile, this file is used to compile the program, run the program, perform regression testing, generate code, functional and combined coverage reports view these reports in firefox.
