#include "protheus.ch"
#include "ap5mail.ch"

/*/

———————————————————————————————————————————————————————————————————————————————
@function		GAMA_CMT                                                      /@
@type				User function                                                 /@
@date				03/08/2015                                                    /@
@description	Rotina para uso em schedule. 
					Job para o envio de informações de produtos e preços para o 
					sistema Assist.                                               /@
@author			Felippe Rainho - Opção Um Consultoria                         /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————

/*/
User Function GAMA_CMT()
Local aFiles	:= {"SB1", "DA1"}
Local aStruLog	:= {{"LINHA",		"C", 200, 0}}
Local nK, cTLOG

//———————————————————————————————————————————————————————————————————————————————
// Abertura do ambiente
//———————————————————————————————————————————————————————————————————————————————
WfPrepEnv("01", "03", "U_GAMA_CMT",, "FAT")
for nK := 1 to Len(aFiles)
	if Select(aFiles[nK]) == 0
		ChkFile(aFiles[nK])
	endif
next

//———————————————————————————————————————————————————————————————————————————————
// Cria tabela de log
//———————————————————————————————————————————————————————————————————————————————
cTLOG := CriaTrab(aStruLOG, .T.)
dbUseArea(.T., "DBFCDX", cTLOG, "TLOG", .T.)
		
//———————————————————————————————————————————————————————————————————————————————
// Seleciona as notas emitidas
//———————————————————————————————————————————————————————————————————————————————
GAMA_CMTA()

//———————————————————————————————————————————————————————————————————————————————
// Fecho o arquivo de log e o excluo
//———————————————————————————————————————————————————————————————————————————————
if Select("TLOG") > 0
	TLOG->(dbCloseArea())
endif
fErase(cTLOG + OrdBagExt())

//———————————————————————————————————————————————————————————————————————————————
// Encerramento do ambiente                                                     
//———————————————————————————————————————————————————————————————————————————————
RpcClearEnv()
	
ConOut(dTOc(Date()) + " as " + Time() + " - GAMA_CMT - Envio de informações da lista de produtos e respectivos preços para o sistema Assist")

Return()


/*/

———————————————————————————————————————————————————————————————————————————————
@function		GAMA_CMTA                                                     /@
@type				Static function                                               /@
@date				26/05/2015                                                    /@
@description	Função chamada pela user function GAMA_CMT. Seleciona os 
					registros de produtos e respectivos preços para envio ao 
					sistema Assist por meio	de webservice e envio de e-mail do 
					resultado do processamento	aos interessados.                  /@
@author			Adalberto Moreno Batista - Opção Um Consultoria               /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————

/*/
Static Function GAMA_CMTA()
Local cAnexo, cMensagem
Local cEol			:= "<br>"
Local cDestinat		:= AllTrim(GetMV("BR_EMLCMT", .F., "cassio.olimpio@gamaitaly.com.br"))							//Enderecos de emails p/ o envio de informações ao sistema Assist de lista de produtos e respecivos preços. GAMA_CMT
Local cTabPrc		:= AllTrim(GetMV("BR_WSTABPR", .F., "018"))													//Codigo da tabela de preco para pedidos integrados pelo webservice com o sistema Assist. GAMA_EOS
Local cAssunto		:= "Brasitech - Log de envio de informações de lista de produtos e respectivos preços ao Assist"
Local cQuery 		:= "SELECT SB1.B1_COD, SB1.B1_DESC, SB1.B1_TIPO, SB1.B1_MSBLQL, DA1.DA1_PRCVEN, DA1.R_E_C_N_O_ REGISTRO " +;
							"FROM " + RetSqlName("DA1") + " DA1, " + RetSqlName("SB1") + " SB1 " +;
							"WHERE DA1.DA1_FILIAL = '" + xFilial("DA1") + "' " +;
									 "AND DA1.DA1_MSEXP = '' " +;
 							 		 "AND DA1.DA1_ATIVO = '1' " +;
 							 		 "AND DA1.DA1_DATVIG < '" + dTOs(dDataBase) + "' " +;
 							 		 "AND DA1.DA1_CODTAB = '" + cTabPrc + "' " +;
							 		 "AND DA1.D_E_L_E_T_ = '' " +;
							 		 "AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' " +;
							 		 "AND SB1.B1_COD = DA1.DA1_CODPRO " +;
							 		 "AND SB1.B1_MSBLQL != '1' " +;
							 		 "AND SB1.D_E_L_E_T_ = '' " +;
					 		"ORDER BY SB1.B1_COD "
