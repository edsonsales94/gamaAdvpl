#include "Protheus.ch"
#include "Rwmake.ch"

/*_________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+------------------------+-------------------+¦¦
¦¦¦ Função    ¦ MT200MAP   ¦ Autor ¦ Ronaldo Gomes          ¦ Data ¦ 04/11/2013 ¦¦¦
¦¦+-----------+------------+-------+------------------------+-------------------+¦¦
¦¦¦ Descriçäo ¦ Grava a Quantidade Base conforme o padrão Gama Italy            ¦¦¦
¦¦+-----------+-----------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/   

USER FUNCTION MT200MAP()                 


Local lRet := .T.           
Local aArea := GetArea ()
Local nReg := SB1->(Recno()) // Guarda o Registro SA1 Atual
Local nQtBase := PARAMIXB[3] 
Local _Cod := PARAMIXB[1]
//Local _Prod := ""


//_Prod := POSICIONE("SB1",1,XFILIAL("SB1")+_Cod,"B1_COD")

IF nQtBase > 1 //.AND. _Cod == _Prod

	DbSelectArea("SB1")
	dbSetOrder(1)
	
	IF dbSeek(xFilial("SB1")+_Cod)

		While SB1->(!Eof()) .And. B1_FILIAL == xFilial("SB1") .And. B1_COD == _Cod

			IF RecLock("SB1",.F.)

			SB1->B1_QB := 1
	           
			MsUnlock()	

			ENDIF            

			SB1->(dbSkip(1))
	
		EndDo
	
	ENDIF


	SB1->(dbGoTo(nReg))
    RestArea(aArea)

ENDIF

 
Return (lRet)