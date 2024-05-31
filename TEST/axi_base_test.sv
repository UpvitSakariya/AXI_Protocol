class axi_base_test extends uvm_test;
  
  `uvm_component_utils(axi_base_test)
   
   axi_env env;

  function new(string name = "axi_base_test",uvm_component parent);
    super.new(name,parent);
    `uvm_info(get_type_name(),"inside constructor",UVM_LOW)
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(),"build phase",UVM_LOW)
     env = axi_env::type_id::create("env",this);

  endfunction
 
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
      uvm_top.print_topology();
  endfunction 
    
 /* virtual function void show_arb_cfg();

  UVM_SEQ_ARB_TYPE cur_arb;

  cur_arb = env.master_agent.m_sqr.get_arbitration();
  `uvm_info("Base_test",$sformatf("master sequencer set to %s",cur_arb.name()),UVM_NONE)

  endfunction */
 
  
endclass
