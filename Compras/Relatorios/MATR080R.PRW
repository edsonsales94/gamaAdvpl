//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} MATR080R
Relatório - Relatorio NFs X PCs           
@author zReport
@since 23/08/18
@version 1.0
	@example
	u_MATR080R()
	@obs Função gerada pelo zReport()
/*/
	
User Function MATR080R()
	Local aArea   := GetArea()
	Local oReport
	Local lEmail  := .F.
	Local cPara   := ""
	Private cPerg := ""
	
	//Definições da pergunta
	cPerg := "MATR080R"
	
	//Se a pergunta não existir, zera a variável
	DbSelectArea("SX1")
	SX1->(DbSetOrder(1)) //X1_GRUPO + X1_ORDEM
	If ! SX1->(DbSeek(cPerg))
		cPerg := Nil
	else
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
	Local oBreak := Nil
	
	//Criação do componente de impressão
	oReport := TReport():New(	"MATR080R",;		//Nome do Relatório
								"Relatorio NFs X PCs",;		//Título
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
	TRCell():New(oSectDad, "D1_TIPO", "QRY_AUX", "TipoDoc.", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "F1_DOC", "QRY_AUX", "NumeroNF", /*Picture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "F1_SERIE", "QRY_AUX", "Serie", /*Picture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D1_EMISSAO", "QRY_AUX", "DT Emissao", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D1_DTDIGIT", "QRY_AUX", "DT Digitacao", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D1_FORNECE", "QRY_AUX", "Forn/Cliente", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D1_LOJA", "QRY_AUX", "Loja", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "cFornec", " ", "Nome Fornec/Cliente", /*Picture*/, 40, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D1_COD", "QRY_AUX", "Produto", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DECRICAO_PRODUTO", "QRY_AUX", "Decricao_produto", /*Picture*/, 45, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D1_QUANT", "QRY_AUX", "Quantidade", PesqPict("SB2","B2_QATU" ), 11, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D1_VUNIT", "QRY_AUX", "Vlr.Unitario", PesqPict("SB2","B2_QATU" ), 11, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D1_TOTAL", "QRY_AUX", "Vlr.Total", PesqPict("SB2","B2_QATU" ), 11, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "F1_COND", "QRY_AUX", "Cod.de Pag", /*Picture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CFIELD15", "QRY_AUX", "Condicao de Pag", /*Picture*/, 25, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "TOT_PRODUTOS_NF", "QRY_AUX", "Tot_produtos_nf", PesqPict("SB2","B2_QATU" ), 11, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NUM_PEDIDO", "QRY_AUX", "Num_pedido", /*Picture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ITEM_PED", "QRY_AUX", "Item_ped", /*Picture*/, 4, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
Return oReport
	
/*-------------------------------------------------------------------------------*
 | Func:  fRepPrint                                                              |
 | Desc:  Função que imprime o relatório                                         |
 *-------------------------------------------------------------------------------*/
	
