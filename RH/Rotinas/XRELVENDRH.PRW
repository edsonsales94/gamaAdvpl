//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} xRelVendRH
Relatório - Relatorio Venda por Periodo 
@author Ricky Moraes
@since 13/08/21
@version 1.0
	@example
	u_xRelVendRH()
	@obs Função gerada pelo Ricky Moraes()
/*/
	
User Function xRelVendRH()
	Local aArea   := GetArea()
	Local oReport
	Local lEmail  := .F.
	Local cPara   := ""
	Private cPerg:= Padr("XRVENDRH",10)
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
	//Local oBreak := Nil
	
	//Criação do componente de impressão
	oReport := TReport():New(	"xRelVendRH",;		//Nome do Relatório
								"Relatorio Venda por Periodo",;		//Título
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

	oSectDad2 := TRSection():New(	oReport,;		//Objeto TReport que a seção pertence
										"DadosFilho",;		//Descrição da seção
										{"QRY_AUX"})		//Tabelas utilizadas, a primeira será considerada como principal da seção									
	oSectDad:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Colunas do relatório
	TRCell():New(oSectDad, "CODCLI", "QRY_AUX", "Codcli", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CPF_CNPJ", "QRY_AUX", "Cpf_cnpj", /*Picture*/, 14, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NOME", "QRY_AUX", "Nome", /*Picture*/, 40, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	//TRCell():New(oSectDad, "UF1", "QRY_AUX", "UF", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ENDERECO", "QRY_AUX", "Endereco", /*Picture*/, 80, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	
	TRCell():New(oSectDad2, "EMISSAO", "QRY_AUX", "Emissao", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad2, "NUMNF", "QRY_AUX", "Numnf / Serie", /*Picture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	
	TRCell():New(oSectDad2, "CODIGO", "QRY_AUX", "Codigo", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad2, "DESCRICAO", "QRY_AUX", "Descricao", /*Picture*/, 50, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad2, "QTDE", "QRY_AUX", "Qtde", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad2, "PRC_UNIT", "QRY_AUX", "Prc_unit", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad2, "PRC_TOTAL", "QRY_AUX", "Prc_total", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad2, "DESC_PERC", "QRY_AUX", "Desc_perc%", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	
	TRCell():New(oSectDad2, "CODTAB", "QRY_AUX", "Codtab", /*Picture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad2, "TABELA_PRC", "QRY_AUX", "Tabela_prc", /*Picture*/, 30, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	
	//Definindo a quebra
	//oBreak := TRBreak():New(oSectDad,{|| QRY_AUX->(CODCLI) },{|| "SEPARACAO DO RELATORIO" })
	//oSectDad:SetHeaderBreak(.T.)
Return oReport
	
/*-------------------------------------------------------------------------------*
 | Func:  fRepPrint                                                              |
 | Desc:  Função que imprime o relatório                                         |
 *-------------------------------------------------------------------------------*/
	
Static Function fRepPrint(oReport)
	Local aArea    := GetArea()
	Local cQryAux  := ""
	Local oSectDad := Nil
	Local oSectDad2 := Nil
	Local nAtual   := 0
	Local nTotal   := 0	
	Local cDataini := cValToChar(MV_PAR01)
	Local cDataFim := cValToChar(MV_PAR02)
	Local cCpf :=cValToChar(MV_PAR03)


	//Pegando as seções do relatório
	oSectDad := oReport:Section(1)
	//Pegando as seções do relatório
	oSectDad2 := oReport:Section(2)
	
	
	//Montando consulta de dados
	cQryAux := ""
	cQryAux += "SELECT "		+ STR_PULA
	cQryAux += " A1_COD CODCLI,"		+ STR_PULA
	cQryAux += " A1_CGC CPF_CNPJ,"		+ STR_PULA
	cQryAux += " A1_NOME NOME,"		+ STR_PULA
	cQryAux += " RTRIM(A1_END) +' , '+RTRIM(A1_BAIRRO) ENDERECO,"		+ STR_PULA
	cQryAux += " A1_EST UF1,"		+ STR_PULA
	cQryAux += " D2_COD CODIGO,"		+ STR_PULA
	cQryAux += " B1_DESC DESCRICAO,"		+ STR_PULA
	cQryAux += " D2_QUANT	QTDE,"		+ STR_PULA
	cQryAux += " D2_PRCVEN  PRC_UNIT,"		+ STR_PULA
	cQryAux += " D2_TOTAL PRC_TOTAL,"		+ STR_PULA
	cQryAux += " D2_DESC  DESC_PERC, "		+ STR_PULA
	cQryAux += " D2_EMISSAO EMISSAO,"		+ STR_PULA
	cQryAux += " (D2_DOC +' / '+ D2_SERIE) NUMNF,"		+ STR_PULA
	//cQryAux += " D2_SERIE SERIE,"		+ STR_PULA
	cQryAux += " DA0_CODTAB CODTAB,"		+ STR_PULA
	cQryAux += " DA0_DESCRI  TABELA_PRC"		+ STR_PULA
	cQryAux += "FROM SA1010 SA1"		+ STR_PULA
	cQryAux += "CROSS APPLY ("		+ STR_PULA
	cQryAux += "SELECT"		+ STR_PULA
	cQryAux += " D2_COD,D2_QUANT,D2_PRUNIT,D2_PRCVEN,D2_DESC, D2_TOTAL,D2_EMISSAO,D2_DOC,D2_SERIE"		+ STR_PULA
	cQryAux += " ,DA0_CODTAB,DA0_DESCRI,B1_DESC "		+ STR_PULA
	cQryAux += " FROM SD2010 SD2"		+ STR_PULA
	cQryAux += " CROSS APPLY ( SELECT B1_DESC FROM SB1010 SB1 WHERE B1_COD=D2_COD AND SB1.D_E_L_E_T_='' AND B1_TIPO='PA') SB1"		+ STR_PULA
	cQryAux += " CROSS APPLY ( SELECT DA0_CODTAB,DA0_DESCRI "		+ STR_PULA
	cQryAux += "				FROM SC5010 SC5 "		+ STR_PULA
	cQryAux += "				CROSS APPLY (SELECT DA0_DESCRI,DA0_CODTAB FROM DA0010 DA0 WHERE DA0_CODTAB= C5_TABELA AND DA0.D_E_L_E_T_='') DA0"		+ STR_PULA
	cQryAux += "				WHERE SC5.D_E_L_E_T_='' "		+ STR_PULA
	cQryAux += "				AND C5_FILIAL=D2_FILIAL"		+ STR_PULA
	cQryAux += "				AND C5_CLIENT=D2_CLIENTE"		+ STR_PULA
	cQryAux += "				AND C5_LOJACLI=D2_LOJA"		+ STR_PULA
	cQryAux += "				AND C5_NUM=D2_PEDIDO"		+ STR_PULA
	cQryAux += "				AND C5_NOTA = D2_DOC"		+ STR_PULA
	cQryAux += "				AND C5_SERIE= D2_SERIE"		+ STR_PULA
	cQryAux += "							"		+ STR_PULA
	cQryAux += " )SC5"		+ STR_PULA
	cQryAux += "WHERE"		+ STR_PULA
	cQryAux += "D2_CLIENTE=A1_COD"		+ STR_PULA
	cQryAux += "AND D2_LOJA = A1_LOJA"		+ STR_PULA
	cQryAux += "AND SD2.D_E_L_E_T_=''"		+ STR_PULA
	cQryAux += ")SD2"		+ STR_PULA
	cQryAux += "WHERE SA1.D_E_L_E_T_=''"		+ STR_PULA
	cQryAux += "AND A1_CGC = '" + cCpf +   "'"		+ STR_PULA
	cQryAux += "  AND D2_EMISSAO BETWEEN '" +cDataini + "'" + STR_PULA
	cQryAux += "  AND '" +cDataFim + "'"		+ STR_PULA
	cQryAux += "ORDER BY A1_COD,D2_EMISSAO,D2_COD"		+ STR_PULA
	cQryAux := ChangeQuery(cQryAux)
	
	//Executando consulta e setando o total da régua
	TCQuery cQryAux New Alias "QRY_AUX"
	Count to nTotal
	TCSetField("QRY_AUX", "EMISSAO", "D")
	oReport:SetMeter(nTotal)
	
	//Enquanto houver dados
	oSectDad:Init()
	oSectDad2:Init()


	QRY_AUX->(DbGoTop())

	oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
	oReport:IncMeter()
		
	//Imprimindo a linha cabeçakho
	oSectDad:PrintLine()
	While ! QRY_AUX->(Eof())
		//Incrementando a régua
		nAtual++
		
		//Imprimindo a linha atual
		oSectDad2:PrintLine()
		
		QRY_AUX->(DbSkip())
	EndDo
	oSectDad2:Finish()
	oSectDad:Finish()
	QRY_AUX->(DbCloseArea())
	
	RestArea(aArea)
Return
