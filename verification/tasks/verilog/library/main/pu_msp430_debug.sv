////////////////////////////////////////////////////////////////////////////////
//                                            __ _      _     _               //
//                                           / _(_)    | |   | |              //
//                __ _ _   _  ___  ___ _ __ | |_ _  ___| | __| |              //
//               / _` | | | |/ _ \/ _ \ '_ \|  _| |/ _ \ |/ _` |              //
//              | (_| | |_| |  __/  __/ | | | | | |  __/ | (_| |              //
//               \__, |\__,_|\___|\___|_| |_|_| |_|\___|_|\__,_|              //
//                  | |                                                       //
//                  |_|                                                       //
//                                                                            //
//                                                                            //
//              MSP430 CPU                                                    //
//              Processing Unit                                               //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2015-2016 by the author(s)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////
// Author(s):
//   Paco Reina Campo <pacoreinacampo@queenfield.tech>

`ifdef OMSP_NO_INCLUDE
`else
`include "pu_msp430_defines.sv"
`endif

module pu_msp430_debug (
  // OUTPUTs
  output reg [8*32-1:0] e_state,      // Execution state
  output reg [8*32-1:0] i_state,      // Instruction fetch state
  output reg [    31:0] inst_cycle,   // Cycle number within current instruction
  output reg [8*32-1:0] inst_full,    // Currently executed instruction (full version)
  output reg [    31:0] inst_number,  // Instruction number since last system reset
  output reg [    15:0] inst_pc,      // Instruction Program counter
  output     [8*32-1:0] inst_short,   // Currently executed instruction (short version)

  // INPUTs
  input core_select  // Core selection
);

  //////////////////////////////////////////////////////////////////////////////
  // 1) ASCII FORMATING FUNCTIONS
  //////////////////////////////////////////////////////////////////////////////

  // This function simply concatenates two strings together, ignorning the NULL
  // at the end of string2.
  // The specified number of space will be inserted between string1 and string2
`ifdef VXL  // no +:
  function [64*8-1:0] myFormat;

    input [32*8-1:0] string1;
    input [32*8-1:0] string2;
    input [3:0] space;

    integer i, j;
    begin
      myFormat = 0;
    end
  endfunction
`else
  function [64*8-1:0] myFormat;

    input [32*8-1:0] string1;
    input [32*8-1:0] string2;
    input [3:0] space;

    integer i, j;
    begin
      myFormat = 0;
      j        = 0;
      for (i = 0; i < 32; i = i + 1) begin  // Copy string2
        myFormat[8*i +: 8] = string2[8*i +: 8];
        if ((string2[8*i +: 8] == 0) && (j == 0)) begin
          j = i;
        end
      end

      for (i = 0; i < space; i = i + 1) begin  // Add spaces
        myFormat[8*(j+i) +: 8] = " ";
      end

      j = j + space;

      for (i = 0; i < 32; i = i + 1) begin  // Copy string1
        myFormat[8*(j+i) +: 8] = string1[8*i +: 8];
      end
    end
  endfunction
