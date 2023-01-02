#include "rwmake.ch"
#include "topconn.ch"    
#include "ap5mail.ch"
#Include "Protheus.ch"

// ------------------------------------------------------------------------------------------
// Ricky Moraes - 01/04/20 - 09:00
// Enviar email quando Gerar SENF Eletronica
// ------------------------------------------------------------------------------------------

******************************************************************************************************************************************************************
User Function  fEmailSenf(cDoc,cStatus)
******************************************************************************************************************************************************************
Local aArea := ZT3->(GetArea())

Local _cSerMail := GetMV("MV_RELSERV")  
Local _cDe       := GetMV("MV_EMCONTA") 
Local _cSenha    := GetMV("MV_EMSENHA")
Local lSmtpAuth := .T. // se o seu servidor requer autenticação 
Local _cRemet  := GetMV("MV_EMCONTA") 
Local cPRO	:= Alltrim( SuperGetMV("MV_EMAIPRO", ," ") )
Local cSUP	:= Alltrim( SuperGetMV("MV_EMAISUP", ," ") )
Local cTI		:= Alltrim( SuperGetMV("MV_EMAITI", ," ") )
Local cENG	:= Alltrim( SuperGetMV("MV_EMAIENG", ," ") )
Local cMAN	:= Alltrim( SuperGetMV("MV_EMAIMAN", ," ") )
Local cRH		:= Alltrim( SuperGetMV("MV_EMAIRH", ," ") )
Local cCON	:= Alltrim( SuperGetMV("MV_EMAICON", ," ") )
Local cQUA	:= Alltrim( SuperGetMV("MV_EMAIQUA", ," ") )
Local cFIS	:= Alltrim( SuperGetMV("MV_EMAIFIS", ," ") )
Local cEXP	:= Alltrim( SuperGetMV("MV_EMAIEXP", ," ") )



//Local _cUserConta:= cResp //UsrRetMail(RetCodUsr())
Local cEmailR    := GetMV("MV_EMSENF") //"senf.am@gamaitaly.com.br;" +"ricky.moraes@gamaitaly.com.br;"
Local cEmailS    := ALLTRIM(ZT3->ZT3_EMAIL)+";" //UsrRetMail(RetCodUsr())+";"
Local _cDest     := cEmailS + cEmailR 
Local _cHTML     := "" 
Local _cAssunto := " SENF - ELETRONICA " + cDoc + ' ' +cStatus
Local _cHoraAtu:=time()
Local  _LENVIADO :=.F.

Local _cTIPO,_cTPSENF,_cNUM,_cCODCF,_cLOJA,_cSOL,_cSETOR
Local _cTES,_cCONDPA,_cEMAIL,_cOBS,_cSTATUS,_cNOME,_cEND,_cPLIQUI
Local _cPBRUTO,_cVOLUME,_cESPECI
Local _cDATA, _cNPed,_cDataPed, _cUsPed
Local _cNomeTrans,_cModalTrans
Local _cNatOP,_cCFOP, _cAliICM,_cAliIPI
Local _cMovEst
Private _nTotGeral
Private _cTotGeral
    

//PEGAR OS CAMPOS DO CABECALHO ZT3
    _cNomeTrans:=" "
    _cModalTrans:=" "

    _cNatOP :=" "
    _cCFOP :=" " 
    _cAliICM :=" "
    _cAliIPI:=" "
    
     _cRespFisc:=" "    
     _cDataResp:=" "
     
    _cNPed:=" " 
    _cDataPed:=" "
    _cUsPed:=" " 
    _cMovEst:=" "
    
    _nTotGeral:=0
    _cTotGeral:=" "




