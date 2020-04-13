----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/11/2020 06:42:49 PM
-- Design Name: 
-- Module Name: sboxV2 - Behavioral
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
use IEEE.math_real.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sboxV2 is
    Generic( CWIDTH : integer := 128);
    Port ( 
        c : in std_logic_vector(CWIDTH-1 downto 0);
        cout : out std_logic_vector(CWIDTH-1 downto 0);
        reset: in std_logic;
        en: in std_logic;
        clk : in std_logic;
        doneOut: out std_logic
    );
end sboxV2;

architecture Behavioral of sboxV2 is
component ALU is
    Port(
        a,b: in std_logic_vector(63 downto 0);
        mode: in std_logic_vector(1 downto 0);
        y: out std_logic_vector(63 downto 0)
    );
end component;
constant CWORDS64 : integer := CWIDTH/64;
constant MID : integer := (CWORDS64 - 1)/2;

signal i : unsigned(integer(ceil(log2(real(CWORDS64)))) - 1 downto 0);
signal i2: unsigned(integer(ceil(log2(real(CWORDS64)))) - 1 downto 0);
signal i3: unsigned(integer(ceil(log2(real(CWORDS64)))) - 1 downto 0);
signal i4: unsigned(integer(ceil(log2(real(CWORDS64)))) - 1 downto 0);
signal d : unsigned(integer(ceil(log2(real(CWORDS64)))) - 1 downto 0);
signal s : unsigned(integer(ceil(log2(real(CWORDS64)))) - 1 downto 0);
signal done1, done2, done3, done4, done5: std_logic;
signal mode : std_logic_vector(1 downto 0);
signal CReg, TReg : std_logic_vector(CWIDTH - 1 downto 0);
signal CSel1, CSel2, outALU : std_logic_vector(63 downto 0);
type stateMachine is (RST, INIT, LOOP1, LOOP2, LOOP3, LOOP4, LOOP5, DON);
signal curr_state,next_state : stateMachine := RST;
type Cycle is (Read,Write);
signal RW : Cycle := Write;
begin

NFSM: process (RW,curr_state, en, done1, done2, done3, done4, done5) begin
    case curr_state is
        when RST => 
            if (en = '1') then
                next_state <= INIT;
            else
                next_state <= RST;
            end if;
        when INIT =>
            next_state <= LOOP1;
        when LOOP1 =>
            if(done1 = '1') then
                next_state <= LOOP2;
            else
                next_state <= LOOP1;
            end if;
        when LOOP2 =>
            if(done2 = '1') then
                next_state <= LOOP3;
            else
                next_state <= LOOP2;
            end if;
        when LOOP3 =>
            if(done3 = '1') then
                next_state <= LOOP4;
            else
                next_state <= LOOP3;
            end if;
        when LOOP4 =>
            if(done4 = '1') then
                next_state <= LOOP5;
            else
                next_state <= LOOP4;
            end if;
        when LOOP5 =>
            if(done5 = '1') then
                next_state <= DON;
            else
                next_state <= LOOP5;
            end if;
        when DON =>
            next_state <= DON;
        when others => 
            next_state <= RST;
    end case;
end process NFSM;

CFSM : process(clk) begin
    if(rising_edge(clk)) then
        if (reset = '1') then
            curr_state <= RST;
        elsif (RW = read or (RW=Write and (curr_state = RST or curr_state = INIT))) then
            curr_state <= next_state;
        else
            curr_state <= curr_state;
        end if;
        
    end if;
end process CFSM;

Calc: process (clk) 
    variable sel1, sel2 : integer;
