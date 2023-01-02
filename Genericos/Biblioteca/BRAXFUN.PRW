#include "rwmake.ch"
#include "protheus.ch"
#include "apwizard.ch"
#include "fileio.ch"
#include "rptdef.ch"  
#include "fwprintsetup.ch"
#include "totvs.ch"
#include "Ap5Mail.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
———————————————————————————————————————————————————————————————————————————————
@function		BRAXFUN                                                      /@
@type			Biblioteca de funções                                        /@
@date			20/06/2012                                                   /@
@description	Biblioteca de funções utilizadas em rotinas ou validações
				específicas no ambiente do grupo Gama Italy                  /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Especifico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
———————————————————————————————————————————————————————————————————————————————
/*/


/*/
———————————————————————————————————————————————————————————————————————————————
@function		EAN13VAL                                                      /@
@type				User Function                                                 /@
@date				20/06/2012                                                    /@
@description	Valida/Retorna o digito verificador do código de barras EAN13.
					Tem como retorno esperado .T. ou .F.
					Sintaxe: U_EAN13VLD(cCodBar, lAutom)                          /@
@author			Adalberto Moreno Batista                                      /@
@use				Especifico Brasitech (Grupo Gama Italy)                       /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function EAN13VLD(cCodBar, lAutom)
Local lRet	:= .F.
Local cDV	:= Substr(cCodBar, 13, 1)
Local nSoma	:= 0
Local nMult	:= 0
Local nK, nDV
Default lAutom := .F. //indica a execucao por rotina automatica

if Len( AllTrim(cCodBar) ) = 13
	
	For nK := 1 to 12
		nMult := iif( nMult = 1, 3, 1)
		nSoma += (Val( Substr(cCodBar, nK, 1) ) * nMult)
	next

	//Calcula o DV
	nDV := (( Int(nSoma / 10) + 1 ) * 10 ) - nSoma
	
	//Retorna .T. se o digito calculado for igual ao digitado
	if AllTrim( Str(nDV) ) = cDV
		lRet := .T.
	endif

elseif Empty(cCodBar)

	lRet := .T.

endif

if !lRet .and. !lAutom
	MsgBox("Código de barras EAN13 inválido. O número deverá possuir 13 posições sendo o último dígito o DV.", "Atenção", "ERRO")
endif

