#include "protheus.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		MT123APV                                                      /@
@date				02/02/2017                                                    /@
@type				Ponto de entrada
@description	Utilizado para trocar o grupo de aprovação nos pedidos de 
					compras.                                                      /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Opção Um Consultoria                                          /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MT123APV()
Local aArea			:= GetArea()
Local aAreaSY1		:= SY1->(GetArea())
Local aAreaCTT		:= CTT->(GetArea())
Local cGrupo		:= SC7->C7_APROV
Local cComprador	:= SC7->C7_USER
Local cCCusto, nPosCC

if CTT->(FieldPos("CTT_XAPVPC")) > 0

	if IsInCallStack("MATA123")
		nPosCC 	:= aScan(aHeader, {|x| AllTrim(x[2]) == "C7_CC"})
		cCCusto	:= aCols[n, nPosCC]
	else
		cCCusto	:= SC7->C7_CC
	endif

	SY1->(dbSetOrder(3))		//Y1_FILIAL, Y1_USER
	CTT->(dbSetOrder(1))		//CTT_FILIAL, CTT_CCUSTO

	//———————————————————————————————————————————————————————————————————————————————
	// 1o verifica se o comprador está vinculado à um grupo de aprovação.
	// 2o verifica se o centro de custo (depto) está vinculado à um grupo de aprovação
	//———————————————————————————————————————————————————————————————————————————————
	if SY1->(dbSeek(xFilial("SY1") + cComprador)) .and. !empty(SY1->Y1_GRAPROV)
	
		cGrupo	:= SY1->Y1_GRAPROV

	elseif CTT->(dbSeek(xFilial("CTT") + cCCusto)) .and. !empty(CTT->CTT_XAPVPC)

		cGrupo	:= CTT->CTT_XAPVPC

	endif
	
	RestArea(aAreaSY1)
	RestArea(aAreaCTT)
	RestArea(aArea)
	
endif

Return(cGrupo)
