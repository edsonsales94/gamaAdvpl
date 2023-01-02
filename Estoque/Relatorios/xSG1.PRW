//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} xSG1
Relatório - Relatorio Estrutura Custom    
@author zReport
@since 30/09/19
@version 1.0
	@example
	u_xSG1()
	@obs Função gerada pelo zReport()
/*/
	
User Function xSG1()
	Local aArea   := GetArea()
	Local oReport
	Local lEmail  := .F.
	Local cPara   := ""
	Private cPerg := ""
	
	//Definições da pergunta
	cPerg := "TROTPROD"
	
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
	oReport := TReport():New(	"xSG1",;		//Nome do Relatório
								"Relatorio Estrutura Custom",;		//Título
								cPerg,;		//Pergunte ... Se eu defino a pergunta aqui, será impresso uma página com os parâmetros, conforme privilégio 101
								{|oReport| fRepPrint(oReport)},;		//Bloco de código que será executado na confirmação da impressão
								)		//Descrição
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9) //Folha A4
	oReport:SetLandscape()
	
	//Criando a seção de dados
	oSectDad := TRSection():New(	oReport,;		//Objeto TReport que a seção pertence
									"NIVEL1",;		//Descrição da seção
									{"QRY_AUX"})		//Tabelas utilizadas, a primeira será considerada como principal da seção 
	oSectDad2 := TRSection():New(	oReport,;		//Objeto TReport que a seção pertence
									"NIVEL2",;		//Descrição da seção
									{"QRY_AUX"})		//Tabelas utilizadas, a primeira será considerada como principal da seção
	
	oSectDad3 := TRSection():New(	oReport,;		//Objeto TReport que a seção pertence
									"NIVEL3",;		//Descrição da seção
									{"QRY_AUX2"})		//Tabelas utilizadas, a primeira será considerada como principal da seção
	
								
							
	oSectDad:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	oSectDad2:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	oSectDad3:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Colunas do relatório
	TRCell():New(oSectDad, "NIVEL", "QRY_AUX", "Nivel", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CODIGO", "QRY_AUX", "Codigo", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DESCRI", "QRY_AUX", "Descri", /*Picture*/, 50, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "TIPO", "QRY_AUX", "Tipo", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)


	TRCell():New(oSectDad2, " ", "QRY_AUX", "ITEM", /*Picture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad2, "NIVEL", "QRY_AUX", "Nivel", /*Picture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad2, "TIPO_COMP", "QRY_AUX", "Tipo", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad2, "COD_COMP", "QRY_AUX", "Cod_comp", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad2, "DESC_COMP", "QRY_AUX", "Desc_comp", /*Picture*/, 50, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad2, "QTD", "QRY_AUX", "Qtd", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad2, "UM_COMP", "QRY_AUX", "Um_comp", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)



	TRCell():New(oSectDad3, " ", "QRY_AUX2", "ITEM", /*Picture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad3, "NIVEL", "QRY_AUX2", "Nivel", /*Picture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad3, "TIPO_COMP", "QRY_AUX2", "Tipo", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad3, "COD_COMP", "QRY_AUX2", "Cod_comp", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad3, "DESC_COMP", "QRY_AUX2", "Desc_comp", /*Picture*/, 50, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad3, "QTD", "QRY_AUX2", "Qtd", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad3, "UM_COMP", "QRY_AUX2", "Um_comp", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)






//	TRCell():New(oSectDad, "COD_PAI", "QRY_AUX", "Cod_pai", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
//	TRCell():New(oSectDad, "DESC_PAI", "QRY_AUX", "Desc_pai", /*Picture*/, 50, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
//	TRCell():New(oSectDad, "COD_COMP", "QRY_AUX", "Cod_comp", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
//	TRCell():New(oSectDad, "DESC_COMP", "QRY_AUX", "Desc_comp", /*Picture*/, 50, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
//	TRCell():New(oSectDad, "QTD", "QRY_AUX", "Qtd", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
//	TRCell():New(oSectDad, "UM_COMP", "QRY_AUX", "Um_comp", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
//	TRCell():New(oSectDad, "DT_INI", "QRY_AUX", "Dt_ini", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
//	TRCell():New(oSectDad, "DT_FIM", "QRY_AUX", "Dt_fim", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
//	TRCell():New(oSectDad, "GROPC", "QRY_AUX", "Gropc", /*Picture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
//	TRCell():New(oSectDad, "OPC", "QRY_AUX", "Opc", /*Picture*/, 4, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
//	TRCell():New(oSectDad, "FTM_PAI", "QRY_AUX", "Ftm_pai", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
//	TRCell():New(oSectDad, "FTM_COD", "QRY_AUX", "Codigo", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
//	TRCell():New(oSectDad, "LOCPAD", "QRY_AUX", "Locpad", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	
	//Definindo a quebra
