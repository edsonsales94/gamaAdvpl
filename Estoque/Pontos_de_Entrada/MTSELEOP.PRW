User function MTSELEOP()
//RETIRAR TELA DE OPCIONAIS DO FATURAMENTO
Local cRet 	 := ParamIxb[1]
Local cProd := ParamIxb[2]
Local cProg := ParamIxb[3]
Local lRet := .T.

IF cProg == "MATA410" // VERIFICA SE ? A FUN??O DO PEDIDO DE VENDA
lRet:=.F.
ENDIF 

Return lRet