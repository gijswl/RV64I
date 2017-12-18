library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;

entity if_stage_old is
	port(
		I_CLK    : in  std_logic;
		I_RST    : in  std_logic;
		I_SELT   : in  std_logic;
		I_STALL  : in  std_logic;
		I_KILL   : in  std_logic;
		I_TARGET : in  std_logic_vector(XLEN - 1 downto 0);
		Q_PC     : out std_logic_vector(XLEN - 1 downto 0);
		Q_INSTR  : out std_logic_vector(32 downto 0)
	);
end entity if_stage_old;

architecture RTL of if_stage_old is
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

	component cache_i is
		generic(
			ADR_WIDTH   : natural;
			DATA_WIDTH  : natural;
			CACHE_LINES : natural;
			DATA_FILE   : string
		);
		port(
			I_CLK  : in  std_logic;
			I_ADR  : in  std_logic_vector(ADR_WIDTH - 1 downto 0);
			Q_DATA : out std_logic_vector(DATA_WIDTH - 1 downto 0)
		);
	end component cache_i;

	signal L_PC      : std_logic_vector(XLEN - 1 downto 0) := X"0000000000000000";
	signal L_NEXT_PC : std_logic_vector(XLEN - 1 downto 0) := X"0000000000000000";
	signal L_CDATA   : std_logic_vector(31 downto 0)       := X"00000000";

	signal C_STALL : std_logic := '0';
begin
	pc : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => L_NEXT_PC,
			I_W   => '1',
			Q_D   => L_PC
		);

	icache : cache_i
		generic map(
			ADR_WIDTH   => XLEN,
			DATA_WIDTH  => 32,
			CACHE_LINES => 2048,
			DATA_FILE   => "instr_cache.txt"
		)
		port map(
			I_CLK  => I_CLK,
			I_ADR  => L_PC,
			Q_DATA => L_CDATA
		);

	C_STALL   <= I_STALL;               -- TODO stall on cache misses as well
	L_NEXT_PC <= DEFAULT_PC when I_RST = '1'
		else L_PC when C_STALL = '1'
		else I_TARGET when I_SELT = '1'
		else L_PC + "100";

	Q_PC    <= (others => '0') when I_RST = '1' else L_PC;
	Q_INSTR <= (others => '0') when (I_RST = '1' or C_STALL = '1' or I_KILL = '1') else '1' & L_CDATA;
end architecture RTL;
