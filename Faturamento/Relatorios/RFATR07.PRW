#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa    ³ RFATR07  ³ Rotina padrão para impressão da nota fiscal de entrada/saída º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Autor       ³ 10.07.07 ³ Hoeste Morelandes                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Produção    ³          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros  ³ ExpC1 = Numero da Nota Fiscal Inicial                                   º±±
±±º             ³ ExpC2 = Numero da Nota Fiscal Final                                     º±±
±±º             ³ ExpC3 = Serie da Nota Fiscal                                            º±±
±±º             ³ ExpC4 = Tipo da Nota Fiscal                                             º±±
±±º             ³ ExpL1 = Imprime Boleto                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno     ³ Nil                                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Observações ³ Deve ser definido os parâmetros abaixo antes da implantação do programa º±±
±±º             ³ lChkImp - Verificar se há notas anteriores não impressas                º±±
±±º             ³           Case seja .T. é necessário criar o campo F1_FIMP (C-1,0)      º±±
±±º             ³ nTamMen - Tamanho da linha de mensagme do campo dados adicionais        º±±
±±º             ³ nTamPro - Tamanho da linha de descrição do produto                      º±±
±±º             ³ nTamDet - Quantidade de linhas do detalhe de produtos                   º±±
±±º             ³ nTamSer - Quantidade de linhas do detalhe de serviços                   º±±
±±º             ³ nTamObs - Quantidade de linhas do campo de detalhes adcionais           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Alterações  ³ 99/99/99 - Consultor - Descricao da alteração                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function RFATR07(cNotIni, cNotFim, cSerie, nNotTip, lBoleto) // NOTA FISCAL PESSARO

Local aRegs		:= {}
Local nLastKey	:= 0
Local cDesc1	:= "Este programa tem como objetivo efetuar a impressão da"
Local cDesc2	:= "Nota Fiscal de Entrada/Saida, conforme os parametros"
Local cDesc3	:= "definidos pelo usuario."
Local cString	:= "SF2"
Local cPerg		:= "FATR01OFIC"

Private aCodServ := {} 
Private aLiqIss
Private nLin	:= 0
Private xVALOR_DUP
Private XDUPLICATAS	
Private lEnd		:= .F.
Private aReturn		:= {	"Especial",;				// [1]= Tipo de Formulário
							1,;							// [2]= Número de Vias
							"Faturamento",;				// [3]= Destinatário
							1,;							// [4]= Formato 1=Comprimido 2=Normal
							2,;							// [5]= Mídia 1=Disco 2=Impressora
							1,;							// [6]= Porta LPT1, LPT2, Etc
							"",;						// [7]= Expressão do Filtro
							"" ;						// [8]= ordem a ser selecionada
							}
Private cTamanho	:= "M"
Private cTitulo		:= "Impressão da Nota Fiscal Entrada/Saída"
Private wnrel		:= "RFATR07"
Private Li			:= 0

Private	nPis    	:= 0
Private	nCof    	:= 0
Private	nDescZf 	:= 0
Private nDescCP     := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define se deve checar se ha notas anteriores sem impressao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lChkImp		:= .f.		// .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o tamanho da linha do campo de dados adicionais     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nTamMen		:= 55
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o tamanho da linha do campo de descricao do produto ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nTamPro		:= 40 //estava 53 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a quantidade de linhas para o detalhe da nota fiscal ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Private nTamDet		:= 15 //estaca 25
Private nTamDet		:= 16 //estaca 25

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a quantidade de linhas para o detalhe da nota fiscal ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nTamSer		:= 15
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a quantidade de linhas para os dados adicionais (obs)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nTamObs		:= 7
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a será impresso o total de IPI qdo IPI para crédito (Destaca IPI = N)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lDestIPI	:= .F.

// Monta array com as perguntas
aAdd(aRegs,{	cPerg,;										// Grupo de perguntas
				"01",;										// Sequencia
				"Nota Fiscal Inicial",;						// Nome da pergunta
				"",;										// Nome da pergunta em espanhol
				"",;										// Nome da pergunta em ingles
				"mv_ch1",;									// Variável
				"C",;										// Tipo do campo
				09,;										// Tamanho do campo
				0,;											// Decimal do campo
				0,;											// Pré-selecionado quando for choice
				"G",;										// Tipo de seleção (Get ou Choice)
				"",;										// Validação do campo
				"MV_PAR01",;								// 1a. Variável disponível no programa
				"",;		  								// 1a. Definição da variável - quando choice
				"",;										// 1a. Definição variável em espanhol - quando choice
				"",;										// 1a. Definição variável em ingles - quando choice
				"",;										// 1o. Conteúdo variável
				"",;										// 2a. Variável disponível no programa
				"",;										// 2a. Definição da variável
				"",;										// 2a. Definição variável em espanhol
				"",;										// 2a. Definição variável em ingles
				"",;										// 2o. Conteúdo variável
				"",;							  			// 3a. Variável disponível no programa
				"",;										// 3a. Definição da variável
				"",;										// 3a. Definição variável em espanhol
				"",;										// 3a. Definição variável em ingles
				"",;										// 3o. Conteúdo variável
				"",;										// 4a. Variável disponível no programa
				"",;										// 4a. Definição da variável
				"",;										// 4a. Definição variável em espanhol
				"",;										// 4a. Definição variável em ingles
				"",;										// 4o. Conteúdo variável
				"",;										// 5a. Variável disponível no programa
				"",;										// 5a. Definição da variável
				"",;										// 5a. Definição variável em espanhol
				"",;										// 5a. Definição variável em ingles
				"",;										// 5o. Conteúdo variável
				"",;										// F3 para o campo
				"",;										// Identificador do PYME
				"",;										// Grupo do SXG
				"",;										// Help do campo
				"999999999" })									// Picture do campo
