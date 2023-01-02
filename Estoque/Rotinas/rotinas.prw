#include "rwmake.ch"
#include "topconn.ch"

/* Rotinas de Uso Generico */

User Function ContaQ(pStr,pAntes,pMuda,pOrdem)
Local nRegs

TCQUERY pStr ALIAS ZZZ New
dbSelectArea("ZZZ")
nRegs := If( SOMA == Nil , 0, SOMA)
dbCloseArea()

pStr := StrTran(pStr,pAntes,pMuda)+If(pOrdem==Nil.Or.Empty(pOrdem),"", " ORDER BY "+pOrdem)
Return(nRegs)

User Function Stod(pData)
dDtRet := Ctod(SubStr(pData,7,2)+"/"+SubStr(pData,5,2)+"/"+SubStr(pData,1,4))
Return(dDtRet)

User Function Posicao(pCampo)
cCampo := pCampo+Space(10-Len(pCampo))
nPos   := AScan(aHeader,{|x| AllTrim(x[2]) == AllTrim(cCampo) })
Return(nPos)
********************************************************************************************************************
User Function VldCpoSx3(pCampo)
********************************************************************************************************************
Local lResp:=.T.
Local cAlias,cOrdem,cRecno
calias:=alias()
cOrdem:=dbSetOrder()
crecno:=recno()
DbSelectArea("SX3")
DbSetOrder(02)
If !DbSeek(pCampo)
	lResp:=.F.
Endif
dbSelectArea(calias)
dbSetOrder(cOrdem)
dbGoto(crecno)
Return(lResp)
********************************************************************************************************************
User Function fVer_Acesso(Par01,Par02,Par03,Par04,Par05,lAchou)
********************************************************************************************************************
Local lResp:=.T.
Local cCondicao
Local _cAlias :=Alias()
DbSelectArea("SZA")
DbSetOrder(01)
If DbSeek(xFilial("SZA")+SubStr(cUserName,1,15)+Upper(Procname(1)))
	cCondicao := Za_Condica
	If !Empty(Par01)
		cCondicao:=StrTran(cCondicao,"PAR01",Par01)
	ElseIf !Empty(Par02)
		cCondicao:=StrTran(cCondicao,"PAR02",Par02)
	ElseIf !Empty(Par03)
		cCondicao:=StrTran(cCondicao,"PAR03",Par03)
	ElseIf !Empty(Par04)
		cCondicao:=StrTran(cCondicao,"PAR04",Par04)
	ElseIf !Empty(Par05)
		cCondicao:=StrTran(cCondicao,"PAR05",Par05)
	Endif
	lResp := &(cCondicao)
Else
	lResp:=lAchou
Endif
dbSelectArea(_cAlias)
Return(lResp)
********************************************************************************************************************
User Function fGera_SDA(pFilial,pProd,pQtdOri,pQuant,pData,pLocal,pDoc,pSerie,pCli,pLoja,pTpNf,pOriDados,pNumSeq,pExclui)
********************************************************************************************************************
Local _cAlias :=Alias()
DbSelectArea("SDA")
DbSetOrder(01)
If !pExclui
	RecLock("SDA",.T.)
	Sda->Da_Filial  :=pFilial
	Sda->Da_Produto :=pProd
	Sda->Da_QtdOri  :=pQtdOri
	Sda->Da_Saldo   :=pQuant
	Sda->Da_Data    :=pData
	//           Sda->Da_LoteCtl
	Sda->Da_Local   :=pLocal
	Sda->Da_Doc     :=pDoc
	Sda->Da_Serie   :=pSerie
	Sda->Da_CliFor  :=pCli
	Sda->Da_Loja    :=pLoja
	Sda->Da_TipoNF  :=pTpNf
	Sda->Da_Origem  :=pOriDados
	Sda->Da_NumSeq  :=pNumSeq
	//           Sda->Da_Empenho
	//           Sda->Da_QtSegum
	//           Sda->Da_QtdOri2
	//           Sda->Da_Emp2
	//           Sda->Da_RegWMS
	//           Sda->Da_Kit
	//           Sda->Da_DtMov
	Sda->(MsUnLock())
ElseIf pExclui .and. Sda->(DbSeek(pFilial+pProd+pLocal+pNumSeq+pDoc+pSerie+pCli+pLoja))
	RecLock("SDA",.f.)
	Delete
	Sda->(MsUnLock())
Endif

dbSelectArea(_cAlias)
Return
********************************************************************************************************************
User Function fBx_SBF(pProduto,pLocal,pQuant,pDoc,pSerie,pCliFor,pLoja,pTipoNf,pNumSeq,pItem)
********************************************************************************************************************
Local aVet:={}
Local _cAlias :=Alias()
Local i
aVet:=u_fEndQtd(pProduto,pLocal,"",pQuant,"N")
For i:=1 To Len(aVet)
	u_GeraSDB(pProduto,pLocal,aVet[i,2],pDoc,pSerie,pCliFor,pLoja,pTipoNF,aVet[i,3],pNumSeq,pItem,"999","100","999")
	If SubStr(aVet[i,2],1,3) <> "SEM"
		IF !u_fAtuSBF(pProduto,pLocal,aVet[i,2],aVet[i,3]*-1)
			//Msgbox("Endereco nao encontrado para este produto - "+pProduto,pLocal+" - "+aVet[i,2])
			u_fGera_SDA(xFilial("SD1"),pProduto,aVet[i,3],aVet[i,3],dDataBase,pLocal,pDoc,pSerie,pCliFor,pLoja,pTipoNf,"SBE",pNumSeq,.f.)
		Endif
	EndIf
