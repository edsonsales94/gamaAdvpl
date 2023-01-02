#include "protheus.ch"
#include "rwmake.ch"
#include "ap5mail.ch"
#include "totvs.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		BRAJOB19	                                                 /@
@type			User function                                                /@
@date			04/04/2019                                                   /@
@description	Importador de notas fiscais emitidas pela INFRACOMMERCE a
				partir da leitura das informações do XML                     /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br) Opção Um   /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
https://doc.stage-api.infrahub.com.br/?version=latest#46dc15db-6c07-4171-b0bb-d4e2260b8902

07/11/19
Alterado o modo de pesquisa do produto de (5) B1_FILIAL, B1_CODBAR para (1) B1_FILIAL, B1_COD

07/06/21
Incluido processo para integrar automaticamente registros pendentes, função E19_BRAJOB

27/07/21
Ajustado para verificar o CNPJ do emitente e aceitar somente os pertencentes às filiais executadas em 'aFil'
Verificação do tipo do XML (normal, cancelado, inutilização) antes de iniciar o processamento
Melhoria para criação de tabela ZZD com configurações de TES x CFOP e retirada do array de configuração fixa.

10/11/22
Criada forma de garantir que o arquivo foi baixado do email, alem do saveattach, verifico com o file()
substituição
/*/
User Function BRAJOB19()
Local aFiles		:= {"CC2", "SA1", "SA2", "SA3", "SA4", "SB1", "SF4", "SF1", "SF2", "SD1", "SD2", "SD3", "SE1", "SE2", "ZZ7", "ZZ8", "ZZD"}
Local cEmp			:= "01"
Local aFil			:= {"11"}
Local cXMLPath		:= "\edi01\infracommerce\xml\"
Local aNFCancel		:= {}
Local nE, nK, nHdl, nTamFile, cBuffer, aArqXML, lNFCancel, cTpXML,cArquivo

MakeDir("\edi01")
MakeDir("\edi01\infracommerce")
MakeDir("\edi01\infracommerce\xml")
MakeDir("\edi01\infracommerce\xml\processado")
MakeDir("\edi01\infracommerce\xml\erro")
MakeDir("\edi01\infracommerce\xml\log")

//———————————————————————————————————————————————————————————————————————————————
//———————————————————————————————————————————————————————————————————————————————
// Busca XML's em email para gravação em pasta específica
//———————————————————————————————————————————————————————————————————————————————
//———————————————————————————————————————————————————————————————————————————————
WfPrepEnv(cEmp, aFil[1], "U_BRAJOB19",, "COM")

A19_BRAJOB()

RpcClearEnv()


//———————————————————————————————————————————————————————————————————————————————
//———————————————————————————————————————————————————————————————————————————————
// Inicie processamento por filial
//———————————————————————————————————————————————————————————————————————————————
//———————————————————————————————————————————————————————————————————————————————
for nE := 1 to Len(aFil)

	//———————————————————————————————————————————————————————————————————————————————
	// Abertura do ambiente e tabelas para processamento
	//———————————————————————————————————————————————————————————————————————————————
	WfPrepEnv(cEmp, aFil[nE], "U_BRAJOB19",, "COM")

	for nK := 1 to Len(aFiles)
		if Empty(Select(aFiles[nK]))
			ChkFile(aFiles[nK])
		endif
	next

	//———————————————————————————————————————————————————————————————————————————————
	// Lê XML's em pasta específica para processamento das notas
	//———————————————————————————————————————————————————————————————————————————————
	aArqXML		:= Directory(cXMLPath + "*.XML","D")
	aNFCancel	:= {}

	For nK:= 1 To Len(aArqXML)

		cArquivo	:= aArqXML[nK][1]
		lNFCancel	:= .F.
		//cBuffer		:= Memoread(cXMLPath + cArquivo)
		nHdl 		:= fOpen(cXMLPath + cArquivo,0)
		if nHdl == -1
			if !Empty(cXMLPath)
				ConOut("B19_BRAJOB. arquivo de nome " + cArquivo + " nao pode ser aberto! Verifique os parametros!")
			endif
			Loop
			//Return()
		endif
		nTamFile	:= fSeek(nHdl,0,2)
		fSeek(nHdl,0,0)
		cBuffer	:= Space(nTamFile)		 //Variavel para criacao da linha do registro para leitura
		fRead(nHdl, @cBuffer, nTamFile)  //Leitura do arquivo XML
		fClose(nHdl)

		//———————————————————————————————————————————————————————————————————————————————
		// Checagem do XML, retorna:
		//	lCNPJAtual
		//		.T. Se CNPJ emitente for igual ao SM0->M0_CGC
		//		.F. Se CNPJ emitente for diferente ao SM0->M0_CGC
		//
		//	cTpXML
		//		1-XML NF
		//		2-XML Inutilização
		//		3-XML Cancelamento
		//		9-XML Incorreto
		//———————————————————————————————————————————————————————————————————————————————
		if CheckXML(cBuffer, @cTpXML)		//Verifico se é da filial atual

			//———————————————————————————————————————————————————————————————————————————————
			// Importa NF valida
			//———————————————————————————————————————————————————————————————————————————————
			if cTpXML == "1"
				B19_BRAJOB(cBuffer)
				__CopyFile(cXMLPath + cArquivo, cXMLPath + "processado\" + cArquivo)
				if File(cXMLPath + "processado\" + cArquivo)
					fErase(cXMLPath + cArquivo)
				endif

			//———————————————————————————————————————————————————————————————————————————————
			// Importa NF inutilizada
			//———————————————————————————————————————————————————————————————————————————————
			elseif cTpXML == "2"
				C19_BRAJOB(cBuffer)
				__CopyFile(cXMLPath + cArquivo, cXMLPath + "processado\" + cArquivo)
				if File(cXMLPath + "processado\" + cArquivo)
					fErase(cXMLPath + cArquivo)
				endif

			//———————————————————————————————————————————————————————————————————————————————
			// Trata notas canceladas para processamento posterior
			//———————————————————————————————————————————————————————————————————————————————
			elseif cTpXML == "3"
				D19_BRAJOB(cBuffer)
				__CopyFile(cXMLPath + cArquivo, cXMLPath + "processado\" + cArquivo)
				if File(cXMLPath + "processado\" + cArquivo)
					fErase(cXMLPath + cArquivo)
				endif
				//aAdd(aNFCancel, cArquivo)

			else

				__CopyFile(cXMLPath + cArquivo, cXMLPath + "erro\" + cArquivo)
				if File(cXMLPath + "erro\" + cArquivo)
					fErase(cXMLPath + cArquivo)
				endif
				
			endif

		endif

	next

	//———————————————————————————————————————————————————————————————————————————————
	// Tratamento para notas canceladas
	//———————————————————————————————————————————————————————————————————————————————
	For nK:= 1 To Len(aNFCancel)

		nHdl 		:= fOpen(cXMLPath + aNFCancel[nK], 0)
		cArquivo:= aNFCancel[nK]


		if nHdl == -1
			if !Empty(cXMLPath)
				ConOut("C19_BRAJOB. arquivo de nome " + cArquivo + " nao pode ser aberto! Verifique os parametros!")
			endif
			Loop
		endif

		nTamFile	:= fSeek(nHdl,0,2)
		fSeek(nHdl,0,0)
		cBuffer	:= Space(nTamFile)		 //Variavel para criacao da linha do registro para leitura
		fRead(nHdl, @cBuffer, nTamFile)  //Leitura do arquivo XML
		fClose(nHdl)

		if D19_BRAJOB(cBuffer)
					
			__CopyFile(cXMLPath + aNFCancel[1], cXMLPath + "processado\" + aNFCancel[1])
			if File(cXMLPath + "processado\" + aNFCancel[1])
				fErase(cXMLPath + aNFCancel[1])
			endif

		endif

	next

	//———————————————————————————————————————————————————————————————————————————————
	// Integração de registros pendentes ZZ7_STATUS == "0"
	//———————————————————————————————————————————————————————————————————————————————
	E19_BRAJOB()

	//———————————————————————————————————————————————————————————————————————————————
	// Encerramento do ambiente
	//———————————————————————————————————————————————————————————————————————————————
	RpcClearEnv()

Next

ConOut(dTOc(Date()) + " - " + Time() + " BRAJOB19 - Importação XML´s Infracommerce")

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		A19_BRAJOB	                                                 /@
@type			Static function                                              /@
@date			01/10/2019                                                   /@
@description	Busca XML's em email para gravação em pasta específica       /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function A19_BRAJOB()
Local cPopServer		:= AllTrim(SuperGetMV("MV_WFPOP3",, "pop.skymail.net.br"))			// servidor pop3 do email
Local cSMTPServer		:= ""																// servidor smtp do email
Local cAccount			:= AllTrim(SuperGetMV("BR_INFREML",, "gama.mkp@gamaitaly.com.br"))	// conta de email a ser utilizada para o recebimento dos arquivos
Local cPassword			:= AllTrim(SuperGetMV("BR_INFRPSW",, "Skymail@509"))				// Senha da conta de email para acesso
Local nPopPort			:= SuperGetMV("BR_INFRPOP",, 995)  									// Porta de acesso ao pop3, padrao 110
Local nPopResult		:= 0
Local nQtdMessages		:= 0
Local nTimeOut			:= 60
Local oMailServer		:= TMailManager():New()
Local lIsPop 			:= .T.																// forço serviço POP

oMailServer:SetUseSSL(.T.)
oMailServer:SetUseTLS(.T.)

if lIsPop
	cPopServer	:= iif(Empty(cPopServer), "pop.skymail.net.br", cPopServer)
	nPopPort	:= iif(nPopPort == 0, 995, nPopPort)
else
	cPopServer	:= iif(Empty(cPopServer), "imap.skymail.net.br", cPopServer)
	nPopPort	:= iif(nPopPort == 0, 993, nPopPort)
endif

oMailServer:Init(cPopServer, cSMTPServer, cAccount, cPassword, nPopPort)

// Seto timeout no servico
If oMailServer:SetPOPTimeout(nTimeOut) == 0

	if lIsPop
		nPopResult	:= oMailServer:POPConnect()
	else
		nPopResult	:= oMailServer:IMAPConnect()
	endif

	If (nPopResult == 0)

		oMailServer:GetNumMsgs(@nQtdMessages)	//Conta quantas mensagens há no servidor

		If (nQtdMessages > 0)

			A19_SUBBRAJOB19(oMailServer, nQtdMessages)

		Else

			ConOut("Não foram encontradas mensagens na caixa postal de " + cAccount)

		EndIf

		oMailServer:PopDisconnect()

	Else

		ConOut("Erro na conexão: " + oMailServer:GetErrorString(nPopResult))

	EndIf

Else

	ConOut("Erro de timeout, tempo " + ValToChar(nTimeOut))

Endif

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		A19_SUBBRAJOB19                                              /@
@type			Static function                                              /@
@date			23/08/2017                                                   /@
@description	Baixa arquivos de e-mail especifico, criado para receber
				pedidos de compras do Atacadão                               /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Consultoria                                         /@
@use			DKT do Brasil                                                /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function A19_SUBBRAJOB19(oMailServer, nQtdMessages)
Local nMessage		:= 0
Local cPath			:= GetSrvProfString("RootPath", "\undefined") + "\edi01\infracommerce\xml\"
Local oMessage 		:= TMailMessage():New()
Local nPopResult, nAttach, aAttached, lHaveFile, lDelMessage

//———————————————————————————————————————————————————————————————————————————————
// Rastreia cada uma das mensagens no servidor
//———————————————————————————————————————————————————————————————————————————————
For nMessage := 1 To nQtdMessages

	oMessage:Clear()
	nPopResult := oMessage:Receive(oMailServer, nMessage)

	//———————————————————————————————————————————————————————————————————————————————
	// Avalia recebimento do e-mail
	//———————————————————————————————————————————————————————————————————————————————
	If (nPopResult == 0)

		//———————————————————————————————————————————————————————————————————————————————
		// Inicia verificacao dos anexos
		//———————————————————————————————————————————————————————————————————————————————
		lDelMessage	:= .T.
		lHaveFile 	:= .F.
		For nAttach := 1 To oMessage:getAttachCount()

			aAttached	:= oMessage:getAttachInfo(nAttach)
			oMessage:SetConfirmRead(.T.)

			//———————————————————————————————————————————————————————————————————————————————
			// somente arquivos com extensão do raiz CNPJ DKT *.38756680
			//———————————————————————————————————————————————————————————————————————————————
			If ".XML" $ Upper(aAttached[1])

				lHaveFile 	:= .T.

				If !(File("\edi01\infracommerce\xml\" + aAttached[1]))

					If oMessage:SaveAttach(nAttach, cPath + aAttached[1]) .and. File("\edi01\infracommerce\xml\" + aAttached[1])

						ConOut("Download de arquivo de pedidos para \edi01\infracommerce\xml\" + aAttached[1])

					Else

						lDelMessage	:= .F.

						ConOut("Não foi possível salvar o arquivo \edi01\infracommerce\xml\" + aAttached[1])

					EndIf

				Else

					ConOut("Arquivo " + aAttached[1] + " não foi gravado, pois já existe um com mesmo nome no diretório aguardando processamento")

				EndIf

			EndIf

		Next

		//———————————————————————————————————————————————————————————————————————————————
		// Caso não encontre anexos com a extensão definida, apaga o e-mail
		//———————————————————————————————————————————————————————————————————————————————
		If !lHaveFile		// Caso não encontre anexos com a extensão definida, apaga o e-mail

			ConOut("E-mail sem anexos válidos")
			oMailServer:DeleteMsg(nMessage)

		ElseIf lDelMessage			// Caso tenha sucesso no download dos arquivos, apaga o e-mail

			ConOut("Baixados arquivos e e-mail excluído")
			oMailServer:DeleteMsg(nMessage)

		EndIf

	Else

		ConOut("Erro leitura mensagem " + cValToChar(nMessage) + ": " + oMailServer:GetErrorString(nMessage))

	EndIf

Next
Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		B19_BRAJOB	                                                 /@
@type			Static function                                              /@
@date			04/04/2019                                                   /@
@description	Lê conteúdo do XML da NFe e grava em tabela ZZ7 e ZZ8        /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function B19_BRAJOB(cBuffer, lNFCancel)
Local aItens		:= {}
Local cStrDuplic	:= ""
Local cFinNFe		:= "1"
Local cCompl 	 	:= ""
Local cStatus		:= "0"		//Pendente
Local cRefNFe		:= Space(47)
Local cIdOrDe		:= Space(14)
Local cCNPJTran		:= Space(14)
Local cNomeTran		:= Space(50)
Local cInscTran		:= Space(14)
Local cEndTran 		:= Space(60)
Local cMunTran 		:= Space(40)
Local cUFTran  		:= Space(02)
Local cFone  		:= Replicate("9", 15)
Local ceMail  		:= 'cadastro@gamaitaly.com.br'		//Space(60)
Local cEspecie  	:= ""
Local nVolume  		:= 0
Local nPesoLiq 		:= 0
Local nPesoBru 		:= 0
Local cAviso		:= ""
Local cErro			:= ""
Local oNFe			:= XmlParser(cBuffer, "_", @cAviso, @cErro)
Local cIdEmit, cIdNF, cNF, cSerie, cNatOp, cMod, dDtEmis, cHrEmis, cTpNF, cDestOp,;
	  cTpAmb, cTpDest, cIE, cNome, cLograd, cNro, cBairro, cCodMun, cMunic, cUF,;
	  cCEP, nVICMS, nVProd, nVFrete, nVseg, nVDesc, nVIPI, nVOutro, nVICDes, nVST,;
	  nVII, nVNF, nVIPIDv, cModFrete, cMPProd, cMPTES, cCliente, cLojaCli, cFornece,;
	  cLojaFor, nX, aNFDevol, nI

SA1->(dbSetOrder(3))		//A1_FILIAL, A1_CGC
SA2->(dbSetOrder(3))		//A2_FILIAL, A2_CGC
SA3->(dbSetOrder(3))		//A3_FILIAL, A3_CGC
SA4->(dbSetOrder(3))		//A3_FILIAL, A3_CGC
SB1->(dbSetOrder(1))		//B1_FILIAL, B1_COD
SF4->(dbSetOrder(1))		//F4_FILIAL, F4_CODIGO

if XmlChildEx(oNFe,"_NFE") <> NIL
	oNFeDetail	:= oNFe:_NFe:_InfNFe
else
	oNFeDetail	:= oNFe:_NFeProc:_NFe:_InfNFe
endif

cNF   		:= StrZero(Val(oNFeDetail:_IDE:_NNF:TEXT),9)								//09,0 - Nota Fiscal
cSerie 		:= Padr(AllTrim(Str(Val(oNFeDetail:_IDE:_SERIE:TEXT),3)),3)					//03,0 - Serie

//———————————————————————————————————————————————————————————————————————————————
// Continuo somente se a nota não estiver gravada
//———————————————————————————————————————————————————————————————————————————————
ZZ7->(dbSetOrder(1))		//ZZ7_FILIAL, ZZ7_NNF, ZZ7_SERIE
if !ZZ7->(dbSeek(xFilial("ZZ7") + cNF + cSerie))

	cIdNF  		:= oNFeDetail:_ID:TEXT														//47,0 - Ident. NFe
	cIdEmit		:= oNFeDetail:_EMIT:_CNPJ:TEXT												//14,0 - CNPJ Emissor
	cNatOp 		:= Padr(oNFeDetail:_IDE:_NATOP:TEXT,30) 									//30,0 - Nat. Operac
	cMod   		:= oNFeDetail:_IDE:_MOD:TEXT												//02,0 - Modelo NF
	dDtEmis		:= StrTran(Left(oNFeDetail:_IDE:_DHEMI:TEXT,10),"-","")
	dDtEmis		:= cTOd(Right(dDtEmis,2) + "/" +;
					Substr(dDtEmis,5,2) + "/" +;
					Substr(dDtEmis,3,2))													//não usar a função sTOd			08,0 - Data Emissao
	cHrEmis		:= Substr(oNFeDetail:_IDE:_DHEMI:TEXT,12,8)									//08,0 - Hora Emissao
	cTpNF  		:= oNFeDetail:_IDE:_TPNF:TEXT												//01,0 - Tipo Operac
	cDestOp		:= oNFeDetail:_IDE:_IDDEST:TEXT												//01,0 - Destino Oper
	cTpAmb 		:= oNFeDetail:_IDE:_TPAMB:TEXT												//01,0 - Tipo Ambient

	if XmlChildEx(oNFeDetail:_IDE,"_FINNFE") != NIL
		cFinNFe		:= oNFeDetail:_IDE:_FINNFE:TEXT											//01,0 - Finalidade NFe	1=NF-e normal;2=NF-e complementar;3=NF-e de ajuste;4=Devolução/Retorno.
	endif

	if XmlChildEx(oNFeDetail:_DEST,"_CPF") != NIL
		cIdOrDe		:= oNFeDetail:_DEST:_CPF:TEXT									  		//14,0 - CPF
	elseif XmlChildEx(oNFeDetail:_DEST,"_CNPJ") != NIL
		cIdOrDe		:= oNFeDetail:_DEST:_CNPJ:TEXT											//14,0 - CNPJ
		if XmlChildEx(oNFeDetail:_DEST,"_IE") != NIL
			cIE		:= oNFeDetail:_DEST:_IE:TEXT									  		//14,0 - Inscr.Estad.
		endif
	endif

	cNome  		:= oNFeDetail:_DEST:_XNOME:TEXT		  										//60,0 - Nome
	cLograd 	:= oNFeDetail:_DEST:_ENDERDEST:_XLGR:TEXT								//60,0 - Logradouro
	cNro   		:= oNFeDetail:_DEST:_ENDERDEST:_NRO:TEXT									//10,0 - Nro
	if XmlChildEx(oNFeDetail:_DEST:_ENDERDEST,"_XCPL") != NIL
		cCompl 	 := oNFeDetail:_DEST:_ENDERDEST:_XCPL:TEXT								//30,0 - Complemento
	endif
	cBairro		:= oNFeDetail:_DEST:_ENDERDEST:_XBAIRRO:TEXT								//40,0 - Bairro
	cCodMun 	:= oNFeDetail:_DEST:_ENDERDEST:_CMUN:TEXT								//07,0 - Cod. Municip
	cMunic  	:= oNFeDetail:_DEST:_ENDERDEST:_XMUN:TEXT								//60,0 - Municipio
	cUF    		:= oNFeDetail:_DEST:_ENDERDEST:_UF:TEXT							 			//02,0 - UF
	cCEP   		:= oNFeDetail:_DEST:_ENDERDEST:_CEP:TEXT									//08,0 - CEP
	if XmlChildEx(oNFeDetail:_DEST:_ENDERDEST,"_FONE") != NIL
		cFone 	:= oNFeDetail:_DEST:_ENDERDEST:_FONE:TEXT									//14,0 - Telefone
	endif
	if XmlChildEx(oNFeDetail:_DEST,"_EMAIL") != NIL
		ceMail 	:= Lower(oNFeDetail:_DEST:_EMAIL:TEXT)									//60,0 - e-Mail
	endif

	nVICMS 		:= Val(oNFeDetail:_TOTAL:_ICMSTOT:_VICMS:TEXT)								//12,2 - Vlr ICMS
	nVProd 		:= Val(oNFeDetail:_TOTAL:_ICMSTOT:_VPROD:TEXT)								//12,2 - Vlr Mercador
	nVFrete		:= Val(oNFeDetail:_TOTAL:_ICMSTOT:_VFRETE:TEXT)								//12,2 - Vlr Frete
	nVseg  		:= Val(oNFeDetail:_TOTAL:_ICMSTOT:_VSEG:TEXT)								//12,2 - Vlr Seguro
	nVDesc 		:= 0	//Val(oNFeDetail:_TOTAL:_ICMSTOT:_VDESC:TEXT)						//12,2 - Vlr Desconto
	nVIPI  		:= Val(oNFeDetail:_TOTAL:_ICMSTOT:_VIPI:TEXT)								//12,2 - Vlr IPI
	nVOutro		:= Val(oNFeDetail:_TOTAL:_ICMSTOT:_VOUTRO:TEXT)								//12,2 - Vlr Outros
	nVICDes		:= Val(oNFeDetail:_TOTAL:_ICMSTOT:_VICMSDESON:TEXT)							//12,2 - Vlr ICM Des
	nVST   		:= Val(oNFeDetail:_TOTAL:_ICMSTOT:_VST:TEXT)								//12,2 - Vlr ICMS ST
	nVII   		:= Val(oNFeDetail:_TOTAL:_ICMSTOT:_VII:TEXT)								//12,2 - Vlr I.Import
	nVIPIDv		:= Val(oNFeDetail:_TOTAL:_ICMSTOT:_VIPIDEVOL:TEXT)							//12,2 - Vlr IP.Devol
	nVNF   		:= Val(oNFeDetail:_TOTAL:_ICMSTOT:_VNF:TEXT)								//12,2 - Total NF

	cModFrete	:= oNFeDetail:_TRANSP:_MODFRETE:TEXT		 								//01,0 - Modal. Frete
	if XmlChildEx(oNFeDetail:_TRANSP,"_TRANSPORTA") != NIL
		if XmlChildEx(oNFeDetail:_TRANSP:_TRANSPORTA,"_CNPJ") != NIL
			cCNPJTran	:= oNFeDetail:_TRANSP:_TRANSPORTA:_CNPJ:TEXT		  				//14,0 - CNPJ Transp
		endif
		if XmlChildEx(oNFeDetail:_TRANSP:_TRANSPORTA,"_XNOME") != NIL
			cNomeTran	:= oNFeDetail:_TRANSP:_TRANSPORTA:_XNOME:TEXT						//50,0 - Nome Transp
		endif
		if XmlChildEx(oNFeDetail:_TRANSP:_TRANSPORTA,"_IE") != NIL
			cInscTran	:= oNFeDetail:_TRANSP:_TRANSPORTA:_IE:TEXT							//14,0 - Inscr.Trans.
		endif
		if XmlChildEx(oNFeDetail:_TRANSP:_TRANSPORTA,"_XENDER") != NIL
			cEndTran 	:= oNFeDetail:_TRANSP:_TRANSPORTA:_XENDER:TEXT						//60,0 - End. Transp.
		endif
		if XmlChildEx(oNFeDetail:_TRANSP:_TRANSPORTA,"_XMUN") != NIL
			cMunTran 	:= oNFeDetail:_TRANSP:_TRANSPORTA:_XMUN:TEXT						//40,0 - Mun. Transp.
		endif
		if XmlChildEx(oNFeDetail:_TRANSP:_TRANSPORTA,"_UF") != NIL
			cUFTran  	:= oNFeDetail:_TRANSP:_TRANSPORTA:_UF:TEXT							//02,0 - UF Transp.
		endif
	endif

	if XmlChildEx(oNFeDetail:_TRANSP,"_VOL") != NIL
		if XmlChildEx(oNFeDetail:_TRANSP:_VOL,"_QVOL") != NIL
			nVolume  	:= Val(oNFeDetail:_TRANSP:_VOL:_QVOL:TEXT)							//09,0 - Volume
		endif
		if XmlChildEx(oNFeDetail:_TRANSP:_VOL,"_ESP") != NIL
			cEspecie  	:= oNFeDetail:_TRANSP:_VOL:_ESP:TEXT								//02,0 - Especie
		endif
		if XmlChildEx(oNFeDetail:_TRANSP:_VOL,"_PESOL") != NIL
			nPesoLiq 	:= Val(oNFeDetail:_TRANSP:_VOL:_PESOL:TEXT)							//12,3 - Peso Liquido
		endif
		if XmlChildEx(oNFeDetail:_TRANSP:_VOL,"_PESOB") != NIL
			nPesoBru 	:= Val(oNFeDetail:_TRANSP:_VOL:_PESOB:TEXT)							//12,3 - Peso Bruto
		endif
	endif
	if XmlChildEx(oNFeDetail:_IDE,"_NFREF") != NIL
		cRefNFe		:=  oNFeDetail:_IDE:_NFREF:_REFNFE:TEXT									//47,0 - Ident. NFe
	endif

	//———————————————————————————————————————————————————————————————————————————————
	// Identifica o tipo de destinatário/origem (Cliente ou Fornecedor)
	//———————————————————————————————————————————————————————————————————————————————
	cCliente 	:= Space(Len(ZZ7->ZZ7_CLIENT))
	cLojaCli	:= Space(Len(ZZ7->ZZ7_LOJCLI))
	cFornece 	:= Space(Len(ZZ7->ZZ7_FORNEC))
	cLojaFor	:= Space(Len(ZZ7->ZZ7_LOJFOR))

	if (cTpNF == "0" .and. cFinNFe != "4") .or. (cTpNF == "1" .and. cFinNFe == "4")
		cTpDest := "F"
	else
		cTpDest := "C"
	endif

	//———————————————————————————————————————————————————————————————————————————————
	// Duplicatas
	//———————————————————————————————————————————————————————————————————————————————
	if XmlChildEx(oNFeDetail,"_COBR") != NIL
		if XmlChildEx(oNFeDetail:_COBR,"_DUP") != NIL

			if Type("oNFeDetail:_COBR:_DUP")  == "A"
				For nX := 1 to Len(oNFeDetail:_COBR:_DUP)
					cStrDuplic += StrTran(oNFeDetail:_COBR:_DUP[nX]:_DVENC:TEXT,"-","") + ";" + AllTrim(oNFeDetail:_COBR:_DUP[nX]:_VDUP:TEXT) + "#"
				Next
			else

	//MUDAR
				FOR NI:=1 TO 3
					cStrDuplic += StrTran(oNFeDetail:_COBR:_DUP:_DVENC:TEXT,"-","") + ";" + AllTrim(oNFeDetail:_COBR:_DUP:_VDUP:TEXT) + "#"
				NEXT

			endif

		endif
	endif
	if Len(cStrDuplic) > 0
		cStrDuplic := Left(cStrDuplic, Len(cStrDuplic)-1)
	endif

	//———————————————————————————————————————————————————————————————————————————————
	// Itens da nota
	//———————————————————————————————————————————————————————————————————————————————
	if Type("oNFeDetail:_DET") == "A"
		//Mais de um item
		For nX:=1 To Len(oNFeDetail:_DET)
			aAdd(aItens, B19_READITEM(oNFeDetail:_DET[nX]))
		Next
	else
		//Um unico item
		aAdd(aItens, B19_READITEM(oNFeDetail:_DET))
	endif


	//———————————————————————————————————————————————————————————————————————————————
	// Busca código do cliente ou fornecedor
	//———————————————————————————————————————————————————————————————————————————————
	if cTpDest == "C"
		lCadCliFor := U_MNT01CliCad(	{	cIdOrDe,;
											cNome,;
											cCodMun,;
											cUF,;
											cLograd,;
											cNro,;
											cIE,;
											cCompl,;
											cBairro,;
											cCEP,;
											cFone,;
											ceMail},;
											cIdNF	)
		if lCadCliFor
			//dbSelectArea("SA1")
			//if dbSeek(xFilial("SA1") + cIdOrDe)
			//if SA1->(dbSeek(xFilial("SA1") + cIdOrDe))
			cCliente 	:= SA1->A1_COD
			cLojaCli	:= SA1->A1_LOJA
		else
			U_GrvLogIC("MNT01CliCad", cIdNF, cIdOrDe, "CPF/CNPJ enviado pela integração, não foi encontrado no cadastro de clientes.")
		endif

	else

		lCadCliFor := U_MNT01ForCad(	{	cIdOrDe,;
											cNome,;
											cCodMun,;
											cUF,;
											cLograd,;
											cNro,;
											cIE,;
											cCompl,;
											cBairro,;
											cCEP,;
											cFone,;
											ceMail},;
											cIdNF	)
		if lCadCliFor
			//if SA2->(dbSeek(xFilial("SA2") + cIdOrDe))
			cFornece 	:= SA2->A2_COD
			cLojaFor	:= SA2->A2_LOJA
		else
			U_GrvLogIC("MNT01ForCad", cIdNF, cIdOrDe, "CPF/CNPJ enviado pela integração, não foi encontrado no cadastro de fornecedores.")
		endif

	endif


	//Begin Transaction
	For nX := 1 to Len(aItens)

		if SB1->(dbSeek(xFilial("SB1") + aItens[nX,2]))
			cMPProd 	:= SB1->B1_COD
		else
			cMPProd 	:= Space(15)
			U_GrvLogIC("Pesquisa Produto", cIdNF, aItens[nX,3], "Código de produto enviado pela integração, não foi encontrado no cadastro de produtos.")
		endif

		cMPTES	:= GetTES(aItens[nX,8], aItens[nX,7], aItens[nX,16], cIE, cIdNF)

		aNFDevol := {}
		if cFinNFe == "4"
			aNFDevol := GetNFDevol(cRefNFe, cCliente, cLojaCli, cMPProd, aItens[nX,10])
		endif

		//———————————————————————————————————————————————————————————————————————————————
		// Verificando o Status da importação
		//———————————————————————————————————————————————————————————————————————————————
		if Empty(cMPTES) .or.;
			Empty(cMPProd) .or.;
			(cFinNFe=="4" .and. (Empty(aNFDevol[1]) .or. Empty(aNFDevol[2]) .or. Empty(aNFDevol[3]))) .or.;
			AllTrim(cIdEmit) != AllTrim(SM0->M0_CGC)
		
			cStatus	:= "2"
		endif

		ZZ8->(RecLock("ZZ8", .T.))
		ZZ8->ZZ8_FILIAL		:= xFilial("ZZ8")
		ZZ8->ZZ8_IDNF  		:= cIdNF
		ZZ8->ZZ8_ITEM  		:= aItens[nX,1]
		ZZ8->ZZ8_MPPROD		:= cMPProd				//Codigo produto Protheus
		ZZ8->ZZ8_MPTES 		:= cMPTES			 	//Codigo tipo entr./saida
		ZZ8->ZZ8_CPROD 		:= aItens[nX,2]			//Produto no XML
		ZZ8->ZZ8_CEAN  		:= aItens[nX,3]			//Codigo EAN
		ZZ8->ZZ8_XPROD 		:= aItens[nX,5]			//Descricao do produto XML
		ZZ8->ZZ8_NCM  	 	:= aItens[nX,6]			//Codigo NCM
		ZZ8->ZZ8_CFOP  		:= aItens[nX,8]			//Codigo do CFOP
		ZZ8->ZZ8_UCOM  		:= aItens[nX,9]			//Unidade comercial
		ZZ8->ZZ8_QCOM		:= aItens[nX,10]		//Quantidade comercial
		ZZ8->ZZ8_VUNCOM		:= aItens[nX,11]		//Valor unidade comercial
		ZZ8->ZZ8_VPROD		:= aItens[nX,12]		//Valor total do item
		ZZ8->ZZ8_CEANTR		:= aItens[nX,4]			//Codigo GTIN da unid. trib
		ZZ8->ZZ8_UTRIB 		:= aItens[nX,13]		//Unidade tributavel
		ZZ8->ZZ8_QTRIB		:= aItens[nX,14]		//Quantidade tributavel
		ZZ8->ZZ8_VUNTRI		:= aItens[nX,15]		//Valor unidade tributavel
		ZZ8->ZZ8_ORIGEM		:= aItens[nX,7]			//Origem do produto
		ZZ8->ZZ8_CSTICM		:= aItens[nX,16]		//Codigo CST ICMS
		ZZ8->ZZ8_PICMS		:= aItens[nX,17]		//Aliquota do ICMS
		ZZ8->ZZ8_VBCICM		:= aItens[nX,18]		//Base de calculo do ICMS
		ZZ8->ZZ8_VICMS		:= aItens[nX,19]		//Valor do ICMS
		ZZ8->ZZ8_VBCST		:= aItens[nX,20]		//Base Calculo do ICMS ST
		//ZZ8->ZZ8_PICMST	:= aItens[nX,21]		//Aliquota ICMS ST
		ZZ8->ZZ8_VICMST		:= aItens[nX,21]		//Valor ICMS ST
		ZZ8->ZZ8_CSTIPI		:= aItens[nX,22]		//Codigo CST IPI
		ZZ8->ZZ8_VBCIPI		:= aItens[nX,24]		//Base calculo IPI
		ZZ8->ZZ8_PIPI		:= aItens[nX,23]		//Aliquota IPI
		ZZ8->ZZ8_VIPI		:= aItens[nX,25]		//Valor IPI
		ZZ8->ZZ8_DIFAL		:= aItens[nX,26]		//Valor DIFAL
		//ZZ8->ZZ8_CSTPIS	:= aItens[nX,26]		//Codigo CST PIS
		//ZZ8->ZZ8_CSTCOF	:= aItens[nX,27]		//Codigo CST COFINS
		if Len(aNFDevol) > 0
			ZZ8->ZZ8_NFORI		:= aNFDevol[1]
			ZZ8->ZZ8_SERORI		:= aNFDevol[2]
			ZZ8->ZZ8_ITORI		:= aNFDevol[3]
		endif
		ZZ8->(MsUnLock())

	Next

	ZZ7->(RecLock("ZZ7", .T.))
	ZZ7->ZZ7_FILIAL		:= xFilial("ZZ7")
	ZZ7->ZZ7_IDEMIT		:= cIdEmit		//14,0 - CNPJ Emissor
	ZZ7->ZZ7_IDNF		:= cIdNF		//47,0 - Ident. NFe
	ZZ7->ZZ7_NNF		:= cNF			//09,0 - Nota Fiscal
	ZZ7->ZZ7_SERIE		:= cSerie		//03,0 - Serie
	ZZ7->ZZ7_NATOP		:= cNatOp 		//30,0 - Nat. Operac
	ZZ7->ZZ7_MOD		:= cMod   		//02,0 - Modelo NF
	ZZ7->ZZ7_DTEMIS		:= dDtEmis		//08,0 - Data Emissao
	ZZ7->ZZ7_HREMIS		:= cHrEmis		//08,0 - Hora Emissao
	ZZ7->ZZ7_TPNF  		:= cTpNF  		//01,0 - Tipo Operac
	ZZ7->ZZ7_DESTOP		:= cDestOp		//01,0 - Destino Oper
	ZZ7->ZZ7_TPAMB 		:= cTpAmb 		//01,0 - Tipo Ambient
	ZZ7->ZZ7_FINNFE		:= cFinNFe		//01,0 - Finalidade
	ZZ7->ZZ7_TPDEST		:= cTpDest
	ZZ7->ZZ7_CLIENT		:= cCliente
	ZZ7->ZZ7_LOJCLI		:= cLojaCli
	ZZ7->ZZ7_FORNEC		:= cFornece
	ZZ7->ZZ7_LOJFOR		:= cLojaFor
	ZZ7->ZZ7_IDORDE		:= cIdOrDe		//14,0 - CPF/CNPJ
	ZZ7->ZZ7_XNOME 		:= cNome  		//60,0 - Nome
	ZZ7->ZZ7_XLGR  		:= cLograd 		//60,0 - Logradouro
	ZZ7->ZZ7_NRO   		:= cNro   		//10,0 - Nro
	ZZ7->ZZ7_XCPL  		:= cCompl 	 	//30,0 - Complemento
	ZZ7->ZZ7_XBAIRR		:= cBairro		//40,0 - Bairro
	ZZ7->ZZ7_CMUN  		:= cCodMun 		//02,0 - Cod. Municip
	ZZ7->ZZ7_XMUN  		:= cMunic  		//60,0 - Municipio
	ZZ7->ZZ7_UF    		:= cUF    		//02,0 - UF
	ZZ7->ZZ7_CEP   		:= cCEP   		//08,0 - CEP
	ZZ7->ZZ7_IE    		:= cIE			//14,0 - Inscr.Estad.
	ZZ7->ZZ7_FONE  		:= cFone  		//14,0 - Telefone
	ZZ7->ZZ7_EMAIL 		:= ceMail 		//60,0 - e-Mail
	ZZ7->ZZ7_VICMS		:= nVICMS 		//12,2 - Vlr ICMS
	ZZ7->ZZ7_VPROD 		:= nVProd 		//12,2 - Vlr Mercador
	ZZ7->ZZ7_VFRETE		:= nVFrete		//12,2 - Vlr Frete
	ZZ7->ZZ7_VSEG  		:= nVseg  		//12,2 - Vlr Seguro
	//ZZ7->ZZ7_VDESC 	:= nVDesc 		//12,2 - Vlr Desconto
	ZZ7->ZZ7_VIPI  		:= nVIPI  		//12,2 - Vlr IPI
	ZZ7->ZZ7_VOUTRO		:= nVOutro		//12,2 - Vlr Outros
	ZZ7->ZZ7_VICDES		:= nVICDes		//12,2 - Vlr ICM Des
	ZZ7->ZZ7_VST   		:= nVST   		//12,2 - Vlr ICMS ST
	ZZ7->ZZ7_VII   		:= nVII   		//12,2 - Vlr I.Import
	ZZ7->ZZ7_VIPIDV		:= nVIPIDv		//12,2 - Vlr IP.Devol
	ZZ7->ZZ7_VNF   		:= nVNF   		//12,2 - Total NF
	ZZ7->ZZ7_MODFRE		:= cModFrete	//01,0 - Modal. Frete
	ZZ7->ZZ7_CNPJTR		:= cCNPJTran	//14,0 - CNPJ Transp.
	ZZ7->ZZ7_NOMETR		:= cNomeTran	//50,0 - Nome Transp.
	ZZ7->ZZ7_INSCTR		:= cInscTran	//14,0 - Inscr.Trans.
	ZZ7->ZZ7_ENDTR 		:= cEndTran 	//60,0 - End. Transp.
	ZZ7->ZZ7_MUNTR 		:= cMunTran 	//40,0 - Mun. Transp.
	ZZ7->ZZ7_UFTR  		:= cUFTran  	//02,0 - UF Transp.
	ZZ7->ZZ7_QVOL  		:=	nVolume  	//09,0 - Volume
	ZZ7->ZZ7_ESP   		:= cEspecie  	//02,0 - Especie
	ZZ7->ZZ7_PESOL 		:= nPesoLiq 	//12,3 - Peso Liquido
	ZZ7->ZZ7_PESOB 		:= nPesoBru 	//12,3 - Peso Bruto
	ZZ7->ZZ7_REFNFE		:= cRefNFe		//47,0 - Ident. NFe

	ZZ7->ZZ7_TITULO		:= cStrDuplic
	
	ZZ7->ZZ7_XML   		:= cBuffer
	ZZ7->ZZ7_LOG   		:= "Incluído em " + dTOc(Date()) + " as " + Time() + " Id.NFe " + cIdNF + chr(13) + chr(10) + Repl("=", 100)

	ZZ7->ZZ7_STATUS		:= cStatus

	ZZ7->(MsUnLock())

	//End Transaction

	//———————————————————————————————————————————————————————————————————————————————
	// Inicia o processo de integração. Dentro do processo MNT01Integra, é verificado
	// se o status do registro está apto a ser processado.
	//———————————————————————————————————————————————————————————————————————————————
	U_MNT01Integra(.F.)		//processo automático (manual=.F.)
	
	//———————————————————————————————————————————————————————————————————————————————
	// Recupera logs das transações realizadas e grava no ZZ7_LOG
	//———————————————————————————————————————————————————————————————————————————————
	U_CommitLog(cIdNF)

endif

Return()


	/*/
	———————————————————————————————————————————————————————————————————————————————
	@function		B19_ReadItem                                                 /@
	@type			Static function                                              /@
	@date			04/04/2019                                                   /@
	@description	Lê conteúdo do objeto referente ao item da NF e retorna vetor/@
	@author			Adalberto Moreno Batista (Opção Um)                          /@
	@use			Brasitech                                                    /@
	———————————————————————————————————————————————————————————————————————————————
	/*/
	Static Function B19_READITEM(oNFeItem)
	Local aRet 		:= {}
	Local cOrigem	:= ""
	Local cCSTICMS 	:= ""
	Local nPICMS	:= 0
	Local nBICMS	:= 0
	Local nVICMS	:= 0
	Local nBICMSST	:= 0
	Local nVICMSST	:= 0
	Local cCSTIPI  	:= ""
	Local nPIPI		:= 0
	Local nBIPI		:= 0
	Local nVIPI		:= 0
	Local nDIFAL	:= 0
	Local cItem


	if XmlChildEx(oNFeItem,"_IMPOSTO") != NIL		//verificando se existe tag IMPOSTO

		//———————————————————————————————————————————————————————————————————————————————
		// Identifica informações de ICMS
		//———————————————————————————————————————————————————————————————————————————————
		if XmlChildEx(oNFeItem:_IMPOSTO,"_ICMS") != NIL		//verificando se existe tag ICMS

			if XmlChildEx(oNFeItem:_IMPOSTO:_ICMS,"_ICMS00") != NIL				//00 - Tributada integralmente

				cCSTICMS	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS00:_CST:TEXT
				cOrigem	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS00:_ORIG:TEXT

				if XmlChildEx(oNFeItem:_IMPOSTO:_ICMS:_ICMS00,"_PICMS") != NIL
					nPICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS00:_PICMS:TEXT)
				endif
				if XmlChildEx(oNFeItem:_IMPOSTO:_ICMS:_ICMS00,"_VBC") != NIL
					nBICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS00:_VBC:TEXT)
				endif
				if XmlChildEx(oNFeItem:_IMPOSTO:_ICMS:_ICMS00,"_VICMS") != NIL
					nVICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS00:_VICMS:TEXT)
				endif

			elseif XmlChildEx(oNFeItem:_IMPOSTO:_ICMS,"_ICMS10") != NIL			//10 - Tributada e com cobrança do ICMS por substituição tributária

				cCSTICMS	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS10:_CST:TEXT
				cOrigem	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS10:_ORIG:TEXT

				if XmlChildEx(oNFeItem:_IMPOSTO:_ICMS:_ICMS10,"_PICMS") != NIL
					nPICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS10:_PICMS:TEXT)
				endif
				if XmlChildEx(oNFeItem:_IMPOSTO:_ICMS:_ICMS10,"_VBC") != NIL
					nBICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS10:_VBC:TEXT)
				endif
				if XmlChildEx(oNFeItem:_IMPOSTO:_ICMS:_ICMS10,"_VICMS") != NIL
					nVICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS10:_VICMS:TEXT)
				endif

			elseif XmlChildEx(oNFeItem:_IMPOSTO:_ICMS,"_ICMS20") != NIL			//20 - Com redução de base de cálculo

				cCSTICMS	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS20:_CST:TEXT
				cOrigem	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS20:_ORIG:TEXT

				if XmlChildEx(oNFeItem:_IMPOSTO:_ICMS:_ICMS20,"_PICMS") != NIL
					nPICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS20:_PICMS:TEXT)
				endif
				if XmlChildEx(oNFeItem:_IMPOSTO:_ICMS:_ICMS20,"_VBC") != NIL
					nBICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS20:_VBC:TEXT)
				endif
				if XmlChildEx(oNFeItem:_IMPOSTO:_ICMS:_ICMS20,"_VICMS") != NIL
					nVICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS20:_VICMS:TEXT)
				endif

			elseif XmlChildEx(oNFeItem:_IMPOSTO:_ICMS,"_ICMS30") != NIL			//30 - Isenta ou não tributada e com cobrança do ICMS por substituição tributária

				cCSTICMS	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS30:_CST:TEXT
				cOrigem		:= oNFeItem:_IMPOSTO:_ICMS:_ICMS30:_ORIG:TEXT

				if XmlChildEx(oNFeItem:_IMPOSTO:_ICMS:_ICMS30,"_PICMS") != NIL
					nPICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS30:_PICMS:TEXT)
				endif
				if XmlChildEx(oNFeItem:_IMPOSTO:_ICMS:_ICMS30,"_VBC") != NIL
					nBICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS30:_VBC:TEXT)
				endif
				if XmlChildEx(oNFeItem:_IMPOSTO:_ICMS:_ICMS30,"_VICMS") != NIL
					nVICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS30:_VICMS:TEXT)
				endif

			elseif XmlChildEx(oNFeItem:_IMPOSTO:_ICMS,"_ICMS40") != NIL			//40 - Isenta
				cCSTICMS	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS40:_CST:TEXT
				cOrigem		:= oNFeItem:_IMPOSTO:_ICMS:_ICMS40:_ORIG:TEXT

			elseif XmlChildEx(oNFeItem:_IMPOSTO:_ICMS,"_ICMS41") != NIL			//41 - Não tributada
				cCSTICMS	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS41:_CST:TEXT
				cOrigem	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS41:_ORIG:TEXT

			elseif XmlChildEx(oNFeItem:_IMPOSTO:_ICMS,"_ICMS50") != NIL			//50 - Suspensão

				cCSTICMS	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS50:_CST:TEXT
				cOrigem		:= oNFeItem:_IMPOSTO:_ICMS:_ICMS50:_ORIG:TEXT

				if XmlChildEx(oNFeItem:_IMPOSTO:_ICMS:_ICMS50,"_PICMS") != NIL
					nPICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS50:_PICMS:TEXT)
				endif
				if XmlChildEx(oNFeItem:_IMPOSTO:_ICMS:_ICMS50,"_VBC") != NIL
					nBICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS50:_VBC:TEXT)
				endif
				if XmlChildEx(oNFeItem:_IMPOSTO:_ICMS:_ICMS50,"_VICMS") != NIL
					nVICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS50:_VICMS:TEXT)
				endif

			elseif XmlChildEx(oNFeItem:_IMPOSTO:_ICMS,"_ICMS51") != NIL			//51 - Diferimento

				cCSTICMS	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS51:_CST:TEXT
				cOrigem		:= oNFeItem:_IMPOSTO:_ICMS:_ICMS51:_ORIG:TEXT

				if XmlChildEx(oNFeItem:_IMPOSTO:_ICMS:_ICMS51,"_PICMS") != NIL
					nPICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS51:_PICMS:TEXT)
				endif
				if XmlChildEx(oNFeItem:_IMPOSTO:_ICMS:_ICMS51,"_VBC") != NIL
					nBICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS51:_VBC:TEXT)
				endif
				if XmlChildEx(oNFeItem:_IMPOSTO:_ICMS:_ICMS51,"_VICMS") != NIL
					nVICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS51:_VICMS:TEXT)
				endif

			elseif XmlChildEx(oNFeItem:_IMPOSTO:_ICMS,"_ICMS60") != NIL			//60 - ICMS cobrado anteriormente por substituição tributária

				cCSTICMS	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS60:_CST:TEXT
				cOrigem		:= oNFeItem:_IMPOSTO:_ICMS:_ICMS60:_ORIG:TEXT

				if XmlChildEx(oNFeItem:_IMPOSTO:_ICMS:_ICMS60,"_PICMS") != NIL
					nPICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS60:_PICMS:TEXT)
				endif
				if XmlChildEx(oNFeItem:_IMPOSTO:_ICMS:_ICMS60,"_VBC") != NIL
					nBICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS60:_VBC:TEXT)
				endif
				if XmlChildEx(oNFeItem:_IMPOSTO:_ICMS:_ICMS60,"_VICMS") != NIL
					nVICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS60:_VICMS:TEXT)
				endif

			elseif XmlChildEx(oNFeItem:_IMPOSTO:_ICMS,"_ICMS70") != NIL			//70 - Com redução de base de cálculo e cobrança do ICMS por substituição tributária

				cCSTICMS	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS70:_CST:TEXT
				cOrigem		:= oNFeItem:_IMPOSTO:_ICMS:_ICMS70:_ORIG:TEXT

				if XmlChildEx(oNFeItem:_IMPOSTO:_ICMS:_ICMS70,"_PICMS") != NIL
					nPICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS70:_PICMS:TEXT)
				endif
				if XmlChildEx(oNFeItem:_IMPOSTO:_ICMS:_ICMS70,"_VBC") != NIL
					nBICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS70:_VBC:TEXT)
				endif
				if XmlChildEx(oNFeItem:_IMPOSTO:_ICMS:_ICMS70,"_VICMS") != NIL
					nVICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS70:_VICMS:TEXT)
				endif

			elseif XmlChildEx(oNFeItem:_IMPOSTO:_ICMS,"_ICMS90") != NIL			//90 - Outras

				cCSTICMS	:= oNFeItem:_IMPOSTO:_ICMS:_ICMS90:_CST:TEXT
				cOrigem		:= oNFeItem:_IMPOSTO:_ICMS:_ICMS90:_ORIG:TEXT
				if XmlChildEx(oNFeItem:_IMPOSTO:_ICMS:_ICMS90,"_PICMS") != NIL
					nPICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS90:_PICMS:TEXT)
				endif
				if XmlChildEx(oNFeItem:_IMPOSTO:_ICMS:_ICMS90,"_VBC") != NIL
					nBICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS90:_VBC:TEXT)
				endif
				if XmlChildEx(oNFeItem:_IMPOSTO:_ICMS:_ICMS90,"_VICMS") != NIL
					nVICMS	:= Val(oNFeItem:_IMPOSTO:_ICMS:_ICMS90:_VICMS:TEXT)
				endif

			endif

		endif

		//———————————————————————————————————————————————————————————————————————————————
		// Identifica informações de IPI
		//———————————————————————————————————————————————————————————————————————————————
		if XmlChildEx(oNFeItem:_IMPOSTO,"_IPI") != NIL		//Verifico se existe a tag IPI

			if XmlChildEx(oNFeItem:_IMPOSTO:_IPI,"_IPITRIB") != NIL
				cCSTIPI		:= oNFeItem:_IMPOSTO:_IPI:_IPITRIB:_CST:TEXT
				nPIPI		:= Val(oNFeItem:_IMPOSTO:_IPI:_IPITRIB:_PIPI:TEXT)
				nBIPI		:= Val(oNFeItem:_IMPOSTO:_IPI:_IPITRIB:_VBC:TEXT)
				nVIPI		:= Val(oNFeItem:_IMPOSTO:_IPI:_IPITRIB:_VIPI:TEXT)
			endif

		endif

		//———————————————————————————————————————————————————————————————————————————————
		// Identifica informações de DIFAL / ICMS no destino
		//———————————————————————————————————————————————————————————————————————————————
		if XmlChildEx(oNFeItem:_IMPOSTO,"_ICMSUFDEST") != NIL .and. XmlChildEx(oNFeItem:_IMPOSTO:_ICMSUFDEST,"_VICMSUFDEST") != NIL
			//Val(oNFeItem:_IMPOSTO:_ICMSUFDEST:_VICMSUFREMET:TEXT)
			nDIFAL	:= Val(oNFeItem:_IMPOSTO:_ICMSUFDEST:_VICMSUFDEST:TEXT)
		endif

	endif

	//———————————————————————————————————————————————————————————————————————————————
	// Monta retorno do item, com valores de impostos
	//———————————————————————————————————————————————————————————————————————————————
	//if Left(oNFeItem:_PROD:_CFOP:TEXT,1) < "4"
		cItem	:= StrZero(Val(oNFeItem:_NITEM:TEXT),4)
	//else
	//	cItem	:= StrZero(Val(oNFeItem:_NITEM:TEXT),2)
	//endif

	aRet	:= {	cItem,;
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
					nDIFAL}

	Return(aRet)

/*/
———————————————————————————————————————————————————————————————————————————————
@function		C19_BRAJOB	                                                 /@
@type			Static function                                              /@
@date			12/07/2021                                                   /@
@description	Registra notas inutilizadas e grava em tabela ZZ7            /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function C19_BRAJOB(cBuffer, lNFCancel)
Local cEspecie  	:= ""
Local cAviso		:= ""
Local cErro			:= ""
Local oNFe			:= XmlParser(cBuffer, "_", @cAviso, @cErro)
Local cCliente		:= SuperGetMV("MV_INUTCLI", .F., "")
Local cProduto		:= SuperGetMV("MV_INUTPRO", .F., "")
Local cTES			:= SuperGetMV("MV_INUTTES", .F., "")
Local cIdEmit		:= oNFe:_RETINUTNFE:_INFINUT:_CNPJ:TEXT
Local cTpAmb		:= oNFe:_RETINUTNFE:_INFINUT:_TPAMB:TEXT
Local cRetSEFAZ		:= oNFe:_RETINUTNFE:_INFINUT:_CSTAT:TEXT
Local cMotivo		:= oNFe:_RETINUTNFE:_INFINUT:_XMOTIVO:TEXT
Local cSerie		:= PadR(oNFe:_RETINUTNFE:_INFINUT:_SERIE:TEXT, Len(SF2->F2_SERIE))
Local cProtocolo	:= oNFe:_RETINUTNFE:_INFINUT:_NPROT:TEXT
Local dDtEmis		:= sTOd(StrTran(Left(oNFe:_RETINUTNFE:_INFINUT:_DHRECBTO:TEXT, 10), "-", ""))
Local cHrEmis		:= Substr(oNFe:_RETINUTNFE:_INFINUT:_DHRECBTO:TEXT, 12, 8)
Local nNFIni		:= Val(oNFe:_RETINUTNFE:_INFINUT:_NNFINI:TEXT)
Local nNFFin		:= Val(oNFe:_RETINUTNFE:_INFINUT:_NNFFIN:TEXT)
Local cNF, cLojaCli, nX, aCabNFInut, aLinNFInut

