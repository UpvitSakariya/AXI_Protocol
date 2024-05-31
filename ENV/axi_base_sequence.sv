class axi_base_sequence extends uvm_sequence#(axi_transaction);
  
  `uvm_object_utils(axi_base_sequence)
   //axi_transaction 
   bit [3:0]id_queue[$];
   bit [3:0]len_queue[$];
   bit [31:0]addr_queue[$];
   bit [1:0]lock_queue[$];

  
  function new(string name = "axi_base_sequence");
    super.new(name);
    `uvm_info(get_type_name(),"inside constructor",UVM_LOW)
  endfunction
 
endclass



