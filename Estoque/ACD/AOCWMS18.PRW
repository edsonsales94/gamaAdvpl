#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'APVT100.CH'

/*
Descrição:  Movimentos internos Mod2 em ACD
Uso:  Modulo ACD para baixa de materia prima Kanbam RE3
Desenvolvedor: Claudio Almeida
Data: 22/09/2015
03/05/16 correcao de Devolucao que nao aceitava minuscula no DEV
*/

//Movimentos internos
user function AOCWMS18()
	Private  cMat:=SPACE(6)
	Private  cEndF:=SPACE(15)
	Private  cCod:= SPACE(15)
	Private  nQtd:= 0
	Private  cEndO:=SPACE(15)
	Private  cLote:=SPACE(15)
	Private  cD3_TM:="501"
	Private  cCC:=""
	Private  acab := {"Cod","Qtde","Endereco","Lote"}
	Private  aSize:= {15,08,09,15}
	Private nPos:=1
	Private nEmp:=0
	Private aItens:={{"",0,"",""}}
	Private cAlmox:=GETMV("MV_LOCPROC")
	Private cDoc:=space(6)
	Private cObserv
	VTClearBuffer()
	DLVTCabec("KAMB/502/DEVOL: " ,.F.,.F.,.T.)
	@ 01, 00 VTSay PadR('Doc.....:' , VTMaxCol())
	@ 01, 13 VTGet cDoc Pict '@!' VALID CkNumSCP(cDoc,"",.F.,0)
	@ 02, 00 VTSay PadR('End.Dest:' , VTMaxCol())
	@ 02, 13 VTGet cEndF Pict '@!'   VALID (ValEnd("20",cEndF ))
	VTREAD
	cObserv:=IIF(cD3_TM=="502","BX 502 :",iif(cD3_TM=="501",iif(left(cDoc,1)=="P","SCP: "+ALLTRIM(cDoc),"BXA KBAM "),"Dev.:"))
	cObserv:=iif(left(cDoc,1)=="R","RET: "+ALLTRIM(cDoc),cObserv)
	While .T.
		cCod:= SPACE(15)
		nQtd:= 0
		nEmp:=0
		if val(cD3_TM)>=500
			cEndO:=SPACE(15)
		endif
		cLote:=SPACE(15)
		DLVTCabec("Baixa TM-"+cD3_TM ,.F.,.F.,.T.)
		@ 01, 00 VTSay PadR('CODIGO  :' , VTMaxCol())
		@ 02, 00 VTSay PadR('ENDERECO:' , VTMaxCol())
		@ 03, 00 VTSay PadR('QTDE....:' , VTMaxCol())
		@ 01, 13 VTGet cCod   Pict '@!' VALID (AtuCod() .and. CkNumSCP(cDoc,cCod,.F.,0))
		@ 02, 13 VTGet cEndO  Pict '@!' VALID (ValEnd("11",cEndO ))
		@ 03, 13 VTGet nQtd   Pict '@R 999999.99' VALID ( IIF(CkNumSCP(cDoc,cCod,.F.,nQtd), ADLISTA() ,.F. ) )
		//@ 04, 00 VTSay PadR('LOTE....:' , VTMaxCol())
		//@ 04, 13 VTGet cLote  Pict '@!'  VALID  IIF(POSICIONE("SB1",1,XFILIAL("SB1")+cCod ,"B1_RASTRO")=="L" .AND. EMPTY(cLote) , .F.,.T.)

		VTREAD
		If (VTLastKey()==27)
			Exit
		EndIf

	Enddo
	cObserv:=IIF(cD3_TM=="502","BX 502 :",iif(cD3_TM=="501",iif(left(cDoc,1)=="P","SCP: "+ALLTRIM(cDoc),"BXA KBAM"),"Dev.:"))
	cObserv:=iif(left(cDoc,1)=="R","RET: "+ALLTRIM(cDoc),cObserv)
	DLVTCabec("Itens da Baixa : " ,.F.,.F.,.T.)
	nPos:=VTaBrowse(1,0,VTMaxRow(),VTMaxCol(),aCab,aItens,aSize,'U_KMBctrl2',nPos)
	if nPos==0
		Baixa3MMb()
	endif
