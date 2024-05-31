
`uvm_analysis_imp_decl(_master)
`uvm_analysis_imp_decl(_slave)


class axi_scoreboard extends uvm_scoreboard;
  
  `uvm_component_utils(axi_scoreboard)
   axi_transaction m_item[$],s_item[$];
   bit [7:0]mem[bit[3:0]][bit[31:0]][$];
   bit [31:0]temp_addr;
   bit [31:0]temp_data;
   bit [3:0]temp_strobe;

   uvm_analysis_imp_master #(axi_transaction,axi_scoreboard) m_scoreboard_port;
   uvm_analysis_imp_slave #(axi_transaction,axi_scoreboard) s_scoreboard_port;
  
  
  function new(string name = "axi_scoreboard",uvm_component parent);
    super.new(name,parent);
    `uvm_info(get_type_name(),"inside constructor",UVM_LOW)
	 m_scoreboard_port = new("m_scoreboard_port",this);
	 s_scoreboard_port = new("s_scoreboard_port",this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(),"build phase",UVM_LOW)
  endfunction
  
  function void write_master(axi_transaction item);
  m_item.push_back(item);
  `uvm_info(get_type_name(),$sformatf("transaction from sequence item s_item=%0p",m_item),UVM_LOW)
  endfunction

  function void write_slave(axi_transaction item);
  s_item.push_back(item);
  `uvm_info(get_type_name(),$sformatf("transaction from sequence item s_item=%0p",s_item),UVM_LOW)
  endfunction
 
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info(get_type_name(),"run phase",UVM_LOW)
       //get the packet
       //generate the expected value
       //compare the actual value
       //score the transaction accordingly 
	 
       fork
	   refmodel();
       compare(); 
       join
	 

  endtask

  task refmodel();

  forever begin
  
  axi_transaction expected_item,actual_item;
  uvm_phase run_phase;

  wait(s_item.size()>0);
  expected_item = s_item.pop_front();
       
	   temp_addr = expected_item.ADDR;
	  for(int i=0;i<=expected_item.LEN;i++)begin
	   temp_data = expected_item.DATA[i];
       temp_strobe = expected_item.STRB[i];

	   for(int j=0;j<`DATA_WIDTH/8;j++)begin	

	      if(temp_strobe[j]==1)begin
          mem[expected_item.ID][temp_addr].push_back(temp_data[j*8+:8]);
		 `uvm_info("SCOREBOARD","[expected task]Wrtitting data into the memory",UVM_LOW)
         `uvm_info("SCOREBOARD",$sformatf("ID=%0h,ADDR=%0h , DATA=%0h, STROBE=%0b",expected_item.ID,expected_item.ADDR,temp_data,temp_strobe),UVM_LOW)
          temp_addr++;
		  end

	   end
	   `uvm_info("Write associative queue",$sformatf("mem=%0p",mem),UVM_NONE)

	  end

       run_phase = uvm_run_phase::get();
	   run_phase.raise_objection(this);
   end

  endtask
    
  task compare();

  forever begin
	 axi_transaction expected_item,actual_item;
	 uvm_phase run_phase;
     wait(m_item.size()>0);
	 //expected_item = s_item.pop_front();
     actual_item = m_item.pop_front();

	   temp_addr = actual_item.ADDR;
         `uvm_info("1",$sformatf("ID=%0h,ADDR=%0h",actual_item.ID,actual_item.ADDR),UVM_LOW)
	  for(int i=0;i<=actual_item.LEN;i++)begin
      
	  temp_data = actual_item.DATA[i];
      `uvm_info("2",$sformatf("ID=%0h,ADDR=%0h , DATA=%0h",actual_item.ID,actual_item.ADDR,temp_data),UVM_LOW)

	    for(int j=0;j<2**actual_item.SIZE;j++)begin

           `uvm_info("SCOREBOARD",$sformatf("actual_ADDR=%0h",actual_item.ADDR),UVM_LOW)
           if(mem[actual_item.ID][temp_addr].pop_front() == temp_data[j*8+:8])begin 
             `uvm_info("SCOREBOARD","[compare] comparing the memory",UVM_LOW);
             `uvm_info(get_type_name(),$sformatf("item Matched act=%0h and exp=%0p",temp_data,mem[actual_item.ID][actual_item.ADDR]),UVM_LOW)
           end
           else begin
             `uvm_error(get_type_name(),$sformatf("item MisMatched act=%0h and exp=%0p",temp_data,mem[actual_item.ID][actual_item.ADDR]))
           end   
		   temp_addr++;

		end

	   `uvm_info("Read associative queue",$sformatf("mem=%0p",mem),UVM_NONE)
 	  end
    
    // if(s_item.size()!=0)begin
      wait(s_item.size()==0 && m_item.size()==0);
	  run_phase = uvm_run_phase::get();
	  run_phase.drop_objection(this);
	// end


  end

  endtask

  function void phase_ready_to_end(uvm_phase phase);
    
	if(s_item.size()!=0 && m_item.size()!=0)begin
	 phase.raise_objection(this);

	 fork
	 `uvm_info("PROLONGED"," being prolonged", UVM_MEDIUM)
	   wait(s_item.size()==0 && m_item.size()==0);
	   phase.drop_objection(this);
     join_none

	end

  endfunction
  
  
endclass
