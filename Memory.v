`timescale 1ns/1ps

// Memory module, you don't need to change any code here
// refer to : lecture note - page 15
module Memory(
  input [15:0] addrs_bus,
  input request,
  input rw, // 1:read, 0:write
  output reg wait_,
  input [15:0] data_bus_write,
  output [15:0] data_bus_read
);
  reg [7:0] mem[0:255];

  integer i;
  initial begin
    /* In this sample testcode, you are expected to have
         
          mem[132] = 8'hab;
          mem[133] = 8'hce;
       at 61ns time.
    */
    wait_ = 1;
    for  (i=0;i!=256;i=i+1) mem[i] = 0; // initialize all instructions as 0
    mem[0] = 8'b00000000; //LD 14'b [00 0000] 1000 0000
    mem[1] = 8'b10000000; //LD 14'b 00 0000 [1000 0000]
    mem[2] = 8'b10000000; //ADD 14'b [00 0000] 1000 0010
    mem[3] = 8'b10000010; //ADD 14'b 00 0000 [1000 0010]
    mem[4] = 8'b11000000; //BRN 14'b [00 0000] 0000 1000
    mem[5] = 8'b00001000; //BRN 14'b 00 0000 [0000 1000]
    mem[8] = 8'b01000000; //ST 14'b [00 0000] 1000 0100
    mem[9] = 8'b10000100; //ST 14'b 00 0000 [1000 0100]
    mem[8'b10000000] = 8'hab;
    mem[8'b10000001] = 8'hcd;
    mem[8'b10000010] = 8'h00;
    mem[8'b10000011] = 8'h01;
    mem[8'b10000100] = 8'h00;
    mem[8'b10000101] = 8'h00;
  end

  assign data_bus_read[15:8] = (rw) ? mem[addrs_bus[7:0]] : 'bz;
  assign data_bus_read[7:0] = (rw) ? mem[addrs_bus[7:0]+1] : 'bz;

  always @ ( request or rw or data_bus_write ) begin
    if ( request ) begin
      if ( ~rw ) begin
        mem[addrs_bus] = data_bus_write[15:8];
        mem[addrs_bus+1] = data_bus_write[7:0];
      end
      wait_ = 0;
    end
    else wait_ = 1;
  end
endmodule