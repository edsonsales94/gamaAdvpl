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
@since 28/08/2018
/*/                                                             
//--------------------------------------------------------------
User Function PASIMPLE()

Local oButton1
Local oButton2
Local oGet2 //data    
Local oGet3 //codigo    
Local oGet4 //descricao  
Local oGet5 //obs    

Local oGet7 //saldo
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSay10

Static oDlg

Private cImprime 
Private oSay5 
Private lOk:=.F.
Private oGet1
Private oGet6
Private oSay6
Private oSay7
Private oSay8
Private nGet3 := 0
Private dDtIni   := Date() //AVCTOD("  /  /  ")
Private cOp        := Space(12) 
Private cObs   	 :=Space(40)
Private nQtd       := 0
Private cCodigo    := Space(15)
Private cDesc      := Space(40)
Private cLocaliz :=Space(1)
Private nSaldo     := 0
Private cbImprime      := {"SIM","NAO"}
Private cNumPA:="" 
Private cQtd:=""
Private cUsername:=Space(15)
Private dData:=AVCTOD("  /  /  ") 
Private cTime:=""
Private cTpAponta:=space(3)




  DEFINE MSDIALOG oDlg TITLE "Apontamento de Produção Simples (PA)" FROM 000, 000  TO 400, 350 COLORS 0, 16777215 PIXEL


   
	@ 015,008 SAY oSay1 PROMPT "Ordem de Produção :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL 
	@ 024,008 MSGET oGet1 VAR cOp Valid (BuscaOp()) SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL  F3 "SC2"
	
	
	@ 015,105 SAY oSay8 PROMPT "Data Apontamento :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 024,105 MSGET oGet2 VAR dDtIni When .F. SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL         
	
	
	@ 044,008 SAY oSay7 PROMPT "Codigo Produto :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL     
	@ 054,008 MSGET oGet3 VAR cCodigo When .F. SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL         


	@ 044,105 SAY oSay4 PROMPT "Saldo a Produzir :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 054,105 MSGET oGet4 VAR nSaldo When .F. SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL         

	@ 068,008 SAY oSay3 PROMPT "Descrição :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 078,008 MSGET oGet5 VAR cDesc When .F. SIZE 150, 010 OF oDlg COLORS 0, 16777215 PIXEL         

	@ 092,008 SAY oSay5 PROMPT "Observação :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 102,008 MSGET oGet6 VAR cObs When lOK  PICTURE "@!A" SIZE 150, 010 OF oDlg COLORS 0, 16777215 PIXEL         
//	oGet6      := TGet():New( 102,008,{|u| If(PCount()>0,cObs:=u,cObs)},oDlg,150,010,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cObs",,)

	
	@ 116,008 SAY oSay2 PROMPT "Quantidade :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 125,008 MSGET oGet7 VAR nQtd PICTURE "@E 999,999.99" SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL         

	@ 116,105 SAY oSay6 PROMPT "Imprimir Etiqueta :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 005,145 SAY oSay10 PROMPT "F5 2ºVIA" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL 
  //	@ 010,145 SAY oSay11 PROMPT "End.:"+cLocaliz SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL 
	@ 125,105 ComboBox cImprime Items cbImprime Size 030,010 PIXEL OF oDlg  
	

	   
 
  //	@ 165, 001 BUTTON oButton3 PROMPT "&Imprimir" ACTION ( Impetiq() ) SIZE 049, 017 OF oDlg PIXEL
	@ 165, 069 BUTTON oButton3 PROMPT "&Apontar" ACTION ( BaixaProd() ) SIZE 049, 017 OF oDlg PIXEL
   @ 165, 123 BUTTON oButton4 PROMPT "&Sair" ACTION ( oDlg:End() )SIZE 049, 017 OF oDlg PIXEL    
   
   SetKey(VK_F5, {|| U_Etiqueta2Via() })  

    

 ACTIVATE MSDIALOG oDlg CENTERED  

SetKey(VK_F5,{||}) 
 
 
Static Function BuscaOp() 
 nSaldoOP:=0
 cCodigo    := Space(15)
 cDesc      := Space(50)
 cObs       := Space(40)
 nSaldo     := 0
 lOk:=.F.
   
If !Empty(cOp)
  dbselectarea("SC2")               
  DBSETORDER(1)
  If !(dbseek(xFilial("SC2")+LEFT(cOp,6), .T.)) .OR. SC2->C2_TPOP != "F" .OR. !Empty(SC2->C2_DATRF) 

      nSaldoOP:=0
	  cCodigo    := Space(15)
	  cDesc      := Space(50)
	  cObs       := Space(40)
	  nQtd       := 0
	  nSaldo     := 0
	  cOp			 :=Space(12)
	  cLocaliz	 :=Space(1)
	  cTpAponta:= space(3)
     alert("Ordem de Produção Encerrada ou Não Econtrada !")
     lOk:=.F.
     oGet6:Refresh()
     oGet1:SetFocus()

  
	else
	 cOp		:=SC2->C2_NUM+ SC2->C2_ITEM + SC2->C2_SEQUEN
	 cCodigo	:=SC2->C2_PRODUTO 
	 cDesc   := left(Posicione("SB1",1,XFILIAL("SB1")+SC2->C2_PRODUTO,"B1_XDESCNF"),50)
	 cLocaliz:=	left(Posicione("SB1",1,XFILIAL("SB1")+SC2->C2_PRODUTO,"B1_LOCALIZ"),1) 
	 cObs       := Space(40)
	 nSaldoOP := SC2->C2_QUANT - SC2->C2_QUJE
	 nSaldo     := nSaldoOP 
	 lOk:=.T.    
  	 oGet6:Refresh()
  	 oGet6:SetFocus()

  Endif

Endif  

   
Return .t.  


User Function Etiqueta2Via()
Local oGet1 //Num.Pa  
Local oSay1  
Local oSay2
Local oGet2 //Codigo Produto
Local oGet3 //Op
Local _cNumPa:=space(9)
Local oButton1
Local oButton2

Static oMainWnd

       DEFINE MSDIALOG oDlg2 TITLE "Impressão de 2 Via Etiqueta" FROM 0,0 to 200,300 of oMainWnd PIXEL
       
         
			@ 010,008 SAY oSay1 PROMPT "Num.Pa :" SIZE 109, 007 OF oDlg2 COLORS 0, 16777215 PIXEL 
			@ 019,008 MSGET oGet1 VAR _cNumPa Valid (CheckSd3(_cNumPa))>0 SIZE 060, 010 OF oDlg2 COLORS 0, 16777215 PIXEL // F3 "SC2"
			
			@ 032,008 SAY oSay2 PROMPT "Imprimir Etiqueta :" SIZE 109, 007 OF oDlg2 COLORS 0, 16777215 PIXEL
			@ 041,008 ComboBox cImprime Items cbImprime Size 030,010 PIXEL OF oDlg2  
	   
 

			@ 060, 015 BUTTON oButton1 PROMPT "&Imprimir" ACTION ( Impetiq(_cNumPa) ) SIZE 049, 017 OF oDlg2 PIXEL
		   @ 060, 070 BUTTON oButton2 PROMPT "&Sair" ACTION ( oDlg2:End() )SIZE 049, 017 OF oDlg2 PIXEL    
 

       ACTIVATE MSDIALOG oDlg2  CENTERED
       
 
Return

Static Function Impetiq(cNumPack)

Local cPorta := "LPT1"
Local cModelo := "GT800"
Local nTotal:= 0   
Local cAliasSD3ckPa := GetNextAlias()




 BeginSql Alias cAliasSD3ckPa    

  SELECT SD3.D3_COD,
  SD3.D3_EMISSAO,
  SD3.D3_DOC,
  SD3.D3_OP,
  SD3.D3_QUANT, 
  SD3.D3_TM,
  SD3.D3_NUMSEQ,
  SD3.D3_IDENT,
  SD3.D3_USUARIO,
  SD3.D3_XHORA,
  SD3.D3_OBSERVA
  FROM %Table:SD3% SD3 
  WHERE 
  SD3.D3_DOC=%exp:cNumPack%
  AND SD3.D3_FILIAL='01' 
  AND SD3.D_E_L_E_T_='' 
  AND SD3.D3_CF = 'PR0'
  AND SD3.D3_ESTORNO=''  

EndSql 
dbSelectArea(cAliasSD3ckPa)
IF cImprime =="SIM"

     
	 cDesc      := left(Posicione("SB1",1,XFILIAL("SB1")+(cAliasSD3ckPa)->D3_COD,"B1_XDESCNF"),50) 
	 cLocaliz:=	left(Posicione("SB1",1,XFILIAL("SB1")+SC2->C2_PRODUTO,"B1_LOCALIZ"),1) 
	 cNumPA :=(cAliasSD3ckPa)->D3_DOC 
	 cOP := (cAliasSD3ckPa)->D3_OP  
	 cCodigo:= (cAliasSD3ckPa)->D3_COD
	 cQtd:=str((cAliasSD3ckPa)->D3_QUANT,6) 
	 cUsername:= (cAliasSD3ckPa)->D3_USUARIO
	 dData:= STOD((cAliasSD3ckPa)->D3_EMISSAO)
	 cTime:=SUBSTR((cAliasSD3ckPa)->D3_XHORA,1,5)
	 cObs:=SUBSTR((cAliasSD3ckPa)->D3_OBSERVA,1,40)
	 
	 


	    MSCBPRINTER(cModelo,cPorta,,,.F.,,,,,,.T.)      
		MSCBBEGIN(1,6,100)    //( [ nxQtde ] [ nVeloc ] [ nTamanho ] [ lSalva ] )
		
		//LINHAS VERTICAIS E HORIZONTAIS--------------------------------------------
		MSCBBOX(06,05,135,063,02) //coluna 2
		MSCBLineH(06,29,135,02,"B")  // x1,y1,x2,espessura ,cor
		MSCBLineH(06,49,135,02,"B")  // x1,y1,x2,espessura ,cor
		MSCBLineV(80,29,49,02,"B")    // X1,Y1,Y2, ESPESSURA ,, COR
	
	
		//codigos de barras --------------------------------------------------------
		MSCBSAYBAR(10,14,cNumPA ,"N","C",8.36,.F.,.F.,.F.,,2,1)
		MSCBSAYBAR(10,39,cCodigo,"N","C",8.36,.F.,.F.,.F.,,2,1)
		MSCBSAYBAR(84,39,cQtd,"N","C",8.36,.F.,.F.,.F.,,2,1)
		//--------------------------------------------------------------------------
		// Dados da Etiqueta -------------------------------------------------------
		/* antiga
		MSCBSAY(10,07,"Cod.: "+RTRIM(cCodigo),"N","0","040,050")
		MSCBSAY(10,15,+RTRIM(cDesc),"N","0","020,030")
		MSCBSAY(90,19,"OP: "+SUBSTR(cOP,1,6),"N","0","040,050")
		MSCBSAY(10,30,"PA: "+cNumPA,"N","0","040,050")
		MSCBSAY(75,30,"Qtd:"+cQtd+" "+"PC" ,"N","0","040,050")
		MSCBSAY(08,052,"Operador: "+ SUBSTR (UsrFullName(__cUserID),1,15)  ,"N","0","030,040")
		MSCBSAY(82,052,"Data: "+DTOC(dDataBase) ,"N","0","030,040")
		MSCBSAY(08,058,"Hora: "+SUBSTR(TIME(), 1, 5) ,"N","0","030,040")
		MSCBSAY(50,058,"Obs: "+cObs ,"N","0","030,030")
		*/
		MSCBSAY(10,07,"Num.Pa : "+RTRIM(cNumPA),"N","0","040,050")
		MSCBSAY(10,26,+RTRIM(cDesc),"N","0","020,030")
		MSCBSAY(85,14,"OP: "+SUBSTR(cOP,1,6),"N","0","040,050")
		MSCBSAY(10,33,""+RTRIM(cCodigo),"N","0","030,040")
		MSCBSAY(84,33,"Qtd:"+ cQtd +" "+"PC" ,"N","0","040,050")
		MSCBSAY(08,052,"Operador: "+ cUsername  ,"N","0","030,040")
		MSCBSAY(85,07,"Data: "+DTOC(dData) ,"N","0","030,040")
		MSCBSAY(08,058,"Hora: "+cTime,"N","0","030,040")
		MSCBSAY(50,058,"Obs: "+cObs ,"N","0","030,030")
		
		
		
	
	MSCBEND()

	MSCBCLOSEPRINTER()
