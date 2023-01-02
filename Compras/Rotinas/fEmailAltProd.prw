#include "rwmake.ch"
#include "topconn.ch"    
#include "ap5mail.ch"
#Include "Protheus.ch"

// ------------------------------------------------------------------------------------------
// Ricky Moraes - 21/10/2020
// Enviar email quando alguem alterar o cadastro de produto
// ------------------------------------------------------------------------------------------

******************************************************************************************************************************************************************
User Function  fEmailAltProd(aAltProd,cCodigo)
******************************************************************************************************************************************************************
Local aArea := ZT3->(GetArea())

Local _cSerMail := GetMV("MV_RELSERV")  
Local _cDe       := GetMV("MV_EMCONTA") 
Local _cSenha    := GetMV("MV_EMSENHA")
Local lSmtpAuth := .T. // se o seu servidor requer autenticação 
Local _cRemet  := GetMV("MV_EMCONTA") 

//Local _cUserConta:= cResp //UsrRetMail(RetCodUsr())
Local cEmailR    :=GetMV("MV_EALTPRO")  
Local cEmailS    := UsrRetMail(RetCodUsr())+";"
Local _cDest     := cEmailS + cEmailR 
Local _cHTML     := "" 
Local _cAssunto := "Alteração de Cadastro - " + cCodigo
Local _cHoraAtu:=time()
Local  _LENVIADO :=.F.
Local _cDATA :=DTOC(DATE())
Local _cCod := cCodigo
Local _cDesc :=Posicione("SB1",1,xFilial("SB1")+cCodigo,"B1_DESC")
Local _cNome :=cUserName  

