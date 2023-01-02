#include "rwmake.ch"
#include "protheus.ch"
/*
???????????????????????????????????????????????????????????????????????????????
@function		CargaPvSenf                                                     /@
@date			 03/04/2020                                                   /@
@type				User Function
@description	Inclusão de PV para a geração de notas fiscais apartir da SENF /@
@author			Ricky Moraes (ricky.moraes@gamaitaly.com.br)
@use				Específico Brasitech                                          /@
???????????????????????????????????????????????????????????????????????????????
*/

*****************************************************************************************************************************************************
User Function fCargaSenf(cDoc)
	******************************************************************************************************************************************************
	Local aArea := ZT3->(GetArea())
	Local oButton1
	Local oButton2
	Local oSay1,oSay2,oSay3,oSay4,oSay5,oSay6,oSay7,oSay8,oSay9
	Local oGet1, oGet2,oGet3,oGet4,oGet5,oGet6,oGet7,oGet8,oGet9
	Local cNumSenf
	Local cSetor
	Local cDestino
	Local cObs
	Local cSol

	Local  nPesoBru
	Local  nPesoLiq
	Local  nVolume
	Local  cEspecie,cTES,cTabela,cCond,cTransp

	Static oDlg

	ZT3->(DbSetOrder(1))
	ZT3->(MsSeek(FwXFilial("ZT3") + cDoc ))


	cNumSenf :=ZT3->ZT3_NUM
	cSetor := ZT3->ZT3_SETOR
	cDestino :=ZT3->ZT3_NOME
	cObs :=ZT3->ZT3_OBS
	cSol:=  ZT3->ZT3_SOL

	nPesoBru :=ZT3->ZT3_PBRUTO
	nPesoLiq :=ZT3->ZT3_PLIQUI
	nVolume:=ZT3->ZT3_VOLUME
	cEspecie:=ZT3->ZT3_ESPECI

	cTES	:=ZT3->ZT3_TES
	cTabela	:=ZT3->ZT3_CODTAB
	cCond	:=ZT3->ZT3_CONDPA
	cTransp :=ZT3->ZT3_TRANSP


	XX:=8
	XY:=17
	A:=22
	B:=22

	DEFINE MSDIALOG oDlg TITLE "Expedição/Fiscal" FROM 000, 000  TO 500, 400 COLORS 0, 16777215 PIXEL

	@ XX,008 SAY oSay1 PROMPT "Num.Senf :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ XY,008 MSGET oGet1 VAR cNumSenf SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL When .F.

	@ XX,105 SAY oSay2 PROMPT "Setor :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ XY,105 MSGET oGet2 VAR cSetor When .F. SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL

	@ XX+=A,008 SAY oSay3 PROMPT "Solicitante :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ XY+=B,008 MSGET oGet3 VAR cSol When .F. SIZE 150, 010 OF oDlg COLORS 0, 16777215 PIXEL

	@ XX+=A,008 SAY oSay4 PROMPT "Destinatário :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ XY+=B,008 MSGET oGet4 VAR cDestino When .F. SIZE 150, 010 OF oDlg COLORS 0, 16777215 PIXEL

	@ XX+=A,008 SAY oSay5 PROMPT "Observações :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ XY+=B,008 MSGET oGet5 VAR cObs When .F. PICTURE "@!A" SIZE 150, 010 OF oDlg COLORS 0, 16777215 PIXEL

	@ XX+=A,008 SAY oSay6 PROMPT "Peso Bruto :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ XY+=B,008 MSGET oGet6 VAR nPesoBru PICTURE "@E 999,999.99" SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL

	@ XX,105 SAY oSay7 PROMPT "Peso Líquido :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ XY,105 MSGET oGet7 VAR nPesoLiq PICTURE "@E 999,999.99" SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL

	@ XX+=A,008 SAY oSay8 PROMPT "Volume :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ XY+=B,008 MSGET oGet8 VAR nVolume PICTURE "@E 999,999.99" SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL

	@ XX,105 SAY oSay9 PROMPT "Espécie :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ XY,105 MSGET oGet9 VAR cEspecie PICTURE "@!A" SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL

	@ XX+=A,008 SAY oSay9 PROMPT "TES :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ XY+=B,008 MSGET oGet9 VAR cTES PICTURE "@!A" SIZE 060, 010 OF oDlg F3 "SF4" COLORS 0, 16777215 PIXEL

	@ XX,105 SAY oSay9 PROMPT "Tabela de Preco :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ XY,105 MSGET oGet9 VAR cTabela PICTURE "@!A" SIZE 060, 010 OF oDlg   COLORS 0, 16777215 PIXEL   F3 "DA0"

	@ XX+=A,008 SAY oSay9 PROMPT "Cond.Pagamento :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ XY+=B,008 MSGET oGet9 VAR cCond PICTURE "@!A" SIZE 060, 010 OF oDlg F3 "SE4"  COLORS 0, 16777215 PIXEL

	@ XX,105 SAY oSay9 PROMPT "Cod.Transp. :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ XY,105 MSGET oGet9 VAR cTransp PICTURE "@!A" SIZE 060, 010 OF oDlg F3 "SA4"  COLORS 0, 16777215 PIXEL

	@ XY+=B+5, 069 BUTTON oButton1 PROMPT "&Gerar PV" ACTION ( iif(AltCarga(cNumSenf,nPesoBru,nPesoLiq,nVolume,cEspecie,cTES,cTabela,cCond,cTransp),oDlg:End(),.F. )) SIZE 049, 017 OF oDlg PIXEL
	@ XY, 123 BUTTON oButton2 PROMPT "&Sair" ACTION ( oDlg:End() )SIZE 049, 017 OF oDlg PIXEL

	//SetKey(VK_F5, {|| U_Etiqueta2Via() })

	ACTIVATE MSDIALOG oDlg CENTERED

	//SetKey(VK_F5,{||})
	RestArea(aArea)
