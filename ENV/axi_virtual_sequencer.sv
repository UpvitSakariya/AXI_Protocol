class axi_virtual_sequencer extends uvm_sequencer;

  `uvm_object_utils(axi_virtual_sequencer)

  axi_master_sequencer m_sqr;
  axi_slave_sequencer  s_sqr;
  
  function new(string name = "axi_virtual_sequencer");
    super.new(name);
    `uvm_info(get_type_name(),"inside constructor",UVM_LOW)
  endfunction

endclass
