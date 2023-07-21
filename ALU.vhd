LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY ALU IS
	port( clk: in std_logic;
			opcode : in std_logic_vector(4 downto 0);
			d1, d2 : in std_logic_vector(15 downto 0);
			Cin : in std_logic;
			d3 : out std_logic_vector(15 downto 0);
			set_flgs : out std_logic;
			flags : out std_logic_vector(7 downto 0));	
END ALU;

ARCHITECTURE behaviour OF ALU IS
	signal a, b, c : std_logic_vector(15 downto 0);
	signal d3_0, d3_1, d3_2, d3_3, d3_4, d3_5, d3_6, d3_7, d3_8, d3_9, 
	d3_10, d3_11, d3_12, d3_13, d3_14, d3_15, d3_16, d3_17  : std_logic_vector(15 downto 0);
	signal flags_0, flags_1, flags_2, flags_3, flags_4, flags_5 : std_logic_vector(7 downto 0) := "ZZZZZZZZ";
	component ADDer
		port (d1, d2 : in signed(15 downto 0);
				clk: in std_logic; 
				Cin: In std_logic;
				d3 : out std_logic_vector(15 downto 0);
				flags : out std_logic_vector(7 downto 0));
	end component;
	component SUBer
		port (d1, d2 : in signed(15 downto 0);
				clk: in std_logic; 
				Cin: in std_logic;
				d3 : out std_logic_vector(15 downto 0);
				flags : out std_logic_vector(7 downto 0));
	end component;
	component ANDer
		port (d1, d2 : in std_logic_vector(15 downto 0);
				d3 : out std_logic_vector(15 downto 0));
	end component;
	component ORer
		port (d1, d2 : in std_logic_vector(15 downto 0);
				d3 : out std_logic_vector(15 downto 0));
	end component;
	component XORer
		port (d1, d2 : in std_logic_vector(15 downto 0);
				d3 : out std_logic_vector(15 downto 0));
	end component;
	component NOTer
		port (d1 : in std_logic_vector(15 downto 0);
				d3 : out std_logic_vector(15 downto 0));
	end component;
	component ALU_SR is
		port (d1 : in std_logic_vector(15 downto 0);
				Cin : in std_logic;
				d3_6, d3_7, d3_8, d3_9, d3_10, d3_11, d3_12, d3_13,
				d3_14, d3_15 : out std_logic_vector(15 downto 0);
				flags_0, flags_1 : out std_logic_vector(7 downto 0));
end component;
	component INC
		port (d1 : in signed(15 downto 0);
				d3 : out std_logic_vector(15 downto 0));
	end component;
	component DEC
		port (clk: in std_logic; 
				d1 : in signed(15 downto 0);
				flags : out std_logic_vector(7 downto 0);
				d3 : out std_logic_vector(15 downto 0));
	end component;
	component CMP
		port (d1, d2 : in std_logic_vector(15 downto 0);
				flags : out std_logic_vector(7 downto 0)
				);	
	end component;	
begin	
	alu00: ADDer port map(signed(d1), signed(d2), clk, Cin, d3_0, flags_0);
	alu01: SUBer port map(signed(d1), signed(d2), clk, Cin, d3_1, flags_1);
	alu02: ANDer port map(d1, d2, d3_2);
	alu03: ORer port map(d1, d2, d3_3);
	alu04: XORer port map(d1, d2, d3_4);
	alu05: NOTer port map(d1, d3_5);
	alu06: ALU_SR port map(d1, Cin, d3_6, d3_7, d3_8, d3_9, d3_10, d3_11, d3_12, d3_13, d3_14, d3_15, flags_3, flags_4);
	alu07: INC port map(signed(d1), d3_16);
	alu08: DEC port map(clk, signed(d1), flags_5, d3_17);
	alu09: CMP port map(d1, d2, flags_2);	
	
	process(clk)
	begin
		if rising_edge(clk) then
			if opcode = "00001" then --add
				d3 <= d3_0;
				flags <= flags_0;
				set_flgs <= '1';
			elsif opcode = "00010" then --sub
				d3 <= d3_1;
				flags <= flags_1;
				set_flgs <= '1';
			elsif opcode = "00011" then --and
				d3 <= d3_2;
				set_flgs <= '0';
			elsif opcode = "00100" then --or
				d3 <= d3_3;
				set_flgs <= '0';
			elsif opcode = "00101" then --xor
				d3 <= d3_4;
				set_flgs <= '0';
			elsif opcode = "00110" then --not
				d3 <= d3_5;
				set_flgs <= '0';
			elsif opcode = "00111" then --sla
				d3 <= d3_6;
				set_flgs <= '0';
			elsif opcode = "01000" then --sra
				d3 <= d3_7;
				set_flgs <= '0';
			elsif opcode = "01001" then --sll
				d3 <= d3_8;
				set_flgs <= '0';
			elsif opcode = "01010" then --srl
				d3 <= d3_9;
				set_flgs <= '0';
			elsif opcode = "01011" then --rol
				d3 <= d3_10;
				set_flgs <= '0';
			elsif opcode = "01100" then --ror
				d3 <= d3_13;
				set_flgs <= '0';
			elsif opcode = "01101" then --rlc
				d3 <= d3_12;				
				flags <= flags_3;
				set_flgs <= '1';
			elsif opcode = "01110" then --rrc
				d3 <= d3_15;
				flags <= flags_4;
				set_flgs <= '1';
			elsif opcode = "01111" then --rla
				d3 <= d3_11;
				set_flgs <= '0';
			elsif opcode = "10000" then --rra
				d3 <= d3_14;
				set_flgs <= '0';	
			elsif opcode = "10001" then --inc
				d3 <= d3_16;
				set_flgs <= '0';
			elsif opcode = "10010" then --dec
				d3 <= d3_17;
				flags <= flags_5;				
				set_flgs <= '1';
			elsif opcode = "10011" then --cmp
				flags <= flags_2;
				set_flgs <= '1';
			else   
				d3 <= "ZZZZZZZZZZZZZZZZ";
				set_flgs <= '0';
			end if;	
		end if;
end process;  
	
end behaviour;
	