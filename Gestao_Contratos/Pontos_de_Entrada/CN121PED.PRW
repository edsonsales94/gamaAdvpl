#Include "Protheus.ch"
#Include "FWMVCDEF.CH"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		CN121PED                                                     /@
@type			Ponto de entrada                                             /@
@date			23/10/2021                                                   /@
@description	Utilizado para tratamentos específicos antes da geração do 
				pedido de compra, podendo manipular o cabeçalho, itens e 
				rateio se necessário.                                        /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function CN121PED()
Local aCab			:= PARAMIXB[1]
Local aItens		:= PARAMIXB[2]
Local aArea			:= GetArea()
Local nX, nPosXFORPG

//———————————————————————————————————————————————————————————————————————————————
// Adiciono campos especificos do pedido de compras, buscando informações 
// definidas nos itens da planilha do contrato
//———————————————————————————————————————————————————————————————————————————————
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
