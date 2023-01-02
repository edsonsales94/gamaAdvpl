#include "protheus.ch"
#include "rwmake.ch"

/*/

———————————————————————————————————————————————————————————————————————————————
@function		ATUCLI                                                       /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————

/*/
User Function ATUCLI()
Local cArquivo 	:= "\_adalberto\SA1BKP.DBF"
Local cIndice	:= CriaTrab(nil,.F.)
Local nCount1	:= 0
Local nCount2	:= 0
Local nIndice

SA1->(dbSetOrder(1))

dbUseArea(.T.,,cArquivo, "BKPCLI", .T., .F.)
IndRegua("BKPCLI",cIndice,"A1_FILIAL + A1_COD + A1_LOJA",,,"Selecionando Registros...")
dbSelectArea("BKPCLI")
dbSetIndex(cIndice+OrdBagExt())

BKPCLI->(dbSeek("03"))
do while BKPCLI->(!eof() .and. A1_FILIAL=="03")

	if SA1->(dbSeek(xFilial("SA1") + BKPCLI->(A1_COD+A1_LOJA)))
		
//		if BKPCLI->A1_OBSCRED != SA1->A1_OBSCRED
			SA1->(RecLock("SA1",.F.))
			SA1->A1_OBSCRED	:= BKPCLI->A1_OBSCRED
			SA1->(MsUnlock())
//		endif
	
	endif

	BKPCLI->(dbSkip())
enddo
alert("concluido")
Return()

             