return

User Function KMBctrl2(modo,nElem,nElemW)
	If modo == 1
		VtAlert('Top')
	Elseif Modo == 2
		VtAlert('Bottom')
	Else
		If VTLastkey() == 27
			DLVTAviso('Saindo sem atualizar os dados')
			VTBeep(3)
			return 1
		elseIf VTLastkey() == 13
			VtBeep(1)
			return 0
		Endif
	EndIf
Return 2

Static Function ValEnd(_cLocal,_cEnd)
	Local lRet:=.T.
	DBSelectArea('SBE')
	DBSetOrder(1)
	IF !DBSeek(xFilial('SBE')+_cLocal+_cEnd)
		DLVTAviso('SIGAWMS', 'O endereco '+Alltrim(_cEnd)+' nao existe.!')
		Return (.F.)
	ENDIF
Return(lRet)

Static Function AtuCod()
	Local cDesc,aRet,lRej
	DBSELECTAREA("SB1")
	DBSETORDER(1)
	DBSEEK(xfilial("SB1")+cCod)
	IF EOF()
		DLVTAviso('SIGAWMS',"Codigo invalido!!!")
		Return(.f.)
	endif
	IF cD3_TM=="502"  .or. left(cDoc,1)$"P/D/R"   //para atender pagamento de scrap e retrabalho
		Return(.t.)
	ENDIF
	if ALLTRIM(SB1->B1_XKANBAN)<>'S' .OR. SB1->B1_MSBLQL=="1"  .or. SB1->B1_APROPRI<>"I"
		IF SB1->B1_MSBLQL=="1"
			DLVTAviso('SIGAWMS',"Item bloqueado ou tipo de apropriaçao invalida , Verifique com a engenharia! Tente Novamente")
		ELSE
			DLVTAviso('SIGAWMS',"Somente itens KANBAN sao aceitos nesta rotina! Tente Novamente")
		ENDIF
		nEmp:=0
		Return(.f.)
	Endif
Return(.t.)

Static Function ADLISTA()
	Local cDesc,cUnd,nItem,nQemp,nSld,x
	nSld:=SaldSBF()   //VERIFICA O SALDO DO ENDEREÇO
	nQemp:=nQtd
	nQEnd:=nQtd
	//somar as quantidades dos itens iguas
	For x:=1 to len(aItens)
		if alltrim(cCod)==alltrim(aItens[x,1])
			nQemp+=aItens[x,2]
		endif
		if alltrim(cCod)==alltrim(aItens[x,1]) .and. alltrim(cEndO)==alltrim(aItens[x,3]) .and. alltrim(cLote)==alltrim(aItens[x,4])
			nQEnd+=aItens[x,2]
		endif
	Next
	IF nQEnd>nSld
		DLVTAviso('SIGAWMS',"Saldo no Endereço menor que o solicitado! Saldo: "+alltrim(str(nSld,12,5)) )
		nQtd:=0
		Return .F.
	ENDIF
	If nQtd==0
		Return .F.
	Endif
	if len(aItens)==1 .and. aItens[1,2]==0
		aItens[1,1]:=cCod ; aItens[1,2]:=nQtd  ; aItens[1,3]:=cEndO ; aItens[1,4]:=cLote
	else
		//aglutinar os codigos com mesmo lote e endereço
		nc:=ascan(aItens,{|x| x[1]==cCod})
		if nc==0
			aadd(aItens ,{cCod,nQemp,cEndO,cLote})
		else
			nl:=ascan(aItens,{|x| alltrim(x[1])+x[4]==alltrim(cCod)+cLote})
			if nl==0
				aadd(aItens,{cCod,nQtd,cEndO,cLote})
			else
				aItens[nl,2]+=nQtd
			endif
		Endif
	Endif
Return .T.

