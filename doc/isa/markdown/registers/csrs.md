## CONTROL AND STATUS REGISTERS

Format of a line in the table:
`<csr number> <csr access> <csr name> "<csr description>" <version>`

`<access> is one of urw, uro, srw, sro, hrw, hro, mrw, mro`

`<version> is [introduced]-[deprecated]`

| csr      | num    | access            | description                                       | version          |
|----------|:-------|:------------------|:--------------------------------------------------|:-----------------|
| `0x000`  | `urw`  | `ustatus`         | `User status register`                            | `1.9-`           |
| `0x004`  | `urw`  | `uie`             | `User interrupt-enable register`                  | `1.9-`           |
| `0x005`  | `urw`  | `utvec`           | `User trap handler base address`                  | `1.9-`           |

:User Trap Setup

| csr      | num    | access            | description                                       | version          |
|----------|:-------|:------------------|:--------------------------------------------------|:-----------------|
| `0x040`  | `urw`  | `uscratch`        | `Scratch handler for user trap handlers`          | `1.9-`           |
| `0x041`  | `urw`  | `uepc`            | `User exception program counter`                  | `1.9-`           |
| `0x042`  | `urw`  | `ucause`          | `User trap cause`                                 | `1.9-`           |
| `0x043`  | `urw`  | `ubadaddr`        | `User bad address`                                | `1.7-1.9.1`      |
| `0x043`  | `urw`  | `utval`           | `User bad address or instruction`                 | `1.10-`          |
| `0x044`  | `urw`  | `uip`             | `User interrupt pending`                          | `1.9-`           |

:User Trap Handling

| csr      | num    | access            | description                                       | version          |
|----------|:-------|:------------------|:--------------------------------------------------|:-----------------|
| `0x001`  | `urw`  | `fflags`          | `Floating-Point Accrued Exceptions`               | `1.7-`           |
| `0x002`  | `urw`  | `frm`             | `Floating-Point Dynamic Rounding Mode`            | `1.7-`           |
| `0x003`  | `urw`  | `fcsr`            | `Floating-Point Control and Status (frm + fflags)`| `1.7-`           |

:User Floating-Point CSRs

| csr      | num    | access            | description                                       | version          |
|----------|:-------|:------------------|:--------------------------------------------------|:-----------------|
| `0xC00`  | `uro`  | `cycle`           | `Cycle counter (for RDCYCLE)`                     | `1.7-`           |
| `0xC01`  | `uro`  | `time`            | `Wall-clock time (for RDTIME)`                    | `1.7-`           |
| `0xC02`  | `uro`  | `instret`         | `Instructions-retired counter (for RDINSTRET)`    | `1.7-`           |
| `0xC80`  | `uro`  | `cycleh`          | `Upper 32 bits of cycle, RV32I only`              | `1.7-,rv32`      |
| `0xC81`  | `uro`  | `timeh`           | `Upper 32 bits of time, RV32I only`               | `1.7-,rv32`      |
| `0xC82`  | `uro`  | `instreth`        | `Upper 32 bits of instret, RV32I only`            | `1.7-,rv32`      |

:User Timers and Counters

| csr      | num    | access            | description                                       | version          |
|----------|:-------|:------------------|:--------------------------------------------------|:-----------------|
| `0x100`  | `srw`  | `sstatus`         | `Supervisor status register`                      | `1.7-`           |
| `0x102`  | `srw`  | `sedeleg`         | `Supervisor exception delegation register`        | `1.9-`           |
| `0x103`  | `srw`  | `sideleg`         | `Supervisor interrupt delegation register`        | `1.9-`           |
| `0x104`  | `src`  | `sie`             | `Supervisor interrupt-enable register`            | `1.7-`           |
| `0x105`  | `srw`  | `stvec`           | `Supervisor trap handler base address`            | `1.7-`           |
| `0x106`  | `swr`  | `scounteren`      | `Supervisor counter enable`                       | `1.10-`          |

