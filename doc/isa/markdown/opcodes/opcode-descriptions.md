## INSTRUCTION DESCRIPTIONS

Instructions in RISC-V are designed to perform specific operations ranging from basic arithmetic and logical computations to memory access and control flow. Each instruction description outlines its functionality, including operands (registers or immediates), effects on status flags, memory access patterns, and control flow implications. Descriptions provide a clear understanding of how instructions interact with processor state and contribute to program execution.

Format of a line in the table:

`<instruction name> "<instruction description>"`

| instruction name | instruction description                                                                                                          |
|------------------|:---------------------------------------------------------------------------------------------------------------------------------|
| `lui`            | `Set and sign extend the 20-bit immediate (shited 12 bits left) and zero the bottom 12 bits into rd`                             |
| `auipc`          | `Place the PC plus the 20-bit signed immediate (shited 12 bits left) into rd (used before JALR)`                                 |
| `jal`            | `Jump to the PC plus 20-bit signed immediate while saving PC+4 into rd`                                                          |
| `jalr`           | `Jump to rs1 plus the 12-bit signed immediate while saving PC+4 into rd`                                                         |
| `beq`            | `Branch to PC relative 12-bit signed immediate (shifted 1 bit left) if rs1 == rs2`                                               |
| `bne`            | `Branch to PC relative 12-bit signed immediate (shifted 1 bit left) if rs1 != rs2`                                               |
| `blt`            | `Branch to PC relative 12-bit signed immediate (shifted 1 bit left) if rs1 < rs2 (signed)`                                       |
| `bge`            | `Branch to PC relative 12-bit signed immediate (shifted 1 bit left) if rs1 >= rs2 (signed)`                                      |
| `bltu`           | `Branch to PC relative 12-bit signed immediate (shifted 1 bit left) if rs1 < rs2 (unsigned)`                                     |
| `bgeu`           | `Branch to PC relative 12-bit signed immediate (shifted 1 bit left) if rs1 >= rs2 (unsigned)`                                    |
| `lb`             | `Load 8-bit value from addr in rs1 plus the 12-bit signed immediate and place sign-extended result into rd`                      |
| `lh`             | `Load 16-bit value from addr in rs1 plus the 12-bit signed immediate and place sign-extended result into rd`                     |
| `lw`             | `Load 32-bit value from addr in rs1 plus the 12-bit signed immediate and place sign-extended result into rd`                     |
| `lbu`            | `Load 8-bit value from addr in rs1 plus the 12-bit signed immediate and place zero-extended result into rd`                      |
| `lhu`            | `Load 32-bit value from addr in rs1 plus the 12-bit signed immediate and place zero-extended result into rd`                     |
| `lwu`            | `Load 32-bit value from addr in rs1 plus the 12-bit signed immediate and place zero-extended result into rd`                     |
| `sb`             | `Store 8-bit value from the low bits of rs2 to addr in rs1 plus the 12-bit signed immediate`                                     |
| `sh`             | `Store 16-bit value from the low bits of rs2 to addr in rs1 plus the 12-bit signed immediate`                                    |
| `sw`             | `Store 32-bit value from the low bits of rs2 to addr in rs1 plus the 12-bit signed immediate`                                    |
| `addi`           | `Add sign-extended 12-bit immediate to register rs1 and place the result in rd`                                                  |
| `slti`           | `Set rd to 1 if rs1 is less than the sign-extended 12-bit immediate, otherwise set rd to 0 (signed)`                             |
| `sltiu`          | `Set rd to 1 if rs1 is less than the sign-extended 12-bit immediate, otherwise set rd to 0 (unsigned)`                           |
| `xori`           | `Set rd to the bitwise xor of rs1 with the sign-extended 12-bit immediate`                                                       |
| `ori`            | `Set rd to the bitwise or of rs1 with the sign-extended 12-bit immediate`                                                        |
| `andi`           | `Set rd to the bitwise and of rs1 with the sign-extended 12-bit immediate`                                                       |
| `slli`           | `Shift rs1 left by the 5 or 6 (RV32/64) bit (RV64) immediate and place the result into rd`                                       |
| `srli`           | `Shift rs1 right by the 5 or 6 (RV32/64) bit immediate and place the result into rd`                                             |
| `srai`           | `Shift rs1 right by the 5 or 6 (RV32/64) bit immediate and place the result into rd while retaining the sign`                    |
| `add`            | `Add rs2 to rs1 and place the result into rd`                                                                                    |
| `sub`            | `Subtract rs2 from rs1 and place the result into rd`                                                                             |
| `sll`            | `Shift rs1 left by the by the lower 5 or 6 (RV32/64) bits in rs2 and place the result into rd`                                   |
| `slt`            | `Set rd to 1 if rs1 is less than rs2, otherwise set rd to 0 (signed)`                                                            |
| `sltu`           | `Set rd to 1 if rs1 is less than rs2, otherwise set rd to 0 (unsigned)`                                                          |
| `xor`            | `Set rd to the bitwise xor of rs1 and rs2`                                                                                       |
| `srl`            | `Shift rs1 right by the by the lower 5 or 6 (RV32/64) bits in rs2 and place the result into rd`                                  |
| `sra`            | `Shift rs1 right by the by the lower 5 or 6 (RV32/64) bits in rs2 and place the result into rd while retaining the sign`         |
| `or`             | `Set rd to the bitwise or of rs1 and rs2`                                                                                        |
| `and`            | `Set rd to the bitwise and of rs1 and rs2`                                                                                       |
| `fence`          | `Order device I/O and memory accesses viewed by other threads and devices`                                                       |
| `fence.i`        | `Synchronize the instruction and data streams`                                                                                   |

