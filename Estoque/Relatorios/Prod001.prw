#Include 'Protheus.ch'

User Function Prod001()
 Local aSize := {}
 Local bOk := {|| ProdDef() }
 Local bCancel:= {|| Fechar() }
 Local cTitle:="Relação de Produção por Periodo"
 

 Local oOk      := LoadBitmap( GetResources(), "LBOK" )
 Local oNo      := LoadBitmap( GetResources(), "LBNO" )
 Local lCheck := .f.
 Private oListAno,oCheck1,oCheck2,oCheck3
 Private oListMes
 Private nListAno 
 Private lChk1:=.F.
 Private lChk2:=.T. 
 Private lChk3:=.F.
 Private cWhere :="%"
 Private nListMes := month(ddatabase)
 Private aListAno := {{.f.,"2010"},{.f.,"2011"}, {.f.,"2012"}, {.f.,"2013"}, {.f.,"2014"}, {.f.,"2015"}, {.f.,"2016"}, {.f.,"2017"}, {.f.,"2018"}, {.f.,"2019"}, {.f.,"2020"}, {.f.,"2021"}, {.f.,"2022"}, {.f.,"2023"}, {.f.,"2024"}, {.f.,"2025"}}
 Private aListMes := {{.f.,"Janeiro"}, {.f.,"Fevereiro"},{.f.,"Marco"},{.f.,"Abril"},{.f.,"Maio"},{.f.,"Junho"},{.f.,"Julho"},{.f.,"Agosto"},{.f.,"Setembro"},{.f.,"Outubro"},{.f.,"Novembro"},{.f.,"Dezembro"}}
 nListAno :=aScan(aListAno,{|x| AllTrim(x[2])==str(year(ddatabase),4)})
 aListAno[nListAno,1]:=.t.
 aListMes[nListMes,1]:=.t. 
 aSize := MsAdvSize(.F.)
 /*
 MsAdvSize (http://tdn.totvs.com/display/public/mp/MsAdvSize+-+Dimensionamento+de+Janelas)
 aSize[1] = 1 -> Linha inicial área trabalho.
 aSize[2] = 2 -> Coluna inicial área trabalho.
 aSize[3] = 3 -> Linha final área trabalho.
 aSize[4] = 4 -> Coluna final área trabalho.
 aSize[5] = 5 -> Coluna final dialog (janela).
 aSize[6] = 6 -> Linha final dialog (janela).
 aSize[7] = 7 -> Linha inicial dialog (janela).
 */
 Define MsDialog oDlg TITLE cTitle STYLE DS_MODALFRAME From aSize[7],0 To 300,600 OF oMainWnd PIXEL
 
  @ 15,05 LISTBOX oListAno VAR nListAno FIELDS HEADER "","Ano da Producao" PIXEL SIZE 80,80 OF oDlg
 
  @ 15,100 LISTBOX oListMes VAR nListMes FIELDS HEADER "","Mes da Producao" PIXEL SIZE 100,80 OF oDlg 
  oListAno:SetArray( aListAno ) 
  oListAno:bLine := {|| {Iif(aListAno[oListAno:nAt,1],oOk,oNo),;
					aListAno[oListAno:nAt,2] } }
 oListAno:blDblClick 	:= {|| Escolher(1) }
 oListAno:cToolTip		:= "Duplo click para marcar/desmarcar o Ano de Producao"
 oListAno:Refresh()
 oListMes:SetArray( aListMes )
 oListMes:blDblClick 	:= {|| Escolher(2) }
 oListMes:cToolTip		:= "Duplo click para marcar/desmarcar o Mes de Producao"
 oListMes:bLine := {||  {Iif(aListMes[oListMes:nAt,1],oOk,oNo),;
 	                       aListMes[oListMes:nAt,2]} }
 oListMes:Refresh()
 
 //oCheck1 := TCheckBox():Create( oDlg,{||lCheck},100,10,'Relacao Anual',100,80,,,,,,,,.T.,,,)
 //oCheck2 := TCheckBox():Create( oDlg,{||lCheck},100,100,'Relaçao Mensal',100,80,,,,,,,,.T.,,,)
 
 @ 100,10   CheckBox oCheck1 Var lChk1 Prompt 'Relacao Anual'     On Click ( ChecBox(1) ) Size 100,10 Of oDlg Pixel 
 @ 100,100  CheckBox oCheck2 Var lChk2 Prompt 'Relaçao Mensal'    On Click ( ChecBox(2) ) Size 100,10 Of oDlg Pixel
 @ 110,10   CheckBox oCheck3 Var lChk3 Prompt 'Com o Retrabalho'  Size 100,10 Of oDlg Pixel 
 
 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bOk , bCancel) CENTERED

 
