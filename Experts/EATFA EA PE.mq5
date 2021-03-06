#property copyright "Copyright 2021, Achref sayadi "
#property link      "mailto:sayadigroup@gmail.com"


#define   Version  "1.10"
#property version   Version
#property strict
#include <\\EATFA\\Trade Functions.mqh>
#include <\\EATFA\\Symbols.mqh>
#include <\\EATFA\\License.mqh>

//bool debug = true;

class EATFA_EA
  {
   CLicense * License;
   CSymbols *CSymbolPointer;
  
   void     TradingCriteria();
   void     OpenOrder(string symbol, int direction);
   void     SaveOrder(string symbol, int direction);
   void     DeleteSaveOrder();
   void     PresentSavedOrders();
   void     UpdateUnAttendedWindow();
   void     ExecuteSavedOrder();
   void     ManageOrders();   //Manage Existing
   void     SL_Follower();
   
   int      PositionProfit(int type);
   
   bool     Debug;
   
   bool     GetStoch(int handle, int mode, int shift, double &val);
   bool     GetRSI(int handle, int shift, double &val);
   bool     GetMACD(int handle, int mode, int shift, double &val);
   bool     GetFastMa(int handle, int shift, double &val);
   bool     GetSlowMa(int handle, int shift, double &val);
   bool     HitDollarSL();
   
   double   bid(string symbol);
   double   ask(string symbol);
   
   string   TradeComment;
   string TimeFrameToString(int secs);
   
   struct SAVEDORDERS
     { 
       bool IsSaved;
       int direction;
       string symbol;
       
       SAVEDORDERS();
     };
     
     SAVEDORDERS SavedOrder[];

public:
                     EATFA_EA(void);
                    ~EATFA_EA(void){delete CSymbolPointer; delete License;};
   int      OnInit();
   
   void     OnTimer();
   void     OnChartEvent(const int id,const long& lparam,const double& dparam,const string& sparam);
  };
  

TradeFunctions *TF;
EATFA_EA EA;

EATFA_EA::SAVEDORDERS::SAVEDORDERS(void)
{
 IsSaved = false;
 direction = EMPTY;
 symbol = NULL;
}
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   TF = new TradeFunctions(MagicNumber,30,Fixed,0.1,LotSize);
//---
   
//---
   EventSetTimer(1);
   return(EA.OnInit());
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {delete TF;
//---
   EventKillTimer();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert timer function                                            |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   EA.OnTimer();
   //Print("Ontimer end ",GetTickCount());
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long& lparam,const double& dparam,const string& sparam)
  {
   EA.OnChartEvent(id,lparam,dparam,sparam);
  }

void EATFA_EA::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{
 if(id==CHARTEVENT_OBJECT_CLICK)
 {
  if (!CSymbolPointer.IsWindowOpen()) return;
  
  string yes = CSymbolPointer.GetYesBName(), no = CSymbolPointer.GetNoBName();
  if(sparam==no)          //no button clicked
  {
   DeleteSaveOrder();
   Sleep(18);
   ObjectSetInteger(0,no,OBJPROP_STATE,false);
   CSymbolPointer.DestroyWindow();
  }
  else if (sparam == yes) //yes button clicked
  {
   if (CSymbolPointer.IsWindowOpen()) //confirm the window is still open
   {
    ExecuteSavedOrder();
    Sleep(18);
    ObjectSetInteger(0,yes,OBJPROP_STATE,false);
    CSymbolPointer.DestroyWindow();
    DeleteSaveOrder();
   }
  }
 }
}

void EATFA_EA::ExecuteSavedOrder(void)
{
 int size = ArraySize(SavedOrder);
 if (size == 0) return;
 bool open = TF.OpenPosition(SavedOrder[size-1].symbol,SavedOrder[size-1].direction,LotSize,TradeComment,0,0);
 return;
}

EATFA_EA::EATFA_EA(void)
{
 Debug = false;
 TradeComment = MQLInfoString(MQL_PROGRAM_NAME)+"_V"+Version;
 CSymbolPointer = new CSymbols();
 
 License = new CLicense();
}

bool EATFA_EA::GetFastMa(int handle,int shift, double &val)
{
 val = 0;
 double value[1];
 if (CopyBuffer(handle,0,shift,1,value) > 0) 
 {
  val = value[0];
  return true;
 }
 
 Print("Did not obtain fast ma data! Handle ",handle);
 return false;
}

