# 1 PRIPREMA PODATAKA

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


# vizualizacija

# Koordinate su prikazane na slici data_set_coor_range

# Pojedinacne
  

ggplot(df)+
  geom_density(
    mapping = aes(
      x = elevation
    )
  )+
  labs(
    title = "Elevation distribution",
    x = "[m]",
  )

ggplot(df)+
  geom_density(
    mapping = aes(
      x = wind_speed
    )
  )+
  labs(
    title = "Wind speed distribution",
    x = "[m/s]",
  )


ggplot(df)+
  geom_density(
    mapping = aes(
      x = air_temp
    )
  )+
  labs(
    title = "Air temperature distribution",
    x = "[C]",
  )

ggplot(df)+
  geom_histogram(
    mapping = aes(
      x = air_temp
    )
  )+
  labs(
    title = "Air temperature distribution",
    x = "[C]",
  )

ggplot(df)+
  geom_boxplot(
    mapping = aes(
      x = air_temp
    )
  )+
  labs(
    title = "Air temperature distribution",
    x = "[C]",
  )


# GHI

ggplot(df)+
  geom_density(
    mapping = aes(
      x = ghi
    )
  )+
  labs(
    title = "GHI distribution",
    x = "kWh/m^2",
  )

ggplot(df)+
  geom_boxplot(
    mapping = aes(
      x = ghi
    )
  )+
  labs(
    title = "GHI distribution",
    x = "kWh/m^2",
  )

# Medjusobni odnosi

ggplot(df, aes(x = ghi, y = air_temp)) +
  geom_line() +
  labs(
    title = "Global Horizontal Irradiance vs. Air Temperature ",
    x = "Air Temperature",
    y = "Global Horizontal Irradiance (ghi)"
  )