:Supervisor Trap Setup

| csr      | num    | access            | description                                       | version          |
|----------|:-------|:------------------|:--------------------------------------------------|:-----------------|
| `0x140`  | `srw`  | `sscratch`        | `Scratch register for supervisor trap handlers`   | `1.7-`           |
| `0x141`  | `srw`  | `sepc`            | `Supervisor exception program counter`            | `1.7-`           |
| `0x142`  | `srw`  | `scause`          | `Supervisor trap cause`                           | `1.7-`           |
| `0x143`  | `srw`  | `sbadaddr`        | `Supervisor bad address`                          | `1.7-1.9.1`      |
| `0x143`  | `srw`  | `stval`           | `Supervisor bad address or instruction`           | `1.10-`          |
| `0x144`  | `srw`  | `sip`             | `Supervisor interrupt pending`                    | `1.7-`           |

:Supervisor Trap Handling

| csr      | num    | access            | description                                       | version          |
|----------|:-------|:------------------|:--------------------------------------------------|:-----------------|
| `0x180`  | `srw`  | `sptbr`           | `Page-table base register`                        | `1.7-1.9.1`      |
| `0x180`  | `srw`  | `satp`            | `Supervisor address translation and protection`   | `1.10-`          |

:Supervisor Protection and Translation

| csr      | num    | access            | description                                       | version          |
|----------|:-------|:------------------|:--------------------------------------------------|:-----------------|
| `0xD00`  | `sro`  | `scycle`          | `Supervisor cycle counter`                        | `1.9-`           |
| `0xD01`  | `sro`  | `stime`           | `Supervisor wall-clock time`                      | `1.7-1.9`        |
| `0xD02`  | `sro`  | `sinstret`        | `Supervisor instructions-retired counter`         | `1.9-`           |
| `0xD80`  | `sro`  | `scycleh`         | `Upper 32 bits of scycle, RV32I only`             | `1.9-,rv32`      |
| `0xD81`  | `sro`  | `stimeh`          | `Upper 32 bits of stime, RV32I only`              | `1.7-,rv32`      |
| `0xD82`  | `sro`  | `sinstreth`       | `Upper 32 bits of sinstret, RV32I only`           | `1.9-,rv32`      |

:Supervisor Timers and Counters

| csr      | num    | access            | description                                       | version          |
|----------|:-------|:------------------|:--------------------------------------------------|:-----------------|
| `0x200`  | `hrw`  | `hstatus`         | `Hypervisor status register`                      | `1.7-1.9.1`      |
| `0x202`  | `mrw`  | `hedeleg`         | `Hypervisor exception delegation register`        | `1.9-1.9.1`      |
| `0x203`  | `mrw`  | `hideleg`         | `Hypervisor interrupt delegation register`        | `1.9-1.9.1`      |
| `0x204`  | `mrw`  | `hie`             | `Hypervisor interrupt-enable register`            | `1.7-1.9.1`      |
| `0x205`  | `hrw`  | `htvec`           | `Hypervisor trap handler base address`            | `1.7-1.9.1`      |

:Hypervisor Trap Setup

| csr      | num    | access            | description                                       | version          |
|----------|:-------|:------------------|:--------------------------------------------------|:-----------------|
| `0x240`  | `hrw`  | `hscratch`        | `Scratch register for hypervisor trap handlers`   | `1.7-1.9.1`      |
| `0x241`  | `hrw`  | `hepc`            | `Hypervisor exception program counter`            | `1.7-1.9.1`      |
| `0x242`  | `hrw`  | `hcause`          | `Hypervisor trap cause`                           | `1.7-1.9.1`      |
| `0x243`  | `hrw`  | `hbadaddr`        | `Hypervisor bad address`                          | `1.7-1.9.1`      |
| `0x244`  | `hrw`  | `hip`             | `Hypervisor interrupt pending`                    | `1.7-1.9.1`      |

