#include 'protheus.ch'
#include 'parmtype.ch'

User Function CadZ03()
	PRIVATE cCadastro := "Cadastro de Custo Stander" //"Processo de Venda"
	PRIVATE aRotina := { { "Pesquisa","AxPesqui"  ,0,1},; //"Pesquisar"
	{ "Visualizar","U_Z02Visua",0,2},; //"Visual"
	{ "Incluir","U_Z03Inclu",0,3},; //"Incluir"
	{ "Alterar","U_Z03Alter",0,4},; //"Alterar"
	{ "Excluir","U_Z03Exclu",0,5},;    //"Exclusao"
	{ "Monitor","U_Z03Stand",0,6} }    //"Exclusao"

	mBrowse( 6, 1,22,75,"Z02")
Return(.T.)

User Function Z02Visua(cAlias,nReg,nOpcx)
	Local aArea     := GetArea()
	Local oGetDad
	Local oDlg
	Local nUsado    := 0
	Local nCntFor   := 0
	Local nOpcA     := 0
	Local lContinua := .T.
	Local lQuery    := .F.
	Local cCadastro := "Cadastro de Custo Stander" //"Processo de Venda"
	Local cQuery    := ""
	Local cTrab     := "Z03"
	Local bWhile    := {|| .T. }
	Local aObjects  := {}
	Local aPosObj   := {}
	Local aSizeAut  := MsAdvSize()
	PRIVATE aHEADER := {}
	PRIVATE aCOLS   := {}
	PRIVATE aGETS   := {}
	PRIVATE aTELA   := {}
	//+----------------------------------------------------------------+
	//|   Montagem de Variaveis de Memoria                             |
	//+----------------------------------------------------------------+
	dbSelectArea("Z02")
	dbSetOrder(2)
	For nCntFor := 1 To FCount()
		M->&(FieldName(nCntFor)) := FieldGet(nCntFor)
	Next nCntFor
	//+----------------------------------------------------------------+
	//|   Montagem do aHeader                                          |
	//+----------------------------------------------------------------+
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("Z03")
	While ( !Eof() .And. SX3->X3_ARQUIVO == "Z03" )
		If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL )
			nUsado++
			Aadd(aHeader,{ TRIM(X3Titulo()),;
			TRIM(SX3->X3_CAMPO),;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT } )
		EndIf
		dbSelectArea("SX3")
		dbSkip()
	EndDo
	//+----------------------------------------------------------------+
	//|   Montagem do aCols                                            |
	//+----------------------------------------------------------------+
	dbSelectArea("Z03")
	dbSetOrder(1)
	#IFDEF TOP
	If ( TcSrvType()!="AS/400" )
		lQuery := .T.
		cQuery := "SELECT *,R_E_C_N_O_ Z03RECNO "
		cQuery += "FROM "+RetSqlName("Z03")+" Z03 "
		cQuery += "WHERE Z03.Z03_FILIAL='"+xFilial("Z03")+"' AND "
		cQuery += "Z03.Z03_CSTCOD='"+Z02->Z02_CSTCOD+"'  AND Z03.Z03_COD='"+Z02->Z02_COD+"' "
		cQuery += " AND Z03.D_E_L_E_T_<>'*' "
		cQuery += "ORDER BY "+SqlOrder(Z03->(IndexKey()))

		cQuery := ChangeQuery(cQuery)
		cTrab := "FT010VIS"
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTrab,.T.,.T.)
		For nCntFor := 1 To Len(aHeader)
			TcSetField(cTrab,AllTrim(aHeader[nCntFor][2]),aHeader[nCntFor,8],aHeader[nCntFor,4],aHeader[nCntFor,5])
		Next nCntFor
	Else
		#ENDIF
		Z03->(dbSeek(xFilial("Z03")+Z02->(Z02_CSTCOD+Z02_COD)))
		bWhile := {|| xFilial("Z03")  == Z03->Z03_FILIAL .And.;
		Z02->Z02_CSTCOD == Z03->Z03_CSTCOD .And.  Z02->Z02_COD == Z03->Z03_COD }
		#IFDEF TOP
	EndIf
	#ENDIF

	While ( !Eof() .And. Eval(bWhile) )
		aadd(aCOLS,Array(nUsado+1))
		For nCntFor := 1 To nUsado
			aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor][2])
			If ( aHeader[nCntFor][10] != "V" )
				aCols[Len(aCols)][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
			Else
				If ( lQuery )
					Z03->(dbGoto((cTrab)->Z03RECNO))
				EndIf
				aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor][2])
			EndIf
		Next nCntFor
		aCOLS[Len(aCols)][Len(aHeader)+1] := .F.
		dbSelectArea(cTrab)
		dbSkip()
	EndDo
	If ( lQuery )
		dbSelectArea(cTrab)
		dbCloseArea()
		dbSelectArea(cAlias)
	EndIf
	aObjects := {}
	AAdd( aObjects, { 315,  50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
	EnChoice( cAlias ,nReg, nOpcx, , , , , aPosObj[1], , 3 )
	oGetDad := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4], nOpcx, "U_Ft010LinOk" ,"AllwaysTrue","+Z03_ITEM",.F.)
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})
	RestArea(aArea)
Return(.T.)

