#include "rwmake.ch"
#include "protheus.ch"
#include "TbiConn.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		RELFATTAB                                                     /@
@type				Relat?rio                                                     /@
@date				31/08/2017                                                    /@
@description	Relat?rio de tabela de pre輟s.                                /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Op鈬o Um Consultoria                                          /@
@use				Especifico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function RELFATTAB()
Local aRegs			:= {}
Local aCabSX1		:= {"X1_GRUPO", "X1_ORDEM", "X1_PERGUNT", "X1_VARIAVL", "X1_TIPO", "X1_TAMANHO", "X1_DECIMAL", "X1_GSC", "X1_VAR01", "X1_F3", "X1_DEF01", "X1_DEF02"}
Local aHlp01		:= {"Informe o c?digo inicial da tabela de   ", "pre輟s."}
Local aHlp02		:= {"Informe o c?digo final da tabela de     ", "pre輟s."}
Local aHlp03		:= {"Informe o c?digo inicial do produto.    "}
Local aHlp04		:= {"Informe o c?digo final do produto.      "}
Local aHlp05		:= {"Emite somente registros 1-Vigentes ou   ", " 2-Todos."}
Local aHlp06		:= {"Deseja exportar relat?rio para o Excel? "}
Private cPerg		:= PadR("GAMATABPRC", Len(SX1->X1_GRUPO))
Private cDesc1 	:= "Emite relat?rio de tabelas de pre輟 conforme parametriza鈬o do usu疵io"
Private cDesc2 	:= ""
Private cDesc3 	:= ""
Private cTamanho  := "M"
Private nTipo     := 15
Private aReturn   := {"Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey  := 0
Private cNomeprog := cPerg
Private cTitulo   := "Registros tabela de pre輟"
Private nLin      := 80
Private cString   := "DA1"
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
// Variaveis utilizadas para impressao do cabecalho e rodape           
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
Private cbtxt      	:= "Brasitech (Grupo Gama Italy)"	//Space(10)
Private cbcont     	:= 0
Private m_pag      	:= 1
Private cCabec1		:= "                                                                                          Data de "
Private cCabec2		:= "C?digo Produto     Descri鈬o Produto                                   Pre輟 de Lista     Vig麩cia"
/*                       XXXXXXXXXXXXXXX    xxxxxxxxxxXXXXXXXXXXxxxxxxxxxxXXXXXXXXXXxxxxxxxxxx  999,999,999.99     99/99/99
                         0123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 
                                   1         2         3         4         5         6         7         8         9 
*/
aAdd(aRegs, {cPerg, "01", "Da tabela de pre輟s?          ", "mv_ch1", "C", 03, 0, "G", "mv_par01", "DA0",	"",				""})
aAdd(aRegs, {cPerg, "02", "At? a tabela de pre輟s?       ", "mv_ch2", "C", 03, 0, "G", "mv_par02", "DA0",	"",				""})
aAdd(aRegs, {cPerg, "03", "Do produto?                   ", "mv_ch3", "C", 15, 0, "G", "mv_par03", "SB1",	"",				""})
aAdd(aRegs, {cPerg, "04", "At? o produto?                ",	"mv_ch4", "C", 15, 0, "G", "mv_par04", "SB1",	"",				""})
aAdd(aRegs, {cPerg, "05", "Emite quais registros?        ", "mv_ch5", "N", 01, 0, "C", "mv_par05", "",		"1-Vigentes",	"2-Todos"})
aAdd(aRegs, {cPerg, "06", "Exporta para Excel ?          ", "mv_ch6", "N", 01, 0, "C", "mv_par06", "",		"1-Sim",			"2-N縊"})
	
U_BRASX1(aRegs, aCabSX1)
	
PutSX1Help("P." + AllTrim(cPerg) + "01.", aHlp01, aHlp01, aHlp01, .T.)
PutSX1Help("P." + AllTrim(cPerg) + "02.", aHlp02, aHlp02, aHlp02, .T.)
PutSX1Help("P." + AllTrim(cPerg) + "03.", aHlp03, aHlp03, aHlp03, .T.)
PutSX1Help("P." + AllTrim(cPerg) + "04.", aHlp04, aHlp04, aHlp04, .T.)
PutSX1Help("P." + AllTrim(cPerg) + "05.", aHlp05, aHlp05, aHlp05, .T.)
PutSX1Help("P." + AllTrim(cPerg) + "06.", aHlp06, aHlp06, aHlp06, .T.)

Pergunte(cPerg,.F.)	

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
// Envia controle para a funcao SETPRINT 
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
do while .t.
	
	wnrel 	:= SetPrint(cString, cNomeProg, cPerg, @cTitulo, cDesc1, cDesc2, cDesc3, .F.,, .F., cTamanho,, .F.)
	
	if nLastKey == 27
	   Return()
	endif
    
	if mv_par02 < mv_par01
		Help(" ", 1, "ATENﾇﾃO",, "O c?digo da tabela de pre輟s final dever? ser maior ou igual ao c?digo da tabela de pre輟s inicial." + chr(13) + chr(10) + "Espec?fico Brasitech", 1)

	elseif mv_par04 < mv_par03
		Help(" ", 1, "ATENﾇﾃO",, "O c?digo do produto final dever? ser maior ou igual ao c?digo do produto inicial." + chr(13) + chr(10) + "Espec?fico Brasitech", 1)

	else
		exit

	endif
	
enddo

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
// Verifica Posicao do Formulario na Impressora 
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
SetDefault(aReturn, cString)

if nLastKey == 27
   Return
endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
// Inicio da Impressao                          
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
RptStatus({ || SelecRel()}, cTitulo)

Return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		SelecRel                                                      /@
@type				Static function                                               /@
@date				31/08/2017                                                    /@
@description	Chamado pela user function RELFATTAB. Processa e imprime as
					informa鋏es do relat?rio.                                     /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Op鈬o Um Consultoria                                          /@
@use				Especifico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function SelecRel()
Local nLin					:= 80
Local cEol					:= chr(13) + chr(10)
Local lVigente				:= (mv_par05 == 1)
Local lExcel				:= (mv_par06 == 1)
Local cTituloExcel		:= AllTrim(SM0->M0_NOME) + " - " + AllTrim(cTitulo) + " - " + AllTrim(SM0->M0_FILIAL) + " (" + SM0->M0_CODFIL + ")"
Local cWorkPar				:= "Par穃etros"
Local cWorkPlan 			:= "Relat?rio"
Local cFrTitCor	 		:= "#666666"	//Cinza nas letras do titulo
Local cBgTitCor			:= "#FFFFFF"	//Branco no fundo do titulo
Local cFrCabCor			:= "#FFFFFF"	//Branco nas letras do cabecalho
Local cBgCabCor			:= "#1F2731"	//Azul escuro no fundo do cabecalho
Local cFrLinCor			:= "#000000"	//Preto nas letras da linha detalhe
Local cBgLinCor			:= "#E0F0F0"	//Branco no fundo da linha detalhe
Local cFrLin2Cor			:= "#000000"	//Preto nas letras da linha alternada detalhe
Local cBgLin2Cor			:= "#BCD2EE"	//Azul claro no fundo da linha alternada detalhe
Local nLeftAlign			:= 1
Local nCenterAlign		:= 2
Local nRightAlign			:= 3
Local nGeneralFormat		:= 1
Local nNumberFormat		:= 2
Local nCurrencyFormat	:= 3
Local nDateFormat			:= 4
Local cCodTab
Local nX, nK

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Inicia tarefas para possibilitar a abertura do Excel com informacoes do relatorio
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if lExcel

	//Cria objeto classe FWMsExcel
	oFWExcel:= FWMsExcel():New()

	//Defini鈬o de fonte, tamanho e cores
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
		oFWExcel:AddColumn(cWorkPar, cTituloExcel, "Perguntas", nGeneralFormat)
		oFWExcel:AddColumn(cWorkPar, cTituloExcel, "Respostas", nGeneralFormat)
		for nK := 1 to Len(aPerg)
			oFWExcel:AddRow(cWorkPar, cTituloExcel, aPerg[nK])
		next
	endif

	//Pasta da planilha
	oFWExcel:AddworkSheet(cWorkPlan)
	oFWExcel:AddTable(cWorkPlan, cTituloExcel)

	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Tabela de Pre輟",			nLeftAlign,  nGeneralFormat, .F.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Descri鈬o Tab. Pre輟", 	nLeftAlign,  nGeneralFormat, .F.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Produto", 					nLeftAlign,  nGeneralFormat, .F.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Descri鈬o Produto", 		nLeftAlign,  nGeneralFormat, .F.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Pre輟",						nRightAlign, nNumberFormat, .F.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Vig麩cia", 					nLeftAlign,  nGeneralFormat, .F.)

