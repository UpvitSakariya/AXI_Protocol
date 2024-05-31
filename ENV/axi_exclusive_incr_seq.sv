class axi_exclusive_incr_seq extends axi_base_sequence;
  
  `uvm_object_utils(axi_exclusive_incr_seq)
  int i=0;

  function new(string name = "axi_exclusive_incr_seq");
    super.new(name);
    `uvm_info(get_type_name(),"inside constructor",UVM_LOW)
  endfunction
  
  task body();
    `uvm_info(get_type_name(),"inside body task",UVM_LOW)
   
    
    // read sequence 
    repeat(axi_config::Number_of_Read_transaction)begin
	  req = axi_transaction::type_id::create("req");
	   start_item(req);
        //`uvm_error(get_type_name(),$sformatf("randomization fail"))
      assert(req.randomize() with {req.SIZE==BYTE4;req.BURST==INCR;req.CONTROL==READ;req.LOCK==EXCLUSIVE;});
	   id_queue.push_back(req.ID);
	   len_queue.push_back(req.LEN);
	   addr_queue.push_back(req.ADDR);
	   lock_queue.push_back(req.LOCK);
      `uvm_info(get_type_name(),$sformatf("--------id_queue=%0p,addr_queue=%0p,ID_queue size=%0d,addr_queue SIZE=%0d",id_queue,addr_queue,id_queue.size,addr_queue.size()),UVM_LOW)
      `uvm_info("INCR Sequence","This is Generated packat",UVM_LOW)
	  req.print();
	  finish_item(req);
	  get_response(req);
	  `uvm_info("READ_RESPONSE","request got from master driver",UVM_MEDIUM)
    end

	repeat(axi_config::Number_of_Read_transaction)begin
	  req = axi_transaction::type_id::create("req");
	   start_item(req);
        //`uvm_error(get_type_name(),$sformatf("randomization fail"))
      assert(req.randomize() with {req.SIZE==BYTE4;req.BURST==INCR;req.CONTROL==READ;req.LOCK==NORMAL;});
	   id_queue.push_back(req.ID);
	   len_queue.push_back(req.LEN);
	   addr_queue.push_back(req.ADDR);
	   lock_queue.push_back(req.LOCK);
      `uvm_info(get_type_name(),$sformatf("--------id_queue=%0p,addr_queue=%0p,ID_queue size=%0d,addr_queue SIZE=%0d",id_queue,addr_queue,id_queue.size,addr_queue.size()),UVM_LOW)
      `uvm_info("INCR Sequence","This is Generated packat",UVM_LOW)
	  req.print();
	  finish_item(req);
	  get_response(req);
	  `uvm_info("READ_RESPONSE","request got from master driver",UVM_MEDIUM)
    end 


    #200;
    //wait(axi_config::cnt==1);
	//write sequence
    repeat(axi_config::Number_of_transaction)begin
	  req = axi_transaction::type_id::create("req");
	   start_item(req);
      assert(req.randomize() with {req.SIZE==BYTE4;req.BURST==INCR;req.ADDR==addr_queue[i];req.ID==id_queue[i];req.LEN==len_queue[i];req.LOCK==lock_queue[i];req.CONTROL==WRITE;});
	 // id_queue = id_queue[1:$];
	 // len_queue = len_queue[1:$];
	 // addr_queue = addr_queue[1:$];
	 // lock_queue = lock_queue[1:$];
      `uvm_info("INCR Sequence","This is Generated packat",UVM_LOW)
	  i++;
	  req.print();
	  finish_item(req);
	  get_response(req);
	  `uvm_info("WRITE_RESPONSE","request got from master driver",UVM_MEDIUM)
    end  

	#1000;i=0;

	repeat(axi_config::Number_of_transaction)begin
	  req = axi_transaction::type_id::create("req");
	   start_item(req);
        //`uvm_error(get_type_name(),$sformatf("randomization fail"))
      assert(req.randomize() with {req.SIZE==BYTE4;req.BURST==INCR;req.ADDR==addr_queue[i];req.ID==id_queue[i];req.LEN==len_queue[i];req.LOCK==lock_queue[i];req.CONTROL==READ;});
	   //id_queue.push_back(req.ID);
	   //len_queue.push_back(req.LEN);
	   //addr_queue.push_back(req.ADDR);
	   //lock_queue.push_back(req.LOCK);
      `uvm_info(get_type_name(),$sformatf("--------id_queue=%0p,addr_queue=%0p,ID_queue size=%0d,addr_queue SIZE=%0d",id_queue,addr_queue,id_queue.size,addr_queue.size()),UVM_LOW)
	  i++;
      `uvm_info("INCR Sequence","This is Generated packat",UVM_LOW)
	  req.print();
	  finish_item(req);
	  get_response(req);
	  `uvm_info("READ_RESPONSE","request got from master driver",UVM_MEDIUM)
    end  
 
    
  endtask 
  
endclass
