#include "Rwmake.ch"
#include "Topconn.ch"

/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммямммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  Ё RelFatCan ╨ Autor Ё Cristiano Figueiroa╨ Data Ё 27/04/2009  ╨╠╠
╠╠лммммммммммьмммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Descricao Ё Relatorio de Faturamento por Canal                          ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Brasitech                                                   ╨╠╠
╠╠хммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/


User Function RelFatCan

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                 Declara as Variaveis Utilizadas na Rotina                  Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Local   aOrd      := {}
Private cbcont    := 00
Private CONTFL    := 01
Private CbTxt     := ""
Private aArea     := GetArea()
Private cPerg     := "RELFATCANO"
Private nOrdem    := 0
Private tamanho   := "G"
Private limite    := 135
Private cDesc1    := "Este programa irА emitir o Relatorio de Faturamento por Canal"
Private cDesc2    := "conforme os parametros informados pelo usuАrio"
Private aReturn   := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
Private nomeprog  := "REFACAN" 
Private nLastKey  := 0
Private nTipo     := 18
Private m_pag     := 01
Private lContinua := .T.
Private lEnd      := .F.
Private nLin      := 80
Private wnrel     := "REFACAN"
Private cString   := "SD2"
Private titulo    := "Faturamento por Canal"
Private cabec1    := "Canal                          Supervisor                                Cliente                                   Nota Fiscal   Produto                              Vlr Total "
Private cabec2    := ""
//                    XXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXX     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   999,999,999.99
//                   "01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789"
//                    0        10         20        30        40        50        60        70        80        90       100       110       120       130       140       150      160     170               130               130        


//Canal                                    Cliente                                 Nf
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

RptStatus( { || RelFatCanA() }, "Aguarde..." ,  "Selecionando as Notas Fiscais de Faturamento..." )

Return

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  Ё RelFatCanA ╨ Autor Ё Cristiano Figueiroa╨ Data Ё 27/04/2009  ╨╠╠
╠╠лммммммммммьммммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Descricao Ё Rotina de Impressao dos Detalhes das Notas Fiscais           ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Brasitech                                                    ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/


Static Function RelFatCanA

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                 Declara as Variaveis Utilizadas na Rotina                  Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Local   cQuery
Local   cCanal     := ""
Local   cCodCli    := ""
Local   cNomCli    := ""
Local   cNomCanal  := ""
Local   cCodSup    := ""
Local   cNomSup    := ""
Private nTotFatCl  := 0
Private nTotCanal  := 0  
Private nTotSup    := 0  
Private nTotGeral  := 0
Private cCnpjEmp   := ""


/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё               Monta a Expressao para Analitico ou Sintetico                Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

If MV_PAR11 == 1 
   Titulo += "  - Analitico "
Else
   Titulo += "  - SintИtico "   
Endif

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё         Chama a Funcao que Monta a Expressao com os Cnpjs do Grupo         Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

If MV_PAR12 == 1
   VerEmpGrp()
Endif

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                      Monta a String contendo a Query                       Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

cQuery := "Select SD2.D2_DOC , SD2.D2_SERIE , SD2.D2_CLIENTE , SD2.D2_LOJA , SD2.D2_COD , SD2.D2_QUANT , SD2.D2_PRCVEN  , SD2.D2_TOTAL , SD2.D2_TES , SD2.D2_TIPO , SD2.D2_TES , SD2.D2_ITEM ,"
cQuery += "       SA1.A1_COD , SA1.A1_LOJA  , SA1.A1_NOME    , SA1.A1_SATIV1 , "
cQuery += "       SA3.A3_COD , SA3.A3_GEREN , SA3.A3_SUPER   ,"
cQuery += "       SF2.F2_VEND1 "

cQuery += " From  " + RetSqlName("SD2") + " SD2  , " + RetSqlName("SA1") + " SA1  , " + RetSqlName("SF4") + " SF4  , " + RetSqlName("SA3") + " SA3  , " + RetSqlName("SF2") + " SF2 " 