:RV32I - "RV32I Base Integer Instruction Set"

| instruction name | instruction description                                                                                                          |
|------------------|:---------------------------------------------------------------------------------------------------------------------------------|
| `ld`             | `Load 64-bit value from addr in rs1 plus 12-bit signed immediate and place sign-extended result into rd`                         |
| `sd`             | `Store 64-bit value from the low bits of rs2 to addr in rs1 plus the 12-bit signed immediate`                                    |
| `addiw`          | `Add sign-extended 12-bit immediate to register rs1 and place 32-bit sign extended result in rs2 zeroing upper bits`             |
| `slliw`          | `Shift 32-bit value in rs1 left by the 5 bit immediate and place the result into rd while zeroing upper bits`                    |
| `srliw`          | `Shift 32-bit value in rs1 right by the 5 bit immediate and place the result into rd while zeroing upper bits`                   |
| `sraiw`          | `Shift 32-bit value in rs1 right by the 5 bit immediate and place the result into rd and retaining the sign`                     |
| `addw`           | `Add 32-bit value in rs2 to rs1 and place the 32-bit result into rd`                                                             |
| `subw`           | `Subtract 32-bit value in rs2 from rs1 and place the 32-bit result into rd`                                                      |
| `sllw`           | `Shift 32-bit value in rs1 left by the by the lower 5 bits in rs2 and place the 32-bit result into rd`                           |
| `srlw`           | `Shift 32-bit value in rs1 right by the by the lower 5 bits in rs2 and place the 32-bit result into rd`                          |
| `sraw`           | `Shift 32-bit value in rs1 right by the by the lower 5 bits in rs2 and place the 32-bit result into rd while retaining the sign` |

:RV64I - "RV64I Base Integer Instruction Set (+ RV32I)"

