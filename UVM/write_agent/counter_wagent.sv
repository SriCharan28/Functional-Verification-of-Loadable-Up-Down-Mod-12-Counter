class counter_wagent extends uvm_agent;

	`uvm_component_utils(counter_wagent);

	counter_wmon wmonh;
	counter_driver drvh;
	counter_sequencer seqrh;
	counter_env_config cfg;

	function new(string name = "counter_wagent",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(counter_env_config)::get(this,"","counter_env_config",cfg))
			`uvm_fatal("CONFIGURATION CLASS","FAILED TO GET CONTENTS IN WRITE AGENT");	
		wmonh=counter_wmon::type_id::create("counter_wmon",this);
		if(cfg.write_agent_is_active==UVM_ACTIVE)
		begin
			drvh=counter_driver::type_id::create("counter_driver",this);
			seqrh=counter_sequencer::type_id::create("counter_sequencer",this);
		end
	endfunction

	function void connect_phase(uvm_phase phase);
		if(cfg.write_agent_is_active==UVM_ACTIVE)
			drvh.seq_item_port.connect(seqrh.seq_item_export);
	endfunction


endclass
