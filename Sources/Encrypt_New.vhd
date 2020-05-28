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

entity Encrypt is
Generic( iWidth : integer := 128;
         cWidth64 : integer := 5;
         xWidth32 : integer := 4;
         rWidth : integer := 128 );
  Port ( clk : in STD_LOGIC;
         eoc : in STD_LOGIC; -- 0 encrypt 1 decrypt 
         rst : in STD_LOGIC;
         en : in STD_LOGIC;
         TAGIN: in STD_LOGIC; -- Decrypt Only
         K : in STD_LOGIC_VECTOR(447 downto 0);
         S : in STD_LOGIC_VECTOR(127 downto 0);
         A : in STD_LOGIC_VECTOR(127 downto 0);
         NONCE:in STD_LOGIC_VECTOR(127 downto 0);
         P : in STD_LOGIC_VECTOR(127 downto 0);
         C : out STD_LOGIC_VECTOR(127 downto 0);
         TAG : out STD_LOGIC;
         done : out STD_LOGIC;
         FAILURE: OUT STD_LOGIC); -- Decrypt Only
end Encrypt;

architecture Behavioral of encrypt is
--components
component ksneq32 is
    Generic(MINWIDTH_K: integer := 128; KWIDTHMAX : integer  := 448; CWIDTH: integer  := 128; XWIDTH: integer := 64);
    Port (
        k: in STD_logic_vector(KWIDTHMAX-1 downto 0) ;
        kWidth : in std_logic_vector(1 downto 0) ;
        clk : in std_logic;
        reset : in std_logic;
        en : in std_logic;
        cout : out std_logic_vector(CWIDTH-1 downto 0) ;
        xout : out std_logic_vector(XWIDTH-1 downto 0) ;
        done : out std_logic 
    );
end component;

component absF is
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
        en : in std_logic;
        AoF : in std_logic;
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
            big: in std_logic;
            en : in std_logic;
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
        en : in std_logic;
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

