#Include "Matr120.ch"
#Include "PROTHEUS.Ch"
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � MATR120  � Autor � Nereu Humberto Junior � Data � 12.06.06  ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Emiss�o da Rela��o de Pedidos de Compras                    ���
��������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                      ���
��������������������������������������������������������������������������Ĵ��
���Retorno   � .T.	/  .F.                                                 ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                    ���
��������������������������������������������������������������������������Ĵ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
User Function MATR120()
Local oReport

If TRepInUse()
	//������������������������������������������������������������������������Ŀ
	//�Interface de impressao                                                  �
	//��������������������������������������������������������������������������
	oReport := ReportDef()
	oReport:PrintDialog()
Else
	MATR120R3()
EndIf

Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor �Nereu Humberto Junior  � Data �12.06.2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef(nReg)

Local oReport 
Local oSection1
Local oSection2 
Local oSection3 
Local oSection4
Local oSection5
Local oCell         
Local aOrdem	:= {}
Local cAliasSC7 := GetNextAlias()

PRIVATE cPerg := "MTR120"
//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������
oReport:= TReport():New("MATR120",STR0007,"MTR120", {|oReport| ReportPrint(oReport,cAliasSC7)},STR0001+" "+STR0002+" "+STR0003) //"Relacao de Pedidos de Compras"##"Emissao da Relacao de  Pedidos de Compras."##"Sera solicitado em qual Ordem, qual o Intervalo para"##"a emissao dos pedidos de compras."
oReport:SetLandscape()    
oReport:SetTotalInLine(.F.)
Pergunte("MTR120",.F.)
Aadd( aOrdem, STR0004 ) // "Por Numero"
Aadd( aOrdem, STR0005 ) // "Por Produto"
Aadd( aOrdem, STR0006 ) // "Por Fornecedor"
Aadd( aOrdem, STR0049 ) // "Por Previsao de Entrega "

oSection1 := TRSection():New(oReport,STR0062,{"SC7","SA2","SB1","SC1"},aOrdem) //"Relacao de Pedidos de Compras"
oSection1 :SetTotalInLine(.F.)

