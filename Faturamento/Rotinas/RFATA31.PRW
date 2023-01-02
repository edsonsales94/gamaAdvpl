#Include "Protheus.ch"
#Include "Rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RFata31  º Autor ³LUIZ FERNANDOº Data ³ 13/04/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ CADASTRO DE METAS COMERCIAIS                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasitech ( Gama Italy )                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function RFATA31

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Declaracao de Variaveis                                             ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

Private cCadastro := "Configuração da Politica Comercial"

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Array (tambem deve ser aRotina sempre) com as definicoes das opcoes ³
  ³ que apareceram disponiveis para o usuario. Segue o padrao:          ³
  ³ aRotina := { {<DESCRICAO>,<ROTINA>,0,<TIPO>},;                      ³
  ³              {<DESCRICAO>,<ROTINA>,0,<TIPO>},;                      ³
  ³              . . .                                                  ³
  ³              {<DESCRICAO>,<ROTINA>,0,<TIPO>} }                      ³
  ³ Onde: <DESCRICAO> - Descricao da opcao do menu                      ³
  ³       <ROTINA>    - Rotina a ser executada. Deve estar entre aspas  ³
  ³                     duplas e pode ser uma das funcoes pre-definidas ³
  ³                     do sistema (AXPESQUI,AXVISUAL,AXINCLUI,AXALTERA ³
  ³                     e AXDELETA) ou a chamada de um EXECBLOCK.       ³
  ³                     Obs.: Se utilizar a funcao AXDELETA, deve-se de-³
  ³                     clarar uma variavel chamada CDELFUNC contendo   ³
  ³                     uma expressao logica que define se o usuario po-³
  ³                     dera ou nao excluir o registro, por exemplo:    ³
  ³                     cDelFunc := 'ExecBlock("TESTE")'  ou            ³
  ³                     cDelFunc := ".T."                               ³
  ³                     Note que ao se utilizar chamada de EXECBLOCKs,  ³
  ³                     as aspas simples devem estar SEMPRE por fora da ³
  ³                     sintaxe.                                        ³
  ³       <TIPO>      - Identifica o tipo de rotina que sera executada. ³
  ³                     Por exemplo, 1 identifica que sera uma rotina de³
  ³                     pesquisa, portando alteracoes nao podem ser efe-³
  ³                     tuadas. 3 indica que a rotina e de inclusao, por³
  ³                     tanto, a rotina sera chamada continuamente ao   ³
  ³                     final do processamento, ate o pressionamento de ³
  ³                     <ESC>. Geralmente ao se usar uma chamada de     ³
  ³                     EXECBLOCK, usa-se o tipo 4, de alteracao.       ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ aRotina padrao. Utilizando a declaracao a seguir, a execucao da     ³
  ³ MBROWSE sera identica a da AXCADASTRO:                              ³
  ³                                                                     ³
  ³ cDelFunc  := ".T."                                                  ³
  ³ aRotina   := { { "Pesquisar"    ,"AxPesqui" , 0, 1},;               ³
  ³                { "Visualizar"   ,"AxVisual" , 0, 2},;               ³
  ³                { "Incluir"      ,"AxInclui" , 0, 3},;               ³
  ³                { "Alterar"      ,"AxAltera" , 0, 4},;               ³
  ³                { "Excluir"      ,"AxDeleta" , 0, 5} }               ³
  ³                                                                     ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Monta um aRotina proprio                                            ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Private aRotina  := { {"Pesquisar"  ,"AxPesqui"             , 0 , 1 } ,;
                       {"Visualizar" ,"AxVisual"             , 0 , 2 } ,;
                       {"Incluir"    ,'AxInclui'  , 0 , 3 } ,;
                       {"Alterar"    ,'AxAltera'  , 0 , 4 } ,;
                       {"Excluir"    ,"AxDeleta"             , 0 , 5 } ,;
                       {"Legenda"    ,'Execblock("LEGEMETA")' , 0 , 2 }}

Private cDelFunc := ".T."  // Validacao para a exclusao. Pode-se utilizar ExecBlock

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Abre a Tabela de Politica Comercial                                 ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

DbSelectArea("SZC")
DbSetOrder(1)


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Variavel que definira as cores do browse                            ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Private aCores  := {} 

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Array com as cores do browse                                        ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Aadd( aCores , { "Dtos(ZC_DATAATE) >= Dtos(dDataBase)" , "BR_VERDE"    } )  // Politica Comercial Ativa
Aadd( aCores , { "Dtos(ZC_DATAATE) <  Dtos(dDataBase)" , "BR_VERMELHO" } )  // Politica Comercial Fora da Vigencia


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Executa a funcao MBROWSE. Sintaxe:                                  ³
  ³                                                                     ³
  ³ mBrowse(<nLin1,nCol1,nLin2,nCol2,Alias,aCampos,cCampo)              ³
  ³ Onde: nLin1,...nCol2 - Coordenadas dos cantos aonde o browse sera   ³
  ³                        exibido. Para seguir o padrao da AXCADASTRO  ³
  ³                        use sempre 6,1,22,75 (o que nao impede de    ³
  ³                        criar o browse no lugar desejado da tela).   ³
  ³                        Obs.: Na versao Windows, o browse sera exibi-³
  ³                        do sempre na janela ativa. Caso nenhuma este-³
  ³                        ja ativa no momento, o browse sera exibido na³
  ³                        janela do proprio SIGAADV.                   ³
  ³ Alias                - Alias do arquivo a ser "Browseado".          ³
  ³ aCampos              - Array multidimensional com os campos a serem ³
  ³                        exibidos no browse. Se nao informado, os cam-³
  ³                        pos serao obtidos do dicionario de dados.    ³
  ³                        E util para o uso com arquivos de trabalho.  ³
  ³                        Segue o padrao:                              ³
  ³                        aCampos := { {<CAMPO>,<DESCRICAO>},;         ³
  ³                                     {<CAMPO>,<DESCRICAO>},;         ³
  ³                                     . . .                           ³
  ³                                     {<CAMPO>,<DESCRICAO>} }         ³
  ³                        Como por exemplo:                            ³
  ³                        aCampos := { {"TRB_DATA","Data  "},;         ³
  ³                                     {"TRB_COD" ,"Codigo"} }         ³
  ³ cCampo               - Nome de um campo (entre aspas) que sera usado³
  ³                        como "flag". Se o campo estiver vazio, o re- ³
  ³                        gistro ficara de uma cor no browse, senao fi-³
  ³                        cara de outra cor.                           ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

MBrowse( 6 , 1 , 22 , 75 , "SZC" , , , , , , aCores )

Return
                      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LegePol  º Autor ³Cristiano Figueiroa º Data ³ 18/02/2009  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Exibe a Legenda na tela de Politica Comercial              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasitech ( Gama Italy )                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function LegeMeta( cAlias , nRecno , cOpcao )

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                 Declara as Variaveis Utilizadas na Rotina                  ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Local aLegenda := {}

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                    Efetua a Carga do Array de Legendas                     ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Aadd( aLegenda , {"BR_VERDE"   , "Período Vigente"             })
Aadd( aLegenda , {"BR_VERMELHO", "Período Encerrado"  })

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                              Monta Legenda                                 ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

BrwLegenda( cCadastro , OemToAnsi("Legendas") , aLegenda )

Return