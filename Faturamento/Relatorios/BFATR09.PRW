#include "rwmake.ch"
#include "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ BFATR09  ³ Por: Adalberto Moreno Batista ³ Data ³15.08.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Emite Posição de Embarque                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Brasitech                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±Alterado 				³ Por: Felipe Varella           ³ Data ³05.09.2014³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function BFATR09()
Local _aRegs		:= {}
Local _aCabSX1		:= {"X1_GRUPO","X1_ORDEM","X1_PERGUNT","X1_VARIAVL","X1_TIPO","X1_TAMANHO","X1_DECIMAL","X1_GSC","X1_VAR01","X1_DEF01","X1_DEF02","X1_DEF03","X1_F3"}
Local aHlp01		:= {"Informe a data de emissao inicial",	"das NF's.",						""}
Local aHlp02		:= {"Informe a data de emissao final",		"das NF's.",						""}
Local aHlp03		:= {"Informe o código de cliente",			"inicial.",							""}
Local aHlp04		:= {"Informe o código de cliente",			"final.",							""}
Local aHlp05		:= {"Informe se deseja exportar", 		  "relatório para o Excel"}
Private cPerg		:= PadR("BFATR09",Len(SX1->X1_GRUPO))
Private cDesc1 		:= "Emite Relação Posição de Embarque"
Private cDesc2 		:= ""
Private cDesc3 		:= ""
Private lAbortPrint	:= .F.
Private limite     	:= 220
Private tamanho    	:= "G"
Private nTipo      	:= 18
Private aReturn    	:= { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey   	:= 0
Private nomeprog   	:= "BFATR09"
Private titulo     	:= "Relacao Posição de Embarque"
Private nLin       	:= 80
Private cString    	:= "SD2"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para impressao do cabecalho e rodape           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cbtxt      	:= Space(10)
Private cbcont     	:= 0
Private CONTFL     	:= 1
Private m_pag      	:= 1
Private Cabec1 	:= "Nota      Codigo          Descricao                                         Data         Tipo"
Private Cabec2 	:= "Fiscal    Produto         Produto                           Qtde            Embarque     Transporte"
//                  999999999 999999999999999 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx    999999999999    99/99/99     xxxxxxxxxxxxxxx
//                  0         10              26                                60              76           89  

aAdd( _aRegs, {cPerg, "01", "Emissao De ?"	    , "mv_ch1", "D", 08, 0, "G", "mv_par01", "", "", "", ""} )
aAdd( _aRegs, {cPerg, "02", "Emissao Ate ?"  	, "mv_ch2", "D", 08, 0, "G", "mv_par02", "", "", "", ""} )
aAdd( _aRegs, {cPerg, "03", "Do Cliente    ?"	, "mv_ch3", "C", 08, 0, "G", "mv_par03", "", "", "", "SA1CLI"} )
aAdd( _aRegs, {cPerg, "04", "Ate o Cliente ?"	, "mv_ch4", "C", 08, 0, "G", "mv_par04", "", "", "", "SA1CLI"} )
aAdd( _aRegs, {cPerg, "05", "Exporta para Excel?","mv_ch5", "N", 01, 0,"C" , "mv_par05"	, "Sim" , "Nao","",	""})


U_BRASX1(_aRegs,_aCabSX1)

PutSX1Help("P." + AllTrim(cPerg) + "01.", aHlp01, aHlp01, aHlp01)
PutSX1Help("P." + AllTrim(cPerg) + "02.", aHlp02, aHlp02, aHlp02)
PutSX1Help("P." + AllTrim(cPerg) + "03.", aHlp03, aHlp03, aHlp03)
PutSX1Help("P." + AllTrim(cPerg) + "04.", aHlp04, aHlp04, aHlp04)
PutSX1Help("P." + AllTrim(cPerg) + "05.", aHlp05, aHlp05, aHlp05)


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
±±³Funcao³ SelecRel     ³ Por: Luiz Fernando Nogueira   ³ Data ³02.12.2013³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SelecRel()
Local _cQuery 	:= ""
Local cArq		:= ""
Local lExcel	:= (mv_par05 == 1)
Local cEol		:= chr(13) + chr(10)
Local nLin 		:= 100
Local nCreate

 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificando NFs Posição de Embarque                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

_cQuery := "SELECT D2_DOC, D2_COD, B1_DESC, D2_QUANT, "
_cQuery += "D2_EMISSAO, A4_VIA "
_cQuery += "FROM " + RetSQLName("SD2") + " SD2 JOIN " + RetSQLName("SF2") + " SF2 "
_cQuery += "ON D2_FILIAL = F2_FILIAL AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE "
_cQuery += "JOIN " + RetSQLName("SB1") + " SB1 "
_cQuery += "ON D2_COD = B1_COD "
_cQuery += "JOIN " + RetSQLName("SA4") + " SA4 "
_cQuery += "ON F2_TRANSP = A4_COD "
_cQuery += "WHERE "
_cQuery += "SD2.D2_FILIAL = '" + xFilial("SD2") + "' AND "
_cQuery += "SD2.D2_EMISSAO BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "' AND "
_cQuery += "SD2.D2_CLIENTE BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' AND "
_cQuery += "SD2.D_E_L_E_T_ = '' AND SF2.D_E_L_E_T_ = '' AND SB1.D_E_L_E_T_ = '' AND SA4.D_E_L_E_T_ = '' " 
_cQuery += "ORDER BY D2_DOC "


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificando se a existencia da area TRB      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

if Select("TRB") > 0
	dbSelectArea("TRB") 
	dbCloseArea()
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criando a tabela temporaria                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cQuery := ChangeQuery(_cQuery)
memowrite("SD2_RELTRANSP.sql",_cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery),"TRB", .F., .T.)
TcSetField("TRB","D2_EMISSAO","D")

