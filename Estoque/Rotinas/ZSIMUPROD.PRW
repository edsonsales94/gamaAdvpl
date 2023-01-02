#INCLUDE "PROTHEUS.CH"
#include 'totvs.ch'
#include 'tcbrowse.ch'
#INCLUDE "RWMAKE2.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"
#Include 'FWMVCDef.ch'

#IFNDEF CRLF
	#DEFINE CRLF ( chr(13)+chr(10) )
#ENDIF


//Constantes
#Define STR_PULA	Chr(13)+Chr(10)


//--------------------------------------------------------------
/*/{Protheus.doc} zSimu
Description                                                     
                                                                
@param xParam Parameter Description                             
@return xRet Return Description                                 
@author Ricky Moraes - ricky.moraes@gamaitaly.com.br                                              
@since 11/04/2021                                                   
/*/                                                             
//--------------------------------------------------------------


User Function ZSIMU()

	Local aArea          := GetArea()
	Private lMsErroAuto	:= .F.

	Private obtAddDemanda
	Private oBtAtuResult
	Private obtConsEst
	Private obtDesproc
	Private oBtEnd
	Private oBtLimpar
	Private obtImpCsv
	Private obtProcessar
	Private obtRemDemanda
	Private oButton1
	Private oCbEtrutura
	Private nCbEtrutura := 1
	Private oCbProdResult
	Private nCbProdResult := 1
	Private oCkNegativo
	Private lCkNegativo := .T.
	Private oFPSimulador

	Private oGetCodDemanda
	Private cGetCodDemanda := Space(TamSX3("B1_COD")[1])

	Private oGetDtDemanda
	Private dGetDtDemanda := STOD("")

	Private oGetDescDemanda

	Private oGetDescEstrutura
	Private cGetDescEstrutura := Space(40)
	Private oGetDescriSaldo
	Private cGetDescriSaldo := Space(40)
	Private oGetProdSaldo
	Private cGetProdSaldo := Space(TamSX3("B1_COD")[1])
	Private oGetQtdDemanada
	Private nGetQtdDemanada := 0
	Private oGetTipoDemanda

	Private oGetTipoSaldo
	Private cGetTipoSaldo := space(2)



	Private oSay1
	Private oSay10
	Private oSay11
	Private oSay12
	Private oSay4
	Private oSay5
	Private oSay6
	Private oSay7
	Private oSay8
	Private oSay9
	Private oSay20
	Private oSayTITULO
	Static oDlg

	Private oGroup1
	Private oGroup2
	Private oGroup3
	Private oGroup4
	Private oGroup5
	Private oGroup6
	Private oGroup7
	Private oGroup8

	Private cGetDescDemanda := Space(40)
	Private cGetTipoDemanda := Space(2)

	Private OWBResult
	Private OWBDemanda

	Private uConteudoSEQ := '000'

	Private aRotina := MenuDef()

	ChkFile("ZTS")
	ChkFile("ZTT")


	//DEFINE MSDIALOG oDlg TITLE "Simulador de Produção - Gamaitaly" FROM 000, 000  TO 680, 1200 COLORS 0, 16777215 PIXEL
	DEFINE MSDIALOG oDlg  FROM 000, 000  TO 680, 1200 COLORS 0, 16777215 PIXEL

	//@ 020, 001 FOLDER oFPSimulador SIZE 595, 320 OF oDlg ITEMS "Demanda","Estrutura","Saldo","Resultado" COLORS 0, 16777215 PIXEL
	@ 020, 001 FOLDER oFPSimulador SIZE 595, 320 OF oDlg ITEMS "Demanda" COLORS 0, 16777215 PIXEL
	/*
	@ 004, 005 GROUP oGroup7 TO 068, 586 PROMPT "Filtros Resultados" OF oFPSimulador:aDialogs[4] COLOR 0, 16777215 PIXEL
	@ 012, 040 MSCOMBOBOX oCbProdResult VAR nCbProdResult ITEMS {"TODOS","APP1528","ASS2177"} SIZE 111, 010 OF oGroup7 COLORS 0, 16777215 PIXEL
	@ 014, 014 SAY oSay12 PROMPT "Produto" SIZE 025, 007 OF oGroup7 COLORS 0, 16777215 PIXEL
	@ 032, 040 CHECKBOX oCkNegativo VAR lCkNegativo PROMPT "Somente Negativo" SIZE 069, 008 OF oGroup7 COLORS 0, 16777215 PIXEL
	@ 070, 005 GROUP oGroup8 TO 317, 586 PROMPT "Resultado calculo Demanda" OF oFPSimulador:aDialogs[4] COLOR 0, 16777215 PIXEL
	fWBResult()

	@ 004, 005 GROUP oGroup5 TO 068, 586 PROMPT "Selecione o Produto " OF oFPSimulador:aDialogs[3] COLOR 0, 16777215 PIXEL
	@ 014, 014 SAY oSay8 PROMPT "Codigo" SIZE 025, 007 OF oGroup5 COLORS 0, 16777215 PIXEL
	@ 012, 040 MSGET oGetProdSaldo VAR cGetProdSaldo SIZE 099, 010 OF oGroup5 VALID ExistCpo('SB1') COLORS 0, 16777215 F3 "SB1" PIXEL
	@ 032, 007 SAY oSay9 PROMPT "Descrição" SIZE 025, 007 OF oGroup5 COLORS 0, 16777215 PIXEL
	@ 031, 040 MSGET oGetDescriSaldo VAR cGetDescriSaldo  When .F. SIZE 186, 010 OF oGroup5 COLORS 0, 16777215  PIXEL
	@ 013, 204 SAY oSay10 PROMPT "Tipo" SIZE 025, 007 OF oGroup5 COLORS 0, 16777215 PIXEL
	@ 011, 242 MSGET oGetTipoSaldo VAR cGetTipoSaldo  When .F. SIZE 023, 010 OF oGroup5 COLORS 0, 16777215  PIXEL
	@ 037, 258 BUTTON oButton1 PROMPT "Consulta" SIZE 062, 016 OF oGroup5 ACTION fConsEst PIXEL
	@ 070, 005 GROUP oGroup6 TO 317, 586 PROMPT "Saldo / Entradas / Saídas " OF oFPSimulador:aDialogs[3] COLOR 0, 16777215 PIXEL
	fWBSaldo()
	@ 004, 005 GROUP oGroup2 TO 068, 586 PROMPT "Selecione o Produto " OF oFPSimulador:aDialogs[2] COLOR 0, 16777215 PIXEL
	@ 031, 040 MSGET oGetDescEstrutura VAR cGetDescEstrutura  When .F. SIZE 186, 010 OF oGroup2 COLORS 0, 16777215  PIXEL
	@ 014, 014 SAY oSay11 PROMPT "Codigo" SIZE 020, 007 OF oGroup2 COLORS 0, 16777215 PIXEL
	@ 032, 007 SAY oSay1 PROMPT "Descrição" SIZE 025, 007 OF oGroup2 COLORS 0, 16777215 PIXEL
	@ 037, 258 BUTTON obtConsEst PROMPT "Consulta" SIZE 062, 016 OF oGroup2 ACTION fConsEst PIXEL
	@ 012, 040 MSCOMBOBOX oCbEtrutura VAR nCbEtrutura ITEMS {"APP1528","ASS2117"} SIZE 094, 010 OF oGroup2 COLORS 0, 16777215 PIXEL
	@ 070, 005 GROUP oGroup3 TO 317, 586 PROMPT "Lista Tecnica (BOM)" OF oFPSimulador:aDialogs[2] COLOR 0, 16777215 PIXEL
	fWBBOM()
	*/
	@ 004, 005 GROUP oGroup1 TO 068, 586 PROMPT "Adicionar o Produto " OF oFPSimulador:aDialogs[1] COLOR 0, 16777215 PIXEL

	@ 014, 014 SAY oSay4 PROMPT "Codigo" SIZE 025, 007 OF oGroup1 COLORS 0, 16777215 PIXEL
	@ 032, 018 SAY oSay5 PROMPT "Qtde" SIZE 018, 007 OF oGroup1 COLORS 0, 16777215 PIXEL
	@ 050, 012 SAY oSay20 PROMPT "Dt.Prod." SIZE 025, 007 OF oGroup1 COLORS 0, 16777215 PIXEL

	
	@ 030, 342 BUTTON obtImpCsv PROMPT "Imp CSV" SIZE 058, 016 OF oGroup1 ACTION  (sfImpSimulador()) PIXEL
	@ 050, 342 BUTTON obtLimpar PROMPT "Limpar Plano" SIZE 058, 016 OF oGroup1 ACTION  (sfLimpaSimula()) PIXEL	

	@ 030, 402 BUTTON obtAddDemanda PROMPT "Add Plano" SIZE 058, 016 OF oGroup1 ACTION  ( sfGrvDemanda(cGetCodDemanda,dGetDtDemanda,cGetDescDemanda,cGetTipoDemanda,nGetQtdDemanada)) PIXEL
	@ 050, 402 BUTTON obtRemDemanda PROMPT "Rem Plano	" SIZE 058, 016 OF oGroup1 ACTION (sfDelDemanda()) PIXEL
	@ 030, 462 BUTTON obtProcessar PROMPT "Processar" SIZE 058, 016 OF oGroup1 ACTION (sfProcDemanda()) PIXEL
	@ 050, 462 BUTTON obtDesproc PROMPT "Desprocessar" SIZE 058, 016 OF oGroup1 ACTION (sfDespDemanda()) PIXEL
	@ 030, 522 BUTTON oBtAtuResult PROMPT "Excel/Result" SIZE 058, 016 OF oGroup1 ACTION (sfTempSimulador()) PIXEL
	@ 050, 522 BUTTON oBtEnd PROMPT "Sair" SIZE 058, 016 OF oGroup1  ACTION oDlg:End() PIXEL

	@ 012, 040 MSGET oGetCodDemanda VAR cGetCodDemanda SIZE 099, 010 OF oGroup1 PICTURE  "@!" COLORS 0, 16777215 F3 "SB1" VALID (GetDescProd(1,cGetCodDemanda)) PIXEL
	@ 030, 040 MSGET oGetQtdDemanada VAR nGetQtdDemanada SIZE 060, 010 OF oGroup1 PICTURE  "@E 999,999,999.99" VALID nGetQtdDemanada>=0 COLORS 0, 16777215 PIXEL
	@ 048, 040 MSGET oGetDtDemanda VAR dGetDtDemanda SIZE 060, 010 OF oGroup1 PICTURE  "@D" COLORS 0, 16777215  PIXEL

	@ 014, 155 SAY oSay6 PROMPT "Descrição" SIZE 025, 007 OF oGroup1 COLORS 0, 16777215 PIXEL
	@ 012, 192 MSGET oGetDescDemanda VAR cGetDescDemanda   When .F. SIZE 222, 010 OF oGroup1 COLORS 0, 16777215 PIXEL
	@ 032, 155 SAY oSay7 PROMPT "Tipo" SIZE 025, 007 OF oGroup1 COLORS 0, 16777215 PIXEL
	@ 030, 192 MSGET oGetTipoDemanda VAR cGetTipoDemanda  When .F. SIZE 023, 010 OF oGroup1  COLORS 0, 16777215   PIXEL
	@ 070, 005 GROUP oGroup4 TO 295, 586 PROMPT "Demanda Projetada " OF oFPSimulador:aDialogs[1] COLOR 0, 16777215 PIXEL
	fWBDemanda()



	//@ 010, 004 SAY oSayTITULO PROMPT "SIMULADOR DE PRODUÇÃO - PRIMEIRO NÍVEL" SIZE 127, 007 OF oDlg COLORS 0, 16777215 PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

	RestArea(aArea)
