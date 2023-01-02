# include "protheus.ch"


User Function CCustoVend()
/*Local aArea := getArea()
Local cCusto := ""

DbSelectArea("SA3")
DbSetOrder(1) //FILIAL + CODIGO
IF DbSeek (xFilial("SA3")+SF2->F2_VEND1)
	cCusto :=SA3->A3_XCCVEND
endIf*/

Local aArea 	:= getArea()
Local aAreaSA3 := SA3->(GetArea())
Local aAreaSF2 := SF2->(GetArea())
Local cCusto 	:= ""

SF2->(dbSetOrder(1))		//F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, F2_TIPO
SA3->(DbSetOrder(1)) 	//FILIAL + CODIGO

if SF2->(dbSeek(xFilial("SF2") + SD2->(D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA)))
	if SA3->(dbSeek(xFilial("SA3") + SF2->F2_VEND1))
		cCusto := SA3->A3_XCCVEND
	endif
endIf

RestArea(aAreaSA3)
RestArea(aAreaSF2)
RestArea(aArea)

Return(cCusto)
