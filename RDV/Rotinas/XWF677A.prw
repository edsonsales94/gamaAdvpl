#Include "totvs.ch"
#Include "TopConn.ch"
#Include "ap5mail.ch"

Static _lTSTHM  := .F.
Static EMAILTST := "andre@adeoconsultoria.com.br;sidney.mendes@gamaitaly.com.br;rodrigo.ramos@gamaitaly.com.br"

/*/{Protheus.doc} User Function XWF677A
    ( WorkFlow para Solicitação de Conferencia de Prestacao de contas )
    @type  User Function
    @author AOliveira
    @since 20/07/2021
    @version 1.0
    @see (links_or_references)
/*/
User Function XWF677A()

Local aFiles	:= {"SA2", "RD0", "FLF", "FLE", "FLN"}
Local cEmp		:= "01"
Local aFil		:= {"03"} //{"01", "03", "08", "09"}
Local nX, nY

Local cArqLock := "XWF677A.lck"

EMAILTST := EMAILTST

// Efetua o Lock de gravacao da Rotina - Monousuario 
FErase(cArqLock)
nHdlLock := MsFCreate(cArqLock)
IF nHdlLock < 0
	Conout("Rotina ( u_XWF677A() ) ja em execução.")
	Return(.T.)
EndIF

for nX := 1 to Len(aFil)

    //Abertura do Ambiente
    WfPrepEnv(cEmp, aFil[nX], "U_XWF677A",, "FIN")

    for nY := 1 to (aFiles[nX])
		if Empty(Select(aFiles[nX]))
			ChkFile(aFiles[nX])
		endif         
    next nY

	XWF677A1() // Processando registros

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
Static Function XWF677A1()

Local cQry := ""

DbSelectArea("ZZG")

cQry := " SELECT * "+CRLF
cQry += " FROM "+RetSqlName("FLF")+" "+CRLF
cQry += " WHERE FLF_FILIAL = '"+xFilial("FLF")+"' "+CRLF
cQry += " AND FLF_STATUS IN ('2','3') "+CRLF
cQry += " AND D_E_L_E_T_ = '' "+CRLF
cQry += " AND FLF_FILIAL+FLF_TIPO+FLF_PRESTA+FLF_PARTIC NOT IN (SELECT ZZG_CHAVE "+CRLF
cQry += " 														FROM "+RetSqlName("ZZG")+" "+CRLF
cQry += " 														WHERE ZZG_FILIAL = '"+xFilial("ZZG")+"' "+CRLF
cQry += " 														AND ZZG_ALIAS = 'FLF' "+CRLF
cQry += " 														AND ZZG_CHAVE = FLF_FILIAL+FLF_TIPO+FLF_PRESTA+FLF_PARTIC "+CRLF
cQry += " 														AND D_E_L_E_T_ = '') "+CRLF

TCQUERY cQry ALIAS "XTRB" NEW

dbSelectArea("XTRB")
XTRB->(dbGoTop())
While !(XTRB->(Eof()))

    cMailId := XWF677A2() // Monto o envio  do WF

	if !(Empty(cMailId))
		
		DbSelectArea("ZZG")
		ZZG->(RecLock("ZZG", .t.))
		ZZG->ZZG_FILIAL := xFilial("ZZG")
		ZZG->ZZG_CODIGO := GetSXENum("ZZG", "ZZG_CODIGO")
		ZZG->ZZG_ALIAS  := "FLF" 
		ZZG->ZZG_INDICE := "1"
		ZZG->ZZG_CHAVE  := XTRB->(FLF_FILIAL+FLF_TIPO+FLF_PRESTA+FLF_PARTIC)
		ZZG->ZZG_XLINK  := cMailId
		ZZG->ZZG_STATUS := "1"
		ZZG->ZZG_DATA   := Date()
		ZZG->ZZG_HORA   := TIME()
		//ZZG->ZZG_DATAF := 
		//ZZG->ZZG_HORAF :=
		//ZZG->ZZG_OBS 	:=
		ZZG->ZZG_ORIG := 'XWF677A'  
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
Static Function XWF677A2()
Local cAssunto		:= "Solicitação de Conferencia de Prestação de Contas Nr. " + XTRB->FLF_PRESTA

