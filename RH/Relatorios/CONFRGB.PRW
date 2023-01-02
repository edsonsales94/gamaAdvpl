#include 'protheus.ch'
#include 'parmtype.ch'

user function CONFRGB()
Local aRegs				:= {}
Local aCabSX1			:= {"X1_GRUPO", "X1_ORDEM", "X1_PERGUNT", "X1_VARIAVL", "X1_TIPO", "X1_TAMANHO", "X1_DECIMAL", "X1_GSC", "X1_VAR01", "X1_DEF01", "X1_DEF02"}
Local aHlp01			:= {"Informe Periodo ",	"de lancamentos das verbas."}
Local aHlp02			:= {"Informe o intervalo de Matriculas ",	"lancadas no Periodo Ex: (em branco todos) 000005-000010 (faixa) ou intercalado 000005;000012 (duas matriculas)"}
Local aHlp03			:= {"Informe o intervalo de Verbas ", 	"Lancadas no Periodo EX: 555-600 ou intercalado 400;555 (duas verbas)."}
Private cPerg 			:= PadR("CONFRGB", iif(Select("SX1") > 0, Len(SX1->X1_GRUPO), 10))
Private cTitulo		:= "Conferencia de Lancamentos de Verbas"
Private cNomePrg		:= "CONFRGB"
Private cDesc1 		:= "Relatório de Conferencia de Lancamentos de Verbas."
Private cDesc2			:= ""
Private cDesc3 		:= ""

//———————————————————————————————————————————————————————————
// Variaveis utilizadas para impressao do cabecalho e rodape 
//———————————————————————————————————————————————————————————
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
Private cString    	:= "RGB"
Private cCabec1		:= "CC     MAT        Nome                                        Verba  Descricao                                    Horas     Valor"
Private cCabec2		:= "."
//                         999999  99/99/99  xxxxxxxxxxXXXXXXXXXXxxxxxxxxxxXXXXXXXXXX  xxxxxxxxxxXXXXXXXXXXxxxxxxxxxxXXXXXXXXXXxxxxxxxxxx            999,999,999.99  999,999,999.99  xxxxxxxxxxXXXXXXXXXX xxxxxxxxxxXXXXXXXXXX"
//                       0123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789
//                                 1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6        

aAdd(aRegs, {cPerg, "01", "Periodo     ", "mv_ch1", "C", 06, 0, "G", "mv_par01", "", "","",""})
aAdd(aRegs, {cPerg, "02", "Matricula ? ", "mv_ch2", "C", 99, 0, "R", "mv_par02", "", "","","SRA"})
aAdd(aRegs, {cPerg, "03", "Roteiro ?   ", "mv_ch3", "C", 04, 0, "G", "mv_par03", "", "","",""})
aAdd(aRegs, {cPerg, "04", "Verbas?     ", "mv_ch4", "C", 99, 0, "R", "mv_par04", "", "","","SRV"})
aAdd(aRegs, {cPerg, "05", "Exporta para Excel?","mv_ch5", "N", 01, 0,"C" , "mv_par05"	, "Sim" , "Nao","",	""})

U_BRASX1(aRegs, aCabSX1)

PutSX1Help("P." + AllTrim(cPerg) + "01.", aHlp01, aHlp01, aHlp01)
PutSX1Help("P." + AllTrim(cPerg) + "02.", aHlp02, aHlp02, aHlp02)
PutSX1Help("P." + AllTrim(cPerg) + "03.", aHlp03, aHlp03, aHlp03)

Pergunte(cPerg,.F.)
	
//——————————————————————————————————————————————————————————————————————————
// Envia controle para a funcao SETPRINT 
//——————————————————————————————————————————————————————————————————————————
do while .T.

	wnrel 	:= SetPrint(cString, cNomePrg, cPerg, @cTitulo, cDesc1, cDesc2, cDesc3, .F.,, .F., cTamanho,, .F.)

	if nLastKey == 27
	   Return
	endif
    
	if len(alltrim(mv_par01))==0 
		Help(" ", 1, "® ATENÇÃO", , "O período deve ser informado." + chr(13) + chr(10) + "Específico ", 1)
	else
		exit
	endif
	
