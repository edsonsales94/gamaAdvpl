#Include "PROTHEUS.CH"        
#include "topconn.ch"          
#include 'parmtype.ch'
#include "rwmake.ch"


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
User Function atumodop()

Local oButton1
Local oButton2
Local oGet1
//Local cGet1 := "Digite a OP"
Local oGet2
//Local cGet2 := "Digite o Cod Mod"
Local oGet3                                                       
//Local nGet3 := 0
Local oGroup1
Local oSay1
Local oSay2
Local oSay3
Local oSay4

Static oDlg

Private oSay5
Private oSay6
Private cGet1 := SPACE(11)
Private cGet2 := SPACE(15)
Private nGet3 := 0

	cOP:=SPACE(12)
	cCodMOD:= SPACE(15)  // SAO AS MODS
//	cDoc:=SPACE(9)
	nQtd:= 0
 /*
  DEFINE MSDIALOG oDlg TITLE "Manutenção de OP" FROM 000, 000  TO 200, 300 COLORS 0, 16777215 PIXEL

    @ 013, 004 SAY oSay1 PROMPT "Manutenção de OPs ( Incluão das MODs )" SIZE 166, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 028, 004 SAY oSay2 PROMPT "OP:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 026, 020 MSGET oGet1 VAR cGet1 Valid (ValOP()) SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 043, 006 SAY oSay3 PROMPT "                   " SIZE 166, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 069, 027 BUTTON oButton1 PROMPT "Atualizar" ACTION ( IncMod() )SIZE 037, 012 OF oDlg PIXEL
    @ 069, 079 BUTTON oButton2 PROMPT "Cancelar" ACTION ( oDlg:End() )SIZE 037, 012 OF oDlg PIXEL

  ACTIVATE MSDIALOG oDlg CENTERED 
  */
  
/*  
  DEFINE MSDIALOG oDlg TITLE "Manutenção de OP" FROM 000, 000  TO 325, 500 COLORS 0, 16777215 PIXEL

    @ 002, 015 GROUP oGroup1 TO 152, 226 PROMPT "Incluão das MODs na OP" OF oDlg COLOR 0, 16777215 PIXEL
    @ 022, 020 SAY oSay1 PROMPT "OP :" SIZE 014, 007 OF oGroup1 COLORS 0, 16777215 PIXEL
    @ 042, 015 SAY oSay2 PROMPT "Cod. Mod :" SIZE 026, 007 OF oGroup1 COLORS 0, 16777215 PIXEL
    @ 063, 015 SAY oSay3 PROMPT "Qut.Unt.Hr:" SIZE 026, 007 OF oGroup1 COLORS 0, 16777215 PIXEL
    @ 020, 045 MSGET oGet1 VAR cGet1 Valid (ValOP()) SIZE 060, 010 OF oGroup1 COLORS 0, 16777215 PIXEL
    @ 040, 045 MSGET oGet2 VAR cGet2 Valid (ValMOD()) SIZE 060, 010 OF oGroup1 COLORS 0, 16777215 PIXEL
    @ 060, 045 MSGET oGet3 VAR nGet3 SIZE 060, 010 OF oGroup1 COLORS 0, 16777215 PIXEL PICTURE "@E 999,999.99999999"
    @ 021, 108 SAY oSay4 PROMPT " " SIZE 014, 020 OF oGroup1 COLORS 0, 16777215 PIXEL
    @ 042, 108 SAY oSay5 PROMPT " " SIZE 014, 020 OF oGroup1 COLORS 0, 16777215 PIXEL
    @ 106, 044 BUTTON oButton1 PROMPT "&Incluir Mods" ACTION ( IncMod() ) SIZE 049, 017 OF oGroup1 PIXEL
    @ 106, 112 BUTTON oButton2 PROMPT "&Cancelar" ACTION ( oDlg:End() ) SIZE 049, 017 OF oGroup1 PIXEL

  ACTIVATE MSDIALOG oDlg CENTERED           
  
*/


  DEFINE MSDIALOG oDlg TITLE "New Dialog" FROM 000, 000  TO 300, 500 COLORS 0, 16777215 PIXEL

    @ 009, 070 SAY oSay1 PROMPT "Manutenção de OPs ( Incluão das MODs )" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 027, 027 SAY oSay2 PROMPT "OP :" SIZE 014, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 025, 042 MSGET oGet1 VAR cGet1 Valid (ValOP()) SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 047, 012 SAY oSay7 PROMPT "Cod. Mod :"  SIZE 026, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 045, 042 MSGET oGet2 VAR cGet2 Valid (ValMOD()) SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 068, 011 SAY oSay8 PROMPT "Qut.Unt.Hr:" SIZE 026, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 065, 042 MSGET oGet3 VAR nGet3 SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL PICTURE "@E 999,999.99999999"
    @ 026, 108 SAY oSay5 PROMPT " " SIZE 120, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 047, 110 SAY oSay6 PROMPT " " SIZE 120, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 099, 069 BUTTON oButton3 PROMPT "&Incluir Mods" ACTION ( IncMod() ) SIZE 049, 017 OF oDlg PIXEL
    @ 098, 123 BUTTON oButton4 PROMPT "&Cancelar" ACTION ( oDlg:End() )SIZE 049, 017 OF oDlg PIXEL

 ACTIVATE MSDIALOG oDlg CENTERED  
  