SA1->(dbSetOrder(1))		//A1_FILIAL, A1_COD, A1_LOJA
SB1->(dbSetOrder(1))		//B1_FILIAL, B1_COD
SF4->(dbSetOrder(1))		//F4_FILIAL, F4_CODIGO

If oNFe:_RETINUTNFE:_INFINUT:_MOD:TEXT == "57"
	cEspecie  := "CTE"
Elseif oNFe:_RETINUTNFE:_INFINUT:_MOD:TEXT == "65"
	cEspecie  := "NFCE"
ElseIf oNFe:_RETINUTNFE:_INFINUT:_MOD:TEXT == "55"
	cEspecie	:= "SPED"
else
	cEspecie	:= ""
EndIf

if AllTrim(cIdEmit) == AllTrim(SM0->M0_CGC) .and. SA1->(dbSeek(xFilial("SA1") + cCliente))

	cLojaCli	:= SA1->A1_LOJA
	SB1->(dbSeek(xFilial("SB1") + cProduto))
	SF4->(dbSeek(xFilial("SF4") + cTES))

	// Inclui a nota na base pela rotina automática MATA920
	for nX := nNFIni to nNFFin

		cNF := StrZero(nX, 9)	//TamSX3("F2_DOC")[1])

		SF3->(dbSetOrder(1))		//F3_FILIAL, F3_ENTRADA, F3_NFISCAL, F3_SERIE, F3_CLIEFOR, F3_LOJA, F3_CFO, F3_ALIQICM
		if SF3->(dbSeek(xFilial("SF3") + dTOs(dDtEmis) + cNF + cSerie + cCliente + cLojaCli))
			If SubStr(SF3->F3_CFO,1,1) $ "1,2,3"
				If AllTrim(SF3->F3_ESPECIE) == cEspecie .And.  SF3->F3_FORMUL == 'S'
					Loop
				EndIf
			ElseIf SubStr(SF3->F3_CFO,1,1) $ "5,6,7"
				If AllTrim(SF3->F3_ESPECIE) == cEspecie
					Loop
				EndIf
			EndIf
		endif

		//Pesquiso se já existe na tabela ZZ7
		ZZ7->(dbSetOrder(1))		//ZZ7_FILIAL, ZZ7_NNF, ZZ7_SERIE
		if !ZZ7->(dbSeek(xFilial("ZZ7") + cNF + cSerie))

			aCabNFInut 	:= {	{"F2_TIPO",		"N", 				Nil},;
								{"F2_FORMUL", 	" ", 				Nil},;
								{"F2_DOC",		cNF,				Nil},;
								{"F2_SERIE",	cSerie, 			Nil},;
								{"F2_EMISSAO",	dDtEmis, 			Nil},;
								{"F2_CLIENTE",	cCliente, 			Nil},;
								{"F2_LOJA",		cLojaCli, 			Nil},;
								{"F2_ESPECIE",	cEspecie, 			Nil},;
								{"F2_DESCONT", 	0, 					Nil},;
								{"F2_FRETE", 	0, 					Nil},;
								{"F2_SEGURO", 	0, 					Nil},;
								{"F2_DESPESA", 	0, 					Nil}}

			aLinNFInut	:= {{	{"D2_COD",		cProduto, 			Nil},;
								{"D2_QUANT",	1, 					Nil},;
								{"D2_PRCVEN",	1, 					Nil},;
								{"D2_TOTAL",	1, 					Nil},;
								{"D2_TES",		cTES, 				Nil}}}

			MATA920(aCabNFInut, aLinNFInut, 3)		// Inclui a nota na base pela rotina automática MATA920
			SF2->(dbSetOrder(1))						//F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, F2_TIPO
			if SF2->(dbSeek(xFilial("SF2") + cNF + cSerie + cCliente + cLojaCli))
				MATA920(aCabNFInut, aLinNFInut, 5)		// Exclui a nota na base pela rotina automática MATA920

				SF3->(dbSetOrder(1))		//F3_FILIAL, F3_ENTRADA, F3_NFISCAL, F3_SERIE, F3_CLIEFOR, F3_LOJA, F3_CFO, F3_ALIQICM
				if SF3->(dbSeek(xFilial("SF3") + dTOs(dDtEmis) + cNF + cSerie + cCliente + cLojaCli))
					SF3->(RecLock("SF3", .F.))
					SF3->F3_PROTOC  := cProtocolo		//Protocolo de inutilizacao
					SF3->F3_EMINFE  := dDtEmis			//Data de inutilizacao
					SF3->F3_HORNFE  := cHrEmis			//Hora de inutilizacao
					SF3->F3_CODRSEF := cRetSEFAZ		//Codigo Retorno
					SF3->F3_CODRET  := "M"				//Status
					SF3->F3_OBSERV	:= "NUMERO INUTILIZADO"
					SF3->F3_DESCRET := "Inutilização de número homologado"
					SF3->(MsUnlock())
				endif

				ZZ7->(RecLock("ZZ7", .T.))
				ZZ7->ZZ7_FILIAL		:= xFilial("ZZ7")
				ZZ7->ZZ7_IDEMIT		:= cIdEmit		//14,0 - CNPJ Emissor
				ZZ7->ZZ7_NNF		:= cNF			//09,0 - Nota Fiscal
				ZZ7->ZZ7_SERIE		:= cSerie		//03,0 - Serie
				ZZ7->ZZ7_DTEMIS		:= dDtEmis		//08,0 - Data Emissao
				ZZ7->ZZ7_HREMIS		:= cHrEmis		//08,0 - Hora Emissao
				ZZ7->ZZ7_TPAMB 		:= cTpAmb 		//01,0 - Tipo Ambient
				ZZ7->ZZ7_NATOP		:= cMotivo
				ZZ7->ZZ7_XML   		:= cBuffer
				ZZ7->ZZ7_LOG   		:= "Incluído em " + dTOc(Date()) + " as " + Time()
				ZZ7->ZZ7_STATUS		:= "4"
				ZZ7->(MsUnLock())

				//Recupera logs das transações realizadas e grava no zz7_log
				U_CommitLog(cProtocolo)

			endif

		endif

	next