Return


Static Function ProdDef()
  Local oReport
  Private cTitler        
  Private anomes
  Private mes,dia
  oReport:= ReportDef()
  oReport:PrintDialog()
Return

Static Function ReportDef()
//-- Variaveis Locais
Local oReport 
Local oSection1 
Local oCell         
Local oBreak
Local cPerg :=''
Local cAliasPr0    := GetNextAlias()	//-- Alias do arquivo 
Local cTitle,nLoop

nListAno :=aScan(aListAno,{|x| x[1]}) //procura onde esta marcado
nListMes :=aScan(aListMes,{|x| x[1]})  //procura onde esta marcado   
anomes := aListAno[nListAno,2]
mes := "4" 
dia := "6" 
if lChk2
  anomes = anomes+strzero(nListMes,2)		 
  mes = "6"
  dia = "8" 
  cTitle:="Produção Mensal Gama"
else
  cTitle:="Produção Anual Gama"
endif

if !lChk3
 cWhere += " AND (SELECT D3_QUANT FROM SD3010 SD3R  " 
 cWhere += " WHERE SD3R.D3_FILIAL=SD3.D3_FILIAL AND SD3R.D3_DOC=SD3.D3_DOC AND SD3R.D3_NUMSEQ=SD3.D3_NUMSEQ"  
 cWhere += " AND SD3R.D3_CF='RE1'AND SD3R.D3_COD=SD3.D3_COD " 
 cWhere += " ) IS NULL "
endif
cWhere +="%"

oReport := TReport():New("PROD001",cTitle,cPerg, {|oReport| ReportPrint(oReport,cAliasPr0  )},cTitle) 
oReport:SetLandscape() 
oReport:SetDevice(4) //1-Arquivo,2-Impressora,3-email,4-Planilha e 5-Html
oSection1:= TRSection():New(oReport,"Producao",{cAliasPr0},/*aOrdem*/)
oSection1:SetHeaderPage()
TRCell():New(oSection1,"MODELO"  ,"  ","Modelo" ,/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/,/*Alinhamento*/)
TRCell():New(oSection1,"DESCRI" ,"  ","Descrição" ,/*Picture*/,40,/*lPixel*/,/*{|| code-block de impressao }*/,/*Alinhamento*/)
TRCell():New(oSection1,"TP"   ,"  ","Tipo" ,/*Picture*/,10,/*lPixel*/,/*{|| code-block de impressao }*/,/*Alinhamento*/)
TRCell():New(oSection1,"PLN"  ,"SD3","Plano" ,PesqPict("SD3","D3_QUANT" ),20,/*lPixel*/,/*{|| code-block de impressao }*/,/*Alinhamento*/)
TRCell():New(oSection1,"PROD" ,"SD3","Produzido" ,PesqPict("SD3","D3_QUANT" ),20,/*lPixel*/,/*{|| code-block de impressao }*/,/*Alinhamento*/)