User Function Z03Inclu(cAlias,nReg,nOpcx)
	Local aArea     := GetArea()
	Local cCadastro := "Cadastro de Custo Stander"
	Local oGetDad
	Local oDlg
	Local nUsado    := 0
	Local nCntFor   := 0
	Local nOpcA     := 0
	Local aObjects  := {}
	Local aPosObj   := {}
	Local aSizeAut  := MsAdvSize()
	PRIVATE aHEADER := {}
	PRIVATE aCOLS   := {}
	PRIVATE aGETS   := {}
	PRIVATE aTELA   := {}
	/*
	+----------------------------------------------------------------+
	|   Montagem das Variaveis de Memoria                            |
	+----------------------------------------------------------------+
	*/
	dbSelectArea("Z02")
	dbSetOrder(1)
	For nCntFor := 1 To FCount()
		M->&(FieldName(nCntFor)) := CriaVar(FieldName(nCntFor))
	Next nCntFor
	/*
	+----------------------------------------------------------------+
	|   Montagem da aHeader                                          |
	+----------------------------------------------------------------+
	*/
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("Z03")
	While ( !Eof() .And. SX3->X3_ARQUIVO == "Z03" )
		If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL )
			nUsado++
			Aadd(aHeader,{ TRIM(X3Titulo()),;
			TRIM(SX3->X3_CAMPO),;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT } )
		EndIf
		dbSelectArea("SX3")
		dbSkip()
	EndDo
	/*
	+----------------------------------------------------------------+
	|   Montagem da Acols                                            |
	+----------------------------------------------------------------+
	*/
	aadd(aCOLS,Array(nUsado+1))
	For nCntFor := 1 To nUsado
		aCols[1][nCntFor] := CriaVar(aHeader[nCntFor][2])
	Next nCntFor
	aCOLS[1][Len(aHeader)+1] := .F.
	aObjects := {}
	AAdd( aObjects, { 315,  50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
	EnChoice( cAlias ,nReg, nOpcx, , , , , aPosObj[1], , 3 )
	oGetDad := MSGetDados():New(aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4], nOpcx, "U_Ft010LinOk", "Ft010TudOk","",.T.)
	ACTIVATE MSDIALOG oDlg ;
	ON INIT EnchoiceBar(oDlg, {||nOpcA:=If(oGetDad:TudoOk() , 1,0),If(nOpcA==1,oDlg:End(),Nil)},{||oDlg:End()})
	If ( nOpcA == 1 )
		Begin Transaction
			Z03Grv(1)
			If ( __lSX8 )
				ConfirmSX8()
			EndIf
			EvalTrigger()
		End Transaction
	Else
		If ( __lSX8 )
			RollBackSX8()
		EndIf
	EndIf
	RestArea(aArea)
Return(.T.)

/*
+------------+----------+-------+-----------------------+------+----------+
| Funcao     |Ft010Alter| Autor |Eduardo Riera          | Data |13.01.2000|
|------------+----------+-------+-----------------------+------+----------+
| Descricao  |Funcao de Tratamento da Alteracao                           |
+------------+------------------------------------------------------------+
| Sintaxe    | Ft010Alter(ExpC1,ExpN2,ExpN3)                              |
+------------+------------------------------------------------------------+
| Parametros | ExpC1: Alias do arquivo                                    |
|            | ExpN2: Registro do Arquivo                                 |
|            | ExpN3: Opcao da MBrowse                                    |
+------------+------------------------------------------------------------+
| Retorno    | Nenhum                                                     |
+------------+------------------------------------------------------------+
| Uso        | FATA010                                                    |
+------------+------------------------------------------------------------+
*/
User Function Z03Alter(cAlias,nReg,nOpcx)
	Local aArea     := GetArea()
	Local cCadastro :="Alterar Custo Stander"
	Local oGetDad
	Local oDlg
	Local nUsado    := 0
	Local nCntFor   := 0
	Local nOpcA     := 0
	Local lContinua := .T.
	Local cQuery    := ""
	Local cTrab     := "Z03"
	Local bWhile    := {|| .T. }
	Local aObjects  := {}
	Local aPosObj   := {}
	Local aSizeAut  := MsAdvSize()
	PRIVATE aHEADER := {}
	PRIVATE aCOLS   := {}
	PRIVATE aGETS   := {}
	PRIVATE aTELA   := {}
	/*
	+----------------------------------------------------------------+
	|   Montagem das Variaveis de Memoria                            |
	+----------------------------------------------------------------+
	*/
	dbSelectArea("Z02")
	dbSetOrder(1)
	lContinua := SoftLock("Z02")
	If ( lContinua )
		For nCntFor := 1 To FCount()
			M->&(FieldName(nCntFor)) := FieldGet(nCntFor)
		Next nCntFor
		/*
		+----------------------------------------------------------------+
		|   Montagem da aHeader                                          |
		+----------------------------------------------------------------+
		*/
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("Z03")
		While ( !Eof() .And. SX3->X3_ARQUIVO == "Z03" )
			If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL )
				nUsado++
				Aadd(aHeader,{ TRIM(X3Titulo()),;
				TRIM(SX3->X3_CAMPO),;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_VALID,;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_ARQUIVO,;
				SX3->X3_CONTEXT } )
			EndIf
			dbSelectArea("SX3")
			dbSkip()
		EndDo
		/*
		+----------------------------------------------------------------+
		|   Montagem da aCols                                            |
		+----------------------------------------------------------------+
		*/
		dbSelectArea("Z03")
		dbSetOrder(1)
		#IFDEF TOP
		If ( TcSrvType()!="AS/400" )
			lQuery := .T.
			cQuery := "SELECT *,R_E_C_N_O_ Z03RECNO "
			cQuery += "FROM "+RetSqlName("Z03")+" Z03 "
			cQuery += "WHERE Z03.Z03_FILIAL='"+xFilial("Z03")+"' AND "
			cQuery += "Z03.Z03_CSTCOD='"+Z02->Z02_CSTCOD+"' AND Z03.Z03_COD='"+Z02->Z02_COD+"' AND "
			cQuery +=  "Z03.D_E_L_E_T_<>'*' "
			cQuery += "ORDER BY "+SqlOrder(Z03->(IndexKey()))

			cQuery := ChangeQuery(cQuery)
			cTrab := "FT010VIS"
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTrab,.T.,.T.)
			For nCntFor := 1 To Len(aHeader)
				TcSetField(cTrab,AllTrim(aHeader[nCntFor][2]),aHeader[nCntFor,8],;
				aHeader[nCntFor,4],aHeader[nCntFor,5])
			Next nCntFor
		Else
			#ENDIF
			Z03->(dbSeek(xFilial("Z03")+Z02->Z02_CTSCOD+Z02->Z02_COD))
			bWhile := {|| xFilial("Z03")  == Z03->Z03_FILIAL .And.;
			Z02->Z02_CSTCOD == Z03->Z03_CSTCOD .And. Z02->Z02_COD == Z03->Z03_COD  }
			#IFDEF TOP
		EndIf
		#ENDIF
		While ( !Eof() .And. Eval(bWhile) )
			aadd(aCOLS,Array(nUsado+1))
			For nCntFor := 1 To nUsado
				aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor][2])
				If ( aHeader[nCntFor][10] != "V" )
					aCols[Len(aCols)][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
				Else
					If ( lQuery )
						Z03->(dbGoto((cTrab)->Z03RECNO))
					EndIf
					aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor][2])
				EndIf
			Next nCntFor
			aCOLS[Len(aCols)][Len(aHeader)+1] := .F.
			dbSelectArea(cTrab)
			dbSkip()
		EndDo
		If ( lQuery )
			dbSelectArea(cTrab)
			dbCloseArea()
			dbSelectArea(cAlias)
		EndIf
	EndIf
	If ( lContinua )
		aObjects := {}
		AAdd( aObjects, { 315,  50, .T., .T. } )
		AAdd( aObjects, { 100, 100, .T., .T. } )
		aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
		aPosObj := MsObjSize( aInfo, aObjects, .T. )
		DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] ;
		OF oMainWnd PIXEL
		EnChoice( cAlias ,nReg, nOpcx, , , , , aPosObj[1], , 3 )
		oGetDad := MSGetDados():New (aPosObj[2,1],aPosObj[2,2] ,aPosObj[2,3],aPosObj[2,4] ,nOpcx,"U_Ft010LinOk","Ft010TudOk","+Z03_ITEM",.T.)
		ACTIVATE MSDIALOG oDlg ;
		ON INIT EnchoiceBar(oDlg, {||nOpcA:=If(oGetDad:TudoOk() , 1,0) ,If(nOpcA==1,oDlg:End(),Nil)},{||oDlg:End()})
		If ( nOpcA == 1 )
			Begin Transaction
				Z03Grv(2)
				If ( __lSX8 )
					ConfirmSX8()
				EndIf
				EvalTrigger()
			End Transaction
		Else
			If ( __lSX8 )
				RollBackSX8()
			EndIf
		EndIf
	EndIf

	RestArea(aArea)
