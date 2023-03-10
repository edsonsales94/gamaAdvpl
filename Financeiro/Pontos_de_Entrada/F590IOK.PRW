#include "protheus.ch"
#include "totvs.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		F590IOK                                                      /@
@type			Ponto de entrada                                             /@
@date			18/07/2022                                                   /@
@description	Manuten鈬o de border?, permite dos registros sendo acionado
                antes da inclus縊 do t?tulo.                                 /@
@parameters     cTipo   - Define se ser? bordero "P" Carteira a pagar ou
                        - "R" - Carteira a Receber.
                cNumBor	- N?mero do border? selecionado.                     /@
@return         .T. / .F.
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
                Op鈬o Um Tecnologia da Informa鈬o (www.opcaoum.com.br)       /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function F590IOK()
Local lRet      := .T.
Local aParam    := PARAMIXB

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Se border? a pagar e tiver gerado arquivo CNAB, n縊 permito incluir t?tulos
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if aParam[1]=="P" .and. SE2->(FieldPos("E2_XCNAB"))>0 .and. SEA->EA_TRANSF=="S"
    lRet    := .F.
    Help(,, "ATENﾇﾃO",, "N縊 ? poss?vel incluir t?tulos para um border? que j? tenha sido gerado arquivo CNAB." + chr(13) + chr(10) + "F590IOK (Espec?fico " + AllTrim(SM0->M0_NOME) + ")", 1)
endif

Return(lRet)
