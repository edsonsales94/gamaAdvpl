#Include 'Protheus.ch'
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

User Function ETQFIFOAVL()

Private cCadastro := OemToAnsi("Impressใo de Etiqueta Almoxarifado")

//Aadd(aButtons	, {'PRODUTO',{||M241SeleEs()},OemToAnsi("Demonstra os Itens da OP"),OemToAnsi("Itens")})

PRIVATE aRotina := {	{"Pesquisar","AxPesqui"  , 0 , 1},;
{"Visualizar","AxVisual",0,2},;  
{"Imprimir Etiqueta","U_ETQAVL1", 0 , 3}}

dbSetOrder(1)

mBrowse( 6, 1,22,75,"SB8",,,,,,)
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

User Function ETQAVL1()  

LOCAL aObjects 	:= {},aPosObj  :={}
LOCAL aSize    	:= MsAdvSize()
LOCAL aInfo    	:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
Local aADDButtons := {},aTelaButtons:={}
LOCAL cMay        := ""
LOCAL aCamposVld:={}
LOCAL bBlkVld   := {|x| x[3] := &(x[2])}
Local nx
Private  cTipoEtq,cPerg,nPosLote
cPerg:="ETQFIFO"
//If !Pergunte(cPerg,.T.)
//	MsgBox("Informe o tipo da etiqueta")
//	Return
//Endif
cTipoEtq:=1

Private aValidGet := {}
Private aCols	  := {} 
Private aHeader	  := {}

nOpc :=3
nOpca:=0

PRIVATE	cDoc:= "Avulso",;
_cSerie		:= "",;
_cDoc		:= "",;
cFornece	:= "",;
cLoja		:= ""

aButtons  := IF(Type("aButtons") == "U", {}, aButtons)
aTelaButtons:= ACLONE(aButtons)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a entrada de dados do arquivo                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private aHeader[0],Continua,nUsado:=0
Private cAlias	:="SB8"
_aArea	:= GetArea()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Montagem do aHeader                                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("SX3")
dbSetOrder(2)
dbSeek( "B8_LOTECTL" )
IF Alltrim(x3_campo) $ "B8_LOTECTL"
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal, ,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
Endif
dbSeek( "B8_PRODUTO" )
IF Alltrim(x3_campo) $ "B8_PRODUTO"
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal, ,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
Endif
dbSeek( "B8_SALDO" )
IF Alltrim(x3_campo) $ "B8_SALDO"
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal, ,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
		nUsado++
		AADD(aHeader,{ "Volumes", "B8_EMPENHO"+SPACE(3), x3_picture,;
		x3_tamanho, x3_decimal, ,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
		nUsado++
		AADD(aHeader,{ "Un.Por Volume", "B8_SALDO2", x3_picture,;
		x3_tamanho, x3_decimal, ,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
		
		DbSetOrder(2)
		DbSeek("B1_DESC")
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal, ,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )

		DbSetOrder(2)
		DbSeek("B8_DOC")
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal, ,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )


		DbSetOrder(2)
		DbSeek("B8_SERIE")
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal, ,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
		
Endif
dbSeek( "B8_DTVALID" )
IF Alltrim(x3_campo) $ "B8_DTVALID"
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal, ,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
Endif



RestArea(_aArea)


For nx := 1 To Len(aHeader)
	Do Case
		Case Trim(aHeader[nx][2]) == "B8_PRODUTO"
			nPosCod:=nX
		Case Trim(aHeader[nx][2]) == "B8_EMPENHO"
			nPosVol:=nX
		Case Trim(aHeader[nx][2]) == "B8_SALDO2"
			nPosUni:=nX
		Case Trim(aHeader[nx][2]) == "B1_DESC"
			nPosDesc:=nX   
		Case Trim(aHeader[nx][2]) == "B8_DOC"
			nPosDoc:=nX
		Case Trim(aHeader[nx][2]) == "B8_SERIE"
			nPosSerie:=nX		
		Case Trim(aHeader[nx][2]) == "B8_LOTECTL"	
			nPosLote:=nX 
		Case Trim(aHeader[nx][2]) == "B8_DTVALID"	
			nPosData:=nX	
	

	EndCase
Next nx

//aCols :=Array(Len(aHeader) + 1)

AADD(aCols,{SB8->B8_LOTECTL,SB8->B8_PRODUTO,SB8->B8_SALDO,0,0,SB1->B1_DESC,SB8->B8_DOC,SB8->B8_SERIE,SB8->B8_DTVALID,.F.})


AADD(aObjects,{100,020,.T.,.F.,.F.})
AADD(aObjects,{100,100,.T.,.T.,.F.})

aPosObj := MsObjSize(aInfo,aObjects)

While .T.
	Continua := .F.
	DEFINE MSDIALOG oDlg TITLE OemToAnsi("Impressใo de Etiqueta")  OF oMainWnd PIXEL FROM aSize[7],0 TO aSize[6],aSize[5]
	oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"U_AOCWM3B" ,"U_AOCWM3B",""        ,.F. ,Nil         ,NIL,NIL ,LINHAS)
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| (oDlg:End(),nOpca:=1)},{||oDlg:End(),nOpca:=2},,aTelaButtons)
	If nOpcA == 1
		If Msgyesno(OemToAnsi("Confirma a Impressใo ?"),"Etiquetas")
		   U_AOCAVL()
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




