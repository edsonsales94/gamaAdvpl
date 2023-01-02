
User Function MT140LOK()
Local lRet := .T.

	If FwIsInCallStack('U_GATI001')
		U_GTPE012()
	EndIf

	If !l103Auto
		// [Conteúdo do Ponto de Entrada que já existe]
	EndIf

Return lRet