#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APVT100.CH'


/*
  DescriÃ§Ã£o: Receber e Enviar Material Solicitados pelo Setores
  Uso:  Modulo ACD para fazer transferencias atraves de requisiÃ§Ãµes
  Desenvolvedor: Ricky Moraes
  Data: 12/03/2020
*/
******************************************************************************************************************************************************
User Function AOCBXARMZ()
	******************************************************************************************************************************************************
	Local nOpc

	VTCLear()
	@ 0,0 VTSay PadR('Selecione Tipo Doc.:' , VTMaxCol())
	nOpc:=VTaChoice(1,0,3,VTMaxCol(),{'Receber  - 004','Pagar    - 501','Consumo  - 502','Tr.Sld Op - 004/501'})
	VtClearBuffer()
	If nOpc == 1
		AOCREC("D","004")//Receber
	ElseIf nOpc == 2
		AOCREC("R","501")  //Pagar
	ElseIf nOpc == 3
		AOCREC("C","502") //Consumir
	ElseIf nOpc == 4
		AOCTRSLD("T","004","501")

	EndIf

Return NIL


	******************************************************************************************************************************************************
Static Function AOCTRSLD(_cCab,_cTm1,_cTm2)
	******************************************************************************************************************************************************
	Local nAux,_cAviso:=0
	Private cDoc:=space(6)
	Private cNop:=Space(12)
	Private cTm:=_cTm1
	Private cTm2:=_cTm2
	Private aItens:={}
	Private lMult:=.T.
	Private cLocal :='11'
	Private cLocalFim :='20'
	Private nQtde:=0
	Private cEnd,cEndF:=Space(15)
	Private cCabecalho:="Transf.Sld OP "
	Private cObs:="TOP-"
	PRIVATE lRastro:=.F.
	Private cCC :=space(9)

	aCab :={"Item","Codigo","UM","Descricao","Saldo","Qtd.Orig","Atendida","Solicitante","Posicao - Qtd","|"}
	aSize   := {3,15,3,25,9,9,9,10,25,1}
	nPos := 1

	DLVTCabec(cCabecalho + "TM-" + cTm + 'e'+cTm2,.F.,.F.,.T.)
	@ 01, 00 VTSay PadR('Doc.  :', VTMaxCol())
	@ 02, 00 VTSay PadR('Num.OP:', VTMaxCol())
	@ 01, 08 VTGet cDoc  Pict '@!' VALID iif(fValDoc(cDoc,'D')>0,.T.,.F.) .and. !Empty(cDoc)
	@ 02, 08 VTGet cNop  Pict '@!' VALID !Empty(cNop) .and. sfValOP(cNop)

	VTRead

	While lMult

		If Len(aItens) == 0 .OR. Empty(aItens)
			DLVTAviso('SIGAWMS - AVISO','Documento Vazio !')
			lMult :=.F.

		Else
			nPos := VTaBrowse(2,0,,,aCab,aItens,aSize,'u_uBrowsectrl',1)

			If nPos==0
				lMult:=.F.
			elseIF nPos>0
				IF VTLastkey() != 27
					IF VTYesNo("Tranferir Devolucao p/OP ?","SIGAWMS")
						nAux:=0
						_cAviso:=""
						DLVTAviso('SIGAWMS - AVISO', 'Processando Devolucao..')
						cEnd:="TRANSITO"
						FOR nAux:=1 TO LEN(aItens)
							IF sfSaldoSBF("20",cEndF,aItens[nAux,1],aItens[nAux,5])
								sfBxSCP(cDoc,aItens[nAux,1],aItens[nAux,5],cTM,.F.,cObs,nAux)
							ENDIF
						NEXT
						DLVTAviso('SIGAWMS - AVISO', 'Realizando Pagamento..')
						FOR nAux:=1 TO LEN(aItens)
							IF sfConsSD4(cNOp,aItens[nAux,1],aItens[nAux,5],cEnd,cEndF)=0
								_cAviso+="Produto :" + aItens[nAux,1] + ' | ' + Transform(aItens[nAux,5], "@R 999999.99" )
							ENDIF
						NEXT
					Endif
				Endif
			ENDIF
		EndIF

	ENDDO

Return


	******************************************************************************************************************************************************
Static Function sfValOP(_cOP)
	******************************************************************************************************************************************************
	Local lRet:=.F.

	dbselectarea("SC2")
	dbsetorder(1)
	dbseek(xfilial("SC2")+alltrim(_cOP))
	if !SC2->(eof())
		IF len(alltrim(DTOS(SC2->C2_DATRF)))>0
			DLVTAviso('SIGAWMS - AVISO',"Ordem de Produção Encerrada !!! Tente novamente.")
			cNOP:=SPACE(12)
		ELSE
			lRet:=.T.
			cEndF:=C2_XEND
			cNOP:=C2_NUM+C2_ITEM+C2_SEQUEN
		ENDIF
	Else
		DLVTAviso('SIGAWMS - AVISO',"Ordem de Produção Invalida !!! Tente novamente."+_cOP)
		cNOP:=SPACE(12)
		cEndF:=Space(15)
	Endif

