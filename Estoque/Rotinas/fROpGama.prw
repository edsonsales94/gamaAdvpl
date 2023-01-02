#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		frOpGama                                                       /@
@type			Relatório                                                     /@
@date			28/10/2020                                                    /@
@description	Impressão de relatório gráfico Ordem de Produção           /@
@author			Ricky Moraes
@use			Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function  fROpGama()
	Local aRegs		:= {}

	Local cPerg		:= PadR("ROPGAMA", Len(SX1->X1_GRUPO))
	Local aCabSX1	:= {"X1_GRUPO", "X1_ORDEM", "X1_PERGUNT", "X1_VARIAVL", "X1_TIPO", "X1_TAMANHO", "X1_DECIMAL", "X1_GSC", "X1_VAR01", "X1_DEF01", "X1_DEF02"}

//parametros para o processamento
	aAdd(aRegs, {cPerg, "01", "Da O.P?       ", "mv_ch1", "C", 06, 0, "G", "mv_par01", "", ""})
//aAdd(aRegs, {cPerg, "02", "Ate a O.P?      ", "mv_ch2", "C", 06, 0, "G", "mv_par02", "", ""})
//aAdd(aRegs,{cPerg,"06","Descricao Produto","mv_ch6","N",01,0,"G","mv_par05","Produto","Pedido","Compl.Prod."})

	U_BRASX1(aRegs,aCabSX1)

	if Pergunte(cPerg, .T.)
		U_IMPOPGAMA(.T.)
	endif
Return()


/*/
	———————————————————————————————————————————————————————————————————————————————
	@function		IMPOPGAMA                                                     /@
	@type				Relatório                                                     /@
	@date				29/10/20                                                    /@
	@description	Chamado pela user function fROpGama /@
	imprime a Ordem de Produção de acordo com parâmetros informados/@
	@author			Ricky Moraes  ricky.moraes@gamaitaly.com.br
	@use			Específico Brasitech                                          /@
	———————————————————————————————————————————————————————————————————————————————
/*/
User Function IMPOPGAMA(lOpGama)

	//Local lAdjustToLegacy := .F.
	//Local lDisableSetup  := .T.
	Local lLegacy  := .F.
	Local lSetup   := .T.
	Local nL	:=0
	Local cTipoQuebra
	Local nTotMP,nTotEM,nTotPI,nTotMOD,nTotPA,nTotHora


	Private cLogo		:= GetMV("ES_LOGO", .F., "\SYSTEM\BRASITECH.BMP")
	Private nPag 		:= 1
	Private nLin		:= 0
	Private oPC
	Private ItensSd4	:={}



// Cria os objetos de fontes que serao utilizadas na impressao do relatorio
	Private oFont07  := TFont():New("Courier",,07,,.F.)
	Private oFont08  := TFont():New("Courier",,08,,.F.)
	Private oFont10  := TFont():New("Courier",,10,,.F.)
	Private oFont12  := TFont():New("Courier",,12,,.F.)
	Private oFont14  := TFont():New("Courier",,14,,.F.)
	Private oFont16  := TFont():New("Courier",,16,,.F.)
	Private oFont18  := TFont():New("Courier",,18,,.F.)
	Private oFont20  := TFont():New("Courier",,20,,.F.)
	Private oFont22  := TFont():New("Courier",,22,,.F.)
	Private oFont24  := TFont():New("Courier",,24,,.F.)
	Private oFont28  := TFont():New("Courier",,28,,.F.)
	Private oFont30  := TFont():New("Courier",,30,,.F.)
	Private oFont34  := TFont():New("Courier",,34,,.F.)
	Private oFont44  := TFont():New("Courier",,44,,.F.)
	Private oFont80  := TFont():New("Courier",,80,,.F.)

	Private oFont07N := TFont():New("Courier",,07,,.T.)
	Private oFont08N := TFont():New("Courier",,08,,.T.)
	Private oFont10N := TFont():New("Courier",,10,,.T.)
	Private oFont12N := TFont():New("Courier",,12,,.T.)
	Private oFont14N := TFont():New("Courier",,14,,.T.)
	Private oFont16N := TFont():New("Courier",,16,,.T.)
	Private oFont18N := TFont():New("Courier",,18,,.T.)
	Private oFont20N := TFont():New("Courier",,20,,.T.)
	Private oFont22N := TFont():New("Courier",,22,,.T.)
	Private oFont24N := TFont():New("Courier",,24,,.T.)
	Private oFont28N := TFont():New("Courier",,28,,.T.)
	Private oFont34N := TFont():New("Courier",,34,,.T.)
	Private oFont44N := TFont():New("Courier",,44,,.T.)
	Private oFont80N := TFont():New("Courier",,80,,.T.)
	Private cTotMP,	cTotEM,	cTotPI,cTotMOD,cTotPA,cTotHora


	cOpIni 	:= mv_par01
	cOoFim 	:= mv_par02