Return

  
User Function zUltNum(cTab, cCampo, lSoma1)
    Local aArea       := GetArea()
    Local cCodFull    := ""
    Local cCodAux     := ""
    Local cQuery      := ""
    Local nTamCampo   := 0
    Default lSoma1    := .T.
      
    //Definindo o código atual
    nTamCampo := TamSX3(cCampo)[01]
    cCodAux   := StrTran(cCodAux, ' ', '0')
      
    //Faço a consulta para pegar as informações
    cQuery := " SELECT "
    cQuery += "   ISNULL(MAX("+cCampo+"), '"+cCodAux+"') AS MAXIMO "
    cQuery += " FROM "
    cQuery += "   "+RetSQLName(cTab)+" TAB "
    cQuery := ChangeQuery(cQuery)
    TCQuery cQuery New Alias "QRY_TAB"
      
    //Se não tiver em branco
    If !Empty(QRY_TAB->MAXIMO)
        cCodAux := QRY_TAB->MAXIMO
    EndIf
      
    //Se for para atualizar, soma 1 na variável
    If lSoma1
        cCodAux := Soma1(cCodAux)
    EndIf
      
    //Definindo o código de retorno
    cCodFull := cCodAux
      
    QRY_TAB->(DbCloseArea())
    RestArea(aArea)
