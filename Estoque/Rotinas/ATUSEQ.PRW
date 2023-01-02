#include 'protheus.ch'
#include 'parmtype.ch'

user function atuseq()
	Local bOk := {|| AtuSeqSd3() }
	Local bCancel:= {|| Fechar() }
	Local aArea := GetArea()
	Local aButtons := {}
	Local aCampos:={}

	Private cProd,cSeq1,cSeq2
	Private oSeq1,oSeq2,oProd,oSaySeq1,oSaySeq2,oSayProd
	Private aSD1,aSD2,aSD3,aSDBo,aSDAo,aSDBd,aSDAd

	aSize := MsAdvSize(.F.)
	aSD1:={}
	aSD2:={}
	aSD3O:={}
	aSD3:={}
	aSDBo:={}
	aSDAo:={}
	aSDBd:={}
	aSDAd:={}

	//aadd(aButtons,{'HISTORIC',{|| IncModSd3()}, "Inlcuir MOD/DOC...", "Inlcuir MOD/DOC" , {|| .T.}} )
	//aadd(aButtons,{'GENERA',{|| IncModSd3B()}, "Inlcuir MOD/OPC...", "Inlcuir MOD/OPC" , {|| .T.}} )

	cTitle:="Ajuste da Sequencia de Calculo"
	// Cria Fonte para visualização
	oFont1 := TFont():New('Courier new',,-14,.T.,.T.)
	oFont2 := TFont():New('Arial',,-20,.T.,.T.)

	//Define a janela do Browse
	oDlg = TDialog():New(0, 0, aSize[6],aSize[5],,,,,,,,,,.T.)
	oSay:= TSay():New(05+40,05,{||'Produto:'},oDlg,,oFont1,,,,.T.,CLR_BLUE,CLR_RED,200,20)
	oSay:= TSay():New(25+40,05,{||'Seq. Origem:'},oDlg,,oFont1,,,,.T.,CLR_BLUE,CLR_RED,200,20)
	oSay:= TSay():New(45+40,05,{||'Seq. Destino:'},oDlg,,oFont1,,,,.T.,CLR_BLUE,CLR_RED,200,20)
	oSayProd:= TSay():New(05+40,150,{||''},oDlg,,oFont2,,,,.T.,CLR_RED,CLR_BLUE,200,20)
	oSaySeq1:= TSay():New(70+40,05,{||''},oDlg,,oFont2,,,,.T.,CLR_RED,CLR_BLUE,300,20)
	oSaySeq2:= TSay():New(95+40,05,{||''},oDlg,,oFont2,,,,.T.,CLR_RED,CLR_BLUE,300,20)

	cSeq1:=SPACE(6)
	cSeq2:=SPACE(6)
	cProd:=SPACE(15)

	@05+40,80 GET oProd VAR cProd VALID (ValProd(cProd)) SIZE 060,09 OF oDlg PIXEL PICTURE "@!"
	@25+40,80 GET oSeq1 VAR cSeq1 VALID (ValSeq()) SIZE 060,09 OF oDlg PIXEL PICTURE "@!"
	@45+40,80 GET oSeq1 VAR cSeq2 VALID (ValSeq()) SIZE 060,09 OF oDlg PIXEL PICTURE "@!"
	// Define o Browse

	//ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||lOk:=.T.,oDlg:End()},{||oDlg:End()},,@aButtons))
	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg, bOk , bCancel ,,@aButtons)) CENTERED
	RestArea(aArea)
Return

Static Function Fechar()
	//If MsgBox("Confirma Saida ?","Atencao","YESNO")
	oDlg:End()
	//Endif
Return

Static Function ValProd(cPrd)
	Local lRet:=.T.
	Local cDesc:=Posicione("SB1",1,xfilial("SB1")+cPrd,"B1_DESC")
	Local x
	oSayProd:cCaption:= cDesc
	oSayProd:Refresh()
Return lRet

