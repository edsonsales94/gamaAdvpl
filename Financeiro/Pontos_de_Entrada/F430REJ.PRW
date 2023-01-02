#include "protheus.ch"
#include "totvs.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		F430REJ                                                      /@
@type			Ponto de entrada                                             /@
@date			18/07/2022                                                   /@
@description	Trata os dados de registro rejeitados no processo do retorno
                bancário CNAB, antes de ser atualizado. Rotina FINA430.      /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
                Opção Um Tecnologia da Informação (www.opcaoum.com.br)       /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function F430REJ()

//———————————————————————————————————————————————————————————————————————————————
// Liberar o registro rejeitado para manutenção borderô
//———————————————————————————————————————————————————————————————————————————————
if SE2->(FieldPos("E2_XCNAB"))>0 .and. !empty(SE2->E2_XCNAB)
    SE2->(RecLock("SE2", .F.))
    SE2->E2_XCNAB := " "
    SE2->(MsUnlock())
endif

Return()
