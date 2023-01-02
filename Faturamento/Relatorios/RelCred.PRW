#Include "Rwmake.ch"
#Include "Topconn.ch"

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммммммм╩╠╠
╠╠╨Programa  Ё RelCred  ╨ Autor ЁCristiano Figueiroa ╨ Data Ё     05/10/09    ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммммммм╧╠╠
╠╠╨Descricao Ё Relatorio de Status de Credito por Pedido                      ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Brasitech                                                      ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

User Function RelCred

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                 Declara as Variaveis Utilizadas na Rotina                  Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Local   aOrd      := {}
Private cbcont    := 00
Private CONTFL    := 01
Private CbTxt     := ""
Private aArea     := GetArea()
Private cPerg     := "RELCRED001"
Private nOrdem    := 0
Private tamanho   := "G"
Private limite    := 135
Private cDesc1    := "Este programa irА emitir o Relatorio com as Situacoes de Credito"
Private cDesc2    := "de Cada Pedido de Vendas"
Private aReturn   := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
Private nomeprog  := "RELCRED" 
Private nLastKey  := 0
Private nTipo     := 18
Private m_pag     := 01
Private lContinua := .T.
Private lEnd      := .F.
Private nLin      := 80
Private wnrel     := "RELCRED"
Private cString   := "SC5"
Private titulo    := "Relatorio de Status de Credito por Pedido"
Private cabec1    := "Pedido  Cliente                                   Status                Dt Liberacao   Risco   Dt RejeiГЦo  Motivo da RejeiГЦo                                          Por"
Private cabec2    := ""                                                                                                                                                                   
//                    XXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXX  99/99/99         X     99/99/99     XXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXX     "
//                   "01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789"
//                    0        10         20        30        40        50        60        70        80        90       100       110       120       130       140       150      160     170               130               130        

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё           Verifica se o Grupo de Perguntas existe ou nao                   Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

VldPerg( cPerg )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё               Carrega o Grupo de Perguntas na Tela                         Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Pergunte( cPerg , .F. )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё               Envia Controle para a Funcao SetPrint                        Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

wnrel := SetPrint( cString , wnrel , cPerg , @Titulo , cDesc1 , cDesc2 , "" , .F. , , .F. )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё           Verifica o Cancelamento da Impressao dos Pedidos                 Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

If nLastKey == 27
	Return
Endif

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                                                                            Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

SetDefault( aReturn , cString )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                    Imprime o Relatorio de Sugestao                         Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

RptStatus( { || RelCreda() }, "Aguarde..." ,  "Imprimindo o Status de Credito dos Pedidos" )

Return

/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммямммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  Ё RelCreda  ╨ Autor Ё Cristiano Figueiroa╨ Data Ё 05/10/2009  ╨╠╠
╠╠лммммммммммьмммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Descricao Ё Rotina de Impressao dos Detalhes dos Status de Credito      ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Brasitech                                                   ╨╠╠
╠╠хммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/


Static Function RelCreda

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                 Declara as Variaveis Utilizadas na Rotina                  Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Local   cQuery
Local   cStatus := ""
Local   dDtLib  := ""
Local   cObs    := ""
Local   cSituaca:= ""

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                      Monta a String contendo a Query                       Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

cQuery := "Select Distinct   SC5.C5_FILIAL , SC5.C5_NUM    , SC5.C5_CODREJ , SC5.C5_MOTIREJ , SC5.C5_DATREJ , SC5.C5_USERREJ , SC5.C5_EMISSAO"
cQuery += "                , SC9.C9_PEDIDO , SC9.C9_BLCRED , SC9.C9_BLEST  , SC9.C9_NFISCAL , SC9.C9_DATALIB"
cQuery += "                , SA1.A1_NOME   , SA1.A1_RISCO"

cQuery += " From  " + RetSqlName("SC5") + " SC5  , " + RetSqlName("SC9") + " SC9 , " + RetSqlName("SA1") + " SA1 "  

//Alterado em 16/03/13 pois o SLQ SERVER 2008 nao aceita left outer join como *=
//cQuery += "  Where        SC5.C5_NUM     *= SC9.C9_PEDIDO
//cQuery += "          And  SC5.C5_FILIAL  *= SC9.C9_FILIAL
cQuery += "  Where  SC5.C5_NUM     = SC9.C9_PEDIDO"
cQuery += "          And  SC5.C5_FILIAL  = SC9.C9_FILIAL"

