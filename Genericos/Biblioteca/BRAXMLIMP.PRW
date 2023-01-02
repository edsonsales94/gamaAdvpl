#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} RLOJA001()              
Importação de XML de cupons fiscais para integração com estoque, 
financeiro, fiscal e contabil da retaguarda Protheus

@author 		
@since 		
@version 	
@obs    		
/*/
//-------------------------------------------------------------------
User Function BRAXMLIMP()
//Local aArea			:= GetArea()
Local cArqCFe			:= "\nfpendente\"
Local lChkArq			:= .F.
Local cCaminho			:= ""
Local nOpcv				:= 0
Local oDlgImp, oGet1, oButton3, oButton4, oButton5, oGroup1, oGroup2, oPnlTop
Private cArqLog		:= "\nfpendente\log\log_" + dTOs(dDataBase) + "_" + StrTran(Time(), ":", "") + ".log"
Private oFont2 		:= TFont():New("Arial",,017,,.F.,,,,,.F.,.F.)
Private cExt			:= "Arquivo XML | *.XML"
Private nHdl 			:= 0
Private aArqXML		:= {}
Private aItens			:= {}
Private aCabNF			:= {}
Private lMsErroAuto  := .F.

MakeDir("\nfpendente")
MakeDir("\nfpendente\erro")
MakeDir("\nfpendente\duplic")
MakeDir("\nfpendente\ok")
MakeDir("\nfpendente\log")
MakeDir("\nfpendente\semuso")
 
DEFINE MSDIALOG oDlgImp TITLE "Importação de Arquivo XML - NF entrada" FROM 000,000 TO 380,500 PIXEL

oPnlTop	:= TPanel():New(3,3,,oDlgImp,,,,,,246,185,.F.,.F.)

@014,011 GROUP oGroup1 To 064, 238 Of oPnlTop Pixel
@031,015 MsGet oGet1 Var cArqCFe		Size 191,011 Of oPnlTop FONT oFont2 When lChkArq Pixel

@079,011 GROUP oGroup2 To 129, 238 Of oPnlTop Pixel
@085,015 SAY "Importa XML´s gerados por terceiros, em notas de entrada, para efeito fiscal."	SIZE 220,022 OF oPnlTop FONT oFont2 PIXEL
@110,015 SAY "Esta operação não atualiza estoque e nem gera financeiro."	SIZE 220,011 OF oPnlTop FONT oFont2 PIXEL

@031,212 BUTTON oButton3 PROMPT "..."					SIZE 018,012 OF oPnlTop ACTION cArqCFe := PadR(AllTrim(cGetFile(cExt,SubStr(cExt,1,12),1,cCaminho,.T.,nOr(GETF_LOCALHARD, GETF_NETWORKDRIVE))),90) WHEN lChkArq PIXEL
@150,150 BUTTON oButton4 PROMPT "OK" 					SIZE 028,012 PIXEL OF oPnlTop ACTION (nOpcv := 1, oDlgImp:End())
@150,195 BUTTON oButton5 PROMPT "Cancelar" 			SIZE 028,012 PIXEL OF oPnlTop ACTION (nOpcv := 0, oDlgImp:End())
Activate MsDialog oDlgImp Centered

if nOpcv == 1
	
	SetFunName("MATA103")
	aArqXML	:= Directory(cArqCFe + "*.XML")

	Processa({ || RotinaPonte(cArqCFe,aArqXML)}, "Processamento de arquivos XML", "Lendo informações", .F.)
	

/*
	For nI:= 1 To Len(aArqXML)

		cInfLog	:= "Arquivo: " + aArqXML[nI,1]
		nHdl 		:= fOpen(cArqCFe + aArqXML[nI][1],0)
		
		If nHdl == -1
			If !Empty(cArqCFe)
				MsgAlert("O arquivo de nome " + cArquivo + " nao pode ser aberto! Verifique os parametros!","Alerta")
			EndIf
			Return
		EndIf
		
		nTamFile	:= fSeek(nHdl,0,2)
		fSeek(nHdl,0,0)
		cBuffer	:= Space(nTamFile) // Variavel para criacao da linha do registro para leitura
		nBtLidos	:= fRead(nHdl, @cBuffer, nTamFile)  // Leitura  do arquivo XML
		fClose(nHdl)
	
		WorkXML(cBuffer, aArqXML[nI,1])

	Next nI
*/

	if len(aArqXML) > 0
		Alert("Processo concluído na filial " + AllTrim(SM0->M0_FILIAL) + "! Foram lidos " + AllTrim(Str(len(aArqXML))) + " arquivos")
	else
		Alert("Sem arquivos para processar")
	endif
