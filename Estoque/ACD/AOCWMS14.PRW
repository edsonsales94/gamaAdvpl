#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'APVT100.CH'


/*
  Descri??o:  Movimentos internos Mod2 em ACD
  Uso:  Modulo ACD para baixa de materia prima RE3
  Desenvolvedor: Claudio Almeida
  Data: 22/09/2015
*/


//Movimentos internos
user function AOCWMS14()
Private  cOP:=SPACE(12) 
Private  cMat:=SPACE(6)
Private  cEndF:=SPACE(15)
Private  cCod:= SPACE(15)
Private  nQtd:= 0 
Private  cEndO:=SPACE(15)
Private  cLote:=SPACE(15) 
Private  acab := {"Cod","Qtde","Endereco","Lote"}
Private  aSize:= {15,06,08,15}
Private nPos:=1
Private nEmp:=0
Private aItens:={{"",0,"",""}}
Private cAlmox:=GETMV("MV_LOCPROC")
Private cDoc:=""
 VTClearBuffer() 
 DLVTCabec("Baixa de Material: " ,.F.,.F.,.T.)
 @ 01, 00 VTSay PadR('Ordem de Producao :' , VTMaxCol())
 @ 03, 00 VTSay PadR('End. Destino:' , VTMaxCol())

 @ 02, 00 VTGet cOP   Pict '@!'   VALID ( ValOP() .AND. U_VldTM( "501" ) )
 @ 04, 00 VTGet cEndF Pict '@!'   VALID (ValEnd("20",cEndF ))
 VTREAD
While .T.
  cCod:= SPACE(15)
  nQtd:= 0 
  nEmp:=0
  cEndO:=SPACE(15)
  cLote:=SPACE(15) 
  DLVTCabec("Itens da Baixa : " ,.F.,.F.,.T.)
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
DLVTCabec("Itens da Baixa : " ,.F.,.F.,.T.)
nPos:=VTaBrowse(1,0,VTMaxRow(),VTMaxCol(),aCab,aItens,aSize,'U_testectrl',nPos)
if nPos==0
  Baixa3MMb()
endif    
return

User Function testectrl(modo,nElem,nElemW) 
If modo == 1 
  VtAlert('Top') 
Elseif Modo == 2 
  VtAlert('Bottom') 
Else 
   If VTLastkey() == 27 
      VtAlert('Saindo sem atualizar os dados') 
      VTBeep(3) 
      return 1       
   elseIf VTLastkey() == 13      
      VtBeep(1) 
      return 0          
   Endif      
EndIf     
Return 2


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
       DLVTAviso('SIGAWMS',"Ordem de Produ??o Encerrada !!! Tente novamente.")
       cOP:=SPACE(12) 
     ELSE
      lRet:=.T.     
      cEndF:=C2_XEND
      cOP:=C2_NUM+C2_ITEM+C2_SEQUEN
      if len(alltrim(C2_CC))>0
        cMat:=C2_CC
      endif
     ENDIF 
   Else  
     DLVTAviso('SIGAWMS',"Ordem de Produ??o Invalida !!! Tente novamente."+cOP)
     cOP:=SPACE(12) 
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
  endif  
  IF SB1->B1_MSBLQL=="1" .or. SB1->B1_APROPRI<>"I"
      DLVTAviso('SIGAWMS',"Item bloqueado ou tipo de apropriacao invalida , Verifique com a engenharia! Tente Novamente")
      nEmp:=0        
      cCod :=space(15)
      Return(.f.) 
  endif     
  lRej:=.f. // valemp()
  if lRej
     DLVTAviso('SIGAWMS',alltrim(cCod)+"nao pertence a OP:"+COP+"! Tente Novamente")
     nEmp:=0
     Return(.f.)
  Endif
  nEmp:=0
  nEmp +=getEmpQtd()
  
  nEmp :=nEmp-(EmpAlmox())  //PEGA O EMPENHO PELAS REQUISICOES PAGAS RE3
  
Return(.t.)



