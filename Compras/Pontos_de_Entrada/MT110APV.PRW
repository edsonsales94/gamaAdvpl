#include "protheus.ch"     
#include "rwmake.ch"
#INCLUDE "FWMVCDEF.CH"

/*/
�������������������������������������������������������������������������������
@function		MT110APV                                                     /@
@type			Ponto de entrada                                             /@
@date			05/05/2021                                                   /@
@description	Validador para execu��o da fun��o aprovar na solicita��o de
                compras                                                      /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Op��o Um Tecnologia                                          /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
/*/
User Function MT110APV()
Local lRet := .T.

//�������������������������������������������������������������������������������
// Verifico se � filial 03-S�o Paulo e n�o permito utilizar a aprova��o manual
// de solicita��o de compras.
// Por: Adalberto Moreno Batista (Op��o Um) em 05/05/2021
//�������������������������������������������������������������������������������
if cFilAnt == "03"
    lRet := .F.
    Help(,, "� ATEN��O",, "Op��o desabilitada para a filial S�o Paulo. (PE MT110APV)" + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
endif

Return(lRet)