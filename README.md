# PU-MSP430 WIKI

A Processing Unit (PU) is an electronic system within a computer that carries out instructions of a program by performing the basic arithmetic, logic, controlling, and I/O operations specified by instructions. Instruction-level parallelism is a measure of how many instructions in a computer can be executed simultaneously. The PU is contained on a single Metal Oxide Semiconductor (MOS) Integrated Circuit (IC).

The MSP430 implementation has a 16 bit Microarchitecture, 3 stages data pipeline and an Instruction Set Architecture based on Reduced Instruction Set Computer. Compatible with Wishbone Bus. Only For Researching.


## FRONT-END Open Source Tools

### Verilator
Hardware Description Language SystemVerilog Simulator
```
git clone http://git.veripool.org/git/verilator

cd verilator
autoconf
./configure
make
sudo make install
```

```
cd sim/verilog/regression/wb/vtor
source SIMULATE-IT
```

```
cd sim/verilog/regression/ahb3/vtor
source SIMULATE-IT
```

### Icarus Verilog
Hardware Description Language Verilog Simulator
```
git clone https://github.com/steveicarus/iverilog

cd iverilog
./configure
make
sh autoconf.sh
sudo make install
```

```
cd sim/verilog/regression/wb/iverilog
source SIMULATE-IT
```

```
cd sim/verilog/regression/ahb3/iverilog
source SIMULATE-IT
```

### GHDL
Hardware Description Language GHDL Simulator
```
git clone https://github.com/ghdl/ghdl

cd ghdl
./configure --prefix=/usr/local
make
sudo make install
```

```
cd sim/vhdl/regression/wb/ghdl
source SIMULATE-IT
```

```
cd sim/vhdl/regression/ahb3/ghdl
source SIMULATE-IT
```

### Yosys-ABC
Hardware Description Language Verilog Synthesizer
```
git clone https://github.com/YosysHQ/yosys

cd yosys
make
sudo make install
```

```
cd synthesis/yosys
source SYNTHESIZE-IT
```

## BACK-END Open Source Tools
Back-End Workflow
```
mkdir qflow
cd qflow

git clone https://github.com/RTimothyEdwards/magic
git clone https://github.com/rubund/graywolf
git clone https://github.com/The-OpenROAD-Project/OpenSTA
git clone https://github.com/RTimothyEdwards/qrouter
git clone https://github.com/RTimothyEdwards/irsim
git clone https://github.com/RTimothyEdwards/netgen
git clone https://github.com/RTimothyEdwards/qflow

cd magic
./configure
make
sudo make install

cd graywolf
mkdir build
cd build
cmake ..
make
sudo make install

cd OpenSTA
mkdir build
cd build
cmake ..
make
sudo make install

cd qrouter
./configure
make
sudo make install

cd irsim
./configure
make
sudo make install

cd netgen
./configure
make
sudo make install

cd qflow
./configure
make
sudo make install
```

```
cd synthesis/qflow
source FLOW-IT
```


## for WINDOWS users!

open Microsoft Store and install Ubuntu

type:
```
sudo apt update upgrade

sudo apt-get install bison cmake flex freeglut3-dev libcairo2-dev libgsl-dev \
libncurses-dev libx11-dev m4 python-tk python3-tk swig tcl tcl-dev tk-dev tcsh

sudo apt install gcc-msp430
```

### FRONT-END

type:
```
sudo apt install verilator
sudo apt install iverilog
sudo apt install ghdl

sudo apt install yosys
```

### BACK-END

type:
```
mkdir qflow
cd qflow

git clone https://github.com/RTimothyEdwards/magic
git clone https://github.com/rubund/graywolf
git clone https://github.com/The-OpenROAD-Project/OpenSTA
git clone https://github.com/RTimothyEdwards/qrouter
git clone https://github.com/RTimothyEdwards/irsim
git clone https://github.com/RTimothyEdwards/netgen
git clone https://github.com/RTimothyEdwards/qflow

cd magic
./configure
make
sudo make install

cd graywolf
mkdir build
cd build
cmake ..
make
sudo make install

cd OpenSTA
mkdir build
cd build
cmake ..
make
sudo make install

cd qrouter
./configure
make
sudo make install

cd irsim
./configure
make
sudo make install

cd netgen
./configure
make
sudo make install

cd qflow
./configure
make
sudo make install
```

## BASIC SYSTEM CONFIGURATION

|Description                            | Parameter   | Type    | Default
|-------------------------------------- | ----------- | ------- | -------
|Program Memory Size                    | PMEM_SIZE   | integer | 16384
|Data Memory Size                       | DMEM_SIZE   | integer | 4096
|Include/Exclude Hardware Multiplier    | MULTIPLYING | bit     | 1
|Include/Exclude Serial Debug interface | DBG_ON      | bit     | 1


