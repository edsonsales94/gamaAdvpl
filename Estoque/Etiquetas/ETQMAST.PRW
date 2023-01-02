#Include "PROTHEUS.CH"        
#include "rwmake.ch"

	
//--------------------------------------------------------------
/*/{Protheus.doc} MyFunction
Description

@param xParam Parameter Description                             
@return xRet Return Description                                 
@author Ricky Moraes - ricky.moraes@gamaitaly.com.br
@since 21/05/2020
/*/                                                             
//--------------------------------------------------------------
User Function ETQMAST()

Local oButton1
Local oButton2
Local oSay1,oSay2,oSay3,oSay4,oSay5,oSay6,oSay7,oSay8
Local XX,XY,A,B
//Local oMsg

Static oDlg
Private cImprime 
Private lOk:=.F.
Private oGet1,oGet2,oGet3,oGet4,oGet5,oGet6,oGet7,oGet8,oGet9

Private cOp    := Space(14) 
Private cCodigo:= Space(15)
Private dDataEtq  := CTOD("  /  /  ")
Private cDesc  := Space(40)
Private cLinha :=Space(20)
Private cLote  :=Space(20)
Private cTurno :={"01","02","03"}
Private nQtdEmb:=0
Private cEtq
Private nDUN14
Private cMemo
Private cMsg     := ""

XX:=8
XY:=17
A:=22
B:=22



  DEFINE MSDIALOG oDlg TITLE "Impressão Etq. Embalagem Master" FROM 000, 000  TO 500, 450 COLORS 0, 16777215 PIXEL

       
	@ XX,008 SAY oSay1 PROMPT "Nr. O.P :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL 
	@ XY,008 MSGET oGet1 VAR cOp Valid (BuscaOp()) SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL  F3 "SC2"
	
	@ XX+=A,008 SAY oSay2 PROMPT "Codigo Produto :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL     
	@ XY+=B,008 MSGET oGet2 VAR cCodigo When .F. SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL         
	
	@ XX+=A,008 SAY oSay3 PROMPT "Descrição :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ XY+=B,008 MSGET oGet3 VAR cDesc When .F. SIZE 150, 010 OF oDlg COLORS 0, 16777215 PIXEL         

    @ XX+=A,008 SAY oSay4 PROMPT "Linha" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ XY+=B,008 MSGET oGet4 VAR cLinha When .F.  PICTURE "@!A" SIZE 150, 010 OF oDlg COLORS 0, 16777215 PIXEL    
    
    @ XX+=A,008 SAY oSay6 PROMPT "Data Etq.:" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ XY+=B,008 MSGET oGet6 VAR dDataEtq  SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL  
    
    @ XX+=A,008 SAY oSay7 PROMPT "Turno :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ XY+=B,008 ComboBox oGet7 Items cTurno SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL      

    @ XX+=A,008 SAY oSay8 PROMPT "Qtd.por Emb :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ XY+=B,008 MSGET oGet8 VAR nQtdEmb PICTURE "@E 9999" SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL      
	   
	@ XX+=A,008 SAY oSay5 PROMPT "Lote :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ XY+=B,008 MSGET oGet5 VAR cLote PICTURE "@!A" SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL  

	//@ XX+=A,008 SAY oSay9 PROMPT "ETQ :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
	//@ XY+=B,008  MSGET oGet9 VAR cMemo  SIZE 250, 010 OF oDlg COLORS 0, 16777215 PIXEL  
	//@ XY+=B, 35 GET oMsg VAR cMsg MEMO SIZE 248,93 PIXEL OF oDlg
	//@ XY+=B,008 MSGET cMemo SIZE 200,035 OF oDlg COLORS 0, 16777215 PIXEL  

	//@ XY+=B,008 GET OMEMO    VAR CMEMO MEMO     SIZE 231,096     PIXEL OF ODLG



    @ XY+=B+5, 069 BUTTON oButton1 PROMPT "&Imprimir" ACTION (  Impetiq() ) SIZE 049, 017 OF oDlg PIXEL
    @ XY, 123 BUTTON oButton2 PROMPT "&Sair" ACTION ( oDlg:End() )SIZE 049, 017 OF oDlg PIXEL    
        

 ACTIVATE MSDIALOG oDlg CENTERED  

Return

 
Static Function BuscaOp() 

    cCodigo := Space(15)
    cDesc   := Space(50)
    cLinha  := Space(40)
    cLote   := Space(20)
    dDataEtq:= CTOD("  /  /  ")
    nQtdEmb := 0

    lOk:=.F.
   
