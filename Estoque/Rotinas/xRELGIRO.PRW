#include "rwmake.ch"
#include "topconn.ch"    
#include "ap5mail.ch"
#Include "Protheus.ch"
#include "TBICONN.ch" 


// ------------------------------------------------------------------------------------------
// Ricky Moraes - 16/06/21 - 16:10
// Enviar email para Gestores Giro Estoque
// ----------------------------------------------------------------------------------------


User Function fRelGiro()
 
 RPCSetType(3)		// Para nao consumir licenca.
 
 PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" MODULO "EST" TABLES  "SB1","SB2","SB9","SBF","SD3","SDB"  
 
 ConOut("INICIANDO JOB JOBPCC NO AMBIENTE "+GetEnvServer()+" -> " + DtoC(Date()) + " - " + Time())

 U_EXEGIRO() 

 ConOut("FINALIZANDO JOB JOBPCC NO AMBIENTE "+GetEnvServer()+" -> " + DtoC(Date()) + " - " + Time())
 
 RESET ENVIRONMENT
 
Return NIL


******************************************************************************************************************************************************************
Static Function fDadosGiro48h()
******************************************************************************************************************************************************************     
Local cQryAux  := ""
Local _cHTMLAux    := ""
Local cEndereco:=""
Local nCont:=0
Local nSaldo :=0
Local nCusFin:=0


	//Montando consulta de dados
	cQryAux := ""
	cQryAux += "EXEC sp_TEMP_GIRO48H "
		
	//Executando consulta e setando o total da régua
	TCQuery cQryAux New Alias "QRY_AUX"

     QRY_AUX->(DbGoTop())
     
     cEndereco:=QRY_AUX->ENDERECO
     _cHTMLAux:=sfMontarCabecalho(cEndereco)
     


     
     While  ! QRY_AUX->(Eof())

          if cEndereco<>QRY_AUX->ENDERECO
               cEndereco:= QRY_AUX->ENDERECO
               _cHTMLAux+=sfMontarCabecalho(cEndereco)
               nCont:=0
               nSaldo:=0
               nCusFin:=0
          EndIf
          //listar itens da tabela
          nCont:=nCont+1
          _cHTMLAux+='              <tr>	'
          _cHTMLAux+='                <td scope="row">'+  StrZero(nCont,3)  +'</td>	'
          _cHTMLAux+='                <td scope="row">'+QRY_AUX->PRODUTO+'</td>	'
          _cHTMLAux+='                <td scope="row" style="text-align: center">'+QRY_AUX->TIPO+'</td>	'
          _cHTMLAux+='                <td scope="row">	'
          _cHTMLAux+='                ' + QRY_AUX->DESCRICAO
          _cHTMLAux+='                </td>	'
          _cHTMLAux+='                <td scope="row">'+ Transform((QRY_AUX->SALDO), "@E 99,999,999,999.99")  + '</td>	'
          _cHTMLAux+='                <td scope="row">'+QRY_AUX->HORAS+'</td>	'
          _cHTMLAux+='                <td scope="row">'+ Transform((QRY_AUX->CUSFIN), "@E 99,999,999,999.99")  + '</td>	'
          _cHTMLAux+='              </tr>	'

          nSaldo := nSaldo + QRY_AUX->SALDO
          nCusFin:= nCusFin + QRY_AUX->CUSFIN
          cEndereco:= QRY_AUX->ENDERECO
     
          QRY_AUX->(DbSkip())          

          if cEndereco<>QRY_AUX->ENDERECO
               _cHTMLAux+= sfMontarRodape(cEndereco,nSaldo,nCusFin)  
                           
          EndIf


     EndDo
     QRY_AUX->(DbCloseArea())



Return _cHTMLAux




******************************************************************************************************************************************************************
//User Function fRelGiro()
User Function EXEGIRO()
******************************************************************************************************************************************************************
Local _cSerMail := GetNewPar("MV_RELSERV")  
Local _cDe       := GetNewPar("MV_EMCONTA") 
Local _cSenha    := GetNewPar("MV_EMSENHA")
Local lSmtpAuth := .T. // se o seu servidor requer autenticação 
Local _cRemet    := GetNewPar("MV_EMCONTA") 
//Local _cDest     := "ricky.moraes@gamaitaly.com.br;ricky_nill@hotmail.com;"
Local _cDest     := " "
Local _cHTML     := "" 
Local _cAssunto := "Relatório Giro 48h"
Local _cData := DTOC(DATE())
Local _cHora :=time()

