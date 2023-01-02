//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} RELDCI
Relatório - Relatorio DCI Mensal          
@author zReport
@since 02/08/19
@version 1.0
	@example
	u_RELDCI()
	@obs Função gerada pelo zReport()
/*/
	
User Function RELDCI()
	Local aArea   := GetArea()
	Local oReport
	Local lEmail  := .F.
	Local cPara   := ""
	Private cPerg := ""
	
		//Definições da pergunta
	cPerg := "CCOMPLETO "
	
	//Se a pergunta não existir, zera a variável
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
	Local oBreak := Nil
	
	//Criação do componente de impressão
	oReport := TReport():New(	"RELDCI",;		//Nome do Relatório
								"Relatorio DCI Mensal",;		//Título
								cPerg,;		//Pergunte ... Se eu defino a pergunta aqui, será impresso uma página com os parâmetros, conforme privilégio 101
								{|oReport| fRepPrint(oReport)},;		//Bloco de código que será executado na confirmação da impressão
								)		//Descrição
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9) //Folha A4
	oReport:SetLandscape()
	
	//Criando a seção de dados
	oSectDad := TRSection():New(	oReport,;		//Objeto TReport que a seção pertence
									"Dados",;		//Descrição da seção
									{"QRY_AUX"})		//Tabelas utilizadas, a primeira será considerada como principal da seção
	oSectDad:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Colunas do relatório
	TRCell():New(oSectDad, "NOTA_FISCAL", "QRY_AUX", "Nota_fiscal", /*Picture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "SERIE", "QRY_AUX", "Serie", /*Picture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CODIGO", "QRY_AUX", "Codigo", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DESC_PRODUTO", "QRY_AUX", "Desc_produto", /*Picture*/, 60, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DCR", "QRY_AUX", "DCR", /*Picture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "QTDE", "QRY_AUX", "Qtde", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NCM", "QRY_AUX", "Ncm", /*Picture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CFOP", "QRY_AUX", "Cfop", /*Picture*/, 5, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "UF1", "QRY_AUX", "UF", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "MUNICIPIO", "QRY_AUX", "Municipio", /*Picture*/, 40, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VALOR_UNITARIO", "QRY_AUX", "Valor_unitario", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VALOR_MERCADORIA", "QRY_AUX", "Valor_mercadoria", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "MES_ANO", "QRY_AUX", "Mes_ano", /*Picture*/, 7, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DT_EMISSAO", "QRY_AUX", "Dt_emissao", /*Picture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "TIPO", "QRY_AUX", "Tipo", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "PESSOA", "QRY_AUX", "Pessoa", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NOME", "QRY_AUX", "Nome", /*Picture*/, 40, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
//	TRCell():New(oSectDad, "CFIELD18", "QRY_AUX", "Cfield18", /*Picture*/, 14, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
//	TRCell():New(oSectDad, "FINANCEIRO", "QRY_AUX", "Financeiro", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
Return oReport
	
/*-------------------------------------------------------------------------------*
 | Func:  fRepPrint                                                              |
 | Desc:  Função que imprime o relatório                                         |
 *-------------------------------------------------------------------------------*/
	
