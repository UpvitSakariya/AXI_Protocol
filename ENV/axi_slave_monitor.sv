class axi_slave_monitor extends uvm_monitor;
  
  `uvm_component_utils(axi_slave_monitor)
   virtual axi_interface vif;
   axi_transaction aw_tx,trans,tx,rx;
   axi_transaction aw_queue[$],assoc_queue[int][$];
   int S_Queue[$];
   int count=0;

   
   //port declaration
   uvm_analysis_port #(axi_transaction) s_collector_port;
   uvm_analysis_port #(axi_transaction) s_request_port;

   
  function new(string name = "axi_slave_monitor",uvm_component parent);
    super.new(name,parent);	
    `uvm_info(get_type_name(),"inside constructor",UVM_LOW)
     s_collector_port = new("s_collector_port",this);
	 s_request_port = new("s_request_port",this);
	endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(),"build phase",UVM_LOW)
	
    if(!(uvm_config_db#(virtual axi_interface)::get(this,"*","vif",vif)))begin
        `uvm_error(get_type_name(),"failed to get vif inside a driver")
    end 
    else begin
       `uvm_info(get_type_name(),"passed to get vif inside a driver",UVM_LOW)
    end 
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
 	  fork
	    aw_channel();
		w_channel();
		ar_channel();
	  join 
  endtask


  task aw_channel();
   forever @(vif.smon_cb) begin

   if(vif.smon_cb.AWLOCK==NORMAL)begin
		aw_tx = axi_transaction::type_id::create("aw_tx");
    	wait(vif.smon_cb.AWVALID && vif.smon_cb.AWREADY);
		//@(vif.smon_cb);
		$display($time,"aw_channel");
		aw_tx.ID = vif.smon_cb.AWID;
		aw_tx.ADDR = vif.smon_cb.AWADDR;
		aw_tx.LEN = burst_len'(vif.smon_cb.AWLEN);
		aw_tx.SIZE = burst_size'(vif.smon_cb.AWSIZE);
		aw_tx.BURST = burst_type'(vif.smon_cb.AWBURST);
		aw_tx.LOCK = lock_type'(vif.smon_cb.AWLOCK);
   		//`uvm_info(get_type_name(),$sformatf("ID=%0d, ADDR=%0d, LEN=%0d, SIZE=%0d, BURST=%0d, control=%0s",tx.ID,tx.ADDR,tx.LEN,tx.SIZE,tx.BURST,tx.control),UVM_LOW)
    
		`uvm_info("Slave Monitor","AW CHANEL",UVM_MEDIUM)
		`uvm_info("AW_QUEUE",$sformatf("before::aw_tx=%0p",aw_tx),UVM_MEDIUM)
		aw_queue.push_back(aw_tx);
		`uvm_info("AW_QUEUE",$sformatf("after::aw_queue packet=%0p,aw_queue size=%0d",aw_queue,aw_queue.size()),UVM_MEDIUM)
		aw_tx.print();
	end
	else if(vif.smon_cb.AWLOCK==EXCLUSIVE)begin
     	aw_tx = axi_transaction::type_id::create("aw_tx");
     	wait(vif.smon_cb.AWVALID && vif.smon_cb.AWREADY);
	 	//@(vif.smon_cb);
	 	$display($time,"aw_channel");
	 	aw_tx.ID = vif.smon_cb.AWID;
	 	aw_tx.ADDR = vif.smon_cb.AWADDR;
	 	aw_tx.LEN = burst_len'(vif.smon_cb.AWLEN);
	 	aw_tx.SIZE = burst_size'(vif.smon_cb.AWSIZE);
	 	aw_tx.BURST = burst_type'(vif.smon_cb.AWBURST);
	 	aw_tx.LOCK = lock_type'(vif.smon_cb.AWLOCK);
     	//`uvm_info(get_type_name(),$sformatf("ID=%0d, ADDR=%0d, LEN=%0d, SIZE=%0d, BURST=%0d, control=%0s",tx.ID,tx.ADDR,tx.LEN,tx.SIZE,tx.BURST,tx.control),UVM_LOW)
     
	 	`uvm_info("Slave Monitor","AW CHANEL",UVM_MEDIUM)
	 	`uvm_info("AW_QUEUE",$sformatf("before::aw_tx=%0p",aw_tx),UVM_MEDIUM)
	 	aw_queue.push_back(aw_tx);
	 	`uvm_info("AW_QUEUE",$sformatf("after::aw_queue packet=%0p,aw_queue size=%0d",aw_queue,aw_queue.size()),UVM_MEDIUM)
	 	aw_tx.print();

	end

	end

  endtask
 
  task w_channel();
   forever @(vif.smon_cb) begin

    if(vif.smon_cb.AWLOCK==NORMAL)begin
		trans = axi_transaction::type_id::create("trans");
		$display($time,"w_channel");
		//for(int i=0;i<=vif.AWLEN;i++)begin
    	wait(vif.smon_cb.WVALID && vif.smon_cb.WREADY && aw_queue.size()>0);
		`uvm_info("Slave Monitor",$sformatf("Before ID MATCHING :tx=%0h, WID=%0h",trans.ID,vif.smon_cb.WID),UVM_NONE)
    	S_Queue = aw_queue.find_index with (item.ID==vif.smon_cb.WID);
    	`uvm_info("EINDEX",$sformatf("S_Queue index::S_queue=%0p",S_Queue),UVM_NONE)
		trans = aw_queue[S_Queue[0]];
    	`uvm_info("Element",$sformatf("aw_queue:: element=%0p, S_queue=%0d, and trans=%0p",aw_queue[S_Queue[0]],S_Queue[0],trans),UVM_NONE)
    	`uvm_info("Slave Monitor",$sformatf("After ID MATCHING :tx=%0h, WID=%0h,Queue size=%0d",trans.ID,vif.smon_cb.WID,S_Queue.size()),UVM_NONE)
    	`uvm_info("Size",$sformatf("After S_Queue delete::aw_queue size=%0d, and Queue size=%0d",aw_queue.size(),S_Queue.size()),UVM_NONE)
    	//`uvm_info(get_type_name(),$sformatf("[w_channel]wdata=%0p",vif.smon_cb.WDATA),UVM_NONE)
		trans.CONTROL = WRITE;
		trans.ID = vif.smon_cb.WID;
		//tx.ADDR = vif.smon_cb.AWADDR;
		trans.STRB.push_back(vif.smon_cb.WSTRB);
		trans.DATA.push_back(vif.smon_cb.WDATA);
   		`uvm_info(get_type_name(),$sformatf("ID=%0d, DATA=%0p, STRB=%0p, LAST=%0d",trans.ID,trans.DATA,trans.STRB,trans.LAST),UVM_LOW)
    
	 		if(vif.smon_cb.WLAST==1)begin
     			`uvm_info("Slave Monitor[W_channel]","This is Pacacket sending to the storage",UVM_MEDIUM)
	  			trans.print();
      			s_collector_port.write(trans);
      			s_request_port.write(trans);
	        	aw_queue.delete(S_Queue[0]);
            	S_Queue.delete();
				trans = null;
	    	end

    end
	else if(vif.smon_cb.AWLOCK==EXCLUSIVE)begin
		trans = axi_transaction::type_id::create("trans");
		$display($time,"w_channel");
		//for(int i=0;i<=vif.AWLEN;i++)begin
    	wait(vif.smon_cb.WVALID && vif.smon_cb.WREADY && aw_queue.size()>0);
		`uvm_info("Slave Monitor",$sformatf("Before ID MATCHING :tx=%0h, WID=%0h",trans.ID,vif.smon_cb.WID),UVM_NONE)
    	S_Queue = aw_queue.find_index with (item.ID==vif.smon_cb.WID);
    	`uvm_info("EINDEX",$sformatf("S_Queue index::S_queue=%0p",S_Queue),UVM_NONE)
		trans = aw_queue[S_Queue[0]];
    	`uvm_info("Element",$sformatf("aw_queue:: element=%0p, S_queue=%0d, and trans=%0p",aw_queue[S_Queue[0]],S_Queue[0],trans),UVM_NONE)
    	`uvm_info("Slave Monitor",$sformatf("After ID MATCHING :tx=%0h, WID=%0h,Queue size=%0d",trans.ID,vif.smon_cb.WID,S_Queue.size()),UVM_NONE)
    	`uvm_info("Size",$sformatf("After S_Queue delete::aw_queue size=%0d, and Queue size=%0d",aw_queue.size(),S_Queue.size()),UVM_NONE)
    	//`uvm_info(get_type_name(),$sformatf("[w_channel]wdata=%0p",vif.smon_cb.WDATA),UVM_NONE)
		trans.CONTROL = WRITE;
		trans.ID = vif.smon_cb.WID;
		//tx.ADDR = vif.smon_cb.AWADDR;
		trans.STRB.push_back(vif.smon_cb.WSTRB);
		trans.DATA.push_back(vif.smon_cb.WDATA);
   		`uvm_info(get_type_name(),$sformatf("ID=%0d, DATA=%0p, STRB=%0p, LAST=%0d",trans.ID,trans.DATA,trans.STRB,trans.LAST),UVM_LOW)
    
	 		if(vif.smon_cb.WLAST==1)begin
     			`uvm_info("Slave Monitor[W_channel]","This is Pacacket sending to the storage",UVM_MEDIUM)
	  			trans.print();
      			s_collector_port.write(trans);
      			s_request_port.write(trans);
	        	aw_queue.delete(S_Queue[0]);
            	S_Queue.delete();
				trans = null;
	    	end

	end

	end

  endtask

 task ar_channel();
  forever @(vif.smon_cb) begin
 
    if(vif.smon_cb.ARLOCK==NORMAL)begin
		rx = axi_transaction::type_id::create("rx");
		//wait(rd_flag==1);
    	wait(vif.smon_cb.ARVALID && vif.smon_cb.ARREADY);
		//@(vif.smon_cb);
		$display($time,"ar_channel");
		rx.CONTROL = READ;
		rx.ID = vif.smon_cb.ARID;
		rx.ADDR = vif.smon_cb.ARADDR;
		rx.LEN = burst_len'(vif.smon_cb.ARLEN);
		rx.SIZE = burst_size'(vif.smon_cb.ARSIZE);
		rx.BURST = burst_type'(vif.smon_cb.ARBURST);
		rx.LOCK = lock_type'(vif.smon_cb.ARLOCK);
   		//`uvm_info(get_type_name(),$sformatf("ID=%0d, ADDR=%0d, LEN=%0d, SIZE=%0d, BURST=%0d, control=%0s",tx.ID,tx.ADDR,tx.LEN,tx.SIZE,tx.BURST,tx.control),UVM_LOW)
		`uvm_info("Slave Monitor","AR CHANEL",UVM_MEDIUM)
		//tx_queue.push_back(tx);
	    rx.print();
 	   	s_collector_port.write(rx);
	end
	else if(vif.smon_cb.ARLOCK==EXCLUSIVE)begin
    	rx = axi_transaction::type_id::create("rx");
		//wait(rd_flag==1);
    	wait(vif.smon_cb.ARVALID && vif.smon_cb.ARREADY);
		//@(vif.smon_cb);
		$display($time,"ar_channel");
		rx.CONTROL = READ;
		rx.ID = vif.smon_cb.ARID;
		rx.ADDR = vif.smon_cb.ARADDR;
		rx.LEN = burst_len'(vif.smon_cb.ARLEN);
		rx.SIZE = burst_size'(vif.smon_cb.ARSIZE);
		rx.BURST = burst_type'(vif.smon_cb.ARBURST);
		rx.LOCK = lock_type'(vif.smon_cb.ARLOCK);
   		//`uvm_info(get_type_name(),$sformatf("ID=%0d, ADDR=%0d, LEN=%0d, SIZE=%0d, BURST=%0d, control=%0s",tx.ID,tx.ADDR,tx.LEN,tx.SIZE,tx.BURST,tx.control),UVM_LOW)
		`uvm_info("Slave Monitor","AR CHANEL",UVM_MEDIUM)
		//tx_queue.push_back(tx);
    	rx.print();
    	s_collector_port.write(rx);
	end

	end

  endtask 

 
endclass

