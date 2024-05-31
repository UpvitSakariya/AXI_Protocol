class axi_master_agent extends uvm_agent;
  
  `uvm_component_utils(axi_master_agent)
  axi_master_monitor m_mon;
  axi_master_driver m_drv;
  axi_master_sequencer m_sqr;
  
  function new(string name = "axi_master_agent",uvm_component parent);
    super.new(name,parent);
    `uvm_info(get_type_name(),"inside constructor",UVM_LOW)
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(),"build phase",UVM_LOW)
    m_drv = axi_master_driver::type_id::create("m_drv",this);
    m_mon = axi_master_monitor::type_id::create("m_mon",this);
    m_sqr = axi_master_sequencer::type_id::create("m_sqr",this);
  endfunction
  
   function void connect_phase(uvm_phase phase);
     super.connect_phase(phase);
     `uvm_info(get_type_name(),"connect phase",UVM_LOW)
      m_drv.seq_item_port.connect(m_sqr.seq_item_export);
  endfunction
 
  
endclass