## ADVANCED SYSTEM CONFIGURATION (FOR EXPERIENCED USERS)

| Description                    | Parameter      | Type       | Default
| ------------------------------ | -------------- | ---------- | -------
| Peripheral Memory Space        | PER_SIZE       | integer    | 512
| Custom user version number     | USER_VERSION   | bit vector | 0
| Watchdog timer                 | WATCHDOG       | bit        | 1
| Non-Maskable-Interrupt support | NMI_EN         | bit        | 1
| Number of available IRQs       | IRQ_16         | bit        | 1
|                                | IRQ_32         | bit        | 0
|                                | IRQ_64         | bit        | 0
| Input synchronizers            | SYNC_NMI       | bit        | 1
|                                | SYNC_CPU_EN    | bit        | 0
|                                | SYNC_DBG_EN    | bit        | 0
| Debugger definition            | DBG_RST_BRK_EN | bit        | 0


## EXPERT SYSTEM CONFIGURATION (EXPERTS ONLY)

| Description                            | Parameter          | Type       | Default
| -------------------------------------- | ------------------ | ---------- | -------
| Hardware breakpoint/watchpoint units   | DBG_HWBRK          | bit vector | 1
| Select serial debug interface protocol | DBG_UART           | bit        | 0
|                                        | DBG_I2C            | bit        | 1
| I2C broadcast address                  | DBG_I2C_BROADCASTC | bit        | 1
| Hardware breakpoint RANGE mode         | HWBRK_RANGE        | bit        | 1
| ASIC version                           | ASIC               | bit        | 1


## ASIC SYSTEM CONFIGURATION (EXPERTS/PROFESSIONALS ONLY)

|Description                     | Parameter           | Type       | Default
|------------------------------- | ------------------- | ---------- | -------
|LOW POWER MODE: SCG             | SCG_EN              | bit vector | 1
|FINE GRAINED CLOCK GATING       | CLOCK_GATING        | bit        | 1
|ASIC CLOCKING                   | ASIC_CLOCKING       | bit        | 1
|LFXT CLOCK DOMAIN               | LFXT_DOMAIN         | bit        | 1
|MCLK: Clock Mux                 | MCLK_MUX            | bit        | 1
|SMCLK: Clock Mux                | SMCLK_MUX           | bit        | 1
|WATCHDOG: Clock Mux             | WATCHDOG_MUX        | bit        | 1
|                                | WATCHDOG_NOMUX_ACLK | bit        | 0
|MCLK: Clock divider             | MCLK_DIVIDER        | bit        | 1
|SMCLK: Clock divider (/1/2/4/8) | SMCLK_DIVIDER       | bit        | 1
|ACLK: Clock divider (/1/2/4/8)  | ACLK_DIVIDER        | bit        | 1
|LOW POWER MODE: CPUOFF          | CPUOFF_EN           | bit        | 1
|LOW POWER MODE: OSCOFF          | OSCOFF_EN           | bit        | 1


## SYSTEM CONSTANTS (DO NOT EDIT)

