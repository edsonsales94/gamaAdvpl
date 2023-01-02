//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} xSG1SD3
Relatório - Relatorio SG1 X SD3           
@author zReport
@since 25/04/19
@version 1.0
	@example
	u_xSG1SD3()
	@obs Função gerada pelo zReport()
/*/
	
User Function xSG1SD3()
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
	oReport := TReport():New(	"xSG1SD3",;		//Nome do Relatório
								"Relatório SG1 X SD3",;		//Título
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
	TRCell():New(oSectDad, "ANOMES", "QRY_AUX", "Anomes", /*Picture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D3_OP", "QRY_AUX", "Ord Producao", /*Picture*/, 14, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D3_DOC", "QRY_AUX", "Documento", /*Picture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D3_IDENT", "QRY_AUX", "Iden. OP Pai", /*Picture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "TIPO", "QRY_AUX", "Tipo", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "FAMILIA", "QRY_AUX", "Familia", /*Picture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "C2_PRODUTO", "QRY_AUX", "Produto", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "PRODUTO", "QRY_AUX", "Produto", /*Picture*/, 50, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "QTD_APONTDA", "QRY_AUX", "Qtd_apontda", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "MOD1", "QRY_AUX", "Mod1", /*Picture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D3_COD", "QRY_AUX", "Produto", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "QTDUNIT_SD3", "QRY_AUX", "Qtdunit_sd3", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "QTDUNIT_HR_SG1", "QRY_AUX", "Qtdunit_hr_sg1", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "QTD_HR_NO_AP", "QRY_AUX", "Qtd_hr_no_ap", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "QTD_HR_APOS", "QRY_AUX", "Qtd_hr_apos", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
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
	cQryAux += "SELECT"		+ STR_PULA
	cQryAux += "SUBSTRING(D3_EMISSAO,1,6) AS ANOMES, "		+ STR_PULA
	cQryAux += "D3_OP"		+ STR_PULA
	cQryAux += ",D3_DOC"		+ STR_PULA
	cQryAux += ",D3_IDENT"		+ STR_PULA
	cQryAux += ",SB1A1.B1_TIPO TIPO"		+ STR_PULA
	cQryAux += ", CASE WHEN SUBSTRING(C2_PRODUTO,1,3) = 'APP' THEN 'PA'"		+ STR_PULA
	cQryAux += "	   WHEN SUBSTRING(C2_PRODUTO,1,3) = 'ASS' THEN 'PA'"		+ STR_PULA
	cQryAux += "	   WHEN SUBSTRING(C2_PRODUTO,1,3) = 'BEC' THEN 'PA'"		+ STR_PULA
	cQryAux += "	   ELSE"		+ STR_PULA
	cQryAux += "	   'OUTROS'"		+ STR_PULA
	cQryAux += "	END FAMILIA"		+ STR_PULA
	cQryAux += ",C2_PRODUTO, SB1A1.B1_DESC AS PRODUTO"		+ STR_PULA
	cQryAux += ",(SELECT D3_QUANT FROM SD3010 SD3_PR0 (NOLOCK) WHERE SD3_PR0.D_E_L_E_T_='' AND SD3_PR0.D3_ESTORNO='' AND SD3_PR0.D3_DOC=SD3.D3_DOC AND SD3_PR0.D3_COD=C2_PRODUTO AND D3_CF='PR0' AND SD3_PR0.D3_IDENT=SD3.D3_IDENT AND SD3_PR0.D3_FILIAL=C2_FILIAL) AS QTD_APONTDA"		+ STR_PULA
	cQryAux += ",CASE WHEN SUBSTRING(D3_COD,1,4) = 'MOD7' THEN 'GIF'"		+ STR_PULA
	cQryAux += "	 WHEN SUBSTRING(D3_COD,1,4) = 'MOD8' THEN 'MOI'"		+ STR_PULA
	cQryAux += "	 WHEN SUBSTRING(D3_COD,1,4) = 'MOD9' THEN 'MOD'"		+ STR_PULA
	cQryAux += "	 ELSE"		+ STR_PULA
	cQryAux += "	 ''"		+ STR_PULA
	cQryAux += "END MOD1"		+ STR_PULA
	cQryAux += ",D3_COD"		+ STR_PULA
	cQryAux += ",D3_QUANT/(SELECT D3_QUANT FROM SD3010 SD3_PR0 WHERE SD3_PR0.D_E_L_E_T_='' AND SD3_PR0.D3_ESTORNO='' AND SD3_PR0.D3_DOC=SD3.D3_DOC AND SD3_PR0.D3_COD=C2_PRODUTO AND D3_CF='PR0' AND SD3_PR0.D3_IDENT=SD3.D3_IDENT AND SD3_PR0.D3_FILIAL=C2_FILIAL) AS QTDUNIT_SD3"		+ STR_PULA
	cQryAux += ",(SELECT SUM(QTD)/COUNT(*) FROM VW_SG1 WHERE CODIGO=C2_PRODUTO AND COD_COMP=SD3.D3_COD AND (FTM_PAI='S' OR NIVEL=1 ) ) AS QTDUNIT_HR_SG1"		+ STR_PULA
	cQryAux += ",D3_QUANT AS QTD_HR_NO_AP"		+ STR_PULA
	cQryAux += ",((SELECT SUM(QTD) FROM VW_SG1 WHERE CODIGO=C2_PRODUTO AND COD_COMP=SD3.D3_COD AND (FTM_PAI='S' OR NIVEL=1)  ) * (SELECT D3_QUANT FROM SD3010 SD3_PR0 WHERE SD3_PR0.D_E_L_E_T_='' AND SD3_PR0.D3_ESTORNO='' AND SD3_PR0.D3_DOC=SD3.D3_DOC AND SD3_PR0.D3_COD=C2_PRODUTO AND D3_CF='PR0' AND SD3_PR0.D3_IDENT=SD3.D3_IDENT AND SD3_PR0.D3_FILIAL=C2_FILIAL) ) AS QTD_HR_APOS"		+ STR_PULA
	cQryAux += "FROM "		+ STR_PULA
	cQryAux += "SC2010 SC2 (NOLOCK)"		+ STR_PULA
	cQryAux += "INNER JOIN SD3010 SD3 (NOLOCK) ON "		+ STR_PULA
	cQryAux += "C2_NUM+'01001'=D3_OP AND SC2.D_E_L_E_T_='' AND SD3.D_E_L_E_T_='' AND  C2_FILIAL='01' AND C2_STATUS='N' AND SD3.D3_COD LIKE 'MOD%' AND SD3.D3_ESTORNO='' "		+ STR_PULA
	cQryAux += "AND SD3.D3_EMISSAO LIKE '" + cValToChar(MV_PAR01) + "%' AND SD3.D3_FILIAL='01' AND "		+ STR_PULA
	cQryAux += "SD3.D3_OP NOT IN (SELECT DISTINCT SD32.D3_OP FROM SD3010 SD32 WHERE SD32.D3_EMISSAO LIKE  '" + cValToChar(MV_PAR01) + "%'  AND SD32.D3_TIPO='PA' AND SD32.D_E_L_E_T_='' AND SD32.D3_FILIAL=C2_FILIAL AND D3_CF='RE1')		"		+ STR_PULA
	cQryAux += "INNER JOIN SB1010 SB1A1 (NOLOCK) ON C2_PRODUTO=SB1A1.B1_COD AND SB1A1.D_E_L_E_T_='' AND SB1A1.B1_FILIAL = '' "		+ STR_PULA
	cQryAux += "INNER JOIN SB1010 SB1A2 (NOLOCK) ON D3_COD=SB1A2.B1_COD AND SB1A2.D_E_L_E_T_='' AND SB1A2.B1_FILIAL = ''"		+ STR_PULA
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
