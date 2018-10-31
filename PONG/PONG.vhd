library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--library UNISIM;
--use UNISIM.VComponents.all;

entity PONG is
	Port(
			VGA_R:out STD_LOGIC_VECTOR (3 downto 0);
			VGA_G:out STD_LOGIC_VECTOR (3 downto 0);
			VGA_B:out STD_LOGIC_VECTOR (3 downto 0);
			VGA_HSYNC:out STD_LOGIC; 
			VGA_VSYNC:out STD_LOGIC;
			WS:in STD_LOGIC;
			PN:in STD_LOGIC;
			PD:in STD_LOGIC;
			ZA:in STD_LOGIC;
			CLK_50MHZ:in STD_LOGIC;
			RESET:in STD_LOGIC);
end PONG;

architecture Behavioral of PONG is
type stan is (OCZEKIWANIE,WALKA,SERWIS,GRA,PUNKTY,KONIEC);
type kto is (LEWY,NIKT,PRAWY);
subtype warunek is integer range 0 to 2;
subtype ktorypoziom is integer range 1 to 12;
subtype ktorypion is integer range 1 to 16;
signal zdobywca: kto:=NIKT;
signal obecny, nastepny: stan:=OCZEKIWANIE;
signal synchronizacja, poprzedni_synchro: STD_LOGIC:='0';
signal l1,l2,p1,p2: STD_LOGIC_VECTOR(6 downto 0):= (others=>'0');
signal punktylewy, punktyprawy: unsigned(7 downto 0):= (others=>'0');
signal licznikpoziom: integer := 0;
signal licznikpion: integer := 0;
signal leway: integer:=266;
signal praway: integer:=266;
signal pilkax: integer:=320;
signal pilkay: integer:=266; 
signal prpilkix: integer:=5;
signal prpilkiy: integer:=1;
signal clk_25: STD_LOGIC;
signal czerwony,zielony,niebieski: STD_LOGIC_VECTOR(3 downto 0):=x"0";
signal wlaczony: STD_LOGIC:='1';

