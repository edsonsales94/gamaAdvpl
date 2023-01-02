#Include "RwMake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A010TOk º Autor ³ Cristiano Figueiroa º Data ³ 26/02/2009  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validação para inclusão ou alteração do Produto		 	  ¹±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º  Deve retornar .T. se validação OK, para continuar e incluir ou 	  ¹±± 
±±º  atualizar o produto ou .F. para retornar a tela de inclusao ou 	  ¹±±
±±º  alteracao, interrompendo o processo.								  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasitech ( Gama Italy )                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function A010TOk()

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³              Declara as Variaveis Utilizadas na Rotina                     ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Local aArea := GetArea()
Local aAreaB1 := SB1->(GetArea())
Local Campo	:= ""  
Local cCodProd	:= POSICIONE("SB1",1,xFilial("SB1")+M->B1_COD,"B1_COD")  
Local nAtual
Local aCampos
Local cErro	:= ""
Local cErroCod	:= ""
Local lRetorno 	:= .T.  
Local cEol		:= Chr(13) + Chr(10)
Local aAltCamp:={}
Local lSg1:=.F.

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³             Valida o Preenchimento do Mix do Produto quando PA             ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
  
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Valida o Preenchimento do Cod. Barras do Produto quando PA - Luiz Fernando 09/06/2011	   ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Valida o Preenchimento do Dun14 do Produto quando PA - Luiz Fernando 09/06/2011	   ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

	If M->B1_TIPO $ "PA-SV"
		if len(Alltrim(M->B1_COD)) < 15 .and. Inclui
		cErroCod := "O código do produto deve seguir o padrão da Matriz. Favor solicitar ao responsável." + cEol
		lRetorno := .F.
		endif
		If M->B1_TIPO == "PA"
			if Empty( M->B1_X_MIX )
			cErro += "Mix, "
			//Aviso( "Atenção !" , "O campo Mix deverá ser preenchido para os produtos do tipo PA - Produto Acabado. Preencha o Mix desse produto antes de prosseguir !"  , {"Ok"} , 1 , "Mix Obrigatório ! " )
			lRetorno := .F.
			endif
			if Empty( M->B1_PESBRU )
			cErro += "Peso Bruto, "
			//Aviso( "Atenção !" , "O campo Peso Bruto deverá ser preenchido para os produtos do tipo PA - Produto Acabado. Preencha o Peso Bruto desse produto antes de prosseguir !"  , {"Ok"} , 1 , "Peso Bruto Obrigatório ! " )
			lRetorno := .F.
			endif
			if Empty( M->B1_PESO )
			cErro += "Peso Liquido, "
			//Aviso( "Atenção !" , "O campo Peso Líquido deverá ser preenchido para os produtos do tipo PA - Produto Acabado. Preencha o Peso Líquido desse produto antes de prosseguir !"  , {"Ok"} , 1 , "Peso Líquido Obrigatório ! " )
			lRetorno := .F.
			endif
			if Empty( M->B1_CODBAR )
			cErro += "Cod Barras, "
			//Aviso( "Atenção !" , "O campo Código de Barras deverá ser preenchido para os produtos do tipo PA - Produto Acabado. Preencha o Código de Barras desse produto antes de prosseguir !"  , {"Ok"} , 1 , "Cód. Barras Obrigatório ! " )
			lRetorno := .F.
			endif
			if Empty( M->B1_DUN14 )
			cErro += "Dun 14, "
			//Aviso( "Atenção !" , "O campo Dun14 deverá ser preenchido para os produtos do tipo PA - Produto Acabado. Preencha o Dun14 desse produto antes de prosseguir !"  , {"Ok"} , 1 , "Dun14 Obrigatório ! " )
			lRetorno := .F.
			endif
			if Empty (M->B1_X_QTCXM)
			cErro += "Qt.Cx.Master, "
			lRetorno := .F.
			endif
			if Empty(M->B1_XMETCUB)
			cErro += "M Cubica, "
			lRetorno := .F.
			endif
			if Empty( M->B1_X_FASE )
			cErro += "Fase, "
			//Aviso( "Atenção !" , "O campo Fase do Produto deverá ser preenchido para os produtos do tipo PA - Produto Acabado. Preencha Fase desse Produto antes de prosseguir !"  , {"Ok"} , 1 , "Fase do Produto Obrigatório ! " )
			lRetorno := .F.
			endif
		Endif
		if !Empty(cErro) .or. !Empty(cErroCod)
		cErro := "Campos Obrigatórios:"+cEol+ SUBSTR(alltrim(cErro),1,len(alltrim(cErro))-1)
		cErro := cErroCod + cErro
