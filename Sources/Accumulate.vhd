----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/16/2019 01:39:50 PM
-- Design Name: 
-- Module Name: Accumulate - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use IEEE.MATH_REAL.ALL;
--use IEEE.MATH_REAL.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Accumulate is
    Generic(
            StateSize: integer := 128; 
            CapacitySize: integer := 1024);
    Port (  
            clk: in STD_LOGIC;
            state: in STD_LOGIC_VECTOR(StateSize - 1 downto 0);
            capacity: in STD_LOGIC_VECTOR(CapacitySize -1 downto 0);
            newState: out STD_LOGIC_VECTOR(StateSize -1 downto 0);
            start: in STD_LOGIC;
            done: out STD_LOGIC
         );
end Accumulate;

architecture Behavioral of Accumulate is


signal cpartSel: STD_LOGIC_VECTOR(31 downto 0);
signal k: STD_LOGIC_VECTOR(integer(ceil(log2(real(capacitySize/StateSize)))) - 1 downto 0);
signal i: STD_LOGIC_VECTOR(integer(ceil(log2(real(StateSize/32)))) - 1 downto 0);
signal tmp,tmp2,tempOut: STD_LOGIC_VECTOR(StateSize - 1 downto 0);
signal running: STD_LOGIC:= '0';
signal enableI : STD_LOGIC:= '0';
signal enableK : STD_LOGIC:= '0';
signal enableMux: STD_LOGIC:= '0';
signal endI: STD_LOGIC := '0';
signal endK: STD_LOGIC := '0';
signal J: integer := 0;
signal L: integer := 0;
signal Lflag: STD_LOGIC;
signal tick: STD_LOGIC;
signal stateSave: STD_LOGIC_VECTOR(StateSize - 1 downto 0);
begin

process(clk) 
variable itmp, ktmp: STD_LOGIC_VECTOR(StateSize - 1 downto 0);
variable AF,nw,low,high: integer;
variable cpart:  STD_LOGIC_VECTOR(StateSize - 1 downto 0);
begin
nw := StateSize/32; 
AF := CapacitySize/StateSize;
if rising_edge(clk) then
    if start = '1' and running = '0' then
    running <= '0';
    ktmp := state;
    for J in 0 to AF -1 loop
        cpart := capacity((J+1)*StateSize - 1 downto J*StateSize);
        for L in 0 to nw -1 loop
            low := ((L+J)mod nw)*32;
            high := low + 32;
            itmp((L+1)*32 - 1 downto L*32) := ktmp((L+1)*32 - 1 downto L*32) xor cpart(high -1 downto low);
        end loop;
        ktmp := itmp;
    end loop;
    newstate <= ktmp;
    done <= '1';
    else
        done <= '0';
    end if;
end if;
if state = stateSave then
else
    running <= '0';
    stateSave <= state;
end if;
end process;
end Behavioral;
