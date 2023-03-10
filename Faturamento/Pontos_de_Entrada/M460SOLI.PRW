#include "rwmake.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		M460SOLI                                                      /@
@type				Ponto de entrada                                              /@
@date				30/05/2012                                                    /@
@description	Ponto de entrada da prepara鈬 da nota fiscal para c疝culo da
					substitui鈬o tribut疵ia.
					Retorna 	aSolid[1] = Base do ICMS substituto por item
								aSolid[2] = Valor do ICMS substituto por item
								aSolid[3] = Margem de Valor Agregado
								aSolid[4] = Al?quota Solid疵io
								aSolid[5] = Base do FECP-ST
								aSolid[6] = Aliquota do FECP-ST
								aSolid[7] = Valor do FECP-ST                         /@
@author			Adalberto Moreno Batista (Op鈬o Um Consultoria)               /@
@use				Especifico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function M460SOLI()
//Local nItem			:= PARAMIXB[1]
Local aArea			:= GetArea()
Local aAreaSA1		:= SA1->(GetArea())
Local aAreaSB1		:= SB1->(GetArea())
Local aAreaSF4		:= SF4->(GetArea())
Local aAreaSF7		:= SF7->(GetArea())
Local lRefaz		:= .F.
Local lNacional	:= .F.
Local nAliqPP		:= 0
Local nAliqST		:= 0
Local nAliqIPI		:= 0
Local nBaseICMS	:= 0
Local nValFrete	:= 0
Local nBaseST		:= BASEICMRET
Local nVlICMS		:= ICMSITEM
Local nMVA			:= MARGEMLUCR
Local nVlST			:= 0
Local aRet			:= 0

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Ordeno os indices das tabelas utilizadas no processo
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
SA1->(dbSetOrder(1))
SB1->(dbSetOrder(1))
SF4->(dbSetOrder(1))
SF7->(dbSetOrder(1))

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Somente para opera鋏es ? partir de SP ou AM e notas que utilizem cliente
// 1- Para vendas de S縊 Paulo para clientes do Amap?, considerar o ICMS Pr?prio
//    no c疝culo da ST.
// 2- Recalcularemos o ICMS ST para vendas a partir de Manaus/AM para qualquer
//    estado e somente em casos onde houver MVA.
// 3- N縊 acionar a rotina quando cliente for do MT. Utilizar o padr縊.
// Regras verificadas com a Valqu?ria em 16/07/14
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
//Posicionando tabelas
SA1->(msSeek(xFilial("SA1") + SC5->(C5_CLIENTE+C5_LOJACLI)))
SB1->(msSeek(xFilial("SB1") + SC6->C6_PRODUTO))

