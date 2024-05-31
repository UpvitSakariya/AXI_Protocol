class axi_slave_driver extends uvm_driver#(axi_transaction);
  
  `uvm_component_utils(axi_slave_driver)
   virtual axi_interface vif;
   axi_transaction b_queue[$],b_trans,r_queue[$],r_trans;
    
  function new(string name = "axi_slave_driver",uvm_component parent);
    super.new(name,parent); 
    `uvm_info(get_type_name(),"inside constructor",UVM_LOW)
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
     `uvm_info(get_type_name(),"run phase",UVM_LOW)
    
     wait(vif.Aresetn);

	 //forever begin
      //@(vif.sdrv_cb);
      
	  vif.sdrv_cb.AWREADY <= 1;
	  vif.sdrv_cb.WREADY <= 1;
	  vif.sdrv_cb.ARREADY <= 1;

      
     //increment and aligned and implement driver logic accordingly
     fork
		 get_rsp();
         `uvm_info("OUR_feature",$sformatf("axi_config::feature=%s",axi_config::FEATURES),UVM_NONE)
		  case(axi_config::FEATURES)
  		  OUT_OF_ORDER:begin
	       `uvm_info("OUR_feature","entered into out_of_order feature",UVM_NONE)
   			wait(b_queue.size()>axi_config::out_of_order);
   			b_queue.shuffle();
   			b_channel();
            //r_channel();
  		    end
  		  OUTSTANDING:begin
	       `uvm_info("OUR_feature","entered into the outstanding feature",UVM_NONE)
   			wait(b_queue.size()>=axi_config::outstanding);
   			axi_config::Flag=1;
   			b_channel();
            //r_channel();
  			end
  		  NORMALY:begin
	       `uvm_info("OUR_feature","entered into the normal feature",UVM_NONE)
  			b_channel();
            //r_channel();
  			end

          endcase
         //b_channel();
         r_channel();

     join_none
	  wait((b_queue.size() + r_queue.size())==0);
     
   endtask
  
  task get_rsp();
  forever begin
     seq_item_port.get(req);
	`uvm_info(get_type_name(),"after getting pkt from slave sequence",UVM_LOW)
	 req.print();
     
	 case(req.CONTROL)

	 WRITE:begin
	 b_trans = new req;
     b_queue.push_back(b_trans);

	 end
	 READ:begin
	 r_trans = new req;

     r_queue.push_back(r_trans);
	 end 
	 default:begin
      $display("finish");
	 end

	 endcase
     `uvm_info("PUT_RSP", $sformatf("before put_response: put_rsp = %0d", req), UVM_LOW);
	`uvm_info("SPUT_RESPONSE","request put back and sending to the master sequence",UVM_MEDIUM)
	 seq_item_port.put(req);
     `uvm_info("PUT_RSP", $sformatf("After put_response: put_rsp = %0d", req), UVM_LOW);
	`uvm_info("Slave Driver","This is pacaket pushed back into the queue",UVM_MEDIUM)
     req.print();
  end
  endtask

  
  task b_channel();
      // write response channel signals (B)
	forever begin

	     //wait(vif.mdrv_cb.WLAST==1);
    	 wait(b_queue.size()>0);
		
	      //`uvm_info("FLAG_B",$sformatf("before packet driven::axi_config::FLAG=%0d",axi_config::Flag),UVM_NONE)
     	 foreach(b_queue[i])begin
 	    	@(vif.sdrv_cb);
			`uvm_info("MBID",$sformatf("queue stored::BID=%0d, axi_config::outstanding=%0d",b_queue[i].ID,axi_config::outstanding),UVM_NONE)
	    	//`uvm_info("Slave Driver","This is pacaket pushed back into the queue",UVM_MEDIUM)
        	b_queue[i].print();
     		vif.sdrv_cb.BID <= b_queue[i].ID;
     		vif.sdrv_cb.BRESP <= b_queue[i].RESP; 
     		vif.sdrv_cb.BVALID <= 1'b1;
     		wait(vif.BREADY);
			`uvm_info(get_type_name(),$sformatf("vif driven::BID=%0d",vif.sdrv_cb.BID),UVM_NONE)
 	    	@(vif.sdrv_cb);
	    	vif.sdrv_cb.BVALID <= 0;

	 	 end
		  //axi_config::Flag=0;
	      //`uvm_info("FLAG_A",$sformatf("after packet driven::axi_config::FLAG=%0d",axi_config::Flag),UVM_NONE)
	       `uvm_info("Slave Driver","--- from B_channel Delete complete queue ---",UVM_NONE);
           b_queue.delete();
           `uvm_info("Slave Driver",$sformatf("Size after queue deletion:b_queue size = %0d", b_queue.size()),UVM_NONE);
		   //break;


    end
  endtask
  
   
  task r_channel();
    // read data&response channel signals (R)
	forever begin

	wait(r_queue.size()>0);
	//wait(vif.sdrv_cb.BID);
	foreach(r_queue[i])begin
		for(int j=0;j<=r_queue[i].LEN;j++)begin
   		    @(vif.sdrv_cb);
    		vif.sdrv_cb.RID <= r_queue[i].ID;
    		vif.sdrv_cb.RRESP <= r_queue[i].RESP;
   		    vif.sdrv_cb.RDATA <= r_queue[i].DATA[j];  
    		`uvm_info("SDRIVER",$sformatf("[SDRIVER after]from master driver into w_channel::j=%0d,arlen=%0d,wdata=%0h, queue_data=%0p",j,r_queue[i].LEN,vif.sdrv_cb.RDATA,r_queue[i].DATA),UVM_NONE)
    		vif.sdrv_cb.RVALID <= 1;
   			wait(vif.RREADY);
    		if(j==r_queue[i].LEN)vif.sdrv_cb.RLAST <= 1;
	        @(vif.sdrv_cb);
	        vif.sdrv_cb.RVALID <= 0;
	        vif.sdrv_cb.RLAST <= 0;
		end
	end
	  `uvm_info("Slave Driver","--- from R_channel Delete complete queue ---",UVM_NONE);
      r_queue.delete();
      `uvm_info("Slave Driver",$sformatf("Size after queue deletion:r_queue size = %0d", r_queue.size()),UVM_NONE);


	end
  endtask  
      
  
endclass


