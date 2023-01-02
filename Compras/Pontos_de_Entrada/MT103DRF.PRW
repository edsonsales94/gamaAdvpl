#include "rwmake.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		MT103DRF                                                      /@
@type				Ponto de entrada                                              /@
@date				22/02/2016                                                    /@
@description	Permite alterar o combobox com a informação de geração da DIRF,
					e o código de retenção. Disponível para IRPF, ISS, PIS, Cofins
					e CSLL.
					Retorna array com lista de codigos de retenção.               /@
@author			Adalberto Moreno Batista (Opção Um Consultoria)               /@
@use				Especifico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
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