Else
 ALERT("Não Gera Etiqueta")
EndIf
dbclosearea() 
    
Return  

Static Function DocSd3()
 Local nDoc:=1
 Local cDocs
 cAliasSD3:= GetNextAlias()
	BeginSql Alias cAliasSD3 
	  SELECT isnull(MAX(D3_DOC),'000000000') AS D3_DOC 
	  FROM %Table:SD3% 
	   WHERE 
	   LEFT(D3_DOC,6)=%exp:left(alltrim(cOP),6)% 
	   AND D3_FILIAL='01' 
	   AND D3_CF ='PR0'
	  EndSql 
	dbSelectArea(cAliasSD3)  
	dbgotop()
	nDoc+=VAL(SUBSTR((cAliasSD3)->D3_DOC,7,3))
	dbSelectArea(cAliasSD3) 
	dbclosearea() 
	cDocs:=LEFT(alltrim(cOP),6)+STRZERO(nDoc,3) 
Return(cDocs)


Static Function CheckSd3(cNumPack)
Local nTotal:= 0   
Local cAliasSD3ckPa := GetNextAlias()

 BeginSql Alias cAliasSD3ckPa    

  SELECT 
  	SD3.D3_COD,
	SD3.D3_DOC,
	SD3.D3_QUANT, 
	SD3.D3_TM,
	SD3.D3_NUMSEQ,
	SD3.D3_IDENT,
	SD3.D3_USUARIO,
	SD3.D3_XHORA
	//SD3.D3_OBSERVA
  	//(SELECT COUNT(SD31.D3_DOC) FROM SD3010 SD31 WHERE SD31.D_E_L_E_T_='' AND SD31.D3_OBSERVA = 'NUMPA : '+SD3.D3_DOC AND SD31.D3_CF = 'DE4' AND LEFT(SD31.D3_DOC,3)='TR-') AS PAGO
  
  FROM %Table:SD3% SD3 
  WHERE 
  SD3.D3_DOC=%exp:cNumPack%
  AND SD3.D3_CF ='PR0'
  AND SD3.D3_FILIAL='01' 
  AND SD3.D_E_L_E_T_=''   
  AND SD3.D3_ESTORNO='' 
  
 