endif

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		GetTES                                                       /@
@type			Static function                                              /@
@date			04/04/2019                                                   /@
@description	Identifica o TES que será utilizado na nota. Como regra,
				primeiro verificará se está em uma lista pré definida e caso
				não o encontre, localiza no cadastro de TES pelo CFOP e se for
				encontrado um unico TES, retorna o conteudo                  /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
Local cRet		 	:= "  "
Local lNacional := (cOrigem $ "0#3#4#5#8")
Local lContrib	 := (!Empty(cIE) .and. !"ISENT" $ cIE)
Local aLista	 := {	{'1201',.T.,.F.,'ALL','203'},;
						{'1202',.F.,.F.,'ALL','204'},;
						{'1410',.T.,.T.,'ALL','206'},;
						{'1411',.F.,.F.,'ALL','205'}, {'1411',.F.,.T.,'ALL','205'}, {'1411',.T.,.F.,'ALL','205'}, {'1411',.T.,.T.,'ALL','205'},;
						{'1910',.F.,.F.,'ALL','045'}, {'1910',.F.,.T.,'ALL','045'}, {'1910',.T.,.F.,'ALL','045'}, {'1910',.T.,.T.,'ALL','045'},;
						{'1949',.F.,.F.,'00', '024'}, {'1949',.F.,.T.,'00', '024'}, {'1949',.T.,.F.,'00', '024'}, {'1949',.T.,.T.,'00', '024'},;
						{'1949',.F.,.F.,'60', '181'}, {'1949',.F.,.T.,'60', '181'}, {'1949',.T.,.F.,'60', '181'}, {'1949',.T.,.T.,'60', '181'},;
						{'2201',.T.,.F.,'ALL','203'}, {'2201',.T.,.T.,'ALL','203'},;
						{'2202',.F.,.F.,'ALL','204'}, {'2202',.F.,.T.,'ALL','204'},;
						{'2410',.T.,.T.,'ALL','206'},;
						{'2411',.F.,.T.,'ALL','205'},;
						{'2910',.F.,.F.,'ALL','045'}, {'2910',.F.,.T.,'ALL','045'}, {'2910',.T.,.F.,'ALL','045'}, {'2910',.T.,.T.,'ALL','045'},;
						{'2949',.F.,.F.,'ALL','024'}, {'2949',.F.,.T.,'ALL','024'}, {'2949',.T.,.F.,'ALL','024'}, {'2949',.T.,.T.,'ALL','024'},;
						{'5101',.T.,.F.,'ALL','516'},;
						{'5102',.F.,.F.,'ALL','506'},;
						{'5151',.T.,.T.,'ALL','526'},;
						{'5152',.F.,.T.,'ALL','657'},;
						{'5405',.F.,.F.,'ALL','523'}, {'5405',.F.,.T.,'ALL','523'}, {'5405',.T.,.F.,'ALL','523'}, {'5405',.T.,.T.,'ALL','523'},;
						{'5910',.F.,.F.,'ALL','507'}, {'5910',.F.,.T.,'ALL','507'}, {'5910',.T.,.F.,'ALL','507'}, {'5910',.T.,.T.,'ALL','507'},;
						{'5949',.F.,.F.,'00', '517'}, {'5949',.F.,.T.,'00', '517'}, {'5949',.T.,.F.,'00', '517'}, {'5949',.T.,.T.,'00', '517'},;
						{'5949',.F.,.F.,'60', '673'}, {'5949',.F.,.T.,'60', '673'}, {'5949',.T.,.F.,'60', '673'}, {'5949',.T.,.T.,'60', '673'},;
						{'6101',.T.,.T.,'ALL','516'},;
						{'6102',.F.,.T.,'ALL','506'},;
						{'6108',.F.,.F.,'ALL','521'}, {'6108',.T.,.F.,'ALL','521'},;
						{'6401',.T.,.T.,'ALL','501'},;
						{'6403',.F.,.T.,'ALL','530'},;
						{'6910',.F.,.F.,'ALL','507'}, {'6910',.F.,.T.,'ALL','507'}, {'6910',.T.,.F.,'ALL','507'}, {'6910',.T.,.T.,'ALL','507'},;
						{'6949',.F.,.F.,'ALL','517'}, {'6949',.F.,.T.,'ALL','517'}, {'6949',.T.,.F.,'ALL','517'}, {'6949',.T.,.T.,'ALL','517'}}