nTam := iif(lChk2,31,12)
For nLoop := 1 To nTam
   cCamp:="DIA"+strzero(nLoop,2)
   TRCell():New(oSection1,cCamp ,"SD3",iif(lChk1,aListMes[nLoop,2],"Dia "+strzero(nLoop,2)),PesqPict("SD3","D3_QUANT" ),20,/*lPixel*/,/*{|| code-block de impressao }*/,/*Alinhamento*/)
Next

Return(oReport)


Static Function ReportPrint(oReport, cAliasPr0)
Local oSection1 := oReport:Section(1)                    
//cria uma celula com o titulo do relatorio -------------------------------
oReport:XlsNewRow(.t.)
oReport:XlsNewStyle("TIT","TIT",2,{"ARIAL",14},,.f.,"C")
oReport:XlsNewCell(oReport:Title(),.f.,2,"TIT",10,20,"C") 
//-------------------------------------------------------------------------
oSection1:BeginQuery()	
BeginSql Alias cAliasPr0
SELECT DISTINCT  SD3P.D3_COD AS MODELO,SB1.B1_DESC AS DESCRI,SD3P.D3_TIPO AS TP, 
ISNULL ((SELECT SUM(HC_QUANT) FROM %table:SHC% SHC WHERE HC_FILIAL=SD3P.D3_FILIAL AND  SHC.HC_PRODUTO=SD3P.D3_COD  AND SUBSTRING(HC_DATA,1,%Exp:val(mes)%)=%Exp:anomes% AND SHC.D_E_L_E_T_<>'*'),0) PLN,  
ISNULL ((SELECT SUM(D3_QUANT) FROM %table:SD3% SD3 WHERE D3_FILIAL='01'  
AND SD3.D3_COD=SD3P.D3_COD AND SUBSTRING(D3_EMISSAO,1,%Exp:val(mes)%)=%Exp:anomes% AND D3_TM='200' AND SD3.D_E_L_E_T_<>'*' AND D3_ESTORNO<>'S' %Exp:cWhere%  ),0) PROD,
ISNULL ((SELECT SUM(D3_QUANT) FROM %table:SD3% SD3 WHERE D3_FILIAL='01'  
AND SD3.D3_COD=SD3P.D3_COD AND SUBSTRING(D3_EMISSAO,1,%Exp:val(dia)%)=%Exp:anomes+'01'% AND D3_TM='200' AND SD3.D_E_L_E_T_<>'*' AND D3_ESTORNO<>'S'  %Exp:cWhere%  ),0) DIA01, 
ISNULL ((SELECT SUM(D3_QUANT) FROM %table:SD3% SD3 WHERE D3_FILIAL='01'  
AND SD3.D3_COD=SD3P.D3_COD AND SUBSTRING(D3_EMISSAO,1,%Exp:val(dia)%)=%Exp:anomes+'02'% AND D3_TM='200' AND SD3.D_E_L_E_T_<>'*' AND D3_ESTORNO<>'S'  %Exp:cWhere%  ),0) DIA02,
ISNULL ((SELECT SUM(D3_QUANT) FROM %table:SD3% SD3 WHERE D3_FILIAL='01'   
AND SD3.D3_COD=SD3P.D3_COD AND SUBSTRING(D3_EMISSAO,1,%Exp:val(dia)%)=%Exp:anomes+'03'% AND D3_TM='200' AND SD3.D_E_L_E_T_<>'*' AND D3_ESTORNO<>'S'  %Exp:cWhere% ),0) DIA03, 
ISNULL ((SELECT SUM(D3_QUANT) FROM %table:SD3% SD3 WHERE D3_FILIAL='01'   
AND SD3.D3_COD=SD3P.D3_COD AND SUBSTRING(D3_EMISSAO,1,%Exp:val(dia)%)=%Exp:anomes+'04'% AND D3_TM='200' AND SD3.D_E_L_E_T_<>'*' AND D3_ESTORNO<>'S'  %Exp:cWhere% ),0) DIA04, 
ISNULL ((SELECT SUM(D3_QUANT) FROM %table:SD3% SD3 WHERE D3_FILIAL='01'  
AND SD3.D3_COD=SD3P.D3_COD AND SUBSTRING(D3_EMISSAO,1,%Exp:val(dia)%)=%Exp:anomes+'05'% AND D3_TM='200' AND SD3.D_E_L_E_T_<>'*' AND D3_ESTORNO<>'S'  %Exp:cWhere% ),0) DIA05, 
ISNULL ((SELECT SUM(D3_QUANT) FROM %table:SD3% SD3 WHERE D3_FILIAL='01'  
AND SD3.D3_COD=SD3P.D3_COD AND SUBSTRING(D3_EMISSAO,1,%Exp:val(dia)%)=%Exp:anomes+'06'% AND D3_TM='200' AND SD3.D_E_L_E_T_<>'*' AND D3_ESTORNO<>'S'  %Exp:cWhere% ),0) DIA06, 
ISNULL ((SELECT SUM(D3_QUANT) FROM %table:SD3% SD3 WHERE D3_FILIAL='01'   
AND SD3.D3_COD=SD3P.D3_COD AND SUBSTRING(D3_EMISSAO,1,%Exp:val(dia)%)=%Exp:anomes+'07'% AND D3_TM='200' AND SD3.D_E_L_E_T_<>'*' AND D3_ESTORNO<>'S'  %Exp:cWhere% ),0) DIA07, 
ISNULL ((SELECT SUM(D3_QUANT) FROM %table:SD3% SD3 WHERE D3_FILIAL='01'  
AND SD3.D3_COD=SD3P.D3_COD AND SUBSTRING(D3_EMISSAO,1,%Exp:val(dia)%)=%Exp:anomes+'08'% AND D3_TM='200' AND SD3.D_E_L_E_T_<>'*' AND D3_ESTORNO<>'S'  %Exp:cWhere% ),0) DIA08, 
ISNULL ((SELECT SUM(D3_QUANT) FROM %table:SD3% SD3 WHERE D3_FILIAL='01'  
AND SD3.D3_COD=SD3P.D3_COD AND SUBSTRING(D3_EMISSAO,1,%Exp:val(dia)%)=%Exp:anomes+'09'% AND D3_TM='200' AND SD3.D_E_L_E_T_<>'*' AND D3_ESTORNO<>'S'  %Exp:cWhere% ),0) DIA09, 
ISNULL ((SELECT SUM(D3_QUANT) FROM %table:SD3% SD3 WHERE D3_FILIAL='01'  
AND SD3.D3_COD=SD3P.D3_COD AND SUBSTRING(D3_EMISSAO,1,%Exp:val(dia)%)=%Exp:anomes+'10'% AND D3_TM='200' AND SD3.D_E_L_E_T_<>'*' AND D3_ESTORNO<>'S'  %Exp:cWhere% ),0) DIA10, 
ISNULL ((SELECT SUM(D3_QUANT) FROM %table:SD3% SD3 WHERE D3_FILIAL='01' 
AND SD3.D3_COD=SD3P.D3_COD AND SUBSTRING(D3_EMISSAO,1,%Exp:val(dia)%)=%Exp:anomes+'11'% AND D3_TM='200' AND SD3.D_E_L_E_T_<>'*' AND D3_ESTORNO<>'S'  %Exp:cWhere% ),0) DIA11, 
ISNULL ((SELECT SUM(D3_QUANT) FROM %table:SD3% SD3 WHERE D3_FILIAL='01'    
AND SD3.D3_COD=SD3P.D3_COD AND SUBSTRING(D3_EMISSAO,1,%Exp:val(dia)%)=%Exp:anomes+'12'% AND D3_TM='200' AND SD3.D_E_L_E_T_<>'*' AND D3_ESTORNO<>'S'  %Exp:cWhere% ),0) DIA12, 
ISNULL ((SELECT SUM(D3_QUANT) FROM %table:SD3% SD3 WHERE D3_FILIAL='01' 
AND SD3.D3_COD=SD3P.D3_COD AND SUBSTRING(D3_EMISSAO,1,%Exp:val(dia)%)=%Exp:anomes+'13'% AND D3_TM='200' AND SD3.D_E_L_E_T_<>'*' AND D3_ESTORNO<>'S'  %Exp:cWhere% ),0) DIA13, 
ISNULL ((SELECT SUM(D3_QUANT) FROM %table:SD3% SD3 WHERE D3_FILIAL='01'   
AND SD3.D3_COD=SD3P.D3_COD AND SUBSTRING(D3_EMISSAO,1,%Exp:val(dia)%)=%Exp:anomes+'14'% AND D3_TM='200' AND SD3.D_E_L_E_T_<>'*' AND D3_ESTORNO<>'S'  %Exp:cWhere% ),0) DIA14, 
ISNULL ((SELECT SUM(D3_QUANT) FROM %table:SD3% SD3 WHERE D3_FILIAL='01'   
AND SD3.D3_COD=SD3P.D3_COD AND SUBSTRING(D3_EMISSAO,1,%Exp:val(dia)%)=%Exp:anomes+'15'% AND D3_TM='200' AND SD3.D_E_L_E_T_<>'*' AND D3_ESTORNO<>'S'  %Exp:cWhere% ),0) DIA15, 
ISNULL ((SELECT SUM(D3_QUANT) FROM %table:SD3% SD3 WHERE D3_FILIAL='01'   
AND SD3.D3_COD=SD3P.D3_COD AND SUBSTRING(D3_EMISSAO,1,%Exp:val(dia)%)=%Exp:anomes+'16'% AND D3_TM='200' AND SD3.D_E_L_E_T_<>'*' AND D3_ESTORNO<>'S'  %Exp:cWhere% ),0) DIA16, 
ISNULL ((SELECT SUM(D3_QUANT) FROM %table:SD3% SD3 WHERE D3_FILIAL='01'   
AND SD3.D3_COD=SD3P.D3_COD AND SUBSTRING(D3_EMISSAO,1,%Exp:val(dia)%)=%Exp:anomes+'17'% AND D3_TM='200' AND SD3.D_E_L_E_T_<>'*' AND D3_ESTORNO<>'S'  %Exp:cWhere% ),0) DIA17, 
ISNULL ((SELECT SUM(D3_QUANT) FROM %table:SD3% SD3 WHERE D3_FILIAL='01'  
AND SD3.D3_COD=SD3P.D3_COD AND SUBSTRING(D3_EMISSAO,1,%Exp:val(dia)%)=%Exp:anomes+'18'% AND D3_TM='200' AND SD3.D_E_L_E_T_<>'*' AND D3_ESTORNO<>'S'  %Exp:cWhere% ),0) DIA18, 
ISNULL ((SELECT SUM(D3_QUANT) FROM %table:SD3% SD3 WHERE D3_FILIAL='01'   
AND SD3.D3_COD=SD3P.D3_COD AND SUBSTRING(D3_EMISSAO,1,%Exp:val(dia)%)=%Exp:anomes+'19'% AND D3_TM='200' AND SD3.D_E_L_E_T_<>'*' AND D3_ESTORNO<>'S'  %Exp:cWhere% ),0) DIA19, 
ISNULL ((SELECT SUM(D3_QUANT) FROM %table:SD3% SD3 WHERE D3_FILIAL='01'  
AND SD3.D3_COD=SD3P.D3_COD AND SUBSTRING(D3_EMISSAO,1,%Exp:val(dia)%)=%Exp:anomes+'20'% AND D3_TM='200' AND SD3.D_E_L_E_T_<>'*' AND D3_ESTORNO<>'S'  %Exp:cWhere% ),0) DIA20, 
ISNULL ((SELECT SUM(D3_QUANT) FROM %table:SD3% SD3 WHERE D3_FILIAL='01'  
AND SD3.D3_COD=SD3P.D3_COD AND SUBSTRING(D3_EMISSAO,1,%Exp:val(dia)%)=%Exp:anomes+'21'% AND D3_TM='200' AND SD3.D_E_L_E_T_<>'*' AND D3_ESTORNO<>'S'  %Exp:cWhere% ),0) DIA21, 
ISNULL ((SELECT SUM(D3_QUANT) FROM %table:SD3% SD3 WHERE D3_FILIAL='01'   
AND SD3.D3_COD=SD3P.D3_COD AND SUBSTRING(D3_EMISSAO,1,%Exp:val(dia)%)=%Exp:anomes+'22'% AND D3_TM='200' AND SD3.D_E_L_E_T_<>'*' AND D3_ESTORNO<>'S'  %Exp:cWhere% ),0) DIA22, 
ISNULL ((SELECT SUM(D3_QUANT) FROM %table:SD3% SD3 WHERE D3_FILIAL='01'   
AND SD3.D3_COD=SD3P.D3_COD AND SUBSTRING(D3_EMISSAO,1,%Exp:val(dia)%)=%Exp:anomes+'23'% AND D3_TM='200' AND SD3.D_E_L_E_T_<>'*' AND D3_ESTORNO<>'S'  %Exp:cWhere% ),0) DIA23, 
ISNULL ((SELECT SUM(D3_QUANT) FROM %table:SD3% SD3 WHERE D3_FILIAL='01'  
AND SD3.D3_COD=SD3P.D3_COD AND SUBSTRING(D3_EMISSAO,1,%Exp:val(dia)%)=%Exp:anomes+'24'% AND D3_TM='200' AND SD3.D_E_L_E_T_<>'*' AND D3_ESTORNO<>'S'  %Exp:cWhere% ),0) DIA24, 
ISNULL ((SELECT SUM(D3_QUANT) FROM %table:SD3% SD3 WHERE D3_FILIAL='01'   
AND SD3.D3_COD=SD3P.D3_COD AND SUBSTRING(D3_EMISSAO,1,%Exp:val(dia)%)=%Exp:anomes+'25'% AND D3_TM='200' AND SD3.D_E_L_E_T_<>'*' AND D3_ESTORNO<>'S'  %Exp:cWhere% ),0) DIA25, 
ISNULL ((SELECT SUM(D3_QUANT) FROM %table:SD3% SD3 WHERE D3_FILIAL='01'   
AND SD3.D3_COD=SD3P.D3_COD AND SUBSTRING(D3_EMISSAO,1,%Exp:val(dia)%)=%Exp:anomes+'26'% AND D3_TM='200' AND SD3.D_E_L_E_T_<>'*' AND D3_ESTORNO<>'S'  %Exp:cWhere% ),0) DIA26, 
ISNULL ((SELECT SUM(D3_QUANT) FROM %table:SD3% SD3 WHERE D3_FILIAL='01'   
AND SD3.D3_COD=SD3P.D3_COD AND SUBSTRING(D3_EMISSAO,1,%Exp:val(dia)%)=%Exp:anomes+'27'% AND D3_TM='200' AND SD3.D_E_L_E_T_<>'*' AND D3_ESTORNO<>'S'  %Exp:cWhere% ),0) DIA27, 
ISNULL ((SELECT SUM(D3_QUANT) FROM %table:SD3% SD3 WHERE D3_FILIAL='01'  
AND SD3.D3_COD=SD3P.D3_COD AND SUBSTRING(D3_EMISSAO,1,%Exp:val(dia)%)=%Exp:anomes+'28'% AND D3_TM='200' AND SD3.D_E_L_E_T_<>'*' AND D3_ESTORNO<>'S'  %Exp:cWhere% ),0) DIA28, 
ISNULL ((SELECT SUM(D3_QUANT) FROM %table:SD3% SD3 WHERE D3_FILIAL='01'   
AND SD3.D3_COD=SD3P.D3_COD AND SUBSTRING(D3_EMISSAO,1,%Exp:val(dia)%)=%Exp:anomes+'29'% AND D3_TM='200' AND SD3.D_E_L_E_T_<>'*' AND D3_ESTORNO<>'S'  %Exp:cWhere% ),0) DIA29, 
ISNULL ((SELECT SUM(D3_QUANT) FROM %table:SD3% SD3 WHERE D3_FILIAL='01'  
AND SD3.D3_COD=SD3P.D3_COD AND SUBSTRING(D3_EMISSAO,1,%Exp:val(dia)%)=%Exp:anomes+'30'% AND D3_TM='200' AND SD3.D_E_L_E_T_<>'*' AND D3_ESTORNO<>'S'  %Exp:cWhere% ),0) DIA30, 
ISNULL ((SELECT SUM(D3_QUANT) FROM %table:SD3% SD3 WHERE D3_FILIAL='01' 
AND SD3.D3_COD=SD3P.D3_COD AND SUBSTRING(D3_EMISSAO,1,%Exp:val(dia)%)=%Exp:anomes+'31'% AND D3_TM='200' AND SD3.D_E_L_E_T_<>'*' AND D3_ESTORNO<>'S'  %Exp:cWhere% ),0) DIA31 
FROM %table:SD3% SD3P,%table:SB1% SB1 WHERE SD3P.D3_FILIAL='01' AND SUBSTRING(SD3P.D3_EMISSAO,1,%Exp:val(mes)%)=%Exp:anomes% AND SD3P.D3_COD<>'ZZZZZZZZZZZZZZZ'  AND SD3P.D3_TM='200' 
 AND SD3P.D3_ESTORNO<>'S' AND SD3P.D_E_L_E_T_<>'*'  