--component ila_0
--PORT (
--clk : IN STD_LOGIC;


--    probe0 : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
--    probe1 : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
--    probe2 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
--    probe3 : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
--    probe4 : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
--    probe5 : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
--    probe6 : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
--    probe7 : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
--    probe8 : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
--    probe9 : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
--    probe10 : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
--    probe11 : IN STD_LOGIC_VECTOR(319 DOWNTO 0);
--    probe12 : IN STD_LOGIC_VECTOR(319 DOWNTO 0);
--    probe13 : IN STD_LOGIC_VECTOR(319 DOWNTO 0);
--    probe14 : IN STD_LOGIC_VECTOR(319 DOWNTO 0);
--    probe15 : IN STD_LOGIC_VECTOR(319 DOWNTO 0);
--    probe16 : IN STD_LOGIC;
--    probe17 : IN STD_LOGIC;
--    probe18 : IN STD_LOGIC;
--    probe19 : IN STD_LOGIC;
--    probe20 : IN STD_LOGIC;
--    probe21 : IN STD_LOGIC;
--    probe22 : IN STD_LOGIC;
--    probe23 : IN STD_LOGIC;
--    probe24 : IN STD_LOGIC;
--    probe25 : IN STD_LOGIC;
--    probe26 : IN STD_LOGIC;
--    probe27 : IN STD_LOGIC;
--    probe28 : IN STD_LOGIC;
--    probe29 : IN STD_LOGIC;
--    probe30 : IN STD_LOGIC;
--    probe31 : IN STD_LOGIC;
--    probe32 : IN STD_LOGIC;
--    probe33 : IN STD_LOGIC;
--    probe34 : IN STD_LOGIC;
--    probe35 : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
--    probe36 : IN STD_LOGIC_VECTOR(19 DOWNTO 0);
--    probe37 : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
--    probe38 : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
--    probe39 : IN STD_LOGIC;
--    probe40 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
--    probe41 : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
--    probe42 : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
--    probe43 : IN STD_LOGIC;
--    probe44 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
--    probe45 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
--    probe46 : IN STD_LOGIC
--);
--end component;
--signals
signal statec : STD_LOGIC_VECTOR(cWidth64*64 -1 downto 0);
signal x : STD_LOGIC_VECTOR(xWidth32*32-1 downto 0);
constant dss : STD_LOGIC_VECTOR(1 downto 0) := "10";
constant dsd : STD_LOGIC_VECTOR(1 downto 0) := "01";
constant dsa : STD_LOGIC_VECTOR(1 downto 0) := "10";
constant dsm : STD_LOGIC_VECTOR(1 downto 0) := "11";
signal DomSep : STD_LOGIC_VECTOR(1 downto 0);
signal r, newr, absFr,Fr : STD_LOGIC_VECTOR(rWidth - 1 downto 0);
signal newx, absFx, Fx, KSx : STD_LOGIC_VECTOR(xWidth32*32-1 downto 0);
signal newc, absFc, Fc, KSc, SDK : STD_LOGIC_VECTOR(cWidth64*64 -1 downto 0);
signal doneK, doneS1, doneS2, doneA, doneN1, doneN2, doneP, doneF, doneTAG: STD_LOGIC;
signal doneAbsF, doneSqe: STD_LOGIC;
signal rstK, rstAF, rstS : STD_LOGIC;
signal enK, enAF, enS: STD_LOGIC;
-- confusing signals
signal absFBlocks : STD_LOGIC_VECTOR(127 downto 0);
signal remainS : STD_LOGIC_VECTOR(19 downto 0);
signal Fi : STD_LOGIC_VECTOR(127 downto 0);
signal big: STD_LOGIC := '0';
signal setTag: STD_LOGIC := '1';
signal ctemp : std_logic_vector(P'LENGTH - 1 downto 0);
--end
signal AorF : STD_LOGIC := '0';
signal fin : STD_LOGIC;
signal tempSel: STD_LOGIC_VECTOR(7 downto 0);
signal PadIn : STD_LOGIC_VECTOR(127 downto 0);
signal PadOut : STD_LOGIC_VECTOR(127 downto 0);
signal padded : STD_LOGIC;
signal rounds : STD_LOGIC_VECTOR(3 downto 0);
signal DSlilm : STD_LOGIC_VECTOR(3 downto 0);
signal finalize : STD_LOGIC;
signal tagreg :STD_LOGIC;
signal doneTemp: STD_LOGIC := '0';
type stateMachine is (INIT, BeginEnc, StaticData1, StaticData2, NonceStep, Associated, CipherText1, CipherText2, CipherPostFor, Padd, TagFinal);
type selector is ('0', '1', '2', '3', '4');
signal State : stateMachine := INIT;
signal SEL : selector;
begin
process (clk,rst)
variable ints,inta,intm, i : integer;
begin
if (rising_edge(clk)) then
        ints := S'LENGTH/iWidth;
        inta := A'LENGTH/iWidth;
        intm := P'LENGTH/iWidth;
        if (rst = '1') then
            finalize <= '0';
            rounds <= std_logic_vector(to_unsigned(7,rounds'length));
            rstK <= '1';
            rstAF <= '1';
            rstS <= '1';
            enK <= '0';
            enAF <= '0';
            enS <= '0';
            setTag <= '0';
            doneS1 <= '0';
            doneS2 <= '0';
            doneN1 <= '0';
            doneN2 <= '0';
            doneTemp <= '0';
            state <= INIT;
        else
        case state is
            when INIT =>
                rounds <= std_logic_vector(to_unsigned(7,rounds'length));
                rstK <= '1';
                rstAF <= '1';
                rstS <= '1';
                tagreg <= TAGIN; 
                setTag <= '0';
                doneS1 <= '0';
                doneS2 <= '0';
                doneN1 <= '0';
                doneN2 <= '0';
                doneTemp <= '0';
                if (en = '0' or rst = '1') then
                    state <= INIT;
                elsif (en = '1') then
                    state <= BeginEnc;
                end if;
            when BeginEnc =>
                rstK <= '0';
                enK <= '1';
                DSlilm <= "0000";
                i := 0;
                SEL <= '2';
                if (doneK = '1') then
                     state <= StaticData1;
                     rstK <= '1';
                     enK <= '0';
                end if;
            when StaticData1 =>
                    absFBlocks <= S;
                    AorF <= '0';
                    doneS1 <= doneAbsF;
                    SEL <= '0';
                    Domsep <= dss;
                    if (ints > integer(0)) then
                        rstAF <= '0';
                        enAF <= '1';
                        if(doneS1 = '1') then
                            state <= StaticData2;
                            SEL <= '3';
                        end if;
                    else
                        state <= NonceStep;
                    end if;
            when StaticData2 =>
                rstS <= '0';
                rstAF <= '1';
                enAF <= '0';
                enS <= '1';
                Sel <= '3';
                RemainS <= conv_std_logic_vector(cWidth64*64,RemainS'Length);
                big <= '1';
                doneS2 <= doneSqe;
                if (doneS2 = '1') then
                    state <= NonceStep;
                    SEL <= '0';
                end if;
            when NonceStep =>
                rounds <= std_logic_vector(to_unsigned(11,rounds'length));
                Domsep <= dsd;
                Sel <= '0';
                rstS <= '1';
                enS <= '0';
                if((inta + intm) = 0) then
                    finalize <= '1';
                else
                    finalize <= '0';
                end if;
                absFBlocks <= NONCE;
                doneN1 <= doneAbsF;
                AorF <= '0';
                if (doneN1 = '1') then
                    state <= Associated;
                    absFBlocks <= A;
                    rstAF <= '1';
                    enAF <= '0';
                else
                    rstAF <= '0';
                    enAF <= '1';
                end if;
            when Associated =>
                rounds <= std_logic_vector(to_unsigned(7,rounds'length));
                Domsep <= dsa;
                rstAF <= '0';
                enAF <= '1';
                if(intm = 0) then
                    finalize <= '1';
                else
                    finalize <= '0';
                end if;
                absFBlocks <= A;
                doneN2 <= doneAbsF;
                AorF <= '0';
                if (doneN2 = '1') then
                    if (intm > 0) then
                        state <= CipherText1;--to cipher
                    else
                        state <= TagFinal;--to tag
                    end if;
                    SEL <= '1';
                    rstAF <= '1';
                    enAF <= '0';
                end if;
            when CipherText1 =>
                SEL <= '4';
                AorF <= '1';
                if( i < (intm - 1)) then    
                    if(eoc = '0') then
                    ctemp((i+1)*rWidth-1 downto i*rWidth) <= P((i+1)*rWidth-1 downto i*rWidth) xor r;
                    absFBlocks <= P((i+1)*rWidth-1 downto i*rWidth);
                    else
                    ctemp((i+1)*rWidth-1 downto i*rWidth) <= P((i+1)*rWidth-1 downto i*rWidth) xor r;
                    absFBlocks <= ctemp((i+1)*rWidth-1 downto i*rWidth);
                    end if;
                    if(doneAbsF = '1') then
--                        rstAF <= '1';
                        state <= CipherText2;
                    else
                        rstAF <= '0';
                        enAF <= '1';
                    end if;
                else
                    state <= CipherPostFor;
                end if;
            when CipherText2 =>
                rstAF <= '1';
                enAF <= '0';
                state <= CipherText1; 
                i := i + 1;
            when CipherPostFor =>
                if (C'Length mod rwidth = 0) then --match dim even cut
                    ctemp((i+1)*rWidth-1 downto i*rWidth) <= P((i+1)*rWidth-1 downto i*rwidth) xor r;
                else
                    ctemp(i*rWidth - 1 + C'Length mod rWidth downto i*rWidth) <= P(i*rWidth - 1 + C'Length mod rWidth downto i*rWidth) xor r(i*rWidth + C'Length mod rWidth downto 0);
                end if;
                if(eoc = '0') then
                PadIn <= P((i+1)*rWidth -1 downto i*rwidth);
                else
                PadIn <= ctemp((i+1)*rWidth -1 downto i*rwidth);
                end if;
                finalize <= '1';
                state <= Padd;
            when Padd =>
                rstAF <= '0';
                enAF <= '1';
                AorF <= '1';
--                {domain,finalize,padded}
                DSlilm <= dsm & finalize & padded;
                SEL <= '4';
                if(eoc='0')then
                absFBlocks <= P((i+1)*rWidth-1 downto i*rWidth);
                else
                absFBlocks <= ctemp((i+1)*rWidth-1 downto i*rWidth);
                end if;
                if (doneAbsF = '1')then
                    rstS <= '1';
                    enS <= '0';
                    state <= TagFinal;
                    big <= '0';
                end if;
            when TagFinal =>
                if(setTag = '0') then
                    rstAF <= '1';
                    enAF <= '0';
                    SEL <= '3';
                    rstS <= '0';
                    enS <= '1';
                    doneTag <= doneSqe;
                    if (doneTag = '1')then
                        C <= ctemp;
                        rstS <= '1';
                        enS <= '0';
                        setTag <= '1';
                        doneTemp <= '1'; -- after last action
                        if(eoc ='1')then
                            if(newc(0)= tagreg) then
                            failure <= '0';
                            else
                            failure <= '1';
                        end if; 
                       end if;
                    end if;
                else
                    rstK <= '1';
                    rstAF <= '1';
                    rstS <= '1';
                    enK <= '0';
                    enAF <= '0';
                    enS <= '0';
                    if(rst = '1') then
                        state <= INIT;
                    end if;
                end if;
            when others => finalize <= '0';
        end case;
        end if;
        fin <= finalize;
end if;
done <= doneTemp;
end process;

SetXCR: process (SEL,clk) begin
    if (rising_edge(clk)) then
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
            newc <= absFc;
            newx <= absFx;
            newr <= absFr;
        when others =>
            newc <= (others => '0');
            newx <= (others => '0');
            newr <= (others => '0');
    end case;
    end if;
end process SetXCR;

dataFF: process (clk) begin
if (rising_edge(clk)) then
    if (rst = '1') then
        statec <= (others => '0');
        x <= (others => '0');
        r <= (others => '0');
        TAG <= '0';
    elsif (doneK = '1') then
        x <= newx;
        statec <= newc;
    elsif(doneAbsF = '1' or doneF = '1') then
        statec <= newc;
        x <= newx;
        r <= newr;
    elsif (doneTag = '1')then
        TAG <= newc(0);
    elsif (doneSqe = '1') then
        statec <= newc;
    end if;
end if;
end process dataFF; 

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
    en => enK,
    cout => KSc,
    xout => KSx ,
    done => doneK
);

Absor: absF generic map(
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
    blocks => absFBlocks,
    finalize => fin,
    clk => clk,
    reset => rstAF,
    en => enAF,
    domain => DomSep,
    AoF => AorF,
    cout => absFc,
    rout => absFr,
    xout => absFx,
    done => doneAbsF,
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
    en => enS,
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

pading: padding2 Generic map ( 
    IWIDTH => 128,
    BWIDTH => 128
)
port map ( 
   blockIn => PadIn,
   blockOut => PadOut,
   padded => padded
);
--ila_fck: ila_0 port map
--(
--clk => clk,
--probe0 => statec,
--probe1 => x,
--probe2 =>DomSep,
--probe3 =>r,
--probe4 =>newr,
--probe5 =>absFr,
--probe6 =>Fr,
--probe7 =>newx,
--probe8 =>absFx,
--probe9 =>Fx,
--probe10 =>KSx,
--probe11 =>newc,
--probe12 =>absFc,
--probe13 =>Fc,
--probe14 =>KSc,
--probe15 =>SDK,
--probe16 =>doneK,
--probe17 =>doneS1,
--probe18 =>doneS2,
--probe19 =>doneA,
--probe20 =>doneN1,
--probe21 =>doneN2,
--probe22 =>doneP,
--probe23 =>doneF,
--probe24 =>doneTAG,
--probe25 =>doneAbsF,
--probe26 =>doneSqe,
--probe27 =>rstK,
--probe28 =>rstAF,
--probe29 =>rstS,
--probe30 =>rstF,
--probe31 =>enK,
--probe32 =>enAF,
--probe33 =>enS,
--probe34 =>enF,
--probe35 =>absFBlocks,
--probe36 =>remainS,
--probe37 =>Fi,
--probe38 =>ctemp,
--probe39 =>fin,
--probe40 =>tempSel,
--probe41 =>PadIn,
--probe42 =>PadOut,
--probe43 =>padded,
--probe44 =>rounds,
--probe45 =>DSlilm,
--probe46 => finalize);
end Behavioral;
