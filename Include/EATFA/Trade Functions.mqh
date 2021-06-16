#property copyright "Copyright 2021, Achref sayadi "
#property link      "mailto:sayadigroup@gmail.com"

enum ENUM_LotType
            { Fixed, //Fixed Lot
              PercentLot //Use Percent of Balance
            };
//#include <MQL4 Constants.mqh>
#include <initmql4.mqh>
#define   LastPrice SymbolInfoDouble(_Symbol,SYMBOL_LAST)

class TradeFunctions
  {int Magic;
   int Slippage;
   
   MqlTradeRequest m_request;
   MqlTradeResult m_result;
   MqlTradeCheckResult m_check_result;
   //int m_deviation;
   int SymbolType(string symbol="NULL", bool verbose=false);
   bool m_async_mode;
   ENUM_ORDER_TYPE_FILLING m_type_filling;
   void ClearStructures();
   void SetFillingType(string symbol,ENUM_ORDER_TYPE_FILLING &fill_type);
   bool FillingCheck(string symbol);
   ENUM_LotType LotStyle;
   double RiskPercent;
   double FixedLots;
   double LotSize(double EquityAtRisk,double OpenPrice,double StopLossPrice,int CurrentOrderType,string symbol="NULL",bool ReturnNormalizedLots=false,bool verbose=false);
   string CounterPairForCross(string symbol="NULL", bool verbose=false);
public:
                     TradeFunctions(int magic, int slippage,ENUM_LotType lotstyle = 0,double riskp = 0.1,double fixedlots = 0.01, bool async_mode = false,
                                    ENUM_ORDER_TYPE_FILLING filling = ORDER_FILLING_FOK)
                     {Magic = magic;
                      Slippage = slippage;
                      //m_deviation = deviation;
                      m_async_mode = async_mode;
                      m_type_filling = filling;
                      SetFillingType(_Symbol,m_type_filling);
                      LotStyle = lotstyle;
                      RiskPercent = riskp;
                      FixedLots = fixedlots;
                     }
                    ~TradeFunctions(void){};
               ulong OpenPendingOrder(string symbol,int signal,double price,double sl,double tp,double lot,string comment, uint &retcode);
                
                void OrderClose(int type, string reason);
                void TrailStop(string symbol,      //symbol to trail in
                               double trailstop,   //Trail Stop Level (distance of sl from price)
                               double trailstep);  //Trail Step
                void FTrailStop(string symbol,int trailstart, int trailstep,int trailticks, double ticksize); // futures trail stop
                void CloseAtDollarAmmount(double profit, double loss);
                void Breakeven(string symbol,int belevel, int beoffset, double ticksize = 0);
                int  GetPositionCount();
                int  GetPositionCount(string symbol, int &buy, int &sell);
                int  GetPendingOrderCount(string symbol, int &buystop, int &sellstop);
                int  GetPendingOrderCount(string symbol, int &buystop,int &sellstop,int &buylimit, int &selllimit);
                bool PositionModifyCheck(ulong ticket,double sl,double tp);
                bool PositionClose(const string symbol,const ulong ticket,string reason,double volume = 0.0000,string comment =NULL);
                bool PositionClosePart(const string symbol,const ulong ticket, string reason,double partclosepercent);
                bool CloseTrades(string symbol,string reason,int type=-1);
                bool IsHedging();
                bool OrderDelete(const ulong ticket);
                bool PositionModify(const string symbol,ulong _ticket,double sl,double tp);
                bool OpenPosition(string symbol, int type,double volume,string comment,double sl,double tp);
                bool OrderModify(ulong ticket,double price,double sl,double tp,const ENUM_ORDER_TYPE_TIME type_time,datetime expiration,double stoplimit);
                void ClosePendingOrders(string symbol, string reason, ENUM_ORDER_TYPE type = -1);
               ulong OrderOpen(string symbol,ENUM_ORDER_TYPE order_type,double volume,double limit_price,double price,double sl,double tp,ENUM_ORDER_TYPE_TIME type_time,datetime expiration,string comment, uint &retcode);
              double PipsToPoints(double pips);
              double LotGen(int ordertype, double StopLossPrice, double pendingprice = 0);
              double FLotGen(int ordertype, double StopLossPrice, double pendingprice = 0);
              double High(int shift);
              double Open(int shift);
              double Close(int shift);
              double Low(int shift);
              double NormalizeLotSize(double CurrentLotSize, string symbol="NULL", bool verbose=false);
                
  };