Static Function ValOP()
	Local lRet:=.F.

	dbselectarea("SC2")
	dbsetorder(1)
	dbseek(xfilial("SC2")+Substr(cGet1,1,6))
	if !eof()
			lRet:=.T.
			//alert("Ordem de Produção encontrada !")
			oSay5:cCaption := "PA/PI :  "+C2_PRODUTO
			cOP:=C2_NUM+C2_ITEM+C2_SEQUEN

	Else
//		alert("Ordem de Produção não encontrada !!! Tente novamente.")
		oSay5:cCaption :="NÃO ENCONTRADO !!!"
		cOP:=""     
		lRet:=.F.

	Endif
Return lRet  
Static Function ValMOD()
	Local lRet:=.F.
IF Substr(cGet2,1,3)='MOD'
	dbselectarea("SB1")
	dbsetorder(1)
	dbseek(xfilial("SB1")+cGet2)
	if !eof()
			lRet:=.T.
			//alert("Ordem de Produção encontrada !")
			oSay6:cCaption :=Substr(SB1->B1_DESC,1,15)
			cCodMOD:=SB1->B1_COD

	Else
//		alert("Ordem de Produção não encontrada !!! Tente novamente.")
		oSay6:cCaption :="MOD NÃO ENCONTRADA !!!"
		cCodMOD:="" 
		lRet:=.F.

	Endif
ELSE  
	alert("Codigo MOD errado !")
END

Return lRet  

Static Function IncMod()


	Local cCodC2,cLocC2,cNumseq, cIdent
	Local dEmissao,nQtdSD3
	Local nRegis,nRegModSg1:=0
	Local cQryModG1,cQryAux := ""
IF ValMOD() .AND. ValOP()
	cCodC2  :=Posicione("SC2",1,xfilial("SC2")+Substr(cGet1,1,6),"C2_PRODUTO")
	cLocC2  :=Posicione("SC2",1,xfilial("SC2")+Substr(cGet1,1,6),"C2_LOCAL")
//	cEmissao:=LEFT(DTOS(Posicione("SC2",1,xfilial("SC2")+Substr(cGet1,1,6),"C2_EMISSAO")),6)
	
	
	cQryAux := ""
	cQryAux += "SELECT SD3EXT.D3_NUMSEQ,SD3EXT.D3_IDENT,SD3EXT.D3_DOC,SD3EXT.D3_QUANT,SD3EXT.D3_EMISSAO FROM SD3010  SD3EXT			"		+ STR_PULA
	cQryAux += "WHERE SD3EXT.D3_FILIAL='01' AND SD3EXT.D3_OP='"+ALLTRIM(cOP) +"' AND SD3EXT.D3_COD='"+ALLTRIM(cCodC2)+"'" 	+ STR_PULA
	cQryAux += "AND SD3EXT.D3_ESTORNO<>'S'  AND SD3EXT.D3_CF='PR0'  AND SD3EXT.D_E_L_E_T_=''	"		+ STR_PULA
	cQryAux += "AND"		+ STR_PULA
	cQryAux += " (SELECT COUNT(SD3INT.D3_COD) FROM SD3010 SD3INT WHERE SD3EXT.D3_OP=SD3INT.D3_OP AND SD3EXT.D3_DOC=SD3INT.D3_DOC AND  D3_COD='"+alltrim(cCodMOD)+ "' AND SD3INT.D_E_L_E_T_='' AND D3_ESTORNO<>'S') =0"		+ STR_PULA
	cQryAux += "GROUP BY SD3EXT.D3_NUMSEQ,SD3EXT.D3_IDENT,SD3EXT.D3_DOC,SD3EXT.D3_QUANT,SD3EXT.D3_EMISSAO,SD3EXT.D3_OP "		+ STR_PULA          	
	cQryAux += " "		+ STR_PULA          	
	cQryAux := ChangeQuery(cQryAux)  
	//Executando consulta e setando o total da régua
	
	TCQuery cQryAux New Alias "QRY_AUX"  
	
	Count to nRegis
