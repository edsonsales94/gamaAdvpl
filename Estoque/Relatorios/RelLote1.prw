#Include 'Protheus.ch'


/*
Relacao de vencimetos de lotes
Autor: Claudio Almeida
Data: 01/04/2015
Objetivo :  Divulgar para os usuarios os lotes vencidos por periodo 
*/

User Function RelLote1()
  Local oReport
  oReport:= ReportDef()
  oReport:PrintDialog()
 Return


Static Function ReportDef()

Local oReport 
Local oSection1
Local oSection2 
Local oSection3 
Local oCell         
Local oBreak
Local cTitle := "Relacao de Vencimento de Lotes e Produtos"

Local cAliasSB8:= GetNextAlias()

oReport := TReport():New("RelLote1",cTitle,Nil, {|oReport| ReportPrint(oReport,cAliasSB8)},"Relação dos Lotes a vencer nos proximos 90 DIAS") 
oReport:SetDevice(3)   //imprime o relatorio por email
//Criação da secao 1 do relatorio
oSection1:= TRSection():New(oReport,"Lotes a Vencer 30 Dias ",{"SB8","SB1"},/*aOrdem*/)
oSection2:= TRSection():New(oReport,"Lotes a Vencer 60 Dias ",{"SB8","SB1"},/*aOrdem*/)
oSection3:= TRSection():New(oReport,"Lotes a Vencer 90 Dias ",{"SB8","SB1"},/*aOrdem*/)
oSection1:SetHeaderPage()