`endif

  //////////////////////////////////////////////////////////////////////////////
  // 2) CONNECTIONS TO MSP430 CORE INTERNALS
  //////////////////////////////////////////////////////////////////////////////

  // CPU 0
  wire [ 2:0] omsp0_i_state_bin = pu_msp430_testbench.omsp0_i_state_bin;
  wire [ 3:0] omsp0_e_state_bin = pu_msp430_testbench.omsp0_e_state_bin;

  wire        omsp0_decode = pu_msp430_testbench.omsp0_decode;
  wire [15:0] omsp0_ir = pu_msp430_testbench.omsp0_ir;
  wire        omsp0_irq_detect = pu_msp430_testbench.omsp0_irq_detect;
  wire [ 3:0] omsp0_irq_num = pu_msp430_testbench.omsp0_irq_num;
  wire [15:0] omsp0_pc = pu_msp430_testbench.omsp0_pc;

  wire        omsp0_mclk = pu_msp430_testbench.omsp0_mclk;
  wire        omsp0_puc_rst = pu_msp430_testbench.omsp0_puc_rst;

  // CPU 1
  wire [ 2:0] omsp1_i_state_bin = pu_msp430_testbench.omsp1_i_state_bin;
  wire [ 3:0] omsp1_e_state_bin = pu_msp430_testbench.omsp1_e_state_bin;

  wire        omsp1_decode = pu_msp430_testbench.omsp1_decode;
  wire [15:0] omsp1_ir = pu_msp430_testbench.omsp1_ir;
  wire        omsp1_irq_detect = pu_msp430_testbench.omsp1_irq_detect;
  wire [ 3:0] omsp1_irq_num = pu_msp430_testbench.omsp1_irq_num;
  wire [15:0] omsp1_pc = pu_msp430_testbench.omsp1_pc;

  wire        omsp1_mclk = pu_msp430_testbench.omsp1_mclk;
  wire        omsp1_puc_rst = pu_msp430_testbench.omsp1_puc_rst;

  // CPU Selection
  wire [ 2:0] i_state_bin = core_select ? omsp1_i_state_bin : omsp0_i_state_bin;
  wire [ 3:0] e_state_bin = core_select ? omsp1_e_state_bin : omsp0_e_state_bin;

  wire        decode = core_select ? omsp1_decode : omsp0_decode;
  wire [15:0] ir = core_select ? omsp1_ir : omsp0_ir;
  wire        irq_detect = core_select ? omsp1_irq_detect : omsp0_irq_detect;
  wire [ 3:0] irq_num = core_select ? omsp1_irq_num : omsp0_irq_num;
  wire [15:0] pc = core_select ? omsp1_pc : omsp0_pc;

  wire        mclk = core_select ? omsp1_mclk : omsp0_mclk;
  wire        puc_rst = core_select ? omsp1_puc_rst : omsp0_puc_rst;

  //////////////////////////////////////////////////////////////////////////////
  // 3) GENERATE DEBUG SIGNALS
  //////////////////////////////////////////////////////////////////////////////

  // Instruction fetch state
  always @(i_state_bin) begin
    case (i_state_bin)
      3'h0:    i_state = "IRQ_FETCH";
      3'h1:    i_state = "IRQ_DONE";
      3'h2:    i_state = "DEC";
      3'h3:    i_state = "EXT1";
      3'h4:    i_state = "EXT2";
      3'h5:    i_state = "IDLE";
      default: i_state = "XXXXX";
    endcase
  end

  // Execution state

  always @(e_state_bin) begin
    case (e_state_bin)
      4'h2:    e_state = "IRQ_0";
      4'h1:    e_state = "IRQ_1";
      4'h0:    e_state = "IRQ_2";
      4'h3:    e_state = "IRQ_3";
      4'h4:    e_state = "IRQ_4";
      4'h5:    e_state = "SRC_AD";
      4'h6:    e_state = "SRC_RD";
      4'h7:    e_state = "SRC_WR";
      4'h8:    e_state = "DST_AD";
      4'h9:    e_state = "DST_RD";
      4'hA:    e_state = "DST_WR";
      4'hB:    e_state = "EXEC";
      4'hC:    e_state = "JUMP";
      4'hD:    e_state = "IDLE";
      default: e_state = "xxxx";
    endcase
  end

  // Count instruction number & cycles
  always @(posedge mclk or posedge puc_rst) begin
    if (puc_rst) begin
      inst_number <= 0;
    end else if (decode) begin
      inst_number <= inst_number + 1;
    end
  end

  always @(posedge mclk or posedge puc_rst) begin
    if (puc_rst) begin
      inst_cycle <= 0;
    end else if (decode) begin
      inst_cycle <= 0;
    end else begin
      inst_cycle <= inst_cycle + 1;
    end
  end

  // Decode instruction

  // Buffer opcode
  reg [15:0] opcode;
  always @(posedge mclk or posedge puc_rst) begin
    if (puc_rst) begin
      opcode <= 0;
    end else if (decode) begin
      opcode <= ir;
    end
  end

  // Interrupts
  reg irq;
  always @(posedge mclk or posedge puc_rst) begin
    if (puc_rst) begin
      irq <= 1'b1;
    end else if (decode) begin
      irq <= irq_detect;
    end
  end

  // Instruction type
  reg [8*32-1:0] inst_type;
  always @(opcode or irq) begin
    if (irq) begin
      inst_type = "IRQ";
    end else begin
      case (opcode[15:13])
        3'b000:  inst_type = "SIG-OP";
        3'b001:  inst_type = "JUMP";
        default: inst_type = "TWO-OP";
      endcase
    end
  end

  // Instructions name
  reg [8*32-1:0] inst_name;
  always @(opcode or inst_type or irq_num) begin
    if (inst_type == "IRQ") begin
      case (irq_num[3:0])
        4'b0000: inst_name = "IRQ 0";
        4'b0001: inst_name = "IRQ 1";
        4'b0010: inst_name = "IRQ 2";
        4'b0011: inst_name = "IRQ 3";
        4'b0100: inst_name = "IRQ 4";
        4'b0101: inst_name = "IRQ 5";
        4'b0110: inst_name = "IRQ 6";
        4'b0111: inst_name = "IRQ 7";
        4'b1000: inst_name = "IRQ 8";
        4'b1001: inst_name = "IRQ 9";
        4'b1010: inst_name = "IRQ 10";
        4'b1011: inst_name = "IRQ 11";
        4'b1100: inst_name = "IRQ 12";
        4'b1101: inst_name = "IRQ 13";
        4'b1110: inst_name = "NMI";
        default: inst_name = "RESET";
      endcase
    end else if (inst_type == "SIG-OP") begin
      case (opcode[15:7])
        9'b000100_000: inst_name = "RRC";
        9'b000100_001: inst_name = "SWPB";
        9'b000100_010: inst_name = "RRA";
        9'b000100_011: inst_name = "SXT";
        9'b000100_100: inst_name = "PUSH";
        9'b000100_101: inst_name = "CALL";
        9'b000100_110: inst_name = "RETI";
        default:       inst_name = "xxxx";
      endcase
    end else if (inst_type == "JUMP") begin
      case (opcode[15:10])
        6'b001_000: inst_name = "JNE";
        6'b001_001: inst_name = "JEQ";
        6'b001_010: inst_name = "JNC";
        6'b001_011: inst_name = "JC";
        6'b001_100: inst_name = "JN";
        6'b001_101: inst_name = "JGE";
        6'b001_110: inst_name = "JL";
        6'b001_111: inst_name = "JMP";
        default:    inst_name = "xxxx";
      endcase
    end else if (inst_type == "TWO-OP") begin
      case (opcode[15:12])
        4'b0100: inst_name = "MOV";
        4'b0101: inst_name = "ADD";
        4'b0110: inst_name = "ADDC";
        4'b0111: inst_name = "SUBC";
        4'b1000: inst_name = "SUB";
        4'b1001: inst_name = "CMP";
        4'b1010: inst_name = "DADD";
        4'b1011: inst_name = "BIT";
        4'b1100: inst_name = "BIC";
        4'b1101: inst_name = "BIS";
        4'b1110: inst_name = "XOR";
        4'b1111: inst_name = "AND";
        default: inst_name = "xxxx";
      endcase
    end
  end

  // Instructions byte/word mode
  reg [8*32-1:0] inst_bw;
  always @(opcode or inst_type) begin
    if (inst_type == "IRQ") begin
      inst_bw = "";
    end else if (inst_type == "SIG-OP") begin
      inst_bw = opcode[6] ? ".B" : "";
    end else if (inst_type == "JUMP") begin
      inst_bw = "";
    end else if (inst_type == "TWO-OP") begin
      inst_bw = opcode[6] ? ".B" : "";
    end
  end

  // Source register
  reg  [8*32-1:0] inst_src;
  wire [     3:0] src_reg = (inst_type == "SIG-OP") ? opcode[3:0] : opcode[11:8];

  always @(src_reg or inst_type) begin
    if (inst_type == "IRQ") begin
      inst_src = "";
    end else if (inst_type == "JUMP") begin
      inst_src = "";
    end else if ((inst_type == "SIG-OP") || (inst_type == "TWO-OP")) begin
      case (src_reg)
        4'b0000: inst_src = "r0";
        4'b0001: inst_src = "r1";
        4'b0010: inst_src = "r2";
        4'b0011: inst_src = "r3";
        4'b0100: inst_src = "r4";
        4'b0101: inst_src = "r5";
        4'b0110: inst_src = "r6";
        4'b0111: inst_src = "r7";
        4'b1000: inst_src = "r8";
        4'b1001: inst_src = "r9";
        4'b1010: inst_src = "r10";
        4'b1011: inst_src = "r11";
        4'b1100: inst_src = "r12";
        4'b1101: inst_src = "r13";
        4'b1110: inst_src = "r14";
        default: inst_src = "r15";
      endcase
    end
  end

  // Destination register
  reg [8*32-1:0] inst_dst;

  always @(opcode or inst_type) begin
    if (inst_type == "IRQ") begin
      inst_dst = "";
    end else if (inst_type == "SIG-OP") begin
      inst_dst = "";
    end else if (inst_type == "JUMP") begin
      inst_dst = "";
    end else if (inst_type == "TWO-OP") begin
      case (opcode[3:0])
        4'b0000: inst_dst = "r0";
        4'b0001: inst_dst = "r1";
        4'b0010: inst_dst = "r2";
        4'b0011: inst_dst = "r3";
        4'b0100: inst_dst = "r4";
        4'b0101: inst_dst = "r5";
        4'b0110: inst_dst = "r6";
        4'b0111: inst_dst = "r7";
        4'b1000: inst_dst = "r8";
        4'b1001: inst_dst = "r9";
        4'b1010: inst_dst = "r10";
        4'b1011: inst_dst = "r11";
        4'b1100: inst_dst = "r12";
        4'b1101: inst_dst = "r13";
        4'b1110: inst_dst = "r14";
        default: inst_dst = "r15";
      endcase
    end
  end

  // Source Addressing mode
  reg [8*32-1:0] inst_as;
  always @(inst_type or src_reg or opcode or inst_src) begin
    if (inst_type == "IRQ") begin
      inst_as = "";
    end else if (inst_type == "JUMP") begin
      inst_as = "";
    end else if (src_reg == 4'h3) begin  // Addressing mode using R3
      case (opcode[5:4])
        2'b11:   inst_as = "#-1";
        2'b10:   inst_as = "#2";
        2'b01:   inst_as = "#1";
        default: inst_as = "#0";
      endcase
    end else if (src_reg == 4'h2) begin  // Addressing mode using R2
      case (opcode[5:4])
        2'b11:   inst_as = "#8";
        2'b10:   inst_as = "#4";
        2'b01:   inst_as = "&EDE";
        default: inst_as = inst_src;
      endcase
    end else if (src_reg == 4'h0) begin  // Addressing mode using R0
      case (opcode[5:4])
        2'b11:   inst_as = "#N";
        2'b10:   inst_as = myFormat("@", inst_src, 0);
        2'b01:   inst_as = "EDE";
        default: inst_as = inst_src;
      endcase
    end else begin  // General Addressing mode
      case (opcode[5:4])
        2'b11: begin
          inst_as = myFormat("@", inst_src, 0);
          inst_as = myFormat(inst_as, "+", 0);
        end
        2'b10: begin
          inst_as = myFormat("@", inst_src, 0);
        end
        2'b01: begin
          inst_as = myFormat("x(", inst_src, 0);
          inst_as = myFormat(inst_as, ")", 0);
        end
        default: begin
          inst_as = inst_src;
        end
      endcase
    end
  end

  // Destination Addressing mode
  reg [8*32-1:0] inst_ad;
  always @(opcode or inst_type or inst_dst) begin
    if (inst_type != "TWO-OP") begin
      inst_ad = "";
    end else if (opcode[3:0] == 4'h2) begin  // Addressing mode using R2
      case (opcode[7])
        1'b1:    inst_ad = "&EDE";
        default: inst_ad = inst_dst;
      endcase
    end else if (opcode[3:0] == 4'h0) begin  // Addressing mode using R0
      case (opcode[7])
        2'b1:    inst_ad = "EDE";
        default: inst_ad = inst_dst;
      endcase
    end else begin  // General Addressing mode
      case (opcode[7])
        2'b1: begin
          inst_ad = myFormat("x(", inst_dst, 0);
          inst_ad = myFormat(inst_ad, ")", 0);
        end
        default: begin
          inst_ad = inst_dst;
        end
      endcase
    end
  end

  // Currently executed instruction

  assign inst_short = inst_name;

  always @(inst_type or inst_name or inst_bw or inst_as or inst_ad) begin
    inst_full = myFormat(inst_name, inst_bw, 0);
    inst_full = myFormat(inst_full, inst_as, 1);

    if (inst_type == "TWO-OP") begin
      inst_full = myFormat(inst_full, ",", 0);
    end

    inst_full = myFormat(inst_full, inst_ad, 1);

    if (opcode == 16'h4303) begin
      inst_full = "NOP";
    end

    if (opcode == `DBG_SWBRK_OP) begin
      inst_full = "SBREAK";
    end
  end

  // Instruction program counter

  always @(posedge mclk or posedge puc_rst) begin
    if (puc_rst) begin
      inst_pc <= 16'h0000;
    end else if (decode) begin
      inst_pc <= pc;
    end
  end
endmodule  // pu_msp430_debug