Return cCodFull


//------------------------------------------------ 
Static Function fWBDemanda()
//------------------------------------------------ 
	Local oOK := LoadBitmap(GetResources(),'br_verde')
	Local oNO := LoadBitmap(GetResources(),'br_vermelho')

	DbSelectarea("ZTS")
	OWBDemanda := TCBrowse():new( 090 , 010, 564, 200,,,,  oGroup4,,,,,{||},,,,,,,.F.,'ZTS',.T.,,.F.,,,  )

	OWBDemanda:bLDblClick := {|| XBrGetDDB() }
	OWBDemanda:bDrawSelect := {|| XBrGetDDB() }


	OWBDemanda:AddColumn(TCColumn():New(" ", {|| If(ZTS->ZTS_STATUS<>'A',oOk,oNo)},,,,,,.T.,.F.,,,,.F., ) )
	OWBDemanda:AddColumn(TCColumn():New("Ordem",{||ZTS->ZTS_SEQ },,,,"LEFT",,.F.,.F.,,,,.F.,))
	OWBDemanda:AddColumn(TCColumn():New("Dt.Producao",{||ZTS->ZTS_DATA },,,,"LEFT",,.F.,.F.,,,,.F.,))
	OWBDemanda:AddColumn(TCColumn():New("Codigo",{||ZTS->ZTS_COD },,,,"LEFT",,.F.,.F.,,,,.F.,))
	OWBDemanda:AddColumn(TCColumn():New("Descrição"  ,{||ZTS->ZTS_DESCRI},,,,"LEFT",,.F.,.F.,,,,.F.,))
	OWBDemanda:AddColumn(TCColumn():New("Tipo"  ,{||ZTS->ZTS_TIPO},,,,"LEFT",,.F.,.F.,,,,.F.,))
	OWBDemanda:AddColumn(TCColumn():New("Quantidade"  ,{||ZTS->ZTS_QTDE},,,,"LEFT",,.F.,.F.,,,,.F.,))
	OWBDemanda:AddColumn(TCColumn():New("Status"  ,{||If(ZTS->ZTS_STATUS=='A','A Processar',"Processado")},,,,"LEFT",,.F.,.F.,,,,.F.,))

