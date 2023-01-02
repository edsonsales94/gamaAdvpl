#Include 'Protheus.ch'

User Function EmlLote1()
Local cEol := chr(13) + chr(10)
Local cDestinat
Local cQuery := ""
Local cWhere := ""
Local lQuery := .T. 
Local cAliasSB81
Local cAliasSB82
Local cAliasSB83
Local dVenc  
Local dVenc1 := ""   //30 dias
Local dVenc2 := ""   //60 dias
Local dVenc3 := ""   //90 dias
Local ano 
Local mes 
Local dia 
Local cTitulo
Local cMensagem := '<html>'          
Local aFiles	:= { "SB8", "SB1" }
Local nK, nX
Local cEmp		:= "01"				//Brasitech
Local cFil		:= "01"		//Filiais 03-São Paulo e 01-Manaus
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Abertura do ambiente                                                         |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WfPrepEnv( cEmp, cFil, "U_EMLLOTE1",aFiles , "EST" )
cTitulo:="Relação de Lotes a  Vencer em 30,60 e 90 Dias apartir de : " + dTOc(dDataBase) + " às " + Time()
cDestinat:=GETMV("BR_EMLOTE")
dVenc  := dtos(dDatabase)
ano :=substr(dVenc,1,4)
mes :=substr(dVenc,5,2) 
dia :=substr(dVenc,7,2) 
//vencimento de 30 dias 
if val(mes)==12
  ano:=str(val(ano)+1,4)
  dVenc1:= alltrim(ano+"01"+dia)
else
  dVenc1:= alltrim(ano+strzero(val(mes)+1,2)+dia)
endif
//vencimento de 60 dias
if val(mes)==11
  ano:=str(val(ano)+1,4)
  dVenc2:= alltrim(ano+"01"+dia)
else
  dVenc2:= alltrim(ano+strzero(val(mes)+2,2)+dia)
endif
//vencimento de 90 dias
if val(mes)==10
  ano:=str(val(ano)+1,4)
  dVenc3:= alltrim(ano+"01"+dia)
else
  dVenc3:= alltrim(ano+strzero(val(mes)+3,2)+dia)
endif
   
// QUERY DOS ITENS VENCIDOS EM 30 DIAS 
cAliasSB81:= GetNextAlias()
BeginSql Alias cAliasSB81
	SELECT B8_LOTECTL,B8_PRODUTO,B8_LOCAL,B8_DTVALID,B8_SALDO
	   		  FROM %table:SB8% SB8
			 WHERE B8_FILIAL  = %xFilial:SB8% AND 
	   			 B8_DTVALID<=%Exp:dVenc1% AND  B8_SALDO<>0 AND 
	 		       SB8.%NotDel% 
			ORDER BY B8_DTVALID
EndSql


// QUERY DOS ITENS VENCIDOS EM 60 DIAS 
cAliasSB82:= GetNextAlias()
BeginSql Alias cAliasSB82
	SELECT B8_LOTECTL,B8_PRODUTO,B8_LOCAL,B8_DTVALID,B8_SALDO
	   		  FROM %table:SB8% SB8
			 WHERE B8_FILIAL  = %xFilial:SB8% AND 
	   			    B8_DTVALID>%Exp:dVenc1% AND B8_DTVALID<=%Exp:dVenc2% AND B8_SALDO<>0 AND  
	 		       SB8.%NotDel% 
			ORDER BY B8_DTVALID
EndSql

// QUERY DOS ITENS VENCIDOS EM 90 DIAS 
cAliasSB83:= GetNextAlias()
BeginSql Alias cAliasSB83
	SELECT B8_LOTECTL,B8_PRODUTO,B8_LOCAL,B8_DTVALID,B8_SALDO
	   		  FROM %table:SB8% SB8
			 WHERE B8_FILIAL  = %xFilial:SB8% AND 
	   			    B8_DTVALID>%Exp:dVenc2% AND B8_DTVALID<=%Exp:dVenc3% AND B8_SALDO<>0 AND 
	 		       SB8.%NotDel% 
			ORDER BY B8_DTVALID
EndSql  