Next i
dbSelectArea(_cAlias)
Return
*********************************************************************************************************************
User Function fUsa_End(pProduto)
*********************************************************************************************************************
Local lResp:=.f.
If Posicione("SB1",1,xFilial("SB1")+pProduto,"B1_LOCALIZ") = "S"
	lResp:=.T.
Endif
Return(lResp)
*********************************************************************************************************************
User Function fBlqComp(pProduto,pData)
*********************************************************************************************************************
Local lResp:=.T.
Local _sAlias,cTipo
_sAlias := Alias()
cTipo:=Posicione("SB1",1,xFilial("SB1")+pProduto,"B1_TIPO")
If cTipo == "MN"
	DbSelectArea("SG1")
	DbSetOrder(02)
	DbSeek(xFilial("SG1")+pProduto)
	While SG1->(!Eof()).and. xFilial("SG1")+pProduto == Sg1->G1_Filial+Sg1->G1_Comp
		If pData < Sg1->G1_Ini .OR. pData > SG1->G1_Fim
			lResp:=.F.
			Msgbox("Produto bloqueado na estrutura da Engenharia!Item: "+Sg1->G1_Cod)
			Exit
		Endif
		DbSelectArea("SG1")
		DbSkip()
	End
Endif
dbSelectArea(_sAlias)
Return(lResp)

/* Rotinas de Uso Generico */
User Function CAD_SZA()
AxCadastro("SZA","Cadastro de Acesso")
Return

*********************************************************************************************************************
User Function fTemSaldo(pProduto,pLocal,pEnd,pQuant)
*********************************************************************************************************************
Local lResp:=.F. ,_sAlias
Local nQtdSbf,nQtdEmp
Local nSaldoDisp:=0
_sAlias := Alias()

Sb2->(dbSetOrder(1))
If Sb2->(dbSeek(xFilial('SB2')+pProduto+pLocal, .F.))
	nSaldoDisp += SaldoSB2()
EndIf

If nSaldoDisp >=pQuant
	lResp:=.T.
Endif

If Empty(pEnd).and.lResp
	lResp:=.T.
ElseIf !Empty(pEnd).and. Localiza(pProduto)
	If QtdComp(SaldoSBF(pLocal,pEnd,pProduto,"","","")) < pQuant
		lResp:=.F.
	Endif
Endif
DbSelectArea(_sAlias)
Return(lResp)
**********************************************************************************************************************
User Function fSd3261(pMov,pLocal,pLocaliz)
**********************************************************************************************************************
Local _aCab  :={}
Local _aItem := {}
LOCAL aVetor :={}
lMsHelpAuto := .T.  // se .t. direciona as mensagens de help
lMsErroAuto := .F.

IF pMov==6
	Aadd(_acab,{"D3_DOC"	    ,SD3->D3_DOC	,NIL})
	Aadd(_acab,{"D3_TM"    	    ,SD3->D3_TM	    ,NIL})
	Aadd(_acab,{"D3_CC"     	,SD3->D3_CC  	,NIL})
	Aadd(_acab,{"D3_EMISSAO"	,SD3->D3_Emissao,Nil})
	
	Aadd(_aitem,{"D3_COD"		,SD3->D3_COD	 ,NIL})
	Aadd(_aitem,{"D3_UM"	    ,SD3->D3_UM      ,NIL})
	Aadd(_aitem,{"D3_QUANT"		,SD3->D3_Quant   ,NIL})
	Aadd(_aitem,{"D3_LOCAL"	    ,SD3->D3_Local   ,NIL})
	Aadd(_aitem,{"D3_GRUPO"	    ,SD3->D3_GRUPO   ,NIL})
	
ElseIf pMov == 1  //Saidas de Remessa
	
	Sb2->(DbSetOrder(01))
	If !SB2->(DbSeek(xFilial("SB2")+SD2->D2_Cod+pLocal))
		Sb2->(RecLock("SB2",.T.))
		Sb2->B2_Filial := xFilial("SB2")
		Sb2->B2_Cod    := SD2->D2_Cod
		Sb2->B2_Local  :=pLocal
		Sb2->(MsUnLock())
	EndIf
	
	DbSelectArea("SD2")
	DbSETORDER(03)
	aVetor:={ {"D3_TM"      ,"131"         ,NIL},;
	{"D3_COD"     ,Sd2->D2_Cod   ,NIL},;
	{"D3_QUANT"   ,Sd2->D2_Quant ,NIL},;
	{"D3_LOCAL"   ,pLocal        ,NIL},;
	{"D3_EMISSAO" ,ddatabase     ,NIL},;
	{"D3_SERVIC"	,_cServico     ,NIL},;
	{"D3_LOTECTL"	,_cLoteCtl     ,NIL},;
	{"D3_LOCALIZ"	,_cLocaliz     ,NIL},;
	{"D3_CC"		,_cCCusto      ,NIL},;
	{"D3_DOCMM"	,_cNumMM       ,NIL},;
	{"D3_REGSD2"	,cChaveSD2     ,NIL},;
	{"D3_REGWMS"	,_cRegWms      ,NIL};
	}
	
	MSExecAuto({|x,y| mata240(x,y)},aVetor,3) //Inclusao
	
