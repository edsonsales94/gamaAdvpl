#Include "PROTHEUS.CH"
#include "Rwmake.ch"                
#include "Topconn.ch"

/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммямммммммммммммммммммммкммммммяммммммммммммммм╩╠╠
╠╠╨Programa  ЁConPesoPedido ╨ Autor Ё Ricky Moraes    ╨ Data Ё   28/02/2019  ╨╠╠
╠╠лммммммммммьммммммммммймммммммомммммммммммммммммммммйммммммоммммммммммммммм╧╠╠
╠╠╨Descricao Ё Consulta  Peso itens do Pedido de Vendas                      ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Brasitech                                                     ╨╠╠
╠╠хммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/

User Function CONPESOPV()

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё              Declara as Variaveis Utilizadas na Rotina                     Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Local aArea    := GetArea()
Local oDlg     := Nil
Local oLbx     := Nil
Local cQuery   := ""
Local cFilPed  := SC5->C5_FILIAL
Local cNumPed  := SC5->C5_NUM   
Local oSay1
Local oSay2
Private aVetor := {}


/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё              Filtra as Informacoes da Tabela de pedidos Venda              Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

cQuery := "SELECT  "
cQuery += "SUM(B1_PESO*C6_QTDVEN ) AS PESOL,  "
cQuery += "SUM(B1_PESBRU *C6_QTDVEN) AS PESOB  "
cQuery += "FROM SC6010  SC6  "
cQuery += "INNER JOIN SB1010 SB1 ON B1_COD=C6_PRODUTO AND SB1.D_E_L_E_T_='' "
cQuery += "WHERE"
cQuery += "               SC6.C6_FILIAL  = '" +  cFilPed + "' "
cQuery += "          And  SC6.C6_NUM  = '" +  cNumPed + "' "
cQuery += "          And  SC6.D_E_L_E_T_ = ''

 

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                             Adequa a Query                                 Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

cQuery := ChangeQuery(cQuery)
//ALERT(cQuery)

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё    Gera a Query em Arquivo Texto para Analises pelo Query Analyser         Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

//Memowrite("CONPESOPV.Sql" , cQuery )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                 Abre o Resultado da Query no Alias QRY                     Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

TcQuery cQuery New Alias "PESOPV"

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                    Ajusta os Campos Data e Numerico                        Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

//TcSetField( "PESOPV" , "C6_PRODUTO"  , "C" , 15 , 0 )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                     Abre o Arquivo Temporario CRD                          Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

DbSelectArea("PESOPV")
DbGoTop()

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                     Processa os Registros do Log                           Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Do While PESOPV->( !Eof() )

 /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   Ё                      Adiciona ao Vetor o Log                             Ё
   юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

//	aAdd( aVetor , { LOGPED->ZA_NUMPED , LOGPED->ZA_NOMUSR , LOGPED->ZA_DATA , LOGPED->ZA_HORA , LOGPED->ZA_STATUS , LOGPED->ZA_CODOPER , LOGPED->ZA_OPEDESC , LOGPED->ZA_ROTINA , LOGPED->ZA_PE } )
	aAdd( aVetor , { PESOPV->PESOL,PESOPV->PESOB} )

 /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   Ё                   Processa o Proximo Registro                            Ё
   юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

   DbSkip()
   Loop

EndDo


/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                   Verifica se ha Dados no Log                            Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

If Len( aVetor ) == 0
	Aviso( "AtenГЦo !" , "NЦo existe item Registrado para o Pedido ! " , {"Ok"}  )
Else

   /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
     Ё               Monta a Tela com o Resultado da Consulta                   Ё
     юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
 
   Define MsDialog oDlg Title "Pedido PESO TOTAL Itens" From 0,0 To 250,300   COLORS 0, 16777215 PIXEL   

   @ 021, 004 ListBox oLbx Fields Header  "PESO_LIQ", "PESO_BRU"  SIZE 130, 050 OF oDlg PIXEL ColSizes 50,50


   oLbx:SetArray( aVetor )
   oLbx:bLine := {|| {aVetor[oLbx:nAt,1] , aVetor[oLbx:nAt,2]  }}   
   
//   oLbx:nScrollType := 1           
oLbx:lHScroll   :=.F.
oLbx:lVScroll   :=.F.


    @ 007, 004 SAY oSay1 PROMPT "Numero PV :" SIZE 034, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 007, 038 SAY oSay2 PROMPT cNumPed SIZE 038, 010 OF oDlg COLORS 0, 16777215 PIXEL
					
   Define SButton From 108,117 Type 1 Action oDlg:End() Enable Of oDlg
   Activate MsDialog oDlg Center

Endif

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                     Fecha o Arquivo Temporario                           Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

DbSelectArea("PESOPV")
DbCloseArea()

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                   Restaura as Areas Selecionadas                         Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

RestArea( aArea )

Return