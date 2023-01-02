#INCLUDE "MATR275.CH"  
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MATR275	³ Autor ³ Nereu Humberto Junior ³ Data ³ 03/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Kardex p/ Lote Sobre o SDB                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MATR275U()

Local oReport

If FindFunction("TRepInUse") .And. TRepInUse()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport := ReportDef()
	oReport:PrintDialog()
Else
	U_MATR275R3U()
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³Nereu Humberto Junior  ³ Data ³03.08.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()

Local oReport 
Local oSection 
Local oCell         
Local cTamQtd := TamSX3('DB_QUANT')[1]
Local cTamDoc := TamSX3('DB_DOC')[1]
Local cPerg := "MTR276P9R1"
Local lQuery
#IFDEF TOP
	lQuery := .T.
#ELSE
	lQuery := .F.
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta perguntas no SX1 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AjustaSX1(.T.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta perguntas no SXB ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AjustaSXB()     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := TReport():New("MATR275",STR0003,cPerg, {|oReport| ReportPrint(oReport,cPerg)},STR0001+" "+STR0002) //"Kardex por Localizacao (por produto)"##//"Este programa emitir  um Kardex com todas as movimenta‡”es"##//"do estoque por Localizacao e Numero de Serie, diariamente."
oReport:SetLandscape()    

Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                        		³
//³ mv_par01         	// Produto ?	                        		³
//³ mv_par02        	// Lote ?		                        		³
//³ mv_par03        	// Sub-Lote ?                           		³
//³ mv_par04        	// Do  Armazem                          		³
//³ mv_par05        	// Ate Armazem                          		³
//³ mv_par06        	// De  Data                             		³
//³ mv_par07        	// Ate Data                             		³
//³ mv_par08        	// Endereco ?                    				³
//³ mv_par09        	// Numero de Serie ?	                		³
//³ mv_par10        	// Lista os Estornos ?                  		³
//³ mv_par11        	// Exibe Quantidades em qual UM?        		³
//³ mv_par12        	// Para Movimentacoes de CQ?       				³
//³ mv_par13        	// Seleciona Filiais ? (Sim/Nao)				³
//³ mv_par14        	// Lista Produtos sem movimento ?(1=Sim/2=Nao)	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection := TRSection():New(oReport,STR0016,{"SDB","SB1","SD7"}) // "Movimentos por Endereco"
oSection :SetHeaderPage()
oSection:SetNoFilter("SB1")
oSection:SetNoFilter("SD7")

TRCell():New(oSection,"DB_PRODUTO"	,"SDB",/*Titulo*/	,/*Picture*/					,/*Tamanho*/,/*lPixel*/,If(lQuery,Nil,{|| TRB->DB_PRODUTO }))
If TamSX3('DB_PRODUTO')[1]<= 15
	TRCell():New(oSection,"B1_DESC"		,"SB1",/*Titulo*/	,/*Picture*/					,30			,/*lPixel*/,/*{|| code-block de impressao }*/)
EndIf
TRCell():New(oSection,"DB_LOCAL"	,"SDB",/*Titulo*/	,/*Picture*/					,/*Tamanho*/,/*lPixel*/,If(lQuery,Nil,{|| TRB->DB_LOCAL }))
TRCell():New(oSection,"DB_LOCALIZ"	,"SDB",/*Titulo*/	,/*Picture*/					,/*Tamanho*/,/*lPixel*/,If(lQuery,Nil,{|| TRB->DB_LOCALIZ }))
TRCell():New(oSection,"DB_NUMSERI"	,"SDB",/*Titulo*/	,/*Picture*/					,/*Tamanho*/,/*lPixel*/,If(lQuery,Nil,{|| TRB->DB_NUMSERI }))
TRCell():New(oSection,"DB_LOTECTL"	,"SDB",/*Titulo*/	,/*Picture*/					,/*Tamanho*/,/*lPixel*/,If(lQuery,Nil,{|| TRB->DB_LOTECTL }))
TRCell():New(oSection,"DB_NUMLOTE"	,"SDB",/*Titulo*/	,/*Picture*/					,/*Tamanho*/,/*lPixel*/,If(lQuery,Nil,{|| TRB->DB_NUMLOTE }))
TRCell():New(oSection,"DB_DATA"		,"SDB",/*Titulo*/	,/*Picture*/					,/*Tamanho*/,/*lPixel*/,If(lQuery,Nil,{|| TRB->DB_DATA }))
TRCell():New(oSection,"cDoc"		,"   ",STR0009		,"@!"							,cTamDoc	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection,"cSerie"		,"   ",STR0010		,"@!"							,3			,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection,"DB_ESTORNO"	,"SDB",STR0011		,/*Picture*/					,/*Tamanho*/,/*lPixel*/,If(lQuery,Nil,{|| TRB->DB_ESTORNO }))
TRCell():New(oSection,"nSaldoIni"	,"   ",STR0012		,PesqPict("SDB","DB_QUANT",14)	,cTamQtd	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection,"nEntrada"	,"   ",STR0013		,PesqPict("SDB","DB_QUANT",14)	,cTamQtd	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection,"nSaida"		,"   ",STR0014		,PesqPict("SDB","DB_QUANT",14)	,cTamQtd	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection,"nSaldo"		,"   ",STR0015		,PesqPict("SDB","DB_QUANT",14)	,cTamQtd	,/*lPixel*/,/*{|| code-block de impressao }*/)

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrin³ Autor ³Nereu Humberto Junior  ³ Data ³03.08.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport,cPerg)

Local oSection  := oReport:Section(1)
Local aStrucSDB := SDB->(dbStruct())
Local cAliasSDB := GetNextAlias()
Local cAliasSB1 := "SB1"
Local nSaldoIni :=nEntrada:=nSaida:=0
Local cProd		:= ""
Local cLocal, cLocaliz, cLoteCtl, cNumLote, cNumSerie, lFirst, cCodSBK
Local nUM       := mv_par11
Local lImpCQOrig:= (mv_par12==2)
Local cDocSDB   := ''
Local cSerieSDB := ''
Local lIntDL	:= GetMV('MV_INTDL') == 'S'
Local lMovtoProd:= .F.

#IFNDEF TOP
	Local cCondicao := ""
	Local cCond2	:= ""
	Local cIndex1	:= ""
	Local cIndex2	:= ""
	Local cNomArq1	:= ""
	Local cNomArq2	:= ""
	Local cPar08SBE := ""
	Local cPar01SB1 := ""
	Local nIndDB
#ELSE
	Local cFilUsrSDB:= ""
    Local cName		:= ""
	Local cSelect	:= "%%"
	Local cOn    := "%%"
	Local cWhere := "%%"
    Local nQryAd	:= 0
    Local nX		:= 0
#ENDIF

Local aFilsCalc := {}
Local nForFilial:= 0
Local cFilBack  := cFilAnt

aFilsCalc:= MatFilCalc( mv_par13 == 1 ) 

If Empty(aFilsCalc)
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Converte os parametros do tipo range, para um range cheio,  ³
//³caso o conteudo do parametro esteja vazio                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FullRange(cPerg)

oReport:NoUserFilter()  // Desabilita a aplicacao do filtro do usuario no filtro/query das secoes

