#property copyright "Copyright 2021, Achref sayadi "
#property link      "mailto:sayadigroup@gmail.com"



#include "Inputs.mqh"
#include "Alert.mqh"
struct SYMBOL
     {
      string symbol_name;
      
      int      RsiHandle;
      int      StochHandle;
      int      FastMaHandle;
      int      SlowMaHandle;
      int      MacdHandle;
      datetime LastBarTime;
      
      double   point;
      
      SYMBOL();
      
      bool     IsNewBar();
     };
   
class CSymbols : public CAlerts
  {
   enum ENUM_INDICATOR_NAME
     {
      RSI,     //Relative strength index
      MACD,    //Moving Average Convergence Divergence
      STOCH,   //Stochastic
      FAST_MA, //Fast Moving Average
      SLOW_MA  //Slow Moving Average
     };
   string Symbols[];
   
   SYMBOL SymStruct[];
   
   int    SplitSymbols();
   int    SelectAllSymbols();
   int    GetIndicatorHandle(ENUM_INDICATOR_NAME name, string symbol);
   
   void   RequestSymbolData(); //Keep a timely request of symbol data to avoid symbol data from being deleted in market watch
   void   AssignHandles();
   
public:
                     CSymbols(void){};
                    ~CSymbols(void){};
   int    Init();
   int    GetSymbolsTotal(){return ArraySize(SymStruct);};
   
   void   Timer();
   
   void   GetSymStruct(int index, SYMBOL &symstruct);
   
   bool   IsNewBar(int index){return SymStruct[index].IsNewBar();}
  };

void CSymbols::GetSymStruct(int index,SYMBOL &symstruct)
{
 if (index < GetSymbolsTotal())
 {symstruct = SymStruct[index];
 }
 else Print(__FUNCTION__" Array out of range! Index is greater than array size");
}

int CSymbols::Init(void)
{
 return SplitSymbols();
}

int CSymbols::SplitSymbols(void)
{
 ushort Char  = StringGetCharacter(",",0);
 int    split = StringSplit(Pairs,Char,Symbols);
 if (split <= 0)
 {
  if (Pairs == "" || Pairs == NULL)
  {
   Alert("No tradeable symbols found! Please enter pairs to trade on");
   return INIT_FAILED;
  }
  else 
  {
   Alert("EA Could not generate tradeable symbols! Please check that you have typed it correctly");
   return INIT_FAILED;
  }
  
 }
 return SelectAllSymbols();
}

void CSymbols::AssignHandles(void)
{
 int arr_size = ::ArraySize(Symbols);
 ArrayResize(SymStruct,arr_size);
 
 for(int i=arr_size-1; i>=0; i--)
 {
  SymStruct[i].symbol_name = Symbols[i];
  
  //PrintFormat("index %d Symbol name %s",i,SymStruct[i].symbol_name);
  
  if (SymStruct[i].RsiHandle    == INVALID_HANDLE) SymStruct[i].RsiHandle    = GetIndicatorHandle(RSI,SymStruct[i].symbol_name);
  if (SymStruct[i].StochHandle  == INVALID_HANDLE) SymStruct[i].StochHandle  = GetIndicatorHandle(STOCH,SymStruct[i].symbol_name);
  if (SymStruct[i].MacdHandle   == INVALID_HANDLE) SymStruct[i].MacdHandle   = GetIndicatorHandle(MACD,SymStruct[i].symbol_name);
  if (SymStruct[i].FastMaHandle == INVALID_HANDLE) SymStruct[i].FastMaHandle = GetIndicatorHandle(FAST_MA,SymStruct[i].symbol_name);
  if (SymStruct[i].SlowMaHandle == INVALID_HANDLE) SymStruct[i].SlowMaHandle = GetIndicatorHandle(SLOW_MA,SymStruct[i].symbol_name);
  
  SymStruct[i].point = SymbolInfoDouble(SymStruct[i].symbol_name,SYMBOL_POINT);
 }
}

int CSymbols::SelectAllSymbols(void)
{
 int arr_size = ::ArraySize(Symbols), not_found = 0;
 
 
 for(int i=arr_size-1; i>=0 ; i--)
   {
    ResetLastError();
    bool select = SymbolSelect(Symbols[i],true);
    if (!select) 
    {
     PrintFormat("Could not select symbol %s %d",Symbols[i],GetLastError());
     not_found++;
     ArrayRemove(Symbols,i,1);
    }
   }
 if (not_found >= arr_size/2 && arr_size > 2)
 {
  Alert("Majority of symbols could not be selected! Please check you typed the symbols correctly. "
        "Each currency pair should be seperated by a comma (,) and no space in between."
       );
  //return INIT_FAILED;
 }
 AssignHandles();
 //Print("INIT SUCCEDDED");
 return INIT_SUCCEEDED;
}

void CSymbols::RequestSymbolData(void)
{
 int arr_size = ArraySize(Symbols);
 
 for (int i = arr_size; i >= 0; i--)
 {
  double open = iOpen(Symbols[i],Timeframe,1),
         high = iHigh(Symbols[i],Timeframe,1),
         low  = iLow(Symbols[i],Timeframe,1),
         close= iClose(Symbols[i],Timeframe,1);
         
  int bars = iBars(Symbols[i],Timeframe);
 }
}

int CSymbols::GetIndicatorHandle(ENUM_INDICATOR_NAME name,string symbol)
{
 switch(name)
   {
   case RSI       : return iRSI(symbol,Timeframe,RsiPeriod,RsiPrice);
      break;
   case MACD      : return iMACD(symbol,Timeframe,MacdFastEMA,MacdSlowEMA,MacdSMA,MacdPrice);
      break;
   case STOCH     : return iStochastic(symbol,Timeframe,StochasticPeriodK,StochasticPeriodD,StochasticSlowDown,StochasticMethod,StochasticPrice);
      break;
   case FAST_MA   : return iMA(symbol,Timeframe,FastMAPeriod,FastMAShift,FastMAMethod,FastMAPrice);
      break;
   case SLOW_MA   : return iMA(symbol,Timeframe,SlowMAPeriod,SlowMAShift,SlowMAMethod,SlowMAPrice);
      break;
    default: Print("Unknown Indicator type");
      break;
   }
 return INVALID_HANDLE;
}

void CSymbols::Timer(void)
{
 RequestSymbolData();
}

SYMBOL::SYMBOL(void)
{MacdHandle    = INVALID_HANDLE;
 RsiHandle     = INVALID_HANDLE;
 FastMaHandle  = INVALID_HANDLE;
 SlowMaHandle  = INVALID_HANDLE;
 StochHandle   = INVALID_HANDLE;
 LastBarTime   = 0;
}
bool SYMBOL::IsNewBar(void)
{
 if(LastBarTime == 0)
 {
  LastBarTime = iTime(symbol_name,Timeframe,0);
  return false;
 }
 else 
 {
  datetime now = iTime(symbol_name,Timeframe,0);
  if (LastBarTime != now)
  {
   LastBarTime = now;
   return true;
  }
 }
 return false;
}