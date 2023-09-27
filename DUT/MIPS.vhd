				-- Top Level Structural Model for MIPS Processor Core
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.std_logic_unsigned.ALL;
ENTITY MIPS IS
	GENERIC ( ALIGNMENT : BOOLEAN := FALSE ); -- WORD/BYTE alignment: FALSE = QUARTUS ; TRUE = ModelSim
	PORT( reset, clock, ena					: IN 	STD_LOGIC; 
	-- General
		C_CNT								: OUT   STD_LOGIC_VECTOR( 15 DOWNTO 0 );	
		S_CNT								: OUT   STD_LOGIC_VECTOR( 7  DOWNTO 0 );	
		F_CNT								: OUT   STD_LOGIC_VECTOR( 7  DOWNTO 0 );	
	--IF
		PC									: OUT   STD_LOGIC_VECTOR( 9  DOWNTO 0 );
		PCstall								: OUT 	STD_LOGIC;
		IFflush								: OUT 	STD_LOGIC;
	--ID	
		Instruction_ID						: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		read_data_1_ID						: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		read_data_2_ID						: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		write_data_ID						: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		RegWrite_ID							: OUT 	STD_LOGIC;
		Branch_ID 							: OUT 	STD_LOGIC;
		IDflush								: OUT 	STD_LOGIC;		
	--EX	
		Instruction_EX						: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );	
		Input_A_EX 							: OUT   STD_LOGIC_VECTOR( 31 DOWNTO 0 );	
		Input_B_EX							: OUT   STD_LOGIC_VECTOR( 31 DOWNTO 0 );	
		ALU_result_EX						: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		Zero_EX								: OUT 	STD_LOGIC;
	--MEM	
		address_MEM							: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );	
		Instruction_MEM						: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );		
		WData_MEM							: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		RData_MEM							: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );		
		MemRead_MEM							: OUT 	STD_LOGIC;
		Memwrite_MEM						: OUT 	STD_LOGIC;
	--WB	
		Instruction_WB						: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		MemtoReg_WB							: OUT 	STD_LOGIC; 
	--Forward		
		forwardA_EX 						: OUT 	STD_LOGIC_VECTOR( 1  DOWNTO 0 );	
		forwardB_EX 						: OUT 	STD_LOGIC_VECTOR( 1  DOWNTO 0 );
	--Intrerrupt			
     	dataBUS								: INOUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );		
     	addressBUS							: OUT 	STD_LOGIC_VECTOR( 11 DOWNTO 0 );
		INTR 								: IN 	STD_LOGIC; 
		INTA								: OUT	STD_LOGIC; 
		GIE									: OUT	STD_LOGIC  );
END MIPS;

