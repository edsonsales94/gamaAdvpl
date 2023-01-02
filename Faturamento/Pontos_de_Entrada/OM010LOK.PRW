/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Ponto Entr³ OM010LOK ³ Por: Adalberto Moreno Batista ³ Data ³13.05.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida linha da tabela de precos                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Brasitech (Gama Italy)                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
#Include "protheus.ch"
#Include "rwmake.ch"

User Function OM010LOK()
Local lRet 			:= .T.
Local lVldTabPrc	:= GetMV("BR_VTABPRC", .F., .F.)
Local cEol			:= chr(13) + chr(10) + chr(13) + chr(10)
Local nPosCODPRO	:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "DA1_CODPRO"})
Local aArea			:= GetArea()
Local aAreaDA1		:= DA1->(GetArea())
Local nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o produto informado na tabela, foi cadastrado anteriormente ³
//³ na tabela 500 e em alguma tabela acima de 900                           ³
//³ Tratamento sera realizado somente se o parametro BR_VTABPRC for .T.     ³
//³ por: Adalberto Moreno Batista em 13/05/13                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !aCols[n, Len(aHeader) + 1]

	if lVldTabPrc .and. (M->DA0_CODTAB <= "900" .and. M->DA0_CODTAB != "500")

		DA1->(dbSetOrder(2))	//DA1_FILIAL+DA1_CODPRO+DA1_CODTAB+DA1_ITEM
		lRet := DA1->(dbSeek(xFilial("DA1") + aCols[n, nPosCODPRO] + "500"))

		if lRet
			DA1->(dbSeek(xFilial("DA1") + aCols[n, nPosCODPRO] + "900", .T.))
			if DA1->DA1_FILIAL == xFilial("DA1") .and. DA1->DA1_CODPRO == aCols[n, nPosCODPRO] .and. DA1->DA1_CODTAB >= "900"
			else
				lRet := .F.
			endif
		endif
		
		if !lRet
			Help(" ", 1, "Atenção",, "Para incluir o produto " + AllTrim(aCols[n, nPosCODPRO]) + "na tabela de preço, é necessário que antes ele tenha sido cadastrado na tabela 500 e em alguma tabela acima de 900." + cEol + "(Específico Gama Italy), ponto de entrada OM010LOK", 1)
		endif

		RestArea(aAreaDA1)
		RestArea(aArea)
		
	endif
	
endif

Return(lRet)