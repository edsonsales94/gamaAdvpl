#include "protheus.ch"
#DEFINE  ARQLOG "\AUTOCOM\TEF" + cEmpAnt + cFilAnt + "\GIENVIACAB.LOG"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGIENVIACABบAutor  ณDenis Polastri      บ Data ณ  15/01/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบUso       ณExclusivo Cliente Gama italy                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDescricao ณEnvia E-Mail contendo os arquivos CAB anexos, para ser rece-บฑฑ
ฑฑบ          ณbido pela matriz.                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function GIENVIACAB(nOpx,cArqMail,cErro)

Local _cModo   := Alltrim(GetMv("MV_WFMODMF",,"M"))
Local cArqHTML := "\\WFArqBranco.htm"
Local cCtaPara := ""
Local cCtaWF   := ""
Local cCaminho := Alltrim(GetMv("MV_GIFWENV",,"\SYSTEM\WF"+cEmpAnt+"\ENVIA\"))
Local aFiliais := {}
Local cSubjLog := ""
Local cSubject := "Workflow Replica Base Dados"
Local oProcess, oHtml
Local cMailTo  := Alltrim(GetMv("BR_MAILRPC",,"rodrigo.ramos@gamaitaly.com.br"))
Local cSubjTo  := ""
Local x

LjWriteLog( ARQLOG, Replicate("-",100) )
LjWriteLog( ARQLOG, "Inicio de execu็ใo da fun็ใo GIENVIACAB()" )

If ( Substr(cCaminho,Len(cCaminho),1) != "\" , cCaminho := cCaminho + "\" , cCaminho )

LjWriteLog( ARQLOG, "Verifica se a fun็ใo estแ rodando na [M]atriz ou na [F]ilial: ["+_cModo+"]" )
LjWriteLog( ARQLOG, "Verifica se serแ enviado um arquivo CAB ou ticket de confirma็ใo: ["+If(nOpx==1,"CAB","TICKET")+"]" )

If _cModo == "M"
	cCtaWF   := AllTrim(GetMv("MV_WFRPCBS",,"WF_REPLICA_BASE_M"))
	SX5->( DbSetOrder(1) )
	SX5->( MsSeek( xFilial("SX5") + "IS" ) )
	While SX5->( !Eof() .And. X5_TABELA == "IS" )
		Aadd( aFiliais, { SX5->X5_CHAVE, Lower(Alltrim(SX5->X5_DESCRI)) } )
		SX5->( DbSkip() )
	EndDo
Else
	cCtaWF   := AllTrim(GetMv("MV_WFRPCBS",,"WF_REPLICA_BASE_F"))
EndIf

LjWriteLog( ARQLOG, "Conta de  selecionada: "+cCtaWF )

If _cModo == "M" // MATRIZ
	If nOpx == 1 // Arquivo CAB
		For x:=1 To Len(aFiliais)

			cSubjLog := "CAB;"+DtoC(dDataBase)+";"+Time()+";"+cArqMail+";"+"MTZ;"+AllTrim(aFiliais[x,1])

			LjWriteLog( ARQLOG, "Cria task para envio do e-mail - Matriz - Cab" )
			LjWriteLog( ARQLOG, "Assunto: "+cSubjLog )

			oProcess:=TWFProcess():New( cCtaWF , cSubject )
			oProcess:NewTask( cSubject , cArqHTML )
			oHtml:=oProcess:oHTML
			oProcess:NewVersion(.T.)
			oProcess:cSubject:= cSubjLog
			oProcess:cTo:= AllTrim(aFiliais[x,2])
			CONOUT("Conta Email: "+oProcess:cTo)
			oProcess:AttachFile(cCaminho+cArqMail+".CAB")

			LjWriteLog( ARQLOG, "E-mail enviado para: "+oProcess:cTo )
			
			oProcess:Start()
			oProcess:Finish()
			
			U_GIGRLOGZ01(cSubjLog)
			
		Next x
	ElseIf nOpx == 2 // TICKET
		For x:=1 To Len(aFiliais)

			cSubjLog := "TKT;"+DtoC(dDataBase)+";"+Time()+";"+cArqMail+";"+"MTZ;"+AllTrim(aFiliais[x,1])

			LjWriteLog( ARQLOG, "Cria task para envio do e-mail - Matriz - Ticket" )
			LjWriteLog( ARQLOG, "Assunto: "+cSubjLog )
			
			oProcess:=TWFProcess():New( cCtaWF , cSubject )
			oProcess:NewTask( cSubject , cArqHTML )
			oHtml:=oProcess:oHTML
			oProcess:NewVersion(.T.)
			oProcess:cSubject:= cSubjLog
			oProcess:cTo:= AllTrim(aFiliais[x,2])

			LjWriteLog( ARQLOG, "E-mail enviado para: "+oProcess:cTo )

			oProcess:Start()
			oProcess:Finish()

		Next x
		
		//ENVIAR EMAIL COMUNICAR QUE O PROCESSO FINALIZOU COM SUCESSO!
			
			cSubjTo := "Replica em SP Finaliza - "+DtoC(dDataBase)+" "+Time()+". Arquivo:"+cArqMail

			oProcess:=TWFProcess():New( cCtaWF , cSubject )
			oProcess:NewTask( cSubject , cArqHTML )
			oHtml:=oProcess:oHTML
			oProcess:NewVersion(.T.)
			oProcess:cSubject:= cSubjTo  
			oProcess:cTo:= cMailTo

			LjWriteLog( ARQLOG, "E-mail comunicacao enviado para: "+oProcess:cTo )

			oProcess:Start()
			oProcess:Finish()
		
	EndIf
Else // FILIAL
	If nOpx == 1 // Arquivo CAB

		cSubjLog := "CAB;"+DtoC(dDataBase)+";"+Time()+";"+cArqMail+";"+"LJ"+cFilAnt+";"+"MTZ"

		LjWriteLog( ARQLOG, "Cria task para envio do e-mail - Lj"+cFilAnt+" - Cab" )
		LjWriteLog( ARQLOG, "Assunto: "+cSubjLog )

		oProcess:=TWFProcess():New( cCtaWF , cSubject )
		oProcess:NewTask( cSubject , cArqHTML )
		oHtml:=oProcess:oHTML
		oProcess:NewVersion(.T.)
		oProcess:cSubject:= cSubjLog
		oProcess:cTo:= AllTrim(GetMv("MV_GWPACTA",,"rodrigo.ramos@gamaitaly.com.br"))

		LjWriteLog( ARQLOG, "E-mail enviado para: "+oProcess:cTo )

		oProcess:AttachFile(cCaminho+cArqMail+".CAB")
		oProcess:Start()
		oProcess:Finish()
		
		LjWriteLog( ARQLOG, "Altera o parโmetro de controle de status MV_STATUWF para GERADO." )
		LjWriteLog( ARQLOG, "Bloqueando novos arquivos, at้ que as filiais tenham recebido." )
		LjWriteLog( ARQLOG, "MV_STATUWF -> GERADO." )
		
		PutMv( "MV_STATUWF" , "GERADO" )

		LjWriteLog( ARQLOG, "Grava log Z01 "+cSubjLog )				
		U_GIGRLOGZ01(cSubjLog)
		
	ElseIf nOpx == 2 // TICKET

		cSubjLog := "TKT;"+DtoC(dDataBase)+";"+Time()+";"+cArqMail+";"+"LJ"+cFilAnt+";"+"MTZ"

		
		LjWriteLog( ARQLOG, "Cria task para envio do e-mail - Lj"+cFilAnt+" - Ticekt" )
		LjWriteLog( ARQLOG, "Assunto: "+cSubjLog )

		oProcess:=TWFProcess():New( cCtaWF , cSubject )
		oProcess:NewTask( cSubject , cArqHTML )
		oHtml:=oProcess:oHTML
		oProcess:NewVersion(.T.)
		oProcess:cSubject:= cSubjLog
		oProcess:cTo:= AllTrim(GetMv("MV_GWPACTA",,"rodrigo.ramos@gamaitaly.com.br"))

		LjWriteLog( ARQLOG, "E-mail enviado para: "+oProcess:cTo )

		oProcess:Start()
		oProcess:Finish()
		
		//ENVIAR EMAIL COMUNICAR QUE O PROCESSO FINALIZOU COM SUCESSO!

		cSubjTo := "Replica em AM Finaliza - "+DtoC(dDataBase)+" "+Time()+". Arquivo:"+cArqMail

		oProcess:=TWFProcess():New( cCtaWF , cSubject )
		oProcess:NewTask( cSubject , cArqHTML )
		oHtml:=oProcess:oHTML
		oProcess:NewVersion(.T.)
		oProcess:cSubject:= cSubjTo  
		oProcess:cTo:= cMailTo

		LjWriteLog( ARQLOG, "E-mail comunicacao enviado para: "+oProcess:cTo )
			
		oProcess:Start()
		oProcess:Finish()

	EndIf
EndIf

If nOpx == 3
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ  Erro na importacao do arquivo CAB  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cArqHTML := "\\WFArqErroSeq.htm"
	
	LjWriteLog( ARQLOG, "Erro na sequencia do arquivo "+cArqMail )

	oProcess:=TWFProcess():New( cCtaWF , cSubject )
	oProcess:NewTask( cSubject , cArqHTML )
	oHtml:=oProcess:oHTML
	oProcess:NewVersion(.T.)
	oProcess:cSubject:= "Erro na sequencia do arquivo "+cArqMail
	oProcess:cTo:= AllTrim(GetMv("MV_GIADMSY",,"rodrigo.ramos@gamaitaly.com.br"))

	LjWriteLog( ARQLOG, "E-mail enviado para: "+oProcess:cTo )

	oProcess:Start()
	oProcess:Finish()
EndIf


If nOpx == 4
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ  Erros genericos  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	LjWriteLog( ARQLOG, cErro + cArqMail )

	oProcess:=TWFProcess():New( cCtaWF , cSubject )
	oProcess:NewTask( cSubject , cArqHTML )
	oHtml:=oProcess:oHTML
	oProcess:NewVersion(.T.)
	oProcess:cSubject:= cErro + cArqMail
	oProcess:cTo:= AllTrim(GetMv("MV_GIADMSY",,"rodrigo.ramos@gamaitaly.com.br"))
	oProcess:AttachFile(cCaminho+cArqMail+".CAB")
	LjWriteLog( ARQLOG, cErro+oProcess:cTo )

	oProcess:Start()
	oProcess:Finish()   
	
	
EndIf

LjWriteLog( ARQLOG, "Fim da execu็ใo da fun็ใo GIENVIACAB()" )
LjWriteLog( ARQLOG, Replicate("-",100) )

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGravaLogZ01บAutor  ณDenis Polastri      บ Data ณ  28/01/10   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava log de envio e recebimento na tabela Z01. Esta tabela  บฑฑ
ฑฑบ          ณe a base para o e-mail de "status report" da replica.        บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGama Italy                                                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function BkpFiles( nOpx, _lTodos , _lErro , _cFileName )

Local _lRet    := .T.
Local _nTry    := 0
Local _lCopia  := .T.
Local _lDeleta := .T.
Local _aTodos  := {}
Local _aLista  := {}
Local cCaminho := ""
Local cCaminBk := ""
Local cCaminEr := ""
Local _xBkp

If nOpx == 1
	cCaminho := Alltrim(GetMv("MV_GIFWENV",,"\SYSTEM\WF"+cEmpAnt+"\ENVIA\"))		
	cCaminBk := Alltrim(GetMv("MV_GIFWENB",,"\SYSTEM\WF"+cEmpAnt+"\ENVBKP\"))
Else
	cCaminho := Alltrim(GetMv("MV_GWRECEB",,"\SYSTEM\WF"+cEmpAnt+"\RECEBE\"))
	cCaminBk := AllTrim(GetMv("MV_GWRECBK",,"\SYSTEM\WF"+cEmpAnt+"\RECBKP\"))
EndIf

If ( Substr(cCaminho,Len(cCaminho),1) != "\" , cCaminho := cCaminho + "\" , cCaminho )
If ( Substr(cCaminBk,Len(cCaminBk),1) != "\" , cCaminBk := cCaminBk + "\" , cCaminBk )

If !_lTodos
	If ValType(_cFilename) == "A"
		_aTodos := aClone(_cFileName)
	Else
		aAdd( _aTodos , { _cFileName , Nil , Nil , Nil })
	Endif
Else
	_aLista := Directory( cCaminho+"*.*" )
	_aTodos := aClone(_aLista)
Endif

For _xBkp := 1 to Len(_aTodos)
	_cSource := AllTrim(cCaminho+_aTodos[_xBkp][1])

	If !_lErro
		_cTarget := AllTrim( cCaminBk+_aTodos[_xBkp][1])
	Else
		cCaminEr := AllTrim(GetMv("MV_GWPENDT",,"\SYSTEM\WF"+cEmpAnt+"\PENDENTE\"))
		If ( Substr(cCaminEr,Len(cCaminEr),1) != "\" , cCaminEr := cCaminEr + "\" , cCaminEr )
		_cTarget := AllTrim( cCaminEr+_aTodos[_xBkp][1])
	Endif
			
	Copy File &_cSource to &_cTarget

	If !File(_cTarget)
		While !File(_cTarget) .And. _nTry < 30
			Copy File &_cSource to &_cTarget
			_nTry := _nTry + 1
		End
		If _nTry >= 30
			_lCopia := .F.
		Endif
	Else
		Delete File &(_cSource)
		If File(_cSource)
			_nTry := 1
			While !File(_cTarget) .And. _nTry < 30
				Delete File &(_cSource)
				_nTry := _nTry + 1
			End
			If _nTry >= 30
				_lDeleta := .F.
			Endif					
		Endif
	Endif
Next _xBkp

If !_lDeleta .Or. !_lCopia
	_lRet := .F.
Endif

Return( _lRet )	
