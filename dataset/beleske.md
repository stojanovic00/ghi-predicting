## Konsultacije:

- ograniciti se samo na letnji period
- smanjiti broj koordinata, pogledati kako su prikupljani ti podaci, pa mozda
  samo raditi predikcije za konkretne  meteo stanice
- razmotriti da li da se izbace sva merenja po mraku, sto je lako ako znamo da 
  se gleda samo letnji period
- ima smisla raditi predikciju ghi
- moze da se uradi klasifikacija preko tresholda nekog tipa jako zracenje i
  normalno zracenje, izuciti malo domen
- razmisliti o dodavanju kolona u svaki red o prethodnim merenjima pre 1 2 3 6 9h,
  pa da i to pomaze prilikom predikcije (kao ghi pre 1h 2h 3h koji je bio)
- koristiti spark da bi se obucavanje paralelizovalo 
- summary je ok da se koristit za one numericke statistike o pojedinacnim obelezjima
- ok je koristiti i histogram i gustinu verovatnoce za prikaz, mada gledati da 
  grafik gustine bude lep, kontinualan. U sustini treba da bude informativnog
  karaktera, da stvarno nesto moze da se skonta sa njega
- oni odnosi izmedju obelezja bukvalno trebaju svaki sa svakim da se uradi
- treba obratiti paznju na licencu i navesti na pocetku rada sve sto ta 
  licenca zahteva, tipa naziv, autor, godina, naziv licence itd.


 konvertujemo iz matricnog zapisa u tabelarni
 Zbog velicine podataka uzimamo merenja vezana za svaku n-tu koordinatu