ARCHITECTURE structure OF MIPS IS
------------------------------- DECLARE MIPS COMPONENTS ---------------------------------
	COMPONENT Ifetch
		 GENERIC ( ALIGNMENT : BOOLEAN );
   	     PORT(	Instruction 	: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				PC_plus_4_out 	: OUT	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
				Add_result 		: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
				Taken 			: IN 	STD_LOGIC;
				PCstall			: IN 	STD_LOGIC;
				IF_ID_stall		: IN 	STD_LOGIC;
				jr,jal,jmp		: IN	STD_LOGIC;
				jr_data,jmp_data: IN	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
				PC_out 			: OUT	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
				IF_ID_ctl_flush	: IN 	STD_LOGIC;	
				ISR 			: IN	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
				EPC_out			: OUT   STD_LOGIC_VECTOR( 7  DOWNTO 0 );	
				INTR		    : IN	STD_LOGIC; 					
				clock, reset,ena: IN 	STD_LOGIC);
	END COMPONENT; 

	COMPONENT Idecode
		  PORT(	read_data_1	 			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				read_data_2				: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				register_1_address 		: OUT 	STD_LOGIC_VECTOR( 4  DOWNTO 0 );
				register_2_address 		: OUT 	STD_LOGIC_VECTOR( 4  DOWNTO 0 );
				rt_ID					: OUT   STD_LOGIC_VECTOR( 4  DOWNTO 0 );
				rs_ID					: OUT   STD_LOGIC_VECTOR( 4  DOWNTO 0 );
				register_rs_address		: OUT 	STD_LOGIC_VECTOR( 4  DOWNTO 0 );
				write_register_address  : IN	STD_LOGIC_VECTOR( 4  DOWNTO 0 );			
				PC_plus_4    			: IN	STD_LOGIC_VECTOR( 9  DOWNTO 0 );
				Instruction  			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				read_data 	 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				regWdata				: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );				
				ALU_result	 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );	
				FWD_OUT_WB	 			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );				
				RegDst 					: IN 	STD_LOGIC;
				ALUSrc 					: IN 	STD_LOGIC;
				MemtoReg 				: IN 	STD_LOGIC;
				RegWrite 				: IN 	STD_LOGIC;
				RegWriteRF 				: IN 	STD_LOGIC;			
				MemRead 				: IN 	STD_LOGIC;
				MemWrite 				: IN 	STD_LOGIC;
				Branch 					: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
				ALU_ctl 				: IN 	STD_LOGIC_VECTOR( 3 DOWNTO 0 );
				RegDst_out 				: OUT 	STD_LOGIC;
				ALUSrc_out 				: OUT 	STD_LOGIC;
				MemtoReg_out 			: OUT 	STD_LOGIC;
				RegWrite_out 			: OUT 	STD_LOGIC;
				MemRead_out 			: OUT 	STD_LOGIC;
				MemWrite_out 			: OUT 	STD_LOGIC;
				ALU_ctl_out 			: OUT 	STD_LOGIC_VECTOR( 3  DOWNTO 0 );
				Sign_extend  			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				Branch_Address 			: OUT   STD_LOGIC_VECTOR( 7  DOWNTO 0 );			
				MemtoRegWB 				: IN 	STD_LOGIC;		
				jal,jr,jmp				: IN 	STD_LOGIC;
				ID_EX_ctl_flush			: IN 	STD_LOGIC;	
				Taken					: OUT 	STD_LOGIC;	
				jr_data,jmp_data	    : OUT	STD_LOGIC_VECTOR( 7  DOWNTO 0 );	
				TYPE_MEM				: IN 	STD_LOGIC_VECTOR( 7  DOWNTO 0 );
				EPC						: IN    STD_LOGIC_VECTOR( 7  DOWNTO 0 );			
				EPC_out					: OUT   STD_LOGIC_VECTOR( 7  DOWNTO 0 );
				EPC_WB					: IN    STD_LOGIC_VECTOR( 7  DOWNTO 0 );					
				ISR 			 		: IN	STD_LOGIC_VECTOR( 1  DOWNTO 0 ); 
				INTR 			 		: IN	STD_LOGIC; 			
				GIE						: OUT	STD_LOGIC; 			
				clock,reset,ena			: IN 	STD_LOGIC );
	END COMPONENT;

	COMPONENT control
		PORT(   Opcode 			: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
				Function_opcode : IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
				RegDst 			: OUT 	STD_LOGIC;
				ALUSrc 			: OUT 	STD_LOGIC;
				MemtoReg 		: OUT 	STD_LOGIC;
				RegWrite 		: OUT 	STD_LOGIC;
				MemRead 		: OUT 	STD_LOGIC;
				MemWrite 		: OUT 	STD_LOGIC;
				Branch 			: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
				ALU_ctl 		: OUT 	STD_LOGIC_VECTOR( 3 DOWNTO 0 );
				jal,jr,jmp		: OUT 	STD_LOGIC;
				clock, reset	: IN 	STD_LOGIC );
	END COMPONENT;

	COMPONENT  Execute
		PORT(	Read_data_1 	 	  : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				Read_data_2 	 	  : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				write_data_2	  	  : IN 	STD_LOGIC_VECTOR( 4  DOWNTO 0 );
				write_data_1	  	  : IN 	STD_LOGIC_VECTOR( 4  DOWNTO 0 );
				write_data_rs	  	  : IN 	STD_LOGIC_VECTOR( 4  DOWNTO 0 );
				FWD_MEM			  	  : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				FWD_WB				  : IN  STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				forwardA			  : IN  STD_LOGIC_VECTOR( 1  DOWNTO 0 );
				forwardB			  : IN  STD_LOGIC_VECTOR( 1  DOWNTO 0 );
				rs_EX	  	 		  : OUT STD_LOGIC_VECTOR( 4  DOWNTO 0 );
				rt_EX	  	 		  : OUT STD_LOGIC_VECTOR( 4  DOWNTO 0 );	
				des_EX				  : OUT STD_LOGIC_VECTOR( 4  DOWNTO 0 );				
				write_data_mem    	  : OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );			
				write_reg_address_out : OUT	STD_LOGIC_VECTOR( 4  DOWNTO 0 );
				Sign_extend 	  	  : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				A_data		 	  	  : OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );	
				B_data		 	  	  : OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );				
				ALU_ctl 		  	  : IN 	STD_LOGIC_VECTOR( 3  DOWNTO 0 );
				ALUSrc 			  	  : IN 	STD_LOGIC;
				RegDst 			  	  : IN 	STD_LOGIC;
				MemtoReg 		  	  : IN 	STD_LOGIC;
				RegWrite 		 	  : IN 	STD_LOGIC;						
				MemRead 		  	  : IN 	STD_LOGIC;
				MemWrite 		  	  : IN 	STD_LOGIC;		
				MemtoReg_out 	  	  : OUT STD_LOGIC;
				RegWrite_out 	  	  : OUT	STD_LOGIC;						
				MemRead_out 	  	  : OUT	STD_LOGIC;
				MemWrite_out      	  : OUT	STD_LOGIC;			
				Zero_out 		  	  : OUT	STD_LOGIC;
				ALU_Res			  	  : OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );	
				ALU_Result_out	  	  : OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				ISR 				  : IN	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
				ISR_out 			  : OUT	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
				EPC					  : IN  STD_LOGIC_VECTOR( 7  DOWNTO 0 );
				INTR 			 	  : IN	STD_LOGIC; 							
				EPC_out				  : OUT STD_LOGIC_VECTOR( 7  DOWNTO 0 );	
				clock, reset, ena 	  : IN 	STD_LOGIC );
	END COMPONENT;


	COMPONENT dmemory
		GENERIC ( ALIGNMENT : BOOLEAN );
		PORT(	read_data 			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				address 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				FWD_OUT_MEM			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );			
				write_data 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				write_reg			: IN	STD_LOGIC_VECTOR( 4  DOWNTO 0 );
				write_reg_out		: OUT	STD_LOGIC_VECTOR( 4  DOWNTO 0 );
				ALU_out				: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				MEM_Rdata			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );				
				MemRead			 	: IN 	STD_LOGIC;
				Memwrite 			: IN 	STD_LOGIC;
				MemtoReg 			: IN 	STD_LOGIC;
				RegWrite 			: IN 	STD_LOGIC;				
				MemtoReg_out 		: OUT 	STD_LOGIC;
				RegWrite_out 		: OUT 	STD_LOGIC;	
				dataBUS 			: INOUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );			
				ISR 				: IN	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
				ISR_out 			: OUT	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
				EPC					: IN    STD_LOGIC_VECTOR( 7  DOWNTO 0 );			
				EPC_out				: OUT   STD_LOGIC_VECTOR( 7  DOWNTO 0 );					
				clock,reset, ena	: IN 	STD_LOGIC );
	END COMPONENT;

	COMPONENT FORWARD
		 PORT(  rd_MEM, rd_WB, rs_EX, rt_EX  	 : IN  STD_LOGIC_VECTOR( 4 DOWNTO 0 );
				RegWrite_EX_MEM, RegWrite_MEM_WB : IN  STD_LOGIC;				
				forwardA_EX, forwardB_EX         : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) );				
	END COMPONENT;

	COMPONENT HAZARD IS
		PORT(   rs_ID,rt_ID, des_EX,des_MEM	    : IN    STD_LOGIC_VECTOR( 4 DOWNTO 0 );
				MemRead_EX, MemRead_MEM         : IN    STD_LOGIC;
				MemRead_WB			            : IN    STD_LOGIC;
				MemWrite_EX       				: IN    STD_LOGIC;
				RegWrite_EX, RegWrite_MEM		: IN    STD_LOGIC;
				Branch 							: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );					
				Taken                   		: IN    STD_LOGIC;
				jal,jr,jmp						: IN 	STD_LOGIC;		
				IF_ID_ctl_flush					: OUT 	STD_LOGIC;			
				ID_EX_ctl_flush					: OUT 	STD_LOGIC;	
				PCstall							: OUT 	STD_LOGIC;
				IF_ID_stall						: OUT 	STD_LOGIC );
	END COMPONENT;	
