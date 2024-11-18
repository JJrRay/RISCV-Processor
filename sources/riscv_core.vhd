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
-- Component declaration for all riscv_modules are in riscv_pkg

-- Signals Instruction Fetch
    -- (IF) Signals for PC
    signal pc        : std_logic_vector(XLEN-1 downto 0);             -- Program counter output 
    signal stall     : std_logic;                                     -- Stall signal
    signal transfert : std_logic;                                     -- Transfer signal
    signal target    : std_logic_vector(XLEN-1 downto 0);             -- Target address for jump

    -- (IF) Signals for IMEM
    signal imem_en   : std_logic;       

    -- (IF/ID) Signals for Pipeline Register
    signal instr :  std_logic_vector(31 downto 0);

-- Signals Instruction Decode
    -- (ID) Signals Register File 
    signal we      : std_logic;                         -- Write enable for the register file
    signal addr_r1 : std_logic_vector(REG_WIDTH-1 downto 0);  -- Read address A
    signal data_r1 : std_logic_vector(XLEN-1 downto 0);  -- Read data A
    signal addr_r2 : std_logic_vector(REG_WIDTH-1 downto 0);  -- Read address B
    signal data_r2 : std_logic_vector(XLEN-1 downto 0);  -- Read data B
    signal addr_w  : std_logic_vector(REG_WIDTH-1 downto 0);  -- Write address
    signal data_w  : std_logic_vector(XLEN-1 downto 0);  -- Write data
    -- (ID) Signals predecode
    signal opcode  : std_logic_vector(6 downto 0)
    signal funct3  : std_logic_vector(2 downto 0)
    signal funct7  : std_logic_vector(6 downto 0)
    -- (ID) Signals decode
    signal branch  : std_logic;
    signal jump    : std_logic;
    signal rw      : std_logic;
    signal wb      : std_logic;
    signal arith   : std_logic;
    signal sign    : std_logic;
    signal imm     : std_logic_vector(19,0);
    signal src_imm : std_logic;
    signal alu_op  : std_logic_vector(ALUOP_WIDTH-1 downto 0);


begin 


end architecture beh;
