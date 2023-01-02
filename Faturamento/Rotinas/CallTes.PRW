#Include "Protheus.ch"
#Include "Rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CallTes  º Autor ³Cristiano Figueiroa º Data ³     26/10/09    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Carrega a Tes Conforme Cadastro de TES Inteligente Especifica  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasitech                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function CallTes( nEntSai , cTpOper , cClieFor , cLoja , cTipoCF , cProduto , cCampo )

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ 					Declaracao de Variaveis                         ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Local aArea		:= GetArea()
Local aAreaSA1	:= SA1->(GetArea())
Local aAreaSA2	:= SA2->(GetArea())
Local aAreaSB1	:= SB1->(GetArea())
Local aTes 		:= {}
Local aDadosCfo := {} 
Local cTesRet	:= "   "
Local cGrupo	:= ""
Local cGruProd	:= ""
Local cQuery	:= ""  
Local cProg     := "MT100"
Local cNCM      := ""
Local cSitGama  := ""
Local cEstado   := ""
Local cContrib  := ""
Local cAliasSZ9 := "SZ9"         
Local cTabela   := ""
Local lQuery	:= .F.
Local nPosCpo	:= 0
Local nPosCfo   := 0

Default cTpOper := &(ReadVar())
Default cClieFor:= ""
Default cProduto:= ""
Default nEntSai := 0
Default cTipoCF := "C"
Default cCampo	:= ""

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Caso o Campo nao tenha sido passado como parametro busca do aHeader ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

If !Empty(cCampo)
   nPosCpo	:= aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim(cCampo) })
   
   If cCampo == "C6_TES"
      cTabela  := "SC6"
   Else
      cTabela  := aHeader[nPosCpo,9]      
   Endif     
   
EndIf

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³       Verifica o Grupo de Tributacao do Cliente ou Fornecedor       ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

DbSelectArea( Iif( cTipoCF == "C" , "SA1" , "SA2" ) )
DbSetOrder(1)

MsSeek( xFilial() + cClieFor + cLoja )

If cTipoCF == "C"
   cGrupo  := SA1->A1_GRPTRIB
   cEstado := SA1->A1_EST
   cContrib:= Iif ( Empty( Alltrim( SA1->A1_INSCR ) ) .Or. Alltrim( Upper( SA1->A1_INSCR ) ) == "ISENTO" , "2" , "1" )
Else
   cGrupo  := SA2->A2_GRPTRIB
   cEstado := SA2->A2_EST
   cContrib:= Iif ( Empty( Alltrim( SA2->A2_INSCR ) ) .Or. Alltrim( Upper( SA2->A2_INSCR ) ) == "ISENTO" , "2" , "1" )
EndIf

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                  Verifica o Grupo do Produto                        ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

DbSelectArea("SB1")
DbSetOrder(1)                  

MsSeek( xFilial("SB1")+cProduto)

cGruProd := SB1->B1_GRTRIB
cNcm     := SB1->B1_POSIPI
cSitGama := SB1->B1_ORIGAMA

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                  Verifica o Grupo do Produto                        ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

#IFDEF TOP
	lQuery := .T.
	cAliasSZ9 := GetNextAlias() 
	cQuery += "SELECT * FROM " + RetSqlName("SZ9") + " SZ9 "
	cQuery += "WHERE SZ9.Z9_FILIAL = '" + xFilial("SZ9") + "'"
	cQuery += "AND SZ9.Z9_TIPO = '" + cTpOper + "'"
	cQuery += "AND SZ9.Z9_ORIGAMA = '" + cSitGama + "'"
	cQuery += "AND SZ9.D_E_L_E_T_= ' ' "
	cQuery += "ORDER BY "+SqlOrder(SZ9->(IndexKey()))
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSZ9,.T.,.T.)
#Else
   DbSelectArea("SZ9")
   DbSetOrder(1)
   MsSeek(xFilial("SZ9") + cTpOper )
#Endif

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³         Realiza o While na Tes Inteligente ate encontra-lo          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Do While ! Eof() .And. ( cAliasSZ9 )->Z9_TIPO == cTpOper
	
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³               Realiza a Busca Quando for Cliente                    ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

   If cTipoCF == "C" 

