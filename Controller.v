module controller (
  input clk,
  input wait_, IR15, AC15, IR14,
  output [21:0] bus_controller
);
  wire [39:0] micro_instructions;
  wire [1:0] muxout;

  reg [3:0] state = 4'b0000;
  reg [3:0] next_state;
  
  reg [21:0] b;
  controllerROM rom(state, micro_instructions);

  always @ (posedge clk) state = next_state;
  // TODO: write codes to implement controller in lecture note, page 59
  always @(*) begin
    case (micro_instructions[39:38])
    2'b00: 
      if (wait_ == 0) begin
        case(AC15)
          1'b0 : next_state[3:0] = micro_instructions[37:34];
          1'b1 : next_state[3:0] = micro_instructions[33:30];
        endcase
      end
      else if (wait_ == 1) begin
        case(AC15)
          1'b0 : next_state[3:0]=micro_instructions[29:26];
          1'b1 : next_state[3:0]=micro_instructions[25:22];
        endcase
      end
    
    2'b11:
     if (IR15 == 0) begin
        case(IR14)
          1'b0 : next_state[3:0]=micro_instructions[37:34];
          1'b1 : next_state[3:0]=micro_instructions[33:30];
        endcase
      end
      else if (IR15 == 1) begin
        case(IR14)
          1'b0 : next_state[3:0]=micro_instructions[29:26];
          1'b1 : next_state[3:0]=micro_instructions[25:22];
        endcase
      end
    endcase 
    
    b = micro_instructions[21:0];
  end
  
  assign bus_controller = micro_instructions[21:0];   
endmodule