cQuery += "          And  SC5.C5_CLIENTE BetWeen '" +  MV_PAR01     + "' And '" +  MV_PAR02 + "' "
cQuery += "          And  SC5.C5_FILIAL  BetWeen '" +  MV_PAR05     + "' And '" +  MV_PAR06   + "' "
cQuery += "          And  SC5.C5_EMISSAO BetWeen '" +  DtoS( MV_PAR03 )   + "' And '" +  DtoS( MV_PAR04 ) + "' "
cQuery += "          And  SC5.C5_CLIENTE  = SA1.A1_COD
cQuery += "          And  SC5.C5_LOJACLI  = SA1.A1_LOJA
cQuery += "          And  SC5.D_E_L_E_T_  = '' 
cQuery += "          And  SC9.D_E_L_E_T_  = '' 
cQuery += "          And  SA1.D_E_L_E_T_  = '' 

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                Chama a Funcao que Readequa a Query                         Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

cQuery :=  ChangeQuery( cQuery )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё    Gera a Query em Arquivo Texto para Analises pelo Query Analyser         Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Memowrite("RelCred.Sql" , cQuery )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                 Abre o Resultado da Query no Alias QRY                     Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

TcQuery cQuery New Alias "CRD"

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                    Ajusta os Campos Data e Numerico                        Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

TcSetField( "CRD" , "C5_DATREJ"  , "D" , 08 , 0 )
TcSetField( "CRD" , "C5_EMISSAO" , "D" , 08 , 0 )
TcSetField( "CRD" , "C9_DATALIB" , "D" , 08 , 0 )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                     Abre o Arquivo Temporario CRD                          Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

DbSelectArea("CRD")
DbGoTop()

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                     Monta a Regua de Processamento                         Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

