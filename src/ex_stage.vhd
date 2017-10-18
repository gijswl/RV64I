library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;

entity ex_stage is
	port(
		I_CLK      : in  std_logic;
		I_RST      : in  std_logic;
		I_STALL    : in  std_logic;
		I_KILL     : in  std_logic;
		I_FW_A     : in  std_logic_vector(1 downto 0);
		I_FW_B     : in  std_logic_vector(1 downto 0);
		I_FW_C     : in  std_logic_vector(1 downto 0);
		I_MA_FW    : in  std_logic_vector(XLEN - 1 downto 0);
		I_A        : in  std_logic_vector(XLEN - 1 downto 0);
		I_B        : in  std_logic_vector(XLEN - 1 downto 0);
		I_C        : in  std_logic_vector(XLEN - 1 downto 0);
		I_PC       : in  std_logic_vector(XLEN - 1 downto 0);
		I_CS       : in  std_logic_vector(CS_SIZE - 1 downto 0);
		Q_CS       : out std_logic_vector(CS_SIZE - 1 downto 0);
		Q_PC       : out std_logic_vector(XLEN - 1 downto 0);
		Q_MA       : out std_logic_vector(XLEN - 1 downto 0);
		Q_MD       : out std_logic_vector(XLEN - 1 downto 0);
		Q_PCTARGET : out std_logic_vector(XLEN - 1 downto 0);
		Q_SELT     : out std_logic;
		Q_KILL     : out std_logic
	);
end entity ex_stage;

architecture RTL of ex_stage is
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
			I_W   : in  std_logic;
			I_D   : in  std_logic_vector(width - 1 downto 0);
			Q_D   : out std_logic_vector(width - 1 downto 0)
		);
	end component reg_rst;

	component alu is
		port(
			I_CLK : in  std_logic;
			I_SZ  : in  std_logic;
			I_A   : in  std_logic_vector(XLEN - 1 downto 0);
			I_B   : in  std_logic_vector(XLEN - 1 downto 0);
			I_FC  : in  std_logic_vector(4 downto 0);
			Q_CC  : out std_logic_vector(2 downto 0); -- V N Z
			Q_O   : out std_logic_vector(XLEN - 1 downto 0)
		);
	end component alu;

	component system_handler is
		generic(
			VENDOR_ID : std_logic_vector(XLEN - 1 downto 0);
			ARCH_ID   : std_logic_vector(XLEN - 1 downto 0);
			IMP_ID    : std_logic_vector(XLEN - 1 downto 0);
			HART_ID   : std_logic_vector(XLEN - 1 downto 0)
		);
		port(
			I_CLK    : in  std_logic;
			I_RST    : in  std_logic;
			I_WR     : in  std_logic;
			I_INT    : in  std_logic;
			I_EXC    : in  std_logic;
			I_CAUSE  : in  std_logic_vector(3 downto 0);
			I_EPC    : in  std_logic_vector(XLEN - 1 downto 0);
			I_CSRSEL : in  std_logic_vector(11 downto 0);
			I_CSRDAT : in  std_logic_vector(XLEN - 1 downto 0);
			I_PC     : in  std_logic_vector(XLEN - 1 downto 0);
			I_CS     : in  std_logic_vector(CS_SIZE - 1 downto 0);
			Q_CSR    : out std_logic_vector(XLEN - 1 downto 0);
			Q_PC     : out std_logic_vector(XLEN - 1 downto 0);
			Q_SELPC  : out std_logic
		);
	end component system_handler;

	signal L_NS : std_logic;
	signal L_A  : std_logic_vector(XLEN - 1 downto 0);
	signal L_B  : std_logic_vector(XLEN - 1 downto 0);
	signal L_C  : std_logic_vector(XLEN - 1 downto 0);
	signal L_PC : std_logic_vector(XLEN - 1 downto 0);
	signal L_CS : std_logic_vector(CS_SIZE - 1 downto 0);

	signal ALU_A : std_logic_vector(XLEN - 1 downto 0);
	signal ALU_B : std_logic_vector(XLEN - 1 downto 0);
	signal L_IA  : std_logic_vector(XLEN - 1 downto 0);
	signal L_IB  : std_logic_vector(XLEN - 1 downto 0);
	signal L_IC  : std_logic_vector(XLEN - 1 downto 0);

	signal L_BT  : std_logic;
	signal L_SZ  : std_logic;
	signal L_CC  : std_logic_vector(2 downto 0);
	signal L_OUT : std_logic_vector(XLEN - 1 downto 0);

	signal L_IEXC  : std_logic;
	signal L_EEXC  : std_logic := '0';
	signal L_EXC   : std_logic;
	signal L_CAUSE : std_logic_vector(3 downto 0);

	signal L_PRIV     : std_logic;
	signal L_CSR      : std_logic;
	signal L_CSRI     : std_logic;
	signal L_CSR_WR   : std_logic;
	signal L_SELSYSPC : std_logic;
	signal L_CSRO     : std_logic_vector(XLEN - 1 downto 0);
	signal L_SYSPC    : std_logic_vector(XLEN - 1 downto 0);