/*      If ( Empty((cAliasSZ9)->Z9_PRODUTO+(cAliasSZ9)->Z9_CLIENTE+(cAliasSZ9)->Z9_LOJACLI+(cAliasSZ9)->Z9_GRTRIB+(cAliasSZ9)->Z9_GRPROD+(cAliasSZ9)->Z9_POSIPI+(cAliasSZ9)->Z9_EST) .Or.;
              (((cAliasSZ9)->Z9_PRODUTO == cProduto .Or. Empty((cAliasSZ9)->Z9_PRODUTO)) .And.;
			  (Alltrim(cGruProd) == Alltrim((cAliasSZ9)->Z9_GRPROD) .Or. Empty((cAliasSZ9)->Z9_GRPROD)) .And.;
			  ( cClieFor+cLoja   == (cAliasSZ9)->Z9_CLIENTE+(cAliasSZ9)->Z9_LOJACLI .Or. Empty((cAliasSZ9)->Z9_CLIENTE+(cAliasSZ9)->Z9_LOJACLI)) .And.;
			  ( cGrupo           == (cAliasSZ9)->Z9_GRTRIB .Or. Empty((cAliasSZ9)->Z9_GRTRIB)) .And.;
			  ( cEstado          == (cAliasSZ9)->Z9_EST    .Or. Empty((cAliasSZ9)->Z9_EST))    .And.;	
			  ( cNCM             == (cAliasSZ9)->Z9_POSIPI .Or. Empty((cAliasSZ9)->Z9_POSIPI))))/*/

      If ( Empty((cAliasSZ9)->Z9_PRODUTO+(cAliasSZ9)->Z9_CLIENTE+(cAliasSZ9)->Z9_LOJACLI+(cAliasSZ9)->Z9_GRTRIB+(cAliasSZ9)->Z9_GRPROD+(cAliasSZ9)->Z9_POSIPI+(cAliasSZ9)->Z9_EST +(cAliasSZ9)->Z9_CONTRIB )  .Or.;
              (((cAliasSZ9)->Z9_PRODUTO == cProduto .Or. Empty((cAliasSZ9)->Z9_PRODUTO)) .And.;
			  (Alltrim(cGruProd) == Alltrim((cAliasSZ9)->Z9_GRPROD) .Or. Empty((cAliasSZ9)->Z9_GRPROD)) .And.;
			  ( cClieFor+cLoja   == (cAliasSZ9)->Z9_CLIENTE+(cAliasSZ9)->Z9_LOJACLI .Or. Empty((cAliasSZ9)->Z9_CLIENTE+(cAliasSZ9)->Z9_LOJACLI)) .And.;
			  ( cGrupo           == (cAliasSZ9)->Z9_GRTRIB .Or. Empty((cAliasSZ9)->Z9_GRTRIB)) .And.;
			  ( cEstado          == (cAliasSZ9)->Z9_EST    .Or. Empty((cAliasSZ9)->Z9_EST))    .And.;	
			  ( cContrib         == (cAliasSZ9)->Z9_CONTRIB .Or. Empty((cAliasSZ9)->Z9_CONTRIB))  .And.;	
			  ( cNCM             == (cAliasSZ9)->Z9_POSIPI .Or. Empty((cAliasSZ9)->Z9_POSIPI))))

       /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         ³           Adiciona no Array as TES que Satisfacam a Condicao        ³
         ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

/*         Aadd( aTes , {(cAliasSZ9)->Z9_PRODUTO , (cAliasSZ9)->Z9_GRPROD , (cAliasSZ9)->Z9_POSIPI , (cAliasSZ9)->Z9_CLIENTE , (cAliasSZ9)->Z9_LOJACLI , ;
                      (cAliasSZ9)->Z9_GRTRIB  ,  (cAliasSZ9)->Z9_EST   , (cAliasSZ9)->Z9_TE     , (cAliasSZ9)->Z9_TS} )/*/

           Aadd( aTes , {(cAliasSZ9)->Z9_PRODUTO , (cAliasSZ9)->Z9_GRPROD , (cAliasSZ9)->Z9_POSIPI , (cAliasSZ9)->Z9_CLIENTE , (cAliasSZ9)->Z9_LOJACLI , ;
                          (cAliasSZ9)->Z9_GRTRIB  ,  (cAliasSZ9)->Z9_EST   , (cAliasSZ9)->Z9_CONTRIB, (cAliasSZ9)->Z9_TE     , (cAliasSZ9)->Z9_TS} )
      EndIf

   Else
      
      If ( Empty((cAliasSZ9)->Z9_PRODUTO+(cAliasSZ9)->Z9_FORNECE+(cAliasSZ9)->Z9_LOJAFOR+(cAliasSZ9)->Z9_GRTRIB+(cAliasSZ9)->Z9_GRPROD+(cAliasSZ9)->Z9_POSIPI+(cAliasSZ9)->Z9_EST +(cAliasSZ9)->Z9_CONTRIB ) .Or.;
		     	(((cAliasSZ9)->Z9_PRODUTO == cProduto .Or. Empty((cAliasSZ9)->Z9_PRODUTO)) .And.;
			    (Alltrim(cGruProd) == Alltrim((cAliasSZ9)->Z9_GRPROD) .Or. Empty((cAliasSZ9)->Z9_GRPROD)) .And.;
			    ( cClieFor+cLoja == (cAliasSZ9)->Z9_FORNECE+(cAliasSZ9)->Z9_LOJAFOR .Or. Empty((cAliasSZ9)->Z9_FORNECE+(cAliasSZ9)->Z9_LOJAFOR)) .And.;
			    ( cGrupo  == (cAliasSZ9)->Z9_GRTRIB .Or. Empty((cAliasSZ9)->Z9_GRTRIB)) .And.;
			    ( cEstado == (cAliasSZ9)->Z9_EST    .Or. Empty((cAliasSZ9)->Z9_EST)) .And.;	
  			    ( cContrib== (cAliasSZ9)->Z9_CONTRIB .Or. Empty((cAliasSZ9)->Z9_CONTRIB)) .And.;
			    ( cNCM    == (cAliasSZ9)->Z9_POSIPI .Or. Empty((cAliasSZ9)->Z9_POSIPI))))
			 			 