| instruction name | instruction description                                                                                                          |
|------------------|:---------------------------------------------------------------------------------------------------------------------------------|
| `mul`            | `Multiply rs1 by rs2 and place the result in rd`                                                                                 |
| `mulh`           | `Multiply signed rs1 by signed rs2 and place the high bits of the result in rd`                                                  |
| `mulhsu`         | `Multiply signed rs1 by unsigned rs2 and place the high bits of the result in rd`                                                |
| `mulhu`          | `Multiply unsigned rs1 by unsigned rs2 and place the high bits of the result in rd`                                              |
| `div`            | `Divide rs1 (dividend) by rs2 (divisor) and place the quotient in rd (signed)`                                                   |
| `divu`           | `Divide rs1 (dividend) by rs2 (divisor) and place the quotient in rd (unsigned)`                                                 |
| `rem`            | `Divide rs1 (dividend) by rs2 (divisor) and place the remainder in rd (signed)`                                                  |
| `remu`           | `Divide rs1 (dividend) by rs2 (divisor) and place the remainder in rd (unsigned)`                                                |

:RV32M - "RV32M Standard Extension for Integer Multiply and Divide"

| instruction name | instruction description                                                                                                          |
|------------------|:---------------------------------------------------------------------------------------------------------------------------------|
| `mulw`           | `Multiply with lower 32-bits of rs1 by the lower 32-bits of rs2 and place the result in rd`                                      |
| `divw`           | `Divide lower 32-bits of rs1 (dividend) by lower 32-bits of rs2 (divisor) and place the quotient in rd (signed)`                 |
| `divuw`          | `Divide lower 32-bits of rs1 (dividend) by lower 32-bits of rs2 (divisor) and place the quotient in rd (unsigned)`               |
| `remw`           | `Divide lower 32-bits of rs1 (dividend) by lower 32-bits of rs2 (divisor) and place the remainder in rd (signed)`                |
| `remuw`          | `Divide lower 32-bits of rs1 (dividend) by lower 32-bits of rs2 (divisor) and place the remainder in rd (unsigned)`              |

:RV64M - "RV64M Standard Extension for Integer Multiply and Divide (+ RV32M)"

| instruction name | instruction description                                                                                                          |
|------------------|:---------------------------------------------------------------------------------------------------------------------------------|
| `lr.w`           | `Load word from address in rs1, place the sign-extended result in rd and register a reservation on the memory word`              |
| `sc.w`           | `Write word in rs1 to the address in rs2 if a valid reservation exists, write 0 on success or 1 on failure to rd`                |
| `amoswap.w`      | `Load word from address in rs1 into rd, swap rd and rs2, write the result to the address in rs1`                                 |
| `amoadd.w`       | `Load word from address in rs1 into rd, add rd and rs2, write the result to the address in rs1`                                  |
| `amoxor.w`       | `Load word from address in rs1 into rd, xor rd and rs2, write the result to the address in rs1`                                  |
| `amoor.w`        | `Load word from address in rs1 into rd, or rd and rs2, write the result to the address in rs1`                                   |
| `amoand.w`       | `Load word from address in rs1 into rd, and rd and rs2, write the result to the address in rs1`                                  |
| `amomin.w`       | `Load word from address in rs1 into rd, find minimum of rd and rs2, write the result to the address in rs1 (signed)`             |
| `amomax.w`       | `Load word from address in rs1 into rd, find maximum of rd and rs2, write the result to the address in rs1 (signed)`             |
| `amominu.w`      | `Load word from address in rs1 into rd, find minimum of rd and rs2, write the result to the address in rs1 (unsigned)`           |
| `amomaxu.w`      | `Load word from address in rs1 into rd, find maximum of rd and rs2, write the result to the address in rs1 (unsigned)`           |

:RV32A - "RV32A Standard Extension for Atomic Instructions"