endif

SetRegua(3)

SB1->(dbSetOrder(1))

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
// Seleciona itens da tabela de pre輟s
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧 
IncRegua("Selecionando os itens a serem impressos")

if Select("TEMP") > 0
	TEMP->(dbCloseArea())
endif

cQuery := "SELECT DA0.DA0_CODTAB, DA0.DA0_DESCRI, DA0.DA0_DATDE, DA0.DA0_DATATE, "
cQuery += 			"DA1.DA1_CODTAB, DA1.DA1_CODPRO, DA1.DA1_PRCVEN, DA1.DA1_DATVIG "
cQuery += "FROM " + RetSqlName("DA0") + " DA0, " + RetSqlName("DA1") + " DA1 "
cQuery += "WHERE DA0.DA0_CODTAB BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' "
cQuery += 			"AND DA0.D_E_L_E_T_ = '' "
cQuery += 			"AND DA1.DA1_CODTAB = DA0.DA0_CODTAB "
cQuery += 			"AND DA1.DA1_CODPRO BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' "
if lVigente
   cQuery += 		"AND DA1.DA1_DATVIG < '" + dTOs(dDatabase) + "' " 
Endif
cQuery += 			"AND DA1.D_E_L_E_T_ = '' "
cQuery += "ORDER BY DA1.DA1_CODTAB, DA1.DA1_CODPRO, DA1.DA1_DATVIG"

dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TEMP", .F., .T.)
TcSetField("TEMP", "DA0_DATDE", "D")
TcSetField("TEMP", "DA0_DATATE", "D")
TcSetField("TEMP", "DA1_DATVIG", "D")

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
// Inicia impress縊 do relat?rio
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
IncRegua("Imprimindo os registros selecionados")
dbSelectArea("TEMP")
dbGoTop()
if TEMP->(!Eof())
	do while TEMP->(!Eof())
	
		if nLin > 56
			nLin := Cabec(cTitulo, cCabec1, cCabec2, cNomeprog, cTamanho, 18) + 1
		endif
		@ nLin, 001 Psay  "Tabela de Pre輟s: " + AllTrim(TEMP->DA0_CODTAB) + " - " + AllTrim(TEMP->DA0_DESCRI)
		nLin+=2
		
		cCodTab := TEMP->DA0_CODTAB
		
		do while TEMP->(!Eof() .and. DA0_CODTAB == cCodTab)
	
			if nLin > 56
				nLin := Cabec(cTitulo, cCabec1, cCabec2, cNomeprog, cTamanho, 18) + 1
				@ nLin, 001 Psay  "Tabela de Pre輟s: " + AllTrim(TEMP->DA0_CODTAB) + " - " + AllTrim(TEMP->DA0_DESCRI)
				nLin+=2
			endif
	
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
			// Imprime detalhe
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
			SB1->(dbSeek(xFilial("SB1") + TEMP->DA1_CODPRO))
			@ nLin, 000 PSay TEMP->DA1_CODPRO
			@ nLin, 019 PSay SB1->B1_DESC
			@ nLin, 071 PSay TEMP->DA1_PRCVEN	Picture "@E 999,999,999.99"
			@ nLin, 090 PSay TEMP->DA1_DATVIG
			nLin++
	
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
			// Gera informa鋏es para exporta鈬o para o Excel - Detalhe
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
			if lExcel
						
				aPlanilha := {}
	
				aAdd(aPlanilha, TEMP->DA0_CODTAB)
				aAdd(aPlanilha, TEMP->DA0_DESCRI)
				aAdd(aPlanilha, TEMP->DA1_CODPRO)
				aAdd(aPlanilha, SB1->B1_DESC)
				aAdd(aPlanilha, TEMP->DA1_PRCVEN)
				aAdd(aPlanilha, dTOc(TEMP->DA1_DATVIG))
						
				oFWExcel:AddRow(cWorkPlan, cTituloExcel, aPlanilha)
						
			endif
	
			TEMP->(dbSkip())
				
		enddo
		@ nLin++, 00 Psay __PrtThinLine()
	
	enddo
	
	Roda(CbCont, CbTxt, cTamanho)

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Abre planilha Excel 
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	if lExcel
	
		if !ApOleClient("MSExcel")
	
			Help(" ", 1, "ATENﾇﾃO",, "O Microsoft Excel n縊 est? instalado, portanto n縊 ser? poss?vel exportar as informa鋏es do relat?rio para o Excel." + cEol  + "(Espec?fico Brasitech)", 1)
	
		else
	
			MakeDir("C:\TEMP")
			cArq  	:= "C:\TEMP\" + AllTrim(CriaTrab(NIL, .F.)) + ".XML"
	
			oFWExcel:Activate()
			oFWExcel:GetXMLFile(cArq)
			oFWExcel:DeActivate()
			
			if !file(cArq)
			
				Help(" ", 1, "ATENﾇﾃO",, "N縊 foi poss?vel criar o arquivo tempor疵io para a abertura do Excel, portanto n縊 ser? poss?vel exportar as informa鋏es do relat?rio para o Excel." + cEol + "(Espec?fico Brasitech)", 1)
				
			else
			
				oExcel:= MsExcel():New()
				oExcel:WorkBooks:Open(cArq)
				oExcel:SetVisible(.T.)
				oExcel:Destroy()
			
			endif
			
			oFWExcel:= FreeObj(oFWExcel)
	
		endif
	
	endif

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	// Chama o Spool de Impressao para impressoes em Disco          
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	If aReturn[5] == 1
	   Set Printer To
	   dbCommitAll()
	   OurSpool(wnrel)
	Endif
	
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	// Libera o relatorio para Spool da Rede                        
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	MS_FLUSH()
	
else

	Help(" ", 1, "ATENﾇﾃO",, "N縊 h? informa鋏es a serem impressas com os par穃etros informados." + chr(13) + chr(10) + "Espec?fico Brasitech", 1)

endif

Set device to screen

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
// Fecha a tabela temporaria                                    
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
TEMP->(dbCloseArea())

Return()
