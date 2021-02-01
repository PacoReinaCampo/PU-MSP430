all: build simulate

build:
	ghdl -a --std=08 ../../../../../rtl/vhdl/pkg/msp430_pkg.vhd
	
	ghdl -a --std=08 ../../../../../rtl/vhdl/core/fuse/msp430_and_gate.vhd
	ghdl -a --std=08 ../../../../../rtl/vhdl/core/fuse/msp430_clock_gate.vhd
	ghdl -a --std=08 ../../../../../rtl/vhdl/core/fuse/msp430_clock_mux.vhd
	ghdl -a --std=08 ../../../../../rtl/vhdl/core/fuse/msp430_scan_mux.vhd
	ghdl -a --std=08 ../../../../../rtl/vhdl/core/fuse/msp430_sync_cell.vhd
	ghdl -a --std=08 ../../../../../rtl/vhdl/core/fuse/msp430_sync_reset.vhd
	ghdl -a --std=08 ../../../../../rtl/vhdl/core/fuse/msp430_wakeup_cell.vhd

	ghdl -a --std=08 ../../../../../rtl/vhdl/core/omsp/msp430_alu.vhd
	ghdl -a --std=08 ../../../../../rtl/vhdl/core/omsp/msp430_dbg_hwbrk.vhd
	ghdl -a --std=08 ../../../../../rtl/vhdl/core/omsp/msp430_dbg_i2c.vhd
	ghdl -a --std=08 ../../../../../rtl/vhdl/core/omsp/msp430_dbg_uart.vhd
	ghdl -a --std=08 ../../../../../rtl/vhdl/core/omsp/msp430_register_file.vhd

	ghdl -a --std=08 ../../../../../rtl/vhdl/core/main/msp430_bcm.vhd
	ghdl -a --std=08 ../../../../../rtl/vhdl/core/main/msp430_dbg.vhd
	ghdl -a --std=08 ../../../../../rtl/vhdl/core/main/msp430_execution.vhd
	ghdl -a --std=08 ../../../../../rtl/vhdl/core/main/msp430_gpio.vhd
	ghdl -a --std=08 ../../../../../rtl/vhdl/core/main/msp430_memory.vhd
	ghdl -a --std=08 ../../../../../rtl/vhdl/core/main/msp430_multiplier.vhd
	ghdl -a --std=08 ../../../../../rtl/vhdl/core/main/msp430_template08.vhd
	ghdl -a --std=08 ../../../../../rtl/vhdl/core/main/msp430_template16.vhd
	ghdl -a --std=08 ../../../../../rtl/vhdl/core/main/msp430_uart.vhd

	ghdl -a --std=08 ../../../../../rtl/vhdl/core/main/msp430_frontend.vhd
	ghdl -a --std=08 ../../../../../rtl/vhdl/core/main/msp430_sfr.vhd
	ghdl -a --std=08 ../../../../../rtl/vhdl/core/main/msp430_ta.vhd
	ghdl -a --std=08 ../../../../../rtl/vhdl/core/main/msp430_watchdog.vhd

	ghdl -a --std=08 ../../../../../rtl/vhdl/pu/msp430_core.vhd

	ghdl -a --std=08 ../spram/core/msp430_ram.vhd

	ghdl -a --std=08 ../msp430_synthesis.vhd

simulate:
	ghdl -m --std=08 msp430_synthesis
	ghdl -r --std=08 msp430_synthesis --ieee-asserts=disable-at-0 --disp-tree=inst > msp430_synthesis.tree

clean:
	rm -f *.cf *.tree
