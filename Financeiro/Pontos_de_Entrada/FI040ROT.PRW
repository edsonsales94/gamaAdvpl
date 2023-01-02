#Include "protheus.ch"     
#include "rwmake.ch"

/*/
�������������������������������������������������������������������������������
@function		FI040ROT                                                      /@
@type				Ponto de entrada                                              /@
@date				06/10/2016                                                    /@
@description	Adiciona fun��o no menu (aRotina) de titulos a receber FINA040/@
@author			Adalberto Moreno Batista (Op��o Um Consultoria)               /@
@use				Especifico Brasitech                                          /@
�������������������������������������������������������������������������������
/*/
User Function FI040ROT()
Local aRotina := PARAMIXB

//�������������������������������������������������������������������������������
// Adiciona item no aRotina que montar� tela para consulta de hist�rico de 
// altera��es de datas de vencimento. A fun��o A_F040() est� localizada no
// ponto de entrada F040BUT.
// Por: Adalberto Moreno Batista (Op��o Um Consultoria) em 06/10/2016
//�������������������������������������������������������������������������������
if SE1->(FieldPos("E1_XVCTORI")) > 0 .and. SX2->(dbSeek("ZZ2"))
	aAdd(aRotina, {"� Hist.Dt.Vcto", "U_A_F040()", 0, 7})
endif

Return(aRotina)