Return
//------------------------------------------------ 
Static Function XBrGetDDB()
//------------------------------------------------ 
	Local lRet:=.F.
	nLinha    := OWBDemanda:nat
	nColunaProd   := 4//OWBDemanda:colpos
	nColunaSEQ   := 2//OWBDemanda:colpos
	nColunaData   := 3//OWBDemanda:colpos
	uConteudoProd := Eval( OWBDemanda:ACOLUMNS[ nColunaProd ]:BDATA )
	uConteudoSEQ := Eval( OWBDemanda:ACOLUMNS[ nColunaSEQ ]:BDATA )
	uConteudoData := Eval( OWBDemanda:ACOLUMNS[ nColunaData ]:BDATA )


	lret:=	GetDescProd(1,uConteudoProd)

Return lret


//----------------------------------------------------------
/*/{Protheus.doc} GetDescProd
Função GetDescProd
@param Não recebe parâmetros
@return Não retorna nada
@author Reinaldo Dias
@owner Totvs S/A
@obs Funcao para buscar os dados do produto.             
@history
04/10/2012 - Acrescimo de cabecalho Protheus.Doc
/*/
//----------------------------------------------------------
Static Function GetDescProd(nfolder,cProduto)
	Local aArea  := GetArea()
	Local  cDescr       := Space(40)
	Local  cTipo        := Space(2)

	DBSelectArea("SB1")
	DBSetOrder(1)
	IF !Empty(cProduto) .AND. !MsSeek(xFilial("SB1")+UPPER(cProduto))
		MsgStop("Produto não cadastrado !!!")
		Return (.F.)
	Endif

	cDescr  := SB1->B1_DESC
	cTipo   := SB1->B1_TIPO
	if nfolder==1
		cGetCodDemanda:=UPPER(cProduto)
		cGetDescDemanda:= cDescr
		cGetTipoDemanda:= cTipo
		nGetQtdDemanada:=0
		dGetDtDemanda:= STOD("")
		oGetCodDemanda:Refresh()
		oGetDescDemanda:Refresh()
		oGetTipoDemanda:Refresh()
		oGetQtdDemanada:Refresh()
		oGetDtDemanda:Refresh()
	Endif
//cCrlLot  := If(SB1->B1_RASTRO ="L","Lote",If(SB1->B1_RASTRO ="S","Sub-Lote","Não"))
//cCrlEnd  := If(SB1->B1_LOCALIZ="S","Sim","Não")
//cLocal   := IF(Empty(cLocal),SB1->B1_LOCPAD,cLocal)
//c1UM     := SB1->B1_UM
//c2UM     := SB1->B1_SEGUM
//nFatConv := SB1->B1_CONV
//cTipConv := SB1->B1_TIPCONV
	RestArea(aArea)
Return(.T.)

//----------------------------------------------------------
Static Function sfGrvDemanda(cCod,dData,cDesc,cTipo,nQtde)
	Local cNumseq:='000'
	cNumseq:=sfNumseq()
	IF nQtde>0 .and. !empty(cCod)
		Begin Transaction
			ZTS->(RecLock( "ZTS",.T.))
			ZTS->ZTS_Filial:=xFilial("ZTS")
			ZTS->ZTS_SEQ   	:=cNumseq
			ZTS->ZTS_DATA  	:=dData
			ZTS->ZTS_COD   	:=cCod
			ZTS->ZTS_DESCRI :=cDesc
			ZTS->ZTS_TIPO	:=cTipo
			ZTS->ZTS_QTDE 	:=nQtde
			ZTS->ZTS_STATUS :='A'
			ZTS->(MsUnLock("ZTS"))
			if lMsErroAuto
				MostraErro()
				DisarmTransaction()
			else
				//MsgInfo("Produto adicionado "+cCod+CRLF+;					"Favor rodar o Processamento")
			Endif
		End Transaction
	Endif
	OWBDemanda:Refresh()
Return()

//----------------------------------------------------------
Static Function sfNumseq()
//----------------------------------------------------------
	Local cNumseq:='000'

	cNumseq:=u_zUltNum("ZTS", "ZTS_SEQ", .F.) //T SOMA

	cNumseq:=StrZero(VAL(cNumseq)+1,3)

return(cNumseq)


//----------------------------------------------------------
Static Function sfDelDemanda()
//----------------------------------------------------------
	IF XBrGetDDB()
		dbSelectArea('ZTS')
		if ZTS->(msSeek(xFilial("ZTS") + uConteudoSEQ))
			ZTS->(RecLock("ZTS", .F.))
			ZTS->(dbDelete())
			ZTS->(MsUnlock())

			sfDesProcN1()

			MsgStop("Demanda Excluída !!!")
		endif

	ENDIF
	OWBDemanda:Refresh()

return()


