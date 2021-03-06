#property copyright "Copyright 2021, Achref sayadi "
#property link      "mailto:sayadigroup@gmail.com"


#property script_show_inputs
#define   Version  "1.00"
#include <\\EATFA\\Crypt.mqh>

input int      UserAccount = 0;                 //Saisissez votre numéro de compte d'utilisateur | Enter User Account Number
input datetime Expire = D'2019.10.22';          //Entrez la date d'expiration de la clé de licence | Enter Expiry date for License key

Crypter Encrypter;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   string client = (string)UserAccount+"_"+TimeToString(Expire),
          password = Encrypter.EnCrypt(crypt_method,Key,client);
   
   Alert(StringFormat("Generated password for account %d valid till %s is \n%s",UserAccount,TimeToString(Expire),password));
   MessageBox(StringFormat("Password for user account %d valid till %s is \n%s",UserAccount,TimeToString(Expire),password),"Mot de passe généré | Password Generated");
   
  }
//+------------------------------------------------------------------+