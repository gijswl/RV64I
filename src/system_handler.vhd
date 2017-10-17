library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.constants.all;

entity system_handler is
	generic(
		VENDOR_ID : std_logic_vector(XLEN - 1 downto 0);
		ARCH_ID   : std_logic_vector(XLEN - 1 downto 0);
		IMP_ID    : std_logic_vector(XLEN - 1 downto 0);
		HART_ID   : std_logic_vector(XLEN - 1 downto 0)
	);
	port(
		I_CLK    : in  std_logic;
		I_RST    : in  std_logic;
		I_WR     : in  std_logic;
		I_INT    : in  std_logic;
		I_EXC    : in  std_logic;
		I_CAUSE  : in  std_logic_vector(3 downto 0);
		I_EPC    : in  std_logic_vector(XLEN - 1 downto 0);
		I_CSRSEL : in  std_logic_vector(11 downto 0);
		I_CSRDAT : in  std_logic_vector(XLEN - 1 downto 0);
		I_PC     : in  std_logic_vector(XLEN - 1 downto 0);
		I_CS     : in  std_logic_vector(CS_SIZE - 1 downto 0);
		Q_CSR    : out std_logic_vector(XLEN - 1 downto 0);
		Q_PC     : out std_logic_vector(XLEN - 1 downto 0);
		Q_SELPC  : out std_logic
	);
end entity system_handler;

architecture RTL of system_handler is
	signal MSTATUS    : std_logic_vector(XLEN - 1 downto 0) := (others => '0');
	signal MISA       : std_logic_vector(XLEN - 1 downto 0) := X"8000000000000000";
	signal MEDELEG    : std_logic_vector(XLEN - 1 downto 0) := (others => '0');
	signal MIDELEG    : std_logic_vector(XLEN - 1 downto 0) := (others => '0');
	signal MIE        : std_logic_vector(XLEN - 1 downto 0) := (others => '0');
	signal MTVEC      : std_logic_vector(XLEN - 1 downto 0) := X"0000000000001000";
	signal MCOUNTEREN : std_logic_vector(XLEN - 1 downto 0) := (others => '0');

	signal MSCRATCH : std_logic_vector(XLEN - 1 downto 0) := (others => '0');
	signal MEPC     : std_logic_vector(XLEN - 1 downto 0) := (others => '0');
	signal MCAUSE   : std_logic_vector(XLEN - 1 downto 0) := (others => '0');
	signal MTVAL    : std_logic_vector(XLEN - 1 downto 0) := (others => '0');
	signal MIP      : std_logic_vector(XLEN - 1 downto 0) := (others => '0');

	signal MCYCLE   : std_logic_vector(XLEN - 1 downto 0) := (others => '0');
	signal MINSTRET : std_logic_vector(XLEN - 1 downto 0) := (others => '0');

	signal L_CSR_READ : std_logic_vector(XLEN - 1 downto 0);

	signal L_SELPC : std_logic                           := '0';
	signal L_PC    : std_logic_vector(XLEN - 1 downto 0) := (others => '0');