return(lRet)



	******************************************************************************************************************************************************
Static Function AOCREC(_cCab,_cTm)
	******************************************************************************************************************************************************

	Private cDoc:=space(6)
	Private cTm:=_cTm //'004'
	Private aItens:={}
	Private lMult:=.T.
	Private cLocal :='11'
	Private cLocalFim :='20'
	Private nQtde:=0
	Private cEnd,cEndF:=Space(15)
	Private cCabecalho:=IIF(_cCab=="D","Dev.p/ALMOX ",IIF(_cCab=="R","Pag.P/Processo ","Baixa c/ CC. "))
	Private cObs:=IIF(_cCab=="D","DEV-",IIF(_cCab=="R","PAG-","CONS-"))
	PRIVATE lRastro:=.F.
	Private cCC :=space(9)


	aCab :={"Item","Codigo","UM","Descricao","Saldo","Qtd.Orig","Atendida","Solicitante","Posicao - Qtd","|"}
	aSize   := {3,15,3,25,9,9,9,10,25,1}
	nPos := 1


	DLVTCabec(cCabecalho + "TM-" + cTm,.F.,.F.,.T.)
	@ 01, 00 VTSay PadR('Doc.:', VTMaxCol())
	@ 01, 08 VTGet cDoc  Pict '@!' VALID iif(fValDoc(cDoc,'D')>0,.T.,.F.) .and. !Empty(cDoc)

	VTRead
	While lMult

		If Len(aItens) == 0 .OR. Empty(aItens)
			DLVTAviso('SIGAWMS - AVISO','Documento Vazio !')
			lMult :=.F.

		Else
			nPos := VTaBrowse(2,0,,,aCab,aItens,aSize,'u_uBrowsectrl',1)

			If nPos==0
				lMult:=.F.
			elseIF nPos>0
	      /* Fazer pagamento apartir da consulta*/  
				//aItens
				DLVTAviso('SIGAWMS - SALDOS - ' + cLocal ,' '+aItens[nPos,9])
				IF VAL(cTM)<500
					DLVTAviso('SIGAWMS - SALDOS - ' + cLocalFim ,' '+aItens[nPos,17])
				EndIf

				nQtde:=aItens[nPos,5]
				cEnd  := Space(15)
				cEndF:=ALLTRIM(aItens[nPos,11])
				lRastro :=IIF(POSICIONE("SB1",1,XFILIAL("SB1")+ aItens[nPos,2],"B1_LOCALIZ")=='S',.T.,.F.)
				cCC:=ALLTRIM(aItens[nPos,12])
				IF POSICIONE("SB1",1,XFILIAL("SB1")+ aItens[nPos,2],"B1_TIPO")=='MC'
					cLocal:='36'
				ELSE
					cLocal:='11'
				ENDIF
				VTCLear()
				VtClearBuffer()

				DLVTCabec( IF(_cCab=="D","Receber/Transf. TM-",IIF(_cCab=="R","Pag/Transf.Req. TM-","Consumir p/CC TM-")) + cTM,.F.,.F.,.T.)
				@ 01, 00 VTSay PadR('Local.:', VTMaxCol())
				@ 02, 00 VTSay PadR('Prod..:' , VTMaxCol())
				@ 03, 00 VTSay PadR('Qtde..:' , VTMaxCol())
				@ 04, 00 VTSay PadR('End...:' , VTMaxCol())

				@ 01, 08 VTSay cLocal    Pict '@!'
				@ 02, 08 VTSay aItens[nPos,2] Pict '@!'
				@ 03, 08 VTGet nQtde  Pict '@R 999999.99999' VALID nQtde>0

				IF lRastro
					@ 04, 08 VTGet cEnd  Pict '@!' VALID sfValEnd(cLocal,cEnd).and. !Empty(cEnd)
					IF EMPTY(cEndF) .and. _cCab<>"C"
						cEndF:=Space(15)
						@ 06, 00 VTSay PadR("End. " + IF(_cCab=="D","Origem ","Destino ") +" não Informado !" , VTMaxCol())
						@ 07, 00 VTSay PadR(IF(_cCab=="D","End.Ori: ","End.Dest:")  , VTMaxCol())
						@ 07, 09 VTGet cEndF  Pict '@!' VALID sfValEnd(IIF(VAL(cTM)<500,"20",cLocal),cEndf).and. !Empty(cEndf) .and. SaldSBF(IIF(VAL(cTM)<500,"20",cLocal),cEndf,aItens[nPos,2])

					ENDIF
				ENDIF
				IF  EMPTY(ALLTRIM(aItens[nPos,12])) .AND. cTM<>"501"
					cCC:=space(9)
					@ 08, 00 VTSay PadR("CC. Desti.:"  , VTMaxCol())
					@ 08, 12 VTGet cCC  Pict '@!' VALID !Empty(cCC)  .and. sfValidCC(cCC)
				ENDIF


				VTRead
				IF VTLastkey() != 27
					If POSICIONE("SB1",1,XFILIAL("SB1")+ aItens[nPos,2],"B1_APROPRI")=='D'
						IF _cCab=="C"
							sfBxSCP(cDoc,aItens[nPos,1],nQtde,cTM,.T.,cObs,nPos,_cCab)
						ELSE
							DLVTAviso('SIGAWMS - AVISO','Produto de Apropriação direta,  não é possivel fazer por essa rotina !')
						ENDIF

					else
						sfBxSCP(cDoc,aItens[nPos,1],nQtde,cTM,.T.,cObs,nPos)
					ENDIF
				Endif

			Endif

		EndIF




	EndDo

