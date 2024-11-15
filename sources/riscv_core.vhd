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


begin 
-- Instruction Fetch
    -- IF Instantiate Program Counter from riscv_pkg
    u_riscv_pc: riscv_pc
        generic map (
            RESET_VECTOR => 16#00000000#  -- Set the reset vector to 0x00000000
        )
        port map (
            i_clk       => i_clk,           -- Clock signal
            i_rstn      => i_rstn,          -- Reset (active low)
            i_stall     => stall,         -- Stall signal (EX)
            i_transfert => transfert,     -- Transfer signal (EX)
            i_target    => target,        -- Target address (EX)
            o_pc        => pc      -- Program counter output (imem)
        );
    o_imem_addr <= s_pc(MEM_ADDR_WIDTH-1 downto 0) --Assuming LSB
    o_imem_en <= imem_en;
   

-- IF/ID Pipeline Register: Store instruction fetched in the IF stage
    process(i_clk)
    begin
        if rising_edge(i_clk, stall, flush) then
            if flush = '1' then
                -- On reset, clear the instruction register and valid signal
                instr <= (others => '0');
                imem_en <='0';
            else
                if stall = '1' then
                    instr <= instr;  -- Hold the instruction
                    imem_en <='0';
                else
                    imem_en <='1';
                    instr <= i_imem_read;     -- Fetch the instruction
                end if;
            end if;
        end if;
    end process;

-- Instruction Decode
    -- ID Instantiate Register_file from riscv_pkg
    rf_inst : riscv_rf
        port map (
            i_clk     => i_clk,                    -- Clock
            i_rstn    => i_rstn,                   -- Reset (active low)
            i_we      => we,                     -- Write enable
            i_addr_r1 => addr_r1,                -- Read address 1
            o_data_r1 => data_r1,                -- Read data 1
            i_addr_r2 => addr_r2,                -- Read address 2
            o_data_r2 => data_r2,                -- Read data 2
            i_addr_w  => addr_w,                 -- Write address
            i_data_w  => data_w                  -- Write data
        );
    -- ID predecode : split instr in rs1,rs2,opcode,funct3 and funct7
    opcode  : instr(6 downto 0);
    funct3  : instr(14 downto 12);
    addr_r1 : instr(19 downto 15);
    addr_r2 : instr(24 down to 20);
    funct7  : instr(31 downto 25);
    -- ID Decode : Decode opcode,funct3 and funct7 for EX

    when "0110011" =>  -- R-type opcode (ALU operations)
        -- decode funct3, funct7 to identify ALU operation
        case decoded_funct3 is
            when "000" =>  -- ADD or SUB
                if decoded_funct7 = "0000000" then
                    alu_op <= "000";  -- ADD
                elsif decoded_funct7 = "0100000" then
                    alu_op <= "001";  -- SUB
                else
                    alu_op <= "111";  -- Invalid (or other logic)
                end if;
            when "001" =>  -- SLL (Shift Left Logical)
                alu_op <= "010";
            when "010" =>  -- SLT (Set Less Than)
                alu_op <= "011";
            when "011" =>  -- SLTU (Set Less Than Unsigned)
                alu_op <= "100";
            when "100" =>  -- XOR
                alu_op <= "101";
            when "101" =>  -- SRL or SRA (Shift Right Logical/Arithmetic)
                if decoded_funct7 = "0000000" then
                    alu_op <= "110";  -- SRL
                elsif decoded_funct7 = "0100000" then
                    alu_op <= "111";  -- SRA
                end if;
            when "110" =>  -- OR
                alu_op <= "1000";
            when "111" =>  -- AND
                alu_op <= "1001";
            when others => 
                alu_op <= "1111";  -- Invalid ALU operation (error state or other logic)
        end case;
    when others => 
        --Handle other opcodes (e.g., I-type, B-type, etc.)
        alu_op <= "1111";  -- Invalid opcode (error state or other logic)
    end case;

        end if;
    end if;
end process;
    -- ID/EX Pipeline Register: Store instrcution decoded in the ID stage



end architecture beh;
