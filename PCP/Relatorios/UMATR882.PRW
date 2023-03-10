#Include "FIVEWIN.CH"

/*-------------------------------------------------------------------*/
/*/{Protheus.doc} MATR882
MRP

@author Ricardo Prandi
@since 30/10/2013
@version P11
@obs Programa c?pia do MATR880, lendo as novas tabelas do MRP
/*/
/*-------------------------------------------------------------------*/

User Function 2(lUsed)
	Local   oReport

	Default lUsed := .F.

	//Interface de impressao
	oReport := ReportDef(lUsed)
	oReport:PrintDialog()

Return NIL

/*------------------------------------------------------------------------//
//Programa:	ReportDef
//Autor:		Felipe Nunes Toledo
//Data:		11/07/06
//Descricao:	A funcao estatica ReportDef devera ser criada para todos os relatorios que poderao ser agendados pelo usuario
//Uso: 		MATR882
//------------------------------------------------------------------------*/
Static Function ReportDef(lUsed)
	Local oReport
	Local oSection1
	Local cTitle := OemToAnsi("MRP") //"MRP"

	//Criacao do componente de impressao
	//TReport():New
	//ExpC1 : Nome do relatorio
	//ExpC2 : Titulo
	//ExpC3 : Pergunte
	//ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao             
	//ExpC5 : Descricao
	
	oReport:= TReport():New("MATR882",cTitle,"MATR882", {|oReport| ReportPrint(oReport,cTitle,lUsed)},OemToAnsi("Este programa ira imprimir a Relacao do MRP")) //"Este programa ira imprimir a Rela??o do MRP"
	oReport:SetPortrait() //Define a orientacao de pagina do relatorio como paisagem.
    oReport:XmlLoad("czixml.xml")       

	//Criacao das secoes utilizadas pelo relatorio
	//
	//TRSection():New
	//ExpO1 : Objeto TReport que a secao pertence
	//ExpC2 : Descricao da se?ao
	//ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela
	//        sera considerada como principal para a se??o.
	//ExpA4 : Array com as Ordens do relat?rio
	//ExpL5 : Carrega campos do SX3 como celulas
	//        Default : False
	//ExpL6 : Carrega ordens do Sindex
	//        Default : False

	//oSection1
	oSection1 := TRSection():New(oReport,"Produtos",{"SB1"},/*Ordem*/) //"Produtos"
	oSection1:SetHeaderPage()

	TRCell():New(oSection1,'B1_COD'    ,'SB1',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'B1_DESC' 	,'SB1',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	//TRCell():New(oSection1,'B1_UM'   	,'SB1',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	//TRCell():New(oSection1,'B1_LE'   	,'SB1',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,  {|| RetFldProd(SB1->B1_COD,"B1_LE") })
	//TRCell():New(oSection1,'B1_ESTSEG' ,'SB1',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,  {|| RetFldProd(SB1->B1_COD,"B1_ESTSEG") })
	//TRCell():New(oSection1,'B1_EMIN' 	,'SB1',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,  {|| RetFldProd(SB1->B1_COD,"B1_EMIN") })
	//TRCell():New(oSection1,'B1_TIPO' 	,'SB1',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

Return(oReport)

/*------------------------------------------------------------------------//
//Programa:	ReportPrint
//Autor:		Felipe Nunes Toledo
//Data:		11/07/06
//Descricao:	A funcao estatica ReportPrint devera ser criada para todos os relatorios que poderao ser agendados pelo usuario.
//Uso: 		MATR882
//------------------------------------------------------------------------*/
Static Function ReportPrint(oReport,cTitle,lUsed)
	//Variaveis do tipo objeto
	Local oSection1 := oReport:Section(1)
	Local oSection2,oSection3,oSection4,oSection5,oBreak

	Local lContinua 	:= .T.
	Local lVNecesEst	:= .F.
	Local lLista		:= .F.
	Local lAchou    	:= .T.
	Local lLogMrp		:= .F.

	Local nTipo     	:= 0
	Local j         	:= 0
	Local i			:= 0
	Local nCusto    	:= 0
	Local nRec		 	:= 0
	Local nParRel		:= 0
	Local nTotValor	:= 0
	Local nQtdPer		:= 0
	Local nH5_Quant 	:= 0

	Local cSeekLog	:= ""
	Local cCondSH5 	:= "CZI_PROD != '"+Criavar("B1_COD",.F.)+"'"
	Local cCampo		:= ""
	Local cFilUsrSB1	:= ""
	Local cFil		  	:= ""
	Local cAliasCZJ 	:= ""

	Local aTam     	:= TamSX3("B2_QFIM")
	Private aPerOri   	:= {}
	Private aPerQuebra  	:= {}
	Private cPerg       	:= "MATR882"
	Private nPeriodos   	:= 0
	Private nTipoCusto  	:= 1
	Private aPeriodos		:= {}
	Private lQuebraPer	:= .F.
	Private nNumPer		:= 0

	//Verifica as perguntas selecionadas (MATR882)
	//Variaveis utilizadas para parametros
	//mv_par01 - Lista ? Tudo     So' c/ Saidas   So' c/ Neces.
	//mv_par02 - De Produto
	//mv_par03 - Ate Produto
	//mv_par04 - Lista log de eventos  1 = sim 2 = nao
	//mv_par05 - Custo Produto: 1-Custo Standard;2-Custo Medio;3-Preco Compra
	//mv_par06 - Aglutina Periodos     1 = sim 2 = nao
	//mv_par07 - Periodos para aglutina
	//mv_par08 - Lista a Necess. da Estrutura? 1 = sim 2 = nao

	Pergunte(oReport:GetParam(),.F.)

	nParRel     := mv_par01
	nTipoCusto  := mv_par05
	lLogMrp     := mv_par04 == 1
	lQuebraPer  := mv_par06 == 1
	nNumPer     := mv_par07
	lVNecesEst  := mv_par08 == 1

	//Monta os Cabecalhos
	If lUsed != .T.
		lContinua := MATA712LCK()
	EndIf

	If lContinua
		dbSelectArea("CZI")

		If !Empty(dbFilter())
			dbClearFilter()
		EndIf

		dbSetOrder(1)
		dbGotop()

		//Definindo o titulo do relatorio
		oReport:SetTitle(cTitle+" - "+"MRP Programacao"+" "+CZI->CZI_NRMRP) //"MRP"##"Programacao"

		aPeriodos := R882PER(@nTipo)

		If lQuebraPer
			aPerOri    := aClone(aPeriodos)
			aPerQuebra := UR882DivPeriodo(aPeriodos,.T.)
			aPeriodos  := UR882DivPeriodo(aPeriodos)
		EndIf
		dbSelectArea("CZI")
		Set Filter to &cCondSH5
	EndIf

	cAliasCZJ := MATA712MVW()
	oSection1:HideHeader()
	//oSection2
	oSection2 := TRSection():New(oSection1,cTitle,{cAliasCZJ,"SB1","CZI"},/*Ordem*/) //"MRP"
	oSection2:SetHeaderPage()
	TRCell():New(oSection2,'B1_ORIGAMA','SB1','Origem',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,'TEXTO',cAliasCZJ,'Codigo','',25,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,'B1_XCODARI' 	,'SB1',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,'B1_DESC' 	,'SB1',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,'B1_UM'   	,'SB1',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,'B1_TIPO'   	,'SB1',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection2,'CUSTO'   	,cAliasCZJ,'V.Unit',"@E 999,999.99",12,/*lPixel*/,/*{|| code-block de impressao }*/)
	For i := 1 to Len(aPeriodos)
		For j:=1 to 6
			cCampo := "PER"+StrZero(i,3)+StrZero(j,2)
			if j==1
				TRCell():New(oSection2,cCampo,cAliasCZJ,DtoC(aPeriodos[i])+" Sld.Ini.","999999999999.99",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
			elseif j==2 ; TRCell():New(oSection2,cCampo,cAliasCZJ,"Entradas","999999999999.99",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
			elseif j==3 ; TRCell():New(oSection2,cCampo,cAliasCZJ,"Saidas","999999999999.99",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
			elseif j==4 ; TRCell():New(oSection2,cCampo,cAliasCZJ,"S.p/Estrut.","999999999999.99",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
			elseif j==5 ; TRCell():New(oSection2,cCampo,cAliasCZJ,"Sld.Final","999999999999.99",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
			elseif j==6 ; TRCell():New(oSection2,cCampo,cAliasCZJ,"Necessidade","999999999999.99",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
			endif
			oSection2:Cell(cCampo):SetLineBreak() // Define quebra de linha caso as colunas nao couberem na pagina
		Next
	Next i

	TRCell():New(oSection2,'PRODUTO',cAliasCZJ,'Produto','',/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

	//oSection3
	oSection3 := TRSection():New(oSection2,cTitle,{cAliasCZJ,"SB1","CZI"},/*Ordem*/) //"MRP"
	oSection3:SetHeaderPage(.F.)
	oSection3:SetHeaderSection(.F.)

	TRCell():New(oSection3,'TEXTO',cAliasCZJ,"Valor",'',25,/*lPixel*/,/*{|| code-block de impressao }*/)

	For i := 1 to Len(aPeriodos)
		cCampo := "PER"+StrZero(i,3)
		TRCell():New(oSection3,cCampo,cAliasCZJ,DtoC(aPeriodos[i]),"999999999999.99",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
		oSection3:Cell(cCampo):SetLineBreak() // Define quebra de linha caso as colunas nao couberem na pagina
	Next i

	If lVNecesEst //-- Lista Neces. da Estrutura
		//oSection4
		oSection4 := TRSection():New(oSection2,cTitle,{cAliasCZJ,"SB1","CZI"},/*Ordem*/) //"MRP"
		
		TRCell():New(oSection4,'ORIGCZI','',"Origem",'',15,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oSection4,'COMPCZI','',"Componente",'',15,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oSection4,'CZI_DTOG','CZI',"Periodo",'',25,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oSection4,'PERIODO','CZI','Demanda',"999999999999.99",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oSection4,'CZI_DOC','CZI',"Produto de Origem",'',25,/*lPixel*/,/*{|| code-block de impressao }*/)
	EndIf

	If lLogMRP //-- Lista Log do MRP
		//oSection5 (Log do MRP)
		oSection5 := TRSection():New(oSection3,cTitle,{cAliasCZJ,"SHG"},/*Ordem*/) //"MRP"
		oSection5:SetHeaderPage(.F.)
		oSection5:SetHeaderSection(.F.)

		TRCell():New(oSection5,'HG_LOGMRP','SHG',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
		oSection5:Cell('HG_LOGMRP'):SetLineBreak() // Define quebra de linha caso as colunas nao couberem na pagina
	EndIf

	//Definindo a Quebra
	oBreak := TRBreak():New(oSection2,oSection2:Cell("PRODUTO"),NIL,.F.)

	If lContinua
		dbSelectArea(cAliasCZJ)
		//Condicao de Filtragem do CZJ                                 ?
		Set Filter to PRODUTO >= MV_PAR02 .And. PRODUTO <= MV_PAR03
		dbGotop()

		//Transforma parametros Range em expressao ADVPL
		MakeAdvplExpr(oReport:GetParam())

		//Posicionamento da tabela SB1
		TRPosition():New(oSection1,"SB1",1,{||xFilial("SB1")+(cAliasCZJ)->PRODUTO})

		//Inibindo Celula
		oSection2:Cell("PRODUTO"):Hide()
		oSection2:Cell("PRODUTO"):HideHeader()

		//Inicio da impressao do fluxo do relatorio
		oReport:SetMeter((cAliasCZJ)->(LastRec()) )
		oSection1:Init()
		oSection1:SetHeaderPage(.F.)
		oSection1:lHeaderVisible := .F.
		oSection2:SetLinesBefore(0)
		oSection2:Init()
		oSection3:Init()
		oSection1:SetHeaderPage(.F.)
		oSection1:SetHeaderSection(.F.)
		cFilUsrSB1:=oSection1:GetAdvplExp()
		oReport:lEmptyLineExcel:=.T.
		//oLayout:= Tlayout1():New()    
		//oLayout:setID("sExt")
		//oLayout:setName("EXT")
		//oLayout:setFontName("Courier New")
		//oLayout:setSize("8")
		//oReport:LoadLayout(oLayout:XlsNewStyle())
		oReport:XlsNewStyle("sCZI","NEC",3,{'Courier New"  ss:Color="#FF0000',8},,.f.,"C")
		oReport:XlsNewStyle("sDef","DEF",3,{'Courier New' ,8},,.f.,"C")
		oReport:XlsNewStyle("sCAB","CAB",2,{'ARIAL BLACK"  ss:Color="#4472C4',8},,.f.,"C")
		oReport:CXLSSHSTYLE:="sCAB"
		While !oReport:Cancel() .And. !(cAliasCZJ)->(Eof())
			SB1->(MsSeek(xFilial("SB1")+(cAliasCZJ)->PRODUTO))
			cDesc:=iif(LEN(alltrim(SB1->B1_XDESCNF))==0,SB1->B1_B1_XDESCNF,SB1->B1_DESC)
			cOrig:=iif(alltrim(SB1->B1_ORIGAMA)=='01','IMP','NAC')
			cUnd :=SB1->B1_UM
			cTipo:=SB1->B1_TIPO
			cCodAri := SB1->B1_XCODARI
			cCusto := U_UR882Custo((cAliasCZJ)->PRODUTO)
			If !Empty(cFilUsrSB1)
				If !(&("SB1->"+cFilUsrSB1))
					(cAliasCZJ)->(dbSkip())
					Loop
				EndIf
			EndIf

			lLista := R882FILTRO(nParRel,nTipo,cAliasCZJ) //-- Filtro conforme MV_PAR01

			If lLista
				//oSection1:PrintLine() //-- Impressao da secao 1
				//oReport:SkipLine()
				cFil	  := xFilial("CZI")
				cProdAnt := (cAliasCZJ)->PRODUTO
				cOpcAnt  := (cAliasCZJ)->OPCIONAL
				cSeekLog := xFilial("CZI")+CZI->CZI_NRMRP+(cAliasCZJ)->PRODUTO
				nPerIni  := 1
				While (cAliasCZJ)->PRODUTO == cProdAnt .And. (cAliasCZJ)->OPCIONAL == cOpcAnt
					If lQuebraPer
						For i := 1 to 6
							For j := 1 to 6
								If j > Len(aPeriodos)
									Exit
								EndIf
							
								nQtdPer := UR882ValField(j,cAliasCZJ)
								cCampo  := "PER"+StrZero(j,3)+StrZero(i,2)
								
								oSection2:Cell(cCampo):SetValue( nQtdPer )
							Next
							oReport:IncMeter()
							oSection2:PrintLine() //-- Impressao da secao 2
							nRec := Recno()
							(cAliasCZJ)->(dbSkip())
						Next
					Else
						For i := 1 to 6

							For  j := 1 to Len(aPeriodos)
								oReport:IncMeter()
								cCampo  := "PER"+StrZero(j,3)+StrZero(i,2)
								nQtdPer :=  (cAliasCZJ)->(FieldGet(FieldPos("PER"+StrZero(j,3))))
							    
								oSection2:Cell(cCampo):SetValue( nQtdPer )
								if i==6 .and. nQtdPer>0
								    OSection2:Cell(cCampo):cXlsStyle:="sCZI"
								    OSection2:Cell(cCampo):nClrBack:=255
								else
								    OSection2:Cell(cCampo):cXlsStyle:="sDef"    
								endif
							Next
							nRec:=(cAliasCZJ)->(recno())
							(cAliasCZJ)->(dbSkip())
						Next
						oSection2:Cell("B1_ORIGAMA"):SetValue(cOrig)
						oSection2:Cell("TEXTO"):SetValue(cProdAnt)
						oSection2:Cell("B1_DESC"):SetValue(cDesc)
						oSection2:Cell("B1_UM"):SetValue(cUnd)
						oSection2:Cell("B1_TIPO"):SetValue(cTipo)
						oSection2:Cell("CUSTO"):SetValue(cCusto)
						oSection2:PrintLine() //-- Impressao da secao 2
					EndIf
				EndDo

				//Definindo o Valor da Necessidade
				nTotValor := 0
				//oSection3:Cell('TEXTO'):SetValue("Valor")
				/*
				For i:= 1 To Len(aPeriodos)
				nCusto	:= U_UR882Custo((cAliasCZJ)->PRODUTO)
				dbSelectArea(cAliasCZJ)
				nQtdPer := U_UR882ValField(i,cAliasCZJ)
				cCampo  := "PER"+StrZero(i,3)
				oSection3:Cell(cCampo):SetValue(nQtdPer * nCusto)
				//nTotValor += oSection3:Cell(cCampo):GetValue()
				Next i

				oSection3:PrintLine() //-- Impressao da secao 3
				*/
				

				//Lista a necessidade da estrutura do produto possicionado a partir da tabela CZI com CZI_ALIAS igual a "CZJ".                               ?
				If lVNecesEst
				    oSection4:Cell('ORIGCZI'):HideHeader()
		            oSection4:Cell('COMPCZI'):HideHeader()
		            oSection4:ACELL[1]:OHBRDBOTTOM:NLINESTYLE:=0    //borda do cabecalho 0=sem borda
		            oSection4:ACELL[2]:OHBRDBOTTOM:NLINESTYLE:=0
		            oSection4:Cell(3):nAlign:=2	
					oSection4:Init()
					oSection4:SetLinesBefore(0)
					CZI->(dbSetOrder(3))
					If (lAchou:=CZI->(dbSeek(xFilial("CZI")+cProdAnt+"CZJ")))
						oReport:SkipLine()
						oReport:PrintText("Necessidade da estrutura/Plano Mestre")
					EndIf

					nH5_Quant:=0

					While CZI->(!Eof() .AND. CZI->(CZI_PROD+CZI_ALIAS) == cProdAnt+"CZJ")

						oSection4:Cell('ORIGCZI'):SetValue(cOrig)
						oSection4:Cell('COMPCZI'):SetValue(cProdAnt)

						lExit := .F.
						if CZI->CZI_DTOG <= aPeriodos[Len(aPeriodos)]
							For i:= 1 To Len(aPeriodos)
								nH5_Quant:=0
								While CZI->(!Eof() .AND. CZI->(CZI_PROD+CZI_ALIAS) == cProdAnt+"CZJ") .AND.  CZI->CZI_DTOG <= aPeriodos[i]
									nH5_Quant += CZI->CZI_QUANT
									CZI->(dbSkip())
								Enddo
								if nH5_Quant>0
									cProd:=OndeUsa(cProdAnt,"",STRZERO(i,3))
									cProd:=IIF(RIGHT(cProd,1)=='/',SUBSTR(cProd,1,LEN(cProd)-1),cProd)
									oSection4:Cell('CZI_DOC'):SetValue(cProd)
									oSection4:Cell('CZI_DTOG'):SetValue(dtoc(aPeriodos[i]))
									oSection4:Cell('PERIODO'):SetValue(nH5_Quant)
									oSection4:PrintLine() //-- Impressao da secao 4
								endif
							Next i

						else
							exit
						endif

					EndDo
					if  lAchou
					 oSection4:Finish()
					 oReport:SkipLine()
					endif 
				EndIf
				//oReport:SkipLine()
				//Imprime o Vlr. Total do Produto
				//oReport:PrintText("Vlr. Total do Produto          "+Str(nTotValor,aTam[1],aTam[2]))
	            dbSelectArea(cAliasCZJ)
  			    //Lista os eventos de log desse produto
				If lLogMrp
					oSection5:Init()
					dbSelectArea("SHG")
					If dbSeek(xFilial("SHG")+cSeekLog)
						oReport:PrintText("Eventos relacionados ao produto") //"Eventos relacionados ao produto"
						While !EOF() .AND. xFilial("SHG")+cSeekLog == HG_FILIAL+HG_SEQMRP+HG_COD
							oSection5:PrintLine() //-- Impressao da secao 5
							SHG->(dbSkip())
						EndDo
					EndIf
					oSection5:Finish()
					oReport:SkipLine()
				EndIf
				oReport:ThinLine()
			Else
				(cAliasCZJ)->(dbSkip(6))
			EndIf
		
		EndDo
		oSection3:Finish()
		oSection2:Finish()
		oSection1:Finish()

	EndIf
	If (lContinua = .T.) .And. (lUsed != .T.)
		dbSelectArea(cAliasCZJ)
		dbCloseArea()
		dbSelectArea("CZI")
		dbCloseArea()
	ElseIf lContinua
		(cAliasCZJ)->(dbClearFilter())
		CZI->(dbClearFilter())
	EndIF

	dbSelectArea("SB1")
	dbClearFilter()
	dbSetOrder(1)

Return Nil

/*------------------------------------------------------------------------//
//Programa:	MATR882R3
//Autor:		Rodrigo de A Sartorio
//Data:		02/09/02
//Descricao:	MRP
//Uso: 		MATR882
//------------------------------------------------------------------------*/

/*------------------------------------------------------------------------//
//Programa:	R882Imp
//Autor:		Rodrigo de A Sartorio
//Data:		02/09/02
//Descricao:	Chamada do Relat?rio
//Uso: 		MATR882
//------------------------------------------------------------------------*/
Static Function R882Imp(lEnd,wnRel,titulo,tamanho,lUsed,nParRel,cProdIni,cProdFim,lLogMrp,lVNecesEst)
	Local i			:= 0
	Local j			:= 0
	Local nTotLin		:= 0
	Local nTotProd  	:= 0
	Local nTipo     	:= 0
	Local nNecEstr  	:= 0
	Local nCusto    	:= 0
	Local nQtdPer   	:= 0
	Local nC        	:= 0

	Local nomeprog  	:= "MATR882"
	Local CbTxt		:= ""
	Local CbCont		:= ""
	Local cSeekLog	:= ""
	Local cNecEstrAtu	:= ""
	Local cAliasCZJ 	:= ""
	Local cCondSH5  	:= "CZI_PROD != '"+Criavar("B1_COD",.F.)+"'"

	Local aPerOri   	:= {}
	Local aNeces    	:= {}
	Local aListaNec 	:= {}
	Local aOrdem    	:= Array(6)

	Local lLista		:= .F.
	Local lImprimiu	:= .F.
	Local lContinua 	:= .T.

	Private aPerQuebra := {}
	Private aPeriodos := {}

	aOrdem[1] := "STR0005"
	aOrdem[2] := "STR0006"
	aOrdem[3] := "STR0007"
	aOrdem[4] := "STR0017"
	aOrdem[5] := "STR0008"
	aOrdem[6] := "STR0009"

	//Variaveis utilizadas para Impressao do Cabecalho e Rodape
	cbtxt    := SPACE(10)
	cbcont   := 0
	li       := 80
	m_pag    := 1

	//Monta os Cabecalhos
	If lUsed != .T.
		lContinua := MATA712LCK()
	EndIf

	If lContinua
		dbSelectArea("CZI")
		If !Empty(dbFilter())
			dbClearFilter()
		EndIf

		dbSetOrder(1)
		dbGotop()

		dbSelectArea("SHG")
		dbSetOrder(1)

		aPeriodos := R882PER(@nTipo)
		cAliasCZJ := MATA712MVW()

		If lQuebraPer
			aPerOri    := aClone(aPeriodos)
			aPerQuebra := U_UR882DivPeriodo(aPeriodos, .T.)
			aPeriodos  := U_UR882DivPeriodo(aPeriodos)
		EndIf

		dbSelectArea("CZI")
		Set Filter to &cCondSH5
	EndIf

	If lContinua
		dbSelectArea(cAliasCZJ)
		dbGotop()
		SetRegua(LastRec())
		Titulo  := Titulo+" -  "+CZI->CZI_NRMRP
		NTotLin := Len(aPeriodos) / 5
		nTotLin := If(Len(aPeriodos) % 6 > 0,++nTotLin,nTotLin)
		While !Eof()
			If lEnd
				@ Prow()+1,001 PSay ""	//"CANCELADO PELO OPERADOR"
				Exit
			EndIf
			IncRegua()
			nRec := Recno()
			cSeekLog  := xFilial("CZI")+CZI->CZI_NRMRP+(cAliasCZJ)->PRODUTO
			lImprimiu := .F.

			If (cAliasCZJ)->PRODUTO >= cProdIni .And. (cAliasCZJ)->PRODUTO <= cProdFim .And. SB1->(dbSeek(xFilial("SB1")+(cAliasCZJ)->PRODUTO))
				If li > 50
					cabec(titulo,"","",nomeprog,tamanho,18)
					@ li,00 PSay __PrtFatLine()
					li++
				EndIf
				lLista		:= R882FILTRO(nParRel,nTipo,cAliasCZJ)
				lImprimiu	:= .f.
				If lLista
					nTotProd	:= 0
					lImprimiu	:= .t.
					nCusto		:= U_UR882Custo(SB1->B1_COD)
					@ li,00 PSay SB1->B1_COD +SPACE(3) + Substr(SB1->B1_DESC,1,30) + SPACE(3) +"PRODUTO: UM:";	//"PRODUTO: "###"UM:"
					+ SB1->B1_UM + SPACE(3)+"L.E" + Str(RetFldProd(SB1->B1_COD,"B1_LE"), Posicione("SX3", 2, "B1_LE", "X3_TAMANHO"), Posicione("SX3", 2, "B1_LE", "X3_DECIMAL")) + SPACE(3) + Upper(AllTrim(RetTitle("B1_ESTSEG"))) + ": " + Str(RetFldProd(SB1->B1_COD,"B1_ESTSEG"), Posicione("SX3", 2, "B1_ESTSEG", "X3_TAMANHO"), Posicione("SX3", 2, "B1_ESTSEG", "X3_DECIMAL")) + SPACE(3) + Upper(AllTrim(RetTitle("B1_EMIN"))) + ": " + Str(RetFldProd(SB1->B1_COD,"B1_EMIN"), Posicione("SX3", 2, "B1_EMIN", "X3_TAMANHO"), Posicione("SX3", 2, "B1_EMIN", "X3_DECIMAL")) + Space(3) + "LOTE ECON: TIPO:"+ SB1->B1_TIPO	//"LOTE ECON: "### "TIPO: "
					li++
					dbSelectArea(cAliasCZJ)
					nPerIni := 1
					While .t.
						dbGoto(nRec)
						nCol := 23
						li++
						// ---- Imprime Periodos
						@ li,00 PSay "Periodos"
						If lQuebraPer .And. nNumPer > 1
							@ li,10 PSay "(inicial)"
						EndIf
						For i:= nPerIni to nPerIni+5
							If i > Len(aPeriodos)
								Exit
							EndIf
							@ li,nCol PSay DtoC(aPeriodos[i])
							nCol += 15
						Next i
						// ---- Se Aglutina em mais de 1 periodo, Imprime data final do periodo
						If lQuebraPer .And. nNumPer > 1
							nCol := 23
							li++
							@ li,10 PSay "(final)"
							For i:= nPerIni to nPerIni+5
								If i > Len(aPeriodos)
									Exit
								EndIf
								// ---- Calcula posicao no array de periodos
								// ---- = (coluna-1)*nro.periodos p/ aglutinar+len(array periodos aglutinados)
								nC := (i-1)*nNumPer+Len(aPerQuebra[i,2])
								@ li,nCol PSay DtoC(aPerOri[nC])
								nCol += 15
							Next i
						EndIf
						// ----
						li += 2
						aNeces := {}
						For i := 1 to 6
							nCol := 16
							@ li,00 PSay aOrdem[i]
							For j := nPerIni to nPerIni+5
								If j > Len(aPeriodos)
									Exit
								EndIf

								@ li,nCol PSay nQtdPer := U_UR882ValField(j,cAliasCZJ) Picture "999999999999.99"
								nCol+=15
								If i == 6
									aAdd(aNeces, nQtdPer)
									nTotProd+=nQtdPer
								EndIf
							Next
							(cAliasCZJ)->(dbSkip())
							li++
						Next

						nCol := 16
						@ li,00 PSay "Valor"
						For j := 1 to Len(aNeces)
							@ li,nCol PSay aNeces[j] * nCusto Picture "999999999999.99"
							nCol+=15
						Next

						//Lista a necessidade da estrutura do produto possicionado a partir da tabela CZI com CZI_ALIAS igual a CZJ.                               ?
						//???????????????????????????????????????????????????????????????????????????
						If lVNecesEst
							//Reposiciono no produto
							DbSelectArea(cAliasCZJ)
							DbGoto(nRec)
							aListaNec := R882LstNec(xFilial("CZI")+(cAliasCZJ)->PRODUTO+"CZJ",aPeriodos,nPerIni)
							If !Empty(aListaNec)
								li+=2
								@ li,00 PSay "Nec. Estrut."
								cNecEstrAtu := ""
								For i:=1 To Len(aListaNec)
									If cNecEstrAtu<>aListaNec[i,1] .Or. !lQuebraPer
										cNecEstrAtu := aListaNec[i,1]
										li++
									EndIf
									@ li,000 PSay aListaNec[i,1]
									nCol := 16
									For j := nPerIni to nPerIni+5
										If j > Len(aPeriodos)
											Exit
										EndIf
										nNecEstr := 0
										If aPeriodos[j]==aListaNec[i,3]
											nNecEstr := aListaNec[i,2]
										EndIf
										@ li,nCol PSay nNecEstr Picture "999999999999.99"
										nCol+=15
									Next

									If li > 60
										cabec(titulo,"","",nomeprog,tamanho,18)
										@ li,00 PSay __PrtFatLine()
										li++
									EndIf
								Next
								li++
							EndIf
						EndIf
						nPerIni+=6
						If nPerIni > Len(aPeriodos)
							Exit
						EndIf
						If li > 50
							cabec(titulo,"","",nomeprog,tamanho,18)
							@ li,00 PSay __PrtFatLine()
							li++
						EndIf
						li++
					Enddo
					li+= 2

					nCol := 16
					@ li,00 PSay "Tot Vl. Produto:"
					@ li,nCol PSay nTotProd * nCusto Picture "999999999999.99"

					li+= 2
					nTotProd := 0
				EndIf

				// Lista os eventos de log desse produto
				If lLogMrp
					dbSelectArea("SHG")
					If dbSeek(xFilial("SHG")+cSeekLog)
						If li > 50
							cabec(titulo,"","",nomeprog,tamanho,18)
						EndIf
						@ li,00 PSay  "Eventos relacionados ao produto"
						li++
						li++
						While !EOF() .AND. xFilial("SHG")+cSeekLog == HG_FILIAL+HG_SEQMRP+HG_COD
							If li > 50
								cabec(titulo,"","",nomeprog,tamanho,18)
							EndIf
							@ li,00 PSay HG_LOGMRP
							li++
							dbSkip()
						End
						li++
					EndIf
				EndIf
				dbSelectArea(cAliasCZJ)
			EndIf
			DbGoto(nRec)
			DbSkip(6)
			If lImprimiu
				@ li,00 PSay __PrtThinLine()
				li++
			EndIf
		End

		If li != 80
			roda(cbcont,cbtxt)
		EndIf

	EndIf
	If (lContinua = .T.) .And. (lUsed != .T.)
		dbSelectArea(cAliasCZJ)
		dbCloseArea()
		dbSelectArea("CZI")
		dbCloseArea()
	EndIf
	dbSelectArea("SB1")
	dbClearFilter()
	dbSetOrder(1)
	If aReturn[5] = 1
		Set Printer TO
		Commit
		ourspool(wnrel)
	EndIf
	MS_FLUSH()
Return NIL

/*------------------------------------------------------------------------//
//Programa:	R882Per
//Autor:		Rodrigo de A Sartorio
//Data:		03/02/97
//Descricao:	Rotina de montagem de array aperiodos para Impressao
//Uso: 		MATR882
//------------------------------------------------------------------------*/
Static Function R882PER(nTipo)
	Local i
	Local dInicio
	Local aRet := {}
	Local nPosAno
	Local nTamAno
	Local cForAno
	Local lConsSabDom := Nil

	Pergunte("MTA712",.F.)
	lConsSabDom := mv_par12 == 1
	Pergunte(cPerg, .F.)

	If __SetCentury()
		nPosAno := 1
		nTamAno := 4
		cForAno := "ddmmyyyy"
	Else
		nPosAno := 3
		nTamAno := 2
		cForAno := "ddmmyy"
	EndIf

	//Adiciona registro em array totalizador utilizado no TREE
	dbSelectArea("CZI")
	dbSetOrder(1)
	dbGotop()
	While !Eof()
		// Recupera parametrizacao gravada no ultimo processamento
		// A T E N C A O
		// Quando utilizado o processamento por periodos variaveis o sistema monta o array com
		// os periodos de maneira desordenada, por causa do indice do arquivo SH5
		// O array aRet ? corrigido logo abaixo
		If CZI_ALIAS == "PAR"
			nTipo       := CZI_NRRGAL
			dInicio     := CZI_DTOG
			nPeriodos   := CZI_QUANT
			If nTipo == 7
				AADD(aRet,DTOS(CTOD(Alltrim(CZI_OPC))))
			EndIf
			//NUMERO DO MRP                                                ?
			c711NumMRP := CZI_NRMRP
		EndIf
		dbSkip()
	End

	//Somente para nTipo==7 (Periodos Diversos) re-ordena aRet
	//pois como o H5_OPC esta gravado a data como caracter ex:(09/10/05)
	//o arquivo esta indexado incorretamente (diferente de 20051009)
	If !Empty(aRet)
		ASort(aRet)
		For i:=1 To Len(aRet)
			aRet[i] := STOD(aRet[i])
		Next i
	EndIf

	If (nTipo == 2)                         // Semanal
		While Dow(dInicio)!=2
			dInicio--
		EndDo
	ElseIf (nTipo == 3) .or. (nTipo=4)      // Quinzenal ou Mensal
		dInicio:= CtoD("01/"+Substr(DtoS(dInicio),5,2)+Substr(DtoC(dInicio),6),cForAno)
	ElseIf (nTipo == 5)                     // Trimestral
		If Month(dInicio) < 4
			dInicio := CtoD("01/01/"+Substr(DtoC(dInicio),7),cForAno)
		ElseIf (Month(dInicio) >= 4) .and. (Month(dInicio) < 7)
			dInicio := CtoD("01/04/"+Substr(DtoC(dInicio),7),cForAno)
		ElseIf (Month(dInicio) >= 7) .and. (Month(dInicio) < 10)
			dInicio := CtoD("01/07/"+Substr(DtoC(dInicio),7),cForAno)
		ElseIf (Month(dInicio) >=10)
			dInicio := CtoD("01/10/"+Substr(DtoC(dInicio),7),cForAno)
		EndIf
	ElseIf (nTipo == 6)                     // Semestral
		If Month(dInicio) <= 6
			dInicio := CtoD("01/01/"+Substr(DtoC(dInicio),7),cForAno)
		Else
			dInicio := CtoD("01/07/"+Substr(DtoC(dInicio),7),cForAno)
		EndIf
	EndIf

	If nTipo != 7
		For i := 1 to nPeriodos
			AADD(aRet,dInicio)
			If nTipo == 1
				dInicio ++
				While !lConsSabDom .And. ( DOW(dInicio) == 1 .or. DOW(dInicio) == 7 )
					dInicio++
				EndDo
			ElseIf nTipo == 2
				dInicio+=7
			ElseIf nTipo == 3
				dInicio := StoD(If(Substr(DtoS(dInicio),7,2)<"15",Substr(DtoS(dInicio),1,6)+"15",;
				If(Month(dInicio)+1<=12,Str(Year(dInicio),4)+StrZero(Month(dInicio)+1,2)+"01",;
				Str(Year(dInicio)+1,4)+"0101")),cForAno)
			ElseIf nTipo == 4
				dInicio := CtoD("01/"+If(Month(dInicio)+1<=12,StrZero(Month(dInicio)+1,2)+;
				"/"+Substr(Str(Year(dInicio),4),nPosAno,nTamAno),"01/"+Substr(Str(Year(dInicio)+1,4),nPosAno,nTamAno)),cForAno)
			ElseIf nTipo == 5
				dInicio := CtoD("01/"+If(Month(dInicio)+3<=12,StrZero(Month(dInicio)+3,2)+;
				"/"+Substr(Str(Year(dInicio),4),nPosAno,nTamAno),"01/"+Substr(Str(Year(dInicio)+1,4),nPosAno,nTamAno)),cForAno)
			ElseIf nTipo == 6
				dInicio := CtoD("01/"+If(Month(dInicio)+6<=12,StrZero(Month(dInicio)+6,2)+;
				"/"+Substr(Str(Year(dInicio),4),nPosAno,nTamAno),"01/"+Substr(Str(Year(dInicio)+1,4),nPosAno,nTamAno)),cForAno)
			EndIf
		Next i
	EndIf

Return aRet

/*------------------------------------------------------------------------//
//Programa:	R882FILTRO
//Autor:		Rodrigo de A Sartorio
//Data:		03/02/97
//Descricao:	Filtra per?odo
//Uso: 		MATR882
//------------------------------------------------------------------------*/
Static Function R882FILTRO(nParRel,nTipo,cAliasCZJ)
	Local ni		:= 0
	Local lRet 	:= .F.
	Local cAlias 	:= Alias()
	Local nReg		:=0

	dbSelectArea(cAliasCZJ)
	nReg := Recno()

	If nParRel == 1
		lRet := .T.
	ElseIf nParRel == 2
		dbSkip(2)
		For ni := 1 to nPeriodos
			cCampo := "PER"+StrZero(ni,3)
			If &(cCampo) != 0
				lRet := .t.
				Exit
			EndIf
		Next
		If !lRet
			dbSkip()
			For ni := 1 to nPeriodos
				cCampo := "PER"+StrZero(ni,3)
				If &(cCampo) != 0
					lRet := .t.
					Exit
				EndIf
			Next
		EndIf
	ElseIf nParRel == 3
		dbSkip(5)
		For ni := 1 to nPeriodos
			cCampo := "PER"+StrZero(ni,3)
			If &(cCampo) != 0
				lRet := .t.
				Exit
			EndIf
		Next
	EndIf

	dbGoto(nReg)
	dbSelectArea(cAlias)

Return (lRet)

/*------------------------------------------------------------------------//
//Programa:	R882Custo
//Autor:		Marcelo Iuspa
//Data:		05/01/05
//Descricao:	Retorna o custo do produto informado baseado na opcao do pergunte (mv_par05):
//				Custo Produto: 1-Custo Standard;2-Custo Medio;3-Preco Compra
//Uso: 		MATR882
//------------------------------------------------------------------------*/
User Function UR882Custo(cProd)
	Local nCusto := 0

	SB1->(MsSeek(xFilial("SB1") + cProd))
	If nTipoCusto == 1
		nCusto := RetFldProd(SB1->B1_COD,"B1_CUSTD")
		cStr:="1"
	ElseIf nTipoCusto == 2
		nCusto := PegaCmAtu(cProd, RetFldProd(SB1->B1_COD,"B1_LOCPAD"))[1]
		cStr:="2"
	ElseIf nTipoCusto == 3
		nCusto := RetFldProd(SB1->B1_COD,"B1_UPRC")
		cStr:="3"
	EndIf

Return(nCusto)

/*------------------------------------------------------------------------//
//Programa:	R882DivPeriodo
//Autor:		Marcelo Iuspa
//Data:		18/01/05
//Descricao:	Retorna o array de periodos aglutinados conforme parametro
//Uso: 		MATR882
//------------------------------------------------------------------------*/
User Function UR882DivPeriodo(aPeriodos, lRetQuebra)
	Local nLenArr := Len(aPeriodos)
	Local nLoop   := Nil
	Local nAglut  := 1
	Local aRetPer := {aPeriodos[1]}
	Local aQuebra := {{1, {1}}}

	Default lRetQuebra := .F.

	For nLoop := 2 to nLenArr
		If nAglut >= nNumPer
			Aadd(aRetPer, aPeriodos[nLoop])
			Aadd(aQuebra, {Len(aQuebra)+1, {}})
			nAglut := 1
		Else
			nAglut ++
		EndIf
		Aadd(aQuebra[Len(aQuebra), 2], nLoop)
	Next

Return(If(lRetQuebra, aQuebra, aRetPer))

/*------------------------------------------------------------------------//
//Programa:	R882ValField
//Autor:		Marcelo Iuspa
//Data:		18/01/05
//Descricao:	Retorna o array de periodos aglutinados conforme parametro
//Uso: 		MATR882
//------------------------------------------------------------------------*/
User Function UR882ValField(nPeriodo,cAliasCZJ)
	Local nRet  := 0
	Local nLoop := 0
	Local aPer  := Nil

	If ! lQuebraPer
		nRet := (cAliasCZJ)->(FieldGet(FieldPos("PER" + StrZero(nPeriodo, 3))))
	Else
		aPer := aPerQuebra[nPeriodo, 2]
		For nLoop := 1 to Len(aPer)
			nRet += (cAliasCZJ)->(FieldGet(FieldPos("PER" + StrZero(aPer[nLoop], 3))))
			If (cAliasCZJ)->TIPO == "1"
				Exit
			ElseIf (cAliasCZJ)->TIPO == "5"
				nRet := (cAliasCZJ)->(FieldGet(FieldPos("PER" + StrZero(aPer[nLoop], 3))))
			EndIf
		Next
	EndIf
Return(nRet)

/*------------------------------------------------------------------------//
//Programa:	R882LstNec
//Autor:		Erike Y. da Silva
//Data:		09/05/05
//Descricao:	Lista a estrutura da necessidade do produto
//Uso: 		MATR882
//------------------------------------------------------------------------*/
Static Function R882LstNec(cChave,aPeriodos,nPerIni)
	Local nPos			:= 0
	Local nI			:= 0
	Local nTamPer   	:= Len(aPeriodos)
	Local lContinua 	:= .F.
	Local aLista    	:= {}
	Local cAlias    	:= Alias()
	Local aAreaSH5  	:= CZI->(GetArea())

	DbSelectArea("CZI")
	CZI->(dbSetOrder(3))
	CZI->(dbSeek(cChave))

	While CZI->(!Eof() .AND. CZI_PROD+CZI_ALIAS==cChave)
		lContinua := .F.
		For nI:=nPerIni To nPerIni+5
			If nI> nTamPer
				Exit
			EndIf
			If aPeriodos[nI]==CZI->CZI_DTOG
				lContinua := .T.
				Exit
			EndIf
		Next

		If !lContinua
			CZI->(DbSkip())
			Loop
		EndIf

		nPos := AsCan(aLista,{|x|x[1]==CZI->CZI_DOC .and. x[3]==CZI->CZI_DTOG})
		If Empty(nPos) .Or. !lQuebraPer
			SB1->(MsSeek(xFilial("SB1") + CZI->CZI_DOC))
			Aadd(aLista,{CZI->CZI_DOC,CZI->CZI_QUANT,CZI->CZI_DTOG})
		Else
			aLista[nPos,2] += CZI->CZI_QUANT
		EndIf
		CZI->(DbSkip())
	EndDo

	If !Empty(aLista)
		aLista := aSort(aLista,,,{|x,y|x[1]<y[1]})
	EndIf

	RestArea(aAreaSH5)
	DbSelectArea(cAlias)

Return aClone(aLista)

Static Function OndeUsa(comp,pai,cper)

	Local aArea := GetArea()
	Local aAreaCZI := CZI->(GetArea())
	cRetorno:=pai
	if Posicione("SB1",1,XFILIAL("SB1")+comp,"B1_TIPO")=="PA"
		cRetorno:=cRetorno+comp+"/"
	endif
	DBSELECTAREA("SG1")
	DBSETORDER(2)
	DBSEEK(XFILIAL("SG1")+comp)
	do while !eof() .and. alltrim(SG1->G1_COMP)==alltrim(comp)
		cAliasTRB:= GetNextAlias()
		BeginSql Alias cAliasTRB
		SELECT ISNULL(B1_TIPO,'') B1_TIPO,B1_MSBLQL,B1_MRP
		FROM %Table:SB1% SB1
		WHERE B1_FILIAL  = %xFilial:SB1% AND
		B1_COD = %Exp:SG1->G1_COD% AND
		SB1.%NotDel%
		EndSql
		dbSelectArea(cAliasTRB)
		dbgotop()
		cTp:=(cAliasTRB)->B1_TIPO
		nBlq:=(cAliasTRB)->B1_MSBLQL
		cMrp:=(cAliasTRB)->B1_MRP
		(cAliasTRB)->(dbCloseArea())
		DBSELECTAREA("SG1")
		if SG1->G1_FIM>ddatabase .and. cTp=="PA"
			dbselectarea("CZI")
			CZI->(dbSetOrder(3))
			CZI->(dbSeek(xFilial("CZI")+SG1->G1_COD+"SHC"))
			ldemnd:=.F.
			do while  !eof() .and. alltrim(CZI->CZI_PROD)==alltrim(SG1->G1_COD)
				if  CZI->CZI_PERMRP=cper
					ldemnd:=.T.
					exit
				endif
				CZI->(dbskip())
			enddo
			if  ldemnd
				cRetorno:=cRetorno+ALLTRIM(SG1->G1_COD)+"/"
			endif
		endif
		if SG1->G1_FIM>ddatabase  .and. cTp$"PI/SA" .and. nBlq<>"1"
			OndeUsa(SG1->G1_COD,cRetorno)
		endif
		dbselectarea("SG1")
		SG1->(dbskip())
	enddo
	RestArea(aArea)
	RestArea(aAreaCZI)
Return(cRetorno)