Return

	******************************************************************************************************************************************************
Static Function fValDoc(_cDoc,_cTipo)
	******************************************************************************************************************************************************
	Local cQuery    := ''
	Local cAliasQry := GetNextAlias()
	Local nRecCount:=0

	cQuery	:= "  SELECT * "
	cQuery	+= "  FROM " +RetSqlName('SCP') + " SCP "
	cQuery	+= "  WHERE CP_FILIAL  = '"+xFilial("SCP")+"' "
	cQuery	+= "  AND CP_NUM = '"+_cDoc+"' "
	cQuery	+= "  AND SCP.D_E_L_E_T_ = ' ' AND CP_QUJE < CP_QUANT  AND CP_STATUS<>'E'"
	cQuery	+= "  ORDER BY R_E_C_N_O_"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .T., .F.)

	//	DLVTAviso('',cQuery)

	dbSelectArea(cAliasQry)
	//Conta total e registros
	Count To nRecCount

	aItens:={}
	dbGotop()
	do While !(cAliasQry)->(EoF())

		IF POSICIONE("SB1",1,XFILIAL("SB1")+ (cAliasQry)->CP_PRODUTO,"B1_TIPO")=='MC'
			cLocal:='36'
		ELSE
			cLocal:='11'
		ENDIF

		aadd(aItens,{		(cAliasQry)->CP_ITEM,;
			(cAliasQry)->CP_PRODUTO,;
			(cAliasQry)->CP_UM,;
			(cAliasQry)->CP_DESCRI,;
			((cAliasQry)->CP_QUANT -(cAliasQry)->CP_QUJE),;
			(cAliasQry)->CP_QUANT,;
			(cAliasQry)->CP_QUJE,;
			(cAliasQry)->CP_SOLICIT,;
			sfLocEnd((cAliasQry)->CP_PRODUTO,cLocal),;
			"|",;
			(cAliasQry)->CP_XLOCALI,;
			(cAliasQry)->CP_CC,;
			(cAliasQry)->CP_CONTA,;
			(cAliasQry)->CP_NUM,;
			(cAliasQry)->CP_EMISSAO,;
			(cAliasQry)->CP_OP,;
			sfLocEnd((cAliasQry)->CP_PRODUTO,cLocalFim),;
			(cAliasQry)->CP_STATUS})
		(cAliasQry)->(DbSkip())
	Enddo

	(cAliasQry)->(dbCloseArea())


return(nRecCount)


Return


	******************************************************************************************************************************************************
Static Function sfLocEnd(_cProd,_cAlmox)
	******************************************************************************************************************************************************
/*retorna lista de enderecos no armz informado */
	Local ListEnd:=space(60)
	Local cQuery := ''
	Local cAliasQry3 := GetNextAlias()
	Local nRecCount

	cQuery	:= "  SELECT ISNULL(BF_LOCALIZ,'VAZIO') BF_LOCALIZ, ISNULL(BF_QUANT,0) BF_QUANT "
	cQuery	+= "  FROM " +RetSqlName('SBF') + " SBF "
	cQuery	+= "  WHERE BF_FILIAL  = '"+xFilial("SBF")+"' "
	cQuery	+= "  AND BF_LOCAL   = '"+_cAlmox+"' "
	cQuery	+= "  AND BF_QUANT >0 AND BF_PRODUTO ='" + _cProd + "' "
	cQuery	+= "  AND SBF.D_E_L_E_T_ = ' ' "
	cQuery	+= "  ORDER BY R_E_C_N_O_"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry3, .T., .F.)


	ListEnd:=''
	dbSelectArea(cAliasQry3)
	//Conta total e registros
	Count To nRecCount

	dbGotop()

	While !(cAliasQry3)->(EoF()) //Enquando nÃ£o for fim de arquivo
		ListEnd += PADR(ALLTRIM((cAliasQry3)->BF_LOCALIZ),10," ") + " -" + STR((cAliasQry3)->BF_QUANT,9,2) + IIF(nRecCount>1,"| +","| ")  //RESULTADO DA CONSULTA
		(cAliasQry3)->(dbSkip()) //Anda 1 registro pra frente
		nRecCount:=nRecCount-1
	EndDo

	(cAliasQry3)->(dbCloseArea()) //Fecha a Ã¡rea de trabalho

	IF ListEnd==''
		ListEnd:='SEM SALDO NO ESTOQUE'
	EndIf

Return(ListEnd)


	******************************************************************************************************************************************************
