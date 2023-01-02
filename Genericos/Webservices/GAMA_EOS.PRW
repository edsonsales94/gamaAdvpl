#INCLUDE "PROTHEUS.CH" 
#INCLUDE 'TOTVS.CH'   
#INCLUDE "TBICONN.CH"
#INCLUDE "APWEBSRV.CH"  

#IFNDEF CRLF
	#DEFINE CRLF Chr(13)+Chr(10)
#ENDIF	

#DEFINE STR0001 "Brasitech - Servi&ccedil;o de inclusão dos pedidos de venda provenientes do sistema Assist"
#DEFINE STR0002 "M&eacute;todo de Inclus&atilde;o do Pedido de venda"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		GAMA_EOS                                                     /@
@type			Webservice                                                   /@
@date			01/04/2015                                                   /@
@description	Webservice de integração Protheus x Telecontrol para inclusão
				de pedidos de vendas.                                        /@
@author			Felippe Rainho (Opção Um Tecnologia)                         /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
WSSTRUCT tAddItemSTR
	WSDATA tzItensDoPedido			AS Array Of tAddPedidoItem
ENDWSSTRUCT

WSSTRUCT tAddPedidoItem
	WSDATA CODMATERIAL				AS String 	//C6_PRODUTO
	WSDATA QTD						AS Integer	//C6_QTDVEN
	WSDATA ARMZ						AS String	//C6_LOCAL
ENDWSSTRUCT

WSSTRUCT AReturn
	WSDATA COD						AS String
	WSDATA MSG						AS String
	WSDATA NumeroDoPedido			AS String
ENDWSSTRUCT
          
WSSERVICE GAMA_EOS DESCRIPTION STR0001 

	WSDATA NUMPEDIDO				AS String
	WSDATA DATAPEDIDO				AS String 
	WSDATA CODCLIENTE				AS String
	WSDATA tAddPedido				AS tAddItemSTR
	WSDATA StructReturn				AS AReturn
	
	WSMETHOD AddPedidoVenda    	DESCRIPTION STR0002	

ENDWSSERVICE


WSMETHOD AddPedidoVenda WSRECEIVE NUMPEDIDO,DATAPEDIDO,CODCLIENTE,tAddPedido WSSEND StructReturn  WSSERVICE GAMA_EOS


//———————————————————————————————————————————————————————————————————————————————
// Definição de variáveis
//———————————————————————————————————————————————————————————————————————————————
Local 	aCabPed, aItePed, cItem, cCliente, cLoja, nI, nK, nJ, lReturn, cErroPed, cProdErro, cPrecoErro,;
		cTpPedido, cMsgNotaOS, cMsgNotaPV, cCPGar, cCPVen, cTransp, cTabela, cDestinat, cMsgOcor, nVlFrt,;
		aLog, lOK, cNumPedGama, cProduto, cArmaz, nQuant, cTESuso, cMsgNotaUso
Private lAutoErrNoFile, lMsErroAuto


//———————————————————————————————————————————————————————————————————————————————
// Inicializando ambiente
//———————————————————————————————————————————————————————————————————————————————
lReturn		:= .T.
lOK			:= .F. // Valida se salvou o pedido
cNumPedGama := ""
cErroPed	:= ""
cProdErro	:= "" 
cPrecoErro	:= ""
cTESuso		:= ""
cMsgNotaUso := ""
cCPuso		:= ""
cTpPedido	:= Left(::NUMPEDIDO,2)
cMsgNotaOS	:= "Ref. seu pedido lote em garantia: " + ::NUMPEDIDO
cMsgNotaPV	:= "Ref. seu pedido: " + ::NUMPEDIDO
cMsgNotaPA	:= "Ref. seu pedido lote em garantia de Produto Acabado: " + ::NUMPEDIDO
cCPGar		:= GetMV("BR_WSCPGAR", .F., "")	//Condicao de pagamento para a criacao de pedidos de garantia na integracao por webservice com o sistema Telecontrol
cCPVen		:= GetMV("BR_WSCPVEN", .F., "")	//Condicao de pagamento para a criacao de pedidos de venda na integracao por webservice com o sistema Telecontrol
cStrFrete	:= GetMV("BR_WSFRTVD", .F., "")	//Valor de frete por estado para cobranca na criacao de pedidos de venda na integracao por webservice com o sistema Telecontrol
cTESGar		:= GetMV("BR_WSTESGR", .F., "")	//Codigo do TES para pedidos em garantia. Utilizado na integracao por webservice com o sistema Telecontrol
cTESVen		:= GetMV("BR_WSTESVD", .F., "")	//Codigo do TES para pedidos de venda de pecas. Utilizado na integracao por webservice com o sistema Telecontrol
cTESGarPA	:= GetMV("BR_WSTESPA", .F., "")	//Codigo do TES para pedidos Produto Acabado em garantia. Utilizado na integracao por webservice com o sistema Telecontrol
cTransp		:= GetMV("BR_WSPVSA4", .F., "")	//Codigo da transportadora para pedidos integrados pelo webservice com o sistema Telecontrol
cTabela		:= GetMV("BR_WSTABPR", .F., "")	//Codigo da tabela de preco para pedidos integrados pelo webservice com o sistema Telecontrol
cDestinat	:= GetMV("BR_WSEMEOS", .F., "sistemas@gamaitaly.com.br")	//Enderecos de emails p/ recebimento de ocorrencias no processamento de pedidos de venda ou garantia pela integracao com o webservice do Telecontrol
cMsgOcor	:= ""
nVlFrt		:= 0

