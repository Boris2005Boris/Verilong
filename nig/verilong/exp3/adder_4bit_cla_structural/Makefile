OUT = cla_str
SRC = adder_4bit_cla.v testbench.v
.PHONY: all compile run wave clean
all: run
compile:
	iverilog -o $(OUT) $(SRC)
run: compile
	vvp $(OUT)
wave: compile
	vvp $(OUT)
	gtkwave dump.vcd
clean:
	rm -f $(OUT) *.vcd
