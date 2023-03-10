#include "rwmake.ch"
#include "protheus.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		BFATM01                                                       /@
@type				User function                                                 /@
@date				05/11/2012                                                    /@
@description	Monta lista de notas fiscais para geracao e envio de XML
					para o operador logistico realizar a separacao de produtos
					Remodelagem da rotina para a considerar os parametros da 
					rotina BFATM03, em 25/02/2019                                 /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Op鈬o Um Consultoria                                          /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function BFATM01()
Local aArea 		:= GetArea()
Local cPerg			:= "BFATM01F"
Local aCabSX1		:= {"X1_GRUPO", "X1_ORDEM", "X1_PERGUNT", "X1_VARIAVL", "X1_TIPO", "X1_TAMANHO", "X1_DECIMAL", "X1_GSC", "X1_VAR01", "X1_DEF01", "X1_DEF02"}
Local aHlp01		:= {"Informe quais registros deseja", "visualizar na tela de browse", "somente as pendentes de envio ou todas"}
Local aRegs			:= {	{cPerg, "01", "Visualiza as NF's ?", "mv_ch1", "N", 01, 0, "C", "mv_par01", "1-Pend. Envio", "2-Todas"} }
Local aCores  		:= {	{'Empty(SF2->F2_X_DTEXP)',		'BR_VERMELHO' },;
								{'!Empty(SF2->F2_X_DTEXP)',	'BR_VERDE' } }
Private cCadastro := "Gera鈬o de arquivo para separa鈬o de mercadoria"
Private aRotina 	:= {	{ "Pesquisa",	"AxPesqui",	     	 		0,1},;
								{ "Visualiza",	"U_FTM01_Visual()",		0,2},;
								{ "Envio",		"U_FTM01_Select(.T.)",	0,3},;
								{ "Reenvio",	"U_FTM01_Select(.F.)",	0,3},;
								{ "Cancela",	"U_FTM01_Cancel()",		0,5},;
								{ "Legenda",	"U_FTM01_Legend()",		0,5}}
Private aIndSF2   := {}
Private bFiltraBrw:= {|| Nil}

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Montando o grupo de perguntas
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
U_BRASX1(aRegs, aCabSX1)	//Funcao contida dentro do BCFGA01.prw
PutSX1Help("P." + AllTrim(cPerg) + "01.", aHlp01, aHlp01, aHlp01)
                                                 	
if !Pergunte(cPerg, .T.)
	Return()
endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Criando filtro
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
dbSelectArea("SF2")
cCondicao	:= "F2_FILIAL == '" + xFilial("SF2") +"' " + iif(mv_par01 = 1," .and. Empty(F2_X_DTEXP)", "")
bFiltraBrw	:= {|| FilBrowse("SF2", @aIndSF2, @cCondicao) }
Eval(bFiltraBrw)
mBrowse(,,,,"SF2",,,,,,aCores)
	
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Restaura a integridade da rotina
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
dbSelectArea("SF2")
RetIndex("SF2")
dbClearFilter()
aEval(aIndSF2,{|x| Ferase(x[1] + OrdBagExt())})
RestArea(aArea)
Return()

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		FTM01_Visual                                                  /@
@type				User function                                                 /@
@date				20/11/2012                                                    /@
@description	Monta o modelo 3 para visualiza鈬o das notas a serem selecio-
					nadas                                                         /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Op鈬o Um Consultoria                                          /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function FTM01_Visual()
