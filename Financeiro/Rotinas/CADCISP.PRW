/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ CADCISP  ³ Por: Adalberto Moreno Batista ³ Data ³31.01.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina para importacao de informacoes sobre a situacao     ³±±
±±³          ³ cadastral de clientes nos sites da Receita Federal,        ³±±
±±³          ³ Sintegra e Suframa                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Brasitech                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
#include "rwmake.ch"
#include "tbiconn.ch"

User Function CADCISP()
Local _aSays	:= {}
Local _aButtons	:= {}
Local _nOpcao	:= 0
Private cCadastro	:= "Importaçào de informações da situação cadastral de clientes"
Private cArquivo

aAdd( _aSays, "Atualiza informaçãs da situação cadastral do cliente a partir do que foi disponibilizado" )
aAdd( _aSays, "nos sites da Receita Federal, Sintegra e Suframa." )
aAdd( _aSays, "A CISP disponibiliza este arquivo diariamente e mantém os três últimos movimentos." )
aAdd( _aSays, "" )

aAdd(_aButtons, { 01, .T., {|o| _nOpcao := 1, o:oWnd:End() } } )		//Ok 01
aAdd(_aButtons, { 02, .T., {|o| _nOpcao := 0, o:oWnd:End() } } )		//Cancela 02

FormBatch( cCadastro, _aSays, _aButtons )

if _nOpcao = 1

	cArquivo	:= AllTrim( cGetFile( "Arquivos Texto|*.TXT|Todos os Arquivos|*.*", OemToAnsi( "Selecione o arquivo" ) ) )

	if cArquivo <> NIL
		
		Processa( { || ProcSelect() }, "Processando..." )
	
	endif
	