cMensagem +='<body>' 
cMensagem += '<font size="5" face="Arial" color="red"><p><b>'+cTitulo+'</b></p></font><br><br>'
cMensagem += '<font size="3" face="Arial" color="#0000CD"><p><b>Lotes com Vencimento em 30 Dias</b></p></font>'
//Abrindo a tabela
cMensagem += '<table width="100%" border="1" cellspacing="0" cellpadding="0">'
//Abrindo a linha do cabeçalho  
cMensagem += '<tr style="background-color:#000000">'
cMensagem += '<td width="7%" align="center"> <font size="3" face="Calibri" color="white"><strong>Numero Lote</strong></font></td>'
cMensagem += '<td width="7%" align="center"><font size="3" face="Calibri" color="white"><strong>Codigo</strong></font></td>'
cMensagem += '<td width="27%" align="center"><font size="3" face="Calibri" color="white"><strong>Descrição</strong></font></td>'
cMensagem += '<td width="3%" align="center"><font size="3" face="Calibri" color="white"><strong>Local</strong></font></td>'
cMensagem += '<td width="7%" align="center"><font size="3" face="Calibri" color="white"><strong>Data Validade</strong></font></td>'
cMensagem += '<td width="6%" align="center"><font size="3" face="Calibri" color="white"><strong>Saldo</strong></font></td>'
cMensagem += '</tr>'

//Abrindo a linha dos itens de 30 dias
dbSelectArea(cAliasSB81)  
dbgotop() 
While !(cAliasSB81)->(Eof())
  cMensagem += '<tr>'
  cB1_DESC:=posicione("SB1",1,xfilial("SB1")+(cAliasSB81)->B8_PRODUTO,"B1_DESC")
  cB8_DTVALID:= substr(B8_DTVALID,7,2)+"/"+substr(B8_DTVALID,5,2)+"/"+substr(B8_DTVALID,1,4)
  cMensagem += '<td width="7%" align="center"><font size="2" face="Calibri"><strong>' + B8_LOTECTL + '</strong></font></td>'
  cMensagem += '<td width="7%" align="center"><font size="2" face="Calibri"><strong>' + B8_PRODUTO + '</strong></font></td>'
  cMensagem += '<td width="27%" align="left"><font size="2" face="Calibri"><strong>' + cB1_DESC + '</strong></font></td>'
  cMensagem += '<td width="3%" align="center"><font size="2" face="Calibri"><strong>' + B8_LOCAL + '</strong></font></td>'
  cMensagem += '<td width="7%" align="center"><font size="2" face="Calibri"><strong>' + cB8_DTVALID + '</strong></font></td>'
  cMensagem += '<td width="6%" align="right"><font size="2" face="Calibri"><strong>' +TRANSFORM(B8_SALDO,"@E 99,999,999.99") + '</strong></font></td>'
  cMensagem += '</tr>'
  dbskip()
Enddo  
cMensagem += '</table>'

cMensagem += '<font size="3" face="Arial" color="#0000CD"><p><b>Lotes com Vencimento em 60 Dias</b></p></font>'
//Abrindo a tabela
cMensagem += '<table width="100%" border="1" cellspacing="0" cellpadding="0">'
//Abrindo a linha do cabeçalho  
cMensagem += '<tr style="background-color:#000000">'
cMensagem += '<td width="7%" align="center"> <font size="3" face="Calibri" color="white"><strong>Numero Lote</strong></font></td>'
cMensagem += '<td width="7%" align="center"><font size="3" face="Calibri" color="white"><strong>Codigo</strong></font></td>'
cMensagem += '<td width="27%" align="center"><font size="3" face="Calibri" color="white"><strong>Descrição</strong></font></td>'
cMensagem += '<td width="3%" align="center"><font size="3" face="Calibri" color="white"><strong>Local</strong></font></td>'
cMensagem += '<td width="7%" align="center"><font size="3" face="Calibri" color="white"><strong>Data Validade</strong></font></td>'
cMensagem += '<td width="6%" align="center"><font size="3" face="Calibri" color="white"><strong>Saldo</strong></font></td>'
cMensagem += '</tr>'

//Abrindo a linha dos itens de 60 dias
dbSelectArea(cAliasSB82)  
dbgotop() 
While !(cAliasSB82)->(Eof())
  cMensagem += '<tr>' 
  cB1_DESC:=posicione("SB1",1,xfilial("SB1")+(cAliasSB82)->B8_PRODUTO,"B1_DESC")  
  cB8_DTVALID:= substr(B8_DTVALID,7,2)+"/"+substr(B8_DTVALID,5,2)+"/"+substr(B8_DTVALID,1,4)
  cMensagem += '<td width="7%" align="center"><font size="2" face="Calibri"><strong>' + B8_LOTECTL + '</strong></font></td>'
  cMensagem += '<td width="7" align="center"><font size="2" face="Calibri"><strong>' + B8_PRODUTO + '</strong></font></td>'
  cMensagem += '<td width="27%" align="left"><font size="2" face="Calibri"><strong>' + cB1_DESC + '</strong></font></td>'
  cMensagem += '<td width="3%" align="center"><font size="2" face="Calibri"><strong>' + B8_LOCAL + '</strong></font></td>'
  cMensagem += '<td width="7%" align="center"><font size="2" face="Calibri"><strong>' + cB8_DTVALID + '</strong></font></td>'
  cMensagem += '<td width="6%" align="right"><font size="2" face="Calibri"><strong>' + TRANSFORM(B8_SALDO,"@E 99,999,999.99") + '</strong></font></td>'
  cMensagem += '</tr>'
  dbskip()