if !SC5->C5_TIPO $ "BD"// .and. SA1->A1_EST != "MT"

	if SM0->M0_ESTCOB == "SP"

		if SB1->B1_ORIGEM $ "0.4"		//produto nacional
			lNacional := .T.
		endif
		
		//identificando caracteristicas do cliente
		if SA1->A1_EST $ "AP"
			lRefaz := .T.
		endif
		
	elseif SM0->M0_ESTCOB == "AM"
		
		if SC6->(FieldPos("C6_XOPER")) > 0
			if AllTrim(SC6->C6_XOPER) $ "01.03.04"	//identificando caracteristicas do cliente e se a opera鈬o ? uma venda ou bonifica鈬o
				lRefaz := .T.
			else								//caso contrario, retorna zero na base e no valor da ST
				aRet := {0, 0}
			endif
		endif
		
	endif
	
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Se identificada a necessidade de rec疝culo do ICMS ST, pesquiso as exce鋏es
	// fiscais para buscar admas aliquotas de ICMS e MVA
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	if lRefaz
		
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		// 1- Pesquiso se h? exce鈬o para o estado destino da mercadoria e tipo de cliente
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		if SF7->(dbSeek(xFilial("SF7") + SB1->B1_GRTRIB + SA1->A1_GRPTRIB))
			do while SF7->(!eof() .and. F7_FILIAL + F7_GRTRIB + F7_GRPCLI == xFilial("SF7") + SB1->B1_GRTRIB + SA1->A1_GRPTRIB)
				if SF7->F7_EST == SA1->A1_EST .and. SF7->F7_TIPOCLI == SC5->C5_TIPOCLI
					nAliqPP	:= (SF7->F7_ALIQEXT / 100)
					nAliqST	:= (SF7->F7_ALIQINT / 100)
					nMVA	:= iif(SF7->F7_MARGEM > 0, (1 + (SF7->F7_MARGEM / 100)), 0)
					Exit
				endif
				SF7->(dbSkip())
			enddo
		endif
		
		
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		// 2- Pesquiso se h? exce鈬o para qualquer estado destino da mercadoria (**) e
		//    tipo de cliente
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		if nAliqPP + nAliqST == 0
			
			if SF7->(dbSeek(xFilial("SF7") + SB1->B1_GRTRIB + SA1->A1_GRPTRIB))
				do while SF7->(!eof() .and. F7_FILIAL + F7_GRTRIB + F7_GRPCLI == xFilial("SF7") + SB1->B1_GRTRIB + SA1->A1_GRPTRIB)
					if SF7->F7_EST == "**" .and. SF7->F7_TIPOCLI == SC5->C5_TIPOCLI
						nAliqPP	:= (SF7->F7_ALIQEXT / 100)
						nAliqST	:= (SF7->F7_ALIQINT / 100)
						nMVA	:= iif(SF7->F7_MARGEM > 0, (1 + (SF7->F7_MARGEM / 100)), 0)
						exit
					endif
					SF7->(dbSkip())
				enddo
			endif
			
		endif
		
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		// 3- Pesquiso se ha excecao para o estado destino da mercadoria e qualquer tipo
		//    de cliente (**)
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		if nAliqPP + nAliqST == 0
			
			if SF7->(dbSeek(xFilial("SF7") + SB1->B1_GRTRIB + SA1->A1_GRPTRIB))
				do while SF7->(!eof() .and. F7_FILIAL + F7_GRTRIB + F7_GRPCLI == xFilial("SF7") + SB1->B1_GRTRIB + SA1->A1_GRPTRIB)
					if SF7->F7_EST == SA1->A1_EST .and. SF7->F7_TIPOCLI == "**"
						nAliqPP	:= (SF7->F7_ALIQEXT / 100)
						nAliqST	:= (SF7->F7_ALIQINT / 100)
						nMVA	:= iif(SF7->F7_MARGEM > 0, (1 + (SF7->F7_MARGEM / 100)), 0)
						exit
					endif
					SF7->(dbSkip())
				enddo
			endif
			
		endif
		
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		// 4- Por ?ltimo, pesquiso se h? exce鈬o para o qualquer estado destino da
		//    mercadoria (**) e qualquer tipo de cliente (**)
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		if nAliqPP + nAliqST == 0
			
			if SF7->(dbSeek(xFilial("SF7") + SB1->B1_GRTRIB + SA1->A1_GRPTRIB))
				do while SF7->(!eof() .and. F7_FILIAL + F7_GRTRIB + F7_GRPCLI == xFilial("SF7") + SB1->B1_GRTRIB + SA1->A1_GRPTRIB)
					if SF7->F7_EST = "**" .and. SF7->F7_TIPOCLI = "**"
						nAliqPP	:= (SF7->F7_ALIQEXT / 100)
						nAliqST	:= (SF7->F7_ALIQINT / 100)
						nMVA	:= iif(SF7->F7_MARGEM > 0, (1 + (SF7->F7_MARGEM / 100)), 0)
						exit
					endif
					SF7->(dbSkip())
				enddo
			endif
			
		endif
		
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		// Verifico se ha calculo de IPI
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		SF4->(msSeek(xFilial("SF4") + SC6->C6_TES))
		if SF4->F4_IPI == "S"
			nAliqIPI	:= SB1->B1_IPI / 100
		endif
		
		
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		// Para opera鋏es ? partir de SP
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		if SM0->M0_ESTCOB == "SP"

			nBaseICMS	:= SC6->C6_VALOR + Round(SC6->C6_VALOR * nAliqIPI, 2)
			//Produtos nacionais
			if lNacional
				
				nVlICMS		:= Round(nBaseICMS * nAliqPP, 2)
				
				//efetuando o calculo da base do ICMS e do valor do ICMS
				if nAliqST <> 0
					nBaseST	:= Round((nBaseICMS - nVlICMS) * nMVA, 2)
					nVlST	:= Round(nBaseST * nAliqST, 2) - Round( nBaseICMS * nAliqPP, 2)
					aRet	:= {nBaseST, nVlST}
				endif
				
				//Produtos importados
			else
				
				//efetuando o calculo da base do ICMS e do valor do ICMS
				if nAliqST <> 0
					nBaseST	:= Round(nBaseICMS * nMVA, 2)
					nVlST	:= Round(nBaseST * nAliqST, 2) - nVlICMS
					aRet	:= {nBaseST, nVlST}
				endif
				
			endif

		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		// Para opera鋏es ? partir de AM
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		elseif SM0->M0_ESTCOB == "AM"

			//se houver MVA, calculo a base e o valor do ST
			if nMVA > 0
			
				if SC5->C5_FRETE > 0
					nValFrete := GetPropFrt()
				endif

				//Identificando o valor total do item (qtde * vlr.unitario)
				nBaseICMS	:= SC6->C6_VALOR + (Round(SC6->C6_VALOR * nAliqIPI, 2)) + nValFrete
				nVlICMS		:= Round(nBaseICMS * nAliqPP, 2)

				//Para opera鋏es a partir de AM, para clientes do AP, retiro o ICMS PP da base de calculo do ICMS ST.
				//Solicitado pela Valquiria em 03/09/14
				if SA1->A1_EST == "AP"
					nBaseICMS	-= nVlICMS
				endif
				
				//efetuando o calculo da base do ICMS e do valor do ICMS
				if nAliqST <> 0
					nBaseST	:= Round(nBaseICMS * nMVA, 2)
					nVlST	:= Round(nBaseST * nAliqST, 2) - nVlICMS
					aRet	:= {nBaseST, nVlST}
				endif
				
			
			//Se n縊 houver MVA, zero a base e o valor do ST
			else
				
				aRet	:= {0, 0}
				
			endif
				
		endif
		
	endif
	
