#INCLUDE "rwmake.ch"        
#include "topconn.ch"

/*
Programa para gerar contagem Zerada
Development: Eduardo/Waldemir
Date:  28/12/2009       
Atualizado: 11/09/2011 by Waldemir/Rafael
*/

User Function GERA_ZERO()

Private oZeraCtg
Private cString  := ""
Private cPerg:="ENVINV07"

Pergunte( cPerg , .t. )

@ 200,1 TO 380,380 DIALOG oZeraCtg TITLE OemToAnsi("Gera contagem Zero pra Itens não Inventariados")
@ 02,10 TO 080,190
@ 10,018 Say " Este programa ira gerar contagem ZERO para os Itens  "
@ 18,018 Say " não inventariado com Saldo contábil no sistema. "
@ 26,018 Say "                                                            "

@ 70,128 BMPBUTTON TYPE 01 ACTION OkZeraCtg()
@ 70,158 BMPBUTTON TYPE 02 ACTION Close(oZeraCtg)

Activate Dialog oZeraCtg Centered

Return Nil

Static Function OkZeraCtg

Close(oZeraCtg)
Processa({|| RunCont() },"Processando...")

Return Nil

*********************************************************************************************************************
Static Function RunCont()
*********************************************************************************************************************
Private nNumEtq , cCod , cAlmox , cLocaliz
SB2->(dbSetorder(1))
SB1->(dbSetorder(1))

DbSelectArea("SZU")
DbSetOrder(2) 			// Filial+COD+LOCAL
 
nNumEtq := '350000'     // StrZero(mv_par01,6)
nNumEtq := f_NumEtqII(nNumEtq)           

f_Inc_Saldo_Zero()

/*
ProcRegua(SB2->(lastrec()))

SB2->(dbGoTop())

Do while !SB2->(eof())	
	
	IF SB2->B2_FILIAL != xFilial("SB2")
	   SB2->( dbSkip() )
	   LOOP
	ENDIF           
	
	IF EMPTY(SB2->B2_QATU)
	   SB2->( dbSkip() )
	   LOOP
	ENDIF           
	
	IF SB2->B2_LOCAL != MV_PAR02
	   SB2->( dbSkip() )
	   LOOP
	ENDIF                   
	
	cCod  := SB2->B2_COD
	cAlmox:= SB2->B2_LOCAL
	IncProc()
	
	If !u_fUsa_End(cCod)
	   //Criar etiquetas zeradas para os produtos que não controlam endereçamento
	     f_CriaEtq_Zero()
	   Else    
	     //Criar etiquetas zeradas para os produtos que controlam endereçamento 
	     f_End_CriaEtq_Zero()
	Endif 
	 
	SB2->(dbSkip())
EndDo     */

Return Nil

*********************************************************************************************************************
Static Function f_Inc_Saldo_Zero() 	//Zerar inventario não contado
*********************************************************************************************************************
Local _aAreaAtu := GetArea()
Private dDTREFINV := CTOD(GetMv("MV_DTINVRF"))