TRCell():New(oSection1,"C7_NUM","SC7",STR0065/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Num.PC"
TRCell():New(oSection1,"C7_NUMSC","SC7",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

TRCell():New(oSection1,"C1_SOLICIT","SC1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //SOLICITANTE SC1 RICKY
TRCell():New(oSection1,"C7_OBS","SC7",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)  // OBSERVACAO SC7 RICKY

TRCell():New(oSection1,"C7_FORNECE","SC7",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
//TRCell():New(oSection1,"C7_LOJA","SC7",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"A2_NOME","SA2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
//TRCell():New(oSection1,"A2_TEL","SA2",/*Titulo*/,/*Picture*/,15,/*lPixel*/,/*{|| code-block de impressao }*/)
//TRCell():New(oSection1,"A2_FAX","SA2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"A2_CONTATO","SA2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"C7_PRODUTO","SC7",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oSection1,"cDescri","   ",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| ImpDescri(cAliasSC7) })
TRCell():New(oSection1,"C7_DATPRF","SC7",STR0052,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"ENTREGA PREVISTA :  "
oSection1:Cell("cDescri"):GetFieldInfo("B1_DESC")             

oSection2 := TRSection():New(oSection1,STR0063,{"SC7","SA2","SB1","SC1"}) 
oSection2 :SetTotalInLine(.F.)
oSection2 :SetHeaderPage()
oSection2 :SetTotalText(STR0033) //"Total Geral "

TRCell():New(oSection2,"C7_NUM","SC7",STR0065/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)//"Num.PC"
TRCell():New(oSection2,"C7_ITEM","SC7",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

//TRCell():New(oSection2,"C1_SOLICIT","SC1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //SOLICITANTE SC1 RICKY
//TRCell():New(oSection2,"C7_OBS","SC7",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)  // OBSERVACAO SC7 RICKY

TRCell():New(oSection2,"C7_PRODUTO","SC7",/*Titulo*/,/*Picture*/,,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oSection2,"cDescri","   ",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| ImpDescri(cAliasSC7) })
oSection2:Cell("cDescri"):GetFieldInfo("B1_DESC")
TRCell():New(oSection2,"B1_GRUPO","SB1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"C7_EMISSAO","SC7",STR0068/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)//"Emissao"
TRCell():New(oSection2,"C7_FORNECE","SC7",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
//TRCell():New(oSection2,"C7_LOJA","SC7",STR0067/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)//"Lj"
TRCell():New(oSection2,"A2_NOME","SA2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
//TRCell():New(oSection2,"A2_TEL","SA2",/*Titulo*/,/*Picture*/,15,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"C7_DATPRF","SC7",STR0066/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Entrega"
TRCell():New(oSection2,"C7_QUANT","SC7",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"C7_UM","SC7",STR0069/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)//"UM"
TRCell():New(oSection2,"nVlrUnit","   ",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| ImpVunit(cAliasSC7) }) 
oSection2:Cell("nVlrUnit"):GetFieldInfo("C7_PRECO")
TRCell():New(oSection2,"C7_VLDESC","   ",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| ImpDescon(cAliasSC7) }) 
TRCell():New(oSection2,"nVlrIPI","   ",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| ImpVIPI(cAliasSC7) })
oSection2:Cell("nVlrIPI"):GetFieldInfo("C7_VALIPI")
TRCell():New(oSection2,"C7_TOTAL","SC7",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| ImpVTotal(cAliasSC7) })
TRCell():New(oSection2,"C7_QUJE","SC7",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"nQtdRec","   ",STR0060,PesqPict('SC7','C7_QUANT'),/*Tamanho*/,/*lPixel*/,{|| If(Empty((cAliasSC7)->C7_RESIDUO),IIF((cAliasSC7)->C7_QUANT-(cAliasSC7)->C7_QUJE<0,0,(cAliasSC7)->C7_QUANT-(cAliasSC7)->C7_QUJE),0) }) //Quant.Receber
TRCell():New(oSection2,"nSalRec","   ",STR0061,PesqPict('SC7','C7_TOTAL'),TamSX3("C7_TOTAL")[1],/*lPixel*/,{|| ImpSaldo(cAliasSC7) }) //Saldo Receber
TRCell():New(oSection2,"C7_RESIDUO","   ",STR0070+CRLF+STR0071/*Titulo*/,/*Picture*/,3,/*lPixel*/,{|| If(Empty((cAliasSC7)->C7_RESIDUO),STR0031,STR0032) }) //"Res."##"Elim."

TRFunction():New(oSection2:Cell("nVlrIPI"),NIL,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/,/*uFormula*/,.T.,.T.,,oSection1) 
TRFunction():New(oSection2:Cell("C7_TOTAL"),NIL,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/,/*uFormula*/,.T.,.T.,,oSection1)
TRFunction():New(oSection2:Cell("nSalRec"),NIL,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/,/*uFormula*/,.T.,.T.,,oSection1) 

Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor �Nereu Humberto Junior  � Data �16.05.2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                           ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportPrint(oReport,cAliasSC7)

Local oSection1 := oReport:Section(1) 
Local oSection2 := oReport:Section(1):Section(1)  
Local oBreak
Local nTxMoeda	:= 1
Local lFirst    := .F.
Local nOrdem    := oReport:Section(1):GetOrder() 
Local nTamDPro	:= If( TamSX3("C7_PRODUTO")[1] > 15, 20, 30 )
Local nFilters 	:= 0
Local nI
Local cWhere := ""
Local cFrom := "%%"
Local lFilUsr	:= oSection1:GetAdvplExp() <> ""

dbSelectArea("SC7")
If nOrdem == 4
	dbSetOrder(16) 
Else
	dbSetOrder(nOrdem)
EndIf

If nOrdem == 1
	If ( cPaisLoc$"ARG|POR|EUA" )	//Ordena los pedidos de compra y luego la AE.
		dbSetOrder(10)
	Endif	
	oReport:SetTitle( oReport:Title()+STR0014) // " - POR NUMERO"
	oSection1 :SetTotalText(STR0034) //"Total dos Itens: " 
ElseIf nOrdem == 2
	oReport:SetTitle( oReport:Title()+STR0018) //" - POR PRODUTO"
	oSection1 :SetTotalText(STR0035) //"Total do Produto"
ElseIf nOrdem == 3
	oReport:SetTitle( oReport:Title()+STR0022) //" - POR FORNECEDOR"
	oSection1 :SetTotalText(STR0036) //"Total do Fornecedor"
ElseIf nOrdem == 4
	oReport:SetTitle( oReport:Title()+STR0053) //" - POR PREVISAO DE ENTREGA"
	oSection1 :SetTotalText(STR0043) //"Total da Previsao de Entrega"
Endif

If mv_par07==1
	oReport:SetTitle( oReport:Title()+STR0025) //", Todos"
Elseif mv_par07==2
	oReport:SetTitle( oReport:Title()+STR0026) //", Em Abertos"
Elseif mv_par07==3
	oReport:SetTitle( oReport:Title()+STR0027) //", Residuos"
Elseif mv_par07==4
	oReport:SetTitle( oReport:Title()+STR0028) //", Atendidos"
Elseif mv_par07==5
	oReport:SetTitle( oReport:Title()+STR0059) //", Atendidos + Parcial entregue"
Endif
oReport:SetTitle( oReport:Title()+" - " + GetMv("MV_MOEDA"+STR(mv_par13,1))) //" MOEDA "
//������������������������������������������������������������������������Ŀ
//�Filtragem do relat�rio                                                  �
//��������������������������������������������������������������������������

	//������������������������������������������������������������������������Ŀ
	//�Transforma parametros Range em expressao SQL                            �	
	//��������������������������������������������������������������������������
	MakeSqlExpr(oReport:uParam)
	//������������������������������������������������������������������������Ŀ
	//�Query do relat�rio da secao 1                                           �
	//��������������������������������������������������������������������������
	oReport:Section(1):BeginQuery()	

	cWhere :="%"

	If mv_par11 == 1 
		cWhere += "AND C7_CONAPRO <> 'B' "	
	ElseIf mv_par11 == 2
		cWhere += "AND C7_CONAPRO = 'B' "	
	Endif

	If mv_par07 == 2 
		cWhere += "AND ( (C7_QUANT-C7_QUJE) > 0 ) "	
		cWhere += "AND C7_RESIDUO = ' ' "
	ElseIf mv_par07 == 3
		cWhere += "AND C7_RESIDUO <> ' ' "
	ElseIf mv_par07 == 4
		cWhere += "AND C7_QUANT <= C7_QUJE "	
	ElseIf mv_par07 == 5
		cWhere += "AND C7_QUJE > 0 "		
	Endif
	
	If mv_par10 == 1 
		cWhere += "AND C7_TIPO = 1 "	
	ElseIf mv_par10 == 2
		cWhere += "AND C7_TIPO = 2 "	
	Endif
	
	If mv_par12 == 1 //Firmes
		cWhere += "AND (C7_TPOP = 'F' OR C7_TPOP = ' ') "	
	ElseIf mv_par12 == 2 //Previstas
		cWhere += "AND C7_TPOP = 'P' "	
	Endif
	
	If lFilUsr
		nFilters := len(oSection1:aUserFilter)
		
		cFrom := "%"
		
		For nI := 1 to nFilters
			If oSection1:aUserFilter[nI][1] == "SA2" .And. oSection1:aUserFilter[nI][2] <> ""
				cFrom += "," + RetSqlName("SA2") + " SA2 "
				cWhere += "AND C7_FORNECE = A2_COD AND SA2.D_E_L_E_T_ = ' ' "
				If FWModeAccess("SC7")=="E" .And. FWModeAccess("SA2")=="E"
					cWhere += "AND SC7.C7_FILIAL = SA2.A2_FILIAL "
				Endif
				
			ElseIf	oSection1:aUserFilter[nI][1] == "SB1" .And. oSection1:aUserFilter[nI][2] <> ""
				cFrom += "," + RetSqlName("SB1") + " SB1 "
				cWhere += "AND C7_PRODUTO = B1_COD AND SB1.D_E_L_E_T_ = ' ' "
				If FWModeAccess("SC7")=="E" .And. FWModeAccess("SB1")=="E"
					cWhere += "AND SC7.C7_FILIAL = SB1.B1_FILIAL "
				Endif
			Endif	
		Next nI
		
		cFrom += "%" 
	Endif

	cWhere +="%"	

	BeginSql Alias cAliasSC7

	SELECT SC7.*
	
	FROM %table:SC7% SC7 %Exp:cFrom%
	
	WHERE C7_FILIAL = %xFilial:SC7% AND 
		  C7_NUM >= %Exp:mv_par08% AND 
		  C7_NUM <= %Exp:mv_par09% AND 	 	  
		  C7_PRODUTO >= %Exp:mv_par01% AND 
		  C7_PRODUTO <= %Exp:mv_par02% AND 
  		  C7_EMISSAO >= %Exp:Dtos(mv_par03)% AND 
		  C7_EMISSAO <= %Exp:Dtos(mv_par04)% AND 
  		  C7_DATPRF >= %Exp:Dtos(mv_par05)% AND 
		  C7_DATPRF <= %Exp:Dtos(mv_par06)% AND 		  
	 	  C7_FORNECE >= %Exp:mv_par15% AND 
		  C7_FORNECE <= %Exp:mv_par16% AND 
		  SC7.%NotDel% 
		  %Exp:cWhere%
		  
	ORDER BY %Order:SC7% 
			
	EndSql 
	//������������������������������������������������������������������������Ŀ
	//�Metodo EndQuery ( Classe TRSection )                                    �
	//�                                                                        �
	//�Prepara o relat�rio para executar o Embedded SQL.                       �
	//�                                                                        �
	//�ExpA1 : Array com os parametros do tipo Range                           �
	//�                                                                        �
	//��������������������������������������������������������������������������
	oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)

oSection2:SetParentQuery()

Do Case
	Case nOrdem == 1
		oSection2:SetParentFilter( { |cParam| (cAliasSC7)->C7_NUM == cParam },{ || (cAliasSC7)->C7_NUM })
	Case nOrdem == 2
		oSection2:SetParentFilter( { |cParam| (cAliasSC7)->C7_PRODUTO == cParam },{ || (cAliasSC7)->C7_PRODUTO })
	Case nOrdem == 3
		oSection2:SetParentFilter( { |cParam| (cAliasSC7)->C7_FORNECE+(cAliasSC7)->C7_LOJA == cParam },{ || (cAliasSC7)->C7_FORNECE+(cAliasSC7)->C7_LOJA })
	Case nOrdem == 4
		oSection2:SetParentFilter( { |cParam| (cAliasSC7)->C7_DATPRF == cParam },{ || (cAliasSC7)->C7_DATPRF })
EndCase
//������������������������������������������������������������������������Ŀ
//�Metodo TrPosition()                                                     �
//�                                                                        �
//�Posiciona em um registro de uma outra tabela. O posicionamento ser�     �
//�realizado antes da impressao de cada linha do relat�rio.                �
//�                                                                        �
//�                                                                        �
//�ExpO1 : Objeto Report da Secao                                          �
//�ExpC2 : Alias da Tabela                                                 �
//�ExpX3 : Ordem ou NickName de pesquisa                                   �
//�ExpX4 : String ou Bloco de c�digo para pesquisa. A string ser� macroexe-�
//�        cutada.                                                         �
//�                                                                        �				
//��������������������������������������������������������������������������
TRPosition():New(oSection1,"SA2",1,{|| xFilial("SA2") + (cAliasSC7)->C7_FORNECE+(cAliasSC7)->C7_LOJA})
TRPosition():New(oSection1,"SB1",1,{|| xFilial("SB1") + (cAliasSC7)->C7_PRODUTO})
TRPosition():New(oSection1,"SC1",1,{|| xFilial("SC1") + (cAliasSC7)->C7_NUMSC +(cAliasSC7)->C7_ITEMSC})   //ADD NOME SOLICITANTE RICKY
TRPosition():New(oSection2,"SA2",1,{|| xFilial("SA2") + (cAliasSC7)->C7_FORNECE+(cAliasSC7)->C7_LOJA})
TRPosition():New(oSection2,"SB1",1,{|| xFilial("SB1") + (cAliasSC7)->C7_PRODUTO})
TRPosition():New(oSection2,"SC1",1,{|| xFilial("SC1") + (cAliasSC7)->C7_NUMSC +(cAliasSC7)->C7_ITEMSC})   //ADD NOME SOLICITANTE RICKY 

//������������������������������������������������������������������������Ŀ
//�Inicio da impressao do fluxo do relat�rio                               �
//��������������������������������������������������������������������������
oReport:SetMeter(SC7->(LastRec()))

If nOrdem <> 2
	oSection1:Cell("cDescri"):SetSize(nTamDPro)
	oSection2:Cell("cDescri"):SetSize(nTamDPro)
EndIf

Do Case
		Case nOrdem == 1

			oSection1:Cell("C7_PRODUTO"):Disable()
			oSection1:Cell("cDescri"):Disable()
//			oSection1:Cell("A2_FAX"):Disable()
			oSection1:Cell("A2_CONTATO"):Disable()
			oSection1:Cell("C7_DATPRF"):Disable()

			oSection2:Cell("C7_NUM"):Disable()
			oSection2:Cell("C7_FORNECE"):Disable()
			oSection2:Cell("A2_NOME"):Disable()
//			oSection2:Cell("A2_TEL"):Disable()
			
			oSection1:Print()
		
		Case nOrdem == 2

			oSection1:Cell("C7_NUM"):Disable()
			oSection1:Cell("C7_NUMSC"):Disable()
			oSection1:Cell("C7_FORNECE"):Disable()
			oSection1:Cell("A2_NOME"):Disable()
//			oSection1:Cell("A2_TEL"):Disable()
//			oSection1:Cell("A2_FAX"):Disable()
			oSection1:Cell("A2_CONTATO"):Disable()
			oSection1:Cell("C7_DATPRF"):Disable()
			
			oSection2:Cell("C7_PRODUTO"):Disable()
			oSection2:Cell("cDescri"):Disable()
			oSection2:Cell("B1_GRUPO"):Disable()
			oSection2:Cell("C7_UM"):Disable()
//			oSection2:Cell("A2_TEL"):Disable()
			
			oSection1:Print()
	
		Case nOrdem == 3

			oSection1:Cell("C7_NUM"):Disable()
			oSection1:Cell("C7_NUMSC"):Disable()
			oSection1:Cell("C7_PRODUTO"):Disable()
			oSection1:Cell("cDescri"):Disable()
			oSection1:Cell("C7_DATPRF"):Disable()
			
			oSection2:Cell("C7_FORNECE"):Disable()
			oSection2:Cell("A2_NOME"):Disable()
//			oSection2:Cell("A2_TEL"):Disable()
			oSection2:Cell("C7_UM"):Disable()

			oSection1:Print()
			
		Case nOrdem == 4
		
			oSection1:Cell("C7_NUM"):Disable()
			oSection1:Cell("C7_NUMSC"):Disable()
			oSection1:Cell("C7_FORNECE"):Disable()
			oSection1:Cell("A2_NOME"):Disable()
//			oSection1:Cell("A2_TEL"):Disable()
//			oSection1:Cell("A2_FAX"):Disable()
			oSection1:Cell("A2_CONTATO"):Disable()
			oSection1:Cell("C7_PRODUTO"):Disable()
			oSection1:Cell("cDescri"):Disable()
			
			oSection2:Cell("B1_GRUPO"):Disable()
			oSection2:Cell("C7_DATPRF"):Disable()
			oSection2:Cell("C7_UM"):Disable()
			oSection2:Cell("C7_FORNECE"):SetTitle(STR0064) //"Fornec."
			oSection2:Cell("cDescri"):SetSize(15)            

			If TamSX3("C7_PRODUTO")[1] > 15
				oSection2:Cell("A2_NOME"):Disable()
				oSection1:Cell("cDescri"):SetSize(14)
				oSection2:Cell("cDescri"):SetSize(14)
			Else
				oSection1:Cell("A2_NOME"):SetSize(15)
				oSection2:Cell("A2_NOME"):SetSize(15)
			EndIf
		
			oSection1:Print()			
EndCase			

Return NIL
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �ImpDescri �Autor�Nereu Humberto Junior � Data � 12/06/2006  ���
�������������������������������������������������������������������������͹��
���Uso       � MATR120                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function ImpDescri(cAliasSC7)

Local aArea   := GetArea()
Local cDescri := ""

If Empty(mv_par14)
	mv_par14 := "B1_DESC"
EndIf

//��������������������������������������������������������������Ŀ
//� Impressao da descricao cientifica do Produto.                �
//����������������������������������������������������������������
If AllTrim(mv_par14) == "B5_CEME"
	dbSelectArea("SB5")
	dbSetOrder(1)
	dbSeek( xFilial("SB5")+(cAliasSC7)->C7_PRODUTO )
	cDescri := Alltrim(B5_CEME)
EndIf

If AllTrim(mv_par14) == "C7_DESCRI"
	dbSelectArea("SC7")
	cDescri := Alltrim((cAliasSC7)->C7_DESCRI)
EndIf

//��������������������������������������������������������������Ŀ
//� Impressao da descricao generica do Produto.                  �
//����������������������������������������������������������������
If AllTrim(mv_par14) == "B1_DESC" .OR. Empty(cDescri)
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek( xFilial("SB1")+(cAliasSC7)->C7_PRODUTO )
	cDescri := Alltrim(SB1->B1_DESC)
EndIf

RestArea(aArea)
Return(cDescri)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �ImpVunit  �Autor�Nereu Humberto Junior � Data � 12/06/2006  ���
�������������������������������������������������������������������������͹��
���Uso       � MATR120                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function ImpVunit(cAliasSC7)

Local aArea    := GetArea()
Local nVlrUnit := 0
Local aTam	   := TamSx3("C7_PRECO")
Local nTxMoeda := IIF((cAliasSC7)->C7_TXMOEDA > 0,(cAliasSC7)->C7_TXMOEDA,Nil)

If !Empty((cAliasSC7)->C7_REAJUST)
	nVlrUnit := xMoeda(Form120((cAliasSC7)->C7_REAJUST),(cAliasSC7)->C7_MOEDA,mv_par13,(cAliasSC7)->C7_DATPRF,aTam[2],nTxMoeda) 
Else
	nVlrUnit := xMoeda((cAliasSC7)->C7_PRECO,(cAliasSC7)->C7_MOEDA,mv_par13,(cAliasSC7)->C7_DATPRF,aTam[2],nTxMoeda) 
Endif

RestArea(aArea)

Return(nVlrUnit)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �ImpVIPI   �Autor�Nereu Humberto Junior � Data � 12/06/2006  ���
�������������������������������������������������������������������������͹��
���Uso       � MATR120                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function ImpVIPI(cAliasSC7)

Local aArea    := GetArea()
Local nVlrIPI  := 0
Local nToTIPI  := 0
Local nTotal   := 0
Local nItemIVA := 0 
Local nValor   := ((cAliasSC7)->C7_QUANT) * IIf(Empty((cAliasSC7)->C7_REAJUST),(cAliasSC7)->C7_PRECO,Formula((cAliasSC7)->C7_REAJUST))
Local nTotDesc := (cAliasSC7)->C7_VLDESC
Local nTxMoeda := IIF((cAliasSC7)->C7_TXMOEDA > 0,(cAliasSC7)->C7_TXMOEDA,Nil)
Local nI 

If cPaisLoc <> "BRA"
	R120FIniPC((cAliasSC7)->C7_NUM,(cAliasSC7)->C7_ITEM,(cAliasSC7)->C7_SEQUEN)
	aValIVA := MaFisRet(,"NF_VALIMP")
	If !Empty( aValIVA )
		For nI := 1 To Len( aValIVA )
			nItemIVA += aValIVA[nI]
		Next
	Endif
	nVlrIPI := xMoeda(nItemIVA,(cAliasSC7)->C7_MOEDA,mv_par13,(cAliasSC7)->C7_DATPRF,,nTxMoeda)  
Else
	If nTotDesc == 0
		nTotDesc := CalcDesc(nValor,(cAliasSC7)->C7_DESC1,(cAliasSC7)->C7_DESC2,(cAliasSC7)->C7_DESC3)
	EndIF
	nTotal := nValor - nTotDesc
	nTotIPI := IIF((cAliasSC7)->C7_IPIBRUT == "L",nTotal, nValor) * ( (cAliasSC7)->C7_IPI / 100 )
	nVlrIPI := xMoeda(nTotIPI,(cAliasSC7)->C7_MOEDA,mv_par13,(cAliasSC7)->C7_DATPRF,,nTxMoeda)  
EndIf

RestArea(aArea)

Return(nVlrIPI)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �ImpSaldo  �Autor�Nereu Humberto Junior � Data � 12/06/2006  ���
�������������������������������������������������������������������������͹��
���Uso       � MATR120                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function ImpSaldo(cAliasSC7)

Local aArea    := GetArea()
Local nSalRec  := 0
Local nItemIVA := 0 
Local nQuant   := If(Empty((cAliasSC7)->C7_RESIDUO),IIF((cAliasSC7)->C7_QUANT-(cAliasSC7)->C7_QUJE<0,0,(cAliasSC7)->C7_QUANT-(cAliasSC7)->C7_QUJE),0)
Local nTotal   := 0
Local nSalIPI  := 0
Local nValor   := ((cAliasSC7)->C7_QUANT) * IIf(Empty((cAliasSC7)->C7_REAJUST),(cAliasSC7)->C7_PRECO,Formula((cAliasSC7)->C7_REAJUST))
Local nSaldo   := ((cAliasSC7)->C7_QUANT-(cAliasSC7)->C7_QUJE) * IIf(Empty((cAliasSC7)->C7_REAJUST),(cAliasSC7)->C7_PRECO,Formula((cAliasSC7)->C7_REAJUST))
Local nTotDesc := (cAliasSC7)->C7_VLDESC
Local nTxMoeda := IIF((cAliasSC7)->C7_TXMOEDA > 0,(cAliasSC7)->C7_TXMOEDA,Nil)
Local nI 

If cPaisLoc <> "BRA"
	R120FIniPC((cAliasSC7)->C7_NUM,(cAliasSC7)->C7_ITEM,(cAliasSC7)->C7_SEQUEN)
	aValIVA  := MaFisRet(,"NF_VALIMP")
	If !Empty( aValIVA )
		For nI := 1 To Len( aValIVA )
			nItemIVA += aValIVA[nI]
		Next
	Endif
	nSalIPI := ((cAliasSC7)->C7_QUANT-(cAliasSC7)->C7_QUJE) * nItemIVA / (cAliasSC7)->C7_QUANT
Else
	If nTotDesc == 0
		nTotDesc := CalcDesc(nValor,(cAliasSC7)->C7_DESC1,(cAliasSC7)->C7_DESC2,(cAliasSC7)->C7_DESC3)
	EndIF
	nTotal := nValor - nTotDesc
	If Empty((cAliasSC7)->C7_RESIDUO)
		nTotal := nSaldo - nTotDesc
		nSalIPI := IIF((cAliasSC7)->C7_IPIBRUT == "L",nTotal, nSaldo) * ( (cAliasSC7)->C7_IPI / 100 )
	Endif
EndIf

If Empty((cAliasSC7)->C7_REAJUST)
	nSalRec := nQuant * (xMoeda((cAliasSC7)->C7_PRECO,(cAliasSC7)->C7_MOEDA,mv_par13,(cAliasSC7)->C7_DATPRF,,nTxMoeda)-xMoeda((cAliasSC7)->C7_VLDESC,(cAliasSC7)->C7_MOEDA,mv_par13,(cAliasSC7)->C7_DATPRF,,nTxMoeda)) + xMoeda(nSalIPI,(cAliasSC7)->C7_MOEDA,mv_par13,(cAliasSC7)->C7_DATPRF,,nTxMoeda) 
Else
	nSalRec  := (nQuant * xMoeda(Formula((cAliasSC7)->C7_REAJUST),(cAliasSC7)->C7_MOEDA,mv_par13,(cAliasSC7)->C7_DATPRF,,nTxMoeda)) + ;
		xMoeda(nSalIPI,(cAliasSC7)->C7_MOEDA,mv_par13,(cAliasSC7)->C7_DATPRF,,nTxMoeda) 
Endif

RestArea(aArea)

Return(nSalRec)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �ImpVTotal �Autor�Nereu Humberto Junior � Data � 12/06/2006  ���
�������������������������������������������������������������������������͹��
���Uso       � MATR120                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function ImpVTotal(cAliasSC7)

Local aArea    := GetArea()
Local nVlrTot  := 0
Local nTxMoeda := IIF((cAliasSC7)->C7_TXMOEDA > 0,(cAliasSC7)->C7_TXMOEDA,Nil)

R120FIniPC((cAliasSC7)->C7_NUM,(cAliasSC7)->C7_ITEM,(cAliasSC7)->C7_SEQUEN)
nTotal  := MaFisRet(,'NF_TOTAL')
nVlrTot := xMoeda(nTotal,(cAliasSC7)->C7_MOEDA,mv_par13,(cAliasSC7)->C7_DATPRF,,nTxMoeda)		  		

RestArea(aArea)

Return(nVlrTot)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �ImpDescon �Autor�Nereu Humberto Junior � Data � 12/06/2006  ���
�������������������������������������������������������������������������͹��
���Uso       � MATR120                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function ImpDescon(cAliasSC7)

Local aArea    := GetArea()
Local nVlrDesc := 0
Local nTxMoeda := IIF((cAliasSC7)->C7_TXMOEDA > 0,(cAliasSC7)->C7_TXMOEDA,Nil)

nVlrDesc := xMoeda(C7_VLDESC,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)

RestArea(aArea)

Return(nVlrDesc)

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �MATR120R3� Autor � Claudinei M. Benzi    � Data � 05.09.91  ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Emiss�o da Rela��o de Pedidos de Compras (Antigo)           ���
��������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                      ���
��������������������������������������������������������������������������Ĵ��
���Retorno   � .T.	/  .F.                                                 ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                    ���
��������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      ���
��������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                    ���
��������������������������������������������������������������������������Ĵ��
���Rogerio F.G.  �05/12/97�08197A�Inclusao do Telefone do Fornecedor       ���
���Rogerio F.G.  �05/12/97�10426A�Alteracao da Picture Cpo C7_PRECO        ���
���Edson   M.    �25/02/98�XXXXXX�Acerto da impressao dos Totais.          ���
���Bruno         �10/12/98�Melhor�Acerto da impressao das A.E.(Argentina) .���
���Viviani       �29/12/98�19074 �Acerto do calculo total geral c/ desconto���
���Viviani       �29/12/98�10634 �Inclusao de fax e contato na ordem 3     ���
���Edson   M.    �23/03/99�XXXXXX�Correcao no calculo do IPI.              ���
���Fernando Joly �20/04/99�XXXXXX�Consistir SC's Firmes e Previstas.       ���
���Percy A Horna �15/08/01�xxxxxx�Inclusao da funcao xMoeda() p/impressao  ���
���              �        �      �em multimoeda, dependendo do parametro   ���
���              �        �      �escolhido no grupo de perguntas do SX1.  ���
���              �        �      �Impressao valores de impostos localizados���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Descri��o � PLANO DE MELHORIA CONTINUA        �Programa    MATR120.PRX ���
�������������������������������������������������������������������������Ĵ��
���ITEM PMC  � Responsavel              � Data          |BOPS             ���
�������������������������������������������������������������������������Ĵ��
���      01  �                          �               |                 ���
���      02  � Ricardo Berti            � 03/03/2006    | 00000092831     ���
���      03  �                          �               |                 ���
���      04  � Ricardo Berti            � 03/03/2006    | 00000092831     ���
���      05  �                          �               |                 ���
���      06  �                          �               |                 ���
���      07  � Flavio Luiz Vicco        � 10/04/2006    | 00000095403     ���
���      08  � Flavio Luiz Vicco        � 10/04/2006    | 00000095403     ���
���      09  � Ricardo Berti            � 03/03/2006    | 00000092831     ���
���      10  � Ricardo Berti            � 03/03/2006    | 00000092831     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function Matr120R3()

//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
LOCAL CbTxt  := ""
Local wnrel  := ""
LOCAL cDesc1 :=STR0001	//"Emissao da Relacao de  Pedidos de Compras."
LOCAL cDesc2 :=STR0002	//"Sera solicitado em qual Ordem, qual o Intervalo para"
LOCAL cDesc3 :=STR0003	//"a emissao dos pedidos de compras."
LOCAL aOrd   := {STR0004,STR0005,STR0006}		//" Por Numero         "###" Por Produto        "###" Por Fornecedor   "
LOCAL lRet	 := .T.
Local cOrdemSix	:= "G" // Indice: PREVISAO ENTREGA (SC7)
Local aArea		:= GetArea()

PRIVATE aTamSXG  := TamSXG("001")
PRIVATE nDifNome := 0
PRIVATE nTamNome := 35
PRIVATE titulo   :=STR0007	//"Relacao de Pedidos de Compras"
PRIVATE cPerg    := "MTR120"
PRIVATE cString  := "SC7"
PRIVATE aReturn  := { STR0008, 1,STR0009, 1, 2, 1, "",1 }		//"Zebrado"###"Administracao"
PRIVATE nomeprog := "MATR120"
PRIVATE nLastKey := 0
PRIVATE aLinha   := { }
PRIVATE LIMITE   :=220
PRIVATE cabec1   := ""
PRIVATE cabec2   := ""
PRIVATE tamanho  := "G"
If aTamSXG[1] != aTamSXG[3]
	nDifNome := aTamSXG[4] - aTamSXG[3]
	nTamNome := if(aTamSXG[1] != aTamSXG[3],35-(aTamSXG[4]-aTamSXG[3]),35)
Endif
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
//����������������������������������������������������������������
Imprime  := .T.
//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
Pergunte("MTR120",.F.)
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01       // do produto                                 �
//� mv_par02       // ate o produto                              �
//� mv_par03       // data de emissao de                         �
//� mv_par04       // data de emissao ate                        �
//� mv_par05       // data de entrega inicial                    �
//� mv_par06       // data de entrega final                      �
//� mv_par07       // todas ou em aberto ou residuos ou atendidos�
//� mv_par08       // pedido inicial                             �
//� mv_par09       // pedido final                               �
//� mv_par10       // Listar  PC    AE    Ambos                  �
//� mv_par11       // Pedidos Liberados  Bloqueados Ambos        �
//� mv_par12       // Impr. SC's Firmes, Previstas ou Ambas      �
//� mv_par13       // Qual Moeda                                 �
//� mv_par14       // Descricao do produto                       �
//� mv_par15       // Fornecedor de                              �
//� mv_par16       // Fornecedor ate                             �
//����������������������������������������������������������������

//���������������������������������������������������������������������������Ŀ
//� Verifica existencia do indice PREVISAO ENTREGA de SC7 e adiciona a opcao  � BOPS 92831
//�����������������������������������������������������������������������������
dbSelectArea("SIX")
If dbSeek(cString+cOrdemSIX)
	Aadd(aOrd,STR0049) //"Por Previsao de Entrega "
EndIf
RestArea(aArea)

//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT                        �
//����������������������������������������������������������������
wnrel := "MATR120R"
wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.f.,Tamanho)

lRet := !(nLastKey == 27)
If lRet
	SetDefault(aReturn,cString)
	lRet := !(nLastKey == 27)
EndIf
If lRet
	RptStatus({|lEnd| R120Imp(@lEnd,tamanho,wnrel,cString)},Titulo)
Else
	Set Filter To
EndIf

Return(lRet)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � R120IMP  � Autor � Cristina M. Ogura     � Data � 10.11.95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relatorio                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � R120Imp(ExpL1,ExpC1,ExpC2,ExpC3)                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpL1 = controle para interrupcao do usuario	              ���
���          � ExpC1 = tamanho do layout                                  ���
���          � ExpC2 = nome do programa                                   ���
���          � ExpC3 = Alias do arquivo principal                         ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR120                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function R120Imp(lEnd,tamanho,wnrel,cString)

LOCAL cbtxt := SPACE(10)
LOCAL nQuebra,cCabQuebra,cQuebrant,cCOndBus
LOCAL CbCont
LOCAL nQuant_a_Rec := 0
Local nTotParc	:= 0
Local nTxMoeda	:= 1

CbCont   := 00
nQuebra  := 00
li       := 80
m_pag    := 01

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Totalizar os valores do relatorio  �
//����������������������������������������������������������������
nT_qtd_ped := 0 // qtde pedida
nT_vl_ipi  := 0 // valor do ipi
nT_vl_total:= 0 // valor total do pedido
nT_qtd_entr:= 0 // qtde entregue
nT_sd_receb:= 0 // saldo a receber
nT_desc    := 0 // total de desconto
nTotIVA    := 0 // Total de IVA (impostos)

//������������������������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Totalizar os valores p/ item de acordo com a ordem �
//��������������������������������������������������������������������������������
nPedida    := 0 // qtde pedida
nValIpi    := 0 // valor do ipi
nTotal     := 0 // valor total do pedido
nQuant     := 0 // qtde entregue
nSaldo     := 0 // saldo a receber
nFlag      := 0 // flag que indica se imprime totais por item ou nao
nITemIpi   := 0
nSalIpi    := 0
nFrete     := 0 // valor do frete
nDesc      := 0 // valor do desconto
nValIVA    := 0 // valor do IVA
nItemIVA   := 0 // valor do item do imposto

//��������������������������������������������������������������Ŀ
//� Monta os Cabecalhos de acordo com os parametros              �
//����������������������������������������������������������������
cabec1    := STR0011		//"RELACAO DOS PEDIDOS DE COMPRAS"
//��������������������������������������������������������������Ŀ
//� Localiza o ponto inicial para a impressao                    �
//����������������������������������������������������������������
nOrdem := aReturn[8]

dbSelectArea("SC7")

If nOrdem <> 4
	dbSetOrder(nOrdem)
EndIf

//��������������������������������������������������������������Ŀ
//� Verifica qual ordem foi selecionada                          �
//����������������������������������������������������������������
If nOrdem == 1
	If ( cPaisLoc$"ARG|POR|EUA" )	//Ordena los pedidos de compra y luego la AE.
		DbSetOrder(10)
		cCondBus	:=	"0"+MV_PAR08
	Else
		cCondBus	:=	mv_par08
	EndIf

	dbSeek(xFilial("SC7")+cCondBus,.T.)
	cCampo     := "SC7->C7_NUM"

	If mv_par10 == 2
		cTexQuebra := STR0012	//"AUTOR. N. : "
	Else
		cTexQuebra := STR0013	//"PEDIDO N. : "
	EndIf
	titulo     += STR0014		//" - POR NUMERO"

	// Verifica se utilizara LayOut Maximo
	if aTamSXG[1] != aTamSXG[3]
		cabec1 := STR0046		//"ITEM CODIGO          DESCRICAO                    GRP  CODIGO               RAZAO SOCIAL         DATA DE  ENTREGA   QUANTIDADE  UM      VALOR        VALOR         VALOR TOTAL  QUANT.      QUANT. A          SALDO   RES."
		//				  	       0         1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20
		//                  	   0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	Else
		cabec1 := STR0015		//"ITEM CODIGO          DESCRICAO                    GRP  CODIGO RAZAO SOCIAL                        DATA DE  ENTREGA   QUANTIDADE  UM      VALOR        VALOR         VALOR TOTAL  QUANT.      QUANT. A          SALDO   RES."
		//                           		 1         2         3         4         5         6         7         8         9        10        11        12        13   X    14        X5        16   X    17        18        19        20        10
		//                         01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	Endif
	cabec2 := STR0016		    //"     PRODUTO         DO PRODUTO                           FORN.                                     EMISSAO  PREVISTA      PEDIDA           UNIT.         IPI            (C/IPI)   ENTREGUE    RECEBER         RECEBER  ELIM."	
ElseIf nOrdem == 2
	dbSeek(xFilial("SC7")+mv_par01,.T.)
	cCampo     := "SC7->C7_PRODUTO"
	cTexQuebra := STR0017	//"PRODUTO : "
	titulo     += STR0018	//" - POR PRODUTO"
	// Verifica se utilizara LayOut Maximo
	if aTamSXG[1] != aTamSXG[3]
		If ( cPaisLoc$"ARG|POR|EUA" )
			cabec1 := STR0050 //"PED/AE ITEM  DATA      CODIGO               RAZAO SOCIAL          FONE            ENTREGA         QUANTIDADE           VALOR    DESCONTO           VALOR     PRECO TOTAL      QUANTIDADE   QUANT. A          SALDO RESIDUOS"
		Else
			cabec1 := STR0047 //"PEDIDO ITEM  DATA      CODIGO               RAZAO SOCIAL          FONE            ENTREGA         QUANTIDADE           VALOR    DESCONTO           VALOR     PRECO TOTAL      QUANTIDADE   QUANT. A          SALDO RESIDUOS"
			//					 123456  12  99/99/9999 12345678901234567890 123456789012345678901 12345789012345 12/34/5678 123456789012345 123456789012345 123456789012 1234567890123 123456789012345 123456789012345 1234567890 123456789012345   Sim
			//					 		   1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21
			//					 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
		EndIf
	Else
		If ( cPaisLoc$"ARG|POR|EUA" )
			cabec1 := STR0051 //"PED/AE ITEM  DATA      CODIGO RAZAO SOCIAL                        FONE            ENTREGA         QUANTIDADE           VALOR    DESCONTO           VALOR     PRECO TOTAL      QUANTIDADE   QUANT. A          SALDO RESIDUOS"
		Else
			cabec1 := STR0019 //"PEDIDO ITEM  DATA      CODIGO RAZAO SOCIAL                        FONE            ENTREGA         QUANTIDADE           VALOR    DESCONTO           VALOR     PRECO TOTAL      QUANTIDADE   QUANT. A          SALDO RESIDUOS"
			// 					 123456  12  99/99/9999 123456 12345678901234567890123456789012345 12345789012345 12/34/5678 123456789012345 123456789012345 123456789012 1234567890123 123456789012345 123456789012345 1234567890 123456789012345   Sim
			//					 		   1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21
			//					 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
		EndIf
	Endif
	cabec2 := STR0020 //"             EMISSAO   FORN.                                      FORN.           PREVISTA            PEDIDA        UNITARIO                         IPI       (C/IPI)          ENTREGUE    RECEBER        RECEBER ELIMINADOS"
ElseIf nOrdem == 3
	dbSeek(xFilial("SC7"))
	cCampo     := "SC7->C7_FORNECE+SC7->C7_LOJA"
	cTexQuebra := STR0021	//"FORNECEDOR : "
	titulo     += STR0022	//" - POR FORNECEDOR"
	If ( cPaisLoc$"ARG|POR|EUA" )
		cabec1 := STR0042 //"PED/AE ITEM  DATA     CODIGO           DESCRICAO DO PRODUTO           GRUPO  ENTREGA        QUANTIDADE            PRECO            VALOR       PRECO TOTAL        QUANTIDADE      QUANT. A       SALDO     RESIDUOS"
	Else
		cabec1 := STR0023 //"PEDIDO ITEM  DATA     CODIGO           DESCRICAO DO PRODUTO           GRUPO  ENTREGA        QUANTIDADE            PRECO            VALOR       PRECO TOTAL        QUANTIDADE      QUANT. A       SALDO     RESIDUOS"
	EndIf
	cabec2 :=  STR0024    //"NUMERO       EMISSAO  PRODUTO                                                PREVISTA           PEDIDA         UNITARIO              IPI         (C/IPI)            ENTREGUE    RECEBER        RECEBER   ELIMINADOS"
	//                       123456  12  12/45/78 123456789012345 123456789012345678901234567890 1234  12/34/56 123456789012345 123456789012345 123456789012 1234567890123 123456789012345 123456789012345 1234567890 123456789012345   Sim
	//                      		   1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21
	//                       01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890

Else		// Ordem == 4
	dbSetOrder(16)
	dbSeek(xFilial("SC7"))
	cCampo     := "DTOC(SC7->C7_DATPRF)"
	cTexQuebra := STR0052 //"ENTREGA PREVISTA :  "
	titulo     += STR0053 //" - POR PREVISAO DE ENTREGA"
	// Verifica se utilizara' LayOut Maximo
	if aTamSXG[1] != aTamSXG[3]
		If ( cPaisLoc$"ARG|POR|EUA" )
			cabec1 := 	STR0054 //"PED/AE ITEM  DATA      CODIGO           DESCRICAO         CODIGO               RAZAO SOCIAL    FONE             QUANTIDADE        VALOR   DESCONTO        VALOR     PRECO TOTAL   QUANTIDADE   QUANT. A           SALDO RES."
		Else
			cabec1 := 	STR0055 //"PEDIDO ITEM  DATA      CODIGO           DESCRICAO         CODIGO               RAZAO SOCIAL    FONE             QUANTIDADE        VALOR   DESCONTO        VALOR     PRECO TOTAL   QUANTIDADE   QUANT. A           SALDO RES."
			//		  	 	 	   123456 1234 99/99/99   123456789012345 123456789012345678 12345678901234567890 123456789012345 12345789012345 123456789012 123456789012 1234567890 123456789012 123456789012345 123456789012 1234567890 123456789012345  Sim
			//			 		  		     1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21
			//					   01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
		EndIf
	Else
		If ( cPaisLoc$"ARG|POR|EUA" )
			cabec1 := 	STR0056 //"PED/AE ITEM  DATA      CODIGO           DESCRICAO         CODIGO RAZAO SOCIAL                  FONE             QUANTIDADE        VALOR   DESCONTO        VALOR     PRECO TOTAL   QUANTIDADE   QUANT. A           SALDO RES."
		Else
			cabec1 := 	STR0057 //"PEDIDO ITEM  DATA      CODIGO           DESCRICAO         CODIGO RAZAO SOCIAL                  FONE             QUANTIDADE        VALOR   DESCONTO        VALOR     PRECO TOTAL   QUANTIDADE   QUANT. A           SALDO RES."
			//		  	 		   123456 1234 99/99/99   123456789012345 123456789012345678 123456 12345678901234567890123456789 12345789012345 123456789012 123456789012 1234567890 123456789012 123456789012345 123456789012 1234567890 123456789012345  Sim
			//			 		     		 1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21
			//			 		   01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
		Endif
	Endif
	cabec2 := 			STR0058 //"             EMISSAO                    DO PRODUTO        FORN.                                FORN.                PEDIDA     UNITARIO                     IPI    (C/IMPOSTOS)     ENTREGUE    RECEBER         RECEBER ELIM."
Endif

If mv_par07==1
	titulo+=STR0025	//", Todos"
Elseif mv_par07==2
	titulo+=STR0026	//", Em Abertos"
Elseif mv_par07==3
	titulo+=STR0027	//", Residuos"
Elseif mv_par07==4
	titulo+=STR0028	//", Atendidos"
Elseif mv_par07==5
	titulo+=STR0059 //", Atendidos + Parcial entregue"
Endif

titulo += " - " + GetMv("MV_MOEDA"+STR(mv_par13,1))		//" MOEDA "
SetRegua(RecCount())
//��������������������������������������������������������������Ŀ
//� Inicia a leitura do arquivo SC7                              �
//����������������������������������������������������������������
Do While !Eof() .And. C7_FILIAL = xFilial("SC7")

	nTxMoeda := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_TXMOEDA,Nil)
	IncRegua()
	If lEnd
		@PROW()+1,001 PSAY STR0029	//"CANCELADO PELO OPERADOR"
		Exit
	Endif
	//��������������������������������������������������������������Ŀ
	//� Consiste este item. POR PEDIDO                               �
	//����������������������������������������������������������������
	If C7_NUM < mv_par08 .Or. C7_NUM > mv_par09
		dbSkip()
		Loop
	Endif
	//��������������������������������������������������������������Ŀ
	//� Consiste este item. POR PRODUTO                              �
	//����������������������������������������������������������������
	If C7_PRODUTO < mv_par01 .Or. C7_PRODUTO > mv_par02
		dbSkip()
		Loop
	Endif
	//��������������������������������������������������������������Ŀ
	//� Consiste este item. POR EMISSAO                              �
	//����������������������������������������������������������������
	If C7_EMISSAO < mv_par03 .Or. C7_EMISSAO > mv_par04
		dbSkip()
		Loop
	Endif
	//��������������������������������������������������������������Ŀ
	//� Consiste este item. POR DATA ENTREGA                         �
	//����������������������������������������������������������������
	If C7_DATPRF < mv_par05 .Or. C7_DATPRF > mv_par06
		dbSkip()
		Loop
	Endif
	//��������������������������������������������������������������Ŀ
	//� Consiste se o pedido esta' liberado.                         �
	//����������������������������������������������������������������
	If	(C7_CONAPRO == "B" .And. mv_par11 == 1) .Or.;
		(C7_CONAPRO != "B" .And. mv_par11 == 2)
		dbSkip()
		Loop
	Endif
	//��������������������������������������������������������������Ŀ
	//� Consiste este item. EM ABERTO                                �
	//����������������������������������������������������������������
	If mv_par07 == 2
		If C7_QUANT-C7_QUJE <= 0 .Or. !EMPTY(C7_RESIDUO)
			dbSkip()
			Loop
		Endif
	Endif
	//��������������������������������������������������������������Ŀ
	//� Consiste este item. RESIDUOS                                 �
	//����������������������������������������������������������������
	If mv_par07 == 3
		If EMPTY(C7_RESIDUO)
			dbSkip()
			Loop
		Endif
	Endif
	//��������������������������������������������������������������Ŀ
	//� Consiste este item. ATENDIDOS                                �
	//����������������������������������������������������������������
	If mv_par07 == 4
		If C7_QUANT > C7_QUJE
			dbSkip()
			Loop
		Endif
	Endif
	//��������������������������������������������������������������Ŀ
	//� Consiste este item. ATENDIDOS +pedidos parcialmente entregues�
	//����������������������������������������������������������������
	If mv_par07 == 5
		If C7_QUJE = 0
			dbSkip()
			Loop
		Endif
	Endif
	//��������������������������������������������������������������Ŀ
	//� Consiste Tipo	de Pedido  1-PC    2-AE    3-Ambos           �
	//����������������������������������������������������������������
	If mv_par10 == 1 .And. C7_TIPO != 1
		dbSkip()
		Loop
	ElseIf mv_par10 == 2 .And.	C7_TIPO !=2
		dbSkip()
		Loop
	Endif

	//��������������������������������������������������������������Ŀ
	//� Consiste este item. por fornecedor                           �
	//����������������������������������������������������������������
	If C7_FORNECE < mv_par15 .Or. C7_FORNECE > mv_par16
		dbSkip()
		Loop
	Endif

	//��������������������������������������������������������������Ŀ
	//� Filtra Tipo de SCs Firmes ou Previstas                       �
	//����������������������������������������������������������������
	If !MtrAValOP(mv_par12, 'SC7')
		dbSkip()
		Loop
	EndIf

	//��������������������������������������������������������������Ŀ
	//� Verifica se e nova pagina                                    �
	//����������������������������������������������������������������
	If li > 60
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
	Endif

	If nQuebra == 0
		cQuebrant := &cCampo
		li++
		If li > 60
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
		Endif
		If nOrdem = 1
			cCabQuebra := " "
		ElseIf nOrdem = 2
			dbSelectArea("SC7")
			cCabQuebra := Alltrim(SC7->C7_DESCRI)

			If Empty(mv_par14)
				mv_par14 := "B1_DESC"
			EndIf

			//��������������������������������������������������������������Ŀ
			//� Impressao da descricao generica do Produto.                  �
			//����������������������������������������������������������������
			If AllTrim(mv_par14) == "B1_DESC"
				dbSelectArea("SB1")
				dbSetOrder(1)
				dbSeek(cFilial+&cCampo)
				cCabQuebra := Alltrim(SB1->B1_DESC)
			EndIf
			//��������������������������������������������������������������Ŀ
			//� Impressao da descricao cientifica do Produto.                �
			//����������������������������������������������������������������
			If AllTrim(mv_par14) == "B5_CEME"
				dbSelectArea("SB5")
				dbSetOrder(1)
				If dbSeek(cFilial+&cCampo)
					cCabQuebra := Alltrim(B5_CEME)
				EndIf
			EndIf

			dbSelectArea("SC7")
			If AllTrim(mv_par14) == "C7_DESCRI"
				cCabQuebra := Alltrim(SC7->C7_DESCRI)
			EndIf
		ElseIf nOrdem = 3
			dbSelectArea("SA2")
			dbSeek(cFilial+&cCampo)
			cCabQuebra := A2_NOME
		ElseIf nOrdem = 4
			cCabQuebra := " "
		Endif
		If ( cPaisLoc$"ARG|POR|EUA" ).AND.mv_par10==3.And.nOrdem==1
			If ( SC7->C7_TIPO==2 )
				@ li,000 PSAY STR0012 + &cCampo + " " + Substr(cCabQuebra,1,(nTamNome-5)) // "AUTOR. No. : "
			Else
				If nOrdem == 1 .And. !Empty(SC7->C7_NUMSC)
					@ li,000 PSAY STR0013 + &cCampo + " " + STR0048 + SC7->C7_NUMSC + " " + Substr(cCabQuebra,1,(nTamNome-5)) // "PEDIDO No. : "
				Else
					@ li,000 PSAY STR0013 + &cCampo + " " + Substr(cCabQuebra,1,(nTamNome-5))  // "PEDIDO No. : "
				Endif
			Endif
		Else
			If nOrdem == 1 .And. !Empty(SC7->C7_NUMSC)
				@ li,000 PSAY cTexQuebra + &cCampo + " " + STR0048 + SC7->C7_NUMSC + " " + Substr(cCabQuebra,1,(nTamNome-5)) // "SOLICITACAO COMPRAS No. : "
			Else
				@ li,000 PSAY cTexQuebra + &cCampo + " " + Substr(cCabQuebra,1,(nTamNome-5))
			Endif
		EndIf

		If nOrdem = 1 .or. nOrdem = 3
			dbSelectArea("SA2")
			If dbSeek(cFilial+SC7->C7_FORNECE+SC7->C7_LOJA)
				If nOrdem = 1
					@ li,055 PSAY SC7->C7_FORNECE
					@ li,(062+nDifNome) PSAY Substr(SA2->A2_NOME,1,nTamNome)
//					@ li,098 PSAY STR0041+Substr(SA2->A2_TEL,1,15) // Fone.:
				Else
//					@ li,055 PSAY STR0041+Substr(SA2->A2_TEL,1,15) + STR0044 + SA2->A2_FAX + STR0045 + SA2->A2_CONTATO   // Fone.: Fax: Contato:
				Endif
			Endif
			dbSelectArea("SC7")
		Endif
		nQuebra := 1
		nFlag:=0
	Endif

	dbSelectArea("SC7")
	If cQuebrant != &cCampo
		nQuebra := 0
		li++
		If li > 60
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
		Endif
		If nFlag > 1 .Or. nOrdem != 2
			Impitem(1)
			nFlag:=0
		EndIf
		nPedida:=nValIpi:=nTotal:=nQuant:=nSaldo:=nValIVA:=0
		@ li,000 PSAY __PrtThinLine()
		Loop
	Endif
	li++
	If li > 60
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
	Endif
	nItemIpi := 0
	nSalIpi  := 0
	nItemIVA := 0
	//�����������������������������������������Ŀ
	//� Verifica ordem a ser impressa           �
	//�������������������������������������������
	R120FIniPC(SC7->C7_NUM,SC7->C7_ITEM,SC7->C7_SEQUEN)
	If nOrdem = 1
		nTotParc := ImpOrd1()
	ElseIf nOrdem = 2
		nTotParc := ImpOrd2()
	ElseIf nOrdem = 3
		nTotParc := ImpOrd3()
	Else
		nTotParc := ImpOrd4()
	Endif
	nTotal 	+= xMoeda(nTotParc,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)
	//�����������������������������������������Ŀ
	//� Soma as variaveis dos totais p/item     �
	//�������������������������������������������
	nPedida = nPedida + C7_QUANT
	nValIpi = nValIpi + xMoeda(nItemIPI,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)
	nQuant  = nQuant  + C7_QUJE
	nQuant_a_Rec := If(Empty(C7_RESIDUO),IIF(C7_QUANT-C7_QUJE<0,0,C7_QUANT-C7_QUJE),0)
	nSaldo  = nSaldo  + (nQuant_a_Rec * IIf(Empty(C7_REAJUST),xMoeda(C7_PRECO,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda),xMoeda(Formula(C7_REAJUST),SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda))) + xMoeda(nSalIPI,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)
	nValIVA := nValIVA + xMoeda(nItemIVA,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)
	//������������������������Ŀ
	//� Valor do Frete         �
	//��������������������������
	nFrete := C7_FRETE
	//���������������������������Ŀ
	//� Valor do Desconto         �
	//�����������������������������
	If C7_DESC1 != 0 .or. C7_DESC2 != 0 .or. C7_DESC3 != 0
		nDesc += CalcDesc(C7_TOTAL,C7_DESC1,C7_DESC2,C7_DESC3)
	Else
		nDesc += C7_VLDESC
	Endif
	//�����������������������������������������Ŀ
	//� Soma as variaveis dos totais gerais     �
	//�������������������������������������������
	nT_vl_ipi   := nT_vl_ipi   + xMoeda(nItemIPI,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)
	nT_vl_total := nT_vl_total + xMoeda(nTotParc,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)
	nT_sd_receb := nT_sd_receb + (nQuant_a_Rec * IIf(Empty(C7_REAJUST),xMoeda(C7_PRECO,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda),xMoeda(Formula(C7_REAJUST),SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda))) + xMoeda(nSalIPI,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)
	nTotIVA     := nTotIVA     + xMoeda(nItemIVA,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)
	dbSelectArea("SC7")
	dbSkip()
EndDo

If nOrdem == 2 
	nT_Desc += xMoeda(nDesc,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)
EndIf

If nFlag > 1 .Or. nOrdem != 2
	If li > 60 .And. li != 80
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
	Endif
	If li != 80
		li++
		Impitem(2)
	Endif
	nFlag:=0
EndIf

If nT_qtd_ped > 0 .Or. nT_vl_ipi > 0 .Or.;
		nT_vl_total > 0 .Or. nT_qtd_entr > 0 .Or. nT_sd_receb > 0
	Imptot(limite)
Endif

IF li != 80
	li++
	If li > 60
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
	Endif
	@ li,000 PSAY __PrtThinLine()
	roda(CbCont,STR0030,"G")		//"PEDIDOS"
EndIF

dbSelectArea("SC7")
Set Filter To
dbSetOrder(1)

If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	ourspool(wnrel)
Endif

MS_FLUSH()

Return Nil

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � IMPORD1  � Autor � Claudinei M. Benzi    � Data � 05.09.91 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao do relatorio na 1a ordem                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ExpN1 := ImpOrd1()                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � ExpN1 = Valor total                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR120                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
STATIC Function ImpOrd1()

Local nQuant_a_Rec:=0
Local aTam		:= TamSx3("C7_PRECO")
Local aTamVal	:= TamSx3("C7_VALICM")
Local nTotal	:= MaFisRet(,'NF_TOTAL')
Local aValIVA  := MaFisRet(,"NF_VALIMP")
Local nI       := 0
Local j        := 0
Local cDescri  := Alltrim(SC7->C7_DESCRI)
Local nTxMoeda := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_TXMOEDA,Nil)

