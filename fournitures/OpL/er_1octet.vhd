library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity er_1octet is
  port ( rst : in std_logic ;
         clk : in std_logic ;
         en : in std_logic ;
         din : in std_logic_vector (7 downto 0) ;
         miso : in std_logic ;
         sclk : out std_logic ;
         mosi : out std_logic ;
         dout : out std_logic_vector (7 downto 0) ;
         busy : out std_logic);
end er_1octet;

architecture behavioral_3 of er_1octet is

	type t_etat is (idle, bit_emis, bit_recu);
	signal etat : t_etat;

begin

	process(clk, rst)
    variable cpt : natural;
    variable registre : std_logic_vector(7 downto 0);

  begin
  
  
		if(rst = '0') then

			-- réinitialisation des variables du process
			-- et des signaux calculés par le process
			
			--reset de la clokc
			sclk <= '1';

			-- les compteurs
			cpt:= 7;

			-- le registre d'envoi
			registre := (others => 'U');

			-- l'indicateur de fonctionnement/occupation
			busy <= '0';

			-- l'état
			etat <= idle;
			
		elsif(rising_edge(clk)) then

			-- front montant de l'horloge
			case etat is
			
				when idle =>
					-- état d'attente d'un ordre d'envoi

					if(en = '1') then
						-- un ordre est détecté
						-- on signale qu'on est occupé
						busy <= '1';
						
						--on prends la valeur en entrée
						registre := din;
						
						--on initialise le compteur
						cpt := 7;
						
						--envoi de l'octet de poids fort
						mosi <= registre(cpt);
						
						--on update la clock
						sclk <= '0';
						
						-- on change d'etat
						etat <= bit_emis;
				
					else
						-- aucun ordre : on ne fait rien
						null;
					end if;
				
				when bit_emis =>
				
					-- on update la clock
					sclk <= '1';
					
					--on reçoit un octet
					registre(cpt) := miso;
					
					-- on change d'etat
					etat <= bit_recu;
						
				when bit_recu =>
		
					if(cpt > 0) then
					
						-- on update la clock
						sclk <= '0';
						
						-- on update le compteur 
						cpt := cpt - 1;
						
						--on envoi un octet
						mosi <= registre(cpt);
					
						-- on change d'etat
						etat <= bit_emis;
					else
					
						--on réinitialise l'etat busy
						busy <= '0';
						
						--dout
						dout <= registre;
					
						-- on change d'etat
						etat <= idle;
					end if;
					
			end case;
		end if;
	end process;

end behavioral_3;
