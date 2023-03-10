#include "rwmake.ch"

/*/

覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		MT410ACE                                                     /@
@type			Ponto de entrada                                             /@
@date			06/01/2012                                                   /@
@description	Ponto de entrada para avaliar se o usu疵io poder? alterar ou
				excluir um determinado pedido de venda                       /@
@author			Adalberto Moreno Batista                                     /@
@use			Espec?fico Brasitech                                         /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?

/*/

User Function MT410ACE()
Local nOpcao	:= PARAMIXB[1]
Local lRet		:= .T.
Local cProcName	:= AllTrim(Upper(ProcName(2)))

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Permite alterar, excluir ou copiar um pedido que nao tiver controle VPC  
// por SI8401 Adalberto Moreno em 06/01/12                                  
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if SC5->(FieldPos("C5_X_VPC")) > 0 .and. FunName() == "MATA410"

	if cProcName $ "A410INCLUI/A410ALTERA/A410DELETA/A410COPIA" .and. SC5->C5_X_VPC == "S"    //MA410RESID/
			
		lRet := .F.
		Help(" ", 1, "ATENﾇﾃO", , "Pedido possui controle VPC e portanto n縊 poder? ser alterado ou excluido. Utilize a rotina de movimenta鈬o VPC." + chr(13) + chr(10) + chr(13) + chr(10) + "(Espec?fico Brasitech). ", 1)
		
	endif
		
endif

Return(lRet)
