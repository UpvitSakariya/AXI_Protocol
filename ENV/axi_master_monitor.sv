class axi_master_monitor extends uvm_monitor;
  
  `uvm_component_utils(axi_master_monitor)
   virtual axi_interface vif;
   axi_transaction ar_tx,rx,ar_queue[$];
   int M_Queue[$];


   //port declaration
   uvm_analysis_port #(axi_transaction) m_collector_port;
  
  function new(string name = "axi_master_monitor",uvm_component parent);
    super.new(name,parent);
    `uvm_info(get_type_name(),"inside constructor",UVM_LOW)
     m_collector_port = new("m_collector_port",this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(),"build phase",UVM_LOW)
    if(!(uvm_config_db#(virtual axi_interface)::get(this,"*","vif",vif)))begin
        `uvm_error(get_type_name(),"failed to get vif inside a driver")
    end
      else begin
        `uvm_info(get_type_name(),"passed to get vif inside a monitor",UVM_LOW)
      end
  endfunction
  
  function void connect_phase(uvm_phase phase);
     super.connect_phase(phase);
     `uvm_info(get_type_name(),"connect phase",UVM_LOW)
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase); 
    `uvm_info(get_type_name(),"run phase",UVM_LOW)

	//forever begin
     //@(vif.mmon_cb);
     fork
	 //b_channel();
	 ar_channel();
	 r_channel();
     join
	//end
    
  endtask

  task b_channel();
   wait(vif.BVALID && vif.BREADY);
   rx.ID = vif.mmon_cb.BID;
   rx.RESP = resp_type'(vif.mmon_cb.BRESP);
  endtask

  task ar_channel();
  forever @(vif.mmon_cb)begin

	ar_tx = axi_transaction::type_id::create("ar_tx");
    wait(vif.mmon_cb.ARVALID && vif.mmon_cb.ARREADY);
	//@(vif.mmon_cb);
	$display($time,"ar_channel");
	ar_tx.ID = vif.mmon_cb.ARID;
	ar_tx.ADDR = vif.mmon_cb.ARADDR;
	ar_tx.LEN = burst_len'(vif.mmon_cb.ARLEN);
	ar_tx.SIZE = burst_size'(vif.mmon_cb.ARSIZE);
	ar_tx.BURST = burst_type'(vif.mmon_cb.ARBURST);
   //`uvm_info(get_type_name(),$sformatf("ID=%0d, ADDR=%0d, LEN=%0d, SIZE=%0d, BURST=%0d, control=%0s",tx.ID,tx.ADDR,tx.LEN,tx.SIZE,tx.BURST,tx.control),UVM_LOW)
	`uvm_info("Master Monitor","AR CHANEL",UVM_MEDIUM)
	ar_queue.push_back(ar_tx);
    ar_tx.print();
	end

  endtask
 
 
 task r_channel();
 forever @(vif.mmon_cb)begin
  rx = axi_transaction::type_id::create("rx");
 
  wait(vif.mmon_cb.RVALID && vif.mmon_cb.RREADY && ar_queue.size()>0);
  
	`uvm_info("Master Monitor",$sformatf("Before ID MATCHING :rx=%0h, RID=%0h",rx.ID,vif.mmon_cb.RID),UVM_NONE)
     M_Queue = ar_queue.find_index with (item.ID==vif.mmon_cb.RID);
	 rx = ar_queue[M_Queue[0]];
     `uvm_info("Master Monitor",$sformatf("After ID MATCHING :rx=%0h, RID=%0h,M_Queue size=%0d",rx.ID,vif.mmon_cb.RID,M_Queue.size()),UVM_NONE)
     rx.ID = vif.mmon_cb.RID;
     rx.RESP = resp_type'(vif.mmon_cb.RRESP);
     `uvm_info(get_type_name(),$sformatf("before pushing into the transaction::rdata=%0p",rx.DATA),UVM_NONE);
     rx.DATA.push_back(vif.mmon_cb.RDATA);  
     `uvm_info(get_type_name(),$sformatf("after pushing into the transaction::rdata=%0p",rx.DATA),UVM_NONE);
  
     if(vif.mmon_cb.RLAST==1)begin
      `uvm_info("Master Monitor[R_channel]","This is Pacacket sending to the scoreboard",UVM_MEDIUM)
       rx.print();
       m_collector_port.write(rx);
	   ar_queue.delete(M_Queue[0]);
       M_Queue.delete();
     end

  end
 endtask
  
endclass