Static Function fRepPrint(oReport)
	Local aArea    := GetArea()
	Local cQryAux  := ""
	Local cQrySA  :=""

	
	Local oSectDad := Nil
	Local nAtual   := 0
	Local nTotal   := 0
	Local nTotalSA   := 0
	Local cFornec :=""
	
	//Pegando as seções do relatório
	oSectDad := oReport:Section(1)
	
	//Montando consulta de dados
	cQryAux := ""
	cQryAux += "SELECT "		+ STR_PULA
	cQryAux += "D1_TIPO,"		+ STR_PULA
	cQryAux += "F1_DOC,"		+ STR_PULA
	cQryAux += "F1_SERIE,"		+ STR_PULA
	cQryAux += "D1_EMISSAO,"		+ STR_PULA
	cQryAux += "D1_DTDIGIT,"		+ STR_PULA
	cQryAux += "D1_FORNECE,"		+ STR_PULA
	cQryAux += "D1_LOJA,"		+ STR_PULA
	cQryAux += "'NOME FORNC/CLIENTE' AS 'CLIENTE/FORNECE',"		+ STR_PULA
	cQryAux += "D1_COD,"		+ STR_PULA
	cQryAux += "ISNULL(C7_DESCRI,B1_DESC) AS DECRICAO_PRODUTO,"		+ STR_PULA
	cQryAux += "D1_QUANT,"		+ STR_PULA
	cQryAux += "D1_VUNIT,"		+ STR_PULA
	cQryAux += "D1_TOTAL,"		+ STR_PULA
	cQryAux += "F1_COND,"		+ STR_PULA
	cQryAux += "ISNULL(E4_DESCRI,'---'),"		+ STR_PULA
	cQryAux += "F1_VALMERC AS TOT_PRODUTOS_NF,"		+ STR_PULA
	cQryAux += "ISNULL(C7_NUM,'S/PC.') AS NUM_PEDIDO,"		+ STR_PULA
	cQryAux += "ISNULL(C7_ITEM,'---') AS ITEM_PED"		+ STR_PULA
	cQryAux += "FROM "		+ STR_PULA
	cQryAux += "SF1010 SF1 INNER JOIN  SD1010 SD1 ON "		+ STR_PULA
	cQryAux += "D1_DOC= F1_DOC AND D1_SERIE=F1_SERIE AND D1_FORNECE=F1_FORNECE AND D1_LOJA=F1_LOJA AND SF1.D_E_L_E_T_='' AND SD1.D_E_L_E_T_=''"		+ STR_PULA
	cQryAux += "INNER JOIN SB1010 SB1 ON D1_COD=B1_COD AND SB1.D_E_L_E_T_=''"		+ STR_PULA
	cQryAux += "LEFT JOIN SC7010 SC7  ON  D1_FILIAL=C7_FILIAL AND D1_PEDIDO=C7_NUM AND D1_ITEMPC=C7_ITEM AND SC7.D_E_L_E_T_='' "		+ STR_PULA
	cQryAux += "LEFT JOIN SE4010 SE4 ON F1_COND=E4_CODIGO AND SE4.D_E_L_E_T_=''"		+ STR_PULA
	cQryAux += "WHERE "		+ STR_PULA
	cQryAux += "D1_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"		+ STR_PULA
	cQryAux += "AND F1_FORNECE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"		+ STR_PULA
	cQryAux += "AND B1_COD BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "'"		+ STR_PULA
	
	IF MV_PAR05<>1 
	cQryAux += " AND"	+ STR_PULA
	cQryAux += " D1_PEDIDO "		+ STR_PULA
	IF MV_PAR05==2
    	cQryAux += "<> '' "		+ STR_PULA
    ELSE
   		cQryAux += "= '' "		+ STR_PULA
    ENDIF
    ENDIF
	
	cQryAux += "ORDER BY D1_DTDIGIT"		+ STR_PULA

	cQryAux := ChangeQuery(cQryAux)
	
	//Executando consulta e setando o total da régua
	TCQuery cQryAux New Alias "QRY_AUX"
	Count to nTotal
	oReport:SetMeter(nTotal)
	TCSetField("QRY_AUX", "D1_EMISSAO", "D")
	TCSetField("QRY_AUX", "D1_DTDIGIT", "D")
	
	//Enquanto houver dados
	oSectDad:Init()
	QRY_AUX->(DbGoTop())
	While ! QRY_AUX->(Eof())
		//Incrementando a régua
		nAtual++
		oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
		oReport:IncMeter()

		IF (QRY_AUX->D1_TIPO=="N") .OR. (QRY_AUX->D1_TIPO=="C")
			    
			
				cQrySA :=""
				cQrySA += "SELECT A2_NOME AS NOME FROM SA2010 WHERE D_E_L_E_T_='' AND "		+ STR_PULA
				cQrySA += "A2_COD= '" + QRY_AUX->D1_FORNECE +"'   AND A2_LOJA='"+QRY_AUX->D1_LOJA+"'"		+ STR_PULA
				cQrySA := ChangeQuery(cQrySA)	
				TCQuery cQrySA New Alias "QRY_SA"
				QRY_SA->(DbGoTop())
         ELSE
		
				cQrySA :=""
				cQrySA += "SELECT A1_NOME AS NOME FROM SA1010 WHERE D_E_L_E_T_='' AND "		+ STR_PULA
				cQrySA += "A1_COD= '" + QRY_AUX->D1_FORNECE +"'   AND A1_LOJA='"+QRY_AUX->D1_LOJA+"'"		+ STR_PULA
				cQrySA := ChangeQuery(cQrySA)	
				TCQuery cQrySA New Alias "QRY_SA"
				QRY_SA->(DbGoTop())

		ENDIF
		cFornec:=	QRY_SA->NOME
		oSectDad:Cell("cFornec"):SetValue(cFornec)
		
		
		
		
		//Imprimindo a linha atual
		oSectDad:PrintLine()
		
		QRY_AUX->(DbSkip())
		QRY_SA->(DbCloseArea())
	EndDo
	oSectDad:Finish()
	QRY_AUX->(DbCloseArea())
	
	RestArea(aArea)
Return
