class axi_master_driver extends uvm_driver#(axi_transaction);
  
  `uvm_component_utils(axi_master_driver)
   virtual axi_interface vif;
   axi_transaction aw_queue[$],aw_trans,w_queue[$],w_trans,ar_queue[$],interleave_queue[$],interleave_trans,ar_trans;
   axi_transaction req;
   bit [3:0]id_queue[$];
   bit [3:0]strb_queue[$]; 
   bit [31:0]last_queue[$];
   int count=0;

  function new(string name = "axi_master_driver",uvm_component parent);
    super.new(name,parent); 
    `uvm_info(get_type_name(),"inside constructor",UVM_MEDIUM)
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(),"build phase",UVM_MEDIUM)
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

      @(vif.mdrv_cb);

	  vif.mdrv_cb.BREADY <= 1;
	  vif.mdrv_cb.RREADY <= 1;

      fork
	 	  
      //phase.raise_objection(this);
		 get();
         aw_channel();
         w_channel();
         ar_channel();
  
      //phase.drop_objection(this);
      join
	  //wait((aw_queue.size() + w_queue.size() + ar_queue.size())==0);
	  //`uvm_info("MPUT_RESPONSE","request put back and sending to the master sequence",UVM_MEDIUM)
   	  //seq_item_port.put(req);
     
     //end
     
   endtask

   task get();
     forever begin
	 //req = axi_transaction::type_id::create("req");
	 
      seq_item_port.get(req);
	  `uvm_info("Master Driver","This is pacaket receiver inside driver",UVM_MEDIUM)
       req.print();

     case(req.CONTROL)

	   WRITE:begin
	     aw_trans = new req;
	     w_trans = new req;
	     aw_queue.push_back(aw_trans);
	     w_queue.push_back(w_trans);
		 end
	   READ:begin 
	     ar_trans = new req;
	     ar_queue.push_back(ar_trans);
		 end
	   default:begin
	     $display("finish");
		 end

	 endcase
       
	  `uvm_info("MPUT_RESPONSE","request put back and sending to the master sequence",UVM_MEDIUM)
	   seq_item_port.put(req);
	  `uvm_info("Master Driver","This is pacaket pushed back into the queue",UVM_MEDIUM)
       req.print();

	 end

   endtask
  
  task aw_channel();
     // write address channel signals (AW)
     //$strobe("AWVALID=%0d",vif.AWVALID);
	forever begin

	 	wait(aw_queue.size()>0);
     //if(aw_queue[0].CONTROL==WRITE)begin
     	foreach(aw_queue[i])begin
	  		$display($time,"master driver inside aw_channel");
        	@(vif.mdrv_cb);
     		vif.mdrv_cb.AWID <= aw_queue[i].ID;
     		vif.mdrv_cb.AWADDR <= aw_queue[i].ADDR;
     		vif.mdrv_cb.AWLEN <= aw_queue[i].LEN;
     		vif.mdrv_cb.AWSIZE <= aw_queue[i].SIZE;
     		vif.mdrv_cb.AWBURST <= aw_queue[i].BURST;
			vif.mdrv_cb.AWLOCK <= aw_queue[i].LOCK;
     		vif.mdrv_cb.AWVALID <= 1;
        	wait(vif.AWREADY);
        	@(vif.mdrv_cb);
        	vif.mdrv_cb.AWVALID <= 0;
	 		`uvm_info(get_type_name(),$sformatf("before aw_channel::AWVALID=%0d, ADDR=%0d,LEN=%0d,ID=%0d,SIZE=%0d, BURST=%0d, AWREADY=%0d",vif.AWVALID,req.ADDR,req.LEN,req.ID,req.SIZE,req.BURST,vif.AWREADY),UVM_LOW)
	 		`uvm_info("enum",$sformatf("before aw_channel::AWVALID=%0d, ADDR=%0d,LEN=%0d,ID=%0d,SIZE=%0d, BURST=%0d, AWREADY=%0d",vif.AWVALID,req.ADDR,aw_queue[i].LEN,aw_queue[i].ID,aw_queue[i].SIZE,aw_queue[i].BURST,vif.AWREADY),UVM_LOW)
	 	end

	  	`uvm_info("Master Driver","--- from AW_channel Delete complete queue ---",UVM_NONE);
       	aw_queue.delete();
      	`uvm_info("Master Driver",$sformatf("Size after queue deletion:aw_queue size = %0d", aw_queue.size()),UVM_NONE);
    //`uvm_info(get_type_name(),$sformatf("after aw_channel::AWVALID=%0d, ADDR=%0d,LEN=%0d,ID=%0d,SIZE=%0d, BURST=%0d, AWREADY=%0d",vif.AWVALID,req.ADDR,req.LEN,req.ID,req.SIZE,req.BURST,vif.AWREADY),UVM_LOW)
	 //end

	end
  endtask
  
  task w_channel();
    // write data channel signals (W)
	forever begin
    
	wait(w_queue.size()>0);
	//if(w_queue[0].CONTROL==WRITE)begin
      `uvm_info("UPVIT",$sformatf("before::Size of w_queue in wchannel before interleaving = %0d",w_queue.size()),UVM_NONE)
	  $display("***************************************");
     if(axi_config::interleave_flag==1)begin
       `uvm_info("MDRV","W_Channel if part with interleaving concept",UVM_NONE)
	   wait(w_queue.size()>=axi_config::interleaving_depth);
       `uvm_info("UPVIT",$sformatf("after::Size of w_queue in wchannel before interleaving = %0d",w_queue.size()),UVM_NONE)
	  for(int i=0;i<axi_config::interleaving_depth;i++)begin
	   //interleave_trans = w_queue.pop_front();
       interleave_queue.push_back(w_queue.pop_front());
	  end

	 // initial begin
      // last_queue.push_back(interleave_queue.pop_front());
	 // end

     //`uvm_info("interleave_queue size",$sformatf("Size of interleave_queue in wchannel = %0d",interleave_queue.size()),UVM_NONE)

	 for(int i=0;i<axi_config::interleaving_depth;i++)begin
            @(vif.mdrv_cb);
      	    vif.mdrv_cb.WID <= interleave_queue[i].ID;
			id_queue.push_back(interleave_queue[i].ID);
            //`uvm_info("TEMP_QUEUE",$sformatf("temp_queue size= %0d, temp_queue=%0p",temp_queue.size(),temp_queue),UVM_NONE)
     		vif.mdrv_cb.WSTRB <= interleave_queue[i].STRB[0];
			strb_queue.push_back(interleave_queue[i].STRB[0]);
       		vif.mdrv_cb.WDATA <= interleave_queue[i].DATA[0];
	        interleave_queue[i].DATA = interleave_queue[i].DATA[1:$];
            last_queue.push_back(interleave_queue[i].DATA[$]);
			interleave_queue[i].DATA = interleave_queue[i].DATA[0:$-1];
            `uvm_info("last_QUEUE",$sformatf("last_queue size= %0d, last_queue=%0p",last_queue.size(),last_queue),UVM_NONE)
	 		vif.mdrv_cb.WVALID <= 1;
	 		wait(vif.WREADY);
            @(vif.mdrv_cb);
	        vif.mdrv_cb.WVALID <= 0;	
	 end

     `uvm_info("interleave_queue size",$sformatf("Size of interleave_queue in wchannel = %0d",interleave_queue.size()),UVM_NONE)
	
   /* for(int i=0;i<axi_config::interleaving_depth;i++)begin
      `uvm_info("outer loop",$sformatf("i = %0d",i),UVM_NONE)
       // for(int j=0;j<2;j++) begin
           @(vif.mdrv_cb);
	   		interleave_queue.shuffle();
     	 //  `uvm_info("iner loop",$sformatf("j = %0d",j),UVM_NONE)
     	   `uvm_info("interleave pack",$sformatf("interleave queue is %h",interleave_queue[i].ID),UVM_NONE)
     	   `uvm_info("iteration",$sformatf("i=%0d",i),UVM_NONE)
		    interleave_queue[i].print();
	   		vif.mdrv_cb.WID <= interleave_queue[i].ID;
     		vif.mdrv_cb.WSTRB <= interleave_queue[i].STRB[0];
       		vif.mdrv_cb.WDATA <= interleave_queue[i].DATA[0];
	        interleave_queue[i].DATA = interleave_queue[i].DATA[1:$];
	 		vif.mdrv_cb.WVALID <= 1;
	 		wait(vif.WREADY);
            @(vif.mdrv_cb);
	        vif.mdrv_cb.WVALID <= 0;	

		//end   
	end */ 

		  while(1)begin

		         /*   @(vif.mdrv_cb);
					interleave_queue.shuffle();
	   				vif.mdrv_cb.WID <= interleave_queue[0].ID;
     				vif.mdrv_cb.WSTRB <= interleave_queue[0].STRB[0];
       				vif.mdrv_cb.WDATA <= interleave_queue[0].DATA[0];
	        		interleave_queue[0].DATA = interleave_queue[0].DATA[1:$];
	 				vif.mdrv_cb.WVALID <= 1;
	 				wait(vif.WREADY);
           		 	@(vif.mdrv_cb);
	                vif.mdrv_cb.WVALID <= 0;	

					if(interleave_queue[0].DATA.size()==0)begin
                      interleave_queue = interleave_queue[1:$];
					end

		      if(interleave_queue.size()!=axi_config::interleaving_depth && w_queue.size()>0)begin
			      //wait(w_queue.size()>0);
	   			 // interleave_trans = w_queue.pop_front();
	   			  //interleave_queue = w_queue.pop_front();
       			  //interleave_queue.push_back(w_queue.pop_front());
				  //last_queue.push_back(interleave_queue[].DATA[$]);
               end  */

    			for(int i=0;i<interleave_queue.size();i++)begin
      				`uvm_info("outer loop",$sformatf("i = %0d",i),UVM_NONE)
           			@(vif.mdrv_cb);
     	   			//`uvm_info("interleave pack",$sformatf("interleave queue is %h",interleave_queue[i].ID),UVM_NONE)
     	   			`uvm_info("iteration",$sformatf("i=%0d",i),UVM_NONE)
		    		//interleave_queue[i].print();
	   				vif.mdrv_cb.WID <= interleave_queue[i].ID;
     				vif.mdrv_cb.WSTRB <= interleave_queue[i].STRB[0];
       				vif.mdrv_cb.WDATA <= interleave_queue[i].DATA[0];
	        		interleave_queue[i].DATA = interleave_queue[i].DATA[1:$];
	 				vif.mdrv_cb.WVALID <= 1;
	 				wait(vif.WREADY);
           		 	@(vif.mdrv_cb);
	                vif.mdrv_cb.WVALID <= 0;	
					if(interleave_queue[i].DATA.size()==0)begin
                      //interleave_queue = interleave_queue[1:$];
					  interleave_queue.delete(i);
					end
		          if(interleave_queue.size()!=axi_config::interleaving_depth && w_queue.size()>0)begin
       			     interleave_queue.push_back(w_queue.pop_front());
				     last_queue.push_back(interleave_queue[$].DATA[$]);
					 id_queue.push_back(interleave_queue[$].ID);
					 strb_queue.push_back(interleave_queue[$].STRB[0]);
				     interleave_queue[$].DATA = interleave_queue[$].DATA[0:$-1];
                  end  
			

				end  

			 

			    `uvm_info("inside interleave_queue size",$sformatf("Size of interleave_queue in wchannel = %0d, count=%0d",interleave_queue.size(),count),UVM_NONE)

      		    `uvm_info("Master Driver",$sformatf("Size after queue deletion:w_queue size = %0d", w_queue.size()),UVM_NONE);

			

			    if(interleave_queue.size()==0)begin
                 break;
			    end

		  end 

        `uvm_info("last_queue",$sformatf("last_queue size= %0d, last_queue=%0p",last_queue.size(),last_queue),UVM_NONE)
		   
	 	for(int i=0;i<last_queue.size();i++)begin
            @(vif.mdrv_cb);
      	    `uvm_info("loop",$sformatf("i = %0d",i),UVM_NONE)
      	    vif.mdrv_cb.WID <= id_queue.pop_front();
     		vif.mdrv_cb.WSTRB <= strb_queue.pop_front();
       		vif.mdrv_cb.WDATA <= last_queue[i];
	        //last_queue[i].DATA = last_queue[i].DATA[1:$];
			//last_queue.delete(i);
	 		vif.mdrv_cb.WVALID <= 1;
	        vif.mdrv_cb.WLAST <= 1;
	 		wait(vif.WREADY);
            @(vif.mdrv_cb);
	        vif.mdrv_cb.WLAST <= 0;
	        vif.mdrv_cb.WVALID <= 0;	
	 	end 
               
			 axi_config::cnt=1;  
       	     //interleave_queue.delete();
			 last_queue.delete();
	 end 
	else begin

      `uvm_info("MDRV","W_Channel else part without interleaving concept",UVM_NONE)
     `uvm_info("UPVIT",$sformatf("before Size of w_queue in wchannel before interleaving = %0d",w_queue.size()),UVM_NONE)
	  //wait(w_queue.size()>0);
	   foreach(w_queue[i])begin
     	for(int j=0;j<=w_queue[i].LEN;j++)begin
            @(vif.mdrv_cb);
    		//`uvm_info(get_type_name(),$sformatf("I=%0d, LEN=%0d",i,req.LEN),UVM_NONE)
     		//`uvm_info(get_type_name(),$sformatf("[MDRIVER before]from master driver into w_channel::wdata=%0d",req.DATA.pop_front()),UVM_NONE)
    	    vif.mdrv_cb.WID <= w_queue[i].ID;
			//w_queue[i].DATA.shuffle();
     		vif.mdrv_cb.WSTRB <= w_queue[i].STRB[j];
     		vif.mdrv_cb.WDATA <= w_queue[i].DATA[j];
	 		vif.mdrv_cb.WVALID <= 1;
	 		wait(vif.WREADY);
     		//`uvm_info(get_type_name(),$sformatf("[MDRIVER after]from master driver into w_channel::wdata=%0d",req.DATA),UVM_NONE)
     		if(j==w_queue[i].LEN)vif.mdrv_cb.WLAST <= 1;
            @(vif.mdrv_cb);
	        vif.mdrv_cb.WLAST <= 0;
	        vif.mdrv_cb.WVALID <= 0;	
     	end
   	   end 

	  axi_config::cnt=1;  
	  `uvm_info("Master Driver","--- from W_channel Delete complete queue ---",UVM_NONE);
      w_queue.delete();
      `uvm_info("Master Driver",$sformatf("Size after queue deletion:w_queue size = %0d", w_queue.size()),UVM_NONE);
     `uvm_info(get_type_name(),$sformatf("from w_channel::WVALID=%0d, DATA=%0d,STRB=%0d,ID=%0d,LAST=%0d, WREADY=%0d",vif.WVALID,vif.WDATA,vif.WSTRB,req.ID,req.LAST,vif.WREADY),UVM_LOW)
     end
     
	 //end

	 end
       
  endtask
  
 
  
  task ar_channel();
    // read address channel signals (AR)
	forever begin
    
     `uvm_info("Master Driver",$sformatf("Size before queue:ar_queue size = %0d", ar_queue.size()),UVM_NONE);
     //`uvm_info("Master Driver",$sformatf("control = %0s", ar_queue[0].CONTROL),UVM_NONE);
     wait(ar_queue.size()>0);
     foreach(ar_queue[i])begin
	//if(ar_queue[i].CONTROL==READ)begin
        @(vif.mdrv_cb);
    	vif.mdrv_cb.ARID <= ar_queue[i].ID;
    	vif.mdrv_cb.ARADDR <= ar_queue[i].ADDR;
    	vif.mdrv_cb.ARLEN <= ar_queue[i].LEN;
    	vif.mdrv_cb.ARSIZE <= ar_queue[i].SIZE;
    	vif.mdrv_cb.ARBURST <= ar_queue[i].BURST;
		vif.mdrv_cb.ARLOCK <= ar_queue[i].LOCK;
		vif.mdrv_cb.ARVALID <= 1;
        wait(vif.ARREADY);
        @(vif.mdrv_cb);
	    vif.mdrv_cb.ARVALID <= 0;
	 end

	   `uvm_info("Master Driver","--- from AR_channel Delete complete queue ---",UVM_NONE);
       ar_queue.delete();
       `uvm_info("Master Driver",$sformatf("Size after queue deletion:ar_queue size = %0d", ar_queue.size()),UVM_NONE);

    //end
  

	end
  endtask 
  
endclass