dbSelectArea('ZT3')
dbSetOrder(1)
IF DBSeek(xFilial("ZT3")+cDoc)

     IF !EMPTY(ZT3->ZT3_TRANSP)
          _cNomeTrans:= ZT3->ZT3_TRANSP +' - '+  POSICIONE("SA4",1,xFilial("SA4")+ZT3->ZT3_TRANSP,"A4_NREDUZ") 
     ENDIF

     IF !EMPTY(ZT3->ZT3_TES)
         SF4->(dbSetOrder(1))
         SF4->(dbSeek(xFilial("SF4")+ZT3->ZT3_TES))
         _cNatOP:= SF4->F4_TEXTO
         _cCFOP:= SF4->F4_CF
         _cRespFisc:=UsrRetName(RETCODUSR())    
         _cDataResp:=DTOC(DATE())
     ENDIF          
       

    _cTIPO:=     IIF(ZT3->ZT3_TIPO=='N','CLIENTE','FORNECEDOR')
    _cTPSENF := ZT3->ZT3_TPSENF
    _cNUM:=	    ZT3->ZT3_NUM
    _cDATA:=    DTOC(ZT3->ZT3_DATA) 
    
    _cCODCF:=  _cTIPO + ' '+ZT3->ZT3_CODCF
    _cLOJA:=	ZT3->ZT3_LOJA
    _cSOL:=	    ZT3->ZT3_SOL
    _cSETOR:=   ZT3->ZT3_SETOR
    _cTES:=	    ZT3->ZT3_TES
    _cCONDPA:=  ZT3->ZT3_CONDPA
    _cEMAIL:=   ZT3->ZT3_EMAIL
    _cOBS:=	    ZT3->ZT3_OBS
    _cSTATUS:=  sfStatusSenf(ZT3->ZT3_STATUS)
    _cNOME:=	ZT3->ZT3_NOME
    _cEND:=	ZT3->ZT3_END
    _cPLIQUI:=  Transform((ZT3->ZT3_PLIQUI), "@E 99,999.99")
    _cPBRUTO:=  Transform((ZT3->ZT3_PBRUTO), "@E 99,999.99")
    _cVOLUME:=  Transform((ZT3->ZT3_VOLUME), "@E 99,999.99")
    _cTotGeral:= Transform((_nTotGeral), "@E 99,999,999,999.99")

    _cESPECI:=  ZT3->ZT3_ESPECI
    _cNPed:= ZT3->ZT3_PEDIDO
    _cDataPed:=IIF(!EMPTY(ZT3->ZT3_PEDIDO),DTOC(DATE())," ")
    _cUsPed:=IIF(!EMPTY(ZT3->ZT3_PEDIDO),UsrRetName(RETCODUSR())," ")
    _cMovEst:=IIF(ZT3->ZT3_MOVEST=="S","Mov. Estoque: SIM","Mov. Estoque: NAO")


                                                     
Endif  


DO CASE
CASE ZT3->ZT3_STATUS == "1"
     _cDest +=cEXP
CASE ZT3->ZT3_STATUS == "2"
     _cDest +=cEXP
CASE ZT3->ZT3_STATUS == "3"
     _cDest +=cFIS
CASE ZT3->ZT3_STATUS == "4"
     _cDest +=cFIS
CASE ZT3->ZT3_STATUS == "5"
     _cDest +=cFIS
ENDCASE
_cSETOR:=ALLTRIM(_cSETOR)
DO CASE
  CASE   _cSETOR=='Producao'
     _cDest +=cPRO
  CASE   _cSETOR==ALLTRIM('Supply Chain')
     _cDest +=cSUP
  CASE   _cSETOR=='Engenharia'
     _cDest +=cENG
  CASE   _cSETOR=='Manutencao'
     _cDest +=cMAN
  CASE   _cSETOR=='Qualidade'
     _cDest +=cQUA
  CASE   _cSETOR=='Controladoria'
     _cDest +=cCON
  CASE   _cSETOR=='TI'
     _cDest +=cTI
  CASE   _cSETOR=="RH"
     _cDest +=cRH
ENDCASE


 

