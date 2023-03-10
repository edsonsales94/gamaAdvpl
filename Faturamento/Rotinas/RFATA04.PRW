#Include "Rwmake.ch"
#Include "Protheus.ch"

/*
????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????ͻ??
???Programa  ? RFata04  ? Autor ?Cristiano Figueiroa ? Data ? 11/03/2009 ???
????????????????????????????????????????????????????????????????????????͹??
???Descricao ? Abre tela para selecao dos Kit's promocionais a serem     ???
???          ? carregados no Pedido de Vendas.                           ???
????????????????????????????????????????????????????????????????????????͹??
???Uso       ? Brasitech                                                 ???
????????????????????????????????????????????????????????????????????????ͼ??
????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????
*/

User Function RFata04()

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                    Declara as variaveis utilizadas                         ?
  ??????????????????????????????????????????????????????????????????????????????*/

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

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Verifica se o Pedido e do Tipo Normal , Caso Contrario nao se Pode  ?
  ? Utilizar a Funcionalidade de Kit Promocional.                       ?
  ???????????????????????????????????????????????????????????????????????*/

If M->C5_TIPO <> "N"
   Aviso( "Aten??o !" , "A Funcionalidade de Kit somente poder? ser utilizada para Pedidos de Vendas do Tipo Normal !" , {"Ok"} , 1 , "Kit Promocional !" )
   Return 
Endif

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Verifica se os dados do Cabecalho foram preenchidos antes da chamada?
  ? do Kit.                                                             ?
  ???????????????????????????????????????????????????????????????????????*/

If Empty( M->C5_CLIENTE ) .Or. Empty( M->C5_LOJACLI )
   Aviso( "Aten??o !" , "Informe o Cliente e a Loja do Pedido de Vendas antes de executar a Rotina de Kit Promocional !" , {"Ok"} , 1 , "Cliente n?o Informado !" )
   Return 
Endif

If Empty( M->C5_TABELA )
   Aviso( "Aten??o !" , "Informe a Tabela de Precos antes de executar a Rotina de Kit Promocional !" , {"Ok"} , 1 , "Tabela n?o Informada !" )
   Return 
Endif

If Empty( M->C5_CONDPAG )
   Aviso( "Aten??o !" , "Informe a Condi??o de Pagamento antes de executar a Rotina de Kit Promocional !" , {"Ok"} , 1 , "Condicao n?o Informada !" )
   Return 
Endif

If Empty( M->C5_VEND1 )
   Aviso( "Aten??o !" , "Informe o Vendedor antes de executar a Rotina de Kit Promocional !" , {"Ok"} , 1 , "Vendedor n?o Informado !" )
   Return 
Endif
                       
If Empty ( Acols[n][nPosProduto] ) .And. Len( aCols ) <> 1
   Aviso( "Aten??o !" , "Para executar a Rotina do Kit posicione no ?ltimo ?tem do Pedido de Vendas !" , {"Ok"} , 1 , "Kit Promocional !" )
   Return
Endif

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                Monta a Tela para selecao do Kit Promocional                ?
  ??????????????????????????????????????????????????????????????????????????????*/

Define Font oBold  Name  "Arial"  Size 07 , -13 BOLD
Define Font oBoldI Name  "Arial"  Size 06 , -11 BOLD
Define MsDialog oDlg1 From  094 , 001 To 315 , 350 Title "Selecione o Kit Promocional" Pixel

@ 005 , 003 To 038 , 174 Of oDlg1 Pixel
@ 040 , 003 To 090 , 174 Of oDlg1 Pixel

@ 011 , 007 Say "C?digo do kit : "            Font oBold Pixel COLOR CLR_HBLUE
@ 025 , 007 Say oDesKit Var cDesKit Font oBoldI Pixel COLOR CLR_HBLUE

@ 045 , 007 Say "Quantidade :"      Font oBold Pixel //COLOR CLR_HBLUE
@ 060 , 007 Say "Tes        :"      Font oBold Pixel //COLOR CLR_HBLUE
@ 062 , 090 Say  oDesTes Var cDesTes Font oBoldI Pixel //COLOR CLR_HBLUE
@ 075 , 007 Say "% Desconto :"      Font oBold Pixel //COLOR CLR_HBLUE

