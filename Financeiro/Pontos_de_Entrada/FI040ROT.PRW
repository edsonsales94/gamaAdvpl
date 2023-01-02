#Include "protheus.ch"     
#include "rwmake.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		FI040ROT                                                      /@
@type				Ponto de entrada                                              /@
@date				06/10/2016                                                    /@
@description	Adiciona função no menu (aRotina) de titulos a receber FINA040/@
@author			Adalberto Moreno Batista (Opção Um Consultoria)               /@
@use				Especifico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function FI040ROT()
Local aRotina := PARAMIXB

//———————————————————————————————————————————————————————————————————————————————
// Adiciona item no aRotina que montará tela para consulta de histórico de 
// alterações de datas de vencimento. A função A_F040() está localizada no
// ponto de entrada F040BUT.
// Por: Adalberto Moreno Batista (Opção Um Consultoria) em 06/10/2016
//———————————————————————————————————————————————————————————————————————————————
if SE1->(FieldPos("E1_XVCTORI")) > 0 .and. SX2->(dbSeek("ZZ2"))
	aAdd(aRotina, {"® Hist.Dt.Vcto", "U_A_F040()", 0, 7})
endif

Return(aRotina)
