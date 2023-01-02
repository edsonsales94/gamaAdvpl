#include "protheus.ch"
#include "tbiconn.ch"
#include "tbicode.ch"

#DEFINE MBF_INBOX	"\inbox"
#DEFINE MBF_OUTBOX	"\outbox"
#DEFINE MBF_SENT	"\sent"
#DEFINE MBF_ERROR	"\error"
#DEFINE MBF_ARCHIVE	"\archive"
#DEFINE MBF_IGNORED	"\ignored"

#define SUNDAY    1
#define MONDAY    2
#define TUESDAY	   3
#define WEDNESDAY 4
#define THURSDAY  5
#define FRIDAY    6

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  บGIRecebCabบ Autor บ Denis Polastri     บ Data ณ  18/01/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบObjetivo  ณ Verifica uma conta de E-Mail e salva os arquivos em anexo  บฑฑ
ฑฑบ          ณ em um diretorio corrente da rede.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ [emp][filial]                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
User Function GIRECEBCAB( aParam )

	Private lWorkFlow  	 := IIF( aParam = Nil , .F. , .T. )	
	Private drFalso 	 := .F.
	Private drVerdadeiro := .T.
	Private cLck         := ""
	Private cLogPop      := ""
	Private cDirPOP		 := ""
	Private _cEmpAtu     := ""
	Private _cFilAtu     := ""
	Private cCtaActive   := ""
	Private lTicket      := .F.
	Private _cModo       := ""
	Private cAssunto     := ""

	If lWorkFlow
		PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2]
		Private ARQLOG := "\AUTOCOM\TEF" + aParam[1] + aParam[1] + "\GIRECEBCAB.LOG"
	Endif

	Private ARQLOG := "\AUTOCOM\TEF" + cEmpAnt + cFilAnt + "\GIRECEBCAB.LOG"
	
	LjWriteLog( ARQLOG, Replicate("-",100) )
	LjWriteLog( ARQLOG, "Inicio de execu็ใo da fun็ใo GIRECEBCAB()" )

	_cModo := AllTrim(GetMv("MV_WFMODMF"))

	RecebeMail()
	
	LjWriteLog( ARQLOG, "Fim da execu็ใo da fun็ใo GIRECEBCAB()" )
	LjWriteLog( ARQLOG, Replicate("-",100) )

	IF lWorkflow
		RESET ENVIRONMENT
	Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  บ WFPOMail บ Autor บ Mauro Paladini Han บ Data ณ  10/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบObjetivo  ณ Executa baixa dos E-Mails.                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function RecebeMail()

	Private cCtaEmail := ""

	cLck 	:= "\SYSTEM\" + IIF(lWorkflow,cEmpAnt,cFilAnt) + "WFPOP.LCK"
	_cEmpAtu 	:= SM0->M0_CODIGO
	_cFilAtu	:= SM0->M0_CODFIL
	cDirPop		:= "\SYSTEM\WF"+cEmpAnt+"\LOG\"
	U_GiCriaDir(cDirPop)
	cLogPop		:= cDirPOP + "Receive.log"

	If _cModo == "L"
		cCtaEmail := AllTrim(GetMv("MV_WFRPCBS",,"WF_REPLICA_BASE_F"))
	Else
		cCtaEmail := AllTrim(GetMv("MV_WFRPCBS",,"WF_REPLICA_BASE_M"))
	EndIf
	
	If !File(cLck)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ  Grava arquivo de semaforo para nใo rodar processamento enquanto baixa msgs  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		u_GravaTxt( cLck , DTOC(Date()) )		

		LjWriteLog( ARQLOG, "Procura conta do workflow" )

		DbSelectArea("WF7")
		DbSetOrder(1)
		If MsSeek( xFilial("WF7") + cCtaEmail )
			LjWriteLog( ARQLOG, "Conta "+cCtaEmail+" encontrada" )
			While WF7->( !Eof() )
				nRecWF7 := WF7->( Recno() )
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Baixa os e-mails, salva os anexos e retorna ticketsณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				RCVMail( RTrim(WF7->WF7_PASTA) , { _cEmpAtu, _cFilAtu, RTrim(WF7->WF7_PASTA) , .T. } )
				WF7->( DbGoTo(nRecWF7) )
				WF7->( DbSkip() )
			End
		Else
			LjWriteLog( ARQLOG, "Conta "+cCtaEmail+" nใo cadastrada, entre em contato com o suporte t้cnico." )
			U_GIENVIACAB( 4 ,"", "Conta "+cCtaEmail+" nใo cadastrada, processo abortado." )
			Return(Nil)
		EndIf
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ *** SEMAFORO *** ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Delete File &(cLck)
		If File(cLck)
			_nTry := 1
			While File(cLck) .And. _nTry < 30
				Delete File &(cLck)
				_nTry := _nTry + 1
			End
			If _nTry >= 30
				_lDeleta := .F.
				u_GravaTxt( cLogPop, "Erro ao deletar arquivo de controle de semแforo " + cLck  )
			Endif					
		Endif		
	Else
		LjWriteLog( ARQLOG, "Download do e-mail CANCELADO, aguardando libera็ใo do semaforo." )
		U_GIENVIACAB( 4 ,"", "Download do e-mail CANCELADO, aguardando libera็ใo, arquivo *.LCK esta bloqueando a sequencia." )
		u_GravaTxt( cLogPop, "Aguardando liberacao do SEMAFORO ..." )		
	Endif			
		
Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RCVMail  บAutor  ณMicrosiga           บ Data ณ  10/14/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que faz a conexao e o recebimento do e_mail         บฑฑ
ฑฑบ          ณ Deve-se ter uma conta cadastrada via cfg no protheus WF7   บฑฑ
ฑฑบ          ณ Esta conta deve ser informada dentro do \SYSTEM\WFPOP.INI  บฑฑ
ฑฑบ          ณ dentro da secao [Config] item ContaWF7                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function RCVMail( cMailBox , lAtivo )

	local oMail
	local aParams
	local cLastAlias := Alias()
	
	CONOUT( "cMailBox := " + cMailBox )	
	
	if valtype( lAtivo ) == "A"
		aParams := { lAtivo[1], lAtivo[2] }
		if len( lAtivo ) >= 3
			lAtivo := lAtivo[3]
		else
			lAtivo := .f.
		end
	else
		aParams := { cEmpAnt, cFilAnt }
	end
	
	oMail := TWFMail():New( aParams )

	LjWriteLog( ARQLOG, "Conta atual := " + RTrim(WF7->WF7_PASTA) )

	WF7->( DbSeek( xFilial("WF7") + cMailBox ) )

	LjWriteLog( ARQLOG, "Verificando caixa postal " + RTrim(WF7->WF7_PASTA) )
	
	WFRcvFiles( { _cEmpAtu , _cFilAtu  } )
	if !Empty( cLastAlias )
		dbSelectArea( cLastAlias )
	end

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  บ WFRcvFiles บ Autor บ Mauro Paladini Han บ Data ณ 10/10/08    บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบObjetivo  ณ Cria objeto de transmissao dos dados e chama classe que faz  บฑฑ
ฑฑบ          ณ o recebimento dentro do Protheus 10                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ [emp][filial]                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static function WFRcvFiles( aParams )

	Local nC
	Local oTD
	Local aUserFuncs := {}

	Default aParams := {}
	
	If Len( aParams ) >= 2
		oTD := TWFTransDados():New( aParams )
		oTD:cMailbox  := ALLTRIM(WF7->WF7_PASTA)
		for nC := 3 to len( aParams )
			AAdd( aUserFuncs, aParams[ nC ] )
		end
		ClassReceive(aUserFuncs,oTD )
	Else
		LjWriteLog( ARQLOG, Replicate( "*",79 ) )
		LjWriteLog( ARQLOG, '* FALHA DE EXECUCAO' )
		u_GravaTxt( cLogPop, '* FALHA DE EXECUCAO' )
		LjWriteLog( ARQLOG, Replicate( "*",79 ) )
		U_GIENVIACAB( 4 ,"", "Erro ao abrir caixa de e-mail: "+ALLTRIM(WF7->WF7_PASTA) )
	Endif
	
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  บ ClassReceiveบ Autor บ Mauro Paladini Han บ Data ณ 10/10/08 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบObjetivo  ณ Faz checagem na INBOX e inicia job de recebimento das msgs บฑฑ
ฑฑบ          ณ disponiveis na INBOX                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ [1] Funcoes de usuario                                     บฑฑ
ฑฑบ          ณ [2] Objeto herdeiro                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static function ClassReceive(aUserFuncs,oTD)

	Local nC
	Local bLastError
	Local oMail, oMailBox
	Local cMsg, cLastAlias := Alias()

	PUBLIC oTransDados := oTd , oLogFile
		
	oTd:lSendMail := .f.

	oLogFile := WFFileSpec( cDirPop	 + "receive.log" )
	
	cMsg := Replicate( "*", 80 )
	oLogFile:WriteLN( cMsg )
	ConOut( cMsg )
    
	LjWriteLog( ARQLOG, "Verificando caixa de entrada" )
	cMsg := FormatStr( "VERIFICANDO CAIXA DE ENTRADA... [%c]", oTd:cMailBox )
	WFConOut( cMsg, oLogFile )
		
	oMail := TWFMail():New()
	oMailBox := oMail:GetMailBox( oTd:cMailBox )

	if !oMailBox:lExists
		LjWriteLog( ARQLOG, "Erro ao conectar no servidor de e-mail." )
		LjWriteLog( ARQLOG, "Verificar as configura็๕es da conta no configurador." )
		cMsg := "Recipiente de mensagem nao encontrado."
		WFConOut( cMsg, oLogFile, .f. )
		cMsg := Replicate( "*", 80 )
		oLogFile:WriteLN( cMsg )
		WFConOut( cMsg )
		U_GIENVIACAB( 4 ,"", "Erro ao conectar no servidor de e-mail." )
		return
	end

	oMailBox:bBeforeReceive := "u_TDDepoisReceive( oMsg, oMailBox )"  // Executa apos download da mensagem
    oMailBox:Receive()  // Obtem as mensagens da caixa de entrada 
   
	if Len( aUserFuncs ) > 0
		cMsg := "Executando funcoes de usuแrio ap๓s o recebimento..."
		WFConOut( cMsg, oLogFile, .f. )
		bLastError := ErrorBlock( { |e| oSelf:ExceptError( e ) } )

		BEGIN SEQUENCE
		                         
			for nC := 1 to Len( aUserFuncs )
				if !Empty( cUserFunc := AllTrim( aUserFuncs[ nC ] ) )
					if At( "(", cUserFunc ) == 0
						cUserFunc += "("
					end
					if At( ")", cUserFunc ) == 0
						cUserFunc += ")"
					end
					cMsg := "Executando"
					cMsg += " '" + cUserFunc + "' "
					WFConOut( cMsg, oLogFile, .f. )
					Eval( &( "{|| " + cUserFunc + " }" ) )
				end
			next
			
		END SEQUENCE

		ErrorBlock( bLastError )		
	end

	if oTd:lSendAuto .or. oTd:lSendMail
		StartJob( "WFLauncher", GetEnvServer(), .f., { "WFSndMsg", { cEmpAnt, cFilAnt, oTd:cMailBox } } )
	end

	cMsg := Replicate( "*", 80 )
	oLogFile:WriteLN( cMsg )
	ConOut( cMsg )
	oLogFile:Close()

	if !Empty( cLastAlias )
		dbSelectArea( cLastAlias )
	end

