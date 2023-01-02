User Function VLAPON() 
//ROMUALDO 11/09/13 - TOTVS-AM
Local _Ctipo := "" 
Local lRet := .T. 

_Ctipo:=  POSICIONE("SB1",1,XFILIAL("SB1")+M->C2_PRODUTO,"B1_TIPO")

	If !(ALLTRIM(_Ctipo) $ "PA/SA/PI")  
		MSGALERT("ABERTURA DE OP SOMENTE PARA TIPOS DE PRODUTOS PA OU SA")
		lRet := .F.
	EndIf

Return lRet