Static Function sfBxSCP(_cDocReq,_cItem,_nQtd,_cTM,_lAviso,_cObs,_nPos,_cCab)
	******************************************************************************************************************************************************
	Local aArea2 := GetArea()
	Local aCab  :={}
	Local _aItem := {}
	LOCAL _atotitem := {}

	Local cAlmox,cConta,cGrupo,_cOP
	Local cTitulo:= _cObs
	Local cNumSCP := _cDocReq //"000001" // No.da Requisicao
	LOCAL cItem := _cItem
	Local cD3Doc:=''
//Local nModAux := nModulo  
	Local MsgRetWMS := ""
	LOCAL nEntregue:=0

	Private lMsErroAuto := .f. //necessario a criacao



//nModulo := 4

	Begin Transaction

		IF (!GetMv("MV_ULMES") > dDataBase)

			cD3Doc:=GetSXENum("SD3", "D3_DOC")

			IF POSICIONE("SB1",1,XFILIAL("SB1")+  aItens[_nPos,2],"B1_TIPO")=='MC'
				cAlmox:='36'
			ELSE
				cAlmox:="11"
			ENDIF

			//cAlmox:="11" POSICIONE//IIF(VAL(_cTM)<500,"20","11")
			cConta:=aItens[_nPos,13]
			//cCC:=aItens[nPos,12]
			cUm:=	aItens[_nPos,3]
			cGrupo := POSICIONE("SB1",1,XFILIAL("SB1")+ aItens[_nPos,2],"B1_GRUPO")
			_cOP := IIF( !EMPTY (ALLTRIM(aItens[_nPos,16])),"OP :"+ ALLTRIM(aItens[_nPos,16]),"")



			aCab := {{"D3_DOC"     ,cD3Doc      ,NIL}, ;
				{"D3_TM"      ,_cTM   ,NIL}, ;
				{"D3_CC"      ,cCC    ,NIL}   , ;
				{"D3_EMISSAO" ,dDataBase ,Nil} }

			_aItem:={{"D3_COD"    ,aItens[_nPos,2]   ,NIL},;
				{"D3_UM"     ,cUm           ,NIL},;
				{"D3_QUANT"  ,nQtde   ,NIL},;
				{"D3_LOCAL"  ,cAlmox        ,NIL},;
				{"D3_LOTECTL" ,"",NIL},;
				{"D3_CONTA"  ,cConta        ,NIL},;
				{"D3_GRUPO"  ,cGrupo        ,NIL},;
				{"D3_LOCALIZ",IIF(VAL(cTM)<500,cEndF,cEnd)    ,NIL},;
				{"D3_XENDER",IIF(VAL(cTM)>500,cEndF,cEnd)	,NIL},;
				{"D3_OBSERVA",cTitulo+"Doc:"+cNumSCP + " " + _cOP,NIL},;
				{"D3_EMISSAO",dDataBase                          ,nil}}

			aadd(_atotitem,_aitem)


			MSExecAuto({|x,y,z|MATA241(x,y,z)},aCab,_atotitem,3)  //Usado para Gerar movimentos Intermos.

			//atualizar tabela SCP
			dbSelectArea("SCP")
			dbSetOrder(1)
			If SCP->(dbSeek(xFilial("SCP")+cNumSCP+cItem))
				nEntregue:=SCP->CP_QUJE + nQtde
				RecLock("SCP",.F.)
				SCP->CP_XDOCSD3:= cD3Doc
				SCP->CP_QUJE   := SCP->CP_QUJE + nQtde
				SCP->CP_STATUS := IIF( nEntregue < SCP->CP_QUANT, "I","E")
				SCP->CP_PREREQU:= IIF( nEntregue < SCP->CP_QUANT, "","S")
				SCP->CP_OBS    := IIF( nEntregue < SCP->CP_QUANT, "BX Parc:","BX:") +Transform(dDatabase,"99/99/99")+"-"+TIME()+"-"+Alltrim(CUSERNAME)// Utilizado para da data do pagto da OP pelo almoxarifado
				SCP->(MsUnLock())
				//DLVTAviso('SIGAWMS-AVISO',"SCP-ATUALIZADO")
			ENDIF



// VALIDAÇÃO DE ERRO NA ROTINA
			If (!lMsErroAuto) // OPERAÇÃO FOI EXECUTADA COM SUCESSO
				DLVTAviso('SIGAWMS-SUCESSO',"Material Baixado")
				ConfirmSX8()
				sfEndProARMZ(cD3Doc,aItens[_nPos,2],IIF(VAL(cTM)<500,cAlmox,"20"),IIF(VAL(cTM)>500,cEndF,cEnd))
				IF _cCab<>"T"
					fValDoc(cNumSCP,'D') // ATUALIZAR LISTA REQUISICAO quando nao for transf
				END

			Else // OPERAÇÃO EXECUTADA COM ERRO
				If (!IsBlind()) // COM INTERFACE GRÁFICA
					MsgRetWMS := MostraErro()
				Else // EM ESTADO DE JOB
					cError := MostraErro("/LOGS", "errorACD.log") // ARMAZENA A MENSAGEM DE ERRO
					DLVTAviso('SIGAWMS-ERRO', cError)
					RollBackSX8()
					DisarmTransaction()
				EndIf
			EndIf




		ENDIF