RETURN


	******************************************************************************************************************************************************
Static Function AltCarga(cNumSenf,nPesoBru,nPesoLiq,nVolume,cEspecie,cTES,cTabela,cCond,cTransp)
	******************************************************************************************************************************************************
	Local aArea := ZT3->(GetArea())
	Local cItens:=""
	Local _cNumPed:=" "
	ZT3->(DbSetOrder(1))
	ZT3->(MsSeek(FwXFilial("ZT3") + cNumSenf ))

	IF ZT3->ZT3_STATUS $ "2-3"
		RecLock("ZT3",.F.)
		ZT3->ZT3_PBRUTO	:= nPesoBru
		ZT3->ZT3_PLIQUI := nPesoLiq
		ZT3->ZT3_VOLUME	:= nVolume
		ZT3->ZT3_ESPECI	:= cEspecie
		ZT3->ZT3_TES	:= cTES
		ZT3->ZT3_CODTAB	:= cTabela
		ZT3->ZT3_CONDPA := cCond
		ZT3->ZT3_TRANSP := cTransp
		//ZT3->ZT3_STATUS:='4'
		MsUnLock()

		//verificar se todos os itens na tabela de preco para PV.
		cItens:=(fGrvPrcItens(ZT3->ZT3_NUM,ZT3->ZT3_CODTAB))
		IF EMPTY(cItens) .OR. (ZT3->ZT3_MOVEST=="N")
			_cNumPed:=fImpPV(ZT3->ZT3_NUM)
			IF !EMPTY(_cNumPed)
				RecLock("ZT3",.F.)
				ZT3->ZT3_STATUS:='4'
				ZT3->ZT3_PEDIDO:=_cNumPed
				MsUnLock()
				If MsgYesNo("Deseja Enviar o E-mail ?")
					lEmail:=U_fEmailSenf(ZT3->ZT3_NUM,"*Prep. Doc. Fiscal*")

					IF lEmail
						MSGINFO( 'E-mail enviado com Sucesso.', "SENF - Eletrônica" )

					ELSE
						ALERT('Erro ao enviar o E-mail')
					ENDIF
				ENDIF
			ELSE
				Alert( "Erro ao Gerar PV favor acionar TI.")
			END
		ELSE
			Alert("Não será possível gerar o Pedido, Itens não estão ativos na tabela " +cTabela +". " +cItens)
		ENDIF

	Else
		ALERT('Não possível gera o PV, Verifique o Status do Registro !')
	EndIf


	RestArea(aArea)


RETURN(.T.)


	*****************************************************************************************************************************************************
