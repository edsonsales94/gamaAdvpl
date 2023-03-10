#include "rwmake.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		F040BLQ                                                       /@
@date				06/01/2012                                                    /@
@description	Ponto de entrada no fonte FINA040 para avaliar se o registro
					poder? ou n縊 ser exclu?do                                    /@
@author			Adalberto Moreno Batista                                      /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function F040BLQ()
Local lRet		:= .T.

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Bloqueia a alteracao ou exclusao de um titulo criado pelo processo VPC 
// por Adalberto Moreno Batista em 06/01/12                                 
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if !INCLUI .and. !ALTERA
	if SE1->(FieldPos("E1_X_VPC")) > 0 .and. FunName() != "BFATA03"
	
		if !Empty(SE1->E1_X_VPC)
		
			lRet := .F.
			Help(" ", 1, "ATENﾇﾃO",, "T?tulo possui controle VPC e portanto n縊 poder? ser excluido. Utilize a rotina de movimenta鈬o VPC." + chr(13) + chr(10) + chr(13) + chr(10) + "(Espec?fico Brasitech).", 1)
		
		endif
			
	endif
endif

Return(lRet)
