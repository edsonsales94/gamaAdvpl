//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} RSPEDICM
Relat�rio - Relatorio                     
@author zReport
@since 24/04/19
@version 1.0
	@example
	u_RSPEDICM()
	@obs Fun��o gerada pelo zReport()
/*/
	
User Function XRSPEDICM()
	Local aArea   := GetArea()
	Local oReport
	Local lEmail  := .F.
	Local cPara   := ""
	Private cPerg := ""
	
	//Defini��es da pergunta
	cPerg := "CCOMPLETO "
	
	//Se a pergunta n�o existir, zera a vari�vel
	DbSelectArea("SX1")
	SX1->(DbSetOrder(1)) //X1_GRUPO + X1_ORDEM
	If ! SX1->(DbSeek(cPerg))
		cPerg := Nil
	else
	 pergunte(cPerg,.f.)
 
	EndIf
	
	//Cria as defini��es do relat�rio
	oReport := fReportDef()
	
	//Ser� enviado por e-Mail?
	If lEmail
		oReport:nRemoteType := NO_REMOTE
		oReport:cEmail := cPara
		oReport:nDevice := 3 //1-Arquivo,2-Impressora,3-email,4-Planilha e 5-Html
		oReport:SetPreview(.F.)
		oReport:Print(.F., "", .T.)
	//Sen�o, mostra a tela
	Else
		oReport:PrintDialog()
	EndIf
	
	RestArea(aArea)
Return
	
/*-------------------------------------------------------------------------------*
 | Func:  fReportDef                                                             |
 | Desc:  Fun��o que monta a defini��o do relat�rio                              |
 *-------------------------------------------------------------------------------*/
	
