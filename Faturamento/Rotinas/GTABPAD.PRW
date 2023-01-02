#include "protheus.ch"

User function gtabpad()

Local cEst := M->A1_EST 
Local cTabPad := ""

If cEst $ ('AC,AL,AM,AP,BA,CE,DF,ES,GO,MA,MT,MS,PA,PB,PE,PI,RN,RO,RR,SE,TO')
	cTabPad := "007"
ElseIf cEst $ ('MG,PR,RS,RJ,SC')
	cTabPad := "012"
Else
	cTabPad := "018"
EndIf

Return(cTabPad)