//————————————————————————————————————————————————————————————————————————————
// Ordem das tabelas 
//————————————————————————————————————————————————————————————————————————————
SA1->(dbSetOrder(3))	//A1_FILIAL+A1_CGC
SA4->(dbSetOrder(1))	//A4_FILIAL+A4_COD
SB1->(dbSetOrder(1))	//B1_FILIAL+B1_COD
SB2->(dbSetOrder(1))	//B2_FILIAL+B2_COD+B2_LOCAL
SC6->(dbSetOrder(1))	//C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
SF4->(dbSetOrder(1))	//F4_FILIAL+F4_CODIGO
DA1->(dbSetOrder(1)) 	//DA1_FILIAL+DA1_CODTAB+DA1_CODPRO

lAutoErrNoFile	:= .T.
lMsErroAuto		:= .F.

ConOut(Repl("-",80))
ConOut(PadC("WebService Inclusao de Pedidos GAMA_EOS Assitencia Tecnica " + Time(), 80))

aCabPed		:= {}
aItePed		:= {}
cItem		:= "01"

For nI := 1 to Len(::tAddPedido:tzItensDoPedido) 

	cProduto	:= PadR(::tAddPedido:tzItensDoPedido[nI]:CODMATERIAL, 15)
	cArmaz		:= PadR(::tAddPedido:tzItensDoPedido[nI]:ARMZ ,2)
	nQuant		:= ::tAddPedido:tzItensDoPedido[nI]:QTD

	if Len(aCabPed) == 0

		If SB1->(dbSeek(xFilial("SB1") + cProduto))
			if SB1->B1_TIPO == "PA"
				cCPuso		:= cCPGar
				cTESuso		:= cTESGarPA
				cMsgNotaUso	:= "Ref. seu pedido lote em garantia de Produto Acabado: " + ::NUMPEDIDO
			else
				if cTpPedido == "OS"
					cCPuso		:= cCPGar
					cTESuso		:= cTESGar
					cMsgNotaUso	:= "Ref. seu pedido lote em garantia: " + ::NUMPEDIDO
				elseif cTpPedido == "PV"
					cCPuso		:= cCPVen
					cTESuso		:= cTESVen
					cMsgNotaUso	:= "Ref. seu pedido: " + ::NUMPEDIDO
				endif
			endif
		Endif

		//————————————————————————————————————————————————————————————————————————————
		// Verifico e valido o Tipo de Pedido
		//————————————————————————————————————————————————————————————————————————————
		SC5->(dbSetOrder(13))	//C5_FILIAL, C5_PEDCLI
		if !(cTpPedido $ "PV/OS") 
			cErroPed	:= "Nao informado no codigo do Pedido informacao PV ou OS" + chr(13) + chr(10)
		elseif SC5->(dbSeek(xFilial("SC5") + Left(::NUMPEDIDO, Len(SC5->C5_PEDCLI))))
			cErroPed	:= "Pedido Telecontrol No.: " + Left(AllTrim(::NUMPEDIDO),2) + ' '+  Substring(AllTrim(::NUMPEDIDO),3,10) + " ja cadastrado no Protheus Filial: " + SC5->C5_FILIAL +" No.: " + SC5->C5_NUM + chr(13) + chr(10)
		endif

		SC5->(dbSetOrder(1))	//C5_FILIAL, C5_NUM

		cCliente	:= Space(8)
		cLoja		:= Space(2)
		If !(SA1->(dbSeek(xFilial("SA1") + ::CODCLIENTE)))
			cErroPed += "Cliente CNPJ " + ::CODCLIENTE + " nao cadastrado." + chr(13) + chr(10)
			exit
		else
			cCliente	:= SA1->A1_COD
			cLoja		:= SA1->A1_LOJA

			//————————————————————————————————————————————————————————————————————————————
			// Identificando o valor do frete
			//————————————————————————————————————————————————————————————————————————————
			if cTpPedido == "PV"
				cStrFrete := StrTran(cStrFrete, "#", chr(13) + chr(10))
				for nK := 1 to MlCount(cStrFrete)
					if SA1->A1_EST $ MemoLine(cStrFrete, nK)
						nVlFrt := MemoLine(cStrFrete, nK)
						nVlFrt := StrTran(nVlFrt, SA1->A1_EST, "")
						nVlFrt := Val(nVlFrt)
					endif
				next
			endif
			
		Endif 

		//————————————————————————————————————————————————————————————————————————————
		// Array Cabeçalho do Pedido
		//————————————————————————————————————————————————————————————————————————————
		aCabPed	:= {	{"C5_TIPO",		"N",									NIL},;
						{"C5_X_ORIG" ,	"1",									NIL},;
						{"C5_CLIENTE",	cCliente,								NIL},;
						{"C5_LOJACLI",	cLoja,									NIL},;
						{"C5_CLIENT",	cCliente,								NIL},;
						{"C5_LOJAENT",	cLoja,									NIL},;
						{"C5_VEND1" ,	"1379",									NIL},;
						{"C5_EMISSAO",	Date(),									NIL},;
						{"C5_CONDPAG",	cCPuso,									NIL},;
						{"C5_TRANSP",	cTransp,								NIL},;
						{"C5_VOLUME1",	1,										NIL},;
						{"C5_ESPECI1",	"CAIXA",								NIL},;
						{"C5_TABELA",	cTabela,								NIL},;
						{"C5_PEDCLI",	::NUMPEDIDO,							NIL},;
						{"C5_MENNOT1",	cMsgNotaUso,							NIL},;
						{"C5_TPFRETE",	"C",		  							NIL},;
						{"C5_XECTTRA",	"2",									NIL},;
						{"C5_XECTCAR",	"69094225",								NIL},; 
						{"C5_FRETE",	iif(cTpPedido == "PV", nVlFrt, 0),		NIL}}
	endif
	
	If !(SB1->(dbSeek(xFilial("SB1") + cProduto))) .or. SB1->B1_MSBLQL == "1"
		cProdErro += AllTrim(cProduto) + " | "
	Endif

	IF !(DA1->(dbSeek(xFilial("DA1") + cTabela + cProduto)))
		cPrecoErro += AllTrim(cProduto) + " | "
	Endif
 	
	If !(SB2->(dbSeek(xFilial("SB2") + cProduto + cArmaz))) 
		//————————————————————————————————————————————————————————————————————————————
		// Cria registro SB2
		//————————————————————————————————————————————————————————————————————————————
		if fValArmz(cArmaz)
			CriaSB2(cProduto, cArmaz)
		else
			cProdErro += "Erro ao criar o Armazem informado : " + cArmaz
		endif
	EndIf

	//————————————————————————————————————————————————————————————————————————————
	// Adiciono o item no array de itens para o MsExecAuto
	//————————————————————————————————————————————————————————————————————————————
	aAdd(aItePed, {	{"C6_ITEM",		cItem,					NIL},;
					{"C6_PRODUTO",	cProduto,				NIL},;
					{"C6_TES",		cTESuso,				NIL},;
					{"C6_LOCAL",	cArmaz,					NIL},;
					{"C6_QTDVEN",	nQuant,					NIL},;
					{"C6_QTDLIB",	0,						NIL},;
					{"C6_PEDCLI",	AllTrim(::NUMPEDIDO),	NIL}})

	cItem	:= Soma1(cItem)
						
