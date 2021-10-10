library ieee;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity UART is
port(
		CLK				:	in std_logic;
		RST				:	in std_logic;
		RXD				:	in std_logic;
		SET_RATE			:	in std_logic;
		HIGH_RATE		:	in std_logic_vector(7 downto 0);
		LOW_RATE			:	in std_logic_vector(7 downto 0);
		TX_E				:	in std_logic;
		TX_DATA			:	in std_logic_vector(7 downto 0);
		TXD				:	out std_logic;
		RX_DATA			:	out std_logic_vector(7 downto 0);
		RX_FINISH		:  out std_logic;
		TX_FINISH		:  out std_logic;
		
		
		Sysclk, rst_b  :  in std_logic;
		--Sel  				:  in unsigned(2 down to 0);
		BclkX8			:  buffer std_logic;
		Bclk 				:  out std_logic
	 
);
end UART;
architecture baudgen of UART is
signal ctr1 : std_logic_vector(3 downto 0) := "0000";
--divide by 13 counter
signal ctr2 : std_logic_vector(7 downto 0) := "00000000";
--divide by 256 ctr
signal ctr3 : std_logic_vector(2 downto 0) := "000";
--divide by 8 counter
signal Clkdiv13:std_logic;
begin
--GRAFCET CONTROLLER
	PROCESS(Sysclk) -- first divide system clock by 13
	BEGIN
		IF (Sysclk'event and Sysclk = '1' ) THEN
			IF (ctr1 = "1100") THEN ctr1 <="0000";
			ELSE ctr1 <= ctr1+1;
			END IF;
		END IF;
	END PROCESS;
	Clkdiv13 <= ctr1(3);
	
	PROCESS(Clkdiv13) -- ctr2 is an 8-bit counter
	BEGIN
		IF (Clkdiv13'event and Clkdiv13 = '1' ) THEN
			ctr2 <= ctr2+1;
		END IF;
	END PROCESS;
	BclkX8 <=ctr2(3);--MUX(choose by my self)
	
	
	PROCESS(BclkX8) -- ctr2 is an 8-bit counter
	BEGIN
		IF (BclkX8'event and BclkX8 = '1' ) THEN
			ctr3 <= ctr3+1;
		END IF;
	END PROCESS;
	Bclk <=ctr3(2);--MUX
END baudgen;