--------------------- declare signals used to connect VHDL components ----------------------
	-- General 					
	SIGNAL Inst_ID_EX				: STD_LOGIC_VECTOR( 31 DOWNTO 0 );	
	SIGNAL Inst_EX_MEM 				: STD_LOGIC_VECTOR( 31 DOWNTO 0 );	
	SIGNAL Inst_MEM_WB				: STD_LOGIC_VECTOR( 31 DOWNTO 0 );	
	SIGNAL clockCNT					: STD_LOGIC_VECTOR( 15 DOWNTO 0 );	
	SIGNAL stallCNT					: STD_LOGIC_VECTOR( 7  DOWNTO 0 );	
	SIGNAL flushCNT					: STD_LOGIC_VECTOR( 7  DOWNTO 0 );		
	-- IF
	SIGNAL PC_plus_4_IF_ID 			: STD_LOGIC_VECTOR( 9  DOWNTO 0 );
	SIGNAL Instruction_IF_ID 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );		
	SIGNAL Zero_MEM					: STD_LOGIC;	
	SIGNAL PC_OUT_IF_ID 			: STD_LOGIC_VECTOR( 9  DOWNTO 0 );
	SIGNAL jr_data, jmp_data		: STD_LOGIC_VECTOR( 7  DOWNTO 0 );
	SIGNAL jr,jmp,jal				: STD_LOGIC;	
	SIGNAL Taken					: STD_LOGIC;	
	-- ID
	SIGNAL read_data_rs	 			: STD_LOGIC_VECTOR( 31 DOWNTO 0 );	
	SIGNAL read_data_rt	 			: STD_LOGIC_VECTOR( 31 DOWNTO 0 );	
	SIGNAL register_1_address		: STD_LOGIC_VECTOR( 4  DOWNTO 0 );	
	SIGNAL register_2_address		: STD_LOGIC_VECTOR( 4  DOWNTO 0 );
	SIGNAL register_rs_address		: STD_LOGIC_VECTOR( 4  DOWNTO 0 );
	SIGNAL write_register_address	: STD_LOGIC_VECTOR( 4  DOWNTO 0 );
	SIGNAL regWdata					: STD_LOGIC_VECTOR( 31 DOWNTO 0 );	
	SIGNAL read_data_WB_ID	 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );	
	SIGNAL ALU_result_WB_ID	 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Sign_extend 				: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL MemtoRegWB 				: STD_LOGIC;	
	SIGNAL RegDst_ID_EX				: STD_LOGIC;	
	SIGNAL ALUSrc_ID_EX				: STD_LOGIC;		
	SIGNAL MemtoReg_ID_EX			: STD_LOGIC;		
	SIGNAL RegWrite_ID_EX			: STD_LOGIC;	
	SIGNAL MemRead_ID_EX			: STD_LOGIC;		
	SIGNAL MemWrite_ID_EX			: STD_LOGIC;	
	SIGNAL ALU_ctl_ID_EX 			: STD_LOGIC_VECTOR( 3  DOWNTO 0 );
	SIGNAL RegWriteRF 				: STD_LOGIC;	
	-- EX
	SIGNAL read_data_EX_MEM	 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );	
	SIGNAL A_data			 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );	
	SIGNAL B_data			 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );		
	SIGNAL rs_EX				 	: STD_LOGIC_VECTOR( 4  DOWNTO 0 );	
	SIGNAL rt_EX				 	: STD_LOGIC_VECTOR( 4  DOWNTO 0 );
	SIGNAL des_EX				  	: STD_LOGIC_VECTOR( 4  DOWNTO 0 );	
	SIGNAL write_reg_address_EX_MEM : STD_LOGIC_VECTOR( 4  DOWNTO 0 );			
	SIGNAL MemtoReg_EX_MEM			: STD_LOGIC;		
	SIGNAL RegWrite_EX_MEM			: STD_LOGIC;	
	SIGNAL MemRead_EX_MEM			: STD_LOGIC;		
	SIGNAL MemWrite_EX_MEM			: STD_LOGIC;	
	SIGNAL ALU_result_EX_MEM		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );	
	SIGNAL ADD_result_Br			: STD_LOGIC_VECTOR( 7  DOWNTO 0 );
	SIGNAL ALU_R			  	  	: STD_LOGIC_VECTOR( 31 DOWNTO 0 );	
	-- MEM
	SIGNAL FWD_MEM 					: STD_LOGIC_VECTOR( 31 DOWNTO 0 );	
	SIGNAL FWD_WB 					: STD_LOGIC_VECTOR( 31 DOWNTO 0 );		
	SIGNAL MEM_Rdata				: STD_LOGIC_VECTOR( 31 DOWNTO 0 );		
	--Control				
	SIGNAL RegDst_CTL				: STD_LOGIC;	
	SIGNAL ALUSrc_CTL				: STD_LOGIC;		
	SIGNAL MemtoReg_CTL				: STD_LOGIC;		
	SIGNAL RegWrite_CTL				: STD_LOGIC;	
	SIGNAL MemRead_CTL				: STD_LOGIC;		
	SIGNAL MemWrite_CTL				: STD_LOGIC;	
	SIGNAL Branch_CTL				: STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL ALU_ctl_CTL 				: STD_LOGIC_VECTOR( 3 DOWNTO 0 );
	--Forward					
	SIGNAL forwardA_E				: STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL forwardB_E 				: STD_LOGIC_VECTOR( 1 DOWNTO 0 );		
	--Hazard						
	SIGNAL PC_stall				    : STD_LOGIC;	
	SIGNAL IF_ID_stall				: STD_LOGIC;		
	SIGNAL IF_ID_ctl_flush		    : STD_LOGIC;
	SIGNAL ID_EX_ctl_flush			: STD_LOGIC;	
	SIGNAL rt_ID					: STD_LOGIC_VECTOR( 4  DOWNTO 0 );
	SIGNAL rs_ID					: STD_LOGIC_VECTOR( 4  DOWNTO 0 );	
	--Interrupt						
	SIGNAL GIE_out					: STD_LOGIC; 		
	SIGNAL INTA_out				    : STD_LOGIC;	
	SIGNAL ISR						: STD_LOGIC_VECTOR( 1  DOWNTO 0 );	
	SIGNAL ISR_EX_MEM				: STD_LOGIC_VECTOR( 1  DOWNTO 0 );
	SIGNAL ISR_MEM_OUT				: STD_LOGIC_VECTOR( 1  DOWNTO 0 );	
	SIGNAL EPC_IF_ID		    	: STD_LOGIC_VECTOR( 7  DOWNTO 0 );
	SIGNAL EPC_ID_EX		    	: STD_LOGIC_VECTOR( 7  DOWNTO 0 );
	SIGNAL EPC_EX_MEM		    	: STD_LOGIC_VECTOR( 7  DOWNTO 0 );
	SIGNAL EPC_MEM_OUT			   	: STD_LOGIC_VECTOR( 7  DOWNTO 0 );

