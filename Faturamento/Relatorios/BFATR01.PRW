/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ BFATR01  ³ Por: Adalberto Moreno Batista ³ Data ³25.07.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Emite relacao de quantidade e custos para notas de vendas  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Brasitech                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
#include "rwmake.ch"
User Function BFATR01()
Local _aRegs		:= {}
Local _aCabSX1		:= {"X1_GRUPO","X1_ORDEM","X1_PERGUNT","X1_VARIAVL","X1_TIPO","X1_TAMANHO","X1_DECIMAL","X1_GSC","X1_VAR01","X1_DEF01","X1_DEF02","X1_DEF03","X1_F3"}
Local aHlp01		:= {"Informe a data inicial do intevalo de",	"pesquisa das vendas e devolucoes de",	"vendas."}
Local aHlp02		:= {"Informe a data final do intevalo de",		"pesquisa das vendas e devolucoes de",	"vendas."}
Local aHlp03		:= {"Informe o produto inicial do intevalo",	"de pesquisa das vendas e devolucoes",	"de vendas."}
Local aHlp04		:= {"Informe o produto final do intevalo",		"de pesquisa das vendas e devolucoes",	"de vendas."}
Local aHlp05		:= {"Informe quais operacoes devem ser",		"relacionadas, com relação à geração",	"de títulos."}
Local aHlp06		:= {"Informe se as devoluções de vendas",		"serão ou não consideradas.",			""}
Local aHlp07		:= {"Informe o caminho e nome do arquivo",		"com extensao CSV.",					""}
Local aHlp08		:= {"Informe os códigos de filiais ou o seu",	"intervalo que serão considerados no",	"relatório."}
Private cPerg		:= PadR("BFATR01",Len(SX1->X1_GRUPO))
Private cDesc1 		:= "Emite relação de produtos e custos"
Private cDesc2 		:= ""
Private cDesc3 		:= ""
Private lAbortPrint	:= .F.
Private limite     	:= 80
Private tamanho    	:= "M"
Private nTipo      	:= 18
Private aReturn    	:= { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey   	:= 0
Private nomeprog   	:= "BFATR01"
Private titulo     	:= "Relacao de produtos e custos"
Private nLin       	:= 80
Private cString    	:= "SD2"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para impressao do cabecalho e rodape           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cbtxt      	:= Space(10)
Private cbcont     	:= 0
Private CONTFL     	:= 1
Private m_pag      	:= 1
Private Cabec2 	:= " "
Private Cabec1 	:= " Produto           Descricao                         Quantidade      Custo Unitario      Custo Total"
/*
Cod             | Produto                        |  Quantidade | Custo Unitario |    Custo Total |
xxxxxxxxxxxxxxx | XXXXXXXXXXxxxxxxxxxxXXXXXXXXXX | 999,999,999 | 999,999,999.99 | 999,999,999.99 |
1               | 19                             | 52          | 66             | 83             |
*/

aAdd( _aRegs, {cPerg, "01", "Da Emissao    ?", "mv_ch1", "D", 08, 0, "G", "mv_par01", "", "", "", ""} )
aAdd( _aRegs, {cPerg, "02", "Ate a Emissao ?", "mv_ch2", "D", 08, 0, "G", "mv_par02", "", "", "", ""} )
aAdd( _aRegs, {cPerg, "03", "Do Produto    ?", "mv_ch3", "C", 15, 0, "G", "mv_par03", "", "", "", "SB1"} )
aAdd( _aRegs, {cPerg, "04", "Ate o Produto ?", "mv_ch4", "C", 15, 0, "G", "mv_par04", "", "", "", "SB1"} )
aAdd( _aRegs, {cPerg, "05", "TES-Financeiro?", "mv_ch5", "N", 01, 0, "C", "mv_par05", "Gera Duplicata", "Não Gera Duplic", "Ambas", ""} )
aAdd( _aRegs, {cPerg, "06", "Devol. Vendas ?", "mv_ch6", "N", 01, 0, "C", "mv_par06", "Sim", "Nao", "", ""} )
aAdd( _aRegs, {cPerg, "07", "Arquivo CSV   ?", "mv_ch7", "C", 40, 0, "G", "mv_par07", "", "", "", ""} )
//aAdd( _aRegs, {cPerg, "08", "Filiais     ?", "mv_ch8", "C", 99, 0, "R", "mv_par08", "", "", "", "SM0","D2_FILIAL"} )
PutSX1(cPerg,"08","Filiais ?"		, "","","mv_ch8","C",99,0,1,"R","","SM0","","","mv_par08","","","","D2_FILIAL"	,"","","","","","","","","","","","")

U_BRASX1(_aRegs,_aCabSX1)

PutSX1Help("P." + AllTrim(cPerg) + "01.", aHlp01, aHlp01, aHlp01)
PutSX1Help("P." + AllTrim(cPerg) + "02.", aHlp02, aHlp02, aHlp02)
PutSX1Help("P." + AllTrim(cPerg) + "03.", aHlp03, aHlp03, aHlp03)
PutSX1Help("P." + AllTrim(cPerg) + "04.", aHlp04, aHlp04, aHlp04)
PutSX1Help("P." + AllTrim(cPerg) + "05.", aHlp05, aHlp05, aHlp05)
PutSX1Help("P." + AllTrim(cPerg) + "06.", aHlp06, aHlp06, aHlp06)
PutSX1Help("P." + AllTrim(cPerg) + "07.", aHlp07, aHlp07, aHlp07)
PutSX1Help("P." + AllTrim(cPerg) + "08.", aHlp08, aHlp08, aHlp08)

Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel 		:= SetPrint(cString,nomeprog,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,.F.,Tamanho,,.F.)

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
±±³Funcao³ SelecRel     ³ Por: Adalberto Moreno Batista ³ Data ³25.07.2011³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SelecRel()
Local _cQuery, nTamLin, cLin, cCpo, nHdl
Local nLin 		:= 100
Local aStru 	:= {	{"PRODUTO" ,"C",15,0},;
						{"QUANT"   ,"N",09,0},;
						{"CUSTO"   ,"N",12,2},;
						{"TIPO"    ,"C",01,0} }
Local cTrab 	:= CriaTrab(aStru,.T.)
Local aTGer 	:= {0,0}
Local lCalc		:= .T.
Local lContinua	:= .T.
Local cEol    	:= Chr(13) + Chr(10)
Local cArquivo	:= AllTrim(mv_par07)
Local cDevol08

MakeSqlExpr(cPerg)

SB1->(dbSetOrder(1))

dbUseArea(.T.,,cTrab,"TRAB",.T.)
dbSelectArea("TRAB")
IndRegua("TRAB", cTrab, "PRODUTO", , , "Criando Indice...")
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificando as notas de saida (SD2) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cQuery := "SELECT SD2.* "
_cQuery += "FROM " + RetSQLName("SD2") + " SD2, " + RetSQLName("SF4") + " SF4 "
_cQuery += "WHERE SD2.D2_EMISSAO BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "' "

if !empty(mv_par08)				//Filiais
	_cQuery	+=	" AND " + mv_par08 + " "
endif

_cQuery +=       "AND SD2.D2_COD BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' "
_cQuery +=       "AND SD2.D2_TIPO NOT IN ('D','B') "
_cQuery +=       "AND SD2.D_E_L_E_T_ <> '*' "

_cQuery +=       "AND SF4.F4_FILIAL = '" + xFilial("SF4") + "' "
_cQuery +=       "AND SF4.F4_CODIGO = SD2.D2_TES "
_cQuery +=       "AND SF4.D_E_L_E_T_ <> '*' "
_cQuery +=       "AND SF4.F4_ESTOQUE = 'S' "

if mv_par05=1
	_cQuery +=   "AND SF4.F4_DUPLIC = 'S' "
elseif mv_par05=2
	_cQuery +=   "AND SF4.F4_DUPLIC = 'N' "
endif

_cQuery += "ORDER BY SD2.D2_COD,SD2.D2_EMISSAO, SD2.D2_DOC"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificando se a existencia da area TRBa     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if Select("TRB") > 0
	dbSelectArea("TRB") 
	dbCloseArea()
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criando a tabela temporaria                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cQuery := ChangeQuery(_cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery),"TRB", .F., .T.)

