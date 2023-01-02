//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} MODXOP
Relatório - Relatorio Consulta Mods nas OP
@author zReport
@since 29/08/18                                                                                   
@version 1.0
	@example
	u_MODXOP()
	@obs Função gerada pelo zReport()
/*/
	
User Function MODXOP()
	Local aArea   := GetArea()
	Local oReport
	Local lEmail  := .F.
	Local cPara   := ""
	Private cPerg := ""
	Private Titulo:=""
	
	//Definições da pergunta
	cPerg := "MODXOP01  "
	
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
//	Local oBreak := Nil
	
	//Criação do componente de impressão
	oReport := TReport():New(	"MODXOP",;		//Nome do Relatório
								"Relatorio Consulta Mods nas OP",;		//Título
								cPerg,;		//Pergunte ... Se eu defino a pergunta aqui, será impresso uma página com os parâmetros, conforme privilégio 101
								{|oReport| fRepPrint(oReport)},;		//Bloco de código que será executado na confirmação da impressão
								)		//Descrição
	
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9) //Folha A4
	oReport:SetPortrait()

    
	

	
	//Criando a seção de dados
	oSectDad := TRSection():New(	oReport,"Dados",{"QRY_AUX","QRY_MOD"})		//Tabelas utilizadas, a primeira será considerada como principal da seção
	oSectDad:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Colunas do relatório
	TRCell():New(oSectDad, "CODIGO", "QRY_AUX", "Código", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "PA_DESC", "QRY_AUX", "Descrição", /*Picture*/, 50, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "QTD_PA", "QRY_AUX", "Qtd_pa", /*Picture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "OP", "QRY_AUX", "Grupo OP", /*Picture*/, 14, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DOC", "QRY_AUX", "Doc", /*Picture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "EMISSAO", "QRY_AUX", "Emissao", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "cMOD", "QRY_MOD", "MOD", /*Picture*/, 11, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "hMOD", " ", "    Horas.Mod.Unit", PesqPict("SB2","B2_QATU" ), 11, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "tHMOD", "QRY_MOD", "    Tot.Horas.Mod", PesqPict("SB2","B2_QATU" ), 11, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "tCMOD", "QRY_MOD", "    R$ Tot.Custo.Mod", PesqPict("SB2","B2_QATU" ), 11, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

Return oReport
	
/*-------------------------------------------------------------------------------*
 | Func:  fRepPrint                                                              |
 | Desc:  Função que imprime o relatório                                         |
 *-------------------------------------------------------------------------------*/
	