Local nPos, cTES

//———————————————————————————————————————————————————————————————————————————————
// Para situações de troca dentro do estado (5949), há diferença de TES dependendo
// do CST da operação, então, criei um novo elemento no array para determinar o
// CST e quando não houver esta necessidade, ele assumirá o conteúdo "ALL"
//———————————————————————————————————————————————————————————————————————————————
cCST := iif(cCFOP == "5949", cCST, "ALL")

//———————————————————————————————————————————————————————————————————————————————
// Primeiro tenta localizar o TES na lista pré-definida, na ordem de CFOP, 
// produtos nacionais ou importados e se cliente é .T. ou não.
//———————————————————————————————————————————————————————————————————————————————
nPos := aScan(aLista, {|x| x[1]==cCFOP .and. x[2]==lNacional .and. x[3]==lContrib .and. x[4]==cCST})
if nPos > 0

	cTES	:= aLista[nPos,5]
	if SF4->(dbSeek(xFilial("SF4") + cTES)) .and. SF4->F4_MSBLQL!="1" .and. SF4->F4_PODER3=="N"
		cRet := cTES
	else
		U_GrvLogIC("Pesquisa CFOP", cIdNF, cCFOP, "O TES " + cTES + " definido na lista de possiveis TES, não foi encontrado ou está bloqueado ou possui controle DE/EM terceiros e por isto não poderá ser utilizado.")
	endif

