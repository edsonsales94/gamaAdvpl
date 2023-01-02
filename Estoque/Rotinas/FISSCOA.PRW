#include 'protheus.ch'
#include "RWMAKE.CH"
#INCLUDE "XMLXFUN.CH"

user function FISSCOA()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Private cPerg       := "SCOA"
	Private oGeraTxt,mes

	Private cString := "SB9"

	ValidPerg(cPerg)
	//Pergunte(cPerg,.T.)

	dbSelectArea("SB9")
	dbSetOrder(1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem da tela de processamento.                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	@ 200,1 TO 380,480 DIALOG oGeraTxt TITLE OemToAnsi("Gera‡„o de Arquivo Texto")
	@ 02,10 TO 085,240
	@ 10,018 Say " Este programa ira gerar um arquivo texto, conforme os parame- "
	@ 18,018 Say " tros definidos  pelo usuario,  com os registros do arquivo de "
	@ 26,018 Say " SB6 .Para isso crie um diretorio C:TEMP com permissao de gravação."

	@ 70,128 BMPBUTTON TYPE 01 ACTION OkGeraTxt()
	@ 70,158 BMPBUTTON TYPE 02 ACTION Close(oGeraTxt)
	@ 70,188 BMPBUTTON TYPE 05 ACTION Pergunte(cPerg,.T.)

	Activate Dialog oGeraTxt Centered

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ OKGERATXTº Autor ³ AP5 IDE            º Data ³  06/06/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao chamada pelo botao OK na tela inicial de processamenº±±
±±º          ³ to. Executa a geracao do arquivo texto.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±301116
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function OkGeraTxt

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria o arquivo texto                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Private cArq    := ALLTRIM(MV_PAR07)

	If File( cArq )

		Erase(cArq)
		nHdl := FCreate( cArq )
		//FClose( nHdl )

	ELSE
		nHdl := FCreate( cArq )
		//FClose( nHdl )
	Endif

	Private cEOL    := "CHR(13)+CHR(10)"
	If Empty(cEOL)
		cEOL := CHR(13)+CHR(10)
	Else
		cEOL := Trim(cEOL)
		cEOL := &cEOL
	Endif

	If nHdl == -1
		MsgAlert("O arquivo de nome C:\TEMP\FSCOA nao pode ser executado! Verifique os parametros.","Atencao!")
		Return
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa a regua de processamento                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Processa({|| RunCont() },"Processando...")
Return

Static Function RunCont

	Local nTamLin, cLin, cCpo
	Local cAliasSB9:= GetNextAlias()
	Local cAliasReg3:= GetNextAlias()
	Local cAliasReg3V:= GetNextAlias()
	Local cAliasSA1:= GetNextAlias()
	Local cError   := ""
	Local cWarning := ""
	Private oXml := NIL
	//Gera o Objeto XML
	//oXml := XmlParser( GeraXML(), "_", @cError, @cWarning )
	cModelo:=GeraXML()
	//CREATE oXml XMLSTRING cModelo

	MakeSqlExpr(cPerg)

	cClientes:=POSICIONE("SA1",1,XFILIAL("SA1")+MV_PAR09,"A1_CGC")

	//CABECALHO

	cLin := "00"+cEOL
	cCpo :="01"
	cCpo += PADR(ALLTRIM(SM0->M0_INSC),14)
	cCpo += PADR(left(dtos(MV_PAR01+1),6),6)
	cCpo += PADR(MV_PAR02,60)
	cLin := Stuff(cLin,03,0,cCpo)
	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		Alert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
	Endif

	nTamLin:=1

	cnpj:=POSICIONE("SA1",1,XFILIAL("SA1")+MV_PAR09,"A1_CGC")
	cCliente:=MV_PAR09
	cAto:=MV_PAR04
	cAtoVal:=MV_PAR05
	cArm:="%"+alltrim(MV_PAR06)+"%"
	//saldo iniciais
	BeginSql Alias cAliasSB9
	SELECT B9_COD,B1_DESC,B1_UM,B9_QINI,B9_VINI1
	FROM %table:SB9% SB9 ,%table:SB1% SB1
	WHERE B9_FILIAL=%exp:XFILIAL("SB9")% AND %exp:cArm%
	AND B9_DATA=%exp:DTOS(MV_PAR01)%	
	AND SB9.%NotDel% AND B1_COD=B9_COD
	EndSql

	//rEGISTRO DE ARMAZEM
	nTamLin++
	cLin := "01"+cEOL
	cCpo := PADR(cnpj,14)+iif(MV_PAR08==2,";","")     //CGC DO ARMAZEM PRINCIPAL
	cCpo += PADR(cAto,5)+iif(MV_PAR08==2,";","")   //ATO DECLARATORIO
	cCpo += PADR(cAtoVal,6)+iif(MV_PAR08==2,";","") //PRAZO DE VALIDADE DO ATO DECLARATORIO
	cLin := Stuff(cLin,03,0,cCpo)
	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		Alert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
	Endif

	dbSelectArea(cAliasSB9)
	dbgotop()
	Count to regSB9
	ProcRegua(regSB9) // Numero de registros a processar
	npos:=1
	dbgotop()
	While !EOF()
		IncProc("Itens dos saldos iniciais")
		cLin   := "02"+cEOL // Variavel para criacao da linha do registros para gravacao
		cDesc  := padr((cAliasSB9)->B1_DESC,80)
		cPreco := STR( NOROUND((cAliasSB9)->(B9_VINI1), 2) ,10,2)
		cPreco := StrTran( cPreco, ",", "" )   //ELIMINA AS VIRGULAS
		cPreco := StrTran( cPreco, ".", "" )
		cPreco := padl(ALLTRIM(cPreco),8)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Substitui nas respectivas posicioes na variavel cLin pelo conteudo  ³
		//³ dos campos segundo o Lay-Out. Utiliza a funcao STUFF insere uma     ³
		//³ string dentro de outra string.                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//FORMAÇÃO DAS LINHAS DO REGISTRO
		cCpo := PADR((cAliasSB9)->B9_COD,15)+iif(MV_PAR08==2,";","")
		cCpo += PADR(ALLTRIM(cDesc),80)+iif(MV_PAR08==2,";","")
		cCpo += PADR(alltrim(MV_PAR03),5)+iif(MV_PAR08==2,";","")   //ESTIMULO DE CREDITO DE 55%
		cCpo += STRZERO((cAliasSB9)->B9_QINI,8)+iif(MV_PAR08==2,";","")
		cCpo += (cAliasSB9)->B1_UM+iif(MV_PAR08==2,";","")
		cCpo += cPreco+iif(MV_PAR08==2,";","")
		cLin := Stuff(cLin,03,0,cCpo)
		//getObjXML(1,PADR((cAliasSB9)->COD,15),PADR(ALLTRIM(cDesc),80),PADR(alltrim(MV_PAR06),5),STRZERO((cAliasSB9)->QINI,8),"PC",cPreco,"","","","","",npos,0)
		npos++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gravacao no arquivo texto. Testa por erros durante a gravacao da    ³
		//³ linha montada.                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
				Exit
			Endif
		else
			nTamLin++
		Endif

		dbSkip()
	EndDo
	dbSelectArea(cAliasSB9)
	dbclosearea()
	mes:=MV_PAR01+1
	cfremessa:="%"+alltrim(MV_PAR10)+"%"
	cfvendas:="%"+alltrim(MV_PAR11)+"%"
	//VENDAS
	BeginSql Alias cAliasReg3
	select F2_CHVNFE CHVNFE,D2_COD COD,D2_QUANT QUANT,D2_PRCVEN VENDA from %table:SF2% SF2
	LEFT OUTER JOIN %table:SD2% SD2 ON D2_DOC=F2_DOC AND D2_CLIENTE=F2_CLIENTE AND SD2.%NotDel%
	WHERE F2_FILIAL=%exp:xfilial("SF2")%  AND SUBSTRING(F2_EMISSAO,1,6)=%exp:SUBSTR(DTOS(mes),1,6)%
	AND SF2.%NotDel% AND %exp:cfvendas%
	ORDER BY F2_DOC
	EndSql
	dbSelectArea(cAliasReg3)
	dbgotop()
	Count to regSB9
	ProcRegua(regSB9) // Numero de registros a processar
	dbgotop()
	npos:=1
	While !EOF()
		IncProc("Itens das Notas de Vendas")
		cLin := "03"+cEOL
		cChave:= (cAliasReg3)->CHVNFE
		cCpo := PADR((cAliasReg3)->CHVNFE,44)+iif(MV_PAR08==2," NF;","")
		cCpo += 'V'+iif(MV_PAR08==2,";","")
		cLin := Stuff(cLin,03,0,cCpo)
		//getObjXML(2,"","","","","","",PADR((cAliasReg3)->CHVNFE,44),'V',"","","",npos,0)
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
				Exit
			Endif
		else
			nTamLin++
		Endif
		npos2:=1
		While !EOF() .and. (cAliasReg3)->CHVNFE==cChave
			cLin := "04"+cEOL
			cPreco := STR( NOROUND((cAliasReg3)->VENDA,2),10,2)
			cPreco := StrTran( cPreco, ",", "" )   //ELIMINA AS VIRGULAS
			cPreco := StrTran( cPreco, ".", "" )
			cPreco := padl(ALLTRIM(cPreco),8)
			cCpo := PADR((cAliasReg3)->COD,15)+iif(MV_PAR08==2,";","")
			cCpo += STRZERO((cAliasReg3)->QUANT,8)+iif(MV_PAR08==2,";","")
			cCpo += cPreco+iif(MV_PAR08==2,";","")
			cLin := Stuff(cLin,03,0,cCpo)
			//getObjXML(3,"","","","","","","","",PADR((cAliasReg3)->COD,15),STRZERO((cAliasReg3)->QUANT,8),cPreco,npos,npos2)
			npos2++
			If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
				If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
					Exit
				Endif
			else
				nTamLin++
			Endif
			dbSkip()
		Enddo
		npos++
	Enddo
	dbSelectArea(cAliasReg3)
	dbclosearea()

	//Remessa
	BeginSql Alias cAliasReg3V
	select F2_CHVNFE CHVNFE,D2_COD COD,D2_QUANT QUANT,D2_PRCVEN VENDA from %table:SF2% SF2
	LEFT OUTER JOIN %table:SD2% SD2 ON D2_DOC=F2_DOC AND D2_CLIENTE=F2_CLIENTE AND SD2.%NotDel%
	WHERE F2_FILIAL=%exp:xfilial("SF2")%  AND SUBSTRING(F2_EMISSAO,1,6)=%exp:SUBSTR(DTOS(mes),1,6)%
	AND SF2.%NotDel% AND %exp:cfremessa%
	ORDER BY F2_DOC
	EndSql
	dbSelectArea(cAliasReg3V)
	dbgotop()
	Count to regSB9
	ProcRegua(regSB9) // Numero de registros a processar
	dbgotop()
	npos:=1
	While !EOF()
		IncProc("Itens das Notas de Remessa")
		cLin := "03"+cEOL
		cChave:=(cAliasReg3)->CHVNFE
		cCpo := PADR((cAliasReg3V)->CHVNFE,44)+iif(MV_PAR08==2," NF;","")
		cCpo += 'R'+iif(MV_PAR08==2,";","")
		cLin := Stuff(cLin,03,0,cCpo)
		//getObjXML(2,"","","","","","",PADR((cAliasReg3V)->CHVNFE,44),'R',"","","",npos,0)

		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
				Exit
			Endif
		else
			nTamLin++
		Endif
		npos2:=1
		While !EOF() .and. (cAliasReg3V)->CHVNFE==cChave
			cLin := "04"+cEOL
			cPreco := STR(NOROUND((cAliasReg3)->VENDA,2),8,2)
			cPreco := StrTran( cPreco, ",", "" )   //ELIMINA AS VIRGULAS
			cPreco := StrTran( cPreco, ".", "" )
			cCpo := PADR((cAliasReg3V)->COD,15)+iif(MV_PAR08==2,";","")
			cCpo += STRZERO((cAliasReg3V)->QUANT,8)+iif(MV_PAR08==2,";","")
			cCpo += cPreco+iif(MV_PAR08==2,";","")
			cLin := Stuff(cLin,03,0,cCpo)
			//getObjXML(3,"","","","","","","","",PADR((cAliasReg3V)->D2_COD,15),STRZERO((cAliasReg3V)->D2_QUANT,8),cPreco,npos,npos2)
			npos2++
			If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
				If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
					Exit
				Endif
			else
				nTamLin++
			Endif
			dbSkip()
		Enddo
		npos++
	Enddo
	dbSelectArea(cAliasReg3V)
	dbclosearea()

	//REGISTRO TRAILLER
	cLin := "09"+cEOL
	cCpo := strzero(nTamLin,5)+iif(MV_PAR08==2,";","")
	cLin := Stuff(cLin,03,0,cCpo)
	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		Alert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ O arquivo texto deve ser fechado, bem como o dialogo criado na fun- ³
	//³ cao anterior.                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//SAVE oxml XMLFILE ALLTRIM(MV_PAR07)
	fClose(nHdl)
	Close(oGeraTxt)
	IF MV_PAR08==2
		If ! ApOleClient( 'MsExcel' )        							//Verifica se o Excel esta instalado
			MsgStop( 'MsExcel nao instalado' )
			Return
		EndIf

		oExcelApp := MsExcel():New()										// Cria um objeto para o uso do Excel
		oExcelApp:WorkBooks:Open( cArq )	// Atribui à propriedade WorkBooks do Excel
		oExcelApp:SetVisible(.T.)											// Abre o Excel com o arquivo criado exibido na Primeira planilha.
		oExcelApp:Destroy()

	ENDIF
Return

//tp,cod,desc,est,qini,und,preco,chave,tpnfe,codnfe,qtdnfe,prcnfe,npos,npos2
static Function getObjXML()
	Local cXML := ""
	Local cError   := ""
	Local cWarning := ""
	Private oXml := NIL
	//Gera o Objeto XML
	oXml := XmlParser( GeraXMLT(), "_", @cError, @cWarning )
	If (oXml == NIL )
		MsgStop("Falha ao gerar Objeto XML : "+cError+" / "+cWarning)
		Return
	Endif
	//verifica quantos elementos possuo
	//conout( XmlChildCount( oXml:_PEDIDO ) )
	//para uso de conteudo de tags com caractes especiais
	//Local cNome    := 'A&B-ZÃO LTDA'
	//cXml +="<empresa>"
	//cXml += EncodeUTF8( _NoTags( cNome ) )
	//cXml +="</empresa>"
	XmlNewNode ( OXML:_PEDIDOS:_ITENS, 'Item', 'Item', "NOD" )
	//ADDNODE OXML:_ENVSCOA:_LISTAARMAZENAGEM:_DADOSARMAZEM:_LISTAPRODUTOSINVENTARIO:_LISTANOTASFISCAIS:_NOTAFISCAL NODE '_NOTAFISCAL' ON oXML
	if tp==1
		if npos>2
			ADDNODE OXML:_ENVSCOA:_LISTAARMAZENAGEM:_DADOSARMAZEM:_LISTAPRODUTOSINVENTARIO:_PRODUTOINVENTARIO NODE '_PRODUTOINVENTARIO' ON oXML
		endif
		//setando o CONTEUDO do meu nodo ""
		oxml:_ENVSCOA:_LISTAARMAZENAGEM:_DADOSARMAZEM:_LISTAPRODUTOSINVENTARIO:_PRODUTOINVENTARIO[npos]:_CODPRODUTO:Text      := cod
		oxml:_ENVSCOA:_LISTAARMAZENAGEM:_DADOSARMAZEM:_LISTAPRODUTOSINVENTARIO:_PRODUTOINVENTARIO[npos]:_DESCPRODUTO:Text     := desc
		oxml:_ENVSCOA:_LISTAARMAZENAGEM:_DADOSARMAZEM:_LISTAPRODUTOSINVENTARIO:_PRODUTOINVENTARIO[npos]:_CREDITOESTIMULO:Text := est
		oxml:_ENVSCOA:_LISTAARMAZENAGEM:_DADOSARMAZEM:_LISTAPRODUTOSINVENTARIO:_PRODUTOINVENTARIO[npos]:_ESTOQUEINICIAL:Text  := qini
		oxml:_ENVSCOA:_LISTAARMAZENAGEM:_DADOSARMAZEM:_LISTAPRODUTOSINVENTARIO:_PRODUTOINVENTARIO[npos]:_UNIDPRODUTO:Text      := und
		oxml:_ENVSCOA:_LISTAARMAZENAGEM:_DADOSARMAZEM:_LISTAPRODUTOSINVENTARIO:_PRODUTOINVENTARIO[npos]:_PRECOUNITPRODUTO:Text := preco

	elseif tp==2
		if npos>2
			ADDNODE OXML:_ENVSCOA:_LISTAARMAZENAGEM:_DADOSARMAZEM:_LISTAPRODUTOSINVENTARIO:_LISTANOTASFISCAIS:_NOTAFISCAL NODE '_NOTAFISCAL' ON oXML
		endif

		oxml:_ENVSCOA:_LISTAARMAZENAGEM:_DADOSARMAZEM:_LISTAPRODUTOSINVENTARIO:_LISTANOTASFISCAIS:_NOTAFISCAL[npos]:_CHAVEACESSONFE:Text :=chave
		oxml:_ENVSCOA:_LISTAARMAZENAGEM:_DADOSARMAZEM:_LISTAPRODUTOSINVENTARIO:_LISTANOTASFISCAIS:_NOTAFISCAL[npos]:_TIPOOPERACAO:Text :=tpnfe

	elseif tp==3
		if npos2>2
			ADDNODE oxml:_ENVSCOA:_LISTAARMAZENAGEM:_DADOSARMAZEM:_LISTAPRODUTOSINVENTARIO:_LISTANOTASFISCAIS:_NOTAFISCAL[npos]:_LISTAPRODUTOSNFE:_PRODUTONFE NODE '_PRODUTONFE' ON oXML
		endif
		//editar o produto
		oxml:_ENVSCOA:_LISTAARMAZENAGEM:_DADOSARMAZEM:_LISTAPRODUTOSINVENTARIO:_LISTANOTASFISCAIS:_NOTAFISCAL[npos]:_LISTAPRODUTOSNFE:_PRODUTONFE[npos2]:_CODPRODUTONFE:Text :=codnfe
		oxml:_ENVSCOA:_LISTAARMAZENAGEM:_DADOSARMAZEM:_LISTAPRODUTOSINVENTARIO:_LISTANOTASFISCAIS:_NOTAFISCAL[npos]:_LISTAPRODUTOSNFE:_PRODUTONFE[npos2]:_QUANTIDADE:Text :=qtdnfe
		oxml:_ENVSCOA:_LISTAARMAZENAGEM:_DADOSARMAZEM:_LISTAPRODUTOSINVENTARIO:_LISTANOTASFISCAIS:_NOTAFISCAL[npos]:_LISTAPRODUTOSNFE:_PRODUTONFE[npos2]:_PRECOUNITPRODUTONFE:Text :=prcnfe

		//verifica quantos elementos possuo depois da inserção
		//conout( XmlChildCount( oXml:_PEDIDO ) )

		// Tranforma o Objeto XML em string
		//SAVE oXml XMLSTRING cXML
		//POSICIONA NO ITEM
		//oScript := XmlParent( oScript:_PEDIDO:_ITENS:_ITEM[1] )
		//Tranforma o Objeto XML em arquivo
	endif
Return

// função para gerar uma string contendo um xml
Static Function GeraXML()
	Local cScript :='<?xml version="1.0" encoding="ISO-8859-1"?>'
	cScript += "<envSCOA>"
	cScript += "  <versao></versao>"
	cScript += "  <IE></IE>"
	cScript += "  <periodoArquivo></periodoArquivo>"
	cScript += "  <nomeResponsavel></nomeResponsavel>"
	cScript += "  <listaArmazenagem>"
	cScript += "   <dadosArmazem>"
	cScript += "    <numCNPJ></numCNPJ>"
	cScript += "    <numAtoDeclaratorio></numAtoDeclaratorio>"
	cScript += "    <validadeAtoDeclaratorio></validadeAtoDeclaratorio>"
	cScript += "    <listaProdutosInventario>"

	cScript += "      <produtoInventario>"
	cScript += "        <codProduto></codProduto>"
	cScript += "        <descProduto></descProduto>"
	cScript += "        <creditoEstimulo></creditoEstimulo>"
	cScript += "        <estoqueInicial></estoqueInicial>"
	cScript += "        <unidProduto></unidProduto>"
	cScript += "        <precoUnitProduto></precoUnitProduto>"
	cScript += "      </produtoInventario>

	cScript += "      <produtoInventario>"
	cScript += "        <codProduto></codProduto>"
	cScript += "        <descProduto></descProduto>"
	cScript += "        <creditoEstimulo></creditoEstimulo>"
	cScript += "        <estoqueInicial></estoqueInicial>"
	cScript += "        <unidProduto></unidProduto>"
	cScript += "        <precoUnitProduto></precoUnitProduto>"
	cScript += "      </produtoInventario>

	cScript += "      <listaNotasFiscais>"

	cScript += "       <notaFiscal>"
	cScript += "        <chaveAcessoNfe></chaveAcessoNfe>"
	cScript += "        <tipoOperacao></tipoOperacao>"
	cScript += "        <listaProdutosNfe>"
	cScript += "         <produtoNfe>"
	cScript += "          <codProdutoNfe></codProdutoNfe>"
	cScript += "          <quantidade></quantidade>"
	cScript += "          <precoUnitProdutoNfe></precoUnitProdutoNfe>"
	cScript += "         </produtoNfe>"
	cScript += "         <produtoNfe>"
	cScript += "          <codProdutoNfe></codProdutoNfe>"
	cScript += "          <quantidade></quantidade>"
	cScript += "          <precoUnitProdutoNfe></precoUnitProdutoNfe>"
	cScript += "         </produtoNfe>"
	cScript += "        </listaProdutosNfe>"
	cScript += "       </notaFiscal>"

	cScript += "       <notaFiscal>"
	cScript += "        <chaveAcessoNfe></chaveAcessoNfe>"
	cScript += "        <tipoOperacao></tipoOperacao>"
	cScript += "        <listaProdutosNfe>"
	cScript += "         <produtoNfe>"
	cScript += "          <codProdutoNfe></codProdutoNfe>"
	cScript += "          <quantidade></quantidade>"
	cScript += "          <precoUnitProdutoNfe></precoUnitProdutoNfe>"
	cScript += "         </produtoNfe>"
	cScript += "         <produtoNfe>"
	cScript += "          <codProdutoNfe></codProdutoNfe>"
	cScript += "          <quantidade></quantidade>"
	cScript += "          <precoUnitProdutoNfe></precoUnitProdutoNfe>"
	cScript += "         </produtoNfe>"
	cScript += "        </listaProdutosNfe>"
	cScript += "       </notaFiscal>"

	cScript += "      </listaNotasFiscais>"
	cScript += "    </listaProdutosInventario>"
	cScript += "   </dadosArmazem>"
	cScript += "  </listaArmazenagem>"
	cScript += "</envSCOA>"
Return cScript

Static Function GeraXMLT()
	Local cScript := '<?xml version="1.0" encoding="UTF-8"?>'
	cScript += "<pedido>"
	cScript += "  <NomeCliente>Microsiga Software S/A</NomeCliente>"
	cScript += "  <Endereco>Av. Braz Leme</Endereco>"
	cScript += "  <Numero>1361</Numero>"
	cScript += "  <Data>22-03-2005</Data>"
	cScript += "  <Itens>"
	cScript += "    <Item>"
	cScript += "      <Produto>Prothues</Produto>"
	cScript += "      <Quantidade>1</Quantidade>"
	cScript += "      <Preco>100.00</Preco>"
	cScript += "    </Item>"
	cScript += "    <Item>"
	cScript += "      <Produto>ERP</Produto>"
	cScript += "      <Quantidade>0</Quantidade>"
	cScript += "      <Preco>0</Preco>"
	cScript += "    </Item>"
	cScript += "  </Itens>"
	cScript += "</pedido>"
Return cScript

Static Function ValidPerg(cPerg)
	PutSX1(cPerg,"01","Data Inicio  ?"                     , "", "", "mv_ch1", "D", 8,00,00,"G",""    ,"   ",""   ,"","mv_par01")
	PutSX1(cPerg,"02","Responsavel  ?"                     , "", "", "mv_ch2", "C",60,00,00,"G",""    ,"   ",""   ,"","mv_par02")
	PutSX1(cPerg,"03","Clientes ?"                         , "", "", "mv_ch3", "C", 6,00,00,"G",""    ,"   ","SA1","","mv_par03")
	PutSX1(cPerg,"04","Perc.Estimulo Ex:005500 (55%)?"     , "", "", "mv_ch4", "C", 5,00,00,"G",""    ,"   ",""   ,"","mv_par04")
	PutSX1(cPerg,"05","Local e Arquivo ex: c:\temp\scoa?"  , "", "", "mv_ch5", "C",30,00,00,"G",""    ,"   ",""   ,"","mv_par05")
Return Nil