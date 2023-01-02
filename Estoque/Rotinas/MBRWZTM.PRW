/*
------------------------------------------------------------------------------
Desenvolvedor: Ricky Moraes - 26/10/20
Solicitante..: Valmir Melo (Gestor Injecao)
Objetivo.....: Cadatra Moldes x PI Injetado tabela customizada ZTM
------------------------------------------------------------------------------
*/
#include 'protheus.ch'


USER FUNCTION mBrwZTM()

	LOCAL cAlias := "ZTM"

	PRIVATE cCadastro := "Cadastro codigos de Moldes para Injeção"

	PRIVATE aRotina     := { }


	ChkFile("ZTM")
//Alert(ChkFile("ZTQ"))


	AADD(aRotina, { "Pesquisar", "AxPesqui", 0, 1,NIL })

	AADD(aRotina, { "Visualizar", "AxVisual"  , 0, 2,NIL })

	AADD(aRotina, { "Incluir"      , "AxInclui"   , 0, 3 ,NIL})

	AADD(aRotina, { "Alterar"     , "AxAltera"  , 0, 4,NIL })

//AADD(aRotina, { "Excluir"     , "AxDeleta" , 0, 5,NIL })


	dbSelectArea(cAlias)

	dbSetOrder(1)

	mBrowse(6, 1, 22, 75, cAlias)
//MBrowse(06, 01, 22, 75, cAlias,,,,,, /*aCores*/,,,,,,,,, 60000, {|| o := GetMBrowse(), o:GoBottom(), o:GoTop(), o:Refresh() }) 



RETURN NIL

User Function fListModeZTM()
	Private cListModeZTM := "PLUMA BIVOLT;" +;
		"ELEGANZA;" +;
		"DELTA NEW;" +;
		"PLUMA;" +;
		"ECO PRO;" +;
		"GRAN TORINO;" +;
		"PRIMO;" +;
		"POTENZA;" +;
		"ERGO BASICA;" +;
		"PRIMO BIVOLT;" +;
		"CP1 NOVA;" +;
		"SEM DEFINICAO;"
Return cListModeZTM


User function fVldEndInj()
Local cEnd := ''
	IF POSICIONE( "ZTM",2,xFilial("ZTM")+SB1->B1_COD,"ZTM_CODPI") == M->C2_PRODUTO
		cEnd :='INJECAO'
	ENDIF
return cEnd
