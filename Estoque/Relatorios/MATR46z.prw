#INCLUDE "MATR460.CH"
#INCLUDE "PROTHEUS.CH"  
#include "Tbiconn.ch"
#DEFINE TT	Chr(254)+Chr(254)	// Substituido p/ "TT"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MATR460  � Autor � Nereu Humberto Junior � Data � 31.07.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio do Inventario, Registro Modelo P7                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function MATR46z()
Local oReport  := NIL
Local lCusUnif := IIf(FindFunction("A330CusFil"),A330CusFil(),GetMV("MV_CUSFIL",.F.))

Static nDecVal := TamSX3("B2_CM1")[2] // Retorna o numero de decimais usado no SX3

//-- Ajusta as Perguntas do SX1
AjustaSx1()

//-- Ajusta perguntas no SX1 a fim de preparar o relatorio p/
//-- custo unificado por empresa
If lCusUnif
	MTR460CUnf(lCusUnif)
EndIf

If FindFunction("TRepInUse") .And. TRepInUse() 
	//-- Interface de impressao
	oReport:= ReportDef()
	oReport:PrintDialog()
Else
	U_MATR460RZ()
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor �Nereu Humberto Junior  � Data �31.07.2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relatorio                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local oReport 	:= NIL
Local oCell	:= NIL
Local oSection1 := NIL

//-- Funcao utilizada para verificar a ultima versao do fonte
//-- SIGACUSA.PRX aplicados no rpo do cliente, assim verificando
//-- a necessidade de uma atualizacao nestes fontes. NAO REMOVER !!!
If !(FindFunction("SIGACUS_V")	.And. SIGACUS_V() >= 20130731)
    Final(STR0040 + " SIGACUS.PRW !!!") // "Atualizar SIGACUS.PRW"
EndIf
If !(FindFunction("SIGACUSA_V")	.And. SIGACUSA_V() >= 20060321)
    Final(STR0040 + " SIGACUSA.PRX !!!") // "Atualizar SIGACUSA.PRX"
EndIf

oReport:= TReport():New("MATR460",STR0001,"MTR46Z", {|oReport| U_ReportPrinZ(oReport)},STR0002) //"Registro de Invent�rio - Modelo P7"##"Emiss�o do Registro de Invent�rio.Os Valores Totais serao impressos conforme Modelo Legal"
oReport:SetTotalInLine(.F.)
oReport:nFontBody	:= 08 // Define o tamanho da fonte.
oReport:nLineHeight := 45 // Define a altura da linha.
oReport:SetEdit(.T.)
oReport:HideHeader() 
oReport:HideFooter()
oReport:SetUseGC(.F.) // Remove bot�o da gest�o de empresas pois conflita com a pergunta "Seleciona Filiais" 

//-- Secao criada para evitar error log no botao Personalizar
oSection1 := TRSection():New(oReport,STR0042,{"SB1"}) //"Saldos em Estoque"
oSection1:SetReadOnly()

Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor �Nereu Humberto Junior  � Data �21.06.2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relatorio                           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function ReportPrinZ(oReport)
Static lCalcUni	:= .F.
Static cFilUsrSB1	:= ""

Local cPeLocProc  := ""
Local cArqTemp    := ""
Local cIndTemp1   := ""
Local cIndTemp2   := ""
Local cQuery		:= ""
Local cKeyInd		:= ""
Local cPosIpi		:= ""
Local cSeekUnif   := ""
Local cJoin		:= ""
Local cArqAbert	:= ""
Local cArqEncer	:= ""
Local cIndSB6		:= ""
Local cFilP7		:= ""
Local cKeyQbr		:= ""
Local cSelect		:= "%%"
Local cAliasTop	:= "SB2"
Local cQuebraCon	:= ""
Local cLocTerc		:= SuperGetMV("MV_ALMTERC",.F.,"")
Local cLocProc		:= SuperGetMv("MV_LOCPROC",.F.,"99")
Local cFilBack		:= cFilAnt
Local cFilCons		:= cFilAnt

Local i				:= 0
Local nPos			:= 0
Local nTotIpi		:= 0
Local nX			:= 0
Local nValTotUnif	:= 0
Local nQtdTotUnif	:= 0
Local nLin			:= 80
Local nPosFilCorr	:= 0
Local nForFilial	:= 0
Local nIndSB6		:= 0
Local nPagina		:= 0
Local nForBkp		:= 0
Local nBarra		:= 0
Local nCLIFOR		:= TamSX3("B6_CLIFOR")[1]
Local nLOJA		:= TamSX3("B6_LOJA")[1]
Local nPRODUTO		:= TamSX3("B6_PRODUTO")[1]
Local nTPCF		:= TamSX3("B6_TPCF")[1]
Local nTamSX1     := Len(SX1->X1_GRUPO)

Local aTerceiros	:= {}
Local aArqTemp		:= {}
Local aTotal		:= {}
Local aSeek		:= {}
Local aSaldo		:= {0,0,0,0}
Local aDadosCF9   := {0,0}
Local aArqCons		:= Array(3)
Local aAuxTer		:= {}
Local aA460AMZP	:= {}
Local aImp			:= {}
Local aSalAtu		:= {}
Local aSaldoTerD  := {}
Local aSaldoTerT  := {}
Local aL			:= R460LayOut(.T.)
Local aDriver		:= ReadDriver()
Local aFilsCalc   := {}

Local lSaldTesN3  := .F.
Local lEmBranco	:= .F.
Local lImpResumo  := .F.
Local lImpAliq		:= .F.
Local lTipoBN		:= .F.
Local lFirst		:= .T.
Local lCusConFil	:= .F.
Local lGravaSit3	:= .T.
Local lConsolida	:= .F.
Local lCusFIFO		:= SuperGetMV("MV_CUSFIFO",.F.,.F.)                                                          	
Local lA460AMZP   := ExistBlock("A460AMZP")
Local lAgregOP    := SB1->(FieldPos("B1_AGREGCU")) > 0 
Local lImpSit		:= .T.
Local lImpTipo		:= .T.
Local lCusUnif		:= IIf(FindFunction("A330CusFil"),A330CusFil(),GetMV("MV_CUSFIL",.F.))
Local lA460TESN3	:= ExistBlock("A460TESN3")
Local l460UnProc	:= SuperGetMV("MV_R460UNP",.F.,.T.)

Local bQuebraCon  := {|x| aFilsCalc[x,4]+aFilsCalc[x,5]} //-- Bloco que define a quebra de impressao

Local oSection1   := oReport:Section(1)

Private nSumQtTer	:= 0   // variavel opcional para o PE A460TESN3

cFilUsrSB1 := oSection1:GetAdvplExp()

//-- Chamada da pergunte e criacao das variaveis de controle
//-- IMPORTANTE: ler mv_par somente apos esta linha
Pergunte("MTR46Z",.F.)
nPagina	 	:= mv_par10
lConsolida	 	:= mv_par21 == 1 .And. mv_par25 == 1
aFilsCalc	 	:= MatFilCalc(mv_par21 == 1,,,lConsolida)
lCusConFil	 	:= lConsolida .And. SuperGetMv('MV_CUSFIL',.F.,"A") == "F" //-- Impressao consolidada e com custo unificado por filial
cAlmoxIni	 	:= IIf(mv_par03 == "**",Space(02),mv_par03)
cAlmoxFim	 	:= IIf(mv_par04 == "**","ZZ",mv_par04)
nQtdPag	 	:= mv_par11
cNrLivro	 	:= mv_par12
nQuebraAliq	:= IIf(mv_par22 == 1,1,mv_par19)

//-- A460UNIT - Ponto de Entrada utilizado para regravar os campos:
//--            TOTAL, VALOR_UNIT e QUANTIDADE
lCalcUni := If(lCalcUni == NIL,ExistBlock("A460UNIT"),lCalcUni)

//-- Cria Arquivo Temporario
If mv_par13 != 2
	aArqTemp := A460ArqTmp(1,@cKeyInd)
EndIf

//-- A460AMZP - Ponto de Entrada para considerar um armazen
//--            adicional como armazem de processo
If lA460AMZP
	aA460AMZP := ExecBlock("A460AMZP",.F.,.F.,'')
	If ValType(aA460AMZP) == "A" .And. Len(aA460AMZP) == 1
		cPeLocProc := IIf(Valtype(aA460AMZP[1]) == "C",aA460AMZP[1],'')
	EndIf	
EndIf

//-- Inicializa e atualiza o log de processamento
ProcLogIni( {},"MATR460" )
ProcLogAtu("INICIO")
ProcLogAtu("MENSAGEM",STR0045,STR0045) //"Iniciando impress�o do Registro de Inventario Modelo 7 "

