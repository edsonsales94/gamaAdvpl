#Include "Protheus.Ch"
#Include "FONT.CH"
#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTRANSFSBF บ Autor ณ        บ Data ณ  07/08/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina de Transfer๊ncia de Produtos                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function Transf_pas()


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aCampos		:= {}
Private cPerg   := "SBFXYZ"
Private cCadastro := "Transfer๊ncia SLD entre Armazens."
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta um aRotina proprio                                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Private aRotina := { 	{"Pesquisar"  	,"AxPesqui"		,0,1} ,;
						{"Visualizar"	,"AxVisual"		,0,2} ,;
 						{"Transferir"	,"u_AltAlm()"	,0,4}   }

Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

Private cString := "SD3"

dbSelectArea("SD3")
dbSetOrder(1)
set filter to D3_CF="PR0" .AND. D3_TIPO$"PA/PI" .AND. D3_ESTORNO<>'S'

cPerg   := "SBFXYZ"
 
//Pergunte(cPerg,.F.)
//SetKey(123,{|| Pergunte(cPerg,.T.)}) // Seta a tecla F12 para acionamento dos parametros
AADD(aCampos,{	"Data"		,"D3_EMISSAO"	})
AADD(aCampos,{	"Documento"		,"D3_DOC"	})
AADD(aCampos,{	"Produto"		,"D3_COD"    	})
AADD(aCampos,{	"Tipo"		,"D3_TIPO"    	})
AADD(aCampos,{	"Und"		,"D3_UM"	})	  	
AADD(aCampos,{  "Quantidade"	,"D3_QUANT"  	})

dbSelectArea(cString)
mBrowse( 6,1,22,75,cString,aCampos,,,,,)


Set Key 123 To // Desativa a tecla F12 do acionamento dos parametros

Return

// *************************************************************

User Function AltAlm()

	Local oDlg, oButton, oCombo, cCombo,aItems,_cQtde
	Private _cDoc    :=Space(09)
	Private cEndere  :=Space(15)
	Private cArmDest :=iif(SD3->D3_TIPO="PI","11","01")   //armazem de almoxarifado
	private cprod := Posicione("SB1",1,xFilial("SB1")+SD3->D3_COD,"B1_DESC") 
	_nQtde := SD3->D3_QUANT  
	aItems:= {}
     
    //If !u_E_Vd_MM("TRFEND",cUserName,"6","")
    //   Return 
    //Endif 
    	
	_cDoc :=  "TR"+ SUBSTR(ALLTRIM(SD3->D3_DOC),3,9)   //u_SD3_DOC()

	

	DEFINE MSDIALOG oDlg FROM 0,0 TO 180,420 PIXEL TITLE "Transferir PA/PI"
    @ 05,10 SAY OemToAnsi("Documento:") SIZE 30,07 OF oDlg PIXEL
   //  27/10/08: Altaredo por Raquel para evitar a altera็ใo do no. do documento para ZZZ e caracteres especiais que estใo travando a numera็ใo do sistema
   //	@ 05,65 MSGET _cDoc Picture "@!" VALID  ExistChav("SD3",_cDoc,2).and.naovazio() SIZE 60,07 OF oDlg PIXEL COLOR CLR_HBLUE 
   
    @ 05,65 SAY _cDoc OF oDlg PIXEL COLOR CLR_HBLUE 
   
	@ 20,10 SAY OemToAnsi("Armazem Destino :") SIZE 60,07 OF oDlg PIXEL	                                              
    @ 20,65 SAY "Definir" Picture "@!" SIZE 60,07 OF oDlg PIXEL COLOR CLR_HBLUE  


	@ 35,10 SAY OemToAnsi("Produto: "+ALLTRIM(SD3->D3_COD) ) SIZE 60,07 OF oDlg PIXEL	                                              
	@ 35,65 SAY cprod  Picture "@!"  OF oDlg PIXEL COLOR CLR_HBLUE 
                             
	
	@ 50,10 SAY OemToAnsi("Transferir Qtd:") SIZE 60,07 OF oDlg PIXEL
	@ 50,65 SAY _nQtde Picture "@E 99,999.9999" SIZE 60,07 OF oDlg PIXEL COLOR CLR_HBLUE
	 
    @ 65,10 Button OemToAnsi("_Almoxarifado/Acabado") Size 80,14 Action (fGrvTrans(cEndere,_nQtde,cArmDest),oDlg:End())
    @ 65,110 Button OemToAnsi("_Processo ") Size 36,14 Action (fGrvTrans(cEndere,_nQtde,GETMV("MV_LOCPROC") ),oDlg:End())
    @ 65,160 Button OemToAnsi("_Cancelar") Size 36,14 Action  Close(oDlg)
	//DEFINE SBUTTON FROM 65,30 TYPE 1 ENABLE OF oDlg	ACTION (fGrvTrans(cEndere,_nQtde),oDlg:End())
	//DEFINE SBUTTON FROM 65,80 TYPE 2 ENABLE OF oDlg	ACTION (oDlg:End())

	ACTIVATE MSDIALOG oDlg CENTERED
	set filter to
