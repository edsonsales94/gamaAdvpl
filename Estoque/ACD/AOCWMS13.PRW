#INCLUDE 'RWMAKE.CH'
#INCLUDE 'APVT100.CH'
//transferencia entre armazem 
User Function AOCWMS13()
	Local cBarras      := Space(28)
	Local _cFixa       := Space(01)
	Private _cDoc     := Space(09)
	Private _cEndOri  := Space(15)
	Private _cEndDest := Space(15)
	Private _cLote	  := Space(10)
	Private _cProduto := Space(15)
	Private _cNumpa    := Space(9)
	Private cInd_Cod  :=" "
	Private _cLocDe	  :=  Space(2)
	Private _cLocAt	  :=  Space(2)
	Private _nQuant	  := 0
	Private aEnd      := {}
	Private cCliInd   :=IIF(SM0->M0_CODIGO="21",SubStr(GetMv("MV_CLIEENV"),1,6),"")
	Private cLojaInd  :=IIF(SM0->M0_CODIGO="21",SubStr(GetMv("MV_CLIEENV"),7,2),"")

	VTClearBuffer()
//DLVTCabec("Tranf. de Endereco: " ,.F.,.F.,.T.)
//@ 01, 00 VTSay PadR('Arm.De : ' , VTMaxCol())
//@ 01, 13 VTGet _cLocDe  Pict '@!' 	  VALID !Empty(_cLocDe) 
//@ 02, 00 VTSay PadR('Arm.Ate : ' , VTMaxCol())
//@ 02, 13 VTGet _cLocAt  Pict '@!' 	  VALID !Empty(_cLocAt)
//VTREAD

	DLVTCabec("Transf. de Endereco: " ,.F.,.F.,.T.)
	@ 01, 00 VTSay PadR('Fixa Endereço ' , VTMaxCol())
	@ 02, 00 VTSay PadR('1-Fixa Origem ' , VTMaxCol())
	@ 03, 00 VTSay PadR('2-Fixa Destino' , VTMaxCol())
	@ 04, 00 VTSay PadR('3-Nao Fixa ' , VTMaxCol())
	@ 05, 00 VTSay PadR('4-Origem/Destino' , VTMaxCol())
	@ 06, 00 VTSay PadR('Escolha:' , VTMaxCol())
	@ 06, 13 VTGet _cFixa  Pict '9' 	  VALID !Empty(_cFixa)
	VTREAD


	// DBSelectArea('SX5')
	// DBSetOrder(1)
	// IF !DBSeek(xFilial('SX5')+ "74" + _cLocDe )
		// DLVTAviso('SIGAWMS', 'O Arm.Origem '+Alltrim(_cLocDe)+' nao existe.')
		// Return (.F.)
	// Endif
// 
	// IF !DBSeek(xFilial('SX5')+ "74" + _cLocAt )
		// DLVTAviso('SIGAWMS', 'O Arm.Destino '+Alltrim(_cLocAt)+' nao existe.')
		// Return (.F.)
	// Endif
	// _cDoc :=u_SD3_DOC()

	While .T.
	/// lIMPAR VARIAREIS
		_cEndOri  := Space(15)
		_cEndDest := Space(15)
		_cProduto := Space(15)
		_cLocDe	  :=  Space(2)
		_cLocAt	  :=  Space(2)
		_cNumPa	  :=  Space(10)
		_nQuant	  := 0

		// DLVTCabec("Tranf. de Endereco: " + _cLocDe ,.F.,.F.,.T.)
		DLVTCabec("Transf. de Endereco/Armazen "  ,.F.,.F.,.T.)
		//@ 01, 00 VTSay PadR('Doc. :' , VTMaxCol())
		@ 01, 00 VTSay PadR('Prod.....:' , VTMaxCol())
	   	@ 02, 00 VTSay PadR('Armz Ori.:' , VTMaxCol())///
		@ 03, 00 VTSay PadR('End Ori..:' , VTMaxCol())
		@ 04, 00 VTSay PadR('Qtde.....:' , VTMaxCol())
		@ 05, 00 VTSay PadR('Armz Dest:' , VTMaxCol())///
		@ 06, 00 VTSay PadR('End Dest.:' , VTMaxCol())
		@ 07, 00 VTSay PadR('Num Pa.:' , VTMaxCol())

		//@ 01, 06 VTGet _cDoc     Pict '@!' 	when .f.
		@ 01, 10 VTGet _cProduto Pict '@!' 				VALID !Empty(_cProduto) .AND. fVldBarras(_cProduto)
		@ 02, 10 VTGet _cLocAt    Pict '@!'  			VALID !Empty(_cLocAt) .and. sfValarmz(_cLocAt)//////
		@ 03, 10 VTGet _cEndOri  Pict '@!' 	        	VALID !Empty(_cEndOri) .and. (ValEnd (_cLocAt,_cEndOri))
		@ 04, 10 VTGet _nQuant   Pict '@R 999999.99' 	VALID !Empty(_nQuant) .and. (SaldSBF(_cLocAt,_cEndOri ))
		@ 05, 10 VTGet _cLocDe    Pict '@!'				VALID !Empty(_cLocDe) .and. sfValarmz(_cLocDe) ///////////
		@ 06, 10 VTGet _cEndDest Pict '@!'        		VALID !Empty(_cEndDest) .and. (ValEnd (_cLocDe,_cEndDest))
        @ 07, 10 VTGet _cNumPa   Pict '@!'        		VALID ValPA (_cLocAt,_cEndOri,_cProduto,_cNumPa)
     
		VTREAD

		If (VTLastKey()==27)
			If (lRet:=DLVTAviso('', 'Deseja encerrar a transferencia ?', {'Sim', 'Nao'})==1)
				Exit
			EndIf
		EndIf

		IF !Empty(_cProduto) .AND. _nQuant >0
			If EndProcesso()  //fc que endereca o saldo do processo
				_cDoc := ""
			Endif
			_cEndDest := Iif(_cFixa$'2/4',_cEndDest,Space(15))
			_cLote	  := Space(10)
			_cProduto := Space(15)
			_cEndOri  := Iif(_cFixa$'1/4',_cEndOri,Space(15))
			_nQuant	  := 0
			cBarras	  := Space(28)

		Endif


	EndDo