aAdd(aRegs,{cPerg,"02","Nota Fiscal Final",		"","","mv_ch2","C",09,0,0,"G","","MV_PAR03","",		"",		"",		"99999999",	"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","","999999999" })
aAdd(aRegs,{cPerg,"03","Serie Nota Fiscal",		"","","mv_ch3","C",03,0,0,"G","","MV_PAR03","",		"",		"",		"",			"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
aAdd(aRegs,{cPerg,"04","Tipo Nota",				"","","mv_ch4","N",01,0,0,"C","","MV_PAR04","Entrada",	"",		"",		"",			"","Saida",	"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})

CriaSx1(aRegs)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se é uma impressão automática ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cNotIni <> Nil .and. cNotFim <> Nil .and. cSerie <> Nil .and. nNotTip <> Nil
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chama a função pergunte para criar as variáveis mv_ e depois inicialza com o conteúdo do parâmetro ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte(cPerg,.F.)
	mv_par01	:= cNotIni
	mv_par02	:= cNotFim
	mv_par03	:= cSerie
	mv_par04	:= nNotTip
	cPerg		:= ""
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chama a função pergunte para criar as variáveis mv_ ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Pergunte(cPerg,.T.)
		Return(Nil)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama a função de interface com o usuário para definição dos parâmetros do relatório ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Wnrel := SetPrint(	cString,;				// Alias do Arquivo Principal
					Wnrel,;					// Nome Padrão do Relatório
					cPerg,;					// Alias do Grupo de Perguntas
					@cTitulo,;				// Título do Relatório
					cDesc1,;				// Descrição 1
					cDesc2,;				// Descrição 2
					cDesc3,;				// Descrição 3
					.F.,;					// Habilita Dicionário de Dados
					,;						// Array com as ordens de indexação do arquivo principal
					.F.,;					// Habilita Compressão do Relatório
					cTamanho,;				// Classificação do Tamanho (P[80]/M[132]/G[220])
					,;						// 
					)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Aborta o processamento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nLastKey == 27
	Set Filter to
	Return(Nil)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta os parâmetros alterados pela SetPrint ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetDefault(aReturn,cString)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Aborta o processamento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
If nLastKey == 27
	Set Filter to
	Return(Nil)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicio do processamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RptStatus( { |lEnd| RFATR07A() } )

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa    ³ RFATR07  ³ Rotina padrão para impressão da nota fiscal de entrada/saída º±±
±±º             ³          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Autor       ³ 99.99.99 ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Produção    ³ 99.99.99 ³ Ignorado                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parâmetros  ³ Nil                                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno     ³ Nil                                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Observações ³                                                                         º±±
±±º             ³                                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Alterações  ³ 99/99/99 - Consultor - Descricao da alteração                           º±±
±±º             ³                                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RFATR07A()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicoes das variaveis da funcao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aFImp		:= {}								// Array com os dados das notas fiscais não impressas
Local aPesPed	:= {}								// Array que controla o peso com base no pedido de venda
Local aClasFis	:= {}								// Array com as letras do NBM de cada produto
Local lContinua	:= .T.								// Controlador de impressão
Local lTransp	:= .T.								// Flag para identificar se há transportadora associada a nota
Local lSomLiq	:= .T.								// Flag de Controle de somatória do peso liquido
Local lSomBru	:= .T.								// Flag de Controle de somatória do peso bruto
Local nElem		:= 0								// Elemento do array pesquisado
Local nQdeLnh	:= 0								// Quantidade de linhas do campo de descrição do produto para o campo memo
Local nPesLiq	:= 0								// Peso liquido calculado com base no produto
Local nPesBru	:= 0								// Peso bruto calculado com base no produto
Local dEmiDev	:= CToD("  /  /  ")					// Data de emissão da nota de devolução
Local cMemo		:= ""								// Conteúdo do campo memo
LOCAL _XDESC	:= ""
Local _XCODFOR	:= ""
Local cOpMemo	:= ""								// Opção de utilização do campo memo para descrição do produto
Local cCodNBM	:= ""								// Código da Classificação Fiscal NBM para o produto
Local cPosIPI	:= ""								// Código da Classificação Fiscal NBM para o produto
//Local cMensag	:= ""								// String com a mensagem montada
Local cQry		:= ""								// String com a query a ser processada
Local nElem		:= 0								// Posição do elemento encontrado em um ascan
Local cLblTip	:= ""								// Label no nome do imposto
Local nAlqImp	:= 0								// Aliquota do imposto retido
Local aMeses	:= {}								// Array com o nome dos meses
Local cMesAno	:= ""								// Mes e ano de referência
Local lDetMsg	:=	.T.								// Flag para Impressao da Msg do Pedido de Vendas uma única vez por Nota Fiscal
Local lIPIObs	:=  .F.								// Flag para identificar se algum item tem IPI em observações
LOCAL _XIMPCOD	:= ""
Local nLoop,nForAtu
Private XPRDCLI		:= {}							// Array com os dados do Cod. Produto no Cliente
Private aCab		:= {}							// Array com os dados do cabeçalho da Nota Fiscal
Private aItens		:= {}							// Array com os dados dos itens da Nota Fiscal
Private aServico	:= {}							// Array com os dados dos serviços prestados
Private aRodape		:= {}							// Array com os dados do rodapé (totais)
Private aDuplic		:= {}							// Array com os dados das duplicatas
Private aNatOpe		:= {}							// Array com as naturezas de operação da nota fiscal
Private aImpostos	:= {}							// Array com os dados de impostos abatidos do total da nota
Private aTransp		:= {}							// Array com os dados de transporte
Private aCodMen		:= {}							// Array com os códigos das mensagens padrões
Private aDadAdc		:= {}							// Array com os dados de mensagens
Private aNFDev		:= {}							// Array com as Notas de Devolução
Private aIPIDEV		:= {}							// Array com os valores do IPI de devolução para ser impresso no corpo da nota
Private aNBM		:= {}							// Array com os códigos NBM dos produtos
Private nForAtu		:= 0							// Loop do Formulário de nota
Private lC5Mens		:= .t.
Private nTotSer		:= 0							// Valor Total dos serviços
Private cMensag	:= ""								// String com a mensagem montada

aAdd( aMeses, {  1, "Janeiro"})
aAdd( aMeses, {  2, "Fevereiro"})
aAdd( aMeses, {  3, "Marco"})
aAdd( aMeses, {  4, "Abril"})
aAdd( aMeses, {  5, "Maio"})
aAdd( aMeses, {  6, "Junho"})
aAdd( aMeses, {  7, "Julho"})
aAdd( aMeses, {  8, "Agosto"})
aAdd( aMeses, {  9, "Setembro"})
aAdd( aMeses, { 10, "Outubro"})
aAdd( aMeses, { 11, "Novembro"})
aAdd( aMeses, { 12, "Dezembro"})

If lChkImp
	If mv_par04 == 1	// Entrada
		cQry	:= " SELECT SF1.F1_DOC,SF1.F1_SERIE,SF1.F1_EMISSAO,SF1.F1_FORNECE,SF1.F1_LOJA,SF1.F1_VALBRUT,"
		cQry	+= " CASE WHEN SF1.F1_TIPO IN('B','D')"
		cQry	+= " 	THEN (SELECT SA1.A1_NOME FROM "+RetSqlName("SA1")+" SA1"
		cQry	+= "		WHERE SA1.A1_FILIAL = '"+xFilial("SA1")+"' "
		cQry	+= "		AND SA1.A1_COD = SF1.F1_FORNECE"
		cQry	+= "		AND SA1.A1_LOJA = SF1.F1_LOJA"
		cQry	+= "		AND SA1.D_E_L_E_T_ <> '*')"
		cQry	+= "	ELSE (SELECT SA2.A2_NOME FROM "+RetSqlName("SA2")+" SA2"
		cQry	+= "		WHERE SA2.A2_FILIAL = '"+xFilial("SA2")+"'"
		cQry	+= "		AND SA2.A2_COD = SF1.F1_FORNECE"
		cQry	+= "		AND SA2.A2_LOJA = SF1.F1_LOJA"
		cQry	+= "		AND SA2.D_E_L_E_T_ <> '*')"
		cQry	+= "	END AS A1_NOME"
		cQry	+= " FROM "+RetSqlName("SF1")+" SF1"
		cQry	+= " WHERE SF1.F1_FILIAL = '"+xFilial("SF1")+"'"
		cQry	+= " AND SF1.F1_DOC < '"+mv_par01+"'"
		cQry	+= " AND SF1.F1_SERIE = '"+mv_par03+"'"
		cQry	+= " AND SF1.F1_FIMP = ' '" 
		cQry	+= " AND SF1.F1_FORMUL = 'S'"
		cQry	+= " AND SF1.D_E_L_E_T_ <> '*'"

		If Select("TMPDUPL") > 0
			dbSelectArea("TMPDUPL")
			dbCloseArea()
		EndIf
		TCQUERY cQry NEW ALIAS "TMPDUPL"
		dbSelectArea("TMPDUPL")
		dbGoTop()
		While !Eof()
			aAdd( aFImp, {	TMPDUPL->F1_DOC,;
							TMPDUPL->F1_SERIE,;
							SToD(TMPDUPL->F1_EMISSAO),;
							TMPDUPL->F1_VALBRUT,;
							TMPDUPL->F1_FORNECE,;
							TMPDUPL->F1_LOJA,;
							TMPDUPL->A1_NOME ;
							})
			dbSkip()
		EndDo
		dbSelectArea("TMPDUPL")
		dbCloseArea()
	Else
		cQry	:= " SELECT SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_EMISSAO,SF2.F2_CLIENTE,SF2.F2_LOJA,SF2.F2_VALBRUT,"
		cQry	+= " CASE WHEN SF2.F2_TIPO NOT IN('B','D')"
		cQry	+= " 	THEN (SELECT SA1.A1_NOME FROM "+RetSqlName("SA1")+" SA1"
		cQry	+= "		WHERE SA1.A1_FILIAL = '"+xFilial("SA1")+"' "
		cQry	+= "		AND SA1.A1_COD = SF2.F2_CLIENTE"
		cQry	+= "		AND SA1.A1_LOJA = SF2.F2_LOJA"
		cQry	+= "		AND SA1.D_E_L_E_T_ <> '*')"
		cQry	+= "	ELSE (SELECT SA2.A2_NOME FROM "+RetSqlName("SA2")+" SA2"
		cQry	+= "		WHERE SA2.A2_FILIAL = '"+xFilial("SA2")+"'"
		cQry	+= "		AND SA2.A2_COD = SF2.F2_CLIENTE"
		cQry	+= "		AND SA2.A2_LOJA = SF2.F2_LOJA"
		cQry	+= "		AND SA2.D_E_L_E_T_ <> '*')"
		cQry	+= "	END AS A1_NOME"
		cQry	+= " FROM "+RetSqlName("SF2")+" SF2"
		cQry	+= " WHERE SF2.F2_FILIAL = '"+xFilial("SF2")+"'"
		cQry	+= " AND SF2.F2_DOC < '"+mv_par01+"'"
		cQry	+= " AND SF2.F2_SERIE = '"+mv_par03+"'"
		cQry	+= " AND SF2.F2_FIMP = ' '" 
		cQry	+= " AND SF2.D_E_L_E_T_ <> '*'"

		If Select("TMPDUPL") > 0
			dbSelectArea("TMPDUPL")
			dbCloseArea()
		EndIf
		TCQUERY cQry NEW ALIAS "TMPDUPL"
		dbSelectArea("TMPDUPL")
		dbGoTop()
		While !Eof()
			aAdd( aFImp, {	TMPDUPL->F2_DOC,;
							TMPDUPL->F2_SERIE,;
							SToD(TMPDUPL->F2_EMISSAO),;
							TMPDUPL->F2_VALBRUT,;
							TMPDUPL->F2_CLIENTE,;
							TMPDUPL->F2_LOJA,;
							TMPDUPL->A1_NOME ;
							})
			dbSkip()
		EndDo
		dbSelectArea("TMPDUPL")
		dbCloseArea()
	EndIf	

	If Len(aFImp) > 0
		VisaFImp(aFImp)
		Return(Nil)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona os arquivos para os loops ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par04 == 2						// Saídas
	dbSelectArea("SF2")					// Cabecalho da Nota Fiscal Saida
	dbSetorder(1)						// FILIAL+DOC+SERIE+CLIENTE+LOJA+FORMUL
	MsSeek(xFilial("SF2")+mv_par01+mv_par03,.T.)
	
	dbSelectArea("SD2")					// Itens de Venda da Nota Fiscal
	//dbSetorder(3)						// FILIAL+DOC+SERIE+CLIENTE+LOJA+COD+ITEM
	dbSetorder(10)						// FILIAL+DOC+SERIE+CLIENTE+LOJA+ITEM+COD - indice criado para gamaitaly, 
	MsSeek(xFilial("SD2")+mv_par01+mv_par03,.T.)
Else									// Entradas
	dbSelectArea("SF1")					// Cabecalho da Nota Fiscal Entrada
	DbSetorder(1)						// FILIAL+DOC+SERIE+FORNECE+LOJA+TIPO
	MsSeek(xFilial("SF1")+mv_par01+mv_par03,.T.)
	
	dbSelectArea("SD1")					// Itens da Nota Fiscal de Entrada
	dbSetorder(1)						// FILIAL+DOC+SERIE+FORNECE+LOJA+COD+ITEM
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta ordem dos arquivos auxiliares ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SB1")
dbSetOrder(1)

dbSelectArea("SA1")
dbSetOrder(1)

dbSelectArea("SA2")
dbSetOrder(1)

dbSelectArea("SA3")
dbSetOrder(1)

dbSelectArea("SA4")
dbSetOrder(1)

dbSelectArea("SC5")
dbSetOrder(1)

dbSelectArea("SC6")
dbSetOrder(1)

dbSelectArea("SE1")
dbSetOrder(1)

dbSelectArea("SE4")
dbSetOrder(1)

dbSelectArea("SF4")
dbSetOrder(1)

//ÚÄÄÄCÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa régua de impressão ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetRegua(Val(mv_par02)-Val(mv_par01))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao dos caracteres de controle ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetPrc(0,0)											// Inicializa impressora (Junior em 26/04/06)
Li := 0												// reinicio
//@ Li,000 PSAY Chr(27)+"@"
//@ li,000 PSay Chr(27)+Chr(67)+chr(72)				// Define tamanho do papel em 100 linhas/pagina... (Junior)
//@ Li,000 PSay Chr(27)+Chr(15)       		 		// Compressao de Impressao - Linha		(Junior em 26/04/06)
@ Li,000 PSAY Chr(15)								// Define caracteres comprimidos


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ NotCa Fiscal de Saída ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par04 == 2
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicia loop do cabecalho de nota ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SF2")
	
	While !Eof() .And. SF2->F2_FILIAL == xFilial("SF2") .And. SF2->F2_DOC <= mv_par02 .And. lContinua 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Movimenta a regua de impressão ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IncRegua("Nota Fiscal "+SF2->F2_DOC+"/"+SF2->F2_SERIE)		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Desconsidera notas com sÉrieS diferentes ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SF2->F2_SERIE <> mv_par03
			dbSkip()
			Loop
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se houve cancelamento pelo usuário ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF lEnd
			@ Li,001 PSAY "** CANCELADO PELO OPERADOR **"
			lContinua := .F.
			Exit
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Zera os array's para a nova nota ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCab		:= {}								// Array com os dados do cabeçalho da Nota Fiscal
		aItens		:= {}								// Array com os dados dos itens da Nota Fiscal
		aServico	:= {}								// Array com os dados dos serviços prestados
		aRodape		:= {}								// Array com os dados do rodapé (totais)
		aDuplic		:= {}								// Array com os dados das duplicatas
		aNatOpe		:= {}								// Array com as naturezas de operação da nota fiscal
		aImpostos	:= {}								// Array com os dados de impostos abatidos do total da nota
		aTransp		:= {}								// Array com os dados de transporte
		aCodMen		:= {}								// Array com os códigos das mensagens padrões
		aDadAdc		:= {}								// Array com os dados de mensagens
		aNFDev		:= {}								// Array com as Notas de Devolução		
		aIPIDEV		:= {}								// Array com os valores do IPI de devolução para ser impresso no corpo da nota
		aNatOpe		:= {}								// Array com as naturezas de operação da nota fiscal
		aPesPed		:= {}								// Array que controla o peso com base no pedido de venda
		aNBM		:= {}								// Array com os códigos NBM dos produtos
		
		xLOTECTL	:= {}
		
		lTransp		:= .T.								// Flag  para identificar se há transportadora associada a nota
		dEmiDev		:= CToD("  /  /  ")					// Data de emissão da nota de devolução
		nPesLiq		:= 0								// Peso liquido calculado com base no produto
		nPesBru		:= 0								// Peso bruto calculado com base no produto
		nTotSer		:= 0								// Valor total dos serviços
		lIPIObs		:= .F.								// IPI no campo de observações

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona no arquivo de clientes/fornecedores de acordo com o tipo da nota ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !(SF2->F2_TIPO $ "BD")
			dbSelectArea("SA1")
			If !MsSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)
				Aviso(	cTitulo,;
						"Cliente não localizado no arquivo! Contate o Administrador.",;
						{"&Continua"},,;
						"Cliente: "+SF2->F2_CLIENTE+"/"+SF2->F2_LOJA)
				Return(Nil)
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Carrega as mensagens codificadas ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SA1->(FieldPos("A1_MENNOT")) > 0 .And. !Empty(SA1->A1_MENNOT)
					If aScan( aCodMen, { |x| x[2] == SA1->A1_MENNOT } ) == 0
						aAdd( aCodMen, { "9", SA1->A1_MENNOT} )
					EndIf
				EndIf
			EndIf

			xCOD_CLI :=SA1->A1_COD             // Codigo do Cliente
			xNOME_CLI:=SA1->A1_NOME            // Nome
			xEND_CLI :=	SA1->A1_END             // Endereco
			xBAIRRO  :=	SA1->A1_BAIRRO          // Bairro
			xMUN_CLI :=	SA1->A1_MUN             // Municipio
			xEST_CLI :=	SA1->A1_EST             // Estado
			xCEP_CLI :=	SA1->A1_CEP             // CEP
			xCGC_CLI :=	SA1->A1_CGC             // CGC
			xINSC_CLI:=	SA1->A1_INSCR           // Inscricao estadual
			xTRAN_CLI:=	SA1->A1_TRANSP          // Transportadora
			xTEL_CLI :=	SA1->A1_TEL             // Telefone
			xTEL_DDD :=	SA1->A1_DDD             // DDD
			xFAX_CLI :=	SA1->A1_FAX             // Fax
			xSUFRAMA :=	SA1->A1_SUFRAMA         // Codigo Suframa
			xCALCSUF :=	SA1->A1_CALCSUF         // Calcula Suframa
			xCOB_CLI :=	SA1->A1_ENDCOB          // Endereco de Cobranca
			xCOB_CEP :=	SA1->A1_CEPC            // CEP de Cobranca
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³*** ENDERECO DE ENTREGA DO MESMO CLIENTE DO PEDIDO ***³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			xENDENT  :=	SA1->A1_ENDENT          // Endereco
			xBAIENT  :=	SA1->A1_BAIRROE         // Bairro
			xMUNENT  :=	SA1->A1_MUNE            // Municipio
			xESTENT  :=	SA1->A1_ESTE            // Estado
			xCEPENT  :=	SA1->A1_CEPE            // CEP
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³*** ENDERECO DE ENTREGA DE OUTRO CLIENTE NO PEDIDO ***³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SA1")                // * Cadastro de Clientes
			dbSetOrder(1)
			dbSeek(xFilial()+SC5->C5_CLIENT+SC5->C5_LOJAENT)
			xEND_ENT  :=	SA1->A1_END          	// Endereco de Entrega
			xBAI_ENT  :=	SA1->A1_BAIRRO         	// Bairro
			xMUN_ENT  :=	SA1->A1_MUN            	// Municipio
			xEST_ENT  :=	SA1->A1_EST            	// Estado
			xCEP_ENT  :=	SA1->A1_CEP            	// CEP

		Else
			dbSelectArea("SA2")
			If !MsSeek(xFilial("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA)
				Aviso(	cTitulo,;
						"Fornecedor não localizado no arquivo! Contate o Administrador.",;
						{"&Continua"},,;
						"Fornecedor: "+SF2->F2_CLIENTE+"/"+SF2->F2_LOJA)
				Return(Nil)
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Carrega as mensagens codificadas ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SA2->(FieldPos("A2_MENNOT")) > 0 .And. !Empty(SA2->A2_MENNOT)
					If aScan( aCodMen, { |x| x[2] == SA2->A2_MENNOT } ) == 0
						aAdd( aCodMen, { "9", SA2->A2_MENNOT} )
					EndIf
				EndIf
			EndIf
		
			xCOD_CLI :=SA2->A2_COD             // Codigo do Fornecedor
			xNOME_CLI:=SA2->A2_NOME            // Nome Fornecedor
			xEND_CLI :=SA2->A2_END             // Endereco
			xBAIRRO  :=SA2->A2_BAIRRO          // Bairro
			xCEP_CLI :=SA2->A2_CEP             // CEP
			xCOB_CLI :=""                      // Endereco de Cobranca
			xREC_CLI :=""                      // Endereco de Entrega
			xMUN_CLI :=SA2->A2_MUN             // Municipio
			xEST_CLI :=SA2->A2_EST             // Estado
			xPAIS	 := ""
			xCGC_CLI :=SA2->A2_CGC             // CGC
			xINSC_CLI:=SA2->A2_INSCR           // Inscricao estadual
			xTRAN_CLI:=SA2->A2_TRANSP          // Transportadora
			xTEL_CLI :=SA2->A2_TEL             // Telefone
			xTEL_DDD :=SA2->A2_DDD             // DDD
			xFAX_CLI :=SA2->A2_FAX             // Fax

		EndIf
		dbSelectArea("SF2")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Alimenta array com os campos do cabecalho da nota ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd( aCab, SF2->F2_DOC)  												// [1]Numero
		aAdd( aCab, SF2->F2_SERIE)												// [2]Serie
		aAdd( aCab, SF2->F2_TIPO)												// [3]Tipo da nota fiscal
		aAdd( aCab, SF2->F2_EMISSAO)											// [4]Data de Emissao
		aAdd( aCab, SF2->F2_CLIENTE)											// [5]Codigo do cliente
		aAdd( aCab, SF2->F2_LOJA)												// [6]Loja do Cliente
		aAdd( aCab, If(SF2->F2_TIPO $ "BD", SA2->A2_NOME, SA1->A1_NOME))		// [7]Nome do Cliente
		aAdd( aCab, If(SF2->F2_TIPO $ "BD", SA2->A2_END, SA1->A1_END))			// [8]Endereço
		aAdd( aCab, If(SF2->F2_TIPO $ "BD", SA2->A2_BAIRRO, SA1->A1_BAIRRO))	// [9]Bairro
		aAdd( aCab, If(SF2->F2_TIPO $ "BD", SA2->A2_CEP, SA1->A1_CEP))			// [10]Cep
		aAdd( aCab, If(SF2->F2_TIPO $ "BD", SA2->A2_MUN, SA1->A1_MUN))			// [11]Município
		aAdd( aCab, If(SF2->F2_TIPO $ "BD", SA2->A2_EST, SA1->A1_EST))			// [12]Estado
		aAdd( aCab, If(SF2->F2_TIPO $ "BD", SA2->A2_TEL, SA1->A1_TEL))			// [13]Fone
		aAdd( aCab, If(SF2->F2_TIPO $ "BD", SA2->A2_FAX, SA1->A1_FAX))			// [14]Fax
		aAdd( aCab, If(SF2->F2_TIPO $ "BD", SA2->A2_CGC, SA1->A1_CGC))			// [15]CGC
		aAdd( aCab, If(SF2->F2_TIPO $ "BD", SA2->A2_INSCR, SA1->A1_INSCR))		// [16]Inscrição Estadual
		aAdd( aCab, If(SF2->F2_TIPO $ "BD", SA2->A2_INSCRM, SA1->A1_INSCRM))	// [17]Inscrição Municipal
	   	aAdd( aCab, SF2->F2_VEND1)												// [18]Vendedor 
		aAdd( aCab, If(SF2->F2_TIPO $ "BD", SA2->A2_DDD, SA1->A1_DDD))			// [19]DDD  Incluido em 26/05/06

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Alimenta array com os campos do rodapé da nota (totais) ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd( aRodape, If(SF2->F2_VALBRUT == 0,;
						SF2->F2_VALMERC+SF2->F2_VALIPI+SF2->F2_SEGURO+SF2->F2_FRETE,;
						SF2->F2_VALBRUT))										// [1]Valor Bruto
		aAdd( aRodape, SF2->F2_VALMERC)											// [2]Valor  da Mercadoria
		aAdd( aRodape, SF2->F2_VALFAT)											// [3]Valor faturado
		aAdd( aRodape, SF2->F2_FRETE)											// [4]Frete
		aAdd( aRodape, SF2->F2_ICMFRET)											// [5]ICMS sobre o frete
		aAdd( aRodape, SF2->F2_FRETAUT)											// [6]Frete Autônomo
		aAdd( aRodape, SF2->F2_ICMAUTO)											// [7]ICMS sobre Frete Autônomo
		aAdd( aRodape, SF2->F2_SEGURO)											// [8]Seguro
		aAdd( aRodape, SF2->F2_DESPESA)											// [9]Despesas acessorias
		aAdd( aRodape, SF2->F2_DESCONT)											// [10]Desconto total
		aAdd( aRodape, SF2->F2_VALACRS)											// [11]Acréscimos
		aAdd( aRodape, SF2->F2_BASEICM)											// [12]Base do ICMS
		aAdd( aRodape, SF2->F2_VALICM)											// [13]Valor  do ICMS
		aAdd( aRodape, SF2->F2_BASEIPI)											// [14]Base do IPI
		aAdd( aRodape, SF2->F2_VALIPI) 											// [15]Valor  do IPI
		aAdd( aRodape, SF2->F2_BRICMS)											// [16]Base do ICMS retido
		aAdd( aRodape, SF2->F2_ICMSRET)											// [17]Valor do ICMS Retido
		aAdd( aRodape, SF2->F2_BASEISS)											// [18]Base do ISS
		aAdd( aRodape, SF2->F2_VALISS)											// [19]Valor do ISS
		aAdd( aRodape, SF2->F2_BASEINS)											// [20]Base do INSS
		aAdd( aRodape, SF2->F2_VALINSS)											// [21]Valor do INSS
		aAdd( aRodape, SF2->F2_VALIRRF)											// [22]Valor do IRRF

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Alimenta array com os campos do rodapé da nota (totais) ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SE1")
		MsSeek(xFilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DOC,.T.)
		While !Eof() .And. SE1->E1_FILIAL == xFilial("SE1") .And. SE1->E1_PREFIXO == SF2->F2_PREFIXO .And.;
							SE1->E1_NUM == SF2->F2_DOC
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se for título referente a parcela da nota grava dados no array aDuplic ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SE1->E1_TIPO == "NF "
				aAdd( aDuplic,	{	SF2->F2_PREFIXO,;							// [1]Prefixo do Título
									SF2->F2_DUPL,;								// [2]Numero da duplicata
									SF2->F2_COND,;								// [3]Condicao de Pagamento
									GetAdvFVal("SE4",;
							 			"E4_DESCRI",;
							 			xFilial("SE4")+SF2->F2_COND,;
										1,0),;									// [4]Descrição da Condição de Pagamento
									SE1->E1_PARCELA,;							// [5]Parcela
									SE1->E1_VALOR,;								// [6]Valor do Título
									SE1->E1_VENCTO,;							// [7]Vencimento
									SE1->E1_VENCREA ;							// [8]Vencimento Real
									})
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se for título referente a abatimento grava os valores no array aImpostos ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf SE1->E1_TIPO $ MVIRABT .Or.;		// Soma o valor do IRRF
				SE1->E1_TIPO $ MVINABT .Or.;	 	// Soma o valor do Inss
				SE1->E1_TIPO $ MVCSABT .Or.;		// Soma o valor do Csll
				SE1->E1_TIPO $ MVCFABT .Or.;		// Soma o valor do Cofins
				SE1->E1_TIPO $ MVPIABT				// Soma o valor do Pis

				nElem	:= aScan( aImpostos, { |x| x[1] == SE1->E1_TIPO })
				If nElem == 0
					aAdd( aImpostos, { SE1->E1_TIPO, SE1->E1_VALOR})
				Else
					aImpostos[nElem,2]	+= SE1->E1_VALOR
				EndIf
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Contas a Receber   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SE1")
			dbSetOrder(1)
			xPARC_DUP  :={}                       // Parcela
			xVENC_DUP  :={}                       // Vencimento
			xVALOR_DUP :={}                       // Valor
			xDUPLICATAS:=IIF(dbSeek(xFilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DUPL,.T.),.T.,.F.) // Flag p/Impressao de Duplicatas
			                                  
			while !eof() .and. SE1->E1_NUM==SF2->F2_DUPL .and. xDUPLICATAS==.T.
				If !("NF" $ SE1->E1_TIPO)
					dbSkip()
					Loop
				Endif
				AADD(xPARC_DUP ,SE1->E1_PARCELA)
				AADD(xVENC_DUP ,SE1->E1_VENCTO)
				AADD(xVALOR_DUP,SE1->E1_VALOR)
				dbSkip()
			EndDo			
				
		dbSelectArea("SE1")
		dbSkip()
		EndDo
		dbSelectArea("SF2")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Alimenta array de mensagens com os impostos da nota ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aImpostos) > 0
			cMensag	:= "RETENCAO NA FONTE: "
			For nLoop := 1 To Len(aImpostos)
				If aImpostos[nLoop,1] == "IR-"
					cLblTip		:= "IRRF"
					nAlqImp	:= Round((aImpostos[nLoop,2] / aRodape[1])*100,2)
				ElseIf aImpostos[nLoop,1] == "IN-"
					cLblTip		:= "INSS"
					nAlqImp	:= Round((aImpostos[nLoop,2] / aRodape[1])*100,2)
				ElseIf aImpostos[nLoop,1] == "CS-"
					cLblTip		:= "CSLL"
					nAlqImp		:= Round((aImpostos[nLoop,2] / aRodape[1])*100,2)
				ElseIf aImpostos[nLoop,1] == "CF-"
					cLblTip		:= "COFINS"
					nAlqImp		:= Round((aImpostos[nLoop,2] / aRodape[1])*100,2)
				ElseIf aImpostos[nLoop,1] == "PI-"
					cLblTip		:= "PIS"
					nAlqImp		:= Round((aImpostos[nLoop,2] / aRodape[1])*100,2)
				EndIf
				cMensag	+= cLblTip+"-"+AllTrim(Transform(nAlqImp, "@E 999.99%"))+" R$ "+AllTrim(Transform(aImpostos[nLoop,2], "@E 999,999,999.99"))+" " 
			Next nLoop
			
			CallMens(cMensag, 2, "0")
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Alimenta array com os campos da transportadora e dados do transporte ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(SF2->F2_TRANSP)
			dbSelectArea("SA4")
			If !MsSeek(xFilial("SA4")+SF2->F2_TRANSP)
				Aviso(	cTitulo,;
							"Transportadora não localizada no arquivo! Contate o Administrador.",;
							{"&Continua"},,;
							"Transportadora: "+SF2->F2_TRANSP)
				lTransp	:= .F.
				Return(Nil)
			EndIf
		Else
			lTransp	:= .F.
		EndIf
		dbSelectArea("SF2")
		aAdd( aTransp, SF2->F2_TRANSP)											// [1]Código da Transportadora
		aAdd( aTransp, SF2->F2_REDESP)											// [2]Transportadora de Redespacho
		If lTransp
			aAdd( aTransp, SA4->A4_NOME)										// [3]Nome da Transportadora
			aAdd( aTransp, SA4->A4_END)											// [4]Endereço
			aAdd( aTransp, SA4->A4_BAIRRO)										// [5]Bairro
			aAdd( aTransp, SA4->A4_MUN)											// [6]Município
			aAdd( aTransp, SA4->A4_EST)											// [7]Estado
			aAdd( aTransp, SA4->A4_CEP)											// [8]Cep 
			aAdd( aTransp, SA4->A4_CGC)											// [9]CGC
			aAdd( aTransp, SA4->A4_INSEST)										// [10]Inscrição Estadual
		Else
			aAdd( aTransp, CriaVar("A4_NOME",.F.))
			aAdd( aTransp, CriaVar("A4_END",.F.))
			aAdd( aTransp, CriaVar("A4_BAIRRO",.F.))
			aAdd( aTransp, CriaVar("A4_MUN",.F.))
			aAdd( aTransp, CriaVar("A4_EST",.F.))
			aAdd( aTransp, CriaVar("A4_CEP",.F.))
			aAdd( aTransp, CriaVar("A4_CGC",.F.))
			aAdd( aTransp, CriaVar("A4_INSEST",.F.))
		EndIf

		If SF2->(FieldPos("F2_TPFRETE")) > 0
			aAdd( aTransp, SF2->F2_TPFRETE)										// [11]Tipo de Frete (1=CIF,2=FOB)
		Else
			aAdd( aTransp, "1")
		EndIf

		If SF2->(FieldPos("F2_UFPLAC")) > 0
			aAdd( aTransp, SF2->F2_UFPLAC)										// [12]UF da Placa do Veículo
		Else
			aAdd( aTransp, SA4->A4_EST)	
		EndIf

		If SF2->(FieldPos("F2_PLACA")) > 0
			aAdd( aTransp, SF2->F2_PLACA)										// [13]Placa do Caminhão
		Else
			aAdd( aTransp, " ")
		EndIf

		aAdd( aTransp, SF2->F2_VOLUME1)											// [14]Quantidade de Volumes
		aAdd( aTransp, SF2->F2_ESPECI1)											// [15]Espécie dos Volumes 
		If SF2->(FieldPos("F2_MARCA")) > 0
			aAdd( aTransp, SF2->F2_MARCA)										// [16]Marca dos Volumes
		Else
			aAdd( aTransp, " ")
		EndIf

		If SF2->(FieldPos("F2_NUMVOL")) > 0
			aAdd( aTransp, SF2->F2_NUMVOL)										// [17]Número dos dos Volumes
		Else
			aAdd( aTransp, " ")
		EndIf

		aAdd( aTransp, SF2->F2_PBRUTO)											// [18]Peso Bruto Total
		aAdd( aTransp, SF2->F2_PLIQUI)											// [19]Peso Líquido Total

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Permite a Impressao da Msg do Pedido de Vendas (C5_MENNOTM) somente uma vez por Nota - Cezar em 22/05/06 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lDetmsg	:=	.T.

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Alimenta array com os campos dos itens da nota fiscal ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SD2")
		//dbSetorder(3)
		dbSetorder(10) // especifico GamaItaly
		MsSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE)
		While !Eof() .And. SD2->D2_FILIAL == xFilial("SD2") .And. SD2->D2_DOC == SF2->F2_DOC .And.;
							SD2->D2_SERIE == SF2->F2_SERIE
		aPosIPI     := {}		// Posicao de IPI
		aClasFis	:= {}	
		aCodPos		:= {}		// Codigo da posicao de IPI (para impressao de tabela de resumo)
		aDesPro     := {}		// Descricao do Produto
		aLiqIss		:= {}		// Aliquota de ISS do Item
		aCodServ	:= {}
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona no arquivo de Produto ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SB1")
			If !MsSeek(xFilial("SB1")+SD2->D2_COD)
				Aviso(	cTitulo,;
							"Produto não localizado no arquivo! Contate o Administrador.",;
							{"&Continua"},,;
							"Produto: "+SD2->D2_COD)
				Return(Nil)
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Defino o código NBM para o produto ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(SB1->B1_CLASFIS)
				cCodNBM	:= CriaVar("B1_CLASFIS",.F.)
				If !Empty(SB1->B1_POSIPI)
					nElem := aScan( aNBM, { |x| x[2] == SB1->B1_POSIPI})
					If nElem > 0
						cCodNBM	:= aNBM[nElem, 01]
					Else
						If Len(aNBM) > 0
							cCodNBM	:= Soma1(aNBM[Len(aNBM),01], TAMSX3("B1_CLASFIS")[1])
						Else
							cCodNBM	:= "A"
						EndIf
						// aAdd( aNBM, { cCodNBM, SB1->B1_POSIPI }) // Removido em 09/02 por Cristiano para nao imprimir as Legendas da Clas Fisc
					EndIf
				EndIf
			Else
				cCodNBM	:= SB1->B1_CLASFIS
				cPosIPI	:= SB1->B1_POSIPI
			EndIf
			
			If aScan(aPosIPI, SB1->B1_POSIPI) == 0
				AADD(aPosIPI, SB1->B1_POSIPI)
				AADD(aClasFis,SB1->B1_CLASFIS)
				AADD(aCodPos, cCodNBM)
			    AADD(aLiqIss, SD2->D2_ALIQISS)
			    AADD(aDespro, SB1->B1_DESC)
//			    AADD(aDespro, SB1->B1_DESCNF)

			Else
				AADD(aCodPos, cCodNBM)
			    AADD(aLiqIss, SD2->D2_ALIQISS)
			    AADD(aDespro, SB1->B1_DESC)
//			    AADD(aDespro, SB1->B1_DESCNF)

			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Carrega os pesos com base no produto ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPesLiq	+= Round(SB1->B1_PESO * SD2->D2_QUANT, TAMSX3("B1_PESO")[2])
			nPesBru	+= Round(SB1->B1_PESBRU * SD2->D2_QUANT, TAMSX3("B1_PESBRU")[2])

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona no arquivo de Tipo de Entrada e Saída ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SF4")
			If !MsSeek(xFilial("SF4")+SD2->D2_TES)
				Aviso(	cTitulo,;
						"Tipo de Entrada/Saída não localizado no arquivo! Contate o Administrador.",;
						{"&Continua"},,;
						"TES: "+SD2->D2_TES)
				Return(Nil)
			EndIf
			xNATUREZA	:=SF4->F4_TEXTO			// Natureza da Operacao
			XFORMSF4 	:=SF4->F4_FORMULA		// FORMULA NO TES
            
			AADD(aCodServ,SF4->F4_ISS) //HOESTE ADIS

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Carrega as mensagens codificadas ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SF4->(FieldPos("F4_MENNOT1")) > 0 .And. !Empty(SF4->F4_MENNOT1)
				If aScan( aCodMen, { |x| x[2] == SF4->F4_MENNOT1} ) == 0
					aAdd( aCodMen, { "1", SF4->F4_MENNOT1 } )
				EndIf
			EndIf
			If SF4->(FieldPos("F4_MENNOT2")) > 0 .And. !Empty(SF4->F4_MENNOT2)
				If aScan( aCodMen, { |x| x[2] == SF4->F4_MENNOT2 } ) == 0
					aAdd( aCodMen, { "1", SF4->F4_MENNOT2 } )
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Adiciona o array com as naturezas de operação ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//			If aScan( aNatOpe, { |x| x[1] == SD2->D2_TES }) == 0
//				aAdd( aNatOpe, { SD2->D2_TES, SD2->D2_CF, SF4->F4_TEXTO })
//			EndIf

 	        If aScan( aNatOpe, { |x| x[2] == SD2->D2_CF }) == 0
				aAdd( aNatOpe, { SD2->D2_TES, SD2->D2_CF, SF4->F4_TEXTO })
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona no arquivo do Cabeçalho do Pedido de Venda ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SC5")
			If !MsSeek(xFilial("SC5")+SD2->D2_PEDIDO)
				Aviso(	cTitulo,;
						"Cabeçalho do Pedido não localizado no arquivo! Contate o Administrador.",;
						{"&Continua"},,;
						"Pedido: "+SD2->D2_PEDIDO)
				Return(Nil)
			EndIf

			xCLIENTE    :=SC5->C5_CLIENTE            	// 	Codigo do Cliente
			xLOJA   	:=SC5->C5_LOJACLI            	// 	Codigo do Loja
			xCLIENT    	:=SC5->C5_CLIENT            	// 	Codigo do Cliente de Entrega
			xLOJAENT   	:=SC5->C5_LOJAENT            	// 	Codigo da Loja do Cliente de Entrega
//			xMENSAGEM   :=SC5->C5_MENNOTA            	// 	Mensagem para a Nota Fiscal
			xMENSAGEM1  :=SC5->C5_MENNOT1            	// 	Mensagem para a Nota Fiscal
			xMENSAGEM2  :=SC5->C5_MENNOT2            	// 	Mensagem para a Nota Fiscal			
			xMENSAGEM3  :=SC5->C5_MENNOT3            	// 	Mensagem para a Nota Fiscal
			xMENSAGEM4  :=SC5->C5_MENNOT4            	// 	Mensagem para a Nota Fiscal
			xMENSAGEM5  :=SC5->C5_MENNOT5            	// 	Mensagem para a Nota Fiscal									
			xCOD_MENS   :=SC5->C5_MENPAD             	// 	Codigo da Mensagem Padrao
			xTPFRETE    :=SC5->C5_TPFRETE            	// 	Tipo de Entrega
			_cPedVen    :=SC5->C5_NUM             
			_cSeuPed    :=Alltrim( SC5->C5_PEDCLI )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Carrega as mensagens codificadas ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(SC5->C5_MENPAD)
				If aScan( aCodMen, { |x| x[2] == SC5->C5_MENPAD } ) == 0
					aAdd( aCodMen, { "3", SC5->C5_MENPAD} )
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Carrega as mensagens digitadas ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(SC5->C5_MENNOTA) .and. lC5Mens
				CallMens( SC5->C5_MENNOTA, 2, "4" ) 
				lC5Mens := .f.
			EndIf

			If lDetmsg	== .T.	// Tratamento para evitar impressao da Msg abaixo Triplicada - Cezar em 22/05/06 			

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Carrega as mensagens digitadas no campo memo ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SC5->(FieldPos("C5_MENNOTM")) > 0 .And. !Empty(SC5->C5_MENNOTM)
					nQdeLnh	:= MlCount( SC5->C5_MENNOTM, nTamMen)// nQtdLin:= MlCount(calcula) Tamanho Msg caract- Espaco Dispon.(col)
					For nLoop := 1 to nQdeLnh
						cMemo	:= MemoLine( SC5->C5_MENNOTM, nTamMen, nLoop)
						CallMens( cMemo, 2, "5"+StrZero(nLoop,2) )
					Next nLoop
				EndIf
                lDetmsg	:=	.F.	// Somente a Proxima Nota trocara este Flag para ser impressa
			Endif
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta o mês/ano de referência para os contratos ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SB1->(FieldPos("B1_IMPREF")) > 0 .And. SB1->B1_IMPREF == "1"
				nElem	:= aScan( aMeses, { |x| x[1] == SC5->C5_MESREF })
				If nElem > 0
					cMesAno	:= AllTrim(aMeses[nElem,2])+"/"+StrZero(SC5->C5_ANOREF,4)
				Else
					cMesAno	:= " "
				EndIf
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Carrega os pesos com base no pedido ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aScan( aPesPed, { |x| x[1] == SD2->D2_PEDIDO }) == 0
				aAdd( aPesPed, { SD2->D2_PEDIDO, SC5->C5_PBRUTO, SC5->C5_PESOL })
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona no arquivo dos Itens do Pedido de Venda ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SC6")
			xPED_CLI 	:={}                          // Numero de Pedido
			xPED_VEND 	:={}                          // Numero de Pedido
			If !MsSeek(xFilial("SC6")+SD2->D2_PEDIDO+SD2->D2_ITEMPV)
				Aviso(	cTitulo,;
						"Item do Pedido não localizado no arquivo! Contate o Administrador.",;
						{"&Continua"},,;
						"Pedido/Item: "+SD2->D2_PEDIDO+"/"+SD2->D2_ITEMPV)
				Return(Nil)
			EndIf
			AADD(xPED_CLI  ,SC6->C6_PEDCLI)
			AADD(xPED_VEND ,SD2->D2_PEDIDO)
//			_XIMPCOD := SC6->C6_XIMPCOD // ESPECIFICO OFICINA DO CACAU
			
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta a descrição do produto com base em campos específicos ou do pedido ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Do Case
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Defino a quantidade de linhas com base no campo memo do pedido de venda ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Case SC6->(FieldPos("C6_DESCCOM")) > 0 .And. !Empty(SC6->C6_DESCCOM)
				nQdeLnh	:= MlCount( SC6->C6_DESCCOM, nTamPro)
				cOpMemo	:= "1"

		 		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Defino a quantidade de linhas com base no campo memo do cadastro do produto ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Case !Empty(MSMM(SB1->B1_DESC_P))
					cMemo	:= AllTrim( MSMM(SB1->B1_DESC_P)+" "+cMesAno)
					nQdeLnh	:= MlCount( cMemo, nTamPro)
					cOpMemo	:= "2"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Defino a quantidade de linhas com base no campo memo do cadastro do produto ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*				Case !Empty(SB1->B1_XDESCFO) 					 // ESPECIFICO OFICINA DO CACAU 
					nQdeLnh	:= MlCount( AllTrim(SB1->B1_XDESCFO))
					cOpMemo	:= "3"
*/
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Defino a quantidade de linhas com base no campo simples do pedido de venda ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			 /* Case !Empty(SC6->C6_DESCRI)
				    IF _XIMPCOD == "1"
				    	_XDESC := ALLTRIM(SC6->C6_DESCRI)+" "+ iif (!empty(SD2->D2_LOTECTL),ALLTRIM(SD2->D2_LOTECTL)," ")
				    ELSE   
				    	_XDESC := ALLTRIM(SC6->C6_DESCRI)+" "+cMesAno+"-"+ALLTRIM(SB1->B1_XCOD2)+" "+ iif (!empty(SD2->D2_LOTECTL),ALLTRIM(SD2->D2_LOTECTL)," ")
				    ENDIF
					nQdeLnh	:= MlCount(ALLTRIM(_XDESC), nTamPro)
					cOpMemo	:= "3"
             */
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Defino a quantidade de linhas com base no campo simples do cadastro do produto ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			OtherWise 
				   // IF _XIMPCOD == "1"
				     //	_XDESC := ALLTRIM(SB1->B1_DESC)+" "+ iif (!empty(SD2->D2_LOTECTL),ALLTRIM(SD2->D2_LOTECTL)," ")
				       
				_XDESC := IIF(EMPTY(SB1->B1_XDESCNF),ALLTRIM(SB1->B1_DESC),ALLTRIM(SB1->B1_XDESCNF))
				//+" "+cMesAno+"-"+ALLTRIM(SB1->B1_XCOD2)+" "+ iif (!empty(SD2->D2_LOTECTL),ALLTRIM(SD2->D2_LOTECTL)," ")
				    

				nQdeLnh	:= MlCount(ALLTRIM(_XDESC), nTamPro)
				cOpMemo	:= "4"
			
			EndCase
            
			For nLoop := 1 To nQdeLnh
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta a linha de descrição do produto com base no tamanho desta ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Do Case
					Case cOpMemo == "1"
						cMemo	:= MemoLine( SC6->C6_DESCCOM, nTamPro, nLoop)
					Case cOpMemo == "2"
						cMemo	:= MemoLine(AllTrim(MSMM(SB1->B1_DESC_P))+" "+cMesAno, nTamPro, nLoop)
/*					Case cOpMemo == "3"   // ESPECIFICO OFICINA DO CACAU
							cMemo	:= MemoLine(SB1->B1_XDESCFO, nTamPro, nLoop)
*/					Case cOpMemo == "3"
						If SB1->(FieldPos("B1_IMPREF")) > 0 .And. SB1->B1_IMPREF == "1"
					   		cMemo	:= MemoLine(_XDESC, nTamPro, nLoop)
						Else
							cMemo	:= MemoLine(_XDESC, nTamPro, nLoop)
						EndIf
				OtherWise  //ESPECIFICO OFICINA DO CACAU
				        	cMemo	:= MemoLine( _XDESC, nTamPro, nLoop)
				EndCase

				//IF !EMPTY(SB1->B1_XCOD2)   // ESPECIFICO OFICINA DO CACAU
				  //	_XCODFOR:= ALLTRIM(SB1->B1_XCOD2)
				//ENDIF
				
				If SD2->D2_VALISS > 0
					If nLoop <> 1
						aAdd( aServico, {	CriaVar("D2_COD",.F.),;		// [1]
											cMemo,;						// [2]
											CriaVar("D2_UM",.F.),;		// [3]
											CriaVar("D2_QUANT",.F.),;	// [4]
											CriaVar("D2_PRCVEN",.F.),;	// [5]
											CriaVar("D2_TOTAL",.F.),;	// [6]
											CriaVar("D2_VALISS",.F.) ;	// [7]
										})
					Else
						aAdd( aServico, {	SD2->D2_COD,;				// [1]
											cMemo,;						// [2]
											SD2->D2_UM,;				// [3]
											SD2->D2_QUANT,;				// [4]
											SD2->D2_PRCVEN,;			// [5]
											SD2->D2_TOTAL,;				// [6]
											SD2->D2_VALISS ;			// [7]Valor do ISS     
										})
					EndIf
				Else
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Adiciona o array apenas com a descrição do produto ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nLoop <> 1
						aAdd( aItens, {	CriaVar("SD2->D2_COD", .F.),;						// [1]Código do Produto
										cMemo,;												// [2]Descrição
										CriaVar("B1_CLASFIS", .F.),;						// [3]NCM
										CriaVar("D2_CLASFIS", .F.),;						// [4]Situação Tributaria
										CriaVar("D2_UM", .F.),;								// [5]Unidade de Medida
										CriaVar("D2_QUANT", .F.),;							// [6]Quantidade
										CriaVar("D2_PRCVEN", .F.),;							// [7]Preço de Venda
										CriaVar("D2_TOTAL", .F.),;							// [8]Preço Total
										CriaVar("D2_PICM", .F.),;							// [9]Percentual do ICMS
										CriaVar("D2_IPI", .F.),;							// [10]Percentual do IPI
										CriaVar("D2_VALIPI", .F.),;							// [11]Valor do IPI
										CriaVar("D2_CF", .F.),;								// [12]Código Fiscal de Operação e Prestação
										CriaVar("D2_LOTECTL", .F.),;						// [13]LOTE
										CriaVar("D2_TES", .F.),;							// [14]TES
										CriaVar("B1_POSIPI", .F.),;							// [15]POSIPI
										CriaVar("D2_VALISS", .F.),;							// [16]VALOR DO ISS
										CriaVar("D2_DTVALID", .F.),;						// [17]VALIDADE LOTE
										CriaVar("D2_DESCON", .F.),;							// [18]VALOR DO DESCONTO
										CriaVar("D2_VALBRUT", .F.); 		         			// [19]VALOR BRUTO										
										})
//										CriaVar("C6_XIMPCOD", .F.);							// [20]VALOR DO DESCONTO										
//										CriaVar("D2_OBS", .F.),;							// [13]OBSERVACAO
//										CriaVar("D2_CHEIO", .F.);							// [20]VALOR CHEIO										
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Adiciona o array todos oa dados necessários ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Else
						aAdd( aItens, { SD2->D2_COD,;
										cMemo,;
										cCodNBM,;
										If(!Empty(SD2->D2_CLASFIS),;
											SD2->D2_CLASFIS,;
											SB1->B1_ORIGEM+SF4->F4_SITTRIB)	,;
										SD2->D2_UM,;
										SD2->D2_QUANT,;
										IF(!Empty(SD2->D2_DESCZFRS),SD2->D2_PRUNIT,SD2->D2_PRCVEN),;
										IF(!Empty(SD2->D2_DESCZFRS),(SD2->D2_PRUNIT*SD2->D2_QUANT),SD2->D2_TOTAL),;
										SD2->D2_PICM,;
										SD2->D2_IPI,;
										SD2->D2_VALIPI,;
										SD2->D2_CF,;
										SD2->D2_LOTECTL,; 
										SD2->D2_TES,;
										SB1->B1_POSIPI,;
										SD2->D2_VALISS,;
										SD2->D2_DTVALID,;
 										SD2->(D2_DESCON/D2_QUANT),;
 										SD2->D2_PRCVEN+SD2->(D2_DESCON/D2_QUANT);
 										})
					EndIf
				
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ TRATAMENTO ESPECIFICO ZONA FRANCA DE MANAUS  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nLoop = 1
						nPis    := nPis + SD2->D2_DESCPIS
						nCof    := nCof + SD2->D2_DESCCOF
						nDescZf := nDescZf + SD2->D2_DESCZFR
					endif
				EndIf
			Next nLoop

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Adiciona o array com os valores do IPI no corpo da nota ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SF4->F4_DESTACA == "N" .And. SF2->F2_TIPO $ "BD"
				aAdd( aIPIDEV, SD2->D2_VALIPI )
				lIPIObs	:= .T.
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Adiciona o array com as notas de devolução ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(SD2->D2_NFORI)
				dbSelectArea("SF1")
				If MsSeek(xFilial("SF1")+SD2->(D2_NFORI+D2_SERIORI+D2_CLIENTE+D2_LOJA))
					dEmiDev	:= SF1->F1_EMISSAO
				EndIf
				dbSelectArea("SD2")
				If aScan( aNFDev, { |x| x[1]+x[2] == SD2->D2_NFORI+SD2->D2_SERIORI }) == 0
					aAdd( aNFDev, { SD2->D2_NFORI, SD2->D2_SERIORI, dEmiDev, SD2->D2_TIPO })
				EndIf
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Vai para o proximo item de nota³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SD2")
			dbSkip()
			
		Enddo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define os pesos da nota ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(aTransp[18]) .Or. !Empty(aTransp[19])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Pega os pesos do Pedido ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len(aPesPed) > 0
				lSomLiq	:= Empty(aTransp[18])
				lSomBru	:= Empty(aTransp[19])
				For nLoop := 1 To Len(aPesPed)
					If lSomLiq
						aTransp[18]	+= aPesPed[nLoop,03]
					EndIf
					If lSomBru
						aTransp[19] += aPesPed[nLoop,02]
					EndIf
				Next nLoop
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Pega os pesos do produto ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(aTransp[18]) .Or. Empty(aTransp[19])
				If Empty(aTRansp[18])
					aTransp[18]	+= nPesLiq
				EndIf
				If Empty(aTransp[19])
					aTransp[19] += nPesBru
				EndIf
			EndIf
		EndIf
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a mensagem de devolução de notas ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cMensag	:= ""
		If Len(aNFDev) > 0
			If aNFDev[1,4] == "D"
				cMensag	:= "Devolucao   "
			ElseIf aNFDev[1,4] == "C"
				cMensag	:= "Complemento "
			Else
				cMensag	:= "Retorno "
			EndIf
			cMensag	+= "Ref. nota(s) fiscal(is): "
			For nLoop := 1 To Len(aNFDev)
				If nLoop <> 1
					cMensag	+= " e "
				EndIf
				cMensag	+= AllTrim(aNFDev[nLoop,1])+ IIF (!EMPTY(aNFDev[nLoop,2]),"/"+AllTrim(aNFDev[nLoop,2]),"")   //+" de "+DToC(aNFDev[nLoop,3])
			Next nLoop
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava a mensagem montada no array ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cMensag)
			CallMens(cMensag, 2, "2")
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava as mensagens codificadas ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nLoop := 1 To Len(aCodMen)
			CallMens(aCodMen[nLoop,2], 1, aCodMen[nLoop,1]+StrZero(nLoop,2))
		Next nLoop

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava as mensagens do IPI para crédito no campo de dados adicionais |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nVlrIPIDev	:= 0
		For nLoop := 1 To Len(aIPIDev)
			nVlrIPIDev += aIPIDev[nLoop]
		Next nLoop
		If !Empty(nVlrIPIDev)
			cMensag	:= "IPI para credito do destinatario no valor de R$ "+AllTrim(Transform(nVlrIPIDev, "@E 999,999,999.99"))
			CallMens(cMensag, 2, "0")
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calcula a quantidade de formularios necessarios³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nFormul := Max( Int(Len(aItens)/nTamDet + .999999999), Int(Len(aServico)/nTamSer + .999999999) )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se tem IPI em Observações e não imprime o Total do IPI no quadro próprio, zerá a variavel com o total do IPI³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lDestIPI .And. lIPIObs
			aRodape[15]	:= 0 // [15]Valor  do IPI
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Chama funcao de impressao da nota fiscal³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nForAtu := 1 to nFormul
			Imprime()
		Next

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava o flag de nota impressa se foi pedido a impressão na impressora ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SF2")
		If aReturn[5] == 3   
			RecLock("SF2",.F.)
				SF2->F2_FIMP	:= "X"
			MsUnLock()
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Movimenta o registro e a regua de impressao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SF2")
		dbSkip()
	EndDo
	
Else	// Compras - Entradas
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicia loop do cabecalho de nota ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SF1")
	
	While !Eof() .And. SF1->F1_FILIAL == xFilial("SF1") .And. SF1->F1_DOC <= mv_par02 .And. lContinua 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Movimenta a regua de impressão ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IncRegua("Nota Fiscal "+SF1->F1_DOC+"/"+SF1->F1_SERIE)		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Desconsidera notas com sÉrieS diferentes ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SF1->F1_SERIE <> mv_par03
			dbSkip()
			Loop
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Desconsidera notas que não são formulário próprio |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SF1->F1_FORMUL <> "S"
			dbSkip()
			Loop
		Endif
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se houve cancelamento pelo usuário ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF lEnd
			@ Li,001 PSAY "** CANCELADO PELO OPERADOR **"
			lContinua := .F.
			Exit
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Zera os array's para a nova nota ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCab		:= {}								// Array com os dados do cabeçalho da Nota Fiscal
		aItens		:= {}								// Array com os dados dos itens da Nota Fiscal
		aServico	:= {}								// Array com os dados dos serviços prestados
		aRodape		:= {}								// Array com os dados do rodapé (totais)
		aDuplic		:= {}								// Array com os dados das duplicatas
		aNatOpe		:= {}								// Array com as naturezas de operação da nota fiscal
		aImpostos	:= {}								// Array com os dados de impostos abatidos do total da nota
		aTransp		:= {}								// Array com os dados de transporte
		aCodMen		:= {}								// Array com os códigos das mensagens padrões
		aDadAdc		:= {}								// Array com os dados de mensagens
		aNFDev		:= {}								// Array com as Notas de Devolução		
		aIPIDEV		:= {}								// Array com os valores do IPI de devolução para ser impresso no corpo da nota
		aNatOpe		:= {}								// Array com as naturezas de operação da nota fiscal
		aPesPed		:= {}								// Array que controla o peso com base no pedido de venda
		aNBM		:= {}								// Array com os códigos NBM dos produtos
		xLOTECTL	:= {}
		lTransp		:= .T.								// Flag  para identificar se há transportadora associada a nota
		dEmiDev		:= CToD("  /  /  ")					// Data de emissão da nota de devolução
		nPesLiq		:= 0								// Peso liquido calculado com base no produto
		nPesBru		:= 0								// Peso bruto calculado com base no produto
		lIPIObs		:= .F.								// Destaca IPI em Observações
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona no arquivo de clientes/fornecedores de acordo com o tipo da nota ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (SF1->F1_TIPO $ "BD")
			dbSelectArea("SA1")
			If !MsSeek(xFilial("SA1")+SF1->F1_FORNECE+SF1->F1_LOJA)
				Aviso(	cTitulo,;
						"Cliente não localizado no arquivo! Contate o Administrador.",;
						{"&Continua"},,;
						"Cliente: "+SF1->F1_FORNECE+"/"+SF1->F1_LOJA)
				Return(Nil)
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Carrega as mensagens codificadas ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SA1->(FieldPos("A1_MENNOT")) > 0 .And. !Empty(SA1->A1_MENNOT)
					If aScan( aCodMen, { |x| x[2] == SA1->A1_MENNOT } ) == 0
						aAdd( aCodMen, { "9", SA1->A1_MENNOT} )
					EndIf
				EndIf
			EndIf
		Else
			dbSelectArea("SA2")
			If !MsSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA)
				Aviso(	cTitulo,;
						"Fornecedor não localizado no arquivo! Contate o Administrador.",;
						{"&Continua"},,;
						"Fornecedor: "+SF1->F1_FORNECE+"/"+SF1->F1_LOJA)
				Return(Nil)
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Carrega as mensagens codificadas ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SA2->(FieldPos("A2_MENNOT")) > 0 .And. !Empty(SA2->A2_MENNOT)
					If aScan( aCodMen, { |x| x[2] == SA2->A2_MENNOT } ) == 0
						aAdd( aCodMen, { "9", SA2->A2_MENNOT} )
					EndIf
				EndIf
			EndIf
		EndIf
		dbSelectArea("SF1")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Alimenta array com os campos do cabecalho da nota ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd( aCab, SF1->F1_DOC)  													// [1]Numero
		aAdd( aCab, SF1->F1_SERIE)													// [2]Serie
		aAdd( aCab, SF1->F1_TIPO)													// [3]Tipo da nota fiscal
		aAdd( aCab, SF1->F1_DTDIGIT)												// [4]Data de Emissao
		aAdd( aCab, SF1->F1_FORNECE)	//acab[5]									// [5]Codigo do cliente
		aAdd( aCab, SF1->F1_LOJA)		//acab[6]									// [6]Loja do Cliente
		aAdd( aCab, If(SF1->F1_TIPO $ "BD", SA1->A1_NOME, 		SA2->A2_NOME))		// [7]Nome do Cliente
		aAdd( aCab, If(SF1->F1_TIPO $ "BD", SA1->A1_END, 		SA2->A2_END))		// [8]Endereço
		aAdd( aCab, If(SF1->F1_TIPO $ "BD", SA1->A1_BAIRRO,	SA2->A2_BAIRRO))	// [9]Bairro
		aAdd( aCab, If(SF1->F1_TIPO $ "BD", SA1->A1_CEP, 		SA2->A2_CEP))		// [10]Cep
		aAdd( aCab, If(SF1->F1_TIPO $ "BD", SA1->A1_MUN, 		SA2->A2_MUN))		// [11]Município
		aAdd( aCab, If(SF1->F1_TIPO $ "BD", SA1->A1_EST, 		SA2->A2_EST))		// [12]Estado
		aAdd( aCab, If(SF1->F1_TIPO $ "BD", SA1->A1_TEL, 		SA2->A2_TEL))		// [13]Fone
		aAdd( aCab, If(SF1->F1_TIPO $ "BD", SA1->A1_FAX, 		SA2->A2_FAX))		// [14]Fax
		aAdd( aCab, If(SF1->F1_TIPO $ "BD", SA1->A1_CGC, 		SA2->A2_CGC))		// [15]CGC
		aAdd( aCab, If(SF1->F1_TIPO $ "BD", SA1->A1_INSCR, 	SA2->A2_INSCR))		// [16]Inscrição Estadual
		aAdd( aCab, If(SF1->F1_TIPO $ "BD", SA1->A1_INSCRM,	SA2->A2_INSCRM))	// [17]Inscrição Municipal
	   	aAdd( aCab, CriaVar("F2_VEND1",.F.))										// [18]Vendedor 
		aAdd( aCab, If(SF1->F1_TIPO $ "BD", SA1->A1_DDD, 		SA2->A2_DDD))		// [19]DDD  Incluido em 26/05/06
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Alimenta array com os campos do rodapé da nota (totais) ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd( aRodape,	If(SF1->F1_VALBRUT == 0,;
						SF1->F1_VALMERC+SF1->F1_VALIPI+SF1->F1_SEGURO+SF1->F1_FRETE,;
						SF1->F1_VALBRUT))											// [1]Valor Bruto
		aAdd( aRodape, IF(SF1->F1_DESCONT>0,SF1->F1_VALMERC-SF1->F1_DESCONT,;
		               SF1->F1_VALMERC))											// [2]Valor  da Mercadoria //alterado para tratamento do desconto
		aAdd( aRodape, SF1->F1_VALBRUT)												// [3]Valor faturado
		aAdd( aRodape, SF1->F1_FRETE)												// [4]Frete
		aAdd( aRodape, 0)															// [5]ICMS sobre o frete
		aAdd( aRodape, 0)															// [6]ICMS sobre Frete Autônomo
		aAdd( aRodape, SF1->F1_SEGURO)												// [7]Seguro
		aAdd( aRodape, SF1->F1_DESPESA)												// [8]Despesas acessorias
		aAdd( aRodape, SF1->F1_DESCONT)												// [9]Desconto total
		aAdd( aRodape, 0)															// [10]Acréscimos
		aAdd( aRodape, SF1->F1_BASEICM)												// [11]Base do ICMS
		aAdd( aRodape, SF1->F1_VALICM)												// [12]Valor  do ICMS
		aAdd( aRodape, SF1->F1_BASEIPI)												// [13]Base do IPI
		aAdd( aRodape, SF1->F1_VALIPI)												// [14]Valor  do IPI
		aAdd( aRodape, SF1->F1_BRICMS)												// [15]Base do ICMS retido
		aAdd( aRodape, SF1->F1_ICMSRET)												// [16]Valor do ICMS Retido
		aAdd( aRodape, 0)															// [17]Base do ISS
		aAdd( aRodape, SF1->F1_ISS)													// [18]Valor do ISS
//		aAdd( aRodape, SF1->F1_BASEINS)												// [19]Base do INSS
		aAdd( aRodape, SF1->F1_INSS)												// [20]Valor do INSS
		aAdd( aRodape, SF1->F1_IRRF)												// [21]Valor do IRRF

		//	aAdd( aRodape, SF1->F1_VALIPI)  	// [15]Valor  do IPI // Alterado em 26/05/06 para n Imrimir valor qdi dev.Teste
		//	If(SF4->F4_DESTACA <> "N", SD1->D1_IPI,0),;
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona no SD1 para Buscar o Código do TES  - Incluido em 7/7/6 - Cezar³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SD1")
		dbSetorder(1)
		MsSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)

		aPosIPI     := {}						   // Posicao de IPI
		aClasFis	:= {}
		aCodPos		:= {}						   // Codigo da posicao de IPI (para impressao de tabela de resumo)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona no arquivo de Tipo de Entrada e Saída    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SF4")
		If !MsSeek(xFilial("SF4")+SD1->D1_TES)
			Aviso(	cTitulo,;
					"Tipo de Entrada/Saída não localizado no arquivo! Contate o Administrador.",;
					{"&Continua"},,;
					"TES: "+SD1->D1_TES)
			Return(Nil)
		EndIf		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ ADIS - COD. 17298              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//		xNATUREZA	:=SF4->F4_FINALID			// Natureza da Operacao
		XFORMSF4 	:=SF4->F4_FORMULA		// FORMULA NO TES

		AADD(aCodServ,SF4->F4_ISS) 			//ADIS
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega as mensagens digitadas ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cMensag	:= ""
		If SF1->(FieldPos("F1_OBSERV1")) > 0 .And. !Empty(SF1->F1_OBSERV1)
			cMensag	+= AllTrim(SF1->F1_OBSERV1)
		EndIf
		If SF1->(FieldPos("F1_OBSERV2")) > 0 .And. !Empty(SF1->F1_OBSERV2)
			cMensag += " "+AllTrim(SF1->F1_OBSERV2)
		EndIf
		If SF1->(FieldPos("F1_OBSERV3")) > 0 .And. !Empty(SF1->F1_OBSERV3)
			cMensag	+= " "+AllTrim(SF1->F1_OBSERV3)
		EndIf
		If SF1->(FieldPos("F1_OBSERV4")) > 0 .And. !Empty(SF1->F1_OBSERV4)
			cMensag	+= " "+AllTrim(SF1->F1_OBSERV4)
		EndIf
		If SF1->(FieldPos("F1_OBSERV5")) > 0 .And. !Empty(SF1->F1_OBSERV5)
			cMensag	+= " "+AllTrim(SF1->F1_OBSERV5)
		EndIf

		CallMens( cMensag, 2, "41" ) 
		cMensag	:= ""
		If SF1->(FieldPos("F1_NUMDI")) > 0 .And. !Empty(SF1->F1_NUMDI)
			cMensag	:= "Referente Declaracao de Importacao No. "+ AllTrim(SF1->F1_NUMDI) +" de "+DToC(SF1->F1_DATDI)
			CallMens( cMensag, 2, "42" ) 
		EndIf
		cMensag	:= ""

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Alimenta array com os campos do rodapé da nota (totais) ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		/*
		dbSelectArea("SE2")
		MsSeek(xFilial("SE2")+SF1->F1_PREFIXO+SF1->F1_DOC,.T.)
		While !Eof() .And. SE2->E2_FILIAL == xFilial("SE2") .And. SE2->E2_PREFIXO == SF1->F1_PREFIXO .And.;
							SE2->E2_NUM == SF1->F1_DOC
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se for título referente a parcela da nota grava dados no array aDuplic ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SE2->E2_TIPO == "NF "
				aAdd( aDuplic,	{	SF1->F1_PREFIXO,;							// [1]Prefixo do Título
									SF1->F1_DUPL,;								// [2]Numero da duplicata
									SF1->F1_COND,;								// [3]Condicao de Pagamento
									GetAdvFVal("SE4",;
							 			"E4_DESCRI",;
							 			xFilial("SE4")+SF1->F1_COND,;
										1,0),;									// [4]Descrição da Condição de Pagamento
									SE2->E2_PARCELA,;							// [5]Parcela
									SE2->E2_VALOR,;								// [6]Valor do Título
									SE2->E2_VENCTO,;							// [7]Vencimento
									SE2->E2_VENCREA ;							// [8]Vencimento Real
									})
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se for título referente a abatimento grava os valores no array aImpostos ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf SubStr(SE2->E2_TIPO,3,1) == "-"
				nElem	:= aScan( aImpostos, { |x| x[1] == SE2->E2_TIPO })
				If nElem == 0
					aAdd( aImpostos, { SE2->E2_TIPO, SE2->E2_VALOR})
				Else
					aImpostos[nElem,2]	+= SE2->E2_VALOR
				EndIf
			EndIf
			dbSelectArea("SE2")
			dbSkip()
		EndDo
		*/
		
		dbSelectArea("SF2")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Alimenta array com os campos da transportadora e dados do transporte ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(SF1->F1_XTRANSP)
			dbSelectArea("SA4")
			If !MsSeek(xFilial("SA4")+SF1->F1_XTRANSP)
				Aviso(	cTitulo,;
							"Transportadora não localizada no arquivo! Contate o Administrador.",;
							{"&Continua"},,;
							"Transportadora: "+SF1->F1_XTRANSP)
				lTransp	:= .F.
				Return(Nil)
			EndIf
		Else
			lTransp	:= .F.
		EndIf
		
		dbSelectArea("SF1")
		aAdd( aTransp, SF1->F1_XTRANSP)											// [1]Código da Transportadora
		aAdd( aTransp, CriaVar("F2_REDESP",.F.))								// [2]Transportadora de Redespacho
