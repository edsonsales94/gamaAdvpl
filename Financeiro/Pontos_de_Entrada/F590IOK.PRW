#include "protheus.ch"
#include "totvs.ch"

/*/
�������������������������������������������������������������������������������
@function		F590IOK                                                      /@
@type			Ponto de entrada                                             /@
@date			18/07/2022                                                   /@
@description	Manuten��o de border�, permite dos registros sendo acionado
                antes da inclus�o do t�tulo.                                 /@
@parameters     cTipo   - Define se ser� bordero "P" Carteira a pagar ou
                        - "R" - Carteira a Receber.
                cNumBor	- N�mero do border� selecionado.                     /@
@return         .T. / .F.
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
                Op��o Um Tecnologia da Informa��o (www.opcaoum.com.br)       /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
/*/
User Function F590IOK()
Local lRet      := .T.
Local aParam    := PARAMIXB

//�������������������������������������������������������������������������������
// Se border� a pagar e tiver gerado arquivo CNAB, n�o permito incluir t�tulos
//�������������������������������������������������������������������������������
if aParam[1]=="P" .and. SE2->(FieldPos("E2_XCNAB"))>0 .and. SEA->EA_TRANSF=="S"
    lRet    := .F.
    Help(,, "ATEN��O",, "N�o � poss�vel incluir t�tulos para um border� que j� tenha sido gerado arquivo CNAB." + chr(13) + chr(10) + "F590IOK (Espec�fico " + AllTrim(SM0->M0_NOME) + ")", 1)
endif

Return(lRet)