#Include "PROTHEUS.CH"        
#include "topconn.ch"          
#include "parmtype.ch"
#include "rwmake.ch"
#INCLUDE "TBICONN.CH"


//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
#define MB_ICONEXCLAMATION          48
#define MB_ICONASTERISK             64
	
//--------------------------------------------------------------
/*/{Protheus.doc} MyFunction
Description

@param xParam Parameter Description                             
@return xRet Return Description                                 
@author Ricky Moraes - ricky.moraes@gamaitaly.com.br
@since 20/05/2020
Tela para explosão de estrutura do produto
/*/                                                            
//--------------------------------------------------------------
User Function fBOM()

Local oButton1
Local oButton2
Local oSay1,oSay2,oSay3
Local cProduto :=space(15)
Local nQuant :=0
Local lImp:=.F.
Local aProd:={}

PRIVATE oGet1, oGet2, oGet3
Private cDescricao

Static oDlg

//Private cFiltro := "B1_TIPO $ 'PA,PI'" //Expressao do Filtro


XX:=8
XY:=17
A:=22
B:=22

    DEFINE MSDIALOG oDlg TITLE "BOM - Carregar Lista" FROM 000, 000  TO 300, 380 COLORS 0, 16777215 PIXEL
    
        @ XX,008 SAY oSay1 PROMPT "Cod.Pai :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL 
        @ XY,008 MSGET oGet1 VAR cProduto  Valid (ValBOM(cProduto))   PICTURE "@!A" SIZE 060, 010 OF oDlg  COLORS 0, 16777215 PIXEL F3 "SB1SG1" 
        
        //oGet1:bF3 := &('{|| IIf(ConPad1(, , , "SB1", , , .F., , , , , , '+ cFiltro +'),Eval({|| cProduto := SB1->B1_COD,cDescricao:= SB1->B1_DESC, oGet2:Refresh()}),.T.)}')      

        @ XX+=A,008 SAY oSay2 PROMPT "Descrição :" SIZE 120, 007 OF oDlg COLORS 0, 16777215 PIXEL 
        @ XY+=B,008 MSGET oGet2 VAR cDescricao  PICTURE "@!A" SIZE 160, 010 OF oDlg  COLORS 0, 16777215 PIXEL When .F.
        

        @ XX+=A,008 SAY oSay3 PROMPT "Quant. :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL     
        @ XY+=B,008 MSGET oGet3 VAR nQuant  PICTURE "99999" SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL   

       
        @ XY+=B+5, 069 BUTTON oButton1 PROMPT "&Importar" ACTION (lImp:=sfImporta(cProduto,nQuant),oDlg:End()) SIZE 049, 017 OF oDlg PIXEL
        @ XY, 123 BUTTON oButton2 PROMPT "&Sair" ACTION ( oDlg:End() )SIZE 049, 017 OF oDlg PIXEL    
   
      //SetKey(VK_F5, {|| U_Etiqueta2Via() })  

     ACTIVATE MSDIALOG oDlg CENTERED  

    //SetKey(VK_F5,{||})
    //RETURN() 

iF lImp
  AAdd(aProd,{cProduto,nQuant})
 
endif  


RETURN(aProd)

******************************************************************************************************************************************************
Static Function sfImporta(_cProduto,_nQuant)
******************************************************************************************************************************************************
LOCAL lOk:=.F.
IF !EMPTY(_cProduto) .AND. !EMPTY(_nQuant)
  //RETURN(cProduto,nQuant)
  lOk:=.T.
  //alert("OK")
ENDIF 

RETURN(lOk)

****************************************************************************************************************************************************** 
Static Function ValBOM(cCodigo) 
******************************************************************************************************************************************************
 lOk:=.F.
   
If !Empty(cCodigo)
  dbselectarea("SG1")               
  DBSETORDER(1)
    If !dbseek(xFilial("SG1")+cCodigo, .T.)
        cDescricao      := Space(50)
        alert("Produto não encontado ou sem Lista BOM")
        lOk:=.F.
        oGet2:Refresh()
        oGet1:SetFocus()
    
    else
	   cCodigo	:=SG1->G1_COD
	   cDescricao := left(Posicione("SB1",1,XFILIAL("SB1")+SG1->G1_COD,"B1_XDESCNF"),50)
	   lOk:=.T.    
  	 oGet2:Refresh()
  	 oGet3:SetFocus()

    Endif

Endif  

   
Return(lOk) 
