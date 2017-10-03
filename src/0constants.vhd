library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

package constants is
	constant XLEN : integer := 64;

	constant DEFAULT_PC : std_logic_vector(XLEN - 1 downto 0) := X"0000000000000000";

	constant CS_RD   : std_logic_vector(4 downto 0)   := (others => '0');		-- Destination register
	constant CS_ALU  : std_logic_vector(9 downto 5)   := (others => '0');		-- ALU function
	constant CS_FC   : std_logic_vector(12 downto 10) := (others => '0');		-- Instruction func3 field
	constant CS_WB   : std_logic_vector(14 downto 13) := (others => '0');		-- Writeback source
	constant CS_BJ   : std_logic_vector(16 downto 15) := (others => '0');		-- Branch / Direct jump / Indirect jump
	constant CS_SZ   : std_logic_vector(17 downto 17) := (others => '0');		-- 32-bit ALU result
	constant CS_LD   : std_logic_vector(18 downto 18) := (others => '0');		-- Load instruction
	constant CS_ST   : std_logic_vector(19 downto 19) := (others => '0');		-- Store instruction
	constant CS_WE   : std_logic_vector(20 downto 20) := (others => '0');		-- Writeback enable
	constant CS_SY   : std_logic_vector(21 downto 21) := (others => '0');		-- System instruction
	constant CS_SYWE : std_logic_vector(22 downto 22) := (others => '0');		-- CSR write enable
	constant CS_ILL  : std_logic_vector(23 downto 23) := (others => '0');		-- Illegal instruction

	constant CS_SIZE : natural := 24;

	constant FW_NO : std_logic_vector(1 downto 0) := "00";
	constant FW_EX : std_logic_vector(1 downto 0) := "01";
	constant FW_MA : std_logic_vector(1 downto 0) := "10";

	constant FC_RS1 : std_logic_vector(4 downto 0)   := (others => '0');
	constant FC_RS2 : std_logic_vector(9 downto 5)   := (others => '0');
	constant FC_RA  : std_logic_vector(10 downto 10) := (others => '0');
	constant FC_RB  : std_logic_vector(11 downto 11) := (others => '0');
	constant FC_RC  : std_logic_vector(12 downto 12) := (others => '0');

	constant FC_SIZE : natural := 13;

	-- System functions
	constant SYS_ECALL  : std_logic_vector(11 downto 0) := x"000";
	constant SYS_EBREAK : std_logic_vector(11 downto 0) := x"001";
	constant SYS_MRET   : std_logic_vector(11 downto 0) := x"302";

	-- CSRs
	constant CSR_MSTATUS    : std_logic_vector(11 downto 0) := x"300";
	constant CSR_MISA       : std_logic_vector(11 downto 0) := x"301";
	constant CSR_MEDELEG    : std_logic_vector(11 downto 0) := x"302";
	constant CSR_MIDELEG    : std_logic_vector(11 downto 0) := x"303";
	constant CSR_MIE        : std_logic_vector(11 downto 0) := x"304";
	constant CSR_MTVEC      : std_logic_vector(11 downto 0) := x"305";
	constant CSR_MCOUNTEREN : std_logic_vector(11 downto 0) := x"306";

	constant CSR_MSCRATCH : std_logic_vector(11 downto 0) := x"340";
	constant CSR_MEPC     : std_logic_vector(11 downto 0) := x"341";
	constant CSR_MCAUSE   : std_logic_vector(11 downto 0) := x"342";
	constant CSR_MTVAL    : std_logic_vector(11 downto 0) := x"343";
	constant CSR_MIP      : std_logic_vector(11 downto 0) := x"344";

	constant CSR_MCYCLE   : std_logic_vector(11 downto 0) := x"B00";
	constant CSR_MINSTRET : std_logic_vector(11 downto 0) := x"B02";

	constant CSR_MVENDORID : std_logic_vector(11 downto 0) := x"F11";
	constant CSR_MARCHID   : std_logic_vector(11 downto 0) := x"F12";
	constant CSR_MIMPID    : std_logic_vector(11 downto 0) := x"F13";
	constant CSR_MHARTID   : std_logic_vector(11 downto 0) := x"F14";

	-- CSR fields
	constant CSR_MSTATUS_MIE  : std_logic_vector(3 downto 3)   := (others => '0');
	constant CSR_MSTATUS_MPIE : std_logic_vector(7 downto 7)   := (others => '0');
	constant CSR_MSTATUS_MPP  : std_logic_vector(12 downto 11) := (others => '0');
	constant CSR_MSTATUS_MPRV : std_logic_vector(17 downto 17) := (others => '0');

	constant CSR_MISA_EXTENSIONS : std_logic_vector(25 downto 0)              := (others => '0');
	constant CSR_MISA_MXL        : std_logic_vector(XLEN - 1 downto XLEN - 2) := (others => '0');

	constant CSR_MTVEC_MODE : std_logic_vector(1 downto 0)        := (others => '0');
	constant CSR_MTVEC_BASE : std_logic_vector(XLEN - 1 downto 2) := (others => '0');

	constant CSR_MIP_MSIP : std_logic_vector(3 downto 3)   := (others => '0');
	constant CSR_MIP_MTIP : std_logic_vector(7 downto 7)   := (others => '0');
	constant CSR_MIP_MEIP : std_logic_vector(11 downto 11) := (others => '0');

	constant CSR_MIE_MSIE : std_logic_vector(3 downto 3)   := (others => '0');
	constant CSR_MIE_MTIE : std_logic_vector(7 downto 7)   := (others => '0');
	constant CSR_MIE_MEIE : std_logic_vector(11 downto 11) := (others => '0');

	-- Exception causes
	constant MCAUSE_IADDR_MISALIGNED : std_logic_vector(XLEN - 1 downto 0) := X"0000000000000000";
	constant MCAUSE_INSTR_ACCESS     : std_logic_vector(XLEN - 1 downto 0) := X"0000000000000001";
	constant MCAUSE_INSTR_ILLEGAL    : std_logic_vector(XLEN - 1 downto 0) := X"0000000000000002";
	constant MCAUSE_BREAKPOINT       : std_logic_vector(XLEN - 1 downto 0) := X"0000000000000003";
	constant MCAUSE_LADDR_MISALIGNED : std_logic_vector(XLEN - 1 downto 0) := X"0000000000000004";
	constant MCAUSE_LOAD_ACCESS      : std_logic_vector(XLEN - 1 downto 0) := X"0000000000000005";
	constant MCAUSE_SADDR_MISALIGNED : std_logic_vector(XLEN - 1 downto 0) := X"0000000000000006";
	constant MCAUSE_STORE_ACCESS     : std_logic_vector(XLEN - 1 downto 0) := X"0000000000000007";
	constant MCAUSE_ECALL_USER       : std_logic_vector(XLEN - 1 downto 0) := X"0000000000000008";
	constant MCAUSE_ECALL_SUPERV     : std_logic_vector(XLEN - 1 downto 0) := X"0000000000000009";
	constant MCAUSE_ECALL_MACHINE    : std_logic_vector(XLEN - 1 downto 0) := X"000000000000000B";
	constant MCAUSE_IPAGE_FAULT      : std_logic_vector(XLEN - 1 downto 0) := X"000000000000000C";
	constant MCAUSE_LPAGE_FAULT      : std_logic_vector(XLEN - 1 downto 0) := X"000000000000000D";
	constant MCAUSE_SPAGE_FAULT      : std_logic_vector(XLEN - 1 downto 0) := X"000000000000000F";
	
	-- Exception sources
	constant SOURCE_MEM : std_logic_vector(XLEN -2 downto 0) := "000" & X"000000000000001"; 
end package constants;

package body constants is
end package body;
