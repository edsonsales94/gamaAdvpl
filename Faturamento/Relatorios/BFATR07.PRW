#include "rwmake.ch"
#include "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ BFATR07  ³ Por: Felipe Varella           ³ Data ³13.12.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Lista Gerentes Vs. Clientes                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Brasitech                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function BFATR07()
Local _aRegs		:= {}
Local _aCabSX1		:= {"X1_GRUPO","X1_ORDEM","X1_PERGUNT","X1_VARIAVL","X1_TIPO","X1_TAMANHO","X1_DECIMAL","X1_GSC","X1_VAR01","X1_DEF01","X1_DEF02"}
Local aHlp01		:= {"Informe o Cliente inicial", "", ""}
Local aHlp02		:= {"Informe o Cliente Final", "", ""}
Local aHlp03		:= {"Informe se deseja exportar", "relatório para o Excel",""}
Private cPerg		:= PadR("BFATR07",Len(SX1->X1_GRUPO))
Private cDesc1 		:= "Lista Gerentes Vs. Clientes"
Private cDesc2 		:= ""
Private cDesc3 		:= ""
Private lAbortPrint	:= .F.
Private tamanho    	:= "M"
Private nTipo      	:= 18
Private aReturn    	:= { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey   	:= 0
Private nomeprog   	:= "BFATR07"
Private titulo     	:= "Lista Gerentes Vs. Clientes"
Private nLin       	:= 80
Private cString    	:= "SA1"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para impressao do cabecalho e rodape           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cbtxt   := Space(10)
Private cbcont  := 0
Private CONTFL  := 1
Private m_pag   := 1                                      
Private Cabec1 	:= ""
Private Cabec2 	:= ""

aAdd( _aRegs, {cPerg, "01", "Do Cliente?" , "mv_ch1", "C", 08, 0, "G", "mv_par01", "", ""} )
aAdd( _aRegs, {cPerg, "02", "Ate Cliente?", "mv_ch2", "C", 08, 0, "G", "mv_par02", "", ""} )
aAdd( _aRegs, {cPerg, "03", "Exporta para Excel?","mv_ch3", "N", 01, 0,"C","mv_par03", "Sim" , "Nao"})

U_BRASX1(_aRegs,_aCabSX1)

PutSX1Help("P." + AllTrim(cPerg) + "01.", aHlp01, aHlp01, aHlp01)
PutSX1Help("P." + AllTrim(cPerg) + "02.", aHlp02, aHlp02, aHlp02)
PutSX1Help("P." + AllTrim(cPerg) + "03.", aHlp03, aHlp03, aHlp03)      

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
±±³Funcao³ SelecRel     Por: Felipe Varella           ³ Data ³13.12.2013  ³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SelecRel()
Local _cQuery
Local nLin 		:= 100
Local nCreate
Local cEol		:= chr(13) + chr(10)    // Pula Linha
Local cArq		:= ""
Local lExcel	:= (mv_par03 == 1)

Cabec1 := "                                                          Nome"
Cabec2 := "Gerente                                       Codigo      Cliente"
//         xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx    xxxxxxxx    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//         0                                             46          58


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Seleciona os dados do relatorio     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cQuery := "select ZB_NOME, A1_COD, A1_NOME "
_cQuery += "from " + RetSQLName("SA1")+ " SA1 LEFT OUTER JOIN "+ RetSQLName("SA3") +" SA3 ON A1_VEND = A3_COD "
_cQuery += "JOIN "+ RetSQLName("SZB")+ " SZB ON A3_XEXECUT = ZB_COD "
_cQuery += "where SA1.D_E_L_E_T_ = '' AND SA3.D_E_L_E_T_ = '' AND SZB.D_E_L_E_T_ = '' AND "
_cQuery += "A1_COD BETWEEN '" + MV_PAR01 +"' AND '"+ MV_PAR02 + "' "

_cQuery += "ORDER BY ZB_NOME ,A1_COD ,A1_NOME "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificando se a existencia da area TRAB01   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if Select("TRAB01") > 0
	dbSelectArea("TRAB01") 
	dbCloseArea()
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criando a tabela temporaria                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cQuery := ChangeQuery(_cQuery)
memowrite("ger_vs_cli.sql",_cQuery)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery),"TRAB01", .F., .T.)

//——————————————————————————————————————————————————————————————————————————
// Inicia tarefas para a abertura do Excel com informações do relatório
//——————————————————————————————————————————————————————————————————————————
if lExcel
	if !ApOleClient("MSExcel")
		Help(" ", 1, "ATENCAO",, "O Microsoft Excel não está instalado, portanto não será possível exportar as informações do relatorio para o Excel." + cEol  + "(Específico DKT do Brasil). ", 1)
		lExcel := .F.
	else
		MakeDir("C:\TEMP")
		cArq := "C:\TEMP\RELCLI_"+Strtran(DtoS(date()),"/","_")+ Strtran(time(),":","") +".csv"
		nCreate	:= fCreate(cArq) 
				if nCreate = -1
			Help(" ", 1, "ATENCAO",, "Não foi possível criar o arquivo temporário para a abertura do Excel, portanto portanto não será possível exportar as informações do relatorio para o Excel." + cEol + "(Específico DKT do Brasil). ", 1)
			lExcel := .F.
		endif   
	endif

	if lExcel
		fWrite(nCreate, Titulo + cEol)
		fWrite(nCreate, "Gerente;" +;
						"Codigo;"  +;
						"Nome Cliente;") 		
		fWrite(nCreate, cEol)
	endif
endif


//——————————————————————————————————————————————————————————————————————————
// Inicia impressão do relatório
// Alimentando arquivo temporario
//——————————————————————————————————————————————————————————————————————————

dbSelectArea("TRAB01")
dbGoTop()
SetRegua(RecCount())

if !eof()
		
	do while TRAB01->(!eof())

		IncRegua()
		
		if nLin > 56
			nLin := Cabec(Titulo, Cabec1, Cabec2, Nomeprog, Tamanho, 18) + 1
		endif

		@ nLin,000 PSay ZB_NOME 
		@ nLin,046 PSay A1_COD
		@ nLin,058 PSay A1_NOME
//		if mv_par06 = 2		
//			@ nLin,033 PSay D1_DOC 
//			@ nLin,044 PSay D1_SERIE
//			@ nLin,051 PSay D1_DTDIGIT 
//		endif
		nLin++  
	
		//——————————————————————————————————————————————————————————————————————————
		// Gera informações para exportação para o Excel 
		//——————————————————————————————————————————————————————————————————————————
		if lExcel
			fWrite(nCreate,	ZB_NOME + ";" +;
							A1_COD + ";" +;
							A1_NOME + ";")
							
//							Transform(D1_QUANT,"@E 9,999,999.99" ) +";")
//			if mv_par06 = 2 
//				fWrite(nCreate,	"'"+D1_DOC + ";" +; 
//								D1_SERIE + ";" +;
//								dtoc(D1_DTDIGIT))
				
//			endif
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


if Select("TRAB01") > 0
	dbSelectArea("TRAB01") 
	dbCloseArea()
endif

Return()