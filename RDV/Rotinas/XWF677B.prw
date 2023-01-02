#Include "totvs.ch"
#Include "TopConn.ch"
#Include "ap5mail.ch"

Static _lTSTHM  := .F.
Static EMAILTST := "andre@adeoconsultoria.com.br;sidney.mendes@gamaitaly.com.br;rodrigo.ramos@gamaitaly.com.br"

/*/{Protheus.doc} User Function XWF677B
    ( WorkFlow para Aprova��o de Prestacao de contas )
    @type  User Function
    @author AOliveira
    @since 20/07/2021
    @version 1.0
    @see (links_or_references)
/*/
User Function XWF677B()

Local aFiles	:= {"SA2", "RD0", "FLF", "FLE", "FLN"}
Local cEmp		:= "01"
Local aFil		:= {"03"} //{"01", "03", "08", "09"}
Local nX, nY

Local cArqLock := "XWF677B.lck"

EMAILTST := EMAILTST

// Efetua o Lock de gravacao da Rotina - Monousuario 
FErase(cArqLock)
nHdlLock := MsFCreate(cArqLock)
IF nHdlLock < 0
	Conout("Rotina ( u_XWF677B() ) ja em execu��o.")
	Return(.T.)
EndIF

for nX := 1 to Len(aFil)

    //Abertura do Ambiente
    WfPrepEnv(cEmp, aFil[nX], "U_XWF677B",, "FIN")

    for nY := 1 to (aFiles[nX])
		if Empty(Select(aFiles[nX]))
			ChkFile(aFiles[nX])
		endif         
    next nY

	XWF677B1() // Processando registros

    RpcClearEnv()
    
next nX

RpcClearEnv()

// Cancela o Lock de gravacao da rotina
FClose(nHdlLock)
FErase(cArqLock)

Return

/*/{Protheus.doc} XWF677A1
    ( Processamento dos registros )
    @type  Static Function
    @author AOliveira
    @since 20/07/2021
    @version 1.0
/*/
Static Function XWF677B1()

Local cQry := ""

DbSelectArea("ZZG")
//INDICE 1 FLN
//FLN_FILIAL+FLN_TIPO+FLN_PRESTA+FLN_PARTIC+FLN_SEQ+FLN_TPAPR

cQry := " SELECT * "+CRLF
cQry += " FROM "+RetSqlName("FLN")+" "+CRLF
cQry += " WHERE FLN_FILIAL = '"+xFilial("FLN")+"' "+CRLF
cQry += " AND FLN_STATUS = '1' "+CRLF
cQry += " AND D_E_L_E_T_ = '' "+CRLF
cQry += " AND FLN_FILIAL+FLN_TIPO+FLN_PRESTA+FLN_PARTIC+FLN_SEQ+FLN_TPAPR NOT IN (SELECT ZZG_CHAVE "+CRLF
cQry += " 														FROM "+RetSqlName("ZZG")+" "+CRLF
cQry += " 														WHERE ZZG_FILIAL = '"+xFilial("ZZG")+"' "+CRLF
cQry += " 														AND ZZG_ALIAS = 'FLN' "+CRLF
cQry += " 														AND ZZG_CHAVE = FLN_FILIAL+FLN_TIPO+FLN_PRESTA+FLN_PARTIC+FLN_SEQ+FLN_TPAPR "+CRLF
cQry += " 														AND D_E_L_E_T_ = '') "+CRLF

TCQUERY cQry ALIAS "XTRB" NEW