cQuery += "  Where      SD2.D2_CLIENTE = SA1.A1_COD  "
cQuery += "         And SD2.D2_LOJA    = SA1.A1_LOJA "
cQuery += "         And SD2.D2_TES     = SF4.F4_CODIGO"
cQuery += "         And SD2.D2_TIPO    = 'N'         "
cQuery += "         And SD2.D2_CLIENTE BetWeen '" +       MV_PAR07   + "' And '" +       MV_PAR08 + "' "
cQuery += "         And SD2.D2_LOJA    BetWeen '" +       MV_PAR09   + "' And '" +       MV_PAR10 + "' "
cQuery += "         And SD2.D2_FILIAL  BetWeen '" +       MV_PAR03   + "' And '" +       MV_PAR04 + "' "
cQuery += "         And SD2.D2_EMISSAO BetWeen '" + DtoS( MV_PAR01 ) + "' And '" + DtoS( MV_PAR02 ) + "' "
cQuery += "         And SD2.D2_DOC     = SF2.F2_DOC    "   
cQuery += "         And SD2.D2_SERIE   = SF2.F2_SERIE  " 
cQuery += "         And SD2.D2_CLIENTE = SF2.F2_CLIENTE"
cQuery += "         And SD2.D2_LOJA    = SF2.F2_LOJA   "
cQuery += "         And SD2.D2_FILIAL  = SF2.F2_FILIAL "
cQuery += "         And SF2.F2_VEND1   = SA3.A3_COD"   
cQuery += "         And SF4.F4_DUPLIC  = 'S' "
cQuery += "         And SD2.D_E_L_E_T_ = '' "
cQuery += "         And SA1.D_E_L_E_T_ = '' "
cQuery += "         And SF4.D_E_L_E_T_ = '' "
cQuery += "         And SF2.D_E_L_E_T_ = '' "
cQuery += "         And SA3.D_E_L_E_T_ = '' "

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё             Ignora os Cnpjs de Cliente de Empresas do Grupo                Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

If MV_PAR12 == 1
   cQuery += "      And A1_CGC Not In " + FormatIn( cCnpjEmp , "/" )
Endif   


cQuery += "    Order By SA3.A3_GEREN , SA3.A3_SUPER , SA1.A1_COD , SA1.A1_LOJA , SD2.D2_DOC , SD2.D2_COD "

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                Chama a Funcao que Readequa a Query                         Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

cQuery :=  ChangeQuery( cQuery )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё    Gera a Query em Arquivo Texto para Analises pelo Query Analyser         Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Memowrite("RelFatCan.Sql" , cQuery )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                 Abre o Resultado da Query no Alias QRY                     Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

TcQuery cQuery New Alias "TMP"

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                    Ajusta os Campos Data e Numerico                        Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

TcSetField( "TMP" , "D2_EMISSAO" , "D" , 08 , 0 )
TcSetField( "TMP" , "D2_PRCVEN"  , "N" , 14 , 2 )
TcSetField( "TMP" , "D2_QUANT"   , "N" , 14 , 2 )
TcSetField( "TMP" , "D2_TOTAL"   , "N" , 14 , 2 )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё       Monta o Cabecalho de Acordo com o Tipo ( Analitico / Sintetico )     Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

If MV_PAR11 == 1
   Cabec1    := "Canal                          Supervisor                                Cliente                                   Nota Fiscal   Produto                              Vlr Total "
Else   
   Cabec1    := "Canal                          Supervisor                                Cliente                                                                                      Vlr Total "
Endif

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                     Abre o Arquivo Temporario RDF                          Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

DbSelectArea("TMP")
DbGoTop()

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                     Monta a Regua de Processamento                         Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