Local nI, nUsado
Private aCols		:= {}
Private aHeader	:= {}

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Criando variaveis M->F2_??? da enchoice
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
RegToMemory("SF2", .F.)

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Montando o aHeader
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
SX3->(dbSetOrder(1))
SX3->(dbSeek("SD2"))
do while SX3->(!eof() .and. X3_ARQUIVO = "SD2")
	
	if x3Uso(SX3->X3_USADO) .and.;
		cNivel >= SX3->X3_NIVEL .and.;
		!AllTrim(SX3->X3_CAMPO) $ "D2_FILIAL/D2_STSERV/D2_REGWMS"
		
		aAdd( aHeader, {	AllTrim(SX3->X3_TITULO),;
								SX3->X3_CAMPO,;
								SX3->X3_PICTURE,;
								SX3->X3_TAMANHO,;
								SX3->X3_DECIMAL,;
								SX3->X3_VLDUSER,;
								SX3->X3_USADO,;
								SX3->X3_TIPO,;
								SX3->X3_ARQUIVO,;
								SX3->X3_CONTEXT } )
	endif
	
	SX3->(dbSkip())
enddo

nUsado := Len(aHeader)

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Montando aCols da getdados
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
aCols	:= {}
SD2->(dbSetOrder(3) )
SD2->(dbSeek(xFilial("SD2") + SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA)))
do while SD2->(!eof() .and. D2_FILIAL = xFilial() .and. D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA = SF2->( F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA))
	aAdd(aCols, Array(nUsado + 1))
	for nI := 1 to nUsado
		aCols[Len(aCols), nI] 	:= SD2->(FieldGet(FieldPos(aHeader[nI,2])))
	next
	aCols[Len(aCols), nUsado + 1]	:=.F.
	SD2->(dbSkip())
enddo

/*覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
Modelo3(cTitulo, cAliasEnchoice, cAliasGetD,, cLinOk, cTudOk, nOpcE, nOpcG, cFieldOk)
Parametros:
NOME				TIPO   		DESCRICAO
cTitulo			Caracter   	Titulo da janela (Obrigatorio)
cAlias   		Caracter   	Alias da Enchoice (Obrigatorio)
cAlias2   		Caracter   	Alias da Getdados (Obrigatorio)
aMyEncho   		Vetor  		Array com campos da enchoice
cLinhaOk   		Caracter   	Funcao para validacao da linha
cTudoOk   		Caracter   	Funcao para validacao na confirmacao
nOpcE   			Numerico   	nOpc da Enchoice
nOpcG   			Numerico   	nOpc da Getdados
cFieldOk   		Caracter   	Validacao para todos os campos da GetDados
lVirtual   		Logico   	Permite visualizar campos virtuais na enchoice
nLinhas   		Num駻ico   	Numero maximo de linhas na getdados
aAltEnchoice  	Vetor  		Array com campos alteraveis da Enchoice
nFreeze   		Numerico   	Congelamento das colunas
aButtons   		Vetor  		Array com botoes de usuario na enchoicebar
aCordW   		Vetor  		Coordenadas da janela
nSizeHeader   	Numerico   	Altura da enchoice
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?*/
Modelo3(cCadastro, "SF2", "SD2",, ".T.", ".T.", 2, 2, "AllwaysTrue()", .T.,,, 1,,, 250)

dbSelectArea("SF2")
Return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		FTM01_Select                                                  /@
@type				User function                                                 /@
@date				05/12/2012                                                    /@
@description	Carrega os registros a serem selecionados                     /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Op鈬o Um Consultoria                                          /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function FTM01_Select(lFirst)
Local cPerg			:= "BFATM01S"
Local aCabSX1		:= {"X1_GRUPO", "X1_ORDEM", "X1_PERGUNT", "X1_VARIAVL", "X1_TIPO", "X1_TAMANHO", "X1_DECIMAL", "X1_GSC", "X1_VAR01", "X1_DEF01", "X1_DEF02", "X1_DEF03", "X1_DEF04"}
Local aHlp01		:= {"Informe a data de emiss縊", "inicial", ""}
Local aHlp02		:= {"Informe a data de emiss縊", "final", ""}
Local aHlp03		:= {"Informe a s駻ie da nota fiscal", "", ""}
Local aHlp04		:= {"Informe o n?mero da nota fiscal", "inicial", ""}
Local aHlp05		:= {"Informe o n?mero da nota fiscal", "final", ""}
Local aRegs			:= {	{cPerg, "01", "Da Emissao    ?", "mv_ch1", "D", 08, 0, "G", "mv_par01", "",			"",  					"",					""},;
								{cPerg, "02", "Ate a Emissao ?", "mv_ch2", "D", 08, 0, "G", "mv_par02", "",			"",					"",					""},;
								{cPerg, "03", "Da S駻ie      ?", "mv_ch3", "C", 03, 0, "G", "mv_par03", "",			"",					"",					""},;
								{cPerg, "04", "Da Nota       ?", "mv_ch4", "C", 09, 0, "G", "mv_par04", "",			"",					"",					""},;
								{cPerg, "05", "Ate a Nota    ?", "mv_ch5", "C", 09, 0, "G", "mv_par05", "",			"",					"",					""},;
								{cPerg, "06", "Tipo da NF    ?", "mv_ch6", "N", 01, 0, "C", "mv_par06", "1-Venda",	"2-Rem.(Devol)",	"3-Rem.(Recusa)",	"4-Rem.(Transf)"} }