SetRegua( Reccount() )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                   Processa todo o Arquivo Temporario                       Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Do While CRD->( !Eof() )

 /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   Ё                   Imprime o Cabecalho do Relatorio                         Ё
   юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	
   If nLin > 56
      Cabec( Titulo , Cabec1 , Cabec2 , NomeProg , Tamanho , nTipo )
      nLin := 8
   Endif   

 /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   Ё                             Zera as Variaveis                              Ё  
   юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

   cStatus  := ""
   cObs     := ""     
   cSituaca := ""
   dEmissao := CRD->C5_EMISSAO

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                   Mostra a Data dos Pedidos                                Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

   nLin ++
   @ nLin , 000 Psay __PrtThinLine()            
   nLin ++   
   @ nLin , 001 Psay "Pedidos Emitidos em  : " + Dtoc (dEmissao ) 
   nLin ++
   @ nLin , 000 Psay __PrtThinLine()               
   nLin ++   

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                   Processa todo o Arquivo Temporario                       Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

   Do While CRD->( !Eof() ) .And. CRD->C5_EMISSAO == dEmissao

                
 /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   Ё                   Imprime o Cabecalho do Relatorio                         Ё
   юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	
      If nLin > 56
         Cabec( Titulo , Cabec1 , Cabec2 , NomeProg , Tamanho , nTipo )
         nLin := 8
      Endif   

    /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      Ё                      Verifica se Esta Faturado ou Nao                      Ё
      юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

      If ( MV_PAR08 == 1 .And. Empty( CRD->C9_NFISCAL ) ) .Or. ( MV_PAR08 == 2 .And. !Empty( CRD->C9_NFISCAL )  )
         DbSkip()
         Loop
      Endif

    /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      Ё                   Verifica o Status do Pedido                              Ё
      юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

      dDtLib := CRD->C9_DATALIB

      If     CRD->C9_BLCRED == '10' .And. CRD->C9_BLEST == '10' .And. !Empty( CRD->C9_NFISCAL)
            cStatus := "Faturado"
            cSituaca:= "Liberado"
      ElseIf CRD->C9_BLCRED == '  ' .And. CRD->C9_BLEST == '02' .And.  Empty( CRD->C9_NFISCAL)
            cStatus := "Bloqueio de Estoque"
            cSituaca:= "Bloqueado"         
            dDtLib  := Ctod( "  /  /  ")            
      ElseIf CRD->C9_BLCRED == '01' .And. CRD->C9_BLEST == '02' .And.  Empty( CRD->C9_NFISCAL)
            cStatus := "Bloqueio de CrИdito"
            cSituaca:= "Bloqueado"
            dDtLib  := Ctod( "  /  /  ")
      ElseIf CRD->C9_BLCRED == '  ' .And. CRD->C9_BLEST == '  ' .And.  Empty( CRD->C9_NFISCAL) .And. !Empty( CRD->C9_PEDIDO )
            cStatus := "Liberado para Faturar"
            cSituaca:= "Liberado"         
      ElseIf CRD->C9_BLCRED == '09' 
            cStatus := "Rejeitado"   
            cSituaca:= "Rejeitado"      
            dDtLib  := Ctod( "  /  /  ")               
      ElseIf Empty( CRD->C9_PEDIDO )
            cStatus := "Em Carteira"
            cSituaca:= "Liberado"
      Endif                  
                               
    /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      Ё                               Imprime Quais                                Ё
      юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
      
      If ( MV_PAR07 == 1 .And. cSituaca <> "Bloqueado" ) .Or. ( MV_PAR07 == 2 .And. cSituaca <> "Rejeitado" )
         DbSkip()
         Loop
      Endif
    /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      Ё                   Imprime os Dados do Relatorio                            Ё
      юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

      @ nLin , 000 Psay  CRD->C5_NUM
      @ nLin , 008 Psay  CRD->A1_NOME
      @ nLin , 050 Psay  cStatus 
      @ nLin , 072 Psay  dDtLib
      @ nLin , 089 Psay  CRD->A1_RISCO
      @ nLin , 095 Psay  Iif ( !Empty( CRD->C5_DATREJ ) , CRD->C5_DATREJ , "" )
      @ nLin , 108 Psay  Iif ( !Empty( CRD->C5_CODREJ ) , CRD->C5_CODREJ + " - " + Alltrim( CRD->C5_MOTIREJ ) , "" )
      @ nLin , 170 Psay  CRD->C5_USERREJ
   // @ nLin , 164 Psay  cObs
      nLin ++

    /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      Ё                   Processa o Proximo Registro                            Ё
      юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

      IncRegua()
      DbSkip()
      Loop

   Enddo   
   
Enddo

Set Device To Screen

If aReturn[5]==1
   DbCommitAll()
   Set Printer To
   OurSpool(wnrel)
Endif

Ms_Flush()
   
/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                 Fecha os Arquivos Temporarios                       Ё
  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

If Select("CRD") > 0
   DbSelectArea("CRD")
   DbClosearea()
Endif

Return

/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммямммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁValidPerg ╨ Autor Ё Analistas Microsiga ╨ Data Ё 14/04/2009  ╨╠╠
╠╠лммммммммммьммммммммммймммммммомммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Descricao Ё Cria o Grupo de Perguntas conforme Parametro                ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё DeNadai                                                     ╨╠╠
╠╠хммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/

Static Function VldPerg( cPerg )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё            Declara as Variaveis Locais Utilizadas na Rotina                Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Local aRegs := {}
Local i,j
/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё            Adiciona as Perguntas no Array a ser Gravado no SX1             Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

                   
/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё            Adiciona as Perguntas no Array a ser Gravado no SX1             Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

