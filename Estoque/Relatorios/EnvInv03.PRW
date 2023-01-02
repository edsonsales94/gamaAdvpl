#include "protheus.ch"
#include "topconn.ch"

#include "protheus.ch"
*****************************************************************************************************************************************************
User Function envinv003()//divergencia de contagem no inventário
*****************************************************************************************************************************************************
Local oReport
If TRepInUse()	//verifica se relatorios personalizaveis esta disponivel
    cPerg:="ENVINV03"
    _VALIDPERG()
	Pergunte(cPerg,.F.)
	oReport := ReportDef()
	oReport:PrintDialog()
EndIf
Return
*****************************************************************************************************************************************************
Static Function ReportDef()
*****************************************************************************************************************************************************
Local oReport
Local oReport2
Local oSection1
Local oSection2

oReport := TReport():New("GAMA ITALY","Divergencia de Contagem de inventário",cPerg,{|oReport| PrintReport(oReport)},"Este relatorio ira imprimir a divergencia de Contagem .")

//oSection1 := TRSection():New(oReport,"Contagem",{"TPV","ZI0"})
oSection1 := TRSection():New(oReport,"Contagem",{"TPV","SZU"})
//TRPosition():New(oSection1,"ZI0",1,{|| xFilial("ZI0")+TPV->ZU_NUMDOC})
TRPosition():New(oSection1,"SZU",1,{|| xFilial("SZU")+TPV->ZU_NUMDOC})

TRCell():New(oSection1,"ZU_NUMDOC","TPV","Lista","@!",6)
TRCell():New(oSection1,"ZU_NUMETQ","TPV","Etiq.","@!",6)
TRCell():New(oSection1,"ZU_COD"   ,"TPV","Produto","@!",25)
TRCell():New(oSection1,"ZU_DESC"  ,"TPV","Descrição","@!",30)
TRCell():New(oSection1,"ZU_UM"    ,"TPV","UN"	,"@!",2)
TRCell():New(oSection1,"ZU_TIPO"  ,"TPV","TP","@!",2)
TRCell():New(oSection1,"ZU_LOCPAD","TPV","Local","@!",2)
TRCell():New(oSection1,"ZU_LOTECTL","TPV","Lote","@!",10)
TRCell():New(oSection1,"ZU_LOCALIZ","TPV","Endereço","@!",15)
TRCell():New(oSection1,"ZU_CONT1"  ,"TPV","Cont 1o","@e 999,999.9999",12)
TRCell():New(oSection1,"ZU_CONT2"  ,"TPV","Cont 2o","@e 999,999.9999",12)
TRCell():New(oSection1,"ZU_CONT3"  ,"TPV","cont 3o","@e 999,999.9999",12)
TRCell():New(oSection1,"ZU_DATA"   ,"TPV","Data","@!",12)
TRCell():New(oSection1,"ZU_ULTCONT","TPV","Ult.Cont","@e 9",1)
TRCell():New(oSection1,"ZU_ORIGEM" ,"TPV","Origem","@!",1)
TRCell():New(oSection1,"ZU_TIME"   ,"TPV","Hora","@!",5)

TRCell():New(oSection1,"ZU_GRUPO"  ,"TPV","Grupo","@!",4)
TRCell():New(oSection1,"ZU_RUA"    ,"TPV","Rua","@!",2)
TRCell():New(oSection1,"ZU_USUCT1" ,"TPV","1o User","@!",6)
TRCell():New(oSection1,"ZU_DATACT1","TPV","1o Data","@!",12)
TRCell():New(oSection1,"ZU_TIME01" ,"TPV","1o Hora","@!",5)

TRCell():New(oSection1,"ZU_USUCT2" ,"TPV","2o User","@!",6)
TRCell():New(oSection1,"ZU_DATACT2","TPV","2o Data","@!",12)
TRCell():New(oSection1,"ZU_TIME02" ,"TPV","2o Hora","@!",5)

TRCell():New(oSection1,"ZU_USUCT3" ,"TPV","3o User","@!",6)
TRCell():New(oSection1,"ZU_DATACT3","TPV","3o Data","@!",12)
TRCell():New(oSection1,"ZU_TIME03" ,"TPV","3o Time","@!",5)


TRCell():New(oSection1,"ZU_AUDNOM2","TPV","1o Auditor","@!",40)
TRCell():New(oSection1,"ZU_AUDMAT2","TPV","1o Matr.","@!",6)
TRCell():New(oSection1,"ZU_AUDDAT2","TPV","1o Data","@!",12)
TRCell():New(oSection1,"ZU_AUDTIM2","TPV","1o Hora","@!",5)

