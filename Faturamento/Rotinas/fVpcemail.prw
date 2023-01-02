#Include "Protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"    
#include "ap5mail.ch"


// ------------------------------------------------------------------------------------------
// Ricky Moraes - 26/04/21 - 13:46
// Enviar email para Gerente VPC pendente
// ------------------------------------------------------------------------------------------

******************************************************************************************************************************************************************
User Function  fVpcEmail(aVpcPend)
******************************************************************************************************************************************************************
Local _cSerMail := GetMV("MV_RELSERV")  
Local _cDe       := GetMV("MV_EMCONTA") 
Local _cSenha    := GetMV("MV_EMSENHA")
Local lSmtpAuth := .T. // se o seu servidor requer autenticação 
Local _cRemet    := GetMV("MV_EMCONTA") 
Local _cDest     := ALLTRIM( LOWER(aVpcAberta[1,8]))+';'
Local _cCopia    :=GetMV("BR_VPCMAIL")
Local _cHTML     := "" 
Local _cAssunto := "Relatório VPC "
Local nK:=0

_cDest :=_cDest + _cCopia 


_cHTML:='<html lang="pt-br">'
_cHTML+='  <head>'
_cHTML+='    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />'
_cHTML+='    <meta name="viewport" content="width=device-width, initial-scale=1" />'
_cHTML+='    <meta http-equiv="X-UA-Compatible" content="IE=edge" />'
_cHTML+=''
_cHTML+='    <title></title>'
_cHTML+='    <style type="text/css">'
_cHTML+='      p.ex1 {'
_cHTML+='         padding-top: 1em;'
_cHTML+='        font-size: 14px;'
_cHTML+='        font-weight: bold;'
_cHTML+='      }'
_cHTML+=''
_cHTML+='      p.tit {'
_cHTML+='        font-size: 1.2rem;'
_cHTML+='        text-align: center;'
_cHTML+='        font-weight: bold;'
_cHTML+='      }'
_cHTML+=''
_cHTML+='      table {'
_cHTML+='        border-collapse: collapse;'
_cHTML+='        border: 1px solid rgb(200, 200, 200);'
//_cHTML+='        box-shadow: 5px 5px 5px rgba(0,0,0,0.5);'
_cHTML+='        font-family: sans-serif;'
_cHTML+='        font-size: 0.8rem;'
_cHTML+='        width: 690px;'
_cHTML+='      }'
_cHTML+=''
_cHTML+='      td {'
_cHTML+='        padding: 5px 10px;'
_cHTML+='        text-align: center;'
_cHTML+='        border: 1px solid rgb(190, 190, 190);'
_cHTML+='        font-size: 0.6rem;'
_cHTML+='      }'
_cHTML+=''
_cHTML+='      th {'
_cHTML+='        border: 1px solid rgb(190, 190, 190);'
_cHTML+='        padding: 5px 5px;'
_cHTML+='        text-align: center;'
_cHTML+='        font-size: 0.6rem;'
_cHTML+='      }'
_cHTML+=''
_cHTML+='      caption {'
_cHTML+='        padding: 5px 5px;'
_cHTML+='        background-color: #3f87a6;'
_cHTML+='        font-weight: bold;'
_cHTML+='        color: #fff;
_cHTML+='      }'
_cHTML+=''
_cHTML+='      thead {'
_cHTML+='        background-color: #3f87a6;'
_cHTML+='        color: #fff;
_cHTML+='      }'
_cHTML+=''
_cHTML+='      body {'
_cHTML+='        margin: 0px;'
_cHTML+='      }'
_cHTML+=''
_cHTML+='      tr.noBorder td {'
_cHTML+='        border: 0;'
_cHTML+='      }'
_cHTML+='    </style>'
_cHTML+='  </head>'
_cHTML+=''
_cHTML+='  <body>'

