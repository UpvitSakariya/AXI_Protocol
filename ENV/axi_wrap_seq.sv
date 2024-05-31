class axi_wrap_seq extends axi_base_sequence;
  
  `uvm_object_utils(axi_wrap_seq)
   axi_transaction req;

  function new(string name = "axi_wrap_seq");
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
      assert(req.randomize() with {req.LEN==TRANSFER5;req.SIZE==BYTE4;req.BURST==WRAP;});
      //`uvm_info(get_type_name(),$sformatf("--------DATA=%0p,LEN=%0d,ID=%0d,SIZE=%0d",req.DATA,req.LEN,req.ID,req.SIZE),UVM_LOW)
      `uvm_info("WRAP Sequence","This is Generated packat",UVM_LOW)
	  req.print();
	  finish_item(req);
    end

	//read sequence
    //repeat(1)begin
      //`uvm_do_with(req,{req.control==READ;req.LEN==0;req.SIZE==0;req.BURST==0;})
        //`uvm_error(get_type_name(),$sformatf("randomization fail"))
      //`uvm_info(get_type_name(),$sformatf("--------DATA=%0p,LEN=%0d,ID=%0d,SIZE=%0d",req.DATA,req.LEN,req.ID,req.SIZE),UVM_LOW)
     	// req.print();
    //end 
    
  endtask
  
endclass