//nModulo := nModAux
	END TRANSACTION

	RESTAREA(aArea2)

Return Nil

	******************************************************************************************************************************************************
Static Function sfSaldoSBF(_cLocal,_cEnd,_cProduto,_nBaixa)
	******************************************************************************************************************************************************
	Local lRet:=.T.
	DBSelectArea('SBF')
	DBSetOrder(1)
	IF !(DBSeek(xFilial('SBF') + _cLocal+_cEnd+_cProduto))
		DLVTAviso('SIGAWMS - AVISO', 'O Saldo do Produto '+ _cProduto + ' ' +Alltrim(_cEnd)+' nao existe.!')
		lRet:=.F.
	ELSEIF Sbf->BF_QUANT < _nBaixa
		DLVTAviso('SIGAWMS - AVISO', 'O Saldo do Produto '+ _cProduto +;
			'  é Menor do que o Solicitado :' +Transform(_nBaixa, "@R 999999.99") +' no Endereco: '+ _cEnd)
		lRet:=.F.
	ENDIF
Return(lRet)


	******************************************************************************************************************************************************
Static Function sfValEnd(_cLocal,_cEnd)
	******************************************************************************************************************************************************
	Local lRet:=.T.
	DBSelectArea('SBE')
	DBSetOrder(1)
	IF !DBSeek(xFilial('SBE')+_cLocal+_cEnd)
		DLVTAviso('SIGAWMS - AVISO', 'O endereco '+Alltrim(_cEnd)+' nao existe.!')
		lRet:=.F.
	ENDIF
Return(lRet)

	******************************************************************************************************************************************************
Static Function SaldSBF(Locde,cEndO,_cPro)  //saldo no SBF E SB2
	******************************************************************************************************************************************************
	Local _nSaldo:=0
	Local cAliasSBF:= GetNextAlias()
	Local cAliasSB2:= GetNextAlias()

	IF Posicione("SB1",1,xfilial("SB1")+aItens[nPos,1],"B1_LOCALIZ")=="S"
		BeginSql Alias cAliasSBF
	  SELECT isnull(SUM(BF_QUANT),0) AS BF_QUANT FROM %Table:SBF% WHERE BF_FILIAL='01' 
	  AND BF_PRODUTO=%exp:_cPro%  AND BF_LOCAL=%exp:Locde% AND BF_LOCALIZ=%exp:cEndO% 
	  AND D_E_L_E_T_='' 
		EndSql
		dbSelectArea(cAliasSBF)
		dbgotop()
		_nSaldo+=(cAliasSBF)->BF_QUANT
		dbSelectArea(cAliasSBF)
		dbclosearea()
	ELSE
		BeginSql Alias cAliasSB2
	  SELECT isnull(SUM(B2_QATU),0) AS B2_QATU FROM %Table:SB2% WHERE B2_FILIAL='01' 
	  AND B2_COD=%exp:_cPro%  AND B2_LOCAL=%exp:Locde%
	  AND D_E_L_E_T_='' 
		EndSql
		dbSelectArea(cAliasSB2)
		dbgotop()
		_nSaldo+=(cAliasSB2)->B2_QATU
		dbSelectArea(cAliasSB2)
		dbclosearea()

	ENDIF

	IF _nSaldo<nQtde
		DLVTAviso('SIGAWMS - AVISO',"Saldo no Endereço menor que o solicitado! 	Quant. : "+ Transform(nQtde, "@R 999999.99") +" Saldo: "+ Transform(_nSaldo, "@R 999999.99") )
		Return .F.
	ENDIF

Return(.T.)


	******************************************************************************************************************************************************
Static Function sfEndProARMZ(_cD3Doc,_cProd,_cAlmox,_cEnd)
	******************************************************************************************************************************************************
	Local aArea   := GetArea()
	Local cQuery    := ''
	Local cAliasQry := GetNextAlias()
	Local nRecCount:=0
	Local lRet :=.F.
	LOCAL nAux1:=0

	cQuery	:= "  SELECT DA_FILIAL,DA_PRODUTO,DA_LOCAL,DA_NUMSEQ,DA_DOC, "
	cQuery 	+= "  DA_SALDO "
	cQuery	+= "  FROM " +RetSqlName('SDA') + " SDA "
	cQuery	+= "  WHERE SDA.DA_FILIAL  = '"+xFilial("SDA")+"' "
	cQuery	+= "  AND SDA.DA_LOCAL   = '"+_cAlmox+"' "
	cQuery	+= "  AND SDA.DA_PRODUTO   = '"+_cProd+"' "
	cQuery	+= "  AND SDA.DA_DOC   = '"+_cD3Doc+"' "
	cQuery	+= "  AND SDA.DA_SALDO >0  "
	cQuery	+= "  AND SDA.D_E_L_E_T_ = ' ' "
	cQuery	+= "  ORDER BY R_E_C_N_O_"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .T., .F.)

	//	DLVTAviso('',cQuery)

	dbSelectArea(cAliasQry)
	//Conta total e registros
	Count To nRecCount

	aSaldoItens:={}
	dbGotop()
	do While !(cAliasQry)->(EoF())
		aadd(aSaldoItens,{(cAliasQry)->DA_PRODUTO, (cAliasQry)->DA_DOC,(cAliasQry)->DA_SALDO,(cAliasQry)->DA_LOCAL,(cAliasQry)->DA_NUMSEQ})
		(cAliasQry)->(DbSkip())
	Enddo

	(cAliasQry)->(dbCloseArea())

	RestArea(aArea)


	WHILE nAux1 < LEN(aSaldoItens) .AND. Len(aSaldoItens)>0
		nAux1++
		//DA_PRODUTO, DA_LOCAL, DA_NUMSEQ, DA_DOC, SALDO  , destino
		//(_cD3Doc,_cProd,_cAlmox,_cEnd)
		sfMATA265(aSaldoItens[nAux1,1],aSaldoItens[nAux1,4],aSaldoItens[nAux1,5],aSaldoItens[nAux1,2],aSaldoItens[nAux1,3],_cEnd,.T.)

	ENDDO