| instruction name | instruction description                                                                                                          |
|------------------|:---------------------------------------------------------------------------------------------------------------------------------|
| `lr.d`           | `Load double word from address in rs1, place the sign-extended result in rd and register a reservation on the memory word`       |
| `sc.d`           | `Write double word in rs1 to the address in rs2 if a valid reservation exists, write 0 on success or 1 on failure to rd`         |
| `amoswap.d`      | `Load double word from address in rs1 into rd, swap rd and rs2, write the result to the address in rs1`                          |
| `amoadd.d`       | `Load double word from address in rs1 into rd, add rd and rs2, write the result to the address in rs1`                           |
| `amoxor.d`       | `Load double word from address in rs1 into rd, xor rd and rs2, write the result to the address in rs1`                           |
| `amoor.d`        | `Load double word from address in rs1 into rd, or rd and rs2, write the result to the address in rs1`                            |
| `amoand.d`       | `Load double word from address in rs1 into rd, and rd and rs2, write the result to the address in rs1`                           |
| `amomin.d`       | `Load double word from address in rs1 into rd, find minimum of rd and rs2, write the result to the address in rs1 (signed)`      |
| `amomax.d`       | `Load double word from address in rs1 into rd, find maximum of rd and rs2, write the result to the address in rs1 (signed)`      |
| `amominu.d`      | `Load double word from address in rs1 into rd, find minimum of rd and rs2, write the result to the address in rs1 (unsigned)`    |
| `amomaxu.d`      | `Load double word from address in rs1 into rd, find maximum of rd and rs2, write the result to the address in rs1 (unsigned)`    |

:RV64A - "RV64A Standard Extension for Atomic Instructions (+ RV32A)"

| instruction name | instruction description                                                                                                          |
|------------------|:---------------------------------------------------------------------------------------------------------------------------------|
| `scall`          | `System call is used to make a request to a higher privilege level`                                                              |
| `sbreak`         | `Break to Debugger causes control to be transferred back to the debugging environment via a breakpoint exception`                |
| `sret`           | `System Return returns to the supervisor mode privilege level after handling a trap`                                             |
| `sfence.vm`      | `Supervisor memory-management fence synchronizes updates to in-memory memory-management data structures`                         |
| `wfi`            | `Wait for Interrupt indicates the hart can be stalled until an interrupt needs servicing`                                        |
| `rdcycle`        | `Read cycle counter status register`                                                                                             |
| `rdtime`         | `Read timer status register`                                                                                                     |
| `rdinstret`      | `Read instructions retired status register`                                                                                      |
| `rdcycleh`       | `Read cycle counter status register (upper 32-bits on RV32)`                                                                     |
| `rdtimeh`        | `Read timer status register (upper 32-bits on RV32)`                                                                             |
| `rdinstreth`     | `Read instructions retired status register (upper 32-bits on RV32)`                                                              |
| `csrrw`          | `CSR Atomic Read Write writes the value in rs1 to the CSR, and writes previous value to rd`                                      |
| `csrrs`          | `CSR Atomic Set Bit reads the CSR, sets CSR bits set in rs1, and writes previous value to rd`                                    |
| `csrrc`          | `CSR Atomic Clear Bit reads the CSR, clears CSR bits set in rs1, and writes previous value to rd`                                |
| `csrrwi`         | `CSR Atomic Read Write Immediate writes the immediate value to the CSR, and writes previous value to rd`                         |
| `csrrsi`         | `CSR Atomic Set Bit Immediate reads the CSR, sets CSR bits set in the immediate, and writes previous value to rd`                |
| `csrrci`         | `CSR Atomic Clear Bit Immediate reads the CSR, clears CSR bits set in the immediate, and writes previous value to rd`            |

:RV32S - "RV32S Standard Extension for Supervisor-level Instructions"

