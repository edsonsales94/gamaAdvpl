#include "rwmake.ch"
#include "protheus.ch"

/*/

———————————————————————————————————————————————————————————————————————————————
@function		BCTBR01                                                      /@
@type			Relatório                                                    /@
@date			13/08/2014                                                   /@
@description	Emite relatório de conciliação kardex x contábil             /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Especifico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————

/*/
User Function BCTBR01()
Local aRegs			:= {}   
Local aCabSX1		:= {"X1_GRUPO", "X1_ORDEM", "X1_PERGUNT", "X1_VARIAVL", "X1_TIPO", "X1_TAMANHO", "X1_DECIMAL", "X1_GSC", "X1_VAR01", "X1_F3", "X1_VALID", "X1_DEF01", "X1_DEF02"}
Local aHlp01		:= {"Informe o mês da data de referência", 	"inicial. Permitido números entre 1 e 12."}
Local aHlp02		:= {"Informe o ano da data de referência", 	"inicial. Permitido números entre 1980 e", 	"2049."}
Local aHlp03		:= {"Emite todos os registros ou somente",	"os que apresentarem divergência entre o",	"kardex e contabilidade?"}
Private cPerg		:= PadR("BCTBR01", Len(SX1->X1_GRUPO))
Private cDesc1 		:= "Emite relatorio de conciliação contábil com registros do Kardex. Específico Brasitech"
Private cDesc2 		:= ""
Private cDesc3 		:= ""
Private cTamanho   	:= "M"
Private nTipo      	:= 15
Private nLastKey   	:= 0
Private aReturn    	:= { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private cNomeprog  	:= "BCTBR01"
Private cTitulo    	:= AllTrim(SM0->M0_NOME) + " - " + "Conciliação estoque x contábil - " + AllTrim(SM0->M0_FILIAL) + " (" + SM0->M0_CODFIL + ")"
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
aAdd(aRegs, {cPerg, "02", "Do ano de emissão ?           ", "mv_ch2", "N", 04, 0, "G",	"mv_par02", "",		"",		"",			""})
aAdd(aRegs, {cPerg, "03", "Emite quais registros ?       ", "mv_ch3", "N", 01, 0, "C",	"mv_par03", "",		"", 		"1-Todos",	"2-Divergência"})

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
@date			13/08/2014                                                   /@
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
Local nLin	 			:= 80
Local aTam				:= TamSX3("B2_CM1")
Local lAll				:= (mv_par03 == 1)
Local lContinua			:= .T.
Local aCampos			:= {{"CTRL",		"C", 001, 0},;
							{"FILIAL",		"C", 002, 0},;
							{"K_DTMOV",		"D", 008, 0},;
							{"K_DOC",		"C", 009, 0},;
							{"K_SERIE",		"C", 003, 0},;
							{"K_CLIFOR",	"C", 008, 0},;
							{"K_LOJA",		"C", 002, 0},;
							{"K_NREDUZ",	"C", 020, 0},;
							{"K_PRODUTO",	"C", 015, 0},;
							{"K_ITEM",		"C", 004, 0},;
							{"K_D1D2D3",	"C", 010, 0},;
							{"K_TESTM",		"C", 003, 0},;
							{"K_CFOP",		"C", 004, 0},;
							{"K_DESCRPRO",	"C", 030, 0},;
							{"K_GRUPO",		"C", 004, 0},;
							{"K_TIPO",		"C", 002, 0},;
							{"K_ARMAZEM",	"C", 002, 0},;
							{"K_ENTSAI",	"C", 001, 0},;
							{"K_NUMSEQ",	"C", 006, 0},;
							{"K_OP",		"C", 013, 0},;
							{"K_QTD",		"N", 012, 0},;
							{"K_CUSTO",		"N", 018, aTam[2]},;
							{"K_DOCORI",	"C", 009, 0},;
							{"K_SERIEORI",	"C", 003, 0},;
							{"K_ITEMORI",	"C", 004, 0},;
							{"L_DTLCT",		"D", 008, 0},;
							{"L_LOTE",		"C", 006, 0},;
							{"L_SBLOTE",	"C", 003, 0},;
							{"L_DOC",		"C", 006, 0},;
							{"L_LINHA",		"C", 003, 0},;
							{"L_DEBITO",	"C", 020, 0},;
							{"L_CREDITO",	"C", 020, 0},;
							{"L_VALOR",		"N", 012, 2},;
							{"L_HISTOR",	"C", 200, 0},;
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
Local dDtIni	 		:= cTOd("01/" + StrZero(mv_par01,2) + "/" + StrZero(mv_par02,4))
Local dDtFim			:= LastDay(dDtIni)
Local nNumSD1			:= 0
Local nNumSD2			:= 0
Local nNumSD3			:= 0
Local nNumCT2			:= 0
Local nSD1xCT2			:= 0
Local nSD2xCT2			:= 0
Local nSD3xCT2			:= 0
Local nCT2xMov			:= 0
Local nCT2xMovOK		:= 0
Local aLP 				:= {	"MOVIMENTOS INTERNOS",;
								"666 - Saída de produto (REQUISIÇÃO)                              - MATA250",;
								"668 - Entrada de produto (DEVOLUÇÃO)                             - MATA240",;
								"670 - Transferência de produto (REQUISIÇÃO)                      - MATA260",;
								"672 - Transferência de produto (DEVOLUÇÃO)                       - MATA260",;
								"670 - Transferência de produto (ORIGEM)                          - MATA260",;
								"676 - Ajuste de inventário (DEVOLUÇÃO)                           - MATA340",;
								"674 - Ajuste de inventário (REQUISIÇÃO)                          - MATA340",;
								"679 - DEVOLUÇÃO automatica por apropriaçao indireta              - MATA330",;
								"680 - REQUISIÇÃO automatica por apropriaçao indireta             - MATA330",;
								"",;
								"NOTA FISCAL DE ENTRADA",;
								"640 - Inclusão de nfe por ítem (somente para notas de DEVOLUÇÃO) - MATA103",;
								"650 - Inclusão de nfe por ítem                                   - MATA103",;
								"651 - Inclusão de nfe por ítem e com RATEIO de centros de custo  - MATA103",;
								"655 - Exclusão de nfe por ítem                                   - MATA103",;
								"656 - Exclusão de nfe por ítem e com RATEIO de centros de custo  - MATA103",;
								"",;
								"NOTA FISCAL DE SAÍDA",;
								"610 - Inclusão de nota fiscal de saída por ítem                  - MATA460",;
								"630 - Exclusão de nota fiscal de saída por ítem                  - MATA520",;
								"678 - Custo da mercadoria vendida" }
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
Local cDiverg, nK, oExcel, oFWExcel, cArq, cConteudo, aPlanilha, aPerg

SetRegua(9)

SA1->(dbSetOrder(1))
SA2->(dbSetOrder(1))

//——————————————————————————————————————————————————————————————————————————
// 1- Cria arquivo de trabalho
//——————————————————————————————————————————————————————————————————————————
IncRegua("Cria arquivo temporário")
dbUseArea(.T.,, cArqTrb, "TRB", .T.)
dbSelectArea("TRB")
IndRegua("TRB", cIndex1, "CTRL+FILIAL+K_DOC+K_SERIE+K_CLIFOR+K_LOJA+K_PRODUTO+K_ITEM",,, "Selecionando Registros...")
IndRegua("TRB", cIndex2, "CTRL+FILIAL+K_PRODUTO+K_ARMAZEM+DTOS(K_DTMOV)+K_NUMSEQ",,, "Selecionando Registros...")
Set Index to &cIndex1, &cIndex2


//——————————————————————————————————————————————————————————————————————————
// 2- Seleciono os itens de notas de entrada e gravo na tabela de trabalho
//——————————————————————————————————————————————————————————————————————————
IncRegua("Selecionando notas de entrada...")
cQuery := "SELECT D1_FILIAL, D1_DTDIGIT, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM, "
cQuery += 		"D1_TES, D1_CF, D1_QUANT, D1_CUSTO, D1_LOCAL, D1_TIPO, D1_NFORI, D1_SERIORI, "
cQuery += 		"D1_ITEMORI, B1_DESC, B1_GRUPO, B1_TIPO "
cQuery += "FROM " + RetSqlName("SD1") + " SD1, " + RetSqlName("SF4") + " SF4, " + RetSqlName("SB1") + " SB1 "
cQuery += "WHERE SD1.D1_FILIAL = '" + xFilial("SD1") + "' "
cQuery += 		"AND SD1.D1_DTDIGIT BETWEEN '" + dTOs(dDtIni) + "' AND '" + dTOs(dDtFim) + "' "
cQuery += 		"AND SD1.D1_ORIGLAN <> 'LF' "
cQuery += 		"AND SD1.D_E_L_E_T_ = ' ' "
cQuery += 		"AND SF4.F4_FILIAL = '" + xFilial("SF4") + "' "
cQuery += 		"AND SF4.F4_CODIGO = SD1.D1_TES "
cQuery += 		"AND SF4.F4_ESTOQUE = 'S' "
cQuery += 		"AND SF4.D_E_L_E_T_ = ' ' "
cQuery += 		"AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
cQuery += 		"AND SB1.B1_COD = SD1.D1_COD "
cQuery += 		"AND SB1.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY D1_DTDIGIT, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_ITEM"

if Select("TEMP") > 0
	TEMP->(dbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TcGenQry(,,ChangeQuery(cQuery)), "TEMP", .F., .T.)
tcSetField("TEMP", "D1_DTDIGIT", "D")

dbSelectArea("TEMP")
dbGoTop()
do while TEMP->(!eof())
   
	if TEMP->D1_TIPO $ "DB"
		SA1->(dbSeek(xFilial("SA1") + TEMP->(D1_FORNECE + D1_LOJA)))
	else 
		SA2->(dbSeek(xFilial("SA2") + TEMP->(D1_FORNECE + D1_LOJA)))
	endif
	
	TRB->(RecLock("TRB", .T.))
	TRB->CTRL		:= "1"
	TRB->FILIAL		:= TEMP->D1_FILIAL
	TRB->K_DTMOV	:= TEMP->D1_DTDIGIT
	TRB->K_DOC		:= TEMP->D1_DOC
	TRB->K_SERIE	:= TEMP->D1_SERIE
	TRB->K_CLIFOR	:= TEMP->D1_FORNECE
	TRB->K_LOJA		:= TEMP->D1_LOJA
	TRB->K_NREDUZ	:= iif(TEMP->D1_TIPO $ "DB", SA1->A1_NREDUZ, SA2->A2_NREDUZ)
	TRB->K_PRODUTO	:= TEMP->D1_COD
	TRB->K_ITEM		:= TEMP->D1_ITEM
	TRB->K_TESTM	:= TEMP->D1_TES
	TRB->K_CFOP		:= TEMP->D1_CF
	TRB->K_ARMAZEM	:= TEMP->D1_LOCAL
	TRB->K_QTD		:= TEMP->D1_QUANT
	TRB->K_CUSTO	:= TEMP->D1_CUSTO
	TRB->K_DOCORI	:= TEMP->D1_NFORI
	TRB->K_SERIEORI	:= TEMP->D1_SERIORI
	TRB->K_ITEMORI	:= TEMP->D1_ITEMORI
	TRB->K_D1D2D3	:= "NF Entrada"
 	TRB->K_ENTSAI	:= "E"
	TRB->K_DESCRPRO	:= TEMP->B1_DESC
	TRB->K_GRUPO	:= TEMP->B1_GRUPO
	TRB->K_TIPO		:= TEMP->B1_TIPO

	TRB->(MsUnlock())
	
	nNumSD1++
	
	TEMP->(dbSkip())
	
enddo


//——————————————————————————————————————————————————————————————————————————
// 3- Seleciono os itens de notas de saída e gravo na tabela de trabalho
//——————————————————————————————————————————————————————————————————————————
IncRegua("Selecionando notas de saída...")
cQuery := "SELECT D2_FILIAL, D2_EMISSAO, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM, "
cQuery += 		"D2_TES, D2_CF, D2_QUANT, D2_CUSTO1, D2_LOCAL, D2_TIPO, D2_NFORI, D2_SERIORI, "
cQuery += 		"D2_ITEMORI, B1_DESC, B1_GRUPO, B1_TIPO "
cQuery += "FROM " + RetSqlName("SD2") + " SD2, " + RetSqlName("SF4") + " SF4, " + RetSqlName("SB1") + " SB1 "
cQuery += "WHERE SD2.D2_FILIAL = '" + xFilial("SD2") + "' "
cQuery += 		"AND SD2.D2_EMISSAO BETWEEN '" + dTOs(dDtIni) + "' AND '" + dTOs(dDtFim) + "' "
cQuery += 		"AND SD2.D2_ORIGLAN <> 'LF' "
cQuery += 		"AND SD2.D_E_L_E_T_ = ' ' "
cQuery += 		"AND SF4.F4_FILIAL = '" + xFilial("SF4") + "' "
cQuery += 		"AND SF4.F4_CODIGO = SD2.D2_TES "
cQuery += 		"AND SF4.F4_ESTOQUE = 'S' "
cQuery += 		"AND SF4.D_E_L_E_T_ = ' ' "
cQuery += 		"AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
cQuery += 		"AND SB1.B1_COD = SD2.D2_COD "
cQuery += 		"AND SB1.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY D2_EMISSAO, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_ITEM"

if Select("TEMP") > 0
	TEMP->(dbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TcGenQry(,,ChangeQuery(cQuery)), "TEMP", .F., .T.)
tcSetField("TEMP", "D2_EMISSAO", "D")

dbSelectArea("TEMP")
dbGoTop()
do while TEMP->(!eof())

	if TEMP->D2_TIPO $ "DB"
		SA2->(dbSeek(xFilial("SA2") + TEMP->(D2_CLIENTE + D2_LOJA)))
	else 
		SA1->(dbSeek(xFilial("SA1") + TEMP->(D2_CLIENTE + D2_LOJA)))
	endif

	TRB->(RecLock("TRB", .T.))
	TRB->CTRL		:= "2"
	TRB->FILIAL		:= TEMP->D2_FILIAL
	TRB->K_DTMOV	:= TEMP->D2_EMISSAO
	TRB->K_DOC		:= TEMP->D2_DOC
	TRB->K_SERIE	:= TEMP->D2_SERIE
	TRB->K_CLIFOR	:= TEMP->D2_CLIENTE
	TRB->K_LOJA		:= TEMP->D2_LOJA
	TRB->K_NREDUZ	:= iif(TEMP->D2_TIPO $ "DB", SA2->A2_NREDUZ, SA1->A1_NREDUZ)
	TRB->K_PRODUTO	:= TEMP->D2_COD
	TRB->K_ITEM		:= TEMP->D2_ITEM
	TRB->K_TESTM	:= TEMP->D2_TES
	TRB->K_CFOP		:= TEMP->D2_CF
	TRB->K_ARMAZEM	:= TEMP->D2_LOCAL
	TRB->K_QTD		:= TEMP->D2_QUANT
	TRB->K_CUSTO	:= TEMP->D2_CUSTO1
	TRB->K_DOCORI	:= TEMP->D2_NFORI
	TRB->K_SERIEORI	:= TEMP->D2_SERIORI
	TRB->K_ITEMORI	:= TEMP->D2_ITEMORI
	TRB->K_D1D2D3	:= "NF Saida"
 	TRB->K_ENTSAI	:= "S"
	TRB->K_DESCRPRO	:= TEMP->B1_DESC
	TRB->K_GRUPO	:= TEMP->B1_GRUPO
	TRB->K_TIPO		:= TEMP->B1_TIPO
	TRB->(MsUnlock())
	
	nNumSD2++
	
	TEMP->(dbSkip())
	
enddo


//——————————————————————————————————————————————————————————————————————————
// 4- Seleciono os movimentos internos e gravo na tabela de trabalho
//——————————————————————————————————————————————————————————————————————————
IncRegua("Selecionando movimentos internos...")
cQuery := "SELECT D3_FILIAL, D3_EMISSAO, D3_DOC, D3_COD, D3_TM, D3_CF, D3_QUANT, D3_CUSTO1, D3_LOCAL, D3_OP, D3_NUMSEQ, B1_DESC, B1_GRUPO, B1_TIPO "
cQuery += "FROM " + RetSqlName("SD3") + " SD3, " + RetSqlName("SB1") + " SB1 "
cQuery += "WHERE SD3.D3_FILIAL = '" + xFilial("SD3") + "' "
cQuery += 		"AND SD3.D3_EMISSAO BETWEEN '" + dTOs(dDtIni) + "' AND '" + dTOs(dDtFim) + "' "
cQuery += 		"AND SD3.D3_ESTORNO <> 'S' "
cQuery += 		"AND SD3.D3_CF NOT IN ('RE4','DE4') "
cQuery += 		"AND SD3.D_E_L_E_T_ = ' ' "
cQuery += 		"AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
cQuery += 		"AND SB1.B1_COD = SD3.D3_COD "
cQuery += 		"AND SB1.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY D3_EMISSAO, D3_DOC"

if Select("TEMP") > 0
	TEMP->(dbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TcGenQry(,,ChangeQuery(cQuery)), "TEMP", .F., .T.)
tcSetField("TEMP", "D3_EMISSAO", "D")

dbSelectArea("TEMP")
dbGoTop()
do while TEMP->(!eof())

	TRB->(RecLock("TRB", .T.))
	TRB->CTRL		:= "3"
	TRB->FILIAL		:= TEMP->D3_FILIAL
	TRB->K_DTMOV	:= TEMP->D3_EMISSAO
	TRB->K_DOC		:= TEMP->D3_DOC
	TRB->K_PRODUTO	:= TEMP->D3_COD
	TRB->K_TESTM	:= TEMP->D3_TM
	TRB->K_CFOP		:= TEMP->D3_CF
	TRB->K_ARMAZEM	:= TEMP->D3_LOCAL
	TRB->K_QTD		:= TEMP->D3_QUANT
	TRB->K_CUSTO	:= TEMP->D3_CUSTO1
	TRB->K_OP		:= TEMP->D3_OP
	TRB->K_NUMSEQ	:= TEMP->D3_NUMSEQ
	TRB->K_D1D2D3	:= "Movim.Int."
 	TRB->K_ENTSAI	:= iif(TEMP->D3_TM <= "500", "E", "S")
	TRB->K_DESCRPRO	:= TEMP->B1_DESC
	TRB->K_GRUPO	:= TEMP->B1_GRUPO
	TRB->K_TIPO		:= TEMP->B1_TIPO
	TRB->(MsUnlock())
	
	nNumSD3++
	
	TEMP->(dbSkip())
	
enddo


//——————————————————————————————————————————————————————————————————————————
// 5- Seleciono os lançamentos contábeis referentes à custo e gravo na 
//    tabela de trabalho
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
cQuery += 		"AND CT1.CT1_X_CONC = '01' "	//Conciliacao do estoque
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

	cHist := TEMP->CT2_HIST
	lNovo := .T.
	U_GetHist(dTOs(TEMP->CT2_DATA) + TEMP->CT2_LOTE + TEMP->CT2_SBLOTE + TEMP->CT2_DOC, TEMP->CT2_LINHA, @cHist)
		
	if !empty(TEMP->CT2_KEY) .and. TEMP->CT2_LP $ "666/668/670/672/674/676/679/680"

		TRB->(dbSetOrder(2))
		lNovo	 := .T.
		if TRB->(dbSeek("3" + Left(TEMP->CT2_KEY, 34))) .and. Empty(TRB->L_DTLCT)
			lNovo	 := .F.
		endif
		nSD3xCT2 += iif(!lNovo, 1, 0)


	elseif TEMP->CT2_LP $ "640/650/651/655/656/641" .and. !empty(TEMP->CT2_KEY)

		TRB->(dbSetOrder(1))
		lNovo	 := .T.
		if TRB->(dbSeek("1" + Left(TEMP->CT2_KEY, 44))) .and. Empty(TRB->L_DTLCT)
			lNovo	 := .F.
		endif
		nSD1xCT2 += iif(!lNovo, 1, 0)

	elseif TEMP->CT2_LP $ "610/630/678" .and. !empty(TEMP->CT2_KEY)

		TRB->(dbSetOrder(1))
		lNovo	 := .T.
		if TRB->(dbSeek("2" + Left(TEMP->CT2_KEY, 44))) .and. Empty(TRB->L_DTLCT)
			lNovo	 := .F.
		endif
		nSD2xCT2 += iif(!lNovo, 1, 0)

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
	if TEMP->CT2_LP $ "655/656/630"	.and. lNovo	//Lancamentos de exclusao de notas. Gravo para não ocasionar divergencia de registro
		TRB->K_DTMOV	:= TEMP->CT2_DATA
		TRB->K_CUSTO	:= TEMP->CT2_VALOR
		TRB->K_DOC		:= "CANC.DOC"
	endif
	TRB->(MsUnlock())

	nNumCT2++
	
	TEMP->(dbSkip())
	
enddo


//——————————————————————————————————————————————————————————————————————————
// 6- Seleciono as contas contábeis que pertencem ao grupo de conciliacao
//    estoque e custos. Emito a relação no relatorio estatistico
//——————————————————————————————————————————————————————————————————————————
IncRegua("Selecionando contas contábeis estoque...")
cQuery := "SELECT CT1_CONTA, CT1_DESC01 "
cQuery += "FROM " + RetSqlName("CT1") + " CT1 "
cQuery += "WHERE CT1.CT1_FILIAL = '" + xFilial("CT1") + "' "
cQuery += 		"AND CT1.CT1_X_CONC = '01' "	//Conciliacao do estoque
cQuery += 		"AND CT1.D_E_L_E_T_ = ' '"

if Select("TEMP") > 0
	TEMP->(dbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TcGenQry(,,ChangeQuery(cQuery)), "TEMP", .F., .T.)


//——————————————————————————————————————————————————————————————————————————
// 7- Gerando planilha Excel
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
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Dt.Kardex", 				nCenterAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Documento", 				nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Serie", 					nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Item", 					nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Cliente/Fornecedor", 		nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Loja", 					nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Nome Cliente/Fornecedor", 	nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Origem", 					nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Entr/Saida", 				nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "TES/TM", 					nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "CFOP/TP", 					nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Produto", 					nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Descrição produto", 		nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Grupo produto", 			nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Tipo produto", 			nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Armazem", 					nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Qtde", 					nRightAlign, 	nNumberFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Custo", 					nRightAlign, 	nCurrencyFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Ord.Prod.", 				nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Docto Origem",				nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Serie Origem",				nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Item Origem", 				nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "NumSeq", 					nLeftAlign, 	nGeneralFormat, .f.)
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


		//Somo contador de vinculo entre CT2 x Mov e de contador com valor OK, caso nao exista divergencia
		if !Empty(TRB->K_DTMOV) .and. !Empty(TRB->L_DTLCT)
		
			nCT2xMov++
			if Abs(Round(TRB->K_CUSTO, 2) - TRB->L_VALOR) <= 0.01
				nCT2xMovOK ++
			else
				cDiverg := "*"
			endif
			
		elseif (Empty(TRB->K_DTMOV) .and. !Empty(TRB->L_DTLCT)) .or.;
			   (!Empty(TRB->K_DTMOV) .and. Empty(TRB->L_DTLCT))
			   
			cDiverg := "*"

		endif

	
		//——————————————————————————————————————————————————————————————————————————
		// Gera informações para exportação para o Excel para todos os registros ou
		// ou somente os que tiverem divergência
		//——————————————————————————————————————————————————————————————————————————
		if lAll .or. (!lAll .and. !Empty(cDiverg))
		  
			aPlanilha := {}

			aAdd(aPlanilha, TRB->FILIAL + "-" + AllTrim(SM0->M0_FILIAL))
			aAdd(aPlanilha, iif(Empty(TRB->K_DTMOV), " ", dTOc(TRB->K_DTMOV)))
			aAdd(aPlanilha, AllTrim(TRB->K_DOC))
			aAdd(aPlanilha, AllTrim(TRB->K_SERIE))
			aAdd(aPlanilha, AllTrim(TRB->K_ITEM))
			aAdd(aPlanilha, AllTrim(TRB->K_CLIFOR))
			aAdd(aPlanilha, AllTrim(TRB->K_LOJA))
			aAdd(aPlanilha, AllTrim(TRB->K_NREDUZ))
			aAdd(aPlanilha, TRB->K_D1D2D3)
			aAdd(aPlanilha, TRB->K_ENTSAI)
			aAdd(aPlanilha, TRB->K_TESTM)
			aAdd(aPlanilha, TRB->K_CFOP)
			aAdd(aPlanilha, TRB->K_PRODUTO)
			aAdd(aPlanilha, TRB->K_DESCRPRO)
			aAdd(aPlanilha, TRB->K_GRUPO)
			aAdd(aPlanilha, TRB->K_TIPO)
			aAdd(aPlanilha, TRB->K_ARMAZEM)
			aAdd(aPlanilha, NoRound(TRB->K_QTD, 0))
			aAdd(aPlanilha, NoRound(TRB->K_CUSTO, aTam[2]))
			aAdd(aPlanilha, TRB->K_OP)
			aAdd(aPlanilha, TRB->K_DOCORI)
			aAdd(aPlanilha, TRB->K_SERIEORI)
			aAdd(aPlanilha, TRB->K_ITEMORI)
			aAdd(aPlanilha, TRB->K_NUMSEQ)
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
// 8- Imprimindo o relatório estatistico
//——————————————————————————————————————————————————————————————————————————
IncRegua("Imprimindo o relatório...")

nLin := Cabec(cTitulo, cCabec1, cCabec2, cNomeprog, cTamanho, 18) + 1

@ nLin++, 05 PSay "Quantidade de Itens de Notas de Entrada: " + Transform(nNumSD1, "@E 999,999,999")
@ nLin++, 05 PSay "Quantidade de itens de Notas de Saida..: " + Transform(nNumSD2, "@E 999,999,999")
@ nLin++, 05 PSay "Quantidade de Movimentos Internos......: " + Transform(nNumSD3, "@E 999,999,999")
@ nLin++, 05 PSay "Quantidade de Lançamentos Contábeis....: " + Transform(nNumCT2, "@E 999,999,999")
@ nLin++, 00 PSay __PrtThinLine()
@ nLin++, 05 PSay "% de Itens NFE com registro contábil...: " + Transform((nSD1xCT2 / nNumSD1) * 100, "@E 999,999.99 %")
@ nLin++, 05 PSay "% de Itens NFS com registro contábil...: " + Transform((nSD2xCT2 / nNumSD2) * 100, "@E 999,999.99 %")
@ nLin++, 05 PSay "% de Mov.Internos com registro contábil: " + Transform((nSD3xCT2 / nNumSD3) * 100, "@E 999,999.99 %")
@ nLin++, 05 PSay "% de Registros contábeis com origem....: " + Transform((nCT2xMov / nNumCT2) * 100, "@E 999,999.99 %") +;
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

@ nLin++, 01 PSay "Relação de lançamentos padrões referentes à custo"
@ nLin++, 01 PSay "================================================="
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

Return()