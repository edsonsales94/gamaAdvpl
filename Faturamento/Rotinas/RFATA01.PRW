#Include "Protheus.ch"
#Include "Rwmake.ch"

/*/
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????ͻ??
???Programa  ? RFata01  ? Autor ?Cristiano Figueiroa ? Data ? 18/02/2009  ???
?????????????????????????????????????????????????????????????????????????͹??
???Descricao ? Tela de Manutencao nas Politicas Comerciais                ???
?????????????????????????????????????????????????????????????????????????͹??
???Uso       ? Brasitech ( Gama Italy )                                   ???
?????????????????????????????????????????????????????????????????????????ͼ??
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
/*/

User Function RFata01

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Atribui o codigo do cliente atual a variavel _cCodCli               ?
  ???????????????????????????????????????????????????????????????????????*/

Public cCodCli := SA1->A1_COD

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Declaracao de Variaveis                                             ?
  ??????????????????????????????????????????????????????????????????????? */

Private cCadastro := "Configura??o da Politica Comercial"

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Array (tambem deve ser aRotina sempre) com as definicoes das opcoes ?
  ? que apareceram disponiveis para o usuario. Segue o padrao:          ?
  ? aRotina := { {<DESCRICAO>,<ROTINA>,0,<TIPO>},;                      ?
  ?              {<DESCRICAO>,<ROTINA>,0,<TIPO>},;                      ?
  ?              . . .                                                  ?
  ?              {<DESCRICAO>,<ROTINA>,0,<TIPO>} }                      ?
  ? Onde: <DESCRICAO> - Descricao da opcao do menu                      ?
  ?       <ROTINA>    - Rotina a ser executada. Deve estar entre aspas  ?
  ?                     duplas e pode ser uma das funcoes pre-definidas ?
  ?                     do sistema (AXPESQUI,AXVISUAL,AXINCLUI,AXALTERA ?
  ?                     e AXDELETA) ou a chamada de um EXECBLOCK.       ?
  ?                     Obs.: Se utilizar a funcao AXDELETA, deve-se de-?
  ?                     clarar uma variavel chamada CDELFUNC contendo   ?
  ?                     uma expressao logica que define se o usuario po-?
  ?                     dera ou nao excluir o registro, por exemplo:    ?
  ?                     cDelFunc := 'ExecBlock("TESTE")'  ou            ?
  ?                     cDelFunc := ".T."                               ?
  ?                     Note que ao se utilizar chamada de EXECBLOCKs,  ?
  ?                     as aspas simples devem estar SEMPRE por fora da ?
  ?                     sintaxe.                                        ?
  ?       <TIPO>      - Identifica o tipo de rotina que sera executada. ?
  ?                     Por exemplo, 1 identifica que sera uma rotina de?
  ?                     pesquisa, portando alteracoes nao podem ser efe-?
  ?                     tuadas. 3 indica que a rotina e de inclusao, por?
  ?                     tanto, a rotina sera chamada continuamente ao   ?
  ?                     final do processamento, ate o pressionamento de ?
  ?                     <ESC>. Geralmente ao se usar uma chamada de     ?
  ?                     EXECBLOCK, usa-se o tipo 4, de alteracao.       ?
  ???????????????????????????????????????????????????????????????????????*/

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? aRotina padrao. Utilizando a declaracao a seguir, a execucao da     ?
  ? MBROWSE sera identica a da AXCADASTRO:                              ?
  ?                                                                     ?
  ? cDelFunc  := ".T."                                                  ?
  ? aRotina   := { { "Pesquisar"    ,"AxPesqui" , 0, 1},;               ?
  ?                { "Visualizar"   ,"AxVisual" , 0, 2},;               ?
  ?                { "Incluir"      ,"AxInclui" , 0, 3},;               ?
  ?                { "Alterar"      ,"AxAltera" , 0, 4},;               ?
  ?                { "Excluir"      ,"AxDeleta" , 0, 5} }               ?
  ?                                                                     ?
  ???????????????????????????????????????????????????????????????????????*/

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Monta um aRotina proprio                                            ?
  ???????????????????????????????????????????????????????????????????????*/

Private aRotina  := { {"Pesquisar"  ,"AxPesqui"             , 0 , 1 } ,;
                       {"Visualizar" ,"AxVisual"             , 0 , 2 } ,;
                       {"Incluir"    ,'ExecBlock("INCPOL")'  , 0 , 3 } ,;
                       {"Alterar"    ,'ExecBlock("ALTPOL")'  , 0 , 4 } ,;
                       {"Excluir"    ,"AxDeleta"             , 0 , 5 } ,;
                       {"Log"        ,'ExecBlock("LOGPOL")'  , 0 , 2 } ,;
                       {"Legenda"    ,'Execblock("LEGEPOL")' , 0 , 2 }}