STATIC Function fGrvPrcItens(cNum,cTabela) // RECEBE O NÚMERO REGISTRO
	*****************************************************************************************************************************************************
	Local cItens :=""               // Retornaos Itens que estao sem preco na tabela
	Local aArea := ZT4->(GetArea()) // ARMAZENA A ÁREA PARA RESTAURAR APÓS OPERAÇÕES
	Local nPreco:=0
	Local cTipo


	DA1->(DbSetOrder(1))
	ZT4->(DbGoTop())                          // MOVE O CURSOR PARA O TOPO DA TABELA
	ZT4->(DbSetOrder(1))                      // ALTERA PARA O ÍNDICE 1
	ZT4->(MsSeek(FwXFilial("ZT4") + cNum )) // USA O NÚMERO  PARA PESQUISAR
	DA1->(MsSeek(FwXFilial("DA1") + cTabela ))


	While ZT4->ZT4_NUMSF == cNum .AND. ZT4->ZT4_BLOCK!="S"

		cTipo:= POSICIONE("SB1",1,XFILIAL("SB1")+ZT4->ZT4_COD,'B1_TIPO')

		IF cTipo $ "PA-PI-MP-EM"
			IF ZT4->ZT4_VALOR=0 .or. ZT3->ZT3_TES=="541"
				IF ZT3->ZT3_TES=="541"

					nPreco:=A410Arred(POSICIONE("SB2",1,XFILIAL("SB2")+ZT4->ZT4_COD+ sfLocalPad(ZT4->ZT4_COD),"B2_CM1"),"C6_PRCVEN" )
					RecLock("ZT4",.F.)
					ZT4->ZT4_PRCVEN	:= 	nPreco
					ZT4->ZT4_PRCUNI := 	nPreco
					ZT4->ZT4_VALOR := IIF(ZT4->ZT4_QTDATE>0,ZT4->ZT4_QTDATE,ZT4->ZT4_QTDATE) * nPreco //round(ZT4->ZT4_QTDATE * nPreco,2)
					MsUnLock()


				ELSEIF POSICIONE("DA1",1,xFilial("DA1")+cTabela+ZT4->ZT4_COD,"DA1_CODPRO") = ZT4->ZT4_COD
					RecLock("ZT4",.F.)
					ZT4->ZT4_PRCVEN	:= 	DA1->DA1_PRCVEN
					ZT4->ZT4_PRCUNI := 	DA1->DA1_PRCVEN
					ZT4->ZT4_VALOR	:=	IIF(ZT4->ZT4_QTDATE>0,ZT4->ZT4_QTDATE,ZT4->ZT4_QTDSOL) * DA1->DA1_PRCVEN
					MsUnLock()

				ELSE
					cItens+=ZT4->ZT4_COD + ' '

				ENDIF
			ENDIF
			nPreco:=0
		ENDIF
		ZT4->(DbSkip())

	End

	// RESTAURA A ÁREA ORIGINAL (EVITA ERROS DE POSICIONAMENTO)
	RestArea(aArea)
Return (cItens)




	*****************************************************************************************************************************************************
STATIC Function fImpPV(cDoc)
	******************************************************************************************************************************************************


	Local _aAreaSA1	:= SA1->( GetArea() )
	Local _aAreaSA2	:= SA2->( GetArea() )
	Local _aAreaSB1	:= SB1->( GetArea() )
	Local _aAreaSE4	:= SE4->( GetArea() )
	Local _aAreaZT3	:= ZT3->( GetArea() )
	Local _aAreaZT4	:= ZT4->( GetArea() )
	Local _aLinha,  _aSC5, _aSC6, _cItem,_cCGC
	Local _cVend1,_cTransp
	Local _nPreco :=0
	Local _nValor :=0
	Local _nQtdVen:=0
	Local _cNumPed:=" "
	Private lMsErroAuto	:= .F.
	Private lMSHelpAuto := .T. //.F. // para nao mostrar os erro na tela


//_cCond:='002'
//_cTabela:='007'
	_cVend1:='1378'
	_cTransp:='111111'
	_cCGC:=" "

