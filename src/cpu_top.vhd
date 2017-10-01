library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu_top is
	port(
		I_CLK : in  std_logic;
		I_RST : in  std_logic;
		I_ACK : in  std_logic;
		I_STL : in  std_logic;
		I_ERR : in  std_logic;
		I_RTY : in  std_logic;
		I_TGD : in  std_logic;          -- TODO
		I_DAT : in  std_logic_vector(63 downto 0);
		Q_DAT : out std_logic_vector(63 downto 0);
		Q_ADR : out std_logic_vector(47 downto 0);
		Q_SEL : out std_logic_vector(7 downto 0);
		Q_TGD : out std_logic;          -- TODO
		Q_TGA : out std_logic;          -- TODO
		Q_TGC : out std_logic;          -- TODO
		Q_CYC : out std_logic;
		Q_LCK : out std_logic;
		Q_STB : out std_logic;
		Q_WE  : out std_logic
	);
end entity cpu_top;

architecture RTL of cpu_top is
	component cpu_core is
		port(
			I_CLK : in std_logic;
			I_RST : in std_logic
		);
	end component cpu_core;
begin
	core0 : cpu_core
		port map(
			I_CLK => I_CLK,
			I_RST => I_RST
		);
end architecture RTL;
