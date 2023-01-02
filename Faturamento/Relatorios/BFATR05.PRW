#include "rwmake.ch"
#include "protheus.ch"

/*/ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ BFATR05  ³ Por: Luiz Fernando Nogueira   ³ Data ³10.12.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatório Provisão de Comissões                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Brasitech                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/

User Function BFATR05()
Local _aRegs		:= {}
Local _aCabSX1		:= {"X1_GRUPO","X1_ORDEM","X1_PERGUNT","X1_VARIAVL","X1_TIPO","X1_TAMANHO","X1_DECIMAL","X1_GSC","X1_VAR01","X1_DEF01","X1_DEF02"}
Local aHlp01		:= {"Informe a filial inicial",	"",						""}
Local aHlp02		:= {"Informe a filial final",		"",						""}
Local aHlp03		:= {"Informe a data de emissao inicial",	"",						""}
Local aHlp04		:= {"Informe a data de emissao final",		"",						""}
Local aHlp05		:= {"Informe se deseja exportar",			"relatório para o Excel"}
Private cPerg		:= PadR("BFATR05",Len(SX1->X1_GRUPO))
Private cDesc1 		:= "Provisão de Comissões"
Private cDesc2 		:= ""
Private cDesc3 		:= ""
Private lAbortPrint	:= .F.
//Private limite     	:= 220
Private tamanho    	:= "M"
Private nTipo      	:= 18
Private aReturn    	:= { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey   	:= 0
Private nomeprog   	:= "BFATR05"
Private titulo     	:= "Provisão de Comissões"
Private nLin       	:= 80
Private cString    	:= "SE1"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para impressao do cabecalho e rodape           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cbtxt      	:= Space(10)
Private cbcont     	:= 0
Private CONTFL     	:= 1
Private m_pag      	:= 1
Private Cabec1 	:= "        Codigo       Nome                                                           Valor       Valor"
Private Cabec2 	:= "Filial  Cliente      Cliente               Executivo                                Titulo      Comissao"
//                  99      99999999-99  xxxxxxxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 9,999,999.99  9,999,999.99
//                  0       8            21                    43                                  79            93

aAdd( _aRegs, {cPerg, "01", "Da filial?"		, "mv_ch1", "C", 02, 0, "G", "mv_par01", "", ""} )
aAdd( _aRegs, {cPerg, "02", "Ate filial?"		, "mv_ch2", "C", 02, 0, "G", "mv_par02", "", ""} )
aAdd( _aRegs, {cPerg, "03", "Da Emissao?"		, "mv_ch3", "D", 08, 0, "G", "mv_par03", "", ""} )
aAdd( _aRegs, {cPerg, "04", "Ate Emissao?"		, "mv_ch4", "D", 08, 0, "G", "mv_par04", "", ""} )
aAdd( _aRegs, {cPerg, "05", "Exporta para Excel?","mv_ch5", "N", 01, 0, "C", "mv_par05", "Sim" , "Nao"})


U_BRASX1(_aRegs,_aCabSX1)

PutSX1Help("P." + AllTrim(cPerg) + "01.", aHlp01, aHlp01, aHlp01)
PutSX1Help("P." + AllTrim(cPerg) + "02.", aHlp02, aHlp02, aHlp02)
PutSX1Help("P." + AllTrim(cPerg) + "03.", aHlp03, aHlp03, aHlp03)

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


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona Comissoes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cQuery := "SELECT E1_FILIAL,E1_CLIENTE,E1_LOJA,E1_NOMCLI, "
_cQuery += "CASE WHEN EEC.ZB_NOME IS NULL OR EEC.ZB_NOME = '' THEN 'ZZ - V E R I F I C A R' ELSE EEC.ZB_NOME END AS ZB_NOME, "
_cQuery += "CASE E1_SALDO WHEN 0 THEN SUM(E1_VALOR) ELSE SUM(E1_SALDO) END AS [VALOR_TITULO], "
_cQuery += "CASE E1_SALDO WHEN 0 THEN round(SUM(E1_VALOR*(E1_COMIS1/100)),2) ELSE round(SUM(E1_SALDO*(E1_COMIS1/100)),2) END AS [VALOR_COMISSAO] "
_cQuery += "FROM " +RetSQLName("SE1")+ " LEFT OUTER JOIN " +RetSQLName("SA3")+ " ON E1_VEND1 = A3_COD "
_cQuery += "LEFT OUTER JOIN (SELECT ZB_COD, ZB_NOME, ZB_USUWEB FROM "+RetSQLName("SZB")+" WHERE  D_E_L_E_T_ = '') AS EEC "
_cQuery += "ON SA3010.A3_XEXECUT = EEC.ZB_COD WHERE "
_cQuery += "E1_COMIS1 <> 0 AND  E1_EMISSAO between '"+dtos(MV_PAR03)+"' and '"+dtos(MV_PAR04)+"' AND "
_cQuery += "(E1_BAIXA > '"+dtos(MV_PAR04)+"' OR E1_SALDO > 0) AND SE1010.D_E_L_E_T_ = '' AND E1_TIPO NOT IN ('NCC','RA') AND "
_cQuery += "E1_FILIAL Between '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
_cQuery += "GROUP BY E1_FILIAL,	E1_CLIENTE,	E1_LOJA,E1_NOMCLI,EEC.ZB_NOME,E1_SALDO "
_cQuery += "ORDER BY [VALOR_COMISSAO] desc "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificando se a existencia da area TRB      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if Select("TRD") > 0
	dbSelectArea("TRD")
	dbCloseArea()
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criando a tabela temporaria                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cQuery := ChangeQuery(_cQuery)
memowrite("PROV_COMIS.sql",_cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery),"TRD", .F., .T.)

//——————————————————————————————————————————————————————————————————————————
// Inicia tarefas para a abertura do Excel com informações do relatório
//——————————————————————————————————————————————————————————————————————————
if lExcel
	if !ApOleClient("MSExcel")
		Help(" ", 1, "ATENCAO",, "O Microsoft Excel não está instalado, portanto não será possível exportar as informações do relatorio para o Excel." + cEol  + "(Específico DKT do Brasil). ", 1)
		lExcel := .F.
	else
		MakeDir("C:\TEMP")
		cArq := "C:\TEMP\COMIS_"+Strtran(DtoS(date()),"/","_")+ Strtran(time(),":","") +".csv"
		nCreate	:= fCreate(cArq) 
				if nCreate = -1
			Help(" ", 1, "ATENCAO",, "Não foi possível criar o arquivo temporário para a abertura do Excel, portanto portanto não será possível exportar as informações do relatorio para o Excel." + cEol + "(Específico DKT do Brasil). ", 1)
			lExcel := .F.
		endif   
	endif
	
	if lExcel
		fWrite(nCreate, Titulo + cEol)
		fWrite(nCreate, "Filial;" +;
						"Cliente;" +;
						"Nome Cliente;" +;
						"Executivo;" +;
						"Valor Titulo;" +;
						"Valor Comissao;" +;
						cEol)
	endif

endif
	
//——————————————————————————————————————————————————————————————————————————
// Inicia impressão do relatório
// Alimentando arquivo temporario
//——————————————————————————————————————————————————————————————————————————
	
dbSelectArea("TRD")
dbGoTop()
SetRegua(RecCount())

if !eof()
		
	do while TRD->(!eof())

		IncRegua()
		
		if nLin > 56
			nLin := Cabec(Titulo, Cabec1, Cabec2, Nomeprog, Tamanho, 18) + 1
		endif

		@ nLin,000 PSay E1_FILIAL
		@ nLin,008 PSay E1_CLIENTE + '-' + E1_LOJA
		@ nLin,021 PSay E1_NOMCLI
		@ nLin,043 PSay ZB_NOME
		@ nLin,079 PSay VALOR_TITULO   Picture "@E 9,999,999.99" 
		@ nLin,093 PSay VALOR_COMISSAO Picture "@E 9,999,999.99" 		
		nLin++

		//——————————————————————————————————————————————————————————————————————————
		// Gera informações para exportação para o Excel 
		//——————————————————————————————————————————————————————————————————————————
		if lExcel
			fWrite(nCreate,	"'" + E1_FILIAL +";" +;
							E1_CLIENTE + '-' + E1_LOJA + ";" +;
							E1_NOMCLI + ";"	+;
							ZB_NOME + ";" +;
							Transform(VALOR_TITULO,"@E 9,999,999.99") + ";" +;
							Transform(VALOR_COMISSAO,"@E 9,999,999.99") + ";" +;
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


if Select("TRD") > 0
	dbSelectArea("TRD") 
	dbCloseArea()
endif

Return()             