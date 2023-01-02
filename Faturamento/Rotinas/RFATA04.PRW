#Include "Rwmake.ch"
#Include "Protheus.ch"

/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммямммммммммммм╩╠╠
╠╠╨Programa  Ё RFata04  ╨ Autor ЁCristiano Figueiroa ╨ Data Ё 11/03/2009 ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммомммммммммммм╧╠╠
╠╠╨Descricao Ё Abre tela para selecao dos Kit's promocionais a serem     ╨╠╠
╠╠╨          Ё carregados no Pedido de Vendas.                           ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Brasitech                                                 ╨╠╠
╠╠хммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/

User Function RFata04()

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                    Declara as variaveis utilizadas                         Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Local   nOpca 		:= 0
Local   nPosProduto := aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "C6_PRODUTO" })
Private cCodKit	    := Space(06)
Private cTes        := Space(03)
Private nQuantidade := 0
Private nDesconto   := 0
Private oBold
Private oBoldI
Private cDesKit     := Space(60)
Private oDlg1           
Private oDesKit
Private oDesTes
Private cDesTes     := Space(60)
Private cTabela     := M->C5_TABELA

/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё Verifica se o Pedido e do Tipo Normal , Caso Contrario nao se Pode  Ё
  Ё Utilizar a Funcionalidade de Kit Promocional.                       Ё
  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

If M->C5_TIPO <> "N"
   Aviso( "AtenГЦo !" , "A Funcionalidade de Kit somente poderА ser utilizada para Pedidos de Vendas do Tipo Normal !" , {"Ok"} , 1 , "Kit Promocional !" )
   Return 
Endif

/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё Verifica se os dados do Cabecalho foram preenchidos antes da chamadaЁ
  Ё do Kit.                                                             Ё
  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

If Empty( M->C5_CLIENTE ) .Or. Empty( M->C5_LOJACLI )
   Aviso( "AtenГЦo !" , "Informe o Cliente e a Loja do Pedido de Vendas antes de executar a Rotina de Kit Promocional !" , {"Ok"} , 1 , "Cliente nЦo Informado !" )
   Return 
Endif

If Empty( M->C5_TABELA )
   Aviso( "AtenГЦo !" , "Informe a Tabela de Precos antes de executar a Rotina de Kit Promocional !" , {"Ok"} , 1 , "Tabela nЦo Informada !" )
   Return 
Endif

If Empty( M->C5_CONDPAG )
   Aviso( "AtenГЦo !" , "Informe a CondiГЦo de Pagamento antes de executar a Rotina de Kit Promocional !" , {"Ok"} , 1 , "Condicao nЦo Informada !" )
   Return 
Endif

If Empty( M->C5_VEND1 )
   Aviso( "AtenГЦo !" , "Informe o Vendedor antes de executar a Rotina de Kit Promocional !" , {"Ok"} , 1 , "Vendedor nЦo Informado !" )
   Return 
Endif
                       
If Empty ( Acols[n][nPosProduto] ) .And. Len( aCols ) <> 1
   Aviso( "AtenГЦo !" , "Para executar a Rotina do Kit posicione no Зltimo Мtem do Pedido de Vendas !" , {"Ok"} , 1 , "Kit Promocional !" )
   Return
Endif

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                Monta a Tela para selecao do Kit Promocional                Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Define Font oBold  Name  "Arial"  Size 07 , -13 BOLD
Define Font oBoldI Name  "Arial"  Size 06 , -11 BOLD
Define MsDialog oDlg1 From  094 , 001 To 315 , 350 Title "Selecione o Kit Promocional" Pixel

@ 005 , 003 To 038 , 174 Of oDlg1 Pixel
@ 040 , 003 To 090 , 174 Of oDlg1 Pixel

@ 011 , 007 Say "CСdigo do kit : "            Font oBold Pixel COLOR CLR_HBLUE
@ 025 , 007 Say oDesKit Var cDesKit Font oBoldI Pixel COLOR CLR_HBLUE

