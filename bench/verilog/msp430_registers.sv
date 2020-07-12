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

/* Copyright (c) 2015-2016 by the author(s)
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the authors nor the names of its contributors
 *       may be used to endorse or promote products derived from this software
 *       without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
 * OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE
 *
 * =============================================================================
 * Author(s):
 *   Olivier Girard <olgirard@gmail.com>
 *   Paco Reina Campo <pacoreinacampo@queenfield.tech>
 */

// RAM cells
//======================

wire       [15:0] mem200 = dmem_0.mem[0];
wire       [15:0] mem202 = dmem_0.mem[1];
wire       [15:0] mem204 = dmem_0.mem[2];
wire       [15:0] mem206 = dmem_0.mem[3];
wire       [15:0] mem208 = dmem_0.mem[4];
wire       [15:0] mem20A = dmem_0.mem[5];
wire       [15:0] mem20C = dmem_0.mem[6];
wire       [15:0] mem20E = dmem_0.mem[7];
wire       [15:0] mem210 = dmem_0.mem[8];
wire       [15:0] mem212 = dmem_0.mem[9];
wire       [15:0] mem214 = dmem_0.mem[10];
wire       [15:0] mem216 = dmem_0.mem[11];
wire       [15:0] mem218 = dmem_0.mem[12];
wire       [15:0] mem21A = dmem_0.mem[13];
wire       [15:0] mem21C = dmem_0.mem[14];
wire       [15:0] mem21E = dmem_0.mem[15];
wire       [15:0] mem220 = dmem_0.mem[16];
wire       [15:0] mem222 = dmem_0.mem[17];
wire       [15:0] mem224 = dmem_0.mem[18];
wire       [15:0] mem226 = dmem_0.mem[19];
wire       [15:0] mem228 = dmem_0.mem[20];
wire       [15:0] mem22A = dmem_0.mem[21];
wire       [15:0] mem22C = dmem_0.mem[22];
wire       [15:0] mem22E = dmem_0.mem[23];
wire       [15:0] mem230 = dmem_0.mem[24];
wire       [15:0] mem232 = dmem_0.mem[25];
wire       [15:0] mem234 = dmem_0.mem[26];
wire       [15:0] mem236 = dmem_0.mem[27];
wire       [15:0] mem238 = dmem_0.mem[28];
wire       [15:0] mem23A = dmem_0.mem[29];
wire       [15:0] mem23C = dmem_0.mem[30];
wire       [15:0] mem23E = dmem_0.mem[31];
wire       [15:0] mem240 = dmem_0.mem[32];
wire       [15:0] mem242 = dmem_0.mem[33];
wire       [15:0] mem244 = dmem_0.mem[34];
wire       [15:0] mem246 = dmem_0.mem[35];
wire       [15:0] mem248 = dmem_0.mem[36];
wire       [15:0] mem24A = dmem_0.mem[37];
wire       [15:0] mem24C = dmem_0.mem[38];
wire       [15:0] mem24E = dmem_0.mem[39];
wire       [15:0] mem250 = dmem_0.mem[40];
wire       [15:0] mem252 = dmem_0.mem[41];
wire       [15:0] mem254 = dmem_0.mem[42];
wire       [15:0] mem256 = dmem_0.mem[43];
wire       [15:0] mem258 = dmem_0.mem[44];
wire       [15:0] mem25A = dmem_0.mem[45];
wire       [15:0] mem25C = dmem_0.mem[46];
wire       [15:0] mem25E = dmem_0.mem[47];
wire       [15:0] mem260 = dmem_0.mem[48];
wire       [15:0] mem262 = dmem_0.mem[49];
wire       [15:0] mem264 = dmem_0.mem[50];
wire       [15:0] mem266 = dmem_0.mem[51];
wire       [15:0] mem268 = dmem_0.mem[52];
wire       [15:0] mem26A = dmem_0.mem[53];
wire       [15:0] mem26C = dmem_0.mem[54];
wire       [15:0] mem26E = dmem_0.mem[55];
wire       [15:0] mem270 = dmem_0.mem[56];
wire       [15:0] mem272 = dmem_0.mem[57];
wire       [15:0] mem274 = dmem_0.mem[58];
wire       [15:0] mem276 = dmem_0.mem[59];
wire       [15:0] mem278 = dmem_0.mem[60];
wire       [15:0] mem27A = dmem_0.mem[61];
wire       [15:0] mem27C = dmem_0.mem[62];
wire       [15:0] mem27E = dmem_0.mem[63];

// Interrupt vectors
//======================

wire       [15:0] irq_vect_15 = pmem_0.mem[(`PMEM_SIZE>>1)-1];  // RESET Vector
wire       [15:0] irq_vect_14 = pmem_0.mem[(`PMEM_SIZE>>1)-2];  // NMI
wire       [15:0] irq_vect_13 = pmem_0.mem[(`PMEM_SIZE>>1)-3];  // IRQ 13
wire       [15:0] irq_vect_12 = pmem_0.mem[(`PMEM_SIZE>>1)-4];  // IRQ 12
wire       [15:0] irq_vect_11 = pmem_0.mem[(`PMEM_SIZE>>1)-5];  // IRQ 11
wire       [15:0] irq_vect_10 = pmem_0.mem[(`PMEM_SIZE>>1)-6];  // IRQ 10
wire       [15:0] irq_vect_09 = pmem_0.mem[(`PMEM_SIZE>>1)-7];  // IRQ  9
wire       [15:0] irq_vect_08 = pmem_0.mem[(`PMEM_SIZE>>1)-8];  // IRQ  8
wire       [15:0] irq_vect_07 = pmem_0.mem[(`PMEM_SIZE>>1)-9];  // IRQ  7
wire       [15:0] irq_vect_06 = pmem_0.mem[(`PMEM_SIZE>>1)-10]; // IRQ  6
wire       [15:0] irq_vect_05 = pmem_0.mem[(`PMEM_SIZE>>1)-11]; // IRQ  5
wire       [15:0] irq_vect_04 = pmem_0.mem[(`PMEM_SIZE>>1)-12]; // IRQ  4
wire       [15:0] irq_vect_03 = pmem_0.mem[(`PMEM_SIZE>>1)-13]; // IRQ  3
wire       [15:0] irq_vect_02 = pmem_0.mem[(`PMEM_SIZE>>1)-14]; // IRQ  2
wire       [15:0] irq_vect_01 = pmem_0.mem[(`PMEM_SIZE>>1)-15]; // IRQ  1
wire       [15:0] irq_vect_00 = pmem_0.mem[(`PMEM_SIZE>>1)-16]; // IRQ  0

// CPU ID
//======================

wire  [2:0] dbg_cpu_version  =  `CPU_VERSION;
`ifdef ASIC
wire        dbg_cpu_asic     =  1'b1;
`else
wire        dbg_cpu_asic     =  1'b0;
`endif
wire  [4:0] dbg_user_version =  `USER_VERSION;
wire  [6:0] dbg_per_space    = (`PER_SIZE  >> 9);
`ifdef MULTIPLIER
wire        dbg_mpy_info     =  1'b1;
`else
wire        dbg_mpy_info     =  1'b0;
`endif
wire  [8:0] dbg_dmem_size    = (`DMEM_SIZE >> 7);
wire  [5:0] dbg_pmem_size    = (`PMEM_SIZE >> 10);

wire [31:0] dbg_cpu_id       = {dbg_pmem_size,
                                dbg_dmem_size,
                                dbg_mpy_info,
                                dbg_per_space,
                                dbg_user_version,
                                dbg_cpu_asic,
                                dbg_cpu_version};
