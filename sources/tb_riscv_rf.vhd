library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_riscv_rf is
end entity tb_riscv_rf;

architecture testbench of tb_riscv_rf is

  -- Test inputs
  signal i_clk : std_logic := '0';
  signal i_rstn : std_logic := '1';
  signal i_we : std_logic := '0';
  signal i_addr_ra : std_logic_vector(4 downto 0) := "00000";
  signal i_addr_rb : std_logic_vector(4 downto 0) := "00000";
  signal i_addr_w : std_logic_vector(4 downto 0) := "00000";
  signal i_data_w : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";

  -- Output signals
  signal o_data_ra : std_logic_vector(31 downto 0);
  signal o_data_rb : std_logic_vector(31 downto 0);

  -- Clock generation process
  constant clock_period : time := 10 ns;

begin

  -- Clock generation process
  clk_process: process
  begin
    while now < 120 ns loop
      i_clk <= '0';
      wait for clock_period / 2;
      i_clk <= '1';
      wait for clock_period / 2;
    end loop;
    wait;
  end process;

  -- Instantiate the riscv_rf
  uut : entity work.riscv_rf
    port map (
      i_clk     => i_clk,
      i_rstn    => i_rstn,
      i_we      => i_we,
      i_addr_ra => i_addr_ra,
      o_data_ra => o_data_ra,
      i_addr_rb => i_addr_rb,
      o_data_rb => o_data_rb,
      i_addr_w  => i_addr_w,
      i_data_w  => i_data_w
    );

  -- Test stimulus generation process
  stimulus_process: process
  begin
    -- Reset the system
    i_rstn <= '0';
    wait for 20 ns;

    i_rstn <= '1';

    -- Test Case 1: Write 0x00000001 in register 0x01 and read its value
    i_we <= '1';
    i_addr_w <= "00001";  -- Write to address 0x01
    i_data_w <= "00000000000000000000000000000001"; -- Data = 0x1
    i_addr_ra <= "00001"; -- Read from address 0x01
    i_addr_rb <= "00010"; -- Read from address 0x02 (should be undefined)
    wait for 20 ns;

    -- Test Case 2: Check that "we" works properly
    i_we <= '0'; -- Disable write
    i_addr_w <= "00001";  -- Attempt to overwrite address 0x01
    i_data_w <= "00000000000000000000000000000000"; -- Data = 0x0 (should not be written)
    i_addr_ra <= "00001"; -- Read from address 0x01 (should still be 0x1)
    i_addr_rb <= "00010"; -- Read from address 0x02 (should be undefined)
    wait for 20 ns;

    -- Test Case 3: Write 0x00000008 to address 0x02
    i_we <= '1';
    i_addr_w <= "00010";  -- Write to address 0x02
    i_data_w <= "00000000000000000000000000001000"; -- Data = 0x8
    i_addr_ra <= "00001"; -- Read from address 0x01 (should be 0x1)
    i_addr_rb <= "00010"; -- Read from address 0x02 (should be 0x8)
    wait for 20 ns;

    -- Test Case 4: Write 0x00000004 to address 0x04 and read address 0x02
    i_we <= '1';
    i_addr_w <= "00100";  -- Write to address 0x04
    i_data_w <= "00000000000000000000000000000100"; -- Data = 0x4
    i_addr_ra <= "00010"; -- Read from address 0x02 (should be 0x8)
    i_addr_rb <= "00001"; -- Read from address 0x01 (should be 0x1)
    wait for 20 ns;

    -- Test Case 5: Read data from address 0x02
    i_we <= '0'; -- Disable write
    i_addr_w <= "00100";  -- Attempt to overwrite address 0x04
    i_data_w <= "00000000000001000000000000000000"; -- Data (should not be written)
    i_addr_ra <= "00010"; -- Read from address 0x02 (should be 0x8)
    i_addr_rb <= "00100"; -- Read from address 0x04 (should be 0x4)
    wait for 20 ns;

    wait;
  end process;

end architecture testbench;