Local cQueryCt		:= "SELECT COUNT(*) CONTADOR " +;
							"FROM " + RetSqlName("DA1") + " DA1, " + RetSqlName("SB1") + " SB1 " +;
							"WHERE DA1.DA1_FILIAL = '" + xFilial("DA1") + "' " +;
									 "AND DA1.DA1_MSEXP = '' " +;
 							 		 "AND DA1.DA1_ATIVO = '1' " +;
 							 		 "AND DA1.DA1_DATVIG < '" + dTOs(dDataBase) + "' " +;
 							 		 "AND DA1.DA1_CODTAB = '" + cTabPrc + "' " +;
							 		 "AND DA1.D_E_L_E_T_ = '' " +;
							 		 "AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' " +;
							 		 "AND SB1.B1_COD = DA1.DA1_CODPRO " +;
							 		 "AND SB1.B1_MSBLQL != '1' " +;
							 		 "AND SB1.D_E_L_E_T_ = '' "
Local oWSDL, lOk, cResp, nK, nX, aEstrProd, cDescrApoio, cDescr, nNumMat
Local cString		:= "abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ-.\/"
Local cParCod		:= ""
Local cParMsg		:= ""

//————————————————————————————————————————————————————————————————————————————
// Pesquisando quantidade de registros
//————————————————————————————————————————————————————————————————————————————
if Select("TRBCT") > 0
	TRBCT->(dbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TcGenQry(,,ChangeQuery(cQueryCt)), "TRBCT", .F., .T.)

dbSelectArea("TRBCT")
nNumMat := TRBCT->CONTADOR

if Select("TRBCT") > 0
	TRBCT->(dbCloseArea())
endif