begin
    if (rising_edge(clk)) then
        if (RW = Write) then
            case(curr_state) is
                when RST => 
                    CReg <= (others => '0');
                    TReg <= (others => '0');
                    CSel1 <= (others => '0');
                    CSel2 <= (others => '0');
                    mode <= "00";
                    RW <= Write;
                    doneOut <= '0';
                when INIT =>
                    CReg <= c;
                    mode <= "00";
                    RW <= Write;
                when LOOP1 =>
                    sel1 := to_integer(i(integer(ceil(log2(real(CWORDS64)))) - 1 downto 0) sll 1);
                    sel2 := (CWORDS64 + sel1 - 1) mod CWORDS64;
                    CSel1 <= CReg(64*(sel1+1) - 1 downto 64*sel1);
                    CSel2 <= CReg(64*(sel2+1) - 1 downto 64*sel2);
                    mode <= "00";
                    RW <= Read;
                when LOOP2 =>
                    sel1 := to_integer(i2(integer(ceil(log2(real(CWORDS64)))) - 1 downto 0));
                    sel2 := (sel1 + 1) mod CWORDS64;
                    CSel1 <= CReg(64*(sel1+1) - 1 downto 64*sel1);
                    CSel2 <= CReg(64*(sel2+1) - 1 downto 64*sel2);
                    mode <= "01";
                    RW <= Read;
                when LOOP3 =>
                    sel1 := to_integer(i3(integer(ceil(log2(real(CWORDS64)))) - 1 downto 0));
                    sel2 := (sel1 + 1) mod CWORDS64;
                    CSel1 <= CReg(64*(sel1+1) - 1 downto 64*sel1);
                    CSel2 <= TReg(64*(sel2+1) - 1 downto 64*sel2);
                    mode <= "00";
                    RW <= Read;
                when LOOP4 =>
                    sel2 := to_integer(i4(integer(ceil(log2(real(CWORDS64)))) - 1 downto 0) sll 1);
                    sel1 := (sel2 + 1) mod CWORDS64;
                    CSel1 <= CReg(64*(sel1+1) - 1 downto 64*sel1);
                    CSel2 <= CReg(64*(sel2+1) - 1 downto 64*sel2);
                    mode <= "00";
                    RW <= Read;
                when LOOP5 =>
                    sel1 := MID;
                    CSel1 <= TReg(64*(sel1+1) - 1 downto 64*sel1);
                    mode <= "10";
                    RW <= Read;
                when DON =>
                    cout <= CReg;
                    doneOut <= '1';
            end case;
        else
            if (curr_state = LOOP2 or curr_state = LOOP5) then
                TReg(64*(sel1+1) - 1 downto 64*sel1) <= outALU;
            else
                CReg(64*(sel1+1) - 1 downto 64*sel1) <= outALU;
            end if;
            RW <= Write;
        end if;
    end if;
end process Calc;

Counters: process(clk) begin
    if (rising_edge(clk)) then
        if (curr_state = RST) then
            i <= (others => '0');
            i2 <= (others => '0');
            i3 <= (others => '0');
            i4 <= (others => '0');
        elsif (RW = Read) then
            if (curr_state = LOOP1) then
                i <= i + 1;
                i2 <= i2;
                i3 <= i3;
                i4 <= i4;
            elsif (curr_state = LOOP2) then
                i <= i;
                i2 <= i2 + 1;
                i3 <= i3;
                i4 <= i4;
            elsif (curr_state = LOOP3) then
                i <= i;
                i2 <= i2;
                i3 <= i3 + 1;
                i4 <= i4;
            elsif (curr_state = LOOP4) then
                i <= i;
                i2 <= i2;
                i3 <= i3;
                i4 <= i4 + 1;
            end if;
        end if;
    end if;
end process Counters;

doneFlags: process(i,i2,i3,i4, RW) begin
        if(i < to_unsigned(MID,integer(ceil(log2(real(CWORDS64)))))) then
            done1 <= '0';
        else
            done1 <= '1';
        end if;
        if(i2 < to_unsigned(CWORDS64 - 1,integer(ceil(log2(real(CWORDS64)))))) then
            done2 <= '0';
        else
            done2 <= '1';
        end if;
        if(i3 < to_unsigned(CWORDS64 - 1,integer(ceil(log2(real(CWORDS64)))))) then
            done3 <= '0';
        else
            done3 <= '1';
        end if;
        if(i4 < to_unsigned(MID,integer(ceil(log2(real(CWORDS64)))))) then
            done4 <= '0';
        else
            done4 <= '1';
        end if;
        if (done4 = '1' and RW = Read) then
            done5 <= '1';
        else
            done5 <= '0';
        end if;
end process doneFlags;

ALUnit: ALU port map(
    a => CSel1,
    b => CSel2,
    mode => mode,
    y => outALU
);

end Behavioral;