//-- Processando Relatorio por Filiais
SM0->(dbSetOrder(1))
For nForFilial := 1 To Len( aFilsCalc )
	If aFilsCalc[nForFilial,1]
		//-- Muda Filial para processamento
		SM0->(dbSeek(cEmpAnt+aFilsCalc[nForFilial,2]))
		cFilAnt := aFilsCalc[nForFilial,2]

		//-- Se impressao consolidada
		If lConsolida
			//-- Seta dados do cabecalho:
			//-- 1. Quando imprimindo empresa da filial corrente, imprime com dados da filial logada
			//-- 2. Senao, imprime com dados da primeira filial da empresa
			If cFilAnt == cFilBack .Or. cQuebraCon == ""
				nPosFilCorr := nForFilial
			EndIf
			//-- Define quebra do consolidado como CNPJ + IE pois
			//-- Pois esta comecando uma nova empresa
			If Empty(cQuebraCon)
				cQuebraCon := Eval(bQuebraCon,nForFilial)
			EndIf
		EndIf
		
		//-- Zera o Array aTotal para que os totalizadores nao sejam acumulados no processamento de mais de uma filial
		aTotal := {}

		//-- Impressao dos Livros
		If mv_par13 != 2
			//-- Cria Indice de Trabalho para Poder de Terceiros
			#IFNDEF TOP
				If mv_par02 <> 2
					cIndSB6 := Substr(CriaTrab(NIL,.F.),1,7)+"T"
					cQuery := 'DtoS(B6_DTDIGIT) <= "' +DtoS(mv_par14) +'" .And. B6_PRODUTO >= "' +mv_par05 +'" .And. '
					cQuery += 'B6_PRODUTO <= "' +mv_par06 +'" .And. B6_LOCAL >= "' +cAlmoxIni +'" .And.'           

					cQuery += 'B6_LOCAL <= "'+cAlmoxFim+'"'

					IndRegua("SB6",cIndSB6,"B6_FILIAL+B6_PRODUTO+B6_TIPO+DTOS(B6_DTDIGIT)",,cQuery,STR0013)		//"Selecionando Poder Terceiros..."
					nIndSB6 := RetIndex("SB6")
					SB6->(dbSetIndex(cIndSB6+OrdBagExt()))
					SB6->(dbSetOrder(nIndSB6+1))
					SB6->(dbGoTop())
				EndIf
			#ENDIF
			
			//-- No consolidado, cria o arquivo somente uma vez (na primeira)
			//-- Ou sempre se MV_CUSFIL igual a F, pois tera que somar e unificar por filial
			If Empty(cArqTemp)
				//-- Cria Indice de Trabalho
				If FindFunction("FWOpenTemp") .And. GetBuild() >= "7.00.121227P-20130730"
					cArqTemp := CriaTrab(,.F.)
					FWOpenTemp(cArqTemp, aArqTemp, cArqTemp)
				Else
					cArqTemp := CriaTrab(aArqTemp)
					dbUseArea(.T.,,cArqTemp,cArqTemp,.T.,.F.)
				EndIf
				cIndTemp1 := Substr(CriaTrab(NIL,.F.),1,7)+"1"
				cIndTemp2 := Substr(CriaTrab(NIL,.F.),1,7)+"2"
				
				//-- Guarda nomes dos arquivos do consolidado para restaurar posteriormente
				If lCusConFil .And. (nForFilial == 1 .Or. Eval(bQuebraCon,nForFilial-1) # cQuebraCon)
					aArqCons[1] := cArqTemp
					aArqCons[2] := cIndTemp1
					aArqCons[3] := cIndTemp2
				EndIf

				//-- Criando Indice Temporario
				IndRegua(cArqTemp,cIndTemp1,cKeyInd,,,STR0014)				//"Indice Tempor�rio..."
				IndRegua(cArqTemp,cIndTemp2,"PRODUTO+SITUACAO",,,STR0014)	//"Indice Tempor�rio..."
				
				Set Cursor Off
				(cArqTemp)->(dbClearIndex())
				(cArqTemp)->(dbSetIndex(cIndTemp1+OrdBagExt()))
				(cArqTemp)->(dbSetIndex(cIndTemp2+OrdBagExt()))
			EndIf
			
			//-- Se empresa impressa for da filial logada, dados do cabe�alho ser� da filial logada
			If !lConsolida
				cFilCons := cFilAnt
			ElseIf (nPos := aScan(aFilsCalc,{|x| x[2] == cFilBack .And. x[1]})) > 0 .And. Eval(bQuebraCon,nPos) == Eval(bQuebraCon,nForFilial)
				cFilCons := aFilsCalc[nPos,2]
			//-- Se empresa impressa n�o for da filial logada, dados do cabe�alho ser� da primeira filial 
			Else
				nPos := aScan(aFilsCalc,{|x| x[4]+x[5] == Eval(bQuebraCon,nForFilial)})
				cFilCons := aFilsCalc[nPos,2] 	  
			EndIf
			
			//-- Filtragem do relatorio
			#IFDEF TOP
				//-- Transforma parametros Range em expressao SQL
				MakeSqlExpr(oReport:uParam)
				
				cAliasTop := GetNextAlias()
			
				//-- Query do relatorio da secao 1
				oReport:Section(1):BeginQuery()	

				If SB1->(FieldPos('B1_TIPOBN')) > 0 
					cSelect := "%"+IIf(lAgregOP,"SB1.B1_AGREGCU,","")+" SB1.B1_TIPOBN, %"
				Else
					cSelect := "%"+IIf(lAgregOP,"SB1.B1_AGREGCU, ","")+"%"
				EndIf	
				
			   	cJoin := "%"
				cJoin += IIf(mv_par07 == 1,"LEFT","") +" JOIN " +RetSqlName("SB2") + " SB2 ON "
				cJoin += "%"
			   
				BeginSql Alias cAliasTop
					SELECT SB1.B1_FILIAL, SB1.B1_COD, SB1.B1_TIPO, SB1.B1_POSIPI, SB1.B1_DESC, 
					       SB1.B1_UM, SB1.B1_PICM, SB1.B1_LOCPAD, SB2.B2_LOCAL, %Exp:cSelect%
					       SB2.B2_COD
						   
					FROM %table:SB1% SB1
					
					%Exp:cJoin%		
							SB2.%NotDel%						AND
							SB1.B1_FILIAL  =  %xFilial:SB1%	 	AND
							SB2.B2_FILIAL  =  %xFilial:SB2%	 	AND
							SB1.B1_COD     =  SB2.B2_COD       	AND 
							SB2.B2_LOCAL   >= %Exp:cAlmoxIni% 	AND
							SB2.B2_LOCAL   <= %Exp:cAlmoxFim%
														
					WHERE   SB1.%NotDel% AND
							SB1.B1_FILIAL  =  %xFilial:SB1%	 	AND
       						SB1.B1_COD     >= %Exp:mv_par05% 	AND
							SB1.B1_COD     <= %Exp:mv_par06%       
							
	
					ORDER BY SB1.B1_FILIAL,SB1.B1_COD,SB1.B1_LOCPAD //-- FILIAL+PRODUTO+LOCAL							
				EndSql
				
				oReport:Section(1):EndQuery()
				
				nBarra := 0				
				(cAliasTop)->(dbEval({|| nBarra++}))									
				oReport:SetMeter(nBarra)
				(cAliasTop)->(dbGoTop())
			#ELSE
				//-- Transforma parametros Range em expressao Advpl
				MakeAdvplExpr(oReport:uParam)
			
				cCondicao := 'B1_FILIAL == "' +xFilial("SB1") +'".And.' 
				cCondicao += 'B1_COD >= "' +mv_par05 +'" .And. B1_COD <="' +mv_par06 +'"'
				
				oReport:Section(1):SetFilter(cCondicao,IndexKey())
				
				oReport:SetMeter(SB1->(LastRec()))
			#ENDIF		
	
			//-- Posiciona produto
			SB1->(dbSetOrder(1))
			
			oReport:SetMsgPrint(STR0041 +aFilsCalc[nForFilial,2] +" - " +aFilsCalc[nForFilial,3])
			
			#IFDEF TOP
			While !oReport:Cancel() .And. !(cAliasTop)->(EOF())
			#ELSE
			While !oReport:Cancel() .And. !SB1->(EOF()) .And. SB1->B1_FILIAL == xFilial("SB1") .And. SB1->B1_COD <= mv_par06
			#ENDIF
				If oReport:Cancel()
					Exit
				EndIf
			    
				oReport:IncMeter()
				lEnd := oReport:Cancel()
				
				#IFDEF TOP
					SB1->(dbSeek(xFilial("SB1")+(cAliasTop)->B1_COD))
				#ENDIF
				
				lTipoBN := .F.
				If SB1->(FieldPos('B1_TIPOBN')) > 0 
		 			lTipoBN := SB1->B1_TIPO == 'BN' .And. !Empty(SB1->B1_TIPOBN)
				EndIf	
			
				// Avalia se o Produto nao entrara no processamento
				If !R460AvalProd(SB1->B1_COD)
					#IFDEF TOP
						(cAliasTop)->(dbSkip())
					#ELSE
						SB1->(dbSkip())
					#ENDIF
					Loop
				EndIf

				//-- Alimenta Array com Saldo D = De Terceiros/ T = Em Terceiros
				If mv_par02 <> 2
					//-- Ponto de Entrada A460TESN3 criado para utilizacao do 8o.parametro da funcao
					//-- SALDOTERC (considera saldo Poder3 tambem c/ TES que NAO atualiza estoque)
					lSaldTesN3 := .F.
					If lA460TESN3
						lSaldTesN3 := ExecBlock("A460TESN3",.F.,.F.,{SB1->B1_COD,mv_par14})
						If ValType(lSaldTesN3) <> "L"
							lSaldTesN3 := .F.
						EndIf
					EndIf
			    	If mv_par02 == 1 .Or. mv_par02 == 3
						aSaldoTerD := SaldoTerc(SB1->B1_COD,cAlmoxIni,"D",mv_par14,cAlmoxFim,,SB1->B1_COD,lSaldTesN3,!mv_par17 == 1)
						If mv_par23 == 1 .And. !Empty(mv_par24)
							aAuxTer := SaldoTerc(SB1->B1_COD,cAlmoxIni,"D",mv_par14,cAlmoxFim,.T.,SB1->B1_COD,lSaldTesN3,!mv_par17 == 1)
							For nX := 1 To Len(aAuxTer)
								aAdd(aTerceiros,{"4",SubStr(aAuxTer[nX,1],nTPCF+nCLIFOR+nLOJA+1,nPRODUTO),SubStr(aAuxTer[nX,1],nTPCF+1,nCLIFOR),SubStr(aAuxTer[nX,1],nTPCF+nCLIFOR+1,nLOJA),aAuxTer[nX,2],aAuxTer[nX,3],aAuxTer[nX,4],SubStr(aAuxTer[nX,1],1,1)})
							Next nX	
						EndIf
					EndIf
			    	If mv_par02 == 1 .Or. mv_par02 == 4
						aSaldoTerT := SaldoTerc(SB1->B1_COD,cAlmoxIni,"T",mv_par14,cAlmoxFim,,SB1->B1_COD,lSaldTesN3,!mv_par17 == 1)
						If mv_par23 == 1 .And. !Empty(mv_par24)
							aAuxTer := SaldoTerc(SB1->B1_COD,cAlmoxIni,"T",mv_par14,cAlmoxFim,.T.,SB1->B1_COD,lSaldTesN3,!mv_par17 == 1)
							For nX := 1 to Len(aAuxTer)
								aAdd(aTerceiros,{"5",SubStr(aAuxTer[nX,1],nTPCF+nCLIFOR+nLOJA+1,nPRODUTO),SubStr(aAuxTer[nX,1],nTPCF+1,nCLIFOR),SubStr(aAuxTer[nX,1],nTPCF+nCLIFOR+1,nLOJA),aAuxTer[nX,2],aAuxTer[nX,3],aAuxTer[nX,4],SubStr(aAuxTer[nX,1],1,1)})
							Next nX	
						EndIf	
					EndIf
				EndIf
						
				//-- Busca Saldo em Estoque
				lFirst	  := .T.
				aSalAtu	  := {}
				aSaldo    := {0,0,0,0}
			
				//-- Posiciona na tabela de Saldos SB2
				#IFNDEF TOP
					SB2->(dbSetOrder(1))
					SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD+If(Empty(cAlmoxIni),"",cAlmoxIni),.T.))
				#ENDIF				
			
				If (cAliasTop)->(EOF()) .Or. SB1->B1_COD <> (cAliasTop)->B2_COD
					//-- Lista produtos sem movimentacao de estoque
					If mv_par07 == 1
						//-- So grava no consolidado caso nenhuma das filiais tenha saldo
						If lConsolida
							//-- Ve nas filiais ja processadas
							//-- Se custo unificado por filial, ve no arquivo consolidador
							If lCusConFil 
								(aArqCons[1])->(dbSetOrder(2))
								lGravaSit3 := !(aArqCons[1])->(dbSeek(SB1->B1_COD))
							//-- Se nao, olha no arquivo corrente (ja consolidado)
							Else
								(cArqTemp)->(dbSetOrder(2))
								lGravaSit3 := !(cArqTemp)->(dbSeek(SB1->B1_COD))
							EndIf
							
							//-- Ve nas filiais a processar
							If lGravaSit3
								SB2->(dbSetOrder(1))
								For i := nForFilial+1 To Len(aFilsCalc)
									If !(lGravaSit3 := !SB2->(dbSeek(xFilial("SB2",aFilsCalc[i,2])+SB1->B1_COD)))
										Exit
									EndIf
								Next i
							EndIf
						EndIf
					
						If lGravaSit3
							//-- TIPO 3 - PRODUTOS SEM SALDO
							RecLock(cArqTemp,.T.)
							(cArqTemp)->FILIAL		:= xFilial("SB2",cFilCons)
							(cArqTemp)->SITUACAO		:= "3"
							(cArqTemp)->TIPO			:= If(lTipoBN,SB1->B1_TIPOBN,SB1->B1_TIPO)
							(cArqTemp)->PRODUTO		:= SB1->B1_COD
							(cArqTemp)->POSIPI		:= SB1->B1_POSIPI
							(cArqTemp)->DESCRICAO	:= SB1->B1_DESC
							(cArqTemp)->UM		   	:= SB1->B1_UM
							(cArqTemp)->ARMAZEM 	:= IIF (empty((cAliasTop)->B2_LOCAL), (cAliasTop)->B1_LOCPAD, (cAliasTop)->B2_LOCAL)
							If nQuebraAliq == 2
								(cArqTemp)->ALIQ := SB1->B1_PICM
							ElseIf nQuebraAliq == 3
								(cArqTemp)->ALIQ := If(SB0->(MsSeek(xFilial("SB0")+SB1->B1_COD)),SB0->B0_ALIQRED,0)
							EndIf
							If mv_par22 == 1
								(cArqTemp)->SITTRIB := R460STrib(SB1->B1_COD)
							EndIf
							(cArqTemp)->(MsUnLock())
						EndIf
					EndIf
					
					#IFDEF TOP
						(cAliasTop)->(dbSkip())
					#ENDIF
				Else
					//-- Lista produtos com movimentacao de estoque
					#IFDEF TOP
					While !oReport:Cancel() .And. !(cAliasTop)->(EOF()) .And. (cAliasTop)->B1_COD == SB1->B1_COD
					#ELSE
					While !oReport:Cancel() .And. !(cAliasTop)->(EOF()) .And. SB2->(B2_FILIAL+B2_COD) == xFilial("SB2")+SB1->B1_COD .And. SB2->B2_LOCAL <= cAlmoxFim
						If !R460Local(SB2->B2_LOCAL)
							SB2->(dbSkip())
							Loop
						EndIf
					#ENDIF
			
						If oReport:Cancel()
							Exit
						EndIf	

						//-- Desconsidera almoxarifado de saldo em processo de mat.indiret
						//-- ou saldo em armazem de terceiros
						If (cAliasTop)->B2_LOCAL == cLocProc .Or.;
						   				(cAliasTop)->B2_LOCAL $ cLocTerc .Or.;
						   				(cAliasTop)->B2_LOCAL $ cPeLocProc
							(cAliasTop)->(dbSkip())
							Loop
						EndIf

                            //-- Retorna o Saldo Atual
						If mv_par17 == 1
							aSalatu := CalcEst(SB1->B1_COD,(cAliasTop)->B2_LOCAL,mv_par14+1,NIL)
						Else
							aSalAtu := CalcEstFF(SB1->B1_COD,(cAliasTop)->B2_LOCAL,mv_par14+1,NIL)		
						EndIf

						//-- TIPO 1 - EM ESTOQUE
						(cArqTemp)->(dbSetOrder(2))
						If (cArqTemp)->(dbSeek(SB1->B1_COD+"1"))
							RecLock(cArqTemp,.F.)
						Else
							RecLock(cArqTemp,.T.)
							lFirst:=.F.

							(cArqTemp)->FILIAL		:= xFilial("SB2",cFilCons)
							(cArqTemp)->SITUACAO		:= "1"
							(cArqTemp)->TIPO			:= If(lTipoBN,SB1->B1_TIPOBN,SB1->B1_TIPO)
							(cArqTemp)->POSIPI		:= SB1->B1_POSIPI
							(cArqTemp)->PRODUTO		:= SB1->B1_COD
							(cArqTemp)->DESCRICAO	:= SB1->B1_DESC
							(cArqTemp)->UM			:= SB1->B1_UM
							(cArqTemp)->ARMAZEM     := IIF (empty((cAliasTop)->B2_LOCAL), (cAliasTop)->B1_LOCPAD, (cAliasTop)->B2_LOCAL)
							If nQuebraAliq == 2
								(cArqTemp)->ALIQ := SB1->B1_PICM
							ElseIf nQuebraAliq == 3
								(cArqTemp)->ALIQ := If(SB0->(MsSeek(xFilial("SB0")+SB1->B1_COD)),SB0->B0_ALIQRED,0)
							EndIf
							If mv_par22 == 1
								(cArqTemp)->SITTRIB := R460STrib(SB1->B1_COD)
							EndIf
						EndIf
						(cArqTemp)->QUANTIDADE 	+= aSalAtu[01]
						(cArqTemp)->TOTAL			+= aSalAtu[02]
						If (cArqTemp)->QUANTIDADE > 0
							(cArqTemp)->VALOR_UNIT := (cArqTemp)->(NoRound(TOTAL/QUANTIDADE,nDecVal))
						EndIf
						
						//-- Este Ponto de Entrada foi criado para recalcular o Valor Unitario/Total
						If lCalcUni
							ExecBlock("A460UNIT",.F.,.F.,{SB1->B1_COD,(cAliasTop)->B2_LOCAL,mv_par14,cArqTemp})
						EndIf							

						(cArqTemp)->(MsUnLock())
						(cAliasTop)->(dbSkip())
					End

					//-- Pesquisa os valores de material de terceiros requisitados para OP
					aDadosCF9 := {0,0} // Quantidade e custo na 1a moeda para movimentos do SD3 com D3_CF RE9 ou DE9
					If lAgregOP .And. SB1->B1_AGREGCU == "1"
						aDadosCF9 := SaldoD3CF9(SB1->B1_COD,NIL,mv_par14,cAlmoxIni,cAlmoxFim)				
						If QtdComp(aDadosCF9[1]) > QtdComp(0) .Or. QtdComp(aDadosCF9[2]) > QtdComp(0)
							(cArqTemp)->(dbSetOrder(2))
							If (cArqTemp)->(dbSeek(SB1->B1_COD+"6"))
								RecLock(cArqTemp,.F.)
							Else
								RecLock(cArqTemp,.T.)
								lFirst:=.F.

								(cArqTemp)->FILIAL		:= xFilial("SB2",cFilCons)
								(cArqTemp)->SITUACAO		:= "6"
								(cArqTemp)->TIPO			:= If(lTipoBN,SB1->B1_TIPOBN,SB1->B1_TIPO)
								(cArqTemp)->POSIPI		:= SB1->B1_POSIPI
								(cArqTemp)->PRODUTO		:= SB1->B1_COD
								(cArqTemp)->DESCRICAO	:= SB1->B1_DESC
								(cArqTemp)->UM			:= SB1->B1_UM
								(cArqTemp)->ARMAZEM 	:= IIF (empty((cAliasTop)->B2_LOCAL), (cAliasTop)->B1_LOCPAD, (cAliasTop)->B2_LOCAL)
								If nQuebraAliq == 2
									(cArqTemp)->ALIQ := SB1->B1_PICM
								ElseIf nQuebraAliq == 3
									(cArqTemp)->ALIQ := If(SB0->(MsSeek(xFilial("SB0")+SB1->B1_COD)),SB0->B0_ALIQRED,0)
								EndIf
								If mv_par22 == 1
									(cArqTemp)->SITTRIB := R460STrib(SB1->B1_COD)
								EndIf
							EndIf
							(cArqTemp)->QUANTIDADE 	:= aDadosCF9[1]
							(cArqTemp)->TOTAL			:= aDadosCF9[2]
							//-- Recalcula valor unitario
							If (cArqTemp)->QUANTIDADE > 0
								(cArqTemp)->VALOR_UNIT := (cArqTemp)->(NoRound(TOTAL/QUANTIDADE,nDecVal))
							EndIf
							
							//-- Este Ponto de Entrada foi criado para recalcular o Valor Unitario/Total
							If lCalcUni
								ExecBlock("A460UNIT",.F.,.F.,{SB1->B1_COD,"",mv_par14,cArqTemp})
							EndIf

							(cArqTemp)->(MsUnLock())
						EndIf
					EndIf

					//-- Tratamento de poder de terceiros
					If mv_par02 <> 2 .And. SB1->B1_FILIAL == xFilial("SB1")
						//-- Pesquisa os valores D = De Terceiros na array aSaldoTerD
						nX := aScan(aSaldoTerD,{|x| x[1] == xFilial("SB6")+SB1->B1_COD})
						If !(nX == 0)
							aSaldo[1] := aSaldoTerD[nX][3]
							aSaldo[2] := aSaldoTerD[nX][4] 
							aSaldo[3] := aSaldoTerD[nX][5]
							If Len(aSaldoTerD[nX]) > 5
								aSaldo[4] := aSaldoTerD[nX][6]
							EndIf
						EndIf
						//-- Manipula arquivo de trabalho subtraindo do saldo em estoque saldo de terceiros
						(cArqTemp)->(dbSetOrder(2))
						If (cArqTemp)->(dbSeek(SB1->B1_COD+"1"))
							RecLock(cArqTemp,.F.)
						Else
							RecLock(cArqTemp,.T.)
							lFirst:=.F.

							(cArqTemp)->FILIAL		:= xFilial("SB2",cFilCons)
							(cArqTemp)->SITUACAO		:= "1"
							(cArqTemp)->TIPO			:= If(lTipoBN,SB1->B1_TIPOBN,SB1->B1_TIPO)
							(cArqTemp)->POSIPI		:= SB1->B1_POSIPI
							(cArqTemp)->PRODUTO		:= SB1->B1_COD
							(cArqTemp)->DESCRICAO	:= SB1->B1_DESC
							(cArqTemp)->UM			:= SB1->B1_UM
							(cArqTemp)->ARMAZEM 	:= IIF (empty((cAliasTop)->B2_LOCAL), (cAliasTop)->B1_LOCPAD, (cAliasTop)->B2_LOCAL)
							If nQuebraAliq == 2
								(cArqTemp)->ALIQ := SB1->B1_PICM
							ElseIf nQuebraAliq == 3
								(cArqTemp)->ALIQ := If(SB0->(MsSeek(xFilial("SB0")+SB1->B1_COD)),SB0->B0_ALIQRED,0)
							EndIf
							If mv_par22 == 1
								(cArqTemp)->SITTRIB := R460STrib(SB1->B1_COD)
							EndIf
						EndIf
						(cArqTemp)->QUANTIDADE 	-= aSaldo[01]
						(cArqTemp)->TOTAL			-= aSaldo[02]
				        If lSaldTesN3 .And. nSumQtTer == 1  // PE A460TESN3 = .T. e variavel nSumQtTer == 1 NAO subtrair TES F4_ESTOQUE = N
							(cArqTemp)->QUANTIDADE 	+= aSaldo[03]
							(cArqTemp)->TOTAL			+= If(Len(aSaldo) >3,aSaldo[4],0)
						EndIf
						
						//-- Pesquisa os valores de material de terceiros requisitados para OP
						If lAgregOP .And. SB1->B1_AGREGCU == "1"
							//-- Desconsidera do calculo do saldo em estoque movimentos RE9 e DE9
							If QtdComp(aDadosCF9[1]) > QtdComp(0) .Or. QtdComp(aDadosCF9[2]) > QtdComp(0)
								(cArqTemp)->QUANTIDADE 	+= aDadosCF9[1]
								(cArqTemp)->TOTAL			+= aDadosCF9[2]
							EndIf
						EndIf
						
						//-- Recalcula valor unitario
						If (cArqTemp)->QUANTIDADE > 0
							(cArqTemp)->VALOR_UNIT := (cArqTemp)->(NoRound(TOTAL/QUANTIDADE,nDecVal))
						EndIf  
												
						//-- Este Ponto de Entrada foi criado para recalcular o Valor Unitario/Total
						If lCalcUni
							ExecBlock("A460UNIT",.F.,.F.,{SB1->B1_COD,"",mv_par14,cArqTemp})
						EndIf
						(cArqTemp)->(MsUnLock())
					EndIf
				EndIf
								
				//-- Processa Saldo De Terceiro TIPO 4 - SALDO DE TERCEIROS
				R460Terceiros(aSaldoTerD,aSaldoTerT,@lEnd,cArqTemp,"4",aDadosCF9,cAliasTop,lTipoBN,cFilCons)

				//-- Processa Saldo Em Terceiro TIPO 5 - SALDO EM TERCEIROS
				R460Terceiros(aSaldoTerD,aSaldoTerT,@lEnd,cArqTemp,"5",NIL,cAliasTop,lTipoBN,cFilCons)
			    				
				#IFNDEF TOP
					SB1->(dbSkip())
				#ENDIF
			End
			
			lEnd := oReport:Cancel()
			
				U_R460EmProcessZ(@lEnd,cArqTemp,.T.,,,lTipoBN,cFilCons)
							
			//-- CUSTO UNIFICADO - Realiza acerto dos valores para todos tipos
			If lCusUnif .And. (!lConsolida .Or. lCusConFil .Or. nForFilial == Len(aFilsCalc))
				(cArqTemp)->(dbSetOrder(2))
				(cArqTemp)->(dbGotop())
				//-- Percorre arquivo
				While !(cArqTemp)->(EOF())
					cSeekUnif   := (cArqTemp)->PRODUTO
					aSeek       := {}
					nValTotUnif := 0
					nQtdTotUnif := 0
					While !(cArqTemp)->(EOF()) .And. cSeekUnif == (cArqTemp)->PRODUTO
						If oReport:Cancel()
							Exit
						EndIf
												
						If (!mv_par08 == 1 .And. (cArqTemp)->QUANTIDADE < 0) .Or.;
								(!mv_par09 == 1 .And. (cArqTemp)->QUANTIDADE == 0) .Or.;
								(!mv_par16 == 1 .And. (cArqTemp)->TOTAL == 0)
							(cArqTemp)->(dbSkip())
							Loop
			    		EndIf
			  			
						//-- Nao processar o saldo de/em terceiros aglutinado ao custo medio
						If !((cArqTemp)->SITUACAO $ "45")
							If l460UnProc
					  			aAdd(aSeek,(cArqTemp)->(Recno()))
								nValTotUnif += (cArqTemp)->TOTAL
								nQtdTotUnif += (cArqTemp)->QUANTIDADE
							ElseIf !((cArqTemp)->SITUACAO == "2")
								aAdd(aSeek,(cArqTemp)->(Recno()))
								nValTotUnif += (cArqTemp)->TOTAL
								nQtdTotUnif += (cArqTemp)->QUANTIDADE
							EndIf
						EndIf
						
						(cArqTemp)->(dbSkip())
					End
					                          
					If Len(aSeek) > 0
						// Calcula novo valor unitario
					  	For nx := 1 to Len(aSeek)
							If QtdComp(nQtdTotUnif) <> QtdComp(0)
								(cArqTemp)->(dbGoto(aSeek[nx]))
								RecLock(cArqTemp,.f.)
								(cArqTemp)->VALOR_UNIT := NoRound(nValTotUnif/nQtdTotUnif,nDecVal)
								(cArqTemp)->TOTAL      := (cArqTemp)->QUANTIDADE * (nValTotUnif/nQtdTotUnif)
								(cArqTemp)->(MsUnlock())
							EndIf	
						Next nx
						
						(cArqTemp)->(dbSkip())
					EndIf
				End
			EndIf
			
			//-- Se impressao consolidada por empresa (CNPJ + IE)
			If lConsolida
				//-- Se custo unificado por filial, devera agregar no arquivo consolidado
				//-- o agregado desta filial e deletar o arquivo desta filial
				If lCusConFil .And. cArqTemp # aArqCons[1]
					//-- Agrega filial no arquivo consolidado
					(cArqTemp)->(dbGoTop())
					(aArqCons[1])->(dbSetOrder(1))
					While !(cArqTemp)->(EOF())
						If (aArqCons[1])->(dbSeek((cArqTemp)->&((aArqCons[1])->(IndexKey()))))
							RecLock(aArqCons[1],.F.)
						Else
							RecLock(aArqCons[1],.T.)
							(aArqCons[1])->FILIAL 	:= (cArqTemp)->FILIAL
							(aArqCons[1])->SITUACAO	:= (cArqTemp)->SITUACAO
							(aArqCons[1])->TIPO 		:= (cArqTemp)->TIPO
							(aArqCons[1])->POSIPI 	:= (cArqTemp)->POSIPI
							(aArqCons[1])->PRODUTO 	:= (cArqTemp)->PRODUTO
							(aArqCons[1])->DESCRICAO	:= (cArqTemp)->DESCRICAO
							(aArqCons[1])->UM 		:= (cArqTemp)->UM
							(aArqCons[1])->ALIQ 		:= (cArqTemp)->ALIQ
							(aArqCons[1])->SITTRIB 	:= (cArqTemp)->SITTRIB
							(aArqCons[1])->ARMAZEM 	:= (cArqTemp)->ARMAZEM
						EndIf
						(aArqCons[1])->QUANTIDADE 	+= (cArqTemp)->QUANTIDADE
						(aArqCons[1])->TOTAL 			+= (cArqTemp)->TOTAL
						(aArqCons[1])->VALOR_UNIT 	:= (aArqCons[1])->TOTAL / (aArqCons[1])->QUANTIDADE
						(aArqCons[1])->(MsUnLock())
						
						(cArqTemp)->(dbSkip())
					End
					
					//-- Apaga arquivos temporarios
					If FindFunction("FWCLOSETEMP") .And. GetBuild() >= "7.00.121227P-20130730"
						FWCLOSETEMP(cArqTemp)
					Else
						Ferase(cArqTemp+GetDBExtension())
					EndIf				
					
					If Select(cArqTemp) > 0
						(cArqTemp)->(dbCloseArea())
					EndIf
					Ferase(cIndTemp1+OrdBagExt())
					Ferase(cIndTemp2+OrdBagExt())
					
					//-- Restaura variaveis de controle do arquivo temporario
					cArqTemp  := aArqCons[1]
					cIndTemp1 := aArqCons[2]
					cIndTemp2 := aArqCons[3]
				EndIf			
			
				//-- Se ainda nao consolidou todas, processara a proxima filial
				//-- zerando as variaveis de controle e realizando loop
				If nForFilial < Len(aFilsCalc) .And. cQuebraCon == Eval(bQuebraCon,nForFilial+1)
					#IFNDEF TOP
						If mv_par02 <> 2
							RetIndex("SB6")
							SB6->(dbClearFilter())
							Ferase(cIndSB6+OrdBagExt())
						EndIf
						SB1->(dbCloseArea())
				 	#ELSE
						(cAliasTop)->(dbCloseArea())
					#ENDIF
					
					If lCusConFil
						cArqTemp := ""
					EndIf
					
					Loop
				//-- Se impressao consolidada, muda filial para imprimir com os dados da filial consolidada
				Else
					SM0->(dbSeek(cEmpAnt+cFilCons))
					cFilAnt 	:= cFilCons										
					cQuebraCon	:= "" //-- Limpa variavel de controle da quebra para imprimir proxima empresa
					nForBkp	:= nForFilial //-- Guarda variavel do laco para restaura-la apos impressao
					nForFilial	:= aScan(aFilsCalc,{|x| x[2] == cFilCons}) //-- Seta variavel do laco para a filial dos dados do cabecalho
				EndIf
			EndIf
                			
			//-- Geracao do registro para Exportacao de dados (Sped Fiscal)
			If mv_par23 == 1 .And. !Empty(mv_par24)
				R460GrvTRB(aTerceiros,cArqTemp,aFilsCalc[nForFilial,2],@cFilP7)
			EndIf
			
			//-- Imprime Modelo P7
			(cArqTemp)->(dbSetOrder(1))
			(cArqTemp)->(dbGotop())
	
			//-- Flags de Impressao
			cSitAnt	  := "X"
			aSituacao := {STR0015,STR0016,STR0017,STR0018,STR0019,STR0034}		//" EM ESTOQUE "###" EM PROCESSO "###" SEM MOVIMENTACAO "###" DE TERCEIROS "###" EM TERCEIROS "
			cTipoAnt  := "XX"
			cQuebra   := ""
			
			While !oReport:Cancel() .And. !(cArqTemp)->(EOF())
				nLin    := 80
				cSitAnt := (cArqTemp)->SITUACAO
				lImpSit := .T.
			
				While !oReport:Cancel() .And. !(cArqTemp)->(Eof()) .And. cSitAnt == (cArqTemp)->SITUACAO
					cTipoAnt := (cArqTemp)->TIPO
					lImpTipo := .T.
			
					While !oReport:Cancel() .And. !(cArqTemp)->(Eof()) .And. cSitAnt+cTipoAnt == (cArqTemp)->(SITUACAO+TIPO)
						cPosIpi := (cArqTemp)->POSIPI
						nTotIpi := 0

						If mv_par22 == 1
							cSitTrib := (cArqTemp)->SITTRIB
							lImpST   := .T.
						EndIf
						
						If nQuebraAliq <> 1
							nAliq    := (cArqTemp)->ALIQ
							lImpAliq := .T.
						EndIf	
			
						If mv_par22 == 1
							cQuebra := cSitAnt+cTipoAnt+cSitTrib
							cKeyQbr := 'SITUACAO+TIPO+SITTRIB'
						Else
							cQuebra := IIf(nQuebraAliq == 1,cSitAnt+cTipoAnt+cPosIpi,cSitAnt+cTipoAnt+Str(nAliq,5,2))
							cKeyQbr := IIf(nQuebraAliq == 1,'SITUACAO+TIPO+POSIPI','SITUACAO+TIPO+Str(ALIQ,5,2)')
						EndIf
			
						While !oReport:Cancel() .And. !(cArqTemp)->(EOF()) .And. cQuebra == (cArqTemp)->&(cKeyQbr)
							If oReport:Cancel()
								Exit
							EndIf	
						    
							//-- Controla impressao de Produtos com saldo negativo ou zerado
							If (!mv_par08 == 1 .And. (cArqTemp)->QUANTIDADE < 0) .Or.;
									(!mv_par09 == 1 .And. (cArqTemp)->QUANTIDADE == 0) .Or.;
									(!mv_par16 == 1 .And. (cArqTemp)->TOTAL == 0)
								(cArqTemp)->(dbSkip())
								Loop
							Else
								nTotIpi += (cArqTemp)->TOTAL
								(cArqTemp)->(R460Acumula(aTotal))
							EndIf
							
							//-- Inicializa array com itens de impressao de acordo com MV_PAR15
							If mv_par15 == 1
								aImp:={	Alltrim((cArqTemp)->POSIPI),;
										(cArqTemp)->DESCRICAO,;
										(cArqTemp)->UM,;
										(cArqTemp)->(Transform(QUANTIDADE,IF(TamSX3("B2_QFIM")[2]>3,"@E 99,999,999.999",PesqPict("SB2", "B2_QFIM",14)))),;
										(cArqTemp)->(Transform(NoRound(TOTAL/QUANTIDADE,nDecVal),PesqPict("SB2", "B2_CM1",18))),;
										Transform((cArqTemp)->TOTAL,"@E 999,999,999,999.99" ),;
										Nil}
							Else
								aImp:={	Alltrim((cArqTemp)->POSIPI),;
										(cArqTemp)->(Padr(Alltrim(PRODUTO)+" - "+DESCRICAO,35)),;
										(cArqTemp)->UM,;
										Transform((cArqTemp)->QUANTIDADE,IF(TamSX3("B2_QFIM")[2]>3,"@E 99,999,999.999",PesqPict("SB2", "B2_QFIM",14))),;
										(cArqTemp)->(Transform(NoRound(TOTAL/QUANTIDADE,nDecVal),PesqPict("SB2", "B2_CM1",18))),;
										Transform((cArqTemp)->TOTAL,"@E 999,999,999,999.99"),;
										Nil}
							EndIf
							
							(cArqTemp)->(dbSkip())
			
							//-- Salta registros Zerados ou Negativos Conforme Parametros
							//-- Necessario Ajustar Posicao p/ Totalizacao de Grupos (POSIPI)
							While !oReport:Cancel() .And. !(cArqTemp)->(EOF()) .And. ((!mv_par08 == 1 .And. (cArqTemp)->QUANTIDADE < 0) .Or.;
																						(!mv_par09 == 1 .And. (cArqTemp)->QUANTIDADE == 0).Or.;
																						(!mv_par16 == 1 .And. (cArqTemp)->TOTAL == 0))
								(cArqTemp)->(dbSkip())
							End

							//-- Verifica se imprime total por POSIPI
							If cSitAnt+cTipoAnt+cPosIpi <> (cArqTemp)->(SITUACAO+TIPO+POSIPI) .And. nQuebraAliq == 1
								aImp[07] := Transform(nTotIPI,"@E 999,999,999,999.99")
							EndIf

							//-- Imprime cabecalho
							If nLin > 55
								R460Cabec(@nLin,@nPagina,.T.,oReport,aFilsCalc[nForFilial,3])
							EndIf
			
							If lImpSit
								FmtLinR4(oReport,{"",Padc(aSituacao[Val(cSitAnt)],35,"*"),"","","","",""},aL[15],,,@nLin)
								lImpSit := .F.
							EndIf
			
							If lImpTipo
								SX5->(dbSeek(xFilial("SX5")+"02"+cTipoAnt))
								FmtLinR4(oReport,Array(7),aL[15],,,@nLin)
								FmtLinR4(oReport,{"",Padc(" "+SUBSTR(TRIM(X5Descri()),1,26)+" ",35,"*"),"","","","",""},aL[15],,,@nLin)
								FmtLinR4(oReport,Array(7),aL[15],,,@nLin)
								lImpTipo := .F.
							EndIf

							If mv_par22 == 1 .And. lImpST
								FmtLinR4(oReport,{"",Padc(" "+STR0044+" "+cSitTrib+" ",35,"*"),"","","","",""},aL[15],,,@nLin)
								FmtLinR4(oReport,Array(7),aL[15],,,@nLin)
								lImpST := .F.
							EndIf
							
							If nQuebraAliq <> 1 .And. lImpAliq
								FmtLinR4(oReport,{"",Padc(" "+STR0031+Transform(nAliq,"@E 99.99%")+" ",35,"*"),"","","","",""},aL[15],,,@nLin)
								FmtLinR4(oReport,Array(7),aL[15],,,@nLin)
								lImpAliq := .F.
							EndIf	
			
							//-- Imprime linhas de detalhe de acordo com parametro (mv_par15)
							FmtLinR4(oReport,aImp,aL[15],,,@nLin)
			
							If nQuebraAliq <> 1 .And. cQuebra <> &(cKeyQbr)
								FmtLinR4(oReport,Array(7),aL[15],,,@nLin)
								nPos := aScan(aTotal,{|x| x[1] == cSitAnt .And. x[2] == cTipoAnt .And. x[6] == nAliq})
								FmtLinR4(oReport,{,STR0021+STR0031+Transform(nAliq,"@E 99.99%")+" ===>",,,,,Transform(aTotal[nPos,5], "@E 999,999,999,999.99")},aL[15],,,@nLin)			//"TOTAL "
								FmtLinR4(oReport,Array(7),aL[15],,,@nLin)
							EndIf
			
							If mv_par22 == 1 .And. cQuebra <> &(cKeyQbr)
								FmtLin(Array(7),aL[15],,,@nLin)
								nPos := aScan(aTotal,{|x| x[1] == cSitAnt .And. x[2] == cTipoAnt .And. x[6] == cSitTrib})
								FmtLinR4(oReport,{,STR0021+STR0044+" "+cSitTrib+" ===>",,,,,Transform(aTotal[nPos,5], "@E 999,999,999,999.99")},aL[15],,,@nLin)		//"TOTAL "
								FmtLinR4(oReport,Array(7),aL[15],,,@nLin)
			                EndIf
			
							If nLin >= 55
								R460EmBranco(@nLin,.T.,oReport)
							EndIf
						End
					End

					//-- Impressao de Totais
					nPos := aScan(aTotal,{|x| x[1] == cSitAnt .And. x[2] == cTipoAnt})
					If nPos # 0
						If nLin > 55
							R460Cabec(@nLin,@nPagina,.T.,oReport,aFilsCalc[nForFilial,3])
						EndIf
						R460Total(@nLin,aTotal,cSitAnt,cTipoAnt,aSituacao,@nPagina,.T.,oReport,aFilsCalc[nForFilial,3])
					EndIf
				End
			
				nPos := aScan(aTotal,{|x| x[1] == cSitAnt .And. x[2] == TT})
				If nPos # 0
					If nLin > 55
						R460Cabec(@nLin,@nPagina,.T.,oReport,aFilsCalc[nForFilial,3])
					EndIf
					R460Total(@nLin,aTotal,cSitAnt,TT,aSituacao,@nPagina,.T.,oReport,aFilsCalc[nForFilial,3])
					R460EmBranco(@nLin,.T.,oReport)
					lImpResumo:=.T.
				EndIf
			EndDo
			
			R460Cabec(@nLin,@nPagina,.T.,oReport,aFilsCalc[nForFilial,3])
			
			If lImpResumo
				R460Total(@nLin,aTotal,"T",TT,aSituacao,@nPagina,.T.,oReport,aFilsCalc[nForFilial,3])
			Else
				R460SemEst(@nLin,@nPagina,.T.,oReport)
			EndIf
			
			R460EmBranco(@nLin,.T.,oReport)
			
			//-- Apaga Arquivos Temporarios
			If FindFunction("FWCLOSETEMP") .And. GetBuild() >= "7.00.121227P-20130730"
				FWCLOSETEMP(cArqTemp)
			Else
				Ferase(cArqTemp+GetDBExtension())
			EndIf

			If Select(cArqTemp) > 0
				(cArqTemp)->(dbCloseArea())
			EndIf

			Ferase(cIndTemp1+OrdBagExt())
			Ferase(cIndTemp2+OrdBagExt())
					
			#IFNDEF TOP
				If mv_par02 <> 2
					RetIndex("SB6")
					SB6->(dbClearFilter())
					Ferase(cIndSB6+OrdBagExt())
				EndIf
				SB1->(dbCloseArea())
			#ELSE
				(cAliasTop)->(dbCloseArea())
			#ENDIF
										
			aTerceiros := {} //Zera array aTerceiros para evitar duplicidade na impress�o do Modelo P7
			
			cArqTemp := ""	//-- Criar� novo arquivo temporario para a nova impressao
			If !Empty(nForBkp) //-- Se impressao consolidada, retorna a variavel do laco de filiais
				nForFilial := nForBkp
				nForBkp := 0
			EndIf
					
		//-- Impressao dos Termos
		Else
			//-- Se impressao consolidada, s� imprime quando quebrar empresa
			If lConsolida .And. nForFilial < Len(aFilsCalc) .And. Eval(bQuebraCon,nForFilial) == Eval(bQuebraCon,nForFilial+1)
				Loop
			EndIf 
			cArqAbert := GetMv("MV_LMOD7AB")
			cArqEncer := GetMv("MV_LMOD7EN")
		
			//-- Posiciona na Empresa/Filial
			If SM0->M0_CODFIL # cFilAnt
				SM0->(dbSeek(cEmpAnt+cFilAnt))
			EndIf

			aVariaveis := {}
		
			For i := 1 To SM0->(FCount())
				If SM0->(FieldName(i)) == "M0_CGC"
					SM0->(aAdd(aVariaveis,{FieldName(i),Transform(FieldGet(i),"@R 99.999.999/9999-99")}))
				Else
					If SM0->(FieldName(i)) == "M0_NOME"
						Loop
					EndIf
					SM0->(aAdd(aVariaveis,{FieldName(i),FieldGet(i)}))
				EndIf
			Next
		
			SX1->(dbSeek(PADR("MTR46Z",nTamSX1)+"01"))			
			While SX1->X1_GRUPO == PADR("MTR46Z",nTamSX1)
				SX1->(aAdd(aVariaveis,{Rtrim(Upper(X1_VAR01)),&(X1_VAR01)}))
				SX1->(dbSkip())
			End

			If AliasIndic("CVB")
				CVB->(dbSeek(xFilial("CVB")))
				For i := 1 To CVB->(FCount())
					If CVB->(FieldName(i)) == "CVB_CGC"
						CVB->(aAdd(aVariaveis,{FieldName(i),Transform(FieldGet(i),"@R 99.999.999/9999-99")}))
					ElseIf CVB->(FieldName(i)) == "CVB_CPF"
						CVB->(aAdd(aVariaveis,{FieldName(i),Transform(FieldGet(i),"@R 999.999.999-99")}))
					Else
						CVB->(aAdd(aVariaveis,{FieldName(i),FieldGet(i)}))
					EndIf
				Next i
			EndIf
		
			aAdd(aVariaveis,{"M_DIA",StrZero(Day(dDataBase),2)})
			aAdd(aVariaveis,{"M_MES",MesExtenso()})
			aAdd(aVariaveis,{"M_ANO",StrZero(Year(dDataBase),4)})
		
			cDriver := aDriver[4]
		    oReport:HideHeader()
			If cArqAbert # NIL
				oReport:EndPage()
				ImpTerm(cArqAbert,aVariaveis,&cDriver,,,.T.,oReport)
			EndIf
		
			If cArqEncer # NIL
				oReport:EndPage()
				ImpTerm(cArqEncer,aVariaveis,&cDriver,,,.T.,oReport)
			EndIf
		EndIf
	EndIf	
