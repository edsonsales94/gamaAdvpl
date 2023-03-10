#include "protheus.ch"
#include "ap5mail.ch"

/*/

覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		GAMA_CMT                                                      /@
@type				User function                                                 /@
@date				03/08/2015                                                    /@
@description	Rotina para uso em schedule. 
					Job para o envio de informa鋏es de produtos e pre輟s para o 
					sistema Assist.                                               /@
@author			Felippe Rainho - Op鈬o Um Consultoria                         /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?

/*/
User Function GAMA_CMT()
Local aFiles	:= {"SB1", "DA1"}
Local aStruLog	:= {{"LINHA",		"C", 200, 0}}
Local nK, cTLOG

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Abertura do ambiente
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
WfPrepEnv("01", "03", "U_GAMA_CMT",, "FAT")
for nK := 1 to Len(aFiles)
	if Select(aFiles[nK]) == 0
		ChkFile(aFiles[nK])
	endif
next

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Cria tabela de log
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
cTLOG := CriaTrab(aStruLOG, .T.)
dbUseArea(.T., "DBFCDX", cTLOG, "TLOG", .T.)
		
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Seleciona as notas emitidas
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
GAMA_CMTA()

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Fecho o arquivo de log e o excluo
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if Select("TLOG") > 0
	TLOG->(dbCloseArea())
endif
fErase(cTLOG + OrdBagExt())

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Encerramento do ambiente                                                     
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
RpcClearEnv()
	
ConOut(dTOc(Date()) + " as " + Time() + " - GAMA_CMT - Envio de informa鋏es da lista de produtos e respectivos pre輟s para o sistema Assist")

Return()


/*/

覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		GAMA_CMTA                                                     /@
@type				Static function                                               /@
@date				26/05/2015                                                    /@
@description	Fun鈬o chamada pela user function GAMA_CMT. Seleciona os 
					registros de produtos e respectivos pre輟s para envio ao 
					sistema Assist por meio	de webservice e envio de e-mail do 
					resultado do processamento	aos interessados.                  /@
@author			Adalberto Moreno Batista - Op鈬o Um Consultoria               /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?

/*/
Static Function GAMA_CMTA()
Local cAnexo, cMensagem
Local cEol			:= "<br>"
Local cDestinat		:= AllTrim(GetMV("BR_EMLCMT", .F., "cassio.olimpio@gamaitaly.com.br"))							//Enderecos de emails p/ o envio de informa鋏es ao sistema Assist de lista de produtos e respecivos pre輟s. GAMA_CMT
Local cTabPrc		:= AllTrim(GetMV("BR_WSTABPR", .F., "018"))													//Codigo da tabela de preco para pedidos integrados pelo webservice com o sistema Assist. GAMA_EOS
Local cAssunto		:= "Brasitech - Log de envio de informa鋏es de lista de produtos e respectivos pre輟s ao Assist"
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

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
// Pesquisando quantidade de registros
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
if Select("TRBCT") > 0
	TRBCT->(dbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TcGenQry(,,ChangeQuery(cQueryCt)), "TRBCT", .F., .T.)

dbSelectArea("TRBCT")
nNumMat := TRBCT->CONTADOR

if Select("TRBCT") > 0
	TRBCT->(dbCloseArea())
endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
// Se houver registros a serem processados, inicio a opera鈬o
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
if nNumMat > 0

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	// Definindo processo
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	oWSDL 			:= tWSDLManager():New()
	oWSDL:lVerbose := .T.							// Seta o modo de trabalho da classe para "verbose"
	
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	// Ambiente de testes QAS
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	//lOk 			:= oWsdl:ParseURL("http://gama.assistonline.com.br/qas/WS_servers/GAMA/PROTEUS/CMT.PHP?wsdl")		// Primeiro faz o parser do WSDL a partir da URL
	
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	// Ambiente de producao
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	lOk 				:= oWsdl:ParseURL("http://gama.assistonline.com.br/WS_SERVERS/GAMA/PROTEUS/CMT.PHP?wsdl")				// ambiente de producao Primeiro faz o parser do WSDL a partir da URL
	
	if !lOk
		cParCod := "2"
		cParMsg := "Falha ao conectar no webservice CMT"
	else
		lOk 			:= oWsdl:SetOperation("CMT")				// Seta a opera鈬o a ser utilizada
		if !lOk
			cParCod	:= "2"
			cParMsg	:= "Falha ao conectar no metodo CMT"
		endif
	endif
	
	if !empty(cParMsg)
		GrvLog(cParMsg)
	endif
	
	if lOk
	
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
		// Selecionando registros a serem processados
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
		if Select("TRB") > 0
			TRB->(dbCloseArea())
		endif
		
		dbUseArea(.T., "TOPCONN", TcGenQry(,,ChangeQuery(cQuery)), "TRB", .F., .T.)
		Memowrite("gama_cmt.sql" , ChangeQuery(cQuery) )
				
		dbSelectArea("TRB")
		dbGoTop()
	
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
		// Iniciando o processamento de registros
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
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
					cParMsg := "Falha no campo " + AllTrim(aEstrProd[nX, 1]) + " da requisi鈬o do produto " + TRB->B1_COD
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
	
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	// Envio de e-mail com o log de processamento
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	dbSelectArea("TLOG")
	dbGoTop()
	if !eof()
		MakeDir("EDI01")
		MakeDir("EDI01\WS")
	
		cAnexo := "edi01\ws\CMT_" + dTOs(date()) + "_" + StrTran(Time(), ":", "") + ".LOG"
		
		Copy to &cAnexo SDF
	endif
	
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	// e-mail no formato html
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	cMensagem := '<html>' + cEol
	cMensagem += '<font size="2" face="Arial">Informa鋏es de ocorr麩cias sobre o envio de lista de produtos e respectivos pre輟s ao Assist em' + dTOc(dDataBase) + ' 灣 ' + Time() + '.</font>' + cEol + cEol + cEol
	cMensagem += '<font size="1" face="Calibri">E-mail autom疸ico enviado pelo sistema Microsiga Protheus. Favor n縊 respond?-lo.</font>' + cEol	
	cMensagem += '</body>' + cEol
	cMensagem += '</html>' + cEol
	
	U_GISendMail(cDestinat,, cAssunto, cMensagem, cAnexo)

endif

Return()


/*/

覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		GRVLOG                                                        /@
@type				Static function                                               /@
@date				06/09/2014                                                    /@
@description	Fun鈬o chamada pela static function GAMA_CMTA. Grava log de
					processamento na tabela tempor疵ia de log                     /@
@author			Adalberto Moreno Batista - Op鈬o Um Consultoria               /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
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