Static Function fReportDef()
	Local oReport
	Local oSectDad := Nil
	Local oBreak := Nil
	
	//Cria��o do componente de impress�o
	oReport := TReport():New(	"RSPEDICM",;		//Nome do Relat�rio
								"Relat�rio SPED Apura��o x Entradas e Saidas ",;		//T�tulo
								cPerg,;		//Pergunte ... Se eu defino a pergunta aqui, ser� impresso uma p�gina com os par�metros, conforme privil�gio 101
								{|oReport| fRepPrint(oReport)},;		//Bloco de c�digo que ser� executado na confirma��o da impress�o
								)		//Descri��o
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9) //Folha A4
	oReport:SetLandscape()
	
	//Criando a se��o de dados
	oSectDad := TRSection():New(	oReport,;		//Objeto TReport que a se��o pertence
									"Dados",;		//Descri��o da se��o
									{"QRY_AUX"})		//Tabelas utilizadas, a primeira ser� considerada como principal da se��o
	oSectDad:SetTotalInLine(.F.)  //Define se os totalizadores ser�o impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Colunas do relat�rio
	TRCell():New(oSectDad, "ANOMES", "QRY_AUX", "Anomes", /*Picture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "TIPO", "QRY_AUX", "Tipo", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "FT_CLASFIS", "QRY_AUX", "Sit.Tribut.", /*Picture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "FT_CFOP", "QRY_AUX", "Cod. Fiscal", /*Picture*/, 5, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "FT_ALIQICM", "QRY_AUX", "Al�q. ICMS", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CDA_ALIQ", "QRY_AUX", "Aliquota", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VLCONT", "QRY_AUX", "Vlcont", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "BASEICMS", "QRY_AUX", "Baseicms", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VLICMS", "QRY_AUX", "Vlicms", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "OUTROSICMS", "QRY_AUX", "Outrosicms", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CDA_BASE", "QRY_AUX", "Valor Base", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CDA_VALOR", "QRY_AUX", "Valor", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CODLAN", "QRY_AUX", "Codlan", /*Picture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "STATUS", "QRY_AUX", "Status", /*Picture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
Return oReport
	
/*-------------------------------------------------------------------------------*
 | Func:  fRepPrint                                                              |
 | Desc:  Fun��o que imprime o relat�rio                                         |
 *-------------------------------------------------------------------------------*/
	
Static Function fRepPrint(oReport)
	Local aArea    := GetArea()
	Local cQryAux  := ""
	Local oSectDad := Nil
	Local nAtual   := 0
	Local nTotal   := 0
	Local cAno := SUBSTR(cValToChar(MV_PAR01),1,4)
	Local cMes := UPPER(MesExtenso( SUBSTR(cValToChar(MV_PAR01),5,2)) )
	Local cTitulo :='Relat�rio SPED Apura��o x Entradas e Saidas Ano: '  + cAno + ' M�s: ' + cMes
	
	oReport:SetTitle(cTitulo) 
	
	//Pegando as se��es do relat�rio
	oSectDad := oReport:Section(1)
	
	//Montando consulta de dados
	cQryAux := ""
	cQryAux += "SELECT "		+ STR_PULA
	cQryAux += "SUBSTRING(FT_ENTRADA,1,6) AS ANOMES,"		+ STR_PULA
	cQryAux += "FT_TIPOMOV AS TIPO,"		+ STR_PULA
	cQryAux += "FT_CLASFIS,"		+ STR_PULA
	cQryAux += "FT_CFOP,"		+ STR_PULA
	cQryAux += "FT_ALIQICM,"		+ STR_PULA
	cQryAux += "CDA_ALIQ,"		+ STR_PULA
	cQryAux += "SUM(FT_VALCONT) VLCONT,"		+ STR_PULA
	cQryAux += "SUM(FT_BASEICM) BASEICMS,"		+ STR_PULA
	cQryAux += "ISNULL(SUM(FT_VALICM),0) VLICMS,"		+ STR_PULA
	cQryAux += "SUM(FT_OUTRICM) OUTROSICMS,"		+ STR_PULA
	cQryAux += "ISNULL(SUM(CDA_BASE),0) CDA_BASE,"		+ STR_PULA
	cQryAux += "ISNULL(SUM(CDA_VALOR),0) CDA_VALOR,"		+ STR_PULA
	cQryAux += "ISNULL(CDA_CODLAN,'NAO') AS CODLAN,"		+ STR_PULA
	cQryAux += "  CASE "		+ STR_PULA
	cQryAux += "     WHEN ISNULL(SUM(FT_VALICM),0) =  ISNULL(SUM(CDA_VALOR),0)  THEN 'OK'"		+ STR_PULA
	cQryAux += "      ELSE 'VERIFICAR'"		+ STR_PULA
	cQryAux += "  END AS [STATUS]"		+ STR_PULA
	cQryAux += "FROM "		+ STR_PULA
	cQryAux += "SFT010 SFT"		+ STR_PULA
	cQryAux += "LEFT JOIN CDA010 CDA ON"		+ STR_PULA
	cQryAux += "CDA.D_E_L_E_T_=''"		+ STR_PULA
	cQryAux += "AND CDA_TPMOVI=FT_TIPOMOV "		+ STR_PULA
	cQryAux += "AND CDA_ESPECI=FT_ESPECIE"		+ STR_PULA
	cQryAux += "AND CDA_NUMERO=FT_NFISCAL"		+ STR_PULA
	cQryAux += "AND CDA_SERIE=FT_SERIE"		+ STR_PULA
	cQryAux += "AND CDA_CLIFOR=FT_CLIEFOR"		+ STR_PULA
	cQryAux += "AND CDA_LOJA=FT_LOJA"		+ STR_PULA
	cQryAux += "AND CDA_FILIAL=FT_FILIAL"		+ STR_PULA
	cQryAux += "AND CDA_NUMITE=FT_ITEM"		+ STR_PULA
	cQryAux += "WHERE "		+ STR_PULA
	cQryAux += "FT_ENTRADA LIKE '" + cValToChar(MV_PAR01) + "%'"		+ STR_PULA
	cQryAux += "AND SFT.D_E_L_E_T_='' "		+ STR_PULA
	cQryAux += "AND FT_FILIAL='01'"		+ STR_PULA
	cQryAux += "GROUP BY"		+ STR_PULA
	cQryAux += "FT_TIPOMOV,"		+ STR_PULA
	cQryAux += "FT_CLASFIS,"		+ STR_PULA
	cQryAux += "FT_CFOP,"		+ STR_PULA
	cQryAux += "FT_ALIQICM,"		+ STR_PULA
	cQryAux += "CDA_CODLAN,"		+ STR_PULA
	cQryAux += "SUBSTRING(FT_ENTRADA,1,6),"		+ STR_PULA
	cQryAux += "CDA_ALIQ"		+ STR_PULA
	cQryAux += "ORDER BY"		+ STR_PULA
	cQryAux += "SUBSTRING(FT_ENTRADA,1,6),"		+ STR_PULA
	cQryAux += "FT_TIPOMOV,"		+ STR_PULA
	cQryAux += "FT_CLASFIS,"		+ STR_PULA
	cQryAux += "FT_CFOP,"		+ STR_PULA
	cQryAux += "FT_ALIQICM"		+ STR_PULA
	cQryAux := ChangeQuery(cQryAux)
	
	//Executando consulta e setando o total da r�gua
	TCQuery cQryAux New Alias "QRY_AUX"
	Count to nTotal
	oReport:SetMeter(nTotal)
	
	//Enquanto houver dados
	oSectDad:Init()
	QRY_AUX->(DbGoTop())
	While ! QRY_AUX->(Eof())
		//Incrementando a r�gua
		nAtual++
		oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
		oReport:IncMeter()
		
		//Imprimindo a linha atual
		oSectDad:PrintLine()
		
		QRY_AUX->(DbSkip())
	EndDo
	oSectDad:Finish()
	QRY_AUX->(DbCloseArea())
	
	RestArea(aArea)
Return
