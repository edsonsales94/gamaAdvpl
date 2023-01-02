#INCLUDE "PRTOPDEF.CH"  
#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRELMRPNEW บAutor  ณRonaldo Silva  - AllERP   Data Agosto/21 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Emissใo de relatorio em formato de tabela,                 บฑฑ
ฑฑบ          ณ baseado nas tabelas do novo MRP                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico Ga.Ma Italy                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

user function RELMRPNEW()
Local cPerg := 'RELMRPNEW'        
                                                                                        
VALPERG(cPerg)
IF pergunte(cPerg,.T.)

	fQuery()
	DlgToExcel()
	
ENDIF

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfQuery()บAutor  ณRonaldo Silva              Data Agosto/21  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

STATIC FUNCTION fQuery()
Local cQuery := " "

cQuery +=" SELECT "
cQuery +=" B1_FILIAL,B1_COD,B1_TIPO,B1_DESC,B1_UM,B1_ORIGAMA,B1_XCODARI,HW3_TICKET,HW3_FILIAL,HWB_PRODUT,HWB_DATA,cast(ORIGENS as varchar(60)) ORIGENS,T4V_QNPT,cast(ALT_UTI as varchar(60)) ALT_UTI "
cQuery +="	 ,HWB_QTSLES,HWB_QTENTR,HWB_QTSAID,HWB_QTSEST,HWB_QTSALD,HWB_QTNECE, VIRADA, B2_CM1, "
cQuery +=" 	row_number() over (partition by HWB_PRODUT order by  HW3_TICKET,HWB_PRODUT,HWB_DATA ) as QUEBRAS,									    "
cQuery +=" 	count(HWB_PRODUT) over (partition by HWB_PRODUT order by  HW3_TICKET,HWB_PRODUT) as TOTPER,"
cQuery +=" 	[dbo].[fn_SCABERTA](HWB_PRODUT,HWB_DATA,row_number() over (partition by HWB_PRODUT order by  HW3_TICKET,HWB_PRODUT,HWB_DATA )) EM_SC,   "
cQuery +=" 	[dbo].[fn_POABERTA](HWB_PRODUT,HWB_DATA,row_number() over (partition by HWB_PRODUT order by  HW3_TICKET,HWB_PRODUT,HWB_DATA )) EM_PO   "
cQuery +=" FROM																										       "
cQuery +=" (																										       "
cQuery +=" 		SELECT 																								       "
cQuery +=" 		B1_FILIAL, B1_COD,B1_TIPO, B1_DESC, B1_UM, 																			       "
cQuery +=" 		IIF(B1_ORIGAMA='01','IMP','NAC') B1_ORIGAMA, 																			       "
cQuery +=" 		B1_XCODARI, HW3_TICKET, 																					       "
cQuery +=" 		HW3_FILIAL, 																							       "
cQuery +=" 		HWB_PRODUT,B2_CM1,  																							       "
cQuery +=" 		HWB_DATA, 																							       "
cQuery +=" 		ISNULL(ORIGENS,'Entradas') ORIGENS,																				       "
cQuery +=" 		ISNULL(T4V_QNPT,0) T4V_QNPT, 																				       "
cQuery +=" 		ISNULL(ALTER1,'') ALT_UTI, 																		       "
cQuery +=" 		HWB_QTSLES ,																							       "
cQuery +=" 		HWB_QTENTR ,																							       "
cQuery +=" 		HWB_QTSAID ,																							       "
cQuery +=" 		HWB_QTSEST ,																							       "
cQuery +=" 		HWB_QTSALD ,																							       "
cQuery +=" 		HWB_QTNECE ,																							       "
cQuery +=" 		ABS(ABS(HWB_QTNECE)-ABS(HWB_QTSALD)) AS VIRADA																			       "
cQuery +="   FROM 																									       "
cQuery +="   HW3010  HW3 JOIN HWB010  HWB ON HWB.HWB_TICKET = HW3.HW3_TICKET AND HWB.D_E_L_E_T_ <>'*' AND HWB.HWB_FILIAL= HW3.HW3_FILIAL  										       "
cQuery +="   JOIN HWA010  HWA ON HWA.HWA_PROD = HWB.HWB_PRODUT AND HWA.D_E_L_E_T_ <>'*'  																       "
cQuery +="   JOIN SB1010  SB1 ON HWA.HWA_PROD = SB1.B1_COD AND SB1.D_E_L_E_T_ <>'*'  																	       "
cQuery +="   OUTER APPLY ( SELECT T4V_QNPT FROM T4V010 T4V WHERE T4V_PROD=HWA.HWA_PROD AND T4V_LOCAL=HWA_LOCPAD AND T4V.D_E_L_E_T_ <>'*') T4V										       "
cQuery +="   OUTER APPLY (SELECT T1.HWC_DATA,																						       "
cQuery +=" 				  STUFF(   (																					       "
cQuery +=" 								SELECT ',' + 																	       "
cQuery +=" 										CASE WHEN T2.HWC_TPDCPA = '0' THEN 'OP'												       "
cQuery +=" 											 WHEN T2.HWC_TPDCPA = '1' THEN 'Plano Mestre'										       "
cQuery +=" 																										       "
cQuery +=" 										 ELSE																       "
cQuery +=" 										 T2.HWC_TPDCPA 															       "
cQuery +=" 										 END																       "
cQuery +=" 								FROM HWC010 T2																	       "
cQuery +=" 								WHERE T2.HWC_TICKET= T1.HWC_TICKET														       "
cQuery +=" 									  AND T2.HWC_FILIAL= T1.HWC_FILIAL													       "
cQuery +=" 									  AND SUBSTRING(T2.HWC_PRODUT,1,15) = SUBSTRING(T1.HWC_PRODUT,1,15)									       "
cQuery +=" 									  AND T2.HWC_DATA=T1.HWC_DATA														       "
cQuery +=" 									  AND T2.D_E_L_E_T_=''															       "
cQuery +=" 								GROUP BY T2.HWC_TICKET,SUBSTRING(T2.HWC_PRODUT,1,15),T2.HWC_TPDCPA,T2.HWC_FILIAL				  				       "
cQuery +=" 								FOR XML PATH('')																       "
cQuery +=" 							  ), 1, 1, ''																		       "
cQuery +=" 							) ORIGENS,																		       "
cQuery +=" 					STUFF(   (																				       "
cQuery +=" 								SELECT ', ' + rtrim(T3.HWC_PRODUT) + ' Qtd. ' + CAST(SUM(HWC_QTSUBS) AS varchar(10))								       "
cQuery +=" 								FROM HWC010 T3																	       "
cQuery +=" 									WHERE T3.HWC_FILIAL= T1.HWC_FILIAL													       "
cQuery +=" 										AND T3.HWC_TICKET= T1.HWC_TICKET												       "
cQuery +=" 										AND T3.HWC_DATA=T1.HWC_DATA													       "
cQuery +=" 										AND T3.D_E_L_E_T_=''							  							       "
cQuery +=" 										AND T3.HWC_TPDCPA = T1.HWC_TPDCPA  												       "
cQuery +=" 										AND T3.HWC_DOCPAI = T1.HWC_DOCPAI  												       "
cQuery +=" 										AND T3.HWC_TRT = T1.HWC_TRT  													       "
cQuery +=" 										AND T3.HWC_CHVSUB = T1.HWC_CHAVE												       "
cQuery +=" 								GROUP BY T3.HWC_TICKET,T3.HWC_PRODUT,T3.HWC_FILIAL,T3.HWC_TPDCPA,T3.HWC_DOCPAI,T3.HWC_TPDCPA,T3.HWC_DOCPAI,T3.HWC_TRT,T3.HWC_CHAVE,T3.HWC_CHVSUB	"
cQuery +=" 								FOR XML PATH('')																       "
cQuery +=" 							  ), 1, 1, ''																		       "
cQuery +=" 							) ALTER1																		       "
cQuery +=" 																										       "
cQuery +=" 				 FROM HWC010 T1 WHERE T1.HWC_TICKET=HW3.HW3_TICKET AND SUBSTRING(T1.HWC_PRODUT,1,15) = HWB_PRODUT										       "
cQuery +=" 				 AND HWC_DATA=HWB_DATA																				       "
cQuery +=" 				 AND T1.D_E_L_E_T_=''																				       "
cQuery +=" 				GROUP BY T1.HWC_DATA,T1.HWC_TICKET,T1.HWC_PRODUT,T1.HWC_FILIAL,T1.HWC_TPDCPA,T1.HWC_DOCPAI,T1.HWC_TRT,T1.HWC_CHAVE 								       "
cQuery +=" 			  ) HWC 																					       "
cQuery +=" 	 OUTER APPLY ( SELECT B2_CM1 FROM SB2010 SB2 WHERE B2_COD=HWB_PRODUT AND B2_LOCAL=HWA_LOCPAD AND SB2.D_E_L_E_T_='' AND B2_FILIAL=HW3_FILIAL) SB2				       "
cQuery +="   WHERE   HW3.HW3_TICKET ='" + MV_PAR01 +"' and HW3.D_E_L_E_T_ <>'*'	 																	       "
cQuery +=" 			AND HW3.HW3_FILIAL = '01' AND HWA.HWA_FILIAL = SB1.B1_FILIAL																       "
cQuery +=" 			AND HWB.HWB_FILIAL = '01' 																				       "
cQuery +=" 			AND B1_TIPO<>'MO'																					       "
//cQuery +=" 			--AND HWB.HWB_DATA BETWEEN '20010101' AND  '20221231'       																       "
//cQuery +=" 			--AND HWB_PRODUT='MPBPJ0000000544'--'MQX0019' 'MMX1998'																	       "
cQuery +=" )DADOSMRP																									       "
cQuery +=" GROUP BY B1_FILIAL,B1_COD,B1_TIPO,B1_DESC,B1_UM,B1_ORIGAMA,B1_XCODARI,HW3_TICKET,HW3_FILIAL,HWB_PRODUT,HWB_DATA,ORIGENS,T4V_QNPT,ALT_UTI									       "
cQuery +="		 ,HWB_QTSLES,HWB_QTENTR,HWB_QTSAID,HWB_QTSEST,HWB_QTSALD,HWB_QTNECE,VIRADA,B2_CM1															       "
cQuery +=" ORDER BY HW3_TICKET,HWB_PRODUT,HWB_DATA																									       "