//		Aviso( "Atenção !" , "Alguns campos devem ser preenchidos para produto do tipo PA(Produto Acabado). "+;
//		"Preencha os campos antes de prosseguir: "+ cEol + cErro+".", {"Ok"} , 2 , "Campos Obrigatórios ! " )
		Help(" ", 1, "ATENÇÃO",, "Foram localizadas inconsistências no cadastro."+;
		"Verifique."+ cEol+ cErro+"." + cEol + cEol + "(Específico Brasitech. PE - A010TOk). ", 1)
		endif
	Endif


  //alterado por claudio em 13/04/15 por solicitação da Dra. Cleonice para o calculo do MRP 
	if M->B1_TIPO$"MP/EM/CX" .AND. M->B1_MRP<>"N"    //retirado para unificação de base xFilial("SB1")=="01" .AND.
	Campo+=IIF(M->B1_QE==0,"-Qtde. p/embalagem","")       //QUANTIDADE POR EMBALAGEM 
    //Campo+=IIF(M->B1_EMIN==0,"-B1_EMIN","")        //PONTO DE PEDIDO
    //Campo+=IIF(M->B1_ESTSEG==0,"-B1_ESTSEG","")      //ESTOQUE DE SEGURANÇA
    //Campo+=IIF(M->B1_LE==0,"-B1_LE","")      //LOTE ECONOMICO
    Campo+=IIF(M->B1_LM==0,"- LOTE MINIMO","")     // LOTE MINIMO
    Campo+=IIF(M->B1_PE==0,"-PRAZO DE ENTREGA","")     //PRAZO DE ENTREGA
    Campo+=IIF(LEN(ALLTRIM(M->B1_MRP))==0,"-B1_MRP","" )    //MRP SIM OU NAO  
		IF LEN(ALLTRIM(Campo))>0
      //lRetorno := .F.  //retirado para unificação de base xFilial("SB1")=="01" .AND. 
      ALERT("Campos do MRP nao foram preenchidos : "+Campo)
		ENDIF
	Endif


    //Se for inclusão
	//If INCLUI
       // MsgInfo("Estou em uma <b>inclusão</b>!", "Atenção")
	//EndIf
     
     //Se for alteração
	If ALTERA

		aAltCamp:={}
		aCampos:={}
		aCampos := SB1->(DbStruct())
		

		For nAtual := 1 To Len(aCampos)
		
			If ( &("SB1->" + aCampos[nAtual] [1]) )!= (&("M->" + aCampos[nAtual][1]))
				if aCampos[nAtual] [1] <> "B1_IDHIST"
					IF ValType( &("SB1->" + aCampos[nAtual] [1]) ) =='C'
						IF (ALLTRIM( &("SB1->" + aCampos[nAtual] [1]) )!= ALLTRIM(&("M->" + aCampos[nAtual][1])) ) .OR.	(LEN(ALLTRIM( &("SB1->" + aCampos[nAtual] [1]) ))!= LEN(ALLTRIM(&("M->" + aCampos[nAtual][1]))))
							aadd( aAltCamp,{aCampos[nAtual][1],SX3Cache(aCampos[nAtual][1]),cValToChar(	&("SB1->" + aCampos[nAtual] [1])),cValToChar( &("M->" + aCampos[nAtual][1]))})	
						EndIf
					else
							aadd( aAltCamp,{aCampos[nAtual][1],SX3Cache(aCampos[nAtual][1]),cValToChar(	&("SB1->" + aCampos[nAtual] [1])),cValToChar( &("M->" + aCampos[nAtual][1]))})	
					ENDIF
				endif
			EndIf
		Next
		//ALERT(ALTERA)

		if Len(aAltCamp)>0 .AND. lRetorno
			//Envia email de aviso quando dentro da estrutura
		//	ALERT(cCodProd)
			lSg1:=CheckEstutura(cCodProd)
			if lSg1
					IF U_fEmailAltProd(aAltCamp,cCodProd) 
					  MSGINFO( 'Este produto é controlado pela Engenharia.', "Workflow - Engenharia" ) 
					ELSE
					  MSGINFO( 'Erro ao enviar e-mail', "Workflow - Engenharia" )
					endif 

			endif
		
		EndIf
	endif
     
    //Se for cópia
	//If lCopia
        //MsgInfo("Estou em uma <b>cópia</b>!", "Atenção")
	//EndIf
     
    //lRetorno := MsgYesNo("Deseja continuar", "Atenção")


    RestArea(aAreaB1)
    RestArea(aArea)
Return lRetorno

static Function SX3Cache(cSX3Campo)
Local cCampo := "X3_TITULO"
Local uValor //retorna o conteudo do X3_TAMANHO do campo da tabela A1_COD
	uValor := GetSx3Cache(cSX3Campo,cCampo)
Return uValor


Static Function CheckEstutura(cCodProduto)
Local lRet :=.F.
Local aArea := GetArea()

	 DbSelectArea("SG1")
     SG1->(DbSetOrder(1))
     SG1->(DbGoTop())
	IF MSSeek(xFilial("SG1") + ALLTRIM(cCodProduto) )
          lRet:=.T.
	ELSE
		    SG1->(DbSetOrder(2))
     		SG1->(DbGoTop())
		IF MSSeek(xFilial("SG1") + ALLTRIM(cCodProduto) )
			 lRet:=.T.
		ENDIF
	ENDIF
		dbclosearea()       
		 	

	RestArea(aArea)
	
Return lRet