_cHTML:='<!DOCTYPE html>																				'
_cHTML+='<html>																				'
_cHTML+='																				'
_cHTML+='<head>																				'
_cHTML+='    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">																				'
_cHTML+='    <title>SENF-ELETRONICA</title>																				'
_cHTML+='    <style>																				'
_cHTML+='        .page {																				'
_cHTML+='            width: 19cm;																				'
_cHTML+='            min-height: 29.7cm;																				'
_cHTML+='            padding: 1cm;																				'
_cHTML+='            margin: 1cm auto;																				'
_cHTML+='            font-size: 11pt;																				'
_cHTML+='            /*  border: 1px #D3D3D3 solid; */																				'
_cHTML+='            /*  border-radius: 5px; */																				'
_cHTML+='            /*  background: white; */																				'
_cHTML+='            /*  box-shadow: 0 0 5px rgba(0, 0, 0, 0.1); */																				'
_cHTML+='        }																				'
_cHTML+='																				'
_cHTML+='        @page {																				'
_cHTML+='            size: A4;																				'
_cHTML+='            margin: 0;																				'
_cHTML+='        }																				'
_cHTML+='																				'
_cHTML+='        @media print {																				'
_cHTML+='            .page {																				'
_cHTML+='                margin: 0;																				'
_cHTML+='                border: initial;																				'
_cHTML+='                border-radius: initial;																				'
_cHTML+='                width: initial;																				'
_cHTML+='                min-height: initial;																				'
_cHTML+='                box-shadow: initial;																				'
_cHTML+='                background: initial;																				'
_cHTML+='                page-break-after: always;																				'
_cHTML+='                																				'
_cHTML+='            }																				'
_cHTML+='        }																				'
_cHTML+='																				'
_cHTML+='        h1 {																				'
_cHTML+='            font-size: 24pt;																				'
_cHTML+='            text-align: center;																				'
_cHTML+='        }																				'
_cHTML+='																				'
_cHTML+='        h2 {																				'
_cHTML+='            font-size: 18pt;																				'
_cHTML+='            text-align: center;																				'
_cHTML+='        }																				'
_cHTML+='																				'
_cHTML+='        h3 {																				'
_cHTML+='            font-size: 14pt;																				'
_cHTML+='            text-align: center;																				'
_cHTML+='        }																				'
_cHTML+='																				'
_cHTML+='        #demo-table {																				'
_cHTML+='            border-collapse: collapse;																				'
_cHTML+='            width: 100%;																				'
_cHTML+='        }																				'
_cHTML+='        #pg-table {																				'
//_cHTML+='            border-collapse: collapse;																				'
_cHTML+='            width: 100%;																				'
_cHTML+='        }																				'
_cHTML+='																				'
_cHTML+='        /* basic shared rules */																				'
_cHTML+='        #demo-table th,																				'
_cHTML+='        #demo-table td {																				'
_cHTML+='            padding: 0.25rem;																				'
_cHTML+='            text-align: left;																				'
_cHTML+='																				'
_cHTML+='        }																				'
_cHTML+='																				'
_cHTML+='        #demo-table td.direita {																				'
_cHTML+='            padding: 0.25rem;																				'
_cHTML+='            text-align: right;																				'
_cHTML+='																				'
_cHTML+='        }																				'
_cHTML+='																				'
_cHTML+='        #demo-table td.centro {																				'
_cHTML+='            padding: 0.25rem;																				'
_cHTML+='            text-align: center;																				'
_cHTML+='																				'
_cHTML+='        }																				'
_cHTML+='																				'
_cHTML+='        #demo-table th {																				'
_cHTML+='            font-weight: bold;																				'
_cHTML+='            padding-left: .5em;																				'
_cHTML+='        }																				'
_cHTML+='																				'
_cHTML+='																				'
_cHTML+='        /* header */																				'
_cHTML+='        #demo-table thead {																				'
_cHTML+='            text-align: center;																				'
_cHTML+='            color: white;																				'
_cHTML+='            background-color: black;																				'
_cHTML+='            font-size: 10pt;																				'
_cHTML+='        }																				'
_cHTML+='																				'
_cHTML+='																				'
_cHTML+='        /* fix size of superscript */																				'
_cHTML+='        #demo-table sup {																				'
_cHTML+='            font-size: 55%;																				'
_cHTML+='        }																				'
_cHTML+='																				'
_cHTML+='        /* body */																				'
_cHTML+='        #demo-table td {																				'
_cHTML+='            padding: 0.25rem;																				'
_cHTML+='            text-align: left;																				'
_cHTML+='            border: 1px solid #696969; 																				'
_cHTML+='            font-size: 7pt;																				'
//_cHTML+='            border-style: solid;																				'
_cHTML+='            border-width: thin;																				'
_cHTML+='        }																				'
_cHTML+='    </style>																				'
_cHTML+='																				'
_cHTML+='</head>																				'
_cHTML+='																				'
_cHTML+='<body>																				'
_cHTML+='    <div class="page">																				'
_cHTML+='        <table id="pg-table" >																				'
_cHTML+='            <tbody>																				'
_cHTML+='                <!-- Top Page -->																				'
_cHTML+='                <tr>																				'
_cHTML+='                    <hr>																				'
_cHTML+='                </tr>																				'
_cHTML+='                <tr>																				'
_cHTML+='                    <table id="pg-table">																				'
_cHTML+='                        																				'
_cHTML+='                        <tr>																				'
_cHTML+='                          																				'
_cHTML+='                            <td width="25%" style="text-align: center;">																				'
_cHTML+='                                <img src="https://gamaitaly.vteximg.com.br/arquivos/logo.png" alt="Gama">																				'
_cHTML+='                            </td>																				'
_cHTML+='                            <td>																				'
_cHTML+='                                <h2>SENF-ELETRÔNICA</h2>																				'
_cHTML+='                                <h3>SOLICITAÇÃO DE EMISSÃO NOTA FISCAL</h3>																				'
_cHTML+='                            </td>																				'
_cHTML+='                            <td width="25%">																				'
_cHTML+='                                <table>																				'
_cHTML+='                                    <tr>																				'
_cHTML+='                                        <td style="text-align: right;">Status :</td>																				'
_cHTML+='                                        <td style="text-align: center;" bgcolor="#F7CF46">																				'
_cHTML+='                                            <font color="#000000"><strong>'+_cStatus+'</strong></font>																				'
_cHTML+='                                        </td>																				'
_cHTML+='                                    </tr>																				'
_cHTML+='                                    <tr>																				'
_cHTML+='                                        <td style="text-align: right;">Emissão </td>																				'
_cHTML+='                                        <td>'+ _cData +'																				'
_cHTML+='                                        </td>																				'
_cHTML+='                                    </tr>																				'
_cHTML+='                                    <tr>																				'
_cHTML+='                                        <td style="text-align: right;">Hora </td>																				'
_cHTML+='                                        <td>'+_cHoraAtu+'</td>																				'
_cHTML+='                                    </tr>																				'
_cHTML+='																				'
_cHTML+='                                </table>																				'
_cHTML+='																				'
_cHTML+='                        </tr>																				'
_cHTML+='                    </table>																				'
_cHTML+='                </tr>																				'
_cHTML+='                <tr>																				'
_cHTML+='																				'
_cHTML+='                    <!-- Cabeçalho -->																				'
_cHTML+='                    <table id="demo-table">																				'
_cHTML+='                        <tbody>																				'
_cHTML+='                            <tr>																				'
_cHTML+='                                <td width="25px" >Num.Senf  </td>																				'
_cHTML+='                                <td><b>'+_cNum+'</b> </td>																				'
_cHTML+='                                <td colspan="2"> Setor : <b>'+_cSetor+'</b></td>																				'
_cHTML+='                                <td colspan="2">Tp. Senf : <b>'+_cTPSENF+' </b></td>																				'
_cHTML+='                            </tr>																				'
_cHTML+='                            <tr>																				'
_cHTML+='                                <td  width="25px">Solicitante </td>																				'
_cHTML+='                                <td colspan="3">'+ _cSol + ' </td>'
_cHTML+='                                <td colspan="2">'+ _cMovEst +' </td>'																				'
_cHTML+='                            </tr>																				'
_cHTML+='                            <tr>																				'
_cHTML+='                                <td  width="25px" >Destinatário </td>																				'
_cHTML+='                                <td colspan="5">'+ _cCODCF +'/'+ _cLOJA +' - '+_cNOME +'</td>																				'
_cHTML+='                            </tr>																				'
_cHTML+='                            <tr>																				'
_cHTML+='                                <td  width="25px">Endereco </td>																				'
_cHTML+='                                <td colspan="5">'+ _CEND+' </td>																				'
_cHTML+='																				'
_cHTML+='                            </tr>																				'
_cHTML+='                            <tr>																				'
_cHTML+='                                <td  width="25px" >Obsevações </td>																				'
_cHTML+='                                <td colspan="5">'+ _cOBS+'</td>																				'
_cHTML+='                            </tr>																				'
_cHTML+='                        </tbody>																				'
_cHTML+='                    </table>																				'
_cHTML+='																				'
_cHTML+='                </tr>																				'
_cHTML+='                <!-- Itens -->																				'
_cHTML+='                <tr>																				'
_cHTML+='                    <hr>																				'
_cHTML+='                </tr>																				'
_cHTML+='                <tr>																				'
_cHTML+='                    <td> <strong>Lista de itens</strong>																				'
_cHTML+='                    </td>																				'
_cHTML+='                </tr>																				'
_cHTML+='                <tr>																				'
_cHTML+='                    <table id="demo-table">																				'
_cHTML+='                        <thead>																				'
_cHTML+='                            <tr>																				'
_cHTML+='                                <th>No. </th>																				'
_cHTML+='                                <th>Codigo</th>																				'
_cHTML+='                                <th>Tipo</th>																				'
_cHTML+='                                <th>Und.</th>																				'
_cHTML+='                                <th>Descrição</th>																				'
_cHTML+='                                <th>Quant.Sol.</th>																				'
_cHTML+='                                <th>Quant.Atend.</th>																				'
_cHTML+='                                <th>Valor R$</th>																				'
_cHTML+='                            </tr>																				'
_cHTML+='                        </thead>																				'
_cHTML+='                        <tbody>																				'