sTatic Function CkNumSCP(cDocSCP,cCod,lbx,nqtd)
	Local aArea := GetArea()
	LOCAL lRet:=.T.
	Local nItens:=0
	Local nEnc:=0
	Local nCod:=0
	Local x
	dbselectarea("SCP")
	SCP->(DbSetOrder(1))
	SCP->(dbSeek(xFilial("SCP")+cDocSCP))
	if SCP->(EOF()) .or. SCP->CP_NUM<>cDocSCP
		DLVTAviso('SIGAWMS',"Solicitação invalida!, tente novamente.")
		cDoc:=space(6)
		Return( .f. )
	endif
	DO WHILE !SCP->(EOF()) .and. SCP->CP_NUM==cDocSCP
		nItens++
		if UPPER(left(SCP->CP_OBS,3))=="TM-" .OR. UPPER(left(SCP->CP_OBS,3))=="DEV" .OR. left(SCP->CP_OBS,3)=="501"
			cD3_TM:=iif(UPPER(left(SCP->CP_OBS,3))=="DEV","004",IIF("501"$(SCP->CP_OBS),"501",SUBSTR(SCP->CP_OBS,4,3)))
			cCC:=SCP->CP_CC
		endif
		if SCP->CP_STATUS=="E"
			nEnc++
			dbskip()
			loop
		endif
		if len(alltrim(cCod))>0
			if SCP->CP_PRODUTO==cCod
				nCod++
				nQbr:=0
				For x:=1 to len(aItens)
					if alltrim(cCod)==alltrim(aItens[x,1])
						nQbr+=aItens[x,2]
					endif
				Next
				if !lbx
					if SCP->CP_QUANT>SCP->CP_QUJE .and. (nQtd+nQbr)<=SCP->(CP_QUANT-CP_QUJE)
						lRet:=.T.
					else
						DLVTAviso('SIGAWMS',"Sld Insuf. !, Sld: "+str(SCP->(CP_QUANT-CP_QUJE),10,2)+"ja Dig: "+str(nQbr,6,2)+"Dig: "+str(nQtd,6,2))
						cCod:= SPACE(15)
						nQtd:= 0
						lRet:=.F.
					endif
				endif
				if lbx .and. lRet
					nEntregue:=SCP->CP_QUJE + nqtd
					RecLock("SCP",.F.)
					SCP->CP_XDOCSD3:= cDocSCP
					SCP->CP_QUJE   := SCP->CP_QUJE + nqtd
					SCP->CP_STATUS := IIF( nEntregue < SCP->CP_QUANT, "I","E")
					SCP->CP_PREREQU:= IIF( nEntregue < SCP->CP_QUANT, "","S")
					SCP->CP_OBS    := IIF( nEntregue < SCP->CP_QUANT, "BX Parc:","BX:") +Transform(dDatabase,"99/99/99")+"-"+TIME()+"-"+Alltrim(CUSERNAME)// Utilizado para da data do pagto da OP pelo almoxarifado
					SCP->(MsUnLock())
				endif
			Endif
		endif
		dbskip()
	ENDDO
	If nCod==0 .and.  len(alltrim(cCod))>0
		DLVTAviso('SIGAWMS',"Cod. Fora da Sol.!, tente novamente.")
		cCod:= SPACE(15)
		nQtd:= 0
		lRet:=.F.
	Endif
	IF nItens==nEnc
		DLVTAviso('SIGAWMS',"Sol. foi encerrada!, tente novamente.")
		cDoc:=space(6)
		lRet:=.F.
	ENDIF
	// desabilitado até resolução do  Sr. Fabio 27/11/2017 (utilidae: verificar a qtde paga pelo estoque conforme empenho de kanbans
	/*
	If verEmp() .and. cD3_TM=="501" .and. left(cDoc,1)!="P"
	   DLVTAviso('SIGAWMS',"Mat. pago acima do Empenho!")
	   cCod:= SPACE(15)
	   nQtd:= 0
	   lRet:=.F.
	Endif
	*/
	RestArea(aArea)
Return( lRet )