Static Function ADLISTA()
Local cDesc,cUnd,nItem,nQemp,nSld,x
  nSld:=SaldSBF()   //VERIFICA O SALDO DO ENDERE?O
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
     DLVTAviso('SIGAWMS',"Saldo no Endere?o menor que o solicitado! Saldo: "+alltrim(str(nSld,12,5)) )
     nQtd:=0       
     Return .F. 
  ENDIF
  If nQemp>nEmp
    DLVTAviso('SIGAWMS',"Saldo de empenho menor que o solicitado! Saldo: "+alltrim(str(nEmp,12,5)) )
    nQtd:=0       
    Return .F. 
  Endif
  If nQtd==0 
    Return .F. 
  Endif
  if len(aItens)==1 .and. aItens[1,2]==0 
    aItens[1,1]:=cCod ; aItens[1,2]:=nQtd  ; aItens[1,3]:=cEndO ; aItens[1,4]:=cLote

  else 
   //aglutinar os codigos com mesmo lote e endere?o 
   nc:=ascan(aItens,{|x| x[1]==cCod})
   if nc==0 
     aadd(aItens ,{cCod,nQemp,cEndO,cLote})
   else
     nl:=ascan(aItens,{|x| alltrim(x[1])+x[4]==alltrim(cCod)+cLote})
     if nl==0 
       aadd(aItens,{cCod,nQtd,cEndO,cLote})
     else
       aItens[nl,2]+=nQtd  
     endif  
   Endif  
  Endif   
Return .T.



Static Function EmpAlmox()
Local lRet:=0
cAliasSD3:= GetNextAlias()
BeginSql Alias cAliasSD3 
 SELECT isnull(SUM(D3_QUANT),0) AS D3_QUANT FROM %Table:SD3% WHERE D3_FILIAL='01' 
 AND LEFT(D3_DOC,6)=%exp:left(alltrim(cOP),6)% AND D3_COD=%exp:left(alltrim(cCod),15)%
 AND D_E_L_E_T_='' AND D3_CF IN ('RE3','RE4') AND LEFT(D3_OBSERVA,5)='RQ/OP' AND D3_ESTORNO=''
