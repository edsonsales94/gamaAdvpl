#include "Rwmake.ch"
#include "Topconn.ch"

/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммямммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  Ё GrvLogPed ╨ Autor Ё Cristiano Figueiroa╨ Data Ё 03/12/2009  ╨╠╠
╠╠лммммммммммьмммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Descricao Ё Grava o Log do Pedido de Vendas Conforme Parametros         ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Brasitech                                                   ╨╠╠
╠╠хммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/


User Function GrvLogPed ( cRotina , cPe , cNumPed , cStatus )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                    Declara as Variaveis da Rotina                          Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Local lRet     := .T. 
Local aArea    := GetArea()
Local aAreaSC5 := SC5->( GetArea() )
Local aAreaSC6 := SC6->( GetArea() )
Local aAreaSC9 := SC9->( GetArea() )
Local aAreaSA1 := SA1->( GetArea() )
Local cItens   := ""
Local cMemo    := ""


/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                   Retorna os Itens dos Pedidos de Vendas                   Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

//cItens := u_RetInfIte( cNumPed )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                       Abre o Cadastro de Clientes                          Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

DbSelectArea("SA1")
DbSetOrder(1)

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                    Posiciona no Cadastro de Clientes                       Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
//If !DbSeek ( xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI )
//	Aviso( "Log do Pedido" , "O cliente " + SC5->C5_CLIENTE + "/" + SC5->C5_LOJACLI + " nЦo foi encontrado no cadastro de clientes do sistema ! O Log nЦo serА Gravado !"  , {"Ok"} , 1 , "Cliente nЦo Encontrado ! " )
//	lRet := .F.
//Endif

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё           Pesquisa no Cadastro de Usuarios pelo Nome do Usuario            Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

PswOrder(2)

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё           Pesquisa no Cadastro de Usuarios pelo Nome do Usuario            Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

If PswSeek( Alltrim( cUserName ) )

  /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё           Ordena o Arquivo de Usuarios pela Senha do Usuario               Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

   cCodUsr := Pswret(1)[1][ 1]	
   cNomUsr := Pswret(1)[1][ 4]
   cMaiUsr := Pswret(1)[1][14]
   
Else

   cCodUsr := __cUserId
   cNomUsr := cUserName
   cMaiUsr := ""

Endif


/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                 Caso nao haja Inconsistencias Grava o Log                  Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

If lRet
	If SC6->(FieldPos("C6_XOPER")) > 0 .and. SC6->(FieldPos("C6_XOPDESC")) > 0
   		RecLock("SZA" , .T. )
	   	SZA->ZA_FILIAL := xFilial()
	   	SZA->ZA_CODUSR := cCodUsr
	   	SZA->ZA_NOMUSR := cNomUsr
	   	SZA->ZA_MALUSR := cMaiUsr
	   	SZA->ZA_NUMPED := SC5->C5_NUM
		SZA->ZA_NUMCOND:= SC5->C5_CONDPAG
		SZA->ZA_DESCOND:= SC5->C5_NOMCOND
		SZA->ZA_DATAFAT:= SC5->C5_X_DTPRE
		SZA->ZA_DATA   := MsDate()
		SZA->ZA_ROTINA := cRotina
		SZA->ZA_PE     := cPe
		SZA->ZA_CODCLI := SC5->C5_CLIENTE
		SZA->ZA_LOJCLI := SC5->C5_LOJACLI
		SZA->ZA_RAZAO  := SC5->C5_NOMECLI  
		SZA->ZA_CGCCLI := Transform( SC5->C5_CGC , "@R 99.999.999/9999-99" )
		SZA->ZA_MUNCLI := SA1->A1_MUN
		SZA->ZA_ESTCLI := SA1->A1_EST
		SZA->ZA_CODCAN := SA1->A1_SATIV1
		SZA->ZA_DESCAN := Posicione( "SX5" , 1 , xFilial("SX5") + "T3" + SubStr( SA1->A1_SATIV1 , 1 , 2 ) , "X5_DESCRI" )
		SZA->ZA_CONTATO:= SA1->A1_CONTATO
		SZA->ZA_MAILCLI:= SA1->A1_EMAIL
		SZA->ZA_STATUS := cStatus
		SZA->ZA_HORA   := Time() 
		SZA->ZA_ITENS  := cItens
		SZA->ZA_CODOPER:=SC6->C6_XOPER  
		SZA->ZA_OPEDESC:=SC6->C6_XOPDESC   
		MsUnlock()
	Endif   
Endif		
/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                      Restaura as Areas Utilizadas                          Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

RestArea( aAreaSC5 )
RestArea( aAreaSC6 )
RestArea( aAreaSC9 )
RestArea( aAreaSA1 )
RestArea( aArea )

Return

/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммямммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  Ё RetInfIte ╨ Autor Ё Cristiano Figueiroa╨ Data Ё 03/12/2009  ╨╠╠
╠╠лммммммммммьмммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Descricao Ё Grava o Log do Pedido de Vendas Conforme Parametros         ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Brasitech                                                   ╨╠╠
╠╠хммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/


User Function RetInfIte( cNumPed )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                    Declara as Variaveis da Rotina                          Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Local cItePed := ""

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                Abre a Tabela Itens dos Pedido de Vendas                    Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

DbSelectArea("SC6")
DbSetOrder(1)

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                       Posiciona nos Itens do Pedido                        Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