//		lTransp := .F.
		If lTransp
			aAdd( aTransp, SA4->A4_NOME)										// [3]Nome da Transportadora
			aAdd( aTransp, SA4->A4_END)											// [4]Endereço
			aAdd( aTransp, SA4->A4_BAIRRO)										// [5]Bairro
			aAdd( aTransp, SA4->A4_MUN)											// [6]Município
			aAdd( aTransp, SA4->A4_EST)											// [7]Estado
			aAdd( aTransp, SA4->A4_CEP)											// [8]Cep 
			aAdd( aTransp, SA4->A4_CGC)											// [9]CGC
			aAdd( aTransp, SA4->A4_INSEST)										// [10]Inscrição Estadual
		Else
			aAdd( aTransp, CriaVar("A4_NOME",.F.))
			aAdd( aTransp, CriaVar("A4_END",.F.))
			aAdd( aTransp, CriaVar("A4_BAIRRO",.F.))
			aAdd( aTransp, CriaVar("A4_MUN",.F.))
			aAdd( aTransp, CriaVar("A4_EST",.F.))
			aAdd( aTransp, CriaVar("A4_CEP",.F.))
			aAdd( aTransp, CriaVar("A4_CGC",.F.))
			aAdd( aTransp, CriaVar("A4_INSEST",.F.))
		EndIf
  
		If !EMPTY(SF1->F1_XTFRETE)
		  	aAdd( aTransp, SF1->F1_XTFRETE)										// [11]Tipo de Frete (1=CIF,2=FOB)
		Else
			aAdd( aTransp, "1")
		EndIf    
		
		If !EMPTY(SF1->F1_XPLACA)
		  	aAdd( aTransp, SF1->F1_XPLACA)										// [13]Placa do Caminhão
		Else
			aAdd( aTransp, " ")
		EndIf
  
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Alimenta array com os campos dos itens da nota fiscal ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SD1")
		dbSetorder(1)
		MsSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
		While !Eof() .And. SD1->D1_FILIAL == xFilial("SD1") .And. SD1->D1_DOC == SF1->F1_DOC .And.;
							SD1->D1_SERIE == SF1->F1_SERIE .And.;
							SD1->D1_FORNECE == SF1->F1_FORNECE .And.;
							SD1->D1_LOJA == SF1->F1_LOJA

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Desconsidera notas que não são formulário próprio |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SD1->D1_FORMUL <> "S"
				dbSkip()
				Loop
			Endif
					
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona no arquivo de Produto ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SB1")
			If !MsSeek(xFilial("SB1")+SD1->D1_COD)
				Aviso(	cTitulo,;
							"Produto não localizado no arquivo! Contate o Administrador.",;
							{"&Continua"},,;
							"Produto: "+SD1->D1_COD)
				Return(Nil)
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Carrega as mensagens codificadas ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SB1->(FieldPos("B1_MENNOT")) > 0 .And. !Empty(SB1->B1_MENNOT)
				If aScan( aCodMen, { |x| x[2] == SB1->B1_MENNOT } ) == 0
					aAdd( aCodMen, { "8", SB1->B1_MENNOT } )
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Defino o código NBM para o produto ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(SB1->B1_CLASFIS)
				cCodNBM	:= CriaVar("B1_CLASFIS",.F.)
				If !Empty(SB1->B1_POSIPI)
					nElem := aScan( aNBM, { |x| x[2] == SB1->B1_POSIPI})
					If nElem > 0
						cCodNBM	:= aNBM[nElem, 01]
					Else
						If Len(aNBM) > 0
							cCodNBM	:= Soma1(aNBM[Len(aNBM),01], TAMSX3("B1_CLASFIS")[1])
						Else
							cCodNBM	:= "A"
						EndIf
						aAdd( aNBM, { cCodNBM, SB1->B1_POSIPI })
					EndIf
				EndIf
			Else
				cCodNBM	:= SB1->B1_CLASFIS
				cPosIPI	:= SB1->B1_POSIPI
			EndIf

			
			If aScan(aPosIPI, SB1->B1_POSIPI) == 0
				AADD(aPosIPI, SB1->B1_POSIPI)
				AADD(aClasFis,SB1->B1_CLASFIS)
