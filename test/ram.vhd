library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity ram is
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
		I_TGA   : in  std_logic;        -- TODO
		I_TGC   : in  std_logic;        -- TODO
		I_SEL   : in  std_logic_vector((ADR_WIDTH / 8) - 1 downto 0);
		I_DAT   : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
		I_ADR   : in  std_logic_vector(ADR_WIDTH - 1 downto 0);
		Q_DAT   : out std_logic_vector(DATA_WIDTH - 1 downto 0);
		Q_TGD   : out std_logic;        -- TODO
		Q_ACK   : out std_logic;
		Q_STALL : out std_logic;
		Q_ERR   : out std_logic;
		Q_RTY   : out std_logic
	);
end entity ram;

architecture RTL of ram is
	file F_DATA : text open read_mode is DATA_FILE;

	type mem_t is array (0 to RAM_SIZE - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal mem : mem_t := (others => (others => '0'));
begin
	read_file : process(I_CLK)
		variable V_LINE : line;
		variable V_ADR  : natural;
		variable V_DAT  : std_logic_vector(DATA_WIDTH - 1 downto 0);
		variable V_SEP  : character;
		variable V_DONE : std_logic := '0';
	begin
		if (I_RST = '1' and rising_edge(I_CLK)) then
			V_DONE := '0';
		end if;
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
			report "Read ram data file" severity note;
		end if;
	end process;

	Q_ACK <= '1';
	Q_DAT <= X"C0FFEEC0FFEE9999";
end architecture RTL;