Return(.T.)

/*
+------------+----------+-------+-----------------------+------+----------+
| Funcao     |Ft010Exclu| Autor |Eduardo Riera          | Data |13.01.2000|
|------------+----------+-------+-----------------------+------+----------+
| Descricao  |Funcao de Tratamento da Exclusao                            |
+------------+------------------------------------------------------------+
| Sintaxe    | Ft010Exclu(ExpC1,ExpN2,ExpN3)                              |
+------------+------------------------------------------------------------+
| Parametros | ExpC1: Alias do arquivo                                    |
|            | ExpN2: Registro do Arquivo                                 |
|            | ExpN3: Opcao da MBrowse                                    |
+------------+------------------------------------------------------------+
| Retorno    | Nenhum                                                     |
+------------+------------------------------------------------------------+
| Uso        | FATA010                                                    |
+------------+------------------------------------------------------------+
*/
User Function Z03Exclu(cAlias,nReg,nOpcx)
	Local aArea     := GetArea()
	Local cCadastro := "Alteracao do custo stander" //"Processo de Venda"
	Local oGetDad
	Local oDlg
	Local nUsado    := 0
	Local nCntFor   := 0
	Local nOpcA     := 0
	Local lContinua := .T.
	Local cQuery    := ""
	Local cTrab     := "Z03"
	Local bWhile    := {|| .T. }
	Local aObjects  := {}
	Local aPosObj   := {}
	Local aSizeAut  := MsAdvSize()
	PRIVATE aHEADER := {}
	PRIVATE aCOLS   := {}
	PRIVATE aGETS   := {}
	PRIVATE aTELA   := {}
	/*
	+----------------------------------------------------------------+
	|   Montagem das Variaveis de Memoria                            |
	+----------------------------------------------------------------+
	*/
	dbSelectArea("Z02")
	dbSetOrder(1)
	lContinua := SoftLock("Z02")
	If ( lContinua )
		For nCntFor := 1 To FCount()
			M->&(FieldName(nCntFor)) := FieldGet(nCntFor)
		Next nCntFor
		/*
		+----------------------------------------------------------------+
		|   Montagem da aHeader                                          |
		+----------------------------------------------------------------+
		*/
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("Z03")
		While ( !Eof() .And. SX3->X3_ARQUIVO == "Z03" )
			If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL )
				nUsado++
				Aadd(aHeader,{ TRIM(X3Titulo()),;
				TRIM(SX3->X3_CAMPO),;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_VALID,;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_ARQUIVO,;
				SX3->X3_CONTEXT } )
			EndIf
			dbSelectArea("SX3")
			dbSkip()
		EndDo
		/*
		+----------------------------------------------------------------+
		|   Montagek da aCols                                            |
		+----------------------------------------------------------------+
		*/
		dbSelectArea("Z03")
		dbSetOrder(1)
		#IFDEF TOP
		If ( TcSrvType()!="AS/400" )
			lQuery := .T.
			cQuery := "SELECT *,R_E_C_N_O_ Z03RECNO "
			cQuery += "FROM "+RetSqlName("Z03")+" Z03 "
			cQuery += "WHERE Z03.Z03_FILIAL='"+xFilial("Z03")+"' AND "
			cQuery +=       "Z03.Z03_CSTCOD='"+Z02->Z02_CSTCOD+"' AND Z03.Z03_COD='"+Z02->Z02_COD+"' AND "
			cQuery +=       "Z03.D_E_L_E_T_<>'*' "
			cQuery += "ORDER BY "+SqlOrder(Z03->(IndexKey()))

			cQuery := ChangeQuery(cQuery)
			cTrab := "FT010VIS"
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTrab,.T.,.T.)
			For nCntFor := 1 To Len(aHeader)
				TcSetField(cTrab,AllTrim(aHeader[nCntFor][2]),aHeader[nCntFor,8],;
				aHeader[nCntFor,4],aHeader[nCntFor,5])
			Next nCntFor
		Else
			#ENDIF
			Z03->(dbSeek(xFilial("Z03")+Z02->(Z02_CSTCOD+Z02_COD)))
			bWhile := {|| xFilial("Z03")  == Z03->Z03_FILIAL .And.;
			Z02->Z02_CSTCOD == Z03->Z03_CSTCOD .And. Z02->Z02_COD == Z03->Z03_COD }
			#IFDEF TOP
		EndIf
		#ENDIF
		While ( !Eof() .And. Eval(bWhile) )
			aadd(aCOLS,Array(nUsado+1))
			For nCntFor := 1 To nUsado
				aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor][2])
				If ( aHeader[nCntFor][10] != "V" )
					aCols[Len(aCols)][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
				Else
					If ( lQuery )
						Z03->(dbGoto((cTrab)->Z03RECNO))
					EndIf
					aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor][2])
				EndIf
			Next nCntFor
			aCOLS[Len(aCols)][Len(aHeader)+1] := .F.
			dbSelectArea(cTrab)
			dbSkip()
		EndDo
		If ( lQuery )
			dbSelectArea(cTrab)
			dbCloseArea()
			dbSelectArea(cAlias)
		EndIf
	EndIf
	If ( lContinua )
		aObjects := {}
		AAdd( aObjects, { 315,  50, .T., .T. } )
		AAdd( aObjects, { 100, 100, .T., .T. } )
		aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
		aPosObj := MsObjSize( aInfo, aObjects, .T. )

		DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],00 To ;
		aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

		EnChoice( cAlias ,nReg, nOpcx, , , , , aPosObj[1], , 3 )
		oGetDad := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,;
		"U_Ft010LinOk","Ft010TudOk","",.F.)
		ACTIVATE MSDIALOG oDlg ;
		ON INIT EnchoiceBar(oDlg,{||nOpca:=If(oGetDad:TudoOk(),1,0),If(nOpcA==1,oDlg:End(),Nil)},;
		{||oDlg:End()})
		If ( nOpcA == 1 )
			Begin Transaction
				If Ft010DelOk()
					Z03Grv(3)
					EvalTrigger()
				EndIf
			End Transaction
		EndIf
	EndIf
	RestArea(aArea)
