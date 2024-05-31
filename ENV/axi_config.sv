typedef enum bit [1:0]{OUTSTANDING,OUT_OF_ORDER,INTERLEAVING_DEPTH,NORMALY}features;
//typedef bit [1:0]{outstanding_flag,out_of_order_flag,interleaving_flag}flag;
 
class axi_config extends uvm_object;

`uvm_object_utils(axi_config)

 //properties
 static int outstanding=0;
 static int out_of_order=3;
 static int interleaving_depth=0;
 static int Flag=0;
 static int cnt=0;
 static int interleave_flag=0;
 static int outstanding_flag=0;
 static int out_of_order_flag=0;
 static int Number_of_transaction = 5;
 static int Number_of_Read_transaction = 5;
 static features FEATURES=OUT_OF_ORDER;

 function new(string name = "axi_config");
  super.new(name);
  `uvm_info(get_type_name(),"inside constructor",UVM_LOW)
 endfunction
 
endclass