TRCell():New(oSection1,"ZU_AUDNOM3","TPV","2o Auditor","@!",40)
TRCell():New(oSection1,"ZU_AUDMAT3","TPV","2o Matr.","@!",6)
TRCell():New(oSection1,"ZU_AUDDAT3","TPV","2o Data","@!",12)
TRCell():New(oSection1,"ZU_AUDTIM3","TPV","2o Hora","@!",5)
//TRCell():New(oSection1,"ZI0_AREA"  ,"ZI0","AREA","@!",6) //REGINALDO
//TRCell():New(oSection1,"ZI0_OBS"   ,"ZI0","OBS","@!",40) // REGINALDO


//TRCell():New(oSection1,"ZU_SLD01","	float	no	8
//TRCell():New(oSection1,"ZU_SLD02","	float	no	8
//TRCell():New(oSection1,"ZU_SLD03","	float	no	8
//TRCell():New(oSection1,"ZU_DIF01","	float	no	8
//TRCell():New(oSection1,"ZU_DIF02","	float	no	8
//TRCell():New(oSection1,"ZU_DIF03","	float	no	8
//TRCell():New(oSection1,"ZU_STATUS","	varchar	no	30



oBreak1 := TRBreak():New(oSection1,oSection1:Cell("ZU_NUMDOC"),{ || "Sub-Total LISTA--> "},.F.)
TRFunction():New(oSection1:Cell("ZU_NUMDOC"),NIL,"COUNT",oBreak1)

oBreak2 := TRBreak():New(oSection1,oSection1:Cell("ZU_RUA"),{ || "Sub-Total RUA--> "},.F.)
TRFunction():New(oSection1:Cell("ZU_RUA"),NIL,"COUNT",oBreak2)

oBreak3 := TRBreak():New(oSection1,oSection1:Cell("ZU_LOCPAD"),{ || "Sub-Total ARM--> "},.F.)
TRFunction():New(oSection1:Cell("ZU_LOCPAD"),NIL,"COUNT",oBreak3)
oSection1:SetHeaderBreak(.T.)   //Imprime o cabecalho das celulas apos a quebra


//TRPosition(oSection2,"SB1",1,{|| xFilial("SB1") + SBH->BH_CODCOMP})
Return oReport
*****************************************************************************************************************************************************
Static Function PrintReport(oReport)
*****************************************************************************************************************************************************
Local oSection1 := oReport:Section(1)

