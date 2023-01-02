/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ExpCisp º Autor ³ Cristiano Figueiroa º Data ³ 15/04/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Exporta Arquivos do Protheus para o Cisp Informacoes       º±±
±±º          ³ Comerciais.                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasitech.                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#Include "RwMake.ch"
#Include "Topconn.ch"
#include "protheus.ch"
#include "ap5mail.ch"

User Function ExpCisp2()
Local _cPerg		:= PadR("EXPCISP2",Len(SX1->X1_GRUPO))
Local _aRegs    	:= {}
Local _aCabSX1		:= {"X1_GRUPO","X1_ORDEM","X1_PERGUNT","X1_VARIAVL","X1_TIPO","X1_TAMANHO","X1_DECIMAL","X1_GSC","X1_VAR01"}
Local nOpc			:= 0
Local cCadastro		:= "Rotina de Exportacao para o CISP."
Local aSay			:= {}
Local aArea			:= GetArea()
Local aButton		:= {} 
Private dDtAtual	:= MsDate()
Private _cTLOG

//parametros para o processamento
aAdd(_aRegs,{_cPerg,"01", "Código do Associado ?  ","mv_ch1","N",04,0,"G","mv_par01"})
aAdd(_aRegs,{_cPerg,"02", "Pasta para Exportação ?","mv_ch2","C",99,0,"G","mv_par02"})

U_GISX1(_aRegs,_aCabSX1)