Static Function SaldSBF()  //saldo no endereço
	Local nDoc:=0
	cAliasSBF:= GetNextAlias()
	if val(cD3_TM)<500
		cendq:=cEndF
		cLocq:=cAlmox
	else
		cendq:=cEndO
		cLocq:="11"
	endif
	BeginSql Alias cAliasSBF
	SELECT isnull(SUM(BF_QUANT),0) AS BF_QUANT FROM %Table:SBF% SBF WHERE BF_FILIAL=%xFilial:SBF%
	AND BF_PRODUTO=%exp:cCod%  AND BF_LOCAL=%exp:cLocq% AND BF_LOCALIZ=%exp:cendq% AND BF_LOTECTL=%exp:ALLTRIM(cLote)%
	AND SBF.%NotDel%
	EndSql
	dbSelectArea(cAliasSBF)
	dbgotop()
	nDoc+=(cAliasSBF)->BF_QUANT
	dbSelectArea(cAliasSBF)
	dbclosearea()
	if val(cD3_TM)<500
		DLVTAviso('SIGAWMS',cendq+" loc: "+ cLocq+" Sld: "+str(nDoc,10,2))
	endif
Return(nDoc)

Static Function Baixa3MMb()
	Local aArea2 := GetArea()
	Local aCab  :={}
	Local _aItem := {}
	LOCAL _atotitem := {}
	LOCAL lShowMSM:=.T.
	Local cAlmox,cConta,cGrupo,i
	Private lMsHelpAuto := .T.
	Private lAutoErrNoFile := .F.
	cTitulo:= "PAGTO-"

	IF (!GetMv("MV_ULMES") > dDataBase)

		FOR I:=1 TO LEN(aItens)

			cAlmox:="11"
			cConta:=Posicione("SB1",1,xfilial("SB1")+aItens[I,1],"B1_CONTA")
			cGrupo:=Posicione("SB1",1,xfilial("SB1")+aItens[I,1],"B1_GRUPO")
			cUm:=Posicione("SB1",1,xfilial("SB1")+aItens[I,1],"B1_UM")
			//  {"D3_QTSEGUM",1             ,NIL},;
			_aitem:={{"D3_COD"    ,aItens[I,1]   ,NIL},;
			{"D3_UM"     ,cUm           ,NIL},;
			{"D3_QUANT"  ,aItens[I,2]   ,NIL},;
			{"D3_ITEM"   ,STRZERO(I,2)  ,NIL},;
			{"D3_LOCAL"  ,cAlmox        ,NIL},;
			{"D3_CONTA"  ,cConta        ,NIL},;
			{"D3_GRUPO"  ,cGrupo        ,NIL},;
			{"D3_LOCALIZ",IIF(VAL(cD3_TM)<500,cEndF,aItens[I,3])   ,NIL},;   //CASO SEJA DEVOLUÇÃO BAIXA DO PROCESSO
			{"D3_LOTECTL",aItens[I,4]   ,NIL},;
			{"D3_OBSERVA",cObserv+" "+left(time(),5)+" US.:"+ Substring ( cUsuario , 7 , 12 ),NIL},;
			{"D3_EMISSAO",dDataBase                          ,nil}}

			aadd(_atotitem,_aitem)

		Next
		cDocSd3:=DocSd3()
		aCab := {{"D3_DOC"     ,cDocSd3      ,NIL}, ;
		{"D3_TM"      ,cD3_TM    ,NIL}, ;
		{"D3_CC"      ,cCC    ,NIL}   , ;
		{"D3_EMISSAO" ,dDataBase ,Nil} }

		BeginTran()

		lMSErroAuto := .F.
		lMSHelpAuto := .T.
		DLVTAviso('SIGAWMS',"Doc: "+cDocSd3+ " Tipo: "+cD3_TM)
		MSExecAuto({|x,y,z|MATA241(x,y,z)},aCab,_atotitem,3)  //Usado para Gerar movimentos Intermos.
		//CONFIRMSX8()
		lMSHelpAuto := .F.
		If lMSErroAuto
			lShowMSM:=.F.
			VTBeep(2)
			DLVTAviso('SIGAWMS',"Falha na gravacao da movimentacao, tente novamente.")
			MostraErro()
			DisarmTransaction()
		ELSE
			EndTran()
			MsUnlockAll()
			FOR I:=1 TO LEN(aItens)
				SD3->(dbSetOrder(2))     //Filial + D3_DOC + D3_COD
				//IF cD3_TM<>"502"
				IF SD3->( dbSeek( xFilial("SD3")+PADR(ALLTRIM(cDocSd3),9)+aItens[I,1] ) )
					_cAprop  := ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+aItens[I,1],"B1_APROPRI"))
					_cLocPad := ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+aItens[I,1],"B1_LOCPAD"))
					_cLocDes := IIF(VAL(cD3_TM)<500,"11",GETMV("MV_LOCPROC") )   //CASO SEJA DEVOLUÇAO ENDERECA NO ALMOX
					_cEndDes := IIF(VAL(cD3_TM)<500,aItens[I,3] ,cEndF)  //ENDEREÇA O PROCESSO, CASO SEJA DEVOLUCAO ENDEREÇA O ALMOXARIFADO)
					// u_fSd3265(3 , SD3->D3_COD , SD3->D3_NUMSEQ , cDocSd3 , _cLocDes , _cEndDes )
				ELSE
					VTBeep(2)
					DLVTAviso('SIGAWMS',"Falha no Endereça,ento do Produto.")
				ENDIF
				//ELSE
				lBx:= CkNumSCP(cDoc,aItens[I,1],.t.,aItens[I,2])
				//ENDIF
			Next
		Endif

		IF lShowMSM
			DLVTAviso('SIGAWMS',cTitulo+cD3_TM+" :  foi realizada com sucesso. Doc: "+cDoc )
		ELSE
			DLVTAviso('SIGAWMS',"Alguns itens nao foram "+cTitulo+". Favor analisar! ")
		ENDIF

	ELSE
		DLVTAviso('SIGAWMS',AllTrim(cUserName)+", não é permitido "+cTitulo+" Ordem Producao com data menor que a do fechamento!")

	Endif
