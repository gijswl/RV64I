library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;

entity id_stage is
	port(
		I_CLK   : in  std_logic;
		I_RST   : in  std_logic;
		I_STALL : in  std_logic;
		I_KILL  : in  std_logic;
		I_WR    : in  std_logic;
		I_WA    : in  std_logic_vector(4 downto 0);
		I_INSTR : in  std_logic_vector(32 downto 0);
		I_WD    : in  std_logic_vector(XLEN - 1 downto 0);
		I_PC    : in  std_logic_vector(XLEN - 1 downto 0);
		Q_PC    : out std_logic_vector(XLEN - 1 downto 0);
		Q_A     : out std_logic_vector(XLEN - 1 downto 0);
		Q_B     : out std_logic_vector(XLEN - 1 downto 0);
		Q_C     : out std_logic_vector(XLEN - 1 downto 0);
		Q_CS    : out std_logic_vector(CS_SIZE - 1 downto 0);
		Q_FC    : out std_logic_vector(FC_SIZE - 1 downto 0)
	);
end entity id_stage;

architecture RTL of id_stage is
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

	component registerfile is
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
	end component registerfile;

	component itype_decoder is
		port(
			I_INSTR  : in  std_logic_vector(6 downto 0);
			Q_TYPE   : out std_logic_vector(31 downto 0);
			Q_FORMAT : out std_logic_vector(5 downto 0)
		);
	end component itype_decoder;

	signal L_WPI : std_logic;
	signal L_PC  : std_logic_vector(XLEN - 1 downto 0);
	signal L_IR  : std_logic_vector(32 downto 0);

	signal L_TYPE   : std_logic_vector(31 downto 0);
	signal L_FORMAT : std_logic_vector(5 downto 0);

	signal L_RD1 : std_logic_vector(XLEN - 1 downto 0);
	signal L_RD2 : std_logic_vector(XLEN - 1 downto 0);
	signal L_IMM : std_logic_vector(XLEN - 1 downto 0);
	signal L_CS  : std_logic_vector(CS_SIZE - 1 downto 0);
	signal L_FC  : std_logic_vector(FC_SIZE - 1 downto 0);

	signal C_RD      : std_logic_vector(4 downto 0);
	signal C_ALUFUNC : std_logic_vector(4 downto 0);
	signal C_WB      : std_logic_vector(1 downto 0);
	signal C_BJ      : std_logic_vector(1 downto 0);
	signal C_ILLEGAL : std_logic;

	signal L_FUNC       : std_logic_vector(3 downto 0);
	signal L_ALU_FUNC   : std_logic_vector(4 downto 0);
	signal L_INSTR_FUNC : std_logic_vector(4 downto 0);

	signal L_SELPC  : std_logic;
	signal L_SELIMM : std_logic;
