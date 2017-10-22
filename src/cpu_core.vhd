library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;

entity cpu_core is
	port(
		I_CLK   : in  std_logic;
		I_RST   : in  std_logic;
		I_MRDY  : in  std_logic;
		I_MIN   : in  std_logic_vector(XLEN - 1 downto 0);
		Q_MADDR : out std_logic_vector(XLEN - 1 downto 0);
		Q_MOUT  : out std_logic_vector(XLEN - 1 downto 0);
		Q_MMASK : out std_logic_vector((XLEN / 8) - 1 downto 0);
		Q_MRE   : out std_logic;
		Q_MWE   : out std_logic
	);
end entity cpu_core;

architecture RTL of cpu_core is
	component if_stage is
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
	end component if_stage;

	signal IF_PC    : std_logic_vector(XLEN - 1 downto 0);
	signal IF_INSTR : std_logic_vector(32 downto 0);

	component id_stage is
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
	end component id_stage;

	signal ID_PC : std_logic_vector(XLEN - 1 downto 0);
	signal ID_A  : std_logic_vector(XLEN - 1 downto 0);
	signal ID_B  : std_logic_vector(XLEN - 1 downto 0);
	signal ID_C  : std_logic_vector(XLEN - 1 downto 0);
	signal ID_CS : std_logic_vector(CS_SIZE - 1 downto 0);

	component ex_stage is
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
	end component ex_stage;

	signal EX_PC   : std_logic_vector(XLEN - 1 downto 0);
	signal EX_MA   : std_logic_vector(XLEN - 1 downto 0);
	signal EX_MD   : std_logic_vector(XLEN - 1 downto 0);
	signal EX_CS   : std_logic_vector(CS_SIZE - 1 downto 0);
	signal EX_KILL : std_logic;

	component ma_stage is
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
	end component ma_stage;

	signal MA_WB : std_logic_vector(XLEN - 1 downto 0);
	signal MA_CS : std_logic_vector(CS_SIZE - 1 downto 0);

	signal MA_MRDY  : std_logic;
	signal MA_MWE   : std_logic;
	signal MA_MRE   : std_logic;
	signal MA_MIN   : std_logic_vector(XLEN - 1 downto 0);
	signal MA_MADDR : std_logic_vector(XLEN - 1 downto 0);
	signal MA_MOUT  : std_logic_vector(XLEN - 1 downto 0);
	signal MA_MMASK : std_logic_vector((XLEN / 8) - 1 downto 0);

	component wb_stage is
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
	end component wb_stage;

	signal WB_WR : std_logic;
	signal WB_WA : std_logic_vector(4 downto 0);
	signal WB_WD : std_logic_vector(XLEN - 1 downto 0);

	signal L_SELT     : std_logic;
	signal L_PCTARGET : std_logic_vector(XLEN - 1 downto 0);

	signal L_FC   : std_logic_vector(FC_SIZE - 1 downto 0);
	signal L_FW_A : std_logic_vector(1 downto 0);
	signal L_FW_B : std_logic_vector(1 downto 0);
	signal L_FW_C : std_logic_vector(1 downto 0);

	signal L_STALL  : std_logic := '0';
	signal L_KILLIF : std_logic;
	signal L_KILLID : std_logic;
	signal L_KILLEX : std_logic;
	signal L_KILLMA : std_logic;