If !Empty(cOp)
  dbselectarea("SC2")               
  DBSETORDER(1)
    If !(dbseek(xFilial("SC2")+LEFT(cOp,6), .T.)) .OR. SC2->C2_TPOP != "F" 

     alert("Ordem de Produção Não Econtrada !")
     lOk:=.F.
     oGet1:Refresh()
     oGet2:Refresh()
     oGet3:Refresh()
     oGet4:Refresh()
     oGet5:Refresh()
     oGet6:Refresh()
   
     oGet1:SetFocus()  
	else

	 cOp    :=SC2->C2_NUM+ SC2->C2_ITEM + SC2->C2_SEQUEN +"           "
	 cCodigo:=SC2->C2_PRODUTO 
	
     cLote  :=Space(20)
     cDesc  := left(Posicione("SB1",1,XFILIAL("SB1")+SC2->C2_PRODUTO,"B1_DESC"),50)
	 nQtdEmb:= Posicione("SB1",1,XFILIAL("SB1")+SC2->C2_PRODUTO,"B1_QE")
	 nDUN14= Posicione("SB1",1,XFILIAL("SB1")+SC2->C2_PRODUTO,"B1_DUN14")

			IF alltrim(SC2->C2_XEND)=="LINHA1"
				 cLinha:='01'
			ELSEIF alltrim(SC2->C2_XEND)=="LINHA2"
				 cLinha:='02'
			ELSEIF alltrim(SC2->C2_XEND)=="LINHA3"
				 cLinha:='03'
			ELSEIF alltrim(SC2->C2_XEND)=="LINHA4"
				 cLinha:='04'
			ELSEIF alltrim(SC2->C2_XEND)=="LINHA5"
				 cLinha:='05'
			ENDIF	






     DbSelectArea("SD3")
     dbSetOrder(1)
	
    	IF MSSeek(xFilial("SD3") + left(cOP,14) + cCodigo,.T. )
          dDataetq:= SD3->D3_EMISSAO
	   	ELSE
          MsgInfo("Não há apontamento deste Produto","Apontamento Produção")
		 	
	    ENDIF

     dbCloseArea()//SD3   
	
	PEGALOTE() 




	 lOk:=.T.    

     oGet1:Refresh()
     oGet2:Refresh()
     oGet3:Refresh()
     oGet4:Refresh()
     oGet5:Refresh()
     oGet6:Refresh()
     oGet8:Refresh()
     oGet6:SetFocus()
    Endif

Endif  
   
Return (lOk) 

Static Function Impetiq()


Local cPorta := "LPT1"
Local cModelo := "ZEBRA"
Local cTamanho:="050,030"
Local cFonte:="0"
MSCBPRINTER(cModelo, cPorta,,10,.F.,,,,,,.F.,)
MSCBCHKSTATUS(.F.)
MSCBBEGIN(1,6)
		// Box da Etiqueta -------------------------------------------------------
		//MSCBBOX(04,03,101,47,1)
		MSCBBOX(04,02,103,50,5,"B")//		Imprime um box ( nX1mm, nY1mm, nX2mm, nY2mm, [ nEspessura ], [ *cCor ] )
		
		//MSCBLineH(04,29,135,02,"B")  // x1,y1,x2,espessura ,cor

		MSCBSAY(6,04,cDesc,"N",cFonte,"050,040")
		MSCBSAY(6,11,"Nr.O.P: "+cOP,"N",cFonte,cTamanho)
		MSCBSAY(6,18,"Cod.: " + cCodigo,"N",cFonte,cTamanho)		
		MSCBSAY(47,18,"Nr. Lote: " + cLote,"N",cFonte,cTamanho)		
		MSCBSAY(85,18		,"Qtde: " + cValToChar(nQtdEmb),"N",cFonte,cTamanho)		
		MSCBSAY(6,25,"Data: "+DTOC(dDataEtq) ,"N",cFonte,cTamanho)
		MSCBSAY(40,25,"Turno: "+cLinha ,"N",cFonte,cTamanho)
		MSCBSAY(85,25,"LM: "+cLinha ,"N",cFonte,cTamanho)
			
		MSCBSAY(32,44,cValToChar(nDUN14) ,"N",cFonte,"050,050")

		//cod barras
		MSCBSAYBAR ( 50 , 11 , ALLTRIM(cEtq) , "N","MB07",6,.F.,.F.,.F.,"C",3,2,.F.)
		MSCBSAYBAR ( 24 , 33 , cValToChar(nDUN14) , "N","MB07",9,.F.,.F.,.F.,"C",4,2,.F.)
		
	
	
	MSCBEND()
	MSCBCLOSEPRINTER()
	U_MsgTimer ('Etiqueta Impressa !')
	
	

    
Return  

Static Function PEGALOTE()
Local cRet 
Local cAliasCB0:= GetNextAlias()
 BeginSql Alias cAliasCB0
   SELECT ISNULL(MAX(CB0_LOTE),' ') CB0_LOTE,ISNULL(MAX(CB0_CODETI),'0') CB0_NUMETQ  FROM %table:CB0% CB0 
   WHERE CB0_FILIAL=%xFilial:CB0% AND CB0_CODETI<>'' AND CB0_OP=%exp:cOP%
   AND CB0.%NotDel%
 EndSql                                          
dbSelectArea(cAliasCB0)  

DbGoTop()

cLote := (cAliasCB0)->CB0_LOTE
cEtq:= STRZERO( VAL((cAliasCB0)->CB0_NUMETQ) , 10)
dbSelectArea(cAliasCB0)
dbcloseArea()
//alert(cRet)
Return 


