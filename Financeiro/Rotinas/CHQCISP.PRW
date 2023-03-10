/*/
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????Ŀ??
???Programa  ? CHQCISP  ? Por: Adalberto Moreno Batista ? Data ?24.01.2011???
?????????????????????????????????????????????????????????????????????????Ĵ??
???Descricao ? Rotina para importacao de informacoes sobre clientes com   ???
???          ? cheques sem fundo                                          ???
?????????????????????????????????????????????????????????????????????????Ĵ??
???Uso       ? Especifico Brasitech                                       ???
??????????????????????????????????????????????????????????????????????????ٱ?
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
/*/
#include "rwmake.ch"
#include "tbiconn.ch"

User Function CHQCISP()
Local _aSays	:= {}
Local _aButtons	:= {}
Local _nOpcao	:= 0
Private cCadastro	:= "Importa??o de informa??es de clientes com cheques sem fundo"
Private cArquivo

aAdd( _aSays, "Atualiza informa??es, disponibilizadas pelo BACEN, referentes a cheques sem fundo" )
aAdd( _aSays, "e atualiza campos de consulta no cadastro de clientes." )
aAdd( _aSays, "A CISP disponibiliza este arquivo diariamente e mant?m os tr?s ?ltimos movimentos." )
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
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????Ŀ??
???Funcao? ProcSelect   ? Por: Adalberto Moreno Batista ? Data ?20.05.2010???
??????????????????????????????????????????????????????????????????????????ٱ?
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
*/
Static Function ProcSelect()
Local nTamFile, nTamLin, cBuffer, nBtLidos
Local cCnpj, cDtBol, cSldAnt, cIncl, cExcl, cSldAtu
Local cEol		:= Chr(13) + Chr(10)
Local nHdl		:= fOpen( cArquivo, 68 )
Local cLogAlt	:= Embaralha( Subs( cUsuario, 7, 15 ) + Save4in2( MsDate() - Ctod("01/01/96") ), 0 )

//?????????????????????????????????????????????????????????????????????Ŀ
//? Verificando se o processo continuara                                ?
//???????????????????????????????????????????????????????????????????????
if !File( cArquivo )
	MsgBox( "O arquivo texto n?o foi localizado. O processo n?o ser? iniciado.", "Aten??o", "ERRO" )
	Return()
endif

//?????????????????????????????????????????????????????????????????????Ŀ
//? Abertura do arquivo texto                                           ?
//???????????????????????????????????????????????????????????????????????
If nHdl == -1
    MsgBox( "O arquivo de nome " + cArquivo + " n?o pode ser aberto. O processo n?o ser? iniciado.", "Aten??o", "ERRO" )
    Return()
Endif

//?????????????????????????????????????????????????????????????????????Ŀ
//? Leitura do arquivo texto                                            ?
//???????????????????????????????????????????????????????????????????????
nTamFile := fSeek(nHdl,0,2)
fSeek(nHdl,0,0)
nTamLin  := 46+Len(cEOL)
cBuffer  := Space(nTamLin) // Variavel para criacao da linha do registro para leitura

nBtLidos := fRead(nHdl,@cBuffer,nTamLin) // Leitura da primeira linha do arquivo texto

ProcRegua(nTamFile) // Numero de registros a processar

While nBtLidos >= nTamLin

    //?????????????????????????????????????????????????????????????????????Ŀ
    //? Incrementa a regua                                                  ?
    //???????????????????????????????????????????????????????????????????????
	IncProc("Atualizando informa??es CISP no cadastro de clientes...")
	
    cCnpj	:= Substr( cBuffer, 05, 14 )
    cDtBol	:= Substr( cBuffer, 19, 08 )
    cSldAnt	:= Substr( cBuffer, 27, 05 )
    cIncl	:= Substr( cBuffer, 32, 05 )
    cExcl	:= Substr( cBuffer, 37, 05 )
    cSldAtu	:= Substr( cBuffer, 42, 05 )
  
	cQuery := 	"UPDATE SA1010 SET " +;
					"A1_X_DTINF = '" + cDtBol + "', " +;
					"A1_X_SLANT = " + cSldAnt + ", " +;
					"A1_X_ICCF = " + cIncl + ", " +;
					"A1_X_ECCF = " + cExcl + ", " +;
					"A1_X_SLATU = " + cSldAtu +;
					iif( !Empty( GetAdvFVal( "SX3", "X3_CAMPO", "A1_USERLGA", 2 ) ), ", A1_USERLGA = '" + cLogAlt + "' ", " " ) +;
				"WHERE D_E_L_E_T_ = ' ' AND A1_CGC = '" + cCnpj + "'"

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

MsgBox( "O cadastro de clientes foi atualizado.", "Informa??o", "INFO" )

Return()