//---------------------Set Filling Type
void TradeFunctions::SetFillingType(string symbol,ENUM_ORDER_TYPE_FILLING &fill_type)
  {
   int filling=(int)SymbolInfoInteger(symbol,SYMBOL_FILLING_MODE);
   if((filling  &SYMBOL_FILLING_FOK)==SYMBOL_FILLING_FOK) fill_type=ORDER_FILLING_FOK;
   else if((filling  &SYMBOL_FILLING_IOC)==SYMBOL_FILLING_IOC) fill_type=ORDER_FILLING_IOC;
   else fill_type=ORDER_FILLING_RETURN;
  }
//+------------------------------------------------------------------+

bool TradeFunctions::FillingCheck(string symbol)
  {
//--- get execution mode of orders by symbol
   ENUM_SYMBOL_TRADE_EXECUTION exec=(ENUM_SYMBOL_TRADE_EXECUTION)SymbolInfoInteger(symbol,SYMBOL_TRADE_EXEMODE);
//--- check execution mode
   if(exec==SYMBOL_TRADE_EXECUTION_REQUEST || exec==SYMBOL_TRADE_EXECUTION_INSTANT)
     {
      return(true);
     }
   uint filling=(uint)SymbolInfoInteger(symbol,SYMBOL_FILLING_MODE);
   if(exec==SYMBOL_TRADE_EXECUTION_MARKET)
     {
      if(m_request.action!=TRADE_ACTION_PENDING)
        {
         if(m_type_filling==ORDER_FILLING_FOK && (filling  &SYMBOL_FILLING_FOK)!=0)
           {
            m_request.type_filling=m_type_filling;
            return(true);
           }
         if(m_type_filling==ORDER_FILLING_IOC && (filling  &SYMBOL_FILLING_IOC)!=0)
           {
            m_request.type_filling=m_type_filling;
            return(true);
           }
         m_result.retcode=TRADE_RETCODE_INVALID_FILL;
         return(false);
        }
      return(true);
     }

//--- EXCHANGE execution mode
   switch(m_type_filling)
     {
      case ORDER_FILLING_FOK:
         if(m_request.action==TRADE_ACTION_PENDING)
           {
            if(m_request.type==ORDER_TYPE_BUY_STOP || m_request.type==ORDER_TYPE_SELL_STOP)
              {
               m_request.type_filling=ORDER_FILLING_RETURN;
               return(true);
              }
           }
         if((filling  &SYMBOL_FILLING_FOK)!=0)
           {
            m_request.type_filling=m_type_filling;
            return(true);
           }
         m_result.retcode=TRADE_RETCODE_INVALID_FILL;
         return(false);
      case ORDER_FILLING_IOC:
         if(m_request.action==TRADE_ACTION_PENDING)
           {

            if(m_request.type==ORDER_TYPE_BUY_STOP || m_request.type==ORDER_TYPE_SELL_STOP)
              {
               m_request.type_filling=ORDER_FILLING_RETURN;
               return(true);
              }
           }
         if((filling  &SYMBOL_FILLING_IOC)!=0)
           {
            m_request.type_filling=m_type_filling;
            return(true);
           }
         m_result.retcode=TRADE_RETCODE_INVALID_FILL;
         return(false);
      case ORDER_FILLING_RETURN:
         m_request.type_filling=m_type_filling;
         return(true);
     }
//--- unknown execution mode, set error code
   m_result.retcode=TRADE_RETCODE_ERROR;
   return(false);
  }
