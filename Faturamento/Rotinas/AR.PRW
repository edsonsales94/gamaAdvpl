#Include "Protheus.Ch" 
#include "rwmake.ch"
#include "topconn.ch"

#Define ENTER Chr(13)+Chr(10)
#define VK_F4    115 

/*/
———————————————————————————————————————————————————————————————————————————————
@function		AUTODEV                                                       /@
@type				User function                                                 /@
@date				15/11/2010                                                    /@
@description	                                                              /@
@author			Luiz Fernando                                                 /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function AutoDev()
Local cAR		:= "0 - Todas ARs"
Local aAR		:= {"0 - Sem Filtro","1 - Pré - AR" ,"2 - AR - Incluída", "3 - AR - Solicitada", "4 - AR - Coletada", "5 - AR - Recebida", "6 - AR - Laudo", "7 - AR - Internada", "8 - AR - Devol. Finalizada","9 - AR - Troca Finalizada" ,"A - AR - Nao Classificada"}
Private oDlgAr

//———————————————————————————————————————————————————————————————————————————————
// Criacao da Interface
//———————————————————————————————————————————————————————————————————————————————
@ 186,388 To 356,768 Dialog oDlgAr Title OemToAnsi("Filtro para AR")
@ 15,5 Say OemToAnsi("Filtra as AR's...") Size 40,10
@ 13,50 ComboBox cAr Items aAr Size 80,21
@ 15,150 BmpButton Type 1 Action BrasFiltro(Left(cAr,1))
@ 30,150 BmpButton Type 2 Action Close(oDlgAr)
Activate Dialog oDlgAr Centered
Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		BRASFILTRO                                                    /@
@type				Static function                                               /@
@date				                                                              /@
@description	                                                              /@
@author			Adalberto Moreno Batista                                      /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function BrasFiltro(cOpc)
Local _cFiltro, _bFiltraBrw
Private _aIndex	:= {}
Private aRet:={}

//SETKEY(VK_F4,{||chnfori(M->ZG_CLIENTE,M->ZG_LOJACLI,GDFIELDGET("ZH_PRODUTO"))})

//———————————————————————————————————————————————————————————————————————————————
// Gravando campo especifico para filtragem da tabela
//———————————————————————————————————————————————————————————————————————————————

if cOpc = "1"			//"1 - Pré AR " - "BR_CANCEL"
	_cFiltro := "empty(SZG->ZG_NFDEVOL) .and. ZG_FILIAL = '" + xFilial("SZG") +"'"
	
elseif cOpc = "2"			//"1 - AR - Incluída" - "BR_VERDE"
	_cFiltro := "!empty(SZG->ZG_NFDEVOL) .and. ZG_FILIAL = '" + xFilial("SZG") + "' .and. !empty(SZG->ZG_DTENTRE) .AND. empty(SZG->ZG_DTSOLIC)  .AND.  empty(SZG->ZG_DTCOLE)  .AND.  empty(SZG->ZG_DTENTES)  .AND.  empty(SZG->ZG_DTRECUS)  .AND.  empty(SZG->ZG_DTINTER)  .AND. empty(SZG->ZG_DTRETOR)"
   
elseif cOpc = "3"		//"2 - AR - Solicitada"	- "BR_AMARELO"	"
	_cFiltro := "!empty(SZG->ZG_NFDEVOL) .and. ZG_FILIAL = '" + xFilial("SZG") + "' .and. !empty(SZG->ZG_DTENTRE) .AND. !empty(SZG->ZG_DTSOLIC) .AND.  empty(SZG->ZG_DTCOLE)  .AND.  empty(SZG->ZG_DTENTES)  .AND.  empty(SZG->ZG_DTRECUS)  .AND.  empty(SZG->ZG_DTINTER)  .AND. empty(SZG->ZG_DTRETOR)"

elseif cOpc = "4"		//"3 - AR - Coletada" - "BR_PINK"
	_cFiltro := "!empty(SZG->ZG_NFDEVOL) .and. ZG_FILIAL = '" + xFilial("SZG") + "' .and. !empty(SZG->ZG_DTENTRE) .AND. !empty(SZG->ZG_DTSOLIC) .AND.  !empty(SZG->ZG_DTCOLE) .AND.  empty(SZG->ZG_DTENTES)  .AND.  empty(SZG->ZG_DTRECUS)  .AND.  empty(SZG->ZG_DTINTER)  .AND. empty(SZG->ZG_DTRETOR)"

elseif cOpc = "5"		//"4 - AR - Recebida" - "BR_AZUL"
	_cFiltro := "!empty(SZG->ZG_NFDEVOL) .and. ZG_FILIAL = '" + xFilial("SZG") + "' .and. !empty(SZG->ZG_DTENTRE) .AND. !empty(SZG->ZG_DTSOLIC) .AND.  !empty(SZG->ZG_DTCOLE) .AND.  !empty(SZG->ZG_DTENTES) .AND.  empty(SZG->ZG_DTRECUS)  .AND.  empty(SZG->ZG_DTINTER)  .AND. empty(SZG->ZG_DTRETOR)"

elseif cOpc = "6"		//"5 - AR - Laudo" - "BR_LARANJA"
	_cFiltro := "!empty(SZG->ZG_NFDEVOL) .and. ZG_FILIAL = '" + xFilial("SZG") + "' .and. !empty(SZG->ZG_DTENTRE) .AND. !empty(SZG->ZG_DTSOLIC) .AND.  !empty(SZG->ZG_DTCOLE) .AND.  !empty(SZG->ZG_DTENTES) .AND.  !empty(SZG->ZG_DTRECUS) .AND.  empty(SZG->ZG_DTINTER)  .AND. empty(SZG->ZG_DTRETOR)"

elseif cOpc = "7"		//"6 - AR - Internada" - "BR_BRANCO"
	_cFiltro := "!empty(SZG->ZG_NFDEVOL) .and. ZG_FILIAL = '" + xFilial("SZG") + "' .and. !empty(SZG->ZG_DTENTRE) .AND. !empty(SZG->ZG_DTSOLIC) .AND.  !empty(SZG->ZG_DTCOLE) .AND.  !empty(SZG->ZG_DTENTES) .AND.  !empty(SZG->ZG_DTRECUS)  .AND.  !empty(SZG->ZG_DTINTER) .AND. empty(SZG->ZG_DTRETOR)  .AND. (ZG_TIPO == 'R')"

elseif cOpc = "8"		//"7 - AR - Devol. Finalizada" - "BR_VERMELHO"
	_cFiltro := "!empty(SZG->ZG_NFDEVOL) .and. ZG_FILIAL = '" + xFilial("SZG") + "' .and. !empty(SZG->ZG_DTENTRE) .AND. !empty(SZG->ZG_DTSOLIC) .AND.  !empty(SZG->ZG_DTCOLE) .AND.  !empty(SZG->ZG_DTENTES) .AND.  !empty(SZG->ZG_DTRECUS)  .AND.  !empty(SZG->ZG_DTINTER) .AND. empty(SZG->ZG_DTRETOR) .AND. (ZG_TIPO == 'D')"

elseif cOpc = "9"		//"8 - AR - Troca Finalizada" - "BR_MARRON"
	_cFiltro := "!empty(SZG->ZG_NFDEVOL) .and. ZG_FILIAL = '" + xFilial("SZG") + "' .and. !empty(SZG->ZG_DTENTRE) .AND. !empty(SZG->ZG_DTSOLIC) .AND.  !empty(SZG->ZG_DTCOLE) .AND.  !empty(SZG->ZG_DTENTES) .AND.  !empty(SZG->ZG_DTRECUS)  .AND.  !empty(SZG->ZG_DTINTER) .AND. !empty(SZG->ZG_DTRETOR) .AND. (ZG_TIPO == 'R')"

elseif cOpc = "A"		//"9 - AR - Nao Classificada" - "BR_CINZA"
	_cFiltro := "!empty(SZG->ZG_NFDEVOL) .and. ZG_FILIAL = '" + xFilial("SZG") + "' .and. empty(SZG->ZG_DTENTRE)  .AND. empty(SZG->ZG_DTSOLIC)  .AND.  empty(SZG->ZG_DTCOLE)  .AND.  empty(SZG->ZG_DTENTES)  .AND.  empty(SZG->ZG_DTRECUS)  .AND.  empty(SZG->ZG_DTINTER)  .AND. empty(SZG->ZG_DTRETOR)"

endif

if !empty(_cFiltro)
	_bFiltraBrw := {|| FilBrowse("SZG",@_aIndex,@_cFiltro) }
	Eval(_bFiltraBrw)
endif

u_AtuaAR()

If ( Len(_aIndex) > 0 )
	//———————————————————————————————————————————————————————————————————————————————
	// Finaliza o uso da funcao FilBrowse e retorna os indices padroes.
	//———————————————————————————————————————————————————————————————————————————————
	EndFilBrw("SZH",_aIndex)
EndIf
Close(oDlgAr)
Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		ATUAAR                                                        /@
@type				User function                                                 /@
@date				15/11/2010                                                    /@
@description	Exibe a legenda na tela do A.R.                               /@
@author			Luiz Fernando                                                 /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function AtuaAR()
Private nUsado     := 0
Private cCadastro  := "Atualização de A.R."
Private aRotina    := {}
Private aPos       := {15, 1, 70, 315}
Private oCliente   := Nil
Private oTotal     := Nil
Private cCliente   := ""
Private nTotal     := 0

Private aSize    := {}
Private aObjects := {}
Private aInfo    := {}
Private aPosObj  := {}
Private aPosGet  := {}

//+---------------------------------------------------
//| MsAdvSize(ExpL1,ExpL2,ExpN1)
//+---------------------------------------------------
//| Parametros
//| ----------
//| ExpL1 -> Enchoicebar .T. ou .F.
//| ExpL2 -> Retorna janela padrao siga .T. ou .F.
//| ExpN1 -> Tamanho minimo ( altura )
//|
//| Retorno
//| -------
//| ExpA1 -> Dimensoes da janela e area de trabalho
//|          1 -> Linha inicial area trabalho
//|          2 -> Coluna inicial area trabalho
//|          3 -> Linha final area trabalho
//|          4 -> Coluna final area trabalho
//|          5 -> Coluna final dialog
//|          6 -> Linha final dialog
//|          7 -> Linha inicial dialog
//+---------------------------------------------------
aSize := MsAdvSize()

//+------------------------------------------------------------------------------------------
//| MsObjSize(ExpA1,ExpA2,lExp1,lExp2)
//+------------------------------------------------------------------------------------------
//| Parametros
//| ----------
//| ExpA2 -> Area de trabalho
//| ExpA3 -> Definicoes de objetos 1-Tamanho X
//|                                2-Tamanho Y
//|                                3-Dimensiona X
//|                                4-Dimensiona Y
//|                                5-Retorna dimensoes X e Y ao inves de linha / coluna final
//| ExpL2 -> Indica calculo de objetos horizontais
//| ExpL1 -> Mantem a proporcao dos objetos
//|
//| Retorno
//| -------
//| ExpA1 -> Array com as posicoes de cada objeto
//|          1 -> Linha inicial
//|          2 -> Coluna inicial
//|          3 -> Linha final
//|          4 -> Coluna final Ou caso seja passado o elemento 5 de cada
//|               definicao de objetos como .T. o retorno sera: 3 -> Tamanho da dimensao X
//|                                                             4 -> Tamanho da dimensao Y
//+------------------------------------------------------------------------------------------
aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}

aAdd(aObjects,{100,100,.T.,.T.})
aAdd(aObjects,{100,100,.T.,.T.})
aAdd(aObjects,{100,015,.T.,.F.})

aPosObj := MsObjSize(aInfo,aObjects)

//+------------------------------------------------------------------------
//| MsObjGetPos(ExpN1,ExpN2,ExpA1)
//+------------------------------------------------------------------------
//| Parametros
//| ----------
//| nSizeAtu -> Linha final area trabalho menos Linha inicial area trabalho
//| nSizeDef -> Tamanho do espaço definido para distribuição
//| aPosDef --> Colunas que serão apresentadas em tela o SAY e GET
//|
//| Retorno
//| -------
//| Vetor com as colunas que serão apresentado o SAY e o GET
//+------------------------------------------------------------------------
aPosGet := MsObjGetPos((aSize[3]-aSize[1]),315,{{004,024,240,270}} )

aAdd(aRotina, {"Pesquisar",	"AxPesqui",					0, 1})
aAdd(aRotina, {"Visualizar",	"u_ARVisual",				0, 2})
aAdd(aRotina, {"Incluir",		"u_ARInclui",				0, 3})
aAdd(aRotina, {"Alterar",		"u_ARAltera",				0, 4})
aAdd(aRotina, {"Excluir",		"u_ARExclui",				0, 5})
aAdd(aRotina, {"Gera PDF",		"u_ARBR01",					0, 6})
aAdd(aRotina, {"AR x GKO",		"u_FDADOSGKO",					0, 6})
aAdd(aRotina, {"Legenda",		"Execblock('LEGEAR')",	0, 2})


If Empty(Posicione("SX3",1,"SZG","X3_ARQUIVO"))
	Help("",1,"","NOX3X2IX","NÃO É POSSÍVEL EXECUTAR, FALTA"+ENTER+"X3, X2, IX E X7",1,0)
	RETURN
Endif


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variavel que definira as cores do browse                            ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Private aCores  := {}

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Array com as cores do browse                                        ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

//aAdd( aCores , { "SZG->ZG_TRANSP <> '      '" , "BR_VERMELHO"    } )

aAdd( aCores , { "empty(SZG->ZG_NFDEVOL)" , 																																																																																		"BR_CANCEL" })
aAdd( aCores , { "!empty(SZG->ZG_NFDEVOL) .and. empty(SZG->ZG_DTENTRE)  .AND. empty(SZG->ZG_DTSOLIC)  .AND.  empty(SZG->ZG_DTCOLE)  .AND.  empty(SZG->ZG_DTENTES)  .AND.  empty(SZG->ZG_DTRECUS)   .AND.  empty(SZG->ZG_DTINTER)  .AND. empty(SZG->ZG_DTRETOR)" , 										"BR_CINZA" })
aAdd( aCores , { "!empty(SZG->ZG_NFDEVOL) .and. !empty(SZG->ZG_DTENTRE) .AND. !empty(SZG->ZG_DTSOLIC) .AND.  !empty(SZG->ZG_DTCOLE) .AND.  !empty(SZG->ZG_DTENTES) .AND.  !empty(SZG->ZG_DTRECUS)  .AND.  !empty(SZG->ZG_DTINTER) .AND. empty(SZG->ZG_DTRETOR)  .AND. (ZG_TIPO == 'D') " ,		"BR_VERMELHO" })
aAdd( aCores , { "!empty(SZG->ZG_NFDEVOL) .and. !empty(SZG->ZG_DTENTRE) .AND. !empty(SZG->ZG_DTSOLIC) .AND.  !empty(SZG->ZG_DTCOLE) .AND.  !empty(SZG->ZG_DTENTES) .AND.  !empty(SZG->ZG_DTRECUS)  .AND.  !empty(SZG->ZG_DTINTER) .AND. empty(SZG->ZG_DTRETOR)  .AND. (ZG_TIPO == 'R') " ,		"BR_BRANCO" })
aAdd( aCores , { "!empty(SZG->ZG_NFDEVOL) .and. !empty(SZG->ZG_DTENTRE) .AND. !empty(SZG->ZG_DTSOLIC) .AND.  !empty(SZG->ZG_DTCOLE) .AND.  !empty(SZG->ZG_DTENTES) .AND.  !empty(SZG->ZG_DTRECUS)  .AND.  !empty(SZG->ZG_DTINTER) .AND. !empty(SZG->ZG_DTRETOR) .AND. (ZG_TIPO == 'R') " ,		"BR_VIOLETA" })
aAdd( aCores , { "!empty(SZG->ZG_NFDEVOL) .and. !empty(SZG->ZG_DTENTRE) .AND. !empty(SZG->ZG_DTSOLIC) .AND.  !empty(SZG->ZG_DTCOLE) .AND.  !empty(SZG->ZG_DTENTES) .AND.  !empty(SZG->ZG_DTRECUS)  .AND.  empty(SZG->ZG_DTINTER)  .AND. empty(SZG->ZG_DTRETOR)" , 										"BR_LARANJA" })
aAdd( aCores , { "!empty(SZG->ZG_NFDEVOL) .and. !empty(SZG->ZG_DTENTRE) .AND. !empty(SZG->ZG_DTSOLIC) .AND.  !empty(SZG->ZG_DTCOLE) .AND.  !empty(SZG->ZG_DTENTES) .AND.  empty(SZG->ZG_DTRECUS)   .AND.  empty(SZG->ZG_DTINTER)  .AND. empty(SZG->ZG_DTRETOR)" , 										"BR_AZUL" })
aAdd( aCores , { "!empty(SZG->ZG_NFDEVOL) .and. !empty(SZG->ZG_DTENTRE) .AND. !empty(SZG->ZG_DTSOLIC) .AND.  !empty(SZG->ZG_DTCOLE) .AND.  empty(SZG->ZG_DTENTES)  .AND.  empty(SZG->ZG_DTRECUS)   .AND.  empty(SZG->ZG_DTINTER)  .AND. empty(SZG->ZG_DTRETOR)" , 										"BR_PINK" })
aAdd( aCores , { "!empty(SZG->ZG_NFDEVOL) .and. !empty(SZG->ZG_DTENTRE) .AND. !empty(SZG->ZG_DTSOLIC) .AND.  empty(SZG->ZG_DTCOLE)  .AND.  empty(SZG->ZG_DTENTES)  .AND.  empty(SZG->ZG_DTRECUS)   .AND.  empty(SZG->ZG_DTINTER)  .AND. empty(SZG->ZG_DTRETOR)" , 										"BR_AMARELO" })
aAdd( aCores , { "!empty(SZG->ZG_NFDEVOL) .and. !empty(SZG->ZG_DTENTRE) .AND. empty(SZG->ZG_DTSOLIC)  .AND.  empty(SZG->ZG_DTCOLE)  .AND.  empty(SZG->ZG_DTENTES)  .AND.  empty(SZG->ZG_DTRECUS)   .AND.  empty(SZG->ZG_DTINTER)  .AND. empty(SZG->ZG_DTRETOR)" ,										 	"BR_VERDE" })


dbSelectArea("SZH")
dbSetOrder(1)
dbSelectArea("SZG")
dbSetOrder(1)

mBrowse(,,,,"SZG", , , , , ,aCores)

Return .T.


/*/
———————————————————————————————————————————————————————————————————————————————
@function		LEGEAR                                                        /@
@type				User function                                             /@
@date				15/11/2010                                                /@
@description	Exibe a legenda na tela do A.R.                               /@
@author			Luiz Fernando                                                 /@
@use				Específico Brasitech                                      /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function LegeAR( cAlias , nRecno , cOpcao )

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³                 Declara as Variaveis Utilizadas na Rotina                  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Local aLegenda := {}

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³                    Efetua a Carga do Array de Legendas                     ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdd(aLegenda, {"BR_CANCEL", 	 "Pré-AR"            		 })
aAdd(aLegenda, {"BR_VERDE", 	 "AR - Incluída"             })
aAdd(aLegenda, {"BR_AMARELO",  "AR - Solicitada"             })
aAdd(aLegenda, {"BR_PINK", 	 "AR - Coletada"                 })
aAdd(aLegenda, {"BR_AZUL", 	 "AR - Recebida"                 })
aAdd(aLegenda, {"BR_LARANJA",  "AR - Laudo"             	 })
aAdd(aLegenda, {"BR_BRANCO", 	 "AR - Internada"  			 })
aAdd(aLegenda, {"BR_VERMELHO", "AR - Devol. Finalizada"      })
aAdd(aLegenda, {"BR_VIOLETA",	 "AR - Troca Finalizada"  	 })
aAdd(aLegenda, {"BR_CINZA", 	 "AR - Nao Classificada"  	 })

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³                              Monta Legenda                                 ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
BrwLegenda( cCadastro , OemToAnsi("Legendas") , aLegenda )