Next nForFilial

If Select("TRB") > 0 
	TRB->(dbCloseArea())
EndIf	

SM0->(dbSeek(cEmpAnt+cFilBack))
cFilAnt := cFilBack

//-- Atualiza o log de processamento
ProcLogAtu("MENSAGEM",STR0046,STR0046) //"Processamento Encerrado"
ProcLogAtu("FIM")

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MATR460RZ � Autor � Juan Jose Pereira     � Data � 07.11.96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio do Inventario, Registro Modelo P7                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function MATR460RZ()
Local wnrel		:= NIL

Local Titulo		:= STR0001	//"Registro de Invent�rio - Modelo P7"
Local cDesc1		:= STR0002	//"Emiss�o do Registro de Invent�rio.Os Valores Totais serao impressos conforme Modelo Legal"
Local cDesc2		:= ""
Local cDesc3		:= ""
Local cString		:= "SB1"
Local NomeProg		:= "MATR460"
Local cArqTemp		:= ""
Local cIndTemp1	:= ""
Local cIndTemp2	:= ""
Local cKeyInd		:= ""
Local cFilBack		:= cFilAnt
Local cFilCons		:= cFilAnt
Local Tamanho		:= "M"

Local nForFilial	:= 0
Local nPos			:= 0

Local aSave		:= GetArea()
Local aArqTemp		:= {}
Local aFilsCalc	:= {}
Local aArqCons		:= Array(3)

Local lImprime		:= .T.
Local lCusConFil	:= .F.
Local lImpSX1		:= .T.
Local lConsolida	:= .F.

Local bQuebraCon	:= {|x| aFilsCalc[x,4]+aFilsCalc[x,5]} //-- Bloco que define a chave de quebra

Private aReturn	:= {STR0005,1,STR0006,2,2,1,"",1}	//"Zebrado"###"Administra��o"
Private nLastKey	:= 0
Private nTipo		:= 0

//-- Funcao utilizada para verificar a ultima versao do fonte
//-- SIGACUSA.PRX aplicados no rpo do cliente, assim verificando
//-- a necessidade de uma atualizacao nestes fontes. NAO REMOVER !!!
If !(FindFunction("SIGACUS_V")	.And. SIGACUS_V() >= 20060810)
    Final(STR0040 +" SIGACUS.PRW !!!") // "Atualizar SIGACUS.PRW"
EndIf
If !(FindFunction("SIGACUSA_V")	.And. SIGACUSA_V() >= 20060321)
    Final(STR0040 +" SIGACUSA.PRX !!!") // "Atualizar SIGACUSA.PRX"
EndIf

//-- Chama pergunte e cria variaveis de controle
Pergunte("MTR46Z",.F.)
cAlmoxIni	:= IIf(mv_par03 == "**",Space(02),mv_par03)
cAlmoxFim	:= IIf(mv_par04 == "**","ZZ",mv_par04)
nQtdPag	:= mv_par11
cNrLivro	:= mv_par12
nQuebraAliq := IIf(mv_par22 == 1,1,mv_par19)
lConsolida	:= mv_par21 == 1 .And. mv_par25 == 1
lCusConFil	:= lConsolida .And. SuperGetMv('MV_CUSFIL',.F.,"A") == "F" //-- Impressao consolidada e com custo unificado por filial

//-- Envia controle para a funcao SETPRINT
wnrel := SetPrint(cString,NomeProg,"MTR46Z",@titulo,cDesc1,cDesc2,cDesc3,.F.,,.T.,Tamanho)

//-- Cria Arquivo Temporario
If mv_par13 == 1
	aArqTemp := A460ArqTmp(1,@cKeyInd)
EndIf

If nLastKey <> 27
	SetDefault(aReturn,cString)
	
	//-- Janela de Selecao de Filiais
	aFilsCalc := MatFilCalc(mv_par21 == 1,,,lConsolida)
	
	//--Processando Relatorio por Filiais
	SM0->(dbSetOrder(1))
	For nForFilial := 1 To Len(aFilsCalc)
		If aFilsCalc[nForFilial,1]
			//-- Muda Filial para processamento
			SM0->(dbSeek(cEmpAnt+aFilsCalc[nForFilial,2]))
			cFilAnt  := aFilsCalc[nForFilial,2]

			//-- Impressao dos livros
			If mv_par13 == 1
				//-- Variavel para controlar a aglutinacao do consolidado
				lImprime := !lConsolida .Or.; 											//-- Nao consolidado
							Len(aFilsCalc) == 1 .Or. Len(aFilsCalc) == nForFilial .Or.;	//-- Somente uma filial ou a ultima
							Eval(bQuebraCon,nForFilial) # Eval(bQuebraCon,nForFilial+1)		//-- Quebrou
	
				//-- No consolidado, cria o arquivo somente uma vez (na primeira)
				//-- Ou sempre se MV_CUSFIL igual a F, pois tera que somar e unificar por filial
				If Empty(cArqTemp)
					//-- Cria Indice de Trabalho
					If FindFunction("FWOpenTemp") .And. GetBuild() >= "7.00.121227P-20130730"
						cArqTemp := CriaTrab(,.F.)
						FWOpenTemp(cArqTemp, aArqTemp, cArqTemp)
					Else
						cArqTemp :=CriaTrab(aArqTemp)
						dbUseArea(.T.,,cArqTemp,cArqTemp,.T.,.F.)
					EndIf
					cIndTemp1 := Substr(CriaTrab(NIL,.F.),1,7)+"1"
					cIndTemp2 := Substr(CriaTrab(NIL,.F.),1,7)+"2"
					
					//-- Guarda nomes dos arquivos do consolidado para restaurar posteriormente
					If lCusConFil .And. (nForFilial == 1 .Or. Eval(bQuebraCon,nForFilial) # Eval(bQuebraCon,nForFilial-1))
						aArqCons[1] := cArqTemp
						aArqCons[2] := cIndTemp1
						aArqCons[3] := cIndTemp2
					EndIf
	
					//-- Criando Indice Temporario
					IndRegua(cArqTemp,cIndTemp1,cKeyInd,,,STR0014)				//"Indice Tempor�rio..."
					IndRegua(cArqTemp,cIndTemp2,"PRODUTO+SITUACAO",,,STR0014)	//"Indice Tempor�rio..."
					
					Set Cursor Off
					(cArqTemp)->(dbClearIndex())
					(cArqTemp)->(dbSetIndex(cIndTemp1+OrdBagExt()))
					(cArqTemp)->(dbSetIndex(cIndTemp2+OrdBagExt()))
				EndIf
				
				If !lConsolida
					cFilCons := cFilAnt //-- Impress�o n�o consolidada o cabe�alho ser� por filial
				ElseIf (nPos := aScan(aFilsCalc,{|x| x[2] == cFilBack .And. x[1]})) > 0 .And. Eval(bQuebraCon,nPos) == Eval(bQuebraCon,nForFilial)
					cFilCons := aFilsCalc[nPos,2]	//-- Se empresa impressa for da filial logada, dados do cabe�alho ser� da filial logada 
				Else
					nPos := aScan(aFilsCalc,{|x| x[4]+x[5] == Eval(bQuebraCon,nForFilial)})
					cFilCons := aFilsCalc[nPos,2] 	//-- Se empresa impressa n�o for da filial logada, dados do cabe�alho ser� da primeira filial  
				EndIf
							
				RptStatus({|lEnd| U_R460Impz(@lEnd,wnRel,cString,Tamanho,aFilsCalc,cArqTemp,lImprime,lImpSX1,cFilCons,aArqCons,nForFilial,cIndTemp1,cIndTemp2)},Titulo,STR0041 +aFilsCalc[nForFilial,2] +" - " +aFilsCalc[nForFilial,3])
				
				//-- Se imprimiu
				If lImprime
					lImpSX1 := .F. //-- Para imprimir somente um vez o grupo de perguntas
					
					//-- Se imprimiu empresa, apaga arquivo temporario
					If !lCusConFil .Or. nForFilial == Len(aFilsCalc) .Or.;
								Eval(bQuebraCon,nForFilial) # Eval(bQuebraCon,nForFilial+1)
						If FindFunction("FWCLOSETEMP") .And. GetBuild() >= "7.00.121227P-20130730"
							FWCLOSETEMP(cArqTemp)
						Else
							Ferase(cArqTemp+GetDBExtension())
						EndIf				
						
						If Select(cArqTemp) > 0
							(cArqTemp)->(dbCloseArea())
						EndIf	
						
						Ferase(cIndTemp1+OrdBagExt())
						Ferase(cIndTemp2+OrdBagExt())
					EndIf
				EndIf
	
				If !lConsolida .Or. lCusConFil .Or. nForFilial == Len(aFilsCalc) .Or.; 	//-- Nao consolidada ou custo por filial
							Eval(bQuebraCon,nForFilial) # Eval(bQuebraCon,nForFilial+1) 	//-- Quebrou
					cArqTemp := ""
				EndIf				
			//-- Se impressao consolidada, s� imprime termos quando quebrar empresa
			ElseIf !lConsolida .Or. nForFilial == Len(aFilsCalc) .Or. Eval(bQuebraCon,nForFilial) # Eval(bQuebraCon,nForFilial+1)
				RptStatus({|lEnd| R460Term(@lEnd,wnRel,cString,Tamanho)},Titulo,STR0041+aFilsCalc[nForFilial,2] +" - " +aFilsCalc[nForFilial,3])
			EndIf
		EndIf
	Next nForFilial

	//-- Fecha tabela temporaria TRB
   	If Select("TRB") > 0 
		TRB->(dbCloseArea())
	EndIf   

	If aReturn[5] == 1
		Set Printer To
		dbCommitAll()
		OurSpool(wnrel)
	EndIf
		
	MS_FLUSH()
	
	SM0->(dbSeek(cEmpAnt+cFilBack))
	cFilAnt := cFilBack //-- Restaura Filial Original	
	RestArea(aSave) //-- Restaura ambiente
EndIf

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �R460LayOut� Autor � Juan Jose Pereira     � Data � 07.11.96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Lay-Out do Modelo P7                                        ���
�������������������������������������������������������������������������Ĵ��
��� Retorno  �aL - Array com layout do cabecalho do relatorio             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR460                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function R460LayOut(lGraph)
Local lImp	:= GetNewPar("MV_IMPCABE",.F.)
Local aL	:= Array(16)

DEFAULT lGraph := .F.

aL[01]:=				  "+----------------------------------------------------------------------------------------------------------------------------------+"
If lImp
	aL[02]:=STR0043 	//"|                                                     REGISTRO DE INVENT�RIO  - P7                                                 |"
Else
	aL[02]:=STR0007		//"|                                                     REGISTRO DE INVENT�RIO                                                       |"
EndIf
aL[03]:=				  "|                                                                                                                                  |"
aL[04]:=STR0039			//"| FIRMA:#########################################     FILIAL: ###############                                                      |"
aL[05]:=				  "|                                                                                                                                  |"
If cPaisLoc == "CHI"
	aL[06]:=STR0029		//"|                               RUT :       ################################                                                       |"
Else
	aL[06]:=STR0009		//"| INSC.EST.: ################   C.N.P.J.  : ################################                                                       |"
EndIf
aL[07]:=				  "|                                                                                                                                  |"
aL[08]:=STR0010			//"| FOLHA: #######                ESTOQUES EXISTENTES EM: ##########                                                                 |"
aL[09]:=				  "|                                                                                                                                  |"
aL[10]:=				  "|----------------------------------------------------------------------------------------------------------------------------------|"
If ( cPaisLoc=="BRA" )
	aL[11]:=STR0025		//"|             |                                      |    |              |                        VALORES                          |"
	aL[12]:=STR0011		//"|CLASSIFICA��O|                                      |    |              |-------------------------------------+-------------------|"
	aL[13]:=STR0012		//"|    FISCAL   |     D I S C R I M I N A � � O        |UNID|  QUANTIDADE  |     UNIT�RIO     |     PARCIAL      |      TOTAL        |"
	aL[14]:=			  "|-------------+--------------------------------------+----+--------------+------------------+------------------+-------------------|"
	aL[15]:=			  "|#############| #####################################| ## |##############|##################|##################|###################|"
Else
	aL[11]:=STR0028		//"|                                                    |    |              |                        VALORES                          |"
	aL[12]:=STR0026		//"|                                                    |    |              |-------------------------------------+-------------------|"
	aL[13]:=STR0027		//"|                   DESCRI��O                        |UNID|  QUANTIDADE  |     UNIT�RIO     |     PARCIAL      |      TOTAL        |"
	aL[14]:=			  "|----------------------------------------------------+----+--------------+------------------+------------------+-------------------|"
	aL[15]:=			  "| # ################################################ | ## |##############|##################|##################|###################|"
EndIf
aL[16]:=				  "+----------------------------------------------------------------------------------------------------------------------------------+"
//		 			      0123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x12
//    	                            1         2         3         4         5         6         7         8         9         10        11        12        13
Return (aL)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � R460ImpZ  � Autor � Juan Jose Pereira     � Data � 07.11.96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao do Modelo P7                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd    - variavel que indica se processo foi interrompido ���
���          � wnrel   - nome do arquivo a ser impresso                   ���
���          � cString - tabela sobre a qual o filtro do relatorio sera   ���
���          � executado                                                  ���
���          � tamanho - tamanho configurado para o relatorio             ���
���          � aFilsCalc - array com as filiais processadas				  	 ���
���          � lImpSX1  - Indica se deve imprimir o grupo de perguntas	 ���
���          � lImprime - Indica se deve imprimir ou somente acumular	  	 ���
���          � cFilCons - Codigo da filial consolidadora 					 ���
���          � aArqCons - Array com os dados do arquivo consolidado		 ��� 
���          � nForFilial - posicao da filial que esta sendo impressa		 ���
���          � cIndTemp1 - arquivo do indice temporario.					 ���
���          � cIndTemp2 - arquivo do indice temporario.					 ��� 
�������������������������������������������������������������������������Ĵ��
��� Retorno  � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR460                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function R460Impz(lEnd,wnRel,cString,tamanho,aFilsCalc,cArqTemp,lImprime,lImpSX1,cFilCons,aArqCons,nForFilial,cIndTemp1,cIndTemp2)
Static lCalcUni	:= .F.
Static cFilUsrSB1	:= ""

Local cPeLocProc	:= ""
Local cPosIpi		:= ""
Local cQuery		:= ""
Local cLeft		:= ""
Local cNameIdx		:= ""
Local cSeekUnif	:= ""
Local cNomeArq		:= ""
Local cIndSB6		:= ""
Local cKeyQbr		:= ""
Local cAliasTop	:= "SB2"
Local cLocTerc		:= SuperGetMV("MV_ALMTERC",.F.,"")
Local cLocProc		:= SuperGetMv("MV_LOCPROC",.F.,"99")

Local aA460AMZP	:= {}
Local aSalAtu		:= {}
Local aTotal		:= {}
Local aImp			:= {}
Local aSeek		:= {}
Local aTerceiros	:= {}
Local aAuxTer		:= {}
Local aSaldoTerD  := {}
Local aSaldoTerT  := {}
Local aSaldo		:= {0,0,0,0}
Local aL			:= R460LayOut(.F.)
Local aDadosCF9   := {0,0}

Local nLin			:= 80
Local nTotIpi		:= 0
Local nPos			:= 0
Local nX			:= 0
Local nValTotUnif	:= 0
Local nQtdTotUnif	:= 0
Local nIndSB6		:= 0
Local nFilCabec	:= 0
Local nBarra		:= 0
Local nTPCF		:= TamSX3("B6_TPCF")[1]
Local nCLIFOR		:= TamSX3("B6_CLIFOR")[1]
Local nLOJA		:= TamSX3("B6_LOJA")[1]
Local nPRODUTO		:= TamSX3("B6_PRODUTO")[1]
Local nPagina		:= mv_par10
Local nTpProcesso	:= SuperGetMV("MV_R460PRC",.F.,1)

Local lConsolida	:= mv_par21 == 1 .And. mv_par25 == 1
Local lEmBranco	:= .F.
Local lImpResumo  := .F.
Local lImpAliq		:= .F.
Local lSaldTesN3  := .F.
Local lTipoBN		:= .F.
Local lFirst		:= .T.
Local lCusFIFO		:= SuperGetMV("MV_CUSFIFO",.F.,.F.)
Local lAgregOP    := SB1->(FieldPos("B1_AGREGCU")) > 0 
Local lA460AMZP   := ExistBlock("A460AMZP")
Local lA460TESN3  := ExistBlock("A460TESN3")
Local lImpSit		:= .F.
Local lImpTipo		:= .F.
Local lCusUnif		:= IIf(FindFunction("A330CusFil"),A330CusFil(),GetMV("MV_CUSFIL",.F.)) //-- Verifica se utiliza custo unificado por Empresa/Filial
Local lCusConFil	:= lConsolida .And. SuperGetMv('MV_CUSFIL',.F.,"A") == "F" //-- Impressao consolidada e com custo unificado por filial
Local lGravaSit3	:= .T.

Local bQuebraCon	:= {|x| aFilsCalc[x,4]+aFilsCalc[x,5]} //-- Bloco que define a chave de quebra

Private m_pag		:= 1  // Controla impressao manual do cabecalho  
Private nSumQtTer	:= 0  // variavel opcional para o PE A460TESN3

//-- A460AMZP - Ponto de Entrada para considerar um armazen
//--            adicional como armazem de processo
If lA460AMZP
	aA460AMZP := ExecBlock("A460AMZP",.F.,.F.,'')
	If ValType(aA460AMZP)=="A" .And. Len(aA460AMZP) == 1
		cPeLocProc := IIf(Valtype(aA460AMZP[1])=="C",aA460AMZP[1],'')
	EndIf	
EndIf

//-- A460UNIT - Ponto de Entrada utilizado para regravar os campos:
//--            TOTAL, VALOR_UNIT e QUANTIDADE
lCalcUni := If(lCalcUni == Nil,ExistBlock("A460UNIT"),lCalcUni)

cFilUsrSB1 := aReturn[7]

//-- Atualiza o log de processamento
ProcLogIni( {},"MATR460" )
ProcLogAtu("INICIO")
ProcLogAtu("MENSAGEM",STR0045,STR0045) //"Iniciando impress�o do Registro de Inventario Modelo 7 "

SB1->(dbSetOrder(1))

//-- Cria Indice de Trabalho para Poder de Terceiros
#IFNDEF TOP
	If mv_par02 <> 2
		cIndSB6 := Substr(CriaTrab(Nil,.F.),1,7)+"T"
		cQuery := 'DtoS(B6_DTDIGIT)<="'+DtoS(mv_par14)+'".And.B6_PRODUTO>="'+mv_par05+'".And.B6_PRODUTO<="'+mv_par06+'".And.B6_LOCAL>="'+cAlmoxIni+'".And.B6_LOCAL<="'+cAlmoxFim+'"'
		IndRegua("SB6",cIndSB6,"B6_FILIAL+B6_PRODUTO+B6_TIPO+DTOS(B6_DTDIGIT)",,cQuery,STR0013)		//"Selecionando Poder Terceiros..."
		nIndSB6 := RetIndex("SB6")
		SB6->(dbSetIndex(cIndSB6+OrdBagExt()))
		SB6->(dbSetOrder(nIndSB6+1))
		SB6->(dbGoTop())
	EndIf
#ELSE
	cAliasTop := CriaTrab(Nil,.F.)

	//-- Tratamento especial feito para ORACLE versao 8 ou inferior, pois nestas
	//-- versoes, nao sao aceitas clausulas como 'LEFT JOIN', 'JOIN', etc ...
	If (Upper(TcGetDB()) == "ORACLE" .And. GetOracleVersion() <= 8)
		cLeft := ""
		
		If mv_par07 == 1 // Lista produtos sem movimentacao
		   cLeft := "(+)"
		EndIf		 

		cQuery := "SELECT SB1.B1_FILIAL, SB1.B1_COD, SB1.B1_TIPO, SB1.B1_POSIPI, SB1.B1_DESC, "
		cQuery += "SB1.B1_UM, SB1.B1_PICM, SB1.B1_LOCPAD, " +IIf(SB1->(FieldPos("B1_TIPOBN")) > 0,"SB1.B1_TIPOBN,","")
		cQuery += "SB2.B2_LOCAL, " +IIf(lAgregOP,"SB1.B1_AGREGCU, ","") +A285QryFil("SB1",cQuery,aReturn[7])
		cQuery += "SB2.B2_COD "
		
		cQuery += "FROM " + RetSqlName("SB1") + " SB1, " +RetSqlName("SB2") + " SB2 "
	
		cQuery += "WHERE SB1.B1_COD >= '"  +mv_par05 +"' AND SB1.B1_COD <= '" +mv_par06+"' ""
		cQuery += "AND SB1.B1_FILIAL = '" +xFilial("SB1") +"' AND SB2.B2_FILIAL" +cLeft +" = '" +xFilial("SB2")+"' "
		cQuery += "AND SB1.B1_COD >= '" +mv_par05 +"' AND SB1.B1_COD <= '" +mv_par06 +"' "
		cQuery += "AND SB2.B2_LOCAL" +cLeft + " >= '" +cAlmoxIni +"' AND SB2.B2_LOCAL" +cLeft +" <= '"+cAlmoxFim +"' "
		cQuery += "AND SB1.B1_COD = SB2.B2_COD" +cLeft +" AND SB1.D_E_L_E_T_ <> '*' AND SB2.D_E_L_E_T_ <> '*' "

		cQuery += "ORDER BY SB1.B1_FILIAL,SB1.B1_COD,SB1.B1_LOCPAD"	//FILIAL+PRODUTO+LOCAL
	Else
		cQuery := "SELECT SB1.B1_FILIAL, SB1.B1_COD, SB1.B1_TIPO, SB1.B1_POSIPI, "
		cQuery += "SB1.B1_DESC, SB1.B1_UM, SB1.B1_PICM, SB1.B1_LOCPAD, "
		cQuery += IIf(SB1->(FieldPos("B1_TIPOBN")) > 0,"SB1.B1_TIPOBN,","")
 		cQuery += "SB2.B2_LOCAL, " +IIf(lAgregOP,"SB1.B1_AGREGCU, ","")
		cQuery += A285QryFil("SB1",cQuery,aReturn[7])
		cQuery += "SB2.B2_COD "
		cQuery += "FROM " +RetSqlName("SB1") +" SB1 "
		cQuery += IIf(mv_par07 == 1,"LEFT","") +" JOIN " +RetSqlName("SB2") +" SB2 ON "
		cQuery += "SB2.B2_FILIAL = '" + xFilial("SB2") +"' AND SB2.D_E_L_E_T_ <> '*' "
		cQuery += "AND SB1.B1_COD = SB2.B2_COD AND SB2.B2_LOCAL >= '" +cAlmoxIni +"' "
		cQuery += "AND SB2.B2_LOCAL <= '" +cAlmoxFim +"' "
		cQuery += "WHERE SB1.B1_FILIAL = '" +xFilial("SB1") +"' AND SB1.D_E_L_E_T_ <> '*' "
		cQuery += "AND SB1.B1_COD >= '" +mv_par05 +"' AND SB1.B1_COD <= '" +mv_par06 +"' "
		cQuery += "ORDER BY SB1.B1_FILIAL,SB1.B1_COD,SB1.B1_LOCPAD"	//FILIAL+PRODUTO+LOCAL
	EndIf	

	cQuery := ChangeQuery(cQuery)
	MsAguarde({|| dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasTop,.F.,.T.)},STR0033)

	(cAliasTop)->(dbEval({|| nBarra++}))
	SetRegua(nBarra)
	(cAliasTop)->(dbGoTop())