//	QRY_AUX->(DbGoTop())
	If nRegis==0
		Alert("Existe Mod nessa OP!! Utilize a opção de *Reprocessar OPs* !") 
		QRY_AUX->(DbCloseArea())
		Return
	Endif 

	If MsgBox("Confirma a Inclusao de MOD na OP ?","Atenção","YESNO")
	else
		Return
	Endif

//	dbSelectArea("QRY_AUX")


	ProcRegua(nRegis)
    
 // VERIFICAR DENTRO DA ESTRUTURA SG1
 /*	cQryModG1:=""
	cQryModG1 += "SELECT G1_COD,G1_COMP,G1_QUANT,G1_INI,G1_FIM FROM SG1010 SG1 "		+ STR_PULA	
	cQryModG1 += "WHERE G1_COMP LIKE 'MOD%' AND G1_COD='" + ALLTRIM(cCodC2)+ "'"		+ STR_PULA
	cQryModG1 += "AND SG1.D_E_L_E_T_='' AND G1_FILIAL='' "		+ STR_PULA
	cQryModG1 += "AND G1_INI>= '"+ QRY_AUX->D3_EMISSAO + "' AND G1_FIM>='" + QRY_AUX->D3_EMISSAO + "' "		+ STR_PULA
	cQryModG1 += " "		+ STR_PULA          	
	cQryModG1 := ChangeQuery(cQryModG1)  
	TCQuery cQryModG1 New Alias "QRY_MODSG1"  
	Count to nRegModSg1


	IF nRegModSg1==0
		Alert("MOD não Cadastrada ! " +Chr(13)+Chr(10)+"SG1 - Estrutura do Produto !")
		oDlg:End()		
    ENDIF
    
   		QRY_MODSG1->(DbGoTop())
   	*/ 
    
    
		QRY_AUX->(dbgotop())    	
	    DO while QRY_AUX->(!eof())

		cNumseq:=QRY_AUX->D3_NUMSEQ
		cIdent :=QRY_AUX->D3_IDENT
		cDoc   :=QRY_AUX->D3_DOC
		nQtdSD3:=QRY_AUX->D3_QUANT
		dEmissao:=STOD(QRY_AUX->D3_EMISSAO)

    //  	DO while QRY_MODSG1->(!eof())   

         SD3->(RecLock("SD3",.T.))
		 SD3->D3_FILIAL :=XFILIAL("SD3")
		 SD3->D3_TM     :="999"
		 SD3->D3_COD    :=cCodMOD
		 SD3->D3_UM     :=POSICIONE("SB1",1,XFILIAL("SB1")+cCodMOD,"B1_UM")
		 SD3->D3_QUANT  :=nGet3  *   nQtdSD3
		 SD3->D3_CF     :="RE1"
		 SD3->D3_CONTA  :=POSICIONE("SB1",1,XFILIAL("SB1")+cCodMOD,"B1_CONTA")
		 SD3->D3_OP     :=PADR(cOP,13)
		 SD3->D3_LOCAL  :=POSICIONE("SB1",1,XFILIAL("SB1")+cCodMOD,"B1_LOCPAD")
		 SD3->D3_DOC    :=cDoc
		 SD3->D3_GRUPO  :=POSICIONE("SB1",1,XFILIAL("SB1")+cCodMOD,"B1_GRUPO")
		 SD3->D3_EMISSAO:= STOD(QRY_AUX->D3_EMISSAO)
		 SD3->D3_NUMSEQ :=cNumseq
		 SD3->D3_NIVEL  :="99"
		 SD3->D3_TIPO   :=POSICIONE("SB1",1,XFILIAL("SB1")+cCodMOD,"B1_TIPO")
		 SD3->D3_USUARIO:="AJUSTEMOD"
		 SD3->D3_IDENT  :=cIdent
		 SD3->D3_CHAVE  :="E0"
		 SD3->(MsUnLock())
		 
  //		QRY_MODSG1->(DbSkip())	  
		IncProc("Incluindo Mod no Document :"+cDoc)	 
      // ENDDO
//	  	QRY_MODSG1->(DbGoTop())
		QRY_AUX->(DbSkip())
	ENDDO                

//		QRY_MODSG1->(DbCloseArea())
		QRY_AUX->(DbCloseArea())
		//MsgBox("As MODs devem esta dentro da estutura do Produto","Atencão - Cadastro","OK",MB_ICONEXCLAMATION)
		MessageBox("Processo Finalizado !","Fim da Manutenção",MB_ICONASTERISK)
		oDlg:End()             
ELSE
 		MessageBox("Erro Campos !","Fim da Manutenção",MB_ICONASTERISK) 
END

Return



Return