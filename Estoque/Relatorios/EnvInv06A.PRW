#include "protheus.ch"
#include "topconn.ch"

#include "protheus.ch"              
*****************************************************************************************************************************************************
User Function List_NCNT()//divergencia de contagem no inventário 
*****************************************************************************************************************************************************
Local oReport
If TRepInUse()	//verifica se relatorios personalizaveis esta disponivel
    cPerg:="ENVINV06"
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

oReport := TReport():New("ENVINV06","Estatistica de Contagem de inventário",cPerg,{|oReport| PrintReport(oReport)},"Este relatorio ira imprimir a divergencia de Contagem .")

oSection1 := TRSection():New(oReport,"Contagem",{""})

TRCell():New(oSection1,"","","PRODUTO","@!",25)
//TRCell():New(oSection1,"","","DESCRICAO","@!",30)
TRCell():New(oSection1,"","","ARM","@!",3)
TRCell():New(oSection1,"","","LOCALIZACAO","@!",15)
TRCell():New(oSection1,"","","SALDO ATUAL","@!",25) 
//TRCell():New(oSection1,"","","","@!",6)
TRCell():New(oSection1,"","","INVENTARIO","@!",25)
//TRCell():New(oSection1,"","","","@!",6)
//TRCell():New(oSection1,"","","3o Contagem","@!",25)

oSection2 := TRSection():New(oReport,"TES",{"TPV","SX5"})
TRPosition():new(oSection2,"SX5",1,{|| xFilial("SX5") +"Z1" +TPV->LOC}) //--posicionamento 
//TRPosition():New(oSection2,"SB1",1,{|| xFilial("SB1")+TPV->BF_PRODUTO})

TRCell():New(oSection2,"FILIAL","TPV","Fil.","@!",3)
TRCell():New(oSection2,"PRODUT","TPV","Produto","@!",25)
TRCell():New(oSection2,"DESCRI","TPV","Descricao","@!",30)
TRCell():New(oSection2,"LOC","TPV","Local","@!",3)
TRCell():New(oSection2,"ENDERE","TPV","Endereco","@!",15)
TRCell():New(oSection2,"TIPO","TPV","Tipo","@!",5) 
TRCell():New(oSection2,"UNID","TPV","UN","@!",5)
TRCell():New(oSection2,"GRUPO","TPV","Grupo","@!",5) 
TRCell():New(oSection2,"CM1","TPV","C.Medio","@r 999,999.9999",20) 
TRCell():New(oSection2,"QTDATU","TPV","SL.ATU","@r 99,999,999.9999",20) 
TRCell():New(oSection2,"REG_TOT","TPV","Tot.Regis","@r 99,999,999.9999",20)
 

//TRCell():New(oSection2,"REG_CONT1","TPV","Reg.Contado(1)","@!",25) 
//TRCell():New(oSection2,"P1O","TPV","Percentual(1)","@!",25)
//TRCell():New(oSection2,"REG_CONT2","TPV","Reg.Contado(2)","@!",25) 
//TRCell():New(oSection2,"P2O","TPV","Percentual(2)","@!",25)
//TRCell():New(oSection2,"REG_CONT3","TPV","Reg.Contado(3)","@!",25) 
//TRCell():New(oSection2,"P3O","TPV","Percentual(3)","@!",25)

//TRCell():New(oSection2,"REG_TOT","TPV","Tot.Registro"   ,"@r 99,999,999.9999",25) 
//TRCell():New(oSection2,"QTDATU" ,"TPV","Qtd.Atual(SB2)"      ,"@r 99,999,999.9999",25) 
//TRCell():New(oSection2,"QTDINV" ,"TPV","Qtd.Inventario(SZU)" ,"@r 99,999,999.9999",25) 
//TRCell():New(oSection2,"DIF"  ,"TPV"   ,"Qtd.DIF" ,"@r 99,999,999.9999",25) 



oBreak2 := TRBreak():New(oSection2,oSection2:Cell("LOC"),{ || "Total --> "+SX5->X5_DESCRI},.F.)
TRFunction():New(oSection2:Cell("QTDATU"),NIL,"SUM",oBreak2)
TRFunction():New(oSection2:Cell("REG_TOT"),NIL,"SUM",oBreak2)
//TRFunction():New(oSection2:Cell("REG_CONT1"),NIL,"SUM",oBreak1)
//TRFunction():New(oSection2:Cell("REG_CONT2"),NIL,"SUM",oBreak1)
//TRFunction():New(oSection2:Cell("REG_CONT3"),NIL,"SUM",oBreak1)
//TRFunction():New(oSection2:Cell("REG_TOT"),NIL,"SUM",oBreak1)
oBreak1 := TRBreak():New(oSection2,oSection2:Cell("FILIAL"),{ || "Total --> "},.F.)
TRFunction():New(oSection2:Cell("QTDATU"),NIL,"SUM",oBreak1)
TRFunction():New(oSection2:Cell("REG_TOT"),NIL,"SUM",oBreak1)


//TRFunction():New(oSection2:Cell("DIF"),NIL,"SUM",oBreak1)

