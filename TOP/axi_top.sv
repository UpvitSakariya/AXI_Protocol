//`include "uvm_pkg.sv"
import uvm_pkg::*;
`include "axi_interface.sv"
`include "uvm_macros.svh"


import axi_pkg::*;

module axi_top;
  
  logic Aclk,Aresetn;
  
  axi_interface intf(Aclk,Aresetn);
  
  initial begin
    uvm_config_db#(virtual axi_interface)::set(null,"*","vif",intf);
  end 
  
  
   initial begin
    Aclk = 1;
    forever #5 Aclk = ~Aclk;
   end
  
   initial begin
    Aresetn = 0;
     repeat(2)@(posedge Aclk);
    Aresetn = 1;
   end 
  

  initial begin
    reset();
    run_test("");
  end  
  
  function void reset();
    //write address channel signals
    intf.AWID = 0;
    intf.AWADDR = 0;
    intf.AWLEN = 0;
    intf.AWSIZE = 0;
    intf.AWBURST = 0;
	intf.AWLOCK = 0;
    intf.AWVALID = 0;
    intf.AWREADY = 0;
    
     // write data channel signals
    intf.WID = 0;
    intf.WDATA = 0;
    intf.WSTRB = 0;
    intf.WLAST = 0;
    intf.WVALID = 0;
    intf.WREADY = 0;
    
    //write response channel signals
    intf.BID = 0;
    intf.BRESP = 0;
    intf.BVALID = 0;
    intf.BREADY = 0;
    
    //read address channel signals
    intf.ARID = 0;
    intf.ARADDR = 0;
    intf.ARLEN = 0;
    intf.ARSIZE = 0;
    intf.ARBURST = 0;
	intf.ARLOCK = 0;
    intf.ARVALID = 0;
    intf.ARREADY = 0;
    
    // read data&response channel signals
    intf.RID = 0;
    intf.RDATA = 0;
    intf.RRESP = 0;
    intf.RLAST = 0;
    intf.RVALID = 0;
    intf.RREADY = 0;
    
  endfunction
  
  
  
endmodule