Next

//————————————————————————————————————————————————————————————————————————————
// Verifico se o pedido será gravado
//————————————————————————————————————————————————————————————————————————————
if Len(aCabPed) > 0 .and. Len(aItePed) > 0

	Begin Transaction
		
		if !Empty(cErroPed)
		
			cMsgOcor := "ERRO - " + cErroPed
			::StructReturn:COD := "2" 
			::StructReturn:MSG := cMsgOcor
			::StructReturn:NumeroDoPedido := " "
		
		else
		
			if cProdErro <> ""
			
				cMsgOcor := "ERRO - Produto |" + cProdErro + " nao encontrado ou bloqueado para uso."
				::StructReturn:COD := "2" 
				::StructReturn:MSG := cMsgOcor
				::StructReturn:NumeroDoPedido := " "

			elseif cPrecoErro <> ""
			
				cMsgOcor := "ERRO - Produto |" + cPrecoErro + " nao encontrado na tabela de preco: "+cTabela
				::StructReturn:COD := "2" 
				::StructReturn:MSG := cMsgOcor
				::StructReturn:NumeroDoPedido := " "
			
			else

				MsExecAuto({ |x, y, z| MATA410(x, y, z) }, aCabPed, aItePed, 3)
				
				if lMsErroAuto

					aLog 		:= GetAutoGRLog()
					cMsgOcor	:= "Falha na Inclusao - "
					for nJ := 1 to len(aLog)
						cMsgOcor += aLog[nJ]
					next
				
					DisarmTransaction()
					::StructReturn:COD	:= "2" 
					::StructReturn:MSG	:= Left(cMsgOcor, 100)

				else

					cMsgOcor := "SUCESSO na inclusao do pedido da Assintencia Tecnica " + SC5->C5_NUM
					::StructReturn:COD	:= "1" 
					::StructReturn:MSG	:= cMsgOcor
					::StructReturn:NumeroDoPedido := SC5->C5_NUM
					lOK:=.T.

				endIf										
				
			endif
			
		endif

	End Transaction

	ConOut(PadC(cMsgOcor, 80))

	//————————————————————————————————————————————————————————————————————————————
	// Envio de e-mail sobre a operação realizada
	//————————————————————————————————————————————————————————————————————————————
	if !Empty(cDestinat)

		if lOk
			cMsgOcor := fMontaXmlPV(SC5->C5_NUM)
		endif
		U_GISendMail(cDestinat,, iif(lOk,"","Erro na ") + "Integração Telecontrol x Protheus (EOS) pedido Telecontrol " + Left(AllTrim(::NUMPEDIDO),2) + ' '+ Substring(AllTrim(::NUMPEDIDO),3,10), cMsgOcor)
	endif