function  podziel  (a : unsigned; b : unsigned) return unsigned is
	variable a1 : unsigned(a'length-1 downto 0):=a;
	variable b1 : unsigned(b'length-1 downto 0):=b;
	variable p1 : unsigned(b'length downto 0):= (others => '0');
	variable i : integer:=0;
begin
	for i in 0 to b'length-1 loop
		p1(b'length-1 downto 1) := p1(b'length-2 downto 0);
		p1(0) := a1(a'length-1);
		a1(a'length-1 downto 1) := a1(a'length-2 downto 0);
		p1 := p1-b1;
		if(p1(b'length-1) ='1') then
			a1(0) :='0';
			p1 := p1+b1;
		else
			a1(0) :='1';
		end if;
	end loop;
	return a1;
end podziel;

function ktorei(liczpi, liczpo: in integer) return integer is
begin
	case liczpo is
		when 0 =>
			case liczpi is
				when 5 to 15 =>
					return 3;
				when 21 to 31 =>
					return 4;
				when others =>
					return 7;
			end case;
		when 20 =>
			case liczpi is
				when 5 to 15 =>
					return 5;
				when 21 to 31 =>
					return 6;
				when others =>
					return 7;
			end case;
		when 1 =>
			case liczpi is
				when 4 to 16 =>
					return 3;
				when 20 to 32 =>
					return 4;
				when others =>
					return 7;
			end case;
		when 19 =>
			case liczpi is
				when 4 to 16 =>
					return 5;
				when 20 to 32 =>
					return 6;
				when others =>
					return 7;
			end case;
		when 2 =>
			case liczpi is
				when 3 to 17 =>
					return 3;
				when 19 to 33 =>
					return 4;
				when others =>
					return 7;
			end case;
		when 18 =>
			case liczpi is
				when 3 to 17 =>
					return 5;
				when 19 to 33 =>
					return 6;
				when others =>
					return 7;
			end case;
		when 3 =>
			case liczpi is
				when 4 to 16 =>
					return 3;
				when 20 to 32 =>
					return 4;
				when 2 =>
					return 0;
				when 18 =>
					return 1;
				when 34 =>
					return 2;
				when others =>
					return 7;
			end case;
		when 17 =>
			case liczpi is
				when 4 to 16 =>
					return 5;
				when 20 to 32 =>
					return 6;
				when 2 =>
					return 0;
				when 18 =>
					return 1;
				when 34 =>
					return 2;
				when others =>
					return 7;
			end case;
		when 4 =>
			case liczpi is
				when 5 to 15 =>
					return 3;
				when 21 to 31 =>
					return 4;
				when 1|2|3 =>
					return 0;
				when 17|18|19 =>
					return 1;
				when 33|34|35 =>
					return 2;
				when others =>
					return 7;
			end case;
		when 16 =>
			case liczpi is
				when 5 to 15 =>
					return 5;
				when 21 to 31 =>
					return 6;
				when 1|2|3 =>
					return 0;
				when 17|18|19 =>
					return 1;
				when 33|34|35 =>
					return 2;
				when others =>
					return 7;
			end case;
		when 5 to 15 =>
			case liczpi is
				when 0|1|2|3|4 =>
					return 0;
				when 16 to 20 =>
					return 1;
				when 32 to 36 =>
					return 2;
				when others =>
					return 7;
			end case;
		when others =>
			return 7;
	end case;
end ktorei;

function segmenty(licznikpi, licznikpo: in integer; l1,l2,p1,p2: in STD_LOGIC_VECTOR(6 downto 0)) return warunek is
	variable i: integer :=0;
begin
	if licznikpo>377 and licznikpo<399 then
		i:=ktorei(licznikpi-42,licznikpo-378);
			if i<3 then
				if l1(i)='1' then
					return 2;
				else
					return 1;
				end if;
			elsif i<7 then
				if l1(i)='1' then
					return 2;
				else
					return 1;
				end if;
			else
				return 0;
			end if;
	elsif licznikpo>408 and licznikpo<430 then
		i:=ktorei(licznikpi-42,licznikpo-409);
			if i<3 then
				if l2(i)='1' then
					return 2;
				else
					return 1;
				end if;
			elsif i<7 then
				if l2(i)='1' then
					return 2;
				else
					return 1;
				end if;
			else
				return 0;
			end if;
	elsif licznikpo>499 and licznikpo<521 then
		i:=ktorei(licznikpi-42,licznikpo-500);
			if i<3 then
				if p1(i)='1' then
					return 2;
				else
					return 1;
				end if;
			elsif i<7 then
				if p1(i)='1' then
					return 2;
				else
					return 1;
				end if;
			else
				return 0;
			end if;
	elsif licznikpo>530 and licznikpo<552 then
		i:=ktorei(licznikpi-42,licznikpo-531);
			if i<3 then
				if p2(i)='1' then
					return 2;
				else
					return 1;
				end if;
			elsif i<7 then
				if p2(i)='1' then
					return 2;
				else
					return 1;
				end if;
			else
				return 0;
			end if;
	else
		return 0;
	end if;
end segmenty;

function lewacyfra(pkty: in unsigned) return STD_LOGIC_VECTOR is
	variable cyfra: unsigned(7 downto 0);
	variable dziesiec: unsigned(7 downto 0):="00001010";
	variable pty: integer range 0 to 9;
	variable zwrot: STD_LOGIC_VECTOR(6 downto 0);
begin
	cyfra:=podziel(pkty, dziesiec);
	case cyfra is
		when x"00" =>
			zwrot:=(1=>'0', others=>'1');
		when x"01" =>
			zwrot:=(6 downto 5=>'1', others=>'0');
		when x"02" =>
			zwrot:=(3=>'0', 6=>'0', others=>'1');
		when x"03" =>
			zwrot:=(4 downto 3=>'0', others=>'1');
		when x"04" =>
			zwrot:=(others=>'0');
		when x"05" =>
			zwrot:=(5 downto 4=>'0', others=>'1');
		when x"06" =>
			zwrot:=(5=>'0', others=>'1');
		when x"07" =>
			zwrot:=(0=>'1', 6 downto 5=>'1', others=>'0');
		when x"08" =>
			zwrot:=(others=>'1');
		when x"09" =>
			zwrot:=(4=>'0', others=>'1');
		when others =>
			zwrot:=(others=>'0');
	end case;
	return zwrot;
end lewacyfra;

function prawacyfra(pkty: in unsigned) return STD_LOGIC_VECTOR is
	variable cyfra: unsigned(7 downto 0);
	variable dziesiec: unsigned(7 downto 0):="00001010";
	variable zwrot: STD_LOGIC_VECTOR(6 downto 0);
begin
	cyfra:=pkty-TO_UNSIGNED(TO_INTEGER(podziel(pkty, dziesiec))*10,8);
	case cyfra is
		when x"00" =>
			zwrot:=(1=>'0', others=>'1');
		when x"01" =>
			zwrot:=(6 downto 5=>'1', others=>'0');
		when x"02" =>
			zwrot:=(3=>'0', 6=>'0', others=>'1');
		when x"03" =>
			zwrot:=(4 downto 3=>'0', others=>'1');
		when x"04" =>
			zwrot:=(0=>'0', 2=>'0', 4=>'0', others=>'1');
		when x"05" =>
			zwrot:=(5 downto 4=>'0', others=>'1');
		when x"06" =>
			zwrot:=(5=>'0', others=>'1');
		when x"07" =>
			zwrot:=(0=>'1', 6 downto 5=>'1', others=>'0');
		when x"08" =>
			zwrot:=(others=>'1');
		when x"09" =>
			zwrot:=(4=>'0', others=>'1');
		when others =>
			zwrot:=(others=>'0');
	end case;
	return zwrot;
end prawacyfra;

begin
	Inst_DCM: entity work.DCM
		PORT MAP(
			CLKIN_IN => CLK_50MHZ,
			RST_IN => '0',
			CLKDV_OUT => clk_25,
			CLKIN_IBUFG_OUT => open,
			CLK0_OUT => open,
			LOCKED_OUT => open
		);

	SynchPion: process(clk_25)
	begin
		if rising_edge(clk_25) then
			if licznikpion<2 then
					VGA_VSYNC<='0';
			elsif licznikpion<31 then
					VGA_VSYNC<='1';
			elsif licznikpion<511 then
					VGA_VSYNC<='1';
			elsif licznikpion<521 then
					VGA_VSYNC<='1';					
			end if;
		end if;
	end process SynchPion;

	SynchPoziom: process(clk_25)
	begin
		if rising_edge(clk_25) then
			if licznikpoziom<96 then
				VGA_HSYNC <= '0';
				licznikpoziom <= (licznikpoziom+1);
			elsif licznikpoziom>95 and licznikpoziom<144 then
				VGA_HSYNC <= '1';
				VGA_R<=x"0";
				VGA_G<=x"0";
				VGA_B<=x"0";
				licznikpoziom <= (licznikpoziom+1);
			elsif licznikpoziom>143 and licznikpoziom<784 then
				VGA_HSYNC <= '1';
				if (licznikpoziom<569 and licznikpoziom>360) and (licznikpion<86) then
					if (licznikpoziom<565 and licznikpoziom>364) and (licznikpion<82 and licznikpion>38) then
						VGA_R<=czerwony;
						VGA_G<=zielony;
						VGA_B<=niebieski;
					else
						VGA_R<=x"F";
						VGA_G<=x"F";
						VGA_B<=x"8";
					end if;
				elsif (licznikpion<502 and licznikpion>91)then
					if (licznikpoziom<148+pilkax and licznikpoziom>140+pilkax and licznikpion>27+pilkay and licznikpion<35+pilkay) or
						(licznikpion<97) or
						(licznikpion>496) or
						(licznikpion>96 and licznikpion<497 and licznikpoziom=464) then
							VGA_R<=x"F";
							VGA_G<=x"F";
							VGA_B<=x"F";
					elsif (licznikpoziom<154 and licznikpion>leway-9 and licznikpion<71+leway) or 
						(licznikpoziom>773 and licznikpion>praway-9 and licznikpion<71+praway) then
						VGA_R<=x"F";
						VGA_G<=x"0";
						VGA_B<=x"0";
					else
						VGA_R<=x"0";
						VGA_G<=x"4";
						VGA_B<=x"0";
					end if;
				else
					VGA_R<=x"0";
					VGA_G<=x"0";
					VGA_B<=x"B";
				end if;
				licznikpoziom <= (licznikpoziom+1);
			elsif licznikpoziom>783 and licznikpoziom<800 then
				VGA_HSYNC <= '1';
				VGA_R<=x"0";
				VGA_G<=x"0";
				VGA_B<=x"0";
				if licznikpoziom<799 then
					licznikpoziom <= (licznikpoziom+1);
				else
					licznikpoziom <= 0;
					if licznikpion<520 then
						licznikpion <= (licznikpion+1);
					else
						licznikpion<=0;
					end if;
				end if;
			end if;
		end if;
	end process SynchPoziom;
	
	Maszyna:process(clk_25)
	begin
		if rising_edge(clk_25) then
			obecny<=nastepny;
			if RESET='1' then
				if poprzedni_synchro='0' then
					synchronizacja<='1';
				else 
					synchronizacja<='0';
				end if;
			else
				synchronizacja<='0';
			end if;
			poprzedni_synchro<=RESET;
		end if;
	end process Maszyna;

	Stany:process(obecny, synchronizacja)
	variable predkosc: integer:=0;
	variable dodatek: integer:=0;
	begin
		case obecny is
			when OCZEKIWANIE =>
				if synchronizacja='1' then
					nastepny<=WALKA;
				else
					nastepny<=OCZEKIWANIE;
				end if;
				wlaczony<='1';
			when WALKA =>
				if pilkax<0 or pilkax>640 then
					nastepny<=SERWIS;
				else
					nastepny<=WALKA;
				end if;
				wlaczony<='1';
			when SERWIS =>
				if synchronizacja='1' then
					nastepny<=GRA;
				else
					nastepny<=SERWIS;
				end if;
				wlaczony<='1';
			when GRA =>
				if pilkax<0 or pilkax>640 then
					nastepny<=PUNKTY;
				else
					nastepny<=GRA;
				end if;
				wlaczony<='1';
			when PUNKTY =>
				if punktylewy>19 or punktyprawy>19 then
					nastepny<=KONIEC;
				else
					nastepny<=SERWIS;
				end if;
				wlaczony<='1';
			when KONIEC =>
				if synchronizacja='0' then
					if predkosc<2000000000 then
						predkosc:=predkosc+1;
					else
						if dodatek<150 then
							dodatek:=dodatek+1;
						else
							dodatek:=0;
						end if;
						predkosc:=0;
					end if;
					nastepny<=KONIEC;
					if dodatek<75 then
						wlaczony<='1';
					else
						wlaczony<='0';
					end if;
				else
					nastepny<=OCZEKIWANIE;
				end if;
			when others =>
				nastepny<=OCZEKIWANIE;
		end case;
	end process Stany;
	
	Paletki:process(clk_25)
	variable predkosc: integer:=0;
	begin
		if rising_edge(clk_25) then
			if predkosc<100000 then
				predkosc:=predkosc+1;
			else
				if PN='1' then
					if leway<426 then
						leway<=(leway+1);
					end if;
				end if;
				if PD='1' then
					if praway>105 then
						praway<=(praway-1);
					end if;
				end if;
				if WS='1' then
					if praway<426 then
						praway<=(praway+1);
					end if;
				end if;
				if ZA='1' then
					if leway>105 then
						leway<=(leway-1);
					end if;
				end if;
				predkosc:=0;
			end if;
		end if;
	end process Paletki;

	LotPilki:process(clk_25)
	variable predkosc: integer:=0;
	begin
		if rising_edge(clk_25) then
			case obecny is
				when SERWIS =>
						pilkax<=320;
						case zdobywca is
							when LEWY =>
								pilkay<=leway;
							when PRAWY =>
								pilkay<=praway;
							when others =>
								pilkay<=266;
						end case;
						prpilkiy<=1;
				when GRA|WALKA =>
					if predkosc<1000000 then
						predkosc:=predkosc+1;
					else
						if (pilkax<18 and pilkax>8 and pilkay<leway+42 and pilkay>leway-42) or
						(pilkax>622 and pilkax<632 and pilkay<praway+42 and pilkay>praway-42) then
							if (pilkax>400 and prpilkix>0) or (pilkax<400 and prpilkix<0) then
								prpilkix<=(prpilkix*(-1));								
							end if;
							if ((ZA='1' and leway<420) or (PD='1' and praway<420)) and (prpilkiy>1 or prpilkiy<0) then
								prpilkiy<=(prpilkiy-1);
							elsif ((PN='1' and leway>101) or (WS='1' and praway>101)) and (prpilkiy>0 or prpilkiy<-1) then
								prpilkiy<=(prpilkiy+1);
							end if;
						end if;
						if (pilkay>460 and prpilkiy>0) or (pilkay<70 and prpilkiy<0) then
							prpilkiy<=(prpilkiy*(-1));
						end if;
						if not (pilkax<0 or pilkax>640) then
							pilkax<=(pilkax+prpilkix);
							pilkay<=(pilkay+prpilkiy);
						end if;
						predkosc:=0;
					end if;
				when others =>
					null;
			end case;
		end if;
	end process LotPilki;
	
	Wyniki:process(clk_25)
	begin
		if rising_edge(clk_25) then
			case obecny is
				when SERWIS =>
					if pilkax>640 then
						zdobywca<=LEWY;
					elsif pilkax<0 then
						zdobywca<=PRAWY;
					end if;
					l1<=lewacyfra(punktylewy);
					l2<=prawacyfra(punktylewy);
					p1<=lewacyfra(punktyprawy);
					p2<=prawacyfra(punktyprawy);					
				when PUNKTY =>
					if pilkax>640 then
						punktylewy<=punktylewy+1;
					elsif pilkax<0 then
						punktyprawy<=punktyprawy+1;
					end if;
					l1<=lewacyfra(punktylewy);
					l2<=prawacyfra(punktylewy);
					p1<=lewacyfra(punktyprawy);
					p2<=prawacyfra(punktyprawy);
				when KONIEC =>
					if punktyprawy>20 then
						l1<=(others=>'0');
						l2<=(others=>'0');
						p1<=(3=>'0', 6=>'0', others=>'1');
						p2<=(6 downto 5=>'1', others=>'0');
					elsif punktylewy>20 then
						p1<=(others=>'0');
						p2<=(others=>'0');
						l1<=(3=>'0', 6=>'0', others=>'1');
						l2<=(6 downto 5=>'1', others=>'0');
					end if;
				when WALKA|OCZEKIWANIE =>
					l1<=(others=>'0');
					l2<=(others=>'0');
					p1<=(others=>'0');
					p2<=(others=>'0');
					if obecny=OCZEKIWANIE then
						zdobywca<=NIKT;
					end if;
					punktyprawy<=x"00";
					punktylewy<=x"00";
				when GRA =>
					zdobywca<=NIKT;
				when others =>
					null;
			end case;
		end if;
	end process Wyniki;
	
	Wyswietl:process(clk_25)
	begin
		if rising_edge(clk_25) then
			case segmenty(licznikpion, licznikpoziom, l1, l2, p1, p2) is
				when 2 =>
					if wlaczony='0' then
						czerwony<=x"1";
						zielony<=x"1";
						niebieski<=x"1";
					else
						czerwony<=x"0";
						zielony<=x"0";
						niebieski<=x"8";
					end if;
				when 1 =>
					czerwony<=x"1";
					zielony<=x"1";
					niebieski<=x"1";
				when others =>
					czerwony<=x"0";
					zielony<=x"0";
					niebieski<=x"0";
			end case;
		end if;
	end process Wyswietl;
end Behavioral;