begin
	pc : reg
		generic map(
			width => XLEN
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_PC,
			I_W   => L_WPI,
			Q_D   => L_PC
		);

	ir : reg_rst
		generic map(
			width => 33
		)
		port map(
			I_CLK => I_CLK,
			I_RST => I_RST,
			I_D   => I_INSTR,
			I_W   => L_WPI,
			Q_D   => L_IR
		);

	rf : registerfile
		port map(
			I_CLK => I_CLK,
			I_WE  => I_WR,
			I_RS1 => L_IR(19 downto 15),
			I_RS2 => L_IR(24 downto 20),
			I_WA  => I_WA,
			I_WD  => I_WD,
			Q_RD1 => L_RD1,
			Q_RD2 => L_RD2
		);

	itd : itype_decoder
		port map(
			I_INSTR  => L_IR(6 downto 0),
			Q_TYPE   => L_TYPE,
			Q_FORMAT => L_FORMAT
		);

	with L_FORMAT select L_IMM <=
		((52 downto 0 => L_IR(31)) & L_IR(30 downto 25) & L_IR(24 downto 21) & L_IR(20)) when "000010", --
		((52 downto 0 => L_IR(31)) & L_IR(30 downto 25) & L_IR(11 downto 8) & L_IR(7)) when "000100", --
		((51 downto 0 => L_IR(31)) & L_IR(7) & L_IR(30 downto 25) & L_IR(11 downto 8) & '0') when "001000", --
		((32 downto 0 => L_IR(31)) & L_IR(30 downto 20) & L_IR(19 downto 12) & (11 downto 0 => '0')) when "010000", --
		((43 downto 0 => L_IR(31)) & L_IR(19 downto 12) & L_IR(20) & L_IR(30 downto 21) & '0') when "100000", --
		X"0000000000000000" when others;

	L_FUNC <= L_IR(30) & L_IR(14 downto 12);
	with L_FUNC select L_ALU_FUNC <=
		"00010" when "0000",
		"00011" when "1000",
		"10000" when "0001",
		"00111" when "0010",
		"00111" when "1010",
		"01000" when "0011",
		"01000" when "1011",
		"00110" when "0100",
		"10001" when "0101",
		"10010" when "1101",
		"00101" when "0110",
		"00100" when "0111",
		"00000" when others;

	L_INSTR_FUNC <= "00010" when (L_TYPE(0) = '1' or L_TYPE(5) = '1' or L_TYPE(8) = '1' or L_TYPE(13) = '1' or L_TYPE(25) = '1' or L_TYPE(27) = '1') -- ADD
		else "00011" when (L_TYPE(24) = '1' and (not L_FUNC = "0110" and not L_FUNC = "0111")) -- SUBS
		else "00101" when (L_TYPE(28) = '1' and L_IR(13 downto 12) = "10") -- OR
		else "01010" when L_TYPE(24) = '1' -- SUBU
		else "01011" when (L_TYPE(28) = '1' and L_IR(13 downto 12) = "11") -- BM CLEAR
		else "00000";

	L_WPI    <= not I_STALL and not I_RST;
	L_SELPC  <= L_TYPE(5) or L_TYPE(27);
	L_SELIMM <= L_TYPE(0) or L_TYPE(4) or L_TYPE(5) or L_TYPE(8) or L_TYPE(13) or L_TYPE(25) or L_TYPE(27);

	C_RD      <= "00000" when (L_TYPE(8) = '1' or L_TYPE(24) = '1') else L_IR(11 downto 7);
	C_ALUFUNC <= L_ALU_FUNC when (L_TYPE(4) = '1' or L_TYPE(6) = '1' or L_TYPE(12) = '1' or L_TYPE(14) = '1') else L_INSTR_FUNC;
	C_WB      <= "01" when L_TYPE(25) = '1' or L_TYPE(27) = '1' -- PC + 4
		else "10" when L_TYPE(0) = '1'  -- MEM
		else "11" when L_TYPE(28) = '1' -- CSR
		else "00";                      -- ALU
	C_BJ      <= "01" when L_TYPE(25) = '1' or L_TYPE(27) = '1' -- JUMP
		else "10" when L_TYPE(24) = '1' -- BRANCH
		else "00";                      -- NONE

	C_ILLEGAL <= '1' when (L_IR(1 downto 0) /= "11" and L_IR(32) = '1')
		else '0' when (
			((L_IR(32) = '0') or (
				(L_TYPE(0) = '1' and L_IR(14 downto 12) /= "111") or -- LOAD
				(L_TYPE(3) = '1') or    -- MISC-MEM (FIXME Check FENCE valid)
				(L_TYPE(4) = '1') or    -- OP-IMM
				(L_TYPE(5) = '1') or    -- AUIPC
				(L_TYPE(6) = '1') or    -- OP-IMM-32
				(L_TYPE(8) = '1' and (L_IR(14) /= '1')) or -- STORE
				((L_TYPE(12) = '1' or L_TYPE(14) = '1') and (L_IR(31 downto 25) = "0000000" or L_IR(31 downto 25) = "01000000")) or -- OP / OP-32
				(L_TYPE(13) = '1') or   -- LUI
				(L_TYPE(24) = '1' and (L_IR(14 downto 12) /= "010" and L_TYPE(14 downto 12) /= "011")) or -- BRANCH
				(L_TYPE(25) = '1' and L_IR(14 downto 12) = "000") or -- JALR
				(L_TYPE(27) = '1') or   -- JAL
				(L_TYPE(28) = '1' and L_IR(14 downto 12) /= "100") -- SYSTEM
			))
		)
		else '1';

	L_CS(CS_RD'range)   <= C_RD;
	L_CS(CS_ALU'range)  <= C_ALUFUNC;
	L_CS(CS_FC'range)   <= L_IR(14 downto 12);
	L_CS(CS_WB'range)   <= C_WB;
	L_CS(CS_BJ'range)   <= C_BJ;
	L_CS(CS_SZ'range)   <= "1" when L_TYPE(6) = '1' or L_TYPE(14) = '1' else "0";
	L_CS(CS_LD'range)   <= "1" when L_TYPE(0) = '1' else "0";
	L_CS(CS_ST'range)   <= "1" when L_TYPE(8) = '1' else "0";
	L_CS(CS_WE'range)   <= "1" when (L_FORMAT(2) = '0' and L_FORMAT(3) = '0') else "0";
	L_CS(CS_SY'range)   <= "1" when L_TYPE(28) = '1' else "0";
	L_CS(CS_SYWE'range) <= "1" when L_TYPE(28) = '1' and L_IR(19 downto 15) /= "00000" else "0";
	L_CS(CS_ILL'range)  <= "1" when C_ILLEGAL = '1' else "0";

	L_FC(FC_RS1'range) <= L_IR(19 downto 15);
	L_FC(FC_RS2'range) <= L_IR(24 downto 20);
	L_FC(FC_RA'range)  <= "1" when L_SELPC = '0' else "0";
	L_FC(FC_RB'range)  <= "1" when L_SELIMM = '0' else "0";
	L_FC(FC_RC'range)  <= "1" when (L_TYPE(24) = '0' and L_TYPE(28) = '0') else "0";

	Q_PC <= L_PC;
	Q_A  <= L_PC when L_SELPC = '1' else L_RD1;
	Q_B  <= L_IMM when L_SELIMM = '1'
		else (XLEN - 1 downto 5 => '0') & L_FC(FC_RS1'range) when (L_TYPE(28) = '1' and L_CS(CS_FC'left) = '1')
		else L_RD2;
	Q_C  <= L_IMM when (L_TYPE(24) = '1' or L_TYPE(28) = '1') else L_RD2;
	Q_CS <= (others => '0') when I_KILL = '1' or I_RST = '1' or L_IR(32) = '0' else L_CS;
	Q_FC <= (others => '0') when I_KILL = '1' or I_RST = '1' or L_IR(32) = '0' else L_FC;
end architecture RTL;