#ELSE
	SB1->(dbSeek(xFilial("SB1")+mv_par05,.T.))
	SB1->(SetRegua(LastRec()))
#ENDIF

//-- Processando Arquivo de Trabalho
#IFDEF TOP
While !lEnd .And. !(cAliasTop)->(EOF())
	SB1->(dbSeek(xFilial("SB1")+(cAliasTop)->B1_COD))
#ELSE
While !lEnd .And. !SB1->(EOF()) .And. SB1->B1_FILIAL == xFilial("SB1") .And. SB1->B1_COD <= mv_par06
#ENDIF
	IncRegua()
	
	If Interrupcao(@lEnd)
		Exit
	EndIf

	lTipoBN := .F.
	If SB1->(FieldPos('B1_TIPOBN')) > 0 
		lTipoBN := SB1->B1_TIPO == 'BN' .And. !Empty(SB1->B1_TIPOBN)
	EndIf	
	
	// Avalia se o Produto nao entrara no processamento
	If !R460AvalProd(SB1->B1_COD)
		#IFDEF TOP
			(cAliasTop)->(dbSkip())
		#ELSE
			SB1->(dbSkip())
		#ENDIF
		Loop
	EndIf

	//-- Alimenta Array com Saldo D = De Terceiros/ T = Em Terceiros
	If mv_par02 <> 2
		//-- Ponto de Entrada A460TESN3 criado para utilizacao do 8o.parametro da funcao
		//-- SALDOTERC (considera saldo Poder3 tambem c/ TES que NAO atualiza estoque)
		lSaldTesN3 := .F.
		If lA460TESN3
			lSaldTesN3 := ExecBlock("A460TESN3",.F.,.F.,{SB1->B1_COD,mv_par14})
			If ValType(lSaldTesN3) <> "L"
				lSaldTesN3 := .F.
			EndIf
		EndIf
    	If mv_par02 == 1 .Or. mv_par02 == 3
			aSaldoTerD   := SaldoTerc(SB1->B1_COD,cAlmoxIni,"D",mv_par14,cAlmoxFim,,SB1->B1_COD,lSaldTesN3,!mv_par17 == 1)
			If mv_par23 == 1 .And. !Empty(mv_par24)
				aAuxTer  := SaldoTerc(SB1->B1_COD,cAlmoxIni,"D",mv_par14,cAlmoxFim,.T.,SB1->B1_COD,lSaldTesN3,!mv_par17 == 1)
				For nX := 1 to Len(aAuxTer)
					aAdd(aTerceiros,{"4",SubStr(aAuxTer[nX,1],nTPCF+nCLIFOR+nLOJA+1,nPRODUTO),SubStr(aAuxTer[nX,1],nTPCF+1,nCLIFOR),SubStr(aAuxTer[nX,1],nTPCF+nCLIFOR+1,nLOJA),aAuxTer[nX,2],aAuxTer[nX,3],aAuxTer[nX,4],SubStr(aAuxTer[nX,1],1,1)})
				Next nX	
			EndIf
    	EndIf
    	If mv_par02 == 1 .Or. mv_par02 == 4
			aSaldoTerT   := SaldoTerc(SB1->B1_COD,cAlmoxIni,"T",mv_par14,cAlmoxFim,,SB1->B1_COD,lSaldTesN3,!mv_par17 == 1)
			If mv_par23 == 1 .And. !Empty(mv_par24)
				aAuxTer  := SaldoTerc(SB1->B1_COD,cAlmoxIni,"T",mv_par14,cAlmoxFim,.T.,SB1->B1_COD,lSaldTesN3,!mv_par17 == 1)
				For nX := 1 to Len(aAuxTer)
					aAdd(aTerceiros,{"5",SubStr(aAuxTer[nX,1],nTPCF+nCLIFOR+nLOJA+1,nPRODUTO),SubStr(aAuxTer[nX,1],nTPCF+1,nCLIFOR),SubStr(aAuxTer[nX,1],nTPCF+nCLIFOR+1,nLOJA),aAuxTer[nX,2],aAuxTer[nX,3],aAuxTer[nX,4],SubStr(aAuxTer[nX,1],1,1)})
				Next nX	
			EndIf	
		EndIf
	EndIf

	//-- Busca Saldo em Estoque
	lFirst	  := .T.
	aSalAtu	  := {}
	aSaldo    := {0,0,0,0}

	#IFNDEF TOP
		SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD+If(Empty(cAlmoxIni), "", cAlmoxIni),.T.))
	#ENDIF

	If (cAliasTop)->(EOF()) .Or. SB1->B1_COD <> (cAliasTop)->B2_COD
		//-- Lista produtos sem movimentacao de estoque
		If mv_par07 == 1
			//-- So grava no consolidado caso nenhuma das filiais tenha saldo
			If lConsolida
				//-- Ve nas filiais ja processadas
				//-- Se custo unificado por filial, ve no arquivo consolidador
				If lCusConFil 
					(aArqCons[1])->(dbSetOrder(2))
					lGravaSit3 := !(aArqCons[1])->(dbSeek(SB1->B1_COD))
				//-- Se nao, olha no arquivo corrente (ja consolidado)
				Else
					(cArqTemp)->(dbSetOrder(2))
					lGravaSit3 := !(cArqTemp)->(dbSeek(SB1->B1_COD))
				EndIf
				
				//-- Ve nas filiais a processar
				If lGravaSit3
					SB2->(dbSetOrder(1))
					For nX := nForFilial+1 To Len(aFilsCalc)
						If !(lGravaSit3 := !SB2->(dbSeek(xFilial("SB2",aFilsCalc[nX,2])+SB1->B1_COD)))
							Exit
						EndIf
					Next nX
				EndIf
			EndIf
						
			//-- TIPO 3 - SEM SALDO
			If lGravaSit3
				RecLock(cArqTemp,.T.)
	
				(cArqTemp)->FILIAL		:= xFilial("SB2",cFilCons)
				(cArqTemp)->SITUACAO		:= "3" 
				(cArqTemp)->TIPO			:= IIf(lTipoBN,SB1->B1_TIPOBN,SB1->B1_TIPO)
				(cArqTemp)->PRODUTO		:= SB1->B1_COD
				(cArqTemp)->POSIPI		:= SB1->B1_POSIPI
				(cArqTemp)->DESCRICAO	:= SB1->B1_DESC
				(cArqTemp)->UM		   	:= SB1->B1_UM
				(cArqTemp)->ARMAZEM		:= IIF (empty((cAliasTop)->B2_LOCAL), (cAliasTop)->B1_LOCPAD, (cAliasTop)->B2_LOCAL)
				If nQuebraAliq == 2
					(cArqTemp)->ALIQ := SB1->B1_PICM
				ElseIf nQuebraAliq == 3
					(cArqTemp)->ALIQ := IIf(SB0->(MsSeek(xFilial("SB0")+SB1->B1_COD)),SB0->B0_ALIQRED,0)
				EndIf
				If mv_par22 == 1
					(cArqTemp)->SITTRIB := R460STrib(SB1->B1_COD)
				EndIf
				(cArqTemp)->(MsUnLock())
			EndIf
		EndIf
		#IFDEF TOP
			(cAliasTop)->(dbSkip())
		#ENDIF

	//-- Lista produtos com movimentacao de estoque
	Else
		#IFDEF TOP
		While !lEnd .And. !(cAliasTop)->(EOF()) .And. (cAliasTop)->B1_COD == SB1->B1_COD
		#ELSE
		While !lEnd .And. !(cAliasTop)->(EOF()) .And. SB2->(B2_FILIAL+B2_COD) == xFilial("SB2")+SB1->B1_COD .And. SB2->B2_LOCAL <= cAlmoxFim
			If !R460Local(SB2->B2_LOCAL)
				SB2->(dbSkip())
				Loop
			EndIf
		#ENDIF

			If Interrupcao(@lEnd)
				Exit
			EndIf

			//-- Desconsidera almoxarifado de saldo em processo de material
			//-- indireto ou saldo em armazem de terceiros
			If (cAliasTop)->B2_LOCAL==cLocProc  .Or.;
			   			(cAliasTop)->B2_LOCAL $ cLocTerc .Or.;
			   			(cAliasTop)->B2_LOCAL $ cPeLocProc
				(cAliasTop)->(dbSkip())
				Loop
			EndIf

			If mv_par17 == 1
				aSalatu := CalcEst(SB1->B1_COD,(cAliasTop)->B2_LOCAL,mv_par14+1,Nil)
			Else
				aSalAtu := CalcEstFF(SB1->B1_COD,(cAliasTop)->B2_LOCAL,mv_par14+1,Nil)	
			EndIf

			//-- TIPO 1 - EM ESTOQUE
			(cArqTemp)->(dbSetOrder(2))
			If (cArqTemp)->(dbSeek(SB1->B1_COD+"1"))
				RecLock(cArqTemp,.F.)
			Else
				RecLock(cArqTemp,.T.)
				lFirst:=.F.

				(cArqTemp)->FILIAL		:= xFilial("SB2",cFilCons)
				(cArqTemp)->SITUACAO		:= "1"
				(cArqTemp)->TIPO			:= IIf(lTipoBN,SB1->B1_TIPOBN,SB1->B1_TIPO)
				(cArqTemp)->POSIPI		:= SB1->B1_POSIPI
				(cArqTemp)->PRODUTO		:= SB1->B1_COD
				(cArqTemp)->DESCRICAO	:= SB1->B1_DESC
				(cArqTemp)->UM			:= SB1->B1_UM
				(cArqTemp)->ARMAZEM		:= IIF (empty((cAliasTop)->B2_LOCAL), (cAliasTop)->B1_LOCPAD, (cAliasTop)->B2_LOCAL)
				If nQuebraAliq == 2
					(cArqTemp)->ALIQ := SB1->B1_PICM
				ElseIf nQuebraAliq == 3
					(cArqTemp)->ALIQ := IIf(SB0->(MsSeek(xFilial("SB0")+SB1->B1_COD)),SB0->B0_ALIQRED,0)
				EndIf
				If mv_par22 == 1
					(cArqTemp)->SITTRIB := R460STrib(SB1->B1_COD)
				EndIf
			EndIf
			(cArqTemp)->QUANTIDADE	+= aSalAtu[01]
			(cArqTemp)->TOTAL		    += aSalAtu[02]
			If aSalAtu[1] > 0
				(cArqTemp)->VALOR_UNIT := NoRound((cArqTemp)->TOTAL/(cArqTemp)->QUANTIDADE,nDecVal)
			EndIf
			
			//-- Este Ponto de Entrada foi criado para recalcular o Valor Unitario / Total
			If lCalcUni
				ExecBlock("A460UNIT",.F.,.F.,{SB1->B1_COD,(cAliasTop)->B2_LOCAL,mv_par14,cArqTemp})
			EndIf
			
			(cArqTemp)->(MsUnLock())

			(cAliasTop)->(dbSkip())
		End

		//-- Pesquisa valores de materiais de terceiros requisitados para OP / TIPO 6
		aDadosCF9 := {0,0}

		If lAgregOP .And. SB1->B1_AGREGCU == "1"
			aDadosCF9 := SaldoD3CF9(SB1->B1_COD,NIL,mv_par14,cAlmoxIni,cAlmoxFim)				
			If (QtdComp(aDadosCF9[1]) > QtdComp(0)) .Or. (QtdComp(aDadosCF9[2]) > QtdComp(0))
				(cArqTemp)->(dbSetOrder(2))
				If (cArqTemp)->(dbSeek(SB1->B1_COD+"6"))
					RecLock(cArqTemp,.F.)
				Else
					RecLock(cArqTemp,.T.)
					lFirst:=.F.
					
					(cArqTemp)->FILIAL		:= xFilial("SB2",cFilCons)
					(cArqTemp)->SITUACAO		:= "6"
					(cArqTemp)->TIPO			:= IIf(lTipoBN,SB1->B1_TIPOBN,SB1->B1_TIPO)
					(cArqTemp)->POSIPI		:= SB1->B1_POSIPI
					(cArqTemp)->PRODUTO		:= SB1->B1_COD
					(cArqTemp)->DESCRICAO	:= SB1->B1_DESC
					(cArqTemp)->UM			:= SB1->B1_UM
					(cArqTemp)->ARMAZEM		:= IIF (empty((cAliasTop)->B2_LOCAL), (cAliasTop)->B1_LOCPAD, (cAliasTop)->B2_LOCAL)
					If nQuebraAliq == 2
						(cArqTemp)->ALIQ := SB1->B1_PICM
					ElseIf nQuebraAliq == 3
						(cArqTemp)->ALIQ := IIf(SB0->(MsSeek(xFilial("SB0")+SB1->B1_COD)),SB0->B0_ALIQRED,0)
					EndIf
					If mv_par22 == 1
						(cArqTemp)->SITTRIB := R460STrib(SB1->B1_COD)
					EndIf
				EndIf
				(cArqTemp)->QUANTIDADE 	:= aDadosCF9[1]
				(cArqTemp)->TOTAL			:= aDadosCF9[2]
				//-- Recalcula valor unitario
				If (cArqTemp)->QUANTIDADE > 0
					(cArqTemp)->VALOR_UNIT := (cArqTemp)->(NoRound(TOTAL/QUANTIDADE,nDecVal))
				EndIf

				//-- Este Ponto de Entrada foi criado para recalcular o Valor Unitario / Total
				If lCalcUni
					ExecBlock("A460UNIT",.F.,.F.,{SB1->B1_COD,"",mv_par14,cArqTemp})
				EndIf
				
				(cArqTemp)->(MsUnLock())
			EndIf
		EndIf

		//-- Tratamento de poder de terceiros
		If mv_par02 <> 2 .And. SB1->B1_FILIAL == xFilial("SB1")
			//-- Pesquisa os valores D = De Terceiros na array aSaldoTerD
			nX := aScan(aSaldoTerD,{|x| x[1] == xFilial("SB6")+SB1->B1_COD})
			If !(nX == 0)
				aSaldo[1] := aSaldoTerD[nX][3]
				aSaldo[2] := aSaldoTerD[nX][4]
				aSaldo[3] := aSaldoTerD[nX][5]
				If Len(aSaldoTerD[nX]) > 5
					aSaldo[4] := aSaldoTerD[nX][6]
				EndIf
			EndIf

			//-- Manipula arquivo de trabalho subtraindo do saldo em estoque saldo de terceiros
			(cArqTemp)->(dbSetOrder(2))
			If (cArqTemp)->(dbSeek(SB1->B1_COD+"1"))
				RecLock(cArqTemp,.F.)
			Else
				RecLock(cArqTemp,.T.)
				lFirst:=.F.
				
				(cArqTemp)->FILIAL		:= xFilial("SB2",cFilCons)
				(cArqTemp)->SITUACAO		:= "1"
				(cArqTemp)->TIPO			:= IIf(lTipoBN,SB1->B1_TIPOBN,SB1->B1_TIPO)
				(cArqTemp)->POSIPI		:= SB1->B1_POSIPI
				(cArqTemp)->PRODUTO		:= SB1->B1_COD
				(cArqTemp)->DESCRICAO	:= SB1->B1_DESC
				(cArqTemp)->UM			:= SB1->B1_UM
				(cArqTemp)->ARMAZEM		:= IIF (empty((cAliasTop)->B2_LOCAL), (cAliasTop)->B1_LOCPAD, (cAliasTop)->B2_LOCAL)
				If nQuebraAliq == 2
					(cArqTemp)->ALIQ := SB1->B1_PICM
				ElseIf nQuebraAliq == 3
					(cArqTemp)->ALIQ := IIf(SB0->(MsSeek(xFilial("SB0")+SB1->B1_COD)),SB0->B0_ALIQRED,0)
				EndIf
				If mv_par22 == 1
					(cArqTemp)->SITTRIB := R460STrib(SB1->B1_COD)
				EndIf
			EndIf
			(cArqTemp)->QUANTIDADE 	-= aSaldo[01]
			(cArqTemp)->TOTAL			-= aSaldo[02]
	        If lSaldTesN3 .And. nSumQtTer == 1  // PE A460TESN3 = .T. e variavel nSumQtTer == 1 NAO subtrair TES F4_ESTOQUE = N
				(cArqTemp)->QUANTIDADE 	+= aSaldo[03]
				(cArqTemp)->TOTAL			+= If(Len(aSaldo) >3,aSaldo[4],0)
			EndIf
			//-- Pesquisa os valores de material de terceiros requisitados para OP
			If lAgregOP .And. SB1->B1_AGREGCU == "1"
				//-- Desconsidera do calculo do saldo em estoque movimentos RE9 e DE9
				If (QtdComp(aDadosCF9[1]) > QtdComp(0)) .Or. (QtdComp(aDadosCF9[2]) > QtdComp(0))
					(cArqTemp)->QUANTIDADE	+= aDadosCF9[1]
					(cArqTemp)->TOTAL			+= aDadosCF9[2]
				EndIf
			EndIf
			//-- Recalcula valor unitario
			If (cArqTemp)->QUANTIDADE > 0
				(cArqTemp)->VALOR_UNIT := (cArqTemp)->(NoRound(TOTAL/QUANTIDADE,nDecVal))
			EndIf

			//-- Este Ponto de Entrada foi criado para recalcular o Valor Unitario / Total
			If lCalcUni
				ExecBlock("A460UNIT",.F.,.F.,{SB1->B1_COD,"",mv_par14,cArqTemp})
			EndIf
			
			(cArqTemp)->(MsUnLock())
		EndIf
	EndIf

	//-- Processa Saldo De Terceiro TIPO 4 - SALDO DE TERCEIROS
	R460Terceiros(aSaldoTerD,aSaldoTerT,@lEnd,cArqTemp,"4",aDadosCF9,cAliasTop,lTipoBN,cFilCons)

	//-- Processa Saldo Em Terceiro TIPO 5 - SALDO EM TERCEIROS
	R460Terceiros(aSaldoTerD,aSaldoTerT,@lEnd,cArqTemp,"5",NIL,cAliasTop,lTipoBN,cFilCons)

	#IFNDEF TOP
		SB1->(dbSkip())
	#ENDIF