/*cQuery  :=" SELECT * FROM  (  SELECT B2_FILIAL AS BF_FILIAL,B1_COD AS BF_PRODUTO,B1_DESC,B1_TIPO,B1_GRUPO,B1_UM,B1_RASTRO,B1_LOCALIZ,B2_CM1,B2_LOCAL AS BF_LOCAL,BF_LOCALIZ='',B2_QATU AS BF_QUANT"
cQuery  +=" FROM   SB2210 SB2 LEFT JOIN SB1210 SB1 ON B2_FILIAL = B1_FILIAL AND B2_COD = B1_COD AND SB1.D_E_L_E_T_ <> '*'  "
cQuery  +=" WHERE SB2.D_E_L_E_T_<>'*' AND B2_FILIAL IN ('01','02') AND B2_QATU<>0 AND B1_LOCALIZ<>'S'   "
cQuery  +=" UNION    "
cQuery  +=" SELECT BF_FILIAL,B1_COD AS BF_PRODUTO,B1_DESC,B1_TIPO,B1_GRUPO,B1_UM,B1_RASTRO,B1_LOCALIZ,B2_CM1"
cQuery  +=" ,BF_LOCAL AS BF_LOCAL,BF_LOCALIZ,SUM(BF_QUANT) AS BF_QUANT  "
cQuery  +=" FROM SBF210 SBF LEFT JOIN SB1210 SB1 ON BF_FILIAL = B1_FILIAL AND BF_PRODUTO = B1_COD AND SB1.D_E_L_E_T_ <> '*'   "
cQuery  +=" LEFT JOIN SB2210 SB2 ON BF_FILIAL = B2_FILIAL AND BF_PRODUTO = B2_COD AND BF_LOCAL=B2_LOCAL AND SB1.D_E_L_E_T_ <> '*'  "
cQuery  +=" WHERE SBF.D_E_L_E_T_<>'*' AND BF_FILIAL IN ('01','02') AND BF_QUANT<>0 AND B1_LOCALIZ='S'   "
cQuery  +=" GROUP BY BF_FILIAL,B1_COD,B1_DESC,B1_TIPO,B1_GRUPO,B1_UM,B1_RASTRO,B1_LOCALIZ,B2_CM1,BF_LOCAL,BF_LOCALIZ"
cQuery  +=" )"
cQuery  +=" AS SBF_2 "
cQuery  +=" WHERE  "
cQuery  +=" BF_LOCAL IN ('A1','A2','A3','A5','A6','AS','AY','B1','B3','B5','B6','J1','J3','J5','J6')"
cQuery  +=" AND NOT BF_FILIAL+BF_PRODUTO+BF_LOCAL+BF_LOCALIZ IN "
cQuery  +=" (SELECT ZU_FILIAL+ZU_COD+ZU_LOCPAD+ZU_LOCALIZ FROM SZU210 WHERE D_E_L_E_T_<>'*' AND ZU_NUMDOC<>'ZERADO')"
*/


cQuery  :="SELECT ZI2_FILIAL,ZI2_DTINV,ZI2_COD,ZI2_DESC,ZI2_TIPO,ZI2_GRUPO,ZI2_UM,ZI2_RASTRO,ZI2_CTLEND,ZI2_LOCAL,ZI2_LOCALI" // ,ZI2_LOTE,ZI2_ORIGEM,ZI2_CONT1,ZI2_CONT2,ZI2_CONT3,ZI2_CONTAG,ZI2_QRCON1,ZI2_QRCON2,ZI2_QRCON3,ZI2_CM1,ZI2_SLDATU,ZI2_QTDINV,(ZI2_SLDATU-ZI2_QTDINV) AS ZI2_QTDIFE"
cQuery  +=" FROM "+Retsqlname("ZI2")+" WHERE D_E_L_E_T_<>'*' AND  ZI2_ORIGEM='S'  AND "
cQuery  +="ZI2_DTINV = '"+DTOS(Mv_Par01)+"'   AND "
cQuery  +="ZI2_LOCAL   BETWEEN  '"+Mv_Par02+"' AND '"+Mv_Par03+"' AND " 
cQuery  +="ZI2_LOCALI  BETWEEN  '"+Mv_Par04+"' AND '"+Mv_Par05+"' AND "
cQuery  +="ZI2_LOTE    BETWEEN  '"+Mv_Par06+"' AND '"+Mv_Par07+"' AND ZI2_FILIAL = '"+xFilial("ZI2")+"' "
cQuery  +="GROUP BY ZI2_FILIAL,ZI2_DTINV,ZI2_COD,ZI2_DESC,ZI2_TIPO,ZI2_GRUPO,ZI2_UM,ZI2_RASTRO,ZI2_CTLEND,ZI2_LOCAL,ZI2_LOCALI "
cQuery  +="ORDER BY ZI2_FILIAL,ZI2_LOCAL,ZI2_LOCALI"

