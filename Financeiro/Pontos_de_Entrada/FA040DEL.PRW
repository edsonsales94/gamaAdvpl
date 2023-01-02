#Include "protheus.ch"     
#include "rwmake.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		FA040DEL                                                      /@
@type				Ponto de entrada                                              /@
@date				30/09/2016                                                    /@
@description	Utilizado na validação do TudoOk, na exclusão do contas a 
					receber.                                                      /@
@author			Adalberto Moreno Batista (Opção Um Consultoria)               /@
@use				Especifico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function FA040DEL() 
Local lRet		:= .T.
Local aArea		:= GetArea()

//———————————————————————————————————————————————————————————————————————————————
// Exclui registros na tabela de historico de alteracoes de vencimento de titulos
// a receber (ZZ2).
//	Por: Adalberto Moreno Batista (Opção Um Consultoria) em 30/09/2016
//———————————————————————————————————————————————————————————————————————————————
if SX2->(dbSeek("ZZ2"))

	ZZ2->(dbSetOrder(1))		//ZZ2_FILIAL, ZZ2_PREFIX, ZZ2_NUM, ZZ2_PARCEL, ZZ2_TIPO, ZZ2_CLIENT, ZZ2_LOJA, ZZ2_DTMOV, ZZ2_HRMOV
	ZZ2->(dbSeek(xFilial("ZZ2") + SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA)))
	do while ZZ2->(!eof() .and. ZZ2_FILIAL + ZZ2_PREFIX + ZZ2_NUM + ZZ2_PARCEL + ZZ2_TIPO + ZZ2_CLIENT + ZZ2_LOJA == xFilial("ZZ2") + SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA))
		ZZ2->(RecLock("ZZ2", .F.))
		ZZ2->(dbDelete())
		ZZ2->(MsUnlock())
		ZZ2->(dbSkip())
	enddo
		
endif

RestArea(aArea)
return(lRet)
