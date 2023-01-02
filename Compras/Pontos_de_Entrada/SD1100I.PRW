#include "rwmake.ch"
#include "Protheus.ch"

/*

———————————————————————————————————————————————————————————————————————————————
@function		SD1100I                                                      /@
@type			Ponto de entrada                                             /@
@date			                                                             /@
@description	Para atualização de itens de nota após sua gravação          /@
@author			Reginaldo                                                    /@
@use			Especifico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————

*/
User Function SD1100I()
Local cArea		:= GetArea()
Local lUtiInd   := GetMv("MV_UTIIND", .F., .F.)
Local CF_Serv   := GetMv("MV_CFOPIND", .F., "")		//CFOP de Serviço de Industrialização  - 1124 - RETORNO DE SERVICOS DE  - WIP


//———————————————————————————————————————————————————————————————————————————————
// Utilizado para regravar o custo de entrada para notas de serviço, somente caso 
// o parametro especifico MV_UTIIND seja verdadeiro e exista os campos de numero 
// de nota e serie origem especificos, e seja a empresa 01 e filial 01 e o CFOP
// esteja cadastrado no parametro especifico MV_CFOIND
// Por: Reginaldo
//———————————————————————————————————————————————————————————————————————————————
if 	lUtiInd .and.;
	SD1->(FieldPos("D1_XNFORI"))  > 0 .and.;
	SD1->(FieldPos("D1_XSERIOR"))  > 0 .and.;
	cEmpAnt $"01/04" .and.;
	cFilAnt == "01" .and.;
	Alltrim(SD1->D1_CF) $ CF_Serv
	
	
	
	Private cNomeTxt := "\data\tlog\emp" + cNumEmp + "-pd3-custo" + SF1->F1_FORNECE + SF1->F1_LOJA + "-" + SF1->F1_DOC + SF1->F1_SERIE + ".LOG"
	
	U_GeraLog(" ", 																									cNomeTxt)
	U_GeraLog("*****************************************************************",								 	cNomeTxt)
	U_GeraLog("CLASSIFICAÇÃO NOTA FISCAL DE SERVICO "+Alltrim(CUSERNAME),										 	cNomeTxt)
	U_GeraLog("DATA "+Transform(dDatabase,"99/99/9999") +" HORA:"+Time(),										 	cNomeTxt)
	U_GeraLog("FORNECEDOR.:" + SF1->F1_FORNECE + SF1->F1_LOJA + " - NOTA FISCAL.:" + SF1->F1_DOC + SF1->F1_SERIE,	cNomeTxt)
	
	//Ajusta custo das serviço das placas
	SD1->(RecLock("SD1", .F.))
	SD1->D1_CUSTO := (SD1->D1_TOTAL-SD1->D1_VALICM) + U_VlrServ(SD1->D1_XNFORI, SD1->D1_XSERIOR, SD1->D1_QUANT, SD1->D1_FORNECE, SD1->D1_LOJA)
	SD1->(MsUnLock())
	
endif

RestArea(cArea)
Return()



//////////////////////////////////////////////////////////////////////
//INSERIDO POR ALEX EM 24/09/2010 - PROJETO TPV
//////////////////////////////////////////////////////////////////////
USER Function VlrServ(pD1NFORI,pD1SERIORI,pD1Quant,cCodFor,cForLoja,lLog)
Local cQuery
local lLog := IF( lLog==Nil, .T. , lLog )

cQuery := " SELECT * "
cQuery += " FROM "+Retsqlname("SB6")+" SB6 " 
cQuery += " WHERE SB6.D_E_L_E_T_ <> '*' "
cQuery += " AND B6_FILIAL='"+xFilial("SB6")+"' "
cQuery += " AND B6_CLIFOR='"+cCodFor+"' "
cQuery += " AND B6_LOJA= '"+cForLoja+"' "
cQuery += " AND B6_DOC=  '"+pD1NFORI+"' "
cQuery += " AND B6_SERIE='"+pD1SERIORI+"' "
cQuery += " AND B6_TPCF='F' "
cQuery += " AND B6_PODER3='D' "

cQuery := ChangeQuery(cQuery)
If Select("TMPSD1") <> 0
	dbSelectArea("TMPSD1")
	TMPSD1->(DbCloseArea())
Endif
DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMPSD1",.F.,.T.)
dbSelectArea("TMPSD1")
Count to nRecSD1
TMPSD1->(dbgotop())

nCustoSB6 := 0
If nRecSD1 > 0
	Procregua(nRecSD1)
	Do While TMPSD1->(!Eof())
		
		nCustoSB6 += Round( TMPSD1->B6_QUANT * TMPSD1->B6_PRUNIT, 2)
				
		TMPSD1->(dbSkip())
	Enddo
	//msgStop("Valor do custo nf componente: "+transform(nCustoSB6, "@E 999,999.99"),"SD1100I")
Else  
   if lLog     
      u_GeraLog(" Erro -> Inconsistencia no custo do item, não foi encontrado CUSTO para NF componente "+pD1NFORI+"-"+cCodFor+"/"+cForLoja , cNomeTxt)
   endif
Endif

TMPSD1->(DbCloseArea())
Return(nCustoSB6)



//=================================================================================================================
// Geração do LOG
//=================================================================================================================
USER Function GeraLog(Texto, cNometxt)
Local cString := Texto
//Local aLog    := {}
If !File(cNometxt)
	fHandle := FCREATE(cNometxt)
Else
	fHandle := FOPEN(cNometxt,2)
Endif
//
cString := Texto+CHR(13)+CHR(10)
FSEEK(fHandle,0,2)
FWRITE(fHandle,cString)
FCLOSE(fHandle)
Return(.T.)

/*
User Function checkBN(cNfSerie,cForBN,cSForBN,cCF)
Local aArea   	:= GetArea()
Local lRet := .T.

IF ALLTRIM(cCF) == ALLTRIM(GetMv("MV_CFOPIND"))
	cQuery := " SELECT * "
	cQuery += " FROM "+Retsqlname("SB6")+" SB6 "
	cQuery += " WHERE SB6.D_E_L_E_T_ <> '*' "
	cQuery += " AND B6_FILIAL='"+xFilial("SB6")+"' "
	cQuery += " AND B6_CLIFOR='"+cForBN+"' "
	cQuery += " AND B6_LOJA= '"+cSForBN+"' "
	cQuery += " AND B6_DOC+B6_SERIE=  '"+cNfSerie+"' "
	cQuery += " AND B6_TPCF='F' "
	cQuery += " AND B6_PODER3='D' "
	//cQuery += " AND B6_PODER3='R' "
	
	cQuery := ChangeQuery(cQuery)
	If Select("TMPSD1") <> 0
		dbSelectArea("TMPSD1")
		TMPSD1->(DbCloseArea())
	Endif
	DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMPSD1",.F.,.T.)
	dbSelectArea("TMPSD1")
	Count to nRecSD1
	If nRecSD1==0
		lRet:=.F.
		msgStop("Nota de serviço não possui NF Retorno (componentes) atrelada!","SD1100I")
	Endif
	
	TMPSD1->(DbCloseArea())
	
ENDIF

RestArea(aArea)

RETURN lRet
*/

/*
User Function CheckTrigger(cRotina,cCheck)
Local lRet:= .T.
IF cRotina =="MATA103"
	lRet:= IF(cCheck==GETMV("MV_CFOPIND"),.T.,.F.)
ENDIF

Return lRet
*/