If Empty(mv_par14)
	mv_par14 := "B1_DESC"
EndIf

//��������������������������������������������������������������Ŀ
//� Impressao da descricao generica do Produto.                  �
//����������������������������������������������������������������
If AllTrim(mv_par14) == "B1_DESC"
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek( xFilial("SB1")+SC7->C7_PRODUTO )
	cDescri := Alltrim(SB1->B1_DESC)
	dbSelectArea("SC7")
EndIf
//��������������������������������������������������������������Ŀ
//� Impressao da descricao cientifica do Produto.                �
//����������������������������������������������������������������
If AllTrim(mv_par14) == "B5_CEME"
	dbSelectArea("SB5")
	dbSetOrder(1)
	If dbSeek( xFilial("SB5")+SC7->C7_PRODUTO )
		cDescri := Alltrim(B5_CEME)
	EndIf
	dbSelectArea("SC7")
EndIf

dbSelectArea("SC7")
If AllTrim(mv_par14) == "C7_DESCRI"
	cDescri := Alltrim(SC7->C7_DESCRI)
EndIf

If cPaisLoc <> "BRA" .And. !Empty( aValIVA )
	For nI := 1 To Len( aValIVA )
		nItemIVA += aValIVA[nI]
	Next
Endif

dbSelectArea("SC7")
@ li,000 PSAY C7_ITEM
@ li,005 PSAY C7_PRODUTO
nFlag++
@ li,021 PSAY Subs(cDescri,1,28)
dbSelectArea("SB1")
dbSeek(cFilial+SC7->C7_PRODUTO)
If Found()
	@ li,050 PSAY B1_GRUPO
