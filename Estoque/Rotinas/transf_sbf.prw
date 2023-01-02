#Include "Protheus.Ch"
#Include "FONT.CH"
#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TRANSFSBF º Autor ³        º Data ³  07/08/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina de Transferência de Endereço                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function TRANSFSBF()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aCampos		:= {}
Private cPerg   := "SBFXYZ"
Private cCadastro := "Transferência SLD entre Endereços."
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta um aRotina proprio                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private aRotina := { 	{"Pesquisar"  	,"AxPesqui"		,0,1} ,;
						{"Visualizar"	,"AxVisual"		,0,2} ,;
 						{"Transferir"	,"U_AltEnd()"	,0,4}   }

Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

Private cString := "SBF"

dbSelectArea("SBF")
dbSetOrder(1)
set filter to BF_QUANT > 0

cPerg   := "SBFXYZ"

//Pergunte(cPerg,.F.)
//SetKey(123,{|| Pergunte(cPerg,.T.)}) // Seta a tecla F12 para acionamento dos parametros

AADD(aCampos,{	"Produto"		,"BF_PRODUTO"	})
AADD(aCampos,{	"Armazem"		,"BF_LOCAL"    	})
AADD(aCampos,{	"Endereco"		,"BF_LOCALIZ"	})	  	
AADD(aCampos,{  "Prioridade"	,"BF_PRIOR"  	})
AADD(aCampos,{	"Quantidade"	,"BF_QUANT"		})

dbSelectArea(cString)
mBrowse( 6,1,22,75,cString,aCampos,,,,,)


Set Key 123 To // Desativa a tecla F12 do acionamento dos parametros

Return

// *************************************************************

User Function AltEnd()

	Local oDlg, oButton, oCombo, cCombo,aItems,_cQtde
	Private _cDoc    :=Space(09)
	Private cEndere  :=Space(15)
	Private cLote    :=Space(10)
	Private cArmDest :=sbf->Bf_Local // "01" 
	_nQtde := SBF->BF_QUANT // 0
	aItems:= {}

    //If !u_E_Vd_MM("TRFEND",cUserName,"6","")
    //   Return 
    //Endif 
    	
	_cDoc := u_SD3_DOC()

	dbSelectArea("SBE")                            
	

	set filter to BE_FILIAL = xFilial("SBE") .AND. SBE->BE_LOCAL = SBF->BF_LOCAL


	DEFINE MSDIALOG oDlg FROM 0,0 TO 180,270 PIXEL TITLE "Transferir Endereço"
    @ 05,10 SAY OemToAnsi("Documento:") SIZE 30,07 OF oDlg PIXEL
   //  27/10/08: Altaredo por Raquel para evitar a alteração do no. do documento para ZZZ e caracteres especiais que estão travando a numeração do sistema
   //	@ 05,65 MSGET _cDoc Picture "@!" VALID  ExistChav("SD3",_cDoc,2).and.naovazio() SIZE 60,07 OF oDlg PIXEL COLOR CLR_HBLUE 
   
    @ 05,65 SAY _cDoc OF oDlg PIXEL COLOR CLR_HBLUE 
   
	@ 20,10 SAY OemToAnsi("Armazem Destino :") SIZE 60,07 OF oDlg PIXEL	                                              
	@ 20,65 MSGET cArmDest Picture "@!" VALID  ExistCpo("SX5","74" + cArmDest) .and. naovazio() SIZE 60,07 F3 "74" OF oDlg PIXEL COLOR CLR_HBLUE  WHEN .F.

	@ 35,10 SAY OemToAnsi("Endereço Destino:") SIZE 60,07 OF oDlg PIXEL	                                              
	@ 35,65 MSGET cEndere  Picture "@!" VALID  ExistCpo("SBE",cArmDest + cEndere).and. naovazio().and.u_vldBlqLocaliz(SBE->BE_LOCAL,cEndere,.t.) SIZE 60,07 F3 "SBE" OF oDlg PIXEL COLOR CLR_HBLUE 

  
	@ 50,10 SAY OemToAnsi("Transferir Qtd:") SIZE 60,07 OF oDlg PIXEL
	@ 50,65 MSGET _nQtde Picture "@E 99,999.99999" VALID (_nQtde > 0 .AND. _nQtde <= SBF->BF_QUANT) SIZE 60,07 OF oDlg PIXEL COLOR CLR_HBLUE

	DEFINE SBUTTON FROM 65,30 TYPE 1 ENABLE OF oDlg	ACTION (fGrvTrans(cEndere,_nQtde),oDlg:End())
	DEFINE SBUTTON FROM 65,80 TYPE 2 ENABLE OF oDlg	ACTION (oDlg:End())

	ACTIVATE MSDIALOG oDlg CENTERED
	set filter to
