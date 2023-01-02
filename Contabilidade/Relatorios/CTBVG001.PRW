#include 'protheus.ch'
#include 'parmtype.ch'

user function ctbvg001()

Local oReport
Private nPerc := {}
Private cAliasQRY := "CVF"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Interface de impressao                                                  ³
// Ultima Alteração : 15/03/2016 14:00 por Claudio 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := ReportDef()
oReport:PrintDialog()
return

 
Static Function ReportDef()

Local oReport 
Local oSection 
Local oCell         
Local cPerg	:= "CTBVG01"
Local meses := {"Janeiro","Feveriro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}

ValidPerg(cPerg)
oReport := TReport():New("CTBVG001","P&L",cPerg, {|oReport| ReportPrint(oReport)})   
oReport:SetLandScape()
Pergunte(cPerg,.F.)

oSection := TRSection():New(oReport,"P&L",{"CVF"}) //"Planilha de Orcamento"
oSection:SetHeaderPage()
TRCell():New(oSection,"CVF_CONTAG"    ,"CVF",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection,"CVF_DESCCG"    ,"CVF",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

TRCell():New(oSection,"VALOR_REAL01" ,"",meses[1]       ,PesqPict("CT2","CT2_VALOR"),,,     {|| aRetCT2((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES01,0)})
if MV_PAR02==2
 TRCell():New(oSection,"VALOR_ORC01" ,""," Orcado"      ,PesqPict("CT2","CT2_VALOR"),,,     {|| aRetOrc((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES01,0)} )
 TRCell():New(oSection,"DIF01" ,"","Var R$"       ,PesqPict("CT2","CT2_VALOR"),,,     {|| aRetDif((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES01,0)} )
 TRCell():New(oSection,"VAR01" ,""," %"         ,PesqPict("CT2","CT2_VALOR"),,,      {|| aRetPerc((cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES01)} )
 oSection:Cell("VAR01"):SetBorder(4,2)
endif

TRCell():New(oSection,"VALOR_REAL02" ,"",meses[2]       ,PesqPict("CT2","CT2_VALOR"),,,     {|| aRetCT2((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES02,0)})
if MV_PAR02==2
 TRCell():New(oSection,"VALOR_ORC02" ,""," Orcado"      ,PesqPict("CT2","CT2_VALOR"),,,     {|| aRetOrc((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES02,0)})
 TRCell():New(oSection,"DIF02" ,"","Var R$"       ,PesqPict("CT2","CT2_VALOR"),,,     {|| aRetDif((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES02,0)})
 TRCell():New(oSection,"VAR02" ,""," %"         ,PesqPict("CT2","CT2_VALOR"),,,      {|| aRetPerc((cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES02)})
 oSection:Cell("VAR02"):SetBorder(4,2)
endif
  
TRCell():New(oSection,"VALOR_REAL03" ,"",meses[3]       ,PesqPict("CT2","CT2_VALOR"),,,     {|| aRetCT2((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES03,0)})
if MV_PAR02==2
 TRCell():New(oSection,"VALOR_ORC03" ,""," Orcado"      ,PesqPict("CT2","CT2_VALOR"),,,     {|| aRetOrc((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES03,0)})
 TRCell():New(oSection,"DIF03" ,"","Var R$"       ,PesqPict("CT2","CT2_VALOR"),,,     {|| aRetDif((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES03,0)})
 TRCell():New(oSection,"VAR03" ,""," %"         ,PesqPict("CT2","CT2_VALOR"),,,      {|| aRetPerc((cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES03)})
 oSection:Cell("VAR03"):SetBorder(4,2)
endif

TRCell():New(oSection,"VALOR_REAL04" ,"",meses[4]       ,PesqPict("CT2","CT2_VALOR"),,,     {|| aRetCT2((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES04,0)})
if MV_PAR02==2
 TRCell():New(oSection,"VALOR_ORC04" ,""," Orcado"      ,PesqPict("CT2","CT2_VALOR"),,,     {|| aRetOrc((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES04,0)})
 TRCell():New(oSection,"DIF04" ,"","Var R$"       ,PesqPict("CT2","CT2_VALOR"),,,     {|| aRetDif((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES04,0)})
 TRCell():New(oSection,"VAR04" ,""," %"         ,PesqPict("CT2","CT2_VALOR"),,,      {|| aRetPerc((cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES04)})
 oSection:Cell("VAR04"):SetBorder(4,2)
endif

TRCell():New(oSection,"VALOR_REAL05" ,"",meses[5]       ,PesqPict("CT2","CT2_VALOR"),,,     {|| aRetCT2((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES05,0)})
if MV_PAR02==2
 TRCell():New(oSection,"VALOR_ORC05" ,""," Orcado"      ,PesqPict("CT2","CT2_VALOR"),,,     {|| aRetOrc((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES05,0)})
 TRCell():New(oSection,"DIF05" ,"","Var R$"       ,PesqPict("CT2","CT2_VALOR"),,,     {|| aRetDif((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES05,0)})
 TRCell():New(oSection,"VAR05" ,""," %"         ,PesqPict("CT2","CT2_VALOR"),,,      {|| aRetPerc((cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES05)})
 oSection:Cell("VAR05"):SetBorder(4,2)
endif

TRCell():New(oSection,"VALOR_REAL06" ,"",meses[6]       ,PesqPict("CT2","CT2_VALOR"),,,     {|| aRetCT2((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES06,0)})
if MV_PAR02==2
 TRCell():New(oSection,"VALOR_ORC06" ,""," Orcado"      ,PesqPict("CT2","CT2_VALOR"),,,     {|| aRetOrc((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES06,0)})
 TRCell():New(oSection,"DIF06" ,"","Var R$"       ,PesqPict("CT2","CT2_VALOR"),,,     {|| aRetDif((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES06,0)})
 TRCell():New(oSection,"VAR06" ,""," %"         ,PesqPict("CT2","CT2_VALOR"),,,      {|| aRetPerc((cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES06)})
 oSection:Cell("VAR06"):SetBorder(4,2)
endif

TRCell():New(oSection,"VALOR_REAL07" ,"",meses[7]       ,PesqPict("CT2","CT2_VALOR"),,,     {|| aRetCT2((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES07,0)})
if MV_PAR02==2
 TRCell():New(oSection,"VALOR_ORC07" ,""," Orcado"      ,PesqPict("CT2","CT2_VALOR"),,,     {|| aRetOrc((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES07,0)})
 TRCell():New(oSection,"DIF07" ,"","Var R$"       ,PesqPict("CT2","CT2_VALOR"),,,     {|| aRetDif((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES07,0)})
 TRCell():New(oSection,"VAR07" ,""," %"         ,PesqPict("CT2","CT2_VALOR"),,,      {|| aRetPerc((cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES07)})
 oSection:Cell("VAR07"):SetBorder(4,2)
endif

TRCell():New(oSection,"VALOR_REAL08" ,"",meses[8]       ,PesqPict("CT2","CT2_VALOR"),,,     {|| aRetCT2((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES08,0)})
if MV_PAR02==2
 TRCell():New(oSection,"VALOR_ORC08" ,""," Orcado"      ,PesqPict("CT2","CT2_VALOR"),,,     {|| aRetOrc((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES08,0)})
 TRCell():New(oSection,"DIF08" ,"","Var R$"       ,PesqPict("CT2","CT2_VALOR"),,,     {|| aRetDif((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES08,0)})
 TRCell():New(oSection,"VAR08" ,""," %"         ,PesqPict("CT2","CT2_VALOR"),,,      {|| aRetPerc((cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES08)})
 oSection:Cell("VAR08"):SetBorder(4,2)
endif

TRCell():New(oSection,"VALOR_REAL09" ,"",meses[9]       ,PesqPict("CT2","CT2_VALOR"),,,     {|| aRetCT2((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES09,0)})
if MV_PAR02==2
 TRCell():New(oSection,"VALOR_ORC09" ,""," Orcado"      ,PesqPict("CT2","CT2_VALOR"),,,     {|| aRetOrc((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES09,0)})
 TRCell():New(oSection,"DIF09" ,"","Var R$"       ,PesqPict("CT2","CT2_VALOR"),,,     {|| aRetDif((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES09,0)})
 TRCell():New(oSection,"VAR09" ,""," %"         ,PesqPict("CT2","CT2_VALOR"),,,      {|| aRetPerc((cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES09)})
 oSection:Cell("VAR09"):SetBorder(4,2)
endif

TRCell():New(oSection,"VALOR_REAL10" ,"",meses[10]      ,PesqPict("CT2","CT2_VALOR"),,,     {|| aRetCT2((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES10,0)})
if MV_PAR02==2
 TRCell():New(oSection,"VALOR_ORC10" ,""," Orcado"      ,PesqPict("CT2","CT2_VALOR"),,,     {|| aRetOrc((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES10,0)})
 TRCell():New(oSection,"DIF10" ,"","Var R$"       ,PesqPict("CT2","CT2_VALOR"),,,     {|| aRetDif((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES10,0)})
 TRCell():New(oSection,"VAR10" ,""," %"         ,PesqPict("CT2","CT2_VALOR"),,,      {|| aRetPerc((cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES10)})
 oSection:Cell("VAR10"):SetBorder(4,2)
endif

TRCell():New(oSection,"VALOR_REAL11" ,"",meses[11]      ,PesqPict("CT2","CT2_VALOR"),,,     {|| aRetCT2((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES11,0)})
if MV_PAR02==2
 TRCell():New(oSection,"VALOR_ORC11" ,""," Orcado"      ,PesqPict("CT2","CT2_VALOR"),,,     {|| aRetOrc((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES11,0)})
 TRCell():New(oSection,"DIF11" ,"","Var R$"       ,PesqPict("CT2","CT2_VALOR"),,,     {|| aRetDif((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES11,0)})
 TRCell():New(oSection,"VAR11" ,""," %"         ,PesqPict("CT2","CT2_VALOR"),,,      {|| aRetPerc((cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES11)})
 oSection:Cell("VAR11"):SetBorder(4,2)
endif

TRCell():New(oSection,"VALOR_REAL12" ,"",meses[12]       ,PesqPict("CT2","CT2_VALOR"),,,     {|| aRetCT2((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES12,0)})
if MV_PAR02==2
 TRCell():New(oSection,"VALOR_ORC12" ,""," Orcado"      ,PesqPict("CT2","CT2_VALOR"),,,      {|| aRetOrc((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES12,0)})
 TRCell():New(oSection,"DIF12" ,"","Var R$"       ,PesqPict("CT2","CT2_VALOR"),,,     {|| aRetDif((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES12,0)})
 TRCell():New(oSection,"VAR12" ,""," %"         ,PesqPict("CT2","CT2_VALOR"),,,      {|| aRetPerc((cAliasQRY)->CVF_CONTAG,(cAliasQRY)->MES12)})
 oSection:Cell("VAR12"):SetBorder(4,2)
endif

TRCell():New(oSection,"TOTALR" ,"","Total Realizado",PesqPict("CT2","CT2_VALOR"),,,      {|| aRetCT2((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,13,0)})
if MV_PAR02==2
 TRCell():New(oSection,"TOTALO" ,"","Total Orcado",PesqPict("CT2","CT2_VALOR"),,,        {|| aRetOrc((cAliasQRY)->CVF_CODIGO,(cAliasQRY)->CVF_CONTAG,13,0)})
endif

Return(oReport)



Static Function ReportPrint(oReport)

Local oSection  := oReport:Section(1)
Local oBreak

//oBreak:= TRBreak():New(oSection,oSection:Cell("BF_LOCAL"),Nil,.F.,,.T.) 



MakeSqlExpr(oReport:uParam)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query do relatório da secao 1                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:Section(1):BeginQuery()	
	
cAliasQRY := GetNextAlias() 

 BeginSql Alias cAliasQRY
 SELECT CVF_CODIGO,CVF_CONTAG,CVF_DESCCG ,
 1  AS MES01,2  AS MES02,3  AS MES03,4  AS MES04,5  AS MES05,
 6  AS MES06,7  AS MES07,8  AS MES08,9  AS MES09,10 AS MES10,
 11 AS MES11,12 AS MES12
 FROM %table:CVF% CVF
 WHERE CVF_FILIAL= %xFilial:CVF% AND CVF_CODIGO=%Exp:mv_par01% AND
 CVF_CONTAG>=%Exp:mv_par07% AND CVF_CONTAG<=%Exp:mv_par08% AND CVF.%NotDel%  
 ORDER BY CVF_ORDEM
 EndSql  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Metodo EndQuery ( Classe TRSection )                                    ³
//³                                                                        ³
//³Prepara o relatório para executar o Embedded SQL.                       ³
//³                                                                        ³
//³ExpA1 : Array com os parametros do tipo Range                           ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)

dif:=0
dbSelectArea(cAliasQRY)

While !oReport:Cancel() .And. !(cAliasQRY)->(Eof())

 oSection:Print()
 dbSelectArea(cAliasQRY)
 dbSkip()

EndDo
dbSelectArea(cAliasQRY)
dbclosearea(cAliasQRY)
Return NIL



 
Static Function aRetCT2(cVger,cCodvg,nMes,nVal)
Local nRet:=nVal
Local aArea 		:= GetArea()
Local cDatade , cDataAte, nMov,recn,recna
Local tCodvg
Local cAliasCTS,sarq
cDat:="01/"+strzero(iif(nMes==13,12,nMes),2)+"/"+MV_PAR05
cDatade :="01/"+strzero(iif(nMes==13,1,nMes),2)+"/"+MV_PAR05
cDataAte:=LastDate(ctod(cDat))

DbselectArea("CTS")
DBSETORDER(2)
DBSEEK(XFILIAL("CTS")+cVger+cCodvg)
nMov:= 0 
IF ALLTRIM(CTS->CTS_CONTAG)=="350"
 nMov:= 0
ENDIF
Do While !eof() .and. CTS_FILIAL=XFILIAL("CTS") .and. alltrim(CTS->CTS_CODPLA)==alltrim(cVger) .and. alltrim(CTS_CONTAG)==alltrim(cCodvg)
 recn:=CTS->(RECNO())
 if CTS->CTS_CLASSE=="1" .AND. !(ALLTRIM(CTS->CTS_CONTAG)$"350/450/451/550/551")
   tCodvg:=CTS_CONTAG
   // QUERY PARA SEPARAR AS CONTAS SUPERIORES 
   cAliasCTS :=GetNextAlias()
   BeginSql Alias cAliasCTS                                                    
   
    SELECT DISTINCT CTS_FILIAL, CTS_CODPLA, CTS_CTASUP ,CTS_CONTAG  
    FROM %table:CTS% CTS
    WHERE CTS_FILIAL= %xFilial:CTS% AND CTS_CODPLA=%Exp:cVger% AND CTS_CTASUP=%Exp:tCodvg% AND
    CTS_CONTAG>=%Exp:mv_par07% AND CTS_CONTAG<=%Exp:mv_par08% AND CTS.%NotDel%  
   EndSql
   dbSelectArea(cAliasCTS)
   DBGOTOP()              
   sarq:=cAliasCTS
   Do while !eof() .and. alltrim((cAliasCTS)->CTS_CODPLA)==alltrim(cVger) .and. alltrim((cAliasCTS)->CTS_CTASUP)==alltrim(tCodvg)
    recna:=recno()
    nRet:=aRetCT2((cAliasCTS)->CTS_CODPLA,(cAliasCTS)->CTS_CONTAG,nMes,nRet)   
    cAliasCTS := sarq
    dbSelectArea(cAliasCTS)
    (cAliasCTS)->(dbgoto(recna))
    dbskip()
   enddo
   dbSelectArea(cAliasCTS)
   dbclosearea(cAliasCTS)
 else
  if LEN(ALLTRIM(CTS_FORMUL))>0 .AND. LEN(ALLTRIM(CTS->CTS_CT1INI))==0
    IF ALLTRIM(CTS_FORMUL)=='PRANCHA'
     nMov:=MOVCPI2(cDatade,dtos(cDataAte),1)
    ELSEIF ALLTRIM(CTS_FORMUL)=='SECADOR'
     nMov:=MOVCPI2(cDatade,dtos(cDataAte),2)
    ELSEIF ALLTRIM(CTS_FORMUL)=='MARGEM'
     nMov:=aRetCT2(CTS_CODPLA,'200                 ',nMes,nRet)   
     nMov+=aRetCT2(CTS_CODPLA,'300                 ',nMes,nRet)
     nMov+=aRetCT2(CTS_CODPLA,'4010                ',nMes,nRet)
     Return(nMov) 
    ELSEIF  ALLTRIM(CTS_FORMUL)=='EBITIDA'
      nMov:=aRetCT2(CTS_CODPLA,'350                 ',nMes,nRet)   
      nMov+=aRetCT2(CTS_CODPLA,'4015                ',nMes,nRet)
      Return(nMov) 
    ELSEIF  ALLTRIM(CTS_FORMUL)=='PERC_EBITIDA'
      nMov:=aRetCT2(CTS_CODPLA,'450                 ',nMes,nRet)   
      nMov:=nMov/aRetCT2(CTS_CODPLA,'200                 ',nMes,nRet)
      Return(nMov)                                 
    ELSEIF  ALLTRIM(CTS_FORMUL)=='RESULTADO'    
      nMov:=aRetCT2(CTS_CODPLA,'450                 ',nMes,nRet) 
      nMov+=aRetCT2(CTS_CODPLA,'500                 ',nMes,nRet) 
      Return(nMov)                                 
    ELSEIF  ALLTRIM(CTS_FORMUL)=='PERC_RESULTADO'  
      nMov:=aRetCT2(CTS_CODPLA,'550                 ',nMes,nRet)   
      nMov:=nMov/aRetCT2(CTS_CODPLA,'200                 ',nMes,nRet)
      Return(nMov)                                 
    ELSEIF  ALLTRIM(CTS_FORMUL)=='MATERIAIS'
     nMov:=MOVCPI(cDatade,dtos(cDataAte))
    ENDIF 
  else 
   nMov:=CTSMMOV(cDatade,cDataAte,"01","1",3,CTS->CTS_CT1INI,CTS->CTS_CT1FIM,CTS->CTS_CTTINI,CTS->CTS_CTTFIM,CTS->CTS_CTDINI,CTS->CTS_CTDFIM,CTS->CTS_CTHINI,CTS->CTS_CTHFIM)
  endif  
  DbselectArea("CTS")
  if CTS->CTS_IDENT=="1"
    nRet:=nRet + nMov  
  elseif CTS->CTS_IDENT=="2"
    nRet:=nRet - nMov
  endif
 endif 
 dbSelectArea("CTS")
 CTS->(dbgoto(recn))
 dbskip()
Enddo
//RestArea(aArea)
Return(nRet)



Static Function  aRetOrc(cVger,cCodvg,nMes,nVal)
Local nRet:=nVal
Local aArea 		:= GetArea()
Local cDatade , cDataAte, nMov,recn,recna
Local tCodvg
Local cAliasCTS,sarq
cDat:="01/"+strzero(iif(nMes==13,12,nMes),2)+"/"+MV_PAR05
cDatade :="01/"+strzero(iif(nMes==13,1,nMes),2)+"/"+MV_PAR05
cDataAte:=LastDate(ctod(cDat))
DbselectArea("CTS")
DBSETORDER(2)
DBSEEK(XFILIAL("CTS")+cVger+cCodvg)
nMov:= 0 
Do While !eof() .and. CTS_FILIAL=XFILIAL("CTS") .and. alltrim(CTS->CTS_CODPLA)==alltrim(cVger) .and. alltrim(CTS_CONTAG)==alltrim(cCodvg)
 recn:=CTS->(RECNO())
 if CTS->CTS_CLASSE=="1"
   tCodvg:=CTS_CONTAG
   // QUERY PARA SEPARAR AS CONTAS SUPERIORES 
   cAliasCTS :=GetNextAlias()
   BeginSql Alias cAliasCTS
    SELECT DISTINCT CTS_FILIAL, CTS_CODPLA, CTS_CTASUP ,CTS_CONTAG  
    FROM %table:CTS% CTS
    WHERE CTS_FILIAL= %xFilial:CTS% AND CTS_CODPLA=%Exp:cVger% AND CTS_CTASUP=%Exp:tCodvg% AND
    CTS_CONTAG>=%Exp:mv_par07% AND CTS_CONTAG<=%Exp:mv_par08% AND CTS.%NotDel%  
   EndSql
   dbSelectArea(cAliasCTS)
   DBGOTOP()              
   sarq:=cAliasCTS
    Do while !eof() .and. alltrim((cAliasCTS)->CTS_CODPLA)==alltrim(cVger) .and. alltrim((cAliasCTS)->CTS_CTASUP)==alltrim(tCodvg)
    recna:=recno()
    nRet:= aRetOrc((cAliasCTS)->CTS_CODPLA     ,(cAliasCTS)->CTS_CONTAG,nMes,nRet)   
    cAliasCTS := sarq
    dbSelectArea(cAliasCTS)
    (cAliasCTS)->(dbgoto(recna))
    dbskip()
   enddo
   dbSelectArea(cAliasCTS)
   dbclosearea(cAliasCTS)
 else
  nMov:= aRetStq(CTS->CTS_CT1INI,CTS->CTS_CT1FIM,MV_PAR03,MV_PAR04,nMes,CTS->CTS_CTTINI,CTS->CTS_CTTFIM)
  DbselectArea("CTS")
  if CTS->CTS_IDENT=="1"
    nRet:=nRet + nMov  
  elseif CTS->CTS_IDENT=="2"
    nRet:=nRet - nMov
  endif
 endif 
 DbselectArea("CTS")
 CTS->(dbgoto(recn))
 dbskip()
Enddo
Return(nRet)

Static Function MovCPI(data_de,data_ate)
Local aret:=0
Local cAliasSTC := GetNextAlias()
Local datade,dataate 
datade :=substr(data_de,7,4) +substr(data_de,4,2) +substr(data_de,1,2)
dataate:=data_ate
BeginSql Alias cAliasSTC  
   SELECT  ISNULL(SUM(D3_CUSTO1),0) as CUSTO FROM %table:SD3% SD3 
   WHERE D3_FILIAL=%xFilial:SD3% 
   AND D3_EMISSAO>=%Exp:datade% AND D3_EMISSAO<=%Exp:dataate% 
   AND LEFT(D3_CF,2)='RE'  AND D3_OP<>''
   AND LEFT((SELECT MAX(C2_PRODUTO) FROM %table:SC2% SC2 WHERE C2_FILIAL=%xFilial:SC2% 
   AND C2_NUM+C2_ITEM+C2_SEQUEN=D3_OP AND SC2.%NotDel% ),3) IN ('APP','ASS')
   AND SD3.%NotDel%  AND D3_ESTORNO<>'S' AND D3_TIPO NOT IN ('MO','PA')
EndSql
dbselectArea(cAliasSTC) 
(cAliasSTC)->(dbgotop())
aret:=(cAliasSTC)->CUSTO*(-1)
dbclosearea(cAliasSTC)   
Return(aret)




Static Function MovCPI2(data_de,data_ate,ntp)
Local aret:=0
Local cAliasSTC := GetNextAlias()
Local datade,dataate ,tipo,mmes
tipo:=iif(ntp==1,'APP%','ASS%')
datade :=substr(data_de,7,4) +substr(data_de,4,2) +substr(data_de,1,2)
dataate:=data_ate
mmes:=substr(dataate,5,2)
IF mmes<>"12"
 BeginSql Alias cAliasSTC  
   SELECT D3_COD, ISNULL(SUM(D3_QUANT),0) as QUANT FROM %table:SD3% SD3 
   WHERE D3_FILIAL=%xFilial:SD3% 
   AND D3_EMISSAO>=%Exp:datade% AND D3_EMISSAO<=%Exp:dataate% 
   AND LEFT(D3_CF,2)='PR' AND D3_TIPO='PA' 
   AND SD3.%NotDel% AND D3_COD LIKE (%Exp:tipo%) AND D3_ESTORNO<>'S'
   GROUP BY D3_COD
   ORDER BY D3_COD
 EndSql
ELSE
   BeginSql Alias cAliasSTC
    SELECT Z02_DTDE,MONTH(D3_EMISSAO),D3_COD, ISNULL(SUM(D3_QUANT),0) as QUANT
    FROM %table:SD3%  SD3
    LEFT OUTER JOIN %table:Z02%  Z02 ON  Z02_FILIAL=%xFilial:Z02% AND Z02_COD=D3_COD AND 
    SUBSTRING(Z02_DTDE,1,6)=SUBSTRING(D3_EMISSAO,1,6) AND Z02.%NotDel%
    WHERE D3_FILIAL=%xFilial:SD3%
    AND D3_EMISSAO>=%Exp:datade% AND D3_EMISSAO<=%Exp:dataate% 
    AND LEFT(D3_CF,2)='PR' AND D3_TIPO='PA' 
    AND SD3.%NotDel% AND D3_COD LIKE (%Exp:tipo%) AND D3_ESTORNO<>'S'
    GROUP BY  Z02_DTDE,MONTH(D3_EMISSAO),D3_COD
    ORDER BY D3_COD
   EndSql
ENDIF  
dbselectArea(cAliasSTC)
(cAliasSTC)->(dbgotop())
Do while !eof()
  aret+=(cAliasSTC)->QUANT * Posicione("Z02",1,xfilial("Z02")+(cAliasSTC)->D3_COD+iif(mmes=="12",(cAliasSTC)->Z02_DTDE,datade),"Z02_CUSTO")
  dbskip()
Enddo
dbclosearea(cAliasSTC)

//DIMINUIR O VALOR DO RETRABALHO
cAliasSTC := GetNextAlias()
IF mmes<>"12"
 BeginSql Alias cAliasSTC  
   SELECT D3_COD, ISNULL(SUM(D3_QUANT),0) as QUANT FROM %table:SD3% SD3 
   WHERE D3_FILIAL=%xFilial:SD3% 
   AND D3_EMISSAO>=%Exp:datade% AND D3_EMISSAO<=%Exp:dataate% 
   AND D3_CF IN ('RE2','RE1') AND D3_TIPO='PA' 
   AND SD3.%NotDel% AND D3_COD LIKE (%Exp:tipo%) AND D3_ESTORNO<>'S'
   GROUP BY D3_COD
   ORDER BY D3_COD
 EndSql
ELSE
   BeginSql Alias cAliasSTC
    SELECT Z02_DTDE,MONTH(D3_EMISSAO),D3_COD, ISNULL(SUM(D3_QUANT),0) as QUANT
    FROM %table:SD3%  SD3
    LEFT OUTER JOIN %table:Z02%  Z02 ON  Z02_FILIAL=%xFilial:Z02% AND Z02_COD=D3_COD AND 
    SUBSTRING(Z02_DTDE,1,6)=SUBSTRING(D3_EMISSAO,1,6) AND Z02.%NotDel%
    WHERE D3_FILIAL=%xFilial:SD3%
    AND D3_EMISSAO>=%Exp:datade% AND D3_EMISSAO<=%Exp:dataate% 
    AND D3_CF IN ('RE2','RE1') AND D3_TIPO='PA' 
    AND SD3.%NotDel% AND D3_COD LIKE (%Exp:tipo%) AND D3_ESTORNO<>'S'
    GROUP BY  Z02_DTDE,MONTH(D3_EMISSAO),D3_COD
    ORDER BY D3_COD
   EndSql
ENDIF  
dbselectArea(cAliasSTC)
(cAliasSTC)->(dbgotop())
Do while !eof()
  aret -=(cAliasSTC)->QUANT * Posicione("Z02",1,xfilial("Z02")+(cAliasSTC)->D3_COD+iif(mmes=="12",(cAliasSTC)->Z02_DTDE,datade),"Z02_CUSTO")
  dbskip()
Enddo
dbclosearea(cAliasSTC)
Return(aret)


Static Function aRetStq(cta_oi,cta_oF,orc,ver,per,cci,ccf)
Local aret:=0
Local cAliasSTC := GetNextAlias()
Local orcamento, periodo
if len(alltrim(cci))==0
  cci:=''
  ccf:='ZZZZZZZZ'
endif
periodo:=MV_PAR06+strzero(per,2)+"01" 
orcamento:=alltrim(cta_oi)+'%'
if per<13
 BeginSql Alias cAliasSTC  
   SELECT ISNULL(SUM(AK2_VALOR),0) as VALOR FROM %table:AK2% AK2 
   WHERE AK2_FILIAL=%xFilial:AK2% AND AK2_ORCAME=%Exp:orc% AND AK2_VERSAO=%Exp:ver% 
   AND AK2_CO>=%Exp:cta_oi% AND AK2_CO<=%Exp:cta_of%  AND AK2_PERIOD=%Exp:periodo% AND AK2.%NotDel%
   AND AK2_CC>=%Exp:cci% and AK2_CC<=%Exp:ccf% AND AK2_CO NOT IN ('4010101099','4010202099','4210201100','4210202100','4210301100') 
 EndSql
else
  BeginSql Alias cAliasSTC 
   SELECT ISNULL(SUM(AK2_VALOR),0) as VALOR FROM %table:AK2% AK2 
   WHERE AK2_FILIAL=%xFilial:AK2% AND AK2_ORCAME=%Exp:orc% AND AK2_VERSAO=%Exp:ver% 
   AND AK2_CO>=%Exp:cta_oi% AND AK2_CO<=%Exp:cta_of%  AND substring(AK2_PERIOD,1,4)=substring(%Exp:periodo%,1,4) AND AK2.%NotDel%
   AND AK2_CC>=%Exp:cci% and AK2_CC<=%Exp:ccf% AND AK2_CO NOT IN ('4010101099','4010202099','4210201100','4210202100','4210301100')
  EndSql 
endif 
dbselectArea(cAliasSTC)
(cAliasSTC)->(dbgotop())
aret:=(cAliasSTC)->valor
dbclosearea(cAliasSTC)   
Return(aret)


Static Function aRetDif(cVger,cCodvg,nMes,nVal)
Local aret
Local nreal:=0
Local nOrc := 0
 aret:=aRetCT2(cVger,cCodvg,nMes,nVal)
 nreal:= iif(aret==0,1,aret)
 nOrc :=  aRetOrc(cVger,cCodvg,nMes,nVal)
 aret:=aret + nOrc
 aadd(nPerc,{cCodvg,strzero(nMes,2), iif(nOrc==0, 1, aret/nOrc)})
Return(aret)


Static Function aRetPerc(cCodvg,nMes)
Local aret:=0
 nPos:=aScan(nPerc, { |x| x[1]+x[2] == cCodvg+strzero(nMes,2) }) 
 if nPos<>0
  aret := nPerc[nPos][3]
 endif
Return(aret)


Static Function ValidPerg(cPerg)
    PutSX1(cPerg,"01","Livro  ?"        , "", "", "mv_ch1", "C", 3 ,00,00,"G",""    ,"CVF","","","mv_par01")
    PutSX1(cPerg,"02","Somente Real ?" , "", "", "mv_ch2" , "N", 1 ,00,00,"C",""    ,"   ","","","mv_par02","Sim","Si","Yes","","Nâo","Non","No")
    PutSX1(cPerg,"03","Orcamento  ?"    , "", "", "mv_ch3", "C", 15,00,00,"G",""    ,"   ","","","mv_par03")
    PutSX1(cPerg,"04","Versao  ?"       , "", "", "mv_ch4", "C", 4 ,00,00,"G",""    ,"   ","","","mv_par04")
    PutSX1(cPerg,"05","Ano Referencia ?", "", "", "mv_ch5", "C", 4 ,00,00,"G",""    ,"   ","","","mv_par05")
    PutSX1(cPerg,"06","Ano Orcamento  ?", "", "", "mv_ch6", "C", 4 ,00,00,"G",""    ,"   ","","","mv_par06")
    PutSX1(cPerg,"07","Entidade Inicio ?", "", "", "mv_ch7", "C", 20 ,00,00,"G",""    ,"CVF","","","mv_par07")
    PutSX1(cPerg,"08","Entidade Final  ?", "", "", "mv_ch8", "C", 20 ,00,00,"G",""    ,"CVF","","","mv_par08")
Return Nil 