End

	U_R460EmProcessZ(@lEnd,cArqTemp,.F.,,,lTipoBN,cFilCons)

//-- CUSTO UNIFICADO - Realiza acerto dos valores para todos tipos
If lCusUnif .And. (!lConsolida .Or. lCusConFil .Or. nForFilial == Len(aFilsCalc))
	(cArqTemp)->(dbSetOrder(2))
	(cArqTemp)->(dbGotop())

	//-- Percorre arquivo de Trabalho
	While !(cArqTemp)->(EOF())
		cSeekUnif   := (cArqTemp)->PRODUTO
		aSeek       := {}
		nValTotUnif := 0
		nQtdTotUnif := 0
		While !(cArqTemp)->(EOF()) .And. cSeekUnif == (cArqTemp)->PRODUTO
  			If (!mv_par08 == 1 .And. (cArqTemp)->QUANTIDADE < 0) .Or.;
							(!mv_par09 == 1 .And. (cArqTemp)->QUANTIDADE == 0) .Or.;
							(!mv_par16 == 1 .And. (cArqTemp)->TOTAL == 0)
				(cArqTemp)->(dbSkip())
				Loop
    		EndIf

			//-- Nao processar o saldo de/em terceiros aglutinado ao custo medio
			If !((cArqTemp)->SITUACAO $ "45")
	  			aAdd(aSeek,(cArqTemp)->(Recno()))
				nValTotUnif += (cArqTemp)->TOTAL
				nQtdTotUnif += (cArqTemp)->QUANTIDADE
			EndIf	
			(cArqTemp)->(dbSkip())
		End
		
		If Len(aSeek) > 0
			//-- Calcula novo valor unitario
		  	For nX := 1 To Len(aSeek)
				If QtdComp(nQtdTotUnif) <> QtdComp(0)
					(cArqTemp)->(dbGoto(aSeek[nX]))
					Reclock(cArqTemp,.F.)
					(cArqTemp)->VALOR_UNIT := NoRound(nValTotUnif/nQtdTotUnif,nDecVal)
					(cArqTemp)->TOTAL      := (cArqTemp)->QUANTIDADE * (nValTotUnif/nQtdTotUnif)
					(cArqTemp)->(MsUnlock())
				EndIf	
			Next nX
			(cArqTemp)->(dbSkip())
		EndIf
	End
EndIf

//-- Se consolidado e custo unificado por filial, devera agregar no arquivo consolidado
//-- o agregado desta filial e deletar o arquivo desta filial
If lConsolida .And. lCusConFil .And. cArqTemp # aArqCons[1]
	//-- Agrega filial no arquivo consolidado
	(cArqTemp)->(dbGoTop())
	(aArqCons[1])->(dbSetOrder(1))
	While !(cArqTemp)->(EOF())
		If (aArqCons[1])->(dbSeek((cArqTemp)->&((aArqCons[1])->(IndexKey()))))
			RecLock(aArqCons[1],.F.)
		Else
			RecLock(aArqCons[1],.T.)
			(aArqCons[1])->FILIAL	:= (cArqTemp)->FILIAL
			(aArqCons[1])->SITUACAO	:= (cArqTemp)->SITUACAO
			(aArqCons[1])->TIPO		:= (cArqTemp)->TIPO
			(aArqCons[1])->POSIPI	:= (cArqTemp)->POSIPI
			(aArqCons[1])->PRODUTO	:= (cArqTemp)->PRODUTO
			(aArqCons[1])->DESCRICAO	:= (cArqTemp)->DESCRICAO
			(aArqCons[1])->UM			:= (cArqTemp)->UM
			(aArqCons[1])->ALIQ		:= (cArqTemp)->ALIQ
			(aArqCons[1])->SITTRIB	:= (cArqTemp)->SITTRIB
			(aArqCons[1])->ARMAZEM	:= (cArqTemp)->ARMAZEM
		EndIf
		(aArqCons[1])->QUANTIDADE	+= (cArqTemp)->QUANTIDADE
		(aArqCons[1])->TOTAL			+= (cArqTemp)->TOTAL
		(aArqCons[1])->VALOR_UNIT	:= (aArqCons[1])->TOTAL / (aArqCons[1])->QUANTIDADE
		(aArqCons[1])->(MsUnLock())
		
		(cArqTemp)->(dbSkip())
	End
	
	//-- Restaura variaveis de controle do arquivo temporario
	cArqTemp  := aArqCons[1]
EndIf

If lImprime
	//-- Muda filial para impressao do cabe�alho (tratamento para consolidado)
	If (nPos := aScan(aFilsCalc,{|x| x[2] == cFilCons})) > 0
		nFilBkp := nForFilial
		nForFilial := nPos
		SM0->(dbSeek(cEmpAnt+aFilsCalc[nForFilial,2]))
		cFilAnt := aFilsCalc[nForFilial,2]
	EndIf
	
	//-- Imprime Modelo P7
	(cArqTemp)->(dbSetOrder(1))
	(cArqTemp)->(dbGotop())
	
	//-- Flags de Impressao
	cSitAnt	  := "X"
	aSituacao := {STR0015,STR0016,STR0017,STR0018,STR0019,STR0034}		//" EM ESTOQUE "###" EM PROCESSO "###" SEM MOVIMENTACAO "###" DE TERCEIROS "###" EM TERCEIROS "
	cTipoAnt  := "XX"
	cQuebra   := ""
	
	If lImpSX1
		ImpListSX1(STR0001,"MATR460",Tamanho,,.T.)
	EndIf	
	
	While !(cArqTemp)->(EOF())
		nLin    := 80
		cSitAnt := (cArqTemp)->SITUACAO
		lImpSit := .T.
		While !(cArqTemp)->(EOF()) .And. cSitAnt == (cArqTemp)->SITUACAO
			cTipoAnt := (cArqTemp)->TIPO
			lImpTipo := .T.
			While !(cArqTemp)->(EOF()) .And. cSitAnt+cTipoAnt == (cArqTemp)->(SITUACAO+TIPO)
				cPosIpi := (cArqTemp)->POSIPI
				nTotIpi := 0
				
				If mv_par22 == 1
					cSitTrib := (cArqTemp)->SITTRIB
					lImpST   := .T.
				EndIf
				
				If nQuebraAliq <> 1
					nAliq    := (cArqTemp)->ALIQ
					lImpAliq := .T.
				EndIf	
	
				If mv_par22 == 1
					cQuebra := cSitAnt+cTipoAnt+cSitTrib
					cKeyQbr := 'SITUACAO+TIPO+SITTRIB'
				Else
					cQuebra := IIf(nQuebraAliq == 1,cSitAnt+cTipoAnt+cPosIpi,cSitAnt+cTipoAnt+Str(nAliq,5,2))
					cKeyQbr := IIf(nQuebraAliq == 1,'SITUACAO+TIPO+POSIPI','SITUACAO+TIPO+Str(ALIQ,5,2)')
				EndIf
	
				While !(cArqTemp)->(EOF()) .And. cQuebra == (cArqTemp)->&(cKeyQbr)
					If Interrupcao(@lEnd)
						Exit
					EndIf
	
					//-- Controla impressao de Produtos com saldo negativo ou zerado
					If (!mv_par08 == 1 .And. (cArqTemp)->QUANTIDADE < 0) .Or.;
							(!mv_par09 == 1 .And. (cArqTemp)->QUANTIDADE == 0) .Or.;
							(!mv_par16 == 1 .And. (cArqTemp)->TOTAL == 0)
						(cArqTemp)->(dbSkip())
						Loop
					Else
						nTotIpi += (cArqTemp)->TOTAL
						(cArqTemp)->(R460Acumula(aTotal))
					EndIf
					
					//-- Inicializa array com itens de impressao de acordo com MV_PAR15
					If mv_par15 == 1
						aImp:= {Alltrim((cArqTemp)->POSIPI),;
								(cArqTemp)->DESCRICAO,;
								(cArqTemp)->UM,;
								Transform((cArqTemp)->QUANTIDADE,IF(TamSX3("B2_QFIM")[2]>3,"@E 99,999,999.999",PesqPict("SB2", "B2_QFIM",14))),;
								(cArqTemp)->(Transform(NoRound(TOTAL/QUANTIDADE,nDecVal),PesqPict("SB2", "B2_CM1",18))),;
								Transform((cArqTemp)->TOTAL,"@E 999,999,999,999.99" ),;
								Nil}
					Else
						aImp:= {Alltrim((cArqTemp)->POSIPI),;
								(cArqTemp)->(Padr(AllTrim(PRODUTO) +" - " +DESCRICAO,35)),;
								(cArqTemp)->UM,;
								Transform((cArqTemp)->QUANTIDADE,IF(TamSX3("B2_QFIM")[2]>3,"@E 99,999,999.999",PesqPict("SB2", "B2_QFIM",14))),;
								(cArqTemp)->(Transform(NoRound(TOTAL/QUANTIDADE,nDecVal),PesqPict("SB2", "B2_CM1",18))),;
								Transform((cArqTemp)->TOTAL,"@E 999,999,999,999.99"),;
								Nil}
					EndIf

					(cArqTemp)->(dbSkip())
	
					//-- Salta registros Zerados ou Negativos Conforme Parametros
					//-- Necessario Ajustar Posicao p/ Totalizacao de Grupos (POSIPI)
					While !(cArqTemp)->(EOF()) .And. (	(!mv_par08 == 1 .And. (cArqTemp)->QUANTIDADE < 0) .Or.;
														(!mv_par09 == 1 .And. (cArqTemp)->QUANTIDADE == 0) .Or.;
														(!mv_par16 == 1 .And. (cArqTemp)->TOTAL == 0))
						(cArqTemp)->(dbSkip())
					End

					//-- Verifica se imprime total por POSIPI
					If !(cSitAnt+cTipoAnt+cPosIpi == (cArqTemp)->(SITUACAO+TIPO+POSIPI)) .And. nQuebraAliq == 1
						aImp[07] := Transform(nTotIPI,"@E 999,999,999,999.99")
					EndIf

					//-- Imprime cabecalho
					If nLin>55
						R460Cabec(@nLin,@nPagina,.F.,Nil,aFilsCalc[nForFilial,3])
					EndIf
	
					If lImpSit
						FmtLin({"",Padc(aSituacao[Val(cSitAnt)],35,"*"),"","","","",""},aL[15],,,@nLin)
						lImpSit := .F.
					EndIf
	
					If lImpTipo
						SX5->(dbSeek(xFilial("SX5")+"02"+cTipoAnt))
						FmtLin(Array(7),aL[15],,,@nLin)
						FmtLin({"",Padc(" "+SUBSTR(TRIM(X5Descri()),1,26)+" ",35,"*"),"","","","",""},aL[15],,,@nLin)
						FmtLin(Array(7),aL[15],,,@nLin)
						lImpTipo := .F.
					EndIf
	
					If mv_par22 == 1 .And. lImpST
						FmtLin({"",Padc(" "+STR0044+" "+cSitTrib+" ",35,"*"),"","","","",""},aL[15],,,@nLin)
						FmtLin(Array(7),aL[15],,,@nLin)
						lImpST := .F.
					EndIf
					
					If nQuebraAliq <> 1 .And. lImpAliq
						FmtLin({"",Padc(" "+STR0031+Transform(nAliq,"@E 99.99%")+" ",35,"*"),"","","","",""},aL[15],,,@nLin)
						FmtLin(Array(7),aL[15],,,@nLin)
						lImpAliq := .F.
					EndIf	
	
					//-- Imprime linhas de detalhe de acordo com parametro (mv_par15)
					FmtLin(aImp,aL[15],,,@nLin)
	
					If nQuebraAliq <> 1 .And. cQuebra <> &(cKeyQbr)
						FmtLin(Array(7),aL[15],,,@nLin)
						nPos := aScan(aTotal,{|x| x[1] == cSitAnt .And. x[2] == cTipoAnt .And. x[6] == nAliq})
						FmtLin({,STR0021+STR0031+Transform(nAliq,"@E 99.99%")+" ===>",,,,,Transform(aTotal[nPos,5], "@E 999,999,999,999.99")},aL[15],,,@nLin)			//"TOTAL "
						FmtLin(Array(7),aL[15],,,@nLin)
					EndIf
	
					If mv_par22 == 1 .And. cQuebra <> &(cKeyQbr)
						FmtLin(Array(7),aL[15],,,@nLin)
						nPos := aScan(aTotal,{|x| x[1] == cSitAnt .And. x[2] == cTipoAnt .And. x[6] == cSitTrib})
						FmtLin({,STR0021+STR0044+" "+cSitTrib+" ===>",,,,,Transform(aTotal[nPos,5], "@E 999,999,999,999.99")},aL[15],,,@nLin)	//"TOTAL "
						FmtLin(Array(7),aL[15],,,@nLin)
	                EndIf
	
					If nLin >= 55
						R460EmBranco(@nLin,.F.)
					EndIf
				End
			End
			
			//-- Impressao de Totais
			If !Empty(nPos := aScan(aTotal,{|x| x[1] == cSitAnt .And. x[2] == cTipoAnt}))
				If nLin > 55
					R460Cabec(@nLin,@nPagina,.F.,Nil,aFilsCalc[nForFilial,3])
				EndIf
				R460Total(@nLin,aTotal,cSitAnt,cTipoAnt,aSituacao,@nPagina,.F.,Nil,aFilsCalc[nForFilial,3])
			EndIf
		End
	
		nPos := Ascan(aTotal,{|x|x[1]==cSitAnt .And. x[2]==TT})
		If nPos # 0
			R460Total(@nLin,aTotal,cSitAnt,TT,aSituacao,@nPagina,.F.,Nil,aFilsCalc[nForFilial,3])
			R460EmBranco(@nLin,.F.)
			lImpResumo := .T.
		EndIf
	End
	
	R460Cabec(@nLin,@nPagina,.F.,Nil,aFilsCalc[nForFilial,3])
	
	If lImpResumo
		R460Total(@nLin,aTotal,"T",TT,aSituacao,@nPagina,.F.,Nil,aFilsCalc[nForFilial,3])
	Else
		R460SemEst(@nLin,@nPagina,.F.)
	EndIf
	
	R460EmBranco(@nLin,.F.)
	
	//-- Realiza a gravacao do arquivo de trabalho (SPED FISCAL)
	If mv_par23 == 1 .And. !Empty(mv_par24)
		R460GrvTRB(aTerceiros,cArqTemp)
	EndIf
	
	//-- Se mudou filial para imprimir cabecalho, retorna
	If !Empty(nFilBkp)
		nForFilial := nFilBkp
		SM0->(dbSeek(cEmpAnt+aFilsCalc[nForFilial,2]))
		cFilAnt := aFilsCalc[nForFilial,2]
	EndIf
EndIf

#IFNDEF TOP
	If mv_par02 <> 2
		SB6->(RetIndex("SB6"))
		SB6->(dbClearFilter())
		FErase(cIndSB6+OrdBagExt())
	EndIf
#ELSE
	(cAliasTop)->(dbCloseArea())
#ENDIF

//-- Atualiza o log de processamento
ProcLogAtu("MENSAGEM",STR0046,STR0046) //"Processamento Encerrado"
ProcLogAtu("FIM")  

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � R460Term � Autor � Juan Jose Pereira     � Data � 07.11.96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Impressao dos Termos de Abertura e Encerramento do Modelo P7���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd    - variavel que indica se processo foi interrompido ���
���          � wnrel   - nome do arquivo a ser impresso                   ���
���          � cString - tabela sobre a qual o filtro do relatorio sera   ���
���          � executado                                                  ���
���          � tamanho - tamanho configurado para o relatorio             ���
�������������������������������������������������������������������������Ĵ��
��� Retorno  � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR460                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function R460Term(lEnd,wnRel,cString,Tamanho)
Local cArqAbert	:= GetMv("MV_LMOD7AB")
Local cArqEncer	:= GetMv("MV_LMOD7EN")
Local aDriver 	:= ReadDriver()
Local aAreaSM0	:= SM0->(GetArea())

If SM0->M0_CODFIL # cFilAnt
	SM0->(dbSeek(cEmpAnt+cFilAnt))
EndIf

XFIS_IMPTERM(cArqAbert,cArqEncer,"MTR46Z",IIF(aReturn[4] == 1,aDriver[3],aDriver[4]))

RestArea(aAreaSM0)	
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �R460Terceiros  �Autor�Juan Jose Pereira   � Data � 07.11.96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Busca Saldo em poder de Terceiros (T) ou de Terceiros (D)   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aSaldoTerD - array de dados dos saldos de terceiros 		  ���
���			 � aSaldoTerT - array de dados dos saldos em terceiros		  ���
���			 � lEnd    - variavel que indica se processo foi interrompido ���
���          � cArqTemp- nome do arquivo de trabalho criado para impressao���
���          � do relatorio                                               ���
���          � cEmdeTerc-String indicando se esta processando saldo de    ���
���          � terceiros ou saldo em terceiros                            ���
���          � executado                                                  ���
���          � aDadosCF9- Array com informacaoes relacionadas a movimentos���
���          � internos RE9/DE9                                           ���
���          � cAliasTop - Alias da query principal (SB2)                 ���
���          � lTipoBN   - Tratamento para produtos BN (Beneficiamento)   ���
���          � cFilCons - Filial que solicitou impressao do relatorio		 ���
�������������������������������������������������������������������������Ĵ��
��� Retorno  � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR460                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function R460Terceiros(aSaldoTerD,aSaldoTerT,lEnd,cArqTemp,cEmDeTerc,aDadosCF9,cAliasTop,lTipoBN,cFilCons)
Local aSaldo  	:= {0,0,0,0}
Local nX	  	:= 0
Local lCusFifo	:= SuperGetMV("MV_CUSFIFO",.F.,.F.)                                                          	
Local cLocTerc	:= SuperGetMv("MV_ALMTERC",.F.,"")
Local aSalAtu 	:= {}
Local cAlmTerc	:= ""
Local lCalcTer  := ExistBlock("A460TUNI") 
Local lConsolida:= mv_par21 == 1 .And. mv_par25 == 1

Default aDadosCF9 := {0,0} // Quantidade e custo na 1a moeda para movimentos do SD3 com D3_CF RE9 ou DE9
Default lTipoBN   := .F.