EndSql 
dbSelectArea(cAliasSD3)  
dbgotop()
lRet:=(cAliasSD3)->D3_QUANT
dbSelectArea(cAliasSD3) 
dbclosearea() 
cAliasSD3:= GetNextAlias()
// PEGA OS SCRAPS DA OP PARA LIBERAR PAGAMENTO DO ITEM   - eliminado em 28/10/15 para pagamento pagar somente os empenhos e nao os scraps
//BeginSql Alias cAliasSD3 
// SELECT isnull(SUM(D3_QUANT),0) AS D3_QUANT FROM %Table:SD3% WHERE D3_FILIAL='01' 
// AND LEFT(D3_OP,11)=%exp:left(alltrim(cOP),11)% AND D3_COD=%exp:left(alltrim(cCod),15)%
// AND D_E_L_E_T_='' AND D3_CF='RE1' AND D3_ESTORNO=''
//EndSql 
//dbSelectArea(cAliasSD3)  
//dbgotop() 
//lRet:=lRet - (cAliasSD3)->D3_QUANT
//dbSelectArea(cAliasSD3) 
//dbclosearea()
Return(lRet) 

 
Static Function SaldSBF()  //saldo no endere?o
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
  AND D_E_L_E_T_='' AND D3_CF IN ('RE3','RE4') AND LEFT(D3_OBSERVA,5)='RQ/OP' AND D3_ESTORNO=''
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
Local cD3_TM:="501"  
Local cAlmox,cConta,cGrupo,cDoc,ordem,i
Private lMsHelpAuto := .T.
Private lAutoErrNoFile := .F.
cDoc:=DocSd3()
cTitulo:= "PAGTO-" 
ordem:=cOP

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
             {"D3_QUANT"  ,aItens[I,2]   ,NIL},;            // {"D3_QTSEGUM",1             ,NIL},; {"D3_ITEM"   ,STRZERO(I,2)  ,NIL},; ERRO EM 2UM
		     {"D3_LOCAL"  ,cAlmox        ,NIL},;
		     {"D3_CONTA"  ,cConta        ,NIL},;
		     {"D3_GRUPO"  ,cGrupo        ,NIL},;
		     {"D3_LOCALIZ",aItens[I,3]   ,NIL},;
		     {"D3_LOTECTL",aItens[I,4]   ,NIL},;
		     {"D3_OBSERVA","RQ/OP "+cOP+" Hr: "+left(time(),5),NIL},;
		     {"D3_EMISSAO",dDataBase                          ,nil}}  
		     
	aadd(_atotitem,_aitem)
	

  Next
   BeginTran()
   lMSErroAuto := .F.
   lMSHelpAuto := .T.
    
   //Pergunte( "MTA240" , .T. )
   MSExecAuto({|x,y,z|MATA241(x,y,z)},aCab,_atotitem,3)  //Usado para Gerar movimentos Intermos.
   lMSHelpAuto := .F.
  EndTran()
  MsUnlockAll() 
  If lMSErroAuto
      lShowMSM:=.F.
      VTBeep(2)
      VTAlert("Falha na gravacao da movimentacao, tente novamente." ,.T.,6000)
      DisarmTransaction()  
  ELSE      
     FOR I:=1 TO LEN(aItens)
        SD3->(dbSetOrder(2))     //Filial + D3_DOC + D3_COD
		IF SD3->( dbSeek( xFilial("SD3")+PADR(ALLTRIM(cDoc),9)+aItens[I,1] ) ) 
			       _cAprop  := ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+aItens[I,1],"B1_APROPRI")) 
			       _cLocPad := ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+aItens[I,1],"B1_LOCPAD"))
			       _cLocDes := GETMV("MV_LOCPROC")  
			       _cEndDes := cEndF  //ENDERE?A O PROCESSO
			       //u_fSd3265(3 , SD3->D3_COD , SD3->D3_NUMSEQ , SD3->D3_DOC , _cLocDes , _cEndDes )
	    ENDIF
	 Next		 
   Endif
  	
   IF lShowMSM
      DLVTAviso('SIGAWMS',cTitulo+" da Ordem Producao: "+ordem+" foi realizada com sucesso. Doc: "+cDoc )
   ELSE
      DLVTAviso('SIGAWMS',"Alguns itens da Ordem Producao No. "+ordem+" nao foram "+cTitulo+". Favor analisar! ")
   ENDIF   
	
ELSE
	DLVTAviso('SIGAWMS',AllTrim(cUserName)+", n?o ? permitido "+cTitulo+" Ordem Producao com data menor que a do fechamento!")
    
Endif 
Return

Static Function valemp()
	Local lRet := .F.
	BeginSql Alias "TRB"
     SELECT COUNT(D4_COD) REG FROM %Table:SD4% SD4
     WHERE D4_FILIAL=%xFilial:SD4% AND D4_OP=%Exp:cOP% AND D4_COD=%Exp:cCod% 
     AND SD4.%NotDel% 
    EndSql
	dbSelectArea("TRB")  
	DbGoTop()
	IF TRB->REG==0
	  lRet := .T.
	EndIf
	dbSelectArea("TRB") 
   dbcloseArea("TRB")
Return lRet

Static Function getEmpQtd()
	Local nRet := 0
	BeginSql Alias "TRB"
     SELECT SUM(D4_QTDEORI) REG FROM %Table:SD4% SD4
     WHERE D4_FILIAL=%xFilial:SD4% AND D4_OP=%Exp:cOP% AND D4_COD=%Exp:ccod% 
     AND SD4.%NotDel% 
    EndSql
	dbSelectArea("TRB")  
	DbGoTop()
	IF TRB->REG>0
		nRet :=TRB->REG
	EndIf
	dbSelectArea("TRB") 
   dbcloseArea("TRB")
Return nRet 

