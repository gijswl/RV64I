library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity syscon is
	port(
		Q_CLK : out std_logic;
		Q_RST : out std_logic
	);
end entity syscon;

architecture RTL of syscon is
	signal L_INIT : std_logic := '0';

	signal L_CLK : std_logic;
	signal L_RST : std_logic;

	signal L_CNT : integer := 0;
begin
	process
	begin
		clock_loop : loop
			L_CNT <= L_CNT + 1;
			L_CLK <= transport '0';
			wait for 5 ns;

			L_CLK <= transport '1';
			wait for 5 ns;
		end loop clock_loop;
	end process;

	rst : process(L_CLK)
	begin
		if (rising_edge(L_CLK) and L_INIT = '0') then
			L_INIT <= '1';
			L_RST  <= '1';
		elsif (rising_edge(L_CLK) and L_INIT = '1') then
			L_RST <= '0';
		end if;
	end process rst;

	Q_CLK <= L_CLK;
	Q_RST <= L_RST;
end architecture RTL;