//???????????????????????????????????????????????????????????????????????????????
// Ordenando as tabelas
//???????????????????????????????????????????????????????????????????????????????
	SA1->( dbSetOrder(1) )
	SA2->( dbSetOrder(1) )
	SB1->( dbSetOrder(1) )
	SC5->( dbSetOrder(1) )
	SC6->( dbSetOrder(1) )
	SE4->( dbSetOrder(1) )
	DA0->( dbSetOrder(1) )
/*SENF*/
	ZT3->( dbSetOrder(1) )
	ZT4->( dbSetOrder(1) )

//???????????????????????????????????????????????????????????????????????????????
// Posicionando os registros
//???????????????????????????????????????????????????????????????????????????????
//DA0->(DBSEEK( xFilial("DA0")+_cTabela ))
	ZT3->(DBSEEK( xFilial("ZT3")+cDoc))


	ZT4->(DbGoTop())                          // MOVE O CURSOR PARA O TOPO DA TABELA
	ZT4->(MsSeek(FwXFilial("ZT4") + ZT3->ZT3_NUM ))  // USA O NÚMERO  PARA PESQUISAR

	IF ZT3->ZT3_TIPO =="N"
		SA1->( dbSeek( xFilial("SA1") + ZT3->ZT3_CODCF + ZT3->ZT3_LOJA ) )
		_cCGC:=SA1->A1_CGC

	ELSE
		SA2->( dbSeek( xFilial("SA2") + ZT3->ZT3_CODCF + ZT3->ZT3_LOJA ) )
		_cCGC:=SA2->A2_CGC
	ENDIF


//???????????????????????????????????????????????????????????????????????????????
// Montando o array para o pedido de venda
//???????????????????????????????????????????????????????????????????????????????
	_aSC5 := {}
	_aSC6 := {}
	_cItem := "01"
//???????????????????????????????????????????????????????????????????????????????
// Cabeçalho pedido de venda
//???????????????????????????????????????????????????????????????????????????????

	aAdd(_aSC5, {'C5_FILIAL', 	xFilial("SC5"),	NIL})
	aAdd(_aSC5, {'C5_TIPO', 	ZT3->ZT3_TIPO, 					NIL})
	aAdd(_aSC5, {'C5_CLIENTE', ZT3->ZT3_CODCF, 			NIL})
	aAdd(_aSC5, {'C5_LOJACLI', ZT3->ZT3_LOJA, 				NIL})
	aAdd(_aSC5, {'C5_CGC', _cCGC, 				NIL})
	aAdd(_aSC5, {'C5_NATUREZ', " ", 				NIL})
	aAdd(_aSC5, {'C5_CONDPAG', ZT3->ZT3_CONDPA, 				NIL})
	aAdd(_aSC5, {'C5_X_DTPRE', dDataBase, 			NIL})
	aAdd(_aSC5, {'C5_PRENF', 	'2', 					NIL})
	aAdd(_aSC5, {'C5_TABELA', 	ZT3->ZT3_CODTAB, 					NIL})
	aAdd(_aSC5, {'C5_VEND1', 	_cVend1, 					NIL})
	aAdd(_aSC5, {'C5_TRANSP', 	ZT3->ZT3_TRANSP, 					NIL})
	aAdd(_aSC5, {'C5_VOLUME1', 	ZT3->ZT3_VOLUME, 					NIL})
	aAdd(_aSC5, {'C5_ESPECI1', 	ZT3->ZT3_ESPECI, 					NIL})
	aAdd(_aSC5, {'C5_PBRUTO', 	ZT3->ZT3_PBRUTO, 					NIL})
	aAdd(_aSC5, {'C5_PESOL', 	ZT3->ZT3_PLIQUI, 					NIL})
	aAdd(_aSC5, {'C5_X_ORIG', '1', 					NIL})
//aAdd(_aSC5, {'C5_TPCOMPL', ' ', 					NIL})

//aAdd(_aSC5, {'C5_CODFIL', 	'01', 				NIL})
//aAdd(_aSC5, {'C5_CODEMP', 	'01', 				NIL})


