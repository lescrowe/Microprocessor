LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Control_Unit is
	port( Power, sys_clk, clk_s, clk_e : in std_logic;
			instr_word     : in std_logic_vector(15 downto 0);
			flags : in std_logic_vector(7 downto 0);	
			io_interrupt : in std_logic_vector(3 downto 0);			
			io_intr_ack : out std_logic_vector(3 downto 0); 	
			opcode, Mio_ctrl, Reg_set, Reg_ena : out std_logic_vector(4 downto 0);
			acc_ena, acc_set, MAR_set, IR_set, pc_set, pc_ena, tmp_set: out std_logic;
			stepp     : out std_logic_vector(5 downto 0));	
end Control_Unit;

architecture behaviour of Control_Unit is
	signal step : std_logic_vector(5 downto 0);
	signal count: integer := 0;
	signal inst_word_int: integer range 0 to 63; 
	component Stepper 
	port( clk : in std_logic;
			step : out std_logic_vector(5 downto 0));
	end component;
begin	
	inst_word_int <= to_integer(unsigned(instr_word(15 downto 10)));
	stpr  : Stepper port map(sys_clk, step);
	stepp <= step;
	process(sys_clk)		
		begin
		if rising_edge(sys_clk) then
			if step(0) = '1' then
				opcode <= "10001";
				Mio_ctrl <= "00000";
				acc_ena <= '0';
				IR_set <= '0';
				pc_set <= '0';
				tmp_set <= '0';
				case clk_s is
				when '1' =>
					acc_set <= '1';
					MAR_set <= '1';
				when '0' =>
					acc_set <= '0';
					MAR_set <= '0';
				end case;
				case clk_e is
				when '1' =>
					pc_ena <= '1';
				when '0' =>
					pc_ena <= '0';
				end case;
			elsif step(1) = '1' then
				opcode <= "00000";
				case clk_s is
				when '1' =>
					IR_set <= '1';
				when '0' =>
					IR_set <= '0';
				end case;
				case clk_e is
				when '1' =>
					Mio_ctrl <= "11100";
				when '0' =>
					Mio_ctrl <= "00000";					
				end case;
			elsif step(2) = '1' then
				case clk_s is
				when '1' =>
					pc_set <= '1';
				when '0' =>
					pc_set <= '0';
				end case;
				case clk_e is
				when '1' =>
					acc_ena <= '1';
				when '0' =>
					acc_ena <= '0';
				end case;
			elsif step(3) = '1' then	
				if inst_word_int < 20 then --ALU operation			
					case instr_word(14 downto 10) is 
					when  "00001" => opcode <= "00001"; 
					when  "00010" => opcode <= "00010"; 
					when  "00011" => opcode <= "00011"; 
					when  "00100" => opcode <= "00100"; 
					when  "00101" => opcode <= "00101"; 
					when  "00110" => opcode <= "00110"; 
					when  "00111" => opcode <= "00111"; 
					when  "01000" => opcode <= "01000"; 
					when  "01001" => opcode <= "01001"; 
					when  "01010" => opcode <= "01010"; 
					when  "01011" => opcode <= "01011"; 
					when  "01100" => opcode <= "01100"; 
					when  "01101" => opcode <= "01101"; 
					when  "01110" => opcode <= "01110"; 
					when  "01111" => opcode <= "01111"; 
					when  "10000" => opcode <= "10000"; 
					when  "10001" => opcode <= "10001";
					when  "10010" => opcode <= "10010";
					when others => null;
					end case;	
					if inst_word_int > 0 and inst_word_int < 6 then --add/sub/and/or/xor 1
						case clk_s is
						when '1' =>
							tmp_set <= '1';						
						when '0' =>
							tmp_set <= '0';						
						end case;
						case clk_e is
						when '1' =>
							Reg_ena(4) <= '1'; Reg_ena(3 downto 0) <= instr_word(5 downto 2);									
						when '0' =>
							Reg_ena <= "00000";									
						end case;
					elsif inst_word_int = 6 then --not 1
						case clk_s is
						when '1' =>
							acc_set <= '1';
						when '0' =>
							acc_set <= '0';
						end case;
						case clk_e is
						when '1' =>
							Reg_ena(4) <= '1'; Reg_ena(3 downto 0) <= instr_word(9 downto 6);									
						when '0' =>
							Reg_ena <= "00000";								
						end case;
					elsif inst_word_int > 6 and inst_word_int < 17 then --shift and rotate 1
						case clk_s is
						when '1' =>
							acc_set <= '1';
						when '0' =>
							acc_set <= '0';
						end case;
						case clk_e is
						when '1' =>
							Reg_ena(4) <= '1'; Reg_ena(3 downto 0) <= instr_word(9 downto 6);
						when '0' =>
							Reg_ena <= "00000";
						end case;
					elsif inst_word_int = 17 or inst_word_int = 18 then --inc/dec 1
						case clk_s is
						when '1' =>
							acc_set <= '1';
						when '0' =>
							acc_set <= '0';
						end case;
						case clk_e is
						when '1' =>
							Reg_ena(4) <= '1'; Reg_ena(3 downto 0) <= instr_word(9 downto 6);
						when '0' =>
							Reg_ena <= "00000";
						end case;
					elsif inst_word_int = 19 then --cmp 1
						case clk_s is
						when '1' =>
							tmp_set <= '1';
						when '0' =>
							tmp_set <= '0';
						end case;
						case clk_e is
						when '1' =>
							Reg_ena(4) <= '1'; Reg_ena(3 downto 0) <= instr_word(5 downto 2);						
						when '0' =>
							Reg_ena <= "00000";						
						end case;
					end if;
				else-- not ALU ooperation
					if  inst_word_int = 30 then --load immediate 1
						opcode <= "10001";
						case clk_s is
						when '1' =>
							acc_set <= '1';
							MAR_set <= '1';
						when '0' =>
							acc_set <= '0';
							MAR_set <= '0';
						end case;
						case clk_e is
						when '1' =>
							pc_ena <= '1';
						when '0' =>
							pc_ena <= '0';
						end case;		
					elsif inst_word_int = 31 then --mov 1	
						case clk_s is
						when '1' =>
							Reg_set(4) <= '1'; Reg_set(3 downto 0) <= instr_word(9 downto 6);
						when '0' =>
							Reg_set(4) <= '0';
						end case;
						case clk_e is
						when '1' =>
							Reg_ena(4) <= '1'; Reg_ena(3 downto 0) <= instr_word(5 downto 2);						
						when '0' =>
							Reg_ena <= "00000";						
						end case;		
					elsif inst_word_int = 21 then --store 1
						case clk_s is
						when '1' =>
							MAR_set <= '1';
						when '0' =>
							MAR_set <= '0';
						end case;
						case clk_e is
						when '1' =>
							Reg_ena(4) <= '1'; Reg_ena(3 downto 0) <= instr_word(9 downto 6);
						when '0' =>
							Reg_ena <= "00000";
						end case;
					elsif inst_word_int = 20 then --load 1
						case clk_s is
						when '1' =>
							MAR_set <= '1';
						when '0' =>
							MAR_set <= '0';
						end case;
						case clk_e is
						when '1' =>
							Reg_ena(4) <= '1'; Reg_ena(3 downto 0) <= instr_word(5 downto 2);
						when '0' =>
							Reg_ena <= "00000";
						end case;
					elsif inst_word_int = 32 then --i/o_out 1
						case clk_s is
						when '1' =>
							Mio_ctrl(4 downto 2) <= "001"; Mio_ctrl(1 downto 0) <= instr_word(5 downto 4);
						when '0' =>
							Mio_ctrl <= "00000";
						end case;
						case clk_e is
						when '1' =>
							Reg_ena(4) <= '1'; Reg_ena(3 downto 0) <= instr_word(9 downto 6);	
						when '0' =>
							Reg_ena <= "00000";
						end case;
					elsif inst_word_int = 33 then --i/o_in 1
						case clk_s is
						when '1' =>
							Mio_ctrl(4 downto 2) <= "001"; Mio_ctrl(1 downto 0) <= instr_word(5 downto 4); 
						when '0' =>
							Mio_ctrl <= "00000";
						end case;
						case clk_e is
						when '1' =>
							Reg_set(4) <= '1'; Reg_set(3 downto 0) <= instr_word(9 downto 6);
						when '0' =>
							Reg_set(4) <= '0';
						end case;			
					elsif inst_word_int = 22 then --jmp 
						case clk_s is
						when '1' =>
							pc_set <= '1';
						when '0' =>
							pc_set <= '0';
						end case;
						case clk_e is
						when '1' =>
							Reg_ena(4) <= '1'; Reg_ena(3 downto 0) <= instr_word(9 downto 6);
						when '0' =>
							Reg_ena <= "00000";
						end case;
					elsif inst_word_int = 23 then --j_Z 
						if flags(1) = '1' then
							case clk_s is
							when '1' =>
								pc_set <= '1';
							when '0' =>
								pc_set <= '0';
							end case;
							case clk_e is
							when '1' =>
								Reg_ena(4) <= '1'; Reg_ena(3 downto 0) <= instr_word(9 downto 6);							
							when '0' =>
								Reg_ena <= "00000";							
							end case;
						end if;
					elsif inst_word_int = 24 then --j_nZ 	
						if flags(1) = '0' then
							case clk_s is
							when '1' =>
								pc_set <= '1';							
							when '0' =>
								pc_set <= '0';							
							end case;
							case clk_e is
							when '1' =>
								Reg_ena(4) <= '1'; Reg_ena(3 downto 0) <= instr_word(9 downto 6);							
							when '0' =>
								Reg_ena <= "00000";							
							end case;
						end if;	
					elsif inst_word_int = 25 then --j_A 	
						if flags(2) = '0' then
							case clk_s is
							when '1' =>
								pc_set <= '1';							
							when '0' =>
								pc_set <= '0';							
							end case;
							case clk_e is
							when '1' =>
								Reg_ena(4) <= '1'; Reg_ena(3 downto 0) <= instr_word(9 downto 6);							
							when '0' =>
								Reg_ena <= "00000";							
							end case;
						end if;	
					elsif inst_word_int = 26 then --j_EQ 	
						if flags(3) = '0' then
							case clk_s is
							when '1' =>
								pc_set <= '1';							
							when '0' =>
								pc_set <= '0';							
							end case;
							case clk_e is
							when '1' =>
								Reg_ena(4) <= '1'; Reg_ena(3 downto 0) <= instr_word(9 downto 6);							
							when '0' =>
								Reg_ena <= "00000";							
							end case;
						end if;	
					elsif inst_word_int = 27 then --j_N 	
						if flags(4) = '0' then
							case clk_s is
							when '1' =>
								pc_set <= '1';							
							when '0' =>
								pc_set <= '0';							
							end case;
							case clk_e is
							when '1' =>
								Reg_ena(4) <= '1'; Reg_ena(3 downto 0) <= instr_word(9 downto 6);							
							when '0' =>
								Reg_ena <= "00000";							
							end case;
						end if;	
					elsif inst_word_int = 28 then --j_subr 1	
						case clk_s is
						when '1' =>
							Reg_set(4) <= '1'; Reg_set(3 downto 0) <= instr_word(9 downto 6);
						when '0' =>
							Reg_set(4) <= '0';
						end case;
						case clk_e is
						when '1' =>
							pc_ena <= '1';
						when '0' =>
							pc_ena <= '0';
						end case;
					elsif inst_word_int = 29 then --ret_subr 	
						case clk_s is
						when '1' =>
							pc_set <= '1';
						when '0' =>
							pc_set <= '0';
						end case;
						case clk_e is
						when '1' =>
							Reg_ena(4) <= '1'; Reg_ena(3 downto 0) <= instr_word(9 downto 6);
						when '0' =>
							Reg_ena <= "00000";
						end case;
					end if;
				end if;
			elsif step(4) = '1' then
				if inst_word_int < 20 then --ALU operation						
					if  inst_word_int > 0 and inst_word_int < 6 then --add/sub/and/or/xor 2
						opcode <= "00001";
						case clk_s is
						when '1' =>
							acc_set <= '1';						
						when '0' =>
							acc_set <= '0';						
						end case;
						case clk_e is
						when '1' =>
							Reg_ena(4) <= '1'; Reg_ena(3 downto 0) <= instr_word(9 downto 6);						
						when '0' =>
							Reg_ena <= "00000";						
						end case;
					elsif inst_word_int = 6 then --not 2						
						case clk_s is
						when '1' =>
							Reg_set(4) <= '1'; Reg_set(3 downto 0) <= instr_word(9 downto 6);
						when '0' =>
							Reg_set(4) <= '0';
						end case;
						case clk_e is
						when '1' =>
							acc_ena <= '1';
						when '0' =>
							acc_ena <= '0';
						end case;			
					elsif inst_word_int > 6 and inst_word_int < 17 then --shift and rotate 2
						opcode <= "00000";
						case clk_s is
						when '1' =>
							Reg_set(4) <= '1'; Reg_set(3 downto 0) <= instr_word(9 downto 6);
						when '0' =>
							Reg_set(4) <= '0';
						end case;
						case clk_e is
						when '1' =>
							acc_ena <= '1';
						when '0' =>
							acc_ena <= '0';
						end case;			
					elsif inst_word_int = 17 or inst_word_int = 18 then --inc/dec 2
						case clk_s is
						when '1' =>
							Reg_set(4) <= '1'; Reg_set(3 downto 0) <= instr_word(9 downto 6);
						when '0' =>
							Reg_set(4) <= '0';
						end case;
						case clk_e is
						when '1' =>
							acc_ena <= '1';
						when '0' =>
							acc_ena <= '0';
						end case;					
					elsif inst_word_int = 19 then --cmp 2						
						case clk_e is
						when '1' =>
							Reg_ena(4) <= '1'; Reg_ena(3 downto 0) <= instr_word(9 downto 6);
							opcode <= "10011";
						when '0' =>
							Reg_ena <= "00000";
							opcode <= "00000";
						end case;			
					end if;
				else-- not ALU ooperation                     
					if inst_word_int = 20 then --load 2						
						case clk_s is
						when '1' =>
							Reg_set(4) <= '1'; Reg_set(3 downto 0) <= instr_word(9 downto 6);
						when '0' =>
							Reg_set(4) <= '0';
						end case;
						case clk_e is
						when '1' =>
							Mio_ctrl <= "11101";
						when '0' =>
							Mio_ctrl <= "00000";
						end case;
					elsif  inst_word_int = 21 then --store 2						
						case clk_s is
						when '1' =>
							Reg_ena(4) <= '1'; Reg_ena(3 downto 0) <= instr_word(5 downto 2);
						when '0' =>
							Reg_set(4) <= '0';
						end case;
						case clk_e is
						when '1' =>
							Mio_ctrl <= "10101";
						when '0' =>
							Mio_ctrl <= "00000";
						end case;
					elsif inst_word_int = 30 then --load immediate 2
						case clk_s is
						when '1' =>
							Reg_set(4) <= '1'; Reg_set(3 downto 0) <= instr_word(9 downto 6);
						when '0' =>
							Reg_set(4) <= '0';
						end case;
						case clk_e is
						when '1' =>
							Mio_ctrl <= "11100";
						when '0' =>
							Mio_ctrl <= "00000";							
						end case;	
					elsif inst_word_int = 28 then --j_subr 2					
						case clk_s is
						when '1' =>
							pc_set <= '1';
						when '0' =>
							pc_set <= '0';
						end case;
						case clk_e is
						when '1' =>
							Reg_ena(4) <= '1'; Reg_ena(3 downto 0) <= instr_word(5 downto 2);
						when '0' =>
							Reg_ena <= "00000";
						end case;
					end if; 
				end if;
			elsif step(5) = '1' then	
				if inst_word_int < 20 then --ALU operation						
					if  inst_word_int > 0 and inst_word_int < 6 then --add/sub/and/or/xor 3
						case clk_s is
						when '1' =>
							Reg_set(4) <= '1'; Reg_set(3 downto 0) <= instr_word(9 downto 6);
						when '0' =>
							Reg_set(4) <= '0';
						end case;
						case clk_e is
						when '1' =>
							acc_ena <= '1';
						when '0' =>
							acc_ena <= '0';
						end case;
					end if; --Not ALU
				elsif   inst_word_int = 30 then --load immediate 3						
						case clk_s is
						when '1' =>
							pc_set <= '1';
						when '0' =>
							pc_set <= '0';
						end case;
						case clk_e is
						when '1' =>
							acc_ena <= '1';
						when '0' =>
							acc_ena <= '0';
						end case;
				end if;			
			end if;
		end if;
	end process;	
end behaviour;