Return


/*/
———————————————————————————————————————————————————————————————————————————————
@function		ARVISUAL                                                      /@
@type				User function                                             /@
@date				15/11/2010                                                /@
@description	Visualiza o A.R.                                              /@
@author			Luiz Fernando                                                 /@
@use				Específico Brasitech                                      /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function ARVisual( cAlias, nRecNo, nOpc )
Local nX        := 0
Local nCols     := 0
Local nOpcA     := 0
Local oDlg      := Nil
Local oGet      := Nil
Local oMainWnd  := Nil

Private aTela   := {}
Private aGets   := {}
Private aHeader := {}
Private aCols   := {}
Private bCampo  := { |nField| Field(nField) }
Private lInclui	:= .F.
Private lAltera	:= .F.
Private lExclui	:= .F.

cCliente := ""
nTotal := 0

//+----------------------------------
//| Inicia as variaveis para Enchoice
//+----------------------------------
dbSelectArea("SZG")
dbSetOrder(1)
dbGoTo(nRecNo)
For nX:= 1 To FCount()
	M->&(Eval(bCampo,nX)) := FieldGet(nX)
Next nX

//+----------------
//| Monta o aHeader
//+----------------
CriaHeader()

//+--------------
//| Monta o aCols
//+--------------
dbSelectArea("SZH")
dbSetOrder(1)
dbSeek(xFilial("SZH") + SZG->ZG_NUMERO)

While !Eof() .And. SZH->ZH_FILIAL == SZG->ZG_FILIAL .And. SZH->ZH_NUMERO == SZG->ZG_NUMERO
	aAdd(aCols,Array(nUsado+1))
	nCols ++
	
	For nX := 1 To nUsado
		If ( aHeader[nX][10] != "V")
			aCols[nCols][nX] := FieldGet(FieldPos(aHeader[nX][2]))
		Else
			aCols[nCols][nX] := CriaVar(aHeader[nX][2],.T.)
		Endif
	Next nX
	
	aCols[nCols][nUsado+1] := .F.
	dbSelectArea("SZH")
	dbSkip()
End


//DEFINE MSDIALOG oDlg TITLE cCadastro From 8,0 TO 28,80  OF oMainWnd
DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],aSize[1] TO aSize[6],aSize[5] OF oMainWnd PIXEL
EnChoice( cAlias, nRecNo, nOpc, , , , , aPosObj[1], , 3)
//EnChoice(cAlias, nRecNo, nOpc,,,,, aPos,, 3)

// Atualizacao do nome do cliente
//@ 136,004 SAY "Cliente: "                                     SIZE 070,7 OF oDlg PIXEL
//@ 136,024 SAY oCliente VAR cCliente                           SIZE 098,7 OF oDlg PIXEL

// Atualizacao do total
//@ 136,240 SAY "Valor Total: "                                 SIZE 070,7 OF oDlg PIXEL
//@ 136,270 SAY oTotal VAR nTotal PICTURE "@E 9,999,999,999.99" SIZE 070,7 OF oDlg PIXEL

//u_Mod3AtuCli()
//oGet := MsGetDados():New(75,2,130,315,nOpc)
oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,,,,.T.)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,Iif(oGet:TudoOk(),oDlg:End(),nOpcA := 0)},{||oDlg:End()})

Return .T.


/*/
———————————————————————————————————————————————————————————————————————————————
@function		ARINCLUI                                                      /@
@type				User function                                                 /@
@date				15/11/2010                                                    /@
@description	Inclui A.R.                                                   /@
@author			Luiz Fernando                                                 /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function ARInclui( cAlias, nRecNo, nOpc )
Local nOpcA      := 0
Local nX         := 0
Local oDlg       := Nil

Private aTela    := {}
Private aGets    := {}
Private aHeader  := {}
Private aCols    := {}
Private bCampo   := {|nField| FieldName(nField) }
Private lInclui	:= .T.
Private lAltera	:= .F.
Private lExclui	:= .F.


cCliente := ""
nTotal := 0

//+--------------------------------------
//| Cria Variaveis de Memoria da Enchoice
//+--------------------------------------
dbSelectArea("SZG")
For nX := 1 To FCount()
	M->&(Eval(bCampo,nX)) := CriaVar(FieldName(nX),.T.)
Next nX

//———————————————————————————————————————————————————————————————————————————————
// Caso o número sequencial não esteja correto, busco o próximo número válido.
// Somente para inclusão de registros
//———————————————————————————————————————————————————————————————————————————————
SZG->(dbSetOrder(1))		//ZG_FILIAL, ZG_NUMERO, ZG_EMISSAO, ZG_CLIENTE, ZG_LOJACLI
do while SZG->(dbSeek(xFilial("SZG") + M->ZG_NUMERO))
	ConfirmSX8()
	M->ZG_NUMERO := GetSXENum("SZG")
enddo

//+----------------
//| Monta o aHeader
//+----------------
CriaHeader()

//+--------------
//| Monta o aCols
//+--------------
aAdd(aCols,Array(nUsado+1))
nUsado := 0
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("SZH")
While !Eof() .And. SX3->X3_ARQUIVO == "SZH"
	If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
		nUsado++
		aCols[1][nUsado] := CriaVar(Trim(SX3->X3_CAMPO),.T.)
	Endif
	dbSkip()
End

aCols[1][nUsado+1] := .F.
//aCols[1][aScan(aHeader,{|x| Trim(x[2])=="ZA2_ITEM"})] := "01"

//+----------------------------------
//| Envia para processamento dos Gets
//+----------------------------------

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],aSize[1] TO aSize[6],aSize[5] OF oMainWnd PIXEL
EnChoice( cAlias, nRecNo, nOpc, , , , , aPosObj[1], , 3)
//EnChoice( cAlias, nRecNo, nOpc, , , , , aPosObj[1], , 3)

// Atualizacao do nome do cliente
//@ aPosObj[3,1],aPosGet[1,1] SAY "Cliente: "                                     SIZE 070,7 OF oDlg PIXEL
//@ aPosObj[3,1],aPosGet[1,2] SAY oCliente VAR cCliente                           SIZE 098,7 OF oDlg PIXEL


// Atualizacao do total
//@ aPosObj[3,1],aPosGet[1,3] SAY "Valor Total: "                                 SIZE 070,7 OF oDlg PIXEL
//@ aPosObj[3,1],aPosGet[1,4] SAY oTotal VAR nTotal PICTURE "@E 9,999,999,999.99" SIZE 070,7 OF oDlg PIXEL

oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,,,,.T.)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcA:=1,If(u_Mod3Tudok().And.Obrigatorio(aGets,aTela),oDlg:End(),nOpca:=0)},{||nOpca:=0,oDlg:End()},,;
{{"RPMOPEN",{|| ChNFOri(M->ZG_CLIENTE,M->ZG_LOJACLI,GDFIELDGET("ZH_PRODUTO"),M->ZG_NUMERO,GDFIELDGET("ZH_ITEM"))},"Seleciona Notas"}})

If nOpcA == 1
	Begin Transaction
	If Mod3Grava(1)
		EvalTrigger()
		If __lSX8
			ConfirmSX8()
		Endif
	EndIf
	End Transaction
Else
	If __lSX8
		RollBackSX8()
	Endif
Endif
Return .T.


/*/
———————————————————————————————————————————————————————————————————————————————
@function		ARALTERA                                                      /@
@type				User function                                                 /@
@date				15/11/2010                                                    /@
@description	Altera A.R.                                                   /@
@author			Luiz Fernando                                                 /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function ARAltera( cAlias, nRecNo, nOpc )
Local nOpcA      := 0
Local nX         := 0
Local nCols      := 0
Local oDlg       := Nil

Private aTela    := {}
Private aGets    := {}
Private aHeader  := {}
Private aCols    := {}
Private aAltera  := {}
Private bCampo   := {|nField| FieldName(nField) }
Private lInclui	:= .F.
Private lAltera	:= .T.
Private lExclui	:= .F.


cCliente := ""
nTotal := 0

/* Removido em 07.10.15 por Luiz Fernando solicitado por Viviane Vieira
//———————————————————————————————————————————————————————————————————————————————
// Permito a alteracao somente se a AR não estiver internada, devolvida ou trocada
//———————————————————————————————————————————————————————————————————————————————
if SZG->(!empty(ZG_DTENTRE) .and. !empty(ZG_DTSOLIC) .and. !empty(ZG_DTCOLE) .and. !empty(ZG_DTENTES) .and. !empty(ZG_DTRECUS) .and. !empty(ZG_DTINTER) .and. empty(ZG_DTRETOR) .and. ZG_TIPO == 'R') .or.;
	SZG->(!empty(ZG_DTENTRE) .and. !empty(ZG_DTSOLIC) .and. !empty(ZG_DTCOLE) .and. !empty(ZG_DTENTES) .and. !empty(ZG_DTRECUS) .and. !empty(ZG_DTINTER) .and. empty(ZG_DTRETOR) .and. ZG_TIPO == 'D') .or.;
	SZG->(!empty(ZG_DTENTRE) .and. !empty(ZG_DTSOLIC) .and. !empty(ZG_DTCOLE) .and. !empty(ZG_DTENTES) .and. !empty(ZG_DTRECUS) .and. !empty(ZG_DTINTER) .and. !empty(ZG_DTRETOR) .and. ZG_TIPO == 'R')

	Help(,, "ATENÇÃO",, "A AR não poderá ser alterada, pois já foi internada, ou teve a devolução ou troca finalizada." + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Brasitech)", 1)
	Return()
	
endif
*/
//+----------------------------------
//| Inicia as variaveis para Enchoice
//+----------------------------------
dbSelectArea("SZG")
dbSetOrder(1)
dbGoTo(nRecNo)
For nX := 1 To FCount()
	M->&(Eval(bCampo,nX)) := FieldGet(nX)