dbSelectArea("XTRB")
XTRB->(dbGoTop())
While !(XTRB->(Eof()))

    cMailId := XWF677B2() // Monto o envio  do WF

	if !(Empty(cMailId))
		
		DbSelectArea("ZZG")
		ZZG->(RecLock("ZZG", .t.))
		ZZG->ZZG_FILIAL := xFilial("ZZG")
		ZZG->ZZG_CODIGO := GetSXENum("ZZG", "ZZG_CODIGO")
		ZZG->ZZG_ALIAS  := "FLN" 
		ZZG->ZZG_INDICE := "1"
		ZZG->ZZG_CHAVE  := XTRB->(FLN_FILIAL+FLN_TIPO+FLN_PRESTA+FLN_PARTIC+FLN_SEQ+FLN_TPAPR)
		ZZG->ZZG_XLINK  := cMailId
		ZZG->ZZG_STATUS := "1"
		ZZG->ZZG_DATA   := Date()
		ZZG->ZZG_HORA   := TIME()
		//ZZG->ZZG_DATAF := 
		//ZZG->ZZG_HORAF :=
		//ZZG->ZZG_OBS 	:=
		ZZG->ZZG_ORIG := 'XWF677B'  
		ZZG->(MsUnlock())
		
		ZZG->(ConfirmSX8("ZZG"))
		
	EndIf

    XTRB->(dbSkip())

EndDo

XTRB->(dbCloseArea())

Return()


/*/{Protheus.doc} XWF677B
    ( Monto o envio do WF via Link )
    @type  Static Function
    @author AOliveira
    @since 20/07/2021
    @version 1.0
/*/
Static Function XWF677B2()
Local cAssunto		:= "Aprova��o de Presta��o de Contas Nr. " + XTRB->FLN_PRESTA

Local cWFBRWSR  := GetMV("MV_WFBRWSR", .F.,"") //IP ou nome do servidor HTTP
Local cWFDir	:= GetMV("MV_WFDIR", .F.,"")   //Diretorio de trabalho do Workflow 
Local cWFDHTTP  := GetMV("MV_WFDHTTP", .F.,"") //Diretorio do servido HTTP          

Local cGerHTML := "/emp" + cEmpAnt + "/html_rdv"

Local cLinkLogo	:= AllTrim(GetMV("BR_LNKLOGO", .F., " "))

Local aItens		:= {}    
Local nTotGer		:= 0

//
Local _cPRESTA  := XTRB->FLN_PRESTA
Local _dEMISSAO := StoD(" / / ") //XTRB->FLF_EMISSAO
Local cCpf      := ""
Local cObsFLF   := ""
Local cAmbiente	    := Lower(GetEnvServer())

Local cPARTIC := ""
Local cPARUSR := ""
Local cPARNOM := ""
Local cPAREMA := ""

Local cAPROPC := ""
Local cAPRUSR := ""
Local cAPRNOM := ""
Local cAPREMA := ""
Local cAPSUBS := ""
Local cAPSUSR := ""
Local cAPSNOM := ""
Local cAPSEMA := ""
      
Local nX, NXX

Private _aFile := {}
Private _cFile := ""

Private oHTML, cMailID


cWFBRWSR  := cWFBRWSR
cWFDHTTP := cWFDHTTP


//Posicionar na Presta��o de Contas FLF
DbSelectArea("FLF")
FLF->(DbSetOrder(1)) // FLF_FILIAL+FLF_TIPO+FLF_PRESTA+FLF_PARTIC
if FLF->(DbSeek( XTRB->(FLN_FILIAL+FLN_TIPO+FLN_PRESTA+FLN_PARTIC) ))
	_dEMISSAO := FLF->FLF_EMISSAO
	cPARTIC := FLF->FLF_PARTIC 
	cObsFLF := FLF->FLF_MOTIVO
endif