bool EATFA_EA::GetSlowMa(int handle,int shift, double &val)
{
 val = 0;
 double value[1];
 if (CopyBuffer(handle,0,shift,1,value) > 0) 
 {
  val = value[0];
  return true;
 }
 
 Print("Did not obtain slow ma data! Handle ",handle);
 return false;
}

bool EATFA_EA::GetMACD(int handle,int mode,int shift,double &val)
{
 val = 0;
 double value[1];
 if (CopyBuffer(handle,mode,shift,1,value) > 0) 
 {
  val = value[0];
  return true;
 }
 
 Print("Did not obtain MACD data! Handle ",handle);
 return false;
}

bool EATFA_EA::GetRSI(int handle,int shift,double &val)
{
 val = 0;
 double value[1];
 if (CopyBuffer(handle,0,shift,1,value) > 0) 
 {
  val = value[0];
  return true;
 }
 
 Print("Did not obtain RSI data! Handle ",handle);
 return false;
}

bool EATFA_EA::GetStoch(int handle,int mode,int shift,double &val)
{
 ResetLastError();
 val = 0;
 double value[1];
 if (CopyBuffer(handle,mode,shift,1,value) > 0) 
 {
  val = value[0];
  return true;
 }
 
 Print("Did not obtain Stochastic data! Handle ",handle," ",GetLastError());
 return false;
}

string EATFA_EA::TimeFrameToString(int secs)
{string timeFrameStr;
 switch(secs)
     {
      case 60        : timeFrameStr="M1"; break;
      case 120       : timeFrameStr="M2"; break;
      case 180       : timeFrameStr="M3"; break;
      case 240       : timeFrameStr="M4"; break;
      case 300       : timeFrameStr="M5"; break;
      case 360       : timeFrameStr="M6"; break;
      case 600       : timeFrameStr="M10"; break;
      case 720       : timeFrameStr="M12"; break;
      case 900       : timeFrameStr="M15"; break;
      case 1200      : timeFrameStr="M20"; break;
      case 1800      : timeFrameStr="M30"; break;
      case 3600      : timeFrameStr="H1"; break;
      case 7200      : timeFrameStr="H2"; break;
      case 10800     : timeFrameStr="H3"; break;
      case 14400     : timeFrameStr="H4"; break;
      case 21600     : timeFrameStr="H6"; break;
      case 28800     : timeFrameStr="H8"; break;
      case 43200     : timeFrameStr="H12"; break;
      case 86400     : timeFrameStr="D1"; break;
      case 604800    : timeFrameStr="W1"; break;
      case 2592000   : timeFrameStr="MN1"; break;
      default : timeFrameStr="Current Timeframe";
     }
 return timeFrameStr;
}

void EATFA_EA::PresentSavedOrders(void)
{
 if (OpenType != SL_MANUAL) return; //if orders are not opened manually, no need to run this function
 int size = ArraySize(SavedOrder);
 if (size == 0) return;
 
 for (int i=size-1; i>=0 && !IsStopped(); i--)
 {
  string message = StringFormat("New %s signal on %s %s",(SavedOrder[i].direction == OP_BUY)? "Buy":"Sell",SavedOrder[i].symbol,TimeFrameToString(PeriodSeconds()));
  if (CSymbolPointer.CreateWindow(message)) return;
 }
}

