#include "protheus.ch"
#include "totvs.ch"

/*/
�������������������������������������������������������������������������������
@function		FA300REJ                                                     /@
@type			Ponto de entrada                                             /@
@date			18/07/2022                                                   /@
@description	Permite a grava��o de informa��es adicionais do t�tulo a 
                pagar que foi rejeitado no processo de retorno Sispag. No 
                momento da chamada deste ponto de entrada, o t�tulo rejeitado
                est� posicionado na base de dados de t�tulos a pagar (SE2).  /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
                Op��o Um Tecnologia da Informa��o (www.opcaoum.com.br)       /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
/*/
User Function FA300REJ()

//�������������������������������������������������������������������������������
// Liberar o registro rejeitado para manuten��o border�
//�������������������������������������������������������������������������������
if SE2->(FieldPos("E2_XCNAB"))>0
    SE2->(RecLock("SE2", .F.))
    SE2->E2_XCNAB := " "
    SE2->(MsUnlock())
endif

Return()