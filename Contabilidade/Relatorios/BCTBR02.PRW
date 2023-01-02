#include "rwmake.ch"
#include "protheus.ch"

/*/

———————————————————————————————————————————————————————————————————————————————
@function		BCTBR02                                                      /@
@type			Relatório                                                    /@
@date			01/09/2014                                                   /@
@description	Emite relatório de conciliação do contas à receber x contábil/@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Especifico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————

/*/
User Function BCTBR02()
Local aRegs			:= {}   
Local aCabSX1		:= {"X1_GRUPO", "X1_ORDEM", "X1_PERGUNT", "X1_VARIAVL", "X1_TIPO", "X1_TAMANHO", "X1_DECIMAL", "X1_GSC", "X1_VAR01", "X1_F3", "X1_VALID", "X1_DEF01", "X1_DEF02"}
Local aHlp01		:= {"Informe o mês da data de referência", 	"inicial. Permitido números entre 1 e 12."}
Local aHlp02		:= {"Informe o ano da data de referência", 	"inicial. Permitido números entre 1980 e", 	"2049."}
Local aHlp03		:= {"Emite todos os registros ou somente",	"os que apresentarem divergência entre o",	"kardex e contabilidade?"}
Private cPerg		:= PadR("BCTBR02", Len(SX1->X1_GRUPO))
Private cDesc1 		:= "Emite relatorio de conciliação contábil com registros do contas à receber e suas baixas. Específico Brasitech"
Private cDesc2 		:= ""
Private cDesc3 		:= ""
Private cTamanho   	:= "M"
Private nTipo      	:= 15
Private nLastKey   	:= 0
Private aReturn    	:= { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private cNomeprog  	:= "BCTBR02"
Private cTitulo    	:= AllTrim(SM0->M0_NOME) + " - " + "Conciliação contas à receber x contábil - " + AllTrim(SM0->M0_FILIAL) + " (" + SM0->M0_CODFIL + ")"
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

aAdd(aRegs, {cPerg, "01", "Do mês de emissão ?           ", "mv_ch1", "N", 02, 0, "G",	"mv_par01", "",		"",	"",			""})
aAdd(aRegs, {cPerg, "02", "Do ano de emissão ?           ", "mv_ch2", "N", 04, 0, "G",	"mv_par02", "",		"",	"",			""})
aAdd(aRegs, {cPerg, "03", "Emite quais registros ?       ", "mv_ch3", "N", 01, 0, "C",	"mv_par03", "",		"", 	"1-Todos",	"2-Divergência"})

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
@date			01/09/2014                                                   /@
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
Local lAll				:= (mv_par03 == 1)
Local lContinua			:= .T.
Local aCampos			:= {{"CTRL",		"C", 001, 0},;
							{"FILIAL",		"C", 002, 0},;
							{"R_TPMOV",		"C", 010, 0},;
							{"R_DTMOV",		"D", 008, 0},;
							{"R_PREFIXO",	"C", 003, 0},;
							{"R_NUM",		"C", 009, 0},;
							{"R_PARCELA",	"C", 001, 0},;
							{"R_TIPO",		"C", 003, 0},;
							{"R_TIPODOC",	"C", 002, 0},;
							{"R_SEQ",		"C", 002, 0},;
							{"R_DOCUMEN",	"C", 050, 0},;
							{"R_HISTOR",	"C", 100, 0},;
							{"R_BANCO",		"C", 003, 0},;
							{"R_AGENCIA",	"C", 005, 0},;
							{"R_CTACOR",	"C", 010, 0},;
							{"R_CLIENTE",	"C", 008, 0},;
							{"R_LOJA",		"C", 002, 0},;
							{"R_NREDUZ",	"C", 020, 0},;
							{"R_DOC",		"C", 009, 0},;
							{"R_SERIE",		"C", 003, 0},;
							{"R_PRODUTO",	"C", 015, 0},;
							{"R_ITEM",		"C", 004, 0},;
							{"R_VALOR",		"N", 012, 2},;
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
Local cIndex3			:= CriaTrab(Nil, .F.)
Local cIndex4			:= CriaTrab(Nil, .F.)
Local cIndex5			:= CriaTrab(Nil, .F.)
Local dDtIni	 		:= cTOd("01/" + StrZero(mv_par01,2) + "/" + StrZero(mv_par02,4))
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
Local aLP 				:= {	"INCLUSÃO MANUAL DE TITULOS A RECEBER",;
								"500 - Ao gravar Contas a Receber                                - FINA040",;
								"501 - Ao Gravar Contas a Receber  - Títulos do tipo RA          - FINA040",;
								"502 - Contas a Receber (Cancelamento) - Título do tipo RA       - FINA040",;
								"505 - Contas a Receber (Cancelamento)                           - FINA040",;
								"",;
								"BAIXAS DE TÍTULOS À RECEBER",;
								"520 - Baixas a Receber - Carteira                               - FINA070",;
								"521 - Baixas a Receber - Contas a receber Simples               - FINA070",;
								"522 - Baixas a Receber - Contas a receber Descontada            - FINA070",;
								"523 - Baixas a Receber - Contas a receber Caucionada            - FINA070",;
								"524 - Baixas a Receber - Contas a receber Vinculada             - FINA070",;
								"525 - Baixas a Receber - Contas a receber Advogado              - FINA070",;
								"526 - Baixar a Receber - Contas a receber Judicial              - FINA070",;
								"527 - Cancelamento de Baixas a Receber                          - FINA070",;
								"528 - Baixa do Título - Contas a receber Caucionada Descontada  - FINA070",;
								"",;
								"NOTA FISCAL DE ENTRADA",;
								"640 - Inclusão de nfe por ítem (somente para notas de DEVOLUÇÃO) - MATA103",;
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

SetRegua(10)

SA1->(dbSetOrder(1))

IncRegua("Cria arquivo temporário")
dbUseArea(.T.,, cArqTrb, "TRB", .T.)
dbSelectArea("TRB")
IndRegua("TRB", cIndex1, "CTRL+FILIAL+R_CLIENTE+R_LOJA+R_PREFIXO+R_NUM+R_PARCELA+R_TIPO",,, "Selecionando Registros...")
IndRegua("TRB", cIndex2, "CTRL+FILIAL+R_TIPODOC+R_PREFIXO+R_NUM+R_PARCELA+R_TIPO+dTOs(R_DTMOV)+R_CLIENTE+R_LOJA+R_SEQ",,, "Selecionando Registros...")
IndRegua("TRB", cIndex3, "CTRL+FILIAL+R_BANCO+R_AGENCIA+R_CTACOR+R_PREFIXO+R_NUM+R_PARCELA+R_TIPO+DTOS(R_DTMOV)",,, "Selecionando Registros...")
IndRegua("TRB", cIndex4, "CTRL+FILIAL+R_DOCUMEN",,, "Selecionando Registros...")
IndRegua("TRB", cIndex5, "CTRL+FILIAL+R_DOC+R_SERIE+R_CLIENTE+R_LOJA+R_PRODUTO+R_ITEM",,, "Selecionando Registros...")
Set Index to &cIndex1, &cIndex2, &cIndex3, &cIndex4, &cIndex5


//——————————————————————————————————————————————————————————————————————————
// 2- Seleciono notas de vendaS e gravo na tabela de trabalho
//——————————————————————————————————————————————————————————————————————————
IncRegua("Selecionando notas de saída...")
cQuery := "SELECT D2_FILIAL, D2_EMISSAO, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_VALBRUT, D2_COD, D2_ITEM "
cQuery += "FROM " + RetSqlName("SD2") + " SD2, " + RetSqlName("SF2") + " SF2 "
cQuery += "WHERE SD2.D2_FILIAL = '" + xFilial("SD2") + "' "
cQuery += 		"AND SD2.D2_EMISSAO BETWEEN '" + dTOs(dDtIni) + "' AND '" + dTOs(dDtFim) + "' "
cQuery += 		"AND SD2.D2_ORIGLAN <> 'LF' "
cQuery += 		"AND SD2.D2_TIPO NOT IN ('B','D') "
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

	SA1->(dbSeek(xFilial("SA1") + TEMP->(D2_CLIENTE + D2_LOJA)))

	TRB->(RecLock("TRB", .T.))
	TRB->CTRL		:= "1"
	TRB->FILIAL		:= TEMP->D2_FILIAL
	TRB->R_DOC		:= TEMP->D2_DOC
	TRB->R_SERIE	:= TEMP->D2_SERIE
	TRB->R_CLIENTE	:= TEMP->D2_CLIENTE
	TRB->R_LOJA		:= TEMP->D2_LOJA
	TRB->R_PRODUTO	:= TEMP->D2_COD
	TRB->R_ITEM		:= TEMP->D2_ITEM
	TRB->R_DTMOV	:= TEMP->D2_EMISSAO	
	TRB->R_VALOR	:= TEMP->D2_VALBRUT
	TRB->R_NREDUZ	:= SA1->A1_NREDUZ	
	TRB->R_TPMOV	:= "PROV.NF"
	TRB->(MsUnlock())

	nNumSD2++
	
	TEMP->(dbSkip())
	
enddo


//——————————————————————————————————————————————————————————————————————————
// 3- Seleciono notas de devolução de vendas e gravo na tabela de trabalho
//——————————————————————————————————————————————————————————————————————————
IncRegua("Selecionando notas de entrada...")
cQuery := "SELECT D1_FILIAL, D1_DTDIGIT, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_TOTAL, D1_VALIPI, D1_ICMSRET, D1_VALDESC, D1_COD, D1_ITEM "
cQuery += "FROM " + RetSqlName("SD1") + " SD1, " + RetSqlName("SF1") + " SF1 "
cQuery += "WHERE SD1.D1_FILIAL = '" + xFilial("SD1") + "' "
cQuery += 		"AND SD1.D1_DTDIGIT BETWEEN '" + dTOs(dDtIni) + "' AND '" + dTOs(dDtFim) + "' "
cQuery += 		"AND SD1.D1_ORIGLAN <> 'LF' "
cQuery += 		"AND SD1.D1_TIPO IN ('B','D') "
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
   
	SA1->(dbSeek(xFilial("SA1") + TEMP->(D1_FORNECE + D1_LOJA)))

	TRB->(RecLock("TRB", .T.))
	TRB->CTRL		:= "2"
	TRB->FILIAL		:= TEMP->D1_FILIAL
	TRB->R_DOC		:= TEMP->D1_DOC
	TRB->R_SERIE	:= TEMP->D1_SERIE
	TRB->R_CLIENTE	:= TEMP->D1_FORNECE
	TRB->R_LOJA		:= TEMP->D1_LOJA
	TRB->R_PRODUTO	:= TEMP->D1_COD
	TRB->R_ITEM		:= TEMP->D1_ITEM
	TRB->R_DTMOV	:= TEMP->D1_DTDIGIT	
	TRB->R_VALOR	:= TEMP->(D1_TOTAL + D1_VALIPI + D1_ICMSRET - D1_VALDESC)
	TRB->R_NREDUZ	:= SA1->A1_NREDUZ
	TRB->R_TPMOV	:= "DEVOL.NF"
	TRB->(MsUnlock())

	nNumSD1++
	
	TEMP->(dbSkip())
	
enddo


//——————————————————————————————————————————————————————————————————————————
// 4- Seleciono os títulos manuais de recebimentos e gravo na tabela de 
//    trabalho
//——————————————————————————————————————————————————————————————————————————
IncRegua("Selecionando movimentos internos...")
cQuery := "SELECT E1_FILIAL, E1_EMISSAO, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_VALOR "
cQuery += "FROM " + RetSqlName("SE1") + " SE1 "
cQuery += "WHERE SE1.E1_FILIAL = '" + xFilial("SE1") + "' "
cQuery += 		"AND SE1.E1_EMISSAO BETWEEN '" + dTOs(dDtIni) + "' AND '" + dTOs(dDtFim) + "' "
cQuery += 		"AND SE1.E1_ORIGEM NOT IN ('MATA100', 'MATA460') "
cQuery += 		"AND SE1.D_E_L_E_T_ = ' ' "

if Select("TEMP") > 0
	TEMP->(dbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TcGenQry(,,ChangeQuery(cQuery)), "TEMP", .F., .T.)
tcSetField("TEMP", "E1_EMISSAO", "D")

dbSelectArea("TEMP")
dbGoTop()
do while TEMP->(!eof())

	SA1->(dbSeek(xFilial("SA1") + TEMP->(E1_CLIENTE + E1_LOJA)))
	
	TRB->(RecLock("TRB", .T.))
	TRB->CTRL		:= "3"
	TRB->FILIAL		:= TEMP->E1_FILIAL
	TRB->R_CLIENTE	:= TEMP->E1_CLIENTE
	TRB->R_LOJA		:= TEMP->E1_LOJA
	TRB->R_PREFIXO	:= TEMP->E1_PREFIXO
	TRB->R_NUM		:= TEMP->E1_NUM
	TRB->R_PARCELA	:= TEMP->E1_PARCELA
	TRB->R_TIPO		:= TEMP->E1_TIPO
	TRB->R_DTMOV	:= TEMP->E1_EMISSAO
	TRB->R_NREDUZ	:= TEMP->E1_NOMCLI
	TRB->R_VALOR	:= TEMP->E1_VALOR`
	TRB->R_NREDUZ	:= SA1->A1_NREDUZ
	TRB->R_TPMOV	:= "PROV.TIT"	
	TRB->(MsUnlock())

	nNumSE1++
	
	TEMP->(dbSkip())
	
enddo


//——————————————————————————————————————————————————————————————————————————
// 5- Seleciono as baixas de recebimentos e gravo na tabela de trabalho
/*
				aBaixas := BaixaSE5(dDtIni, dDtFim, "R", .T., "A")
				for nK := 1 to Len(aBaixas)
					TRB->(RecLock("TRB", .T.))
					TRB->CTRL		:= "4"
					TRB->FILIAL		:= xFilial("SE5")
					TRB->R_TIPODOC	:= aBaixas[nK, 32]
					TRB->R_PREFIXO	:= aBaixas[nK, 01]
					TRB->R_NUM		:= aBaixas[nK, 02]
					TRB->R_PARCELA	:= aBaixas[nK, 03]
					TRB->R_TIPO		:= aBaixas[nK, 04]
					TRB->R_DTMOV	:= aBaixas[nK, 10]
					TRB->R_CLIENTE	:= aBaixas[nK, 34]
					TRB->R_LOJA		:= aBaixas[nK, 35]
					TRB->R_SEQ		:= aBaixas[nK, 33]
					TRB->R_BANCO	:= aBaixas[nK, 18]
					TRB->R_AGENCIA	:= aBaixas[nK, 30]
					TRB->R_CTACOR	:= aBaixas[nK, 31]
					TRB->R_NREDUZ	:= aBaixas[nK, 06]
					TRB->R_DOCUMEN	:= aBaixas[nK, 36]
					TRB->R_HISTOR	:= aBaixas[nK, 09]
					TRB->R_VALOR	:= aBaixas[nK, 17]
					TRB->R_TPMOV	:= "BAIXA"
					TRB->(MsUnlock())
					nNumSE5++
				next
*/
//——————————————————————————————————————————————————————————————————————————
IncRegua("Selecionando movimentos internos...")

cQuery := "SELECT E5_FILIAL, E5_TIPODOC, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_DATA, E5_CLIFOR, "
cQuery +=       "E5_LOJA, E5_SEQ, E5_BANCO, E5_AGENCIA, E5_CONTA, E5_DOCUMEN, E5_HISTOR, E5_VALOR "
cQuery += "FROM " + RetSqlName("SE5")+" SE5 "
cQuery += "WHERE SE5.E5_FILIAL = '" + xFilial("SE5") + "' "
cQuery +=       "AND SE5.E5_RECPAG = 'R' "
cQuery +=       "AND SE5.E5_DATA BETWEEN '" + dTOs(dDtIni) + "' AND '" + dTOs(dDtFim) + "' "
cQuery +=       "AND SE5.E5_TIPODOC NOT IN ('DC','D2','JR','J2','TL','MT','M2','CM','C2','TR','TE') "
cQuery +=       "AND SE5.E5_VALOR > 0 "

cQuery +=       "AND SE5.E5_SITUACA NOT IN ('C','E','X') "
cQuery +=       "AND ((SE5.E5_TIPODOC = 'CD' AND SE5.E5_VENCTO <= SE5. E5_DATA) OR SE5.E5_TIPODOC <> 'CD') "
cQuery +=       "AND SE5.E5_HISTOR NOT LIKE '%Baixa Automatica / Lote%' "

//movimentos financeiros
cQuery +=   	"AND SE5.E5_TIPODOC <> ' ' "
cQuery +=   	"AND SE5.E5_NUMERO  <> ' ' "
cQuery +=   	"AND SE5.E5_TIPODOC <> 'CH' "

cQuery +=       "AND SE5.E5_MOTBX != 'DRH' "	//Solicitado pelo Renato em 27/10/14

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

	SA1->(dbSeek(xFilial("SA1") + TEMP->(E5_CLIFOR + E5_LOJA)))
	
	TRB->(RecLock("TRB", .T.))
	TRB->CTRL		:= "4"
	TRB->FILIAL		:= xFilial("SE5")
	TRB->R_TIPODOC	:= TEMP->E5_TIPODOC
	TRB->R_PREFIXO	:= TEMP->E5_PREFIXO
	TRB->R_NUM		:= TEMP->E5_NUMERO
	TRB->R_PARCELA	:= TEMP->E5_PARCELA
	TRB->R_TIPO		:= TEMP->E5_TIPO
	TRB->R_DTMOV	:= TEMP->E5_DATA
	TRB->R_CLIENTE	:= TEMP->E5_CLIFOR
	TRB->R_LOJA		:= TEMP->E5_LOJA
	TRB->R_SEQ		:= TEMP->E5_SEQ
	TRB->R_BANCO	:= TEMP->E5_BANCO
	TRB->R_AGENCIA	:= TEMP->E5_AGENCIA
	TRB->R_CTACOR	:= TEMP->E5_CONTA
	TRB->R_NREDUZ	:= SA1->A1_NREDUZ
	TRB->R_DOCUMEN	:= TEMP->E5_DOCUMEN
	TRB->R_HISTOR	:= TEMP->E5_HISTOR
	TRB->R_VALOR	:= TEMP->E5_VALOR
	TRB->R_TPMOV	:= "BAIXA"
	TRB->(MsUnlock())
	
	nNumSE5++
	
	TEMP->(dbSkip())
	
enddo


//——————————————————————————————————————————————————————————————————————————
// 6- Seleciono os lançamentos contábeis referentes ao contas à receber e 
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
cQuery += 		"AND CT1.CT1_X_CONC = '02' "	//Conciliacao do contas a receber
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
	
	if TEMP->CT2_LP $ "500/501" .and. !Empty(TEMP->CT2_KEY)		//provisao de titulos
		TRB->(dbSetOrder(1))
		cChvPesq := "3" + Left(TEMP->CT2_KEY, Len(TRB->(FILIAL+R_CLIENTE+R_LOJA+R_PREFIXO+R_NUM+R_PARCELA+R_TIPO)))
		lNovo	 := .T.
		if TRB->(dbSeek(cChvPesq)) .and. Empty(TRB->L_DTLCT)
			lNovo	 := .F.
		endif
		nSE1xCT2 += iif(!lNovo, 1, 0)

	elseif TEMP->CT2_LP $ "520/521/522/523/524/525/526/527/528/530/531/532/587/588/589/596/597" .and. !Empty(TEMP->CT2_KEY)		//baixa e cancelamento de baixas a receber e a pagar
		TRB->(dbSetOrder(2))
		cChvPesq := "4" + Left(TEMP->CT2_KEY, Len(TRB->(FILIAL+R_TIPODOC+R_PREFIXO+R_NUM+R_PARCELA+R_TIPO+dTOs(R_DTMOV)+R_CLIENTE+R_LOJA+R_SEQ)))
		lNovo	 := TRB->(!dbSeek(cChvPesq))
		nSE5xCT2 += iif(!lNovo, 1, 0)
		
	elseif TEMP->CT2_LP $ "560/561" .and. !Empty(TEMP->CT2_KEY)		//transferencia financeira (origem e destino)
		TRB->(dbSetOrder(3))
		cChvPesq := "4" + Left(TEMP->CT2_KEY, Len(TRB->(FILIAL+R_BANCO+R_AGENCIA+R_CONTA+R_PREFIXO+R_NUMERO+R_PARCELA+R_TIPO+DTOS(R_DTMOV))))
		lNovo	 := .T.
		if TRB->(dbSeek(cChvPesq)) .and. Empty(TRB->L_DTLCT)
			lNovo	 := .F.
		endif
		nSE5xCT2 += iif(!lNovo, 1, 0)
		
	elseif TEMP->CT2_LP $ "562/563" .and. !Empty(TEMP->CT2_KEY)		//movimento bancario a receber e a pagar
		TRB->(dbSetOrder(4))
		cChvPesq := "4" + Left(TEMP->CT2_KEY, Len(TRB->(FILIAL+R_DOCUMEN)))
		lNovo	 := .T.
		if TRB->(dbSeek(cChvPesq)) .and. Empty(TRB->L_DTLCT)
			lNovo	 := .F.
		endif
		nSE5xCT2 += iif(!lNovo, 1, 0)
	
	elseif TEMP->CT2_LP $ "610" .and. !Empty(TEMP->CT2_KEY)			//provisao de titulos por nota fiscal
		TRB->(dbSetOrder(5))
		cChvPesq := "1" + Left(TEMP->CT2_KEY, Len(TRB->(FILIAL+R_DOC+R_SERIE+R_CLIENTE+R_LOJA+R_PRODUTO+R_ITEM)))
		lNovo	 := .T.
		if TRB->(dbSeek(cChvPesq)) .and. Empty(TRB->L_DTLCT)
			lNovo	 := .F.
		endif
		nSD2xCT2 += iif(!lNovo, 1, 0)

	elseif TEMP->CT2_LP $ "640/650" .and. !Empty(TEMP->CT2_KEY)		//devolução de vendas por nota fiscal
		TRB->(dbSetOrder(5))
		cChvPesq := "2" + Left(TEMP->CT2_KEY, Len(TRB->(FILIAL+R_DOC+R_SERIE+R_CLIENTE+R_LOJA+R_PRODUTO+R_ITEM)))
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
	
	if TEMP->CT2_LP $ "502/505/630/655"	.and. lNovo		//Lancamentos de exclusao. Gravo para não ocasionar divergencia de registro (502, 505, 527, 531, 588, 589)
		TRB->R_DTMOV	:= TEMP->CT2_DATA
		TRB->R_VALOR	:= TEMP->CT2_VALOR
		TRB->R_NUM		:= "CANC.DOC"
	endif
	TRB->(MsUnlock())

	nNumCT2++
	
	TEMP->(dbSkip())
	
enddo


//——————————————————————————————————————————————————————————————————————————
// 7- Seleciono as contas contábeis que pertencem ao grupo de conciliacao
//    de contas à receber. Emito a relação no relatorio estatistico
//——————————————————————————————————————————————————————————————————————————
IncRegua("Selecionando contas contábeis de contas a receber...")
cQuery := "SELECT CT1_CONTA, CT1_DESC01 "
cQuery += "FROM " + RetSqlName("CT1") + " CT1 "
cQuery += "WHERE CT1.CT1_FILIAL = '" + xFilial("CT1") + "' "
cQuery += 		"AND CT1.CT1_X_CONC = '02' "	//Conciliacao de contas a receber
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
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Cliente", 					nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Loja", 					nLeftAlign, 	nGeneralFormat, .f.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Nome Cliente", 			nLeftAlign, 	nGeneralFormat, .f.)
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
		if !Empty(TRB->R_DTMOV) .and. !Empty(TRB->L_DTLCT)
			nCT2xMov++
			if TRB->R_VALOR == TRB->L_VALOR
				nCT2xMovOK ++
			endif
		endif

		//Verificando se há divergencia
		if (Empty(TRB->R_DTMOV) .and. !Empty(TRB->L_DTLCT)) .or.;
		   (!Empty(TRB->R_DTMOV) .and. Empty(TRB->L_DTLCT)) .or.;
		   TRB->R_VALOR != TRB->L_VALOR
		   
			cDiverg := "*"
			
		endif

		//——————————————————————————————————————————————————————————————————————————
		// Gera informações para exportação para o Excel para todos os registros ou
		// ou somente os que tiverem divergência
		//——————————————————————————————————————————————————————————————————————————
		if lAll .or. (!lAll .and. !Empty(cDiverg))

			aPlanilha := {}

			aAdd(aPlanilha, TRB->FILIAL + "-" + AllTrim(SM0->M0_FILIAL))
			aAdd(aPlanilha, iif(Empty(TRB->R_DTMOV), " ", dTOc(TRB->R_DTMOV)))
			aAdd(aPlanilha, AllTrim(TRB->R_TPMOV))
			aAdd(aPlanilha, AllTrim(TRB->R_PREFIXO))
			aAdd(aPlanilha, AllTrim(TRB->R_NUM))
			aAdd(aPlanilha, AllTrim(TRB->R_PARCELA))
			aAdd(aPlanilha, AllTrim(TRB->R_TIPO))
			aAdd(aPlanilha, AllTrim(TRB->R_CLIENTE))
			aAdd(aPlanilha, AllTrim(TRB->R_LOJA))
			aAdd(aPlanilha, AllTrim(TRB->R_NREDUZ))
			aAdd(aPlanilha, AllTrim(TRB->R_SERIE))
			aAdd(aPlanilha, AllTrim(TRB->R_ITEM))
			aAdd(aPlanilha, AllTrim(TRB->R_PRODUTO))
			aAdd(aPlanilha, AllTrim(TRB->R_TIPODOC))
			aAdd(aPlanilha, AllTrim(TRB->R_SEQ))
			aAdd(aPlanilha, AllTrim(TRB->R_DOCUMEN))
			aAdd(aPlanilha, AllTrim(TRB->R_HISTOR))
			aAdd(aPlanilha, AllTrim(TRB->R_BANCO))
			aAdd(aPlanilha, AllTrim(TRB->R_AGENCIA))
			aAdd(aPlanilha, AllTrim(TRB->R_CTACOR))
			aAdd(aPlanilha, NoRound(TRB->R_VALOR, 2))
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

@ nLin++, 05 PSay "Quantidade de provisões de títulos NFS.: " + Transform(nNumSD2, "@E 999,999,999")
@ nLin++, 05 PSay "Quantidade de devoluções de vendas NFE.: " + Transform(nNumSD1, "@E 999,999,999")
@ nLin++, 05 PSay "Quantidade de provisões manuais........: " + Transform(nNumSE1, "@E 999,999,999")
@ nLin++, 05 PSay "Quantidade de baixas/movim. financeiros: " + Transform(nNumSE5, "@E 999,999,999")
@ nLin++, 05 PSay "Quantidade de lançamentos contábeis....: " + Transform(nNumCT2, "@E 999,999,999")
@ nLin++, 00 PSay __PrtThinLine()
@ nLin++, 05 PSay "% provisões tít. NFS com reg. contábil.: " + Transform((nSD2xCT2 / nNumSD2) * 100, "@E 999,999.99 %")
@ nLin++, 05 PSay "% devoluções vendas NFE com reg. contáb: " + Transform((nSD1xCT2 / nNumSD1) * 100, "@E 999,999.99 %")
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
fErase(cIndex4 + OrdBagExt())
fErase(cIndex5 + OrdBagExt())
Return()



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FA190ImpR4 ³ Autor ³ Adrianne Furtado      ³ Data ³ 05.09.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rela‡„o das baixas                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FA190ImpR4(nOrdem,aTotais)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ aTotais   - Array que retorna o totalizador especifico de    ³±±
±±³          ³ 			   cada quebra de secao                             ³±±
±±³          ³ oReport   - objeto da classe TReport                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³aRelat[x][01]: Prefixo			³
//³         [02]: Numero 			³
//³         [03]: Parcela			³
//³         [04]: Tipo do Documento	³
//³         [05]: Cod Cliente/Fornec³
//³         [06]: Nome Cli/Fornec	³
//³         [07]: Natureza         	³
//³         [08]: Vencimento       	³
//³         [09]: Historico       	³
//³         [10]: Data de Baixa    	³
//³         [11]: Valor Original   	³
//³         [12]: Jur/Multa        	³
//³         [13]: Correcao         	³
//³         [14]: Descontos        	³
//³         [15]: Abatimento       	³
//³         [16]: Impostos         	³
//³         [17]: Total Pago       	³
//³         [18]: Banco            	³
//³         [19]: Data Digitacao   	³
//³         [20]: Motivo           	³
//³         [21]: Filial de Origem 	³
exclui//³         [22]: Filial            ³
//³         [23]: E5_BENEF - cCliFor³
//³         [24]: E5_LOTE          	³
//³         [25]: E5_DTDISPO        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

TRB->R_DTMOV	:= TEMP->E5_DATA
TRB->R_TPMOV	:= "BAIXA"
TRB->R_PREFIXO	:= TEMP->E5_PREFIXO
TRB->R_NUM		:= TEMP->E5_NUMERO
TRB->R_PARCELA	:= TEMP->E5_PARCELA
TRB->R_TIPO		:= TEMP->E5_TIPO
TRB->R_CLIENTE	:= TEMP->E5_CLIFOR
TRB->R_LOJA		:= TEMP->E5_LOJA
TRB->R_BANCO	:= TEMP->E5_BANCO
TRB->R_AGENCIA	:= TEMP->E5_AGENCIA
TRB->R_CTACOR	:= TEMP->E5_CONTA
TRB->R_NREDUZ	:= SA1->A1_NREDUZ
TRB->R_VALOR	:= TEMP->E5_VALOR
/*/


Static Function BaixaSE5(dDtIni, dDtFim, cTpCarteira, lConsMovFin, cChqAglut)
//lconsmovfin = mv_par16
//cchqaglut = mv_par37
Local aRet 			:= {}
Local cExp			:= ""
Local nValor		:= 0
Local nDesc			:= 0
Local nJuros		:= 0
Local nMulta		:= 0
Local nJurMul		:= 0
Local nCM			:= 0
Local nVlMovFin		:= 0
Local nAbatLiq 		:= 0
Local nTotAbImp 	:= 0
Local lBxTit		:= .F.
Local lOriginal		:= .T.
Local nAbat 		:= 0
Local lManual 		:= .F.
Local nRecSe5 		:= 0
Local cMotBaixa		:= CriaVar("E5_MOTBX")
Local cCliFor190	:= ""
Local aTam 			:= iif(cTpCarteira == "R", TamSX3("E1_CLIENTE"), TamSX3("E2_FORNECE"))
Local aStru			:= SE5->(DbStruct())
Local lAchou		:= .F.
Local lAchouEmp		:= .T.
Local lAchouEst		:= .F.
Local nTamEH		:= TamSx3("EH_NUMERO")[1]
Local nTamEI		:= TamSx3("EI_NUMERO")[1]+TamSx3("EI_REVISAO")[1]+TamSx3("EI_SEQ")[1]
Local cChaveNSE5	:= ""
Local nRecSE2		:= 0
Local nTaxa			:= 0
Local lUltBaixa 	:= .F.
Local cChaveSE1 	:= ""
Local cSeqSE5 		:= ""
Local nValTroco 	:= 0
Local li 			:= 1
Local cMascNat 		:= ""
Local cChave		:= SE5->(IndexKey(1))

//Controla o Pis Cofins e Csll na baixa (1-Retem PCC na Baixa ou 2-Retem PCC na Emissão(default))
Local lPccBxCr		:= If(FindFunction("FPccBxCr"),FPccBxCr(),.F.)
Local nPccBxCr 		:= 0
//Controla o Pis Cofins e Csll na RA (1 = Controla retenção de impostos no RA; ou 2 = Não controla retenção de impostos no RA(default))
Local lRaRtImp  	:= If(FindFunction("FRaRtImp"),FRaRtImp(),.F.)
Local lPCCBaixa 	:= 	SuperGetMv("MV_BX10925", .T., "2") == "1"  .and.;
						SE5->(FieldPos("E5_VRETPIS")) > 0 .and.;
						SE5->(FieldPos("E5_VRETCOF")) > 0 .and.;
						SE5->(FieldPos("E5_VRETCSL")) > 0 .and.;
						SE5->(FieldPos("E5_PRETPIS")) > 0 .and.;
						SE5->(FieldPos("E5_PRETCOF")) > 0 .and.;
						SE5->(FieldPos("E5_PRETCSL")) > 0 .and.;
						SE2->(FieldPos("E2_SEQBX")) > 0 .and.;
						SFQ->(FieldPos("FQ_SEQDES")) > 0
Local cBanco,cNatureza,cAnterior,cCliFor,dDigit,cLoja, cCond3, nVlr, cHistorico, dDtMovFin, nI,;
	  cCarteira, cQuery, cFilTrb, cChave, cFilOrig, nRecno, aAreaSE5, aAreaSE2, aAreabk, cAuxCliFor,;
	  cAuxLote, dAuxDtDispo, cAge, cContaBco, cTipoDoc, cDocumen

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atribui valores as variaveis ref a filiais                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Definicao das condicoes e ordem de impressao, de acordo com a ordem escolhida pelo
// usuario.
DbSelectArea("SE5")
cQuery := ""
aEval(DbStruct(),{|e| cQuery += "," + AllTrim(e[1])})

//cQuery +=       "E5_DATA    <= '" + DTOS(dDataBase) + "' AND "
//cQuery += "      E5_BANCO   between '" + mv_par03       + "' AND '" + mv_par04       + "' AND "
/*/-- Realiza filtragem pela natureza principal
If mv_par39 == 2
	cQuery +=  " E5_NATUREZ between '" + mv_par05       + "' AND '" + mv_par06     	+ "' AND "
Else
	cQuery +=       " (E5_NATUREZ between '" + mv_par05       + "' AND '" + mv_par06       + "' OR "
	cQuery +=       " EXISTS (SELECT EV_FILIAL, EV_PREFIXO, EV_NUM, EV_PARCELA, EV_CLIFOR, EV_LOJA "
	cQuery +=                 " FROM "+RetSqlName("SEV")+" SEV "
	cQuery +=                " WHERE E5_FILIAL  = EV_FILIAL AND "
	cQuery +=                       "E5_PREFIXO = EV_PREFIXO AND "
	cQuery +=                       "E5_NUMERO  = EV_NUM AND "
	cQuery +=                       "E5_PARCELA = EV_PARCELA AND "
	cQuery +=                       "E5_TIPO    = EV_TIPO AND "
	cQuery +=                       "E5_CLIFOR  = EV_CLIFOR AND "
	cQuery +=                       "E5_LOJA    = EV_LOJA AND "
	cQuery +=                       "EV_NATUREZ between '" + mv_par05 + "' AND '" + mv_par06 + "' AND "
	cQuery +=                       "SEV.D_E_L_E_T_ = ' ')) AND "
EndIf
cQuery +=  "      E5_CLIFOR  between '" + mv_par07       + "' AND '" + mv_par08       + "' AND "
cQuery += "      E5_DTDIGIT between '" + DTOS(mv_par09) + "' AND '" + DTOS(mv_par10) + "' AND "
cQuery += "      E5_LOTE    between '" + mv_par20       + "' AND '" + mv_par21       + "' AND "
cQuery += "      E5_LOJA    between '" + mv_par22       + "' AND '" + mv_par23 	    + "' AND "
cQuery += "      E5_PREFIXO between '" + mv_par26       + "' AND '" + mv_par27 	    + "' AND "
*/


// Obtem os registros a serem processados
cQuery := "SELECT " +SubStr(cQuery,2)
cQuery +=         ",SE5.R_E_C_N_O_ SE5RECNO "
cQuery += "FROM " + RetSqlName("SE5")+" SE5 "
cQuery += "WHERE SE5.E5_FILIAL = '" + xFilial("SE5") + "' "
cQuery +=       "AND SE5.E5_RECPAG = '" + cTpCarteira + "' "
cQuery +=       "AND SE5.E5_DATA BETWEEN '" + dTOs(dDtIni) + "' AND '" + dTOs(dDtFim) + "' "
cQuery +=       "AND SE5.E5_TIPODOC NOT IN ('DC','D2','JR','J2','TL','MT','M2','CM','C2','TR','TE') "

cQuery +=       "AND SE5.E5_SITUACA NOT IN ('C','E','X') "
cQuery +=       "AND ((SE5.E5_TIPODOC = 'CD' AND SE5.E5_VENCTO <= SE5. E5_DATA) OR SE5.E5_TIPODOC <> 'CD') "
cQuery +=       "AND SE5.E5_HISTOR NOT LIKE '%Baixa Automatica / Lote%' "
if cTpCarteira == "P"
	cQuery +=   "AND SE5.E5_TIPODOC <> 'E2' "
endif
If !lConsMovFin
	cQuery +=   "AND SE5.E5_TIPODOC <> '" + space(Len(SE5->E5_TIPODOC)) + "' "
	cQuery +=   "AND SE5.E5_NUMERO  <> '" + space(Len(SE5->E5_NUMERO)) + "' "
	cQuery +=   "AND SE5.E5_TIPODOC <> 'CH' "
Endif
cQuery +=       "AND SE5.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY " + SqlOrder(cChave)
dbUseArea(.T., "TOPCONN", TCGenQry(,,ChangeQuery(cQuery)), "NEWSE5", .F., .T.)
For nI := 1 TO LEN(aStru)
	If aStru[nI][2] != "C"
		TCSetField("NEWSE5", aStru[nI][1], aStru[nI][2], aStru[nI][3], aStru[nI][4])
	EndIf
Next

dbSelectArea("NEWSE5")
dbGoTop()
do while NEWSE5->(!Eof() .and. E5_FILIAL==xFilial("SE5"))
	
	DbSelectArea("NEWSE5")
	// Testa condicoes de filtro
//	If !Fr190TstCond(.F.)
//		NEWSE5->(dbSkip())		      // filtro de registros desnecessarios
//		Loop
//	Endif
	
	If (NEWSE5->E5_RECPAG == "R" .and. ! (NEWSE5->E5_TIPO $ "PA /"+MV_CPNEG )) .or. ;	//Titulo normal
		(NEWSE5->E5_RECPAG == "P" .and.   (NEWSE5->E5_TIPO $ "RA /"+MV_CRNEG )) 	//Adiantamento
		cCarteira := "R"
	Else
		cCarteira := "P"
	Endif
	
	dbSelectArea("NEWSE5")
	cAnterior 	:= E5_DATA
	
	While NEWSE5->(!EOF() .and. E5_FILIAL==xFilial("SE5") .and. E5_DATA=cAnterior)
		
		lManual := .f.
		dbSelectArea("NEWSE5")
		
		If (Empty(NEWSE5->E5_TIPODOC) .And. lConsMovFin) .Or.;
			(Empty(NEWSE5->E5_NUMERO)  .And. lConsMovFin)
			lManual := .t.
		EndIf
		
		// Testa condicoes de filtro
//		If !Fr190TstCond(.T.)
//			dbSelectArea("NEWSE5")
//			NEWSE5->(dbSkip())		      // filtro de registros desnecessarios
//			Loop
//		Endif
		
		// Imprime somente cheques
		If cChqAglut == "C" .and. NEWSE5->E5_TIPODOC == "BA"
			
			aAreaSE5 := SE5->(GetArea())
			lAchou := .F.
			
			SE5->(dbSetOrder(11))
			cChaveNSE5	:= NEWSE5->(E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ)
			SE5->(MsSeek(xFilial("SE5")+cChaveNSE5))
			
			// Procura o cheque aglutinado, se encontrar, marca lAchou := .T. e despreza
			WHILE SE5->(!EOF()) .And. SE5->(E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ)	== cChaveNSE5
				If SE5->E5_TIPODOC == "CH"
					lAchou := .T.
					Exit
				Endif
				SE5->(dbSkip())
			Enddo
			RestArea(aAreaSE5)
			// Achou cheque aglutinado para a baixa, despreza o registro
			If lAchou
				NEWSE5->(dbSkip())
				Loop
			Endif
			
		ElseIf cChqAglut == "B" .And. NEWSE5->E5_TIPODOC == "CH" //somente baixas
			
			aAreaSE5 := SE5->(GetArea())
			lAchou := .F.
			
			SE5->(dbSetOrder(11))
			cChaveNSE5	:= NEWSE5->(E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ)
			SE5->(MsSeek(xFilial("SE5")+cChaveNSE5))
			
			// Procura a baixa aglutinada, se encontrar despreza o movimento bancario
			WHILE SE5->(!EOF()) .And. SE5->(E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ)	== cChaveNSE5
				If SE5->E5_TIPODOC $ "BA"
					lAchou := .T.
					Exit
				Endif
				SE5->(dbSkip())
			Enddo
			RestArea(aAreaSE5)
			// Achou cheque aglutinado para a baixa, despreza o registro
			If lAchou
				NEWSE5->(dbSkip())
				Loop
			Endif
		Endif
		
		cNumero    	:= NEWSE5->E5_NUMERO
		cPrefixo   	:= NEWSE5->E5_PREFIXO
		cParcela   	:= NEWSE5->E5_PARCELA
		dBaixa     	:= NEWSE5->E5_DATA
		cBanco     	:= NEWSE5->E5_BANCO
		cAge			:= NEWSE5->E5_AGENCIA
		cContaBco		:= NEWSE5->E5_CONTA
		cNatureza  	:= NEWSE5->E5_NATUREZ
		cCliFor    	:= NEWSE5->E5_BENEF
		cSeq       	:= NEWSE5->E5_SEQ
		cNumCheq   	:= NEWSE5->E5_NUMCHEQ
		cMotBaixa	:= NEWSE5->E5_MOTBX
		cCheque    	:= NEWSE5->E5_NUMCHEQ
		cTipo      	:= NEWSE5->E5_TIPO
		cFornece   	:= NEWSE5->E5_CLIFOR
		cLoja      	:= NEWSE5->E5_LOJA
		dDigit     	:= NEWSE5->E5_DTDIGIT
		lBxTit	  	:= .F.
		cFilorig    := NEWSE5->E5_FILORIG
		
		If (NEWSE5->E5_RECPAG == "R" .and. ! (NEWSE5->E5_TIPO $ "PA /"+MV_CPNEG )) .or. ;	//Titulo normal
			(NEWSE5->E5_RECPAG == "P" .and.   (NEWSE5->E5_TIPO $ "RA /"+MV_CRNEG )) 	//Adiantamento
			dbSelectArea("SE1")
			dbSetOrder(1)
			lBxTit := MsSeek(cFilial+cPrefixo+cNumero+cParcela+cTipo)
			If !lBxTit
				lBxTit := dbSeek(NEWSE5->E5_FILORIG+cPrefixo+cNumero+cParcela+cTipo)
			Endif
			cCarteira := "R"
			dDtMovFin := IIF (lManual,CTOD("//"), DataValida(SE1->E1_VENCTO,.T.))
			While SE1->(!Eof()) .and. SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO==cPrefixo+cNumero+cParcela+cTipo
				If SE1->E1_CLIENTE == cFornece .And. SE1->E1_LOJA == cLoja	// Cliente igual, Ok
					Exit
				Endif
				SE1->( dbSkip() )
			EndDo
			
			cCond3:="E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DtoS(E5_DATA)+E5_SEQ+E5_NUMCHEQ==cPrefixo+cNumero+cParcela+cTipo+DtoS(dBaixa)+cSeq+cNumCheq"
			nDesc := nJuros := nValor := nMulta := nJurMul := nCM := nVlMovFin := 0
		Else
			dbSelectArea("SE2")
			DbSetOrder(1)
			cCarteira := "P"
			lBxTit 	:= MsSeek(cFilial+cPrefixo+cNumero+cParcela+cTipo+cFornece+cLoja)
			
			Iif(lBxTit, nRecSE2	:= SE2->(Recno()), nRecSE2 := 0 )
			
			If !lBxTit
				lBxTit := dbSeek(NEWSE5->E5_FILORIG+cPrefixo+cNumero+cParcela+cTipo+cFornece+cLoja)
			Endif
			dDtMovFin := IIF(lManual,CTOD("//"),DataValida(SE2->E2_VENCTO,.T.))
			cCond3:="E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+DtoS(E5_DATA)+E5_SEQ+E5_NUMCHEQ==cPrefixo+cNumero+cParcela+cTipo+cFornece+DtoS(dBaixa)+cSeq+cNumCheq"
			nDesc := nJuros := nValor := nMulta := nJurMul := nCM := nVlMovFin := 0
			cCheque    := Iif(Empty(NEWSE5->E5_NUMCHEQ),SE2->E2_NUMBCO,NEWSE5->E5_NUMCHEQ)
		Endif
		dbSelectArea("NEWSE5")
		cHistorico := Space(40)
		While NEWSE5->( !Eof() .and. E5_FILIAL==xFilial("SE5") .and. &cCond3)
			
			dbSelectArea("NEWSE5")
			cCheque    := NEWSE5->E5_NUMCHEQ
			
			lAchouEmp := .T.
			lAchouEst := .F.
			
			// Testa condicoes de filtro
//			If !Fr190TstCond(.T.)
//				dbSelectArea("NEWSE5")
//				NEWSE5->(dbSkip())		      // filtro de registros desnecessarios
//				Loop
//			Endif
			
			If NEWSE5->E5_SITUACA $ "C/E/X"
				dbSelectArea("NEWSE5")
				NEWSE5->( dbSkip() )
				Loop
			EndIF
			
			If NEWSE5->E5_LOJA != cLoja
				Exit
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Nao imprime os registros de emprestimos excluidos ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If NEWSE5->E5_TIPODOC == "EP"
				aAreaSE5 := NEWSE5->(GetArea())
				dbSelectArea("SEH")
				dbSetOrder(1)
				lAchouEmp := MsSeek(xFilial("SEH")+Substr(NEWSE5->E5_DOCUMEN,1,nTamEH))
				RestArea(aAreaSE5)
				If !lAchouEmp
					NEWSE5->(dbSkip())
					Loop
				EndIf
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Nao imprime os registros de pagamento de emprestimos estornados ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If NEWSE5->E5_TIPODOC == "PE"
				aAreaSE5 := NEWSE5->(GetArea())
				dbSelectArea("SEI")
				dbSetOrder(1)
				If	MsSeek(xFilial("SEI")+"EMP"+Substr(NEWSE5->E5_DOCUMEN,1,nTamEI))
					If SEI->EI_STATUS == "C"
						lAchouEst := .T.
					EndIf
				EndIf
				RestArea(aAreaSE5)
				If lAchouEst
					NEWSE5->(dbSkip())
					Loop
				EndIf
			EndIf
			
	
			dBaixa     	:= NEWSE5->E5_DATA
			cBanco     	:= NEWSE5->E5_BANCO
			cAge			:= NEWSE5->E5_AGENCIA
			cContaBco		:= NEWSE5->E5_CONTA
			cNatureza  	:= NEWSE5->E5_NATUREZ
			cCliFor    	:= NEWSE5->E5_BENEF
			cSeq       	:= NEWSE5->E5_SEQ
			cNumCheq   	:= NEWSE5->E5_NUMCHEQ
			cMotBaixa	:= NEWSE5->E5_MOTBX
			cTipo190		:= NEWSE5->E5_TIPO
			cFilorig    := NEWSE5->E5_FILORIG
			cTipoDoc	:= NEWSE5->E5_TIPODOC
			cDocumen	:= NEWSE5->E5_DOCUMEN
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Obter moeda da conta no Banco.                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			
			If !Empty(NEWSE5->E5_NUMERO)
				If (NEWSE5->E5_RECPAG == "R" .and. !(NEWSE5->E5_TIPO $ MVPAGANT+"/"+MV_CPNEG)) .or. ;
					(NEWSE5->E5_RECPAG == "P" .and. NEWSE5->E5_TIPO $ MVRECANT+"/"+MV_CRNEG) .Or.;
					(NEWSE5->E5_RECPAG == "P" .And. NEWSE5->E5_TIPODOC $ "DB#OD")
					dbSelectArea( "SA1")
					dbSetOrder(1)
					lAchou := .F.
					If Empty(xFilial("SA1"))  //SA1 Compartilhado
						If dbSeek(xFilial("SA1")+NEWSE5->E5_CLIFOR+NEWSE5->E5_LOJA)
							lAchou := .T.
						Endif
					Else
						cFilOrig := NEWSE5->E5_FILIAL //Procuro SA1 pela filial do movimento
						If dbSeek(cFilOrig+NEWSE5->E5_CLIFOR+NEWSE5->E5_LOJA)
							If Upper(Alltrim(SA1->A1_NREDUZ)) == Upper(Alltrim(NEWSE5->E5_BENEF))
								lAchou := .T.
							Else
								cFilOrig := NEWSE5->E5_FILORIG //Procuro SA1 pela filial origem
								If dbSeek(cFilOrig+NEWSE5->E5_CLIFOR+NEWSE5->E5_LOJA)
									If Upper(Alltrim(SA1->A1_NREDUZ)) == Upper(Alltrim(NEWSE5->E5_BENEF))
										lAchou := .T.
									Endif
								Endif
							Endif
						Else
							cFilOrig := NEWSE5->E5_FILORIG	//Procuro SA1 pela filial origem
							If dbSeek(cFilOrig+NEWSE5->E5_CLIFOR+NEWSE5->E5_LOJA)
								If Upper(Alltrim(SA1->A1_NREDUZ)) == Upper(Alltrim(NEWSE5->E5_BENEF))
									lAchou := .T.
								Endif
							Endif
						Endif
					EndIF
					If lAchou
						cCliFor := SA1->A1_NOME
					Else
						cCliFor	:= 	Upper(Alltrim(NEWSE5->E5_BENEF))
					Endif
				Else
					dbSelectArea( "SA2")
					dbSetOrder(1)
					lAchou := .F.
					If Empty(FwFilial("SA2"))  //SA2 Compartilhado
						If dbSeek(xFilial("SA2")+NEWSE5->E5_CLIFOR+NEWSE5->E5_LOJA)
							lAchou := .T.
						Endif
					Else
						cFilOrig := NEWSE5->E5_FILIAL //Procuro SA2 pela filial do movimento
						If dbSeek(cFilOrig+NEWSE5->E5_CLIFOR+NEWSE5->E5_LOJA)
							If Upper(Alltrim(SA2->A2_NREDUZ)) == Upper(Alltrim(NEWSE5->E5_BENEF))
								lAchou := .T.
							Else
								cFilOrig := NEWSE5->E5_FILORIG //Procuro SA2 pela filial origem
								If dbSeek(cFilOrig+NEWSE5->E5_CLIFOR+NEWSE5->E5_LOJA)
									If Upper(Alltrim(SA2->A2_NREDUZ)) == Upper(Alltrim(NEWSE5->E5_BENEF))
										lAchou := .T.
									Endif
								Endif
							Endif
						Else
							cFilOrig := NEWSE5->E5_FILORIG	//Procuro SA2 pela filial origem
							If dbSeek(cFilOrig+NEWSE5->E5_CLIFOR+NEWSE5->E5_LOJA)
								If Upper(Alltrim(SA2->A2_NREDUZ)) == Upper(Alltrim(NEWSE5->E5_BENEF))
									lAchou := .T.
								Endif
							Endif
						Endif
					EndIF
					If lAchou
						cCliFor := SA2->A2_NOME
					Else
						cCliFor	:= 	Upper(Alltrim(NEWSE5->E5_BENEF))
					Endif
				EndIf
			EndIf
			dbSelectArea("SM2")
			dbSetOrder(1)
			dbSeek(NEWSE5->E5_DATA)
			dbSelectArea("NEWSE5")
			nTaxa:= 0
			
			
			If !Empty(NEWSE5->E5_TXMOEDA)
				nTaxa:=NEWSE5->E5_TXMOEDA
			Else
				nTaxa := NEWSE5->E5_VALOR / NEWSE5->E5_VLMOED2
			EndIf
			
			nRecSe5:=NEWSE5->SE5RECNO
			nDesc+=NEWSE5->E5_VLDESCO
			nJuros+=NEWSE5->E5_VLJUROS
			nMulta+=NEWSE5->E5_VLMULTA
			nJurMul+= nJuros + nMulta
			nCM+=NEWSE5->E5_VLCORRE
			
			If lPccBaixa .and. Empty(NEWSE5->E5_PRETPIS) .And. Empty(NEWSE5->E5_PRETCOF) .And. Empty(NEWSE5->E5_PRETCSL)
				If nRecSE2 > 0
					
					aAreabk  := Getarea()
					aAreaSE2 := SE2->(Getarea())
					SE2->(DbGoto(nRecSE2))
					
					nTotAbImp+=(NEWSE5->E5_VRETPIS)+(NEWSE5->E5_VRETCOF)+(NEWSE5->E5_VRETCSL)+;
					SE2->E2_INSS+ SE2->E2_ISS+ SE2->E2_IRRF
					
					Restarea(aAreaSE2)
					Restarea(aAreabk)
				Else
					nTotAbImp+=(NEWSE5->E5_VRETPIS)+(NEWSE5->E5_VRETCOF)+(NEWSE5->E5_VRETCSL)
				Endif
			Endif
			
			If NEWSE5->E5_TIPODOC $ "VL/V2/BA/RA/PA/CP"
				nValTroco := 0
				cHistorico := NEWSE5->E5_HISTOR
					nValor += NEWSE5->E5_VALOR
		

				dbSelectArea("NEWSE5")
				
				nValor -= nValTroco
				
				//Pcc Baixa CR
				If cCarteira == "R" .and. lPccBxCr .And. IiF(lRaRtImp,NEWSE5->E5_TIPO $ MVRECANT,.T.)
					If Empty(NEWSE5->E5_PRETPIS)
						nPccBxCr += NEWSE5->E5_VRETPIS
					Endif
					If Empty(NEWSE5->E5_PRETCOF)
						nPccBxCr += NEWSE5->E5_VRETCOF
					Endif
					If Empty(NEWSE5->E5_PRETCSL)
						nPccBxCr += NEWSE5->E5_VRETCSL
					Endif
				Endif
				
			Else
				nVlMovFin+=NEWSE5->E5_VALOR
				cHistorico := Iif(Empty(NEWSE5->E5_HISTOR),"MOV FIN MANUAL",NEWSE5->E5_HISTOR)
				cNatureza  	:= NEWSE5->E5_NATUREZ
			Endif
			
			cAuxCliFor  := cCliFor
			cAuxLote    := E5_LOTE
			dAuxDtDispo := E5_DTDISPO
			
			dbSkip()
			If lManual		// forca a saida do looping se for mov manual
				Exit
			Endif
		EndDO
		
		If (nDesc+nValor+nJurMul+nCM+nVlMovFin) > 0
			AAdd(aRet, Array(36))
			
			// Defaults >>>
			aRet[Li][01] := ""
			aRet[Li][02] := ""
			aRet[Li][03] := ""
			aRet[Li][04] := ""
			aRet[Li][05] := ""
			// <<< Defaults
			
			aRet[Li][23] := cAuxCliFor
			aRet[Li][24] := cAuxLote
			aRet[Li][25] := dAuxDtDispo
			aRet[Li][32] := cSeq
			
			aRet[Li][34] := cFornece
			aRet[Li][35] := cLoja
			aRet[Li][36] := cDocumen
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ C lculo do Abatimento        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cCarteira == "R" .and. !lManual
				dbSelectArea("SE1")
				nRecno := Recno()
				nAbat := 0
				nAbatLiq := 0
				If !SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Encontra a ultima sequencia de baixa na SE5 a partir do título da SE1 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAreaSE1 := SE1->(GetArea())
					dbSelectArea("SE5")
					dbSetOrder(7)
					cChaveSE1 := SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)
					SE5->(MsSeek(xFilial("SE5")+cChaveSE1))
					
					cSeqSE5 := SE5->E5_SEQ
					
					While SE5->(!EOF()) .And. cChaveSE1 == SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)
						If SE5->E5_SEQ > cSeqSE5
							cSeqSE5 := SE5->E5_SEQ
						Endif
						SE5->(dbSkip())
					Enddo
					
					lUltBaixa := .F.
					SE5->(MsSeek(xFilial("SE5")+cChaveSE1+cSeqSE5))
					
					If SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ) == cPrefixo+cNumero+cParcela+cTipo+cFornece+cLoja+cSeq .And.;
						Empty(SE1->E1_SALDO)
						If SE1->E1_VALOR <> SE1->E1_VALLIQ
							lUltBaixa := .T.
						EndIf
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Calcula o valor total de abatimento do titulo e impostos se houver ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nTotAbImp  := 0
					If lUltBaixa
						nAbat := SumAbatRec(cPrefixo,cNumero,cParcela,SE1->E1_MOEDA,"V",dBaixa,@nTotAbImp)
						nAbatLiq := nAbat - nTotAbImp
					EndIf
					
					lUltBaixa := .F.
					RestArea(aAreaSE1)
				EndIf
				dbSelectArea("SE1")
				dbGoTo(nRecno)
			Elseif !lManual
				dbSelectArea("SE2")
				nRecno := Recno()
				nAbat := 0
				nAbatLiq := 0
				If !SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG
					nAbat :=	SomaAbat(cPrefixo,cNumero,cParcela,"P",1,,cFornece,cLoja)
					nAbatLiq := nAbat
				EndIf
				dbSelectArea("SE2")
				dbGoTo(nRecno)
			EndIF
			aRet[li][05]:= " "
			IF cTpCarteira == "R" .and. aTam[1] > 6 .and. !lManual
				If lBxTit
					aRet[li][05] := SE1->E1_CLIENTE
				Endif
				aRet[li][06] := AllTrim(cCliFor)
			Elseif cTpCarteira == "P" .and. aTam[1] > 6 .and. !lManual
				If lBxTit
					aRet[li][05] := SE2->E2_FORNECE
				Endif
				aRet[li][06] := AllTrim(cCliFor)
			Endif
			
			aRet[li][01] := cPrefixo
			aRet[li][02] := cNumero
			aRet[li][03] := cParcela
			aRet[li][04] := cTipo
			
			If !lManual
				dbSelectArea("TRB")
				lOriginal := .T.
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Baixas a Receber             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cCarteira == "R"
					cCliFor190 := SE1->E1_CLIENTE+SE1->E1_LOJA
					nVlr:= SE1->E1_VLCRUZ
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Baixa de PA                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Else
					cCliFor190 := SE2->E2_FORNECE+SE2->E2_LOJA
					
					lCalcIRF:= Posicione("SA2",1,xFilial("SA2")+cCliFor190,"A2_CALCIRF") == "1" .Or.;//1-Normal, 2-Baixa
					Posicione("SA2",1,xFilial("SA2")+cCliFor190,"A2_CALCIRF") == " "
					
					// MV_MRETISS "1" retencao do ISS na Emissao, "2" retencao na Baixa.
					nVlr:= SE2->E2_VLCRUZ+ SE2->E2_INSS+ Iif(GetNewPar('MV_MRETISS',"1")=="1",SE2->E2_ISS,0) +;
					Iif(lCalcIRF,SE2->E2_IRRF,0)
					
				Endif
				aRet[li,28] := nRecSE5
				dbgoto(nRecSe5)
				cFilTrb := If(cCarteira=="R","SE1","SE2")
				IF DbSeek( xFilial(cFilTrb)+cPrefixo+cNumero+cParcela+cCliFor190+cTipo)
					nAbat:=0
					lOriginal := .F.
				Else
					nVlr:=NoRound(nVlr)
				EndIF
			Else
				dbSelectArea("SE5")
				aRet[li,28] := nRecSE5
				dbgoto(nRecSe5)
				nVlr := Round(xMoeda(E5_VALOR,1,1,E5_DATA,2,,E5_TXMOEDA),2)
				nAbat:= 0
				lOriginal := .t.
				nRecSe5:=NEWSE5->SE5RECNO
				dbSelectArea("TRB")
			Endif
			IF cCarteira == "R"
				If ( !lManual )
					cHistorico := Iif(Empty(cHistorico), SE1->E1_HIST, cHistorico )
				EndIf
				If aTam[1] <= 6 .and. !lManual
					If lBxTit
						aRet[li][05] := SE1->E1_CLIENTE
					Endif
					aRet[li][06] := AllTrim(cCliFor)
				Endif
				cMascNat := MascNat(cNatureza)
				aRet[li][07] := If(Len(Alltrim(cNatureza))>8, cNatureza, cMascNat)
				If Empty( dDtMovFin ) .or. dDtMovFin == Nil
					dDtMovFin := CtoD("  /  /  ")
				Endif
				aRet[li][08] := IIf(lManual,dDtMovFin,DataValida(SE1->E1_VENCTO,.T.)) //Vencto
				aRet[li][09] := AllTrim(cHistorico)
				aRet[li][10] := dBaixa
				IF nVlr > 0
					aRet[li][11] := nVlr
				Endif
			Else
				cHistorico := Iif(Empty(cHistorico), SE2->E2_HIST, cHistorico )
				If aTam[1] <= 6 .and. !lManual
					If lBxTit
						aRet[li][05] := SE2->E2_FORNECE
					Endif
					aRet[li][06] := AllTrim(cCliFor)
				Endif
				cMascNat := MascNat(cNatureza)
				aRet[li][07] := If(Len(Alltrim(cNatureza))>8, cNatureza, cMascNat)
				If Empty( dDtMovFin ) .or. dDtMovFin == Nil
					dDtMovFin := CtoD("  /  /  ")
				Endif
				aRet[li][08] := IIf(lManual,dDtMovFin,DataValida(SE2->E2_VENCTO,.T.))
				If !Empty(cCheque)
					aRet[li][09] := ALLTRIM(cCheque)+"/"+Trim(cHistorico)
				Else
					aRet[li][09] := ALLTRIM(cHistorico)
				EndIf
				aRet[li][10] := dBaixa
				IF nVlr > 0
					aRet[li][11] := nVlr
				Endif
			Endif
			aRet[li][12] := nJurMul
			
			If cCarteira == "R" .and. SE1->E1_MOEDA == 1
				aRet[li][13] := 0
				
			ElseIf cCarteira == "P" .and. SE2->E2_MOEDA == 1
				aRet[li][13] := 0
				
			Else
				aRet[li][13] := nCM
				
			Endif
			
			//PCC Baixa CR
			//Somo aos abatimentos de impostos, os impostos PCC na baixa.
			//Caso o calculo do PCC CR seja pela emissao, esta variavel estara zerada
			nTotAbImp += nPccBxCr
			
			aRet[li][14] := nDesc
			aRet[li][15] := nAbatLiq
			aRet[li][16] := nTotAbImp
			If nVlMovFin > 0
				aRet[li][17] := nVlMovFin
			Else
				aRet[li][17] := nValor
			Endif
			aRet[li][18] := cBanco
			aRet[li][30] := cAge
			aRet[li][31] := cContaBco
			aRet[li][32] := cTipoDoc
			If Len(DtoC(dDigit)) <= 8
				aRet[li][19] := dDigit
			Else
				aRet[li][19] := dDigit
			EndIf
			
			If empty(cMotBaixa)
				cMotBaixa := "NOR"  //NORMAL
			Endif
			
			aRet[li][20] := Substr(cMotBaixa,1,3)
			aRet[li][21] := cFilorig
			
			aRet[li][26] := lOriginal
			aRet[li][27] := If( nVlMovFin <> 0, nVlMovFin , If(MovBcoBx(cMotBaixa),nValor,0))
			nDesc := nJurMul := nValor := nCM := nAbat := nTotAbImp := nAbatLiq := nVlMovFin := 0
			nPccBxCr	:= 0		//PCC Baixa CR
			li++
		Endif
		dbSelectArea("NEWSE5")
	Enddo
	
Enddo

dbSelectArea("NEWSE5")
dbCloseArea()

Return(aRet)
