#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'APVT100.CH'


/*
  Descrição:  Movimentos internos Mod2 em ACD
  Uso:  Modulo ACD para baixa de material para Retrabalho
  Desenvolvedor: Claudio Almeida / Ricky
  Data: 22/09/2015 ; 17/06/19;
*/


//Movimentos internos


user function AOCRETRAB()

Private  cOP:=SPACE(14) 
Private  cMat:=SPACE(6)
Private  cEndF:=SPACE(15)
Private  cCod:= SPACE(15)
Private  cPai:= SPACE(15)
Private  nQtd:= 0 
Private  cEndO:=SPACE(15)
Private  cLote:=SPACE(15) 
Private  acab := {"Cod","Qtde","Endereco"}
Private  aSize:= {15,07,15}
Private nPos:=1
Private nEmp:=0
Private aItens:={{"",0,"",""}}
Private cAlmox:=GETMV("MV_LOCPROC")
Private cDoc:=""
 VTClearBuffer() 
 DLVTCabec("Retrab./508/ Baixa na OP " ,.F.,.F.,.T.)
 @ 01, 00 VTSay PadR('Ordem de Producao :' , VTMaxCol())
// @ 03, 00 VTSay PadR('End. Destino:' , VTMaxCol())

 @ 02, 00 VTGet cOP   Pict '@!'   VALID ( ValOP() .AND. U_VldTM( "508" ) )
// @ 04, 00 VTGet cEndF Pict '@!'   VALID (ValEnd("11",cEndF ))
 VTREAD
While .T.
  cCod:= SPACE(15)
  nQtd:= 0 
  nEmp:=0
  cEndO:=SPACE(15)
  cLote:=SPACE(15) 
//  DLVTCabec("Its.Retrabalho OP: " ,.F.,.F.,.T.)
	DLVTCabec("Its.Retrab. OP:"+cOP ,.F.,.F.,.T.)
  @ 01, 00 VTSay PadR('Codigo  :' , VTMaxCol())
  @ 03, 00 VTSay PadR('Endereco:' , VTMaxCol())
  @ 05, 00 VTSay PadR('Quant...:' , VTMaxCol())
  @ 02, 00 VTGet cCod   Pict '@!' VALID (AtuCod())
  @ 04, 00 VTGet cEndO  Pict '@!' VALID (ValEnd("11",cEndO ))
//  @ 03, 00 VTSay PadR('LOTE....:' , VTMaxCol())
//  @ 03, 13 VTGet cLote  Pict '@!'  VALID  IIF(POSICIONE("SB1",1,XFILIAL("SB1")+cCod ,"B1_RASTRO")=="L" .AND. EMPTY(cLote) , .F.,.T.)
  @ 06, 00 VTGet nQtd   Pict '@R 999999.99' VALID (ADLISTA())
  VTREAD
  If (VTLastKey()==27)
    Exit
  EndIf
 
Enddo
DLVTCabec("Its.Retrab. OP:"+cOP ,.F.,.F.,.T.)
nPos:= VTaBrowse(1,0,VTMaxRow(),VTMaxCol(),aCab,aItens,aSize,'U_testectrl',nPos)       



if nPos==0
  Baixa3MMb()
endif    
return



Static Function ValEnd(_cLocal,_cEnd)
Local lRet:=.T.
DBSelectArea('SBE')
DBSetOrder(1)
IF !DBSeek(xFilial('SBE')+_cLocal+_cEnd) 
   DLVTAviso('SIGAWMS', 'O endereco '+Alltrim(_cEnd)+' nao existe.!')   
   cEndO := SPACE(15)
   Return (.F.)        
ENDIF
Return(lRet)

Static Function ValOP()
Local lRet:=.F.
   dbselectarea("SC2")
   dbsetorder(1)
   dbseek(xfilial("SC2")+alltrim(cOP))
   if !SC2->(eof()) 
     IF len(alltrim(DTOS(SC2->C2_DATRF)))>0
       DLVTAviso('SIGAWMS',"Ordem de Produção Encerrada !!! Tente novamente.")
       cOP:=SPACE(14) 
       cPai:=SPACE(15) 
     ELSE
      lRet:=.T.     
      cEndF:=C2_XEND
      cOP:=C2_NUM+C2_ITEM+C2_SEQUEN
      cPai:=C2_PRODUTO
      if len(alltrim(C2_CC))>0
        cMat:=C2_CC
      endif
     ENDIF 
   Else  
     DLVTAviso('SIGAWMS',"Ordem de Produção Invalida !!! Tente novamente."+cOP)
     cOP:=SPACE(14) 
     cPai:=SPACE(15) 
   Endif
Return lRet