Next nX
//IF !EMPTY(SZG->ZG_ESPECIE)
//	MSGINFO("AR COM NOTA FISCAL JÁ DIGITADA: "+SZG->ZG_NFDEVOL+"/"+SZG->ZG_SERIENF+"-"+SZG->ZG_ESPECIE)
//	Return 
//Endif
                                                          
//+----------------
//| Monta o aHeader
//+----------------
CriaHeader()

//+--------------
//| Monta o aCols
//+--------------
dbSelectArea("SZH")
dbSetOrder(1)
dbSeek(xFilial("SZH") + SZG->ZG_NUMERO)

do while !Eof() .And. SZH->ZH_FILIAL == xFilial("SZH") .And. SZH->ZH_NUMERO == SZG->ZG_NUMERO
	
	aAdd(aCols,Array(nUsado+1))
	nCols ++
	
	For nX := 1 To nUsado
		If ( aHeader[nX][10] != "V")
			aCols[nCols][nX] := FieldGet(FieldPos(aHeader[nX][2]))
		Else
			aCols[nCols][nX] := CriaVar(aHeader[nX][2],.T.)
		Endif
	Next nX
	
	aCols[nCols][nUsado+1] := .F.

	aAdd(aAltera,RecNo())
	dbSkip()

Enddo


//———————————————————————————————————————————————————————————————————————————————
// Envia para processamento dos Gets
//———————————————————————————————————————————————————————————————————————————————
DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],aSize[1] TO aSize[6],aSize[5] OF oMainWnd PIXEL
EnChoice( cAlias, nRecNo, nOpc, , , , , aPosObj[1], , 3)

//Retirado por solicitação da Viviane em 29/09/15, para sempre permitir a alteração de itens
//IF EMPTY(SZG->ZG_NFDEVOL)
	oGet := MSGetdados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,,,,.T.)
//Else                       
//	nopc:=2  //não altera os itens depois de gerar a nota fiscal
//	oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,,,,.F.)
//Endif	

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca:=1,If(ValDtEnc() .AND. u_Mod3Tudok().And.Obrigatorio(aGets,aTela),oDlg:End(),nOpca:=0)},{||nOpca:=0,oDlg:End()},,;
{{"RPMOPEN",{|| ChNFOri(M->ZG_CLIENTE,M->ZG_LOJACLI,GDFIELDGET("ZH_PRODUTO"),M->ZG_NUMERO,GDFIELDGET("ZH_ITEM"))},"Seleciona Notas"}})

If nOpcA == 1
	Begin Transaction
	If Mod3Grava(2,aAltera)
		EvalTrigger()
		If __lSX8
			ConfirmSX8()
		Endif
	EndIf
	End Transaction
Else
	If __lSX8
		RollBackSX8()
	Endif
Endif
Return


/*/
———————————————————————————————————————————————————————————————————————————————
@function		AREXCLUI                                                      /@
@type				User function                                                 /@
@date				15/11/2010                                                    /@
@description	Exclui A.R.                                                   /@
@author			Luiz Fernando                                                 /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function ARExclui( cAlias, nRecNo, nOpc )
Local nX        := 0
Local nCols     := 0
Local nOpcA     := 0
Local oDlg      := Nil
Local oGet      := Nil
Local oMainWnd  := Nil

Private aTela   := {}
Private aGets   := {}
Private aHeader := {}
Private aCols   := {}
Private bCampo  := { |nField| Field(nField) }
Private lInclui	:= .F.
Private lAltera	:= .F.
Private lExclui	:= .T.

cCliente := ""
nTotal := 0

//+----------------------------------
//| Inicia as variaveis para Enchoice
//+----------------------------------
dbSelectArea("SZG")
dbSetOrder(1)
dbGoTo(nRecNo)
For nX:= 1 To FCount()
	M->&(Eval(bCampo,nX)) := FieldGet(nX)
Next nX

IF !EMPTY(SZG->ZG_DTINTER)
	MSGINFO("AR COM NOTA FISCAL JÁ INTERNADA: " + SZG->ZG_NFDEVOL + "/" + SZG->ZG_SERIENF)
	Return 
Endif



//+----------------
//| Monta o aHeader
//+----------------
CriaHeader()

//+--------------
//| Monta o aCols
//+--------------
dbSelectArea("SZH")
dbSetOrder(1)
dbSeek(xFilial("SZH") + SZG->ZG_NUMERO)

While !Eof() .And. SZH->ZH_FILIAL == SZG->ZG_FILIAL .And. SZH->ZH_NUMERO == SZG->ZG_NUMERO
	aAdd(aCols,Array(nUsado+1))
	nCols ++
	
	For nX := 1 To nUsado
		If ( aHeader[nX][10] != "V")
			aCols[nCols][nX] := FieldGet(FieldPos(aHeader[nX][2]))
		Else
			aCols[nCols][nX] := CriaVar(aHeader[nX][2],.T.)
		Endif
	Next nX
	
	aCols[nCols][nUsado+1] := .F.
	dbSelectArea("SZH")
	dbSkip()
End

//DEFINE MSDIALOG oDlg TITLE cCadastro From 8,0 TO 28,80  OF oMainWnd
DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],aSize[1] TO aSize[6],aSize[5] OF oMainWnd PIXEL
EnChoice( cAlias, nRecNo, nOpc, , , , , aPosObj[1], , 3)
//EnChoice(cAlias, nRecNo, nOpc,,,,, aPos,, 3)

// Atualizacao do nome do cliente
//@ 136,004 SAY "Cliente: "                                     SIZE 070,7 OF oDlg PIXEL
//@ 136,024 SAY oCliente VAR cCliente                           SIZE 098,7 OF oDlg PIXEL

// Atualizacao do total
//@ 136,240 SAY "Valor Total: "                                 SIZE 070,7 OF oDlg PIXEL
//@ 136,270 SAY oTotal VAR nTotal PICTURE "@E 9,999,999,999.99" SIZE 070,7 OF oDlg PIXEL

//u_Mod3AtuCli()
//oGet := MsGetDados():New(75,2,130,315,nOpc)
oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,,,,.T.)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,Iif(oGet:TudoOk(),oDlg:End(),nOpcA := 0)},{||oDlg:End()})

If nOpcA == 1
	Begin Transaction
	If Mod3Grava(3)
		EvalTrigger()
		If __lSX8
			ConfirmSX8()
		Endif
	EndIf
	End Transaction
Else
	If __lSX8
		RollBackSX8()
	Endif
Endif

Return .T.


/*/
———————————————————————————————————————————————————————————————————————————————
@function		CRIAHEADER                                                    /@
@type				User function                                                 /@
@date				15/11/2010                                                    /@
@description	Cria aheader                                                  /@
@author			Luiz Fernando                                                 /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function CriaHeader()
nUsado  := 0
aHeader := {}
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("SZH")
While ( !Eof() .And. SX3->X3_ARQUIVO == "SZH" )
	If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL )
		aAdd(aHeader,{ Trim(X3Titulo()), ;
							SX3->X3_CAMPO   , ;
							SX3->X3_PICTURE , ;
							SX3->X3_TAMANHO , ;
							SX3->X3_DECIMAL , ;
							SX3->X3_VALID   , ;
							SX3->X3_USADO   , ;
							SX3->X3_TIPO    , ;
							SX3->X3_ARQUIVO , ;
							SX3->X3_CONTEXT } )
		nUsado++
	Endif
	dbSkip()
End
Return