void EATFA_EA::TradingCriteria(void)
{
 int sym_total = CSymbolPointer.GetSymbolsTotal();
 
 for(int i = 0; i < sym_total && !IsStopped(); i++)
 {
  if (OpenType == SL_MANUAL && CSymbolPointer.IsWindowOpen()) break; // if an order is awaiting confirmation wait for the order to process
  
  //if (!CSymbolPointer.IsNewBar(i)) continue; //if not a new bar on the symbol
  
  SYMBOL symstuct; 
  CSymbolPointer.GetSymStruct(i, symstuct);
  
  if (MarketInfo(symstuct.symbol_name,MODE_SPREAD) > MaxSpread) continue; 
  
  int buy = 0, sell = 0, total = TF.GetPositionCount(symstuct.symbol_name,buy,sell);
  if (total > 0) continue;
  const int shift = 1;                          //indicator shift for trade signals
  
  //buy signals
  bool buy_cond1 = false, buy_cond2 = false, /*buy_cond3 = false,*/ buy_cond4 = false,
       buy_cond5 = false, buy_cond6 = false, buy_cond7 = false;
  
  double fast_ma = 0, slow_ma = 0, point = SymbolInfoDouble(symstuct.symbol_name,SYMBOL_POINT);         //condition 1
  if (!UseCondition1 || (GetFastMa(symstuct.FastMaHandle,shift,fast_ma) && GetSlowMa(symstuct.SlowMaHandle,shift,slow_ma) 
      && fast_ma > slow_ma && fabs(fast_ma - slow_ma) > MAGap * point)) buy_cond1 = true;
  //else PrintFormat("Buy cond 1 not true fast ma %.6f slow ma %.6f shift %d",fast_ma,slow_ma,shift);
      
  double macd_histo = 0, macd_signal = 0;                      //condition 2
  if (!UseCondition2 || (GetMACD(symstuct.MacdHandle,MAIN_LINE,shift,macd_histo) && GetMACD(symstuct.MacdHandle,SIGNAL_LINE,shift,macd_signal)
      && macd_histo > 0.0001 && macd_signal <= macd_histo)) buy_cond2 = true;
  
  /*double macd_histo_prior = 0;                                 //condition 3
  if (!UseCondition3 || (GetMACD(symstuct.MacdHandle,MAIN_LINE,shift+1,macd_histo_prior) && 
      GetMACD(symstuct.MacdHandle,MAIN_LINE,shift,macd_histo) && macd_histo_prior < macd_histo
      && macd_signal > macd_histo_prior && macd_signal <= macd_histo) 
     ) buy_cond3 = true;*/
  
  double stoch_main = 0, stoch_signal = 0, stoch_main_before = 0, stoch_signal_before = 0;                     //condition 4
  if (!UseCondition4 || (GetStoch(symstuct.StochHandle,MAIN_LINE,shift-1,stoch_main) && GetStoch(symstuct.StochHandle,SIGNAL_LINE,shift-1,stoch_signal)
      && GetStoch(symstuct.StochHandle,MAIN_LINE,shift,stoch_main_before) && GetStoch(symstuct.StochHandle,SIGNAL_LINE,shift,stoch_signal_before)
      && stoch_main > stoch_signal && stoch_main_before < stoch_signal_before)) buy_cond4 = true;
  
  if (!UseCondition5 || (GetStoch(symstuct.StochHandle,MAIN_LINE,shift,stoch_main) && stoch_main < StochUpLevel))  //condition 5
  buy_cond5 = true;
  
  double stoch_main_prior = 0;
  if (!UseCondition6 || (GetStoch(symstuct.StochHandle,MAIN_LINE,shift,stoch_main) && 
      GetStoch(symstuct.StochHandle,MAIN_LINE,shift+1,stoch_main_prior) && stoch_main > stoch_main_prior) )  //condition 6
  buy_cond6 = true;
  
  double rsi = 0, rsi_prior = 0;
  if (!UseCondition7 || (GetRSI(symstuct.RsiHandle,shift,rsi) && GetRSI(symstuct.RsiHandle,shift+1,rsi_prior) && 
      rsi > rsi_prior))                                        //condition 7
  buy_cond7 = true;
  
  if (buy_cond1 && buy_cond2 && /*buy_cond3 &&*/ buy_cond4 && buy_cond5 && buy_cond6 && buy_cond7)
  OpenOrder(symstuct.symbol_name,OP_BUY);
  
  //Sell Signals
  bool sell_cond1 = false, sell_cond2 = false, /*sell_cond3 = false,*/ sell_cond4 = false,
       sell_cond5 = false, sell_cond6 = false, sell_cond7 = false;
  
  //fast_ma = 0; slow_ma = 0;                             //condition 1
  if (!UseCondition1 || (GetFastMa(symstuct.FastMaHandle,shift,fast_ma) && GetSlowMa(symstuct.SlowMaHandle,shift,slow_ma) 
      && fast_ma < slow_ma && fabs(fast_ma - slow_ma) > MAGap * point)) sell_cond1 = true;
  //else PrintFormat("Sell cond 1 not true fast ma %.6f slow ma %.6f shift %d",fast_ma,slow_ma,shift);
      
  //double macd_histo = 0, macd_signal = 0;                      //condition 2
  if (!UseCondition2 || (GetMACD(symstuct.MacdHandle,MAIN_LINE,shift,macd_histo) && GetMACD(symstuct.MacdHandle,SIGNAL_LINE,shift,macd_signal)
      && macd_histo < -0.0001 && macd_signal >= macd_histo)) sell_cond2 = true;
  
  /*double macd_histo_prior = 0;                                 //condition 3
  if (!UseCondition3 || (GetMACD(symstuct.MacdHandle,MAIN_LINE,shift+1,macd_histo_prior) && 
      GetMACD(symstuct.MacdHandle,MAIN_LINE,shift,macd_histo) && macd_signal < -0.0001 && macd_histo < -0.0001 && macd_histo_prior < -0.0001 && macd_histo_prior > macd_histo
       && macd_signal < macd_histo_prior) 
     ) sell_cond3 = true;*/
  
  //double stoch_main = 0, stoch_signal = 0;                     //condition 4
  if (!UseCondition4 || (GetStoch(symstuct.StochHandle,MAIN_LINE,shift-1,stoch_main) && GetStoch(symstuct.StochHandle,SIGNAL_LINE,shift-1,stoch_signal)
      && GetStoch(symstuct.StochHandle,MAIN_LINE,shift,stoch_main_before) && GetStoch(symstuct.StochHandle,SIGNAL_LINE,shift,stoch_signal_before)
      && stoch_main < stoch_signal && stoch_main_before > stoch_signal_before)) sell_cond4 = true;
  
  if (!UseCondition5 || (GetStoch(symstuct.StochHandle,MAIN_LINE,shift,stoch_main) && stoch_main > StochLowLevel))  //condition 5
  sell_cond5 = true;
  
  //double stoch_main_prior = 0;
  if (!UseCondition6 || (GetStoch(symstuct.StochHandle,MAIN_LINE,shift,stoch_main) && 
      GetStoch(symstuct.StochHandle,MAIN_LINE,shift+1,stoch_main_prior) && stoch_main < stoch_main_prior) )  //condition 6
  sell_cond6 = true;
  
  //double rsi = 0, rsi_prior = 0;
  if (!UseCondition7 || (GetRSI(symstuct.RsiHandle,shift,rsi) && GetRSI(symstuct.RsiHandle,shift+1,rsi_prior) && 
      rsi < rsi_prior))                                        //condition 7
  sell_cond7 = true;
  
  if (sell_cond1 && sell_cond2 && /*sell_cond3 &&*/ sell_cond4 && sell_cond5 && sell_cond6 && sell_cond7)
  OpenOrder(symstuct.symbol_name,OP_SELL);
  
 }
}