Return(lRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		EAN13VAL                                                      /@
@type				User Function                                                 /@
@date				31/08/2012                                                    /@
@description	Busca a transportadora que atende a situação descrita, 
					utilizando o seguinte criterio:
					1o. Busca registro utilizando um cliente e loja especifico
					2o. Busca registro utilizando um cliente sem loja especifica
					3o. Busca registro utilizando o codigo de municipio         
					4o. Busca registro utilizando uma UF especifica             

					Sintaxe: cRetorno := U_FindTraUF(cCliente, cLoja, cCodMun, cEst)
					Retorno: Esperado o codigo de transportadora                  /@
@author			Adalberto Moreno Batista                                      /@
@use				Especifico Brasitech (Grupo Gama Italy)                       /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function FindTraUF(cCliente,cLoja,cCodMun,cEst)
Local cRet	:= Space(6)
Local nTCli	:= Len(SA1->A1_COD)
Local nTLoj	:= Len(SA1->A1_LOJA)
Local nTMun	:= Len(SA1->A1_COD_MUN)
Local nTEst	:= Len(SA1->A1_EST)

Default cCliente	:= Space( nTCli )
Default cLoja		:= Space( nTLoj )
Default cCodMun		:= Space( nTMun )
Default cEst		:= Space( nTEst )

SZD->( dbSetOrder(1) )		//ZD_FILIAL+ZD_CLIENTE+ZD_LOJA+ZD_CODMUN+ZD_EST

//1-Busca utilizando cliente e loja
if Empty(cRet) .and. !Empty(cCliente) .and. !Empty(cLoja)
	if SZD->( dbSeek( xFilial("SZD") + cCliente + cLoja ) )
		cRet := SZD->ZD_TRANSP
	endif
endif

//2-Busca utilizando cliente sem loja
if Empty(cRet) .and. !Empty(cCliente)
	if SZD->( dbSeek( xFilial("SZD") + cCliente + space(nTLoj) ) )
		cRet := SZD->ZD_TRANSP
	endif
endif
		
//3-Busca utilizando codigo do municipio
if Empty(cRet) .and. !Empty(cCodMun)
	if SZD->( dbSeek( xFilial("SZD") + space(nTCli + nTLoj) + cCodMun ) )
		cRet := SZD->ZD_TRANSP
	endif
endif

//4-Busca utilizando UF
if Empty(cRet) .and. !Empty(cEst)
	if SZD->( dbSeek( xFilial("SZD") + space(nTCli + nTLoj +nTMun) + cEst ) )
		cRet := SZD->ZD_TRANSP
	endif
endif

Return(cRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		VldC5Tra                                                      /@
@type				User Function                                                 /@
@date				03/09/2012                                                    /@
@description	Valida transportadora digitada no pedido de vendas            /@
@author			Adalberto Moreno Batista - (Opção Um Consultoria)             /@
@use				Especifico Brasitech (Grupo Gama Italy)                       /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function VldC5Tra()
Local lRet	:= .T.
Local aArea	:= GetArea()
Local cVlTrans    := Getmv("BR_VLTRANS")

//somente se for empresa 01, filial 03 e tipo pedido diferente de devolucao e beneficiamento
if SM0->(M0_CODIGO+M0_CODFIL) = "0103" .and. !M->C5_TIPO $ "BD" .and. !Empty(M->C5_TRANSP)

	if !AllTrim(M->C5_TRANSP) $ cVlTrans .and. M->C5_TRANSP != SA1->(U_FindTraUF(A1_COD, A1_LOJA, A1_COD_MUN, A1_EST))
		if !l410Auto
			Help(" ", 1, "ATENÇÃO",, "Transportadora inválida! É permitido somente o uso de transportadoras cadastradas na amarração 'Transportadora x Estado'." + chr(13) + chr(10) + "(Específico Brasitech). ", 1)
		endif
		lRet := .F.
	endif

endif

RestArea(aArea)
Return(lRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		VldDocSer                                                     /@
@type				User Function                                                 /@
@date				28/05/2013                                                    /@
@description	Valida o número e série do documento                          /@
@author			Adalberto Moreno Batista - (Opção Um Consultoria)             /@
@use				Especifico Brasitech (Grupo Gama Italy)                       /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function VldDocSer(cDoc, cSer)
Local lRetDoc	:= .T.
Local lRetSer	:= .T.
Local lRet	:= .T.
Local nX

//Inicio a validacao somente se a nota nao for propria
if cFormul != "S"

	//validando o numero do documento
	if cDoc != Nil
		cDoc := AllTrim(cDoc)
		for nX := 1 to Len(cDoc)
			if !IsDigit(Substring(cDoc,nX,1))
				lRetDoc := .F.
				exit
			endif
		next
	endif
	
	//validando a serie do documento
	if cSer != Nil
		cSer := AllTrim(cSer)
		for nX := 1 to Len(cSer)
			if !LetterOrNum(Substring(cSer,nX,1))
				lRetSer := .F.
				exit
			endif
		next
	endif
	
	if !lRetDoc .and. lRet
		Help(" ", 1, "ATENÇÃO", , "O número do documento deve ser composto somente de números." + chr(13) + chr(10) + "(Específico Brasitech). ", 1)
		lRet := .F.
	endif
	
	if !lRetSer .and. lRet
		Help(" ", 1, "ATENÇÃO", , "A série do documento deve ser composta somente de números e/ou letras." + chr(13) + chr(10) + "(Específico Brasitech). ", 1)
		lRet := .F.
	endif

endif

Return(lRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		ExportXML                                                     /@
@type				User Function                                                 /@
@date				                                                              /@
@description	Exporta o XML das notas emitidas na empresa, buscando os dados
					no TSS.                                                       /@
@Sintaxe			ExportXML(cIdEnt, cSerie, cNotaIni, cNotaFim, dDataDe, 
								dDataAte, cCnpjDIni, cCnpjDFim, cDirDest, cExtensao)
					<cIdEnt>  - Id da entidade geradora da NFe e gravado nas
									tabelas do banco SPED (obrigatorio)         
					<cSerie>  - Serie da nota fiscal                        
					<cNFde>   - Numero da nota fiscal inicial (obrigatorio) 
					<cNFate>  - Numero da nota fiscal final. Caso nao seja  
					            preenchido, considero o mesmo numero da nota
					            fiscal inicial                              
					<dEmiDe>  - Data de emissao de                          
					<dEmiAte> - Data de emissao ate                         
					<cCNPJde> - CNPJ de                                     
					<cCNPJate>- CNPJ ate                                    
					<cDirDest>- Diretorio onde o XML sera gravado (obrigatorio)
					<cExtensao>-Extensao do arquivo XML                           /@
@author			Adalberto Moreno Batista - (Opção Um Consultoria)             /@
@use				Especifico Brasitech (Grupo Gama Italy)                       /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function ExportXML(cIdEnt, cSerie, cNotaIni, cNotaFim, dDataDe, dDataAte, cCnpjDIni, cCnpjDFim, cDirDest, cPrefixo)
Local aDeleta		:= {}
Local nHandle		:= 0
Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cChvNFe		:= ""
Local cDestino		:= ""
Local cDrive		:= ""
Local cModelo		:= ""
Local cParteNome	:= ""
Local cCNPJDEST	:= Space(14)                
Local cNFes			:= ""
Local cIdflush		:= cSerie + cNotaIni
Local cXmlInut		:= ""
Local cXml			:= ""
Local cAnoInut		:= ""
Local cAnoInut1	:= ""
Local nX				:= 0 
Local lOk			:= .F.
Local lFlush		:= .T.
Local lFinal		:= .F.
Local cExtensao	:= ".xml"
Local oWS, oRetorno, oXML

//———————————————————————————————————————————————————————————————————————————————
// Ajustando as variaveis de parametros recebidos
//———————————————————————————————————————————————————————————————————————————————
cNotaFim		:= iif(cNotaFim == NIL, cNotaIni, cNotaFim)
dDataDe		:= iif(dDataDe == NIL, cTOd(""), dDataDe)
dDataAte		:= iif(dDataAte == NIL, cTOd(""), dDataAte)
cCnpjDIni	:= iif(cCnpjDIni == NIL, Space(14), cCnpjDIni)
cCnpjDFim	:= iif(cCnpjDFim == NIL, Space(14), cCnpjDFim)
cPrefixo		:= iif(cPrefixo == NIL, "", cPrefixo)

ProcRegua(Val(cNotaFim) - Val(cNotaIni))

//———————————————————————————————————————————————————————————————————————————————
// Corrigi diretorio de destino
//———————————————————————————————————————————————————————————————————————————————
SplitPath(cDirDest, @cDrive, @cDestino, "", "")
cDestino		:= cDrive + cDestino

//———————————————————————————————————————————————————————————————————————————————
// Inicia processamento
//———————————————————————————————————————————————————————————————————————————————
Do While lFlush
		oWS							:= WSNFeSBRA():New()
		oWS:cUSERTOKEN				:= "TOTVS"
		oWS:cID_ENT					:= cIdEnt 
		oWS:_URL						:= AllTrim(cURL)+"/NFeSBRA.apw"
		oWS:cIdInicial				:= cIdflush // cNotaIni
		oWS:cIdFinal				:= cSerie+cNotaFim
		oWS:dDataDe					:= dDataDe
		oWS:dDataAte				:= dDataAte
		oWS:cCNPJDESTInicial		:= cCnpjDIni
		oWS:cCNPJDESTFinal		:= cCnpjDFim
		oWS:nDiasparaExclusao	:= 0
		lOk							:= oWS:RETORNAFX()
		oRetorno						:= oWS:oWsRetornaFxResult
	
		If lOk
			ProcRegua(Len(oRetorno:OWSNOTAS:OWSNFES3))
			
			//———————————————————————————————————————————————————————————————————————————————
			// Exporta as notas                                                       
			//———————————————————————————————————————————————————————————————————————————————
			For nX := 1 To Len(oRetorno:OWSNOTAS:OWSNFES3)
		    
		 		oXml		:= oRetorno:OWSNOTAS:OWSNFES3[nX]
				oXmlExp	:= XmlParser(oRetorno:OWSNOTAS:OWSNFES3[nX]:OWSNFE:CXML,"","","")
				cXML		:= "" 
				If Type("oXmlExp:_NFE:_INFNFE:_DEST:_CNPJ")<>"U" 
					cCNPJDEST := AllTrim(oXmlExp:_NFE:_INFNFE:_DEST:_CNPJ:TEXT)
				ElseIF Type("oXmlExp:_NFE:_INFNFE:_DEST:_CPF")<>"U"
					cCNPJDEST := AllTrim(oXmlExp:_NFE:_INFNFE:_DEST:_CPF:TEXT)
				Else
	    			cCNPJDEST := ""
    			EndIf	
  				cVerNfe := IIf(Type("oXmlExp:_NFE:_INFNFE:_VERSAO:TEXT") <> "U", oXmlExp:_NFE:_INFNFE:_VERSAO:TEXT, '')                                 
  				cVerCte := Iif(Type("oXmlExp:_CTE:_INFCTE:_VERSAO:TEXT") <> "U", oXmlExp:_CTE:_INFCTE:_VERSAO:TEXT, '')
		 		If !Empty(oXml:oWSNFe:cProtocolo)
			    	cNotaIni := oXml:cID	 		
					cIdflush := cNotaIni
			 		cNFes 	:= cNFes+cNotaIni+chr(13) + chr(10)
			 		cChvNFe  := NfeIdSPED(oXml:oWSNFe:cXML,"Id")	 			
					cModelo 	:= cChvNFe
					cModelo 	:= StrTran(cModelo,"NFe","")
					cModelo 	:= StrTran(cModelo,"CTe","")
					cModelo 	:= SubStr(cModelo,21,02)
					
					Do Case
						Case cModelo == "57"
							cParteNome := "CTe"
						OtherWise
							cParteNome := "NFe"
					EndCase	 				
					
		 			nHandle := FCreate(cDestino + cPrefixo + SubStr(cChvNFe,4,44) + "-" + cParteNome + cExtensao)		//".xml")
		 			If nHandle > 0
		 				cCab1 := '<?xml version="1.0"?>'
		 				If cModelo == "57"
							cCab1  += '<cteProc xmlns="http://www.portalfiscal.inf.br/cte" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.portalfiscal.inf.br/cte procCTe_v'+cVerCte+'.xsd" versao="'+cVerCte+'">'
							cRodap := '</cteProc>'
						Else
							Do Case
								Case cVerNfe <= "1.07"
									cCab1 += '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.portalfiscal.inf.br/nfe procNFe_v1.00.xsd" versao="1.00">'
								Case cVerNfe >= "2.00" .And. "cancNFe" $ oXml:oWSNFe:cXML
									cCab1 += '<procCancNFe xmlns="http://www.portalfiscal.inf.br/nfe" versao="' + cVerNfe + '">'
								OtherWise
									cCab1 += '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="' + cVerNfe + '">'
							EndCase
							cRodap := '</nfeProc>'
						EndIf
						FWrite(nHandle,AllTrim(cCab1))							
			 			FWrite(nHandle,AllTrim(oXml:oWSNFe:cXML))
			 			FWrite(nHandle,AllTrim(oXml:oWSNFe:cXMLPROT))
						FWrite(nHandle,AllTrim(cRodap))	 
			 			FClose(nHandle)
			 			aadd(aDeleta,oXml:cID)
			 			cXML := AllTrim(cCab1)+AllTrim(oXml:oWSNFe:cXML)+AllTrim(cRodap)
			 			
			 		EndIf					
			 	EndIf
			 	
			 	If oXml:OWSNFECANCELADA<>Nil .And. !Empty(oXml:oWSNFeCancelada:cProtocolo)
				 	cChvNFe  := NfeIdSPED(oXml:oWSNFeCancelada:cXML,"Id")
				 	cNotaIni := oXml:cID	 		
					cIdflush := cNotaIni
			 		cNFes		:= cNFes + cNotaIni + chr(13) + chr(10)
				 	If !"INUT"$oXml:oWSNFeCancelada:cXML
			 			nHandle := FCreate(cDestino+SubStr(cChvNFe,3,44)+"-ped-can"+cExtensao)		//.xml")
			 			If nHandle > 0
				 			FWrite(nHandle,oXml:oWSNFeCancelada:cXML)
				 			FClose(nHandle)
				 			aadd(aDeleta,oXml:cID)
				 		EndIf
			 			nHandle := FCreate(cDestino+"\"+SubStr(cChvNFe,3,44)+"-can."+cExtensao)		//xml")
			 			If nHandle > 0
				 			FWrite(nHandle,oXml:oWSNFeCancelada:cXMLPROT)
				 			FClose(nHandle)
				 		EndIf
				 	Else 
						
//						If Type("oXml:OWSNFECANCELADA:CXML")<>"U"
					 	    cXmlInut  := oXml:OWSNFECANCELADA:CXML
					 	    cAnoInut1 := At("<ano>",cXmlInut)+5
					 	    cAnoInut  := SubStr(cXmlInut,cAnoInut1,2)
//					 	EndIf
			 			nHandle := FCreate(cDestino+SubStr(cChvNFe,3,2)+cAnoInut+SubStr(cChvNFe,5,38)+"-ped-inu."+cExtensao)		//xml")
			 			If nHandle > 0
				 			FWrite(nHandle,oXml:oWSNFeCancelada:cXML)
				 			FClose(nHandle)
				 			aadd(aDeleta,oXml:cID)
				 		EndIf
			 			nHandle := FCreate(cDestino+"\"+cAnoInut+SubStr(cChvNFe,5,38)+"-inu."+cExtensao)		//xml")
			 			If nHandle > 0
				 			FWrite(nHandle,oXml:oWSNFeCancelada:cXMLPROT)
				 			FClose(nHandle)
				 		EndIf		 	
				 	EndIf
				EndIf
				IncProc()
		    Next nX

			//———————————————————————————————————————————————————————————————————————————————
			// Exclui as notas
			//———————————————————————————————————————————————————————————————————————————————
			If !Empty(aDeleta) .And. GetNewPar("MV_SPEDEXP",0)<>0
				oWS:= WSNFeSBRA():New()
				oWS:cUSERTOKEN        := "TOTVS"
				oWS:cID_ENT           := cIdEnt
				oWS:nDIASPARAEXCLUSAO := GetNewPar("MV_SPEDEXP",0)
				oWS:_URL              := AllTrim(cURL)+"/NFeSBRA.apw"		
				oWS:oWSNFEID          := NFESBRA_NFES2():New()
				oWS:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
			    For nX := 1 To Len(aDeleta)	    
					aadd(oWS:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
					Atail(oWS:oWSNFEID:oWSNotas:oWSNFESID2):cID := aDeleta[nX]
			    Next nX
				If !oWS:RETORNANOTAS()
					Help(" ", 1, "SPED", , iif(Empty(GetWscError(3)), GetWscError(1), GetWscError(3)) + chr(13) + chr(10) + "(Específico Brasitech)", 1)
					lFlush := .F.	
				EndIf
			EndIf
			aDeleta  := {}
		    If Len(oRetorno:OWSNOTAS:OWSNFES3) == 0 .and. Empty(cNfes)
			   	Help(" ", 1, "SPED", , "Não há dados." + chr(13) + chr(10) + "(Específico Brasitech). ", 1)
				lFlush := .F.
		    EndIf
		Else
			Help(" ", 1, "SPED", , iif(Empty(GetWscError(3)), GetWscError(1), GetWscError(3)) + chr(13) + chr(10) + "(Específico Brasitech)", 1)
			lFinal := .T.
		EndIf

		cIdflush := AllTrim(Substr(cIdflush,1,3) + StrZero((Val( Substr(cIdflush,4,Len(AllTrim(mv_par02))))) + 1 ,Len(AllTrim(mv_par02))))
		If cIdflush <= AllTrim(cNotaIni) .Or. Len(oRetorno:OWSNOTAS:OWSNFES3) == 0 .Or. Empty(cNfes) .Or. ;
		   cIdflush <= Substr(cNotaIni,1,3)+Replicate('0',Len(AllTrim(mv_par02))-Len(Substr(Rtrim(cNotaIni),4)))+Substr(Rtrim(cNotaIni),4)// Importou o range completo
			lFlush := .F.
		EndIf
EndDo

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		GetCodEnt                                                     /@
@type				User function                                                 /@
@date				                                                              /@
@description	Obtem o codigo da entidade apos enviar o post para o TSS
					Retorno-> ExpC1: Codigo da entidade no TSS                    /@
@author			Adalberto Moreno Batista - Opção Um Consultoria               /@
@use				Especifico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function GetCodEnt()
Local aArea  := GetArea()
Local cIdEnt := ""
Local cURL   := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local oWs

//———————————————————————————————————————————————————————————————————————————————
// Obtem o codigo da entidade
//———————————————————————————————————————————————————————————————————————————————
oWS := WsSPEDAdm():New()
oWS:cUSERTOKEN := "TOTVS"
	
oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")
oWS:oWSEMPRESA:cCPF        := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM	
oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
oWS:oWSEMPRESA:cFANTASIA   := SM0->M0_NOME
oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
oWS:oWSEMPRESA:cCOD_PAIS   := "1058"
oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
oWS:oWSEMPRESA:cCEP_CP     := Nil
oWS:oWSEMPRESA:cCP         := Nil
oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(SM0->M0_TEL)[2],3)
oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
oWS:oWSEMPRESA:cEMAIL      := UsrRetMail(RetCodUsr())
oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
oWS:oWSEMPRESA:cNIT        := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
oWS:oWSEMPRESA:cINDSITESP  := ""
oWS:oWSEMPRESA:cID_MATRIZ  := ""
oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"
if oWs:ADMEMPRESAS()
	cIdEnt  := oWs:cADMEMPRESASRESULT
else
	Help(" ", 1, "SPED",, iif(Empty(GetWscError(3)), GetWscError(1), GetWscError(3)) + chr(13) + chr(10) + "(Específico Brasitech)", 1)
endif

RestArea(aArea)

Return(cIdEnt)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		EditCUSGAMA                                                   /@
@type				User function                                                 /@
@date				01/07/2013                                                    /@
@description	Habilita ou nao o campo D1_CUSGAMA para que seja digitado
					algum valor.
					Retorno: .T./.F.                                              /@
@author			Adalberto Moreno Batista - Opção Um Consultoria               /@
@use				Especifico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function EditCusGama()
Local lRet	 		:= .F.
Local cCFOPcusto	:= GetMV("BR_CFOPCUS", .F., "")
Local nPosCF		:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "D1_CF"})
Local nPosTES		:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "D1_TES"})
Local aArea, aAreaSF4

