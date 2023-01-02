#include "rwmake.ch"
#include "protheus.ch"

/*/
{Protheus.doc} MT100TOK
@description	Ponto de entrada para validar a inclusão de uma nota fiscal 
				de entrada. 
				Uso Brasitech
@type 			User Function
@author 
@since 			30/04/2009
@return			Lógico, verdadeiro .T. ou falso .F.
/*/
User Function MT100TOK()
Local _lRet			:= .T.
Local lUtiInd		:= GetMv("MV_UTIIND", .F., .F.)
Local cNomeFunc		:= AllTrim(Upper(FunName()))
Local lGAMANFE		:= (!cNomeFunc $ "MATA920 # U_BRAJOB19 # U_JOB15DESP # U_BRAMNT01")

If Type("cFormul") == "C" .and. lGAMANFE

	if Type("l103Auto") != "L"
		l103Auto := .F.
	endif
	
	if _lRet .and.;
		SD1->(FieldPos("D1_XNFORI")) > 0 .and.;
		SD1->(FieldPos("D1_XSERIOR")) > 0 .and.;
		(cEmpAnt == "01" .or. cEmpAnt == "04") .and.;
		lUtiInd .and.;
		cNomeFunc != "MATA920"  //Se nao for livros fiscais
	
		_lRet := A_MT100TOK()
	
	endif
	
	
	//———————————————————————————————————————————————————————————————————————————————
	// Verifica se a chave da nota fiscal foi preenchida, quando for nota com especie
	// CTE ou SPED e nota de terceiros, pois a informacao passara a obrigatoria no 
	// SPED Fiscal
	// Por: SI8401 - Adalberto Moreno Batista em 15/03/12                      
	//———————————————————————————————————————————————————————————————————————————————
	if _lRet .and. cFormul == "N" .and. AllTrim(cEspecie) $ "CTE.SPED"
		_lRet := B_MT100TOK()
	endif
	
	//———————————————————————————————————————————————————————————————————————————————
	// A partir da forma de pagamento do pedido de compras, verifico se as informações
	// obrigatórias para os tipos 1-Boleto ou Depósito em conta estão registradas.
	// Por: Adalberto Moreno Batista (Opção Um Consultoria) em 05/11/14
	//———————————————————————————————————————————————————————————————————————————————
	if _lRet .and. SC7->(FieldPos("C7_X_FORPG")) > 0 .and. cTipo == "N" .and. !cNomeFunc $ "U_GATI001 # U_BRAMNT07 # U_BRAMNTFM" .and. ValType(aGIPosSE2) == "A"
		_lRet := C_MT100TOK()
	endif
	
	// Function utilizada pelo importador "Conexao NFe"
	if _lRet .and. !l103Auto
		_lRet := E_MT100TOK()
	endif
	
	// Valida condição de pagamento do Fornecedor
	if _lRet .AND. SF1->F1_FILIAL == '01' .and. cTipo <> "D"
		_lRet := F_MT100TOK()
	endif

EndIf

