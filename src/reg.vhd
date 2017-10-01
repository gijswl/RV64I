library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;

entity reg is
	generic(
		width : natural
	);
	port(
		I_CLK : in  std_logic;
		I_D   : in  std_logic_vector(width-1 downto 0);
		I_W   : in  std_logic;
		Q_D   : out std_logic_vector(width-1 downto 0)
	);
end entity reg;

architecture RTL of reg is
	signal L_CONTENT : std_logic_vector(width-1 downto 0) := (others =>'0');
begin
	process(I_CLK)
	begin
		if (rising_edge(I_CLK)) then
			if (I_W = '1') then
				L_CONTENT <= I_D;
			end if;
		end if;
	end process;

	Q_D <= L_CONTENT;
end architecture RTL;