Local cQuery
Local aArqTMP		:= {	{"TB_MARCA",	"C", 02, 00},;
								{"TB_DOC",		"C", 09, 00},;
								{"TB_SERIE",	"C", 03, 00},;
								{"TB_EMISSAO",	"D", 08, 00},;
								{"TB_CLIENTE",	"C", 06, 00},;
								{"TB_LOJA",		"C", 02, 00},;
								{"TB_NOMECLI",	"C", 30, 00},;
								{"TB_EST",		"C", 02, 00},;
                                                                {"TB_MUN",	"C", 30, 00},;
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
                                                                {"TB_MUN",		"", "Cidade"},;
								{"TB_COND",		"", "Cond.Pagto"},;
								{"TB_VALMERC",	"", "Vl.Mercadoria",	"@E 999,999,999.99"},;
								{"TB_VALICMS",	"", "Valor ICMS",		"@E 999,999,999.99"},;
								{"TB_VALIPI",	"", "Valor IPI",		"@E 999,999,999.99"},;
								{"TB_ICMSRET",	"", "Vl.ICMS ST",		"@E 999,999,999.99"},;
								{"TB_VALBRUT",	"", "Valor Nota",		"@E 999,999,999.99"},;
								{"TB_VEND",		"", "Vendedor"},;
								{"TB_NOMEVEN",	"", "Nome Vendedor"},;
								{"TB_DTEXP",	"", "Data exporta鈬o"},;
								{"TB_HREXP",	"", "Hora exporta鈬o"}}
Private oSel, oMark

if !lFirst
	MsgBox("Voc? selecionou a op鈬o de reenvio de registros de notas fiscais para o operador log?stico.", "Aten鈬o", "INFO")
endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Montando o grupo de perguntas
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
U_BRASX1(aRegs, aCabSX1)	//Funcao contida dentro do BCFGA01.prw
PutSX1Help("P." + AllTrim(cPerg) + "01.", aHlp01, aHlp01, aHlp01)
PutSX1Help("P." + AllTrim(cPerg) + "02.", aHlp02, aHlp02, aHlp02)
PutSX1Help("P." + AllTrim(cPerg) + "03.", aHlp03, aHlp03, aHlp03)
PutSX1Help("P." + AllTrim(cPerg) + "04.", aHlp04, aHlp04, aHlp04)
PutSX1Help("P." + AllTrim(cPerg) + "05.", aHlp05, aHlp05, aHlp05)

if !Pergunte(cPerg, .T.)
	Return()
endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Fecha as areas de trabalho, caso estejam abertas
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if Select("TRB") > 0
	TRB->( dbCloseArea() )
endif

if Select("TMP") > 0
	TMP->( dbCloseArea() )
endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Seleciona os registros validos
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
cQuery := "SELECT F2_DOC, F2_SERIE, F2_EMISSAO, F2_COND, F2_CLIENTE, F2_LOJA, F2_VEND1, F2_EST, A1_MUN ,F2_VALMERC, F2_VALICM, F2_VALIPI, F2_ICMSRET, F2_VALBRUT, SF2.R_E_C_N_O_ REGISTRO "
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
elseIf mv_par06 != 1
	cQuery += "AND SF2.F2_X_OPLOG = 'ON' " //Nota de Remessao para o Operador Logistico(ON)
endif
cQuery += "AND SF2.D_E_L_E_T_=' ' "
cQuery += "ORDER BY F2_SERIE,F2_DOC"
cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRB", .F., .T.)
tcSetField("TRB", "F2_EMISSAO", "D")

dbUseArea(.T.,,cDBFTMP,"TMP",.T.)

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Gravando em tabela temporaria
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
dbSelectArea("TRB")
dbGoTop()
do while !eof()
	TMP->(RecLock("TMP",.T.))
	TMP->TB_MARCA		:= cMarca
	TMP->TB_DOC			:= TRB->F2_DOC
	TMP->TB_SERIE		:= TRB->F2_SERIE
	TMP->TB_EMISSAO	:= TRB->F2_EMISSAO
	TMP->TB_CLIENTE	:= TRB->F2_CLIENTE
	TMP->TB_LOJA		:= TRB->F2_LOJA
	TMP->TB_NOMECLI	:= GetAdvFVal("SA1", "A1_NOME", xFilial("SA1") + TRB->F2_CLIENTE + TRB->F2_LOJA, 1)
	TMP->TB_VEND		:= TRB->F2_VEND1
	TMP->TB_NOMEVEN	:= GetAdvFVal("SA3", "A3_NOME", xFilial("SA3") + TRB->F2_VEND1, 1)
	TMP->TB_EST			:= TRB->F2_EST
        TMP->TB_MUN			:= TRB->A1_MUN
	TMP->TB_COND		:= TRB->F2_COND
	TMP->TB_VALBRUT	:= TRB->F2_VALBRUT
	TMP->TB_VALMERC	:= TRB->F2_VALMERC
	TMP->TB_VALICMS	:= TRB->F2_VALICM
	TMP->TB_VALIPI		:= TRB->F2_VALIPI
	TMP->TB_ICMSRET	:= TRB->F2_ICMSRET
	TMP->TB_RECNO		:= TRB->REGISTRO
	TMP->(MsUnlock())

	dbSkip()

enddo	

if Select("TRB") > 0
	TRB->(dbCloseArea())
endif

