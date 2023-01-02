#include "protheus.ch"
// compilar nos repositórios OFICIAL e SCHEDULE
/*/
———————————————————————————————————————————————————————————————————————————————
@function		MTALCFIM                                                     /@
@date			11/11/2020                                                   /@
@type			Ponto de entrada                                             /@
@description	Acionada ao final da função MaAlcDoc permitindo interações
                no controle de alçada dos documentos.
@parameters     ParamIXB[1]	- Array com informações do documento.
                            [1] Número do documento
                            [2] Tipo de Documento 
                            [3] Valor do Documento 
                            [4] Código do Aprovador
                            [5] Código do Usuário
                            [6] Grupo do Aprovador
                            [7] Aprovador Superior
                            [8] Moeda do Documento
                            [9] Taxa da Moeda 
                            [10] Data de Emissão do Documento
                            [11] Grupo de Compras
                ParamIXB[2] - Data de referência para o saldo.
                ParamIXB[3] - Operação a ser executada.
                ParamIXB[4] - Chave(Alternativa) do SF1 para exclusão SCR.
                ParamIXB[5] - Eliminação de Residuos.                        /@
@return         .T. Libera PC / .F. Bloqueia PC                              /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Tecnologia da Informação                            /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MTALCFIM()
Local aArea			:= GetArea()
Local aAreaSCR		:= SCR->(GetArea())
Local aAreaSAK		:= SAK->(GetArea())
Local aAreaSAL		:= SAL->(GetArea())
Local aAreaSCS		:= SCS->(GetArea())
Local aAlcada    	:= PARAMIXB[1]
//Local dDtRef    	:= PARAMIXB[2]
Local nOper 		:= PARAMIXB[3]
Local cDtSaldo		:= Left(dTOs(Date()),6) + "01"
Local aGestores		:= {{"", ""}, {"", ""}}		//Codigo gestor, nivel gestor
Local nSaldo		:= 0
Local lSaldo		:= .F.
Local nRecSAL, nRecSAK, nLimiteSAK

SAK->(dbSetOrder(1))	//AK_FILIAL, AK_COD
SAL->(dbSetOrder(3))	//AL_FILIAL, AL_COD, AL_APROV
SCR->(dbSetOrder(1))	//CR_FILIAL, CR_TIPO, CR_NUM, CR_NIVEL
SCS->(dbSetOrder(2))    //CS_FILIAL, CS_APROV, CS_DATA

//—————————————————————————————————————————————————————————————————————————
// Em aprovações de alçadas em PEDIDO DE COMPRAS acrescentar novas linhas
// quando o limite do aprovador antigir 90% de uso.
// 90% - incluir Controller
// 95% - incluir Controller e Gestor Local
//—————————————————————————————————————————————————————————————————————————

if nOper == 4 .and.;
    aAlcada[2] == "PC" .and.;
    SAL->(FieldPos("AL_XGEST1N")) > 0 .and.;
    SAL->(FieldPos("AL_XGEST2N")) > 0 .and.;
    SAK->(dbSeek(xFilial("SAK") + aAlcada[4])) .and.;
    SAL->(dbSeek(xFilial("SAL") + aAlcada[6] + aAlcada[4])) .and.;
    SAL->AL_LIBAPR == "A"

	//Identificando os gestores a partir do aprovador
	nLimiteSAK		:= SAK->AK_LIMITE
	aGestores[1,1]	:= SAL->AL_XGEST1N
	aGestores[2,1]	:= SAL->AL_XGEST2N
	nRecSAL			:= SAL->(Recno())
	nRecSAK			:= SAK->(Recno())
	
	//—————————————————————————————————————————————————————————————————————————
	// Identificando os niveis dos gestores no grupo de aprovação e caso não 
	// encontre, significa que o gestor é um responsável pelo depto, portanto
	// não gero uma nova linha para não duplicar a aprovação para o mesmo
	// "aprovador"
	//—————————————————————————————————————————————————————————————————————————
	if SAL->(dbSeek(xFilial("SAL") + aAlcada[6] + aGestores[1,1]))
		aGestores[1,2]	:= SAL->AL_NIVEL

		//—————————————————————————————————————————————————————————————————————————
		// Tratamento para substituto do gestor 1
		//—————————————————————————————————————————————————————————————————————————
		SAK->(dbSeek(xFilial("SAK") + aGestores[1,1]))
		if dDataBase >= SAK->AK_XBLQDE .and. dDataBase <= SAK->AK_XBLQATE .and. !Empty(SAK->AK_XSUBST)
			aGestores[1,1] := SAK->AK_XSUBST
		endif

	endif
	if SAL->(dbSeek(xFilial("SAL") + aAlcada[6] + aGestores[2,1]))
		aGestores[2,2]	:= SAL->AL_NIVEL

		//—————————————————————————————————————————————————————————————————————————
		// Tratamento para substituto do gestor 2
		//—————————————————————————————————————————————————————————————————————————
		SAK->(dbSeek(xFilial("SAK") + aGestores[2,1]))
		if dDataBase >= SAK->AK_XBLQDE .and. dDataBase <= SAK->AK_XBLQATE .and. !Empty(SAK->AK_XSUBST)
			aGestores[2,1] := SAK->AK_XSUBST
		endif

	endif

	SAL->(dbGoTo(nRecSAL))
	SAK->(dbGoTo(nRecSAK))

	if SCS->(dbSeek(xFilial("SCS") + aAlcada[4] + cDtSaldo, .T.))
		lSaldo	:= .T.
		nSaldo	:= SCS->CS_SALDO
    endif

    if nSaldo < (SAK->AK_LIMITE * 0.1) .and. lSaldo

		//—————————————————————————————————————————————————————————————————————————
		// Valida se deve ser criado alçada para os gestores, pois podem já ter 
		// sido registrados como responsaveis pela aprovação
		//—————————————————————————————————————————————————————————————————————————
		ValidaGestor(@aGestores)

        if nSaldo < (SAK->AK_LIMITE * 0.05)

			// Gravo somente se o nível tiver sido preenchido
			if !Empty(aGestores[1,2])
				GrvAlcada(aAlcada, SAL->AL_XGEST1N, aGestores[1])
			endif
			// Gravo somente se o nível tiver sido preenchido
			if !Empty(aGestores[2,2])
				GrvAlcada(aAlcada, SAL->AL_XGEST2N, aGestores[2])
			endif
	
        else

			// Gravo somente se o nível tiver sido preenchido
			if !Empty(aGestores[1,2])
				GrvAlcada(aAlcada, SAL->AL_XGEST1N, aGestores[1])
			endif

        endif

    endif

endif

RestArea(aAreaSCR)
RestArea(aAreaSCS)
RestArea(aAreaSAK)
RestArea(aAreaSAL)
RestArea(aArea)

// não retornar conteudo lógico (.T. ou .F.) para que rotina assuma o resultado obtido pelo padrão
Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		VALIDAGESTOR                                                 /@
@date			23/06/2021                                                   /@
@type			Static Function                                              /@
@description	Verifica se os gestores gravados por atingimento de 
				proximidade com o fim do orçamento mensal, já foram acionados
				como responsável ou substituto na linha de aprovação do 
				departamento e elimina a necessidade de uma nova aprovação.  /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function ValidaGestor(aGestores)
Local aArea		:= GetArea()
Local aAreaSCR	:= SCR->(GetArea())
Local cChave	:= SCR->(CR_FILIAL + CR_TIPO + CR_NUM)

SCR->(dbSetOrder(1))	//CR_FILIAL, CR_TIPO, CR_NUM, CR_NIVEL
SCR->(dbSeek(cChave))
do while SCR->(!eof() .and. CR_FILIAL + CR_TIPO + CR_NUM == cChave)
	if !Empty(aGestores[1,1]) .and. (aGestores[1,1] == SCR->CR_APROV .or. aGestores[1,1] == SCR->CR_XRESP)
		aGestores[1,1] := ""
		aGestores[1,2] := ""
	endif
	if !Empty(aGestores[2,1]) .and. (aGestores[2,1] == SCR->CR_APROV .or. aGestores[2,1] == SCR->CR_XRESP)
		aGestores[2,1] := ""
		aGestores[2,2] := ""
	endif
	SCR->(dbSkip())
enddo

RestArea(aAreaSCR)
RestArea(aArea)

Return()

/*/
———————————————————————————————————————————————————————————————————————————————
@function		GRVALCADA                                                    /@
@date			11/11/2020                                                   /@
@type			Static Function                                              /@
@description	Grava registros adicionais no controle de alçada de compras. /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Tecnologia da Informação                            /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function GrvAlcada(aAlcada, cUserApr, aGestor)
Local aArea		:= GetArea()
Local aAreaSAK	:= SAK->(GetArea())
Local aAreaSCR	:= SCR->(GetArea())
Local lExistN02	:= .F.

