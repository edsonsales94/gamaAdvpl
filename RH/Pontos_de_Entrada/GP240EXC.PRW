#include "rwmake.ch"
#include "protheus.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		GP240EXC                                                      /@
@date		  		01/02/2016                                                    /@
@type				Ponto de entrada
@description	Executado antes da exclus縊 do registro na tabela SR8 (Cadastro
					de Afastamentos).
					Utilizado para atualiza鈬o de campo de estabilidade no cadastro
					de funcion疵ios. 
					Trabalha em conjunto com os PEｴs GP240EXC, GP030FER e GPM030EX/@
@author			Adalberto Moreno Batista (Op鈬o Um Consultoria)               /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function GP240EXC()

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Executado somente se for para a empresa Brasitech
// Limpo a informa鈬o da data de estabilidade no cadastro de funcion疵ios
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
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