:Hypervisor Trap Handling

| csr      | num    | access            | description                                       | version          |
|----------|:-------|:------------------|:--------------------------------------------------|:-----------------|
| `0xE00`  | `sro`  | `hcycle`          | `Hypervisor cycle counter`                        | `1.7-1.9.1`      |
| `0xE01`  | `sro`  | `htime`           | `Hypervisor wall-clock time`                      | `1.7-1.9`        |
| `0xE02`  | `sro`  | `hinstret`        | `Hypervisor instructions-retired counter`         | `1.9-1.9.1`      |
| `0xE80`  | `sro`  | `hcycleh`         | `Upper 32 bits of hcycle, RV32I only`             | `1.7-1.9.1,rv32` |
| `0xE81`  | `sro`  | `htimeh`          | `Upper 32 bits of htime, RV32I only`              | `1.7-1.9,rv32`   |
| `0xE82`  | `sro`  | `hinstreth`       | `Upper 32 bits of hinstret, RV32I only`           | `1.9-1.9.1,rv32` |

:Hypervisor Timers and Counters

| csr      | num    | access            | description                                       | version          |
|----------|:-------|:------------------|:--------------------------------------------------|:-----------------|
| `0xF11`  | `mro`  | `mvendorid`       | `Vendor ID`                                       | `1.9-`           |
| `0xF12`  | `mro`  | `marchid`         | `Architecture ID`                                 | `1.9-`           |
| `0xF13`  | `mro`  | `mimpid`          | `Implementation ID`                               | `1.9-`           |
| `0xF14`  | `mro`  | `mhartid`         | `Hardware thread ID`                              | `1.7-`           |

:Machine Information Registers

| csr      | num    | access            | description                                       | version          |
|----------|:-------|:------------------|:--------------------------------------------------|:-----------------|
| `0x300`  | `mrw`  | `mstatus`         | `Machine status register`                         | `1.7-`           |
| `0x301`  | `mrw`  | `misa`            | `ISA and extensions supported`                    | `1.7-`           |
| `0x302`  | `mrw`  | `medeleg`         | `Machine exception delegation register`           | `1.9-`           |
| `0x303`  | `mrw`  | `mideleg`         | `Machine interrupt delegation register`           | `1.9-`           |
| `0x304`  | `mrw`  | `mie`             | `Machine interrupt-enable register`               | `1.7-`           |
| `0x305`  | `mrw`  | `mtvec`           | `Machine trap-handler base address`               | `1.7-`           |
| `0x306`  | `mrw`  | `mcounteren`      | `Machine counter enable`                          | `1.10-`          |

:Machine Trap Setup

