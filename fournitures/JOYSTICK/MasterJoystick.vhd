----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:23:43 11/22/2023 
-- Design Name: 
-- Module Name:    MasterJoystick - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MasterJoystick is
	port ( rst : in std_logic;
         clk : in std_logic;
         en : in std_logic;
         swt : in std_logic_vector (1 downto 0);
         miso : in std_logic;
         ss   : out std_logic;
         sclk : out std_logic;
         mosi : out std_logic;
         btn1 : out std_logic;
			btn2 : out std_logic;
			btnj : out std_logic;
			X_axis : out std_logic_vector (9 downto 0);
         Y_axis : out std_logic_vector (9 downto 0);
			busy : out std_logic);
end MasterJoystick;

architecture Behavioral of MasterJoystick is

	-- Ajout du composant er_1octet
	COMPONENT er_1octet
	PORT(
		rst : IN std_logic;
		clk : IN std_logic;
		en : IN std_logic;
		din : IN std_logic_vector(7 downto 0);
		miso : IN std_logic;          
		sclk : OUT std_logic;
		mosi : OUT std_logic;
		dout : OUT std_logic_vector(7 downto 0);
		busy : OUT std_logic
		);
	END COMPONENT;
	-- ce composant est utilisé pour envoyer et recevoir un octet
	
	type t_etat is (idle, attente, echange);
	signal etat : t_etat;
	
	-- input du composant er_1octet
	signal en_er_1octet : std_logic;
	signal din_er_1octet : std_logic_vector(7 downto 0);

	-- output du composant er_1octet
	signal busy_er_1octet : std_logic;
	signal dout_er_1octet : std_logic_vector(7 downto 0);

begin

	-- Instanciation du composant er_1octet
	Inst_er_1octet : er_1octet PORT MAP(
		-- signaux en sortie directe
		sclk => sclk,
		miso => miso,
		mosi => mosi,
		-- signaux en entrée directe
		clk => clk,
		rst => rst,
		-- signaux modifiés par le composant
		en => en_er_1octet,
		din => din_er_1octet,
		dout => dout_er_1octet,
		busy => busy_er_1octet
		);
		
process(clk, rst)
	variable cpt_clk : natural;
	variable cpt_bytes : natural;
	
begin

	if (rst = '0') then

		-- réinitialisaation des variables du processus
		-- et des signaux modifiés par le processus

		-- réinitialisation du compteur
		cpt_clk := 20;

		-- réinitialisation du signal busy
		busy <= '0';

		-- réinitialisation du signal ss
		ss <= '1';

		-- réinitialisation de l'octet courant 
		cpt_bytes := 5;
		
		-- réinitialisation des axes
		X_axis(9 downto 0) <= (others => '0');
		Y_axis(9 downto 0) <= (others => '0');

		-- réinitialisation de l'etat
		etat <= idle;

	elsif(rising_edge(clk)) then

		-- front montant de l'horloge
		case etat is 

			-- attente d'un ordre
			when idle =>

				if(en = '1') then
					-- un ordre est détecté
					-- on signale qu'on est occupé
					busy <= '1';

					-- initialisation du signal ss pour la transmission spi
					ss <= '0';

					-- on initialise le compteur de clk
					cpt_clk := 30;

					-- on initialise le compteur d'octets envoyés
					cpt_bytes := 5;

					-- on passe à l'état d'attente
					etat <= attente;

				else
					--aucun ordre, on ne fait rien
					null;
				end if;

			when attente =>

					-- une attente de 15us cycles d'horloge clk est nécessaire
					-- pour que le slave soit prêt à échanger,
					-- et de 10us cycle entre chaque octet échangé

					if(cpt_clk > 0) then
						-- l'attente n'est pas terminée
						cpt_clk := cpt_clk - 1;

					else
						-- l'attente est terminée

						-- on change d'octet à envoyer
						cpt_bytes := cpt_bytes - 1;

						-- on passe le bon entier en entrée du composant er_1octet
						
						-- seul le premier envoi est utile pour l'activation des leds joystick
						
						case cpt_bytes is
							when 4 =>
								-- on envoie le premier octet des leds
								din_er_1octet <= ("100000"&swt(1 downto 0));
							when others =>
								-- on n'envoie rien
								din_er_1octet <= (others => 'U');
						end case;	

						-- on lance l'échange d'un octet en activant le sous composant
						en_er_1octet <= '1';
						etat <= echange;
					end if;

			when echange =>
					-- on echange un bit à la fois via le composant er_1octet

					-- on rabaissee l'ordre passé au sous composant
					en_er_1octet <= '0';
					din_er_1octet <= (others => 'U');

					if (en_er_1octet = '0' and busy_er_1octet = '0') then
						-- échange d'un octet terminé
						-- on récupère l'octet reçu et on le stocke dans le bon signal

						case cpt_bytes is
							when 4 =>
								-- on récupère le premier octet reçu
								X_axis(7 downto 0) <= dout_er_1octet;
							when 3 =>
								-- on récupère le second octet reçu
								X_axis(9 downto 8) <= dout_er_1octet(1 downto 0);
							when 2 =>
								-- on récupère le troisième octet reçu
								Y_axis(7 downto 0) <= dout_er_1octet;
							when 1 =>
								-- on récupère le troisième octet reçu
								Y_axis(9 downto 8) <= dout_er_1octet(1 downto 0);
							when 0 =>
								-- on récupère le troisième octet reçu
								btn1 <= dout_er_1octet(1);
								btn2 <= dout_er_1octet(2);
								btnj <= dout_er_1octet(0);
							when others => null;
						end case;
					
						-- on prépare la suite
						if(cpt_bytes > 0) then
							-- il reste des octets à échanger
							-- on passe l'attente à 5 cycles d'horloge
							cpt_clk := 20;
							etat <= attente;
						else
							-- tous les octets ont été envoyés
							-- on signale qu'on n'est plus occupé
							busy <= '0';

							-- on reset le slave
							ss <= '1';

							-- on revient sur l'etat idle
							etat <= idle;
						end if;
					end if;
									
			when others =>
				-- ne devrait jamais arriver
				etat <= idle;
		
		end case;
	end if;
end process;

end Behavioral;