If mv_par02 <> 2 .And. !lEnd .And. SB1->B1_FILIAL == xFilial("SB1")
	//-- Pesquisa os valores D == De Terceiros / T == Em Terceiros
	nX := aScan(If(cEmDeTerc=="4",aSaldoTerD,aSaldoTerT),{|x| x[1] == xFilial("SB6")+SB1->B1_COD})
	If !(nX == 0)
       //--NAO CALCULAR PA EM TERCEIROS 
       //criado por Ricky em 05/12/18 para  n�o demostra PA EM TERCEIROS solicitado por Ezaquiel
       if SB1->B1_TIPO=="PA"                 
       	aSaldo[1] := If(cEmDeTerc=="4",0,0)
       else
			aSaldo[1] := If(cEmDeTerc=="4",aSaldoTerD[nX,3],aSaldoTerT[nX,3])       
		EndIF
			
			
		aSaldo[2] := If(cEmDeTerc=="4",aSaldoTerD[nX,4],aSaldoTerT[nX,4])
	EndIf

	//-- Considera o saldo do armazem do parametro como saldo em terceiros
	If !Empty(cLocTerc) .And. cEmDeTerc == "5"
		While !Empty(cLocTerc)
			cAlmTerc := SubStr(cLocTerc,1,At("/",cLocTerc)-1)
			cLocTerc := SubStr(cLocTerc,At("/",cLocTerc)+1)
			If !Empty(cAlmTerc)
				If mv_par17 == 1
					aSalatu := CalcEst(SB1->B1_COD,cAlmTerc,mv_par14+1,Nil)		
				Else
					aSalatu := CalcEstFF(SB1->B1_COD,cAlmTerc,mv_par14+1,Nil)
				EndIf
				aSaldo[1] +=aSalAtu[01]
				aSaldo[2] +=aSalAtu[02]		
			Else
				Exit
			EndIf
		End
	EndIf
	
	If aSaldo[1]+aSaldo[2] # 0
		(cArqTemp)->(dbSetOrder(2))
		If (cArqTemp)->(dbSeek(SB1->B1_COD+cEmDeTerc))
			RecLock(cArqTemp,.F.)
		Else
			RecLock(cArqTemp,.T.)
			(cArqTemp)->FILIAL		:= xFilial("SB2",cFilCons)
			(cArqTemp)->SITUACAO 		:= cEmDeTerc
			(cArqTemp)->TIPO			:= IIf(lTipoBN,SB1->B1_TIPOBN,SB1->B1_TIPO)
			(cArqTemp)->POSIPI		:= SB1->B1_POSIPI
			(cArqTemp)->PRODUTO		:= SB1->B1_COD
			(cArqTemp)->DESCRICAO	:= SB1->B1_DESC
			(cArqTemp)->UM			:= SB1->B1_UM
			(cArqTemp)->ARMAZEM		:= SB1->B1_LOCPAD
			If nQuebraAliq == 2
				(cArqTemp)->ALIQ := SB1->B1_PICM
			ElseIf nQuebraAliq == 3
				(cArqTemp)->ALIQ := IIf(SB0->(MsSeek(xFilial("SB0")+SB1->B1_COD)),SB0->B0_ALIQRED,0)
			EndIf
			If mv_par22 == 1
				(cArqTemp)->SITTRIB := R460STrib(SB1->B1_COD)
			EndIf
		EndIf
		(cArqTemp)->QUANTIDADE	+= aSaldo[01]
		(cArqTemp)->TOTAL			+= aSaldo[02]

		//-- Desconsidera do calculo do saldo do material de terceiros movimentos RE9 e DE9
		If QtdComp(aDadosCF9[1]) > QtdComp(0) .Or. QtdComp(aDadosCF9[2]) > QtdComp(0)
			(cArqTemp)->QUANTIDADE	-= aDadosCF9[1]
			(cArqTemp)->TOTAL			-= aDadosCF9[2]
		EndIf
		If (cArqTemp)->QUANTIDADE > 0
			(cArqTemp)->VALOR_UNIT := NoRound((cArqTemp)->TOTAL/(cArqTemp)->QUANTIDADE,nDecVal)
		EndIf
		
		//-- Este Ponto de Entrada foi criado para recalcular o Valor Unitario/Total
		If lCalcTer
			ExecBlock("A460TUNI",.F.,.F.,{SB1->B1_COD,SuperGetMv("MV_ALMTERC",.F.,""),mv_par14,cArqTemp})
		EndIf

		(cArqTemp)->(MsUnLock())
	EndIf
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �R460EmProcessZ �Autor�Microsiga S/A       � Data � 19.06.08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Busca saldo em Processo                                     ���
���          �Atualiza aqruivo de trab. c/ Saldo em Processo dos Produtos.���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd      - Var. que indica se proc. foi interrompido      ���
���          � cArqTemp  - Nome do arquivo de trabalho                    ���
���          � lGraph    - Nao atualiza regua de progressao               ���
���          � aProdFis  - Informacoes saldo em processo Sintegra         ���
���          � aNCM      - Aglutinacao por NCM processos (Sintegra)       ���
���          � lTipoBN   - Tratamento para produtos BN (Beneficiamento)   ���
���          � cFilCons - Filial que solicitou impressao do relatorio		���
�������������������������������������������������������������������������Ĵ��
��� Retorno  � Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function R460EmProcessZ(lEnd,cArqTemp,lGraph,aProdFis,aNCM,lTipoBN,cFilCons)
Local aA460AMZP	:= {}
Local aCampos   := {}
Local aEmAnalise:= {}
Local aSalAtu   := {}
Local aProducao := {}

Local lEmProcess:= .F. 
Local lFiscal	:= .F.
Local lCusFIFO  := SuperGetMV("MV_CUSFIFO",.F.,.F.)
Local nProdPR0  := SuperGetMv("MV_PRODPR0",.F.,1)
Local lMT460EP  := SuperGetMv("MV_MT460EP",.F.,.F.)
Local lA460AMZP := ExistBlock("A460AMZP")

Local cAliasTop := "SD3"
Local cAliasSD3 := "SD3"
Local cArqTemp2 := ""
Local cPeLocProc:= ""
Local cBkLocProc:= ""
Local cArqTemp3 := CriaTrab(Nil,.F.)
Local cLocProc  := SuperGetMv("MV_LOCPROC",.F.,"99")

Local nQtMedia  := 0
Local nQtNeces  := 0
Local nQtde     := 0
Local nCusto    := 0
Local nPos      := 0
Local nX        := 0
Local nQtdOrigem:= 0
Local nQtdProduz:= 0
Local nRecnoD3  := 0
Local cQuery:=""
#IFDEF TOP
	Local cQuery  := ""
#ELSE
	Local cFiltro := ""
	Local nIndex  := 0
#ENDIF

Default lGraph 		:= .F.
Default lTipoBN     := .F.
Default aProdFis 	:= {} 
Default aNCM		:= {}

lFiscal	:= Len(aProdFis) >= 11  

//-- A460AMZP - Ponto de Entrada para considerar um armazen
//--            adicional como armazem de processo.
If lA460AMZP
	aA460AMZP := ExecBlock("A460AMZP",.F.,.F.,'')
	If ValType(aA460AMZP)=="A" .And. Len(aA460AMZP) == 1
		cBkLocProc := IIf(Valtype(aA460AMZP[1])=="C",aA460AMZP[1],'')
	EndIf	
EndIf

//-- SALDO EM PROCESSO
If mv_par01 == 1 .And. !lEnd
	//-- Busca saldo em processo dos materiais de uso indireto
	cQuery:= " SELECT B1_COD FROM SB1010 WHERE D_E_L_E_T_ = '' AND B1_TIPO IN ('MP','EM','PA','PI','MC') 
	cQuery+= " AND B1_COD BETWEEN '"+MV_PAR05+"' AND  '"+MV_PAR06+"' "
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),"TMP",.T.,.T.)
 
	While !TMP->(Eof()) .And. !lEnd
		If !lGraph .And. Interrupcao(@lEnd)
			Exit
		EndIf	
      
      If !R460AvalProd(TMP->B1_COD,Iif(!lFiscal,mv_par20==1,aProdFis[11]==1))
			SB1->(dbSkip())
			Loop
		EndIf

		
		If mv_par17 == 1
			aSalatu := CalcEst(TMP->B1_COD,cLocProc,mv_par14+1,nil)
		Else
			aSalatu := CalcEstFF(TMP->B1_COD,cLocProc,mv_par14+1,nil)
		EndIf

		//-- Grava o Saldo Em Processo
		U_R460Gravz(TMP->B1_COD	,;	//-- 01. Codigo do Produto
		          cLocProc			,;	//-- 02. Local
		          aSalAtu[1]		,;	//-- 03. Quantidade
		          aSalAtu[2]		,;	//-- 04. Custo na moeda 1 
		          Nil				,;	//-- 05. Recno da tabela SD3
		          Nil				,;	//-- 06. Tipo de movimento RE/DE
		          cArqTemp	 	  	,;	//-- 07. Alias do arquivo de trabalho
		          Nil   			,;	//-- 08. Alias da Query SD3 
		          lFiscal           ,;	//-- 09. Indica se o processamento e para o Sintegra e nao para geracao do Livro
		          @aNCM				,;	//-- 10. Array para aglutinar por NCM os saldos em processo
		          lTipoBN			,;	//-- 11. Tratamento para Produtos BN
		          cFilCons			)	//-- 12. Filial que esta processando o rel

		TMP->(dbSkip())
	End
	TMP->(dbCloseArea())
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �R460Cabec()    �Autor�Juan Jose Pereira   � Data � 07.11.96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Cabecalho do Modelo P7                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nLin - Numero da linha corrente                            ���
���          � nPagina - Numero da pagina corrente                        ���
�������������������������������������������������������������������������Ĵ��
��� Retorno  � Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function R460Cabec(nLin,nPagina,lGraph,oReport,cFilNome)
Local aL		:= R460LayOut(lGraph)
Local cPicCgc	:= ""

Default lGraph	 := .F.
Default cFilNome := ""

If cPaisLoc == "ARG"
	cPicCgc	:= "@R 99-99.999.999-9"
ElseIf cPaisLoc == "CHI"
	cPicCgc	:= "@R XX.999.999-X"
ElseIf cPaisLoc $ "POR|EUA"
	cPicCgc	:= PesqPict("SA2","A2_CGC")
Else
	cPicCgc	:= "@R 99.999.999/9999-99"
EndIf

//-- Posiciona na Empresa/Filial a ser processada
If mv_par21 == 1
	SM0->(dbSeek(cEmpAnt+cFilAnt))
EndIf

nLin:=1
If !lGraph
	@00,00 PSAY AvalImp(132)
	FmtLin(,aL[01],,,@nLin)
	FmtLin(,aL[02],,,@nLin)
	FmtLin(,aL[03],,,@nLin)
	If cFilNome != ""
		FmtLin({SM0->M0_NOMECOM,cFilNome},aL[04],,,@nLin)
	Else
		FmtLin({SM0->M0_NOMECOM},aL[04],,,@nLin)
	EndIf
	FmtLin(,aL[05],,,@nLin)
	If cPaisLoc == "CHI"
		FmtLin({,Transform(SM0->M0_CGC,cPicCgc)},aL[06],,,@nLin)
	Else
		FmtLin({InscrEst(),Transform(SM0->M0_CGC,cPicCgc)},aL[06],,,@nLin)
	EndIf
	
	FmtLin(,aL[07],,,@nLin)
	FmtLin({Transform(StrZero(nPagina,6),"@R 999.999"),DTOC(mv_par14)},aL[08],,,@nLin)
	FmtLin(,aL[09],,,@nLin)
	FmtLin(,aL[10],,,@nLin)
	FmtLin(,aL[11],,,@nLin)
	FmtLin(,aL[12],,,@nLin)
	FmtLin(,aL[13],,,@nLin)
	FmtLin(,aL[14],,,@nLin)
Else
	//-- Reinicia Paginas
	oReport:EndPage()

	FmtLinR4(oReport,,''    ,,,@nLin)
	FmtLinR4(oReport,,aL[01],,,@nLin)
	FmtLinR4(oReport,,aL[02],,,@nLin)
	FmtLinR4(oReport,,aL[03],,,@nLin)
	If cFilNome != ""
		FmtLinR4(oReport,{SM0->M0_NOMECOM,cFilNome},aL[04],,,@nLin)
	Else
		FmtLinR4(oReport,{SM0->M0_NOMECOM},aL[04],,,@nLin)
	EndIf
	FmtLinR4(oReport,,aL[05],,,@nLin)
	If cPaisLoc == "CHI"
		FmtLinR4(oReport,{,Transform(SM0->M0_CGC,cPicCgc)},aL[06],,,@nLin)
	Else
		FmtLinR4(oReport,{InscrEst(),Transform(SM0->M0_CGC,cPicCgc)},aL[06],,,@nLin)
	EndIf
	
	FmtLinR4(oReport,,aL[07],,,@nLin)
	FmtLinR4(oReport,{Transform(StrZero(nPagina,6),"@R 999.999"),DTOC(mv_par14)},aL[08],,,@nLin)
	FmtLinR4(oReport,,aL[09],,,@nLin)
	FmtLinR4(oReport,,aL[10],,,@nLin)
	FmtLinR4(oReport,,aL[11],,,@nLin)
	FmtLinR4(oReport,,aL[12],,,@nLin)
	FmtLinR4(oReport,,aL[13],,,@nLin)
	FmtLinR4(oReport,,aL[14],,,@nLin)
EndIf	

nPagina := nPagina +1

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �R460EmBranco() �Autor�Juan Jose Pereira   � Data � 07.11.96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Preenche o resto da pagina em branco                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nLin - Numero da linha corrente                            ���
�������������������������������������������������������������������������Ĵ��
��� Retorno  � Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function R460EmBranco(nLin,lGraph,oReport)
Local aL := R460Layout(lGraph)

Default lGraph := .F.

If !lGraph
	While nLin<=55
		FmtLin(Array(7),aL[15],,,@nLin)
	End
	FmtLin(,aL[16],,,@nLin)
Else
	While nLin <= 55
		FmtLinR4(oReport,Array(7),aL[15],,,@nLin)
	End
	FmtLinR4(oReport,,aL[16],,,@nLin)
	oReport:EndPage()
EndIf	

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �R460AvalProd() �Autor�Juan Jose Pereira   � Data � 07.11.96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Avalia se produto deve ser listado                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cProduto - Codigo do produto avaliado                      ���
���          � lConsMod - Flag que indica se devem ser considerados       ���
���          � produtos MOD                                               ���
�������������������������������������������������������������������������Ĵ��
��� Retorno  � LOGICO indicando se o produto deve ser listado             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function R460AvalProd(cProduto,lConsMod)
Local lRet		 := .T.     
Local aArea	 := {}

Default lConsMod := .F.

If !Empty(cFilUsrSB1)    //Executa filtro do usuario, se houver
	aArea		 := GetArea() 
	DbSelectArea ("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1")+cProduto)
	
	If Eof()
		lRet := .F.
	Else 
		lRet := &(cFilUsrSB1)
	EndIf
	
	RestArea(aArea)
EndIf

lRet := lRet .And. IIf(lConsMod,.T.,!IsProdMod(cProduto))

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �R460Local      �Autor�Juan Jose Pereira   � Data � 07.11.96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Avalia se Local deve ser listado                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cLocal - Codigo do armazem avaliado                        ���
�������������������������������������������������������������������������Ĵ��
��� Retorno  � LOGICO indicando se o armazem deve ser listado             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function R460Local(cLocal)
Return cLocal >= cAlmoxIni .And. cLocal <= cAlmoxFim

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �R460Acumula()  �Autor�Juan Jose Pereira   � Data � 07.11.96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Acumulador de totais                                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aTotal - Array com totalizadores do relatorio              ���
�������������������������������������������������������������������������Ĵ��
��� Retorno  � Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function R460Acumula(aTotal)
Local nPos := 0

If mv_par22 == 1
	nPos := aScan(aTotal,{|x| x[1] == SITUACAO .And. x[2] == TIPO .And. x[6] == SITTRIB})
ElseIf nQuebraAliq == 1
	nPos := aScan(aTotal,{|x| x[1] == SITUACAO .And. x[2] == TIPO})
Else
	nPos := aScan(aTotal,{|x| x[1] == SITUACAO .And. x[2] == TIPO .And. x[6] == ALIQ})
EndIf	

If nPos == 0
	If mv_par22 == 1
		aAdd(aTotal,{SITUACAO,TIPO,QUANTIDADE,VALOR_UNIT,TOTAL,SITTRIB})
	Else
		If nQuebraAliq == 1
			aAdd(aTotal,{SITUACAO,TIPO,QUANTIDADE,VALOR_UNIT,TOTAL})
		Else
			aAdd(aTotal,{SITUACAO,TIPO,QUANTIDADE,VALOR_UNIT,TOTAL,ALIQ})
		EndIf
	EndIf	
Else
	aTotal[nPos,3]+=QUANTIDADE
	aTotal[nPos,4]+=VALOR_UNIT
	aTotal[nPos,5]+=TOTAL
EndIf

If (nPos := aScan(aTotal,{|x| x[1] == SITUACAO .And. x[2] == TT})) == 0
	aAdd(aTotal,{SITUACAO,TT,QUANTIDADE,VALOR_UNIT,TOTAL,IIf(mv_par22 == 1,'',0)})
Else
	aTotal[nPos,3] += QUANTIDADE
	aTotal[nPos,4] += VALOR_UNIT
	aTotal[nPos,5] += TOTAL
EndIf

If (nPos := aScan(aTotal,{|x| x[1] == "T" .And. x[2] == TT})) == 0
	AADD(aTotal,{"T",TT,QUANTIDADE,VALOR_UNIT,TOTAL,IIf(mv_par22 == 1,'',0)})
Else
	aTotal[nPos,3]+=QUANTIDADE
	aTotal[nPos,4]+=VALOR_UNIT
	aTotal[nPos,5]+=TOTAL
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �R460Total()    �Autor�Juan Jose Pereira   � Data � 07.11.96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Imprime totais                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nLin  - Numero da linha corrente                           ���
���          � aTotal- Array com totalizadores do relatorio               ���
���          � cSituacao- Indica se deve imprimir total geral ou do grupo ���
���          � cTipo - Tipo que esta sendo totalizado                     ���
���          � aSituacao - Array com descricao da situacao totalizada     ���
���          � nPagina - Numero da pagina corrente                        ���
�������������������������������������������������������������������������Ĵ��
��� Retorno  � LOGICO indicando se o armazem deve ser listado             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function R460Total(nLin,aTotal,cSituacao,cTipo,aSituacao,nPagina,lGraph,oReport,cFilNome)
Local aL     	:= R460LayOut(lGraph)
Local nPos   	:= 0
Local i      	:= 0
Local nTotal 	:= 0
Local nStart 	:= 1
Local cSitAnt	:= "X"
Local cTipAnt	:= "X"
Local cSubtitulo:= ""

Default lGraph := .F.

If !lGraph
	FmtLin(Array(7),aL[15],,,@nLin)
Else
	FmtLinR4(oReport,Array(7),aL[15],,,@nLin)
EndIf	

If cSituacao != "T"
	//-- Imprime totais dos grupos                                    �
	If cTipo != TT
		nPos := aScan(aTotal,{|x| x[1] == cSituacao .And. x[2] == cTipo})
		SX5->(dbSeek(xFilial("SX5")+"02"+cTipo))
		If nQuebraAliq == 1 .And. !mv_par22 == 1
			If !lGraph
				FmtLin({,STR0021+SUBSTR(TRIM(X5Descri()),1,26)+" ===>",,,,,Transform(aTotal[nPos,5], "@E 999,999,999,999.99")},aL[15],,,@nLin)			//"TOTAL "
			Else
				FmtLinR4(oReport,{,SUBSTR(TRIM(X5Descri()),1,26)+" ===>",,,,,Transform(aTotal[nPos,5], "@E 999,999,999,999.99")},aL[15],,,@nLin)			//"TOTAL "
			EndIf	
		Else
			nTotal := 0
			nStart := aScan(aTotal,{|x| x[1] == cSituacao .And. x[2] == cTipo})
			While (nPos := aScan(aTotal,{|x| x[1] == cSituacao .And. x[2] == cTipo},nStart)) > 0
				If nPos > 0
					nTotal += aTotal[nPos,5]
				EndIf	
				If (nStart := ++nPos) > Len(aTotal)
					Exit
				EndIf
			End
			If !lGraph
				FmtLin({,STR0021+SUBSTR(TRIM(X5Descri()),1,26)+" ===>",,,,,Transform(nTotal, "@E 999,999,999,999.99")},aL[15],,,@nLin)			//"TOTAL "
			Else
				FmtLinR4(oReport,{,STR0021+SUBSTR(TRIM(X5Descri()),1,26)+" ===>",,,,,Transform(nTotal, "@E 999,999,999,999.99")},aL[15],,,@nLin)	//"TOTAL "
			EndIf	
		EndIf	
	Else
		nPos := aScan(aTotal,{|x| x[1] == cSituacao .And. x[2] == TT})
		If !lGraph
			FmtLin({,STR0021+aSituacao[Val(cSituacao)]+" ===>",,,,,Transform(aTotal[nPos,5], "@E 999,999,999,999.99")},aL[15],,,@nLin)	//"TOTAL "
		Else 
			FmtLinR4(oReport,{,STR0021+aSituacao[Val(cSituacao)]+" ===>",,,,,Transform(aTotal[nPos,5], "@E 999,999,999,999.99")},aL[15],,,@nLin)	//"TOTAL "
		EndIf	
	EndIf
	If nLin >= 55
		R460EmBranco(@nLin,If(!lGraph,.F.,.T.),If(lGraph,oReport,))
	EndIf
