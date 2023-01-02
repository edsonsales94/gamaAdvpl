#Include "Protheus.ch"
#Include "FWMVCDEF.CH"

/*/
�������������������������������������������������������������������������������
@function		CN121PED                                                     /@
@type			Ponto de entrada                                             /@
@date			23/10/2021                                                   /@
@description	Utilizado para tratamentos espec�ficos antes da gera��o do 
				pedido de compra, podendo manipular o cabe�alho, itens e 
				rateio se necess�rio.                                        /@
@author			Adalberto Moreno Batista (Op��o Um)                          /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
/*/
User Function CN121PED()
Local aCab			:= PARAMIXB[1]
Local aItens		:= PARAMIXB[2]
Local aArea			:= GetArea()
Local nX, nPosXFORPG

//�������������������������������������������������������������������������������
// Adiciono campos especificos do pedido de compras, buscando informa��es 
// definidas nos itens da planilha do contrato
//�������������������������������������������������������������������������������
For nX := 1 to Len(aItens)

	nPosXFORPG	:= aScan(aItens[nX], {|x| Upper(AllTrim(x[1])) == "C7_X_FORPG"})
	if nPosXFORPG > 0
		aItens[nX,nPosXFORPG,2] := CND->CND_XFORPG
	else
		aAdd(aItens[nX], {"C7_X_FORPG", 	AllTrim(CND->CND_XFORPG), 	NIL})
	endif

Next

RestArea(aArea)

Return({aCab, aItens})