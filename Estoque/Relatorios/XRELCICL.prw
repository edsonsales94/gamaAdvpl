#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TOTVS.ch"
#Include 'TopConn.ch'
#Include "RPTDEF.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³XRELCICL ºAutor  ³ Ricky Moraes        º Data ³  03/02/2021 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressao Documento Inventário Ciclico       no endereço   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function XRELCICL()
	If ValidPerg()

		IF !EMPTY(ZTI->ZTI_DOC)
			MsAguarde({|| ImpRelCicli(ZTI->ZTI_DOC) },"Impressão de Documento","Aguarde...")
		ENDIF
	EndIf

Return

Static Function ImpRelCicli(cZTI_DOC)

	Local cQuery	:= ""
	Local cImpress  := Alltrim(MV_PAR06) //pego o nome da impressora
/*
	Local nLin		:= 0
	Local nLinT		:= 0
	Local nCol		:= 0
	Local nLinC		:= 0
	Local nColC		:= 0
	Local nWidth	:= 0
	Local nHeigth   := 0
	Local lBanner	:= .T.		//Se imprime a linha com o código embaixo da barra. Default .T.
	Local nPFWidth	:= 0
	Local nPFHeigth	:= 0
	Local lCmtr2Pix	:= .T.		//Utiliza o método Cmtr2Pix() do objeto Printer.Default .T.
	Local nCodPagina:=0 // numero de codigos por pagina
	Local lLegacy  := .F.
	Local lSetup   := .T.
	Local cTitBar:=space(60)
	Local cSaldoFisico
	Local cGrupo:=space(15)
*/
	Public nLin		:= 0
	Public nLinT		:= 0
	Public nCol		:= 0
	Public nLinC		:= 0
	Public nColC		:= 0
	Public nWidth	:= 0
	Public nHeigth   := 0
	Public lBanner	:= .T.		//Se imprime a linha com o código embaixo da barra. Default .T.
	Public nPFWidth	:= 0
	Public nPFHeigth	:= 0
	Public lCmtr2Pix	:= .T.		//Utiliza o método Cmtr2Pix() do objeto Printer.Default .T.
	Public nCodPagina:=0 // numero de codigos por pagina
	Public lLegacy  := .F.
	Public lSetup   := .T.
	Public cTitBar:=space(60)
	Public cSaldoFisico
	Public cGrupo:=space(15)
	Public nPag 		:=0
	Public nTotPg :=0




	nLinC		:= 4.95		//Linha que será impresso o Código de Barra
	nColC		:= 1.5		//Coluna que será impresso o Código de Barra
	nWidth	 	:= 0.0164	//Numero do Tamanho da barra. Default 0.025 limite de largura da etiqueta é 0.0164
	nHeigth   	:= 0.6		//Numero da Altura da barra. Default 1.5 --- limite de altura é 0.3
	lBanner		:= .T.		//Se imprime a linha com o código embaixo da barra. Default .T.
	nPFWidth	:= 0.8		//Número do índice de ajuste da largura da fonte. Default 1
	nPFHeigth	:= 0.9		//Número do índice de ajuste da altura da fonte. Default 1
	lCmtr2Pix	:= .T.		//Utiliza o método Cmtr2Pix() do objeto Printer.Default .T.


	MsProcTxt("Identificando a impressora...")

	Private cLogo		:= GetMV("ES_LOGO", .F., "\SYSTEM\BRASITECH.BMP")
	
	
	Private nLargura	:= 80
	Private nRecTr1		:=0


	Private oFont08	:= TFont():New('Courier',08,08,,.F.,,,,.T.,.F.,.F.)
	Private oFont16	:= TFont():New('Courier',16,16,,.F.,,,,.T.,.F.,.F.)
	Private oFont20	:= TFont():New('Courier',20,20,,.F.,,,,.T.,.F.,.F.)
	Private oFont12	:= TFont():New('Courier',10,10,,.F.,,,,.T.,.F.,.F.)
	Private oFont16N	:= TFont():New('Courier',16,16,,.T.,,,,.T.,.F.,.F.)
	Private oFont25	:= TFont():New('Courier',25,25,,.F.,,,,.T.,.F.,.F.)
	Private oFont30  := TFont():New("Courier",,30,,.F.)
	Private oFont07  := TFont():New("Courier",,07,,.F.)

	//Private oPrinter := FWMSPrinter():New("produto"+Alltrim(__cUserID)+".etq",IMP_PDF,lAdjustToLegacy,"/spool/",lDisableSetup,,,Alltrim(cImpress) /*parametro que recebe a impressora*/)
	Private oPrinter:= FWMSPrinter():New("Ciclico"+Alltrim(cZTI_DOC)+".pdf",IMP_PDF,lLegacy, NIL, lSetup, NIL, NIL, NIL, NIL, .F.)// Ordem obrigátoria de configuração do relatório
	oPrinter:SetPortrait()
	oPrinter:SetMargin(1,1,1,1) // nEsquerda, nSuperior, nDireita, nInferior
	oPrinter:SetPaperSize(DMPAPER_A4)//:setPaperSize(9)
	oPrinter:cPathPDF := "c:\temp\" // Caso seja utilizada impressão em IMP_PDF


	//Para saber mais sobre o componente FWMSPrinter acesse http://tdn.totvs.com/display/public/mp/FWMsPrinter

	cQuery := "SELECT * FROM ZTI010 ZTI "
	cQuery += " INNER JOIN ZTF010 ZTF ON"
	cQuery += " ZTF.D_E_L_E_T_=''"
	cQuery += " AND ZTI_FILIAL=ZTF_FILIAL"
	cQuery += " AND ZTI_FILIAL='" + xFilial("ZTI") + "'"
	cQuery += " AND ZTI.D_E_L_E_T_=''"
	cQuery += " AND ZTF_DOC=ZTI_DOC"
	cQuery += " AND ZTI_DOC='"+cZTI_DOC+"'"
	cQuery += " ORDER BY ZTF_DOC,ZTF_ITEM "

	TcQuery cQuery New Alias "QRYTMP"
	//Conta total e registros
	Count To nRecTr1

	ProcRegua(nRecTr1)

	QRYTMP->(DbGoTop())

	//oPrinter:SetMargin(001,001,001,001)

	nLin := 6
	nLinT:=80 //62
	nCol := 5
	nTotCodPag:=16 //total codigos por pagina
	Quebra:= 0
	nPag:=1
	nTotPg := 0 
	WHILE  nRecTr1> Quebra 
		Quebra:=Quebra+nTotCodPag
		nTotPg :=nTotPg +1
	EndDo


	cabPag()

	nCodPagina:=1
	cColetor:=''

	

	While QRYTMP->(!Eof())
		
		MsProcTxt("Imprimindo "+alltrim(QRYTMP->ZTF_COD)+"...")
		IncProc()
		ctpSaldo:="COLETADO/DIGIT."
		IF Alltrim(MV_PAR01) =="Digitado"
			
			IF QRYTMP->ZTF_STATUS<>'0'
				cColetor:=ltrim(QRYTMP->ZTF_USUARI)
				cSaldoFisico := alltrim(TRANSFORM(QRYTMP->ZTF_QUANT, '@E 999,999.999'))
			ELSE 
				cColetor:=''
				cSaldoFisico := space(10)
			ENDIF
		ELSEIF Alltrim(MV_PAR01) =="Saldo_Sistema"
			cSaldoFisico := alltrim(TRANSFORM(QRYTMP->ZTF_SLDSBF, '@E 999,999.999'))
			ctpSaldo:="SLDO.SISTEMA"
		ELSE
			cSaldoFisico:=space(10)
			ctpSaldo:="INFORME SLDO."
		ENDIF

		oPrinter:Box(nLinT-13,003,nLinT+28,590)
		oPrinter:Box(nLinT-13,285,nLinT+28,590)
		oPrinter:Box(nLinT-13,450,nLinT+28,590)

		cTitBar :=(alltrim(QRYTMP->ZTF_COD) + " - " + alltrim(QRYTMP->ZTF_DESCRI))
		oPrinter:Code128(nLinT+3/*nRow*/ ,020/*nCol*/, alltrim(QRYTMP->ZTF_COD)/*cCode*/,1/*nWidth*/,20/*nHeigth*/,.F./*lSay*/,,)
		oPrinter:Say(nLinT,020,SUBSTR(cTitBar,1,55),oFont12)

		oPrinter:Say(nLinT,295,'ARMZ. - '+alltrim(QRYTMP->ZTF_LOCAL)+' | END. - '+ alltrim(QRYTMP->ZTF_LOCALI),oFont12)
		IF !empty(alltrim(QRYTMP->ZTF_LOCALI) )
			oPrinter:Code128(nLinT+3/*nRow*/ ,295/*nCol*/, alltrim(QRYTMP->ZTF_LOCALI)/*cCode*/,1/*nWidth*/,20/*nHeigth*/,.F./*lSay*/,,)
		ENDIF

		oPrinter:Say(nLinT,460,ctpSaldo+'  |  UNIDADE',oFont12)
		oPrinter:Say(nLinT+15,460, cSaldoFisico + ' | ' + alltrim(QRYTMP->ZTF_UM),oFont16)
		oPrinter:Say(nLinT+25,460, cColetor,oFont07)
		
		if nCodPagina>nTotCodPag
			
			nLinT+=42//61
			FimPag()
			nCodPagina:=1
			nPag:=nPag+1
					
			nLinT:=80
			cabPag()
			//alert('1')
		else
			nCodPagina:=nCodPagina+1
			nLinT+=42//61
			
		Endif

		QRYTMP->(DbSkip())
	EndDo

	FimPag()
	IF Alltrim(MV_PAR01) =="Saldo_Sistema"
		MsgInfo("O Saldo do sistema é referente a data do documento. " + Chr(13) + Chr(10)  + Chr(13) + Chr(10) +"Data : "+ dtoc(ZTI->ZTI_DATA) , "Atenção")

	ENDIF
	oPrinter:Print()
	QRYTMP->(DbCloseArea())

