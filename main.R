# 1 PRIPREMA PODATAKA

# Konsultacije:
#- ograniciti se samo na letnji period
#- smanjiti broj koordinata, pogledati kako su prikupljani ti podaci, pa mozda
  #samo raditi predikcije za konkretne  meteo stanice
#- razmotriti da li da se izbace sva merenja po mraku, sto je lako ako znamo da
  #se gleda samo letnji period
#- ima smisla raditi predikciju ghi
#- moze da se uradi klasifikacija preko tresholda nekog tipa jako zracenje i
  #normalno zracenje, izuciti malo domen
#- razmisliti o dodavanju kolona u svaki red o prethodnim merenjima pre 1 2 3 6 9h,
  #pa da i to pomaze prilikom predikcije (kao ghi pre 1h 2h 3h koji je bio)
#- koristiti spark da bi se obucavanje paralelizovalo 
#- summary je ok da se koristit za one numericke statistike o pojedinacnim obelezjima
#- ok je koristiti i histogram i gustinu verovatnoce za prikaz, mada gledati da 
  #grafik gustine bude lep, kontinualan. U sustini treba da bude informativnog
  #karaktera, da stvarno nesto moze da se skonta sa njega
#- oni odnosi izmedju obelezja bukvalno trebaju svaki sa svakim da se uradi
#- treba obratiti paznju na licencu i navesti na pocetku rada sve sto ta 
  #licenca zahteva, tipa naziv, autor, godina, naziv licence itd.

# Ucitavanje datoteke

#install.packages("BiocManager")
#BiocManager::install("rhdf5")

library(rhdf5)
library(ggplot2)
library(dplyr)
library(lubridate)

h5_file <- H5Fopen("./dataset/vietnam_2016.h5")


# redovi: x y
# Zakljucujemo da imamo 75361 redova zbog 75361 koordinate koje se posmatraju 
# Kolona ima koliko i sati koliko je posmatranje trajalo 366 * 24 = 8784 


air_temp <- h5read(h5_file, "/air_temperature") # celsius
coordinates <- h5read(h5_file, "/coordinates") # ugao
ghi <- h5read(h5_file, "/ghi") #kwh/m^2
meta <- h5read(h5_file, "/meta") # elevation je u m 
time_index <- h5read(h5_file, "/time_index") # datum
wind_speed <- h5read(h5_file, "/wind_speed") # m/s

# konvertujemo iz matricnog zapisa u tabelarni
# Zbog velicine podataka uzimamo merenja vezana za svaku n-tu koordinatu
n <- 10
time_measures_per_coor = ncol(air_temp)
coor_num = nrow(air_temp)

selected_rows = seq(1, coor_num, by = n)
coor_num <- length(selected_rows)

id <- 1:(coor_num * time_measures_per_coor)

latitude <- rep(coordinates[1, selected_rows], each = time_measures_per_coor)
longitude <- rep(coordinates[2, selected_rows], each = time_measures_per_coor)
elevation <- rep(meta[selected_rows,"elevation"], each = time_measures_per_coor)
rm(coordinates)

air_temp <- c(air_temp[selected_rows,])
wind_speed <- c(wind_speed[selected_rows,])
ghi <- c(ghi[selected_rows,])

time <- rep(time_index, coor_num)


df <- data.frame(id, time, latitude, longitude, elevation, air_temp, wind_speed, ghi)

rm(h5_file, meta, id, time, latitude, longitude, elevation, air_temp, wind_speed, ghi)


df <- df %>%
  filter(ghi != 0) %>%
  mutate(time = ymd_hms(strptime(time, "%Y-%m-%d %H:%M:%S")))
# FIX: svaki put kad je 00:00:00 dobije se NA

# 2 PRELIMINARNA ANALIZA PODATAKA 

# vrednosti deskriptivnih statistika

time_range <- range(df$time)
latitude_range <- range(df$latitude)
longitude_range <- range(df$longitude)

elevation_summ <- summary(df$elevation)
wind_summ <- summary(df$wind_speed)
air_temp_summ <- summary(df$air_temp)
ghi_summ <- summary(df$ghi)


  