ElseIf pMov = 2 //Entradas de  Remessa
	DbSelectArea("SD1")
	Aadd(_acab,{"D3_DOC"	    ,SD1->D1_DOC	,NIL})
	Aadd(_acab,{"D3_TM"    	    ,"531"     		,NIL})
	Aadd(_acab,{"D3_CC"    	    ,""  	    	,NIL})
	Aadd(_acab,{"D3_EMISSAO"	,SD1->D1_DtDigit,Nil})
	
	Aadd(_aitem,{"D3_COD"		,SD1->D1_COD	 ,NIL})
	Aadd(_aitem,{"D3_UM"	    ,SD1->D1_UM      ,NIL})
	Aadd(_aitem,{"D3_QUANT"		,SD1->D1_Quant   ,NIL})
	Aadd(_aitem,{"D3_LOCAL"	    ,pLocal          ,NIL})
	Aadd(_aitem,{"D3_GRUPO"	    ,SD1->D1_GRUPO   ,NIL})
	Aadd(_aitem,{"D3_LOCALIZ"	,pLocaliz        ,NIL})
Endif
If pMov == 6
	MSExecAuto({|x,y,z| MATA241(x,y,z)},_aCab,{_aItem},6) //Usado para Gerar  Estorno
ElseiF pMov == 2
	MSExecAuto({|x,y,z| MATA241(x,y,z)},_aCab,{_aItem},3)  //Usaod para Gerar movimentos
ENDIF
//Forca documento igual a da Nota
If lMsErroAuto
	Mostraerro()
Else
	If pMov = 1 .or.  pMov = 2
		dbSelectArea("SDA") // Seleciona Saldo a Endereçar
		DBSETORDER(1)  // DA_FILIAL + DA_DOC + DA_SERIE + DA_CLIFOR + DA_LOJA + DA_PRODUTO
		If DbSeek(xFilial("SDA")+Sd3->D3_Cod+Sd3->D3_Local+Sd3->D3_NumSeq)
			RecLock("SDA",.F.)
			SDA->DA_Doc   :=IIf(pMov = 1,SD2->D2_DOC,SD1->D1_DOC)
			SDA->DA_NUMSEQ:=IIf(pMov = 1,SD2->D2_NUMSEQ,SD1->D1_NUMSEQ)
			MsUnLock()
		Endif
		dbSelectArea("SDB") // Seleciona Saldo a Endereçar
		DBSETORDER(1)  // DA_FILIAL + DA_DOC + DA_SERIE + DA_CLIFOR + DA_LOJA + DA_PRODUTO
		If DbSeek(xFilial("SDB")+Sd3->D3_Cod+Sd3->D3_Local+Sd3->D3_NumSeq)
			RecLock("SDB",.F.)
			SDB->DB_Doc   :=IIf(pMov = 1,SD2->D2_DOC,SD1->D1_DOC)
			SDB->DB_NUMSEQ:=IIf(pMov = 1,SD2->D2_NUMSEQ,SD1->D1_NUMSEQ)
			MsUnLock()
		Endif
		
		DbSelectArea("SD3")
		RecLock("SD3",.F.)
		SD3->D3_Doc   :=IIf(pMov = 1,SD2->D2_DOC   ,SD1->D1_DOC )
		SD3->D3_NUMSEQ:=IIf(pMov = 1,SD2->D2_NUMSEQ,SD1->D1_NUMSEQ)
		MsUnLock()
	Endif
Endif
Return(lMsErroAuto)
*****************************************************************************************************************
User Function fSd3265(pMov,pProd,pNumSeq,pDoc,pLocal,pLocaliz)
*****************************************************************************************************************
Local _aItensSDB := {}
Local _aCab := {}
Local _aItem:= {}
Local cemp
If Posicione("SB1",1, xFilial("SB1")+pProd, "B1_LOCALIZ") <> "S"
	Return
Endif
lMsHelpAuto := .T.  // se .t. direciona as mensagens de help
lMsErroAuto := .F.
        
cemp:=SM0->M0_NOMECOM

dbSelectArea("SDA") // Seleciona Saldo a Endereçar
DBSETORDER(1)  // DA_FILIAL + DA_DOC + DA_SERIE + DA_CLIFOR + DA_LOJA + DA_PRODUTO
If DbSeek(xFilial("SDA")+pProd+pLocal+pNumSeq+pDoc)
	// Rotina Automatica de Endereçamento
	
	_acab := {{ "DA_PRODUTO", SDA->DA_PRODUTO,Nil},;
	{ "DA_QTDORI" , SDA->DA_QTDORI ,Nil},;
	{ "DA_SALDO"  , SDA->DA_SALDO  ,Nil},;
	{ "DA_DATA"   , SDA->DA_DATA   ,Nil},;
	{ "DA_LOCAL"  , SDA->DA_LOCAL  ,Nil},;
	{ "DA_DOC"    , SDA->DA_DOC    ,Nil},;
	{ "DA_ORIGEM" , SDA->DA_ORIGEM ,Nil},;
	{ "DA_NUMSEQ" , SDA->DA_NUMSEQ ,Nil}}

	
	If pMov==4 .AND. SDA->dA_saldo < Sda->Da_QtdOri  //Estorno
		dbSelectArea("SDB") // Seleciona Saldo a Endereçar
		DBSETORDER(1)  // DA_FILIAL + DA_DOC + DA_SERIE + DA_CLIFOR + DA_LOJA + DA_PRODUTO
		If DbSeek(xFilial("SDB")+pProd+pLocal+pNumSeq+pDoc)
			Aadd(_aitem,{"DB_ITEM"		, SDB->Db_Item 		,NIL})
			Aadd(_aitem,{"DB_ESTORNO"	, "S"	        	,NIL})
			Aadd(_aitem,{"DB_LOCALIZ"	, SDB->Db_LOCALIZ  	,NIL})
			Aadd(_aitem,{"DB_DATA"		, SDB->Db_Data  	,NIL})
			Aadd(_aitem,{"DB_QUANT"	 	, SDB->DB_QUANT		,NIL})
			
		Endif
	ElseiF pMov==3 .and. SDA->DA_SALDO <= SDA->DA_QTDORI  //Distribuição
		_aitem := {{"DB_ITEM"	  ,"0001"	 ,Nil},;
		{"DB_ESTORNO"  ," "	     ,Nil},;
		{"DB_LOCALIZ"  ,pLocaliz    ,Nil},;
		{"DB_DATA"	  ,dDataBase     ,Nil},;
		{"DB_QUANT"  ,SDA->DA_SALDO ,Nil}}
	Endif
	x_Area  := Alias()
	x_Rec   := Recno()
	x_Ind   := Indexord()
	//Endereçamento
	aadd(_aItensSDB,_aitem)//Executa o endereçamento do item
	if len(_aitem)>0 .and. len(_acab)>0
		MSExecAuto({|X,Y,Z|MATA265(X,Y,Z)},_acab,_aItensSDB,pMov)
	endif
	DbSelectArea(x_Area)
	DbSetOrder(x_Ind)
	DbGoto(x_Rec)
	If lMsErroAuto
		Mostraerro()
	endif
