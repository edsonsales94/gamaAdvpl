#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³         ³ Autor ³                       ³ Data ³           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³                  ³Contato ³                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aplicacao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³  /  /  ³                                               ³±±
±±³              ³  /  /  ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function APONZTY()

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Declaração de cVariable dos componentes                                 ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Private DDTINI    := Date()
Private cCelula := Space(3)
Private cDesc := Space(40)
Private cLinha  := Space(30)
Private cCodigo := Space(15)
Private cOp     := Space(6)
Private nQtd  := 1    


/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Declaração de Variaveis Private dos Objetos                             ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
SetPrvt("oDlg","oSay1","oSay2","oSay3","oSay4","oSay5","oSay6","oSay7","oGetData","oGetOp","oGetModelo")
SetPrvt("oGet1","oGet2","oGet3","oGet4","oGet5","oGet6","btApontar","btSair")

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Definicao do Dialog e todos os seus componentes.                        ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

CHKFILE("ZTY")

  DEFINE MSDIALOG oDlg TITLE "Apontamento FPY Produção " FROM 000, 000  TO 400, 350 COLORS 0, 16777215 PIXEL


   
	@ 015,008 SAY oSay1 PROMPT "Ordem de Produção :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL 
	@ 024,008 MSGET oGet1 VAR cOp Valid (BuscaOp()) SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL  F3 "SC2CQ1"
	
	
	@ 015,105 SAY oSay2 PROMPT "Data Apontamento :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 024,105 MSGET oGet2 VAR dDtIni When .F. SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL         
	
	
	@ 044,008 SAY oSay3 PROMPT "Codigo Produto :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL     
	@ 054,008 MSGET oGet3 VAR cCodigo When .F. SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL         


	@ 044,105 SAY oSay4 PROMPT "Quantidade :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 054,105 MSGET oGet4 VAR nQtd When .F. SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL         

	@ 068,008 SAY oSay5 PROMPT "Descrição :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 078,008 MSGET oGet5 VAR cDesc When .F. SIZE 150, 010 OF oDlg COLORS 0, 16777215 PIXEL         

 	@ 095,008 SAY oSay6 PROMPT "Linha :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 105,008 MSGET oGet7 VAR cLinha When .F.  SIZE 080, 010 OF oDlg COLORS 0, 16777215 PIXEL         

		
	@ 119,008 SAY oSay7 PROMPT "Celula :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 129,008 MSGET oGet6 VAR cCelula PICTURE "@E 999" SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL         


	   
 

	@ 165, 069 BUTTON oButton3 PROMPT "&Apontar" ACTION ( ApontarFPY() ) SIZE 049, 017 OF oDlg PIXEL
   @ 165, 123 BUTTON oButton4 PROMPT "&Sair" ACTION ( oDlg:End() )SIZE 049, 017 OF oDlg PIXEL    
   
    

 ACTIVATE MSDIALOG oDlg CENTERED  

 
 
Static Function BuscaOp() 
 nSaldoOP:=0
 cCodigo    := Space(15)
 cDesc      := Space(50)


 lOk:=.F.
   
If !Empty(cOp)
  dbselectarea("SC2")               
  DBSETORDER(1)
  If !(dbseek(xFilial("SC2")+LEFT(cOp,6), .T.)) .OR. SC2->C2_TPOP != "F" .OR. !Empty(SC2->C2_DATRF) 

	  cCodigo    := Space(15)
	  cDesc      := Space(50)
	  cLinha :=Space(30)

	  nQtd       := 1
	  cOp			 :=Space(12)

     alert("Ordem de Produção Encerrada ou Não Econtrada !")
     lOk:=.F.
     oGet3:Refresh()
     oGet1:SetFocus()

  
	else
	 cOp		:=SC2->C2_NUM+ SC2->C2_ITEM + SC2->C2_SEQUEN
	 cCodigo	:=SC2->C2_PRODUTO 
	 cDesc   := left(Posicione("SB1",1,XFILIAL("SB1")+SC2->C2_PRODUTO,"B1_XDESCNF"),50)
	 cLinha :=SC2->C2_XEND
	 lOk:=.T.    
  	 oGet6:Refresh()
  	 oGet6:SetFocus()

  Endif

Endif  

   
Return .t.  



   
Static Function ApontarFPY()
Local cDoc:= space(6)

If alltrim(cCelula) !='' .AND. alltriM(cOp) !=''

	DbSelectArea("ZTY")
	cDoc:=GetSx8Num("ZTY","ZTY_DOC")
	
	if RecLock("ZTY", .T.)
			ZTY->ZTY_FILIAL := xFilial("ZTY")
			ZTY->	ZTY_DATA := DDATABASE
			ZTY->	ZTY_DOC := cDoc
			ZTY->	ZTY_OP :=SUBSTR(cOp,1,6)
			ZTY->	ZTY_HORA := GetRmtTime()
			ZTY->	ZTY_CELULA :=cCelula
			ZTY->	ZTY_QUANT :=nQtd
			ZTY->	ZTY_USUARI := SUBSTR (UsrFullName(__cUserID),1,30)     
			MsUnLock() // Confirma e finaliza a operação 
			ZTY->(dbclosearea())
		   ConfirmSx8()
	   	MsgInfo("Apontamento realizado com sucesso !")
	   	cCelula:=Space(3) 
	   	oGet6:Refresh()
	   	oGet6:SetFocus()
	   	
	else
	    RollbackSx8() 
	endif
	                   
Else
Alert("Favor, Informe o No. da Celula ou verifique a OP !")
 oGet6:Refresh()
 oGet6:SetFocus()
Endif


 

    

 
Return 

