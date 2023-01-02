#INCLUDE "PROTHEUS.CH"
#Include "rwmake.ch"
#DEFINE LINHAS 999

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAOCWMS03  บAutor  ณ Eduardo Barbosa    บ Data ณ  10/01/2008 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Impressao de Etiqueta Para Enderecamento MP                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ETQFIFO()

Private cCadastro := OemToAnsi("Impressใo de Etiqueta Almoxarifado")

//Aadd(aButtons	, {'PRODUTO',{||M241SeleEs()},OemToAnsi("Demonstra os Itens da OP"),OemToAnsi("Itens")})

PRIVATE aRotina := {	{"Pesquisar","AxPesqui"  , 0 , 1},;
{"Visualizar","A103NFiscal",0,2},;
{"Imprimir Etiqueta","U_ETQFIFO3A", 0 , 3}}
  
dbSetOrder(1)

mBrowse( 6, 1,22,75,"SF1",,,,,,)
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAOCWM03A  บAutor  ณ Eduardo Barbosa    บ Data ณ  10/01/2008บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Impressao de Etiqueta Para Enderecamento MP                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ETQFIFO3A(nOpc)  

LOCAL aObjects 	:= {},aPosObj  :={}
LOCAL aSize    	:= MsAdvSize()
LOCAL aInfo    	:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
Local aADDButtons := {},aTelaButtons:={}
LOCAL cMay        := ""
LOCAL aCamposVld:={}
LOCAL bBlkVld   := {|x| x[3] := &(x[2])}
Local nX
Private  cTipoEtq,cPerg
cPerg:="ETQFIFO"
If !Pergunte(cPerg,.T.)
	MsgBox("Informe o tipo da etiqueta")
	Return
Endif
cTipoEtq:=Mv_Par01

Private aValidGet := {}
Private aCols	  := {}
Private aHeader	  := {}

nOpc :=3
nOpca:=0

PRIVATE	cDoc:= SF1->F1_DOC,;
cSerie		:= SF1->F1_SERIE,;
cFornece	:= SF1->F1_FORNECE,;
cLoja		:= SF1->F1_LOJA

aButtons  := IF(Type("aButtons") == "U", {}, aButtons)
aTelaButtons:= ACLONE(aButtons)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a entrada de dados do arquivo                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private aHeader[0],Continua,nUsado:=0
Private cAlias	:="SD1"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Montagem do aHeader                                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek( cAlias )
While !EOF() .And. (x3_arquivo == cAlias)
	IF Alltrim(x3_campo) $ "D1_ITEM/D1_COD/D1_QUANT/D1_DTDIGIT"
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal, ,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
	Endif
	If Alltrim(x3_campo) == "D1_QUANT"
		nUsado++
		AADD(aHeader,{ "Volumes", "D1_PESO"+SPACE(3), x3_picture,;
		x3_tamanho, x3_decimal, ,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
		nUsado++
		AADD(aHeader,{ "Un.Por Volume", "D1_QTSEGUM", x3_picture,;
		x3_tamanho, x3_decimal, ,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
		_aArea	:= GetArea()
		DbSetOrder(2)
		DbSeek("B1_DESC")
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal, ,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
		RestArea(_aArea)
	Endif
	dbSkip()
End

For nx := 1 To Len(aHeader)
	Do Case
		Case Trim(aHeader[nx][2]) == "D1_COD"
			nPosCod:=nX
		Case Trim(aHeader[nx][2]) == "D1_PESO"
			nPosVol:=nX
		Case Trim(aHeader[nx][2]) == "D1_QTSEGUM"
			nPosUni:=nX
		Case Trim(aHeader[nx][2]) == "B1_DESC"
			nPosDesc:=nX
	EndCase
Next nx

//aCols :=Array(Len(aHeader) + 1)

DbSelectarea("SD1")
DbSetOrder(1)
DbSeek(xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA),.F.)
While ! Eof() .AND. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)== xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+SD1->D1_COD,.F.)
	AADD(aCols,{SD1->D1_ITEM,SD1->D1_COD,SD1->D1_QUANT,0,0,SB1->B1_DESC,SD1->D1_DTDIGIT,.F.})
	//AADD(aCols,{SD1->D1_COD,SD1->D1_QUANT,0,0,SB1->B1_DESC,SD1->D1_DTDIGIT,.F.})
	DbSelectarea("SD1")
	DbSkip()
Enddo
DbSelectArea("SF1")

AADD(aObjects,{100,020,.T.,.F.,.F.})
AADD(aObjects,{100,100,.T.,.T.,.F.})

aPosObj := MsObjSize(aInfo,aObjects)

While .T.
	Continua := .F.
	DEFINE MSDIALOG oDlg TITLE OemToAnsi("Impressใo de Etiqueta")  OF oMainWnd PIXEL FROM aSize[7],0 TO aSize[6],aSize[5]
	@ 1.6,.7  SAY "Nota Fiscal" 					//"Nฃmero Documento"
	@ 1.5,5   MSGET cDoc	Picture PesqPict("SF1","F1_DOC") WHEN .F.
	@ 1.6,5  +Len(cDoc)	SAY "Serie"
	@ 1.5,7.5+Len(cDoc)	MSGET cSerie Picture PesqPict("SF1","F1_SERIE") WHEN .F.
	@ 1.6,11.4 +Len(cDoc)	SAY "Fornecedor"
	@ 1.5,16.4 +Len(cDoc)	MSGET cFornece Picture PesqPict("SF1","F1_FORNECE") WHEN .F.
	@ 1.6,23.4 +Len(cDoc)	SAY "Loja"
	@ 1.5,26.4 +Len(cDoc)	MSGET cLoja WHEN .F.
	@ 1.6,28.4 +Len(cDoc)	SAY "Nome"
	IF ALLTRIM(SF1->F1_TIPO)=='B'
		@ 1.5,30.4 +Len(cDoc)	MSGET Posicione("SA1",1,xFilial("SA1")+SF1->F1_FORNECE+SF1->F1_LOJA,"A1_NOME") WHEN .F.
	ELSE
		@ 1.5,30.4 +Len(cDoc)	MSGET Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"A2_NOME") WHEN .F.
	ENDIF
	oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"U_AOCWM3B","U_AOCWM3B","",.F.,Nil,NIL,NIL,LINHAS)
	//ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| (AEval(aCamposVld,bBlkVld),IIF(oGet:TudoOK() .And. ChkGetFix(aCamposVld,.F.,.T.),(oDlg:End(),nOpca:=1),nOpca := 0))},{||oDlg:End()},,aTelaButtons)
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| (oDlg:End(),nOpca:=1)},{||oDlg:End(),nOpca:=2},,aTelaButtons)
	If nOpcA == 1
		If Msgyesno(OemToAnsi("Confirma a Impressใo ?"),"Etiquetas")
			AOCWM3C()
		Endif
	Endif
	If nOpcA == 2
		Exit
	Endif