Pergunte(_cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a Janela de Dialogo com as Mensagens Explicativas                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd ( aSay , "Essa rotina tem como objetivo a Exportação de Arquivo Texto para o CISP conforme Layout " )
aAdd ( aSay , "Desenvolvida Especificamente para a Brasitech" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a os Botoes a serem Disponibilizados na Tela                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd ( aButton , { 1 , .T. , { || nOpc := 1,	FechaBatch()	}} )
aAdd ( aButton , { 2 , .T. , { || FechaBatch()					}} )
aAdd ( aButton , { 5 , .T. , { || Pergunte( _cPerg , .T. )		}} )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre a Tela para o Processamento das Opcoes                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FormBatch( cCadastro , aSay , aButton )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso o Usuario Tenha acessado o Botao de Ok inicia o processamento         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 1

	if MsgBox("Confirma a Geração dos Arquivos ? ","Pergunta!","YESNO")
	
		CriaLog()

		Processa( { |lEnd| Gera2Cisp() } , "Integração Protheus x CISP (versão 2.02)" , "Gerando o Arquivo Texto" , .T. )
		
	endif   

Endif   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha os Arquivos Temporarios e Restaura as Areas Antes da Execucao da Rotina  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea( aArea )

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GeraCisp º Autor ³ Cristiano Figueiroa º Data ³ 15/04/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Seleciona os Clientes a Serem Considerados no CISP.          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Brasitech                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Gera2Cisp()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declara as Variaveis Utilizadas na Rotina                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cQuery, aDadCom, aMedAtra, aVlVenc, aVlMedVen, nVl5Dias, nMed5Dias, nVl15Dias, nMed15Dia, nVl30Dias, nMed30Dia, nVlVec
Local nPonMed, nAriMed, nMedPap, nMedAap, nVlPenC, nVlUltC, dDtPenC, dDtUltC, cStrEmp, nVlDebAtu, lNovo, lGrava, cLog, aInfReg
Local cEol		:= Chr(13) + Chr(10)
Local cStrCliente, dPriCom, nLC, cRaizCNPJ
Private cArqCisp:= "PFJ_" + Alltrim(MV_PAR01) + ".TXT"
//Private cArqCisp:= "PFJ_" + StrZero(MV_PAR01,4) + ".TXT"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama a Funcao que Carrega os Cnpjs do Grupo Brasitech                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cStrEmp := EmpGrp()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Query para Selecao de Pessoas Juridicas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT SA1.A1_FILIAL, SA1.A1_COD, SA1.A1_LOJA, SA1.A1_CGC, SA1.A1_PRICOM, A1_LC "
cQuery += "FROM " + RetSqlName("SA1") + " SA1 "
cQuery += "WHERE SUBSTRING(SA1.A1_CGC, 12, 1) != ' ' AND SA1.A1_PRICOM <> '' AND SA1.D_E_L_E_T_ = ' ' AND "
cQuery +=       "SA1.A1_EST <> 'EX' AND SA1.A1_CGC <> '08296596000120' AND SUBSTRING(SA1.A1_CGC, 1, 8) NOT IN (" + cStrEmp + ") "
cQuery += "ORDER BY SUBSTRING(SA1.A1_CGC ,1 ,8)"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama a Funcao que Readequa a Query ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery :=  ChangeQuery( cQuery )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera a Query em Arquivo Texto para Analises pelo Query Analyser ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Memowrite("Gera2Cisp.Sql" , cQuery )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre o Resultado da Query no Alias QRY ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TcQuery cQuery New Alias "CLI_QRY"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta os Campos Apos a Execucao da Query ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TcSetField( "CLI_QRY" , "A1_PRICOM"  , "D" , 08 , 0 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Appenda a Query na Tabela ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SA1->( dbSetOrder(3) )
DbSelectArea("CLI_QRY")
DbGotop()
ProcRegua( CLI_QRY->( Reccount() ) )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa o Arquivo com os Clientes Selecionados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do While CLI_QRY->( !Eof() )

	cRaizCNPJ	:= Left( CLI_QRY->A1_CGC, 8 )
	dPriCom		:= CLI_QRY->A1_PRICOM
	nLC			:= CLI_QRY->A1_LC
	cStrCliente	:= ""	
	do while CLI_QRY->( !Eof() .and. Left( CLI_QRY->A1_CGC, 8 ) = cRaizCNPJ )
		
//		cStrCliente += "'" + CLI_QRY->( A1_FILIAL + A1_COD + A1_LOJA ) + "',"
  		cStrCliente += "'" + CLI_QRY->( A1_COD + A1_LOJA ) + "',"
  		
		dPriCom		:= iif( CLI_QRY->A1_PRICOM < dPriCom, CLI_QRY->A1_PRICOM, dPriCom )	//menor data de primeira compra
		nLC			:= iif( CLI_QRY->A1_LC > nLC, CLI_QRY->A1_LC, nLC )					//maior valor de limite de credito
			
		CLI_QRY->( dbSkip() )

	enddo
	cStrCliente := Left( cStrCliente, Len(cStrCliente) - 1 )

	IncProc( "Processando dados do CNPJ: " + Transform( cRaizCNPJ, "@R 99.999.999" ) + "/****-**" )
	
	nMedPap		:= 0				//  12 - Media Ponderada de Atraso nos Pagamentos
	nMedAap		:= 0				//  13 - Media Aritmetica dos Dias de Atraso de Pagamentos
	dDtPenC		:= CtoD("")			//  23 - Data da Penultima Compra
	nVlPenC		:= 0				//  24 - Valor da Penultima Compra
	dDtUltC		:= CtoD("")			//  06 - Data da Ultima Compra
	nVlUltC		:= 0				//  07 - Valor da Ultima Compra
	dDtAcum		:= CtoD("")			// Data de Maior Acumulo
	nVlAcum		:= 0				// Valor de todas as filiais com maior acumulo
	nVlVec		:= 0				// Valor Debito Atual Vencer
	nPonMed		:= 0				// Valor da media ponderada a vencer
	nAriMed		:= 0				// Valor da media aritmetica a vencer
	nVl5Dias		:= 0
	nMed5Dias	:= 0
	nVl15Dias	:= 0
	nMed15Dia	:= 0
	nVl30Dias	:= 0
	nMed30Dia	:= 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SEQ 06/07/23/24 - Retorna os Valores da Ultima e Penultima Compra ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aDadCom  := InfComp( cStrCliente )
	if Len(aDadCom) > 0
		dDtPenC := aDadCom[1]			// 23 - Data da Penultima Compra
		nVlPenC := aDadCom[2]			// 24 - Valor da Penultima Compra
		dDtUltC := aDadCom[3]			// 06 - Data da Ultima Compra
		nVlUltC := aDadCom[4]			// 07 - Valor da Ultima Compra
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ignora caso nao tenha realizado nenhuma compra.                                   ³
	//³ Retirei a validacao se a data da ultima compra e anterior a um ano pois filtro    ³
	//³ somente na geracao do arquivo texto. Por Adalberto em 30/07/12.                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if Empty( dDtUltC ) .or. dDtUltC < ( dDtAtual - 365 )
		Loop
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SEQ 11 e 12 - Media ponderada e Media aritmetica de atraso ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aMedAtra := VlAtraso( cStrCliente )
	if Len(aMedAtra) > 0
		nMedPap := aMedAtra[1,1]							//  12 - Media Ponderada de Atraso nos Pagamentos
		nMedAap := aMedAtra[1,2]							//  13 - Media Aritmetica dos Dias de Atraso de Pagamentos
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SEQ 09 - Debito Atual Total ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVlDebAtu := VlDebAtu( cStrCliente )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SEQ 07 e 08 - Funcao para retornar a Data e o Valor do maior acumulo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAcumul:= MaiorAcu( cStrCliente )
	If Len(aAcumul) > 0
		dDtAcum	:= aAcumul[1,1]										// Data de Maior Acumulo
		nVlAcum	:= aAcumul[1,2]										// Valor de todas as filiais com maior acumulo
	Endif

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³ SEQ 13/14/15 - Chama a Funcao que Calcula a Media Ponderada de Titulos a Vencer e Prazo Medio de Vendas ³
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aVlMedVen := VlMedVen( cStrCliente )
      
	If Len( aVlMedVen ) > 0
		nVlVec  := aVlMedVen[1,1]									// Valor Debito Atual Vencer
		nPonMed := aVlMedVen[1,2]									// Valor da media ponderada a vencer
		nAriMed := aVlMedVen[1,3]									// Valor da media aritmetica a vencer
	Endif

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³ SEQ 16/17/18/19/20/21 - Chama a Funcao que Calcula os Debitos nao Pagos com mais de 5 , 15 ou 30 Dias  ³
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aVlVenc  := CalcVenc( cStrCliente )

	If Len( aVlVenc ) > 0
		nVl5Dias  := aVlVenc[1,1]				// Valor do debito atual vencido ha mais de 5 dias
		nMed5Dias := aVlVenc[1,2]				// Media ponderada dos titulos vencido e nao pagos a mais de 5 dias
		nVl15Dias := aVlVenc[1,3]				// Valor do debito atual vencido ha mais de 15 dias
		nMed15Dia := aVlVenc[1,4]				// Media ponderada dos titulos vencido e nao pagos a mais de 15 dias
		nVl30Dias := aVlVenc[1,5]				// Valor do debito atual vencido ha mais de 30 dias
		nMed30Dia := aVlVenc[1,6]				// Media ponderada dos titulos vencido e nao pagos a mais de 30 dias
	Endif   

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pesquisa se ja existe o CNPJ ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SZF->( dbSetOrder( 1 ) )
	lNovo	:= SZF->( !dbSeek( xFilial("SZF") + cRaizCNPJ ) )
	
	lGrava	:= .T.
	cLog 	:= ""
	

	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Criticas para qualquer registro ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//(11) - valor do maior acumulo MENOR QUE debito atual.
 	if nVlAcum < nVlDebAtu
		lGrava	:= .F.
		cLog	+= "(11) - valor do maior acumulo MENOR QUE debito atual." + cEol
	endif

	//(63) - data penultima compra MENOR data cliente desde.
	if dDtPenC < dPriCom .and. !Empty(dDtPenC)
		lGrava	:= .F.
		cLog	+= "(63) - data penultima compra MENOR data cliente desde." + cEol
	endif
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Criticas quando NAO for um registro novo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if !lNovo
        //(7) - data ultima compra MENOR QUE data ultima compra anterior.
		if dDtUltC < SZF->ZF_DUCM
			lGrava	:= .F.
			cLog	+= "(7) - data ultima compra MENOR QUE data ultima compra anterior." + cEol
		endif
                
		//(22) - data do maior acumulo MENOR QUE a mesma data informada anteriormente.
		if dDtAcum < SZF->ZF_DMAC .and. SZF->ZF_DMAC >= (dDtAtual - 365)
			lGrava	:= .F.
			cLog	+= "(22) - data do maior acumulo MENOR QUE a mesma data informada anteriormente." + cEol
		endif
        
		//(23) - valor do maior acumulo MENOR QUE valor do maior acumulo informado anteriormente.
		if nVlAcum < SZF->ZF_VMAC .and. SZF->ZF_DMAC >= (dDtAtual - 365)
			lGrava	:= .F.
			cLog	+= "(23) - valor do maior acumulo MENOR QUE valor do maior acumulo informado anteriormente." + cEol
		endif
		
		//(24) - data cliente desde DIFERENTE da data cliente desde informada anteriormente.
		if dPriCom != SZF->ZF_DCDD
			lGrava	:= .F.
			cLog	+= "(24) - data cliente desde DIFERENTE da data cliente desde informada anteriormente." + cEol
		endif
		
		//(48) - SEM data penultima compra SENDO data ultima compra DIFERENTE data ultima compra informada anteriormente.
		if Empty( dDtPenC ) .and. dDtUltC != SZF->ZF_DUCM
			lGrava	:= .F.
			cLog	+= "(48) - SEM data penultima compra SENDO data ultima compra DIFERENTE data ultima compra informada anteriormente." + cEol
		endif
		
		//(54) - data maior acumulo IGUAL data maior acumulo anterior E valor maior acumulo DIFERENTE valor maior acumulo anterior.
		if dDtAcum = SZF->ZF_DMAC .and. nVlAcum != SZF->ZF_VMAC
			lGrava	:= .F.
			cLog	+= "(54) - data maior acumulo IGUAL data maior acumulo anterior E valor maior acumulo DIFERENTE valor maior acumulo anterior." + cEol
		endif

		//(59) - Vl.Maior Acum. MAIOR Vl.Maior Acum. Ant. E Dt.Maior Acum. MENOR Dt. Infor.Ant.
		if nVlAcum > SZF->ZF_VMAC .and. dDtAcum < SZF->ZF_DMAC
			lGrava	:= .F.
			cLog	+= "(59) - Vl.Maior Acum. MAIOR Vl.Maior Acum. Ant. E Dt.Maior Acum. MENOR Dt. Infor.Ant." + cEol
		endif
		
		//(60) - data maior acumulo DIFERENTE data maior acumulo anterior E data maior acumulo MENOR data informacao anterior.
		if dDtAcum != SZF->ZF_DMAC .and. dDtAcum < SZF->ZF_DDAT 						.and. SZF->ZF_DMAC >= (dDtAtual - 365)
			lGrava	:= .F.
			cLog	+= "(60) - data maior acumulo DIFERENTE data maior acumulo anterior E data maior acumulo MENOR data informacao anterior." + cEol
		endif
		
		//(64) - data informacao atual - data informacao anterior MENOR que media atraso 5 dias atual - media atraso 5 dias anterior.
		if ( dDtAtual - SZF->ZF_DDAT ) < ( nVl5Dias - SZF->ZF_DATV )
			lGrava	:= .F.
			cLog	+= "(64) - data informacao atual - data informacao anterior MENOR que media atraso 5 dias atual - media atraso 5 dias anterior." + cEol
		endif

	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava as informacoes na tabela SZF (CISP) ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if !lGrava

		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		  ³ Gravacao do log da inconsistencia encontrada                                ³
		  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
        
		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		  ³ Vetor para armazenamento de informacoes do registro com inconsistencia      ³
		  ³ [1] - nome do campo                                                         ³
		  ³ [2] - informacao anterior, se for um registro novo aparecera a string 'NOVO'³
		  ³ [3] - informacao atual (conteudo da variavel de memoria)                    ³
		  ³ [4] - posicao do campo no layout                                            ³
		  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		aInfReg := {	{"ZF_CCLI", ""																				, cRaizCNPJ						 								, "01 - Identificacao"},;
						{"ZF_DDAT", iif( lNovo, "NOVO", DtoC( SZF->ZF_DDAT ) )										, DtoC( dDtAtual )												, "04 - Data da Informacao"},;
						{"ZF_DCDD", iif( lNovo, "NOVO", DtoC( SZF->ZF_DCDD ) )										, DtoC( dPriCom )												, "05 - Data Cadastramento do Cliente"},;
						{"ZF_DUCM", iif( lNovo, "NOVO", DtoC( SZF->ZF_DUCM ) )										, DtoC( dDtUltC )												, "06 - Data da Ultima Compra"},;
						{"ZF_VULC", iif( lNovo, "NOVO", Transform( SZF->ZF_VULC, 	PesqPict("SZF","ZF_VULC") ) )	, Transform( nVlUltC, 			PesqPict("SZF","ZF_VULC") )		, "07 - Valor da Ultima Compra"},;
						{"ZF_DMAC", iif( lNovo, "NOVO", DtoC( SZF->ZF_DMAC ) )										, DtoC( dDtAcum )												, "08 - Data do Maior Acumulo Pendente"},;
						{"ZF_VMAC", iif( lNovo, "NOVO", Transform( SZF->ZF_VMAC, 	PesqPict("SZF","ZF_VMAC") ) )	, Transform( nVlAcum, 			PesqPict("SZF","ZF_VMAC") )		, "09 - Valor do Maior Acumulo Pendente"},;
						{"ZF_VSAT", iif( lNovo, "NOVO", Transform( SZF->ZF_VSAT, 	PesqPict("SZF","ZF_VSAT") ) )	, Transform( nVlDebAtu, 		PesqPict("SZF","ZF_VSAT") )		, "10 - Valor Debito Atual Total"},;
						{"ZF_VLCR", iif( lNovo, "NOVO", Transform( SZF->ZF_VLCR, 	PesqPict("SZF","ZF_VLCR") ) )	, Transform( nLC, 				PesqPict("SZF","ZF_VLCR") )		, "11 - Valor do Limite de Credito"},;
						{"ZF_QPAG", iif( lNovo, "NOVO", Transform( SZF->ZF_QPAG, 	PesqPict("SZF","ZF_QPAG") ) )	, Transform( nMedPap, 			PesqPict("SZF","ZF_QPAG") )		, "12 - Media Ponderada de Atraso nos Pagamentos"},;
						{"ZF_QDAP", iif( lNovo, "NOVO", Transform( SZF->ZF_QDAP, 	PesqPict("SZF","ZF_QDAP") ) )	, Transform( nMedAap, 			PesqPict("SZF","ZF_QDAP") )		, "13 - Media Aritmetica dos Dias de Atraso de Pagamentos"},;
						{"ZF_VDAV", iif( lNovo, "NOVO", Transform( SZF->ZF_VDAV, 	PesqPict("SZF","ZF_VDAV") ) )	, Transform( nVlVec, 			PesqPict("SZF","ZF_VDAV") )		, "14 - Valor Debito Atual a Vencer"},;
						{"ZF_MDAV", iif( lNovo, "NOVO", Transform( SZF->ZF_MDAV, 	PesqPict("SZF","ZF_MDAV") ) )	, Transform( nPonMed, 			PesqPict("SZF","ZF_MDAV") )		, "15 - Media Ponderada de Titulos a Vencer"},;
						{"ZF_MPMV", iif( lNovo, "NOVO", Transform( SZF->ZF_MPMV, 	PesqPict("SZF","ZF_MPMV") ) )	, Transform( nAriMed, 			PesqPict("SZF","ZF_MPMV") )		, "16 - Prazo Medio de Vendas"},;
						{"ZF_DATV", iif( lNovo, "NOVO", Transform( SZF->ZF_DATV, 	PesqPict("SZF","ZF_DATV") ) )	, Transform( nVl5Dias, 			PesqPict("SZF","ZF_DATV") )		, "17 - Valor Debito Atual Vencido ha + 5 Dias"},;
						{"ZF_MPTV", iif( lNovo, "NOVO", Transform( SZF->ZF_MPTV, 	PesqPict("SZF","ZF_MPTV") ) )	, Transform( nMed5Dias, 		PesqPict("SZF","ZF_MPTV") )		, "18 - Media Ponderada Atraso Titulos Vencidos e Nao Pagos +5 Dias"},;
						{"ZF_V15D", iif( lNovo, "NOVO", Transform( SZF->ZF_V15D, 	PesqPict("SZF","ZF_V15D") ) )	, Transform( nVl15Dias, 		PesqPict("SZF","ZF_V15D") )		, "19 - Valor Debito Atual Vencido ha +15 Dias"},;
						{"ZF_M15D", iif( lNovo, "NOVO", Transform( SZF->ZF_M15D, 	PesqPict("SZF","ZF_M15D") ) )	, Transform( nMed15Dia, 		PesqPict("SZF","ZF_M15D") )		, "20 - Media Ponderada Atraso Titulos Vencidos e Nao Pagos +15 Dias"},;
						{"ZF_V30D", iif( lNovo, "NOVO", Transform( SZF->ZF_V30D, 	PesqPict("SZF","ZF_V30D") ) )	, Transform( nVl30Dias, 		PesqPict("SZF","ZF_V30D") )		, "21 - Valor Debito Atual Vencido ha +30 Dias"},;
						{"ZF_M30D", iif( lNovo, "NOVO", Transform( SZF->ZF_M30D, 	PesqPict("SZF","ZF_M30D") ) )	, Transform( nMed30Dia, 		PesqPict("SZF","ZF_M30D") )		, "22 - Media Ponderada Atraso Titulos Vencidos e Nao Pagos +30 Dias"},;
						{"ZF_DTPC", iif( lNovo, "NOVO", DtoC( SZF->ZF_DTPC ) )										, DtoC( dDtPenC	)												, "23 - Data da Penultima Compra"},;
						{"ZF_VPCO", iif( lNovo, "NOVO", Transform( SZF->ZF_VPCO,	PesqPict("SZF","ZF_VPCO") ) )	, Transform( nVlPenC,			PesqPict("SZF","ZF_VPCO") )		, "24 - Valor da Penultima Compra"}		}

		GrvLog( cLog, aInfReg )
	
	endif
	
	
	
//	if lGrava

		//Campos obrigatorios
		if 	empty(mv_par01) .or. empty(cRaizCNPJ) .or. empty(dDtAtual) .or. empty(dPriCom) .or. empty(dDtUltC) .or. nVlUltC=0 .or. empty(dDtAcum) .or. nVlAcum=0
		else
		
			SZF->( RecLock( "SZF", lNovo ) )
		
			if lNovo
				
				SZF->ZF_TIPO	:= "1"		//Iif ( CLI_QRY->A1_PESSOA == "J", "1", "2" )		// 01 - Identificação
				SZF->ZF_CASS	:= alltrim(mv_par01)//StrZero(mv_par01,4)		//alltrim(mv_par01)		// 02 - Codigo do Associado
				SZF->ZF_CCLI	:= cRaizCNPJ									// 03 - Numero de identificação do Cliente
				
			endif

			SZF->ZF_DDAT	:= dDtAtual						// 04 - Data da Informacao
			SZF->ZF_DCDD	:= dPriCom						// 05 - Data Cadastramento do Cliente
			SZF->ZF_DUCM	:= dDtUltC						// 06 - Data da Ultima Compra
			SZF->ZF_VULC	:= nVlUltC						// 07 - Valor da Ultima Compra
			
//			if 	(dDtAcum = SZF->ZF_DMAC .and. nVlAcum != SZF->ZF_VMAC) .or.;
//				(dDtAcum < SZF->ZF_DMAC .and. SZF->ZF_DMAC >= (dDtAtual - 365)) .or.;
//				(nVlAcum < SZF->ZF_VMAC .and. SZF->ZF_DMAC >= (dDtAtual - 365)) .or.;
//				(nVlAcum > SZF->ZF_VMAC .and. dDtAcum < SZF->ZF_DMAC)
//			else
				SZF->ZF_DMAC	:= dDtAcum						// 08 - Data do Maior Acumulo Pendente
				SZF->ZF_VMAC	:= nVlAcum						// 09 - Valor do Maior Acumulo Pendente
//			endif
			
			SZF->ZF_VSAT	:= nVlDebAtu					// 10 - Valor Debito Atual Total
			SZF->ZF_VLCR	:= nLC							// 11 - Valor do Limite de Credito
			SZF->ZF_QPAG	:= nMedPap						// 12 - Media Ponderada de Atraso nos Pagamentos
			SZF->ZF_QDAP	:= nMedAap						// 13 - Media Aritmetica dos Dias de Atraso de Pagamentos
			SZF->ZF_VDAV	:= nVlVec						// 14 - Valor Debito Atual a Vencer 
			SZF->ZF_MDAV	:= nPonMed						// 15 - Media Ponderada de Titulos a Vencer
			SZF->ZF_MPMV	:= nAriMed						// 16 - Prazo Médio de Vendas
			SZF->ZF_DATV	:= nVl5Dias						// 17 - Valor Debito Atual Vencido ha + 5 Dias
			SZF->ZF_MPTV	:= nMed5Dias					// 18 - Media Ponderada Atraso Títulos Vencidos e Não Pagos + 5 Dias
			SZF->ZF_V15D	:= nVl15Dias					// 19 - Valor Debito Atual Vencido ha +15 Dias
			SZF->ZF_M15D	:= nMed15Dia					// 20 - Media Ponderada Atraso Títulos Vencidos e Não Pagos +15 Dias
			SZF->ZF_V30D	:= nVl30Dias					// 21 - Valor Debito Atual Vencido ha +30 Dias
			SZF->ZF_M30D	:= nMed30Dia					// 22 - Média Ponderada Atraso Títulos Vencidos e Não Pagos +30 Dias
			SZF->ZF_DTPC	:= dDtPenC						// 23 - Data da Penúltima Compra
			SZF->ZF_VPCO	:= nVlPenC						// 24 - Valor da Penúltima Compra
			SZF->ZF_VSIT	:= "2"							// 25 - Situação do Cálculo Limite de Crédito
			SZF->ZF_TIPG	:= "0"							// 26 - Tipo de Garantia
			SZF->ZF_GGA		:= "00"							// 27 - Grau da Garantia
			SZF->ZF_DTG		:= CtoD("")						// 28 - Data de Validade da Garantia
			SZF->ZF_VLG		:= 0							// 29 - Valor da Garantia
			SZF->ZF_VPA		:= 0							// 30 - Valor da Venda ( Pagamento Antecipado )
			SZF->ZF_SVV		:= "  "							// 31 - Venda sem Credito
	
			SZF->( MsUnlock() )
			
			// Grava dados de Maior acumulo no cadastro do cliente SA1
			if SA1->(dbseek(xFilial("SA1") + cRaizCNPJ ))
				do while Left( SA1->A1_CGC, 8 ) = cRaizCNPJ
					if SA1->(Reclock("SA1",.F.))
						SA1->A1_X_VMACU := 	nVlAcum						// 09 - Valor do Maior Acumulo Pendente 
						SA1->A1_X_DMACU :=	dDtAcum						// 08 - Data do Maior Acumulo Pendente					
					endif
					SA1->(MsUnlock())
					SA1->( dbSkip() )
				enddo
			endif

		endif

	//else

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³ Processa o Proximo Registro                                                ³
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
//	CLI_QRY->( DbSkip() )

Enddo

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Fecha o Arquivo Temporario                                                 ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If Select("CLI_QRY") > 0
   DbSelectArea("CLI_QRY")
   DbCloseArea()
EndIf


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Gera o arquivo texto para integracao com a CISP                            ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
if GeraArq( Alltrim(mv_par02) + cArqCisp )

	MostraLog()
	MsgBox("O arquivo " + cArqCisp + " foi gerado com sucesso !","Informação","INFO")

endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ InfComp  º Autor ³ Cristiano Figueiroa º Data ³ 20/04/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao para Informacoes de Compra do Cliente                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasitech                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function InfComp( cCodCli )
Local cQuery	:= ""
Local nVlrUCom	:= 0
Local dDatUCom	:= Ctod("  /  /  ")
Local nVlrPCom	:= 0
Local dDatPCom	:= Ctod("  /  /  ")
Local aArea		:= GetArea()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Query para Selecao de Pessoas Juridicas                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT TOP 2 SUM( SF2.F2_VALFAT ) F2_VALFAT , SF2.F2_EMISSAO "
cQuery += "FROM " + RetSqlName("SF2") + " SF2 "
//cQuery += "WHERE SF2.F2_FILIAL + SF2.F2_CLIENTE + SF2.F2_LOJA IN (" + cCodCli + ") AND SF2.F2_DUPL <> '' AND "
cQuery += "WHERE SF2.F2_CLIENTE + SF2.F2_LOJA IN (" + cCodCli + ") AND SF2.F2_DUPL <> '' AND "
cQuery += "SF2.F2_TIPO = 'N' AND SF2.D_E_L_E_T_ = ' ' "
cQuery += "GROUP BY SF2.F2_EMISSAO "
cQuery += "ORDER BY SF2.F2_EMISSAO DESC"
cQuery :=  ChangeQuery( cQuery )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre o Resultado da Query no Alias QRY                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TcQuery cQuery New Alias "COM_QRY"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta os Campos Apos a Execucao da Query                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TcSetField( "COM_QRY" , "F2_EMISSAO"  , "D" , 08 , 0 )
TcSetField( "COM_QRY" , "F2_VALFAT"   , "N" , 13 , 2 )


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se Existem Compras para o Cliente                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !COM_QRY->( Eof() )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se as Informacoes de Ultima Compra ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dDatUCom := COM_QRY->F2_EMISSAO
	nVlrUCom := COM_QRY->F2_VALFAT
	
	COM_QRY->( dbSkip() )
   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se as Informacoes de Ultima Compra ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !COM_QRY->( Eof() )
		dDatPCom := COM_QRY->F2_EMISSAO
		nVlrPCom := COM_QRY->F2_VALFAT
	Endif   

Endif   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha os Arquivos Temporarios e Restaura as Areas Antes da Execucao da Rotina  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select("COM_QRY") > 0
   dbSelectArea("COM_QRY")
   dbCloseArea()
EndIf
RestArea(aArea)

Return( {dDatPCom, nVlrPCom, dDatUCom, nVlrUCom} )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VlDebAtu º Autor ³ Cristiano Figueiroa º Data ³ 20/04/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao para Retornar o Valor do Debito Atual Total          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasitech                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VlDebAtu( cCodCli )
Local nRet		:= 0
Local cQuery	:= ""
Local aArea		:= GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Soma os Titulos a Receber com Saldo em Aberto ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT SUM( E1_SALDO ) AS SOMA "
cQuery += "FROM " + RetSqlName("SE1") + " SE1 "
cQuery += "WHERE D_E_L_E_T_=' ' AND SE1.E1_CLIENTE + SE1.E1_LOJA IN (" + cCodCli + ") AND SE1.E1_TIPO  = 'NF' AND SE1.E1_ORIGEM = 'MATA460' AND SE1.E1_SALDO > 0"
cQuery :=  ChangeQuery( cQuery )

TcQuery cQuery New Alias "DEB_QRY"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Identifica a somatoria do debito atual do cliente.      ³
//³ Caso ele possua creditos (valores a receber) envio zero ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If DEB_QRY->( !eof() )
   nRet := iif( DEB_QRY->SOMA > 0, DEB_QRY->SOMA, 0 )
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha os Arquivos Temporarios e Restaura as Areas Antes da Execucao da Rotina ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select("DEB_QRY") > 0
   DbSelectArea("DEB_QRY")
   DbCloseArea()
EndIf
RestArea(aArea)

Return( nRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Vlatraso º Autor ³ Cristiano Figueiroa º Data ³ 20/04/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao para retornar a media ponderada e aritmetica de      º±±
±±º          ³ maior atraso no pagto                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasitech                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VlAtraso( cCodCli )

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                 Declara as Variaveis Utilizadas na Rotina                  ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
  
Local nVlFat	:= 0
Local nDiasDif	:= 0
Local nVlCalc	:= 0
Local nTotDias	:= 0
Local nQtdTit	:= 0
Local nMediaPon	:= 0
Local nMediaAri	:= 0
Local aDados	:= {}
Local cQuery    := ""
Local aArea     := GetArea()

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                Monta a Query para Calcular as Medias por Atraso            ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cQuery := "SELECT SE1.E1_VALOR , SE1.E1_SALDO , SE1.E1_BAIXA , SE1.E1_VENCREA "
cQuery += "FROM " + RetSqlName("SE1") + " SE1 "
cQuery += "WHERE SE1.E1_CLIENTE + SE1.E1_LOJA IN (" + cCodCli + ") AND "
cQuery += 		"SE1.E1_BAIXA > '"+ DtoS( dDtAtual - 366 ) + "' AND "
cQuery += 		"SE1.E1_VALOR <> SE1.E1_SALDO AND "
cQuery += 		"SE1.E1_TIPO  = 'NF' AND "
cQuery += 		"SE1.D_E_L_E_T_ = ' ' AND "
cQuery += 		"SE1.E1_ORIGEM = 'MATA460'"

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                Chama a Funcao que Readequa a Query                         ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cQuery :=  ChangeQuery( cQuery )

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                 Abre o Resultado da Query no Alias QRY                     ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
// MsAguarde({|| DbUseArea( .T. , "TOPCONN" , TCGenQry(,,cQuery), "ATR_QRY" , .F., .T.) } ,"Selecionando Registros da Tabela " + "ATR_QRY")
DbUseArea( .T. , "TOPCONN" , TCGenQry(,,cQuery), "ATR_QRY" , .F., .T.)

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                Ajusta os Campos Apos a Execucao da Query                   ³   
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

TcSetField( "ATR_QRY" , "E1_VALOR"   , "N" , 13 , 2 )
TcSetField( "ATR_QRY" , "E1_SALDO"   , "N" , 13 , 2 )
TcSetField( "ATR_QRY" , "E1_BAIXA"   , "D" , 08 , 0 )
TcSetField( "ATR_QRY" , "E1_VENCREA" , "D" , 08 , 0 )

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                 Abre o Resultado da Query no Alias QRY                     ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

DbSelectArea("ATR_QRY")
DbGotop()

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³            Processa o Contas a Receber Conforme Selecao                    ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Do While ATR_QRY->( !Eof() )

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³            Posiciona no Registro Selecionado no SE1 Total                  ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
  
   nVlFat   := nVlFat + ( ATR_QRY->E1_VALOR - ATR_QRY->E1_SALDO )	                // Valor Pago dos Titulos em atraso
   nDiasDif := ATR_QRY->E1_BAIXA - ATR_QRY->E1_VENCREA		                        // Qtd de Dias de Atraso

   // Quando Paga Adiantado o Atraso nao eh Negativo. Eh Zero
   If nDiasDif < 0
      nDiasDif := 0
   Endif
  
   nTotDias	:= nTotDias + nDiasDif                                                  // Qtd Total de Dias de Atraso 
   nVlCalc	:= nVlCalc + ( ( ATR_QRY->E1_VALOR - ATR_QRY->E1_SALDO ) * nDiasDif )	// Valor Total Calculado
   nQtdTit	:= nQtdTit + 1

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³  Retorna o Ponteiro do Registro para a Query e Processa o Proximo Registro ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

   DbSkip() 
   Loop
   
Enddo

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³        Calcula a Media Ponderada = Valor Calculado / Valor Faturado        ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

nMediaPon := nVlCalc / nVlFat

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³  Tratamento para Quando as Medias forem Maior que Zero e Menores que 0.01  ³
  ³  Informar 0.01                                                             ³  
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
         
If nMediaPon > 0 .And. nMediaPon < 0.01 
   nMediaPon := 0.01
Else
   nMediaPon := Round ( nMediaPon , 2 )
Endif

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                       Calcula a Media Aritmetica                           ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

nMediaAri := nTotDias / nQtdTit

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³  Tratamento para Quando as Medias forem Maior que Zero e Menores que 0.01  ³
  ³  Informar 0.01                                                             ³  
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
         
If nMediaAri > 0 .And. nMediaAri < 0.01 
   nMediaAri := 0.01
Else
   nMediaAri := Round ( nMediaAri , 2 )
Endif

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³    Como nao existem Valores Negativos no Arquivo , Zera quando ocorrer     ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

If nMediaPon < 0 .Or. nMediaAri < 0
   nMediaPon := 0
   nMediaAri := 0
Endif   

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                    Adiciona as Informacoes no Array                        ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Aadd( aDados , { nMediaPon , nMediaAri } )

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Fecha os Arquivos Temporarios e Restaura as Areas Antes da Execucao da Rotina  ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

If Select("ATR_QRY") > 0
   DbSelectArea("ATR_QRY")
   DbCloseArea()
EndIf

RestArea(aArea)

Return(aDados)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CalcVenc º Autor ³ Cristiano Figueiroa º Data ³ 20/04/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Funcao para Retornar o Valor e a Media Ponderada Atual       º±±
±±º          ³Vencido ha + 5 , 15 ou 30 Dias                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasitech                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CalcVenc( cCodCli )
Local nVl05	   := 0
Local nTit05   := 0
Local nTVl05   := 0
Local nMed05   := 0
Local nVl15	   := 0
Local nTit15   := 0
Local nTVl15   := 0
Local nMed15   := 0
Local nVl30    := 0
Local nTit30   := 0
Local nTVl30   := 0
Local nMed30   := 0
Local aDados   := {}
Local cQuery   := ""
Local nDiasDif := 0
Local aArea    := GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa a query ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT SE1.E1_VENCREA , SE1.E1_SALDO "
cQuery += "FROM " + RetSqlName("SE1") + " SE1 "
cQuery += "WHERE SE1.E1_CLIENTE + SE1.E1_LOJA IN (" + cCodCli + ") AND "
cQuery += 		"SE1.E1_TIPO = 'NF' AND SE1.E1_SALDO > 0 AND SE1.E1_VENCREA < '" + DtoS( dDtAtual ) + "' AND SE1.D_E_L_E_T_ = ' ' AND SE1.E1_ORIGEM = 'MATA460'"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama a funcao que readequa a query ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery :=  ChangeQuery( cQuery )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre o resultado da query no alias QRY ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// MsAguarde({|| DbUseArea( .T. , "TOPCONN" , TCGenQry(,,cQuery), "VEN_QRY" , .F., .T.) } ,"Selecionando Titulos Vencidos " )
dbUseArea( .T. , "TOPCONN" , TCGenQry(,,cQuery), "VEN_QRY" , .F., .T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta os dampos apos a execucao da query ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TcSetField( "VEN_QRY" , "E1_SALDO"   , "N" , 13 , 2 )
TcSetField( "VEN_QRY" , "E1_VENCREA" , "D" , 08 , 0 )

DbSelectArea("VEN_QRY")
DbGotop()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa os titulos vencidos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
do while VEN_QRY->( !Eof() )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula dias em atraso ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nDiasDif := dDtAtual - VEN_QRY->E1_VENCREA

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Titulos com mais de 5 dias em atraso ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if nDiasDif >= 5
		nVl05	+= VEN_QRY->E1_SALDO
		nTit05 ++
		nTVl05	+= ( VEN_QRY->E1_SALDO * nDiasDif )
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Titulos com mais de 15 dias em atraso ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if nDiasDif >= 15
		nVl15	+= VEN_QRY->E1_SALDO
		nTit15 ++
		nTVl15	+= ( VEN_QRY->E1_SALDO * nDiasDif )
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Titulos com mais de 30 dias em atraso ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if nDiasDif >= 30
		nVl30	+= VEN_QRY->E1_SALDO
		nTit30 ++
		nTVl30	+= ( VEN_QRY->E1_SALDO * nDiasDif )
	endif

	dbSkip()

enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula as medias ponderadas para atrasos superiores a 5,15,30 dias ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nMed05 := (nTVl05 / nVl05)
nMed15 := (nTVl15 / nVl15)
nMed30 := (nTVl30 / nVl30)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona os valores no array ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd( aDados , { nVl05 , nMed05 , nVl15 , nMed15 , nVl30 , nMed30 } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha area temporaria ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if Select("VEN_QRY") > 0
	dbSelectArea("VEN_QRY")
	VEN_QRY->( DbCloseArea() )
endif

RestArea(aArea)

Return(aDados)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VlMedVen º Autor ³ Cristiano Figueiroa º Data ³ 23/04/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao para retornar a media ponderada de titulos a vencer  º±±
±±º          ³ e prazo medio de Vendas.                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasitech                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VlMedVen( cCodCli )
Local nVlFat	:= 0
Local nDiasDif	:= 0
Local nVlCalc	:= 0
Local nMediaPon	:= 0
Local nMediaAri	:= 0
Local nTotDias	:= 0
Local nQtdTit	:= 0
Local cQuery 	:= ""
Local aDados	:= {}
Local aArea		:= GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta query  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT SE1.E1_SALDO , SE1.E1_EMISSAO , SE1.E1_VENCREA "
cQuery += "FROM " + RetSqlName("SE1") + " SE1 "
cQuery += "WHERE SE1.E1_CLIENTE + SE1.E1_LOJA IN (" + cCodCli + ") AND "
cQuery += 		"SE1.E1_VENCREA > '" + DtoS( dDtAtual + 1 ) + "' AND "
cQuery += 		"SE1.E1_SALDO <> 0 AND "
cQuery += 		"SE1.E1_TIPO = 'NF' AND "
cQuery += 		"SE1.D_E_L_E_T_ = '' AND "
cQuery += 		"SE1.E1_ORIGEM = 'MATA460' "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta query ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery :=  ChangeQuery( cQuery )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre o resultado da query ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// MsAguarde( {|| DbUseArea( .T. , "TOPCONN", TCGenQry(,,cQuery) , "MED_QRY" , .F. , .T. ) } , "Calculando Titulos a Vencer e Prazo Medio de Vendas " )
DbUseArea( .T. , "TOPCONN", TCGenQry(,,cQuery) , "MED_QRY" , .F. , .T. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta campos da query ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TcSetField( "MED_QRY" , "E1_SALDO"   , "N" , 13 , 2 )
TcSetField( "MED_QRY" , "E1_EMISSAO" , "D" , 08 , 0 )
TcSetField( "MED_QRY" , "E1_VENCREA" , "D" , 08 , 0 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa titulos selecionados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("MED_QRY")
DbGotop()
Do While MED_QRY->( !Eof() )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alimenta as variaveis ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVlFat		+= MED_QRY->E1_SALDO
	nDiasDif	:= MED_QRY->E1_VENCREA - MED_QRY->E1_EMISSAO
	nTotDias	+= nDiasDif
	nVlCalc		+= (MED_QRY->E1_SALDO * nDiasDif)
	nQtdTit++

	dbSkip()

Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula media ponderada = valor calculado / valor faturado ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nMediaPon := Round( nVlCalc / nVlFat , 2 ) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula media aritmetica ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nMediaAri := Round( nTotDias / nQtdTit , 2 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona os valores no array ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aDados , { nVlFat , nMediaPon , nMediaAri })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha area temporaria ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if Select("MED_QRY") > 0
   dbSelectArea("MED_QRY")
   dbCloseArea()
endif

RestArea(aArea)

Return(aDados)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MaiorAcu º Autor ³ Cristiano Figueiroa º Data ³ 23/04/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao para retornar a data e valor de maior acumulo        º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasitech                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MaiorAcu( cCodCli ) 
Local aArea		:= GetArea()
Local dMAcum	:= Ctod("")
Local dMAcumAno	:= Ctod("")
Local nMAcum	:= 0
Local nMAcumAno	:= 0
Local nSoma		:= 0
Local aRet		:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define query para pesquisa do maior acumulo ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT E1_EMISSAO DATAACUM, SUM(E1_VALOR) AS VALOACUM, '0' AS ORDEM "
cQuery += "FROM " + RetSqlName("SE1") + " SE1 "
cQuery += "WHERE D_E_L_E_T_=' ' AND SE1.E1_CLIENTE + SE1.E1_LOJA IN (" + cCodCli + ") AND SE1.E1_TIPO  = 'NF' AND SE1.E1_ORIGEM = 'MATA460' "
cQuery += "GROUP BY E1_EMISSAO "

cQuery += "UNION "

cQuery += "SELECT E1_BAIXA DATAACUM, SUM((E1_VALOR - E1_SALDO) * -1) AS VALOACUM, '1' AS ORDEM "
cQuery += "FROM " + RetSqlName("SE1") + " SE1 "
cQuery += "WHERE D_E_L_E_T_=' ' AND SE1.E1_CLIENTE + SE1.E1_LOJA IN (" + cCodCli + ") AND SE1.E1_TIPO  = 'NF' AND SE1.E1_ORIGEM = 'MATA460' "
cQuery += "GROUP BY E1_BAIXA "

cQuery += "ORDER BY DATAACUM, ORDEM"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Readequa a query com a funcao changequery ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery :=  ChangeQuery( cQuery )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera a view ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"MAC_QRY", .F., .T.)
TcSetField("MAC_QRY", "DATAACUM", "D", 08, 0)
TcSetField("MAC_QRY", "VALOACUM", "N", 13, 2)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa o resultado selecionado ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("MAC_QRY")
dbGotop()
do while MAC_QRY->( !eof() )

	nSoma += MAC_QRY->VALOACUM

	if nSoma > nMAcum
		nMAcum	:= nSoma
		dMAcum	:= MAC_QRY->DATAACUM
	endif
	
	if nSoma > nMAcumAno .and. MAC_QRY->DATAACUM >= dDtAtual - 365
		nMAcumAno	:= nSoma
		dMAcumAno	:= MAC_QRY->DATAACUM
	endif

	dbSkip()

enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define retorno ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if dMAcum >= dDtAtual - 365
	aAdd(aRet, {dMAcum, nMAcum})
else
	aAdd(aRet, {dMAcumAno, nMAcumAno})
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha tabela temporaria e restaura area ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if Select("MAC_QRY") > 0
   dbSelectArea("MAC_QRY")
   dbCloseArea()
EndIf
RestArea(aArea)

Return(aRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³  EmpGrp  º Autor ³ Cristiano Figueiroa º Data ³  25/05/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Lista em um Array as Empresas do Grupo Brasitech            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasitech                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function EmpGrp()

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Declaracao de Variaveis Utilizadas na Rotina                        ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Local aAmbAtu	:= GetArea()
Local aAmbEmp	:= SM0->(GetArea())
Local cString	:= ""

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                  Abre o Cadastro de Empresas - SM0                  ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

DbSelectArea("SM0")
DbSetOrder(1)       //  M0_CODIGO + M0_FILIAL       
DbGoTop()

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Processa todas as Empresas existentes no cadastro de empresas       ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Do While SM0->( !Eof() )

 /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³               Adiciona no Array a Empresa do Grupo                  ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	if !Empty( Left( SM0->M0_CGC, 8 ) ) .and. !Left( SM0->M0_CGC, 8 ) $ cString
		cString += "'" + Left( SM0->M0_CGC, 8 ) + "',"
	endif
	
 /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³                  Proxima empresa cadastrada                         ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
   DbSkip()

Enddo

cString := Left( cString, Len(cString) - 1 )

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                  Restaura os Ambientes Anteriores                   ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
RestArea( aAmbEmp )
RestArea( aAmbAtu )

Return( cString )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ GISX1          ³ Por: Adalberto Moreno Batista     ³ Data ³20.05.2010³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function GISX1( aRegs, aCampo )
Local aArea := GetArea()
Local nI, nJ

dbSelectArea("SX1")
dbSetOrder(1)

For nI := 1 to Len( aRegs )
    If !dbSeek( aRegs[nI,1] + aRegs[nI,2] )
		RecLock( "SX1", .T. )
		For nJ := 1 to Len( aCampo )
	    	FieldPut( FieldPos( aCampo[nJ] ), aRegs[nI,nJ] )
		Next
		MsUnlock()
    Endif
Next

RestArea( aArea )
Return()



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ GeraArq        ³ Por: Adalberto Moreno Batista     ³ Data ³20.10.2010³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GeraArq( cArqTxt )
Local cQuery, nHdl, cLin
Local cEol		:= Chr(13) + Chr(10)
Local lRet		:= .T.

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Selecionando os registros na tabela SZF - informacoes CISP  ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Incproc("Selecionando os registros...")

cQuery := "SELECT SZF.* "
cQuery += "FROM "+RetSQLName("SZF")+" SZF "
cQuery += "WHERE SZF.ZF_FILIAL = '"+xFilial("SZF")+"' and "
cQuery +=       "(SZF.ZF_VSAT > 0 or SZF.ZF_DUCM >= '" + dTOs(dDtAtual - 365) + "') and "
cQuery +=       "SZF.ZF_CASS != ' ' and "
cQuery +=       "SZF.ZF_CCLI != ' ' and "
cQuery +=       "SZF.ZF_DCDD != ' ' and "
cQuery +=       "SZF.ZF_DUCM != ' ' and "
cQuery +=       "SZF.ZF_VULC > 0 and "
cQuery +=       "SZF.ZF_DMAC != ' ' and "
cQuery +=       "SZF.ZF_VMAC > 0 and "
cQuery +=       "SZF.D_E_L_E_T_ = '' "
cQuery += "ORDER BY ZF_CCLI"

if Select("TRABx") > 0
	dbSelectArea("TRABx")
	dbCloseArea()
endif

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Criando a tabela temporaria da consulta      ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRABx", .F., .T.)

dbSelectArea("TRABx")
dbGoTop()

if eof()

	lRet := .F.

else

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³ Criando o arquivo texto                      ³
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	nHdl    := fCreate( cArqTxt )
	If nHdl == -1
		MsgBox( "O arquivo "+cArqTxt+" nao pode ser criado e o processo sera interrompido.", "Atenção", "ERRO" )
	    Return(.F.)
	Endif
	
	do while !eof()
	
		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    	  ³ Monta a linha a ser gravada no arquivo texto                     ³
    	  ³ Ajuste solicitado por Luiz em 25/04/11							 ³
	      ³ 	substitui a 4 linha de:                                      ³
	      ³ 	  iif( Empty( TRABx->ZF_DDAT ), "00000000", TRABx->ZF_DDAT ) ³
	      ³ 	para: 														 ³
	      ³ 	  dTOs(dDtAtual) 											 ³
	      ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		cLin	:= ""
		cLin    += TRABx->ZF_TIPO 													// de 001 a 001 - tam 1
		cLin    += TRABx->ZF_CASS 													// de 002 a 005 - tam 4
		cLin    += StrZero( Val( TRABx->ZF_CCLI) , 20) 			 				// de 006 a 025 - tam 20
		cLin    += dTOs(dDtAtual) 													// de 026 a 033 - tam 8
		cLin    += iif( Empty( TRABx->ZF_DCDD ), "00000000", TRABx->ZF_DCDD ) 		// de 034 a 041 - tam 8
		cLin    += iif( Empty( TRABx->ZF_DUCM ), "00000000", TRABx->ZF_DUCM ) 		// de 042 a 049 - tam 8
		cLin    += StrZero( TRABx->ZF_VULC * 100, 15 ) 							// de 050 a 064 - tam 15
		cLin    += iif( Empty( TRABx->ZF_DMAC ), "00000000", TRABx->ZF_DMAC ) 		// de 065 a 072 - tam 8  - Data  do Maior Acumulo
		cLin    += StrZero( TRABx->ZF_VMAC * 100, 15 ) 							// de 073 a 087 - tam 15 - Valor Maior Acumulo
		cLin    += StrZero( TRABx->ZF_VSAT * 100, 15 ) 							// de 088 a 102 - tam 15 - Valor Debito Atual Total
		cLin    += StrZero( TRABx->ZF_VLCR * 100, 15 ) 							// de 103 a 117 - tam 15
		cLin    += StrZero( TRABx->ZF_QPAG * 100, 6 ) 								// de 118 a 123 - tam 6
		cLin    += StrZero( TRABx->ZF_QDAP * 100, 6 ) 								// de 124 a 129 - tam 6
		cLin    += StrZero( TRABx->ZF_VDAV * 100, 15 ) 							// de 130 a 144 - tam 15
		cLin    += StrZero( TRABx->ZF_MDAV * 100, 6 ) 								// de 145 a 150 - tam 6
		cLin    += StrZero( TRABx->ZF_MPMV * 100, 6 ) 								// de 151 a 156 - tam 6
		cLin    += StrZero( TRABx->ZF_DATV * 100, 15 ) 							// de 157 a 171 - tam 15
		cLin    += StrZero( TRABx->ZF_MPTV, 4 ) 									// de 172 a 175 - tam 4
		cLin    += StrZero( TRABx->ZF_V15D * 100, 15 ) 							// de 176 a 190 - tam 15
		cLin    += StrZero( TRABx->ZF_M15D, 4 ) 									// de 191 a 194 - tam 4
		cLin    += StrZero( TRABx->ZF_V30D * 100, 15 ) 							// de 195 a 209 - tam 15
		cLin    += StrZero( TRABx->ZF_M30D, 4 ) 									// de 210 a 213 - tam 4
		cLin    += iif( Empty( TRABx->ZF_DTPC ), "00000000", TRABx->ZF_DTPC ) 		// de 214 a 221 - tam 8
		cLin    += StrZero( TRABx->ZF_VPCO * 100, 15 ) 						  	// de 222 a 236 - tam 15
		cLin    += TRABx->ZF_VSIT 													// de 237 a 237 - tam 1
		cLin    += TRABx->ZF_TIPG 													// de 238 a 238 - tam 1
		cLin    += TRABx->ZF_GGA 													// de 239 a 240 - tam 2
		cLin    += iif( Empty( TRABx->ZF_DTG ), "00000000", TRABx->ZF_DTG ) 		// de 241 a 248 - tam 8
		cLin    += StrZero( TRABx->ZF_VLG * 100, 15 ) 								// de 249 a 263 - tam 15
		cLin    += StrZero( TRABx->ZF_VPA * 100, 15 ) 								// de 264 a 278 - tam 15
		cLin    += TRABx->ZF_SVV 													// de 279 a 280 - tam 2
		cLin    += cEol

	    /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	      ³ Gravacao no arquivo texto. Testa por erros durante a gravacao da ³
	      ³ linha montada.                                                   ³
	      ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	    If fWrite( nHdl, cLin, Len(cLin) ) != Len( cLin )
	    	MsgBox( "O arquivo "+cArqTxt+" nao pode ser criado e o processo sera interrompido.", "Atenção", "ERRO" )
	    	Return(.F.)
	    Endif
			    
		dbSkip()

	enddo

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   	  ³ Fecha o arquivo texto                                            ³
      ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	fClose( nHdl )

endif

if Select("TRABx") > 0
	dbSelectArea("TRABx")
	dbCloseArea()
endif

dbSelectArea("SZF")

Return( lRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ CriaLog        ³ Por: Adalberto Moreno Batista     ³ Data ³20.10.2010³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CriaLog()
Local _aStru
Local aArea := GetArea()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Criacao da estrutura temporaria para LOG de operacoes        |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if Select( "TLOG" ) > 0
	dbSelectArea( "TLOG" )
	dbCloseArea()
endif
_aStru := { { "LINHA"  , "C", 120, 0 } }
_cTLOG := CriaTrab( _aStru, .T. )
dbUseArea( .T. , , _cTLOG, "TLOG" , .T. )
RestArea( aArea )

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ GrvLog             ³ Por: Adalberto Moreno Batista ³ Data ³20.10.2010³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GrvLog( cLog, aInfReg )
Local nK
Local nLimite	:= Len( TLOG->LINHA )							//identificando o tamanho maximo da linha
Local nTamLin	:= iif( Len( cLog ) = 0, 1, Len( cLog ) )		//identificando o tamanho do texto do log (minimo 1)
Local nMax		:= Int( Len( cLog ) / nLimite ) + 1			//identificando o numero maximo de linhas (minimo 1)
Local nPos		:= 0

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Gravando informacoes do registro                                 ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
for nK := 1 to Len( aInfReg )

	TLOG->( RecLock( "TLOG", .T. ) )
	TLOG->LINHA		:= PadR( aInfReg[nK,1], 11 ) + PadR( aInfReg[nK,2], 21 ) + PadR( aInfReg[nK,3], 21 ) + PadR( aInfReg[nK,4], 60 )
	TLOG->( MsUnlock() )
	
next

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Gravando log de inconsistencias                                  ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
For nK := 1 to MlCount(cLog, nLimite )

	TLOG->( RecLock( "TLOG", .T. ) )
	TLOG->LINHA		:= MemoLine( cLog, nLimite, nK )
	TLOG->( MsUnlock() )

Next

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Gravando uma linha em branco para separacao                      ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
TLOG->( RecLock( "TLOG", .T. ) )
TLOG->LINHA		:= ""
TLOG->( MsUnlock() )

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ MostraLog      ³ Por: Adalberto Moreno Batista     ³ Data ³20.10.2010³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MostraLog()
Local cNome, cPath, lResultado, cMensagem, lEnviado, cErro
Local cServer	:= AllTrim( GetMV('MV_RELSERV') )
Local cAccount	:= AllTrim( GetMv('MV_RELACNT') )
Local cPassword	:= AllTrim( GetMV('MV_RELPSW') )
Local lRelAuth	:= GetMV("MV_RELAUTH",.F.,.F.)
Local cRelaUsr	:= AllTrim( GetMV("MV_RELAUSR",.F.,"") )
Local cRecebe	:= AllTrim( GetMV('BR_EMLCISP',.F.,"cassio.olimpio@gamaitaly.com.br") )
Local cAssunto	:= "Brasitech - Inconsistências apuradas durante processamento arquivo CISP"

Local cEol		:= Chr(13) + Chr(10)

dbSelectArea("TLOG")
dbGoTop()

if !eof()
	
	cNome	:= "LOG_"+StrTran(dtos(dDataBase)+"_"+time()+".LOG",":","")
	cPath := "C:\TEMP\"+cNome
	MakeDir("C:\TEMP")
	Copy to &cPath SDF
	
	//	if MsgBox("Deseja ler o log ("+cPath+") de ocorrências do processamento?","Informação","YESNO")
	//		if file("C:\WINDOWS\NOTEPAD.EXE")
	//			WinExec("C:\WINDOWS\NOTEPAD.EXE "+cPath,3)
	//		else
	//			WinExec("C:\WINNT\NOTEPAD.EXE "+cPath,3)
	//		endif
	//	endif

	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResultado
	
	if lRelAuth
 
 		MailAuth( cRelaUsr, cPassword )
	
	endif
	
	if lResultado
	
		//email no formato html
		cMensagem := '<html>' + cEol
		cMensagem += '<font size="2" face="Arial">Informações de inconsistência no processamento de informações para a CISP.' + cEol + 'Para detalhes dos problemas apresentados, abra o arquivo anexo.</font>' + cEol + cEol + cEol
		cMensagem += '<font size="1" face="Calibri">E-mail automático enviado pelo sistema Microsiga Protheus (rotina expcisp2). Favor não respondê-lo.</font>' + cEol	
		cMensagem += '</body>' + cEol
		cMensagem += '</html>' + cEol
				
		SEND MAIL FROM cAccount TO cRecebe SUBJECT cAssunto BODY cMensagem ATTACHMENT cPath RESULT lEnviado
		
		GET MAIL ERROR cErro
		ConOut("Falha no envio do e-mail. Verifique se o e-mail destino é valido ou se o tempo de resposta do servidor e e-mails foi superior ao configurado no parametro MV_RELTIME " + cErro)
	
	else

		ConOut("Nao foi possivel conectar o servidor de e-mails. Verifique se o tempo de resposta do servidor e e-mails foi superior ao configurado no parametro MV_RELTIME")
	
	endif
	
	DISCONNECT SMTP SERVER RESULT lResultado
	
endif

dbCloseArea()
fErase(_cTLOG)

dbSelectArea("SZF")
Return()


/*
cQuery := "SELECT E1_EMISSAO DATAACUM, "
cQuery += 		"SUM( CASE E1_TIPO "
cQuery += 				"WHEN 'RA ' THEN E1_VALOR * (-1) "
cQuery += 				"WHEN 'PR ' THEN 0 "				//Desconsidera titulos provisorios
cQuery += 				"WHEN 'NCC' THEN E1_VALOR * (-1) "
cQuery +=	 			"WHEN 'AB-' THEN E1_VALOR * (-1) "
cQuery += 				"WHEN 'FB-' THEN E1_VALOR * (-1) "
cQuery += 				"WHEN 'FC-' THEN E1_VALOR * (-1) "
cQuery += 				"WHEN 'IR-' THEN E1_VALOR * (-1) "
cQuery +=	 			"WHEN 'IN-' THEN E1_VALOR * (-1) "
cQuery += 				"WHEN 'IS-' THEN E1_VALOR * (-1) "
cQuery += 				"WHEN 'PI-' THEN E1_VALOR * (-1) "
cQuery += 				"WHEN 'CF-' THEN E1_VALOR * (-1) "
cQuery +=	 			"WHEN 'CS-' THEN E1_VALOR * (-1) "
cQuery += 				"WHEN 'FU-' THEN E1_VALOR * (-1) "
cQuery += 				"WHEN 'FE-' THEN E1_VALOR * (-1) "
cQuery += 			"ELSE "
cQuery += 				"E1_VALOR "
cQuery +=			"END ) "
cQuery += 			"AS VALOACUM "
cQuery += "FROM " + RetSqlName("SE1") + " SE1 "
cQuery += "WHERE D_E_L_E_T_=' ' AND SE1.E1_FILIAL + SE1.E1_CLIENTE + SE1.E1_LOJA IN (" + cCodCli + ") AND SE1.E1_SALDO > 0 "
cQuery += "GROUP BY E1_EMISSAO "





Static Function InfComp( cCodCli )
cQuery := "Select Top 2 Sum( SF2.F2_VALFAT ) F2_VALFAT , SF2.F2_EMISSAO "
cQuery += "From " + RetSqlName("SF2") + " SF2 "
cQuery += "Where SF2.F2_CLIENTE = '" + cCodCli + "' And SF2.F2_DUPL <> '' And SF2.F2_TIPO = 'N' And SF2.D_E_L_E_T_ = '' "
cQuery += "Group By SF2.F2_EMISSAO "
cQuery += "Order By SF2.F2_EMISSAO DESC"


Static Function VlDebAtu( cCodCli )
cQuery := "SELECT SUM(SE1.E1_SALDO) SOMA "
cQuery += "FROM "+ RetSqlName("SE1") + " SE1 "
cQuery += "WHERE SE1.E1_FILIAL + SE1.E1_CLIENTE + SE1.E1_LOJA IN (" + cCodCli + ") AND SE1.E1_TIPO = 'NF' AND SE1.E1_ORIGEM = 'MATA460' AND SE1.E1_SALDO > 0 AND SE1.D_E_L_E_T_ = ' ' "


Static Function VlDebAtu( cCodCli )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Soma os Titulos a Receber com Saldo em Aberto ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT SUM(SE1.E1_SALDO) SOMA "
cQuery += "FROM "+ RetSqlName("SE1") + " SE1 "
cQuery += "WHERE SE1.E1_FILIAL + SE1.E1_CLIENTE + SE1.E1_LOJA IN (" + cCodCli + ") AND SE1.E1_TIPO = 'NF' AND SE1.E1_ORIGEM = 'MATA460' AND SE1.E1_SALDO > 0 AND SE1.D_E_L_E_T_ = ' ' "


Static Function VlAtraso( cCodCli )
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³                Monta a Query para Calcular as Medias por Atraso            ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "Select SE1.E1_VALOR , SE1.E1_SALDO , SE1.E1_BAIXA , SE1.E1_VENCREA "
cQuery += "From " + RetSqlName("SE1") + " SE1 "
cQuery += "Where SE1.E1_CLIENTE = '" + cCodCli + "' "
cQuery += 		"And SE1.E1_BAIXA > '"+ DtoS( dDtAtual - 366 ) + "' "
cQuery += 		"And SE1.E1_VALOR <> SE1.E1_SALDO "
cQuery += 		"And SE1.E1_TIPO  = 'NF' "
cQuery += 		"And SE1.D_E_L_E_T_ <> '*' "
cQuery += 		"And SE1.E1_ORIGEM = 'MATA460'"



Static Function CalcVenc( cCodCli )
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³                 Executa a Query conforme as Regras                         ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT SE1.E1_VENCREA , SE1.E1_SALDO "
cQuery += "From " + RetSqlName("SE1") + " SE1 "
cQuery += "Where SE1.E1_CLIENTE = '" + cCodCli + "' "
cQuery += 		"And SE1.E1_TIPO = 'NF' "
cQuery += 		"And SE1.E1_SALDO > 0 "
cQuery += 		"And SE1.E1_VENCREA < '" + DtoS( dDtAtual ) + "' "
cQuery += 		"And SE1.D_E_L_E_T_ <> '*' "
cQuery += 		"And SE1.E1_ORIGEM = 'MATA460'"



Static Function VlMedVen( cCodCli )
cQuery := "Select SE1.E1_SALDO , SE1.E1_EMISSAO , SE1.E1_VENCREA "
cQuery += "From " + RetSqlName("SE1") + " SE1 "
cQuery += "Where SE1.E1_CLIENTE = '" + cCodCli + "' "
cQuery += 		"And SE1.E1_VENCREA > '" + DtoS( dDtAtual + 1 ) + "' "
cQuery += 		"And SE1.E1_SALDO <> 0 "
cQuery += 		"And SE1.E1_TIPO = 'NF' "
cQuery += 		"And SE1.D_E_L_E_T_ <> '*' "
cQuery += 		"And SE1.E1_ORIGEM = 'MATA460'"
                                               

Static Function MaiorAcu( cCodCli ) 
cQuery := "SELECT DISTINCT SF2.F2_DOC NF , '' PARC , SF2.F2_EMISSAO DATAACUM , 'NF' TIPO , SF2.F2_VALFAT VALOACUM "
cQuery += "FROM " + RetSqlName("SF2") + " SF2 , " + RetSqlName("SE1") + " SE1 "
cQuery += "WHERE SF2.F2_FILIAL + SF2.F2_CLIENTE + SF2.F2_LOJA IN (" + cCodCli + ") AND "
cQuery += 		"SF2.D_E_L_E_T_ = ' ' AND "
cQuery += 		"SE1.D_E_L_E_T_ = ' ' AND "
cQuery += 		"SF2.F2_TIPO = 'N' AND "
cQuery += 		"SF2.F2_FILIAL = SE1.E1_FILIAL AND "
cQuery += 		"SF2.F2_PREFIXO = SE1.E1_PREFIXO AND "
cQuery += 		"SF2.F2_DOC = SE1.E1_NUM AND "
cQuery += 		"SF2.F2_CLIENTE = SE1.E1_CLIENTE AND "
cQuery += 		"SF2.F2_LOJA = SE1.E1_LOJA AND "
cQuery += 		"SF2.F2_DUPL <> ' ' "

cQuery += "UNION "

cQuery += "SELECT SE1.E1_NUM NF , SE1.E1_PARCELA PARC  , SE1.E1_BAIXA DATAACUM , SE1.E1_TIPO  TIPO, "
cQuery += 		 "VALOACUM = Case When SE1.E1_TIPO In ( '' , 'NDC' ) Then ( SE1.E1_VALLIQ - SE1.E1_JUROS - SE1.E1_MULTA + SE1.E1_DESCONT ) Else ( SE1.E1_VALLIQ - SE1.E1_JUROS - SE1.E1_MULTA + SE1.E1_DESCONT ) * -1 End "
cQuery += "FROM " + RetSqlName("SF2") + " SF2 , " + RetSqlName("SE1") + " SE1, " + RetSqlName("SA1") + " SA1 "
cQuery += "WHERE SF2.F2_FILIAL + SF2.F2_CLIENTE + SF2.F2_LOJA IN (" + cCodCli + ") AND "
cQuery += 		"SF2.D_E_L_E_T_ = ' ' AND "
cQuery += 		"SE1.D_E_L_E_T_ = ' ' AND "
cQuery += 		"SF2.F2_TIPO = 'N' AND "
cQuery += 		"SF2.F2_FILIAL = SE1.E1_FILIAL AND "
cQuery += 		"SF2.F2_PREFIXO = SE1.E1_PREFIXO AND "
cQuery += 		"SF2.F2_DOC = SE1.E1_NUM AND "
cQuery += 		"SF2.F2_CLIENTE = SE1.E1_CLIENTE AND "
cQuery += 		"SF2.F2_LOJA = SE1.E1_LOJA AND "
cQuery += 		"SF2.F2_DUPL <> ' ' "
cQuery += 		"ORDER BY DATAACUM ASC, VALOACUM DESC"
*/