If DbSeek ( xFilial("SC6") + cNumPed )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                   Processa Todos os Itens do Pedido                        Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

   Do While SC6->( !Eof() ) .And. SC6->C6_NUM == cNumPed
                             
   /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
     Ё                   Guarda as Informacoes no Array                           Ё
     юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

      cItePed += SC6->C6_ITEM + " Produto " + SC6->C6_PRODUTO + " DescriГЦo " + SC6->C6_DESCRI + " Unidade " + SC6->C6_UM + " Quantidade " + Transform ( SC6->C6_QTDVEN ,"@E 999,999,999") + " Vlr UnitАrio " + Transform ( SC6->C6_PRCVEN ,"@E 9,999,999.99") + " Total " + Transform ( SC6->C6_VALOR ,"@E 9,999,999.99") + ";" 

   /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
     Ё                   Processa o Proximo Item do Pedido                        Ё
     юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
      
      DbSkip()
      Loop
   Enddo                             

Endif

Return cItePed

/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммямммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁVerStatPed ╨ Autor Ё Cristiano Figueiroa╨ Data Ё 07/12/2009  ╨╠╠
╠╠лммммммммммьмммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Descricao Ё Verifica o Status do Pedido de Vendas                       ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Brasitech                                                   ╨╠╠
╠╠хммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/


User Function VerStatPed( cFilPed , cNumPed , cCliPed , cCliLoj )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                 Declara as Variaveis Utilizadas na Rotina                  Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Local   cQuery
Local   aStatus := { "Pedido Em Carteira" }
Local   aArea   := GetArea()

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                      Monta a String contendo a Query                       Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

cQuery := "Select Distinct   SC5.C5_FILIAL , SC5.C5_NUM    , SC5.C5_CODREJ , SC5.C5_MOTIREJ , SC5.C5_DATREJ , SC5.C5_USERREJ "
cQuery += "                , SC9.C9_PEDIDO , SC9.C9_BLCRED , SC9.C9_BLEST  , SC9.C9_NFISCAL"

cQuery += " From  " + RetSqlName("SC5") + " SC5  , " + RetSqlName("SC9") + " SC9 " 

cQuery += "  Where "
cQuery += "               SC5.C5_NUM     = '" +  cNumPed + "' "
cQuery += "          And  SC5.C5_CLIENTE = '" +  cCliPed + "' "
cQuery += "          And  SC5.C5_LOJACLI = '" +  cCliLoj + "' "
cQuery += "          And  SC5.C5_FILIAL  = '" +  cFilPed + "' "
//Alterado em 16/03/13 pois o SLQ SERVER 2008 nao aceita left outer join como *=
//cQuery += "          And  SC5.C5_NUM     *= SC9.C9_PEDIDO
//cQuery += "          And  SC5.C5_FILIAL  *= SC9.C9_FILIAL
cQuery += "          And  SC5.C5_NUM     = SC9.C9_PEDIDO
cQuery += "          And  SC5.C5_FILIAL  = SC9.C9_FILIAL

cQuery += "          And  SC5.D_E_L_E_T_ = '' 
cQuery += "          And  SC9.D_E_L_E_T_ = '' 

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                Chama a Funcao que Readequa a Query                         Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

cQuery :=  ChangeQuery( cQuery )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё    Gera a Query em Arquivo Texto para Analises pelo Query Analyser         Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

//Memowrite("StatusPed.Sql" , cQuery )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                 Abre o Resultado da Query no Alias QRY                     Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

TcQuery cQuery New 	Alias "STA"

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                    Ajusta os Campos Data e Numerico                        Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

TcSetField( "STA" , "C5_DATREJ"  , "D" , 08 , 0 )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                     Abre o Arquivo Temporario CRD                          Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

DbSelectArea("STA")
DbGoTop()

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                   Processa todo o Arquivo Temporario                       Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Do While STA->( !Eof() )

 /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   Ё                   Verifica o Status do Pedido                              Ё
   юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

   If     STA->C9_BLCRED == '10' .And. STA->C9_BLEST == '10' .And. !Empty( STA->C9_NFISCAL)
      aStatus := { "Pedido Faturado" }
   ElseIf STA->C9_BLCRED == '  ' .And. STA->C9_BLEST == '02' .And.  Empty( STA->C9_NFISCAL)
      aStatus := { "Pedido com Bloqueio de Estoque" }
   ElseIf STA->C9_BLCRED == '01' .And. STA->C9_BLEST == '02' .And.  Empty( STA->C9_NFISCAL)
      aStatus := { "Pedido com Bloqueio de CrИdito" }
   ElseIf STA->C9_BLCRED == '  ' .And. STA->C9_BLEST == '  ' .And.  Empty( STA->C9_NFISCAL) .And. !Empty( STA->C9_PEDIDO )
      aStatus := { "Pedido Liberado para Faturar" }
   ElseIf STA->C9_BLCRED == '09' 
      aStatus := { "Pedido com CrИdito Rejeitado" }
   ElseIf Empty( STA->C9_PEDIDO )
      aStatus := { "Pedido Em Carteira" }
   Endif                  
                               
 /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   Ё                   Processa o Proximo Registro                            Ё
   юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

   DbSkip()
   Loop

Enddo         

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                     Fecha o Arquivo Temporario                           Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

DbSelectArea("STA")
DbCloseArea()

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                   Restaura as Areas Selecionadas                         Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

RestArea( aArea )

   
Return aStatus