#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'APVT100.CH'


/*
  Descrição:  Movimentos internos Mod2 em ACD
  Uso:  Modulo ACD para baixa de materia prima Kanbam RE3 
  Desenvolvedor: Claudio Almeida
  Data: 22/09/2015
*/


//Movimentos internos
user function AOCWMS15()
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
 DLVTCabec("Baixa KAMBAN: " ,.F.,.F.,.T.)
 @ 02, 00 VTSay PadR('End.Dest:' , VTMaxCol())
 @ 02, 13 VTGet cEndF Pict '@!'   VALID (ValEnd("20",cEndF ))
 VTREAD
While .T.
  cCod:= SPACE(15)
  nQtd:= 0 
  nEmp:=0
  cEndO:=SPACE(15)
  cLote:=SPACE(15) 
  DLVTCabec("Itens da Baixa : " ,.F.,.F.,.T.)
  @ 01, 00 VTSay PadR('CODIGO  :' , VTMaxCol())
  @ 02, 00 VTSay PadR('ENDERECO:' , VTMaxCol())
  @ 03, 00 VTSay PadR('QTDE....:' , VTMaxCol())
  @ 01, 13 VTGet cCod   Pict '@!' VALID (AtuCod())
  @ 02, 13 VTGet cEndO  Pict '@!' VALID (ValEnd("11",cEndO ))    
  @ 03, 13 VTGet nQtd   Pict '@R 999999.99' VALID (ADLISTA())
  //@ 03, 00 VTSay PadR('LOTE....:' , VTMaxCol())
  //@ 03, 13 VTGet cLote  Pict '@!'  VALID  IIF(POSICIONE("SB1",1,XFILIAL("SB1")+cCod ,"B1_RASTRO")=="L" .AND. EMPTY(cLote) , .F.,.T.)
  VTREAD
  If (VTLastKey()==27)
		Exit
  EndIf
 
Enddo
DLVTCabec("Itens da Baixa : " ,.F.,.F.,.T.)
nPos:=VTaBrowse(1,0,VTMaxRow(),VTMaxCol(),aCab,aItens,aSize,'U_KMBctrl',nPos)
if nPos==0
  Baixa3MMb()
endif    
return

User Function KMBctrl(modo,nElem,nElemW) 
If modo == 1 
  VtAlert('Top') 
Elseif Modo == 2 
  VtAlert('Bottom') 
Else 
   If VTLastkey() == 27 
      DLVTAviso('Saindo sem atualizar os dados') 
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
   Return (.F.)  
ENDIF
Return(lRet)


Static Function AtuCod()
Local cDesc,aRet,lRej
  DBSELECTAREA("SB1")
  DBSETORDER(1)
  DBSEEK(xfilial("SB1")+cCod)
  IF EOF() 
     DLVTAviso('SIGAWMS',"Codigo invalido!!!")
     Return(.f.)
  endif   
  if ALLTRIM(SB1->B1_XKANBAN)<>'S' .OR. SB1->B1_MSBLQL=="1"  .or. SB1->B1_APROPRI<>"I"
    IF SB1->B1_MSBLQL=="1"
      DLVTAviso('SIGAWMS',"Item bloqueado ou tipo de apropriaçao invalida , Verifique com a engenharia! Tente Novamente") 
    ELSE   
     DLVTAviso('SIGAWMS',"Somente itens KANBAN sao aceitos nesta rotina! Tente Novamente")
    ENDIF 
    nEmp:=0
    Return(.f.)
  Endif
Return(.t.)



Static Function ADLISTA()
Local cDesc,cUnd,nItem,nQemp,nSld, x
  nSld:=SaldSBF()   //VERIFICA O SALDO DO ENDEREÇO
  nQemp:=nQtd
  nQEnd:=nQtd
    //somar as quantidades dos itens iguas 
  For x:=1 to len(aItens)
   if alltrim(cCod)==alltrim(aItens[x,1])
     nQemp+=aItens[x,2]
   endif 
   if alltrim(cCod)==alltrim(aItens[x,1]) .and. alltrim(cEndO)==alltrim(aItens[x,3]) .and. alltrim(cLote)==alltrim(aItens[x,4])  
     nQEnd+=aItens[x,2]
   endif
  Next
  IF nQEnd>nSld
     DLVTAviso('SIGAWMS',"Saldo no Endereço menor que o solicitado! Saldo: "+alltrim(str(nSld,12,5)) )
     nQtd:=0       
     Return .F. 
  ENDIF
  If nQtd==0 
    Return .F. 
  Endif
  if len(aItens)==1 .and. aItens[1,2]==0 
    aItens[1,1]:=cCod ; aItens[1,2]:=nQtd  ; aItens[1,3]:=cEndO ; aItens[1,4]:=cLote
  else 
   //aglutinar os codigos com mesmo lote e endereço 
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