return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  บ TDDepoisRcv บ Autor บ Mauro Paladini Han บ Data ณ 10/10/08    บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบObjetivo  ณ Funcao de usuario que e executada logo depois do download     บฑฑ
ฑฑบ          ณ da mensagem na Inbox.                                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ [1] Msg atual da Inbox                                        บฑฑ
ฑฑบ          ณ [2] Objeto herdeiro                                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
User Function TDDepoisReceive( oMsg, oMailBox )

	local oInboxFolder, oArchiveFolder
	local nC1, nC2 := 1, nAttachs
	local cMsg, cAttachFile, cRootPath
	local aMails := WFTokenChar( WFGetAddress( AllTrim( WFGetMV( "MV_TDMLAUT", "" ) ) ), ";" ), aAttachFiles
	local lMailAutoriz
	
	Private cDirEntrada := AllTrim(GetMv("MV_GWRECEB",,"\SYSTEM\WF"+cEmpAnt+"\RECEBE\"))

	LjWriteLog( ARQLOG, "Recebendo e-mails." )

	U_GiCriaDir(cDirEntrada)
	
	if (oMsg == nil)
		return
	end

	cRootPath := AllTrim( GetSrvProfString( "RootPath","" ) )
	cRootPath := if( Right( cRootPath, 1 ) == "\", Left( cRootPath, Len( cRootPath ) -1 ), cRootPath )
	
	oArchiveFolder := oMailBox:NewFolder( MBF_ARCHIVE )
	oInboxFolder := oMailBox:GetFolder( MBF_INBOX )
	
	lMailAutoriz := .f.
	
	for nC1 := 1 to Len( aMails )
		if At( AllTrim( Upper( aMails[ nC1 ] ) ), Upper( oMsg:cFrom ) ) > 0
			lMailAutoriz := .t.
		end
	next
	
	aAttachFiles := {}
	if ( nAttachs := oMsg:GetAttachCount() ) > 0
		if oTransDados:lNF002 .and. !Empty( oTransDados:cMailAdmim ) .and. !(lMailAutoriz)
			if ( oMsg:GetAttachInfo( nC2 )[2] == "text/html" )
				while file( cAttachFile := oTransDados:cTempDir + ChgFileExt( CriaTrab(,.f.),".htm" ) )
				end
				oMsg:SaveAttach( nC2++, cDirEntrada + cAttachFile )
				WFNewMessage( oTransDados:cMailBox, oTransDados:cMailAdmim,,, TD_NOTIFY, WFLoadFile( cAttachFile ) )
				FErase( cAttachFile )
				oTransDados:lSendMail := .t.
			end
		end
		for nC1 := nC2 to nAttachs
			if ( cAttachFile := oMsg:GetAttachInfo( nC1 )[1] ) <> NIL 
				if !Empty( cAttachFile := AllTrim( cAttachFile ) )
					AAdd( aAttachFiles, { nC1, cAttachFile } )
				end
			end
		next

	end
	IF len( aAttachFiles ) > 0
		cMsg := "Ha %c arquivo(s) anexo(s)."
		cMsg := FormatStr( cMsg, StrZero( Len( aAttachFiles ),4 ) )
		WFConOut( cMsg, oLogFile, .f. )
		For nC2 := 1 to Len( aAttachFiles )
			cAttachFile := aAttachFiles[ nC2,2 ]
			cMsg := "[#%c| "
			cMsg += "Gravando"
			cMsg += " '" + cAttachFile + "' "
			cMsg += "em"
			cMsg += " %c"
			
			cMsg := FormatStr( cMsg, { StrZero( nC2,4 ), cDirEntrada + cAttachFile } )  
			WFConOut( cMsg, oLogFile, .f. )
		                                    
		    //oMsg:SaveAttach( aAttachFiles[ nC2,1 ] -1, cRootPath + cDirEntrada + cAttachFile )
		    If nAttachs > Len( aAttachFiles )           
		    	oMsg:SaveAttach( aAttachFiles[ nC2,1 ], cRootPath + cDirEntrada + cAttachFile )
		    Else //P11
		    	oMsg:SaveAttach( aAttachFiles[ nC2,1 ] -1, cRootPath + cDirEntrada + cAttachFile )  
		    EndIf		    

			If !File(cDirEntrada + cAttachFile)
				LjWriteLog( ARQLOG, "O arquivo "+cAttachFile+" nใo foi salvo, verifique a caixa de entrada." )
				U_GIENVIACAB( 4 ,"", "O arquivo "+cAttachFile+" nใo foi salvo, verifique a caixa de entrada." )
				Return
			EndIf
		    
			cAssunto := AllTrim(oMsg:cSubject)
			LjWriteLog( ARQLOG, "Chama a fun็ใo GiProcCab para importar o arquivo "+cAttachFile+" anexo" )
			U_GIPROCCAB(cAssunto)

		    LjWriteLog( ARQLOG, "Mensagem cont้m anexo(s): "+cAttachFile )
			LjWriteLog( ARQLOG, "Assunto: "+cAssunto )	
		Next
	Else
		LjWriteLog( ARQLOG, "Mensagem nใo cont้m anexos" )
		cMsg := "Nao ha arquivos anexos."
		WFConOut( cMsg, oLogFile, .f. )
		cMsg := "Movendo"
		cMsg += " '" + oArchiveFolder:cRootPath + "' "
		WFConOut( cMsg, oLogFile, .f. )					
		cAssunto := AllTrim(oMsg:cSubject)
		LjWriteLog( ARQLOG, "L๊ ticket - Assunto: "+cAssunto )
		U_GIGRLOGZ01(cAssunto)
		If _cModo == "L"
			PutMv( "MV_STATUWF" , "IMPORTADO" )
		EndIf
	EndIf
	LjWriteLog( ARQLOG, "Mensagem baixada na caixa de entrada" )
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGravaTxt  บAutor  ณMauro Paladini      บ Data ณ  02/22/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria arquivo texo com base em informacoes                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
User Function GravaTxt( cArq, cTexto )
	Local nHandle := 0
	If !File( cArq )
		nHandle := FCreate( cArq )
		FClose( nHandle )		
	Endif
	If File( cArq )
		nHandle := FOpen( cArq, 2 )
		FSeek( nHandle, 0, 2 )	// Posiciona no final do arquivo
		FWrite( nHandle, cTexto + Chr(13) + Chr(10), Len(cTexto)+2 )
		FClose( nHandle) 
	Endif
Return