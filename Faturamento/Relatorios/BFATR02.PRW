#include "rwmake.ch"
#include "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ BFATR02  ³ Por: Adalberto Moreno Batista ³ Data ³15.08.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Emite relacao de AR                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Brasitech                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±Alterado 				³ Por: Luiz Fernando Nogueira   ³ Data ³02.12.2013³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function BFATR02()
Local _aRegs		:= {}
Local _aCabSX1		:= {"X1_GRUPO","X1_ORDEM","X1_PERGUNT","X1_VARIAVL","X1_TIPO","X1_TAMANHO","X1_DECIMAL","X1_GSC","X1_VAR01","X1_DEF01","X1_DEF02","X1_DEF03","X1_F3"}
Local aHlp01		:= {"Informe a data de emissao inicial",	"das AR's.",						""}
Local aHlp02		:= {"Informe a data de emissao final",		"das AR's.",						""}
Local aHlp03		:= {"Informe o número da AR inicial.",		"",									""}
Local aHlp04		:= {"Informe o número da AR final.",		"",									""}
Local aHlp05		:= {"Informe o código de cliente",			"inicial.",							""}
Local aHlp06		:= {"Informe o código de cliente",			"final.",							""}
Local aHlp07		:= {"Informe quais sao os tipos de",		"registros a serem selecionados.",	""}
Local aHlp08		:= {"Informe se deseja exportar", 	        "relatório para o Excel"}
Local aHlp09		:= {"Considera AR's Internadas?",          	"",         						""}
Local aHlp10		:= {"Informe a data de internação inicial",	"das AR's.",						""}
Local aHlp11		:= {"Informe a data de internação final",	"das AR's.",						""}
Local aHlp12		:= {"Tipo de Relatório?",	"das AR's.",										""}
Local aHlp13		:= {"Informe a filial inicial",	               "",						""}
Local aHlp14		:= {"Informe a filial final", 	               "",						""}
Private cPerg		:= PadR("BFATR02",Len(SX1->X1_GRUPO))
Private cDesc1 		:= "Emite relação de A.R.s"
Private cDesc2 		:= ""
Private cDesc3 		:= ""
Private lAbortPrint	:= .F.
Private limite     	:= 220
Private tamanho    	:= "G"
Private nTipo      	:= 18
Private aReturn    	:= { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey   	:= 0
Private nomeprog   	:= "BFATR02"
Private titulo     	:= "Relacao AR"
Private nLin       	:= 80
Private cString    	:= "SZG"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para impressao do cabecalho e rodape           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cbtxt      	:= Space(10)
Private cbcont     	:= 0
Private CONTFL     	:= 1
Private m_pag      	:= 1
Private Cabec1 	:= "Numero  NF         Nome                                          Endereco                                  Municipio        CEP                                Codigo      Descricao                                    Valor Unit.    Valor        Cod.   Descricao                                                                         Data     Data        Data     Data        Data     Data       Data                                                                                   Codigo"
Private Cabec2 	:= "AR      Devolucao  Cliente                                   UF  Coleta                                    Coleta           Coleta    Tipo   Motivo            Produto     Produto                         Qtde         Com IPI        Total        Grupo  Grupo                          Executivo                                          Emissao  Solicitacao Coleta   Recebimento Laudo    Internacao Retorno  Status                CNPJ           Transportadora                           Postagem"
//                  999999  999999999  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xxxxxxxxxxxxxxx  xxxxxxxx  xxxxxx xxxxxxxxxxxxxxxxx xxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 999999999999 9,999,999.99   9,999,999.99 xxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 99/99/99 99/99/99    99/99/99 99/99/99    99/99/99 99/99/99   99/99/99 xxxxxxxxxxxxxxxxxxxxx xxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx xxxxxxxxxx
//                  0       8          19                                        61  65                                        107              124       134    141               159         171                             202          215            230          243    250                            281                                                333      342         354      363         375      384        395      404                   426            441                                      482

aAdd( _aRegs, {cPerg,  "01", "Da Data da AR ?"				, "mv_ch1",  "D", 08, 0, "G", "mv_par01", "", "", "", ""} )
aAdd( _aRegs, {cPerg,  "02", "Ate Data da AR?"				, "mv_ch2",  "D", 08, 0, "G", "mv_par02", "", "", "", ""} )
aAdd( _aRegs, {cPerg,  "03", "Da AR         ?"				, "mv_ch3",  "C", 06, 0, "G", "mv_par03", "", "", "", ""} )
aAdd( _aRegs, {cPerg,  "04", "Ate a AR      ?"				, "mv_ch4",  "C", 06, 0, "G", "mv_par04", "", "", "", ""} )
aAdd( _aRegs, {cPerg,  "05", "Do Cliente    ?"				, "mv_ch5",  "C", 08, 0, "G", "mv_par05", "", "", "", "SA1CLI"} )
aAdd( _aRegs, {cPerg,  "06", "Ate o Cliente ?"				, "mv_ch6",  "C", 08, 0, "G", "mv_par06", "", "", "", "SA1CLI"} )
aAdd( _aRegs, {cPerg,  "07", "Tipo Dev      ?"				, "mv_ch7",  "N", 01, 0, "C", "mv_par07" , "Reposicao", "Devolucao", "Ambos", ""} )
aAdd( _aRegs, {cPerg,  "08", "Exporta para Excel?"			, "mv_ch8",  "N", 01, 0, "C", "mv_par08"	, "Sim" , "Nao","",	""})
aAdd( _aRegs, {cPerg,  "09", "Considera AR's Internadas?", "mv_ch9",  "N", 01, 0, "C", "mv_par09"	, "Sim" , "Nao","",	""})
aAdd( _aRegs, {cPerg,  "10", "Da Data da Internação AR ?", "mv_ch10", "D", 08, 0, "G", "mv_par10", "", "", "", ""} )
aAdd( _aRegs, {cPerg,  "11", "Ate Data da Internação AR?", "mv_ch11", "D", 08, 0, "G", "mv_par11", "", "", "", ""} )
aAdd( _aRegs, {cPerg,  "12", "Tipo Relatório?"				, "mv_ch12", "N", 01, 0, "C", "mv_par12"	, "Analitico" , "Sintetico","",	""}) 
aAdd( _aRegs, {cPerg,  "13", "Da Filial ?"		   		, "mv_ch13",  "C", 02, 0, "G", "mv_par13", "", "", "", ""} )
aAdd( _aRegs, {cPerg,  "14", "Ate Filial?"		   		, "mv_ch14",  "C", 02, 0, "G", "mv_par14", "", "", "", ""} )

U_BRASX1(_aRegs,_aCabSX1)     

PutSX1Help("P." + AllTrim(cPerg) + "01.", aHlp01, aHlp01, aHlp01)                                              
PutSX1Help("P." + AllTrim(cPerg) + "02.", aHlp02, aHlp02, aHlp02)
PutSX1Help("P." + AllTrim(cPerg) + "03.", aHlp03, aHlp03, aHlp03)
PutSX1Help("P." + AllTrim(cPerg) + "04.", aHlp04, aHlp04, aHlp04)
PutSX1Help("P." + AllTrim(cPerg) + "05.", aHlp05, aHlp05, aHlp05)
PutSX1Help("P." + AllTrim(cPerg) + "06.", aHlp06, aHlp06, aHlp06)
PutSX1Help("P." + AllTrim(cPerg) + "07.", aHlp07, aHlp07, aHlp07)
PutSX1Help("P." + AllTrim(cPerg) + "08.", aHlp08, aHlp08, aHlp08)
PutSX1Help("P." + AllTrim(cPerg) + "09.", aHlp09, aHlp09, aHlp09)
PutSX1Help("P." + AllTrim(cPerg) + "10.", aHlp10, aHlp10, aHlp10)
PutSX1Help("P." + AllTrim(cPerg) + "11.", aHlp11, aHlp11, aHlp11)
PutSX1Help("P." + AllTrim(cPerg) + "12.", aHlp12, aHlp12, aHlp12)
PutSX1Help("P." + AllTrim(cPerg) + "13.", aHlp13, aHlp13, aHlp13)
PutSX1Help("P." + AllTrim(cPerg) + "14.", aHlp14, aHlp14, aHlp14)

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
Local lExcel	:= (mv_par08 == 1)
Local cEol		:= chr(13) + chr(10)
Local nLin 		:= 100
Local nCreate

 
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³  Monta Relatório Analitico sem Data Internação    ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

if mv_par12 == 1 .and. mv_par09 == 2


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificando as AR's                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	_cQuery := "SELECT ZG_NUMERO, ZG_SERIENF, ZG_NFDEVOL ,ZG_NFFMDEV ,ZG_NOMECLI ,ZG_ESTCOLE ,ZG_ENDCOLE ,ZG_MUNCOLE ,ZG_CEPCOLE, "
	_cQuery += "Substring(ZG_DESCMOT,1,17) ZG_DESCMOT, ZH_PRODUTO ,ZH_DESCRI ,ZH_QTDDEVO, "
	_cQuery += "cast((ZH_PRECONF * ZH_ALIQIPI) /100 as money) + ZH_PRECONF ValorPrecoUnitComIPI ,ZG_VALOR, "
	_cQuery += "BM_GRUPO ,BM_DESC ,ZB_NOME, "
	_cQuery += "ZG_EMISSAO ,ZG_DTDEVOL ,ZG_DTSOLIC ,ZG_DTCOLE ,ZG_DTENTES ,ZG_DTRECUS ,ZG_DTINTER ,ZG_DTRETOR, "
	_cQuery += "ZG_STATUS, ZG_CGC, ZG_NOMETRP, ZG_NUMOBJ, ZH_ORIGEM, ZG_CFOP, ZG_TIPO, ZG_VLRDESP, ZH_OPALICM, "
	_cQuery += "CASE ZG_TIPO WHEN 'R' THEN 'T'	WHEN 'D' THEN 'D' END AS ZG_TIPO, ZG_X_USUAR,ZG_OBSCOLE "
	_cQuery += "FROM " + RetSQLName("SZG")+" SZG JOIN "+ RetSQLName("SZH")+" SZH "
	_cQuery += "ON ZG_FILIAL = ZH_FILIAL AND ZG_NUMERO = ZH_NUMERO "
	_cQuery += "JOIN " + RetSQLName("SB1")+" SB1 "
	_cQuery += "ON	B1_COD = ZH_PRODUTO "
	_cQuery += "JOIN "+ RetSQLName("SBM")+" SBM "
	_cQuery += "ON B1_GRUPO = BM_GRUPO "
	_cQuery += "JOIN "+ RetSQLName("SA1")+" SA1 "
	_cQuery += "ON A1_COD = ZG_CLIENTE AND A1_LOJA = ZG_LOJACLI "
	_cQuery += "JOIN "+ RetSQLName("SA3")+" SA3 "
	_cQuery += "ON A1_VEND = A3_COD "
	_cQuery += "JOIN "+ RetSQLName("SZB")+" SZB "
	_cQuery += "ON ZB_COD = A3_XEXECUT "
	_cQuery += "WHERE "
	if (mv_par07 == 1)
		_cQuery +=   " SZG.ZG_TIPO = 'R' AND "
		elseif (mv_par07 == 2)
		_cQuery +=   " SZG.ZG_TIPO = 'D' AND "
	endif
	_cQuery += "SZG.ZG_FILIAL  BETWEEN '" + mv_par13 + "' AND '" + mv_par14 + "' AND " 
	_cQuery += "SZG.ZG_EMISSAO BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "' AND " 
	_cQuery += "SZG.ZG_NUMERO  BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' AND " 
	_cQuery += "SZG.ZG_CLIENTE BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' AND "
	_cQuery += "SZG.D_E_L_E_T_ = '' AND SZH.D_E_L_E_T_ = '' AND SB1.D_E_L_E_T_ = '' AND SBM.D_E_L_E_T_ = '' "
	_cQuery += "AND SA1.D_E_L_E_T_ = '' AND SA3.D_E_L_E_T_ = '' AND SZB.D_E_L_E_T_ = '' "		
	_cQuery += "ORDER BY ZG_NUMERO"		

elseif mv_par12 == 1 .and. mv_par09 == 1 


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³  Monta Relatório Analitico com Data Internação    ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

	_cQuery := "SELECT ZG_NUMERO , ZG_SERIENF, ZG_NFDEVOL ,ZG_NFFMDEV, ZG_NOMECLI ,ZG_ESTCOLE ,ZG_ENDCOLE ,ZG_MUNCOLE ,ZG_CEPCOLE, "
	_cQuery += "Substring(ZG_DESCMOT,1,17) ZG_DESCMOT, ZH_PRODUTO ,ZH_DESCRI ,ZH_QTDDEVO, "
	_cQuery += "cast((ZH_PRECONF * ZH_ALIQIPI) /100 as money) + ZH_PRECONF ValorPrecoUnitComIPI ,ZG_VALOR, "
	_cQuery += "BM_GRUPO ,BM_DESC ,ZB_NOME, "
	_cQuery += "ZG_EMISSAO ,ZG_DTDEVOL ,ZG_DTSOLIC ,ZG_DTCOLE ,ZG_DTENTES ,ZG_DTRECUS ,ZG_DTINTER ,ZG_DTRETOR, "
	_cQuery += "ZG_STATUS, ZG_CGC, ZG_NOMETRP, ZG_NUMOBJ, ZH_ORIGEM, ZG_CFOP, ZG_TIPO, ZG_VLRDESP, ZH_OPALICM, "
	_cQuery += "CASE ZG_TIPO WHEN 'R' THEN 'T'	WHEN 'D' THEN 'D' END AS ZG_TIPO, ZG_X_USUAR,ZG_OBSCOLE "
	_cQuery += "FROM " + RetSQLName("SZG")+" SZG JOIN "+ RetSQLName("SZH")+" SZH "
	_cQuery += "ON ZG_FILIAL = ZH_FILIAL AND ZG_NUMERO = ZH_NUMERO "
	_cQuery += "JOIN " + RetSQLName("SB1")+" SB1 "
	_cQuery += "ON	B1_COD = ZH_PRODUTO "
	_cQuery += "JOIN "+ RetSQLName("SBM")+" SBM "
	_cQuery += "ON B1_GRUPO = BM_GRUPO "
	_cQuery += "JOIN "+ RetSQLName("SA1")+" SA1 "
	_cQuery += "ON A1_COD = ZG_CLIENTE AND A1_LOJA = ZG_LOJACLI "
	_cQuery += "JOIN "+ RetSQLName("SA3")+" SA3 "
	_cQuery += "ON A1_VEND = A3_COD "
	_cQuery += "JOIN "+ RetSQLName("SZB")+" SZB "
	_cQuery += "ON ZB_COD = A3_XEXECUT "
	_cQuery += "WHERE "
	if (mv_par07 == 1)
		_cQuery +=   " SZG.ZG_TIPO = 'R' AND "
		elseif (mv_par07 == 2)
		_cQuery +=   " SZG.ZG_TIPO = 'D' AND "
	endif
	_cQuery += "SZG.ZG_FILIAL  BETWEEN '" + mv_par13 + "' AND '" + mv_par14 + "' AND " 
	_cQuery += "SZG.ZG_EMISSAO BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "' AND " 
	_cQuery += "SZG.ZG_NUMERO  BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' AND " 
	_cQuery += "SZG.ZG_CLIENTE BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' AND "
	_cQuery += "SZG.ZG_DTINTER BETWEEN '" + dtos(mv_par10) + "' AND '" + dtos(mv_par11) + "' AND " 
	_cQuery += "SZG.D_E_L_E_T_ = '' AND SZH.D_E_L_E_T_ = '' AND SB1.D_E_L_E_T_ = '' AND SBM.D_E_L_E_T_ = '' "
	_cQuery += "AND SA1.D_E_L_E_T_ = '' AND SA3.D_E_L_E_T_ = '' AND SZB.D_E_L_E_T_ = '' "		
	_cQuery += "ORDER BY ZG_DTINTER"		


elseif mv_par12 == 2 .and. mv_par09 == 2 


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³  Monta Relatório Sintético Sem Data Internação    ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/


	_cQuery := "SELECT ZG_NUMERO, ZG_SERIENF, ZG_NFDEVOL ,ZG_NFFMDEV ,ZG_NOMECLI ,ZG_ESTCOLE ,ZG_ENDCOLE ,ZG_MUNCOLE ,ZG_CEPCOLE, "
	_cQuery += "Substring(ZG_DESCMOT,1,17) ZG_DESCMOT, Sum (ZH_QTDDEVO) QTDEDEV, "
	_cQuery += "ZG_VALOR VALOR, ZB_NOME, "
	_cQuery += "ZG_EMISSAO ,ZG_DTDEVOL ,ZG_DTSOLIC ,ZG_DTCOLE ,ZG_DTENTES ,ZG_DTRECUS ,ZG_DTINTER ,ZG_DTRETOR, "
	_cQuery += "ZG_STATUS, ZG_CGC, ZG_NOMETRP, ZG_NUMOBJ, ZG_CFOP, ZG_VLRDESP, "
	_cQuery += "CASE ZG_TIPO WHEN 'R' THEN 'T'	WHEN 'D' THEN 'D' END AS ZG_TIPO, ZG_X_USUAR,ZG_OBSCOLE "
   	_cQuery += "FROM " + RetSQLName("SZG")+" SZG JOIN "+ RetSQLName("SZH")+" SZH "
   	_cQuery += "ON ZG_FILIAL = ZH_FILIAL AND ZG_NUMERO = ZH_NUMERO "
	_cQuery += "JOIN " + RetSQLName("SA1")+" SA1 "
	_cQuery += "ON A1_COD = ZG_CLIENTE AND A1_LOJA = ZG_LOJACLI "
	_cQuery += "JOIN "+ RetSQLName("SA3")+" SA3 "
	_cQuery += "ON A1_VEND = A3_COD "
	_cQuery += "JOIN "+ RetSQLName("SZB")+" SZB "
	_cQuery += "ON ZB_COD = A3_XEXECUT "
	_cQuery += "WHERE "
	if (mv_par07 == 1)
		_cQuery +=   " SZG.ZG_TIPO = 'R' AND "
		elseif (mv_par07 == 2)
		_cQuery +=   " SZG.ZG_TIPO = 'D' AND "
	endif
	_cQuery += "SZG.ZG_FILIAL  BETWEEN '" + mv_par13 + "' AND '" + mv_par14 + "' AND " 
	_cQuery += "SZG.ZG_EMISSAO BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "' AND " 
	_cQuery += "SZG.ZG_NUMERO  BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' AND " 
	_cQuery += "SZG.ZG_CLIENTE BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' AND "
//	_cQuery += "SZG.ZG_DTINTER BETWEEN '" + dtos(mv_par10) + "' AND '" + dtos(mv_par11) + "' AND " 
	_cQuery += "SZG.D_E_L_E_T_ = '' AND SZH.D_E_L_E_T_ = '' "
	_cQuery += "AND SA1.D_E_L_E_T_ = '' AND SA3.D_E_L_E_T_ = '' AND SZB.D_E_L_E_T_ = '' "		
	_cQuery += "GROUP BY "
	_cQuery += "ZG_NUMERO, ZG_NFDEVOL, ZG_SERIENF, ZG_NFFMDEV, ZG_NOMECLI, ZG_ESTCOLE, ZG_ENDCOLE, ZG_MUNCOLE, ZG_CEPCOLE, ZG_DESCMOT, "
	_cQuery += "ZB_NOME, ZG_EMISSAO ,ZG_DTDEVOL ,ZG_DTSOLIC ,ZG_DTCOLE ,ZG_DTENTES, "
	_cQuery += "ZG_DTRECUS ,ZG_DTINTER ,ZG_DTRETOR, ZG_STATUS, ZG_CGC, ZG_NOMETRP, ZG_NUMOBJ, ZG_CFOP, "
	_cQuery += "ZG_TIPO, ZG_VLRDESP, ZG_TIPO, ZG_X_USUAR, ZG_VALOR,ZG_OBSCOLE "
	_cQuery += "ORDER BY ZG_NUMERO"	 


elseif mv_par12 == 2 .and. mv_par09 == 1 


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³  Monta Relatório Sintético Com Data Internação    ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

_cQuery := "SELECT ZG_NUMERO, ZG_SERIENF, ZG_NFDEVOL, ZG_NFFMDEV ,ZG_NOMECLI ,ZG_ESTCOLE ,ZG_ENDCOLE ,ZG_MUNCOLE ,ZG_CEPCOLE, "
	_cQuery += "Substring(ZG_DESCMOT,1,17) ZG_DESCMOT, Sum (ZH_QTDDEVO) QTDEDEV, "
	_cQuery += "ZG_VALOR VALOR, ZB_NOME, "
	_cQuery += "ZG_EMISSAO ,ZG_DTDEVOL ,ZG_DTSOLIC ,ZG_DTCOLE ,ZG_DTENTES ,ZG_DTRECUS ,ZG_DTINTER ,ZG_DTRETOR, "
	_cQuery += "ZG_STATUS, ZG_CGC, ZG_NOMETRP, ZG_NUMOBJ, ZG_CFOP, ZG_VLRDESP, "
	_cQuery += "CASE ZG_TIPO WHEN 'R' THEN 'T'	WHEN 'D' THEN 'D' END AS ZG_TIPO, ZG_X_USUAR,ZG_OBSCOLE "
   	_cQuery += "FROM " + RetSQLName("SZG")+" SZG JOIN "+ RetSQLName("SZH")+" SZH "
   	_cQuery += "ON ZG_FILIAL = ZH_FILIAL AND ZG_NUMERO = ZH_NUMERO "
	_cQuery += "JOIN " + RetSQLName("SA1")+" SA1 "
	_cQuery += "ON A1_COD = ZG_CLIENTE AND A1_LOJA = ZG_LOJACLI "
	_cQuery += "JOIN "+ RetSQLName("SA3")+" SA3 "
	_cQuery += "ON A1_VEND = A3_COD "
	_cQuery += "JOIN "+ RetSQLName("SZB")+" SZB "
	_cQuery += "ON ZB_COD = A3_XEXECUT "
	_cQuery += "WHERE "
	if (mv_par07 == 1)
		_cQuery +=   " SZG.ZG_TIPO = 'R' AND "
		elseif (mv_par07 == 2)
		_cQuery +=   " SZG.ZG_TIPO = 'D' AND "
	endif	
	_cQuery += "SZG.ZG_FILIAL  BETWEEN '" + mv_par13 + "' AND '" + mv_par14 + "' AND " 
	_cQuery += "SZG.ZG_EMISSAO BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "' AND " 
	_cQuery += "SZG.ZG_NUMERO  BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' AND " 
	_cQuery += "SZG.ZG_CLIENTE BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' AND "
	_cQuery += "SZG.ZG_DTINTER BETWEEN '" + dtos(mv_par10) + "' AND '" + dtos(mv_par11) + "' AND " 
	_cQuery += "SZG.D_E_L_E_T_ = '' AND SZH.D_E_L_E_T_ = '' "
	_cQuery += "AND SA1.D_E_L_E_T_ = '' AND SA3.D_E_L_E_T_ = '' AND SZB.D_E_L_E_T_ = '' "		
	_cQuery += "GROUP BY "
	_cQuery += "ZG_NUMERO, ZG_NFDEVOL,ZG_SERIENF, ZG_NFFMDEV ,ZG_NOMECLI, ZG_ESTCOLE, ZG_ENDCOLE, ZG_MUNCOLE, ZG_CEPCOLE, ZG_DESCMOT, "
	_cQuery += "ZB_NOME, ZG_EMISSAO ,ZG_DTDEVOL ,ZG_DTSOLIC ,ZG_DTCOLE ,ZG_DTENTES, "
	_cQuery += "ZG_DTRECUS ,ZG_DTINTER ,ZG_DTRETOR, ZG_STATUS, ZG_CGC, ZG_NOMETRP, ZG_NUMOBJ, ZG_CFOP, "
	_cQuery += "ZG_TIPO, ZG_VLRDESP, ZG_TIPO, ZG_X_USUAR, ZG_VALOR,ZG_OBSCOLE "
	_cQuery += "ORDER BY ZG_DTINTER"	 


endif


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
memowrite("SZG_AR.sql",_cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery),"TRB", .F., .T.)
TcSetField("TRB","ZG_EMISSAO","D")
TcSetField("TRB","ZG_DTDEVOL","D")
TcSetField("TRB","ZG_DTSOLIC","D")
TcSetField("TRB","ZG_DTCOLE","D")
TcSetField("TRB","ZG_DTENTES","D")
TcSetField("TRB","ZG_DTRECUS","D")
TcSetField("TRB","ZG_DTINTER","D")
TcSetField("TRB","ZG_DTRETOR","D")

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
	

		
		if lExcel .AND. mv_par12 == 1
		fWrite(nCreate, Titulo + cEol)
		fWrite(nCreate, "Numero AR;" +;
						"Nf Devolucao;" +;
						"Serie;" +;
						"Nf FM Devolucao;" +;
						"Nome Cliente;" +;
						"UF;"			+;
						"Endereco Coleta;" +;
						"Municipio Coleta;" +;
						"Cep Coleta;" +;
						"Tipo;Motivo;" +;
						"Cod. Produto;" +;
						"Descricao do Produto;" +;
						"Quantidade;" +;
						"Valor Unit. C/ IPI;" +;
						"Valor Total;" +;
						"Cod. Grupo;" +;						
						"Desc. Grupo;" +;
						"Executivo;" +;
						"Data Emissao AR;" +;
						"Data Emissao NF;" +;
						"Data Solicitacao;" +; 
						"Data Coleta;" +; 
						"Data Recebimento;" +;						
						"Data Laudo;" +;						
						"Data Internacao;" +;
						"Data Retorno;" +;				                
						"Status;" +;
						"CNPJ;" +;
						"Transportadora;" +;
						"Cod. Postagem;" +;		
						"NF Origem;" +;
						"CFOP;" +; 
						"Natureza;" +;				
						"Valor Despesa;" +;		
						"Aliq. ICMS;" +;  		                                      
						"Incluído por;" +;
						"Obs Coleta"+;		
						cEol)		
	else 
		fWrite(nCreate, Titulo + cEol)
		fWrite(nCreate, "Numero AR;" +;
						"Nf Devolucao;" +;
						"Serie;" +;
						"Nf FM Devolucao;" +;
						"Nome Cliente;" +;
						"UF;"			+;
						"Endereco Coleta;" +;
						"Municipio Coleta;" +;
						"Cep Coleta;" +;
						"DescrMotivo;" +;
						"Quantidade;" +;
						"Valor Total;" +;
						"Executivo;" +;
						"Data Emissao AR;" +;
						"Data Emissao NF;" +;
						"Data Solicitacao;" +; 
						"Data Coleta;" +; 
						"Data Recebimento;" +;						
						"Data Laudo;" +;						
						"Data Internacao;" +;
						"Data Retorno;" +;				                
						"Status;" +;
						"CNPJ;" +;
						"Transportadora;" +;
						"Cod. Postagem;" +;		
						"CFOP;" +; 
						"Valor Despesa;" +;		
						"Tipo;" +;
						"Incluído por;" +;
						"Obs Coleta"+;		
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

   	If mv_par12 == 1 	


		@ nLin,000 PSay ZG_NUMERO
		@ nLin,000 PSay ZG_SERIENF
		@ nLin,008 PSay ZG_NFDEVOL
		@ nLin,019 PSay ZG_NOMECLI
		@ nLin,061 PSay ZG_ESTCOLE
		@ nLin,065 PSay ZG_ENDCOLE
		@ nLin,107 PSay ZG_MUNCOLE
		@ nLin,124 PSay ZG_CEPCOLE
		@ nLin,134 PSay ZG_TIPO
		@ nLin,141 PSay ZG_DESCMOT
		@ nLin,159 PSay ZH_PRODUTO
		@ nLin,171 PSay ZH_DESCRI
		@ nLin,202 PSay ZH_QTDDEVO		
		@ nLin,215 PSay ZG_EMISSAO
		@ nLin,224 PSay ZG_DTSOLIC
		@ nLin,236 PSay ZG_DTCOLE
		@ nLin,245 PSay ZG_DTENTES
		@ nLin,257 PSay ZG_DTRECUS
		@ nLin,266 PSay ZG_DTINTER	
		@ nLin,277 PSay ZG_DTRETOR		
		@ nLin,286 PSay ZG_VALOR	Picture "@E 9,999,999.99"
		@ nLin,321 PSay ZG_CGC
		@ nLin,336 PSay ZG_NOMETRP
		@ nLin,377 PSay ZG_NUMOBJ						
				
		nLin++

	else

		@ nLin,000 PSay ZG_NUMERO
		@ nLin,000 PSay ZG_SERIENF
		@ nLin,008 PSay ZG_NFDEVOL
		@ nLin,019 PSay ZG_NOMECLI
		@ nLin,061 PSay ZG_ESTCOLE
		@ nLin,065 PSay ZG_ENDCOLE
		@ nLin,107 PSay ZG_MUNCOLE
		@ nLin,124 PSay ZG_CEPCOLE
		@ nLin,134 PSay ZG_DESCMOT
		@ nLin,141 PSay QTDEDEV		
		@ nLin,171 PSay VALOR					Picture "@E 9,999,999.99"	  
				
		nLin++

	endif


		//——————————————————————————————————————————————————————————————————————————
		// Gera informações para exportação para o Excel 
		//——————————————————————————————————————————————————————————————————————————
	
	if lExcel
		
		if mv_par12 == 1
		 
			fWrite(nCreate,	"'" + ZG_NUMERO 	 + ";" 	+;
							"'" + ZG_NFDEVOL 	 + ";" 	+;
							"'" + ZG_SERIENF 	 + ";" 	+; 
							"'" + ZG_NFFMDEV 	 + ";" 	+;
							ZG_NOMECLI 			 + ";"	+;
							ZG_ESTCOLE 			 + ";" 	+;
							ZG_ENDCOLE 			 + ";" 	+;
							ZG_MUNCOLE 			 + ";" 	+;
							"'" + ZG_CEPCOLE	 + ";" 	+;
							ZG_TIPO 			 + ";" 	+;
							ZG_DESCMOT 			 + ";" 	+;
                     ZH_PRODUTO 			 + ";" 	+;
                     ZH_DESCRI 			 + ";" 	+;
                    	Transform(ZH_QTDDEVO,"@E 999999.99999" ) + ";"  +;
						   Transform(ValorPrecoUnitComIPI,"@E 9,999,999.99" ) + ";"  +;
						   Transform(ZG_VALOR,"@E 9,999,999.99" ) + ";"  +;
							"'" + BM_GRUPO		 + ";" 	+;
							BM_DESC				 + ";" 	+;
							ZB_NOME 			 + ";" 	+;						
							dtoc(ZG_EMISSAO) 	 + ";"  +;
							dtoc(ZG_DTDEVOL) 	 + ";"  +;
							dtoc(ZG_DTSOLIC) 	 + ";"  +;
							dtoc(ZG_DTCOLE)  	 + ";"  +;
							dtoc(ZG_DTENTES)  	 + ";"  +;
							dtoc(ZG_DTRECUS)  	 + ";"  +;							
							dtoc(ZG_DTINTER) 	 + ";"  +;
							dtoc(ZG_DTRETOR) 	 + ";"  +;
							ZG_STATUS 			 + ";" 	+;
							"'" + ZG_CGC		 + ";"  +;
							ZG_NOMETRP 			 + ";"  +;
							"'" + ZG_NUMOBJ 	 + ";"  +;																												
							"'" + ZH_ORIGEM 	 + ";"  +;																												
                     ZG_CFOP 			 + ";" 	+;
                     ZG_TIPO 			 + ";" 	+;
						   Transform(ZG_VLRDESP,"@E 9,999,999.99" ) + ";"  +;
							Transform(ZH_OPALICM,"@E 9,999,999.99" ) + ";"  +;
   						ZG_X_USUAR 			 + ";" 	+;
   						ZG_OBSCOLE 			 + ";" 	+;
							cEol)
		else               

			fWrite(nCreate,	"'" + ZG_NUMERO 	 + ";" 	+;
							"'" + ZG_NFDEVOL 	 + ";" 	+;
							"'" + ZG_SERIENF 	 + ";" 	+;
							"'" + ZG_NFFMDEV 	 + ";" 	+;
							ZG_NOMECLI 			 + ";"	+;
							ZG_ESTCOLE 			 + ";" 	+;
							ZG_ENDCOLE 			 + ";" 	+;
							ZG_MUNCOLE 			 + ";" 	+;
							"'" + ZG_CEPCOLE	 + ";" 	+;
							ZG_DESCMOT 			 + ";" 	+;
                    	Transform(QTDEDEV,"@E 999999.99999" ) + ";"  +;
						   Transform(VALOR,"@E 9,999,999.99" ) + ";"  +;
							ZB_NOME 			 + ";" 	+;						
							dtoc(ZG_EMISSAO) 	 + ";"  +;
							dtoc(ZG_DTDEVOL) 	 + ";"  +;
							dtoc(ZG_DTSOLIC) 	 + ";"  +;
							dtoc(ZG_DTCOLE)  	 + ";"  +;
							dtoc(ZG_DTENTES)  	 + ";"  +;
							dtoc(ZG_DTRECUS)  	 + ";"  +;							
							dtoc(ZG_DTINTER) 	 + ";"  +;
							dtoc(ZG_DTRETOR) 	 + ";"  +;
							ZG_STATUS 			 + ";" 	+;
							"'" + ZG_CGC		 + ";"  +;
							ZG_NOMETRP 			 + ";"  +;
							"'" + ZG_NUMOBJ 	 + ";"  +;																												
                    	ZG_CFOP 			 + ";" 	+;                     		
						   Transform(ZG_VLRDESP,"@E 9,999,999.99" ) + ";"  +;
							ZG_TIPO 			 + ";" 	+;                     		   						   
   						ZG_X_USUAR 			 + ";" 	+;
   						ZG_OBSCOLE 			 + ";" 	+;
							cEol)
 				
        endif
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