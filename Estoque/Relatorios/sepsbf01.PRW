//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} SEPSBF01
Relat?rio - SEPARACAO DE MATERIAIS        
@author zReport
@since 10/09/19
@version 1.0
	@example
	u_SEPSBF01()
	@obs Fun??o gerada pelo zReport()
/*/
	
User Function SEPSBF01()
	Local aArea   := GetArea()
	Local oReport
	Local lEmail  := .F.
	Local cPara   := ""
	Private cPerg := ""    
	
	
	
	//Defini??es da pergunta
	cPerg := "SEPSBF01  "
	

	Pergunte(cPerg, .F.)
	
	//Se a pergunta n?o existir, zera a vari?vel
	DbSelectArea("SX1")
	SX1->(DbSetOrder(1)) //X1_GRUPO + X1_ORDEM
	If ! SX1->(DbSeek(cPerg))
		cPerg := Nil
	EndIf
	
	//Cria as defini??es do relat?rio
	oReport := fReportDef()
	
	//Ser? enviado por e-Mail?
	If lEmail
		oReport:nRemoteType := NO_REMOTE
		oReport:cEmail := cPara
		oReport:nDevice := 3 //1-Arquivo,2-Impressora,3-email,4-Planilha e 5-Html
		oReport:SetPreview(.F.)
		oReport:Print(.F., "", .T.)
	//Sen?o, mostra a tela
	Else
		oReport:PrintDialog()
	EndIf
	
	RestArea(aArea)
Return


	
/*-------------------------------------------------------------------------------*
 | Func:  fReportDef                                                             |
 | Desc:  Fun??o que monta a defini??o do relat?rio                              |
 *-------------------------------------------------------------------------------*/
	
