
//typedef enum bit [1:0]{FIXED,INCR,WRAP,RESERVED}burst_signals;

class axi_coverage extends uvm_subscriber#(axi_transaction);

 `uvm_component_utils(axi_coverage)

 bit [3:0]id;
 bit [31:0]addr;
 bit [31:0]data;
 bit [3:0]len;
 bit [2:0]size;
 bit [1:0]burst;
 bit [3:0]strobe;
 bit [1:0]resp;
 bit last;

 covergroup cgp;

    c1:coverpoint id{
	    bins id0[] = {[0:15]};
	}

    c2:coverpoint addr{
	    bins addr0[] = {[0:1501]};
		bins addr1[] = {[1501:3500]};
		bins addr2[] = {[3501:4095]};
       }


	c4:coverpoint len{   
        bins len[] = {[0:15]};
       }

	c5:coverpoint size{
        bins size[] = {[0:7]};
	   }

	c6:coverpoint burst{
        bins burst[] = {[0:2]};
		ignore_bins burst0 = {3};
	   }

	c7:coverpoint strobe{
       bins strobe[] = {[0:15]};
	}

	c8:coverpoint resp{
       bins resp[] ={[0:2]};
	   ignore_bins resp0 = {3};
	}

	c9:coverpoint last{
       bins last = (0 => 1);
	}

 endgroup

 covergroup cgp1 with function sample(int a);

   c7:coverpoint addr{
        bins add0 = (0 => 1);
		bins add1 = (1 => 0);
   }

 endgroup

 function new(string name="axi_coverage",uvm_component parent); 
  super.new(name,parent);
  `uvm_info(get_type_name(),"inside constructor",UVM_LOW)
  cgp = new;
  cgp1 = new;
 endfunction

 function void write(axi_transaction t);
   `uvm_info(get_type_name(),$sformatf("Subscriber received pkt=%0p",t), UVM_NONE);
    $display("coverage=",cgp.get_coverage());
  
   id = t.ID; 
   addr = t.ADDR;
   //data = t.DATA;
   //strobe = t.STRB;
   len = t.LEN;
   size = t.SIZE;
   burst = t.BURST;
   resp = t.RESP;
   last = t.LAST;
   cgp.sample();
   for(int i=0;i<=32;i++)cgp1.sample(addr[i]);
   
 endfunction


 endclass