Return(.T.)

/*/
/*/
Static Function sfValarmz(_cArmazen)
	Local lRet:=.T.
	DBSelectArea('SBE')
	DBSetOrder(1)
	IF !DBSeek(xFilial('SBE')+_cArmazen)
		DLVTAviso('SIGAWMS', 'Esse Armazen '+Alltrim(_cArmazen)+' nao existe.!')
		Return (.F.)
	ENDIF
Return(lRet)


Static Function SaldSBF(_Locde,cEndO)  //saldo no endereço
	Local nDoc:=0
	cAliasSBF:= GetNextAlias()
	BeginSql Alias cAliasSBF
		SELECT isnull(SUM(BF_QUANT),0) AS BF_QUANT FROM %Table:SBF% WHERE BF_FILIAL='01' 
		AND BF_PRODUTO=%exp:_cProduto%  AND BF_LOCAL=%exp:_Locde% AND BF_LOCALIZ=%exp:cEndO% AND BF_LOTECTL=%exp:ALLTRIM(_cLote)% 
		AND D_E_L_E_T_='' 
	EndSql
	dbSelectArea(cAliasSBF)
	dbgotop()
	nDoc+=(cAliasSBF)->BF_QUANT
	dbSelectArea(cAliasSBF)
	dbclosearea()

	IF _nQuant>nDoc
		DLVTAviso('SIGAWMS',"Saldo no Endereço menor que o solicitado! Saldo: "+alltrim(str(nDoc,12,5)) )
		_nQuant:=0
		Return .F.
	ENDIF

Return(.T.)


Static Function ValEnd(_cLocal,_cEnd)
	Local lRet:=.T.
	DBSelectArea('SBE')
	DBSetOrder(1)
	IF !DBSeek(xFilial('SBE')+_cLocal+_cEnd)
		DLVTAviso('SIGAWMS', 'O endereco '+Alltrim(_cEnd)+' nao existe.!')
		Return (.F.)
	ENDIF
Return(lRet)


Static Function ValPA(_cLocal,_cEnd,_cProd,_cNPa)
	Local lRet:=.T.
	Local ccNumPa := space(10)
	     
		SBF->(DBSetOrder(1))
	    if SBF->(DBSeek(xFilial('SBF')+_cLocal+_cEnd+_cProd))
		   ccNumPa := SBF->BF_XNUMPA
	    endif

		if Empty(_cNPa)
		   if _cNPa <> ccNumPa 	 
		      DLVTAviso('SIGAWMS', 'O Numero da PA não foi informada.!')
		      lRet:=.F.
		    endif
		else
	  	    if _cNPa <> ccNumPa 	 
		      DLVTAviso('SIGAWMS', 'O Numero da PA correta é '+Alltrim(ccNumPa)+'.!')
			  _cNumPa := SBF->BF_XNUMPA
		    endif
		endif
Return(lRet)


	******************************************************************************************************************************************************
Static Function fVldBarras(cBarras)
	******************************************************************************************************************************************************
	Local lResp:=.f.
	Local cProd:=SubStr(cBarras,1,15)
	Local nquant:=SubStr(cBarras,16,15)
	Local cObs:=""


	if  Posicione("SB1",1,xFilial("SB1")+cProd,"B1_COD")==cProd
		lResp:=.t.
		_cProduto := cProd
	Else
		cObs+=" Codigo Invalido!"
		DLVTAviso('SIGAWMS', cObs)
	Endif

Return(lResp)


	*********************************************************************************************************************************
