#include "rwmake.ch"

/*/
�������������������������������������������������������������������������������
@function		F040BLQ                                                       /@
@date				06/01/2012                                                    /@
@description	Ponto de entrada no fonte FINA040 para avaliar se o registro
					poder� ou n�o ser exclu�do                                    /@
@author			Adalberto Moreno Batista                                      /@
@use				Espec�fico Brasitech                                          /@
�������������������������������������������������������������������������������
/*/
User Function F040BLQ()
Local lRet		:= .T.

//�������������������������������������������������������������������������
// Bloqueia a alteracao ou exclusao de um titulo criado pelo processo VPC 
// por Adalberto Moreno Batista em 06/01/12                                 
//�������������������������������������������������������������������������
if !INCLUI .and. !ALTERA
	if SE1->(FieldPos("E1_X_VPC")) > 0 .and. FunName() != "BFATA03"
	
		if !Empty(SE1->E1_X_VPC)
		
			lRet := .F.
			Help(" ", 1, "ATEN��O",, "T�tulo possui controle VPC e portanto n�o poder� ser excluido. Utilize a rotina de movimenta��o VPC." + chr(13) + chr(10) + chr(13) + chr(10) + "(Espec�fico Brasitech).", 1)
		
		endif
			
	endif
endif

Return(lRet)