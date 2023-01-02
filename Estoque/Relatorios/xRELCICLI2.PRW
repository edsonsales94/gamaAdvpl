//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"

//Constantes
#Define STR_PULA		Chr(13)+Chr(10)

/*/{Protheus.doc} xRelCicl
Relatório - Relatorio Ciclico             
@author zReport
@since 04/03/21
@version 1.0
	@example
	u_xRelCicl()
	@obs Função gerada pelo zReport()
/*/

User Function XRCICLI2()
	Local aArea   := GetArea()
	Local oReport
	Local lEmail  := .F.
	Local cPara   := ""
	//Private cPerg := ""
	Private cPerg:= Padr("XRCICLI02",10)
	//gero a pergunta de modo oculto, ficando disponível no botão ações relacionadas
	DbSelectArea("SX1")
	SX1->(DbSetOrder(1)) //X1_GRUPO + X1_ORDEM
	If ! SX1->(DbSeek(cPerg))
		cPerg := Nil
	else
		pergunte(cPerg,.f.)

	EndIf

	//Cria as definições do relatório
	oReport := fReportDef()

	//Será enviado por e-Mail?
	If lEmail
		oReport:nRemoteType := NO_REMOTE
		oReport:cEmail := cPara
		oReport:nDevice := 3 //1-Arquivo,2-Impressora,3-email,4-Planilha e 5-Html
		oReport:SetPreview(.F.)
		oReport:Print(.F., "", .T.)
		//Senão, mostra a tela
	Else
		oReport:PrintDialog()
	EndIf

	RestArea(aArea)
Return

/*-------------------------------------------------------------------------------*
 | Func:  fReportDef                                                             |
 | Desc:  Função que monta a definição do relatório                              |
 *-------------------------------------------------------------------------------*/
	