Static Function AtuCod()
Local cDesc,aRet,lRej
  DBSELECTAREA("SB1")
  DBSETORDER(1)
  DBSEEK(xfilial("SB1")+cCod)
  IF EOF()
     DLVTAviso('SIGAWMS',"Codigo invalido!!!")
     cCod :=space(15)
     Return(.f.)
  Endif  
  IF SB1->B1_MSBLQL=="1" .or. SB1->B1_FANTASM="S"
      DLVTAviso('SIGAWMS',"Item bloqueado, Verifique com a engenharia! Tente Novamente")
      nEmp:=0        
      cCod :=space(15)
      Return(.f.) 
  Endif 
  
  IF VerSG1()==0
  	   DLVTAviso('SIGAWMS',"Item não faz parte da estrutura !")
      nEmp:=0        
      cCod :=space(15)
      Return(.f.) 
  EndIf
  
   
Return(.t.)



Static Function ADLISTA()
Local cDesc,cUnd,nItem,nQemp,nSld, x
  nSld:=SaldSBF()   //VERIFICA O SALDO DO ENDEREÇO
  nQemp:=nQtd
  nQEnd:=nQtd
    //somar as quantidades dos itens iguais 
  For x:=1 to len(aItens)
   if alltrim(cCod)==alltrim(aItens[x,1])
     nQemp+=aItens[x,2]
   endif 
   if alltrim(cCod)==alltrim(aItens[x,1]) .and. alltrim(cEndO)==alltrim(aItens[x,3]) .and. alltrim(cLote)==alltrim(aItens[x,4])  
     nQEnd+=aItens[x,2]
   endif
  Next
  IF nQEnd>nSld
     DLVTAviso('SIGAWMS - SEM SALDO',"Saldo no Endereço: "+alltrim(str(nSld,12,5))+ " Saldo Empenhado: " +alltrim(str(nEmp,12,5)) )
     nQtd:=0       
     Return .F. 
  ENDIF
//    Return .F. 
//  Endif
  if len(aItens)==1 .and. aItens[1,2]==0 
    aItens[1,1]:=cCod ; aItens[1,2]:=nQtd  ; aItens[1,3]:=cEndO ; aItens[1,4]:=cLote
  else 
   //aglutinar os codigos com mesmo lote e endereço 
   nc:=ascan(aItens,{|x| x[1]==cCod})
   if nc==0 
     aadd(aItens ,{cCod,nQemp,cEndO,cLote})
   else
     nl:=ascan(aItens,{|x| alltrim(x[1])+x[3]==alltrim(cCod)+cEndO})
     if nl==0 
       aadd(aItens,{cCod,nQtd,cEndO,cLote})
     else
       aItens[nl,2]+=nQtd  
     endif  
   Endif  
  Endif   
Return .T.

Static Function SaldSBF()  //saldo no endereço
 Local nDoc:=0
 cAliasSBF:= GetNextAlias()
 BeginSql Alias cAliasSBF  
  SELECT isnull(SUM(BF_QUANT),0) AS BF_QUANT FROM %Table:SBF% WHERE BF_FILIAL='01' 
  AND BF_PRODUTO=%exp:cCod%  AND BF_LOCAL='11' AND BF_LOCALIZ=%exp:cEndO% AND BF_LOTECTL=%exp:ALLTRIM(cLote)% 
  AND D_E_L_E_T_='' 
 EndSql 
dbSelectArea(cAliasSBF)  
dbgotop()
nDoc+=(cAliasSBF)->BF_QUANT
dbSelectArea(cAliasSBF) 
dbclosearea() 
Return(nDoc)


Static Function DocSd3()
 Local nDoc:=1
 Local cDocs
 cAliasSD3:= GetNextAlias()
 BeginSql Alias cAliasSD3 
  SELECT isnull(MAX(D3_DOC),'000000000') AS D3_DOC FROM %Table:SD3% WHERE D3_FILIAL='01' 
  AND LEFT(D3_DOC,6)=%exp:left(alltrim(cOP),6)% 
  AND D_E_L_E_T_='' AND D3_CF IN ('RE0') AND LEFT(D3_OBSERVA,6)='RETRAB' AND D3_ESTORNO=''
 EndSql 
dbSelectArea(cAliasSD3)  
dbgotop()
nDoc+=VAL(SUBSTR((cAliasSD3)->D3_DOC,7,3))
dbSelectArea(cAliasSD3) 
dbclosearea() 
cDocs:=LEFT(alltrim(cOP),6)+STRZERO(nDoc,3) 
Return(cDocs)



Static Function Baixa3MMb()
Local aArea2 := GetArea()  
Local aCab  :={}
Local _aItem := {} 
LOCAL _atotitem := {}  
LOCAL lShowMSM:=.T.

Local cD3_TM:="508"  
Local cAlmox,cConta,cGrupo,cDoc,ordem,i
Private lMsHelpAuto := .T.
Private lAutoErrNoFile := .F.
cDoc:=DocSd3()
cTitulo:= "RETRABALHO - " 
ordem:=alltrim(cOP)

