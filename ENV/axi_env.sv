class axi_env extends uvm_env;
  
  `uvm_component_utils(axi_env)
 
  axi_virtual_sequencer v_sqr;
  axi_master_agent master_agent;
  axi_slave_agent slave_agent;
  axi_scoreboard scb;
  axi_coverage cov;
  
  function new(string name = "axi_env",uvm_component parent);
    super.new(name,parent);
    `uvm_info(get_type_name(),"inside constructor",UVM_LOW)
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(),"build phase",UVM_LOW)
	 //v_sqr = axi_virtual_sequencer::type_id::create("v_sqr");
     master_agent = axi_master_agent::type_id::create("master_agent",this);
     slave_agent = axi_slave_agent::type_id::create("slave_agent",this);
     scb = axi_scoreboard::type_id::create("scb",this);
	 cov = axi_coverage::type_id::create("cov",this);
  endfunction
  
   function void connect_phase(uvm_phase phase);
     super.connect_phase(phase);
     `uvm_info(get_type_name(),"connect phase",UVM_LOW)  
	  //v_sqr.m_sqr = master_agent.m_sqr;
	  //v_sqr.s_sqr = slave_agent.s_sqr;
      master_agent.m_mon.m_collector_port.connect(scb.m_scoreboard_port);
	  slave_agent.s_mon.s_request_port.connect(scb.s_scoreboard_port);
      slave_agent.s_mon.s_request_port.connect(cov.analysis_export);
  endfunction
 
 
endclass
