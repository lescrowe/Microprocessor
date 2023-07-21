LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity Clock is
	port( clk :in std_logic; 
			clk_s : out std_logic;
			clk_e : out std_logic);
end Clock;

architecture Behavioral of Clock is
	signal count: integer := 1;
	signal clock_1: std_logic := '1';
	signal clock_2: std_logic := '0';
begin
	process(clk)
		begin
		if rising_edge(clk) then
			count <= count + 1;
			if count = 12500000 then  --10
				clock_1 <= not clock_1;	
				count <= 1;								
			elsif count = 5000000 then--4
				clock_2 <= not clock_2;
			end if;			
		end if;		
		end process;	
		clk_e <= clock_1 or clock_2;
		clk_s <= clock_1 and clock_2;
end Behavioral;

library ieee;
use ieee.std_logic_1164.all;

entity stepper is
	port (clk : in std_logic;
			step: out std_logic_vector(5 downto 0));
end stepper;

architecture behav of stepper is
	signal count : integer := 1;
begin
	Process(clk)
	begin
	if rising_edge(clk) then
	   count <= count+1;
		if count < 25000000 then  --0
			step <= "000001";
		elsif count = 25000000 then  --19
			step <= "000010";
		elsif count = 50000000 then  --39
			step <= "000100";
		elsif count = 75000000 then  --59
			step <= "001000";
		elsif count = 100000000 then  --79
			step <= "010000";
		elsif count = 125000000 then --99 
			step <= "100000";
		elsif count = 150000000 then --119		
			count <= 1;
		end if;
	end if;
	end Process;
end behav;

library IEEE;
use ieee.std_logic_1164.all;

entity program_Counter is
	port( clk: in std_logic;
			set, en : in std_logic;
			pc_in : in std_logic_vector(15 downto 0);	
			pc_out : out std_logic_vector(15 downto 0));	
	end program_Counter;
	
Architecture behaviour of program_Counter is
	signal RAM : std_logic_vector(15 downto 0);
begin
	process(clk)
	begin
		if rising_edge(clk) then
			if set = '1' then
				RAM <= pc_in;
			elsif en = '1' then
				pc_out <= RAM;
			else
				pc_out <= "ZZZZZZZZZZZZZZZZ";
			end if;
		end if;
	end process;		
end behaviour;	

library IEEE;
use ieee.std_logic_1164.all;

entity temp_ALU is
	port( clk: in std_logic;
			frm_bus : in std_logic_vector(15 downto 0);
			tmp_set : in std_logic;
			temp_out : out std_logic_vector(15 downto 0));	
	end temp_ALU;
	
Architecture behaviour of temp_ALU is
begin
	process(clk)
		begin
		if rising_edge(clk) then
			if  tmp_set = '1' then
				temp_out <= frm_bus;
			end if;
		end if;
	end process;
end behaviour;

library IEEE;
use ieee.std_logic_1164.all;

entity accumulator is
	port( clk: in std_logic;
			frm_ALU: in std_logic_vector(15 downto 0);
			acc_set, acc_ena : in std_logic;
			to_bus : out std_logic_vector(15 downto 0));	
	end accumulator;
	
Architecture behaviour of accumulator is	
	signal RAM : std_logic_vector(15 downto 0);	
begin
	process(clk)
		begin
		if rising_edge(clk) then
			if  acc_set = '1' then
				RAM <= frm_ALU;
			elsif acc_ena = '1' then	
				to_bus <= RAM;	
			else 
				to_bus <= "ZZZZZZZZZZZZZZZZ";
			end if;
		end if;
	end process;
end behaviour;

library ieee;
use ieee.std_logic_1164.all;

entity FLAGS is
		port (clk: in std_logic;
				frm_ALU: in std_logic_vector(7 downto 0);
				set_flgs : in std_logic;
				carry_to_ALU : out std_logic;
				to_CU : out std_logic_vector(7 downto 0));
end FLAGS;

Architecture behaviour of FLAGS is
begin	
	process(clk)		
		begin
		if rising_edge(clk) then
			if set_flgs = '1' then
				to_CU <= frm_ALU;
				carry_to_ALU <= frm_ALU(0);
			end if;
		end if;		
	end process;
end behaviour;

library ieee;
use ieee.std_logic_1164.all;

entity io_intr_flags is
		port (clk: in std_logic;
				frm_IO, io_intr_ack : in std_logic_vector(3 downto 0);
				to_MIO : inout std_logic_vector(3 downto 0));
end io_intr_flags;

Architecture behaviour of io_intr_flags is
begin	
	process(clk)		
		begin
		if rising_edge(clk) then
			to_MIO <= frm_IO and to_MIO;
		end if;	
		if rising_edge(clk) then
			if io_intr_ack(0) = '1' then
				to_MIO(0) <= '0';
			elsif io_intr_ack(1) = '1' then
				to_MIO(1) <= '0';
			elsif io_intr_ack(2) = '1' then
				to_MIO(2) <= '0';
			elsif io_intr_ack(3) = '1' then
				to_MIO(3) <= '0';
			end if;
		end if;		
	end process;
