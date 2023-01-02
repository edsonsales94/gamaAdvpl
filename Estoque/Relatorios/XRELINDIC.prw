#Include "TOTVS.ch"
#Include "TOPCONN.ch"

User Function XRELINDICA()
	Local oReport := ReportDef()

	oReport:PrintDialog()
Return (NIL)

Static Function ReportDef()
	Local cPerg   := "XCICLINDIC"
	Local cTitRel := " Indicadores de Acuracidade - Inventário Ciclíco "
	Local oReport


	DbSelectArea("SX1")
	SX1->(DbSetOrder(1)) //X1_GRUPO + X1_ORDEM
	If ! SX1->(DbSeek(cPerg))
		cPerg := Nil
	else
		pergunte(cPerg,.f.)
	EndIf




	//Local oReport := TReport():New(cPerg, cTitRel, cPerg, {|oReport| ReportPrint(oReport, oSection)}, cTitRel)
	//Criação do componente de impressão
	oReport := TReport():New(	"RelIndicador",;		//Nome do Relatório
	cTitRel,;		//Título
	cPerg,;		//Pergunte ... Se eu defino a pergunta aqui, será impresso uma página com os parâmetros, conforme privilégio 101
	{|oReport| fRepPrint(oReport)},;		//Bloco de código que será executado na confirmação da impressão
	)		//Descrição
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9) //Folha A4
	oReport:SetPortrait()
	//oReport:SetLineHeight(60)

	//Criando a seção de dados
	oSection := TRSection():New(	oReport,;		//Objeto TReport que a seção pertence
	"Cabaçalho",;		//Descrição da seção
	{"QRY_AUX"})		//Tabelas utilizadas, a primeira será considerada como principal da seção
	//oSection:SetTotalInLine(.t.)  //Define se os t

	//oSection:nLinesBefore:= 3

	//Aqui, farei uma quebra  por seção
	oSection:SetTotalInLine(.F.)  //Define se os t
	oSection:SetPageBreak(.F.)
	oSection:SetTotalText(" ")


	oSection2 := TRSection():New(	oReport,;		//Objeto TReport que a seção pertence
	"Lista",;		//Descrição da seção
	{"QRY_AUX"})		//Tabelas utilizadas, a primeira será considerada como principal da seção
	oSection2:SetTotalInLine(.F.)  //Define se os t
	oSection2:SetPageBreak(.F.)
	oSection2:SetTotalText(" ")

	TRCell():New(oSection, "ARMZ", "QRY_AUX", "Armz.", /*Picture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSection, "RUA", "QRY_AUX", "Rua", /*Picture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,.F./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

	TRCell():New(oSection, "nTOTITENS",NIL, "Tot.Itens.", "@E 999,999,999.99"/*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,.F./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSection, "nACURADOS", NIL, "Acurados", "@E 999,999,999.99"/*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,.F./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSection, "nINACURADOS", NIL, "Inacurados","@E 999,999,999.99" /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,.F./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSection, "nPOSICAO", NIL, "Posicao","@E 999,999,999.99" /*Picture*/, 30, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,.F./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

	TRCell():New(oSection, "npACURADOS", NIL, "Acurados %","@E 999,999,999.99" /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT"/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,.F./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSection, "npINACURADOS", NIL, "Inacurados %","@E 999,999,999.99" /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT"/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,.F./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)


	TRCell():New(oSection2, "ARMZ", "QRY_AUX", "Armz.", /*Picture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSection2, "RUA", "QRY_AUX", "Rua", /*Picture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,.F./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSection2, "ENDERECO", "QRY_AUX", "Endereco", /*Picture*/, 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSection2, "COD", "QRY_AUX", "Codigo", /*Picture*/,17, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSection2, "UND", "QRY_AUX", "Und.", /*Picture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

	TRCell():New(oSection2, "DESCRI", "QRY_AUX", "Descricao", /*Picture*/,65, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSection2, "SLDSBF", "QRY_AUX", "Qtd.Sistema.", "@E 999,999,999.99" /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSection2, "QUANT", "QRY_AUX", "Qtd.Invent.", "@E 999,999,999.99" /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSection2, "DIF", "QRY_AUX", "Dif.Invent.", "@E 999,999,999.99" /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSection2, "DATAINV", "QRY_AUX", "Dt.Invent.", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSection2, "US", "QRY_AUX", "Usuário", /*Picture*/,30, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSection2, "IND", "QRY_AUX", "Indicador", /*Picture*/,15, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)


/*
	oBreak1 := TRBreak():New(oSection,oSection:Cell("RUA"),{ || "Total RUA --> "},.F.)
	TRFunction():New(oSection:Cell("RUA"),NIL,"COUNT",oBreak1,,,,.F.,.T.)
	oSection:SetHeaderBreak(.T.)
*/
Return (oReport)

Static Function fRepPrint(oReport)
	Local cARMZ:= ""
	Local cRua,qRua	:=""
	Local lFilRua:=.F.
	Local nTolerancia:=0
	// Local nNumero  := 0
	Local cQryAux := ""
	Local nAtual   := 0
	Local nTotal   := 0
	Local aTotais:={}
	Local nInacurado,nAcurado,nPosicao,nTotItens,nX:=0
	Local nPerAcurado,nPerInacurado:=0
	Local  oSection  := Nil
	Local  oSection2  := Nil
	Local ARMZ,DTINI,DTFIM,TOL
	nTolerancia:=MV_PAR05

	//FILTRA RUA ?
	qRua:= upper(alltrim(cValToChar(MV_PAR02)))
	lFilRua := IIF(qRua=='' .OR. SUBSTRING(qRua,1,1)='*' .OR. EMPTY(qRua), .F.,.T. )

	ARMZ:=alltrim(cValToChar(MV_PAR01))
	DTINI:=Dtos(MV_PAR03)
	DTFIM:=Dtos(MV_PAR04)
	TOL:=alltrim(cValToChar(MV_PAR05))


	//atualizar SP INDICADORES
	Processa({|| sfProcCICLI(ARMZ,DTINI,DTFIM,TOL) },"Atualizando tabelas Indicadores...")
	//sfProcCICLI(ARMZ,DTINI,DTFIM,TOL)


	//cQryAux := " EXEC sp_CICL_IND '20210101','20210331',10 "
	/*
	cQryAux := " EXEC sp_CICL_IND "
	cQryAux += " '"+ alltrim(cValToChar(MV_PAR01))+ "' "// ARMZ
	cQryAux += ",'"+ alltrim(cValToChar(MV_PAR03))+ "' "// DT.INICIAL
	cQryAux += ",'"+ alltrim(cValToChar(MV_PAR04))+ "' "// DT.FINAL
	cQryAux += " ,"+ alltrim(cValToChar(MV_PAR05))+ " "// TOLERANCIA
	*/

	//Se o alias estiver aberto, irei fechar, isso ajuda a evitar erros
	IF Select("QRY_AUX") <> 0
		DbSelectArea("QRY_AUX")
		DbCloseArea()
	ENDIF

	//Montando consulta de dados
	cQryAux := ""
	cQryAux += "SELECT * FROM TEMP_CICLI ORDER BY ARMZ,RUA,ENDERECO,COD"
	cQryAux := ChangeQuery(cQryAux)


	TCQuery cQryAux New Alias "QRY_AUX"

	dbSelectArea("QRY_AUX")
	TCSetField("QRY_AUX", "DATAINV", "D")
	Count to nTotal
	oReport:SetMeter(nTotal)

	QRY_AUX->(DbGotop())
	//TOTALIZADORES
	aTotais:={}
	nAcurado:=0
	nInacurado:=0
	nPosicao:=0
	nTotItens:=0
	nPerAcurado:=0
	nPerInacurado:=0


	nX:=0


	While !oReport:Cancel() .And. !QRY_AUX->(Eof())
		cARMZ:= QRY_AUX->ARMZ
		cRua :=QRY_AUX->RUA
		While QRY_AUX->RUA==cRua .and. QRY_AUX->ARMZ==cARMZ
			nAcurado:=nAcurado+QRY_AUX->ACURADO
			nInacurado:=nInacurado+QRY_AUX->INACURADO
			nPosicao:=nPosicao+QRY_AUX->POSICAO
			QRY_AUX->(DbSkip())

		EndDo
		IF lFilRua .and. cRua<>qRua
			Loop
		ELSE
			nTotItens:=nAcurado + nInacurado + nPosicao
			nPerAcurado:=round((nAcurado/nTotItens*100),2)
			nPerInacurado:=100-nPerAcurado
			Aadd(aTotais,{cARMZ,cRua,nTotItens,nAcurado,nInacurado,nPosicao,nPerAcurado,nPerInacurado})
			nTotItens:=0
			nAcurado:=0
			nInacurado:=0
			nPosicao:=0
		EndIf
	EndDo

	QRY_AUX->(DbGotop())

	While !oReport:Cancel() .And. !QRY_AUX->(Eof())

		oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
		oReport:IncMeter()
		//inicializo a primeira seção
		cRua := QRY_AUX->RUA
		cARMZ:= QRY_AUX->ARMZ
		oSection := oReport:Section(1)

		IF alltrim(cValToChar(MV_PAR06))=='1' //1=analitico;2=sintetico
			oSection:Cell("ARMZ"):SetBlock({|| cARMZ})
			oSection:Cell("RUA"):SetBlock({|| cRua})
		EndIf
		nX++
		//imprimo a primeira seção
		oSection:Cell("nTOTITENS"):SetValue(aTotais[nX,3])
		oSection:Cell("nACURADOS"):SetValue(aTotais[nX,4])
		oSection:Cell("nINACURADOS"):SetValue(aTotais[nX,5])
		oSection:Cell("nPOSICAO"):SetValue(aTotais[nX,6])
		oSection:Cell("npACURADOS"):SetValue(aTotais[nX,7])
		oSection:Cell("npINACURADOS"):SetValue(aTotais[nX,8])



		//Imprimindo a linha cabeçalho
		oSection:Init()
		IF lFilRua .and. cRua<>qRua
			Loop
		ELSE
			oSection:PrintLine()
		EndIf

		//inicializo a segunda seção
		oSection2 := oReport:Section(2)
		oSection2:init()
		While QRY_AUX->RUA==cRua .and. QRY_AUX->ARMZ==cARMZ
			//Incrementando a régua
			nAtual++
			//oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
			oReport:IncMeter()
			IF lFilRua .and. cRua<>qRua
				Loop
			ELSE
				IF alltrim(cValToChar(MV_PAR06))=='1' //1=analitico;2=sintetico
					oSection2:Printline()
				ENDIF
			ENDIF

			QRY_AUX->(DbSkip())

			If oReport:Cancel()
				Exit
			EndIf
		EndDo
		//finalizo a segunda seção para que seja reiniciada para o proximo registro
		oSection2:Finish()
		IF alltrim(cValToChar(MV_PAR06))=='1' //1=analitico;2=sintetico
			//imprimir uma linha para separar uma NCM de outra
			oReport:ThinLine()
			//finalizo a primeira seção
			oReport:ThinLine()
			oSection:Finish()
		EndIf

		
		//oReport:Line(oReport:Row(), oReport:Col(), oReport:Row(), oReport:Col() + 3400)

	EndDo
		
	//oSection:Finish()
	QRY_AUX->(DbCloseArea())

Return (NIL)


/* Executa a procedure dentro do banco*/
Static function sfProcCICLI(ARMZ,DTINI,DTFIM,TOL)
Local aResult := {}
Local nTol:=0
nTol:=val(TOL)
aResult := TCSPEXEC("sp_CICL_IND", ARMZ,DTINI,DTFIM,nTol)
 
IF empty(aResult)
Conout('Erro na execução da Stored Procedure : '+TcSqlError())
Else
Conout("Retorno String : "+aResult[1])
Conout("Retorno Numerico : "+str(aResult[2]))
MsgInfo("Procedure Executada")
Endif
 
Return( Nil )


