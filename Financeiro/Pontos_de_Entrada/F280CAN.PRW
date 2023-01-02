#Include "protheus.ch"     
#include "rwmake.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		F280CAN                                                       /@
@type				Ponto de entrada                                              /@
@date				06/10/2016                                                    /@
@description	Utilizado na validação do TudoOk, na exclusão do contas a 
					receber.                                                      /@
@author			Adalberto Moreno Batista (Opção Um Consultoria)               /@
@use				Especifico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function F280CAN() 
Local lRet		:= .T.
Local aArea		:= GetArea()

//———————————————————————————————————————————————————————————————————————————————
// Exclui registros na tabela de historico de alteracoes de vencimento de titulos
// a receber (ZZ2).
//	Por: Adalberto Moreno Batista (Opção Um Consultoria) em 30/09/2016
//———————————————————————————————————————————————————————————————————————————————
if SX2->(dbSeek("ZZ2"))

	ZZ2->(dbSetOrder(1))		//ZZ2_FILIAL, ZZ2_PREFIX, ZZ2_NUM, ZZ2_PARCEL, ZZ2_TIPO, ZZ2_CLIENT, ZZ2_LOJA, ZZ2_DTMOV, ZZ2_HRMOV
	ZZ2->(dbSeek(xFilial("ZZ2") + cPrefCan + cFatCan))
	do while ZZ2->(!eof() .and. ZZ2_FILIAL + ZZ2_PREFIX + ZZ2_NUM == xFilial("ZZ2") + cPrefCan + cFatCan)
		if ZZ2->ZZ2_TIPO == cTipoCan
			ZZ2->(RecLock("ZZ2", .F.))
			ZZ2->(dbDelete())
			ZZ2->(MsUnlock())
		endif
		ZZ2->(dbSkip())
	enddo
		
endif

RestArea(aArea)
Return(lRet)