| csr      | num    | access            | description                                       | version          |
|----------|:-------|:------------------|:--------------------------------------------------|:-----------------|
| `0x340`  | `mrw`  | `mscratch`        | `Scratch register for machine trap handlers`      | `1.7-`           |
| `0x341`  | `mrw`  | `mepc`            | `Machine exception program counter`               | `1.7-`           |
| `0x342`  | `mrw`  | `mcause`          | `Machine trap cause`                              | `1.7-`           |
| `0x343`  | `mrw`  | `mbadaddr`        | `Machine bad address`                             | `1.7-1.9.1`      |
| `0x343`  | `mrw`  | `mtval`           | `Machine bad address or instruction`              | `1.10-`          |
| `0x344`  | `mrw`  | `mip`             | `Machine interrupt pending`                       | `1.7-`           |
| `0x3A0`  | `mrw`  | `pmpcfg0`         | `Physical memory protection configuration`        | `1.10-`          |
| `0x3A1`  | `mrw`  | `pmpcfg1`         | `Physical memory protection configuration (RV32)` | `1.10-`          |
| `0x3A2`  | `mrw`  | `pmpcfg2`         | `Physical memory protection configuration`        | `1.10-`          |
| `0x3A3`  | `mrw`  | `pmpcfg3`         | `Physical memory protection configuration (RV32)` | `1.10-`          |
| `0x3B0`  | `mrw`  | `pmpaddr0`        | `Physical memory protection address register`     | `1.10-`          |
| `0x3B1`  | `mrw`  | `pmpaddr1`        | `Physical memory protection address register`     | `1.10-`          |
| `0x3B2`  | `mrw`  | `pmpaddr2`        | `Physical memory protection address register`     | `1.10-`          |
| `0x3B3`  | `mrw`  | `pmpaddr3`        | `Physical memory protection address register`     | `1.10-`          |
| `0x3B4`  | `mrw`  | `pmpaddr4`        | `Physical memory protection address register`     | `1.10-`          |
| `0x3B5`  | `mrw`  | `pmpaddr5`        | `Physical memory protection address register`     | `1.10-`          |
| `0x3B6`  | `mrw`  | `pmpaddr6`        | `Physical memory protection address register`     | `1.10-`          |
| `0x3B7`  | `mrw`  | `pmpaddr7`        | `Physical memory protection address register`     | `1.10-`          |
| `0x3B8`  | `mrw`  | `pmpaddr8`        | `Physical memory protection address register`     | `1.10-`          |
| `0x3B9`  | `mrw`  | `pmpaddr9`        | `Physical memory protection address register`     | `1.10-`          |
| `0x3BA`  | `mrw`  | `pmpaddr10`       | `Physical memory protection address register`     | `1.10-`          |
| `0x3BB`  | `mrw`  | `pmpaddr11`       | `Physical memory protection address register`     | `1.10-`          |
| `0x3BC`  | `mrw`  | `pmpaddr12`       | `Physical memory protection address register`     | `1.10-`          |
| `0x3BE`  | `mrw`  | `pmpaddr13`       | `Physical memory protection address register`     | `1.10-`          |
| `0x3BD`  | `mrw`  | `pmpaddr14`       | `Physical memory protection address register`     | `1.10-`          |
| `0x3BF`  | `mrw`  | `pmpaddr15`       | `Physical memory protection address register`     | `1.10-`          |

:Machine Trap Handling

| csr      | num    | access            | description                                       | version          |
|----------|:-------|:------------------|:--------------------------------------------------|:-----------------|
| `0x380`  | `mrw`  | `mbase`           | `Base register`                                   | `1.7-`           |
| `0x381`  | `mrw`  | `mbound`          | `Bound register`                                  | `1.7-`           |
| `0x382`  | `mrw`  | `mibase`          | `Instruction base register`                       | `1.7-`           |
| `0x383`  | `mrw`  | `mibound`         | `Instruction bound register`                      | `1.7-`           |
| `0x384`  | `mrw`  | `mdbase`          | `Data base register`                              | `1.7-`           |
| `0x385`  | `mrw`  | `mdbound`         | `Data bound register`                             | `1.7-`           |

:Machine Protection and Translation