//———————————————————————————————————————————————————————————————————————————————
// Seta as ordens de pesquisa das tabelas
//———————————————————————————————————————————————————————————————————————————————
	SC2->(dbSetOrder(1))
	SD4->(dbSetOrder(1))
	SB1->(dbSetOrder(1))

	dbSelectArea("SC2")

	oPC := FWMSPrinter():New(cOpIni+".rel",IMP_PDF,lLegacy, NIL, lSetup, NIL, NIL, NIL, NIL, .F.)// Ordem obrigátoria de configuração do relatório
	oPC:SetPortrait()
	oPC:SetMargin(1,1,1,1) // nEsquerda, nSuperior, nDireita, nInferior
	oPC:SetPaperSize(DMPAPER_A4)//:setPaperSize(9)
	oPC:cPathPDF := "c:\temp\" // Caso seja utilizada impressão em IMP_PDF


//———————————————————————————————————————————————————————————————————————————————
// Query para selecionar as ordens de Produção
//———————————————————————————————————————————————————————————————————————————————
	cQuery := "SELECT C2_NUM,C2_ITEM,C2_SEQUEN,C2_PRODUTO,C2_QUANT,C2_LOCAL,C2_XEND,C2_XMOLDE,C2_EMISSAO,C2_STATUS  "
	cQuery += "FROM " + RetSqlName("SC2") + " SC2 "
	cQuery += "WHERE D_E_L_E_T_=' ' "
	cQuery +=   "AND C2_FILIAL = '" + xFilial("SC2") + "' "

	cQuery +=       "AND C2_NUM = '" + cOpIni +  "' "


	if Select("TRB") > 0
		TRB->( dbCloseArea() )
	endif

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TRB", .F., .T.)
	dbSelectArea("TRB")
	dbGoTop()
//alert(TRB->C2_NUM)
//———————————————————————————————————————————————————————————————————————————————
// Alimentacao das variaveis de impressao
//———————————————————————————————————————————————————————————————————————————————
	Imp_Cabec()

	Imp_CabItem()

 	nTotMP:=0
	nTotEM:=0
	nTotPI:=0
	nTotMOD :=0
	nTotPA :=0
	nTotHora :=0


	ItensSd4:=fItenSd4(cOpIni)
	aSort(ItensSd4, , , {|x, y| x[8] < y[8]})
	cTipoQuebra:='  '
	for nL := 1 to len(ItensSd4)
		if cTipoQuebra!=ItensSd4[nL,8]
			Imp_QuebraTipo(ItensSd4[nL,8])
		endif

		Imp_Itens( StrZero(nL,2,0);
			,ItensSd4[nL,1];
			,ItensSd4[nL,2];
			,ItensSd4[nL,3];
			,ItensSd4[nL,4];
			,ItensSd4[nL,5];
			,ItensSd4[nL,6];
			,ItensSd4[nL,7];
			,ItensSd4[nL,8] )

		cTipoQuebra:=ItensSd4[nL,8]

		DO CASE
		CASE cTipoQuebra=='MP'
			nTotMP:=nTotMP+1
		CASE  cTipoQuebra=='EM'
			nTotEM:=nTotEM+1
		CASE  cTipoQuebra=='PI'
			nTotPI:=nTotPI+1
		CASE  cTipoQuebra=='MO'
			nTotMOD:=nTotMOD+1
			nTotHora:=nTotHora + ItensSd4[nL,9]
		CASE  cTipoQuebra=='PA'
			nTotPA:=nTotPA+1			
		OTHERWISE
			alert('Tipo não definido :' +cTipoQuebra)
		ENDCASE
	next



	cTotMP:=StrZero(nTotMP,2)
	cTotEM:=StrZero(nTotEM,2)
	cTotPI:=StrZero(nTotPI,2)
	cTotMOD:=StrZero(nTotMOD,2)
	cTotPA:=StrZero(nTotPA,2)
	cTotHora:=TRANSFORM( nTotHora/nTotMOD, '@E 999,999.999')

	Imp_Rodape(.F.)

	oPC:Setup()
	if oPC:nModalResult == PD_OK
		oPC:Preview()     // Visualiza antes de imprimir
	EndIf