//carregar os itens
_cHTML+= RetItencSenf(_cNum)

_cHTML+='                        </tbody>																				'
_cHTML+='																				'
_cHTML+='        </table>																				'
_cHTML+='        </tr>																				'
_cHTML+='        <!-- carga -->																				'
_cHTML+='        <tr>																				'
_cHTML+='            <hr>																				'
_cHTML+='        <tr>																				'
_cHTML+='            <td><strong>Características da carga</strong></td>																				'
_cHTML+='        </tr>																				'
_cHTML+='        <tr>																				'
_cHTML+='            <td>																				'
_cHTML+='                <table width="100%" id="demo-table">																				'
_cHTML+='                    <thead>																				'
_cHTML+='                        <tr>																				'
_cHTML+='                            <th>Peso bruto</th>																				'
_cHTML+='                            <th>Peso líquido</th>																				'
_cHTML+='                            <th>Volumes</th>																				'
_cHTML+='                            <th>Espécie</th>																				'
_cHTML+='                            <th>Total R$</th>																				'
_cHTML+='                        </tr>																				'
_cHTML+='                    </thead>																				'
_cHTML+='                    <tr>																				'
_cHTML+='                        <td>'+_cPBRUTO+'</td>																				'
_cHTML+='                        <td>'+_cPLIQUI+'</td>																				'
_cHTML+='                        <td>'+_cVOLUME+'</td>																				'
_cHTML+='                        <td>'+_cESPECI+'</td>																				'
_cHTML+='                        <td>'+_cTotGeral+'</td>																				'
_cHTML+='                    </tr>																				'
_cHTML+='                </table>																				'
_cHTML+='            </td>																				'
_cHTML+='        </tr>																				'
_cHTML+='																				'
_cHTML+='        </tr>																				'

