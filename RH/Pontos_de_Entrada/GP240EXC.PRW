#include "rwmake.ch"
#include "protheus.ch"

/*/
�������������������������������������������������������������������������������
@function		GP240EXC                                                      /@
@date		  		01/02/2016                                                    /@
@type				Ponto de entrada
@description	Executado antes da exclus�o do registro na tabela SR8 (Cadastro
					de Afastamentos).
					Utilizado para atualiza��o de campo de estabilidade no cadastro
					de funcion�rios. 
					Trabalha em conjunto com os PE�s GP240EXC, GP030FER e GPM030EX/@
@author			Adalberto Moreno Batista (Op��o Um Consultoria)               /@
@use				Espec�fico Brasitech                                          /@
�������������������������������������������������������������������������������
/*/
User Function GP240EXC()

//�������������������������������������������������������������������������������
// Executado somente se for para a empresa Brasitech
// Limpo a informa��o da data de estabilidade no cadastro de funcion�rios
//�������������������������������������������������������������������������������
if cEmpAnt == "01"
	U_GP_Estabil()
/*
	SRA->(RecLock("SRA", .F.))
	SRA->RA_DTVTEST := cTOd("")
	if SRA->(FieldPos("RA_X_TPEST")) > 0
		SRA->RA_X_TPEST := " "
	endif
	SRA->(MsUnLock())
*/
endif

Return()