return(lRet)

	******************************************************************************************************************************************************
Static Function sfMATA265(_cProd,_cLocal,_cSeq,_cDoc,_nQtde,_cEnd,_lAviso) //DA_PRODUTO, DA_LOCAL, DA_NUMSEQ, DA_DOC, SALDO  , destino, aviso
	******************************************************************************************************************************************************
	Local aCabSDA    := {}
	Local aItSDB         := {}
	Local _aItensSDB := {}
	Local nModAux := nModulo
	Local  MsgRetWMS := ""

	Private lMsErroAuto := .F.

	nModulo := 4

	Begin Transaction

//Cabeçalho com a informação do item e NumSeq que sera endereçado.
		aCabSDA := {{"DA_PRODUTO" ,_cProd,Nil},;
			{"DA_NUMSEQ"  ,_cSeq,Nil}}
//Dados do item que será endereçado


		aItSDB := {{"DB_ITEM"	  ,sfItemSDB(_cProd,_cLocal,_cSeq) ,Nil},;
			{"DB_ESTORNO"  ," "	      ,Nil},;
			{"DB_LOCALIZ"  ,_cEnd    ,Nil},;
			{"DB_DATA"	  ,dDataBase    ,Nil},;
			{"DB_QUANT"  ,_nQtde          ,Nil}}
		aadd(_aItensSDB,aitSDB)

//Executa o endereçamento do item
//MATA265( aCabSDA, _aItensSDB, 3)
		MSExecAuto({|X,Y,Z|MATA265(X,Y,Z)},aCabSDA, _aItensSDB, 3)


// VALIDAÇÃO DE ERRO NA ROTINA
		If (!lMsErroAuto) // OPERAÇÃO FOI EXECUTADA COM SUCESSO
			if _lAviso
				DLVTAviso('SIGAWMS','Endereçado com SUCESSO !')
			endif

		Else // OPERAÇÃO EXECUTADA COM ERRO
			If (!IsBlind()) // COM INTERFACE GRÁFICA
				MsgRetWMS := MostraErro()
			Else // EM ESTADO DE JOB
				cError := MostraErro("/LOGS", "errorACD.log") // ARMAZENA A MENSAGEM DE ERRO
				DLVTAviso('SIGAWMS-ERRO', cError)
				DisarmTransaction()
			EndIf
		EndIf



		nModulo := nModAux
	END TRANSACTION

Return


	******************************************************************************************************************************************************
Static Function sfItemSDB(_cProduto1,_cLocal1,_cSeq1)
	******************************************************************************************************************************************************
	Local cQuery2    := ''
	Local cAliasQry2 := GetNextAlias()
	Local cItem	:='0000'

	cQuery2	:= "  SELECT ISNULL(MAX(DB_ITEM),'0000') DB_ITEM "
	cQuery2	+= "  FROM " +RetSqlName('SDB') + " SDB "
	cQuery2	+= "  WHERE DB_FILIAL  = '"+xFilial("SDB")+"' "
	cQuery2	+= "  AND DB_PRODUTO = '"+_cProduto1+"' "
	cQuery2	+= "  AND DB_LOCAL = '"+_cLocal1+"' "
	cQuery2	+= "  AND DB_NUMSEQ='"+_cSeq1+"' "
	cQuery2	+= "  AND SDB.D_E_L_E_T_ = ' ' "
	cQuery2	+= "  "
	cQuery2 := ChangeQuery(cQuery2)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery2),cAliasQry2, .T., .F.)

	//	DLVTAviso('',cQuery)

	dbSelectArea(cAliasQry2)

	cItem:=StrZero(Val((cAliasQry2)->DB_ITEM)+1,4)
	(cAliasQry2)->(dbCloseArea())
Return(cItem)



	******************************************************************************************************************************************************