//Alimentando arquivo temporario
dbSelectArea("TRB")
do while !eof()

	if TRAB->( !dbSeek( TRB->D2_COD ) )
		TRAB->(RecLock("TRAB",.T.))
		TRAB->PRODUTO	:= TRB->D2_COD
	else
		TRAB->(RecLock("TRAB",.F.))
	endif
	TRAB->QUANT		+= TRB->D2_QUANT
	TRAB->CUSTO		+= TRB->D2_CUSTO1
	TRAB->(MsUnlock())

	if empty(TRB->D2_SEQCALC)
		lCalc := .F.
	endif
	
	dbSkip()
	
enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificando notas de devolucao (SD1) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if mv_par06 = 1

	cDevol08 := StrTran(mv_par08, "D2_FILIAL", "D1_FILIAL")
	
	_cQuery := "SELECT SD1.* "
	_cQuery += "FROM " + RetSQLName("SD1") + " SD1, " + RetSQLName("SF4") + " SF4 "
	_cQuery += "WHERE SD1.D1_DTDIGIT BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "' "
	
	if !empty(mv_par08)				//Filiais
		_cQuery	+=	" AND " + cDevol08 + " "
	endif
	
	_cQuery +=       "AND SD1.D1_COD BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' "
	_cQuery +=       "AND SD1.D1_TIPO = 'D' "
	_cQuery +=       "AND SD1.D_E_L_E_T_ <> '*' "

	_cQuery +=       "AND SF4.F4_FILIAL = '" + xFilial("SF4") + "' "
	_cQuery +=       "AND SF4.F4_CODIGO = SD1.D1_TES "
	_cQuery +=       "AND SF4.D_E_L_E_T_ <> '*' "

	_cQuery +=   	 "AND SF4.F4_ESTOQUE = 'S' "

	if mv_par05=1
		_cQuery +=   "AND SF4.F4_DUPLIC = 'S' "
	elseif mv_par05=2
		_cQuery +=   "AND SF4.F4_DUPLIC = 'N' "
	endif
	
	_cQuery += "ORDER BY SD1.D1_COD, SD1.D1_DTDIGIT, D1_DOC"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verificando se a existencia da area TRBa     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if Select("TRB") > 0
		dbSelectArea("TRB")
		dbCloseArea()
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Criando a tabela temporaria                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cQuery := ChangeQuery(_cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery),"TRB", .F., .T.)
	
	//Alimentando arquivo temporario
	dbSelectArea("TRB")
	do while !eof()

		if TRAB->( !dbSeek( TRB->D1_COD ) )
			TRAB->(RecLock("TRAB",.T.))
			TRAB->PRODUTO	:= TRB->D1_COD
		else
			TRAB->(RecLock("TRAB",.F.))
		endif
		TRAB->QUANT		+= TRB->D1_QUANT * -1
		TRAB->CUSTO		+= TRB->D1_CUSTO * -1
		TRAB->(MsUnlock())

		dbSkip()
		
	enddo