Static Function ValSeq()
	Local lRet:=.T.
	Local cFech:= dtos(GetMv("MV_ULMES"))
	Local nReg := 0
	Local lOrig:= .F.
	IF  GetMv("MV_ULMES") > dDataBase
		alert("Nao é permitido corrigir Seqeuncia depois do fechamento!")
		Return .F.
	Endif
	IF LEN(ALLTRIM(cseq1))>0 .AND. LEN(ALLTRIM(cseq2))==0
		BeginSql Alias "TRSD1"
		SELECT count(R_E_C_N_O_)  REG FROM SD1010 SD1
		WHERE D1_FILIAL=%xFilial:SD1% AND D1_COD=%Exp:cProd% AND D1_LOCAL='11' AND D1_NUMSEQ=%Exp:cseq1%
		AND SD1.%NotDel% AND D1_DTDIGIT>=%Exp:cFech%
		EndSql
		dbSelectArea("TRSD1")
		DbGoTop()
		if (TRSD1->REG==0)
			dbSelectArea("TRSD1")
			dbcloseArea("TRSD1")
			lOrig:= .T.
		else
			lOrig:= .F.
			dbSelectArea("TRSD1")
			dbcloseArea("TRSD1")
			BeginSql Alias "TRSD1"
			SELECT D1_DOC,D1_NUMSEQ,D1_QUANT,R_E_C_N_O_  REG FROM SD1010 SD1
			WHERE D1_FILIAL=%xFilial:SD1% AND D1_COD=%Exp:cProd% AND D1_LOCAL='11' AND D1_NUMSEQ=%Exp:cseq1%
			AND SD1.%NotDel% AND D1_DTDIGIT>=%Exp:cFech%
			EndSql
			dbSelectArea("TRSD1")
			DbGoTop()
			nReg := TRSD1->REG
			oSaySeq1:cCaption:= "ORIGEM SD1 - DOC: "+TRSD1->D1_DOC+" QUANT: "+ALLTRIM(STR(TRSD1->D1_QUANT))
			oSaySeq1:Refresh()
			Do while !eof()
				AADD(aSD1,TRSD1->REG)
				TRSD1->(DBSKIP())
			Enddo
			dbSelectArea("TRSD1")
			dbcloseArea("TRSD1")
		endif
		//VERIFICA SE A SEQUENCIA DE ORIGEM É O SD2
		if lOrig
			BeginSql Alias "TRSD2"
			SELECT count(R_E_C_N_O_)  REG FROM SD2010 SD2
			WHERE D2_FILIAL=%xFilial:SD2% AND D2_COD=%Exp:cProd%  AND D2_NUMSEQ=%Exp:cseq1%
			AND SD2.%NotDel% AND D2_EMISSAO>=%Exp:cFech%
			EndSql
			dbSelectArea("TRSD2")
			DbGoTop()
			if (TRSD2->REG==0)
				dbSelectArea("TRSD2")
				dbcloseArea("TRSD2")
				lOrig:= .T.
			else
				lOrig:= .F.
				dbSelectArea("TRSD2")
				dbcloseArea("TRSD2")
				BeginSql Alias "TRSD2"
				SELECT D2_DOC,D2_NUMSEQ,D2_QUANT,R_E_C_N_O_  REG FROM SD2010 SD2
				WHERE D2_FILIAL=%xFilial:SD1% AND D2_COD=%Exp:cProd% AND D2_NUMSEQ=%Exp:cseq1%
				AND SD2.%NotDel% AND D2_EMISSAO>=%Exp:cFech%
				EndSql
				dbSelectArea("TRSD2")
				DbGoTop()
				nReg := TRSD2->REG
				oSaySeq1:cCaption:= "ORIGEM SD2 - DOC: "+TRSD2->D2_DOC+" QUANT: "+ALLTRIM(STR(TRSD2->D2_QUANT))
				oSaySeq1:Refresh()
				Do while !eof()
					AADD(aSD2,TRSD2->REG)
					TRSD2->(DBSKIP())
				Enddo
				dbSelectArea("TRSD2")
				dbcloseArea("TRSD2")
			endif
		endif
		//FIM DA VERIFICAÇÃO DO SD2
		IF 	lOrig
			BeginSql Alias "TRSD3"
			SELECT count(R_E_C_N_O_)  REG FROM SD3010 SD3
			WHERE D3_FILIAL=%xFilial:SD3% AND D3_COD=%Exp:cProd%  AND D3_NUMSEQ=%Exp:cseq1%
			AND SD3.%NotDel% AND D3_EMISSAO>=%Exp:cFech%
			EndSql
			dbSelectArea("TRSD3")
			DbGoTop()
			if (TRSD3->REG==0)
				alert("Origem Nao Encontrado (SD1/SD2/SD3) ou Fora do perido aberto!!")
				dbSelectArea("TRSD3")
				dbcloseArea("TRSD3")
				Return .F.
			else
				dbSelectArea("TRSD3")
				dbcloseArea("TRSD3")
			endif
			BeginSql Alias "TRSD3"
			SELECT D3_DOC,D3_QUANT,R_E_C_N_O_  REG FROM SD3010 SD3
			WHERE D3_FILIAL=%xFilial:SD3% AND D3_NUMSEQ=%Exp:cseq1%
			AND SD3.%NotDel% AND D3_EMISSAO>=%Exp:cFech%
			EndSql
			dbSelectArea("TRSD3")
			DbGoTop()
			oSaySeq1:cCaption:= "ORIGEM SD3 - DOC: "+TRSD3->D3_DOC+" QUANT: "+ALLTRIM(STR(TRSD3->D3_QUANT))
			oSaySeq1:Refresh()
			Do while !EOF()
				aadd(aSD3O,TRSD3->REG)
				TRSD3->(DBSKIP())
			Enddo
			dbSelectArea("TRSD3")
			dbcloseArea("TRSD3")
		ENDIF
		//PEGANDO OS REGISTROS DE ENDERECAMENTO DE ORIGEM
		BeginSql Alias "TRSDB"
		SELECT R_E_C_N_O_  REG FROM SDB010 SDB
		WHERE DB_FILIAL=%xFilial:SDB% AND  DB_NUMSEQ=%Exp:cseq1%
		AND SDB.%NotDel% AND DB_DATA>=%Exp:cFech%
		EndSql
		dbSelectArea("TRSDB")
		DbGoTop()
		Do While !eof()
			aadd( aSDBo,TRSDB->REG)
			TRSDB->(DBSKIP())
		Enddo
		dbSelectArea("TRSDB")
		dbcloseArea("TRSDB")
		//PEGANDO OS REGISTROS DE ENDERECAMENTO DE ORIGEM DO SDA
		BeginSql Alias "TRSDA"
		SELECT R_E_C_N_O_  REG FROM SDA010 SDA
		WHERE DA_FILIAL=%xFilial:SDA% AND DA_PRODUTO=%Exp:cProd% AND DA_NUMSEQ=%Exp:cseq1%
		AND SDA.%NotDel% AND DA_DATA>=%Exp:cFech%
		EndSql
		dbSelectArea("TRSDA")
		DbGoTop()
		Do While !eof()
			aadd( aSDAo,TRSDA->REG)
			TRSDA->(DBSKIP())
		Enddo
		dbSelectArea("TRSDA")
		dbcloseArea("TRSDA")
	ENDIF
	IF LEN(ALLTRIM(cseq1))>0 .AND. LEN(ALLTRIM(cseq2))>0
		BeginSql Alias "TRSD3"
		SELECT count(R_E_C_N_O_)  REG FROM SD3010 SD3
		WHERE D3_FILIAL=%xFilial:SD3% AND D3_COD=%Exp:cProd%  AND D3_NUMSEQ=%Exp:cseq2%
		AND SD3.%NotDel% AND D3_EMISSAO>=%Exp:cFech%
		EndSql
		dbSelectArea("TRSD3")
		DbGoTop()
		if (TRSD3->REG==0)
			alert("Sequencia SD3 nao Encontrado ou Fora do perido aberto!!")
			dbSelectArea("TRSD3")
			dbcloseArea("TRSD3")
			Return .F.
		else
			dbSelectArea("TRSD3")
			dbcloseArea("TRSD3")
		endif
		BeginSql Alias "TRSD3"
		SELECT D3_DOC,D3_QUANT,R_E_C_N_O_  REG FROM SD3010 SD3
		WHERE D3_FILIAL=%xFilial:SD3% AND  D3_NUMSEQ=%Exp:cseq2%
		AND SD3.%NotDel% AND D3_EMISSAO>=%Exp:cFech%
		EndSql
		dbSelectArea("TRSD3")
		DbGoTop()
		oSaySeq2:cCaption:= "DESTINO SD3 - DOC: "+TRSD3->D3_DOC+" QUANT: "+ALLTRIM(STR(TRSD3->D3_QUANT))
		oSaySeq2:Refresh()
		Do while !EOF()
			aadd(aSD3,TRSD3->REG)
			TRSD3->(DBSKIP())
		Enddo
		dbSelectArea("TRSD3")
		dbcloseArea("TRSD3")
		//PEGANDO OS REGISTROS DE ENDERECAMENTO DE DESTINO
		BeginSql Alias "TRSDB"
		SELECT R_E_C_N_O_  REG FROM SDB010 SDB
		WHERE DB_FILIAL=%xFilial:SDB% AND  DB_NUMSEQ=%Exp:cseq2%
		AND SDB.%NotDel% AND DB_DATA>=%Exp:cFech%
		EndSql
		dbSelectArea("TRSDB")
		DbGoTop()
		Do While !eof()
			aadd( aSDBd,TRSDB->REG)
			TRSDB->(DBSKIP())
		Enddo
		dbSelectArea("TRSDB")
		dbcloseArea("TRSDB")
		//PEGANDO OS REGISTROS DE ENDERECAMENTO DE DESTINO DO SDA
		BeginSql Alias "TRSDA"
		SELECT R_E_C_N_O_  REG FROM SDA010 SDA
		WHERE DA_FILIAL=%xFilial:SDA% AND DA_PRODUTO=%Exp:cProd% AND DA_NUMSEQ=%Exp:cseq2%
		AND SDA.%NotDel% AND DA_DATA>=%Exp:cFech%
		EndSql
		dbSelectArea("TRSDA")
		DbGoTop()
		Do While !eof()
			aadd( aSDAd,TRSDA->REG)
			TRSDA->(DBSKIP())
		Enddo
		dbSelectArea("TRSDA")
		dbcloseArea("TRSDA")
	ENDIF
