class axi_incr_test extends axi_base_test;
  
  `uvm_component_utils(axi_incr_test)
   
   axi_incr_seq incr_seq;
   axi_incr_wr_seq incr_wr_seq;
   axi_slave_sequence slave_seq;

  function new(string name = "axi_incr_test",uvm_component parent);
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
  
	 incr_seq = axi_incr_seq::type_id::create("incr_seq",this);
	 incr_wr_seq = axi_incr_wr_seq::type_id::create("incr_wr_seq",this);
	 slave_seq = axi_slave_sequence::type_id::create("slave_seq",this);

    phase.raise_objection(this);
	  
        fork 
	     incr_seq.start(env.master_agent.m_sqr);
	     //incr_wr_seq.start(env.master_agent.m_sqr);

	     slave_seq.start(env.slave_agent.s_sqr);

	    join_any
   
    phase.drop_objection(this); 
    
  endtask 
 
  
endclass