For nForFilial := 1 To Len( aFilsCalc )

	If aFilsCalc[ nForFilial, 1 ]
	
		cFilAnt := aFilsCalc[ nForFilial, 2 ]
		
		oReport:EndPage() //Reinicia Paginas

		oReport:SetTitle( STR0003 + " - " + aFilsCalc[ nForFilial, 3 ] )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Filtragem do relatório                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   	cFilUsrSDB:= oSection:GetAdvplExp()

		#IFDEF TOP              
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Transforma parametros Range em expressao SQL                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MakeSqlExpr(cPerg)					

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Esta rotina foi escrita para adicionar no select os campos         ³
			//³usados no filtro do usuario, quando houver.                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SDB")
		    If !Empty(cFilUsrSDB) .And. nQryAd == 0
				cSelect := "%"   
				For nX := 1 To SDB->(FCount())
					cName := SDB->(FieldName(nX))
				 	If AllTrim( cName ) $ cFilUsrSDB
			      		If aStrucSDB[nX,2] <> "M"  
			      			If !cName $ cSelect 
				        		cSelect += ","+cName
				        		nQryAd ++
				          	Endif 	
				       	EndIf
					EndIf 			       	
				Next nX 
				cSelect += "%"
		    Endif    

			cOn :="%"
			If !Empty(mv_par01)
				cOn += mv_par01+' AND '
			EndIf
			If !Empty(mv_par02)
				cOn += mv_par02+' AND '
			EndIf
			If !Empty(mv_par03)
				cOn += mv_par03+' AND '
			EndIf
			If !Empty(mv_par08)
				cOn += mv_par08+' AND '
			EndIf
			If !Empty(mv_par09)
				cOn += mv_par09+' '
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Adaptacao ao APDL - Considera somente mov. que atual. Estoque³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lIntDL
				cOn += " AND NOT (SDB.DB_ATUEST = 'N')"
			EndIf	
			cOn += "%"
			cWhere :="%"+StrTran(MV_PAR01,"DB_PRODUTO","B1_COD")+"%"
			
			dbSelectArea("SB1")
			dbSetOrder(1)
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Query do relatório da secao 1                                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oReport:Section(1):BeginQuery()	
			
			BeginSql Alias cAliasSDB
				SELECT SDB.DB_FILIAL,SDB.DB_PRODUTO,SDB.DB_LOCAL,SDB.DB_LOCALIZ,SDB.DB_NUMSERI,SDB.DB_LOTECTL,
				       SDB.DB_NUMLOTE,SDB.DB_DATA,SDB.DB_NUMSEQ,SDB.DB_IDOPERA,SDB.DB_DOC,SDB.DB_SERIE,SDB.DB_TM,
				       SDB.DB_QUANT,SDB.DB_ESTORNO, SB1.B1_COD, SB1.B1_DESC
					   %Exp:cSelect%
				
				FROM %table:SB1% SB1
				LEFT JOIN %Table:SDB% SDB ON( 
					SDB.DB_FILIAL = %xFilial:SDB%  AND 
					SDB.DB_PRODUTO = SB1.B1_COD AND 
					SDB.DB_LOCAL >= %Exp:mv_par04% AND 
					SDB.DB_LOCAL <= %Exp:mv_par05% AND 
					SDB.DB_DATA >= %Exp:mv_par06% AND 
					SDB.DB_DATA <= %Exp:mv_par07% AND 
					SB1.%NotDel% AND SDB.%NotDel% AND %Exp:cOn%)
				
				WHERE SB1.B1_FILIAL = %xFilial:SB1%  AND 
				    SB1.B1_LOCALIZ = 'S'  
				    AND SB1.%NotDel% AND %Exp:cWhere% 
				
				
				ORDER BY SB1.B1_COD,SDB.DB_LOCAL,SDB.DB_LOCALIZ,SDB.DB_NUMSERI,SDB.DB_LOTECTL,SDB.DB_NUMLOTE,SDB.DB_DATA
			
			EndSql 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Metodo EndQuery ( Classe TRSection )                                    ³
			//³                                                                        ³
			//³Prepara o relatório para executar o Embedded SQL.                       ³
			//³                                                                        ³
			//³ExpA1 : Array com os parametros do tipo Range                           ³
			//³                                                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Metodo TrPosition()                                                     ³
			//³                                                                        ³
			//³Posiciona em um registro de uma outra tabela. O posicionamento será     ³
			//³realizado antes da impressao de cada linha do relatório.                ³
			//³                                                                        ³
			//³                                                                        ³
			//³ExpO1 : Objeto Report da Secao                                          ³
			//³ExpC2 : Alias da Tabela                                                 ³
			//³ExpX3 : Ordem ou NickName de pesquisa                                   ³
			//³ExpX4 : String ou Bloco de código para pesquisa. A string será macroexe-³
			//³        cutada.                                                         ³
			//³                                                                        ³				
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			TRPosition():New(oSection,"SB1",1,{|| xFilial("SB1")+(cAliasSDB)->DB_PRODUTO})
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inicio da impressao do fluxo do relatório                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea(cAliasSDB)
			oReport:SetMeter(SDB->(LastRec()))
			oSection:Init()
			cProd := ''
			While !oReport:Cancel() .And. !(cAliasSDB)->(Eof())
			    
				lFirst  := .F.  
				lNprod  := .F.
				If oReport:Cancel()
					Exit
				EndIf
				
				oReport:IncMeter()
	
				If (cAliasSDB)->DB_ESTORNO == "S"  .And. mv_par10 == 2
					DbSkip()
					Loop
				EndIf			

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Considera filtro de usuario                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(cFilUsrSDB) .And. !(&(cFilUsrSDB))
					DbSkip()
					Loop
				EndIf			
						
				nSaldoIni:=nEntrada:=nSaida:=0                                         
				
				nSaldoIni:=CalcEstL((cAliasSDB)->B1_COD,(cAliasSDB)->DB_LOCAL,mv_par06,(cAliasSDB)->DB_LOTECTL,(cAliasSDB)->DB_NUMLOTE,(cAliasSDB)->DB_LOCALIZ,(cAliasSDB)->DB_NUMSERI)[1]
				
				//-- Converte o Saldo inicial para Segunda Unidade de Medida
				If nUm == 2
					nSaldoIni := ConvUM((cAliasSDB)->DB_PRODUTO, nSaldoIni, 0, 2)
				EndIf	
	
	 			If mv_par14 == 2 .And. Empty((cAliasSDB)->DB_DATA) .And. nSaldoIni == 0
	 				lNprod := .T.
	 				DbSkip()
	 				Loop			
				EndIf

				If !Empty(cProd) .And. cProd <> (cAliasSDB)->DB_PRODUTO
					oReport:SkipLine(1)
					If !lMovtoProd
						oReport:PrintText(STR0017)	//"Não houve movimentação para este produto"
    				EndIf
					oReport:ThinLine()
					lMovtoProd := .F.
					oReport:SkipLine(1)
				EndIf
				
				If (DB_DATA >= mv_par06 .And. DB_DATA <= mv_par07)  
					oSection:Cell("DB_PRODUTO"):Show()
					If TamSX3('DB_PRODUTO')[1]<= 15
						oSection:Cell("B1_DESC"):Show()
					EndIf
					oSection:Cell("DB_LOCAL"):Show()
					oSection:Cell("DB_LOCALIZ"):Show()
					oSection:Cell("DB_LOTECTL"):Show()
					oSection:Cell("DB_NUMLOTE"):Show()
					oSection:Cell("nSaldoIni"):Show()
					
					oSection:Cell("DB_NUMSERI"):Hide()
					oSection:Cell("DB_DATA"):Hide()
					oSection:Cell("cDoc"):Hide()
					oSection:Cell("cSerie"):Hide()
					oSection:Cell("DB_ESTORNO"):Hide()
					oSection:Cell("nEntrada"):Hide()
					oSection:Cell("nSaida"):Hide()
					oSection:Cell("nSaldo"):Hide()
					oSection:Cell("nSaldoIni"):SetValue(nSaldoIni)
					oSection:PrintLine()
				EndIf
				
				cProd    := (cAliasSDB)->DB_PRODUTO           
				cLocal   := (cAliasSDB)->DB_LOCAL
				cLocaliz := (cAliasSDB)->DB_LOCALIZ
				cLoteCtl := (cAliasSDB)->DB_LOTECTL
				cNumLote := (cAliasSDB)->DB_NUMLOTE
				cNumSerie:= (cAliasSDB)->DB_NUMSERI 
			
				Do While !Eof() .And. cProd+cLocal+cLocaliz+cNumSerie+cLoteCtl+cNumLote == (cAliasSDB)->DB_PRODUTO+(cAliasSDB)->DB_LOCAL+(cAliasSDB)->DB_LOCALIZ+(cAliasSDB)->DB_NUMSERIE+(cAliasSDB)->DB_LOTECTL+(cAliasSDB)->DB_NUMLOTE
				    
					If (cAliasSDB)->DB_ESTORNO == "S"  .And. mv_par10 == 2
						DbSkip()
						Loop
					EndIf			

		 			If mv_par14 == 2 .And. Empty((cAliasSDB)->DB_DATA)
		 				lNprod := .T.
		 				DbSkip()
		 				Loop			
					EndIf
						
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Considera filtro de usuario                                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty(cFilUsrSDB) .And. !(&(cFilUsrSDB))
		 				DbSkip()
		 				Loop			
					EndIf
					
					oSection:Cell("DB_PRODUTO"):Hide()
					If TamSX3('DB_PRODUTO')[1]<= 15	
						oSection:Cell("B1_DESC"):Hide()
					EndIf
					oSection:Cell("DB_LOCAL"):Hide()
					oSection:Cell("DB_LOCALIZ"):Hide()
					oSection:Cell("DB_LOTECTL"):Hide()
					oSection:Cell("DB_NUMLOTE"):Hide()
					oSection:Cell("nSaldoIni"):Hide()
					
					oSection:Cell("DB_NUMSERI"):Show()
					oSection:Cell("DB_DATA"):Show()
					oSection:Cell("cDoc"):Show()
					oSection:Cell("cSerie"):Show()
					oSection:Cell("DB_ESTORNO"):Show()
					oSection:Cell("nEntrada"):Show()
					oSection:Cell("nSaida"):Show()
					oSection:Cell("nSaldo"):Show()
				
					cDocSDB   := (cAliasSDB)->DB_DOC
					cSerieSDB := (cAliasSDB)->DB_SERIE
					
					//-- Imprime os Numeros de DOC e SERIE originais para Movimentacoes de CQ
					If lImpCQOrig
						MTR275OrCQ(@cDocSDB, @cSerieSDB)
					EndIf
					
					oSection:Cell("cDoc"):SetValue(cDocSDB)
					oSection:Cell("cSerie"):SetValue(cSerieSDB)
			
					If (cAliasSDB)->DB_TM <= "500" .Or. Substr((cAliasSDB)->DB_TM,1,1) $ "PD"
						oSection:Cell("nEntrada"):Show()
						If nUm == 1	
							nEntrada+=(cAliasSDB)->DB_QUANT
							oSection:Cell("nEntrada"):SetValue((cAliasSDB)->DB_QUANT)
						Else
							//-- Converte as Entradas para a 2a Unidade de Medida
							nEntrada += ConvUM((cAliasSDB)->DB_PRODUTO, (cAliasSDB)->DB_QUANT, 0, 2)
							oSection:Cell("nEntrada"):SetValue(ConvUM((cAliasSDB)->DB_PRODUTO, (cAliasSDB)->DB_QUANT, 0, 2))
						EndIf	
						oSection:Cell("nSaida"):Hide()
						oSection:Cell("nSaida"):SetValue(0)
					Else
						oSection:Cell("nSaida"):Show()
						If nUm == 1	
							nSaida+=(cAliasSDB)->DB_QUANT
							oSection:Cell("nSaida"):SetValue((cAliasSDB)->DB_QUANT)
						Else
							//-- Converte as Saidas para a 2a Unidade de Medida
							nSaida += ConvUM((cAliasSDB)->DB_PRODUTO, (cAliasSDB)->DB_QUANT, 0, 2)
							oSection:Cell("nSaida"):SetValue(ConvUM((cAliasSDB)->DB_PRODUTO, (cAliasSDB)->DB_QUANT, 0, 2))
						EndIf	
						oSection:Cell("nEntrada"):Hide()
						oSection:Cell("nEntrada"):SetValue(0)
					EndIf
					oSection:Cell("nSaldo"):SetValue((nSaldoIni+nEntrada) - nSaida)
					lFirst := .T.					
					lMovtoProd := .T.
					If (DB_DATA >= mv_par06 .And. DB_DATA <= mv_par07) 
						oSection:PrintLine()
					EndIf	
					If mv_par14 == 1 .And. !(DB_DATA >= mv_par06 .And. DB_DATA <= mv_par07)  
						oSection:Cell("DB_PRODUTO"):SetValue(B1_COD)
						oSection:Cell("B1_DESC"):SetValue(B1_DESC)
						oSection:Cell("DB_PRODUTO"):Show()
						oSection:Cell("B1_DESC"):Show()
						oSection:Cell("nEntrada"):Hide()
						oSection:Cell("DB_DATA"):Hide()
						oSection:PrintLine()
						oReport:SkipLine(1)
						oReport:PrintText(STR0017)
						oReport:SkipLine(1)
						oSection:Cell("DB_PRODUTO"):SetValue()
						oSection:Cell("B1_DESC"):SetValue()
						oReport:ThinLine()
					EndIf	
					dbSkip()
				EndDo
	
				If !lFirst .And. MV_PAR14 == 2 .And. !lNprod
					dbSkip()				
				EndIF

			EndDo

			If !Empty(cProd)
				If !lMovtoProd
					oReport:PrintText(STR0017)	//"Não houve movimentação para este produto"
   				EndIf
				oReport:ThinLine()
			EndIf
			oSection:Finish()		

		#ELSE
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Transforma parametros Range em expressao Advpl                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MakeAdvplExpr(cPerg)

			cCond2 := 'DB_FILIAL == "'+xFilial("SDB")+'".And.' 
			cCond2 += mv_par01+".And. "  // DB_PRODUTO
			cCond2 += mv_par08+".And. "  // DB_LOCALIZ
			cCond2 += mv_par09+".And. "  // DB_NUMSERI
			cCond2 += mv_par02+".And. "  // DB_LOTECTL
			cCond2 += mv_par03+".And. "  // DB_NUMLOTE
			cCond2 += 'DB_LOCAL >= "'+mv_par04+'".And.DB_LOCAL <="'+mv_par05+'"'
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quando lista somente com movimentos                         	 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par14 == 2
				cCond2 += '.And.DtoS(DB_DATA) >= "'+DtoS(mv_par06)+'".And.DtoS(DB_DATA) <="'+DtoS(mv_par07)+'"'
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Adaptacao ao APDL - Considera somente mov. que atual. Estoque ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lIntDL
				cCond2 += '.And.!(DB_ATUEST=="N")'
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cria o indice de trabalho p/ SDB: ordem de Prod+local+end   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cNomArq2 := Substr(CriaTrab(NIL,.F.),1,7)+"A"
  			cIndex2:="DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_LOCALIZ+DB_NUMSERI+DB_LOTECTL+DB_NUMLOTE+DTOS(DB_DATA)+DB_NUMSEQ+DB_IDOPERA"
			dbSelectArea(cAliasSDB)
			IndRegua("SDB",cNomArq2,cIndex2,,If(!Empty(cFilUsrSDB),cFilUsrSDB+'.And.','')+cCond2,STR0008) //"Selecionando Registros..."
			nIndDB := RetIndex(cAliasSDB)
			dbSetIndex(cNomArq2 + OrdBagExt())
			dbSetOrder(nIndDB + 1)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cria Arquivo Temporario para ordenar por produto+endereco no relatorio      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cNomArq1:=CriaTrab(aStrucSDB)
			cIndex1:=SubStr(cNomArq1,1,7)+"1"

			dbUseArea(.T.,,cNomArq1,"TRB",.T.,.F.)
			IndRegua("TRB",cIndex1,"DB_PRODUTO+DB_LOCAL+DB_LOCALIZ+DB_NUMSERI+DB_LOTECTL+DB_NUMLOTE+DTOS(DB_DATA)+DB_NUMSEQ+DB_IDOPERA")

			dbSelectArea("SB1")
			dbSetOrder(1)
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Troca os prefixos e/ou campos contidos nos parametros com o dos arquivos onde serao aplicados ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cPar08SBE := mv_par08
			While "DB_"$cPar08SBE
				cPar08SBE := StrTran(mv_par08,"DB_","BE_")
			EndDo
			cPar01SB1 := mv_par01
			While "DB_PRODUTO"$cPar01SB1
				cPar01SB1 := StrTran(mv_par01,"DB_PRODUTO","B1_COD")
			EndDo

			cCondicao := "B1_FILIAL=='"+xFilial("SB1")+"'.And. "
			cCondicao += cPar01SB1+" .And."
			cCondicao += "B1_LOCALIZ=='S'"

			Set Filter to &cCondicao
			dbGoTop()
			oReport:SetMeter(SB1->(LastRec()))
			dbSelectArea(cAliasSB1)

			While !oReport:Cancel() .And. !(cAliasSB1)->(Eof())

				If oReport:Cancel()
					Exit
				EndIf
				oReport:IncMeter()
				cProd    := (cAliasSB1)->B1_COD
	
				dbSelectArea("SB2")
				dbSetOrder(1)
				MsSeek(xFilial("SB2")+cProd)

				While !oReport:Cancel() .And. !Eof() .And. B2_FILIAL + B2_COD == xFilial("SB2") + cProd
					If B2_LOCAL < mv_par04 .Or. B2_LOCAL > mv_par05
						dbSkip()
						Loop
					EndIf

					dbSelectArea("SBE")
					dbSetOrder(1)
					MsSeek(xFilial("SBE")+SB2->B2_LOCAL)
					cLocaliz := "" // Chave unica SBE: Podem haver varias estruturas fisicas no mesmo local e endereco

					While !oReport:Cancel() .And. !Eof() .And. BE_FILIAL + BE_LOCAL == xFilial("SBE") + SB2->B2_LOCAL
						If BE_LOCALIZ == cLocaliz .Or. If(Empty(mv_par08),.F., ! &cPar08SBE )
							dbSkip()
							Loop
						EndIf
						cLocaliz := BE_LOCALIZ
						dbSelectArea("SDB")
  						dbSeek( xFilial("SDB") + cProd + SBE->BE_LOCAL + SBE->BE_LOCALIZ,.F. )
  						
						Do While !Eof()	.And. DB_FILIAL == xFilial("SDB") .And. DB_PRODUTO == cProd ;
							.And. DB_LOCAL == SBE->BE_LOCAL .And. DB_LOCALIZ == SBE->BE_LOCALIZ

							If DB_ESTORNO == "S"  .And. mv_par10 == 2
								DbSkip()
								Loop
							EndIf			

					 		If DB_DATA >= mv_par06 .And. DB_DATA <= mv_par07
								GravaTRB()

					 		ElseIf mv_par14 == 1 .And. DB_DATA <= mv_par07	// Ha' mov. anterior no endereco
								dbSelectArea("TRB")
								If !dbSeek( cProd+SBE->BE_LOCAL+SBE->BE_LOCALIZ+SDB->DB_NUMSERI+SDB->DB_LOTECTL+SDB->DB_NUMLOTE,.F. )
									If CalcEstL(SDB->DB_PRODUTO,SDB->DB_LOCAL,mv_par06,SDB->DB_LOTECTL,SDB->DB_NUMLOTE,SDB->DB_LOCALIZ,SDB->DB_NUMSERI)[1] > 0
										GravaTRB()
									EndIf
								EndIf
							EndIf

							dbSelectarea("SDB")
							dbSkip()
						Enddo

						dbSelectarea("SBE")
						dbSkip()
					EndDo

					dbSelectArea("SB2")
					dbSkip()
				EndDo

				dbSelectArea(cAliasSB1)
				dbSkip()
			EndDo
		
			TRPosition():New(oSection,cAliasSB1,1,{|| xFilial("SB1")+TRB->DB_PRODUTO})
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inicio da impressao do fluxo do relatório                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectarea("TRB")
			dbGoTop()
			oReport:SetMeter(TRB->(LastRec()))
			oSection:Init()
			While !oReport:Cancel() .And. !TRB->(Eof())
		
				If oReport:Cancel()
					Exit
				EndIf
				oReport:IncMeter()
	
				nSaldoIni:=nEntrada:=nSaida:=0                                         
					
				nSaldoIni:=CalcEstL(DB_PRODUTO,DB_LOCAL,mv_par06,DB_LOTECTL,DB_NUMLOTE,DB_LOCALIZ,DB_NUMSERI)[1]
					
				//-- Converte o Saldo inicial para Segunda Unidade de Medida
				If nUm == 2
					nSaldoIni := ConvUM(DB_PRODUTO, nSaldoIni, 0, 2)
				EndIf	

				oSection:Cell("DB_PRODUTO"):Show()
				If TamSX3('DB_PRODUTO')[1]<= 15
					oSection:Cell("B1_DESC"):Show()
				EndIf
				oSection:Cell("DB_LOCAL"):Show()
				oSection:Cell("DB_LOCALIZ"):Show()
				oSection:Cell("DB_LOTECTL"):Show()
				oSection:Cell("DB_NUMLOTE"):Show()
				oSection:Cell("nSaldoIni"):Show()
					
				oSection:Cell("DB_NUMSERI"):Hide()
				oSection:Cell("DB_DATA"):Hide()
				oSection:Cell("cDoc"):Hide()
				oSection:Cell("cSerie"):Hide()
				oSection:Cell("DB_ESTORNO"):Hide()
				oSection:Cell("nEntrada"):Hide()
				oSection:Cell("nSaida"):Hide()
				oSection:Cell("nSaldo"):Hide()

				oSection:Cell("nSaldoIni"):SetValue(nSaldoIni)

				oSection:PrintLine()  // Impressao do Saldo Inicial

				cProd    := DB_PRODUTO
				cLocal   := DB_LOCAL
				cLocaliz := DB_LOCALIZ
				cNumSerie:= DB_NUMSERI
				cLoteCtl := DB_LOTECTL
				cNumLote := DB_NUMLOTE
                   
				If mv_par14 == 1 .And. !Eof() .And. DB_DATA < mv_par06
					// despreza o registro utilizado para saldo inicial
					dbSkip()
				EndIf

				Do While !Eof() .And. cProd+cLocal+cLocaliz+cNumSerie+cLoteCtl+cNumLote == DB_PRODUTO+DB_LOCAL+DB_LOCALIZ+DB_NUMSERIE+DB_LOTECTL+DB_NUMLOTE .And. DB_DATA >= mv_par06
					    
					oSection:Cell("DB_PRODUTO"):Hide()
					If TamSX3('DB_PRODUTO')[1]<= 15
						oSection:Cell("B1_DESC"):Hide()
					EndIf
					oSection:Cell("DB_LOCAL"):Hide()
					oSection:Cell("DB_LOCALIZ"):Hide()
					oSection:Cell("DB_LOTECTL"):Hide()
					oSection:Cell("DB_NUMLOTE"):Hide()
					oSection:Cell("nSaldoIni"):Hide()
						
					oSection:Cell("DB_NUMSERI"):Show()
					oSection:Cell("DB_DATA"):Show()
					oSection:Cell("cDoc"):Show()
					oSection:Cell("cSerie"):Show()
					oSection:Cell("DB_ESTORNO"):Show()
					oSection:Cell("nEntrada"):Show()
					oSection:Cell("nSaida"):Show()
					oSection:Cell("nSaldo"):Show()
				
					cDocSDB   := DB_DOC
					cSerieSDB := DB_SERIE
					
					//-- Imprime os Numeros de DOC e SERIE originais para Movimentacoes de CQ
					If lImpCQOrig
						MTR275OrCQ(@cDocSDB, @cSerieSDB)
					EndIf
						
					oSection:Cell("cDoc"):SetValue(cDocSDB)
					oSection:Cell("cSerie"):SetValue(cSerieSDB)
				
					If  DB_TM <= "500" .Or. Substr(DB_TM,1,1) $ "PD"
						oSection:Cell("nEntrada"):Show()
						If nUm == 1	
							nEntrada+=DB_QUANT
							oSection:Cell("nEntrada"):SetValue(DB_QUANT)
						Else
							//-- Converte as Entradas para a 2a Unidade de Medida
							nEntrada += ConvUM(DB_PRODUTO, DB_QUANT, 0, 2)
							oSection:Cell("nEntrada"):SetValue(ConvUM(DB_PRODUTO, DB_QUANT, 0, 2))
						EndIf	
						oSection:Cell("nSaida"):Hide()
						oSection:Cell("nSaida"):SetValue(0)
					Else
						oSection:Cell("nSaida"):Show()
						If nUm == 1	
							nSaida+=DB_QUANT
							oSection:Cell("nSaida"):SetValue(DB_QUANT)
						Else
							//-- Converte as Saidas para a 2a Unidade de Medida
							nSaida += ConvUM(DB_PRODUTO, DB_QUANT, 0, 2)
							oSection:Cell("nSaida"):SetValue(ConvUM(DB_PRODUTO, DB_QUANT, 0, 2))
						EndIf	
						oSection:Cell("nEntrada"):Hide()
						oSection:Cell("nEntrada"):SetValue(0)
					EndIf
					oSection:Cell("nSaldo"):SetValue((nSaldoIni+nEntrada) - nSaida)
					oSection:PrintLine()
					lMovtoProd := .T.
					dbSkip()
				EndDo
				If cProd <> DB_PRODUTO
					If !lMovtoProd
						oReport:PrintText(STR0017)	//"Não houve movimentação para este produto"
    				EndIf
					oReport:ThinLine()
					lMovtoProd := .F.
				EndIf

			EndDo

			oSection:Finish()

			RetIndex("SDB")
			dbSelectArea("SDB")
			dbClearFilter()
			dbSetOrder(1)
			If File(cNomArq2+OrdBagExt())
				Ferase(cNomArq2+OrdBagExt())
			EndIf

			dbSelectArea("TRB")
			dbCloseArea()
			FErase( cNomArq1 + GetDBExtension() )
			FErase( cIndex1 + OrdBagExt() )

 			dbSelectArea("SB1")
			dbClearFilter()

		#ENDIF		
		
	EndIf
	