return()


/*/
	———————————————————————————————————————————————————————————————————————————————
	@function		    IMP_CAB                                                   /@
	@type				Relatório                                                     /@
	@date				30/10/2020                                                    /@
	@description	  Chamado pela static function fROpGama,
	imprime o cabeçalho da pagina @author			Ricky Moraes (ricky.moraes@gamaitaly.com.br)
	@use				Específico Brasitech                                          /@
	———————————————————————————————————————————————————————————————————————————————
/*/

Static Function Imp_Cabec()
	Local nLargura	:= 80
	Local cOP :=TRB->C2_NUM+TRB->C2_ITEM+TRB->C2_SEQUEN

	Local dDataEmissao :=  STOD(TRB->C2_EMISSAO)
	Local cProduto := TRB->C2_PRODUTO
	Local cTipo := POSICIONE("SB1",1,xFilial("SB1")+cProduto,"B1_TIPO")
	Local cDesc := POSICIONE("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")
	Local cEnd := TRB->C2_XEND
	Local cQuant := Transform(TRB->C2_QUANT, "@E 999,999,999")
	Local cMolde :=  IIF(EMPTY(TRB->C2_XMOLDE),"XXXXXX",(TRB->C2_XMOLDE))
	Local cUsuInc

	dbSelectArea("SC2")
	aAreaSC2:=GetArea()
	dbSetOrder(1)
	If MSSeek(xFilial()+cOP)
		cUsuInc:=FWLeUserlg("C2_USERLGI",1)
	else
		cUsuInc:='---------------'
	EndIf
	RestArea(aAreaSC2)

	oPC:StartPage()
	oPC:Box(009,003,050,092)
	oPC:SayBitmap(012, 008, cLogo, nLargura, nLargura * 0.4)
	oPC:Box(009,092,050,500)
	oPC:Say(035, 094, "ORDEM DE PRODUÇÃO", oFont30)
	oPC:Box(009,338,050,590)

	oPC:Code128(015/*nRow*/ ,343/*nCol*/, cOP/*cCode*/,1/*nWidth*/,20/*nHeigth*/,.F./*lSay*/,,)
	oPC:Say(046, 343, "NUM.O.P.: ", oFont08)
	oPC:Say(046, 384, SUBSTRING(cOP,1,6), oFont16N)

	oPC:Box(009,498,050,590)
	oPC:Say(020, 500, "IMPRESSÃO: " +dtoc(dDataBase), oFont08)
	oPC:Say(031, 500, "HORA: " + TIME()   , oFont08)
	oPC:Say(042, 500, "PÁGINA: " + AllTrim(Str(nPag)) , oFont08)

	oPC:Box(050,003,100,590)
	oPC:Say(060, 012, "CÓDIGO : " , oFont08)
	oPC:Say(062, 052,cProduto, oFont16N)
	oPC:Say(072, 012, "PRODUTO: " + cDesc   , oFont08)

	oPC:Box(050,305,100,338)
	oPC:Say(060, 314, "TIPO ", oFont07)
	oPC:Say(075, 313, cTipo, oFont20N)

	oPC:Box(050,338,100,405)
	oPC:Say(060, 342, "QTD. A PRODUZIR ", oFont07)
	oPC:Say(075, 342, alltrim(cQuant), oFont20N)


	oPC:Say(060, 410, "DT. EMISSAO ", oFont07)
	oPC:Say(075, 410, DTOC(dDataEmissao), oFont14)

	oPC:Box(050,468,100,535)

	oPC:Say(060, 471, "MOLDE (INJETADO) " , oFont07)
	oPC:Say(075, 471, alltrim(cMolde) , oFont18N)


	oPC:Say(060, 538, "STATUS O.P." , oFont07)
	//oPC:Say(075, 538, "P" , oFont18N)
	oPC:Say(075, 538, "PREVISTA" , oFont12N)

	oPC:Box(080,003,110,100)
	oPC:Box(080,100,110,590)

	oPC:Say(089, 012, "ENDEREÇO PRODUÇÃO " , oFont07)
	oPC:Say(103, 012, alltrim(cEnd) , oFont20)

	oPC:Say(089, 110, "OBSERVAÇÃO " , oFont07)
	oPC:Say(103, 110, alltrim(cMolde) , oFont12)

	oPC:Box(080,305,110,405)
	oPC:Say(089, 310, "PCP - EMISSOR ", oFont07)
	oPC:Say(103, 310, alltrim(cUsuInc), oFont12)



