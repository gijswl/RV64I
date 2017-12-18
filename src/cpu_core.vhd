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
			I_MRDY   : in std_logic;
			I_MIN    : in std_logic_vector(XLEN - 1 downto 0);
			I_TARGET : in  std_logic_vector(XLEN - 1 downto 0);
			Q_MMASK  : out std_logic_vector((XLEN / 8) - 1 downto 0);
			Q_PC     : out std_logic_vector(XLEN - 1 downto 0);
			Q_MADDR  : out std_logic_vector(XLEN - 1 downto 0);
			Q_INSTR  : out std_logic_vector(32 downto 0);
			Q_MRE    : out std_logic
		);
	end component if_stage;

	signal IF_PC    : std_logic_vector(XLEN - 1 downto 0);
	signal IF_INSTR : std_logic_vector(32 downto 0);
	signal IF_MRDY  : std_logic;
	signal IF_MRE   : std_logic;
	signal IF_MIN   : std_logic_vector(XLEN - 1 downto 0);
	signal IF_MADDR : std_logic_vector(XLEN - 1 downto 0);
	signal IF_MMASK : std_logic_vector((XLEN / 8) - 1 downto 0);

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
	
	signal A_CUR_MEM : std_logic_vector(1 downto 0);
begin
	stage_if : if_stage
		port map(
			I_CLK    => I_CLK,
			I_RST    => I_RST,
			I_SELT   => L_SELT,
			I_STALL  => L_STALL,
			I_KILL   => L_KILLIF,
			I_MRDY   => IF_MRDY,
			I_MIN    => IF_MIN,
			I_TARGET => L_PCTARGET,
			Q_MMASK  => IF_MMASK,
			Q_PC     => IF_PC,
			Q_MADDR  => IF_MADDR,
			Q_INSTR  => IF_INSTR,
			Q_MRE    => IF_MRE
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
		
	process(IF_MRE, MA_MRE, MA_MWE, I_MRDY, I_RST)
	begin
		if(falling_edge(I_MRDY) or I_RST = '1') then
			if((A_CUR_MEM = "01" and IF_MRE = '1') or (A_CUR_MEM = "10" and (MA_MRE = '1' or MA_MWE = '1'))) then
				
			else
				A_CUR_MEM <= "00";
			end if;
		end if;
		if((MA_MRE = '1' or MA_MWE = '1') and A_CUR_MEM = "00") then
			A_CUR_MEM <= "10";
		elsif(IF_MRE = '1' and A_CUR_MEM = "00") then
			A_CUR_MEM <= "01";
		end if;
	end process;

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


	IF_MRDY <= I_MRDY when A_CUR_MEM = "01" else '0';
	MA_MRDY <= I_MRDY when A_CUR_MEM = "10" else '0';
	
	IF_MIN  <= I_MIN;
	MA_MIN  <= I_MIN;

	L_KILLIF <= L_SELT or EX_KILL;
	L_KILLID <= L_SELT or EX_KILL;
	L_KILLEX <= EX_KILL;
	L_KILLMA <= '0';

	Q_MMASK <= MA_MMASK when A_CUR_MEM = "10" else IF_MMASK when A_CUR_MEM = "01" else (others => 'Z');
	Q_MOUT  <= MA_MOUT when A_CUR_MEM = "10" else (others => '0');
	Q_MADDR <= MA_MADDR when A_CUR_MEM = "10" else IF_MADDR when A_CUR_MEM = "01" else (others => 'Z');
	Q_MWE   <= MA_MWE when A_CUR_MEM = "10" else '0';
	Q_MRE   <= MA_MRE when A_CUR_MEM = "10" else IF_MRE when A_CUR_MEM = "01" else '0';
end architecture RTL;