SetRegua( Reccount() )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                   Processa todo o Arquivo Temporario                       Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Do While TMP->( !Eof() )
	
  /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё                   Imprime o Cabecalho do Relatorio                         Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	
   If nLin > 56
      Cabec( Titulo , Cabec1 , Cabec2 , NomeProg , Tamanho , nTipo )
      nLin := 8
   Endif   

  /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё                   Armazena as Variaveis de Quebra                          Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

   cCanal    := TMP->A3_GEREN 
   cNomCanal := Iif ( Empty ( TMP->A3_GEREN ) , "Canal nЦo Identificado"   , Posicione ( "SA3" , 1 , xFilial("SA3") + TMP->A3_GEREN , "A3_NOME" ) )
   nTotCanal:= 0
   @ nLin , 000 Psay cNomCanal
   nLin ++
   @ nLin , 000 Psay __PrtThinLine()         
   nLin ++

  /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё                   Processa a Quebra do Canal                               Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
   
   Do While TMP->( !Eof() )	 .And. TMP->A3_GEREN == cCanal
   
    /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  	  Ё                   Imprime o Cabecalho do Relatorio                         Ё
	  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	
      If nLin > 56
         Cabec( Titulo , Cabec1 , Cabec2 , NomeProg , Tamanho , nTipo )
         nLin := 8
      Endif   

    /*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      Ё                 Atualiza as Variaveis do Supervisor                 Ё
      юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

      cCodSup  := TMP->A3_SUPER
      cNomSup  := Iif ( Empty ( TMP->A3_SUPER ) , "Supervisor nЦo Identificado"   , Posicione ( "SA3" , 1 , xFilial("SA3") + TMP->A3_SUPER , "A3_NOME" ) )

    /*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  	  Ё                   Imprime os Dados do Supervisor                    Ё
	  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

      @ nLin , 031 Psay  cNomSup
      nLin ++
      
    /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  	  Ё                   Processa a Quebra do Supervisor                          Ё
	  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
   
      Do While TMP->( !Eof() )	 .And. TMP->A3_SUPER == cCodSup .And. TMP->A3_GEREN == cCanal
  
       /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   	     Ё                   Imprime o Cabecalho do Relatorio                         Ё
	     юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	
         If nLin > 56
            Cabec( Titulo , Cabec1 , Cabec2 , NomeProg , Tamanho , nTipo )
            nLin := 8
         Endif   

      /*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   	    Ё                   Atualiza as Variaveis do Cliente                  Ё
	    юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

         cCodCli  := TMP->A1_COD
         cNomCli  := TMP->A1_NOME

      /*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   	    Ё                   Imprime os Dados do Cliente                       Ё
	    юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

         If MV_PAR11 == 1
            @ nLin , 073 Psay TMP->A1_NOME
            nLin ++
         Endif   

      /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
        Ё                        Processa a Quebra do Cliente                        Ё
	    юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
   
         Do While TMP->( !Eof() ) .And. TMP->A3_SUPER == cCodSup .And. TMP->A3_GEREN == cCanal .And. TMP->A1_COD == cCodCli 

          /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    	    Ё                   Processa a Quebra do Cliente                             Ё
	        юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

     	    If MV_PAR11 == 1
     	       @ nLin , 115 Psay TMP->D2_DOC
  	           @ nLin , 129 Psay Substr( Posicione ( "SB1" , 1 , "03" + TMP->D2_COD , "B1_DESC"   ) , 1 , 30 )
               @ nLin , 162 Psay TMP->D2_TOTAL  Picture "@E 999,999,999.99" 
               nLin ++
            Endif   

            nTotFatCl += TMP->D2_TOTAL
            nTotCanal += TMP->D2_TOTAL
            nTotSup   += TMP->D2_TOTAL
            nTotGeral += TMP->D2_TOTAL         

          /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            Ё                   Chama a Rotina que Calcula as Devolucoes                 Ё
	        юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

            MontaDevFat ( TMP->D2_DOC , TMP->D2_SERIE , TMP->D2_COD , TMP->D2_ITEM , TMP->D2_CLIENTE , TMP->D2_LOJA )

          /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
     	    Ё                   Volta a Area ao Arquivo Anterior                         Ё
	        юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
         
            DbSelectArea("TMP")
         
          /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       	    Ё                   Imprime o Cabecalho do Relatorio                         Ё
	        юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	
            If nLin > 56
               Cabec( Titulo , Cabec1 , Cabec2 , NomeProg , Tamanho , nTipo )
               nLin := 8
            Endif   

            DbSkip()
            Loop
   
         Enddo    
      
         If MV_PAR11 == 1 
            nLin ++         
            @ nLin , 073 Psay " ---| Total do Cliente |--- " 
         Else
            @ nLin , 073 Psay cNomCli
         Endif               
         @ nLin , 162 Psay nTotFatCl Picture "@E 999,999,999.99" 
         
         If MV_PAR11 == 1
            nLin ++
            @ nLin , 000 Psay __PrtThinLine()            
         Endif   
      
         nLin ++
         nTotFatCl := 0     

      Enddo

    /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      Ё                   Imprime os Totais por Supervisor                         Ё
      юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

      nLin ++
      @ nLin , 073 Psay " ---| Total do Supervisor |--- " 
      @ nLin , 162 Psay nTotSup   Picture "@E 999,999,999.99" 
      nLin ++
      nLin ++
      nTotSup := 0                         
      
      If MV_PAR11 == 1
         nLin ++
         @ nLin , 000 Psay __PrtThinLine()            
         nLin ++
      Endif   
      
//    DbSkip()
//    Loop

   Enddo

 /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   Ё                      Imprime os Totais por Canal                           Ё
   юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

   nLin ++
   @ nLin , 000 Psay " ---| Total do Canal |--- " 
   @ nLin , 031 Psay cNomCanal
   @ nLin , 162 Psay nTotCanal Picture "@E 999,999,999.99" 
   nLin ++
   nLin ++
   @ nLin , 000 Psay __PrtThinLine()            
   nLin ++
   nLin ++

   //DbSkip()
   //Loop

Enddo         

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                   Imprime o Total Geral do Relatorio                       Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

nLin ++                                               
@ nLin , 000 Psay __PrtThinLine()            
nLin ++
@ nLin , 000 Psay  " ---| Total do Geral |--- " 
@ nLin , 162 Psay nTotGeral Picture "@E 999,999,999.99" 
nLin ++
@ nLin , 000 Psay __PrtThinLine()            

/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                Finaliza a execucao do relatorio...                  Ё
  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Set Device To Screen

/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё      Se impressao em disco, chama o gerenciador de impressao...     Ё
  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

If aReturn[5]==1
   DbCommitAll()
   Set Printer To
   OurSpool(wnrel)
Endif

Ms_Flush()

/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                 Fecha os Arquivos Temporarios                       Ё
  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

If Select("TMP") > 0
   DbSelectArea("TMP")
   DbClosearea()
Endif

If Select("TMP2") > 0
   DbSelectArea("TMP2")
   DbClosearea()
Endif


Return

/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммямммммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  Ё MontaDevFat ╨ Autor Ё Cristiano Figueiroa╨ Data Ё 27/04/2009  ╨╠╠
╠╠лммммммммммьмммммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Descricao Ё Monta as Devolucoes do Faturamento                            ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Brasitech                                                     ╨╠╠
╠╠хммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/


Static Function MontaDevFat ( cNumero , cSerie , cProduto , cItem , cCliente , cLoja )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                 Declara as Variaveis Utilizadas na Rotina                  Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Local cQuery1

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                      Monta a String contendo a Query                       Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

cQuery1 := "Select SD1.D1_DOC     , SD1.D1_SERIE    , SD1.D1_COD     , SD1.D1_QUANT   , SD1.D1_VUNIT   , SD1.D1_TOTAL "

cQuery1 += " From  " + RetSqlName("SD1") + " SD1  "

cQuery1 += "  Where      SD1.D1_TIPO = 'D'"

cQuery1 += "         And SD1.D1_NFORI   = '" + cNumero + "'"
cQuery1 += "         And SD1.D1_SERIORI = '" + cSerie  + "'"
cQuery1 += "         And SD1.D1_COD     = '" + cProduto+ "'"
cQuery1 += "         And SD1.D1_ITEMORI = '" + cItem   + "'"
cQuery1 += "         And SD1.D1_FORNECE = '" + cCliente+ "'"
cQuery1 += "         And SD1.D1_LOJA    = '" + cLoja   + "'"
cQuery1 += "         And SD1.D_E_L_E_T_ = '' "
cQuery1 += "         And SD1.D1_FILIAL  BetWeen '" +   MV_PAR03   + "' And '" +  MV_PAR04 + "' "
cQuery1 += "    Order By SD1.D1_COD "

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                Chama a Funcao que Readequa a Query                         Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

cQuery1 :=  ChangeQuery( cQuery1 )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё    Gera a Query em Arquivo Texto para Analises pelo Query Analyser         Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Memowrite("ReDeFatDet.Sql" , cQuery1 )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                 Abre o Resultado da Query no Alias QRY                     Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

TcQuery cQuery1 New Alias "TMP2"

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                    Ajusta os Campos Data e Numerico                        Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

TcSetField( "TMP2" , "D1_VUNIT"   , "N" , 14 , 2 )
TcSetField( "TMP2" , "D1_QUANT"   , "N" , 14 , 2 )
TcSetField( "TMP2" , "D1_TOTAL"   , "N" , 14 , 2 )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                     Abre o Arquivo Temporario RDT                          Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

DbSelectArea("TMP2")
DbGoTop()

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                     Monta a Regua de Processamento                         Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

SetRegua( Reccount() )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                   Processa todo o Arquivo Temporario                       Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Do While TMP2->( !Eof() )
	
  /*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё                Imprime os Dados da Devolucao                        Ё
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	
   If MV_PAR11 == 1
      @ nLin , 115 Psay TMP2->D1_DOC
      @ nLin , 129 Psay Substr( Posicione ( "SB1" , 1 , "03" + TMP2->D1_COD , "B1_DESC"   ) , 1 , 30 )
      @ nLin , 162 Psay TMP2->D1_TOTAL  Picture "@E 999,999.99" 
      @ nLin , 170 Psay "(-)"
	  nLin ++
   Endif	  

/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                   Subtrai a Devolucao dos Totais                    Ё
  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

   nTotFatCl -= TMP2->D1_TOTAL
   nTotCanal -= TMP2->D1_TOTAL
   nTotSup   -= TMP2->D1_TOTAL   
   nTotGeral -= TMP2->D1_TOTAL
   
/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                   Processa a Promixa Devolucao                      Ё
  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

  DbSkip()
  Loop

Enddo 

/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                   Fecha o Arquivo Temporario                        Ё
  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

DbSelectArea("TMP2")
DbCloseArea()

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

aAdd( aRegs , { cPerg , "01" , "Da Data de Emissao      ?    " , "            " , "            " , "MV_CH1" , "D" , 08 , 0 , 0 , "G" , "" , "MV_PAR01" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , ""})
aAdd( aRegs , { cPerg , "02" , "Ate a Data de Emissao   ?    " , "            " , "            " , "MV_CH2" , "D" , 08 , 0 , 0 , "G" , "" , "MV_PAR02" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , ""})
aAdd( aRegs , { cPerg , "03" , "Da Filial               ?    " , "            " , "            " , "MV_CH3" , "C" , 02 , 0 , 0 , "G" , "" , "MV_PAR03" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "SM0" , ""})
aAdd( aRegs , { cPerg , "04" , "Ate a Filial            ?    " , "            " , "            " , "MV_CH4" , "C" , 02 , 0 , 0 , "G" , "" , "MV_PAR04" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "SM0" , ""})
aAdd( aRegs , { cPerg , "05" , "Do Canal                ?    " , "            " , "            " , "MV_CH5" , "C" , 06 , 0 , 0 , "S" , "" , "MV_PAR05" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "T3" , ""})
aAdd( aRegs , { cPerg , "06" , "Ate o Canal             ?    " , "            " , "            " , "MV_CH6" , "C" , 06 , 0 , 0 , "S" , "" , "MV_PAR06" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "T3" , ""})
aAdd( aRegs , { cPerg , "07" , "Do Cliente              ?    " , "            " , "            " , "MV_CH7" , "C" , 08 , 0 , 0 , "G" , "" , "MV_PAR07" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "SA1" , ""})
aAdd( aRegs , { cPerg , "08" , "Ate o Cliente           ?    " , "            " , "            " , "MV_CH8" , "C" , 08 , 0 , 0 , "G" , "" , "MV_PAR08" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "SA1" , ""})
aAdd( aRegs , { cPerg , "09" , "Da Loja                 ?    " , "            " , "            " , "MV_CH9" , "C" , 02 , 0 , 0 , "G" , "" , "MV_PAR09" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , ""})
aAdd( aRegs , { cPerg , "10" , "Ate a Loja              ?    " , "            " , "            " , "MV_CHA" , "C" , 02 , 0 , 0 , "G" , "" , "MV_PAR10" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , ""})
aAdd( aRegs , { cPerg , "11" , "Imprimir Relatorio      ?    " , "            " , "            " , "MV_CHB" , "N" , 01 , 0 , 0 , "C" , "" , "MV_PAR11" , "Analitico" , "Analitico" , "Analitico" , "" , "" , "Sintetico" , "Sintetico" , "Sintetico" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , ""})
aAdd( aRegs , { cPerg , "12" , "Lista Empresas do Grupo ?    " , "            " , "            " , "MV_CHC" , "N" , 01 , 0 , 0 , "C" , "" , "MV_PAR12" , "Nao"       , "Nao"       , "Nao"       , "" , "" , "Sim"       , "Sim"       , "Sim"       , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , ""})

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
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммямммммммммкмммммммямммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁVerEmpGrp╨ Autor Ё Cristiano Figueiroa ╨ Data Ё 29/04/2009  ╨╠╠
╠╠лммммммммммьмммммммммймммммммомммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Descricao ЁMonta Expressao com as Empresas do Grupo                    ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       ЁBrasitech                                                   ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/

Static Function VerEmpGrp  

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                 Declara as Variaveis Utilizadas na Rotina                  Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Local aArea      := GetArea()
Local aAreaSM0   := SM0->( GetArea() )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                 Abre o Cadastro de Empresas - SM0                          Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

DbSelectArea("SM0")
DbSetOrder(1)
DbGoTop()


Do While SM0->( !Eof() )

/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё  Monta Expressao com os Cnpjs existentes no Cadastro de Empresas do Protheus  Ё
  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

   cCnpjEmp += SM0->M0_CGC + "/"

 /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   Ё                Proximo Registro do Cadastro de Empresas                    Ё
   юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

   DbSkip()
   Loop

Enddo

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                 Restaura as Areas utilizadas Anteriormente                 Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

RestArea(aAreaSM0)
RestArea(aArea)

Return cCnpjEmp