//TRPosition(oSection2,"SB1",1,{|| xFilial("SB1") + SBH->BH_CODCOMP})
Return oReport
*****************************************************************************************************************************************************
Static Function PrintReport(oReport)
*****************************************************************************************************************************************************
Local oSection1 := oReport:Section(1) 
Local oSection2 := oReport:Section(2)

oSection1:Init()	
oSection1:PrintLine() 
oSection1:Finish()

ChamaSPO()
cArq    :="TABDIC"+Sm0->m0_Codigo+"0"+SM0->M0_CODFIL
cQuery  :="SELECT * FROM "+cArq 
cQuery  +=" WHERE "
cQuery  +=" LOC    BETWEEN  '"+Mv_Par02+"' AND '"+Mv_Par03+"' AND " 
cQuery  +=" ENDERE BETWEEN  '"+Mv_Par04+"' AND '"+Mv_Par05+"' "


/*cQuery  :="SELECT ZI2_FILIAL,ZI2_LOCAL,SUBSTRING(ZI2_LOCALI,1,4)AS ZI2_LOCALI,SUM(ZI2_SLDATU)AS QTDATU,SUM(ZI2_QTDINV)AS QTDINV,SUM(ZI2_SLDATU-ZI2_QTDINV)AS DIF,SUM(ZI2_QRCON1)AS REG_CONT1,SUM(ZI2_QRCON2)AS REG_CONT2,SUM(ZI2_QRCON3)AS REG_CONT3,COUNT(*)AS REG_TOT,"
cQuery  +="SUM(ZI2_QRCON1)/COUNT(*) AS P1O,SUM(ZI2_QRCON2)/COUNT(*) AS P2O,SUM(ZI2_QRCON3)/COUNT(*) AS P3O" 
cQuery  +=" FROM "+Retsqlname("ZI2")+" WHERE D_E_L_E_T_<>'*' AND "
cQuery  +="ZI2_DTINV = '"+DTOS(Mv_Par01)+"' AND "
cQuery  +="ZI2_LOCAL BETWEEN  '"+Mv_Par02+"' AND '"+Mv_Par03+"' AND " 
cQuery  +="ZI2_LOCALI BETWEEN  '"+Mv_Par04+"' AND '"+Mv_Par05+"' "
cQuery  +="GROUP BY ZI2_FILIAL,ZI2_LOCAL,SUBSTRING(ZI2_LOCALI,1,4) "
cQuery  +="ORDER BY ZI2_FILIAL,ZI2_LOCAL,SUBSTRING(ZI2_LOCALI,1,4) "*/

/*
cQuery := "SELECT BF_FILIAL, BF_PRODUTO, BF_LOCAL, BF_LOCALIZ, SUM(BF_QUANT) AS QTDATU,"
cQuery += "(SELECT SUM(ZU_CONT1)QTDINV FROM "+RETSQLNAME('SZU')+" WHERE "+RETSQLNAME('SZU')+".D_E_L_E_T_<>'*' AND "
cQuery += "ZU_FILIAL = BF_FILIAL AND ZU_COD = BF_PRODUTO AND ZU_LOCALIZ = BF_LOCALIZ)QTDINV FROM "+RETSQLNAME('SBF')+" WHERE "
cQuery += RETSQLNAME('SBF')+".D_E_L_E_T_<>'*' AND BF_FILIAL = '"+xFILIAL('SBF')+"' AND BF_LOCAL BETWEEN '"+MV_PAR02+"' AND "
cQuery += "'"+MV_PAR03+"' AND BF_LOCALIZ BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR05 + "' "
cQuery += "GROUP BY BF_FILIAL, BF_PRODUTO, BF_LOCAL, BF_LOCALIZ "
cQuery += "ORDER BY BF_FILIAL, BF_PRODUTO, BF_LOCAL, BF_LOCALIZ"
*/

TCQUERY cQuery NEW ALIAS TPV
COUNT TO  nRegis 
DbSelectArea("TPV")
DBGOTOP()  
ProcRegua(nRegis)  
oReport:SetMeter(RecCount())
oSection2:Init()	
nRegCont:=0
While !Eof()
    nRegCont:=nRegCont+1
    IncProc("Reg =>"+StrZero(nRegCont,10)+" / "+strZero(nRegis,10))   
	If oReport:Cancel()
		Exit
	EndIf
	oSection2:Cell("REG_TOT"):Hide()
	oSection2:PrintLine() 
	
	DbSelectArea("TPV")
	DbSkip()
	oReport:IncMeter()
End
oSection2:Finish()
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

Return
*****************************************************************************************************************************************************
Static Function ChamaSPO()
*****************************************************************************************************************************************************
cProced:="E_INVSTAT05"
		If !TCSPExist(cProced)
			MsgAlert("Erro na criação da procedure"+": "+cProced)	//	"Erro na exclusao da procedure"
			Return .F.
		EndIf
	   	cRet := TcSqlExec(cProced+" '"+SM0->M0_CODFIL+"','"+SM0->m0_Codigo+"0','"+DTOS(Mv_Par01)+"','"+DTOS(dDataBase)+"'" )
	   	If cRet < 0
	   		If !IsBlind()
		   		MsgAlert('Erro na procedure'+": "+cProced)	//	'Erro na criação da procedure'
		   	EndIf
			Return .F.
		EndIf
Return (.t.)
