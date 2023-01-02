#include "rwmake.ch"
#include "protheus.ch"

/*/

———————————————————————————————————————————————————————————————————————————————
@function		BCTBR03                                                      /@
@type			Relatório                                                    /@
@date			13/09/2014                                                   /@
@description	Emite relatório de conciliação do contas à pagar x contábil  /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Especifico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————

/*/
User Function BCTBR03()
Local aRegs			:= {}   
Local aCabSX1		:= {"X1_GRUPO", "X1_ORDEM", "X1_PERGUNT", "X1_VARIAVL", "X1_TIPO", "X1_TAMANHO", "X1_DECIMAL", "X1_GSC", "X1_VAR01", "X1_F3", "X1_VALID", "X1_DEF01", "X1_DEF02"}
Local aHlp01		:= {"Informe o mês da data de referência", 	"inicial. Permitido números entre 1 e 12."}
Local aHlp02		:= {"Informe o ano da data de referência", 	"inicial. Permitido números entre 1980 e", 	"2049."}
Local aHlp03		:= {"Emite todos os registros ou somente",	"os que apresentarem divergência entre o",	"kardex e contabilidade?"}
Private cPerg		:= PadR("BCTBR03", Len(SX1->X1_GRUPO))
Private cDesc1 		:= "Emite relatorio de conciliação contábil com registros do contas à pagar e suas baixas. Específico Brasitech"
Private cDesc2 		:= ""
Private cDesc3 		:= ""
Private cTamanho   	:= "M"
Private nTipo      	:= 15
Private nLastKey   	:= 0
Private aReturn    	:= {"Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private cNomeprog  	:= "BCTBR03"
Private cTitulo    	:= AllTrim(SM0->M0_NOME) + " - " + "Conciliação contas à pagar x contábil - " + AllTrim(SM0->M0_FILIAL) + " (" + SM0->M0_CODFIL + ")"
Private nLin       	:= 80
Private cString    	:= "CT2"
//——————————————————————————————————————————————————————————————————————————
// Variaveis utilizadas para impressao do cabecalho e rodape           
//——————————————————————————————————————————————————————————————————————————
Private cbtxt      	:= "BRASITECH"
Private cbcont     	:= 0
Private m_pag      	:= 1
Private cCabec1		:= "Resumo estatístico"
Private cCabec2		:= "."

if CT1->(FieldPos("CT1_X_CONC")) == 0
	Help(" ", 1, "ATENÇÃO",, "O relatório não será impresso pois o plano de contas não possui o campo classificador (CT1_X_CONC) de conciliação contábil." + chr(13) + chr(10) + "(Específico Brasitech).", 1)
	Return()
endif

aAdd(aRegs, {cPerg, "01", "Do mês de emissão ?           ", "mv_ch1", "N", 02, 0, "G",	"mv_par01", "",		"",		"",			""})
aAdd(aRegs, {cPerg, "02", "Do ano de emissão ?           ", "mv_ch2", "N", 04, 0, "G",	"mv_par02", "",		"",	"",			""})
aAdd(aRegs, {cPerg, "03", "Emite quais registros ?       ", "mv_ch3", "N", 01, 0, "C",	"mv_par03", "",		"", 														"1-Todos",	"2-Divergência"})

U_BRASX1(aRegs, aCabSX1)

PutSX1Help("P." + AllTrim(cPerg) + "01.", aHlp01, aHlp01, aHlp01)
PutSX1Help("P." + AllTrim(cPerg) + "02.", aHlp02, aHlp02, aHlp02)
PutSX1Help("P." + AllTrim(cPerg) + "03.", aHlp03, aHlp03, aHlp03)

Pergunte(cPerg,.F.)

//——————————————————————————————————————————————————————————————————————————
// Envia controle para a funcao SETPRINT 
//——————————————————————————————————————————————————————————————————————————
wnrel 	:= SetPrint(cString, cNomeProg, cPerg, @cTitulo, cDesc1, cDesc2, cDesc3, .F., , .F., cTamanho, , .F.)
	
if nLastKey != 27

	//——————————————————————————————————————————————————————————————————————————
	// Verifica Posicao do Formulario na Impressora 
	//——————————————————————————————————————————————————————————————————————————
	SetDefault(aReturn, cString)
	
	//——————————————————————————————————————————————————————————————————————————
	// Inicio da Impressao                          
	//——————————————————————————————————————————————————————————————————————————
	RptStatus({ || SelecRel() }, cTitulo)

endif
Return()


/*/

———————————————————————————————————————————————————————————————————————————————
@function		SelecRel                                                     /@
@type			Static function                                              /@
@date			13/09/2014                                                   /@
@description	Chamado pela user function BCTBR01. Processa e imprime as 
				informações do relatório de conciliação entre a contábilidade
				e o kardex.
				MATA250	666	Saída - Movimentos (Requisição de Produtos)
				MATA240	668	Entrada - Movim Int (Dev. Produção/Dev. Produtos)
				MATA260	670	Transferência Origem  (Movimentos no Stock)
						672	Transferência Destino (Movimentos no Stock)
				MATA340	676	Entrada - Inventário On Line
						674	Saída    - Inventário On Line
				MATA330	679	Devol. Autom.Material de Apropr. Indireta
						680	Requis. Autom.Material de Apropr.  Indireta
				MATA103 640	ITENS DA NOTA FISCAL DE ENTRADA - DEV.  
						641	Documento de Entrada - Inclusão de Docum
						650	ITENS NOTA FISCAL DE ENTRADA            
						651	ITENS DA NOTA FISCAL DE ENTRADA - RATEIO
						655	ITENS NOTA FISCAL DE ENTRADA            
						656	ITENS NOTA FISCAL DE ENTRADA            
				MATA460 678	CUSTO DA MERCADORIA DE VENDAS           
						610	ITENS DA NOTA FISCAL DE SAIDA           
						630	CANCELAMENTO ITENS NF SAIDA                      /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Especifico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————

/*/
Static Function SelecRel()
Local nLin 				:= 80
Local lAll				:= (mv_par03 == 1)
Local lContinua			:= .T.
Local aCampos			:= {{"CTRL",		"C", 001, 0},;
							{"FILIAL",		"C", 002, 0},;
							{"P_TPMOV",		"C", 010, 0},;
							{"P_DTMOV",		"D", 008, 0},;
							{"P_PREFIXO",	"C", 003, 0},;
							{"P_NUM",		"C", 009, 0},;
							{"P_PARCELA",	"C", 001, 0},;
							{"P_TIPO",		"C", 003, 0},;
							{"P_TIPODOC",	"C", 002, 0},;
							{"P_SEQ",		"C", 002, 0},;
							{"P_DOCUMEN",	"C", 050, 0},;
							{"P_HISTOR",	"C", 100, 0},;
							{"P_BANCO",		"C", 003, 0},;
							{"P_AGENCIA",	"C", 005, 0},;
							{"P_CTACOR",	"C", 010, 0},;
							{"P_FORNECE",	"C", 008, 0},;
							{"P_LOJA",		"C", 002, 0},;
							{"P_NREDUZ",	"C", 020, 0},;
							{"P_DOC",		"C", 009, 0},;
							{"P_SERIE",		"C", 003, 0},;
							{"P_PRODUTO",	"C", 015, 0},;
							{"P_ITEM",		"C", 004, 0},;
							{"P_VALOR",		"N", 012, 2},;
							{"L_DTLCT",		"D", 008, 0},;
							{"L_LOTE",		"C", 006, 0},;
							{"L_SBLOTE",	"C", 003, 0},;
							{"L_DOC",		"C", 006, 0},;
							{"L_LINHA",		"C", 003, 0},;
							{"L_DEBITO",	"C", 020, 0},;
							{"L_CREDITO",	"C", 020, 0},;
							{"L_VALOR",		"N", 012, 2},;
							{"L_HISTOR",	"C", 240, 0},;
							{"L_LP",		"C", 003, 0},;
							{"L_ROTINA",	"C", 010, 0},;
							{"L_ORIGEM",	"C", 100, 0},;
							{"L_KEY",		"C", 200, 0},;
							{"L_CCDEB",		"C", 009, 0},;
							{"L_CCCRD",		"C", 009, 0},;
							{"L_ITDEB",		"C", 009, 0},;
							{"L_ITCRD",		"C", 009, 0},;
							{"L_CLDEB",		"C", 009, 0},;
							{"L_CLCRD",		"C", 009, 0}}
Local cArqTRB			:= CriaTrab(aCampos, .T.)
Local cIndex1			:= CriaTrab(Nil, .F.)
Local cIndex2			:= CriaTrab(Nil, .F.)
Local cIndex3			:= CriaTrab(Nil, .F.)
Local dDtIni 			:= cTOd("01/" + StrZero(mv_par01,2) + "/" + StrZero(mv_par02,4))
Local dDtFim			:= LastDay(dDtIni)
Local nNumSD1			:= 0
Local nNumSD2			:= 0
Local nNumSE1			:= 0
Local nNumSE5			:= 0
Local nNumCT2			:= 0
Local nSD1xCT2			:= 0	//NF devolucao x lcto ctb
Local nSD2xCT2			:= 0	//NF venda x lcto ctb
Local nSE1xCT2			:= 0	//NF titulos provisionados x lcto ctb
Local nSE5xCT2			:= 0	//baixas e movim.financeiros x lcto ctb
Local nCT2xMov			:= 0
Local nCT2xMovOK		:= 0
Local aLP	 			:= {	"INCLUSÃO MANUAL DE TITULOS À PAGAR",;
								"510 - Ao gravar Contas a Pagar                                   - FINA050",;
								"511 - Ao gravar Contas a Pagar - Rateio                          - FINA050",;
								"513 - Ao gravar Contas a Pagar - Títulos do tipo PA              - FINA050",;
								"514 - Cancelamento de Contas a Pagar - Títulos do tipo PA        - FINA050",;
								"515 - Cancelamento de Contas a Pagar                             - FINA050",;
								"",;
								"BAIXAS DE TÍTULOS À PAGAR",;
								"530 - Baixas - Contas a Pagar                                    - FINA080",;
								"531 - Cancelamento de Baixas a Pagar                             - FINA080",;
								"532 - Baixa por Borderô de Pagamento                             - FINA090",;
								"597 - Compensação Antecipação - CP                               - FINA340",;
								"589 - Cancelamento Compensação - CP                              - FINA340",;
								"",;
								"NOTA FISCAL DE ENTRADA",;
								"650 - Inclusão de nfe por ítem                                   - MATA103",;
								"655 - Exclusão de nfe por ítem                                   - MATA103",;
								"",;
								"NOTA FISCAL DE SAÍDA",;
								"610 - Inclusão de nota fiscal de saída por ítem                  - MATA460",;
								"630 - Exclusão de nota fiscal de saída por ítem                  - MATA520"	}
Local cTituloExcel		:= cTitulo
Local cWorkPar			:= "Parâmetros"
Local cWorkPlan 		:= "Relatório"
Local cFrTitCor	 		:= "#666666"	//Cinza nas letras do titulo
Local cBgTitCor			:= "#FFFFFF"	//Branco no fundo do titulo
Local cFrCabCor			:= "#FFFFFF"	//Branco nas letras do cabecalho
Local cBgCabCor			:= "#1F2731"	//Azul escuro no fundo do cabecalho
Local cFrLinCor			:= "#000000"	//Preto nas letras da linha detalhe
Local cBgLinCor			:= "#E0F0F0"	//Branco no fundo da linha detalhe
Local cFrLin2Cor		:= "#000000"	//Preto nas letras da linha alternada detalhe
Local cBgLin2Cor		:= "#BCD2EE"	//Azul claro no fundo da linha alternada detalhe
Local nLeftAlign		:= 1
Local nCenterAlign		:= 2
Local nRightAlign		:= 3
Local nGeneralFormat	:= 1
Local nNumberFormat		:= 2                                                  	
Local nCurrencyFormat	:= 3
Local nDateFormat		:= 4
Local cDiverg, nK, aBaixas, cChvPesq, oExcel, oFWExcel, cArq, cConteudo, aPlanilha, aPerg
/*
"562	Movimento Bancário - a Pagar              - FINA100",;
"563	Movimento Bancário - a Receber              - FINA100",;
"564	Cancelamento de Movimentos Bancários - Pagar              - FINA100",;
*/

SetRegua(10)

SA2->(dbSetOrder(1))

IncRegua("Cria arquivo temporário")
dbUseArea(.T.,, cArqTrb, "TRB", .T.)
dbSelectArea("TRB")
IndRegua("TRB", cIndex1, "CTRL+FILIAL+P_PREFIXO+P_NUM+P_PARCELA+P_TIPO+P_FORNECE+P_LOJA",,, "Selecionando Registros...")
IndRegua("TRB", cIndex2, "CTRL+FILIAL+P_TIPODOC+P_PREFIXO+P_NUM+P_PARCELA+P_TIPO+dTOs(P_DTMOV)+P_FORNECE+P_LOJA+P_SEQ",,, "Selecionando Registros...")
IndRegua("TRB", cIndex3, "CTRL+FILIAL+P_DOC+P_SERIE+P_FORNECE+P_LOJA+P_PRODUTO+P_ITEM",,, "Selecionando Registros...")
Set Index to &cIndex1, &cIndex2, &cIndex3

//——————————————————————————————————————————————————————————————————————————
// 2- Seleciono notas de compras e gravo na tabela de trabalho
//——————————————————————————————————————————————————————————————————————————
IncRegua("Selecionando notas de entrada...")
cQuery := "SELECT D1_FILIAL, D1_DTDIGIT, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_TOTAL, D1_VALIPI, D1_ICMSRET, D1_VALDESC, D1_COD, D1_ITEM "
cQuery += "FROM " + RetSqlName("SD1") + " SD1, " + RetSqlName("SF1") + " SF1 "
cQuery += "WHERE SD1.D1_FILIAL = '" + xFilial("SD1") + "' "
cQuery += 		"AND SD1.D1_DTDIGIT BETWEEN '" + dTOs(dDtIni) + "' AND '" + dTOs(dDtFim) + "' "
cQuery += 		"AND SD1.D1_ORIGLAN <> 'LF' "
cQuery += 		"AND SD1.D1_TIPO NOT IN ('B','D') "
cQuery += 		"AND SD1.D_E_L_E_T_ = ' ' "
cQuery += 		"AND SF1.F1_FILIAL = '" + xFilial("SF1") + "' "
cQuery += 		"AND SF1.F1_DOC = SD1.D1_DOC "
cQuery += 		"AND SF1.F1_SERIE = SD1.D1_SERIE "
cQuery += 		"AND SF1.F1_FORNECE = SD1.D1_FORNECE "
cQuery += 		"AND SF1.F1_LOJA = SD1.D1_LOJA "
cQuery += 		"AND SF1.F1_DUPL != ' ' "
cQuery += 		"AND SF1.D_E_L_E_T_ = ' '"

if Select("TEMP") > 0
	TEMP->(dbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TcGenQry(,,ChangeQuery(cQuery)), "TEMP", .F., .T.)
tcSetField("TEMP", "D1_DTDIGIT", "D")

dbSelectArea("TEMP")
dbGoTop()
do while TEMP->(!eof())
   
	SA2->(dbSeek(xFilial("SA2") + TEMP->(D1_FORNECE + D1_LOJA)))

	TRB->(RecLock("TRB", .T.))
	TRB->CTRL		:= "1"
	TRB->FILIAL		:= TEMP->D1_FILIAL
	TRB->P_DOC		:= TEMP->D1_DOC
	TRB->P_SERIE	:= TEMP->D1_SERIE
	TRB->P_FORNECE	:= TEMP->D1_FORNECE
	TRB->P_LOJA		:= TEMP->D1_LOJA
	TRB->P_PRODUTO	:= TEMP->D1_COD
	TRB->P_ITEM		:= TEMP->D1_ITEM
	TRB->P_DTMOV	:= TEMP->D1_DTDIGIT	
	TRB->P_VALOR	:= TEMP->(D1_TOTAL + D1_VALIPI + D1_ICMSRET - D1_VALDESC)
	TRB->P_NREDUZ	:= SA2->A2_NREDUZ
	TRB->P_TPMOV	:= "PROV.NF"
	TRB->(MsUnlock())

	nNumSD1++
	
	TEMP->(dbSkip())
	
enddo


//——————————————————————————————————————————————————————————————————————————
// 3- Seleciono notas de devolução de compras e gravo na tabela de trabalho
//——————————————————————————————————————————————————————————————————————————
IncRegua("Selecionando notas de saída...")
cQuery := "SELECT D2_FILIAL, D2_EMISSAO, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_VALBRUT, D2_COD, D2_ITEM "
cQuery += "FROM " + RetSqlName("SD2") + " SD2, " + RetSqlName("SF2") + " SF2 "
cQuery += "WHERE SD2.D2_FILIAL = '" + xFilial("SD2") + "' "
cQuery += 		"AND SD2.D2_EMISSAO BETWEEN '" + dTOs(dDtIni) + "' AND '" + dTOs(dDtFim) + "' "
cQuery += 		"AND SD2.D2_ORIGLAN <> 'LF' "
cQuery += 		"AND SD2.D2_TIPO IN ('B','D') "
cQuery += 		"AND SD2.D_E_L_E_T_ = ' ' "
cQuery += 		"AND SF2.F2_FILIAL = '" + xFilial("SF2") + "' "
cQuery += 		"AND SF2.F2_DOC = SD2.D2_DOC "
cQuery += 		"AND SF2.F2_SERIE = SD2.D2_SERIE "
cQuery += 		"AND SF2.F2_CLIENTE = SD2.D2_CLIENTE "
cQuery += 		"AND SF2.F2_LOJA = SD2.D2_LOJA "
cQuery += 		"AND SF2.F2_DUPL != ' ' "
cQuery += 		"AND SF2.D_E_L_E_T_ = ' '"

if Select("TEMP") > 0
	TEMP->(dbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TcGenQry(,,ChangeQuery(cQuery)), "TEMP", .F., .T.)
tcSetField("TEMP", "D2_EMISSAO", "D")

dbSelectArea("TEMP")
dbGoTop()
do while TEMP->(!eof())

	SA2->(dbSeek(xFilial("SA2") + TEMP->(D2_CLIENTE + D2_LOJA)))

	TRB->(RecLock("TRB", .T.))
	TRB->CTRL		:= "2"
	TRB->FILIAL		:= TEMP->D2_FILIAL
	TRB->P_DOC		:= TEMP->D2_DOC
	TRB->P_SERIE	:= TEMP->D2_SERIE
	TRB->P_FORNECE	:= TEMP->D2_CLIENTE
	TRB->P_LOJA		:= TEMP->D2_LOJA
	TRB->P_PRODUTO	:= TEMP->D2_COD
	TRB->P_ITEM		:= TEMP->D2_ITEM
	TRB->P_DTMOV	:= TEMP->D2_EMISSAO	
	TRB->P_VALOR	:= TEMP->D2_VALBRUT
	TRB->P_NREDUZ	:= SA2->A2_NREDUZ
	TRB->P_TPMOV	:= "PROV.NF"
	TRB->(MsUnlock())

	nNumSD2++
	
	TEMP->(dbSkip())
	
enddo


//——————————————————————————————————————————————————————————————————————————
// 4- Seleciono os títulos manuais de pagamentos e gravo na tabela de 
//    trabalho
//——————————————————————————————————————————————————————————————————————————
IncRegua("Selecionando movimentos internos...")
cQuery := "SELECT E2_FILIAL, E2_EMISSAO, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_VALOR "
cQuery += "FROM " + RetSqlName("SE2") + " SE2 "
cQuery += "WHERE SE2.E2_FILIAL = '" + xFilial("SE2") + "' "
cQuery += 		"AND SE2.E2_EMISSAO BETWEEN '" + dTOs(dDtIni) + "' AND '" + dTOs(dDtFim) + "' "
cQuery += 		"AND SE2.E2_ORIGEM NOT IN ('MATA100', 'MATA460') "
cQuery += 		"AND SE2.D_E_L_E_T_ = ' ' "

if Select("TEMP") > 0
	TEMP->(dbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TcGenQry(,,ChangeQuery(cQuery)), "TEMP", .F., .T.)
tcSetField("TEMP", "E2_EMISSAO", "D")

dbSelectArea("TEMP")
dbGoTop()
do while TEMP->(!eof())

	SA2->(dbSeek(xFilial("SA2") + TEMP->(E2_FORNECE + E2_LOJA)))

	TRB->(RecLock("TRB", .T.))
	TRB->CTRL		:= "3"
	TRB->FILIAL		:= TEMP->E2_FILIAL
	TRB->P_FORNECE	:= TEMP->E2_FORNECE
	TRB->P_LOJA		:= TEMP->E2_LOJA
	TRB->P_PREFIXO	:= TEMP->E2_PREFIXO
	TRB->P_NUM		:= TEMP->E2_NUM
	TRB->P_PARCELA	:= TEMP->E2_PARCELA
	TRB->P_TIPO		:= TEMP->E2_TIPO
	TRB->P_DTMOV	:= TEMP->E2_EMISSAO
	TRB->P_NREDUZ	:= TEMP->E2_NOMFOR
	TRB->P_VALOR	:= TEMP->E2_VALOR
	TRB->P_NREDUZ	:= SA2->A2_NREDUZ
	TRB->P_TPMOV	:= "PROV.TIT"	
	TRB->(MsUnlock())

	nNumSE1++
	
	TEMP->(dbSkip())
	
enddo


//——————————————————————————————————————————————————————————————————————————
// 5- Seleciono as baixas de receb`imentos e gravo na tabela de trabalho
//——————————————————————————————————————————————————————————————————————————
IncRegua("Selecionando movimentos internos...")

cQuery := "SELECT E5_FILIAL, E5_TIPODOC, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_DATA, E5_CLIFOR, "
cQuery +=       "E5_LOJA, E5_SEQ, E5_BANCO, E5_AGENCIA, E5_CONTA, E5_DOCUMEN, E5_HISTOR, E5_VALOR "
cQuery += "FROM " + RetSqlName("SE5")+" SE5 "
cQuery += "WHERE SE5.E5_FILIAL = '" + xFilial("SE5") + "' "
cQuery +=       "AND SE5.E5_RECPAG = 'P' "
cQuery +=       "AND SE5.E5_DATA BETWEEN '" + dTOs(dDtIni) + "' AND '" + dTOs(dDtFim) + "' "
cQuery +=       "AND SE5.E5_TIPODOC NOT IN ('DC','D2','JR','J2','TL','MT','M2','CM','C2','TR','TE','E2') "
cQuery +=       "AND SE5.E5_VALOR > 0 "

cQuery +=       "AND SE5.E5_SITUACA NOT IN ('C','E','X') "
cQuery +=       "AND ((SE5.E5_TIPODOC = 'CD' AND SE5.E5_VENCTO <= SE5. E5_DATA) OR SE5.E5_TIPODOC <> 'CD') "
cQuery +=       "AND SE5.E5_HISTOR NOT LIKE '%Baixa Automatica / Lote%' "

cQuery +=   "AND SE5.E5_TIPODOC <> ' ' "
cQuery +=   "AND SE5.E5_NUMERO  <> ' ' "
cQuery +=   "AND SE5.E5_TIPODOC <> 'CH' "

cQuery +=       "AND SE5.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY E5_FILIAL, E5_TIPODOC, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_DATA , E5_CLIFOR, E5_LOJA, E5_SEQ"

if Select("TEMP") > 0
	TEMP->(dbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TCGenQry(,,ChangeQuery(cQuery)), "TEMP", .F., .T.)
TCSetField("TEMP", "E5_DATA", "D", 8, 0)

dbSelectArea("TEMP")
dbGoTop()
do while TEMP->(!eof())

	SA2->(dbSeek(xFilial("SA2") + TEMP->(E5_CLIFOR + E5_LOJA)))
	
	TRB->(RecLock("TRB", .T.))
	TRB->CTRL		:= "4"
	TRB->FILIAL		:= xFilial("SE5")
	TRB->P_TIPODOC	:= TEMP->E5_TIPODOC
	TRB->P_PREFIXO	:= TEMP->E5_PREFIXO
	TRB->P_NUM		:= TEMP->E5_NUMERO
	TRB->P_PARCELA	:= TEMP->E5_PARCELA
	TRB->P_TIPO		:= TEMP->E5_TIPO
	TRB->P_DTMOV	:= TEMP->E5_DATA
	TRB->P_FORNECE	:= TEMP->E5_CLIFOR
	TRB->P_LOJA		:= TEMP->E5_LOJA
	TRB->P_SEQ		:= TEMP->E5_SEQ
	TRB->P_BANCO	:= TEMP->E5_BANCO
	TRB->P_AGENCIA	:= TEMP->E5_AGENCIA
	TRB->P_CTACOR	:= TEMP->E5_CONTA
	TRB->P_NREDUZ	:= SA2->A2_NREDUZ
	TRB->P_DOCUMEN	:= TEMP->E5_DOCUMEN
	TRB->P_HISTOR	:= TEMP->E5_HISTOR
	TRB->P_VALOR	:= TEMP->E5_VALOR
	TRB->P_TPMOV	:= "BAIXA"
	TRB->(MsUnlock())
	
	nNumSE5++
	
	TEMP->(dbSkip())
	
enddo


//——————————————————————————————————————————————————————————————————————————
// 6- Seleciono os lançamentos contábeis referentes ao contas à pagar e 
//    gravo na tabela de trabalho
//——————————————————————————————————————————————————————————————————————————
IncRegua("Selecionando lançamentos contábeis...")
cQuery := "SELECT CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_DEBITO, CT2_CREDIT, CT2_VALOR, CT2_HIST, "
cQuery += 		 "CT2_CCD, CT2_CCC, CT2_ITEMD, CT2_ITEMC, CT2_CLVLDB, CT2_CLVLCR, CT2_ORIGEM, CT2_ROTINA, CT2_LP, CT2_SEQLAN, CT2_KEY "
cQuery += "FROM " + RetSqlName("CT2") + " CT2, " + RetSqlName("CT1") + " CT1 "
cQuery += "WHERE CT2.CT2_FILIAL = '" + xFilial("CT2") + "' "
cQuery += 		"AND CT2.CT2_DATA BETWEEN '" + dTOs(dDtIni) + "' AND '" + dTOs(dDtFim) + "' "
cQuery += 		"AND CT2.CT2_MOEDLC = '01' "
cQuery += 		"AND CT2.CT2_TPSALD = '1' "
cQuery += 		"AND CT2.D_E_L_E_T_ = ' ' "
cQuery += 		"AND CT1.CT1_FILIAL = '" + xFilial("CT1") + "' "
cQuery += 		"AND (CT1.CT1_CONTA = CT2_DEBITO OR CT1.CT1_CONTA = CT2_CREDIT) "
cQuery += 		"AND CT1.CT1_X_CONC = '03' "	//Conciliacao do contas a receber
cQuery += 		"AND CT1.D_E_L_E_T_ = ' ' "
cQuery += "GROUP BY CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_DEBITO, CT2_CREDIT, CT2_VALOR, CT2_HIST, "
cQuery += 		 "CT2_CCD, CT2_CCC, CT2_ITEMD, CT2_ITEMC, CT2_CLVLDB, CT2_CLVLCR, CT2_ORIGEM, CT2_ROTINA, CT2_LP, CT2_SEQLAN, CT2_KEY "
cQuery += "ORDER BY CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA"

if Select("TEMP") > 0
	TEMP->(dbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TcGenQry(,,ChangeQuery(cQuery)), "TEMP", .F., .T.)
tcSetField("TEMP", "CT2_DATA", "D")

dbSelectArea("TEMP")
dbGoTop()
do while TEMP->(!eof())

	cHist	 	:= TEMP->CT2_HIST
	lNovo	 	:= .T.
	cChvPesq 	:= ""
	U_GetHist(dTOs(TEMP->CT2_DATA) + TEMP->CT2_LOTE + TEMP->CT2_SBLOTE + TEMP->CT2_DOC, TEMP->CT2_LINHA, @cHist)
	
	if TEMP->CT2_LP $ "510/511/513/514/515" .and. !Empty(TEMP->CT2_KEY)		//provisao de titulos
		TRB->(dbSetOrder(1))
		cChvPesq := "1" + Left(TEMP->CT2_KEY, Len(TRB->(FILIAL+P_FORNECE+P_LOJA+P_PREFIXO+P_NUM+P_PARCELA+P_TIPO)))
		lNovo	 := .T.
		if TRB->(dbSeek(cChvPesq)) .and. Empty(TRB->L_DTLCT)
			lNovo	 := .F.
		endif
		nSE1xCT2 += iif(!lNovo, 1, 0)

	elseif TEMP->CT2_LP $ "530/531/532/589/597" .and. !Empty(TEMP->CT2_KEY)		//baixa e cancelamento de baixas a receber e a pagar
		TRB->(dbSetOrder(2))
		cChvPesq := "2" + Left(TEMP->CT2_KEY, Len(TRB->(FILIAL+P_TIPODOC+P_PREFIXO+P_NUM+P_PARCELA+P_TIPO+dTOs(P_DTMOV)+P_FORNECE+P_LOJA+P_SEQ)))
		lNovo	 := .T.
		if TRB->(dbSeek(cChvPesq)) .and. Empty(TRB->L_DTLCT)
			lNovo	 := .F.
		endif
		nSE5xCT2 += iif(!lNovo, 1, 0)
		
	elseif TEMP->CT2_LP $ "610" .and. !Empty(TEMP->CT2_KEY)			//provisao de titulos por nota fiscal
		TRB->(dbSetOrder(3))
		cChvPesq := "1" + Left(TEMP->CT2_KEY, Len(TRB->(FILIAL+P_DOC+P_SERIE+P_FORNECE+P_LOJA+P_PRODUTO+P_ITEM)))
		lNovo	 := .T.
		if TRB->(dbSeek(cChvPesq)) .and. Empty(TRB->L_DTLCT)
			lNovo	 := .F.
		endif
		nSD2xCT2 += iif(!lNovo, 1, 0)

	elseif TEMP->CT2_LP $ "650" .and. !Empty(TEMP->CT2_KEY)		//devolução de vendas por nota fiscal
		TRB->(dbSetOrder(3))
		cChvPesq := "2" + Left(TEMP->CT2_KEY, Len(TRB->(FILIAL+P_DOC+P_SERIE+P_FORNECE+P_LOJA+P_PRODUTO+P_ITEM)))
		lNovo	 := .T.
		if TRB->(dbSeek(cChvPesq)) .and. Empty(TRB->L_DTLCT)
			lNovo	 := .F.
		endif
		nSD1xCT2 += iif(!lNovo, 1, 0)

	endif

	TRB->(RecLock("TRB", lNovo))
	TRB->CTRL		:= iif(lNovo, "9", TRB->CTRL)
	TRB->FILIAL		:= TEMP->CT2_FILIAL
	TRB->L_DTLCT	:= TEMP->CT2_DATA
	TRB->L_LOTE		:= TEMP->CT2_LOTE
	TRB->L_SBLOTE	:= TEMP->CT2_SBLOTE
	TRB->L_DOC		:= TEMP->CT2_DOC
	TRB->L_LINHA	:= TEMP->CT2_LINHA
	TRB->L_DEBITO	:= TEMP->CT2_DEBITO
	TRB->L_CREDITO	:= TEMP->CT2_CREDIT
	TRB->L_VALOR	:= TEMP->CT2_VALOR
	TRB->L_HISTOR	:= cHist
	TRB->L_LP		:= TEMP->CT2_LP
	TRB->L_ROTINA	:= TEMP->CT2_ROTINA
	TRB->L_ORIGEM	:= TEMP->CT2_ORIGEM
	TRB->L_KEY		:= TEMP->CT2_KEY
	TRB->L_CCDEB	:= TEMP->CT2_CCD
	TRB->L_CCCRD	:= TEMP->CT2_CCC
	TRB->L_ITDEB	:= TEMP->CT2_ITEMD
	TRB->L_ITCRD	:= TEMP->CT2_ITEMC
	TRB->L_CLDEB	:= TEMP->CT2_CLVLDB
	TRB->L_CLCRD	:= TEMP->CT2_CLVLCR
	
	if TEMP->CT2_LP $ "630/655/514/515"	.and. lNovo		//Lancamentos de exclusao. Gravo para não ocasionar divergencia de registro
		TRB->P_DTMOV	:= TEMP->CT2_DATA
		TRB->P_VALOR	:= TEMP->CT2_VALOR
		TRB->P_NUM		:= "CANC.DOC"
	endif
	TRB->(MsUnlock())

	nNumCT2++
	
	TEMP->(dbSkip())
	
enddo


//——————————————————————————————————————————————————————————————————————————
// 7- Seleciono as contas contábeis que pertencem ao grupo de conciliação
//    de contas à pagar. Emito a relação no relatorio estatistico
//——————————————————————————————————————————————————————————————————————————
IncRegua("Selecionando contas contábeis de contas a receber...")
cQuery := "SELECT CT1_CONTA, CT1_DESC01 "
cQuery += "FROM " + RetSqlName("CT1") + " CT1 "
cQuery += "WHERE CT1.CT1_FILIAL = '" + xFilial("CT1") + "' "
cQuery += 		"AND CT1.CT1_X_CONC = '03' "	//Conciliacao de contas a pagar
cQuery += 		"AND CT1.D_E_L_E_T_ = ' '"

if Select("TEMP") > 0
	TEMP->(dbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TcGenQry(,,ChangeQuery(cQuery)), "TEMP", .F., .T.)

//——————————————————————————————————————————————————————————————————————————
// 8- Gerando planilha Excel
//——————————————————————————————————————————————————————————————————————————
TRB->(dbGoTop())
if TRB->(!eof())
	IncRegua("Gerando planilha Excel...")
	
	//Cria objeto classe FWMsExcel
	oFWExcel:= FWMsExcel():New()

	//Definição de fonte, tamanho e cores
	oFWExcel:SetTitleFont("Calibri")
	oFWExcel:SetTitleSizeFont(11)
	oFWExcel:SetTitleBold(.T.)
	oFWExcel:SetTitleBgColor(cBgTitCor)
	oFWExcel:SetTitleFrColor(cFrTitCor)
	
	oFWExcel:SetHeaderFont("Calibri")
	oFWExcel:SetHeaderSizeFont(8)
	oFWExcel:SetHeaderBold(.T.)
	oFWExcel:SetBgColorHeader(cBgCabCor)
	oFWExcel:SetFrColorHeader(cFrCabCor)
	
	oFWExcel:SetLineFont("Calibri")
	oFWExcel:SetLineSizeFont(8)
	oFWExcel:SetLineBold(.F.)
	oFWExcel:SetLineBgColor(cBgLinCor)
	oFWExcel:SetLineFrColor(cFrLinCor)
	
	oFWExcel:Set2LineFont("Calibri")
	oFWExcel:Set2LineSizeFont(8)
	oFWExcel:Set2LineBold(.F.)
	oFWExcel:Set2LineBgColor(cBgLin2Cor)
	oFWExcel:Set2LineFrColor(cFrLin2Cor)

	//Pasta de parametros
	aPerg := U_GetSX1Excel(cPerg)
	if Len(aPerg) > 0
		oFWExcel:AddworkSheet(cWorkPar)
		oFWExcel:AddTable(cWorkPar, cTituloExcel)
		oFWExcel:AddColumn(cWorkPar, cTituloExcel, "Perguntas", 1)
		oFWExcel:AddColumn(cWorkPar, cTituloExcel, "Respostas", 1)
		for nK := 1 to Len(aPerg)
			oFWExcel:AddRow(cWorkPar, cTituloExcel, aPerg[nK])
		next
	endif

	//Pasta da planilha
	oFWExcel:AddworkSheet(cWorkPlan)
	oFWExcel:AddTable(cWorkPlan, cTituloExcel)

	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Filial", 					nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Dt.NF", 					nCenterAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Tp.Movim", 				nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Prefixo", 					nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Número", 					nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Parcela", 					nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Tipo", 					nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Fornecedor", 				nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Loja", 					nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Nome Fornecedor", 			nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Serie", 					nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Item", 					nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Produto", 					nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Tipo Doc", 				nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Sequencia", 				nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Doc.Chv.Baixa", 			nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Hist.Movim.Banco", 		nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Banco", 					nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Agência", 					nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Cta.Corrente", 			nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Valor", 					nRightAlign, 	nCurrencyFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Dt.Lancto", 				nCenterAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Lote", 					nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Sub-Lote", 				nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Doc.Contab.", 				nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Linha", 					nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Debito", 					nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Crédito", 					nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Valor", 					nRightAlign, 	nCurrencyFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Histórico do lançamento", 	nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "C.Custo Deb.", 			nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "C.Custo Crd.", 			nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Item Deb.", 				nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Item Crd.", 				nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Negócio Deb.", 			nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Negócio Crd.", 			nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "LP", 						nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Rotina", 					nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Origem", 					nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Chave", 					nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Divergência", 				nCenterAlign, 	nGeneralFormat, .f.)

	do while TRB->(!eof())

		cDiverg := ""

		//Somo contador de vinculo entre CT2 x Mov e de contador com valor OK
		if !Empty(TRB->P_DTMOV) .and. !Empty(TRB->L_DTLCT)
			nCT2xMov++
			if TRB->P_VALOR == TRB->L_VALOR
				nCT2xMovOK ++
			endif
		endif

		//Verificando se há divergencia
		if (Empty(TRB->P_DTMOV) .and. !Empty(TRB->L_DTLCT)) .or.;
		   (!Empty(TRB->P_DTMOV) .and. Empty(TRB->L_DTLCT)) .or.;
		   TRB->P_VALOR != TRB->L_VALOR
		   
			cDiverg := "*"
			
		endif

		//——————————————————————————————————————————————————————————————————————————
		// Gera informações para exportação para o Excel para todos os registros ou
		// ou somente os que tiverem divergência
		//——————————————————————————————————————————————————————————————————————————
		if lAll .or. (!lAll .and. !Empty(cDiverg))

			aPlanilha := {}

			aAdd(aPlanilha, TRB->FILIAL + "-" + AllTrim(SM0->M0_FILIAL))
			aAdd(aPlanilha, iif(Empty(TRB->P_DTMOV), " ", dTOc(TRB->P_DTMOV)))
			aAdd(aPlanilha, AllTrim(TRB->P_TPMOV))
			aAdd(aPlanilha, AllTrim(TRB->P_PREFIXO))
			aAdd(aPlanilha, AllTrim(TRB->P_NUM))
			aAdd(aPlanilha, AllTrim(TRB->P_PARCELA))
			aAdd(aPlanilha, AllTrim(TRB->P_TIPO))
			aAdd(aPlanilha, AllTrim(TRB->P_FORNECE))
			aAdd(aPlanilha, AllTrim(TRB->P_LOJA))
			aAdd(aPlanilha, AllTrim(TRB->P_NREDUZ))
			aAdd(aPlanilha, AllTrim(TRB->P_SERIE))
			aAdd(aPlanilha, AllTrim(TRB->P_ITEM))
			aAdd(aPlanilha, AllTrim(TRB->P_PRODUTO))
			aAdd(aPlanilha, AllTrim(TRB->P_TIPODOC))
			aAdd(aPlanilha, AllTrim(TRB->P_SEQ))
			aAdd(aPlanilha, AllTrim(TRB->P_DOCUMEN))
			aAdd(aPlanilha, AllTrim(TRB->P_HISTOR))
			aAdd(aPlanilha, AllTrim(TRB->P_BANCO))
			aAdd(aPlanilha, AllTrim(TRB->P_AGENCIA))
			aAdd(aPlanilha, AllTrim(TRB->P_CTACOR))
			aAdd(aPlanilha, NoRound(TRB->P_VALOR, 2))
			aAdd(aPlanilha, iif(Empty(TRB->L_DTLCT), " ", dTOc(TRB->L_DTLCT)))
			aAdd(aPlanilha, TRB->L_LOTE)
			aAdd(aPlanilha, TRB->L_SBLOTE)
			aAdd(aPlanilha, TRB->L_DOC)
			aAdd(aPlanilha, TRB->L_LINHA)
			aAdd(aPlanilha, AllTrim(TRB->L_DEBITO))
			aAdd(aPlanilha, AllTrim(TRB->L_CREDITO))
			aAdd(aPlanilha, NoRound(TRB->L_VALOR, 2))
			aAdd(aPlanilha, AllTrim(TRB->L_HISTOR))
			aAdd(aPlanilha, AllTrim(TRB->L_CCDEB))
			aAdd(aPlanilha, AllTrim(TRB->L_CCCRD))
			aAdd(aPlanilha, AllTrim(TRB->L_ITDEB))
			aAdd(aPlanilha, AllTrim(TRB->L_ITCRD))
			aAdd(aPlanilha, AllTrim(TRB->L_CLDEB))
			aAdd(aPlanilha, AllTrim(TRB->L_CLCRD))
			aAdd(aPlanilha, TRB->L_LP)
			aAdd(aPlanilha, TRB->L_ROTINA)
			aAdd(aPlanilha, TRB->L_ORIGEM)
			aAdd(aPlanilha, AllTrim(TRB->L_KEY))
			aAdd(aPlanilha, cDiverg)

			oFWExcel:AddRow(cWorkPlan, cTituloExcel, aPlanilha)

		endif
		
		TRB->(dbSkip())
		
	enddo
	
	//——————————————————————————————————————————————————————————————————————————
	// Inicia procedimentos para a gravação da planilha no formato XML
	//——————————————————————————————————————————————————————————————————————————
	if !ApOleClient("MSExcel")
		Help(" ", 1, "ATENCAO",, "O Microsoft Excel não está instalado, portanto não será possível exportar as informações do relatorio para o Excel." + chr(13) + chr(10) + "(Específico Brasitech). ", 1)
		lExcel := .F.
	else

		MakeDir("C:\TEMP")
		cArq  	:= "C:\TEMP\" + AllTrim(CriaTrab(NIL, .F.)) + ".XML"

		oFWExcel:Activate()
		oFWExcel:GetXMLFile(cArq)
		oFWExcel:DeActivate()
		
		if !file(cArq)
		
			Help(" ", 1, "ATENCAO",, "Não foi possível criar o arquivo temporário para a abertura do Excel, portanto portanto não será possível exportar as informações do relatório para o Excel." + chr(13) + chr(10) + "(Específico Brasitech). ", 1)
			
		else
		
			oExcel:= MsExcel():New()
			oExcel:WorkBooks:Open(cArq)
			oExcel:SetVisible(.T.)
			oExcel:Destroy()
		
		endif
		
		oFWExcel:=FreeObj(oFWExcel)
		
	endif

