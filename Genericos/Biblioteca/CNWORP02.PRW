#include 'Ap5Mail.ch'
#INCLUDE "PROTHEUS.CH"
//#INCLUDE "rwmake.ch" 
//#Include "TOPCONN.CH"
//#Include "TBICONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCNWORP02  บAutor  ณClaudio             บ Data ณ  19/10/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina que envia email pelo sistema das Solicita็๕es       บฑฑ
ฑฑบ          ณ de Compras                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


User Function CNWORP02(cTitulo,cMens,cEmail)
	Local cAccount,cServer,cPass,cMsg
	cFrom    := GetMv("MV_RELFROM")  //Conta de e-mail para valida็ใo
	cAccount := GetMv("MV_RELACNT")  //Conta de e-mail utilizada para enviar os relatorios do afrrm
	cServer  := GetMv("MV_RELSERV")  // IP do Servidor de e-mails 
	cPass    := GetMv("MV_RELPSW")   // Senha da Conta de E-Mail para envio de relatorios   
    
    CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPass RESULT lResult
	If lResult
	  	If GetMv("MV_RELAUTH") //lRelauth / Servidor de EMAIL necessita de Autenticacao?      
			lRet:= Mailauth(cAccount,alltrim(cPass))
   		Else
			lRet:= .T.
	 	Endif
		If lRet
			cSubject:= cTitulo
			SEND MAIL FROM cFrom;
			TO cEmail; 
			SUBJECT cSubject ;
			BODY cMens
			DISCONNECT SMTP SERVER      
		Else
			qout("Error de autenticacao")
		EndIf 
	Else
		GET MAIL ERROR cErrorMsg   
		qout("Erro - "+ cErrorMsg)
	EndIf
Return 