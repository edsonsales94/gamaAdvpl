#include "rwmake.ch"
#include "protheus.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		PE01NFESEFAZ                                                  /@
@type				User function                                                 /@
@date				13/02/2012                                                    /@
@description	Manipula variaveis utilizadas na rotina NFESEFAZ              /@
@author			Adalberto Moreno Batista (Opção Um Tecnologia)                /@
@use				Brasitech                                                     /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function PE01NFESEFAZ()
Local cMensCli		:= aParam[2]
Local cMensFis		:= aParam[3]
Local aDest 		:= aParam[4]
Local aEntrega		:= aParam[9]
Local aEspVol     := aParam[14]
Local aObsCont		:= aParam[17]
Local _aAreaItem
Local _cNFD								//variavel auxiliar na montagem das notas fiscais de devolucao na variavel _cnfdevol
Local _aiMSG		:= {}				//multidimensional {1o.elemento cod.formula, 2o.elemento texto da mensagem}
Local _ciTIPONF	:= " "
Local _ciNFCompl	:= " "			//variavel para armazenar numero / serie e data de notas complementares
Local _ciNFDevol	:= " "			//armazena numero/serie e data da nota original
Local _aiNFDevol	:= {0,0,0,0}	//armazena Vl.ICMS, Base ST, Val.ICMR e Val.IPI da nota original em notas de devolucao
Local _cObs			:= ""
Local _aiPEDEMP	:= {}
Local _nK
Local _cSepara		:= "#"		//" /*/ "
Local lInfAdZF  	:= GetNewPar("MV_INFADZF",.F.)
Local nValCofZF 	:= 0
Local nValPisZF	:= 0
Local nDescZFR		:= 0
Local lSuframa		:= .F.
Local cComplEnd	:= AllTrim( GetMV("BR_COMPEND", .F., "") )
Local aArea			:= GetArea()
Local aAreaSA1		:= SA1->(GetArea())
Local aAreaSC5		:= SC5->(GetArea())
Local aAreaSC6		:= SC6->(GetArea())
Local aAreaSD1		:= SD1->(GetArea())
Local aAreaSD2		:= SD2->(GetArea())
Local aAreaSF4		:= SF4->(GetArea())
Local aAreaSF3		:= SF3->(GetArea())

//Inclui a informacao do complemento do endereco em dados adicionais
if !Empty(cComplEnd)
	cMensCli += iif(Empty(cMensCli), "", _cSepara) + cComplEnd + _cSepara
endif

//Setando as ordens das tabelas a serem utilizadas na nota fiscal
SC5->(dbSetOrder(1))
SC6->(dbSetOrder(1))
SD1->(dbsetorder(1))
SD2->(dbsetorder(3))
SF4->(dbSetOrder(1))
SF3->(dbSetOrder(4))

//———————————————————————————————————————————————————————————————————————————————
// Array aDest - Ajuste no CEP para destinatario EX
//———————————————————————————————————————————————————————————————————————————————
if Upper(aDest[8]) == "EX"			//estado
	aDest[10]	:= "        "		//CEP
endif

