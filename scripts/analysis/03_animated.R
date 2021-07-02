library(tidyverse)
library(lubridate)
library(gganimate)
library(transformr)
library(lattice)
library(broom)

pitches <- read_csv("data/clean_data/combined_2017_2021.csv") %>% 
  mutate(pitch_type=case_when(
    pi_pitch_type=="CH" ~ "changeup",
    pi_pitch_type=="SI" ~ "sinker",
    pi_pitch_type=="SL" ~ "slide",
    pi_pitch_type=="CU" ~ "knuckle curve",
    pi_pitch_type=="FA" ~ "4-seam fastball",
    pi_pitch_type=="FC" ~ "cutter",
    pi_pitch_type=="KN" ~ "knuckleball",
    pi_pitch_type=="SB" ~ "screwball",
    pi_pitch_type=="FS" ~ "sinking fastball/splitter",
    pi_pitch_type=="CS" ~ "curve, slow",
  ),
  pitch_results=case_when(
    pitch_result=="B" ~ "ball",
    pitch_result=="F" ~ "foul",
    pitch_result=="FB" ~ "fly ball/popup",
    pitch_result=="GB" ~ "ground ball",
    pitch_result=="LD" ~ "line drive",
    pitch_result=="PU" ~ "fly ball/popup",
    pitch_result=="S" ~ "strike"
  ),
  pitch_outcomes=case_when(
    pitch_outcome=="1B" ~ "first base",
    pitch_outcome=="2B" ~ "second base",
    pitch_outcome=="3B" ~ "third base",
    pitch_outcome=="B" ~ "ball",
    pitch_outcome=="F" ~ "foul",
    pitch_outcome=="HR" ~ "homerun",
    pitch_outcome=="OUT" ~ "out",
    pitch_outcome=="S" ~ "strike",
    pitch_outcome=="HBP" ~ "hit by pitch",
    pitch_outcome=="NIP" ~ "not in play",
    pitch_outcome=="RBOE" ~ "reached base on error"
  )) %>% 
  mutate(bauer_units=rpm/mph)

daily <- pitches %>% 
  filter(pitch_type=="4-seam fastball") %>% 
  group_by(game_date) %>% 
  filter(year==2021) %>% 
  summarize(avg_bu = round(mean(bauer_units, na.rm=T),2)) 

ggplot(daily, aes(x = game_date,
                  y = avg_bu)) +
  geom_vline(xintercept=ymd("2021-06-03"), color="red") +
  geom_line() +
  geom_point() +
  geom_smooth(method = "loess", formula = 'y ~ x', se = FALSE) + 
  labs(title="Average adjusted spin of daily pitches in 2021",
       y="Adjusted spin rate",
       x="Date") +
  theme_minimal() 
ggsave("outputs/graphics_data/daily2021.pdf", width=8, height=5)

write_csv(daily, "outputs/graphics_data/daily2021.csv")
p <- ggplot(daily, aes(x = game_date,
                    y = avg_bu)) +
  geom_vline(xintercept=ymd("2021-06-03"), color="red") +
  geom_line() +
  geom_point() +
  #geom_smooth(method = "loess", formula = 'y ~ x', se = FALSE) + 
  labs(title="Average adjusted spin of daily pitches in 2021",
       y="Adjusted spin rate",
       x="Date") +
  theme_minimal() +
  transition_reveal(game_date)

a <- animate(p,  height = 600, width =1200, renderer = gifski_renderer())


anim_save("outputs/findings/2021_average_trend.gif", a)


# transformed
daily <- daily %>% 
  mutate(date_chart=str_sub(as.character(game_date),6, 11)) %>% 
    mutate(date_chart=mdy(paste0(date_chart, "-21")),
           year=as.character(year(game_date)))

daily_nested <-
  daily %>%
  group_by(year) %>%
  nest()

# build separate regression models
daily_models <- 
  daily_nested %>%
  mutate(lm_mod = map(data, 
                      ~lm(formula = avg_bu ~ game_date, 
                          data = .x)))

daily_models_aug <-
  daily_models %>%
  mutate(aug = map(lm_mod, ~augment(.x))) %>% 
  unnest(aug)

case_animate <-
  daily_models_aug %>%
  ggplot(aes(x = game_date, 
             y = avg_bu,
             colour = year)) +
  geom_vline(xintercept=ymd("2021-06-03")) +
  geom_line(aes(group = year, y = .fitted), size = 0.5, linetype = "dashed") +
  geom_point(size = 2) +
  geom_line(aes(group = year)) +
  transition_reveal(game_date) +
  labs(title = "Trends in adjusted average pitcher spin rates",
       subtitle = "Data from...",
       x = "Date",
       y = 'Average spin rate',
       caption = "",
       colour = "KPI") +
  scale_colour_discrete(labels = c("2017", 
                                   "2018",
                                   "2019",
                                   "2020",
                                   "2021")) +
  scale_fill_discrete() +
  theme_minimal() 



case_animate <-
  daily %>%
  ggplot(aes(x = game_date, 
             y = avg_bu,
             colour = year)) +
  geom_vline(xintercept=ymd("2021-06-03"), color="gray80") +
  geom_line() +
  geom_smooth(method="lm", linetype="dashed", se=F) +
  labs(title="Average adjusted spin of daily pitches in 2021",
       subtitle = "Data from...",
       x = "Date",
       y = 'Average spin rate',
       caption = "") +
  theme_minimal() +
  transition_reveal(game_date) 


a <- animate(case_animate, height = 600, width =1200,
             renderer=ffmpeg_rende)
a <- animate(case_animate,  height = 600, width =1200, renderer = av_renderer())


anim_save("annual_average_trend.mp4", a)


