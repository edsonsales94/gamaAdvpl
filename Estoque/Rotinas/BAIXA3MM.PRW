#Include 'Protheus.ch'
#include "rwmake.ch"


//Baixa de requisições avulsa
User Function Baixa3MM()
Local aArea := GetArea()
Local cExprFilTop :=""  //"D3_CF='RE3' OR D3_CF='DE3'"
Private cCadastro := "Requisicao Automatica de Materiais"
Private cString   := "SD3"                                                
Private pOpc

dbSelectArea(cString)
SCP->(dbSetorder(4))


aRotina   := {{"Pesquisar" ,"AXPESQUI"       ,0,1},;//			  {"Visualizar","U_CPCONS1()"    ,0,2},;
			  {"Baixar",   "U_Pedido3MM('B')"    ,0,3},;
		      {"Estorno" , "U_Pedido3MM('E')"   ,0,4},; 			  
			  {"Legenda" ,	"U_Baixa3LEG()"   ,0,5}}

aCores 	:= {{'D3_CF == "RE3" .AND. D3_ESTORNO<>"S" ','ENABLE' },;  // Cores padroes do semaforo
            {'D3_CF == "DE3" .AND. D3_ESTORNO<>"S" ','BR_AMARELO' },;
			{'D3_CF$"DE3/RE3" .AND. D3_ESTORNO=="S" ' ,'DISABLE' } }
                                                     

mBrowse(06,01,22,75,cString,,,,,,aCores,,,,,,,,cExprFilTop )
RestArea(aArea)
Return


User Function Pedido3MM(pOpc)
Local aArea := GetArea()
Local aSize := {}
Local bOk := {|| Baixa3MMb(pOpc) }
Local bCancel:= {|| Fechar() }
Local cTitle:="Baixa de Material Avulso"
Private cCod, nQtd,nEmp 
Private aListCod := {{"    ","          ","                                                     ","   ","          ","               ","               "}}
Private oListCod,oCod,oQtd,oOP,oMat,oEnd,oLote,oSayLote
Private nListCod,lLin,cEnd,cLote,cMat,cOP
Private cAlmox:=GETMV("MV_LOCPROC")
PRIVATE cTitulo := IIF( pOpc=="B" , "PAGTO-" , IIF( pOpc=="E" ,"ESTORNO ", "EXCLUIR ") )
lLin:=.T.          
cLote:=""
aSize := MsAdvSize(.F.)
// Cria Fonte para visualização 
oFont1 := TFont():New('Courier new',,-14,.T.,.T.)
oFont2 := TFont():New('Arial',,-20,.T.,.T.)
Define MsDialog oDlg TITLE cTitle STYLE DS_MODALFRAME From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL
@ 105,10 LISTBOX oListCod VAR nListCod  FIELDS HEADER "ITEM", "CODIGO","DESCRICAO","UND","QUANTIDADE","ENDERECO","LOTE" PIXEL SIZE 460,150 OF oDlg
oListCod:SetArray( aListCod ) 
oListCod:bLine := {|| {aListCod[oListCod:nAt,1],aListCod[oListCod:nAt,2],aListCod[oListCod:nAt,3],;
					   aListCod[oListCod:nAt,4],aListCod[oListCod:nAt,5],aListCod[oListCod:nAt,6],aListCod[oListCod:nAt,7] } }
oListCod:Refresh() 

oSay:= TSay():New(40,05,{||'Ord.Produção:'},oDlg,,oFont1,,,,.T.,CLR_BLUE,CLR_RED,200,20) 
oSay:= TSay():New(55,05,{||'Requisitante:'},oDlg,,oFont1,,,,.T.,CLR_BLUE,CLR_RED,200,20)   
oSay:= TSay():New(65,05,{||'Endereço    :'},oDlg,,oFont1,,,,.T.,CLR_BLUE,CLR_RED,200,20) 
oSay:= TSay():New(85,10,{|| IIf(pOpc=="E","",'CODIGO')},oDlg,,oFont2,,,,.T.,CLR_RED,CLR_BLACK,200,20)   
oSay:= TSay():New(85,120,{|| IIf(pOpc=="E","ITENS PARA ESTORNO ",'QUANTIDADE')},oDlg,,oFont2,,,,.T.,CLR_RED,CLR_BLACK,200,20) 
oSayLote:= TSay():New(85,230,{||'LOTE'},oDlg,,oFont2,,,,.T.,CLR_RED,CLR_BLACK,200,20) 
oSayCod:= TSay():New(90,340,{||''},oDlg,,oFont2,,,,.T.,CLR_RED,CLR_BLACK,300,20) //avisos 
oSayItem:= TSay():New(262,10,{||'ITENS PAGOS :'},oDlg,,oFont2,,,,.T.,CLR_RED,CLR_BLACK,200,20) 