@ 045 , 007 Say "Quantidade :"      Font oBold Pixel //COLOR CLR_HBLUE
@ 060 , 007 Say "Tes        :"      Font oBold Pixel //COLOR CLR_HBLUE
@ 062 , 090 Say  oDesTes Var cDesTes Font oBoldI Pixel //COLOR CLR_HBLUE
@ 075 , 007 Say "% Desconto :"      Font oBold Pixel //COLOR CLR_HBLUE

@ 010 , 059 MsGet cCodKit F3 "SZ4"                        Size 035 , 010 Of oDLG1 Pixel Valid VldKit( cCodKit )
@ 045 , 059 MsGet nQuantidade Picture "@E 999,999,999.99" Size 060 , 010 Of oDLG1 Pixel Valid nQuantidade <> 0
@ 060 , 059 MsGet cTes    F3 "SF4"                        Size 030 , 010 Of oDLG1 Pixel Valid VldTes( cTes    )
@ 075 , 059 MsGet nDesconto   Picture "@E 99.99"          Size 060 , 010 Of oDLG1 Pixel Valid nDesconto >= 0


/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                Monta a Tela para Receber o Codigo do Rateio                Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Define SButton From 095 , 048 Type 1 Enable Of oDlg1 Action ( nOpca := 1 , Iif( CarregaKit( cCodKit ) , oDlg1:End() ,nOpca := 0) )
Define SButton From 095 , 090 Type 2 Enable Of oDlg1 Action ( oDlg1:End() , nOpca := 0)
			
/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                Monta a Tela para Receber o Codigo do Rateio                Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Activate MsDialog oDlg1 Centered

Return

/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммммммкмммммммяммммммммммммммммммммкммммммямммммммммммм╩╠╠
╠╠╨Programa  Ё    VldKit    ╨ Autor Ё Cristiano Figueiroa╨ Data Ё 16/03/2009 ╨╠╠
╠╠лммммммммммьммммммммммммммймммммммоммммммммммммммммммммйммммммомммммммммммм╧╠╠
╠╠╨Descricao Ё Valida a Existencia do Kit                                    ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Brasitech                                                     ╨╠╠
╠╠хммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/

Static Function VldKit( cCodKit )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё              Declara as Variaveis Locais Utilizadas na Rotina              Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Local l
Local lRet    := .T.
Local aKits   := {}
Local nPosKit := aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "C6_CODKIT"  })

/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                 Processa todos os Itens do Acols                    Ё
  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

