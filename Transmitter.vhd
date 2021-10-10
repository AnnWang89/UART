library ieee;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;
entity Transmitter is
port(
		CLK     :  in std_logic;
		RST     :  in std_logic;
		S0      :  in std_logic;
		TBAUDRATE_I  :  in std_logic;
		DATA_I:  in std_logic_vector(7 downto 0);
		TX :  out std_logic;
		READY_O  :  out std_logic;
		FINISH  :  out std_logic;
		Y0,Y1,Y2,Y3,Y4,Y5:out std_logic
);
end Transmitter;
architecture RT of Transmitter is
--REG
		signal X0,X1,X2,X3,X4,X5 : std_logic;
		signal READY_REG:std_logic;
		signal TX_Buff: std_logic_vector(7 downto 0);
		signal BitCnt_REG: std_logic_vector(7 downto 0);
		signal FINISH_REG: std_logic;
begin
--GRAFCET CONTROLLER
GRAFCET:PROCESS(CLK,RST)
BEGIN
	IF RST='1' THEN
		X0<='1';X1<='0';X2<='0';X3<='0';X4<='0';X5<='0';
	ELSIF CLK'EVENT AND CLK='1' THEN
		IF X0='1'AND S0='1' THEN X0<='0'; X1<='1';
		ELSIF X1='1' AND TBAUDRATE_I='1' THEN X1<='0'; X2<='1';
		ELSIF X2='1' THEN X2<='0';X3<='1';
		ELSIF X3='1' AND TBAUDRATE_I='0' THEN X3<='0';X4<='1';
		ELSIF X4='1' THEN
			IF BitCnt_REG < 10 AND TBAUDRATE_I='1' THEN
				X4<='0'; X2<='1';
			ELSIF BitCnt_REG>=10 AND TBAUDRATE_I='1' THEN  
				X4<='0'; X5<='1';
			ELSE NULL;
			END IF;
		ELSIF X5='1' AND S0='0'THEN X5<='0';X0<='1';
		END IF;
	END IF;
END PROCESS GRAFCET;
DATAPATH:PROCESS(CLK,X0,X1,X2,X3,X4,X5)
BEGIN
	IF CLK'EVENT AND CLK='1' THEN
		IF X0='1' THEN TX<='1';READY_O<='1';READY_REG<='0';FINISH_REG<='0';
		ELSIF X1='1' THEN TX_Buff<=DATA_I;READY_O<='0';READY_REG<='1';BitCnt_REG<=(others=>'0');
		ELSIF X2='1' THEN TX<=TX_Buff(0);BitCnt_REG<=BitCnt_REG+1;TX_Buff<='0' & TX_Buff(7 downto 1) ;
		ELSIF X5='1' THEN FINISH_REG<='1';
		END IF;
	END IF;
END PROCESS DATAPATH;

FINISH<=FINISH_REG;
y0<=X0;
y1<=X1;
y2<=X2;
y3<=X3;
y4<=X4;
y5<=X5;
END RT;