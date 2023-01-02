#Include "Protheus.ch"
#Include "Rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³  VldPrcVen   º Autor ³ Cristiano Figueiroa º Data ³ 08/10/2009  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida se o preco digitado eh maior ou igual ao preco de tabela º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasitech ( Gama Italy )                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function VldPrcVen()

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³              Declara as Variaveis Utilizadas na Rotina                     ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Local nPosPrcVen := aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "C6_PRCVEN" })
Local nPosPrcTab := aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "C6_PRUNIT" })
Local cPosCodPrd := aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "C6_PRODUTO" })
Local nPrcVen  := M->C6_PRCVEN
Local lRetorno   := .T. 


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³              Valida os Precos Informados x Preco de Tabela                 ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

If 	M->C5_TIPO == "N" .and. (SM0->M0_CODIGO <> "08" .and. SM0->M0_CODIGO <> "09" .and. SM0->M0_CODIGO <> "11" .and. SM0->M0_CODIGO <> "12" );
	.and. !(M->C5_CLIENTE$('65033573,49728108,58279134'))    
	   
	   		   	
	If nPrcVen < Acols[n][nPosPrcTab]
		if !l410Auto
			Aviso( "Politica Comercial !" , "Nao é permitida a alteração de preços com valores inferiores ao preco de tabela !"  , {"Ok"} , 1 , "Alteração de Preço ! " )
		endif
		lRetorno := .F.
	   	Endif   
	
		If Acols[n][nPosPrcTab] <= 0.AND. !(SUBSTR( Acols[n][cPosCodPrd],1,3) == "SRV")
			if !l410Auto
				Aviso( "Politica Comercial !" , "O produto nao esta cadastrado na tabela de precos ou seu valor na tabela é igual a zero ! Solicite o cadastramento do preço do produto na tabela !"  , {"Ok"} , 1 , "Produto sem Preço ! " )
			endif
			lRetorno := .F.
	  	Endif	  	   
	
Endif

Return lRetorno