EndIf
dbSelectArea("SC7")
@ li,076 PSAY C7_EMISSAO
@ li,086 PSAY C7_DATPRF
@ li,097 PSAY C7_QUANT Picture Tm(C7_QUANT,10,2)
@ li,109 PSAY C7_UM
If !Empty(C7_REAJUST)
	@ li,113 PSAY xMoeda(Formula(C7_REAJUST),SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,aTam[2],nTxMoeda) Picture tm(Formula(C7_REAJUST),10,aTam[2])
Else
	@ li,113 PSAY xMoeda(C7_PRECO,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,aTam[2],nTxMoeda) Picture tm(C7_PRECO,13,aTam[2])
Endif
nItemIPI := CalcIPI()[1]
nSalIPI := CalcIPI()[2]
@ li,128 PSAY xMoeda(C7_VLDESC,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)  Picture tm(C7_VLDESC,12,aTamVal[2])
If cPaisLoc <> "BRA"
	@ li,141 PSAY xMoeda(nItemIVA,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)  Picture tm(nItemIVA,15,aTamVal[2])
Else
	@ li,141 PSAY xMoeda(nItemIPI,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)  Picture tm(nItemIPI,15,aTamVal[2])
EndIf
@ li,157 PSAY xMoeda(nTotal,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda) Picture tm(nTotal,15,aTamVal[2])
@ li,173 PSAY C7_QUJE Picture tm(C7_QUJE,10,2)
nQuant_a_Rec := If(Empty(C7_RESIDUO),IIF(C7_QUANT-C7_QUJE<0,0,C7_QUANT-C7_QUJE),0)
@ li,189 PSAY nQuant_a_Rec Picture tm(C7_QUANT-C7_QUJE,10,2)

