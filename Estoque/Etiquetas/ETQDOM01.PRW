#include 'protheus.ch'
#include 'parmtype.ch'
#include "rwmake.ch"
#include "topconn.ch"

user function ETQDOM01()
	Local bOk := {|| ETQDM01A() }
	Local bCancel:= {|| Fechar() }
	Local aArea := GetArea()
	Local aButtons := {}

	Private cCod, nQtd1, nQtd2,cOp,cTitle,cDoc,cDesc,cLm,cLocali,cBarras,nQtdcxm
	Private oTurno, oQtd1, oQtd2,oOP,oDlg,oDoc,oSay2,oSay3
	Private nimpress
	aSize := MsAdvSize(.F.)
	nimpress:=2   // impressora TLP 2844

	//aadd(aButtons,{'HISTORIC',{|| IncModSd3()}, "Inlcuir MOD...", "Inlcuir MOD" , {|| .T.}} )

	cTitle:="Etiquetas Avulso por Lote"
	// Cria Fonte para visualização
	oFont1 := TFont():New('Courier new',,-14,.T.,.T.)
	oFont2 := TFont():New('Arial',,-20,.T.,.T.)
	oFont3 := TFont():New("AriaL",,-15,,.T.) // Definicao do Objeto da Fonte
	oFont4 := TFont():New("AriaL",,-30,,.T.) // Definicao do Objeto da Fonte

	Define MsDialog oDlg TITLE cTitle STYLE DS_MODALFRAME From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL

	oSay:= TSay():New(45,05,{||'Ord.Produção:'},oDlg,,oFont1,,,,.T.,CLR_BLUE,CLR_RED,200,20)
	oSay:= TSay():New(65,05,{||'Turno:'},oDlg,,oFont1,,,,.T.,CLR_BLUE,CLR_RED,200,20)
	oSay:= TSay():New(85,05,{||'Lote:'},oDlg,,oFont1,,,,.T.,CLR_BLUE,CLR_RED,200,20)
	oSay:= TSay():New(105,05,{||'Dia:'},oDlg,,oFont1,,,,.T.,CLR_BLUE,CLR_RED,200,20)
	oSay:= TSay():New(125,05,{||'Qtd.Etiquetas:'},oDlg,,oFont1,,,,.T.,CLR_BLUE,CLR_RED,200,20)
	oSay2:=tSay():New(145,010 ,{||space(40)}        ,oDlg,,oFont2 ,,,,.T.)
	oSay3:=tSay():New(165,010 ,{||space(40)}        ,oDlg,,oFont2 ,,,,.T.)
	oSay4:=tSay():New(185,010 ,{||space(40)}        ,oDlg,,oFont2 ,,,,.T.)
	oSay5:=tSay():New(205,010 ,{||space(40)}        ,oDlg,,oFont2 ,,,,.T.)

	cDesc:=""
	cLm:=""
	cLocali:=""
	cBarras:=""
	cCod:=""
	cOP:=SPACE(12)
	cTurno:= SPACE(5)
	nQtd1:= SPACE(10)
	nQtd2:= 1
	nQtd3:= day(ddatabase)

	@45, 65 GET oOP    Var cOP  Valid ( ValOP()  ) SIZE 060,09 OF oDlg PIXEL
	@65,65  GET oTurno VAR cTurno SIZE 096,015 OF oDlg PIXEL PICTURE "@!"
	@85,65  GET oQtd1  VAR nQtd1 SIZE 096,015 OF oDlg PIXEL PICTURE "@!"
	@105,65  GET oQtd3  VAR nQtd3 Valid ( nQtd3<(nQtd3+1) .and. nQtd3<=31 ) SIZE 096,015 OF oDlg PIXEL PICTURE "@E 99"
	@125,65  GET oQtd2  VAR nQtd2 SIZE 096,015 OF oDlg PIXEL PICTURE "@E 999,999"

	//ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||lOk:=.T.,oDlg:End()},{||oDlg:End()},,@aButtons))
	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg, bOk , bCancel ,,)) CENTERED
	RestArea(aArea)

return

Static Function Fechar()
	If MsgBox("Confirma Saida ?","Atencao","YESNO")
		oDlg:End()
	Endif