//Verifico se o CFOP esta preenchido no parametro especifico
if AllTrim(aCols[n, nPosCF]) $ cCFOPcusto
	aArea		:= GetArea()
	aAreaSF4	:= SF4->(GetArea())

	SF4->( dbSetOrder(1) )
	if SF4->( dbSeek(xFilial("SF4") + aCols[n, nPosTES]) )

		//Verifico se o TES controle estoque
		if SF4->F4_ESTOQUE == "S"
			lRet	:= .T.
		endif
		
	endif

	RestArea(aAreaSF4)
	RestArea(aArea)
endif

Return(lRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		GISendMail                                                    /@
@type			User function                                                 /@
@date			08/07/2013                                                    /@
@description	Função para envio de e-mails                                  /@
@Sintaxe		GISendMail(cDestin, cCCO, cAssunto, cTexto, cAnexo)           
				cDestin - Endereco dos e-mails destinatarios, separados por   
				          ponto e virgula (obrigatorio)                       
				cCCO    - Endereco dos e-mails em copia oculta, separados por 
				          ponto e virgula (opcional)                          
				cAssunto- Descricao do assunto do e-mail (opcional)           
				cTexto  - Variavel contendo o texto para o corpo do e-mail.   
				cAnexo  - Variavel com o caminho e nome do arquivo que sera   
				          anexado ao e-mail (opcional)                        /@
@author			Adalberto Moreno Batista - Opção Um Consultoria               /@
@use			Especifico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function GISendMail(cDestinat, cCopiaOcult, cSubject, cMsgCorpo, cAnexo)
Local cServer	:= AllTrim( GetMV("MV_RELSERV", .F., "" ) )
Local cAccount	:= AllTrim( GetMV("MV_RELACNT", .F., "" ) )
Local cPassword	:= GetMV( "MV_RELAPSW", .F., "" )
Local lSSL		:= GetMV( "MV_RELSSL", .F., .F. )
Local lRelAuth	:= GetMV( "MV_RELAUTH",.F., .F. )
Local cErro		:= ""
Local cMsgErro	:= ""
Local lEnviado, lConectou, lAutentic

//———————————————————————————————————————————————————————————————————————————————
// Redefinindo variaveis recebidas como parametros 
//———————————————————————————————————————————————————————————————————————————————
cCopiaOcult	:= iif(cCopiaOcult == NIL, "", cCopiaOcult)
cSubject	:= iif(cSubject == NIL, "", cSubject)
cAnexo	 	:= iif(cAnexo == NIL, "", cAnexo)
cMsgCorpo 	:= iif(cMsgCorpo == NIL, "", cMsgCorpo)

//———————————————————————————————————————————————————————————————————————————————
// Verifico se ha destinatario                     
//———————————————————————————————————————————————————————————————————————————————
if !empty(cDestinat)                                                                             
	
	//———————————————————————————————————————————————————————————————————————————————
	// Verifico se a conexao necessita da instrucao SSL 
	//———————————————————————————————————————————————————————————————————————————————
	if lSSL
		CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword SSL RESULT lConectou
	else
		CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lConectou
	endif
	
	if lConectou

		//———————————————————————————————————————————————————————————————————————————————
		// Verifico se a conexao necessita de autenticacao 
		//———————————————————————————————————————————————————————————————————————————————
		if lRelAuth
			lAutentic := MailAuth(cAccount, cPassword)
		else
			lAutentic := .T.
		endif
	
		if lAutentic

			//———————————————————————————————————————————————————————————————————————————————
			// Verifico se existe anexo a ser enviado          
			//———————————————————————————————————————————————————————————————————————————————
			if Empty(cAnexo)
				SEND MAIL FROM cAccount TO cDestinat BCC cCopiaOcult SUBJECT cSubject BODY cMsgCorpo RESULT lEnviado
			else
				SEND MAIL FROM cAccount TO cDestinat BCC cCopiaOcult SUBJECT cSubject BODY cMsgCorpo ATTACHMENT cAnexo RESULT lEnviado
			endif
	
			if !lEnviado
				GET MAIL ERROR cErro
				cMsgErro := "GISendMail-> Erro no envio: " + cErro

			endif
		
		else

			GET MAIL ERROR cErro
			cMsgErro := "GISendMail-> Erro na autenticação da conta: " + cErro

		endif
		
	else

		GET MAIL ERROR cErro
		cMsgErro := "GISendMail-> Erro na conexão com o servidor SMTP: " + cErro

	endif
				
	DISCONNECT SMTP SERVER

else

	cMsgErro := "GISendMail-> E-mail não enviado por falta do destinatário."

endif

Return(cMsgErro)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		GetHist                                                       /@
@type			User function                                                 /@
@date			13/08/2014                                                    /@
@description	Retorna o histórico	completo do lançamento contábil à partir
				de uma data, lote, sublote, documento e linha. Utilizado nos
				relatórios de conciliações contabeis.
				Recebe como referencia a variável do historico (@cHist)       /@
@author			Adalberto Moreno Batista - Opção Um Consultoria               /@
@use			Especifico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function GetHist(cChave, cLinha, cHist)

CT2->(dbSetOrder(1))

if CT2->(dbSeek(xFilial("CT2") + cChave + cLinha))

	cHist := CT2_HIST
	CT2->(dbSkip())
	
	do while CT2->(!eof() .and. CT2_FILIAL  == xFilial("CT2") .and. dTOs(CT2_DATA) + CT2_LOTE + CT2_SBLOTE + CT2_DOC == cChave)
		if CT2->CT2_DC == "4"	//continuação de historico
			cHist += CT2->CT2_HIST
		else
			exit
		endif
		CT2->(dbSkip())
	enddo
	
endif

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		GetSX1Excel                                                   /@
@type			User function                                                 /@
@date			17/09/2014                                                    /@
@description	Retorna array bidimensional com perguntas e respostas dos 
				parametros de um respectivo grupo de perguntas                /@
@author			Adalberto Moreno Batista - Opção Um Consultoria               /@
@use			Especifico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function GetSX1Excel(cPerg)
Local aRet 		:= {}
Local aArea		:= GetArea()
Local aAreaSX1	:= SX1->(GetArea())

SX1->(dbSetOrder(1))
SX1->(dbSeek(cPerg))
do while SX1->(!eof() .and. AllTrim(X1_GRUPO) == AllTrim(cPerg))
	
	if SX1->X1_GSC == "C" //combo
		cConteudo := "SX1->X1_DEF" + StrZero(SX1->&X1_VAR01, 2)
		cConteudo := &cConteudo
	else
		cConteudo := SX1->&X1_VAR01
	endif
	
	aAdd(aRet, {SX1->X1_PERGUNT, cConteudo})
	
	SX1->(dbSkip())
	
enddo

RestArea(aAreaSX1)
RestArea(aArea)
Return(aRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		SE2DtvcVlr                                                    /@
@type			User Function                                                 /@
@date			22/09/2014                                                    /@
@description	Valida se o código de barras informado refere-se ao respectivo
				título, comparando a data de vencimento (E2_VENCTO) e o valor
				(E2_VALOR).                                                   /@
@author			Adalberto Moreno Batista - Opção Um Consultoria               /@
@use			Especifico Brasitech (Grupo Gama Italy)                       /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function SE2DtVcVlr(nE2Valor, dE2Vencto, cCodBar, lMostra)
Local lRet			:= .T.
Local dDtBase 		:= cTOd("07/10/97")
Local nVlrTit		:= 0
Local dDtVenc		:= cTOd("")
Local cNomeFunc		:= AllTrim(Upper(FunName()))
Local nPosVALOR		:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "E2_VALOR"})
Local nPosIRRF		:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "E2_IRRF"})
Local nPosPIS		:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "E2_PIS"})
Local nPosCOF		:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "E2_COFINS"})
Local nPosCSLL		:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "E2_CSLL"})
Local nPosVENCTO	:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "E2_VENCTO"})
Local nPosISS		:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "E2_ISS"})
Local nPosINSS		:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "E2_INSS"})