IF VAL(ZT3->ZT3_STATUS)>1
    _cHTML+='        <!-- Transporte -->																				'
    _cHTML+='        <tr>																				'
    _cHTML+='            <hr>																				'
    _cHTML+='            <table id="demo-table">																				'
    _cHTML+='                <thead>																				'
    _cHTML+='                    <tr>																				'
    _cHTML+='                        <th align="left">Nome Transportador</th>																				'
    _cHTML+='                        <th align="left">Modal de Transporte</th>																				'
    _cHTML+='                    </tr>																				'
    _cHTML+='                </thead>																				'
    _cHTML+='                <tr>																				'
    _cHTML+='                    <td align="left">'+ _cNomeTrans +'</td>																				'
    _cHTML+='                    <td align="left">'+ _cModalTrans +'</td>																				'
    _cHTML+='                </tr>																				'
    _cHTML+='            </table>																				'
    _cHTML+='        </tr>																				'
ENDIF   
   IF VAL(ZT3->ZT3_STATUS)>3
   
    _cHTML+='        <!-- Fiscal -->																				'
    _cHTML+='        <tr>																				'
    _cHTML+='            <hr>																				'
    _cHTML+='        <tr>																				'
    _cHTML+='            <td><strong>Para uso exclusivo do setor fiscal</strong></td>																				'
    _cHTML+='        </tr>																				'
    _cHTML+='        <tr>																				'
    _cHTML+='            <td>																				'
    _cHTML+='                <table id="demo-table">																				'
    _cHTML+='                    <thead>																				'
    _cHTML+='                        <tr>																				'
    _cHTML+='                            <th align="left">Natureza da operação</th>																				'
    _cHTML+='                            <th>CFOP</th>																				'
    _cHTML+='                            <th>Aliq. ICMS</th>																				'
    _cHTML+='                            <th>Aliq. IPI </th>																				'
    _cHTML+='                        </tr>																				'
    _cHTML+='                    </thead>																				'
    _cHTML+='                    <tr>																				'
    _cHTML+='                        <td width="50%">'+ _cNatOP +'</td>																				'
    _cHTML+='																				'
    _cHTML+='                        <td align="center">'+ _cCFOP +'</td>																				'
    _cHTML+='                        <td align="center">'+ _cAliICM +'</td>																				'
    _cHTML+='                        <td align="center">'+ _cAliIPI +'</td>																				'
    _cHTML+='                    </tr>																				'
    _cHTML+='																				'
    _cHTML+='                </table>																				'
    _cHTML+='            </td>																				'
    _cHTML+='        </tr>																				'
    _cHTML+='        <p> </p>																				'
    _cHTML+='        <tr>																				'
    _cHTML+='            <td>																				'
    _cHTML+='                <table id="demo-table">																				'
    _cHTML+='                    <p> </p>																				'
    _cHTML+='                    <thead>																				'
    _cHTML+='                        <tr>																				'
    _cHTML+='                            <th align="left">Responsável</th>																				'
    _cHTML+='                            <th>Data</th>																				'
    _cHTML+='                        </tr>																				'
    _cHTML+='                    </thead>																				'
    _cHTML+='                    <tr>																				'
    _cHTML+='                        <td width="70%">'+ _cRespFisc+ '</td>																				'
    _cHTML+='                        <td align="center">'+ _cDataResp + '</td>																				'
    _cHTML+='                    </tr>																				'
    _cHTML+='                </table>																				'
    _cHTML+='            </td>																				'
    _cHTML+='        </tr>																				'
    _cHTML+='        <!-- Faturamento -->																				'
    _cHTML+='        <tr>																				'
    _cHTML+='            <hr>																				'
    _cHTML+='        <tr>																				'
    _cHTML+='            <td><strong>Faturamento</strong>																				'
    _cHTML+='            </td>																				'
    _cHTML+='        </tr>																				'
    _cHTML+='        <tr>																				'
    _cHTML+='            <table id="demo-table">																				'
    _cHTML+='                <thead>																				'
    _cHTML+='                    <tr>																				'
    _cHTML+='                        <th>No.Pedido</th>																				'
    _cHTML+='                        <th>Emissão</th>																				'
    _cHTML+='                        <th>Responsável</th>																				'
    _cHTML+='																				'
    _cHTML+='                    </tr>																				'
    _cHTML+='                </thead>																				'
    _cHTML+='                <tr>																				'
    _cHTML+='                    <td>'+ _cNPed + '</td>																				'
    _cHTML+='                    <td>' + _cDataPed+'</td>																				'
    _cHTML+='                    <td>'+ _cUsPed +'</td>																				'
    _cHTML+='																				'
    _cHTML+='                </tr>																				'
    _cHTML+='            </table>																				'
    _cHTML+='        </tr>																				'
    _cHTML+='        <hr>																				'
    _cHTML+='        </tr>																				'
