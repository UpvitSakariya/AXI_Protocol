class axi_outstanding_test extends axi_base_test;
  
  `uvm_component_utils(axi_outstanding_test)
   
   
   //axi_master_sequencer m_sequencer;
   axi_outstanding_fixed_seq outstanding_fixed_seq;
   axi_outstanding_incr_seq outstanding_incr_seq;
   axi_outstanding_wrap_seq outstanding_wrap_seq;
   axi_slave_sequence slave_seq;

  function new(string name = "axi_outstanding_test",uvm_component parent);
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

	 //axi_config::outstanding=3;
     //axi_config::outstanding_flag=1;

	 outstanding_fixed_seq = axi_outstanding_fixed_seq::type_id::create("outstanding_fixed_seq",this);
	 outstanding_incr_seq = axi_outstanding_incr_seq::type_id::create("outstanding_incr_seq",this);
	 outstanding_wrap_seq = axi_outstanding_wrap_seq::type_id::create("outstanding_wrap_seq",this);
	 slave_seq = axi_slave_sequence::type_id::create("slave_seq",this);

    phase.raise_objection(this);

	//env.master_agent.m_sqr.set_arbitration(UVM_SEQ_ARB_FIFO); 
	//show_arb_cfg();
	  
       fork 
	   // outstanding_fixed_seq.start(env.master_agent.m_sqr);
	    outstanding_incr_seq.start(env.master_agent.m_sqr);
	    //outstanding_wrap_seq.start(env.master_agent.m_sqr);


	    slave_seq.start(env.slave_agent.s_sqr);
	   join_any
		//phase.phase_done.set_drain_time(this,1000);
   
    phase.drop_objection(this); 
    
  endtask 
 
  
endclass