Return(.T.)

/*/
+------------+----------+-------+-----------------------+------+----------+
| Funcao     |Ft010LinOK| Autor |Eduardo Riera          | Data |13.01.2000|
|------------+----------+-------+-----------------------+------+----------+
| Descricao  |Funcao de Validacao da linha OK                             |
+------------+------------------------------------------------------------+
| Sintaxe    | Ft010LinOk()                                               |
+------------+------------------------------------------------------------+
| Parametros | Nennhum                                                    |
+------------+------------------------------------------------------------+
| Retorno    | Nenhum                                                     |
+------------+------------------------------------------------------------+
| Uso        | FATA010                                                    |
+------------+------------------------------------------------------------+
/*/
User Function Ft010LinOk()
	Local lRetorno:= .T.
	Local nPStage := aScan(aHeader,{|x| AllTrim(x[2])=="Z03_CC"})
	Local nPDescri:= aScan(aHeader,{|x| AllTrim(x[2])=="Z03_ITEM"})
	Local nCntFor := 0
	Local nUsado  := Len(aHeader)
	If ( !aCols[n][nUsado+1] )
		/*
		+----------------------------------------------------------------+
		|  Verifica os campos obrigatorios                               |
		+----------------------------------------------------------------+
		*/
		If ( nPStage == 0 .Or. nPDescri == 0 )
			Help("Itens obrigatorios nao preenchidos! ",1,"OBRIGAT")
			lRetorno := .F.
		EndIf
		/*
		+----------------------------------------------------------------+
		|   Verifica se não há estagios repetidos                        |
		+----------------------------------------------------------------+
		*/
		If ( nPStage != 0 .And. lRetorno )
			For nCntFor := 1 To Len(aCols)
				If ( nCntFor != n .And. !aCols[nCntFor][nUsado+1])
					If ( aCols[n][nPStage] == aCols[nCntFor][nPStage] )
						Help("ITENS REPETIDOS !",1,"VALORES REPETIDOS")
						lRetorno := .F.
					EndIf
				EndIf
			Next nCntFor
		EndIf
	EndIf