//				AADD(aCodPos, Chr(Len(aPosIPI)+64))
				AADD(aCodPos, cCodNBM)
			Else
//				AADD(aCodPos, Chr(aScan(aPosIPI, SB1->B1_POSIPI)+64))
				AADD(aCodPos, cCodNBM)
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Carrega os pesos com base no produto ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPesLiq	+= Round(SB1->B1_PESO * SD1->D1_QUANT, TAMSX3("B1_PESO")[2])
			nPesBru	+= Round(SB1->B1_PESBRU * SD1->D1_QUANT, TAMSX3("B1_PESBRU")[2])

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona no arquivo de Tipo de Entrada e Saída ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SF4")
			If !MsSeek(xFilial("SF4")+SD1->D1_TES)
				Aviso(	cTitulo,;
						"Tipo de Entrada/Saída não localizado no arquivo! Contate o Administrador.",;
						{"&Continua"},,;
						"TES: "+SD1->D1_TES)
				Return(Nil)
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ ADIS - COD. 17298              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//			xNATUREZA	:=SF4->F4_FINALID			// Natureza da Operacao
			XFORMSF4 	:=SF4->F4_FORMULA		// FORMULA NO TES
          
			AADD(aCodServ,SF4->F4_ISS) //HOESTE ADIS

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Carrega as mensagens codificadas ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SF4->(FieldPos("F4_MENNOT1")) > 0 .And. !Empty(SF4->F4_MENNOT1)
				If aScan( aCodMen, { |x| x[2] == SF4->F4_MENNOT1} ) == 0
					aAdd( aCodMen, { "1", SF4->F4_MENNOT1 } )
				EndIf
			EndIf
			If SF4->(FieldPos("F4_MENNOT2")) > 0 .And. !Empty(SF4->F4_MENNOT2)
				If aScan( aCodMen, { |x| x[2] == SF4->F4_MENNOT2 } ) == 0
					aAdd( aCodMen, { "1", SF4->F4_MENNOT2 } )
				EndIf
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Adiciona o array com as naturezas de operação ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aScan( aNatOpe, { |x| x[2] == SD1->D1_CF }) == 0				 
				aAdd( aNatOpe, { SD1->D1_TES, SD1->D1_CF, SF4->F4_TEXTO })		// SD2->D2_TES 	19/05
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta a descrição do produto com base em campos específicos ou do pedido ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Do Case
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Defino a quantidade de linhas com base no campo memo do pedido de venda ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Case SD1->(FieldPos("D1_DESCCOM")) > 0 .And. !Empty(SD1->D1_DESCCOM)
					nQdeLnh	:= MlCount( SD1->D1_DESCCOM+" "+iif (!empty(SD2->D2_LOTECTL),ALLTRIM(SD2->D2_LOTECTL)," "), nTamPro)
					cOpMemo	:= "1"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Defino a quantidade de linhas com base no campo memo do cadastro do produto ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Case !Empty(SB1->B1_DESC_P)
					cMemo	:= AllTrim( MSMM(SB1->B1_DESC_P))
					nQdeLnh	:= MlCount( cMemo, nTamPro)
					cOpMemo	:= "2"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Defino a quantidade de linhas com base no campo memo do cadastro do produto ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*				Case !Empty(SB1->B1_XDESCFO) 					 // ESPECIFICO OFICINA DO CACAU 
					nQdeLnh	:= MlCount( AllTrim(SB1->B1_XDESCFO))
					cOpMemo	:= "3"
