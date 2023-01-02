/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MTA410  º Autor ³ Cristiano Figueiroa º Data ³ 19/02/2009  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ponto de Entrada disparado apos a confirmacao do pedido de º±±
±±º          ³ Vendas.                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasitech ( Gama Italy )                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#Include "RwMake.ch"
#Include "Protheus.ch"

User Function MTA410()
Local lRet          := .T.
Local aArea 		:= GetArea()
Local aAreaSA4 		:= SA4->(GetArea())
Local nPosProduto   := aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "C6_PRODUTO"   })
Local nPosDesconto  := aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "C6_DESCONT"   })
Local nPosValor     := aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "C6_VALOR"     })
Local nPosComis1    := aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "C6_COMIS1"    })
Local nPosCodKit    := aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "C6_CODKIT"    })
Local cTransp		:= alltrim(M->C5_TRANSP)
Local nVlrPed       := 0
Local lCliDesEsp    := .F.
Local lPergunta		:= .F.
Local aProdProc     := {}
Local aKitDel       := {}
Local aKitAtv       := {}
Local lEspPrz, lEspPar, cUserLib, cMsgEsp, y
Private aPolCom     := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava nome do usuario que incluiu pedido e informacoes do vendedor no ³
//³ pedido de vendas, que posteriormente serao serao gravados na NF.      ³
//³ SI8401 - Adalberto em 18/04/11                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if INCLUI
	
	if SC5->( FieldPos("C5_USRINC") ) > 0
		M->C5_USRINC  := Alltrim( Substr(cUsuario, 7, 15) )
	endif
	
	if 	SC5->( FieldPos("C5_XREPRES") ) > 0 .and.;
		SC5->( FieldPos("C5_XEXECUT") ) > 0 .and.;
		SC5->( FieldPos("C5_XASSIST") ) > 0 .and.;
		SC5->( FieldPos("C5_XCANAL") ) > 0
		
		A_MTA410()

	endif

endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida politica comercial somente se for pedido INTERNO (C5_X_ORIG=1) e ³
//³ tipo NORMAL (C5_TIPO=N) e para casos de INCLUSAO ou ALTERACAO e chamado ³
//³ pelas rotinas de Pedido de Venda (MATA410) ou Orcamento (MATA416)       ³
//³ Reorganizacao do ponto de entrada                                       ³
//³ Por: Adalberto Moreno Batista em 15/05/13                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

if SC5->( FieldPos("C5_X_ORIG") ) > 0

