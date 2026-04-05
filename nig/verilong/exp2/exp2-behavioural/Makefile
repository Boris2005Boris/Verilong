# Output executable
OUT = barrel

# Source files
SRC = barrel_shifter.v testbench.v

# .PHONY targets
.PHONY: all compile run wave clean

# Default target
all: run

# Compile
compile:
	iverilog -o $(OUT) $(SRC)

# Run simulation
run: compile
	vvp $(OUT)

# Waveform view
wave: compile
	vvp $(OUT)
	gtkwave dump.vcd

# Clean
clean:
	rm -f $(OUT) *.vcd
