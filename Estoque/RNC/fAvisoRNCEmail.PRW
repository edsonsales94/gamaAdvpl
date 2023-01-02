#include "rwmake.ch"
#include "topconn.ch"    
#include "ap5mail.ch"
#Include "Protheus.ch"

// ------------------------------------------------------------------------------------------
// Ricky Moraes - 02/01/20 - 16:21
// Enviar email quando Gerar Documento RNC Pagamentos
// ------------------------------------------------------------------------------------------

******************************************************************************************************************************************************************
User Function  fAvisoRNC(cDoc,cData,cHora,cSolic,cEmailS,cResp,cEmailR,cStatus,cObs,cAprovador,cDataAprov,cNumOP,cTipoRNC )
******************************************************************************************************************************************************************
Local _cSerMail := GetMV("MV_RELSERV")  
Local _cDe       := GetMV("MV_EMCONTA") 
Local _cGestao       := GetMV("MV_EMAILRN") 
Local _cSenha    := GetMV("MV_EMSENHA")
Local lSmtpAuth := .T. // se o seu servidor requer autenticação 
Local _cRemet    := GetMV("MV_EMCONTA") 
//Local _cUserConta:= cResp //UsrRetMail(RetCodUsr())
Local _cDest     :=  _cGestao
Local _cHTML     := "" 
Local _cAssunto := cStatus + ' RNC - ' + iif(UPPER(cTipoRNC)='S','Solicitação','Devolução') + ' - ' + cDoc 
Local _cNomeAProv:=IIF(cAprovador!='',UsrRetName (cAprovador),'')
Local _cHoraAtu:=time()
Local cOp		:='' 
Local cCodigo	:=''  
Local cDesc   :='' 
Local cLinha :=''
/* procurar endereco da OP */

dbselectarea("SC2")               
DBSETORDER(1)
If (dbseek(xFilial("SC2")+LEFT(cNumOP,6), .T.)) 

	 cOp		:=SC2->C2_NUM+ SC2->C2_ITEM + SC2->C2_SEQUEN
	 cCodigo	:=SC2->C2_PRODUTO 
	 cDesc   := left(Posicione("SB1",1,XFILIAL("SB1")+SC2->C2_PRODUTO,"B1_XDESCNF"),40)
	 cLinha :=SC2->C2_XEND

endif

_cHTML:='<html>																																			   '
_cHTML+='<head>																																			   '
_cHTML+='<META http-equiv="Content-Type" content="text/html;charset=ISO-8859-1">				'		
_cHTML+='<title></title>																																   '
_cHTML+='<style type="text/css">																														   '
_cHTML+='table#alter td {background: #FFF;}																												   '
_cHTML+='table#alter tr.dif td {background: #EEE;}																										   '
_cHTML+='table#t01 tr:nth-child(even) {																													   '
_cHTML+='  background-color: #eee;																														   '
_cHTML+='}																																				   '
_cHTML+='table#t01 tr:nth-child(odd) {																													   '
_cHTML+='  background-color: #fff;																														   '
_cHTML+='}																																				   '
_cHTML+='table#t01 th {																																	   '
_cHTML+='  color: white;																																   '
_cHTML+='  background-color: black;} '
_cHTML+=' '

_cHTML+='	.TFtable{width:100%; border-collapse:collapse; 	}'
_cHTML+='	.TFtable td{ 	padding:7px; border: #262d37ff 1px solid;	}'
_cHTML+='	.TFtable tr{background: white;}