*/
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Defino a quantidade de linhas com base no campo simples do pedido de venda ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Case SD1->(FieldPos("D1_DESCRI")) > 0 .And. !Empty(SD1->D1_DESCRI)
					_XDESC 	:= ALLTRIM( SD1->D1_DESCRI)+" "+iif (!empty(SD2->D2_LOTECTL),ALLTRIM(SD2->D2_LOTECTL)," ")
					nQdeLnh	:= MlCount(ALLTRIM(_XDESC), nTamPro)
					cOpMemo	:= "3"

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Defino a quantidade de linhas com base no campo simples do cadastro do produto ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			OtherWise
				_XDESC	:= SB1->B1_DESC
				nQdeLnh	:= MlCount( ALLTRIM(_XDESC), nTamPro)
				cOpMemo	:= "4"
			EndCase

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se a quantidade de linhas for igual a zero, força pegar do cadastro de produto ³
			//³ pois em alguns casos os campos memos podem estar vazios                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nQdeLnh == 0
				_XDESC	:= SB1->B1_DESC
				nQdeLnh	:= MlCount( _XDESC, nTamPro)
				cOpMemo	:= "4"
			EndIf

			For nLoop := 1 To nQdeLnh
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta a linha de descrição do produto com base no tamanho desta ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Do Case
					Case cOpMemo == "1"
						cMemo	:= MemoLine( SD1->D1_DESCCOM, nTamPro, nLoop)
					Case cOpMemo == "2"
						cMemo	:= MemoLine( AllTrim( _XDESC), nTamPro, nLoop)
