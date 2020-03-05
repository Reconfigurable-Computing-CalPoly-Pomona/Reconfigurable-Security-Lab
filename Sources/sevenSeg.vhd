----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/04/2020 03:48:35 PM
-- Design Name: 
-- Module Name: sevenSeg - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sevenSeg is
    Port ( Val : in STD_LOGIC_VECTOR (3 downto 0);
           Seg : out STD_LOGIC_VECTOR (6 downto 0));
end sevenSeg;

architecture Behavioral of sevenSeg is

begin
    process(Val) begin
        case(Val) is
            when "0000" =>
                Seg <= "1000000";
            when "0001" =>
                Seg <= "1111001";
            when "0010" =>
                Seg <= "0100100";
            when "0011" =>
                Seg <= "0110000";
            when "0100" =>
                Seg <= "0011001";
            when "0101" =>
                Seg <= "0010010";
            when "0110" =>
                Seg <= "0000010";
            when "0111" =>
                Seg <= "1111000";
            when "1000" =>
                Seg <= "0000000";
            when "1001" =>
                Seg <= "0010000";
            when "1010" =>
                Seg <= "0001000";
            when "1011" =>
                Seg <= "0000011";
            when "1100" =>
                Seg <= "0100111";
            when "1101" =>
                Seg <= "0100001";
            when "1110" =>
                Seg <= "0000110";
            when "1111" =>
                Seg <= "0001110";
            when others =>
                Seg <= "ZZZZZZZ";
        end case;
    end process;

end Behavioral;