aAdd( aRegs , { cPerg , "01" , "Do Cliente                ?    " , "            " , "            " , "MV_CH1" , "C" , 08 , 0 , 0 , "G" , "" , "MV_PAR01" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "SA1" , ""})
aAdd( aRegs , { cPerg , "02" , "Ate o Cliente             ?    " , "            " , "            " , "MV_CH2" , "C" , 08 , 0 , 0 , "G" , "" , "MV_PAR02" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "SA1" , ""})
aAdd( aRegs , { cPerg , "03" , "Da Emissao do Pedido      ?    " , "            " , "            " , "MV_CH3" , "D" , 08 , 0 , 0 , "G" , "" , "MV_PAR03" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , ""})
aAdd( aRegs , { cPerg , "04" , "Ate a a Emissao do Pedido ?    " , "            " , "            " , "MV_CH4" , "D" , 08 , 0 , 0 , "G" , "" , "MV_PAR04" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , ""})
aAdd( aRegs , { cPerg , "05" , "Da Filial                 ?    " , "            " , "            " , "MV_CH5" , "C" , 02 , 0 , 0 , "G" , "" , "MV_PAR05" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , ""})
aAdd( aRegs , { cPerg , "06" , "Ate a Filial              ?    " , "            " , "            " , "MV_CH6" , "C" , 02 , 0 , 0 , "G" , "" , "MV_PAR06" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , ""})
aAdd( aRegs , { cPerg , "07" , "Lista Quais Pedidos       ?    " , "            " , "            " , "MV_CH7" , "N" , 01 , 0 , 0 , "C" , "" , "MV_PAR07" , "Bloqueados" , "Bloqueados" , "Bloqueados" , "" , "" , "Rejeitados" , "Rejeitados" , "Rejeitados" , "" , "" , "Todos" , "Todos" , "Todos" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , ""})
aAdd( aRegs , { cPerg , "08" , "SituaГЦo de Faturamento   ?    " , "            " , "            " , "MV_CH8" , "N" , 01 , 0 , 0 , "C" , "" , "MV_PAR08" , "Faturados"   , "Faturados"   , "Faturados"   , "" , "" , "Nao Faturados" , "Nao Faturados" , "Nao Faturados" , "" , "" , "Ambos" , "Ambos" , "Ambos" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , ""})

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё            Verifica se Ja Existe Registro no SX1 e Grava                   Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

DbSelectArea("SX1")
DbSetOrder(1)

For i := 1 to Len( aRegs )
	If !SX1->(dbSeek(cPerg+aRegs[i,2]))
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		SX1->(MsUnlock())
	Endif
Next

Return

/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммямммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  Ё MontaTrb ╨ Autor Ё Cristiano Figueiroa ╨ Data Ё 21/05/2009  ╨╠╠
╠╠лммммммммммьммммммммммймммммммомммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Descricao Ё Monta o Arquivo Temporario para Importacao dos Dados        ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Brasitech                                                   ╨╠╠
╠╠хммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/

Static Function MontaTrb()

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                    Declara as variaveis utilizadas                         Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Local aFile1 := {}
Local aFile2 := {}

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                Monta a Estrutura dos Arquivos Temporarios                  Ё   
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

aFile1 := { ;                                                                 // Arquivo de Produtos
             {"Cliente"      , "C" , 050 , 0 } ,;
             {"Vigencia"     , "C" , 030 , 0 } ,;
             {"Vlr_Minimo"   , "N" , 014 , 2 } ,;
             {"Prz_Medio"    , "N" , 003 , 0 } ,;
             {"Prz_Espec"    , "N" , 003 , 0 } ,;             
             {"Num_Parc"     , "N" , 003 , 0 } ,;
             {"Num_Parc_E"   , "N" , 003 , 0 } ,;
             {"Desconto"     , "N" , 006 , 2 } ,;
             {"Desc_Espec"   , "N" , 006 , 2 } ,;
             {"Desc_Distr"   , "N" , 006 , 2 } ,;
             {"Desc_Antec"   , "N" , 006 , 2 } ,;
             {"Desc_AV7"     , "N" , 006 , 2 } ,;
             {"Incluid_Em"   , "C" , 010 , 0 } ,;
             {"Por"          , "C" , 030 , 2 } ,;             
             {"Tabela"       , "C" , 003 , 0 } }          

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                      Cria area Temporaria no Sistema                       Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

cFile1 := CriaTrab( aFile1 )   // Arquivo de Trabalho

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                     Cria o Arquivo Temporario no Sistema                   Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

DbUseArea(.T. , , cFile1 , "TMX" , .T. )  // Arquivo de Produto

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                     Cria o Indice Temporario no Sistema                    Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

IndRegua("TMX" , cFile1 , "Str(100 - Desconto) + Cliente"   ,,, "Criando Arquivo...")  

Return