Static Function sfValidCC(_cCC)
	******************************************************************************************************************************************************
	Local lRet:=.F.
	Local aArea:= GetArea()

	dbSelectArea("CTT")
	CTT->(dbSetOrder(1))		//CTT_FILIAL, CTT_CCUSTO
	If dbSeek( xFilial("CTT") + _cCC )
		lRet:=.T.
	else
		DLVTAviso('SIGAWMS-AVISO','Centro de Custo não Localizado !')
	Endif

	DBCloseArea()

	RESTAREA(aArea)

RETURN(lRet)



	******************************************************************************************************************************************************
Static Function sfBaixaOP501(_cOP,_cCod,_nQtd,_cUM,_cConta,_cGrupo,_cEnd,_cEndF)
	******************************************************************************************************************************************************
	Local aArea2 := GetArea()
	Local aCab  :={}
	Local _aItem := {}
	LOCAL _atotitem := {}
	LOCAL lShowMSM:=.T.
	Local _cTM:="501"
	Local _cAlmox,_cDoc
	Local _cTitulo:= "PAGTO-"



	Private lAutoErrNoFile := .F.
	Private lMsHelpAuto := .t. // se .t. direciona as mensagens de help
	Private lMsErroAuto := .f. //necessario a criacao


	IF (!GetMv("MV_ULMES") > dDataBase)

		_cAlmox:="11"
		_cDoc:=DocSd3()

		aCab := {{"D3_DOC"     ,_cDoc      ,NIL}, ;
			{"D3_TM"      ,_cTM    ,NIL}, ;
			{"D3_EMISSAO" ,dDataBase ,Nil} }

		_aItem:={{"D3_COD"    ,_cCod   ,NIL},;
			{"D3_UM"     ,_cUm           ,NIL},;
			{"D3_QUANT"  ,_nQtd   ,NIL},;
			{"D3_LOCAL"  ,_cAlmox        ,NIL},;
			{"D3_LOTECTL" ,"",NIL},;
			{"D3_CONTA"  ,_cConta        ,NIL},;
			{"D3_GRUPO"  ,_cGrupo        ,NIL},;
			{"D3_LOCALIZ",_cEnd    ,NIL},;
			{"D3_XENDER",_cEndF	,NIL},;
			{"D3_OBSERVA","RQ/OP "+_cOP+" Hr: "+left(time(),5),NIL},;
			{"D3_EMISSAO",dDataBase                          ,nil}}

		aadd(_atotitem,_aitem)

		BeginTran()
		MSExecAuto({|x,y,z|MATA241(x,y,z)},aCab,_atotitem,3)  //Usado para Gerar movimentos Intermos.
	EndTran()

	MsUnlockAll()

	//verificar se existe saldo a endereçar
	sfSDASD3(_cDoc,dDataBase)

ELSE
	DLVTAviso('SIGAWMS - ERRO',"Não é permitido "+cTitulo+" Ordem Producao com data menor que a do fechamento!")

Endif

RestArea(aArea2)

Return


******************************************************************************************************************************************************
Static Function DocSd3()
	******************************************************************************************************************************************************
	Local nDoc:=1
	Local cDocs
	cAliasSD3:= GetNextAlias()
	BeginSql Alias cAliasSD3
  SELECT isnull(MAX(D3_DOC),'000000000') AS D3_DOC FROM %Table:SD3% WHERE D3_FILIAL='01' 
  AND LEFT(D3_DOC,6)=%exp:left(alltrim(cNop),6)% 
  AND D_E_L_E_T_='' AND D3_CF IN ('RE3','RE4') AND LEFT(D3_OBSERVA,5)='RQ/OP' AND D3_ESTORNO=''
	EndSql
	dbSelectArea(cAliasSD3)
	dbgotop()
	nDoc+=VAL(SUBSTR((cAliasSD3)->D3_DOC,7,3))
	dbSelectArea(cAliasSD3)
	dbclosearea()
	cDocs:=LEFT(alltrim(cNop),6)+STRZERO(nDoc,3)
Return(cDocs)


	******************************************************************************************************************************************************