BEGIN
--------------------------------- Connect MIPS output signals ---------------------------
-- General
	C_CNT				 <=  clockCNT;
	S_CNT				 <=  stallCNT;
	F_CNT				 <=  flushCNT;
-- IF
	PC 				<=   PC_OUT_IF_ID;
	PCstall			<=   PC_stall;
	IFflush			<=	 IF_ID_ctl_flush;
-- ID
	read_data_1_ID  <=   read_data_rs;
	read_data_2_ID  <=   read_data_rt;
	write_data_ID   <=   regWdata;
	Instruction_ID  <=   Instruction_IF_ID;
	RegWrite_ID		<=	 RegWriteRF;
	Branch_ID 		<=   '1' WHEN Branch_CTL(0) = '1' OR Branch_CTL(1) = '1' ELSE '0'; -- Show Branch Operation
	IDflush			<=   ID_EX_ctl_flush;
-- EX	
	Instruction_EX	<=	 Inst_ID_EX;
	Input_A_EX 		<=	 A_data;	
	Input_B_EX		<=	 B_data;	
	ALU_result_EX 	<=   ALU_R;
	Zero_EX 		<=   Zero_MEM;
-- MEM	
	Instruction_MEM	<=	 Inst_EX_MEM;	
	Memwrite_MEM 	<=   MemWrite_EX_MEM;
	MemRead_MEM 	<=   MemRead_EX_MEM;
	WData_MEM 		<=   read_data_EX_MEM; 
	RData_MEM 		<=   MEM_Rdata;	
	address_MEM 	<=   FWD_MEM;	