@ 010 , 059 MsGet cCodKit F3 "SZ4"                        Size 035 , 010 Of oDLG1 Pixel Valid VldKit( cCodKit )
@ 045 , 059 MsGet nQuantidade Picture "@E 999,999,999.99" Size 060 , 010 Of oDLG1 Pixel Valid nQuantidade <> 0
@ 060 , 059 MsGet cTes    F3 "SF4"                        Size 030 , 010 Of oDLG1 Pixel Valid VldTes( cTes    )
@ 075 , 059 MsGet nDesconto   Picture "@E 99.99"          Size 060 , 010 Of oDLG1 Pixel Valid nDesconto >= 0


/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                Monta a Tela para Receber o Codigo do Rateio                ?
  ??????????????????????????????????????????????????????????????????????????????*/

Define SButton From 095 , 048 Type 1 Enable Of oDlg1 Action ( nOpca := 1 , Iif( CarregaKit( cCodKit ) , oDlg1:End() ,nOpca := 0) )
Define SButton From 095 , 090 Type 2 Enable Of oDlg1 Action ( oDlg1:End() , nOpca := 0)
			
/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                Monta a Tela para Receber o Codigo do Rateio                ?
  ??????????????????????????????????????????????????????????????????????????????*/

Activate MsDialog oDlg1 Centered

Return

/*
????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????ͻ??
???Programa  ?    VldKit    ? Autor ? Cristiano Figueiroa? Data ? 16/03/2009 ???
????????????????????????????????????????????????????????????????????????????͹??
???Descricao ? Valida a Existencia do Kit                                    ???
????????????????????????????????????????????????????????????????????????????͹??
???Uso       ? Brasitech                                                     ???
????????????????????????????????????????????????????????????????????????????ͼ??
????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????????
*/

Static Function VldKit( cCodKit )

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?              Declara as Variaveis Locais Utilizadas na Rotina              ?
  ??????????????????????????????????????????????????????????????????????????????*/
Local l
Local lRet    := .T.
Local aKits   := {}
Local nPosKit := aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "C6_CODKIT"  })

/*?????????????????????????????????????????????????????????????????????Ŀ
  ?                 Processa todos os Itens do Acols                    ?
  ???????????????????????????????????????????????????????????????????????*/

For l := 1 to Len(aCols)

 /*???????????????????????????????????????????????????????????????????????????Ŀ
   ? Verifica se a Linha nao esta Deletada e monta Array com os Kit Informados ?
   ?????????????????????????????????????????????????????????????????????????????*/

   If !aCols[ l , Len(aHeader) + 1 ]
      If Ascan ( aKits , aCols[l][nPosKit] ) == 0
         Aadd( aKits , aCols[l][nPosKit] )
      Endif   
   Endif

Next l

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                    Verifica se o Kit ja foi Utilizado                      ?
  ??????????????????????????????????????????????????????????????????????????????*/

If Ascan ( aKits , cCodKit ) <> 0
   Aviso( "Aten??o !" , "O Kit Promocional : " + cCodKit + " j? foi utilizado neste Pedido de Vendas anteriormente ! Apenas um mesmo Kit por Pedido pode ser Informado !" , {"Ok"} , 1 , "Kit j? informado !" )
   lRet := .F.
Endif

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                    Abre a Tabela de Kit Promocional                        ?
  ??????????????????????????????????????????????????????????????????????????????*/

DbSelectArea("SZ4")
DbSetOrder(1)

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?        Pesquisa o Codigo informado na Tabela de Kit Promocional            ?
  ??????????????????????????????????????????????????????????????????????????????*/

If !DbSeek( xFilial("SZ4") + cCodKit )
   Aviso( "Aten??o !" , "O Kit Promocional Informado n?o existe !" , {"Ok"} , 1 , "Kit n?o existe !" )
   lRet := .F.