/*
///
///O codigo abaixo foi substituido em funcao de e-mail datado em 24/11/10 - Patricia Lima
///Alteracao efetuada em 10/12/10
///
cQuery  :=" SELECT "
cQuery  +="  ZU_NUMETQ,ZU_COD,ZU_DESC,ZU_CODCLI,ZU_UM,ZU_TIPO,ZU_LOCPAD,ZU_FANTASM,ZU_CONT1,ZU_CONT2,ZU_CONT3,Substring(ZU_DATA,7,2)+'/'+Substring(ZU_DATA,5,2)+'/'+Substring(ZU_DATA,1,4) AS ZU_DATA,ZU_AJUSTE,ZU_LOCALIZ,ZU_CLIENTE,ZU_ULTCONT,ZU_ORIGEM,"
cQuery  +=   "ZU_TIME,ZU_NUMDOC,ZU_GRUPO,ZU_RUA,ZU_CLASSE,Substring(ZU_DATACT1,7,2)+'/'+Substring(ZU_DATACT1,5,2)+'/'+Substring(ZU_DATACT1,1,4) AS ZU_DATACT1,ZU_TIME01,ZU_LOTECTL,ZU_USUCT1,Substring(ZU_DATACT2,7,2)+'/'+Substring(ZU_DATACT2,5,2)+'/'+Substring(ZU_DATACT2,1,4) AS ZU_DATACT2,ZU_TIME02,ZU_USUCT2,ZU_AUDMAT2,ZU_AUDNOM2,"
cQuery  +=   "Substring(ZU_AUDDAT2,7,2)+'/'+Substring(ZU_AUDDAT2,5,2)+'/'+Substring(ZU_AUDDAT2,1,4) AS ZU_AUDDAT2,ZU_AUDTIM2,"
cQuery  +=   "Substring(ZU_DATACT3,7,2)+'/'+Substring(ZU_DATACT3,5,2)+'/'+Substring(ZU_DATACT3,1,4) AS ZU_DATACT3,ZU_TIME03,ZU_USUCT3,ZU_AUDMAT3,ZU_AUDNOM3,"
cQuery  +=   "Substring(ZU_AUDDAT3,7,2)+'/'+Substring(ZU_AUDDAT3,5,2)+'/'+Substring(ZU_AUDDAT3,1,4) AS ZU_AUDDAT3,ZU_AUDTIM3,ZU_DTINV1,ZU_DTINV2,ZU_DTINV3,ZU_SLD01,ZU_SLD02,ZU_SLD03,ZU_DIF01,ZU_DIF02,ZU_DIF03"

cQuery  +=" FROM " +RetSqlName("SZU")+" A "
cQuery  +=" WHERE  A.D_E_L_E_T_<>'*' AND "
cQuery  +=" ZU_FILIAL = '"+xFilial("SZU")+"' AND  "
cQuery  +=" ZU_ULTCONT = "+STRZERO(Mv_Par01+1,1)+" AND  "
cQuery  +=" ZU_DATA    = '"+DTOS(Mv_Par02)+"' AND  "
cQuery  +=" ZU_COD     BETWEEN  '"+Mv_Par03+"' AND  '"+Mv_Par04+"' AND  "
cQuery  +=" ZU_LOCALIZ BETWEEN  '"+Mv_Par05+"' AND  '"+Mv_Par06+"' AND  "
cQuery  +=" ZU_LOCPAD ='"+Mv_Par07+"' AND "
If Mv_Par01 = 1
   cQuery  +=" ZU_CONT1<>ZU_CONT2 ORDER BY ZU_FILIAL,ZU_LOCPAD,ZU_LOCALIZ,ZU_NUMDOC,ZU_RUA,ZU_COD"
Else
   cQuery  +=" ZU_CONT2<>ZU_CONT3 ORDER BY ZU_FILIAL,ZU_LOCPAD,ZU_LOCALIZ,ZU_NUMDOC,ZU_RUA,ZU_COD"
Endif
*/
cQuery  :=" SELECT "
cQuery  +="  ZU_NUMETQ,ZU_COD,ZU_DESC,ZU_CODCLI,ZU_UM,ZU_TIPO,ZU_LOCPAD,ZU_FANTASM,ZU_CONT1,ZU_CONT2,ZU_CONT3,Substring(ZU_DATA,7,2)+'/'+Substring(ZU_DATA,5,2)+'/'+Substring(ZU_DATA,1,4) AS ZU_DATA,ZU_AJUSTE,ZU_LOCALIZ,ZU_CLIENTE,ZU_ULTCONT,ZU_ORIGEM,"
cQuery  +=   "ZU_TIME,ZU_NUMDOC,ZU_GRUPO,ZU_RUA,ZU_CLASSE,Substring(ZU_DATACT1,7,2)+'/'+Substring(ZU_DATACT1,5,2)+'/'+Substring(ZU_DATACT1,1,4) AS ZU_DATACT1,ZU_TIME01,ZU_LOTECTL,ZU_USUCT1,Substring(ZU_DATACT2,7,2)+'/'+Substring(ZU_DATACT2,5,2)+'/'+Substring(ZU_DATACT2,1,4) AS ZU_DATACT2,ZU_TIME02,ZU_USUCT2,ZU_AUDMAT2,ZU_AUDNOM2,"
cQuery  +=   "Substring(ZU_AUDDAT2,7,2)+'/'+Substring(ZU_AUDDAT2,5,2)+'/'+Substring(ZU_AUDDAT2,1,4) AS ZU_AUDDAT2,ZU_AUDTIM2,"
cQuery  +=   "Substring(ZU_DATACT3,7,2)+'/'+Substring(ZU_DATACT3,5,2)+'/'+Substring(ZU_DATACT3,1,4) AS ZU_DATACT3,ZU_TIME03,ZU_USUCT3,ZU_AUDMAT3,ZU_AUDNOM3,"
cQuery  +=   "Substring(ZU_AUDDAT3,7,2)+'/'+Substring(ZU_AUDDAT3,5,2)+'/'+Substring(ZU_AUDDAT3,1,4) AS ZU_AUDDAT3,ZU_AUDTIM3,ZU_DTINV1,ZU_DTINV2,ZU_DTINV3,ZU_SLD01,ZU_SLD02,ZU_SLD03,ZU_DIF01,ZU_DIF02,ZU_DIF03"
//cQuery  += "   ZI2_SLDATU"