MEMOWRITE('LOG1QRY.SQL',cQuery)
 

IF SELECT('TBHWC') > 0
	DBSELECTAREA("TBHWC")
	TBHWC->(DBCLOSEAREA())
ENDIF  

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), "TBHWC", .F., .T. )

TBHWC->(DbGoTop())

RETURN


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVALPERG     บAutor  ณRONALDO SILVA          Data Agosto/21  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVALIDA A PERGUNTA                                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function VALPERG(cPerg)
Local i,j
cPerg := PADR(cPerg,10)
aRegs := {}
dbSelectArea("SX1")
dbSetOrder(1)

if !dbSeek(cPerg)
	AADD(aRegs,{cPerg,"01","Ticket:"             ,"","" ,"mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","HW3Z",""})
	AADD(aRegs,{cPerg,"02","Data de:"            ,"","" ,"mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"03","Data ate:"           ,"","" ,"mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Endif

For i := 1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j := 1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next
                                                                
Return

***************************************************************************************************************************************************************

Static Function DlgToExcel()

Local oExcel := FWMSEXCEL():New() //Cria o Objeto que ira gerar o Arquivo
Local cArqv  := 'REL_Movi_mrpnew.XML'
Local cPath  := 'C:\temp\'
Local cPlanilha := 'Analitico'
Local cTabela  := "Controle de Movimenta็ใo MRP"
Local cUltQuebra:='N'
Local nAtual      := 0

ProcRegua(RecCount())

//oExcel:AddworkSheet(<Planilha>)
oExcel:AddworkSheet(cPlanilha) //Cria Planilha(Pasta) Dentro do Arquivo

//oExcel:AddTable (<Planilha>,<Tabela>)
oExcel:AddTable (cPlanilha,cTabela) //Cria uma Tabela

//Cria o Cabe็alho de cada coluna
oExcel:AddColumn(cPlanilha,cTabela,"TICKET"         		,1,1) 
oExcel:AddColumn(cPlanilha,cTabela,"ORIGEM"         		,1,1) 
oExcel:AddColumn(cPlanilha,cTabela,"ALIAS"       	     	,1,1) 
oExcel:AddColumn(cPlanilha,cTabela,"SLD TERC"	            ,1,1)
oExcel:AddColumn(cPlanilha,cTabela,"CODIGO"      	        ,1,1)
oExcel:AddColumn(cPlanilha,cTabela,"COD ARIMEX"       		,1,1)
oExcel:AddColumn(cPlanilha,cTabela,"DESCRIวรO"	            ,1,1)
oExcel:AddColumn(cPlanilha,cTabela,"UNIDADE"                ,1,1)
oExcel:AddColumn(cPlanilha,cTabela,"TIPO" 		            ,1,1)
oExcel:AddColumn(cPlanilha,cTabela,"V.UNIT"     		    ,1,1)
oExcel:AddColumn(cPlanilha,cTabela,"DATA SLD.INI."     		,1,1)
oExcel:AddColumn(cPlanilha,cTabela,"SLD.INI."       		,1,1)
oExcel:AddColumn(cPlanilha,cTabela,"ENTRADAS"       		,1,1)
oExcel:AddColumn(cPlanilha,cTabela,"SAIDAS"       		    ,1,1)
oExcel:AddColumn(cPlanilha,cTabela,"S.P/ESTRUT."       		,1,1)
oExcel:AddColumn(cPlanilha,cTabela,"SLD.FINAL"       		,1,1)
oExcel:AddColumn(cPlanilha,cTabela,"NEC.SC."       		,1,1)
oExcel:AddColumn(cPlanilha,cTabela,"VIRADA SLD."      		,1,1)
oExcel:AddColumn(cPlanilha,cTabela,"ALT.UTILIZADO"     		,1,1)
oExcel:AddColumn(cPlanilha,cTabela,"EM_SC."      		,1,1)
oExcel:AddColumn(cPlanilha,cTabela,"EM_PO."      		,1,1)
oExcel:AddColumn(cPlanilha,cTabela,"PERIODO"      		,1,1)
oExcel:AddColumn(cPlanilha,cTabela,"FIM"      		,1,1)


oExcel:SetLineBgColor('#4F81BD')
oExcel:SetLineBgColor('#FFFFFF')

//oExcel:AddRow(cPlanilha,cTabela,cCel) //Insere uma linha na Tabela
oExcel:SetLineBgColor('#000000')

oExcel:SetLineBgColor('#FFFFFF') //Cor de Preenchimento da Linha Impar
oExcel:Set2LineBgColor('#FFFFFF')//Cor de Preenchimento da Linha Par

nX := 1        
dbselectarea("TBHWC")
dbgotop()

_DATA   := ''
_FUNCX  :=  ''
_TOTALX := 0
_TOTALGX:= 0
_PRODUTOX:=''	

While TBHWC->(!eof())	
	
	 nAtual++
     IncProc("Processando registro "+cValToChar(nAtual)+"...")                         
    
		IF TBHWC->QUEBRAS = TBHWC->TOTPER 
			cUltQuebra:='S'
		ELSE
			cUltQuebra:='N'
		ENDIF
		
		cCel := {TBHWC->HW3_TICKET                      ,;
				TBHWC->B1_ORIGAMA						,; 
				TBHWC->ORIGENS,;
				TBHWC->T4V_QNPT				    		,;
				TBHWC->B1_COD				    	,;
				TBHWC->B1_XCODARI						,;
				TBHWC->B1_DESC							,;
				TBHWC->B1_UM							,;
				TBHWC->B1_TIPO				     		,;
				TBHWC->B2_CM1							,;
				SUBSTR(TBHWC->HWB_DATA,7,2) +'/'+ SUBSTR(TBHWC->HWB_DATA,5,2) +'/'+ SUBSTR(TBHWC->HWB_DATA,1,4)     			    ,;
				TBHWC->HWB_QTSLES                       ,;
				TBHWC->HWB_QTENTR						,;
				TBHWC->HWB_QTSAID						,;
				TBHWC->HWB_QTSEST						,;
				TBHWC->HWB_QTSALD						,;
				TBHWC->HWB_QTNECE						,;
				TBHWC->VIRADA							,;						
				TBHWC->ALT_UTI							,;	
				TBHWC->EM_SC,;
				TBHWC->EM_PO,;
				TBHWC->QUEBRAS,;
				cUltQuebra} 


	oExcel:AddRow(cPlanilha,cTabela,cCel) //Insere uma linha na Tabela
		
	TBHWC->(DBSKIP())
enddo

oExcel:Activate() //Ativa a Planilha
oExcel:GetXMLFile(cArqv) //Salva o Arquivo

IncProc("Montando Arquivo")

if !ExistDir(cPath)//verifica se a pasta existe
	MakeDir(cPath) //Cria a Pasta
endif

if __CopyFile(cArqv,cPath +cArqv)//Copia o arquivo do servidor para a pasta definida na esta็ใo do SmartClient
	
	IF !( ApOleClient("MsExcel") )//Verifica se existe o Excel instalado. Obs: No Windows 8 e 8.1 s๓ com a Build: 7.00.121227P-20131106
		MsgAlert('Nใo foi possivel localizar o excel' + chr(13) + chr(10) + 'Relat๓rio foi gerado na Pasta: ' + cPath + cArqv)
	else
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open()
		//oExcelApp:WorkBooks:Open(cPath + cArq+'.XML') // Abre uma planilha
		oExcelApp:WorkBooks:Open(cPath + cArqv+'.XML') // Abre uma planilha		
		oExcelApp:SetVisible(.T.)
		//oExcelApp := oExcelApp:Destroy()
	EndIF
else
	MsgAlert('Nใo foi possivel gerar o Relat๓rio')
endif

Return