Endif
Return(lMsErroAuto)
*********************************************************************************************************************
User Function GeraEtqProd(pProduto,pNota,pSerie,pItem,pFornece,pLoja,pQuant)
*********************************************************************************************************************
Local cNumEtiqueta:=""
Local calias:=alias()
Local cOrdem:=dbSetOrder()
cNumEtiqueta:=GetSXENum("ZC5","ZC5_NUM")
DbSelectArea("ZC5")
If RecLock("ZC5",.T.)
	ZC5->ZC5_Filial:=xFilial("ZC5")
	ZC5->ZC5_Num   :=cNumEtiqueta
	ZC5->ZC5_Data  :=dDataBase
	ZC5->ZC5_Cod   :=pProduto
	ZC5->ZC5_Doc   :=pNota
	ZC5->ZC5_Serie :=pSerie
	ZC5->ZC5_Item  :=pItem
	ZC5->ZC5_Fornec:=pFornece
	ZC5->ZC5_Loja  :=pLoja
	ZC5->ZC5_Status:="0"
	ZC5->ZC5_UserI :=cUserName
	ZC5->ZC5_Quant :=pQuant
	// ZC5->ZC5_UserA :=cUserName
	MsUnLock()
	CONFIRMSX8()
Else
	RollBackSx8()
	cNumEtiqueta:=""
EndIf
dbSelectArea(calias)
dbSetOrder(cOrdem)
Return(cNumEtiqueta)
*********************************************************************************************************************
User Function AltEtqProd(pNum,pLocal,pEndereco)
*********************************************************************************************************************
Local lResp:=.F.
Local calias:=alias()
Local cOrdem:=dbSetOrder()
DbSelectArea("ZC5")
DbSetOrder(01)
If DbSeek(xFilial("ZC5")+pNum)
	RecLock("ZC5",.f.)
	ZC5->ZC5_Status:="1"
	ZC5->ZC5_Local :=pLocal
	ZC5->ZC5_Locali:=pEndereco
	ZC5->ZC5_DtMov :=dDataBase
	ZC5->ZC5_UserA :=cUserName
	MsUnLock()
	lResp:=.T.
EndIf
dbSelectArea(calias)
dbSetOrder(cOrdem)
Return(lResp)
********************************************************************************************************************
User Function MM_ATUSD3(_cDoc,_cTm,_cProdD3,_cLocal,_nQuant,_cLoteCtl,_cLocaliz,_cLocDes,_cEndDes,_cCC)
********************************************************************************************************************
Local _cDocTm	:= _cDoc
Local _aVetor	:= {}
Local _cTime    := TIME()
Local _aAreaAtu := GetArea()
Local _cTm		 := _cTm
Local _cProdD3	 := _cProdD3

aVetor:={{"D3_TM"	,_cTm,NIL},;
{"D3_COD"			,_cProdD3,NIL},;
{"D3_QUANT"			,_nQuant,NIL},;
{"D3_DOC"			,_cDocTm,NIL},;
{"D3_EMISSAO"		,dDataBase,NIL},;
{"D3_LOCAL"			,_cLocal,NIL},;
{"D3_CC"			,_cCC,NIL},;
{"D3_SERVIC"		,' ',NIL},;
{"D3_LOTECTL"		,_cLoteCtl,NIL},;
{"D3_LOCALIZ"		,_cLocaliz,NIL}}
lMSHelpAuto := .F.
lMSErroAuto := .F.
MSExecAuto({|x,y| MATA240(x,y)},aVetor,3)

If !lMSErroAuto
	dbSelectArea("SDB") // Seleciona Saldo a Endereçar
	DBSETORDER(1)  // DA_FILIAL + DA_DOC + DA_SERIE + DA_CLIFOR + DA_LOJA + DA_PRODUTO
	If DbSeek(xFilial("SDB")+Sd3->D3_Cod+Sd3->D3_Local+Sd3->D3_NumSeq)
		RecLock("SDB",.F.)
		SDB->DB_Doc   :=_cDocTm
		MsUnLock()
	Endif
	
	dbSelectArea("SDA") // Seleciona Saldo a Endereçar
	DBSETORDER(1)  // DA_FILIAL + DA_DOC + DA_SERIE + DA_CLIFOR + DA_LOJA + DA_PRODUTO
	If DbSeek(xFilial("SDA")+Sd3->D3_Cod+_cLocDes+Sd3->D3_NumSeq)
		RecLock("SDA",.F.)
		SDA->DA_Doc   :=_cDocTm
		MsUnLock()
	Endif
	
	DbSelectArea("SD3")
	RecLock("SD3",.F.)
	SD3->D3_Doc   :=_cDocTm
	MsUnLock()
	