endif

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ ProcSelect   ³ Por: Adalberto Moreno Batista ³ Data ³31.01.2011³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ProcSelect()
Local nTamFile, nTamLin, cBuffer, nBtLidos
Local cCnpj, cSitCad, cConsulta, cIE, cRazSoc, cEnd, cNro, cCpl, cBai, cMun, cEst, cCEP, cSitCad, cCISP, cSit, cCons, cNroCons, cAbert, cInscr, cMotBx, cSuframa, cVldSufr
Local cEol		:= Chr(13) + Chr(10)
Local nHdl		:= fOpen( cArquivo, 68 )
Local cLogAlt	:= Embaralha( Subs( cUsuario, 7, 15 ) + Save4in2( MsDate() - Ctod("01/01/96") ), 0 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificando se o processo continuara                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !File( cArquivo )
	MsgBox( "O arquivo texto não foi localizado. O processo não será iniciado.", "Atenção", "ERRO" )
	Return()
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abertura do arquivo texto                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nHdl == -1
    MsgBox( "O arquivo de nome " + cArquivo + " não pode ser aberto. O processo não será iniciado.", "Atenção", "ERRO" )
    Return()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Leitura do arquivo texto                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTamFile := fSeek(nHdl,0,2)
fSeek(nHdl,0,0)
nTamLin  := 1499 + Len(cEol)
cBuffer  := Space(nTamLin)							// Variavel para criacao da linha do registro para leitura

nBtLidos := fRead(nHdl,@cBuffer,nTamLin)			// Leitura da primeira linha do arquivo texto

ProcRegua( Round((nTamFile / nTamLin), 0 ) )			// Numero de registros a processar

While nBtLidos >= nTamLin

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Incrementa a regua                                                  ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IncProc("Atualizando informação da situação cadastral...")
	
    cCnpj		:= Substr( cBuffer, 05, 14 )
	cConsulta 	:= Substr( cBuffer, 1, 1 )
	cIE 		:= AllTrim( Substr( cBuffer, 19, 20 ) )
	cRazSoc		:= AllTrim( Substr( cBuffer, 39, 150 ) )
	cEnd		:= AllTrim( Substr( cBuffer, 189, 100 ) )
	cNro		:= AllTrim( Substr( cBuffer, 289, 10 ) )
	cCpl		:= AllTrim( Substr( cBuffer, 299, 70 ) )
	cBai		:= AllTrim( Substr( cBuffer, 369, 50 ) )
	cMun		:= AllTrim( Substr( cBuffer, 419, 80 ) )
	cEst		:= AllTrim( Substr( cBuffer, 499, 2 ) )
	cCEP		:= AllTrim( Substr( cBuffer, 501, 8 ) )
	cSitCad		:= AllTrim( Substr( cBuffer, 715, 50 ) )
	cCISP		:= AllTrim( Substr( cBuffer, 765, 8 ) )
	cSit		:= AllTrim( Substr( cBuffer, 773, 8 ) )
	cCons		:= AllTrim( Substr( cBuffer, 781, 8 ) )
	cNroCons	:= AllTrim( Substr( cBuffer, 789, 10 ) )
	cAbert		:= AllTrim( Substr( cBuffer, 1003, 8 ) )
	cInscr		:= AllTrim( Substr( cBuffer, 1011, 8 ) )
	cMotBx		:= AllTrim( Substr( cBuffer, 1077, 50 ) )
	cSuframa	:= AllTrim( Substr( cBuffer, 1462, 10 ) )
	cVldSufr	:= AllTrim( Substr( cBuffer, 1472, 8 ) )

	cQuery := "UPDATE SA1010 SET "
	
	if cConsulta = '1'		//Sintegra
		cQuery += 	"A1_X_1IE = '" + cIE + "', "
	//	cQuery +=	"A1_X_1RAZ = '" + cSitCad + "', " +;
		cQuery +=	"A1_X_1END = '" + cEnd + ", " + cNro + " " + cCpl + "', "
		cQuery +=	"A1_X_1BAI = '" + cBai + "', "
		cQuery +=	"A1_X_1MUN = '" + cMun + "', "
		cQuery +=	"A1_X_1EST = '" + cEst + "', "
		cQuery +=	"A1_X_1CEP = '" + cCEP + "', "
		cQuery +=	"A1_X_1SIT = '" + cSitCad + "', "
		cQuery +=	"A1_X_1CONS = '" + cCISP + "', "
		cQuery +=	"A1_X_1DTST = '" + cSit + "', "
		cQuery +=	"A1_X_1DTCO = '" + cCons + "', "
		cQuery +=	"A1_X_1NRCO = '" + cNroCons + "', "
		cQuery +=	"A1_X_1DINS = '" + cInscr + "', "
		cQuery +=	"A1_X_1MTBX = '" + cMotBx + "' "
	
	elseif cConsulta = '2'	//Receita
	//	cQuery += 	"A1_X_2RAZ
		cQuery += 	"A1_X_2END = '" + cEnd + ", " + cNro + " " + cCpl + "', "
		cQuery += 	"A1_X_2BAI = '" + cBai + "', "
		cQuery += 	"A1_X_2MUN = '" + cMun + "', "
		cQuery += 	"A1_X_2EST = '" + cEst + "', "
		cQuery += 	"A1_X_2CEP = '" + cCEP + "', "
		cQuery += 	"A1_X_2SIT = '" + cSitCad + "', "
		cQuery +=	"A1_X_2CONS = '" + cCISP + "', "
		cQuery += 	"A1_X_2DTST = '" + cSit + "', "
		cQuery += 	"A1_X_2DTCO = '" + cCons + "', "
		cQuery += 	"A1_X_2ABER = '" + cAbert + "' "
	
	elseif cConsulta = '3'	//Suframa
		cQuery += 	"A1_X_3IE = '" + cIE + "', "
	//	cQuery += 	"A1_X_3RAZ
		cQuery += 	"A1_X_3END = '" + cEnd + ", " +cNro + " " + cCpl + "', "
		cQuery += 	"A1_X_3BAI = '" + cBai + "', "
		cQuery += 	"A1_X_3MUN = '" + cMun + "', "
		cQuery += 	"A1_X_3EST = '" + cEst + "', "
		cQuery += 	"A1_X_3CEP = '" + cCEP + "', "
		cQuery += 	"A1_X_3SIT = '" + cSitCad + "', "
		cQuery +=	"A1_X_3CONS = '" + cCISP + "', "
		cQuery += 	"A1_X_3DTCO = '" + cCons + "', "
		cQuery += 	"A1_X_3DINS = '" + cInscr + "', "
		cQuery += 	"A1_X_3SUFR = '" + cSuframa + "', "
		cQuery += 	"A1_X_3DTVL = '" + cVldSufr + "' "
		
	endif
	  
	cQuery += iif( !Empty( GetAdvFVal( "SX3", "X3_CAMPO", "A1_USERLGA", 2 ) ), ", A1_USERLGA = '" + cLogAlt + "' ", " " )
	cQuery += "WHERE D_E_L_E_T_ = ' ' AND A1_CGC = '" + cCnpj + "'"
	
	TcSqlExec( cQuery )

    nBtLidos := fRead( nHdl, @cBuffer, nTamLin ) // Leitura da proxima linha do arquivo texto

EndDo

fClose( nHdl )

MsgBox( "O cadastro de clientes foi atualizado.", "Informação", "INFO" )

Return()


/*
		cQuery := "UPDATE SA1010 SET "
		cQuery += 	"A1_X_1IE = ' ', "
		cQuery +=	"A1_X_1END = ' ', "
		cQuery +=	"A1_X_1BAI = ' ', "
		cQuery +=	"A1_X_1MUN = ' ', "
		cQuery +=	"A1_X_1EST = ' ', "
		cQuery +=	"A1_X_1CEP = ' ', "
		cQuery +=	"A1_X_1SIT = ' ', "
		cQuery +=	"A1_X_1CONS = ' ', "
		cQuery +=	"A1_X_1DTST = ' ', "
		cQuery +=	"A1_X_1DTCO = ' ', "
		cQuery +=	"A1_X_1NRCO = ' ', "
		cQuery +=	"A1_X_1DINS = ' ', "
		cQuery +=	"A1_X_1MTBX = ' ' "
		cQuery += 	"A1_X_2END = ' ', "
		cQuery += 	"A1_X_2BAI = ' ', "
		cQuery += 	"A1_X_2MUN = ' ', "
		cQuery += 	"A1_X_2EST = ' ', "
		cQuery += 	"A1_X_2CEP = ' ', "
		cQuery += 	"A1_X_2SIT = ' ', "
		cQuery +=	"A1_X_2CONS = ' ', "
		cQuery += 	"A1_X_2DTST = ' ', "
		cQuery += 	"A1_X_2DTCO = ' ', "
		cQuery += 	"A1_X_2ABER = ' ' "
		cQuery += 	"A1_X_3IE = ' ', "
		cQuery += 	"A1_X_3END = ' ', "
		cQuery += 	"A1_X_3BAI = ' ', "
		cQuery += 	"A1_X_3MUN = ' ', "
		cQuery += 	"A1_X_3EST = ' ', "
		cQuery += 	"A1_X_3CEP = ' ', "
		cQuery += 	"A1_X_3SIT = ' ', "
		cQuery +=	"A1_X_3CONS = ' ', "
		cQuery += 	"A1_X_3DTCO = ' ', "
		cQuery += 	"A1_X_3DINS = ' ', "
		cQuery += 	"A1_X_3SUFR = ' ', "
		cQuery += 	"A1_X_3DTVL = ' ' "
		cQuery += "WHERE D_E_L_E_T_ = ' ' " 
	
		TcSqlExec( cQuery )
*/