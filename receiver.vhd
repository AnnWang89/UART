library ieee;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use ieee.numeric_std.all;
entity receiver is
generic(
DATA_WIDTH : POSITIVE :=10
);
port(
		CLK     		:  in std_logic;
		RST     		:  in std_logic;
		RX 			:  in std_logic;
		RBAUDRATE_I :  in std_logic;
		DATA_O 		:  out std_logic_vector(7 downto 0);
		FINISH 		:  out std_logic;
		cnt 			:  out std_logic_vector(DATA_WIDTH-1 downto 0);
		Y0,Y1,Y2,Y3,Y4,Y5,Y6,Y7,Y8,Y9 : out std_logic;
		ERR 			:  out std_logic
);
end receiver;
architecture r1 of receiver is
--REG
	signal X0,X1,X2,X3,x4,x5,x6,x7,x8,x9 : std_logic;
	signal BitCnt_REG: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal RX_Buff: std_logic_vector(DATA_WIDTH-1 downto 0);
--signal RX_Buff_tmp: unsigned(DATA_WIDTH-1 downto 0):= (others => '0');
	signal SampleCnt_REG: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal FINISH_REG: std_logic;
begin
--GRAFCET CONTROLLER
GRAFCET:PROCESS(CLK,RST)
BEGIN
	IF RST='1' THEN
		X0<='1';X1<='0';X2<='0';X3<='0';X4<='0';X5<='0';X6<='0';X7<='0';X8<='0';X9<='0';
	ELSIF CLK'EVENT AND CLK='1' THEN
		IF X0='1'AND RX='0' THEN X0<='0'; X1<='1';
		ELSIF X1='1' THEN X1<='0'; X2<='1';
		ELSIF X2='1' AND RBAUDRATE_I='1' THEN
			IF SampleCnt_REG = 8 THEN X2<='0';X4<='1';
			ELSIF SampleCnt_REG = 15 THEN X2<='0';X6<='1';
			ELSE  X2<='0';X3<='1';
			END IF;
		ELSIF X3='1' THEN X3<='0';X5<='1';
		ELSIF X4='1' THEN X4<='0';X5<='1';
		ELSIF X5='1' AND RBAUDRATE_I='0' THEN X5<='0';X2<='1';
		ELSIF X6='1' THEN X6<='0';X7<='1';
		ELSIF X7='1' AND RBAUDRATE_I='0' THEN 
			IF BitCnt_REG<10 THEN X7<='0';X1<='1';
			ELSIF BitCnt_REG=10 THEN X7<='0';X8<='1';
			END IF;
		ELSIF X8='1' THEN X8<='0';X9<='1';
		ELSIF X9='1' THEN X9<='0';X0<='1';
		END IF;
	END IF;
END PROCESS GRAFCET;
DATAPATH:PROCESS(CLK,X0,X1,X2,X3,x4,x5,x6,x7,x8,x9)
BEGIN
	IF CLK'EVENT AND CLK='1' THEN
		IF X0='1' THEN BitCnt_REG<=(others=>'0');RX_Buff<=(others=>'0');
		ELSIF X1='1' THEN SampleCnt_REG<=(others=>'0');
		ELSIF X3='1' THEN SampleCnt_REG<=SampleCnt_REG + 1;
		ELSIF X4='1' THEN 
			RX_Buff(9)<=RX;
			--RX_Buff_tmp<= unsigned(RX_Buff);
			RX_Buff<= '0' & RX_Buff(DATA_WIDTH-1 downto 1) ; 
			SampleCnt_REG<=SampleCnt_REG+1;
		ELSIF x6='1' THEN BitCnt_REG<=BitCnt_REG+1;
		ELSIF x8='1' THEN DATA_O<=RX_Buff(8 downto 1);ERR<=RX_Buff(9);
		ELSIF x9='1' THEN FINISH<='1';
		END IF;
	END IF;
	Y0<= X0;Y1<= X1;Y2<= X2;Y3<= X3;Y4<= X4;Y5<= X5;Y6<= X6;Y7<= X7;Y8<= X8;Y9<= X9;
	cnt<= SampleCnt_REG;
END PROCESS DATAPATH;
END r1;