/*/
———————————————————————————————————————————————————————————————————————————————
@function		MOD3TUDOK                                                     /@
@type				User function                                                 /@
@date				15/11/2010                                                    /@
@description	Valida dados na confirmação da manutencao                     /@
@author			Luiz Fernando                                                 /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function Mod3TudOk()
Local lRet				:= .T.
Local nP_Produto		:= aScan(aHeader,{|x| Trim(x[2])=="ZH_PRODUTO"})
Local nP_QtdVen		:= aScan(aHeader,{|x| Trim(x[2])=="ZH_QTDDEVO"})
Local nP_Origem		:= aScan(aHeader,{|x| Trim(x[2])=="ZH_ORIGEM"})
Local nP_SerieOrig	:= aScan(aHeader,{|x| Trim(x[2])=="ZH_SERIE"})
Local nPosDTORIG		:= aScan(aHeader,{|x| AllTrim(x[2])=="ZH_DTORIG"})
Local nPosITEM			:= aScan(aHeader,{|x| AllTrim(x[2])=="ZH_ITEM"})
Local cMsg				:= ""
Local cProduto			:= 0
Local nQtdVen			:= 0
Local cOrigem			:= ""
Local cSerieOrig		:= ""
Local cTitulo			:= "Validação"
Local _cStatus			:= ""
Local lGetSenha		:= .F.
Local aAreaSZG			:= SZG->(GetArea())
Local nI

SZH->(dbSetOrder(1))		//ZH_FILIAL, ZH_NUMERO, ZH_ITEM, ZH_PRODUTO

For nI := 1 To Len(aCols)
	
	If aCols[ni][nUsado+1]
		Loop
	Endif
	
	cProduto		:= aCols[ni][nP_Produto]
	nQtdVen		:= aCols[ni][nP_QtdVen]
	cOrigem		:= aCols[ni][nP_Origem]
	cSerieOrig	:= aCols[ni][nP_SerieOrig]
	
	If Empty(cProduto)
		cMsg := "Campo PRODUTO preenchimento obrigatorio"
		lRet := .F.
	Endif
	
	If nQtdVen == 0 .And. lRet
		cMsg := "Campo QUANTIDADE preenchimento obrigatorio"
		lRet := .F.
	Endif
	
	If M->ZG_ORIGEM == "S"
		dbSelectArea("SD2")
		dbSetOrder(3)
		if !dbSeek(xFilial("SZG")+cOrigem+cSerieOrig+M->ZG_CLIENTE+M->ZG_LOJACLI+cProduto)
			cMsg := "Número da Nota Fiscal de origem não localizado pra esse cliente. NF: ("+alltrim(cOrigem)+"/"+alltrim(cSerieOrig)+"). Produto: "+cProduto
			lRet := .F.
		Endif
	Endif
	
	If !lRet
		//Help("",1,"","Mod3TudOk",cMsg,1,0)
		//Exit
		msgalert(cMsg,cTitulo)
	Endif
	
	//———————————————————————————————————————————————————————————————————————————————
	// Verifico se a data de origem da nota é superior à um ano.
	// 1- Se inclusao de AR, exige senha
	// 2- Se alteracao de AR, e nao localizar o item do AR, significa item novo, 
	//		logo exige senha
	// 3- Se alteracao de AR, e localizar o item e não for mesma nota/serie de origem,
	//		logo houve mudanca, portanto exige senha
	//———————————————————————————————————————————————————————————————————————————————
	if Date() - aCols[nI, nPosDTORIG] > 365 .and. SA1->A1_X_PSWAR != "N"
		
		if lInclui
		
			lGetSenha := .T.
			
		elseif lAltera
		
			if SZH->(!dbSeek(xFilial("SZH") + M->ZG_NUMERO + aCols[nI, nPosITEM] + aCols[nI, nP_Produto]))
			
				lGetSenha := .T.
				
			else
			
				if aCols[nI, nP_Origem] + aCols[nI, nP_SerieOrig] != SZH->ZH_ORIGEM + SZH->ZH_SERIE
				
					lGetSenha := .T.
					
				endif
				
			endif
		
		endif
		
	endif
	
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gravando o campo STATUS                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            
if empty(SZG->ZG_NFDEVOL)      
	_cStatus := "Pré - AR"

elseif !empty(SZG->ZG_NFDEVOL) .and. !empty(M->ZG_DTENTRE) .AND. empty(M->ZG_DTSOLIC)  .AND.  empty(M->ZG_DTCOLE)  .AND.  empty(M->ZG_DTENTES)  .AND.  empty(M->ZG_DTRECUS)  .AND.  empty(M->ZG_DTINTER)  .AND. empty(M->ZG_DTRETOR)
	_cStatus := "AR - Incluída"
	
elseif !empty(SZG->ZG_NFDEVOL) .and. !empty(M->ZG_DTENTRE) .AND. !empty(M->ZG_DTSOLIC) .AND.  empty(M->ZG_DTCOLE)  .AND.  empty(M->ZG_DTENTES)  .AND.  empty(M->ZG_DTRECUS)  .AND.  empty(M->ZG_DTINTER)  .AND. empty(M->ZG_DTRETOR)
	_cStatus := "AR - Solicitada"
	
elseif !empty(SZG->ZG_NFDEVOL) .and. !empty(M->ZG_DTENTRE) .AND. !empty(M->ZG_DTSOLIC) .AND.  !empty(M->ZG_DTCOLE) .AND.  empty(M->ZG_DTENTES)  .AND.  empty(M->ZG_DTRECUS)  .AND.  empty(M->ZG_DTINTER)  .AND. empty(M->ZG_DTRETOR)
	_cStatus := "AR - Coletada"
	
elseif !empty(SZG->ZG_NFDEVOL) .and. !empty(M->ZG_DTENTRE) .AND. !empty(M->ZG_DTSOLIC) .AND.  !empty(M->ZG_DTCOLE) .AND.  !empty(M->ZG_DTENTES) .AND.  empty(M->ZG_DTRECUS)  .AND.  empty(M->ZG_DTINTER)  .AND. empty(M->ZG_DTRETOR)
	_cStatus := "AR - Recebida"
	
elseif !empty(SZG->ZG_NFDEVOL) .and. !empty(M->ZG_DTENTRE) .AND. !empty(M->ZG_DTSOLIC) .AND.  !empty(M->ZG_DTCOLE) .AND.  !empty(M->ZG_DTENTES) .AND.  !empty(M->ZG_DTRECUS) .AND.  empty(M->ZG_DTINTER)  .AND. empty(M->ZG_DTRETOR)
	_cStatus := "AR - Laudo"
	
elseif !empty(SZG->ZG_NFDEVOL) .and. !empty(M->ZG_DTENTRE) .AND. !empty(M->ZG_DTSOLIC) .AND.  !empty(M->ZG_DTCOLE) .AND.  !empty(M->ZG_DTENTES) .AND.  !empty(M->ZG_DTRECUS)  .AND.  !empty(M->ZG_DTINTER) .AND. empty(M->ZG_DTRETOR)  .AND. (ZG_TIPO == 'R')
	_cStatus := "AR - Internada"
	
elseif !empty(SZG->ZG_NFDEVOL) .and. !empty(M->ZG_DTENTRE) .AND. !empty(M->ZG_DTSOLIC) .AND.  !empty(M->ZG_DTCOLE) .AND.  !empty(M->ZG_DTENTES) .AND.  !empty(M->ZG_DTRECUS)  .AND.  !empty(M->ZG_DTINTER) .AND. empty(M->ZG_DTRETOR)  .AND. (ZG_TIPO == 'D')
	_cStatus := "AR - Devol. Finalizada"
	
elseif !empty(SZG->ZG_NFDEVOL) .and. !empty(M->ZG_DTENTRE) .AND. !empty(M->ZG_DTSOLIC) .AND.  !empty(M->ZG_DTCOLE) .AND.  !empty(M->ZG_DTENTES) .AND.  !empty(M->ZG_DTRECUS)  .AND.  !empty(M->ZG_DTINTER) .AND. !empty(M->ZG_DTRETOR) .AND. (ZG_TIPO == 'R')
	_cStatus := "AR - Troca Finalizada"
	
elseif !empty(SZG->ZG_NFDEVOL) .and. empty(M->ZG_DTENTRE) .AND. empty(M->ZG_DTSOLIC) .AND. empty(M->ZG_DTCOLE) .AND. empty(M->ZG_DTENTES) .AND. empty(M->ZG_DTRECUS) .AND. empty(M->ZG_DTINTER) .AND. empty(M->ZG_DTRETOR)
	_cStatus := "AR - Nao Classificada"
	
endif

M->ZG_STATUS := _cStatus


//———————————————————————————————————————————————————————————————————————————————
// Quando o campo da nota fiscal do cliente for preenchido com o número válido, 
// obrigar o preenchimento dos campos série e data de emissão
//———————————————————————————————————————————————————————————————————————————————
if Val(M->ZG_NFDEVOL) > 0 .and. lRet
	if empty(M->ZG_SERIENF) .or. empty(M->ZG_DTDEVOL) .or. empty(M->ZG_QUANTID) .OR. empty(M->ZG_CHVNFE)
		lRet := .F.
		Help(,, "ATENÇÃO",, "Ao informar o campo 'Num NF Devo' com um número válido, é necessário preencher os campo de 'Serie NF', 'Dt.Emis.NF' , 'Volume' e 'Chave NFe' Verifique." + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Brasitech)", 1)
	else
		SZG->(dbSetOrder(2))		//ZG_FILIAL, ZG_CLIENTE, ZG_LOJACLI, ZG_NFDEVOL
		if SZG->(dbSeek(xFilial("SZG") + M->ZG_CLIENTE + M->ZG_LOJACLI + M->ZG_NFDEVOL))
			do while SZG->(!eof() .and. ZG_FILIAL + ZG_CLIENTE + ZG_LOJACLI + ZG_NFDEVOL == xFilial("SZG") + M->ZG_CLIENTE + M->ZG_LOJACLI + M->ZG_NFDEVOL)
				if SZG->ZG_SERIENF == M->ZG_SERIENF
					if lInclui .or. (lAltera .and. SZG->(Recno()) != aAreaSZG[3])
			  			lRet := .F.
						Help(,, "ATENÇÃO",, "O número da nota de devolução já cadastrado para um outro AR do mesmo cliente e loja. Informe outro número." + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Brasitech)", 1)
					endif
				endif
				SZG->(dbSkip())
			enddo
		endif
		RestArea(aAreaSZG)
	endif
endif	


//———————————————————————————————————————————————————————————————————————————————
// Solicita senha caso algum item usado tiver data de emissao superior à 365 dias
//———————————————————————————————————————————————————————————————————————————————
//if lRet .and. lGetSenha   - conforme solicitado remover validaçao com senha - jorge
//	lRet := ValSel()
//endif

Return(lRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		MOD3GRAVA                                                     /@
@type				Static function                                               /@
@date				15/11/2010                                                    /@
@description	Grava dados do A.R.                                           /@
@author			Luiz Fernando                                                 /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function Mod3Grava(nOpc, aAltera)
Local lGravou    	:= .F.
Local nUsado     	:= Len(aHeader) + 1
Local nSeq       	:= 1
Local nX         	:= 0
Local nI				:= 0
Local nP_ValDesp	:= 0
Local nValorTot	:= 0
Local nVlrDesp		:= M->ZG_VLRDESP
Local nP_ValProd	:= aScan(aHeader,{|x| Trim(x[2])=="ZH_PRECTOT"})
Local nP_ValIpi  	:= aScan(aHeader,{|x| Trim(x[2])=="ZH_VLRIPI"})
Local np_valst    := aScan(aHeader,{|x| Trim(x[2])=="ZH_VALST"})
Local nCalcDev		:= 0

Private bCampo := { |nField| FieldName(nField) }


SD2->(dbSetOrder(3))		//D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM
SZG->(dbSetOrder(1))		//ZG_FILIAL, ZG_NUMERO, ZG_EMISSAO, ZG_CLIENTE, ZG_LOJACLI
SZH->(dbSetOrder(1))		//ZH_FILIAL, ZH_NUMERO, ZH_ITEM, ZH_PRODUTO

//———————————————————————————————————————————————————————————————————————————————
// Grava itens quando inclusão
//———————————————————————————————————————————————————————————————————————————————
If nOpc == 1

	//+---------------
	//| Grava os itens
	//+---------------
	dbSelectArea("SZH")
	dbSetOrder(1)
	For nX := 1 To Len(aCols)
		dbSelectArea("SZH")
		
		If !aCols[nX][nUsado]
		
			nValorTot += aCols[nx,nP_ValProd] + aCols[nx,nP_ValIpi] + aCols[nx,nP_Valst]
			
			SZH->(RecLock("SZH",.T.))
			For nI := 1 To Len(aHeader)
				FieldPut(FieldPos(Trim(aHeader[nI,2])),aCols[nX,nI])
			Next nI
			SZH->ZH_FILIAL 	:= xFilial("SZG")
			SZH->ZH_NUMERO    := M->ZG_NUMERO
			SZH->ZH_ITEM   	:= StrZero(nSeq,2)
			SZH->(MsUnLock())
			
			//vrgx-inicio
			if SZH->ZH_REGSD2 > 0

	         SD2->(dbGoTo(SZH->ZH_REGSD2))		//if SD2->D2_FILIAL == xfilial("SD2") .and. SD2->D2_DOC == SZH->ZH_ORIGEM .and. SD2->D2_SERIE == SZH->ZH_SERIE .and. SD2->D2_CLIENTE == M->ZG_CLIENTE .and. SD2->D2_LOJA == M->ZG_LOJACLI .and. SD2->D2_COD == SZH->ZH_PRODUTO .and. SD2->D2_ITEM == SZH->ZH_ITEMORI
//				if SD2->(DbSeek(xfilial("SD2") + SZH->ZH_ORIGEM + SZH->ZH_SERIE + M->ZG_CLIENTE + M->ZG_LOJACLI + SZH->ZH_PRODUTO + SZH->ZH_ITEMORI))
				nCalcDev := SD2->D2_BRQTDEV + SZH->ZH_QTDDEVO
				SD2->(Reclock("SD2",.F.))
				SD2->D2_BRQTDEV	:= nCalcDev
				SD2->(MsUnLock())  
				
//					SZH->(RECLOCK("SZH",.F.))
//					SZH->ZH_REGSD2		:= SD2->(Recno())
//					SZH->(MsUnLock())
		
/*			elseif M->ZG_ORIGEM == "S"
			
				U_GISendMail(	"rodrigo.ramos@gamaitaly.com.br;amoreno@opcaoum.com.br",,;
								 	"Falha na atualização de notas na INCLUSÃO do AR",;
									"Função temporária para identificar a falha na atualização de notas na inclusão do AR. Rotina AR.PRW, linha 1012." + chr(13) + chr(10) +;
									"AR Numero:>" + M->ZG_NUMERO + "<" + chr(13) + chr(10) + chr(13) + chr(10) +;
									"Filial:>" + SD2->(xFilial("SD2")) + "<" + chr(13) + chr(10) +;
									"Doc:>" + SZH->ZH_ORIGEM + "<" + chr(13) + chr(10) +;
									"Serie:>" + SZH->ZH_SERIE  + "<" + chr(13) + chr(10) +;
									"Cliente:>" + M->ZG_CLIENTE + "<" + chr(13) + chr(10) +;
									"Loja:>" + M->ZG_LOJACLI + "<" + chr(13) + chr(10) +;
									"Produto:>" + SZH->ZH_PRODUTO + "<" + chr(13) + chr(10) +;
									"Item:>" + SZH->ZH_ITEMORI + "<" + chr(13) + chr(10) +;
									chr(13) + chr(10) +;
									"Quantidade a somar no campo D2_BRQTDEV: " + AllTrim(Str(SZH->ZH_QTDDEVO)) + chr(13) + chr(10) +;
									"Queries: " + chr(13) + chr(10) +;
									"Select D2_DOC,D2_QUANT, D2_QTDEDEV, D2_BRQTDEV, D2_COD from " + RetSQLName("SD2") + " where D_E_L_E_T_='' and D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE+D2_LOJA + D2_COD + D2_ITEM = '" + xFilial("SD2") + SZH->ZH_ORIGEM + SZH->ZH_SERIE + M->ZG_CLIENTE + M->ZG_LOJACLI + SZH->ZH_PRODUTO + SZH->ZH_ITEMORI + "'" + chr(13) + chr(10) +;
									"Update " + RetSQLName("SD2") + " set D2_BRQTDEV=D2_BRQTDEV+" + AllTrim(Str(SZH->ZH_QTDDEVO)) + " where D_E_L_E_T_='' and D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE+D2_LOJA + D2_COD + D2_ITEM = '"+xFilial("SD2") + SZH->ZH_ORIGEM + SZH->ZH_SERIE + M->ZG_CLIENTE + M->ZG_LOJACLI + SZH->ZH_PRODUTO + SZH->ZH_ITEMORI + "'" + chr(13) + chr(10))
			
			//vrgx-fim
*/
			endif

			nSeq ++
			lGravou := .T.
		Endif
	Next nX
	
	//+------------------
	//| Grava o Cabecalho
	//+------------------
	If lGravou
		dbSelectArea("SZG")
		RecLock("SZG",.T.)
		For nX := 1 To FCount()
			If "FILIAL" $ FieldName(nX)
				FieldPut(nX,xFilial("SZG"))
			Else
				FieldPut(nX,M->&(Eval(bCampo,nX)))
			Endif
		Next nX
		SZG->ZG_X_USUAR	:= cUserName	//SubStr(cUsuario,7,15)
		SZG->ZG_VALOR		:= nValorTot + nVlrDesp
		MsUnLock()
	Endif


//———————————————————————————————————————————————————————————————————————————————
// Grava itens quando alteração
//———————————————————————————————————————————————————————————————————————————————]
elseIf nOpc == 2

	SD2->(dbSetorder(3))
	dbSelectArea("SZH")
	dbSetOrder(1)

	For nX := 1 To Len(aCols)

		if !aCols[nX][nUsado]
			nValorTot += aCols[nx,nP_ValProd] + aCols[nx,nP_ValIpi] + aCols[nx,nP_Valst]
		endif
	   
		//Para registros antigos, altero o conteudo
		if nX <= Len(aAltera)
			
			lGravou 		:= .T.
			dbGoto(aAltera[nX])
			
			//vrgx-inicio 
			//pego a nota anterior, pode ter sido alterada
			if !empty(SZH->ZH_REGSD2)  //ISSO GARANTE QUE FOI GRAVADO NO SD2
				SD2->(dbGoto(SZH->ZH_REGSD2))
				SD2->(RecLock("SD2",.F.))
				SD2->D2_BRQTDEV	-= SZH->ZH_QTDDEVO
				SD2->(MsUnlock())
			endif
			//vrgx-fim

			nSeq := iif(Val(SZH->ZH_ITEM) > nSeq, Val(SZH->ZH_ITEM), nSeq)
			
			if aCols[nX,nUsado]		//registro excluido?
			
				SZH->(RecLock("SZH",.F.))
				SZH->(dbDelete())
				SZH->(MsUnlock())
				
			else
			
				SZH->(RecLock("SZH",.F.))
				For nI := 1 To Len(aHeader)
					SZH->(FieldPut(FieldPos(Trim(aHeader[nI,2])), aCols[nX,nI]))
				Next nI
				SZH->(MsUnlock())
				
				if !empty(SZH->ZH_REGSD2)  //ISSO GARANTE QUE FOI GRAVADO NO SD2
					SD2->(dbGoto(SZH->ZH_REGSD2))
					SD2->(RecLock("SD2",.F.))
					SD2->D2_BRQTDEV	+= SZH->ZH_QTDDEVO
					SD2->(MsUnlock())
				endif

			endif
			
		else

			if !aCols[nX,nUsado]		//registro não excluido?

				lGravou 				:= .T.
				nSeq ++
				
				SZH->(RecLock("SZH",.T.))
				For nI := 1 To Len(aHeader)
					SZH->(FieldPut(FieldPos(Trim(aHeader[nI,2])),aCols[nX,nI]))
				Next nI
				SZH->ZH_FILIAL 	:= xFilial("SZH")
				SZH->ZH_NUMERO   	:= M->ZG_NUMERO
				SZH->ZH_ITEM   	:= StrZero(nSeq,2)
				SZH->(MsUnlock())

				if SZH->ZH_REGSD2 > 0
		         SD2->(dbGoTo(SZH->ZH_REGSD2))		//if SD2->D2_FILIAL == xfilial("SD2") .and. SD2->D2_DOC == SZH->ZH_ORIGEM .and. SD2->D2_SERIE == SZH->ZH_SERIE .and. SD2->D2_CLIENTE == M->ZG_CLIENTE .and. SD2->D2_LOJA == M->ZG_LOJACLI .and. SD2->D2_COD == SZH->ZH_PRODUTO .and. SD2->D2_ITEM == SZH->ZH_ITEMORI
	//				if SD2->(DbSeek(xfilial("SD2") + SZH->ZH_ORIGEM + SZH->ZH_SERIE + M->ZG_CLIENTE + M->ZG_LOJACLI + SZH->ZH_PRODUTO + SZH->ZH_ITEMORI))
					nCalcDev := SD2->D2_BRQTDEV + SZH->ZH_QTDDEVO
					SD2->(Reclock("SD2",.F.))
					SD2->D2_BRQTDEV	:= nCalcDev
					SD2->(MsUnLock())  
					