Static Function Baixa3MMb()
Local aArea2 := GetArea()  
Local aCab  :={}
Local _aItem := {} 
LOCAL _atotitem := {}  
LOCAL lShowMSM:=.T.
Local cD3_TM:="501"  
Local cAlmox,cConta,cGrupo,cDoc, i
Private lMsHelpAuto := .T.
Private lAutoErrNoFile := .F.
cDoc:=""
cTitulo:= "PAGTO-" 


IF (!GetMv("MV_ULMES") > dDataBase) 
 
  FOR I:=1 TO LEN(aItens)
    cAlmox:="11"   
    cConta:=Posicione("SB1",1,xfilial("SB1")+aItens[I,1],"B1_CONTA")
    cGrupo:=Posicione("SB1",1,xfilial("SB1")+aItens[I,1],"B1_GRUPO")
    cUm:=Posicione("SB1",1,xfilial("SB1")+aItens[I,1],"B1_UM")
    //   {"D3_QTSEGUM",1             ,NIL},;
    _aitem:={{"D3_COD"    ,aItens[I,1]   ,NIL},;
             {"D3_UM"     ,cUm           ,NIL},;
             {"D3_QUANT"  ,aItens[I,2]   ,NIL},;
             {"D3_ITEM"   ,STRZERO(I,2)  ,NIL},;
		     {"D3_LOCAL"  ,cAlmox        ,NIL},;
		     {"D3_CONTA"  ,cConta        ,NIL},;
		     {"D3_GRUPO"  ,cGrupo        ,NIL},;
		     {"D3_LOCALIZ",aItens[I,3]   ,NIL},;
		     {"D3_LOTECTL",aItens[I,4]   ,NIL},;
		     {"D3_OBSERVA","KBAM Hr: "+left(time(),5)+"US.:"+ Substring ( cUsuario , 7 , 12 ),NIL},;
		     {"D3_EMISSAO",dDataBase                          ,nil}}  
		     
	aadd(_atotitem,_aitem)
  Next
   BeginTran()
   cDoc:=GetSXENum("SD3","D3_DOC") 
   aCab := {{"D3_DOC"   ,cDoc  ,NIL},;
	        {"D3_TM"      ,cD3_TM    ,NIL}, ; 
	        {"D3_EMISSAO" ,dDataBase ,Nil} }
   lMSErroAuto := .F.
   lMSHelpAuto := .T.
    
   //Pergunte( "MTA240" , .T. )
   MSExecAuto({|x,y,z|MATA241(x,y,z)},aCab,_atotitem,3)  //Usado para Gerar movimentos Intermos.
   CONFIRMSX8()
   lMSHelpAuto := .F.
  If lMSErroAuto
      lShowMSM:=.F.
      VTBeep(2) 
      DLVTAviso("Falha na gravacao da movimentacao, tente novamente.")  
      MostraErro()
      DisarmTransaction()  
  ELSE      
     FOR I:=1 TO LEN(aItens)
        SD3->(dbSetOrder(2))     //Filial + D3_DOC + D3_COD
		IF SD3->( dbSeek( xFilial("SD3")+PADR(ALLTRIM(cDoc),9)+aItens[I,1] ) ) 
			       _cAprop  := ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+aItens[I,1],"B1_APROPRI")) 
			       _cLocPad := ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+aItens[I,1],"B1_LOCPAD"))
			       _cLocDes := GETMV("MV_LOCPROC")  
			       _cEndDes := cEndF  //ENDEREÇA O PROCESSO
			       //u_fSd3265(3 , SD3->D3_COD , SD3->D3_NUMSEQ , cDoc , _cLocDes , _cEndDes )
	    ENDIF
	 Next		 
   Endif
   EndTran()
   MsUnlockAll() 
		
   IF lShowMSM
      DLVTAviso('SIGAWMS',cTitulo+" da Ordem Producao: "+ordem+" foi realizada com sucesso. Doc: "+cDoc )
   ELSE
      DLVTAviso('SIGAWMS',"Alguns itens da Ordem Producao No. "+ordem+" nao foram "+cTitulo+". Favor analisar! ")
   ENDIF   
	
ELSE
	DLVTAviso('SIGAWMS',AllTrim(cUserName)+", não é permitido "+cTitulo+" Ordem Producao com data menor que a do fechamento!")
    
Endif 
Return





