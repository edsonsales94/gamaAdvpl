#include "rwmake.ch"
#include "topconn.ch"
#include "ap5mail.ch"
#Include "Protheus.ch"
#include "Fileio.ch"


// ------------------------------------------------------------------------------------------
// Ricky Moraes - 16/06/21 - 16:10
// Enviar email para Colaboradores
// ----------------------------------------------------------------------------------------

******************************************************************************************************************************************************************
User Function fRelAnive()
******************************************************************************************************************************************************************
	Local cEmp		:= "01"
	Local cFil		:= "01"



//———————————————————————————————————————————————————————————————————————————————
// Abertura do ambiente                                         
//———————————————————————————————————————————————————————————————————————————————
	WfPrepEnv(cEmp, cFil, "U_fRelAnive",, "SIGAGPE")

	//fSendRelAnive('01')

	//fSendRelAnive('03')
	//sfGzip()

	sfNiverMail("Aniversariantes Manaus","01")
	//sfNiverMail("Aniversariantes São Paulo","03")
	//———————————————————————————————————————————————————————————————————————————————
// Encerramento do ambiente                                                     
//———————————————————————————————————————————————————————————————————————————————
	RpcClearEnv()

	ConOut(dTOc(Date()) + " as " + Time() + ". Relatorio Aniversariante Semana ")

Return

*****************************************************************************************************************************************************************
Static Function sfMontarRodape()
******************************************************************************************************************************************************************

	Local _cHTMLAux1:=''
/*
	_cHTMLAux1+='</table>'
	_cHTMLAux1+='                                </td>'
	_cHTMLAux1+='                            </tr>'
	_cHTMLAux1+='                            <tr>'
	_cHTMLAux1+='                                <td align="center" style="padding:0px 0px 0px 0px;background: #C1ECE0;">'
	//_cHTMLAux1+='                                    <img src="cid:footHap" alt="RODAPE" border="0" width="600" style="height:auto"; >'
	_cHTMLAux1+=' <img src="https://i.ibb.co/pdjbhHS/RODAPE.png" alt="RODAPE" border="0"  width="600" style="height:auto";>'

	_cHTMLAux1+='								</td>'
	_cHTMLAux1+='                            </tr>'
	_cHTMLAux1+=''
	_cHTMLAux1+='                        </td>'
	_cHTMLAux1+='                    </tr>'
	_cHTMLAux1+='                </table>'
	_cHTMLAux1+='            </td>'
	_cHTMLAux1+='        </tr>'
	_cHTMLAux1+=''
	_cHTMLAux1+='    </table>'
	_cHTMLAux1+='</body>'
	_cHTMLAux1+=''
	_cHTMLAux1+='</html>'
*/
Return _cHTMLAux1


******************************************************************************************************************************************************************
Static Function fDadosAniveRH(cFil1)
******************************************************************************************************************************************************************
	Local cQryAux  := ""
	Local _cHTMLAux    := ""
	Local _cDescFilial:=""

	_cDescFilial:= iif(cFil1=='01','Manaus','São Paulo')

	//Montando consulta de dados
	cQryAux := ""
	cQryAux += "EXEC sp_ANIV_SEMANA '"+ cFil1+"' "

	//Executando consulta e setando o total da régua
	TCQuery cQryAux New Alias "QRY_AUX"

	QRY_AUX->(DbGoTop())

	While  ! QRY_AUX->(Eof())

		_cHTMLAux+='<tr align="center">	'
		_cHTMLAux+='    <td style="padding:10px 10px 10px 10px;">&nbsp;</td>'
		_cHTMLAux+='    <td>'
		_cHTMLAux+= Transform((QRY_AUX->DIA), "@E 99,999,999,999")
		_cHTMLAux+='    </td>'
		_cHTMLAux+='    <td>'
		_cHTMLAux+= substring(QRY_AUX->Nome,1,50)
		_cHTMLAux+='    </td>'
		_cHTMLAux+='   <td>'
		_cHTMLAux+= substring(QRY_AUX->CENTRO_CUSTO,1,50)
		_cHTMLAux+='   </td>'
		_cHTMLAux+='</tr>'

		QRY_AUX->(DbSkip())

	EndDo
	QRY_AUX->(DbCloseArea())

	_cHTMLAux+= iif( _cHTMLAux    == "",'Esta semana não tivemos aniversariantes na Filial de ' + _cDescFilial," ")

Return _cHTMLAux

