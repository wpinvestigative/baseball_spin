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

pitcher_names <- read_csv("outputs/summarized_data/pitcher_names.csv") %>% 
  arrange(pitcher_name)

pitch_types <- read_csv("outputs/summarized_data/pitch_types.csv") %>% 
  filter(!is.na(pitch_type)) %>% 
  arrange(pitch_type)



shinyUI(fluidPage(theme=shinytheme("flatly"),
                  
                  # Inserting the Washington Post Investigative logo
                  list(tags$head(HTML('<link rel="icon", href="https://avatars3.githubusercontent.com/u/29076131?s=30&v=4", 
                                      type="image/png" />'))),
                  div(style="padding: 1px 0px; width: '100%'",
                      titlePanel(
                        title="", windowTitle="MLB Pitcher Adjusted Spin Rate Analysis"
                      )
                  ),
                  navbarPage(
                    title=div(HTML("<img src='https://avatars3.githubusercontent.com/u/29076131?s=30&v=4' hspace='5'>"), "MLB Pitcher Adjusted Spin Rate Analysis"),
                    tabPanel("Pitcher",
                             sidebarLayout(
                               sidebarPanel(
                                 pickerInput("pitcher_name", label = h4("Select pitcher"), 
                                             choices = pitcher_names,
                                             options = list(`live-search`=TRUE),
                                             selected = "Gerrit Cole")
                                 ,
                                 pickerInput("pitch_type", label = h4("Select pitch type"), 
                                             choices = pitch_types, 
                                             options = list(`live-search`=TRUE),
                                             selected = "fastball"),
                                 p("How baseball’s war on sticky stuff is already changing the game"),
                                 p("The Washington Post reviewed MLB footage and analyzed nearly 2 million pitches from data provided by Baseball Prospectus since 2017 when spin rates first started being tracked reliably. Details on The Post’s methodology and data can be found on GitHub.")
                               ),
                               
                               mainPanel(
                                 
                                 plotOutput("top_chart", height="400px"),
                                 dataTableOutput("top_table")
                                 ))
                    )

                  )
                  
))

