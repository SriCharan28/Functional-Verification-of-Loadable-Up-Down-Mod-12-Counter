class counter_test extends uvm_test;

	`uvm_component_utils(counter_test);
	
	counter_env_config cfg;
	counter_env envh;
	counter_sequence seqh;

	function new(string name = "counter_test",uvm_component parent=null);
		super.new(name,parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		cfg=counter_env_config::type_id::create("counter_env_config");
		if(!uvm_config_db#(virtual counter_if)::get(this,"","vif",cfg.vif))
			`uvm_fatal("vif","FAILED TO GET CONTENTS IN TEST");

		cfg.has_scoreboard=1;
		cfg.has_write_agent=1;
		cfg.has_read_agent=1;
		cfg.write_agent_is_active=UVM_ACTIVE;
		cfg.read_agent_is_active=UVM_PASSIVE;
		uvm_config_db#(counter_env_config)::set(this,"*","counter_env_config",cfg);

		envh=counter_env::type_id::create("counter_env",this);
	endfunction

	function void start_of_simulation_phase(uvm_phase phase);
		uvm_top.print_topology();
	endfunction

	task run_phase(uvm_phase phase);
	phase.raise_objection(this);
		seqh=counter_sequence::type_id::create("counter_sequence");
		seqh.start(envh.wagth.seqrh);
	phase.drop_objection(this);
	endtask

endclass

class extended_counter_test extends counter_test;

	`uvm_component_utils(extended_counter_test);
	
	function new(string name = "extended_counter_test",uvm_component parent=null);
		super.new(name,parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

	function void start_of_simulation_phase(uvm_phase phase);
		uvm_top.print_topology();
	endfunction

	task run_phase(uvm_phase phase);
		extended_counter_sequence eseqh;
		eseqh=extended_counter_sequence::type_id::create("extended_counter_sequence");
		phase.raise_objection(this);
			eseqh.start(envh.wagth.seqrh);
		phase.drop_objection(this);
	endtask

endclass


