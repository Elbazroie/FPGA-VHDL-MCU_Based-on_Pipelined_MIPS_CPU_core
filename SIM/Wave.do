onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group MCU /mcu_tb/clock
add wave -noupdate -expand -group MCU /mcu_tb/reset
add wave -noupdate -expand -group MCU /mcu_tb/ena
add wave -noupdate -expand -group MCU /mcu_tb/SW
add wave -noupdate -expand -group MCU /mcu_tb/KEY
add wave -noupdate -expand -group MCU /mcu_tb/LEDR
add wave -noupdate -expand -group MCU /mcu_tb/HEX0
add wave -noupdate -expand -group MCU /mcu_tb/HEX1
add wave -noupdate -expand -group MCU /mcu_tb/HEX2
add wave -noupdate -expand -group MCU /mcu_tb/HEX3
add wave -noupdate -expand -group MCU /mcu_tb/HEX4
add wave -noupdate -expand -group MCU /mcu_tb/HEX5
add wave -noupdate -expand -group MCU /mcu_tb/BT_OUTMOD
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/C_CNT
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/S_CNT
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/F_CNT
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/PC
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/PCstall
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/IFflush
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/ID/register_array
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/Instruction_ID
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/read_data_1_ID
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/read_data_2_ID
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/write_data_ID
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/RegWrite_ID
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/Branch_ID
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/IDflush
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/Instruction_EX
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/Input_A_EX
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/Input_B_EX
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/ALU_result_EX
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/Zero_EX
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/address_MEM
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/Instruction_MEM
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/WData_MEM
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/RData_MEM
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/MemRead_MEM
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/Memwrite_MEM
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/Instruction_WB
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/MemtoReg_WB
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/forwardA_EX
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/forwardB_EX
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/dataBUS
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/addressBUS
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/INTR
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/INTA
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/GIE
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/ISR
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/ISR_EX_MEM
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/ISR_MEM_OUT
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/EPC_IF_ID
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/EPC_ID_EX
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/EPC_EX_MEM
add wave -noupdate -group CPU /mcu_tb/U_0/CPU_MIPS/EPC_MEM_OUT
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/Opcode
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/Function_opcode
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/RegDst
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/ALUSrc
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/MemtoReg
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/RegWrite
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/MemRead
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/MemWrite
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/Branch
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/ALU_ctl
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/jal
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/jr
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/jmp
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/clock
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/reset
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/R_format
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/Lw
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/Sw
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/Beq
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/Addi
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/slt
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/mov
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/jmpop
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/orop
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/shiftl
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/shiftr
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/add
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/sub
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/andop
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/xorop
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/jalop
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/jrop
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/mul
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/Bne
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/Andi
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/Ori
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/Xori
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/lui
add wave -noupdate -group CTL /mcu_tb/U_0/CPU_MIPS/CTL/slti
add wave -noupdate -group {CS DECODER} /mcu_tb/U_0/CS_DECODER/address
add wave -noupdate -group {CS DECODER} /mcu_tb/U_0/CS_DECODER/CS
add wave -noupdate -group BASIC_TIMER /mcu_tb/U_0/B_TIMER/OUT_SIGNAL
add wave -noupdate -group BASIC_TIMER /mcu_tb/U_0/B_TIMER/data
add wave -noupdate -group BASIC_TIMER /mcu_tb/U_0/B_TIMER/A0
add wave -noupdate -group BASIC_TIMER /mcu_tb/U_0/B_TIMER/CS
add wave -noupdate -group BASIC_TIMER /mcu_tb/U_0/B_TIMER/MemWrite
add wave -noupdate -group BASIC_TIMER /mcu_tb/U_0/B_TIMER/MemRead
add wave -noupdate -group BASIC_TIMER /mcu_tb/U_0/B_TIMER/BT_INT
add wave -noupdate -group BASIC_TIMER /mcu_tb/U_0/B_TIMER/OUTMOD
add wave -noupdate -group BASIC_TIMER /mcu_tb/U_0/B_TIMER/BTCCR1
add wave -noupdate -group BASIC_TIMER /mcu_tb/U_0/B_TIMER/BTCCR0
add wave -noupdate -group BASIC_TIMER /mcu_tb/U_0/B_TIMER/BTCCR1_W_EN
add wave -noupdate -group BASIC_TIMER /mcu_tb/U_0/B_TIMER/BTCCR0_W_EN
add wave -noupdate -group BASIC_TIMER /mcu_tb/U_0/B_TIMER/BTCCR1_R_EN
add wave -noupdate -group BASIC_TIMER /mcu_tb/U_0/B_TIMER/BTCCR0_R_EN
add wave -noupdate -group BASIC_TIMER /mcu_tb/U_0/B_TIMER/BTCNT_W_EN
add wave -noupdate -group BASIC_TIMER /mcu_tb/U_0/B_TIMER/BTCNT_R_EN
add wave -noupdate -group BASIC_TIMER /mcu_tb/U_0/B_TIMER/BTCTL_W_EN
add wave -noupdate -group BASIC_TIMER /mcu_tb/U_0/B_TIMER/BTCTL_R_EN
add wave -noupdate -group BASIC_TIMER /mcu_tb/U_0/B_TIMER/BTCL0
add wave -noupdate -group BASIC_TIMER /mcu_tb/U_0/B_TIMER/BTCL1
add wave -noupdate -group BASIC_TIMER /mcu_tb/U_0/B_TIMER/BTCNT
add wave -noupdate -group BASIC_TIMER /mcu_tb/U_0/B_TIMER/BTCTL
add wave -noupdate -group BASIC_TIMER /mcu_tb/U_0/B_TIMER/Q_SEL
add wave -noupdate -group BASIC_TIMER /mcu_tb/U_0/B_TIMER/CLK
add wave -noupdate -group BASIC_TIMER /mcu_tb/U_0/B_TIMER/clock_8
add wave -noupdate -group BASIC_TIMER /mcu_tb/U_0/B_TIMER/clock_4
add wave -noupdate -group BASIC_TIMER /mcu_tb/U_0/B_TIMER/clock_2
add wave -noupdate -group BASIC_TIMER /mcu_tb/U_0/B_TIMER/BTOUTEN
add wave -noupdate -group BASIC_TIMER /mcu_tb/U_0/B_TIMER/BTHOLD
add wave -noupdate -group BASIC_TIMER /mcu_tb/U_0/B_TIMER/BTSSEL
add wave -noupdate -group BASIC_TIMER /mcu_tb/U_0/B_TIMER/BTIP
add wave -noupdate -group {INTERRUPT CONTROLLER} /mcu_tb/U_0/INTERR/NMI
add wave -noupdate -group {INTERRUPT CONTROLLER} /mcu_tb/U_0/INTERR/data
add wave -noupdate -group {INTERRUPT CONTROLLER} /mcu_tb/U_0/INTERR/A0
add wave -noupdate -group {INTERRUPT CONTROLLER} /mcu_tb/U_0/INTERR/A1
add wave -noupdate -group {INTERRUPT CONTROLLER} /mcu_tb/U_0/INTERR/CS
add wave -noupdate -group {INTERRUPT CONTROLLER} /mcu_tb/U_0/INTERR/INT_SRC
add wave -noupdate -group {INTERRUPT CONTROLLER} /mcu_tb/U_0/INTERR/INTR
add wave -noupdate -group {INTERRUPT CONTROLLER} /mcu_tb/U_0/INTERR/INTA
add wave -noupdate -group {INTERRUPT CONTROLLER} /mcu_tb/U_0/INTERR/GIE
add wave -noupdate -group {INTERRUPT CONTROLLER} /mcu_tb/U_0/INTERR/MemWrite
add wave -noupdate -group {INTERRUPT CONTROLLER} /mcu_tb/U_0/INTERR/MemRead
add wave -noupdate -group {INTERRUPT CONTROLLER} /mcu_tb/U_0/INTERR/PEND
add wave -noupdate -group {INTERRUPT CONTROLLER} /mcu_tb/U_0/INTERR/PRIORITY
add wave -noupdate -group {INTERRUPT CONTROLLER} /mcu_tb/U_0/INTERR/NMI_IRQ
add wave -noupdate -group {INTERRUPT CONTROLLER} /mcu_tb/U_0/INTERR/NMI_CLR
add wave -noupdate -group {INTERRUPT CONTROLLER} /mcu_tb/U_0/INTERR/IE
add wave -noupdate -group {INTERRUPT CONTROLLER} /mcu_tb/U_0/INTERR/IE_W_EN
add wave -noupdate -group {INTERRUPT CONTROLLER} /mcu_tb/U_0/INTERR/IE_R_EN
add wave -noupdate -group {INTERRUPT CONTROLLER} /mcu_tb/U_0/INTERR/IRQ
add wave -noupdate -group {INTERRUPT CONTROLLER} /mcu_tb/U_0/INTERR/IRQ_CLR
add wave -noupdate -group {INTERRUPT CONTROLLER} /mcu_tb/U_0/INTERR/IFG
add wave -noupdate -group {INTERRUPT CONTROLLER} /mcu_tb/U_0/INTERR/IFG_W_EN
add wave -noupdate -group {INTERRUPT CONTROLLER} /mcu_tb/U_0/INTERR/IFG_R_EN
add wave -noupdate -group {INTERRUPT CONTROLLER} /mcu_tb/U_0/INTERR/ITR
add wave -noupdate -group {INTERRUPT CONTROLLER} /mcu_tb/U_0/INTERR/ITR_W_EN
add wave -noupdate -group {INTERRUPT CONTROLLER} /mcu_tb/U_0/INTERR/ITR_R_EN
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {137500 ps} 0} {{Cursor 2} {417762500 ps} 0} {{Cursor 3} {585486898 ps} 0} {{Cursor 4} {436041032 ps} 0}
quietly wave cursor active 3
configure wave -namecolwidth 274
configure wave -valuecolwidth 270
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1050 us}