void EATFA_EA::SaveOrder(string symbol,int direction)
{
 int arr_size = ArraySize(SavedOrder);
 ArrayResize(SavedOrder,arr_size+1,10);
 SavedOrder[arr_size].direction = direction;
 SavedOrder[arr_size].symbol = symbol;
 SavedOrder[arr_size].IsSaved = true;
}

void EATFA_EA::DeleteSaveOrder(void)
{
 int size = ArraySize(SavedOrder);
 ArrayRemove(SavedOrder,size-1,1);
}

void EATFA_EA::OpenOrder(string symbol,int direction)
{
 if (OpenType == SL_AUTOMATIC)
 {
  TF.OpenPosition(symbol,direction,LotSize,TradeComment,0,0);
 }
 else if (OpenType == SL_MANUAL)
 {
  SaveOrder(symbol,direction);
 }
}

double EATFA_EA::bid(string symbol)
{
 return SymbolInfoDouble(symbol,SYMBOL_BID);
}

double EATFA_EA::ask(string symbol)
{
 return SymbolInfoDouble(symbol,SYMBOL_ASK);
}

int EATFA_EA::OnInit(void)
{
 //------Check License
 string message = "";
 bool check = License.Password_Check(LicenseKey,message);
 
 if (!check) 
 {
  MessageBox(message,"Invalid or Expired License key");
  return INIT_FAILED;
 }
 Print(message);
 //-------Initialize symbols
 return CSymbolPointer.Init();
}

