class counter_ragent extends uvm_agent;

	`uvm_component_utils(counter_ragent);

	counter_rmon rmonh;
	counter_env_config cfg;

	function new(string name = "counter_ragent",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	
		if(!uvm_config_db#(counter_env_config)::get(this,"","counter_env_config",cfg))
			`uvm_fatal("CONFIGURATION CLASS","FAILED TO GET CONTENTS IN READ AGENT");

		if(cfg.read_agent_is_active==UVM_PASSIVE)
			rmonh=counter_rmon::type_id::create("counter_rmon",this);
	endfunction

endclass