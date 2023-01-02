#include "RwMake.ch"

User Function M460FIL()
Local cRetorno := ""

   cRetorno += "C9_LOCAL >= '" + MV_PAR17 + "' .AND. C9_LOCAL <= '" + MV_PAR18 + "'"

Return cRetorno 