SAK->(dbSetOrder(1))		//AK_FILIAL, AK_COD
SCR->(dbSetOrder(3))		//CR_FILIAL, CR_TIPO, CR_NUM, CR_APROV

if !SCR->(dbSeek(xFilial("SCR") + aAlcada[2] + aAlcada[1] + aGestor[1])) .and.;
	SAK->(dbSeek(xFilial("SAK") + aGestor[1]))

	//Descobrindo o status do registro a ser gravado
	SCR->(dbSetOrder(1))		//CR_FILIAL, CR_TIPO, CR_NUM, CR_NIVEL
	SCR->(dbSeek(xFilial("SCR") + aAlcada[2] + aAlcada[1]))
	do while SCR->(!eof() .and. CR_FILIAL == xFilial("SCR") .and. CR_TIPO == aAlcada[2] .and. CR_NUM == aAlcada[1])
		if SCR->CR_STATUS == "02"
			lExistN02	:= .T.
			exit
		elseif SCR->CR_STATUS == "01" .and. SCR->CR_NIVEL < aGestor[2]
			lExistN02	:= .T.
		endif
		SCR->(dbSkip()) 
	enddo

	SCR->(Reclock("SCR",.T.))
	SCR->CR_FILIAL	:= xFilial("SCR")							//cFilSCR
	SCR->CR_NUM		:= aAlcada[1]								//cDocto
	SCR->CR_TIPO	:= aAlcada[2]								//cTipoDoc
	SCR->CR_NIVEL	:= aGestor[2]
	SCR->CR_USER	:= SAK->AK_USER
	SCR->CR_APROV	:= aGestor[1]
	SCR->CR_STATUS	:= iif(lExistN02, "01", "02")
	SCR->CR_TOTAL	:= aAlcada[3]								//nValDcto
	SCR->CR_EMISSAO	:= aAlcada[10]								//IIF(nPosDoc > 0,aDocRelib[nPosDoc][2],aDocto[10])
	SCR->CR_MOEDA	:= aAlcada[8]								//nMoeDcto
	SCR->CR_TXMOEDA	:= aAlcada[9]								//nTxMoeda
	SCR->CR_ESCALON	:= .F.										//lEscalona
	SCR->CR_ESCALSP	:= .F.										//lEscalonaS
	SCR->CR_GRUPO	:= iif(aAlcada[6] != NIL, aAlcada[6], "")	//cGrupo

	//SCR->CR_PRAZO	:= dPrazo
	//SCR->CR_AVISO	:= dAviso
	//If !Empty(cItGrp)
	//	SCR->CR_ITGRP := cItGrp
	//EndIf

	SCR->(MsUnlock())