/*					Case cOpMemo == "3"   // ESPECIFICO OFICINA DO CACAU
							cMemo	:= MemoLine(SB1->B1_XDESCFO, nTamPro, nLoop)
*/					Case cOpMemo == "3"
						cMemo	:= MemoLine( SD1->D1_DESCRI, nTamPro, nLoop)
				OtherWise
					cMemo	:= MemoLine( _XDESC, nTamPro, nLoop)
				EndCase

//				IF !EMPTY(SB1->B1_XCOD2)   // ESPECIFICO OFICINA DO CACAU
  //					_XCODFOR:= ALLTRIM(SB1->B1_XCOD2)
	//			ENDIF
			
			xMenEnt  := SD1->D1_X_MPAD 
            xMenEnt1 := SD1->D1_X_MNOT

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Adiciona o array apenas com a descrição do produto ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nLoop <> 1
					aAdd( aItens, {	CriaVar("SD1->D1_COD", .F.),;				// [1]Código do Produto
									cMemo,;										// [2]Descrição
									CriaVar("B1_CLASFIS", .F.),;				// [3]NBM
									CriaVar("D1_CLASFIS", .F.),;				// [4]Situação Tributária
									CriaVar("D1_UM", .F.),;						// [5]Unidade de Medida
									CriaVar("D1_QUANT", .F.),;					// [6]Quantidade
									CriaVar("D1_VUNIT", .F.),;					// [7]Preço de Venda
									CriaVar("D1_TOTAL", .F.),;					// [8]Preço Total
									CriaVar("D1_PICM", .F.),;					// [9]Percentual do ICMS
									CriaVar("D1_IPI", .F.),;					// [10]Percentual do IPI
									CriaVar("D1_VALIPI", .F.),;					// [11]Valor do IPI
									CriaVar("D1_CF", .F.),;						// [12]Código Fiscal de Operação e Prestação
									CriaVar("D1_LOTECTL", .F.),;				// [13]LOTE
									CriaVar("D1_DTVALID", .F.),;				// [14]VALIDADE LOTE
									CriaVar("B1_POSIPI", .F.),;					// [15]POSIPI
									CriaVar("D1_TES", .F.),;						// [16] TES
									CriaVar("D1_X_MPAD", .F.),;					// [17] MPAD
									CriaVar("D1_X_MNOT", .F.);					// [18] MNOT								
									 })
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Adiciona o array todos oa dados necessários ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Else
					aAdd( aItens, {	SD1->D1_COD,;	
									cMemo,;
									cCodNBM,;
									If(!Empty(SD1->D1_CLASFIS),;
										SD1->D1_CLASFIS,;
										SB1->B1_ORIGEM+SF4->F4_SITTRIB)	,;
									SD1->D1_UM,;
									SD1->D1_QUANT,;
									IF(SD1->D1_VALDESC>0,((SD1->D1_TOTAL-SD1->D1_VALDESC)/SD1->D1_QUANT),SD1->D1_VUNIT),;
									IF(SD1->D1_VALDESC>0,(SD1->D1_TOTAL-SD1->D1_VALDESC),SD1->D1_TOTAL),;
									SD1->D1_PICM,;
									If(SF4->F4_DESTACA <> "N", SD1->D1_IPI,0),; 
									If(SF4->F4_DESTACA <> "N", SD1->D1_VALIPI, 0),;  		
									SD1->D1_CF,;
									SD1->D1_LOTECTL,;
									SD1->D1_DTVALID,;
									SB1->B1_POSIPI,;
									SD1->D1_TES,;                                           
									SD1->D1_X_MPAD,;									
									SD1->D1_X_MNOT;
									})
				EndIf
			Next nLoop
          

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Adiciona o array com os valores do IPI no corpo da nota ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SF4->F4_DESTACA == "N" .And. SF1->F1_TIPO $ "BD"
				aAdd( aIPIDEV, SD1->D1_VALIPI )
				lIPIObs	:= .T.
			EndIf
							
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Adiciona o array com as notas de devolução ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(SD1->D1_NFORI)
				dbSelectArea("SF2")
				If MsSeek(xFilial("SF2")+SD1->(D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA))
					dEmiDev	:= SF2->F2_EMISSAO
				EndIf
				dbSelectArea("SD1")
				If aScan( aNFDev, { |x| x[1]+x[2] == SD1->D1_NFORI+SD1->D1_SERIORI }) == 0
					aAdd( aNFDev, { SD1->D1_NFORI, SD1->D1_SERIORI, dEmiDev, SD1->D1_TIPO })
				EndIf
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Vai para o proximo item de nota³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SD1")
			dbSkip()
			
		Enddo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a mensagem de devolução de notas ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aNFDev) > 0
			If aNFDev[1,4] == "D"
				cMensag	:= "Devolucao   "
			Else
				cMensag	:= "Retorno     "
			EndIf
			cMensag	+= "Ref. a(s) nota(s) fiscal(is) "
			For nLoop := 1 To Len(aNFDev)
				If nLoop <> 1
					cMensag	+= " e "
				EndIf
				cMensag	+= AllTrim(aNFDev[nLoop,1])+IIF (!EMPTY(aNFDev[nLoop,2]),"/"+AllTrim(aNFDev[nLoop,2]),"") //+" de "+DToC(aNFDev[nLoop,3])
			Next nLoop
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava a mensagem montada no array ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		CallMens(cMensag, 2, "2")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava as mensagens codificadas ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nLoop := 1 To Len(aCodMen)
			CallMens(aCodMen[nLoop,2], 1, aCodMen[nLoop,1]+StrZero(nLoop,2))
		Next nLoop

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava as mensagens do IPI para crédito no campo de dados adicionais |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nVlrIPIDev	:= 0
		For nLoop := 1 To Len(aIPIDev)
			nVlrIPIDev += aIPIDev[nLoop]
		Next nLoop
		If !Empty(nVlrIPIDev)
			cMensag	:= "IPI para credito no valor de R$ "+AllTrim(Transform(nVlrIPIDev, "@E 999,999,999.99"))
			CallMens(cMensag, 2, "0")
		EndIf
			   
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calcula a quantidade de formularios necessarios³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nFormul := Int(Len(aItens)/nTamDet + .999999999)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se tem IPI em Observações e não imprime o Total do IPI no quadro próprio, zerá a variavel com o total do IPI³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lDestIPI .And. lIPIObs
			aRodape[15]	:= 0 				// [15]Valor  do IPI
		EndIf
						  
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Chama funcao de impressao da nota fiscal³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nForAtu := 1 to nFormul
			Imprime()
		Next

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava o flag de nota impressa se foi pedido a impressão na impressora ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SF1")
		If aReturn[5] == 2
			RecLock("SF1",.F.)
			SF1->F1_FIMP	:= "X"
			MsUnLock()
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Movimenta o registro e a regua de impressao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SF1")
		dbSkip()
	EndDo
	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime caracter de descompactacao e zera posicao do formulario³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//@ 72, 000 PSAY Chr(18)+" "					  // Descompressao de caracteres

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Encerra a impressao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Set Device To Screen    

SetPgEject(.f.)

If aReturn[5] == 1
	Set Printer TO
	dbCommitAll()
	OurSpool(wnrel)
Endif

Ms_Flush()

*******************************************************************************************************
Static Function CriaSx1(aRegs)
*******************************************************************************************************
Local aAreaAnt	:= GetArea()
Local aAreaSX1	:= SX1->(GetArea())
Local nLoop2	:= 0
Local nLoop1	:= 0

dbSelectArea("SX1")
dbSetOrder(1)

For nLoop1 := 1 To Len(aRegs)
	If !MsSeek(aRegs[nLoop1,1]+aRegs[nLoop1,2])
		RecLock("SX1",.T.)
		For nLoop2 := 1 To FCount()
			If nLoop2 <= Len(aRegs[nLoop1])
				FieldPut(nLoop2,aRegs[nLoop1,nLoop2])
			EndIf
		Next nLoop2
		MsUnlock()
	EndIf
Next nLoop1

RestArea(aAreaSX1)
RestArea(aAreaAnt)

Return(Nil)

******************************************************************************************************
Static Function VisaFImp(aFImp)
******************************************************************************************************
Local oDlg
Local oListBox
Local aTitulo	:= {	"Nota Fiscal",;
						"Série",;
						"Emissão",;
						"Valor Bruto",;
						"Código Cliente",;
						"Loja",;
						"Nome Cliente/Fornecedor" ;
						}	// Array com os t'tiulos da janela listbox
Local cListBox	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Array aFImp                                   | 
//| 1o. Elemento - Número da Nota Fiscal          |
//| 2o. Elemento - Série da Nota Fiscal           |
//| 3o. Elemento - Data de Emissão da Nota Fiscal |
//| 4o. Elemento - Valor Bruto da Nota Fiscal     |
//| 5o. Elemento - Código do Cliente              |
//| 6o. Elemento - Loja do Cliente                |
//| 7o. Elemento - Nome do Cliente                |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Ordena array pela parcela de forma descendente para que o registro totalizador fique primeiro |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSort(aFImp,,, { |x, y| x[2]+x[1] < y[2]+y[1] } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Monta display |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE "Notas Fiscais não Impressas" From 9,0 To 19,60 OF oMainWnd 
DEFINE SBUTTON FROM    4,206 	TYPE 1  ACTION (nOpc := 1,oDlg:End()) ENABLE OF oDlg 
@ .5,.7 LISTBOX oListBox VAR cListBox Fields HEADER ;
										aTitulo[1],;
										aTitulo[2],;
										aTitulo[3],;
										aTitulo[4],;
										aTitulo[5],;
										aTitulo[6],;
										aTitulo[7],;
										SIZE 195,62 
oListBox:SetArray(aFImp)
oListBox:bLine := { || {	aFImp[oListBox:nAt,1],;
   							aFImp[oListBox:nAt,2],;
   							aFImp[oListBox:nAt,3],;
							Transform(aFImp[oListBox:nAt,4], "@E 9,999,999.99"),;
							aFImp[oListBox:nAt,5],;
							aFImp[oListBox:nAt,6],;
							aFImp[oListBox:nAt,7] ;
							}}
ACTIVATE MSDIALOG oDlg CENTERED

Return(Nil)

******************************************************************************************************
Static Function CallMens(cMensag, nTipo, cPrior)
******************************************************************************************************
Local cTexto	:= ""
Local nLoop		:= 0
Local nCnt		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Se for mensagem codificada monta o texto |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTipo == 1
	cTexto	:= AllTrim(Formula(cMensag))
Else
	cTexto	:= AllTrim(cMensag)
EndIf

For nLoop := 1 To Len(cTexto) Step nTamMen
	nCnt++
	aAdd( aDadAdc, { cPrior+StrZero(nCnt,2), SubStr(cTexto,nLoop,nTamMen)} )
Next

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ IMPRIME  º Autor ³ Hoeste Morelandes  º Data ³  20/12/95   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Impressao da Nota Fiscal de Entrada e de Saida             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso      ³ AP8 - ESPECIFICO - ADIS (17298)                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Imprime()

Local nLoop		:= 0
Local cNatOpe	:= ""
Local cCFOOpe	:= ""
Local cLinha1	:= ""
Local cLinha2	:= ""
Local cLinha3	:= ""
Local nDetObs	:= 0

//+--------------------------------------------------------------+
//¦              IMPRESSAO DA N.F. DA Nfiscal                    ¦
//¦        INICIA A IMPRESSAO DA NOTA FISCAL DE SAIDA            ¦
//+--------------------------------------------------------------+
For nLoop := 1 To Len(aNatOpe)
	cNatOpe	+= If(!Empty(cNatOpe), "/", "")+AllTrim(aNatOpe[nLoop,3])
	cCFOOpe += If(!Empty(cCFOOpe), "/", "")+Transform(aNatOpe[nLoop,2], "@R 9999")
Next nLoop

nLin := 00
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³RESETA A IMPRESSORA E DEFINE O TAM. DA PAGINA     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ PROW(), PCOL() PSAY CHR(27)+'@'
@ PROW(), PCOL() PSAY CHR(27)+'C'+CHR(72)
@ PROW(), PCOL() PSAY ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ativa o Comando para aumentar a Fonte da Impressao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//@ nLin,002 PSAY CHR(27)+"E"+ CHR(27)+"M"+CHR(14)+ aCab[01] + If(nFormul > 1,"/"+AllTrim(Str(nForAtu,6)),"")+CHR(27)+"F"+CHR(27)+"P"+CHR(20)

@ nLin,000 PSAY Chr(15)								// Define caracteres comprimidos

//+-------------------------------------+
//¦ Impressao do Cabecalho da N.F.      ¦
//+-------------------------------------+
@ nLin,126 PSAY ALLTRIM(aCab[01]) + If(nFormul > 1,"/"+AllTrim(Str(nForAtu,6)),"") 
nLin += 1                                                                               
If mv_par04 == 2 // Saida
	@ nLin,087 PSAY "XX"
Else
	@ nLin,103 PSAY "XX"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Natureza de Operacao - Descricao                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLin += 6                                                                                
If Len(aNatOpe) > 1
	@ nLin,001 PSAY ALLTRIM(Left(cNatOpe, 40))
	@ nLin,044 PSAY ALLTRIM(Left(cCFOOpe, 14))
Else
	@ nLin,001 PSAY ALLTRIM(Left(cNatOpe, 40))
	@ nLin,044 PSAY ALLTRIM(Left(cCFOOpe, 14))
Endif	
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados do Cliente / Fornecedor                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLin += 3                                                                                
If mv_par04 == 2 .and. aCab[03]=='N' .OR. aCab[03]=='C' .OR. aCab[03]=='P' .OR. aCab[03]=='I' .OR. aCab[03]=='S' .OR. aCab[03]=='T' .OR. aCab[03]=='O' 
	If !(aCab[03]$"BD") 
		@ nLin,002 PSAY AllTrim(xNOME_CLI)         	//	Nome do Cliente
	Else
		@ nLin,002 PSAY AllTrim(aCab[07])			//	Nome do Cliente
	Endif
Else
	@ nLin,002 PSAY alltrim(aCab[07])						//	Nome do Fornecedor
Endif

If mv_par04 == 2 .and. aCab[03]=='N' .OR. aCab[03]=='C' .OR. aCab[03]=='P' .OR. aCab[03]=='I' .OR. aCab[03]=='S' .OR. aCab[03]=='T' .OR. aCab[03]=='O' 
	If Len(xCGC_CLI) > 11			// CGC		
		@ nLin,094 PSAY ALLTRIM(Transform(xCGC_CLI, "@R 99.999.999/9999-99"))
	Else
		@ nLin,094 PSAY ALLTRIM(Transform(xCGC_CLI, "@R 999.999.999-99"))
	EndIf
Else
	If Len(Alltrim(aCab[15])) > 11	// CGC		
		@ nLin,094 PSAY ALLTRIM(Transform(aCab[15], "@R 99.999.999/9999-99"))
	Else
		@ nLin,094 PSAY ALLTRIM(Transform(aCab[15], "@R 999.999.999-99"))
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Data da Emissao do Documento                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ nLin,126 PSAY ALLTRIM(DTOC(aCab[04]))