| instruction name | instruction description                                                                                                          |
|------------------|:---------------------------------------------------------------------------------------------------------------------------------|
| `flw`            | `Loads a single-precision foating-point value from memory into foating-point register frd`                                       |
| `fsw`            | `Stores a single-precision foating-point value from foating-point register frs2 to memory`                                       |
| `fmadd.s`        | `Multiply the single-precision values in frs1 and frs2, then add rs3 and write the result to frd`                                |
| `fmsub.s`        | `Multiply the single-precision values in frs1 and frs2, then subtract rs3 and write the result to frd`                           |
| `fnmsub.s`       | `Multiply the single-precision value in frs1 with the negated value in frs2, then add rs3 and write the result to frd`           |
| `fnmadd.s`       | `Multiply the single-precision value in frs1 with the negated value in frs2, then subtract rs3 and write the result to frd`      |
| `fadd.s`         | `Add the single-precision values in frs1 and frs2, then write the result to frd`                                                 |
| `fsub.s`         | `Subtract the single-precision values in frs1 from frs2, then write the result to frd`                                           |
| `fmul.s`         | `Multiply the single-precision values in frs1 and frs2, then write the result to frd`                                            |
| `fdiv.s`         | `Divide the single-precision value in frs1 into frs2, then write the result to frd`                                              |
| `fsgnj.s`        | `Take the single-precision value from frs1 and inject the sign bit from frs2, then write the result to frd`                      |
| `fsgnjn.s`       | `Take the single-precision value from frs1 and inject the negated sign bit from frs2, then write the result to frd`              |
| `fsgnjx.s`       | `Take the single-precision value from frs1 and inject the xor of the sign bits frs1 and frs2, then write the result to frd`      |
| `fmin.s`         | `Take the smaller single-precision value from frs1 and frs2, then write the result to frd`                                       |
| `fmax.s`         | `Take the larger single-precision value from frs1 and frs2, then write the result to frd`                                        |
| `fsqrt.s`        | `Calculate the square root of the single-precision value in frs1, then write the result to frd`                                  |
| `fle.s`          | `Set rd to 1 if the single-precision value in frs1 is less than or equal to frs2, otherwise set rd to 0`                         |
| `flt.s`          | `Set rd to 1 if the single-precision value in frs1 is less than frs2, otherwise set rd to 0`                                     |
| `feq.s`          | `Set rd to 1 if the single-precision value in frs1 is equal to frs2, otherwise set rd to 0`                                      |
| `fcvt.w.s`       | `Convert the single-precision value in frs1 to a 32-bit signed integer, then write the result to rd`                             |
| `fcvt.wu.s`      | `Convert the single-precision value in frs1 to a 32-bit unsigned integer, then write the result to rd`                           |
| `fcvt.s.w`       | `Convert the 32-bit signed integer in rs1 to a single-precision value, then write the result to frd`                             |
| `fcvt.s.wu`      | `Convert the 32-bit unsigned integer in rs1 to a single-precision value, then write the result to frd`                           |
| `fclass.s`       | `Set rd to a 10-bit mask indicating the class of the single-precision value in frs1`                                             |

:RV32F - "RV32F Standard Extension for Single-Precision Floating-Point"

| instruction name | instruction description                                                                                                          |
|------------------|:---------------------------------------------------------------------------------------------------------------------------------|
| `fcvt.l.s`       | `Convert the single-precision value in frs1 to a 64-bit signed integer, then write the result to rd`                             |
| `fcvt.lu.s`      | `Convert the single-precision value in frs1 to a 64-bit unsigned integer, then write the result to rd`                           |
| `fmv.x.s`        | `Write the sign extended single-precision value in frs1 into the integer register rd`                                            |
| `fcvt.s.l`       | `Convert the 64-bit signed integer in rs1 to a single-precision value, then write the result to frd`                             |
| `fcvt.s.lu`      | `Convert the 64-bit unsigned integer in rs1 to a single-precision value, then write the result to frd`                           |
| `fmv.s.x`        | `Write the lower 32-bits of the integer register rs1 into the single-precision register frd`                                     |

:RV64F - "RV64F Standard Extension for Single-Precision Floating-Point (+ RV32F)"

