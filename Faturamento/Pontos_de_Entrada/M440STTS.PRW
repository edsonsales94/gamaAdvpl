#Include "RwMake.ch"
#Include "Protheus.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		M440STTS                                                      /@
@type				Ponto de entrada                                              /@
@date				27/11/2017                                                    /@
@description	Acionado ao final de todas as transa鋏es da libera鈬o de um 
					pedido de vendas.                                             /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Op鈬o Um Consultoria                                          /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function M440STTS()
Local aArea		:= GetArea()

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
// Na empresa 01, filial 08, quando pedido do eCommerce (C5_X_ORIG == "3"),
// Liberar automaticamente o cr馘ito
// Por: Adalberto Moreno Batista (Op鈬o Um Consultoria) em 21/09/2017
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
if SM0->M0_CODIGO == "01" .and. SM0->M0_CODFIL == "08" .and. SC5->C5_X_ORIG == "3"

	U_A_M410STTS()
	
endif

RestArea(aArea)
Return()
