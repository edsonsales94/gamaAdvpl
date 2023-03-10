#Include "protheus.ch"     
#include "rwmake.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		FI040ROT                                                      /@
@type				Ponto de entrada                                              /@
@date				06/10/2016                                                    /@
@description	Adiciona fun鈬o no menu (aRotina) de titulos a receber FINA040/@
@author			Adalberto Moreno Batista (Op鈬o Um Consultoria)               /@
@use				Especifico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function FI040ROT()
Local aRotina := PARAMIXB

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Adiciona item no aRotina que montar? tela para consulta de hist?rico de 
// altera鋏es de datas de vencimento. A fun鈬o A_F040() est? localizada no
// ponto de entrada F040BUT.
// Por: Adalberto Moreno Batista (Op鈬o Um Consultoria) em 06/10/2016
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if SE1->(FieldPos("E1_XVCTORI")) > 0 .and. SX2->(dbSeek("ZZ2"))
	aAdd(aRotina, {"ｮ Hist.Dt.Vcto", "U_A_F040()", 0, 7})
endif

Return(aRotina)