ENDIF

_cHTML+='        <!-- Rodape -->																				'
_cHTML+='        <tr>																				'
_cHTML+='            <td style="text-align: center;">																				'
_cHTML+='                Aviso / Sistema : Este documento é para uso interno,																				'
_cHTML+='                utilizado para geração/liberacao de documentos fiscais,																				'
_cHTML+='                portanto sem valor Fiscal.																				'
_cHTML+='            </td>																				'
_cHTML+='        </tr>																				'
_cHTML+='																				'
_cHTML+='        </tbody>																				'
_cHTML+='        </table>																				'
_cHTML+='    </div>																				'
_cHTML+='</body>																				'
_cHTML+='																				'
_cHTML+='</html>																				'
_cHTML+='																				'



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


******************************************************************************************************************************************************
STATIC Function sfStatusSenf(cStatus)
******************************************************************************************************************************************************
Local cTexto:=''

DO CASE
CASE cStatus == "1"
cTexto := "Solicitação"
CASE cStatus == "2"
cTexto:= "Setor Exp."
CASE cStatus == "3"
cTexto := "Setor Fiscal"
CASE cStatus == "4"
cTexto := "Faturado/Em Pedido"
CASE cStatus == "5"
cTexto := "*Cancelada*"
OTHERWISE
cTexto := "*Standby*"
ENDCASE

