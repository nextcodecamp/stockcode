#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#This code is created by Nextcodecamp 
#February, 14, 2023

library(shiny)
library(quantmod)
ui <- fluidPage(
  # Application title
  img(src='next.jpg', align = "left", width="150", height="150"),
  titlePanel("NextToYou: Find Stock Room"),
  fluidRow(
    column
    (12,
      tabsetPanel(id = "inTabset", 
        tabPanel("Stock", fluidRow(column(3,
                       selectInput("mystock1", "Stock:", multiple=FALSE, selected=1,
                      c("BAFS.BK" ,
                        "OR.BK",
                        "BCPG.BK",
                        "PTT.BK",
                        "TISCO.BK"))
                       ),
                      (column(3,
                      selectInput("mystock2", "Stock:", multiple=FALSE, selected=2,
                                  c("BAFS.BK" ,
                                    "OR.BK",
                                    "BCPG.BK",
                                    "PTT.BK",
                                    "TISCO.BK"))
                       )),
                      column(3,dateInput("from","From (yyyy-mm-dd)", value="2019-01-01")),
                      column(3,dateInput("to","From (yyyy-mm-dd)"), value= Sys.Date()),
                      
                      )
                 ,
                 
                
                 
        ),
        
    
      
    )
  )
  
  ,
  
),
fluidRow(
  
  column(12,
         navlistPanel(
           "Stock Performance",
           tabPanel("Dividend",fluidRow(column(6,tableOutput("dividend1")),
                                        column(6,tableOutput("dividend2"))),
                    
           ),
           tabPanel("P/E ratio"),
           "Stock Performance",
           tabPanel("Return - 4 weeks", tableOutput("return4weeks")),
           tabPanel("Return - 3 months", tableOutput("return3months")),
           tabPanel("Return - 6 months", tableOutput("return6months")),
           tabPanel("Return - 12 months", tableOutput("return12months")),
           
           
         )
    
  )
)

)#End fluidPage
  




# Define server logic required to draw a histogram
server <- function(input, output) {
  
  createDivTable <- function(stock){
    dividend <-data.frame(getDividends( stock , src = "yahoo",
                                        from = input$from,
                                        to = input$to, auto.assign = FALSE))
    div <- c(dividend[1])
    div <- c(unlist(div))        
    avgdiv <- sum(div)/nrow(dividend)
    
    dividend[nrow(dividend) + 1,] <- c(avgdiv)
    rownames(dividend) [nrow(dividend) ] <- "Average dividend"
    close <-data.frame(getSymbols( stock , src = "yahoo",
                                        from = Sys.Date()-1,
                                        to = Sys.Date(), auto.assign = FALSE))
    dividend[nrow(dividend) + 1,] <- c(Cl(close))
    rownames(dividend) [nrow(dividend) ] <- "Last close"
    dividend[nrow(dividend) + 1,] <- c(avgdiv/Cl(close))
    rownames(dividend) [nrow(dividend) ] <- "Dividend %"
    
   return (dividend)
    
  }
  output$dividend1 <- renderTable({
    dividend <- createDivTable(input$mystock1)
    dividend
     },rownames = TRUE)
  
  output$dividend2 <- renderTable({
    dividend <- createDivTable(input$mystock2)
    dividend
  },rownames = TRUE)
  
 
  
  output$return <- renderTable({
    test<-as.data.frame(getSymbols(Symbols = input$mystock , src = "yahoo", from = input$from,
                                   to = input$to, env = NULL))
   # test <- c(Cl(test),Op(test),Cl(test)-Op(test)/Op(test) )
    test <- data.frame(test[1],test[4], (test[4] - test[1]) / test[1])
    colnames(test) <- c("Open","Close", "Return")
    test
  })
 
  
  output$peratio <- renderTable({
    pestock <- as.data.frame(getQuote(input$groupstock, 
                        what = yahooQF("P/E Ratio")))
    pestock
  })
 
  output$sma2Plot <- renderPlot({
    test<-as.data.frame(getSymbols(Symbols = input$mystock , src = "yahoo", from = "2023-01-01",to = "2023-01-11", env = NULL))
    
    chartSeries(test, subset="last 4 weeks")
  })
  
  
}

# Run the application 
shinyApp(ui = ui, server = server)