Enddo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Desativa tecla F4                                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Return nOpca

USER FUNCTION AOCWM3B()
Return .T.




Static Function AOCWM3C()

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Local oFont06,oFont08,oFont09,oFont10,oFont11,oFont12,oFont14,oFont16,oFont18,oFont20,oFont50
Local cQuery    := Space(1)
Local cInvoice  := Space(1)
Local _aArea	:= GetArea()
Local Titulo	:= ''
Local cNomFor   := ''
Local _nEtq
_lPri	:= .T.

For _nEtq 	 := 1 to Len(aCols)
	_nQtdVol := aCols[_nEtq,nPosVol]
	_nQtdUni := aCols[_nEtq,nPosUni]
	_cCodPro := aCols[_nEtq,nPosCod]
	
	If _nQtdVol <=0 .OR. _nQtdUni <=0
		Loop
	Endif
	DbSelectArea("SD1")
	DbSetOrder(01)
	If !DbSeek(xFilial("SD1")+cDoc+cSerie+cFornece+cLoja+_cCodPro)
		Loop
	Endif
	/*
	If Empty(SD1->D1_LOTECTL)
	Loop
	Endif
	*/
	
	SA5->(DbSetOrder(1))
	SA5->(DbSeek(xFilial('SA5')+cFornece+cLoja+_cCodPro))
	
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+SD1->D1_COD,.F.)
	
	DbSelectArea("SA2")
	DbSetOrder(1)
	Dbseek(xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA,.F.)
	cNOMFOR := SA2->A2_NREDUZ
	
	DbSelectArea("SC7")
	DbSetOrder(1)
	DbSeek(xFilial("SC7") + SD1->D1_PEDIDO)
	If SC7->C7_ORIGEM = 'EICPO400'  //esta relacionado com um pedido de importacao
		DbSelectArea("SW9")
		DbSetOrder(3)
		If DbSeek(xFilial("SW9") + RTrim(SF1->F1_HAWB))
			cInvoice := Alltrim(SW9->W9_INVOICE)
		EndIf
    ELSE 
      cInvoice := POSICIONE("CD5",4,xFilial("SA2")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_ITEM,"CD5_NDI")
   	EndIf
	
	DbSelectArea("SF1")
	DbSetOrder(1)
	DbSeek(xFilial("SF1")+cDoc+cSerie+cFornece+cLoja)
	IF ALLTRIM(SF1->F1_TIPO) == 'B'   // NOTA DE BENEFICIAMENTO
		DbSelectArea("SA1")   // CADASTRO DE CLIENTES
		DbSetOrder(1)
		Dbseek(xFilial("SA1")+SD1->D1_FORNECE+SD1->D1_LOJA,.F.)
		cNOMFOR := SA1->A1_NREDUZ
	ENDIF
	_nQtdbar:=_nQtdUni
	If Int(_nQtdUni) != _nQtdUni
		_nQtdUni	:= Transform(_nQtdUni,"@E 999999.99")
	Else
		_nQtdUni	:= Transform(_nQtdUni,"@E 999999")
	Endif

	
	If cTipoEtq = 1
		MSCBPRINTER("ZM400","LPT1",,,.f.,,,,)
	Else
		//MSCBPRINTER("Z4M","LPT1",,,.f.,,,,)
		MSCBPRINTER("S4M","LPT1",,,.f.,,,,)
	Endif
	MSCBCHKStatus(.f.)
	
	
	//For _nElem := 1 To _nQtdVol // Qtde de Etiquetas
	_cSerial := "TESTE" //GetMV("MV_AOCSER")
	DbSelectArea("SX6")
	DbSetOrder(1)
	If DbSeek(xFilial("SX6")+"MV_AOCSER",.F.)
		RecLock("SX6",.F.)
		SX6->X6_CONTEUD := Soma1(_cSerial,6)
		msUnlock()
	Endif
	
	If cTipoEtq = 1 //Etiqueta de Fifo 100 mm por 160 mm//130 mm
		MSCBBEGIN(_nQtdVol,6,100)
		
		//LINHAS VERTICAIS E HORIZONTAIS--------------------------------------------
		MSCBBOX(05,05,132,064,02) //coluna 2
		MSCBLineH(05,28,132,02,"B")  // x1,y1,x2,espessura ,cor
		MSCBLineH(05,49,132,02,"B")  // x1,y1,x2,espessura ,cor
		//MSCBLineH(05,64,127,02,"B")  // x1,y1,x2,espessura ,cor
		//MSCBLineH(05,78,127,02,"B")  // x1,y1,x2,espessura ,cor
		MSCBLineV(73,28,49,02,"B")    // X1,Y1,Y2, ESPESSURA ,, COR
	
	
		//codigos de barras --------------------------------------------------------
		MSCBSAYBAR(40,18,SD1->D1_COD,"N","C",8.36,.F.,.F.,.F.,,2,1)
		MSCBSAYBAR(10,37,alltrim(SD1->D1_LOTECTL),"N","C",8.36,.F.,.F.,.F.,,2,1)
		MSCBSAYBAR(75,37,str(_nQtdbar,10,2),"N","C",8.36,.F.,.F.,.F.,,2,1)
		//--------------------------------------------------------------------------
		// Dados da Etiqueta -------------------------------------------------------
		MSCBSAY(10,07,"Codigo : "+RTRIM(SB1->B1_COD),"N","0","040,050")
		MSCBSAY(10,14,+RTRIM(SB1->B1_DESC),"N","0","020,030")
		MSCBSAY(10,30,"Lote: "+SD1->D1_LOTECTL,"N","0","040,050")
		MSCBSAY(75,30,"Qtd:"+_nQtdUni+" "+SB1->B1_UM ,"N","0","040,050")
		//MSCBSAY(050,150,"Serial "+_cSerial,"R","0","060,060")
		//MSCBSAY(10,052,"Fornecedor: "+SA2->A2_COD ,"N","0","030,040")
		//MSCBSAY(10,058,"Nome: "+Left(cNOMFOR,37) ,"N","0","030,040")
		MSCBSAY(07,052,"Nota Fiscal: "+SD1->D1_DOC  ,"N","0","030,040")
		MSCBSAY(75,052,"N.DI: "+cInvoice ,"N","0","030,040")
		MSCBSAY(07,058,"Dt.Vld: "+DTOC(SD1->D1_DTVALID) ,"N","0","030,040")
	    IF SB1->B1_NOTAMIN <> 9 // Verifica se produto esta em qualidade assegurada.
		 	MSCBSAY(57,58,"QUAL.ASSEGURADA","N","0","040,050") 
		ELSE
			MSCBSAY(57,58,"FAZER INSP. CQ" ,"N","0","040,050")
		ENDIF
	   	MSCBSAY(093,65,"Oper: "+ALLTRIM(SUBSTR(cUSUARIO,7,15))+' - '+LEFT(TIME(),5),"N","0","020,015")
	Endif
	
	MSCBEND()
	//Next nElem
	MSCBCLOSEPRINTER()
Next _nEtq

RestArea(_aArea)

Return Nil

