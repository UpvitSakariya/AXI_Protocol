class axi_storage extends uvm_component;
  
  `uvm_component_utils(axi_storage)
  //port declaration
  uvm_analysis_imp #(axi_transaction,axi_storage) analysis_export;
  //uvm_analysis_port #(axi_transaction) request_port;

  bit [7:0]mem[bit[31:0]];
  bit [31:0]temp_addr;
  bit [31:0]fixed_wdata;
  bit [7:0]fixed_rdata;
  bit [31:0]incr_wdata;
  bit [31:0]incr_rdata;
  bit [3:0]temp_strobe;
  int inc;
  axi_transaction tx_queue[$];

  // burst type wrap calculation
  bit [31:0]start_addr;
  bit [31:0]aligned_addr;
  bit [7:0]total_size;
  bit [3:0]remainder;
  bit [31:0]lower_wrap;
  bit [31:0]upper_wrap;


  function new(string name = "axi_storage",uvm_component parent);
    super.new(name,parent);
    `uvm_info(get_type_name(),"inside constructor",UVM_LOW)
	analysis_export = new("analysis_export",this);
	//request_port = new("request_port",this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(),"build phase",UVM_LOW)
	
  endfunction

  function void write(axi_transaction tx);
   `uvm_info("storage","storage received a packet",UVM_NONE)
    tx.print();
    tx_queue.push_back(tx);
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info(get_type_name(),"run phase",UVM_LOW)

 
	forever begin

     axi_transaction tx;
  	 `uvm_info("storage",$sformatf("size of tx_queue in storage=%0d",tx_queue.size()),UVM_NONE)
	 wait(tx_queue.size()>0);
     tx = tx_queue.pop_front();
	`uvm_info("Storage","after size of tx_queue greatet than zero",UVM_LOW)
	 //tx.print();
     `uvm_info(get_type_name(),$sformatf("from strorage control - %s",tx.CONTROL),UVM_LOW);
	 if(tx.CONTROL == WRITE)begin

	 case(tx.BURST)
	 2'b00:begin
	    temp_addr = tx.ADDR;
	    `uvm_info(get_type_name(),$sformatf("temp_addr=%0h, wdata=%0d",temp_addr,fixed_wdata),UVM_NONE)
		for(int i=0;i<=tx.LEN;i++)begin
	     fixed_wdata = tx.DATA[i];
		 temp_strobe = tx.STRB[i];
         `uvm_info(get_type_name(),$sformatf("from w_channel::DATA=%0h,i=%0d",fixed_wdata,i),UVM_NONE)
         for(int j=0;j<`DATA_WIDTH/8;j++)begin
	      `uvm_info(get_type_name(),$sformatf("from w_channel::j=%0d",j),UVM_NONE)
		  		if(temp_strobe[j]==1 && tx.LOCK!=EXCLUSIVE)begin
           			mem[temp_addr] = fixed_wdata[j*8+:8];
	      			`uvm_info(get_type_name(),$sformatf("from w_channel::mem=%0h,temp_addr=%0h",mem[temp_addr],(temp_addr)),UVM_NONE)
          			`uvm_info(get_type_name(),$sformatf("temp_addr=%0h, wdata=%0d",temp_addr,fixed_wdata),UVM_NONE)
		  		end
          end
          `uvm_info(get_type_name(),$sformatf("from w_channel::temp_addr=%0d",temp_addr),UVM_NONE)
		   if(i==tx.LEN && tx.LOCK==NORMAL)begin
		  tx.RESP = OKAY;
         `uvm_info(get_type_name(),$sformatf("before::addr=%0h",tx.ADDR),UVM_NONE)
		  //tx. */
          `uvm_info(get_type_name(),"sending write response of incr type transaction to slave sequence",UVM_NONE)
          axi_transaction::mem2seq.put(tx);
		 end
		 else if(i==tx.LEN && tx.LOCK==EXCLUSIVE)begin
         tx.RESP = EXOKAY;
         `uvm_info(get_type_name(),$sformatf("before::addr=%0h",tx.ADDR),UVM_NONE)
		  //tx.
          `uvm_info(get_type_name(),"sending write response of incr type transaction to slave sequence",UVM_NONE)
          axi_transaction::mem2seq.put(tx);
		 end 
  	    end 
	  end
	  2'b01:begin

	     temp_addr = tx.ADDR;
         `uvm_info(get_type_name(),$sformatf("before::addr=%0h",tx.ADDR),UVM_NONE)
        for(int i=0;i<=tx.LEN;i++)begin
         incr_wdata = tx.DATA[i];
		 temp_strobe = tx.STRB[i];
         `uvm_info(get_type_name(),$sformatf("from w_channel::DATA=%0h,size=%0d,i=%0d",incr_wdata,tx.STRB.size(),i),UVM_NONE)

         for(int j=0,cnt=0;j<`DATA_WIDTH/8;j++)begin

	      	`uvm_info("tom",$sformatf("from w_channel::j=%0d, strobe=%0b,addr=%0h",j,temp_strobe,temp_addr),UVM_NONE)
		 	if(temp_strobe[j]==1 && tx.LOCK!=EXCLUSIVE)begin
	      	   `uvm_info("jerry",$sformatf("from w_channel::j=%0d",j),UVM_NONE)
          		mem[temp_addr+cnt] = incr_wdata[j*8+:8];
	      		`uvm_info(get_type_name(),$sformatf("from w_channel::mem=%0h,temp_addr=%0h",mem[temp_addr+cnt],(temp_addr+cnt)),UVM_NONE)
				cnt++;
          	end
          		inc = cnt;

         end
         temp_addr = temp_addr + inc; 
         `uvm_info(get_type_name(),$sformatf("from w_channel::temp_addr=%0h, inc=%0d",temp_addr,inc),UVM_NONE)
		 if(i==tx.LEN && tx.LOCK!=EXCLUSIVE)begin
		 `uvm_info("OKAY","SENDING OKAY RESPONSE",UVM_NONE)
		  tx.RESP = OKAY;
         `uvm_info(get_type_name(),$sformatf("before::addr=%0h",tx.ADDR),UVM_NONE) 
          `uvm_info(get_type_name(),"sending write response of incr type transaction to slave sequence",UVM_NONE)
          axi_transaction::mem2seq.put(tx);
	     end
		 else if(i==tx.LEN && tx.LOCK==EXCLUSIVE)begin
		 `uvm_info("EXOKAY","SENDING EXOKAY RESPONSE",UVM_NONE)
         tx.RESP = EXOKAY;
         `uvm_info(get_type_name(),$sformatf("before::addr=%0h",tx.ADDR),UVM_NONE)
          `uvm_info(get_type_name(),"sending write response of incr type transaction to slave sequence",UVM_NONE)
          axi_transaction::mem2seq.put(tx);
		 end 
	    end 
	  end
	  2'b10:begin
  			total_size=(tx.LEN+1)*(2**tx.SIZE);
  			remainder=tx.ADDR%total_size;
  			lower_wrap=tx.ADDR-remainder;
  			upper_wrap=lower_wrap+total_size;

		
         temp_addr = tx.ADDR;
	    `uvm_info(get_type_name(),$sformatf("temp_addr=%0d, wdata=%0d",temp_addr,incr_wdata),UVM_NONE)
		
        for(int i=0;i<=tx.LEN;i++)begin
	     `uvm_info(get_type_name(),$sformatf("from r_channel::aligned_addr=%0d, temp_addr=%0h, total_size=%0d, remainder=%0d, lower_wrap=%0h, upper_wrap=%0h",aligned_addr,temp_addr,total_size,remainder,lower_wrap,upper_wrap),UVM_NONE)
         incr_wdata = tx.DATA[i];
		 temp_strobe = tx.STRB[i];
	      `uvm_info("WRAP",$sformatf("from w_channel::i=%0d,strobe=%0d, data=%0h",i,temp_strobe,incr_wdata),UVM_NONE)
         for(int j=0,cnt=0;j<`DATA_WIDTH/8;j++)begin

	      		`uvm_info("jacky",$sformatf("from w_channel::j=%0d,strobe size=%0d, addr=%0h, data=%0h",j,temp_strobe,temp_addr,incr_wdata),UVM_NONE)
		   	if(temp_strobe[j]==1 && tx.LOCK!=EXCLUSIVE)begin
	      		`uvm_info("chane",$sformatf("from w_channel::j=%0d",j),UVM_NONE)
          		mem[temp_addr+cnt] = incr_wdata[j*8+:8];
	      		`uvm_info(get_type_name(),$sformatf("from w_channel::mem=%0h,temp_addr=%0h",mem[temp_addr+cnt],(temp_addr+cnt)),UVM_NONE)
				cnt++;
		   	end
          inc = cnt;
         end
         temp_addr = temp_addr + inc; 
         if(temp_addr==upper_wrap)begin
	     temp_addr = lower_wrap;
		 end
         `uvm_info(get_type_name(),$sformatf("from w_channel::temp_addr=%0d, inc=%0d",temp_addr,inc),UVM_NONE)
		 if(i==tx.LEN && tx.LOCK==NORMAL)begin
		   tx.RESP = OKAY;
           `uvm_info(get_type_name(),$sformatf("before::addr=%0h",tx.ADDR),UVM_NONE) 
           `uvm_info(get_type_name(),"sending write response of incr type transaction to slave sequence",UVM_NONE)
           axi_transaction::mem2seq.put(tx);
		 end
		 else if(i==tx.LEN && tx.LOCK==EXCLUSIVE)begin
           tx.RESP = EXOKAY;
           `uvm_info(get_type_name(),$sformatf("before::addr=%0h",tx.ADDR),UVM_NONE)
           `uvm_info(get_type_name(),"sending write response of incr type transaction to slave sequence",UVM_NONE)
           axi_transaction::mem2seq.put(tx);
		 end 
	    end 

	  end

     endcase

	 end
	 else if(tx.CONTROL==READ)begin
     `uvm_info(get_type_name(),$sformatf("from strorage control - %s",tx.CONTROL),UVM_LOW);

	 case(tx.BURST)
	 2'b00:begin
	     temp_addr = tx.ADDR;
         fixed_rdata = mem[temp_addr];
         tx.DATA.push_back(fixed_rdata);
         `uvm_info(get_type_name(),$sformatf("Read mailbox befor read put - %p",axi_transaction::mem2seq),UVM_LOW);
	     //tx.print();
		 `uvm_info("storage","sending fixed type packet to the slave sequence from storage",UVM_LOW)
		   if(tx.LOCK==NORMAL)begin
		 `uvm_info("OKAY","SENDING OKAY RESPONSE",UVM_NONE)
		  tx.RESP = OKAY;
         `uvm_info(get_type_name(),$sformatf("before::addr=%0h",tx.ADDR),UVM_NONE) 
          `uvm_info(get_type_name(),"sending write response of incr type transaction to slave sequence",UVM_NONE)
          axi_transaction::mem2seq.put(tx);
		 end
		 else if(tx.LOCK==EXCLUSIVE)begin
		 `uvm_info("EXOKAY","SENDING EXOKAY RESPONSE",UVM_NONE)
         tx.RESP = EXOKAY;
         `uvm_info(get_type_name(),$sformatf("before::addr=%0h",tx.ADDR),UVM_NONE)
          `uvm_info(get_type_name(),"sending write response of incr type transaction to slave sequence",UVM_NONE)
		  tx.print();
          axi_transaction::mem2seq.put(tx);
		 end 

         // tx.print(); 
        // axi_transaction::mem2seq.put(tx);
         //`uvm_info(get_type_name(),$sformatf("[FIXED]after putting into the mailbox it's size = %0d",axi_transaction::mem2seq.num()),UVM_LOW);
	   end
	 2'b01:begin
	     temp_addr = tx.ADDR;
       	for(int i=0;i<=tx.LEN;i++)begin
	     `uvm_info(get_type_name(),$sformatf("from r_channel::i=%0d, temp_addr=%0h",i,temp_addr),UVM_NONE)
	     for(int j=0;j<2**tx.SIZE;j++)begin
	      `uvm_info(get_type_name(),$sformatf("from r_channel::j=%0d, temp_addr=%0h",j,temp_addr),UVM_NONE)
          incr_rdata[j*8+:8] = mem[temp_addr+j];
	      `uvm_info(get_type_name(),$sformatf("from r_channel::mem=%0h,temp_addr=%0h",mem[temp_addr+j],(temp_addr+j)),UVM_NONE)
	      inc = j+1;
	     end
         temp_addr = temp_addr + inc;
		  tx.DATA.push_back(incr_rdata);
	     `uvm_info(get_type_name(),$sformatf("from r_channel::temp_addr=%0h, inc=%0d",temp_addr,inc),UVM_NONE)
		  if(i==tx.LEN && tx.LOCK==NORMAL)begin
		 `uvm_info("OKAY","SENDING OKAY RESPONSE",UVM_NONE)
		  tx.RESP = OKAY;
         `uvm_info(get_type_name(),$sformatf("before::addr=%0h",tx.ADDR),UVM_NONE) 
          `uvm_info(get_type_name(),"sending write response of incr type transaction to slave sequence",UVM_NONE)
          axi_transaction::mem2seq.put(tx);
		 end
		 else if(i==tx.LEN && tx.LOCK==EXCLUSIVE)begin
		 `uvm_info("EXOKAY","SENDING EXOKAY RESPONSE",UVM_NONE)
         tx.RESP = EXOKAY;
         `uvm_info(get_type_name(),$sformatf("before::addr=%0h",tx.ADDR),UVM_NONE)
          `uvm_info(get_type_name(),"sending write response of incr type transaction to slave sequence",UVM_NONE)
		  tx.print();
          axi_transaction::mem2seq.put(tx);
		 end 

	    end  
		 //`uvm_info("storage","sending incr type packet to the slave sequence from storage",UVM_LOW)
		 // tx.print();
          //axi_transaction::mem2seq.put(tx);
	  // `uvm_info(get_type_name(),$sformatf("[INCR]after putting into the mailbox it's size=%0d",axi_transaction::mem2seq.num()),UVM_NONE)

	    end
	 2'b10:begin
  			total_size=(tx.LEN+1)*(2**tx.SIZE);
  			remainder=tx.ADDR%total_size;
  			lower_wrap=tx.ADDR-remainder;
  			upper_wrap=lower_wrap+total_size;

         temp_addr = tx.ADDR;
	    `uvm_info(get_type_name(),$sformatf("temp_addr=%0h, wdata=%0d",temp_addr,incr_rdata),UVM_NONE)
       	for(int i=0;i<=tx.LEN;i++)begin
	     `uvm_info(get_type_name(),$sformatf("from r_channel::aligned_addr=%0d, temp_addr=%0h, total_size=%0d, remainder=%0d, lower_wrap=%0h, upper_wrap=%0h",aligned_addr,temp_addr,total_size,remainder,lower_wrap,upper_wrap),UVM_NONE)
	     `uvm_info(get_type_name(),$sformatf("from r_channel::i=%0d, temp_addr=%0h",i,temp_addr),UVM_NONE)
	     for(int j=0;j<2**tx.SIZE;j++)begin
	      `uvm_info(get_type_name(),$sformatf("from r_channel::j=%0d, temp_addr=%0h",j,temp_addr),UVM_NONE)
          incr_rdata[j*8+:8] = mem[temp_addr+j];
	      `uvm_info(get_type_name(),$sformatf("from w_channel::mem=%0h,temp_addr=%0h,incr_rdata=%0h",mem[temp_addr+j],(temp_addr+j),incr_rdata),UVM_NONE)
	      inc = j+1;
	     end
         temp_addr = temp_addr + inc;
         if(temp_addr==upper_wrap)begin
	     temp_addr = lower_wrap;
		 end
		  tx.DATA.push_back(incr_rdata);
	     `uvm_info(get_type_name(),$sformatf("from r_channel::temp_addr=%0h, inc=%0d",temp_addr,inc),UVM_NONE)
		 if(i==tx.LEN && tx.LOCK==NORMAL)begin
		 `uvm_info("OKAY","SENDING OKAY RESPONSE",UVM_NONE)
		  tx.RESP = OKAY;
         `uvm_info(get_type_name(),$sformatf("before::addr=%0h",tx.ADDR),UVM_NONE) 
          `uvm_info(get_type_name(),"sending write response of incr type transaction to slave sequence",UVM_NONE)
          axi_transaction::mem2seq.put(tx);
		 end
		 else if(i==tx.LEN && tx.LOCK==EXCLUSIVE)begin
		 `uvm_info("EXOKAY","SENDING EXOKAY RESPONSE",UVM_NONE)
         tx.RESP = EXOKAY;
         `uvm_info(get_type_name(),$sformatf("before::addr=%0h",tx.ADDR),UVM_NONE)
          `uvm_info(get_type_name(),"sending write response of incr type transaction to slave sequence",UVM_NONE)
		  tx.print();
          axi_transaction::mem2seq.put(tx);
		 end 

	    end
         
		// `uvm_info("storage","sending wrap type packet to the slave sequence from storage",UVM_LOW)
		// tx.print(); 
        // axi_transaction::mem2seq.put(tx);
	    //`uvm_info(get_type_name(),$sformatf("after putting into the mailbox it's size=%0d",axi_transaction::mem2seq.num()),UVM_NONE)
	 end

	 endcase
	   
	  end

  end

endtask

   
endclass