endif

SA1->(RestArea(aAreaSA1))
SB1->(RestArea(aAreaSB1))
SF4->(RestArea(aAreaSF4))
SF7->(RestArea(aAreaSF7))
RestArea(aArea)

Return(aRet)


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		GETPROPFRT                                                    /@
@type				Static Function                                               /@
@date				22/08/2019                                                    /@
@description	Calcula o valor do frete proporcionalmente em rela鈬o ao valor
					do item do pedido.                                            /@
@author			Adalberto Moreno Batista (Op鈬o Um)                           /@
@use				Brasitech                                                     /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function GetPropFrt()
Local nRet			:= 0
Local aArea			:= GetArea()
Local cNextAlias	:= GetNextAlias()
Local cQuery, nRateio

If SC9->C9_PRCVEN > 0 .and. SF4->F4_ISS <> "S"
	cQuery := "SELECT SUM(SC6.C6_VALOR) TOTALPED " +;
				 "FROM " + RetSqlName("SC6") + " SC6, " + RetSqlName("SF4") + " SF4 " +;
				 "WHERE SC6.C6_FILIAL = '" + xFilial("SC6") + "' " +;
						  "AND SC6.C6_NUM = '" + SC5->C5_NUM + "' " +;
						  "AND SC6.C6_PRCVEN > 0 " +;
						  "AND SC6.D_E_L_E_T_ = ' ' " +;
						  "AND SF4.F4_FILIAL = '" + xFilial("SF4")+"' " +;
						  "AND SF4.F4_CODIGO = SC6.C6_TES " +;
						  "AND SF4.D_E_L_E_T_ = ' ' " +;
						  "AND SF4.F4_ISS <> 'S' "
	
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cNextAlias, .F., .T.)

	nRateio 		:= SC6->C6_VALOR / NoRound(TOTALPED,8)
	nRet			:= Round(SC5->C5_FRETE * nRateio, 2)
	(cNextAlias)->(dbCloseArea())
 
	RestArea(aArea)	
Endif

Return(nRet)