Private cDelFunc := ".T."  // Validacao para a exclusao. Pode-se utilizar ExecBlock

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Abre a Tabela de Politica Comercial                                 ?
  ???????????????????????????????????????????????????????????????????????*/

DbSelectArea("SZ1")
DbSetOrder(1)

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Filtra o Cliente de acordo com o Cliente selecionado na amarracao   ?
  ???????????????????????????????????????????????????????????????????????*/

If Alltrim( Funname() ) == "MATA030"
   Set Filter to SZ1->Z1_CLIENTE  == cCodCli
Endif   

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Variavel que definira as cores do browse                            ?
  ???????????????????????????????????????????????????????????????????????*/

Private aCores  := {} 

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Array com as cores do browse                                        ?
  ???????????????????????????????????????????????????????????????????????*/

Aadd( aCores , { "Dtos(Z1_DATAATE) >= Dtos(dDataBase)" , "BR_VERDE"    } )  // Politica Comercial Ativa
Aadd( aCores , { "Dtos(Z1_DATAATE) <  Dtos(dDataBase)" , "BR_VERMELHO" } )  // Politica Comercial Fora da Vigencia


/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Executa a funcao MBROWSE. Sintaxe:                                  ?
  ?                                                                     ?
  ? mBrowse(<nLin1,nCol1,nLin2,nCol2,Alias,aCampos,cCampo)              ?
  ? Onde: nLin1,...nCol2 - Coordenadas dos cantos aonde o browse sera   ?
  ?                        exibido. Para seguir o padrao da AXCADASTRO  ?
  ?                        use sempre 6,1,22,75 (o que nao impede de    ?
  ?                        criar o browse no lugar desejado da tela).   ?
  ?                        Obs.: Na versao Windows, o browse sera exibi-?
  ?                        do sempre na janela ativa. Caso nenhuma este-?
  ?                        ja ativa no momento, o browse sera exibido na?
  ?                        janela do proprio SIGAADV.                   ?
  ? Alias                - Alias do arquivo a ser "Browseado".          ?
  ? aCampos              - Array multidimensional com os campos a serem ?
  ?                        exibidos no browse. Se nao informado, os cam-?
  ?                        pos serao obtidos do dicionario de dados.    ?
  ?                        E util para o uso com arquivos de trabalho.  ?
  ?                        Segue o padrao:                              ?
  ?                        aCampos := { {<CAMPO>,<DESCRICAO>},;         ?
  ?                                     {<CAMPO>,<DESCRICAO>},;         ?
  ?                                     . . .                           ?
  ?                                     {<CAMPO>,<DESCRICAO>} }         ?
  ?                        Como por exemplo:                            ?
  ?                        aCampos := { {"TRB_DATA","Data  "},;         ?
  ?                                     {"TRB_COD" ,"Codigo"} }         ?
  ? cCampo               - Nome de um campo (entre aspas) que sera usado?
  ?                        como "flag". Se o campo estiver vazio, o re- ?
  ?                        gistro ficara de uma cor no browse, senao fi-?
  ?                        cara de outra cor.                           ?
  ???????????????????????????????????????????????????????????????????????*/

MBrowse( 6 , 1 , 22 , 75 , "SZ1" , , , , , , aCores )

Return
                      
/*
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????ͻ??
???Programa  ? LegePol  ? Autor ?Cristiano Figueiroa ? Data ? 18/02/2009  ???
?????????????????????????????????????????????????????????????????????????͹??
???Descricao ? Exibe a Legenda na tela de Politica Comercial              ???
?????????????????????????????????????????????????????????????????????????͹??
???Uso       ? Brasitech ( Gama Italy )                                   ???
?????????????????????????????????????????????????????????????????????????ͼ??
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
*/

User Function LegePol( cAlias , nRecno , cOpcao )

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                 Declara as Variaveis Utilizadas na Rotina                  ?
  ??????????????????????????????????????????????????????????????????????????????*/

Local aLegenda := {}

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                    Efetua a Carga do Array de Legendas                     ?
  ??????????????????????????????????????????????????????????????????????????????*/