if	M->C5_X_ORIG != "2" .and.;
	M->C5_TIPO == "N" .and.;
	(INCLUI .or. ALTERA) .and.;
	(Funname() $ ("MATA410-MATA416"))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso o a transportadora nao esteja preenchida nao grava	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if lRet .and. Empty(M->C5_TPFRETE)
		if !l410Auto
			Aviso( "Campo Obrigatorio!" , "Atenção! Informe o Tipo de Frete antes de confirmar a gravação do Pedido!", {"Ok"}, 1, "Transportadora!" )
		else
			ConOut("MTA410 - Informe o Tipo de Frete (C5_TPFRETE) antes de confirmar a gravação do Pedido")
		endif		
		lRet := .f.
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o vendedor esta INATIVO |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if lRet
		SA3->(DbSetOrder(1))        // Filial + Vendedor
		if SA3->( DbSeek(xFilial("SA3") + M->C5_VEND1) )
			if SA3->A3_MSBLQL == "1" .and. lRet
				if !l410Auto
					Aviso( "Vendedor Inativo!", "Este Vendedor está inativo. Verifique o cadastro!", {"Ok"}, 1, "Vendedor!" )
				else
					ConOut("MTA410 - Vendedor inativo, verifique o cadastro - C5_VEND1 = " +  M->C5_VEND1)
				endif
				lRet := .f.
			endif   
		endif
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chama a Funcao que Retorna a Politica Comercial Vigente ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if lRet
		lRet := u_RetPolCom( M->C5_CLIENTE , aPolCom )

		if !lRet .and. !l410Auto
			lPergunta := .T.
		endif
		
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processa todos os Itens do Acols ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if lRet
		For y := 1 to Len(aCols)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a Linha nao esta Deletada ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !aCols[ y , Len(aHeader) + 1 ]
				/*
				Retirada a verificacao de duplicidade de produtos no pedido de vendas
				para a incorporacao de novo conceito de pedido com a inclusao de itens
				de venda e de bonificacao no mesmo pedido para facilitar a analise
				de credito
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Adiciona no Array os Produtos ja Processados    ³
				//³ Caso o produto ja exista bloqueia a confirmacao ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Ascan ( aProdProc , Acols[y][nPosProduto] ) == 0
					Aadd ( aProdProc , Acols[y][nPosProduto] )
				Else
					If !( SM0->M0_CODIGO $ "02-05" )   // Bloqueia a digitação de mais de um item no Pedido
						if !l410Auto
							Aviso( "Politica Comercial !" , "Atenção ! O Produto : " + Alltrim( Acols[y][nPosProduto] ) + " já foi informado anteriormente nesse Pedido de Vendas ! Não é permitida a inclusão de um mesmo ítem em mais de uma linha no Pedido de Vendas !" , {"Ok"} , 1 , "Produto já Existente ! " )
						else
							ConOut("MTA410 - Politica Comercial, o produto : " + Alltrim( Acols[y][nPosProduto] ) + " já foi informado anteriormente nesse Pedido de Vendas ! Não é permitida a inclusão de um mesmo ítem em mais de uma linha no Pedido de Vendas !")
						endif
						lRet := .f.
		    		Endif   
				Endif   
				*/
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se a Linha Ativa se Refere a um Kit ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				if !Empty( aCols[y, nPosCodKit] )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Adiciona no Array de Kits Deletados ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Aadd ( aKitAtv , aCols[ y , nPosCodKit ] )
		         	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Caso seja um Kit , Verifica se existe alguma Linha Ativa para o Kit ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					if Ascan( aKitDel , aCols[ y , nPosCodKit ] ) <> 0
						if !l410Auto
							Aviso( "Kit Promocional !" , "Atenção ! Foi detectado que parte do Kit Promocional : " + Alltrim( aCols[ y , nPosCodKit ] ) + " está deletado. Não é permitida a deleção parcial de linhas do pedido que fazem parte de um Kit ! " , {"Ok"} , 1 , "Deleção de Linhas do Kit ! " )
						else
							ConOut("MTA410 - Kit Promocional, foi detectado que parte do Kit Promocional: " + Alltrim( aCols[ y , nPosCodKit ] ) + " está deletado. Não é permitida a deleção parcial de linhas do pedido que fazem parte de um Kit !")
						endif
						lRet := .f.
					endif
				endif
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atribui as variaveis necessarias ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nVlrPed   += Acols[y][nPosValor]
				nDescIte  := Acols[y][nPosDesconto]  
		      
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Recalcula os Valores de Comissao ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aCols[y][nPosComis1] := u_RetPerCom( M->C5_CLIENTE , M->C5_LOJACLI , M->C5_VEND1 , Acols[y][nPosProduto] )


				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Chama Funcao para Revalidar os Descontos ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				if !( u_VerDesCon( M->C5_CLIENTE , M->C5_CONDPAG , nDescIte ) ) .Or. lEspDes
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Caso nao seja um Desconto Especial e Esteja fora da Faixa de Desconto, Atualiza o Flag de Inconsistencia ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					if !( lEspDes )
						lRet := .F.
						if !l410Auto
							lPergunta := .T.
						endif
					endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza o Flag de Cliente com Desconto Especial ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lCliDesEsp := .T.
				Endif

			Else

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se a Linha Deletada se Refere a um Kit ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				if !Empty( aCols[y, nPosCodKit] )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Adiciona no Array de Kits Deletados ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAdd ( aKitDel , aCols[ y , nPosCodKit ] )

         			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Caso seja um Kit , Verifica se existe alguma Linha Ativa para o Kit ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					if Ascan( aKitAtv , aCols[ y , nPosCodKit ] ) <> 0
						if !l410Auto
							Aviso( "Kit Promocional!" , "Atenção! Foi detectado que parte do Kit Promocional: " + Alltrim( aCols[ y , nPosCodKit ] ) + " está deletado. Não é permitida a deleção parcial de linhas do pedido que fazem parte de um Kit! Delete todas as linhas referentes ao Kit ou Ative as linhas deletadas!", {"Ok"}, 1, "Deleção de Linhas do Kit!" )
						else
							ConOut("MTA410 - Kit Promocional, foi detectado que parte do Kit Promocional: " + Alltrim( aCols[ y , nPosCodKit ] ) + " está deletado. Não é permitida a deleção parcial de linhas do pedido que fazem parte de um Kit !")
						endif
						lRet := .F.
					Endif
         
				Endif
      
			Endif
   
		Next y
    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Realiza a Validacao do Prazo Medio e Numero de Parcelas na ³
		//³ confirmacao do Pedido.                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if !(u_VerPrzMed( M->C5_CLIENTE , M->C5_CONDPAG))
			lRet := .F.    
			lPergunta := .T.
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o Valor do Pedido Atingiu o Valor Minimo Definido na ³
		//³ politica comercial do Cliente.                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (SF4->F4_DUPLIC == "S") .and. Len(aPolCom) > 0
			If nVlrPed < aPolCom[1][1] .or. aPolCom[1][1] = 1
				lRet := .F.
				if !l410Auto
					Aviso( "Política Comercial" , "Atenção! O valor total do pedido (R$ " + Alltrim( Transform ( nVlrPed , "@E 999,999,999.99" ) ) + ") não atingiu o valor mínimo conforme a política comercial vigente para este cliente.", {"Ok"}, 1, "Valor mínimo" )
					lPergunta := .T.
				endif
			Endif
		Endif
		
        
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso o lRet seja FALSO e a variavel de controle lPergunta seja   ³
		//³ VERDADEIRA, significa que o pedido possui alguma divergencia em  ³
		//³ relacao a politica comercial e para continuar passara por uma    ³
		//³ aprovacao                                                        ³
		//³ Por: Adalberto Moreno Batista em 17/06/13,                       ³
		//³ Solicitado por: Luiz Fernando                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if !lRet .and. lPergunta
			if MsgBox("Atenção! As informações do pedido de vendas estão divergentes com relação à política comercial vigente do cliente. Deseja validar o pedido mesmo assim?", "Política Comercial", "YESNO")
				//MsgBox("Atenção! O valor total do pedido (R$ " + Alltrim( Transform ( nVlrPed , "@E 999,999,999.99" ) ) + ") não atingiu o valor mínimo (R$ " + Alltrim( Transform ( aPolCom[1][1] , "@E 999,999,999.99" )) + ") conforme a política comercial vigente para este cliente. Deseja validar assim mesmo?", "Política Comercial", "YESNO")
				cUserLibVM	:= Space(20)
				cMsgEsp		:= ""
				
				lRet := D_MTA410(@cUserLibVM, @cMsgEsp)

				M->C5_USRAPRV := iif(lRet, Alltrim(cUserLibVM), "")
				M->C5_DATAPRV := iif(lRet, dDataBase, cTOd(""))
				M->C5_MSGAPRV := iif(lRet, cMsgEsp, "")
			
			endif
		endif

	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Trata as Variaveis de Desconto/Prazo/Parcela Especiais ³
	//³ Caso nao tenha entrado em condicoes Especiais          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lEspPrz == Nil 
	   lEspPrz := .F.
	Endif            
	
	If lEspPar == Nil 
	   lEspPar := .F.
	Endif 
	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida condicao de pagamento 999 x TES que gera duplicata             ³
	//³ Luiz Fernando - 20/06/11                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if lRet
	
		lRet := B_MTA410()

	endif
                          

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se bonificacao, exige mensagem VPC                                    ³
	//³ Ronaldo Gomes - 06/09/12                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if lRet .and. SM0->M0_CODIGO == '01'
	
 		lRet :=	C_MTA410()
	
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se transportadora for ECT valida os campos Tipo de serviço e 		  ³
	//³ cartão de cobrança                                    				  ³
	//³ Luiz Fernando 20/02/17                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	if lRet .and. SM0->M0_CODIGO == '01' .and. Posicione("SA4", 1, xFilial("SA4") + cTransp,"A4_X_ECT") == "1"
		lret := E_MTA410()
	endif


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso o a transportadora nao esteja preenchida nao grava ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	/*if lRet .and. Empty(M->C5_TRANSP)
		if !l410Auto
			Aviso( "Campo Obrigatorio !", "Atenção! Informe a Transportadora antes de confirmar a gravação do Pedido !", {"Ok"}, 1, "Transportadora!" )
			lRet := .f.
		endif
	endif*/

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chama a Funcao que Valida a Trasnportadora com o Estado do Cliente ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	/*if lRet
		lRet := u_VldTranEst(M->C5_TRANSP,M->C5_UFCLI)
	endif*/

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³            Trata a transportadora de acordo com o valor total do pedido    |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	/*Retirado em 09/04/12 por solicitacao do Cassio.
	If lRet .and. xFilial("SC5") == '03'
		IF nVlrPed < 500 .and. M->C5_TRANSP <> '206212' //'206212' = PAC (RESCOM SERVICOS E COMERCIO -EPP)   - CORREIOS
			If !MsgBox("Atenção! O Valor Total do Pedido ( R$ " + Alltrim( Transform ( nVlrPed , "@E 999,999,999.99" ) ) + " ) é menor que R$500,00. Confirma a transportadora utilizada?","Politica Comercial!","YESNO")
				lRet := .F.
		Endif
	Endif*/


