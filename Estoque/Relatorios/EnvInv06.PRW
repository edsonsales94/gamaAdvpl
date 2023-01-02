#include "protheus.ch"
#include "topconn.ch"

#include "protheus.ch"
*****************************************************************************************************************************************************
User Function envinv06()//"Estatistica de Contagem de inventário
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

TRCell():New(oSection1,"","","","@!",3)
TRCell():New(oSection1,"","","","@!",3)
TRCell():New(oSection1,"","","","@!",30)
TRCell():New(oSection1,"","","","@!",15)
TRCell():New(oSection1,"","","1o Contagem","@!",25) 
TRCell():New(oSection1,"","","","@!",6)
TRCell():New(oSection1,"","","2o Contagem","@!",25)
TRCell():New(oSection1,"","","","@!",6)
TRCell():New(oSection1,"","","3o Contagem","@!",25)


oSection2 := TRSection():New(oReport,"TES",{"TPV","SX5"})

//TRPosition(oSection2,"SX5",1,{|| xFilial("SX5") +"74" +TPV->ZI2_LOCAL}) //--posicionamento 
TRPosition():New(oSection2,"SX5",1,{|| xFilial("SX5")+"74"+TPV->LOC})

TRCell():New(oSection2,"FILIAL","TPV","Fil.","@!",3)
TRCell():New(oSection2,"LOC","TPV","Local","@!",3)
TRCell():New(oSection2,"X5_DESCRI","SX5","Descricao","@!",30)
TRCell():New(oSection2,"ENDERE","TPV","Endereco","@!",15)
TRCell():New(oSection2,"nREG1","TPV","Reg.Contado(1)","@!",25) 
TRCell():New(oSection2,"nP10","TPV","Percentual(1)","@r 999.99",10)
TRCell():New(oSection2,"nREG2","TPV","Reg.Contado(2)","@!",25) 
TRCell():New(oSection2,"nP20","TPV","Percentual(2)","@r 999.99",10)
TRCell():New(oSection2,"nREG3","TPV","Reg.Contado(3)","@!",25) 
TRCell():New(oSection2,"nP30","TPV","Percentual(3)","@r 999.99",10)

TRCell():New(oSection2,"REG_TOT","TPV","Tot.Registro"   ,"@r 99,999,999.9999",25) 
TRCell():New(oSection2,"QTDATU" ,"TPV","Qtd.Atual(SB2)"      ,"@r 99,999,999.9999",25) 
TRCell():New(oSection2,"QTDINV" ,"TPV","Qtd.Inventario(SZU)" ,"@r 99,999,999.9999",25) 
TRCell():New(oSection2,"DIF"  ,"TPV"   ,"Qtd.DIF" ,"@r 99,999,999.9999",25) 



oBreak1 := TRBreak():New(oSection2,oSection2:Cell("FILIAL"),{ || "Total --> "},.F.)
TRFunction():New(oSection2:Cell("nREG1"),NIL,"SUM",oBreak1)
TRFunction():New(oSection2:Cell("nREG2"),NIL,"SUM",oBreak1)
TRFunction():New(oSection2:Cell("nREG3"),NIL,"SUM",oBreak1)
TRFunction():New(oSection2:Cell("REG_TOT"),NIL,"SUM",oBreak1)
TRFunction():New(oSection2:Cell("QTDATU"),NIL,"SUM",oBreak1)
TRFunction():New(oSection2:Cell("QTDINV"),NIL,"SUM",oBreak1)
TRFunction():New(oSection2:Cell("DIF"),NIL,"SUM",oBreak1)

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
cArq    :="TABINV"+Sm0->m0_Codigo+"0"+SM0->M0_CODFIL
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
	IF TpV->REG_TOT>0
	 oSection2:Cell("nREG1"):SetValue(TpV->REG_CONT1)			
	 oSection2:Cell("nREG2"):SetValue(TPV->REG_CONT2)			
	 oSection2:Cell("nREG3"):SetValue(TPV->REG_CONT3)			

	 oSection2:Cell("nP10"):SetValue(TpV->(REG_CONT1/REG_TOT)*100)			
	 oSection2:Cell("nP20"):SetValue(TPV->(REG_CONT2/REG_TOT)*100)			
	 oSection2:Cell("nP30"):SetValue(TPV->(REG_CONT3/REG_TOT)*100)			
 
	 oSection2:PrintLine() 
	Endif
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
cProced:="E_INVSTAT02"
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
                   
