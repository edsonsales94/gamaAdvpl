#Include "Protheus.ch"

/*
??????????????????????????????????????????????????????????????????????????????
??????????????????????????????????????????????????????????????????????????????
??????????????????????????????????????????????????????????????????????????ͻ??
???Programa  ? GrvDadBol ? Autor ? Cristiano Figueiroa? Data ? 12/12/2006  ???
???Adaptado  ? GrvDadBol ? Autor ? Marcelo Varella    ? Data ? 04/06/2007  ???
??????????????????????????????????????????????????????????????????????????͹??
???Descricao ? Funcao que grava campos adicionais na impressao do boleto   ???
???          ? bancario do contas a receber                                ???
??????????????????????????????????????????????????????????????????????????͹??
???Uso       ? Opus                                                        ???
??????????????????????????????????????????????????????????????????????????ͼ??
??????????????????????????????????????????????????????????????????????????????
??????????????????????????????????????????????????????????????????????????????*/

User Function GrvDadBol( cPrefixo , cNumero , cParcela , cTipo , cCliente , cLoja , cBanco , cAgencia , cConta , cCarteira )

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?              Declara as Variaveis Locais Utilizadas na Rotina              ?
  ??????????????????????????????????????????????????????????????????????????????*/

Local aArea    := GetArea()
Local aAreaSE1 := SE1->( GetArea() )
Local lOk      := .T.
Local aNossNum := {}
                  
/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?         Verifica se a Rotina recebeu todos os parametros necessarios       ?
  ??????????????????????????????????????????????????????????????????????????????*/

If cPrefixo == Nil .Or. ;
   cNumero  == Nil .Or. ;
   cParcela == Nil .Or. ;
   cTipo    == Nil .Or. ;
   cCliente == Nil .Or. ;
   cLoja    == Nil .Or. ;
   cBanco   == Nil .Or. ;
   cAgencia == Nil .Or. ;
   cConta   == Nil .Or. ;
   cCarteira== Nil
                   
   Aviso( "Aten??o - Problema na Rotina GrvDadBol" , "Alguns parametros nao foram passados de forma adequada para a rotina que grava o Nosso N?mero do Boleto Banc?rio !" , {"Ok"} , 1 , "Problema na Impress?o" )
   lOk := .F.

Endif

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                           Gera o Nosso Numero                              ?
  ??????????????????????????????????????????????????????????????????????????????*/

aNossNum  := u_GerNosNum( cBanco , cAgencia , cConta , cCarteira )

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?    Posicao 1 do Array - Gerou o Nosso Numero (.T. ) ou Nao Gerou (.F.)     ?
  ?    Posicao 2 do Array - Nosso Numero                                       ?
  ??????????????????????????????????????????????????????????????????????????????*/

lOk     := aNossNum[1]
cNumBco := aNossNum[2]

 /*????????????????????????????????????????????????????????????????????????????Ŀ
   ?                  Caso esteja tudo Ok grava o Nosso Numero                  ?
   ??????????????????????????????????????????????????????????????????????????????*/

If lOk

 /*????????????????????????????????????????????????????????????????????????????Ŀ
   ?                     Abre a Tabela do Contas a Receber                      ?
   ??????????????????????????????????????????????????????????????????????????????*/

   DbSelectArea("SE1")
   DbSetOrder(1)

 /*????????????????????????????????????????????????????????????????????????????Ŀ
   ?                       Posiciona no Titulo a Receber                        ?
   ??????????????????????????????????????????????????????????????????????????????*/

   If DbSeek ( xFilial ("SE1") + cPrefixo + cNumero + cParcela + cTipo + cCliente + cLoja )
      RecLock("SE1" , .F. )
      SE1->E1_NUMBCO  := cNumBco
      MsUnlock()
   Else
      Aviso( "Aten??o !" , "O Titulo a Receber " + " " + cPrefixo + " " + cNumero + " " + cParcela + " " + cTipo + " n?o foi encontrado ! O Nosso n?mero n?o poder? ser gravado ! " , {"Ok"} , 1 , "Titulo n?o Encontrado !" )
      lOk := .F.
   Endif

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                       Restaura as Areas Utilizadas                         ?
  ?????????????????????????????????????????????????????????????????????????????*/

   RestArea(aAreaSE1)
   RestArea(aArea)

Endif  

//Alert( "O Nosso N?mero ? : " + cNumBco )

Return ( { lOk , cNumBco } ) 