//Pego o Codigo de user de sistema 
//dos Aprovadores
RD0->(dbSetOrder(1)) //RD0_FILIAL+RD0_CODIGO
If RD0->(dbSeek( xFilial("RD0")+XTRB->FLN_PARTIC ))

	//Participante
	cPARTIC := cPARTIC
	cPARUSR := RD0->RD0_USER
	cPARNOM := AllTrim(UsrFullName(cPARUSR))
	cPAREMA := iif( !Empty(AllTrim(UsrRetMail(cPARUSR))), AllTrim(UsrRetMail(cPARUSR)) ,  Alltrim(RD0->RD0_EMAIL) ) 		

	//cPAREMA := AllTrim(UsrRetMail(cPARUSR))		

	cAPROPC := RD0->RD0_APROPC //Aprovador
	cAPSUBS := RD0->RD0_APSUBS //Substituto

	if RD0->(dbSeek( xFilial("RD0")+cAPROPC )) //Aprovador
		cAPROPC := cAPROPC
		cAPRUSR := RD0->RD0_USER	 
		cAPRNOM := AllTrim(UsrFullName(cAPRUSR))
		cAPREMA := iif( !Empty(AllTrim(UsrRetMail(cAPRUSR))), AllTrim(UsrRetMail(cAPRUSR)) ,  Alltrim(RD0->RD0_EMAIL) ) 	

		//cAPREMA := AllTrim(UsrRetMail(cAPRUSR))		
	endif

	if RD0->(dbSeek( xFilial("RD0")+cAPSUBS )) //Substituto
		cAPSUBS := cAPSUBS
		cAPSUSR := RD0->RD0_USER	 
		cAPSNOM := AllTrim(UsrFullName(cAPSUSR))
		cAPSEMA := iif( !Empty(AllTrim(UsrRetMail(cAPSUSR))), AllTrim(UsrRetMail(cAPSUSR)) ,  Alltrim(RD0->RD0_EMAIL) ) 

		//cAPSEMA := Alltrim(UsrRetMail(cAPSUSR))
	endif
      
Endif
//
//

//
// Devido o processo paradr�o npa atender a GAMA. 
// Ser� criado 2 parametros para envio de email ao 
// Aprovador 
//
// ES_RDVBAP1   -- RDV - Aprovador processo processo B
// ES_RDVBAP2   -- RDV - Aprovador Substituto processo B
// ES_RDVCAP1   -- RDV - Aprovador processo processo C
// ES_RDVCAP2   -- RDV - Aprovador Substituto processo C
// 

/*
cAPROPC := GetMV("ES_RDVBAP1", .F.,"")
cAPRUSR := GetMV("ES_RDVBAP1", .F.,"")
cAPRNOM := AllTrim(UsrFullName(cAPRUSR))
cAPREMA := iif( !Empty(AllTrim(UsrRetMail(cAPRUSR))), AllTrim(UsrRetMail(cAPRUSR)) ,  "" ) 	

cAPSUBS := GetMV("ES_RDVCAP2", .F.,"")
cAPSUSR := GetMV("ES_RDVCAP2", .F.,"")	 
cAPSNOM := AllTrim(UsrFullName(cAPSUSR))
cAPSEMA := iif( !Empty(AllTrim(UsrRetMail(cAPSUSR))), AllTrim(UsrRetMail(cAPSUSR)) ,  "" ) 
*/

cAPROPC := GetMV("ES_RDVBAP1", .F.,"") //Informar registro na RDO como aprovador
if RD0->(dbSeek( xFilial("RD0")+cAPROPC )) //Aprovador
	cAPROPC := cAPROPC
	cAPRUSR := RD0->RD0_USER	 
	cAPRNOM := AllTrim(UsrFullName(cAPRUSR))
	cAPREMA := iif( !Empty(AllTrim(UsrRetMail(cAPRUSR))), AllTrim(UsrRetMail(cAPRUSR)) ,  Alltrim(RD0->RD0_EMAIL) ) 	
	//cAPREMA := AllTrim(UsrRetMail(cAPRUSR))		
endif

cAPSUBS := GetMV("ES_RDVCAP2", .F.,"") //Informar registro na RD0 como aprovador Substituto
if RD0->(dbSeek( xFilial("RD0")+cAPSUBS )) //Substituto
	cAPSUBS := cAPSUBS
	cAPSUSR := RD0->RD0_USER	 
	cAPSNOM := AllTrim(UsrFullName(cAPSUSR))
	cAPSEMA := iif( !Empty(AllTrim(UsrRetMail(cAPSUSR))), AllTrim(UsrRetMail(cAPSUSR)) ,  Alltrim(RD0->RD0_EMAIL) ) 
	//cAPSEMA := Alltrim(UsrRetMail(cAPSUSR))
