
#Include 'Protheus.ch'

User Function MA330CP()

LOCAL aRegraCP:={}
 
AADD(aRegraCP,"SB1->B1_TIPO == 'MP' .AND. SB1->B1_ORIGEM<>'1'")
AADD(aRegraCP,"SB1->B1_TIPO == 'EM'")
AADD(aRegraCP,"SB1->B1_TIPO == 'MP' .AND. SB1->B1_ORIGEM=='1'")   //MATERIAL IMPORTADO
AADD(aRegraCP,"SB1->B1_TIPO == 'ZZ'")   //PARTE NAO VAI SER USADA
AADD(aRegraCP,"LEFT(SB1->B1_COD,4) == 'MOD7'")   //GIF
AADD(aRegraCP,"LEFT(SB1->B1_COD,4) == 'MOD8'")   //MOI
AADD(aRegraCP,"LEFT(SB1->B1_COD,4) == 'MOD9'")   //MOD

Return aRegraCP 



//User Function A330E6CP()
//Local lRet := .F.
//Return lRet
