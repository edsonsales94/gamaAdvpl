#include "rwmake.ch"
#include "protheus.ch"

/*/
�������������������������������������������������������������������������������
@function		GP240MAN                                                      /@
@date		  		01/02/2016                                                    /@
@type				Ponto de entrada
@description	Executado ap�s a grava��o dos registros na tabela SR8 (Cadastro
					de Afastamentos), em casos de inclus�o ou altera��o.
					Utilizado para atualiza��o de campo de estabilidade no cadastro
					de funcion�rios. 
					Trabalha em conjunto com os PE�s GP240EXC, GP030FER e GPM030EX/@
@author			Adalberto Moreno Batista (Op��o Um Consultoria)               /@
@use				Espec�fico Brasitech                                          /@
�������������������������������������������������������������������������������
/*/
User Function GP240MAN()
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