int TradeFunctions::GetPositionCount(string symbol,int &buy,int &sell)
  {
   buy=0; sell=0;
   if(IsHedging())
     {
      int pos_total=PositionsTotal();
      for(int pos=pos_total-1;pos>=0;pos--)
        {
         ulong pos_ticket=PositionGetTicket(pos);
         if(PositionSelectByTicket(pos_ticket) && PositionGetString(POSITION_SYMBOL)==symbol && PositionGetInteger(POSITION_MAGIC)==Magic)
           {
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY) buy++;
            else if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL) sell++;
           }
        }
     }
   else
   if(PositionSelect(symbol))
     {
      long pos_ID=PositionGetInteger(POSITION_IDENTIFIER);
      HistorySelect(0,TimeCurrent());
      int total= HistoryDealsTotal();
      for(int i=0; i<total; i++)
        {
         ulong deal_ticket= HistoryDealGetTicket(i);
         long pos_ticket  = HistoryDealGetInteger(deal_ticket,DEAL_POSITION_ID);
         if(pos_ID==pos_ticket && HistoryDealGetInteger(deal_ticket,DEAL_ENTRY)==DEAL_ENTRY_IN && HistoryDealGetInteger(deal_ticket,DEAL_MAGIC)==Magic)
           {
            if(HistoryDealGetInteger(deal_ticket,DEAL_TYPE)==DEAL_TYPE_BUY) buy++;
            else if(HistoryDealGetInteger(deal_ticket,DEAL_TYPE)==DEAL_TYPE_SELL) sell++;
           }
        }
     }
   return(buy+sell);
  }
//--------------------------
int TradeFunctions::GetPositionCount()
  {int buy,sell;
   string symbol=_Symbol;
   buy=0; sell=0;
   if(IsHedging())
     {
      int pos_total=PositionsTotal();
      for(int pos=pos_total-1;pos>=0;pos--)
        {
         ulong pos_ticket=PositionGetTicket(pos);
         if(PositionSelectByTicket(pos_ticket) && PositionGetString(POSITION_SYMBOL)==symbol && PositionGetInteger(POSITION_MAGIC)==Magic)
           {
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY) buy++;
            else if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL) sell++;
           }
        }
     }
   else
   if(PositionSelect(symbol))
     {
      long pos_ID=PositionGetInteger(POSITION_IDENTIFIER);
      HistorySelect(0,TimeCurrent());
      int total= HistoryDealsTotal();
      for(int i=0; i<total; i++)
        {
         ulong deal_ticket= HistoryDealGetTicket(i);
         long pos_ticket  = HistoryDealGetInteger(deal_ticket,DEAL_POSITION_ID);
         if(pos_ID==pos_ticket && HistoryDealGetInteger(deal_ticket,DEAL_ENTRY)==DEAL_ENTRY_IN && HistoryDealGetInteger(deal_ticket,DEAL_MAGIC)==Magic)
           {
            if(HistoryDealGetInteger(deal_ticket,DEAL_TYPE)==DEAL_TYPE_BUY) buy++;
            else if(HistoryDealGetInteger(deal_ticket,DEAL_TYPE)==DEAL_TYPE_SELL) sell++;
           }
        }
     }
   return(buy+sell);
  }
bool TradeFunctions::PositionClose(const string symbol,const ulong ticket,string reason,double volume=0,string comment=NULL)
  {
//--- check position existence
   if(IsHedging()) { if(!PositionSelectByTicket(ticket)) return(false); }
   else if(!PositionSelect(symbol)) return(false);
//--- clean
   ClearStructures();
//--- check
   if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY) m_request.type=ORDER_TYPE_SELL;
   else m_request.type=ORDER_TYPE_BUY;
//--- setting request
   m_request.action   = TRADE_ACTION_DEAL;
   m_request.position = ticket;
   m_request.symbol   = symbol;
   m_request.magic    = PositionGetInteger(POSITION_MAGIC);
   if(comment==NULL) m_request.comment=PositionGetString(POSITION_COMMENT);
   else m_request.comment=comment;
   m_request.deviation= Slippage;

//--- check filling
   if(!FillingCheck(symbol))  
   {Print("Filling check failed! Unable to close");
    return(false);
   }

   double pos_volume=PositionGetDouble(POSITION_VOLUME);
   if(volume>0 && volume<=pos_volume) pos_volume=volume;