//———————————————————————————————————————————————————————————————————————————————
// Notas de saida
//———————————————————————————————————————————————————————————————————————————————
if cTpES == "1"

	//———————————————————————————————————————————————————————————————————————————————
	// Array aEntrega
	//———————————————————————————————————————————————————————————————————————————————
	if SF2->(FieldPos("F2_CLIENT"))<>0 .And. !Empty(SF2->F2_CLIENT+SF2->F2_LOJENT) .And. SF2->F2_CLIENT+SF2->F2_LOJENT<>SF2->F2_CLIENTE+SF2->F2_LOJA
	elseif Len(aEntrega) = 0
		SD2->( dbSetOrder(3) )
		SC5->( dbSetOrder(1) )
		
		if SD2->(dbSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA))
			if SC5->(dbSeek(xFilial("SC5") + SD2->D2_PEDIDO)) .and. !Empty(SC5->C5_ENDENT)
				aAdd(aEntrega, Posicione("SA1", 1, xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA, "A1_CGC"))
				aAdd(aEntrega, FisGetEnd(SC5->C5_ENDENT)[1])
				aAdd(aEntrega, ConvType(Iif( FisGetEnd(SC5->C5_ENDENT)[2] <> 0, FisGetEnd(SC5->C5_ENDENT)[2],"SN" )))
				aAdd(aEntrega, FisGetEnd(SC5->C5_ENDENT)[4])
				aAdd(aEntrega, SC5->C5_BAIRROE)
				aAdd(aEntrega, Posicione("SA1", 1, xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA, "A1_COD_MUN"))
				aAdd(aEntrega, SC5->C5_MUNE)
				aAdd(aEntrega, SC5->C5_ESTE)
				aAdd(aEntrega, SA1->A1_NOME)
				aAdd(aEntrega, Iif(!Empty(SA1->A1_INSCR), VldIE(SA1->A1_INSCR), ""))
				aAdd(aEntrega, Alltrim(SA1->A1_CEP))
				aAdd(aEntrega, IIF(Empty(SA1->A1_PAIS), "1058",	  Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_SISEXP")))
				aAdd(aEntrega, IIF(Empty(SA1->A1_PAIS), "BRASIL", Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_DESCR")))
				aAdd(aEntrega, Alltrim(SA1->A1_DDD) + Alltrim(SA1->A1_TEL)) 
				aAdd(aEntrega, Alltrim(SA1->A1_EMAIL))
			endif
		endif
	
	endif

	//———————————————————————————————————————————————————————————————————————————————
	// Array aEspVol
	//———————————————————————————————————————————————————————————————————————————————
	if !Empty(SF2->F2_ESPECI1) .and. !Empty(SF2->F2_VOLUME1)
		aEspVol	:= {{SF2->F2_ESPECI1, SF2->F2_VOLUME1 , SF2->F2_PLIQUI , SF2->F2_PBRUTO}}
	else
		aEspVol	:= {}
	endif


	//———————————————————————————————————————————————————————————————————————————————
	// Variavel cMensCli. Antiga funcao NFEMSG
	//———————————————————————————————————————————————————————————————————————————————
	_ciTIPONF	:= SF2->F2_TIPO

	if !SF2->F2_TIPO $ "BD"

		if SA1->(dbSeek(xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA))

			//———————————————————————————————————————————————————————————————————————————————
			// Atualização de vetor para uso de tags especificas (xCampo e xTexto)
			// Integração com FM Logistics
			// Em 28/11/19 por Adalberto Moreno Batista
			//———————————————————————————————————————————————————————————————————————————————
			if !Empty(SA1->A1_XREGESP)
				aObsCont	:= {{"RegEsp", AllTrim(SA1->A1_XREGESP)}}
			endif

			// Verificando se cliente pertence SUFRAMA
			if !Empty(SA1->A1_SUFRAMA)
				lSuframa := .T.
			endif
		endif
	endif
		
	//dados dos itens da nota
	dbSelectArea("SD2")
	if dbSeek(xFilial("SD2")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA))
		
		do while SD2->(!eof() .and. D2_FILIAL == xFilial("SD2") .and.;
						D2_DOC == SF2->F2_DOC .and.;
						D2_SERIE == SF2->F2_SERIE .and.;
						D2_CLIENTE == SF2->F2_CLIENTE .and.;
						D2_LOJA == SF2->F2_LOJA)
			
			SC5->(dbSeek(xFilial("SC5") + SD2->D2_PEDIDO))
			SC6->(dbSeek(xFilial("SC6") + SD2->D2_PEDIDO + SD2->D2_ITEMPV))
			SF4->(dbSeek(xFilial("SF4") + SD2->D2_TES))

			//dados das mensagens da nota
			//numeros de pedidos Empresa
			if aScan(_aiPEDEMP, SC5->C5_NUM) == 0
			
				aAdd(_aiPEDEMP, SC5->C5_NUM)

				// Mensagem de Endereco Op. Logistico
         	if !SD2->D2_TIPO $ "BD" .And. SM0->M0_CODIGO == "01" .And. SM0->M0_CODFIL == "03" .And. !("SAÍDA DO ARMAZEM GERAL FM LOGISTIC DO BRASIL OPERAÇÕES DE LOGISTICA LTDA. CNPJ:02.462.805./0007-78 IE:115.266.030.117 - VIA ANHANGUERA S/N KM.26.421-JD JARAGUA-SP CEP:05275-000" $ cMensCli)
            	cMensCli += "SAÍDA DO ARMAZEM GERAL FM LOGISTIC DO BRASIL OPERAÇÕES DE LOGISTICA LTDA. CNPJ:02.462.805./0007-78 IE:115.266.030.117 - VIA ANHANGUERA S/N KM.26.421-JD JARAGUA-SP CEP:05275-000" + _cSepara
            endif

            // Mensagem da Suframa Brasitech
            if SM0->M0_CODIGO == "01" .And. SM0->M0_CODFIL $ "01/04" .And. !("Suframa 20010965-0" $ cMensCli)    //antigo 20117401-4 
            	cMensCli += "Suframa 20010965-0" + _cSepara 
            endif

				// Mensagem do valor da ST
				if SM0->M0_CODIGO == "01" .And. SM0->M0_CODFIL == "01" .And. !("ICMS ST:" $ cMensCli) .And. SF2->F2_ICMSRET > 0
            	cMensCli += "ICMS ST: R$ " + Alltrim(Transf(SF2->F2_ICMSRET,"@E 999,999,999.99")) + _cSepara
    			endif                

            // Mensagem da Suframa Techit
            if SM0->M0_CODIGO == "04" .And. !("Suframa 20117001-9" $ cMensCli)
            	cMensCli += "Suframa 20117001-9" + _cSepara
            endif

            // Mensagem de Divergencia
            if !SD2->D2_TIPO $ "BD" .And. !("Qualquer divergencia deve ser comunicada no ato do recebimento e ressalvada no verso da NF de entrega." $ cMensCli)
					cMensCli += "Numero Pedido : " + Alltrim(SC5->C5_NUM) + " - Qualquer divergencia deve ser comunicada no ato do recebimento e ressalvada no verso da NF de entrega." + _cSepara
     			endif

  		      // Seu Pedido 
				if !SD2->D2_TIPO $ "BD" .And. !Empty(Alltrim(SC6->C6_PEDCLI)) .And. !("Seu Pedido :" $ cMensCli)
					cMensCli += "Seu Pedido : " + Alltrim(SC6->C6_PEDCLI) + _cSepara
				endif

            // Endereco de Entrega
           	if !SD2->D2_TIPO $ "BD" .And. !Empty(Alltrim(SC5->C5_ENDENT)) .And. !("Endereço de Entrega :" $ cMensCli)
	         	cMensCli += "Endereço de Entrega :" + Alltrim(SC5->C5_ENDENT)  + " - " + Alltrim(SC5->C5_BAIRROE) + " " + Alltrim(SC5->C5_MUNE) + " - " + Alltrim(SC5->C5_ESTE) + ALLTRIM(SC5->C5_CEPE) + _cSepara
				endif

  	         // Mensagem da Nota 1 e nao pula linha
            if !Empty(Alltrim(SC5->C5_MENNOT1)) .And. !(Alltrim(SC5->C5_MENNOT1) $ cMensCli)
     		   	cMensCli += Alltrim( SC5->C5_MENNOT1 )
				endif
                
            // Mensagem da Nota 2 e pula linha
            if !Empty(Alltrim(SC5->C5_MENNOT2)) .And. !(Alltrim(SC5->C5_MENNOT2) $ cMensCli)
     		   	cMensCli += " - " + Alltrim(SC5->C5_MENNOT2) + _cSepara
            endif

  	         // Mensagem da Nota 3 e nao pula linha
            if !Empty(Alltrim(SC5->C5_MENNOT3)) .And. !(Alltrim(SC5->C5_MENNOT3) $ cMensCli)
     		   	cMensCli += Alltrim(SC5->C5_MENNOT3)
           	endif
                
            // Mensagem da Nota 4 e pula linha
            if !Empty(Alltrim(SC5->C5_MENNOT4)) .And. !(Alltrim(SC5->C5_MENNOT4) $ cMensCli)
     		   	cMensCli += " - " + Alltrim( SC5->C5_MENNOT4 ) + _cSepara
           	endif

            // Mensagem da Nota 4 e pula linha
            if !Empty(Alltrim(SC5->C5_MENNOT5)) .And. !(Alltrim(SC5->C5_MENNOT5) $ cMensCli)
     		   	cMensCli += " - " + Alltrim(SC5->C5_MENNOT5) + _cSepara
           	endif

			endif

			//Mensagens nos TES
		if aScan(_aiMSG, { |x| x[1] = SF4->F4_MENNOT1}) == 0 .and. !Empty(SF4->F4_MENNOT1)
				
				aAdd(_aiMSG, {SF4->F4_MENNOT1, Formula(SF4->F4_MENNOT1)})	//Mensagem Padrao no TES
				
			endif
			
			if aScan(_aiMSG, {|x| x[1] = SF4->F4_MENNOT2}) == 0 .and. !Empty(SF4->F4_MENNOT2)
				
				aAdd(_aiMSG, {SF4->F4_MENNOT2, Formula(SF4->F4_MENNOT2)})	//Mensagem Padrao no TES
				
			endif

			//armazenando em _ciNFDevol as notas fiscais, series e dt.emissao originais
			if !Empty(SD2->D2_NFORI) .and. SD2->D2_TIPO $ "BD"
				
				SD1->(dbSeek(xFilial("SD1") + SD2->(D2_NFORI + D2_SERIORI + D2_CLIENTE + D2_LOJA + D2_COD + D2_ITEMORI)))
				_cNFD = AllTrim(SD2->D2_NFORI) + "/" + AllTrim(SD2->D2_SERIORI) + " de " + dtoc(SD1->D1_EMISSAO)
				//Pergunta para nao repetir mesma nota/serie/data
				if !_cNFD $ _ciNFDevol
					_ciNFDevol += iif(Empty(_ciNFDevol),"",", ") + _cNFD
				endif
				
				//Alimentando array de notas de devolucao para destaque de ICMR e Base
				_aiNFDevol[1] += SD2->D2_VALICM		//NoRound(_nProp*SD1->D1_VALICM)		//[1] - Valor do ICMS (proporcional)
				_aiNFDevol[2] += SD2->D2_BRICMS		//NoRound(_nProp*SD1->D1_BRICMS)		//[2] - Base do ICMR (proporcional)
				_aiNFDevol[3] += SD2->D2_ICMSRET		//NoRound(_nProp*SD1->D1_ICMSRET)	//[3] - Valor do ICMR (proporcional)
				_aiNFDevol[4] += SD2->D2_VALIPI		//NoRound(_nProp*SD1->D1_VALIPI)		//[4] - Valor do IPI (proporcional)
				
			endif
			
			//armazenando em _ciNFCompl as notas fiscais, series e dt.emissao originais
			if !Empty(SD2->D2_NFORI) .and. SD2->D2_TIPO $ "CIP"
				_aAreaItem	:= SD2->(GetArea())
				_cNFD			:= AllTrim(SD2->D2_NFORI) + "/" + AllTrim(SD2->D2_SERIORI) + " de " + dtoc(GetAdvFVal("SD2", "D2_EMISSAO", xFilial("SD2") + SD2->(D2_NFORI + D2_SERIORI + D2_CLIENTE + D2_LOJA), 3))
				SD2->(RestArea(_aAreaItem))
				
				//Pergunta para nao repetir mesma nota/serie/data
				if !_cNFD $ _ciNFCompl
					_ciNFCompl += iif(Empty(_ciNFCompl),"",", ") + _cNFD
				endif
			endif


			//———————————————————————————————————————————————————————————————————————————————
			// Desconto Zona Franca PIS e COFINS. Retirei da NFESEFAZ
			//———————————————————————————————————————————————————————————————————————————————
				If	SD2->(FieldPos("D2_DESCZFC"))<>0 .AND. SD2->(FieldPos("D2_DESCZFP"))<>0
					If SD2->D2_DESCZFC > 0	
						nValCofZF += SD2->D2_DESCZFC
					EndIf
					If SD2->D2_DESCZFP > 0	
						nValPisZF += SD2->D2_DESCZFP
					EndIf
				EndIf 

				//total de desconto Zona Franca
				nDescZFR	+= SD2->D2_DESCZFR
				
			//fim

			dbSelectArea("SD2")
			dbSkip()
		enddo
		
	endif

		//———————————————————————————————————————————————————————————————————————————————
		// Mensagem de Desconto para Zona Franca. Retirei da NFESEFAZ
		//———————————————————————————————————————————————————————————————————————————————
		if lSuframa

			if nDescZFR > 0
			
				cMensFis += iif( Empty( cMensFis ), "", " /*/ " )
				
				if lInfAdZF .And. (nValPisZF > 0 .Or. nValCofZF > 0)
					cMensFis += "Descontos Ref. a Zona Franca de Manaus / ALC. ICMS - R$ " + AllTrim( str(nDescZFR - nValPisZF - nValCofZF, 13, 2) ) + ", PIS - R$ "+ AllTrim( str(nValPisZF, 13, 2) ) +" e COFINS - R$ " + AllTrim( str(nValCofZF, 13, 2) )
					
				elseif !lInfAdZF .And. (nValPisZF > 0 .Or. nValCofZF > 0) 
					cMensFis += "Desconto Ref. ao ICMS - Zona Franca de Manaus / ALC. R$ " + AllTrim( str(nDescZFR - nValPisZF - nValCofZF, 13, 2) )
					
			    else
			    	cMensFis += "Total do desconto Ref. a Zona Franca de Manaus / ALC. R$ " + AllTrim( Str(nDescZFR, 13, 2) )
			    	
			    endif
			    
			endif
			
		Endif
	//fim

//———————————————————————————————————————————————————————————————————————————————
// Notas de entrada
//———————————————————————————————————————————————————————————————————————————————
else

	//———————————————————————————————————————————————————————————————————————————————
	// Variavel cMensCli. Antiga funcao NFEMSG
	//———————————————————————————————————————————————————————————————————————————————
	_ciTIPONF		:= SF1->F1_TIPO
    
	//Mensagens especificas para nota fiscal de entrada
	if !Empty(SF1->F1_XMENSG1)
		aAdd(_aiMSG,{ '', SF1->F1_XMENSG1 })
	endif
	
	if !Empty(SF1->F1_XMENSG2)
		aAdd(_aiMSG,{ '', SF1->F1_XMENSG2 })
	endif
	
	if !Empty(SF1->F1_XMENSG3)
		aAdd(_aiMSG,{ '', SF1->F1_XMENSG3 })
	endif
	
	if !Empty(SF1->F1_XMENSG4)
		aAdd(_aiMSG,{ '', SF1->F1_XMENSG4 })
	endif
	
	if !Empty(SF1->F1_XMENSG5)
		aAdd(_aiMSG,{ '', SF1->F1_XMENSG5 })
	endif

	if !SF1->F1_TIPO $ "BD" .And. SM0->M0_CODIGO == "01" .And. SM0->M0_CODFIL == "03" .And. SF1->F1_EST  == 'EX'
		aAdd(_aiMSG,{ '', "ENDEREÇO DE ENTREGA FM LOGISTIC - VIA ANHANGUERA KM 26.421 JARDIM JARAGUA-SP" })
	endif 

	
	//dados dos itens da nota
	if SD1->(dbSeek(xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))

		
		do while SD1->(!eof() .and. D1_FILIAL == xFilial("SD1") .and.;
						D1_DOC == SF1->F1_DOC .and.;
						D1_SERIE == SF1->F1_SERIE .and.;
						D1_FORNECE == SF1->F1_FORNECE .and.;
						D1_LOJA == SF1->F1_LOJA)
			
			//buscando mensagens no cadastro de TES
			SF4->(dbSeek(xFilial("SF4")+SD1->D1_TES))
			if aScan( _aiMSG, { |x| x[1] = SF4->F4_MENNOT1 } ) = 0 .and. !Empty( SF4->F4_MENNOT1 )
				aAdd( _aiMSG, { SF4->F4_MENNOT1, Formula( SF4->F4_MENNOT1 ) } )	//Mensagem Padrao no TES
				cMensFis += Formula( SF4->F4_MENNOT1 ) + _cSepara
			endif
			if aScan( _aiMSG, { |x| x[1] = SF4->F4_MENNOT2 } ) = 0 .and. !Empty( SF4->F4_MENNOT2 )
				aAdd( _aiMSG, { SF4->F4_MENNOT2, Formula( SF4->F4_MENNOT2 ) } )	//Mensagem Padrao no TES
				cMensFis += Formula( SF4->F4_MENNOT2 ) + _cSepara
			endif

			//armazenando em _ciNFDevol as notas fiscais, series e dt.emissao originais
			if !Empty(SD1->D1_NFORI) .and. SD1->D1_TIPO$"BD"
				
				SD2->(dbSeek(xFilial("SD2")+SD1->(D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEMORI)))
				_cNFD = AllTrim(SD1->D1_NFORI)+"/"+AllTrim(SD1->D1_SERIORI)+" de "+dtoc(SD2->D2_EMISSAO)
				//Pergunta para nao repetir mesma nota/serie/data
				if !_cNFD $ _ciNFDevol
					_ciNFDevol += _cNFD+", "
				endif
				
				//Alimentando array de notas de devolucao para destaque de ICMR e Base
				_aiNFDevol[1] += SD1->D1_VALICM		//NoRound(_nProp*SD2->D2_VALICM)			//[1] - Valor do ICMS (proporcional)
				_aiNFDevol[2] += SD1->D1_BRICMS		//NoRound(_nProp*SD2->D2_BRICMS)			//[2] - Base do ICMR (proporcional)
				_aiNFDevol[3] += SD1->D1_ICMSRET		//NoRound(_nProp*SD2->D2_ICMSRET)		//[3] - Valor do ICMR (proporcional)
				_aiNFDevol[4] += SD1->D1_VALIPI		//NoRound(_nProp*SD2->D2_VALIPI)			//[4] - Valor do IPI (proporcional)
				
			endif
			
			//armazenando em _ciNFCompl as notas fiscais, series e dt.emissao originais
			if !Empty(SD1->D1_NFORI) .and. SD1->D1_TIPO$"CIP"
				_aAreaItem := SD1->(GetArea())
				_cNFD = AllTrim(SD1->D1_NFORI) + "/" + AllTrim(SD1->D1_SERIORI) + " de " + dtoc(GetAdvFVal("SD1", "D1_EMISSAO", xFilial("SD1") + SD1->(D1_NFORI + D1_SERIORI + D1_FORNECE + D1_LOJA), 1))
				SD1->(RestArea(_aAreaItem))
				
				//Pergunta para nao repetir mesma nota/serie/data
				if !_cNFD $ _ciNFCompl
					_ciNFCompl += iif(Empty(_ciNFCompl), "", ", ") + _cNFD + ", "
				endif
			endif
			
			SD1->(dbSkip())
		enddo
		
	endif
		
endif

//atribuindo as mensagens carregadas no array _aiMSG 
for _nK := 1 to Len(_aiMSG)
	if !Empty(_aiMSG[_nK,2])
		cMensCli += iif( Empty( cMensCli ), "", " /*/ " ) + _aiMSG[_nK,2]
	endif
next

//Mensagens para notas complementares
if _ciTIPONF = "C"
	cMensFis += "Complemento de PRECO destacado a menor em N.NF/Serie " + _ciNFCompl + _cSepara
elseif _ciTIPONF = "I"
	cMensFis += "Complemento de ICMS destacado a menor em N.NF/Serie " + _ciNFCompl + _cSepara
elseif _ciTIPONF = "P"
	cMensFis += "Complemento de IPI destacado a menor em N.NF/Serie " + _ciNFCompl + _cSepara
endif

//Mensagens especificas para DEVOLUCAO
if _ciTIPONF $ "BD"

	if !Empty(_ciNFDevol)
		_cObs += iif(Empty(_cObs), "", " /*/ ") + "Devol. Ref. S/NF " + _ciNFDevol
	endif
	
	if _aiNFDevol[2] > 0
		_cObs += iif(Empty(_cObs), "", " /*/ ") + "ICMS Destacado: " + AllTrim(Transf(_aiNFDevol[1], "@E 999,999,999.99"))
		_cObs += iif(Empty(_cObs), "", " /*/ ") + "Base ICMS ST: " + AllTrim(Transf(_aiNFDevol[2], "@E 999,999,999.99"))
		_cObs += iif(Empty(_cObs), "", " /*/ ") + "Valor ICMS ST: " + AllTrim(Transf(_aiNFDevol[3], "@E 999,999,999.99"))
	endif
	
	if _aiNFDevol[4] > 0
		_cObs += iif(Empty(_cObs), "", " /*/ ") + "Valor IPI: " + AllTrim(Transf(_aiNFDevol[4], "@E 999,999,999.99"))
	endif
	
	cMensFis += _cObs
	
endif

//———————————————————————————————————————————————————————————————————————————————
// Atribuição dos novos conteúdos do array aParam
//———————————————————————————————————————————————————————————————————————————————
aParam[2] 	:= cMensCli
aParam[3] 	:= cMensFis
aParam[4] 	:= aDest
aParam[9] 	:= aEntrega
aParam[14]	:= aEspVol
aParam[17]	:= aObsCont

//———————————————————————————————————————————————————————————————————————————————
// Restauração dos posicionamentos
//———————————————————————————————————————————————————————————————————————————————
RestArea(aAreaSA1)
RestArea(aAreaSC5)
RestArea(aAreaSC6)
RestArea(aAreaSD1)
RestArea(aAreaSD2)
RestArea(aAreaSF4)
RestArea(aAreaSF3)
RestArea(aArea)
 
Return(aParam)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		CONVTYPE                                                      /@
@type				Static function                                               /@
@description	Original no fonte NFESEFAZ                                    /@
@author			Adalberto Moreno Batista (Opção Um Tecnologia)                /@
@use				Brasitech                                                     /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function ConvType(xValor,nTam,nDec)

Local cNovo := ""
DEFAULT nDec := 0
Do Case
	Case ValType(xValor)=="N"
		If xValor <> 0
			cNovo := AllTrim(Str(xValor,nTam,nDec))	
		Else
			cNovo := "0"
		EndIf
	Case ValType(xValor)=="D"
		cNovo := FsDateConv(xValor,"YYYYMMDD")
		cNovo := SubStr(cNovo,1,4)+"-"+SubStr(cNovo,5,2)+"-"+SubStr(cNovo,7)
	Case ValType(xValor)=="C"
		If nTam==Nil
			xValor := AllTrim(xValor)
		EndIf
		DEFAULT nTam := 60
		cNovo := AllTrim(EnCodeUtf8(NoAcento(SubStr(xValor,1,nTam))))
EndCase
Return(cNovo)
