library work;
use work.riscv_pkg.all;

entity riscv_core is
    port (
    i_rstn : in std_logic;
    i_clk : in std_logic;
    o_imem_en : out std_logic;
    o_imem_addr : out std_logic_vector(8 downto 0);
    i_imem_read : in std_logic_vector(31 downto 0);
    o_dmem_en : out std_logic;
    o_dmem_we : out std_logic;
    o_dmem_addr : out std_logic_vector(8 downto 0);
    i_dmem_read : in std_logic_vector(31 downto 0);
    o_dmem_write : out std_logic_vector(31 downto 0);

    -- DFT
    i_scan_en : in std_logic;
    i_test_mode : in std_logic;
    i_tdi : in std_logic;
    o_tdo : out std_logic);
end entity riscv_core;

--   5 Step Pipeline
-- 1 Instruction Fetch (IF)
    --IF/ID
-- 2 Instruction Decode (ID)
    --ID/EX 
-- 3 Execute (EX)
    --EX/ME
-- 4 Memory (ME)
    --ME/WB
-- 5 Write-Back (WB)

architecture beh of riscv_core is


begin 

-- instanciate Fetch module
-- instanciate Decode module
-- instanciate exectue module
-- MEMORY ACCESS
    -- DMEM block
    -- ME/WB Pipeline Register
-- WRITE-BACK
    -- Multiplexer for rd_data

end architecture beh;