If pOpc=="E" 
 cOP:=SD3->D3_DOC; cMat:=SD3->D3_CC; cEnd:=SD3->D3_LOCALIZ
 cDoc:=SD3->D3_DOC
Else
 cOP:=SPACE(14) ; cMat:=SPACE(6); cEnd:=SPACE(15)
Endif
  
 
cCod:= SPACE(15)
nQtd:= 0 
cLote:=SPACE(15)
@40, 60 GET oOP  Var cOP  Valid ( ValOP() .AND. U_VldTM( "501" ) ) SIZE 060,09 OF oDlg PIXEL             
@55, 60 GET oMat Var cMat SIZE 060,09 OF oDlg PIXEL  PICTURE "9999"
@65, 60 GET oEnd Var cEnd Valid ( !Vazio() .AND. ExistCpo("SBE", "11"+cEnd)) SIZE 060,09 OF oDlg PIXEL PICTURE "@!"
oOP:oFont:=oFont1 ; oMat:oFont:=oFont1  ;  oEnd:oFont:=oFont1
oOP:CF3:="SC2" ; oEnd:CF3:="SBE"  ; oMat:CF3:="CTT"
 
              
@ 80,10  GET oCod VAR cCod SIZE 096,015 OF oDlg PIXEL PICTURE "@!"
@ 80,120 GET oQtd VAR nQtd SIZE 096,015 OF oDlg PIXEL PICTURE "@E 999,999.99999"
@ 80,230 GET oLote VAR cLote Valid ( !Vazio() .AND. ExistCpo("SB8", LEFT(cCod,15)+cLote,5)) SIZE 096,015 OF oDlg PIXEL
oCod:oFont:=oFont2 ; oCod:CF3:="SB1"  ; oCod:BLOSTFOCUS:={ ||  AtuCod() }
oQtd:oFont:=oFont2 ; oQtd:BLOSTFOCUS:={ || ADLISTA(.T.) }
oLote:oFont:=oFont2 ; oLote:BLOSTFOCUS:={ || AtuLote() }
oLote:CF3:="SB8"   ; oLote:LVISIBLECONTROL:=.F.  ; oSayLote:LVISIBLECONTROL=.F.  //Objetos do lote inicializados

If pOpc=="E" 
 oCod:LVISIBLECONTROL:=.F. 
 oQtd:LVISIBLECONTROL:=.F. 
 CarregaList()
ELSE
 SetFocus(oOP:HWND)
ENDIF
oDlg:lEscClose:= .F.  // NAO PERMITE FECHAR A JANELA COM A TECLA ESC    
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bOk , bCancel) CENTERED 
RestArea(aArea)
Return

Static Function CarregaList()
   dbselectarea("SD3")
   dbsetorder(9)
   DBSEEK(XFILIAL("SD3")+cDoc,.T.)
   DO WHILE !EOF() .AND. SD3->D3_DOC==cDoc .AND. SD3->D3_CF="RE3" 
    if lLin
     lLin:=.F.
     aListCod[1,1]:=SD3->D3_ITEM ; aListCod[1,2]:=SD3->D3_COD
     aListCod[1,3]:=POSICIONE("SB1",1,XFILIAL("SB1")+SD3->D3_COD,"B1_DESC")
     aListCod[1,4]:=POSICIONE("SB1",1,xfilial("SB1")+SD3->D3_COD,"B1_UM")
     aListCod[1,5]:=SD3->D3_QUANT ; aListCod[1,6]:=SD3->D3_LOCALIZ ; aListCod[1,7]:=SD3->D3_LOTECTL
    ELSE
     aadd(aListCod ,{ SD3->D3_ITEM,SD3->D3_COD, ;
     POSICIONE("SB1",1,XFILIAL("SB1")+SD3->D3_COD,"B1_DESC"), ; 
     POSICIONE("SB1",1,xfilial("SB1")+SD3->D3_COD,"B1_UM") , ;
     SD3->D3_QUANT, SD3->D3_LOCALIZ, SD3->D3_LOTECTL } )
    ENDIF 
   DBSKIP() 
   ENDDO
   oListCod:Refresh() ; oOP:Refresh() ; oMat:Refresh()
   oSayItem:SetText("ITENS PAGOS :"+strzero(LEN(aListCod),3)) ; oSayItem:CtrlRefresh()