//					SZH->(RECLOCK("SZH",.F.))
//					SZH->ZH_REGSD2		:= SD2->(Recno())
//					SZH->(MsUnlock())
				endif
		
				SZH->(MsUnlock())
				
			endif

		endif

	Next nX

	//+------------------
	//| Grava o Cabecalho
	//+------------------
	dbSelectArea("SZG")
	
	If lGravou

		SZG->(RecLock("SZG",.F.))
		For nX := 1 To SZG->(FCount())
			If "FILIAL" $ SZG->(FieldName(nX))
				SZG->(FieldPut(nX, xFilial("SZG")))
			Else
				SZG->(FieldPut(nX,M->&(Eval(bCampo,nX))))
			Endif
		Next
		If ZG_EMISSAO >= sTOd("20120101")
			SZG->ZG_VALOR   := nValorTot + nVlrDesp
		Endif
		SZG->(MsUnLock())
		
	Else

		//vrgx-inicio
		if SD2->(DbSeek(xFilial("SD2") + SZH->ZH_ORIGEM + SZH->ZH_SERIE + M->ZG_CLIENTE + M->ZG_LOJACLI + SZH->ZH_PRODUTO + SZH->ZH_ITEMORI))
			SD2->(Reclock("SD2",.F.))
			SD2->D2_BRQTDEV -= SZH->ZH_QTDDEVO
			SD2->(MsUnlock())
			
			dbSelectArea("SZH")
			SZH->(RecLock("SZH",.F.))
			SZH->ZH_REGSD2	:= 0
			SZH->(MsUnlock())
			
		elseif M->ZG_ORIGEM == "S"
		
			U_GISendMail(	"rodrigo.ramos@gamaitaly.com.br;amoreno@opcaoum.com.br",,;
							 	"Falha na atualização de notas na ALTERAÇÃO do AR",;
								"Função temporária para identificar a falha na atualização de notas na alteração do AR. Rotina AR.PRW, linha 1178." + chr(13) + chr(10) +;
								"AR Numero:>" + M->ZG_NUMERO + "<" + chr(13) + chr(10) + chr(13) + chr(10) +;
								"Filial:>" + SD2->(xFilial("SD2")) + "<" + chr(13) + chr(10) +;
								"Doc:>" + SZH->ZH_ORIGEM + "<" + chr(13) + chr(10) +;
								"Serie:>" + SZH->ZH_SERIE  + "<" + chr(13) + chr(10) +;
								"Cliente:>" + M->ZG_CLIENTE + "<" + chr(13) + chr(10) +;
								"Loja:>" + M->ZG_LOJACLI + "<" + chr(13) + chr(10) +;
								"Produto:>" + SZH->ZH_PRODUTO + "<" + chr(13) + chr(10) +;
								"Item:>" + SZH->ZH_ITEMORI + "<" + chr(13) + chr(10) +;
								chr(13) + chr(10) +;
								"Quantidade a abater do campo D2_BRQTDEV: " + AllTrim(Str(SZH->ZH_QTDDEVO)) + chr(13) + chr(10) +;
								"Queries: " + chr(13) + chr(10) +;
								"Select D2_DOC,D2_QUANT, D2_QTDEDEV, D2_BRQTDEV, D2_COD from " + RetSQLName("SD2") + " where D_E_L_E_T_='' and D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE+D2_LOJA + D2_COD + D2_ITEM = '" + xFilial("SD2") + SZH->ZH_ORIGEM + SZH->ZH_SERIE + M->ZG_CLIENTE + M->ZG_LOJACLI + SZH->ZH_PRODUTO + SZH->ZH_ITEMORI + "'" + chr(13) + chr(10) +;
								"Update " + RetSQLName("SD2") + " set D2_BRQTDEV=D2_BRQTDEV-" + AllTrim(Str(SZH->ZH_QTDDEVO)) + " where D_E_L_E_T_='' and D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE+D2_LOJA + D2_COD + D2_ITEM = '"+xFilial("SD2") + SZH->ZH_ORIGEM + SZH->ZH_SERIE + M->ZG_CLIENTE + M->ZG_LOJACLI + SZH->ZH_PRODUTO + SZH->ZH_ITEMORI + "'" + chr(13) + chr(10))
								
		Endif
		//vrgx-fim
		
		dbSelectArea("SZG")
		SZG->(RecLock("SZG",.F.))
		SZG->(dbDelete())
		SZG->(MsUnLock())
		
	Endif



//———————————————————————————————————————————————————————————————————————————————
// Atualiza tabelas quando exclusão
//———————————————————————————————————————————————————————————————————————————————
elseIf nOpc == 3

	SZH->(dbSeek(xFilial("SZH") + M->ZG_NUMERO))

	do while SZH->(!eof() .And. ZH_FILIAL == xFilial("SZH") .and. ZH_NUMERO == M->ZG_NUMERO)

		//vrgx-inicio
	//		if SD2->(dbSeek(xFilial("SD2") + SZH->ZH_ORIGEM + SZH->ZH_SERIE + M->ZG_CLIENTE + M->ZG_LOJACLI + SZH->ZH_PRODUTO + SZH->ZH_ITEMORI))
	
		if SZH->ZH_REGSD2 > 0
			SD2->(dbGoTo(SZH->ZH_REGSD2))
			nCalcDev := SD2->D2_BRQTDEV - SZH->ZH_QTDDEVO
			SD2->(Reclock("SD2",.F.))
			SD2->D2_BRQTDEV	:= iif(nCalcDev < 0, 0, nCalcDev)
			SD2->(MsUnLock())
			
/*		elseif M->ZG_ORIGEM == "S"
		
			U_GISendMail(	"rodrigo.ramos@gamaitaly.com.br;amoreno@opcaoum.com.br",,;
							 	"Falha na atualização de notas na exclusão do AR",;
								"Função temporária para identificar a falha na atualização de notas na exclusão do AR. Rotina AR.PRW, linha 1223." + chr(13) + chr(10) +;
								"AR Numero:>" + M->ZG_NUMERO + "<" + chr(13) + chr(10) + chr(13) + chr(10) +;
								"Filial:>" + SD2->(xFilial("SD2")) + "<" + chr(13) + chr(10) +;
								"Doc:>" + SZH->ZH_ORIGEM + "<" + chr(13) + chr(10) +;
								"Serie:>" + SZH->ZH_SERIE  + "<" + chr(13) + chr(10) +;
								"Cliente:>" + M->ZG_CLIENTE + "<" + chr(13) + chr(10) +;
								"Loja:>" + M->ZG_LOJACLI + "<" + chr(13) + chr(10) +;
								"Produto:>" + SZH->ZH_PRODUTO + "<" + chr(13) + chr(10) +;
								"Item:>" + SZH->ZH_ITEMORI + "<" + chr(13) + chr(10) +;
								chr(13) + chr(10) +;
								"Quantidade a abater do campo D2_BRQTDEV: " + AllTrim(Str(SZH->ZH_QTDDEVO)) + chr(13) + chr(10) +;
								"Queries: " + chr(13) + chr(10) +;
								"Select D2_DOC,D2_QUANT, D2_QTDEDEV, D2_BRQTDEV, D2_COD from " + RetSQLName("SD2") + " where D_E_L_E_T_='' and D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE+D2_LOJA + D2_COD + D2_ITEM = '" + xFilial("SD2") + SZH->ZH_ORIGEM + SZH->ZH_SERIE + M->ZG_CLIENTE + M->ZG_LOJACLI + SZH->ZH_PRODUTO + SZH->ZH_ITEMORI + "'" + chr(13) + chr(10) +;
								"Update " + RetSQLName("SD2") + " set D2_BRQTDEV=D2_BRQTDEV-" + AllTrim(Str(SZH->ZH_QTDDEVO)) + " where D_E_L_E_T_='' and D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE+D2_LOJA + D2_COD + D2_ITEM = '"+xFilial("SD2") + SZH->ZH_ORIGEM + SZH->ZH_SERIE + M->ZG_CLIENTE + M->ZG_LOJACLI + SZH->ZH_PRODUTO + SZH->ZH_ITEMORI + "'" + chr(13) + chr(10))
*/
		endif
		//vrgx-fim

		SZH->(RecLock("SZH", .F.))
		SZH->(dbDelete())
		SZH->(MsUnLock())
		SZH->(dbSkip())
		
	enddo
	
	SZG->(RecLock("SZG", .F.))
	SZG->(dbDelete())
	SZG->(MsUnLock())

	lGravou := .T.

endif

	
dbSelectArea("SZG")
Return(lGravou)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		VALDTENC                                                      /@
@type				Static function                                               /@
@date				                                                              /@
@description	                                                              /@
@author			Vescio Pereira de Moura                                       /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function ValDtEnc()

Local lRet := .T.

if !Empty (M->ZG_DTRECUS) .AND. Empty (M->ZG_DTENTES)
	Alert ("Favor Preencher a Data de Recebimento")
	Return .F.
	
Elseif !Empty (M->ZG_DTINTER) .AND. Empty(M->ZG_DTRECUS)
	Alert ("Favor Preencher a Data de Laudo e Recebimento")
	Return .F.
	
Elseif !Empty (M->ZG_DTRETOR) .AND. Empty(M->ZG_DTINTER)
	Alert ("Favor Preencher a Data de Retorno")
	Return .F.
	
Elseif !Empty (M->ZG_DTRETOR) .AND. M->ZG_TIPO == 'D'
	Alert ("O Tipo de Devolução deve ser R= C/Reposição")
	Return .F.
	
Endif

Return lRet


/*/
———————————————————————————————————————————————————————————————————————————————
@function		NFORI                                                         /@
@type				Static function                                               /@
@date				                                                              /@
@description	                                                              /@
@author			Vescio Pereira de Moura                                       /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function NFOri(cCliente, cloja, cProduto, _numar, _itemar)
local cArea			:= GetNextAlias()
Local aRet			:= {}
Local _AREA			:= GetArea()
Local _cFilial		:= xfilial("SZG")
Local aPosobj, ainfosize, aobjects, asizeaut, _QTDAR
Private acols		:= {}
Private aHeader	:= {}
Private N			:= 1
Private aRetSZW	:= {}
Private _nopcao	:= 0


aRet		:= {}
aSizeAut := MsAdvSize(,.F.,400)
aObjects := {}
aAdd(aObjects, {100, 100, .T., .T.}) //GETDADOS
aInfo 	:= {aSizeAut[1], aSizeAut[2], aSizeAut[3], aSizeAut[4], 3, 3}
aPosObj	:= MsObjSize(aInfo, aObjects)

// NAO ALTERAR A ORDEM DOS CAMPOS DA POSICAO 1 ATÉ 17
aAdd( aHeader, {"Nota Fiscal",		"NFISCAL", 	"@!",					09, 0, ".F.", "û", "C", "  ", "V"} )
aAdd( aHeader, {"Serie",				"serie", 	"@!",					03, 0, ".F.", "û", "C", "  ", "V"} )
aAdd( aHeader, {"Item",					"item", 		"@!",					03, 0, ".F.", "û", "C", "  ", "V"} )
aAdd( aHeader, {"Emissao",				"emissao", 	"@!",					08, 0, ".F.", "û", "D", "  ", "V"} )
aAdd( aHeader, {"Saldo",				"saldo", 	"@E 9,999,999",	12, 0, ".F.", "û", "N", "  ", "V"} )
aAdd( aHeader, {"Preco Unitario",	"PRCUNIT", 	"@E 9,999,999.99",10, 2, ".F.", "û", "N", "  ", "V"} )
aAdd( aHeader, {"Alq.IPI",				"ALQIPI",	"@E 99",				02, 0, ".F.", "û", "N", "  ", "V"} )
aAdd( aHeader, {"Alq.ICMS",			"ALQICM", 	"@E 99.99",			05, 2, ".F.", "û", "N", "  ", "V"} )
aAdd( aHeader, {"Valor IPI",			"VALIPI", 	"@E 999,999.99",	12, 2, ".F.", "û", "N", "  ", "V"} )
aAdd( aHeader, {"Valor ICMS",			"VALICM", 	"@E 999,999.99",	12, 2, ".F.", "û", "N", "  ", "V"} )
aAdd( aHeader, {"Base de ICMS",		"BASEICMS", "@E 999,999.99",	12, 2, ".F.", "û", "N", "  ", "V"} )
aAdd( aHeader, {"Base ICMS ST",		"BASEST", 	"@E 999,999.99",	12, 2, ".F.", "û", "N", "  ", "V"} )
aAdd( aHeader, {"ICMS ST",				"ICMSST", 	"@E 999,999.99",	12, 2, ".F.", "û", "N", "  ", "V"} )
aAdd( aHeader, {"Base IPI",			"BASEIPI", 	"@E 999,999.99",	12, 2, ".F.", "û", "N", "  ", "V"} )
aAdd( aHeader, {"Quantidade",			"QTDVEN", 	"@E 999,999.99",	12, 2, ".F.", "û", "N", "  ", "V"} )
aAdd( aHeader, {"Produto",				"produto", 	"@!",					15, 0, ".F.", "û", "C", "  ", "V"} )
aAdd( aHeader, {"Nro Controle",		"nSD2Rec",	"9999999999",		10, 0, ".F.", "û", "C", "  ", "V"} )
	aAdd( aHeader, {"TES",					"cTES", 		"@!",					03, 0, ".F.", "û", "C", "  ", "V"} )
	aAdd( aHeader, {"Finalidade",			"cFinalid",	"@!",					40, 0, ".F.", "û", "C", "  ", "V"} )


//NÃO VOU CONSIDERAR A PRÓPRIA NOTA.
//SE QUISER QUE A PROPRIA NOTA APARECA NOVAMENTE, DEVE EXCLUIR O ITEM SALVAR E ENTRAR NOVAMENTE PARA ALTERAR;
dbSelectArea("SZH")
DbSetorder(1)
DbSeek(xfilial()+_numar+_itemar)
_qtdar:=SZH->ZH_QTDDEVO   //SOMO A QUANTIDADE QUE ESTÁ NA AR  

	_cQuery  := "SELECT D2_BASEIPI,D2_IPI,D2_PICM,D2_BRICMS,D2_ICMSRET,D2_BASEICM,D2_VALICM,D2_VALIPI,D2_DOC,D2_ITEM,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_EMISSAO,D2_COD,D2_QUANT,D2_QUANT-D2_QTDEDEV-(D2_BRQTDEV-D2_QTDEDEV) AS SALDO,D2_PRCVEN,D2_TES,SUBSTRING(F4_FINALID,1,40) F4_FINALID, SD2.R_E_C_N_O_ SD2RECNO " 
	_cQuery  += "FROM " + RetSqlName("SD2") + " SD2, " + RetSqlName("SF4") + " SF4 "
	_cQuery  += "WHERE D2_FILIAL+D2_CLIENTE+D2_LOJA = '"+_CFILIAL+CCLIENTE+CLOJA+"' AND D2_COD = '"+CPRODUTO+"' AND D2_QUANT-D2_QTDEDEV+D2_BRQTDEV+"+ALLTRIM(STR(_QTDAR))+" > 0 "
	_cQuery  += "AND D2_TIPO = 'N' "
	_cQuery  += "AND SD2.D_E_L_E_T_ <> '*' "
	_cQuery  += "AND SF4.F4_FILIAL = '"+xFilial("SF4")+"' "
	_cQuery  += "AND SF4.F4_CODIGO = SD2.D2_TES "
	_cQuery  += "AND SF4.D_E_L_E_T_ <> '*' "
	
	_cQuery  += "ORDER BY D2_EMISSAO, D2_DOC, D2_SERIE"
	//Processa a Query principal (do processamento)
	TCQUERY _cQuery NEW ALIAS (CAREA)

/*


BEGINSQL ALIAS CAREA
	SELECT D2_BASEIPI,D2_IPI,D2_PICM,D2_BRICMS,D2_ICMSRET,D2_BASEICM,D2_VALICM,D2_VALIPI,D2_DOC,D2_ITEM,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_EMISSAO,D2_COD,D2_QUANT,D2_QUANT-D2_QTDEDEV-D2_BRQTDEV AS SALDO,D2_PRCVEN FROM %table:SD2% SD2
	WHERE D2_FILIAL+D2_CLIENTE+D2_LOJA = %EXP:_CFILIAL+CCLIENTE+CLOJA% AND D2_COD = %EXP:CPRODUTO% AND D2_QUANT-D2_QTDEDEV-D2_BRQTDEV+%SZH->(ZH_QTDDEVO)% > 0 AND D2_TIPO = "N" AND SD2.%NotDel%
	ORDER BY D2_FILIAL,D2_EMISSAO,D2_DOC,D2_SERIE
ENDSQL
/*/

