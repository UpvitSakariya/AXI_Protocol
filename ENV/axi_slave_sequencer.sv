class axi_slave_sequencer extends uvm_sequencer#(axi_transaction,axi_transaction);
  
  `uvm_component_utils(axi_slave_sequencer)

   
  function new(string name = "axi_slave_sequencer",uvm_component parent);
    super.new(name,parent);
    `uvm_info(get_type_name(),"inside constructor",UVM_LOW)
  endfunction
  
endclass