Return

Static Function ValOP()
	Local lRet:=.F.
	dbselectarea("SC2")
	dbsetorder(1)
	dbseek(xfilial("SC2")+alltrim(cOP))
	if !eof()
		//    if (!GetMv("MV_ULMES") < SC2->C2_EMISSAO .AND. !GetMv("MV_ULMES") < SC2->C2_DATRF )
		//     ALERT("Op fora do Periodo do Ultimo Fechamento!!")
		//    else
		if LEN(ALLTRIM(DTOS(C2_DATRF)))==0
			lRet:=.T.
			cOP:=C2_NUM+C2_ITEM+C2_SEQUEN
			cDesc:=Posicione("SB1",1,XFILIAL("SB1")+SC2->C2_PRODUTO,"B1_DESC")
			cBarras:=Posicione("SB1",1,XFILIAL("SB1")+SC2->C2_PRODUTO,"B1_DUN14")
			cEnder:=Posicione("SBE",1,XFILIAL("SBE")+"20"+SC2->C2_XEND,"BE_LOCALIZ")
			cCod:=SC2->C2_PRODUTO
			cLocali:=SC2->C2_XEND
			nQtdcxm:=Posicione("SB1",1,XFILIAL("SB1")+SC2->C2_PRODUTO,"B1_LM")
			IF alltrim(SC2->C2_XEND)=="LINHA1"
				cLm:='01'
			ELSEIF alltrim(SC2->C2_XEND)=="LINHA2"
				cLm:='02'
			ELSEIF alltrim(SC2->C2_XEND)=="LINHA3"
				cLm:='03'
			ELSEIF alltrim(SC2->C2_XEND)=="LINHA4"
				cLm:='04'
			ELSEIF alltrim(SC2->C2_XEND)=="LINHA5"
				cLm:='05'
			ENDIF
			oSay2:cCaption:=left(Posicione("SB1",1,XFILIAL("SB1")+SC2->C2_PRODUTO,"B1_DESC"),40)
			oSay3:cCaption:= " Local: "+cEnder+" Inicio.: "+dtoc(SC2->C2_DATPRI)
			oSay4:cCaption:= " Planejado : " +ALLTRIM(str(SC2->C2_QUANT))+"    Produzido: "+ALLTRIM(str(SC2->C2_QUJE))
			oSay5:cCaption:= " A Produzir : " +ALLTRIM(str(SC2->C2_QUANT-SC2->C2_QUJE))
			oSay2:nClrText:= 255 ; oSay2:Refresh() ; oSay3:Refresh() ; oSay4:Refresh() ; oSay5:Refresh()
		else
			ALERT("Ordem de Produção ja foi encerrada!!")
		endif
		//  endif
	Else
		alert("Ordem de Produção Invalida !!! Tente novamente.")
	Endif
Return lRet

Static Function PEGACOD()
	Local cRet
	Local cAliasCB0:= GetNextAlias()
	BeginSql Alias cAliasCB0
	SELECT ISNULL(MAX(CB0_CODETI),"0") NUMETQ FROM %table:CB0% CB0
	WHERE CB0_FILIAL=%xFilial:CB0% AND CB0_CODETI<>''
	AND CB0.%NotDel%
	EndSql
	dbSelectArea(cAliasCB0)

	DbGoTop()
	cRet := STRZERO( VAL((cAliasCB0)->NUMETQ)+1 , 10)
	dbSelectArea(cAliasCB0)
	dbcloseArea(cAliasCB0)
Return cRet