| instruction name | instruction description                                                                                                          |
|------------------|:---------------------------------------------------------------------------------------------------------------------------------|
| `fld`            | `Loads a double-precision foating-point value from memory into foating-point register frd`                                       |
| `fsd`            | `Stores a double-precision foating-point value from foating-point register frs2 to memory`                                       |
| `fmadd.d`        | `Multiply the double-precision values in frs1 and frs2, then add rs3 and write the result to frd`                                |
| `fmsub.d`        | `Multiply the double-precision values in frs1 and frs2, then subtract rs3 and write the result to frd`                           |
| `fnmsub.d`       | `Multiply the double-precision value in frs1 with the negated value in frs2, then add rs3 and write the result to frd`           |
| `fnmadd.d`       | `Multiply the double-precision value in frs1 with the negated value in frs2, then subtract rs3 and write the result to frd`      |
| `fadd.d`         | `Add the double-precision values in frs1 and frs2, then write the result to frd`                                                 |
| `fsub.d`         | `Subtract the double-precision values in frs1 from frs2, then write the result to frd`                                           |
| `fmul.d`         | `Multiply the double-precision values in frs1 and frs2, then write the result to frd`                                            |
| `fdiv.d`         | `Divide the double-precision value in frs1 into frs2, then write the result to frd`                                              |
| `fsgnj.d`        | `Take the double-precision value from frs1 and inject the sign bit from frs2, then write the result to frd`                      |
| `fsgnjn.d`       | `Take the double-precision value from frs1 and inject the negated sign bit from frs2, then write the result to frd`              |
| `fsgnjx.d`       | `Take the double-precision value from frs1 and inject the xor of the sign bits frs1 and frs2, then write the result to frd`      |
| `fmin.s`         | `Take the smaller double-precision value from frs1 and frs2, then write the result to frd`                                       |
| `fmax.s`         | `Take the larger double-precision value from frs1 and frs2, then write the result to frd`                                        |
| `fcvt.s.d`       | `Convert the double-precision value in frs1 to single-precision, then write the result to frd`                                   |
| `fcvt.d.s`       | `Convert the single-precision value in frs1 to double-precision, then write the result to frd`                                   |
| `fsqrt.d`        | `Calculate the square root of the double-precision value in frs1, then write the result to frd`                                  |
| `fle.d`          | `Set rd to 1 if frs1 is less than or equal to frs2, otherwise set rd to 0`                                                       |
| `flt.d`          | `Set rd to 1 if frs1 is less than frs2, otherwise set rd to 0`                                                                   |
| `feq.d`          | `Set rd to 1 if frs1 is equal to frs2, otherwise set rd to 0`                                                                    |
| `fcvt.w.d`       | `Convert the double-precision value in frs1 to a 32-bit signed integer, then write the result to rd`                             |
| `fcvt.wu.d`      | `Convert the double-precision value in frs1 to a 32-bit unsigned integer, then write the result to rd`                           |
| `fcvt.d.w`       | `Convert the 64-bit signed integer in rs1 to a double-precision value, then write the result to frd`                             |
| `fcvt.d.wu`      | `Convert the 64-bit unsigned integer in rs1 to a double-precision value, then write the result to frd`                           |
| `fmv.x.d`        | `Write the sign extended double-precision value in frs1 into integer register rd`                                                |
| `fclass.d`       | `Set rd to a 10-bit mask indicating the class of the double-precision value in frs1`                                             |
| `fmv.d.x`        | `Write the 64-bit integer register rs1 into the double-precision register frd`                                                   |

:RV32D - "RV32D Standard Extension for Double-Precision Floating-Point"

| instruction name | instruction description                                                                                                          |
|------------------|:---------------------------------------------------------------------------------------------------------------------------------|
| `fcvt.l.d`       | `Convert the double-precision value in frs1 to a 64-bit signed integer, then write the result to rd`                             |
| `fcvt.lu.d`      | `Convert the double-precision value in frs1 to a 64-bit unsigned integer, then write the result to rd`                           |
| `fcvt.d.l`       | `Convert the 64-bit signed integer in rs1 to a double-precision value, then write the result to frd`                             |
| `fcvt.d.lu`      | `Convert the 64-bit unsigned integer in rs1 to a double-precision value, then write the result to frd`                           |

:RV64D - "RV64D Standard Extension for Double-Precision Floating-Point (+ RV32D)"

