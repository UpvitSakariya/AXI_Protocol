class axi_wrap_test extends axi_base_test;
  
  `uvm_component_utils(axi_wrap_test)
   
   axi_wrap_seq wrap_seq;
   axi_slave_sequence slave_seq;

  function new(string name = "axi_wrap_test",uvm_component parent);
    super.new(name,parent);
    `uvm_info(get_type_name(),"inside constructor",UVM_LOW)
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(),"build phase",UVM_LOW)

  endfunction
 
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
      //uvm_top.print_topology();
  endfunction 
    
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info(get_type_name(),"run phase",UVM_LOW)
  
	 wrap_seq = axi_wrap_seq::type_id::create("wrap_seq",this);
	 slave_seq = axi_slave_sequence::type_id::create("slave_seq",this);

    phase.raise_objection(this);
	  
       fork 
	    wrap_seq.start(env.master_agent.m_sqr);

	    slave_seq.start(env.slave_agent.s_sqr);

	    join_any
	//	phase.phase_done.set_drain_time(this,1000);
   
    phase.drop_objection(this); 
    
  endtask 
 
  
endclass
