library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MasterOpl is
  port ( rst : in std_logic;
         clk : in std_logic;
         en : in std_logic;
         v1 : in std_logic_vector (7 downto 0); -- premier octet opérande
         v2 : in std_logic_vector(7 downto 0); -- second octet opérande
         miso : in std_logic;
         ss   : out std_logic;
         sclk : out std_logic;
         mosi : out std_logic;
         val_nand : out std_logic_vector (7 downto 0); -- résultat du nand, premier octet reçu
         val_nor : out std_logic_vector (7 downto 0); -- résultat du nor, second octet reçu
         val_xor : out std_logic_vector (7 downto 0); -- résultat du xor, troisième octet reçu
         busy : out std_logic);
end MasterOpl;

architecture behavior of MasterOpl is

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
		cpt_bytes := 3;

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
					cpt_clk := 20;

					-- on initialise le compteur d'octets envoyés
					cpt_bytes := 3;

					-- on passe à l'état d'attente
					etat <= attente;

				else
					--aucun ordre, on ne fait rien
					null;
				end if;

			when attente =>

					-- une attente de 20 cycles d'horloge clk est nécessaire
					-- pour que le slave soit prêt à échanger,
					-- et de 5 cycle entre chaque octet échangé

					if(cpt_clk > 0) then
						-- l'attente n'est pas terminée
						cpt_clk := cpt_clk - 1;

					else
						-- l'attente est terminée

						-- on change d'octet à envoyer
						cpt_bytes := cpt_bytes - 1;

						-- on passe le bon entier en entrée du composant er_1octet

						case cpt_bytes is
							when 2 =>
								-- on envoie le premier octet opérande 1
								din_er_1octet <= v1;
							when 1 =>
								-- on envoie le premier octet opérande 2
								din_er_1octet <= v2;
							when 0 =>
								-- on n'envoie rien
								din_er_1octet <= (others => 'U');
							when others => null;
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
							when 2 =>
								-- on récupère le premier octet reçu
								val_nand <= dout_er_1octet;
							when 1 =>
								-- on récupère le second octet reçu
								val_nor <= dout_er_1octet;
							when 0 =>
								-- on récupère le troisième octet reçu
								val_xor <= dout_er_1octet;
							when others => null;
						end case;
					
						-- on prépare la suite
						if(cpt_bytes > 0) then
							-- il reste des octets à échanger
							-- on passe l'attente à 5 cycles d'horloge
							cpt_clk := 5;
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

end behavior;