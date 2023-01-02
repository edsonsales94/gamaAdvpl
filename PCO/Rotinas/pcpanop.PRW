#include 'protheus.ch'
#include 'parmtype.ch'

user function pcpanop()
   
	oReport := ReportDef()
	oReport:PrintDialog()

Return NIL

Static Function ReportDef(lUsed)
	Local oReport
	Local oSection1
	Local cTitle := OemToAnsi("MRP") //"MRP"
	Local cPerg:="ANLOP"
    ValidPerg(cPerg)   
	oReport := TReport():New("PCPANOP","Analise de Ordem de Produção",cPerg, {|oReport| ReportPrint(oReport)})
	oReport:SetLandScape()
	oReport:HideParamPage()
	oReport:PrintHeader(.F.,.F.)
	oReport:lEmptyLineExcel:=.F.
	Pergunte(oReport:uParam,.F.)

	oSection1 := TRSection():New(oReport,"Ordem de Producao",{"SC2"}) //"Planilha de Orcamento"
	TRCell():New(oSection1,"C2_NUM"  ,"SC2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"C2_PRODUTO"  ,"SC2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"PRODUTO"  ,"",'Produto a Produzir'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"C2_XEND"  ,"SC2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"C2_QUANT"  ,"SC2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"C2_QUJE"  ,"SC2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

	oSection2 := TRSection():New(oSection1,"Movimentacoes",{"SD3"}) //"Planilha de Orcamento"
	TRCell():New(oSection2,"D3_EMISSAO"  ,"SD3",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"D3_COD"  ,"SD3",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"COMP"  ,"",'Componente',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"ENDERECO"  ,"",'Endereco',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"ENTRADA"  ,"","Entrada",PesqPict("SD3","D3_QUANT"),/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"SAIDA"  ,"","Saida",PesqPict("SD3","D3_QUANT"),/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"D3_UM"  ,"SD3",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"D3_TIPO"  ,"SD3",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"ALMOX"  ,"",'Almox',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"D3_CF"  ,"SD3",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"D3_DOC"  ,"SD3",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"D3_NUMSEQ"  ,"SD3",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"D3_USUARIO"  ,"SD3",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"D3_OBSERVA"  ,"SD3",/*Titulo*/,/*Picture*/,50,/*lPixel*/,/*{|| code-block de impressao }*/)

Return(oReport)

Static Function ReportPrint(oReport)
	Local oSection1 := oReport:Section(1)
	Local osection2 := oReport:Section(1):Section(1)
	Local cAliasQRY

	MakeSqlExpr(oReport:uParam)

	oReport:Section(1):BeginQuery()
	cAliasQRY := GetNextAlias()
	BeginSql Alias cAliasQRY
	select C2_NUM,C2_PRODUTO,SB11.B1_DESC PRODUTO,C2_XEND,C2_QUANT,C2_QUJE,D3_EMISSAO,D3_DOC,D3_NUMSEQ,ISNULL(DB_LOCALIZ,'NA CONTROLA END') ENDERECO,
	ISNULL(DB_LOCAL,'') ALMOX,D3_CF,D3_COD,SB12.B1_DESC COMP,D3_UM,D3_TIPO,D3_QUANT,D3_CUSTO1,D3_USUARIO,SB12.B1_XKANBAN,D3_OBSERVA,ISNULL(DB_HRINI,'') HORA
	from %table:SD3% SD31
	LEFT OUTER JOIN %table:SDB% SDB1 ON  DB_FILIAL=D3_FILIAL AND DB_PRODUTO=D3_COD AND DB_NUMSEQ=D3_NUMSEQ  AND SDB1.%NotDel%
	LEFT OUTER JOIN %table:SC2% SC21 ON C2_NUM=LEFT(D3_OP,6) AND SC21.%NotDel%
	LEFT OUTER JOIN %table:SB1% SB11 ON SB11.B1_FILIAL='' AND SB11.B1_COD=C2_PRODUTO AND SB11.%NotDel%
	LEFT OUTER JOIN %table:SB1% SB12 ON SB12.B1_FILIAL='' AND SB12.B1_COD=D3_COD AND SB12.%NotDel%
	WHERE D3_FILIAL=%xFilial:SD3%  AND left(D3_OP,6)=%Exp:LEFT(MV_PAR01,6)%
	AND LEFT(D3_COD,3)<>'MOD' AND D3_ESTORNO<>'S' AND SD31.%NotDel%

	UNION

	select C2_NUM,C2_PRODUTO,SB13.B1_DESC PRODUTO,C2_XEND,C2_QUANT,C2_QUJE,D3_EMISSAO,D3_DOC,D3_NUMSEQ,ISNULL(DB_LOCALIZ,'NA CONTROLA END') ENDERECO,
	ISNULL(DB_LOCAL,'') ALMOX,D3_CF,D3_COD,SB14.B1_DESC COMP,D3_UM,D3_TIPO,D3_QUANT,D3_CUSTO1,D3_USUARIO,SB14.B1_XKANBAN,D3_OBSERVA,ISNULL(DB_HRINI,"") HORA
	from %table:SD3% SD32
	LEFT OUTER JOIN %table:SDB% SDB2 ON DB_FILIAL=D3_FILIAL AND DB_PRODUTO=D3_COD AND DB_NUMSEQ=D3_NUMSEQ  AND SDB2.%NotDel%
	LEFT OUTER JOIN %table:SC2% SC22 ON C2_NUM=SUBSTRING(D3_OBSERVA,7,6) AND SC22.%NotDel%
	LEFT OUTER JOIN %table:SB1% SB13 ON SB13.B1_FILIAL='' AND SB13.B1_COD=C2_PRODUTO AND SB13.%NotDel%
	LEFT OUTER JOIN %table:SB1% SB14 ON SB14.B1_FILIAL='' AND SB14.B1_COD=D3_COD AND SB14.%NotDel%
	WHERE D3_FILIAL=%xFilial:SD3%  AND D3_CF IN ('RE3','RE4') AND  LEFT(D3_OBSERVA,12)=%Exp:"RQ/OP "+LEFT(MV_PAR01,6)%
	AND LEFT(D3_COD,3)<>'MOD'  AND D3_ESTORNO<>'S' AND SD32.%NotDel%
	ORDER BY C2_NUM,D3_EMISSAO,D3_CF,D3_COD,D3_NUMSEQ
	EndSql
	oReport:Section(1):EndQuery()

    oReport:SetDevice(4)
    oReport:lEmptyLineExcel:=.T.
    
    oReport:XlsNewStyle("CTIT","CIT",1,{'ARIAL BLACK" ss:Color="#4472C4',8},,.f.,"C")
    oReport:XlsNewStyle("NTIT","NIT",3,{'ARIAL BLACK" ss:Color="#4472C4',8},,.f.,"C")
    oReport:XlsNewStyle("NENT","ENT",3,{'Courier New" ss:Color="#4472C4',8},,.f.,"C")
    oReport:XlsNewStyle("TIT","TIT",2,{"ARIAL",14},,.f.,"C")
    
    OSection1:CELL(1):cXlsStyle:="CTIT"
    OSection1:CELL(2):cXlsStyle:="CTIT"
    OSection1:CELL(3):cXlsStyle:="CTIT"
    OSection1:CELL(4):cXlsStyle:="CTIT"
    OSection1:CELL(5):cXlsStyle:="NTIT"
    OSection1:CELL(6):cXlsStyle:="NTIT"
    oSection2:SetParentQuery()

	dbSelectArea(cAliasQRY)
	DBGOTOP()
	oSection1:Init()
	oReport:XlsNewRow(.t.)
	oReport:XlsNewCell("Relatorio para Conferencia de Ordem de Producao",.f.,2,"TIT",14,20,"C")
	While !oReport:Cancel() .And. !(cAliasQRY)->(Eof())
		If oReport:Cancel()
			Exit
		EndIf
	    oReport:IncMeter()
	    oSection1:Printline()
	    oReport:SkipLine()  
	    cOpAnt:=(cAliasQRY)->C2_NUM
	    While !(cAliasQRY)->(Eof()) .and. (cAliasQRY)->C2_NUM == cOpAnt
	      oSection2:Init()
	      oSection2:SetLinesBefore(0)
	      oReport:IncMeter()
	      oSection2:CELL("ENTRADA"):HIDE()
	      oSection2:CELL("SAIDA"):HIDE()
	      oSection2:CELL("D3_CF"):SetValue((cAliasQRY)->D3_CF)
	      IF (cAliasQRY)->D3_CF$"RE3/RE4" .and. (cAliasQRY)->ALMOX=="11"
	         oSection2:CELL("SAIDA"):Show()
	         oSection2:CELL("SAIDA"):SetValue((cAliasQRY)->D3_QUANT)
	      ELSEIF ((cAliasQRY)->D3_CF$"RE3/RE4" .and. (cAliasQRY)->ALMOX=="20") .OR. (cAliasQRY)->D3_CF=="PR0"
	         oSection2:CELL("ENTRADA"):Show()  
	         oSection2:CELL("ENTRADA"):SetValue((cAliasQRY)->D3_QUANT)
	         oSection2:CELL("D3_CF"):SetValue(IIF(alltrim((cAliasQRY)->D3_CF)=="RE4","DE4", (cAliasQRY)->D3_CF) )
	      ELSEIF (cAliasQRY)->D3_CF$"RE1/RE2/RE0"
	        oSection2:CELL("SAIDA"):Show()   
	        oSection2:CELL("SAIDA"):SetValue((cAliasQRY)->D3_QUANT)
	      ELSEIF (cAliasQRY)->D3_CF$"DE1/DE2/DE0"
	        oSection2:CELL("ENTRADA"):Show() 
	        oSection2:CELL("ENTRADA"):SetValue((cAliasQRY)->D3_QUANT)
	      ENDIF
	      IF ALLTRIM((cAliasQRY)->D3_CF)=="RE1"
	        oSection2:CELL("D3_OBSERVA"):SetValue("SCRAP DE COMPONENTE")
	      ELSE
	       IF ALLTRIM((cAliasQRY)->B1_XKANBAN)=="S"
	         oSection2:CELL("D3_OBSERVA"):SetValue("KANBAM "+ALLTRIM((cAliasQRY)->HORA)+" - "+ALLTRIM((cAliasQRY)->D3_OBSERVA ))
	       ELSE
	         oSection2:CELL("D3_OBSERVA"):SetValue("HR. "+ALLTRIM((cAliasQRY)->HORA)+" - "+ALLTRIM((cAliasQRY)->D3_OBSERVA ))  
	       ENDIF
	      ENDIF  
	      OSection2:CELL("ENTRADA"):cXlsStyle:="NENT"
	      oSection2:PrintLine() // Impressao da secao 2
	      (cAliasQRY)->(dbSkip())
        EndDo
        oSection2:Finish()
        oReport:SkipLine()
    Enddo
    oSection1:Finish()
    (cAliasQRY)->(DbCloseArea()) 
Return Nil

Static Function ValidPerg(cPerg)
	PutSX1(cPerg,"01","Ordem de Producao  ?"    , "", "", "mv_ch1", "C", 11,00,00,"G",""    ,"SC2","","","mv_par01")
Return Nil