Aadd( aLegenda , {"BR_VERDE"   , "Politica Ativa"             })
Aadd( aLegenda , {"BR_VERMELHO", "Politica Fora da Vigencia"  })

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                              Monta Legenda                                 ?
  ??????????????????????????????????????????????????????????????????????????????*/

BrwLegenda( cCadastro , OemToAnsi("Legendas") , aLegenda )

Return

/*
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????ͻ??
???Programa  ?  RetSeq  ? Autor ?Cristiano Figueiroa ? Data ? 16/02/2009  ???
?????????????????????????????????????????????????????????????????????????͹??
???Descricao ? Retorna o Sequencial da Politica Comercial                 ???
?????????????????????????????????????????????????????????????????????????͹??
???Uso       ? Brasitech ( Gama Italy )                                   ???
?????????????????????????????????????????????????????????????????????????ͼ??
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
*/

User Function RetSeq( cCodCli , cLojCli ) // Funcao Desativada Apos Alteracoes na Politica

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Declara as Variaveis da Rotina                                      ?
  ???????????????????????????????????????????????????????????????????????*/

Private cSequencia := "001"  

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Abre a Tabela de Politica Comercial                                 ?
  ???????????????????????????????????????????????????????????????????????*/

DbSelectArea("SZ1")
DbSetOrder(1)         // Filial + Cliente + Loja + Sequencial

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Adiciona 1 no Sequencial da Politica Comercial                      ?
  ???????????????????????????????????????????????????????????????????????*/

If DbSeek ( xFilial("SZ1") + cCodCli + cLojCli )
   Do While SZ1->( !Eof() ) .And. SZ1->Z1_CLIENTE == cCodCli .And. SZ1->Z1_LOJA == cLojCli
      cSequencia := Soma1( SZ1->Z1_SEQ) 
      DbSkip()
   Enddo
Endif   

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Atribui o Numero Sequencial a Variavel                              ?
  ???????????????????????????????????????????????????????????????????????*/

If Inclui
   M->Z1_SEQ  := cSequencia
Else
   cSequencia := SZ1->Z1_SEQ
Endif   

Return cSequencia

/*
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????ͻ??
???Programa  ?  VerVig  ? Autor ?Cristiano Figueiroa ? Data ? 16/02/2009  ???
?????????????????????????????????????????????????????????????????????????͹??
???Descricao ? Verifica a Vigencia da Politica Comercial                  ???
?????????????????????????????????????????????????????????????????????????͹??
???Uso       ? Brasitech ( Gama Italy )                                   ???
?????????????????????????????????????????????????????????????????????????ͼ??
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
*/

User Function VerVig( cCodCli , cLojCli , cSeqPol , dDatade , dDataate ) // Funcao Desativada Apos Alteracoes na Politica

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Declara as Variaveis da Rotina                                      ?
  ???????????????????????????????????????????????????????????????????????*/

Local lRet    := .T.
Local nQtdReg := 0

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Abre a Tabela de Politica Comercial                                 ?
  ???????????????????????????????????????????????????????????????????????*/

DbSelectArea("SZ1")
DbSetOrder(1)         // Filial + Cliente + Loja + Sequencial

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Posiciona na Politica Comercial do Cliente                          ?
  ???????????????????????????????????????????????????????????????????????*/

If DbSeek ( xFilial("SZ1") + cCodCli + cLojCli )

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Verifica a Faixa de Datas e Armazena as Datas da Politica Comercial ?
  ???????????????????????????????????????????????????????????????????????*/

   Do While SZ1->( !Eof() ) .And. SZ1->Z1_CLIENTE == cCodCli .And. SZ1->Z1_LOJA == cLojCli

   /*?????????????????????????????????????????????????????????????????????Ŀ
     ?                Retira a Vigencia das Demais Politicas               ?
     ???????????????????????????????????????????????????????????????????????*/

      If SZ1->Z1_SEQ <> cSeqPol

         Aviso( "Aten??o !" , "A Vigencia das Politicas Comerciais j? existentes para este Cliente ser?o alteradas para : " + DtoC( dDatade - 1 ) + ". Desta forma apenas a Pol?tica que voc? acabou de cadastrar estar? Vigente !", {"Ok"} , 1 , "Altera??o de Vigencia ! " )
         lRet := .F.
         
      /*?????????????????????????????????????????????????????????????????????Ŀ
        ?           Ajusta a Data de Vigencia das Politicas Existentes        ?
        ???????????????????????????????????????????????????????????????????????*/
         
         RecLock("SZ1" , .F. )
         SZ1->Z1_DATADE  := dDatade - 1
         SZ1->Z1_DATAATE := dDatade - 1
         MsUnlock()
         
      Endif            

   /*?????????????????????????????????????????????????????????????????????Ŀ
     ? Trata a Sequencia Inicial e Final , Ignorando a Atual               ?
     ???????????????????????????????????????????????????????????????????????*/

      DbSkip()

   Enddo

