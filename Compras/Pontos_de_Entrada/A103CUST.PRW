#INCLUDE "Protheus.ch"
User Function A103CUST()
Local _cArea := GetArea()
Local _aCusto:={}

If SD1->D1_CUSGAMA > 0
	Aadd(_aCusto,{SD1->D1_CUSGAMA,0,0,0,0})
Endif

RestArea(_cArea)
Return(_aCusto)
