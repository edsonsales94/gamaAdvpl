//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"

//Constantes
#Define STR_PULA		Chr(13)+Chr(10)

/*/{Protheus.doc} xRELSLOW
Relatório - Relatorio SLOW MOVING         
@author zReport
@since 17/03/21
@version 1.0
	@example
	u_xRELSLOW()
	@obs Função gerada pelo zReport()
/*/

User Function XRELSLOW()
	Local aArea   := GetArea()
	Local oReport
	Local lEmail  := .F.
	Local cPara   := ""
	Private cPerg := ""

	//Definições da pergunta
	cPerg := "XRELSLOW  "

	//Se a pergunta não existir, zera a variável
	DbSelectArea("SX1")
	SX1->(DbSetOrder(1)) //X1_GRUPO + X1_ORDEM
	If ! SX1->(DbSeek(cPerg))
		cPerg := Nil
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

	
	//Criação do componente de impressão
	oReport := TReport():New(	"xRELSLOW",;		//Nome do Relatório
								"Relatório SLOW MOVING - 180 dias",;		//Título
								cPerg,;		//Pergunte ... Se eu defino a pergunta aqui, será impresso uma página com os parâmetros, conforme privilégio 101
								{|oReport| fRepPrint(oReport)},;		//Bloco de código que será executado na confirmação da impressão
								)		//Descrição
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9) //Folha A4
	oReport:SetPortrait()
	
	//Criando a seção de dados
	oSectDad := TRSection():New(	oReport,;		//Objeto TReport que a seção pertence
									"Dados",;		//Descrição da seção
									{"QRY_AUX"})		//Tabelas utilizadas, a primeira será considerada como principal da seção
	oSectDad:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Colunas do relatório
	TRCell():New(oSectDad, "POSICAO", "QRY_AUX", "#Posicao",  "@E 999,999,999"/*Picture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "B1_COD", "QRY_AUX", "Codigo", /*Picture*/, 17, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "B1_DESC", "QRY_AUX", "Descricao", /*Picture*/, 60, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "B1_TIPO", "QRY_AUX", "Tipo", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "B1_UM", "QRY_AUX", "Unid.", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ULT_MOVE", "QRY_AUX", "Dt.Ult.E", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ULT_MOVS", "QRY_AUX", "Dt.Ult.E", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DIAS_SLOW", "QRY_AUX", "Dias",  "@E 999,999,999"/*Picture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "MOVING", "QRY_AUX", "Moving", /*Picture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "PREVISTO", "QRY_AUX", "Previ.", /*Picture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ORIGEM", "QRY_AUX", "Origem", /*Picture*/, 13, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "SALDOSB2", "QRY_AUX", "Qtd.Sb2", "@E 999,999,999.99" /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "SB2VTOT", "QRY_AUX", "R$ Total", "@E 999,999,999.99" /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "USADOPA", "QRY_AUX", "Onde Usado ?",  /*Picture*/, 300, /*lPixel*/,/*{|| code-block de impressao }*/,"LEFT"/*cAlign*/,/*lLineBreak*/,"LEFT"/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
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
	//    Local cQryAux2  := ""
	
	//Pegando as seções do relatório
	oSectDad := oReport:Section(1)

	//atualizar SP SLOW
	Processa({|| sfProcSlow() },"Atualizando tabelas Slow...")
	
	
	//Montando consulta de dados
	cQryAux := ""
	cQryAux += "SELECT * FROM TEMP_SLOW ORDER BY 1"		+ STR_PULA
	cQryAux := ChangeQuery(cQryAux)

  	//Se o alias estiver aberto, irei fechar, isso ajuda a evitar erros
	IF Select("QRY_AUX") <> 0
		DbSelectArea("QRY_AUX")
		DbCloseArea()
	ENDIF

	
	//Executando consulta e setando o total da régua
	TCQuery cQryAux New Alias "QRY_AUX"
    TCSetField("QRY_AUX", "ULT_MOVE", "D")
    TCSetField("QRY_AUX", "ULT_MOVS", "D")
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
	
	RestArea(aArea)
Return

/* Executa a procedure dentro do banco*/
Static function sfProcSlow()
Local aResult := {}
aResult := TCSPEXEC("sp_TEMP_SLOW", 180)
 
IF empty(aResult)
Conout('Erro na execução da Stored Procedure : '+TcSqlError())
Else
Conout("Retorno String : "+aResult[1])
Conout("Retorno Numerico : "+str(aResult[2]))
MsgInfo("Procedure Executada")
Endif
 
Return
