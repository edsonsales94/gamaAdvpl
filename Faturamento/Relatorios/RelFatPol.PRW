#include "Rwmake.ch"
#include "Topconn.ch"

/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммямммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  Ё RelFatPol ╨ Autor Ё Cristiano Figueiroa╨ Data Ё 14/05/2009  ╨╠╠
╠╠лммммммммммьмммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Descricao Ё Relatorio de Politica Comercial                             ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Brasitech                                                   ╨╠╠
╠╠хммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/


User Function RelFatPol

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                 Declara as Variaveis Utilizadas na Rotina                  Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Local   aOrd      := {}
Private cbcont    := 00
Private CONTFL    := 01
Private CbTxt     := ""
Private aArea     := GetArea()
Private cPerg     := "RELFATPOLX"
Private nOrdem    := 0
Private tamanho   := "G"
Private limite    := 135
Private cDesc1    := "Este programa irА emitir o Relatorio de Politicas Comerciais"
Private cDesc2    := "conforme os parametros informados pelo usuАrio"
Private aReturn   := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
Private nomeprog  := "POLITIC" 
Private nLastKey  := 0
Private nTipo     := 18
Private m_pag     := 01
Private lContinua := .T.
Private lEnd      := .F.
Private nLin      := 80
Private wnrel     := "POLITIC"
Private cString   := "SZ1"
Private titulo    := "Politica Comercial"
Private cabec1    := "Cliente                                        Vigencia             Valor Minimo   Prz Medio Prz Espec Num Parcelas Num Parcelas E % Desconto % Desc Espec % Desc Distr % Desc Antec %Desc Av7 Incluido Por          Tabela"
Private cabec2    := ""
//                    XXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXX     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   999,999,999.99
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

RptStatus( { || RelFatPola() }, "Aguarde..." ,  "Imprimindo as Politicas Comerciais.." )

Return

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  Ё RelPolComa ╨ Autor Ё Cristiano Figueiroa╨ Data Ё 14/05/2009  ╨╠╠
╠╠лммммммммммьммммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Descricao Ё Rotina de Impressao dos Detalhes das Politicas Comerciais    ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Brasitech                                                    ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/


Static Function RelFatPola

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                 Declara as Variaveis Utilizadas na Rotina                  Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Local   cQuery
Local   lAchei := .F.

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                      Cria Arquivo Temporario                               Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

MontaTrb()

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                      Monta a String contendo a Query                       Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

cQuery := "Select SZ1.Z1_NOME   ,  'Ate ' + Substring( SZ1.Z1_DATAATE , 7 , 2 ) + '/' + Substring( SZ1.Z1_DATAATE , 5 , 2 ) + '/' + Substring( SZ1.Z1_DATAATE , 1 , 4 ) As VIGENCIA ,  "
cQuery += "       SZ1.Z1_VLRMIN , SZ1.Z1_PRAZO   , SZ1.Z1_PRAZOE  ,SZ1.Z1_NUMPAR , SZ1.Z1_NUMPARE , SZ1.Z1_DESCON , SZ1.Z1_DESCONE , SZ1.Z1_DESCDIS , SZ1.Z1_DESCANT , SZ1.Z1_DESCAV7 , SZ1.Z1_DATAATE , SZ1.Z1_CLIENTE , "
cQuery += "       SZ1.Z1_DATA   , SZ1.Z1_USRINC  , SA1.A1_TABELA "

cQuery += " From  " + RetSqlName("SZ1") + " SZ1  , " + RetSqlName("SA1") + " SA1 " 

cQuery += "  Where      SZ1.Z1_CLIENTE BetWeen '" +       MV_PAR01   + "' And '" +       MV_PAR02 + "' "
cQuery += "         And SZ1.Z1_CLIENTE = SA1.A1_COD  "
cQuery += "         And SA1.D_E_L_E_T_ = '' "
cQuery += "         And SZ1.D_E_L_E_T_ = '' "

cQuery += "    Order By SZ1.Z1_CLIENTE , SZ1.Z1_DATAATE "

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                Chama a Funcao que Readequa a Query                         Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

cQuery :=  ChangeQuery( cQuery )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё    Gera a Query em Arquivo Texto para Analises pelo Query Analyser         Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Memowrite("RelFatPol.Sql" , cQuery )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                 Abre o Resultado da Query no Alias QRY                     Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