If Empty(C7_REAJUST)
	@ li,199 PSAY nQuant_a_Rec * (xMoeda(C7_PRECO,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)- ;
		xMoeda(C7_VLDESC,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda))+ ;
		xMoeda(nSalIPI,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda) Picture tm(C7_TOTAL,15,aTamVal[2])
Else
	@ li,199 PSAY (nQuant_a_Rec * xMoeda(Formula(C7_REAJUST),SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)) + ;
		xMoeda(nSalIPI,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda) Picture tm(C7_TOTAL,15,aTamVal[2])
Endif
@ li,215 PSAY If(Empty(C7_RESIDUO),STR0031,STR0032)		//'Nao'###'Sim'
//��������������������������������������������������������������Ŀ
//� Impressao da Descricao Adicional do Produto (se houver)      �
//����������������������������������������������������������������
For j:=29 TO Len(Trim(cDescri)) Step 28
	If !empty(Subs(cDescri,j,28))
		Li++
		If li > 60
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
		Endif
		@ li,21 PSAY SubStr(cDescri,j,28)
	Endif
Next j

Return(nTotal)


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � IMPORD2  � Autor � Claudinei M. Benzi    � Data � 05.09.91 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao do relatorio na 2a ordem                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ExpN1 := ImpOrd2()                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � ExpN1 = Valor total                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR120                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
STATIC Function ImpOrd2()

