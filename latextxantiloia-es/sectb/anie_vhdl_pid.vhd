-- Unai Martinez Corral
-- umartinez012@ikasle.ehu.es
----------------------------------------------------------------------------------
library ieee;
 use ieee.std_logic_1164.ALL;
 use ieee.numeric_std.all;

-- PID kontroladorearen entitatea
entity anie_pid is
 generic (
  i_wl: natural:=12; -- Kontroladorearen sarreren hitz luzera
  o_wl: natural:=22; -- Kontroladorearen irteeraren hitz luzera
  k_wl: natural:=8; -- Kontroladoreen koefizienteen (Kp, Ki, Kd) hitz luzeera
  irem_wl: natural:=1; -- Adar integrazailearen "memoria"ren luzera gehitua

  pbp: natural:=2; -- Kp koefizientearen koma bitarraren kokapena
  ibp: natural:=17; -- Ki koefizientearen koma bitarraren kokapena
  dbp: natural:=2; -- Kd koefizientearen koma bitarraren kokapena
  minbp: natural:=2 -- Adar baturan koma bitarrak lerrokatzeko parametroa
 );
 port (
  clk,ce: in std_logic; -- Erloju eta erlojuaren gaitze seinaleak: T(m_ce)=Ts
  srst: in  std_logic; -- Reset sinkrono orokorra
  i_ref: in signed(i_wl-1 downto 0); -- Erreferentzia seinalea: (r)
  i_feed: in signed(i_wl-1 downto 0); -- Berrelikadura seinalea: (y)
  kp: in signed(k_wl-1 downto 0); -- Koefiziente proportzionala: Kp=P
  ki: in signed(k_wl-1 downto 0); -- Koefiziente integratzailea: Ki=I*Ts/2
  kd: in signed(k_wl-1 downto 0); -- Koefiziente deribatzailea: Kd=D/Ts
  o: out signed(o_wl-1 downto 0) -- Kontrol seinalea (u)
 );
end anie_pid;

-- PID kontroladorearen arkitektura adar integratzailean Tustin bihurketa eta adar deribatzailean Backward difference bihurketa erabilita.
architecture pid of anie_pid is

-- Batutzaileen irteerak saturatzeko blokea
component anie_sat
 generic (
  iref_wl: natural:=2; -- Saturatu nahi den seinalearen hitz luzera
  osat_wl: natural:=2 ); -- Saturatutako seinalearen hitz luzera
 port (
  iref: in signed(iref_wl-1 downto 0); -- Saturatu nahi den seinalea
  osat: out signed(osat_wl-1 downto 0) ); -- Saturatutako seinalea
end component;

 constant aswl: natural:= i_wl+1;
 constant mwl: natural:= i_wl+k_wl;
 constant oswl: natural:= mwl+irem_wl+1;

 signal ref: signed(i_wl-1 downto 0); -- r(k)
 signal feed: signed(i_wl-1 downto 0); -- y(k)
	
 signal dif_act: signed(aswl-1 downto 0); -- e(k)
 signal dif_pre: signed(aswl-1 downto 0); -- e(k-1)

 signal der_dif: signed(aswl downto 0); -- e(k)-e(k-1)
 signal int_sum: signed(aswl downto 0); -- e(k)+e(k-1)

 signal pro_out: signed(mwl-1 downto 0); -- Kp*e(k)
 signal int_mult: signed(mwl downto 0); -- Ki*(e(k)+e(k-1))
 signal der_out: signed(mwl downto 0); -- Kd*(e(k)-e(k-1))
  
 signal int_out: signed(oswl-1 downto 0); -- uisat(k)
 signal int_rem: signed(oswl-1 downto 0); -- uisat(k-1)
 signal out_sat: signed(oswl-1 downto 0); -- usat(k)
  
 signal int_tosat: signed(oswl downto 0); -- ui(k)
 signal out_tosat: signed(oswl downto 0); -- u(k)

begin

-- r(k) - y(k)
dif_act <= resize(ref,aswl) - resize(feed,aswl);

-- e(k)+e(k-1)
int_sum <= resize(dif_act,aswl+1) + resize(dif_pre,aswl+1);
-- e(k)-e(k-1)
der_dif <= resize(dif_act,aswl+1) - resize(dif_pre,aswl+1);

-- up(k)=Kp*e(k)
pro_out <= shift_right(resize(kp*dif_act,mwl),pbp-minbp);
-- Ki*(e(k)+e(k-1))
int_mult <= shift_right(resize(ki*int_sum,mwl+1),ibp-minbp);
-- ud(k)=Kd*(e(k)-e(k-1))
der_out <= shift_right(resize(kd*der_dif,mwl+1),dbp-minbp);

-- ui(k)=Ki*(e(k)+e(k-1))+ui(k-1)
int_tosat <= resize(int_mult,oswl+1) + resize(int_rem,oswl+1);

-- u(k)=up(k)+ud(k)+uisat(k)
out_tosat <= resize(pro_out,oswl+1) +
             resize(int_out,oswl+1) +
             resize(der_out,oswl+1);

-- Kontrol seinalea moztea
o <= out_sat(oswl-1 downto oswl-o_wl);

-- ui(k) -> uisat(k)
INTSAT: anie_sat
  generic map (oswl+1,oswl)
  port map (int_tosat,int_out);

-- u(k) -> usat(k)
OUTSAT: anie_sat
  generic map (oswl+1,oswl)
  port map (out_tosat,out_sat);

-- Fs 
process(clk,ce)
begin
if rising_edge(clk) then
 if srst='1' then
  ref <= (others => '0');
  feed <= (others => '0');
  dif_pre <= (others => '0');
  int_rem <= (others => '0');
 elsif ce='1' then
  ref <= i_ref;
  feed <= i_feed;
  dif_pre <= dif_act;
  int_rem <= int_out;
 end if;
end if;
end process;

end pid;