Return

Static Function DocSd3()
	Local nDoc:=1
	Local cDocs
	Local cAliasSD3:= GetNextAlias()
	BeginSql Alias cAliasSD3
	SELECT isnull(MAX(D3_DOC),'000000000') AS D3_DOC FROM %Table:SD3% SD3 WHERE D3_FILIAL=%xFilial:SD3%
	AND LEFT(D3_DOC,6)=%exp:left(alltrim(cDoc),6)% AND D3_COD=%exp:cCod%
	AND SD3.%NotDel% AND D3_CF IN ('PR0','PR1')  AND D3_ESTORNO=''
	EndSql
	dbSelectArea(cAliasSD3)
	dbgotop()
	nDoc+=VAL(SUBSTR((cAliasSD3)->D3_DOC,7,3))
	dbSelectArea(cAliasSD3)
	dbclosearea()
	cDocs:=LEFT(alltrim(cDoc),6)+STRZERO(nDoc,3)
Return(cDocs)

Static Function verEmp()
	Local lRet:=.F.
	Local cData:=left(dtos(ddatabase),6)
	Local cAliasSD3:= GetNextAlias()
	BeginSql Alias cAliasSD3
 SELECT ISNULL(SUM(D3_QUANT),0)  PAGO,
	 (SELECT ISNULL(SUM(D4_QTDEORI),0) FROM %Table:SD4% SD4
	 WHERE D4_FILIAL=%xFilial:SD4% AND SUBSTRING(D4_DATA,1,6)=%exp:cData%
	 AND SD4.%NotDel% AND D4_COD=%exp:cCod%) EMPENHO
	 FROM %Table:SD3% SD3 WHERE D3_FILIAL=%xFilial:SD3% AND SUBSTRING(D3_EMISSAO,1,6)=%exp:cData%
	 AND D3_CF='RE3' AND D3_ESTORNO<>'S' AND SD3.%NotDel%
	 AND D3_COD=%exp:cCod%
	EndSql
	dbSelectArea(cAliasSD3)
	dbgotop()
	If (nQtd+(cAliasSD3)->PAGO)-(cAliasSD3)->EMPENHO>0
	 lRet:=.T.
	Endif
	dbSelectArea(cAliasSD3)
	dbclosearea()
Return(lRet)

