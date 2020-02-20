----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/21/2020 04:14:21 PM
-- Design Name: 
-- Module Name: Encrypt - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;

use ieee.numeric_std.all;


-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Decrypt is
Generic( iWidth : integer := 128;
         cWidth64 : integer := 5;
         xWidth32 : integer := 4;
         rWidth : integer := 128 );
  Port ( clk : in STD_LOGIC;
         start: in STD_LOGIC;
         rst : in STD_LOGIC;
         K : in STD_LOGIC_VECTOR(447 downto 0);
         S : in STD_LOGIC_VECTOR(127 downto 0);
         A : in STD_LOGIC_VECTOR(127 downto 0);
         NONCE:in STD_LOGIC_VECTOR(127 downto 0);
         P : out STD_LOGIC_VECTOR(127 downto 0);
         C : in STD_LOGIC_VECTOR(127 downto 0);
         TAG : in STD_LOGIC_VECTOR(0 downto 0);
         failure : out STD_LOGIC;
         done : out STD_LOGIC);
end Decrypt;

architecture Behavioral of Decrypt is
--components
component ksneq32 is
    Generic(MINWIDTH_K: integer := 128; KWIDTHMAX : integer  := 448; CWIDTH: integer  := 128; XWIDTH: integer := 64);
    Port (
        k: in STD_logic_vector(KWIDTHMAX-1 downto 0) ;
        kWidth : in std_logic_vector(1 downto 0) ;
        clk : in std_logic;
        reset : in std_logic;
        cout : out std_logic_vector(CWIDTH-1 downto 0) ;
        xout : out std_logic_vector(XWIDTH-1 downto 0) ;
        done : out std_logic 
    );
end component;

component absorb is
    Generic(CWIDTH : integer := 320; RWIDTH : integer := 32; XWIDTH: integer := 64;
                BWIDTH : integer := 32; NUMBLOCKS: integer := 4); 
    Port(
        c : in std_logic_vector(CWIDTH-1 downto 0);
        r : in std_logic_vector(RWIDTH-1 downto 0);
        x : in std_logic_vector(XWIDTH-1 downto 0);
        blocks : in std_logic_vector((BWIDTH*NUMBLOCKS)-1 downto 0);
        rounds : in std_logic_vector(3 downto 0);
        finalize : in std_logic;
        clk: in std_logic; 
        reset: in std_logic;
        domain : in std_logic_vector(1 downto 0);
        cout : out std_logic_vector(CWIDTH-1 downto 0);
        rout : out std_logic_vector(RWIDTH-1 downto 0);
        xout : out std_logic_vector(XWIDTH-1 downto 0);
        done : out std_logic 
    );
end component;

component squeez 
    Generic (CWIDTH : integer := 320; RWIDTH : integer := 32; DATA_SIZE: integer := 32;
                REMAINWIDTH: integer := 20; ROUND_COUNT :integer := 10);
    Port(
            clk : in std_logic;
            reset: in std_logic; 
            big : in std_logic;
            seldone : out std_logic;
            Gdone : out  std_logic;
            c : in std_logic_vector(CWIDTH-1 downto 0); -- capacity
            Bdata : out std_logic_vector(CWIDTH-1 downto 0); --output data
            r : in std_logic_vector(RWIDTH-1 downto 0); -- state I think
            remaining : in std_logic_vector(REMAINWIDTH-1 downto 0);
            rounds : in std_logic_vector(ROUND_COUNT-1 downto 0);
            squeezDone : out std_logic 
    );  
end component;

component F
    Generic (CWIDTH : integer := 320; XWORDS32: integer := 9; DS_WIDTH: integer := 128;
                RWIDTH : integer := 32; ROUND_COUNT : integer := 10);
    Port(
        clk : in std_logic; 
        reset : in std_logic;
        c : in std_logic_vector(CWIDTH-1 downto 0);
        x : in std_logic_vector(XWORDS32*32-1 downto 0);
        i : in std_logic_vector(127 downto 0);
        ds : in std_logic_vector (DS_WIDTH-1 downto 0);
        rounds : in std_logic_vector(ROUND_COUNT-1 downto 0);
        cout : out std_logic_vector(CWIDTH-1 downto 0);
        xout : out std_logic_vector(XWORDS32*32-1 downto 0);
        rout : out std_logic_vector(RWIDTH-1 downto 0);
        done : out std_logic 
    );