Return(.t.)


/***********************************************/
Static Function fGrvTrans(cOPC,nVlr)
	Local cCodOri	:= 	SBF->BF_PRODUTO												//	Produto Origem	(Codigo)
    Local cDescrOri	:= 	Posicione("SB1",1,xFilial("SB1")+SBF->BF_PRODUTO,"B1_DESC") //	Produto Origem	(Descricao)
	Local cUmOri	:=	Posicione("SB1",1,xFilial("SB1")+SBF->BF_PRODUTO,"B1_UM")	//	Produto Origem	(Unid Medida)
	Local cAlmOri	:= 	SBF->BF_LOCAL												//	Produto Origem	(Almoxarifado)
	Local cEndOri	:= 	SBF->BF_LOCALIZ												//	Produto Origem	(Endereco)
	
	Local cCodDest	:=	SBF->BF_PRODUTO												//	Produto Destino	(Codigo)
	Local cDescrDest:=	Posicione("SB1",1,xFilial("SB1")+SBF->BF_PRODUTO,"B1_DESC")	//	Produto Destino	(Descricao)
	Local cUmDest	:=	Posicione("SB1",1,xFilial("SB1")+SBF->BF_PRODUTO,"B1_UM")	//	Produto Destino	(Unid Medida)
	Local cAlmDest	:=	cArmDest												//	Produto Destino	(Almoxarifado)
	Local cEndDest	:= 	cEndere												//	Produto Destino	(Endereco)
	
	Local cNumSerie	:= 	SBF->BF_NUMSERI							//	Produto	(Numero de Serie)
	Local cLote		:= 	SBF->BF_LOTECTL							//	Produto	(Lote)
	Local cSLote	:= 	Space(06)								//	Produto	(Sub Lote)
	Local cValLote	:=    Posicione("SB8",2,xFilial("SB8")+SBF->(BF_NUMLOTE+BF_LOTECTL+BF_PRODUTO+BF_LOCAL),"B8_DTVALID")									//	Produto	(Validade do Lote)       
	Local nPotenc	:= 	0										//  Potencia
	Local nQtde		:= 	nVlr									//	Produto	(Quantidade do movimento)
	Local nQtde2	:=	ConvUM(cCodOri,nVlr,0,2)				//	Produto	(Quantidade do movimento na Segunda Unidade Medida)
	Local cEstorn	:= 	Space(01)								//	Produto	(Se igual a S = Indica estorno)
	Local cSeq      := 	ProxNum()								//	Produto	(Sequencia utilizada pelo sistema)
	Local cLoteDest	:=	SBF->BF_LOTECTL							//	Produto	(Lote Destino)
	Local cValLtDest:=	Posicione("SB8",2,xFilial("SB8")+SBF->(BF_NUMLOTE+BF_LOTECTL+BF_PRODUTO+BF_LOCAL),"B8_DTVALID")								//  Produto (Validade Destino)  //VALIDADE DO LOTE	    