enddo

//——————————————————————————————————————————————
// Verifica Posicao do Formulario na Impressora
//——————————————————————————————————————————————
SetDefault(aReturn, cString)

//—————————————————————
// Inicio da Impressao
//—————————————————————
RptStatus({|| ProcRel()}, cTitulo)

Roda(CbCont, CbTxt, cTamanho)
Set Device to Screen

//—————————————————————————————————————————————————————
// Chama o Spool de Impressao para impressoes em Disco
//—————————————————————————————————————————————————————
If aReturn[5] == 1
   Set Printer To
   dbCommitAll()
   OurSpool(wnrel)
Endif

//———————————————————————————————————————
// Libera o relatorio para Spool da Rede 
//———————————————————————————————————————
Ms_Flush()
Return

Static Function ProcRel()
Local cQuery
Local cSqlSRA 
Local cSqlRGB

MakeSqlExpr(cPerg)
cSqlSRA := "%"+alltrim(MV_PAR02)+"%"
cSqlRGB:= "%"+alltrim(MV_PAR04)+"%"
If len(alltrim(MV_PAR04))==0
 cSqlRGB:="%"+"RGB_PD<>''"+"%"
Endif
If len(alltrim(MV_PAR02))==0
 cSqlSRA:="%"+"RA_MAT<>''"+"%"
Endif

ProcRegua(3)

//———————————————————————————————————————————————————————————————————
// Selecionando registros para impressão do relatório
//———————————————————————————————————————————————————————————————————
IncProc("Selecionando registros...")
// 18/01/2018 Acrescentado filtro para nao imprimir pedido encerrado ou com residuo eliminado , por claudio TI manaus

cAliasRGB := GetNextAlias()

BeginSql Alias cAliasRGB
 SELECT RGB_CC,RGB_MAT,RA_NOME,RGB_PD,RV_DESC,RGB_PERIOD,RGB_DTREF,RGB_HORAS,RGB_VALOR 
 FROM RGB010 RGB,SRA010 SRA,SRV010 SRV 
 WHERE RGB_FILIAL=%Exp:xfilial("RGB")% AND RGB_ROTEIR=%Exp:MV_PAR03% 
 AND RGB_PERIOD=%Exp:MV_PAR01%  AND %Exp:cSqlSRA% AND %Exp:cSqlRGB% AND RGB.%NotDel% AND 
 RA_FILIAL=RGB_FILIAL AND RA_MAT=RGB_MAT AND RA_MAT=RGB_MAT AND SRA.%NotDel%
 AND RV_FILIAL=RGB_FILIAL AND RV_COD=RGB_PD AND SRV.%NotDel% 
 ORDER BY RGB_MAT
EndSql
dbSelectArea(cAliasRGB)
dbGoTop()
if !eof()
	IncProc("Imprimindo relatório...")
	PrintReport()
endif

IncProc("Concluindo impressão...")
if Select(cAliasRGB) > 0
	(cAliasRGB)->(dbCloseArea())
endif

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		PRINTREPORT                                                   /@
@type				Static Function                                               /@
@date				29/03/2017                                                    /@
@description	Imprime as informações processadas                            /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Opção Um Consultoria                                          /@
@use				Especifico                                                 /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function PrintReport()
Local lExcel				:= (mv_par05 == 1)
Local cTituloExcel		:= AllTrim(SM0->M0_NOME) + " - " + AllTrim(cTitulo) + " - " + AllTrim(SM0->M0_FILIAL) + " (" + SM0->M0_CODFIL + ")"
Local cWorkPar				:= "Parâmetros"
Local cWorkPlan 			:= "Relatório"
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

