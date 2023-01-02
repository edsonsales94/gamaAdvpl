#include "rwmake.ch"
#include "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ BFATR06  ³ Por: Luiz Fernando Nogueira   ³ Data ³12.12.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Lista entradas de produtos acabados na filial de vendas    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Brasitech                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function BFATR06()
Local _aRegs		:= {}
Local _aCabSX1		:= {"X1_GRUPO","X1_ORDEM","X1_PERGUNT","X1_VARIAVL","X1_TIPO","X1_TAMANHO","X1_DECIMAL","X1_GSC","X1_VAR01","X1_DEF01","X1_DEF02","X1_DEF03"}
Local aHlp01		:= {"Informe a data de entrada inicial", "", ""}
Local aHlp02		:= {"Informe a data de entrada final", "", ""}
Local aHlp03		:= {"Informe o Produto inicial.", "", ""}
Local aHlp04		:= {"Informe o Produto final.", "", ""}
Local aHlp05		:= {"Informe se deseja exportar", "relatório para o Excel",""}
Local aHlp06		:= {"Se escolher analítico", "imprime por nota fiscal",""}
Local aHlp07		:= {"Informe a origem dos produtos", "",""}
Private cPerg		:= PadR("BFATR06",Len(SX1->X1_GRUPO))
Private cDesc1 		:= "Lista entradas de produtos acabados na filial de vendas."
Private cDesc2 		:= ""
Private cDesc3 		:= ""
Private lAbortPrint	:= .F.
Private tamanho    	:= "P"
Private nTipo      	:= 18
Private aReturn    	:= { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey   	:= 0
Private nomeprog   	:= "BFATR06"
Private titulo     	:= "Entradas de produtos acabados"
Private nLin       	:= 80
Private cString    	:= "SD1"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para impressao do cabecalho e rodape           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cbtxt   := Space(10)
Private cbcont  := 0
Private CONTFL  := 1
Private m_pag   := 1                                      
Private Cabec1 	:= ""
Private Cabec2 	:= ""

aAdd( _aRegs, {cPerg, "01", "Data Entrada?"		, "mv_ch1","D", 08, 0,"G",	"mv_par01", "", "", ""} )
aAdd( _aRegs, {cPerg, "02", "Ate data entrada?"	, "mv_ch2","D", 08, 0,"G", 	"mv_par02", "", "", ""} )
aAdd( _aRegs, {cPerg, "03", "Do Produto?"		, "mv_ch3","C", 15, 0,"G", 	"mv_par03", "", "", ""} )
aAdd( _aRegs, {cPerg, "04", "Ate Produto?"		, "mv_ch4","C", 15, 0,"G", 	"mv_par04", "", "", ""} )
aAdd( _aRegs, {cPerg, "05", "Exporta para Excel?","mv_ch5","N", 01, 0,"C" ,	"mv_par05", "Sim", "Nao",""})
aAdd( _aRegs, {cPerg, "06", "Tipo?"				,"mv_ch6", "N", 01, 0,"C" ,	"mv_par06", "Sintetico"	, "Analitico",""})
aAdd( _aRegs, {cPerg, "07", "Origem?"			,"mv_ch7", "N", 01, 0,"C" ,	"mv_par07", "Nacional"	, "Importado","Ambos"})

U_BRASX1(_aRegs,_aCabSX1)

PutSX1Help("P." + AllTrim(cPerg) + "01.", aHlp01, aHlp01, aHlp01)
PutSX1Help("P." + AllTrim(cPerg) + "02.", aHlp02, aHlp02, aHlp02)
PutSX1Help("P." + AllTrim(cPerg) + "03.", aHlp03, aHlp03, aHlp03)      
PutSX1Help("P." + AllTrim(cPerg) + "04.", aHlp04, aHlp04, aHlp04)
PutSX1Help("P." + AllTrim(cPerg) + "05.", aHlp05, aHlp05, aHlp05)
PutSX1Help("P." + AllTrim(cPerg) + "06.", aHlp06, aHlp06, aHlp06)
PutSX1Help("P." + AllTrim(cPerg) + "07.", aHlp07, aHlp07, aHlp07)

Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := SetPrint(cString,nomeprog,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,.F.,Tamanho,,.F.)

If nLastKey == 27
   Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica Posicao do Formulario na Impressora ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio da Impressao                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RptStatus({|| SelecRel()},Titulo)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ SelecRel     Por: Luiz Fernando Nogueira   ³ Data ³02.12.2013  ³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SelecRel()
Local _cQuery
Local nLin 		:= 100
Local nCreate
Local cEol		:= chr(13) + chr(10)
Local cArq		:= ""
Local lExcel	:= (mv_par05 == 1)

Cabec1 := "Codigo                          "
Cabec2 := "Produto   Origem    Quantidade  "
//         xxxxxxxx  xx      9.999.999,99  
//         0         11      19            

If mv_par06 = 2
	Cabec1 += "Nota       Serie  Data"
	cabec2 += "Fiscal     NF     Entrada"
	//         xxxxxxxxx  xx     XX/XX/XXXX
	//         33         44     51
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona os dados do relatorio     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cQuery := "select D1_COD ,B1_XDESCNF, A2_EST, SUM(D1_QUANT) D1_QUANT "
if	mv_par06 = 2
	_cQuery += ",D1_DOC ,D1_SERIE ,D1_DTDIGIT "
endif 
_cQuery += "from " + RetSQLName("SD1")+ " SD1 LEFT OUTER JOIN "+ RetSQLName("SA2") +" SA2 ON D1_FILIAL = A2_FILIAL AND "
_cQuery += "D1_FORNECE = A2_COD AND D1_LOJA = A2_LOJA "
_cQuery += "left join SB1010 SB1 ON D1_COD = B1_COD "
_cQuery += "WHERE (D1_FORNECE = '07293118' or D1_CF LIKE '3%') AND "
_cQuery += "D1_FILIAL = '03' AND D1_TIPO = 'N' AND "
_cQuery += "D1_DTDIGIT BETWEEN '" + dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' and SD1.D_E_L_E_T_ = '' AND SA2.D_E_L_E_T_ = '' AND "
_cQuery += "D1_COD BETWEEN '" + MV_PAR03+"' AND '"+MV_PAR04+"' AND D1_TES <> '' "
if MV_PAR07 == 1
	_cQuery += "AND  A2_EST = 'AM' "
elseif MV_PAR07 == 2
	_cQuery += "AND  A2_EST <> 'AM' "
endif
_cQuery += "GROUP BY D1_COD ,B1_XDESCNF,A2_EST "
if	mv_par06 = 2
	_cQuery += ",D1_DOC	,D1_SERIE,D1_DTDIGIT "
endif
_cQuery += "ORDER BY A2_EST	,D1_COD "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificando se a existencia da area TRE      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if Select("TRE") > 0
	dbSelectArea("TRE") 
	dbCloseArea()
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criando a tabela temporaria                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cQuery := ChangeQuery(_cQuery)
memowrite("entradas_sp.sql",_cQuery)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery),"TRE", .F., .T.)
TcSetField("TRE","D1_DTDIGIT","D")