EndSql 
dbSelectArea(cAliasSD3ckPa) 
Count To nTotal
dbclosearea() 
 if nTotal=0
  alert("Num.Pa Não Econtrada !")
 endif
  
	
Return(nTotal)
	 


Static Function BaixaProd() 

Local aVetor
Local dData
Local nOpc := 3 //-Opção de execução da rotina,
Local _cOp := Space(12)
Local _cTM:="200"

Local _cObs:=""
Local _cEnd:=""

Local _cParc:=""
Local cDoc:=""
Local aVetor := {}
Local dData:=dDataBase  

cDoc:=DocSd3()
cNumPA:=DocSd3()




IF !Empty(cOp) .And.  nQtd>0
  dbselectarea("SC2")               
  DBSETORDER(1)
	  If !(dbseek(xFilial("SC2")+LEFT(cOp,6), .T.)) .OR. SC2->C2_TPOP != "F" .OR. !Empty(SC2->C2_DATRF) 
	  
	     nSaldoOP:=0
		  cCodigo    := Space(15)
		  cDesc      := Space(40)
		  cObs       := Space(40)
		  nQtd       := 0
		  nSaldo     := 0
		  cOp			 :=Space(12)
	     alert("Ordem de Produção Encerrada ou Não Econtrada !")
	     lOk:=.F.
	     oGet6:Refresh()   
	     oGet1:SetFocus()
	   
		else
		 _cOp		:=SC2->C2_NUM+ SC2->C2_ITEM + SC2->C2_SEQUEN 
	 	 _cCod	:=SC2->C2_PRODUTO 
		 _cObs       := cObs
		 _cEnd :=SC2->C2_XEND
		 nSaldoOP := SC2->C2_QUANT - SC2->C2_QUJE
		 nSaldo     := nSaldoOP 
		 _cPar:=IIF(nQtd=nSaldo,"T" ,"P" )
		 cQtd:=str(nQtd,6)
		 cUsername:= SUBSTR (UsrFullName(__cUserID),1,15)     
		 cTpAponta:= SC2->C2_XTPAPON
		
		If  !Empty(cTpAponta) 
			_cTM:=cTpAponta
		ENDIF
		
			 lMsErroAuto := .F.
			
			 aVetor := { ;                
 		               {"D3_DOC"     ,cDoc      ,NIL}, ;
		               {"D3_OP"        , _cOp , NIL},;
		               {"D3_TM"        , _cTM            , NIL},;
		               {"D3_QUANT"  , nQtd               , NIL},;
		               {"D3_PERDA"  , 0                , NIL},; 
		               {"D3_PARCTOT", _cPar              , NIL},;              
		               {"D3_OBSERVA" , _cObs, NIL},;           
		               {"D3_USUARIO" , cUsername, NIL},;
		               {"ATUEMP"    , "T"              , NIL};                              
		              }
//Executando o ExecAuto 
          MsgRun("Aguarde o Processamento...",,{||MSExecAuto({|x, y| mata250(x, y)},aVetor, nOpc )})        
		
			If lMsErroAuto
			 Alert("Erro")
			 mostraerro()
			Else
			IF CheckSd3(cNumPa)>0 
				 MsgAlert("Num.Pa: "+ cNumPa + " Apontado com sucesso !!!")
			 	 Impetiq(cNumPa)
				 nQtd:=0
				 BuscaOp()
			ELSE
				 Alert("Erro na Baixa, Verifique a OP, caso persista o erro acione o Suporte TI")
			ENDIF
			Endif
		EndIf
	 EndIf
Return   
