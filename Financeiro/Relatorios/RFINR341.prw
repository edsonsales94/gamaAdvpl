#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "rwmake.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa    ³ RFINR341 ³ Impressão do Boleto de Cobrança em impressora laser com      º±±
±±º             ³          ³ código de barras. (                                          º±±            
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Autor       ³ 18.07.08 ³ TI2238 - Osmil Squarcine                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Produção    ³ 99.99.99 ³ Ignorado                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parâmetros  ³ Nil                                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno     ³ Nil                                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Observações ³                                                                         º±±
±±º             ³                                                                         º±±
±±º             ³                                                                         º±±
±±º             ³                                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Alterações  ³ ESPECIFICO SP VACINAS                                                   º±±
±±º             ³                                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function RFINR341()

Local aRegs		:= {}
Local aTitulos	:= {}
Local cTamanho	:= "M"
Local cDesc1	:= "Este programa tem como objetivo efetuar a impressão do"
Local cDesc2	:= "Boleto de Cobrança com código de barras, conforme os"
Local cDesc3	:= "parâmetros definidos pelo usuário"
Local cString	:= "SE1"
Local cPerg		:= "FINR01XXTX"
Local wnrel		:= "RFINR341"
Private cStatus := 1
Private lEnd	:= .F.
Private nLastKey	:= 0
Private aReturn	:= {	"Banco",;					// [1]= Tipo de Formulário
						1,;							// [2]= Número de Vias
						"Administração",;			// [3]= Destinatário
						2,;							// [4]= Formato 1=Comprimido 2=Normal
						2,;							// [5]= Mídia 1=Disco 2=Impressora
						1,;							// [6]= Porta LPT1, LPT2, Etc
						"",;						// [7]= Expressão do Filtro
						1 ;							// [8]= ordem a ser selecionada
						}   
Private cTitulo	:= "Boleto de Cobrança com Código de Barras"

// Monta array com as perguntas
aAdd(aRegs,{	cPerg,;										// Grupo de perguntas
				"01",;										// Sequencia
				"Prefixo Inicial",;							// Nome da pergunta
				"",;										// Nome da pergunta em espanhol
				"",;										// Nome da pergunta em ingles
				"mv_ch1",;									// Variável
				"C",;										// Tipo do campo
				03,;										// Tamanho do campo
				0,;											// Decimal do campo
				0,;											// Pré-selecionado quando for choice
				"G",;										// Tipo de seleção (Get ou Choice)
				"",;										// Validação do campo
				"MV_PAR01",;								// 1a. Variável disponível no programa
				"",;		  								// 1a. Definição da variável - quando choice
				"",;										// 1a. Definição variável em espanhol - quando choice
				"",;										// 1a. Definição variável em ingles - quando choice
				"",;										// 1o. Conteúdo variável
				"",;										// 2a. Variável disponível no programa
				"",;										// 2a. Definição da variável
				"",;										// 2a. Definição variável em espanhol
				"",;										// 2a. Definição variável em ingles
				"",;										// 2o. Conteúdo variável
				"",;										// 3a. Variável disponível no programa
				"",;										// 3a. Definição da variável
				"",;										// 3a. Definição variável em espanhol
				"",;										// 3a. Definição variável em ingles
				"",;										// 3o. Conteúdo variável
				"",;										// 4a. Variável disponível no programa
				"",;										// 4a. Definição da variável
				"",;										// 4a. Definição variável em espanhol
				"",;										// 4a. Definição variável em ingles
				"",;										// 4o. Conteúdo variável
				"",;										// 5a. Variável disponível no programa
				"",;										// 5a. Definição da variável
				"",;										// 5a. Definição variável em espanhol
				"",;										// 5a. Definição variável em ingles
				"",;										// 5o. Conteúdo variável
				"",;										// F3 para o campo
				"",;										// Identificador do PYME
				"",;										// Grupo do SXG
				"",;										// Help do campo
				"" })										// Picture do campo
aAdd(aRegs,{cPerg,"02","Prefixo Final",			"","","mv_ch2","C",03,0,0,"G","","MV_PAR02","",	"",		"",		"zzz",			"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","","" })
aAdd(aRegs,{cPerg,"03","Numero Inicial", 		"","","mv_ch3","C",10,0,0,"G","","MV_PAR03","",	"",		"",		"",				"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
aAdd(aRegs,{cPerg,"04","Numero Final",			"","","mv_ch4","C",10,0,0,"G","","MV_PAR04","",	"",		"",		"zzzzzz",		"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
aAdd(aRegs,{cPerg,"05","Parcela Inicial",		"","","mv_ch5","C",01,0,0,"G","","MV_PAR05","",	"",		"",		"",				"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
aAdd(aRegs,{cPerg,"06","Parcela Final",			"","","mv_ch6","C",01,0,0,"G","","MV_PAR06","",	"",		"",		"z",			"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
aAdd(aRegs,{cPerg,"07","Tipo Inicial",			"","","mv_ch7","C",03,0,0,"G","","MV_PAR07","",	"",		"",		"",				"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
aAdd(aRegs,{cPerg,"08","Tipo Final",			"","","mv_ch8","C",03,0,0,"G","","MV_PAR08","",	"",		"",		"zzz",			"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
aAdd(aRegs,{cPerg,"09","Cliente Inicial",		"","","mv_ch9","C",06,0,0,"G","","MV_PAR09","",	"",		"",		"",				"","",		"",		"",		"","","","","","","","","","","","","","","","","SA1",	"","","",""})
aAdd(aRegs,{cPerg,"10","Cliente Final",			"","","mv_cha","C",06,0,0,"G","","MV_PAR10","",	"",		"",		"zzzzzz",		"","",		"",		"",		"","","","","","","","","","","","","","","","","SA1",	"","","",""})
aAdd(aRegs,{cPerg,"11","Loja Inicial",			"","","mv_chb","C",02,0,0,"G","","MV_PAR11","",	"",		"",		"",				"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
aAdd(aRegs,{cPerg,"12","Loja Final",			"","","mv_chc","C",02,0,0,"G","","MV_PAR12","",	"",		"",		"zz",			"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
aAdd(aRegs,{cPerg,"13","Emissao Inicial",		"","","mv_chd","D",08,0,0,"G","","MV_PAR13","",	"",		"",		"01/01/05",		"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
aAdd(aRegs,{cPerg,"14","Emissao Final",			"","","mv_che","D",08,0,0,"G","","MV_PAR14","",	"",		"",		"31/12/05",		"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
aAdd(aRegs,{cPerg,"15","Vencimento Inicial",	"","","mv_chf","D",08,0,0,"G","","MV_PAR15","",	"",		"",		"01/01/05",		"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
aAdd(aRegs,{cPerg,"16","Vencimento Final",		"","","mv_chg","D",08,0,0,"G","","MV_PAR16","",	"",		"",		"31/12/05",		"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
aAdd(aRegs,{cPerg,"17","Natureza Inicial",		"","","mv_chh","C",10,0,0,"G","","MV_PAR17","",	"",		"",		"",				"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
aAdd(aRegs,{cPerg,"18","Natureza Final",		"","","mv_chi","C",10,0,0,"G","","MV_PAR18","",	"",		"",		"zzzzzzzzzz",	"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
aAdd(aRegs,{cPerg,"19","Banco Cobranca",		"","","mv_chj","C",03,0,0,"G","","MV_PAR19","",	"",		"",		"",				"","",		"",		"",		"","","","","","","","","","","","","","","","","SA6",	"","","",""})
aAdd(aRegs,{cPerg,"20","Agencia Cobranca",		"","","mv_chk","C",05,0,0,"G","","MV_PAR20","",	"",		"",		"",				"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
aAdd(aRegs,{cPerg,"21","Conta Cobranca",		"","","mv_chl","C",10,0,0,"G","","MV_PAR21","",	"",		"",		"",				"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
aAdd(aRegs,{cPerg,"22","Sub-Conta",				"","","mv_chm","C",03,0,0,"G","","MV_PAR22","",	"",		"",		"001",			"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
aAdd(aRegs,{cPerg,"23","Re-Impressao",			"","","mv_chn","N",01,0,0,"C","","MV_PAR23","Sim",	"Si",	"Yes",	"",				"","Nao",	"No",	"No",	"","","","","","","","","","","","","","","","","",		"","","",""})
aAdd(aRegs,{cPerg,"24","Especio Docto",			"","","mv_cho","C",03,0,0,"G","","MV_PAR24","",	"",		"",		"DM",			"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
aAdd(aRegs,{cPerg,"25","Valor Multa",			"","","mv_chp","C",10,0,0,"G","","MV_PAR25","",	"",		"",		"1,00",			"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
aAdd(aRegs,{cPerg,"26","Juros Mensal",			"","","mv_chq","N",11,2,0,"G","","MV_PAR26","",	"",		"",		"5",			"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
aAdd(aRegs,{cPerg,"27","Dias Protesto",			"","","mv_chr","C",02,0,0,"G","","MV_PAR27","",	"",		"",		"02",			"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
aAdd(aRegs,{cPerg,"28","Mensagem 1",			"","","mv_chs","C",40,0,0,"G","","MV_PAR28","",	"",		"",		"",			"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
aAdd(aRegs,{cPerg,"29","Mensagem 2",			"","","mv_cht","C",40,0,0,"G","","MV_PAR29","",	"",		"",		"",			"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
aAdd(aRegs,{cPerg,"30","Carteira",				"","","mv_chu","C",03,0,0,"G","","MV_PAR30","",	"",		"",		"109",			"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
aAdd(aRegs,{cPerg,"31","Bordero de?",				"","","mv_chv","C",06,0,0,"G","","MV_PAR31","",	"",		"",		"",			"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
aAdd(aRegs,{cPerg,"32","Bordero ate?",				"","","mv_chx","C",06,0,0,"G","","MV_PAR32","",	"",		"",		"",			"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})

CriaSx1(aRegs)

//If 
Pergunte (cPerg,.F.)

	Wnrel := SetPrint(cString,Wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,,,cTamanho,,)

	If nLastKey == 27
		Set Filter to
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
		Set Filter to
		Return
	Endif

	// Seleciona os registros para marcação
	MsgRun( "Títulos a Receber", "Selecionando registros para processamento", { || CallRegs(@aTitulos)} )
	// Monta tela de seleção dos registros que deverão gerar o boleto
	CallTela(@aTitulos)
	
	
//EndIf

Return(Nil)




******************************************************************************************************
Static Function CallRegs(aTitulos)
******************************************************************************************************

Local cQry	:= "SELECT"                


cQry	+= " SE1.E1_PREFIXO,SE1.E1_NUM,SE1.E1_PARCELA,SE1.E1_TIPO,SE1.E1_NATUREZ,SE1.E1_CLIENTE,SE1.E1_LOJA,"
cQry	+= " SE1.E1_NOMCLI,SE1.E1_EMISSAO,SE1.E1_VENCTO,SE1.E1_VENCREA,SE1.E1_VALOR,SE1.E1_HIST,SE1.E1_NUMBCO,"
cQry	+= " R_E_C_N_O_ AS E1_REGSE1"
cQry	+= " FROM "+RetSqlName("SE1")+" SE1 "
cQry	+= " WHERE SE1.E1_FILIAL = '"+xFilial("SE1")+"'"
cQry	+= " AND SE1.E1_PREFIXO BETWEEN '"+mv_par01+"' AND '"+mv_par02+"'"
cQry	+= " AND SE1.E1_NUM BETWEEN '"+mv_par03+"' AND '"+mv_par04+"'"
cQry	+= " AND SE1.E1_PARCELA BETWEEN '"+mv_par05+"' AND '"+mv_par06+"'"
cQry	+= " AND SE1.E1_TIPO BETWEEN '"+mv_par07+"' AND '"+mv_par08+"'"
cQry	+= " AND SE1.E1_CLIENTE BETWEEN '"+mv_par09+"' AND '"+mv_par10+"'"
cQry	+= " AND SE1.E1_LOJA BETWEEN '"+mv_par11+"' AND '"+mv_par12+"'"
cQry	+= " AND SE1.E1_EMISSAO BETWEEN '"+DTOS(mv_par13)+"' AND '"+DTOS(mv_par14)+"'"
cQry	+= " AND SE1.E1_VENCREA BETWEEN '"+DTOS(mv_par15)+"' AND '"+DTOS(mv_par16)+"'"
cQry	+= " AND SE1.E1_NATUREZ BETWEEN '"+mv_par17+"' AND '"+mv_par18+"'"
cQry	+= " AND SE1.E1_NUMBOR BETWEEN '"+MV_PAR31+"' AND '"+MV_PAR32+"'"
cQry	+= " AND SE1.E1_PORTADO = '341 '"
//alteração José Mendes chamdo:9029	26/06/2018
cQry	+= " AND SE1.E1_CONTA = '"+MV_PAR21+"'"
cQry	+= " AND SE1.E1_SALDO > 0"
If mv_par23 == 1
	cQry	+= " AND SE1.E1_NUMBCO <> ' '"
Else
	cQry	+= " AND SE1.E1_NUMBCO = ' '"
EndIf
//alteração José Mendes chamdo:9029	26/06/2018
cQry	+= " AND SE1.E1_TIPO NOT IN('RA','AB','FB','FC','FU','IR','IN','IS','PI','CF','CS','FE','IV')"
cQry	+= " AND SE1.D_E_L_E_T_ <> '*'"
cQry	+= " ORDER BY SE1.E1_CLIENTE,SE1.E1_LOJA,SE1.E1_PREFIXO,SE1.E1_NUM,SE1.E1_PARCELA,SE1.E1_TIPO"


If Select("FINR01A") > 0
	dbSelectArea("FINR01A")
	dbCloseAea()
EndIf

TCQUERY cQry NEW ALIAS "FINR01A"
TCSETFIELD("FINR01A", "E1_EMISSAO",	"D",08,0)
TCSETFIELD("FINR01A", "E1_VENCTO",	"D",08,0)
TCSETFIELD("FINR01A", "E1_VENCREA",	"D",08,0)
TCSETFIELD("FINR01A", "E1_VALOR", 	"N",14,2)
TCSETFIELD("FINR01A", "E1_REGSE1",	"N",10,0)           


dbSelectArea("FINR01A")
While !Eof()
	aAdd(aTitulos, {	.F.,;						// 1=Mark
						FINR01A->E1_PREFIXO,;		// 2=Prefixo do Título
						FINR01A->E1_NUM,;			// 3=Número do Título
						FINR01A->E1_PARCELA,;		// 4=Parcela do Título
						FINR01A->E1_TIPO,;			// 5=Tipo do Título
						FINR01A->E1_NATUREZ,;		// 6=Natureza do Título
						FINR01A->E1_CLIENTE,;		// 7=Cliente do título
						FINR01A->E1_LOJA,;			// 8=Loja do Cliente
						FINR01A->E1_NOMCLI,;		// 9=Nome do Cliente
						FINR01A->E1_EMISSAO,;		//10=Data de Emissão do Título
						FINR01A->E1_VENCTO,;		//11=Data de Vencimento do Título
						FINR01A->E1_VENCREA,;		//12=Data de Vencimento Real do Título
						FINR01A->E1_VALOR,;			//13=Valor do Título
						FINR01A->E1_HIST,;			//14=Histótico do Título
						FINR01A->E1_REGSE1,;		//15=Número do registro no arquivo
						FINR01A->E1_NUMBCO ;		//16=Nosso Número
						})
	dbSkip()
EndDo

If Len(aTitulos) == 0
	aAdd(aTitulos, {.F.,"","","","","","","","","","","",0,"",0,""})
EndIf

dbSelectArea("FINR01A")
dbCloseArea()

Return(Nil)




******************************************************************************************************
Static Function CallTela(aTitulos)
******************************************************************************************************

Local oDlg
Local oList1
Local oMark
Local bCancel   := {|| ARFINR341(oDlg,@lRetorno,aTitulos) }
Local bOk       := {|| BRFINR341(oDlg,@lRetorno,aTitulos) }
Local aAreaAtu	:= GetArea()
Local aLabel	:= {" ","Prefixo","Número","Parcela","Tipo","Natureza","Cliente","Loja","Nome Cliente","Emissão","Vencimento","Venc.Real","Valor","Histórico","Nosso Número"}
Local aBotao    := {}
Local lRetorno	:= .T.
Local lMark		:= .F.
Local cList1


Private oOk			:= LoadBitMap(GetResources(),"LBOK")
Private oNo			:= LoadBitMap(GetResources(),"NADA")


AADD(aBotao, {"S4WB011N" 	, { || U_CRFINR341("SE1",SE1->(aTitulos[oList1:nAt,15]),2)}, "[F12] - Visualiza Título", "Título" })
SetKey(VK_F10,	{|| U_CRFINR341("SE1",SE1->(aTitulos[oLis1:nAt,15]),2)})

// REMOVIDO 16/12/2009 POR LUIZ FERNANDO - GA.MA ITALY
//Aviso(	"Numeração Bancária",;
//		"Não esquecer de verificar o número bancário antes de gerar os boletos.",;
//		{"&Ok"},,;
//		"A T E N Ç Ã O" )

DEFINE MSDIALOG oDlg TITLE cTitulo From 000,000 To 420,940 OF oMainWnd PIXEL
@ 015,005 CHECKBOX oMark VAR lMark PROMPT "Marca Todos" FONT oDlg:oFont PIXEL SIZE 80,09 OF oDlg;
			ON CLICK (aEval(aTitulos, {|x,y| aTitulos[y,1] := lMark}), oList1:Refresh() )
@ 030,003 LISTBOX oList1 VAR cList1 Fields HEADER ;
							aLabel[1],;
							aLabel[2],;
							aLabel[3],;
							aLabel[4],;
							aLabel[5],;
							aLabel[6],;
							aLabel[7],;
							aLabel[8],;
							aLabel[9],;
							aLabel[10],;
							aLabel[11],;
							aLabel[12],;
							aLabel[13],;
							aLabel[14],;
							aLabel[15] ;
							SIZE 463,175  NOSCROLL PIXEL
oList1:SetArray(aTitulos)
oList1:bLine	:= {|| {	If(aTitulos[oList1:nAt,1], oOk, oNo),;
							aTitulos[oList1:nAt,2],;
							aTitulos[oList1:nAt,3],;
							aTitulos[oList1:nAt,4],;
							aTitulos[oList1:nAt,5],;
							aTitulos[oList1:nAt,6],;
							aTitulos[oList1:nAt,7],;
							aTitulos[oList1:nAt,8],;
							aTitulos[oList1:nAt,9],;
							aTitulos[oList1:nAt,10],;
							aTitulos[oList1:nAt,11],;
							aTitulos[oList1:nAt,12],;
							Transform(aTitulos[oList1:nAt,13], "@E 999,999,999.99"),;
							aTitulos[oList1:nAt,14],;
							aTitulos[oList1:nAt,16] ;
							}}

oList1:blDblClick 	:= {|| aTitulos[oList1:nAt,1] := !aTitulos[oList1:nAt,1], oList1:Refresh() }
oList1:cToolTip		:= "Duplo click para marcar/desmarcar o título"
oList1:Refresh()

@ 15,81 BMPBUTTON TYPE 01 ACTION BRFINR341(oDlg,@lRetorno,aTitulos)
@ 15,110 BMPBUTTON TYPE 2 ACTION ARFINR341(oDlg,@lRetorno,aTitulos)
ACTIVATE MSDIALOG oDlg CENTERED //ON INIT EnchoiceBar(oDlg,bOk,bcancel,,aBotao)



SetKey(VK_F12,	Nil)

Return(lRetorno)




******************************************************************************************************
Static Function ARFINR341(oDlg,lRetorno, aTitulos) 
******************************************************************************************************

lRetorno := .F.

oDlg:End() 

Return(lRetorno)                      




******************************************************************************************************
Static Function BRFINR341(oDlg,lRetorno, aTitulos) 
******************************************************************************************************

Local nLoop		:= 0
Local nContador	:= 0

lRetorno := .T.

For nLoop := 1 To Len(aTitulos)
	If aTitulos[nLoop,1]
		nContador++
	EndIf	
Next

If nContador > 0
	RptStatus( {|lEnd| ImpBol(aTitulos) }, cTitulo)

Else
	lRetorno := .F.
EndIf

oDlg:End() 

Return(lRetorno)                      




******************************************************************************************************
User Function CRFINR341(cAlias, nRecAlias, nOpcEsc)
******************************************************************************************************

Local aAreaAtu	:= GetArea()
Local aAreaAux	:= (cAlias)->(GetArea())

If !Empty(nRecAlias)
	dbSelectArea(cAlias)
	dbSetOrder(1)
	dbGoTo(nRecAlias)
	
	AxVisual(cAlias,nRecAlias,nOpcEsc)
EndIf

RestArea(aAreaAux)
RestArea(aAreaAtu)

Return(Nil)




******************************************************************************************************
Static Function ImpBol(aTitulos)
******************************************************************************************************


Local oPrint
Local aEmpresa	:= {	AllTrim(SM0->M0_NOMECOM),;																//[1]Nome da Empresa
						AllTrim(SM0->M0_ENDCOB),;																//[2]Endereço
						AllTrim(SM0->M0_BAIRCOB),;																//[3]Bairro
						AllTrim(SM0->M0_CIDCOB),;																//[4]Cidade
						SM0->M0_ESTCOB,;																		//[5]Estado
						"CEP: "+Transform(SM0->M0_CEPCOB, "@R 99999-999"),;									//[6]CEP
						"PABX/FAX: "+SM0->M0_TEL,;																//[7]Telefones
						"CNPJ: "+Transform(SM0->M0_CGC, "@R 99.999.999/9999-99"),;								//[8]CGC
						"I.E.: "+Transform(SM0->M0_INSC, SuperGetMv("MV_IEMASC",.F.,"@R 999.999.999.999")) ;	//[9]I.E
						}
Local aCB_RN_NN	:= {}
Local aDadTit	:= {}
Local aBanco	:= {}
Local aSacado	:= {}
// No máximo 8 elementos com 80 caracteres para cada linha de mensagem
Local aBolTxt	:= {"","","","","","","",""}
Local aMensag	:= {}
Local nI		:= 1
Local nVlrAbat	:= 0
Local nAcresc	:= 0
Local nDecres	:= 0
Local nSaldo	:= 0
Local nX		:= 0
Local nLoop		:= 0
Local nLoop1	:= 0
Local cNNum		:= " "
Local cQry		:= ""
Local aDadFat	:= {}
Local nCnt		:= 0
Local nLoop2	:= 0

oPrint:= TMSPrinter():New( "Boleto Laser" )
oPrint:SetPortrait()								// ou SetLandscape()
oPrint:StartPage()									// Inicia uma nova página
                                                                        

// Fazer pergunta de Centimetro ou Polegada

// nTipo := Aviso(	"Impressão","Escolha o método de impressão.",{"&Centimetro","&Polegada"},,"A T E N Ç Ã O" )

nTipo := 1  // sempre executa padrao centimetro

SetRegua(Len(aTitulos))

// Faz loop no array com os títulos a serem impressos
For nLoop := 1 To Len(aTitulos)

	IncRegua("Titulo: "+aTitulos[nLoop,02]+"/"+aTitulos[nLoop,03]+"/"+aTitulos[nLoop,04])

	// Se estiver marcado, imprime
	If aTitulos[nLoop,01]

		// Posiciona no Título
		dbSelectArea("SE1")
		dbGoTo(aTitulos[nLoop,15])
		//Posiciona no Cliente
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek(xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA)
		// Posiciona no Banco
		DbSelectArea("SA6")
		DbSetOrder(1)
		If !DbSeek(xFilial("SA6")+mv_par19+mv_par20+mv_par21)
			Aviso(	"Emissão do Boleto",;
					"Banco não localizado no cadastro!",;
					{"&Ok"},,;
					"Banco: "+mv_par19+"/"+mv_par20+"/"+mv_par21 )
			Loop
		EndIf
		//Posiciona na Configuração do Banco
		DbSelectArea("SEE")
		DbSetOrder(1)
		If !DbSeek(xFilial("SEE")+mv_par19+mv_par20+mv_par21+mv_par22)
			Aviso(	"Emissão do Boleto",;
					"Configuração dos parâmetros do banco não localizado no cadastro!",;
					{"&Ok"},,;
					"Banco: "+mv_par19+"/"+mv_par20+"/"+mv_par21+"/"+mv_par22 )
			Loop
		EndIf
		DbSelectArea("SE1")
		aBanco  := {	SA6->A6_COD,;	   												// [1]Numero do Banco
						SA6->A6_NREDUZ,;												// [2]Nome do Banco
						SubStr(SA6->A6_AGENCIA, 1, 4),;								// [3]Agência
						SubStr(SA6->A6_NUMCON,1,At("-",SA6->A6_NUMCON)-1),;			// [4]Conta Corrente
						SubStr(SA6->A6_NUMCON,At("-",SA6->A6_NUMCON)+1,1),;			// [5]Dígito da conta corrente
						MV_PAR30,;						 						// [6]Codigo da Carteira
						"7" }															// [7]Dígito do Banco

		If Empty(SA1->A1_ENDCOB)
			aSacado   := {	AllTrim(SA1->A1_NOME),;										// [1]Razão Social
							AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA,;		    	  	// [2]Código
							AllTrim(SA1->A1_END )+" - "+AllTrim(SA1->A1_BAIRRO),;		// [3]Endereço
							AllTrim(SA1->A1_MUN ),;										// [4]Cidade
							SA1->A1_EST,;												// [5]Estado
							SA1->A1_CEP,;												// [6]CEP
							SA1->A1_CGC,;												// [7]CGC
							SA1->A1_PESSOA }											// [8]PESSOA

		Else
			aSacado   := {	AllTrim(SA1->A1_NOME),;										// [1]Razão Social
							AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA,;					// [2]Código
							AllTrim(SA1->A1_ENDCOB)+" - "+AllTrim(SA1->A1_BAIRROC),;	// [3]Endereço
							AllTrim(SA1->A1_MUNC),;										// [4]Cidade
							SA1->A1_ESTC,;												// [5]Estado
							SA1->A1_CEPC,;												// [6]CEP
							SA1->A1_CGC,;												// [7]CGC
							SA1->A1_PESSOA }											// [8]PESSOA
		Endif

		// Define o valor do título considerando Acréscimos e Decrescimos
		nSaldo	:= U_SlRece(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_CLIENTE,SE1->E1_LOJA)[1]

		// Define o Nosso Número
		If !Empty(SE1->E1_NUMBCO)
			cNNum	:= AllTrim(SE1->E1_NUMBCO)
		Else
			dbSelectArea("SEE")
			RecLock("SEE",.F.)
				cNNum			:= AllTrim(SEE->EE_FAXATU)
				SEE->EE_FAXATU	:= Soma1(Alltrim(SEE->EE_FAXATU),8)    
			MsUnLock()
		EndIf
		dbSelectArea("SE1")
	
		//Monta codigo de barras
		aCB_RN_NN := Ret_cBarra(	Subs(aBanco[1],1,3)+"9",;			// [1]-Banco+Fixo 9
									aBanco[3],;							// [2]-Agencia
									aBanco[4],;							// [3]-Conta
									aBanco[5],;							// [4]-Digito Conta
									aBanco[6],;							// [5]-Carteira
									cNNum,;								// [6]-Nosso Número
									nSaldo,;								// [7]-Valor do Título
									SE1->E1_VENCREA )					// [8]-Vencimento

		dbSelectArea("SE1")

		aDadTit	:= {	AllTrim(E1_NUM)+AllTrim(E1_PARCELA)+Alltrim(E1_TIPO),;			// [1] Número do título
						E1_EMISSAO,;									// [2] Data da emissão do título
						dDataBase,;										// [3] Data da emissão do boleto
						E1_VENCREA,;									// [4] Data do vencimento
						nSaldo,;											// [5] Valor do título
						aCB_RN_NN[3],;									// [6] Nosso número (Ver fórmula para calculo)
						E1_PREFIXO,;									// [7] Prefixo da NF
						mv_par24,; 										// [8] Tipo do Titulo
						""}												// [9] HISTORICO DO TITULO


		aBolTxt	:= {"","","","","","","",""}                      
		
		If !Empty(Alltrim(MV_PAR27))
			aBolTxt[1] := "TITULO SUJEITO A PROTESTO APÓS "+Alltrim(StrZero(val(MV_PAR27),2))+" DIAS DE VENCIMENTO "
		EndIf	

		If !Empty(Alltrim(MV_PAR25))
			aBolTxt[2] := "APÓS O VENCIMENTO MULTA DE "+Alltrim( Transform(MV_PAR25 ,  "@E 999.99" )) +" %."
		EndIf	

		If MV_PAR26 <> 0
			aBolTxt[3] := "APÓS VENCIMENTO MORA DIA "+Alltrim( Transform(MV_PAR26/30 , "@E 999.99")) +" %."
		EndIf	
		
				
		If !Empty(Alltrim(MV_PAR28))
			aBolTxt[4] := MV_PAR28
		EndIf	
	   
	 //Verifica se banco e itau para colocar instruções no boleto
		IF MV_PAR21 = "39637-3" 
		 	aBolTxt[4] := " Crédito Cedido Fiduciariamente "
		end if
		
		//Verifica se banco e itau para colocar instruções no boleto
		IF MV_PAR21 = "39636-5" 
		 	aBolTxt[4] := " Crédito Cedido Fiduciariamente "
		end if
		   
			//Verifica se banco e itau para colocar instruções no boleto
		IF MV_PAR21 = "39635-7" 
		 	aBolTxt[4] := " Crédito Cedido Fiduciariamente "
		end if
		
			
			If !Empty(Alltrim(MV_PAR29))
			aBolTxt[5]:= MV_PAR29
		EndIf	

		// Sempre Incremento a mensagem de não receber após vencimento
		aBolTxt[8]	:= "SR. CAIXA, NÃO RECEBER APÓS O VENCIMENTO"

		// Chama rotina de impressão	                      
		Impress(oPrint,aEmpresa,aDadTit,aBanco,aSacado,aBolTxt,aCB_RN_NN,cNNum)

	
	EndIf
Next nLoop

oPrint:EndPage()     // Finaliza a página
oPrint:Preview()     // Visualiza antes de imprimir

Return(Nil)




******************************************************************************************************
Static Function Impress(oPrint,aEmpresa,aDadTit,aBanco,aSacado,aBolTxt,aCB_RN_NN,cNNum)
******************************************************************************************************

LOCAL oFont8
LOCAL oFont11c
LOCAL oFont10
LOCAL oFont14
LOCAL oFont16
LOCAL oFont15
LOCAL oFont12
LOCAL oFont14n
LOCAL oFont24
LOCAL nI := 0
Local cStartPath	:= GetSrvProfString("StartPath","")
Local cBmp			:= ""

cStartPath	:= AllTrim(cStartPath)
If SubStr(cStartPath,Len(cStartPath),1) <> "\"
	cStartPath	+= "\"
EndIf
cBmp	:= cStartPath+"itau.bmp"

//Parametros de TFont.New()
//1.Nome da Fonte (Windows)
//3.Tamanho em Pixels
//5.Bold (T/F)
oFont8		:= TFont():New("Arial",			9,08,.T.,.F.,5,.T.,5,.T.,.F.)
oFont10		:= TFont():New("Arial",			9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont11c		:= TFont():New("Courier New",	9,11,.T.,.T.,5,.T.,5,.T.,.F.)
oFont12		:= TFont():New("Arial",			9,12,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14		:= TFont():New("Arial",			9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14n		:= TFont():New("Arial",			9,14,.T.,.F.,5,.T.,5,.T.,.F.)
oFont15		:= TFont():New("Arial",			9,15,.T.,.T.,5,.T.,5,.T.,.F.)
oFont15n		:= TFont():New("Arial",			9,15,.T.,.F.,5,.T.,5,.T.,.F.)
oFont16		:= TFont():New("Arial",			9,16,.T.,.T.,5,.T.,5,.T.,.F.)
oFont20		:= TFont():New("Arial",			9,20,.T.,.T.,5,.T.,5,.T.,.F.)
oFont21		:= TFont():New("Arial",			9,21,.T.,.T.,5,.T.,5,.T.,.F.)
oFont24		:= TFont():New("Arial",			9,24,.T.,.T.,5,.T.,5,.T.,.F.)

oPrint:StartPage()   // Inicia uma nova página

//------------------------------------------------------------------------------------------------------------//
// Primeiro Bloco - Recibo de Entrega                                                                         //
//------------------------------------------------------------------------------------------------------------//
nRow1 := 0
 
oPrint:Line	(nRow1+0150,500,nRow1+0070, 500)													// Quadro
oPrint:Line	(nRow1+0150,710,nRow1+0070, 710)													// Quadro

//oPrint:Say	(nRow1+0084,100,aBanco[2],												oFont14)	// Nome do Banco



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³O Tamanho da Figura tem que ser 381 X 68 Pixel para imprimir corretamente no boleto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄì

//oPrint:SayBitMap(nRow1+0040,100,cBmp)// antes estava em 74
//oPrint:SayBitMap(0084,100,cBmp,0284,050)		// Logo da Empresa													// Nome do Banco

oPrint:Say	(nRow1+0075,100,Upper(aBanco[2]),										oFont12)
oPrint:Say	(nRow1+0075,520,aBanco[1]+"-"+aBanco[7],								oFont16)	// Número do Banco + Dígito

oPrint:Say	(nRow1+0084,1900,"Comprovante de Entrega",								oFont10)	// Texto Fixo
oPrint:Line	(nRow1+0150,100,nRow1+0150,2300)													// Quadro

oPrint:Say  (nRow1+0150,100 ,"Beneficiario",												oFont8)		// Texto Fixo
oPrint:Say  (nRow1+0200,100 ,Substr(strTran(strTran(aEmpresa[1],"INDUSTRIA","IND."),"COMERCIO","COM."),1,44),	oFont10)	// Nome da Empresa

oPrint:Say  (nRow1+0150,1060,"Agência/Código Beneficiario",								oFont8)		// Texto Fixo
oPrint:Say  (nRow1+0200,1060,aBanco[3]+"/"+aBanco[4]+"-"+aBanco[5],					oFont10)	// Agencia + Cód.Cedente + Dígito

oPrint:Say  (nRow1+0150,1510,"Nro.Documento",										oFont8)		// Texto fixo
oPrint:Say  (nRow1+0200,1510,aDadTit[7]+StrTran(aDadTit[1],alltrim(SE1->E1_TIPO),""),	oFont10)	// Prefixo + Numero + Parcela

oPrint:Say  (nRow1+0250,100 ,"Pagador",												oFont8)		// Texto Fixo
oPrint:Say  (nRow1+0300,100 ,aSacado[1],											oFont10)	// Nome do Cliente

oPrint:Say  (nRow1+0250,1060,"Vencimento",											oFont8)		// Texto Fixo
oPrint:Say  (nRow1+0300,1060,StrZero(Day(aDadTit[4]),2) +;
							"/"+ StrZero(Month(aDadTit[4]),2) +;
							"/"+ Right(Str(Year(aDadTit[4])),4),					oFont10)	// Data de Vencimento

oPrint:Say  (nRow1+0250,1510,"Valor do Documento",									oFont8)		// Texto Fixo
oPrint:Say  (nRow1+0300,1550,AllTrim(Transform(aDadTit[5],"@E 999,999,999.99")),	oFont10)		// Valor do Título

oPrint:Say  (nRow1+0400,0100,"Recebi(emos) o bloqueto/título",						oFont10)	// Texto Fixo
oPrint:Say  (nRow1+0450,0100,"com as características acima.",						oFont10)	// Texto Fixo
oPrint:Say  (nRow1+0350,1060,"Data",												oFont8)		// Texto Fixo
oPrint:Say  (nRow1+0350,1410,"Assinatura",											oFont8)		// Texto Fixo
oPrint:Say  (nRow1+0450,1060,"Data",												oFont8)		// Texto Fixo
oPrint:Say  (nRow1+0450,1410,"Entregador",											oFont8)		// Texto Fixo

oPrint:Line (nRow1+0250, 100,nRow1+0250,1900 )													// Quadro
oPrint:Line (nRow1+0350, 100,nRow1+0350,1900 )													// Quadro
oPrint:Line (nRow1+0450,1050,nRow1+0450,1900 )													// Quadro
oPrint:Line (nRow1+0550, 100,nRow1+0550,2300 )													// Quadro

oPrint:Line (nRow1+0550,1050,nRow1+0150,1050 )													// Quadro
oPrint:Line (nRow1+0550,1400,nRow1+0350,1400 )													// Quadro
oPrint:Line (nRow1+0350,1500,nRow1+0150,1500 )													// Quadro
oPrint:Line (nRow1+0550,1900,nRow1+0150,1900 )													// Quadro

oPrint:Say  (nRow1+0165,1910," (  )  Mudou-se",										oFont8)		// Texto Fixo
oPrint:Say  (nRow1+0205,1910," (  )  Ausente",										oFont8)		// Texto Fixo
oPrint:Say  (nRow1+0245,1910," (  )  Não existe nº indicado",						oFont8)		// Texto Fixo
oPrint:Say  (nRow1+0285,1910," (  )  Recusado",			 							oFont8)		// Texto Fixo
oPrint:Say  (nRow1+0325,1910," (  )  Não procurado",		 						oFont8)		// Texto Fixo
oPrint:Say  (nRow1+0365,1910," (  )  Endereço insuficiente",						oFont8)		// Texto Fixo
oPrint:Say  (nRow1+0405,1910," (  )  Desconhecido",		 							oFont8)		// Texto Fixo
oPrint:Say  (nRow1+0445,1910," (  )  Falecido",										oFont8)		// Texto Fixo
oPrint:Say  (nRow1+0485,1910," (  )  Outros(anotar no verso)",						oFont8)		// Texto Fixo

//--------------------------------------------------------------------------------------------------------------//           
// Segundo Bloco - Recibo do Sacado                                                                             //
//--------------------------------------------------------------------------------------------------------------//
nRow2 := 0

//Pontilhado separador
For nI := 100 to 2300 step 50
	oPrint:Line(nRow2+0580, nI,nRow2+0580, nI+30)												// Linha pontilhada
Next nI

oPrint:Line (nRow2+0710,100,nRow2+0710,2300)													// Quadro
oPrint:Line (nRow2+0710,500,nRow2+0630, 500)													// Quadro
oPrint:Line (nRow2+0710,710,nRow2+0630, 710)													// Quadro

//oPrint:Say  (nRow2+0644,100,aBanco[2],												oFont14)	// Nome do Banco
//oPrint:SayBitMap(nRow1+0600,100,cBmp)													// Nome do Banco
oPrint:Say  (nRow2+0635,100,Upper(aBanco[2]),										oFont12)
oPrint:Say  (nRow2+0635,520,aBanco[1]+"-"+aBanco[7],								oFont16)	// Numero do Banco + Dígito
oPrint:Say  (nRow2+0644,1800,"Recibo do Pagador",									oFont10)	// Texto Fixo

oPrint:Line (nRow2+0810,100,nRow2+0810,2300)													// Quadro
oPrint:Line (nRow2+0910,100,nRow2+0910,2300)													// Quadro
oPrint:Line (nRow2+0980,100,nRow2+0980,2300)													// Quadro
oPrint:Line (nRow2+1050,100,nRow2+1050,2300)													// Quadro

oPrint:Line (nRow2+0910,500,nRow2+1050,500)													// Quadro
oPrint:Line (nRow2+0980,750,nRow2+1050,750)													// Quadro
oPrint:Line (nRow2+0910,1000,nRow2+1050,1000)													// Quadro
oPrint:Line (nRow2+0910,1300,nRow2+0980,1300)													// Quadro
oPrint:Line (nRow2+0910,1480,nRow2+1050,1480)													// Quadro

oPrint:Say  (nRow2+0710,100 ,"Local de Pagamento",											oFont8)		// Texto Fixo
oPrint:Say  (nRow2+0725,400 ,"ATÉ O VENCIMENTO, PREFERENCIALMENTE NO "+Upper(aBanco[2]) , 	oFont10)	// 1a. Linha de Local Pagamento
oPrint:Say  (nRow2+0765,400 ,"APÓS O VENCIMENTO, SOMENTE NO "+Upper(aBanco[2]),				oFont10)	// 2a. Linha de Local Pagamento

oPrint:Say  (nRow2+0710,1810,"Vencimento",													oFont8)		// Texto Fixo
cString	:= StrZero(Day(aDadTit[4]),2) +"/"+ StrZero(Month(aDadTit[4]),2) +"/"+ Right(Str(Year(aDadTit[4])),4)
nCol := 1910+(374-(len(cString)*22))
oPrint:Say  (nRow2+0750,nCol,cString,												oFont11c)	// Vencimento

oPrint:Say  (nRow2+0810,100 ,"Beneficiario",												oFont8)		// Texto Fixo
oPrint:Say  (nRow2+0850,100 ,strTran(strTran(aEmpresa[1],"INDUSTRIA","IND."),"COMERCIO","COM.")+" - "+aEmpresa[8],							oFont10)	// Nome + CNPJ

oPrint:Say  (nRow2+0810,1810,"Agência/Código Beneficiario",								oFont8)		// Texto Fixo
cString := Alltrim(aBanco[3]+"/"+aBanco[4]+"-"+aBanco[5])
nCol := 1910+(374-(len(cString)*22))
oPrint:Say  (nRow2+0850,nCol,cString,												oFont11c)	// Agência + Código Cedente

oPrint:Say  (nRow2+0910,100, "Data do Documento",									oFont8)		// Texto Fixo
oPrint:Say  (nRow2+0940,100, StrZero(Day(aDadTit[2]),2) +;
							"/"+ StrZero(Month(aDadTit[2]),2) +;
							"/"+ Right(Str(Year(aDadTit[2])),4),					oFont10)	// Data do Documento

oPrint:Say  (nRow2+0910,505 ,"Nro.Documento",										oFont8)		// Texto Fixo
oPrint:Say  (nRow1+0940,505,aDadTit[7]+StrTran(aDadTit[1],alltrim(SE1->E1_TIPO),""),	oFont10)	// Prefixo + Numero + Parcela

oPrint:Say  (nRow2+0910,1005,"Espécie Doc.",										oFont8)		// Texto Fixo
oPrint:Say  (nRow2+0940,1050,aDadTit[8],											oFont10)	// Tipo do Titulo

oPrint:Say  (nRow2+0910,1305,"Aceite",												oFont8)		// Texto Fixo
oPrint:Say  (nRow2+0940,1400,"N",													oFont10)	// Texto Fixo

oPrint:Say  (nRow2+0910,1485,"Data do Processamento",								oFont8)		// Texto Fixo
oPrint:Say  (nRow2+0940,1550,StrZero(Day(aDadTit[3]),2) +;
							"/"+ StrZero(Month(aDadTit[3]),2) +;
							"/"+ Right(Str(Year(aDadTit[3])),4),					oFont10)	// Data impressao

oPrint:Say  (nRow2+0910,1810,"Nosso Número",										oFont8)		// Texto Fixo
cString := Alltrim(Substr(aDadTit[6],1,3)+"/"+Substr(aDadTit[6],4))
nCol := 1910+(374-(len(cString)*22))
oPrint:Say  (nRow2+0940,nCol,cString,												oFont11c)	// Nosso Número

oPrint:Say  (nRow2+0980,100 ,"Uso do Banco",										oFont8)		// Texto Fixo

oPrint:Say  (nRow2+0980,505 ,"Carteira",											oFont8)		// Texto Fixo
oPrint:Say  (nRow2+1010,555 ,aBanco[6],												oFont10)	// Carteira

oPrint:Say  (nRow2+0980,755 ,"Espécie",												oFont8)		// Texto Fixo
oPrint:Say  (nRow2+1010,805 ,"R$",													oFont10)	// Texto Fixo

oPrint:Say  (nRow2+0980,1005,"Quantidade",											oFont8)		// Texto Fixo
oPrint:Say  (nRow2+0980,1485,"Valor",												oFont8)		// Texto Fixo

oPrint:Say  (nRow2+0980,1810,"Valor do Documento",									oFont8)		// Texto Fixo
cString := Alltrim(Transform(aDadTit[5],"@E 99,999,999.99"))
nCol := 1910+(374-(len(cString)*22))
oPrint:Say  (nRow2+1010,nCol,cString,												oFont11c)	// Valor do Título

oPrint:Say  (nRow2+1050,0100,"Instruções (Todas informações são de exclusiva responsabilidade do beneficiario)",;
																					oFont8)		// Texto Fixo
If Empty(aDadTit[9])
	If Len(aBolTxt) > 0
		oPrint:Say  (nRow2+1080,0100,aBolTxt[1],											oFont10)	// 1a Linha Instrução
		oPrint:Say  (nRow2+1120,0100,aBolTxt[2],											oFont10)	// 2a. Linha Instrução
		oPrint:Say  (nRow2+1160,0100,aBolTxt[3],											oFont10)	// 3a. Linha Instrução
		oPrint:Say  (nRow2+1200,0100,aBolTxt[4],											oFont10)	// 4a Linha Instrução
		oPrint:Say  (nRow2+1240,0100,aBolTxt[5],											oFont10)	// 5a. Linha Instrução
		oPrint:Say  (nRow2+1280,0100,aBolTxt[6],											oFont10)	// 6a. Linha Instrução
		oPrint:Say  (nRow2+1320,0100,aBolTxt[7],											oFont10)	// 7a. Linha Instrução
		oPrint:Say  (nRow2+1360,0100,aBolTxt[8],											oFont10)	// 8a. Linha Instrução
	EndIf
Else

	oPrint:Say  (nRow2+1080,0100,aDadTit[9],											oFont10)	// 1a Linha Instrução
	oPrint:Say  (nRow2+1360,0100,aBolTxt[8],											oFont10)	// 8a. Linha Instrução
EndIf

oPrint:Say  (nRow2+1050,1810,"(-)Desconto/Abatimento",								oFont8)		// Texto Fixo
oPrint:Say  (nRow2+1120,1810,"(-)Outras Deduções",									oFont8)		// Texto Fixo
oPrint:Say  (nRow2+1190,1810,"(+)Mora/Multa",										oFont8)		// Texto Fixo
oPrint:Say  (nRow2+1260,1810,"(+)Outros Acréscimos",								oFont8)		// Texto Fixo
oPrint:Say  (nRow2+1330,1810,"(=)Valor Cobrado",									oFont8)		// Texto Fixo

oPrint:Say  (nRow2+1400,0100,"Pagador",												oFont8)		// Texto Fixo
oPrint:Say  (nRow2+1430,0250,"("+aSacado[2]+") "+aSacado[1],						oFont10)	// Nome do Cliente + Código
If aSacado[8] = "J"
	oPrint:Say  (nRow2+1430,1850 ,"CNPJ: "+TRANSFORM(aSacado[7],"@R 99.999.999/9999-99"),;
																					oFont10)	// CGC
Else
	oPrint:Say  (nRow2+1430,1850 ,"CPF: "+TRANSFORM(aSacado[7],"@R 999.999.999-99"),;
																					oFont10)	// CPF
EndIf

oPrint:Say  (nRow2+1470,0250,aSacado[3],											oFont10)	// Endereço
oPrint:Say  (nRow2+1510,0250,Transform(aSacado[6],"@R 99999-999")+" - "+ ;
										aSacado[4]+" - "+ ;
										aSacado[5],									oFont10)	// CEP + Cidade + Estado

oPrint:Say  (nRow2+1510,1850,Substr(aDadTit[6],1,3)+Substr(aDadTit[6],4),			oFont10)	// Carteira + Nosso Número

oPrint:Say  (nRow2+1605,0100,"Pagador/Avalista",									oFont8)		// Texto Fixo
oPrint:Say  (nRow2+1605,1850,"Código de Baixa",										oFont8)		// Texto Fixo

oPrint:Say  (nRow2+1645,1500,"Autenticação Mecânica",								oFont8)		// Texto Fixo

oPrint:Line (nRow2+0710,1800,nRow2+1400,1800)													// Quadro
oPrint:Line (nRow2+1120,1800,nRow2+1120,2300)													// Quadro
oPrint:Line (nRow2+1190,1800,nRow2+1190,2300)													// Quadro
oPrint:Line (nRow2+1260,1800,nRow2+1260,2300)													// Quadro
oPrint:Line (nRow2+1330,1800,nRow2+1330,2300)													// Quadro
oPrint:Line (nRow2+1400,0100,nRow2+1400,2300)													// Quadro
oPrint:Line (nRow2+1640,0100,nRow2+1640,2300)													// Quadro

//--------------------------------------------------------------------------------------------------------------//
// Terceiro Bloco - Ficha de Compensação                                                                        //
//--------------------------------------------------------------------------------------------------------------//
nRow3 := 0

For nI := 100 to 2300 step 50
	oPrint:Line(nRow3+1880, nI, nRow3+1880, nI+30)												// Linha Pontilhada
Next nI

oPrint:Line (nRow3+2000,100,nRow3+2000,2300)													// Quadro
oPrint:Line (nRow3+2000,500,nRow3+1920, 500)													// Quadro
oPrint:Line (nRow3+2000,710,nRow3+1920, 710)													// Quadro

//oPrint:Say  (nRow3+1934,100,aBanco[2],												oFont14)	// Nome do Banco
//oPrint:SayBitMap(nRow1+1890,100,cBmp)													// Nome do Banco
oPrint:Say  (nRow2+1925,100,Upper(aBanco[2]),							   			oFont12)
oPrint:Say  (nRow3+1925,520,aBanco[1]+"-"+aBanco[7],								oFont16)	// Numero do Banco + Dígito
oPrint:Say  (nRow3+1934,755,aCB_RN_NN[2],											oFont15n)	// Linha Digitavel do Codigo de Barras

oPrint:Line (nRow3+2100,100,nRow3+2100,2300 )													// Quadro
oPrint:Line (nRow3+2200,100,nRow3+2200,2300 )													// Quadro
oPrint:Line (nRow3+2270,100,nRow3+2270,2300 )													// Quadro
oPrint:Line (nRow3+2340,100,nRow3+2340,2300 )													// Quadro

oPrint:Line (nRow3+2200,500 ,nRow3+2340,500 )													// Quadro
oPrint:Line (nRow3+2270,750 ,nRow3+2340,750 )													// Quadro
oPrint:Line (nRow3+2200,1000,nRow3+2340,1000)													// Quadro
oPrint:Line (nRow3+2200,1300,nRow3+2270,1300)													// Quadro
oPrint:Line (nRow3+2200,1480,nRow3+2340,1480)													// Quadro

oPrint:Say  (nRow3+2000,100 ,"Local de Pagamento",									oFont8)		// Texto Fixo
oPrint:Say  (nRow3+2015,400 ,"ATÉ O VENCIMENTO, PREFERENCIALMENTE NO "+aBanco[2],	oFont10)	// Texto Fixo
oPrint:Say  (nRow3+2055,400 ,"APÓS O VENCIMENTO, SOMENTE NO "+aBanco[2],			oFont10)	// Texto Fixo
           
oPrint:Say  (nRow3+2000,1810,"Vencimento",											oFont8)		// Texto Fixo
cString := StrZero(Day(aDadTit[4]),2) +"/"+ StrZero(Month(aDadTit[4]),2) +"/"+ Right(Str(Year(aDadTit[4])),4)
nCol	:= 1910+(374-(len(cString)*22))
oPrint:Say  (nRow3+2040,nCol,cString,												oFont11c)	// Vencimento

oPrint:Say  (nRow3+2100,100 ,"Beneficiario",												oFont8)		// Texto Fixo
oPrint:Say  (nRow3+2140,100 ,strTran(strTran(aEmpresa[1],"INDUSTRIA","IND."),"COMERCIO","COM.")+" - "+aEmpresa[8]	,						oFont10)	// Nome + CNPJ

oPrint:Say  (nRow3+2100,1810,"Agência/Código Beneficiario",								oFont8)		// Texto Fixo
cString := Alltrim(aBanco[3]+"/"+aBanco[4]+"-"+aBanco[5])
nCol	:= 1910+(374-(len(cString)*22))
oPrint:Say  (nRow3+2140,nCol,cString,												oFont11c)	// Agência + Cod. Cedente


oPrint:Say  (nRow3+2200,100 ,"Data do Documento",									oFont8)		// Texto Fixo
oPrint:Say (nRow3+2230,100, StrZero(Day(aDadTit[2]),2) +;
							"/"+ StrZero(Month(aDadTit[2]),2) +;
							"/"+ Right(Str(Year(aDadTit[2])),4),					oFont10)	// Vencimento

oPrint:Say  (nRow3+2200,505 ,"Nro.Documento",										oFont8)		// Texto Fixo
oPrint:Say  (nRow1+2230,505,aDadTit[7]+StrTran(aDadTit[1],alltrim(SE1->E1_TIPO),""),	oFont10)	// Prefixo + Numero + Parcela

oPrint:Say  (nRow3+2200,1005,"Espécie Doc.",										oFont8)		// Texto Fixo
oPrint:Say  (nRow3+2230,1050,aDadTit[8],											oFont10)	//Tipo do Titulo

oPrint:Say  (nRow3+2200,1305,"Aceite",												oFont8)		// Texto Fixo
oPrint:Say  (nRow3+2230,1400,"N",													oFont10)	// Texto Fixo

oPrint:Say  (nRow3+2200,1485,"Data do Processamento",								oFont8)		// Texto Fixo
oPrint:Say  (nRow3+2230,1550,StrZero(Day(aDadTit[3]),2) +;
							"/"+ StrZero(Month(aDadTit[3]),2) +;
							"/"+ Right(Str(Year(aDadTit[3])),4),					oFont10)	// Data impressao


oPrint:Say  (nRow3+2200,1810,"Nosso Número",										oFont8)		// Texto Fixo
cString := Alltrim(Substr(aDadTit[6],1,3)+"/"+Substr(aDadTit[6],4))
nCol	:= 1910+(374-(len(cString)*22))
oPrint:Say  (nRow3+2230,nCol,cString,												oFont11c)	// Nosso Número

oPrint:Say  (nRow3+2270,100 ,"Uso do Banco",										oFont8)		// Texto Fixo

oPrint:Say  (nRow3+2270,505 ,"Carteira",											oFont8)		// Texto Fixo
oPrint:Say  (nRow3+2300,555 ,aBanco[6],											oFont10)

oPrint:Say  (nRow3+2270,755 ,"Espécie",												oFont8)		// Texto Fixo
oPrint:Say  (nRow3+2300,805 ,"R$",													oFont10)	// Texto Fixo

oPrint:Say  (nRow3+2270,1005,"Quantidade",											oFont8)		// Texto Fixo
oPrint:Say  (nRow3+2270,1485,"Valor",												oFont8)		// Texto Fixo

oPrint:Say  (nRow3+2270,1810,"Valor do Documento",									oFont8)		// Texto Fixo
cString := Alltrim(Transform(aDadTit[5],"@E 99,999,999.99"))
nCol	:= 1910+(374-(len(cString)*22))
oPrint:Say  (nRow3+2300,nCol,cString,												oFont11c)	// Valor do Documento

oPrint:Say  (nRow3+2340,0100,"Instruções (Todas informações são de exclusiva responsabilidade do beneficiario)",;
																					oFont8)		// Texto Fixo
If Empty(aDadTit[9])
	If Len(aBolTxt) > 0
		oPrint:Say  (nRow3+2370,0100,aBolTxt[1],											oFont10)	// 1a Linha Instrução
		oPrint:Say  (nRow3+2410,0100,aBolTxt[2],											oFont10)	// 2a. Linha Instrução
		oPrint:Say  (nRow3+2450,0100,aBolTxt[3],											oFont10)	// 3a. Linha Instrução
		oPrint:Say  (nRow3+2490,0100,aBolTxt[4],											oFont10)	// 4a Linha Instrução
		oPrint:Say  (nRow3+2530,0100,aBolTxt[5],											oFont10)	// 5a. Linha Instrução
		oPrint:Say  (nRow3+2570,0100,aBolTxt[6],											oFont10)	// 6a. Linha Instrução
		oPrint:Say  (nRow3+2610,0100,aBolTxt[7],											oFont10)	// 7a. Linha Instrução
		oPrint:Say  (nRow3+2650,0100,aBolTxt[8],											oFont10)	// 8a. Linha Instrução
	EndIf
Else
	oPrint:Say  (nRow3+2370,0100,aDadTit[9],											oFont10)	// 1a Linha Instrução
	oPrint:Say  (nRow3+2650,0100,aBolTxt[8],											oFont10)	// 8a. Linha Instrução
EndIf

oPrint:Say  (nRow3+2340,1810,"(-)Desconto/Abatimento",								oFont8)		// Texto Fixo
oPrint:Say  (nRow3+2410,1810,"(-)Outras Deduções",									oFont8)		// Texto Fixo
oPrint:Say  (nRow3+2480,1810,"(+)Mora/Multa",										oFont8)		// Texto Fixo
oPrint:Say  (nRow3+2550,1810,"(+)Outros Acréscimos",								oFont8)		// Texto Fixo
oPrint:Say  (nRow3+2620,1810,"(=)Valor Cobrado",									oFont8)		// Texto Fixo

oPrint:Say  (nRow3+2690,0100,"Pagador",												oFont8)		// Texto Fixo
oPrint:Say  (nRow3+2700,0250,"("+aSacado[2]+") "+aSacado[1],						oFont10)	// Nome Cliente + Código

If aSacado[8] = "J"
	oPrint:Say  (nRow3+2700,1850,"CNPJ: "+TRANSFORM(aSacado[7],"@R 99.999.999/9999-99"),;
																					oFont10)	// CGC
Else
	oPrint:Say  (nRow3+2700,1850,"CPF: "+TRANSFORM(aSacado[7],"@R 999.999.999-99"),;
																					oFont10)	// CPF
EndIf

oPrint:Say  (nRow3+2740,0250,aSacado[3],											oFont10)	// Endereço
oPrint:Say  (nRow3+2780,0250,Transform(aSacado[6],"@R 99999-999")+" - "+;
							aSacado[4]+" - "+aSacado[5],							oFont10)	// CEP + Cidade + Estado

oPrint:Say  (nRow3+2780,1850,Substr(aDadTit[6],1,3)+Substr(aDadTit[6],4),			oFont10)	// Carteira + Nosso Número

oPrint:Say  (nRow3+2815,0100,"Pagador/Avalista",									oFont8)		// Texto Fixo
oPrint:Say  (nRow3+2815,1850,"Código de Baixa",										oFont8)		// Texto Fixo

oPrint:Say  (nRow3+2855,1500,"Autenticação Mecânica - Ficha de Compensação",		oFont8)		// Texto Fixo

oPrint:Line (nRow3+2000,1800,nRow3+2690,1800)													// Quadro
oPrint:Line (nRow3+2410,1800,nRow3+2410,2300)													// Quadro
oPrint:Line (nRow3+2480,1800,nRow3+2480,2300)													// Quadro
oPrint:Line (nRow3+2550,1800,nRow3+2550,2300)													// Quadro
oPrint:Line (nRow3+2620,1800,nRow3+2620,2300)													// Quadro
oPrint:Line (nRow3+2690,100 ,nRow3+2690,2300)													// Quadro
oPrint:Line (nRow3+2850,100,nRow3+2850,2300)													// Quadro

If nTipo = 2
	MSBAR("INT25",13.0,1.0,aCB_RN_NN[1],oPrint,.F.,Nil,Nil,0.013,0.7,Nil,Nil,"A",.F.)				// Código de Barras
Else
	MSBAR("INT25",25.1,0.8,aCB_RN_NN[1],oPrint,.F.,Nil,Nil,0.025,1.5,Nil,Nil,"A",.F.)				// Código de Barras
EndIf

DbSelectArea("SE1")
RecLock("SE1",.F.)
SE1->E1_NUMBCO	:= cNNum
MsUnlock()

oPrint:EndPage() // Finaliza a página

Return Nil


******************************************************************************************************
Static Function Modulo10(cData)
******************************************************************************************************

Local L,D,P := 0
Local B     := .F.

L := Len(cData)
B := .T.
D := 0

While L > 0
	P := Val(SubStr(cData, L, 1))
	If (B)
		P := P * 2
		If P > 9
			P := P - 9
		EndIf
	EndIf
	D := D + P
	L := L - 1
	B := !B
EndDo
D := 10 - (Mod(D,10))
If D == 10
	D := 0
EndIf

Return(D)




******************************************************************************************************
Static Function Modulo11(cData)
******************************************************************************************************

Local L, D, P := 0

L := Len(cdata)
D := 0
P := 1

While L > 0
	P := P + 1
	D := D + (Val(SubStr(cData, L, 1)) * P)
	If P = 9
		P := 1
	EndIf
	L := L - 1
EndDo
D := 11 - (mod(D,11))
If (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
	D := 1
EndIf

Return(D)




******************************************************************************************************
Static Function Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cCart,cNNum,nValor,dVencto)
******************************************************************************************************

Local cValorFinal	:= strzero(int(nValor*100),10)
Local nDvnn			:= 0
Local nDvcb			:= 0
Local nDv			:= 0
Local cNN			:= ''
Local cRN			:= ''
Local cCB			:= ''
Local cS			:= ''
Local cFator		:= strzero(dVencto - ctod("07/10/97"),4)

//-----------------------------
// Definicao do NOSSO NUMERO
// ----------------------------
If cBanco == "341"
	cS    :=  cAgencia + cConta + cCart + cNNum
	nDvnn := modulo10(cS) // digito verifacador Agencia + Conta + Carteira + Nosso Num
	cNN   := cCart + cNNum + '-' + AllTrim(Str(nDvnn))
Else
	cS    :=  cAgencia + cConta + cCart + cNNum
	nDvnn := modulo10(cS) // digito verifacador Agencia + Conta + Carteira + Nosso Num
	cNN   := cCart + cNNum + '-' + AllTrim(Str(nDvnn))
EndIf
	
//----------------------------------
//	 Definicao do CODIGO DE BARRAS
//----------------------------------
cS:= cBanco + cFator +  cValorFinal + Subs(cNN,1,11) + Subs(cNN,13,1) + cAgencia + cConta + cDacCC + '000'
nDvcb := modulo11(cS)
cCB   := SubStr(cS, 1, 4) + AllTrim(Str(nDvcb)) + SubStr(cS,5,25) + AllTrim(Str(nDvnn))+ SubStr(cS,31)

//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica)
//	Campo 1			Campo 2			Campo 3			Campo 4		Campo 5
//	AAABC.CCDDX		DDDDD.DDFFFY	FGGGG.GGHHHZ	K			UUUUVVVVVVVVVV

// 	CAMPO 1:
//	AAA	= Codigo do banco na Camara de Compensacao
//	  B = Codigo da moeda, sempre 9
//	CCC = Codigo da Carteira de Cobranca
//	 DD = Dois primeiros digitos no nosso numero
//	  X = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

cS    := cBanco + cCart + SubStr(cNNum,1,2)
nDv   := modulo10(cS)
cRN   := SubStr(cS, 1, 5) + '.' + SubStr(cS, 6, 4) + AllTrim(Str(nDv)) + '  '      

// 	CAMPO 2:
//	DDDDDD = Restante do Nosso Numero
//	     E = DAC do campo Agencia/Conta/Carteira/Nosso Numero
//	   FFF = Tres primeiros numeros que identificam a agencia
//	     Y = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

cS :=Subs(cNN,6,6) + Alltrim(Str(nDvnn))+ Subs(cAgencia,1,3)
nDv:= modulo10(cS)
cRN := Subs(cBanco,1,3) + "9" + Subs(cCart,1,1)+'.'+ Subs(cCart,2,3) + Subs(cNN,4,2) + SubStr(cRN,11,1)+ ' '+  Subs(cNN,6,5) +'.'+ Subs(cNN,11,1) + Alltrim(Str(nDvnn))+ Subs(cAgencia,1,3) +Alltrim(Str(nDv)) + ' ' 

// 	CAMPO 3:
//	     F = Restante do numero que identifica a agencia
//	GGGGGG = Numero da Conta + DAC da mesma
//	   HHH = Zeros (Nao utilizado)
//	     Z = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
cS    := Subs(cAgencia,4,1) + Subs(cConta,1,4) +  Subs(cConta,5,1)+Alltrim(cDacCC)+'000'
nDv   := modulo10(cS)
cRN   := cRN + Subs(cAgencia,4,1) + Subs(cConta,1,4) +'.'+ Subs(cConta,5,1)+Alltrim(cDacCC)+'000'+ Alltrim(Str(nDv))

//	CAMPO 4:
//	     K = DAC do Codigo de Barras
cRN   := cRN + ' ' + AllTrim(Str(nDvcb)) + '  '

// 	CAMPO 5:
//	      UUUU = Fator de Vencimento
//	VVVVVVVVVV = Valor do Titulo
cRN   := cRN + cFator + StrZero(Int(nValor * 100),14-Len(cFator))

Return({cCB,cRN,cNN})




******************************************************************************************************
User Function SlRece(cPrefixo,cNum,cParcela,cCliente,cLoja)
******************************************************************************************************
// Retorna o Saldo de um título
Local aRet		:= {0,0,0,0}
Local nVlrAbat	:= 0
Local nAcresc	:= 0
Local nDecres	:= 0
Local nSaldo	:= 0

// Pega os Default dos parâmetros
cPrefixo	:= Iif(cPrefixo == Nil, SE1->E1_PREFIXO, cPrefixo)
cNum		:= Iif(cNum == Nil, SE1->E1_NUM, cNum)
cParcela	:= Iif(cParcela == Nil, SE1->E1_PARCELA, cParcela)
cCliente	:= Iif(cCliente == Nil, SE1->E1_CLIENTE, cCliente)
cLoja		:= Iif(cLoja == Nil, SE1->E1_LOJA, cLoja)

// Pega o valor dos abatimentos para o título
nVlrAbat	:= SomaAbat(cPrefixo,cNum,cParcela,"R",1,,cCliente,cLoja)

// Pega o valor de acréscimos e decrescimos paa o título
nAcresc		:= SE1->E1_ACRESC
nDecres		:= SE1->E1_DECRESC

// Define o saldo do título
nSaldo		:= SE1->E1_SALDO-nVlrAbat-nDecres+nAcresc

// Monta Vetor com o retorno
aRet		:= {nSaldo,nVlrAbat,nAcresc,nDecres}

Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa    ³ CriaSx1  ³ Verifica e cria um novo grupo de perguntas com base nos      º±±
±±º             ³          ³ parâmetros fornecidos                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Solicitante ³ 23.05.05 ³ Modelagem de Dados                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Produção    ³ 99.99.99 ³ Ignorado                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parâmetros  ³ ExpA1 = array com o conteúdo do grupo de perguntas (SX1)                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno     ³ Nil                                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Observações ³                                                                         º±±
±±º             ³                                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Alterações  ³ 99/99/99 - Consultor - Descricao da alteração                           º±±
±±º             ³                                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CriaSx1(aRegs)

Local aAreaAtu	:= GetArea()
Local aAreaSX1	:= SX1->(GetArea())
Local nJ		:= 0
Local nY		:= 0

dbSelectArea("SX1")
dbSetOrder(1)

For nY := 1 To Len(aRegs)
	If !MsSeek(aRegs[nY,1]+aRegs[nY,2])
		RecLock("SX1",.T.)
		For nJ := 1 To FCount()
			If nJ <= Len(aRegs[nY])
				FieldPut(nJ,aRegs[nY,nJ])
			EndIf
		Next nJ
		MsUnlock()
	EndIf
Next nY

RestArea(aAreaSX1)
RestArea(aAreaAtu)

Return(Nil)