Return



User Function Baixa3LEG()
BrwLegenda(cCadastro,"Legenda",{{"ENABLE","Material Pago"},;
	                            {"BR_AMARELO","Material Devolvido"},;
								{"DISABLE","Item Estornado"}})
Return .T.


Static Function ValOP()
Local lRet:=.F.
   dbselectarea("SC2")
   dbsetorder(1)
   dbseek(xfilial("SC2")+alltrim(cOP))
   if !eof() 
     IF len(alltrim(DTOS(SC2->C2_DATRF)))>0
       alert("Ordem de Produção Encerrada !!! Tente novamente.")
     ELSE
      lRet:=.T.
      cOP:=C2_NUM+C2_ITEM+C2_SEQUEN
      if len(alltrim(C2_CC))>0
        cMat:=C2_CC
        oEnd:SetFocus(oEnd:HWND)
      endif
     ENDIF 
   Else  
     alert("Ordem de Produção Invalida !!! Tente novamente.")
   Endif
Return lRet


Static Function AtuLote()
  oQtd:BLOSTFOCUS:={ || ADLISTA(.T.) }
  SetFocus(oQtd:HWND)
  oQtd:SelectAll()
Return

Static Function AtuCod()
Local cDesc,lRej
  lRej:=.F.
  cDesc:=Posicione("SB1",1,xfilial("SB1")+cCod,"B1_DESC")
  cRastro:=Posicione("SB1",1,xfilial("SB1")+cCod,"B1_RASTRO")  //VERIFICA SE CONTROLA LOTE
  DBSELECTAREA("SD4")
  DBSETORDER(2)
  DBSEEK(xfilial("SD4")+PADR(ALLTRIM(cOP),14)+cCod+cAlmox)
  If !eof() .AND. ALLTRIM(SD4->D4_COD)==ALLTRIM(cCod)
   nEmp :=SD4->D4_QTDEORI-(EmpAlmox())  //PEGA O EMPENHO PELAS REQUISICOES PAGAS RE3
  else
     cDesc:="Item nao pertence a esta OP! Tente Novamente"
     lRej:=.T.  ; nEmp:=0
  Endif
  If LEN(ALLTRIM(cDesc))==0
     cDesc:="Codigo Invalido!!, Tente Novamente."
     lRej:=.T.
  Endif
  If cRastro=='L' .AND. !lRej
   oQtd:BLOSTFOCUS:={ || ADLISTA(.F.) }
   oLote:LVISIBLECONTROL:=.T.  ; oSayLote:LVISIBLECONTROL=.T. 
   oSayLote:CtrlRefresh()
   oSayCod:SetText(cDesc)
   oSayCod:CtrlRefresh()
   SetFocus(oLote:HWND)
   oLote:SelectAll()
   Return
  Endif
  If lRej   
     oQtd:BLOSTFOCUS:={ || ADLISTA(.F.) }
     SetFocus(oCod:HWND)
     oCod:SelectAll()
     oSayCod:SetText(cDesc)
     oSayCod:CtrlRefresh()
     Return
  Endif 
  oQtd:BLOSTFOCUS:={ || ADLISTA(.T.) }
  oSayCod:SetText(cDesc)
  oSayCod:CtrlRefresh()
Return