_cHTML+=' '
_cHTML+='</style>																																		   '
_cHTML+='</head>																																		   '
_cHTML+='<table width="89%"  border="1" >																												   '
_cHTML+='<tr>																																			   '
_cHTML+='<td width="100%" height="30" ><div  >																											   '
_cHTML+='	<hr/>																																		   '
_cHTML+='  <table width="100%" height="82" >																											   '
_cHTML+='<tr>																																			   '
_cHTML+='  <td width="305" height="76" align="center">																									   '
_cHTML+='  <h1 color=#ff0000>RNC-MATERIAIS</h1></td>																									   '
_cHTML+='  <td width="46" align="center">&nbsp;</td>																									   '
_cHTML+='  <td width="365" align="center"><h3>DOCUMENTO DE ' + if(UPPER(cTipoRNC)='S','SOLICITAÇÃO','DEVOLUÇÃO') + ' </h3></td>															   '
_cHTML+='  <td width="341"><table align="right" >																										   '
_cHTML+='    <tr>																																		   '
_cHTML+='        <td width="54" align="right">Status :</td>																								   '
DO CASE
CASE SUBSTR(cStatus,1,1)=='P'
_cHTML+=' <td width="79"  bgcolor="#F7CF46" align="center"><p><font color="#000000" size="+1"><strong>' + cStatus + '</strong></font></p></td>'
CASE SUBSTR(cStatus,1,1)=='A'
_cHTML+=' <td width="79"  bgcolor="#298A08" align="center"><p><font color="#000000" size="+1"><strong>' + cStatus + '</strong></font></p></td>'
CASE SUBSTR(cStatus,1,1)=='R'
_cHTML+=' <td width="79"  bgcolor="#FF0000" align="center"><p><font color="#000000" size="+1"><strong>' + cStatus + '</strong></font></p></td>'
Otherwise
_cHTML+=' <td width="79"  bgcolor="#C70F12" align="center"><p><font color="#FCF9F9" size="+1"><strong>' + cStatus + '</strong></font></p></td>'  											   
EndCase
_cHTML+='    </tr>																																		   '
_cHTML+='    <tr>																																		   '
_cHTML+='      <td align="right">Emissão :</td>																											   '
_cHTML+='      <td>'+cData+'</td>																															   '
_cHTML+='    </tr>																																		   '
_cHTML+='    <tr>																																		   '
_cHTML+='      <td align="right">Hora :</td>																											   '
_cHTML+='      <td>' +_cHoraAtu+'</td>																														   '
_cHTML+='    </tr>																																		   '
_cHTML+='  </table>																																		   '
_cHTML+='</table>																																		   '
_cHTML+='<hr/>																																			   '
_cHTML+='<table width="100%" border="0">																												   '
_cHTML+='  <tr>																																			   '
_cHTML+='  <td width="1%" rowspan="2"></td>																												   '
_cHTML+='</tr>																																			   '
_cHTML+='  <tr>																																			   '
_cHTML+='    <td><table width="100%"  align="left" cellspacing="2" id="alter" border="0" >													   '
//_cHTML+='  <td width="99%"><b>Num.Registro : <FONT color=#ff0000>' + cDoc +'</FONT></b></td>																   '
_cHTML+='	<td width="16px" ><b>N.Registro : </b></td>'
_cHTML+='	<td><b><FONT color=#ff0000>' + cDoc +'</FONT></b> </td>'
_cHTML+='   <td colspan="3" align="left">Endereço : ' + cLinha  + '</td>'

_cHTML+='      <tr class="dif">																															   '
_cHTML+='        <td width="100"  >Solicitante :</td>																									   '
_cHTML+='        <td colspan="3">' + cSolic + '</td>																									   '
_cHTML+='      </tr>																																	   '
//_cHTML+='      <tr >																																	   '
//_cHTML+='        <td >Responsável :</td>																												   '
//_cHTML+='        <td>' + cResp + '</td>																													   '
//_cHTML+='      </tr>																																	   '
_cHTML+='      <tr >																																	   '
_cHTML+='        <td >Num.OP:</td>																												   '
_cHTML+='        <td colspan="3" >' + SubStr(cNumOP,1,6) + '  -  ' + cCodigo +'  -  '  + cDesc + '</td>	 							   '
_cHTML+='      </tr>																																	   '
_cHTML+='      <tr class="dif">																																	   '
_cHTML+='        <td >Aprov/Repr.:</td>																												   '
_cHTML+='        <td >'+ _cNomeAProv + '</td>																													   '
_cHTML+='        <td colspan="3"> Dt.Baixa :' + cDataAprov + '</td>																													   '
_cHTML+='      </tr>																																	   '
_cHTML+='      <tr >																															   '
_cHTML+='        <td >Obsevações  :</td>																												   '
_cHTML+='        <td colspan="3">' + cObs +'</td>																														   '
_cHTML+='      </tr>																																	   '


_cHTML+='    </table></td>																																   '
_cHTML+='  </tr>																																		   '
_cHTML+='</table>																																		   '
_cHTML+='<hr/>																																			   '
_cHTML+='																																				   '
_cHTML+='<table width="100%" border="0" id="t01">																										   '
_cHTML+='	<caption align="center" >																													   '
_cHTML+='	<strong >Lista de itens com saldo divergente</strong>																						   '
_cHTML+='	<br>																																		   '
_cHTML+='	</caption>																																	   '
_cHTML+='  <tr>																																			   '
_cHTML+='    <td width="1%" rowspan="2"></td>																											   '
_cHTML+='    <td width="99%"><table  width="100%"  border="1" class="TFtable">																							   '
_cHTML+='      <thead> <tr>																																		   '
_cHTML+='        <th width=10px scope="col" align="left" >No. </th>																						   '
_cHTML+='        <th width=20px scope="col" align="left">Codigo</th>																				   '
_cHTML+='        <th width=8px scope="col" align="left">Tipo</th>																				   '
_cHTML+='        <th width=80px scope="col" align="left">Descrição</th>																				   '
_cHTML+='        <th width=15px" scope="col" align="left">End.Origem</th>																				   '
//_cHTML+='        <th width="16%" scope="col" align="left">End.Destino</th>																				   '
_cHTML+='        <th width=10px scope="col" align="left">Quant.</th>																					   '
_cHTML+='        <th width=30px scope="col" align="left">Observações</th>																				   '
_cHTML+='      </tr> </thead>																																   '

