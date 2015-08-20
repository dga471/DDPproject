library(zoo)
data(airquality)
df <- airquality
datevec <- paste(airquality$Month,airquality$Day,"1973",sep="/")
df$Date <- as.Date(datevec,format = "%m/%d/%Y")
df$Ozone <- round(na.approx(df$Ozone),0)
df$Solar.R <- round(na.approx(df$Solar.R),0)

shinyServer(
  function(input, output) {
    mindate <- reactive(input$dates[1])
    maxdate <- reactive(input$dates[2])
    
    rf <- reactive(df[df$Date >= mindate() & df$Date <= maxdate(),])
    ydata <- reactive({
      rf = rf()
      switch(input$select,
             "Ozone" = rf$Ozone,
             "Solar Radiation" = rf$Solar.R,
             "Wind" = rf$Wind,
             "Temperature" = rf$Temp)})
    ylab <- reactive({
      rf = rf()
      switch(input$select,
             "Ozone" = "Ozone level (ppb)",
             "Solar Radiation" = "Solar radiation (langleys)",
             "Wind" = "Average wind speed (langleys)",
             "Temperature" = "Temperature (F)")
    })
    output$myplot <- renderPlot({
      newplot()
      reset <- TRUE;
    })
    
    cslope <- eventReactive(input$Calculate,{
      rf = rf()
      ydata <- ydata()
      fit <- lm(ydata ~ rf$Date)
      return(fit$coefficients)
    })
    
    output$slope <- renderText({
      mindate = mindate()
      maxdate = maxdate()
      mtext = round(cslope(),2)
      units = switch(input$select,
                     "Ozone" = "ppb",
                     "Solar Radiation" = "langleys",
                     "Wind" = "langleys",
                     "Temperature" = "F")
    
      return(paste("The rate of change of ",tolower(input$select)," from ",mindate," to ",maxdate," is ",mtext[2]," ",units," per day."))
    })
    
    newplot <- eventReactive(input$Calculate,{
      mtext = cslope()
      rf = rf()
      ydata=ydata()
      ylab=ylab()
      plot(rf$Date,ydata,type="l",xlab = "Date",ylab = ylab)
      abline(mtext[1],mtext[2],lwd = 3,col = "red")
    })
    
    output$help <- renderText({
      htext()
    })
    
    htext <- eventReactive(input$Help,{
        "This application explores data of air quality measurements in New York from May to September 1973. There are four quantities measured: ozone, solar radiation, wind, and temperature. To use the app, first select which quantity to examine and the range of dates. Then click 'Calculate'. This will fit a straight line to the data, giving the rate of change of the quantity during the specified time period." 
    })
  }
)