-- WB	
	Instruction_WB	<=	 Inst_MEM_WB;	
	MemtoReg_WB		<=	 MemtoRegWB;
-- Forward		
	forwardA_EX 	<=   forwardA_E;
	forwardB_EX 	<=   forwardB_E;
--Interrupt		
	addressBUS		<=   ALU_result_EX_MEM( 11 DOWNTO 0);  
	GIE 			<=   GIE_out;
	INTA 			<=   INTA_out;	
	
--------------------------- Connect all MIPS components with portmap ------------------------------  											
  IFE : Ifetch
  	GENERIC MAP ( ALIGNMENT => ALIGNMENT )
	PORT MAP (	Instruction 	=> Instruction_IF_ID,
    	    	PC_plus_4_out 	=> PC_plus_4_IF_ID,
				Add_result 		=> ADD_result_Br,
				Taken 			=> Taken,
				PCstall 		=> PC_stall,
				IF_ID_stall		=> IF_ID_stall,
				IF_ID_ctl_flush => IF_ID_ctl_flush,
				jr				=> jr, 		
				jmp				=> jmp, 		
				jal				=> jal, 		
				jmp_data		=> jmp_data,
				jr_data			=> jr_data, 
				PC_out 			=> PC_OUT_IF_ID, 
				ISR 			=> ISR_MEM_OUT,
				EPC_out			=> EPC_IF_ID,
				INTR		    => INTR,		
				ena 			=> ena,
				clock 			=> clock,  
				reset 			=> reset );
			
   ID : Idecode
   	PORT MAP (	read_data_1 			=> read_data_rs,
        		read_data_2 			=> read_data_rt,
				register_1_address		=> register_1_address,
				register_2_address		=> register_2_address,
				register_rs_address 	=> register_rs_address,
				write_register_address  => write_register_address,
				PC_plus_4				=> PC_plus_4_IF_ID,
        		Instruction 			=> Instruction_IF_ID,
        		read_data 				=> read_data_WB_ID,
				regWdata				=> regWdata,
				ALU_result 				=> ALU_result_WB_ID,	
				FWD_OUT_WB	 			=> FWD_WB,				
				RegDst	 				=> RegDst_CTL,
				ALUSrc 					=> ALUSrc_CTL,
				MemtoReg				=> MemtoReg_CTL,
				RegWrite				=> RegWrite_CTL,
				RegWriteRF 				=> RegWriteRF,
				MemRead					=> MemRead_CTL,
				MemWrite				=> MemWrite_CTL,
				Branch					=> Branch_CTL,
				ALU_ctl					=> ALU_ctl_CTL,
				RegDst_out	 			=> RegDst_ID_EX,
				ALUSrc_out 				=> ALUSrc_ID_EX,
				MemtoReg_out			=> MemtoReg_ID_EX,
				RegWrite_out			=> RegWrite_ID_EX,
				MemRead_out				=> MemRead_ID_EX,
				MemWrite_out			=> MemWrite_ID_EX,
				ALU_ctl_out				=> ALU_ctl_ID_EX,	
				Sign_extend				=> Sign_extend,	
				Branch_Address			=> ADD_result_Br,
				MemtoRegWB				=> MemtoRegWB,	
				jr 						=> jr,
				jmp 					=> jmp,
				jal 					=> jal,	
				rt_ID					=> rt_ID,
				rs_ID					=> rs_ID,				
				ID_EX_ctl_flush         => ID_EX_ctl_flush,
				Taken 					=> Taken,
				jr_data					=> jr_data, 
				jmp_data				=> jmp_data, 
				TYPE_MEM				=> MEM_Rdata (9 DOWNTO 2),
				EPC						=> EPC_IF_ID,
				EPC_out					=> EPC_ID_EX,	
				EPC_WB					=> EPC_MEM_OUT,	
				ISR 			 		=> ISR_MEM_OUT,
				GIE						=> GIE_out,	
				INTR 			 		=> INTR,				
				ena 					=> ena,	
        		clock 					=> clock, 
				reset 					=> reset  );

   CTL:   control
	PORT MAP ( 	Opcode 			=> Instruction_IF_ID( 31 DOWNTO 26 ),
				Function_opcode => Instruction_IF_ID( 5  DOWNTO 0 ),
				RegDst 			=> RegDst_CTL,
				ALUSrc 			=> ALUSrc_CTL,
				MemtoReg 		=> MemtoReg_CTL,
				RegWrite 		=> RegWrite_CTL,
				MemRead 		=> MemRead_CTL,
				MemWrite 		=> MemWrite_CTL,
				Branch 			=> Branch_CTL,
				ALU_ctl 		=> ALU_ctl_CTL,
				jr 				=> jr,
				jmp 			=> jmp,
				jal 			=> jal,
                clock 			=> clock,
				reset 			=> reset );
				
   EXE:  Execute
   	PORT MAP (	Read_data_1 			=> read_data_rs,
             	Read_data_2 			=> read_data_rt,
				write_data_2			=> register_2_address,
				write_data_1			=> register_1_address,
				FWD_MEM				    => FWD_MEM,
				FWD_WB					=> FWD_WB,		
				rs_EX					=> rs_EX,
				rt_EX					=> rt_EX,
				des_EX					=> des_EX,
				forwardA			 	=> forwardA_E,
				forwardB			 	=> forwardB_E,
				write_data_rs			=> register_rs_address,
				write_data_mem			=> read_data_EX_MEM,
				write_reg_address_out   => write_reg_address_EX_MEM,
				Sign_extend				=> Sign_extend,
				A_data		 	  	 	=> A_data,	
				B_data		 	  	    => B_data,
				ALU_ctl					=> ALU_ctl_ID_EX,
				ALUSrc					=> ALUSrc_ID_EX,
				RegDst					=> RegDst_ID_EX,
				MemtoReg				=> MemtoReg_ID_EX,
				RegWrite				=> RegWrite_ID_EX,
				MemRead					=> MemRead_ID_EX,
				MemWrite				=> MemWrite_ID_EX,
				MemtoReg_out			=> MemtoReg_EX_MEM,
				RegWrite_out			=> RegWrite_EX_MEM,				
				MemRead_out 			=> MemRead_EX_MEM,
				MemWrite_out 			=> MemWrite_EX_MEM, 
				Zero_out 		 		=> Zero_MEM,
				ALU_Res 		 		=> ALU_R,
				ALU_Result_out	  	  	=> ALU_result_EX_MEM,
				ISR 				    => ISR,
				ISR_out 			    => ISR_EX_MEM,
				EPC					    => EPC_ID_EX,			
				EPC_out				    => EPC_EX_MEM,	
				INTR 			 	    => INTR, 			
				ena 					=> ena,				
                Clock					=> clock,
				Reset					=> reset );				

   MEM:  dmemory
    GENERIC MAP ( ALIGNMENT => ALIGNMENT )
	PORT MAP (	read_data		=> read_data_WB_ID,
				address 		=> ALU_result_EX_MEM,
				FWD_OUT_MEM		=> FWD_MEM,
				write_data 		=> read_data_EX_MEM,
				write_reg		=> write_reg_address_EX_MEM,
				write_reg_out	=> write_register_address,
				ALU_out			=> ALU_result_WB_ID,
				MemRead 		=> MemRead_EX_MEM,	
				MEM_Rdata		=> MEM_Rdata,							
				Memwrite 		=> MemWrite_EX_MEM, 
				MemtoReg 		=> MemtoReg_EX_MEM, 
				RegWrite 		=> RegWrite_EX_MEM, 	  
				MemtoReg_out 	=> MemtoRegWB,
				RegWrite_out 	=> RegWriteRF,
				dataBUS 		=> dataBUS,		
				ISR 			=> ISR_EX_MEM,
				ISR_out 		=> ISR_MEM_OUT,
				EPC				=> EPC_EX_MEM,		
				EPC_out			=> EPC_MEM_OUT,				
				ena 			=> ena,
                clock 			=> clock,  
				reset 			=> reset );
								
	FWD:   FORWARD
	PORT MAP ( 	rd_MEM 			=> write_reg_address_EX_MEM,
				rd_WB 			=> write_register_address,
				rs_EX 			=> rs_EX,
				rt_EX 			=> rt_EX,
				RegWrite_EX_MEM => RegWrite_EX_MEM,
				RegWrite_MEM_WB => RegWriteRF,
				forwardA_EX 	=> forwardA_E,
				forwardB_EX 	=> forwardB_E );
				
	HZD:   HAZARD
	PORT MAP ( 	rs_ID 			=> rs_ID,
				rt_ID 			=> rt_ID,
				MemRead_EX  	=> MemRead_ID_EX,
				MemRead_MEM	    => MemRead_EX_MEM,
				MemWrite_EX     => MemWrite_ID_EX,
				MemRead_WB      => MemtoRegWB,
				RegWrite_EX	    => RegWrite_ID_EX,
				RegWrite_MEM	=> RegWrite_EX_MEM,
				des_EX			=> des_EX,
				des_MEM         => write_reg_address_EX_MEM,
				Branch 			=> Branch_CTL,
				Taken 			=> Taken,
				jal 			=> jal,
				jr  			=> jr,
				jmp 			=> jmp,
				IF_ID_ctl_flush => IF_ID_ctl_flush,
				ID_EX_ctl_flush => ID_EX_ctl_flush,			
				PCstall			=> PC_stall,
				IF_ID_stall		=> IF_ID_stall );				