Local cWFBRWSR  := GetMV("MV_WFBRWSR", .F.,"") //IP ou nome do servidor HTTP
Local cWFDir	:= GetMV("MV_WFDIR", .F.,"")   //Diretorio de trabalho do Workflow 
Local cWFDHTTP  := GetMV("MV_WFDHTTP", .F.,"") //Diretorio do servido HTTP          

Local cGerHTML := "/emp" + cEmpAnt + "/html_rdv"

Local cLinkLogo	:= AllTrim(GetMV("BR_LNKLOGO", .F., " "))

Local aItens		:= {}    
Local nTotGer		:= 0

//
Local _cPRESTA  := XTRB->FLF_PRESTA
Local _dEMISSAO := XTRB->FLF_EMISSAO
Local cCpf      := ""
Local cObsFLF   := posicione('FLF',1,XTRB->(FLF_FILIAL+FLF_TIPO+FLF_PRESTA+FLF_PARTIC) ,'FLF_MOTIVO') 

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

//Pego o Codigo de user de sistema 
//dos Aprovadores
RD0->(dbSetOrder(1)) //RD0_FILIAL+RD0_CODIGO
If RD0->(dbSeek( xFilial("RD0")+XTRB->FLF_PARTIC ))

	//Participante
	cPARTIC := XTRB->FLF_PARTIC
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

_aFile := {}
_cFile := ""

