library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;

entity if_stage is
	port(
		I_CLK    : in  std_logic;
		I_RST    : in  std_logic;
		I_SELT   : in  std_logic;
		I_STALL  : in  std_logic;
		I_KILL   : in  std_logic;
		I_MRDY   : in std_logic;
		I_MIN    : in std_logic_vector(XLEN - 1 downto 0);
		I_TARGET : in  std_logic_vector(XLEN - 1 downto 0);
		Q_MMASK  : out std_logic_vector((XLEN / 8) - 1 downto 0);
		Q_PC     : out std_logic_vector(XLEN - 1 downto 0);
		Q_MADDR  : out std_logic_vector(XLEN - 1 downto 0);
		Q_INSTR  : out std_logic_vector(32 downto 0);
		Q_MRE    : out std_logic
	);
end entity if_stage;

architecture RTL of if_stage is
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

	component cache is
		generic(
			ADDR_WIDTH      : in natural := 32;
			WORD_WIDTH      : in natural := 32;
			LINE_SIZE_BITS  : in natural := 0;
			LINE_COUNT_BITS : in natural := 8;
			ASSOC_BITS      : in natural := 1;
			REPLACEMENT     : in natural := 0;
			-- 0: LRU
			-- 1: MRU
			-- 2: FIFO
			-- 3: PLRU
			WRITE_POLICY    : in natural := 0
			-- 0: write-back,    write-allocate
			-- 1: write-through, write-around
		);
		port(
			clk    : in  std_logic;
			rst    : in  std_logic;
			addr   : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
			din    : in  std_logic_vector(WORD_WIDTH - 1 downto 0);
			dout   : out std_logic_vector(WORD_WIDTH - 1 downto 0);
			re     : in  std_logic;
			we     : in  std_logic;
			mask   : in  std_logic_vector((WORD_WIDTH / 8) - 1 downto 0);
			ready  : out std_logic;
			maddr  : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
			mout   : out std_logic_vector(WORD_WIDTH - 1 downto 0);
			min    : in  std_logic_vector(WORD_WIDTH - 1 downto 0);
			mre    : out std_logic;
			mwe    : out std_logic;
			mmask  : out std_logic_vector((WORD_WIDTH / 8) - 1 downto 0);
			mready : in  std_logic
		);
	end component cache;
	
	signal C_CLK   : std_logic;
	signal C_RE    : std_logic;
	signal C_DOUT  : std_logic_vector(XLEN - 1 downto 0);
	signal C_RDY   : std_logic;
	signal C_MRE   : std_logic;

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

	icache : cache
		generic map(
			ADDR_WIDTH      => XLEN,
			WORD_WIDTH      => XLEN,
			LINE_SIZE_BITS  => 0,
			LINE_COUNT_BITS => 0,
			ASSOC_BITS      => 0,
			REPLACEMENT     => 0,
			-- 0: LRU
			-- 1: MRU
			-- 2: FIFO
			-- 3: PLRU
			WRITE_POLICY    => 1
			-- 0: write-back,    write-allocate
			-- 1: write-through, write-around
		)
		port map(
			clk    => C_CLK,
			rst    => I_RST,
			addr   => L_PC,
			din    => X"DEADBEEFDEADBEEF",
			re     => C_RE,
			we     => '0',
			mask   => X"FF",
			min    => I_MIN,
			mready => I_MRDY,
			dout   => C_DOUT,
			ready  => C_RDY,
			maddr  => Q_MADDR,
			mout   => open,
			mre    => C_MRE,
			mwe    => open,
			mmask  => Q_MMASK
		);
	
	C_CLK <= I_CLK;
	C_RE  <= '1';

	C_STALL   <= I_STALL or not C_RDY;
	L_NEXT_PC <= DEFAULT_PC when I_RST = '1'
		else I_TARGET when I_SELT = '1'
		else L_PC when C_STALL = '1'
		else L_PC + "100";

	L_CDATA <= C_DOUT(31 downto 0) when L_PC(2) = '1' else C_DOUT(63 downto 32);

	Q_PC    <= (others => '0') when I_RST = '1' else L_PC;
	Q_INSTR <= (others => '0') when (I_RST = '1' or C_STALL = '1' or I_KILL = '1') else '1' & L_CDATA;
	Q_MRE   <= C_MRE;
end architecture RTL;