Static Function ADLISTA(lAgir)
Local cDesc,cUnd,nItem,nQemp,x

  if !lAgir  ; Return ; Endif 
  nItem:=len(aListCod)+1
  cDesc:=Posicione("SB1",1,xfilial("SB1")+cCod,"B1_DESC")
  cUnd:=Posicione("SB1",1,xfilial("SB1")+cCod,"B1_UM")
  nQemp:=nQtd
  //somar as quantidades dos itens iguas 
  For x:=1 to len(aListCod)
   if alltrim(cCod)==alltrim(aListCod[x,2])
     nQemp+=aListCod[x,5]
   endif 
  Next
  
  If nQemp>nEmp
    Alert("Saldo de empenho menor que o solicitado! Saldo: "+alltrim(str(nEmp,12,5)) )
    nQtd:=0   ;  oQtd:CtrlRefresh()    
    SetFocus(oCod:HWND) 
    oCod:SelectAll()
    Return 
  Endif
  
  If nQtd==0 
    SetFocus(oQtd:HWND)
    oQtd:SelectAll()
    Return 
  Endif
  if lLin
    lLin:=.F.
    nItem:=1
    aListCod[1,1]:=1 ; aListCod[1,2]:=cCod ; aListCod[1,3]:=cDesc ; aListCod[1,4]:=cUnd
    aListCod[1,5]:=nQtd ; aListCod[1,6]:=cEnd ; aListCod[1,7]:=cLote
  else 
   //aglutinar os codigos com mesmo lote e endereço 
   nc:=ascan(aListCod,{|x| x[2]==cCod})
   if nc==0 
     aadd(aListCod ,{nItem,cCod,cDesc,cUnd,nQtd,cEnd,cLote})
   else
     nl:=ascan(aListCod,{|x| alltrim(x[2])+x[7]==alltrim(cCod)+cLote})
     if nl==0 
       aadd(aListCod ,{nItem,cCod,cDesc,cUnd,nQtd,cEnd,cLote})
     else
       aListCod[nl,5]+=nQtd  
     endif  
   Endif  
  Endif   
  nItem:=len(aListCod)
  oListCod:Refresh()
  oSayCod:SetText("") ;    oSayCod:CtrlRefresh()
  oSayItem:SetText("ITENS PAGOS :"+strzero(nItem,3)) ; oSayItem:CtrlRefresh()
  nQtd:=0   ;  oQtd:CtrlRefresh()
  cLote:=SPACE(15)
  oLote:LVISIBLECONTROL:=.F.  ; oSayLote:LVISIBLECONTROL=.F.
  cCod:=space(15) ; oCod:CtrlRefresh()
  oQtd:BLOSTFOCUS:={ || ADLISTA(.F.) }  
  SetFocus(oCod:HWND)
  oCod:SelectAll()
  
Return

Static Function Baixa3MMb(pOpc)
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
cTitulo:=IIF( pOpc=="B" , "PAGTO-" , IIF( pOpc=="E" ,"ESTORNO ", "EXCLUIR ") )
ordem:=cOP
if lMsHelpAuto

 alert("Documento Gerado..: "+cDoc)
endif 

