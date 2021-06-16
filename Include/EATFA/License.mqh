

#property copyright "Copyright 2021, Achref sayadi "
#property link      "mailto:sayadigroup@gmail.com"


#include <\\EATFA\\Crypt.mqh>
class CLicense
  {Crypter *Encrypt;
   datetime Expire_Time;
public:
                     CLicense(void){ Encrypt = new Crypter(); Expire_Time = 0;};
                    ~CLicense(void){delete Encrypt;};
   bool              Password_Check(string InputPassword, string &message);
   bool              IsExpired();
  };

bool CLicense::Password_Check(string InputPassword, string &message)
{
   message = "";
   if (StringLen(InputPassword) == 0 || InputPassword == "") 
   {
    message = "Enter Password! Password cannot be empty";
    return false;
   }
   //--- print decoded data
   string decoded_pass = Encrypt.DeCrypt(crypt_method,Key,InputPassword);
   //--- check error     
   //if(decoded_pass != "")
     {
      
//------------Check password
      int find = StringFind(decoded_pass,"_");
      if (find < 0)
      {
       message = "Invalid Password! Ensure password is typed correctly";
       return false;
      }
      string acc = StringSubstr(decoded_pass,0,find);
//------------Check if the same account
      if (acc != (string)AccountInfoInteger(ACCOUNT_LOGIN))
      {
       message = "Cannot use license with this account! Contact vendor for license";
       return false;
      }
      string s_expire = StringSubstr(decoded_pass,find+1);
      datetime expire = StringToTime(s_expire);
//----------Check Time validity
      if (TimeCurrent() > expire)
      {
       message = "License expired! Contact vendor for renewal";
       return false;
      }
//----------Success
      message = "License verification successful! License will expire on "+s_expire;
      Expire_Time = expire;
      return true;
     }
   //else
     // Print("Error in CryptDecode. Error code=",GetLastError());
 return false;
}
bool CLicense::IsExpired(void)
{
 if (TimeCurrent() > Expire_Time)
 {
  return true;
 }
 return false;
}