cQuery  +=" FROM " +RetSqlName("SZU")+" A"  ///,"+RetSqlName("ZI2")+ " B"
cQuery  +=" WHERE  A.D_E_L_E_T_<>'*' AND"    /// B.D_E_L_E_T_ = ' ' AND"
cQuery  +=" ZU_FILIAL  = '"+xFilial("SZU")+"' AND"
cQuery  +=" ZU_DATA    = '"+DTOS(Mv_Par02)+"' AND  "
cQuery  +=" ZU_COD     BETWEEN  '"+Mv_Par03+"' AND  '"+Mv_Par04+"' AND"
cQuery  +=" ZU_LOCALIZ BETWEEN  '"+Mv_Par05+"' AND  '"+Mv_Par06+"' AND"
cQuery  +=" ZU_LOCPAD ='"+Mv_Par07+"' AND "
//cQuery  +=" ZI2_FILIAL = ZU_FILIAL AND ZI2_COD = ZU_COD"
//cQuery  +=" AND ZI2_LOCAL = ZU_LOCPAD AND ZI2_DTINV = ZU_DATA AND ZI2_LOCALI = ZU_LOCALIZ AND"
If Mv_Par01 = 1
   cQuery  +=" ZU_ULTCONT > 0 AND"
   //cQuery  +=" ZU_ORIGEM  = 'C' AND"
   cQuery  +=" (ZU_ORIGEM  = 'S' OR ZU_ORIGEM  = 'B') AND "
   cQuery  +=" ZU_CONT1 <> ZU_SLD01 ORDER BY ZU_FILIAL,ZU_LOCPAD,ZU_LOCALIZ,ZU_NUMDOC,ZU_RUA,ZU_COD"
ElseIf Mv_Par01 = 2
   cQuery  +=" ZU_ULTCONT > 1 AND"
   cQuery  +=" ZU_CONT1 <> ZU_CONT2 ORDER BY ZU_FILIAL,ZU_LOCPAD,ZU_LOCALIZ,ZU_NUMDOC,ZU_RUA,ZU_COD"
Else
   cQuery  +=" ZU_ULTCONT > 2 AND"
   cQuery  +=" ZU_CONT2 <> ZU_CONT3 ORDER BY ZU_FILIAL,ZU_LOCPAD,ZU_LOCALIZ,ZU_NUMDOC,ZU_RUA,ZU_COD"
Endif

TCQUERY cQuery NEW ALIAS TPV
COUNT TO  nRegis
DbSelectArea("TPV")
DBGOTOP()
ProcRegua(nRegis)
oReport:SetMeter(RecCount())
oSection1:Init()
nRegCont:=0
While !Eof()
    nRegCont:=nRegCont+1
    IncProc("Reg =>"+StrZero(nRegCont,10)+" / "+strZero(nRegis,10))
	If oReport:Cancel()
		Exit
	EndIf
	oSection1:PrintLine()
	DbSelectArea("TPV")
	DbSkip()
	oReport:IncMeter()
End
oSection1:Finish()
DbSelectArea("TPV")
DbCloseArea()
Return
*****************************************************************************************************************************************************
Static Function _VALIDPERG()
*****************************************************************************************************************************************************
Local aHelpPor := {}
Local aHelpEng := {}
Local aHelpSpa := {}
cPerg          := PADR(cPerg,len(sx1->x1_grupo))

aHelpPor :={}
AAdd(aHelpPor,"Informe Contagem")
AAdd(aHelpPor,"1-Primeira; 2-Segunda; 3-Terceira ")  ///Alterado em 10/12/10 - vide e-mail
PutSx1(cPerg,"01","Contagem","Contagem","Contagem","mv_ch1","N",1,0,0,"C","","","","","MV_PAR01","1-Primeira","","","","2-Segunda","","","","","3-Terceira","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

aHelpPor :={}
AAdd(aHelpPor,"Informe data do Inventario")
AAdd(aHelpPor,"a ser Processada a divergencia")
PutSx1(cPerg,"02","Data do Inventário","Data do Inventário","Data do Inventário","mv_ch2","D",08,0,0,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

AAdd(aHelpPor,"Informe Produto Inicial")
AAdd(aHelpPor,"a ser Processado")
PutSx1(cPerg,"03","Produto Inicial","Produto Inicial","Produto Inicial","mv_ch3","C",25,0,0,"G","","","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

aHelpPor :={}
AAdd(aHelpPor,"Informe Produto Final")
AAdd(aHelpPor,"a ser Processado")
PutSx1(cPerg,"04","Produto Final","Produto Final","Produto Final","mv_ch4","C",25,0,0,"G","","","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

aHelpPor :={}
AAdd(aHelpPor,"Endereço Inicial")
AAdd(aHelpPor,"a ser Processado")
PutSx1(cPerg,"05","Endereço Inicial","Endereço Inicial","Endereço Inicial","mv_ch5","C",15,0,0,"G","","","","","MV_PAR05","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

aHelpPor :={}
AAdd(aHelpPor,"Endereço Final")
AAdd(aHelpPor,"a ser Processado")
PutSx1(cPerg,"06","Endereço Endereço Final","Endereço Final","Endereço Final","mv_ch6","C",15,0,0,"G","","","","","MV_PAR06","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)


aHelpPor :={}
AAdd(aHelpPor,"Local")
AAdd(aHelpPor,"a ser Processado")
PutSx1(cPerg,"07","Local","Local","Local","mv_ch7","C",02,0,0,"G","","","","","MV_PAR07","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

Return
