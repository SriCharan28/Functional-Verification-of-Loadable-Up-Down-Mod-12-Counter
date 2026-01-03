#Makefile for MOD-12 COUNTER

# SIMULATOR = Questa for Mentor's Questasim

SIMULATOR = Questa

FSDB_PATH=/home/cad/eda/SYNOPSYS/VERDI_2022/verdi/T-2022.06-SP1/share/PLI/VCS/LINUX64


RTL= ../rtl/*
work= work #library name
SVTB1= ../tb/counter_top.sv
INC = +incdir+../tb +incdir+../test +incdir+../write_agent +incdir+../read_agent
SVTB2 = ../test/counter_pkg.sv ../test/counter_assertions.sv
VSIMOPT= -vopt -voptargs=+acc 
VSIMCOV= -coverage -sva 
VSIMBATCH1= -c -do  " log -r /* ;coverage save -onexit mem_cov1;run -all; exit"


help:
	@echo =============================================================================================================
	@echo "! USAGE   	--  make target                  								!"
	@echo "! clean   	=>  clean the earlier log and intermediate files.  						!"
	@echo "! sv_cmp    	=>  Create library and compile the code.           						!"
	@echo "! run_test	=>  clean, compile & run the simulation for counter_test in batch mode.		!" 
	@echo "! view_wave1 =>  To view the waveform of counter_test	    						!"  
	@echo "! regress    =>  clean, compile and run all testcases in batch mode.		    				!"
	@echo "! report     =>  To merge coverage reports for all testcases and  convert to html format.			!"
	@echo "! cov        =>  To open merged coverage report in html format.							!"
	@echo ====================================================================================================================

clean : clean_$(SIMULATOR)
sv_cmp : sv_cmp_$(SIMULATOR)
run_test : run_test_$(SIMULATOR)
view_wave1 : view_wave1_$(SIMULATOR)
regress : regress_$(SIMULATOR)
report : report_$(SIMULATOR)
cov : cov_$(SIMULATOR)

# ----------------------------- Start of Definitions for Mentor's Questa Specific Targets -------------------------------#

sv_cmp_Questa:
	vlib $(work)
	vmap work $(work)
	vlog -work $(work) $(RTL) $(INC) $(SVTB2) $(SVTB1) 	
	
run_test_Questa: sv_cmp
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH1)  -wlf wave_file1.wlf -l test1.log  -sv_seed random  work.counter_top +UVM_TESTNAME=counter_test
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov1
	
	
view_wave1_Questa:
	vsim -view wave_file1.wlf
	

report_Questa:
	vcover merge mem_cov mem_cov1 
	vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov

regress_Questa: clean_Questa run_test_Questa report_Questa cov_Questa

cov_Questa:
	firefox covhtmlreport/index.html&
	
clean_Questa:
	rm -rf transcript* *log* fcover* covhtml* mem_cov* *.wlf modelsim.ini work
	clear

# ----------------------------- End of Definitions for Mentor's Questa Specific Targets -------------------------------#