Next nForFilial

cFilAnt := cFilBack

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MATR275R3	³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 09/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Kardex p/ Lote Sobre o SDB (Antigo)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Patricia Sal³13.09.00³XXXXXX³Inclusao mv_par15 (Lista os Estornos ?)   ³±±
±±³Emerson Dib ³17.07.06³XXXXXX³Inclusao mv_par18 (Seleciona Filiais?)    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function MATR275R3U()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cDesc1    := STR0001	//"Este programa emitir  um Kardex com todas as movimenta‡”es"
LOCAL cDesc2    := STR0002	//"do estoque por Localizacao e Numero de Serie, diariamente."
LOCAL cDesc3    := ""
LOCAL titulo	:= STR0003	//"Kardex por Localizacao (por produto)"
LOCAL wnrel     := "MATR275"
LOCAL Tamanho   := "G"
LOCAL cString   := "SDB"

LOCAL aFilsCalc :={}

PRIVATE aReturn:= {STR0004,1,STR0005, 1, 2, 1, "",1 }	//"Zebrado"###"Administracao"
PRIVATE aLinha := { },nLastKey := 0
PRIVATE cPerg  :="MTR276"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta perguntas no SX1                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AjustaSX1(.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("MTR276",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                        		³
//³ mv_par01       		// Do  Produto ?                             	³
//³ mv_par02        	// Ate Produto ?                         		³
//³ mv_par03        	// De  Lote ?                            		³
//³ mv_par04        	// Ate Lote ?                            		³
//³ mv_par05        	// De  Sub-Lote ?                        		³
//³ mv_par06        	// Ate Sub-Lote ?                        		³
//³ mv_par07        	// Do Armazem ?                            		³
//³ mv_par08        	// Ate Armazem ?                           		³
//³ mv_par09        	// De  Data ?                             		³
//³ mv_par10        	// Ate Data ?                            		³
//³ mv_par11        	// Do  Endereco ?	                      		³
//³ mv_par12        	// Ate Endereco ?                        		³
//³ mv_par13        	// De  Numero de Serie ?                  		³
//³ mv_par14        	// Ate Numero de Serie ?                 		³
//³ mv_par15        	// Lista os Estornos ?                    		³
//³ mv_par16        	// Exibe Quantidades em qual UM ?        		³
//³ mv_par17        	// Para Movimentacoes de CQ ? 	        		³
//³ mv_par18        	// Seleciona Filiais ? (Sim/Nao)				³
//³ mv_par19        	// Lista Produtos sem movimento ?(1=Sim/2=Nao)	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel :=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,,.F.,Tamanho)

If nLastKey = 27
	dbClearFilter()
	Return
EndIf

// Funcao para a selecao de filiais
aFilsCalc:= MatFilCalc( mv_par18 == 1 ) 

If Empty(aFilsCalc)
	dbClearFilter()
	Return
EndIf

SetDefault(aReturn,cString)

If nLastKey = 27
	dbClearFilter()
	Return
EndIf

Processa({|lEnd| C275Imp(@lEnd,wnRel,tamanho,titulo,aFilsCalc)},titulo)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C275IMP  ³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 09/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR275			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function C275Imp(lEnd,WnRel,tamanho,titulo,aFilsCalc)

Local cNomArq2:=""
Local cPictQt:=PesqPict("SDB","DB_QUANT",14)
Local nSaldoIni:=nEntrada:=nSaida:=0
Local nTipo := IIF(aReturn[4]==1,15,18)
Local nIndDB	 := 0
Local cCond2	 := ""
Local cIndex2	 := ""
Local cProd		 := ""
Local cLocal, cLocaliz, cLoteCtl, cNumLote, cNumSerie
Local nUM        := mv_par16
Local lImpCQOrig := (mv_par17==2)
Local cDocSDB    := ''
Local cSerieSDB  := ''
Local lQuery	 := .F.
Local cAliasSDB	 := "SDB"    
Local cAliasSB1	 := "SB1"
Local aStrucSDB  := SDB->(dbStruct())
Local lFirst, lNprod
Local lIntDL	 := GetMV('MV_INTDL') == 'S'
Local lMovtoProd := .F.
Local cTexto     := SubStr(STR0006,1,134)+Space(10)+SubStr(STR0006,135,220)

#IFDEF TOP
    Local cName    := ""
	Local cQuery   := ""
	Local cQuery1  := ""
    Local cQryAd   := ""
    Local nQryAd   := 0
    Local nX       := 0
#ENDIF	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Tratamento da impressao por Filiais³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nForFilial:=0
Local cFilBack  :=cFilAnt

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cbtxt := Space(10)
PRIVATE cbcont:= 0
PRIVATE li    := 80
PRIVATE m_pag := 01

PRIVATE cabec1  := cTexto //"PRODUTO         DESCRICAO                      LOCAL LOCALIZACAO     NUMERO DE SERIE      LOTE       SUBLOTE DATA MOVIM    DOCUMENTO  SERIE EST SALDO INICIAL    ENTRADA        SAIDA          SALDO"
PRIVATE cabec2  := ""
//--                         123456789012345 123456789012345678901234567890  99   123456789012345 12345678901234567890 1234567890  123456 99/99/9999  999999999999  123   X  12345678901234 12345678901234 12345678901234 12345678901234
//--                         0         1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19
//--                         01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012

For nForFilial := 1 to Len(aFilsCalc)

	If aFilsCalc[nForFilial,1]
	
		// Altera filial corrente
		cFilAnt:=aFilsCalc[nForFilial,2]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta arquivo de trabalho p/ processar custo por Filial      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		#IFDEF TOP
			// **** ATENCAO - O ORDER BY UTILIZA AS POSICOES DO SELECT, SE ALGUM CAMPO
			// **** FOR INCLUIDO NA QUERY OU ALTERADO DE LUGAR DEVE SER REVISTA A SINTAXE
			// **** DO ORDER BY
				
			// 01 PRODUTO
			// 02 LOCAL
			// 03 LOCALIZ
			// 04 NUMSERI
			// 05 LOTECTL
			// 06 NUMLOTE
			// 07 DATA
			// 08 NUMSEQ
			// 09 ID OPERA
		    // 10 DOC
		    // 11 SERIE
		    // 12 TM
		    // 13 QUANT

			lQuery    := .T.
		    cAliasSDB := CriaTrab("",.F.)
			cQuery := "SELECT SDB.DB_FILIAL,SDB.DB_PRODUTO,SDB.DB_LOCAL,SDB.DB_LOCALIZ,SDB.DB_NUMSERI,SDB.DB_LOTECTL,SDB.DB_NUMLOTE,SDB.DB_DATA,"
			cQuery += "SDB.DB_NUMSEQ,SDB.DB_IDOPERA,SDB.DB_DOC,SDB.DB_SERIE,SDB.DB_TM,SDB.DB_QUANT,"
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Esta rotina foi escrita para adicionar no select os campos         ³
			//³usados no filtro do usuario quando houver, a rotina acrecenta      ³
			//³somente os campos que forem adicionados ao filtro testando         ³
			//³se os mesmo já existem no select ou se forem definidos novamente   ³
			//³pelo o usuario no filtro, esta rotina acrecenta o minimo possivel  ³
			//³de campos no select.                                               |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(aReturn[7]) .And. nQryAd == 0
				For nX := 1 To SDB->(FCount())
					cName := SDB->(FieldName(nX))
					If AllTrim( cName ) $ aReturn[7]
						If aStrucSDB[nX,2] <> "M"
							If !cName $ cQuery .And. !cName $ cQryAd
								cQryAd += "SDB."+ cName +","
								nQryAd ++
							EndIf
						EndIf
					EndIf
				Next nX
			EndIf
			
			cQuery += cQryAd
			cQuery += " SDB.DB_ESTORNO " 
			cQuery += ", SB1.B1_COD, SB1.B1_DESC FROM " 
			cQuery += RetSqlName("SB1") + " SB1 "
			cQuery +=	" LEFT JOIN " + RetSqlName("SDB") + " SDB ON ( "
			cQuery += " SDB.DB_FILIAL = '"+xFilial("SDB")+"' AND " 
			cQuery += " SDB.DB_PRODUTO = SB1.B1_COD AND "
			cQuery += " SDB.DB_LOCALIZ >='"+mv_par11+"' AND SDB.DB_LOCALIZ <='"+mv_par12+"' AND"
			cQuery += " SDB.DB_LOTECTL >='"+mv_par03+"' AND SDB.DB_LOTECTL <='"+mv_par04+"' AND"
			cQuery += " SDB.DB_NUMLOTE >='"+mv_par05+"' AND SDB.DB_NUMLOTE <='"+mv_par06+"' AND"
			cQuery += " SDB.DB_LOCAL   >='"+mv_par07+"' AND SDB.DB_LOCAL   <='"+mv_par08+"' AND"
			cQuery += " SDB.DB_NUMSERI >='"+mv_par13+"' AND SDB.DB_NUMSERI <='"+mv_par14+"' AND"
			cQuery += " SDB.DB_DATA >='"+DTOS(mv_par09)+"' AND SDB.DB_DATA <='"+DTOS(mv_par10)+"'"
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Adaptacao ao APDL - Considera somente mov. que atual. Estoque ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lIntDL
				cQuery += " AND NOT (SDB.DB_ATUEST = 'N') "
			EndIf
			cQuery += " AND SB1.D_E_L_E_T_<>'*' AND SDB.D_E_L_E_T_<>'*' )"
			cQuery += " WHERE SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND "
			cQuery += " SB1.B1_LOCALIZ = 'S' AND " 
			cQuery += " SB1.B1_COD >='"+mv_par01+"' AND SB1.B1_COD <='"+mv_par02+"' AND "
			cQuery += " SB1.B1_LOCALIZ = 'S' AND SB1.D_E_L_E_T_<>'*' "
			cQuery += " ORDER BY SB1.B1_COD,SDB.DB_LOCAL,SDB.DB_LOCALIZ,SDB.DB_NUMSERI,SDB.DB_LOTECTL, SDB.DB_NUMLOTE, SDB.DB_DATA "
			     
			cQuery:=ChangeQuery(cQuery)
			MsAguarde({|| dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasSDB,.F.,.T.)},STR0008)
			TCSetField(cAliasSDB,"DB_DATA","D",8,0)
			dbSelectArea(cAliasSDB)
			ProcRegua(LastRec())
	
			li := 999 // Forca a quebra de linha.
	          
			Do While !Eof()    
			          
    			dbSelectArea(cAliasSDB)      
				lFirst  := .F.
				lNprod  := .F.

				IncProc(STR0009 + " - " + aFilsCalc[nForFilial,3] )
								
				If (cAliasSDB)->DB_ESTORNO == "S"  .And. mv_par15 == 2
					DbSkip()
					Loop
				EndIf			
			
			    If !Empty(aReturn[7]) .And. !&(aReturn[7])
			        DbSkip()
			        Loop
			    EndIf	
								
				If lEnd
					@PROW()+1,001 PSAY STR0007 //"CANCELADO PELO OPERADOR"
					Exit
				EndIf
					
				nSaldoIni:=nEntrada:=nSaida:=0                                         
				
				nSaldoIni:=CalcEstL((cAliasSDB)->B1_COD,(cAliasSDB)->DB_LOCAL,mv_par09,(cAliasSDB)->DB_LOTECTL,(cAliasSDB)->DB_NUMLOTE,(cAliasSDB)->DB_LOCALIZ,(cAliasSDB)->DB_NUMSERI)[1]
				
				//-- Converte o Saldo inicial para Segunda Unidade de Medida
				If nUm == 2
					nSaldoIni := ConvUM((cAliasSDB)->B1_COD, nSaldoIni, 0, 2)
				EndIf	
				         
	 			If mv_par19 == 2 .And. Empty((cAliasSDB)->DB_DATA) .And. nSaldoIni == 0
	 				lNprod := .T.
	 				DbSkip()
	 				Loop			
				EndIf
			
				If  !Empty(cProd) .And. cProd <> (cAliasSDB)->B1_COD
					If !lMovtoProd
						Li++
						@Li ,  0 PSay STR0017	//"Não houve movimentação para este produto"
						Li++
    				EndIf
					@Li ,  0 PSay __PrtThinLine()		
					Li++				
					lMovtoProd := .F.
				EndIf

				If li > 58
				    If mv_par18 == 1   // Seleciona Filiais
						cabec(titulo + " - " + aFilsCalc[nForFilial,3],cabec1,cabec2,wnrel,Tamanho,nTipo)
					Else	
						cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
					EndIf	
				EndIf          
			
				@ li,000 PSAY (cAliasSDB)->B1_COD
				If SB1->(dbSeek(xFilial("SB1")+(cAliasSDB)->B1_COD)) .And. TamSX3('DB_PRODUTO')[1]<= 15
					@ li,016 PSAY Substr(SB1->B1_DESC,1,30)
				EndIf
				@ li,048 PSAY (cAliasSDB)->DB_LOCAL
				@ li,053 PSAY (cAliasSDB)->DB_LOCALIZ
				@ li,090 PSAY (cAliasSDB)->DB_LOTECTL
				@ li,102 PSAY (cAliasSDB)->DB_NUMLOTE
				@ li,144 PSAY nSaldoIni PICTURE cPictQt
				
				Li++
				
				cProd    := (cAliasSDB)->B1_COD          
				cLocal   := (cAliasSDB)->DB_LOCAL
				cLocaliz := (cAliasSDB)->DB_LOCALIZ
				cLoteCtl := (cAliasSDB)->DB_LOTECTL
				cNumLote := (cAliasSDB)->DB_NUMLOTE
				cNumSerie:= (cAliasSDB)->DB_NUMSERI
			
				Do While !Eof() .And. cProd+cLocal+cLocaliz+cNumSerie+cLoteCtl+cNumLote == (cAliasSDB)->B1_COD+(cAliasSDB)->DB_LOCAL+(cAliasSDB)->DB_LOCALIZ+(cAliasSDB)->DB_NUMSERIE+(cAliasSDB)->DB_LOTECTL+(cAliasSDB)->DB_NUMLOTE       	
	
					If (cAliasSDB)->DB_ESTORNO == "S"  .And. mv_par15 == 2
						DbSkip()
						Loop
					EndIf			
				
				    If !Empty(aReturn[7]) .And. !&(aReturn[7])
				        DbSkip()
				        Loop
				    EndIf	
	                     
		 			If Empty((cAliasSDB)->DB_DATA) .And. mv_par19 == 2
		 				lNprod := .T.
		 				DbSkip()
		 				Loop			
					EndIf
						
					If (cAliasSDB)->DB_DATA < mv_par09 .Or. (cAliasSDB)->DB_DATA > mv_par10
						lNprod := .T.
						DbSkip()
						Loop
					EndIf			
						
					If li > 58
						If mv_par18 == 1   // Seleciona Filiais
						   cabec(titulo + " - " + aFilsCalc[nForFilial,3],cabec1,cabec2,wnrel,Tamanho,nTipo)
						Else
						   cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
						EndIf   
					EndIF
			       	
					@ li,069 PSAY (cAliasSDB)->DB_NUMSERI
					@ li,109 PSAY (cAliasSDB)->DB_DATA
					
					cDocSDB   := (cAliasSDB)->DB_DOC
					cSerieSDB := (cAliasSDB)->DB_SERIE
					//-- Imprime os Numeros de DOC e SERIE originais para Movimentacoes de CQ
					If lImpCQOrig
						MTR275OrCQ(@cDocSDB, @cSerieSDB)
					EndIf
					@ li,122 PSAY cDocSDB
					@ li,147 PSAY cSerieSDB
			
					@ li,153 PSAY (cAliasSDB)->DB_ESTORNO
					If (cAliasSDB)->DB_TM <= "500" .Or. Substr((cAliasSDB)->DB_TM,1,1) $ "PD"
						If nUm == 1	
							@ li,171 PSAY (cAliasSDB)->DB_QUANT PICTURE cPictQt
							nEntrada+=(cAliasSDB)->DB_QUANT
						Else
							//-- Converte as Entradas para a 2a Unidade de Medida
							@ li,171 PSAY ConvUM((cAliasSDB)->B1_COD, (cAliasSDB)->DB_QUANT, 0, 2) PICTURE cPictQt
							nEntrada += ConvUM((cAliasSDB)->B1_COD, (cAliasSDB)->DB_QUANT, 0, 2)
						EndIf	
					Else
						If nUm == 1	
							@ li,186 PSAY (cAliasSDB)->DB_QUANT PICTURE cPictQt
							nSaida+=(cAliasSDB)->DB_QUANT
						Else
							//-- Converte as Saidas para a 2a Unidade de Medida
							@ li,186 PSAY ConvUM((cAliasSDB)->B1_COD, (cAliasSDB)->DB_QUANT, 0, 2) PICTURE cPictQt
							nSaida += ConvUM((cAliasSDB)->B1_COD, (cAliasSDB)->DB_QUANT, 0, 2)
						EndIf	
					EndIf
					@ li,201 PSAY (nSaldoIni+nEntrada) - nSaida PICTURE cPictQt
					Li++                                                       
					lFirst	   := .T.				
					lMovtoProd := .T.			
					dbSkip()
				EndDo
				
				If !lFirst .And. mv_par19 == 2 .And. !lnProd
					dbSkip()				
				EndIf			
				
			EndDo
			If !Empty(cProd)
				If !lMovtoProd
					Li++
					@Li ,  0 PSay STR0017	//"Não houve movimentação para este produto"
					Li++
   				EndIf
				@Li ,  0 PSay __PrtThinLine()		
				Li++				
			EndIf
		
		#ELSE                              

			cCond2 := 'DB_FILIAL == "'+xFilial("SDB")+'".And.'
			cCond2 += 'DB_PRODUTO >= "'+mv_par01+'".And.DB_PRODUTO <= "'+mv_par02+'".And.'
			cCond2 += 'DB_LOCALIZ >= "'+mv_par11+'".And.DB_LOCALIZ <="'+mv_par12+'".And.'
			cCond2 += 'DB_LOTECTL >= "'+mv_par03+'".And.DB_LOTECTL <="'+mv_par04+'".And. '
			cCond2 += 'DB_LOCAL >= "'+mv_par07+'".And.DB_LOCAL <="'+mv_par08+'".And. '
			cCond2 += 'DB_NUMLOTE >= "'+mv_par05+'".And.DB_NUMLOTE <="'+mv_par06+'".And. '
			cCond2 += 'DB_NUMSERI >= "'+mv_par13+'".And.DB_NUMSERI <="'+mv_par14+'"'
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quando lista somente com movimentos                         	 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par19 == 2
				cCond2 += '.And.DtoS(DB_DATA) >= "'+DtoS(mv_par09)+'".And.DtoS(DB_DATA) <="'+DtoS(mv_par10)+'"'
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Adaptacao ao APDL - Considera somente mov. que atual. Estoque ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lIntDL
				cCond2 += '.And.!(DB_ATUEST=="N")'
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cria o indice de trabalho p/ SDB: ordem de Prod+local+end   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cNomArq2 := Substr(CriaTrab(NIL,.F.),1,7)+"A"
  			cIndex2:="DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_LOCALIZ+DB_NUMSERI+DB_LOTECTL+DB_NUMLOTE+DTOS(DB_DATA)+DB_NUMSEQ+DB_IDOPERA"
			dbSelectArea(cAliasSDB)
			IndRegua("SDB",cNomArq2,cIndex2,,If(!Empty(aReturn[7]),aReturn[7]+'.And.','')+cCond2,STR0008) //"Selecionando Registros..."
			nIndDB := RetIndex(cAliasSDB)
			dbSetIndex(cNomArq2 + OrdBagExt())
			dbSetOrder(nIndDB + 1)
    
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cria Arquivo Temporario para ordenar por produto+endereco no relatorio      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cNomArq1:=CriaTrab(aStrucSDB)
			cIndex1:=SubStr(cNomArq1,1,7)+"1"

			dbUseArea(.T.,,cNomArq1,"TRB",.T.,.F.)
			IndRegua("TRB",cIndex1,"DB_PRODUTO+DB_LOCAL+DB_LOCALIZ+DB_NUMSERI+DB_LOTECTL+DB_NUMLOTE+DTOS(DB_DATA)+DB_NUMSEQ+DB_IDOPERA")

			dbSelectArea("SB1")
			dbSetOrder(1)
		
			cCondicao := 'B1_FILIAL=="'+xFilial("SB1")+'".And.B1_COD>="'+mv_par01+'".And.B1_COD<="'+mv_par02+'".And.'
			cCondicao += 'B1_LOCALIZ=="S"'
			
			Set Filter to &cCondicao
			dbGoTop()
			ProcRegua(LastRec())
			dbSelectArea(cAliasSB1)

			Do While !Eof()    	          
			 
				IncProc(STR0009 + " - " + aFilsCalc[nForFilial,3] )

				cProd	:= (cAliasSB1)->B1_COD

				dbSelectArea("SB2")
				dbSetOrder(1)
				MsSeek(xFilial("SB2")+cProd)

				While !Eof() .And. B2_FILIAL + B2_COD == xFilial("SB2") + cProd
					If B2_LOCAL < mv_par07 .Or. B2_LOCAL > mv_par08
						dbSkip()
						Loop
					EndIf

					dbSelectArea("SBE")
					dbSetOrder(1)
					MsSeek(xFilial("SBE")+SB2->B2_LOCAL)
					cLocaliz := "" // Chave unica SBE: Podem haver varias estruturas fisicas no mesmo local e endereco

					While !Eof() .And. BE_FILIAL + BE_LOCAL == xFilial("SBE") + SB2->B2_LOCAL
						If BE_LOCALIZ == cLocaliz .Or. BE_LOCALIZ < mv_par11 .Or. BE_LOCALIZ > mv_par12
							dbSkip()
							Loop
						EndIf
						cLocaliz := BE_LOCALIZ
						dbSelectArea("SDB")
  						dbSeek( xFilial("SDB") + cProd + SBE->BE_LOCAL + SBE->BE_LOCALIZ,.F. )
  						
						Do While !Eof()	.And. DB_FILIAL == xFilial("SDB") .And. DB_PRODUTO == cProd ;
							.And. DB_LOCAL == SBE->BE_LOCAL .And. DB_LOCALIZ == SBE->BE_LOCALIZ

							If DB_ESTORNO == "S"  .And. mv_par15 == 2
								DbSkip()
								Loop
							EndIf			

					 		If DB_DATA >= mv_par09 .And. DB_DATA <= mv_par10
								GravaTRB()

					 		ElseIf mv_par19 == 1 .And. DB_DATA <= mv_par10	// Ha' mov. anterior no endereco
								dbSelectArea("TRB")
								If !dbSeek( cProd+SBE->BE_LOCAL+SBE->BE_LOCALIZ+SDB->DB_NUMSERI+SDB->DB_LOTECTL+SDB->DB_NUMLOTE,.F. )
									If CalcEstL(SDB->DB_PRODUTO,SDB->DB_LOCAL,mv_par09,SDB->DB_LOTECTL,SDB->DB_NUMLOTE,SDB->DB_LOCALIZ,SDB->DB_NUMSERI)[1] > 0
										GravaTRB()
									EndIf
								EndIf
							EndIf

							dbSelectarea("SDB")
							dbSkip()
						Enddo

						dbSelectarea("SBE")
						dbSkip()
					EndDo

					dbSelectArea("SB2")
					dbSkip()
				EndDo

				dbSelectArea("SB1")
				dbSkip()
			EndDo
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inicio da impressao do relatório  			                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectarea("TRB")
			ProcRegua(LastRec())
			dbGoTop()

			While !TRB->(Eof())
				
				IncProc(STR0009 + " - " + aFilsCalc[nForFilial,3] )

				If lEnd
					@PROW()+1,001 PSAY STR0007 //"CANCELADO PELO OPERADOR"
					Exit
				EndIf
						
				nSaldoIni:=nEntrada:=nSaida:=0                                         
					
				nSaldoIni:=CalcEstL(DB_PRODUTO,DB_LOCAL,mv_par09,DB_LOTECTL,DB_NUMLOTE,DB_LOCALIZ,DB_NUMSERI)[1]
					
				//-- Converte o Saldo inicial para Segunda Unidade de Medida
				If nUm == 2
					nSaldoIni := ConvUM(DB_PRODUTO, nSaldoIni, 0, 2)
				EndIf	
					
				If li > 58
				    If mv_par18 == 1   // Seleciona Filiais
						cabec(titulo + " - " + aFilsCalc[nForFilial,3],cabec1,cabec2,wnrel,Tamanho,nTipo)
					Else	
						cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
					EndIf	
				EndIf          
				
				@ li,000 PSAY DB_PRODUTO
				If SB1->(dbSeek(xFilial("SB1")+cProd))
					@ li,016 PSAY Substr(SB1->B1_DESC,1,30)
				EndIf
				@ li,048 PSAY DB_LOCAL
				@ li,053 PSAY DB_LOCALIZ
				@ li,090 PSAY DB_LOTECTL
				@ li,102 PSAY DB_NUMLOTE
				@ li,144 PSAY nSaldoIni PICTURE cPictQt
						
				Li++
					
				cProd    := DB_PRODUTO           
				cLocal   := DB_LOCAL
				cLocaliz := DB_LOCALIZ
				cLoteCtl := DB_LOTECTL
				cNumLote := DB_NUMLOTE
				cNumSerie:= DB_NUMSERI
				
				If mv_par19 == 1 .And. !Eof() .And. DB_DATA < mv_par09
					// despreza o registro utilizado para saldo inicial
					dbSkip()
				EndIf

				Do While !Eof() .And. cProd+cLocal+cLocaliz+cNumSerie+cLoteCtl+cNumLote == DB_PRODUTO+DB_LOCAL+DB_LOCALIZ+DB_NUMSERIE+DB_LOTECTL+DB_NUMLOTE

					If li > 58
						If mv_par18 == 1   // Seleciona Filiais
						   cabec(titulo + " - " + aFilsCalc[nForFilial,3],cabec1,cabec2,wnrel,Tamanho,nTipo)
						Else
						   cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
						EndIf   
					EndIF
				       	
					@ li,069 PSAY DB_NUMSERI
					@ li,109 PSAY DB_DATA
						
					cDocSDB   := DB_DOC
					cSerieSDB := DB_SERIE
					//-- Imprime os Numeros de DOC e SERIE originais para Movimentacoes de CQ
					If lImpCQOrig
						MTR275OrCQ(@cDocSDB, @cSerieSDB)
					EndIf
					@ li,122 PSAY cDocSDB
					@ li,147 PSAY cSerieSDB
			
					@ li,153 PSAY DB_ESTORNO
					If DB_TM <= "500" .Or. Substr(DB_TM,1,1) $ "PD"
						If nUm == 1	
							@ li,171 PSAY DB_QUANT PICTURE cPictQt
							nEntrada+=DB_QUANT
						Else
							//-- Converte as Entradas para a 2a Unidade de Medida
							@ li,171 PSAY ConvUM(DB_PRODUTO, DB_QUANT, 0, 2) PICTURE cPictQt
							nEntrada += ConvUM(DB_PRODUTO, DB_QUANT, 0, 2)
						EndIf	
					Else
						If nUm == 1	
							@ li,186 PSAY DB_QUANT PICTURE cPictQt
							nSaida+=DB_QUANT
						Else
							//-- Converte as Saidas para a 2a Unidade de Medida
							@ li,186 PSAY ConvUM(DB_PRODUTO, DB_QUANT, 0, 2) PICTURE cPictQt
							nSaida += ConvUM(DB_PRODUTO, DB_QUANT, 0, 2)
						EndIf	
					EndIf
					@ li,201 PSAY (nSaldoIni+nEntrada) - nSaida PICTURE cPictQt
					Li++                                                       
					lMovtoProd := .T.
					dbSkip()
				EndDo

   				If cProd <> DB_PRODUTO
					If !lMovtoProd
						@Li ,  0 PSay STR0017	//"Não houve movimentação para este produto"
						Li++
    				EndIf
					@Li ,  0 PSay __PrtThinLine()		
					Li++				
					lMovtoProd := .F.
				EndIf
            
            EndDo
            
  			dbSelectArea("SB1")
			dbClearFilter()

        #ENDIF
		
		If li != 80
			roda(cbcont,cbtxt,Tamanho)
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Apaga indice de trabalho                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lQuery
			(cAliasSDB)->(dbCloseArea())
		Else
			RetIndex("SDB")
			dbSelectArea("SDB")
			dbClearFilter()
			dbSetOrder(1)
			If File(cNomArq2+OrdBagExt())
				Ferase(cNomArq2+OrdBagExt())
			EndIf

			dbSelectArea("TRB")
			dbCloseArea()
			FErase( cNomArq1 + GetDBExtension() )
			FErase( cIndex1 + OrdBagExt() )
		EndIf	

    EndIf

Next nForFilial

// Restaura filial original apos processamento
cFilAnt:=cFilBack

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve as ordens originais do arquivo                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RetIndex("SDB")
dbClearFilter()

If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	ourspool(wnrel)
EndIf

MS_FLUSH()
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AjustaSX1 ³ Autor ³ Ricardo Berti         ³ Data ³ 24/07/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ajuste de perguntas no SX1 				                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AjustaSX1(ExpL1)                              		 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1: .T. = chamada do Relatorio TReport (Release 4)      ³±±
±±³          ³        .F. = chamada do Relatorio da Release 3  	          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum		                                 		 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATR275                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaSX1(lTReport)

Local aAreaAnt:= GetArea()
Local aPerg	  := {}
Local nTamSX1 := Len(SX1->X1_GRUPO)

dbSelectArea("SX1")
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajuste da Pergunta 08 - Release 4                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTReport .And. dbSeek(PADR("MTR276P9R1",nTamSX1)+"08") .And. !"Endereco"$X1_PERGUNT
	RecLock("SX1",.F.)
	Replace X1_PERGUNT 	with "Endereco ?"
	MsUnLock()
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajuste da Pergunta 11 - Release 3                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lTReport .And. dbSeek(PADR("MTR276",nTamSX1)+"11") .And. !"Endereco"$X1_PERGUNT
	RecLock("SX1",.F.)
	Replace X1_PERGUNT 	with "Do Endereco ?"
	MsUnLock()
EndIf            

Aadd(aPerg,{"Sim","Si","Yes"})
Aadd(aPerg,{"Nao","No","No"})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajuste da Pergunta 14 - Release 4                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTReport .And. dbSeek(PADR("MTR276P9R1",nTamSX1)+"14") .And. ("Nao"$X1_DEF01 .Or. "No"$X1_DEFSPA1 .Or. "No"$X1_DEFENG1)
	RecLock("SX1",.F.)
	Replace X1_DEF01 	with aPerg[1][1]
	Replace X1_DEFSPA1	with aPerg[1][2]
	Replace X1_DEFENG1 	with aPerg[1][3]
	Replace X1_DEF02 	with aPerg[2][1]
	Replace X1_DEFSPA2	with aPerg[2][2]
	Replace X1_DEFENG2 	with aPerg[2][3]
	MsUnLock()
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajuste da Pergunta 19 - Release 3                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lTReport .And. dbSeek(PADR("MTR276",nTamSX1)+"19") .And. ("Nao"$X1_DEF01 .Or. "No"$X1_DEFSPA1 .Or. "No"$X1_DEFENG1)
	RecLock("SX1",.F.)
	Replace X1_DEF01 	with aPerg[1][1]
	Replace X1_DEFSPA1	with aPerg[1][2]
	Replace X1_DEFENG1 	with aPerg[1][3]
	Replace X1_DEF02 	with aPerg[2][1]
	Replace X1_DEFSPA2	with aPerg[2][2]
	Replace X1_DEFENG2 	with aPerg[2][3]
	MsUnLock()
EndIf

RestArea(aAreaAnt)
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AjustaSXB  ³ Autor ³ Bruno Schmidt        ³ Data ³20/12/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de Validacao da Tudok                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSXB()

Local aArea      := GetArea()
Local aAreaSXB	 := SXB->(GetArea())
Local nTamSXB    := Len(SXB->XB_ALIAS)

dbSelectArea("SXB")
dbSetOrder(1)  

If !dbSeek(PadR('SDB', nTamSXB)+'40104')
	RecLock('SXB', .T.)
	SXB->XB_ALIAS   := 'SDB'
	SXB->XB_TIPO    := '4'
	SXB->XB_SEQ     := '01'
	SXB->XB_COLUNA  := '04'
	SXB->XB_DESCRI  := 'Numero de Serie'
	SXB->XB_DESCSPA := 'Numero de Serie'
	SXB->XB_DESCENG := 'Serie Number'
	SXB->XB_CONTEM  := 'DB_NUMSERIE'
	MsUnlock()
Endif 

If dbSeek(PadR('SDB', nTamSXB)+'501  ')
	If SXB->XB_CONTEM  <> 'SDB->DB_NUMSERIE'
		RecLock('SXB', .F.)
		SXB->XB_CONTEM  := 'SDB->DB_NUMSERIE'
		MsUnlock()
	EndIF
Endif

RestArea(aAreaSXB)
RestArea(aArea)		
Return Nil	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTR275OrCQºAutor  ³Microsiga           º Data ³  06/09/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MTR275OrCQ(cDoc, cSerie)

Local aAreaAnt   := GetArea()

dbSelectArea('SD7')
dbSetorder(1)
If MsSeek(xFilial('SD7')+cDoc, .F.)
	cDoc   := SD7->D7_DOC
	cSerie := SD7->D7_SERIE
EndIf

RestArea(aAreaAnt)
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GravaTRB ³ Autor ³ Ricardo Berti         ³ Data ³ 24/07/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava os movtos. no arq.temp. para o Relatorio             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GravaTrb()	                                 		 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum		                                 		 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATR275                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
#IFNDEF TOP
Static Function GravaTRB()

Local nCntFor := 0
RecLock("TRB",.T.)
For nCntFor := 1 To TRB->(FCount())
	If ( FieldName(nCntFor)= "DB_FILIAL" )
		TRB->DB_FILIAL := xFilial("SDB")
	Else
		FieldPut(nCntFor,SDB->&(FieldName(nCntFor)))
	EndIf
Next
MsUnlock()
Return Nil
#ENDIF