/*
???????????????????????????????????????????????????????????????????????????????
???????????????????????????????????????????????????????????????????????????????
???????????????????????????????????????????????????????????????????????????ͻ??
???Programa  ?GeraNossoNum? Autor ? Cristiano Figueiroa? Data ? 12/12/2006  ???
???????????????????????????????????????????????????????????????????????????͹??
???Descricao ? Funcao que gera o Nosso N?mero de Acordo com o Banco         ???
???????????????????????????????????????????????????????????????????????????͹??
???Parametros? Banco , Agencia e Conta Corrente                             ???
???????????????????????????????????????????????????????????????????????????͹??
???Retorno   ? lGerou    - .T. Gerou o Nosso Numero Correto .F. - Nao Gerou ???
???          ? cNossoNum - Nosso Numero Gerado                              ???
???????????????????????????????????????????????????????????????????????????͹??
???Uso       ? G & P                                                        ???
???????????????????????????????????????????????????????????????????????????ͼ??
???????????????????????????????????????????????????????????????????????????????
???????????????????????????????????????????????????????????????????????????????*/

User Function GerNosNum( cBco , cAge , cCC , cCarteira )

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?              Declara as Variaveis Locais Utilizadas na Rotina              ?
  ??????????????????????????????????????????????????????????????????????????????*/

Local aArea     := GetArea()
Local aAreaSEE  := SEE->( GetArea() )
Local lGerou    := .T.
Local cNossoNum := ""

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?         Verifica se a Rotina recebeu todos os parametros necessarios       ?
  ??????????????????????????????????????????????????????????????????????????????*/

If cBco == Nil .Or. ;
   cAge == Nil .Or. ;
   cCC  == Nil

   Aviso( "Aten??o ! Problema na Rotina GerNosNum" , "Alguns parametros nao foram passados de forma adequada para a rotina que gera o Nosso N?mero do Boleto Banc?rio ! Este boleto n?o ser? impresso !" , {"Ok"} , 1 , "Calculo do Nosso N?mero" )
   lGerou := .F.
   Return ( { lGerou , cNossoNum } )

Endif

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                    Abre o Arquivo de Parametros Bancos Cnab                ?
  ??????????????????????????????????????????????????????????????????????????????*/

DbSelectArea("SEE")
DbSetOrder(1)

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?              Posiciona no Arquivo de Parametros Bancos Cnab                ?
  ??????????????????????????????????????????????????????????????????????????????*/

If DbSeek ( xFilial("SEE") + cBco + cAge + cCC + cCarteira)
   
/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                             Banco Sudameris                                ?
  ? Nosso Numero com Registro : Sequencial de 7 digitos                        ?
  ?                                                                            ?
  ?                             Banco do Brasil                                ?
  ? Nosso Numero com Registro : Sequencial de 10 digitos                       ?
  ?                                                                            ?
  ??????????????????????????????????????????????????????????????????????????????*/

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                  Calcula o Nosso Numero para o Unibanco                    ?
  ??????????????????????????????????????????????????????????????????????????????*/

   If cBco == "347"   // SUDAMERIS
      cNossoNum := Soma1 ( StrZero( Val( SEE->EE_FAXATU ) , 7 ) )
      RecLock( "SEE" , .F. )
      SEE->EE_FAXATU := SubStr(cNossoNum, 1, 7)
      MsUnlock()
 
/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                  Calcula o Nosso Numero para o Real                        ?
  ??????????????????????????????????????????????????????????????????????????????*/

   ElseIf cBco == "001"   // BCO DO BRASIL
      cNossoNum := Soma1 ( StrZero( Val( SEE->EE_FAXATU ) , 10 ) )
      RecLock( "SEE" , .F. )
      SEE->EE_FAXATU := SubStr(cNossoNum, 1, 10)
      MsUnlock()
   Endif
     
/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                       Atualiza o Ultimo Numero Gerado                      ?
  ??????????????????????????????????????????????????????????????????????????????*/

Else
   Aviso( "Aten??o ! Problema na Rotina GerNosNum" , "N?o existem parametros de bancos Cnab (SEE) cadastrados para a o Banco : " + Alltrim(cBco) + " Agencia : " + Alltrim(cAge) + " e Conta : " + Alltrim(cCC) + " . Cadastre os Parametros de Bancos para que o Nosso N?mero possa ser gerado !" , {"Ok"} , 1 , "Calculo do Nosso N?mero" )
   lGerou := .F.
Endif

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ?                  Restaura as Areas Anteriores a Rotina                     ?
  ??????????????????????????????????????????????????????????????????????????????*/

RestArea(aAreaSEE)
RestArea(aArea)

Return ( { lGerou , cNossoNum } ) 
