library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;

entity registerfile is
	port(
		I_CLK : in  std_logic;
		I_WE  : in  std_logic;
		I_RS1 : in  std_logic_vector(4 downto 0);
		I_RS2 : in  std_logic_vector(4 downto 0);
		I_WA  : in  std_logic_vector(4 downto 0);
		I_WD  : in  std_logic_vector(XLEN - 1 downto 0);
		Q_RD1 : out std_logic_vector(XLEN - 1 downto 0);
		Q_RD2 : out std_logic_vector(XLEN - 1 downto 0)
	);
end entity registerfile;

architecture RTL of registerfile is
	component reg is
		generic(
			width : natural
		);
		port(
			I_CLK : in  std_logic;
			I_D   : in  std_logic_vector(width - 1 downto 0);
			I_W   : in  std_logic;
			Q_D   : out std_logic_vector(width - 1 downto 0)
		);
	end component reg;

	signal L_WRITE  : std_logic_vector(31 downto 0)       := X"00000000";
	signal L_WRITES : std_logic_vector(31 downto 0)       := X"00000000";
	signal L_R1     : std_logic_vector(XLEN - 1 downto 0);
	signal L_R2     : std_logic_vector(XLEN - 1 downto 0);
	signal L_R3     : std_logic_vector(XLEN - 1 downto 0);
	signal L_R4     : std_logic_vector(XLEN - 1 downto 0);
	signal L_R5     : std_logic_vector(XLEN - 1 downto 0);
	signal L_R6     : std_logic_vector(XLEN - 1 downto 0);
	signal L_R7     : std_logic_vector(XLEN - 1 downto 0);
	signal L_R8     : std_logic_vector(XLEN - 1 downto 0);
	signal L_R9     : std_logic_vector(XLEN - 1 downto 0);
	signal L_R10    : std_logic_vector(XLEN - 1 downto 0);
	signal L_R11    : std_logic_vector(XLEN - 1 downto 0);
	signal L_R12    : std_logic_vector(XLEN - 1 downto 0);
	signal L_R13    : std_logic_vector(XLEN - 1 downto 0);
	signal L_R14    : std_logic_vector(XLEN - 1 downto 0);
	signal L_R15    : std_logic_vector(XLEN - 1 downto 0);
	signal L_R16    : std_logic_vector(XLEN - 1 downto 0);
	signal L_R17    : std_logic_vector(XLEN - 1 downto 0);
	signal L_R18    : std_logic_vector(XLEN - 1 downto 0);
	signal L_R19    : std_logic_vector(XLEN - 1 downto 0);
	signal L_R20    : std_logic_vector(XLEN - 1 downto 0);
	signal L_R21    : std_logic_vector(XLEN - 1 downto 0);
	signal L_R22    : std_logic_vector(XLEN - 1 downto 0);
	signal L_R23    : std_logic_vector(XLEN - 1 downto 0);
	signal L_R24    : std_logic_vector(XLEN - 1 downto 0);
	signal L_R25    : std_logic_vector(XLEN - 1 downto 0);
	signal L_R26    : std_logic_vector(XLEN - 1 downto 0);
	signal L_R27    : std_logic_vector(XLEN - 1 downto 0);
	signal L_R28    : std_logic_vector(XLEN - 1 downto 0);
	signal L_R29    : std_logic_vector(XLEN - 1 downto 0);
	signal L_R30    : std_logic_vector(XLEN - 1 downto 0);
	signal L_R31    : std_logic_vector(XLEN - 1 downto 0);

	signal L_RD1 : std_logic_vector(XLEN - 1 downto 0);
	signal L_RD2 : std_logic_vector(XLEN - 1 downto 0);
