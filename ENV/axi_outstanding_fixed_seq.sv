class axi_outstanding_fixed_seq extends axi_base_sequence;
  
  `uvm_object_utils(axi_outstanding_fixed_seq)
   axi_transaction req;
   int cnt=0;

  function new(string name = "axi_outstanding_fixed_seq");
    super.new(name);
    `uvm_info(get_type_name(),"inside constructor",UVM_LOW)
  endfunction
  
  task body();
    `uvm_info(get_type_name(),"inside body task",UVM_LOW)
    
    
    // write sequence
	if(axi_config::outstanding>0)begin
    

    repeat(axi_config::Number_of_transaction)begin
	  req = axi_transaction::type_id::create("req");
	  if(cnt==axi_config::outstanding)begin
       wait(axi_config::Flag==1);
	  end
	  start_item(req);
        //`uvm_error(get_type_name(),$sformatf("randomization fail"))
      assert(req.randomize() with {req.LEN==TRANSFER3;req.SIZE==BYTE4;req.BURST==FIXED;});
      //`uvm_info(get_type_name(),$sformatf("--------DATA=%0p,LEN=%0d,ID=%0d,SIZE=%0d",req.DATA,req.LEN,req.ID,req.SIZE),UVM_LOW)
      `uvm_info("INCR Sequence","This is Generated packat",UVM_LOW)
	  req.print();
	  finish_item(req);
	  cnt++;
    end


    end
	else begin
     
	 repeat(axi_config::Number_of_transaction)begin
	  req = axi_transaction::type_id::create("req");
	   start_item(req);
        //`uvm_error(get_type_name(),$sformatf("randomization fail"))
      assert(req.randomize() with {req.LEN==TRANSFER4;req.SIZE==BYTE4;req.BURST==INCR;});
      //`uvm_info(get_type_name(),$sformatf("--------DATA=%0p,LEN=%0d,ID=%0d,SIZE=%0d",req.DATA,req.LEN,req.ID,req.SIZE),UVM_LOW)
      `uvm_info("INCR Sequence","This is Generated packat",UVM_LOW)
	  req.print();
	  finish_item(req);
	  end

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