//	Local _cDoc		:= 	NextNumero("SD3",2,"D3_DOC",.T.)
//	Local _cDoc		:= iif(substr(NextNumero("SD3",2,"D3_DOC",.T.),1,1)="X", "X"+substr(NextNumero("SD3",2,"D3_DOC",.T.),2,5), "K"+substr(NextNumero("SD3",2,"D3_DOC",.T.),2,5)   )	

	Local aSepa  := {{_cDoc,dDataBase}}	//Criacao da 1a. linha do array com o documento e data
	Local cTexto := ""   
	Local cItemGrd:=""
	
	
	dbSelectArea("SB2")
	dbSetOrder(1)		
	IF DBSeek(xFilial('SB2')+cCodOri+ cArmDest )
	  nSaldoSda:=pegaSda(cCodOri,cArmDest)
	  IF SB2->B2_QACLASS<>nSaldoSda   //VERIFICA SE OS SALDOS A CLASSIFICAR ESTAO ALINHADOS
	    RecLock("SB2",.F.)
	    SB2->B2_QACLASS:=nSaldoSda
	    MsUnLock()
	  Endif
	Endif 
	
	dbSelectArea("SBE")
	dbSetOrder(1)		
	IF !DBSeek(xFilial('SBE')+ cArmDest + 	cEndere	)
		Alert("Armazem + Endereço Não Localizado" )
		Return (.F.)
	Endif 
	
	dbSeek(xFilial("SBE")+cArmDest+cEndDest)//Adicionado por Gláucia para impedir a transferencia de saldo para endereço bloqueado.
	If 	SBE->BE_STATUS == '3'//STATUS=3 ->BLOQUEADO	
		alert("O endereço "+cEndDest+" está bloqueado, selecione outro!!!")
		Return(.F.)
	Endif  
	
	cTexto := "Armazém / Endereço Origem  =" + SBF->BF_LOCAL + " - "  + SBF->BF_LOCALIZ + chr(13) + "Armazém / Endereço Destino =" + cArmDest + " - " + cEndere
	cTexto := cTexto + chr(13) + "Quantidade : " +STR(nVlr,15,5)

	lmsErroAuto	:= .F. 

	If MsgBox(cTexto,"Confirma a Transferência ?","YESNO") == .F.
	   Return
	Endif	           
	
	dbSelectArea("SBF")
    If (SBF->BF_LOCAL + SBF->BF_LOCALIZ) <> ( cArmDest + cEndere )  
      //If SubStr(cNumEmp,1,2) $ "21/31"
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
       Else 
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
					   	cItemGrd	})  //  Item Grade 
      Endif 
      */

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Chamada da Rotina automatica para gravacao de dados	³
		|de transferencia modelo II - [tabela SD3] 				|
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		*/
		
		If Len(aSepa) > 1
			x_Area  := Alias()
			x_Rec   := Recno()
			x_Ind   := Indexord()
	 	    BeginTran()
	         lMsErroAuto := .F. 
			 MsExecAuto({|x,y| mata261(x,y)},aSepa,3)//transferencia entre enderecos
			
			DbSelectArea(x_Area)
			DbSetOrder(x_Ind)
			DbGoto(x_Rec)
		EndIf
	else
		Alert("Endereço de Destino igual Endereço de Origem. Transferência Não Realizada!")	
	Endif
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Verifica se houve algum tipo de erro retornado pela	³
	|rotina automatica.										|
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	
	If  lmsErroAuto
		_Erro := Aviso("Pergunta","Transferência não gerada. Deseja visualizar o log?",{"Sim","Não"},1,"Atenção")
		If _Erro == 1
			MostraErro()
			DisarmTransaction()
			Return
		Endif
	Endif              
	EndTran()
Return

Static Function pegaSda(cCod,cAlmox)
Local nRet:=0
Local cAliasSDA:= GetNextAlias()
BeginSql Alias cAliasSDA
  SELECT ISNULL(SUM(DA_SALDO),0) saldo FROM %table:SDA% SDA 
  WHERE DA_FILIAL=%exp:XFILIAL("SDA")% AND DA_PRODUTO=%exp:cCod% AND DA_LOCAL=%exp:cAlmox% AND DA_SALDO>0 
  AND SDA.%NotDel%
EndSql
dbSelectArea(cAliasSDA)
dbgotop()
IF (cAliasSDA)->saldo>0
 nRet:=(cAliasSDA)->saldo
Endif
dbSelectArea(cAliasSDA)
dbclosearea()
Return(nRet)