RETURN(cTexto)

// FUNÇÃO: RETORNA OS ITENS EM HTML
STATIC Function RetItencSenf(cNum) // RECEBE O NÚMERO REGISTRO
    Local cItens :=""               // Retornaos Itens em TXT/HTML
    Local aArea := ZT4->(GetArea()) // ARMAZENA A ÁREA PARA RESTAURAR APÓS OPERAÇÕES

    ZT4->(DbGoTop())                          // MOVE O CURSOR PARA O TOPO DA TABELA
    ZT4->(DbSetOrder(1))                      // ALTERA PARA O ÍNDICE 1: ZT2_FILIAL + ZT2_DOC + (...)
    ZT4->(MsSeek(FwXFilial("ZT4") + cNum )) // USA O NÚMERO  PARA PESQUISAR

    // ENTÃO O NÚMERO  NÚMERO CORRENTE NA
    // TABELA ZT2, ADICIONE O VALOR TOTAL DO ITEM A VARIAVEL NTOTAL
    While (ZT4->ZT4_NUMSF == cNum)
       
        cItens+='<tr>'								
        cItens+='<td class="centro">' 
        cItens+=ZT4->ZT4_ITEM 							
        cItens+='</td>'

        cItens+='<td>'								
        cItens+=ZT4->ZT4_COD							
        cItens+='</td>'								

        cItens+='<td class="centro">'						
        cItens+=POSICIONE("SB1",1,xFilial("SB1")+ZT4->ZT4_COD,"B1_TIPO")	
        cItens+='</td>'	

        cItens+='<td class="centro">'						
        cItens+=ZT4->ZT4_UM							
        cItens+='</td>'								

        cItens+='<td>'								
        cItens+=ZT4->ZT4_DESC							
        cItens+='</td>'								

        cItens+='<td>'								
        cItens+=Transform((ZT4-> ZT4_QTDSOL), "@E 99,999.99") 			
        cItens+='</td>'								

        cItens+='<td>'								
        cItens+=IIF(ZT4->ZT4_BLOCK=="S","BLOQUEADO",Transform((ZT4-> ZT4_QTDATE), "@E 99,999.99")) 			
        cItens+='</td>'	
        cItens+='<td>'								
        cItens+=Transform((ZT4->ZT4_VALOR), "@E 99,999,999,999.99") 				
        cItens+='</td>'	
        cItens+='</tr>'
        _nTotGeral:= _nTotGeral + ZT4->ZT4_VALOR

        ZT4->(DbSkip())
    End
     _cTotGeral:=Transform((_nTotGeral), "@E 99,999,999,999.99")
    // RESTAURA A ÁREA ORIGINAL (EVITA ERROS DE POSICIONAMENTO)
    RestArea(aArea)
Return (cItens) 
*/// RETORNA O VALOR PARA A COLUNA