_cHTML+='    <table style="background-color:WhiteSmoke ; height:120px;" >'
_cHTML+='      <tbody>'
_cHTML+='        <tr class="noBorder">'
_cHTML+='          <td width="25%" align="center">'
_cHTML+='            <img'
_cHTML+='              src="https://gamaitaly.vteximg.com.br/arquivos/logo.png"'
_cHTML+='              alt="Gama"'
_cHTML+='            />'
_cHTML+='          </td>'
_cHTML+='          <td width="50%">'
_cHTML+='            <p class="tit">Relatório diário VPC</p>'
_cHTML+='            <p class="tit">Pendente de Aprovação</p>'
_cHTML+='          </td>'
_cHTML+='          <td width="25%" style="vertical-align: top" align="right">'
_cHTML+='            <p class="ex1">Emissão : '
 _cHTML+=DToC(dDataBase)
 _cHTML+='</p>'
_cHTML+='          </td>'
_cHTML+='        </tr>'
_cHTML+='      </tbody>'
_cHTML+='    </table>'

_cHTML+='    <table>'
_cHTML+='      <caption>'

_cHTML+= aVpcAberta[1,7]

_cHTML+='      </caption>'
_cHTML+=''
_cHTML+='      <thead>'
_cHTML+='        <tr>'
_cHTML+='          <th scope="col">#</th>'
_cHTML+='          <th scope="col">VPC</th>'
_cHTML+='          <th scope="col">Código</th>'
_cHTML+='          <th scope="col">Descrição</th>'
_cHTML+='          <th scope="col">Tipo</th>'
_cHTML+='          <th scope="col">Cliente</th>'
_cHTML+='        </tr>'
_cHTML+='      </thead>'
_cHTML+='      <tbody>'

for nK := 1 to Len(aVpcAberta) 
_cHTML+='        <tr>'
_cHTML+='          <th scope="row">'+ aVpcAberta[nk,1] + '</th>'
_cHTML+='          <td scope="row">'+ aVpcAberta[nk,2] + '</td>'
_cHTML+='          <td scope="row">'+ aVpcAberta[nk,3]+ '</td>'
_cHTML+='          <td scope="row">'+ aVpcAberta[nk,4] + '</td>'
_cHTML+='          <td scope="row">'+ aVpcAberta[nk,5] + '</td>'
_cHTML+='          <td scope="row">'+ aVpcAberta[nk,6] + '</td>'
_cHTML+='        </tr>'
next
_cHTML+='        <tr style="background-color: #3f87a6;">'
_cHTML+='          <td colspan="6"> '
_cHTML+='&nbsp;&nbsp' 
_cHTML+=' </td>'
_cHTML+='        </tr>'
_cHTML+='      </tbody>'
_cHTML+='      <tfoot>'
_cHTML+=' <tr>'
_cHTML+='          <td colspan="6">Enviado para : '
_cHTML+=LOWER(aVpcAberta[1,8]) 
_cHTML+=' </td>'
_cHTML+=' </tr>'
_cHTML+='        <tr>'
_cHTML+='          <td colspan="6">'
_cHTML+='            Aviso / Sistema : Este documento é para uso interno, utilizado'
_cHTML+='            para comunicações e avisos.'
_cHTML+='          </td>'
_cHTML+='        </tr>'
_cHTML+='      </tfoot>'
_cHTML+='    </table>'
_cHTML+='  </body>'
_cHTML+=' </html>'
	 




										


//ALERT('Enviar Email registros ' + aVpcPend[1,7])

Connect SMTP Server _cSerMail Account _cDe Password _cSenha Result _lConectou          // Conecta ao servidor de email 

     If !(_lConectou)                                                                                     // Se nao conectou ao servidor de email, avisa ao usuario 
          Get Mail Error _cMailError 
          ConOut("Não foi possível conectar ao Servidor de email. Erro: "+ _cMailError) 

     Else 
          If lSmtpAuth 
               lAutOk := MailAuth(_cDe,_cSenha) 
          Else 
               lAutOK := .t. 
          EndIf 

          IF !lAutOk 
               ConOut("Não foi possivel autenticar no servidor.") 
               
          Else 

               Send Mail From _cRemet To _cDest SUBJECT _cAssunto BODY _cHTML  FORMAT TEXT Result _lEnviado 

               If !(_lEnviado) 
                    Get Mail Error _cMailError 
                    ConOut("Não foi possível enviar o email. Erro: "+ _cMailError) 
                   
               EndIf 
          EndIf 

          Disconnect Smtp Server 
     EndIf 
    
 
Return (_lEnviado)
