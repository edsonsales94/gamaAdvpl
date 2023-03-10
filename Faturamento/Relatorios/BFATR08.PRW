#include "rwmake.ch"
#include "protheus.ch"

/*/
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????Ŀ??
???Programa  ? BFATR08  ? Por:    Felipe Varella	    ? Data ?18.12.2013???
?????????????????????????????????????????????????????????????????????????Ĵ??
???Descricao ?    Lista movimentos das sa?das por nota fiscal			  ???
?????????????????????????????????????????????????????????????????????????Ĵ??
???Uso       ? Especifico Brasitech                                       ???
??????????????????????????????????????????????????????????????????????????ٱ?
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
/*/

User Function BFATR08()
Local _aRegs		:= {}
Local _aCabSX1		:= {"X1_GRUPO","X1_ORDEM","X1_PERGUNT","X1_VARIAVL","X1_TIPO","X1_TAMANHO","X1_DECIMAL","X1_GSC","X1_VAR01","X1_DEF01","X1_DEF02"}
Local aHlp01		:= {"Do armazem?", "", ""}
Local aHlp02		:= {"Ate armazem?", "", ""}
Local aHlp03		:= {"Da emissao?", "", ""}
Local aHlp04		:= {"Ate emissao?", "", ""}
Local aHlp05		:= {"Da Filial?", "", ""}
Local aHlp06		:= {"Ate filial?", "", ""}
Local aHlp07		:= {"Informe se deseja exportar", "relat?rio para o Excel",""}
Private cPerg		:= PadR("BFATR08",Len(SX1->X1_GRUPO))
Private cDesc1 		:= "Lista Movimentos das sa?das por nota fiscal"
Private cDesc2 		:= ""
Private cDesc3 		:= ""
Private lAbortPrint	:= .F.
Private tamanho    	:= "P"
Private nTipo      	:= 18
Private aReturn    	:= { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey   	:= 0
Private nomeprog   	:= "BFATR08"
Private titulo     	:= "Movimentos das sa?das por nota fiscal"
Private nLin       	:= 80
Private cString    	:= "SD2"

//?????????????????????????????????????????????????????????????????????Ŀ
//? Variaveis utilizadas para impressao do cabecalho e rodape           ?
//???????????????????????????????????????????????????????????????????????
Private cbtxt   := Space(10)
Private cbcont  := 0
Private CONTFL  := 1
Private m_pag   := 1                                      
Private Cabec1 	:= ""
Private Cabec2 	:= ""

aAdd( _aRegs, {cPerg, "01", "Do armazem?"	, "mv_ch1", "C", 02, 0, "G", "mv_par01", "", ""} )
aAdd( _aRegs, {cPerg, "02", "Ate armazem?"	, "mv_ch2", "C", 02, 0, "G", "mv_par02", "", ""} )
aAdd( _aRegs, {cPerg, "03", "Da emissao?"	, "mv_ch3", "D", 08, 0, "G", "mv_par03", "", ""} )
aAdd( _aRegs, {cPerg, "04", "Ate emissao?"	, "mv_ch4", "D", 08, 0, "G", "mv_par04", "", ""} )
aAdd( _aRegs, {cPerg, "05", "Da filial?"	, "mv_ch5", "C", 02, 0, "G", "mv_par05", "", ""} )
aAdd( _aRegs, {cPerg, "06", "Ate filial?"	, "mv_ch6", "C", 02, 0, "G", "mv_par06", "", ""} )
aAdd( _aRegs, {cPerg, "07", "Exporta para Excel?","mv_ch7", "N", 01, 0,"C","mv_par07", "Sim"  , "Nao"})

U_BRASX1(_aRegs,_aCabSX1)

PutSX1Help("P." + AllTrim(cPerg) + "01.", aHlp01, aHlp01, aHlp01)
PutSX1Help("P." + AllTrim(cPerg) + "02.", aHlp02, aHlp02, aHlp02)
PutSX1Help("P." + AllTrim(cPerg) + "03.", aHlp03, aHlp03, aHlp03)      
PutSX1Help("P." + AllTrim(cPerg) + "04.", aHlp04, aHlp04, aHlp04)
PutSX1Help("P." + AllTrim(cPerg) + "05.", aHlp05, aHlp05, aHlp05)
PutSX1Help("P." + AllTrim(cPerg) + "06.", aHlp06, aHlp06, aHlp06)
PutSX1Help("P." + AllTrim(cPerg) + "07.", aHlp07, aHlp07, aHlp07)

Pergunte(cPerg,.F.)

//??????????????????????????????????????????????Ŀ
//? Envia controle para a funcao SETPRINT        ?
//????????????????????????????????????????????????
wnrel := SetPrint(cString,nomeprog,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,.F.,Tamanho,,.F.)

If nLastKey == 27
   Return
Endif

//??????????????????????????????????????????????Ŀ
//? Verifica Posicao do Formulario na Impressora ?
//????????????????????????????????????????????????
SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

//??????????????????????????????????????????????Ŀ
//? Inicio da Impressao                          ?
//????????????????????????????????????????????????
RptStatus({|| SelecRel()},Titulo)

Return()

/*
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????Ŀ??
???Funcao? SelecRel     Por: Felipe Varella			  ? Data ?18.12.2013  ???
??????????????????????????????????????????????????????????????????????????ٱ?
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
*/
Static Function SelecRel()
Local _cQuery
Local nLin 		:= 100
Local nCreate
Local cEol		:= chr(13) + chr(10)
Local cArq		:= ""
Local lExcel	:= (mv_par07 == 1)

Cabec1 := "Data         Nota          Codigo"
Cabec2 := "Emiss?o      Fiscal        Produto          Quantidade"
//         XX/XX/XX     xxxxxxxxx      xxxxxxxx        9.999.999,99  
//         0            13             27              42


//?????????????????????????????????????Ŀ
//? Seleciona os dados do relatorio     ?
//???????????????????????????????????????

_cQuery := "SELECT D2_EMISSAO ,D2_DOC ,D2_COD ,SUM(D2_QUANT) as D2_QUANT "
_cQuery += "FROM " + RetSQLName("SD2")+ " SD2 JOIN "+ RetSQLName("SF4") +" SF4 on D2_TES = F4_CODIGO "
_cQuery += "WHERE F4_TEXTO not like '%ARMAZE%' AND "                                                                                                              
_cQuery += "D2_LOCAL BETWEEN '" + MV_PAR01+"' AND '"+MV_PAR02+"' AND "
_cQuery += "D2_EMISSAO BETWEEN '" + dtos(MV_PAR03)+"' AND '"+ dtos(MV_PAR04)+"' AND SD2.D_E_L_E_T_ = '' AND "
_cQuery += "D2_FILIAL BETWEEN '" + MV_PAR05+"' AND '"+MV_PAR06+"' "
_cQuery += "GROUP BY D2_EMISSAO ,D2_DOC ,D2_COD "
_cQuery += "ORDER BY D2_EMISSAO,D2_DOC,D2_COD "


//??????????????????????????????????????????????Ŀ
//? Verificando se a existencia da area TRAB02   ?
//????????????????????????????????????????????????

if Select("TRAB02") > 0
	dbSelectArea("TRAB02") 
	dbCloseArea()
endif

//??????????????????????????????????????????????Ŀ
//? Criando a tabela temporaria                  ?
//????????????????????????????????????????????????

_cQuery := ChangeQuery(_cQuery)
memowrite("mov_saidas_nf.sql",_cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery),"TRAB02", .F., .T.)
TcSetField("TRAB02","D2_EMISSAO","D")