else

	U_GrvLogIC("Pesquisa CFOP", cIdNF, cCFOP, "Para o CFOP " + cCFOP + ", não há configuração de TES para operação com produtos " + Iif(cOrigem $ "0#3#4#5#8", "nacionais", "importados") + " e " + Iif(!Empty(cIE) .and. !"ISENT" $ cIE, "não", "") + "contribuintes.")

endif

Return(cRet)
/*/
Static Function GetTES(cCFOP, cOrigem, cCST, cIE, cIdNF)
Local cRet		 	:= "  "
Local cProd			:= iif((cOrigem $ "0#3#4#5#8"), "N", "I")				//Nacional ou Importado
Local cCliente		:= iif((!Empty(cIE) .and. !"ISENT" $ cIE), "C", "N")	//Contribuinte ou Não Contribuinte

cCFOP := PadR(cCFOP,Len(ZZD->ZZD_CFOP))		//Ajustando o tamanho do CFOP.

ZZD->(dbSetOrder(1))	//ZZD_FILIAL, ZZD_CFOP, ZZD_PROD, ZZD_CLIENT, ZZD_CST

//———————————————————————————————————————————————————————————————————————————————
// Procura com o CST da operação
//———————————————————————————————————————————————————————————————————————————————
if ZZD->(dbSeek(xFilial("ZZD") + cCFOP + cProd + cCliente + cCST))
	if SF4->(dbSeek(xFilial("SF4") + ZZD->ZZD_TES)) .and. SF4->F4_MSBLQL!="1" .and. SF4->F4_PODER3=="N"
		cRet := ZZD->ZZD_TES
	else
		U_GrvLogIC("Pesquisa CFOP", cIdNF, cCFOP, "O TES " + ZZD->ZZD_TES + " definido na lista de possiveis TES, não foi encontrado ou está bloqueado ou possui controle DE/EM terceiros e por isto não poderá ser utilizado.")
	endif

//———————————————————————————————————————————————————————————————————————————————
// Procura com o CST genérico
//———————————————————————————————————————————————————————————————————————————————
elseif ZZD->(dbSeek(xFilial("ZZD") + cCFOP + cProd + cCliente + "ALL"))
	if SF4->(dbSeek(xFilial("SF4") + ZZD->ZZD_TES)) .and. SF4->F4_MSBLQL!="1" .and. SF4->F4_PODER3=="N"
		cRet := ZZD->ZZD_TES
	else
		U_GrvLogIC("Pesquisa CFOP", cIdNF, cCFOP, "O TES " + ZZD->ZZD_TES + " definido na lista de possiveis TES, não foi encontrado ou está bloqueado ou possui controle DE/EM terceiros e por isto não poderá ser utilizado.")
	endif

else

	U_GrvLogIC("Pesquisa CFOP", cIdNF, cCFOP, "Para o CFOP " + cCFOP + ", não há configuração de TES para operação com produtos " + Iif(cOrigem $ "0#3#4#5#8", "nacionais", "importados") + " e " + Iif(Empty(cIE) .or. "ISENT" $ cIE, "não ", "") + "contribuintes.")

endif

Return(cRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		GetNFDevol                                                   /@
@type			Static function                                              /@
@date			22/07/2019                                                   /@
@description	Identifica numero, serie e item da nota origem               /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function GetNFDevol(cNFRef, cCliente, cLoja, cProd, nQuant)
Local cNota		:= Substr(cNFRef, 26, 9)
Local cSerie	:= PadR(AllTrim(Str(Val(Substr(cNFRef, 23, 3)))), 3)
Local cItem		:= ""

SD2->(dbSetOrder(3))		//D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM
if SD2->(dbSeek(xFilial("SD2") + cNota + cSerie + cCliente + cLoja + cProd))

	do while SD2->(!eof() .and. D2_FILIAL == xFilial("SD2") .and. D2_DOC == cNota .and. D2_SERIE == cSerie .and. D2_CLIENTE == cCliente .and. D2_LOJA == cLoja .and. D2_COD == cProd)

		if SD2->D2_QTDEDEV + nQuant <= SD2->D2_QUANT
			cItem := SD2->D2_ITEM
			exit
		endif

		SD2->(dbSkip())

	enddo

endif

Return({cNota, cSerie, cItem})



/*/
———————————————————————————————————————————————————————————————————————————————
@function		D19_BRAJOB	                                                 /@
@type			Static function                                              /@
@date			25/06/2020                                                   /@
@description	Lê conteúdo do XML da NFe de cancelamento                    /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function D19_BRAJOB(cBuffer)
Local lRet			:= .T.
Local aMovEst		:= {}
Local cBkpFuncao	:= FunName()
Local cIdEmit, cIdNF, cNF, cSerie, dDtEmis, cHrEmis, cTpAmb, cAviso, cErro, oNFe,;
	  cCliente, cLojaCli, aCabNFCanc, aLinNFCanc, cChave