Endif

Return lRet
/*
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????ͻ??
???Programa  ? VldPrzEsp? Autor ?Cristiano Figueiroa ? Data ? 19/02/2009  ???
?????????????????????????????????????????????????????????????????????????͹??
???Descricao ?Verifica se o Prazo Medio Especial e Maior que o Prazo Medio???
?????????????????????????????????????????????????????????????????????????͹??
???Uso       ? Brasitech ( Gama Italy )                                   ???
?????????????????????????????????????????????????????????????????????????ͼ??
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
*/

User Function VldPrzEsp()

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Declara as Variaveis da Rotina                                      ?
  ???????????????????????????????????????????????????????????????????????*/

Local lRet := .T.

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Valida o Prazo Medio Especial Digitado                              ?
  ???????????????????????????????????????????????????????????????????????*/

If !Empty( M->Z1_PRAZOE )
   If M->Z1_PRAZO >= M->Z1_PRAZOE
      Aviso( "Aten??o !" , "O Prazo Medio Especial somente poder? ser maior que o Prazo M?dio. Informe um Prazo Medio Especial maior que o Prazo M?dio !" , {"Ok"} , 1 , "Prazo M?dio Inv?lido ! " )
      lRet := .F.
   Endif
Endif   

Return lRet

/*
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????ͻ??
???Programa  ? VldParEsp? Autor ?Cristiano Figueiroa ? Data ? 19/02/2009  ???
?????????????????????????????????????????????????????????????????????????͹??
???Descricao ?Verifica se a Parcela Especial e Maior que a Parcela        ???
?????????????????????????????????????????????????????????????????????????͹??
???Uso       ? Brasitech ( Gama Italy )                                   ???
?????????????????????????????????????????????????????????????????????????ͼ??
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
*/

User Function VldParEsp()

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Declara as Variaveis da Rotina                                      ?
  ???????????????????????????????????????????????????????????????????????*/

Local lRet := .T.

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Valida o Prazo Medio Especial Digitado                              ?
  ???????????????????????????????????????????????????????????????????????*/

If !Empty( M->Z1_NUMPARE )
   If M->Z1_NUMPAR >= M->Z1_NUMPARE
      Aviso( "Aten??o !" , "O Numero de Parcelas Especiais somente poder? ser maior o Numero de Parcelas. Informe um Numero de Parcelas Especiais maior que o Numero de Parcelas !" , {"Ok"} , 1 , "Numero de Parcelas Inv?lido ! " )
      lRet := .F.
   Endif
Endif   

Return lRet

/*
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????ͻ??
???Programa  ? VldDesEsp? Autor ?Cristiano Figueiroa ? Data ? 19/02/2009  ???
?????????????????????????????????????????????????????????????????????????͹??
???Descricao ?Verifica se o Desconto Especial e Maior que a Desconto      ???
?????????????????????????????????????????????????????????????????????????͹??
???Uso       ? Brasitech ( Gama Italy )                                   ???
?????????????????????????????????????????????????????????????????????????ͼ??
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
*/

User Function VldDesEsp()

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Declara as Variaveis da Rotina                                      ?
  ???????????????????????????????????????????????????????????????????????*/

Local lRet := .T.

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Valida o Prazo Medio Especial Digitado                              ?
  ???????????????????????????????????????????????????????????????????????*/

If !Empty( M->Z1_DESCONE )
   If M->Z1_DESCON >= M->Z1_DESCONE
      Aviso( "Aten??o !" , "O Percentual de Descontos Especial somente poder? ser maior o Percentual de Desconto. Informe um Percentual de Desconto Especial maior que o Percentual de Desconto !" , {"Ok"} , 1 , "Desconto Inv?lido ! " )
      lRet := .F.
   Endif
Endif   

Return lRet

/*
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????ͻ??
???Programa  ?  AltPol  ? Autor ?Cristiano Figueiroa ? Data ? 29/04/2009  ???
?????????????????????????????????????????????????????????????????????????͹??
???Descricao ? Tela de Alteracao da Politica Comercial                    ???
?????????????????????????????????????????????????????????????????????????͹??
???Uso       ? Brasitech ( Gama Italy )                                   ???
?????????????????????????????????????????????????????????????????????????ͼ??
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
*/