IF (!GetMv("MV_ULMES") > dDataBase) .AND. (pOpc $"BE" )
 
  FOR I:=1 TO LEN(aListCod)
    cAlmox:="11"   //Posicione("SB1",1,xfilial("SB1")+cCod,"B1_LOCPAD")
    cConta:=Posicione("SB1",1,xfilial("SB1")+cCod,"B1_CONTA")
    cGrupo:=Posicione("SB1",1,xfilial("SB1")+cCod,"B1_GRUPO")
    IF I == 1
    
      IF pOpc=="B"
        cDoc:=DocSd3()
			    aCab := {{"D3_DOC"   ,cDoc  ,NIL},{"D3_TM"   ,cD3_TM  ,NIL}, ;
			           {"D3_CC"    	    ,cMat   	,NIL}, {"D3_EMISSAO"	,dDataBase      ,Nil} }
      ELSEIF pOpc == "E" 
        cDoc:=SD3->D3_DOC
     	 	   aCab := { {"D3_DOC" , cDoc , Nil} , {"D3_EMISSAO" ,ddatabase, NIL} }      
      ENDIF      
    Endif
    IF pOpc == "B"
		_aitem:={{"D3_COD"    ,aListCod[I,2] ,NIL}, {"D3_UM"    ,aListCod[I,4],NIL},{"D3_QUANT"	, aListCod[I,5],NIL} ,{"D3_ITEM"   ,STRZERO(aListCod[I,1],2)  ,NIL},;
		         {"D3_LOCAL"  ,cAlmox        ,NIL}, {"D3_CONTA" ,cConta       ,NIL},{"D3_GRUPO"	,cGrupo        ,NIL},;
		         {"D3_LOCALIZ",aListCod[I,6] ,NIL},{"D3_LOTECTL",aListCod[I,7],NIL},{"D3_OBSERVA","RQ/OP "+cOP+" Hr: "+left(time(),5),NIL}}  
			                       
	ELSEIF pOpc == "E"
			   
		_aitem:={ {"D3_COD"		,aListCod[I,2]	 ,NIL},{"D3_UM"	    ,aListCod[I,4]    ,NIL}, {"D3_QUANT"	,  aListCod[I,5]      ,NIL} ,;
		          {"D3_LOCAL"	,cAlmox   ,NIL},  {"D3_LOCALIZ"	,"",NIL},{"D3_LOTECTL"	,""        ,NIL}, {"D3_ESTORNO"	,"S"        ,NIL}, {"D3_OBSERVA","Est.p/ " +Substring ( cUsuario , 7 , 15 ) + " em " + DtoC ( MsDate() ) + " as " + left(Time(),5),NIL}}             
	ENDIF   
	aadd(_atotitem,_aitem)
  Next
   BeginTran()
   lMsErroAuto := .F. 
   Pergunte( "MTA240" , .T. )

   IF pOpc == "B"     
       MSExecAuto({|x,y,z| MATA241(x,y,z)},aCab,_atotitem,3)  //Usado para Gerar movimentos Intermos.
    
   ELSEIF pOpc == "E"  
      // Estornar Distribuicao 
	   SD3->(dbSetOrder(1))     //Filial + D3_DOC + D3_COD 
	   FOR I:=1 TO LEN(aListCod)
	    IF SD3->( dbSeek( xFilial("SD3")+PADR(ALLTRIM(cDoc),9)+aListCod[I,2] ) ) 
	      _cAprop  := ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+aListCod[I,2],"B1_APROPRI")) 
	      _cLocPad := ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+aListCod[I,2],"B1_LOCPAD"))
	      _cLocDes := IIF( _cAprop=="I" , GETMV("MV_LOCPROC") , _cLocPad ) 
	      _cEndDes := aListCod[I,6]   //PRECISA SER TESTADO
	      u_fSd3265(4, SD3->D3_COD , SD3->D3_NUMSEQ , SD3->D3_DOC , _cLocDes , _cEndDes )
	    ENDIF
	   NEXT I
	   SD3->(dbSeek(xFilial("SD3")+cDoc) )
	   cD3_TM := SD3->D3_TM
	   MSExecAuto({|x,y,z| MATA241(x,y,z)},aCab,_atotitem,6) //Usado para Gerar  Estorno
   Endif
   IF lMsErroAuto  
	   lShowMSM:=.F. 
	   Mostraerro()
	   DisarmTransaction() 
   ELSE      
     FOR I:=1 TO LEN(aListCod)
        If pOpc=="B"
		   	SD3->(dbSetOrder(2))     //Filial + D3_DOC + D3_COD
			IF SD3->( dbSeek( xFilial("SD3")+PADR(ALLTRIM(cDoc),9)+aListCod[I,2] ) ) 
			       _cAprop  := ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+aListCod[I,2],"B1_APROPRI")) 
			       _cLocPad := ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+aListCod[I,2],"B1_LOCPAD"))
			       _cLocDes := GETMV("MV_LOCPROC")  
			       _cEndDes := aListCod[I,6]  //PRECISA SER TESTADO
			       u_fSd3265(3 , SD3->D3_COD , SD3->D3_NUMSEQ , cDoc , _cLocDes , _cEndDes )
				
			ENDIF             
	    ENDIF
	 Next		 
   Endif
   EndTran()
   MsUnlockAll() 
		
   IF lShowMSM
      ALERT(cTitulo+" da Ordem Producao: "+ordem+" foi realizada com sucesso. Doc: "+cDoc )
   ELSE
      ALERT("Alguns itens da Ordem Producao No. "+ordem+" nao foram "+cTitulo+". Favor analisar! ")
   ENDIF   
	
ELSE
	ALERT(AllTrim(cUserName)+", não é permitido "+cTitulo+" Ordem Producao com data menor que a do fechamento!")
    
Endif 
oDlg:End()
Return

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

//RETORNA A QUANTIDADE DE REQUISIÇÕES PAGAS PARA ORDEM DE PRODUÇÃO
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
// PEGA OS SCRAPS DA OP PARA LIBERAR PAGAMENTO DO ITEM 
BeginSql Alias cAliasSD3 
 SELECT isnull(SUM(D3_QUANT),0) AS D3_QUANT FROM %Table:SD3% WHERE D3_FILIAL='01' 
 AND LEFT(D3_OP,11)=%exp:left(alltrim(cOP),11)% AND D3_COD=%exp:left(alltrim(cCod),15)%
 AND D_E_L_E_T_='' AND D3_CF='RE1' AND D3_ESTORNO=''
EndSql 
dbSelectArea(cAliasSD3)  
dbgotop() 
lRet:=lRet - (cAliasSD3)->D3_QUANT
dbSelectArea(cAliasSD3) 
dbclosearea()
Return(lRet)

Static Function Fechar()
 If MsgBox("Confirma Saida ?","Atencao","YESNO") 
  oDlg:End() 
 Endif
Return