| csr      | num    | access            | description                                       | version          |
|----------|:-------|:------------------|:--------------------------------------------------|:-----------------|
| `0xB00`  | `mrw`  | `mcycle`          | `Machine cycle counter`                           | `1.7-`           |
| `0xB01`  | `mrw`  | `mtime`           | `Machine wall-clock time`                         | `1.7-1.9`        |
| `0xB02`  | `mrw`  | `minstret`        | `Machine instructions-retired counter`            | `1.7-`           |
| `0xB03`  | `mrw`  | `mhpmcounter3`    | `Machine performance-monitoring counter`          | `1.9.1-`         |
| `0xB04`  | `mrw`  | `mhpmcounter4`    | `Machine performance-monitoring counter`          | `1.9.1-`         |
| `0xB05`  | `mrw`  | `mhpmcounter5`    | `Machine performance-monitoring counter`          | `1.9.1-`         |
| `0xB06`  | `mrw`  | `mhpmcounter6`    | `Machine performance-monitoring counter`          | `1.9.1-`         |
| `0xB07`  | `mrw`  | `mhpmcounter7`    | `Machine performance-monitoring counter`          | `1.9.1-`         |
| `0xB08`  | `mrw`  | `mhpmcounter8`    | `Machine performance-monitoring counter`          | `1.9.1-`         |
| `0xB09`  | `mrw`  | `mhpmcounter9`    | `Machine performance-monitoring counter`          | `1.9.1-`         |
| `0xB0A`  | `mrw`  | `mhpmcounter10`   | `Machine performance-monitoring counter`          | `1.9.1-`         |
| `0xB0B`  | `mrw`  | `mhpmcounter11`   | `Machine performance-monitoring counter`          | `1.9.1-`         |
| `0xB0C`  | `mrw`  | `mhpmcounter12`   | `Machine performance-monitoring counter`          | `1.9.1-`         |
| `0xB0D`  | `mrw`  | `mhpmcounter13`   | `Machine performance-monitoring counter`          | `1.9.1-`         |
| `0xB0E`  | `mrw`  | `mhpmcounter14`   | `Machine performance-monitoring counter`          | `1.9.1-`         |
| `0xB0F`  | `mrw`  | `mhpmcounter15`   | `Machine performance-monitoring counter`          | `1.9.1-`         |
| `0xB10`  | `mrw`  | `mhpmcounter16`   | `Machine performance-monitoring counter`          | `1.9.1-`         |
| `0xB11`  | `mrw`  | `mhpmcounter17`   | `Machine performance-monitoring counter`          | `1.9.1-`         |
| `0xB12`  | `mrw`  | `mhpmcounter18`   | `Machine performance-monitoring counter`          | `1.9.1-`         |
| `0xB13`  | `mrw`  | `mhpmcounter19`   | `Machine performance-monitoring counter`          | `1.9.1-`         |
| `0xB14`  | `mrw`  | `mhpmcounter20`   | `Machine performance-monitoring counter`          | `1.9.1-`         |
| `0xB15`  | `mrw`  | `mhpmcounter21`   | `Machine performance-monitoring counter`          | `1.9.1-`         |
| `0xB16`  | `mrw`  | `mhpmcounter22`   | `Machine performance-monitoring counter`          | `1.9.1-`         |
| `0xB17`  | `mrw`  | `mhpmcounter23`   | `Machine performance-monitoring counter`          | `1.9.1-`         |
| `0xB18`  | `mrw`  | `mhpmcounter24`   | `Machine performance-monitoring counter`          | `1.9.1-`         |
| `0xB19`  | `mrw`  | `mhpmcounter25`   | `Machine performance-monitoring counter`          | `1.9.1-`         |
| `0xB1A`  | `mrw`  | `mhpmcounter26`   | `Machine performance-monitoring counter`          | `1.9.1-`         |
| `0xB1B`  | `mrw`  | `mhpmcounter27`   | `Machine performance-monitoring counter`          | `1.9.1-`         |
| `0xB1C`  | `mrw`  | `mhpmcounter28`   | `Machine performance-monitoring counter`          | `1.9.1-`         |
| `0xB1D`  | `mrw`  | `mhpmcounter29`   | `Machine performance-monitoring counter`          | `1.9.1-`         |
| `0xB1E`  | `mrw`  | `mhpmcounter30`   | `Machine performance-monitoring counter`          | `1.9.1-`         |
| `0xB1F`  | `mrw`  | `mhpmcounter31`   | `Machine performance-monitoring counter`          | `1.9.1-`         |
| `0xB80`  | `mrw`  | `mcycleh`         | `Upper 32 bits of mcycle, RV32I only`             | `1.7-,rv32`      |
| `0xB81`  | `mrw`  | `mtimeh`          | `Upper 32 bits of mtime, RV32I only`              | `1.7-1.9,rv32`   |
| `0xB82`  | `mrw`  | `minstreth`       | `Upper 32 bits of minstret, RV32I only`           | `1.7-,rv32`      |
| `0xB83`  | `mrw`  | `mhpmcounter3h`   | `Upper 32 bits of mhpmcounter3, RV32I only`       | `1.9.1-`         |
| `0xB84`  | `mrw`  | `mhpmcounter4h`   | `Upper 32 bits of mhpmcounter4, RV32I only`       | `1.9.1-`         |
| `0xB85`  | `mrw`  | `mhpmcounter5h`   | `Upper 32 bits of mhpmcounter5, RV32I only`       | `1.9.1-`         |
| `0xB86`  | `mrw`  | `mhpmcounter6h`   | `Upper 32 bits of mhpmcounter6, RV32I only`       | `1.9.1-`         |
| `0xB87`  | `mrw`  | `mhpmcounter7h`   | `Upper 32 bits of mhpmcounter7, RV32I only`       | `1.9.1-`         |
| `0xB88`  | `mrw`  | `mhpmcounter8h`   | `Upper 32 bits of mhpmcounter8, RV32I only`       | `1.9.1-`         |
| `0xB89`  | `mrw`  | `mhpmcounter9h`   | `Upper 32 bits of mhpmcounter9, RV32I only`       | `1.9.1-`         |
| `0xB8A`  | `mrw`  | `mhpmcounter10h`  | `Upper 32 bits of mhpmcounter10, RV32I only`      | `1.9.1-`         |
| `0xB8B`  | `mrw`  | `mhpmcounter11h`  | `Upper 32 bits of mhpmcounter11, RV32I only`      | `1.9.1-`         |
| `0xB8C`  | `mrw`  | `mhpmcounter12h`  | `Upper 32 bits of mhpmcounter12, RV32I only`      | `1.9.1-`         |
| `0xB8D`  | `mrw`  | `mhpmcounter13h`  | `Upper 32 bits of mhpmcounter13, RV32I only`      | `1.9.1-`         |
| `0xB8E`  | `mrw`  | `mhpmcounter14h`  | `Upper 32 bits of mhpmcounter14, RV32I only`      | `1.9.1-`         |
| `0xB8F`  | `mrw`  | `mhpmcounter15h`  | `Upper 32 bits of mhpmcounter15, RV32I only`      | `1.9.1-`         |
| `0xB90`  | `mrw`  | `mhpmcounter16h`  | `Upper 32 bits of mhpmcounter16, RV32I only`      | `1.9.1-`         |
| `0xB91`  | `mrw`  | `mhpmcounter17h`  | `Upper 32 bits of mhpmcounter17, RV32I only`      | `1.9.1-`         |
| `0xB92`  | `mrw`  | `mhpmcounter18h`  | `Upper 32 bits of mhpmcounter18, RV32I only`      | `1.9.1-`         |
| `0xB93`  | `mrw`  | `mhpmcounter19h`  | `Upper 32 bits of mhpmcounter19, RV32I only`      | `1.9.1-`         |
| `0xB94`  | `mrw`  | `mhpmcounter20h`  | `Upper 32 bits of mhpmcounter20, RV32I only`      | `1.9.1-`         |
| `0xB95`  | `mrw`  | `mhpmcounter21h`  | `Upper 32 bits of mhpmcounter21, RV32I only`      | `1.9.1-`         |
| `0xB96`  | `mrw`  | `mhpmcounter22h`  | `Upper 32 bits of mhpmcounter22, RV32I only`      | `1.9.1-`         |
| `0xB97`  | `mrw`  | `mhpmcounter23h`  | `Upper 32 bits of mhpmcounter23, RV32I only`      | `1.9.1-`         |
| `0xB98`  | `mrw`  | `mhpmcounter24h`  | `Upper 32 bits of mhpmcounter24, RV32I only`      | `1.9.1-`         |
| `0xB99`  | `mrw`  | `mhpmcounter25h`  | `Upper 32 bits of mhpmcounter25, RV32I only`      | `1.9.1-`         |
| `0xB9A`  | `mrw`  | `mhpmcounter26h`  | `Upper 32 bits of mhpmcounter26, RV32I only`      | `1.9.1-`         |
| `0xB9B`  | `mrw`  | `mhpmcounter27h`  | `Upper 32 bits of mhpmcounter27, RV32I only`      | `1.9.1-`         |
| `0xB9C`  | `mrw`  | `mhpmcounter28h`  | `Upper 32 bits of mhpmcounter28, RV32I only`      | `1.9.1-`         |
| `0xB9D`  | `mrw`  | `mhpmcounter29h`  | `Upper 32 bits of mhpmcounter29, RV32I only`      | `1.9.1-`         |
| `0xB9E`  | `mrw`  | `mhpmcounter30h`  | `Upper 32 bits of mhpmcounter30, RV32I only`      | `1.9.1-`         |
| `0xB9F`  | `mrw`  | `mhpmcounter31h`  | `Upper 32 bits of mhpmcounter31, RV32I only`      | `1.9.1-`         |

