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
//              Peripheral-NTM for MPSoC                                      //
//              Neural Turing Machine for MPSoC                               //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022-2025 by the author(s)
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

class peripheral_uvm_sequence_item extends uvm_sequence_item;
  // Core 0: Debug Signals
  bit [8*32-1:0] omsp0_i_state;
  bit [8*32-1:0] omsp0_e_state;
  bit [    31:0] omsp0_inst_cycle;
  bit [8*32-1:0] omsp0_inst_full;
  bit [    31:0] omsp0_inst_number;
  bit [    15:0] omsp0_inst_pc;
  bit [8*32-1:0] omsp0_inst_short;

  // Core 1: Debug Signals
  bit [8*32-1:0] omsp1_i_state;
  bit [8*32-1:0] omsp1_e_state;
  bit [    31:0] omsp1_inst_cycle;
  bit [8*32-1:0] omsp1_inst_full;
  bit [    31:0] omsp1_inst_number;
  bit [    15:0] omsp1_inst_pc;
  bit [8*32-1:0] omsp1_inst_short;

  // Constructor
  function new(string name = "peripheral_uvm_sequence_item");
    super.new(name);
  endfunction

  // Utility and Field declarations
  `uvm_object_utils_begin(peripheral_uvm_sequence_item)

  // Core 0: Debug Signals
  `uvm_field_int(omsp0_i_state, UVM_ALL_ON)
  `uvm_field_int(omsp0_e_state, UVM_ALL_ON)
  `uvm_field_int(omsp0_inst_cycle, UVM_ALL_ON)
  `uvm_field_int(omsp0_inst_full, UVM_ALL_ON)
  `uvm_field_int(omsp0_inst_number, UVM_ALL_ON)
  `uvm_field_int(omsp0_inst_pc, UVM_ALL_ON)
  `uvm_field_int(omsp0_inst_short, UVM_ALL_ON)

  // Core 1: Debug Signals
  `uvm_field_int(omsp1_i_state, UVM_ALL_ON)
  `uvm_field_int(omsp1_e_state, UVM_ALL_ON)
  `uvm_field_int(omsp1_inst_cycle, UVM_ALL_ON)
  `uvm_field_int(omsp1_inst_full, UVM_ALL_ON)
  `uvm_field_int(omsp1_inst_number, UVM_ALL_ON)
  `uvm_field_int(omsp1_inst_pc, UVM_ALL_ON)
  `uvm_field_int(omsp1_inst_short, UVM_ALL_ON)

  `uvm_object_utils_end

  // Constraints
endclass