AND B1_COD=D3_COD AND SB1.D_E_L_E_T_<>'*' 
ORDER BY SD3P.D3_TIPO,SD3P.D3_COD 
EndSql     


	aLastQuery    := GetLastQuery()
   cLastQuery    := aLastQuery[2]

oSection1:EndQuery(/*Array com os parametros do tipo Range*/)

dbSelectArea(cAliasPr0) 
Count to nRecSra 
dbgotop()     
oReport:SetMeter(nRecSra)

If !(cAliasPr0)->(Eof())
 oSection1:Init() 
 While !oReport:Cancel() .And. !(cAliasPr0)->(Eof())
    oReport:IncMeter()
    If oReport:Cancel()
	 Exit
    EndIf
    oSection1:PrintLine()
    dbSelectArea(cAliasPr0)
   dbSkip()
 Enddo   
Endif
oSection1:Finish()
oReport:EndPage() 
dbSelectArea(cAliasPr0)
dbCloseArea()
 
Return Nil

Static Function ChecBox(nbox)
 lChk1:=iif(nbox==1,.T.,.F.)
 lChk2:=iif(nbox==2,.T.,.F.)
 oCheck1:Refresh()
 oCheck2:Refresh()
Return


Static Function Escolher(nbox)
Local nLoop
 For nLoop := 1 To Len(iif(nbox==1,aListAno,aListMes))
    if nbox==1
	 aListAno[nLoop,1] := .f.
	else
	 aListMes[nLoop,1] := .f.
	endif
 Next
 if nbox==1
  aListAno[oListAno:nAt,1] := .t.
  nListAno:=oListAno:nAt
  oListAno:Refresh()
 else
  aListMes[oListMes:nAt,1] := .t.
  nListMes:=oListMes:nAt
  oListMes:Refresh()
 endif 
 
Return



Static Function Fechar()
 oDlg:End()
Return