Static Function fRepPrint(oReport)
	Local aArea    := GetArea()
	Local cQryAux,cQrMod  := ""
	Local oSectDad := Nil
	Local nAtual   := 0
	Local hMOD	:=0
	Local nTotal,nTMOds   := 0
	
	
	Titulo 	:= "Relatorio Consulta Mods nas OP - de DATA "+DTOC(MV_PAR01)+" até DATA "+DTOC(MV_PAR02)+" 
  	oReport:SetTitle(Titulo) 
	
	
	//Pegando as seções do relatório
	oSectDad := oReport:Section(1)
	
	//Montando consulta de dados
	cQryAux := ""
	cQryAux += "		SELECT			"		+ STR_PULA
	cQryAux += "		B1_COD AS CODIGO, B1_DESC AS PA_DESC,SD3EXT.D3_QUANT AS QTD_PA,SD3EXT.D3_OP AS OP,"		+ STR_PULA
	cQryAux += "			SD3EXT.D3_DOC AS DOC,"		+ STR_PULA
	cQryAux += "			D3_EMISSAO AS EMISSAO"		+ STR_PULA
	cQryAux += "		FROM SD3010  SD3EXT  INNER JOIN SB1010 ON SD3EXT.D3_COD=B1_COD "		+ STR_PULA
	cQryAux += "		WHERE SD3EXT.D3_OP<>'' AND SD3EXT.D3_CF ='PR0' AND"		+ STR_PULA
	cQryAux += "		  SD3EXT.D3_DOC IN "		+ STR_PULA
	cQryAux += "			( SELECT DISTINCT D3_DOC FROM SD3010 SD3INT WHERE "		+ STR_PULA
	cQryAux += "				SD3INT.D_E_L_E_T_=''		AND "		+ STR_PULA
	cQryAux += "		 	(SD3EXT.D3_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) +"' ) AND"	+ STR_PULA
	cQryAux += "			(SD3EXT.D3_OP BETWEEN '" +MV_PAR03+"' AND '"+ MV_PAR04 +"') AND"		+ STR_PULA		
	cQryAux += "				SD3INT.D3_OP<>'' AND SD3INT.D3_CF ='PR0') AND"		+ STR_PULA
	cQryAux += "				SD3EXT.D_E_L_E_T_=''"		+ STR_PULA
	
	IF MV_PAR05<>1 
	cQryAux += "AND"		+ STR_PULA
	cQryAux += "(SELECT COUNT(D3_DOC) FROM SD3010 WHERE  D3_COD  LIKE 'MOD%' AND D3_OP=SD3EXT.D3_OP AND SD3010.D_E_L_E_T_='' AND SD3EXT.D3_DOC=SD3010.D3_DOC) "		+ STR_PULA
	IF MV_PAR05==2
    	cQryAux += "NOT IN (3,6,9)"		+ STR_PULA
    ELSE
   		cQryAux += " >0 "		+ STR_PULA
    ENDIF
 ENDIF

	cQryAux += "		GROUP BY"		+ STR_PULA
	cQryAux += "		SD3EXT.D3_COD,SD3EXT.D3_OP,SD3EXT.D3_DOC,SD3EXT.D3_EMISSAO,B1_DESC,SD3EXT.D3_QUANT,	B1_COD"		+ STR_PULA
    
	cQryAux += "		"		+ STR_PULA

	
	cQryAux += "		ORDER BY D3_OP,D3_DOC,D3_EMISSAO"		+ STR_PULA
	cQryAux += "		"		+ STR_PULA
	cQryAux := ChangeQuery(cQryAux)
	


	//Executando consulta e setando o total da régua
	TCQuery cQryAux New Alias "QRY_AUX"
	Count to nTotal
	TCSetField("QRY_AUX", "EMISSAO", "D")
	oReport:SetMeter(nTotal)
	
	//Enquanto houver dados
	oSectDad:Init()
	QRY_AUX->(DbGoTop())
	While ! QRY_AUX->(Eof())
		//Incrementando a régua
		nAtual++
		oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
		oReport:IncMeter()
		
		
		
			    cQryMod:= ""
	   			cQryMod += "	SELECT			"		+ STR_PULA
				cQryMod += "	SD3MOD.D3_COD AS cMOD, 	"		+ STR_PULA
				cQryMod += "	SUM(SD3MOD.D3_QUANT) AS tHMOD,	"		+ STR_PULA
				cQryMod += "	SUM(SD3MOD.D3_CUSTO1) AS tCMOD"		+ STR_PULA
				cQryMod += "	FROM SD3010 SD3MOD	"		+ STR_PULA
				cQryMod += "	WHERE SD3MOD.D3_COD LIKE 'MOD%' AND SD3MOD.D_E_L_E_T_='' AND "		+ STR_PULA
				cQryMod += "	D3_DOC='"+QRY_AUX->DOC +"' AND D3_OP='"+QRY_AUX->OP+"'	"		+ STR_PULA
				cQryMod += "	GROUP BY D3_COD "		+ STR_PULA
				cQryMod := ChangeQuery(cQryMod)
	    
	TCQuery cQryMod New Alias "QRY_MOD"
	Count To nTMOds
	QRY_MOD->(DbGoTop())
	  IF nTMOds==0
	  	oSectDad:PrintLine() 
	else		
    While ! QRY_MOD->(Eof())
       
        hMod:=QRY_MOD->tHMOD / QRY_AUX->QTD_PA
       	oSectDad:Cell("hMod"):SetValue(hMod)
    	oSectDad:PrintLine()
	    QRY_MOD ->(DbSkip())
    EndDo
    endif
	QRY_MOD->(DbCloseArea())
	QRY_AUX->(DbSkip())
	
	EndDo
	oSectDad:Finish()
	QRY_AUX->(DbCloseArea())
	
	RestArea(aArea)
Return