User Function AltPol()

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Chama a Rotina de Alteracao Padrao                                  ?
  ???????????????????????????????????????????????????????????????????????*/

AxAltera( "SZ1" , SZ1->( Recno() ) , 4 )                          

/*?????????????????????????????????????????????????????????????????????Ŀ
  ?                  Altera as Vigencias Anteriores                     ?
  ???????????????????????????????????????????????????????????????????????*/

// u_VerVig( SZ1->Z1_CLIENTE , SZ1->Z1_LOJA , SZ1->Z1_SEQ , SZ1->Z1_DATADE , SZ1->Z1_DATAATE )

/*?????????????????????????????????????????????????????????????????????Ŀ
  ?                  Abre a Tabela Generica do Sistema                  ?
  ???????????????????????????????????????????????????????????????????????*/

DbSelectArea("SZ7")
DbSetOrder(1)

/*?????????????????????????????????????????????????????????????????????Ŀ
  ?                  Grava o Log de Alteracao do Sistema                ?
  ???????????????????????????????????????????????????????????????????????*/

RecLock("SZ7" , .T. )
SZ7->Z7_CODCLI := SZ1->Z1_CLIENTE
SZ7->Z7_LOG    := "Pol?tica Alterada pelo Usu?rio : " + Substring ( cUsuario , 7 , 15 ) + " em " + DtoC ( MsDate() ) + " as " + Time()
MsUnlock()

Return 

/*
????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????ͻ??
???Programa  ?  LogPol  ? Autor ?Cristiano Figueiroa ? Data ? 29/04/2009 ???
????????????????????????????????????????????????????????????????????????͹??
???Descricao ? Lista o Log da Politica Comercial do Cliente              ???
????????????????????????????????????????????????????????????????????????͹??
???Uso       ? Brasitech ( Gama Italy )                                  ???
????????????????????????????????????????????????????????????????????????ͼ??
????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????
*/

User Function LogPol

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Declara as Variaveis da Rotina                                      ?
  ???????????????????????????????????????????????????????????????????????*/

Local aArea    := GetArea()
Local oDlg     := Nil
Local oLbx     := Nil
Local cTitulo  := "Log da Pol?tica Comercial"
Private nChave   := 0
Private cChave   := ""
Private aVetor   := {}                                                  

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Atribui as Variaveis caso a Rotina seja Cadastro de Clientes        ?
  ???????????????????????????????????????????????????????????????????????*/

cCliePol := SZ1->Z1_CLIENTE

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Abre a Tabela Generica do Log da Politica Comercial                 ?
  ???????????????????????????????????????????????????????????????????????*/

DbSelectArea("SZ7")
DbSetOrder(1)
DbGotop()

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Posiciona na Tabela Generica do Log da Politica Comercial do Cliente?
  ???????????????????????????????????????????????????????????????????????*/

If !( DbSeek ( xFilial("SZ7") + cCliePol ) )
   Aviso( "Log da Politica Comercial ", "Nao existe Log Registrado para essa Politica Comercial  !", {"Ok"} )
   Return
Endif

CursorWait()

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Carrega o Vetor com os Dados do Log da Politica Comercial           ?
  ???????????????????????????????????????????????????????????????????????*/

Do While SZ7->( !Eof() ) .And. SZ7->Z7_CODCLI == cCliePol

 /*?????????????????????????????????????????????????????????????????????Ŀ
   ?             Seleciona os Logs Referentes ao Cliente                 ?
   ???????????????????????????????????????????????????????????????????????*/

   aAdd( aVetor , SZ7->Z7_LOG )
   
   DbSkip()

Enddo

CursorArrow()

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Verifica se h? dados da Politica                                    ?
  ???????????????????????????????????????????????????????????????????????*/

If Len( aVetor ) == 0
   Aviso( "Log da Politica Comercial ", "Nao existe Log Registrado para essa Politica Comercial  !", {"Ok"} )
   Return
Endif

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Monta Tela para o Usuario Visualizar a Politica                     ?
  ???????????????????????????????????????????????????????????????????????*/

Define MsDialog oDlg Title cTitulo From 0,0 To 240,500 Pixel

@ 10 , 10 ListBox oLbx Var nChave Items aVetor Size 230,95 Of oDlg Pixel
oLbx:bChange := {|| cChave := SubStr ( aVetor [nChave] , 1 , 11 ) }

Define SButton From 107,213 Type  1 Action oDlg:End() Enable Of oDlg

