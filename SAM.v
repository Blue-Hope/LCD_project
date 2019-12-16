`timescale 1ns/1ps

module SAM();
  reg clk;

// TODO: you may alter the type of registers to wire (e.g. reg RW -> wire RW) if necessary
  reg [15:0] PC;
  reg [15:0] AC, MAR, MBR, IR;
  wire [15:0] ABUS, RBUS, MBUS;
  reg [15:0] ADDRESS_BUS, DATA_BUS;
  reg RW, REQUEST;
  wire WAIT;

  reg [15:0] ALU_A, ALU_B;
  wire ALU_ADD, ALU_PASS_B;
  reg [15:0] ALU_RESULT;

  wire [21:0] b;
  controller my_controller(clk, WAIT, IR[15], AC[15], IR[14], b);

  wire [15:0] data_bus_t;
  always @ ( RW ) if (RW) DATA_BUS = data_bus_t;
  Memory my_memory(ADDRESS_BUS, REQUEST, RW, WAIT, DATA_BUS, data_bus_t);

  // initial settings
  // TODO : add any initialization process if required (not necessary)
  initial begin
    clk = 0;
    AC = 0;
    IR = 0;
    ADDRESS_BUS = 0;
    //RW = 1;
    REQUEST = 1;
    ALU_A = 'bz;
    ALU_B = 'bz;
  end
  always begin
    clk = ~clk; #1;
  end

  // ALU implementation
  always @ (ALU_ADD or ALU_PASS_B or ALU_A or ALU_B )begin
    if (ALU_ADD) ALU_RESULT = ALU_A + ALU_B;
    else if (ALU_PASS_B) ALU_RESULT = ALU_B;
  end

  always @ ( negedge clk ) begin
    // TODO: refer to lecture note, page 46 
    // ->DONE(DAHYUN) CHECK NEEDED
    // Example 1. clk-synchrinized implementation
    if  (b[18]) AC = RBUS;
    if  (b[13]) ADDRESS_BUS = MAR[7:0];
    if  (b[12]) DATA_BUS = MBR;
    if  (b[11]) IR = ABUS;
    if  (b[10]) MAR = ABUS;
    if  (b[8]) MBR = RBUS;
    if  (b[6]) PC = 0;
    if  (b[5]) PC = PC + 2;
    if  (b[4]) PC = ABUS;
    RW = b[3];
    REQUEST = b[2];


  end

/* Example 2. register without clk */
  always @ (b or AC or MBUS or DATA_BUS or RBUS) begin
    if (b[17]) ALU_A = AC;
    if (b[16]) ALU_B = MBUS;
    if (~b[16]) ALU_B = 'bz;
    if (b[9]) MBR = DATA_BUS;
  end

/* Example 3. wire-based */
  assign ABUS = b[21] ? PC : (b[20] ? IR : (b[19] ? MBR : 'bz));
  assign RBUS = b[1] ? AC : (b[0] ? ALU_RESULT : 'bz);
  assign MBUS = b[7] ? MBR : 'bz;
  assign ALU_ADD = b[15];
  assign ALU_PASS_B = b[14];

endmodule