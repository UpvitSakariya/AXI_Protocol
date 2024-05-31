class axi_incr_wr_seq extends axi_base_sequence;
  
  `uvm_object_utils(axi_incr_wr_seq)
   axi_transaction req,wr_req,rd_req;
   bit [3:0]id_queue[$];
   bit [3:0]len_queue[$];
   bit [31:0]addr_queue[$];

  function new(string name = "axi_incr_wr_seq");
    super.new(name);
    `uvm_info(get_type_name(),"inside constructor",UVM_LOW)
  endfunction
  
  task body();
    `uvm_info(get_type_name(),"inside body task",UVM_LOW)
   
    
    // write sequence 
    repeat(axi_config::Number_of_transaction)begin
	  req = axi_transaction::type_id::create("req");
	   start_item(req);
        //`uvm_error(get_type_name(),$sformatf("randomization fail"))
      assert(req.randomize() with {req.SIZE==BYTE4;req.BURST==INCR;});
	   id_queue.push_back(req.ID);
	   len_queue.push_back(req.LEN);
	   addr_queue.push_back(req.ADDR);
      `uvm_info(get_type_name(),$sformatf("--------id_queue=%0p,addr_queue=%0p,ID_queue size=%0d,addr_queue SIZE=%0d",id_queue,addr_queue,id_queue.size,addr_queue.size()),UVM_LOW)
      `uvm_info("INCR Sequence","This is Generated packat",UVM_LOW)
	  req.print();
	  finish_item(req);
	  get_response(req);
    end
       
  endtask
  
endclass