//Criação das celulas da seção 1 vencimento para 30 DIAS
TRCell():New(oSection1,"B8_LOTECTL"   ,"SB8",/*Titulo*/,/*Picture*/,TamSX3("B8_LOTECTL")[1]+5,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"B8_PRODUTO"   ,"SB8",/*Titulo*/,/*Picture*/,TamSX3("B8_PRODUTO")[1]+5,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"B1_DESC"      ,"SB1",/*Titulo*/,/*Picture*/,TamSX3("B1_DESC")[1]+15,/*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"B8_LOCAL"     ,"SB8",/*Titulo*/,/*Picture*/,10,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"B8_DTVALID"   ,"SB8",/*Titulo*/,PesqPict("SB8","B8_DTVALID" ,14),/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"B8_SALDO"     ,"SB8",/*Titulo*/,PesqPict("SB8","B8_SALDO" ,20),/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

//Criação das celulas da seção 3 vencimento para 60 DIAS
TRCell():New(oSection2,"B8_LOTECTL"   ,"SB8",/*Titulo*/,/*Picture*/,TamSX3("B8_LOTECTL")[1]+5,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"B8_PRODUTO"   ,"SB8",/*Titulo*/,/*Picture*/,TamSX3("B8_PRODUTO")[1]+5,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"B1_DESC"      ,"SB1",/*Titulo*/,/*Picture*/,TamSX3("B1_DESC")[1]+15,/*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection2,"B8_LOCAL"     ,"SB8",/*Titulo*/,/*Picture*/,10,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"B8_DTVALID"   ,"SB8",/*Titulo*/,PesqPict("SB8","B8_DTVALID" ,14),/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"B8_SALDO"     ,"SB8",/*Titulo*/,PesqPict("SB8","B8_SALDO" ,20),/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

//Criação das celulas da seção 3 vencimento para 90 DIAS
TRCell():New(oSection3,"B8_LOTECTL"   ,"SB8",/*Titulo*/,/*Picture*/,TamSX3("B8_LOTECTL")[1]+5,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"B8_PRODUTO"   ,"SB8",/*Titulo*/,/*Picture*/,TamSX3("B8_PRODUTO")[1]+5,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"B1_DESC"      ,"SB1",/*Titulo*/,/*Picture*/,TamSX3("B1_DESC")[1]+15,/*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection3,"B8_LOCAL"     ,"SB8",/*Titulo*/,/*Picture*/,10,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"B8_DTVALID"   ,"SB8",/*Titulo*/,PesqPict("SB8","B8_DTVALID" ,14),/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"B8_SALDO"     ,"SB8",/*Titulo*/,PesqPict("SB8","B8_SALDO" ,20),/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

Return(oReport)



Static Function ReportPrint(oReport,cAliasSB8)
Local oSection1 := oReport:Section(1) 
Local oSection2 := oReport:Section(2)
Local oSection3 := oReport:Section(3)  
Local oBreak
Local cQuery := ""
Local cWhere := ""
Local lQuery := .T. 
Local cAliasSB82
Local cAliasSB83
Local dVenc  := dtos(dDatabase)
Local dVenc1 := ""   //30 dias
Local dVenc2 := ""   //60 dias
Local dVenc3 := ""   //90 dias
Local ano :=substr(dVenc,1,4)
Local mes :=substr(dVenc,5,2) 
Local dia :=substr(dVenc,7,2) 
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
oReport:Section(1):BeginQuery()	
BeginSql Alias cAliasSB8
	SELECT B8_LOTECTL,B8_PRODUTO,B8_LOCAL,B8_DTVALID,B8_SALDO
	   		  FROM %table:SB8% SB8
			 WHERE B8_FILIAL  = %xFilial:SB8% AND 
	   			   B8_DTVALID<=%Exp:dVenc1% AND B8_SALDO<>0 AND 
	 		       SB8.%NotDel% 
			ORDER BY B8_DTVALID
EndSql
oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)

// QUERY DOS ITENS VENCIDOS EM 60 DIAS 
cAliasSB82:= GetNextAlias()
oReport:Section(2):BeginQuery()	
BeginSql Alias cAliasSB82
	SELECT B8_LOTECTL,B8_PRODUTO,B8_LOCAL,B8_DTVALID,B8_SALDO
	   		  FROM %table:SB8% SB8
			 WHERE B8_FILIAL  = %xFilial:SB8% AND 
	   			   B8_DTVALID>%Exp:dVenc1% AND B8_DTVALID<=%Exp:dVenc2% AND B8_SALDO<>0 AND  
	 		       SB8.%NotDel% 
			ORDER BY B8_DTVALID
EndSql
oReport:Section(2):EndQuery(/*Array com os parametros do tipo Range*/)

// QUERY DOS ITENS VENCIDOS EM 90 DIAS 
cAliasSB83:= GetNextAlias()
oReport:Section(3):BeginQuery()	
BeginSql Alias cAliasSB83
	SELECT B8_LOTECTL,B8_PRODUTO,B8_LOCAL,B8_DTVALID,B8_SALDO
	   		  FROM %table:SB8% SB8
			 WHERE B8_FILIAL  = %xFilial:SB8% AND 
	   			   B8_DTVALID>%Exp:dVenc2% AND B8_DTVALID<=%Exp:dVenc3% AND B8_SALDO<>0 AND 
	 		       SB8.%NotDel% 
			ORDER BY B8_DTVALID
EndSql
oReport:Section(3):EndQuery(/*Array com os parametros do tipo Range*/)

TRPosition():New(oSection1,"SB1",1,{ || xFilial("SB1") + (cAliasSB8)->B8_PRODUTO })
TRFunction():New(oSection1:Cell("B8_LOTECTL"),, 'COUNT',/*oBreak*/ ,"Quantidade de Lotes: ",,,.T.,.T.,.T., oSection1)
TRFunction():New(oSection2:Cell("B8_LOTECTL"),, 'COUNT',/*oBreak*/ ,"Quantidade de Lotes: ",,,.T.,.T.,.T., oSection2)
TRFunction():New(oSection3:Cell("B8_LOTECTL"),, 'COUNT',/*oBreak*/ ,"Quantidade de Lotes: ",,,.T.,.T.,.T., oSection3)

oReport:SetMeter((cAliasSB8)->(LastRec()))
dbSelectArea(cAliasSB8)  
dbgotop() 
oSection1:Cell("B8_LOCAL"):nAlign := 2
oSection1:Cell("B8_DTVALID"):nAlign := 2
IF !(cAliasSB8)->(Eof())
 oSection1:Init() 
 While !oReport:Cancel() .And. !(cAliasSB8)->(Eof())
    oReport:IncMeter()
   If oReport:Cancel()
	 Exit
   EndIf
   oSection1:PrintLine() 
   dbSelectArea(cAliasSB8)
   dbSkip()
 EndDo
 oReport:SkipLine()
 oReport:ThinLine()
 oSection1:Finish()
ELSE
 oReport:SkipLine()
 oReport:PrintText("Nao existem lotes vencendo em ate 30 Dias !",,oSection1:Cell("B8_LOTECTL"):ColPos()) 
 oReport:SkipLine()    
ENDIF 
 dbSelectArea(cAliasSB8)
 dbCloseArea()
 
//imprimi os lotes vencidos em 60 dias 
dbSelectArea(cAliasSB82)
dbgotop()  
oSection2:Cell("B8_LOCAL"):nAlign := 2
oSection2:Cell("B8_DTVALID"):nAlign := 2
IF !(cAliasSB82)->(Eof())
 oSection2:Init() 
 While !oReport:Cancel() .And. !(cAliasSB82)->(Eof())
    oReport:IncMeter()
   If oReport:Cancel()
	 Exit
   EndIf
   oSection2:PrintLine() 
   dbSelectArea(cAliasSB82)
   dbSkip()
 EndDo
 oReport:SkipLine()
 oReport:ThinLine()
 oSection2:Finish()
ELSE
 oReport:SkipLine()
 oReport:PrintText("Nao existem lotes vencendo em ate 60 Dias !",,oSection2:Cell("B8_LOTECTL"):ColPos()) 
 oReport:SkipLine()    
ENDIF 
dbSelectArea(cAliasSB82)
dbCloseArea()
 
 
//imprimi os lotes vencidos em 90 dias 
dbSelectArea(cAliasSB83)  
dbgotop() 
oSection3:Cell("B8_LOCAL"):nAlign := 2
oSection3:Cell("B8_DTVALID"):nAlign := 2
IF !(cAliasSB83)->(Eof())
oSection3:Init() 
While !oReport:Cancel() .And. !(cAliasSB83)->(Eof())
    oReport:IncMeter()
   If oReport:Cancel()
	 Exit
   EndIf
   oSection3:PrintLine() 
   dbSelectArea(cAliasSB83)
   dbSkip()
 EndDo
 oReport:SkipLine()
 oReport:ThinLine()
 oSection3:Finish()
ELSE
 oReport:SkipLine()
 oReport:PrintText("Nao existem lotes vencendo em ate 90 Dias !",,oSection2:Cell("B8_LOTECTL"):ColPos()) 
 oReport:SkipLine()    
ENDIF 
 
 oReport:EndPage() 
 dbSelectArea(cAliasSB83)
 dbCloseArea()
Return Nil