end behaviour;

library IEEE;
use ieee.std_logic_1164.all;

entity instruction_register is
	port( clk: in std_logic;
			frm_bus : in std_logic_vector(15 downto 0);
			set_IR  : in std_logic;
			to_cu  : out std_logic_vector(15 downto 0));	
	end instruction_register;
	
Architecture behaviour of instruction_register is	
begin
	process(clk, set_IR)
	begin
		if rising_edge(clk) then
			if set_IR = '1' then	
				to_cu <= frm_bus; 
			end if;
		end if;
	end process;
end behaviour;

library IEEE;
use ieee.std_logic_1164.all;

entity MemAR is
	port( clk: in std_logic;
			frm_bus : in std_logic_vector(15 downto 0);
			mem_set     : in std_logic;
			to_mem  : out std_logic_vector(15 downto 0));		
	end MemAR;
	
Architecture behaviour of MemAR is	
begin
	process(clk, mem_set)
	begin
		if rising_edge(clk) then
			if mem_set = '1' then	
				to_mem <= frm_bus; 
			end if;
		end if;
	end process;
end behaviour;

library ieee;
use ieee.std_logic_1164.all;

entity rom is
port( clk: in std_logic;
		rd_ena	: 	in std_logic;                             --read enable
		addr		:	in		integer range 0 to 15;             --address to write/read
		ack 		:	out		std_logic;
		data		:	out		std_logic_vector(15 downto 0));		
end rom;

architecture behaviour of rom is
	type memory is array(0 to 31) of std_logic_vector(15 downto 0);  --data type for memory
	signal rom:	memory := (
	--program begins here
	"0111100000000000",  --ld imm r0
	"0000000000000000",  --Ax0 ram address
	"0111100001000000",  --ld imm r1
	"0001100000110000",  --7s33
	"0111100100000000",  --ld imm r4
	"0000000100000010",  --7s66
	"0101010000000101",  --str r0 r1 33  store 33 in RAMx0000
	"0101000100000001",  --ld  r4 r0     load RAMx0000 to r4
	"1000000100000000",  --print r4 33   print r4
	"0000000000000000","0000000000000000",
	"0000000000000000","0000000000000000","0000000000000000",
	"0000000000000000","0000000000000000","0000000000000000",
	"0000000000000000","0000000000000000","0000000000000000",
	"0000000000000000","0000000000000000","0000000000000000",
	"0000000000000000","0000000000000000","0000000000000000",
	"0000000000000000","0000000000000000","0000000000000000",
	"0000000000000000","0000000000000000","0000000000000000");
	--program ends here. NOTE: There must be 32 sets of words(2-bytes).
begin

process(clk)
	begin
		if rising_edge(clk) then
			if(rd_ena = '1') then     --write enable is asserted
				data <= rom(addr);      --output data at the stored address	
				ack <= '1';
			else 	
				data <= "ZZZZZZZZZZZZZZZZ";
				ack <= 'Z';
			end if;	
		end if;	
	end process;	
end behaviour;	

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Register_File is
	port( clk: in std_logic;
			Reg_set	:	in std_logic_vector(4 downto 0);                      --write enable
			Reg_ena	:	in std_logic_vector(4 downto 0);                      --read enable
			data_input : in std_logic_vector(15 downto 0);
			data_output : out std_logic_vector(15 downto 0));	
end Register_File;

architecture behaviour of Register_file is
	type memory is array(15 downto 0) of std_logic_vector(15 downto 0);  --data type for memory
	signal regFile		:	memory;                                         --memory array		
begin
	process(clk)
	begin		
		if rising_edge(clk) then
			if(Reg_set(4) = '1') then     --write enable is asserted
				regFile(to_integer(unsigned(Reg_set(3 downto 0)))) <= data_input;
			elsif Reg_ena(4) = '1' THEN     --write enable is asserted
				data_output <= regFile(to_integer(unsigned(Reg_ena(3 downto 0)))); 
			else 	
				data_output <= "ZZZZZZZZZZZZZZZZ";
			end if;	
		end if;		
	end process;	
end behaviour;

library ieee;
use ieee.std_logic_1164.all;

entity SegmentDisplay  is
	port( sys_clk : in std_logic;
			frm_bus : in std_logic_vector(15 downto 0); --data_bus
			wr_enable: in std_logic;	
			to_lcd0, to_lcd1 : out std_logic_vector(6 downto 0));	
end SegmentDisplay ;
	
Architecture behaviour of SegmentDisplay  is		
	
begin
	process(sys_clk)
	begin
	if rising_edge(sys_clk) then
		if not(wr_enable) = '1' then
			to_lcd0 <= frm_bus(6 downto 0);
			to_lcd1 <= frm_bus(13 downto 7);
		end if;
	end if;
	end process;