endif
endif

RestArea(aArea)

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ A_MTA410     ³ Por: Adalberto Moreno Batista ³ Data ³ 18.04.11 ³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A_MTA410()
Local aArea		:= GetArea()
Local aAreaSA3	:= SA3->( GetArea() )

SA3->( dbSetOrder(1) )
if SA3->( dbSeek( xFilial("SA3") + M->C5_VEND1 ) )

	M->C5_XREPRES	:= SA3->A3_XREPRES
	M->C5_XEXECUT	:= SA3->A3_XEXECUT
	M->C5_XASSIST	:= SA3->A3_XASSIST
	M->C5_XCANAL	:= SA3->A3_XCANAL

endif

RestArea( aAreaSA3 )
RestArea( aArea )
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ B_MTA410     ³ Por: Adalberto Moreno Batista ³ Data ³ 18.04.11 ³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function B_MTA410()
Local lRet			:= .T.
Local nPosTES		:= aScan( aHeader,{|x| Upper(alltrim(x[2])) == "C6_TES"} )
Local aArea			:= GetArea()
Local aAreaSF4		:= SF4->( GetArea() )
Local nK

if M->C5_CONDPAG = '999'
	//Posicionando o TES
	SF4->( dbSetOrder(1) )
	for nK := 1 to Len(aCols)
	
		if !aCols[nK, Len(aHeader) + 1 ]	//Testando se a linha esta excluida
			SF4->( dbSeek( xFilial("SF4") + aCols[nK,nPosTES] ) )

			if SF4->F4_DUPLIC == 'S'
				lRet := .F.
				if !l410Auto
					MsgBox("A condição de pagamento 999 não poderá ser utilizada com operações que gerem duplicatas. Troque a condicao de pagamento ou o TES utilizado","Atenção","ERRO")
				else
				    ConOut("MTA410 - A condição de pagamento 999 não poderá ser utilizada com operações que gerem duplicatas. Troque a condicao de pagamento ou o TES utilizado")
				endif
				exit
			endif
		endif
		
	next
