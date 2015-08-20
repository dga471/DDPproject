shinyUI(
  fluidPage(
    titlePanel("Investigating New York Air Quality Data"),
    
    sidebarLayout(
      sidebarPanel(
        selectInput("select",label = h3("Select the quantity to be measured:"), choices = c("Ozone","Solar Radiation","Wind","Temperature"),selected = "Ozone"),
        
        dateRangeInput("dates", label = h3("Date range"),start = "1973-05-01",end="1973-09-30",min = "1973-05-01",max="1973-09-30"),
        
        actionButton("Calculate", label = "Calculate"),
        
        actionButton("Help",label = "Help"),
        textOutput("help")
      ),
      mainPanel(
        plotOutput("myplot"),
        textOutput("slope")
      )
    )
  )
)