/*         Aadd(aTes,{(cAliasSZ9)->Z9_PRODUTO , (cAliasSZ9)->Z9_GRPROD , (cAliasSZ9)->Z9_POSIPI , (cAliasSZ9)->Z9_FORNECE , (cAliasSZ9)->Z9_LOJAFOR , ;
 		             (cAliasSZ9)->Z9_GRTRIB , (cAliasSZ9)->Z9_EST    ,  (cAliasSZ9)->Z9_TE    , (cAliasSZ9)->Z9_TS } )*/
 		             
           Aadd(aTes,{(cAliasSZ9)->Z9_PRODUTO , (cAliasSZ9)->Z9_GRPROD , (cAliasSZ9)->Z9_POSIPI , (cAliasSZ9)->Z9_FORNECE , (cAliasSZ9)->Z9_LOJAFOR , ;
 		             (cAliasSZ9)->Z9_GRTRIB , (cAliasSZ9)->Z9_EST      , (cAliasSZ9)->Z9_CONTRIB ,  (cAliasSZ9)->Z9_TE    , (cAliasSZ9)->Z9_TS } )
      EndIf
   EndIf

   DbSelectArea(cAliasSZ9)
   DbSkip()

EndDo

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³          Fecha o Arquivo Temporario com o Resultado da Query        ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

If ( lQuery )
   DbSelectArea(cAliasSZ9)
   DbCloseArea()
   DbSelectArea("SZ9")
EndIf

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³        Pesquisa por todas as regras validas para este caso          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

//aSort(aTES,,,{|x,y| x[1]+x[2]+x[3]+x[4]+x[5]+x[6]+x[7] > y[1]+y[2]+y[3]+y[4]+y[5]+y[6]+y[7]})
  aSort(aTES,,,{|x,y| x[1]+x[2]+x[3]+x[4]+x[5]+x[6]+x[7]+x[8] > y[1]+y[2]+y[3]+y[4]+y[5]+y[6]+y[7]+y[8] })

If Len(aTes) <> 0
	cTesRet := If( nEntSai == 1 , aTes[1][9] , aTes[1][10] )
EndIf

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³        De acordo com a tabela utilizada retorna a TES               ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

If nPosCpo > 0 .And. !Empty(cTesRet) .And. Type('aCols') <> "U"

   aCols[n][nPosCpo] := cTesRet
   Do Case
      Case cTabela == "SD1"
         nPosCfo := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim("D1_CF") })
      Case cTabela == "SD2"
         nPosCfo := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim("D2_CF") })
      Case cTabela == "SC6"     
         DbSelectArea("SF4")
         DbSetOrder(1)
         nPosCfo := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim("C6_CF") })
         
         If nPosCfo > 0 .And. MsSeek(xFilial("SF4")+cTesRet)
            aDadosCfo := {} 
            AAdd(aDadosCfo,{"OPERNF","S"})
            AAdd(aDadosCfo,{"TPCLIFOR",If(cTipoCF == "C", SA1->A1_TIPO , SA2->A2_TIPO )})
            AAdd(aDadosCfo,{"UFDEST"  ,If(cTipoCF == "C", SA1->A1_EST  , SA2->A2_EST  )})
            AAdd(aDadosCfo,{"INSCR"   ,If(cTipoCF == "C", SA1->A1_INSCR, SA2->A2_INSCR)})
            aCols[n][nPosCfo] := MaFisCfo( ,SF4->F4_CF,aDadosCfo ) 
         EndIf
         nPosCfo := 0      

      Case cTabela == "SC7"
         cProg := "MT120"
      Case cTabela == "SC8"
         cProg := "MT150"
      Case cTabela == "SUB"
         nPosCfo := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim("UB_CF") })
         cProg := "TK273"
   EndCase
	
   If nPosCfo > 0
      aCols[n][nPosCfo] := Space(Len(aCols[n][nPosCfo]))
   EndIf
   
   If MaFisFound("IT",N)
      MaFisAlt("IT_TES",cTesRet,n)
      MaFisRef("IT_TES",cProg,cTesRet)
   EndIf
   
EndIf

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³        Pesquisa por todas as regras validas para este caso          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
  
If !Empty(cTesRet)
   DbSelectArea("SF4")
   If MsSeek(xFilial("SF4")+cTesRet)
      If !RegistroOK("SF4")
         cTesRet := Space(Len(cTesRet))
      EndIf
   EndIf
EndIf

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³               Restaura os Arquivos antes da Execucao                ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

RestArea(aAreaSA2)
RestArea(aAreaSA1)
RestArea(aAreaSB1)
RestArea(aArea)

Return(cTesRet)