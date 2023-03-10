#include "protheus.ch"     
#include "rwmake.ch"
#INCLUDE "FWMVCDEF.CH"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		MT110APV                                                     /@
@type			Ponto de entrada                                             /@
@date			05/05/2021                                                   /@
@description	Validador para execu鈬o da fun鈬o aprovar na solicita鈬o de
                compras                                                      /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Op鈬o Um Tecnologia                                          /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function MT110APV()
Local lRet := .T.

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Verifico se ? filial 03-S縊 Paulo e n縊 permito utilizar a aprova鈬o manual
// de solicita鈬o de compras.
// Por: Adalberto Moreno Batista (Op鈬o Um) em 05/05/2021
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if cFilAnt == "03"
    lRet := .F.
    Help(,, "ｮ ATENﾇﾃO",, "Op鈬o desabilitada para a filial S縊 Paulo. (PE MT110APV)" + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
endif

Return(lRet)
