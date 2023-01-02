//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} xCCOMPLE
Relatório - Relatorio CUSTO COMPLETO      
@author zReport
@since 24/04/19
@version 1.0
	@example
	u_xCCOMPLE()
	@obs Função gerada pelo zReport()
/*/
	
User Function xCCOMPLE()
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
	oReport := TReport():New(	"xCCOMPLE",;		//Nome do Relatório
								"Relatorio CUSTO EM PARTES COMPLETO - ANO e MES  " ,;		//Título
								cPerg,;		//Pergunte ... Se eu defino a pergunta aqui, será impresso uma página com os parâmetros, conforme privilégio 101
								{|oReport| fRepPrint(oReport)},;		//Bloco de código que será executado na confirmação da impressão
								)		//Descrição
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(10) //Folha A4
	//oReport:SetPortrait() retrato
	oReport:SetLandScape() //paisagem
	
	
	//Criando a seção de dados
	oSectDad := TRSection():New(	oReport,;		//Objeto TReport que a seção pertence
									"Dados",;		//Descrição da seção
									{"QRY_AUX"})		//Tabelas utilizadas, a primeira será considerada como principal da seção
	oSectDad:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Colunas do relatório
	TRCell():New(oSectDad, "CODIGO", "QRY_AUX", "Codigo", /*Picture*/, 17, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DESC_PA", "QRY_AUX", "Desc_pa", /*Picture*/, 50, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "QTD_PRD", "QRY_AUX", "Qtd_prd", PesqPict("SC2","C2_QUANT" ), 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "C_TOTAL", "QRY_AUX", "C_total", PesqPict("SB2","B2_VATU1" ), 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "C_UNIT", "QRY_AUX", "C_unit", PesqPict("SB2","B2_VATU1" ), 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "MOD_GERAL", "QRY_AUX", "Mod_geral", PesqPict("SB2","B2_VATU1" ), 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "MOI_GERAL", "QRY_AUX", "Moi_geral", PesqPict("SB2","B2_VATU1" ), 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "GIF_GERAL", "QRY_AUX", "Gif_geral", PesqPict("SB2","B2_VATU1" ), 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CFIELD9", "QRY_AUX", "Mp+Em_geral", PesqPict("SB2","B2_VATU1" ), 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "MOD_UNIT", "QRY_AUX", "Mod_unit", PesqPict("SB2","B2_VATU1" ), 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "MOI_UNIT", "QRY_AUX", "Moi_unit",PesqPict("SB2","B2_VATU1" ), 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "GIF_UNIT", "QRY_AUX", "Gif_unit", PesqPict("SB2","B2_VATU1" ), 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CFIELD13", "QRY_AUX", "Mp+Em_unit", PesqPict("SB2","B2_VATU1" ), 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "MOD_PERC", "QRY_AUX", "Mod_%", PesqPict("SB2","B2_VATU1" ), 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "MOI_PERC", "QRY_AUX", "Moi_%", PesqPict("SB2","B2_VATU1" ), 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "GIF_PERC", "QRY_AUX", "Gif_%", PesqPict("SB2","B2_VATU1" ), 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CFIELD17", "QRY_AUX", "Mp+Em_%", PesqPict("SB2","B2_VATU1" ), 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
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
	Local cAno := SUBSTR(cValToChar(MV_PAR01),1,4)
	Local cMes := UPPER(MesExtenso( SUBSTR(cValToChar(MV_PAR01),5,2)) )
	Local cTitulo :='Relatório CUSTO EM PARTES COMPLETO - Ano: '  + cAno + ' Mês: ' + cMes
	
	oReport:SetTitle(cTitulo) 
	
	//Pegando as seções do relatório
	oSectDad := oReport:Section(1)
	
	//Montando consulta de dados
	cQryAux := ""
	cQryAux += "SELECT "		+ STR_PULA
	cQryAux += "CODIGO,DESC_PA,D3_QUANT AS QTD_PRD,C_AP_GERAL AS C_TOTAL,"		+ STR_PULA
	cQryAux += "(C_AP_GERAL/D3_QUANT) C_UNIT,"		+ STR_PULA
	cQryAux += "SUM(CASE WHEN TIPO_COMP2 ='MOD' THEN C_EST_CAL END) AS 'MOD_GERAL',"		+ STR_PULA
	cQryAux += "SUM(CASE WHEN TIPO_COMP2 ='MOI' THEN C_EST_CAL END) AS 'MOI_GERAL',"		+ STR_PULA
	cQryAux += "SUM(CASE WHEN TIPO_COMP2 ='GIF' THEN C_EST_CAL END) AS 'GIF_GERAL',"		+ STR_PULA
	cQryAux += "SUM(CASE WHEN TIPO_COMP2 ='MP+EM' THEN C_EST_CAL END) AS 'MP+EM_GERAL',"		+ STR_PULA
	cQryAux += "SUM(CASE WHEN TIPO_COMP2 ='MOD' THEN C_EST_CAL_UNIT END) AS 'MOD_UNIT',"		+ STR_PULA
	cQryAux += "SUM(CASE WHEN TIPO_COMP2 ='MOI' THEN C_EST_CAL_UNIT END) AS 'MOI_UNIT',"		+ STR_PULA
	cQryAux += "SUM(CASE WHEN TIPO_COMP2 ='GIF' THEN C_EST_CAL_UNIT END) AS 'GIF_UNIT',"		+ STR_PULA
	cQryAux += "SUM(CASE WHEN TIPO_COMP2 ='MP+EM' THEN C_EST_CAL_UNIT END) AS 'MP+EM_UNIT',"		+ STR_PULA
	cQryAux += "SUM(CASE WHEN TIPO_COMP2 ='MOD' THEN PORC_EST END) AS 'MOD_PERC',"		+ STR_PULA
	cQryAux += "SUM(CASE WHEN TIPO_COMP2 ='MOI' THEN PORC_EST END) AS 'MOI_PERC',"		+ STR_PULA
	cQryAux += "SUM(CASE WHEN TIPO_COMP2 ='GIF' THEN PORC_EST END) AS 'GIF_PERC',"		+ STR_PULA
	cQryAux += "SUM(CASE WHEN TIPO_COMP2 ='MP+EM' THEN PORC_EST END) AS 'MP+EM_PERC'"		+ STR_PULA
	cQryAux += " FROM ("		+ STR_PULA
	cQryAux += "SELECT "		+ STR_PULA
	cQryAux += "((CUSTO_ESTIMADO*100)/CUSTO_TOTAL_ESTIMADO) AS PORC_EST,"		+ STR_PULA
	cQryAux += "(((CUSTO_ESTIMADO*100)/CUSTO_TOTAL_ESTIMADO)/100)*C_AP_GERAL AS C_EST_CAL,"		+ STR_PULA
	cQryAux += "((((CUSTO_ESTIMADO*100)/CUSTO_TOTAL_ESTIMADO)/100)*C_AP_GERAL)/D3_QUANT AS C_EST_CAL_UNIT,"		+ STR_PULA
	cQryAux += "* FROM "		+ STR_PULA
	cQryAux += "("		+ STR_PULA
	cQryAux += "SELECT "		+ STR_PULA
	cQryAux += "("		+ STR_PULA
	cQryAux += "SELECT SUM(CUSTO_TOTAL) AS CUSTO_ESTIMADO"		+ STR_PULA
	cQryAux += "FROM("		+ STR_PULA
	cQryAux += "SELECT (QTD*B2_CMFIM1)*D3_QUANT CUSTO_TOTAL ,"		+ STR_PULA
	cQryAux += "       C_AP_GERAL,CODIGO,DESCRI,COD_COMP,TIPO_COMP,QTD,B1_LOCPAD,B2_CMFIM1,D3_QUANT,"		+ STR_PULA
	cQryAux += "       CASE "		+ STR_PULA
	cQryAux += "       WHEN SUBSTRING(COD_COMP,1,4) ='MOD7'    THEN 'GIF'"		+ STR_PULA
	cQryAux += "       WHEN SUBSTRING(COD_COMP,1,4)= 'MOD8'    THEN 'MOI'"		+ STR_PULA
	cQryAux += "       WHEN SUBSTRING(COD_COMP,1,4)= 'MOD9'    THEN 'MOD'"		+ STR_PULA
	cQryAux += "  ELSE 'MP+EM'"		+ STR_PULA
	cQryAux += "END AS TIPO_COMP2"		+ STR_PULA
	cQryAux += "      "		+ STR_PULA
	cQryAux += "       FROM VW_SG1 INNER JOIN SB1010 SB1"		+ STR_PULA
	cQryAux += "       ON B1_COD = COD_COMP"		+ STR_PULA
	cQryAux += "       INNER JOIN SB2010 SB2"		+ STR_PULA
	cQryAux += "       ON B1_COD = B2_COD"		+ STR_PULA
	cQryAux += "       AND B1_LOCPAD  = B2_LOCAL"		+ STR_PULA
	cQryAux += "       AND B2_FILIAL  = '01'"		+ STR_PULA
	cQryAux += "       INNER JOIN"		+ STR_PULA
	cQryAux += "       (SELECT SUM(D3_QUANT) D3_QUANT,SUM(D3_CUSTO1) C_AP_GERAL ,D3_COD FROM SD3010"		+ STR_PULA
	cQryAux += "       WHERE D_E_L_E_T_ = ''"		+ STR_PULA
	cQryAux += "       AND D3_CF IN ('PR0','PR1') AND D3_ESTORNO<>'S' "		+ STR_PULA
	cQryAux += "       AND D3_EMISSAO LIKE '%" + cValToChar(MV_PAR01) + "%'"		+ STR_PULA
	cQryAux += "       AND D3_TIPO  = 'PA'"		+ STR_PULA
	cQryAux += "       AND D3_FILIAL = '01'"		+ STR_PULA
	cQryAux += "       AND D3_OP NOT IN (SELECT DISTINCT D3_OP FROM SD3010"		+ STR_PULA
	cQryAux += "                                        WHERE D_E_L_E_T_  = ''"		+ STR_PULA
	cQryAux += "                                        AND D3_CF NOT IN ('PR0','PR1') AND D3_ESTORNO<>'S'"		+ STR_PULA
	cQryAux += "                                        AND D3_EMISSAO LIKE '%" + cValToChar(MV_PAR01) + "%'"		+ STR_PULA
	cQryAux += "                                        AND D3_TIPO  = 'PA'"		+ STR_PULA
	cQryAux += "                                        AND D3_FILIAL = '01'"		+ STR_PULA
	cQryAux += "                                        AND D3_OP <> '')"		+ STR_PULA
	cQryAux += "GROUP BY D3_COD)"		+ STR_PULA
	cQryAux += "AS APONTAMENTOS"		+ STR_PULA
	cQryAux += "ON D3_COD = CODIGO"		+ STR_PULA
	cQryAux += "WHERE CODIGO=CODIGO_B1 AND "		+ STR_PULA
	cQryAux += "TIPO_COMP<>'PI'"		+ STR_PULA
	cQryAux += "AND SB1.D_E_L_E_T_ = ''"		+ STR_PULA
	cQryAux += "AND SB2.D_E_L_E_T_ = ''"		+ STR_PULA
	cQryAux += ") AS MOVIMENTOS"		+ STR_PULA
	cQryAux += ")"		+ STR_PULA
	cQryAux += "AS CUSTO_TOTAL_ESTIMADO,"		+ STR_PULA
	cQryAux += "SUM(CUSTO_TOTAL) AS CUSTO_ESTIMADO,C_AP_GERAL,TIPO_COMP2,D3_QUANT,D3_COD,CODIGO,DESC_PA"		+ STR_PULA
	cQryAux += "FROM("		+ STR_PULA
	cQryAux += "SELECT (QTD*B2_CMFIM1)*D3_QUANT CUSTO_TOTAL ,"		+ STR_PULA
	cQryAux += "       C_AP_GERAL,CODIGO,DESCRI,COD_COMP,TIPO_COMP,QTD,SB1.B1_LOCPAD,B2_CMFIM1,D3_COD,D3_QUANT,SB12.B1_COD AS CODIGO_B1,SB12.B1_DESC AS DESC_PA,"		+ STR_PULA
	cQryAux += "       CASE "		+ STR_PULA
	cQryAux += "       WHEN SUBSTRING(COD_COMP,1,4) ='MOD7'    THEN 'GIF'"		+ STR_PULA
	cQryAux += "       WHEN SUBSTRING(COD_COMP,1,4)= 'MOD8'    THEN 'MOI'"		+ STR_PULA
	cQryAux += "       WHEN SUBSTRING(COD_COMP,1,4)= 'MOD9'    THEN 'MOD'"		+ STR_PULA
	cQryAux += "  ELSE 'MP+EM'"		+ STR_PULA
	cQryAux += "END AS TIPO_COMP2"		+ STR_PULA
	cQryAux += "      "		+ STR_PULA
	cQryAux += "       FROM VW_SG1 INNER JOIN SB1010 SB1"		+ STR_PULA
	cQryAux += "       ON B1_COD = COD_COMP"		+ STR_PULA
	cQryAux += "       INNER JOIN SB2010 SB2"		+ STR_PULA
	cQryAux += "       ON B1_COD = B2_COD"		+ STR_PULA
	cQryAux += "       AND B1_LOCPAD  = B2_LOCAL"		+ STR_PULA
	cQryAux += "       AND B2_FILIAL  = '01'"		+ STR_PULA
	cQryAux += "       INNER JOIN SB1010 SB12"		+ STR_PULA
	cQryAux += "	   ON SB12.B1_COD = CODIGO"		+ STR_PULA
	cQryAux += "	   AND SB12.D_E_L_E_T_ = ''"		+ STR_PULA
	cQryAux += "	   INNER JOIN"		+ STR_PULA
	cQryAux += "       (SELECT SUM(D3_QUANT) D3_QUANT,SUM(D3_CUSTO1) C_AP_GERAL ,D3_COD FROM SD3010"		+ STR_PULA
	cQryAux += "       WHERE D_E_L_E_T_ = ''"		+ STR_PULA
	cQryAux += "       AND D3_CF IN ('PR0','PR1') AND D3_ESTORNO<>'S'"		+ STR_PULA
	cQryAux += "       AND D3_EMISSAO LIKE '%" + cValToChar(MV_PAR01) + "%'"		+ STR_PULA
	cQryAux += "       AND D3_TIPO  = 'PA'"		+ STR_PULA
	cQryAux += "       AND D3_FILIAL = '01'"		+ STR_PULA
	cQryAux += "       AND D3_OP NOT IN (SELECT DISTINCT D3_OP FROM SD3010"		+ STR_PULA
	cQryAux += "                                        WHERE D_E_L_E_T_  = ''"		+ STR_PULA
	cQryAux += "                                        AND D3_CF NOT IN ('PR0','PR1') AND D3_ESTORNO<>'S'"		+ STR_PULA
	cQryAux += "                                        AND D3_EMISSAO LIKE '%" + cValToChar(MV_PAR01) + "%'"		+ STR_PULA
	cQryAux += "                                        AND D3_TIPO  = 'PA'"		+ STR_PULA
	cQryAux += "                                        AND D3_FILIAL = '01'"		+ STR_PULA
	cQryAux += "                                        AND D3_OP <> '')"		+ STR_PULA
	cQryAux += "GROUP BY D3_COD)"		+ STR_PULA
	cQryAux += "AS APONTAMENTOS"		+ STR_PULA
	cQryAux += "ON D3_COD = CODIGO"		+ STR_PULA
	cQryAux += "WHERE TIPO_COMP<>'PI'"		+ STR_PULA
	cQryAux += "AND SB1.D_E_L_E_T_ = ''"		+ STR_PULA
	cQryAux += "AND SB2.D_E_L_E_T_ = ''"		+ STR_PULA
	cQryAux += ") AS MOVIMENTOS"		+ STR_PULA
	cQryAux += "GROUP BY TIPO_COMP2,D3_QUANT,CODIGO,C_AP_GERAL,D3_COD,CODIGO_B1,DESC_PA"		+ STR_PULA
	cQryAux += ") AS CUSTOS_ESTIMADO"		+ STR_PULA
	cQryAux += ") CUSTO_ESTIMADOS_FINAIS"		+ STR_PULA
	cQryAux += "GROUP BY CODIGO,DESC_PA,D3_QUANT,C_AP_GERAL"		+ STR_PULA
	cQryAux += "ORDER BY CODIGO"		+ STR_PULA
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
