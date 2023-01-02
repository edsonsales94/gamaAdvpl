#include "protheus.ch"
#include "totvs.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		F590IOK                                                      /@
@type			Ponto de entrada                                             /@
@date			18/07/2022                                                   /@
@description	Manutenção de borderô, permite dos registros sendo acionado
                antes da inclusão do título.                                 /@
@parameters     cTipo   - Define se será bordero "P" Carteira a pagar ou
                        - "R" - Carteira a Receber.
                cNumBor	- Número do borderô selecionado.                     /@
@return         .T. / .F.
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
                Opção Um Tecnologia da Informação (www.opcaoum.com.br)       /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function F590IOK()
Local lRet      := .T.
Local aParam    := PARAMIXB

//———————————————————————————————————————————————————————————————————————————————
// Se borderô a pagar e tiver gerado arquivo CNAB, não permito incluir títulos
//———————————————————————————————————————————————————————————————————————————————
if aParam[1]=="P" .and. SE2->(FieldPos("E2_XCNAB"))>0 .and. SEA->EA_TRANSF=="S"
    lRet    := .F.
    Help(,, "ATENÇÃO",, "Não é possível incluir títulos para um borderô que já tenha sido gerado arquivo CNAB." + chr(13) + chr(10) + "F590IOK (Específico " + AllTrim(SM0->M0_NOME) + ")", 1)
endif

Return(lRet)