endif


//——————————————————————————————————————————————————————————————————————————
// 9- Imprimindo o relatório estatistico
//——————————————————————————————————————————————————————————————————————————
IncRegua("Imprimindo o relatório...")

nLin := Cabec(cTitulo, cCabec1, cCabec2, cNomeprog, cTamanho, 18) + 1

@ nLin++, 05 PSay "Quantidade de provisões de títulos NFE.: " + Transform(nNumSD1, "@E 999,999,999")
@ nLin++, 05 PSay "Quantidade de devoluções de compras NFS: " + Transform(nNumSD2, "@E 999,999,999")
@ nLin++, 05 PSay "Quantidade de provisões manuais........: " + Transform(nNumSE1, "@E 999,999,999")
@ nLin++, 05 PSay "Quantidade de baixas/movim. financeiros: " + Transform(nNumSE5, "@E 999,999,999")
@ nLin++, 05 PSay "Quantidade de lançamentos contábeis....: " + Transform(nNumCT2, "@E 999,999,999")
@ nLin++, 00 PSay __PrtThinLine()
@ nLin++, 05 PSay "% provisões tít. NFE com reg. contábil.: " + Transform((nSD1xCT2 / nNumSD2) * 100, "@E 999,999.99 %")
@ nLin++, 05 PSay "% devoluções compras NFe com reg.contáb: " + Transform((nSD2xCT2 / nNumSD1) * 100, "@E 999,999.99 %")
@ nLin++, 05 PSay "% provisões manuais com reg. contábil..: " + Transform((nSE1xCT2 / nNumSE1) * 100, "@E 999,999.99 %")
@ nLin++, 05 PSay "% baixas e mov.financ. com reg. contáb.: " + Transform((nSE5xCT2 / nNumSE5) * 100, "@E 999,999.99 %")
@ nLin++, 05 PSay "% de registros contábeis com origem....: " + Transform((nCT2xMov / nNumCT2) * 100, "@E 999,999.99 %") +;
				  ", sendo " + AllTrim(Transform((nCT2xMovOK / nNumCT2) * 100, "@E 999,999.99 %")) + " sem divergência de valor."