dbSelectArea("TMP")
dbGoTop()
if !eof()
	/*
	ﾚﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄｿ
	ｳ MsSelect():New(<cAlias>,[cCampo],[cCpo],[aCampos],[lInv],[cMar],<aCord>,[cTopFun],[cBotFun],<oWnd>,[uPar11],[aColors]) ｳ
	ｳ --> oSelf                                                                                                              ｳ
	ﾃﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾂﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾂﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄｴ
	ｳ Nome		ｳ Tipo		ｳ Descricao Obrigatorio Referencia                                                               ｳ
	ｳ cAlias	ｳ Caracter	ｳ Alias da tabela utilizada pela MsSelect para controle dos registros/colunas apresentadas. X    ｳ
	ｳ cCampo	ｳ Caracter	ｳ Nome do campo presente na tabela definida em cAlias, qual contemplara a op鈬o de marca鈬o      ｳ
	ｳ        	ｳ        	ｳ (check/unckeck)                                                                                ｳ
	ｳ cCpo		ｳ Caracter	ｳ Campo da tabela informada pelo parametro cAlias ou funcao que sera executada na apresentacao   ｳ
	ｳ        	ｳ        	ｳ da coluna que indica se a linha da MsSelect esta habilitada ou n縊.                            ｳ
	ｳ aCampos	ｳ Array		ｳ Vetor com informacoes dos campos para criacao das colunas da MsSelect. Se nao for informado, a ｳ
	ｳ        	ｳ        	ｳ MsSelect ira criar as colunas baseado no Dicionario de Campos (SX3) da tabela informada no     ｳ
	ｳ        	ｳ        	ｳ parametro cAlias.                                                                              ｳ
	ｳ lInv		ｳ L?gico	ｳ Indica se MsSelect ira utilizar marcacao invertida                                             ｳ
	ｳ cMar		ｳ Caracter	ｳ Marca que sera utilizada pela MsSelect para controle do campo informado pelo parametro cCampo. ｳ
	ｳ        	ｳ        	ｳ Para utilizar o parametro cMar, utilize a funcao GetMark() para retornar a proxima marca       ｳ
	ｳ        	ｳ        	ｳ disponivel para uso.                                                                           ｳ
	ｳ aCord		ｳ Array		ｳ Coordenadas para criacao da MsSelect, sendo:                                                   ｳ
	ｳ        	ｳ        	ｳ aCord[1] = Coordenada vertical inicial,                                                        ｳ
	ｳ        	ｳ        	ｳ aCord[2] = Coordenada horizontal inicial,                                                      ｳ
	ｳ        	ｳ        	ｳ aCord[3] = Altura do objeto MsSelect                                                           ｳ
	ｳ        	ｳ        	ｳ aCord[4] = Largura do objeto MsSelect X                                                        ｳ
	ｳ cTopFun	ｳ Caracter	ｳ Funcao que retornara o conteudo inicial que a MsSelect utilizara para apresentar a primeira    ｳ
	ｳ        	ｳ        	ｳ linha da tabela, como um range, junto com o parametro cBotFun. O conte?do retornado sera       ｳ
	ｳ        	ｳ        	ｳ utilizado para fazer o posicionamento da tabela informada pelo parametro cAlias, baseado na    ｳ
	ｳ        	ｳ        	ｳ chave de indice posicionada para a mesma.                                                      ｳ
	ｳ cBotFun	ｳ Caracter	ｳ Funcao que retornara o conteudo final que a MsSelect utilizar? para apresentar a ultima linha  ｳ 
	ｳ        	ｳ        	ｳ da tabela, como um range, junto com o parametro cTopFun. O conteudo retornado sera utilizado   ｳ
	ｳ        	ｳ        	ｳ para o posicionamento final da tabela informada pelo parametro cAlias, baseado na chave de     ｳ
	ｳ        	ｳ        	ｳ indice posicionada para a mesma.                                                               ｳ
	ｳ oWnd		ｳ Objeto	ｳ Objeto tipo "Dialog" (MSDIALOG, MSWINDOW, MSPANEL, etc.) aonde a MsSelect sera posicionada. X  ｳ
	ｳ uPar11	ｳ Nulo		ｳ Parametro reservado relativo a compatibilidade.                                                ｳ
	ｳ aColors	ｳ Array		ｳ Vetor com regras para a apresenta鈬o da coluna de legenda.                                     ｳ
	ﾀﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾁﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾁﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾙ
	*/
	@ 060, 001 TO 590, 1250 Dialog oSel Title OemToAnsi("Sele鈬o de Notas Fiscais")
	oMark 		:= MsSelect():New("TMP","TB_MARCA","",aCampos,.F.,@cMarca,{005,002,247,620})
	oMark:bMark := {| | MarcaReg(cMarca)} 
	
	@ 250, 320 BmpButton Type 1 Action (Processa({|| GravaArq(lFirst) }, "Gerando arquivos para envio por email"), Close(oSel))		//PrepGravacao(lFirst)
	@ 250, 370 BmpButton Type 2 Action (oSel:End())
	Activate Dialog oSel Centered