Enddo  
  
cMensagem += '</table>'

cMensagem += '<font size="3" face="Arial" color="#0000CD"><p><b>Lotes com Vencimento em 90 Dias</b></p></font>'
//Abrindo a tabela
cMensagem += '<table width="100%" border="1" cellspacing="0" cellpadding="0">' 
//Abrindo a linha do cabeçalho  
cMensagem += '<tr style="background-color:#000000">'
cMensagem += '<td width="7%" align="center"> <font size="3" face="Calibri" color="white"><strong>Numero Lote</strong></font></td>'
cMensagem += '<td width="7%" align="center"><font size="3" face="Calibri" color="white"><strong>Codigo</strong></font></td>'
cMensagem += '<td width="27%" align="center"><font size="3" face="Calibri" color="white"><strong>Descrição</strong></font></td>'
cMensagem += '<td width="3%" align="center"><font size="3" face="Calibri" color="white"><strong>Local</strong></font></td>'
cMensagem += '<td width="7%" align="center"><font size="3" face="Calibri" color="white"><strong>Data Validade</strong></font></td>'
cMensagem += '<td width="6%" align="center"><font size="3" face="Calibri" color="white"><strong>Saldo</strong></font></td>'
cMensagem += '</tr>'
 //Abrindo a linha dos itens de 90 dias
dbSelectArea(cAliasSB83)  
dbgotop() 
While !(cAliasSB83)->(Eof())  
  cMensagem += '<tr>'
  cB1_DESC:=posicione("SB1",1,xfilial("SB1")+(cAliasSB83)->B8_PRODUTO,"B1_DESC")     
  cB8_DTVALID:= substr(B8_DTVALID,7,2)+"/"+substr(B8_DTVALID,5,2)+"/"+substr(B8_DTVALID,1,4)
  cMensagem += '<td width="7%" align="center"><font size="2" face="Calibri"><strong>' + B8_LOTECTL + '</strong></font></td>'
  cMensagem += '<td width="7%" align="center"><font size="2" face="Calibri"><strong>' + B8_PRODUTO + '</strong></font></td>'
  cMensagem += '<td width="27%" align="left"><font size="2" face="Calibri"><strong>' + cB1_DESC + '</strong></font></td>'
  cMensagem += '<td width="3%" align="center"><font size="2" face="Calibri"><strong>' + B8_LOCAL + '</strong></font></td>'
  cMensagem += '<td width="7%" align="center"><font size="2" face="Calibri"><strong>' + cB8_DTVALID + '</strong></font></td>'
  cMensagem += '<td width="6%" align="right"><font size="2" face="Calibri"><strong>' + TRANSFORM(B8_SALDO,"@E 99,999,999.99") + '</strong></font></td>'
  cMensagem += '</tr>'
  dbskip()
Enddo  
cMensagem += '</table>'
cMensagem += '</body>'
cMensagem += '</html>'

//fechando as tabelas   ------------------------------------------------------------
dbSelectArea(cAliasSB81)
dbCloseArea()
dbSelectArea(cAliasSB82)
dbCloseArea() 
dbSelectArea(cAliasSB83)  
dbCloseArea()
//-----------------------------------------------------------------------------------
 
 //enviando o email com as mensagens
     //GISendMail(cDestinat, cCopiaOcult, cSubject, cMsgCorpo, cAnexo)
    cErro := U_GISendMail(cDestinat,/*copia oculta*/, cTitulo, cMensagem)
	
	if !Empty(cErro)
		Help(" ", 1, "ATENÇÃO", , "Ocorreu o seguinte erro  no envio do e-mail: " + cEol + cErro + cEol + "(Específico Brasitech). ", 1)	
	endif   
ConOut("EMAIL COM RELACAO DE LOTES ENVIADO COM SUCESSO EM "+dtoc(dDatabase)+ " às " + Time())	
RpcClearEnv()
Return