//--- check volume
   double max_volume=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);

   while(pos_volume>max_volume)
     {
      pos_volume-=max_volume;
      m_request.volume = max_volume;
      m_request.price  = PositionGetDouble(POSITION_PRICE_CURRENT);
      if(OrderSend(m_request,m_result)) Sleep(1000);
      else return(false);
     }

   m_request.volume = pos_volume;
   m_request.price  = PositionGetDouble(POSITION_PRICE_CURRENT);
   bool res = OrderSend(m_request,m_result);
   //Print("Order send res ",m_result.retcode);
//--- close position
   if (res)
   {if (m_result.retcode == 10009) 
    {Print(PositionGetInteger(POSITION_TICKET)," has been closed because ",reason);
     return true;
    }
    else return false;
   }
   return false;
  }
//+------------------------------------------------------------------+
bool TradeFunctions::CloseTrades(string symbol,string reason,int type=-1)
  {
   bool result=true;
   int pos_total=PositionsTotal();
   for(int pos=pos_total-1;pos>=0;pos--)
     {
      ulong pos_ticket=PositionGetTicket(pos);
      if(PositionSelectByTicket(pos_ticket) && PositionGetSymbol(POSITION_SYMBOL)==symbol && PositionGetInteger(POSITION_MAGIC)==Magic)
        {
         long pos_type=PositionGetInteger(POSITION_TYPE);
         if(type==-1 || (type==0 && pos_type==POSITION_TYPE_BUY) || (type==1 && pos_type==POSITION_TYPE_SELL))
            if(!PositionClose(PositionGetSymbol(POSITION_SYMBOL),pos_ticket,reason)) result=false;
         
        }
     }
   return(result);
  }
void TradeFunctions::ClearStructures(void)
  {
   ZeroMemory(m_request);
   ZeroMemory(m_result);
   ZeroMemory(m_check_result);
  }
//-----------Is Hedging
bool TradeFunctions::IsHedging()
  {
   return((ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING);
  }
//---------------------Position Modify
bool TradeFunctions::PositionModify(const string symbol,ulong _ticket,double sl,double tp)
  { if (!PositionModifyCheck(_ticket,sl,tp)) 
    {
     Print("Position modify check returned false");
     return false;
    }
//--- check position existence

   ulong ticket= _ticket;
   /*int cnt=10;
   while(--cnt>0)
     {
      if(HistoryDealSelect(_ticket))
        {
         ticket=HistoryDealGetInteger(_ticket,DEAL_POSITION_ID);
         if(ticket>0) break;
         Sleep(1000);
        }
      else
         Sleep(1000);
     }

   if(IsHedging() && !PositionSelectByTicket(ticket))
     {
      Print("Could not select ticket! ticket = ",ticket);
      return(false);
     }
   else if(!PositionSelect(symbol)) 
   {
    Print("Could not select position");
    return(false);
   }*/


//--- clean
   ClearStructures();
//--- setting request
//symbol = PositionGetString(POSITION_SYMBOL);
   double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
   int stoplevel=(int)SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL);
   long type=PositionGetInteger(POSITION_TYPE);
   if(type==ORDER_TYPE_BUY)
     {
      double bid=SymbolInfoDouble(symbol,SYMBOL_BID);
      if( sl > 0 ) sl  = MathMin(sl,bid - stoplevel*point);
      if( tp > 0 ) tp  = MathMax(tp,bid + stoplevel*point);
     }
   if(type==ORDER_TYPE_SELL)
     {
      double ask=SymbolInfoDouble(symbol,SYMBOL_ASK);
      if(sl>0) sl= MathMax(sl,ask+stoplevel*point);
      if(tp>0) tp= MathMin(tp,ask-stoplevel*point);
     }
   m_request.action  = TRADE_ACTION_SLTP;
   m_request.position= ticket;
   m_request.symbol  = PositionGetString(POSITION_SYMBOL);
   m_request.magic   = PositionGetInteger(POSITION_MAGIC);
   m_request.sl      = sl;
   m_request.tp      = tp;
//--- action and return the result
   return(OrderSend(m_request,m_result));
}
//+------------------------------------------------------------------+
//| Checking the new values of levels before order modification      |
//+------------------------------------------------------------------+
bool TradeFunctions::PositionModifyCheck(ulong ticket,double sl,double tp)
  {
//--- select order by ticket
   if(PositionSelectByTicket(ticket))
     {
      //--- point size and name of the symbol, for which a pending order was placed
      string symbol=PositionGetString(POSITION_SYMBOL);
      //double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
      double posSL = PositionGetDouble(POSITION_SL);
      double posTP = PositionGetDouble(POSITION_TP);
      //--- check if there are changes in the StopLoss level
      bool StopLossChanged = (posSL == sl) ? false: true;
      //(MathAbs(positioninfo.StopLoss()-sl)>point);
      //--- check if there are changes in the Takeprofit level
      bool TakeProfitChanged = (posTP == tp) ? false: true;
      //(MathAbs(positioninfo.TakeProfit()-sl)>tp);
      //--- if there are any changes in levels
      if(StopLossChanged || TakeProfitChanged)
         return(true);  // position can be modified      
      //--- there are no changes in the StopLoss and Takeprofit levels
      /*else
      //--- notify about the error
         PrintFormat("Order #%d already has levels of Open=%.5f SL=%.5f TP=%.5f",
                     ticket,PositionGetDouble(POSITION_PRICE_OPEN),sl,tp);*/
     }
//--- came to the end, no changes for the order
   return(false);       // no point in modifying 
  }
