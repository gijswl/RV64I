library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;

entity cpu_top is
	port(
		I_CLK : in  std_logic;
		I_RST : in  std_logic;
		I_ACK : in  std_logic;
		I_STL : in  std_logic;
		I_ERR : in  std_logic;
		I_RTY : in  std_logic;
		I_TGD : in  std_logic;          -- TODO
		I_DAT : in  std_logic_vector(XLEN - 1 downto 0);
		Q_DAT : out std_logic_vector(XLEN - 1 downto 0);
		Q_ADR : out std_logic_vector(XLEN - 1 downto 0);
		Q_SEL : out std_logic_vector((XLEN / 8) - 1 downto 0);
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
	end component cpu_core;

	signal C0_MRDY  : std_logic;
	signal C0_MRE   : std_logic;
	signal C0_MWE   : std_logic;
	signal C0_MIN   : std_logic_vector(XLEN - 1 downto 0);
	signal C0_MADDR : std_logic_vector(XLEN - 1 downto 0);
	signal C0_MOUT  : std_logic_vector(XLEN - 1 downto 0);
	signal C0_MMASK : std_logic_vector((XLEN / 8) - 1 downto 0);

	signal L_STATE : std_logic_vector(1 downto 0);
	signal L_CORE  : std_logic;

	signal L_TGC : std_logic;
	signal L_TGA : std_logic;
	signal L_TGD : std_logic;

	signal L_CYC  : std_logic;
	signal L_LCK  : std_logic;
	signal L_STB  : std_logic;
	signal L_WE   : std_logic;
	signal L_DATO : std_logic_vector(XLEN - 1 downto 0);
	signal L_ADR  : std_logic_vector(XLEN - 1 downto 0);
	signal L_SEL  : std_logic_vector((XLEN / 8) - 1 downto 0);

begin
	core0 : cpu_core
		port map(
			I_CLK   => I_CLK,
			I_RST   => I_RST,
			I_MRDY  => C0_MRDY,
			I_MIN   => C0_MIN,
			Q_MADDR => C0_MADDR,
			Q_MOUT  => C0_MOUT,
			Q_MMASK => C0_MMASK,
			Q_MRE   => C0_MRE,
			Q_MWE   => C0_MWE
		);

	process(I_CLK)
	begin
		if (I_RST = '1') then
			L_STATE <= "00";
			L_CORE  <= '0';
		elsif (rising_edge(I_CLK)) then
			case L_STATE is
				when "00" =>
					C0_MRDY <= '0';
					C0_MIN  <= (others => 'Z');

					L_ADR <= (others => 'Z');
					L_CYC <= '0';
					L_STB <= '0';
					L_WE  <= '0';

					if (C0_MRE = '1') then
						L_ADR <= C0_MADDR;
						L_WE  <= '0';
						L_SEL <= C0_MMASK;
						L_CYC <= '1';
						L_STB <= '1';

						L_TGA <= '0';
						L_TGC <= '0';

						L_CORE  <= '0';
						L_STATE <= "01";
					end if;
				when "01" =>
					if (L_CORE = '0') then
						if (I_ACK = '1') then
							C0_MIN  <= I_DAT;
							C0_MRDY <= '1';

							L_CYC   <= '0';
							L_STB   <= '0';
							L_STATE <= "10";
						elsif (I_ERR = '1') then
							C0_MIN <= I_DAT;

							L_CYC   <= '0';
							L_STB   <= '0';
							L_STATE <= "10";
						end if;
					end if;
				when "10" =>
					if (L_CORE = '0') then
						L_STATE <= "00";
					end if;
				when others => null;
			end case;
		end if;
	end process;

	Q_CYC <= L_CYC;
	Q_LCK <= L_LCK;
	Q_STB <= L_STB;
	Q_WE  <= L_WE;

	Q_DAT <= L_DATO;
	Q_ADR <= L_ADR;
	Q_SEL <= L_SEL;

	Q_TGC <= L_TGC;
	Q_TGA <= L_TGA;
	Q_TGD <= L_TGD;
end architecture RTL;
