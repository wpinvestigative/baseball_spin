library(tidyverse)
library(writexl)
library(jsonlite)

pitch_import <- function(x=2017) {
  year <- x
  
  csv <- paste0("data/raw_data/0624_", x, ".csv")
  df <- read_csv(csv) %>% 
    mutate(year=year)
  return(df)
}

y2017 <- pitch_import(2017)
y2018 <- pitch_import(2018)
y2019 <- pitch_import(2019)
y2020 <- pitch_import(2020)
y2021 <- pitch_import(2021)


combined <- rbind(y2017, y2018, y2019, y2020, y2021) %>% 
  unique()

combined <- combined %>% 
  mutate(pitcher_name=paste0(pitcher_name_first, " ", pitcher_name_last)) %>% 
  arrange(pitcher_name, game_date, inning, at_bat_index, pitch_of_ab) %>% 
  group_by(pitcher_name, game_date) %>% 
  mutate(pitchid_game=row_number()) %>% 
  group_by(pitcher_name, year) %>% 
  mutate(pitchid_year=row_number()) 
  

#Gerrit Cole, Trevor Bauer, Walker Buehler, Justin Verlander, Kenley Jansen, James Karinchak and Max Scherzer 
write_csv(combined, "data/clean_data/combined_2017_2021.csv", na="")

gerrit_cole <- combined %>% 
  filter(pitcher_name_first=="Gerrit" & pitcher_name_last=="Cole")

trevor_bauer <- combined %>% 
  filter(pitcher_name_first=="Trevor" & pitcher_name_last=="Bauer")

walker_buehler <- combined %>% 
  filter(pitcher_name_first=="Walker" & pitcher_name_last=="Buehler")

justin_verlander<- combined %>% 
  filter(pitcher_name_first=="Justin" & pitcher_name_last=="Verlander")

kenley_jansen <- combined %>% 
  filter(pitcher_name_first=="Kenley" & pitcher_name_last=="Jansen")

james_karinchak <- combined %>% 
  filter(pitcher_name_first=="James" & pitcher_name_last=="Karinchak")

max_scherzer <- combined %>% 
  filter(pitcher_name_first=="Max" & pitcher_name_last=="Scherzer")


tmp <- write_xlsx(list(mysheet = iris))

write_xlsx(list(`Gerrit Cole`=gerrit_cole, `Trevor Bauer`=trevor_bauer,
                `Walker Buehler`=walker_buehler,
                `Justin Verlander`=justin_verlander,
                `Kenley Jansen`=kenley_jansen,
                `James Karinchak`=james_karinchak,
                `Max Scherzer`=max_scherzer), path="pitchers.xlsx")

test <- fromJSON("https://statsapi.mlb.com/api/v1/schedule?startDate=2021-06-12&endDate=2021-06-12&hydrate=weather&sportId=1")

test2 <- test$dates$games