| instruction name | instruction description                                                                                                          |
|------------------|:---------------------------------------------------------------------------------------------------------------------------------|
| `frcsr`          | `Read FP Control and Status Register`                                                                                            |
| `frrm`           | `Read FP Rounding Mode (Bits 7:5 of fcsr Control and Status Register)`                                                           |
| `frflags`        | `Read FP Accrued Exception Flags (Bits 4:0 of fcsr Control and Status Register)`                                                 |
| `fscsr`          | `Read FP Control and Status Register`                                                                                            |
| `fsrm`           | `Set FP Rounding Mode (Bits 7:5 of fcsr Control and Status Register)`                                                            |
| `fsflags`        | `Set FP Accrued Exception Flags (Bits 4:0 of fcsr Control and Status Register)`                                                  |
| `fsrmi`          | `Set FP Rounding Mode Immediate (Bits 7:5 of fcsr Control and Status Register)`                                                  |
| `fsflagsi`       | `Set FP Accrued Exception Flags Immediate (Bits 4:0 of fcsr Control and Status Register)`                                        |

:RV32FD - "RV32F and RV32D Common Floating-Point Instructions"

| instruction name | instruction description                                                                                                          |
|------------------|:---------------------------------------------------------------------------------------------------------------------------------|
| `flq`            | `Loads a quadruple-precision foating-point value from memory into foating-point register frd`                                    |
| `fsq`            | `Stores a quadruple-precision foating-point value from foating-point register frs2 to memory`                                    |
| `fmadd.q`        | `Multiply the quadruple-precision values in frs1 and frs2, then add rs3 and write the result to frd`                             |
| `fmsub.q`        | `Multiply the quadruple-precision values in frs1 and frs2, then subtract rs3 and write the result to frd`                        |
| `fnmsub.q`       | `Multiply the quadruple-precision value in frs1 with the negated value in frs2, then add rs3 and write the result to frd`        |
| `fnmadd.q`       | `Multiply the quadruple-precision value in frs1 with the negated value in frs2, then subtract rs3 and write the result to frd`   |
| `fadd.q`         | `Add the quadruple-precision values in frs1 and frs2, then write the result to frd`                                              |
| `fsub.q`         | `Subtract the quadruple-precision values in frs1 from frs2, then write the result to frd`                                        |
| `fmul.q`         | `Multiply the quadruple-precision values in frs1 and frs2, then write the result to frd`                                         |
| `fdiv.q`         | `Divide the quadruple-precision value in frs1 into frs2, then write the result to frd`                                           |
| `fsgnj.q`        | `Take the quadruple-precision value from frs1 and inject the sign bit from frs2, then write the result to frd`                   |
| `fsgnjn.q`       | `Take the quadruple-precision value from frs1 and inject the negated sign bit from frs2, then write the result to frd`           |
| `fsgnjx.q`       | `Take the quadruple-precision value from frs1 and inject the xor of the sign bits frs1 and frs2, then write the result to frd`   |
| `fmin.s`         | `Take the smaller quadruple-precision value from frs1 and frs2, then write the result to frd`                                    |
| `fmax.s`         | `Take the larger quadruple-precision value from frs1 and frs2, then write the result to frd`                                     |
| `fcvt.s.q`       | `Convert the quadruple-precision value in frs1 to single-precision, then write the result to frd`                                |
| `fcvt.q.s`       | `Convert the single-precision value in frs1 to quadruple-precision, then write the result to frd`                                |
| `fcvt.d.q`       | `Convert the quadruple-precision value in frs1 to double-precision, then write the result to frd`                                |
| `fcvt.q.d`       | `Convert the double-precision value in frs1 to quadruple-precision, then write the result to frd`                                |
| `fsqrt.q`        | `Calculate the square root of the quadruple-precision value in frs1, then write the result to frd`                               |
| `fle.q`          | `Set rd to 1 if frs1 is less than or equal to frs2, otherwise set rd to 0`                                                       |
| `flt.q`          | `Set rd to 1 if frs1 is less than frs2, otherwise set rd to 0`                                                                   |
| `feq.q`          | `Set rd to 1 if frs1 is equal to frs2, otherwise set rd to 0`                                                                    |
| `fcvt.w.q`       | `Convert the quadruple-precision value in frs1 to a 32-bit signed integer, then write the result to rd`                          |
| `fcvt.wu.q`      | `Convert the quadruple-precision value in frs1 to a 32-bit unsigned integer, then write the result to rd`                        |
| `fcvt.q.w`       | `Convert the 64-bit signed integer in rs1 to a quadruple-precision value, then write the result to frd`                          |
| `fcvt.q.wu`      | `Convert the 64-bit unsigned integer in rs1 to a quadruple-precision value, then write the result to frd`                        |
| `fclass.q`       | `Set rd to a 10-bit mask indicating the class of the quadruple-precision value in frs1`                                          |