/********************************************************
Utilizando classe TMailMessage
********************************************************/
Static Function sfNiverMail(cAssunto,cFil1)
	Local cMsg := ""
	Local xRet
	Local oServer, oMessage
	Local lMailAuth	:= .T.
	Local cEmailRH:= AllTrim(GetMV("BR_RHAVISO"))
	Local cCorpo, cPara
	Local aAnexos  := {}

	Private cMailConta	:= NIL
	Private cMailServer	:= NIL 
	Private cMailSenha	:= NIL
	
	Default aArquivos := {}
 
	cMailConta :=If(cMailConta == NIL,GETMV("MV_YUSER"),cMailConta)             //Conta utilizada para envio do email
	cMailServer:=If(cMailServer == NIL,GETMV("MV_YSMTP"),cMailServer)           //Servidor SMTP
	cMailSenha :=If(cMailSenha == NIL,GETMV("MV_EMSENHA"),cMailSenha)             //Senha da conta de e-mail utilizada para envio

	oServer := tMailManager():New()
    oServer:SetUseSSL(.T.)
    oServer:SetUseTLS(.T.)
    
 
   	oMessage:= TMailMessage():New()
	oMessage:Clear()
   
	oMessage:cDate	 := cValToChar( Date() )
	oMessage:cFrom   := cMailConta
	oMessage:cTo 	 := cEmailRH
	oMessage:cSubject:= cAssunto
  	oMessage:cBody   :=  '<html><body> <img src="cid:headHap.jpg" alt="Cabeçalho"  border="0"> teste 1</body></html>' //"Teste&lt;br&gt;&lt;img src='cid:headHap.jpg'&gt;"
  	oMessage:MsgBodyType( "application/octet-stream" )

    //oMessage:cBody    :=  '<img src="cid:headHap" alt="Cabecalho" border="0" width="600" style="height:auto"; ><br><br>'+ '<img src="cid:footHap" alt="RODAPE" border="0" width="600" style="height:auto"; ><br><br>' 
	// oMessage:AddCustomHeader("Content-Type","multipart/related")
   	//oMessage:MsgBodyType( "text/html" )
    // Adiciona um anexo, nesse caso a imagem esta no root
     oMessage:AttachFile( '\img\headHap.jpg' )
	 oMessage:AddAttHTag( 'Content-Disposition: inline; Content-ID: &lt;headHap.jpg&gt;' )
	// oMessage:AddCustomHeader("Content-Transfer-Encoding", "base64")
	 oMessage:AddCustomHeader("Content-Type", "application/octet-stream;" )
	 oMessage:AddCustomHeader("Content-Type" ,"text/html; charset='utf-8'")

	//'<html><body> <img src="cid:headHap.jpg" ></body></html>'


  // Essa tag, é a referecia para o arquivo ser mostrado no corpo, o nome declarado nela deve ser o usado no HTML
   //oMessage:AddAttHTag("Content-ID:headHap;")
   //oMessage:AddAtthTag( 'Content-Disposition: attachment; filename=headHap.jpg')
   //oMessage:AddAttHTag("X-Attachment-Id:headHap;")
   //oMessage:AddAttHTag("Content-Type:image/jpeg;")

  //

  // Adiciona um anexo, nesse caso a imagem esta no root
  //oMessage:AttachFile( '\img\footHap.jpg' )
  // Essa tag, é a referecia para o arquivo ser mostrado no corpo, o nome declarado nela deve ser o usado no HTML
  //oMessage:AddAttHTag("Content-ID:footHap;")
  //oMessage:AddAttHTag("X-Attachment-Id:footHap;")
  //oMessage:AddAttHTag("Content-Type:image/jpeg;")
  //oMessage:AddCustomHeader("X-Attachment-Id","footHap")
  // oMessage:AddAtthTag( 'Content-Disposition: attachment; filename=footHap.jpg')

  

	xRet := oServer:Init( "", cMailServer, cMailConta, cMailSenha, 110, 587 ) //inicilizar o servidor
     //oMailServer:Init(cPopServer, cSMTPServer, cAccount, cPassword, nPopPort)

	if xRet != 0
		alert("O servidor SMTP não foi inicializado: " + oServer:GetErrorString( xRet ) )
		return
	endif
   
	xRet := oServer:SetSMTPTimeout( 60 ) //Indica o tempo de espera em segundos.
	if xRet != 0
		alert("Não foi possível definir " + cProtocol + " tempo limite para " + cValToChar( nTimeout ))
	endif
   
	xRet := oServer:SMTPConnect()
	if xRet <> 0
		alert("Não foi possível conectar ao servidor SMTP: " + oServer:GetErrorString( xRet ))
		return
	endif
   
	if lMailAuth
		//O método SMTPAuth ao tentar realizar a autenticação do 
		//usuário no servidor de e-mail, verifica a configuração 
		//da chave AuthSmtp, na seção [Mail], no arquivo de 
		//configuração (INI) do TOTVS Application Server, para determinar o valor.
		xRet := oServer:SmtpAuth( cMailConta, cMailSenha )
		if xRet <> 0
			cMsg := "Could not authenticate on SMTP server: " + oServer:GetErrorString( xRet )
			alert( cMsg )
			oServer:SMTPDisconnect()
			return
		endif
   	Endif
	xRet := oMessage:Send( oServer )
	if xRet <> 0
		alert("Não foi possível enviar mensagem: " + oServer:GetErrorString( xRet ))
	endif
   
	xRet := oServer:SMTPDisconnect()
	if xRet <> 0
		alert("Não foi possível desconectar o servidor SMTP: " + oServer:GetErrorString( xRet ))
	endif
