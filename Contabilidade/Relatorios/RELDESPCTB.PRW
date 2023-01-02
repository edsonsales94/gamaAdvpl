//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} 
Relatório - Relatório Despesas Contábil   
Solicitado pelo Sr.Aldyr/Controladoria
@author Ricky Moraes	
@since 21/02/2020
@version 1.0
/*/
	
User Function XRDESPCTB()
	Local aArea   := GetArea()
	Local oReport
	Local lEmail  := .F.
	Local cPara   := ""
	Private cPerg := ""
	
	//Definições da pergunta
	cPerg := "XDESPCTB  "
	
	//Se a pergunta não existir, zera a variável
	DbSelectArea("SX1")
	SX1->(DbSetOrder(1)) //X1_GRUPO + X1_ORDEM
	If ! SX1->(DbSeek(cPerg))
		cPerg := Nil 
	Else
	  pergunte(cperg,.f.)
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
	//Local oBreak := Nil
	
	//Criação do componente de impressão
	oReport := TReport():New(	"XDESPCTB",;		//Nome do Relatório
								"Relatório de Despesas Contábil",;		//Título
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
	TRCell():New(oSectDad, "FILIAL", "QRY_AUX", "Filial", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "TPCONTA", "QRY_AUX", "Tpconta", /*Picture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CONTA", "QRY_AUX", "Conta", /*Picture*/, 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CC", "QRY_AUX", "Carga", /*Picture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DATA", "QRY_AUX", "Data", /*Picture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "HIST", "QRY_AUX", "Hist", /*Picture*/, 40, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VLR_DEBITO", "QRY_AUX", "Vlr_debito", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VLR_CREDITO", "QRY_AUX", "Vlr_credito", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "SALDO", "QRY_AUX", "Saldo", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "RECNO", "QRY_AUX", "Recno", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "SEQUEN", "QRY_AUX", "Sequen", /*Picture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ORIGEM", "QRY_AUX", "Origem", /*Picture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NATUREZA", "QRY_AUX", "Natureza", /*Picture*/, 30, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DESCRICAO", "QRY_AUX", "Descricao", /*Picture*/, 100, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
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
	cQryAux += "		SELECT"		+ STR_PULA
	cQryAux += "		FILIAL,"		+ STR_PULA
	cQryAux += "		CASE   CT1_NORMAL "		+ STR_PULA
	cQryAux += "			 WHEN  '1' THEN 'D'"		+ STR_PULA
	cQryAux += "			 WHEN '2' THEN 'C'"		+ STR_PULA
	cQryAux += "		ELSE "		+ STR_PULA
	cQryAux += "			'BRANCO'"		+ STR_PULA
	cQryAux += "		END AS TPCONTA,"		+ STR_PULA
	cQryAux += "		 "		+ STR_PULA
	cQryAux += "		CONTA,"		+ STR_PULA
	cQryAux += "		CC,"		+ STR_PULA
	cQryAux += "		CAST(DATA1 AS DATE) [DATA],"		+ STR_PULA
	cQryAux += "		HIST,"		+ STR_PULA
	cQryAux += "		(DEBITO) VLR_DEBITO,"		+ STR_PULA
	cQryAux += "		(CREDITO) VLR_CREDITO,"		+ STR_PULA
	cQryAux += "		(IIF(CT1_NORMAL='1',"		+ STR_PULA
	cQryAux += "			(DEBITO)-(CREDITO),"		+ STR_PULA
	cQryAux += "			(CREDITO)-(DEBITO))) AS SALDO"		+ STR_PULA
	cQryAux += "		,RECNO"		+ STR_PULA
	cQryAux += "		,SEQUEN"		+ STR_PULA
	cQryAux += "		,COALESCE(CV3_TABORI,ROTINA) AS ORIGEM"		+ STR_PULA
	cQryAux += "		,COALESCE(ED_DESCRIC,'  ') NATUREZA"		+ STR_PULA
	cQryAux += "		,COALESCE(C7_DESCRI,B1_DESC,SE2.E2_HIST,'  ') DESCRICAO"		+ STR_PULA
	cQryAux += "		"		+ STR_PULA
	cQryAux += "		FROM("		+ STR_PULA
	cQryAux += "		SELECT "		+ STR_PULA
	cQryAux += "		CT2_FILIAL FILIAL,"		+ STR_PULA
	cQryAux += "		CT2D.CT2_DEBITO AS CONTA,"		+ STR_PULA
	cQryAux += "		CT2D.CT2_CCD AS CC,"		+ STR_PULA
	cQryAux += "		CT2D.CT2_DATA AS DATA1,"		+ STR_PULA
	cQryAux += "		CT2D.CT2_HIST AS HIST,"		+ STR_PULA
	cQryAux += "		CT2D.CT2_VALOR AS DEBITO,"		+ STR_PULA
	cQryAux += "		0 AS CREDITO,"		+ STR_PULA
	cQryAux += "		CT2D.R_E_C_N_O_  RECNO,"		+ STR_PULA
	cQryAux += "		CT2D.CT2_SEQUEN  SEQUEN,"		+ STR_PULA
	cQryAux += "		IIF(CT2D.CT2_ROTINA='CTBA102','MANUAL',CT2D.CT2_ROTINA) ROTINA"		+ STR_PULA
	cQryAux += "		FROM "		+ STR_PULA
	cQryAux += "		CT2010 CT2D"		+ STR_PULA
	cQryAux += "		WHERE"		+ STR_PULA
	cQryAux += "		CT2D.D_E_L_E_T_=''"		+ STR_PULA
	cQryAux += "		AND CT2D.CT2_DEBITO<>'' "	+ STR_PULA

	cQryAux += "		 AND CT2D.CT2_DATA>='" + DTOS(MV_PAR01) + "'"	+ STR_PULA
	cQryAux += "		 AND "		+ STR_PULA
	cQryAux += "		 CT2D.CT2_DATA<='" + DTOS(MV_PAR02) + "'"	+ STR_PULA
	cQryAux += "		 AND CT2D.CT2_FILIAL='01'"		+ STR_PULA






	cQryAux += "		"		+ STR_PULA
	cQryAux += "		UNION ALL"		+ STR_PULA
	cQryAux += "		"		+ STR_PULA
	cQryAux += "		SELECT "		+ STR_PULA
	cQryAux += "		CT2_FILIAL FILIAL,"		+ STR_PULA
	cQryAux += "		CT2C.CT2_CREDIT,"		+ STR_PULA
	cQryAux += "		CT2C.CT2_CCC,"		+ STR_PULA
	cQryAux += "		CT2C.CT2_DATA AS DATA1,"		+ STR_PULA
	cQryAux += "		CT2C.CT2_HIST AS HIST,"		+ STR_PULA
	cQryAux += "		0 AS DEBITO,"		+ STR_PULA
	cQryAux += "		CT2C.CT2_VALOR AS CREDITO,"		+ STR_PULA
	cQryAux += "		CT2C.R_E_C_N_O_ RECNO,"		+ STR_PULA
	cQryAux += "		CT2C.CT2_SEQUEN SEQUEN,"		+ STR_PULA
	cQryAux += "		IIF(CT2C.CT2_ROTINA='CTBA102','MANUAL',CT2C.CT2_ROTINA) ROTINA"		+ STR_PULA
	cQryAux += "		FROM "		+ STR_PULA
	cQryAux += "		CT2010 CT2C"		+ STR_PULA
	cQryAux += "		WHERE"		+ STR_PULA
	cQryAux += "		CT2C.D_E_L_E_T_=''"		+ STR_PULA
	cQryAux += "	   AND CT2C.CT2_CREDIT<>'' AND "	+ STR_PULA
	
	cQryAux += "		 CT2C.CT2_DATA>='" + DTOS(MV_PAR01) + "'"	+ STR_PULA
	cQryAux += "		 AND "		+ STR_PULA
	cQryAux += "		 CT2C.CT2_DATA<='" + DTOS(MV_PAR02) + "'"	+ STR_PULA
	cQryAux += "		 AND CT2C.CT2_FILIAL='01'"		+ STR_PULA

	
	cQryAux += "	) AS TMP"		+ STR_PULA
	cQryAux += "	INNER JOIN CT1010 CT1 ON CT1.D_E_L_E_T_='' AND CT1_CONTA=CONTA"		+ STR_PULA
	cQryAux += "	"		+ STR_PULA
	cQryAux += "	LEFT JOIN CV3010 CV3 ON  ("		+ STR_PULA
	cQryAux += "		CV3_FILIAL=FILIAL"		+ STR_PULA
	cQryAux += "		AND CV3_RECDES=RECNO "		+ STR_PULA
	cQryAux += "		AND CV3_SEQUEN=SEQUEN"		+ STR_PULA
	cQryAux += "		AND CV3.D_E_L_E_T_=''"		+ STR_PULA
	cQryAux += "		)"		+ STR_PULA
	cQryAux += "/* SD1 */"		+ STR_PULA
	cQryAux += "LEFT JOIN SD1010 SD12 ON ("		+ STR_PULA
	cQryAux += "	  SD12.D1_FILIAL = FILIAL"		+ STR_PULA
	cQryAux += "	  AND SD12.R_E_C_N_O_=CV3_RECORI"		+ STR_PULA
	cQryAux += "	  AND CV3_TABORI = 'SD1'"		+ STR_PULA
	cQryAux += "	)"		+ STR_PULA
	cQryAux += "	LEFT JOIN SB1010 SB1 ON ("		+ STR_PULA
	cQryAux += "	 B1_COD=D1_COD"		+ STR_PULA
	cQryAux += "	 AND SB1.D_E_L_E_T_=''"		+ STR_PULA
	cQryAux += "	 AND CV3_TABORI = 'SD1'"		+ STR_PULA
	cQryAux += "	)"		+ STR_PULA
	cQryAux += "	LEFT JOIN SC7010 SC7 ON	("		+ STR_PULA
	cQryAux += "	C7_FILIAL=FILIAL"		+ STR_PULA
	cQryAux += "	AND C7_NUM = D1_PEDIDO"		+ STR_PULA
	cQryAux += "	AND C7_ITEM = D1_ITEMPC"		+ STR_PULA
	cQryAux += "	AND SC7.D_E_L_E_T_=''"		+ STR_PULA
	cQryAux += "	AND CV3_TABORI = 'SD1'"		+ STR_PULA
	cQryAux += "	)"		+ STR_PULA
	cQryAux += "	LEFT JOIN SF1010 SF1 ON ("		+ STR_PULA
	cQryAux += "		F1_FILIAL= FILIAL"		+ STR_PULA
	cQryAux += "		AND D1_DOC = F1_DOC "		+ STR_PULA
	cQryAux += "		AND	D1_SERIE = F1_SERIE "		+ STR_PULA
	cQryAux += "		AND	D1_FORNECE = F1_FORNECE "		+ STR_PULA
	cQryAux += "		AND	D1_LOJA = F1_LOJA"		+ STR_PULA
	cQryAux += "		AND SF1.D_E_L_E_T_=''"		+ STR_PULA
	cQryAux += "		 AND CV3_TABORI = 'SD1'"		+ STR_PULA
	cQryAux += "	)"		+ STR_PULA
	cQryAux += "	LEFT JOIN SE2010 SE21 ON	("		+ STR_PULA
	cQryAux += "	    (SE21.E2_FILIAL+'|'+SE21.E2_PREFIXO+'|'+SE21.E2_NUM+'|'+SE21.E2_TIPO+'|'+SE21.E2_FORNECE+'|'+SE21.E2_LOJA)="		+ STR_PULA
	cQryAux += "		(D1_FILIAL+'|'+D1_SERIE+'|'+D1_DOC+'|'+'NF '+'|'+D1_FORNECE+'|'+D1_LOJA)"		+ STR_PULA
	cQryAux += "		AND SE21.D_E_L_E_T_=''"		+ STR_PULA
	cQryAux += "		 AND CV3_TABORI = 'SD1'"		+ STR_PULA
	cQryAux += "	)"		+ STR_PULA
	cQryAux += "	LEFT JOIN SE5010 SE5 ON SE5.D_E_L_E_T_='' AND E5_FILIAL=FILIAL"		+ STR_PULA
	cQryAux += "	AND SE5.R_E_C_N_O_=CV3_RECORI AND CV3_TABORI = 'SE5'"		+ STR_PULA
	cQryAux += "   LEFT JOIN FK2010 FK2 ON ("		+ STR_PULA
	cQryAux += "        FK2_FILIAL = FILIAL"		+ STR_PULA
	cQryAux += "        AND FK2_IDFK2 = E5_IDORIG"		+ STR_PULA
	cQryAux += "        AND FK2.D_E_L_E_T_ = ' '"		+ STR_PULA
	cQryAux += "    )"		+ STR_PULA
	cQryAux += "    LEFT JOIN FK7010 FK7 ON ("		+ STR_PULA
	cQryAux += "        FK7_FILIAL = FILIAL"		+ STR_PULA
	cQryAux += "        AND FK7_IDDOC = FK2_IDDOC"		+ STR_PULA
	cQryAux += "        AND FK7.D_E_L_E_T_ = ' '"		+ STR_PULA
	cQryAux += "    )"		+ STR_PULA
	cQryAux += "    LEFT JOIN FKA010 FKA ON ("		+ STR_PULA
	cQryAux += "        FKA.FKA_FILIAL = FILIAL"		+ STR_PULA
	cQryAux += "        AND FKA.FKA_IDORIG = E5_IDORIG"		+ STR_PULA
	cQryAux += "        AND FKA.FKA_TABORI = 'FK2'"		+ STR_PULA
	cQryAux += "        AND FKA.D_E_L_E_T_ = ' '"		+ STR_PULA
	cQryAux += "    )"		+ STR_PULA
	cQryAux += "    LEFT JOIN FKA010 FKA2 ON ("		+ STR_PULA
	cQryAux += "        FKA2.FKA_FILIAL = FILIAL"		+ STR_PULA
	cQryAux += "        AND FKA2.FKA_IDPROC = FKA.FKA_IDPROC"		+ STR_PULA
	cQryAux += "        AND FKA2.FKA_TABORI = 'FK5'"		+ STR_PULA
	cQryAux += "        AND FKA2.D_E_L_E_T_ = ' '"		+ STR_PULA
	cQryAux += "    )"		+ STR_PULA
	cQryAux += "    LEFT JOIN FK5010 FK5 ON ("		+ STR_PULA
	cQryAux += "        FK5_FILIAL = FILIAL"		+ STR_PULA
	cQryAux += "        AND FK5_IDMOV = FKA2.FKA_IDORIG"		+ STR_PULA
	cQryAux += "        AND FK5.D_E_L_E_T_ = ' '"		+ STR_PULA
	cQryAux += "    )"		+ STR_PULA
	cQryAux += "	"		+ STR_PULA
	cQryAux += "		LEFT JOIN SE2010 SE2 ON ("		+ STR_PULA
	cQryAux += "		SE2.E2_FILIAL=FILIAL"		+ STR_PULA
	cQryAux += "		AND SE2.R_E_C_N_O_=CV3_RECORI"		+ STR_PULA
	cQryAux += "		AND SE2.D_E_L_E_T_=''"		+ STR_PULA
	cQryAux += "		AND CV3_TABORI='SE2'"		+ STR_PULA
	cQryAux += "	)"		+ STR_PULA
	cQryAux += "	LEFT JOIN SED010 SED ON	( "		+ STR_PULA
	cQryAux += "	ED_CODIGO=COALESCE (SE2.E2_NATUREZ,SE21.E2_NATUREZ,E5_NATUREZ)"		+ STR_PULA
	cQryAux += "	AND SED.D_E_L_E_T_='' "		+ STR_PULA
	cQryAux += "	"		+ STR_PULA
	cQryAux += ")"		+ STR_PULA
	cQryAux += "		"		+ STR_PULA
	cQryAux += "WHERE "
	cQryAux += "CONTA>='" + (MV_PAR03) + "'"	+ STR_PULA
	cQryAux += "AND "		+ STR_PULA
	cQryAux += "CONTA<='" + (MV_PAR04) + "'"	+ STR_PULA
	cQryAux += "GROUP BY CONTA,"		+ STR_PULA
	cQryAux += "		CC,"		+ STR_PULA
	cQryAux += "		DATA1,"		+ STR_PULA
	cQryAux += "		HIST,CT1_NORMAL,FILIAL,RECNO,SEQUEN"		+ STR_PULA
	cQryAux += "		,CV3_TABORI"		+ STR_PULA
	cQryAux += "		,C7_DESCRI,B1_DESC,C7_CC"		+ STR_PULA
	cQryAux += "		,SE2.E2_NATUREZ,SE21.E2_NATUREZ,E5_NATUREZ"		+ STR_PULA
	cQryAux += "		,ED_DESCRIC"		+ STR_PULA
	cQryAux += "		,ROTINA"		+ STR_PULA
	cQryAux += "		,SE2.E2_HIST,DEBITO,CREDITO"		+ STR_PULA
	cQryAux += "		"		+ STR_PULA
	cQryAux += "ORDER BY CONTA,CC,DATA1"		+ STR_PULA
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








	