Local nQuant_a_Rec
Local aTam		:= TamSx3("C7_PRECO")
Local aTamVal	:= TamSx3("C7_VALICM")
Local nTotal	:= MaFisRet(,'NF_TOTAL')
Local aValIVA   := MaFisRet(,"NF_VALIMP")
Local nTxMoeda  := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_TXMOEDA,Nil)
Local nI

If cPaisLoc <> "BRA" .And. !Empty( aValIVA )
	For nI := 1 To Len( aValIVA )
		nItemIVA += aValIVA[nI]
	Next
Endif

dbSelectArea("SC7")
If ( cPaisLoc$"ARG|POR|EUA" )
	@ li,000 PSAY If(C7_TIPO==1,"P"+C7_NUM,"A"+C7_NUM)
Else
	@ li,000 PSAY C7_NUM
EndIf
@ li,007 PSAY C7_ITEM
nFlag++
@ li,012 PSAY C7_EMISSAO
@ li,023 PSAY C7_FORNECE
dbSelectArea("SA2")
If dbSeek(cFilial+SC7->C7_FORNECE+SC7->C7_LOJA)
	@li,(30+nDifNome) PSAY Subs(A2_NOME,1,nTamNome)
//	@li,66 PSAY Substr(A2_TEL,1,15)
Endif

DbSelectArea("SC7")
@ li,82 PSAY C7_DATPRF
@ li,93 PSAY C7_QUANT Picture tm(C7_QUANT,15,2)
If !Empty(C7_REAJUST)
	@ li,109 PSAY xMoeda(Formula(C7_REAJUST),SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,aTam[2],nTxMoeda) Picture tm(Formula(C7_REAJUST),15,aTam[2])
Else
	@ li,109 PSAY xMoeda(C7_PRECO,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,aTam[2],nTxMoeda) Picture tm(C7_PRECO,15,aTam[2])
