#property copyright "Copyright 2021, Achref sayadi "
#property link      "mailto:sayadigroup@gmail.com"

string Key = "pqH%4$yui_PQ=";
ENUM_CRYPT_METHOD crypt_method = CRYPT_BASE64;

class Crypter
{
   
   public :
   
      Crypter( void );
               
      ~Crypter( void );

      string EnCrypt
      (
         ENUM_CRYPT_METHOD method,
         string toKey,
         string toEnCrypt
      
      );
      
      string DeCrypt
      (
         ENUM_CRYPT_METHOD method,
         string toKey,
         string toDeCrypt
      
      );

};

Crypter::Crypter( void ){ /* TODO */ };
Crypter::~Crypter( void ){ /* TODO */ };

string Crypter::EnCrypt(ENUM_CRYPT_METHOD method, string toKey, string toEnCrypt)
{

   uchar src[],dst[],key[];
   
   StringToCharArray( toKey, key, 0, StringLen( toKey ) );
   StringToCharArray( toEnCrypt,src, 0, StringLen( toEnCrypt ) );

   int res = CryptEncode( method, src, key, dst );
   
   return ( res > 0 ) ? CharArrayToString( dst ) : "";

};

string Crypter::DeCrypt(ENUM_CRYPT_METHOD method,string toKey,string toDeCrypt)
{

   uchar src[],dst[],key[];
   
   StringToCharArray( toKey, key, 0, StringLen( toKey ) );
   StringToCharArray( toDeCrypt, src, 0, StringLen( toDeCrypt ) );   

   int res = CryptDecode( method, src, key, dst );

   return ( res > 0 ) ? CharArrayToString( dst ) : "";

};