Static Function ETQDM01A()
	Local cModPrint:="ZM400"
	Local cCodEtq, x
	for x:=1 to nQtd2
	   cCodEtq:= PEGACOD()
		CB0->(RecLock("CB0",.T.))
		CB0->CB0_FILIAL:=XFILIAL("CB0")
		CB0->CB0_CODETI:=cCodEtq
		CB0->CB0_OP:=ALLTRIM(cOP)
		CB0->CB0_TIPO:="PA"
		CB0->CB0_LOCAL:="01"
		CB0->CB0_DTNASC:=dDataBase
		CB0->CB0_CODPRO:=ALLTRIM(cCod)
		CB0->CB0_LOCALI:=cLocali
		CB0->CB0_LOTE:=alltrim(nQtd1)
		CB0->CB0_QTDE:=nQtdcxm
		CB0->CB0_USUARI:=cUserName      
      CB0->CB0_SERIEE:="AVS"  // IDENTIFICA COMO ETIQUETA AVULSA 		
		CB0->(MsUnlock())
	next
	if nimpress=2
		cModPrint:="TLP 2844"
		MSCBPRINTER(cModPrint,"LPT1",,,.F.,,,,,,.T.)
		MSCBCHKStatus(.F.)
		MSCBBEGIN(nQtd2,3)  //TAMANH 52 MM
		// Box da Etiqueta -------------------------------------------------------
		MSCBBOX(04,01,101,47,2)
		// Dados da Etiqueta -------------------------------------------------------
		if val(cLm)==2
			MSCBSAY(04,01,"__"+SPACE(2)+PADR(cDesc,54,"_")            ,"N","3" ,"1,2",.T.)
		else
			MSCBSAY(07,02,cDesc,"N","3" ,"1,2")
		endif
		MSCBSAY(07,09,"Nr.O.P: "+ALLTRIM(cOP),"N","3" ,"1,2")
		MSCBSAY(07,15,"Cod.: "+ALLTRIM(cCod),"N","3" ,"1,2")
		MSCBSAY(54,15,"Nr.Lote: "+alltrim(nQtd1)+" Qt.Emb: "+cValToChar(nQtdcxm),"N","3" ,"1,2")
		MSCBSAY(07,21,"Data: "+STRZERO(nQtd3,2)+"/"+substr(alltrim(Dtoc(dDataBase)),4,7),"N","3" ,"1,2")
		MSCBSAY(41,21,"Turno: "+alltrim(cTurno),"N","3" ,"1,2")
		MSCBSAY(71,21,"LM: "+cLm ,"N","3" ,"1,2")
		MSCBSAY(15,40, cBarras ,"N","3" ,"3,3")

		// codigos de barras da Etiqueta -------------------------------------------------------
		MSCBSAYBAR ( 66 , 08 , ALLTRIM(cCodEtq) , "N","MB07",6,.F.,.F.,.F.,"C",2,2,.F.)
		MSCBSAYBAR ( 16 , 27 , cBarras , "N","MB07",10,.F.,.F.,.F.,"C",5,2,.F.)
	Else
		MSCBPRINTER(cModPrint,"LPT1",,)
		MSCBCHKStatus(.F.)
		MSCBBEGIN(nQtd2,3)
		// Box da Etiqueta -------------------------------------------------------
		MSCBBOX(04,01,101,47,2)
		// Dados da Etiqueta -------------------------------------------------------
		MSCBSAY(07,03,cDesc                 ,"N","1","030,040")
		MSCBSAY(07,09,"Nr.O.P: "+ALLTRIM(cOP),"N","1","030,040")
		MSCBSAY(07,15,"Cod.: "+ALLTRIM(cCod),"N","1","030,040")
		MSCBSAY(54,15,"Nr.Lote: "+alltrim(nQtd1),"N","1","030,040")
		MSCBSAY(07,21,"Data: "+STRZERO(nQtd3,2)+"/"+substr(alltrim(Dtoc(dDataBase)),4,6),"N","1","030,040")
		MSCBSAY(41,21,"Turno: "+alltrim(cTurno),"N","1","030,040")
		MSCBSAY(71,21,"LM: "+cLm ,"N","1","030,040")
		MSCBSAY(15,41, cBarras ,"N","1","030,040")
		// codigos de barras da Etiqueta -------------------------------------------------------
		MSCBSAYBAR ( 66 , 07 , ALLTRIM(cCodEtq) , "N","MB07",6,.F.,.F.,.F.,"C",2,2,.F.)
		MSCBSAYBAR ( 16 , 27 , cBarras , "N","MB07",12,.F.,.F.,.F.,"C",5,2,.F.)

	Endif

	MSCBEND()
	MSCBCLOSEPRINTER()

Return