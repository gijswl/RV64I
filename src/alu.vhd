library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.constants.all;

entity alu is
	port(
		I_CLK : in  std_logic;
		I_SZ  : in  std_logic;
		I_A   : in  std_logic_vector(XLEN - 1 downto 0);
		I_B   : in  std_logic_vector(XLEN - 1 downto 0);
		I_FC  : in  std_logic_vector(4 downto 0);
		Q_CC  : out std_logic_vector(2 downto 0); -- V N Z
		Q_O   : out std_logic_vector(XLEN - 1 downto 0)
	);
end entity alu;

architecture RTL of alu is
	signal L_CC    : std_logic_vector(2 downto 0);
	signal L_OUT   : std_logic_vector(XLEN - 1 downto 0);
	signal L_OUTSZ : std_logic_vector(XLEN - 1 downto 0);
	signal L_ALU   : std_logic_vector(XLEN downto 0); -- Extra bit to detect overflow
	signal L_SHIFT : std_logic_vector(XLEN downto 0);

	signal U_A : std_logic_vector(XLEN downto 0);
	signal U_B : std_logic_vector(XLEN downto 0);
	signal S_A : std_logic_vector(XLEN downto 0);
	signal S_B : std_logic_vector(XLEN downto 0);
begin
	U_A <= '0' & I_A;
	U_B <= '0' & I_B;
	S_A <= I_A(63) & I_A;
	S_B <= I_B(63) & I_B;

	process(I_CLK)
	begin
		if (falling_edge(I_CLK)) then
			case I_FC(3 downto 0) is
				when "0000" =>          -- pass A | shift left logic
					L_ALU   <= U_A;
					L_SHIFT <= STD_LOGIC_VECTOR(SHL(U_A, U_B(4 downto 0)));
				when "0001" =>          -- pass B | shift right logic
					L_ALU   <= U_B;
					L_SHIFT <= STD_LOGIC_VECTOR(SHR(U_A, U_B(4 downto 0)));
				when "0010" =>          -- add | shift right arithmetic
					L_ALU   <= S_A + S_B;
					L_SHIFT <= STD_LOGIC_VECTOR(SHR(S_A, U_B(4 downto 0)));
				when "0011" =>          -- subtract (signed)
					L_ALU   <= S_A - S_B;
					L_SHIFT <= (others => 'Z');
				when "0100" =>          -- and
					L_ALU   <= U_A and U_B;
					L_SHIFT <= (others => 'Z');
				when "0101" =>          -- or
					L_ALU   <= U_A or U_B;
					L_SHIFT <= (others => 'Z');
				when "0110" =>          -- xor
					L_ALU   <= U_A xor U_B;
					L_SHIFT <= (others => 'Z');
				when "0111" =>          -- compare (signed)
					if (S_A < S_B) then
						L_ALU <= '0' & X"0000000000000001";
					else
						L_ALU <= '0' & X"0000000000000000";
					end if;
					L_SHIFT <= (others => 'Z');
				when "1000" =>          -- compare (unsigned)
					if (U_A < U_B) then
						L_ALU <= '0' & X"0000000000000001";
					else
						L_ALU <= '0' & X"0000000000000000";
					end if;
					L_SHIFT <= (others => 'Z');
				when "1001" =>          -- add 4
					L_ALU   <= U_A + ('0' & X"0000000000000004");
					L_SHIFT <= (others => 'Z');
				when "1010" =>          -- subtract (unsigned)
					L_ALU   <= U_A - U_B;
					L_SHIFT <= (others => 'Z');
				when "1011" =>          -- bitmap clear
					L_ALU   <= U_A and not U_B;
					L_SHIFT <= (others => 'Z');
				when others =>          -- nothing
					L_ALU   <= (others => 'Z');
					L_SHIFT <= (others => 'Z');
			end case;
		end if;
	end process;

	L_OUT   <= L_ALU(XLEN - 1 downto 0) when I_FC(4) = '0' else L_SHIFT(XLEN - 1 downto 0);
	L_OUTSZ <= ((XLEN - 33 downto 0 => L_ALU(31)) & L_ALU(31 downto 0)) when I_FC(4) = '0' else ((XLEN - 33 downto 0 => L_SHIFT(31)) & L_SHIFT(31 downto 0));
	L_CC(0) <= '1' when L_ALU = X"0000000000000000" else '0';
	L_CC(1) <= '1' when L_OUT(XLEN - 1) = '1' else '0';
	L_CC(2) <= L_ALU(XLEN) when I_FC(4) = '0' else L_SHIFT(XLEN);
	Q_O     <= L_OUT when I_SZ = '0' else L_OUTSZ;
	Q_CC    <= L_CC;
end architecture RTL;