Endif //Fim do If !lMSErroAuto

IF lMSErroAuto
	_lRet := .T.
	MostraErro()
ElseIf u_fUsa_End(SD3->D3_COD) .AND. _cLocDes = '10' .and.u_f_NDistr10(SD3->D3_COD)
	//A100Distri(SD3->D3_COD,_cLocDes,SD3->D3_NUMSEQ,SD3->D3_DOC,,,,_cEndDes,Nil,SD3->D3_QUANT,SD3->D3_LOTECTL,SD3->D3_NUMLOTE,SD3->D3_QTSEGUM,,,SD3->D3_QUANT)
	u_fSd3265(3,SD3->D3_COD,SD3->D3_NUMSEQ,SD3->D3_DOC,_cLocDes,_cEndDes)
Endif

RestArea(_aAreaAtu)
Return(lMSErroAuto)
********************************************************************************************************************
User Function f_PagProd(_cProd)//Verifica se o pagamento de produto é parcial,completo ou não controla
********************************************************************************************************************
Local _aAreaAtu := GetArea()
cTipo_Pag :=Posicione("SB1",1,xFilial("SB1")+_cProd,"B1_ENVRESD")
RestArea(_aAreaAtu)
Return(cTipo_Pag)
********************************************************************************************************************
User Function f_NDistr10(_cProd)//Verifica se deve distribuir a baixa da M.M. no armazem 10
********************************************************************************************************************
Local lResp:=.T.
Local _aAreaAtu := GetArea()
Local cDistr10 := GetMV("MV_DIST10")
//  T ; distribui todos  os produtos do armazém 10
//  P ; Não distribui    os produtos do armazém 10 que forem de pagamento parciais
//  C ; Não distribui    os produtos do armazém 10 que forem de pagamento completos
//  N ; Não distrinui   nenhum produto do armazém 10 na baixa da M.M.
If cDistr10 = "T"
	lResp:=.T.
ElseIf cDistr10 = "N"
	lResp:=.F.
ElseIf cDistr10 = "P" .and. U_f_PagProd(_cProd) = "P"
	lResp:=.F.
ElseIf cDistr10 = "C" .and. U_f_PagProd(_cProd) = "C"
	lResp:=.F.
Endif
RestArea(_aAreaAtu)
Return(lResp)

*********************************************************************************************************************
User Function vldRastro(_cProduto)
*********************************************************************************************************************
Local lResp:=.F.
Local _aAreaAtu := GetArea()
cRastro:=Posicione("SB1",1,xFilial("SB1")+_cProduto,"B1_RASTRO")
If cRastro $ "S/L"
	lResp:=.T.
Endif
RestArea(_aAreaAtu)
Return(lResp)
********************************************************************************************************************
User Function vldBlqLocaliz(_cLocal,_cEndereco,_lMens)//Verifica se o endereços esta Bloqueado ou não
********************************************************************************************************************
Local lResp:=.T.
Local _aAreaAtu := GetArea()
cBlq:=Posicione("SBE",1,xFilial("SBE")+_cLocal+_cEndereco,"BE_STATUS")
If cBlq = '3'
	lResp:=.F.
	MsgBox("Endereço bloqueado para movimentação",'Alerta')
Endif
RestArea(_aAreaAtu)
Return(lResp)
********************************************************************************************************************
User Function fAtuSD3(pTm,pCod,pUm,pQuant,pCf,pLocOri,pDoc,pNumSeq,pTipo,pCm1,pNumSeri,pCCOri,pLocaliz)
********************************************************************************************************************
//- Atualizando tabela das movimentações internas. "SD3"
DBSELECTAREA("SD3")
RecLock("SD3" , .T. )
SD3->D3_FILIAL  := xFilial("SD3")
SD3->D3_TM      := pTM
SD3->D3_COD     := pCod
SD3->D3_UM      := pUM
SD3->D3_QUANT   := pQuant
SD3->D3_CF      := pCf //"RE3"
SD3->D3_LOCAL   := pLocOri
SD3->D3_DOC     := pDoc
SD3->D3_NUMSERI := pNUMSERI
SD3->D3_EMISSAO := dDataBase
SD3->D3_NUMSEQ  := pNumSeq
SD3->D3_TIPO    := Posicione("SB1",1,xFilial("SB1")+SD3->D3_COD,"B1_TIPO")//pTIPO
SD3->D3_USUARIO := SUBSTR(cUsuario,7,15)
SD3->D3_CHAVE   := IF(pCf<>"DE4","E0","E9")
SD3->D3_CC      := pCCOri
SD3->D3_CUSTO1  := pQuant*pCM1
SD3->D3_LOCALIZ := pLocaliz
SD3->D3_GRUPO   := Posicione("SB1",1,xFilial("SB1")+pCod,"B1_GRUPO")
SD3->D3_LOTECTL := If(pTipo$"PA/PL".and.Rastro(pCod,"S"),Substr(DtoS(dDatabase),1,6)+ IIF(DAY(dDatabase) > 15,'B','A') + '1',SD3->D3_LOTECTL)
MsUnLock()