User Function AOCAVL()

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
	_cLote   := aCols[_nEtq,nPosLote]
	_dData   := aCols[_nEtq,nPosData]
	_cDoc    :=aCols[_nEtq,nPosDoc]
	_cSerie    :=aCols[_nEtq,nPosSerie]
	If _nQtdVol <=0 .OR. _nQtdUni <=0
		Loop
	Endif
	
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+_cCodPro,.F.)

	cNOMFOR := "Etiqueta Avulsa"
	
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
		MSCBBOX(05,05,132,063,02) //coluna 2
		MSCBLineH(05,28,132,02,"B")  // x1,y1,x2,espessura ,cor
		MSCBLineH(05,49,132,02,"B")  // x1,y1,x2,espessura ,cor
		//MSCBLineH(05,64,135,02,"B")  // x1,y1,x2,espessura ,cor
		//MSCBLineH(05,78,135,02,"B")  // x1,y1,x2,espessura ,cor
		MSCBLineV(73,28,49,02,"B")    // X1,Y1,Y2, ESPESSURA ,, COR
	
	
		//codigos de barras --------------------------------------------------------
		MSCBSAYBAR(40,18,_cCodPro ,"N","C",8.36,.F.,.F.,.F.,,2,1)
		MSCBSAYBAR(10,37,alltrim(SB8->B8_LOTECTL),"N","C",8.36,.F.,.F.,.F.,,2,1)
		MSCBSAYBAR(76,37,str(_nQtdbar,10,2),"N","C",8.36,.F.,.F.,.F.,,2,1)
		//--------------------------------------------------------------------------
		// Dados da Etiqueta -------------------------------------------------------
		MSCBSAY(10,07,"Codigo : "+RTRIM(SB1->B1_COD),"N","0","040,050")
		MSCBSAY(10,14,+RTRIM(SB1->B1_DESC),"N","0","020,030")
		MSCBSAY(10,30,"Lote: "+_cLote,"N","0","040,050")
		MSCBSAY(75,30,"Qtd:"+_nQtdUni+" "+SB1->B1_UM ,"N","0","040,050")
		//MSCBSAY(050,150,"Serial "+_cSerial,"R","0","060,060")
		//MSCBSAY(10,052,"Fornecedor: "+"Etiqueta Avulsa","N","0","030,040")
		//MSCBSAY(10,058,"Nome: " ,"N","0","030,040")
		MSCBSAY(07,052,"Nota Fiscal: "+RTRIM(_cDoc)+'-'+RTRIM(_cSerie),"N","0","030,040")
		MSCBSAY(77,052,"N.DI: " ,"N","0","030,040")
		MSCBSAY(07,058,"Rec: "+DTOC(SB8->B8_DATA) ,"N","0","030,040")
		MSCBSAY(77,058,"Vld.: "+DTOC(_dData) ,"N","0","030,040")
		
		//IF SB1->B1_NOTAMIN <> 9 // Verifica se produto esta em qualidade assegurada.
		// 	MSCBSAY(15,82,"" ,"N","0","040,050")   
		//ELSE
		//	MSCBSAY(15,82,"" ,"N","0","040,050")
		//ENDIF
	   	MSCBSAY(093,65,"Oper: "+ALLTRIM(SUBSTR(cUSUARIO,7,15))+' - '+LEFT(TIME(),5),"N","0","020,015")
	Endif
	
	MSCBEND()
	//Next nElem
	MSCBCLOSEPRINTER()
Next _nEtq

RestArea(_aArea)

Return Nil
