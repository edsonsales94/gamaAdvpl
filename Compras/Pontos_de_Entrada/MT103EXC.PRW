#INCLUDE "PROTHEUS.CH"    

/*/

———————————————————————————————————————————————————————————————————————————————
@function		MT103EXC                                                      /@
@type				Ponto de Entrada                                              /@
@date				11/05/2015                                                    /@
@description	                                                              /@
@author			Vescio Pereira de Moura                                       /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————

/*/
//ponto de dentrada para atualizar o campo D2_BRQTDEV na exclusão da nota fiscal
User function MT103EXC()

if FieldPos("F1_BRAR") > 0
	IF !EMPTY(SF1->F1_BRAR)
		DbSelectar("SD1")
		DbSetorder(1)
		DbSeek(xfilial()+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))
	  		While SF1->(xfilial()+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)) == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) .AND. !EOF()
			DbSelectar("SD2")
			DbSetorder(3)
			IF DbSeek(xfilial()+SD1->(D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEMORI))
				Reclock("SD2",.F.)
				SD2->D2_BRQTDEV+=SD1->D1_QUANT
				MSUNLOCK()
			Endif
			DbSelectar("SD1")
			DbSkip()
		Enddo					
		DbSelectar("SZG")
		IF DbSeek(xfilial()+SF1->F1_BRAR)
			Reclock("SZG",.F.)
	//		SZG->ZG_NFDEVOL:=SPACE(9)
	//		SZG->ZG_SERIENF:=SPACE(3)
	//		SZG->ZG_ESPECIE:=SPACE(4)
			SZG->ZG_DTINTER:=CTOD("")
			MSUNLOCK()		
		Endif
	Endif	
endif

Return .T.