Endif
nItemIPI := CalcIPI()[1]
nSalIPI := CalcIPI()[2]
@ li,124 PSAY xMoeda(C7_VLDESC,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)  Picture tm(C7_VLDESC,12,aTamVal[2])
If cPaisLoc <> "BRA"
	@ li,137 PSAY xMoeda(nItemIVA,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)  Picture tm(nItemIVA,15,aTamVal[2])
Else
	@ li,137 PSAY xMoeda(nItemIPI,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)  Picture tm(nItemIPI,15,aTamVal[2])
EndIf
@ li,153 PSAY xMoeda(nTotal,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda) Picture tm(nTotal,15,aTamVal[2])
@ li,169 PSAY C7_QUJE Picture tm(C7_QUJE,15,2)
nQuant_a_Rec := If(Empty(C7_RESIDUO),IIF(C7_QUANT-C7_QUJE<0,0,C7_QUANT-C7_QUJE),0)
@ li,185 PSAY nQuant_a_Rec Picture tm(C7_QUANT-C7_QUJE,10,2)

If Empty(C7_REAJUST)
	@ li,195 PSAY nQuant_a_Rec * (xMoeda(C7_PRECO,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)- ;
		xMoeda(C7_VLDESC,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda))+ ;
		xMoeda(nSalIPI,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda) Picture tm(C7_TOTAL,15,aTamVal[2])
Else
	@ li,195 PSAY (nQuant_a_Rec * xMoeda(Formula(C7_REAJUST),SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)) + ;
		xMoeda(nSalIPI,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda) Picture tm(C7_TOTAL,15,aTamVal[2])
Endif
@ li,211 PSAY If(Empty(C7_RESIDUO),STR0031,STR0032)		//'Nao'###'Sim'

Return(nTotal)

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � IMPORD3  � Autor � Claudinei M. Benzi    � Data � 05.09.91 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao do relatorio na 3a ordem                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ExpN1 := ImpOrd3()                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � ExpN1 = Valor total                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR120                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
STATIC Function ImpOrd3()

Local nQuant_a_Rec:=0
Local aTam		:= TamSx3("C7_PRECO")
Local aTamVal	:= TamSx3("C7_VALICM")
Local nTotal	:= MaFisRet(,"NF_TOTAL")
Local aValIVA  := MaFisRet(,"NF_VALIMP")
Local nI       := 0
Local j        := 0
Local cDescri := Alltrim(SC7->C7_DESCRI)
Local nTxMoeda := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_TXMOEDA,Nil)

If Empty(mv_par14)
	mv_par14 := "B1_DESC"
EndIf

//��������������������������������������������������������������Ŀ
//� Impressao da descricao generica do Produto.                  �
//����������������������������������������������������������������
If AllTrim(mv_par14) == "B1_DESC"
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek( xFilial("SB1")+SC7->C7_PRODUTO )
	cDescri := Alltrim(SB1->B1_DESC)
	dbSelectArea("SC7")
EndIf
//��������������������������������������������������������������Ŀ
//� Impressao da descricao cientifica do Produto.                �
//����������������������������������������������������������������
If AllTrim(mv_par14) == "B5_CEME"
	dbSelectArea("SB5")
	dbSetOrder(1)
	If dbSeek( xFilial("SB5")+SC7->C7_PRODUTO )
		cDescri := Alltrim(B5_CEME)
	EndIf
	dbSelectArea("SC7")
EndIf

dbSelectArea("SC7")
If AllTrim(mv_par14) == "C7_DESCRI"
	cDescri := Alltrim(SC7->C7_DESCRI)
EndIf

If cPaisLoc <> "BRA" .And. !Empty( aValIVA )
	For nI := 1 To Len( aValIVA )
		nItemIVA += aValIVA[nI]
	Next
Endif
dbSelectArea("SC7")
If ( cPaisLoc$"ARG|POR|EUA" )
	@li,000 PSAY If(C7_TIPO==1,"P"+C7_NUM,"A"+C7_NUM)
Else
	@li,000 PSAY C7_NUM
EndIf
@ li,007 PSAY C7_ITEM
nFlag++
@ li,012 PSAY C7_EMISSAO
@ li,023 PSAY C7_PRODUTO
@ li,039 PSAY Subs(cDescri,1,28)
dbSelectArea("SB1")
If dbSeek(xFilial("SB1")+SC7->C7_PRODUTO)
	@ li,068 PSAY B1_GRUPO
Endif
dbSelectArea("SC7")
@ li,073 PSAY C7_DATPRF
@ li,085 PSAY C7_QUANT Picture tm(C7_QUANT,13,2)
If !Empty(C7_REAJUST)
	@li,99 PSAY xMoeda(Formula(C7_REAJUST),SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,aTam[2],nTxMoeda) Picture tm(Formula(C7_REAJUST),15,aTam[2])
Else
	@li,99 PSAY xMoeda(C7_PRECO,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,aTam[2],nTxMoeda) Picture tm(C7_PRECO,15,aTam[2])
Endif
nItemIPI := CalcIPI()[1]
nSalIPI := CalcIPI()[2]
@ li,115 PSAY xMoeda(C7_VLDESC,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda) Picture tm(C7_VLDESC,12,2)
If cPaisLoc <> "BRA"
	@ li,128 PSAY xMoeda(nItemIVA,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)  Picture tm(nItemIVA,15,aTamVal[2])
Else
	@ li,128 PSAY xMoeda(nItemIPI,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)  Picture tm(nItemIPI,15,aTamVal[2])
EndIf
@ li,143 PSAY xMoeda(nTotal,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda) Picture tm(nTotal,15,aTamVal[2])
@ li,158 PSAY C7_QUJE	Picture tm(C7_QUJE,15,2)
nQuant_a_Rec := If(Empty(C7_RESIDUO),IIF(C7_QUANT-C7_QUJE<0,0,C7_QUANT-C7_QUJE),0)
@ li,174 PSAY nQuant_a_Rec Picture tm(C7_QUANT-C7_QUJE,10,2)

If Empty(C7_REAJUST)
	@ li,185 PSAY nQuant_a_Rec * (xMoeda(C7_PRECO,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)- ;
		xMoeda(C7_VLDESC,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda))+ ;
		xMoeda(nSalIPI,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda) Picture tm(C7_TOTAL,15,aTamVal[2])
Else
	@ li,185 PSAY (nQuant_a_Rec * xMoeda(Formula(C7_REAJUST),SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)) + ;
		xMoeda(nSalIPI,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda) Picture tm(C7_TOTAL,15,aTamVal[2])
Endif
@ li,203 PSAY If(Empty(C7_RESIDUO),STR0031,STR0032)		//'Nao'###'Sim'

//��������������������������������������������������������������Ŀ
//� Impressao da Descricao Adicional do Produto (se houver)      �
//����������������������������������������������������������������
For j:=29 TO Len(Trim(cDescri)) Step 28
	If !empty(Subs(cDescri,j,28))
		li++
		If li > 60
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
		Endif
		@ li,39 PSAY SubStr(cDescri,j,28)
	Endif
Next j

Return(nTotal)


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � IMPORD4  � Autor � Ricardo Berti         � Data � 03.03.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao do relatorio na 4a ordem                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ExpN1 := ImpOrd4()                                     	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � ExpN1 = Valor total 	                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR120                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
STATIC Function ImpOrd4()

Local nQuant_a_Rec
Local aTam		:= TamSx3("C7_PRECO")
Local aTamVal	:= TamSx3("C7_VALICM")
Local nTotal	:= MaFisRet(,'NF_TOTAL')
Local aValIVA   := MaFisRet(,"NF_VALIMP")
Local nTxMoeda  := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_TXMOEDA,Nil)
Local nI		:= 0
Local j			:= 0
Local cDescri	:= Alltrim(SC7->C7_DESCRI)

//��������������������������������������������������������������Ŀ
//� Redefine tamanho da razao social do fornecedor               �
//����������������������������������������������������������������
PRIVATE nDifNome := 0
PRIVATE nTamNome := 29
If aTamSXG[1] != aTamSXG[3]
	nDifNome := aTamSXG[4] - aTamSXG[3]
	nTamNome := if(aTamSXG[1] != aTamSXG[3],29-(aTamSXG[4]-aTamSXG[3]),29)
Endif
If Empty(mv_par14)
	mv_par14 := "B1_DESC"
EndIf

//��������������������������������������������������������������Ŀ
//� Impressao da descricao generica do Produto.                  �
//����������������������������������������������������������������
If AllTrim(mv_par14) == "B1_DESC"
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek( xFilial("SB1")+SC7->C7_PRODUTO )
	cDescri := Alltrim(SB1->B1_DESC)
	dbSelectArea("SC7")
EndIf
//��������������������������������������������������������������Ŀ
//� Impressao da descricao cientifica do Produto.                �
//����������������������������������������������������������������
If AllTrim(mv_par14) == "B5_CEME"
	dbSelectArea("SB5")
	dbSetOrder(1)
	If dbSeek( xFilial("SB5")+SC7->C7_PRODUTO )
		cDescri := Alltrim(B5_CEME)
	EndIf
	dbSelectArea("SC7")
EndIf

dbSelectArea("SC7")
If AllTrim(mv_par14) == "C7_DESCRI"
	cDescri := Alltrim(SC7->C7_DESCRI)
EndIf

If cPaisLoc <> "BRA" .And. !Empty( aValIVA )
	For nI := 1 To Len( aValIVA )
		nItemIVA += aValIVA[nI]
	Next
Endif

dbSelectArea("SC7")
If ( cPaisLoc$"ARG|POR|EUA" )
	@ li,000 PSAY If(C7_TIPO==1,"P"+C7_NUM,"A"+C7_NUM)
Else
	@ li,000 PSAY C7_NUM
EndIf
@ li,007 PSAY C7_ITEM
nFlag++
@ li,012 PSAY C7_EMISSAO
@ li,023 PSAY C7_PRODUTO
@ li,039 PSAY Subs(cDescri,1,18)
@ li,058 PSAY C7_FORNECE
dbSelectArea("SA2")
If dbSeek(cFilial+SC7->C7_FORNECE+SC7->C7_LOJA)
	@li,(65+nDifNome) PSAY Subs(A2_NOME,1,nTamNome)
//	@li,95 PSAY Substr(A2_TEL,1,15)
Endif
DbSelectArea("SC7")
@ li,110 PSAY C7_QUANT Picture tm(C7_QUANT,12,2)
If !Empty(C7_REAJUST)
	@ li,123 PSAY xMoeda(Formula(C7_REAJUST),SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,aTam[2],nTxMoeda) Picture tm(Formula(C7_REAJUST),12,aTam[2])
Else
	@ li,123 PSAY xMoeda(C7_PRECO,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,aTam[2],nTxMoeda) Picture tm(C7_PRECO,12,aTam[2])
Endif
nItemIPI:= CalcIPI()[1]
nSalIPI	:= CalcIPI()[2]
@ li,136 PSAY xMoeda(C7_VLDESC,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)  Picture tm(C7_VLDESC,10,aTamVal[2])
If cPaisLoc <> "BRA"
	@ li,147 PSAY xMoeda(nItemIVA,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)  Picture tm(nItemIVA,12,aTamVal[2])