------------------------------------------ Support registers ------------------------------------------						
	--- instruction address registers:
	INSTR_ID_EX:	process(clock,reset)		-- EX INSTRUCTION
					begin
						if(reset = '1') then					
							Inst_ID_EX <= (others => '0');							
						elsif rising_edge(clock) then
							if (ena = '1') then
								Inst_ID_EX <= Instruction_IF_ID;	
							end if;	
						end if;				
					end process;	

	INSTR_EX_MEM:	process(clock,reset)		-- MEM INSTRUCTION
					begin
						if(reset = '1') then						
							Inst_EX_MEM <= (others => '0');							
						elsif rising_edge(clock) then
							if (ena = '1') then						
								Inst_EX_MEM <= Inst_ID_EX;	
							end if;
						end if;				
					end process;	

	INSTR_MEM_WB:	process(clock,reset)		-- WB INSTRUCTION
					begin
						if(reset = '1') then						
							Inst_MEM_WB <= (others => '0');							
						elsif rising_edge(clock) then
							if (ena = '1') then
								Inst_MEM_WB <= Inst_EX_MEM;
							end if;	
						end if;				
					end process;
			
	--- clock counter register:		
	CLKCNT:			process(clock,reset)
					begin
						if(reset = '1') then						
							clockCNT <= (others => '0');							
						elsif rising_edge(clock) then
							if (ena = '1') then						
								clockCNT <= clockCNT + 1;
							end if;	
						end if;				
					end process;	
					
	--- stall counter register:		
	STCNT:			process(clock,reset)
					begin
						if(reset = '1') then						
							stallCNT <= (others => '0');							
						elsif rising_edge(clock) and PC_stall = '1' then
							if (ena = '1') then
								stallCNT <= stallCNT + 1;
							end if;
						end if;				
					end process;
					
	--- flush counter register:			
	FHCNT:			process(clock,reset)
					begin
						if(reset = '1') then				
							flushCNT <= (others => '0');							
						elsif rising_edge(clock) and (IF_ID_ctl_flush = '1' or ID_EX_ctl_flush = '1')  then
								if (ena = '1') then
									flushCNT <= flushCNT + 1;
								end if;
						end if;				
					end process;	
	
------------------ INTERRUPT -----------------------------------------------
	INT_ACK:    PROCESS(clock)
			    BEGIN		
					IF rising_edge(clock) THEN
						IF ISR = "10" THEN
							INTA_out <= '1';							
						ELSIF INTR = '1' THEN
							INTA_out <= '0';
						END IF;
					END IF;			
				END PROCESS;										

	ISR_BIT:    PROCESS(clock)
			    BEGIN					
					IF falling_edge(clock) THEN
						IF INTA_out = '0' THEN
							ISR <= ISR + 1;
						ELSE
							ISR <= "00";							
						END IF;
					END IF;			
				END PROCESS;	
END structure;