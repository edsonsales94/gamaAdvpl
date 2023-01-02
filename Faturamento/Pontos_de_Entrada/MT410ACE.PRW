#include "rwmake.ch"

/*/

———————————————————————————————————————————————————————————————————————————————
@function		MT410ACE                                                     /@
@type			Ponto de entrada                                             /@
@date			06/01/2012                                                   /@
@description	Ponto de entrada para avaliar se o usuário poderá alterar ou
				excluir um determinado pedido de venda                       /@
@author			Adalberto Moreno Batista                                     /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————

/*/

User Function MT410ACE()
Local nOpcao	:= PARAMIXB[1]
Local lRet		:= .T.
Local cProcName	:= AllTrim(Upper(ProcName(2)))

//———————————————————————————————————————————————————————————————————————————————
// Permite alterar, excluir ou copiar um pedido que nao tiver controle VPC  
// por SI8401 Adalberto Moreno em 06/01/12                                  
//———————————————————————————————————————————————————————————————————————————————
if SC5->(FieldPos("C5_X_VPC")) > 0 .and. FunName() == "MATA410"

	if cProcName $ "A410INCLUI/A410ALTERA/A410DELETA/A410COPIA" .and. SC5->C5_X_VPC == "S"    //MA410RESID/
			
		lRet := .F.
		Help(" ", 1, "ATENÇÃO", , "Pedido possui controle VPC e portanto não poderá ser alterado ou excluido. Utilize a rotina de movimentação VPC." + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Brasitech). ", 1)
		
	endif
		
endif

Return(lRet)
