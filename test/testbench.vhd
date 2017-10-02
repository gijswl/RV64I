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
			Q_ADR : out std_logic_vector(63 downto 0);
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

	component ram is
		generic(
			ADR_WIDTH  : natural;
			DATA_WIDTH : natural;
			RAM_SIZE   : natural;
			DATA_FILE  : string
		);
		port(
			I_CLK   : in  std_logic;
			I_RST   : in  std_logic;
			I_TGD   : in  std_logic;
			I_CYC   : in  std_logic;
			I_LCK   : in  std_logic;
			I_STB   : in  std_logic;
			I_WE    : in  std_logic;
			I_TGA   : in  std_logic;    -- TODO
			I_TGC   : in  std_logic;    -- TODO
			I_SEL   : in  std_logic_vector((ADR_WIDTH / 8) - 1 downto 0);
			I_DAT   : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
			I_ADR   : in  std_logic_vector(ADR_WIDTH - 1 downto 0);
			Q_DAT   : out std_logic_vector(DATA_WIDTH - 1 downto 0);
			Q_TGD   : out std_logic;    -- TODO
			Q_ACK   : out std_logic;
			Q_STALL : out std_logic;
			Q_ERR   : out std_logic;
			Q_RTY   : out std_logic
		);
	end component ram;

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
	signal L_ADR  : std_logic_vector(63 downto 0);
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
			I_DAT => L_DATI,
			Q_DAT => L_DATO,
			Q_ADR => L_ADR,
			Q_TGD => L_TGDO,
			Q_TGA => L_TGA,
			Q_TGC => L_TGC,
			Q_CYC => L_CYC,
			Q_LCK => L_LCK,
			Q_STB => L_LCK,
			Q_WE  => L_WE
		);

	ram_module : ram
		generic map(
			ADR_WIDTH  => 64,
			DATA_WIDTH => 64,
			RAM_SIZE   => 64,
			DATA_FILE  => "C:\Users\Gijs\workspaceSigasi\RV64-priv\ram.txt"
		)
		port map(
			I_CLK   => L_CLK,
			I_RST   => L_RST,
			I_TGD   => L_TGDO,
			I_CYC   => L_CYC,
			I_LCK   => L_LCK,
			I_STB   => L_STB,
			I_WE    => L_WE,
			I_TGA   => L_TGA,
			I_TGC   => L_TGC,
			I_SEL   => L_SEL,
			I_DAT   => L_DATO,
			I_ADR   => L_ADR,
			Q_DAT   => L_DATI,
			Q_TGD   => L_TGDI,
			Q_ACK   => L_ACK,
			Q_STALL => open,
			Q_ERR   => L_ERR,
			Q_RTY   => L_RTY
		);

	scon : syscon
		port map(
			Q_CLK => L_CLK,
			Q_RST => L_RST
		);
end architecture RTL;