:RV32Q - "RV32Q Standard Extension for Quadruple-Precision Floating-Point"

| instruction name | instruction description                                                                                                          |
|------------------|:---------------------------------------------------------------------------------------------------------------------------------|
| `fcvt.l.q`       | `Convert the quadruple-precision value in frs1 to a 64-bit signed integer, then write the result to rd`                          |
| `fcvt.lu.q`      | `Convert the quadruple-precision value in frs1 to a 64-bit unsigned integer, then write the result to rd`                        |
| `fcvt.q.l`       | `Convert the 64-bit signed integer in rs1 to a quadruple-precision value, then write the result to frd`                          |
| `fcvt.q.lu`      | `Convert the 64-bit unsigned integer in rs1 to a quadruple-precision value, then write the result to frd`                        |

:RV64Q - "RV64Q Standard Extension for Quadruple-Precision Floating-Point (+ RV32Q)"

| instruction name | instruction description                                                                                                          |
|------------------|:---------------------------------------------------------------------------------------------------------------------------------|
| `fmv.x.q`        | `Write the sign extended quadruple-precision value in frs1 into integer register rd`                                             |
| `fmv.q.x`        | `Write the 64-bit integer register rs1 into the quadruple-precision register frd`                                                |

:RV128Q - "RV128Q Standard Extension for Quadruple-Precision Floating-Point (+ RV64Q)"

| instruction name | instruction description                                                                                                          |
|------------------|:---------------------------------------------------------------------------------------------------------------------------------|
| `nop`            | `No operation`                                                                                                                   |
| `#li`            | `Load immediate`                                                                                                                 |
| `mv`             | `Copy register`                                                                                                                  |
| `not`            | `One's complement`                                                                                                               |
| `neg`            | `Two's complement`                                                                                                               |
| `negw`           | `Two's complement Word`                                                                                                          |
| `sext.w`         | `Sign extend Word`                                                                                                               |
| `seqz`           | `Set if = zero`                                                                                                                  |
| `snez`           | `Set if != zero`                                                                                                                 |
| `sltz`           | `Set if < zero`                                                                                                                  |
| `sgtz`           | `Set if > zero`                                                                                                                  |
| `fmv.s`          | `Single-precision move`                                                                                                          |
| `fabs.s`         | `Single-precision absolute value`                                                                                                |
| `fneg.s`         | `Single-precision negate`                                                                                                        |
| `fmv.d`          | `Double-precision move`                                                                                                          |
| `fabs.d`         | `Double-precision absolute value`                                                                                                |
| `fneg.d`         | `Double-precision negate`                                                                                                        |
| `fmv.q`          | `Quadruple-precision move`                                                                                                       |
| `fabs.q`         | `Quadruple-precision absolute value`                                                                                             |
| `fneg.q`         | `Quadruple-precision negate`                                                                                                     |
| `beqz`           | `Branch if = zero`                                                                                                               |
| `bnez`           | `Branch if != zero`                                                                                                              |
| `blez`           | `Branch if <= zero`                                                                                                              |
| `bgez`           | `Branch if >= zero`                                                                                                              |
| `bltz`           | `Branch if < zero`                                                                                                               |
| `bgtz`           | `Branch if > zero`                                                                                                               |
| `j`              | `Jump`                                                                                                                           |
| `jr`             | `Jump register`                                                                                                                  |
| `ret`            | `Return from subroutine`                                                                                                         |

:Pseudo Instructions