Else

 /*????????????????????????????????????????????????????????????????????????????Ŀ
   ?                   Verifica a Vigencia do Kit Promocional                   ?
   ??????????????????????????????????????????????????????????????????????????????*/

   If !( SZ4->Z4_INICIO <= dDataBase .And. SZ4->Z4_FIM >= dDataBase )
      Aviso( "Aten??o !" , "O Kit Promocional est? fora da Data de Vigencia ! Solicite ao respons?vel a revis?o da Vigencia do Kit antes de utiliza-lo !" , {"Ok"} , 1 , "Kit fora da Vig?ncia !" )
      lRet := .F.
   Endif

   cDesKit := Alltrim( SZ4->Z4_DESCRIC )

Endif

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                       Atualiza as Variaveis da Tela                        ?
  ??????????????????????????????????????????????????????????????????????????????*/
     
oDesKit:Refresh() 
oDlg1:Refresh()

Return lRet


/*
????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????ͻ??
???Programa  ?    VldTes    ? Autor ? Cristiano Figueiroa? Data ? 30/03/2009 ???
????????????????????????????????????????????????????????????????????????????͹??
???Descricao ? Valida a Existencia da Tes                                    ???
????????????????????????????????????????????????????????????????????????????͹??
???Uso       ? Brasitech                                                     ???
????????????????????????????????????????????????????????????????????????????ͼ??
????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????????
*/

Static Function VldTes( cTes )

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?              Declara as Variaveis Locais Utilizadas na Rotina              ?
  ??????????????????????????????????????????????????????????????????????????????*/

Local lRet := .T.

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                  Abre a Tabela de Tipos de Entrada e Saida                 ?
  ??????????????????????????????????????????????????????????????????????????????*/

DbSelectArea("SF4")
DbSetOrder(1)

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?        Pesquisa o Codigo informado na Tabela de TES                        ?
  ??????????????????????????????????????????????????????????????????????????????*/

If !DbSeek( xFilial("SF4") + cTes )
   Aviso( "Aten??o !" , "A Tes informada n?o existe !" , {"Ok"} , 1 , "Tes n?o existe !" )
   lRet := .F.
Else

 /*????????????????????????????????????????????????????????????????????????????Ŀ
   ?        Valida se a TES informada e maior que 500 ( Saidas )                ?
   ??????????????????????????????????????????????????????????????????????????????*/

   If Val ( cTes ) < 500
      Aviso( "Aten??o !" , "Informe uma TES maior que '500' !" , {"Ok"} , 1 , "Tes Inv?lida !" )
      Return .F.
   Endif

   cDesTes := " - " + Alltrim( SF4->F4_TEXTO )

Endif

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                       Atualiza as Variaveis da Tela                        ?
  ??????????????????????????????????????????????????????????????????????????????*/
     
oDesTes:Refresh() 
oDlg1:Refresh()

Return lRet

/*
????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????ͻ??
???Programa  ?  CarregaKit  ? Autor ? Cristiano Figueiroa? Data ? 16/03/2009 ???
????????????????????????????????????????????????????????????????????????????͹??
???Descricao ? Carrega o Kit Promocional de Acordo com o Cadastro            ???
????????????????????????????????????????????????????????????????????????????͹??
???Uso       ? Brasitech                                                     ???
????????????????????????????????????????????????????????????????????????????ͼ??
????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????????
*/

Static Function CarregaKit ( cCodKit )

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?              Declara as Variaveis Locais Utilizadas na Rotina              ?
  ??????????????????????????????????????????????????????????????????????????????*/

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

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?        Verifica se os campos Obrigatorios da Tela Foram Preenchidos        ?
  ??????????????????????????????????????????????????????????????????????????????*/

If Empty( cTes )
   Aviso( "Aten??o !" , "Informe o C?digo da TES a ser gravada no Pedido !" , {"Ok"} , 1 , "Tes n?o Informada !" )
   Return .F.
Endif

If Empty( nQuantidade )
   Aviso( "Aten??o !" , "Informe a Quantidade do Kit Promocional !" , {"Ok"} , 1 , "Quantidade n?o Informada !" )
   Return .F.
Endif