_cDest :=GetNewPar("MV_GIRO48H")


_cHTML:='<!DOCTYPE html>	'
_cHTML+='<html lang="pt-br">	'
_cHTML+='  <head>	'
_cHTML+='    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />	'
_cHTML+='    <meta name="viewport" content="width=device-width, initial-scale=1" />	'
_cHTML+='    <title></title>	'
_cHTML+='    <style type="text/css">	'
_cHTML+='      p.ex1 {	'
_cHTML+='        padding-top: 0.1rem;	'
_cHTML+='        font-size: 7rem;	'
_cHTML+='        font-weight: bold;	'
_cHTML+='      }	'
_cHTML+='	'
_cHTML+='      p.tit {	'
_cHTML+='        font-size: 1rem;	'
_cHTML+='        text-align: center;	'
_cHTML+='        font-weight: bold;	'
_cHTML+='      }	'
_cHTML+='	'
_cHTML+='      td {	'
_cHTML+='        padding: 1px 2px;	'
_cHTML+='        border-spacing: 0 0;	'
_cHTML+='        font-size: 8pt;	'
_cHTML+='      }	'
_cHTML+='	'
_cHTML+='      th {	'
_cHTML+='        padding: 2px 2px;	'
_cHTML+='        text-align: left;	'
_cHTML+='        font-size: 8pt;	'
_cHTML+='      }	'
_cHTML+='	'
_cHTML+='      thead {	'
_cHTML+='        background-color: #3f87a6;	'
_cHTML+='        color: #fff;	'
_cHTML+='        font-size: 0.4rem;	'
_cHTML+='        border: #3f87a6;	'
_cHTML+='        border-width: thin;	'
_cHTML+='      }	'
_cHTML+='    </style>	'
_cHTML+='  </head>	'
_cHTML+='  <body style="margin: 0; padding: 0">	'
_cHTML+='    <table cellpadding="0" cellspacing="0" width="650px">	'
_cHTML+='      <tr>	'
_cHTML+='        <td width="25%" style="text-align: center;">	'
_cHTML+='          <img	'
_cHTML+='            src="https://gamaitaly.vteximg.com.br/arquivos/logo.png"	'
_cHTML+='            alt="Gama"	'
_cHTML+='            width="80"	'
_cHTML+='            height="60"	'
_cHTML+='          />	'
_cHTML+='        </td>	'
_cHTML+='        <td width="50%">	'
_cHTML+='          <p class="tit" style="font-size: 12pt">RELATÓRIO POSIÇÃO DE ESTOQUE</p>	'
_cHTML+='          <p class="tit" style="font-size: 12pt" >GIRO DE ESTOQUE - 48H</p>	'
_cHTML+='        </td>	'
_cHTML+='        <td width="25%" style="text-align: right; margin: 0; padding: 0px 8px">	'
_cHTML+='          <p class="tit" style="font-size: 12pt">Emissão : '+_cData +'</p>	'
_cHTML+='          <p class="tit" style="font-size: 12pt">Hora : '+ _cHora + '</p>	'
_cHTML+='        </td>	'
_cHTML+='      </tr>	'
_cHTML+='      <tr>	'
_cHTML+='        <td colspan="3">	'
_cHTML+='          <p>&nbsp;</p>	'
_cHTML+='        </td>	'
_cHTML+='      </tr>	'

// buscar funcao de dados
_cHTML+=fDadosGiro48h()

_cHTML+='      <tr>	'
_cHTML+='        <td colspan="3" style="text-align: center; margin: 0; padding: 0px 8px">	'
_cHTML+='              <hr />	'
_cHTML+='              <p>	'
_cHTML+='                Aviso / Sistema : Este documento é para uso interno, utilizado	'
_cHTML+='                para comunicações e avisos.	'
_cHTML+='              </p>	'
_cHTML+='        </td>	'
_cHTML+='      </tr>	'
_cHTML+='    </table>	'
_cHTML+='  </body>	'
_cHTML+='</html>	'



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

