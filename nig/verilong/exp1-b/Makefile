# Output executable
OUT = rca

# Source files
SRC = full_adder.v ripple_carry_adder_4bit.v testbench.v

# .PHONY targets ensure rules always run
.PHONY: all compile run wave clean

# Default target
all: run

# Compile rule
compile:
	iverilog -o $(OUT) $(SRC)

# Run simulation
run: compile
	vvp $(OUT)

# Run and open waveform with gtkwave
wave: compile
	vvp $(OUT)
	gtkwave dump.vcd

# Clean build artifacts
clean:
	rm -f $(OUT) *.vcd
