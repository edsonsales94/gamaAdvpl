#include "rwmake.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		MT103DRF                                                      /@
@type				Ponto de entrada                                              /@
@date				22/02/2016                                                    /@
@description	Permite alterar o combobox com a informa鈬o de gera鈬o da DIRF,
					e o c?digo de reten鈬o. Dispon?vel para IRPF, ISS, PIS, Cofins
					e CSLL.
					Retorna array com lista de codigos de reten鈬o.               /@
@author			Adalberto Moreno Batista (Op鈬o Um Consultoria)               /@
@use				Especifico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function MT103DRF()
Local aCodRet := {{"PIS", 1, "5952"},;
						{"COF", 1, "5952"},;
						{"CSL", 1, "5952"}}

if SA2->(FieldPos("A2_X_CDRET")) > 0
	if !empty(SA2->A2_X_CDRET)
		aAdd(aCodRet, {"IRR", 1, SA2->A2_X_CDRET})
	endif
endif

Return(aCodRet)
