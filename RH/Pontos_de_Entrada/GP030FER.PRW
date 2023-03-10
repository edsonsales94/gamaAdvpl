#include "rwmake.ch"
#include "protheus.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		GP030FER                                                      /@
@date		  		01/02/2016                                                    /@
@type				Ponto de entrada
@description	Acionado ap?s o c疝culo de f駻ias. Permite alterar os valores
					de f駻ias ap?s a grava鈬o dos valores calculados.
					Utilizado para atualiza鈬o de campo de estabilidade no cadastro
					de funcion疵ios.                                  
					Trabalha em conjunto com os PEｴs GP240EXC, GP030FER e GPM030EX/@
@author			Adalberto Moreno Batista (Op鈬o Um Consultoria)               /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function GP030FER()
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
