#include 'protheus.ch'
#include 'parmtype.ch'

user function CUSTMP01()
	Local oReport

	Private cAliasQRY := "SB1"
	Private aRetCQ	:= {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao                                                  ³
	//Data : 28/03/2016 correcao do medio do ano anterio pelas ocorrencias                                    ³
	// Ultima Atualização foi corrigido o medio anual do custo FOb que estava igual ao da materia prima linhas 201/207 28/03/17
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport := ReportDef()
	oReport:PrintDialog()

return

Static Function ReportDef()

	Local oReport
	Local oSection
	Local oCell, x
	Local cPerg	:= "CSTO01"
	Local meses := {"Jan","Fev","Mar","Abr","Mai","Jun","Jul","Ago","Set","Out","Nov","Dez"}

	ValidPerg(cPerg)

	oReport := TReport():New("CUSTMP01","Evolução do custo da Material Prima",cPerg, {|oReport| ReportPrint(oReport)})
	oReport:SetLandScape()
	Pergunte(cPerg,.F.)

	oSection := TRSection():New(oReport,"Custos",{"SB1"}) //"Planilha de Orcamento"
	oSection:SetHeaderPage()

	TRCell():New(oSection,"B1_TPGAMA" ,"SB1")
	TRCell():New(oSection,"TPGAMA" ,"","Tipo Gama")
	TRCell():New(oSection,"B1_COD"    ,"SB1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection,"B1_DESC"   ,"SB1")
	TRCell():New(oSection,"B1_UM"     ,"SB1")
	oSection:Cell("B1_UM"):SetBorder(4,2)
	for x=1 to 12
	    TRCell():New(oSection,"FOB"+strzero(x,2)    ,""   ,"FOB "+meses[x]+" $"       ,PesqPict("SB1","B1_CUSTD"),,,)
		TRCell():New(oSection,"Custo"+strzero(x,2)    ,""   ,"Custo "+meses[x]+" R$"       ,PesqPict("SB1","B1_CUSTD"),,,)
		TRCell():New(oSection,"Frete"+strzero(x,2)    ,""   ,"Frete "+meses[x]+" R$"       ,PesqPict("SB1","B1_CUSTD"),,,)
		TRCell():New(oSection,"Despesa"+strzero(x,2)    ,"" ,"O.Desp. "+meses[x]+" R$"       ,PesqPict("SB1","B1_CUSTD"),,,)
		TRCell():New(oSection,"Total"+strzero(x,2)    ,""   ,"C.Total "+meses[x]+" R$"       ,PesqPict("SB1","B1_CUSTD"),,,)
		oSection:Cell("Total"+strzero(x,2)):SetBorder(4,2)
	next
	TRCell():New(oSection,"Mediafob"   ,""   ,"Medio FOB $"       ,PesqPict("SB1","B1_CUSTD"),,,)
	TRCell():New(oSection,"Mediac"   ,""   ,"Medio MP R$"       ,PesqPict("SB1","B1_CUSTD"),,,)
	TRCell():New(oSection,"Mediaf"   ,""   ,"Medio Frete R$"       ,PesqPict("SB1","B1_CUSTD"),,,)
	TRCell():New(oSection,"Mediad"   ,""   ,"Medio Desp. R$"       ,PesqPict("SB1","B1_CUSTD"),,,)
	TRCell():New(oSection,"Media"   ,""   ,"Medio Ano R$"       ,PesqPict("SB1","B1_CUSTD"),,,)
	oSection:Cell("Media"):SetBorder(4,3)
	for x=1 to 12
	    TRCell():New(oSection,"aFOB"+strzero(x,2)    ,""   ,"FOB "+MV_PAR06+" "+meses[x]+" $"       ,PesqPict("SB1","B1_CUSTD"),,,)
		TRCell():New(oSection,"aCusto"+strzero(x,2)    ,""   ,"Custo "+MV_PAR06+" "+meses[x]+" R$"       ,PesqPict("SB1","B1_CUSTD"),,,)
		TRCell():New(oSection,"aFrete"+strzero(x,2)    ,""   ,"Frete "+MV_PAR06+" "+meses[x]+" R$"       ,PesqPict("SB1","B1_CUSTD"),,,)
		TRCell():New(oSection,"aDespesa"+strzero(x,2)    ,"" ,"O.Desp. "+MV_PAR06+" "+meses[x]+" R$"       ,PesqPict("SB1","B1_CUSTD"),,,)
		TRCell():New(oSection,"aTotal"+strzero(x,2)    ,""   ,"C.Total "+MV_PAR06+" "+meses[x]+" R$"       ,PesqPict("SB1","B1_CUSTD"),,,)
		oSection:Cell("aTotal"+strzero(x,2)):SetBorder(4,2)
	next

	TRCell():New(oSection,"aMediafob"   ,""   ,"Medio "+MV_PAR06+" FOB $"       ,PesqPict("SB1","B1_CUSTD"),,,)
	TRCell():New(oSection,"aMediac"   ,""   ,"Medio "+MV_PAR06+" MP R$"       ,PesqPict("SB1","B1_CUSTD"),,,)
	TRCell():New(oSection,"aMediaf"   ,""   ,"Medio "+MV_PAR06+" Frete R$"       ,PesqPict("SB1","B1_CUSTD"),,,)
	TRCell():New(oSection,"aMediad"   ,""   ,"Medio "+MV_PAR06+" Desp. R$"       ,PesqPict("SB1","B1_CUSTD"),,,)
	TRCell():New(oSection,"aMedia"   ,""   ,"Medio "+MV_PAR06+" Ano R$"       ,PesqPict("SB1","B1_CUSTD"),,,)
	oSection:Cell("aMedia"):SetBorder(4,3)
Return(oReport)

Static Function ReportPrint(oReport)

	Local oSection  := oReport:Section(1)
	Local oBreak, x
	Local aCust :={}

	MakeSqlExpr(oReport:uParam)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query do relatório da secao 1                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:Section(1):BeginQuery()

	cAliasQRY := GetNextAlias() 
	BeginSql Alias cAliasQRY
	SELECT B1_TPGAMA,ISNULL(X5_DESCRI,'S/CLASSIFICACAO!') TPGAMA,B1_COD,B1_DESC,B1_UM
	FROM %table:SB1% SB1
	LEFT OUTER JOIN %table:SX5% SX5 ON X5_FILIAL=%xFilial:SX5% AND X5_TABELA='IC' AND X5_CHAVE=B1_TPGAMA AND SX5.%NotDel%
	WHERE B1_FILIAL= %xFilial:SB1% AND B1_COD>= %Exp:mv_par01% AND B1_COD<= %Exp:mv_par02% AND
	B1_TPGAMA>=%Exp:mv_par03%  AND B1_TPGAMA<=%Exp:mv_par04%   AND  SB1.%NotDel%
	AND (
	SELECT SUM(D1_QUANT)
	FROM %table:SD1% SD1,%table:SF4% SF4
	WHERE D1_FILIAL=%xFilial:SD1% AND (SUBSTRING(D1_DTDIGIT,1,4)=%Exp:mv_par05%  OR SUBSTRING(D1_DTDIGIT,1,4)=%Exp:mv_par06%) AND D1_NUMSEQ<>'' AND SD1.R_E_C_N_O_<>0
	AND SD1.D_E_L_E_T_<>'*' AND D1_COD=B1_COD
	AND F4_FILIAL=%xFilial:SF4% AND F4_CODIGO=D1_TES AND SF4.R_E_C_N_O_<>0 AND SF4.%NotDel% AND F4_ESTOQUE='S'
	)>0
	ORDER BY B1_TPGAMA,B1_COD
	EndSql
	lcor:=.T.
	oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)
	oSection:Cell("Media"):SetBorder(4,2)
	dbSelectArea(cAliasQRY)
	oSection:Init()
	While !oReport:Cancel() .And. !(cAliasQRY)->(Eof())
		oReport:IncMeter()
		aCust:=aRetStq((cAliasQRY)->B1_COD,MV_PAR05)
		aCustcomp:=aRetStq((cAliasQRY)->B1_COD,MV_PAR06)
		anmedioc := 0
		anmediof := 0
		anmediod := 0
		anmedio := 0
		nmedioc := 0
		nmediof := 0
		nmediod := 0
		nmedio := 0
		nocor  := 0
		anocor  := 0
		nmediofob:=0 
		anmediofob:=0
		for x=1 to 12
		   oSection:Cell("FOB"+strzero(x,2)):SetValue(aCust[5,x]/( iif(aCust[1,x]==0,1,aCust[1,x]) ))
			oSection:Cell("Custo"+strzero(x,2)):SetValue(aCust[2,x]/( iif(aCust[1,x]==0,1,aCust[1,x]) ))
			oSection:Cell("Frete"+strzero(x,2)):SetValue(aCust[3,x]/( iif(aCust[1,x]==0,1,aCust[1,x]) ))
			oSection:Cell("Despesa"+strzero(x,2)):SetValue(aCust[4,x]/( iif(aCust[1,x]==0,1,aCust[1,x]) ))
			oSection:Cell("Total"+strzero(x,2)):SetValue((aCust[2,x]+aCust[3,x]+aCust[4,x])/( iif(aCust[1,x]==0,1,aCust[1,x]) ))

         oSection:Cell("aFOB"+strzero(x,2)):SetValue(aCustcomp[5,x]/( iif(aCustcomp[1,x]==0,1,aCustcomp[1,x]) ))
			oSection:Cell("aCusto"+strzero(x,2)):SetValue(aCustcomp[2,x]/( iif(aCustcomp[1,x]==0,1,aCustcomp[1,x]) ))
			oSection:Cell("aFrete"+strzero(x,2)):SetValue(aCustcomp[3,x]/( iif(aCustcomp[1,x]==0,1,aCustcomp[1,x]) ))
			oSection:Cell("aDespesa"+strzero(x,2)):SetValue(aCustcomp[4,x]/( iif(aCustcomp[1,x]==0,1,aCustcomp[1,x]) ))
			oSection:Cell("aTotal"+strzero(x,2)):SetValue((aCustcomp[2,x]+aCustcomp[3,x]+aCustcomp[4,x])/( iif(aCustcomp[1,x]==0,1,aCustcomp[1,x]) ))

			nocor += iif(aCust[2,x]+aCust[3,x]+aCust[4,x]>0,1,0)
			nmedio+=(aCust[2,x]+aCust[3,x]+aCust[4,x])/ iif(aCust[1,x]==0,1,aCust[1,x])
			nmediofob+= aCust[5,x] / iif(aCust[1,x]==0,1,aCust[1,x])
			nmedioc+= aCust[2,x] / iif(aCust[1,x]==0,1,aCust[1,x])
			nmediof+= aCust[3,x] / iif(aCust[1,x]==0,1,aCust[1,x])
			nmediod+= aCust[4,x] / iif(aCust[1,x]==0,1,aCust[1,x])

			anocor += iif(aCustcomp[2,x]+aCustcomp[3,x]+aCustcomp[4,x]>0,1,0)
			anmedio+=(aCustcomp[2,x]+aCustcomp[3,x]+aCustcomp[4,x])/ iif(aCustcomp[1,x]==0,1,aCustcomp[1,x])
			anmediofob+= aCustcomp[5,x] / iif(aCustcomp[1,x]==0,1,aCustcomp[1,x])
			anmedioc+= aCustcomp[2,x] / iif(aCustcomp[1,x]==0,1,aCustcomp[1,x])
			anmediof+= aCustcomp[3,x] / iif(aCustcomp[1,x]==0,1,aCustcomp[1,x])
			anmediod+= aCustcomp[4,x] / iif(aCustcomp[1,x]==0,1,aCustcomp[1,x])

			if lcor
			    oSection:Cell("FOB"+strzero(x,2)):SetClrBack(CLR_WHITE) //cor do fundo 
				oSection:Cell("Custo"+strzero(x,2)):SetClrBack(CLR_WHITE) //cor do fundo
				oSection:Cell("Frete"+strzero(x,2)):SetClrBack(CLR_WHITE) //cor do fundo
				oSection:Cell("Despesa"+strzero(x,2)):SetClrBack(CLR_WHITE) //cor do fundo
				oSection:Cell("Total"+strzero(x,2)):SetClrBack(CLR_WHITE) //cor do fundo
				oSection:Cell("FOB"+strzero(x,2)):SetClrFore(CLR_BLACK) //cor do fundo
				oSection:Cell("Custo"+strzero(x,2)):SetClrFore(CLR_BLACK) //cor do fundo
				oSection:Cell("Frete"+strzero(x,2)):SetClrFore(CLR_BLACK) //cor do fundo
				oSection:Cell("Despesa"+strzero(x,2)):SetClrFore(CLR_BLACK) //cor do fundo
				oSection:Cell("Total"+strzero(x,2)):SetClrFore(CLR_BLACK) //cor do fundo
			else
			    oSection:Cell("FOB"+strzero(x,2)):SetClrBack(CLR_BLACK) //cor do fundo 
				oSection:Cell("Custo"+strzero(x,2)):SetClrBack(CLR_BLACK) //cor do fundo
				oSection:Cell("Frete"+strzero(x,2)):SetClrBack(CLR_BLACK) //cor do fundo
				oSection:Cell("Despesa"+strzero(x,2)):SetClrBack(CLR_BLACK) //cor do fundo
				oSection:Cell("Total"+strzero(x,2)):SetClrBack(CLR_BLACK) //cor do fundo
				oSection:Cell("FOB"+strzero(x,2)):SetClrFore(CLR_WHITE) //cor do fundo
				oSection:Cell("Custo"+strzero(x,2)):SetClrFore(CLR_WHITE) //cor do fundo
				oSection:Cell("Frete"+strzero(x,2)):SetClrFore(CLR_WHITE) //cor do fundo
				oSection:Cell("Despesa"+strzero(x,2)):SetClrFore(CLR_WHITE) //cor do fundo
				oSection:Cell("Total"+strzero(x,2)):SetClrFore(CLR_WHITE) //cor do fundo
			endif
		next
		if lcor
			oSection:Cell("B1_TPGAMA"):SetClrBack(CLR_WHITE) //cor do fundo
			oSection:Cell("B1_COD"):SetClrBack(CLR_WHITE) //cor do fundo
			oSection:Cell("B1_DESC"):SetClrBack(CLR_WHITE) //cor do fundo
			oSection:Cell("B1_UM"):SetClrBack(CLR_WHITE) //cor do fundo
			oSection:Cell("Media"):SetClrBack(CLR_WHITE) //cor do fundo
			oSection:Cell("B1_TPGAMA"):SetClrFore(CLR_BLACK) //cor do fundo
			oSection:Cell("B1_COD"):SetClrFore(CLR_BLACK) //cor do fundo
			oSection:Cell("B1_DESC"):SetClrFore(CLR_BLACK) //cor do fundo
			oSection:Cell("B1_UM"):SetClrFore(CLR_BLACK) //cor do fundo
			oSection:Cell("Media"):SetClrFore(CLR_BLACK) //cor do fundo
			lcor:=.F.
		else
			oSection:Cell("B1_TPGAMA"):SetClrBack(CLR_BLACK) //cor do fundo
			oSection:Cell("B1_COD"):SetClrBack(CLR_BLACK) //cor do fundo
			oSection:Cell("B1_DESC"):SetClrBack(CLR_BLACK) //cor do fundo
			oSection:Cell("B1_UM"):SetClrBack(CLR_BLACK) //cor do fundo
			oSection:Cell("Media"):SetClrBack(CLR_BLACK) //cor do fundo
			oSection:Cell("B1_TPGAMA"):SetClrFore(CLR_WHITE) //cor do fundo
			oSection:Cell("B1_COD"):SetClrFore(CLR_WHITE) //cor do fundo
			oSection:Cell("B1_DESC"):SetClrFore(CLR_WHITE) //cor do fundo
			oSection:Cell("B1_UM"):SetClrFore(CLR_WHITE) //cor do fundo
			oSection:Cell("Media"):SetClrFore(CLR_WHITE) //cor do fundo
			lcor:=.T.
		endif
		//oSection:Cell("TPGAMA"):SetValue(Posicione( "SX5" , 1 , xFilial("SX5") + "IC" + SubStr( (cAliasQRY)->B1_TPGAMA , 1 , 3 ) , "X5_DESCRI" ))
		oSection:Cell("Media"):SetValue(nmedio/nocor)
		oSection:Cell("Mediafob"):SetValue(nmediofob/nocor)
		oSection:Cell("Mediac"):SetValue(nmedioc/nocor)
		oSection:Cell("Mediaf"):SetValue(nmediof/nocor)
		oSection:Cell("Mediad"):SetValue(nmediod/nocor)

		oSection:Cell("aMedia"):SetValue(anmedio/anocor)
		oSection:Cell("aMediafob"):SetValue(anmediofob/anocor)
		oSection:Cell("aMediac"):SetValue(anmedioc/anocor)
		oSection:Cell("aMediaf"):SetValue(anmediof/anocor)
		oSection:Cell("aMediad"):SetValue(anmediod/anocor)
		oSection:PrintLine()
		dbSelectArea(cAliasQRY)
		dbSkip()
		aCust :={}
	EndDo
	oSection:Finish()
	dbSelectArea(cAliasQRY)
	dbclosearea(cAliasQRY)
Return NIL

Static Function aRetStq(cprod,ano)
	Local aret:={{0,0,0,0,0,0,0,0,0,0,0,0}, {0,0,0,0,0,0,0,0,0,0,0,0}, {0,0,0,0,0,0,0,0,0,0,0,0}, {0,0,0,0,0,0,0,0,0,0,0,0}, {0,0,0,0,0,0,0,0,0,0,0,0} }
	Local cAliasSTC := GetNextAlias()

	BeginSql Alias cAliasSTC

	SELECT  D1_PEDIDO,D1_ITEMPC,D1_TIPO,D1_X_MNOT,D1_COD,MONTH(D1_DTDIGIT) MES,ISNULL(SUM(D1_QUANT),0) QUANT,SUM(D1_CUSTO) VALOR
	FROM %table:SD1% SD1,%table:SF4% SF4
	WHERE D1_FILIAL=%xFilial:SD1% AND SUBSTRING(D1_DTDIGIT,1,4)=%Exp:ano%  AND D1_NUMSEQ<>'' AND SD1.R_E_C_N_O_<>0
	AND SD1.D_E_L_E_T_<>'*' AND D1_COD=%Exp:cprod%
	AND F4_FILIAL=%xFilial:SF4% AND F4_CODIGO=D1_TES AND SF4.R_E_C_N_O_<>0 AND SF4.D_E_L_E_T_<>'*'  AND F4_ESTOQUE='S'
	GROUP BY D1_TIPO,D1_X_MNOT,D1_COD, D1_PEDIDO,D1_ITEMPC,MONTH(D1_DTDIGIT)
	ORDER BY MONTH(D1_DTDIGIT),D1_TIPO

	EndSql
	dbselectArea(cAliasSTC)
	(cAliasSTC)->(dbgotop())

	While !(cAliasSTC)->(Eof())
		aret[1,(cAliasSTC)->MES]+=(cAliasSTC)->QUANT
		aret[2,(cAliasSTC)->MES]+=IIF((cAliasSTC)->D1_TIPO=="N",(cAliasSTC)->VALOR,0)
		aret[3,(cAliasSTC)->MES]+=IIF((cAliasSTC)->D1_TIPO=="C" .AND. "FRET"$(cAliasSTC)->D1_X_MNOT  ,(cAliasSTC)->VALOR,0)
		aret[4,(cAliasSTC)->MES]+=IIF((cAliasSTC)->D1_TIPO=="C" .AND. !("FRET"$(cAliasSTC)->D1_X_MNOT),(cAliasSTC)->VALOR,0)
		//PROCESSAR CUSTO FOB SOLICITADO EM 26/09/2016 SRa. Cleonice
		IF LEN(ALLTRIM((cAliasSTC)->D1_PEDIDO))>0
		 txFob:=POSICIONE("SC7",14,xfilial("SC7")+(cAliasSTC)->(D1_PEDIDO+D1_ITEMPC),"C7_TXMOEDA")
		 IF txFob==0 ; txFob:=1 ; ENDIF
		 aret[5,(cAliasSTC)->MES]+= (cAliasSTC)->VALOR / txFob 
		ENDIF  
		dbSkip()
	EndDo

	dbclosearea(cAliasSTC)
Return(aret)

Static Function ValidPerg(cPerg)
	PutSX1(cPerg,"01","Codigo de  ?"  , "", "", "mv_ch1", "C", 15,00,00,"G",""    ,"   ","","","mv_par01")
	PutSX1(cPerg,"02","Codigo Ate ?"  , "", "", "mv_ch2", "C", 15,00,00,"G",""    ,"   ","","","mv_par02")
	PutSX1(cPerg,"03","Tipo Gama de ?", "", "", "mv_ch3", "C", 3,00,00,"G",""    ,"   ","","","mv_par03")
	PutSX1(cPerg,"04","Tipo Gama Ate?", "", "", "mv_ch4", "C", 3,00,00,"G",""    ,"   ","","","mv_par04")
	PutSX1(cPerg,"05","Ano Ref ?", "", "", "mv_ch5", "C", 4,00,00,"G",""    ,"   ","","","mv_par05")
	PutSX1(cPerg,"06","Ano Comparação ?", "", "", "mv_ch6", "C", 4,00,00,"G",""    ,"   ","","","mv_par06")
Return	