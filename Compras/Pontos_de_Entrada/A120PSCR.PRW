#include "protheus.ch"     
#include "rwmake.ch"
#INCLUDE "FWMVCDEF.CH"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		A120PSCR                                                     /@
@type			Ponto de entrada                                             /@
@date			21/06/2021                                                   /@
@description	Adiciona campos da tabela SCR na MsGetDados da conSulta de
                aprova鋏es. Deve retornar os campos da tabela SCR em uma
                string separados por uma barra (/)                           /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Op鈬o Um Tecnologia                                          /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function A120PSCR()
Local cRet      := ""

if SCR->(FieldPos("CR_XNOMRES")) > 0
    cRet    += "CR_XNOMRES"
endif

Return(cRet)

