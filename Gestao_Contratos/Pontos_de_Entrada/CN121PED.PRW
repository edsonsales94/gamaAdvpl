#Include "Protheus.ch"
#Include "FWMVCDEF.CH"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		CN121PED                                                     /@
@type			Ponto de entrada                                             /@
@date			23/10/2021                                                   /@
@description	Utilizado para tratamentos espec?ficos antes da gera鈬o do 
				pedido de compra, podendo manipular o cabe軋lho, itens e 
				rateio se necess疵io.                                        /@
@author			Adalberto Moreno Batista (Op鈬o Um)                          /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function CN121PED()
Local aCab			:= PARAMIXB[1]
Local aItens		:= PARAMIXB[2]
Local aArea			:= GetArea()
Local nX, nPosXFORPG

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Adiciono campos especificos do pedido de compras, buscando informa鋏es 
// definidas nos itens da planilha do contrato
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
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