//----------------------------------------------------------
Static Function sfProcDemanda()
//----------------------------------------------------------
	IF XBrGetDDB()
		dbSelectArea('ZTS')
		if ZTS->(msSeek(xFilial("ZTS") + uConteudoSEQ))
			IF ZTS->ZTS_STATUS<>'P'
				Begin Transaction
					ZTS->(RecLock("ZTS", .F.))
					ZTS->ZTS_STATUS:='P'
					ZTS->(MsUnlock())
					//APMSGINFO("Processado com Sucesso ")
					sfProcN1(ZTS->ZTS_SEQ,ZTS->ZTS_COD,ZTS->ZTS_QTDE)
					U_MsgTimer ('Processado com Sucesso ! ', ZTS->ZTS_COD,2 )

				End Transaction
			Endif
		endif
	ENDIF
	OWBDemanda:Refresh()
return()
//----------------------------------------------------------
Static Function sfDespDemanda()
//----------------------------------------------------------
	IF XBrGetDDB()
		dbSelectArea('ZTS')
		if ZTS->(msSeek(xFilial("ZTS") + uConteudoSEQ))
			IF ZTS->ZTS_STATUS<>'A'
				Begin Transaction
					ZTS->(RecLock("ZTS", .F.))
					ZTS->ZTS_STATUS:='A'
					ZTS->(MsUnlock())
					sfDesProcN1()
					APMSGINFO("Demanda Desprocessada ! ")
				End Transaction
			Endif
		endif
	ENDIF
return()

//----------------------------------------------------------
Static Function sfProcN1(nOrdem,cProd,nQtde)
//----------------------------------------------------------
	Local aArea   := GetArea()
	Local cQuery    := ''
	Local cAliasQry := GetNextAlias()
	Local nRecCount:=0

	cQuery	:= "SELECT  CODIGO,COD_COMP,FRQPAD FROM VW_SG1N1 "
	cQuery	+= "  WHERE CODIGO= '"+cProd+"' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .T., .F.)
	dbSelectArea(cAliasQry)
	//Conta total e registros
	Count To nRecCount
	ProcRegua(nRecCount )
	dbGotop()
	do While !(cAliasQry)->(EoF())
		IncProc()
		Begin Transaction
			ZTT->(RecLock( "ZTT",.T.))
			ZTT->ZTT_Filial:=xFilial("ZTT")
			ZTT->ZTT_SEQ   	:=nOrdem
			ZTT->ZTT_PROD  	:=(cAliasQry)->CODIGO
			ZTT->ZTT_CODNEC	:=(cAliasQry)->COD_COMP
			ZTT->ZTT_QTDE	:=(cAliasQry)->FRQPAD*nQtde
			ZTT->(MsUnLock("ZTT"))
			if lMsErroAuto
				MostraErro()
				DisarmTransaction()
			else
				//MsgInfo("Produto adicionado "+cCod+CRLF+;					"Favor rodar o Processamento")
			Endif
		End Transaction
		(cAliasQry)->(DbSkip())
	Enddo

	(cAliasQry)->(dbCloseArea())

	RestArea(aArea)

	OWBDemanda:Refresh()
return()


//----------------------------------------------------------
Static Function sfDesProcN1()
//----------------------------------------------------------
	Local aArea   := GetArea()
	Local nRecCount:=0

	IF XBrGetDDB()
		dbSelectArea('ZTT')
		ZTT->(msSeek(xFilial("ZTT") + uConteudoSEQ))
		Begin Transaction
			While !Eof() .and. ZTT->ZTT_FILIAL == xFilial("ZTT") .and. ZTT->ZTT_SEQ == uConteudoSEQ
				ZTT->(RecLock("ZTT", .F.))
				ZTT->(dbDelete())
				ZTT->(MsUnlock())
				ZTT->(dbSkip())
				nRecCount=nRecCount+1
				//MsgStop("Demanda Excluída !!!")
				if lMsErroAuto
					MostraErro()
					DisarmTransaction()
					exit
				Endif
			Enddo
		End Transaction
		Alert("Total de " + StrZero(nRecCount,2) + " itens desprocessados !")

	endif
	RestArea(aArea)

	OWBDemanda:Refresh()
return()


//----------------------------------------------------------
Static Function sfTempSimulador()
//----------------------------------------------------------
// Executar a procedure e depois salvar o query com os dados
	Local aResult := {}
	Local cQryAux  := ""

	aResult := TCSPEXEC("sp_TEMP_SIMULADOR")

	IF empty(aResult)
		Conout('Erro na execução da Stored Procedure : '+TcSqlError())
	Else
		Conout("Retorno String : "+aResult[1])
		Conout("Retorno Numerico : "+str(aResult[2]))
		MsgInfo("Procedure Executada")
	Endif


	cQryAux := ""
	cQryAux += "SELECT * FROM TEMP_SIMULADOR "


	//verifica se tem PI Negativo
	Processa({|| sfVerPINeg() }, "Verificando PI")


	u_zQry2Excel(cQryAux , "SIMULADOR PCP - PRODUÇÃO")