Else
	@ li,147 PSAY xMoeda(nItemIPI,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)  Picture tm(nItemIPI,12,aTamVal[2])
EndIf
@ li,160 PSAY xMoeda(nTotal,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda) Picture tm(nTotal,15,aTamVal[2])
@ li,176 PSAY C7_QUJE Picture tm(C7_QUJE,12,2)
nQuant_a_Rec := If(Empty(C7_RESIDUO),IIF(C7_QUANT-C7_QUJE<0,0,C7_QUANT-C7_QUJE),0)
@ li,189 PSAY nQuant_a_Rec Picture tm(C7_QUANT-C7_QUJE,10,2)
If Empty(C7_REAJUST)
	@ li,200 PSAY nQuant_a_Rec * (xMoeda(C7_PRECO,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)- ;
		xMoeda(C7_VLDESC,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda))+ ;
		xMoeda(nSalIPI,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda) Picture tm(C7_TOTAL,15,aTamVal[2])
Else
	@ li,200 PSAY (nQuant_a_Rec * xMoeda(Formula(C7_REAJUST),SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)) + ;
		xMoeda(nSalIPI,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda) Picture tm(C7_TOTAL,15,aTamVal[2])
Endif
@ li,217 PSAY If(Empty(C7_RESIDUO),STR0031,STR0032)		//'Nao'###'Sim'

//��������������������������������������������������������������Ŀ
//� Impressao da Descricao Adicional do Produto (se houver)      �
//����������������������������������������������������������������
For j:=19 TO Len(Trim(cDescri)) Step 18
	If !empty(Subs(cDescri,j,18))
		li++
		If li > 60
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
		Endif
		@ li,39 PSAY SubStr(cDescri,j,18)
	Endif
Next j

Return(nTotal)

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � IMPTOT   � Autor � Cristina M. Ogura     � Data � 03.02.95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao dos totais do relatorio                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ImpTot(ExpN1)                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = tamanho limite da linha                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR120                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
STATIC Function ImpTot(limite)

Local nc1,nc2,nc3,nc4,nc5,nc6  	// numeros das colunas para aparecer os
								// totais dependendo do tipo de rela-
								// torio escolhido(1,2,3)
nc1:=nc2:=nc3:=nc4:=nc5:=nc6:=0
If nOrdem = 1
	nc3:= 141
	nc4:= 157; nc6:= 199
ElseIf nOrdem = 2
	nc3:= 137
	nc4:= 153;nc6:= 195
ElseIf nOrdem = 3
	nc3:= 128
	nc4:= 143;nc6:= 185
Else
	nc3:= 147-3
	nc4:= 160;nc6:= 200
Endif
li+=2
@ li,000 PSAY STR0033	//"Total Geral "
If cPaisLoc <> "BRA"
	@ li,nc3 PSAY nTotIVA   Picture tm(nTotIVA,15,2)
Else
	@ li,nc3 PSAY nT_vl_ipi Picture tm(nT_vl_ipi,15,2)
EndIf
@ li,nc4 PSAY nT_vl_total           Picture tm(nT_vl_total,15,2)
@ li,nc6 PSAY nT_sd_receb - nT_desc Picture tm(nT_sd_receb,15,2)
Return(.T.)


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � IMPITEM  � Autor � Rodrigo de A. Sartorio� Data � 08.05.95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao dos totais p/ item de acordo com a ordem         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR120                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
STATIC Function ImpItem(nTipo)

Local nc1,nc2,nc3,nc4,nc5,nc6		// numeros das colunas para aparecer os
Local nTxMoeda := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_TXMOEDA,Nil)
// totais dependendo do tipo de rela-
// torio escolhido(1,2,3)

nc1:=nc2:=nc3:=nc4:=nc5:=nc6:=0
If nOrdem = 1
	nc3:= 141
	nc4:= 157; nc6:= 199
	cTotal:=STR0034	//"Total dos Itens "
ElseIf nOrdem = 2
	nc3:= 137
	nc4:= 153; nc6:= 195
	cTotal:=STR0035	//"Total do Produto"
ElseIf nOrdem = 3
	nc3:= 128
	nc4:= 143;nc6:= 185
	cTotal:=STR0036	//"Total do Fornecedor"
Else //AQUI
	nc3:= 147-3
	nc4:= 160;nc6:= 200
	cTotal:=STR0043 //"Total da Previsao de Entrega"
Endif

li ++
@ li,000 PSAY cTotal
If cPaisLoc <> "BRA"
	@ li,nc3 PSAY nValIVA  Picture tm(nValIVA,15,2)
Else
	@ li,nc3 PSAY nValIpi  Picture tm(nValIpi,15,2)
EndIf
@ li,nc4 PSAY nTotal   Picture tm(nTotal,15,2)
@ li,nc6 PSAY (nSaldo-nDesc) Picture tm(nSaldo,15,2)
li++
If li > 60
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
Endif
If nOrdem <> 2 .Or. (nOrdem == 2 .And. nTipo <> 2)
	nT_desc += xMoeda(nDesc,SC7->C7_MOEDA,mv_par13,SC7->C7_DATPRF,,nTxMoeda)
Endif	
nDesc:=0
Return(.T.)

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CALCIPI  � Autor � Marcos Bregantim      � Data � 30.08.95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Calculo do IPI                                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ExpA1 := CalcIPI()                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � ExpA1 = array com valor e saldo de IPI					  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR120                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function CalcIPI()

Local nToTIPI	:= 0,nTotal,nSalIPI:= 0
Local nValor 	:= (C7_QUANT) * IIf(Empty(C7_REAJUST),C7_PRECO,Formula(C7_REAJUST))
Local nSaldo 	:= (C7_QUANT-C7_QUJE) * IIf(Empty(C7_REAJUST),C7_PRECO,Formula(C7_REAJUST))
Local nTotDesc := C7_VLDESC

If cPaisLoc <> "BRA"
	nSalIPI := (C7_QUANT-C7_QUJE) * nItemIVA / C7_QUANT
Else
	If nTotDesc == 0
		nTotDesc := CalcDesc(nValor,SC7->C7_DESC1,SC7->C7_DESC2,SC7->C7_DESC3)
	EndIF
	nTotal := nValor - nTotDesc
	nTotIPI := IIF(SC7->C7_IPIBRUT == "L",nTotal, nValor) * ( SC7->C7_IPI / 100 )
	If Empty(C7_RESIDUO)
		nTotal := nSaldo - nTotDesc
		nSalIPI := IIF(SC7->C7_IPIBRUT == "L",nTotal, nSaldo) * ( SC7->C7_IPI / 100 )
	Endif
EndIf

Return {nTotIPI,nSalIPI}

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Formula  � Autor � Julio Saraiva         � Data � 11/04/12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Interpreta formula cadastrada trocando o Alias             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � xExp1:= Formula(cExp1,nExp2)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� xExp1:= Retorna formula iterpretada                        ���
���          � cExp1:= Codigo da formula previamente cadastrada em SM4    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GENERICO                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User FUNCTION Form120(cFormula)
Local xAlias 
Local cForm		:= "" , xValor
Local cString 	:= "SC7->"
Local cNewAlias := "" 
Local cNewForm	:= ""
//����������������������������������������������������������������������Ŀ
//�Salva a integridade dos dados                                         �
//������������������������������������������������������������������������
xAlias := Alias()

DbSelectArea("SM4")
If DbSeek(cFilial+cFormula)
	cForm := AllTrim(M4_FORMULA)
	cNewAlias := xAlias + "->"
	cNewForm := StrTran(cForm,cString,cNewAlias)
	DbSelectArea(xAlias)      
	xValor := &cNewForm
Else
	xValor := NIL
EndIf
DbSelectArea(xAlias)
Return xValor

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �R120FIniPC� Autor � Edson Maricate        � Data �20/05/2000���
�������������������������������������������������������������������������Ĵ��
���Descricao � Inicializa as funcoes Fiscais com o Pedido de Compras      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � R120FIniPC(ExpC1,ExpC2)                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 := Numero do Pedido                                  ���
���          � ExpC2 := Item do Pedido                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR110,MATR120,Fluxo de Caixa                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function R120FIniPC(cPedido,cItem,cSequen,cFiltro)

Local aArea		:= GetArea()
Local aAreaSC7	:= SC7->(GetArea())
Local cValid		:= ""
Local nPosRef		:= 0
Local nItem		:= 0
Local cItemDe		:= IIf(cItem==Nil,'',cItem)
Local cItemAte	:= IIf(cItem==Nil,Repl('Z',Len(SC7->C7_ITEM)),cItem)
Local cRefCols	:= ''
DEFAULT cSequen	:= ""
DEFAULT cFiltro	:= ""

dbSelectArea("SC7")
dbSetOrder(1)
If dbSeek(xFilial("SC7")+cPedido+cItemDe+Alltrim(cSequen))
	MaFisEnd()
	MaFisIni(SC7->C7_FORNECE,SC7->C7_LOJA,"F","N","R",{})
	While !Eof() .AND. SC7->C7_FILIAL+SC7->C7_NUM == xFilial("SC7")+cPedido .AND. ;
			SC7->C7_ITEM <= cItemAte .AND. (Empty(cSequen) .OR. cSequen == SC7->C7_SEQUEN)

		// Nao processar os Impostos se o item possuir residuo eliminado  
		If &cFiltro
			dbSelectArea('SC7')
			dbSkip()
			Loop
		EndIf
            
		// Inicia a Carga do item nas funcoes MATXFIS  
		nItem++
		MaFisIniLoad(nItem)
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek('SC7')
		While !EOF() .AND. (X3_ARQUIVO == 'SC7')
			cValid	:= StrTran(UPPER(SX3->X3_VALID)," ","")
			cValid	:= StrTran(cValid,"'",'"')
			If "MAFISREF" $ cValid
				nPosRef  := AT('MAFISREF("',cValid) + 10
				cRefCols := Substr(cValid,nPosRef,AT('","MT120",',cValid)-nPosRef )
				// Carrega os valores direto do SC7.           
				//MaFisLoad(cRefCols,&("SC7->"+ SX3->X3_CAMPO),nItem) //ERRO C7_OPER RICKY
				IF SX3->X3_CAMPO <>"C7_OPER"
					MaFisLoad(cRefCols,&("SC7->"+ SX3->X3_CAMPO),nItem)
				ENDIF
			
			EndIf
			dbSkip()
		End
		MaFisEndLoad(nItem,2)
		dbSelectArea('SC7')
		dbSkip()
	End
EndIf

RestArea(aAreaSC7)
RestArea(aArea)

Return .T.

Static Function SchedDef()

Local aParam  := {}
Local aOrd := {}
Aadd( aOrd, STR0004 ) // "Por Numero"
Aadd( aOrd, STR0005 ) // "Por Produto"
Aadd( aOrd, STR0006 ) // "Por Fornecedor"
Aadd( aOrd, STR0049 ) // "Por Previsao de Entrega "

aParam := { "R",;			//Tipo R para relatorio P para processo
            "MTR120",;	//Pergunte do relatorio, caso nao use passar ParamDef
            "SC7",;				//Alias
            aOrd,;				//Array de ordens
            STR0007}				//Titulo

Return aParam
