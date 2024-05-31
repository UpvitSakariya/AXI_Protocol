class axi_outstanding_incr_seq extends axi_base_sequence;
  
  `uvm_object_utils(axi_outstanding_incr_seq)
   axi_transaction req;
   bit [3:0]id_queue[$];
   bit [31:0]addr_queue[$];
   int cnt=0;

  function new(string name = "axi_outstanding_incr_seq");
    super.new(name);
    `uvm_info(get_type_name(),"inside constructor",UVM_LOW)
  endfunction
  
  task body();
    `uvm_info(get_type_name(),"inside body task",UVM_LOW)
     

    repeat(axi_config::Number_of_transaction)begin
	  req = axi_transaction::type_id::create("req");
	  if(cnt==axi_config::outstanding)begin
       wait(axi_config::Flag==1);
	  end
	  start_item(req);
        //`uvm_error(get_type_name(),$sformatf("randomization fail"))
      assert(req.randomize() with {req.LEN==TRANSFER4;req.SIZE==BYTE4;req.BURST==INCR;req.LOCK==NORMAL;req.CONTROL==WRITE;});
	  id_queue.push_back(req.ID);
	  addr_queue.push_back(req.ADDR);
      //`uvm_info(get_type_name(),$sformatf("--------DATA=%0p,LEN=%0d,ID=%0d,SIZE=%0d",req.DATA,req.LEN,req.ID,req.SIZE),UVM_LOW)
      `uvm_info("INCR Sequence","This is Generated packat",UVM_LOW)
	  req.print();
	  finish_item(req);
	  cnt++;
    end

     //#480;
     
    wait(axi_config::cnt==1);
	 //read sequence
	 repeat(axi_config::Number_of_transaction)begin
	  req = axi_transaction::type_id::create("req");
	   start_item(req);
      assert(req.randomize() with {req.LEN==TRANSFER4;req.SIZE==BYTE4;req.BURST==INCR;req.ID==id_queue[0];req.ADDR==addr_queue[0];req.LOCK==NORMAL;req.CONTROL==READ;});
	  id_queue = id_queue[1:$];
	  addr_queue = addr_queue[1:$];
      `uvm_info("INCR Sequence","This is Generated packat",UVM_LOW)
	  req.print();
	  finish_item(req);
	  end
 
  endtask
  
endclass
