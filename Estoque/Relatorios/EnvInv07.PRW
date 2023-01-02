#include "protheus.ch"
#include "topconn.ch"

#include "protheus.ch"
*****************************************************************************************************************************************************
User Function envinv07()//divergencia de contagem no inventário 
*****************************************************************************************************************************************************
Local oReport
If TRepInUse()	//verifica se relatorios personalizaveis esta disponivel
    cPerg:="ENVINV07"
    //_VALIDPERG()    
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

oReport := TReport():New("ENVINV07","Estatistica de Contagem de inventário",cPerg,{|oReport| PrintReport(oReport)},"Este relatorio ira imprimir a divergencia de Contagem .")

oSection1 := TRSection():New(oReport,"Contagem",{"TPV"})

TRCell():New(oSection1,"ZI2_DTINV"  ,"TPV","Data"         ,"@!",3)
TRCell():New(oSection1,"ZI2_COD"    ,"TPV","Produto"      ,"@!",25)
TRCell():New(oSection1,"ZI2_DESC"   ,"TPV","Descrição"    ,"@!",40)
TRCell():New(oSection1,"ZI2_TIPO"   ,"TPV","TP."          ,"@!",3)
TRCell():New(oSection1,"ZI2_GRUPO"  ,"TPV","Grupo"        ,"@!",6)
TRCell():New(oSection1,"ZI2_UM"     ,"TPV","UN"           ,"@!",3)
TRCell():New(oSection1,"ZI2_RASTRO" ,"TPV","Rastro"       ,"@!",3)
TRCell():New(oSection1,"ZI2_CTLEND" ,"TPV","C.End."       ,"@!",3)
TRCell():New(oSection1,"ZI2_LOCAL"  ,"TPV","Arm."         ,"@!",3)
TRCell():New(oSection1,"ZI2_LOCALI" ,"TPV","Endereço"     ,"@!",16)
TRCell():New(oSection1,"ZI2_LOTE"   ,"TPV","Lote"         ,"@!",16)
TRCell():New(oSection1,"ZI2_ORIGEM" ,"TPV","Ori."         ,"@!",3)
TRCell():New(oSection1,"ZI2_CONT1"  ,"TPV","1o Contagem"  ,"@E 99,999,999.9999",16)
TRCell():New(oSection1,"ZI2_CONT2"  ,"TPV","2o Contagem"  ,"@E 99,999,999.9999",16)
TRCell():New(oSection1,"ZI2_CONT3"  ,"TPV","3o Contagem"  ,"@E 99,999,999.9999",16)
TRCell():New(oSection1,"ZI2_CONTAG" ,"TPV","Ult.Cont."    ,"@E 9999",4)
TRCell():New(oSection1,"ZI2_QRCON1" ,"TPV","Tot.(1o)Cont.","@E 99,999,999",10)
TRCell():New(oSection1,"ZI2_QRCON2" ,"TPV","Tot.(2o)Cont.","@E 99,999,999",10)
TRCell():New(oSection1,"ZI2_QRCON3" ,"TPV","Tot.(3o)Cont.","@E 99,999,999",10)
TRCell():New(oSection1,"ZI2_CM1"    ,"TPV","Custo Unit."  ,"@E 9,999,999.9999",16)
TRCell():New(oSection1,"ZI2_SLDATU" ,"TPV","Qtd. Atual"   ,"@E 999,999,999.9999",16)
TRCell():New(oSection1,"ZI2_QTDINV" ,"TPV","Qtd. Invent." ,"@E 999,999,999.9999",16)
TRCell():New(oSection1,"ZI2_QTDIFE" ,"TPV","Qtd. Difer."  ,"@E 999,999,999.9999",16)


oBreak1 := TRBreak():New(oSection1,oSection1:Cell("ZI2_LOCAL"),{ || "Total --> "},.F.)
TRFunction():New(oSection1:Cell("ZI2_COD"),NIL,"COUNT",oBreak1)
TRFunction():New(oSection1:Cell("ZI2_QRCON1"),NIL,"SUM",oBreak1)
TRFunction():New(oSection1:Cell("ZI2_QRCON2"),NIL,"SUM",oBreak1)
TRFunction():New(oSection1:Cell("ZI2_QRCON3"),NIL,"SUM",oBreak1)
TRFunction():New(oSection1:Cell("ZI2_SLDATU"),NIL,"SUM",oBreak1)
TRFunction():New(oSection1:Cell("ZI2_QTDINV"),NIL,"SUM",oBreak1) 
TRFunction():New(oSection1:Cell("ZI2_QTDIFE"),NIL,"SUM",oBreak1)