/*?????????????????????????????????????????????????????????????????????Ŀ
  ?           Chama a Funcao que Valida o Desconto Aplicado             ?
  ???????????????????????????????????????????????????????????????????????*/

lRet := u_VerDesCon( M->C5_CLIENTE , M->C5_CONDPAG , nDesconto )

/*?????????????????????????????????????????????????????????????????????Ŀ
  ?       Caso o Desconto nao seja Valido , Bloqueia a Continuidade     ?
  ???????????????????????????????????????????????????????????????????????*/

If !lRet 
   Return lRet
Endif

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                    Abre a Tabela de Kit Promocional                        ?
  ??????????????????????????????????????????????????????????????????????????????*/

DbSelectArea("SZ4")
DbSetOrder(1)

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?        Pesquisa o Codigo informado na Tabela de Kit Promocional            ?
  ??????????????????????????????????????????????????????????????????????????????*/

If DbSeek( xFilial("SZ4") + cCodKit )

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?       Fator a ser Considerado na Multiplicacao dos Itens Bonificados       ?
  ??????????????????????????????????????????????????????????????????????????????*/

   nFator := ( nQuantidade / SZ4->Z4_QTDPVEN )

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?  Verifica se a Quantidade Vendida Atinge o Minimo para Bonificar os Itens  ?
  ??????????????????????????????????????????????????????????????????????????????*/

   If nQuantidade < SZ4->Z4_QTDPVEN
      Aviso( "Aten??o !" , "A Quantidade informada n?o atingiu o m?nimo necess?rio para que o Kit Promocional seja carregado ! Quantidade M?nima do Kit : " + Transform( SZ4->Z4_QTDPVEN , "@E 999,999,999.99" ) , {"Ok"} , 1 , "Quantidade M?nima do Kit !" )
      Return .F.
   Endif

   
/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                Processa o Item Principal da Promocao                       ?
  ??????????????????????????????????????????????????????????????????????????????*/
  
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

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                Armazena o Valor Total do Kit Promocional                   ?
  ??????????????????????????????????????????????????????????????????????????????*/

   nVlrTotKit += nTotProd
   
/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?             Adiciona no Array Temporario de Itens do Pedido                ?
  ??????????????????????????????????????????????????????????????????????????????*/
   
   aAdd ( aPedido , { cCodProd , cDesProd , cLocProd , cUniProd , nQtdProd , nPrcProd , nTotProd , cSegum , cTes , cCodKit , cDesKit , 0 , 0 , 0 } )
   
   
/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                Processa todos os Itens do Kit Promocional                  ?
  ??????????????????????????????????????????????????????????????????????????????*/

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
      
   /*????????????????????????????????????????????????????????????????????????????Ŀ
     ?                Armazena o Valor Total do Kit Promocional                   ?
     ??????????????????????????????????????????????????????????????????????????????*/

      nVlrTotKit += nTotProd

   /*????????????????????????????????????????????????????????????????????????????Ŀ
     ?             Adiciona no Array Temporario de Itens do Pedido                ?
     ??????????????????????????????????????????????????????????????????????????????*/

      aAdd ( aPedido , { cCodProd , cDesProd , cLocProd , cUniProd , Int( nQtdProd ) , nPrcProd , nTotProd , cSegum , cTes , cCodKit , cDesKit , 0 , 0 , 0 } )

   /*????????????????????????????????????????????????????????????????????????????Ŀ
     ?                        Processa o Proximo Registro                         ?
     ??????????????????????????????????????????????????????????????????????????????*/
   
      DbSkip()
      Loop
           
   Enddo
   
Else
   Aviso( "Aten??o !" , "O Kit Promocional Informado n?o existe !" , {"Ok"} , 1 , "Kit n?o existe !" )
   Return
Endif

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?           Proporcao do Preco em Relacao ao Valor Total do Kit              ?
  ??????????????????????????????????????????????????????????????????????????????*/