For l := 1 to Len(aCols)

 /*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   Ё Verifica se a Linha nao esta Deletada e monta Array com os Kit Informados Ё
   юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

   If !aCols[ l , Len(aHeader) + 1 ]
      If Ascan ( aKits , aCols[l][nPosKit] ) == 0
         Aadd( aKits , aCols[l][nPosKit] )
      Endif   
   Endif

Next l

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                    Verifica se o Kit ja foi Utilizado                      Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

If Ascan ( aKits , cCodKit ) <> 0
   Aviso( "AtenГЦo !" , "O Kit Promocional : " + cCodKit + " jА foi utilizado neste Pedido de Vendas anteriormente ! Apenas um mesmo Kit por Pedido pode ser Informado !" , {"Ok"} , 1 , "Kit jА informado !" )
   lRet := .F.
Endif

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                    Abre a Tabela de Kit Promocional                        Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

DbSelectArea("SZ4")
DbSetOrder(1)

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё        Pesquisa o Codigo informado na Tabela de Kit Promocional            Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

If !DbSeek( xFilial("SZ4") + cCodKit )
   Aviso( "AtenГЦo !" , "O Kit Promocional Informado nЦo existe !" , {"Ok"} , 1 , "Kit nЦo existe !" )
   lRet := .F.
Else

 /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   Ё                   Verifica a Vigencia do Kit Promocional                   Ё
   юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

   If !( SZ4->Z4_INICIO <= dDataBase .And. SZ4->Z4_FIM >= dDataBase )
      Aviso( "AtenГЦo !" , "O Kit Promocional estА fora da Data de Vigencia ! Solicite ao responsАvel a revisЦo da Vigencia do Kit antes de utiliza-lo !" , {"Ok"} , 1 , "Kit fora da VigЙncia !" )
      lRet := .F.
   Endif

   cDesKit := Alltrim( SZ4->Z4_DESCRIC )

Endif

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                       Atualiza as Variaveis da Tela                        Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
     
oDesKit:Refresh() 
oDlg1:Refresh()

Return lRet


/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммммммкмммммммяммммммммммммммммммммкммммммямммммммммммм╩╠╠
╠╠╨Programa  Ё    VldTes    ╨ Autor Ё Cristiano Figueiroa╨ Data Ё 30/03/2009 ╨╠╠
╠╠лммммммммммьммммммммммммммймммммммоммммммммммммммммммммйммммммомммммммммммм╧╠╠
╠╠╨Descricao Ё Valida a Existencia da Tes                                    ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Brasitech                                                     ╨╠╠
╠╠хммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/

Static Function VldTes( cTes )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё              Declara as Variaveis Locais Utilizadas na Rotina              Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Local lRet := .T.

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                  Abre a Tabela de Tipos de Entrada e Saida                 Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

DbSelectArea("SF4")
DbSetOrder(1)

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё        Pesquisa o Codigo informado na Tabela de TES                        Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

If !DbSeek( xFilial("SF4") + cTes )
   Aviso( "AtenГЦo !" , "A Tes informada nЦo existe !" , {"Ok"} , 1 , "Tes nЦo existe !" )
   lRet := .F.
Else

 /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   Ё        Valida se a TES informada e maior que 500 ( Saidas )                Ё
   юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

   If Val ( cTes ) < 500
      Aviso( "AtenГЦo !" , "Informe uma TES maior que '500' !" , {"Ok"} , 1 , "Tes InvАlida !" )
      Return .F.
   Endif

   cDesTes := " - " + Alltrim( SF4->F4_TEXTO )

Endif

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                       Atualiza as Variaveis da Tela                        Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
     
oDesTes:Refresh() 
oDlg1:Refresh()

Return lRet

/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммммммкмммммммяммммммммммммммммммммкммммммямммммммммммм╩╠╠
╠╠╨Programa  Ё  CarregaKit  ╨ Autor Ё Cristiano Figueiroa╨ Data Ё 16/03/2009 ╨╠╠
╠╠лммммммммммьммммммммммммммймммммммоммммммммммммммммммммйммммммомммммммммммм╧╠╠
╠╠╨Descricao Ё Carrega o Kit Promocional de Acordo com o Cadastro            ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Brasitech                                                     ╨╠╠
╠╠хммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/

Static Function CarregaKit ( cCodKit )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё              Declara as Variaveis Locais Utilizadas na Rotina              Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Local lRet       := .T.
Local aPedido    := {}
Local nVlrTotKit := 0
Local cCodProd   := ""
Local cDesProd   := ""
Local cLocProd   := ""
Local cUniProd   := ""
Local nQtdProd   := 0
Local nPrcProd   := 0
Local nTotProd   := 0
Local cSegum     := ""  	
//Local cCodKit    := ""
Local cDesKit    := ""
Local cClasFis   := ""
Local nConta

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё        Verifica se os campos Obrigatorios da Tela Foram Preenchidos        Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

If Empty( cTes )
   Aviso( "AtenГЦo !" , "Informe o CСdigo da TES a ser gravada no Pedido !" , {"Ok"} , 1 , "Tes nЦo Informada !" )
   Return .F.
Endif

If Empty( nQuantidade )
   Aviso( "AtenГЦo !" , "Informe a Quantidade do Kit Promocional !" , {"Ok"} , 1 , "Quantidade nЦo Informada !" )
   Return .F.
Endif

/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё           Chama a Funcao que Valida o Desconto Aplicado             Ё
  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

lRet := u_VerDesCon( M->C5_CLIENTE , M->C5_CONDPAG , nDesconto )

/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё       Caso o Desconto nao seja Valido , Bloqueia a Continuidade     Ё
  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

If !lRet 
   Return lRet
Endif

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                    Abre a Tabela de Kit Promocional                        Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

DbSelectArea("SZ4")
DbSetOrder(1)

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё        Pesquisa o Codigo informado na Tabela de Kit Promocional            Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

If DbSeek( xFilial("SZ4") + cCodKit )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё       Fator a ser Considerado na Multiplicacao dos Itens Bonificados       Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

   nFator := ( nQuantidade / SZ4->Z4_QTDPVEN )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё  Verifica se a Quantidade Vendida Atinge o Minimo para Bonificar os Itens  Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

   If nQuantidade < SZ4->Z4_QTDPVEN
      Aviso( "AtenГЦo !" , "A Quantidade informada nЦo atingiu o mМnimo necessАrio para que o Kit Promocional seja carregado ! Quantidade MМnima do Kit : " + Transform( SZ4->Z4_QTDPVEN , "@E 999,999,999.99" ) , {"Ok"} , 1 , "Quantidade MМnima do Kit !" )
      Return .F.
   Endif

   
/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                Processa o Item Principal da Promocao                       Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
  
   cCodProd := SZ4->Z4_CODPVEN
   cDesProd := Alltrim( Posicione( "SB1" , 1 , xFilial("SB1") + SZ4->Z4_CODPVEN , "B1_DESC"   ) )
   cLocProd := Alltrim( Posicione( "SB1" , 1 , xFilial("SB1") + SZ4->Z4_CODPVEN , "B1_LOCPAD" ) )
   cUniProd := Alltrim( Posicione( "SB1" , 1 , xFilial("SB1") + SZ4->Z4_CODPVEN , "B1_UM"     ) )
   nQtdProd := nQuantidade
   nPrcProd := RetPrcTab ( cTabela , SZ4->Z4_CODPVEN )
   nTotProd := Round( nQuantidade * nPrcProd , 2 )
   cSegum   := ""  	
   cClasFis  := Alltrim( Posicione( "SB1" , 1 , xFilial("SB1") + SZ4->Z4_CODPVEN , "B1_ORIGEM"   ) ) + Alltrim( Posicione( "SF4" , 1 , xFilial("SF4") + cTes , "F4_SITTRIB"   ) )
   cCodKit  := SZ4->Z4_CODIGO
   cDesKit  := Alltrim( SZ4->Z4_DESCRIC )  

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                Armazena o Valor Total do Kit Promocional                   Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

   nVlrTotKit += nTotProd
   
/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё             Adiciona no Array Temporario de Itens do Pedido                Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
   
   aAdd ( aPedido , { cCodProd , cDesProd , cLocProd , cUniProd , nQtdProd , nPrcProd , nTotProd , cSegum , cTes , cCodKit , cDesKit , 0 , 0 , 0 } )
   
   
/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                Processa todos os Itens do Kit Promocional                  Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

   Do While SZ4->( !Eof() ) .And. cCodKit == SZ4->Z4_CODIGO

      cCodProd := SZ4->Z4_CODPBON
      cDesProd := Alltrim( Posicione( "SB1" , 1 , xFilial("SB1") + SZ4->Z4_CODPBON , "B1_DESC"   ) )
      cLocProd := Alltrim( Posicione( "SB1" , 1 , xFilial("SB1") + SZ4->Z4_CODPBON , "B1_LOCPAD" ) )
      cUniProd := Alltrim( Posicione( "SB1" , 1 , xFilial("SB1") + SZ4->Z4_CODPBON , "B1_UM"     ) )
      nQtdProd := SZ4->Z4_QTDPBON * nFator
      nPrcProd := RetPrcTab ( cTabela , SZ4->Z4_CODPBON )
      nTotProd := Round ( nQtdProd * nPrcProd , 2 )
      cSegum   := ""
      cClasFis  := Alltrim( Posicione( "SB1" , 1 , xFilial("SB1") + SZ4->Z4_CODPVEN , "B1_ORIGEM"   ) ) + Alltrim( Posicione( "SF4" , 1 , xFilial("SF4") + cTes , "F4_SITTRIB"   ) )
      cCodKit  := SZ4->Z4_CODIGO
      cDesKit  := Alltrim( SZ4->Z4_DESCRIC )   
      
   /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
     Ё                Armazena o Valor Total do Kit Promocional                   Ё
     юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

      nVlrTotKit += nTotProd

   /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
     Ё             Adiciona no Array Temporario de Itens do Pedido                Ё
     юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

      aAdd ( aPedido , { cCodProd , cDesProd , cLocProd , cUniProd , Int( nQtdProd ) , nPrcProd , nTotProd , cSegum , cTes , cCodKit , cDesKit , 0 , 0 , 0 } )

   /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
     Ё                        Processa o Proximo Registro                         Ё
     юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
   
      DbSkip()
      Loop
           
   Enddo
   
Else
   Aviso( "AtenГЦo !" , "O Kit Promocional Informado nЦo existe !" , {"Ok"} , 1 , "Kit nЦo existe !" )
   Return
Endif

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё           Proporcao do Preco em Relacao ao Valor Total do Kit              Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

For nConta := 1 to Len ( aPedido )
   aPedido[nConta][12] := aPedido[nConta][7]  / nVlrTotKit                        // Proporcao do Kit ( Total do Produto / Valor Total dos Produtos do Kit )
   aPedido[nConta][13] := aPedido[nConta][12] * aPedido[1][7]                    // Proporcao sobre a Venda ( Proporcao do Kit * Preco Total do Produto de Venda )
   aPedido[nConta][14] := Round ( aPedido[nConta][13] / aPedido[nConta][5] , 2 ) // Preco Final ( Proporcao sobre a Venda / Quantidade )
   aPedido[nConta][13] := aPedido[nConta][14] * aPedido[nConta][5]               // Reacalculo do Preco Tota;
Next nConta

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё          Chama a Funcao que Monta o Acola de Acordo com o Pedido           Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
   
LoadAcols( aPedido )

Return lRet

/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммммммкмммммммяммммммммммммммммммммкммммммямммммммммммм╩╠╠
╠╠╨Programa  Ё  LoadAcols   ╨ Autor Ё Cristiano Figueiroa╨ Data Ё 26/03/2009 ╨╠╠
╠╠лммммммммммьммммммммммммммймммммммоммммммммммммммммммммйммммммомммммммммммм╧╠╠
╠╠╨Descricao Ё Carrega o Acola de Acordo com o Pedido                        ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Brasitech                                                     ╨╠╠
╠╠хммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/

Static Function LoadAcols ( aPedido )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё              Declara as Variaveis Utilizadas na Rotina                     Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Local nPosItem      := aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "C6_ITEM"    })
Local nPosProduto   := aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "C6_PRODUTO" })
Local nPosDescri    := aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "C6_DESCRI"  })
Local nPosLocal     := aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "C6_LOCAL"   })
Local nPosUM        := aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "C6_UM"      })
Local nPosQtdVen    := aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "C6_QTDVEN"  })
Local nPosPrcVen    := aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "C6_PRCVEN"  })
Local nPosValor     := aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "C6_VALOR"   })
Local nPosDescont   := aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "C6_DESCONT" })
Local nPosValDesc   := aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "C6_VALDESC" })
Local nPosTes       := aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "C6_TES"     })
Local nPosCf        := aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "C6_CF"      })
Local nPosEntreg    := aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "C6_ENTREG"  })
Local nPosPrunit    := aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "C6_PRUNIT"  })
Local nPosComis1    := aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "C6_COMIS1"  })  
Local nPosClasFis   := aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "C6_CLASFIS" })  
Local nPosCodKit    := aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "C6_CODKIT"  })  
Local nPosDesKit    := aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "C6_DESKIT"  })  
Local nCount        := 0
Local nUsado        := Len( aHeader )
Local nLinhas       := Len( Acols   )
Local nValDesc      := 0
Local nValUni       := 0
Local nValDesc      := 0
Local nValTot       := 0
Local aAglPedido    := {}
Local nItPv         := ""
Local k, nCount, x

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё              Aglutina os Itens Iguais do Array de Itens                    Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

For k:= 1 to Len ( aPedido )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё              Verifica a Localizacao do Produto no Array                    Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

   nLocProd := aScan( aAglPedido , {|x| ( x[1] ) == aPedido[k][1] } )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё              Aglutina os Itens Iguais do Array de Itens                    Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

   If nLocProd <> 0

    /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      Ё                  Recalcula os Valores Dos Itens Iguais                     Ё
      юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

      aAglPedido[ nLocProd , 5 ] += aPedido[ k , 5 ]
      aAglPedido[ nLocProd , 13] := aAglPedido[ nLocProd , 5 ] * aPedido[ k , 14]

   Else
      Aadd ( aAglPedido , aPedido[k] )
   Endif
   

Next k


aPedido := aAglPedido
 
/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё          Processa todo o Array com os Itens do Kit do Pedido               Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

For nCount := 1 to Len ( aPedido )

/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё  Verifica se o Acols tem Apenas uma Linha e se a mesms esta em Branco Ё
  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

   If Empty( aCols[nLinhas][nPosProduto] )
      aCols[nLinhas][nUsado + 1 ] := .T.
   Endif
   
/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё               Soma 1 ao Item do Pedido                       Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

   nItPv  := Soma1( aCols [ Len( aCols ) ] [ nPosItem ] )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё               Adiciona uma Linha no Acols                    Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
   
   Aadd( aCols , Array( nUsado + 1 ) )                 

   nLinhas ++
   n ++

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё              Posiciona na Linha Adicionada                   Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

   n := nLinhas
         
/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё               Adiciona uma Linha no Acols                    Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

   For x := 1 to nUsado
   
   /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
     Ё               Trata os Campos nao Virtuais                   Ё
     юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
   
      If aHeader[x][10] <> "V"
         aCols[ Len( aCols ) , x ] :=  CriaVar( aHeader [ x , 2 ] , .T. )
      Else
         
      /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
        Ё                  Trata os Campos Virtuais                    Ё
        юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

         If aHeader[x][2] == "C6_ALI_WT"
            aCols[ Len( aCols ) , x ]  :=  "SC6"
         Endif   

         If aHeader[x][2] == "C6_REC_WT" 
            aCols[ Len( aCols ) , x ]  :=  0
         Endif                        

      Endif   

    /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      Ё                Deixa a Linha Ativa do Acols                  Ё
      юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
         
      aCols[ Len( aCols ) , nUsado + 1] := .F.      
   
   Next x


/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё               Aplica os Descontos nos Precos                 Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

   If nDesconto > 0
      nValDesc := aPedido [nCount][14] * ( nDesconto / 100 ) 
      nValUni  := Round( aPedido [nCount][14] - nValDesc, 2 )
      nValDesc := Round( nValDesc * aPedido [nCount][5] , 2 )
      nValTot  := Round( nValUni  * aPedido [nCount][5] , 2 )
   Else
      nValDesc := 0
      nValUni  := aPedido [nCount][14]
      nValTot  := aPedido [nCount][13]
   Endif   
  
/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё               Atribui as Linhas do Acols                     Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

   aCols[nLinhas][nPosItem   ] 	:= StrZero( Val( nItPv ) , 2 )
   aCols[nLinhas][nPosProduto] 	:= aPedido [nCount][1]
   aCols[nLinhas][nPosDescri ] 	:= aPedido [nCount][2]
   aCols[nLinhas][nPosLocal  ] 	:= aPedido [nCount][3]
   aCols[nLinhas][nPosUM     ] 	:= aPedido [nCount][4]
   aCols[nLinhas][nPosQtdVen ] 	:= aPedido [nCount][5]
   aCols[nLinhas][nPosPrcVen ] 	:= nValUni  //aPedido [nCount][14]
   aCols[nLinhas][nPosValor  ] 	:= nValTot  // aPedido [nCount][13]
   aCols[nLinhas][nPosTes    ] 	:= aPedido [nCount][9]
   aCols[nLinhas][nPosDescont] 	:= nDesconto
   aCols[nLinhas][nPosValDesc] 	:= nValDesc
   aCols[nLinhas][nPosComis1 ] 	:= u_RetPerCom( M->C5_CLIENTE , M->C5_LOJACLI , M->C5_VEND1 , aPedido [nCount][1] )
   aCols[nLinhas][nPosPrUnit ] 	:= aPedido [nCount][14]
   aCols[nLinhas][nPosClasFis] 	:= Substring( SB1->B1_ORIGEM , 1 , 1 ) + SF4->F4_SITTRIB
   aCols[nLinhas][nPosCodKit ] 	:= aPedido [nCount][10]
   aCols[nLinhas][nPosDesKit ] 	:= aPedido [nCount][11]
   aCols[nLinhas][nUsado + 1 ] := .F.

   A410MultT( "M->C6_PRODUTO" , aPedido [nCount][1] , )
   A410MultT( "M->C6_TES"     , aPedido [nCount][9] , )
   A410MultT( "M->C6_QTDVEN"  , aPedido [nCount][5] , )

Next nCount

Return	

/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммммммкмммммммяммммммммммммммммммммкммммммямммммммммммм╩╠╠
╠╠╨Programa  Ё  RetPrcTab   ╨ Autor Ё Cristiano Figueiroa╨ Data Ё 24/03/2009 ╨╠╠
╠╠лммммммммммьммммммммммммммймммммммоммммммммммммммммммммйммммммомммммммммммм╧╠╠
╠╠╨Descricao Ё Retorna o Preco de Tabela do Produto                          ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Brasitech                                                     ╨╠╠
╠╠хммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/

Static Function RetPrcTab ( cTabela , cProduto )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё              Declara as Variaveis Locais Utilizadas na Rotina              Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Local nPrecoRet := 0
Local aArea     := GetArea()

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                  Verifica o Preco de Venda do Produto                      Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

DbSelectArea("DA1")
DbSetOrder(1)

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                  Verifica o Preco de Venda do Produto                      Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

If DbSeek( xFilial("DA1") + cTabela + cProduto )
   nPrecoRet := DA1->DA1_PRCVEN
Else
   Aviso( "AtenГЦo !" , "O Produto " + Alltrim( Posicione( "SB1" , 1 , xFilial("SB1") + cProduto , "B1_DESC"   ) ) + " nЦo estА na Tabela de PreГos " + cTabela + " !" , {"Ok"} , 1 , "Produto sem PreГo !" )
Endif		

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                  Restaura o Ambiente Antes da Utilizacao                   Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

RestArea( aArea )

Return nPrecoRet

/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммммммкмммммммяммммммммммммммммммммкммммммямммммммммммм╩╠╠
╠╠╨Programa  Ё  EdtLinKit   ╨ Autor Ё Cristiano Figueiroa╨ Data Ё 01/04/2009 ╨╠╠
╠╠лммммммммммьммммммммммммммймммммммоммммммммммммммммммммйммммммомммммммммммм╧╠╠
╠╠╨Descricao Ё Bloqueia a Edicao do Campo caso seja um Produto de Kit        ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Brasitech                                                     ╨╠╠
╠╠хммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/

User Function EdiLinKit

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё              Declara as Variaveis Locais Utilizadas na Rotina              Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Local nPosKit := aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "C6_CODKIT"  })
Local cCodKitL := aCols[ n ][nPosKit ]
Local lRet    := .F.

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё              Verifica se a Linha se Refere a um Kit                        Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

If Empty ( Alltrim(  cCodKitL )  )
   lRet := .T.
Endif

Return lRet