Return()


/*/
	———————————————————————————————————————————————————————————————————————————————
	@function		    IMP_CABITEM                                                   /@
	@type				Relatório                                                     /@
	@date				30/10/2020                                                    /@
	@description	  Chamado pela static function fROpGama, imprime o cabeçalho Item
do pedido de compras.                                         /@
@author			Ricky Moraes (ricky.moraes@gamaitaly.com.br)
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function Imp_CabItem()
	nLin:= 111

	oBrush1 := TBrush():New( , CLR_HGRAY)
	oPC:Box(nLin-1,003,nLin+21,590)
	oPC:FillRect( {nLin, 004, nLin+20, 589}, oBrush1 )
	oPC:Say(nLin + 15, 233, 'LISTA DE MATERIAL - B.O.M.', oFont16N)

	nLin+=10

	nLin+=11
	//oBrush1 := TBrush():New( , CLR_HGRAY)
	oPC:Box(nLin-1,003,nLin+15,590)
	oPC:Box(nLin-1,024,nLin+15,123)
	oPC:Box(nLin-1,398,nLin+15,422)
	oPC:Box(nLin-1,486,nLin+15,510)
	oPC:Box(nLin-1,536,nLin+15,561)

	//oPC:FillRect( {nLin, 004, nLin+20, 589}, oBrush1 )

	nLin+=12
	oPC:Say(nLin, 006, 'N#', oFont14N)
	oPC:Say(nLin, 026, 'COD.PRODUTO', oFont14N)
	oPC:Say(nLin, 125, 'DESCRICAO', oFont14N)
	oPC:Say(nLin, 400, 'UND', oFont14N)
	oPC:Say(nLin, 427, 'QUANTID.', oFont14N)
	oPC:Say(nLin, 488, 'KNB', oFont14N)
	oPC:Say(nLin, 513, 'FTM', oFont14N)
	oPC:Say(nLin, 538, 'LOC', oFont14N)
	oPC:Say(nLin, 563, 'TIPO', oFont14N)


Return()

Static Function Imp_QuebraTipo(cTipoQebra1)

	nLin+=2
	oPC:Box(nLin,003,nLin+15,590)
	nLin+=12
	oPC:Say(nLin, 006, cTipoQebra1, oFont12N)

return()

static Function Imp_Itens(cSeq1,cCod1,cDesc1,cUnid1,cQuant1,cKnb1,cFtm1,cLocal1,cTipo1)
	nLin+=2
	oPC:Box(nLin,003,nLin+15,590)
	oPC:Box(nLin,024,nLin+15,123)
	oPC:Box(nLin,398,nLin+15,422)
	oPC:Box(nLin,486,nLin+15,510)
	oPC:Box(nLin,536,nLin+15,561)

	nLin+=12
	oPC:Say(nLin, 006, cSeq1, oFont12)
	oPC:Say(nLin, 026, cCod1, oFont12)
	oPC:Say(nLin, 125, cDesc1, oFont12)
	oPC:Say(nLin, 402, cUnid1, oFont12)
	oPC:Say(nLin, 423, cQuant1, oFont12)
	oPC:Say(nLin, 489, cKnb1, oFont12)
	oPC:Say(nLin, 514, cFtm1, oFont12)
	oPC:Say(nLin, 540, cLocal1, oFont12)
	oPC:Say(nLin, 565, cTipo1, oFont12)


Return()

Static Function fItenSd4(cOp1)
	Local aSd4
	LOCAL cTipo,cDescProd,cUnid,cFtm,cKnb,cQtd
	cTipo 	:=space(2)
	cDesricao :=space(46)
	cUnid 	:= space(2)
	cFtm 	:=space(2)
	cKnb 	:=space(2)
	cQtd :='0,00'

	aSd4:={}
	SD4->(dbSetOrder(2))
	IF SD4->(MSSeek(xFilial("SD4") +cOp1+'01001' ))
		Do While !SD4->(Eof()) .AND. alltrim(SD4->D4_OP) == cOp1+'01001' .AND. xFilial("SD4")==SD4->D4_FILIAL
			SB1->(dbSetOrder(1))


			IF SB1->(MSSeek(xFilial("SB1") +SD4->D4_COD,.T. ))
				cTipo 	:=SB1->B1_TIPO
				cDescProd :=SUBSTRING(iif(empty(SB1->B1_XDESCNF),SB1->B1_DESC,SB1->B1_XDESCNF),1,46)
				cUnid 	:= SB1->B1_UM
				cFtm 	:=IIf(SB1->B1_FANTASM=='S','SIM',' ')
				cKnb 	:=IIF(SB1->B1_XKANBAN=='S','SIM',' ')
				cQtd := TRANSFORM(SD4->D4_QTDEORI, '@E 999,999.999')  //TRANSFORM(SD4->D4_QUANT, '@E 999,999.999')

				aadd(aSd4,{SD4->D4_COD,cDescProd,cUnid,cQtd,cKnb,cFtm, SD4->D4_LOCAL,cTipo,SD4->D4_QTDEORI})
			else
				cTipo 	:=space(2)
				cDesricao :=space(50)
				cUnid 	:= space(2)
				cFtm 	:=space(2)
				cKnb 	:=space(2)
				cQtd :='0,00'

			EndIf

			SD4->(dbSkip())
		Enddo

	EndIf

return(aSd4)


/*/
	———————————————————————————————————————————————————————————————————————————————
	@function		IMP_RODAPE                                                    /@
	@type				Relatório                                                     /@
	@date				25/10/2015                                                    /@
	@description	Chamado pela static function IMPCOMR01, imprime o cabeçalho
