library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

-- TODO make cache act like a cache
entity d_cache is
	generic(
		ADR_WIDTH   : natural;
		DATA_WIDTH  : natural;
		CACHE_LINES : natural;
		DATA_FILE   : string
	);
	port(
		I_CLK  : in  std_logic;
		I_EN   : in  std_logic;
		I_WE   : in  std_logic;
		I_SZ   : in  std_logic_vector(1 downto 0);
		I_ADR  : in  std_logic_vector(ADR_WIDTH - 1 downto 0);
		I_DATA : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
		Q_DATA : out std_logic_vector(DATA_WIDTH - 1 downto 0)
	);
end entity d_cache;

architecture RTL of d_cache is
	file F_DATA : text open read_mode is DATA_FILE;

	type mem_t is array (0 to CACHE_LINES - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal mem : mem_t := (others => (others => '0'));

	signal L_ADR  : integer := 0;
	signal L_DATA : std_logic_vector(DATA_WIDTH - 1 downto 0);
begin
	read_file : process(I_CLK)
		variable V_LINE : line;
		variable V_ADR  : natural;
		variable V_DAT  : std_logic_vector(DATA_WIDTH - 1 downto 0);
		variable V_SEP  : character;
		variable V_DONE : std_logic := '0';
	begin
		if (V_DONE = '0') then
			while not endfile(F_DATA) loop
				readline(F_DATA, V_LINE);
				read(V_LINE, V_ADR);
				read(V_LINE, V_SEP);
				read(V_LINE, V_DAT);

				mem(V_ADR) <= V_DAT;
			end loop;
			file_close(F_DATA);
			V_DONE := '1';
			report "Read d_cache data file" severity note;
		end if;
	end process;

	L_ADR <= to_integer(unsigned(SHL(I_ADR(ADR_WIDTH - 2 downto 2), "10"))) / 4;

	process(I_CLK)
	begin
		if (rising_edge(I_CLK)) then
			L_DATA <= mem(L_ADR);
		end if;
	end process;

	Q_DATA <= L_DATA;
end architecture RTL;
