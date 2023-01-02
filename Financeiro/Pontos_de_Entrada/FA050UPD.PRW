#include "rwmake.ch"

/*/
�������������������������������������������������������������������������������
@function		FA050UPD                                                      /@
@date				18/10/2013                                                    /@
@description	Ponto de entrada no fonte FINA050 para avaliar se o registro
					poder� ser exclu�do                                           /@
@author			Adalberto Moreno Batista - Op��o Um Consultoria               /@
@use				Espec�fico Brasitech                                          /@
�������������������������������������������������������������������������������
/*/
User Function FA050UPD()
Local lRet		:= .T.

//��������������������������������������������������������������������������
// Bloqueia a altera��o ou exclus�o de um t�tulo criado pelo processo VPC  
// por: Adalberto Moreno Batista em 18/10/12      
//��������������������������������������������������������������������������
if !INCLUI .and. !ALTERA
	if SE2->(FieldPos("E2_X_VPC")) > 0 .and. FunName() != "BFATA03"
	
		if !Empty(SE2->E2_X_VPC)
		
			lRet := .F.
			Help(" ", 1, "ATEN��O",, "T�tulo possui controle VPC e portanto n�o poder� ser excluido. Utilize a rotina de movimenta��o VPC." + chr(13) + chr(10) + chr(13) + chr(10) + "(Espec�fico Brasitech).", 1)
		
		endif
		
	endif
endif

//GMIFIN00 - Gatilho do cod.rec. da guia de recolhimento do ICMS - Cosme Nunes
If FindFunction("U_GMIFIN00") //Gatilhar cod. rec. da guia de recolhimento
    _lRet := U_GMIFIN00()
Endif	

Return(lRet)
   