`include "uvm_macros.svh"

interface axi_interface(input logic Aclk,Aresetn);
  
  // write address channel signals
  logic [3:0]AWID;
  logic [31:0]AWADDR;
  logic [3:0]AWLEN;
  logic [2:0]AWSIZE;
  logic [1:0]AWBURST; 
  logic [1:0]AWLOCK;
  logic AWVALID;
  logic AWREADY;

  // write data channel signals
  logic [3:0]WID;
  logic [31:0]WDATA;
  logic [3:0]WSTRB;
  logic WLAST;
  logic WVALID;
  logic WREADY;
  
  // write response channel signals
  logic [3:0]BID;
  logic [1:0]BRESP;
  logic BVALID;
  logic BREADY;
  
  // read address channel signals
  logic [3:0]ARID;
  logic [31:0]ARADDR;
  logic [3:0]ARLEN;
  logic [2:0]ARSIZE;
  logic [1:0]ARBURST;
  logic [1:0]ARLOCK;
  logic ARVALID;
  logic ARREADY;
  
  // read data&response channel signals
  logic [3:0]RID;
  logic [31:0]RDATA;
  logic [1:0]RRESP;
  logic RLAST;
  logic RVALID;
  logic RREADY;

  clocking mdrv_cb @(posedge Aclk);
   default input #(0) output #(1);
   
   output AWID,AWADDR,AWLEN,AWSIZE,AWBURST,AWLOCK,AWVALID;
   output WID,WDATA,WSTRB,WLAST,WVALID;
   output ARID,ARADDR,ARLEN,ARSIZE,ARBURST,ARLOCK,ARVALID;
   output BREADY,RREADY;

  endclocking
  
  clocking mmon_cb @(posedge Aclk);
   default input #(1) output #(0);

   input AWREADY,WREADY,ARREADY;
   input BID,BRESP,BVALID;
   input RID,RDATA,RRESP,RLAST,RVALID,RREADY;
   input ARID,ARADDR,ARLEN,ARSIZE,ARBURST,ARLOCK,ARVALID;

  endclocking 

  clocking sdrv_cb @(posedge Aclk);
   default input #(0) output #(1);

   output AWREADY,WREADY,ARREADY;
   output BID,BRESP,BVALID;
   output RID,RDATA,RRESP,RLAST,RVALID;

  endclocking
  clocking smon_cb @(posedge Aclk);
   default input #(1) output #(0);

   input AWID,AWADDR,AWLEN,AWSIZE,AWBURST,AWLOCK,AWVALID;
   input WID,WDATA,WSTRB,WLAST,WVALID;
   input ARID,ARADDR,ARLEN,ARSIZE,ARBURST,ARLOCK,ARVALID;
   input AWREADY,WREADY,ARREADY;
   input BREADY,RREADY;

  endclocking


  //assertions on axi features
  //1
  sequence s1_a;

  $rose(AWVALID);

  endsequence

  sequence s1_b;

  $stable(AWID) && $stable(AWADDR) && $stable(AWSIZE) && $stable(AWLEN) && $stable(AWBURST);
 
  endsequence 
 
  property p1;

  @(posedge Aclk) s1_a |-> ##1 s1_b;

  endproperty

  a1:assert property(p1)
  `uvm_info("[assert p1]","property p1 is successfull",UVM_LOW)
  else 
  `uvm_info("[assert p1]","property p1 fails",UVM_LOW) 

  //2
  sequence s2_a;

  $rose(Aresetn);

  endsequence

  sequence s2_b;

  $rose(AWVALID);

  endsequence

  property p2;

  @(posedge Aclk) s2_a |-> ##1 s2_b;

  endproperty

  a2:assert property(p2)
  `uvm_info("[assert p2]","property p2 is successfull",UVM_LOW)
  else 
  `uvm_info("[assert p2]","property p2 fails",UVM_LOW)

  //3
  sequence s3_a;

  $rose(AWVALID);

  endsequence

  sequence s3_b;

  $isunknown(AWID) && $isunknown(AWADDR) && $isunknown(AWLEN) && $isunknown(AWSIZE) && $isunknown(AWBURST);

  endsequence

  property p3;

  @(posedge Aclk) s3_a |-> not s3_b;

  endproperty

  a3:assert property(p3)
  `uvm_info("[assert p3]","property p3 is successfull",UVM_LOW)
  else 
  `uvm_info("[assert p3]","property p3 fails",UVM_LOW)

  //4
  sequence s4_a;
   
  $rose(AWVALID);
   
  endsequence

  sequence s4_b;

  (AWBURST==3);

  endsequence

  property p4;

  @(posedge Aclk) s4_a |-> not s4_b;
  
  endproperty

  a4:assert property(p4)
  `uvm_info("[assert p4]","property p4 is successfull",UVM_LOW)
  else 
  `uvm_info("[assert p4]","property p4 fails",UVM_LOW)

  //5
  sequence s5_a;

  $rose(AWVALID);

  endsequence

  sequence s5_b;

  (AWBURST%2==0);

  endsequence

  property p5;

  @(posedge Aclk) s5_a |-> s5_b;

  endproperty

  a5:assert property(p5)
  `uvm_info("[assert p5]","property p5 is successfull",UVM_LOW)
  else 
  `uvm_info("[assert p5]","property p5 fails",UVM_LOW)

  //6
  sequence s6_a;

  $rose(WVALID);

  endsequence

  sequence s6_b;

  $stable(WID) && $stable(WDATA) && $stable(WSTRB) && $stable(WLAST);

  endsequence

  property p6;

  @(posedge Aclk) s6_a |-> ##1 s6_b;

  endproperty

  a6:assert property(p6)
  `uvm_info("[assert p6]","property p6 is successfull",UVM_LOW)
  else 
  `uvm_info("[assert p6]","property p6 fails",UVM_LOW)

  //7
  sequence s7_a;

  $rose(Aresetn);

  endsequence

  sequence s7_b;

  $rose(WVALID);

  endsequence

  property p7;

  @(posedge Aclk) s7_a |-> ##1 s7_b;

  endproperty

  a7:assert property(p7)
  `uvm_info("[assert p7]","property p7 is successfull",UVM_LOW)
  else 
  `uvm_info("[assert p7]","property p7 fails",UVM_LOW)

  //8
  sequence s8_a;

  $rose(WVALID);

  endsequence

  sequence s8_b;

  $isunknown(WID) && $isunknown(WDATA) && $isunknown(WSTRB) && $isunknown(WLAST);

  endsequence

  property p8;

  @(posedge Aclk) s8_a |-> not s8_b;

  endproperty

  a8:assert property(p8)
  `uvm_info("[assert p8]","property p8 is successfull",UVM_LOW)
  else 
  `uvm_info("[assert p8]","property p8 fails",UVM_LOW)

  //9
  sequence s9_a;

  $rose(BVALID);

  endsequence

  sequence s9_b;

  $stable(BID) && $stable(BRESP);

  endsequence

  property p9;

  @(posedge Aclk) s9_a |-> ##1 s9_b;

  endproperty

  a9:assert property(p9)
  `uvm_info("[assert p9]","property p9 is successfull",UVM_LOW)
  else 
  `uvm_info("[assert p9]","property p9 fails",UVM_LOW)

  //10
sequence s10_a;

  $rose(Aresetn);

  endsequence

  sequence s10_b;

  $rose(BVALID);

  endsequence

  property p10;

  @(posedge Aclk) s10_a |-> ##1 s10_b;

  endproperty

  a10:assert property(p10)
  `uvm_info("[assert p10]","property p10 is successfull",UVM_LOW)
  else 
  `uvm_info("[assert p10]","property p10 fails",UVM_LOW)

  //11
  sequence s11_a;

  $rose(BVALID);

  endsequence

  sequence s11_b;

  $isunknown(BID) && $isunknown(BRESP);

  endsequence

  property p11;

  @(posedge Aclk) s11_a |-> not s11_b;

  endproperty

  a11:assert property(p11)
  `uvm_info("[assert p11]","property p11 is successfull",UVM_LOW)
  else 
  `uvm_info("[assert p11]","property p11 fails",UVM_LOW)

  //12
  sequence s12_a;

  $rose(ARVALID);

  endsequence

  sequence s12_b;

  $stable(ARID) && $stable(ARADDR) && $stable(ARSIZE) && $stable(ARLEN) && $stable(ARBURST);
 
  endsequence 
 
  property p12;

  @(posedge Aclk) s12_a |-> ##1 s12_b;

  endproperty

  a12:assert property(p12)
  `uvm_info("[assert p12]","property p12 is successfull",UVM_LOW)
  else 
  `uvm_info("[assert p12]","property p12 fails",UVM_LOW) 

  //13
  sequence s13_a;

  $rose(Aresetn);

  endsequence

  sequence s13_b;

  $rose(ARVALID);

  endsequence

  property p13;

  @(posedge Aclk) s13_a |-> ##1 s13_b;

  endproperty

  a13:assert property(p13)
  `uvm_info("[assert p13]","property p13 is successfull",UVM_LOW)
  else 
  `uvm_info("[assert p13]","property p13 fails",UVM_LOW)

  //14
  sequence s14_a;

  $rose(ARVALID);

  endsequence

  sequence s14_b;

  $isunknown(ARID) && $isunknown(ARADDR) && $isunknown(ARLEN) && $isunknown(ARSIZE) && $isunknown(ARBURST);

  endsequence

  property p14;

  @(posedge Aclk) s14_a |-> not s14_b;

  endproperty

  a14:assert property(p14)
  `uvm_info("[assert p14]","property p14 is successfull",UVM_LOW)
  else 
  `uvm_info("[assert p14]","property p14 fails",UVM_LOW)

  //15
  sequence s15_a;
   
  $rose(ARVALID);
   
  endsequence

  sequence s15_b;

  (ARBURST==3);

  endsequence

  property p15;

  @(posedge Aclk) s15_a |-> not s15_b;
  
  endproperty

  a15:assert property(p15)
  `uvm_info("[assert p15]","property p15 is successfull",UVM_LOW)
  else 
  `uvm_info("[assert p15]","property p15 fails",UVM_LOW)

  //16
  sequence s16_a;

  $rose(ARVALID);

  endsequence

  sequence s16_b;

  (ARBURST%2==0);

  endsequence

  property p16;

  @(posedge Aclk) s16_a |-> s16_b;

  endproperty

  a16:assert property(p16)
  `uvm_info("[assert p16]","property p16 is successfull",UVM_LOW)
  else 
  `uvm_info("[assert p16]","property p16 fails",UVM_LOW)

   //17
  sequence s17_a;

  $rose(RVALID);

  endsequence

  sequence s17_b;

  $stable(RID) && $stable(RDATA) && $stable(RRESP) && $stable(RLAST);

  endsequence

  property p17;

  @(posedge Aclk) s17_a |-> ##1 s17_b;

  endproperty

  a17:assert property(p17)
  `uvm_info("[assert p17]","property p17 is successfull",UVM_LOW)
  else 
  `uvm_info("[assert p17]","property p17 fails",UVM_LOW)

  //18
sequence s18_a;

  $rose(Aresetn);

  endsequence

  sequence s18_b;

  $rose(RVALID);

  endsequence

  property p18;

  @(posedge Aclk) s18_a |-> ##1 s18_b;

  endproperty

  a18:assert property(p18)
  `uvm_info("[assert p18]","property p18 is successfull",UVM_LOW)
  else 
  `uvm_info("[assert p18]","property p18 fails",UVM_LOW)

  //19
  sequence s19_a;

  $rose(RVALID);

  endsequence

  sequence s19_b;

  $isunknown(RID) && $isunknown(RDATA) && $isunknown(RRESP) && $isunknown(RLAST);

  endsequence

  property p19;

  @(posedge Aclk) s19_a |-> not s19_b;

  endproperty

  a19:assert property(p19)
  `uvm_info("[assert p19]","property p19 is successfull",UVM_LOW)
  else 
  `uvm_info("[assert p19]","property p19 fails",UVM_LOW)






endinterface



