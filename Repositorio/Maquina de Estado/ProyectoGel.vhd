--------------------------------------------------------------------------------
-- Universidad Nacional de Colombia
-- Departamento de Ingeniería Eléctrica y Electrónica
-- Electrónica Digital I 2020-2
-- Integrantes:-Diego Fernando Gutierrez García
              --Cristian Eduardo
--
-- Target Devices: FPGA EPACEE10BLA
---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
entity ProyectoGel is
Port ( 
--Entradas TEMPORALES del dispositivo en general
ESTemperatura: in std_logic;
ECarnet: in std_logic;
ESManos: in std_logic;
-------------------------------
Rst : in STD_LOGIC;
Clk : in STD_LOGIC;


-------Entradas TEMPORALES de la Bomba--------
--Entrada1: in std_logic;
Salida1: out std_logic;
clk_out1: out std_logic;
-------------------------------------------------------------BOMBA
LCD_Data : out std_logic_vector(7 downto 0); --Һ�������ź�
-----------------------------bomba 2 
key_in : in std_logic_vector (0 downto 0);     
led_out : out std_logic_vector(0 downto 0) 
------------------------------------------BOMBA 2


 );
end ProyectoGel;
architecture Maquina of ProyectoGel is
--Señales intermedias de entrada para la maquina
signal X: std_logic;
signal Y: std_logic;
signal Sal : std_logic;
----------------------------------------------------------BOMBA
signal contadorA: integer range 0 to 60000;
signal clk_1: std_logic;
signal reset1: std_logic;
signal count : unsigned(32 downto 0) := (others => '0');
signal brightness1 : std_logic;


----------------------------------------------------------BOMBA


type ESTADOS is (Vacio,STemperatura, Carnet, CarnetYSTemperatura, SManos, Salida);
attribute syn_encoding: string;
attribute syn_encoding of ESTADOS: type is "sequential";
signal EstadoX,EstadoSig: ESTADOS;
begin

process(ESTemperatura,ECarnet,ESManos)
 begin

    if (ESTemperatura ='1') then
            X <= '0';
            Y <= '1';
	 if (ECarnet = '1') then
            X <= '1';
            Y <= '0';
	 if (ESManos = '1') then
            X <= '1';
            Y <= '1';						
    end if;
	 end if;
	 end if;
end process;


process (Rst,Clk) --Inicia el proceso secuencial
begin
if (Rst='1') then
EstadoX <= Vacio;
elsif (CLK'event and CLK='1') then
EstadoX <= EstadoSig;
end if;
end process;
process (EstadoX,X,Y)
begin
EstadoSig <= EstadoX;
case EstadoX is
when Vacio => if X='0' and Y='1' then EstadoSig<=STemperatura;
elsif X='1' and Y='0' then EstadoSig<=Carnet;
elsif X='1' and Y='1' then EstadoSig<=SManos;
end if;
when STemperatura => if X='0' and Y='1' then EstadoSig<=Carnet;
elsif X='1' and Y='0' then EstadoSig<=CarnetYSTemperatura;
elsif X='1' and Y='1' then EstadoSig<=Salida;
end if;
when Carnet => if X='0' and Y='1' then EstadoSig<=CarnetYSTemperatura;
elsif X='1' and Y='0' then EstadoSig<=SManos;
elsif X='1' and Y='1' then EstadoSig<=Salida;
end if;
when CarnetYSTemperatura => if X='0' and Y='1' then EstadoSig<=SManos;
elsif X='1' then EstadoSig<=Salida;
end if;
when SManos => if X='1' or Y='1' then EstadoSig<=Salida;
end if;
when Salida => EstadoSig<=Vacio;
end case;
end process;
Sal <= '1' when (EstadoX = Salida) else '0';

----------------------Bomba-----------------------------
Salida1<= brightness1;
    reset1 <= not Sal;
	 
-----------Divisor de frecuencia de 1.2 KHz---------------------------------------
    process(Clk, clk_1,contadorA)
    begin
    if Clk'event and Clk = '1' then
    if contadorA < 60000 then
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
	 
	 
	 
	 
	 
	 
	 
end Maquina;