Static Function sfSDASD3(_cDoc,_dDataBase1)
	******************************************************************************************************************************************************
	Local cQuery    := ''
	Local cAliasQry := GetNextAlias()
	Local nRecCount:=0

	cQuery	:= "  SELECT "
	cQuery	+= "	DA_PRODUTO,DA_LOCAL,DA_NUMSEQ,DA_DOC,DA_SALDO,D3_XENDER"
	cQuery	+= "  FROM " +RetSqlName('SDA') + " SDA"
	cQuery	+= "  INNER JOIN "+ RetSqlName('SD3')+ " SD3 "
	cQuery	+= " 	ON  SDA.D_E_L_E_T_=''	"
	cQuery	+= "  	AND SD3.D_E_L_E_T_=''	"
	cQuery	+= "  	AND D3_NUMSEQ=DA_NUMSEQ	"
	cQuery	+= "  	AND D3_COD=DA_PRODUTO	"
	cQuery	+= "  	AND D3_QUANT=DA_QTDORI	"
	cQuery	+= "  	AND D3_FILIAL=DA_FILIAL	"
	cQuery	+= "  	AND D3_ESTORNO=''	"
	cQuery	+= "  	AND DA_SALDO>0		"
	cQuery	+= "  	AND DA_FILIAL='"+xFilial("SDA")+"' "
	cQuery	+= "  	AND D3_DOC='"+ _cDoc +"' "
	cQuery	+= "  	AND D3_EMISSAO='" + DTOS(_dDataBase1) +"' "
	cQuery	+= "  	AND DA_ORIGEM='SD3'	"
	cQuery	+= "  	AND D3_XENDER<>'' "
	cQuery	+= "  "
	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .T., .F.)

	//	DLVTAviso('',cQuery)

	dbSelectArea(cAliasQry)
	//Conta total e registros
	Count To nRecCount
	dbGotop()
	If nRecCount>0

		While !(cAliasQry)->(EoF()) //Enquando não for fim de arquivo
			//(_cProd,_cLocal,_cSeq,_cDoc,_nQtde,_cEnd,_lAviso)
			sfMATA265(	(cAliasQry)->DA_PRODUTO,;
				(cAliasQry)->DA_LOCAL,;
				(cAliasQry)->DA_NUMSEQ,;
				(cAliasQry)->DA_DOC,;
				(cAliasQry)->DA_SALDO,;
				(cAliasQry)->D3_XENDER,.F. )  //executar enderecamento
			(cAliasQry)->(DbSkip())

		EndDo

	EndIF


	(cAliasQry)->(dbCloseArea())

Return


	******************************************************************************************************************************************************
Static Function sfConsSD4(_cOp,_cProduto,_nQtd,_cEnd,_cEndF)
	******************************************************************************************************************************************************
	Local cQuery := ''
	Local cAliasQry := GetNextAlias()
	Local nRecCount:=0
	Local cPosicao:=''


	cQuery	:= "	SELECT   			 			 			"
	cQuery	+= "	D4_COD,B1_TIPO,D4_QTDEORI 	 			"
	cQuery	+= "	,ISNULL(SUM(D3_QUANT),0) BAIXADAS	"
	cQuery	+= "	,B1_XDESCNF,D4_OP		  					"
	cQuery	+= "	,B1_APROPRI,D4_LOCAL						"
	cQuery	+= "	,B1_CONTA,B1_GRUPO,B1_UM				"
	cQuery	+= "	FROM SD4010 SD4  		 					"
	cQuery	+= "	INNER JOIN SB1010 SB1 ON D4_COD=B1_COD	"
	cQuery	+= "	 AND B1_TIPO <> 'MO'			  			"
	cQuery	+= "	 AND B1_XKANBAN<>'S'						"
	cQuery	+= "	 AND B1_FANTASM<>'S'	 					"
	cQuery	+= "	 AND SD4.D_E_L_E_T_=' '	 				"
	cQuery	+= "	 AND SB1.D_E_L_E_T_=' '					"
	cQuery	+= "	 AND D4_FILIAL='"+xFilial("SD4")+"' "
	cQuery	+= "	 AND B1_APROPRI='I'						"
	cQuery	+= "	 AND D4_OP='"+ _cOP +"'	 				"
	cQuery	+= "	 AND D4_PRODUTO='"+ _cProduto +"'	 				"
	cQuery	+= "	LEFT JOIN SD3010 SD3 ON D3_COD=D4_COD	"
	cQuery	+= "	 AND SD3.D_E_L_E_T_=' '		 			"
	cQuery	+= "	 AND D3_FILIAL=D4_FILIAL	 			"
	cQuery	+= "	 AND D3_CF IN ('RE3','RE4')  			"
	cQuery	+= "	 AND D3_ESTORNO<>'S'		  				"
	cQuery	+= "	 AND SUBSTRING(D3_OBSERVA,7,12) =D4_OP	"
	cQuery	+= " "
	cQuery	+= " GROUP BY D4_DATA,D4_COD,B1_TIPO		"
	cQuery	+= " ,B1_APROPRI,B1_XDESCNF,D4_OP	  		"
	cQuery	+= " ,SUBSTRING(D3_OBSERVA,7,12)	 			"
	cQuery	+= " ,D4_QTDEORI,D4_LOCAL						"
	cQuery	+= " ,B1_CONTA,B1_GRUPO,B1_UM			 		"
	cQuery	+= " HAVING D4_QTDEORI> ISNULL(SUM(D3_QUANT),0)"




	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .T., .F.)

	dbSelectArea(cAliasQry)
	//Conta total e registros
	Count To nRecCount
	dbGotop()
	//RESULTADO DA CONSULTA
	(_cOP,_cCod,_nQtd,_cUM,_cConta,_cGrupo,_cEnd,_cEndF)
	IF nRecCount>0
		sfBaixaOP501((cAliasQry)->D4_OP,;
			(cAliasQry)->D4_COD,;
			_nQtd,;
			(cAliasQry)->B1_UM,;
			(cAliasQry)->B1_CONTA,;
			(cAliasQry)->B1_GRUPO,;
			_cEnd,;
			_cEndF)
	ENDIF

	(cAliasQry)->(dbCloseArea()) //Fecha a área de trabalho



return(nRecCount)





