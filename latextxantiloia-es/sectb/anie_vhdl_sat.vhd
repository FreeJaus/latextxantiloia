-- Unai Martinez Corral
-- umartinez012@ikasle.ehu.es
------------------------------------------------------------------
library ieee;
 use ieee.std_logic_1164.ALL;
 use ieee.numeric_std.all;

entity anie_sat is
 generic (
  iref_wl: natural:=2; -- Saturatu nahi den seinalearen hitz luzera
  osat_wl: natural:=2 -- Saturatutako seinalearen hitz luzera
 );
 port (
  iref: in signed(iref_wl-1 downto 0); -- Saturatu nahi den seinalea
  osat: out signed(osat_wl-1 downto 0) -- Saturatutako seinalea
 );
end anie_sat;

architecture sat of anie_sat is

  signal max,min: signed(osat_wl-1 downto 0); -- Saturatutako seinalearen limiteak
  
begin

-- Saturazio maximoaren balioa ezartzea
max(osat_wl-1) <= '0';
max(osat_wl-2 downto 0) <= (others => '1');

-- Saturazio minimoaren balioa ezartzea
min(osat_wl-1) <= '1';
min(osat_wl-2 downto 0) <= (0 => '1', others => '0');

osat <=
  max when (iref>resize(max,iref_wl))
  else
  min when (iref<resize(min,iref_wl))
  else
  resize(iref,osat_wl);

end sat;