Return(_lRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		A_MT100TOK                                                    /@
@type			Static function                                              /@
@date			30/04/2009                                                   /@
@description	Função chamada pela user function MT100TOK. 
				Retorna .T. ou .F.                                           /@
@author			                                                             /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function A_MT100TOK()
Local _lRet := .T.
Local iX, nQtd, nPosCF, nPosxNF, nPosxSR, CF_Serv

//se for a validação do sistema for verdadeira , entra na validação do ponto de entrada.
//Variáveis de posicionamento de campos no acols
nQtd	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_QUANT"})
nPosCF	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_CF"})
nPosxNF	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_XNFORI"})
nPosxSR	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_XSERIOR"})
CF_Serv	:= AllTrim(GetMv("MV_CFOPIND", .F., ""))
		
For iX:=1 to Len(aCols)
			
	if AllTrim(aCols[iX, nPosCF]) $ CF_Serv
	
		if Empty(aCols[iX, nPosxNF]) .or. Empty(aCols[iX, nPosxSR])

			if !IsBlind()
				MsgStop("É necessário digitar NF e Serie de retorno componente para NF Servico!", "MT100TOK")
			else
				ConOut("MT100TOK - É necessário digitar NF e Serie de retorno componente para NF Servico!")
			endif
			_lRet := .F.
			exit
			
		elseif u_VlrServ(aCols[iX, nPosxNF], aCols[iX, nPosxSR], aCols[iX, nQtd], cA100For, cLoja, .F.) == 0
		
			if !IsBlind()
				MsgStop("É necessário classificar primeiramente a(s) NF(s) de retorno!", "MT100TOK")
			else
				ConOut("MT100TOK - É necessário classificar primeiramente a(s) NF(s) de retorno!")
			endif
			_lRet := .F.
			exit
			
		endif
		
	endif
	
Next

Return(_lRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		B_MT100OK                                                    /@
@type			Static function                                              /@
@date			15/03/2012                                                   /@
@description	Função chamada pela user function MT100TOK. 
				Verifica se a chave da nota fiscal foi preenchida, quando for
				nota com especie CTE ou SPED e nota de terceiros, pois a 
				informacao passara a obrigatoria no SPED Fiscal.
				Retorna .T. ou .F.                                           /@
@author			Adalberto Moreno Batista                                     /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function B_MT100TOK()
Local lRet		:= .T.
Local cMsg		:= ""
Local cTxt		:= ""
Local cCNPJ		:= iif( cTipo $ "BD", SA1->A1_CGC, SA2->A2_CGC )
Local aCodEst	:= {	{'AC','12'}, {'AL','27'}, {'AM','13'}, {'AP','16'}, {'BA','29'},;
						{'CE','23'}, {'DF','53'}, {'ES','32'}, {'GO','52'}, {'MA','21'},;
						{'MG','31'}, {'MS','50'}, {'MT','51'}, {'PA','15'}, {'PB','25'},;
						{'PE','26'}, {'PI','22'}, {'PR','41'}, {'RJ','33'}, {'RN','24'},;
						{'RO','11'}, {'RR','14'}, {'RS','43'}, {'SC','42'}, {'SE','28'},;
						{'SP','35'}, {'TO','17'} }
Local nPos		:= aScan( aCodEst, { |x|, x[1] = cUFOrig } )
Local nK

if Empty(aNFeDANFE[13])

	//Verifico se a chave foi preenchida
	cMsg	:= "Chave NFe em branco"
	lRet	:= .F.

elseif Len(AllTrim(aNFeDANFE[13])) == 44

	//Verifico se ha digitos nao numericos
	For nK := 1 to Len( AllTrim( aNFeDANFE[13] ) )
		if !IsDigit( Substr( aNFeDANFE[13], nK, 1 ) )
			cMsg	:= "Chave NFe deve conter somente números"
			lRet	:= .F.
			exit
		endif
	next

	if lRet

		//Verifico a composicao da chave
		if Substr( aNFeDANFE[13], 3, 4 ) != Substr( dTOs( ddEmissao ), 3, 4 )
			cTxt	:= "Foi encontrada divergência entre o mês e ano de emissão da nota fiscal informada e o encontrada na Chave NFe. "
			lRet	:= .F.
			
		elseif Substr( aNFeDANFE[13], 7, 14 ) != cCNPJ
			cTxt	:= "Foi encontrada divergência entre o CNPJ do " + iif( cTipo $ "BD", "cliente", "fornecedor" ) + " utilizado e o encontrado na Chave NFe. "
			lRet	:= .F.

		elseif Substr( aNFeDANFE[13], 21, 2 ) != AModNot(cEspecie)
			cTxt	:= "Foi encontrada divergência entre a espécie/modelo da nota fiscal informada e a encontrada na Chave NFe. "
			lRet	:= .F.
	
		elseif Substr( aNFeDANFE[13], 23, 3 ) != StrZero( Val( cSerie ), 3 )
			cTxt	:= "Foi encontrada divergência entre a série da nota fiscal informada e a encontrada na Chave NFe. "
			lRet	:= .F.
		
		elseif Substr( aNFeDANFE[13], 26, 9 ) != StrZero( Val( cNFiscal ), 9 )
			cTxt	:= "Foi encontrada divergência entre o número da nota fiscal informada e a encontrada na Chave NFe. "
			lRet	:= .F.

		elseif nPos > 0
			if Substr( aNFeDANFE[13], 1, 2 ) != aCodEst[nPos,2]
				cTxt	:= "Foi encontrada divergência entre o estado da nota fiscal informada e o encontrada na Chave NFe. "
				lRet	:= .F.
			endif
		endif
		
		if !lRet
			cMsg	:= "Divergência nas informações da Chave NFe com o informado na nota fiscal."
		endif
	
	endif

else

	//Verifico se a chave 44 posicoes
	cMsg	:= "Chave NFe menor do que 44 posições"
	lRet	:= .F.

endif

if !lRet
	if !IsBlind()	//!l103Auto
		MsgBox(cTxt + "Esta é uma nota fiscal de terceiros com espécie '" + AllTrim(cEspecie) + "' e portanto é obrigatório o preenchimento da chave da nota fiscal, com 44 dígitos numéricos, na pasta 'DANFE'. Preencha esta informação para poder gravar a nota fiscal", "Atenção, " + cMsg, "ERRO")
	else
		Conout("MT100TOK - Atenção, " + cMsg + "-> " + cTxt + "Esta é uma nota fiscal de terceiros com espécie '" + AllTrim(cEspecie) + "' e portanto é obrigatório o preenchimento da chave da nota fiscal, com 44 dígitos numéricos, na pasta 'DANFE'. Preencha esta informação para poder gravar a nota fiscal")
	endif
endif

Return(lRet)   


/*/
———————————————————————————————————————————————————————————————————————————————
@function		C_MT100OK                                                    /@
@type			Static function                                              /@
@date			05/11/2014                                                   /@
@description	Função chamada pela user function MT100TOK. 
				A partir da forma de pagamento do pedido de compras, verifico
				se as informações obrigatórias para os tipos 1-Boleto ou 
				Depósito em conta estão registradas.                         /@
@author			Adalberto Moreno Batista                                     /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function C_MT100TOK()
Local lRet			:= .T.
Local cMsg			:= ""
Local cSoluc		:= ""
Local nPosApoio		:= 0
Local nPosXFORPAG	:= 0
Local nPosCODBAR	:= 0
Local nPosFORBCO	:= 0
Local nPosFORAGE	:= 0
Local nPosFORCTA	:= 0
Local nPosFCTADV	:= 0
Local cCBApoio		:= ""
Local aArea			:= GetArea()
Local aAreaSF4		:= SF4->(GetArea())
Local nPosTes		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_TES"})
Local lGeraTitulo	:= .F.
Local nK

//———————————————————————————————————————————————————————————————————————————————
// Valido dados bancarios somente se a nota gerar titulo a pagar
//———————————————————————————————————————————————————————————————————————————————
SF4->(dbSetOrder(1))
For nK := 1 to Len(aCols)
	if SF4->(dbSeek(xFilial("SF4") + aCols[nK, nPosTes])) .and. SF4->F4_DUPLIC == "S"
		lGeraTitulo := .T.
		Exit
	endif
Next
RestArea(aAreaSF4)
RestArea(aArea)

//———————————————————————————————————————————————————————————————————————————————
// Verifico se a nota gera titulo
//———————————————————————————————————————————————————————————————————————————————
if lGeraTitulo

	//———————————————————————————————————————————————————————————————————————————————
	// Identificando posicao de campos no aCols dos titulos
	//———————————————————————————————————————————————————————————————————————————————
	nPosApoio	:= aScan(aGIPosSE2, {|x| x[1]=="E2_XFORPAG"})
	if nPosApoio > 0
		nPosXFORPAG	:= aGIPosSE2[nPosApoio,2]
	endif

	nPosApoio	:= aScan(aGIPosSE2, {|x| x[1]=="E2_CODBAR"})
	if nPosApoio > 0
		nPosCODBAR	:= aGIPosSE2[nPosApoio,2]
	endif

	nPosApoio	:= aScan(aGIPosSE2, {|x| x[1]=="E2_FORBCO"})
	if nPosApoio > 0
		nPosFORBCO	:= aGIPosSE2[nPosApoio,2]
	endif

	nPosApoio	:= aScan(aGIPosSE2, {|x| x[1]=="E2_FORAGE"})
	if nPosApoio > 0
		nPosFORAGE	:= aGIPosSE2[nPosApoio,2]
	endif

	nPosApoio	:= aScan(aGIPosSE2, {|x| x[1]=="E2_FORCTA"})
	if nPosApoio > 0
		nPosFORCTA	:= aGIPosSE2[nPosApoio,2]
	endif

	nPosApoio	:= aScan(aGIPosSE2, {|x| x[1]=="E2_FCTADV"})
	if nPosApoio > 0
		nPosFCTADV	:= aGIPosSE2[nPosApoio,2]
	endif

	//———————————————————————————————————————————————————————————————————————————————
	// Analisa as linhas dos títulos
	//———————————————————————————————————————————————————————————————————————————————
	for nK:=1 to Len(aGI103Dupl)

		if Empty(aGI103Dupl[nK, nPosXFORPAG])
			lRet 	:= .F.
			cMsg	:= "A forma de pagamento não foi preenchida em um ou mais títulos."
			cSoluc	:= "Verifique e corrija."
			exit

		//Codigo de barras
		elseif aGI103Dupl[nK, nPosXFORPAG] == "BOL"

			if !Empty(aGI103Dupl[nK, nPosCODBAR]) .and. AllTrim(cCBApoio) == AllTrim(aGI103Dupl[nK, nPosCODBAR])

				lRet 	:= .F.
				cMsg	:= "Foi encontrado código de barras duplicado nos títulos informados."
				cSoluc	:= "Verifique e corrija."
				exit

			elseif Empty(aGI103Dupl[nK, nPosCODBAR])

				lRet 	:= .F.
				cMsg	:= "A forma de pagamento informa que trata-se de pagamento por código de barras e ele não foi preenchido."
				cSoluc	:= "Preencha os códigos de barras para todos os titulos gerados nesta nota fiscal."
				exit

			elseif !U_ChkCodBar(aGI103Dupl[nK, nPosCODBAR])

				lRet 	:= .F.
				exit

			elseif !U_SE2DtVcVlr()

				lRet 	:= .F.
				exit

			endif

		//Transferencia
		elseif aGI103Dupl[nK, nPosXFORPAG] == "DEP" .and. (Empty(aGI103Dupl[nK, nPosFORBCO]) .or. Empty(aGI103Dupl[nK, nPosFORAGE]) .or. Empty(aGI103Dupl[nK, nPosFORCTA]) .or. Empty(aGI103Dupl[nK, nPosFCTADV]))
		
			lRet 	:= .F.
			cMsg	:= "A forma de pagamento informa que trata-se de pagamento por transferencia bancária, mas os dados bancários não foram preenchidos."
			cSoluc	:= "Revise os dados bancários no cadastro de fornecedor ou no pedido de compras."
			exit

		//Debito em Conta
		elseif aGI103Dupl[nK, nPosXFORPAG] == "DBC" .and. (!Empty(aGI103Dupl[nK, nPosCODBAR]) .or. !Empty(aGI103Dupl[nK, nPosFORBCO]) .or. !Empty(aGI103Dupl[nK, nPosFORAGE]) .or. !Empty(aGI103Dupl[nK, nPosFORCTA]) .or. !Empty(aGI103Dupl[nK, nPosFCTADV]))
		
			lRet 	:= .F.
			cMsg	:= "A forma de pagamento informa que trata-se de débito em conta, portanto codigo de barras e dados bancários não devem ser preenchidos."
			cSoluc	:= "Limpe os dados bancarios e/ou codigo de barras"
			exit

		endif

		cCBApoio	:= aGI103Dupl[nK, nPosCODBAR]

	next

	if !lRet .and. !Empty(cMsg)
		if !IsBlind()
			Help("", 1, "ATENÇÃO",, cMsg + chr(13) + chr(10) + "(MT100TOK - Específico " + AllTrim(SM0->M0_NOME) + ")", 1,,,,,,, {cSoluc})
		else
			ConOut(cMsg + " - " + cSoluc + "(MT100TOK - Específico " + AllTrim(SM0->M0_NOME) + ")")
		endif
	endif

endif

Return(lRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		E_MT100OK                                                    /@
@type			Static function                                              /@
@date			                                                             /@
@description	Função chamada pela user function MT100TOK. 
				FORÇA A CONDIÇÃO DE PAGAMENTO INFORMADA NO IMPORTADOR, 
				PARA NÃO SER SUBSTITUÍDA PELA INFORMADA NO PEDIDO DE COMPRA  /@
@author			                                                             /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function E_MT100TOK()
Local lRet := .T.     

lRet:= U_GTPE005()

Return lRet


/*/
———————————————————————————————————————————————————————————————————————————————
@function		F_MT100OK                                                    /@
@type			Static function                                              /@
@date			                                                             /@
@description	                                                             /@
@author			                                                             /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function F_MT100TOK()
Local aArea		:= GetArea()
Local aAreaSF4	:= SF4->(GetArea())
Local nPosTes	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_TES"})
Local lRet := .T.
Local iX
	For iX:=1 to Len(aCols)
		SF4->(dbSetOrder(1))
		SF4->( dbSeek( xFilial("SF4") + aCols[iX,nPosTes] ) )
		if SF4->F4_DUPLIC == 'S' 
			IF CCondicao == '999'
				lRet := .F.
				if !IsBlind()
					MsgBox("A condição de pagamento 999 não poderá ser utilizada com operações que gerem duplicatas. Troque a condicao de pagamento ou o TES utilizado","Atenção","ERRO")
				else
					ConOut("MT100TOK - A condição de pagamento 999 não poderá ser utilizada com operações que gerem duplicatas. Troque a condicao de pagamento ou o TES utilizado")
				endif
				Exit
			ELSE
				/*
				IF len(alltrim(SA2->A2_COND))==0
					lRet := .F.
					if !IsBlind()
						MsgBox("A condição de pagamento nao foi cadastrada no fornecedor. Corrija o cadastro!","Atenção","ERRO")
					else
						ConOut("MT100TOK - A condição de pagamento nao foi cadastrada no fornecedor. Corrija o cadastro!")
					endif
					Exit
				ENDIF 
				IF SA2->A2_COND <> CCondicao
					lRet := .F.
					if !IsBlind()
						MsgBox("A condição de pagamento difere do fornecedor. Troque a condicao de pagamento ou o TES utilizado","Atenção","ERRO")
					else
						ConOut("MT100TOK - A condição de pagamento difere do fornecedor. Troque a condicao de pagamento ou o TES utilizado")
					endif
					Exit
				ENDIF 
				*/
			ENDIF	
		endif
	Next
RestArea(aAreaSF4)
RestArea(aArea)

Return(lRet)