SA1->(dbSetOrder(3))		//A1_FILIAL, A1_CGC
SA2->(dbSetOrder(3))		//A2_FILIAL, A2_CGC
SD1->(dbSetOrder(1))		//D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM
SD2->(dbSetOrder(3))		//D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM	
SF1->(dbSetOrder(1))		//F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO
SF2->(dbSetOrder(1))		//F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, F2_TIPO
SF4->(dbSetOrder(1))		//F4_FILIAL, F4_CODIGO
ZZ7->(dbSetOrder(3))		//ZZ7_FILIAL, ZZ7_IDNF

cAviso		:= ""
cErro		:= ""
oNFe		:= XmlParser(cBuffer, "_", @cAviso, @cErro)

	cIdEmit		:= oNFe:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_CNPJ:TEXT
	cIdNF		:= "NFe" + oNFe:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_CHNFE:TEXT
	cTpAmb		:= oNFe:_PROCEVENTONFE:_RETEVENTO:_INFEVENTO:_TPAMB:TEXT
	cRetSEFAZ	:= oNFe:_PROCEVENTONFE:_RETEVENTO:_INFEVENTO:_CSTAT:TEXT
	cMotivo		:= oNFe:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO:_XJUST:TEXT
	cProtocolo	:= oNFe:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO:_NPROT:TEXT

	if ZZ7->(dbSeek(xFilial("ZZ7") + cIdNF))

		cChave := ZZ7->ZZ7_NNF + ZZ7->ZZ7_SERIE
		
		//nota de saida
		if ZZ7->ZZ7_TPNF == "1"

			if SF2->(dbSeek(xFilial("SF2") + ZZ7->ZZ7_NNF + ZZ7->ZZ7_SERIE + ZZ7->ZZ7_CLIENT + ZZ7->ZZ7_LOJCLI))
				
				dDtEmis		:= SF2->F2_EMISSAO
				cNF			:= SF2->F2_DOC
				cSerie		:= SF2->F2_SERIE
				cCliente	:= SF2->F2_CLIENTE
				cLojaCli	:= SF2->F2_LOJA

				aCabNFCanc 	:= {	{"F2_TIPO",		SF2->F2_TIPO, 			Nil},;
									{"F2_FORMUL", 	SF2->F2_FORMUL, 		Nil},;
									{"F2_DOC",		SF2->F2_DOC,			Nil},;
									{"F2_SERIE",	SF2->F2_SERIE, 			Nil},;
									{"F2_EMISSAO",	SF2->F2_EMISSAO, 		Nil},;
									{"F2_CLIENTE",	SF2->F2_CLIENTE, 		Nil},;
									{"F2_LOJA",		SF2->F2_LOJA, 			Nil},;
									{"F2_ESPECIE",	SF2->F2_ESPECIE, 		Nil},;
									{"F2_DESCONT", 	SF2->F2_DESCONT, 		Nil},;
									{"F2_FRETE", 	SF2->F2_FRETE, 			Nil},;
									{"F2_SEGURO", 	SF2->F2_SEGURO, 		Nil},;
									{"F2_DESPESA", 	SF2->F2_DESPESA, 		Nil}}

				aLinNFCanc	:= {}
				SD2->(dbSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA))
				do while SD2->(!eof() .and. D2_FILIAL == xFilial("SD2") .and. D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA == SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA)
					aAdd(aLinNFCanc, {	{"D2_COD",		SD2->D2_COD, 		Nil},;
										{"D2_QUANT",	SD2->D2_QUANT, 		Nil},;
										{"D2_PRCVEN",	SD2->D2_PRCVEN, 	Nil},;
										{"D2_TOTAL",	SD2->D2_TOTAL, 		Nil},;
										{"D2_TES",		SD2->D2_TES, 		Nil}})
					SF4->(dbSeek(xFilial("SF4") + SD2->D2_TES))
					if SF4->F4_ESTOQUE == "S"
						aAdd(aMovEst, {SD2->D2_COD, SD2->D2_LOCAL, SD2->D2_QUANT})
					endif

					SD2->(dbSkip())
				enddo
			
				if Len(aLinNFCanc) > 0

					Begin Transaction
					
						//———————————————————————————————————————————————————————————————————————————————
						// Alteração do nome da função, pois a rotina MATA920 chama o ponto de entrada
						// MT100TOK (que é de nota de entrada).
						// Há um tratamento neste ponto de entrada para não acionar funções quando a 
						// chamada for pela função MATA920.
						// Criei também a variável cFormul:="S" no inicio da função MNT01Integra(), que 
						// é a acionadora da MNT01NFSaida()
						//———————————————————————————————————————————————————————————————————————————————
						lMsErroAuto := .F.
						SetFunName("MATA920")
						MsExecAuto({|x,y,z| MATA920(x,y,z)}, aCabNFCanc, aLinNFCanc, 5)		//MATA920(aCabNFCanc, aLinNFCanc, 5)		// Exclui a nota na base pela rotina automática MATA920
						SetFunName(cBkpFuncao)
				
						if lMsErroAuto
						
							U_GrvLogIC("ExecAuto MATA920", ZZ7->ZZ7_IDNF, cChave, "NF saída não cancelada. Erro no MsExecAuto", NomeAutoLog())

						else

							//———————————————————————————————————————————————————————————————————————————————
							// Cancela movimentação de estoque
							//———————————————————————————————————————————————————————————————————————————————
							if Len(aMovEst) > 0
								lRet := MNT01CancMov()
							endif

							//———————————————————————————————————————————————————————————————————————————————
							// Movimentação financeira
							//———————————————————————————————————————————————————————————————————————————————
							//if lMovFin
								//lRet := MNT01MovFin()
							//endif

							if lRet

								SF3->(dbSetOrder(1))		//F3_FILIAL, F3_ENTRADA, F3_NFISCAL, F3_SERIE, F3_CLIEFOR, F3_LOJA, F3_CFO, F3_ALIQICM
								if SF3->(dbSeek(xFilial("SF3") + dTOs(dDtEmis) + cNF + cSerie + cCliente + cLojaCli))
									SF3->(RecLock("SF3", .F.))
									SF3->F3_PROTOC  := cProtocolo		//Protocolo de inutilizacao
									SF3->F3_EMINFE  := dDtEmis			//Data de inutilizacao
									//SF3->F3_HORNFE  := cHrEmis			//Hora de inutilizacao
									SF3->F3_CODRSEF := cRetSEFAZ		//Codigo Retorno
									SF3->F3_CODRET  := "M"				//Status
									SF3->F3_DESCRET := cMotivo
									SF3->(MsUnlock())
								endif

								U_GrvLogIC("ExecAuto MATA920", ZZ7->ZZ7_IDNF, cChave, "NF saída cancelada com SUCESSO")

								ZZ7->(RecLock("ZZ7", .F.))
								ZZ7->ZZ7_NATOP		:= cMotivo
								ZZ7->ZZ7_XMLCAN		:= cBuffer
								ZZ7->ZZ7_STATUS		:= "4"
								ZZ7->(MsUnLock())

								U_CommitLog(cIdNF)