Static Function fReportDef()
	Local oReport
	Local oSectDad := Nil
	Local oBreak := Nil
	Local oFunTot1 := Nil
	
	//Cria??o do componente de impress?o
	oReport := TReport():New(	"SEPSBF01",;		//Nome do Relat?rio
								"Rela??o de Separa??o de Materiais",;		//T?tulo
								cPerg,;		//Pergunte ... Se eu defino a pergunta aqui, ser? impresso uma p?gina com os par?metros, conforme privil?gio 101
								{|oReport| fRepPrint(oReport)},;		//Bloco de c?digo que ser? executado na confirma??o da impress?o
								)		//Descri??o
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9) //Folha A4
	oReport:SetPortrait()
	
	//Criando a se??o de dados
	oSectDad := TRSection():New(	oReport,;		//Objeto TReport que a se??o pertence
									"Dados",;		//Descri??o da se??o
									{"QRY_AUX"})		//Tabelas utilizadas, a primeira ser? considerada como principal da se??o
	oSectDad:SetTotalInLine(.F.)  //Define se os totalizadores ser?o impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	

	
	//Colunas do relat?rio
	TRCell():New(oSectDad, "DOC", "QRY_AUX", "Doc", /*Picture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CLIFOR", "QRY_AUX", "Clifor", /*Picture*/, 40, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "B1_LOCALIZ", "QRY_AUX", "Contr.Endere", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D2_ITEM", "QRY_AUX", "Item", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "PRODUTO", "QRY_AUX", "Produto", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "QVENDA", "QRY_AUX", "Qvenda", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ENDER", "QRY_AUX", "Ender", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "QUANT", "QRY_AUX", "Quant", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	
	//Totalizadores
	oFunTot1 := TRFunction():New(oSectDad:Cell("PRODUTO"),,"COUNT",,,/*cPicture*/)
	oFunTot1:SetEndReport(.F.)
Return oReport
	
/*-------------------------------------------------------------------------------*
 | Func:  fRepPrint                                                              |
 | Desc:  Fun??o que imprime o relat?rio                                         |
 *-------------------------------------------------------------------------------*/
	
Static Function fRepPrint(oReport)
	Local aArea    := GetArea()
	Local cQryAux  := ""
	Local oSectDad := Nil
	Local nAtual   := 0
	Local nTotal   := 0
	
	//Pegando as se??es do relat?rio
	oSectDad := oReport:Section(1)
	
	//Montando consulta de dados
	cQryAux := ""
	cQryAux += "SELECT  "		+ STR_PULA
	cQryAux += "	D2_DOC DOC,"		+ STR_PULA
	cQryAux += "	COALESCE(A1_NOME,A2_NOME) CLIFOR,"		+ STR_PULA
	cQryAux += "	B1_LOCALIZ,"		+ STR_PULA
	cQryAux += "	D2_ITEM ,DB_PRODUTO PRODUTO,D2_QUANT QVENDA,DB_LOCALIZ ENDER,DB_QUANT QUANT"		+ STR_PULA
	cQryAux += "	FROM SD2010 SD2 "		+ STR_PULA
	cQryAux += "	INNER JOIN SF2010 SF2 ON F2_FILIAL='01' AND F2_DOC=D2_DOC AND F2_SERIE=D2_SERIE AND F2_CLIENTE=D2_CLIENTE AND F2_LOJA=D2_LOJA AND SF2.D_E_L_E_T_=''"		+ STR_PULA
	cQryAux += "	LEFT OUTER JOIN SDB010 SDB ON D2_FILIAL='01' AND D2_NUMSEQ=DB_NUMSEQ AND D2_COD=DB_PRODUTO AND SDB.D_E_L_E_T_=''"		+ STR_PULA
	cQryAux += "	"		+ STR_PULA
	cQryAux += "	LEFT JOIN SA1010 SA1 ON SA1.D_E_L_E_T_ = '' "		+ STR_PULA
	cQryAux += "	AND A1_FILIAL = '01'"		+ STR_PULA
	cQryAux += "	AND A1_COD = F2_CLIENTE"		+ STR_PULA
	cQryAux += "	AND A1_LOJA = F2_LOJA"		+ STR_PULA
	cQryAux += "	AND NOT (F2_TIPO IN ('D', 'B'))"		+ STR_PULA
	cQryAux += "	LEFT JOIN SA2010 SA2 ON SA2.D_E_L_E_T_ = ''"		+ STR_PULA
	cQryAux += "	AND A2_FILIAL = '01'"		+ STR_PULA
	cQryAux += "	AND A2_COD = F2_CLIENTE"		+ STR_PULA
	cQryAux += "	AND A2_LOJA = F2_LOJA"		+ STR_PULA
	cQryAux += "	AND (F2_TIPO IN ('D', 'B'))"		+ STR_PULA
	cQryAux += "	"		+ STR_PULA
	cQryAux += "	INNER JOIN SB1010 SB1 ON SB1.D_E_L_E_T_='' AND B1_COD=D2_COD "		+ STR_PULA
	cQryAux += "	WHERE DB_DOC= '" + MV_PAR01 + "'  AND DB_ORIGEM='SC6'  AND SD2.D_E_L_E_T_=''"		+ STR_PULA
	cQryAux += "	ORDER BY D2_ITEM"		+ STR_PULA
	cQryAux := ChangeQuery(cQryAux)
	
	//Executando consulta e setando o total da r?gua
	TCQuery cQryAux New Alias "QRY_AUX"
	Count to nTotal
	oReport:SetMeter(nTotal)
	
	//Enquanto houver dados
	oSectDad:Init()
	QRY_AUX->(DbGoTop())
	While ! QRY_AUX->(Eof())
		//Incrementando a r?gua
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



/* DESATIVAR
#include 'protheus.ch'
#include "rwMake.ch"
//feito em 29/03/2017 para separacao de materiais apos impressao da DANFE
user function sepsbf01()
	Local   cPerg    := PADR("SEPSBF01", Len(SX1->X1_GRUPO))
	Local   cTitulo  := "Ordem de Sepa??o de Materiais"
	Private aExc     := {}
	Private oFormIni := Nil
	Private lFirstTm := .T.
	Private nItens   := 0

	ValidPerg(cPerg)
	Pergunte(cPerg, .F.)

	@96,042 TO 323,505 DIALOG oFormIni TITLE "ORDEM DE SEPARA??O DE MATERIAIS"
	@08,010 TO 84,222
	@23,014 SAY "Esta rotina tem a finalidade de emitir relat?rio de Ordem de Separa??o "
	@33,014 SAY "de materiais conforme a DANFE de Saida. "

	@91, 111 BUTTON "Par?metros"	SIZE 40, 15 ACTION Pergunte(cPerg, .T.)
	@91, 152 BUTTON "OK" 		 	SIZE 30, 15 ACTION (Processa({|| RunProc(), "Selecionando dados...", cTitulo, .T. }), Close(oFormIni))
	@91, 183 BUTTON "Cancelar"		SIZE 40, 15 ACTION Close(oFormIni)
	ACTIVATE DIALOG oFormIni CENTERED

Return Nil

Static Function RunProc()
	Local cAliasQRY
	Private nLin
	cAliasQRY := GetNextAlias()
	BeginSql Alias cAliasQRY
	select A2_NOME FORNECEDOR ,A1_NOME CLIENTE, DB_DOC DOC, D2_ITEM ,F2_TIPOCLI,DB_PRODUTO PRODUTO,D2_QUANT QVENDA,DB_LOCALIZ ENDER,DB_QUANT QUANT
	from %table:SD2% SD2
	LEFT OUTER JOIN %table:SDB% SDB ON D2_FILIAL=%xFilial:SD2% AND D2_NUMSEQ=DB_NUMSEQ AND D2_COD=DB_PRODUTO AND SDB.%NotDel%
	LEFT OUTER JOIN %table:SA2% SA2 ON A2_FILIAL=%xFilial:SA2%  AND A2_COD=DB_CLIFOR AND A2_LOJA=DB_LOJA AND  SA2.%NotDel%
	LEFT OUTER JOIN %table:SA1% SA1 ON A1_FILIAL=%xFilial:SA1%  AND A1_COD=DB_CLIFOR AND A1_LOJA=DB_LOJA AND  SA1.%NotDel%
	LEFT OUTER JOIN %table:SF2% SF2 ON F2_FILIAL=%xFilial:SF2% AND F2_DOC=D2_DOC AND F2_SERIE=D2_SERIE AND F2_CLIENTE=D2_CLIENTE AND F2_LOJA=D2_LOJA AND SF2.%NotDel%
	WHERE DB_DOC=%exp:MV_PAR01% AND DB_ORIGEM='SC6' AND SD2.%NotDel%
	ORDER BY D2_ITEM
	EndSql
	dbSelectArea(cAliasQRY)
	DBGOTOP()
	If ((cAliasQRY)->(EOF()))
		MsgStop("N?o h? dados a serem exibidos com os par?metros informados!")
		(cAliasQRY)->(dbCloseArea())
		Return Nil
	Endif

	oEstVnd:= TMSPrinter():New("ORDEM DE SEPARA??O")
	oEstVnd:SetPortrait() // ou SetLandscape()

	hMin := 50
	hMax := 3100
	wMin := 50
	wMax := 3200

	DEFINE FONT oFontItem   NAME "Calibri"      SIZE 0,06 OF oEstVnd
	DEFINE FONT oFontItem2  NAME "Calibri" BOLD SIZE 0,06 OF oEstVnd
	DEFINE FONT oFontCab  	NAME "Arial"   BOLD SIZE 0,09 OF oEstVnd
	DEFINE FONT oFontCab2  	NAME "Arial"   BOLD SIZE 0,07 OF oEstVnd
	DEFINE FONT oFontCab3  	NAME "Arial"        SIZE 0,07 OF oEstVnd
	DEFINE FONT oFontCab4  	NAME "Arial"        SIZE 0,06 OF oEstVnd
	DEFINE FONT oFontCab5  	NAME "Arial"        SIZE 0,09 OF oEstVnd
	DEFINE FONT oFontTit    NAME "Arial"   BOLD SIZE 0,12 OF oEstVnd
	DEFINE FONT oFontTit2   NAME "Arial"        SIZE 0,11 OF oEstVnd
	DEFINE FONT oFontTit3   NAME "Arial"   BOLD SIZE 0,06 OF oEstVnd
	DEFINE FONT oFontTit4   NAME "Arial"        SIZE 0,12 OF oEstVnd

	oEstVnd:StartPage()
	nLin:= 100  //linha Inicial,coluna Inicial,Linha Final,Coluna Final
	oEstVnd:Box(85, 15, 185 , 2380 )//1?
	oEstVnd:Say(110,15+700,"Rela??o de Separa??o de Materiais ", oFontTit,,,2)
	oEstVnd:Box(185, 15 , 285 , 2380 )//2?

	oEstVnd:Box(185, 650 , 285 ,2380 )
	oEstVnd:Say(195,100,"Nota Fiscal : "+(cAliasQRY)->DOC, oFontTit2,,,2)
	oEstVnd:Say(195,700,"Cliente : " + IIF(len(alltrim((cAliasQRY)->CLIENTE))==0,(cAliasQRY)->FORNECEDOR,(cAliasQRY)->CLIENTE), oFontTit2,,,2)
	codAnt := ""
	nlin = 0
	WHILE !(cAliasQRY)->(EOF())
		if (cAliasQRY)->PRODUTO<>codAnt
			if len(alltrim(codAnt))>0
				nLin:= nLin + 10
			endif
			oEstVnd:Say(310+nlin,200,"Produto : " + (cAliasQRY)->PRODUTO, oFontTit,,,2)
			oEstVnd:Say(310+nlin,870,"Qtd.Venda: "+STR((cAliasQRY)->QVENDA,12,3), oFontTit,,,2)
			oEstVnd:Say(310+nlin,1400,"Endere?o  ", oFontTit,,,2)
			oEstVnd:Say(310+nlin,1900,"Qtd.Baixa ", oFontTit,,,2)
			oEstVnd:Line(370+nlin,1400 , 370+nlin,1750 ) //VISTO DAS GER?NCIAS
			oEstVnd:Line(370+nlin,1900 , 370+nlin,2200 ) //VISTO DAS GER?NCIAS
			codAnt := (cAliasQRY)->PRODUTO
			nLin:=nLin + 80
		Endif
		oEstVnd:Say(310+nlin,1400,(cAliasQRY)->ENDER, oFontTit2 ,,,2)
		oEstVnd:Say(310+nlin,1900,STR((cAliasQRY)->QUANT,12,3), oFontTit2 ,,,2)
		nLin:=nLin + 40
		(cAliasQRY)->(dbskip())
	Enddo
	oEstVnd:EndPage()
	oEstVnd:Preview()
	dbSelectArea(cAliasQRY)
	dbclosearea(cAliasQRY)
Return Nil

Static Function ValidPerg(cPerg)
	PutSX1(cPerg,"01","Nota De?", "", "", "mv_ch1", "C", 09,00,00,"G","","SD2","","","mv_par01")
	//PutSX1(cPerg,"02","Nota Ate?", "", "", "mv_ch2", "C", 09,00,00,"G","","SD2","","","mv_par02")
Return Nil  

*/