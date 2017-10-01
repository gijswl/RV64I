library ieee;
use ieee.std_logic_1164.all;

entity itype_decoder is
	port(
		I_INSTR  : in  std_logic_vector(6 downto 0);
		Q_TYPE   : out std_logic_vector(31 downto 0);
		Q_FORMAT : out std_logic_vector(5 downto 0)
	);
end entity itype_decoder;

architecture RTL of itype_decoder is
	signal L_TYPE : std_logic_vector(31 downto 0) := X"00000000";
begin
	L_TYPE(0)  <= '1' when (I_INSTR(6 downto 2) = "00000") else '0';
	L_TYPE(1)  <= '1' when (I_INSTR(6 downto 2) = "00001") else '0';
	L_TYPE(2)  <= '1' when (I_INSTR(6 downto 2) = "00010") else '0';
	L_TYPE(3)  <= '1' when (I_INSTR(6 downto 2) = "00011") else '0';
	L_TYPE(4)  <= '1' when (I_INSTR(6 downto 2) = "00100") else '0';
	L_TYPE(5)  <= '1' when (I_INSTR(6 downto 2) = "00101") else '0';
	L_TYPE(6)  <= '1' when (I_INSTR(6 downto 2) = "00110") else '0';
	L_TYPE(7)  <= '1' when (I_INSTR(6 downto 2) = "00111") else '0';
	L_TYPE(8)  <= '1' when (I_INSTR(6 downto 2) = "01000") else '0';
	L_TYPE(9)  <= '1' when (I_INSTR(6 downto 2) = "01001") else '0';
	L_TYPE(10) <= '1' when (I_INSTR(6 downto 2) = "01010") else '0';
	L_TYPE(11) <= '1' when (I_INSTR(6 downto 2) = "01011") else '0';
	L_TYPE(12) <= '1' when (I_INSTR(6 downto 2) = "01100") else '0';
	L_TYPE(13) <= '1' when (I_INSTR(6 downto 2) = "01101") else '0';
	L_TYPE(14) <= '1' when (I_INSTR(6 downto 2) = "01110") else '0';
	L_TYPE(15) <= '1' when (I_INSTR(6 downto 2) = "01111") else '0';
	L_TYPE(16) <= '1' when (I_INSTR(6 downto 2) = "10000") else '0';
	L_TYPE(17) <= '1' when (I_INSTR(6 downto 2) = "10001") else '0';
	L_TYPE(18) <= '1' when (I_INSTR(6 downto 2) = "10010") else '0';
	L_TYPE(19) <= '1' when (I_INSTR(6 downto 2) = "10011") else '0';
	L_TYPE(20) <= '1' when (I_INSTR(6 downto 2) = "10100") else '0';
	L_TYPE(21) <= '1' when (I_INSTR(6 downto 2) = "10101") else '0';
	L_TYPE(22) <= '1' when (I_INSTR(6 downto 2) = "10110") else '0';
	L_TYPE(23) <= '1' when (I_INSTR(6 downto 2) = "10111") else '0';
	L_TYPE(24) <= '1' when (I_INSTR(6 downto 2) = "11000") else '0';
	L_TYPE(25) <= '1' when (I_INSTR(6 downto 2) = "11001") else '0';
	L_TYPE(26) <= '1' when (I_INSTR(6 downto 2) = "11010") else '0';
	L_TYPE(27) <= '1' when (I_INSTR(6 downto 2) = "11011") else '0';
	L_TYPE(28) <= '1' when (I_INSTR(6 downto 2) = "11100") else '0';
	L_TYPE(29) <= '1' when (I_INSTR(6 downto 2) = "11101") else '0';
	L_TYPE(30) <= '1' when (I_INSTR(6 downto 2) = "11110") else '0';
	L_TYPE(31) <= '1' when (I_INSTR(6 downto 2) = "11111") else '0';
	
	Q_FORMAT(0) <= L_TYPE(3) or L_TYPE(12) or L_TYPE(25);
	Q_FORMAT(1) <= L_TYPE(0) or L_TYPE(4)  or L_TYPE(28);
	Q_FORMAT(2) <= L_TYPE(8);
	Q_FORMAT(3) <= L_TYPE(24);
	Q_FORMAT(4) <= (L_TYPE(5) or L_TYPE(13));
	Q_FORMAT(5) <= L_TYPE(27);
	
	Q_TYPE <= L_TYPE;
end architecture RTL;
