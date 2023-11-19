--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:51:48 11/16/2023
-- Design Name:   
-- Module Name:   /home/mricard/Xilink/mini_projet/testMasterOpl.vhd
-- Project Name:  mini_projet
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
 
ENTITY testMasterOpl IS
END testMasterOpl;
 
ARCHITECTURE behavior OF testMasterOpl IS 
 
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
 
   -- signaux attendu pour la comparaison
   signal ref_nand : std_logic_vector(7 downto 0);
   signal ref_nor: std_logic_vector(7 downto 0);
   signal ref_xor: std_logic_vector(7 downto 0);

 
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
 		
	v1   <= "UUUUUUUU" after 0 ps,
			  "01100001" after  200000 ps,
           "10100101" after 1080000 ps,
           "11111111" after 1960000 ps,
			  "10100101" after 2840000 ps,
			  "10010110" after 3720000 ps;

				  
	v2   <= "UUUUUUUU" after 0 ps,
	        "01000100" after  200000 ps,
           "11010010" after 1080000 ps,
           "00000000" after 1960000 ps,
			  "10010100" after 2840000 ps,
			  "00111011" after 3720000 ps;

   -- Idealément la simulation fait aux alentour de 6us
	ref_nand <= "00110011" after 595000 ps,
					"10111111" after 1475000 ps,
 					"01111111" after 2355000 ps,
					"11111111" after 3235000 ps,
					"01111011" after 4115000 ps,
					"11101101" after 4995000 ps;

	ref_nor  <= "11001100" after 835000 ps,
					"10011010" after 1715000 ps,
 					"00001000" after 2595000 ps,
					"00000000" after 3475000 ps,
					"01001010" after 4355000 ps,
					"01000000" after 5235000 ps;

	ref_xor  <= "10100000" after 1075000 ps,
				 	"00100101" after 1955000 ps,
 					"01110111" after 2835000 ps,
					"11111111" after 3715000 ps,
					"00110001" after 4595000 ps,
					"10101101" after 5475000 ps;
					
					
   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		
		
      wait for clk_period*10;

		rst <= '1';
		en <= '1';
		-- insert stimulus here 

      wait;
   end process;

	process(clk)
	-- permet de vérifier que les valeurs de nand, nor et xor sont les bonnes
	begin
    if(falling_edge(clk)) then
      assert(val_nand = ref_nand) report "nand faux"
      severity error;
      assert(val_nor = ref_nor) report "nor faux"
      severity error;
      assert(val_xor = ref_xor) report "xor faux"
      severity error;
    end if;
	end process;
END;