Return(lRetorno)
/*/
+------------+----------+-------+-----------------------+------+----------+
| Funcao     |Ft010Grv  | Autor |Eduardo Riera          | Data |13.01.2000|
|------------+----------+-------+-----------------------+------+----------+
| Descricao  |Funcao de Gravacao do Processe de Venda                     |
+------------+------------------------------------------------------------+
| Sintaxe    | Ft010Grv(ExpN1)                                            |
+------------+------------------------------------------------------------+
| Parametros | ExpN1: Opcao do Menu (Inclusao / Alteracao / Exclusao)     |
+------------+------------------------------------------------------------+
| Retorno    | .T.                                                        |
+------------+------------------------------------------------------------+
| Uso        | FATA010                                                    |
+------------+------------------------------------------------------------+
/*/
Static Function Z03Grv(nOpc)
	Local aArea     := GetArea()
	Local aUsrMemo  := If( ExistBlock( "FT010MEM" ), ExecBlock( "FT010MEM", .F.,.F. ), {} )
	Local aMemoAC1  := {}
	Local aMemoAC2  := {}
	Local aRegistro := {}
	Local cQuery    := ""
	Local lGravou   := .F.
	Local nCntFor   := 0
	Local nCntFor2  := 0
	Local nUsado    := Len(aHeader)
	Local nPStage   := aScan(aHeader,{|x| AllTrim(x[2])=="Z03_CSTCOD"})
	Local nPMEMO    := aScan(aHeader,{|x| AllTrim(x[2])=="Z03_COD"})
	/*
	+----------------------------------------------------------------+
	| Guarda os registros em um array para atualizacao               |
	+----------------------------------------------------------------+
	*/
	dbSelectArea("Z03")
	dbSetOrder(1)
	#IFDEF TOP
	If ( TcSrvType()!="AS/400" )
		cQuery := "SELECT Z03.R_E_C_N_O_ Z03RECNO "
		cQuery += "FROM "+RetSqlName("Z03")+" Z03 "
		cQuery += "WHERE Z03.Z03_FILIAL='"+xFilial("Z03")+"' AND "
		cQuery +=       "Z03.Z03_CSTCOD='"+M->Z02_CSTCOD+"' AND Z03.Z03_COD='"+M->Z02_COD+"' AND "
		cQuery +=       "Z03.D_E_L_E_T_<>'*' "
		cQuery += "ORDER BY "+SqlOrder(Z03->(IndexKey()))

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"FT010GRV",.T.,.T.)
		dbSelectArea("FT010GRV")
		While ( !Eof() )
			aadd(aRegistro,Z03RECNO)
			dbSelectArea("FT010GRV")
			dbSkip()
		EndDo
		dbSelectArea("FT010GRV")
		dbCloseArea()
		dbSelectArea("Z03")
	Else
		#ENDIF
		dbSeek(xFilial("Z03")+M->Z02_CSTCOD+M->Z02_COD)
		While ( !Eof() .And. xFilial("Z03") == Z03->Z03_FILIAL .And.;
		M->Z02_CSTCOD == Z03->Z03_CSTCOD .And. M->Z02_COD=Z03->Z03_COD )
			aadd(aRegistro,Z03->(RecNo()))
			dbSelectArea("Z03")
			dbSkip()
		EndDo
		#IFDEF TOP
	EndIf
	#ENDIF
	Do Case
		/*
		+----------------------------------------------------------------+
		|  Inclusao / Alteracao                                          |
		+----------------------------------------------------------------+
		*/
		Case nOpc != 3
		For nCntFor := 1 To Len(aCols)
			If ( nCntFor > Len(aRegistro) )
				If ( !aCols[nCntFor][nUsado+1] )
					RecLock("Z03",.T.)
				EndIf
			Else
				Z03->(dbGoto(aRegistro[nCntFor]))
				RecLock("Z03",.F.)
			EndIf
			If ( !aCols[nCntFor][nUsado+1] )
				lGravou := .T.
				For nCntFor2 := 1 To nUsado
					If ( aHeader[nCntFor2][10] != "V" )
						FieldPut(FieldPos(aHeader[nCntFor2][2]),aCols[nCntFor][nCntFor2])
					EndIf
				Next nCntFor2
				/*
				+----------------------------------------------------------------+
				| Grava os campos obrigatorios                                   |
				+----------------------------------------------------------------+
				*/
				Z03->Z03_FILIAL := xFilial("Z03")
				Z03->Z03_CSTCOD := M->Z02_CSTCOD
				Z03->Z03_COD    := M->Z02_COD
				/*
				+----------------------------------------------------------------+
				| Grava os campos memo de usuario                                |
				+----------------------------------------------------------------+
				*/
			Else
				If ( nCntFor <= Len(aRegistro) )
					dbDelete()

				EndIf
			EndIf
			MsUnLock()
		Next nCntFor
		/*
		+----------------------------------------------------------------+
		| Exclusao                                                       |
		+----------------------------------------------------------------+
		*/
		OtherWise
		For nCntFor := 1 To Len(aRegistro)
			Z03->(dbGoto(aRegistro[nCntFor]))
			RecLock("Z03")
			dbDelete()
			MsUnLock()
		Next nCntFor

	EndCase
	/*
	+----------------------------------------------------------------+
	| Atualizacao do cabecalho                                       |
	+----------------------------------------------------------------+
	*/
	dbSelectArea("Z02")
	dbSetOrder(2)
	If ( MsSeek(xFilial("Z02")+M->Z02_CSTCOD+M->Z02_COD) )
		RecLock("Z02",.F.)
	Else
		If ( lGravou )
			RecLock("Z02",.T.)
		EndIf
	EndIf
	If nOpc == 3
		dbDelete()
	Else
		For nCntFor := 1 To Z02->(FCount())
			If ( FieldName(nCntFor)!="Z02_FILIAL" )
				FieldPut(nCntFor,M->&(FieldName(nCntFor)))
			Else
				Z02->Z02_FILIAL := xFilial("Z02")
			EndIf
		Next nCntFor
	EndIf
	MsUnLock()
	/*
	+----------------------------------------------------------------+
	|   Restaura integridade da rotina                               |
	+----------------------------------------------------------------+
	*/
	RestArea(aArea)