endif

Return()


Static Function RotinaPonte(cArqCFe,aArqXML)
Local nI, nHdl, nTamFile, cBuffer,nBtLidos

	For nI:= 1 To Len(aArqXML)


		if !"CANCELAMENTO" $ Upper(aArqXML[nI,1])
		
			cInfLog	:= "Arquivo: " + aArqXML[nI,1]
			nHdl 		:= fOpen(cArqCFe + aArqXML[nI][1],0)
			
			If nHdl == -1
				If !Empty(cArqCFe)
					MsgAlert("O arquivo de nome " + cArquivo + " nao pode ser aberto! Verifique os parametros!","Alerta")
				EndIf
				Return
			EndIf
			
			nTamFile	:= fSeek(nHdl,0,2)
			fSeek(nHdl,0,0)
			cBuffer	:= Space(nTamFile) // Variavel para criacao da linha do registro para leitura
			nBtLidos	:= fRead(nHdl, @cBuffer, nTamFile)  // Leitura  do arquivo XML
			fClose(nHdl)
		
			WorkXML(cBuffer, aArqXML[nI,1])

      else
      
			__CopyFile("\nfpendente\" + aArqXML[nI,1], "\nfpendente\semuso\" + aArqXML[nI,1])
			fErase("\nfpendente\" + aArqXML[nI,1])

		endif

	Next nI

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		GRVLOG                                                        /@
@type			Static function                                               /@
@date			30/04/2012                                                    /@
@description	Grava log de processamento na tabela temporária de log        /@
@author			Adalberto Moreno Batista - Opção Um Consultoria               /@
@use			Brasitech                                      /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function GrvLog(cArqLog, cDescr, cArqErro)
Local cLog		:= MemoRead(cArqLog)
Local cEol		:= chr(13) + chr(10)
Local cTexto

cTexto := cLog + cDescr + cEol

if cArqErro <> NIL
	cTexto := cLog + cDescr + cEol + " Detalhes do erro no arquivo " + cArqErro + cEol
else
	cTexto := cLog + cDescr + cEol
endif
MemoWrite(cArqLog, cTexto)
Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		WORKXML                                                      /@
@type			Static function                                              /@
@date			27/05/2019                                                   /@
@description	                                                             /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function WorkXML(cBuffer, cFile)

Local aEmpresas:= {{"07293118000102", "01"}, {"07293118000285", "03"}, {"07293118000790", "09"}, {"07293118000609", "08"}}
Local aItens	:= {}
Local cFinNFe, cCompl, cRefNFe, cIdEmit, cIdNF, cNF, cSerie, cNatOp, cMod, cDtEmis,;
	  cTpNF, cDestOp, cTpAmb, nVDesc, nVNF, cAviso, cErro, oNFe, oNFeDetail, nPosEmp,;
	  cFormul, aCabNF, aItNF, aTES, nX
		
//cTpDest, cIE, cNome, cLograd,;
//		cNro,cBairro, cCodMun, cMunic, cUF, cCEP, cFone, ceMail, nVolume, cEspecie, nPesoLiq, nPesoBru, cModFrete, cCNPJTran, cNomeTran, cInscTran, cEndTran, cMunTran, cUFTran,;

//Ler somente cupons válidos. Os cancelados serão desprezados
//Este ponto resolve o erro na leitura do XML de cupons cancelados, pois
//como ele não possui itens, nao há o elemento DET
if !"http://www.portalfiscal.inf.br/nfe" $ cBuffer 	//?xml version="1.0" encoding="UTF-8"?

   conout("erro na leitura do XML")

else
	
	SA2->(dbSetOrder(3))		//A2_FILIAL, A2_CGC   - 02462805000778
	SB1->(dbSetOrder(1))		//B1_FILIAL, B1_COD
	SF1->(dbSetOrder(1))		//F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO
	SD1->(dbSetOrder(1))		//D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM
	SF4->(dbSetOrder(1))		//F4_FILIAL, F4_CODIGO
	
	cAviso	:= ""
	cErro		:= ""
	oNFe		:= XmlParser(cBuffer, "_", @cAviso, @cErro)

	if (XmlChildEx(oNFe,"_NFE") <> NIL .and. XmlChildEx(oNFe:_NFe, "_INFNFE") <> NIL) .or.;
		(XmlChildEx(oNFe,"_NFEPROC") <> NIL .and. XmlChildEx(oNFe:_NFEPROC,"_NFE") <> NIL .and. XmlChildEx(oNFe:_NFEPROC:_NFe, "_INFNFE") <> NIL)

		cFinNFe		:= "1"
		cCompl 	 	:= ""
		cRefNFe		:= Space(44)
		
		if XmlChildEx(oNFe,"_NFE") <> NIL
			oNFeDetail	:= oNFe:_NFe:_InfNFe
		else
			oNFeDetail	:= oNFe:_NFeProc:_NFe:_InfNFe
		endif

		cNF   		:= StrZero(Val(oNFeDetail:_IDE:_NNF:TEXT),9)
		cSerie 		:= Padr(AllTrim(Str(Val(oNFeDetail:_IDE:_SERIE:TEXT),3)),3)
		cTpNF  		:= oNFeDetail:_IDE:_TPNF:TEXT
		cIdDestino	:= oNFeDetail:_DEST:_CNPJ:TEXT		//destino
		cIdEmit		:= oNFeDetail:_EMIT:_CNPJ:TEXT		//emissor
		nPosEmp 		:= aScan(aEmpresas, {|x| x[1] == cIdDestino})
		
		if cTpNF == "1"
		
			if nPosEmp > 0
			
				if aEmpresas[nPosEmp,2] == SM0->M0_CODFIL
	//				if SA2->(dbSeek(xFilial("SA2") + cIdEmit))
					dbSelectArea("SA2")
					if dbSeek(xFilial("SA2") + cIdEmit)
						cFornece := SA2->A2_COD
						cLoja		:= SA2->A2_LOJA
	
						cIdEmit		:= oNFeDetail:_EMIT:_CNPJ:TEXT												//14,0 - CNPJ Emissor
						cIdNF  		:= substr(oNFeDetail:_ID:TEXT,4)												//47,0 - Ident. NFe
						cNatOp 		:= Padr(oNFeDetail:_IDE:_NATOP:TEXT,30) 									//30,0 - Nat. Operac
						cMod   		:= oNFeDetail:_IDE:_MOD:TEXT													//02,0 - Modelo NF
						cDtEmis		:= sTOd(StrTran(Left(oNFeDetail:_IDE:_DHEMI:TEXT,10),"-",""))		//08,0 - Emissao
						cDestOp		:= oNFeDetail:_IDE:_IDDEST:TEXT												//01,0 - Destino Oper
						cTpAmb 		:= oNFeDetail:_IDE:_TPAMB:TEXT												//01,0 - Tipo Ambient
				
						if XmlChildEx(oNFeDetail:_IDE,"_FINNFE") != NIL
							cFinNFe		:= oNFeDetail:_IDE:_FINNFE:TEXT											//01,0 - Finalidade
						endif
				
						nVDesc 		:= 0	//Val(oNFeDetail:_TOTAL:_ICMSTOT:_VDESC:TEXT)							//12,2 - Vlr Desconto
						nVNF   		:= Val(oNFeDetail:_TOTAL:_ICMSTOT:_VNF:TEXT)								//12,2 - Total NF
				
						if XmlChildEx(oNFeDetail:_IDE,"_REFNFE") != NIL
							cRefNFe		:=  oNFeDetail:_IDE:_REFNFE:TEXT											//47,0 - Ident. NFe
						endif
				
						cFormul		:= iif(cIdEmit==SM0->M0_CGC, "S", "N")
						
						//———————————————————————————————————————————————————————————————————————————————
						// Itens da nota
						//———————————————————————————————————————————————————————————————————————————————
						oItemDetail := oNFeDetail:_DET
						if Type("oItemDetail") == "A"
								//Mais de um item
								For nX:=1 To Len(oItemDetail)
									aAdd(aItens, READITEM(oItemDetail[nX]))
								Next
						else
							//Um unico item
							aAdd(aItens, READITEM(oItemDetail))
				      endif
				   
						//———————————————————————————————————————————————————————————————————————————————
						// Gravação do retorno em tabela especifica de notas integradas
						//———————————————————————————————————————————————————————————————————————————————
	//					if !SF1->(dbSeek(xFilial("SF1") + cNF + cSerie + cFornece + cLoja))
						dbSelectArea("SF1")
						if !dbSeek(xFilial("SF1") + cNF + cSerie + cFornece + cLoja)
	
							aCabNF := {	{"F1_TIPO",		"N",					Nil},;
										{"F1_FORMUL",	cFormul,				Nil},;
										{"F1_DOC",		cNF,					Nil},;
										{"F1_SERIE",	cSerie,				Nil},;
										{"F1_EMISSAO",	cDtEmis,				Nil},;
										{"F1_FORNECE",	cFornece,			Nil},;
										{"F1_LOJA",		cLoja,				Nil},;
										{"F1_EST",		SA2->A2_EST,		Nil},;
										{"F1_ESPECIE",	"SPED",				Nil},;
										{"F1_CHVNFE",	cIdNF,				Nil}}
							aItNF := {}
							For nX:=1 To Len(aItens)
					
								aTES		:= GetTES(aItens[nX,8])
								cProduto	:= Substr(aItens[nX,2],5)
								//if !SB1->(dbSeek(xFilial("SB1") + aItens[8])) .and. Len(aTES) != 1
								dbSelectArea("SB1")
								if !dbSeek(xFilial("SB1") + cProduto) .and. Len(aTES) != 1
									aCabNF := Nil
									exit
								endif
	
								aAdd(aItNF,{	{"D1_ITEM", 	StrZero(nX,4),		Nil},;
													{"D1_COD",		cProduto,			Nil},;
													{"D1_TES",		aTES[1],				Nil},;
													{"D1_QUANT",	aItens[nX,10],		Nil},;
													{"D1_VUNIT",	aItens[nX,11], 	Nil},;
													{"D1_TOTAL",	aItens[nX,12],		Nil},;
													{"D1_LOCAL",	"01",					Nil},;
													{"D1_BASEICM", aItens[nX,18],		Nil},;
													{"D1_ICM", 		aItens[nX,17],		Nil},;
													{"D1_VALICM", 	aItens[nX,19],		Nil},;
													{"D1_BASEIPI", aItens[nX,24],		Nil},;
													{"D1_IPI", 		aItens[nX,23],		Nil},;
													{"D1_VALIPI", 	aItens[nX,25],		Nil}} )
	
							Next
				         
				         if aCabNF != Nil .and. Len(aItNF) > 0
					         lMsErroAuto := .F.
					         dbSelectArea("SF1")

								MsExecAuto({|x, y, z| MATA103(x, y, z)}, aCabNF, aItNF, 3)
											
								if lMsErroAuto
								
									DisarmTransaction()
									cLogSC := NomeAutoLog()
									GrvLog(cArqLog, cInfLog + " NF não foi gravada. Motivo: Ocorrência de erro no msexecauto. Verifique!", cLogSC)
									__CopyFile("\nfpendente\" + cFile, "\nfpendente\erro\" + cFile)
									fErase("\nfpendente\" + cFile)
									
									__CopyFile("\system\" + cLogSC, "\nfpendente\log\" + cLogSC)
									
								else
	
									__CopyFile("\nfpendente\" + cFile, "\nfpendente\ok\" + cFile)
									fErase("\nfpendente\" + cFile)
									
								endif
							else
	
								GrvLog(cArqLog, cInfLog + " não existe TES para o CFOP em questão e/ou produto não cadastrado!")
								__CopyFile("\nfpendente\" + cFile, "\nfpendente\erro\" + cFile)
								fErase("\nfpendente\" + cFile)
								
							endif
							
						else
						
							GrvLog(cArqLog, cInfLog + ". NF já cadastrada. movido para pasta ok")
							__CopyFile("\nfpendente\" + cFile, "\nfpendente\duplic\" + cFile)
							fErase("\nfpendente\" + cFile)
	
						endif
				   
				   else
	
						GrvLog(cArqLog, cInfLog + ". CNPJ do emitente não está cadastrado como fornecedor. movido para pasta erro")
						__CopyFile("\nfpendente\" + cFile, "\nfpendente\erro\" + cFile)
						fErase("\nfpendente\" + cFile)
				   
				   endif
				   
	         endif
	         
	      else
	      
				GrvLog(cArqLog, cInfLog + ". CNPJ do destinatário não encontrado nas filiais do grupo GAMA. (07293118000102, 07293118000285, 07293118000790 ou 07293118000609). movido para pasta erro")
				__CopyFile("\nfpendente\" + cFile, "\nfpendente\erro\" + cFile)
				fErase("\nfpendente\" + cFile)
	
	      endif

      else
      
			__CopyFile("\nfpendente\" + cFile, "\nfpendente\semuso\" + cFile)
			fErase("\nfpendente\" + cFile)

      endif

	endif

endif
Return()



/*/
———————————————————————————————————————————————————————————————————————————————
@function		ReadItem                                                      /@
@type				Static function                                               /@
@date				04/04/2019                                                    /@
@description	Lê conteúdo do objeto referente ao item da nota e retorna vetor/@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Opção Um Consultoria                                          /@
@use				Especifico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function READITEM(oNFeItem)
Local aRet 		:= {}
Local cOrigem	:= ""
Local nVDesc	:= 0	//Val(oNFeiTEM:_PROD:_VDESC:TEXT)
Local cCSTICMS := ""
Local nPICMS	:= 0
Local nBICMS	:= 0
Local nVICMS	:= 0
Local nBICMSST	:= 0
Local nVICMSST	:= 0
Local cCSTIPI  := ""
Local nPIPI		:= 0
Local nBIPI		:= 0
Local nVIPI		:= 0

//———————————————————————————————————————————————————————————————————————————————
// Identifica informações de ICMS
//———————————————————————————————————————————————————————————————————————————————
if XmlChildEx(oNFeItem:_IMPOSTO,"_ICMS") != NIL

	if XmlChildEx(oNFeItem:_IMPOSTO:_ICMS,"_ICMS00") != NIL	//00 - Tributada integralmente
		cCSTICMS	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS00:_CST:TEXT
		cOrigem	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS00:_ORIG:TEXT
		nPICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS00:_PICMS:TEXT)
		nBICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS00:_VBC:TEXT)
		nVICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS00:_VICMS:TEXT)
		
	elseif XmlChildEx(oNFeItem:_IMPOSTO:_ICMS,"_ICMS10") != NIL	//10 - Tributada e com cobrança do ICMS por substituição tributária
		cCSTICMS	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS10:_CST:TEXT
		cOrigem	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS10:_ORIG:TEXT
		nPICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS10:_PICMS:TEXT)
		nBICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS10:_VBC:TEXT)
		nVICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS10:_VICMS:TEXT)
		
	elseif XmlChildEx(oNFeItem:_IMPOSTO:_ICMS,"_ICMS20") != NIL	//20 - Com redução de base de cálculo
		cCSTICMS	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS20:_CST:TEXT
		cOrigem	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS20:_ORIG:TEXT
		nPICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS20:_PICMS:TEXT)
		nBICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS20:_VBC:TEXT)
		nVICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS20:_VICMS:TEXT)
	
	elseif XmlChildEx(oNFeItem:_IMPOSTO:_ICMS,"_ICMS30") != NIL	//30 - Isenta ou não tributada e com cobrança do ICMS por substituição tributária
		cCSTICMS	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS30:_CST:TEXT
		cOrigem	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS30:_ORIG:TEXT
		nPICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS30:_PICMS:TEXT)
		nBICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS30:_VBC:TEXT)
		nVICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS30:_VICMS:TEXT)
	
	elseif XmlChildEx(oNFeItem:_IMPOSTO:_ICMS,"_ICMS40") != NIL	//40 - Isenta
		cCSTICMS	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS40:_CST:TEXT
		cOrigem	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS40:_ORIG:TEXT
	
	elseif XmlChildEx(oNFeItem:_IMPOSTO:_ICMS,"_ICMS41") != NIL	//41 - Não tributada
		cCSTICMS	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS41:_CST:TEXT
		cOrigem	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS41:_ORIG:TEXT
	
	elseif XmlChildEx(oNFeItem:_IMPOSTO:_ICMS,"_ICMS50") != NIL	//50 - Suspensão
		cCSTICMS	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS50:_CST:TEXT
		cOrigem	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS50:_ORIG:TEXT
		nPICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS50:_PICMS:TEXT)
		nBICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS50:_VBC:TEXT)
		nVICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS50:_VICMS:TEXT)
	
	elseif XmlChildEx(oNFeItem:_IMPOSTO:_ICMS,"_ICMS51") != NIL	//51 - Diferimento
		cCSTICMS	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS51:_CST:TEXT
		cOrigem	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS51:_ORIG:TEXT
		nPICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS51:_PICMS:TEXT)
		nBICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS51:_VBC:TEXT)
		nVICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS51:_VICMS:TEXT)
	
	elseif XmlChildEx(oNFeItem:_IMPOSTO:_ICMS,"_ICMS60") != NIL	//60 - ICMS cobrado anteriormente por substituição tributária
		cCSTICMS	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS60:_CST:TEXT
		cOrigem	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS60:_ORIG:TEXT
		nPICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS60:_PICMS:TEXT)
		nBICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS60:_VBC:TEXT)
		nVICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS60:_VICMS:TEXT)
	
	elseif XmlChildEx(oNFeItem:_IMPOSTO:_ICMS,"_ICMS70") != NIL	//70 - Com redução de base de cálculo e cobrança do ICMS por substituição tributária
		cCSTICMS	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS70:_CST:TEXT
		cOrigem	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS70:_ORIG:TEXT
		nPICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS70:_PICMS:TEXT)
		nBICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS70:_VBC:TEXT)
		nVICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS70:_VICMS:TEXT)
	
	elseif XmlChildEx(oNFeItem:_IMPOSTO:_ICMS,"_ICMS90") != NIL	//90 - Outras
		cCSTICMS	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS90:_CST:TEXT
		cOrigem	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS90:_ORIG:TEXT
		nPICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS90:_PICMS:TEXT)
		nBICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS90:_VBC:TEXT)
		nVICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS90:_VICMS:TEXT)
	
	endif
	
endif

//———————————————————————————————————————————————————————————————————————————————
// Identifica informações de IPI
//———————————————————————————————————————————————————————————————————————————————
if XmlChildEx(oNFeItem:_IMPOSTO,"_IPI") != NIL .and. XmlChildEx(oNFeItem:_IMPOSTO:_IPI,"_IPITRIB") != NIL
	cCSTIPI	:= oNFeItem:_IMPOSTO:_IPI:_IPITRIB:_CST:TEXT
	nPIPI		:= Val(oNFeItem:_IMPOSTO:_IPI:_IPITRIB:_PIPI:TEXT)
	nBIPI		:= Val(oNFeItem:_IMPOSTO:_IPI:_IPITRIB:_VBC:TEXT)
	nVIPI		:= Val(oNFeItem:_IMPOSTO:_IPI:_IPITRIB:_VIPI:TEXT)
endif

//———————————————————————————————————————————————————————————————————————————————
// Monta retorno do item, com valores de impostos
//———————————————————————————————————————————————————————————————————————————————
aRet := {oNFeItem:_NITEM:TEXT,;
			oNFeItem:_PROD:_CPROD:TEXT,;
			oNFeItem:_PROD:_CEAN:TEXT,;
			oNFeItem:_PROD:_CEANTRIB:TEXT,;
			oNFeItem:_PROD:_XPROD:TEXT,;
			oNFeItem:_PROD:_NCM:TEXT,;
			cOrigem,;
			oNFeItem:_PROD:_CFOP:TEXT,;
			oNFeItem:_PROD:_UCOM:TEXT,;
			Val(oNFeItem:_PROD:_QCOM:TEXT),;
			Val(oNFeItem:_PROD:_VUNCOM:TEXT),;
			Val(oNFeItem:_PROD:_VPROD:TEXT),;
			oNFeItem:_PROD:_UTRIB:TEXT,;
			Val(oNFeItem:_PROD:_QTRIB:TEXT),;
			Val(oNFeItem:_PROD:_VUNTRIB:TEXT),;
			cCSTICMS,;
			nPICMS,;
			nBICMS,;
			nVICMS,;
			nBICMSST,;
			nVICMSST,;
			cCSTIPI,;
			nPIPI,;
			nBIPI,;
			nVIPI,;
			nVDesc}

Return(aRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		GetTES                                                        /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
@use				Especifico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function GetTES(cCFOP)
Local aRet		:= {}
Local aArea		:= GetArea()
Local cQuery
                                                                                                 '
if AllTrim(cCFOP) == "5906" .or. AllTrim(cCFOP) == "6906"
	cCFOP := "5907"
endif
	
cQuery	:= "SELECT * FROM " + RetSQLName("SF4") + " SF4 " +;
						"WHERE D_E_L_E_T_='' AND F4_MSBLQL!='1' AND F4_TIPO='E' AND F4_ESTOQUE='N' AND F4_DUPLIC='N' AND F4_PODER3='N' AND SUBSTRING(F4_CF,2,3)='" + Substr(cCFOP,2,3) + "'"

if Select("TEMP") > 0
	TEMP->(dbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),"TEMP", .F., .T.)

dbSelectArea("TEMP")
dbGoTop()
do while TEMP->(!eof())
	aAdd(aRet, TEMP->F4_CODIGO)
	TEMP->(dbSkip())
enddo

RestArea(aArea)

Return(aRet)