end component;

component padding2 is
    Generic (IWIDTH : integer := 64; BWIDTH : integer := 32);
    Port (
        blockIn : in std_logic_vector(BWIDTH-1 downto 0);
        blockOut: out std_logic_vector(IWIDTH-1 downto 0);
        padded : out std_logic 
    );
end component;

component selec_t 
    Generic(INPUT_WIDTH: integer := 8; OUT_WIDTH :integer := 4);
    Port(
        inputVal : in std_logic_vector(INPUT_WIDTH-1 downto 0);
        index : in std_logic_vector(integer(ceil(log2(real(INPUT_WIDTH/OUT_WIDTH)))) - 1 downto 0);
        out1 : out std_logic_vector(OUT_WIDTH-1 downto 0);
        reset : in std_logic
    );
end component;
--signals
signal statec : STD_LOGIC_VECTOR(cWidth64*64 -1 downto 0);
signal x : STD_LOGIC_VECTOR(xWidth32*32-1 downto 0);
constant dss : STD_LOGIC_VECTOR(1 downto 0) := "10";
constant dsd : STD_LOGIC_VECTOR(1 downto 0) := "01";
constant dsa : STD_LOGIC_VECTOR(1 downto 0) := "10";
constant dsm : STD_LOGIC_VECTOR(1 downto 0) := "11";
signal DomSep : STD_LOGIC_VECTOR(1 downto 0);
signal r, newr, absr,Fr : STD_LOGIC_VECTOR(rWidth - 1 downto 0);
signal newx, absx, Fx, KSx : STD_LOGIC_VECTOR(xWidth32*32-1 downto 0);
signal newc, absc, Fc, KSc, SDK : STD_LOGIC_VECTOR(cWidth64*64 -1 downto 0);
signal doneK, doneS1, doneS2, doneA, doneN1, doneN2, doneP, doneF, doneTAG: STD_LOGIC;
signal doneAbs, doneSqe: STD_LOGIC;
signal rstK, rstA, rstS, rstF : STD_LOGIC;
-- confusing signals
signal absBlocks : STD_LOGIC_VECTOR(127 downto 0);
signal remainS : STD_LOGIC_VECTOR(19 downto 0);
signal Fi : STD_LOGIC_VECTOR(127 downto 0);
signal ptemp : std_logic_vector(P'LENGTH - 1 downto 0);
signal firstDone, big : std_logic := '0';
signal newTAG : std_logic_vector(0 downto 0);
signal rounds : STD_LOGIC_VECTOR(3 downto 0);
--end
signal fin : STD_LOGIC;
signal tempSel: STD_LOGIC_VECTOR(7 downto 0);
signal PadIn : STD_LOGIC_VECTOR(127 downto 0);
signal PadOut : STD_LOGIC_VECTOR(127 downto 0);
signal padded : STD_LOGIC;
signal DSlilm : STD_LOGIC_VECTOR(3 downto 0);
type stateMachine is (BeginEnc, StaticData1, StaticData2, NonceStep, Associated, CipherText1, CipherText2, CipherPostFor, Padd, TagFinal);
type selector is ('0', '1', '2', '3', '4');
signal State : stateMachine := TagFinal;
signal SEL : selector;

begin
process (clk, start)
variable ints,inta,intm, i : integer;
variable finalize : STD_LOGIC;
variable doneTemp: STD_LOGIC := '1';
begin
if (rising_edge(clk)) then
        ints := S'LENGTH/iWidth;
        inta := A'LENGTH/iWidth;
        intm := P'LENGTH/iWidth;
        finalize := '0';
        case state is
            when BeginEnc =>
                if (doneTemp = '1') then
                    rounds <= std_logic_vector(to_unsigned(7,rounds'length));
                    rstK <= '1';
                    rstA <= '1';
                    rstS <= '1';
                    rstF <= '1';
                else
                    rstK <= '0';
                    DSlilm <= "0000";
                end if;
                 if (start = '1'or doneTemp = '0') then
                    doneTemp := '0';
                    i := 0;
                    SEL <= '2';
                    if (doneK = '1') then
                         state <= StaticData1;
                         statec <= newc;
                         x <= newx;
                         r <= (others => '0');
                         rstK <= '1';
                    end if;
                 end if;
            when StaticData1 =>
                    absBlocks <= S;
                    doneS1 <= doneAbs;
                    SEL <= '0';
                    Domsep <= dss;
                    if (ints > integer(0)) then
                        rstA <= '0';
                        if(doneS1 = '1') then
                            state <= StaticData2;
                            statec <= newc;
                            x <= newx;
                            r <= newr;
                            SEL <= '3';
                        end if;
                    else
                        state <= NonceStep;
                    end if;
            when StaticData2 =>
                rstS <= '0';
                rstA <= '1';
                Sel <= '3';
                RemainS <= conv_std_logic_vector(cWidth64*64,RemainS'Length);
                big <= '1';
                doneS2 <= doneSqe;
                
                if (doneS2 = '1') then
                    state <= NonceStep;
                    statec <= newc;
                    SEL <= '0';
                end if;
            when NonceStep =>
                rounds <= std_logic_vector(to_unsigned(11,rounds'length));
                Domsep <= dsd;
                Sel <= '0';
                rstS <= '1';
                
                if((inta + intm) = 0) then
                    finalize := '1';
                else
                    finalize := '0';
                end if;
                absBlocks <= NONCE;
                doneN1 <= doneAbs;
                if (doneN1 = '1') then
                    state <= Associated;
                    statec <= newc;
                    r <= newr;
                    x <= newx;
                    absBlocks <= A;
                    rstA <= '1';
                else
                    rstA <= '0';
                end if;
            when Associated =>
                rounds <= std_logic_vector(to_unsigned(7,rounds'length));
                Domsep <= dsa;
                rstA <= '0';
                if(intm = 0) then
                    finalize := '1';
                else
                    finalize := '0';
                end if;
                absBlocks <= A;
                doneN2 <= Doneabs;
                if (doneN2 = '1') then
                    if (intm > 0) then
                        state <= CipherText1;--to cipher
                    else
                        state <= TagFinal;--to tag
                    end if;
                    statec <= newc;
                    r <= newr;
                    x <= newx;
                    SEL <= '1';
                    rstA <= '1';
                end if;
            when CipherText1 =>
                SEL <= '4';
                if( i < (intm - 1)) then    
                    ptemp((i+1)*rWidth-1 downto i*rWidth) <= C((i+1)*rWidth-1 downto i*rWidth) xor r;
                    Fi <= ptemp((i+1)*rWidth-1 downto i*rWidth);
                    if(doneF = '1') then
--                        rstF <= '1';
                        state <= CipherText2;
                    else
                        rstF <= '0';
                    end if;
                else
                    state <= CipherPostFor;
                end if;

            when CipherText2 =>
                statec <= newC;
                x <= newx;
                r <= newr;
                state <= CipherText1; 
            when CipherPostFor =>
                if (C'Length mod rwidth = 0) then --match dim even cut
                    ptemp((i+1)*rWidth-1 downto i*rWidth) <= C((i+1)*rWidth-1 downto i*rwidth) xor r;
                else
                    ptemp(i*rWidth - 1 + C'Length mod rWidth downto i*rWidth) <= C(i*rWidth - 1 + C'Length mod rWidth downto i*rWidth) xor r(i*rWidth + C'Length mod rWidth downto 0);
                end if;
                PadIn <= ptemp((i+1)*rWidth -1 downto i*rwidth);
                finalize:= '1';
                state <= Padd;
            when Padd =>
                rstF <= '0';
--                {domain,finalize,padded}
                DSlilm <= dsm & finalize & padded;
                SEL <= '4';
                Fi <= ptemp((i+1)*rWidth-1 downto i*rWidth);
                if (doneF = '1')then
                    rstS <= '1';
                    statec <= newc;
                    x <= newx;
                    r <= newr;
                    state <= TagFinal;
                    big <= '0';
                    rstS <= '0';
                end if;
            when TagFinal =>
                if(doneTemp = '0') then
                    rstF <= '1';
                    SEL <= '3';
                    rstS <= '0';
                    doneTag <= doneSqe;
                    if (doneTAG = '1')then
                        newTAG <= newc(0 downto 0);
                        firstDone <= '1';
                        rstS <= '1';
                        doneTemp := '1'; -- after last action
                    end if;
                else
                    if(firstDone = '1') then
                        firstDone <= '0';
                        if(newTAG = TAG) then
                            P <= ptemp;
                            failure <= '0';
                        else
                            failure <= '1';
                        end if;
                    else
                        firstDone <= '0';
                        rstK <= '1';
                        rstA <= '1';
                        rstS <= '1';
                        rstF <= '1';
                        if(rst = '1') then
                            state <= BeginEnc;
                        end if;
                    end if;
                end if;
            when others => finalize := '0';
        end case;
        fin <= finalize;
end if;
done <= doneTemp;
end process;

SetXCR: process (SEL,clk) begin
    case SEL is 
        when '4' =>
            newc <= Fc;
            newx <= Fx;
            newr <= Fr;
        when '3' =>
            newc <= SDK;
        when '2' =>
            newc <= KSc;
            newx <= KSx;
        when '1' =>
            newc <= Fc;
            newx <= Fx;
            newr <= Fr;
        when '0' =>
            newc <= absc;
            newx <= absx;
            newr <= absr;
    end case;
end process SetXCR;

KS: ksneq32 generic map(
    MINWIDTH_K => 128,
    KWIDTHMAX => 448,
    CWIDTH => cWidth64*64,
    XWIDTH => xWidth32*32
)
port map(
    k => K,
    kWidth => "00",
    clk => clk,
    reset => rstK, 
    cout => KSc,
    xout => KSx ,
    done => doneK
);

Absor: absorb generic map(
    CWIDTH => cWidth64*64,
    RWIDTH => rWidth,
    XWIDTH => xWidth32*32,
    BWIDTH => 128,
    NUMBLOCKS => 1
)
port map(
    c => statec,
    r => r,
    x => x,
    blocks => absBlocks,
    finalize => fin,
    clk => clk,
    reset => rstA,
    domain => DomSep,
    cout => absc,
    rout => absr,
    xout => absx,
    done => doneAbs,
    rounds => rounds
);

Sqeez: squeez generic map(
    CWIDTH => cWidth64*64,
    RWIDTH => rWidth,
    DATA_SIZE => 32,
    REMAINWIDTH => 20,
    ROUND_COUNT => 10
)
port map(
    clk => clk,
    reset => rstS,
    seldone => open,
    Gdone => open,
    c => statec, -- capacity
    Bdata => SDK, --output data
    r => r, -- state I think
    remaining => remainS,
    rounds => "0000000111",
    squeezDone => doneSqe,
    big => big
);

encF : F generic map(
    CWIDTH => cWidth64*64,
    XWORDS32 => xWidth32,
    DS_WIDTH => 4,
    RWIDTH => rWidth,
    ROUND_COUNT => 10
)
port map(
    clk => clk, 
    reset => rstF,
    c => statec,
    x => x,
    i => Fi,
    ds => DSlilm,
    rounds => "0000000111",
    cout => Fc,
    xout => Fx,
    rout => Fr,
    done => doneF
);

pading: padding2 Generic map ( 
    IWIDTH => 128,
    BWIDTH => 128
)
port map ( 
   blockIn => PadIn,
   blockOut => PadOut,
   padded => padded
);
end Behavioral;
