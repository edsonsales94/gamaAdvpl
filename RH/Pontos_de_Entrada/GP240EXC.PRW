#include "rwmake.ch"
#include "protheus.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		GP240EXC                                                      /@
@date		  		01/02/2016                                                    /@
@type				Ponto de entrada
@description	Executado antes da exclusão do registro na tabela SR8 (Cadastro
					de Afastamentos).
					Utilizado para atualização de campo de estabilidade no cadastro
					de funcionários. 
					Trabalha em conjunto com os PE´s GP240EXC, GP030FER e GPM030EX/@
@author			Adalberto Moreno Batista (Opção Um Consultoria)               /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function GP240EXC()

//———————————————————————————————————————————————————————————————————————————————
// Executado somente se for para a empresa Brasitech
// Limpo a informação da data de estabilidade no cadastro de funcionários
//———————————————————————————————————————————————————————————————————————————————
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