else

	if lFirst
		Help(" ", 1, "ATENﾇﾃO",, "N縊 foram localizadas notas fiscais dentro do per?odo informado." + cEol + "Poss?veis causas: N縊 existem NFs no intervalo selecionado ou as NFs j? foram enviadas ao operador log?stico ou as notas existentes n縊 pertencem ao grupo apto a gerar separa鈬o." + cEol + "(Espec?fico Brasitech). ", 1)
	else
		Help(" ", 1, "ATENﾇﾃO",, "N縊 foram localizadas notas fiscais j? enviadas dentro do per?odo informado." + cEol + "Poss?veis causas: N縊 existem NFs j? enviadas no intervalo selecionado ou as NFs ainda n縊 foram enviadas ao operador log?stico ou as notas existentes n縊 pertencem ao grupo apto a gerar separa鈬o." + cEol + "(Espec?fico Brasitech). ", 1)
	endif

endif

if Select("TMP") > 0
	TMP->(dbCloseArea())
endif
Return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		MarcaReg                                                      /@
@type				Static function                                               /@
@date				18/03/2013                                                    /@
@description	Fun鈬o para marcar ou desmarcar registros                     /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Op鈬o Um Consultoria                                          /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function MarcaReg(cMark)
TMP->( RecLock("TMP",.F.) )
TMP->TB_MARCA := iif(Marked("TB_MARCA"), cMark, "")
TMP->( MsUnlock() )
oMark:oBrowse:Refresh()
Return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		GravaArq                                                      /@
@type				Static function                                               /@
@date				05/11/2012                                                    /@
@description	Fun鈬o para marcar ou desmarcar registros                     /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Op鈬o Um Consultoria                                          /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function GravaArq(lFirst)
Local aArea 		:= GetArea()
Local cEol			:= chr(13) + chr(10) 
//Local nVlrNF		:= GetMV("ES_VLREDI")
Local cDiretorio	:= AllTrim(Getmv("MV_XDIRFML", .F., ""))
Local cIdEnt   	:= U_GetCodEnt()
Local aRelatorio	:= {}
Local nQtdTotal	:= 0
Local cNatOper		:= ""
Local cPreNome

if MsgBox("Deseja enviar os arquivos ao operador log?stico?", "Pergunta", "YESNO")
 
	if mv_par06 == 1
		cPreNome := "vend_"
	elseif mv_par06 == 2
		cPreNome := "rdev_"
	elseif mv_par06 == 3
		cPreNome := "rrec_"
	elseif mv_par06 == 4
		cPreNome := "rtrf_"
	endif
	
	cDiretorio	:= cDiretorio + iif(Right(cDiretorio, 1) = "\", "", "\" ) 	//AllTrim(mv_par01) + iif( Right( AllTrim(mv_par01), 1) = "\", "", "\" )

	ProcRegua(TMP->(RecCount())) // Numero de registros a processar
	
	SA1->(dbSetOrder(1))
	SA4->(dbSetOrder(1))
	SB1->(dbSetOrder(1))
	SC5->(dbSetOrder(1))
	SC6->(dbSetOrder(1))
	SD2->(dbSetOrder(3))
	
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Atualizando registro da nota como ja enviado para o EDI
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	TMP->(dbGoTop())
	do while TMP->(!eof())
	
		IncProc()
		
		if TMP->(Marked("TB_MARCA"))
		
			SF2->(dbGoTo(TMP->TB_RECNO))		//posicionando o cabecalho da nota fiscal
			
			SA1->(dbSeek(xFilial("SA1") + SF2->(F2_CLIENTE + F2_LOJA)))
			SA4->(dbSeek(xFilial("SA4") + SF2->F2_TRANSP))
			SD2->(dbSeek(xFilial("SD2") + SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA)))
	
			nQtdTotal	:= 0
			cNatOper	:= GetAdvFVal("SF4", "F4_TEXTO", xFilial("SF4")+SD2->D2_TES,1)		
			do while SD2->(!eof() .and. D2_FILIAL == xFilial("SD2") .and. D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA == SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA))
				nQtdTotal += SD2->D2_QUANT
				SD2->(dbSkip())
			enddo
			
			SF2->(RecLock("SF2",.F.))
			SF2->F2_X_DTEXP	:= Date()
			SF2->F2_X_HREXP	:= SUBSTR(Time(),1,5)
			SF2->(MsUnlock())
	
			aAdd(aRelatorio, {SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_EMISSAO, SA1->A1_NOME, SA4->A4_NOME, SF2->F2_VOLUME1, nQtdTotal,cNatOper,SF2->F2_VALBRUT,SA1->A1_CGC,SF2->F2_EST,SF2->F2_PBRUTO,SA1->A1_MUN})
			
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			// Grava鈬o do arquivo XML no diret?rio padr縊
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			U_ExportXML(cIdEnt, SF2->F2_SERIE, SF2->F2_DOC,,,,,, cDiretorio, cPreNome)
			
		endif
		
		TMP->(dbSkip())
		
	enddo
	