//	oBreak := TRBreak():New(oSectDad,{|| QRY_AUX->(NIVEL) },{|| "SEPARACAO DO RELATORIO" })
//	oBreak := TRBreak():New(oSectDad2,{|| QRY_AUX->(TIPO_COMP) },{|| "SEPARACAO DO RELATORIO" })
	oSectDad:SetHeaderBreak(.T.)

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
	Local oSectDad3 := Nil
	Local nAtual   := 0
	Local nTotal   := 0
	Local nN1 :=1
	Local cCodigo :=space(15)
	Local cNivel1 :=space(15)
	Local cN1:=space(3)
	
	//Pegando as seções do relatório
	oSectDad := oReport:Section(1)
	oSectDad2 := oReport:Section(2)    
	oSectDad3 := oReport:Section(3) 
	
	// tira cabeçalho
	oSectDad:SetHeaderSection(.F.)
	oSectDad2:SetHeaderSection(.F.)
	oSectDad3:SetHeaderSection(.F.)
	
	
	//Montando consulta de dados
	cQryAux := ""
	cQryAux += "SELECT "		+ STR_PULA
	cQryAux += "NIVEL,"		+ STR_PULA
	cQryAux += "CODIGO,"		+ STR_PULA
	cQryAux += "DESCRI,"		+ STR_PULA
	cQryAux += "TIPO,"		+ STR_PULA
	cQryAux += "TIPO_PAI,"		+ STR_PULA
	cQryAux += "COD_PAI,"		+ STR_PULA
	cQryAux += "DESC_PAI,"		+ STR_PULA
	cQryAux += "TIPO_COMP,"		+ STR_PULA
	cQryAux += "COD_COMP,DESC_COMP,"		+ STR_PULA
	cQryAux += "QTD,"		+ STR_PULA
	cQryAux += "UM_COMP,"		+ STR_PULA
	cQryAux += "DT_INI,"		+ STR_PULA
	cQryAux += "DT_FIM,"		+ STR_PULA
	cQryAux += "GROPC,OPC,"		+ STR_PULA
	cQryAux += "FTM_PAI,"		+ STR_PULA
	cQryAux += "FTM_COD,"		+ STR_PULA
	cQryAux += "LOCPAD"		+ STR_PULA
	cQryAux += " FROM VW_SG1"		+ STR_PULA 
	cQryAux += " WHERE CODIGO BETWEEN '" + (MV_PAR01) + "' AND '" + (MV_PAR02) +"' "	+ STR_PULA
	cQryAux += " AND NIVEL= 1 ORDER BY CODIGO,NIVEL,TIPO_COMP,COD_COMP,COD_PAI"		+ STR_PULA
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
		IF 	cCodigo <> QRY_AUX->(CODIGO)
				oSectDad:PrintLine()  
		ENDIF
		cCodigo := QRY_AUX->(CODIGO)

		oSectDad2:Init()
		
		 //	nAtual++
			oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
			oReport:IncMeter()   
	
			cN1:= STRZERO(nN1, 3, 0) 
			++nN1 
			
			oSectDad2:Cell("ITEM"):SetValue(cN1)
		   oSectDad2:Cell("ITEM"):SetAlign("RIGTH")
			
			
			oSectDad2:Printline()
			
			//IMPRIMIR NIVEL 2
			IF QRY_AUX->(TIPO_COMP) ='PA' .OR. QRY_AUX->(TIPO_COMP) ='PI'
				QueryNiveis()
  				nN2:=0   
	  			oSectDad3:Init()
				While QRY_AUX2->(COD_PAI) == QRY_AUX->(COD_COMP) 
					cN2:= STRZERO(nN2, 3, 0) 
					++nN2
				
				oSectDad3:Cell("ITEM"):SetValue(cN2)
			   oSectDad3:Cell("ITEM"):SetAlign("RIGTH")
				oSectDad3:Printline()
			 	QRY_AUX2->(DbSkip())
		
			   Enddo	
				QRY_AUX2->(DbCloseArea())
		 ENDIF
	 	  
		QRY_AUX->(DbSkip())
		
	EndDo
	oSectDad:Finish()
	oSectDad2:Finish()
	oSectDad3:Finish()
	QRY_AUX->(DbCloseArea())

	
	RestArea(aArea)
Return   

Static Function QueryNiveis()

	//Montando consulta de dados
	cQryAux2 := ""
	cQryAux2 += "SELECT "		+ STR_PULA
	cQryAux2 += "NIVEL,"		+ STR_PULA
	cQryAux2 += "CODIGO,"		+ STR_PULA
	cQryAux2 += "DESCRI,"		+ STR_PULA
	cQryAux2 += "TIPO,"		+ STR_PULA
	cQryAux2 += "TIPO_PAI,"		+ STR_PULA
	cQryAux2 += "COD_PAI,"		+ STR_PULA
	cQryAux2 += "DESC_PAI,"		+ STR_PULA
	cQryAux2 += "TIPO_COMP,"		+ STR_PULA
	cQryAux2 += "COD_COMP,DESC_COMP,"		+ STR_PULA
	cQryAux2 += "QTD,"		+ STR_PULA
	cQryAux2 += "UM_COMP,"		+ STR_PULA
	cQryAux2 += "DT_INI,"		+ STR_PULA
	cQryAux2 += "DT_FIM,"		+ STR_PULA
	cQryAux2 += "GROPC,OPC,"		+ STR_PULA
	cQryAux2 += "FTM_PAI,"		+ STR_PULA
	cQryAux2 += "FTM_COD,"		+ STR_PULA
	cQryAux2 += "LOCPAD"		+ STR_PULA
	cQryAux2 += " FROM VW_SG1"		+ STR_PULA 
	cQryAux2 += " WHERE CODIGO BETWEEN '" + (MV_PAR01) + "' AND '" + (MV_PAR02) +"' "	+ STR_PULA
//	cQryAux2 += " AND NIVEL= 2 "		+ STR_PULA
	cQryAux2 += " AND COD_PAI ='"+	QRY_AUX->(COD_COMP) +"'"	+ STR_PULA
	cQryAux2 += "ORDER BY CODIGO,COD_PAI,TIPO_COMP,COD_COMP"		+ STR_PULA
	cQryAux2 := ChangeQuery(cQryAux2)
	//Executando consulta e setando o total da régua
	TCQuery cQryAux2 New Alias "QRY_AUX2"  
	QRY_AUX2->(DbGoTop())   
	alert('1')
                                                            
  Return

