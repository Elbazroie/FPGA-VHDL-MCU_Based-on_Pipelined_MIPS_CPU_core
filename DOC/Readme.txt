Final Project - MCU

This VHDL design includes Microcontroller UNIT based on MIPS PIPELINE CPU with one Delay slot architecture.

	The MCU design includes modules such as GPIO (LEDR,HEX0-5,SWITCH,KEYS), Basic Timer with OUTMOD capabilities and
	Interrupt controller Module with up to 5 PRIORITY interrupts (KEYS0-3, BASIC TIMER, NMI).

	The MIPS PIPLLINE design also includes HAZARD and forwarding unit that support stall and flush, to deal with RAW and control hazards (branch), and 
	added HARDWARE exclusively for INTERRUPT capabilities.
	the entire ISA supported included in the control.vhd file.

The design has been compiled and loaded to the FPGA Altera board for testing