//———————————————————————————————————————————————————————————————————————————————————
// Inicia tarefas para possibilitar a abertura do Excel com informacoes do relatorio
//———————————————————————————————————————————————————————————————————————————————————
if lExcel

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
		oFWExcel:AddColumn(cWorkPar, cTituloExcel, "Perguntas", nGeneralFormat)
		oFWExcel:AddColumn(cWorkPar, cTituloExcel, "Respostas", nGeneralFormat)
		for nK := 1 to Len(aPerg)
			oFWExcel:AddRow(cWorkPar, cTituloExcel, aPerg[nK])
		next
	endif

	//Pasta da planilha
	oFWExcel:AddworkSheet(cWorkPlan)
	oFWExcel:AddTable(cWorkPlan, cTituloExcel)

	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "C.Custo",			nLeftAlign,  	nGeneralFormat, 	.F.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Matricula",		nLeftAlign,  	nGeneralFormat, 	.F.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Nome",	nLeftAlign,  	nGeneralFormat, 	.F.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Verba",		nLeftAlign,  	nGeneralFormat,	.F.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Descricao",		nLeftAlign,  	nGeneralFormat, 	.F.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Data Ref.", 	nLeftAlign,		nGeneralFormat, 	.F.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Horas", 	nRightAlign,  	nNumberFormat, 	.F.)
	oFWExcel:AddColumn(cWorkPlan, cTituloExcel, "Vlr R$", nRightAlign,  	nCurrencyFormat, 	.F.)
	
endif

//———————————————————————————————
// Inicia impressao do relatorio
//———————————————————————————————
do while (cAliasRGB)->(!eof())

	if nLin + 5 > 72
		nLin := Cabec(cTitulo, cCabec1, cCabec2, cNomePrg, cTamanho, 18) + 1
	endif			
	
	@ nLin, 000 PSay (cAliasRGB)->RGB_CC
	@ nLin, 008 PSay (cAliasRGB)->RGB_MAT
	@ nLin, 016 PSay Left((cAliasRGB)->RA_NOME, 40)
	@ nLin, 056 PSay (cAliasRGB)->RGB_PD
	@ nLin, 062 PSay (cAliasRGB)->RV_DESC
	@ nLin, 100 PSay DTOC(STOD((cAliasRGB)->RGB_DTREF))
	@ nLin, 110 PSay (cAliasRGB)->RGB_HORAS
	@ nLin, 120 PSay (cAliasRGB)->RGB_VALOR
	

	nLin++

	//———————————————————————————————————————————————
	// Gera informacoes para exportacao para o Excel
	//———————————————————————————————————————————————
	if lExcel
		aPlanilha := {}
		aAdd(aPlanilha, (cAliasRGB)->RGB_CC)
		aAdd(aPlanilha, (cAliasRGB)->RGB_MAT)
		aAdd(aPlanilha, (cAliasRGB)->RA_NOME)
		aAdd(aPlanilha, (cAliasRGB)->RGB_PD)
		aAdd(aPlanilha, (cAliasRGB)->RV_DESC)
		aAdd(aPlanilha, DTOC(STOD((cAliasRGB)->RGB_DTREF)))
		aAdd(aPlanilha, (cAliasRGB)->RGB_HORAS)
		aAdd(aPlanilha, (cAliasRGB)->RGB_VALOR)
		oFWExcel:AddRow(cWorkPlan, cTituloExcel, aPlanilha)
	endif

	(cAliasRGB)->(dbSkip())
	
enddo

//———————————————————————————————————————————————————————————————————————————————
// Abre planilha Excel 
//———————————————————————————————————————————————————————————————————————————————
if lExcel

	if !ApOleClient("MSExcel")

		Help(" ", 1, "® ATENÇÃO",, "O Microsoft Excel não está instalado, portanto não será possível exportar as informações do relatorio para o Excel." + cEol  + "(Específico Brasitech)", 1)

	else

		MakeDir("C:\TEMP")
		cArq := "C:\TEMP\" + AllTrim(CriaTrab(NIL, .F.)) + ".XML"

		oFWExcel:Activate()
		oFWExcel:GetXMLFile(cArq)
		oFWExcel:DeActivate()
		
		if !file(cArq)
		
			Help(" ", 1, "® ATENÇÃO",, "Não foi possível criar o arquivo temporário para a abertura do Excel, portanto portanto não será possível exportar as informações do relatorio para o Excel." + cEol + "(Específico Brasitech)", 1)
			
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