Return( .T. )
/*/
+------------+----------+-------+-----------------------+------+----------+
| Funcao     |Ft010TudOK| Autor |Eduardo Riera          | Data |13.01.2000|
|------------+----------+-------+-----------------------+------+----------+
| Descricao  |Funcao TudoOK                                               |
+------------+------------------------------------------------------------+
| Sintaxe    | Ft010TudOK()                                               |
+------------+------------------------------------------------------------+
| Parametros | Nenhum                                                     |
+------------+------------------------------------------------------------+
| Retorno    | .T./.F.                                                    |
+------------+------------------------------------------------------------+
| Uso        | FATA010                                                    |
+------------+------------------------------------------------------------+
/*/
Static Function Ft010TudOk()
	Local lRet      := .T.
	Local nPosRelev := GDFieldPos( "Z03_CSTCOD" )
	Local nPosStage := GDFieldPos( "Z03_COD" )
	Local nLoop     := 0
	Local nTotal    := 0
	Local nPosDel   := Len( aHeader ) + 1
	/*
	If !Empty( AScan( aCols, { |x| x[nPosRelev] > 0 } ) )
	For nLoop := 1 To Len( aCols )
	If !aCols[ nLoop, nPosDel ]
	nTotal += aCols[ nLoop, nPosRelev ]

	EndIf
	Next nLoop

	If lRet
	If nTotal <> 100
	Aviso( "SSSS", "TESSS", ;
	{ "FECHAR" }, 2 )  //"Atencao !"###"A soma dos valores de relevancia deve ser igual a 100% //!"###"Fechar"
	lRet := .F.
	EndIf
	EndIf
	EndIf*/
Return( lRet )
/*/
+------------+----------+-------+-----------------------+------+----------+
| Funcao     |Ft010DelOk| Autor |Sergio Silveira        | Data |18.01.2001|
|------------+----------+-------+-----------------------+------+----------+
| Descricao  |Validacao da Exclusao                                       |
+------------+------------------------------------------------------------+
| Sintaxe    | Ft010DelOk()                                               |
+------------+------------------------------------------------------------+
| Parametros | Nenhum                                                     |
+------------+------------------------------------------------------------+
| Retorno    | .T./.F.                                                    |
+------------+------------------------------------------------------------+
| Uso        | FATA010                                                    |
+------------+------------------------------------------------------------+
/*/
Static Function Ft010DelOk()
	LOCAL lRet := .T.
	//AD1->( dbSetOrder( 5 ) )
	//If AD1->( dbSeek( xFilial( "AD1" ) + M->AC1_PROVEN ) )
	//   lRet := .F.
	//   Aviso( "ERRO AO EXCLUIR!", "", { "FECHAR" }, 2 )  // "Atencao"
	// "Este processo de venda nao pode ser excluido pois esta sendo utilizado em uma ou mais
	// oportunidades !", "Fechar"
	//EndIf
Return( lRet )
 
User Function Z03Stand(cAlias,nReg,nOpcx)
	LOCAL lRet := .T.
	Local nErr := 0
	Local cParam 
	
	
	dbSelectArea("Z02")
	dbSetOrder(1)        
	aResult := TCSPEXEC("sp_custostd",Z02->Z02_COD,Z02->Z02_QPAD,1,1,Z02->Z02_CSTCOD,Z02->Z02_COD,DTOS(Z02->Z02_DTDE),DTOS(Z02->Z02_DTATE),xFilial("Z02"),0)
	cParam :=ALLTRIM(STR(Z02->Z02_QPAD))+SPACE(1)+ ALLTRIM(STR(Z02->Z02_PSCRAP)) 
	cParam += SPACE(1)+ alltrim(str(aResult[1]))+ SPACE(1)+ DTOS(Z02->Z02_DTDE)+ SPACE(1)+DTOS(Z02->Z02_DTATE)+SPACE(1)+XFILIAL("Z02")
	ALERT(IIF(aResult[1]==1,"Será Incluido uma Revisao!","Esta Revisao Será Alterada!"  ) )
	nErr := ShellExecute( "Open", "C:\custo\CustoApp.jar",cParam, "C:\temp",10)
	IF nErr == 0
		MsgInfo("Aplicação iniciada com sucesso.")
	Else
		MsgStop("Aguarde para Carregar os Dados ")
	Endif

Return( lRet )