//	Close(oSel)
	RestArea(aArea)
	
	U_FTM01_EnvFTP(aRelatorio, lFirst)

endif
Return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		FTM01_Cancel                                                  /@
@type				User function                                                 /@
@date				07/11/2012                                                    /@
@description	Fun鈬o para cancelar marca鈬o de registros enviados, 
					possibilitando novo envio                                     /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Op鈬o Um Consultoria                                          /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function FTM01_Cancel()
Local cPerg		:= "BFATM01C"
Local aCabSX1	:= {"X1_GRUPO", "X1_ORDEM", "X1_PERGUNT", "X1_VARIAVL", "X1_TIPO", "X1_TAMANHO", "X1_DECIMAL", "X1_GSC", "X1_VAR01"}
Local aHlp01	:= {"Informe o numero da nota fiscal que ", "dever? ter o controle de envio", "desmarcado"}
Local aHlp02	:= {"Informe a serie nota fiscal que ", "dever? ter o controle de envio", "desmarcado"}
Local aRegs		:= {	{cPerg, "01", "Nota Fiscal   ?", "mv_ch1", "C", 09, 0, "G", "mv_par01"},;
							{cPerg, "02", "S駻ie         ?", "mv_ch2", "C", 03, 0, "G", "mv_par02"} }
Local cEol		:= chr(13) + chr(10)
Local cQuery

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Montando o grupo de perguntas
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
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

		MsgBox("Nota desmarcada para do envio para separa鈬o. Avise o operador log?stico.", "Informa鈬o", "INFO")
		
	else

		Help(" ", 1, "ATENﾇﾃO",, "A nota fiscal e s駻ie informada n縊 foi marcada para envio, portanto n縊 h? necessidade de desmarc?-la." + cEol + "(Espec?fico Brasitech). ", 1)

	endif

else

	Help(" ", 1, "ATENﾇﾃO", , "A nota fiscal e s駻ie n縊 foi encontrada. Verifique se os dados digitados est縊 corretos." + cEol + "(Espec?fico Brasitech). ", 1)

endif


dbSelectArea("SF2")
cCondicao	:= "F2_FILIAL = '" + xFilial("SF2") + "' .and. F2_X_OPLOG = 'NN'" + iif(mv_par01 = 1," .and. Empty(F2_X_DTEXP)", "")
bFiltraBrw	:= {|| FilBrowse("SF2", @aIndSF2, @cCondicao) }
Eval(bFiltraBrw)
	
Return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		FTM01_Legend                                                  /@
@type				User function                                                 /@
@date				19/12/2012                                                    /@
@description	Legenda                                                       /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Op鈬o Um Consultoria                                          /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function FTM01_Legend()
Local aLegenda := {	{ "BR_VERMELHO",	"Pendentes de envio" },;
							{ "BR_VERDE",		"Enviados" } }
