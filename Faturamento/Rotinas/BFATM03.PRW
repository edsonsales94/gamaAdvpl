/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ BFATM03  ³ Por: Adalberto Moreno Batista ³ Data ³05.11.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta lista de notas fiscais para geracao e envio de txt   ³±±
±±³          ³ para o operador logistico realizar a separacao de produtos ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Brasitech                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
#include "rwmake.ch"
#include "protheus.ch"

User Function BFATM03()
Local _cFiltro, _cIndex, _cKey, _nIndex
Local aArea 		:= GetArea()
Local cPerg			:= "BFATM03F"
Local aCabSX1		:= { "X1_GRUPO", "X1_ORDEM", "X1_PERGUNT", "X1_VARIAVL", "X1_TIPO", "X1_TAMANHO", "X1_DECIMAL", "X1_GSC", "X1_VAR01", "X1_DEF01", "X1_DEF02" }
Local aHlp01		:= {"Informe quais registros deseja", "visualizar na tela de browse", "somente as pendentes de envio ou todas"}
Local aRegs			:= {	{cPerg, "01", "Visualiza as NF's ?", "mv_ch1", "N", 01, 0, "C", "mv_par01", "1-Pend. Envio", "2-Todas"} }
Local aCores  		:= {	{'Empty(SF2->F2_X_DTEXP)',		'BR_VERMELHO' },;
							{'!Empty(SF2->F2_X_DTEXP)',	'BR_VERDE' } }
Private cCadastro 	:= "Geração de arquivo para separação de mercadoria"

Private aRotina 	:= {	{ "Pesquisa",	"AxPesqui",	     		0,1},;
							{ "Visualiza",	"U_FTM03_Visual()",		0,2},;
							{ "Envio",		"U_FTM03_Select(.T.)",	0,3},;
							{ "Reenvio",	"U_FTM03_Select(.F.)",	0,3},;
							{ "Cancela",	"U_FTM03_Cancel()",		0,5},;
							{ "Legenda",	"U_FTM03_Legend()",		0,5}}
Private aIndSF2   := {}
Private bFiltraBrw:= {|| Nil}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montando o grupo de perguntas                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
U_BRASX1(aRegs, aCabSX1)	//Funcao contida dentro do BCFGA01.prw
PutSX1Help("P." + AllTrim(cPerg) + "01.", aHlp01, aHlp01, aHlp01)

