#include "protheus.ch"
#include "totvs.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		FA420CRI                                                     /@
@type			Ponto de entrada                                             /@
@date			18/07/2022                                                   /@
@description	Trata da utiliza鈬o ou n縊 do border? enviado anteriormente
                na gera鈬o do arquivo banc疵io.
                (Rotina FINA420)
                Retorno: .T./.F.                                             /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
                Op鈬o Um Tecnologia da Informa鈬o (www.opcaoum.com.br)       /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function FA420CRI()
Local lRet      := .T.

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// N縊 permitir gerar arquivo texto CNAB, caso j? tenha sido gerado (somente se
// houver tratamento de CNAB existencia do campo E2_XCNAB)
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if SE2->(FieldPos("E2_XCNAB")) > 0 .and. SEA->EA_TRANSF=="S"
    lRet := .F.
    Help(,, "ATENﾇﾃO",, "Border? j? gerou arquivo CNAB. N縊 ? poss?vel ger?-lo novamente." + chr(13) + chr(10) + "F420CHK (Espec?fico " + AllTrim(SM0->M0_NOME) + ")", 1)
endif

Return(lRet)
