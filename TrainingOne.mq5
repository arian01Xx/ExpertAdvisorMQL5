#property link      "Nova Noir Bank ----- CEO Arian J. Mio"
#property version   "Nexo Noir Intelectual Corp."

#include <Trade/Trade.mqh>

double lots=0.1;
int tp=100;
int sl=100;
int magic=11;
input int up=20;
input int down=20;

input ENUM_TIMEFRAMES timeframe=PERIOD_M15;

CTrade trade;

int bollingerBands;
int Rsi;

int OnInit(){
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){

}

void OnTick(){
   
   static datetime lastTime=0;
   if(TimeCurrent() == lastTime){
     return;
   }
   lastTime=TimeCurrent();
   
   double ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   double bid=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
   
   //BOLLINGERS BANDS
   double middleBandArray[];
   double upBandArray[];
   double downBandArray[];
   double RSI[];
   
   ArraySetAsSeries(middleBandArray,true);
   ArraySetAsSeries(upBandArray,true);
   ArraySetAsSeries(downBandArray,true);
   
   bollingerBands=iBands(_Symbol,timeframe,20,0,2,PRICE_CLOSE);
   
   CopyBuffer(bollingerBands,0,0,3,middleBandArray);
   CopyBuffer(bollingerBands,1,0,3,upBandArray);
   CopyBuffer(bollingerBands,2,0,3,downBandArray);
   
   double middleBArray=middleBandArray[0];
   double upBArray=upBandArray[0];
   double downBArray=downBandArray[0];
   
   //////////////////////////////////////77
   ArraySetAsSeries(RSI,true);
   
   Rsi=iRSI(_Symbol,timeframe,13,PRICE_CLOSE);
   
   if(bid>upBArray){
     Comment("\nSeñal de Venta: ", DoubleToString(bid,_Digits));
   }else if(ask<downBArray){
     Comment("\nSeñal de Compra: ",DoubleToString(bid,_Digits));
   }
   
   //////////////////////////////////////////////////
   CopyBuffer(Rsi,0,0,3,RSI);
   double currentRSI=RSI[0];
   
   Comment(currentRSI);
   
   bool sell=trading(bid);
   bool buy=trading(ask);
   
   //sell bid, buy ask
   if(ask>70 && ask>upBArray){
     operationBuy(buy,ask,sl,tp);
   }else if(bid<30 && bid<downBArray){
     operationSell(sell,bid,tp,sl);
   }
}

bool trading(double number){
   for(int i=PositionsTotal()-1; i>=0; i--){
     ulong postTicket=PositionGetTicket(i);
     string postSimbol=PositionGetString(POSITION_SYMBOL);
     if(postSimbol != _Symbol){
       continue;
     }
     return true; //Hay una posición abierta para este simbolo
   }
   return false; //No hay posiciones abiertas para este simbolo
}

void operationBuy(bool tradeOne,double ask,int stopL,int takeP){
   if(tradeOne==false){
     double newStopLossBuy=ask-takeP*_Point;
     double newTakeProfitBuy=ask+stopL*_Point;
     trade.Buy(lots,_Symbol,ask,newStopLossBuy,newTakeProfitBuy);
   }
}

void operationSell(bool tradeOne,double bid,int stopL, int takeP){
  if(tradeOne == false){
     double newStopLoss=bid+stopL*_Point;
     double newTakeProfit=bid-takeP*_Point;
     trade.Sell(lots,_Symbol,bid,newStopLoss,newTakeProfit);
  }
}

void Comment(double number){
   if(number>50){
     Comment("\nTendencia Alcista...");
   }else if(number<50){
     Comment("\nTendenci Bajista...");
   }
}