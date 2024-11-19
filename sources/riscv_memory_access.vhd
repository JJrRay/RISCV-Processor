library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;	   
use work.riscv_pkg.all;

entity riscv_memory_access is

  port (
  i_store_data  		: in  std_logic_vector(XLEN-1 downto 0);
  i_alu_result  		: in  std_logic_vector(XLEN-1 downto 0);	 
  i_rd_addr  			: in  std_logic_vector(REG_WIDTH -1 downto 0);  
  i_rw 		 			: in  std_logic;		
  i_wb 		 			: in  std_logic;
  i_we					: in  std_logic;
  i_rstn 	 			: in  std_logic;
  i_clk 	 			: in  std_logic; 
  o_store_data 			: out std_logic_vector(XLEN-1 downto 0);
  o_alu_result 			: out std_logic_vector(XLEN-1 downto 0);
  o_wb 		 			: out std_logic;
  o_we					: out std_logic;
  o_rw 					: out std_logic;		
  o_rd_addr  			: out std_logic_vector(REG_WIDTH -1 downto 0)  
  );
end entity riscv_memory_access;



architecture beh of riscv_memory_access is 	
	
begin 		   
	-- D-MEM is dealt outside of module contrary to drawing
	process(i_clk, i_rstn)
	begin
	  if i_rstn='0' then
		o_store_data <=	(others => '0');						
		o_we <=	'0';
		o_rw <= '0';
		o_alu_result <= (others => '0');
		o_wb <= '0';
		o_rd_addr <= "00000"; 	    
	  elsif rising_edge(i_clk) then	
		o_store_data <=	 i_store_data;						
		o_we		 <=	 i_we;
		o_rw		 <=  i_rw;
		o_alu_result  <= i_alu_result;
		o_wb 		  <= i_wb;
		o_rd_addr  	  <= i_rd_addr;
	  end if;
	end process;	

	
end architecture beh;
