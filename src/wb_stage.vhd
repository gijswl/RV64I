library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;

entity wb_stage is
	port(
		I_CLK   : in  std_logic;
		I_RST   : in  std_logic;
		I_STALL : in  std_logic;
		I_WB    : in  std_logic_vector(XLEN - 1 downto 0);
		I_CS    : in  std_logic_vector(CS_SIZE - 1 downto 0);
		Q_WD    : out std_logic_vector(XLEN - 1 downto 0);
		Q_WA    : out std_logic_vector(4 downto 0);
		Q_WR    : out std_logic
	);
end entity wb_stage;

architecture RTL of wb_stage is
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

	signal L_NOSTALL : std_logic;

	signal L_WB : std_logic_vector(XLEN - 1 downto 0);
	signal L_CS : std_logic_vector(CS_SIZE - 1 downto 0);
begin
	wb : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_WB,
			I_W   => L_NOSTALL,
			Q_D   => L_WB
		);
	cs : reg
		generic map(
			width => CS_SIZE
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_CS,
			I_W   => L_NOSTALL,
			Q_D   => L_CS
		);

	L_NOSTALL <= not I_STALL;

	Q_WD <= L_WB;
	Q_WA <= L_CS(CS_RD'range);
	Q_WR <= '0' when (L_CS(CS_RD'range) = "00000" or L_CS(CS_WE'range) = "0" or I_RST = '1') else '1';
end architecture RTL;