_cHTML:='		<!DOCTYPE html>													'
_cHTML+='		<html>														'
_cHTML+='																'
_cHTML+='		<head>														'
_cHTML+='		    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">					'
_cHTML+='		    <title>CADASTRO</title>											'
_cHTML+='		    <style>													'
_cHTML+='			body {													'
_cHTML+='			    font-family: Arial, Verdana, Tahoma, Sans-Serif;							'
_cHTML+='			    font-size: 12px;											'
_cHTML+='			}													'
_cHTML+='																'
_cHTML+='			.page {													'
_cHTML+='			    width: 500px;											'
_cHTML+='			    margin: auto;											'
_cHTML+='			}													'
_cHTML+='																'
_cHTML+='			#demo-table {												'
_cHTML+='			    border-collapse: collapse;										'
_cHTML+='			    width: 100%;											'
_cHTML+='			}													'
_cHTML+='																'
_cHTML+='			#pg-table {												'
_cHTML+='			    border-collapse: collapse;										'
_cHTML+='			    width: 100%;											'
_cHTML+='			    margin-bottom: 1rem;										'
_cHTML+='			    padding: 5px;											'
_cHTML+='																'
_cHTML+='			}													'
_cHTML+='			#pg-table td {												'
_cHTML+='			    padding: 5px;											'
_cHTML+='			    text-align: left;											'
_cHTML+='																'
_cHTML+='			}													'
_cHTML+='			/* basic shared rules */										'
_cHTML+='			#demo-table th,												'
_cHTML+='			#demo-table td {											'
_cHTML+='			    padding: 5px;											'
_cHTML+='			    text-align: left;											'
_cHTML+='																'
_cHTML+='			}													'
_cHTML+='																'
_cHTML+='																'
_cHTML+='			#demo-table td.direita {										'
_cHTML+='			    padding: 0.25rem;											'
_cHTML+='			    text-align: right;											'
_cHTML+='																'
_cHTML+='			}													'
_cHTML+='																'
_cHTML+='			#demo-table td.centro {											'
_cHTML+='			    padding: 0.25rem;											'
_cHTML+='			    text-align: center;											'
_cHTML+='																'
_cHTML+='			}													'
_cHTML+='																'
_cHTML+='			#demo-table th {											'
_cHTML+='			    font-weight: bold;											'
_cHTML+='			    padding-left: .5em;											'
_cHTML+='																'
_cHTML+='			}													'
_cHTML+='																'
_cHTML+='																'
_cHTML+='			/* header */												'
_cHTML+='			#demo-table thead {											'
_cHTML+='			    text-align: center;											'
_cHTML+='			    color: white;											'
_cHTML+='			    background-color: black;										'
_cHTML+='			    font-size: 10pt;											'
_cHTML+='																'
_cHTML+='			}													'
_cHTML+='																'
_cHTML+='																'
_cHTML+='			/* fix size of superscript */										'
_cHTML+='			#demo-table sup {											'
_cHTML+='			    font-size: 55%;											'
_cHTML+='																'
_cHTML+='																'
_cHTML+='			}													'
_cHTML+='																'
_cHTML+='			/* body */												'
_cHTML+='			#demo-table td {											'
_cHTML+='			    padding: 0.25rem;											'
_cHTML+='			    text-align: left;											'
_cHTML+='			    border: 1px solid #696969;										'
_cHTML+='			    font-size: 7pt;											'
_cHTML+='			    border-style: solid;										'
_cHTML+='			    border-width: thin;											'
_cHTML+='																'
_cHTML+='			}													'
_cHTML+='																'
_cHTML+='			/* table */												'
_cHTML+='			table {													'
_cHTML+='			    width: 100%;											'
_cHTML+='																'
_cHTML+='			}													'
_cHTML+='																'
_cHTML+='			p {													'
_cHTML+='			    margin: 1;												'
_cHTML+='			    font-size: 15px;											'
_cHTML+='			}													'
_cHTML+='		    </style>													'
_cHTML+='																'
_cHTML+='		</head>														'
_cHTML+='																'
_cHTML+='		<body>														'
_cHTML+='		    <div class="page">												'
_cHTML+='			<table id="pg-table">											'
_cHTML+='			    <tbody>												'
_cHTML+='				<!-- Top Page -->										'
_cHTML+='				<tr>												'
_cHTML+='				    <hr>											'
_cHTML+='				</tr>												'
_cHTML+='				<tr>												'
_cHTML+='				    <table id="pg-table">									'
_cHTML+='																'
_cHTML+='					<tr>											'
_cHTML+='																'
_cHTML+='					    <td width="25%" style="text-align: center;">					'
_cHTML+='						<img src="https://gamaitaly.vteximg.com.br/arquivos/logo.png" alt="Gama">	'
_cHTML+='					    </td>										'
_cHTML+='					    <td>										'
_cHTML+='																'
_cHTML+='					    </td>										'
_cHTML+='					    <td style="text-align: center;">							'
_cHTML+='						<b>										'
_cHTML+='						    <p>AVISO - ALTERAÇÃO</p>							'
_cHTML+='						    <p>CADASTRO DE PRODUTOS</p>							'
_cHTML+='						</b>										'
_cHTML+='					    </td>										'
_cHTML+='					    <td width="25%">									'
_cHTML+='						<table>										'
_cHTML+='						    <tr>									'
_cHTML+='							<td style="text-align: right;">Emissão : </td>				'
_cHTML+='							<td>'+ _cData +'							'
_cHTML+='							</td>									'
_cHTML+='						    </tr>									'
_cHTML+='						    <tr>									'
_cHTML+='							<td style="text-align: right;">Hora : </td>				'
_cHTML+='							<td>'+_cHoraAtu+'</td>							'
_cHTML+='						    </tr>									'
_cHTML+='						</table>									'
_cHTML+='					    </td>										'
_cHTML+='																'
_cHTML+='					</tr>											'
_cHTML+='				    </table>											'
_cHTML+='				    <hr>											'
_cHTML+='				</tr>												'
_cHTML+='				<tr>												'
_cHTML+='																'
_cHTML+='				    <!-- Cabeçalho -->										'
_cHTML+='				    <table id="pg-table">									'
_cHTML+='					<tbody>											'
_cHTML+='					    <tr>										'
_cHTML+='						<td style="font-size: 15px;"><b>'+_cCod +' - '+ _cDesc+'</b> </td>							'
_cHTML+='					    </tr>										'
_cHTML+='					    <tr>										'
_cHTML+='						<td>Usuário - <b>'+_cNome+'</b> </td>							'
_cHTML+='					    </tr>										'
_cHTML+='					</tbody>										'
_cHTML+='				    </table>											'
_cHTML+='																'
_cHTML+='				</tr>												'
_cHTML+='				<!-- Itens -->											'
_cHTML+='				<tr>												'
_cHTML+='				    <hr>											'
_cHTML+='				</tr>												'
_cHTML+='				<tr>												'
_cHTML+='				    <td> <strong>Campos alterados</strong>							'
_cHTML+='				    </td>											'
_cHTML+='				</tr>												'
_cHTML+='				<tr>												'
_cHTML+='				    <table id="demo-table">									'
_cHTML+='					<thead>											'
_cHTML+='					    <tr>										'
_cHTML+='						<th>No. </th>									'
_cHTML+='						<th>Campo</th>									'
_cHTML+='						<th>Titulo</th>									'
_cHTML+='						<th>Antes</th>								'
_cHTML+='						<th>Depois</th>								'
_cHTML+='					    </tr>										'
_cHTML+='					</thead>										'
_cHTML+='					<tbody>											'
_cHTML+='					    <!-- carga itens -->								'
_cHTML +=fCampAltSB1(aAltProd)
_cHTML+='																'
_cHTML+='					</tbody>										'
_cHTML+='																'
_cHTML+='				    </table>											'
_cHTML+='				</tr>												'
_cHTML+='				<!-- Rodape -->											'
_cHTML+='				<tr>												'
_cHTML+='				    <td style="text-align: center;">								'
_cHTML+='					Aviso / Sistema : Este documento é para uso interno,					'
_cHTML+='					utilizado para comunicação e avisos internos,						'
_cHTML+='					não deve ser usado como documentação técnica.						'
_cHTML+='				    </td>											'
_cHTML+='				</tr>												'
_cHTML+='																'
_cHTML+='			    </tbody>												'
_cHTML+='			</table>												'
_cHTML+='		    </div>													'
_cHTML+='		</body>														'
_cHTML+='																'
_cHTML+='		</html>														'
_cHTML+=' '


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

 
  RestArea(aArea)
Return (_lEnviado)


// FUNÇÃO: RETORNA OS ITENS EM HTML
STATIC Function fCampAltSB1(aAltProd) // RECEBE O NÚMERO REGISTRO
    Local cItens :=""               // Retornaos Itens em TXT/HTML
    Local x :=0
for x:=1 to len(aAltProd)


//No.1
//Campo2
//Titulo3	
//Anterior4
//Atualizado5

        cItens+='<tr>'								
        cItens+='<td>' 
        cItens+=STRZERO(x, 3, 0)							
        cItens+='</td>'

        cItens+='<td>'								
        cItens+=cValToChar(aAltProd[x][1])							
        cItens+='</td>'								

        cItens+='<td >'						
        cItens+=(aAltProd[x][2])							
        cItens+='</td>'	

        cItens+='<td>'						
        cItens+=(aAltProd[x][3])
        cItens+='</td>'								

        cItens+='<td>'								
        cItens+= (aAltProd[x][4])
        cItens+='</td>'								
			       						
        cItens+='</tr>'		

    next    
Return (cItens) 
*/// RETORNA O VALOR PARA A COLUNA
