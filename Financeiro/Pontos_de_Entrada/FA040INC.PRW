#Include "protheus.ch"     
#include "rwmake.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		FA040INC                                                      /@
@type				Ponto de entrada                                              /@
@date				30/09/2016                                                    /@
@description	Utilizado na validação do TudoOk, na inclusão do contas a 
					receber.                                                      /@
@author			Adalberto Moreno Batista (Opção Um Consultoria)               /@
@use				Especifico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function FA040INC() 
Local lRet		:= .T.
Local aArea		:= GetArea()
Local cTpTit	:= GetMV("BR_HISTVCT", .F., "")

ZZ2->(dbSetOrder(1))		//ZZ2_FILIAL, ZZ2_PREFIX, ZZ2_NUM, ZZ2_PARCEL, ZZ2_TIPO, ZZ2_CLIENT, ZZ2_LOJA, ZZ2_DTMOV, ZZ2_HRMOV

if SE1->(FieldPos("E1_XVCTORI")) > 0 .and.;
	SX2->(dbSeek("ZZ2")) .and.;
	M->E1_TIPO $ cTpTit .and.;
	ZZ2->(!dbSeek(xFilial("ZZ2") + M->E1_PREFIXO + M->E1_NUM + M->E1_PARCELA + M->E1_TIPO + M->E1_CLIENTE + M->E1_LOJA))
	
	M->E1_XVCTORI := M->E1_VENCTO

	ZZ2->(RecLock("ZZ2", .T.))
	ZZ2->ZZ2_FILIAL	:= xFilial("ZZ2")
	ZZ2->ZZ2_PREFIX	:= M->E1_PREFIXO
	ZZ2->ZZ2_NUM		:= M->E1_NUM
	ZZ2->ZZ2_PARCEL	:= M->E1_PARCELA
	ZZ2->ZZ2_TIPO		:= M->E1_TIPO
	ZZ2->ZZ2_CLIENT	:= M->E1_CLIENTE
	ZZ2->ZZ2_LOJA		:= M->E1_LOJA
	ZZ2->ZZ2_DTMOV		:= Date()
	ZZ2->ZZ2_HRMOV		:= Time()
	ZZ2->ZZ2_USUMOV	:= cUserName
	ZZ2->ZZ2_VENORI	:= M->E1_XVCTORI
	ZZ2->ZZ2_VENCTO	:= M->E1_VENCTO
	ZZ2->ZZ2_VENREA	:= M->E1_VENCREA
	ZZ2->ZZ2_MOTIVO	:= "01"	
	ZZ2->(MsUnlock())
		
endif

RestArea(aArea)
return(lRet)