//————————————————————————————————————————————————————————————————————————————
// Se houver registros a serem processados, inicio a operação
//————————————————————————————————————————————————————————————————————————————
if nNumMat > 0

	//————————————————————————————————————————————————————————————————————————————
	// Definindo processo
	//————————————————————————————————————————————————————————————————————————————
	oWSDL 			:= tWSDLManager():New()
	oWSDL:lVerbose := .T.							// Seta o modo de trabalho da classe para "verbose"
	
	//————————————————————————————————————————————————————————————————————————————
	// Ambiente de testes QAS
	//————————————————————————————————————————————————————————————————————————————
	//lOk 			:= oWsdl:ParseURL("http://gama.assistonline.com.br/qas/WS_servers/GAMA/PROTEUS/CMT.PHP?wsdl")		// Primeiro faz o parser do WSDL a partir da URL
	
	//————————————————————————————————————————————————————————————————————————————
	// Ambiente de producao
	//————————————————————————————————————————————————————————————————————————————
	lOk 				:= oWsdl:ParseURL("http://gama.assistonline.com.br/WS_SERVERS/GAMA/PROTEUS/CMT.PHP?wsdl")				// ambiente de producao Primeiro faz o parser do WSDL a partir da URL
	
	if !lOk
		cParCod := "2"
		cParMsg := "Falha ao conectar no webservice CMT"
	else
		lOk 			:= oWsdl:SetOperation("CMT")				// Seta a operação a ser utilizada
		if !lOk
			cParCod	:= "2"
			cParMsg	:= "Falha ao conectar no metodo CMT"
		endif
	endif
	
	if !empty(cParMsg)
		GrvLog(cParMsg)
	endif
	
	if lOk
	
		//————————————————————————————————————————————————————————————————————————————
		// Selecionando registros a serem processados
		//————————————————————————————————————————————————————————————————————————————
		if Select("TRB") > 0
			TRB->(dbCloseArea())
		endif
		
		dbUseArea(.T., "TOPCONN", TcGenQry(,,ChangeQuery(cQuery)), "TRB", .F., .T.)
		Memowrite("gama_cmt.sql" , ChangeQuery(cQuery) )
				
		dbSelectArea("TRB")
		dbGoTop()
	
		//————————————————————————————————————————————————————————————————————————————
		// Iniciando o processamento de registros
		//————————————————————————————————————————————————————————————————————————————
		oWSDL:SetComplexOccurs(1, nNumMat)
		
		nK := 1
		do while TRB->(!eof() .and. nK <= nNumMat)

			cDescrApoio	:= AllTrim(TRB->B1_DESC)
			cDescr		:= ""
			for nX := 1 to Len(cDescrApoio)
				if Substr(cDescrApoio, nX, 1) $ cString
					cDescr += Substr(cDescrApoio, nX, 1)
				endif
			next
	
			aEstrProd := {	{"CODMATERIAL", 	AllTrim(TRB->B1_COD)},;
								{"DESCRMATERIAL", cDescr},;
								{"TIPO", 			iif(TRB->B1_TIPO=="PA", "PD", "PC")},;
								{"PRECOG", 			"0"},;
								{"PRECOV", 			AllTrim(Str(TRB->DA1_PRCVEN))},;
								{"INATIVO", 		iif(TRB->B1_MSBLQL == "1", "1", "0")}}
	
			lOk := .T.
			for nX := 1 to Len(aEstrProd)
				lOk 	:= oWsdl:SetValPar(aEstrProd[nX, 1], {"ENTRADA#1","ITENS#" + Alltrim(Str(nK))}, 	aEstrProd[nX, 2])
				if !lOk
					cParCod := "2"
					cParMsg := "Falha no campo " + AllTrim(aEstrProd[nX, 1]) + " da requisição do produto " + TRB->B1_COD
	//				exit
				endif
			next
			
			if lOk
				DA1->(dbGoTo(TRB->REGISTRO))
				DA1->(RecLock("DA1", .F.))
				DA1->DA1_MSEXP := dTOs(date())
				DA1->(MsUnlock())
	//			GrvLog("Ok para o produto " + TRB->(AllTrim(B1_COD) + " - " + B1_DESC))
			else
				GrvLog(cParMsg)
	//			exit
			endif
	   
			nK++	
			TRB->(dbSkip())

		enddo
	
		if lOk
			lOk := oWsdl:SendSoapMsg()
	
			if !lOk
				ConOut( "Erro SendSoapMsg: " + oWsdl:cError )
				ConOut( "Erro SendSoapMsg FaultCode: " + oWsdl:cFaultCode )
	
				cParCod	:= "2"
				cParMsg	:= oWsdl:cError + chr(13) + chr(10) + oWsdl:cFaultCode
			
			else
			
				// Recupera os elementos de retorno
				cResp 	:= oWsdl:GetSoapResponse()
	
				nIni1		:= rAt("<MSG xsi:type=", cResp)
				nIni1a	:= rAt("</MSG>", cResp)
				cParMsg	:= Substr(cResp, nIni1+27, nIni1a - (nIni1 + 27))
				nIni2		:= rAt("</COD>", cResp)
				cParCod	:= Substr(cResp, nIni2 - 1, 1)
			
				if Empty(cParCod)
					cParCod := "2"
					cParMsg := "Sem resposta do webservice"
				elseif cParCod == "1"
					cParMsg += " - Sucesso no envio dos registros"
				endif
				
			endif
	
			GrvLog(cParMsg)
			
		endif
	
	endif
	
	if Select("TRB") > 0
		TRB->(dbCloseArea())
	endif
	
	//————————————————————————————————————————————————————————————————————————————
	// Envio de e-mail com o log de processamento
	//————————————————————————————————————————————————————————————————————————————
	dbSelectArea("TLOG")
	dbGoTop()
	if !eof()
		MakeDir("EDI01")
		MakeDir("EDI01\WS")
	
		cAnexo := "edi01\ws\CMT_" + dTOs(date()) + "_" + StrTran(Time(), ":", "") + ".LOG"
		
		Copy to &cAnexo SDF
	endif
	
	//————————————————————————————————————————————————————————————————————————————
	// e-mail no formato html
	//————————————————————————————————————————————————————————————————————————————
	cMensagem := '<html>' + cEol
	cMensagem += '<font size="2" face="Arial">Informações de ocorrências sobre o envio de lista de produtos e respectivos preços ao Assist em' + dTOc(dDataBase) + ' às ' + Time() + '.</font>' + cEol + cEol + cEol
	cMensagem += '<font size="1" face="Calibri">E-mail automático enviado pelo sistema Microsiga Protheus. Favor não respondê-lo.</font>' + cEol	
	cMensagem += '</body>' + cEol
	cMensagem += '</html>' + cEol
	
	U_GISendMail(cDestinat,, cAssunto, cMensagem, cAnexo)

endif

Return()


/*/

———————————————————————————————————————————————————————————————————————————————
@function		GRVLOG                                                        /@
@type				Static function                                               /@
@date				06/09/2014                                                    /@
@description	Função chamada pela static function GAMA_CMTA. Grava log de
					processamento na tabela temporária de log                     /@
@author			Adalberto Moreno Batista - Opção Um Consultoria               /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————

/*/
Static Function GrvLog(cErro)
Local aArea	:= GetArea()

dbSelectArea("TLOG")
TLOG->(RecLock("TLOG",.T.))
TLOG->LINHA	:= cErro
TLOG->(MsUnlock())

RestArea(aArea)
Return()
