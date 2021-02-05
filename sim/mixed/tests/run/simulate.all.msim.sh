#!/bin/bash
source ../../../../settings64_msim.sh

# Disable waveform dumping
OMSP_NODUMP=1
export OMSP_NODUMP

# Choose simulator:
#                   - iverilog  : Icarus Verilog  (default)
#                   - msim      : ModelSim
#                   - isim      : Xilinx Simulator
OMSP_SIMULATOR=msim
export OMSP_SIMULATOR

rm -rf ./cov_work
rm -rf ./log/*.log
mkdir  ./log

# Two-Operand Arithmetic test patterns
../bin/msp430sim.sh two-op_mov               | tee ./log/two-op_mov.log
../bin/msp430sim.sh two-op_mov-b             | tee ./log/two-op_mov-b.log
../bin/msp430sim.sh two-op_add               | tee ./log/two-op_add.log
../bin/msp430sim.sh two-op_add-b             | tee ./log/two-op_add-b.log
../bin/msp430sim.sh two-op_addc              | tee ./log/two-op_addc.log
../bin/msp430sim.sh two-op_sub               | tee ./log/two-op_sub.log
../bin/msp430sim.sh two-op_subc              | tee ./log/two-op_subc.log
../bin/msp430sim.sh two-op_cmp               | tee ./log/two-op_cmp.log
../bin/msp430sim.sh two-op_bit               | tee ./log/two-op_bit.log
../bin/msp430sim.sh two-op_bic               | tee ./log/two-op_bic.log
../bin/msp430sim.sh two-op_bis               | tee ./log/two-op_bis.log
../bin/msp430sim.sh two-op_xor               | tee ./log/two-op_xor.log
../bin/msp430sim.sh two-op_and               | tee ./log/two-op_and.log
../bin/msp430sim.sh two-op_dadd              | tee ./log/two-op_dadd.log
../bin/msp430sim.sh two-op_autoincr          | tee ./log/two-op_autoincr.log
../bin/msp430sim.sh two-op_autoincr-b        | tee ./log/two-op_autoincr-b.log

# Conditional Jump test patterns
../bin/msp430sim.sh c-jump_jeq               | tee ./log/c-jump_jeq.log
../bin/msp430sim.sh c-jump_jne               | tee ./log/c-jump_jne.log
../bin/msp430sim.sh c-jump_jc                | tee ./log/c-jump_jc.log
../bin/msp430sim.sh c-jump_jnc               | tee ./log/c-jump_jnc.log
../bin/msp430sim.sh c-jump_jn                | tee ./log/c-jump_jn.log
../bin/msp430sim.sh c-jump_jge               | tee ./log/c-jump_jge.log
../bin/msp430sim.sh c-jump_jl                | tee ./log/c-jump_jl.log
../bin/msp430sim.sh c-jump_jmp               | tee ./log/c-jump_jmp.log

# Single-Operand Arithmetic test patterns
../bin/msp430sim.sh sing-op_rrc              | tee ./log/sing-op_rrc.log
../bin/msp430sim.sh sing-op_rra              | tee ./log/sing-op_rra.log
../bin/msp430sim.sh sing-op_swpb             | tee ./log/sing-op_swpb.log
../bin/msp430sim.sh sing-op_sxt              | tee ./log/sing-op_sxt.log
../bin/msp430sim.sh sing-op_push             | tee ./log/sing-op_push.log
../bin/msp430sim.sh sing-op_call             | tee ./log/sing-op_call.log

# Interrupts & NMI
../bin/msp430sim.sh sing-op_reti             | tee ./log/sing-op_reti.log
../bin/msp430sim.sh nmi                      | tee ./log/nmi.log
../bin/msp430sim.sh irq32                    | tee ./log/irq32.log
../bin/msp430sim.sh irq64                    | tee ./log/irq64.log

# ROM Data Read access
../bin/msp430sim.sh two-op_add_rom-rd        | tee ./log/two-op_add_rom-rd.log
../bin/msp430sim.sh sing-op_push_rom-rd      | tee ./log/sing-op_push_rom-rd.log
../bin/msp430sim.sh sing-op_call_rom-rd      | tee ./log/sing-op_call_rom-rd.log

# Power saving modes (CPUOFF, OSCOFF, SCG0, SCG1)
../bin/msp430sim.sh op_modes                 | tee ./log/op_modes.log
../bin/msp430sim.sh op_modes_asic            | tee ./log/op_modes_asic.log
../bin/msp430sim.sh lp_modes_asic            | tee ./log/lp_modes_asic.log
../bin/msp430sim.sh lp_modes_dbg_asic        | tee ./log/lp_modes_dbg_asic.log

# CPU startup conditions
../bin/msp430sim.sh cpu_startup_asic         | tee ./log/cpu_startup_asic.log

# Basic clock module
../bin/msp430sim.sh clock_module             | tee ./log/clock_module.log
../bin/msp430sim.sh clock_module_asic        | tee ./log/clock_module_asic.log
../bin/msp430sim.sh clock_module_asic_mclk   | tee ./log/clock_module_asic_mclk.log
../bin/msp430sim.sh clock_module_asic_smclk  | tee ./log/clock_module_asic_smclk.log
../bin/msp430sim.sh clock_module_asic_lfxt   | tee ./log/clock_module_asic_lfxt.log

# Serial Debug Interface (UART)
../bin/msp430sim.sh dbg_uart                 | tee ./log/dbg_uart.log
../bin/msp430sim.sh dbg_uart_sync            | tee ./log/dbg_uart_sync.log
../bin/msp430sim.sh dbg_uart_cpu             | tee ./log/dbg_uart_cpu.log
../bin/msp430sim.sh dbg_uart_mem             | tee ./log/dbg_uart_mem.log
../bin/msp430sim.sh dbg_uart_hwbrk0          | tee ./log/dbg_uart_hwbrk0.log
../bin/msp430sim.sh dbg_uart_hwbrk1          | tee ./log/dbg_uart_hwbrk1.log
../bin/msp430sim.sh dbg_uart_hwbrk2          | tee ./log/dbg_uart_hwbrk2.log
../bin/msp430sim.sh dbg_uart_hwbrk3          | tee ./log/dbg_uart_hwbrk3.log
../bin/msp430sim.sh dbg_uart_rdwr            | tee ./log/dbg_uart_rdwr.log
../bin/msp430sim.sh dbg_uart_halt_irq        | tee ./log/dbg_uart_halt_irq.log
../bin/msp430sim.sh dbg_uart_onoff           | tee ./log/dbg_uart_onoff.log
../bin/msp430sim.sh dbg_uart_onoff_asic      | tee ./log/dbg_uart_onoff_asic.log

# Serial Debug Interface (I2C)
../bin/msp430sim.sh dbg_i2c                  | tee ./log/dbg_i2c.log
../bin/msp430sim.sh dbg_i2c_sync             | tee ./log/dbg_i2c_sync.log
../bin/msp430sim.sh dbg_i2c_cpu              | tee ./log/dbg_i2c_cpu.log
../bin/msp430sim.sh dbg_i2c_mem              | tee ./log/dbg_i2c_mem.log
../bin/msp430sim.sh dbg_i2c_hwbrk0           | tee ./log/dbg_i2c_hwbrk0.log
../bin/msp430sim.sh dbg_i2c_hwbrk1           | tee ./log/dbg_i2c_hwbrk1.log
../bin/msp430sim.sh dbg_i2c_hwbrk2           | tee ./log/dbg_i2c_hwbrk2.log
../bin/msp430sim.sh dbg_i2c_hwbrk3           | tee ./log/dbg_i2c_hwbrk3.log
../bin/msp430sim.sh dbg_i2c_rdwr             | tee ./log/dbg_i2c_rdwr.log
../bin/msp430sim.sh dbg_i2c_halt_irq         | tee ./log/dbg_i2c_halt_irq.log
../bin/msp430sim.sh dbg_i2c_onoff            | tee ./log/dbg_i2c_onoff.log
../bin/msp430sim.sh dbg_i2c_onoff_asic       | tee ./log/dbg_i2c_onoff_asic.log

# SFR test patterns
../bin/msp430sim.sh sfr                      | tee ./log/sfr.log

# SCAN test patterns (only to increase coverage)
../bin/msp430sim.sh scan                     | tee ./log/scan.log

# Watchdog test patterns
../bin/msp430sim.sh wdt_interval             | tee ./log/wdt_interval.log
../bin/msp430sim.sh wdt_watchdog             | tee ./log/wdt_watchdog.log
../bin/msp430sim.sh wdt_clkmux               | tee ./log/wdt_clkmux.log
../bin/msp430sim.sh wdt_wkup                 | tee ./log/wdt_wkup.log

# GPIO test patterns
../bin/msp430sim.sh gpio_rdwr                | tee ./log/gpio_rdwr.log
../bin/msp430sim.sh gpio_irq                 | tee ./log/gpio_irq.log

# Peripheral templates test patterns
../bin/msp430sim.sh template_periph_8b       | tee ./log/template_periph_8b.log
../bin/msp430sim.sh template_periph_16b      | tee ./log/template_periph_16b.log

# Timer A patterns
../bin/msp430sim.sh tA_modes                 | tee ./log/tA_modes.log
../bin/msp430sim.sh tA_compare               | tee ./log/tA_compare.log
../bin/msp430sim.sh tA_output                | tee ./log/tA_output.log
../bin/msp430sim.sh tA_capture               | tee ./log/tA_capture.log
../bin/msp430sim.sh tA_clkmux                | tee ./log/tA_clkmux.log

# Simple full duplex UART (8N1 protocol)
#../bin/msp430sim.sh uart                    | tee ./log/uart.log


# Hardware multiplier test patterns
../bin/msp430sim.sh mpy_basic                | tee ./log/mpy_basic.log


# Report regression results
../bin/parse.results.sh