Activate MsDialog oDlg Center

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Restaura o Posicionamento dos Arquivos antes de Executar a Rotina   ?
  ???????????????????????????????????????????????????????????????????????*/

RestArea( aArea )

Return .T.

/*
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????ͻ??
???Programa  ?  IncPol  ? Autor ?Cristiano Figueiroa ? Data ? 04/05/2009  ???
?????????????????????????????????????????????????????????????????????????͹??
???Descricao ? Tela de Inclusao da Politica Comercial                     ???
?????????????????????????????????????????????????????????????????????????͹??
???Uso       ? Brasitech ( Gama Italy )                                   ???
?????????????????????????????????????????????????????????????????????????ͼ??
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
*/

User Function IncPol()

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Chama a Rotina de Inclusao Padrao                                   ?
  ???????????????????????????????????????????????????????????????????????*/

AxInclui( "SZ1" , 0 , 3 )

/*?????????????????????????????????????????????????????????????????????Ŀ
  ?                  Verifica inconsistencia na Vigencia                ?
  ???????????????????????????????????????????????????????????????????????*/

/*If SZ1->Z1_DATADE > SZ1->Z1_DATAATE
   Aviso( "Aten??o !" , "Voc? informou uma Data de Vigencia Inicial Maior que a Data de Vigencia Final ! A Data de Vigencia Inicial ser? alterada para a mesma Data da Vigencia Final ! ", {"Ok"} , 1 , "Vigencia Inicial Maior que Final ! " )
   RecLock("SZ1" , .F. )
   SZ1->Z1_DATADE  := SZ1->Z1_DATAATE
   MsUnlock()
Endif   */

/*?????????????????????????????????????????????????????????????????????Ŀ
  ?                  Abre a Tabela Generica do Sistema                  ?
  ???????????????????????????????????????????????????????????????????????*/

DbSelectArea("SZ7")
DbSetOrder(1)

/*?????????????????????????????????????????????????????????????????????Ŀ
  ?                  Grava o Log de Alteracao do Sistema                ?
  ???????????????????????????????????????????????????????????????????????*/

RecLock("SZ7" , .T. )
SZ7->Z7_CODCLI := SZ1->Z1_CLIENTE
SZ7->Z7_LOG    := "Pol?tica Incluida pelo Usu?rio : " + Substring ( cUsuario , 7 , 15 ) + " em " + DtoC ( MsDate() ) + " as " + Time()
MsUnlock()

/*?????????????????????????????????????????????????????????????????????Ŀ
  ?                  Altera as Vigencias Anteriores                     ?
  ???????????????????????????????????????????????????????????????????????*/

// u_VerVig( SZ1->Z1_CLIENTE , SZ1->Z1_LOJA , SZ1->Z1_SEQ , SZ1->Z1_DATADE , SZ1->Z1_DATAATE ) // 

Return                 

/*
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????ͻ??
???Programa  ? VldExPol ? Autor ?Cristiano Figueiroa ? Data ? 04/05/2009  ???
?????????????????????????????????????????????????????????????????????????͹??
???Descricao ? Verifica se ja existe Politica para o Cliente              ???
?????????????????????????????????????????????????????????????????????????͹??
???Uso       ? Brasitech ( Gama Italy )                                   ???
?????????????????????????????????????????????????????????????????????????ͼ??
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
*/

User Function VldExPol( cCli , dDataAte )

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Chama a Rotina de Inclusao Padrao                                   ?
  ???????????????????????????????????????????????????????????????????????*/

Local lRet := .T.

/*?????????????????????????????????????????????????????????????????????Ŀ
  ? Abre a Tabela de Politica Comercial                                 ?
  ???????????????????????????????????????????????????????????????????????*/

DbSelectArea("SZ1")
DbSetOrder(1)         // Filial + Cliente + Data Ate

/*?????????????????????????????????????????????????????????????????????Ŀ
  ?         Verifica se existe Politica Comercial para o Cliente        ?
  ???????????????????????????????????????????????????????????????????????*/

If DbSeek ( xFilial("SZ1") + cCli + DtoS( dDataAte ) ) .And. !Empty ( cCli ) .And. !Empty ( dDataAte )
   Aviso( "Aten??o !" , "J? existe uma Pol?tica Comercial Cadastrada para o cliente : " + Alltrim( SZ1->Z1_NOME ) + " na Vigencia : " + DtoC( dDataAte ) + " ! ", {"Ok"} , 1 , "Pol?tica j? Existe ! " ) 
   lRet := .F.
Endif   

Return lRet