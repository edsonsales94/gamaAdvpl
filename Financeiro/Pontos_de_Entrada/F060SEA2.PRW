#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F060SEA2  ºAutor  ³ALEXANDRE PINHEIRO  º Data ³  05/07/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³O ponto de entrada F060SEA2 altera antes de gravar, ou gravaº±±
±±º          ³informações adicionais na tabela SEA na geração do Borderô. º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GAMAITALY                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function F060SEA2()
 
Local nFinsed     := GetMV("MV_FINSED", .F., 1) // email que receberar o arquivo
Local nFinced     := GetMV("MV_FINSEI", .F., 1) // contas que serao enviadas


If  ALLTRIM(SEA->EA_NUMCON) $ nFinced                         //"39635-7,39636-5,39637-3"    //"FINA061" .And. !Empty(SA6->A6_XEMAIL)	//BORDERO CONTAS A RECEBER
	//
	cIdEnt 		:= AllTrim(getCfgEntidade())
	aXml 		:= {}
	aNotas     	:= {}
	cModalidade	:= ""
	//
	MakeDir("edi01")
	MakeDir("edi01\XML_EXPORT") //DIRETORIO AONDE SERÃO GRAVADOS OS EMAILS, GRAVANDO PARA ANEXAR NO EMAIL
	//
	dbSelectArea("SF3")
	dbSetOrder(5)		//FILIAL+SERIE+NFISCAL+CLIEFOR+LJ
	If dbSeek(xFILIAL("SF3")+SEA->EA_PREFIXO+ SEA->EA_NUM + SE1->E1_CLIENTE+SE1->E1_LOJA)   
	//If dbSeek(xFilial("SF1")+cDoc+cSerie+cFornec+cLoja+cTipo)

		//
		aadd(aNotas,{})
		aadd(Atail(aNotas),.F.)
		aadd(Atail(aNotas),IIF(SF3->F3_CFO<"5","E","S"))
		aadd(Atail(aNotas),SF3->F3_ENTRADA)
		aadd(Atail(aNotas),SF3->F3_SERIE)
		aadd(Atail(aNotas),SF3->F3_NFISCAL)
		aadd(Atail(aNotas),SF3->F3_CLIEFOR)
		aadd(Atail(aNotas),SF3->F3_LOJA)
		//
		aXml	:= GetXML(cIdEnt,aNotas,@cModalidade)	//IMPORTA O XML DA TABELA SPED050
		//
		MemoWrite("edi01\XML_EXPORT\" + xFILIAL("SF3") + SEA->EA_PREFIXO + SEA->EA_NUM + ".XML",aXML[1][2])
		//
		cDestinat	:= nFinsed //"jose.mendes@gamaitaly.com.br;maicom.barcellos@gamaitaly.com.br"  //SA6->A6_XEMAIL
		cCopiaOcult	:= ""
		cSubject	:= "NFe Nacional"
		cMsgCorpo	:= "Este e-mail foi enviado automaticamente pelo Sistema de Nota Fiscal Eletrônica (NF-e) da BRASITECH INDUSTRIA E COMERCIO DE APARELHOS P/ BELEZA LTDA"
		cAnexo		:= "\edi01\XML_EXPORT\" + xFILIAL("SF3") + SEA->EA_PREFIXO + SEA->EA_NUM + ".XML"
		//
		U_GISendMail(cDestinat, cCopiaOcult, cSubject, cMsgCorpo, cAnexo)
		//
	EndIf
	//
EndIf

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DEBUG     ºAutor  ³Microsiga           º Data ³  11/22/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GetXML(cIdEnt,aIdNFe,cModalidade)

Local aRetorno		:= {}
Local aDados		:= {}

Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://localhost:8080/sped"),250)
Local cModel		:= "55"


Local nZ			:= 0
Local nCount		:= 0

Local oWS

If Empty(cModalidade)
	
	oWS := WsSpedCfgNFe():New()
	oWS:cUSERTOKEN := "TOTVS"
	oWS:cID_ENT    := cIdEnt
	oWS:nModalidade:= 0
	oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
	oWS:cModelo    := cModel
	If oWS:CFGModalidade()
		cModalidade    := SubStr(oWS:cCfgModalidadeResult,1,1)
	Else
		cModalidade    := ""
	EndIf
	
EndIf

oWs := nil

For nZ := 1 To len(aIdNfe)
	
	nCount++
	
	aDados := executeRetorna( aIdNfe[nZ], cIdEnt )
	
	if ( nCount == 10 )
		delClassIntF()
		nCount := 0
	endif
	
	aAdd(aRetorno,aDados)
	
Next nZ

Return(aRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DEBUG     ºAutor  ³Microsiga           º Data ³  11/22/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//-----------------------------------------------------------------------
/*/{Protheus.doc} executeRetorna
Executa o retorna de notas

@author Henrique Brugugnoli
@since 17/01/2013
@version 1.0

@param  cID ID da nota que sera retornado

@return aRetorno   Array com os dados da nota
/*/
//-----------------------------------------------------------------------
static function executeRetorna( aNfe, cIdEnt, lUsacolab )

Local aExecute		:= {}
Local aFalta		:= {}
Local aResposta		:= {}
Local aRetorno		:= {}
Local aDados		:= {}
Local aIdNfe		:= {}

Local cAviso		:= ""
Local cDHRecbto		:= ""
Local cDtHrRec		:= ""
Local cDtHrRec1		:= ""
Local cErro			:= ""
Local cModTrans		:= ""
Local cProtDPEC		:= ""
Local cProtocolo	:= ""
Local cMsgNFE			:= ""
Local cRetDPEC		:= ""
Local cRetorno		:= ""
Local cCodRetNFE	:= ""
Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://localhost:8080/sped"),250)
Local cModel		:= "55"

Local dDtRecib		:= CToD("")

Local lFlag			:= .T.

Local nDtHrRec1		:= 0
Local nL			:= 0
Local nX			:= 0
Local nY			:= 0
Local nZ			:= 1
Local nCount		:= 0
Local nLenNFe
Local nLenWS

Local oWS

Private oDHRecbto
Private oNFeRet
Private oDoc

default lUsacolab	:= .F.

aAdd(aIdNfe,aNfe)

if !lUsacolab
	
	oWS:= WSNFeSBRA():New()
	oWS:cUSERTOKEN        := "TOTVS"
	oWS:cID_ENT           := cIdEnt
	oWS:nDIASPARAEXCLUSAO := 0
	oWS:_URL 			  := AllTrim(cURL)+"/NFeSBRA.apw"
	oWS:oWSNFEID          := NFESBRA_NFES2():New()
	oWS:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
	
	aadd(aRetorno,{"","",aIdNfe[nZ][4]+aIdNfe[nZ][5],"","","",CToD(""),"","",""})
	
	aadd(oWS:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
	Atail(oWS:oWSNFEID:oWSNotas:oWSNFESID2):cID := aIdNfe[nZ][4]+aIdNfe[nZ][5]
	
	If oWS:RETORNANOTASNX()
		If Len(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5) > 0
			For nX := 1 To Len(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5)
				cRetorno        := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CXML
				cProtocolo      := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CPROTOCOLO
				cDHRecbto  		:= oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CXMLPROT
				oNFeRet			:= XmlParser(cRetorno,"_",@cAviso,@cErro)
				cModTrans		  := IIf(Type("oNFeRet:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT") <> "U",IIf (!Empty("oNFeRet:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT"),oNFeRet:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT,1),1)
				If ValType(oWs:OWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:OWSDPEC)=="O"
					cRetDPEC        := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSDPEC:CXML
					cProtDPEC       := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSDPEC:CPROTOCOLO
				EndIf
				
				
				//Tratamento para gravar a hora da transmissao da NFe
				If !Empty(cProtocolo)
					oDHRecbto		:= XmlParser(cDHRecbto,"","","")
					cDtHrRec		:= IIf(Type("oDHRecbto:_ProtNFE:_INFPROT:_DHRECBTO:TEXT")<>"U",oDHRecbto:_ProtNFE:_INFPROT:_DHRECBTO:TEXT,"")
					nDtHrRec1		:= RAT("T",cDtHrRec)
					
					If nDtHrRec1 <> 0
						cDtHrRec1   :=	SubStr(cDtHrRec,nDtHrRec1+1)
						dDtRecib	:=	SToD(StrTran(SubStr(cDtHrRec,1,AT("T",cDtHrRec)-1),"-",""))
					EndIf
					
					//AtuSF2Hora(cDtHrRec1,aIdNFe[nZ][5]+aIdNFe[nZ][4]+aIdNFe[nZ][6]+aIdNFe[nZ][7])
					
				EndIf
				
				nY := aScan(aIdNfe,{|x| x[4]+x[5] == SubStr(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:CID,1,Len(x[4]+x[5]))})
				
				oWS:cIdInicial    := aIdNfe[nZ][4]+aIdNfe[nZ][5]
				oWS:cIdFinal      := aIdNfe[nZ][4]+aIdNfe[nZ][5]
				If oWS:MONITORFAIXA()
					cCodRetNFE := oWS:oWsMonitorFaixaResult:OWSMONITORNFE[1]:OWSERRO:OWSLOTENFE[len(oWS:oWsMonitorFaixaResult:OWSMONITORNFE[1]:OWSERRO:OWSLOTENFE)]:CCODRETNFE
					cMsgNFE	:= oWS:oWsMonitorFaixaResult:OWSMONITORNFE[1]:OWSERRO:OWSLOTENFE[len(oWS:oWsMonitorFaixaResult:OWSMONITORNFE[1]:OWSERRO:OWSLOTENFE)]:CMSGRETNFE
				EndIf
				
				If nY > 0
					aRetorno[nY][1] := cProtocolo
					aRetorno[nY][2] := cRetorno
					aRetorno[nY][4] := cRetDPEC
					aRetorno[nY][5] := cProtDPEC
					aRetorno[nY][6] := cDtHrRec1
					aRetorno[nY][7] := dDtRecib
					aRetorno[nY][8] := cModTrans
					aRetorno[nY][9] := cCodRetNFE
					aRetorno[nY][10]:= cMsgNFE
					
					//aadd(aResposta,aIdNfe[nY])
				EndIf
				cRetDPEC := ""
				cProtDPEC:= ""
			Next nX
			
		EndIf
	Else
		Aviso("DANFE",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
	EndIf
else
	oDoc 			:= ColaboracaoDocumentos():new()
	oDoc:cModelo	:= "NFE"
	oDoc:cTipoMov	:= "1"
	oDoc:cIDERP	:= aIdNfe[nZ][4]+aIdNfe[nZ][5]+FwGrpCompany()+FwCodFil()
	
	aadd(aRetorno,{"","",aIdNfe[nZ][4]+aIdNfe[nZ][5],"","","",CToD(""),"","",""})
	
	if odoc:consultar()
		aDados := ColDadosNf(1)
		
		if !Empty(oDoc:cXMLRet)
			cRetorno	:= oDoc:cXMLRet
		else
			cRetorno	:= oDoc:cXml
		endif
		
		aDadosXml := ColDadosXMl(cRetorno, aDados, @cErro, @cAviso)
		
		if '<obsCont xCampo="nRegDPEC">' $ cRetorno
			aDadosXml[9] := SubStr(cRetorno,At('<obsCont xCampo="nRegDPEC"><xTexto>',cRetorno)+35,15)
		endif
		
		cProtocolo		:= aDadosXml[3]
		cModTrans		:= IIF(Empty(aDadosXml[5]),aDadosXml[7],aDadosXml[5])
		cCodRetNFE := aDadosXml[1]
		cMsgNFE := iif (aDadosXml[2]<> nil ,aDadosXml[2],"")
		//Dados do DEPEC
		If !Empty( aDadosXml[9] )
			cRetDPEC        := cRetorno
			cProtDPEC       := aDadosXml[9]
		EndIf
		
		//Tratamento para gravar a hora da transmissao da NFe
		If !Empty(cProtocolo)
			cDtHrRec		:= aDadosXml[4]
			nDtHrRec1		:= RAT("T",cDtHrRec)
			
			If nDtHrRec1 <> 0
				cDtHrRec1   :=	SubStr(cDtHrRec,nDtHrRec1+1)
				dDtRecib	:=	SToD(StrTran(SubStr(cDtHrRec,1,AT("T",cDtHrRec)-1),"-",""))
			EndIf
			
			AtuSF2Hora(cDtHrRec1,aIdNFe[nZ][5]+aIdNFe[nZ][4]+aIdNFe[nZ][6]+aIdNFe[nZ][7])
			
		EndIf
		
		aRetorno[1][1] := cProtocolo
		aRetorno[1][2] := cRetorno
		aRetorno[1][4] := cRetDPEC
		aRetorno[1][5] := cProtDPEC
		aRetorno[1][6] := cDtHrRec1
		aRetorno[1][7] := dDtRecib
		aRetorno[1][8] := cModTrans
		aRetorno[1][9] := cCodRetNFE
		aRetorno[1][10]:= cMsgNFE
		
		cRetDPEC := ""
		cProtDPEC:= ""
		
	endif
endif

oWS       := Nil
oDHRecbto := Nil
oNFeRet   := Nil

return aRetorno[len(aRetorno)]