//TRPosition(oSection2,"SB1",1,{|| xFilial("SB1") + SBH->BH_CODCOMP})
Return oReport
*****************************************************************************************************************************************************
Static Function PrintReport(oReport)
*****************************************************************************************************************************************************
Local oSection1 := oReport:Section(1) 

cQuery  :="SELECT ZI2_FILIAL,ZI2_DTINV,ZI2_COD,ZI2_DESC,ZI2_TIPO,ZI2_GRUPO,ZI2_UM,ZI2_RASTRO,ZI2_CTLEND,ZI2_LOCAL,ZI2_LOCALI,ZI2_LOTE,ZI2_ORIGEM,ZI2_CONT1,ZI2_CONT2,ZI2_CONT3,ZI2_CONTAG,ZI2_QRCON1,ZI2_QRCON2,ZI2_QRCON3,ZI2_CM1,ZI2_SLDATU,ZI2_QTDINV,(ZI2_SLDATU-ZI2_QTDINV) AS ZI2_QTDIFE"
cQuery  +=" FROM "+Retsqlname("ZI2")+" WHERE D_E_L_E_T_<>'*' AND "
cQuery  +="ZI2_FILIAL = '"+MV_PAR08+"' AND "
cQuery  +="ZI2_DTINV = '"+DTOS(Mv_Par01)+"' AND "
cQuery  +="ZI2_LOCAL BETWEEN  '"+Mv_Par02+"' AND '"+Mv_Par03+"' AND " 
cQuery  +="ZI2_LOCALI  BETWEEN  '"+Mv_Par04+"' AND '"+Mv_Par05+"' AND "
cQuery  +="ZI2_LOTE    BETWEEN  '"+Mv_Par06+"' AND '"+Mv_Par07+"' "
cQuery  +="ORDER BY ZI2_FILIAL,ZI2_LOCAL,ZI2_LOCALI"

TCQUERY cQuery NEW ALIAS TPV
COUNT TO  nRegis 
DbSelectArea("TPV")
ProcRegua(nRegis)  
oReport:SetMeter(RecCount())
oSection1:Init()	
nRegCont:=0
DBGOTOP()  
While !Eof()
    /*
    IF TPV->ZI2_FILIAL<>xFilial("ZI2")
       TPV->(dbSkip())
       LOOP
    ENDIF  
    */
    
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
AAdd(aHelpPor,"Informe data do Inventario")
AAdd(aHelpPor,"a ser Processada a divergencia")
PutSx1(cPerg,"01","Data do Inventário","Data do Inventário","Data do Inventário","mv_ch1","D",08,0,0,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)


aHelpPor :={}
AAdd(aHelpPor,"Local Inicial")
AAdd(aHelpPor,"a ser Processado")
PutSx1(cPerg,"02","Local Inicial","Local Inicial","Local Inicial","mv_ch2","C",02,0,0,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

aHelpPor :={}
AAdd(aHelpPor,"Local Final")
AAdd(aHelpPor,"a ser Processado")
PutSx1(cPerg,"03","Local Final","Local Final","Local Final","mv_ch3","C",02,0,0,"G","","","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

aHelpPor :={}
AAdd(aHelpPor,"Endereço Inicial")
AAdd(aHelpPor,"a ser Processado")
PutSx1(cPerg,"04","Endereço Inicial","Endereço Inicial","Endereço Inicial","mv_ch4","C",15,0,0,"G","","","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

aHelpPor :={}
AAdd(aHelpPor,"Endereço Final")
AAdd(aHelpPor,"a ser Processado")
PutSx1(cPerg,"05","Endereço Endereço Final","Endereço Final","Endereço Final","mv_ch5","C",15,0,0,"G","","","","","MV_PAR05","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

aHelpPor :={}
AAdd(aHelpPor,"Lote Inicial")
AAdd(aHelpPor,"a ser Processado")
PutSx1(cPerg,"06","Lote Inicial","Lote Inicial","Lote Inicial","mv_ch6","C",10,0,0,"G","","","","","MV_PAR06","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

aHelpPor :={}
AAdd(aHelpPor,"Lote Final")
AAdd(aHelpPor,"a ser Processado")
PutSx1(cPerg,"07","Lote Final","Lote Final","Lote Final","mv_ch7","C",10,0,0,"G","","","","","MV_PAR07","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)



Return
