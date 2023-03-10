#include "rwmake.ch"
#include "protheus.ch"
#include "TbiConn.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		BCOMR02                                                       /@
@type				Relat?rio                                                     /@
@date				17/04/2017                                                    /@
@description	Emite rela鈬o de pedidos pendentes de aprova鈬o.              /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Op鈬o Um Consultoria                                          /@
@use				Especifico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function BCOMR02()
Local aRegs				:= {}
Local aCabSX1			:= {"X1_GRUPO", "X1_ORDEM", "X1_PERGUNT", "X1_VARIAVL", "X1_TIPO", "X1_TAMANHO", "X1_DECIMAL", "X1_GSC", "X1_VAR01", "X1_DEF01", "X1_DEF02"}
Local aHlp01			:= {"Informe o intervalo inicial da data ",	"de emiss縊 do pedido de compras."}
Local aHlp02			:= {"Informe o intervalo final da data   ",	"de emiss縊 do pedido de compras."}
Local aHlp03			:= {"Informe se deseja exportar relat?rio", 	"para o Excel."}
Private cPerg 			:= PadR("REICR002", iif(Select("SX1") > 0, Len(SX1->X1_GRUPO), 10))
Private cTitulo		:= "Pedidos pendentes de aprova鈬o"
Private cNomePrg		:= "BCOMR02"
Private cDesc1 		:= "Relat?rio com informa鋏es sobre pedidos de compras pendentes de aprova鈬o."
Private cDesc2			:= ""
Private cDesc3 		:= ""

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Variaveis utilizadas para impressao do cabecalho e rodape 
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
Private cbtxt      	:= Space(10)
Private cbcont     	:= 0
Private CONTFL     	:= 1
Private m_pag      	:= 1
Private lAbortPrint	:= .F.
Private nLimite    	:= 132
Private cTamanho   	:= "G"
Private nTipo      	:= 18
Private aReturn    	:= {"Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey   	:= 0
Private nLin       	:= 80
Private cString    	:= "SC7"
Private cCabec1		:= "N?mero  Emiss縊   Fornecedor                                Observa鈬o                                            Moeda              Total        Total R$  Comprador            Aprovador"
Private cCabec2		:= "."
//                         999999  99/99/99  xxxxxxxxxxXXXXXXXXXXxxxxxxxxxxXXXXXXXXXX  xxxxxxxxxxXXXXXXXXXXxxxxxxxxxxXXXXXXXXXXxxxxxxxxxx            999,999,999.99  999,999,999.99  xxxxxxxxxxXXXXXXXXXX xxxxxxxxxxXXXXXXXXXX"
//                       0123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789
//                                 1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6        

aAdd(aRegs, {cPerg, "01", "Data inicial emiss縊          ", "mv_ch1", "D", 08, 0, "G", "mv_par01", "", ""})
aAdd(aRegs, {cPerg, "02", "Data final emiss縊            ", "mv_ch2", "D", 08, 0, "G", "mv_par02", "", ""})
aAdd(aRegs, {cPerg, "03", "Exporta p/ Excel?             ", "mv_ch3", "N", 01, 0, "C",	"mv_par03", "1-Sim", "2-N縊"})

U_BRASX1(aRegs, aCabSX1)

PutSX1Help("P." + AllTrim(cPerg) + "01.", aHlp01, aHlp01, aHlp01)
PutSX1Help("P." + AllTrim(cPerg) + "02.", aHlp02, aHlp02, aHlp02)
PutSX1Help("P." + AllTrim(cPerg) + "03.", aHlp03, aHlp03, aHlp03)

Pergunte(cPerg,.F.)
	
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
// Envia controle para a funcao SETPRINT 
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
do while .T.

	wnrel 	:= SetPrint(cString, cNomePrg, cPerg, @cTitulo, cDesc1, cDesc2, cDesc3, .F.,, .F., cTamanho,, .F.)

	if nLastKey == 27
	   Return
	endif
    
	if (mv_par01 > mv_par02)
		Help(" ", 1, "ｮ ATENﾇﾃO", , "O per?odo inicial dever? ser menor ou igual ao per?odo final." + chr(13) + chr(10) + "Espec?fico Brasitech", 1)
	else
		exit
	endif
	
enddo

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
// Verifica Posicao do Formulario na Impressora
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
SetDefault(aReturn, cString)

//覧覧覧覧覧覧覧覧覧覧?
// Inicio da Impressao
//覧覧覧覧覧覧覧覧覧覧?
RptStatus({|| ProcRel()}, cTitulo)

Roda(CbCont, CbTxt, cTamanho)
Set Device to Screen

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Chama o Spool de Impressao para impressoes em Disco
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
If aReturn[5] == 1
   Set Printer To
   dbCommitAll()
   OurSpool(wnrel)
Endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Libera o relatorio para Spool da Rede 
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
Ms_Flush()

Return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		PROCREL                                                       /@
@type				Static Function                                               /@
@date				17/04/2017                                                    /@
@description	Seleciona informa鋏es para o relat?rio                        /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Op鈬o Um Consultoria                                          /@
@use				Especifico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function ProcRel()
Local cQuery

ProcRegua(3)

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Selecionando registros para impress縊 do relat?rio
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
IncProc("Selecionando registros...")
// 18/01/2018 Acrescentado filtro para nao imprimir pedido encerrado ou com residuo eliminado , por claudio TI manaus
cQuery := "SELECT CR_USER, LEFT(CR_NUM,6) CR_NUM, A2_NOME, C7_EMISSAO, C7_USER, C7_X_OBSGE, SUM(C7_TOTAL) C7_TOTAL, C7_MOEDA, C7_TXMOEDA " +;
				"FROM " + RetSqlName("SCR") + " SCR, " + RetSqlName("SC7") + " SC7, " + RetSqlName("SA2") + " SA2 " +;
				"WHERE SCR.CR_STATUS = '02' " +;
						"AND SCR.CR_WF = '1' " +;
						"AND SCR.CR_TIPO = 'PC' " +;
						"AND SCR.D_E_L_E_T_ = ' ' " +;
						"AND SC7.C7_FILIAL = SCR.CR_FILIAL " +;
						"AND SC7.C7_NUM = LEFT(SCR.CR_NUM,6) " +;
						"AND SC7.C7_EMISSAO BETWEEN '" + dTOs(mv_par01) + "' AND '" + dTOs(mv_par02) + "' " +;
						"AND SC7.C7_ENCER<>'S' AND SC7.C7_RESIDUO<>'S' " + ;
						"AND SC7.D_E_L_E_T_ = ' ' " +;
						"AND SC7.C7_FILIAL = '" + xFilial("SC7") + "' " +;
						"AND SA2.A2_FILIAL = '" + xFilial("SA2") + "' " +;
						"AND SA2.A2_COD = SC7.C7_FORNECE " +;
						"AND SA2.A2_LOJA = SC7.C7_LOJA " +;
						"AND SA2.D_E_L_E_T_ = ' ' " +;
				"GROUP BY CR_USER, CR_NUM, A2_NOME, C7_EMISSAO, C7_USER, C7_X_OBSGE, C7_MOEDA, C7_TXMOEDA " +;
				"ORDER BY CR_NUM"

if Select("TEMP") > 0
	TEMP->(dbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TEMP", .F., .T.)
TcSetField("TEMP", "C7_EMISSAO", "D")

dbSelectArea("TEMP")
dbGoTop()
if !eof()
	IncProc("Imprimindo relat?rio...")
	PrintReport()
endif

IncProc("Concluindo impress縊...")
if Select("TEMP") > 0
	TEMP->(dbCloseArea())
endif

Return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		PRINTREPORT                                                   /@
@type				Static Function                                               /@
@date				29/03/2017                                                    /@
@description	Imprime as informa鋏es processadas                            /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Op鈬o Um Consultoria                                          /@
@use				Especifico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function PrintReport()
Local lExcel				:= (mv_par03 == 1)
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
Local nK, cObs, nTaxa
Local oExcel, oFWExcel, cArq, cConteudo, aPlanilha, aPerg

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

	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "N?mero",			nLeftAlign,  	nGeneralFormat, 	.F.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Emiss縊",		nLeftAlign,  	nGeneralFormat, 	.F.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Fornecedor",	nLeftAlign,  	nGeneralFormat, 	.F.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Comprador",		nLeftAlign,  	nGeneralFormat,	.F.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Aprovador",		nLeftAlign,  	nGeneralFormat, 	.F.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Observa鈬o", 	nLeftAlign,		nGeneralFormat, 	.F.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Moeda", 			nLeftAlign,		nGeneralFormat, 	.F.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Vlr Total", 	nRightAlign,  	nNumberFormat, 	.F.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Vlr Total R$", nRightAlign,  	nCurrencyFormat, 	.F.)
	
endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Inicia impressao do relatorio
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
do while TEMP->(!eof())

	if nLin + 5 > 72
		nLin := Cabec(cTitulo, cCabec1, cCabec2, cNomePrg, cTamanho, 18) + 1
	endif			

	cObs 		:= AllTrim(TEMP->C7_X_OBSGE)
	nTaxa		:= iif(TEMP->C7_TXMOEDA==0, 1, TEMP->C7_TXMOEDA)
	cMoeda	:= Left(GetMV("MV_MOEDA" + AllTrim(Str(TEMP->C7_MOEDA)), .F., ""), 8)
	
	@ nLin, 000 PSay TEMP->CR_NUM
	@ nLin, 008 PSay TEMP->C7_EMISSAO
	@ nLin, 018 PSay Left(TEMP->A2_NOME, 40)
	@ nLin, 114 PSay cMoeda
	@ nLin, 124 PSay TEMP->C7_TOTAL							Picture "@E 999,999,999.99"
	@ nLin, 140 PSay TEMP->C7_TOTAL * nTaxa					Picture "@E 999,999,999.99"
	@ nLin, 156 PSay Left(UsrFullName(TEMP->C7_USER), 20)
	@ nLin, 177 PSay Left(UsrFullName(TEMP->CR_USER), 20)
	@ nLin, 070 PSay AllTrim(MemoLine(cObs, 50, 1))
	for nK := 2 to MlCount(cObs, 50)
		@ ++nLin, 070 PSay AllTrim(MemoLine(cObs, 50, nK))
	next

	nLin++

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Gera informacoes para exportacao para o Excel
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	if lExcel
	
		aPlanilha := {}

		aAdd(aPlanilha, TEMP->CR_NUM)
		aAdd(aPlanilha, dTOc(TEMP->C7_EMISSAO))
		aAdd(aPlanilha, TEMP->A2_NOME)
		aAdd(aPlanilha, AllTrim(UsrFullName(TEMP->C7_USER)))
		aAdd(aPlanilha, AllTrim(UsrFullName(TEMP->CR_USER)))
		aAdd(aPlanilha, TEMP->C7_X_OBSGE)
		aAdd(aPlanilha, cMoeda)
		aAdd(aPlanilha, TEMP->C7_TOTAL)
		aAdd(aPlanilha, TEMP->C7_TOTAL * nTaxa)

		oFWExcel:AddRow(cWorkPlan, cTituloExcel, aPlanilha)

	endif

	TEMP->(dbSkip())
	
enddo

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Abre planilha Excel 
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if lExcel

	if !ApOleClient("MSExcel")

		Help(" ", 1, "ｮ ATENﾇﾃO",, "O Microsoft Excel n縊 est? instalado, portanto n縊 ser? poss?vel exportar as informa鋏es do relatorio para o Excel." + cEol  + "(Espec?fico Brasitech)", 1)

	else

		MakeDir("C:\TEMP")
		cArq := "C:\TEMP\" + AllTrim(CriaTrab(NIL, .F.)) + ".XML"

		oFWExcel:Activate()
		oFWExcel:GetXMLFile(cArq)
		oFWExcel:DeActivate()
		
		if !file(cArq)
		
			Help(" ", 1, "ｮ ATENﾇﾃO",, "N縊 foi poss?vel criar o arquivo tempor疵io para a abertura do Excel, portanto portanto n縊 ser? poss?vel exportar as informa鋏es do relatorio para o Excel." + cEol + "(Espec?fico Brasitech)", 1)
			
		else
		
			oExcel:= MsExcel():New()
			oExcel:WorkBooks:Open(cArq)
			oExcel:SetVisible(.T.)
			oExcel:Destroy()
		
		endif
		
		oFWExcel:= FreeObj(oFWExcel)

	endif

endif

Return()