endif

RestArea(aAreaSF4)
RestArea(aArea)
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ C_MTA410     ³ Por: Ronaldo Gomes			³ Data ³ 06.09.12 ³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C_MTA410()
Local lRet			:= .T.
Local nPosOPER		:= aScan( aHeader,{|x| Upper(alltrim(x[2])) == "C6_XOPER"} )
Local nCODVPC		:= M->C5_CODVPCM
Local nK            := 0

For nK := 1 to Len(aCols)

	if aCols[nK,nposOPER] == '03' .and. empty(nCODVPC)  .and. !aCols[nK, Len(aHeader) + 1 ]	//Testando se a linha esta excluida
		lRet := .F.  
		MsgBox("Pedido de Bonificação, favor informa o tipo da VPC no campo Cod Mens VPC","Atenção")
	endif
	exit

next

Return(lRet)  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ D_MTA410     ³ Por: Adalberto Moreno Batista ³ Data ³ 04.03.13 ³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function D_MTA410(cUserLibVM, cMsgEsp)
Local oDlgVM, oMainWnd, oPass
Local cPswLibVM		:= Space(15)
Local cUserLibVM	:= Space(20)
Local lRet 			:= .F.

If lEspDes == Nil
	Public lEspDes := .F.
Endif

If lEspPrz == Nil
	Public lEspPrz := .F.