Return lRet

Static Function AtuSeqSd3() 
Local x
	//tratar a origem com a sequencia destino
	For x:=1 to len(aSD1)
		dbselectarea("SD1")
		dbgoto(aSD1[x])
		RecLock("SD1",.F.)
		D1_NUMSEQ :=cseq2
		MsUnLock()
	Next
	For x:=1 to len(aSD2)
		dbselectarea("SD2")
		dbgoto(aSD2[x])
		RecLock("SD2",.F.)
		D2_NUMSEQ :=cseq2
		MsUnLock()
	Next
	For x:=1 to len(aSD3O)
		dbselectarea("SD3")
		dbgoto(aSD3O[x])
		RecLock("SD3",.F.)
		D3_NUMSEQ :=cseq2
		MsUnLock()
	Next
	For x:=1 to len(aSDAo)
		dbselectarea("SDA")
		dbgoto(aSDAo[x])
		RecLock("SDA",.F.)
		DA_NUMSEQ :=cseq2
		MsUnLock()
	Next
	For x:=1 to len(aSDBo)
		dbselectarea("SDB")
		dbgoto(aSDBo[x])
		RecLock("SDB",.F.)
		DB_NUMSEQ :=cseq2
		MsUnLock()
	Next
	//tratar a destino com a sequencia origem
	For x:=1 to len(aSD3)
		dbselectarea("SD3")
		dbgoto(aSD3[x])
		RecLock("SD3",.F.)
		D3_NUMSEQ :=cseq1
		MsUnLock()
	Next
	For x:=1 to len(aSDAd)
		dbselectarea("SDA")
		dbgoto(aSDAd[x])
		RecLock("SDA",.F.)
		DA_NUMSEQ :=cseq1
		MsUnLock()
	Next
	For x:=1 to len(aSDBd)
		dbselectarea("SDB")
		dbgoto(aSDBd[x])
		RecLock("SDB",.F.)
		DB_NUMSEQ :=cseq1
		MsUnLock()
	Next
	alert("Sequencias alteradas com sucesso!!")
	oDlg:End()
Return