//——————————————————————————————————————————————————————————————————————————
// Inicia tarefas para a abertura do Excel com informações do relatório
//——————————————————————————————————————————————————————————————————————————
if lExcel
	if !ApOleClient("MSExcel")
		Help(" ", 1, "ATENCAO",, "O Microsoft Excel não está instalado, portanto não será possível exportar as informações do relatorio para o Excel." + cEol  + "(Específico DKT do Brasil). ", 1)
		lExcel := .F.
	else
		MakeDir("C:\TEMP")
		cArq := "C:\TEMP\ENT_"+Strtran(DtoS(date()),"/","_")+ Strtran(time(),":","") +".csv"
		nCreate	:= fCreate(cArq) 
				if nCreate = -1
			Help(" ", 1, "ATENCAO",, "Não foi possível criar o arquivo temporário para a abertura do Excel, portanto portanto não será possível exportar as informações do relatorio para o Excel." + cEol + "(Específico DKT do Brasil). ", 1)
			lExcel := .F.
		endif   
	endif

	if lExcel
		fWrite(nCreate, Titulo + cEol)
		fWrite(nCreate, "Codigo Produto;" +;
						"Origem;" +;
						"Quantidade;")		
		If mv_par06 = 2
			fWrite(nCreate, "Nota Fiscal;" +;
							"Serie NF;" +;
						    "Data Entrada")
		endif
		fWrite(nCreate, cEol)
	endif
endif

//——————————————————————————————————————————————————————————————————————————
// Inicia impressão do relatório
// Alimentando arquivo temporario
//——————————————————————————————————————————————————————————————————————————

dbSelectArea("TRE")
dbGoTop()
SetRegua(RecCount())

if !eof()
		
	do while TRE->(!eof())

		IncRegua()
		
		if nLin > 56
			nLin := Cabec(Titulo, Cabec1, Cabec2, Nomeprog, Tamanho, 18) + 1
		endif

		@ nLin,000 PSay Left(D1_COD,8)
		@ nLin,011 PSay A2_EST
		@ nLin,019 PSay D1_QUANT 	Picture "@E 9,999,999.99" 
		if mv_par06 = 2		
			@ nLin,033 PSay D1_DOC 
			@ nLin,044 PSay D1_SERIE
			@ nLin,051 PSay D1_DTDIGIT 
		endif
		nLin++  
	
		//——————————————————————————————————————————————————————————————————————————
		// Gera informações para exportação para o Excel 
		//——————————————————————————————————————————————————————————————————————————
		if lExcel
			fWrite(nCreate,	D1_COD + ";" +;
									B1_XDESCNF + ";" +;
									A2_EST + ";" +;
							Transform(D1_QUANT,"@E 9,999,999.99" ) +";")
			if mv_par06 = 2 
				fWrite(nCreate,	"'"+D1_DOC + ";" +; 
								D1_SERIE + ";" +;
								dtoc(D1_DTDIGIT))
				
			endif
			fWrite(nCreate,cEol)
		endif
		dbSkip()

	enddo
nLin+=2        
endif

Roda(CbCont,CbTxt,tamanho)
Set device to screen

//——————————————————————————————————————————————————————————————————————————
// Abre planilha Excel 
//——————————————————————————————————————————————————————————————————————————
if lExcel
	FClose(nCreate)
	oExcel := MSExcel():New()
	oExcel:WorkBooks:Open(cArq)
	oExcel:SetVisible(.T.)
	oExcel:Destroy()
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama o Spool de Impressao para impressoes em Disco          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] == 1
   Set Printer To
   dbCommitAll()
   OurSpool(wnrel)
Endif
	                                                                       
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Libera o relatorio para Spool da Rede                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MS_FLUSH()


if Select("TRE") > 0
	dbSelectArea("TRE") 
	dbCloseArea()
endif

Return()