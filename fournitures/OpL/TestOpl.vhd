--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:24:31 11/20/2023
-- Design Name:   
-- Module Name:   /home/ngauthie2/Documents/2A/VHDL/miniprojet_vhdl/fournitures/OpL/TestOpl.vhd
-- Project Name:  Projet
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: MasterOpl
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY TestOpl IS
END TestOpl;
 
ARCHITECTURE behavior OF TestOpl IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT MasterOpl
    PORT(
         rst : IN  std_logic;
         clk : IN  std_logic;
         en : IN  std_logic;
         v1 : IN  std_logic_vector(7 downto 0);
         v2 : IN  std_logic_vector(7 downto 0);
         miso : IN  std_logic;
         ss : OUT  std_logic;
         sclk : OUT  std_logic;
         mosi : OUT  std_logic;
         val_nand : OUT  std_logic_vector(7 downto 0);
         val_nor : OUT  std_logic_vector(7 downto 0);
         val_xor : OUT  std_logic_vector(7 downto 0);
         busy : OUT  std_logic
        );
    END COMPONENT;
	 
	 COMPONENT SlaveOpl
		PORT(
			sclk : IN std_logic;
			mosi : IN std_logic;
			ss : IN std_logic;          
			miso : OUT std_logic
			);
		END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '0';
   signal clk : std_logic := '0';
   signal en : std_logic := '0';
   signal v1 : std_logic_vector(7 downto 0) := (others => '0');
   signal v2 : std_logic_vector(7 downto 0) := (others => '0');
   signal miso : std_logic := '0';

 	--Outputs
   signal ss : std_logic;
   signal sclk : std_logic;
   signal mosi : std_logic;
   signal val_nand : std_logic_vector(7 downto 0);
   signal val_nor : std_logic_vector(7 downto 0);
   signal val_xor : std_logic_vector(7 downto 0);
   signal busy : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
   constant sclk_period : time := 10 ns;
	
	-- Signaux de référence
	signal busy_ref : std_logic;
	signal nand_ref : std_logic_vector(7 downto 0);
	signal nor_ref : std_logic_vector(7 downto 0);
	signal xor_ref : std_logic_vector(7 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: MasterOpl PORT MAP (
          rst => rst,
          clk => clk,
          en => en,
          v1 => v1,
          v2 => v2,
          miso => miso,
          ss => ss,
          sclk => sclk,
          mosi => mosi,
          val_nand => val_nand,
          val_nor => val_nor,
          val_xor => val_xor,
          busy => busy
        );
		  
	Inst_SlaveOpl: SlaveOpl PORT MAP(
			sclk => sclk,
			mosi => mosi,
			miso => miso,
			ss => ss
	);

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
	
	v1 <= "UUUUUUUU" after 0 ps,
			"11010011" after 100000 ps;
	
	v2 <= "UUUUUUUU" after 0 ps,
			"10100100" after 100000 ps;
			
			
	-- signaux de référence
	
	busy_ref <= '0' after 0 ps,
					'1' after 105000 ps,
					'0' after 975000 ps,
					'1' after 985000 ps, 
					'0' after 1855000 ps;
					
	nand_ref <= "UUUUUUUU" after 0 ps,
					"00110011" after 495000 ps,
					"01111111" after 1375000 ps;
	
	nor_ref <= "UUUUUUUU" after 0 ps,
				  "11001100" after 735000 ps,
				  "00001000" after 1615000 ps;
	
	xor_ref <= "UUUUUUUU" after 0 ps,
				  "10100000" after 975000 ps,
				  "01110111" after 1855000 ps;
					

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      -- insert stimulus here 
		
		-- on down le reset
		rst <= '1';
		
		--on active le composant
		en <= '1';

      wait for 1755 ns;
		en <= '0';
		wait for 1000000 ns;
   end process;
	
	process(clk)
		begin
			if(falling_edge(clk)) then
				assert(val_nand = nand_ref) report "nand différent nand_ref"
				severity error;
				assert(val_nor = nor_ref) report "nor différent nor_ref"
				severity error;
				assert(val_xor = xor_ref) report "xor différent xor_ref"
				severity error;
				assert(busy = busy_ref) report "busy différent busy_ref"
				severity error;
			end if;
		end process;

END;
