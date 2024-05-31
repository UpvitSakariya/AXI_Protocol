class axi_virtual_sequence extends uvm_sequence#(axi_transaction);


  `uvm_object_utils(axi_virtual_sequence)
  `uvm_declare_p_sequencer(axi_virtual_sequencer)

  axi_incr_write_seq incr_write_seq;
  axi_incr_read_seq incr_read_seq;



  function new(string name = "axi_virtual_sequence");
    super.new(name);
    `uvm_info(get_type_name(),"inside constructor",UVM_LOW)
  endfunction

  task body();

  `uvm_do_on(incr_write_seq,p_sequencer.m_sqr)
  `uvm_do_on(incr_read_seq,p_sequencer.m_sqr)


  endtask

endclass