//——————————————————————————————————————————————————————————————————————————
// Inicia tarefas para a abertura do Excel com informações do relatório
//——————————————————————————————————————————————————————————————————————————
if lExcel
	if !ApOleClient("MSExcel")
		Help(" ", 1, "ATENCAO",, "O Microsoft Excel não está instalado, portanto não será possível exportar as informações do relatorio para o Excel." + cEol  + "(Específico DKT do Brasil). ", 1)
		lExcel := .F.
	else
		MakeDir("C:\TEMP")
		cArq := "C:\TEMP\AR_"+Strtran(DtoS(date()),"/","_")+ Strtran(time(),":","") +".csv"
		nCreate	:= fCreate(cArq) 
				if nCreate = -1
			Help(" ", 1, "ATENCAO",, "Não foi possível criar o arquivo temporário para a abertura do Excel, portanto portanto não será possível exportar as informações do relatorio para o Excel." + cEol + "(Específico DKT do Brasil). ", 1)
			lExcel := .F.
		endif   
	endif
	
	if lExcel
		fWrite(nCreate, Titulo + cEol)
		fWrite(nCreate, "Nota Fiscal;" +;
						"Codigo Produto;" +;
						"Descricao Produto;" +;
						"Qtde;"			+;
						"Data Embarque;" +;
						"Tipo Transporte;" +;
					 	cEol)
	endif

endif

	
//——————————————————————————————————————————————————————————————————————————
// Inicia impressão do relatório
// Alimentando arquivo temporario
//——————————————————————————————————————————————————————————————————————————
	
dbSelectArea("TRB")
dbGoTop()
SetRegua(RecCount())

if !eof()
		
	do while TRB->(!eof())

		IncRegua()
		
		if nLin > 56
			nLin := Cabec(Titulo, Cabec1, Cabec2, Nomeprog, Tamanho, 18) + 1
		endif

		@ nLin,000 PSay D2_DOC
		@ nLin,010 PSay D2_COD
		@ nLin,026 PSay B1_DESC
		@ nLin,060 PSay D2_QUANT	Picture "@E 9,999,999.99"
		@ nLin,076 PSay D2_EMISSAO
		@ nLin,089 PSay A4_VIA
		
		nLin++
        
  
  
		//——————————————————————————————————————————————————————————————————————————
		// Gera informações para exportação para o Excel 
		//——————————————————————————————————————————————————————————————————————————
		if lExcel
			fWrite(nCreate,	"'" + D2_DOC	 	     + ";" 	+;
							D2_COD          		 + ";" 	+;
							B1_DESC  			 	 + ";"	+;
							CVALTOCHAR(D2_QUANT)	 + ";" 	+;
							dtoc(D2_EMISSAO) 		 + ";"  +;
							A4_VIA  			 	 + ";" 	+;
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


if Select("TRB") > 0
	dbSelectArea("TRB") 
	dbCloseArea()
endif

Return()             