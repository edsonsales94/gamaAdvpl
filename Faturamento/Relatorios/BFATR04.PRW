#include "rwmake.ch"
#include "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ BFATR04  ³ Por: Luiz Fernando Nogueira   ³ Data ³02.12.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relacao das notas que estao bloqueadas para separacao logis³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Brasitech                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function BFATR04()
Local _aRegs		:= {}
Local _aCabSX1		:= {"X1_GRUPO","X1_ORDEM","X1_PERGUNT","X1_VARIAVL","X1_TIPO","X1_TAMANHO","X1_DECIMAL","X1_GSC","X1_VAR01","X1_DEF01","X1_DEF02","X1_DEF03"}
Local aHlp01		:= {"Informe a data de emissao inicial",	"",						""}
Local aHlp02		:= {"Informe a data de emissao final",		"",						""}
Local aHlp03		:= {"Informe o número da NF inicial.",		"",						""}
Local aHlp04		:= {"Informe o número da NF final.",		"",						""}
Local aHlp05		:= {"Informe quais sao os tipos de",		"bloqueios a serem selecionados.",	""}
Local aHlp06		:= {"Se escolher relatorio analitico",		"imprime os codigos de produtos.",	""}
Local aHlp07		:= {"Informe se deseja exportar", 		  "relatório para o Excel"}
Private cPerg		:= PadR("BFATR04",Len(SX1->X1_GRUPO))
Private cDesc1 		:= "Emite relação de notas bloqueadas para separação logistica"
Private cDesc2 		:= ""
Private cDesc3 		:= ""
Private lAbortPrint	:= .F.
Private tamanho    	:= "G"
Private nTipo      	:= 18
Private aReturn    	:= { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey   	:= 0
Private nomeprog   	:= "BFATR04"
Private titulo     	:= "Relacao NF bloqueadas"
Private nLin       	:= 80
Private cString    	:= "SF2"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para impressao do cabecalho e rodape           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cbtxt   := Space(10)
Private cbcont  := 0
Private CONTFL  := 1
Private m_pag   := 1                                      
Private Cabec1 	:= ""
Private Cabec2 	:= ""

aAdd( _aRegs, {cPerg, "01", "Da emissao?"		, "mv_ch1", "D", 08, 0, "G", "mv_par01", "", "", ""} )
aAdd( _aRegs, {cPerg, "02", "Ate emissao?"		, "mv_ch2", "D", 08, 0, "G", "mv_par02", "", "", ""} )
aAdd( _aRegs, {cPerg, "03", "Da Nota?"			, "mv_ch3", "C", 09, 0, "G", "mv_par03", "", "", ""} )
aAdd( _aRegs, {cPerg, "04", "Ate Nota?"			, "mv_ch4", "C", 09, 0, "G", "mv_par04", "", "", ""} )
aAdd( _aRegs, {cPerg, "05", "Tipo Bloqueio?"	, "mv_ch5", "N", 01, 0, "C", "mv_par05", "Comercial", "Logistica", "Ambos"} )
aAdd( _aRegs, {cPerg, "06", "Tipo Relatorio?"	, "mv_ch6", "N", 01, 0, "C", "mv_par06", "Sintetico", "Analitico", ""} )
aAdd( _aRegs, {cPerg, "07", "Exporta para Excel?","mv_ch7", "N", 01, 0, "C", "mv_par07", "Sim"	  	, "Nao",""})

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
Local lExcel	:= (mv_par07 == 1)

Cabec1 := "Tipo        Numero   Nota          Data       Codigo        Nome                                     Nome                            "
Cabec2 := "Bloqueio    Pedido   Fiscal        Emissao    Cliente       Cliente                                  Gerente                         "
//         xxxxxxxxxx  999999   999999999-9   99/99/99   xxxxxxxx-xx   xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//         0           12       21            35         46            60                                       101

If mv_par06 = 1
	Cabec1 += "   Valor Total"
	cabec2 += ""
	//         999.999.999,99
	//         133
Else
	Cabec1 += "Codigo                     Valor Total"
	cabec2 += "Produto    Quantidade"
	//         xxxxxxxx   999.999,99   999.999.999,99
	//         133        144          157
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Selecionando Notas Bloqueadas       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cQuery := "select distinct D2_PEDIDO ,F2_DOC ,F2_SERIE ,F2_EMISSAO ,F2_CLIENTE ,F2_LOJA ,A1_NOME,A1_MUN,A1_EST, A3_XEXECUT, substring(ZB_NOME,1,30) ZB_NOME, "
_cQuery += "case F2_X_OPLOG when 'SN' then 'Logistica' when 'NS' then 'Comercial' when 'SS' then 'Ambos' end F2_X_OPLOG, "
_cQuery += "isnull(X5_DESCRI,'') X5_DESCRI, C5_PEDCLI "
If mv_par06 = 1
	_cQuery += ",F2_VALMERC+F2_VALIPI AS F2_XTOTAL "
Else
	_cQuery += ",D2_ITEM,D2_COD ,D2_QUANT ,F2_VALMERC+F2_VALIPI AS F2_XTOTAL "
Endif
_cQuery += "from "+RetSQLName("SF2")+" F2 LEFT OUTER JOIN "+RetSQLName("SA1")+" A1 on F2_CLIENTE = A1_COD and F2_LOJA = A1_LOJA and F2_EST = A1_EST "
_cQuery += "left join "+RetSQLName("SD2")+" D2 ON F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE AND F2_CLIENTE = D2_CLIENTE "
_cQuery += "left join "+RetSQLName("SA3")+" A3 ON A3_COD = A1_VEND "
_cQuery += "left join "+RetSQLName("SZB")+" ZB on ZB_COD = A3_XEXECUT "                                                                    
_cQuery += "left join "+RetSQLName("SC5")+" C5 on C5_NUM = D2_PEDIDO and C5_FILIAL = D2_FILIAL "
_cQuery += "LEFT JOIN (select * from "+RetSQLName("SX5")+" where X5_TABELA = 'ZC' and D_E_L_E_T_ = '') X5 ON X5_FILIAL = C5_FILIAL AND X5_CHAVE = C5_XOBSBLQ                                                                    
_cQuery += "where F2.D_E_L_E_T_ = '' and A1.D_E_L_E_T_ = '' and D2.D_E_L_E_T_ = '' AND A3.D_E_L_E_T_ = '' AND ZB.D_E_L_E_T_ = '' AND C5.D_E_L_E_T_ = '' AND "
_cQuery += "F2_EMISSAO BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "' AND " 
_cQuery += "F2_DOC  BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' AND " 
if mv_par05 = 1
	_cQuery +=   "F2_X_OPLOG = 'NS' "
elseif mv_par05 = 2
	_cQuery +=   "F2_X_OPLOG = 'SN' "
elseif mv_par05 = 3
	_cQuery +=   "F2_X_OPLOG LIKE '%S%'"
endif
_cQuery += "ORDER BY F2_EMISSAO,F2_DOC,D2_PEDIDO "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificando se a existencia da area TRC      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if Select("TRC") > 0
	dbSelectArea("TRC") 
	dbCloseArea()
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criando a tabela temporaria                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cQuery := ChangeQuery(_cQuery)
memowrite("bloq_sep.sql",_cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery),"TRC", .F., .T.)
TcSetField("TRC","F2_EMISSAO","D")