IF (!GetMv("MV_ULMES") > dDataBase) 
 
  FOR I:=1 TO LEN(aItens)
    cAlmox:="11"   
    cConta:=Posicione("SB1",1,xfilial("SB1")+aItens[I,1],"B1_CONTA")
    cGrupo:=Posicione("SB1",1,xfilial("SB1")+aItens[I,1],"B1_GRUPO")
    cUm:=Posicione("SB1",1,xfilial("SB1")+aItens[I,1],"B1_UM")
    IF I == 1
       cDoc:=DocSd3() 
       

	   aCab := {{"D3_DOC"     ,cDoc      ,NIL}, ;
	            {"D3_TM"      ,cD3_TM    ,NIL}, ; 
	            {"D3_EMISSAO" ,dDataBase ,Nil} }
    Endif
    _aitem:={{"D3_COD"    ,aItens[I,1]   ,NIL},;
             {"D3_UM"     ,cUm           ,NIL},;
             {"D3_QUANT"  ,aItens[I,2]   ,NIL},;
             {"D3_QTSEGUM",1             ,NIL},;
             {"D3_ITEM"   ,STRZERO(I,2)  ,NIL},;
		     {"D3_LOCAL"  ,cAlmox        ,NIL},;
		     {"D3_CONTA"  ,cConta        ,NIL},;
		     {"D3_GRUPO"  ,cGrupo        ,NIL},;
		     {"D3_LOCALIZ",aItens[I,3]   ,NIL},;
		     {"D3_LOTECTL",aItens[I,4]   ,NIL},;
		     {"D3_OBSERVA","RETRABALHO "+cOP+" Hr: "+left(time(),5),NIL},; 
		     {"D3_EMISSAO",dDataBase                          ,nil}}  
		     
	aadd(_atotitem,_aitem)
  Next
   BeginTran()
   lMSErroAuto := .F.
//   lMSHelpAuto := .T.
    
   //Pergunte( "MTA240" , .T. )
   MSExecAuto({|x,y,z|MATA241(x,y,z)},aCab,_atotitem,3)  //Usado para Gerar movimentos Intermos.   
  EndTran()

  MsUnlockAll() 
 
  If lMSErroAuto
//      lShowMSM:=.F.
      VTBeep(2)
      VTAlert("Falha na gravacao da movimentacao, tente novamente." ,.T.,6000)
      DisarmTransaction()  
 ELSE          

     FOR I:=1 TO LEN(aItens)
        SD3->(dbSetOrder(2))     //Filial + D3_DOC + D3_COD
		IF SD3->( dbSeek( xFilial("SD3")+PADR(ALLTRIM(cDoc),9)+aItens[I,1] ) ) 
			       _cAprop  := ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+aItens[I,1],"B1_APROPRI")) 
			       _cLocPad := ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+aItens[I,1],"B1_LOCPAD"))
			       _cLocDes := "11" //GETMV("MV_LOCPROC")
			       _cEndDes := cEndF  //ENDEREÇA O PROCESSO
			       //u_fSd3265(3 , SD3->D3_COD , SD3->D3_NUMSEQ , SD3->D3_DOC , _cLocDes , _cEndDes )
			       u_fSd3265(3 , SD3->D3_COD , SD3->D3_NUMSEQ , SD3->D3_DOC , SD3->D3_LOCAL , SD3->D3_LOCALIZ )
				
				//Este somente gravara um item mesmo
            /*
				RecLock("SD3",.F.)
				SD3->D3_OP := ordem
				MsUnlock()        
			  //	 DLVTAviso('SIGAWMS', ordem )
				*/

			       

	    ENDIF
	 Next		 
	 
   Endif
  	
   IF lShowMSM
      GravaOpSD3(cDoc,ordem)
      DLVTAviso('SIGAWMS',cTitulo+" da OP : "+ordem+" foi realizada com sucesso. Doc: "+cDoc )
      
   ELSE
      DLVTAviso('SIGAWMS',"Alguns itens da baixa OP: "+ordem+" não foram baixados. Favor analisar! ")
   ENDIF   
	
ELSE
	DLVTAviso('SIGAWMS',AllTrim(cUserName)+", não é permitido "+cTitulo+" na Ordem Producao com data menor que a do fechamento!")
    
Endif 
Return

Static Function VerSG1()
	Local nComp := 0
	BeginSql Alias "SG1T"
		SELECT COUNT(COD_COMP) COMP FROM VW_SG1
	   WHERE CODIGO= %Exp:cPai%  AND COD_COMP=%Exp:cCod% 

    EndSql
	dbSelectArea("SG1T")  
	DbGoTop()
	IF SG1T->COMP > 0
	  nComp := SG1T->COMP
	EndIf
	dbSelectArea("SG1T") 
   dbcloseArea("SG1T")
Return  nComp
                    

Static Function GravaOpSD3(sDoc,sOP)
LOCAL lMsErroAuto := .F. 
LOCAL cQuery := ""
Begin Transaction 

cQuery := "UPDATE SD3010 SET D3_OP ='"+ALLTRIM(sOP)+"' "                        
cQuery += " WHERE D3_DOC ='"+ALLTRIM(sDoc)+"'  AND D3_TM ='508'"
 
                      
nStatus := TCSQLExec(cQuery) 
   
  if (nStatus < 0)
   DLVTAviso("TCSQLError() " + TCSQLError())
  endif

End Transaction

Return 