For nConta := 1 to Len ( aPedido )
   aPedido[nConta][12] := aPedido[nConta][7]  / nVlrTotKit                        // Proporcao do Kit ( Total do Produto / Valor Total dos Produtos do Kit )
   aPedido[nConta][13] := aPedido[nConta][12] * aPedido[1][7]                    // Proporcao sobre a Venda ( Proporcao do Kit * Preco Total do Produto de Venda )
   aPedido[nConta][14] := Round ( aPedido[nConta][13] / aPedido[nConta][5] , 2 ) // Preco Final ( Proporcao sobre a Venda / Quantidade )
   aPedido[nConta][13] := aPedido[nConta][14] * aPedido[nConta][5]               // Reacalculo do Preco Tota;
Next nConta

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?          Chama a Funcao que Monta o Acola de Acordo com o Pedido           ?
  ??????????????????????????????????????????????????????????????????????????????*/
   
LoadAcols( aPedido )

Return lRet

/*
????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????ͻ??
???Programa  ?  LoadAcols   ? Autor ? Cristiano Figueiroa? Data ? 26/03/2009 ???
????????????????????????????????????????????????????????????????????????????͹??
???Descricao ? Carrega o Acola de Acordo com o Pedido                        ???
????????????????????????????????????????????????????????????????????????????͹??
???Uso       ? Brasitech                                                     ???
????????????????????????????????????????????????????????????????????????????ͼ??
????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????????
*/

Static Function LoadAcols ( aPedido )

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?              Declara as Variaveis Utilizadas na Rotina                     ?
  ??????????????????????????????????????????????????????????????????????????????*/

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

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?              Aglutina os Itens Iguais do Array de Itens                    ?
  ??????????????????????????????????????????????????????????????????????????????*/

For k:= 1 to Len ( aPedido )

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?              Verifica a Localizacao do Produto no Array                    ?
  ??????????????????????????????????????????????????????????????????????????????*/

   nLocProd := aScan( aAglPedido , {|x| ( x[1] ) == aPedido[k][1] } )

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?              Aglutina os Itens Iguais do Array de Itens                    ?
  ??????????????????????????????????????????????????????????????????????????????*/

   If nLocProd <> 0

    /*????????????????????????????????????????????????????????????????????????????Ŀ
      ?                  Recalcula os Valores Dos Itens Iguais                     ?
      ??????????????????????????????????????????????????????????????????????????????*/

      aAglPedido[ nLocProd , 5 ] += aPedido[ k , 5 ]
      aAglPedido[ nLocProd , 13] := aAglPedido[ nLocProd , 5 ] * aPedido[ k , 14]

   Else
      Aadd ( aAglPedido , aPedido[k] )
   Endif
   

Next k


aPedido := aAglPedido
 
/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?          Processa todo o Array com os Itens do Kit do Pedido               ?
  ??????????????????????????????????????????????????????????????????????????????*/

For nCount := 1 to Len ( aPedido )

/*???????????????????????????????????????????????????????????????????????Ŀ
  ?  Verifica se o Acols tem Apenas uma Linha e se a mesms esta em Branco ?
  ?????????????????????????????????????????????????????????????????????????*/

   If Empty( aCols[nLinhas][nPosProduto] )
      aCols[nLinhas][nUsado + 1 ] := .T.
   Endif
   
/*??????????????????????????????????????????????????????????????Ŀ
  ?               Soma 1 ao Item do Pedido                       ?
  ????????????????????????????????????????????????????????????????*/

   nItPv  := Soma1( aCols [ Len( aCols ) ] [ nPosItem ] )

/*??????????????????????????????????????????????????????????????Ŀ
  ?               Adiciona uma Linha no Acols                    ?
  ????????????????????????????????????????????????????????????????*/
   
   Aadd( aCols , Array( nUsado + 1 ) )                 

   nLinhas ++
   n ++

/*??????????????????????????????????????????????????????????????Ŀ
  ?              Posiciona na Linha Adicionada                   ?
  ????????????????????????????????????????????????????????????????*/

   n := nLinhas
         