//——————————————————————————————————————————————————————————————————————————
// Inicia tarefas para a abertura do Excel com informações do relatório
//——————————————————————————————————————————————————————————————————————————
if lExcel
	if !ApOleClient("MSExcel")
		Help(" ", 1, "ATENCAO",, "O Microsoft Excel não está instalado, portanto não será possível exportar as informações do relatorio para o Excel." + cEol  + "(Específico DKT do Brasil). ", 1)
		lExcel := .F.
	else
		MakeDir("C:\TEMP")
		cArq := "C:\TEMP\BLQ_"+Strtran(DtoS(date()),"/","_")+ Strtran(time(),":","") +".csv"
		nCreate	:= fCreate(cArq) 
				if nCreate = -1
			Help(" ", 1, "ATENCAO",, "Não foi possível criar o arquivo temporário para a abertura do Excel, portanto portanto não será possível exportar as informações do relatorio para o Excel." + cEol + "(Específico DKT do Brasil). ", 1)
			lExcel := .F.
		endif   
	endif

	if lExcel
		fWrite(nCreate, Titulo + cEol)
		fWrite(nCreate, "Bloqueio;" 		+;
						"Pedido;" 			+;
						"Nota Fiscal;" 		+;
						"Emissão;"			+;
						"Código Cliente;" 	+;
						"Nome Cliente;" 	+;	
						"Municipio;"	+;
						"Estado;"	+;					
						"Nome Gerente;"		+;
						"Motivo;"			+;
						"Pedido Cliente;")
		If mv_par06 = 1
			fWrite(nCreate, "Valor Total;")
		Else
			fWrite(nCreate, "Codigo Produto;" +;
							"Quantidade;"+;
							"Valor Total;")
		endif						
		fWrite(nCreate, cEol)
	endif