_cHTML+= RetItencRNC(cDoc)

_cHTML+='																																				   '
_cHTML+='    </table></td>  </tr>																														   '
_cHTML+='</table>																																		   '
_cHTML+='<table width="100%" border="0">																												   '
_cHTML+='  <tr>																																			   '
_cHTML+='    <td width="1%" rowspan="2"></td>																											   '
_cHTML+='   </tr>																																		   '
_cHTML+='  <tr>

_cHTML+='    <td><table width="100%" height="42" align="left" cellspacing="1"  >													   '
_cHTML+='      <tr >																																	   '
_cHTML+='        <td width="108" ><p>Aviso / Sistema :</p></td>																							   '
_cHTML+='        <td width="959"> 																														   '
_cHTML+=' O Documento não gera  movimentação/transferência de saldos entre endereços, O Responsável precisa 											   '
_cHTML+='acessar o registro Aprovar/Reprovar a solicitação. A controladoria irá fazer apuração validar os saldos nos endereços informados.</td> 		   '
_cHTML+='      </tr>																																	   '
_cHTML+='																																				   '
_cHTML+='    </table></td>																																   '
_cHTML+='																																				   '
_cHTML+='  </tr>																																		   '
_cHTML+='<hr/>																																			   '
_cHTML+='</table>																																		   '
_cHTML+='<hr/>																																			   '
_cHTML+='</table>																																		   '
_cHTML+='</html>'																																		   







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


// FUNÇÃO: RETORNA OS ITENS EM HTML
STATIC Function RetItencRNC(cNum) // RECEBE O NÚMERO REGISTRO
    Local cItens :=""               // Retornaos Itens em TXT/HTML
    Local aArea := ZT2->(GetArea()) // ARMAZENA A ÁREA PARA RESTAURAR APÓS OPERAÇÕES
    Local _cTipo := SPACE(2)
    

    ZT2->(DbGoTop())                          // MOVE O CURSOR PARA O TOPO DA TABELA
    ZT2->(DbSetOrder(1))                      // ALTERA PARA O ÍNDICE 1: ZT2_FILIAL + ZT2_DOC + (...)
    ZT2->(MsSeek(FwXFilial("ZT2") + cNum )) // USA O NÚMERO  PARA PESQUISAR

    // ENTÃO O NÚMERO  NÚMERO CORRENTE NA
    // TABELA ZT2, ADICIONE O VALOR TOTAL DO ITEM A VARIAVEL NTOTAL
    While (ZT2->ZT2_DOC == cNum)
    	cItens+='<tr>'
      cItens+='<td><pre>'+ZT2->	ZT2_ITEM+'</pre></td>' 
  		cItens+='<td><pre>'+ZT2->	ZT2_COD+'</pre></td>'    

  		_cTipo := POSICIONE("SB1",1,XFILIAL("SB1")+ZT2->ZT2_COD,"B1_TIPO")

  		cItens+='<td><pre>' + _cTipo + '</pre></td>'    
  		
		cItens+='<td><pre>'+ZT2->	ZT2_DESCRI+'</pre></td>' 
		cItens+='<td><pre>'+ZT2->	ZT2_OENDER+'</pre></td>' 
		//cItens+='<td><pre>'+ZT2-> ZT2_DENDER+'</pre></td>' 
		cItens+='<td><pre>'+ Transform((ZT2-> ZT2_QUANT), "@E 99,999.99")	+'</pre></td>' 
		cItens+='<td> <font size="1px"> '+ZT2-> ZT2_OBS+'</font></td>'
		cItens+='</tr>' 

      ZT2->(DbSkip())
    End

    // RESTAURA A ÁREA ORIGINAL (EVITA ERROS DE POSICIONAMENTO)
    RestArea(aArea)
Return (cItens) // RETORNA O VALOR PARA A COLUNA