Static Function fReportDef()
	Local oReport
	Local oSectDad := Nil
	Local oSectDad2 := Nil
	Local oBreak1 := Nil
	
	
	//Criação do componente de impressão
	oReport := TReport():New(	"RelCiclico",;		//Nome do Relatório
								"Relatório Cíclico - Status e Posição",;		//Título
								cPerg,;		//Pergunte ... Se eu defino a pergunta aqui, será impresso uma página com os parâmetros, conforme privilégio 101
								{|oReport| fRepPrint(oReport)},;		//Bloco de código que será executado na confirmação da impressão
								)		//Descrição
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9) //Folha A4
	oReport:SetPortrait()
	
	//Criando a seção de dados
	oSectDad := TRSection():New(	oReport,;		//Objeto TReport que a seção pertence
									"Lista Status/Posição",;		//Descrição da seção
									{"QRY_AUX"})		//Tabelas utilizadas, a primeira será considerada como principal da seção
	oSectDad:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha

	//Criando a seção de dados
	oSectDad2 := TRSection():New(	oReport,;		//Objeto TReport que a seção pertence
									"Resumo Subtotais",;		//Descrição da seção
									{"QRY_AUX2"})		//Tabelas utilizadas, a primeira será considerada como principal da seção
	oSectDad2:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	oSectDad2:SetLinesBefore(2)
	//Colunas do relatório
 


	TRCell():New(oSectDad, "LOCAL", "QRY_AUX", "Local", /*Picture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "RUA", "QRY_AUX", "Rua", /*Picture*/, 5, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,.F./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ENDERECO", "QRY_AUX", "Endereco", /*Picture*/, 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CODIGO", "QRY_AUX", "Codigo", /*Picture*/,18, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CLASSE", "QRY_AUX", "C-ABC", /*Picture*/, 7, /*lPixel*/,/*{|| code-block de impressao }*/,"CENTER"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,.F./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "QATU", "QRY_AUX", "Qtd.Atual", "@E 999,999,999.99" /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,.F./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "QINV", "QRY_AUX", "Qtd.Invent.", "@E 999,999,999.99" /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,.F./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "QMOM", "QRY_AUX", "Qtd.NoInvet.", "@E 999,999,999.99" /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,.F./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DIFINV", "QRY_AUX", "Dif.Invent.", "@E 999,999,999.99" /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,.F./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NVEZES", "QRY_AUX", "N.vezes ?", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DATAINV", "QRY_AUX", "Dt.Ult.Invent.", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)


	oBreak1 := TRBreak():New(oSectDad,oSectDad:Cell("RUA"),{ || "Total RUA --> "},.F.)
	TRFunction():New(oSectDad:Cell("ENDERECO"),NIL,"COUNT",oBreak1,,,,.F.,.F.)
	//oSectDad:SetHeaderBreak(.T.)



	

	aAdd(oSectDad:Cell("DIFINV"):aFormatCond, {"DIFINV < -10" ,,CLR_RED})
	aAdd(oSectDad:Cell("DIFINV"):aFormatCond, {"DIFINV > 10" ,,CLR_BLUE})
	//aAdd(oSection1:Cell("E1_VALOR"):aFormatCond, {"E1_VALOR > 100 .and. E1_VALOR < 1000" ,,CLR_GREEN})
	//aAdd(oSection1:Cell("E1_VALOR"):aFormatCond, {"E1_VALOR >= 1000" ,CLR_HGRAY,CLR_RED})
	//aAdd(oSection1:Cell("E1_VALOR"):aFormatCond, {"E1_VALOR >= "+cvaltochar(MV_PAR01) ,,CLR_RED})


	//Totalizadores
	//oFunTot1 := TRFunction():New(oSectDad:Cell("LOCAL"),,"COUNT",,,/*cPicture*/)
	//oFunTot1:SetEndReport(.F.)



	TRCell():New(oSectDad2, "LOCAL", "QRY_AUX2", "Local", /*Picture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad2, "RUA", "QRY_AUX2", "Rua", /*Picture*/, 20, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,.F./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad2, "SIM", "QRY_AUX2", "Registrados", "@E 999,999,999.99" /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,.F./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad2, "NAO", "QRY_AUX2", "Faltam", "@E 999,999,999.99" /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,.F./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad2, "GERAL", "QRY_AUX2", "Tot.Geral", "@E 999,999,999.99" /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,.F./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad2, "PCONC", "QRY_AUX2", "%Concluido", "@E 999,999,999.99" /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,.F./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	
	

Return oReport
	
/*-------------------------------------------------------------------------------*
 | Func:  fRepPrint                                                              |
 | Desc:  Função que imprime o relatório                                         |
 *-------------------------------------------------------------------------------*/
	
Static Function fRepPrint(oReport)
	Local aArea    := GetArea()
	Local cQryAux  := ""
	Local cQryAux2  := ""
	Local oSectDad := Nil
	Local oSectDad2 := Nil
	Local nAtual   := 0
	Local nTotal   := 0
	Local cStatus := ''

	//alert(cValToChar(MV_PAR05))
	If cValToChar(MV_PAR05) =='1'
		cStatus := '0'
	else
		cStatus := ''
	EndIf


	//IF alltrim(cValToChar(MV_PAR03))=='1'
	//Pegando as seções do relatório
	oSectDad := oReport:Section(1)
		
	//Montando consulta por Procedure LISTA
	//EXEC sp_CICL_LISTA '20200101','20211231','11','20'
	cQryAux := ""
	cQryAux += "EXEC sp_CICL_LISTA  '" + cValToChar(MV_PAR01) +"','"+cValToChar(MV_PAR02)+"','"+cValToChar(MV_PAR03)+"','"+cValToChar(MV_PAR04)+"'"
	cQryAux +=" ,'"+xFilial("ZTI")+"'"
	cQryAux +=" ,'"+cStatus+"'"
	//cQryAux := ChangeQuery(cQryAux)

	//Executando consulta e setando o total da régua
	TCQuery cQryAux New Alias "QRY_AUX"
	TCSetField("QRY_AUX", "DATAINV", "D")

	Count to nTotal
	oReport:SetMeter(nTotal)
	
	//Enquanto houver dados
	oSectDad:Init()
	QRY_AUX->(DbGoTop())
		While !oReport:Cancel() .And. ! QRY_AUX->(Eof()) 
		//Incrementando a régua
		nAtual++
		oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
		oReport:IncMeter()
		
		//Imprimindo a linha atual
		oSectDad:PrintLine()
		
		QRY_AUX->(DbSkip())
		EndDo
	oSectDad:Finish()
	QRY_AUX->(DbCloseArea())

	//IMPRIMIR SUBTOTAIS
	oReport:ThinLine()
	//EndIf //verifica se quer impressao analitico


	//Pegando as seções do relatório gerar os subtotais
	oSectDad2 := oReport:Section(2)
		
	//Montando consulta por Procedure LISTA
	//EXEC sp_CICL_SUBTOTAIS '20200101','20211231','11','11'
	cQryAux2 := ""
	cQryAux2 += "EXEC sp_CICL_SUBTOTAIS '" + cValToChar(MV_PAR01) +"','"+cValToChar(MV_PAR02)+"','"+cValToChar(MV_PAR03)+"','"+cValToChar(MV_PAR04)+"'"
	cQryAux2 +=" ,'"+xFilial("ZTI")+"'"
	cQryAux2 +=" ,'"+cStatus+"'"
	//cQryAux := ChangeQuery(cQryAux)
	//Executando consulta e setando o total da régua
	TCQuery cQryAux2 New Alias "QRY_AUX2"
	
	nAtual   := 0
	nTotal   := 0
	
	Count to nTotal

	oReport:SetMeter(nTotal)
	oReport:ThinLine()
	//Enquanto houver dados
	oSectDad2:Init()
	
	QRY_AUX2->(DbGoTop())
	While  !oReport:Cancel() .And. ! QRY_AUX2->(Eof())
		//Incrementando a régua
		nAtual++
		oReport:SetMsgPrint("Imprimindo Subtotais "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
		oReport:IncMeter()
		
		//Imprimindo a linha atual
		oSectDad2:PrintLine()
		
		QRY_AUX2->(DbSkip())
	EndDo
	oReport:ThinLine()
	oSectDad2:Finish()
	QRY_AUX2->(DbCloseArea())


	
	RestArea(aArea)
Return