TcSetField(CAREA,"D2_QUANT",	 "N", 12, 2)
TcSetField(CAREA,"SALDO",		 "N", 12, 2)
TcSetField(CAREA,"D2_PRCVEN",	 "N", 12, 2)
TcSetField(CAREA,"D2_IPI",		 "N", 02, 0)
TcSetField(CAREA,"D2_PICM",	 "N", 05, 2)
TcSetField(CAREA,"D2_VALIPI",	 "N", 12, 2)
TcSetField(CAREA,"D2_VALICM",	 "N", 12, 2)
TcSetField(CAREA,"D2_BASEICM", "N", 12, 2)
TcSetField(CAREA,"D2_BRICM",	 "N", 12, 2)
TcSetField(CAREA,"D2_ICMSRET", "N", 12, 2)
TcSetField(CAREA,"D2_BASEIPI", "N", 12, 2)
TcSetField(CAREA,"D2_EMISSAO", "D", 08, 0)
TcSetField(CAREA,"SD2RECNO", 	 "N", 10, 0)

dbSelectArea(carea)
DbGotop()
While !eof()
	nCols:={}
	_SALDO:=(cArea)->SALDO		//+SZH->ZH_QTDDEVO   //SOMO A QUANTIDADE QUE ESTÁ NA AR - (Retirada a soma do ZH_QTDDEVO pois ocasiona inconsistencia na alteracao. em 9/5/16 por Adalberto
	aAdd(aCols,{	(cArea)->D2_DOC,;
						(CAREA)->D2_SERIE,;
						(CAREA)->D2_ITEM,;
						(carea)->D2_EMISSAO,;
						_SALDO,;
						(CAREA)->D2_PRCVEN,;
						(CAREA)->D2_IPI,;
						(CAREA)->D2_PICM,;
						((CAREA)->D2_VALIPI/(cArea)->D2_QUANT)*_SALDO,;
						((CAREA)->D2_VALICM/(carea)->D2_QUANT)*_SALDO,;
						((CAREA)->D2_BASEICM/(CAREA)->D2_QUANT)*_SALDO,;
						((CAREA)->D2_BRICMS/(CAREA)->D2_QUANT)*_SALDO,;
						((CAREA)->D2_ICMSRET/(CAREA)->D2_QUANT)*_SALDO,;
						((CAREA)->D2_BASEIPI/(CAREA)->D2_QUANT)*_SALDO,;
						(cArea)->D2_QUANT,;
						(cArea)->D2_COD,;
						(CAREA)->SD2RECNO,;
						(CAREA)->D2_TES,;
						(CAREA)->F4_FINALID,;
						.F.})
	DbSkip()
Enddo

DbClosearea(carea)
dbSelectArea("SD2")
DEFINE MSDIALOG oDlg FROM  ASIZEAUT[7],0 To ASIZEAUT[6],ASIZEAUT[5] OF oMainWnd  PIXEL TITLE OemToAnsi("Nota Fiscal de Origem")
oGet := MSGETDADOS():NEW(APOSOBJ[1,1]+50,APOSOBJ[1,2],APOSOBJ[1,3],APOSOBJ[1,4],2,"U_ESTC12L",,,,,,,,,,,,)
//ACTIVATE MSDIALOG oDlg CENTERED  ON INIT EnchoiceBar(oDlg,{||IF(valsel(acols[N]),EVAL({||aRetszw:=retSZW(ACOLS[N],_CFILIAL),_nopcao:=1,ODLG:END()}),.F.)},{||oDlg:End()})
ACTIVATE MSDIALOG oDlg CENTERED  ON INIT EnchoiceBar(oDlg, {||EVAL({|| aRetszw := RetSZW(aCols[N],_cFilial), _nOpcao:=1, ODLG:END()})}, {||oDlg:End()})

RESTAREA(_AREA)

//———————————————————————————————————————————————————————————————————————————————
// Preparando o retorno. Inicializo a variável aRet com o conteúdo vazio e caso
// seja escolhido o confirmar e o SALDO seja maior que zero, igualo aRet com o
// aCols e aRetSZW.
// Se o SALDO for menor ou igual a zero, e o usuario confirmou o uso do registro
// emite mensagem de inconsistencia e retorno o aRet padrão
//———————————————————————————————————————————————————————————————————————————————
aRet	:= {{},{}}
if _nOpcao == 1
	if aCols[n, 5] <= 0
		Help(,, "ATENÇÃO",, "O item escolhido possui não possui saldo disponível para retorno. Escolha outro item!" + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Brasitech)", 1)
	else
		aRet 	:= {aCols[n], aRetSZW}
	endif
endif
	
Return(aRet)

/*/
———————————————————————————————————————————————————————————————————————————————
@function		CHNFORI                                                       /@
@type				Static function                                               /@
@date				                                                              /@
@description	                                                              /@
@author			Vescio Pereira de Moura                                       /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static function ChNFOri(cCliente, cLoja, cProduto, cNumAR, cItemAR)
Local aArea			:= GetArea()
Local nPosREGSD2	:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "ZH_REGSD2"})
Local N1				:= N
Local aRet, f4

if M->ZG_ORIGEM == "S"
  
	if Empty(aCols[n, nPosREGSD2])

		//f4:=setkey(VK_F4)  //DESABILITA F4
		aRet 	:= nfori(cCliente, cLoja, cProduto, cNumAR, cItemAR)
		N		:= N1 //O N DEVE SER PUBLICO. NAO SEI PORQUE, MESMO DECLARANDO ELE COMO PRIVATE DENTRO DA FUNÇÃO ELE RETORNA COM O ULTIMO CONTEUDO
		
		if aRet != NIL
		
			if len(aRet[1]) > 0
				GdFieldPut("ZH_ORIGEM",		aret[1,1])
				GdFieldPut("ZH_SERIE",		aret[1,2])
				GdFieldPut("ZH_ITEMORI",	aret[1,3])
				GdFieldPut("ZH_QTDDEVO",	aret[1,5])  //SALDO A DEVOLVER
				GdFieldPut("ZH_PRECONF",	aret[1,6])
				GdFieldPut("ZH_PRECTOT",	aret[1,5]*ARET[1,6])
				GdFieldPut("ZH_DTORIG",		aret[1,4])
				GdFieldPut("ZH_ALIQIPI",	aret[1,7])
				GdFieldPut("ZH_VLRIPI",		aret[1,9])
				GdFieldPut("ZH_ICM",			iif(Empty(aRet[1,11]), 0, aRet[1,8]))
				GdFieldPut("ZH_VALICM",		aret[1,10])
				GdFieldPut("ZH_BASEICM",	aret[1,11])
				GdFieldPut("ZH_BASEST",		aret[1,12])
				GdFieldPut("ZH_VALST",		aret[1,13])
				GdFieldPut("ZH_BASEIPI",	aret[1,14])
				GdFieldPut("ZH_REGSD2",		aret[1,17])		//Recno do SD2
				M->ZH_QTDDEVO	:= GDFIELDGET("ZH_QTDDEVO")
				U_VLDQTD()
				RUNTRIGGER(2,N,,,"ZH_QTDDEVO")
				RUNTRIGGER(2,N,,,"ZH_ORIGEM")
			Endif
			if len(aRet[2]) > 0
				GdFieldPut("ZH_DOCOPER",	aret[2,15])
				GdFieldPut("ZH_SEROPER",	aret[2,16])
				GdFieldPut("ZH_EMISSAO",	aret[2,4])
				GdFieldPut("ZH_ITOPER",		aret[2,3])
				GdFieldPut("ZH_OPVLUN",		aret[2,11])
				GdFieldPut("ZH_OPALIPI",	aret[2,5])
				GdFieldPut("ZH_OPVLIPI",	aret[2,7])
				GdFieldPut("ZH_OPALICM",	aret[2,6])
				GdFieldPut("ZH_OPVLICM",	aret[2,8])
				GdFieldPut("ZH_OPBCST",		aret[2,9])
				GdFieldPut("ZH_OPVLST",		aret[2,10])
				GdFieldPut("ZH_OPCST",		aret[2,12])
				GdFieldPut("ZH_OPCFOP",		aret[2,13])
				GdFieldPut("ZH_OPBCICM",	aret[2,14])
	
			Endif
		endif
		//SETKEY(VK_F4,F4)  //REABILITA F4
		Restarea(aArea)
		
	else

		MsgInfo("Não é possível alterar a origem de um registro que já tiver sido registrado. Exclua o item e inclua um novo!")

	endif

Else

	msginfo("Origem não habilitada!")

Endif
Return

/*/
———————————————————————————————————————————————————————————————————————————————
@function		RETSZW                                                        /@
@type				Static function                                               /@
@date				                                                              /@
@description	                                                              /@
@author			Vescio Pereira de Moura                                       /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static function RETSZW(ACOLS,_CFILIAL)
Local cAreaSZW		:= GETNEXTALIAS()
Local _aColSZW		:= {}
Local cNota			:= acols[1]
Local cSerie		:= acols[2]
Local cProduto		:= acols[16]

BEGINSQL ALIAS cAREASZW
	SELECT  ZW_CFOP,ZW_VLIPI,ZW_CST,ZW_QUANT,ZW_ALIPI,ZW_ALICMS,ZW_BCST,ZW_VLST,ZW_BCICMS,ZW_VLICMS,ZW_DOCGAMA,ZW_ITEM,ZW_SERGAMA,ZW_EMISSAO,ZW_VLUNIT,ZW_DOC,ZW_SERIE FROM %table:SZW% SZW
	WHERE ZW_FILIAL+ZW_DOCGAMA+ZW_SERGAMA+ZW_PRODUTO = %EXP:_cfilial+CNota+cSerie+cProduto% AND SZW.%NotDel%
ENDSQL
TcSetField(cAREASZW,"ZW_EMISSAO","D",8,0)
TcSetField(cAREASZW,"ZW_ALIPI","N",2,0)
TcSetField(cAREASZW,"ZW_ALICM","N",5,2)
TcSetField(cAREASZW,"ZW_VLIPI","N",12,2)
TcSetField(cAREASZW,"ZW_QUANT","N",12,2)
TcSetField(cAREASZW,"ZW_VLICMS","N",12,2)
TcSetField(cAREASZW,"ZW_BCST","N",12,2)
TcSetField(cAREASZW,"ZW_VLST","N",12,2)
TcSetField(cAREASZW,"ZW_BCICMS","N",12,2)


dbSelectArea(cAreaSZW)
DbGotop()   //TEM QUE TER UM ITEM SÓ, DEVE SER UM PARA UM ENTRE O SD2 E SZW
//While !eof()
//	nCols:={}
aAdd(_ACOLSzw,{(cAREASZW)->ZW_DOCGAMA,;
					(cAREASZW)->ZW_SERGAMA,;
					(CAREASZW)->ZW_ITEM,;
					(careaSZW)->ZW_EMISSAO,;
					(CAREASZW)->ZW_ALIPI,;
					(CAREASZW)->ZW_ALICMS,;
					((CAREASZW)->ZW_VLIPI/(cAreaSZW)->ZW_QUANT)*ACOLS[5],;
					((CAREASZW)->ZW_VLICMS/(careaSZW)->ZW_QUANT)*ACOLS[5],;
					((CAREASZW)->ZW_BCST/(CAREASZW)->ZW_QUANT)*ACOLS[5],;
					((CAREASZW)->ZW_VLST/(CAREASZW)->ZW_QUANT)*ACOLS[5],;
					(cAreaSZW)->ZW_VLUNIT,;
					(cAreaSZW)->ZW_CST,;
					(cAreaSZW)->ZW_CFOP,;
					((cAreaSZW)->ZW_BCICMS/(CAREASZW)->ZW_QUANT)*ACOLS[5],;
					(cAreaSZW)->ZW_DOC,;
					(cAreaSZW)->ZW_SERIE,;
					.f.})
//	DbSkip()
//Enddo
Dbclosearea()
Return _acolszw[1]

