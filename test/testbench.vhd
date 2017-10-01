library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end entity testbench;

architecture RTL of testbench is
	component cpu_top is
		port(
			I_CLK : in  std_logic;
			I_RST : in  std_logic;
			I_ACK : in  std_logic;
			I_STL : in  std_logic;
			I_ERR : in  std_logic;
			I_RTY : in  std_logic;
			I_TGD : in  std_logic;      -- TODO
			I_DAT : in  std_logic_vector(63 downto 0);
			Q_DAT : out std_logic_vector(63 downto 0);
			Q_ADR : out std_logic_vector(47 downto 0);
			Q_SEL : out std_logic_vector(7 downto 0);
			Q_TGD : out std_logic;      -- TODO
			Q_TGA : out std_logic;      -- TODO
			Q_TGC : out std_logic;      -- TODO
			Q_CYC : out std_logic;
			Q_LCK : out std_logic;
			Q_STB : out std_logic;
			Q_WE  : out std_logic
		);
	end component cpu_top;

	component syscon is
		port(
			Q_CLK : out std_logic;
			Q_RST : out std_logic
		);
	end component syscon;

	signal L_CLK : std_logic;
	signal L_RST : std_logic;

	signal L_ACK  : std_logic;
	signal L_STL  : std_logic;
	signal L_ERR  : std_logic;
	signal L_RTY  : std_logic;
	signal L_TGDI : std_logic;
	signal L_DATI : std_logic_vector(63 downto 0);
	signal L_DATO : std_logic_vector(63 downto 0);
	signal L_ADR  : std_logic_vector(47 downto 0);
	signal L_SEL  : std_logic_vector(7 downto 0);
	signal L_TGDO : std_logic;
	signal L_TGA  : std_logic;
	signal L_TGC  : std_logic;
	signal L_CYC  : std_logic;
	signal L_LCK  : std_logic;
	signal L_STB  : std_logic;
	signal L_WE   : std_logic;
begin
	top : cpu_top
		port map(
			I_CLK => L_CLK,
			I_RST => L_RST,
			I_ACK => L_ACK,
			I_STL => L_STL,
			I_ERR => L_ERR,
			I_RTY => L_RTY,
			I_TGD => L_TGDI,
			I_DAT => L_DATI
		);

	scon : syscon
		port map(
			Q_CLK => L_CLK,
			Q_RST => L_RST
		);
end architecture RTL;