Return
********************************************************************************************************************
User Function SD3_DOC()
********************************************************************************************************************
Local cD3_Doc:=Space(9)
Local lContinua:=.T.
Local cSeq:="ZZZ"

If Substring(cUserName,1,4) == cNumEmp
	cD3_Doc :=SubStr(cUserName,5,6)+cSeq
Else
	cD3_Doc :=SubStr(cUserName,1,6)+cSeq
Endif
//cD3_Doc:= Substr(Time(),7,2)+Substring(GetSXENum("SD3","D3_DOC"),1,2)+Substr(Time(),7,2)
//cD3_Doc:= GetSXENum("SD3","D3_DOC")
//CONFIRMSX8()
//LEFT(M->D3_OP,3)+Substr(Time(),1,2)+Substr(Time(),4,2)+Substr(Time(),7,2)
Sd3->(DbSetOrder(02))
Sd3->(DbSeek(xFilial("SD3")+cD3_Doc,.T.))
sd3->(DbSkip(-1))
cD3_Doc:=Sd3->D3_Doc
While lContinua
	Sd3->(DbSetOrder(02))
	If !Sd3->(DbSeek(xFilial("SD3")+cD3_Doc))
		lContinua:=.f.
	Else
		cD3_Doc:=SubStr(cD3_Doc,1,6)+SOMA1(SubStr(cD3_Doc,7,3),3)
	Endif
End

If SubStr(cUserName,1,4) == cNumEmp
	If SubStr(cUserName,5,6)<> SubStr(cD3_Doc,1,6)
		cD3_Doc :=SubStr(cUserName,5,6)+"001"
	Endif
Else
	If SubStr(cUserName,1,6)<> SubStr(cD3_Doc,1,6)
		cD3_Doc :=SubStr(cUserName,1,6)+"001"
	Endif
Endif

//ALERT(cD3_Doc)
//alert(TIME())

Return(cD3_Doc)
********************************************************************************************************************
User Function COD_Retrabalho(pCod)
********************************************************************************************************************
Local _aAreaAtu := GetArea()
Local lResp     :=.f.
Local cProduto  :=pCod
Local cTpPro    :=RIGHT(Alltrim(pCod),2)
Local cProduto2 :=Posicione("SB1",1,xFilial("SB1")+pCod,'B1_CODAOC')
if cTpPro='-R'
	cProduto:=cProduto2
Endif
RestArea(_aAreaAtu)
Return(ALLTRIM(cProduto))
********************************************************************************************************************
User Function AocWmsSda(pLocaliz)
********************************************************************************************************************
Local c_Area  := Alias()
Local n_Rec   := Recno()
Local n_Ind   := Indexord()
Local cItem
aCbEnd   := {}  //cabec da chamada da rotina aut
aItEnd   := {}  //itens da chamada da rotina aut
DbSelectArea("SDA")
cItem:=fPegaItemSDb(SDA->DA_DOC,SDA->DA_SERIE,SDA->DA_CLIFOR,SDA->DA_LOJA ,SDA->DA_PRODUTO,SDA->DA_LOCAL,SDA->DA_NUMSEQ)
aCbEnd:={	{"DA_FILIAL"	,xFilial("SDA") ,NIL},;
{"DA_PRODUTO"	,SDA->DA_PRODUTO,NIL},;
{"DA_QTDORI"	,SDA->DA_QTDORI ,NIL},;
{"DA_SALDO"  	,SDA->DA_SALDO  ,NIL},;
{"DA_DATA"  	,SDA->DA_DATA   ,NIL},;
{"DA_LOTECTL"	,SDA->DA_LOTECTL,NIL},;
{"DA_NUMLOTE"	,SDA->DA_NUMLOTE,NIL},;
{"DA_LOCAL"		,SDA->DA_LOCAL  ,NIL},;
{"DA_DOC"		,SDA->DA_DOC    ,NIL},;
{"DA_SERIE"		,SDA->DA_SERIE  ,NIL},;
{"DA_CLIFOR"	,SDA->DA_CLIFOR ,NIL},;
{"DA_LOJA"		,SDA->DA_LOJA   ,NIL},;
{"DA_TIPONF"	,SDA->DA_TIPONF ,NIL},;
{"DA_ORIGEM"	,SDA->DA_ORIGEM ,NIL},;
{"DA_NUMSEQ"	,SDA->DA_NUMSEQ ,NIL},;
{"DA_QTSEGUM"	,SDA->DA_QTSEGUM ,NIL},;
{"DA_QTDORI2"	,SDA->DA_QTDORI2 ,NIL};
}

Sb1->(DbSetOrder(01))
Sb1->(DbSeek(xFilial("SB1")+SDA->DA_PRODUTO))
If !empty(Sb1->B1_Conv).and. !empty(Sb1->B1_TipConv).and. !empty(Sb1->B1_Segum)
	nSegum:=ConvUm(SDA->DA_PRODUTO,Abs(pQuant),0,2)
Else
	nSegum:=0
Endif

aadd(aItEnd,{{"DB_ITEM"     ,cItem           ,NIL},;
{"DB_ESTORNO"  ,""              ,NIL},;
{"DB_LOCALIZ"  ,pLocaliz        ,NIL},;
{"DB_QUANT"    ,SDA->DA_SALDO   ,NIL},;
{"DB_DATA"	    ,dDataBase       ,NIL},;
{"DB_NUMSERI"	,Space(20)       ,NIL},;
{"DB_QTSEGUM"	,nSegum          ,NIL},;
{"DB_SERVIC"	,SPACE(03)       ,NIL},;
{"DB_ESTDES"	,SPACE(06)       ,NIL},;
{"DB_DATAFIM"	,CTOD("//")      ,NIL},;
{"DB_KIT"	    ,SPACE(10)      ,NIL},;
{"DB_DTMOV"	,CTOD("//")      ,NIL};
})

