library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity LCD1602 is
Port ( CLK : in std_logic; --״̬��ʱ���źţ�ͬʱҲ��Һ��ʱ���źţ�������Ӧ������Һ�����ݵĽ��ʱ��
Reset:in std_logic; 
LCD_RS : out std_logic; --�Ĵ���ѡ���ź�
LCD_RW : out std_logic; --Һ����д�ź�
LCD_EN : out std_logic; --Һ��ʱ���ź�
------------------------------------------------------BOMBA
Entrada1: in std_logic;
Salida1: out std_logic;
clk_out1: out std_logic;
-------------------------------------------------------------BOMBA
LCD_Data : out std_logic_vector(7 downto 0); --Һ�������ź�
-----------------------------bomba 2 
key_in : in std_logic_vector (0 downto 0);     
led_out : out std_logic_vector(0 downto 0));  --LED OUTPUT

-----------------------------------------
end LCD1602;


architecture Behavioral of LCD1602 is
type state is (set_dlnf,set_cursor,set_dcb,set_cgram,write_cgram,set_ddram,write_LCD_Data);
signal Current_State:state;
----------------------------------------------------------BOMBA
signal contadorA: integer range 0 to 20000;
signal clk_1: std_logic;
signal reset1: std_logic;
signal count : unsigned(32 downto 0) := (others => '0');
signal brightness1 : std_logic;
-------------------------------------------------------------BOMBA

type ram1 is array(0 to 30) of std_logic_vector(7 downto 0);
type ram2 is array(0 to 30) of std_logic_vector(7 downto 0);
type ram3 is array(0 to 30) of std_logic_vector(7 downto 0);
type ram4 is array(0 to 30) of std_logic_vector(7 downto 0);
constant cgram1:ram1:=(x"55",x"2e",x"20",x"4e",x"41",x"43",x"49",x"4f",x"4e",x"41",x"4c",x"20",x"40",x"49",x"45",x"20",x"53",x"45"
,x"44",x"45",x"20",x"42",x"4f",x"47",x"4f",x"54",x"41",x"20",x"20",x"20",x"20"); 
--u. nacional @IE
constant cgram2:ram2:=(x"41",x"43",x"45",x"52",x"51",x"55",x"45",x"20",x"54",x"41",x"52",x"4a",x"45",x"54",x"41",x"20",x"20",x"20",x"20"
,x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20"); 
--ACERQUE TARJETA
constant cgram3:ram3:=(x"54",x"45",x"4d",x"50",x"3a",x"20",x"4f",x"50",x"54",x"49",x"4d",x"41",x"20",x"20",x"20",x"20",x"45",x"53"
,x"54",x"55",x"44",x"49",x"41",x"4e",x"54",x"45",x"20",x"4f",x"4b",x"20",x"20"); 
--TEMP: OPTIMA
--ESTUDIANTE OK
constant cgram4:ram4:=(x"44",x"45",x"4e",x"45",x"47",x"41",x"44",x"4f",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20"
,x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20");
--DENEGADO
signal CLK1 : std_logic;
signal Clk_Out : std_logic;
signal LCD_Clk : std_logic;
signal m :std_logic_vector(1 downto 0);
begin
-------------------------
LCD_EN <= Clk_Out ; 
LCD_RW <= '0'; 
---------------------------------------------
process(CLK)
variable n1:integer range 0 to 19999;
begin 
if rising_edge(CLK) then
if n1<19999 then
n1:=n1+1;
else 
n1:=0;
Clk_Out<=not Clk_Out;
end if;
end if;
end process;
LCD_Clk <= Clk_Out;
----------------------------------------------------
process(Clk_Out)
variable n2:integer range 0 to 499;
begin 
if rising_edge(Clk_Out) then
if n2<499 then
n2:=n2+1;
else
n2:=0;
Clk1<=not Clk1;
end if;
end if;
end process;
---------------------------------------------------
process(Clk1)
variable n3:integer range 0 to 14;
begin
if rising_edge(Clk1) then
n3:=n3+1;
if n3<=4 then
m<="00";
elsif n3<=9 and n3>4 then
m<="01";
elsif n3<=14 and n3>9 then
m<="10";
else
m<="11";
end if;
end if;
end process;
-----------------------------------------------------
process(LCD_Clk,Reset,Current_State) 
variable cnt1: std_logic_vector(4 downto 0);
begin
if Reset='0'then
Current_State<=set_dlnf;
cnt1:="11110";
LCD_RS<='0';
elsif rising_edge(LCD_Clk)then
Current_State <= Current_State ;
LCD_RS <= '0';
case Current_State is
when set_dlnf=> 
cnt1:="00000"; 
LCD_Data<="00000001";   --  /*������ʾ*/ 
Current_State<=set_cursor;
when set_cursor=>
LCD_Data<="00111000";   --/*����8λ��ʽ,2��,5*7*/  
Current_State<=set_dcb;
when set_dcb=>
LCD_Data<="00001100";   --/*������ʾ,�ع���,����˸*/  
Current_State<=set_cgram;
when set_cgram=>
LCD_Data<="00000110";
Current_State<=write_cgram;
when write_cgram=> 
LCD_RS<='1';
if m="00" then
LCD_Data<=cgram1(conv_integer(cnt1));
elsif m="01"then
LCD_Data<=cgram2(conv_integer(cnt1));
elsif m="10"then
LCD_Data<=cgram3(conv_integer(cnt1));
else
LCD_Data<=cgram4(conv_integer(cnt1));
end if;
Current_State<=set_ddram; 
when set_ddram=> 
if cnt1<"11110" then
cnt1:=cnt1+1;
else
cnt1:="00000";
end if;
if cnt1<="01111" then
LCD_Data<="10000000"+cnt1;--80H 
else
LCD_Data<="11000000"+cnt1-"10000";--80H 
end if;
Current_State<=write_LCD_Data;
when write_LCD_Data=> 
LCD_Data<="00000000"; 
Current_State<=set_cursor;
when others => null;
end case;
end if;
end process;

----------------------------------------------------------------------------BOMBA
Salida1 <= brightness1;
    reset1 <= not Entrada1;
	 
	 
-----------Divisor de frecuencia de 400 Hz---------------------------------------
    process(CLK, clk_1,contadorA)
    begin
    if CLK'event and CLK = '1' then
    if contadorA < 20000 then
    contadorA <= contadorA +1;
    else 
    contadorA <= 0;
    clk_1 <= not(clk_1);
    end if;
    end if;
    end process;
--clk_out <= clk_1;

-----------------------Bomba-----------------------------------------------
    process(clk_1, reset1)
    begin
	     if rising_edge(clk_1) then
            count <= count + 1;
            if count(10) = '1' then  --Ciclo de trabajo de 30%
                brightness1 <= '1';
            else
                brightness1 <= '0' ;
            end if;
        end if; -- end of sync
		  
		  if reset1 = '1' then
            count <= (others => '0');
            brightness1 <= '0';
			end if;
     end process;
	  clk_out1 <= clk_1;
--------------------------------Bomba 2 ---------------------------------------------------
process(key_in)
begin
led_out <= (others => '1');   --???????????

case key_in is
when "1" => led_out <= "1"; -- key1???KEY1??????LED?

when others => NULL;
end case;
end process;

end Behavioral;