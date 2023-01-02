#Include "Protheus.ch"
#Include "Rwmake.ch"

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  �  VldPrcVen   � Autor � Cristiano Figueiroa � Data � 08/10/2009  ���
������������������������������������������������������������������������������͹��
���Descricao � Valida se o preco digitado eh maior ou igual ao preco de tabela ���
������������������������������������������������������������������������������͹��
���Uso       � Brasitech ( Gama Italy )                                        ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/

User Function VldPrcVen()

/*����������������������������������������������������������������������������Ŀ
  �              Declara as Variaveis Utilizadas na Rotina                     �
  ������������������������������������������������������������������������������*/

Local nPosPrcVen := aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "C6_PRCVEN" })
Local nPosPrcTab := aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "C6_PRUNIT" })
Local cPosCodPrd := aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "C6_PRODUTO" })
Local nPrcVen  := M->C6_PRCVEN
Local lRetorno   := .T. 


/*����������������������������������������������������������������������������Ŀ
  �              Valida os Precos Informados x Preco de Tabela                 �
  ������������������������������������������������������������������������������*/

If 	M->C5_TIPO == "N" .and. (SM0->M0_CODIGO <> "08" .and. SM0->M0_CODIGO <> "09" .and. SM0->M0_CODIGO <> "11" .and. SM0->M0_CODIGO <> "12" );
	.and. !(M->C5_CLIENTE$('65033573,49728108,58279134'))    
	   
	   		   	
	If nPrcVen < Acols[n][nPosPrcTab]
		if !l410Auto
			Aviso( "Politica Comercial !" , "Nao � permitida a altera��o de pre�os com valores inferiores ao preco de tabela !"  , {"Ok"} , 1 , "Altera��o de Pre�o ! " )
		endif
		lRetorno := .F.
	   	Endif   
	
		If Acols[n][nPosPrcTab] <= 0.AND. !(SUBSTR( Acols[n][cPosCodPrd],1,3) == "SRV")
			if !l410Auto
				Aviso( "Politica Comercial !" , "O produto nao esta cadastrado na tabela de precos ou seu valor na tabela � igual a zero ! Solicite o cadastramento do pre�o do produto na tabela !"  , {"Ok"} , 1 , "Produto sem Pre�o ! " )
			endif
			lRetorno := .F.
	  	Endif	  	   
	
Endif

Return lRetorno