//								else

//									DisarmTransaction()

							endif
							
						endif

						if !lRet
							DisarmTransaction()
						endif

					End Transaction
				endif
			else

				lRet := .F.

			endif

		//nota de entrada
		elseif ZZ7->ZZ7_TPNF == "0"
			
			if SF1->(dbSeek(xFilial("SF1") + ZZ7->ZZ7_NNF + ZZ7->ZZ7_SERIE + ZZ7->ZZ7_CLIENT + ZZ7->ZZ7_LOJCLI))

				dDtEmis		:= SF1->F1_DTDIGIT
				cNF			:= SF1->F1_DOC
				cSerie		:= SF1->F1_SERIE
				cCliente	:= SF1->F1_FORNECE
				cLojaCli	:= SF1->F1_LOJA

				aCabNFCanc 	:= {	{"F1_TIPO",		SF1->F1_TIPO, 			Nil},;
									{"F1_FORMUL", 	SF1->F1_FORMUL, 		Nil},;
									{"F1_DOC",		SF1->F1_DOC,			Nil},;
									{"F1_SERIE",	SF1->F1_SERIE, 			Nil},;
									{"F1_EMISSAO",	SF1->F1_EMISSAO, 		Nil},;
									{"F1_FORNECE",	SF1->F1_FORNECE, 		Nil},;
									{"F1_LOJA",		SF1->F1_LOJA, 			Nil},;
									{"F1_ESPECIE",	SF1->F1_ESPECIE, 		Nil},;
									{"F1_DESCONT", 	SF1->F1_DESCONT, 		Nil},;
									{"F1_FRETE", 	SF1->F1_FRETE, 			Nil},;
									{"F1_SEGURO", 	SF1->F1_SEGURO, 		Nil},;
									{"F1_DESPESA", 	SF1->F1_DESPESA, 		Nil}}

				aLinNFCanc	:= {}
				SD1->(dbSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))
				do while SD1->(!eof() .and. D1_FILIAL == xFilial("SD1") .and. D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA == SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA)
					aAdd(aLinNFCanc, {	{"D1_COD",		SD1->D1_COD, 		Nil},;
										{"D1_QUANT",	SD1->D1_QUANT, 		Nil},;
										{"D1_VUNIT",	SD1->D1_VUNIT, 		Nil},;
										{"D1_TOTAL",	SD1->D1_TOTAL, 		Nil},;
										{"D1_TES",		SD1->D1_TES, 		Nil}})
					SD1->(dbSkip())
				enddo

				lMsErroAuto := .F.
				dbSelectArea("SF1")
				MsExecAuto({|x, y, z| MATA103(x, y, z)}, aCabNFCanc, aLinNFCanc, 5)
				
				if lMsErroAuto
					
					U_GrvLogIC("ExecAuto MATA103", ZZ7->ZZ7_IDNF, cChave, "Cancelamento não realizado. Erro no MsExecAuto", NomeAutoLog())
					DisarmTransaction()

				else

					SF3->(dbSetOrder(1))		//F3_FILIAL, F3_ENTRADA, F3_NFISCAL, F3_SERIE, F3_CLIEFOR, F3_LOJA, F3_CFO, F3_ALIQICM
					if SF3->(dbSeek(xFilial("SF3") + dTOs(dDtEmis) + cNF + cSerie + cCliente + cLojaCli))
						SF3->(RecLock("SF3", .F.))
						SF3->F3_PROTOC  := cProtocolo		//Protocolo de inutilizacao
						SF3->F3_EMINFE  := dDtEmis			//Data de inutilizacao
						SF3->F3_HORNFE  := cHrEmis			//Hora de inutilizacao
						SF3->F3_CODRSEF := cRetSEFAZ		//Codigo Retorno
						SF3->F3_CODRET  := "M"				//Status
						SF3->F3_DESCRET := cMotivo
						SF3->(MsUnlock())
					endif

					ZZ7->(RecLock("ZZ7", .F.))
					ZZ7->ZZ7_NATOP		:= cMotivo
					ZZ7->ZZ7_XMLCAN		:= cBuffer
					ZZ7->ZZ7_STATUS		:= "4"
					ZZ7->(MsUnLock())

					U_CommitLog(cIdNF)

					U_GrvLogIC("ExecAuto MATA103", ZZ7->ZZ7_IDNF, cChave, "NF de entrada cancelada com SUCESSO")

				endif

			else

				lRet := .F.

			endif

		endif

	else

		lRet := .F.
	
	endif