Endif

If lEspPar == Nil
	Public lEspPar := .F.
Endif

If lEspDes
	cMsgEsp += "Desconto Especial / "
Endif
	
If lEspPrz
	cMsgEsp += "Prazo Medio / "
Endif
	
If lEspPar
	cMsgEsp += "Numero de Parcelas / "
Endif

Define MsDialog oDlgVM From 200 , 250 To 370 , 535 Title "Aprovação de pedido" Of oMainWnd Pixel
	
@ 0.3 , 0.5 Say "  Pedido necessita de aprovação, pois não está"   Size 30 , 17 Of oDlgVM
@ 0.9 , 0.5 Say "  adequado à política comercial." Size 30 , 17 Of oDlgVM
	
@ 2.0 , 003 Say "Usuário : " Size 30 , 17 Of oDlgVM
@ 2.9 , 003 Say "Senha   : " Size 30 , 17 Of oDlgVM
	
@ 2.0 , 007 MsGet cUserLibVM Of oDlgVM Size 55 , 08
@ 2.9 , 007 MsGet oPass VAR cPswLibVM PassWord Of oDlgVM Size 55 , 08
	
Define SButton From 67 , 40 Type 1 Action {||(If( U_VlPswGama( cUserLibVM , cPswLibVM ) , ( lRet:=.T. , oDlgVM:End() ) , ( lRet:=.F. , oDlgVM:End() ) ) ) } Enable Of oDlgVM
Define SButton From 67 , 80 Type 2 Action {||( lRet :=.F. , oDlgVM:End() ) } Enable Of oDlgVM
Activate MsDialog oDlgVM
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ E_MTA410     ³ Por: Luiz Fernando			³ Data ³ 20.02.17 ³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function E_MTA410()
Local lRet			:= .T.
Local cTPEntrega	:= M->C5_XECTTRA
Local cCartao		:= M->C5_XECTCAR


if empty(cTPEntrega) .or. empty(cCartao)
	lRet := .F.  
		if !l410Auto
			Aviso( "Campo Obrigatorio!" , "Atenção! Informe os campos ECT Entrega e ECT Cart.Pos antes de confirmar a gravação do Pedido!", {"Ok"}, 1, "Transportadora!" )
		else
			ConOut("MTA410 - Informe os campos ECT Entrega(C5_XECTTRA) e ECT Cart.Pos(C5_XECTCAR) antes de confirmar a gravação do Pedido")
		endif		
endif

Return(lRet)  