BrwLegenda(cCadastro, "Legenda", aLegenda)
Return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		FTM01_EnvFTP                                                  /@
@type				User function                                                 /@
@date				20/12/2012                                                    /@
@description	Fun鈬o para chamada do envio para FTP                         /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Op鈬o Um Consultoria                                          /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function FTM01_EnvFTP(aRelatorio, lFirst)
Processa({|| EnvFTP(aRelatorio, lFirst) },"Aguarde... ")
Return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		EnvFTP                                                        /@
@type				Static function                                               /@
@date				20/12/2012                                                    /@
@description	Fun鈬o para envio de registros para FTP do operador log?stico /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Op鈬o Um Consultoria                                          /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function EnvFTP(aRelatorio, lFirst)
Local cEol			:= chr(13) + chr(10)
Local cDestinat	:= AllTrim(GetMV("BR_BFATM01", .F., "rodrigo.ramos@gamaitaly.com.br"))
Local nK, cMensagem, cErro
Default aRelatorio := {}

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Envia e-mail com o rela鈬o de notas somente quando gerada a transmiss縊 
// convencional por meio do "envio" ou "reenvio". E-mail enviado mesmo quando os
// arquivos n縊 tenham transmitidos para o FTP.
// Caso seja somente ativada o envio por ftp (op鈬o FTP no menu), o e-mail n縊 
// ser? gerado
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if Len(aRelatorio) > 0
	//email no formato html
	cMensagem := '<html>'
	cMensagem += '<font size="2" face="Arial">Segue lista com as notas fiscais transferidas para a empresa FM Log?stic em ' + dTOc(date()) + ', 灣 ' + time() + '.</font><br><br>'
	cMensagem += '<font size="2" face="Arial">' + iif(lFirst, 'Lista em primeiro envio','Notas reenviadas') + '.</font><br><br>'
	
	//Abrindo a tabela
	cMensagem += '<table width="100%" border="1" cellspacing="0" cellpadding="0">'
	
	//Abrindo a linha do cabe軋lho
	cMensagem += '<tr>'
	cMensagem += '<td width="5%" align="center"><font size="2" face="Calibri"><strong>Nota Fiscal</strong></font></td>'
	cMensagem += '<td width="3%" align="center"><font size="2" face="Calibri"><strong>S駻ie</strong></font></td>'
	cMensagem += '<td width="5%" align="center"><font size="2" face="Calibri"><strong>Emiss縊</strong></font></td>'
	cMensagem += '<td width="9%" align="center"><font size="2" face="Calibri"><strong>Cnpj</strong></font></td>'
	cMensagem += '<td width="18%" align="center"><font size="2" face="Calibri"><strong>Cliente</strong></font></td>'
	cMensagem += '<td width="3%" align="center"><font size="2" face="Calibri"><strong>UF</strong></font></td>'
	cMensagem += '<td width="14%" align="center"><font size="2" face="Calibri"><strong>Cidade</strong></font></td>'
	cMensagem += '<td width="15%" align="center"><font size="2" face="Calibri"><strong>Transportadora</strong></font></td>'
	cMensagem += '<td width="4%" align="center"><font size="2" face="Calibri"><strong>Vol.</strong></font></td>'
	cMensagem += '<td width="4%" align="center"><font size="2" face="Calibri"><strong>Quant.</strong></font></td>'
	cMensagem += '<td width="4%" align="center"><font size="2" face="Calibri"><strong>Peso</strong></font></td>'
	cMensagem += '<td width="6%" align="center"><font size="2" face="Calibri"><strong>Valor NF</strong></font></td>'
	cMensagem += '<td width="10%" align="center"><font size="2" face="Calibri"><strong>Natureza Opera鈬o</strong></font></td>'
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
	
	cErro := U_GISendMail(cDestinat,, "Notas Fiscais enviadas no arquivo EDI em: " + dTOc(dDataBase) + " 灣 " + Time(), cMensagem)
	
	if !Empty(cErro)
		Help(" ", 1, "ATENﾇﾃO", , "Ocorreu o seguinte erro  no envio do e-mail: " + cEol + cErro + cEol + "(Espec?fico Brasitech). ", 1)	
	endif
endif

Return()