Return(lRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		MNT01MovEst                                                  /@
@type			User function                                                /@
@date			24/06/2019                                                   /@
@description	Movimenta Estoque                                            /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function MNT01CancMov()
Local lRet			:= .T.
Local aCab			:= {}
Local aItem			:= {}
Private l241Auto	:= .T.
Private lMsErroAuto	:= .F.
Private lMsHelpAuto := .T.		// se .t. direciona as mensagens de help

//———————————————————————————————————————————————————————————————————————————————
// Criando o movimento interno
//———————————————————————————————————————————————————————————————————————————————
SD3->(dbSetOrder(2))		//D3_FILIAL, D3_DOC, D3_COD
if SD3->(dbSeek(xFilial("SD3") + ZZ7->ZZ7_NNF)) .and. SD3->D3_XCHVNFE == ZZ7->ZZ7_IDNF

	//nRegistro 	:= SD3->(Recno())
	aCab		:= {{"D3_TM",		SD3->D3_TM, 		NIL},;
					{"D3_EMISSAO",	SD3->D3_EMISSAO, 	NIL}}

	Do While SD3->(!eof() .and. D3_FILIAL == xFilial("SD3") .and. D3_DOC == ZZ7->ZZ7_NNF)
		aAdd(aItem, {	{"D3_COD",		SD3->D3_COD,		NIL},;
						{"D3_UM",		SD3->D3_UM,			NIL},;
						{"D3_QUANT",	SD3->D3_QUANT,		NIL},;
						{"D3_LOCAL",	SD3->D3_LOCAL,		NIL},;
						{"D3_LOCAL",	SD3->D3_LOTECTL,	NIL}})
		SD3->(dbSkip())
	Enddo

	SD3->(dbSeek(xFilial("SD3") + ZZ7->ZZ7_NNF))
	dbSelectArea("SD3")

	lMsErroAuto := .F.
	MSExecAuto({|x,y,z| MATA241(x,y,z)}, aCab, aItem, 6)
	
	if lMsErroAuto
		lRet := .F.
		U_GrvLogIC("ExecAuto MATA241", ZZ7->ZZ7_IDNF, ZZ7->ZZ7_NNF, "Movimento de estoque não pôde ser cancelado. Erro no MsExecAuto", NomeAutoLog())
	else
		U_GrvLogIC("ExecAuto MATA241", ZZ7->ZZ7_IDNF, ZZ7->ZZ7_NNF, "Movimento interno cancelado com SUCESSO.")
	endif

else
	lRet := .F.
	U_GrvLogIC("ExecAuto MATA241", ZZ7->ZZ7_IDNF, ZZ7->ZZ7_NNF, "Movimento interno não encontrado. processo não poderá ser cancelado.")
endif

Return(lRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		E19_BRAJOB	                                                 /@
@type			Static function                                              /@
@date			16/06/2021                                                   /@
@description	Processa registros pendentes ZZ7_STATUS='0'                  /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function E19_BRAJOB()
Local cQuery	:=	"SELECT R_E_C_N_O_ REGISTRO " +;
						"FROM " + RetSqlName("ZZ7") + " ZZ7 " +;
						"WHERE ZZ7.ZZ7_FILIAL = '" + xFilial("ZZ7") + "' " +;
							"AND ZZ7.ZZ7_STATUS = '0' " +;
							"AND ZZ7.D_E_L_E_T_= ' ' " +;
						"ORDER BY ZZ7_DTEMIS"


//———————————————————————————————————————————————————————————————————————————————
// Verificando a existencia da area Temporaria
//———————————————————————————————————————————————————————————————————————————————
if Select("TZZ7") > 0
	TZZ7->(dbCloseArea())
endif

//———————————————————————————————————————————————————————————————————————————————
// Criando a tabela temporaria
//———————————————————————————————————————————————————————————————————————————————
dbUseArea( .T., "TOPCONN", TcGenQRY(,,cQuery), "TZZ7", .F., .T.)

dbSelectArea("TZZ7")
TZZ7->(dbGoTop())
do while TZZ7->(!eof())
	
	ZZ7->(dbGoTo(TZZ7->REGISTRO))
	
	if ZZ7->ZZ7_STATUS == "0"
	
		//———————————————————————————————————————————————————————————————————————————————
		// Inicia o processo de integração. Dentro do processo MNT01Integra, é verificado
		// se o status do registro está apto a ser processado.
		//———————————————————————————————————————————————————————————————————————————————
		U_MNT01Integra(.F.)		//processo automático (manual=.F.)
	
	endif
	
	TZZ7->(dbSkip())

enddo

if Select("TZZ7") > 0
	TZZ7->(dbCloseArea())
endif

Return()






/*
cTpXML
	1-XML NF
	2-XML Inutilização
	3-XML Cancelamento
	9-XML Incorreto

lCNPJAtual 
	AllTrim(cIdEmit) == AllTrim(SM0->M0_CGC)

*/
Static Function CheckXML(cBuffer, cTpXML)
Local cAviso		:= ""
Local cErro			:= ""
Local lCNPJAtual	:= .F.
Local oNFe, oNFeDetail, cIdEmit

//Este ponto resolve o erro na leitura do XML de cupons cancelados, pois
//como ele não possui itens, nao há o elemento DET
if !"http://www.portalfiscal.inf.br/nfe" $ cBuffer 	//?xml version="1.0" encoding="UTF-8"?

	ConOut("Erro na leitura do XML")
	cTpXML		:= "9"

else

	cAviso		:= ""
	cErro		:= ""
	cIdEmit		:= ""
	oNFe		:= XmlParser(cBuffer, "_", @cAviso, @cErro)

	//———————————————————————————————————————————————————————————————————————————————
	// Verifica se é uma notas fiscais válida
	//———————————————————————————————————————————————————————————————————————————————
	if (XmlChildEx(oNFe,"_NFE") <> NIL .and. XmlChildEx(oNFe:_NFe, "_INFNFE") <> NIL) .or.;
		(XmlChildEx(oNFe,"_NFEPROC") <> NIL .and. XmlChildEx(oNFe:_NFEPROC,"_NFE") <> NIL .and. XmlChildEx(oNFe:_NFEPROC:_NFe, "_INFNFE") <> NIL)

		if XmlChildEx(oNFe,"_NFE") <> NIL
			oNFeDetail	:= oNFe:_NFe:_InfNFe
		else
			oNFeDetail	:= oNFe:_NFeProc:_NFe:_InfNFe
		endif

		cIdEmit		:= oNFeDetail:_EMIT:_CNPJ:TEXT				//14 - CNPJ Emissor
		cTpXML		:= "1"										//XML NF

	//———————————————————————————————————————————————————————————————————————————————
	// Identifico se é uma nota inutilizada
	//———————————————————————————————————————————————————————————————————————————————
    elseif XmlChildEx(oNFe, "_RETINUTNFE") <> NIL .and.;
		XmlChildEx(oNFe:_RETINUTNFE, "_INFINUT") <> NIL

		cIdEmit		:= oNFe:_RETINUTNFE:_INFINUT:_CNPJ:TEXT		//14 - CNPJ Emissor
		cTpXML		:= "2"										//XML Inutilização

	//———————————————————————————————————————————————————————————————————————————————
	// Verifico se é uma nota cancelada
	//———————————————————————————————————————————————————————————————————————————————
    elseif XmlChildEx(oNFe, "_PROCEVENTONFE") <> NIL .and.;
            XmlChildEx(oNFe:_PROCEVENTONFE, "_EVENTO") <> NIL .and.;
            XmlChildEx(oNFe:_PROCEVENTONFE:_EVENTO, "_INFEVENTO") <> NIL .and.;
            XmlChildEx(oNFe:_PROCEVENTONFE:_EVENTO:_INFEVENTO,"_DETEVENTO") <> NIL .and.;
            XmlChildEx(oNFe:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO,"_DESCEVENTO") <> NIL .and.;
            Upper(oNFe:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO:_DESCEVENTO:TEXT) == "CANCELAMENTO" .and.;
            XmlChildEx(oNFe:_PROCEVENTONFE:_EVENTO:_INFEVENTO,"_CNPJ") <> NIL
			
		cIdEmit		:= oNFe:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_CNPJ:TEXT		//14 - CNPJ Emissor
		cTpXML		:= "3"														//XML Cancelamento

    endif

	lCNPJAtual := (AllTrim(cIdEmit) == AllTrim(SM0->M0_CGC))

endif

Return(lCNPJAtual)