@ nLin++, 00 PSay __PrtThinLine()

nLin += 2

@ nLin++, 01 PSay "Relação das contas contábeis analisadas neste relatório"
@ nLin++, 01 PSay "======================================================="
do while TEMP->(!eof())
	if nLin > 60
		nLin := Cabec(cTitulo, cCabec1, cCabec2, cNomeprog, cTamanho, 18) + 1
	endif
	@ nLin,   01 PSay TEMP->CT1_CONTA
	@ nLin++, 22 PSay TEMP->CT1_DESC01
	TEMP->(dbSkip())
enddo

nLin += 2

@ nLin++, 01 PSay "Relação de lançamentos padrões referentes à contas à receber"
@ nLin++, 01 PSay "============================================================"
for nK := 1 to Len(aLP)
	if nLin > 60
		nLin := Cabec(cTitulo, cCabec1, cCabec2, cNomeprog, cTamanho, 18) + 1
	endif
	@ nLin++, 01 PSay aLP[nK]
next

Roda(CbCont, CbTxt, cTamanho)

//——————————————————————————————————————————————————————————————————————————
// Chama o Spool de Impressao para impressoes em Disco          
//——————————————————————————————————————————————————————————————————————————
If aReturn[5] == 1
   Set Printer To
   dbCommitAll()
   OurSpool(wnrel)
Endif

//——————————————————————————————————————————————————————————————————————————
// Libera o relatorio para Spool da Rede                        
//——————————————————————————————————————————————————————————————————————————
MS_FLUSH()

Set device to screen

//——————————————————————————————————————————————————————————————————————————
// Fecha a tabela temporaria e apaga arquivos temporarios criados
//——————————————————————————————————————————————————————————————————————————
TEMP->(dbCloseArea())
TRB->(dbCloseArea())
fErase(cArqTRB + GetDbExtension())
fErase(cIndex1 + OrdBagExt())
fErase(cIndex2 + OrdBagExt())
fErase(cIndex3 + OrdBagExt())
Return()