///****** Object:  StoredProcedure [dbo].[E_INVSTAT02]    Script Date: 12/03/2012 10:22:23 ******/
/*
USE [DADOSADV]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE  [dbo].[E_INVSTAT02]
( @cFILIAL Varchar(02), @cEmp Varchar(03),@dDtIni Varchar(08),@dDtFim Varchar(08))
AS 
BEGIN 
  DECLARE @cArq   Varchar(11) 
  DECLARE @cDrop  Varchar(80) 
  DECLARE @cQuery Varchar(8000) 
  DECLARE @cQuery2 Varchar(8000) 
  DECLARE @cQuery3 Varchar(8000) 
 
  SET @cArq='TABINV'+@cEmp+@cFILIAL
  If NOT (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_NAME=@cArq) IS NULL 
  	 BEGIN  
    	   Set @cDrop= 'DROP TABLE '+@cArq  
  	   EXEC( @cDrop )  
  END   


SET @cQuery2=' SELECT FILIAL,LOC,ENDERE,SUM(BF_QUANT)QTDATU,SUM(CONTAGEM)QTDINV,SUM(BF_QUANT-CONTAGEM)DIF,SUM(REG_S)REG_TOT,'
SET @cQuery2=@cQuery2+' ISNULL(SUM(CONT1),0)REG_CONT1, ISNULL(SUM(CONT2),0)REG_CONT2, ISNULL(SUM(CONT3),0)REG_CONT3,'
SET @cQuery2=@cQuery2+' P10= CASE SUM(REG_S) WHEN 0 THEN 0 ELSE (ISNULL(SUM(CONT1),0)/SUM(REG_S)) END, '
SET @cQuery2=@cQuery2+' P20= CASE SUM(REG_S) WHEN 0 THEN 0 ELSE (ISNULL(SUM(CONT2),0)/SUM(REG_S)) END, '
SET @cQuery2=@cQuery2+' P30= CASE SUM(REG_S) WHEN 0 THEN 0 ELSE (ISNULL(SUM(CONT3),0)/SUM(REG_S)) END '
SET @cQuery2=@cQuery2+' INTO '+@cArq+' FROM'

SET @cQuery2=@cQuery2+'(SELECT'
SET @cQuery2=@cQuery2+'	ISNULL(CONTAGEM,0)CONTAGEM, ISNULL(BF_QUANT,0)BF_QUANT, ISNULL(B2_CM1,0)B2_CM1,ISNULL(IMPR,0)REG_S'
SET @cQuery2=@cQuery2+' ,FILIAL=CASE WHEN ZU_FILIAL    IS NULL THEN SBF_2.BF_FILIAL ELSE ZU_FILIAL END'
SET @cQuery2=@cQuery2+' ,PRODUT=CASE WHEN ZU_COD       IS NULL THEN SBF_2.BF_PRODUTO ELSE ZU_COD END'
SET @cQuery2=@cQuery2+' ,LOC   =CASE WHEN ZU_LOCPAD    IS NULL THEN SBF_2.BF_LOCAL ELSE ZU_LOCPAD END'
SET @cQuery2=@cQuery2+' ,ENDERE=CASE WHEN ZU_LOCALIZ   IS NULL THEN SBF_2.BF_LOCALIZ ELSE ZU_LOCALIZ END' 
SET @cQuery2=@cQuery2+' ,DESCRI=CASE WHEN SB1.B1_DESC  IS NULL THEN SBF_2.B1_DESC ELSE SB1.B1_DESC END'
SET @cQuery2=@cQuery2+' ,TIPO  =CASE WHEN SB1.B1_TIPO  IS NULL THEN SBF_2.B1_TIPO ELSE SB1.B1_TIPO END'
SET @cQuery2=@cQuery2+' ,UNID  =CASE WHEN SB1.B1_UM    IS NULL THEN SBF_2.B1_UM ELSE SB1.B1_UM END'
SET @cQuery2=@cQuery2+' ,GRUPO =CASE WHEN SB1.B1_GRUPO IS NULL THEN SBF_2.B1_GRUPO ELSE SB1.B1_GRUPO END'
SET @cQuery2=@cQuery2+' ,SZU_3.CONT1,SZU_3.CONT2,SZU_3.CONT3'
SET @cQuery2=@cQuery2+' FROM'

SET @cQuery2=@cQuery2+' (SELECT ZU_FILIAL,ZU_COD,ZU_LOCPAD,ZU_LOCALIZ,SUM(CONT1)AS CONT1,SUM(CONT2)AS CONT2,SUM(CONT3)AS CONT3,SUM(CONTAGEM)AS CONTAGEM,SUM(IMPR) AS IMPR'
SET @cQuery2=@cQuery2+' FROM'
SET @cQuery2=@cQuery2+' (SELECT  ZU_FILIAL,ZU_COD,ZU_LOCPAD,ZU_LOCALIZ,ZU_CONT1,ZU_CONT2,ZU_CONT3,ZU_ULTCONT,'
SET @cQuery2=@cQuery2+' CONTAGEM=CASE ZU_ULTCONT WHEN 1 THEN  ZU_CONT1'
SET @cQuery2=@cQuery2+' WHEN 2 THEN  ZU_CONT2'
SET @cQuery2=@cQuery2+' WHEN 3 THEN  ZU_CONT3'
SET @cQuery2=@cQuery2+' ELSE 0'
SET @cQuery2=@cQuery2+' END,'

SET @cQuery2=@cQuery2+' CONT1=CASE ZU_DATACT1  WHEN '''' THEN  0 ELSE 1 END, '
SET @cQuery2=@cQuery2+' CONT2=CASE ZU_DATACT2  WHEN '''' THEN  0 ELSE 1 END, '
SET @cQuery2=@cQuery2+' CONT3=CASE ZU_DATACT3  WHEN '''' THEN  0 ELSE 1 END, '
SET @cQuery2=@cQuery2+' IMPR=CASE ZU_TIME  WHEN ''IMP'' THEN  1 ELSE 0 END '
                                                                                                                                                                                  
SET @cQuery2=@cQuery2+' FROM SZU'+@cEmp+' SZU_1 '
SET @cQuery2=@cQuery2+' WHERE SZU_1.D_E_L_E_T_<>''*'' AND SZU_1.ZU_FILIAL = '''+@cFILIAL+''' AND SZU_1.ZU_COD <>'''' '
SET @cQuery2=@cQuery2+' AND SZU_1.ZU_DATA   BETWEEN '''+@dDtIni+''' AND '''+@dDtFim +'''' +' )  AS SZU_2'

SET @cQuery3=' GROUP BY SZU_2.ZU_FILIAL,SZU_2.ZU_COD,SZU_2.ZU_LOCPAD,SZU_2.ZU_LOCALIZ'
SET @cQuery3=@cQuery3+' )AS SZU_3' 
SET @cQuery3=@cQuery3+' INNER JOIN  SB1'+@cEmp+' SB1 ON ( SZU_3.ZU_COD = B1_COD  AND SZU_3.ZU_FILIAL=B1_FILIAL AND SB1.D_E_L_E_T_<>''*'')' 
SET @cQuery3=@cQuery3+' FULL JOIN ' 
SET @cQuery3=@cQuery3+'(  SELECT B2_FILIAL AS BF_FILIAL,B1_COD AS BF_PRODUTO,B1_DESC,B1_TIPO,B1_GRUPO,B1_UM,B1_RASTRO,B1_LOCALIZ,B2_CM1,B2_LOCAL AS BF_LOCAL,BF_LOCALIZ='''',B2_QATU AS BF_QUANT' 
SET @cQuery3=@cQuery3+' FROM   SB2'+@cEmp+' SB2 LEFT JOIN SB1'+@cEmp+' SB1 ON B2_FILIAL = B1_FILIAL AND B2_COD = B1_COD AND SB1.D_E_L_E_T_ <> ''*'''   
SET @cQuery3=@cQuery3+' WHERE SB2.D_E_L_E_T_<>''*'' AND B2_FILIAL='''+@cFILIAL+''' AND B2_QATU<>0 AND B1_LOCALIZ<>''S'''   
SET @cQuery3=@cQuery3+' UNION '   
SET @cQuery3=@cQuery3+' SELECT BF_FILIAL,B1_COD AS BF_PRODUTO,B1_DESC,B1_TIPO,B1_GRUPO,B1_UM,B1_RASTRO,B1_LOCALIZ,B2_CM1'
SET @cQuery3=@cQuery3+'	,BF_LOCAL AS BF_LOCAL,BF_LOCALIZ,SUM(BF_QUANT) AS BF_QUANT '
SET @cQuery3=@cQuery3+'  FROM SBF'+@cEmp+' SBF LEFT JOIN SB1'+@cEmp+' SB1 ON BF_FILIAL = B1_FILIAL AND BF_PRODUTO = B1_COD AND SB1.D_E_L_E_T_ <> ''*'''    
SET @cQuery3=@cQuery3+'  LEFT JOIN SB2'+@cEmp+' SB2 ON BF_FILIAL = B2_FILIAL AND BF_PRODUTO = B2_COD AND BF_LOCAL=B2_LOCAL AND SB1.D_E_L_E_T_ <> ''*'''  
SET @cQuery3=@cQuery3+'  WHERE SBF.D_E_L_E_T_<>''*'' AND BF_FILIAL='''+@cFILIAL+''' AND BF_QUANT<>0 AND B1_LOCALIZ=''S'''   
SET @cQuery3=@cQuery3+'  GROUP BY BF_FILIAL,B1_COD,B1_DESC,B1_TIPO,B1_GRUPO,B1_UM,B1_RASTRO,B1_LOCALIZ,B2_CM1,BF_LOCAL,BF_LOCALIZ'
SET @cQuery3=@cQuery3+'  )'
SET @cQuery3=@cQuery3+' AS SBF_2 ON (SZU_3.ZU_COD=SBF_2.BF_PRODUTO AND SZU_3.ZU_LOCALIZ=SBF_2.BF_LOCALIZ AND SZU_3.ZU_LOCPAD=SBF_2.BF_LOCAL AND SZU_3.ZU_FILIAL=SBF_2.BF_FILIAL)' 
SET @cQuery3=@cQuery3+' ) AS TRX ' 
SET @cQuery3=@cQuery3+' GROUP BY FILIAL,LOC,ENDERE' 


set @cQuery=@cQuery2+@cQuery3

EXEC(@cQuery)  

END 


*/