/*??????????????????????????????????????????????????????????????Ŀ
  ?               Adiciona uma Linha no Acols                    ?
  ????????????????????????????????????????????????????????????????*/

   For x := 1 to nUsado
   
   /*??????????????????????????????????????????????????????????????Ŀ
     ?               Trata os Campos nao Virtuais                   ?
     ????????????????????????????????????????????????????????????????*/
   
      If aHeader[x][10] <> "V"
         aCols[ Len( aCols ) , x ] :=  CriaVar( aHeader [ x , 2 ] , .T. )
      Else
         
      /*??????????????????????????????????????????????????????????????Ŀ
        ?                  Trata os Campos Virtuais                    ?
        ????????????????????????????????????????????????????????????????*/

         If aHeader[x][2] == "C6_ALI_WT"
            aCols[ Len( aCols ) , x ]  :=  "SC6"
         Endif   

         If aHeader[x][2] == "C6_REC_WT" 
            aCols[ Len( aCols ) , x ]  :=  0
         Endif                        

      Endif   

    /*??????????????????????????????????????????????????????????????Ŀ
      ?                Deixa a Linha Ativa do Acols                  ?
      ????????????????????????????????????????????????????????????????*/
         
      aCols[ Len( aCols ) , nUsado + 1] := .F.      
   
   Next x


/*??????????????????????????????????????????????????????????????Ŀ
  ?               Aplica os Descontos nos Precos                 ?
  ????????????????????????????????????????????????????????????????*/

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
  
/*??????????????????????????????????????????????????????????????Ŀ
  ?               Atribui as Linhas do Acols                     ?
  ????????????????????????????????????????????????????????????????*/

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
????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????ͻ??
???Programa  ?  RetPrcTab   ? Autor ? Cristiano Figueiroa? Data ? 24/03/2009 ???
????????????????????????????????????????????????????????????????????????????͹??
???Descricao ? Retorna o Preco de Tabela do Produto                          ???
????????????????????????????????????????????????????????????????????????????͹??
???Uso       ? Brasitech                                                     ???
????????????????????????????????????????????????????????????????????????????ͼ??
????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????????
*/

Static Function RetPrcTab ( cTabela , cProduto )

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?              Declara as Variaveis Locais Utilizadas na Rotina              ?
  ??????????????????????????????????????????????????????????????????????????????*/

Local nPrecoRet := 0
Local aArea     := GetArea()

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                  Verifica o Preco de Venda do Produto                      ?
  ??????????????????????????????????????????????????????????????????????????????*/

DbSelectArea("DA1")
DbSetOrder(1)

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                  Verifica o Preco de Venda do Produto                      ?
  ??????????????????????????????????????????????????????????????????????????????*/

If DbSeek( xFilial("DA1") + cTabela + cProduto )
   nPrecoRet := DA1->DA1_PRCVEN
Else
   Aviso( "Aten??o !" , "O Produto " + Alltrim( Posicione( "SB1" , 1 , xFilial("SB1") + cProduto , "B1_DESC"   ) ) + " n?o est? na Tabela de Pre?os " + cTabela + " !" , {"Ok"} , 1 , "Produto sem Pre?o !" )
Endif		

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                  Restaura o Ambiente Antes da Utilizacao                   ?
  ??????????????????????????????????????????????????????????????????????????????*/

RestArea( aArea )

Return nPrecoRet

/*
????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????ͻ??
???Programa  ?  EdtLinKit   ? Autor ? Cristiano Figueiroa? Data ? 01/04/2009 ???
????????????????????????????????????????????????????????????????????????????͹??
???Descricao ? Bloqueia a Edicao do Campo caso seja um Produto de Kit        ???
????????????????????????????????????????????????????????????????????????????͹??
???Uso       ? Brasitech                                                     ???
????????????????????????????????????????????????????????????????????????????ͼ??
????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????????
*/

User Function EdiLinKit

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?              Declara as Variaveis Locais Utilizadas na Rotina              ?
  ??????????????????????????????????????????????????????????????????????????????*/

Local nPosKit := aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "C6_CODKIT"  })
Local cCodKitL := aCols[ n ][nPosKit ]
Local lRet    := .F.

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?              Verifica se a Linha se Refere a um Kit                        ?
  ??????????????????????????????????????????????????????????????????????????????*/

If Empty ( Alltrim(  cCodKitL )  )
   lRet := .T.
Endif

Return lRet