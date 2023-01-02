#include "rwmake.ch"
#include "protheus.ch"

/*/
�������������������������������������������������������������������������������
@function		GP030FER                                                      /@
@date		  		01/02/2016                                                    /@
@type				Ponto de entrada
@description	Acionado ap�s o c�lculo de f�rias. Permite alterar os valores
					de f�rias ap�s a grava��o dos valores calculados.
					Utilizado para atualiza��o de campo de estabilidade no cadastro
					de funcion�rios.                                  
					Trabalha em conjunto com os PE�s GP240EXC, GP030FER e GPM030EX/@
@author			Adalberto Moreno Batista (Op��o Um Consultoria)               /@
@use				Espec�fico Brasitech                                          /@
�������������������������������������������������������������������������������
/*/
User Function GP030FER()
Local aArea		:= GetArea()

//�������������������������������������������������������������������������������
// Executado somente se for para a empresa Brasitech
// Fun��o GP_ESTABIL encontra-se no fonte BRAXFUN, pois � utilizada nos pontos de
// entrada GP240MAN, GP030FER e GPM030EX
//�������������������������������������������������������������������������������
if cEmpAnt == "01"
	U_GP_Estabil()
endif

RestArea(aArea)
Return()