
class axi_slave_sequence extends uvm_sequence#(axi_transaction);
  
  `uvm_object_utils(axi_slave_sequence)

  axi_transaction item;
  
  function new(string name = "axi_slave_sequence");
    super.new(name);
    `uvm_info(get_type_name(),"inside constructor",UVM_LOW)
	item = axi_transaction::type_id::create("item");
  endfunction

 
  task body();
    `uvm_info(get_type_name(),"inside body task",UVM_LOW)
     
    forever begin
	  //item.print();
    //repeat(5)begin
	 `uvm_info(get_type_name(),$sformatf("before getting packact in sequence - %p, size=%0d",axi_transaction::mem2seq,axi_transaction::mem2seq.num()),UVM_NONE)
     axi_transaction::mem2seq.get(item);
	 `uvm_info(get_type_name(),$sformatf("after getting packet from mailbox - %p, size=%0d",axi_transaction::mem2seq,axi_transaction::mem2seq.num()),UVM_NONE)
	 item.print();
	 start_item(item);
	 `uvm_info(get_type_name(),"------------------",UVM_LOW)
	  item.print();
      // item.ID.rand_mode(0);
       //item.ADDR.rand_mode(0);
       //item.DATA.rand_mode(0);
      // item.BURST.rand_mode(0);
      // item.LEN.rand_mode(0);
      // item.SIZE.rand_mode(0);
      // item.STRB.rand_mode(0);
      // item.LOCK.rand_mode(0);
	 /* if(item.LAST==1 && item.LOCK==NORMAL)begin
	    item.RESP = EXOKAY;
      // assert(item.randomize() with {item.RESP==OKAY;});
	  end
	  else if(item.LAST==1 && item.LOCK==EXCLUSIVE)begin
	    item.RESP = OKAY;
       //assert(item.randomize() with {item.RESP==EXOKAY;});
	  end */
      

   	  `uvm_info(get_type_name(),"*******",UVM_LOW)
	   item.print();
   	 finish_item(item); 
	 get_response(item);
     `uvm_info("GET_RSP", $sformatf("After get_response: rsp_b = %0d", item), UVM_LOW);
    end
	 //`uvm_do(req)

   /*  $display("before getting the packet from storage");

     $display("after getting the packet from storage");
	if(item.control == WRITE)begin
	 `uvm_do_with(item,{item.ID==5;item.RESP==0;})
	 end
	 if(item.control == READ)begin
     `uvm_do(item)
	 end 

	//item.DATA = p_sequencer.storage.read();
     item.print();
	`uvm_do(item);*/
        
  endtask
  
endclass

