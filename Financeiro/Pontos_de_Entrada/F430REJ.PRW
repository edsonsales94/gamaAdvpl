#include "protheus.ch"
#include "totvs.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		F430REJ                                                      /@
@type			Ponto de entrada                                             /@
@date			18/07/2022                                                   /@
@description	Trata os dados de registro rejeitados no processo do retorno
                banc疵io CNAB, antes de ser atualizado. Rotina FINA430.      /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
                Op鈬o Um Tecnologia da Informa鈬o (www.opcaoum.com.br)       /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function F430REJ()

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Liberar o registro rejeitado para manuten鈬o border?
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if SE2->(FieldPos("E2_XCNAB"))>0 .and. !empty(SE2->E2_XCNAB)
    SE2->(RecLock("SE2", .F.))
    SE2->E2_XCNAB := " "
    SE2->(MsUnlock())
endif

Return()
