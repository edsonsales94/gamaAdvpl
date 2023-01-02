#include "rwmake.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		F040BLQ                                                       /@
@date				06/01/2012                                                    /@
@description	Ponto de entrada no fonte FINA040 para avaliar se o registro
					poderá ou não ser excluído                                    /@
@author			Adalberto Moreno Batista                                      /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function F040BLQ()
Local lRet		:= .T.

//—————————————————————————————————————————————————————————————————————————
// Bloqueia a alteracao ou exclusao de um titulo criado pelo processo VPC 
// por Adalberto Moreno Batista em 06/01/12                                 
//—————————————————————————————————————————————————————————————————————————
if !INCLUI .and. !ALTERA
	if SE1->(FieldPos("E1_X_VPC")) > 0 .and. FunName() != "BFATA03"
	
		if !Empty(SE1->E1_X_VPC)
		
			lRet := .F.
			Help(" ", 1, "ATENÇÃO",, "Título possui controle VPC e portanto não poderá ser excluido. Utilize a rotina de movimentação VPC." + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Brasitech).", 1)
		
		endif
			
	endif
endif

Return(lRet)
