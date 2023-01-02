#include "rwmake.ch"

/*/

———————————————————————————————————————————————————————————————————————————————
@function		BFATR03                                                      /@
@type			Relatório                                                    /@
@date			10/01/2012                                                   /@
@description	Emite extrato de movimentações VPC                           /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————

/*/
User Function BFATR03()
Local aAreaSX3		:= SX3->(GetArea())
Local lContinua
Local aRegs			:= {}
Local aCabSX1		:= {"X1_GRUPO", "X1_ORDEM", "X1_PERGUNT", "X1_VARIAVL", "X1_TIPO", "X1_TAMANHO", "X1_DECIMAL", "X1_GSC", "X1_VAR01", "X1_F3", "X1_DEF01", "X1_DEF02"}
Local aHlp01		:= {"Informe o cliente inicial para o",		"intevalo de pesquisa dos movimentos VPC"}
Local aHlp02		:= {"Informe a loja inicial para o",		"intevalo de pesquisa dos movimentos VPC"}
Local aHlp03		:= {"Informe o cliente final para o",		"intevalo de pesquisa dos movimentos VPC"}
Local aHlp04		:= {"Informe o loja final para o",			"intevalo de pesquisa dos movimentos VPC"}
Local aHlp05		:= {"Informe a data inicial do intevalo de","pesquisa de movimentos VPC"}
Local aHlp06		:= {"Informe a data final do intevalo de",	"pesquisa de movimentos VPC"}
Local aHlp07		:= {"Informe se deseja exportar", 			"relatório para o Excel"}
Private cPerg		:= PadR("BFATR03", Len(SX1->X1_GRUPO))
Private cDesc1 		:= "Emite extrato de movimentações VPC por cliente"
Private cDesc2 		:= ""
Private cDesc3 		:= ""
Private lAbortPrint	:= .F.
Private aOrd       	:= {}
Private nLimite    	:= 220
Private cTamanho   	:= "G"
Private nTipo      	:= 18
Private aReturn    	:= { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey   	:= 0
Private cNomeprog  	:= "BFATR03"
Private cTitulo    	:= "Extrato de movimentacao VPC"
Private nLin       	:= 80
Private cString    	:= "SZK"
Private cFilterUser

//———————————————————————————————————————————————————————————————————————————————
// Variaveis utilizadas para impressao do cabecalho e rodape           
//———————————————————————————————————————————————————————————————————————————————
Private cbtxt      	:= Space(10)
Private cbcont     	:= 0
Private CONTFL     	:= 1
Private m_pag      	:= 1
Private Cabec1 	:= "                                                                                                                                                                              <------------------ SALDOS ------------------>"
Private Cabec2 	:= " Data      Historico                                                                                           Tipo                      Uso        Creditos         Debitos             NCC      Ctas.Pagar    Pedido Bonif"

SX3->(dbSetOrder(2))
lContinua := SX3->(dbSeek("ZK_CHAVE"))
RestArea(aAreaSX3)

if !lContinua
	Help(" ", 1, "ATENÇÃO", , "Esta empresa não possui configuração para uso de controle VPC." + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Brasitech). ", 1)
	Return()
endif


/*
Saldo Inicial
                                                                                                                                                                          <------------ saldos para uso em ------------>
Data      Historico                                                                                        Tipo                      Uso        Creditos         Debitos             NCC      Ctas.Pagar    Pedido Bonif
99/99/99  XXXXXXXXXXxxxxxxxxxxXXXXXXXXXXxxxxxxxxxxXXXXXXXXXXxxxxxxxxxxXXXXXXXXXXxxxxxxxxxxXXXXXXXXXXxxxxx  999-XXXXXXXXXXxxxxxxxxxx  XXX  999,999,999.99  999,999,999.99  999,999,999.99  999,999,999.99  999,999,999.99
1         11                                                  63                        89   94              110             126             142             158
*/

aAdd(aRegs, {cPerg,"01","Do Cliente ?", 		"mv_ch1", "C", 08, 0, "G", "mv_par01", "SA1VPC","",""})
aAdd(aRegs, {cPerg,"02","Da Loja ?", 			"mv_ch2", "C", 02, 0, "G", "mv_par02", "",		"",""})
aAdd(aRegs, {cPerg,"03","Até o Cliente ?", 		"mv_ch3", "C", 08, 0, "G", "mv_par03", "SA1VPC","",""})
aAdd(aRegs, {cPerg,"04","Até a Loja ?", 		"mv_ch4", "C", 02, 0, "G", "mv_par04", "",		"",""})
aAdd(aRegs, {cPerg,"05","Da Emissao ?", 		"mv_ch5", "D", 08, 0, "G", "mv_par05", "",		"",""})
aAdd(aRegs, {cPerg,"06","Ate a Emissao ?", 		"mv_ch6", "D", 08, 0, "G", "mv_par06", "",		"",""})
aAdd(aRegs, {cPerg,"07","Exporta para Excel?", 	"mv_ch7", "N", 01, 0, "C", "mv_par07", "",		"1-Sim","2-Não"})

U_BRASX1(aRegs, aCabSX1)

PutSX1Help("P." + AllTrim(cPerg) + "01.", aHlp01, aHlp01, aHlp01)
PutSX1Help("P." + AllTrim(cPerg) + "02.", aHlp02, aHlp02, aHlp02)
PutSX1Help("P." + AllTrim(cPerg) + "03.", aHlp03, aHlp03, aHlp03)
PutSX1Help("P." + AllTrim(cPerg) + "04.", aHlp04, aHlp04, aHlp04)
PutSX1Help("P." + AllTrim(cPerg) + "05.", aHlp05, aHlp05, aHlp05)
PutSX1Help("P." + AllTrim(cPerg) + "06.", aHlp06, aHlp06, aHlp06)
PutSX1Help("P." + AllTrim(cPerg) + "07.", aHlp07, aHlp07, aHlp07)

Pergunte(cPerg,.F.)

//———————————————————————————————————————————————————————————————————————————————
// Envia controle para a funcao SETPRINT        
//———————————————————————————————————————————————————————————————————————————————
wnrel 		:= SetPrint(cString, cNomeprog, cPerg, @cTitulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., cTamanho,, .T.)
cFilterUser := aReturn[7]

If nLastKey == 27
   Return
Endif

//———————————————————————————————————————————————————————————————————————————————
// Verifica Posicao do Formulario na Impressora 
//———————————————————————————————————————————————————————————————————————————————
SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

//———————————————————————————————————————————————————————————————————————————————
// Inicio da Impressao                          
//———————————————————————————————————————————————————————————————————————————————
RptStatus({|| SelecRel()}, cTitulo)

Return()


/*/

———————————————————————————————————————————————————————————————————————————————
@function		SelecRel                                                     /@
@type			Static function                                              /@
@date			10/01/2012                                                   /@
@description	Função para seleção e impressão das informações do extrato 
				de movimentações VPC                                         /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————

/*/
Static Function SelecRel()
Local cQuery, cCliente, cLoja, nSldNCC, nSldPAG, nSldPED
Local nLin 		:= 100
Local lExcel	:= (mv_par07 == 1)
Local cEol		:= chr(13) + chr(10)

SA1->(dbSetOrder(1))

//———————————————————————————————————————————————————————————————————————————————
// Verificando os clientes que possuem movimento VPC 
//———————————————————————————————————————————————————————————————————————————————
cQuery := "SELECT * "
cQuery += "FROM " + RetSQLName("SZK") + " SZK "
cQuery += "WHERE SZK.ZK_FILIAL = '" + xFilial("SZK") + "' "
cQuery +=       "AND SZK.ZK_DATA BETWEEN '" + dTOs(mv_par05) + "' AND '" + dTOs(mv_par06) + "' "
cQuery +=       "AND SZK.ZK_CLIENTE BETWEEN '" + mv_par01 + "' AND '" + mv_par03 + "' "
cQuery +=       "AND SZK.ZK_LOJA BETWEEN '" + mv_par02 + "' AND '" + mv_par04 + "' "
cQuery +=       "AND SZK.D_E_L_E_T_ <> '*' "
cQuery += "ORDER BY ZK_CLIENTE, ZK_DATA, ZK_TPCHV, ZK_CHAVE "

//———————————————————————————————————————————————————————————————————————————————
// Verificando se a existencia de area temporaria 
//———————————————————————————————————————————————————————————————————————————————
if Select("TRB") > 0
	TRB->( dbCloseArea() )
endif

//———————————————————————————————————————————————————————————————————————————————
// Criando a tabela temporaria                  
//———————————————————————————————————————————————————————————————————————————————
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TRB", .F., .T.)
TcSetField( "TRB", "ZK_DATA", "D" )

//——————————————————————————————————————————————————————————————————————————
// Inicia tarefas para a abertura do Excel com informações do relatório
//——————————————————————————————————————————————————————————————————————————
if lExcel
	if !ApOleClient("MSExcel")
		Help(" ", 1, "ATENCAO",, "O Microsoft Excel não está instalado, portanto não será possível exportar as informações do relatorio para o Excel." + cEol  + "(Específico DKT do Brasil). ", 1)
		lExcel := .F.
	else
		MakeDir("C:\TEMP")
		cArq  	:= "C:\TEMP\" + AllTrim(CriaTrab(NIL, .F.)) + ".CSV"
		nCreate	:= fCreate(cArq)
		if nCreate = -1
			Help(" ", 1, "ATENCAO",, "Não foi possível criar o arquivo temporário para a abertura do Excel, portanto portanto não será possível exportar as informações do relatorio para o Excel." + cEol + "(Específico DKT do Brasil). ", 1)
			lExcel := .F.
		endif   
	endif

	if lExcel
		fWrite(nCreate, cTitulo + cEol)
		fWrite(nCreate, "Cliente;" +;
						"Loja;" +;
						"Nome Cliente;" +;
						"Data;" +;
						"Histórico;" +;
						"Tipo;" +;
						"Descrição Tp;" +;
						"Uso;" +;
						"Créditos;" +;
						"Débitos;" +;
						"NCC;" +;
						"Ctas.Pagar;" +;
						"Pedido Bonif;" +;
						"Base Cálculo;" +;
						"Percentual;" +;
						cEol)
	endif

endif


//Alimentando arquivo temporario
dbSelectArea("TRB")
dbGoTop()
do while TRB->(!eof())

	//Testando o filtro de usuario
	if !empty(cFilterUser) .and. !(&cFilterUser)
		TRB->(dbSkip())
		loop
	endif

	cCliente	:= TRB->ZK_CLIENTE
	cLoja		:= TRB->ZK_LOJA
	nSldNCC 	:= 0
	nSldPAG 	:= 0
	nSldPED 	:= 0
	U_VPCCalcSld(cCliente, cLoja, "1", @nSldNCC, mv_par05 - 1)
	U_VPCCalcSld(cCliente, cLoja, "2", @nSldPAG, mv_par05 - 1)
	U_VPCCalcSld(cCliente, cLoja, "3", @nSldPED, mv_par05 - 1)
	
	if nLin > 60
		nLin := Cabec(cTitulo, Cabec1, Cabec2, cNomeprog, cTamanho, 18) + 1
	endif
	@ nLin, 000 PSay cCliente + "/" + cLoja + " - " + GetAdvFVal("SA1", "A1_NOME", xFilial("SA1") + cCliente + iif(!Empty(cLoja), cLoja, ""), 1)
	nLin += 2
	
	@ nLin, 011 PSay "Saldos Iniciais VPC"
	@ nLin, 174 PSay nSldNCC Picture "@E 999,999,999.99"
	@ nLin, 190 PSay nSldPAG Picture "@E 999,999,999.99"
	@ nLin, 206 PSay nSldPED Picture "@E 999,999,999.99"
	nLin++

	if lExcel
		fWrite(nCreate,	";" +;
						";" +;
						"Saldos Iniciais VPC;" +;
						";" +;
						";" +;
						";" +;
						";" +;
						";" +;
						";" +;
						";" +;
						Transform(nSldNCC, "@E 999,999,999.99") + ";" +;
						Transform(nSldPAG, "@E 999,999,999.99") + ";" +;
						Transform(nSldPED, "@E 999,999,999.99") + ";" +;
						";" +;
						";" +;
						cEol)
	endif
	
	do while TRB->(!eof() .and. ZK_CLIENTE == cCliente .and. ZK_LOJA == cLoja)
		if nLin > 60
			nLin := Cabec(cTitulo, Cabec1, Cabec2, cNomeprog, cTamanho, 18) + 1
			@ nLin, 000 PSay cCliente + "/" + cLoja + " - " + GetAdvFVal("SA1", "A1_NOME", xFilial("SA1") + cCliente + iif(!Empty(cLoja), cLoja, ""), 1)
			nLin += 2
		endif

		@ nLin, 001 PSay TRB->ZK_DATA
		@ nLin, 011 PSay Left(TRB->ZK_HISTOR, 98)
		@ nLin, 111 PSay TRB->ZK_TPVPC + "-" + Left(GetAdvFVal("SZI", "ZI_DESCR", xFilial("SZI") + TRB->ZK_TPVPC, 1), 20)
		@ nLin, 137 PSay TRB->ZK_USO
		if TRB->ZK_TIPO == "CR"
			@ nLin, 142 PSay TRB->ZK_VALOR		Picture "@E 999,999,999.99"
			nSldNCC += iif(Substr(TRB->ZK_USO,1,1) == "S", TRB->ZK_VALOR, 0)
			nSldPAG += iif(Substr(TRB->ZK_USO,2,1) == "S", TRB->ZK_VALOR, 0)
			nSldPED += iif(Substr(TRB->ZK_USO,3,1) == "S", TRB->ZK_VALOR, 0)
		elseif TRB->ZK_TIPO == "DB"
			@ nLin, 158 PSay TRB->ZK_VALOR		Picture "@E 999,999,999.99"
			nSldNCC -= iif(Substr(TRB->ZK_USO,1,1) == "S", TRB->ZK_VALOR, 0)
			nSldPAG -= iif(Substr(TRB->ZK_USO,2,1) == "S", TRB->ZK_VALOR, 0)
			nSldPED -= iif(Substr(TRB->ZK_USO,3,1) == "S", TRB->ZK_VALOR, 0)
		endif
		@ nLin, 174 PSay nSldNCC Picture "@E 999,999,999.99"
		@ nLin, 190 PSay nSldPAG Picture "@E 999,999,999.99"
		@ nLin, 206 PSay nSldPED Picture "@E 999,999,999.99"
		nLin++
	
		//——————————————————————————————————————————————————————————————————————————
		// Gera informações para exportação para o Excel 
		//——————————————————————————————————————————————————————————————————————————
		if lExcel
			fWrite(nCreate,	"'" + cCliente + ";" +;
							iif(!Empty(cLoja), "'" + cLoja, "") + ";" +;
							GetAdvFVal("SA1", "A1_NOME", xFilial("SA1") + cCliente + iif(!Empty(cLoja), cLoja, ""), 1) + ";" +;
							dTOc(TRB->ZK_DATA) + ";" +;
							TRB->ZK_HISTOR + ";" +;
							"'" + TRB->ZK_TPVPC + ";" +;
							GetAdvFVal("SZI", "ZI_DESCR", xFilial("SZI") + TRB->ZK_TPVPC, 1) + ";" +;
							TRB->ZK_USO + ";" +;
							Transform(iif(TRB->ZK_TIPO == "CR", TRB->ZK_VALOR, 0), "@E 999,999,999.99") + ";" +;
							Transform(iif(TRB->ZK_TIPO == "DB", TRB->ZK_VALOR, 0), "@E 999,999,999.99") + ";" +;
							Transform(nSldNCC, "@E 999,999,999.99") + ";" +;
							Transform(nSldPAG, "@E 999,999,999.99") + ";" +;
							Transform(nSldPED, "@E 999,999,999.99") + ";" +;
							Transform(TRB->ZK_BASCALC, "@E 999,999,999.99") + ";" +;
							Transform(TRB->ZK_PERC, "@E 999.99") + ";" +;
							cEol)
		endif

		TRB->( dbSkip() )
	enddo
	@ ++nLin, 011 PSay "Saldos Finais VPC (atenção, os valores apresentados não devem ser somados)"
	@ nLin, 174 PSay nSldNCC Picture "@E 999,999,999.99"
	@ nLin, 190 PSay nSldPAG Picture "@E 999,999,999.99"
	@ nLin, 206 PSay nSldPED Picture "@E 999,999,999.99"

	nLin++
	@ nLin, 000 PSay Repl("-", nLimite)
	nLin++
	
	if lExcel
		fWrite(nCreate,	";" +;
						";" +;
						"Saldos Finais VPC (atenção, os valores apresentados não devem ser somados);" +;
						";" +;
						";" +;
						";" +;
						";" +;
						";" +;
						";" +;
						";" +;
						Transform(nSldNCC, "@E 999,999,999.99") + ";" +;
						Transform(nSldPAG, "@E 999,999,999.99") + ";" +;
						Transform(nSldPED, "@E 999,999,999.99") + ";" +;
						";" +;
						";" +;
						cEol)

		fWrite(nCreate,	";;;;;;;;;;;;;;;" + cEol)

	endif
	
enddo

Roda(CbCont, CbTxt, ctamanho)
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

//———————————————————————————————————————————————————————————————————————————————
// Chama o Spool de Impressao para impressoes em Disco          
//———————————————————————————————————————————————————————————————————————————————
If aReturn[5] == 1
   Set Printer To
   dbCommitAll()
   OurSpool(wnrel)
Endif

//———————————————————————————————————————————————————————————————————————————————
// Libera o relatorio para Spool da Rede                        
//———————————————————————————————————————————————————————————————————————————————
MS_FLUSH()

//———————————————————————————————————————————————————————————————————————————————
// Verificando se a existencia de area temporaria 
//———————————————————————————————————————————————————————————————————————————————
if Select("TRB") > 0
	TRB->( dbCloseArea() )
endif

//———————————————————————————————————————————————————————————————————————————————
// Fim do Programa                                              
//———————————————————————————————————————————————————————————————————————————————
Return()