return()

User Function zQry2Excel(cQryAux, cTitAux)
	Default cQryAux   := ""
	Default cTitAux   := "Título"
	Processa({|| sfProcessa(cQryAux, cTitAux) }, "Processando...")
Return

/*---------------------------------------------------------------------*
 | Func:  fProcessa                                                    |
 | Desc:  Função de processamento                                      |
 *---------------------------------------------------------------------*/ 
Static Function sfProcessa(cQryAux, cTitAux)
    Local aArea       := GetArea()
    Local aAreaX3     := SX3->(GetArea())
    Local nAux        := 0
    Local oExcel := FWMsExcelEx():New()
    Local cDiretorio  := 'C:\TEMP\'
    Local cArquivo    
    Local cArqFull    
    Local cWorkSheet  := "Demanda"
    Local cTable      := ""
    Local aColunas    := {}
    Local aEstrut     := {}
    Local aLinhaAux   := {}
	Local aColor   	  := {}
    Local cTitulo     := ""
    Local nTotal      := 0
    Local nAtual      := 0
	Local xTipo
    Default cQryAux   := ""
    Default cTitAux   := "Demanda"

	cArquivo    := 'ResultSimulador'+ SubStr(Time(),4,2) +'.XML'
	MakeDir("C:\TEMP")

    cArqFull    := cDiretorio + cArquivo
    cTable := cTitAux
     
    //Se tiver a consulta
	If !Empty(cQryAux)
        TCQuery cQryAux New Alias "QRY_AUX"
         
        DbSelectArea('SX3')
        SX3->(DbSetOrder(2)) //X3_CAMPO
         
        //Percorrendo a estrutura
        aEstrut := QRY_AUX->(DbStruct())
	
        ProcRegua(Len(aEstrut))
		For nAux := 1 To Len(aEstrut)
            IncProc("Incluindo coluna "+cValToChar(nAux)+" de "+cValToChar(Len(aEstrut))+"...")
            cTitulo := ""
           
            //Se conseguir posicionar no campo
			If SX3->(DbSeek(aEstrut[nAux][1]))
                cTitulo := Alltrim(SX3->X3_TITULO)
                 
                //Se for tipo data, transforma a coluna
				If SX3->X3_TIPO == 'D'
                    TCSetField("QRY_AUX", aEstrut[nAux][1], "D")					
				EndIf
			Else
				if LEFT(aEstrut[nAux][1],3)=='P20'
			   		//cTitulo := DTOC(Alltrim(aEstrut[nAux][1]))
					   //alert(Capital(Alltrim(aEstrut[nAux][1])))
					   cTitulo :=DTOC(STOD(SubStr((aEstrut[nAux][1]),2,8)))
				else
               	 //cTitulo := Capital(Alltrim(aEstrut[nAux][1]))
					cTitulo := (Alltrim(aEstrut[nAux][1]))
					if cTitulo =='SLDFIM'
					 nSldFim:=nAux
					endif
				endif
				//alert(cTitulo)
			
			EndIf
             
            //Adicionando nas colunas
            aAdd(aColunas, cTitulo)
		Next
          
		oExcel:AddworkSheet(cWorkSheet)  
		oExcel:AddTable (cWorkSheet, cTable)       
            //Adicionando as Colunas
		For nAux := 1 To Len(aColunas)
             oExcel:AddColumn(cWorkSheet, cTable, aColunas[nAux], 1, 2)
		Next
             
            //Definindo o total da barra
            DbSelectArea("QRY_AUX")
            QRY_AUX->(DbGoTop())
            Count To nTotal
            ProcRegua(nTotal)
            nAtual := 0
             
            //Percorrendo os produtos
            QRY_AUX->(DbGoTop())
		While !QRY_AUX->(EoF())
                nAtual++
                IncProc("Processando registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
             
                //Criando a linha
                aLinhaAux := Array(Len(aColunas))
				aColor :={}
			For nAux := 1 To Len(aEstrut)
                    aLinhaAux[nAux] := &("QRY_AUX->"+aEstrut[nAux][1])
					
					xTipo:= (VALTYPE(aLinhaAux[nAux]))

					if xTipo == "N"
           				if   aLinhaAux[nAux]<0
						   	//Alterando atributos da linha e adicionando
						     AAdd( aColor, nAux  )
						endif
					endif
			Next
			
			if Len(aColor)>0
           			//Alterando atributos da linha e adicionando
					oExcel:SetCelFrColor("#FF0000") //branco #FFFFFF
					//oExcel:SetCelBgColor("#FF0000")
					//Adiciona a linha no Excel
					oExcel:AddRow(cWorkSheet, cTable, aLinhaAux,aColor)
				else
					oExcel:AddRow(cWorkSheet, cTable, aLinhaAux)
				endif	

			QRY_AUX->(DbSkip())
		EndDo


		//Ativando o arquivo e gerando o xml
		oExcel:Activate()
		oExcel:GetXMLFile(cArqFull)

		//Verifica se o Excel esta instalado
		If ApOleClient("MSEXCEL")
			oExcel := MsExcel():New()
			oExcel:WorkBooks:Open(cArqFull)
			oExcel:SetVisible(.T.)
			oExcel:Destroy()
		Else
			//Se existir a pasta do LibreOffice 5
			If ExistDir("C:\Program Files (x86)\LibreOffice 5")
				WaitRun('C:\Program Files (x86)\LibreOffice 5\program\scalc.exe "'+cDiretorio+cArquivo+'"', 3)

				//Senão, abre o XML pelo programa padrão
			Else
				ShellExecute("OPEN", cArquivo, "", cDiretorio, 3)

			EndIf
		EndIf

		QRY_AUX->(DbCloseArea())
	EndIf

	RestArea(aAreaX3)
	RestArea(aArea)

Return

//----------------------------------------------------------
Static Function sfVerPINeg()
//----------------------------------------------------------
	Local cQryAux1
	Local aPiNeg := {}
	Local nTotal,nAux
	Local dData :=  DATE()
	
	//fecha o alias temporário
	If Select("QRY_AUX1") > 0
		dbSelectArea("QRY_AUX1")
		dbCloseArea()
	EndIf




	cQryAux1 := ""
	cQryAux1 += " SELECT COMP, TIPO,B1_DESC DESCRIC, SLDFIM,   "
	cQryAux1 += " ISNULL(ZTS_COD,'') ZTS_COD,   "
	cQryAux1 += " ISNULL(QTDPLANO,0) QTDPLANO,   "
	cQryAux1 += " ((SLDFIM * -1) - ISNULL(QTDPLANO,0)) FALTA,   "
	cQryAux1 += " GETDATE() AS DTPI  "
	cQryAux1 += " FROM TEMP_SIMULADOR   "
	cQryAux1 += " OUTER APPLY (SELECT ZTS_COD,SUM(ZTS_QTDE) QTDPLANO FROM ZTS010 ZTS   "
	cQryAux1 += " WHERE ZTS_COD=COMP AND ZTS.D_E_L_E_T_=''   "
	cQryAux1 += " AND ZTS_STATUS='P' GROUP BY ZTS_COD) ZTS  "
	cQryAux1 += " OUTER APPLY ( SELECT B1_DESC FROM SB1010 SB1 WHERE SB1.D_E_L_E_T_='' AND B1_COD=COMP) SB1 "
	cQryAux1 += " WHERE TIPO='PI' AND SLDFIM < 0   "
	cQryAux1 += " AND ((SLDFIM * -1) - ISNULL(QTDPLANO,0))>=1  "



	cQryAux1 := ChangeQuery(cQryAux1)
	TCQuery cQryAux1 New Alias "QRY_AUX1"

	DbSelectArea("QRY_AUX1")
	QRY_AUX1->(DbGoTop())
	Count To nTotal

	//Percorrendo os produtos
	QRY_AUX1->(DbGoTop())
	While !QRY_AUX1->(EoF())
		aAdd(aPiNeg,{QRY_AUX1->COMP,;
			dData,;
			QRY_AUX1->DESCRIC,;
			QRY_AUX1->TIPO,;
			QRY_AUX1->FALTA})
		QRY_AUX1->(DbSkip())
	EndDo
	IF nTotal>0

		if  MsgYesNo("Deseja incluir PI com saldo negativo ?","Demanda Automática")
			For nAux := 1 To Len(aPiNeg)
				//MsgInfo(aPiNeg[nAux][1])
				//sfGrvDemanda(cCod,dData,cDesc,cTipo,nQtde)
				sfGrvDemanda(aPiNeg[nAux][1],aPiNeg[nAux][2],aPiNeg[nAux][3],aPiNeg[nAux][4],aPiNeg[nAux][5])
				sfProcDemanda()

			Next
				Result := TCSPEXEC("sp_TEMP_SIMULADOR")
				QRY_AUX1->(DbCloseArea())
				sfVerPINeg()
		endif
	

		endif
	aResult := TCSPEXEC("sp_TEMP_SIMULADOR")




return()


// Limpar tudo
//----------------------------------------------------------
Static Function sfLimpaSimula()
//----------------------------------------------------------
Local cSQL    := ""
Local cAliAtu := ""
Local nErr    := 0
Local cLogErr := ""
	if  MsgYesNo("Deseja Limpar Simulação ?","Apagar Demanda")
		/*
		DbSelectarea("ZTS")
		ZTS->(DbGoTop())
		While !ZTS->(EoF())
			ZTS->(RecLock("ZTS",.F.))
			ZTS->(DbDelete())
			ZTS->(MsUnLock())
			ZTS->(DbSkip())		
		EndDo
	
		DbSelectarea("ZTT")
		ZTT->(DbGoTop())
		While !ZTT->(EoF())
			ZTT->(RecLock("ZTT",.F.))
			ZTT->(DbDelete())
			ZTT->(MsUnLock())
			ZTT->(DbSkip())
		
		EndDo
*/

			
			//Deleta tudo que existe na tabela destino
			cAliAtu := "ZTT"
			cSQL := "DELETE FROM "+RetSQLName(cAliAtu)+" "
			nErr := TcSqlExec(cSQL)
			
			//Se houve Erro
			If nErr != 0
				cLogErr += "- Tabela "+cAliAtu+Chr(13)+Chr(10)
				//TcSQLExec("DELETE " + RetSqlName("ZTT") )
			endif

			//Deleta tudo que existe na tabela destino
			cAliAtu := "ZTS"
			cSQL := "DELETE FROM "+RetSQLName(cAliAtu)+" "
			nErr := TcSqlExec(cSQL)
			
			If nErr != 0
				cLogErr += "- Tabela "+cAliAtu+Chr(13)+Chr(10)
				//TcSQLExec("DELETE " + RetSqlName("ZTT") )
			endif

			//Se houve erro
			If !Empty(cLogErr)
				Aviso('Atenção', "Houveram erros nas tabelas: "+Chr(13)+Chr(10)+cLogErr, {'Ok'}, 03)
				
			Else
				MsgInfo("Processo terminado!", "Atenção")
			EndIf

		aResult := TCSPEXEC("sp_TEMP_SIMULADOR")
	Endif
return()



//Importar do Excel Plano

Static Function sfImpSimulador()
	Local aButton		:= {}
	Local aSay			:= {}
	Local nOpc			:= 0
	Local cCadastro		:= "Importação do Plano Simulador"
	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Criacao da Interface                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd ( aSay , "Importação do Plano de Produção diario utilizando planilha excel como base" )
	aAdd ( aSay , "Atenção: o formato do arquivo deve ser .CSV")
	aAdd ( aSay , "A primeira linha deve conter o cabecalho :Codigo, Data e Qtde ")
	aAdd ( aSay , "Data no formato dd/mm/aaaa " )
	aAdd ( aButton , { 1 , .T. , { || nOpc := 1,	FechaBatch()	}} )
	aAdd ( aButton , { 2 , .T. , { || FechaBatch()					}} )

	FormBatch( cCadastro , aSay , aButton )

	If nOpc == 1

		_cArqTab 	:= cGetFile("Arquivos |*.CSV|Todos os Arquivos|*.*",OemToAnsi("Selecione o arquivo")) //,0,,.T.,GETF_OVERWRITEPROMPT)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verificando se o processo ira ser continuado                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if !File(_cArqTab)

			MsgBox("O arquivo nao foi localizado. O PROCESSO NAO PODERA SER INICIADO.","ATENCAO","ERRO")

		ElseIf MsgBox("Confirma importação do Plano para o Simulador ?", "Importação do Plano", "YESNO" )

			Processa( { |lEnd| impPlanSimu(_cArqTab) } , "Simulador de Produção" , "Importando Plano de Produção" , .T. )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ renomeando o arquivo lido                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			fClose( _cArqTab )
			nDotPos := At( ".", _cArqTab )
			if nDotPos > 0
				_cNewArqTab := Substr( _cArqTab, 1, nDotPos ) + "ok"
				__CopyFile( _cArqTab, _cNewArqTab )
			endif
			fErase( _cArqTab )
		Else
			MsgBox("O arquivo nao foi localizado. O PROCESSO NAO PODERA SER INICIADO.","ATENCAO","ERRO")
		Endif

	Endif

Return()

Static Function impPlanSimu(_cArqTab)
	Local cLinha  := ""
	Local aDados  := {}
	Local i :=0
	Local dData 
	Local nQtdeProd :=0
	
	nHandle := FT_FUSE(_cArqTab)
	// Se houver erro de abertura abandona processamento
	if nHandle = -1
	    Alert('Erro na abertura do arquivo !')
		return
	endif

	ProcRegua(3) // Numero de processos/sub-processos	
	
	FT_FGOTOP()
	IncProc("Realizando leitura do arquivo ...")		//1o.
	cLinha := FT_FREADLN()
	If !FT_FEOF()
		While !FT_FEOF()
			cLinha := FT_FREADLN()
			AADD(aDados,Separa(cLinha,";",.T.))			
			FT_FSKIP()
		EndDo
	Else
		MsgBox("O arquivo de nome " + AllTrim(_cArqTab) + " está vazio!","Atencao!")
		return
	Endif
	IncProc("Importando dados ...")		//2o.
	ProcRegua(Len(aDados))
	//valida dados
	For i:=2 to Len(aDados)
		if (GetDescProd(1,aDados[i][1]))
		  dData := ctod(aDados[i][2])
		  nQtdeProd := VAL(aDados[i][3])
		  sfGrvDemanda(cGetCodDemanda,dData,SB1->B1_DESC,SB1->B1_TIPO,nQtdeProd)
		  sfProcDemanda()

		else
			Alert('A Linha ' + str(i) + ' possui dados inválidos, verifique !')
		endif

	Next	
	// Fecha o Arquivo
	FT_FUSE()
	IncProc("Finalizando processo...")	//3o.
	ApMsgInfo("Importação do plano foi concluida com sucesso!","Importador CSV - Simulador")

Return                       