endif

//

//INDICE 1 FLN
//FLN_FILIAL+FLN_TIPO+FLN_PRESTA+FLN_PARTIC+FLN_SEQ+FLN_TPAPR

_aFile := {}
_cFile := ""

DbSelectArea("FLE")
FLE->(dbGoTop())
FLE->(DbSetOrder(1)) //FLE_FILIAL+FLE_TIPO+FLE_PRESTA+FLE_PARTIC+FLE_ITEM
FLE->(DbSeek( XTRB->FLN_FILIAL+	XTRB->FLN_TIPO+XTRB->FLN_PRESTA ))
while !FLE->(Eof()) .And. (FLE->(FLE_FILIAL+FLE_TIPO+FLE_PRESTA) == XTRB->(FLN_FILIAL+FLN_TIPO+FLN_PRESTA) )
	nTotGer += FLE->FLE_TOTAL
	aAdd(aItens,{FLE->FLE_ITEM,;
	            FLE->FLE_DATA,;	
				FLE->FLE_LOCAL,;	
				FLE->FLE_DESPES,;
				posicione('FLG',1,xFilial('FLG')+FLE->FLE_DESPES,'FLG_DESCRI'),;
				FLE->FLE_GRUPO,;	
				FLE->FLE_QUANT,;	
				FLE->FLE_MOEDA,;	
				FLE->FLE_TOTAL,;
				FLF->FLF_CC,;
				FLE->FLE_OBS })
			
	//
	//Anexos	
	cEntidade := "FLE"
	cChave  := xFilial("FLE") + FLE->FLE_TIPO + FLE->FLE_PRESTA + FLE->FLE_PARTIC + FLE->FLE_ITEM
	AC9->(dbSetOrder(2)) //	AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT+AC9_CODOBJ
	If AC9->(dbSeek(xFilial("AC9") + cEntidade + xFilial(cEntidade) + Alltrim(cChave)))	
		ACB->(dbSetOrder(1))	//	ACB_FILIAL+ACB_CODOBJ
		iF ACB->(dbSeek(xFilial("ACB") + AC9->AC9_CODOBJ))
			_cFile := Alltrim( MsDocPath() + "\" + Alltrim(ACB->ACB_OBJETO) )
			if File(_cFile)
				Aadd(_aFile, _cFile )
			endif
		endif
	EndIf
	//
	//

	FLE->(DbSkip())	
EndDo

// Monta o HTML para aprova��o e verificar o tipo do aprovador
oWF:= TWFProcess():New("WF677B", "Aprova��o de Presta��o de Contas")
oWF:cTo := "XWF677B_APRO"

oWF:NewTask("000021", "\workflow\XWF677B.htm")
oWF:cSubject	:= cAssunto
oWF:bReturn	:= "U_XWF677B3()" //Retorno
oWF:UserSiga	:= "JOB20"
oWF:NewVersion(.T.)

oHTML := oWF:oHTML

// Campos de controle para o retorno da pagina de aprovacao
oWF:oHTML:ValByName("NUMERO",			XTRB->(FLN_FILIAL+FLN_TIPO+FLN_PRESTA+FLN_PARTIC+FLN_SEQ+FLN_TPAPR))
oWF:oHTML:ValByName("PARTICIPANTE",		cPARTIC)
oWF:oHTML:ValByName("APROVADOR",		cAPROPC)
oWF:oHTML:ValByName("SUBSTITUTO",		cAPSUBS)

// Cabecalho
oWF:oHTML:ValByName("C_LINKLOGO",	   cLinkLogo)
oWF:oHTML:ValByName("C_PCONTA",		   _cPRESTA)
oWF:oHTML:ValByName("C_FILIAL",		   Upper(SM0->M0_FILIAL) )
oWF:oHTML:ValByName("C_EMISSAO",	   DtoC(_dEMISSAO) )
oWF:oHTML:ValByName("C_PARTICIPANTE",  AllTrim(cPARNOM) + "      (" + Alltrim(cPAREMA) + ")")
oWF:oHTML:ValByName("C_CPF",	       cCpf)
oWF:oHTML:ValByName("C_OBS",	       cObsFLF)

for nX := 1 to Len(aItens)
	aAdd((oWF:oHTML:ValByName("I.ITEM")),	  aItens[nX,1])
	aAdd((oWF:oHTML:ValByName("I.DATA")),	  aItens[nX,2])
	aAdd((oWF:oHTML:ValByName("I.CODLOCAL")), aItens[nX,3])
	aAdd((oWF:oHTML:ValByName("I.DESPESA")),  aItens[nX,4])
    aAdd((oWF:oHTML:ValByName("I.DESCR")),	  aItens[nX,5])
    aAdd((oWF:oHTML:ValByName("I.GRUPO")),	  aItens[nX,6])
	aAdd((oWF:oHTML:ValByName("I.QTDE")),	  Transform(aItens[nX,7], "@E 999,999,999"))
    aAdd((oWF:oHTML:ValByName("I.MOEDA")),	  aItens[nX,8])
	aAdd((oWF:oHTML:ValByName("I.TOTAL")),	  Transform(aItens[nX,9], "@E 999,999,999.99"))
	aAdd((oWF:oHTML:ValByName("I.CCUSTO")),	  aItens[nX,10])
	aAdd((oWF:oHTML:ValByName("I.COBS2")),	  aItens[nX,11])
next nX

oWF:oHTML:ValByName("R_TOTAL",		Transform(nTotGer, "@E 999,999,999.99"))


/*
Ret := MakeDir( cWFDHTTP + cGerHTML+_cPRESTA )
//__CopyFile(cDirLocal+cArquivo, cDirServ+cArquivo+"2")
//Anexo no link
for NXX := 1 to Len(_aFile)
	oWF:oHTML:ValByName("anexo_link", cWFDHTTP + cGerHTML +"/" + cMailID + ".htm")
	oWF:AttachFile(_aFile[NXX]) //Caminho do Anexo	
next
*/

cMailID := oWF:Start(cWFDir+cGerHTML,.T.)

// Inicio da definicao do email do Link
oWF:NewTask(cAssunto, "\workflow\XWF677B_link.htm")

//Anexo
for NXX := 1 to Len(_aFile)
	oWF:AttachFile(_aFile[NXX]) //Caminho do Anexo	
next

oWF:cSubject   := cAssunto

if _lTSTHM
	oWF:cTo 		:= Alltrim(EMAILTST)
else
	oWF:cTo 		:= Alltrim(cAPREMA)
endif	

oWF:oHTML   	 		:= oWF:oHTML

ConOut("(BEGIN|WFLINK - XWF677B )Process Id: " + oWF:fProcessID + " - Task: " + oWF:fTaskID)
// Cabecalho
oWF:oHTML:ValByName("C_LINKLOGO",	   cLinkLogo)
oWF:oHTML:ValByName("C_PCONTA",		   _cPRESTA)
oWF:oHTML:ValByName("C_FILIAL",		   Upper(SM0->M0_FILIAL))
oWF:oHTML:ValByName("C_EMISSAO",	   DtoC(_dEMISSAO) )
oWF:oHTML:ValByName("C_PARTICIPANTE",  AllTrim(cPARNOM) + "      (" + Alltrim(cPAREMA) + ")")
oWF:oHTML:ValByName("C_CPF",	       cCpf)
oWF:oHTML:ValByName("C_OBS",	       cObsFLF)

for nX := 1 to Len(aItens)
	aAdd((oWF:oHTML:ValByName("I.ITEM")),	  aItens[nX,1])
	aAdd((oWF:oHTML:ValByName("I.DATA")),	  aItens[nX,2])
	aAdd((oWF:oHTML:ValByName("I.CODLOCAL")), aItens[nX,3])
	aAdd((oWF:oHTML:ValByName("I.DESPESA")),  aItens[nX,4])
    aAdd((oWF:oHTML:ValByName("I.DESCR")),	  aItens[nX,5])
    aAdd((oWF:oHTML:ValByName("I.GRUPO")),	  aItens[nX,6])
	aAdd((oWF:oHTML:ValByName("I.QTDE")),	  Transform(aItens[nX,7], "@E 999,999,999"))
    aAdd((oWF:oHTML:ValByName("I.MOEDA")),	  aItens[nX,8])
	aAdd((oWF:oHTML:ValByName("I.TOTAL")),	  Transform(aItens[nX,9], "@E 999,999,999.99"))
	aAdd((oWF:oHTML:ValByName("I.CCUSTO")),	  aItens[nX,10])
	aAdd((oWF:oHTML:ValByName("I.COBS2")),	  aItens[nX,11])
next nX

oWF:oHTML:ValByName("R_TOTAL",		Transform(nTotGer, "@E 999,999,999.99"))

oWF:oHTML:ValByName("R_MAILID",	    cMailId)
oWF:oHTML:ValByName("R_AMBIENTE",	cAmbiente)

oWF:oHTML:ValByName("proc_link", cWFDHTTP + cGerHTML +"/" + cMailID + ".htm")	//
oWF:Start()

/*

Local cWFBRWSR  := GetMV("MV_WFBRWSR", .F.,"") //IP ou nome do servidor HTTP
Local cWFDir	:= GetMV("MV_WFDIR", .F.,"")   //Diretorio de trabalho do Workflow 
Local cWFDHTTP  := GetMV("MV_WFDHTTP", .F.,"") //Diretorio do servido HTTP          
*/

Return(cMailId)

/*/{Protheus.doc} XWF677B
    ( Monto o envio do WF via Link )
    @type  Static Function
    @author AOliveira
    @since 20/07/2021
    @version 1.0
/*/
User Function XWF677B3(oWF)
Local cNum	    := Alltrim(oWF:oHtml:RetByName("NUMERO"))
Local cPARTIC	:= AllTrim(oWF:oHtml:RetByName("PARTICIPANTE"))
Local cAprov	:= AllTrim(oWF:oHtml:RetByName("APROVADOR"))
Local cSubst	:= AllTrim(oWF:oHtml:RetByName("SUBSTITUTO"))
Local cOpcao	:= AllTrim(oWF:oHtml:RetByName("OPC"))
Local cObs		:= AllTrim(oWF:oHtml:RetByName("JUSTIFICATIVA"))
Local cMailId	:= Substr(AllTrim(oWF:oHtml:RetByName("WFMAILID")), 3)		//campo alimentado com a string 'WF' + o c?igo do processo

Local lOK := .T.

Local cAction  := iif(cOpcao == "APROVAR", "A", "R")
Local aUser    := {}
Local cTpAprov := ""
Local cMotv    := Alltrim(cObs)

cPARTIC	:= cPARTIC
cSubst := cSubst
cObs := cObs
cMailId := cMailId

//INDICE 1 FLN
//FLN_FILIAL+FLN_TIPO+FLN_PRESTA+FLN_PARTIC+FLN_SEQ+FLN_TPAPR
conout('XWF677B3 -> APROVACAO DA PRESTACAO DE CONTA ')

DbSelectArea("FLN")
FLN->(DbSetOrder(1)) //FLN_FILIAL+FLN_TIPO+FLN_PRESTA+FLN_PARTIC+FLN_SEQ+FLN_TPAPR
If FLN->(DbSeek( cNum))

	conout('XWF677B3 -> RDV : '+CValToChar(cNum))

	DbSelectArea("FLF")
	FLF->(DbSetOrder(1)) //FLF_FILIAL+FLF_TIPO+FLF_PRESTA+FLF_PARTIC
	if FLF->(DbSeek( FLN->(FLN_FILIAL+FLN_TIPO+FLN_PRESTA+FLN_PARTIC) ))

		if !(FLF->FLF_STATUS <> '1')

			conout('XWF677B3 -> RDV JA APROVADA-> '+CValToChar(cNum))

			cMsg := '<html><body>'
			cMsg += '<font size="3" face="Calibri">Prezado(a) ' + AllTrim(UsrFullName(cAprov)) + ',</font><br><br>'
			cMsg += '<font size="3" face="Calibri">A Conferencia de Presta��o de conta  nr. ' + FLF->FLF_PRESTA + ' foi REALIZADA, anteriormente por algu�m com o mesmo perfil de al�ada que o seu, portanto sua a��o neste processo n�o foi aceita.</font><br><br><br>'
			cMsg += '<font size="1" face="Calibri"><i>E-mail autom�tico enviado pelo processo de workflow, Favor n�o responde-lo.</i></font><br><br>'
			cMsg += '</body></html>'

			//enviar email
			
		else

			If Alltrim(FLN->FLN_APROV) == Alltrim(cAprov)
				cTpAprov := 'O'
			EndIf
						
			If Empty(cTpAprov)
				RD0->(DbSetOrder(1)) // Filial + Participante
				If RD0->(DbSeek( xFilial("RD0") + FLN->FLN_PARTIC ))

					FINXUser(__cUserID, @aUser, .F.)

					If Alltrim(cAprov) == Alltrim(RD0->RD0_APROPC)
						cTpAprov := 'O'
					ElseIf Alltrim(cAprov) == AllTrim(RD0->RD0_APSUBS)
						cTpAprov := 'S'
					EndIf
				EndIf 
			EndIf

			conout('XWF677B3 -> cAprov -> '+CValToChar(cAprov))

			If Empty(cTpAprov)
				RD0->(DbSetOrder(1)) // Filial + Participante
				If RD0->(DbSeek( xFilial("RD0") + cAprov ))

					FINXUser(__cUserID, @aUser, .F.)

					If Alltrim(cAprov) == Alltrim(RD0->RD0_APROPC)
						cTpAprov := 'O'
					ElseIf Alltrim(cAprov) == AllTrim(RD0->RD0_APSUBS)
						cTpAprov := 'S'
					else
						cTpAprov := 'O'
					EndIf
				Else
					cTpAprov := 'O'
				EndIf 
			EndIf


			conout('XWF677B3 -> cTpAprov -> '+CValToChar(cTpAprov))

			F677APRGRV(cAction, cTpAprov, aUser, FLN->FLN_TIPO, FLN->FLN_PRESTA, FLN->FLN_PARTIC, FLN->FLN_SEQ, cMotv, '1',)

			If FLN->(dbSeek( cNum ))
				If FLN->FLN_STATUS == '1'
					//"A opera��o de aprova��o n�o foi conclu�da."
					conout('XWF677B3 -> RDV  opera��o de aprova��o n�o foi conclu�da. -> '+CValToChar(cNum))
					lRet := .F.
					lOK := .F.
				else
					conout('XWF677B3 -> RDV  aprovada com sucesso -> '+CValToChar(cNum))
					DbSelectArea("ZZG")
					ZZG->( DbSetOrder(4) ) //ZZG_FILIAL+ZZG_ALIAS+ZZG_INDICE+ZZG_CHAVE
					if ZZG->( DbSeek(xFilial("ZZG")+"FLN"+"1"+FLN->(FLN_FILIAL+FLN_TIPO+FLN_PRESTA+FLN_PARTIC+FLN_SEQ+FLN_TPAPR)) )
						RecLock("ZZG",.F.)	
						ZZG->ZZG_DATAF := Date()
						ZZG->ZZG_HORAF := Time()
						ZZG->ZZG_OBS   := Alltrim(cObs)
						ZZG->(MsUnlock())
					endif				
				EndIf
			EndIf
		
		endif
	endif
else
	conout('XWF677B3 -> RDV NAO ENCONTRADO-> '+CValToChar(cNum))
	lOK := .F.
EndIf

if lOK
	oWF:Finish()           // FINALIZA O PROCESSO
endif

Return()