Else
	//-- Imprime resumo final
	If mv_par22 == 1
		aTotal := aSort(aTotal,,,{|x,y|x[1]+x[2]+x[6]<y[1]+y[2]+y[6]})
	Else
		aTotal := aSort(aTotal,,,{|x,y|x[1]+x[2]<y[1]+y[2]})
	EndIf	
	If !lGraph
		FmtLin(Array(7),aL[15],,,@nLin)
		FmtLin({,STR0022,,,,,},aL[15],,,@nLin)				//"R E S U M O"
		FmtLin({,"***********",,,,,},aL[15],,,@nLin)
	Else
		FmtLinR4(oReport,Array(7),aL[15],,,@nLin)
		FmtLinR4(oReport,{,STR0022,,,,,},aL[15],,,@nLin)		//"R E S U M O"
		FmtLinR4(oReport,{,"***********",,,,,},aL[15],,,@nLin)
	EndIf	
	For i := 1 To Len(aTotal)
		If nLin > 55
			If !lGraph
				R460Cabec(@nLin,@nPagina,.F.,NIL,cFilNome)
				FmtLin(Array(7),aL[15],,,@nLin)
			Else
				R460Cabec(@nLin,@nPagina,.T.,oReport,cFilNome)
				FmtLinR4(oReport,Array(7),aL[15],,,@nLin)
			EndIf
		EndIf
		//-- Nao imprime produtos sem movimentacao
		If aTotal[i,1] == "3"
			Loop
		EndIf
		If cSitAnt != aTotal[i,1]
			cSitAnt := aTotal[i,1]
			If aTotal[i,1] != "T"
				If !lGraph
					FmtLin(Array(7),aL[15],,,@nLin)
					cSubTitulo:=Alltrim(aSituacao[Val(aTotal[i,1])])
					FmtLin({,cSubtitulo,,,,,},aL[15],,,@nLin)
					FmtLin({,Replic("*",Len(cSubtitulo)),,,,,},aL[15],,,@nLin)
				Else 
					FmtLinR4(oReport,Array(7),aL[15],,,@nLin)
					cSubTitulo:=Alltrim(aSituacao[Val(aTotal[i,1])])
					FmtLinR4(oReport,{,cSubtitulo,,,,,},aL[15],,,@nLin)
					FmtLinR4(oReport,{,Replic("*",Len(cSubtitulo)),,,,,},aL[15],,,@nLin)				
				EndIf	
			Else
				If !lGraph
					FmtLin(Array(7),aL[15],,,@nLin)
					FmtLin({,STR0023,,,,,Transform(aTotal[i,5],"@E 999,999,999,999.99")},aL[15],,,@nLin)		//"TOTAL GERAL ====>"
				Else
					FmtLinR4(oReport,Array(7),aL[15],,,@nLin)
					FmtLinR4(oReport,{,STR0023,,,,,Transform(aTotal[i,5],"@E 999,999,999,999.99")},aL[15],,,@nLin)		//"TOTAL GERAL ====>"
				EndIf	
			EndIf
		EndIf
		If aTotal[i,1] != "T"
			If aTotal[i,2] != TT
				If cTipAnt != aTotal[i,2] .And. cSitAnt == aTotal[i,1]
					cTipAnt := aTotal[i,2]
					SX5->(dbSeek(xFilial("SX5")+"02"+aTotal[i,2]))
					If nQuebraAliq == 1 .And. !mv_par22 == 1
						If !lGraph
							FmtLin({,SUBSTR(TRIM(X5Descri()),1,26),,,,,Transform(aTotal[i,5],"@E 999,999,999,999.99")},aL[15],,,@nLin)
						Else
							FmtLinR4(oReport,{,SUBSTR(TRIM(X5Descri()),1,26),,,,,Transform(aTotal[i,5],"@E 999,999,999,999.99")},aL[15],,,@nLin)
						EndIf	
					Else
						nTotal := 0
						nStart := aScan(aTotal,{|x| x[1] == cSitAnt .And. x[2] == cTipAnt})
						While (nPos := aScan(aTotal,{|x| x[1]== cSitAnt .And. x[2] == cTipAnt},nStart)) > 0
							If nPos > 0
								nTotal += aTotal[nPos,5]
							EndIf	
							If (nStart := ++nPos) > Len(aTotal)
								Exit
							EndIf
						End
						If i <> 1
							If !lGraph
								FmtLin(Array(7),aL[15],,,@nLin)
							Else
								FmtLinR4(oReport,Array(7),aL[15],,,@nLin)
							EndIf	
						EndIf	
						If !lGraph
							FmtLin({,SUBSTR(TRIM(X5Descri()),1,26),,,,,Transform(nTotal,"@E 999,999,999,999.99")},aL[15],,,@nLin)
						Else 
							FmtLinR4(oReport,{,SUBSTR(TRIM(X5Descri()),1,26),,,,,Transform(nTotal,"@E 999,999,999,999.99")},aL[15],,,@nLin)
						EndIf	
					EndIf
				EndIf
				If nQuebraAliq <> 1	
					If !lGraph
						FmtLin({,STR0031+Transform(aTotal[i,6],"@E 99.99%"),,,,,Transform(aTotal[i,5], "@E 999,999,999,999.99")},aL[15],,,@nLin)			
					Else
						FmtLinR4(oReport,{,STR0031+Transform(aTotal[i,6],"@E 99.99%"),,,,,Transform(aTotal[i,5], "@E 999,999,999,999.99")},aL[15],,,@nLin)			
					EndIf	
				EndIf
				If mv_par22 == 1
					If !lGraph
						FmtLin({,STR0044+" "+aTotal[i,6],,,,,Transform(aTotal[i,5], "@E 999,999,999,999.99")},aL[15],,,@nLin)
					Else
						FmtLinR4(oReport,{,STR0044+" "+aTotal[i,6],,,,,Transform(aTotal[i,5], "@E 999,999,999,999.99")},aL[15],,,@nLin)
					EndIf	
				EndIf
			Else
				If !lGraph
					FmtLin({,STR0024,,,,,Transform(aTotal[i,5], "@E 999,999,999,999.99")},aL[15],,,@nLin)			//"TOTAL ====>"
				Else
					FmtLinR4(oReport,{,STR0024,,,,,Transform(aTotal[i,5], "@E 999,999,999,999.99")},aL[15],,,@nLin)			//"TOTAL ====>"
				EndIf	
				cTipAnt := "X"
			EndIf
		EndIf
		If nLin >= 55
			R460EmBranco(@nLin,If(!lGraph,.F.,.T.),If(lGraph,oReport,))
		EndIf
	Next i
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �R460SemEst()   �Autor�Rodrigo A Sartorio  � Data � 31.10.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Imprime informacao sem estoque                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nLin - Numero da linha corrente                            ���
���          � nPagina - Numero da pagina corrente                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function R460SemEst(nLin,nPagina,lGraph,oReport)
Local aL := R460LayOut(lGraph)

Default lGraph := .F.

If !lGraph
	FmtLin(Array(7),aL[15],,,@nLin)
	FmtLin({,STR0030,,,,,},aL[15],,,@nLin) //"ESTOQUE INEXISTENTE"
Else
	FmtLinR4(oReport,Array(7),aL[15],,,@nLin)
	FmtLinR4(oReport,{,STR0030,,,,,},aL[15],,,@nLin) //"ESTOQUE INEXISTENTE"
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �AjustaSX1 � Autor � Nereu Humberto Jr     � Data �21.03.2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Cria as perguntas necesarias para o programa                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function AjustaSX1()
Local aHelpPor := {}
Local nTamSX1  := Len(SX1->X1_GRUPO)

//---- Remove pergunta referente a poder de terceiros -----------------------
dbSelectArea("SX1")
dbSetOrder(1)
If dbSeek(PADR("MTR46Z",nTamSX1)+"19") .And. Upper(Left(SX1->X1_PERGUNT,6)) <> "QUANTO"
	RecLock("SX1",.F.)
	dbDelete()
	MsUnlock()
EndIf

//---- Remove pergunta referente a qtde Paginas/Feixes -----------------------
If dbSeek(PADR("MTR46Z",nTamSX1)+"11") .And. Upper(SubStr(SX1->X1_PERGUNT,1,3)) <> "QTD"
	Reclock("SX1",.F.)
	dbDelete()
	MsUnlock()
EndIf

//------------------------------- mv_par11 -----------------------------------
aHelpPor := {	"Informa no TERMO DE ABERTURA do livro "  ,;
				"de Registro de Inventario Modelo P7 a "  ,;
				"QUANTIDADE de paginas impressas.      "  ,;
				"Observa��o: O conteudo desta pergunta "  ,;
				"e descritiva e somente sera utilizada "  ,;
				"para preencher o termo de abertura. A "  ,;
				"pergunta somente sera utilizada em  "    ,;
				"conjunto com 'Imprime?' igual 'Termos'"  ,;
			}

PutSX1Help("P.MTR46011.",aHelpPor,,)

//u_MTPutSx1( "MTR460","11","Qtd P�ginas/Feixes?","Ctd. Paginas/Resma?","Qtty Pages/Bundle","mv_chb","N",5,0,0,"G","","","","","mv_par11","","","","","","","","","","","","","","","","",aHelpPor,,)

//------------------------------- mv_par12 -----------------------------------
aHelpPor := {	"Informa no TERMO DE ABERTURA do livro "  ,;
				"de Registro de Inventario Modelo P7 a "  ,;
				"NUMERA��O do Livro.                   "  ,;
				"Observa��o: A pergunta somente sera   "  ,;
				"utilizada em conjunto com 'Imprime?'  "  ,;
				"igual 'Termos'.                       "  ,;
				"                                      "  ,;
			}

PutSX1Help("P.MTR46012.",aHelpPor,,)

//------------------------------- mv_par19 -----------------------------------
aHelpPor := {	"Informe o tipo de quebra por Aliquota " ,;
				"- Nao Quebrar                         " ,;
              	"- ICMS Produto                        " ,;
              	"- ICMS Redu��o                        " ,;
              	"                                      " ,;
             }

PutSX1Help("P.MTR46019.",aHelpPor,,)

//u_MTPutSx1( "MTR46Z","19","Quanto a quebra por aliquota ?","","","mv_chj","N",1,0,1,"C","","","","","mv_par19","Nao Quebrar","","","","Icms Produto","","","Icms Reducao","","","","","","","","",aHelpPor,,)

//------------------------------- mv_par20 -----------------------------------
aHelpPor := { "Pergunta utilizada para verificar se"  ,;
              "devera imprimir as requisicoes para"   ,;
              "MOD com saldo em processo."            ,;
              "Somente utilizada em conjunto com "    ,;
              "a pergunta 'Saldo em Processo'"        ,;
             }
            
//u_MTPutSx1( "MTR46Z", "20","Lista MOD Processo?","�Lista MOD Processo?","Lista MOD Processo?","mv_chk","N",1,0,2,"C","","","","","mv_par20","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpPor,,)

//------------------------------- mv_par21 -----------------------------------
aHelpPor := {'Seleciona as filiais desejadas. Se NAO',;
              'apenas a filial corrente sera afetada.',;
              '' }

//u_MTPutSx1(	'MTR46Z','21','Seleciona filiais?','�Selecciona sucursales?','Select branch offices?','mv_chl','N',1,0,2,'C','','','','','mv_par21','Sim','Si','Yes','','Nao','No','No','','','','','','','','','',aHelpPor,,,'')
    	
//------------------------------- mv_par02 -----------------------------------
If dbSeek(PADR("MTR46Z",nTamSX1)+"02",.F.)
	If Empty(X1_DEF04)
		RecLock("SX1",.F.)
		X1_TIPO := "N"
		X1_DEF03   := "De Terceiros"
		X1_DEFSPA3 := "De Terceros"
		X1_DEFENG3 := "From 3rd Party"
		X1_DEF04   := "Em Terceiros"
		X1_DEFSPA4 := "En Terceros"
		X1_DEFENG4 := "In 3rd Party"
		MsUnlock()
	EndIf           
	//-- Ajustar o Help da Pergunta
	aHelpPor := {	"Considera o saldo De/Em poder de        "    ,;
					"terceiros na impress�o do relatorio.    "    ,;
					"OP�AO 'SIM' :                           "    ,;
					"Considera o saldo De/Em Terceiros.      "    ,;
					"OP��O 'NAO' :                           "    ,;
					"N�o considera o saldo De/Em Terceiros.  "    ,;
					"OP��O 'DE TERCEIROS' :                  "    ,;
					"Considera somente o saldo De terceiros. "    ,;
					"OP��O 'EM TERCEIROS' :                  "    ,;
					"Considera somente o saldo Em terceiros. "    ,;
				}

	PutSX1Help("P.MTR46002.",aHelpPor,,)
EndIf

//------------------------------- mv_par03 -----------------------------------
If dbSeek(PADR("MTR46Z",nTamSX1)+"03") .And. !("MTR460VAlm" $ X1_VALID)
	RecLock("SX1",.F.)
	If Empty(X1_VALID) .Or. "MTR900VAlm" $ X1_VALID
		X1_VALID := "MTR460VAlm"
	Else
		X1_VALID := X1_VALID+".And.MTR460VAlm"
	EndIf
	MsUnlock()
EndIf

//------------------------------- mv_par04 -----------------------------------
If dbSeek(PADR("MTR46Z",nTamSX1)+"04") .And. !("MTR460VAlm" $ X1_VALID)
	RecLock("SX1",.F.)
	If Empty(X1_VALID) .Or. "MTR900VAlm" $ X1_VALID
		X1_VALID := "MTR460VAlm"
	Else
		X1_VALID := X1_VALID+".And.MTR460VAlm"
	EndIf
	MsUnlock()
EndIf

//------------------------------- mv_par07 -----------------------------------
aHelpPor := { "Considera o Produto sem movimento em         "	,;
              "estoque, nao aplicado para os movimentos     "	,;
              "em processo e poder de terceiros.            "	 }

PutSX1Help("P.MTR46007.",aHelpPor,,)

//------------------------------- mv_par22 -----------------------------------
aHelpPor := {	"Informe se deseja quebrar o relatorio "    ,;
				"por Situa��o Tributaria."                  ,;
				"Op��es:"                                   ,;
				"NAO - Nao realiza a quebra (Padrao)"       ,;
				"SIM - Quebra o relatorio por situa��o "    ,;
				"tributaria desconsiderando a pergunta"     ,;
				"'Quanto a quebra por aliquota?'"           ,;
			 }
//u_MTPutSx1( "MTR46Z","22","Quebrar por Sit.Tributaria?","","","mv_chn","N",1,0,2,"C","","","","","mv_par22","Sim","","","","Nao","","","","","","","","","","","",aHelpPor,,)

//------------------------------- mv_par23 -----------------------------------
aHelpPor := {	"Informe se deseja gerar o arquivo "   ,;
				"de exportado para o SPED FISCAL. "    ,;
			 }
//u_MTPutSx1( "MTR46Z","23","Gerar Arq. Exportacao?","","","mv_cho","N",1,0,2,"C","","","","","mv_par23","Sim","","","","Nao","","","","","","","","","","","",aHelpPor,,)

//------------------------------- mv_par24 -----------------------------------
aHelpPor := {	"Informe o nome do arquivo que ser� "   ,;
				"exportado para o SPED FISCAL. "        ,;
			 }
//u_MTPutSx1( "MTR46Z","24","Arquivo Exp. Sped Fiscal?","","","mv_chp","C",8,0,0,"G","","","","","mv_par24","","","","","","","","","","","","","","","","",aHelpPor,,)

//------------------------------- mv_par25 -----------------------------------
aHelpPor := {	'Aglutina a impress�o do relat�rio por',;
      			'CNPJ+IE respeitando a sele��o de filiais '      ,;
      			'realizada pelo usu�rio. Este tratamento'       ,;
      			'somente ser� realizado quando utilizada'    ,;
				'a pergunta de sele��o de filiais.'	}

//u_MTPutSx1("MTR46Z","25","Aglutina por CNPJ+IE","Aglutina por CNPJ+IE","Agglutna. by CNPJ+IE","mv_chq","N",1,0,2,"C","","","","","mv_par25","Sim","Si","Yes","","N�o","No","No","","","","","","","","","",aHelpPor)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ImpListSX1� Autor � Nereu Humberto Junior � Data � 01.08.05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina de impressao da lista de parametros do SX1 sem cabec���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ImpListSX1(titulo,nomeprog,tamanho,char,lFirstPage)        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cTitulo - Titulo                                           ���
���          � cNomPrg - Nome do programa                                 ���
���          � nTamanho- Tamanho                                          ���
���          � nchar   - Codigo de caracter                               ���
���          � lFirstpage - Flag que indica se esta na primeira pagina    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ImpListSX1(cTitulo,cNomPrg,nTamanho,nChar,lFirstPage)
Local cAlias	:= ""
Local cVar		:= ""
Local nCont		:= 0
Local nLargura	:= 0
Local nLin		:= 0
Local nTamSX1 	:= Len(SX1->X1_GRUPO)
Local lWin		:=.F.
Local aDriver 	:= ReadDriver()

PRIVATE cSuf := ""

lWin := "DEFAULT"$ FWSFUser(PswRecno(),"PROTHEUSPRINTER","USR_DRIVEIMP")

nLargura   := IIf(nTamanho=="P",80,IIf(nTamanho=="G",220,132))
cTitulo    := IIf(TYPE("NewHead")!="U",NewHead,cTitulo)
lFirstPage := IIf(lFirstPage==Nil,.F.,lFirstPage)

If lFirstPage
	If GetMv("MV_SALTPAG",,"S") == "N"
		Setprc(0,0)
	EndIf	
	If nChar == NIL
		@0,0 PSAY AvalImp(132)
	Else
		If nChar == 15
			@0,0 PSAY &(if(nTamanho=="P",aDriver[1],if(nTamanho=="G",aDriver[5],aDriver[3])))
		Else
			@0,0 PSAY &(if(nTamanho=="P",aDriver[2],if(nTamanho=="G",aDriver[6],aDriver[4])))
		EndIf
	EndIf
EndIf	

cFileLogo := "LGRL"+SM0->M0_CODIGO+SM0->M0_CODFIL+".BMP" // Empresa+Filial
If !File(cFileLogo)
	cFileLogo := "LGRL"+SM0->M0_CODIGO+".BMP" // Empresa
EndIf

__ChkBmpRlt(cFileLogo) // Seta o bitmap, mesmo que seja o padr�o da microsiga

If GetMv("MV_IMPSX1") == "S" .And. Substr(cAcesso,101,1) == "S" .And. m_pag == 1  // Imprime pergunta no cabecalho
	nLin   := 0
	nLin   := SendCabec(lWin, nLargura, cNomPrg, RptParam+" - "+Alltrim(cTitulo), "", "", .F.)
	cAlias := Alias()
	dbSelectArea("SX1")
	dbSeek(PADR("MTR46Z",nTamSX1))
	While !EOF() .And. X1_GRUPO == PADR("MTR46Z",nTamSX1)
		cVar := "MV_PAR" +StrZero(Val(X1_ORDEM),2,0)
		nLin += 1
		@nLin,5 PSAY RptPerg +" " +X1_ORDEM +" : " +ALLTRIM(X1_PERGUNTA)
		If X1_GSC == "C"
			xStr := StrZero(&(cVar),2)
		EndIf
		@ nLin,Pcol()+3 PSAY IIF(X1_GSC!='C',&(cVar),IIF(&(cVar)>0,X1_DEF&xStr,""))
		dbSkip()
	EndDo

	cFiltro := IIF(!Empty(aReturn[7]),MontDescr(cAlias,aReturn[7]),"")
	nCont := 1
	
	If !Empty(cFiltro)
		nLin += 2
		@ nLin,5 PSAY OemToAnsi(STR0032) +Substr(cFiltro,nCont,nLargura-19)  // "Filtro      : "
		While Len(Alltrim(Substr(cFiltro,nCont))) > (nLargura-19)
			nCont += nLargura - 19
			nLin++
			@ nLin,19 PSAY Substr(cFiltro,nCont,nLargura-19)
		End	
		nLin++
	EndIf
	nLin++
	@ nLin,00 PSAY REPLI("*",nLargura)
	dbSelectArea(cAlias)
EndIf

m_pag++

If Subs(__cLogSiga,4,1) == "S"
	__LogPages()
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MTR460CUnf � Autor �Nereu Humberto Junior  � Data �29/08/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Ajusta grupo de perguntas p/ Custo Unificado                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR460                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MTR460CUnf(lCusUnif)
Local aSvAlias	:= GetArea()
Local nTamSX1 	:= Len(SX1->X1_GRUPO)

dbSelectArea("SX1")
If dbSeek(PADR("MTR46Z",nTamSX1)+"03",.F.) .And. lCusUnif .And. X1_CNT01 != "**"
	RecLock("SX1",.F.)
	X1_CNT01 := "**"
	MsUnlock()
EndIf
If dbSeek(PADR("MTR46Z",nTamSX1)+"04",.F.) .And. lCusUnif .And. X1_CNT01 != "**"
	RecLock("SX1",.F.)
	X1_CNT01 := "**"
	MsUnlock()
EndIf

RestArea(aSvAlias)
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �SaldoD3CF9 � Autor �Rodrigo de A Sartorio  � Data �30/12/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Retorna saldo dos movimentos RE9/DE9 relacionados ao produto���
�������������������������������������������������������������������������Ĵ��
���Parametros�cProduto - Codigo do produto a ter os movimentos pesquisados���
���          �dDataIni - Data inicial para pesquisa dos movimentos        ���
���          �dDataFim - Data final para pesquisa dos movimentos          ���
���          �cAlmoxIni- Armazem inicial para pesquisa dos movimentos     ���
���          �cAlmoxFim- Armazem final para pesquisa dos movimentos       ���
�������������������������������������������������������������������������Ĵ��
��� Retorno  �aDadosCF9- Array com quantidade e valor requisitado atraves ���
���          �de movimentos RE9 / DE9                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR460                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function SaldoD3CF9(cProduto,dDataini,dDataFim,cAlmoxIni,cAlmoxFim)
Local aArea     := GetArea()
Local cIndSD3   := ''
Local cQuery 	:= ''
Local aDadosCF9 := {0,0} // Quantidade e custo na 1a moeda para movimentos do SD3 com D3_CF RE9 ou DE9

Default dDataIni := GETMV("MV_ULMES")+1

dbSelectArea("SD3")
#IFNDEF TOP
   	cIndSD3:=Substr(CriaTrab(NIL,.F.),1,7)+"T"
	cQuery := 'D3_FILIAL =="'+xFilial('SD3')+'".And.D3_ESTORNO=="'+Space(Len(SD3->D3_ESTORNO))+'".And.(D3_CF == "RE9" .Or. D3_CF == "DE9").And.DtoS(D3_EMISSAO)>="'+DtoS(dDataIni)+'".And.DtoS(D3_EMISSAO)<="'+DtoS(dDataFim)+'".And.D3_COD=="'+cProduto+'".And.D3_LOCAL>="'+cAlmoxIni+'".And.D3_LOCAL<="'+cAlmoxFim+'"'
	IndRegua("SD3",cIndSD3,"D3_FILIAL+D3_COD+D3_LOCAL",,cQuery)
	nIndSD3:=RetIndex("SD3")
	dbSetIndex(cIndSD3+OrdBagExt())
	dbSetOrder(nIndSD3+1)
	dbGoTop()
#ELSE
	cIndSD3:= GetNextAlias()
	cQuery := "SELECT D3_CF,D3_QUANT,D3_CUSTO1 FROM "+RetSqlName("SD3")+" SD3 "
	cQuery += "WHERE SD3.D3_FILIAL='"+xFilial("SD3")+"' AND SD3.D3_ESTORNO ='"+Space(Len(SD3->D3_ESTORNO))+"' "
	cQuery += "AND SD3.D3_CF IN ('RE9','DE9') "
	cQuery += "AND SD3.D3_EMISSAO >= '" + DTOS(dDataIni) + "' "
	cQuery += "AND SD3.D3_EMISSAO <= '" + DTOS(dDataFim) + "' "
	cQuery += "AND SD3.D3_COD = '" +cProduto+ "' "
	cQuery += "AND SD3.D3_LOCAL >= '" +cAlmoxIni+ "' "
	cQuery += "AND SD3.D3_LOCAL <= '" +cAlmoxFim+ "' "
	cQuery += "AND SD3.D_E_L_E_T_=' ' "
	cQuery += "ORDER BY D3_FILIAL,D3_COD,D3_LOCAL"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cIndSD3,.T.,.T.)
	aEval(SD3->(dbStruct()), {|x| If(x[2] <> "C" .And. FieldPos(x[1]) > 0, TcSetField(cIndSD3,x[1],x[2],x[3],x[4]),Nil)})
#ENDIF
While !Eof()
	If D3_CF == "RE9"
		aDadosCF9[1] += D3_QUANT
		aDadosCF9[2] += D3_CUSTO1
	ElseIf D3_CF == "DE9"
		aDadosCF9[1] -= D3_QUANT
		aDadosCF9[2] -= D3_CUSTO1
	EndIf				 
	dbSkip()
