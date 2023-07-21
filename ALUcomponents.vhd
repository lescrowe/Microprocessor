LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY ADDer IS
	port (d1, d2 : in signed(15 downto 0);
			clk: in std_logic; 
			Cin: IN integer range 0 to 1;--std_logic;
			d3 : out std_logic_vector(15 downto 0);
			flags : out std_logic_vector(7 downto 0));
END ADDer;

ARCHITECTURE behaviour OF ADDer IS
	signal Zsig: signed(15 downto 0);
					
begin
	process(clk)
	begin
	if (d1 < 0) and (d2 < 0) and (Zsig > 0) then
		flags(5) <= '1';
	elsif (d1 > 0) and (d2 > 0) and (Zsig < 0) then
		flags(5) <= '1';
	else 	
		flags(5) <= '0';
	end if;
	if (Zsig < 0) then
		flags(4) <= '1';
	else	
		flags(4) <= '0';
	end if;
	
	Zsig <= d1 + d2;-- + Cin;
	d3 <= std_logic_vector(signed(Zsig));
	end process;
	
end behaviour;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY SUBer IS
	port (d1, d2 : in signed(15 downto 0);
			clk: in std_logic; 
			Cin: IN integer range 0 to 1;--std_logic;
			d3 : out std_logic_vector(15 downto 0);
			flags : out std_logic_vector(7 downto 0));
END SUBer;

ARCHITECTURE behaviour OF SUBer IS
	signal Zsig: signed(15 downto 0);
					
begin
	process(clk)
	begin
	if (d1 < 0) and (d2 > 0) and (Zsig > 0) then
		flags(5) <= '1';
	elsif (d1 > 0) and (d2 < 0) and (Zsig < 0) then
		flags(5) <= '1';
	else 	
		flags(5) <= '0';
	end if;
	if Zsig < 0 then
		flags(4) <= '1';
	else 	
		flags(4) <= '0';
	end if;
	
	Zsig <= d1 - d2 - Cin;
	d3 <= std_logic_vector(signed(Zsig));
	end process;	
end behaviour;

library ieee;
use ieee.std_logic_1164.all;

entity ANDer is
		port (d1, d2 : in std_logic_vector(15 downto 0);
				d3 : out std_logic_vector(15 downto 0));
end ANDer;

Architecture behaviour of ANDer is
begin
	d3 <= d1 and d2;
end behaviour;


library ieee;
use ieee.std_logic_1164.all;

entity ORer is
		port (d1, d2 : in std_logic_vector(15 downto 0);
				d3 : out std_logic_vector(15 downto 0));
end ORer;

Architecture behaviour of ORer is
begin
	d3 <= d1 or d2;
end behaviour;


library ieee;
use ieee.std_logic_1164.all;

entity XORer is
		port (d1, d2 : in std_logic_vector(15 downto 0);
				d3 : out std_logic_vector(15 downto 0));
end XORer;

Architecture behaviour of XORer is
begin
	d3 <= d1 xor d2;
end behaviour;


library ieee;
use ieee.std_logic_1164.all;

entity NOTer is
		port (d1: in std_logic_vector(15 downto 0);
				d3 : out std_logic_vector(15 downto 0));
end NOTer;

Architecture behaviour of NOTer is
begin
	d3 <= not d1;
end behaviour;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU_SR is
		port (d1 : in std_logic_vector(15 downto 0);
				Cin : in std_logic;
				d3_6, d3_7, d3_8, d3_9, d3_10, d3_11, d3_12, d3_13,
				d3_14, d3_15  : out std_logic_vector(15 downto 0);
				flags_0, flags_1 : out std_logic_vector(7 downto 0));
end ALU_SR;

Architecture behaviour of ALU_SR is
	signal SL_A : signed(15 downto 0);
	signal SL_L : unsigned(15 downto 0);
	signal SR_A : signed(15 downto 0);
	signal SR_L : unsigned(15 downto 0);
	signal RLL  : unsigned(15 downto 0);
	signal RLA  : signed(15 downto 0);
	signal RLC  : unsigned(16 downto 0);
	signal RRL  : unsigned(15 downto 0);
	signal RRA  : signed(15 downto 0);
	signal RRC  : unsigned(16 downto 0);
	
begin
	SL_A <= shift_left(signed(d1),1);
	SL_L <= shift_left(unsigned(d1),1);
	SR_A <= shift_right(signed(d1),1);
	SR_L <= shift_right(unsigned(d1),1);
	RLL <= rotate_left(unsigned(d1),1);
	RLA <= rotate_left(signed(d1),1);
	RLC  <= rotate_left(unsigned(d1 & Cin),1);
	RRL <= rotate_right(unsigned(d1),1);
	RRA <= rotate_right(signed(d1),1);
	RRC  <= rotate_right(unsigned(d1 & Cin),1);
	
	d3_6    <= std_logic_vector(signed(SL_A));
	d3_8    <= std_logic_vector(signed(SL_L));
	d3_7    <= std_logic_vector(signed(SR_A));
	d3_9    <= std_logic_vector(signed(SR_L));
	d3_10   <= std_logic_vector(signed(RLL));
	d3_11   <= std_logic_vector(signed(RLA));
	d3_12   <= std_logic_vector(signed(RLC(16 downto 1)));
	flags_0(0)<= RLC(0);
	d3_13   <= std_logic_vector(signed(RRL));
	d3_14   <= std_logic_vector(signed(RRA));
	d3_15   <= std_logic_vector(signed(RRC(16 downto 1)));
	flags_1(0)<= RRC(0);
	
end behaviour;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity INC is
		port (d1 : in signed(15 downto 0);
				d3 : out std_logic_vector(15 downto 0));
end INC;

Architecture behaviour of INC is
	signal Zsig: signed(15 downto 0);
						
begin
	Zsig <= d1 + 1;
	d3 <= std_logic_vector(signed(Zsig));
end behaviour;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DEC is
	port (clk: in std_logic; 
			d1 : in signed(15 downto 0);
			flags : out std_logic_vector(7 downto 0);
			d3 : out std_logic_vector(15 downto 0));
end DEC;

Architecture behaviour of DEC is
	signal Zsig: signed(15 downto 0);
					
begin
	process(Clk)
		begin
		if rising_edge(clk) then
			if Zsig < 0 then
				flags(4) <= '1';
			else 	
				flags(4) <= '0';
			end if;
		end if;
		Zsig <= d1 - 1;
		d3 <= std_logic_vector(signed(Zsig));	
	end process;	
	
end behaviour;

library ieee;
use ieee.std_logic_1164.all;

entity CMP is
		port (d1, d2 : in std_logic_vector(15 downto 0);
				flags : out std_logic_vector(7 downto 0));
end CMP;

Architecture behaviour of CMP is		
begin
	flags(1) <= '1' when (d1 = "0000000000000000") else '0'; --zero flag
	flags(2) <= '1' when (d1 > d2) else '0'; -- b greater
	flags(3) <= '1' when (d1 = d2) else '0'; --equality	
end behaviour;