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
User Function fAlmoxExp()

Local oButton1
Local oButton2
Local oSay1,oSay2,oSay3,oSay4,oSay5,oSay6,oSay7,oSay8,oSay9
Local oGet1, oGet2,oGet3,oGet4,oGet5,oGet6,oGet7,oGet8,oGet9

Local cNumSenf :=ZT3->ZT3_NUM
Local cSetor := ZT3->ZT3_SETOR
Local cDestino :=ZT3->ZT3_NOME
Local cObs :=ZT3->ZT3_OBS
Local cSol:=  ZT3->ZT3_SOL

Local  nPesoBru :=ZT3->ZT3_PBRUTO
Local nPesoLiq :=ZT3->ZT3_PLIQUI
Local  nVolume:=ZT3->ZT3_VOLUME
Local  cEspecie:=ZT3->ZT3_ESPECI
Local cTransp :=ZT3->ZT3_TRANSP

Static oDlg


XX:=8
XY:=17
A:=22
B:=22

    DEFINE MSDIALOG oDlg TITLE "Expedição - Liberar Carga/Faturamento" FROM 000, 000  TO 450, 400 COLORS 0, 16777215 PIXEL
    
        @ XX,008 SAY oSay1 PROMPT "Num.Senf :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL 
        @ XY,008 MSGET oGet1 VAR cNumSenf SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL When .F.
            
        @ XX,105 SAY oSay2 PROMPT "Setor :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ XY,105 MSGET oGet2 VAR cSetor When .F. SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL         
            
        @ XX+=A,008 SAY oSay3 PROMPT "Solicitante :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL     
        @ XY+=B,008 MSGET oGet3 VAR cSol When .F. SIZE 150, 010 OF oDlg COLORS 0, 16777215 PIXEL         

        @ XX+=A,008 SAY oSay4 PROMPT "Destinatário :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ XY+=B,008 MSGET oGet4 VAR cDestino When .F. SIZE 150, 010 OF oDlg COLORS 0, 16777215 PIXEL         

        @ XX+=A,008 SAY oSay5 PROMPT "Observações :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ XY+=B,008 MSGET oGet5 VAR cObs When .F. PICTURE "@!A" SIZE 150, 010 OF oDlg COLORS 0, 16777215 PIXEL             
        
        @ XX+=A,008 SAY oSay6 PROMPT "Peso Bruto :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ XY+=B,008 MSGET oGet6 VAR nPesoBru PICTURE "@E 999,999.99" SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL         

        @ XX,105 SAY oSay7 PROMPT "Peso Líquido :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ XY,105 MSGET oGet7 VAR nPesoLiq PICTURE "@E 999,999.99" SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL         

        @ XX+=A,008 SAY oSay8 PROMPT "Volume :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ XY+=B,008 MSGET oGet8 VAR nVolume PICTURE "@E 999,999.99" SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL         

        @ XX,105 SAY oSay9 PROMPT "Espécie :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ XY,105 MSGET oGet9 VAR cEspecie PICTURE "@!A" SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL             

        @ XX+=A,008 SAY oSay9 PROMPT "Cod.Transp. :" SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL
        @ XY+=B,008 MSGET oGet9 VAR cTransp PICTURE "@!A" SIZE 060, 010 OF oDlg F3 "SA4"  COLORS 0, 16777215 PIXEL 
          

        @ XY+=B+5, 069 BUTTON oButton1 PROMPT "&Gravar" ACTION ( iif(AltCarga(cNumSenf,nPesoBru,nPesoLiq,nVolume,cEspecie, cTransp),oDlg:End(),.F. )) SIZE 049, 017 OF oDlg PIXEL
        @ XY, 123 BUTTON oButton2 PROMPT "&Sair" ACTION ( oDlg:End() )SIZE 049, 017 OF oDlg PIXEL    
   
      //SetKey(VK_F5, {|| U_Etiqueta2Via() })  

     ACTIVATE MSDIALOG oDlg CENTERED  

    //SetKey(VK_F5,{||})
RETURN 


******************************************************************************************************************************************************
Static Function AltCarga(cNumSenf,nPesoBru,nPesoLiq,nVolume,cEspecie, cTransp)
******************************************************************************************************************************************************
Local aArea := ZT3->(GetArea()) 

    ZT3->(DbSetOrder(1))                      
    ZT3->(MsSeek(FwXFilial("ZT3") + cNumSenf ))

    IF ZT3->ZT3_STATUS $ "1-2" 
        //GRAVA DADOS ALTERADOS
        RecLock("ZT3",.F.) 
        ZT3->ZT3_PBRUTO	:= nPesoBru
        ZT3->ZT3_PLIQUI := nPesoLiq
        ZT3->ZT3_VOLUME	:= nVolume	
        ZT3->ZT3_ESPECI	:= cEspecie
        ZT3->ZT3_TRANSP :=  cTransp
        MsUnLock() 
           
                    If MsgNoYes("Deseja Libera Pedido para o Setor  Fiscal ?")                
				     
                        ZT4->(DbGoTop())  
                        ZT4->(MsSeek(FwXFilial("ZT4") + ZT3->ZT3_NUM))
                        While ZT4->ZT4_NUMSF == ZT3->ZT3_NUM .AND. !ZT4->(eof())
                            IF ZT4->ZT4_QTDATE==0
                                RecLock("ZT4",.F.) 
                                ZT4->ZT4_BLOCK:=" "
                                ZT4->ZT4_QTDATE:=ZT4_QTDSOL
                                ZT4->ZT4_DTLIB :=DATE()
                                ZT4->ZT4_USLIB:=UsrRetName(RETCODUSR())
                                MsUnLock() 
                            ENDIF
                            ZT4->(DbSkip())
                        End
                        RecLock("ZT3",.F.) 
                        ZT3->ZT3_STATUS:='3'
                        MsUnLock() 
                        lEmail:=U_fEmailSenf(ZT3->ZT3_NUM,"*Env.Fiscal*")
                    ELSE 
                        lEmail:=U_fEmailSenf(ZT3->ZT3_NUM,"*Alteração/Carga*")
                    Endif
                          
				IF lEmail
					MSGINFO( 'E-mail enviado com Sucesso.', "SENF - Eletronica" )    
				ELSE
					ALERT('Erro ao enviar o E-mail')											
				ENDIF    
	Else
		ALERT('Verifique o Status da Senf, não é possível fazer alterações por essa rotina.')
	EndIf
RestArea(aArea)
return(.T.)
 
 