Static Function sfMontarCabecalho(cEndereco)
Local _cHTMLAux1:=''
//montar cabeçalho
     _cHTMLAux1+='      <tr">	'
     _cHTMLAux1+='        <td colspan="5">	'
     _cHTMLAux1+='          <p style="padding-left: 5px; color: red;  font-size: 10pt"> ARMZ.PROCESO (20) / '+ cEndereco + '  </p>	'
     _cHTMLAux1+='        </td>	'
     _cHTMLAux1+='      </tr>	'
     _cHTMLAux1+='      <tr>	'
     _cHTMLAux1+='        <td colspan="3">	'
     _cHTMLAux1+='          <table	'
     _cHTMLAux1+='            width="100%"	'
     _cHTMLAux1+='            align="left"	'
     _cHTMLAux1+='            cellpadding="0"	'
     _cHTMLAux1+='            cellspacing="0"	'
     _cHTMLAux1+='            border="1"	'
     _cHTMLAux1+='            bordercolor="#3f87a6"	'
     _cHTMLAux1+='            bordercolorlight="#3f87a6"	'
     _cHTMLAux1+='            bordercolordark="#3f87a6"	'
     _cHTMLAux1+='            style="	'
     _cHTMLAux1+='              border-collapse: collapse;	'
     _cHTMLAux1+='              border-left: 1px solid #3f87a6;	'
     _cHTMLAux1+='              border-right: 1px solid #3f87a6;	'
     _cHTMLAux1+='              border-top: 1px solid #3f87a6;	'
     _cHTMLAux1+='              border-bottom: 1px solid #3f87a6;	'
     _cHTMLAux1+='              border-color: #3f87a6;	'
     _cHTMLAux1+='            "	'
     _cHTMLAux1+='          >	'
     _cHTMLAux1+='            <thead>	'
     _cHTMLAux1+='              <tr>	'
     _cHTMLAux1+='                <th scope="col">#</th>	'
     _cHTMLAux1+='                <th scope="col">Código</th>	'
     _cHTMLAux1+='                <th scope="col">Tipo</th>	'
     _cHTMLAux1+='                <th scope="col">Descrição Produto</th>	'
     _cHTMLAux1+='                <th scope="col">Saldo</th>	'
     _cHTMLAux1+='                <th scope="col">Slow Time</th>	'
     _cHTMLAux1+='                <th scope="col">Total R$</th>	'
     _cHTMLAux1+='              </tr>	'
     _cHTMLAux1+='            </thead>	'
     _cHTMLAux1+='            <tbody>	'



Return _cHTMLAux1


Static Function sfMontarRodape(cEndereco,nSaldo,nCusFin)
Local _cHTMLAux1:=''

_cHTMLAux1+='              <tr style="background-color: lightblue">	'
_cHTMLAux1+='                <td scope="row" colspan="3" style="text-align: left">	'
_cHTMLAux1+='                 '+cEndereco
_cHTMLAux1+='                </td>	'
_cHTMLAux1+='                <td scope="row" style="text-align: right">Totais = ></td>	'
_cHTMLAux1+='                <td scope="row" style="font-weight: bold">'+ Transform((nSaldo), "@E 99,999,999,999.99") +'</td>	'
_cHTMLAux1+='                <td scope="row"></td>	'
_cHTMLAux1+='                <td scope="row" style="font-weight: bold"> R$ '+ Transform((nCusFin), "@E 99,999,999,999.99") +'</td>	'
_cHTMLAux1+='              </tr>	'
_cHTMLAux1+='            </tbody>	'
_cHTMLAux1+='          </table>	'
_cHTMLAux1+='        </td>	'
_cHTMLAux1+='      </tr>	'
_cHTMLAux1+='      <tr>	'
//_cHTMLAux1+='        <td colspan="7">	'
_cHTMLAux1+='          <p>&nbsp;</p>	'
_cHTMLAux1+='          <p>&nbsp;</p>	'
//_cHTMLAux1+='        </td>	'
_cHTMLAux1+='      </tr>	'

Return _cHTMLAux1