//??????????????????????????????????????????????????????????????????????????
// Inicia tarefas para a abertura do Excel com informa??es do relat?rio
//??????????????????????????????????????????????????????????????????????????

if lExcel
	if !ApOleClient("MSExcel")
		Help(" ", 1, "ATENCAO",, "O Microsoft Excel n?o est? instalado, portanto n?o ser? poss?vel exportar as informa??es do relatorio para o Excel." + cEol  + "(Espec?fico DKT do Brasil). ", 1)
		lExcel := .F.
	else
		MakeDir("C:\TEMP")
		cArq := "C:\TEMP\SAI_"+Strtran(DtoS(date()),"/","_")+ Strtran(time(),":","") +".csv"
		nCreate	:= fCreate(cArq) 
				if nCreate = -1
			Help(" ", 1, "ATENCAO",, "N?o foi poss?vel criar o arquivo tempor?rio para a abertura do Excel, portanto portanto n?o ser? poss?vel exportar as informa??es do relatorio para o Excel." + cEol + "(Espec?fico DKT do Brasil). ", 1)
			lExcel := .F.
		endif   
	endif

	if lExcel
		fWrite(nCreate, Titulo + cEol)
		fWrite(nCreate, "Data Emissao;" +;
						"Nota Fiscal;" +;
						"Codigo Produto;" +;
						"Quantidade;")		

		fWrite(nCreate, cEol)
	endif
endif


//??????????????????????????????????????????????????????????????????????????
// Inicia impress?o do relat?rio
// Alimentando arquivo temporario
//??????????????????????????????????????????????????????????????????????????

dbSelectArea("TRAB02")
dbGoTop()
SetRegua(RecCount())

if !eof()
		
	do while TRAB02->(!eof())

		IncRegua()
		
		if nLin > 56
			nLin := Cabec(Titulo, Cabec1, Cabec2, Nomeprog, Tamanho, 18) + 1
		endif

		@ nLin,000 PSay D2_EMISSAO
		@ nLin,013 PSay D2_DOC
		@ nLin,027 PSay LEFT(D2_COD,8)
		@ nLin,042 PSay D2_QUANT 	Picture "@E 9,999,999.99" 

		nLin++  
	
		//??????????????????????????????????????????????????????????????????????????
		// Gera informa??es para exporta??o para o Excel 
		//??????????????????????????????????????????????????????????????????????????
		if lExcel
			fWrite(nCreate,	dtoc(D2_EMISSAO) + ";" +;
							D2_DOC + ";" +;
							D2_COD + ";" +;
							Transform(D2_QUANT,"@E 9,999,999.99" ) +";")

			fWrite(nCreate,cEol)
		endif
		dbSkip()

	enddo
nLin+=2        
endif

Roda(CbCont,CbTxt,tamanho)
Set device to screen

//??????????????????????????????????????????????????????????????????????????
// Abre planilha Excel 
//??????????????????????????????????????????????????????????????????????????
if lExcel
	FClose(nCreate)
	oExcel := MSExcel():New()
	oExcel:WorkBooks:Open(cArq)
	oExcel:SetVisible(.T.)
	oExcel:Destroy()
endif

//??????????????????????????????????????????????????????????????Ŀ
//? Chama o Spool de Impressao para impressoes em Disco          ?
//????????????????????????????????????????????????????????????????
If aReturn[5] == 1
   Set Printer To
   dbCommitAll()
   OurSpool(wnrel)
Endif
	                                                                       
//??????????????????????????????????????????????????????????????Ŀ
//? Libera o relatorio para Spool da Rede                        ?
//????????????????????????????????????????????????????????????????
MS_FLUSH()


if Select("TRAB02") > 0
	dbSelectArea("TRAB02") 
	dbCloseArea()
endif

Return()