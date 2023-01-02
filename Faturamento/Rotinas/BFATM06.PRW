/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ BFATM06  ³ Por: Felipe Varella           ³ Data ³01.10.2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina para Alteração da Data de Embarque das Notas Fiscais³±±
±±³          ³ campo específico F2_X_COLET                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Brasitech                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


#include "rwmake.ch"
#include "protheus.ch"
#include "totvs.ch"


User Function BFATM06()


Local cPerg			:= "BFATM06S"
Local aCabSX1		:= {"X1_GRUPO", "X1_ORDEM", "X1_PERGUNT", "X1_VARIAVL", "X1_TIPO", "X1_TAMANHO", "X1_DECIMAL", "X1_GSC", "X1_VAR01"}
Local aHlp01		:= {"Informe a data de emissão", "inicial", ""}
Local aHlp02		:= {"Informe a data de emissão", "final", ""}
Local aHlp03		:= {"Informe a série da nota fiscal", "", ""}
Local aHlp04		:= {"Informe o número da nota fiscal", "inicial", ""}
Local aHlp05		:= {"Informe o número da nota fiscal", "final", ""}
Local aRegs			:= {{cPerg, "01", "Da Emissao  ?", "mv_ch1", "D", 08, 0, "G", "mv_par01","",""},;
						{cPerg, "02", "Ate a Emissao  ?", "mv_ch2", "D", 08, 0, "G", "mv_par02","",""},;
						{cPerg, "03", "Da Série  ?", "mv_ch3", "C", 03, 0, "G", "mv_par03","",""},;
						{cPerg, "04", "Da Nota  ?", "mv_ch4", "C", 09, 0, "G", "mv_par04","",""},;
						{cPerg, "05", "Ate a Nota  ?", "mv_ch5", "C", 09, 0, "G", "mv_par05","",""},;
						{cPerg, "06", "Informe a Data de Embarque  ?", "mv_ch6", "D", 08, 0, "G", "mv_par06","",""}}
Local cQuery
Local aArqTMP		:= {{"TB_MARCA",	"C", 02, 00},;
						{"TB_DTCOLET",	"D", 08, 00},;						
						{"TB_DOC",		"C", 09, 00},;
						{"TB_SERIE",	"C", 03, 00},;
						{"TB_EMISSAO",	"D", 08, 00},;
						{"TB_CLIENTE",	"C", 06, 00},;
						{"TB_LOJA",		"C", 02, 00},;
						{"TB_NOMECLI",	"C", 30, 00},;
						{"TB_RECNO",	"N", 10, 00}}
Local cDBFTMP		:= CriaTrab (aArqTMP , .t.)
Local cEol			:= chr(13) + chr(10)
Private cMarca		:= GetMark()
Private aCampos	:= {	{"TB_MARCA",	"", "  "},;
						{"TB_DTCOLET",	"", "Data Embarque"},;					
						{"TB_DOC",		"", "Nota Fiscal"},;
						{"TB_SERIE",	"", "Serie"},;
						{"TB_EMISSAO",	"", "Dt.Emissao"},;
						{"TB_CLIENTE",	"", "Cliente"},;
						{"TB_LOJA",		"", "Loja"},;
						{"TB_NOMECLI",	"", "Nome Cliente"}}
Private oSel, oMark


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

Do while empty(mv_par06)
	MsgBox("Você deve informar a Data de Embarque que deseja Gravar", "Atenção", "INFO")
	if !Pergunte(cPerg, .T.)
		Return()
	endif
	
enddo

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
cQuery := "SELECT F2_X_COLET, F2_DOC, F2_SERIE, F2_EMISSAO, F2_COND, F2_CLIENTE, F2_LOJA, F2_VEND1, F2_EST, F2_VALMERC, F2_VALICM, F2_VALIPI, F2_ICMSRET, F2_VALBRUT, SF2.R_E_C_N_O_ REGISTRO "
cQuery += "FROM " + RetSQLName("SF2") + " SF2 "
cQuery += "WHERE SF2.F2_FILIAL = '" + xFilial("SF2") + "' "
cQuery += "AND SF2.F2_EMISSAO BETWEEN '" + dTOs(mv_par01) + "' AND '" + dTOs(mv_par02) + "' "
cQuery += "AND SF2.F2_SERIE = '" + mv_par03 + "' "
cQuery += "AND SF2.F2_X_COLET = '' "
cQuery += "AND SF2.F2_DOC BETWEEN '" + mv_par04 + "' AND '" + mv_par05 + "' "
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
	TMP->TB_DTCOLET		:= stod(TRB->F2_X_COLET)
	TMP->TB_DOC			:= TRB->F2_DOC
	TMP->TB_SERIE		:= TRB->F2_SERIE
	TMP->TB_EMISSAO		:= TRB->F2_EMISSAO
	TMP->TB_CLIENTE		:= TRB->F2_CLIENTE
	TMP->TB_LOJA		:= TRB->F2_LOJA
	TMP->TB_NOMECLI		:= GetAdvFVal("SA1", "A1_NOME", xFilial("SA1") + TRB->F2_CLIENTE + TRB->F2_LOJA, 1)
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
	
	@ 250, 320 BmpButton Type 1 Action Processa({|| GravaArq() }, "Gerando arquivos para carga no FTP")		//PrepGravacao()
	@ 250, 370 BmpButton Type 2 Action (oSel:End())
	Activate Dialog oSel Centered

endif

if Select("TMP") > 0
	TMP->( dbCloseArea() )
endif   

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ MarcaReg     ³ Por: Felipe Varella                 ³ Data ³01/10/2015³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
s*/
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
±±³Funcao³ GravaArq     ³ Por: Felipe Varella                 ³ Data ³ 01/10/15 ³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GravaArq()

Local aArea := GetArea()
Local aAreaSF2 := SF2->(GetArea())

if MsgBox("Deseja Gravar a Data de Embarque nas Notas Fiscais Selecionadas?", "Pergunta", "YESNO")

   	ProcRegua(TMP->(RecCount())) // Numero de registros a processar              

	TMP->(dbGoTop())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualizando registro da nota como ja enviado para o EDI        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	do while TMP->(!eof())
	
		IncProc()
		
		if TMP->(Marked("TB_MARCA"))
		
			SF2->(dbGoTo(TMP->TB_RECNO))		//posicionando o cabecalho da nota fiscal
			
			SF2->(RecLock("SF2",.F.))
			SF2->F2_X_COLET	:= MV_PAR06
			SF2->(MsUnlock())
	
		endif
		
		TMP->(dbSkip())
		
	enddo
    
	Close(oSel)
	RestArea(aArea)
	RestArea(aAreaSF2)
endif   

Return()