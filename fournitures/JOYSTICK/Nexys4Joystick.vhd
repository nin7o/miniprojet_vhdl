library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;	

entity Nexys4Joystick is
  port (
    -- les 16 switchs
    swt : in std_logic_vector (15 downto 0);
    -- les 5 boutons noirs
    btnC, btnU, btnL, btnR, btnD : in std_logic;
    -- horloge
    mclk : in std_logic;
    -- les 16 leds
    led : out std_logic_vector (15 downto 0);
    -- les anodes pour sélectionner les afficheurs 7 segments à utiliser
    an : out std_logic_vector (7 downto 0);
    -- valeur affichée sur les 7 segments (point décimal compris, segment 7)
    ssg : out std_logic_vector (7 downto 0);
	 pmod_ss : out std_logic;
	 pmod_mosi : out std_logic;
	 pmod_miso : in std_logic;
	 pmod_sclk : out std_logic
  );
end Nexys4Joystick;

architecture synthesis of Nexys4Joystick is

	COMPONENT MasterJoystick
	PORT(
		rst : IN std_logic;
		clk : IN std_logic;
		en : IN std_logic;
		swt : IN std_logic_vector(1 downto 0);
		miso : IN std_logic;          
		ss : OUT std_logic;
		sclk : OUT std_logic;
		mosi : OUT std_logic;
		btn1 : OUT std_logic;
		btn2 : OUT std_logic;
		btnj : OUT std_logic;
		X_axis : OUT std_logic_vector(9 downto 0);
		Y_axis : OUT std_logic_vector(9 downto 0);
		busy : OUT std_logic
		);
	END COMPONENT;
	
		COMPONENT All7Segments
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		e0 : IN std_logic_vector(3 downto 0);
		e1 : IN std_logic_vector(3 downto 0);
		e2 : IN std_logic_vector(3 downto 0);
		e3 : IN std_logic_vector(3 downto 0);
		e4 : IN std_logic_vector(3 downto 0);
		e5 : IN std_logic_vector(3 downto 0);
		e6 : IN std_logic_vector(3 downto 0);
		e7 : IN std_logic_vector(3 downto 0);          
		an : OUT std_logic_vector(7 downto 0);
		ssg : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
	
		COMPONENT diviseurClk
		GENERIC(facteur : natural);
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;          
		nclk : OUT std_logic
		);
	END COMPONENT;
	
	signal X_10 : std_logic_vector(9 downto 0);
	signal Y_10 : std_logic_vector(9 downto 0);
	
	signal nclk : std_logic;

begin

  -- convention afficheur 7 segments 0 => allumé, 1 => éteint
  --ssg <= (others => '0');
  -- aucun afficheur sélectionné
  --an(7 downto 0) <= (others => '0');
  -- 16 leds éteintes
  led(15 downto 4) <= (others => '0');

  -- connexion du (des) composant(s) avec les ports de la carte
  
  	Inst_diviseurClk: diviseurClk 
	GENERIC MAP(200)
	PORT MAP(
		clk => mclk,
		reset => not btnC,
		nclk => nclk
	);
  
  	Inst_MasterJoystick: MasterJoystick PORT MAP(
		rst => not btnC,
		clk => nclk,
		en => swt(15),
		swt => swt(1 downto 0),
		miso => pmod_miso,
		ss => pmod_ss,
		sclk => pmod_sclk,
		mosi => pmod_mosi,
		btn1 => led(1),
		btn2 => led(2),
		btnj => led(3),
		X_axis => X_10,
		Y_axis => Y_10,
		busy => led(0)
	);
	
	Inst_All7Segments: All7Segments PORT MAP(
		clk => mclk,
		reset => not btnC,
		e0 => X_10(3 downto 0),
		e1 => X_10(7 downto 4),
		e2 => ("00"&X_10(9 downto 8)),
		e3 => "0000",
		e4 => Y_10(3 downto 0),
		e5 => Y_10(7 downto 4),
		e6 => ("00"&Y_10(9 downto 8)),
		e7 => "0000",
		an => an,
		ssg => ssg
	);
    
end synthesis;
