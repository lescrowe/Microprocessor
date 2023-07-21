library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Ilara_i is
	port( Power, prim_clk : in std_logic;
			ps2_clk      : in  std_logic;                     --clock signal from ps/2 keyboard
			ps2_data     : in  std_logic;                     --data signal from PS/2 keyboard
			achtung : out std_logic_vector(15 downto 0) ;
			HEX0, HEX1, HEX2 : out std_logic_vector(6 downto 0));
end Ilara_i;

Architecture behaviour of Ilara_i is
	signal sys_clk, dev_clk, clk, cu_s, cu_e, ackn: std_logic;
	signal traffic_ctrl : std_logic_vector(7 downto 0);
	signal io_interrupt,io_interruptCU, io_intr_ack : std_logic_vector(3 downto 0);				
	signal step : std_logic_vector(5 downto 0);
	signal opcode, Reg_set, Reg_ena, Mio_ctrl  : std_logic_vector(4 downto 0);
	signal CU_flags, ALU_flags : std_logic_vector(7 downto 0);
	signal to_ALU_carry, set_flgs, acc_ena, acc_set, rd_ena, wr_ena, MAR_set, 
			 pc_set, pc_ena, IR_set, tmp_set: std_logic := 'Z';
	signal tmp_out, data_bus, instr_word, alu_acc, 
			 address_bus, mem_bus, M_data_bus, 
			 to_device_bus : std_logic_vector(15 downto 0);--M_addr_bus, 
			 
	component Clock 
	port( clk : in std_logic; --50 MHz
			clk_s : out std_logic;--set data clk
			clk_e : out std_logic);--enable data(on bus) clk
 	end component;
	component Control_Unit
	port( Power, sys_clk, clk_s, clk_e : in std_logic;
			instr_word     : in std_logic_vector(15 downto 0);
			flags : in std_logic_vector(7 downto 0);			
			io_interrupt : in std_logic_vector(3 downto 0);	
			io_intr_ack : out std_logic_vector(3 downto 0); 	
			opcode, Mio_ctrl, Reg_set, Reg_ena : out std_logic_vector(4 downto 0);
			acc_ena, acc_set, MAR_set, IR_set, pc_set, pc_ena, tmp_set: out std_logic;
			stepp     : out std_logic_vector(5 downto 0));		
	end component;
	component program_Counter
	port( clk: in std_logic;
			set, en : in std_logic;
			pc_in : in std_logic_vector(15 downto 0);	
			pc_out : out std_logic_vector(15 downto 0));	
	end component;	
	component temp_ALU 
	port( clk: in std_logic;
			frm_bus : in std_logic_vector(15 downto 0);
			tmp_set : in std_logic;
			temp_out : out std_logic_vector(15 downto 0));	
	end component;
	component ALU 
	port( clk: in std_logic;
			opcode : in std_logic_vector(4 downto 0);
			d1, d2 : in std_logic_vector(15 downto 0);
			Cin : in std_logic;
			d3 : out std_logic_vector(15 downto 0);
			set_flgs : out std_logic;
			flags : out std_logic_vector(7 downto 0));	
	end component;
	component accumulator
	port( clk: in std_logic;
			frm_ALU: in std_logic_vector(15 downto 0);
			acc_set, acc_ena : in std_logic;
			to_bus : out std_logic_vector(15 downto 0));	
	end component;	
	component FLAGS 
	port (clk: in std_logic;
			frm_ALU: in std_logic_vector(7 downto 0);
			set_flgs : in std_logic;
			carry_to_ALU : out std_logic;
			to_CU : out std_logic_vector(7 downto 0));
	end component;
	component MemAR
	port( clk: in std_logic;
			frm_bus : in std_logic_vector(15 downto 0);
			mem_set     : in std_logic;
			to_mem  : out std_logic_vector(15 downto 0));	
	end component;	
	component rom 
	port( clk: in std_logic;
			rd_ena	:	IN		STD_LOGIC;                             --read enable
			addr		:	IN		INTEGER RANGE 0 TO 15;             --address to write/read
			ack 		:	out		std_logic;		
			data	:	OUT		STD_LOGIC_VECTOR(15 DOWNTO 0));		
	end component;	
	component instruction_register
	port( clk: in std_logic;
			frm_bus : in std_logic_vector(15 downto 0);
			set_IR     : in std_logic;
			to_cu  : out std_logic_vector(15 downto 0));	
	end component;
	component Register_File
	port( clk: in std_logic;
			Reg_set : in std_logic_vector(4 downto 0);
			Reg_ena : in std_logic_vector(4 downto 0);
			data_input : in std_logic_vector(15 downto 0);
			data_output : out std_logic_vector(15 downto 0));
	end component;	
	component SegmentDisplay 
	port( sys_clk : in std_logic;
			frm_bus : in std_logic_vector(15 downto 0); --data_bus
			wr_enable: in std_logic;	
			to_lcd0, to_lcd1 : out std_logic_vector(6 downto 0));				
	end component;	
	component MIO_Interface
	port( sys_clk: in std_logic;
			address_bus, frm_bus, Mdata_bus : in std_logic_vector(15 downto 0); 
			Mio_con: in std_logic_vector(4 downto 0);  -- 4 m/io; 3 rd/wr; 2 wake bit; rd/wr 1-0 device port
			ackn: in std_logic;	  --1 read 0 write
			io_interrupt : in std_logic_vector(3 downto 0);
			io_interruptCU : out std_logic_vector(3 downto 0);
			io_intr_ack : in std_logic_vector(3 downto 0);	
			traffic_ctrl : out std_logic_vector(7 downto 0);	  --1 read 0 write
			to_bus, Maddress_bus, to_device : out std_logic_vector(15 downto 0);   --data_bus);	
			dev_clk: out std_logic); --device clock);	
	end component;
	component ram 
	port(	clk      : in std_logic;--clock
			mem_ctrl :  in std_logic;--read/write enable
			addr	   :	in		integer range 0 to 31;--address to write/read
			ackn 		:	out		std_logic;--acknowledgement bit
			data_in	:	in		std_logic_vector(15 downto 0);--input bus
			data_out:	out		std_logic_vector(15 downto 0));--output bus
	end component;
	component ps2_keyboard 
	port(	clk          : in  std_logic;                     --system clock
			ps2_clk      : in  std_logic;                     --clock signal from ps/2 keyboard
			ps2_data     : in  std_logic;                     --data signal from ps/2 keyboard
			traffic_ctrl : in  std_logic;
			ps2_code_new : out std_logic;                     --flag that new ps/2 code is available on ps2_code bus
			ps2_code     : out std_logic_vector(7 downto 0)); --code received from ps/2
	end component;	
