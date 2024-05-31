
//typedef enum bit [1:0]{INTERLEAVING_DEPTH,OUT_OF_ORDER,OUTSTANDING}trans_type;
//typedef enum bit [1:0]{INTERLEAVE_FLAG,OUT_OF_ORDER_FLAG,OUTSTANDING_FLAG}trans_flag;
typedef enum bit {WRITE,READ}t_signal;
typedef enum bit [2:0]{BYTE1=0,BYTE2,BYTE4,BYTE8,BYTE16,BYTE32,BYTE64,BYTE128}burst_size;
typedef enum bit [3:0]{TRANSFER1=0,TRANSFER2,TRANSFER3,TRANSFER4,TRANSFER5,TRANSFER6,TRANSFER7,TRANSFER8,TRANSFER9,TRANSFER10,TRANSFER11,TRANSFER12,TRANSFER13,TRANSFER14,TRANSFER15}burst_len;
typedef enum bit [1:0]{FIXED,INCR,WRAP,RESERVED}burst_type;
typedef enum bit [1:0]{OKAY,EXOKAY,SLVERR,DECRR}resp_type;
typedef enum bit [1:0]{NORMAL,EXCLUSIVE,LOCKED,RESERVED_LOCK}lock_type;

class axi_transaction extends uvm_sequence_item;
  
  // write address channel signals
  randc bit [3:0]ID;
  rand bit [`DATA_WIDTH-1:0]ADDR;
  rand burst_len LEN;
  rand burst_size SIZE;
  rand burst_type BURST;
  rand bit [`DATA_WIDTH-1:0]DATA[$];
  rand bit [(`DATA_WIDTH/8)-1:0]STRB[$];
  bit LAST;
  rand resp_type RESP;
  rand lock_type LOCK;

  // read address channel signals
  rand bit [3:0]RID;
  rand bit [`DATA_WIDTH-1:0]RADDR;
  rand burst_len RLEN;
  rand burst_size RSIZE;
  rand burst_type RBURST;
  rand bit [`DATA_WIDTH-1:0]RDATA[$];
  bit RLAST;
  resp_type RRESP;
  //lock_type RLOCK;


  // other required signals
  bit [3:0]unique_id[$];
  //trans_type TRANSACTION_TYPE;
  randc t_signal CONTROL;
  //rand bit [3:0]id_queue[16];

  // burst type wrap calculation
 /* rand bit [31:0]START_ADDR;
  rand bit [31:0]ALIGNED_ADDR;
  rand bit [7:0]TOTAL_SIZE;
  rand bit [3:0]REMAINDER;
  rand bit [31:0]LOWER_WRAP;
  rand bit [31:0]UPPER_WRAP; */

  static mailbox#(axi_transaction) mem2seq = new();

  //constraint cn{soft ADDR%(2**SIZE)==0;}
 // constraint uniqu_id{foreach(unique_id[i])unique_id[i]!=ID;}
  //constraint cnt{soft ID!=0;unique {ID};}
  constraint id{soft ID!=0;}
  constraint axi_4kb{soft ADDR%4096 + (2**SIZE*(LEN+1)) <= ADDR%4096;}
  constraint data{soft DATA.size==LEN+1;}
  constraint strb{soft STRB.size==LEN+1;}
  //constraint control{(CONTROL==0)->(CONTROL==1);}
  constraint strb_cnt{if(SIZE==2){
                       foreach(STRB[i])
                       $countones(STRB[i])==2**SIZE; 
					   }
					   else if(SIZE==1){
					   foreach(STRB[i])
					   $countones(STRB[i])==2**SIZE;
					   }
					   else if(SIZE==0){
					   foreach(STRB[i])
					   $countones(STRB[i])==2**SIZE;
					   }
					 } 



 /* function void post_randomize();
    unique_id.push_back(ID);
    $display("++++++++++++++++++++++unique_id size::q=%0p",unique_id);
  endfunction */
  //constraint aligned_addr{solve SIZE before ADDR;if(BURST==WRAP) ADDR==(int'(ADDR/2**SIZE))*2**SIZE;}
  //constraint unaligned_addr{solve SIZE before ADDR;if(BURST!=WRAP) ADDR!=(int'(ADDR/2**SIZE))*2**SIZE;}

 /* constraint wrap_addr{ALIGNED_ADDR==ADDR*(2**SIZE);solve SIZE before ADDR;}
  constraint wrap_start_addr{START_ADDR==ALIGNED_ADDR;}
  constraint wrap_size{TOTAL_SIZE==LEN*(2**SIZE);solve SIZE before LEN;}
  constraint wrap_rem{REMAINDER==START_ADDR%TOTAL_SIZE;solve TOTAL_SIZE before START_ADDR;}
  constraint wrap_lower_boundary{LOWER_WRAP==START_ADDR-REMAINDER;solve REMAINDER before START_ADDR;}
  constraint wrap_upper_boundary{UPPER_WRAP==LOWER_WRAP+TOTAL_SIZE;solve TOTAL_SIZE before LOWER_WRAP;} */



 // constraint unique_values{foreach(id_queue[i]) ID!=id_queue[i];}
  
  function new(string name = "axi_transaction");
    super.new(name);
    `uvm_info(get_type_name(),"inside constructor",UVM_LOW)
    `uvm_info(get_type_name(),$sformatf("DATA=%0p,LEN=%0d,ID=%0d,SIZE=%0d",DATA,LEN,ID,SIZE),UVM_LOW)
  endfunction

  function void post_randomize();
    unique_id.push_back(ID);
    $display("++++++++++++++++++++++unique_id size::q=%0p",unique_id);
  endfunction 

  // register all signals into
  `uvm_object_utils_begin(axi_transaction)
   `uvm_field_int(ID,UVM_ALL_ON)
   `uvm_field_int(ADDR,UVM_ALL_ON)
   `uvm_field_enum(burst_len,LEN,UVM_ALL_ON)
   `uvm_field_enum(burst_size,SIZE,UVM_ALL_ON)
   `uvm_field_enum(burst_type,BURST,UVM_ALL_ON)
   `uvm_field_queue_int(DATA,UVM_ALL_ON)
   `uvm_field_queue_int(STRB,UVM_ALL_ON)
   `uvm_field_int(LAST,UVM_ALL_ON)
   `uvm_field_enum(resp_type,RESP,UVM_ALL_ON)
   `uvm_field_enum(lock_type,LOCK,UVM_ALL_ON)
   `uvm_field_enum(t_signal,CONTROL,UVM_ALL_ON)
   //`uvm_field_int(START_ADDR,UVM_ALL_ON)
   //`uvm_field_int(ALIGNED_ADDR,UVM_ALL_ON)
   //`uvm_field_int(TOTAL_SIZE,UVM_ALL_ON)
   //`uvm_field_int(REMAINDER,UVM_ALL_ON)
   //`uvm_field_int(LOWER_WRAP,UVM_ALL_ON)
   //`uvm_field_int(UPPER_WRAP,UVM_ALL_ON)
  `uvm_object_utils_end
  
  
  
endclass