begin
	stage_if : if_stage
		port map(
			I_CLK    => I_CLK,
			I_RST    => I_RST,
			I_SELT   => L_SELT,
			I_STALL  => L_STALL,
			I_KILL   => L_KILLIF,
			I_TARGET => L_PCTARGET,
			Q_PC     => IF_PC,
			Q_INSTR  => IF_INSTR
		);

	stage_id : id_stage
		port map(
			I_CLK   => I_CLK,
			I_RST   => I_RST,
			I_STALL => L_STALL,
			I_KILL  => L_KILLID,
			I_WR    => WB_WR,
			I_WA    => WB_WA,
			I_INSTR => IF_INSTR,
			I_WD    => WB_WD,
			I_PC    => IF_PC,
			Q_PC    => ID_PC,
			Q_A     => ID_A,
			Q_B     => ID_B,
			Q_C     => ID_C,
			Q_CS    => ID_CS,
			Q_FC    => L_FC
		);

	stage_ex : ex_stage
		port map(
			I_CLK      => I_CLK,
			I_RST      => I_RST,
			I_STALL    => L_STALL,
			I_KILL     => L_KILLEX,
			I_FW_A     => L_FW_A,
			I_FW_B     => L_FW_B,
			I_FW_C     => L_FW_C,
			I_MA_FW    => MA_WB,
			I_A        => ID_A,
			I_B        => ID_B,
			I_C        => ID_C,
			I_PC       => ID_PC,
			I_CS       => ID_CS,
			Q_CS       => EX_CS,
			Q_PC       => EX_PC,
			Q_MA       => EX_MA,
			Q_MD       => EX_MD,
			Q_PCTARGET => L_PCTARGET,
			Q_SELT     => L_SELT,
			Q_KILL     => EX_KILL
		);

	stage_ma : ma_stage
		port map(
			I_CLK   => I_CLK,
			I_RST   => I_RST,
			I_MRDY  => MA_MRDY,
			I_PC    => EX_PC,
			I_MA    => EX_MA,
			I_MD    => EX_MD,
			I_MIN   => MA_MIN,
			I_CS    => EX_CS,
			Q_CS    => MA_CS,
			Q_MMASK => MA_MMASK,
			Q_WB    => MA_WB,
			Q_MADDR => MA_MADDR,
			Q_MOUT  => MA_MOUT,
			Q_MWE   => MA_MWE,
			Q_MRE   => MA_MRE,
			Q_STALL => L_STALL
		);

	stage_wb : wb_stage
		port map(
			I_CLK   => I_CLK,
			I_RST   => I_RST,
			I_STALL => L_STALL,
			I_WB    => MA_WB,
			I_CS    => MA_CS,
			Q_WD    => WB_WD,
			Q_WA    => WB_WA,
			Q_WR    => WB_WR
		);

	L_FW_A <= FW_EX when (
			((L_FC(FC_RS1'range) = EX_CS(CS_RD'range)) and (EX_CS(CS_WE'range) = "1" and not (EX_CS(CS_RD'range) = "00000")) and L_FC(FC_RA'range) = "1")
		)
		else FW_MA when (
			((L_FC(FC_RS1'range) = MA_CS(CS_RD'range)) and (MA_CS(CS_WE'range) = "1" and not (MA_CS(CS_RD'range) = "00000")) and L_FC(FC_RA'range) = "1")
		)
		else FW_NO;
	L_FW_B <= FW_EX when (
			((L_FC(FC_RS2'range) = EX_CS(CS_RD'range)) and (EX_CS(CS_WE'range) = "1" and not (EX_CS(CS_RD'range) = "00000")) and L_FC(FC_RB'range) = "1")
		)
		else FW_MA when (
			((L_FC(FC_RS2'range) = MA_CS(CS_RD'range)) and (MA_CS(CS_WE'range) = "1" and not (MA_CS(CS_RD'range) = "00000")) and L_FC(FC_RB'range) = "1")
		)
		else FW_NO;
	L_FW_C <= FW_EX when (
			((L_FC(FC_RS2'range) = EX_CS(CS_RD'range)) and (EX_CS(CS_WE'range) = "1" and not (EX_CS(CS_RD'range) = "00000")) and L_FC(FC_RC'range) = "1")
		)
		else FW_MA when (
			((L_FC(FC_RS2'range) = MA_CS(CS_RD'range)) and (MA_CS(CS_WE'range) = "1" and not (MA_CS(CS_RD'range) = "00000")) and L_FC(FC_RC'range) = "1")
		)
		else FW_NO;

	MA_MRDY <= I_MRDY;
	MA_MIN  <= I_MIN;

	L_KILLIF <= L_SELT or EX_KILL;
	L_KILLID <= L_SELT or EX_KILL;
	L_KILLEX <= EX_KILL;
	L_KILLMA <= '0';

	Q_MMASK <= MA_MMASK;
	Q_MOUT  <= MA_MOUT;
	Q_MADDR <= MA_MADDR;
	Q_MWE   <= MA_MWE;
	Q_MRE   <= MA_MRE;
end architecture RTL;