Return(.t.)


/***********************************************/
Static Function fGrvTrans(cOPC,nVlr,arm)
	Local cCodOri	:= 	SD3->D3_COD												//	Produto Origem	(Codigo)
    Local cDescrOri	:= 	cprod //	Produto Origem	(Descricao)
	Local cUmOri	:=	Posicione("SB1",1,xFilial("SB1")+SD3->D3_COD,"B1_UM")	//	Produto Origem	(Unid Medida)
	Local cAlmOri	:= 	SD3->D3_LOCAL												//	Produto Origem	(Almoxarifado)
	Local cEndOri	:=  IIF(Posicione("SB1",1,xFilial("SB1")+SD3->D3_COD,"B1_LOCALIZ")=="S","TRANSITO",	""	)		//	Produto Origem	(Endereco)
	Local cTipo     :=  Posicione("SB1",1,xFilial("SB1")+SD3->D3_COD,"B1_TIPO")
	Local cCodDest	:=	SD3->D3_COD												//	Produto Destino	(Codigo)
	Local cDescrDest:= cprod	//	Produto Destino	(Descricao)
	Local cUmDest	:=	Posicione("SB1",1,xFilial("SB1")+SD3->D3_COD,"B1_UM")	//	Produto Destino	(Unid Medida)
	Local cAlmDest	:=	arm												//	Produto Destino	(Almoxarifado)
	Local cEndDest	:= 	""												//	Produto Destino	(Endereco)
	
	Local cNumSerie	:= 	SD3->D3_NUMSERI							//	Produto	(Numero de Serie)
	Local cLote		:= 	SD3->D3_LOTECTL							//	Produto	(Lote)
	Local cSLote	:= 	Space(06)								//	Produto	(Sub Lote)
	Local cValLote	:= 	ctod('')								//	Produto	(Validade do Lote)       
	Local nPotenc	:= 	0										//  Potencia
	Local nQtde		:= 	nVlr									//	Produto	(Quantidade do movimento)
	Local nQtde2	:=	ConvUM(cCodOri,nVlr,0,2)				//	Produto	(Quantidade do movimento na Segunda Unidade Medida)
	Local cEstorn	:= 	Space(01)								//	Produto	(Se igual a S = Indica estorno)
	Local cSeq      := 	ProxNum()								//	Produto	(Sequencia utilizada pelo sistema)
	Local cLoteDest	:=	SD3->D3_LOTECTL							//	Produto	(Lote Destino)
	Local cValLtDest:=	ctod('')								//  Produto (Validade Destino)	    