endif

//——————————————————————————————————————————————————————————————————————————
// Inicia impressão do relatório
// Alimentando arquivo temporario
//——————————————————————————————————————————————————————————————————————————

dbSelectArea("TRC")
dbGoTop()
SetRegua(RecCount())

if !eof()
		
	do while TRC->(!eof())

		IncRegua()
		
		if nLin > 56
			nLin := Cabec(Titulo, Cabec1, Cabec2, Nomeprog, Tamanho, 18) + 1
		endif

		@ nLin,000 PSay F2_X_OPLOG
		@ nLin,012 PSay D2_PEDIDO
		@ nLin,021 PSay F2_DOC+'-'+F2_SERIE
		@ nLin,035 PSay F2_EMISSAO
		@ nLin,046 PSay F2_CLIENTE+'-'+F2_LOJA
		@ nLin,060 PSay A1_NOME 
		@ nLin,101 PSay ZB_NOME
		If mv_par06 = 1
			@ nLin,133 PSay F2_XTOTAL	Picture "@E 999,999,999.99" 
		Else		
			@ nLin,133 PSay D2_COD
			@ nLin,144 PSay D2_QUANT 	Picture "@E 9,999,999.99" 
			@ nLin,157 PSay F2_XTOTAL	Picture "@E 999,999,999.99" 
		Endif
		nLin++  
	
		//——————————————————————————————————————————————————————————————————————————
		// Gera informações para exportação para o Excel 
		//——————————————————————————————————————————————————————————————————————————
		if lExcel
			fWrite(nCreate,	F2_X_OPLOG				+ ";" +;
							"'"+D2_PEDIDO			+ ";" +;
							F2_DOC+'-'+F2_SERIE		+ ";" +;
							dtoc(F2_EMISSAO)		+ ";" +;
							F2_CLIENTE+'-'+F2_LOJA	+ ";" +;
							A1_NOME					+ ";" +;
							A1_MUN					+ ";" +;
							A1_EST					+ ";" +;
							ZB_NOME					+ ";" +;
							X5_DESCRI				+ ";" +;
							C5_PEDCLI				+ ";")
			If mv_par06 = 1
				fWrite(nCreate,	Transform(F2_XTOTAL,"@E 999,999,999.99" )) 
			Else 
				fWrite(nCreate,	D2_COD + ";"+ Transform(D2_QUANT,"@E 9,999,999.99" )+";" + Transform(F2_XTOTAL,"@E 999,999,999.99" )) 
			Endif
			fWrite(nCreate,;
			cEol)
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


if Select("TRC") > 0
	dbSelectArea("TRC") 
	dbCloseArea()
endif

Return()