end behaviour;



library ieee;
use ieee.std_logic_1164.all;

entity MIO_Interface is
	port( sys_clk: in std_logic;
			address_bus, frm_bus, Mdata_bus : in std_logic_vector(15 downto 0); 
			Mio_con: in std_logic_vector(4 downto 0);  -- 4 m/io; 3 rd/wr; 2 wake bit; rd/wr 1-0 device port
			ackn: in std_logic;	  --1 read 0 writeio_interrupt : in std_logic_vector(3 downto 0);
			io_interrupt : in std_logic_vector(3 downto 0);
			io_interruptCU : out std_logic_vector(3 downto 0);
			io_intr_ack : in std_logic_vector(3 downto 0);	
			traffic_ctrl : out std_logic_vector(7 downto 0);	  --1 read 0 write
			to_bus, Maddress_bus, to_device : out std_logic_vector(15 downto 0);  --data_bus);	
			dev_clk: out std_logic); --device clock);	
end MIO_Interface;
	
Architecture behaviour of MIO_Interface is		
	component io_intr_flags 
	port( clk: in std_logic;
			frm_IO, io_intr_ack : in std_logic_vector(3 downto 0);
			to_MIO : out std_logic_vector(3 downto 0));
	end component;
begin
	io_intr_module : io_intr_flags port map (sys_clk, io_interrupt, io_intr_ack, io_interruptCU);
	dev_clk <= sys_clk;
	process(sys_clk)
	begin
	if rising_edge(sys_clk) then
		if Mio_con(2) = '1' then
			if Mio_con(4 downto 3) = "11" then   	   -- if memory read 11
				Maddress_bus <= address_bus;
				case Mio_con(1 downto 0) is
				when "00" =>
					traffic_ctrl(0) <= '1';
				when "01" =>
					traffic_ctrl(1) <= '1';
				when "10" =>
					traffic_ctrl(2) <= '1';
				when "11" =>
					traffic_ctrl(3) <= '1';
				end case;
			elsif Mio_con(4 downto 3) = "10" then     -- if memory write 10 
				Maddress_bus <= address_bus;
				to_device <= frm_bus; 
				case Mio_con(1 downto 0) is
				when "00" =>
					traffic_ctrl(0) <= '0';
				when "01" =>
					traffic_ctrl(1) <= '0';
				when "10" =>
					traffic_ctrl(2) <= '0';
				when "11" =>
					traffic_ctrl(3) <= '0';
				end case;
			elsif Mio_con(4 downto 3) = "01" then   	   -- if IO read 11
				case Mio_con(1 downto 0) is
				when "00" =>
					traffic_ctrl(4) <= '1';
				when "01" =>
					traffic_ctrl(5) <= '1';
				when "10" =>
					traffic_ctrl(6) <= '1';
				when "11" =>
					traffic_ctrl(7) <= '1';
				end case;
			elsif Mio_con(4 downto 3) = "00" then        -- if IO write 10
				to_device <= frm_bus;
				case Mio_con(1 downto 0) is
				when "00" =>
					traffic_ctrl(4) <= '0';					
				when "01" =>
					traffic_ctrl(5) <= '0';
				when "10" =>
					traffic_ctrl(6) <= '0';
				when "11" =>
					traffic_ctrl(7) <= '0';
				end case;	
			end if;			
			
			if ackn = '1' then -- if expecting memory to respond(memory read) 
				to_bus <= Mdata_bus;
			else 		
				to_bus <= "ZZZZZZZZZZZZZZZZ";
			end if;		
		else
			traffic_ctrl <= "ZZZZZZZZ";
			to_bus <= "ZZZZZZZZZZZZZZZZ";				
		end if;
	end if;
	end process;
end behaviour;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram is
 port(clk: in std_logic;                                        
		mem_ctrl:   in std_logic;                
		addr	:	in		integer range 0 to 31;             
		ackn 		:	out		std_logic;
		data_in	:	in		std_logic_vector(15 downto 0);		   
		data_out:	out		std_logic_vector(15 downto 0));		   
end ram;

architecture behaviour of ram is
	type memory is array(31 downto 0) of std_logic_vector(15 downto 0);--data type for memory
	signal ram:	memory;--memory array	
begin
	process(clk)
	begin
		if rising_edge(clk) then 
			if    (mem_ctrl = '0') then     --write enable is asserted
				ram(addr) <= data_in;       --write input data into memory
			elsif (mem_ctrl = '1') then  	--read enable is asserted	 
				data_out <= ram(addr);      --output data at the stored address	
				ackn <= '1';		
			else 	
				data_out <= "ZZZZZZZZZZZZZZZZ";
				ackn <= 'Z';	
			end if;		
		end if;	
	end process;	
end behaviour;			