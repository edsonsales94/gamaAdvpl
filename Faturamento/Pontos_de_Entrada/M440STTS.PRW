#Include "RwMake.ch"
#Include "Protheus.ch"

/*/
�������������������������������������������������������������������������������
@function		M440STTS                                                      /@
@type				Ponto de entrada                                              /@
@date				27/11/2017                                                    /@
@description	Acionado ao final de todas as transa��es da libera��o de um 
					pedido de vendas.                                             /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Op��o Um Consultoria                                          /@
@use				Espec�fico Brasitech                                          /@
�������������������������������������������������������������������������������
/*/
User Function M440STTS()
Local aArea		:= GetArea()

//����������������������������������������������������������������������������
// Na empresa 01, filial 08, quando pedido do eCommerce (C5_X_ORIG == "3"),
// Liberar automaticamente o cr�dito
// Por: Adalberto Moreno Batista (Op��o Um Consultoria) em 21/09/2017
//����������������������������������������������������������������������������
if SM0->M0_CODIGO == "01" .and. SM0->M0_CODFIL == "08" .and. SC5->C5_X_ORIG == "3"

	U_A_M410STTS()
	
endif

RestArea(aArea)
Return()