/*/
———————————————————————————————————————————————————————————————————————————————
@function		VLDQTD                                                        /@
@type				Static function                                               /@
@date				                                                              /@
@description	                                                              /@
@author			Vescio Pereira de Moura                                       /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function VLDQTD()
LOCAL _baseipi := GdFieldGet("ZH_BASEIPI")
Local _Vlipiw	:= GdFieldGet("ZH_OPVLIPI")
Local _vlipi	:= GdFieldGet("ZH_VLRIPI")
Local _QUANT	:= GdFieldGet("ZH_QTDDEVO")
Local _BCSTW	:= GdFieldGet("ZH_OPBCST")
Local _BCST		:= GdFieldGet("ZH_BASEST")
Local _VALSTW	:= GdFieldGet("ZH_OPVLST")
	Local _VALST	:= GdFieldGet("ZH_VALST")
LOCAL _baseicm	:= GdFieldGet("ZH_BASEICM")
Local _Vlicmw	:= GdFieldGet("ZH_OPVLICM")
Local _vlicm	:= GdFieldGet("ZH_VALICM")
Local _OPBCICM	:= GdFieldGet("ZH_OPBCICM")
Local _area		:= GetArea()
Local _ret		:= iif(M->ZG_ORIGEM == "S", .F., .T.)

dbSelectArea("SZH")
DbSetorder(1)
DbSeek(xfilial()+M->ZG_NUMERO+GdFieldGet("ZH_ITEM"))
dbSelectArea("SA1")
DbSetorder(1)
DbSeek(xfilial()+M->ZG_CLIENTE+M->ZG_LOJACLI)
dbSelectArea("SD2")
DbSetorder(3)
IF DbSeek(xfilial()+GdFieldGet("ZH_ORIGEM")+GdFieldGet("ZH_SERIE")+M->ZG_CLIENTE+M->ZG_LOJACLI+GdFieldGet("ZH_PRODUTO")+GdFieldGet("ZH_ITEMORI"))
   //	_SALDO:=SD2->(D2_QUANT-D2_QTDEDEV-D2_BRQTDEV)+SZH->ZH_QTDDEVO
	_SALDO:= SD2->(D2_QUANT-D2_QTDEDEV-(D2_BRQTDEV-D2_QTDEDEV)) + SZH->ZH_QTDDEVO
	IF M->ZH_QTDDEVO > _SALDO
		MSGINFO("Quantidade Invalida!")
		_ret:=.f.
	Else
		_ret:=.t.
	Endif
Endif

IF _RET

	GdFieldPut("ZH_OPBCST",(_BCSTW/_QUANT)*M->ZH_QTDDEVO)
	GdFieldPut("ZH_BASEST",(_BCST/_QUANT)*M->ZH_QTDDEVO)
	GdFieldPut("ZH_OPVLST",(_VALSTW/_QUANT)*M->ZH_QTDDEVO)
		GdFieldPut("ZH_VALST",(_VALST/_QUANT)*M->ZH_QTDDEVO)
	GdFieldPut("ZH_BASEIPI",(_BASEIPI/_QUANT)*M->ZH_QTDDEVO)
	GdFieldPut("ZH_OPVLIPI",(_VLIPIW/_QUANT)*M->ZH_QTDDEVO)
	GdFieldPut("ZH_VLRIPI",(_VLIPI/_QUANT)*M->ZH_QTDDEVO)
	GdFieldPut("ZH_BASEICM",(_BASEICM/_QUANT)*M->ZH_QTDDEVO)
	GdFieldPut("ZH_VALICM",(_VLICM/_QUANT)*M->ZH_QTDDEVO)
	GdFieldPut("ZH_OPVLICM",(_VLICMW/_QUANT)*M->ZH_QTDDEVO)
	GdFieldPut("ZH_OPBCICM",(_OPBCICM/_QUANT)*M->ZH_QTDDEVO)
	
	If SA1->A1_SIMPLES = "1"
		GdFieldPut("ZH_OUTDESP",((_VLIPI/_QUANT)*M->ZH_QTDDEVO)+((_VALST/_QUANT)*M->ZH_QTDDEVO))
		GdFieldPut("ZH_OPDESP",((_VLIPIW/_QUANT)*M->ZH_QTDDEVO)+((_VALSTW/_QUANT)*M->ZH_QTDDEVO))
	Endif
Endif
getdrefresh()
Restarea(_area)
Return _ret


/*/
———————————————————————————————————————————————————————————————————————————————
@function		AR_NFE1                                                       /@
@type				Static function                                               /@
@date				                                                              /@
@description	                                                              /@
@author			Vescio Pereira de Moura                                       /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function AR_NFE1(cAR, cFormul)
Local aArea			:= GetArea()
Local lContinua	:= .T.
Local cSerie		:= ""
Local cNota			:= ""
Private lld1imp	:= .f.
Private _Nvaldesp	:= 0
Private alSD1, alSF1
Private cNumero

SF1->(dbSetOrder(1))		//F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO
dbSelectArea("SZG")
DbSetorder(1)				//ZG_FILIAL, ZG_NUMERO, ZG_EMISSAO, ZG_CLIENTE, ZG_LOJACLI
if SZG->(dbSeek(xfilial("SZG") + cAr))

	//———————————————————————————————————————————————————————————————————————————————
	//Devem estar preechidos
	//Num. NF Devo 	ZG_NFDEVOL
	//Dta Ent. NF 	ZG_DTENTRE
	//Dt Solicitac	ZG_DTSOLIC
	//Dat. Coleta 	ZG_DTCOLE
	//Dta Ent. Rec	ZG_DTENTES
	//Dta. Laudo  	ZG_DTRECUS
	//
	//Devem estar vazios
	//Dta. Interna	ZG_DTINTER
	//Dt. Ret. NF 	ZG_DTRETOR
	
	//linha original -> if !(!empty(SZG->ZG_NFDEVOL) .and.	!empty(SZG->ZG_DTENTRE) .and.	!empty(SZG->ZG_DTSOLIC) .and.	!empty(SZG->ZG_DTCOLE) .and. !empty(SZG->ZG_DTENTES) .and. !empty(SZG->ZG_DTRECUS) .and. empty(SZG->ZG_DTINTER) .and. empty(SZG->ZG_DTRETOR))
	if empty(SZG->ZG_NFDEVOL) .or. empty(SZG->ZG_DTENTRE) .or. empty(SZG->ZG_DTSOLIC) .or. empty(SZG->ZG_DTCOLE) .or.	empty(SZG->ZG_DTENTES) .or. empty(SZG->ZG_DTRECUS) .or. !empty(SZG->ZG_DTINTER) .or. !empty(SZG->ZG_DTRETOR)
		
		Help(,, "ATENÇÃO",, "Este AR não será internado, pois está com informações incorretas. Os campos 'Num.NF Devo', 'Dta Ent.NF', 'Dt Solicitac', 'Dat.Coleta', 'Dta Ent.Rec' e 'Dta. Laudo' devem estar preenchidos e os campos 'Dta.Interna' e 'Dt.Ret.NF' não podem estar preenchidos. Verifique." + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Brasitech)", 1)
		
	else

		if cFormul == "S"
		
			lContinua := Sx5NumNota(@cSerie, SuperGetMV("MV_TPNRNFS"))
			
			if lContinua
			
				cNota		:= cNumero
				cSerie	:= cSerie
				cEspecie	:= ""
				
				SX5->(MsRUnLock())
				
			endif

		else
		
			cNota		:= SZG->ZG_NFDEVOL
			cSerie	:= SZG->ZG_SERIENF
			cEspecie	:= SZG->ZG_ESPECIE
			
		endif
		
		if !empty(cNota) .and. lContinua //.AND. !EMPTY(cSerie) .AND. !EMPTY(cEspecie)

			if !SF1->(dbSeek(xFilial("SF1") + cNota + cSerie + SZG->(ZG_CLIENTE + ZG_LOJACLI)))
			
				MsgRun("Aguarde...",,{|| iif(!Empty(alSD1 := D1Imp(@_NVALDESP)), llD1Imp:=.T., llD1Imp:=.F.  ) } )
				
				if lLD1Imp
				
					SA1->(dbSetorder(1))
					SA1->(dbSeek(xFilial("SA1") + SZG->(ZG_CLIENTE + ZG_LOJACLI)))
					
					alSF1	:= {	{"F1_TIPO",		"D",					Nil},;
									{"F1_FORMUL",	cFormul,				Nil},;
									{"F1_DOC",		cNota,				Nil},;
									{"F1_SERIE",	cSerie,				Nil},;
									{"F1_EMISSAO",	dDataBase,			Nil},;
									{"F1_DTDIGIT",	dDataBase,			Nil},;
									{"F1_RECBMTO",	dDataBase,			Nil},;
									{"F1_FORNECE",	SZG->ZG_CLIENTE,	Nil},;
									{"F1_LOJA",		SZG->ZG_LOJACLI,	Nil},;
									{"F1_EST",		SA1->A1_EST,		Nil},;
									{"F1_BRAR",		SZG->ZG_NUMERO,	Nil},;
									{"F1_DESPESA",	SZG->ZG_VLRDESP,	Nil},;
									{"F1_MOEDA",	1, 					Nil}}

					alSF1	:= WsAutoOpc(alSF1)								
				
					lMsErroAuto:=.f.

					MsgRun("Aguarde gerando pre-nota...",,{||MSExecAuto({|x,y,z| MATA140(x,y,z)},alSF1,alSD1,3)})
					
					IF lMsErroAuto
						MostraErro()
						//	ElseIf supergetmv("MVCLASFIC",.F.,"N") = "S"
					Else
						dbSelectArea("SD1")
						DbSetorder(1)
						DbSeek(xfilial()+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))
						While SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) .AND. !EOF()
							dbSelectArea("SD2")
							DbSetorder(3)
							IF DbSeek(xfilial()+SD1->(D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA+D1_ITEMORI))
								Reclock("SD2",.F.)
								SD2->D2_BRQTDEV-=SD1->D1_QUANT
								alert("d2_brqtdev")
								MSUNLOCK()
							Endif
							dbSelectArea("SD1")
							DbSkip()
						Enddo
						dbSelectArea("SZG")
						Reclock("SZG",.F.)
//						SZG->ZG_NFDEVOL:=SF1->F1_DOC
//						SZG->ZG_SERIENF:=SF1->F1_SERIE
//						SZG->ZG_ESPECIE:=SF1->F1_ESPECIE
						SZG->ZG_DTINTER:=DDATABASE
						SZG->ZG_STATUS:=Iif(SZG->ZG_TIPO=="R","AR - Internada","AR - Devol. Finalizada")
						MSUNLOCK()
					
						//atualizar controle de quantodade em OR
						dbSelectArea("SF1")
						DbSetorder(1)
						if DbSeek(xfilial()+SZG->(cNota+cSerie+ZG_CLIENTE+ZG_LOJACLI))
							MsgRun("Aguarde para classificar a nota...",,{||MSExecAuto({|x,y,z,a,b| MATA103(x,y,z)},nil,nil,4)})
						Endif
						IF lMsErroAuto
							MostraErro()
						Endif
					Endif
	
				else
				
					Help(" ", 1, "ATENÇÃO",, "Não foi possível gerar a pré-nota de entrada." + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Brasitech).", 1)
	
				endif

			else
			
				Help(" ", 1, "ATENÇÃO",, "Este AR não poderá ser integrado com a pré-nota de entrada com o NÚMERO e SÉRIE informados, pois já existe uma nota com estas caracaterísticas. Verifique se a nota já foi incluída no sistema ou se os dados estão corretos no AR." + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Brasitech).", 1)
				
			endif
			
		Else
		
			Help(" ", 1, "ATENÇÃO",, "O número da NOTA da nota fiscal não foram informados no AR " + cAr + ". Atualize estas informações antes da internação da nota fiscal." + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Brasitech).", 1)
			
		Endif
		
	endif
	
else

	Help(" ", 1, "ATENÇÃO", , "O número do AR não foi localizado. Verifique se o mesmo foi informado corretamente." + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Brasitech).", 1)

endif

Restarea(aArea)
Return

/*/
———————————————————————————————————————————————————————————————————————————————
@function		F1IMP                                                         /@
@type				Static function                                               /@
@date				                                                              /@
@description	                                                              /@
@author			Vescio Pereira de Moura                                       /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————


Static Function F1Imp(cNota, cSerie, cEspecie, _NVALDESP, cFormul)
Local alCabec	:= {}
Local aArea		:= GetArea()

SA1->(dbSetorder(1))
SA1->(DbSeek(xFilial("SA1")+SZG->(ZG_CLIENTE+ZG_LOJACLI)))

aAdd(alCabec,{"F1_TIPO",		"D",												Nil})
aAdd(alCabec,{"F1_FORMUL",		cFormul,											Nil})
aAdd(alCabec,{"F1_DOC",			iif(cFormul=="S", Space(9), cNota),		Nil})
aAdd(alCabec,{"F1_SERIE",		iif(cFormul=="S", Space(3), cSerie),	Nil})
aAdd(alCabec,{"F1_EMISSAO",	dDataBase,										Nil})
aAdd(alCabec,{"F1_DTDIGIT",	dDataBase,										Nil})
aAdd(alCabec,{"F1_RECBMTO",	dDataBase,										Nil})
aAdd(alCabec,{"F1_FORNECE",	SZG->ZG_CLIENTE,								Nil})
aAdd(alCabec,{"F1_LOJA",		SZG->ZG_LOJACLI,								Nil})
aAdd(alCabec,{"F1_EST",			SA1->A1_EST,									Nil})
//aAdd(alCabec,{"F1_ESPECIE",	cEspecie,										Nil})
aAdd(alCabec,{"F1_BRAR",		SZG->ZG_NUMERO,								Nil})
aAdd(alCabec,{"F1_DESPESA",	SZG->ZG_VLRDESP,								Nil})
aAdd(alCabec,{"F1_MOEDA",		1, 												Nil})

alCabec := WsAutoOpc(alCabec)
Restarea(aArea)
Return alCabec
/*/

