library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;

entity ma_stage is
	port(
		I_CLK   : in  std_logic;
		I_RST   : in  std_logic;
		I_MRDY  : in  std_logic;
		I_PC    : in  std_logic_vector(XLEN - 1 downto 0);
		I_MA    : in  std_logic_vector(XLEN - 1 downto 0);
		I_MD    : in  std_logic_vector(XLEN - 1 downto 0);
		I_MIN   : in  std_logic_vector(XLEN - 1 downto 0);
		I_CS    : in  std_logic_vector(CS_SIZE - 1 downto 0);
		Q_CS    : out std_logic_vector(CS_SIZE - 1 downto 0);
		Q_MMASK : out std_logic_vector((XLEN / 8) - 1 downto 0);
		Q_WB    : out std_logic_vector(XLEN - 1 downto 0);
		Q_MADDR : out std_logic_vector(XLEN - 1 downto 0);
		Q_MOUT  : out std_logic_vector(XLEN - 1 downto 0);
		Q_MWE   : out std_logic;
		Q_MRE   : out std_logic;
		Q_STALL : out std_logic
	);
end entity ma_stage;

architecture RTL of ma_stage is
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

	component reg_rst is
		generic(
			width : natural
		);
		port(
			I_CLK : in  std_logic;
			I_RST : in  std_logic;
			I_D   : in  std_logic_vector(width - 1 downto 0);
			I_W   : in  std_logic;
			Q_D   : out std_logic_vector(width - 1 downto 0)
		);
	end component reg_rst;

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

	signal C_MA    : std_logic_vector(XLEN - 1 downto 0);
	signal C_MD    : std_logic_vector(XLEN - 1 downto 0);
	signal C_MASK  : std_logic_vector((XLEN / 8) - 1 downto 0);
	signal C_SMASK : std_logic_vector((XLEN / 8) - 1 downto 0);
	signal C_RE    : std_logic;
	signal C_WE    : std_logic;
	signal C_DOUT  : std_logic_vector(XLEN - 1 downto 0);
	signal C_RDY   : std_logic;
	signal C_MADDR : std_logic_vector(XLEN - 1 downto 0);
	signal C_MOUT  : std_logic_vector(XLEN - 1 downto 0);
	signal C_MRE   : std_logic;
	signal C_MWE   : std_logic;
	signal C_MMASK : std_logic_vector((XLEN / 8) - 1 downto 0);
	signal C_MRDY  : std_logic;
	signal C_MIN   : std_logic_vector(XLEN - 1 downto 0);

	signal C_CLK : std_logic;

	signal L_NS : std_logic;

	signal L_PC : std_logic_vector(XLEN - 1 downto 0);
	signal L_MA : std_logic_vector(XLEN - 1 downto 0);
	signal L_MD : std_logic_vector(XLEN - 1 downto 0);
	signal L_CS : std_logic_vector(CS_SIZE - 1 downto 0);

	signal L_DOUT  : std_logic_vector(XLEN - 1 downto 0);
	signal L_SDOUT : std_logic_vector(XLEN - 1 downto 0);
begin
	dcache : cache
		generic map(
			ADDR_WIDTH      => XLEN,
			WORD_WIDTH      => XLEN,
			LINE_SIZE_BITS  => 0,
			LINE_COUNT_BITS => 8,
			ASSOC_BITS      => 1,
			REPLACEMENT     => 0,
			-- 0: LRU
			-- 1: MRU
			-- 2: FIFO
			-- 3: PLRU
			WRITE_POLICY    => 0
			-- 0: write-back,    write-allocate
			-- 1: write-through, write-around
		)
		port map(
			clk    => C_CLK,
			rst    => I_RST,
			addr   => C_MA,
			din    => C_MD,
			re     => C_RE,
			we     => C_WE,
			mask   => C_SMASK,
			min    => C_MIN,
			mready => C_MRDY,
			dout   => C_DOUT,
			ready  => C_RDY,
			maddr  => Q_MADDR,
			mout   => Q_MOUT,
			mre    => C_MRE,
			mwe    => C_MWE,
			mmask  => Q_MMASK
		);

	pc : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_PC,
			I_W   => L_NS,
			Q_D   => L_PC
		);
	ma : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_MA,
			I_W   => L_NS,
			Q_D   => L_MA
		);
	md : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_MD,
			I_W   => L_NS,
			Q_D   => L_MD
		);
	cs : reg_rst
		generic map(
			width => CS_SIZE
		)
		port map(
			I_CLK => I_CLK,
			I_RST => I_RST,
			I_D   => I_CS,
			I_W   => L_NS,
			Q_D   => L_CS
		);

	with L_CS(CS_FC'range) select C_MASK <=
		"00000001" when "000",          -- LB
		"00000011" when "001",          -- LH
		"00001111" when "010",          -- LW
		"11111111" when "011",          -- LD
		"00000001" when "100",          -- LBU
		"00000011" when "101",          -- LHU
		"00001111" when "110",          -- LWU
		"00000000" when others;

	L_NS <= C_RDY;

	C_CLK <= not I_CLK;

	C_RE <= '1' when L_CS(CS_LD'range) = "1" and C_RDY = '1' else '0';
	C_WE <= '1' when L_CS(CS_ST'range) = "1" and C_RDY = '1' else '0';

	C_SMASK <= STD_LOGIC_VECTOR(SHL(C_MASK, L_MA(2 downto 0)));
	C_MA    <= L_MA(XLEN - 1 downto 3) & "000";
	C_MD    <= STD_LOGIC_VECTOR(SHL(L_MD, STD_LOGIC_VECTOR(TO_SIGNED(8*(TO_INTEGER(unsigned(L_MA(2 downto 0)))), XLEN))));
	C_MRDY  <= I_MRDY;
	C_MIN   <= I_MIN;

	process(I_CLK)
	begin
		if (falling_edge(I_CLK)) then
			L_SDOUT <= STD_LOGIC_VECTOR(SHR(C_DOUT, STD_LOGIC_VECTOR(TO_SIGNED(8*(TO_INTEGER(unsigned(L_MA(2 downto 0)))), XLEN))));
		end if;
	end process;

	with L_CS(CS_FC'range) select L_DOUT <=
		(XLEN - 1 downto 8 => L_SDOUT(7)) & L_SDOUT(7 downto 0) when "000", -- LB
		(XLEN - 1 downto 16 => L_SDOUT(15)) & L_SDOUT(15 downto 0) when "001", -- LH
		(XLEN - 1 downto 32 => L_SDOUT(31)) & L_SDOUT(31 downto 0) when "010", -- LW
		L_SDOUT(XLEN - 1 downto 0) when "011", -- LD
		(XLEN - 1 downto 8 => '0') & L_SDOUT(7 downto 0) when "100", -- LBU
		(XLEN - 1 downto 16 => '0') & L_SDOUT(15 downto 0) when "101", -- LHU
		(XLEN - 1 downto 32 => '0') & L_SDOUT(31 downto 0) when "110", -- LWU
		(others => '0') when others;

	with L_CS(CS_WB'range) select Q_WB <=
		L_PC + "100" when "01",         -- PC + 4
		L_DOUT when "10",               -- MEM
		L_MD when "11",                 -- CSR
		L_MA when others;               -- ALU

	Q_STALL <= not C_RDY;
	Q_CS    <= (others => '0') when C_RDY = '0' else L_CS;

	Q_MRE <= C_MRE;
	Q_MWE <= C_MWE;
end architecture RTL;