bool TradeFunctions::OpenPosition(string symbol, int type,double volume,string comment,double sl,double tp)
  {
   ENUM_ORDER_TYPE trade=EMPTY;
   if(type==OP_BUY)
      trade=ORDER_TYPE_BUY;
   if(type==OP_SELL)
      trade=ORDER_TYPE_SELL;
//--- clean
   ClearStructures();
//--- check
   if(trade!=ORDER_TYPE_BUY && trade!=ORDER_TYPE_SELL)
     {
      m_result.retcode=TRADE_RETCODE_INVALID;
      m_result.comment="Invalid order type";
      return(false);
     }
//---------------------------------------------
//MqlTradeRequest request={0};
//MqlTradeResult  result={0};
//--- parameters of request
   m_request.action   =TRADE_ACTION_DEAL;                     // type of trade operation
   m_request.symbol   =symbol;                                // symbol
                                                              //m_request.volume   =lots;                                   // volume of 0.2 lot
   m_request.type=trade;                                  // order type
   m_request.deviation=Slippage;                              // Deviation
   if(type==OP_BUY)
      m_request.price=SymbolInfoDouble(symbol,SYMBOL_ASK); // price for opening
   else
      m_request.price    =SymbolInfoDouble(symbol,SYMBOL_BID); // price for opening
   m_request.deviation=Slippage;                              // allowed deviation from the price
   m_request.magic=Magic;                          // Magic Number of the order
   m_request.comment  =comment;
   m_request.sl       =sl;
   m_request.tp       =tp;
//--- check filling
   if(!FillingCheck(symbol))  return(false);
//--- check volume
   double max_volume=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);
//--- action and return the result
   bool check=false;
   while(volume>max_volume)
     {
      volume-=max_volume;
      m_request.volume=max_volume;
      if(m_async_mode) check=OrderSendAsync(m_request,m_result);
      else check=OrderSend(m_request,m_result);
      if(check) { Print("Open partial position."); Sleep(1000); }
      else return(false);
     }

   m_request.volume=volume;

//--- send the request
   if(m_async_mode) check=OrderSendAsync(m_request,m_result);
   else check=OrderSend(m_request,m_result);
   if(!check)
      PrintFormat("OrderSend error %d",GetLastError());     // if unable to send the request, output the error code
//--- information about the operation
   PrintFormat("retcode=%u  deal=%I64u  order=%I64u",m_result.retcode,m_result.deal,m_result.order);
   return(check);
  }