TcQuery cQuery New Alias "TMP"

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                    Ajusta os Campos Data e Numerico                        Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

TcSetField( "TMP" , "Z1_DATAATE" , "D" , 08 , 0 )
TcSetField( "TMP" , "Z1_DATA"    , "D" , 08 , 0 )
TcSetField( "TMP" , "Z1_VLRMIN"  , "N" , 14 , 2 )
TcSetField( "TMP" , "Z1_DESCON"  , "N" , 05 , 2 )
TcSetField( "TMP" , "Z1_DESCONE" , "N" , 05 , 2 )
TcSetField( "TMP" , "Z1_DESCDIS" , "N" , 05 , 2 )
TcSetField( "TMP" , "Z1_DESCANT" , "N" , 05 , 2 )
TcSetField( "TMP" , "Z1_DESCAV7" , "N" , 05 , 2 )
TcSetField( "TMP" , "Z1_NUMPAR"  , "N" , 03 , 0 )
TcSetField( "TMP" , "Z1_NUMPARE" , "N" , 03 , 0 )
TcSetField( "TMP" , "Z1_PRAZO"   , "N" , 03 , 0 )
TcSetField( "TMP" , "Z1_PRAZOE"  , "N" , 03 , 0 )  

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
    Ё            Filtro para Apresentar Somente as Politicas Vigentes            Ё
    юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

   If MV_PAR03 == 1

   /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
     Ё                   Realiza a Quebra por Cliente                             Ё
     юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

      cCodCliente := TMP->Z1_CLIENTE
      lAchei      := .F.

   /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
     Ё                 Separa Apenas o Vigente para o Cliente                     Ё
     юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
   
      Do While TMP->( !Eof() ) .And. cCodCliente == TMP->Z1_CLIENTE .And. !lAchei

      /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
        Ё            Assim que Encontrar o Primeiro Vigente Sai do Loop              Ё
        юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
   
         If TMP->Z1_DATAATE < dDataBase
            DbSkip()
            Loop
         Else
            lAchei := .T.
         Endif   
            
      Enddo
            
   Endif

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                   Grava os Dados para Planilha Excel                       Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

   DbSelectArea("TMX")
   RecLock("TMX" , .T. )
   TMX->Cliente      := Substr( TMP->Z1_NOME , 1 , 35 )
   TMX->Vigencia     := TMP->Vigencia
   TMX->Vlr_Minimo   := TMP->Z1_VLRMIN  
   TMX->Prz_Medio    := TMP->Z1_PRAZO 
   TMX->Prz_Espec    := TMP->Z1_PRAZOE
   TMX->Num_Parc     := TMP->Z1_NUMPAR
   TMX->Num_Parc_E   := TMP->Z1_NUMPARE
   TMX->Desconto     := TMP->Z1_DESCON 
   TMX->Desc_Espec   := TMP->Z1_DESCONE
   TMX->Desc_Distr   := TMP->Z1_DESCDIS
   TMX->Desc_Antec   := TMP->Z1_DESCANT
   TMX->Desc_AV7     := TMP->Z1_DESCAV7
   TMX->Incluid_Em   := Substr( Dtoc( TMP->Z1_DATA ) , 1 , 2 )+ "/" +Substr( Dtoc( TMP->Z1_DATA ) , 4 , 2 ) + "/" + "20" + Substr( Dtoc( TMP->Z1_DATA ) , 7 , 2)
   TMX->Por          := TMP->Z1_USRINC 
   TMX->Tabela       := TMP->A1_TABELA 
   MsUnlock()

 /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   Ё                   Processa o Proximo Registro                            Ё
   юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

   DbSelectArea("TMP")
   IncRegua()
   DbSkip()
   Loop

Enddo

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                     MV_PAR04 <> 1 - Indica a Impressao                     Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