else
	
	ConOut("Sem itens validos para pedido | " + AllTrim(cErroPed) + "|" + AllTrim(cProdErro) + "|" + AllTrim(cPrecoErro))

endif

ConOut(PadC("FIM - WebService GAMA_EOS: " + Time(), 80))
ConOut(Repl("-",80))

Return(lReturn)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		FVALARMZ                                                     /@
@type			Static Function                                              /@
@date			11/05/2022                                                   /@
@description	Valida o armazem.                                            /@
@author			Ricky Elenita                                                /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function fValArmz(cLocal)
Local lRet		:= .T.
Local cTabela	:= FWGetSX5("74", cLocal)

if cLocal == "20"
	ConOut('SIGAWMS - AVISO', 'Armazem de Processo, Usar rotina de pagamento !')
elseif cTabela == NIL
	lRet := .F.
	ConOut('SIGAWMS - AVISO', 'O Armazem ' + Alltrim(cLocal) + ' nao existe.')
endif

/*DBSelectArea('SX5')
DBSetOrder(1)
IF !DBSeek(xFilial('SX5')+ "74" + cLocal )
	ConOut('SIGAWMS - AVISO', 'O Armazem '+Alltrim(cLocal)+' nao existe.')
	lRet:=.F.
ELSE 
 IF cLocal<>"20"
   lRet:=.T.
 ELSE
  	ConOut('SIGAWMS - AVISO', 'Armazem de Processo, Usar rotina de pagamento !')
 Endif   
endif*/
Return(lRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		FMONTAXMLPV                                                  /@
@type			Static Function                                              /@
@date			11/05/2022                                                   /@
@description	Monta html para envio de informacoes de pedido incluido.     /@
@author			Ricky Elenita                                                /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function fMontaXmlPV(cNumPedVenda)
Local _cHTML		:= ''
Local _cHoraAtu,_cNumPedCli,_cNomeCli,_cCodCli,_cEnd,_cObs,_cItem,_cCodigoPro,_cDescricao,_cQtde,_cData,_cNumPedProtheus,_cFilial
Private cAliasHTML	:= GetNextAlias()

//CARREGA SELECT COM AS VARIAVES DO HTML
BeginSql Alias cAliasHTML

	COLUMN C5_EMISSAO AS DATE
		SELECT 
		C5_FILIAL,C5_EMISSAO,C5_NUM,C5_CLIENT,C5_LOJACLI,C5_NOMECLI,C5_TABELA,C5_PEDCLI,C5_MENNOT1
		,C6_ITEM,C6_PRODUTO,B1_DESC,C6_LOCAL,C6_QTDVEN,C6_TES,C6_PRCVEN,C6_VALOR
		,A1_EMAIL,A1_END,A1_EST,A1_MUN
		FROM SC5010 SC5 (NOLOCK)
		CROSS APPLY ( SELECT A1_EMAIL,A1_END,A1_EST,A1_MUN FROM %Table:SA1% SA1
						WHERE A1_COD=C5_CLIENT AND A1_LOJA=C5_LOJACLI
						AND A1_FILIAL= %xFilial:SA1%  ) SA1
		CROSS APPLY ( SELECT C6_ITEM,C6_PRODUTO,B1_DESC,C6_LOCAL,C6_TES,C6_QTDVEN,C6_PRCVEN,C6_VALOR 
						FROM %Table:SC6% SC6 (NOLOCK)
						CROSS APPLY ( 
							SELECT B1_DESC FROM %Table:SB1% SB1 (NOLOCK) 
							WHERE B1_COD=C6_PRODUTO
							AND SB1.%NotDel% 
							)SB1
						WHERE 
						C6_FILIAL=C5_FILIAL 
						AND C6_NUM=C5_NUM
						AND SC6.%NotDel% 
						)SC6
		WHERE 
		C5_FILIAL= %xFilial:SC5%
		AND SC5.%NotDel% 
		AND C5_NUM=%Exp:cNumPedVenda%
		ORDER BY C6_ITEM
EndSQL	

dbSelectArea(cAliasHTML)  
dbgotop()

_cHoraAtu			:= TIME()
_cNumPedProtheus	:= (cAliasHTML)->C5_NUM
_cFilial			:= (cAliasHTML)->C5_FILIAL
_cData				:= DTOC((cAliasHTML)->C5_EMISSAO) 
_cNumPedCli			:= (cAliasHTML)->C5_PEDCLI
_cNomeCli			:= (cAliasHTML)->C5_NOMECLI
_cCodCli			:= (cAliasHTML)->C5_CLIENT
_cEnd				:= (cAliasHTML)->A1_END
_cObs				:= (cAliasHTML)->C5_MENNOT1
_cItem				:= (cAliasHTML)->C6_ITEM
_cCodigoPro			:= (cAliasHTML)->C6_PRODUTO
_cDescricao			:= (cAliasHTML)->B1_DESC
_cQtde				:= Transform((cAliasHTML)->C6_QTDVEN, "@E 99,999.99") 

_cHTML +='<!DOCTYPE html>																																																		 '
_cHTML +='<html lang="pt-br" xmlns="http://www.w3.org/1999/xhtml" xmlns:o="urn:schemas-microsoft-com:office:office">																																							 '
_cHTML +='																																																				 '
_cHTML +='<head>																																																			 '
_cHTML +='																																																				 '
_cHTML +='    <meta charset="utf-8">																																																	 '
_cHTML +='    <meta http-equiv="x-ua-compatible" content="ie=edge">																																													 '
_cHTML +='																																																				 '
_cHTML +='    <title>Email Confirmation</title>																																																 '
_cHTML +='    <meta name="viewport" content="width=device-width, initial-scale=1">																																											 '
_cHTML +='    <style type="text/css">																																																	 '
_cHTML +='        /**																																																			 '
_cHTML +='   * Google webfonts. Recommended to include the .woff version for cross-client compatibility.																																								 '
_cHTML +='   */																																																				 '
_cHTML +='        																																																			 '
_cHTML +='        @media screen {																																																	 '
_cHTML +='            @font-face {																																																	 '
_cHTML +='                font-family: "Source Sans Pro";																																														 '
_cHTML +='                font-style: normal;																																																 '
_cHTML +='                font-weight: 400;																																																 '
_cHTML +='                src: local("Source Sans Pro Regular"), local("SourceSansPro-Regular"), url(https://fonts.gstatic.com/s/sourcesanspro/v10/ODelI1aHBYDBqgeIAH2zlBM0YzuT7MdOe03otPbuUS0.woff) format("woff");																											 '
_cHTML +='            }																																																			 '
_cHTML +='            @font-face {																																																	 '
_cHTML +='                font-family: "Source Sans Pro";																																														 '
_cHTML +='                font-style: normal;																																																 '
_cHTML +='                font-weight: 700;																																																 '
_cHTML +='                src: local("Source Sans Pro Bold"), local("SourceSansPro-Bold"), url(https://fonts.gstatic.com/s/sourcesanspro/v10/toadOcfmlt9b38dHJxOBGFkQc6VGVFSmCnC_l7QZG60.woff) format("woff");																												 '
_cHTML +='            }																																																			 '
_cHTML +='        }																																																			 '
_cHTML +='        /**																																																			 '
_cHTML +='   * Avoid browser level font resizing.																																															 '
_cHTML +='   * 1. Windows Mobile																																																	 '
_cHTML +='   * 2. iOS / OSX																																																		 '
_cHTML +='   */																																																				 '
_cHTML +='        																																																			 '
_cHTML +='        body,																																																			 '
_cHTML +='        table,																																																		 '
_cHTML +='        td,																																																			 '
_cHTML +='        a {																																																			 '
_cHTML +='            -ms-text-size-adjust: 100%;																																															 '
_cHTML +='            /* 1 */																																																		 '
_cHTML +='            -webkit-text-size-adjust: 100%;																																															 '
_cHTML +='            /* 2 */																																																		 '
_cHTML +='        }																																																			 '
_cHTML +='        /**																																																			 '
_cHTML +='   * Remove extra space added to tables and cells in Outlook.																																													 '
_cHTML +='   */																																																				 '
_cHTML +='        																																																			 '
_cHTML +='        table,																																																		 '
_cHTML +='        td {																																																			 '
_cHTML +='            mso-table-rspace: 0pt;																																																 '
_cHTML +='            mso-table-lspace: 0pt;																																																 '
_cHTML +='        }																																																			 '
_cHTML +='        																																																			 '
_cHTML +='        #demo-table thead {																																																	 '
_cHTML +='            color: white;																																																	 '
_cHTML +='            background-color: black;																																																 '
_cHTML +='        }																																																			 '
_cHTML +='        																																																			 '
_cHTML +='        #demo-table td {																																																	 '
_cHTML +='            padding: 0.25rem;																																																	 '
_cHTML +='            text-align: left;																																																	 '
_cHTML +='            border: 1px solid #d4dadf;																																															 '
_cHTML +='            border-style: solid;																																																 '
_cHTML +='            border-width: thin;																																																 '
_cHTML +='        }																																																			 '
_cHTML +='        /**																																																			 '
_cHTML +='   * Better fluid images in Internet Explorer.																																														 '
_cHTML +='   */																																																				 '
_cHTML +='        																																																			 '
_cHTML +='        img {																																																			 '
_cHTML +='            -ms-interpolation-mode: bicubic;																																															 '
_cHTML +='        }																																																			 '
_cHTML +='        /**																																																			 '
_cHTML +='   * Remove blue links for iOS devices.																																															 '
_cHTML +='   */																																																				 '
_cHTML +='        																																																			 '
_cHTML +='        a[x-apple-data-detectors] {																																																 '
_cHTML +='            font-family: inherit !important;																																															 '
_cHTML +='            font-size: inherit !important;																																															 '
_cHTML +='            font-weight: inherit !important;																																															 '
_cHTML +='            line-height: inherit !important;																																															 '
_cHTML +='            color: inherit !important;																																															 '
_cHTML +='            text-decoration: none !important;																																															 '
_cHTML +='        }																																																			 '
_cHTML +='        /**																																																			 '
_cHTML +='   * Fix centering issues in Android 4.4.																																															 '
_cHTML +='   */																																																				 '
_cHTML +='        																																																			 '
_cHTML +='        div[style*="margin: 16px 0;"] {																																															 '
_cHTML +='            margin: 0 !important;																																																 '
_cHTML +='        }																																																			 '
_cHTML +='        																																																			 '
_cHTML +='        body {																																																		 '
_cHTML +='            width: 100% !important;																																																 '
_cHTML +='            height: 100% !important;																																																 '
_cHTML +='            padding: 0 !important;																																																 '
_cHTML +='            margin: 0 !important;																																																 '
_cHTML +='        }																																																			 '
_cHTML +='        /**																																																			 '
_cHTML +='   * Collapse table borders to avoid space between cells.																																													 '
_cHTML +='   */																																																				 '
_cHTML +='        																																																			 '
_cHTML +='        table {																																																		 '
_cHTML +='            border-collapse: collapse !important;																																														 '
_cHTML +='        }																																																			 '
_cHTML +='        																																																			 '
_cHTML +='        a {																																																			 '
_cHTML +='            color: #1a82e2;																																																	 '
_cHTML +='        }																																																			 '
_cHTML +='        																																																			 '
_cHTML +='        img {																																																			 '
_cHTML +='            height: auto;																																																	 '
_cHTML +='            line-height: 100%;																																																 '
_cHTML +='            text-decoration: none;																																																 '
_cHTML +='            border: 0;																																																	 '
_cHTML +='            outline: none;																																																	 '
_cHTML +='        }																																																			 '
_cHTML +='    </style>																																																			 '
_cHTML +='																																																				 '
_cHTML +='</head>																																																			 '
_cHTML +='																																																				 '
_cHTML +='<body style="background-color: #e5e7e9;">																																															 '
_cHTML +='																																																				 '
_cHTML +='    <!-- start body -->																																																	 '
_cHTML +='    <table border="0" cellpadding="0" cellspacing="0" width="100%">																																												 '
_cHTML +='																																																				 '
_cHTML +='        <!-- start logo -->																																																	 '
_cHTML +='        <tr>																																																			 '
_cHTML +='            <td align="center" bgcolor="#e9ecef">																																														 '
_cHTML +='                <!--[if (gte mso 9)|(IE)]>																																															 '
_cHTML +='                    <table align="center" border="0" cellpadding="0" cellspacing="0" width="600">																																								 '
_cHTML +='                    <tr>																																																	 '
_cHTML +='                    <td align="center" valign="top" width="600">																																												 '
_cHTML +='                    <![endif]-->																																																 '
_cHTML +='                <table border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width: 600px;">																																							 '
_cHTML +='                    <tr>																																																	 '
_cHTML +='                        <td align="left" valign="top" style="padding: 36px 24px;">																																										 '
_cHTML +='                            <img src="https://gamaitaly.vteximg.com.br/arquivos/logo.png" alt="Gama">																																								 '
_cHTML +='                        </td>																																																	 '
_cHTML +='                        <td align="center" valign="top" style="padding: 24px 24px 0; font-family:  Source Sans Pro , Helvetica, Arial, sans-serif;">																																		 '
_cHTML +='                            <h2>TELECONTROL</h2>																																														 '
_cHTML +='                            <h3>Assistência Técnica</h3>																																													 '
_cHTML +='                        </td>																																																	 '
_cHTML +='                        <td width="25%" align="left" valign="top" style="padding: 60px 24px 0; font-family:  Source Sans Pro , Helvetica, Arial, sans-serif;">																																 '
_cHTML +='                            <table>																																																 '
_cHTML +='                                <tr>																																																 '
_cHTML +='                                    <td style="text-align: right;">Emissão </td>																																										 '
_cHTML +='                                    <td>'+ _cData 
_cHTML +='                                    </td>																																															 '
_cHTML +='                                </tr>																																																 '
_cHTML +='                                <tr>																																																 '
_cHTML +='                                    <td style="text-align: right;">Hora </td>																																											 '
_cHTML +='                                    <td>'+_cHoraAtu+'</td>																																													 '
_cHTML +='                                </tr>																																																 '
_cHTML +='                            </table>																																																 '
_cHTML +='                        </td>																																																	 '
_cHTML +='                    </tr>																																																	 '
_cHTML +='                </table>																																																	 '
_cHTML +='																																																				 '
_cHTML +='																																																				 '
_cHTML +='                <!--[if (gte mso 9)|(IE)]>																																															 '
_cHTML +='                        </td>																																																	 '
_cHTML +='                        </tr>																																																	 '
_cHTML +='                        </table>																																																 '
_cHTML +='                        <![endif]-->																																																 '
_cHTML +='            </td>																																																		 '
_cHTML +='        </tr>																																																			 '
_cHTML +='        <!-- end logo -->																																																	 '
_cHTML +='																																																				 '
_cHTML +='        <!-- start hero -->																																																	 '
_cHTML +='        <tr>																																																			 '
_cHTML +='            <td align="center" bgcolor="#e9ecef">																																														 '
_cHTML +='                <!--[if (gte mso 9)|(IE)]>																																															 '
_cHTML +='        <table align="center" border="0" cellpadding="0" cellspacing="0" width="600">																																										 '
_cHTML +='        <tr>																																																			 '
_cHTML +='        <td align="center" valign="top" width="600">																																														 '
_cHTML +='        <![endif]-->																																																		 '
_cHTML +='                <table border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width: 600px;">																																							 '
_cHTML +='                    <tr>																																																	 '
_cHTML +='                        <td align="left" bgcolor="#ffffff" style="padding: 5px 24px 0; font-family:  Source Sans Pro , Helvetica, Arial, sans-serif; border-top: 3px solid #d4dadf;">																														 '
_cHTML +='                            <h1 style="margin: 0; font-size: 22px; font-weight: 700; letter-spacing: -1px; line-height: 48px;">																																				 '
_cHTML +='                                Confirmação Protheus : '+_cNumPedProtheus+' | '+ _cFilial+ '																																												 '
_cHTML +='                            </h1>																																																 '
_cHTML +='                        </td>																																																	 '
_cHTML +='                    </tr>																																																	 '
_cHTML +='                </table>																																																	 '
_cHTML +='                <!--[if (gte mso 9)|(IE)]>																																															 '
_cHTML +='        </td>																																																			 '
_cHTML +='        </tr>																																																			 '
_cHTML +='        </table>																																																		 '
_cHTML +='        <![endif]-->																																																		 '
_cHTML +='            </td>																																																		 '
_cHTML +='        </tr>																																																			 '
_cHTML +='        <!-- end hero -->																																																	 '
_cHTML +='																																																				 '
_cHTML +='        <!-- start copy block -->																																																 '
_cHTML +='        <tr>																																																			 '
_cHTML +='            <td align="center" bgcolor="#e9ecef">																																														 '
_cHTML +='                <!--[if (gte mso 9)|(IE)]>																																															 '
_cHTML +='                <table align="center" border="0" cellpadding="0" cellspacing="0" width="600">																																									 '
_cHTML +='                <tr>																																																		 '
_cHTML +='                <td align="center" valign="top" width="600">																																													 '
_cHTML +='                <![endif]-->																																																	 '
_cHTML +='                <table border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width: 600px;">																																							 '
_cHTML +='                    <!-- start copy -->																																															 '
_cHTML +='                    <tr>																																																	 '
_cHTML +='                        <td align="left" bgcolor="#ffffff" style="padding: 5px 24px 0; font-family:  Source Sans Pro , Helvetica, Arial, sans-serif; font-size: 16px; line-height: 24px;">																													 '
_cHTML +='                            <!-- Cabeçalho -->																																														 '
_cHTML +='                            <table>																																																 '
_cHTML +='                                <tr>																																																 '
_cHTML +='                                    <p style="margin: 0;">OS/PV No.: <b>'+_cNumPedCli+'</b> </p>																																								 '
_cHTML +='                                    <p style="margin: 0;">Cliente : '+ _cCodCli + '-'+ _cNomeCli + '</p>																																										 '
_cHTML +='                                    <p style="margin: 0;">Endereco : '+ _cEnd + '</p>																																										 '
_cHTML +='                                    <p style="margin: 0;">Obsevações : '+ _cObs + '</p>																																									 '
_cHTML +='                                </tr>																																																 '
_cHTML +='                            </table>																																																 '
_cHTML +='																																																				 '
_cHTML +='                        </td>																																																	 '
_cHTML +='                    </tr>																																																	 '
_cHTML +='                    <!-- end copy -->																																																 '
_cHTML +='																																																				 '
_cHTML +='                    <!-- start copy -->																																															 '
_cHTML +='                    <tr>																																																	 '
_cHTML +='                        <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family:  Source Sans Pro , Helvetica, Arial, sans-serif; font-size: 16px; line-height: 24px;">																														 '
_cHTML +='                            <table border="1" cellpadding="0" cellspacing="0" width="100%" style="max-width: 600px;">																																				 '
_cHTML +='                                <thead>																																															 '
_cHTML +='                                    <tr>																																															 '
_cHTML +='                                        <th width="10%">Item</th>																																												 '
_cHTML +='                                        <th width="22%">Codigo</th>																																												 '
_cHTML +='                                        <th width="53%">Descrição</th>																																											 '
_cHTML +='                                        <th width="15%">Qtde</th>																																												 '
_cHTML +='																																																				 '
_cHTML +='                                    </tr>																																															 '
_cHTML +='                                </thead>																																															 '

//carrega Itens no Html
While !EOF()
	_cHTML +='                                <tr>	
	_cHTML +='                                    <td align="center">'+ (cAliasHTML)->C6_ITEM+'</td>																																													 '
	_cHTML +='                                    <td align="left">' + (cAliasHTML)->C6_PRODUTO+ '</td>																																												 '
	_cHTML +='                                    <td align="left">'+ (cAliasHTML)->B1_DESC+'</td>																																												 '
	_cHTML +='                                    <td align="center">'+ Transform((cAliasHTML)->C6_QTDVEN, "@E 99,999")  +'</td>																																													 '
	_cHTML +='                                </tr>																																																 '
	dbSkip()	
enddo	

_cHTML +='                            </table>																																																 '
_cHTML +='                        </td>																																																	 '
_cHTML +='                    </tr>																																																	 '
_cHTML +='                    <!-- end copy -->																																																 '
_cHTML +='																																																				 '
_cHTML +='                </table>																																																	 '
_cHTML +='                <!--[if (gte mso 9)|(IE)]>																																															 '
_cHTML +='                    </td>																																																	 '
_cHTML +='                    </tr>																																																	 '
_cHTML +='                    </table>																																																	 '
_cHTML +='                    <![endif]-->																																																 '
_cHTML +='            </td>																																																		 '
_cHTML +='        </tr>																																																			 '
_cHTML +='        <!-- end copy block -->																																																 '
_cHTML +='																																																				 '
_cHTML +='        <!-- start footer -->																																																	 '
_cHTML +='        <tr>																																																			 '
_cHTML +='            <td align="center" bgcolor="#e9ecef" style="padding: 24px;">																																											 '
_cHTML +='                <!--[if (gte mso 9)|(IE)]>																																															 '
_cHTML +='                <table align="center" border="0" cellpadding="0" cellspacing="0" width="600">																																									 '
_cHTML +='                <tr>																																																		 '
_cHTML +='                <td align="center" valign="top" width="600">																																													 '
_cHTML +='                <![endif]-->																																																	 '
_cHTML +='                <table border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width: 600px;">																																							 '
_cHTML +='																																																				 '
_cHTML +='                    <!-- start permission -->																																															 '
_cHTML +='                    <tr>																																																	 '
_cHTML +='                        <td align="center" bgcolor="#e9ecef" style="padding: 12px 24px; font-family: " Source Sans Pro ", Helvetica, Arial, sans-serif; font-size: 14px; line-height: 20px; color: #666;">																											 '
_cHTML +='                            <p style="margin: 0;">																																														 '
_cHTML +='                                Aviso / Sistema : Este documento é para uso interno, utilizado para geração e liberação de documentos, portanto sem valor Fiscal. </p>																																 '
_cHTML +='                        </td>																																																	 '
_cHTML +='                    </tr>																																																	 '
_cHTML +='                    <!-- end permission -->																																															 '
_cHTML +='                </table>																																																	 '
_cHTML +='                <!--[if (gte mso 9)|(IE)]>																																															 '
_cHTML +='                </td>																																																		 '
_cHTML +='                </tr>																																																		 '
_cHTML +='                </table>																																																	 '
_cHTML +='                <![endif]-->																																																	 '
_cHTML +='            </td>																																																		 '
_cHTML +='        </tr>																																																			 '
_cHTML +='        <!-- end footer -->																																																	 '
_cHTML +='																																																				 '
_cHTML +='    </table>																																																			 '
_cHTML +='    <!-- end body -->																																																		 '
_cHTML +='																																																				 '
_cHTML +='</body>																																																			 '
_cHTML +='																																																				 '
_cHTML +='</html>	

dbSelectArea(cAliasHTML) 
dbclosearea() 

return(_cHTML)
