#include "Rwmake.ch"
#include "Topconn.ch"

/*
??????????????????????????????????????????????????????????????????????????????
??????????????????????????????????????????????????????????????????????????????
??????????????????????????????????????????????????????????????????????????ͻ??
???Programa  ? RelFatPol ? Autor ? Cristiano Figueiroa? Data ? 14/05/2009  ???
??????????????????????????????????????????????????????????????????????????͹??
???Descricao ? Relatorio de Politica Comercial                             ???
??????????????????????????????????????????????????????????????????????????͹??
???Uso       ? Brasitech                                                   ???
??????????????????????????????????????????????????????????????????????????ͼ??
??????????????????????????????????????????????????????????????????????????????
??????????????????????????????????????????????????????????????????????????????*/


User Function RelFatPol

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                 Declara as Variaveis Utilizadas na Rotina                  ?
  ??????????????????????????????????????????????????????????????????????????????*/

Local   aOrd      := {}
Private cbcont    := 00
Private CONTFL    := 01
Private CbTxt     := ""
Private aArea     := GetArea()
Private cPerg     := "RELFATPOLX"
Private nOrdem    := 0
Private tamanho   := "G"
Private limite    := 135
Private cDesc1    := "Este programa ir? emitir o Relatorio de Politicas Comerciais"
Private cDesc2    := "conforme os parametros informados pelo usu?rio"
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

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?           Verifica se o Grupo de Perguntas existe ou nao                   ?
  ??????????????????????????????????????????????????????????????????????????????*/

VldPerg( cPerg )

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?               Carrega o Grupo de Perguntas na Tela                         ?
  ??????????????????????????????????????????????????????????????????????????????*/

Pergunte( cPerg , .F. )

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?               Envia Controle para a Funcao SetPrint                        ?
  ??????????????????????????????????????????????????????????????????????????????*/

wnrel := SetPrint( cString , wnrel , cPerg , @Titulo , cDesc1 , cDesc2 , "" , .F. , , .F. )

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?           Verifica o Cancelamento da Impressao dos Pedidos                 ?
  ??????????????????????????????????????????????????????????????????????????????*/

If nLastKey == 27
	Return
Endif

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                                                                            ?
  ??????????????????????????????????????????????????????????????????????????????*/

SetDefault( aReturn , cString )

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                    Imprime o Relatorio de Sugestao                         ?
  ??????????????????????????????????????????????????????????????????????????????*/

RptStatus( { || RelFatPola() }, "Aguarde..." ,  "Imprimindo as Politicas Comerciais.." )

Return

/*
???????????????????????????????????????????????????????????????????????????????
???????????????????????????????????????????????????????????????????????????????
???????????????????????????????????????????????????????????????????????????ͻ??
???Programa  ? RelPolComa ? Autor ? Cristiano Figueiroa? Data ? 14/05/2009  ???
???????????????????????????????????????????????????????????????????????????͹??
???Descricao ? Rotina de Impressao dos Detalhes das Politicas Comerciais    ???
???????????????????????????????????????????????????????????????????????????͹??
???Uso       ? Brasitech                                                    ???
???????????????????????????????????????????????????????????????????????????ͼ??
???????????????????????????????????????????????????????????????????????????????
???????????????????????????????????????????????????????????????????????????????*/


Static Function RelFatPola

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                 Declara as Variaveis Utilizadas na Rotina                  ?
  ??????????????????????????????????????????????????????????????????????????????*/

Local   cQuery
Local   lAchei := .F.

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                      Cria Arquivo Temporario                               ?
  ??????????????????????????????????????????????????????????????????????????????*/

MontaTrb()

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                      Monta a String contendo a Query                       ?
  ??????????????????????????????????????????????????????????????????????????????*/

cQuery := "Select SZ1.Z1_NOME   ,  'Ate ' + Substring( SZ1.Z1_DATAATE , 7 , 2 ) + '/' + Substring( SZ1.Z1_DATAATE , 5 , 2 ) + '/' + Substring( SZ1.Z1_DATAATE , 1 , 4 ) As VIGENCIA ,  "
cQuery += "       SZ1.Z1_VLRMIN , SZ1.Z1_PRAZO   , SZ1.Z1_PRAZOE  ,SZ1.Z1_NUMPAR , SZ1.Z1_NUMPARE , SZ1.Z1_DESCON , SZ1.Z1_DESCONE , SZ1.Z1_DESCDIS , SZ1.Z1_DESCANT , SZ1.Z1_DESCAV7 , SZ1.Z1_DATAATE , SZ1.Z1_CLIENTE , "
cQuery += "       SZ1.Z1_DATA   , SZ1.Z1_USRINC  , SA1.A1_TABELA "

cQuery += " From  " + RetSqlName("SZ1") + " SZ1  , " + RetSqlName("SA1") + " SA1 " 

cQuery += "  Where      SZ1.Z1_CLIENTE BetWeen '" +       MV_PAR01   + "' And '" +       MV_PAR02 + "' "
cQuery += "         And SZ1.Z1_CLIENTE = SA1.A1_COD  "
cQuery += "         And SA1.D_E_L_E_T_ = '' "
cQuery += "         And SZ1.D_E_L_E_T_ = '' "

