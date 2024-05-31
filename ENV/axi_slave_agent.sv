class axi_slave_agent extends uvm_agent;

  axi_slave_driver s_drv;
  axi_slave_monitor s_mon;
  axi_slave_sequencer s_sqr;
  axi_storage storage;

  `uvm_component_utils(axi_slave_agent);

  function new(string name = "axi_slave_agent",uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    s_drv = axi_slave_driver::type_id::create("s_drv",this);
    s_sqr = axi_slave_sequencer::type_id::create("s_sqr",this);
    s_mon = axi_slave_monitor::type_id::create("s_mon",this);
	storage = axi_storage::type_id::create("storage",this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    s_drv.seq_item_port.connect(s_sqr.seq_item_export);
    s_mon.s_collector_port.connect(storage.analysis_export);
  endfunction

endclass

