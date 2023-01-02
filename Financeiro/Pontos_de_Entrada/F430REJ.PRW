#include "protheus.ch"
#include "totvs.ch"

/*/
�������������������������������������������������������������������������������
@function		F430REJ                                                      /@
@type			Ponto de entrada                                             /@
@date			18/07/2022                                                   /@
@description	Trata os dados de registro rejeitados no processo do retorno
                banc�rio CNAB, antes de ser atualizado. Rotina FINA430.      /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
                Op��o Um Tecnologia da Informa��o (www.opcaoum.com.br)       /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
/*/
User Function F430REJ()

//�������������������������������������������������������������������������������
// Liberar o registro rejeitado para manuten��o border�
//�������������������������������������������������������������������������������
if SE2->(FieldPos("E2_XCNAB"))>0 .and. !empty(SE2->E2_XCNAB)
    SE2->(RecLock("SE2", .F.))
    SE2->E2_XCNAB := " "
    SE2->(MsUnlock())
endif

Return()