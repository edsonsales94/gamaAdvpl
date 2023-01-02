#include "rwmake.ch"
#include "topconn.ch"    
#include "ap5mail.ch"
#Include "Protheus.ch"

// ------------------------------------------------------------------------------------------
// Ricky Moraes - 23/07/19 - 12:28
// Enviar email quando apontamento for reprovado   pelo CQ
// ------------------------------------------------------------------------------------------

******************************************************************************************************************************************************************
User Function  fAvisoRepCq(cStatus,cDataAtu,cDescProd,cCod,cData,cPa,cCodDef,cTurno,cHora,cOperador,cLocaliz,cObs,cUsuario,nQuant)
******************************************************************************************************************************************************************
Local _cSerMail := GetMV("MV_RELSERV")  
Local _cDe       := GetMV("MV_EMCONTA") 
Local _cSenha    := GetMV("MV_EMSENHA")
Local lSmtpAuth := .T. // se o seu servidor requer autenticação 
Local _cRemet    := GetMV("MV_EMCONTA") 
Local _cUserConta:=UsrRetMail(RetCodUsr())
Local _cDest     := "ricky.moraes@gamaitaly.com.br;joao.zanateli@gamaitaly.com.br;"+_cUserConta 
Local _cHTML     := "" 
Local _cAssunto := "Reprovado CQ - " + alltrim(cCod) + " - " + SUBSTR(cCodDef,1,4)

_cHTML:='<html>															
_cHTML+='<head>													'		
_cHTML+='<META http-equiv="Content-Type" content="text/html;charset=ISO-8859-1">				'		
_cHTML+='<title></title>											'
_cHTML+='<style type="text/css">										'
_cHTML+='table#alter td {background: #FFF;}									'
_cHTML+='table#alter tr.dif td {background: #EEE;}								'
_cHTML+='</style>												'
_cHTML+='</head>												'		
_cHTML+='<table width="695" border="1" >									'		
_cHTML+='<tr>													'		
_cHTML+='<td width="629"><div  class="container"  >								'		
_cHTML+='<left>													'		
_cHTML+='<table width="100%" height="90" border="0">								'		
_cHTML+='<tr>													'		
_cHTML+='  <td width="10%">&nbsp;</td>										'		
_cHTML+='  <td width="65%" height="86" align="center">								'
_cHTML+='  <h1 class="titulo" color=#ff0000>Relatório de Inspeção - CQ </h1></td>				'
_cHTML+='  <td width="25%"><table align="right" >								'		
_cHTML+='    <tr>												'		
_cHTML+='      <td width="54" align="right">Status :</td>							'		
_cHTML+='      <td width="79"><FONT color=#ff0000 size="+1">' +cStatus+' </FONT></td>				'		
_cHTML+='    </tr>												'		
_cHTML+='    <tr>												'		
_cHTML+='      <td align="right">Emissão :</td>									'		
_cHTML+='      <td>' +cDataAtu +'</td>										'		
_cHTML+='    </tr>												'		
_cHTML+='  </table>         											'		
_cHTML+='</table>												'		
_cHTML+='<hr/>													'
_cHTML+='<p></p>												'		
_cHTML+='<table width="100%" border="0">									'		
_cHTML+='<tr>													'		
_cHTML+='  <td width="2%">&nbsp;</td>										'		
_cHTML+='  <td width="98%"><b>Descrição do Produto: <FONT color=#ff0000>' + cDescProd +'</FONT></b></td>	'		
_cHTML+='</tr>													'		
_cHTML+='</table>												'		
_cHTML+='													'
_cHTML+='<table width="650" height="126" align="center" cellspacing="4" id="alter" >				'
_cHTML+='<tr>													'		
_cHTML+='  <td width="115" class="full_table_list" >Codigo :</td>						'		
_cHTML+='  <td width="517">' + cCod + '</td>									'		
_cHTML+='</tr>													'		
_cHTML+='<tr class="dif">											'		
_cHTML+='  <td >Data :</td>											'		
_cHTML+='  <td>' + cData + '</td>										'		
_cHTML+='</tr>													'		
_cHTML+='<tr>													'		
_cHTML+='  <td >Num.PA :</td>											'		
_cHTML+='  <td> '+ cPa +'</td>											'		
_cHTML+='</tr>													'		
_cHTML+='<tr class="dif">											'		
_cHTML+='  <td height="29" >Cod.Defeito :</td>									'		
_cHTML+='  <td><FONT color=#ff0000><b>' + cCodDef +' </b></FONT></td>						'		
_cHTML+='</tr>													'		

_cHTML+='<tr >'
_cHTML+='  <td height="29" >Quantidade :</td>'
_cHTML+='  <td><b>' + nQuant +' </b></td>'
_cHTML+='</tr>'


_cHTML+='</table>												'		
_cHTML+='<p>&nbsp;</p>												'		
_cHTML+='<hr/>													'
_cHTML+='<p></p>												'		
_cHTML+='													'
_cHTML+='													'
_cHTML+='<table width="100%" border="0" >									'		
_cHTML+='<tr>													'		
_cHTML+='  <th width="2%" scope="col">&nbsp;</th>								'		
_cHTML+='  <th width="98%" scope="col" align="left"><b>Informações de Apontamento:</b></th>			'		
_cHTML+='</tr>													'		
_cHTML+='</table>												'		
_cHTML+='													'
_cHTML+='<table width="650" height="146" align="center" cellspacing="4"  id="alter" >				'
_cHTML+='<tr >													'		
_cHTML+='  <td width="115" class="dif" >Turno :</td>								'		
_cHTML+='  <td width="517">' + cTurno + '</td>									'		
_cHTML+='</tr>													'		
_cHTML+='<tr class="dif" >											'		
_cHTML+='  <td  >Hora :</td>											'		
_cHTML+='  <td>' + cHora +' </td>										'		
_cHTML+='</tr>													'		
_cHTML+='<tr >													'		
_cHTML+='  <td  >Operador :</td>										'		
_cHTML+='  <td>'  + cOperador + '</td>										'		
_cHTML+='</tr>													'		
_cHTML+='<tr class="dif">											'		
_cHTML+='  <td >Endereço :</td>											'		
_cHTML+='  <td> '+ cLocaliz + '</td>										'		
_cHTML+='</tr>													'		
_cHTML+='<tr  >													'		
_cHTML+='  <td  >Observações :</td>										'		
_cHTML+='  <td>' + cObs +'</td>											'		
_cHTML+='</tr>													'		
_cHTML+='</table>												'		
_cHTML+='<p>&nbsp;</p>												'
_cHTML+='<hr/>													'
_cHTML+='<table width="100%" border="0">									'		
_cHTML+='  <tr class="dif">											'		
_cHTML+='  <th width="2%" scope="col">&nbsp;</th>								'		
_cHTML+='  <th width="98%" scope="col" align="left">Avaliado por : ' +cUsuario +'</th>				'		
_cHTML+='</tr>													'		
_cHTML+='</table>												'		
_cHTML+='<p></p></tr>												'		
_cHTML+='</table>												'		
_cHTML+='<p>&nbsp;</p>												'		
_cHTML+='</html>												'
														'











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