begin
	HEX2(5 downto 0) <= step;
	lk0 : Clock port map(prim_clk, cu_s, cu_e);
	cu0  : Control_Unit port map(Power, prim_clk, cu_s, cu_e, instr_word, CU_flags,
			 io_interruptCU, io_intr_ack, opcode, Mio_ctrl, Reg_set, Reg_ena, acc_ena, acc_set, 
			 MAR_set, IR_set, pc_set, pc_ena, tmp_set, step);
	p_c  : program_Counter port map(prim_clk, pc_set, pc_ena, data_bus, data_bus);
	tmp  : temp_ALU  port map(prim_clk, data_bus, tmp_set, tmp_out);
	alu0 : ALU port map(prim_clk, opcode, data_bus, tmp_out, to_ALU_carry, alu_acc, set_flgs, ALU_flags);
	acc  : accumulator port map(prim_clk, alu_acc, acc_set, acc_ena, data_bus);
	fgs0 : FLAGS port map(prim_clk, ALU_flags, set_flgs, to_ALU_carry, CU_flags);
	mar  : MemAR port map(prim_clk, data_bus, MAR_set, address_bus);
	i_r  : instruction_register port map(prim_clk, data_bus, IR_set, instr_word);
	r0m  : rom port map(dev_clk, traffic_ctrl(0), to_integer(unsigned(mem_bus)), ackn, M_data_bus);
	Reg0 : Register_File port map(prim_clk, Reg_set, Reg_ena, data_bus, data_bus);
	sd   : SegmentDisplay  port map(dev_clk, to_device_bus, traffic_ctrl(4), HEX0, HEX1);
	mio  : MIO_Interface port map(prim_clk, address_bus, data_bus, M_data_bus, Mio_ctrl, ackn, io_interrupt, io_interruptCU, 
			 io_intr_ack, traffic_ctrl, data_bus, mem_bus, to_device_bus, dev_clk);	
	ram0 : ram port map(dev_clk , traffic_ctrl(1), to_integer(unsigned(mem_bus)), ackn, data_bus, data_bus);		 
	keyb : ps2_keyboard port map(dev_clk, ps2_clk, ps2_data, traffic_ctrl(5), io_interrupt(0), --flag that new ps/2 code is available on ps2_code bus
			 data_bus(7 downto 0)); --code received from ps/2)	
end behaviour;	
		