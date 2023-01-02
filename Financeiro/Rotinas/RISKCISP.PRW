/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ RISKCISP ³ Por: Luiz Fernando Nogueira 	³ Data ³25.08.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina para importacao de informacoes sobre clientes com   ³±±
±±³          ³ Risk Rating Plus (CISP)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Brasitech                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
#include "rwmake.ch"
#include "tbiconn.ch"

User Function RISKCISP()
Local _aSays	:= {}
Local _aButtons	:= {}
Local _nOpcao	:= 0
Private cCadastro	:= "Importaçào de informações de clientes com Risk Rating Plus (CISP)"
Private cArquivo

aAdd( _aSays, "Atualiza informações referentes a Risk Rating Plus (CISP)" )
aAdd( _aSays, "e atualiza campos de consulta no cadastro de clientes." )
//aAdd( _aSays, "A CISP disponibiliza este arquivo diariamente e mantém os três últimos movimentos." )
aAdd( _aSays, "" )

aAdd(_aButtons, { 01, .T., {|o| _nOpcao := 1, o:oWnd:End() } } )		//Ok 01
aAdd(_aButtons, { 02, .T., {|o| _nOpcao := 0, o:oWnd:End() } } )		//Cancela 02

FormBatch( cCadastro, _aSays, _aButtons )

if _nOpcao = 1

	cArquivo	:= AllTrim( cGetFile( "Arquivos Texto|*.TXT|Todos os Arquivos|*.*", OemToAnsi( "Selecione o arquivo" ) ) )

	if cArquivo <> NIL
		
		Processa( { || ProcSelec() }, "Processando..." )
	
	endif
	
endif

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ ProcSelec    ³ Por: Luiz Fernando Nogueira  	³ Data ³25.08.2011³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ProcSelec()
Local nTamFile, nTamLin, cBuffer, nBtLidos
Local cCnpj, cRiscAtu, cRiscPont, cRiscMerc, cRiscOcor, cRiscCred, cRiscDens
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
nTamLin  := 317+Len(cEOL)
cBuffer  := Space(nTamLin) // Variavel para criacao da linha do registro para leitura

nBtLidos := fRead(nHdl,@cBuffer,nTamLin) // Leitura da primeira linha do arquivo texto

ProcRegua(nTamFile) // Numero de registros a processar

While nBtLidos >= nTamLin

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Incrementa a regua                                                  ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IncProc("Atualizando informações Risk Rating Plus (CISP) no cadastro de clientes...")
	
    cCnpj	:= STRZero(val(Substr( cBuffer, 05, 24 )),14)
    cRiscAtu	:= Substr( cBuffer, 65, 01 )
    cRiscPont	:= Substr( cBuffer, 66, 01 ) 
    cRiscMerc	:= Substr( cBuffer, 67, 01 ) 
    cRiscOcor	:= Substr( cBuffer, 68, 01 ) 
    cRiscCred	:= Substr( cBuffer, 69, 01 ) 
    cRiscDens	:= Substr( cBuffer, 70, 01 )
    
    /*
    cDtBol	:= Substr( cBuffer, 19, 08 )
    cSldAnt	:= Substr( cBuffer, 27, 05 )
    cIncl	:= Substr( cBuffer, 32, 05 )
    cExcl	:= Substr( cBuffer, 37, 05 )
    cSldAtu	:= Substr( cBuffer, 42, 05 )
    */
  
	cQuery := 	"UPDATE SA1010 SET " +;
					"A1_XRSCATU = '" 		+ cRiscAtu 	+ 	"', " +;
					"A1_XRSCPON = '" 		+ cRiscPont + 	"', " +;
					"A1_XRSCMER = '" 		+ cRiscMerc + 	"', " +;
					"A1_XRSCOCO = '" 		+ cRiscOcor + 	"', " +;
					"A1_XRSCCRE = '" 		+ cRiscCred + 	"', " +;
					"A1_XRSCDEN = '" 		+ cRiscDens + 	"'  " +;
					iif( !Empty( GetAdvFVal( "SX3", "X3_CAMPO", "A1_USERLGA", 2 ) ), ", A1_USERLGA = '" + cLogAlt + "' ", " " ) +;
				"WHERE D_E_L_E_T_ = ' ' AND A1_CGC = '" + cCnpj + "'"


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³    Gera a Query em Arquivo Texto para Analises pelo Query Analyser         ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

//Memowrite("RiskCisp.Sql" , cQuery )


TcSqlExec( cQuery )

/*	SA1->( dbSetOrder(3) )
	if SA1->( dbSeek( xFilial("SA1") + cCnpj ) )
		SA1->( RecLock( "SA1", .F. ) )
		SA1->A1_X_DTINF		:= sTOd(cDtBol)
		SA1->A1_X_SLANT		:= NoRound( Val( cSldAnt ) )
		SA1->A1_X_ICCF		:= NoRound( Val( cIncl ) )
		SA1->A1_X_ECCF		:= NoRound( Val( cExcl ) )
		SA1->A1_X_SLATU		:= NoRound( Val( cSldAtu ) )
		SA1->( MsUnLock() )
	endif	*/
    
    nBtLidos := fRead( nHdl, @cBuffer, nTamLin ) // Leitura da proxima linha do arquivo texto

EndDo

fClose( nHdl )

MsgBox( "O cadastro de clientes foi atualizado.", "Informação", "INFO" )

Return()
