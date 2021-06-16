
#property copyright "Copyright 2021, Achref sayadi "
#property link      "mailto:sayadigroup@gmail.com"
#property strict

#include <\\ChartObjects\\ChartObjectsTxtControls.mqh>

class CAlerts : public CChartObjectRectLabel
  {
   bool           WindowActive;
   
   uint           WindowMilliOpenTime; //Window Open time in millisecond
   
   string         Prefix;
   string         YesButtonName;
   string         NoButtonName;
   
   bool           CreateButton(string name, string text, int x, int y);
   bool           CreateLabel(string name, string text, color col, int x, int y);
   
public:
                     CAlerts(void);
                    ~CAlerts(void){ObjectsDeleteAll(0,Prefix);};
   bool           CreateWindow(string message);
   bool           IsWindowOpen(){ return WindowActive; };
   
   uint           GetWindowOpenMiliTime(){ return WindowMilliOpenTime;};
   
   void           DestroyWindow();
   
   string         GetYesBName(){return YesButtonName;};
   string         GetNoBName(){return NoButtonName;};
  };

CAlerts::CAlerts(void)
{
 Prefix = "EATFA_Alerts_";
 WindowActive = false;
 WindowMilliOpenTime = 0;
 YesButtonName = Prefix+"_yes";
 NoButtonName  = Prefix+"_no";
}

bool CAlerts::CreateWindow(string message)
{color txt_col = clrWhite;
 int x = 300, y = 100, x_size = 350, y_size = 150;
 if (Create(0,Prefix+"rect",0,x,y,x_size,y_size))
 {
  BackColor(clrRed);
  Background(false);
  
  CreateButton(YesButtonName, "Yes", x+130,y+130);
  CreateButton(NoButtonName, "No", x+180,y+130);
  
  CreateLabel(Prefix+"text",message,txt_col,x,y);
  CreateLabel(Prefix+"option","Do you want to proceed with trade?",txt_col,x,y+50);
  
  Print(message);
  ChartRedraw();
  
  PlaySound("alert.wav");
  
  WindowActive = true;
  WindowMilliOpenTime = GetTickCount();
  
  return true;
 }
 return false;
}

void CAlerts::DestroyWindow()
{
 ObjectsDeleteAll(0,Prefix);
 WindowActive = false;
 ChartRedraw();
}

bool CAlerts::CreateButton(string name, string text, int x, int y)
{
 if(ObjectFind(0,name) < 0)
 {
  ObjectCreate(0,name,OBJ_BUTTON,0,0,0);
 }
 ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
 ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
 ObjectSetInteger(0,name,OBJPROP_WIDTH,10);
 ObjectSetString(0,name,OBJPROP_TEXT,text);
 return true;
}

bool CAlerts::CreateLabel(string name,string text, color col, int x,int y)
{
 if(ObjectFind(0,name) < 0)
 {
  ObjectCreate(0,name,OBJ_LABEL,0,0,0);
 }
 ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
 ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
 ObjectSetInteger(0,name,OBJPROP_WIDTH,10);
 ObjectSetString(0,name,OBJPROP_TEXT,text);
 ObjectSetInteger(0,name,OBJPROP_COLOR,col);
 ObjectSetInteger(0,name,OBJPROP_FONTSIZE,14);
 return true;
}