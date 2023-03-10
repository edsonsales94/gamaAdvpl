#include "rwmake.ch"
#include "protheus.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		GP240MAN                                                      /@
@date		  		01/02/2016                                                    /@
@type				Ponto de entrada
@description	Executado ap?s a grava鈬o dos registros na tabela SR8 (Cadastro
					de Afastamentos), em casos de inclus縊 ou altera鈬o.
					Utilizado para atualiza鈬o de campo de estabilidade no cadastro
					de funcion疵ios. 
					Trabalha em conjunto com os PEｴs GP240EXC, GP030FER e GPM030EX/@
@author			Adalberto Moreno Batista (Op鈬o Um Consultoria)               /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function GP240MAN()
Local aArea		:= GetArea()

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Executado somente se for para a empresa Brasitech
// Fun鈬o GP_ESTABIL encontra-se no fonte BRAXFUN, pois ? utilizada nos pontos de
// entrada GP240MAN, GP030FER e GPM030EX
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if cEmpAnt == "01"
	U_GP_Estabil()
endif

RestArea(aArea)
Return()