DbSelectArea("FLE")
FLE->(dbGoTop())
FLE->(DbSetOrder(1)) //FLE_FILIAL+FLE_TIPO+FLE_PRESTA+FLE_PARTIC+FLE_ITEM
FLE->(DbSeek( XTRB->FLF_FILIAL+	XTRB->FLF_TIPO+XTRB->FLF_PRESTA ))
while !FLE->(Eof()) .And. (FLE->(FLE_FILIAL+FLE_TIPO+FLE_PRESTA) == XTRB->(FLF_FILIAL+FLF_TIPO+FLF_PRESTA) )
	nTotGer += FLE->FLE_TOTAL
	aAdd(aItens,{FLE->FLE_ITEM,;
	            FLE->FLE_DATA,;	
				FLE->FLE_LOCAL,;	
				FLE->FLE_DESPES,;
				posicione('FLG',1,xFilial('FLG')+FLE->FLE_DESPES,'FLG_DESCRI') ,;
				FLE->FLE_GRUPO,;	
				FLE->FLE_QUANT,;	
				FLE->FLE_MOEDA,;	
				FLE->FLE_TOTAL,;
				XTRB->FLF_CC,;
				FLE->FLE_OBS })

	//
	//Anexos	
	cEntidade := "FLE"
	cChave  := xFilial("FLE") + FLE->FLE_TIPO + FLE->FLE_PRESTA + FLE->FLE_PARTIC + FLE->FLE_ITEM
	AC9->(dbSetOrder(2)) //	AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT+AC9_CODOBJ
	If AC9->(dbSeek(xFilial("AC9") + cEntidade + xFilial(cEntidade) + Alltrim(cChave)))	
		ACB->(dbSetOrder(1))	//	ACB_FILIAL+ACB_CODOBJ
		iF ACB->(dbSeek(xFilial("ACB") + AC9->AC9_CODOBJ))
			_cFile := Alltrim(MsDocPath() + "\" + Alltrim(ACB->ACB_OBJETO) )
			if File(_cFile)
				Aadd(_aFile,  _cFile )
			endif
		endif
	EndIf
	//
	//

	FLE->(DbSkip())	
EndDo

// Monta o HTML para aprovação e verificar o tipo do aprovador
oProcess 	 := TWFProcess():New("WF677A", "Conferencia de Prestação de Contas")
oProcess:cTo := "XWF677A_CONF"

oProcess:NewTask("000020", "\workflow\XWF677A.htm")
oProcess:cSubject	:= cAssunto
oProcess:bReturn	:= "U_XWF677A3()" //Retorno
oProcess:UserSiga	:= "JOB20"
oProcess:NewVersion(.T.)

oHTML := oProcess:oHTML

// Campos de controle para o retorno da pagina de aprovacao
oHTML:ValByName("NUMERO",			XTRB->(FLF_FILIAL+FLF_TIPO+FLF_PRESTA+FLF_PARTIC))
oHTML:ValByName("PARTICIPANTE",		cPARTIC)
oHTML:ValByName("APROVADOR",		cAPROPC)
oHTML:ValByName("SUBSTITUTO",		cAPSUBS)

// Cabecalho
oHTML:ValByName("C_LINKLOGO",	   cLinkLogo)
oHTML:ValByName("C_PCONTA",		   _cPRESTA)
oHTML:ValByName("C_FILIAL",		   Upper(SM0->M0_FILIAL) )
oHTML:ValByName("C_EMISSAO",	   DtoC(Stod(_dEMISSAO)) )
oHTML:ValByName("C_PARTICIPANTE",  AllTrim(cPARNOM) + "      (" + Alltrim(cPAREMA) + ")")
oHTML:ValByName("C_CPF",	       cCpf)
oHTML:ValByName("C_OBS",	       Alltrim(cObsFLF))

for nX := 1 to Len(aItens)
	aAdd((oHTML:ValByName("I.ITEM")),	  aItens[nX,1])
	aAdd((oHTML:ValByName("I.DATA")),	  aItens[nX,2])
	aAdd((oHTML:ValByName("I.CODLOCAL")), aItens[nX,3])
	aAdd((oHTML:ValByName("I.DESPESA")),  aItens[nX,4])
    aAdd((oHTML:ValByName("I.DESCR")),	  aItens[nX,5])
    aAdd((oHTML:ValByName("I.GRUPO")),	  aItens[nX,6])
	aAdd((oHTML:ValByName("I.QTDE")),	  Transform(aItens[nX,7], "@E 999,999,999"))
    aAdd((oHTML:ValByName("I.MOEDA")),	  aItens[nX,8])
	aAdd((oHTML:ValByName("I.TOTAL")),	  Transform(aItens[nX,9], "@E 999,999,999.99"))
	aAdd((oHTML:ValByName("I.CCUSTO")),	  aItens[nX,10])
	aAdd((oHTML:ValByName("I.COBS2")),	  aItens[nX,11])
next nX

oHTML:ValByName("R_TOTAL",		Transform(nTotGer, "@E 999,999,999.99"))


/*
Ret := MakeDir( cWFDHTTP + cGerHTML+_cPRESTA )
//__CopyFile(cDirLocal+cArquivo, cDirServ+cArquivo+"2")
//Anexo no link
for NXX := 1 to Len(_aFile)
	oProcess:oHTML:ValByName("anexo_link", cWFDHTTP + cGerHTML +"/" + cMailID + ".htm")
	oProcess:AttachFile(_aFile[NXX]) //Caminho do Anexo	
next
*/

cMailID := oProcess:Start(cWFDir+cGerHTML,.T.)

// Inicio da definicao do email do Link
oProcess:NewTask(cAssunto, "\workflow\XWF677A_link.htm")

//Anexo
for NXX := 1 to Len(_aFile)
	oProcess:AttachFile(_aFile[NXX]) //Caminho do Anexo	
next

oProcess:cSubject   := cAssunto

if _lTSTHM
	oProcess:cTo 		:= Alltrim(EMAILTST)
else
	oProcess:cTo 		:= Alltrim(cAPREMA)
endif	

oHTML   	 		:= oProcess:oHTML

ConOut("(BEGIN|WFLINK - XWF677A )Process Id: " + oProcess:fProcessID + " - Task: " + oProcess:fTaskID)
// Cabecalho
oHTML:ValByName("C_LINKLOGO",	   cLinkLogo)
oHTML:ValByName("C_PCONTA",		   _cPRESTA)
oHTML:ValByName("C_FILIAL",		   Upper(SM0->M0_FILIAL))
oHTML:ValByName("C_EMISSAO",	   DtoC(Stod(_dEMISSAO)) )
oHTML:ValByName("C_PARTICIPANTE",  AllTrim(cPARNOM) + "      (" + Alltrim(cPAREMA) + ")")
oHTML:ValByName("C_CPF",	       cCpf)
oHTML:ValByName("C_OBS",	       Alltrim(cObsFLF))

for nX := 1 to Len(aItens)
	aAdd((oHTML:ValByName("I.ITEM")),	  aItens[nX,1])
	aAdd((oHTML:ValByName("I.DATA")),	  aItens[nX,2])
	aAdd((oHTML:ValByName("I.CODLOCAL")), aItens[nX,3])
	aAdd((oHTML:ValByName("I.DESPESA")),  aItens[nX,4])
    aAdd((oHTML:ValByName("I.DESCR")),	  aItens[nX,5])
    aAdd((oHTML:ValByName("I.GRUPO")),	  aItens[nX,6])
	aAdd((oHTML:ValByName("I.QTDE")),	  Transform(aItens[nX,7], "@E 999,999,999"))
    aAdd((oHTML:ValByName("I.MOEDA")),	  aItens[nX,8])
	aAdd((oHTML:ValByName("I.TOTAL")),	  Transform(aItens[nX,9], "@E 999,999,999.99"))
	aAdd((oHTML:ValByName("I.CCUSTO")),	  aItens[nX,10])
	aAdd((oHTML:ValByName("I.COBS2")),	  aItens[nX,11])
next nX

oHTML:ValByName("R_TOTAL",		Transform(nTotGer, "@E 999,999,999.99"))

oHTML:ValByName("R_MAILID",	    cMailId)
oHTML:ValByName("R_AMBIENTE",	cAmbiente)

oProcess:oHTML:ValByName("proc_link", cWFDHTTP + cGerHTML +"/" + cMailID + ".htm")	//
oProcess:Start()

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
User Function XWF677A3(oProcess)
Local cNum	    := Alltrim(oProcess:oHtml:RetByName("NUMERO"))
Local cPARTIC	:= AllTrim(oProcess:oHtml:RetByName("PARTICIPANTE"))
Local cAprov	:= AllTrim(oProcess:oHtml:RetByName("APROVADOR"))
Local cSubst	:= AllTrim(oProcess:oHtml:RetByName("SUBSTITUTO"))
Local cOpcao	:= AllTrim(oProcess:oHtml:RetByName("OPC"))
Local cObs		:= AllTrim(oProcess:oHtml:RetByName("JUSTIFICATIVA"))
Local cMailId	:= Substr(AllTrim(oProcess:oHtml:RetByName("WFMAILID")), 3)		//campo alimentado com a string 'WF' + o c?igo do processo

Local lOK := .T.

cPARTIC	:= cPARTIC
cSubst := cSubst
cObs := cObs
cMailId := cMailId

oProcess:Finish()           // FINALIZA O PROCESSO

DbSelectArea("FLF")
FLF->(DbSetOrder(1)) //FLF_FILIAL+FLF_TIPO+FLF_PRESTA+FLF_PARTIC 
If FLF->(DbSeek( cNum))

	if !(FLF->FLF_STATUS $ '2|3')
		cMsg := '<html><body>'
		cMsg += '<font size="3" face="Calibri">Prezado(a) ' + AllTrim(UsrFullName(cAprov)) + ',</font><br><br>'
		cMsg += '<font size="3" face="Calibri">A Conferencia de Prestação de conta  nr. ' + FLF->FLF_PRESTA + ' foi REALIZADA, anteriormente por alguém com o mesmo perfil de alçada que o seu, portanto sua ação neste processo não foi aceita.</font><br><br><br>'
		cMsg += '<font size="1" face="Calibri"><i>E-mail automático enviado pelo processo de workflow, Favor não responde-lo.</i></font><br><br>'
		cMsg += '</body></html>'

		//enviar email

	else

		If cOpcao == "APROVAR"
			lOK := F677GERAPR(FLF->FLF_TIPO, FLF->FLF_PRESTA, FLF->FLF_PARTIC, FLF->FLF_VIAGEM)
		endif

		If lOK
		
			RecLock("FLF",.F.)
			FLF->FLF_CONFER := cAprov
			FLF->FLF_DTCONF	:= dDatabase
			FLF->FLF_STATUS := iif(cOpcao == "APROVAR", "4", "5") //IIF(__lConfReprova,"5","4")	
			FLF->FLF_OBCONF := Alltrim(cObs)
			FLF->(MsUnlock())
		
			DbSelectArea("ZZG")
			ZZG->( DbSetOrder(4) ) //ZZG_FILIAL+ZZG_ALIAS+ZZG_INDICE+ZZG_CHAVE
			if ZZG->( DbSeek(xFilial("ZZG")+"FLF"+"1"+FLF->(FLF_FILIAL+FLF_TIPO+FLF_PRESTA+FLF_PARTIC)) )
				RecLock("ZZG",.F.)	
				ZZG->ZZG_DATAF := Date()
				ZZG->ZZG_HORAF := Time()
				ZZG->ZZG_OBS   := Alltrim(cObs)
				ZZG->(MsUnlock())
			endif
		
		EndIf
	
	endif
EndIf

Return()