Default lMostra 	:= .T.	//iif(lMostra == NIL, .T., lMostra)

if !cNomeFunc$"MATA103#U_GATI001" .or. (cNomeFunc=="MATA103" .and. nPosVALOR>0 .and. nPosIRRF>0 .and. nPosPIS>0 .and. nPosCOF>0 .and. nPosCSLL>0 .and. nPosVENCTO>0 .and. nPosISS>0 .and. nPosINSS>0)

	cCodBar	:= AllTrim(cCodBar)

	if nE2Valor != NIL .and. dE2Vencto != NIL

		lF050Auto := .F.
		
	else

		if cNomeFunc=="MATA103" .or. cNomeFunc=="MATA116"
			nE2Valor  := aCols[n, nPosVALOR] - aCols[n, nPosIRRF] - aCols[n, nPosPIS] - aCols[n, nPosCOF] - aCols[n, nPosCSLL] - aCols[n, nPosISS] - aCols[n, nPosINSS]
			dE2Vencto := aCols[n, nPosVENCTO]
			lF050Auto := .F.
		else
			//———————————————————————————————————————————————————————————————————————————————
			// Manter a instrucao considerando valores de acrescimo ou descontos pois gerando
			// fatura de titulos a pagar ocasiona problema contábil.
			// Portanto, para pagamento em atraso não deveremos gerar uma fatura.
			//———————————————————————————————————————————————————————————————————————————————
			nE2Valor  := M->E2_VALOR + M->E2_ACRESC - M->E2_DECRESC - M->E2_IRRF - M->E2_ISS - M->E2_INSS - M->E2_PIS - M->E2_COFINS - M->E2_CSLL
	//		nE2Valor  :=0
			dE2Vencto := M->E2_VENCTO
		endif

	endif

	dDtVenc := dE2Vencto

	if Len(cCodBar) == 47			//Codigo de barras linha digitada
	
		if Substr(cCodBar, 34, 04) != "0000"
			dDtVenc := dDtBase + Val(Substr(cCodBar, 34, 04))
		endif
		nVlrTit := Val(Substr(cCodBar, 38, 10)) / 100
		
	elseif Len(cCodBar) == 44		//Codigo de barras leitor codigo
		
		if Substr(cCodBar, 06, 04) != "0000"
			dDtVenc := dDtBase + Val(Substr(cCodBar, 06, 04))
		endif
		nVlrTit := Val(Substr(cCodBar, 10, 10)) / 100
		
	elseif Len(cCodBar) == 48		//Codigo de barras de concessionárias e tributos
		
		nVlrTit	 := Val(Substr(cCodBar, 05, 07) + Substr(cCodBar, 13, 04)) / 100
		
	endif

	//Comparo o valor do titulo
	if nVlrTit > 0 .and. nVlrTit != nE2Valor
		lRet := .F.     
	endif

	//Comparo a data de vencimento
	// Retirada a validação de vencimento, conforme solicitado pelo Evandro em 01/09/22
	//if !empty(dDtVenc) .and. dDtVenc != dE2Vencto
	//	lRet := .F.    
	//endif

	if !lRet .and. !lF050Auto .and. lMostra
		Help(" ", 1, "ATENÇÃO",, "O valor do título não correspondem ao informado neste código de barras." + chr(13) + chr(10) +;
										"Valor do título no código de barras: " + AllTrim(Transf(nVlrTit, "@E 999,999,999.99")) + chr(13) + chr(10) +; 
										"Valor Calculado-Impostos : " + AllTrim(Transf(nE2Valor, "@E 999,999,999.99")) + chr(13) + chr(10) +; 
										iif(!empty(dDtVenc) .and. dDtVenc!=dE2Vencto, "Data de vencto no código de barras: " + AllTrim(dTOc(dDtVenc)) + chr(13) + chr(10) + "Vencto no Titulo: "+  AllTrim(dTOc(dE2Vencto))+ chr(13) + chr(10), "") +;
										"(Específico " + AllTrim(SM0->M0_NOME) + ")", 1)
	endif