|Description                                  | Parameter           | Type       | Default
|-------------------------------------------- | ------------------- | ---------- | -------
|Program Memory Size                          | PMEM_AWIDTH         | integer    | 13
|Data Memory Size                             | DMEM_AWIDTH         | integer    | 11
|Peripheral Memory Size                       | PER_AWIDTH          | integer    | 8
|Data Memory Base Adresses                    | DMEM_BASE           | integer    | N
|Program Memory                               | PMEM_MSB            | integer    | N
|Data Memory                                  | DMEM_MSB            | integer    | N
|                                             | PER_MSB             | integer    | N
|Number of available IRQs                     | IRQ_NR              | integer    | 16
|Instructions type                            | INST_SOC            | integer    | 0
|                                             | INST_JMPC           | integer    | 1
|                                             | INST_TOC            | integer    | 2
|Single-operand arithmetic                    | RRC                 | integer    | 0
|                                             | SWPB                | integer    | 1
|                                             | RRA                 | integer    | 2
|                                             | SXTC                | integer    | 3
|                                             | PUSH                | integer    | 4
|                                             | CALL                | integer    | 5
|                                             | RETI                | integer    | 6
|                                             | IRQX                | integer    | 7
|Conditional jump                             | JNE                 | integer    | 0
|                                             | JEQ                 | integer    | 1
|                                             | JNC                 | integer    | 2
|                                             | JC                  | integer    | 3
|                                             | JN                  | integer    | 4
|                                             | JGE                 | integer    | 5
|                                             | JL                  | integer    | 6
|                                             | JMP                 | integer    | 7
|Two-operand arithmetic                       | MOV                 | integer    | 0
|                                             | ADD                 | integer    | 1
|                                             | ADDC                | integer    | 2
|                                             | SUBC                | integer    | 3
|                                             | SUBB                | integer    | 4
|                                             | CMP                 | integer    | 5
|                                             | DADD                | integer    | 6
|                                             | BITC                | integer    | 7
|                                             | BIC                 | integer    | 8
|                                             | BIS                 | integer    | 9
|                                             | XORX                | integer    | 10
|                                             | ANDX                | integer    | 11
|Addressing modes                             | DIR                 | integer    | 0
|                                             | IDX                 | integer    | 1
|                                             | INDIR               | integer    | 2
|                                             | INDIR_I             | integer    | 3
|                                             | SYMB                | integer    | 4
|                                             | IMM                 | integer    | 5
|                                             | ABSC                | integer    | 6
|                                             | CONST               | integer    | 7
|Instruction state machine                    | I_IRQ_FETCH         | bit vector | 000
|                                             | I_IRQ_DONE          | bit vector | 001
|                                             | I_DEC               | bit vector | 010
|                                             | I_EXT1              | bit vector | 011
|                                             | I_EXT2              | bit vector | 100
|                                             | I_IDLE              | bit vector | 101
|Execution state machine                      | E_SRC_AD            | bit vector | X5
|                                             | E_SRC_RD            | bit vector | X6
|                                             | E_SRC_WR            | bit vector | X7
|                                             | E_DST_AD            | bit vector | X8
|                                             | E_DST_RD            | bit vector | X9
|                                             | E_DST_WR            | bit vector | XA
|                                             | E_EXEC              | bit vector | XB
|                                             | E_JUMP              | bit vector | XC
|                                             | E_IDLE              | bit vector | XD
|                                             | E_IRQ_0             | bit vector | X2
|                                             | E_IRQ_1             | bit vector | X1
|                                             | E_IRQ_2             | bit vector | X0
|                                             | E_IRQ_3             | bit vector | X3
|                                             | E_IRQ_4             | bit vector | X4
|ALU control signals                          | ALU_SRC_INV         | integer    | 0
|                                             | ALU_INC             | integer    | 1
|                                             | ALU_INC_C           | integer    | 2
|                                             | ALU_ADD             | integer    | 3
|                                             | ALU_AND             | integer    | 4
|                                             | ALU_OR              | integer    | 5
|                                             | ALU_XOR             | integer    | 6
|                                             | ALU_DADD            | integer    | 7
|                                             | ALU_STAT_7          | integer    | 8
|                                             | ALU_STAT_F          | integer    | 9
|                                             | ALU_SHIFT           | integer    | 10
|                                             | EXEC_NO_WR          | integer    | 11
|Debug interface                              | DBG_UART_WR         | integer    | 18
|                                             | DBG_UART_BW         | integer    | 17
|Debug interface CPU_CTL register             | HALT                | integer    | 0
|                                             | RUN                 | integer    | 1
|                                             | ISTEP               | integer    | 2
|                                             | SW_BRK_EN           | integer    | 3
|                                             | FRZ_BRK_EN          | integer    | 4
|                                             | RST_BRK_EN          | integer    | 5
|                                             | CPU_RST             | integer    | 6
|Debug interface BRKx_CTL register            | BRK_MODE_RD         | integer    | 0
|                                             | BRK_MODE_WR         | integer    | 1
|                                             | BRK_EN              | integer    | 2
|                                             | BRK_I_EN            | integer    | 3
|                                             | BRK_RANGE           | integer    | 4
|Basic clock module: BCSCTL2 Control Register | SELMX               | integer    | 7
|                                             | SELS                | integer    | 3
|MCLK Clock gate                              | MCLK_CGATE          | bit        | 1
|SMCLK Clock gate                             | SMCLK_CGATE         | bit        | 1
|Debug interface: CPU version                 | CPU_VERSION         | bit vector | 010
|Debug interface: Software breakpoint opcode  | DBG_SWBRK_OP        | bit vector | X4343
|UART interface auto data synchronization     | DBG_UART_AUTO_SYNC  | bit        | 1
|Counter width for the debug interface UART   | DBG_UART_XFER_CNT_W | integer    | 16
|Debug UART interface data rate               | DBG_UART_BAUD       | integer    | 2000000
|                                             | DBG_DCO_FREQ        | integer    | 20000000
|                                             | DBG_UART_CNT        | integer    | N
|                                             | DBG_UART_CNTB       | bit vector | N
|Debug interface input synchronizer           | SYNC_DBG_UART_RXD   | bit        | 1
|MULTIPLIER CONFIGURATION                     | MPY_16X16           | bit        | 1
