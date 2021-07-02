# install packages if missing
packages <- c("tidyverse", "shiny", "shinyWidgets", "lubridate", "shinythemes", "DT")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())), repos = "https://cran.us.r-project.org")  
}


library(tidyverse)
library(shiny)
library(shinyWidgets)
library(lubridate)
library(shinythemes)
library(DT)


pitches_daily <- readRDS("outputs/summarized_data/daily_summarized_pitchers.RDS") %>% 
  mutate(year=as.factor(year))

shinyServer(function(input, output) {
  

output$top_chart <- renderPlot({
  pitches_daily %>% 
    filter(pitcher_name == input$pitcher_name) %>% 
    filter(pitch_type==input$pitch_type) %>% 
    ggplot(aes(x=date_chart, y=adj_spin, group=year, color=year), size=7) +
    geom_point(size=.5) +
    geom_vline(xintercept=ymd("2021-06-03")) +
    geom_smooth(method = "loess", formula = 'y ~ x', se = FALSE) + 
    labs(title=paste0(input$pitcher_name, " adjusted average spin rate over time"),
         y="Spin/Velocity", x="Date",
         subtitle="Data through June 24",
         caption="Credit: Baseball Prospectus / The Washington Post") +
    
    theme_minimal()
})

output$top_table <- renderDataTable(
  pitches_daily %>% 
    mutate(game_date=as.character(game_date)) %>% 
    filter(pitcher_name == input$pitcher_name) %>% 
    filter(pitch_type==input$pitch_type) %>% 
    select(Team=pitcher_team_name,
           Pitcher=pitcher_name,
           Year=year,
           `Game day`=game_date,
           Type=pitch_type,
           `Average adjusted spin rate`=adj_spin)
)

})