/*
     cCorpo :=  '<html><body> <img src="cid:headHap.jpg" alt="Cabeçalho"  border="0"> teste 2</body></html>' 
	 cPara:="ricky_nill@hotmail.com;ricky.moraes@gamaitaly.com.br;"
	 aAdd(aAnexos, '\img\headHap.jpg') 
	 GPEMail("teste 2", cCorpo, cPara,aAnexos )
	 */
return



******************************************************************************************************************************************************************
Static Function fHtmlNiver(cFil1)
******************************************************************************************************************************************************************
	Local _cHTML     := ""

/*
	_cHTML:='<!DOCTYPE html>'
	_cHTML+='<html lang="pt-br" xmlns="http://www.w3.org/1999/xhtml" xmlns:o="urn:schemas-microsoft-com:office:office">'
	_cHTML+=''
	_cHTML+='<head>'
	_cHTML+='    <meta charset="UTF-8">'
	_cHTML+='    <meta name="viewport" content="width=device-width,initial-scale=1">'
	_cHTML+='    <meta name="x-apple-disable-message-reformatting">'
	_cHTML+='    <title>GamaItaly</title>'
	_cHTML+='    <!--[if mso]>'
	_cHTML+='	<noscript>'
	_cHTML+='		<xml>'
	_cHTML+='			<o:OfficeDocumentSettings>'
	_cHTML+='				<o:PixelsPerInch>96</o:PixelsPerInch>'
	_cHTML+='			</o:OfficeDocumentSettings>'
	_cHTML+='		</xml>'
	_cHTML+='	</noscript>'
	_cHTML+='	<![endif]-->'
	_cHTML+='    <style>'
	_cHTML+='        table,'
	_cHTML+='        td,'
	_cHTML+='        div,'
	_cHTML+='        h1,'
	_cHTML+='        p {'
	_cHTML+='            font-family:Arial, sans-serif;'
	_cHTML+='       }'
	_cHTML+='    </style>'
	_cHTML+='</head>'
	_cHTML+=''
	_cHTML+='<body style="margin:0;padding:0px 0px 0px 0px;">'
	_cHTML+='    <table role="presentation" style="width:100%;border-collapse:collapse;border:0;border-spacing:0;background: #ffffff;">'
	_cHTML+='        <tr style="padding:0px 0px 0px 0px;">'
	_cHTML+='            <td align="center" style="padding:0px 0px 0px 0px;">'
	_cHTML+='                <table role="presentation" style="width:602px;border-collapse:collapse;border:1px solid #cccccc;border-spacing:0;text-align:left;">'
	_cHTML+='                    <tr>'
	_cHTML+='                        <td align="center" style="padding:0px 0 0px 0;background: #C1ECE0;">'
	_cHTML+='	<picture>	'
	_cHTML+='							<img src="https://i.ibb.co/vmB8fh6/CABECALHO.png" alt="CABECALHO" border="0" width="600" style="height:auto;display:block;">'
	_cHTML+='	</picture>	'
	//_cHTML+='                            <img src="cid:headHap" alt="CABECALHO" border="0" width="600" style="height:auto;display:block;">'
	_cHTML+='                        </td>'
	_cHTML+='                    </tr>'
	_cHTML+='                    <tr>'
	_cHTML+='                        <td style="padding:0px 0px 5px 0px; background: #ffffff; " align="center">'
	_cHTML+='                            <tr>'
	_cHTML+='                                <td style="padding:0px 0px 35px 0px; background: #ffffff; " align="center">'
	_cHTML+='                                    <table role="presentation" style="width:100%;border-collapse:collapse;border:0;border-spacing:0;">'
	_cHTML+='                                        <tr align="center" style="padding:10px 10px 10px 10px;">'
	_cHTML+='                                            <td style="padding:10px 10px 10px 10px;">&nbsp;</td>'
	_cHTML+='                                            <td style="font-weight:bold">Dia</td>'
	_cHTML+='                                            <td style="font-weight:bold">Nome</td>'
	_cHTML+='                                            <td style="font-weight:bold">Área/Dpto.</td>'
	_cHTML+='                                        </tr>'

*/
/*
// buscar funcao de dados
	_cHTML+=fDadosAniveRH(cFil1)
	_cHTML+=sfMontarRodape()

*/

RETURN(_cHTML)