TCQUERY cQuery NEW ALIAS TPV
COUNT TO  nRegis 
DbSelectArea("TPV")
DBGOTOP()  
ProcRegua(nRegis)  
nRegCont:=0
While !Eof()
    nRegCont:=nRegCont+1
    IncProc("Reg =>"+StrZero(nRegCont,10)+" / "+strZero(nRegis,10))   
	//
	DbSelectArea("SZU")                       
	DbSetOrder(4) // Filial+LOCPAD+LOCALIZ+COD+LOTECTL
	//
 	//If !SZU->(DbSeek(xFilial("SZU")+TPV->ZI2_LOCAL+TPV->ZI2_LOCALI+TPV->ZI2_COD+TPV->ZI2_LOTE ))			
 	If !SZU->(DbSeek(xFilial("SZU")+TPV->ZI2_LOCAL+TPV->ZI2_LOCALI+TPV->ZI2_COD))  // Sem o Lote
  		RecLock("SZU",.T.)
      	SZU->ZU_FILIAL := xFilial("SZU")
        SZU->ZU_NUMETQ := nNumEtq
      	SZU->ZU_COD    := TPV->ZI2_COD
      	SZU->ZU_CONT1  := 0 
      	SZU->ZU_CONT2  := 0
      	SZU->ZU_DESC   := TPV->ZI2_DESC   //POSICIONE("SB1",1,xFilial("SB1")+cCod ,"B1_DESC")
      	SZU->ZU_UM     := TPV->ZI2_UM     //POSICIONE("SB1",1,xFilial("SB1")+cCod ,"B1_UM")
      	SZU->ZU_TIPO   := TPV->ZI2_TIPO   //POSICIONE("SB1",1,xFilial("SB1")+cCod ,"B1_TIPO")
      	SZU->ZU_LOCPAD := TPV->ZI2_LOCAL 
      	SZU->ZU_DATA   := U_STOD(TPV->ZI2_DTINV)
      	SZU->ZU_ULTCONT:= 2
      	SZU->ZU_NUMDOC := "ZERADO" 
      	SZU->ZU_LOCALIZ:= TPV->ZI2_LOCALI
        SZU->ZU_DATACT1:= dDataBase
        SZU->ZU_RUA    := SubStr(TPV->ZI2_LOCALI,3,2)		
        SZU->ZU_TIME01 := TIME()
        //SZU->ZU_LOTECTL:= TPV->ZI2_LOTE
        SZU->ZU_USUCT1 := ''
        SZU->ZU_NUMDOC := 'ZERADO'	//Subs(DtoS(dDataBase),3,6)
        SZU->ZU_ORIGEM := "Z"
        SZU->ZU_DTINV1 := dDataBase
        //SZU->ZU_SLD01  := POSICIONE("SBF",1,xfilial("SBF")+TPV->ZI2_LOCAL +TPV->ZI2_LOCALI+TPV->ZI2_COD+Space(20)+TPV->ZI2_LOTE,"BF_QUANT")
        //SZU->ZU_DIF01  := SZU->ZU_CONT1 - SZU->ZU_SLD01
        If SZU->ZU_DIF01>0
           SZU->ZU_STATUS	:= "GANHO"
        ElseIf SZU->ZU_DIF01<0
           SZU->ZU_STATUS	:= "PERDA"
        ElseIf SZU->ZU_DIF01=0
           SZU->ZU_STATUS	:= "OK"
        Endif
	    // 
	    MsUnLock("SZU")      
	    nNumEtq   :=f_NumEtqII(nNumEtq)           
	End
	//
	DbSelectArea("TPV")
	DbSkip()
	// 
End
//
DbSelectArea("TPV")
DbCloseArea()
/*
DbSelectArea("SBF")
DbSetOrder(2)
DbSeek(xFilial("SBF")+cCod+cAlmox)
While SBf->(!Eof()).and. Sbf->Bf_Filial+Sbf->Bf_Produto+Sbf->Bf_Local == xFilial("SBF")+cCod+cAlmox
       DbSelectArea("SZU")              
       DbSetOrder(4) //  
       cLocaliz:=Sbf->Bf_Localiz
       EndIf          
  Sbf->(DbSkip())
End
RestArea(_aAreaAtu)
*/
Return 

********************************************************************************************************************
Static Function f_NumEtqII(pNum)
********************************************************************************************************************
Local cAlias
Local cOrdem
calias:=alias()
cOrdem:=dbSetOrder()

DbSelectArea("SZU")
DbSetOrder(01)
If !DbSeek(xFilial("SZU")+pNum)
  //Retorna ao Status antes de entra no Sf2460i
  dbSelectArea(calias)
  dbSetOrder(cOrdem)
  Return(pNum)
Endif 
While .T.
 pNum:= StrZero(Val(pNum)+1,6)
 If !DbSeek(xFilial("SZU")+pNum) 
   //Retorna ao Status antes de entra no Sf2460i
   dbSelectArea(calias)
   dbSetOrder(cOrdem)
   Return(pNum)
 Endif 
 If pNum="999999"
   Exit 
 Endif 
End     
//Retorna ao Status antes de entra no Sf2460i
dbSelectArea(calias)
dbSetOrder(cOrdem)
Return(pNum)