End

//-- Restaura ambiente e apaga arquivo temporario
#IFDEF TOP
	dbSelectArea(cIndSD3)
	dbCloseArea()
	dbSelectArea("SD3")
#ELSE
	dbSelectArea("SD3")
	dbClearFilter()
	RetIndex("SD3")
	Ferase(cIndSD3+OrdBagExt())
#ENDIF

RestArea(aArea)
Return aDadosCF9
               
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GetOracleVe� Autor �Guilherme C.L.Oliveira � Data �25/05/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Obtem a Versao do ORACLE                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
��� Retorno  �Versao do Oracle                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR460                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
#IFDEF TOP
	Static Function GetOracleVersion()
	Local aArea  	:= GetArea()
	Local cQuery 	:= "select * from v$version"
	Local cAlias 	:= "_Oracle_version"
	Local nVersion	:= 0
	
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)
	nVersion := Val(SubString((cAlias)->BANNER,At("Release",(cAlias)->BANNER)+8,1))
	dbCloseArea()
	
	RestArea(aArea)
	Return nVersion
#ENDIF

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o  	 �FmtLinR4()� Autor � Nereu Humberto Junior � Data � 31.07.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Formata linha para impressao                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FmtLinR4(oReport,aValores,cFundo,cPictN,cPictC,nLin,lImprime,bCabec,nTamLin)
//-- Variaveis da funcao
Local cConteudo	:= ''
Local cLetra   	:= ''
Local nPos     	:= 0
Local i        	:= 0
Local j        	:= 0
//-- Sets para a Funcao, mudar se necessario
Local cPictNPad := '@E 999,999,999.99'
Local cPictCPad := '@!'
Local cCharOld  := '#'
Local cCharBusca:= '�'
Local cTipoFundo:= ValType(cFundo)
Local nFor      := 1
Local aArea		:= GetArea()

//-- Troca # por cCharBusca pois existem dados com # que devem
//-- ser impressos corretamente.
If cTipoFundo == "C"
	cFundo := StrTran(cFundo,cCharOld,cCharBusca)
ElseIf cTipoFundo == "A"
	For i := 1 To Len(cFundo)
		cFundo[i] := StrTran(cFundo[i],cCharOld,cCharBusca)
	Next i
EndIf

aValores := IIf(Empty(aValores),{},aValores)
aValores := IIf(cTipoFundo == "C",aValores,{})
lImprime := IIf(lImprime == NIL,.T.,lImprime)

//-- Substitue o caracter cCharBusca por "_" nas strings
For nFor := 1 To Len(aValores)
	If ValType(aValores[nFor]) == "C" .And. At(cCharBusca,aValores[nFor]) > 0
		aValores[nFor]:=StrTran(aValores[nFor],cCharBusca,"_")
	EndIf
Next nFor

//-- Efetua quebra de pagina com impressao de cabecalho
If bCabec != NIL .And. nLin > 55
	nTamLin := Iif(nTamLin==NIL,220,nTamLin)
	nLin++
	oReport:PrintText("+"+Replic("-",nTamLin-2)+"+")
	Eval(bCabec)
EndIf

//-- Rotina de substituicao
For i := 1 to Len(aValores)
	If ValType(aValores[i]) == 'A'
		If !Empty(aValores[i,2])
			cConteudo := Transform(aValores[i,1],aValores[i,2])
		Else
			If Type(aValores[i,1]) == 'N'
				cConteudo := Str(aValores[i,1])
			Else
				cConteudo := aValores[i,1]
			EndIf
		EndIf
	Else
		cPictN := Iif(Empty(cPictN),cPictNPad,cPictN)
		cPictC := Iif(Empty(cPictC),cPictCPad,cPictC)
		aValores[i] := Iif(aValores[i] == NIL,"",aValores[i])
		If ValType(aValores[i]) == 'N'
			cConteudo := Transform(aValores[i],cPictN)
		Else
			cConteudo := Transform(aValores[i],cPictC)
		EndIf
	EndIf
	nPos := 0
	cFormato := ""
	nPos := At(cCharBusca,cFundo)
	If nPos > 0
		cLetra := cCharBusca
		j := nPos
		While cLetra == cCharBusca
			cLetra := Substr(cFundo,j,1)
			If cLetra == cCharBusca
				cFormato += cLetra
			EndIf
			j++
		End
		If Len(cFormato) > Len(cConteudo)
			If ValType(aValores[i]) <> 'N'
				cConteudo += Space(Len(cFormato)-Len(cConteudo))
			Else
				cConteudo := Space(Len(cFormato)-Len(cConteudo)) +cConteudo	
			EndIf
		EndIf
		cFundo := Stuff(cFundo,nPos,Len(cConteudo),cConteudo)
	EndIf
Next i

//-- Imprime linha formatada
If lImprime
	If cTipoFundo == "C"
		nLin++
		oReport:PrintText(cFundo)
	Else
		For i := 1 to Len(cFundo)
			nLin++
			oReport:PrintText(cFundo[i])
		Next i
	EndIf
EndIf

//-- Devolve array de dados com mesmo tamanho mas vazio
If Len(aValores) > 0
	aValores := Array(Len(aValores))
EndIf

RestArea(aArea)
Return cFundo

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MTR460VAlm � Autor �Nereu Humberto Junior  � Data �01/08/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida Almoxarifado do KARDEX com relacao a custo unificado ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR460                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MTR460VAlm()
Local lRet		:= .T.
Local cConteudo	:= &(ReadVar())
Local nOpc		:= 2

//-- Verifica se utiliza custo unificado por Empresa/Filial
Local lCusUnif := IIf(FindFunction("A330CusFil"),A330CusFil(),GetMV("MV_CUSFIL",.F.))

If lCusUnif .And. cConteudo != "**"
	nOpc := Aviso(STR0035,STR0036,{STR0037,STR0038})	//"Aten��o"###"Ao alterar o almoxarifado o custo medio unificado sera desconsiderado."###"Confirma"###"Abandona"
	If nOpc == 2
		lRet := .F.
	EndIf
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �R460STrib  � Autor �Microsiga S/A          � Data �12/06/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao utilizada para verificar qual a situacao triburia    ���
���          �do produto a ser impresso.                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cProduto - Codigo do Produto                                ���
�������������������������������������������������������������������������Ĵ��
��� Retorno  �Caracter                                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR460                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function R460STrib(cProduto)
Local aAreaAnt := GetArea()
Local aAreaSB1 := SB1->(GetArea())
Local aAreaSD1 := SD1->(GetArea())
Local aAreaSD2 := SD2->(GetArea())
Local cSitTrib := ''
Local lContinua:= .T.

dbSelectArea('SB1')
dbSetOrder(1)
If dbSeek(xFilial('SB1')+cProduto) .And. !Empty(RetFldProd(SB1->B1_COD, "B1_TE"))
	cSitTrib := AllTrim(RetFldProd(SB1->B1_COD,"B1_ORIGEM")) +"-"
	//-- Analisa Situacao Tributaria atraves da TES de Entrada Padrao
	If !Empty(RetFldProd(SB1->B1_COD,"B1_TE"))
		dbSelectArea('SF4')
		dbSetOrder(1)
		If dbSeek(xFilial('SF4')+RetFldProd(SB1->B1_COD,"B1_TE")) .And. !Empty(SF4->F4_SITTRIB)
			cSitTrib  := cSitTrib +AllTrim(SF4->F4_SITTRIB)
			lContinua := .F.
		EndIf
	//-- Analisa Situacao Tributaria atraves da TES de Saida Padrao
	ElseIf !Empty(RetFldProd(SB1->B1_COD,"B1_TS"))
		dbSelectArea('SF4')
		dbSetOrder(1)
		If dbSeek(xFilial('SF4')+RetFldProd(SB1->B1_COD,"B1_TS")) .And. !Empty(SF4->F4_SITTRIB)
			cSitTrib  := cSitTrib +AllTrim(SF4->F4_SITTRIB)
			lContinua := .F.
		EndIf
	EndIf

	//-- Quando nao for cadastrada a TES padrao analisar os documentos
	//-- de Entrada/Saida.
	If lContinua
		//-- Analisa Situacao Tributaria atraves do Documento de Entrada
		dbSelectArea('SD1')
		dbSetOrder(2)
		dbSeek(xFilial('SD1')+cProduto+Replicate("z",Len(SD1->D1_DOC)),.T.)
		dbSkip(-1)
		While !Bof() .And. cProduto == SD1->D1_COD .And. SD1->D1_TIPO == "C"
			dbSkip(-1)
		End
		dbSelectArea('SF4')
		dbSetOrder(1)
		If dbSeek(xFilial('SF4')+SD1->D1_TES) .And. !Empty(SF4->F4_SITTRIB)
			cSitTrib  := cSitTrib +AllTrim(SF4->F4_SITTRIB)
			lContinua := .F.   
		EndIf
	EndIf

	//-- Quando nao e localizada a situacao tributaria na TES informa
	//-- o codigo 90 - Outras.
	If lContinua .And. Len(Alltrim(cSitTrib)) == 2
		cSitTrib := cSitTrib +'90'
	EndIf	
EndIf

RestArea(aAreaSD1)
RestArea(aAreaSD2)
RestArea(aAreaSB1)
RestArea(aAreaAnt)
Return IIf(Empty(cSitTrib),'0-90',cSitTrib)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �R460GravZ  � Autor �Microsiga S/A          � Data �19/06/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �Funcao utilizada para realizar a gravacao do registro na    ���
���          �tabela temporaria referente ao saldo em processo.           ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cProduto  - Codigo do Produto                               ���
���          �cLocal    - Codigo do Armazem                               ���
���          �nQtde     - Quantidade                                      ���
���          �nCusto    - Custo na Moeda 1                                ���
���          �nRecnoSD3 - Numero do Recno da Tabela SD3                   ���
���          �cTipo     - Tipo DE/RE                                      ���
���          �cArqTemp  - Alias do arquivo de trabalho                    ���
���          �cAliasSD3 - Alias da Query SD3                              ���
���          �lFiscal   - Indica processamento para o Sintegra            ���
���          �aNCM      - Aglutina o resultado por NCM                    ���
���          �lTipoBN   - Tratamento para produtos BN (Beneficiamento)    ���
���          �cFilCons - Filial que solicitou impressao do relatorio	    ���
�������������������������������������������������������������������������Ĵ��
��� Retorno  �Nill                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR460                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function R460Gravz(cProduto,cLocal,nQtde,nCusto,nRecnoSD3,cTipo,cArqTemp,cAliasSD3,lFiscal,aNCM,lTipoBN,cFilCons)
Local aAreaAnt 	:= GetArea()
Local aAreaSB1 	:= SB1->(GetArea())
Local nPosNCM  	:= 0
Local lConsolida:= mv_par21 == 1 .And. mv_par25 == 1

Default cTipo     := ''
Default nRecnoSD3 := 0   
Default lFiscal   := .F.
Default aNCM	  := {}
Default lTipoBN   := .F.

//-- Posiciona tabela SB1
If SB1->B1_COD != cProduto
    SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+cProduto))
EndIf

//-- Gravacao do registro no arquivo temporario
If SB1->B1_COD == cProduto
	(cArqTemp)->(dbSetOrder(2))
	If (cArqTemp)->(dbSeek(SB1->B1_COD+"2"))
		RecLock(cArqTemp,.F.)
	Else
		RecLock(cArqTemp,.T.)
		(cArqTemp)->FILIAL		:= xFilial("SB2",cFilCons)
		(cArqTemp)->SITUACAO		:= "2"
		(cArqTemp)->TIPO			:= IIf(lTipoBN,SB1->B1_TIPOBN,SB1->B1_TIPO)
		(cArqTemp)->POSIPI		:= SB1->B1_POSIPI
		(cArqTemp)->PRODUTO		:= SB1->B1_COD
		(cArqTemp)->DESCRICAO	:= SB1->B1_DESC
		(cArqTemp)->UM			:= SB1->B1_UM
		If nQuebraAliq == 2
			(cArqTemp)->ALIQ := SB1->B1_PICM
		ElseIf nQuebraAliq == 3
			(cArqTemp)->ALIQ := IIf(SB0->(MsSeek(xFilial("SB0")+SB1->B1_COD)),SB0->B0_ALIQRED,0)
		EndIf
		If mv_par22 == 1
			(cArqTemp)->SITTRIB := R460STrib(SB1->B1_COD)
		EndIf
	EndIf
	Do Case
		Case cTipo == "RE" .Or. Empty(cTipo)
			(cArqTemp)->QUANTIDADE	+= nQtde
			(cArqTemp)->TOTAL			+= nCusto
		Case cTipo == "DE"
			(cArqTemp)->QUANTIDADE 	-= nQtde
			(cArqTemp)->TOTAL			-= nCusto
	EndCase
	If (cArqTemp)->QUANTIDADE > 0
		(cArqTemp)->VALOR_UNIT := (cArqTemp)->(NoRound(TOTAL/QUANTIDADE,nDecVal))
	EndIf

	//-- Este Ponto de Entrada foi criado para recalcular o Valor Unitario/Total
	If lCalcUni
		//-- Posiciona na tabela SD3
		If nRecnoSD3 <> 0
			SD3->(dbGoto(nRecnoSD3))
			//-- Chamada do Ponto de Entrada
			ExecBlock("A460UNIT",.F.,.F.,{cProduto,cLocal,mv_par14,cArqTemp})
		Else
			//-- Chamada do Ponto de Entrada
			ExecBlock("A460UNIT",.F.,.F.,{cProduto,cLocal,mv_par14,cArqTemp})
		EndIf	
	EndIf       

	//-- Aglutina por NCM quando a funcao e chamada pelo fiscal
	//-- para a geracao do Sintegra e nao para a impressao do livro fiscal
	If lFiscal
		nPosNCM := aScan(aNCM,{|x| x[1] == (cArqTemp)->POSIPI}) 
		If nPosNCM > 0 
			aNCM[nPosNCM][02] += (cArqTemp)->QUANTIDADE
			aNCM[nPosNCM][03] += (cArqTemp)->TOTAL                         
		Else
			(cArqTemp)->(aAdd(aNCM,{POSIPI,QUANTIDADE,TOTAL}))
		Endif
	Endif
	(cArqTemp)->(MsUnLock())
EndIf

RestArea(aAreaSB1)
RestArea(aAreaAnt)
Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �R460GrvTRB     �Autor�TOTVS S/A           � Data � 12/03/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �Esta funcao e utilizada para gravacao do arquivo de trabalho���
���          �para exportacao de dados do SPED FISCAL.                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Retorno  � Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function R460GrvTRB(aTerceiros,cArqTemp,cFilImp,cFilP7)
Local aAreaAnt		:= GetArea()
Local aAreaSB1		:= SB1->(GetArea())
Local aArqTemp		:= {}  
local aRetPe		:= {}
Local cNomeArq		:= AllTrim(mv_par24)
Local cNomeIdx		:= CriaTrab(NIL,.F.)
Local cIndice		:= ""
Local nCnt			:= 0
Local lConsolida	:= mv_par21 == 1 .And. mv_par25 == 1

Default aTerceiros:= {}
Default cFilP7		:= ""
Default cFilImp	:= ""

//-- Verifica se n�o est� na mesma filial, n�o cria TRB novamente
//-- Realiza a Abertura/Criacao da tabela 'TRB'
If (Empty(cFilP7) .Or. cFilImp == cFilP7) .And. Select("TRB") <= 0
	aArqTemp := A460ArqTmp(2,@cIndice)

	dbCreate(cNomeArq,aArqTemp,__LocalDriver)
	dbUseArea(.T.,__LocalDriver,cNomeArq,"TRB",.T.,.F.)
	INDEX ON &(cIndice) TAG &(cNomeIdx) TO &(cNomeIdx+OrdBagExt())
	TRB->(dbClearIndex())
	TRB->(dbSetIndex(cNomeIdx+OrdBagExt()))
EndIf

//-- A460ALTRB - Ponto de entrada Alterar dados gravados na TRB
If ExistBlock("A460ALTRB") .And. Valtype(aRetPe := ExecBlock("A460ALTRB",.F.,.F.,{aTerceiros})) =="A"
  	aTerceiros := aRetPe
EndIf

// Atualiza Saldo De/Em Terceiros
For nCnt := 1 to Len(aTerceiros)
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+PadR(AllTrim(aTerceiros[nCnt,2]),TamSX3("B1_COD")[1])))

	//Se atender esta condi��o ent�o n�o dever� gravar no arquvo DBF
	//pois trata de valores negativos e o relat�rio foi emitido com op��o de N�O exibir valores negativos
	//Desta maneira n�o ir� gerar valor negativo no bloco H do SPED FISCAL.
	If 	(!mv_par08 == 1 .And. aTerceiros[nCnt,5] < 0) .Or.;
		(!mv_par09 == 1 .And. aTerceiros[nCnt,5] == 0) .Or.;
		(!mv_par16 == 1 .And. aTerceiros[nCnt,6] == 0)
		Loop
	EndIf
	
	If lConsolida .And. TRB->(dbSeek(aTerceiros[nCnt,1]+aTerceiros[nCnt,8]+aTerceiros[nCnt,3]+aTerceiros[nCnt,4]+aTerceiros[nCnt,2]))
		RecLock("TRB",.F.)
	Else
		RecLock("TRB",.T.)
	EndIf
	TRB->FILIAL		:= xFilial("SB2")
	TRB->SITUACAO		:= aTerceiros[nCnt,1]
	TRB->PRODUTO		:= aTerceiros[nCnt,2]
	TRB->CLIFOR		:= aTerceiros[nCnt,3]
	TRB->LOJA			:= aTerceiros[nCnt,4]
	TRB->UM			:= SB1->B1_UM
	TRB->QUANTIDADE	:= aTerceiros[nCnt,5]
	TRB->VALOR_UNIT	:= ABS(aTerceiros[nCnt,6] / IIf(aTerceiros[nCnt,5]==0,1,aTerceiros[nCnt,5]))
	TRB->TOTAL			:= aTerceiros[nCnt,6]
	TRB->TPCF			:= aTerceiros[nCnt,8]
	TRB->ARMAZEM		:= SB1->B1_LOCPAD
	TRB->(MsUnLock())
Next nCnt

// Atualiza Saldo em Estoque e Processo
(cArqTemp)->(dbSetOrder(1))
(cArqTemp)->(dbGoTop())
While !(cArqTemp)->(EOF())
	//-- Itens sem saldo nao saem no arquivo e poder de terceiros foi gerado acima
	If (cArqTemp)->SITUACAO $ "3|4|5"
		(cArqTemp)->(dbSkip())
		Loop
	EndIf
	//-- Filtra itens da listagem conforme parametrizacao do relatorio (negativos, zerados e/ou sem custo)
	If 	(!mv_par08 == 1 .And. (cArqTemp)->QUANTIDADE < 0) .Or.;
		(!mv_par09 == 1 .And. (cArqTemp)->QUANTIDADE == 0) .Or.;
		(!mv_par16 == 1 .And. (cArqTemp)->TOTAL == 0)
		(cArqTemp)->(dbSkip())
		Loop
	EndIf
	//-- Garante que No bloco H do SPED havera somente itens com saldo (quantidade ou custo)
	If (cArqTemp)->QUANTIDADE <> 0 .Or. (cArqTemp)->VALOR_UNIT <> 0
		RecLock("TRB",.T.)
		TRB->FILIAL		:= (cArqTemp)->FILIAL
		TRB->SITUACAO		:= (cArqTemp)->SITUACAO
		TRB->PRODUTO		:= (cArqTemp)->PRODUTO
		TRB->UM			:= (cArqTemp)->UM
		TRB->QUANTIDADE	:= (cArqTemp)->QUANTIDADE
		TRB->VALOR_UNIT	:= NoRound((cArqTemp)->TOTAL/(cArqTemp)->QUANTIDADE,nDecVal)
		TRB->TOTAL			:= (cArqTemp)->TOTAL
		TRB->ARMAZEM		:= (cArqTemp)->ARMAZEM   
		TRB->(MsUnLock())
	EndIf
	(cArqTemp)->(dbSkip())
End

cFilP7 := cFilImp

RestArea(aAreaSB1)
RestArea(aAreaAnt)
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A460ArqTmp�Autor  � Andre Anjos		 � Data �  19/07/13   ���
�������������������������������������������������������������������������͹��
���Descricao � Devolve estrutura dos arquivos temporarios usados no rel.  ���
�������������������������������������������������������������������������͹��
���Parametros� nTpArq: tipo do arquivo: 1-IMPRESSAO; 2- SPED			  ���
���			 � cIndice: indice principal do arquivo (referencia)		  ���
�������������������������������������������������������������������������͹��
��� Retorno	 � aRet: estrutura de campos do arquivo de trabalho 		  ���
�������������������������������������������������������������������������͹��
���Uso       � MATR460                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A460ArqTmp(nTpArq,cIndice)
Local aRet := {}

//-- Cria Arquivo Temporario:
//-- SITUACAO: 1=ESTOQUE,2=PROCESSO,3=SEM SALDO,4=DE TERCEIROS,5=EM TERCEIROS,
//--           6=DE TERCEIROS USADO EM ORDENS DE PRODUCAO
aAdd(aRet,{"FILIAL"     ,"C",FWSizeFilial(),0})
aAdd(aRet,{"SITUACAO"	,"C",01,0})
aAdd(aRet,{"PRODUTO"	,"C",TamSX3("B1_COD")[1],0})
aAdd(aRet,{"UM"			,"C",02,0})
aAdd(aRet,{"QUANTIDADE"	,"N",14,Min(TamSX3("B2_QFIM")[2],4)})
aAdd(aRet,{"VALOR_UNIT"	,"N",21,nDecVal})
aAdd(aRet,{"TOTAL"		,"N",21,nDecVal})
aAdd(aRet,{"ARMAZEM"	,"C",TamSx3("B1_LOCPAD")[1],0})
If nTpArq == 1
	aAdd(aRet,{"TIPO"		,"C",02,0})
	aAdd(aRet,{"POSIPI"		,"C",10,0})
	aAdd(aRet,{"DESCRICAO"	,"C",35,0})
	aAdd(aRet,{"ALIQ"	    ,"N",5,2})
	aAdd(aRet,{"SITTRIB"	,"C",4,0})

	//-- Chave do Arquivo de Trabalho
	If mv_par22 == 1
		cIndice := "SITUACAO+TIPO+SITTRIB+PRODUTO"
	Else
		If nQuebraAliq == 1
			cIndice := "SITUACAO+TIPO+POSIPI+PRODUTO"
		ElseIf nQuebraAliq <> 1
			cIndice := "SITUACAO+TIPO+STR(ALIQ,5,2)+PRODUTO"
		EndIf
	EndIf	
ElseIf nTpArq == 2
	aAdd(aRet,{"CLIFOR"	    ,"C",TamSX3("B6_CLIFOR")[1]	,0})
	aAdd(aRet,{"LOJA"		,"C",TamSX3("B6_LOJA")[1]	,0})
	aAdd(aRet,{"TPCF"		,"C",1						,0})
	
	cIndice := "SITUACAO+TPCF+CLIFOR+LOJA+PRODUTO"
EndIf

Return aRet