If MV_PAR04 <> 1

  /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    Ё                     Abre o Arquivo Temporario TMX                          Ё
    юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

   DbSelectArea("TMX")
   DbGoTop()

  /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    Ё                     Monta a Regua de Processamento                         Ё
    юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

   SetRegua( Reccount() )

  /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    Ё                   Processa todo o Arquivo Temporario                       Ё
    юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

   Do While TMX->( !Eof() )
   
  /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    Ё                   Imprime o Cabecalho do Relatorio                         Ё
    юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	
      If nLin > 56
         Cabec( Titulo , Cabec1 , Cabec2 , NomeProg , Tamanho , nTipo )
         nLin := 8
      Endif   

   /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
     Ё                   Imprime os Dados da Politica                             Ё
     юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

      @ nLin , 001 Psay  Substr( TMX->Cliente , 1 , 35 )
      @ nLin , 042 Psay  TMX->Vigencia
      @ nLin , 068 Psay  TMX->Vlr_Minimo  Picture "@E 9,999,999.99" 
      @ nLin , 088 Psay  TMX->Prz_Medio
      @ nLin , 098 Psay  TMX->Prz_Espec
      @ nLin , 107 Psay  TMX->Num_Parc   Picture "@E 999" 
      @ nLin , 119 Psay  TMX->Num_Parc_E Picture "@E 999" 
      @ nLin , 134 Psay  TMX->Desconto   Picture "@E 99.99" 
      @ nLin , 147 Psay  TMX->Desc_Espec Picture "@E 99.99"                      
      @ nLin , 158 Psay  TMX->Desc_Distr Picture "@E 99.99"                      
      @ nLin , 172 Psay  TMX->Desc_Antec Picture "@E 99.99"                      
      @ nLin , 183 Psay  TMX->Desc_AV7   Picture "@E 99.99"                      
      @ nLin , 191 Psay  TMX->Incluid_Em
      @ nLin , 200 Psay  TMX->Por       
      @ nLin , 215 Psay  TMX->Tabela       
      nLin ++

   /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
     Ё                   Processa o Proximo Registro                            Ё
     юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

      IncRegua()
      DbSkip()
      Loop

   Enddo

   Set Device To Screen

   If aReturn[5]==1
      DbCommitAll()
      Set Printer To
      OurSpool(wnrel)
   Endif

   Ms_Flush()
   
Endif   

/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                      Gera o Arquivo em Xls                          Ё
  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

If MV_PAR04 <> 2
   DbSelectArea("TMX")
   cArquivo := "C:\POLITICA.XLS"
   Copy To Politica
   Copy File &("Politica.dbf") To &(cArquivo)
   Aviso( "AtenГЦo !" , "O Arquivo Politica.xls foi gerado no C:\" , {"Ok"} , 1 , "Final de Processo !" )
Endif
  
/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                 Fecha os Arquivos Temporarios                       Ё
  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

If Select("TMP") > 0
   DbSelectArea("TMP")
   DbClosearea()
Endif

/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                 Fecha os Arquivos Temporarios                       Ё
  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

If Select("TMX") > 0
   DbSelectArea("TMX")
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
Local i, j

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё            Adiciona as Perguntas no Array a ser Gravado no SX1             Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/


/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё            Adiciona as Perguntas no Array a ser Gravado no SX1             Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

aAdd( aRegs , { cPerg , "01" , "Do Cliente              ?    " , "            " , "            " , "MV_CH1" , "C" , 08 , 0 , 0 , "G" , "" , "MV_PAR01" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "SA1" , ""})
aAdd( aRegs , { cPerg , "02" , "Ate o Cliente           ?    " , "            " , "            " , "MV_CH2" , "C" , 08 , 0 , 0 , "G" , "" , "MV_PAR02" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "SA1" , ""})
aAdd( aRegs , { cPerg , "03" , "Somente as Vigentes     ?    " , "            " , "            " , "MV_CH3" , "N" , 01 , 0 , 0 , "C" , "" , "MV_PAR03" , "Sim" , "Sim" , "Sim" , "" , "" , "Nao" , "Nao" , "Nao" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , ""})
aAdd( aRegs , { cPerg , "04" , "Modo de Impressao       ?    " , "            " , "            " , "MV_CH4" , "N" , 01 , 0 , 0 , "C" , "" , "MV_PAR04" , "Excel" , "Excel" , "Excel" , "" , "" , "Impressora" , "Impressora" , "Impressora" , "" , "" , "Ambos" , "Ambos" , "Ambos" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , ""})

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