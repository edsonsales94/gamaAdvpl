#Include "Protheus.Ch" 
#include "ap5mail.ch"
#include "rwmake.ch"
#include "topconn.ch"


// ------------------------------------------------------------------------------------------
// Ricky Moraes - 29/06/21 - 12:10
// Enviar atualiza??o Protheus AR x GKO CTE
// ----------------------------------------------------------------------------------------


// fun??o para colocar 9 digitos
User Function STRNFDEVOL()
If !Empty(M->ZG_NFDEVOL) 
  M->ZG_NFDEVOL := StrZero(Val(M->ZG_NFDEVOL),9)
Endif  
Return(.T.)


//fun??o para verificar dados GKO x AR
User Function FDADOSGKO()
    Processa( { || sFDADOSGKO() }, 'Analisando registros..', 'Aguarde...')
Return



//fun??o para verificar dados GKO x AR
******************************************************************************************************************************************************************
Static Function sFDADOSGKO()
******************************************************************************************************************************************************************     
Local cQryAux  := ""
Local nTotal:=0
Local lGravou:=.F.
Local nAtual := 0
Local nOK:=0

	//Montando consulta de dados
	cQryAux := ""
	cQryAux += "SELECT * FROM VW_ARCTE2"

  cQryAux := ChangeQuery(cQryAux)		

  //Executando consulta e setando o total 
	TCQuery cQryAux New Alias "QRY_AUX"
  
  TCSetField("QRY_AUX", "DTCTE", "D")

	Count to nTotal

  //seta o total de registros
  ProcRegua(nTotal)



  if nTotal > 0
   QRY_AUX->(DbGoTop())
     While  ! QRY_AUX->(Eof())
      lGravou:= fDadosCTE(QRY_AUX->FILIAL,;
                          QRY_AUX->NUMAR,;
                          QRY_AUX->DTCTE,;
                          QRY_AUX->NUMCTE,;
                          QRY_AUX->SERIECTE,;
                          QRY_AUX->CHAVECTE)               
      if !lGravou
        U_GeraLog("NUMAR "+ QRY_AUX->NUMAR + " DATA "+Transform(dDatabase,"99/99/9999") +" HORA:"+Time()  ,"fDadosGKO" )
        ALERT("Erro GKO " + QRY_AUX->NUMAR )
      else
         nOK++
      endif
      QRY_AUX->(DbSkip()) 
      //Incrementa a mensagem na r?gua
      nAtual++
      incproc("Atualizando Registro... " + str(nAtual))      
    Enddo
  Else
    ALERT("N?o existem registros a serem atualizados !")
  endif
If nOK>0
 U_MsgTimer ("Foram atualizados " + alltrim(str(nOK)) + " registros !", "AR X GKO" )
endif

QRY_AUX->(dbclosearea())
Return()


//fun??o gravadados na AR
******************************************************************************************************************************************************************
Static Function fDadosCTE(cFil,cNumAr,cDtcoleta,cNCTE,cNSerieCte,cChaveCte)
******************************************************************************************************************************************************************     
Local lRet :=.F.
Local aArea := GetArea()

DbSelectArea('SZG')
SZG->(DbSetOrder(1)) // Filial + Numero
 
//Se conseguir posicionar no produto
If SZG->(msSeek(cFil + cNumAr))
  If RecLock("SZG", .F.)
       //Grava CTE NFS DEV
          SZG->ZG_DTCOLE :=cDtcoleta
          SZG->ZG_NROCTE := cNCTE
          SZG->ZG_SERIECT:= cNSerieCte
          SZG->ZG_CHVECTE:= cChaveCte
          //SZG->ZG_CHVNFE := cChaveDev
         // SZG->ZG_STATUS:='AR - Dev.Finaliz.Auto.'
          SZG->ZG_STATUS:='AR - Coletada'
          SZG->(MsUnlock())
          lRet:=.T.             
  Else
      MsgStop("N?o foi poss?vel travar o registro para manipula??o!", "Aten??o")
  EndIf   
EndIf      

	SZG->(dbclosearea())		 	

	RestArea(aArea)          

return(lRet)