begin
	reg_a : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => L_IA,
			I_W   => L_NS,
			Q_D   => L_A
		);
	reg_b : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => L_IB,
			I_W   => L_NS,
			Q_D   => L_B
		);
	reg_c : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => L_IC,
			I_W   => L_NS,
			Q_D   => L_C
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
	cs : reg_rst
		generic map(
			width => CS_SIZE
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_CS,
			I_RST => I_KILL,
			I_W   => L_NS,
			Q_D   => L_CS
		);

	fu : alu
		port map(
			I_CLK => I_CLK,
			I_SZ  => L_SZ,
			I_A   => ALU_A,
			I_B   => ALU_B,
			I_FC  => L_CS(CS_ALU'range),
			Q_CC  => L_CC,
			Q_O   => L_OUT
		);

	sy : system_handler
		generic map(
			VENDOR_ID => X"0000000000000000",
			ARCH_ID   => X"0000000000000000",
			IMP_ID    => X"0000000000000000",
			HART_ID   => X"0000000000000000"
		)
		port map(
			I_CLK    => I_CLK,
			I_RST    => I_RST,
			I_WR     => L_CSR_WR,
			I_INT    => '0',
			I_EXC    => L_EXC,
			I_CAUSE  => L_CAUSE,
			I_EPC    => I_PC,
			I_CSRSEL => L_C(11 downto 0),
			I_CSRDAT => L_OUT,
			I_PC     => L_PC,
			I_CS     => L_CS,
			Q_CSR    => L_CSRO,
			Q_PC     => L_SYSPC,
			Q_SELPC  => L_SELSYSPC
		);
        
	L_NS <= not I_STALL;
	L_SZ <= '1' when L_CS(CS_SZ'range) = "1" else '0';

	L_IA <= I_A when I_FW_A = FW_NO
		else L_OUT when I_FW_A = FW_EX
		else I_MA_FW when I_FW_A = FW_MA
	;
	L_IB <= I_B when I_FW_B = FW_NO
		else L_OUT when I_FW_B = FW_EX
		else I_MA_FW when I_FW_B = FW_MA
	;
	L_IC <= I_C when I_FW_C = FW_NO
		else L_OUT when I_FW_C = FW_EX
		else I_MA_FW when I_FW_C = FW_MA
	;

	L_PRIV   <= '1' when (L_CS(CS_SY'range) = "1" and L_CS(CS_FC'range) = "000") else '0';
	L_CSR    <= '1' when (L_CS(CS_SY'range) = "1" and (L_PRIV = '0' and L_CS(CS_FC'left) = '0')) else '0';
	L_CSRI   <= '1' when (L_CS(CS_SY'range) = "1" and (L_PRIV = '0' and L_CS(CS_FC'left) = '1')) else '0';
	L_CSR_WR <= '1' when (L_CSR = '1' or L_CSRI = '1') and L_CS(CS_SYWE'range) = "1" else '0';

	ALU_A <= L_CSRO when (L_CSR = '1' or L_CSRI = '1') else L_A;
	ALU_B <= L_A when L_CSR = '1' else L_B;

	L_BT <= '1' when L_CS(CS_BJ'range) = "10" and (
		(L_CS(CS_FC'range) = "000" and L_CC(0) = '1') or (L_CS(CS_FC'range) = "001" and L_CC(0) = '0') or ((L_CS(CS_FC'range) = "101" or L_CS(CS_FC'range) = "111") and (L_CC(1) = '0' and L_CC(2) = '0')) or ((L_CS(CS_FC'range) = "100" or L_CS(CS_FC'range) = "110") and (L_CC(1) = '1' and L_CC(2) = '1'))
	) else '0';

    L_IEXC <= '1' when (
        (
            (L_OUT(2 downto 0) /= "000" and (L_CS(CS_LD'range) = "1" or L_CS(CS_ST'range) = "1") and (L_CS(CS_FC'range) = "011" or L_CS(CS_FC'range) = "110")) or --
            (L_OUT(1 downto 0) /= "00" and (L_CS(CS_LD'range) = "1" or L_CS(CS_ST'range) = "1") and (L_CS(CS_FC'range) = "010" or L_CS(CS_FC'range) = "101")) or --
            (L_OUT(0) /= '0' and (L_CS(CS_LD'range) = "1" or L_CS(CS_ST'range) = "1") and (L_CS(CS_FC'range) = "001" or L_CS(CS_FC'range) = "100")) --
        ) and I_CLK = '0'
    ) else '0';   
    
	L_EXC <= L_IEXC or L_EEXC;

	L_CAUSE <= "0100" when (L_IEXC = '1' and L_CS(CS_LD'range) = "1") -- Load address misaligned
		else "0110" when (L_IEXC = '1' and L_CS(CS_ST'range) = "1") -- Store address misaligned
		else "0000";

	Q_KILL     <= L_IEXC;
	Q_PC       <= L_PC;
	Q_MA       <= L_OUT;
	Q_MD       <= L_CSRO when L_CSR = '1' or L_CSRI = '1' else L_C;
	Q_CS       <= (others => '0') when L_SELSYSPC = '1' or I_RST = '1' or L_IEXC = '1' else L_CS;
	Q_SELT     <= '1' when (L_BT = '1' or L_CS(CS_BJ'range) = "01" or L_SELSYSPC = '1') else '0';
	Q_PCTARGET <= L_SYSPC when L_SELSYSPC = '1'
		else (L_PC + L_IC) when L_CS(CS_BJ'range) = "10"
		else L_OUT;
end architecture RTL;
