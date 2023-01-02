#include "rwmake.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		FA050UPD                                                      /@
@date				18/10/2013                                                    /@
@description	Ponto de entrada no fonte FINA050 para avaliar se o registro
					poderá ser excluído                                           /@
@author			Adalberto Moreno Batista - Opção Um Consultoria               /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function FA050UPD()
Local lRet		:= .T.

//——————————————————————————————————————————————————————————————————————————
// Bloqueia a alteração ou exclusão de um título criado pelo processo VPC  
// por: Adalberto Moreno Batista em 18/10/12      
//——————————————————————————————————————————————————————————————————————————
if !INCLUI .and. !ALTERA
	if SE2->(FieldPos("E2_X_VPC")) > 0 .and. FunName() != "BFATA03"
	
		if !Empty(SE2->E2_X_VPC)
		
			lRet := .F.
			Help(" ", 1, "ATENÇÃO",, "Título possui controle VPC e portanto não poderá ser excluido. Utilize a rotina de movimentação VPC." + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Brasitech).", 1)
		
		endif
		
	endif
endif

//GMIFIN00 - Gatilho do cod.rec. da guia de recolhimento do ICMS - Cosme Nunes
If FindFunction("U_GMIFIN00") //Gatilhar cod. rec. da guia de recolhimento
    _lRet := U_GMIFIN00()
Endif	

Return(lRet)
   