begin
	r1 : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_WD,
			I_W   => L_WRITE(1),
			Q_D   => L_R1
		);

	r2 : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_WD,
			I_W   => L_WRITE(2),
			Q_D   => L_R2
		);

	r3 : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_WD,
			I_W   => L_WRITE(3),
			Q_D   => L_R3
		);

	r4 : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_WD,
			I_W   => L_WRITE(4),
			Q_D   => L_R4
		);

	r5 : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_WD,
			I_W   => L_WRITE(5),
			Q_D   => L_R5
		);

	r6 : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_WD,
			I_W   => L_WRITE(6),
			Q_D   => L_R6
		);

	r7 : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_WD,
			I_W   => L_WRITE(7),
			Q_D   => L_R7
		);

	r8 : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_WD,
			I_W   => L_WRITE(8),
			Q_D   => L_R8
		);

	r9 : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_WD,
			I_W   => L_WRITE(9),
			Q_D   => L_R9
		);

	r10 : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_WD,
			I_W   => L_WRITE(10),
			Q_D   => L_R10
		);

	r11 : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_WD,
			I_W   => L_WRITE(11),
			Q_D   => L_R11
		);

	r12 : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_WD,
			I_W   => L_WRITE(12),
			Q_D   => L_R12
		);

	r13 : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_WD,
			I_W   => L_WRITE(13),
			Q_D   => L_R13
		);

	r14 : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_WD,
			I_W   => L_WRITE(14),
			Q_D   => L_R14
		);

	r15 : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_WD,
			I_W   => L_WRITE(15),
			Q_D   => L_R15
		);

	r16 : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_WD,
			I_W   => L_WRITE(16),
			Q_D   => L_R16
		);

	r17 : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_WD,
			I_W   => L_WRITE(17),
			Q_D   => L_R17
		);

	r18 : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_WD,
			I_W   => L_WRITE(18),
			Q_D   => L_R18
		);

	r19 : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_WD,
			I_W   => L_WRITE(19),
			Q_D   => L_R19
		);

	r20 : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_WD,
			I_W   => L_WRITE(20),
			Q_D   => L_R20
		);

	r21 : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_WD,
			I_W   => L_WRITE(21),
			Q_D   => L_R21
		);

	r22 : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_WD,
			I_W   => L_WRITE(22),
			Q_D   => L_R22
		);

	r23 : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_WD,
			I_W   => L_WRITE(23),
			Q_D   => L_R23
		);

	r24 : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_WD,
			I_W   => L_WRITE(24),
			Q_D   => L_R24
		);

	r25 : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_WD,
			I_W   => L_WRITE(25),
			Q_D   => L_R25
		);

	r26 : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_WD,
			I_W   => L_WRITE(26),
			Q_D   => L_R26
		);

	r27 : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_WD,
			I_W   => L_WRITE(27),
			Q_D   => L_R27
		);

	r28 : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_WD,
			I_W   => L_WRITE(28),
			Q_D   => L_R28
		);

	r29 : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_WD,
			I_W   => L_WRITE(29),
			Q_D   => L_R29
		);

	r30 : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_WD,
			I_W   => L_WRITE(30),
			Q_D   => L_R30
		);

	r31 : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_WD,
			I_W   => L_WRITE(31),
			Q_D   => L_R31
		);

	with I_WA select L_WRITES <=
		"00000000000000000000000000000001" when "00000",
		"00000000000000000000000000000010" when "00001",
		"00000000000000000000000000000100" when "00010",
		"00000000000000000000000000001000" when "00011",
		"00000000000000000000000000010000" when "00100",
		"00000000000000000000000000100000" when "00101",
		"00000000000000000000000001000000" when "00110",
		"00000000000000000000000010000000" when "00111",
		"00000000000000000000000100000000" when "01000",
		"00000000000000000000001000000000" when "01001",
		"00000000000000000000010000000000" when "01010",
		"00000000000000000000100000000000" when "01011",
		"00000000000000000001000000000000" when "01100",
		"00000000000000000010000000000000" when "01101",
		"00000000000000000100000000000000" when "01110",
		"00000000000000001000000000000000" when "01111",
		"00000000000000010000000000000000" when "10000",
		"00000000000000100000000000000000" when "10001",
		"00000000000001000000000000000000" when "10010",
		"00000000000010000000000000000000" when "10011",
		"00000000000100000000000000000000" when "10100",
		"00000000001000000000000000000000" when "10101",
		"00000000010000000000000000000000" when "10110",
		"00000000100000000000000000000000" when "10111",
		"00000001000000000000000000000000" when "11000",
		"00000010000000000000000000000000" when "11001",
		"00000100000000000000000000000000" when "11010",
		"00001000000000000000000000000000" when "11011",
		"00010000000000000000000000000000" when "11100",
		"00100000000000000000000000000000" when "11101",
		"01000000000000000000000000000000" when "11110",
		"10000000000000000000000000000000" when "11111",
		"00000000000000000000000000000000" when others;
	L_WRITE <= L_WRITES when I_WE = '1' else X"00000000";

	with I_RS1 select L_RD1 <=
		L_R1 when "00001",
		L_R2 when "00010",
		L_R3 when "00011",
		L_R4 when "00100",
		L_R5 when "00101",
		L_R6 when "00110",
		L_R7 when "00111",
		L_R8 when "01000",
		L_R9 when "01001",
		L_R10 when "01010",
		L_R11 when "01011",
		L_R12 when "01100",
		L_R13 when "01101",
		L_R14 when "01110",
		L_R15 when "01111",
		L_R16 when "10000",
		L_R17 when "10001",
		L_R18 when "10010",
		L_R19 when "10011",
		L_R20 when "10100",
		L_R21 when "10101",
		L_R22 when "10110",
		L_R23 when "10111",
		L_R24 when "11000",
		L_R25 when "11001",
		L_R26 when "11010",
		L_R27 when "11011",
		L_R28 when "11100",
		L_R29 when "11101",
		L_R30 when "11110",
		L_R31 when "11111",
		(others => '0') when others;

	with I_RS2 select L_RD2 <=
		L_R1 when "00001",
		L_R2 when "00010",
		L_R3 when "00011",
		L_R4 when "00100",
		L_R5 when "00101",
		L_R6 when "00110",
		L_R7 when "00111",
		L_R8 when "01000",
		L_R9 when "01001",
		L_R10 when "01010",
		L_R11 when "01011",
		L_R12 when "01100",
		L_R13 when "01101",
		L_R14 when "01110",
		L_R15 when "01111",
		L_R16 when "10000",
		L_R17 when "10001",
		L_R18 when "10010",
		L_R19 when "10011",
		L_R20 when "10100",
		L_R21 when "10101",
		L_R22 when "10110",
		L_R23 when "10111",
		L_R24 when "11000",
		L_R25 when "11001",
		L_R26 when "11010",
		L_R27 when "11011",
		L_R28 when "11100",
		L_R29 when "11101",
		L_R30 when "11110",
		L_R31 when "11111",
		(others => '0') when others;

	Q_RD1 <= I_WD when (I_WA = I_RS1 and I_WE = '1') else L_RD1;
	Q_RD2 <= I_WD when (I_WA = I_RS2 and I_WE = '1') else L_RD2;
end architecture RTL;