Static Function EndProcesso()//processo de validação de transferencia
	*********************************************************************************************************************************
	Local aCbEnd   := {}  //cabec da chamada da rotina aut
	Local aItEnd   := {}  //itens da chamada da rotina aut
	Local nItem    := 1

	VtClearBuffer()
	If ! VTYesNo("Confirma Transf.:Ori." +_cEndOri+" Desct."+_cEndDest+"  Qtd.:"+Transform(_nQuant,"@E 9,999,999.99")+" ?"  , "Produto: " + _cProduto  , .T.)
		If IsTelnet() .and. VtModelo() == "RF"
			VTKeyBoard(chr(20))
		EndIf
		Return .F.
	EndIf

	VTMSG("Aguarde...")
	vBaixaReg  := 0
	vBaixaAcum := 0

	Begin Transaction
		Tranf_AocWms(_cProduto,_cLocAt,_cEndOri,_cLocDe,_cEndDest,_cLote,_cLote,_nQuant)
	End Transaction
	VTKeyBoard(chr(20))

Return (.T.)

	***************************************************************************************************************************************
Static Function Tranf_AocWms(cProduto,cArmOri,cEndOri,cArmDest,cEndDest,cLoteOri,cLoteDest,nVlr)	//Função de transferencia de endereços
	***************************************************************************************************************************************
	Local cCodOri	:= 	cProduto												//	Produto Origem	(Codigo)
	Local cDescrOri	:= 	Posicione("SB1",1,xFilial("SB1")+SBF->BF_PRODUTO,"B1_DESC") //	Produto Origem	(Descricao)
	Local cUmOri	:=	Posicione("SB1",1,xFilial("SB1")+SBF->BF_PRODUTO,"B1_UM")	//	Produto Origem	(Unid Medida)
	Local cAlmOri	:= 	cArmOri												//	Produto Origem	(Almoxarifado)
	Local cEndOri	:= 	cEndOri												//	Produto Origem	(Endereco)

	Local cCodDest	:=	cProduto												//	Produto Destino	(Codigo)
	Local cDescrDest:=	Posicione("SB1",1,xFilial("SB1")+SBF->BF_PRODUTO,"B1_DESC")	//	Produto Destino	(Descricao)
	Local cUmDest	:=	Posicione("SB1",1,xFilial("SB1")+SBF->BF_PRODUTO,"B1_UM")	//	Produto Destino	(Unid Medida)
	Local cAlmDest	:=	cArmDest												//	Produto Destino	(Almoxarifado)
	Local cEndDest	:= 	cEndDest												//	Produto Destino	(Endereco)

	Local cNumSerie	:= 	""							//	Produto	(Numero de Serie)
	Local cLote		:= 	cLoteOri							//	Produto	(Lote)
	Local cSLote	:= 	Space(06)								//	Produto	(Sub Lote)
	Local cValLote	:= 	ctod('')								//	Produto	(Validade do Lote)
	Local nPotenc	:= 	0										//  Potencia
	Local nQtde		:= 	nVlr									//	Produto	(Quantidade do movimento)
	Local nQtde2	:=	nVlr                                    //	Produto	(Quantidade do movimento na Segunda Unidade Medida)
	Local cEstorn	:= 	"N"								        //	Produto	(Se igual a S = Indica estorno)
	Local cSeq      := 	ProxNum()								//	Produto	(Sequencia utilizada pelo sistema)
	Local cLoteDest	:=	cLoteDest							//	Produto	(Lote Destino)
	Local cValLtDest:=	ctod('')								//  Produto (Validade Destino)

	// Local aSepa  := {{_cDoc,dDataBase}}	//Criacao da 1a. linha do array com o documento e data
	Local cTexto := ""
	Local cItemGrd:=""

	_cDoc :=u_SD3_DOC()
	aSepa  := {{_cDoc,dDataBase}}
	lmsErroAuto	:= .F.

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
	"Transf. entre Enderecos"})		/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Chamada da Rotina automatica para gravacao de dados	³
	|de transferencia modelo II - [tabela SD3] 				|
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		*/

	If Len(aSepa) > 1
		x_Area  := Alias()
		x_Rec   := Recno()
		x_Ind   := Indexord()

		MsExecAuto({|x,y| mata261(x,y)},aSepa,3)

		DbSelectArea(x_Area)
		DbSetOrder(x_Ind)
		DbGoto(x_Rec)
	EndIf
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Verifica se houve algum tipo de erro retornado pela	³
	|rotina automatica.										|
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/

	If  lmsErroAuto
		DLVTAviso('SIGAWMS', '!!!! ERRO DE Transferência !!!!')
		//_Erro := DLVTAviso('Pergunta', 'Transferência não gerada. Deseja visualizar o log ?', {'Sim', 'Nao'})
		//Aviso("Pergunta","Transferência não gerada. Deseja visualizar o log?",{"Sim","Não"},1,"Atenção")
		//If _Erro == 1
		//	DLVTMostraErro()
		//DLVTAviso('SIGAWMS', 'Endereço não encontrado')
		Return
		//Endif
	Endif

Return