:Machine Counters / Timers

| csr      | num    | access            | description                                       | version          |
|----------|:-------|:------------------|:--------------------------------------------------|:-----------------|
| `0x320`  | `mrw`  | `mucounteren`     | `Machine interrupt-enable register`               | `1.9-1.9.1`      |
| `0x321`  | `mrw`  | `mscounteren`     | `Supervisor-mode counter enable`                  | `1.9-1.9.1`      |
| `0x322`  | `mrw`  | `mhcounteren`     | `Hypervisor-mode counter enable`                  | `1.9-1.9.1`      |
| `0x323`  | `mrw`  | `mhpmevent3`      | `Machine performance-monitoring event selector`   | `1.9.1-`         |
| `0x324`  | `mrw`  | `mhpmevent4`      | `Machine performance-monitoring event selector`   | `1.9.1-`         |
| `0x325`  | `mrw`  | `mhpmevent5`      | `Machine performance-monitoring event selector`   | `1.9.1-`         |
| `0x326`  | `mrw`  | `mhpmevent6`      | `Machine performance-monitoring event selector`   | `1.9.1-`         |
| `0x327`  | `mrw`  | `mhpmevent7`      | `Machine performance-monitoring event selector`   | `1.9.1-`         |
| `0x328`  | `mrw`  | `mhpmevent8`      | `Machine performance-monitoring event selector`   | `1.9.1-`         |
| `0x329`  | `mrw`  | `mhpmevent9`      | `Machine performance-monitoring event selector`   | `1.9.1-`         |
| `0x32A`  | `mrw`  | `mhpmevent10`     | `Machine performance-monitoring event selector`   | `1.9.1-`         |
| `0x32B`  | `mrw`  | `mhpmevent11`     | `Machine performance-monitoring event selector`   | `1.9.1-`         |
| `0x32C`  | `mrw`  | `mhpmevent12`     | `Machine performance-monitoring event selector`   | `1.9.1-`         |
| `0x32D`  | `mrw`  | `mhpmevent13`     | `Machine performance-monitoring event selector`   | `1.9.1-`         |
| `0x32E`  | `mrw`  | `mhpmevent14`     | `Machine performance-monitoring event selector`   | `1.9.1-`         |
| `0x32F`  | `mrw`  | `mhpmevent15`     | `Machine performance-monitoring event selector`   | `1.9.1-`         |
| `0x330`  | `mrw`  | `mhpmevent16`     | `Machine performance-monitoring event selector`   | `1.9.1-`         |
| `0x331`  | `mrw`  | `mhpmevent17`     | `Machine performance-monitoring event selector`   | `1.9.1-`         |
| `0x332`  | `mrw`  | `mhpmevent18`     | `Machine performance-monitoring event selector`   | `1.9.1-`         |
| `0x333`  | `mrw`  | `mhpmevent19`     | `Machine performance-monitoring event selector`   | `1.9.1-`         |
| `0x334`  | `mrw`  | `mhpmevent20`     | `Machine performance-monitoring event selector`   | `1.9.1-`         |
| `0x335`  | `mrw`  | `mhpmevent21`     | `Machine performance-monitoring event selector`   | `1.9.1-`         |
| `0x336`  | `mrw`  | `mhpmevent22`     | `Machine performance-monitoring event selector`   | `1.9.1-`         |
| `0x337`  | `mrw`  | `mhpmevent23`     | `Machine performance-monitoring event selector`   | `1.9.1-`         |
| `0x338`  | `mrw`  | `mhpmevent24`     | `Machine performance-monitoring event selector`   | `1.9.1-`         |
| `0x339`  | `mrw`  | `mhpmevent25`     | `Machine performance-monitoring event selector`   | `1.9.1-`         |
| `0x33A`  | `mrw`  | `mhpmevent26`     | `Machine performance-monitoring event selector`   | `1.9.1-`         |
| `0x33B`  | `mrw`  | `mhpmevent27`     | `Machine performance-monitoring event selector`   | `1.9.1-`         |
| `0x33C`  | `mrw`  | `mhpmevent28`     | `Machine performance-monitoring event selector`   | `1.9.1-`         |
| `0x33D`  | `mrw`  | `mhpmevent29`     | `Machine performance-monitoring event selector`   | `1.9.1-`         |
| `0x33E`  | `mrw`  | `mhpmevent30`     | `Machine performance-monitoring event selector`   | `1.9.1-`         |
| `0x33F`  | `mrw`  | `mhpmevent31`     | `Machine performance-monitoring event selector`   | `1.9.1-`         |

