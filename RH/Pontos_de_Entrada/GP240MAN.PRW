#include "rwmake.ch"
#include "protheus.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		GP240MAN                                                      /@
@date		  		01/02/2016                                                    /@
@type				Ponto de entrada
@description	Executado após a gravação dos registros na tabela SR8 (Cadastro
					de Afastamentos), em casos de inclusão ou alteração.
					Utilizado para atualização de campo de estabilidade no cadastro
					de funcionários. 
					Trabalha em conjunto com os PE´s GP240EXC, GP030FER e GPM030EX/@
@author			Adalberto Moreno Batista (Opção Um Consultoria)               /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function GP240MAN()
Local aArea		:= GetArea()

//———————————————————————————————————————————————————————————————————————————————
// Executado somente se for para a empresa Brasitech
// Função GP_ESTABIL encontra-se no fonte BRAXFUN, pois é utilizada nos pontos de
// entrada GP240MAN, GP030FER e GPM030EX
//———————————————————————————————————————————————————————————————————————————————
if cEmpAnt == "01"
	U_GP_Estabil()
endif

RestArea(aArea)
Return()