nLin += 2                                                                                
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereco / Bairro / CEP                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par04 == 2 .and. aCab[03]=='N' .OR. aCab[03]=='C' .OR. aCab[03]=='P' .OR. aCab[03]=='I' .OR. aCab[03]=='S' .OR. aCab[03]=='T' .OR. aCab[03]=='O' 
	@ nLin,002 PSAY ALLTRIM(xEND_CLI)		// Endereco
	if !empty(xBAIRRO)
		@ nLin,078 PSAY ALLTRIM(xBAIRRO)			// Bairro
	ELSE
		@ nLin,078 PSAY " "							// Bairro	
	ENDIF
	@ nLin,107 PSAY ALLTRIM(Transform(xCEP_CLI, "@R 99999-999"))	//CEP
Else
	@ nLin,002 PSAY ALLTRIM(aCab[08])		// Endereco
	IF !EMPTY(aCab[09])
		@ nLin,078 PSAY ALLTRIM(aCab[09])		// Bairro
	ELSE
		@ nLin,078 PSAY " "				 		// Bairro
	ENDIF
	@ nLin,107 PSAY Transform(aCab[10], "@R 99999-999")	//CEP
Endif

nLin += 2                                                                                
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Municipio/DDD Fone/Estado/Inscricao Estadual     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par04 == 2 .and. aCab[03]=='N' .OR. aCab[03]=='C' .OR. aCab[03]=='P' .OR. aCab[03]=='I' .OR. aCab[03]=='S' .OR. aCab[03]=='T' .OR. aCab[03]=='O' 
	@ nLin,002 PSAY xMUN_CLI						// Municipio
	@ nLin,060 PSAY xTEL_DDD						// DDD
	@ nLin,064 PSAY SUBSTR(xTEL_CLI,1,4)            // Telefone/FAX
	@ nLin,068 PSAY "-"
	@ nLin,069 PSAY SUBSTR(xTEL_CLI,5,4)            // Telefone/FAX
	@ nLin,083 PSAY xEST_CLI						// Estado
	@ nLin,094 PSAY xINSC_CLI						// I.E.
Else
	@ nLin,002 PSAY aCab[11]						// Municipio
	@ nLin,060 PSAY SA2->A2_DDD						// DDD
	@ nLin,064 PSAY SUBSTR(aCab[13],1,4)            // Telefone/FAX
	@ nLin,068 PSAY "-"
	@ nLin,069 PSAY SUBSTR(aCab[13],5,4)            // Telefone/FAX
	@ nLin,083 PSAY aCab[12]						// Estado
	@ nLin,094 PSAY aCab[16]						// I.E.
Endif

//nLin += 3                                                                                
//+-------------------------------------+
//¦ Impressao da Fatura/Duplicata       ¦
//+-------------------------------------+
If !(aCab[03]$"BD")
	nLin:=16
	BB:=1
	nCol := 031             //  duplicatas
	If xDUPLICATAS == .F.
		@ 16, 015 PSAY " "
	Else
	    If SF2->F2_VALFAT > 0
			If mv_par04 == 2
				DUPLIC()
			Endif
		Else
			@ 16, 015 PSAY " "
		Endif
	Endif
Endif

//nLin += 2                                                                                

//nLin:= 22
nLin:= 22
nLin2:=nLin + 14        //WILDER
nval	:= Len(aItens)  //WILDER 

If Len(aItens) > 0
	ImpDet(nLin)
EndIf       

If nFormul = 1 .or. nForAtu = nFormul // inserido por Denis Ribeiro para tratamento da mensagem suframa 02/04/2009
   IF !EMPTY(nDescZf)
   		nlin:=37
        IF !EMPTY(nPis) .and. !EMPTY(nCof) 
   		   nDescZf := nDescZf - nPis - nCof
   		   nDescPC := nPis + nCof
   		   @ nLin,006 PSAY "Abatimento I.C.M.S: "+ TRANSFORM(nDescZf,"@E 9999,999,999.99")+"         "+"Abatimento de PIS/COFINS :"+ TRANSFORM(nDescPC,"@E 9999,999,999.99")  
        else
   		   @ nLin,006 PSAY "Abatimento I.C.M.S: "+ TRANSFORM(nDescZf,"@E 9999,999,999.99")  
   		endif
    ENDIF
 ENDIF   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime os Itens da Nota de Servico³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLin := 40

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime os Totais da Nota ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If nFormul > 1 .And. nForAtu <> nFormul
	@ nLin,006 PSAY "****.***.***,**"
	@ nLin,030 PSAY "****.***.***,**"
	@ nLin,064 PSAY "****.***.***,**"
	@ nLin,094 PSAY "****.***.***,**"
	@ nLin,120 PSAY "****.***.***,**"
Else
	If mv_par04 == 2 
		@ nLin,006 PSAY TRANSFORM(aRodape[12],"@E 9999,999,999.99") //base icms
		@ nLin,030 PSAY TRANSFORM(aRodape[13],"@E 9999,999,999.99") //valor icms
		@ nLin,056 PSAY TRANSFORM(aRodape[16],"@E 9999,999,999.99") //base icms retido
		@ nLin,094 PSAY TRANSFORM(aRodape[17],"@E 9999,999,999.99") //valor icms retido
		@ nLin,119 PSAY TRANSFORM(aRodape[02]-nTotSer,"@E 9999,999,999.99") //valor dos produtos
    Else
		@ nLin,006 PSAY TRANSFORM(aRodape[11],"@E 9999,999,999.99")
		@ nLin,030 PSAY TRANSFORM(aRodape[12],"@E 9999,999,999.99")
		@ nLin,056 PSAY TRANSFORM(aRodape[16],"@E 9999,999,999.99")
		@ nLin,094 PSAY TRANSFORM(aRodape[17],"@E 9999,999,999.99")
		@ nLin,119 PSAY TRANSFORM(aRodape[02]-nTotSer,"@E 9999,999,999.99")
	Endif    
EndIf    	
nLin += 2

If nFormul > 1 .And. nForAtu <> nFormul
	@ nLin,006 PSAY "****.***.***,**"
	@ nLin,030 PSAY "****.***.***,**"
	@ nLin,056 PSAY "****.***.***,**"
	@ nLin,094 PSAY "****.***.***,**"
	@ nLin,119 PSAY "****.***.***,**"
Else
	If mv_par04 == 2 
		@ nLin,006 PSAY aRodape[04]				Picture "@E 9999,999,999.99" //frete
		@ nLin,030 PSAY aRodape[07]				Picture "@E 9999,999,999.99" //Seguro
		@ nLin,056 PSAY aRodape[09]				Picture "@E 9999,999,999.99" //Despesas Acessorias
		@ nLin,094 PSAY aRodape[15]				Picture "@E 9999,999,999.99" //valor ipi
		@ nLin,119 PSAY aRodape[01]				Picture "@E 9999,999,999.99" //Valor Bruto
	Else
		@ nLin,006 PSAY aRodape[04]				Picture "@E 9999,999,999.99"
		@ nLin,027 PSAY aRodape[07]				Picture "@E 9999,999,999.99"
		@ nLin,056 PSAY aRodape[08]				Picture "@E 9999,999,999.99"
		@ nLin,094 PSAY aRodape[14]				Picture "@E 9999,999,999.99"
		@ nLin,119 PSAY aRodape[01]				Picture "@E 9999,999,999.99"
	Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime os Dados de Transporte ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLin += 3
If nFormul = 1 .Or. nForAtu == nFormul
	@ nLin,001 PSAY aTransp[03]
	If mv_par04 == 2
		If xTPFRETE=='C'				//Frete por conta do
			@ nLin, 077 PSAY "1"		//  Emitente  (1)
		Else							//     ou
			@ nLin, 077 PSAY "2"		//Destinatario(2)
		Endif
	Else
		@ nLin, 077 PSAY "2"			// Emitente (1)
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime o CGC da Transportadora ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(aTransp[09])
		If Len(Alltrim(aTransp[09])) >= 14
			@ nLin, 115 PSAY aTransp[09] Picture"@R 99.999.999/9999-99"
		Else
			@ nLin, 115 PSAY aTransp[09] Picture"@R 999.999.999-99"
		Endif
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime Enderecos da Transportadora ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLin += 2
	If nFormul = 1 .Or. nForAtu == nFormul
		@ nLin,001 PSAY aTransp[04]	// Endereco Transportadora
		@ nLin,068 PSAY aTransp[06]	// Municipio
		@ nLin,098 PSAY aTransp[07]	// U.F.
		@ nLin,115 PSAY aTransp[10]	// I.E.
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime dos dados dos volumes³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLin += 2
	If (nFormul = 1 .Or. nForAtu == nFormul)
		If mv_par04 == 2
//			@ nLin,004 PSAY SF2->F2_VOLUME1		Picture "@E 999,999"
//			@ nLin,032 PSAY "VOLUME"
			@ nLin,030 PSAY SF2->F2_ESPECI1			
			
		Else
			@ nLin,004 PSAY "  " //SF1->F1_VOLUME1		Picture "@E 999,999.99"
//			@ nLin,032 PSAY "VOLUME" 
			@ nLin,030 PSAY SF2->F2_ESPECI1			
		Endif		
	
		If mv_par04 == 2
			@ nLin,068 PSAY  _cPedVen 
	    ELse
			@ nLin,099 PSAY  "  " //SF1->F1_PBRUTO	Picture "@E 999,999.99"
			@ nLin,118 PSAY  "  " //SF1->F1_PLIQUI	Picture "@E 999,999.99"
	    Endif
	EndIf                                        
	
//	nLin++
//	@nLin,001 Psay "012356789012356789012356789012356789012356789012356789012356789012356789012356789012356789012356789012356789012356789012356789012356789012356789012356789012356789012356789012356789012356789"
//	nLin++
//	@nLin,001 Psay "        10       20       30       40       50       60       70       80       90       100      110      120      130      140      150      160      170      180      190      200      210"
	
//+-------------------------------------+
//¦ Mensagens Finais                    ¦
//+-------------------------------------+
nLin := nLin+1

ImpEnd()

@ 62,124  PSAY ALLTRIM(aCab[01]) + If(nFormul > 1,"/"+AllTrim(Str(nForAtu,6)),"")        

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona final do formulario³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//@ 72, 000 PSAY chr(18)+Chr(15) 		// Descompressao de Impressao
@ 66, 000 PSAY Chr(15) 		// Descompressao de Impressao

SetPrc(0,0)                     	// (Zera o Formulario)

Return .t.
                                  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ImpMenx  º Autor ³ Hoeste Morelandes  º Data ³ 12/09/2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprime Mensagens da Nota Fiscal                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ KAP - 15896                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpMenx()
Local aImpMenx		:= {}
Local z,i,x
Local aTesF4        :={}
Local aFormF4       :={}
Local cCodForm      :=''
Local cTxtSF4       :=''
local _xPosIPI		:=''
local _nCont		:= 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime as Msg's da Nota Fiscal    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//nLin += 4

    If MV_PAR04 == 2 .AND. Empty(Alltrim(xMENSAGEM1))
		If !Empty(xCOD_MENS)		
		@ 52, 001 PSAY alltrim(SUBSTR(FORMULA(xCOD_MENS), 1, 68))			
		@ 53, 001 PSAY alltrim(SUBSTR(FORMULA(xCOD_MENS), 69,68))					
		Endif
        If !Empty(XFORMSF4)
        @ 54, 001 PSAY alltrim(SUBSTR(FORMULA(XFORMSF4), 1, 68))			
		@ 55, 001 PSAY alltrim(SUBSTR(FORMULA(XFORMSF4), 69,68))				
		endif			
        If !Empty(_cSeuPed)
			@ 56, 001 PSAY "Seu Pedido : " + _cSeuPed
		Endif
		If !(SF2->F2_TIPO $ "BD")
			If !Empty(xENDENT)
				@ 57, 001 PSAY "End. Ent. " + alltrim(xENDENT)  + " - " + alltrim(xBAIENT)
     			@ 58, 001 PSAY ALLTRIM(xMUNENT) + " / " + ALLTRIM(xESTENT) + " - " + ALLTRIM(xCEPENT)  
			Endif
		ENDIF

	Elseif MV_PAR04 == 2 .AND. Empty(Alltrim(xMENSAGEM2))
		@ 52, 001 Psay alltrim(Substr(xMENSAGEM1,1,68))
		If !Empty(xCOD_MENS)		
		@ 53, 001 PSAY alltrim(SUBSTR(FORMULA(xCOD_MENS), 1, 68))			
		@ 54, 001 PSAY alltrim(SUBSTR(FORMULA(xCOD_MENS), 69,68))					
		Endif
        If !Empty(XFORMSF4)
        @ 55, 001 PSAY alltrim(SUBSTR(FORMULA(XFORMSF4), 1, 68))			
		@ 56, 001 PSAY alltrim(SUBSTR(FORMULA(XFORMSF4), 69,68))				
		endif
        If !Empty(_cSeuPed)
			@ 57, 001 PSAY "Seu Pedido : " + _cSeuPed
		Endif
	
		

	Elseif MV_PAR04 == 2 .AND. Empty(Alltrim(xMENSAGEM3))
		@ 52, 001 Psay alltrim(Substr(xMENSAGEM1,1,68))
		@ 53, 001 Psay alltrim(Substr(xMENSAGEM2,1,68))		
		If !Empty(xCOD_MENS)				
		@ 54, 001 PSAY alltrim(SUBSTR(FORMULA(xCOD_MENS), 1, 68))			
		@ 55, 001 PSAY alltrim(SUBSTR(FORMULA(xCOD_MENS), 69,68))					
		Endif
		If !Empty(XFORMSF4)
        @ 56, 001 PSAY alltrim(SUBSTR(FORMULA(XFORMSF4), 1, 68))			
		@ 57, 001 PSAY alltrim(SUBSTR(FORMULA(XFORMSF4), 69,68))				
		endif
        If !Empty(_cSeuPed)
			@ 58, 001 PSAY "Seu Pedido : " + _cSeuPed
		Endif 
	Elseif MV_PAR04 == 2 .AND. Empty(Alltrim(xMENSAGEM4))
		@ 52, 001 Psay alltrim(Substr(xMENSAGEM1,1,68))
		@ 53, 001 Psay alltrim(Substr(xMENSAGEM2,1,68))		
		@ 54, 001 Psay alltrim(Substr(xMENSAGEM3,1,68))				
		If !Empty(xCOD_MENS)				
		@ 55, 001 PSAY alltrim(SUBSTR(FORMULA(xCOD_MENS), 1, 68))			
		@ 56, 001 PSAY alltrim(SUBSTR(FORMULA(xCOD_MENS), 69,68))							
		Endif
        If !Empty(_cSeuPed)
			@ 57, 001 PSAY "Seu Pedido : " + _cSeuPed
		Endif		

	Elseif MV_PAR04 == 2 .AND. Empty(Alltrim(xMENSAGEM5))
		@ 52, 001 Psay alltrim(Substr(xMENSAGEM1,1,68))
		@ 53, 001 Psay alltrim(Substr(xMENSAGEM2,1,68))		
		@ 54, 001 Psay alltrim(Substr(xMENSAGEM3,1,68))				
		@ 55, 001 Psay alltrim(Substr(xMENSAGEM4,1,68))						
		If !Empty(xCOD_MENS)				
		@ 56, 001 PSAY alltrim(SUBSTR(FORMULA(xCOD_MENS), 1, 68))			
		@ 57, 001 PSAY alltrim(SUBSTR(FORMULA(xCOD_MENS), 69,68))									
		Endif
        If !Empty(_cSeuPed)
			@ 58, 001 PSAY "Seu Pedido : " + _cSeuPed
		Endif		
    Elseif MV_PAR04 == 2 
		@ 52, 001 Psay alltrim(Substr(xMENSAGEM1,1,68))
		@ 53, 001 Psay alltrim(Substr(xMENSAGEM2,1,68))		
		@ 54, 001 Psay alltrim(Substr(xMENSAGEM3,1,68))				
		@ 55, 001 Psay alltrim(Substr(xMENSAGEM4,1,68))						
		@ 56, 001 Psay alltrim(Substr(xMENSAGEM5,1,68))					
		If !Empty(xCOD_MENS)							
		@ 57, 001 PSAY alltrim(SUBSTR(FORMULA(xCOD_MENS), 1, 68))			
		@ 58, 001 PSAY alltrim(SUBSTR(FORMULA(xCOD_MENS), 69,68))									
		Endif
        If !Empty(_cSeuPed) .AND. EMPTY (xCOD_MENS)
			@ 57, 001 PSAY "Seu Pedido : " + _cSeuPed
		Endif	   
     Else
            @ 52, 001 PSAY cMensag
		    @ 53, 001 PSAY SUBSTR(AllTrim(Formula(xMenEnt)),1, 68)						
		    @ 54, 001 PSAY SUBSTR(AllTrim(Formula(xMenEnt)),69, 68)						
			@ 55, 001 PSAY xMenEnt1
     Endif		