void EATFA_EA::OnTimer()
{
 //Check License expire date
 if (License.IsExpired())
 {
  int sym_total = CSymbolPointer.GetSymbolsTotal();
  for (int i = sym_total-1; i>=0; i--)
  {
   SYMBOL symstruct;
   CSymbolPointer.GetSymStruct(i,symstruct);
   
   TF.CloseTrades(symstruct.symbol_name,"EA License has expired! Contact vendor for renewal");
  }
 }
 
 UpdateUnAttendedWindow();   //deletes window automatically if left unattended for the specified time
 //Timer();
 if ((OpenType == SL_MANUAL || SLType == SL_MANUAL) && CSymbolPointer.IsWindowOpen()) return; //cancel timer operations if a window is open
 PresentSavedOrders();
 //---
 ManageOrders();
 //---
 TradingCriteria();     //this function contains means to detect if a window was opened while or before it ran
 
}
void EATFA_EA::UpdateUnAttendedWindow(void)
{
 if (CSymbolPointer.IsWindowOpen())
 {
  uint miliOpenTime = CSymbolPointer.GetWindowOpenMiliTime();
  //Print("Window open time ",CSymbolPointer.GetWindowOpenMiliTime()," close time ",miliOpenTime+MaxWindowOpenTime," current time = ",GetTickCount());
  if (GetTickCount() > miliOpenTime+MaxWindowOpenTime)
  {
   CSymbolPointer.DestroyWindow();
   DeleteSaveOrder();
   Print("Dialog window deleted automatically due to timeout");
  }
  else if (miliOpenTime+MaxWindowOpenTime >= UINT_MAX)    //in case coincidentally the window opens just when the timer is about to overfill
  {
   uint elapsed = UINT_MAX - miliOpenTime, tickcount = GetTickCount();
   if (tickcount + elapsed >= MaxWindowOpenTime)
   {
    CSymbolPointer.DestroyWindow();
    DeleteSaveOrder();
    Print("Dialog window deleted automatically due to timeout");
   }
  }
 }
}
void EATFA_EA::SL_Follower(void)
{
 if(TF.IsHedging())
  {
   int pos_total = PositionsTotal();
   for(int i=pos_total-1; i>=0 && !IsStopped(); i--)
   {
    ulong ticket = PositionGetTicket(i);
    if (ticket > 0)
    {
    
     if (PositionGetInteger(POSITION_MAGIC) == MagicNumber)
     {
      string symbol = PositionGetString(POSITION_SYMBOL);
      
      if (HitDollarSL()) continue;
     if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
      {
       switch(PositionProfit(OP_BUY))
        {
        case 1:{
                double current_price = PositionGetDouble(POSITION_PRICE_CURRENT),
                       sl            = PositionGetDouble(POSITION_SL),
                       open_price    = PositionGetDouble(POSITION_PRICE_OPEN),
                       point         = SymbolInfoDouble(symbol,SYMBOL_POINT);
                //if (debug) Print("Case 1 active current price = ",current_price," sl = ",sl," open price ",open_price);
                if (sl > 0 && current_price - sl >= (Step1Dist*point))
                {
                 double new_sl = current_price - (Step1Dist*point);
                 if ( fabs(new_sl - sl) > point)
                 TF.PositionModify(symbol,ticket,new_sl,0);
                }
                else if (sl == 0)
                {//if (debug) Print("Condition 1 sl == 0 active");
                 TF.PositionModify(symbol,ticket,current_price-(Step1Dist*point),0);
                }
               }
         break;
        case 2:{
                double current_price = PositionGetDouble(POSITION_PRICE_CURRENT),
                       sl            = PositionGetDouble(POSITION_SL),
                       open_price    = PositionGetDouble(POSITION_PRICE_OPEN),
                       point         = SymbolInfoDouble(symbol,SYMBOL_POINT);
                if (sl > 0 && current_price - sl >= (Step2Dist*point))
                {
                 double new_sl = current_price - (Step2Dist*point);
                 if ( fabs(new_sl - sl) > point)
                 TF.PositionModify(symbol,ticket,new_sl,0);
                }
                else if (sl == 0)
                {
                 TF.PositionModify(symbol,ticket,current_price-(Step2Dist*point),0);
                }
               }
         break;
        case 3:{
                double current_price = PositionGetDouble(POSITION_PRICE_CURRENT),
                       sl            = PositionGetDouble(POSITION_SL),
                       open_price    = PositionGetDouble(POSITION_PRICE_OPEN),
                       point         = SymbolInfoDouble(symbol,SYMBOL_POINT);
                if (sl > 0 && current_price - sl >= (Step3Dist*point))
                {
                 double new_sl = current_price - (Step3Dist*point);
                 if ( fabs(new_sl - sl) > point)
                 TF.PositionModify(symbol,ticket,new_sl,0);
                }
                else if (sl == 0)
                {
                 TF.PositionModify(symbol,ticket,current_price-(Step3Dist*point),0);
                }
               }
         break;
        case 4:{
                double current_price = PositionGetDouble(POSITION_PRICE_CURRENT),
                       sl            = PositionGetDouble(POSITION_SL),
                       open_price    = PositionGetDouble(POSITION_PRICE_OPEN),
                       point         = SymbolInfoDouble(symbol,SYMBOL_POINT);
                if (sl > 0 && current_price - sl >= (Step4Dist*point))
                {
                 double new_sl = current_price - (Step4Dist*point);
                 if ( fabs(new_sl - sl) > point)
                 TF.PositionModify(symbol,ticket,new_sl,0);
                }
                else if (sl == 0)
                {
                 TF.PositionModify(symbol,ticket,current_price-(Step4Dist*point),0);
                }
               }
         break;
        case 5:{
                double current_price = PositionGetDouble(POSITION_PRICE_CURRENT),
                       sl            = PositionGetDouble(POSITION_SL),
                       open_price    = PositionGetDouble(POSITION_PRICE_OPEN),
                       point         = SymbolInfoDouble(symbol,SYMBOL_POINT);
                if (sl > 0 && current_price - sl >= (Step5Dist*point))
                {
                 double new_sl = current_price - (Step5Dist*point);
                 if ( fabs(new_sl - sl) > point)
                 TF.PositionModify(symbol,ticket,new_sl,0);
                }
                else if (sl == 0)
                {
                 TF.PositionModify(symbol,ticket,current_price-(Step5Dist*point),0);
                }
               }
         break;
        }
      }
     else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
     {switch(PositionProfit(OP_SELL))
        {
        case 1:{
                double current_price = PositionGetDouble(POSITION_PRICE_CURRENT),
                       sl            = PositionGetDouble(POSITION_SL),
                       open_price    = PositionGetDouble(POSITION_PRICE_OPEN),
                       point         = SymbolInfoDouble(symbol,SYMBOL_POINT);
                if (sl > 0 && sl - current_price >= (Step1Dist*point))
                {
                 double new_sl = current_price + (Step1Dist*point);
                 if ( fabs(new_sl - sl) > point)
                 TF.PositionModify(symbol,ticket,new_sl,0);
                }
                else if (sl == 0)
                {
                 TF.PositionModify(symbol,ticket,current_price + (Step1Dist*point),0);
                }
               }
         break;
        case 2:{
                double current_price = PositionGetDouble(POSITION_PRICE_CURRENT),
                       sl            = PositionGetDouble(POSITION_SL),
                       open_price    = PositionGetDouble(POSITION_PRICE_OPEN),
                       point         = SymbolInfoDouble(symbol,SYMBOL_POINT);
                if (sl > 0 && sl - current_price >= (Step2Dist*point))
                {
                 double new_sl = current_price + (Step2Dist*point);
                 if ( fabs(new_sl - sl) > point)
                 TF.PositionModify(symbol,ticket,new_sl,0);
                }
                else if (sl == 0)
                {
                 TF.PositionModify(symbol,ticket,current_price + (Step2Dist*point),0);
                }
               }
         break;
        case 3:{
                double current_price = PositionGetDouble(POSITION_PRICE_CURRENT),
                       sl            = PositionGetDouble(POSITION_SL),
                       open_price    = PositionGetDouble(POSITION_PRICE_OPEN),
                       point         = SymbolInfoDouble(symbol,SYMBOL_POINT);
                if (sl > 0 && sl - current_price >= (Step3Dist*point))
                {
                 double new_sl = current_price + (Step3Dist*point);
                 if ( fabs(new_sl - sl) > point)
                 TF.PositionModify(symbol,ticket,new_sl,0);
                }
                else if (sl == 0)
                {
                 TF.PositionModify(symbol,ticket,current_price + (Step3Dist*point),0);
                }
               }
         break;
        case 4:{
                double current_price = PositionGetDouble(POSITION_PRICE_CURRENT),
                       sl            = PositionGetDouble(POSITION_SL),
                       open_price    = PositionGetDouble(POSITION_PRICE_OPEN),
                       point         = SymbolInfoDouble(symbol,SYMBOL_POINT);
                if (sl > 0 && sl - current_price >= (Step4Dist*point))
                {
                 double new_sl = current_price + (Step4Dist*point);
                 if ( fabs(new_sl - sl) > point)
                 TF.PositionModify(symbol,ticket,new_sl,0);
                }
                else if (sl == 0)
                {
                 TF.PositionModify(symbol,ticket,current_price + (Step4Dist*point),0);
                }
               }
         break;
        case 5:{
                double current_price = PositionGetDouble(POSITION_PRICE_CURRENT),
                       sl            = PositionGetDouble(POSITION_SL),
                       open_price    = PositionGetDouble(POSITION_PRICE_OPEN),
                       point         = SymbolInfoDouble(symbol,SYMBOL_POINT);
                if (sl > 0 && sl - current_price >= (Step5Dist*point))
                {
                 double new_sl = current_price + (Step5Dist*point);
                 if ( fabs(new_sl - sl) > point)
                 TF.PositionModify(symbol,ticket,new_sl,0);
                }
                else if (sl == 0)
                {
                 TF.PositionModify(symbol,ticket,current_price + (Step5Dist*point),0);
                }
               }
         break;
        }
     }
     }
    }
   }
  }
  else
  {
   int sym_total = CSymbolPointer.GetSymbolsTotal();
   for(int i=sym_total-1; i>=0 && !IsStopped(); i--)
   {
    SYMBOL sym_struct;
    CSymbolPointer.GetSymStruct(i,sym_struct);
    
    if (PositionSelect(sym_struct.symbol_name))
    {ulong ticket = PositionGetInteger(POSITION_TICKET);
     string symbol = sym_struct.symbol_name;
     if (PositionGetInteger(POSITION_MAGIC) == MagicNumber)
     {
      if (HitDollarSL()) continue;
      
      if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
      {
       switch(PositionProfit(OP_BUY))
        {
        case 1:{
                double current_price = PositionGetDouble(POSITION_PRICE_CURRENT),
                       sl            = PositionGetDouble(POSITION_PRICE_OPEN),
                       point         = SymbolInfoDouble(symbol,SYMBOL_POINT);
                if (current_price - sl >= (Step1Dist*point)+point)
                {
                 TF.PositionModify(symbol,ticket,current_price-(Step1Dist*point),0);
                }
               }
         break;
        case 2:{
                double current_price = PositionGetDouble(POSITION_PRICE_CURRENT),
                       sl            = PositionGetDouble(POSITION_PRICE_OPEN),
                       point         = SymbolInfoDouble(symbol,SYMBOL_POINT);
                if (current_price - sl >= (Step2Dist*point)+point)
                {
                 TF.PositionModify(symbol,ticket,current_price-(Step2Dist*point),0);
                }
               }
         break;
        case 3:{
                double current_price = PositionGetDouble(POSITION_PRICE_CURRENT),
                       sl            = PositionGetDouble(POSITION_PRICE_OPEN),
                       point         = SymbolInfoDouble(symbol,SYMBOL_POINT);
                if (current_price - sl >= (Step3Dist*point)+point)
                {
                 TF.PositionModify(symbol,ticket,current_price-(Step3Dist*point),0);
                }
               }
         break;
        case 4:{
                double current_price = PositionGetDouble(POSITION_PRICE_CURRENT),
                       sl            = PositionGetDouble(POSITION_PRICE_OPEN),
                       point         = SymbolInfoDouble(symbol,SYMBOL_POINT);
                if (current_price - sl >= (Step4Dist*point)+point)
                {
                 TF.PositionModify(symbol,ticket,current_price-(Step4Dist*point),0);
                }
               }
         break;
        case 5:{
                double current_price = PositionGetDouble(POSITION_PRICE_CURRENT),
                       sl            = PositionGetDouble(POSITION_PRICE_OPEN),
                       point         = SymbolInfoDouble(symbol,SYMBOL_POINT);
                if (current_price - sl >= (Step5Dist*point)+point)
                {
                 TF.PositionModify(symbol,ticket,current_price-(Step5Dist*point),0);
                }
               }
         break;
         default:Print(__FUNCTION__" Position type not defined! type = ",PositionProfit(OP_BUY));
         break;
        }
      }
     else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
     {switch(PositionProfit(OP_SELL))
        {
        case 1:{
                double current_price = PositionGetDouble(POSITION_PRICE_CURRENT),
                       sl            = PositionGetDouble(POSITION_PRICE_OPEN),
                       point         = SymbolInfoDouble(symbol,SYMBOL_POINT);
                if (sl - current_price >= (Step1Dist*point)+point)
                {
                 TF.PositionModify(symbol,ticket,current_price+(Step1Dist*point),0);
                }
               }
         break;
        case 2:{
                double current_price = PositionGetDouble(POSITION_PRICE_CURRENT),
                       sl            = PositionGetDouble(POSITION_PRICE_OPEN),
                       point         = SymbolInfoDouble(symbol,SYMBOL_POINT);
                if (sl - current_price >= (Step2Dist*point)+point)
                {
                 TF.PositionModify(symbol,ticket,current_price+(Step2Dist*point),0);
                }
               }
         break;
        case 3:{
                double current_price = PositionGetDouble(POSITION_PRICE_CURRENT),
                       sl            = PositionGetDouble(POSITION_PRICE_OPEN),
                       point         = SymbolInfoDouble(symbol,SYMBOL_POINT);
                if (sl - current_price >= (Step3Dist*point)+point)
                {
                 TF.PositionModify(symbol,ticket,current_price+(Step3Dist*point),0);
                }
               }
         break;
        case 4:{
                double current_price = PositionGetDouble(POSITION_PRICE_CURRENT),
                       sl            = PositionGetDouble(POSITION_PRICE_OPEN),
                       point         = SymbolInfoDouble(symbol,SYMBOL_POINT);
                if (sl - current_price >= (Step4Dist*point)+point)
                {
                 TF.PositionModify(symbol,ticket,current_price+(Step4Dist*point),0);
                }
               }
         break;
        case 5:{
                double current_price = PositionGetDouble(POSITION_PRICE_CURRENT),
                       sl            = PositionGetDouble(POSITION_PRICE_OPEN),
                       point         = SymbolInfoDouble(symbol,SYMBOL_POINT);
                if (sl - current_price >= (Step5Dist*point)+point)
                {
                 TF.PositionModify(symbol,ticket,current_price+(Step5Dist*point),0);
                }
               }
         break;
        default:Print(__FUNCTION__" Position type not defined! type = ",PositionProfit(OP_SELL));
         break;
        }
     }
     }
    }
   }
  }
 
}