do pedido de compras.                                         /@
@author			Ricky Moraes (ricky.moraes@gamaitaly.com.br)
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function Imp_Rodape(lContinua)
	Local nX, nLiObs, nCont, nCol
	nLin += 20
	if lContinua
		oPC:Say(nLin+10,004, "...CONTINUA...",oFont8)

	endif
	oBrush1 := TBrush():New( , CLR_HGRAY)
	oPC:Box(nLin-1,003,nLin+29,590)
	oPC:FillRect( {nLin, 004, nLin+26, 589}, oBrush1 )
	oPC:Say(nLin + 8, 240, 'RESUMOS / TOTAIS', oFont12N)

	nLin+=11

	oPC:Box(nLin-1,003,nLin+25,590)
	oPC:Box(nLin-1,003,nLin+30,590)
	//oPC:Box(nLin-1,003,nLin+20,590)
	//oPC:Box(nLin-1,024,nLin+15,123)
	//oPC:Box(nLin-1,398,nLin+15,422)
	//oPC:Box(nLin-1,486,nLin+15,510)
	//oPC:Box(nLin-1,536,nLin+15,561)

	//oPC:FillRect( {nLin, 004, nLin+20, 589}, oBrush1 )

	nLin+=12
	oPC:Say(nLin+5, 004, 'TOTAIS ', oFont14N)
	oPC:Say(nLin-2, 060, 'MAT.PRIMA', oFont12N)
	oPC:Say(nLin-2, 140, 'EMBALAGEM', oFont12N)
	oPC:Say(nLin-2, 220, 'P.INTERM.', oFont12N)
	oPC:Say(nLin-2, 300, 'MODs.', oFont12N)
	oPC:Say(nLin-2, 350, 'PA/RETR', oFont12N)
	oPC:Say(nLin-2, 420, 'HORAS', oFont12N)

	nLin+=15

	oPC:Say(nLin-2, 070, cTotMP, oFont14)
	oPC:Say(nLin-2, 153, cTotEM, oFont14)
	oPC:Say(nLin-2, 233, cTotPI, oFont14)
	oPC:Say(nLin-2, 302, cTotMOD, oFont14)
	oPC:Say(nLin-2, 356, cTotPA, oFont14)
	oPC:Say(nLin-2, 380, cTotHora, oFont14)



	oPC:EndPage()
Return()