if !Pergunte(cPerg, .T.)
	Return()
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criando filtro                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SF2")
cCondicao	:= "F2_FILIAL == '" + xFilial("SF2") +"' " + iif(mv_par01 = 1," .and. Empty(F2_X_DTEXP)", "")
bFiltraBrw	:= {|| FilBrowse("SF2", @aIndSF2, @cCondicao) }
Eval(bFiltraBrw)
mBrowse(,,,,"SF2",,,,,,aCores)
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a integridade da rotina                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SF2")
RetIndex("SF2")
dbClearFilter()
aEval(aIndSF2,{|x| Ferase(x[1] + OrdBagExt())})
RestArea(aArea)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ FTM01_Visual ³ Por: Adalberto Moreno Batista       ³ Data ³20/11/2012³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function FTM03_Visual()
Local nI, nUsado
Private aCols		:= {}
Private aHeader	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criando variaveis M->F2_??? da enchoice ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("SF2", .F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montando o aHeader ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                   `
SX3->(dbSetOrder(1))
SX3->(dbSeek("SD2"))
do while SX3->( !eof() .and. X3_ARQUIVO = "SD2" )
	
	if x3Uso(SX3->X3_USADO) .and.;
		cNivel >= SX3->X3_NIVEL .and.;
		!AllTrim(SX3->X3_CAMPO) $ "D2_FILIAL/D2_STSERV/D2_REGWMS"
		
		SX3->( aAdd( aHeader, {	AllTrim(X3_TITULO),;
										X3_CAMPO,;
										X3_PICTURE,;
										X3_TAMANHO,;
										X3_DECIMAL,;
										X3_VLDUSER,;
										X3_USADO,;
										X3_TIPO,;
										X3_ARQUIVO,;
										X3_CONTEXT } ) )
	endif
	
	SX3->( dbSkip() )
enddo

nUsado := Len(aHeader)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montando aCols da getdados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols	:= {}
SD2->( dbSetOrder(3) )
SD2->( dbSeek(xFilial("SD2") + SF2->( F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA )) )
do while SD2->( !eof() .and. D2_FILIAL = xFilial() .and. D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA = SF2->( F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA ))
	aAdd( aCols, Array( nUsado + 1 ) )
	for nI := 1 to nUsado
		aCols[Len(aCols), nI] 	:= SD2->( FieldGet( FieldPos( aHeader[nI,2] ) ) )
	next
	aCols[Len(aCols), nUsado + 1]	:=.F.
	SD2->( dbSkip() )
enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Modelo3(cTitulo, cAliasEnchoice, cAliasGetD,, cLinOk, cTudOk, nOpcE, nOpcG, cFieldOk) ³
//³ Parametros:                                                                           ³
//³ NOME			TIPO   		DESCRICAO   								              ³
//³ cTitulo			Caracter   	Titulo da janela (Obrigatorio)                            ³
//³ cAlias   		Caracter   	Alias da Enchoice (Obrigatorio)      		              ³
//³ cAlias2   		Caracter   	Alias da Getdados (Obrigatorio)      			          ³
//³ aMyEncho   		Vetor  		Array com campos da enchoice                              ³
//³ cLinhaOk   		Caracter   	Funcao para validacao da linha                            ³
//³ cTudoOk   		Caracter   	Funcao para validacao na confirmacao                      ³
//³ nOpcE   		Numerico   	nOpc da Enchoice                                          ³
//³ nOpcG   		Numerico   	nOpc da Getdados                                          ³
//³ cFieldOk   		Caracter   	Validacao para todos os campos da GetDados                ³
//³ lVirtual   		Logico   	Permite visualizar campos virtuais na enchoice            ³
//³ nLinhas   		Numérico   	Numero maximo de linhas na getdados                       ³
//³ aAltEnchoice  	Vetor  		Array com campos alteraveis da Enchoice                   ³
//³ nFreeze   		Numerico   	Congelamento das colunas.                                 ³
//³ aButtons   		Vetor  		Array com botoes de usuario na enchoicebar                ³
//³ aCordW   		Vetor  		Coordenadas da janela                                     ³
//³ nSizeHeader   	Numerico   	Altura da enchoice                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Modelo3(cCadastro, "SF2", "SD2",, ".T.", ".T.", 2, 2, "AllwaysTrue()", .T.,,, 1,,, 250)

dbSelectArea("SF2")
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ FTM01_Select ³ Por: Adalberto Moreno Batista       ³ Data ³ 05/11/12 ³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function FTM03_Select(lFirst)
Local cPerg			:= "BFATM03S"
Local aCabSX1		:= {"X1_GRUPO", "X1_ORDEM", "X1_PERGUNT", "X1_VARIAVL", "X1_TIPO", "X1_TAMANHO", "X1_DECIMAL", "X1_GSC", "X1_VAR01"}
Local aHlp01		:= {"Informe a data de emissão", "inicial", ""}
Local aHlp02		:= {"Informe a data de emissão", "final", ""}
Local aHlp03		:= {"Informe a série da nota fiscal", "", ""}
Local aHlp04		:= {"Informe o número da nota fiscal", "inicial", ""}
Local aHlp05		:= {"Informe o número da nota fiscal", "final", ""}
Local aRegs			:= {{cPerg, "01", "Da Emissao    ?", "mv_ch1", "D", 08, 0, "G", "mv_par01","",""},;
						{cPerg, "02", "Ate a Emissao ?", "mv_ch2", "D", 08, 0, "G", "mv_par02","",""},;
						{cPerg, "03", "Da Série      ?", "mv_ch3", "C", 03, 0, "G", "mv_par03","",""},;
						{cPerg, "04", "Da Nota       ?", "mv_ch4", "C", 09, 0, "G", "mv_par04","",""},;
						{cPerg, "05", "Ate a Nota    ?", "mv_ch5", "C", 09, 0, "G", "mv_par05","",""},;
						{cPerg, "06", "Tipo da NF    ?", "mv_ch6", "N", 01, 0, "C", "mv_par06","1-Venda","2-Remessa"} }
Local cQuery
Local aArqTMP		:= {{"TB_MARCA",	"C", 02, 00},;
						{"TB_DOC",		"C", 09, 00},;
						{"TB_SERIE",	"C", 03, 00},;
						{"TB_EMISSAO",	"D", 08, 00},;
						{"TB_CLIENTE",	"C", 06, 00},;
						{"TB_LOJA",		"C", 02, 00},;
						{"TB_NOMECLI",	"C", 30, 00},;
						{"TB_EST",		"C", 02, 00},;
						{"TB_COND",		"C", 03, 00},;
						{"TB_VALMERC",	"N", 12, 02},;
						{"TB_VALICMS",	"N", 12, 02},;
						{"TB_VALIPI",	"N", 12, 02},;
						{"TB_ICMSRET",	"N", 12, 02},;
						{"TB_VALBRUT",	"N", 12, 02},;
						{"TB_VEND",		"C", 06, 00},;
						{"TB_NOMEVEN",	"C", 40, 00},;
						{"TB_DTEXP",	"D", 08, 00},;
						{"TB_HREXP",	"C", 05, 00},;
						{"TB_RECNO",	"N", 10, 00}}
Local cDBFTMP		:= CriaTrab (aArqTMP , .t.)
Local cEol			:= chr(13) + chr(10)
Private cMarca		:= GetMark()
Private aCampos	:= {	{"TB_MARCA",	"", "  "},;
						{"TB_DOC",		"", "Nota Fiscal"},;
						{"TB_SERIE",	"", "Serie"},;
						{"TB_EMISSAO",	"", "Dt.Emissao"},;
						{"TB_CLIENTE",	"", "Cliente"},;
						{"TB_LOJA",		"", "Loja"},;
						{"TB_NOMECLI",	"", "Nome Cliente"},;
						{"TB_EST",		"", "Estado"},;
						{"TB_COND",		"", "Cond.Pagto"},;
						{"TB_VALMERC",	"", "Vl.Mercadoria",	"@E 999,999,999.99"},;
						{"TB_VALICMS",	"", "Valor ICMS",		"@E 999,999,999.99"},;
						{"TB_VALIPI",	"", "Valor IPI",		"@E 999,999,999.99"},;
						{"TB_ICMSRET",	"", "Vl.ICMS ST",		"@E 999,999,999.99"},;
						{"TB_VALBRUT",	"", "Valor Nota",		"@E 999,999,999.99"},;
						{"TB_VEND",		"", "Vendedor"},;
						{"TB_NOMEVEN",	"", "Nome Vendedor"},;
						{"TB_DTEXP",	"", "Data exportação"},;
						{"TB_HREXP",	"", "Hora exportação"}}
Private oSel, oMark

if !lFirst
	MsgBox("Você selecionou a opção de reenvio de registros de notas fiscais para o operador logístico.", "Atenção", "INFO")
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montando o grupo de perguntas                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
U_BRASX1(aRegs, aCabSX1)	//Funcao contida dentro do BCFGA01.prw
PutSX1Help("P." + AllTrim(cPerg) + "01.", aHlp01, aHlp01, aHlp01)
PutSX1Help("P." + AllTrim(cPerg) + "02.", aHlp02, aHlp02, aHlp02)
PutSX1Help("P." + AllTrim(cPerg) + "03.", aHlp03, aHlp03, aHlp03)
PutSX1Help("P." + AllTrim(cPerg) + "04.", aHlp04, aHlp04, aHlp04)
PutSX1Help("P." + AllTrim(cPerg) + "05.", aHlp05, aHlp05, aHlp05)

if !Pergunte(cPerg, .T.)
	Return()
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha as areas de trabalho, caso estejam abertas               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if Select("TRB") > 0
	TRB->( dbCloseArea() )
endif

if Select("TMP") > 0
	TMP->( dbCloseArea() )
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona os registros validos                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT F2_DOC, F2_SERIE, F2_EMISSAO, F2_COND, F2_CLIENTE, F2_LOJA, F2_VEND1, F2_EST, F2_VALMERC, F2_VALICM, F2_VALIPI, F2_ICMSRET, F2_VALBRUT, SF2.R_E_C_N_O_ REGISTRO "
cQuery += "FROM " + RetSQLName("SF2") + " SF2 "
cQuery += "JOIN " + RetSQLName("SA1") + " SA1 " 
cQuery += "ON SA1.A1_COD = SF2.F2_CLIENTE AND SA1.A1_LOJA = SF2.F2_LOJA"
cQuery += "WHERE SF2.F2_FILIAL = '" + xFilial("SF2") + "' "
cQuery += "AND SF2.F2_EMISSAO BETWEEN '" + dTOs(mv_par01) + "' AND '" + dTOs(mv_par02) + "' "
cQuery += "AND SF2.F2_SERIE = '" + mv_par03 + "' "
cQuery += "AND SF2.F2_DOC BETWEEN '" + mv_par04 + "' AND '" + mv_par05 + "' "
if lFirst
	cQuery += "AND SF2.F2_X_DTEXP = ' ' "		//primeiro envio
else
	cQuery += "AND SF2.F2_X_DTEXP != ' ' "		//reenvio
endif
if mv_par06 == 1
	cQuery += "AND SF2.F2_X_OPLOG = 'NN' " //somente se nao houver bloqueio(NN) 
elseIf mv_par06 == 2
	cQuery += "AND SF2.F2_X_OPLOG = 'ON' " //Nota de Remessao para o Operador Logistico(ON)
endif
cQuery += "AND SF2.D_E_L_E_T_=' ' "
cQuery += "ORDER BY F2_SERIE,F2_DOC"
cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRB", .F., .T.)
tcSetField("TRB", "F2_EMISSAO", "D")

dbUseArea(.T.,,cDBFTMP,"TMP",.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravando em tabela temporaria                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TRB")
dbGoTop()
do while !eof()
	TMP->( RecLock("TMP",.T.) )
	TMP->TB_MARCA		:= cMarca
	TMP->TB_DOC			:= TRB->F2_DOC
	TMP->TB_SERIE		:= TRB->F2_SERIE
	TMP->TB_EMISSAO		:= TRB->F2_EMISSAO
	TMP->TB_CLIENTE		:= TRB->F2_CLIENTE
	TMP->TB_LOJA		:= TRB->F2_LOJA
	TMP->TB_NOMECLI		:= GetAdvFVal("SA1", "A1_NOME", xFilial("SA1") + TRB->F2_CLIENTE + TRB->F2_LOJA, 1)
	TMP->TB_VEND		:= TRB->F2_VEND1
	TMP->TB_NOMEVEN		:= GetAdvFVal("SA3", "A3_NOME", xFilial("SA3") + TRB->F2_VEND1, 1)
	TMP->TB_EST			:= TRB->F2_EST
	TMP->TB_COND		:= TRB->F2_COND
	TMP->TB_VALBRUT		:= TRB->F2_VALBRUT
	TMP->TB_VALMERC		:= TRB->F2_VALMERC
	TMP->TB_VALICMS		:= TRB->F2_VALICM
	TMP->TB_VALIPI		:= TRB->F2_VALIPI
	TMP->TB_ICMSRET		:= TRB->F2_ICMSRET
	TMP->TB_RECNO		:= TRB->REGISTRO
	TMP->( MsUnlock() )

	dbSkip()

enddo	

if Select("TRB") > 0
	TRB->( dbCloseArea() )
endif

dbSelectArea("TMP")
dbGoTop()
if !eof()
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ MsSelect():New(<cAlias>,[cCampo],[cCpo],[aCampos],[lInv],[cMar],<aCord>,[cTopFun],[cBotFun],<oWnd>,[uPar11],[aColors]) ³
	³ --> oSelf                                                                                                              ³
	ÃÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
	³ Nome		³ Tipo		³ Descricao Obrigatorio Referencia                                                               ³
	³ cAlias	³ Caracter	³ Alias da tabela utilizada pela MsSelect para controle dos registros/colunas apresentadas. X    ³
	³ cCampo	³ Caracter	³ Nome do campo presente na tabela definida em cAlias, qual contemplara a opção de marcação      ³
	³        	³        	³ (check/unckeck)                                                                                ³
	³ cCpo		³ Caracter	³ Campo da tabela informada pelo parametro cAlias ou funcao que sera executada na apresentacao   ³
	³        	³        	³ da coluna que indica se a linha da MsSelect esta habilitada ou não.                            ³
	³ aCampos	³ Array		³ Vetor com informacoes dos campos para criacao das colunas da MsSelect. Se nao for informado, a ³
	³        	³        	³ MsSelect ira criar as colunas baseado no Dicionario de Campos (SX3) da tabela informada no     ³
	³        	³        	³ parametro cAlias.                                                                              ³
	³ lInv		³ Lógico	³ Indica se MsSelect ira utilizar marcacao invertida                                             ³
	³ cMar		³ Caracter	³ Marca que sera utilizada pela MsSelect para controle do campo informado pelo parametro cCampo. ³
	³        	³        	³ Para utilizar o parametro cMar, utilize a funcao GetMark() para retornar a proxima marca       ³
	³        	³        	³ disponivel para uso.                                                                           ³
	³ aCord		³ Array		³ Coordenadas para criacao da MsSelect, sendo:                                                   ³
	³        	³        	³ aCord[1] = Coordenada vertical inicial,                                                        ³
	³        	³        	³ aCord[2] = Coordenada horizontal inicial,                                                      ³
	³        	³        	³ aCord[3] = Altura do objeto MsSelect                                                           ³
	³        	³        	³ aCord[4] = Largura do objeto MsSelect X                                                        ³
	³ cTopFun	³ Caracter	³ Funcao que retornara o conteudo inicial que a MsSelect utilizara para apresentar a primeira    ³
	³        	³        	³ linha da tabela, como um range, junto com o parametro cBotFun. O conteúdo retornado sera       ³
	³        	³        	³ utilizado para fazer o posicionamento da tabela informada pelo parametro cAlias, baseado na    ³
	³        	³        	³ chave de indice posicionada para a mesma.                                                      ³
	³ cBotFun	³ Caracter	³ Funcao que retornara o conteudo final que a MsSelect utilizará para apresentar a ultima linha  ³ 
	³        	³        	³ da tabela, como um range, junto com o parametro cTopFun. O conteudo retornado sera utilizado   ³
	³        	³        	³ para o posicionamento final da tabela informada pelo parametro cAlias, baseado na chave de     ³
	³        	³        	³ indice posicionada para a mesma.                                                               ³
	³ oWnd		³ Objeto	³ Objeto tipo "Dialog" (MSDIALOG, MSWINDOW, MSPANEL, etc.) aonde a MsSelect sera posicionada. X  ³
	³ uPar11	³ Nulo		³ Parametro reservado relativo a compatibilidade.                                                ³
	³ aColors	³ Array		³ Vetor com regras para a apresentação da coluna de legenda.                                     ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	@ 060, 001 TO 590, 1250 Dialog oSel Title OemToAnsi("Seleção de Notas Fiscais")
	oMark 		:= MsSelect():New("TMP","TB_MARCA","",aCampos,.F.,@cMarca,{005,002,247,620})
	oMark:bMark := {| | MarcaReg(cMarca)} 
	
	@ 250, 320 BmpButton Type 1 Action Processa({|| GravaArq(lFirst) }, "Gerando arquivos para carga no FTP")		//PrepGravacao(lFirst)
	@ 250, 370 BmpButton Type 2 Action (oSel:End())
	Activate Dialog oSel Centered

else

	if lFirst
		Help(" ", 1, "ATENÇÃO", , "Não foram localizadas notas fiscais dentro do período informado." + cEol + "Possíveis causas: Não existem NFs no intervalo selecionado ou as NFs já foram enviadas ao operador logístico ou as notas existentes não pertencem ao grupo apto a gerar separação." + cEol + "(Específico Brasitech). ", 1)
	else
		Help(" ", 1, "ATENÇÃO", , "Não foram localizadas notas fiscais já enviadas dentro do período informado." + cEol + "Possíveis causas: Não existem NFs já enviadas no intervalo selecionado ou as NFs ainda não foram enviadas ao operador logístico ou as notas existentes não pertencem ao grupo apto a gerar separação." + cEol + "(Específico Brasitech). ", 1)
	endif

endif

if Select("TMP") > 0
	TMP->( dbCloseArea() )
endif
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ MarcaReg     ³ Por: Adalberto Moreno Batista       ³ Data ³18/03/2013³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MarcaReg(cMark)
TMP->( RecLock("TMP",.F.) )
TMP->TB_MARCA := iif(Marked("TB_MARCA"), cMark, "")
TMP->( MsUnlock() )
oMark:oBrowse:Refresh()
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ GravaArq     ³ Por: Adalberto Moreno Batista       ³ Data ³ 05/11/12 ³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GravaArq(lFirst)
Local cBuffer, cOperac, aDetalhe, nX, nHdl, cArquivo
Local lContinua		:= .T.
Local aArea 		:= GetArea()
Local cEol			:= chr(13) + chr(10) 
//Local cIdEnt   		:= U_GetCodEnt()
Local nVlrNF		:= GetMV("ES_VLREDI")
Local cDiretorio	:= AllTrim(Getmv("MV_XDIRFML", .F., ""))  
Local lLayOut		:= GetMV("BR_FTPLOP", .F., .T.)
Local aRelatorio	:= {}
Local nQtdTotal		:= 0
Local cNatOper		:= ""
Local cTipoArq		:= ""
Local cEmailPad		:= GetMv("BR_EMAILNF")
local cCgca         :=""

if MsgBox("Deseja enviar os arquivos ao operador logístico?", "Pergunta", "YESNO")

	if mv_par06 == 1 .and. cFilAnt == "01"
		cTipoArq := "VEN_AM_"
	elseif mv_par06 == 1 .and. cFilAnt == "03"
		cTipoArq :=	"VEN_SP_"
	elseif mv_par06 == 1 .and. cFilAnt == "08"
		cTipoArq :=	"VEN_LJ_"
	elseif mv_par06 == 2 .and. cFilAnt == "01"
		cTipoArq :=	"REM_RN_"
	elseif mv_par06 == 2 .and. cFilAnt == "03"	
		cTipoArq :=	"REM_RI_"                   
	elseif mv_par06 == 2 .and. cFilAnt == "08"	
		cTipoArq :=	"REM_LJ_"                   
	endif
	
	cDiretorio	:= cDiretorio + iif(Right(cDiretorio, 1) = "\", "", "\" ) 	//AllTrim(mv_par01) + iif( Right( AllTrim(mv_par01), 1) = "\", "", "\" )
//	cArquivo		:= cTipoArq + dTOs(Date()) + Substr(Time(), 1, 2) + Substr(Time(), 4, 2) + iif(lLayOut, ".TXT", ".CSV")
	cArquivo		:= cTipoArq + dTOs(Date()) + strtran(Time(), ":", "") + iif(lLayOut, ".TXT", ".CSV")
	nHdl			:= MsFCreate(cDiretorio + cArquivo, 0)
 
	if nHdl = -1
		Help(" ", 1, "ATENÇÃO", , "O arquivo " + cDiretorio + cArquivo + " não foi criado. Verifique se o diretório informado é válido." + cEol + "(Específico Brasitech). ", 1)
		Return()
	endif
		
	ProcRegua(TMP->(RecCount())) // Numero de registros a processar
	
	SA1->(dbSetOrder(1))
	SA4->(dbSetOrder(1))
	SB1->(dbSetOrder(1))
	SC5->(dbSetOrder(1))
	SC6->(dbSetOrder(1))
	SD2->(dbSetOrder(3))
	                    
	TMP->(dbGoTop())
		if TMP->(Marked("TB_MARCA"))
			SF2->(dbGoTo(TMP->TB_RECNO))		//posicionando o cabecalho da nota fiscal
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cabeçalho do Arquivo                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if alltrim(SF2->F2_X_OPLOG) == 'NN'
				cBuffer :=	"V" + cEol
			elseIf alltrim(SF2->F2_X_OPLOG) == 'ON' .and. xFilial("SF2") == "01"
				cBuffer :=	"RN" + cEol
			elseIf alltrim(SF2->F2_X_OPLOG) == 'ON' .and. xFilial("SF2") == "03"
				cBuffer :=	"RI" + cEol
			elseIf alltrim(SF2->F2_X_OPLOG) == 'ON' .and. xFilial("SF2") == "08"
				cBuffer :=	"LJ" + cEol
			EndIf
			
			lContinua := fWrite(nHdl, cBuffer) > 0
			if !lContinua
				MsgBox("Ocorreu um erro na gravação arquivo. O processo serã interrompido.", "Atenção", "ERRO")
			//	exit
			endif
		endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualizando registro da nota como ja enviado para o EDI        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	do while TMP->(!eof())
	
		IncProc()
		
		if TMP->(Marked("TB_MARCA"))
		
			SF2->(dbGoTo(TMP->TB_RECNO))		//posicionando o cabecalho da nota fiscal
			
			SA1->(dbSeek(xFilial("SA1") + SF2->(F2_CLIENTE + F2_LOJA)))
			SA4->(dbSeek(xFilial("SA4") + SF2->F2_TRANSP))
			SD2->(dbSeek(xFilial("SD2") + SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA)))
			SC5->(dbSeek(xFilial("SC5") + SD2->D2_PEDIDO))
			nQtdTotal	:= 0
			cNatOper	:= GetAdvFVal("SF4", "F4_TEXTO", xFilial("SF4")+SD2->D2_TES,1)		
	
				// Alteracao do layout FM Logistica - Por Felipe Varella
				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Gera em layout (colunas fixas)                       					 ³
				ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
				³ Campo               Ini  Fim  Tam  Dec  Tipo  Formato                  ³
				³ Tipo Registro = 1  (Cabecalho Documento Saida)                         ³
				³ Campo               Ini  Fim  Tam  Dec  Tipo  Formato   Observacao     ³
				³ Id Cabecalho        001  001  001       N               1-Fixo         ³
				³ Numero da Nota      002  010  009       C                              ³
				³ Branco              011  011  001       C                              ³
				³ CNPJ                012  025  014       C                              ³
				³ Branco              026  026  001       C                              ³
				³ Nome Cliente        027  061  035       C                              ³
				³ Endereco            062  091  030       C                              ³
				³ Complemento         092  111  020       C                              ³
				³ Bairro              112  126  015       C                              ³
				³ Cidade              127  146  020       C                              ³
				³ Estado              147  148  002       C                              ³
				³ CEP                 149  156  008       C                              ³
				³ CNPJ/CPF            157  170  014       C                              ³
				³ Branco		      171  178  008       C								 ³
				³ Data Emissao NF     179  186  008       D     DDMMAAAA                 ³
				³ Codigo Operacao     187  189  003       C               M3S ou SGC     ³
				³ Branco              190  389  200       C                              ³			
				³ Codigo Transp       390  395  006       C                              ³
				³ Transportadora      396  425  030       C                              ³
				³ Serie NF		      426  428  003       C                              ³
				³ Inscr Estadual      429  448  020       N                              ³
				³ Cod Ibge Mun        449  458  010       N                              ³			
				³ Email 		      459  519  060       C                              ³			
				³	                                                                     ³
				³ Tipo Registro = 9 (Item Documento Saida)                               ³
				³ Campo               Ini  Fim  Tam  Dec  Tipo  Formato   Observacao     ³
				³ Id                  001  001  001       C               9-Fixo         ³
				³ Numero NF           002  010  009       C                              ³
				³ Brancos	          012  012  001       C                              ³
				³ Item Pedido         013  015  003       C                              ³
				³ Produto             016  023  008       C                              ³
				³ Brancos	          024  040  017       C                              ³
				³ Descricao           041  060  020       C                              ³
				³ Unidade de Medida   061  062  002       C                              ³
				³ Quantidade          063  073  011  000  N                              ³
				³ Valor Unitario      074  089  016  004  N                              ³
				³ Branco              090  104  015       C                              ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				*/
				if SF2->F2_VALMERC >= nVlrNF
					cOperac := 'SGC'
				elseif SC5->C5_CONDPAG $ '001,002,004'
					cOperac := 'M3U'
				elseif SA1->A1_X_PRIOR != ' '
					cOperac := 'M3X'
				else
					cOperac := 'M3S'
				endif
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Cabeçalho do Documento                                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
				// Alterada a linha 538
				// Substr(dTOc(SC6->C6_ENTREG),1,2)+Substr(dTOc(SC6->C6_ENTREG),4,2)+AllTrim(Str(Year(SC6->C6_ENTREG))) +;
	
	
		
				// serapa numero endereço para registro
				cEnd  :=  FisGetEnd(SA1->A1_END)[1]
				cNum1 :=  FisGetEnd(SA1->A1_END)[3]
				
				//faz tratamento no campo quando for ='' deixa valor para exportação iterface
				//chamado: 10639 18/12
				
				cCgca := SA1->A1_CGC
				if AllTrim(cCgca) == ''
					cCgca ="00000000000001"
					else
					cCgca := SA1->A1_CGC
				Endif
	 
	//VENDAS
	  if mv_par06 == 2
	          				cBuffer :=	"1" +;
							PadR(SF2->F2_DOC, 09) + ;
							Space(01) + ;
							PadR(cCgca, 14) +;
							Space(01) +;
							PadR(SA1->A1_NOME,35) +;
							PadR(SA1->A1_END, 30) +;
							PadR(SA1->A1_COMPLEM, 20) +;
							PadR(SA1->A1_BAIRRO, 15) +;
							PadR(SA1->A1_MUN, 20) +;
							PadR(SA1->A1_EST, 2) +;
							PadR(SA1->A1_CEP, 8) +;
							PadR(SM0->M0_CGC, 14) +;
							Space(08) +;		
							Substr(dTOc(SF2->F2_EMISSAO),1,2)+Substr(dTOc(SF2->F2_EMISSAO),4,2)+AllTrim(Str(Year(SF2->F2_EMISSAO))) +;
							cOperac +;
							Space(200) +;
							PadR(SA4->A4_COD, 6) +;
							PadR(SA4->A4_NOME, 30) +;
							PadR(SF2->F2_SERIE, 03) +;
							PadR(SA1->A1_INSCR, 20) +;
							PadR(SA1->A1_COD_MUN, 10) +;
							PadR(StrTran(cEmailPad,";","",1,1)+";"+SubStr(SA1->A1_EMAIL,1,At (";" , SA1->A1_EMAIL)-1),200) +;
							StrZero(SF2->F2_VOLUME1,6) +;
							StrZero(SF2->(F2_VALBRUT+F2_DESCZFR) * 100, 16) +;
							StrZero(SF2->F2_PLIQUI * 10000, 12) +;
							StrZero(SF2->F2_PBRUTO * 10000, 12) +;
							PadR(SF2->F2_CHVNFE, 44) +;							
							cEol
							
							else
							
							cBuffer :=	"1" +;							
							PadR(SF2->F2_DOC, 09) + ;
							Space(01) + ;
							PadR(cCgca, 14) +;
							Space(01) +;
							PadR(SA1->A1_NOME,35) +;
							PadR(cEnd, 30) +;
							PadR(cNum1, 9) +;
							PadR(SA1->A1_COMPLEM, 40) +;
							PadR(SA1->A1_BAIRRO, 40) +;
							PadR(SA1->A1_MUN, 60) +;
							PadR(SA1->A1_EST, 2) +;
							PadR(SA1->A1_CEP, 8) +;
							PadR(SM0->M0_CGC, 14) +;
							Space(08) +;		
							Substr(dTOc(SF2->F2_EMISSAO),1,2)+Substr(dTOc(SF2->F2_EMISSAO),4,2)+AllTrim(Str(Year(SF2->F2_EMISSAO))) +;
							cOperac +;
							Space(200) +;
							PadR(SA4->A4_COD, 6) +;
							PadR(SA4->A4_NOME, 30) +;
							PadR(SF2->F2_SERIE, 03) +;
							PadR(SA1->A1_INSCR, 20) +;
							PadR(SA1->A1_COD_MUN, 10) +;
							PadR(StrTran(cEmailPad,";","",1,1)+";"+SubStr(SA1->A1_EMAIL,1,At (";" , SA1->A1_EMAIL)-1),200) +;
							StrZero(SF2->F2_VOLUME1,6) +;
							StrZero(SF2->(F2_VALBRUT+F2_DESCZFR) * 100, 16) +;
							StrZero(SF2->F2_PLIQUI * 10000, 12) +;
							StrZero(SF2->F2_PBRUTO * 10000, 12) +;
							PadR(SF2->F2_CHVNFE, 44) +;	
							PadR(SF2->F2_ICMSRET, 9) +;
							cEol
							
						endif	
							
							
	
				lContinua := fWrite(nHdl, cBuffer) > 0
				if !lContinua
					MsgBox("Ocorreu um erro na gravação arquivo. O processo serã interrompido.", "Atenção", "ERRO")
					exit
				endif
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Armazena os dados no array aDetalhes para ordenar pelo campo D2_ITEM ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aDetalhe := {}
				do while SD2->(!eof() .and. D2_FILIAL = xFilial("SD2") .and. D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA = SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA))
		        
					SB1->( dbSeek( xFilial("SB1") + SD2->D2_COD ) )
			        aAdd(aDetalhe, {"9",;
			        				PadR(SF2->F2_DOC, 09),;
			        				Space(01) +;
			        				PadR(SD2->D2_ITEM, 3),;
			        				PadR(SD2->D2_COD, 15),;
			        				Space(10) +;
			        				PadR(SB1->B1_XDESCNF, 20),;
			        				PadR(SD2->D2_UM, 2),;
			        				StrZero(SD2->D2_QUANT,11),;
			        				StrZero(SD2->(D2_PRCVEN+(D2_DESCZFR/D2_QUANT)) * 10000, 16),;
			        				Space(15)} )
					SD2->( dbSkip() )
	
				enddo
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ordeno pela posicao 3, D2_ITEM, e gero a linha cBuffer ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				if Len(aDetalhe) > 0
					aDetalhe := aSort(aDetalhe,,, { |x, y| x[3] < y[3] })
					for nX := 1 to Len(aDetalhe)
						cBuffer :=	aDetalhe[nX, 1] +;
									aDetalhe[nX, 2] +;
									aDetalhe[nX, 3] +;
									aDetalhe[nX, 4] +;
									aDetalhe[nX, 5] +;
									aDetalhe[nX, 6] +;
									aDetalhe[nX, 7] +;
									aDetalhe[nX, 8] +;
									aDetalhe[nX, 9] +;
									cEol
			
						lContinua := fWrite(nHdl, cBuffer) > 0
						if !lContinua
							MsgBox("Ocorreu um erro na gravação arquivo. O processo serã interrompido.", "Atenção", "ERRO")
							exit
						endif
					next
				endif
	
			SF2->(RecLock("SF2",.F.))
			SF2->F2_X_DTEXP	:= Date()
			SF2->F2_X_HREXP	:= SUBSTR(Time(),1,5)
			SF2->(MsUnlock())
	
			SD2->(dbSeek(xFilial("SD2") + SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA)))		
			do while SD2->(!eof() .and. D2_FILIAL = xFilial("SD2") .and. D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA = SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA))
				nQtdTotal += SD2->D2_QUANT
				SD2->(dbSkip())
			enddo
			
			aAdd(aRelatorio, {SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_EMISSAO, SA1->A1_NOME, SA4->A4_NOME, SF2->F2_VOLUME1, nQtdTotal,cNatOper,SF2->F2_VALBRUT,SA1->A1_CGC,SF2->F2_EST,SF2->F2_PBRUTO,SA1->A1_MUN})
			nQtdTotal = 0 
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gravacao do arquivo XML no diretorio padrao                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//U_ExportXML(cIdEnt, SF2->F2_SERIE, SF2->F2_DOC,,,,,, cDiretorio, ".vnd")
			
		endif
		
		TMP->(dbSkip())
		
	enddo
	
	fClose(nHdl)
	Close(oSel)
	RestArea(aArea)
	
	U_FTM03_EnvFTP(aRelatorio, cArquivo, lFirst)

endif
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ FTM01_Cancel ³ Por: Adalberto Moreno Batista       ³ Data ³ 07/11/12 ³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function FTM03_Cancel()
Local cPerg		:= "BFATM03C"
Local aCabSX1	:= {"X1_GRUPO", "X1_ORDEM", "X1_PERGUNT", "X1_VARIAVL", "X1_TIPO", "X1_TAMANHO", "X1_DECIMAL", "X1_GSC", "X1_VAR01"}
Local aHlp01	:= {"Informe o numero da nota fiscal que ", "deverá ter o controle de envio", "desmarcado"}
Local aHlp02	:= {"Informe a serie nota fiscal que ", "deverá ter o controle de envio", "desmarcado"}
Local aRegs		:= {	{cPerg, "01", "Nota Fiscal   ?", "mv_ch1", "C", 09, 0, "G", "mv_par01"},;
						{cPerg, "02", "Série         ?", "mv_ch2", "C", 03, 0, "G", "mv_par02"} }
Local cEol		:= chr(13) + chr(10)
Local cQuery

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montando o grupo de perguntas                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
U_BRASX1(aRegs, aCabSX1)	//Funcao contida dentro do BCFGA01.prw
PutSX1Help("P." + AllTrim(cPerg) + "01.", aHlp01, aHlp01, aHlp01)
PutSX1Help("P." + AllTrim(cPerg) + "02.", aHlp02, aHlp02, aHlp02)

if !Pergunte(cPerg, .T.)
	Return()
endif

SF2->(RetIndex("SF2"))
SF2->(dbClearFilter())
aEval(aIndSF2,{|x| Ferase(x[1] + OrdBagExt())})

SF2->(dbSetOrder(1))
if SF2->(dbSeek(xFilial("SF2") + mv_par01 + mv_par02))

	if (!empty(SF2->F2_X_DTEXP) .or. !empty(SF2->F2_X_HREXP))

		SF2->(RecLock("SF2",.F.))
		SF2->F2_X_DTEXP	:= cTOD("")
		SF2->F2_X_HREXP	:= Space( Len(SF2->F2_X_HREXP) )
		SF2->(MsUnlock())

		MsgBox("Nota desmarcada para do envio para separação. Avise o operador logístico.", "Informação", "INFO")
		
	else

		Help(" ", 1, "ATENÇÃO", , "A nota fiscal e série informada não foi marcada para envio, portanto não há necessidade de desmarcá-la." + cEol + "(Específico Brasitech). ", 1)

	endif

else

	Help(" ", 1, "ATENÇÃO", , "A nota fiscal e série não foi encontrada. Verifique se os dados digitados estão corretos." + cEol + "(Específico Brasitech). ", 1)

endif


dbSelectArea("SF2")
cCondicao	:= "F2_FILIAL = '" + xFilial("SF2") + "' .and. F2_X_OPLOG = 'NN'" + iif(mv_par01 = 1," .and. Empty(F2_X_DTEXP)", "")
bFiltraBrw	:= {|| FilBrowse("SF2", @aIndSF2, @cCondicao) }
Eval(bFiltraBrw)
	
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ FTM01_Legend ³ Por: Adalberto Moreno Batista       ³ Data ³ 19/11/12 ³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function FTM03_Legend()
Local aLegenda := {	{ "BR_VERMELHO",	"Pendentes de envio" },;
					{ "BR_VERDE",		"Enviados" } }
BrwLegenda(cCadastro, "Legenda", aLegenda)
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ FTM03_EnvFTP ³ Por: Adalberto Moreno Batista ³ Data ³20.11.2012³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function FTM03_EnvFTP(aRelatorio, cArquivo, lFirst)
Processa({|| EnvFTP(aRelatorio, lFirst) },"Aguarde... ")
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ EnvFTP 		³ Por: Adalberto Moreno Batista ³ Data ³20.11.2012³±±
±±ÃÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function EnvFTP(aRelatorio, lFirst)
Local cEol		:= chr(13) + chr(10)
Local cDestinat	:= AllTrim(GetMV("BR_BFATM03", .F., "rodrigo.ramos@gamaitaly.com.br"))
Local cMsg		:= ""
Local cLog		:= ""
Local cNomeLog	:= "C:\TEMP\" + StrTran(dTOs(Date()) + "_" + time() + ".LOG", ":", "-")
Local aArquivos	:= {}
Local cTipos, aArqSepar, aArqXML, lUpLoad, nTempo, aArqUpload, nK, nT, cMensagem, cErro
Default aRelatorio := {}


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia e-mail com o relação de notas somente quando gerada a transmissão convencional    ³
//³ por meio do "envio" ou "reenvio". E-mail enviado mesmo quando os arquivos não tenham    ³
//³ transmitidos para o FTP.                                                                ³
//³ Caso seja somente ativada o envio por ftp (opção FTP no menu), o e-mail não será gerado ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if Len(aRelatorio) > 0
	//email no formato html
	cMensagem := '<html>'
	cMensagem += '<font size="2" face="Arial">Segue lista com as notas fiscais transferidas para a empresa FM Logístic em ' + dTOc(date()) + ', às ' + time() + '.</font><br><br>'
	cMensagem += '<font size="2" face="Arial">' + iif(lFirst, 'Lista em primeiro envio','Notas reenviadas') + '.</font><br><br>'
	
	//Abrindo a tabela
	cMensagem += '<table width="100%" border="1" cellspacing="0" cellpadding="0">'
	
	//Abrindo a linha do cabeçalho
	cMensagem += '<tr>'
	cMensagem += '<td width="5%" align="center"><font size="2" face="Calibri"><strong>Nota Fiscal</strong></font></td>'
	cMensagem += '<td width="3%" align="center"><font size="2" face="Calibri"><strong>Série</strong></font></td>'
	cMensagem += '<td width="5%" align="center"><font size="2" face="Calibri"><strong>Emissão</strong></font></td>'
	cMensagem += '<td width="9%" align="center"><font size="2" face="Calibri"><strong>Cnpj</strong></font></td>'
	cMensagem += '<td width="18%" align="center"><font size="2" face="Calibri"><strong>Cliente</strong></font></td>'
	cMensagem += '<td width="3%" align="center"><font size="2" face="Calibri"><strong>UF</strong></font></td>'
	cMensagem += '<td width="14%" align="center"><font size="2" face="Calibri"><strong>Cidade</strong></font></td>'
	cMensagem += '<td width="15%" align="center"><font size="2" face="Calibri"><strong>Transportadora</strong></font></td>'
	cMensagem += '<td width="4%" align="center"><font size="2" face="Calibri"><strong>Vol.</strong></font></td>'
	cMensagem += '<td width="4%" align="center"><font size="2" face="Calibri"><strong>Quant.</strong></font></td>'
	cMensagem += '<td width="4%" align="center"><font size="2" face="Calibri"><strong>Peso</strong></font></td>'
	cMensagem += '<td width="6%" align="center"><font size="2" face="Calibri"><strong>Valor NF</strong></font></td>'
	cMensagem += '<td width="10%" align="center"><font size="2" face="Calibri"><strong>Natureza Operação</strong></font></td>'
	cMensagem += '</tr>'
	
	//Abrindo a linha dos itens
	for nK := 1 to len(aRelatorio)
		cMensagem += '<tr>'
		cMensagem += '<td width="5%" align="left"><font size="2" face="Calibri">' + aRelatorio[nK,1] + '</font></td>'
		cMensagem += '<td width="3%" align="center"><font size="2" face="Calibri">' + aRelatorio[nK,2] + '</font></td>'
		cMensagem += '<td width="5%" align="center"><font size="2" face="Calibri">' + dTOc(aRelatorio[nK,3]) + '</font></td>'
		cMensagem += '<td width="9%" align="center"><font size="2" face="Calibri">' + Transform(aRelatorio[nK,10],"@R 99.999.999/9999-99") + '</font></td>'
		cMensagem += '<td width="18%" align="left"><font size="2" face="Calibri">' + aRelatorio[nK,4] + '</font></td>'
		cMensagem += '<td width="3%" align="center"><font size="2" face="Calibri">' + AllTrim(aRelatorio[nK,11]) + '</font></td>'
		cMensagem += '<td width="14%" align="left"><font size="2" face="Calibri">' + aRelatorio[nK,13] + '</font></td>'
		cMensagem += '<td width="15%" align="left"><font size="2" face="Calibri">' + AllTrim(aRelatorio[nK,5]) + '</font></td>'
		cMensagem += '<td width="4%" align="right"><font size="2" face="Calibri">' + Transform(aRelatorio[nK,6],"@E 999,999,999") + '</font></td>'
		cMensagem += '<td width="4%" align="right"><font size="2" face="Calibri">' + Transform(aRelatorio[nK,7],"@E 999,999,999") + '</font></td>'
		cMensagem += '<td width="4%" align="right"><font size="2" face="Calibri">' + Transform(aRelatorio[nK,12],"@E 999,999,999.99") + '</font></td>'
		cMensagem += '<td width="6%" align="right"><font size="2" face="Calibri">' + Transform(aRelatorio[nK,9],"@E 999,999,999.99") + '</font></td>'
		cMensagem += '<td width="10%" align="left"><font size="2" face="Calibri">' + AllTrim(aRelatorio[nK,8]) + '</font></td>'
		cMensagem += '</tr>'
	next
	
	cMensagem += '</table>'
	
	cMensagem += '</body>'
	cMensagem += '</html>'
	
	cErro := U_GISendMail(cDestinat,, "Notas Fiscais enviadas no arquivo EDI em: " + dTOc(dDataBase) + " às " + Time(), cMensagem)
	
	if !Empty(cErro)
		Help(" ", 1, "ATENÇÃO", , "Ocorreu o seguinte erro  no envio do e-mail: " + cEol + cErro + cEol + "(Específico Brasitech). ", 1)	
	endif
endif

Return()