If pQuant > 0
	lMSHelpAuto := .F.
	lMSErroAuto := .F.
	MSExecAuto({|x,y,z| MATA265(x,y,z)},aCbEnd,aItEnd,3)//rot automatica de enderecamento
	
	If lMsErroAuto
		DLVTAviso('ATENCAO', 'Nao foi gerado movimento endereçamento para este item')
	endif
Endif
Return
*********************************************************************************************************************
Static Function fPegaItemSDb(pDoc,pSerie,pClifor,pLoja,pProduto,pLocal,pNumSeq)
*********************************************************************************************************************
// Função para pegar a proxima sequencia dos itens da distribuição de endereço
Local cItem :="0000"
DbSelectArea("SDB")
DbSetOrder(01)
DbSeek(xFilial("SDB")+pProduto+pLocal+pNumSeq+pDoc+pSerie+pCliFor+pLoja)
While !Eof().and. xFilial("SDB")+pProduto+pLocal+pNumSeq+pDoc+pSerie+pCliFor+pLoja == ;
	Sdb->Db_Filial+Sdb->Db_Produto+Sdb->Db_local+Sdb->db_NumSeq+Sdb->Db_Doc+Sdb->Db_Serie+Sdb->Db_CliFor+Sdb->Db_Loja
	cItem:=Sdb->Db_Item
	DbSkip()
End
cItem:=StrZero(Val(cItem)+1,4)
Return(cItem)
*********************************************************************************************************************
USER Function Ajb2_QACLASS(pCod,pLocOri,pLocDes)//Corrigi movimento da função A100DISTRI
*********************************************************************************************************************
Local _aAreaAtu := GetArea()
Local nQtdDes,nQtdOri

cQuery:=" SELECT SUM(DA_SALDO)AS DA_SALDO "
cQuery+=" FROM "+RetSqlName("SDA")+" WHERE D_E_L_E_T_<>'*' AND DA_LOCAL='"+pLocOri+"' AND "
cQuery+=" DA_SALDO <> 0 AND "
cQuery+=" DA_FILIAL  = '"+xFilial("SB1")+"' AND "
cQuery+=" DA_PRODUTO = '"+pCod+"'"
TCQUERY cQuery ALIAS TRX New
dbSelectArea("TRX")
DbGotop()
nQtdOri:=IF(TRX->(!Eof()),Trx->DA_SALDO,0)
dbCloseArea("TRX")

DbSelectArea("SB2")
DbSetOrder(01)
if DbSeek(xFilial("SB2")+pCod+pLocOri)
	RecLock("SB2",.f.)
	Sb2->B2_QaClass:=nQtdOri
	Sb2->(MsUnLock())
Endif

cQuery:=" SELECT SUM(DA_SALDO)AS DA_SALDO "
cQuery+=" FROM "+RetSqlName("SDA")+" WHERE D_E_L_E_T_<>'*' AND DA_LOCAL='"+pLocDes+"' AND "
cQuery+=" DA_SALDO <> 0 AND "
cQuery+=" DA_FILIAL  = '"+xFilial("SB1")+"' AND "
cQuery+=" DA_PRODUTO = '"+pCod+"'"
TCQUERY cQuery ALIAS TRX New
dbSelectArea("TRX")
DbGotop()
nQtdDes:=IF(TRX->(!Eof()),Trx->DA_SALDO,0)
dbCloseArea("TRX")

DbSelectArea("SB2")
DbSetOrder(01)
if DbSeek(xFilial("SB2")+pCod+pLocDes)
	RecLock("SB2",.f.)
	Sb2->B2_QaClass:=nQtdDes
	Sb2->(MsUnLock())
Endif

RestArea(_aAreaAtu)
Return
**********************************************************************************************************************
User Function TbSx5ZL(l1Elem)//Tela de Seleção de Armazéns
**********************************************************************************************************************
Local cTitulo:=""
Local MvPar:=""
Local MvParDef:=""

Private aSit:={}
l1Elem := If (l1Elem = Nil , .F. , .T.)
lTipoRet := .T.

