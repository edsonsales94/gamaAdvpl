#include "protheus.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		GAMA_XECTZZ1                                                   /@
@type				Cart縊 de Postagem                                             /@
@date				21/02/2017                                                     /@
@description	Cadastrar os cart?es de postagem por departamento              /@
@author			Rodrigo Ramos                                                  /@
@use				Espec?fico Brasitech                                           /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/

User Function XECTZZ1()

Local cAlias  := "ZZ1"
Local cTitulo := " Cart縊 de Postagem"
Local cVldExc := ".T."
Local cVldAlt := ".T."

dbSelectArea (cAlias)
dbSetOrder (1)
AxCadastro (cAlias,cTitulo,cVldExc,cVldAlt)

Return Nil