cQuery += "    Order By SZ1.Z1_CLIENTE , SZ1.Z1_DATAATE "

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                Chama a Funcao que Readequa a Query                         ?
  ??????????????????????????????????????????????????????????????????????????????*/

cQuery :=  ChangeQuery( cQuery )

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?    Gera a Query em Arquivo Texto para Analises pelo Query Analyser         ?
  ??????????????????????????????????????????????????????????????????????????????*/

Memowrite("RelFatPol.Sql" , cQuery )

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                 Abre o Resultado da Query no Alias QRY                     ?
  ??????????????????????????????????????????????????????????????????????????????*/

TcQuery cQuery New Alias "TMP"

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                    Ajusta os Campos Data e Numerico                        ?
  ??????????????????????????????????????????????????????????????????????????????*/

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

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                     Abre o Arquivo Temporario RDF                          ?
  ??????????????????????????????????????????????????????????????????????????????*/

DbSelectArea("TMP")
DbGoTop()

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                     Monta a Regua de Processamento                         ?
  ??????????????????????????????????????????????????????????????????????????????*/

SetRegua( Reccount() )

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                   Processa todo o Arquivo Temporario                       ?
  ??????????????????????????????????????????????????????????????????????????????*/

Do While TMP->( !Eof() )

  /*????????????????????????????????????????????????????????????????????????????Ŀ
    ?            Filtro para Apresentar Somente as Politicas Vigentes            ?
    ??????????????????????????????????????????????????????????????????????????????*/

   If MV_PAR03 == 1

   /*????????????????????????????????????????????????????????????????????????????Ŀ
     ?                   Realiza a Quebra por Cliente                             ?
     ??????????????????????????????????????????????????????????????????????????????*/

      cCodCliente := TMP->Z1_CLIENTE
      lAchei      := .F.

   /*????????????????????????????????????????????????????????????????????????????Ŀ
     ?                 Separa Apenas o Vigente para o Cliente                     ?
     ??????????????????????????????????????????????????????????????????????????????*/
   
      Do While TMP->( !Eof() ) .And. cCodCliente == TMP->Z1_CLIENTE .And. !lAchei

      /*????????????????????????????????????????????????????????????????????????????Ŀ
        ?            Assim que Encontrar o Primeiro Vigente Sai do Loop              ?
        ??????????????????????????????????????????????????????????????????????????????*/
   
         If TMP->Z1_DATAATE < dDataBase
            DbSkip()
            Loop
         Else
            lAchei := .T.
         Endif   
            
      Enddo
            
   Endif

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                   Grava os Dados para Planilha Excel                       ?
  ??????????????????????????????????????????????????????????????????????????????*/

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

 /*??????????????????????????????????????????????????????????????????????????Ŀ
   ?                   Processa o Proximo Registro                            ?
   ????????????????????????????????????????????????????????????????????????????*/

   DbSelectArea("TMP")
   IncRegua()
   DbSkip()
   Loop

Enddo

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                     MV_PAR04 <> 1 - Indica a Impressao                     ?
  ??????????????????????????????????????????????????????????????????????????????*/

If MV_PAR04 <> 1

  /*????????????????????????????????????????????????????????????????????????????Ŀ
    ?                     Abre o Arquivo Temporario TMX                          ?
    ??????????????????????????????????????????????????????????????????????????????*/

   DbSelectArea("TMX")
   DbGoTop()

  /*????????????????????????????????????????????????????????????????????????????Ŀ
    ?                     Monta a Regua de Processamento                         ?
    ??????????????????????????????????????????????????????????????????????????????*/

   SetRegua( Reccount() )

  /*????????????????????????????????????????????????????????????????????????????Ŀ
    ?                   Processa todo o Arquivo Temporario                       ?
    ??????????????????????????????????????????????????????????????????????????????*/

   Do While TMX->( !Eof() )
   
  /*????????????????????????????????????????????????????????????????????????????Ŀ
    ?                   Imprime o Cabecalho do Relatorio                         ?
    ??????????????????????????????????????????????????????????????????????????????*/
	
      If nLin > 56
         Cabec( Titulo , Cabec1 , Cabec2 , NomeProg , Tamanho , nTipo )
         nLin := 8
      Endif   

   /*????????????????????????????????????????????????????????????????????????????Ŀ
     ?                   Imprime os Dados da Politica                             ?
     ??????????????????????????????????????????????????????????????????????????????*/

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

   /*??????????????????????????????????????????????????????????????????????????Ŀ
     ?                   Processa o Proximo Registro                            ?
     ????????????????????????????????????????????????????????????????????????????*/

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

/*?????????????????????????????????????????????????????????????????????Ŀ
  ?                      Gera o Arquivo em Xls                          ?
  ???????????????????????????????????????????????????????????????????????*/