//
cAlias := Alias() 					 // Salva Alias Anterior
//
IF lTipoRet
	MvPar:=&(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
	mvRet:=Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno
EndIF

dbSelectArea("SX5")
If dbSeek(cFilial+"0074")
	cTitulo := Alltrim(Left(X5Descri(),30))
Endif
If dbSeek(cFilial+"ZL")
	//CursorWait()
	While !Eof() .And. SX5->X5_Tabela == "ZL"
		//If Len(Alltrim(Sx5->X5_DescSpa))=1
		Aadd(aSit,SubStr(SX5->X5_Chave,1,2) + " - " + Alltrim(X5Descri()))
		MvParDef+=SubStr(Sx5->X5_DescSpa,1,1)
		//MvParDef+=SubStr(Sx5->X5_Chave,1,2)
		//Endif
		dbSkip()
	Enddo
	//CursorArrow()
	//Else
	//	aSit := {"  - Todos"}
	//	MvParDef:=" "
	//	cTitulo :=" Armazém Envision "
Endif
IF lTipoRet
	IF f_Opcoes(@MvPar,cTitulo,aSit,MvParDef,12,49,.F.)//l1Elem)  // Chama funcao f_Opcoes
		&MvRet := mvpar                                                                          // Devolve Resultado
	EndIF
EndIF
dbSelectArea(cAlias) 								 // Retorna Alias
Return( IF( lTipoRet , .T. , MvParDef ) )

**********************************************************************************************************************
User Function F4_CSolEnv(pProd,pLocal,pLocaliz,pCpoSb8,pCpoSbf,pCpoSb2)
**********************************************************************************************************************
Do Case
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³F4 para Rastreabilidade                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case (pCpoSb8 $ ReadVar())
		F4Lote(,,,"",pProd,pLocal)
	Case ( pCpoSbf $ ReadVar() )
		F4Localiz( ,,, "A260",pProd,pLocal,0,pLocaliz)
	Case ( pCpoSb2 $ ReadVar() )
		MaViewSB2(pProd,,pLocal)
EndCase
Return

//***********************************************************************************************************************************
User Function E_RunExcel(pArquivo)
//***********************************************************************************************************************************
Local oExcelApp
Local cPathExcel:="\\ENV023\TOTVS\protheus_data\system\Excel\"

If ! ApOleClient( 'MsExcel' )        //Verifica se o Excel esta instalado
	MsgStop( 'MsExcel nao instalado' )
	Return
EndIf
If MSGYESNO('Você esta processando na Envision II ? ','Processo')
	cPathExcel:="\\Env027\Microsiga\Excel\"
Endif

If    File("C:\Program Files\Microsoft Office\Office11\Excel.exe")
	WinExec("C:\Program Files\Microsoft Office\Office11\Excel.exe "+cPathExcel+pArquivo )
ElseIf  File("C:\Program Files (x86)\Microsoft Office\OFFICE11\EXCEL.EXE")
	WinExec("C:\Program Files (x86)\Microsoft Office\OFFICE11\EXCEL.EXE  "+cPathExcel+pArquivo )
ElseIf  File("C:\Program Files (x86)\Microsoft Office\OFFICE12\EXCEL.EXE")
	WinExec("C:\Program Files (x86)\Microsoft Office\OFFICE12\EXCEL.EXE  "+cPathExcel+pArquivo )
ElseIf File("C:\Arquivos de Programas\Microsoft Office\Office11\Excel.exe")
	WinExec("C:\Arquivos de Programas\Microsoft Office\Office11\Excel.exe "+cPathExcel+pArquivo )
ElseIf File("C:\Program Files\Microsoft Office\Office10\Excel.exe")
	WinExec("C:\Program Files\Microsoft Office\Office10\Excel.exe "+cPathExcel+pArquivo )
ElseIf File("C:\Arquivos de Programas\Microsoft Office\Office10\Excel.exe")
	WinExec("C:\Arquivos de Programas\Microsoft Office\Office10\Excel.exe "+cPathExcel+pArquivo )
Endif

Return


********************************************************************************************************************
User Function VerGatilho() //rotina criada para validar os gatilhos dos campos - 23/03/12
********************************************************************************************************************
Local lResp:=.T.
Local cCondicao
Local cQuery  := ""
Local _cAlias :=Alias()
Local cRetorno:=""

cQuery:= " SELECT * "
cQuery+= " FROM  "+RetSqlName('SZA')+" SZA "
cQuery+= " WHERE SZA.D_E_L_E_T_<>'*' AND SZA.ZA_FILIAL = '"+xFilial('SZA')+"' "
cQuery+= " AND ZA_USUARIO = '"+Alltrim(cUserName)+"' "
cQuery+= " AND ZA_PROCEDU = '"+AllTrim(FunName())+"' "
cQuery+= " AND ZA_MODULO = '"+AllTrim(ProcName())+"' "
cQuery+= " AND ZA_CONDICA = '"+AllTrim(SX7->X7_CDOMIN)+"' "

TcQuery cQuery NEW ALIAS TMP

TMP->( DbGotop() )

If TMP->( Eof() )
	If SubStr(SX7->X7_CDOMIN,3,1) == '_'
		cRetorno:= &("S"+SubStr(SX7->X7_CDOMIN,1,2)+"->"+SX7->X7_CDOMIN)
	Else
		cRetorno:= &(SubStr(SX7->X7_CDOMIN,1,3)+"->"+SX7->X7_CDOMIN)
	Endif
	Alert(AllTrim(cUserName)+", você não está autorizado a alterar o campo:"+SX7->X7_CDOMIN+"!")
Else
	cRetorno:= &(SX7->X7_CDOMIN)
Endif

TMP->( dbCloseArea() )
dbSelectArea(_cAlias)
Return ( cRetorno )

USER FUNCTION ExistTP(cCodi,cTIpo)
Local aArea := GetArea()
LOCAL lUserRet:= .T.
LOCAL lSD3,lSD1,lSD2

IF GetMv("MV_CHKTP")  // Parametro logico(.T.) para habilitar validacao se item ja foi movimentacao.
	lSD3:= ExistChav("SD3",cCodi, 3, "" )
	lSD1:= ExistChav("SD1",cCodi, 2, "" )
	lSD2:= ExistChav("SD2",cCodi, 1, "" )
	
	IF !lSD3 .OR. !lSD1 .OR. !lSD2
		MsgBox("Ja existe movimentacao para este codigo com este TIPO de material. Tipo nao pode ser alterado !" )
		lUserRet:=.F.
	Endif
ENDIF
RestArea(aArea)
RETURN lUserRet


