# Clean Simulation Files
cd sim/mixed/baremetal/run/; sh clean.sh
cd ../../tests/run/; sh clean.sh
cd ../../../verilog/baremetal/run/; sh clean.sh
cd ../../tests/run/; sh clean.sh

# Clean Software Files
cd ../../../../software/baremetal/leds/; make clean