:Machine Counter Setup

| csr      | num    | access            | description                                       | version          |
|----------|:-------|:------------------|:--------------------------------------------------|:-----------------|
| `0x7A0`  | `mrw`  | `tselect`         | `Debug/Trace trigger register select`             | `1.9.1-`         |
| `0x7A1`  | `mrw`  | `tdata1`          | `First Debug/Trace trigger data register`         | `1.9.1-`         |
| `0x7A2`  | `mrw`  | `tdata2`          | `Second Debug/Trace trigger data register`        | `1.9.1-`         |
| `0x7A3`  | `mrw`  | `tdata3`          | `Third Debug/Trace trigger data register`         | `1.9.1-`         |

:Debug/Trace Registers (shared with Debug Mode)

| csr      | num    | access            | description                                       | version          |
|----------|:-------|:------------------|:--------------------------------------------------|:-----------------|
| `0x7B0`  | `mrw`  | `dcsr`            | `Debug control and status register`               | `1.9.1-`         |
| `0x7B1`  | `mrw`  | `dpc`             | `Debug program counter`                           | `1.9.1-`         |
| `0x7B2`  | `mrw`  | `dscratch`        | `Debug scratch register`                          | `1.9.1-`         |

:Debug Mode Registers

| csr      | num    | access            | description                                       | version          |
|----------|:-------|:------------------|:--------------------------------------------------|:-----------------|
| `0x780`  | `mrw`  | `mtohost`         | `IO to Host`                                      | `1.7-`           |
| `0x781`  | `mrw`  | `mfromhost`       | `IO from Host`                                    | `1.7-`           |
| `0x782`  | `mrw`  | `mreset`          | `Reset`                                           | `1.7-`           |
| `0x783`  | `mrw`  | `mipi`            | `Inter Processor Interrupt`                       | `1.7-`           |
| `0x784`  | `mrw`  | `miobase`         | `IO Base`                                         | `1.7-`           |

:NonStandard
