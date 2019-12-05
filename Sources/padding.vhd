----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/20/2019 10:46:25 PM
-- Design Name: 
-- Module Name: padding - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity padding is
generic ( g_block_in_size:Integer:= 32;
          g_block_out_size:Integer:= 64;
          g_i_width:Integer:= 64); 
Port ( 
           i_block_in: in std_logic_vector(g_block_in_size-1 downto 0);
           o_block_out: out std_logic_vector(g_block_out_size-1 downto 0);
           i_clk      : in std_logic;
           o_padded: out std_logic
            );
end padding;

architecture Behavioral of padding is
signal c_I: integer:=0; 
signal c_size_check: integer:= g_block_in_size;
signal c_block_out_reg: std_logic_vector ( g_block_out_size -1 downto 0);  
type t_State is (s_Pad_start, s_length_check, s_for_loop,
                     s_Done);
  signal r_SM_Main : t_State := s_Pad_start;
begin
    p_state_machine: process(i_clk,i_block_in)
                        begin
                        if rising_edge(i_clk) then
                            case r_SM_main is 
                                    when s_Pad_start => -- start padded is zero and bo = bi
                                    c_block_out_reg(g_block_in_size-1 downto 0) <= i_block_in; --bo = bi         
                                    o_padded <= '0'; -- padded is zero
                                    r_SM_main <= s_length_check; -- go to if statement
                                    when s_length_check=>
                                    if(i_block_in'length < g_i_width) then -- if input block length is less than our I width set padded to 1 and start the padding
                                        o_padded <= '1'; -- duh
                                        r_SM_main <= s_for_loop; -- next state 
                                    else
                                        r_SM_main <= s_done; -- otherwise we are done
                                        end if;
                                    when s_for_Loop => -- for loop 
                                        if ( c_I < g_i_width-2) then -- our for loop with integer I
                                            c_block_out_reg <= std_logic_vector(shift_left(unsigned(c_block_out_reg),1)); -- shift left and concatinate zero 
                                            c_I <= c_I+1; -- increment
                                            r_SM_main <= s_for_Loop; -- back into iteself
                                        else
                                            c_block_out_reg <= std_logic_vector(shift_left(unsigned(c_block_out_reg),1)); -- otherwise concact 1 
                                            c_block_out_reg(0) <= '1'; -- 1 
                                            r_SM_main <= s_Done; -- done
                                        end if;
                                    when s_Done => 
                                        o_block_out<=c_block_out_reg;  --donezo register to output
                                        r_SM_main <= s_Done; -- loop in on itself, we will probably have to change this later to make it be able to be used like an enable or something
                             end case; 
                         end if;
                    end process; 
end Behavioral;
