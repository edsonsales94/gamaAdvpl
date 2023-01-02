#include "protheus.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		GAMA_XECTZZ1                                                   /@
@type				Cartão de Postagem                                             /@
@date				21/02/2017                                                     /@
@description	Cadastrar os cartões de postagem por departamento              /@
@author			Rodrigo Ramos                                                  /@
@use				Específico Brasitech                                           /@
———————————————————————————————————————————————————————————————————————————————
/*/

User Function XECTZZ1()

Local cAlias  := "ZZ1"
Local cTitulo := " Cartão de Postagem"
Local cVldExc := ".T."
Local cVldAlt := ".T."

dbSelectArea (cAlias)
dbSetOrder (1)
AxCadastro (cAlias,cTitulo,cVldExc,cVldAlt)

Return Nil