//ENDIF

//If MV_PAR04 == 2 .AND. !Empty(Alltrim(xCOD_MENS))
//	@ 56, 001 PSAY alltrim(SUBSTR(FORMULA(xCOD_MENS), 1, 68))
//	@ 57, 001 PSAY alltrim(SUBSTR(FORMULA(xCOD_MENS), 69, 68))	
//ENDIF

nLin:=58

if mv_par04 == 2
     for z:=1 to len(aNBM) 
     	if (!empty(aNBM[z,01]) .AND. !empty(aNBM[z,01])) .and. Z < len(aNBM)
     		_xPosIPI := _xPosIPI + ALLTRIM(aNBM[z,01])+"="+ALLTRIM(aNBM[z,02])+", "
     	else
     		_xPosIPI := _xPosIPI + ALLTRIM(aNBM[z,01])+"="+ALLTRIM(aNBM[z,02])
     	ENDIF
     next z
endif           

If mv_par04 == 2
	For i:=1 to Len(aItens)
	    If  !empty(aItens[i,14]) //aScan(aTesF4,aItens[i,14]) == 0    
        	aadd(aTesF4 ,aItens[i,14])
    	EndIf
	Next i
ELSE
	For i:=1 to Len(aItens)
	    If  !empty(aItens[i,16]) //aScan(aTesF4,aItens[i,14]) == 0    
        	aadd(aTesF4 ,aItens[i,16])
    	EndIf
	Next i
ENDIF

For z:=1 to Len(aTesF4)
    cCodForm :=GetAdvFVal("SF4","F4_FORMULA",xFilial("SF4")+aTesF4[z],1)
    aadd(aFormF4 ,cCodForm)
Next z

If Len(aFormF4) > 0
	For z:=1 to Len(aFormF4)
		dbSelectArea ("SM4")
		dbSetOrder(1)
		dbSeek(xFilial("SM4")+aFormF4[z])
		XFORMSF4 := STRTRAN(SM4->M4_FORMULA,"'")
	Next z
Endif

If mv_par04 == 2
	If !Empty(xCOD_MENS)
		dbSelectArea ("SM4")
		dbSetOrder(1)
		dbSeek(xFilial("SM4")+xCOD_MENS)
		xCOD_MENS := STRTRAN(SM4->M4_FORMULA,"'")
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  MENSAGENS DO PADRAO - FORMULA SF4 / SC5           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SA1")
dbSetOrder(1)
dbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)

dbSelectArea("SA3")
dbSetOrder(1)
dbSeek(xFilial("SA3")+SF2->F2_VEND1+SF2->F2_LOJA)



If mv_par04 == 2
//	AADD(aImpMenx,iif (!empty(SF2->F2_VEND1),"VENDEDOR: " +SF2->F2_VEND1+"-"+SA3->A3_NREDUZ+" "+"PEDIDO NRO.:"+_cPedVen,"PEDIDO NRO.:"+_cPedVen))	//	01 Desabilitado Conforme a Solicitacao do Sr Luis ( 09/02 )

    If !Empty(_cSeuPed)
  	   AADD(aImpMenx,"Seu Pedido : " + _cSeuPed )
  	Endif   
	AADD(aImpMenx,SUBSTR(_xPosIPI,1,70))		//	02   CLASSIFICACAO FISCAL
	AADD(aImpMenx,SUBSTR(_xPosIPI,71,70))		//	03   CLASSIFICACAO FISCAL
	AADD(aImpMenx,SUBSTR(_xPosIPI,142,70))		//	04   CLASSIFICACAO FISCAL
	for x:=1 to Len(AdadAdc) 
		if (!empty(aDadAdc[x,1]) .and. !empty(aDadAdc[x,2])) .AND. substr(aDadAdc[x,1],1,1) == "2"
	   		AADD(aImpMenx,SUBSTR(aDadAdc[x,2],1,70))		//	05   NUMERO DAS NOTAS DE DEVOLUCOES E/OU BENEFICIAMENTO
	   	endif
	next x	
	AADD(aImpMenx,SUBSTR(XFORMSF4,1,70))		//	06   FORMULA NO CADASTRO DE TES
	AADD(aImpMenx,SUBSTR(XFORMSF4,71,70))		//	07   FORMULA NO CADASTRO DE TES
	AADD(aImpMenx,SUBSTR(XFORMSF4,142,70))		//	08   FORMULA NO CADASTRO DE TES

//	AADD(aImpMenx,SUBSTR(XCOD_MENS,1,70))		//	05   FORMULA PEDIDO DE VENDAS
//	AADD(aImpMenx,SUBSTR(XCOD_MENS,71,70))		//	06   FORMULA PEDIDO DE VENDAS
//	AADD(aImpMenx,SUBSTR(XCOD_MENS,142,70))		//	07   FORMULA PEDIDO DE VENDAS
//	AADD(aImpMenx,"DESCONTO: "+" " )               //	06
//	AADD(aImpMenx,"DESCONTO: "+Transform(SF2->F2_DESCONT,"@E 999,999,999.99"))//	08 DESCONTO
//	AADD(aImpMenx,SUBSTR(xMENSAGEM,1,100))		//	08   MENSAGEM PARA NOTA NO PEDIDO DE VENDAS
//	AADD(aImpMenx,SUBSTR(xMENSAGEM,101,100))	//	09   MENSAGEM PARA NOTA NO PEDIDO DE VENDAS

//Esta com 31 a nLin

for z:=1 to Len(aImpMenx)
	If !Empty(aImpMenx[Z]) .and. _nCont < nTamObs
		_nCont++
//		@nLin,001	Psay aImpMenx[Z]
		nLin:=nLin+1
	Endif
next z

//nlin:=nlin+2

//@ 61,124  PSAY ALLTRIM(aCab[01]) + If(nFormul > 1,"/"+AllTrim(Str(nForAtu,6)),"")        


ELSE

	FOR z:=1 to Len(aDadAdc)
		if (!empty(aDadAdc[Z,1]) .and. !empty(aDadAdc[Z,2])) .AND. substr(aDadAdc[Z,1],1,1) == "2"
			_nCont++
			AADD(aImpMenx,(aDadAdc[z,2]))				//	01   MENSAGEM INFORMANDO A NOTA FISCAL DE ORIGEM
		endif
	next z
	AADD(aImpMenx,SUBSTR(XFORMSF4,1,70))		//	03   FORMULA NO CADASTRO DE TES
	AADD(aImpMenx,SUBSTR(XFORMSF4,71,70))		//	04   FORMULA NO CADASTRO DE TES
	AADD(aImpMenx,SUBSTR(XFORMSF4,142,70))		//	05   FORMULA NO CADASTRO DE TES
	
	for z:=1 to Len(aImpMenx)
		If !Empty(aImpMenx[z]) .and. _nCont < nTamObs
			_nCont ++
//			@nLin,001	Psay aImpMenx[z]
			nLin:=nLin+1
		Endif
    next z
    
Endif

aImpMenx := {}

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³  ImpEnd  º Autor ³ Hoeste Morelandes  º Data ³ 31/07/2007  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Imprime Mensagens Finais da Nota Fiscal :                   º±±
±±ºda Rotina ³Codigo NCM dos Produtos / Informacoes do Pedido de Vendas / º±±
±±º          ³Mensagens do Pedido de Vendas - C5_MEMNOTA (Caracter 200)   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ADIS - 17298                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpEnd()
Local aImpEnd	:= {}
Local nPosIPI   := 1				// Contador do vetor de classificacao fiscal (posicao de IPI)
Local aNcm     :={}
Local aNumPed  :={}
Local i
aadd(aNcm,{Alltrim(aItens[1,3]),Alltrim(aItens[1,15])})
For i:=1 to Len(aItens)
    If !Empty(Alltrim(aItens[i,3]))
	    If  aScan(aNcm  ,{|x,y|Alltrim(x[1])==Alltrim(aItens[i,3])}) == 0    
	       aadd(aNcm,{Alltrim(aItens[i,3]),Alltrim(aItens[i,15])})
	    EndIf
    EndIf
Next i

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  MENSAGEN DO PEDIDO DE VENDAS                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par04 == 2

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|QUEBRA DE PAGINA -**CONTINUA** |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nFormul > 1 .And. nForAtu <> nFormul
		@ 055,020 PSAY " *** C  O  N  T  I  N  U  A ***  "
	ElseIf nForAtu == nFormul
		ImpMenx()
	Endif	
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  CODIGO NCM DO PRODUTO - SB1->B1_POSIPI (LINHA 1)  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  INFORMACAO "CHUMBADA"  (LINHA 1)                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//	@ nLin,015 PSAY ""
//	nLin++
	ImpMenx()

Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³  IMPDET  º Autor ³ Hoeste Morelandes  º Data ³  12/05/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Impressao de Linhas de Detalhe da Nota Fiscal              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso      ³ AP8 - ESPECIFICO -                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio da Funcao    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function IMPDET()

Local nLoop1 := 0

If mv_par04 == 2
	For nLoop1 := (nForAtu-1)*nTamDet+1 To Min(Len(aItens),nForAtu*nTamDet)
		If aItens[nLoop1,16] == 0 // aServico
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Só imprime os demais dados se não for a linha prinicpal do produto ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            @ nLin, 000 PSAY ALLTRIM(Left(aItens[nLoop1,01],14)) //Codigo
            @ nLin, 013 Psay ALLTRIM(aItens[nLoop1,02]) //  Descricao
          //  @ nlin, 056 Psay ALLTRIM(aItens[nLoop1,12]) 
			If !Empty(aItens[nLoop1,02])
				//if !empty(aItens[nLoop1,03])
				  //	@ nLin,055 PSAY alltrim(aItens[nLoop1,03])						// CLAS.FISCAL
				//endif                                           
				if !empty (aItens[nLoop1,15])
					@ nLin,063 PSAY alltrim(aItens[nLoop1,15])                          // CLAS.FISCAL (NCM)
				endif	
				@ nLin,073 PSAY ALLTRIM(aItens[nLoop1,04])							// Sit. Tribut.
				@ nLin,078 PSAY ALLTRIM(aItens[nLoop1,05])	   						// Unidade
                If aItens[nLoop1,08] > 0
//   				   @ nLin,079 PSAY Transform(aItens[nLoop1,06],"@E 999,999.99")		// Qtde. alterado 13/08				
   				   @ nLin,079 PSAY Transform(aItens[nLoop1,06],"@E 999,999.99")		    // Qtde. alterado 13/08				
				   @ nLin,093 PSAY Transform(aItens[nLoop1,07],"@E 999,999.99") 		// Preco Unit.
				   @ nLin,105 PSAY TRANSFORM(aItens[nLoop1,08],"@E 999,999,999.99")		// Preco Total
				   @ nLin,122 PSAY TRANSFORM(aItens[nLoop1,09],"@E 99")				// ICMS (%)
				   If aItens[nLoop1,10] >0
					   @ nLin,127 PSAY Transform(aItens[nLoop1,10],"@E 99")				// IPI (%)
					   @ nLin,130 PSAY Transform(aItens[nLoop1,11],"@E 99,999.99")  		// Valor do IPI
				   EndIf   
				Endif   
			EndIf
			nLin++                     
//	            @ nLIN ,010 PSAY ALLTRIM("Lote:"+SUBSTR(aItens[nLoop1,13],1,10)+space(01)+ "Validade:"+RTRIM(DTOC(aItens[nLoop1,17])))	//Lote + VALIDADE			
//			endif
		Endif
	Next
Else
	For nLoop1 := (nForAtu-1)*nTamDet+1 To Min(Len(aItens),nForAtu*nTamDet)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Só imprime os demais dados se não for a linha prinicpal do produto ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ nLin, 000 PSAY ALLTRIM(Left(aItens[nLoop1,01],14)) // Codigo 
		@ nLin, 013 psay ALLTRIM(aItens[nLoop1,02])	//Descricao 
        //@ nlin, 056 Psay ALLTRIM(aItens[nLoop1,12]) 		
		If !Empty(aItens[nLoop1,01])
			@ nLin,063 PSAY ALLTRIM(aItens[nLoop1,15])								// CLAS.FISCAL
			@ nLin,074 PSAY ALLTRIM(aItens[nLoop1,04])								// Sit. Tribut.
			@ nLin,078 PSAY ALLTRIM(aItens[nLoop1,05])		           				// Unidade
			@ nLin,081 PSAY ALLTRIM(Transform(aItens[nLoop1,06],"@E 999,999.99"))// Qtde.
			@ nLin,097 PSAY ALLTRIM(Transform(aItens[nLoop1,07],"@E 999,999.99")) 	// Preco Unit.
			@ nLin,105 PSAY ALLTRIM(TRANSFORM(aItens[nLoop1,08],"@E 999,999,999.99"))	// Preco Total
			@ nLin,122 PSAY ALLTRIM(TRANSFORM(aItens[nLoop1,09],"@E 99"))				// ICMS (%)
				   If aItens[nLoop1,10] >0
					   @ nLin,128 PSAY Transform(aItens[nLoop1,10],"@E 99")				// IPI (%)
					   @ nLin,131 PSAY Transform(aItens[nLoop1,11],"@E 99,999.99")  		// Valor do IPI
			       Endif   
		EndIf
		nLin++        

//        if !empty(aItens[nLoop1,13])
//            @ nLIN ,010 PSAY ALLTRIM("Lote:"+SUBSTR(aItens[nLoop1,13],1,10)+space(01)+ "Validade:"+RTRIM(DTOC(aItens[nLoop1,14])))	//Lote + VALIDADE			
//		endif

	Next
Endif

Return(nLoop1)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ImpServ  ºAutor  ³ Hoeste Morelandes  º Data ³  19/05/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprime itens da nota fiscal                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpServ()
Local nLoop1 := 0

If nForAtu == nFormul
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Só imprime os demais dados se não for a linha prinicpal do produto ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ nLin ,001 PSAY aServico[01,01]+ "- " + aServico[01,02]	// Codigo + Descricao
	@ nLin ,090 PSAY aServico[01,07] Picture "@E 9,999.99"	// Valor de ISS do Item
		nLin += 2                                                                                
	@ nLin ,086 PSAY Transform(aServico[01,06],"@E 999,999.99")// Valor Total de ISS da NF
Endif 

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ DUPLIC   º Autor ³ Osmil Squarcine    º Data ³  07/07/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Impressao do Parcelamento das Duplicacatas                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso      ³ AP8 - ESPECIFICO - K A P                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DUPLIC()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio da Funcao    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local BB, _nj, _nK, _nI

nCol := 7
nAjuste := 0

_aDupli := {}

For _nj := 1 to Len(xVALOR_DUP)

	If Len(xValor_DUP) <= 6
	
		_nPos := Ascan(_aDupli,{|x| x[1]=SF2->F2_DUPL .AND. X[2]=xPARC_DUP[_nj] .AND. x[3]=xVENC_DUP[_nj] .AND. x[4]=xVALOR_DUP[_nj]})
		
		If _nPos == 0
			Aadd(_aDupli,{SF2->F2_DUPL, xPARC_DUP[_nj], xVENC_DUP[_nj], xVALOR_DUP[_nj]})
		Endif
	
	EndIf	
next _nj

For _nK  := 1 To 3   // Coluna do Vetor
	
	_nColIni  := 17   // Dado na primeira coluna
	
	// Os dados serao impressos em 24, 49, 73, 97 e 121.
	// 25 espacos entre cada coluna.
	_nProxima := 21
	
	For _ni  := 1 to Len(_aDupli)
		_cDado := ""
		
		Do Case
			Case _nK == 1   // Primeira vez imprime Titulo e Prefixo
				_cDado := _aDupli[_ni,1] + _aDupli[_ni,2]
			Case _nK == 2   // Segunda vez imprime o vencimento
				_cDado := _aDupli[_ni,3]
			OtherWise       // Terceira vez imprime o valor
				_cDado := Transform(_aDupli[_ni,4],"@E 9,999,999.99")
		EndCase
		
		@ nLin, _nColIni  PSAY _cDado
		
		_nColIni += _nProxima
		
	Next _ni
	
	nLin++
	
Next _nK



/*Local BB
nCol := 07
nAjuste := 0

For BB:= 1 to Len(xVALOR_DUP)
	If xDUPLICATAS == .T. .and. BB <= 6 //Len(xVALOR_DUP)
		@ nLin, 012 + nAjuste PSAY xPARC_DUP[BB]
		@ nLin, 020 + nAjuste PSAY xVENC_DUP[BB]
		@ nLin, 038 + nAjuste PSAY ALLTRIM(TRANSFORM(xVALOR_DUP[BB] ,"@E 9,999,999.99"))

		nAjuste := nAjuste + 44
		
		If nAjuste > 131
			nLin    += 1
			nAjuste := 0
		EndIf	  

	Endif
Next
*/
Return
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Funcao       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