endif

RestArea(aAreaSCR)
RestArea(aAreaSAK)
RestArea(aArea)
Return()


/*
If !(cTipoDoc $ "IP|SA|") 
	//Reposiciona e verifica se ja esta totalmente liberado
	SCR->(MsGoto(nRec))
	While SCR->(!Eof()) .And. cFilSCR+cTipoDoc+cDocto == SCR->(CR_FILIAL+CR_TIPO+CR_NUM)
		If cGrupo == SCR->CR_GRUPO .And. SCR->CR_ITGRP == cItGrp
			If SCR->CR_STATUS != "03" .And. SCR->CR_STATUS != "05" .And. SCR->CR_STATUS != "04"
				lRet := .F.
				Exit
			EndIf
		Endif
		SCR->(dbSkip())
	EndDo
EndIf






Function MaAlcDoc(aDocto,dDataRef,nOper,cDocSF1,lResiduo,cItGrp,aItens,lEstCred,aItensDBM,cChaveRej)
Local cDocto	:= aDocto[1]
Local cTipoDoc	:= aDocto[2]
Local nValDcto	:= aDocto[3]
Local cAprov	:= If(aDocto[4]==Nil,"",aDocto[4])
Local cUsuario	:= If(aDocto[5]==Nil,"",aDocto[5])
Local nMoeDcto	:= If(Len(aDocto)>7,If(aDocto[8]==Nil, 1,aDocto[8]),1)
Local nTxMoeda	:= If(Len(aDocto)>8,If(aDocto[9]==Nil, 0,aDocto[9]),0)
Local cObs      := If(Len(aDocto)>10,If(aDocto[11]==Nil, "",aDocto[11]),"")
Local aArea		:= GetArea()
Local aAreaSCS	:= SCS->(GetArea())
Local aAreaSCR	:= SCR->(GetArea())
Local aRetPe	:= {}
Local aRetDBM	:= {.F.,0,0,0}
Local nSaldo	:= 0
Local nCount    := 1
Local cGrupo	:= If(aDocto[6]==Nil,"",aDocto[6])
Local lFirstNiv:= .T.
Local cAuxNivel:= ""
Local cNextNiv := ""
Local cNivIgual:= ""
Local cStatusAnt:= ""
Local cAprovOri := ""
Local cUserOri  := ""
Local cObsBloq  := STR0061
Local lAchou	:= .F.
Local nRec		:= 0
Local lRetorno	:= .T.
Local aSaldo	:= {}
Local aMTALCGRU := {}
Local lDeletou  := .F.
Local lBloqueio := .F.
Local dDataLib := IIF(dDataRef==Nil,dDataBase,dDataRef)
Local lIntegDef  := FWHasEAI("MATA120",.T.,,.T.)
Local lAltpdoc	:= SuperGetMv("MV_ALTPDOC",.F.,.F.)
Local lCnAglFlg	:= SuperGetMV("MV_CNAGFLG",.F.,.F.)
Local lNfLimAl	:= SuperGetMV("MV_NFLIMAL",.F.,.F.)
Local lTipoDoc	:= .T.
Local lFluig		:= !Empty(AllTrim(GetNewPar("MV_ECMURL",""))) .And. FWWFFluig()
Local lBlqNivel := .F.
Local cGrupoSAL	:= ""
Local cAprovDBM	:= ""
Local cMTALCAPR	:= ""
Local lUserNiv	:= .F. //Verifica se existe usuário no mesmo nível - Tipo de Lib por Usuário
Local lCalMta235 := IsInCallStack("MATA235")

Local dPrazo	:= Ctod("//")
Local dAviso	:= Ctod("//")
Local nRecAprov	:= 0
Local lEscalona 	:= .F.
Local lEscalonaS	:= .F.
Local lRetCr 		:= .T.
Local cFilSCR		:= IIf(cTipoDoc $ 'IC|CT|IR|RV',CnFilCtr(cDocto),xFilial("SCR"))
Local lNewFlg		:= .F.
Local nPosDoc		:= 0

PRIVATE cA120Num := ""

DEFAULT dDataRef := dDataBase
DEFAULT cDocSF1 := cDocto
DEFAULT lResiduo := .F.
DEFAULT cItGrp	:= ""
DEFAULT aItens	:= {}
DEFAULT lEstCred := .T.
DEFAULT cChaveRej:= ""
cDocto := cDocto+Space(Len(SCR->CR_NUM)-Len(cDocto))
cDocSF1:= cDocSF1+Space(Len(SCR->CR_NUM)-Len(cDocSF1))

If ExistBlock("MT097GRV")
	lRetorno := (Execblock("MT097GRV",.F.,.F.,{aDocto,dDataRef,nOper,cDocSF1,lResiduo}))
	If Valtype( lRetorno ) <> "L"
		lRetorno := .T.
	EndIf
Endif

If type("aDocRelib") == "U"
	 aDocRelib := {}
EndIf

If lRetorno

	If Empty(cUsuario) .And. (nOper != 1 .And. nOper != 6) //nao e inclusao ou estorno de liberacao
		dbSelectArea("SAK")
		SAK->(dbSetOrder(1))
		SAK->(MsSeek(xFilial("SAK") + cAprov))
		cUsuario :=	AK_USER
		SAL->(DbSetOrder(1))
		If SAL->(DbSeek(xFilial("SAL")+cGrupo+cUsuario))
			DHL->(DbSetOrder(1))
			If DHL->(DbSeek(xFilial("DHL") + SAL->AL_PERFIL))
				nMoeDcto := DHL->DHL_MOEDA
			Else
				nMoeDcto :=	AK_MOEDA
			Endif
		Else
			nMoeDcto :=	AK_MOEDA
		EndIf
		nTxMoeda	:=	0
	EndIf
	
	If nOper == 1  //Inclusao do Documento


		cGrupo := If(!Empty(aDocto[6]),PadR(aDocto[6], TamSX3("AL_COD")[1]),PadR(cGrupo, TamSX3("AL_COD")[1]))
		dbSelectArea("SAL")
		SAL->(dbSetOrder(2))
		If !Empty(cGrupo) .And. SAL->(MsSeek(xFilial("SAL",cFilAnt)+cGrupo))
			If lAltpdoc
				Do Case
				Case cTipoDoc == "AE"
					lTipoDoc := SAL->AL_DOCAE == .T.
				Case cTipoDoc == "CO"
					lTipoDoc := SAL->AL_DOCCO == .T.
				Case cTipoDoc == "CP"
					lTipoDoc := SAL->AL_DOCCP == .T.
				Case cTipoDoc == "NF"
					lTipoDoc := SAL->AL_DOCNF == .T.
				Case cTipoDoc == "PC"
					lTipoDoc := SAL->AL_DOCPC == .T.
				Case cTipoDoc == "SA"
					lTipoDoc := SAL->AL_DOCSA == .T.
				Case cTipoDoc == "SC"
					lTipoDoc := SAL->AL_DOCSC == .T.
				Case cTipoDoc == "ST"
					lTipoDoc := SAL->AL_DOCST == .T.
				Case cTipoDoc == "IP"
					lTipoDoc := SAL->AL_DOCIP == .T.
				Case cTipoDoc $ "CT|IC"
					lTipoDoc := SAL->AL_DOCCT == .T.
				Case cTipoDoc $ "RV|IR"
					lTipoDoc := SAL->AL_DOCCT == .T.
				Case cTipoDoc $ "MD|IM"
					lTipoDoc := SAL->AL_DOCMD == .T.
				Case cTipoDoc == "GA"
					lTipoDoc := SAL->AL_DOCGA == .T.
                Case cTipoDoc >= "A1" .AND. cTipoDoc <= "A9" //Documentos Agro
					lTipoDoc := AGRXCOM12(SAL->AL_AGRCNNG, cTipoDoc, cGrupo)
				End
			EndIf

			SAK->(dbSetOrder(1))

			While !SAL->(Eof()) .And. xFilial("SAL",cFilAnt)+cGrupo == SAL->(AL_FILIAL+AL_COD) .And. lTipoDoc
				dPrazo		:= Ctod("//")
				dAviso  	:= Ctod("//")					

				//-- Verifica se o Registro esta Bloqueado				
				If !RegistroOk("SAL",.F.) .Or. SAK->(! dbSeek(xFilial("SAK")+SAL->AL_APROV )) .Or. !RegistroOk("SAK",.F.)
					SAL->(dbSkip())
					Loop
				EndIf
				//-- Elimina o aprovador que não realizou o pedido de compras e não efetuou aprovacoes.	
				If lCalMta235 				
					If !ElExistSCR(cTipoDoc,cDocto,SAL->AL_APROV,nOper,cItGrp) .And. cTipoDoc $ "PC*IP"
						SAL->(dbSkip())
						Loop
					EndIf
					dbSelectArea("SAL")
					SAL->(dbSetOrder(2))					
				EndIf	
				If  (!cTipoDoc $ "NF|PC|IP|SA" .Or. lNfLimAl)
					If SAL->AL_AUTOLIM == "S" .And. !MaAlcLim(SAL->AL_APROV,nValDcto,nMoeDcto,nTxMoeda,cGrupo)
						SAL->(dbSkip())
						Loop
					EndIf
				EndIf
		
				Do Case
				Case cTipoDoc == "NF"
					SF1->(FkCommit())
				Case cTipoDoc == "PC" .Or. cTipoDoc == "AE"
					SC7->(FkCommit())
				Case cTipoDoc == "CP"
					SC3->(FkCommit())
				Case cTipoDoc == "SC"
					SC1->(FkCommit())
				Case cTipoDoc == "CO"
					SC8->(FkCommit())
				Case cTipoDoc == "MD"
					CND->(FkCommit())
				EndCase

				cAprovOri := SAL->AL_APROV
				cUserOri  := SAL->AL_USER
				
				//-- Ponto de entrada para troca do usuario aprovador
				If ExistBlock("MTALCAPR")
					SAK->(dbSetOrder(2))
					If ValType(cMTALCAPR := ExecBlock("MTALCAPR",.F.,.F.,{cTipoDoc,cDocto,nValDcto,dDataRef})) == "C" .And.;
										SAK->(MsSeek(xFilial("SAK")+cMTAlCAPR))
						cAprovOri := SAK->AK_COD
						cUserOri := SAK->AK_USER
					EndIf
					SAK->(dbSetOrder(1))
				EndIf

				//-- Gravacao dos itens da alcada
				If !Empty(aItens) .And. cTipoDoc <> "PC"											 
					aRetDBM := MaAlcItEC(cDocto,cTipoDoc,cGrupo,cItGrp,cUserOri,aItens,,nOper,cAprovOri,,@aItensDBM,SAL->AL_APROV,nMoeDcto)

					If aRetDBM[1]
						nValDcto 	:= aRetDBM[2]
						dPrazo		:= dDatabase + aRetDBM[3]
						dAviso  	:= dPrazo - aRetDBM[4]
						lEscalona	:= aRetDBM[5]
						lEscalonaS	:= aRetDBM[6]
					Else
						dbSelectArea("SAL")
						dbSkip()
						Loop
					EndIf					
				Elseif cTipoDoc == "PC"
					aItens 	:= MaRetItDoc(aDocto[1],xFilial("SC7"),"SC7","PC")
					nValDcto 	:= MaAlcItApG(cDocto,cTipoDoc,cGrupo,cUserOri,aItens,nOper,cAprovOri)
				EndIf

				// Nao gera alcada com valor zerado, exceto SC
				If cTipoDoc <> "NF" .And. cTipoDoc <> "SC" .And. !(cTipoDoc $ 'CT|RV|IR') .And. nValDcto == 0
					SAL->(dbSkip())
					Loop
				Endif

				If cTipoDoc == "PC"
					If SAL->AL_AUTOLIM == "S" .And. !MaAlcLim(SAL->AL_APROV,nValDcto,nMoeDcto,nTxMoeda,cGrupo)
						SAL->(dbSkip())
						Loop
					EndIf
				EndIf

				If lFirstNiv
					cAuxNivel := SAL->AL_NIVEL
					lFirstNiv := .F.
				EndIf

				nPosDoc := ascan(aDocRelib,{|x|,x[1] = cFilSCR+cTipoDoc+cDocto+cAprovOri})
				
				Reclock("SCR",.T.)
				SCR->CR_FILIAL	:= cFilSCR
				SCR->CR_NUM		:= cDocto
				SCR->CR_TIPO	:= cTipoDoc
				SCR->CR_NIVEL	:= SAL->AL_NIVEL
				SCR->CR_USER	:= cUserOri
				SCR->CR_APROV	:= cAprovOri
				SCR->CR_STATUS	:= IIF(SAL->AL_NIVEL == cAuxNivel  ,"02","01")
				SCR->CR_TOTAL	:= nValDcto
				SCR->CR_EMISSAO	:= IIF(nPosDoc > 0,aDocRelib[nPosDoc][2],aDocto[10])
				SCR->CR_MOEDA	:= nMoeDcto
				SCR->CR_TXMOEDA	:= nTxMoeda
				SCR->CR_PRAZO	:= dPrazo
				SCR->CR_AVISO	:= dAviso
				SCR->CR_ESCALON	:= lEscalona
				SCR->CR_ESCALSP	:= lEscalonaS

				If !Empty(cGrupo)
			   		SCR->CR_GRUPO := cGrupo
				EndIf

				If !Empty(cItGrp)
			   		SCR->CR_ITGRP := cItGrp
				EndIf

				MsUnlock()

				//Ponto de entrada para alteraçao da SCR
				If ExistBlock("MTALCALT")
					Execblock("MTALCALT",.F.,.F.)
				EndIf

				// Gera a nova alçada no Fluig
				If lFluig .And. SCR->CR_STATUS == '02'
					If cTipoDoc $ "CT|IC|IR|IM"
						If cTipoDoc == "IR"
							Aadd(aFluigIR, cDocto)
						EndIf
						If (!lCnAglFlg .Or. cTipoDoc = "IM")
							cUserSolic	:= MtUsrSolic(SCR->CR_TIPO,SCR->CR_NUM)
							MTSoliCAT(cTipoDoc,cDocto,"","CR_NUM",cUserSolic,.T.)
						EndIf
					Elseif cTipoDoc <> "RV"
						cUserSolic	:= MtUsrSolic(SCR->CR_TIPO,SCR->CR_NUM)
						MTSoliCAT(cTipoDoc,cDocto,"","CR_NUM",cUserSolic,.T.)
					EndIf
				EndIf
				
				dbSelectArea("SAL")
				SAL->(dbSkip())
			EndDo
		EndIf
		If cTipoDoc == "NF" .And. !lFirstNiv .And. !Empty(cGrupo)
			lFirstNiv := .T.
		EndIf
		lRetorno := lFirstNiv

*/