begin
	timer : process(I_CLK)
	begin
		if (rising_edge(I_CLK)) then
			MCYCLE <= MCYCLE + 1;
		end if;
	end process;

	with I_CSRSEL select L_CSR_READ <=
		MSTATUS when CSR_MSTATUS,
		MISA when CSR_MISA,
		MEDELEG when CSR_MEDELEG,
		MIDELEG when CSR_MIDELEG,
		MIE when CSR_MIE,
		MTVEC when CSR_MTVEC,
		MCOUNTEREN when CSR_MCOUNTEREN,
		
		MSCRATCH when CSR_MSCRATCH,
		MEPC when CSR_MEPC,
		MCAUSE when CSR_MCAUSE,
		MTVAL when CSR_MTVAL,
		MIP when CSR_MIP,
		
		MCYCLE when CSR_MCYCLE,
		MINSTRET when CSR_MINSTRET,
		
		VENDOR_ID when CSR_MVENDORID,
		ARCH_ID when CSR_MARCHID,
		IMP_ID when CSR_MIMPID,
		HART_ID when CSR_MHARTID,       --
		(others => '0') when others;

	process(I_CLK)
	begin
		if (I_RST = '1') then
			MSTATUS(CSR_MSTATUS_MIE'range)  <= "0";
			MSTATUS(CSR_MSTATUS_MPRV'range) <= "0";
		elsif (rising_edge(I_CLK)) then
			L_PC    <= (others => '0');
			L_SELPC <= '0';

			if (I_EXC = '1') then
				MSTATUS(CSR_MSTATUS_MPIE'range) <= MSTATUS(CSR_MSTATUS_MIE'range);
				MSTATUS(CSR_MSTATUS_MIE'range)  <= "0";
				MEPC                            <= I_EPC;
				MCAUSE(3 downto 0)              <= I_CAUSE;
				MCAUSE(XLEN - 1 downto 4)       <= X"00000000000000" & "0000";

				L_PC    <= MTVEC(XLEN - 1 downto 2) & "00";
				L_SELPC <= '1';
			elsif (I_INT = '1') then
				MSTATUS(CSR_MSTATUS_MPIE'range) <= MSTATUS(CSR_MSTATUS_MIE'range);
				MSTATUS(CSR_MSTATUS_MIE'range)  <= "0";
				MEPC                            <= I_EPC;
				MCAUSE(3 downto 0)              <= I_CAUSE;
				MCAUSE(XLEN - 1 downto 4)       <= X"80000000000000" & "0000";

				L_PC    <= MTVEC(XLEN - 1 downto 2) & "00";
				L_SELPC <= '1';
			end if;
		elsif (falling_edge(I_CLK)) then
			if (I_CS(CS_ILL'range) = "1") then
				--report "Illegal instruction" severity note;
				MSTATUS(CSR_MSTATUS_MPIE'range) <= MSTATUS(CSR_MSTATUS_MIE'range);
				MSTATUS(CSR_MSTATUS_MIE'range)  <= "0";
				MEPC                            <= I_PC;
				MCAUSE                          <= MCAUSE_INSTR_ILLEGAL;

				L_PC    <= MTVEC(XLEN - 1 downto 2) & "00";
				L_SELPC <= '1';
			elsif (I_CS(CS_FC'range) = "000" and I_CS(CS_SY'range) = "1") then
				case I_CSRSEL is
					when SYS_ECALL =>
						MSTATUS(CSR_MSTATUS_MPIE'range) <= MSTATUS(CSR_MSTATUS_MIE'range);
						MSTATUS(CSR_MSTATUS_MIE'range)  <= "0";
						MEPC                            <= I_PC;
						MCAUSE                          <= MCAUSE_ECALL_MACHINE;

						L_PC    <= MTVEC(XLEN - 1 downto 2) & "00";
						L_SELPC <= '1';
					when SYS_EBREAK =>
						MSTATUS(CSR_MSTATUS_MPIE'range) <= MSTATUS(CSR_MSTATUS_MIE'range);
						MSTATUS(CSR_MSTATUS_MIE'range)  <= "0";
						MEPC                            <= I_PC;
						MCAUSE                          <= MCAUSE_BREAKPOINT;

						L_PC    <= MTVEC(XLEN - 1 downto 2) & "00";
						L_SELPC <= '1';
					when SYS_MRET =>
						MSTATUS(CSR_MSTATUS_MPIE'range) <= "0";
						MSTATUS(CSR_MSTATUS_MIE'range)  <= MSTATUS(CSR_MSTATUS_MPIE'range);

						L_PC    <= MEPC;
						L_SELPC <= '1';
					when others =>
						--report "Illegal PRIV instruction" severity note;
						MSTATUS(CSR_MSTATUS_MPIE'range) <= MSTATUS(CSR_MSTATUS_MIE'range);
						MSTATUS(CSR_MSTATUS_MIE'range)  <= "0";
						MEPC                            <= I_PC;
						MCAUSE                          <= MCAUSE_INSTR_ILLEGAL;

						L_PC    <= MTVEC(XLEN - 1 downto 2) & "00";
						L_SELPC <= '1';
				end case;
			elsif (I_WR = '1' or rising_edge(I_WR)) then
				case I_CSRSEL is
					when CSR_MISA =>
						MISA(CSR_MISA_EXTENSIONS'range) <= I_CSRDAT(CSR_MISA_EXTENSIONS'range);
						MISA(CSR_MISA_MXL'range)        <= I_CSRDAT(CSR_MISA_MXL'range);
					when CSR_MSTATUS =>
						MSTATUS(CSR_MSTATUS_MIE'range)  <= I_CSRDAT(CSR_MSTATUS_MIE'range);
						MSTATUS(CSR_MSTATUS_MPIE'range) <= I_CSRDAT(CSR_MSTATUS_MPIE'range);
						MSTATUS(CSR_MSTATUS_MPP'range)  <= I_CSRDAT(CSR_MSTATUS_MPP'range);
					when CSR_MTVEC =>
						MTVEC(CSR_MTVEC_MODE'range) <= I_CSRDAT(CSR_MTVEC_MODE'range);
						MTVEC(CSR_MTVEC_BASE'range) <= I_CSRDAT(CSR_MTVEC_BASE'range);
					when CSR_MIE =>
						MIE(CSR_MIE_MSIE'range) <= I_CSRDAT(CSR_MIE_MSIE'range);
						MIE(CSR_MIE_MTIE'range) <= I_CSRDAT(CSR_MIE_MTIE'range);
						MIE(CSR_MIE_MEIE'range) <= I_CSRDAT(CSR_MIE_MEIE'range);
					when CSR_MEPC =>
						MEPC <= I_CSRDAT;
					when others =>
						--report "Illegal CSR write" severity note;
						MSTATUS(CSR_MSTATUS_MPIE'range) <= MSTATUS(CSR_MSTATUS_MIE'range);
						MSTATUS(CSR_MSTATUS_MIE'range)  <= "0";
						MEPC                            <= I_PC;
						MCAUSE                          <= MCAUSE_INSTR_ILLEGAL;

						L_PC    <= MTVEC(XLEN - 1 downto 2) & "00";
						L_SELPC <= '1';
				end case;
			end if;
		end if;
	end process;

	Q_CSR   <= L_CSR_READ;
	Q_PC    <= L_PC;
	Q_SELPC <= L_SELPC;
end architecture RTL;