If MV_PAR04 <> 2
   DbSelectArea("TMX")
   cArquivo := "C:\POLITICA.XLS"
   Copy To Politica
   Copy File &("Politica.dbf") To &(cArquivo)
   Aviso( "Aten??o !" , "O Arquivo Politica.xls foi gerado no C:\" , {"Ok"} , 1 , "Final de Processo !" )
Endif
  
/*?????????????????????????????????????????????????????????????????????Ŀ
  ?                 Fecha os Arquivos Temporarios                       ?
  ???????????????????????????????????????????????????????????????????????*/

If Select("TMP") > 0
   DbSelectArea("TMP")
   DbClosearea()
Endif

/*?????????????????????????????????????????????????????????????????????Ŀ
  ?                 Fecha os Arquivos Temporarios                       ?
  ???????????????????????????????????????????????????????????????????????*/

If Select("TMX") > 0
   DbSelectArea("TMX")
   DbClosearea()
Endif

Return

/*
??????????????????????????????????????????????????????????????????????????????
??????????????????????????????????????????????????????????????????????????????
??????????????????????????????????????????????????????????????????????????ͻ??
???Programa  ?ValidPerg ? Autor ? Analistas Microsiga ? Data ? 14/04/2009  ???
??????????????????????????????????????????????????????????????????????????͹??
???Descricao ? Cria o Grupo de Perguntas conforme Parametro                ???
??????????????????????????????????????????????????????????????????????????͹??
???Uso       ? DeNadai                                                     ???
??????????????????????????????????????????????????????????????????????????ͼ??
??????????????????????????????????????????????????????????????????????????????
??????????????????????????????????????????????????????????????????????????????
*/

Static Function VldPerg( cPerg )

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?            Declara as Variaveis Locais Utilizadas na Rotina                ?
  ??????????????????????????????????????????????????????????????????????????????*/

Local aRegs := {}
Local i, j

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?            Adiciona as Perguntas no Array a ser Gravado no SX1             ?
  ??????????????????????????????????????????????????????????????????????????????*/


/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?            Adiciona as Perguntas no Array a ser Gravado no SX1             ?
  ??????????????????????????????????????????????????????????????????????????????*/

aAdd( aRegs , { cPerg , "01" , "Do Cliente              ?    " , "            " , "            " , "MV_CH1" , "C" , 08 , 0 , 0 , "G" , "" , "MV_PAR01" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "SA1" , ""})
aAdd( aRegs , { cPerg , "02" , "Ate o Cliente           ?    " , "            " , "            " , "MV_CH2" , "C" , 08 , 0 , 0 , "G" , "" , "MV_PAR02" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "SA1" , ""})
aAdd( aRegs , { cPerg , "03" , "Somente as Vigentes     ?    " , "            " , "            " , "MV_CH3" , "N" , 01 , 0 , 0 , "C" , "" , "MV_PAR03" , "Sim" , "Sim" , "Sim" , "" , "" , "Nao" , "Nao" , "Nao" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , ""})
aAdd( aRegs , { cPerg , "04" , "Modo de Impressao       ?    " , "            " , "            " , "MV_CH4" , "N" , 01 , 0 , 0 , "C" , "" , "MV_PAR04" , "Excel" , "Excel" , "Excel" , "" , "" , "Impressora" , "Impressora" , "Impressora" , "" , "" , "Ambos" , "Ambos" , "Ambos" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , ""})

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?            Verifica se Ja Existe Registro no SX1 e Grava                   ?
  ??????????????????????????????????????????????????????????????????????????????*/

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
??????????????????????????????????????????????????????????????????????????????
??????????????????????????????????????????????????????????????????????????????
??????????????????????????????????????????????????????????????????????????ͻ??
???Programa  ? MontaTrb ? Autor ? Cristiano Figueiroa ? Data ? 21/05/2009  ???
??????????????????????????????????????????????????????????????????????????͹??
???Descricao ? Monta o Arquivo Temporario para Importacao dos Dados        ???
??????????????????????????????????????????????????????????????????????????͹??
???Uso       ? Brasitech                                                   ???
??????????????????????????????????????????????????????????????????????????ͼ??
??????????????????????????????????????????????????????????????????????????????
??????????????????????????????????????????????????????????????????????????????
*/

Static Function MontaTrb()

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                    Declara as variaveis utilizadas                         ?
  ??????????????????????????????????????????????????????????????????????????????*/

Local aFile1 := {}
Local aFile2 := {}

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                Monta a Estrutura dos Arquivos Temporarios                  ?   
  ??????????????????????????????????????????????????????????????????????????????*/

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

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                      Cria area Temporaria no Sistema                       ?
  ??????????????????????????????????????????????????????????????????????????????*/

cFile1 := CriaTrab( aFile1 )   // Arquivo de Trabalho

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                     Cria o Arquivo Temporario no Sistema                   ?
  ??????????????????????????????????????????????????????????????????????????????*/

DbUseArea(.T. , , cFile1 , "TMX" , .T. )  // Arquivo de Produto

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                     Cria o Indice Temporario no Sistema                    ?
  ??????????????????????????????????????????????????????????????????????????????*/

IndRegua("TMX" , cFile1 , "Str(100 - Desconto) + Cliente"   ,,, "Criando Arquivo...")  

Return