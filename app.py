from shiny import ui, render, App
from matplotlib import pyplot as plt
import pandas as pd
import pandas_ta as ta
import yfinance as yf

style="border: none;"

app_ui = ui.page_fluid(
    ui.h1("Stock Analysis by Python"),
	ui.navset_tab(
       	ui.nav("OHLC",
         	ui.row(
             	ui.column(4,ui.input_selectize("stock",
"Choose a stock:",{
"Energy": {"PTT.BK":"PTT", "BGRIM.BK":"BGRIM", "BAFS.BK":"BAFS"},
"Tourism": {"AOT.BK":"AOT", "MINT.BK": "MINT"},
                  },multiple=True, selected="PTT.BK"
                              ) ),
				ui.column(3, 	
					ui.input_date("start","Start", value="2022-01-01"), style=style),
                 ui.column(3, ui.input_date("end","End"), style=style)
                    ),
              ui.row(
				ui.column(12, 
					ui.output_table("getstock")))
              ), #End nav OHLC  
         ui.nav("rsi",
     			ui.row(
             	ui.column(12, 
					ui.navset_pill_list(
                        ui.nav("rsi-15 days", ui.output_plot("rsi15plot")),
                        ui.nav("rsi-30 days", ui.output_plot("rsi30plot")),
                        ui.nav("rsi-45 days", ui.output_plot("rsi45plot")),
                       )) 
                      ), 
               ),  #End nav rsi
         ui.nav("div", "Dividend report"),
         ui.nav_menu("Moving Average",
         # body of menu
            ui.nav("sma", "Simple Moving Average"),
                   "----",
            ui.nav("ema", "Exponential Moving Average"),
                     ),
         )
    
)#End page_fluid
def server(input, output, session):
    @output
    @render.plot
    def rsi15plot():
      stk = input.stock()
      startdate = input.start()
      enddate = input.end()
      df = yf.download(stk,startdate, enddate, 
            auto_adjust=True)
      rsi = ta.rsi(df['Close'], length=15)
      pr = pd.DataFrame()
      pr['close'] = df['Close']
      pr['rsi'] = rsi
      return plt.plot(pr)
    @output
    @render.table
    def getstock():
      stk = input.stock()
      startdate = input.start()
      enddate = input.end()
      df = yf.download(stk,startdate, enddate, 
            auto_adjust=True)
      return( 
            df.style.set_table_attributes(
             'class="dataframe shiny-table table w-auto"'
            )
            .set_table_styles(
            [dict(selector="th", props=[("text-align",     
             "right")])])
            .highlight_min(color="yellow")
            .highlight_max(color="#AEF359")
           ) 
    
app = App(app_ui, server)
