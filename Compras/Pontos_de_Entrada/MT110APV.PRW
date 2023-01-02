#include "protheus.ch"     
#include "rwmake.ch"
#INCLUDE "FWMVCDEF.CH"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		MT110APV                                                     /@
@type			Ponto de entrada                                             /@
@date			05/05/2021                                                   /@
@description	Validador para execução da função aprovar na solicitação de
                compras                                                      /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Tecnologia                                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MT110APV()
Local lRet := .T.

//———————————————————————————————————————————————————————————————————————————————
// Verifico se é filial 03-São Paulo e não permito utilizar a aprovação manual
// de solicitação de compras.
// Por: Adalberto Moreno Batista (Opção Um) em 05/05/2021
//———————————————————————————————————————————————————————————————————————————————
if cFilAnt == "03"
    lRet := .F.
    Help(,, "® ATENÇÃO",, "Opção desabilitada para a filial São Paulo. (PE MT110APV)" + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
endif

Return(lRet)
