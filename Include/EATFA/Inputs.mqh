#property copyright "Copyright 2021, Achref sayadi "
#property link      "mailto:sayadigroup@gmail.com"

enum ENUM_SL_FOLLOWER
  {
   SL_AUTOMATIC, //Mode Automatique
   SL_MANUAL     //Mode Manuel 
   
  };

input string                        hint7                = "------Code Activation Settings----";      //Code activation EA 
input string                        LicenseKey           = "";                                        //Entrer la clé de licence | Enter Licence Key
input string                        hint                 = "--------Indicator Setups--------";        //Les setups indicateurs

input string                        hint1                = "--------Bullish MA Settings-----";        //Moyenne Mobile Haussière : (MMH)
input int                           MAGap                = 10;                                        //Moving Average Gap
input int                           FastMAPeriod         = 34;                                        //Periode
input int                           FastMAShift          = 0;                                         //Décalage
input ENUM_MA_METHOD                FastMAMethod         = MODE_EMA;                                  //Methode
input ENUM_APPLIED_PRICE            FastMAPrice          = PRICE_CLOSE;                               //Appliquer à

input string                        hint2                = "--------Bearish MA Settings-----";        //Moyenne mobile Baissière : (MMB)
input int                           SlowMAPeriod         = 55;                                        //Periode
input int                           SlowMAShift          = 0;                                         //Décalage
input ENUM_MA_METHOD                SlowMAMethod         = MODE_EMA;                                  //Methode
input ENUM_APPLIED_PRICE            SlowMAPrice          = PRICE_CLOSE;                               //Appliquer à

input string                        hint3                = "----------MACD Settings---------";        //MACD
input int                           MacdFastEMA          = 2;                                        //EMA Rapide
input int                           MacdSlowEMA          = 35;                                        //EMA Lente
input int                           MacdSMA              = 2;                                        //MACD SMA
input ENUM_APPLIED_PRICE            MacdPrice            = PRICE_CLOSE;                               //Appliquer à

input string                        hint4                = "---------Stochastic Settings-----";       //STOCHASTIQUE Oscillator 
input int                           StochasticPeriodK    = 14;                                        //Periode %K
input int                           StochasticPeriodD    = 3;                                         //Periode %D
input int                           StochasticSlowDown   = 3;                                         //Ralentissement
input ENUM_STO_PRICE                StochasticPrice      = STO_LOWHIGH;                               //Prix
input ENUM_MA_METHOD                StochasticMethod     = MODE_SMA;                                  //Methode
input double                        StochUpLevel         = 80;                                        //Niveau Up
input double                        StochLowLevel        = 20;                                        //Niveau Low

input string                        hint5                = "----------RSI Settings-----------";       //RSI
input int                           RsiPeriod            = 14;                                        //Periode
input ENUM_APPLIED_PRICE            RsiPrice             = PRICE_CLOSE;                               //Appliquer à
input double                        RsiUpLevel           = 70;                                        //Niveaux Up
input double                        RsiDownLevel         = 30;                                        //Niveaux Down

input string                        hint6                = "-----Timeframe & SL Settings-----";       //Unité de temps & SL
input ENUM_TIMEFRAMES               Timeframe            = PERIOD_M5;                                 //Unité de temps
input double                        LotSize              = 1.0;                                       //Lot de
input double                        SL                   = -60;                                       //Stop Loss
input ENUM_SL_FOLLOWER              SLType               = SL_AUTOMATIC;                              //SL Suiveur
input ENUM_SL_FOLLOWER              OpenType             = SL_AUTOMATIC;                              //Mode d'ouverture de commerce

input string                        hint8                = "---------General Settings---------";      //General Settings
input int                           MagicNumber          = 79837384;                                  //Magic Number
input string                        Pairs                = "EURUSD,EURGBP,EURJPY,EURCHF,EURNZD,EURCAD,"
                                                           "EURAUD,USDCAD,USDCHF,USDJPY,NZDJPY,NZDUSD,"
                                                           "GBPUSD,GBPAUD,GBPCHF,GBPJPY,GBPCAD,GBPNZD,"
                                                           "AUDCHF,AUDJPY,AUDCAD,AUDNZD,AUDUSD,CADJPY,"
                                                           "CHFJPY,CADCHF";                           //Pairs To Trade On (Separated by commas ",")
//input string                        Prefix               = "";                                        //Broker Prefix
input int                           MaxSpread            = 20;                                        //Max Spread (in pippetes/points)
      uint                          MaxWindowOpenTime    = 5000;                                      //Max Time Window can be active in milliseconds
input string                        hint9                = "-------5 Step SL Follower Settings-----"; //5 Paramétrages de « Pas »

input int                           Step1Profit          = 10;                                        //Step 1 Profit (in points)
input int                           Step1Dist            = 20;                                        //Step 1 SL Distance (in points)

input int                           Step2Profit          = 20;                                        //Step 2 Profit (in points)
input int                           Step2Dist            = 20;                                        //Step 2 SL Distance (in points)

input int                           Step3Profit          = 30;                                        //Step 3 Profit (in points)
input int                           Step3Dist            = 10;                                        //Step 3 SL Distance (in points)

input int                           Step4Profit          = 40;                                        //Step 4 Profit (in points)
input int                           Step4Dist            = 10;                                        //Step 4 SL Distance (in points)

input int                           Step5Profit          = 50;                                        //Step 5 Profit (in points)
input int                           Step5Dist            = 5;                                        //Step 5 SL Distance (in points)

input bool                          UseCondition1        = true;                                      //Use Condition 1
input bool                          UseCondition2        = true;                                      //Use Condition 2
//input bool                          UseCondition3        = true;                                      //Use Condition 3
input bool                          UseCondition4        = true;                                      //Use Condition 4
input bool                          UseCondition5        = true;                                      //Use Condition 5
input bool                          UseCondition6        = true;                                      //Use Condition 6
input bool                          UseCondition7        = true;                                      //Use Condition 7