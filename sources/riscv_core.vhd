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

-- Process for decoding signals
process (opcode, funct3, funct7)
begin
    -- Default values
    branch  <= '0';
    jump    <= '0';
    rw      <= '0';
    wb      <= '0';
    arith   <= '0';
    sign    <= '0';
    imm     <= (others => '0'); // imm handling is still generic must customise to documentation
    src_imm <= '0';
    alu_op  <= ALUOP_OTHER;  -- Default ALU operation to "other" for undefined cases

    -- Decoding logic based on opcode
    case opcode is
        -- R-type instructions (Arithmetic operations)
        when "0110011" =>  -- R-type opcode (add, sub, and etc.)
            arith   <= '1';
            rw      <= '1'; -- write to register
            wb      <= '1'; -- write-back enabled
            src_imm <= '0'; -- no immediate, uses rs1 and rs2 for operands

            case funct3 is
                when "000" => -- ADD/SUB
                    case funct7 is
                        when "0000000" =>  -- ADD
                            alu_op <= ALUOP_ADD;
                        when "0100000" =>  -- SUB
                            alu_op <= ALUOP_ADD;  -- ALU subtraction handled with addition
                        when others => 
                            alu_op <= ALUOP_OTHER;  -- Unknown funct7
                    end case;
                when "001" => -- SLL
                    alu_op <= ALUOP_SL;
                when "010" => -- SLT
                    alu_op <= ALUOP_SLT;
                when "011" => -- SLTU
                    alu_op <= ALUOP_SLT;  -- For unsigned, the logic might change depending on your implementation
                when "100" => -- XOR
                    alu_op <= ALUOP_XOR;
                when "101" => -- SRL/SRA
                    case funct7 is
                        when "0000000" =>  -- SRL
                            alu_op <= ALUOP_SR;
                        when "0100000" =>  -- SRA
                            alu_op <= ALUOP_SR;  -- Adjust according to how you handle SRA
                        when others => 
                            alu_op <= ALUOP_OTHER;
                    end case;
                when "110" => -- OR
                    alu_op <= ALUOP_OR;
                when "111" => -- AND
                    alu_op <= ALUOP_AND;
                when others => 
                    alu_op <= ALUOP_OTHER;
            end case;
            
        -- I-type instructions (Immediate Arithmetic or Load)
        when "0000011" =>  -- Load (opcode for I-type load instructions)
            rw      <= '1';  -- write to register
            wb      <= '1';  -- write-back enabled
            imm     <= std_logic_vector(to_unsigned(signed(funct3), 20));  -- Example: immediate decoding
            alu_op  <= ALUOP_ADD; -- ALU operation for load (typically address calculation)
        
        when "0010011" =>  -- I-type Arithmetic
            arith   <= '1';  -- arithmetic operation
            rw      <= '1';  -- write to register
            wb      <= '1';  -- write-back enabled
            imm     <= std_logic_vector(to_unsigned(signed(funct3), 20)); -- Example immediate decoding
            alu_op  <= ALUOP_ADD; -- ALU operation for arithmetic (ADD, SUB, etc.)
        
        -- Branch instructions
        when "1100011" =>  -- Branch instructions
            branch  <= '1';  -- enable branching
            alu_op  <= ALUOP_ADD;  -- comparison typically handled with subtraction (e.g., BEQ, BNE)
        
        -- Jump instructions
        when "1101111" =>  -- Jump (JAL)
            jump    <= '1';
            rw      <= '1';  -- write to register (return address)
            wb      <= '1';  -- write-back enabled
            alu_op  <= ALUOP_ADD; -- ALU operation for jump (address calculation)
        
        -- Default case for unknown opcodes
        when others => 
            null;  -- undefined behavior for unknown opcodes
    end case;
    
end process;


    -- ID/EX Pipeline Register: Store instrcution decoded in the ID stage



end architecture beh;