//SEGUE ABAIXO STORED PROCEDURE DE CUSTO STANDER
/*
USE [Protheus11]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_custostd]
@G1_COD VARCHAR(15) ,@G1_QUANT FLOAT, @APAGA INT,@IDENT INT,@REVPAI VARCHAR(6),@CODID VARCHAR(15),
@DTDE VARCHAR(8),@DTATE VARCHAR(8),@FILIAL VARCHAR(2),@ALT INT OUTPUT
AS
DECLARE @NIV VARCHAR(2) ;
DECLARE @COD VARCHAR(15) ;
DECLARE @DESCPAI VARCHAR(40) ;
DECLARE @TIPOPAI VARCHAR(2) ;
DECLARE @FANTASMPAI VARCHAR(1) ;
DECLARE @COMP VARCHAR(15) ;
DECLARE @DESCFIL VARCHAR(40) ;
DECLARE @TPFIL  VARCHAR(2) ;
DECLARE @FANTASMFIL  VARCHAR(1) ;
DECLARE @FILORIGAMA  VARCHAR(2) ;
DECLARE @FILORIGEM  VARCHAR(3) ;
DECLARE @FILTPGAMA  VARCHAR(40) ;
DECLARE @UTIL  FLOAT;
DECLARE @REV   VARCHAR(3) ;
DECLARE @USADO FLOAT ;
DECLARE @UM VARCHAR(2) ;
DECLARE @CUSTO FLOAT ;
DECLARE @ID INT ;


DECLARE @REC INT ;
DECLARE c_Custo CURSOR LOCAL FOR
SELECT G1_NIV,G1_COD,SB1PAI.B1_DESC,SB1PAI.B1_TIPO,SB1PAI.B1_FANTASM ,G1_COMP,
SB1FILHO.B1_DESC,SB1FILHO.B1_TIPO,SB1FILHO.B1_FANTASM,SB1FILHO.B1_ORIGAMA,ISNULL(SX5TP.X5_DESCRI,SB1FILHO.B1_DESC),
G1_QUANT,SB1PAI.B1_REVATU,SB1FILHO.B1_UM 
FROM SG1010 SG1
LEFT OUTER JOIN SB1010 SB1PAI   ON SB1PAI.B1_COD=G1_COD AND SB1PAI.D_E_L_E_T_<>'*'
LEFT OUTER JOIN SB1010 SB1FILHO ON SB1FILHO.B1_COD=G1_COMP AND SB1FILHO.D_E_L_E_T_<>'*'
LEFT OUTER JOIN SX5010 SX5TP ON SX5TP.X5_TABELA='IC' AND SX5TP.X5_CHAVE=SB1FILHO.B1_TPGAMA AND SX5TP.D_E_L_E_T_<>'*'
WHERE G1_COD= @G1_COD
AND  G1_INI<=CONVERT(date, SYSDATETIME())  
AND  G1_FIM>=CONVERT(date, SYSDATETIME())
AND ( G1_REVFIM=SB1PAI.B1_REVATU  OR G1_REVFIM='ZZZ')  AND SG1.D_E_L_E_T_<>'*'
ORDER BY G1_COMP

-- Abrindo Cursor para leitura
OPEN c_Custo
-- Lendo a próxima linha

FETCH NEXT FROM c_Custo INTO  @NIV , @COD , @DESCPAI , @TIPOPAI , @FANTASMPAI , @COMP , @DESCFIL , @TPFIL  , @FANTASMFIL
, @FILORIGAMA , @FILTPGAMA  , @UTIL  , @REV,@UM

-- Iniciando a tabela temporaria
IF object_id('CUSTOSTD') is null
BEGIN
 CREATE TABLE CUSTOSTD (CODID VARCHAR(15),REV   VARCHAR(6),
 NIV VARCHAR(2) , COD VARCHAR(15) , DESCPAI VARCHAR(40) , TIPOPAI VARCHAR(2) , FANTASMPAI VARCHAR(1) , COMP VARCHAR(15) ,
 DESCFIL VARCHAR(40) ,TPFIL  VARCHAR(2) ,FANTASMFIL  VARCHAR(1) ,FILORIGAMA  VARCHAR(3) , FILTPGAMA  VARCHAR(40) , UTIL  FLOAT,
 CUSTO FLOAT, FILUM VARCHAR(2) ,IDENT INT, IDCOMP INT,EXCEL INT)
END
ELSE
BEGIN
 IF @APAGA=1
  BEGIN
   DELETE CUSTOSTD
  END
END
SET @ID = @IDENT
IF (SELECT COUNT(CODID) FROM CUSTO WHERE CODID=@CODID AND REV=@REVPAI)>0
BEGIN
 SET @ALT = 2 -- INFORMA QUE É UMA ALTERAÇÃO
 INSERT INTO CUSTOSTD SELECT * FROM CUSTO CTS WHERE CODID=@CODID AND REV=@REVPAI
END
ELSE
BEGIN
 SET @ALT = 1 -- INFORMA QUE É UMA INCLUSAO
 WHILE @@FETCH_STATUS = 0
 BEGIN

  SET @USADO = @G1_QUANT*@UTIL
   IF @FANTASMFIL<>'S' AND (SELECT COUNT(G1_COD) FROM SG1010  WHERE G1_COD=@COMP  AND  G1_FIM>=CONVERT(date, SYSDATETIME()) AND D_E_L_E_T_<>'*')=0
   BEGIN 
    SET @CUSTO = @USADO * (SELECT 
    ISNULL((SELECT  cast(SUM(D1_CUSTO)/(ISNULL(SUM(D1_QUANT),1) ) as numeric(18,6))
    FROM SD1010 SD1,SF4010 SF4
    WHERE D1_FILIAL=@FILIAL AND D1_DTDIGIT>=@DTDE AND D1_DTDIGIT<=@DTATE
    AND D1_NUMSEQ<>'' AND SD1.R_E_C_N_O_<>0
    AND SD1.D_E_L_E_T_<>'*' AND D1_COD=@COMP  
    AND F4_FILIAL='' AND F4_CODIGO=D1_TES AND SF4.R_E_C_N_O_<>0 AND SF4.D_E_L_E_T_<>'*'  AND F4_ESTOQUE='S' ),0))
  END
  ELSE
  BEGIN
   SET @CUSTO = @USADO * (SELECT 
   ISNULL((SELECT  cast(SUM(D1_TOTAL-D1_VALICM)/(ISNULL(SUM(D1_QUANT),1) ) as numeric(18,6))
   FROM SD1010 SD1,SF4010 SF4
     WHERE D1_FILIAL=@FILIAL AND D1_DTDIGIT>=@DTDE AND D1_DTDIGIT<=@DTATE
     AND D1_NUMSEQ<>'' AND SD1.R_E_C_N_O_<>0
     AND SD1.D_E_L_E_T_<>'*' AND D1_COD=@COMP  
     AND F4_FILIAL='' AND F4_CODIGO=D1_TES AND SF4.R_E_C_N_O_<>0 AND SF4.D_E_L_E_T_<>'*'  AND F4_ESTOQUE='S' ),0))
  END
  IF @CUSTO=0 AND @FANTASMFIL<>'S' AND (SELECT COUNT(G1_COD) FROM SG1010  WHERE G1_COD=@COMP  AND
  G1_FIM>=CONVERT(date, SYSDATETIME()) AND D_E_L_E_T_<>'*')=0
  BEGIN
    SET @CUSTO = @USADO * (SELECT 
    ISNULL((SELECT  cast(SUM(D1_CUSTO)/(ISNULL(SUM(D1_QUANT),1) ) as numeric(18,6))
    FROM SD1010 SD1,SF4010 SF4
    WHERE D1_FILIAL=@FILIAL AND LEFT(D1_DTDIGIT,4)=LEFT( 
	 ISNULL((SELECT MAX(D1MAX.D1_DTDIGIT) FROM SD1010 D1MAX,SF4010 F4MAX 
	 WHERE D1MAX.D1_FILIAL=SD1.D1_FILIAL AND D1MAX.D1_COD=SD1.D1_COD  AND 
	 F4MAX.F4_FILIAL='' AND F4MAX.F4_CODIGO=D1MAX.D1_TES AND F4MAX.R_E_C_N_O_<>0 AND F4MAX.D_E_L_E_T_<>'*'  AND F4MAX.F4_ESTOQUE='S'),''),4)
    AND D1_NUMSEQ<>'' AND SD1.R_E_C_N_O_<>0
    AND SD1.D_E_L_E_T_<>'*' AND D1_COD=@COMP
    AND F4_FILIAL='' AND F4_CODIGO=D1_TES AND SF4.R_E_C_N_O_<>0 AND SF4.D_E_L_E_T_<>'*'  AND F4_ESTOQUE='S' ),0))
  END
  IF @FILORIGAMA='01'
  BEGIN
   SET @FILORIGEM='Imp'
  END
  ELSE
  BEGIN
   SET @FILORIGEM='Nac'
  END

  IF @FANTASMFIL<>'S' OR (SELECT COUNT(G1_COD) FROM SG1010  WHERE G1_COD=@COMP  AND
  G1_FIM>=CONVERT(date, SYSDATETIME()) AND D_E_L_E_T_<>'*')>0
  BEGIN
    IF (SELECT COUNT(G1_COD) FROM SG1010  WHERE G1_COD=@COMP  AND
     G1_FIM>=CONVERT(date, SYSDATETIME()) AND D_E_L_E_T_<>'*')>0
     BEGIN
      SET @APAGA = 2
      SET @ID=(SELECT MAX(IDENT) FROM CUSTOSTD)+1
      IF @ID=@IDENT 
      BEGIN
       SET @ID=@ID+1
      END
      INSERT INTO CUSTOSTD (CODID,NIV , COD , DESCPAI , TIPOPAI , FANTASMPAI , COMP ,
      DESCFIL ,TPFIL  ,FANTASMFIL  ,FILORIGAMA  , FILTPGAMA  , UTIL  ,CUSTO,  REV, FILUM ,IDENT,IDCOMP,EXCEL  )
      VALUES (@CODID,@NIV , @COD , @DESCPAI , @TIPOPAI , @FANTASMPAI , @COMP ,
      @DESCFIL ,@TPFIL  ,@FANTASMFIL,  @FILORIGEM  , @FILTPGAMA  , @USADO  ,@CUSTO,  @REVPAI,@UM,@IDENT,@ID,0   )
	  IF @CUSTO>0 
	  BEGIN
	   INSERT INTO CUSTOSTD (CODID,NIV , COD , DESCPAI , TIPOPAI , FANTASMPAI , COMP ,
       DESCFIL ,TPFIL  ,FANTASMFIL  ,FILORIGAMA  , FILTPGAMA  , UTIL  ,CUSTO,  REV, FILUM ,IDENT,IDCOMP,EXCEL  )
       VALUES (@CODID,@NIV , @COMP , @DESCFIL , @TPFIL , @FANTASMPAI , @COMP ,
       LEFT('SERV_'+LTRIM(RTRIM(@DESCFIL)),40) ,'SR'  ,@FANTASMFIL,  @FILORIGEM  , 'INDUSTRIALIZAÇAO DE TERCEIROS'  , @USADO  ,@CUSTO,  @REVPAI,@UM,@ID,0,0   )
	  END
      Execute sp_custostd @COMP,@USADO,@APAGA,@ID,@REVPAI,@CODID,@DTDE,@DTATE,@FILIAL,@ALT
     END
    ELSE
     BEGIN
      INSERT INTO CUSTOSTD (CODID,NIV , COD , DESCPAI , TIPOPAI , FANTASMPAI , COMP ,
      DESCFIL ,TPFIL  ,FANTASMFIL  ,FILORIGAMA  , FILTPGAMA  , UTIL  ,CUSTO,  REV, FILUM ,IDENT,IDCOMP,EXCEL  )
      VALUES (@CODID,@NIV , @COD , @DESCPAI , @TIPOPAI , @FANTASMPAI , @COMP ,
      @DESCFIL ,@TPFIL  ,@FANTASMFIL,  @FILORIGEM  , @FILTPGAMA  , @USADO  ,@CUSTO,  @REVPAI,@UM,@IDENT,0,0   )
     END
  END
  -- Lendo a próxima linha
  FETCH NEXT FROM c_Custo INTO  @NIV , @COD , @DESCPAI , @TIPOPAI , @FANTASMPAI , @COMP , @DESCFIL , @TPFIL  , @FANTASMFIL
  , @FILORIGAMA , @FILTPGAMA  , @UTIL  , @REV,@UM
 END 
END
-- Fechando Cursor para leitura
CLOSE c_Custo
-- Desalocando o cursor
DEALLOCATE c_Custo
*/