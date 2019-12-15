`timescale 1ns/1ps

module SAM();
  reg clk;

// TODO: you may alter the type of registers to wire (e.g. reg RW -> wire RW) if necessary
  reg [15:0] PC;
  reg [15:0] AC, MAR, MBR, IR;
  reg [15:0] ABUS, RBUS, MBUS;
  reg [15:0] ADDRESS_BUS, DATA_BUS;
  reg RW, REQUEST;
  wire WAIT;

  reg [15:0] ALU_A, ALU_B;
  reg ALU_ADD, ALU_PASS_B;
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
  end
  always begin
    #1 clk = ~clk;
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
    if		(b[21]) ABUS = PC;
    if		(b[20]) ABUS = IR;
    if		(b[19]) ABUS = MBR;
    if  (b[18]) AC = RBUS;
    if  (b[17]) ALU_A = AC;
    if  (b[16]) ALU_B = MBUS;
    ALU_ADD = b[15];
    ALU_PASS_B = b[14];
    if  (b[13]) ADDRESS_BUS = MAR;
    if  (b[12]) DATA_BUS = MBR;
    if  (b[11]) IR = ABUS;
    if  (b[10]) MAR = ABUS;
    if  (b[9]) MBR = DATA_BUS;
    if  (b[8]) MBR = RBUS;
    if  (b[7]) MBUS = MBR;
    if  (b[6]) PC = 0;
    if  (b[5]) PC = PC + 2;
    if  (b[4]) PC = ABUS;
    RW = b[3];
    REQUEST = b[2];
    if  (b[1]) RBUS = AC;
    if  (b[0]) RBUS = ALU_RESULT;


  end

/* Example 2. register without clk
  always @ (b or PC or IR or MBR) begin
    if (b[21]) ABUS = PC;
    if (b[20]) ABUS = IR;
    if (b[19]) ABUS = MBR;
  end
*/

/* Example 3. wire-based
  assign ABUS = b[21] ? PC : (b[20] ? IR : (b[19] ? MBR : 'bz));
  Note that you need to change ABUS's type as wire in this case (wire ABUS)
*/
endmodule