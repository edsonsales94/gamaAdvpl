#include 'protheus.ch'
#include 'parmtype.ch'

//ponto de entrada para definir a geração da SC 
//Analista: Claudio Almeida data: 04/12/2017
//ParamIXB {Data de necessidade, Quantidade, Código do produto}
user function MT711VLSC()
Local cProd:=ParamIXB[3]
Local cTipo:=Posicione("SB1",1,XFILIAL("SB1")+cProd,"B1_ORIGAMA")
Local lRet:=.T. 
If cTipo=="05"
  lRet:=.T.
Endif
return(lRet)