Static Function fRepPrint(oReport)
	Local aArea    := GetArea()
	Local cQryAux  := ""
	Local oSectDad := Nil
	Local nAtual   := 0
	Local nTotal   := 0
	
	//Pegando as seções do relatório
	oSectDad := oReport:Section(1)
	
	//Montando consulta de dados
	cQryAux := ""
	cQryAux += "SELECT  "		+ STR_PULA
	cQryAux += "D2_DOC AS [NOTA_FISCAL],"		+ STR_PULA
	cQryAux += "D2_SERIE AS [SERIE],"		+ STR_PULA
	cQryAux += "D2_COD AS	[CODIGO],"		+ STR_PULA
	cQryAux += "B1_XDESCNF AS [DESC_PRODUTO],"		+ STR_PULA
	cQryAux += "B1_DCRE AS [DCR],"		+ STR_PULA
	cQryAux += "D2_QUANT AS [QTDE],"		+ STR_PULA
	cQryAux += "B1_POSIPI AS [NCM],"		+ STR_PULA
	cQryAux += "D2_CF AS	[CFOP],"		+ STR_PULA
	cQryAux += "F2_EST AS UF1,"		+ STR_PULA
	cQryAux += "COALESCE(A1_MUN,A2_MUN) AS	[MUNICIPIO],"		+ STR_PULA
	cQryAux += "D2_PRCVEN AS [VALOR_UNITARIO],"		+ STR_PULA
	cQryAux += "D2_TOTAL AS [VALOR_MERCADORIA],"		+ STR_PULA
	cQryAux += "(SUBSTRING(D2_EMISSAO,5,2)+'/'+SUBSTRING(D2_EMISSAO,1,4)) AS [MES_ANO],"		+ STR_PULA
	cQryAux += "CAST(D2_EMISSAO AS DATE) DT_EMISSAO,"		+ STR_PULA
	cQryAux += "(CASE WHEN F2_TIPO IN ('D', 'B') THEN 'DEV/BENE' ELSE 'VENDA' END) AS TIPO, "		+ STR_PULA
	cQryAux += "COALESCE(A2_TIPO,A1_PESSOA) AS PESSOA,"		+ STR_PULA
	cQryAux += "COALESCE(A1_NOME,A2_NOME) AS NOME, "		+ STR_PULA
	cQryAux += "COALESCE(A1_CGC,A2_CGC) [CNPJ/CPF],  "		+ STR_PULA
	cQryAux += "F4_DUPLIC AS FINANCEIRO"		+ STR_PULA
	cQryAux += "FROM "		+ STR_PULA
	cQryAux += "SD2010 SD2"		+ STR_PULA
	cQryAux += "INNER JOIN SB1010 SB1 ON SD2.D_E_L_E_T_='' AND SB1.D_E_L_E_T_='' AND B1_COD=D2_COD AND B1_TIPO='PA'"		+ STR_PULA
	cQryAux += "INNER JOIN SF2010 SF2 ON SF2.D_E_L_E_T_='' AND F2_FILIAL=D2_FILIAL AND  F2_DOC=D2_DOC AND F2_SERIE =D2_SERIE AND F2_CLIENTE=D2_CLIENTE AND "		+ STR_PULA
	cQryAux += "F2_LOJA=D2_LOJA AND F2_EST=D2_EST"		+ STR_PULA
	cQryAux += "INNER JOIN SF4010 SF4 ON SF4.D_E_L_E_T_='' AND D2_TES=F4_CODIGO"		+ STR_PULA
	cQryAux += "LEFT JOIN SA1010 SA1 ON  "		+ STR_PULA
	cQryAux += "A1_COD = F2_CLIENTE "		+ STR_PULA
	cQryAux += "AND A1_LOJA = F2_LOJA "		+ STR_PULA
	cQryAux += "AND A1_EST = F2_EST "		+ STR_PULA
	cQryAux += "AND SA1.D_E_L_E_T_ <> '*' "		+ STR_PULA
	cQryAux += "AND NOT (SF2.F2_TIPO IN ('D', 'B'))  "		+ STR_PULA
	cQryAux += "LEFT JOIN SA2010 SA2 ON SA2.A2_FILIAL = '01' "		+ STR_PULA
	cQryAux += "AND SA2.A2_COD = F2_CLIENTE "		+ STR_PULA
	cQryAux += "AND SA2.A2_LOJA = F2_LOJA "		+ STR_PULA
	cQryAux += "AND SA2.A2_EST = F2_EST "		+ STR_PULA
	cQryAux += "AND SA2.D_E_L_E_T_ <> '*'"		+ STR_PULA
	cQryAux += "AND SF2.F2_TIPO IN ('D', 'B')"		+ STR_PULA
	cQryAux += "WHERE D2_EMISSAO LIKE '%" + cValToChar(MV_PAR01) + "%'"
	cQryAux += " AND D2_FILIAL = " + CHR(39) + xFilial('SD2') +CHR(39)  
	cQryAux += " AND D2_EST<>'AM' AND D2_LOCAL='01'"		+ STR_PULA
	cQryAux += " ORDER BY D2_EMISSAO"		+ STR_PULA
	cQryAux := ChangeQuery(cQryAux)
	
	//Executando consulta e setando o total da régua
	TCQuery cQryAux New Alias "QRY_AUX"
	Count to nTotal
	oReport:SetMeter(nTotal)
	
	//Enquanto houver dados
	oSectDad:Init()
	QRY_AUX->(DbGoTop())
	While ! QRY_AUX->(Eof())
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
	
	RestArea(aArea)
Return