endif

if Select("TRB") > 0
	dbSelectArea("TRB") 
	dbCloseArea()
endif

dbSelectArea("TRAB")
dbGoTop()
SetRegua(RecCount())
IncRegua()

if !lCalc
	lContinua := MsgBox("No período selecionado, foram encontrados registros que não tiveram o recalculo do custo médio e isto poderá impactar no resultado apresentado. Deseja continuar?","Pergunta","YESNO")
endif

if lContinua

	if !eof()

		if !empty(cArquivo)
			
			//grava a linha de cabecalho no arquivo texto
			nHdl    := fCreate(cArquivo)
			if nHdl == -1
				if !MsgBox("O arquivo de nome " + cArquivo + " nao pode ser criado! Continua somente com a geração do relatório e sem a criação do arquivo CSV?","Pergunta","YESNO")
					dbCloseArea()
					fErase(cTRAB + ".dbf")
					fErase(cTRAB + OrdBagExt())
				    Return()
				endif 
			endif

			if nHdl != -1
			
				cLin := "Produto;Descricao;Quantidade;Custo Unitario;Custo Total" + cEol
				
			    if fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			        if !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
						dbCloseArea()
						fErase(cTRAB + ".dbf")
						fErase(cTRAB + OrdBagExt())
					    Return()
		        	endif
			    endif
			    
			 endif

		else

			nHdl := -1

		endif
		
		aSTot := {0,0}
		do while !eof()
	
			IncRegua()
			
			if nLin > 56
				nLin := Cabec(Titulo, Cabec1, Cabec2, Nomeprog, Tamanho, 18) + 1
			endif
	
	        SB1->( dbSeek( xFilial("SB1") + TRAB->PRODUTO ) )
			@ nLin,01 PSay PRODUTO
			@ nLin,19 PSay SB1->B1_DESC
			@ nLin,52 PSay QUANT			Picture "@E 999,999,999"
			@ nLin,69 PSay CUSTO/QUANT		Picture "@E 9,999,999.9999"
			@ nLin,86 PSay CUSTO			Picture "@E 999,999,999.99" 
			nLin++
	
			//Grava a linha no arquivo texto
			if nHdl != -1
				cLin := AllTrim( StrTran(PRODUTO, ";"," ") ) + ";"
				cLin += AllTrim( StrTran(SB1->B1_DESC, ";"," ") ) + ";"
				cLin += AllTrim( StrTran(Str(QUANT), ".",",") ) + ";"
				cLin += AllTrim( StrTran(Str(Round(CUSTO/QUANT,4)), ".",",")  ) + ";"
				cLin += AllTrim( StrTran(Str(CUSTO), ".",",")  ) + cEol
				
			    if fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			        if !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
						dbCloseArea()
						fErase(cTRAB + ".dbf")
						fErase(cTRAB + OrdBagExt())
					    Return()
			        endif
			    endif
			endif
	
			//Total Geral
			aTGer[1] += QUANT
			aTGer[2] += CUSTO
			
			dbSkip()
	
		enddo
	    
		if aTGer[1] + aTGer[2] > 0
	
			@ nLin++,00 PSay Repl("-",100)
			@ nLin,01 PSay "Total Geral"
			@ nLin,52 PSay aTGer[1]		Picture "@E 999,999,999"
			@ nLin,86 PSay aTGer[2]		Picture "@E 999,999,999.99" 
			
		endif
	
	endif
	
	Roda(CbCont,CbTxt,tamanho)
	Set device to screen

	if nHdl != -1
		fClose(nHdl)
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
	
endif

dbCloseArea()
fErase(cTRAB + ".dbf")
fErase(cTRAB + OrdBagExt())

if nHdl != -1 .and. lContinua

	MsgBox("O arquivo " + cArquivo + " foi criado com sucesso", "Informação", "INFO")
	
endif
Return()