// Itens pedido de venda

	// ENTÃO O NÚMERO  NÚMERO CORRENTE NA
	// TABELA ZT3 e ZT4
	While (ZT4->ZT4_NUMSF == ZT3->ZT3_NUM) .AND. (ZT4->ZT4_BLOCK!="S")

		cTipo:= POSICIONE("SB1",1,XFILIAL("SB1")+ZT4->ZT4_COD,'B1_TIPO')
		cLocaliz :=POSICIONE("SB1",1,XFILIAL("SB1")+ZT4->ZT4_COD,'B1_LOCALIZ')

		//_nValor:=A410Arred( _nValor, "C6_VALOR" )

		_nValor:=0
		_nPreco:=0
		_nQtdVen:=0
		_nPreco:=ZT4->ZT4_PRCUNI
		_nValor:=ZT4->ZT4_VALOR
		_nQtdVen:=IIF(cTipo $ "PA-PI-MP-EM" .AND. ZT3->ZT3_MOVEST=='S', ZT4->ZT4_QTDATE,ZT4_QTDSOL)

		_aLinha := {}
		aAdd( _aLinha, { 'C6_FILIAL', 	xFilial("SC6"), 	NIL } )
		aAdd( _aLinha, { 'C6_ITEM', 	_cItem,	 			NIL } )
		aAdd( _aLinha, { 'C6_PRODUTO', 	ZT4->ZT4_COD, 		NIL } )
		aAdd( _aLinha, { 'C6_DESCRI', 	ZT4->ZT4_DESC, 		NIL } )
		aadd(_aLinha,{"C6_QTDVEN",_nQtdVen,Nil})
	
		aadd(_aLinha,{"C6_PRCVEN", A410Arred(_nPreco,"C6_PRCVEN")  ,NIL})	
		aadd(_aLinha,{"C6_PRUNIT", A410Arred(_nPreco,"C6_PRCVEN"),Nil})
		if ZT3->ZT3_TES<>'541'
		aadd(_aLinha,{"C6_VALOR",A410Arred((_nPreco*_nQtdVen), "C6_VALOR" ) ,Nil})   //(ZT4->ZT4_PRCUNI * ZT4->ZT4_QTDATE)
		endif
		aadd(_aLinha,{"C6_TES",ZT3->ZT3_TES,Nil})
	
		IF cTipo $ 'PA'
			aAdd(_aLinha, {'C6_LOCAL','01',	NIL } )
		EndIf
		IF cTipo $ 'PI-MP-EM'
			aAdd(_aLinha, {'C6_LOCAL','11',	NIL } )
		EndIf

		IF cLocaliz=="S" .AND. ZT3->ZT3_MOVEST=="S"
			aAdd(_aLinha, {'C6_LOCALIZ','EXPEDICAO',	NIL } )
		ENDIF
		//ALERT('AQUI')

		aAdd( _aSC6, _aLinha )
		_cItem	:= Soma1( _cItem )

		ZT4->(DbSkip())
	End


// Chamada da rotina automatica

//	MsExecAuto( { |x, y, z| Mata410( x, y, z ) }, _aSC5, _aSC6, 3 )

  nOpcX := 3
   MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)},  _aSC5, _aSC6, nOpcX, .F.)
  
	IF lmsErroAuto
		MsgBox("Foram encontrados problemas na geraçao do pedido, um ou mais campos obrigatórios não foram preenchidos. Visualize o log de erros e informe ao depto de TI.", "Atenção", "ERRO")
		MostraErro()
		_cNumPed:=" "
	else
		//MsgBox("Pedido '" + SC5->C5_NUM + "' foi criado com sucesso.", "Informação", "INFO")
		U_MsgTimer ("Pedido " + SC5->C5_NUM + " foi criado com sucesso.")
		_cNumPed:=SC5->C5_NUM
	endif

	SA1->(RestArea(_aAreaSA1))
	SA2->(RestArea(_aAreaSA2))
	SB1->(RestArea(_aAreaSB1))
	SE4->(RestArea(_aAreaSE4))
	ZT3->(RestArea(_aAreaZT3))
	ZT4->(RestArea(_aAreaZT4))

RETURN(_cNumPed)

	******************************************************************************************************************************************************
STATIC FUNCTION sfLocalPad(cCOD)
	******************************************************************************************************************************************************
	Local _cLocal:=POSICIONE("SB1",1,XFILIAL("SB1")+cCOD,"B1_LOCPAD")

	IF _cLocal=="20"
		_cLocal:="11"
	ENDIF

RETURN(_cLocal)