int EATFA_EA::PositionProfit(int type)
{
 if(type == OP_BUY)
 {
  double profit_pips = PositionGetDouble(POSITION_PRICE_CURRENT) - PositionGetDouble(POSITION_PRICE_OPEN);
  profit_pips = profit_pips/SymbolInfoDouble(PositionGetString(POSITION_SYMBOL),SYMBOL_POINT);
  
  if (profit_pips >= (double)Step1Profit && profit_pips < (double)Step2Profit) 
  {
   //if (debug) Print("Step 1 active profit pips = ",profit_pips);
   return 1;
  }
  if (profit_pips >= (double)Step2Profit && profit_pips < (double)Step3Profit) return 2;
  if (profit_pips >= (double)Step3Profit && profit_pips < (double)Step4Profit) return 3;
  if (profit_pips >= (double)Step4Profit && profit_pips < (double)Step5Profit) return 4;
  if (profit_pips >= (double)Step5Profit) return 5;
 }
 else if (type == OP_SELL)
 {
  double profit_pips = PositionGetDouble(POSITION_PRICE_OPEN) - PositionGetDouble(POSITION_PRICE_CURRENT);
  profit_pips = profit_pips/SymbolInfoDouble(PositionGetString(POSITION_SYMBOL),SYMBOL_POINT);
  
  if (profit_pips >= (double)Step1Profit && profit_pips < (double)Step2Profit) return 1;
  if (profit_pips >= (double)Step2Profit && profit_pips < (double)Step3Profit) return 2;
  if (profit_pips >= (double)Step3Profit && profit_pips < (double)Step4Profit) return 3;
  if (profit_pips >= (double)Step4Profit && profit_pips < (double)Step5Profit) return 4;
  if (profit_pips >= (double)Step5Profit) return 5;
 }
 return EMPTY;
}

void EATFA_EA::ManageOrders(void)
{
 SL_Follower();
 
}

bool EATFA_EA::HitDollarSL(void)
{
 double dollarSL = SL;
 if (dollarSL > 0) dollarSL *= -1;
  
 if (PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP) < dollarSL)
 {
  return TF.PositionClose(PositionGetString(POSITION_SYMBOL),PositionGetInteger(POSITION_TICKET),"Position has lost more than the specified amount");
 }
 return false;
}