Return

/*Montagem da tela de perguntas*/
Static Function ValidPerg()

	Local aRet 		:= {}
	Local aParamBox	:= {}
	Local lRet 		:= .F.
	Local aOpcoes	:= {}

	aOpcoes :={"Digitado","Saldo_Sistema","Oculta_Saldos"}

	aadd(aParamBox,{02,"Imprimir Saldos em "			,0,aOpcoes			,100,".T.",.T.,".T."})		// MV_PAR04

	If ParamBox(aParamBox,"Documento Ciclico ",/*aRet*/,/*bOk*/,/*aButtons*/,.T.,,,,FUNNAME(),.T.,.T.)
		lRet := .T.
	EndIf

Return lRet

Static Function cabPag()
	Local nLargura	:= 80
	Local cNumDoc := ALLTRIM(ZTI->ZTI_DOC)
	//Local dDataEmissao :=  STOD(ZTI->ZTI_DATA)

	Local cTipo:=''

	IF ZTI->ZTI_TIPO=='A'
		cTipo:='AUTO/SISTEMA'
	ELSE
		cTipo:='MANUAL'
	ENDIF


	//Local cProduto := TRB->C2_PRODUTO
	//Local cTipo := POSICIONE("SB1",1,xFilial("SB1")+cProduto,"B1_TIPO")
	//Local cDesc := POSICIONE("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")
	//cUsuInc:=FWLeUserlg("ZTI->ZTI_USERLGI",1)
	oPrinter:StartPage()
	//oPrinter:Box(009,003,050,092) //1
	//oPrinter:Box(009,092,050,500) //2
	//oPrinter:Box(009,413,050,590) //Box(009,338,050,590)
	//oPrinter:Box(009,498,050,590)//5
	//oPrinter:Box(009,092,050,118)//6

	oPrinter:SayBitmap(012, 008, cLogo, nLargura, nLargura * 0.4)
	oPrinter:Say(036, 097, "DOC.INVENTÁRIO CICLÍCO", oFont30)


	oPrinter:Code128(016/*nRow*/ ,419/*nCol*/, cNumDoc/*cCode*/,1/*nWidth*/,20/*nHeigth*/,.F./*lSay*/,,)
	oPrinter:Say(042, 419,"DOC.: " + AllTrim(cNumDoc) , oFont08)

	oPrinter:Say(020, 500, "IMPRESSÃO: " +dtoc(dDataBase), oFont08)
	oPrinter:Say(031, 500, "HORA: " + TIME()   , oFont08)
	oPrinter:Say(042, 500, "PÁGINA: " + AllTrim(Str(nPag)) , oFont08)


	oPrinter:Say(059, 008, "BASE: " + cTipo   , oFont08)
	oPrinter:Say(059, 095, "EMISSOR: "+ ZTI->ZTI_USUARIO  , oFont08)
	oPrinter:Say(059, 207, "DT.EMISSÃO: " + dtoc(ZTI->ZTI_DATA) , oFont08)
	oPrinter:Say(059, 320, "OBS.: "+ ZTI->ZTI_OBS , oFont08)
	oPrinter:Say(059, 450, "COLETOR: " , oFont08)

	oPrinter:Line( 005,003,005,590 )

	oPrinter:Line( 048,003,048,590 )

	oPrinter:Line( 063,003,063,590 )
	//oPrinter:Line( 066,003,066,590 )
	//oPrinter:Box(009,003,050,092) //1

Return()

Static Function FimPag()

	oPrinter:Box(nLinT-13,003,nLinT+25,590)
	oPrinter:Say(nLinT+7,255,"Fim da Página: " +alltrim( Str(nPag))+ " de " + alltrim(Str(nTotPg)) ,oFont12)
	oPrinter:EndPage()
	

Return()