/*/
———————————————————————————————————————————————————————————————————————————————
@function		D1IMP                                                         /@
@type				Static function                                               /@
@date				                                                              /@
@description	                                                              /@
@author			Vescio Pereira de Moura                                       /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function D1Imp(_Nvaldesp)

Local alItens	 := {}
Local alRet      := {}
dbSelectArea("SA1")
DbSetorder(1)
DbSeek(xfilial()+SZG->(ZG_CLIENTE+ZG_LOJACLI))

dbSelectArea("SZH")
DbSetorder(1)
DbSeek(xfilial()+SZG->ZG_NUMERO)
While SZG->ZG_FILIAL+SZG->ZG_NUMERO == SZH->(ZH_FILIAL+ZH_NUMERO) .AND. !EOF()
	alItens:={}
	IF SA1->A1_SIMPLES = "1"
		aAdd(alItens,{"D1_COD"      , SZH->ZH_PRODUTO             ,NIL})
		aAdd(alItens,{"D1_ITEM"     , STRZERO(VAL(SZH->ZH_ITEM),4),NIL})
		aAdd(alItens,{"D1_QUANT"    , SZH->ZH_QTDDEVO           ,NIL})
		aAdd(alItens,{"D1_VUNIT"    , SZH->ZH_PRECONF           ,NIL})
		aAdd(alItens,{"D1_TOTAL"    , SZH->ZH_PRECTOT        ,NIL})
		aAdd(alitens,{"D1_EMISSAO"	,	DDATABASE,Nil})
		aAdd(alitens,{"D1_DIGIT"	,	DDATABASE,Nil})
		aAdd(alItens,{"D1_NFORI"    , SZH->ZH_ORIGEM        ,NIL})
		aAdd(alItens,{"D1_SERIORI"  , SZH->ZH_SERIE        ,NIL})
		aAdd(alItens,{"D1_ITEMORI"  , SZH->ZH_ITEMORI        ,NIL})
		aAdd(alItens,{"D1_BASEICM"  , SZH->ZH_BASEICM        ,NIL})
		aAdd(alItens,{"D1_ICM"      , SZH->ZH_ICM        ,NIL})
		aAdd(alItens,{"D1_VALICM"   , SZH->ZH_VALICM        ,NIL})
		aAdd(alItens,{"D1_DESPESA"  , SZH->ZH_VLRIPI+SZH->ZH_VALST,NIL})
		
		aAdd(alItens,{"AUTDELETA" ,"N",Nil}) // Incluir sempre no último elemento do array de cada item
		_nvaldesp+=SZH->ZH_VLRIPI+SZH->ZH_VALST
	Else
		aAdd(alItens,{"D1_COD"      , SZH->ZH_PRODUTO             ,NIL})
		aAdd(alItens,{"D1_ITEM"     , STRZERO(VAL(SZH->ZH_ITEM),4),NIL})
		aAdd(alItens,{"D1_QUANT"    , SZH->ZH_QTDDEVO           ,NIL})
		aAdd(alItens,{"D1_VUNIT"    , SZH->ZH_PRECONF           ,NIL})
		aAdd(alItens,{"D1_TOTAL"    , SZH->ZH_PRECTOT        ,NIL})
		aAdd(alitens,{"D1_EMISSAO"	,DDATABASE,Nil})
		aAdd(alitens,{"D1_DIGIT"	,DDATABASE,Nil})
		aAdd(alItens,{"D1_NFORI"    , SZH->ZH_ORIGEM        ,NIL})
		aAdd(alItens,{"D1_SERIORI"  , SZH->ZH_SERIE        ,NIL})
		aAdd(alItens,{"D1_ITEMORI"  , SZH->ZH_ITEMORI        ,NIL})
		aAdd(alItens,{"D1_BASEICM"  , SZH->ZH_BASEICM        ,NIL})
		aAdd(alItens,{"D1_BASEIPI"  , (SZH->ZH_VLRIPI/SZH->ZH_ALIQIPI)*100,NIL})
		aAdd(alItens,{"D1_IPI"      , SZH->ZH_ALIQIPI        ,NIL})
		aAdd(alItens,{"D1_VALIPI"   , SZH->ZH_VLRIPI        ,NIL})
		aAdd(alItens,{"D1_ICM"      , SZH->ZH_ICM        ,NIL})
		aAdd(alItens,{"D1_VALICM"   , SZH->ZH_VALICM        ,NIL})
		aAdd(alItens,{"D1_ICMSRET"  , SZH->ZH_VALST        ,NIL})
		aAdd(alItens,{"AUTDELETA" ,"N",Nil}) // Incluir sempre no último elemento do array de cada item
	Endif
	
	//			    alItens := WsAutoOpc( alItens, .T. )
	aAdd(alRet,alItens)
	dbSkip()
EndDo
Return alRet


/*/
———————————————————————————————————————————————————————————————————————————————
@function		SELEAR                                                        /@
@type				Static function                                               /@
@date				                                                              /@
@description	                                                              /@
@author			Vescio Pereira de Moura                                       /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function SeleAR()
Local aArea		 := GetArea()
Local cCadastro := "Autorizações de Recebimento"
Local aSays		 := {}
Local aButtons  := {}
Local cPerg		 := PadR("AUTODEV", Len(SX1->X1_GRUPO))
Local aCabSX1	 := {"X1_GRUPO", "X1_ORDEM", "X1_PERGUNT", "X1_VARIAVL", "X1_TIPO", "X1_TAMANHO", "X1_DECIMAL", "X1_GSC", "X1_VAR01", "X1_DEF01", "X1_DEF02", "X1_F3"}
Local aHlp01	 := {"Informe o número do aviso de recebimento", 		 "a ser integrado com a pré-nota de entrada"}
Local aHlp02	 := {"Informe o tipo de formulario a ser considerado", "se próprio (1-Sim) ou de terceiros (2-Não)"}
Local aRegs		 := {	{cPerg, "01", "Numero do AR ?", 		 "mv_ch1", "C", 06, 0, "G", "mv_par01", "", 		 "", 		 "AR"},;
							{cPerg, "02", "Formulario proprio?", "mv_ch2", "N", 01, 0, "C", "mv_par02", "1-Sim", "2-Não", ""} }
aAdd(aSays, OemToAnsi("Esta rotina irá gerar uma pre-nota a partir da AR informada"))
aAdd(aSays, OemToAnsi("nos parâmetros. Informe o número da AR."))
aAdd(aSays, OemToAnsi("Ao confirmar essa tela, será gerada"))
aAdd(aSays, OemToAnsi("uma pré-nota e em seguida será chamada a classificação da mesma."))
aAdd(aSays, OemToAnsi("Caso não seja confirmada a classificação, poderá ser feita posteriormente"))
aAdd(aSays, OemToAnsi("ou ser excluida na opção de pre-nota de entrada."))

U_BRASX1(aRegs, aCabSX1)	//Funcao contida dentro do BCFGA01.prw
PutSX1Help("P." + AllTrim(cPerg) + "01.", aHlp01, aHlp01, aHlp01)
PutSX1Help("P." + AllTrim(cPerg) + "02.", aHlp02, aHlp02, aHlp02)

Pergunte(cPerg, .F.)
aAdd(aButtons, { 5,.T.,{|o| Pergunte(cPerg, .T.)}})
aAdd(aButtons, { 1,.T.,{|o| AR_NFE1(mv_par01, iif(mv_par02==1, "S", "N")),o:oWnd:End()}})
aAdd(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

FormBatch( cCadastro, aSays, aButtons,,250,450 )
Restarea(aArea)
Return


/*/
———————————————————————————————————————————————————————————————————————————————
@function		NFORIz                                                         /@
@type				Static function                                               /@
@date				                                                              /@
@description	grava perguntas no sx1 de usuários
					Parametros:
					1 - Grupo de perguntas a atualizar
					2 - Codigo (ordem) da pergunta
					3 - Dado a ser gravado                                        /@
@author			Vescio Pereira de Moura                                       /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
user function GrvSX1 (_sGrupo, _sPerg, _xValor)
local _sUserName := ""
local _sMemoProf := ""
local _nTamanho := 0
local _nLinha    := 0
local _aLinhas   := {}
local _lContinua := .T.
_SGrupo:=padr(_sgrupo,len(SX1->X1_GRUPO))
if _lContinua
	if ! sx1 -> (dbseek (_sGrupo + _sPerg, .F.))
		msgalert ("Programa " + procname () + ": grupo/pergunta '" + _sGrupo + "/" + _sPerg + "' nao encontrado no arquivo SX1." + _PCham ())
		_lContinua = .F.
	endif
endif

if _lContinua
	// Atualizarei sempre no SX1. Depois vou ver se tem profile de usuario.
	do case
		case sx1 -> x1_gsc == "C"
			reclock ("SX1", .F.)
			sx1 -> x1_presel = val (cvaltochar (_xValor))
			sx1 -> x1_cnt01 = ""
			sx1 -> (msunlock ())
		case sx1 -> x1_gsc == "G"
			if valtype (_xValor) != sx1 -> x1_tipo
				msgalert ("Programa " + procname () + ": incompatibilidade de tipos: o parametro '" + _sPerg + "' do grupo de perguntas '" + _sGrupo + "' eh do tipo '" + sx1 -> x1_tipo + "', mas o valor recebido eh do tipo '" + valtype (_xValor) + "'." + _PCham ())
				_lContinua = .F.
			else
				reclock ("SX1", .F.)
				sx1 -> x1_presel = 0
				if sx1 -> x1_tipo == "D"
					sx1 -> x1_cnt01 = "'" + dtoc (_xValor) + "'"
				elseif sx1 -> x1_tipo == "N"
					sx1 -> x1_cnt01 = str (_xValor, sx1 -> x1_tamanho, sx1 -> x1_decimal)
				elseif sx1 -> x1_tipo == "C"
					sx1 -> x1_cnt01 = _xValor
				endif
				sx1 -> (msunlock ())
			endif
		otherwise
			msgalert ("Programa " + procname () + ": tratamento para X1_GSC = '" + sx1 -> x1_gsc + "' ainda nao implementado." + _PCham ())
			_lContinua = .F.
	endcase
endif

if _lContinua
	// Antes da versao 8.11 nao havia profile de usuario. Na versao 9 nao sei como serah...
	if "MP8.11" $ cVersao .and. type ("__cUserId") == "C"
		psworder (1) // Ordena arquivo de senhas por ID do usuario
		PswSeek(__cUserID) // Pesquisa usuario corrente
		_sUserName := PswRet(1) [1, 2]
		
		// Encontra e atualiza profile deste usuario para a rotina / pergunta atual.
		// Enquanto o usuario nao alterar nenhuma pergunta, ficarah usando do SX1 e
		// seu profile nao serah criado.
		If FindProfDef (_sUserName, _sGrupo, "PERGUNTE", "MV_PAR")
			
			// Carrega memo com o profile do usuario (o profile fica gravado
			// em um campo memo)
			_sMemoProf := RetProfDef (_sUserName, _sGrupo, "PERGUNTE", "MV_PAR")
			
			// Monta array com as linhas do memo (tem uma pergunta por linha)
			_aLinhas = {}
			for _nLinha = 1 to MLCount (_sMemoProf)
				aAdd (_aLinhas, alltrim (MemoLine (_sMemoProf,, _nLinha)) + chr (13) + chr (10))
			next
			
			// Monta uma linha com o novo conteudo do parametro atual.
			// Pos 1 = tipo (numerico/data/caracter...)
			// Pos 2 = '#'
			// Pos 3 = GSC
			// Pos 4 = '#'
			// Pos 5 em diante = conteudo.
			_sLinha = sx1 -> x1_tipo + "#" + sx1 -> x1_gsc + "#" + iif (sx1 -> x1_gsc == "C", cValToChar (sx1 -> x1_presel), sx1 -> x1_cnt01) + chr (13) + chr (10)
			
			// Se foi passada uma pergunta que nao consta no profile, deve tratar-se
			// de uma pergunta nova, pois jah encontrei-a no SX1. Entao vou criar uma
			// linha para ela na array. Senao, basta regravar na array.
			if val(_sPerg) > len (_aLinhas)
				aAdd (_aLinhas, _sLinha)
			else
				// Grava a linha de volta na array de linhas
				_aLinhas [val (_sPerg)] = _sLinha
			endif
			
			// Remonta memo para gravar no profile
			_sMemoProf = ""
			for _nLinha = 1 to len (_aLinhas)
				_sMemoProf += _aLinhas [_nLinha]
			next
			
			// Grava o memo no profile
			WriteProfDef(_sUserName, _sGrupo, "PERGUNTE", "MV_PAR", ; // Chave antiga
			_sUserName, _sGrupo, "PERGUNTE", "MV_PAR", ; // Chave nova
			_sMemoProf) // Novo conteudo do memo.
		endif
	endif
endif

return .T.



/*/
———————————————————————————————————————————————————————————————————————————————
@function		GRAVAX1                                                       /@
@type				Static function                                               /@
@date				                                                              /@
@description	                                                              /@
@author			Vescio Pereira de Moura                                       /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————

USER FUNCTION GRAVAX1(_REG)
LOCAL _CH:="ch0",_AREA:=GETAREA(),_A
dbSelectArea("SX1")
DbSetorder(1)
FOR _A:=1 TO LEN(_REG)
	IF !DbSeek(padr(_REG[_A,1],len(sx1->x1_grupo))+STRZERO(_A,2))  //PROCURA O GRUPO e a Pergunta
		
		RECLOCK("SX1",.T.)
		SX1->X1_GRUPO:=_REG[_A,1]
		SX1->X1_ORDEM:=STRZERO(_A,2)
		SX1->X1_PERGUNTE:=_REG[_A,2]
		_CH:=SOMA1(_ch)
		SX1->X1_VARIAVL:="mv_"+_ch
		SX1->X1_TIPO:=_REG[_A,3]
		SX1->X1_TAMANHO:=_REG[_A,4]
		SX1->X1_DECIMAL:=_REG[_A,5]
		SX1->X1_GSC:=_REG[_A,6]
		SX1->X1_VAR01:="MV_PAR"+STRZERO(_A,2)
		SX1->X1_F3:=if(len(_reg[_a]) < 7,"",_REG[_A,7])
		SX1->X1_DEF01:=if(len(_reg[_a]) < 8,"",_REG[_A,8])
		SX1->X1_DEF02:=if(len(_reg[_a]) < 9,"",_REG[_A,9])
		SX1->X1_DEF03:=if(len(_reg[_a]) < 10,"",_REG[_A,10])
		SX1->X1_DEF04:=if(len(_reg[_a]) < 11,"",_REG[_A,11])
		SX1->X1_DEF05:=if(len(_reg[_a]) < 12,"",_REG[_A,12])
		MSUNLOCK()
	Endif
Next _A
restarea(_area)
return
/*/

/*/
———————————————————————————————————————————————————————————————————————————————
@function		VALSEL                                                        /@
@type				Static function                                               /@
@date				                                                              /@
@description	                                                              /@
@author			Vescio Pereira de Moura                                       /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static function ValSel()	//_aCols)
Local lRet	 := .f.
Local aArea  := GetArea()
Local cuser	 := Space(25)
Local cSenha := Space(20)
Local oDlg1

//if Date() - _aCols[4] > 365
	@ 00,000 To 120,300 Dialog oDlg1 Title "Informe a Senha"
	@ 05,001 To 037,120
	@ 10,005 Say "Usuario:"
	@ 25,005 Say "Senha  :"
	@ 10,050 Get cUser Picture "@x" F3 "US3"
//	@ 25,050 Get cSenha Valid Empty(csenha) .or. _VerSenha(AllTrim(cUser), cSenha) PASSWORD
//	@ 40,049 BmpButton Type 1 Action Close(ODLG1)
//	@ 40,090 BmpButton Type 2 Action Eval({||lRet := .f., CLOSE(oDlg1)})

	@ 25,050 Get cSenha PASSWORD
	@ 40,049 BmpButton Type 1 Action _VerSenha(AllTrim(cUser), cSenha, @lRet, @oDlg1)
	@ 40,090 BmpButton Type 2 Action Eval({||lRet := .f., CLOSE(oDlg1)})

	Activate Dialog oDlg1 centered
//else
//	lRet := .T.
//endif
RestArea(aArea)

Return(lRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		_VERSENHA                                                     /@
@type				Static function                                               /@
@date				                                                              /@
@description	                                                              /@
@author			Vescio Pereira de Moura                                       /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function _verSenha(cUser, cSenha, lRet, oDlG1)
Local cUsers 	:= Upper(SuperGetMV("MV_AUTUSER",.f.,"admin") + "#admin")
Local aArea		:= GetArea()
Local aUser

lRet	:= .F.
PswOrder(2)
if PswSeek(cUser, .T.)

	if PswName(cSenha)

		if Upper(cUser) $ cUsers
			lRet := .T.
		else
			MsgInfo("Este usuário não está permitido à liberar seleção de notas com data superior à um ano!")
		endif
		
	else
	
		MsgInfo("Senha Inválida")
		
	endif
	
else

	Msginfo("Usuario não localizado!")
	
endif
	
PswOrder(1)
RestArea(aArea)

if lRet
	Close(oDlg1)
endif
Return(lRet)

/*/
if Retcodusr() $ cUsers
			aUser := pswret()
			if aUser[1,1] $ cusers
				_ret:=.t.
			Else
				MSGINFO("Usuário não Senha Invalida")
			Endif

Static Function _verSenha(cuser,_csenha,cusers,_ret)
local auser,_AREA:=GETAREA()
_ret:=.f.
psworder(3)
if pswseek(_csenha,.t.)                       admin	
	auser:=pswret()
	if auser[1,1]$cusers
		_ret:=.t.
	Else
		MSGINFO("Senha Invalida")
	Endif
Else
	MSGINFO("Senha Invalida")
Endif
return _ret
/*/