endif

Return(lRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		GP_Estabil                                                    /@
@type			User Function                                                 /@
@date			01/02/2016                                                    /@
@description	Calcula e grava a data de estabilidade de um funcionario, de
				acordo com a data final do afastamento, preenchido no cadastro
				de afastamentos. Função acionada pelos pontos de entrada 
				GP240MAN, GP030FER e GPM030EX                                 /@
@author			Adalberto Moreno Batista - Opção Um Consultoria               /@
@use			Especifico Brasitech (Grupo Gama Italy)                       /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function GP_Estabil()
Local aAreaSR8	:= SR8->(GetArea())
Local dDtEstab	:= cTOd("")		//SRA->RA_DTVTEST
Local cTpEstab	:= " "			//iif(SRA->(FieldPos("RA_X_TPEST")) > 0, SRA->RA_X_TPEST, " ")
Local dDtApoio	:= cTOd("")
Local cTpApoio	:= " "

//———————————————————————————————————————————————————————————————————————————————
// Pesquisa afastamentos
//———————————————————————————————————————————————————————————————————————————————
SR8->(dbSetOrder(2))			//R8_FILIAL, R8_MAT, R8_SEQ, R8_DATA, R8_TIPO
SR8->(dbSeek(xFilial("SR8") + SRA->RA_MAT))
do while SR8->(!eof() .and. R8_FILIAL == xFilial("SR8") .and. R8_MAT == SRA->RA_MAT)

	//———————————————————————————————————————————————————————————————————————————————
	// Processa registros somente se a data final do afastamento estiver preenchida
	//———————————————————————————————————————————————————————————————————————————————
	if !Empty(SR8->R8_DATAFIM)

		//———————————————————————————————————————————————————————————————————————————————
		// Regra 1 - Férias
		// Quando filial 03-São Paulo, a estabilidade será de 30 dias
		//———————————————————————————————————————————————————————————————————————————————
		if SRA->RA_FILIAL == "03" .and. SR8->R8_TIPO == "F"
		
			dDtApoio := SR8->R8_DATAFIM + 30
			if dDtApoio > dDtEstab
				dDtEstab := dDtApoio
				cTpEstab	:= "1"
			endif
		
		//———————————————————————————————————————————————————————————————————————————————
		// Regra 2 - Licença Maternidade ou Licença Gestante
		// Quando filial 03-São Paulo a estabilidade será de 75 dias
		//———————————————————————————————————————————————————————————————————————————————
		elseif SRA->RA_FILIAL == "03" .and. SR8->R8_TIPO $ "6/7/B/Q"
		
			dDtApoio := SR8->R8_DATAFIM + 75
			if dDtApoio > dDtEstab
				dDtEstab := dDtApoio
				cTpEstab	:= "2"
			endif

		//———————————————————————————————————————————————————————————————————————————————
		// Regra 6 - Licença Maternidade ou Licença Gestante
		// Quando filial 01-Manaus a estabilidade será de 60 dias
		//———————————————————————————————————————————————————————————————————————————————
		elseif SRA->RA_FILIAL == "01" .and. SR8->R8_TIPO $ "6/7/B/Q"
		
			dDtApoio := SR8->R8_DATAFIM + 60
			if dDtApoio > dDtEstab
				dDtEstab := dDtApoio
				cTpEstab	:= "2"
			endif

		//———————————————————————————————————————————————————————————————————————————————
		// Regra 3 - Afastamento por Doença
		// Quando filial 03-São Paulo, 03-Sindicato dos Farmaceuticos SP e o tempo de 
		// afastamento for maior que 15 dias, a estabilidade será de 60 dias
		//———————————————————————————————————————————————————————————————————————————————
		elseif SRA->RA_FILIAL == "03" .and. SRA->RA_SINDICA == "03" .and. SR8->R8_TIPO $ "P" .and. SR8->(R8_DATAFIM - R8_DATAINI + 1) > 15
		
			dDtApoio := SR8->R8_DATAFIM + 60
			if dDtApoio > dDtEstab
				dDtEstab := dDtApoio
				cTpEstab	:= "3"
			endif
		
		//———————————————————————————————————————————————————————————————————————————————
		// Regra 4 - Afastamento por Doença
		// Quando filial 03-São Paulo, outros sindicatos e o tempo de afastamento for
		// maior que 15 dias, a estabilidade será de 30 dias
		//———————————————————————————————————————————————————————————————————————————————
		elseif SRA->RA_FILIAL == "03" .and. SRA->RA_SINDICA != "03" .and. SR8->R8_TIPO $ "P" .and. SR8->(R8_DATAFIM - R8_DATAINI + 1) > 15
		
			dDtApoio := SR8->R8_DATAFIM + 30
			if dDtApoio > dDtEstab
				dDtEstab := dDtApoio
				cTpEstab	:= "3"
			endif
		
		//———————————————————————————————————————————————————————————————————————————————
		// Regra 5 - Acidente de Trabalho
		// Quanto o tempo de afastamento for maior que 15 dias, a estabilidade será de 
		// 365 dias
		//———————————————————————————————————————————————————————————————————————————————
		elseif SR8->R8_TIPO $ "O" .and. SR8->(R8_DATAFIM - R8_DATAINI + 1) > 15
		
			dDtApoio := SR8->R8_DATAFIM + 365
			if dDtApoio > dDtEstab
				dDtEstab := dDtApoio
				cTpEstab	:= "4"
			endif

		endif

	endif
		
	SR8->(dbSkip())
	
enddo


//———————————————————————————————————————————————————————————————————————————————
// Pesquisa histórico de campos da tabela de funcionários
//———————————————————————————————————————————————————————————————————————————————
cTpApoio	:= " "
dDtApoio	:= cTOd("")
SR9->(dbSetOrder(2))			//R9_FILIAL, R9_MAT, R9_DATA, R9_CAMPO
SR9->(dbSeek(xFilial("SR9") + SRA->RA_MAT))
do while SR9->(!eof() .and. R9_FILIAL == xFilial("SR9") .and. R9_MAT == SRA->RA_MAT)
	if AllTrim(SR9->R9_CAMPO) == "RA_DTVTEST"
		dDtApoio	:= cTOd(AllTrim(SR9->R9_DESC))
	endif
	if AllTrim(SR9->R9_CAMPO) == "RA_X_TPEST" .and. !AllTrim(SR9->R9_DESC) $ " .1.2.3.4"
		cTpApoio	:= AllTrim(SR9->R9_DESC)
	endif
	
	SR9->(dbSkip())
enddo

//———————————————————————————————————————————————————————————————————————————————
// Verifica se há preenchimento manual da data de estabilidade e se ela é maior
// do que a apurada nos afastamentos
//———————————————————————————————————————————————————————————————————————————————
if !empty(cTpApoio) .and. dDtApoio > dDtEstab
	dDtEstab	:= dDtApoio
	cTpEstab	:= cTpApoio
endif


//———————————————————————————————————————————————————————————————————————————————
// Gravo a informação da data de estabilidade apurada e tipo no cadastro do 
// funcionário. Tipos válidos 1-Ferias, 2-Maternidade, 3-Doença ou 4-Acidente de 
// trabalho
//———————————————————————————————————————————————————————————————————————————————
SRA->(RecLock("SRA", .F.))
SRA->RA_DTVTEST := dDtEstab
if SRA->(FieldPos("RA_X_TPEST")) > 0
	SRA->RA_X_TPEST := cTpEstab
endif
SRA->(MsUnLock())

RestArea(aAreaSR8)
Return()

/*/
———————————————————————————————————————————————————————————————————————————————
@function		VLDCDPRV                                                      /@
@type			User Function                                                 /@
@date			23/05/2016                                                    /@
@description	Valida o código do produto consultando o codigo provisório    /@
@author			Adalberto Moreno Batista - Opção Um Consultoria               /@
@use			Especifico Brasitech (Grupo Gama Italy)                       /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function VldCdPrv()
Local lRet	:= .T.

if SB1->(FieldPos("B1_XCODPRV")) > 0
	SB1->(dbOrderNickName("B1_XCODPRV"))	//B1_FILIAL, B1_XCODPRV
	if SB1->(dbSeek(xFilial("SB1") + M->B1_COD))
		lRet := .F.
		Help(" ", 1, "ATENÇÃO", , "Este código de produto não poderá ser utilizado. Escolha outro código de produto. (processo de automatização de codificação de produtos)" + chr(13) + chr(10) + "(Específico Brasitech)", 1)
	endif
	SB1->(dbSetOrder(1))							//B1_FILIAL, B1_COD
endif

Return(lRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		TPBLOQPV                                                      /@
@type			User Function                                                 /@
@date			05/09/2017                                                    /@
@description	Monta listbox do campo C5_XOBSBLQ com o conteúdo da tabela ZC /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Consultoria                                          /@
@use			Especifico Brasitech (Grupo Gama Italy)                       /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function TpBloqPV()
Local cRet	:= ""

if SX5->(dbSeek(xFilial("SX5") + "ZC"))
	do while SX5->(!Eof() .and. X5_FILIAL+X5_TABELA == xFilial("SX5") + "ZC")
		cRet += AllTrim(SX5->X5_CHAVE) + "=" + AllTrim(SX5->X5_DESCRI) + ";"
		SX5->(dbSkip())
	enddo
	cRet := Left(cRet, Len(cRet) - 1)
endif

Return(cRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		GenAttach                                                    /@
@type			User Function                                                /@
@date			28/12/2020                                                   /@
@description	Função genérica para adiciona arquivos aos processos de 
				solicitação de compras (SC), cotações (CO), contratos (CT),
				pedidos de compras (PC), notas fiscais (NF), títulos a pagar
				(CP) e Boletos (BO). Referência do diretorio \ANEXOS         /@
@author			Adalberto Moreno Batista (Opção Um Tecnologia da Informação) /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function GENATTACH(cNumControle, cParTipo, lEdit, aChave)
Local aExclui 		:= {}
Local aPermissao	:= {}
Local lPermissao	:= .T.
Local cTipo			:= Left(cParTipo, 2)
Local cDirAnexos	:= GetMV("BR_ANEXOPC")
Local oDlg, aBkpaCols, aBkpaHeader, nBkp, cAno, cMes, cContrato, lRestaura
Private cPathFile, nTamFilesDKT

//———————————————————————————————————————————————————————————————————————————————
// Tratamento para restauração ou inicialização aHeader e aCols
//———————————————————————————————————————————————————————————————————————————————
if Type("aCols") == "A" 
	aBkpaCols		:= aCols
	aBkpaHeader	    := aHeader
    nBkp			:= n
	lRestaura		:= .T.
else
	aCols 			:= {}
	aHeader 		:= {}
	n				:= 1
	lRestaura		:= .F.
endif

//———————————————————————————————————————————————————————————————————————————————
// Criando as pastas de ANEXOS
//———————————————————————————————————————————————————————————————————————————————
MakeDir(cDirAnexos)	//"\ANEXOS")

if cTipo == "CT" .or. cTipo == "ME"
	aPermissao	:= CN300VldUsr()
	//lPermissao	:= aPermissao[1] .or. aPermissao[7][aScan(aPermissao[7],{|x| x[1] == '047'})][2]
    cContrato	:= aChave[1]
	aCols		:= {}
	aHeader		:= {}
	n			:= 1

	MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt + "\CT")
	MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt + "\CT\" + cContrato)
	MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt + "\CT\" + cContrato + "\MEDICAO")

	//———————————————————————————————————————————————————————————————————————————————
	// Definindo o caminho dos anexos
	//———————————————————————————————————————————————————————————————————————————————
	cPathFile	:= cDirAnexos + "\" + cEmpAnt + cFilAnt + "\CT\" + cContrato + "\"
	if cTipo == "ME"
		cPathFile	+= "MEDICAO\"
		cTipo		:= "CT"
	endif

elseif cTipo == "CP"
    cAno			:= aChave[1]
    cMes			:= aChave[2]
//	aCols			:= {}
//	aHeader			:= {}
//	n				:= 1
    cPathFile		:= cDirAnexos + "\" + cTipo + "\" + cAno + "\mes_" + cMes + "\"
	//lPermissao		:= (AllTrim(SE2->E2_ORIGEM)=="FINA050")

    MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt + "\" + cTipo + "\" + cAno)
    MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt + "\" + cTipo + "\" + cAno + "\mes_" + cMes)

else

    cAno			:= aChave[1]
    cMes			:= aChave[2]
//		aBkpaCols		:= aCols
//		aBkpaHeader	    := aHeader
//	    nBkp			:= n
	if lEdit
    	cPathFile	:= cDirAnexos + "\" + cEmpAnt + cFilAnt + "\" + cTipo + "\temp\"
	else
		cPathFile	:= cDirAnexos + "\" + cEmpAnt + cFilAnt + "\" + cTipo + "\" + cAno + "\mes_" + cMes + "\"
	endif

    MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt + "\" + cTipo + "\temp")
    MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt + "\" + cTipo + "\" + cAno)
    MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt + "\" + cTipo + "\" + cAno + "\mes_" + cMes)
    
endif

//———————————————————————————————————————————————————————————————————————————————
// Verifica se há permissão
//———————————————————————————————————————————————————————————————————————————————
if lPermissao

	//———————————————————————————————————————————————————————————————————————————————
	// Carregando os anexos
	//———————————————————————————————————————————————————————————————————————————————
	GetAttachs(cNumControle)

	Define MsDialog oDlg Title OemtoAnsi("Arquivos vinculados ao processo ") From 005, 005 To 350, 780 Pixel						            //"Arquivos vinculados ao processo "
	@ 010, 010 To 150, 380 MultiLine
	@ 155,010 Button OemtoAnsi("+ Adiciona") Size 037,012 When lEdit Pixel Of oDlg Action U_AddFile(cNumControle)		//"+ Adiciona"
	@ 155,060 Button OemtoAnsi("- Remove") Size 037,012 When lEdit Pixel Of oDlg Action U_EraseFile(cNumControle)		//"- Remove"
	@ 155,110 Button OemtoAnsi("Abre") Size 037,012 PIXEL OF oDlg Action Open(@aExclui)							//"Abre"
	@ 155,340 Button OemtoAnsi("Encerra") Size 037,012 Pixel Of oDlg Action Close(oDlg)								//"Encerra"
	Activate MsDialog oDlg Centered

	//———————————————————————————————————————————————————————————————————————————————
	// Exclui os temporarios
	//———————————————————————————————————————————————————————————————————————————————
	if !Empty(aExclui)
		MsDocExclui(aExclui, .F.)
	endif 			

else

	Help(" ", 1, "ATENÇÃO",, "Usuário não possui permissão para realizar esta operação ou o registro não está apto para esta operação." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)

endif

//———————————————————————————————————————————————————————————————————————————————
// Restaura aHeader e aCols
//———————————————————————————————————————————————————————————————————————————————
if lRestaura
	aCols		:= aBkpaCols
	aHeader		:= aBkpaHeader
	n			:= nBkp
endif

Return()


	/*/
	———————————————————————————————————————————————————————————————————————————————
	@function		GetAttachs()                                                 /@
	@type			Static Function                                              /@
	@date			28/12/2020                                                   /@
	@description	Pesquisa os arquivos anexos ao pedido de compras no diretorio
					COTACOES                                                     /@
	@author			Adalberto Moreno Batista (Opção Um Consultoria)              /@
	@use			Brasitech                                                    /@
	———————————————————————————————————————————————————————————————————————————————
	/*/
	Static Function GetAttachs(cNumControle)	//,cTipo)
	Local aFiles	:= Directory(cPathFile + cFilAnt + "_" + AllTrim(cNumControle) + "_" + "*.*")
	Local nX
	//{"Tipo", "AA4_CODCLI", "", 004,0, ".F.",, "C",},;
	n 				:= 1
	aCols			:= {{Space(4),Space(50), .F.}}
	aHeader			:= {{"Arquivo", "AA4_CODCLI", "", 170,0, ".F.",, "C",}}		//"Arquivo"		//o campo escolhido serve somente para aproveitar o when do dicionario de dados
	nTamFilesDKT 	:= 0
	
	if Len(aFiles) > 0
		aCols := {}
		for nX := 1 to Len(aFiles)
			aAdd(aCols, {aFiles[nX,1], .F.})
			nTamFilesDKT += aFiles[nX,2]
		next
	endif
	
	Return()


	/*/
	———————————————————————————————————————————————————————————————————————————————
	@function		AddFile()                                                    /@
	@type			Static Function                                              /@
	@date			28/12/2020                                                   /@
	@description	Adiciona arquivos vinculados ao pedido de compras no diretorio
					COTACOES                                                     /@
	@author			Adalberto Moreno Batista (Opção Um Consultoria)              /@
	@use			Brasitech                                                    /@
	———————————————————————————————————————————————————————————————————————————————
	/*/
	User Function AddFile(cNumControle)
	Local nDrvNet		:= 32
	Local nDrvLoc		:= 16
	Local cArqOrig		:= cGetFile("PDFs|*.pdf|Todos os Arquivos|*.*", OemToAnsi("Selecione o arquivo"),,,,nDrvNet + nDrvLoc)							//"PDFs|*.pdf|Todos os Arquivos|*.*"#"Selecione o arquivo"
	Local cArqName		:= ""
	Local lContinua		:= .T.
	Local cString		:= "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ _-[]#."
	Local nK, cArqDest, cParte, cArqOrigOk
	
	if !Empty(cArqOrig)
		
        cArqOrigOk		:= cArqOrig
        cArqOrig		:= U_ClearString(cArqOrig)
        
        if !empty(cArqOrig)
            
            for nK := Len(cArqOrig) to 1 step -1
                cParte := Substr(cArqOrig, nK, 1)
                if cParte == "\"
                    exit
                elseif !cParte $ cString
                    cParte := ""
                endif
                cArqName := cParte + cArqName
            next
        
            cArqDest := cPathFile + cFilAnt + "_" + cNumControle + "_" + cArqName
    
            if Len(cArqName) > 157
                Help(,, "® ATENÇÃO",, "O nome do arquivo pode ter no máximo 150 caracteres.", 1)			  						//"® ATENÇÃO"#"O nome do arquivo pode ter no máximo 150 caracteres."
                lContinua := .F.
            endif
            
            if file(cArqDest)
                if !MsgBox("Arquivo já vinculado ao respectivo ao processo. Deseja gravá-lo novamente?", "® ATENÇÃO", "YESNO")							//#"® ATENÇÃO"#"Arquivo já vinculado ao respectivo pedido de compras. Deseja gravá-lo novamente?"
                    lContinua := .F.
                endif
            endif
            
            if lContinua
                __CopyFile(cArqOrigOk, cArqDest)
            
                if File(cArqDest)
                    GetAttachs(cNumControle)
                else
                    Help(,, "® ATENÇÃO",, "O arquivo " + cArqDest + " não foi copiado corretamente. Repita a operação.", 1)			//"® ATENÇÃO"#"O arquivo "#" não foi copiado corretamente. Repita a operação."
                endif
            endif
        
        endif
		
	endif
	Return()


	/*/
	———————————————————————————————————————————————————————————————————————————————
	@function		EraseFile()                                                  /@
	@type			Static Function                                              /@
	@date			28/12/2020                                                   /@
	@description	Exclui arquivos vinculados ao pedido de compras no diretório
					ANEXOS_PC                                                    /@
	@author			Adalberto Moreno Batista (Opção Um Consultoria)              /@
	@use			Brasitech                                                    /@
	———————————————————————————————————————————————————————————————————————————————
	/*/
	User Function EraseFile(cNumControle)
	fErase(cPathFile + AllTrim(aCols[n,1]))
	GetAttachs(cNumControle)
	Return()


	/*/
	———————————————————————————————————————————————————————————————————————————————
	@function		Open()                                                       /@
	@type			Static Function                                              /@
	@date			28/12/2020                                                   /@
	@description	Abre arquivos vinculados ao pedido de compras no diretorio
					ANEXOS_PC                                                    /@
	@author			Adalberto Moreno Batista (Opção Um Consultoria)              /@
	@use			Brasitech                                                    /@
	———————————————————————————————————————————————————————————————————————————————
	/*/
	Static Function Open(aExclui)
	Local cDirDocs		:= cPathFile											//Retira a ultima barra invertida, se houver:  MsDocRmvBar(cDirDocs)
	Local cFile			:= AllTrim(aCols[n,1])
	Local cPathFile		:= Lower(cDirDocs + cFile)
	Local cPathTerm		:= Lower(GetTempPath() + cFile)
	Local cAcao			:= "open"												//"print", "explore"
	Local cParLinha		:= ""
	Local cDir			:= ""
	Local lCopied

	//———————————————————————————————————————————————————————————————————————————————
	// Transfere o arquivo para o diretorio de trabalho do Windows
	//———————————————————————————————————————————————————————————————————————————————
	Processa({|| lCopied := __CopyFile(cPathFile, cPathTerm)}, "Transferindo objeto", "Aguarde...", .F.)		//"Transferindo objeto", "Aguarde..."

	if lCopied .or. File(cPathTerm)
		if ShellExecute(cAcao, cPathTerm, cParLinha, cDir, 1) <= 32
			Help(,, "® ATENÇÃO",, "Não foi possível efetuar a transferência do arquivo para a área de trabalho!" + " (" + cFile + ")", 1)						//"® ATENÇÃO"#"Não foi possível efetuar a transferência do arquivo '"#"' para a área de trabalho !"
		EndIf			
	endif

	if Empty(AScan(aExclui, cPathTerm))
		aAdd(aExclui, cPathTerm)
	endif

	Return(.T.)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		ClearString                                                  /@
@type			Static Function                                              /@
@date			28/12/2020                                                   /@
@description	Retira caracteres especiais do nome do arquivo, aque será 
				anexado.                                                     /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function ClearString(cString)

cString := StrTran(cString, "á", "a")
cString := StrTran(cString, "à", "a")
cString := StrTran(cString, "ä", "a")
cString := StrTran(cString, "â", "a")
cString := StrTran(cString, "ã", "a")

cString := StrTran(cString, "é", "e")
cString := StrTran(cString, "è", "e")
cString := StrTran(cString, "ë", "e")
cString := StrTran(cString, "ê", "e")

cString := StrTran(cString, "í", "i")
cString := StrTran(cString, "ì", "i")
cString := StrTran(cString, "ï", "i")
cString := StrTran(cString, "î", "i")

cString := StrTran(cString, "ó", "o")
cString := StrTran(cString, "ò", "o")
cString := StrTran(cString, "ö", "o")
cString := StrTran(cString, "ô", "o")
cString := StrTran(cString, "õ", "o")

cString := StrTran(cString, "ú", "u")
cString := StrTran(cString, "ù", "u")
cString := StrTran(cString, "ü", "u")
cString := StrTran(cString, "û", "u")

cString := StrTran(cString, "ç", "c")

cString := StrTran(cString, "Á", "A")
cString := StrTran(cString, "À", "A")
cString := StrTran(cString, "Ä", "A")
cString := StrTran(cString, "Â", "A")
cString := StrTran(cString, "Ã", "A")

cString := StrTran(cString, "É", "E")
cString := StrTran(cString, "È", "E")
cString := StrTran(cString, "Ë", "E")
cString := StrTran(cString, "Ê", "E")

cString := StrTran(cString, "Í", "I")
cString := StrTran(cString, "Ì", "I")
cString := StrTran(cString, "Ï", "I")
cString := StrTran(cString, "Î", "I")

cString := StrTran(cString, "Ó", "O")
cString := StrTran(cString, "Ò", "O")
cString := StrTran(cString, "Ö", "O")
cString := StrTran(cString, "Ô", "O")
cString := StrTran(cString, "Õ", "O")

cString := StrTran(cString, "Ú", "U")
cString := StrTran(cString, "Ù", "U")
cString := StrTran(cString, "Ü", "U")
cString := StrTran(cString, "Û", "U")

cString := StrTran(cString, "Ç", "C")

cString := StrTran(cString, " ", "_")

Return(cString)
/*/
———————————————————————————————————————————————————————————————————————————————————————
@function		GRVLOG                                                               /@
@type			User Function                                                        /@
@date			10/01/2012                                                           /@
@description	Grava o log do processamento de registros                            /@
@author			Adalberto Moreno Batista (Opção Um Consultoria)                      /@
@Alteração      Ronaldo Silva - 08-09-21 (Unificar LOG para todos os processamentos) /@  
@use			Brasitech                                                            /@
———————————————————————————————————————————————————————————————————————————————————————
/*/
User Function GrvLog(cTipoOcor, cChave, cOcorrencia, cProc)
Local cEol		:= chr(13) + chr(10)
Local cLog		:= cOcorrencia + cEol

ZZ9->(RecLock("ZZ9",.T.))
ZZ9->ZZ9_FILIAL		:= xFilial("ZZ9")
ZZ9->ZZ9_ROTINA		:= FunName()
ZZ9->ZZ9_PROC		:= cProc
ZZ9->ZZ9_TIPO		:= cTipoOcor
ZZ9->ZZ9_CHAVE		:= cChave
ZZ9->ZZ9_INDPRO		:= Lower(cQualArq)
ZZ9->ZZ9_DATA		:= dDtProc
ZZ9->ZZ9_HORA		:= cHrProc
ZZ9->ZZ9_RESUMO		:= cOcorrencia
ZZ9->ZZ9_LOG		:= cLog
ZZ9->(MsUnlock())

Return()