//	Local _cDoc		:= 	NextNumero("SD3",2,"D3_DOC",.T.)
//	Local _cDoc		:= iif(substr(NextNumero("SD3",2,"D3_DOC",.T.),1,1)="X", "X"+substr(NextNumero("SD3",2,"D3_DOC",.T.),2,5), "K"+substr(NextNumero("SD3",2,"D3_DOC",.T.),2,5)   )	

	Local aSepa  := {{_cDoc,dDataBase}}	//Criacao da 1a. linha do array com o documento e data
	Local cTexto := ""   
	Local cItemGrd:=""
	
	x_Area  := Alias()
	x_Rec   := Recno()
	x_Ind   := Indexord()
	dbSelectArea("SD3")
	dbSetOrder(2)		
	IF DBSeek(xFilial('SD3')+ _cDoc+space(9-len(_cDoc) ) + 	cCodOri	)
		Alert("Documento jแ foi transferido !!" )
		Return (.F.)
	Endif 
	If cAlmDest==GETMV("MV_LOCPROC") .and. cTipo=="PA"
	  alert("Produto Acabado nao pode ser transferido para o processo!!")
	  Return (.F.)
	Endif
	
	cTexto := "Armaz้m / Produto Origem  =" + cAlmOri + " - "  + cCodOri + chr(13) + "Armaz้m / Produto Destino =" + cAlmDest + " - " + cCodDest
	cTexto := cTexto + chr(13) + "Quantidade : " +STR(nVlr,10,4)

	lmsErroAuto	:= .F.            

	If MsgBox(cTexto,"Confirma a Transfer๊ncia ?","YESNO") == .F.
	   Return
	Endif	           
	
	aAdd(aSepa,{	cCodOri		,;	//	Produto Origem	(Codigo)
			            cDescrOri	,;	//	Produto Origem	(Descricao)
						cUmOri		,;	//	Produto Origem	(Unid Medida)
						cAlmOri		,;	//	Produto Origem	(Almoxarifado)
						cEndOri		,;	//	Produto Origem	(Endereco)
						cCodDest	,;	//	Produto Destino	(Codigo)
						cDescrDest	,;	//	Produto Destino	(Descricao)
						cUmDest		,;	//	Produto Destino	(Unid Medida)
						cAlmDest	,;	//	Produto Destino	(Almoxarifado)
						cEndDest	,;	//	Produto Destino	(Endereco)
						cNumSerie	,;	//	Produto	(Numero de Serie)
						cLote		,;	//	Produto	(Lote)
						cSLote		,;	//	Produto	(Sub Lote)
						cValLote	,;	//	Produto	(Validade do Lote)       
						nPotenc		,;  //	Produto (Potencia)
						nQtde		,;	//	Produto	(Quantidade do movimento)
						nQtde2		,;	//	Produto	(Quantidade do movimento na Segunda Unidade Medida)
						cEstorn		,;	//	Produto	(Se igual a S = Indica estorno)
						cSeq		,;	//	Produto	(Sequencia)
						cLoteDest	,;	//	Produto	(Lote Destino)
						cValLtDest	,;  //  Produto (Validade Lote Destino) 
   					Space(03)   ,;  //  Item Grade
						Space(128)   ,;  //OBSERVA 
					    Space(128)	})  //  
					       	
       
		/*
		ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		ณChamada da Rotina automatica para gravacao de dados	ณ
		|de transferencia modelo II - [tabela SD3] 				|
		ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		*/
		
		If Len(aSepa) > 1
			MsExecAuto({|x,y| mata261(x,y)},aSepa,3)//transferencia entre enderecos
			DbSelectArea(x_Area)
			DbSetOrder(x_Ind)
			DbGoto(x_Rec)
		EndIf
	/*
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณVerifica se houve algum tipo de erro retornado pela	ณ
	|rotina automatica.										|
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	*/
	
	If  lmsErroAuto
		_Erro := Aviso("Pergunta","Transfer๊ncia nใo gerada. Deseja visualizar o log?",{"Sim","Nใo"},1,"Aten็ใo")
		If _Erro == 1
			MostraErro()
			Return
		Endif
	Endif              
	
Return