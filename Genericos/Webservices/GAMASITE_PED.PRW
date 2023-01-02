#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RWMAKE.CH"

#IFNDEF CRLF
	#DEFINE CRLF Chr(13)+Chr(10)
#ENDIF	

#DEFINE STR0001 "Brasitech - Serviço de inclusão de pedidos de venda provenientes do website GA.MA Store"
#DEFINE STR0002 "Método de inclusão de pedidos de venda do website GA.MA Store"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		GAMASITE_PED                                                  /@
@type				Webservice                                                /@
@date				09/01/2017                                                /@
@description	Webservice de integração Protheus x website GA.MA Store para
					inclusão de pedidos de vendas.                            /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Opção Um Consultoria                                      /@
@use				Específico Brasitech                                      /@
———————————————————————————————————————————————————————————————————————————————
/*/

//———————————————————————————————————————————————————————————————————————————————
// Método WS
//———————————————————————————————————————————————————————————————————————————————
WSSTRUCT tAddItemPED
	WSDATA tzItensDoPedido			AS Array Of tAddItemPedSite
ENDWSSTRUCT

WSSTRUCT tAddItemPedSite
	WSDATA CODMATERIAL				As String 	//C6_PRODUTO
	WSDATA QTD						As Integer	//C6_QTDVEN
	WSDATA OPERACAO					As String	//se (V)enda ou (B)rinde
	WSDATA PRCPADR					As Float
	WSDATA PRCVEND					As Float
ENDWSSTRUCT

WSSTRUCT ARetPedSite
	WSDATA COD						As String
	WSDATA MSG						As String
	WSDATA NumeroDoPedido			As String
ENDWSSTRUCT
          
WSSERVICE GAMASITE_PED DESCRIPTION STR0001 

	WSDATA NUMPEDIDO              	As String
	WSDATA CODCLIENTE				As String
	WSDATA CONDPAG					As String	//BOL (boleto) / DEB (cartao debito) / CRD1 (credito 1x) / CRD2 (credito 2x) / CRD3 (credito 3x) / CRD4 (credito 4x) / CRD5 (credito 5x) / CRD6 (credito 6x)
	WSDATA VALFRETE					As Float
	WSDATA TPFRETE					As String	//1-SEDEX ou 2-PAC
	WSDATA NUMPEDEXT				As String	// Numero do pedido do parceiro externo 
	WSDATA tAddPedido				As tAddItemPED
	WSDATA StructReturn		    	As ARetPedSite
	
WSMETHOD AddPedecom    	DESCRIPTION STR0002	

ENDWSSERVICE

WSMETHOD AddPedecom WSRECEIVE NUMPEDIDO,CODCLIENTE,CONDPAG,VALFRETE,TPFRETE,NUMPEDEXT,tAddPedido WSSEND StructReturn  WSSERVICE GAMASITE_PED

//———————————————————————————————————————————————————————————————————————————————
// Definição de variáveis
//———————————————————————————————————————————————————————————————————————————————
Local aCabPed, aItePed, cItem, cCliente, cLoja, nK, cOper, cTransp, cTabela, nI,;
		cDestinat, lRet, cErroPed, cMsgNotaPV, cMsgOcor, nVlFrt, cCondPag, cVend,;
		cECTEntrega, cPedCli, cProduto, nQtde, nPrcLista, nPrcVenda, nDesc, cPedExt, cEctCart
Private _cTLOG


//———————————————————————————————————————————————————————————————————————————————
// Inicializando ambiente
//———————————————————————————————————————————————————————————————————————————————
//WfPrepEnv("01", "08", "GAMASITE_PED",, "FAT")
//Prepare Environment Empresa "01" Filial "08" User 'siga' PassWord 't58220' Modulo "FAT" Tables "SA1","SA4","SB1","SB2","SC5","SC6","SC9","SE4","SF4"
//RpcSetType(3)
//lRetEnv := RpcSetEnv("01","08",,,'FAT',, {"SC5","SC6"}, , , ,  )
//If lRetEnv

lRet		:= .T.
cMsgOcor	:= ""
cTabela		:= GetMV("BR_X_TPRLJ", .F., "109")	//Codigo da tabela padrao para a loja. Utilizada no PE - LJ1146EX
cDestinat	:= GetMV("BR_STOEML3", .F., "luiz.fernando@gamaitaly.com.br")	//Enderecos de emails p/ recebimento de ocorrencias no processamento de pedidos oriundos do site GA.MA Store
cTransp		:= GetMV("BR_STOSA4 ", .F., "340283")	//Codigo da transportadora para pedidos integrados pelo webservice com o sistema Assist
cMsgNotaPV	:= Iif(empty(::NUMPEDEXT),"","Pedido do parceiro: " + Upper(::NUMPEDEXT))
cVend			:= Iif(empty(::NUMPEDEXT),"15488","15563") 
cEctCart		:= Iif(empty(cMsgNotaPV),"72912057","73325597")
nVlFrt		:= 0
cECTEntrega	:= ::TPFRETE
cPedCli		:= Upper(PadR("GS-" +::NUMPEDIDO, Len(SC5->C5_PEDCLI)))

if ::CONDPAG == "BOL"
	cCondPag	:= "002"
elseif ::CONDPAG == "DEB"
	cCondPag	:= "001"
elseif ::CONDPAG == "CRD1"
	cCondPag	:= "141"
elseif ::CONDPAG == "CRD2"
	cCondPag	:= "009"
elseif ::CONDPAG == "CRD3"
	cCondPag	:= "007"
elseif ::CONDPAG == "CRD4"
	cCondPag	:= "186"
elseif ::CONDPAG == "CRD5"
	cCondPag	:= "068"
elseif ::CONDPAG == "CRD6"
	cCondPag	:= "253"		
elseif ::CONDPAG == "CRD7"
	cCondPag	:= "865"
elseif ::CONDPAG == "CRD8"
	cCondPag	:= "864"
elseif ::CONDPAG == "CRD9"
	cCondPag	:= "863"
elseif ::CONDPAG == "CRD10"
	cCondPag	:= "862"
elseif ::CONDPAG == "CRD11"
	cCondPag	:= "868"
elseif ::CONDPAG == "CRD12"
	cCondPag	:= "464"
elseif ::CONDPAG == "CRD13"
	cCondPag	:= "599"
elseif ::CONDPAG == "CRD14"
	cCondPag	:= "598"
elseif ::CONDPAG == "CRD15"
	cCondPag	:= "597"
elseif ::CONDPAG == "CRD16"
	cCondPag	:= "596"
elseif ::CONDPAG == "CRD17"
	cCondPag	:= "595"
elseif ::CONDPAG == "CRD18"
	cCondPag	:= "594"
elseif ::CONDPAG == "CRD19"
	cCondPag	:= "593"
elseif ::CONDPAG == "CRD20"
	cCondPag	:= "592"
else
	cCondPag	:= ""
endif

cCliente 	:= Space(8)
cLoja		:= Space(2)
lMsErroAuto := .F. 
lMsHelpAuto := .F.
aCabPed		:= {}
aItePed		:= {}
cItem		:= "01"

//————————————————————————————————————————————————————————————————————————————
// Ordem das tabelas 
//————————————————————————————————————————————————————————————————————————————
SA1->(dbSetOrder(3))	//A1_FILIAL+A1_CGC
SA4->(dbSetOrder(1))	//A4_FILIAL+A4_COD
SB1->(dbSetOrder(1))	//B1_FILIAL+B1_COD
SB2->(dbSetOrder(1))	//B2_FILIAL+B2_COD+B2_LOCAL
SC6->(dbSetOrder(1))	//C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
SE4->(dbSetOrder(1))	//E4_FILIAL+E4_CODIGO
SF4->(dbSetOrder(1))	//F4_FILIAL+F4_CODIGO

//————————————————————————————————————————————————————————————————————————————
// Valido informações do pedido de vendas
//————————————————————————————————————————————————————————————————————————————
if Empty(cCondPag) .or. SE4->(!dbSeek(xFilial("SE4") + cCondPag))
	cMsgOcor	+= "Condição de pagamento não localizada" + chr(13) + chr(10)
	lRet		:= .F.
endif

if Empty(cPedCli)
	cMsgOcor	+= "Não foi informado o número do pedido Site GA.MA Store" + chr(13) + chr(10)
	lRet		:= .F.
endif

SC5->(dbSetOrder(13))	//C5_FILIAL, C5_PEDCLI
if SC5->(dbSeek(xFilial("SC5") + cPedCli))
	cMsgOcor	+= "Pedido Site GA.MA Store '" + AllTrim(cPedCli) + "' já cadastrado para o pedido Protheus " + SC5->C5_NUM + chr(13) + chr(10)
	lRet		:= .F.
endif

SC5->(dbSetOrder(1))	//C5_FILIAL, C5_NUM
if !(SA1->(dbSeek(xFilial("SA1") + ::CODCLIENTE)))
	cMsgOcor += "Cliente CNPJ " + ::CODCLIENTE + " não cadastrado." + chr(13) + chr(10)
	lRet		:= .F.
else
	cCliente := SA1->A1_COD
	cLoja		:= SA1->A1_LOJA
endif 

//————————————————————————————————————————————————————————————————————————————
// Continua se o retorno for verdadeiro
//————————————————————————————————————————————————————————————————————————————
if lRet

	for nI := 1 to Len(::tAddPedido:tzItensDoPedido) 

		cProduto	:= ::tAddPedido:tzItensDoPedido[nI]:CODMATERIAL
		nQtde		:= ::tAddPedido:tzItensDoPedido[nI]:QTD
		nPrcLista	:= ::tAddPedido:tzItensDoPedido[nI]:PRCPADR
		nPrcVenda	:= ::tAddPedido:tzItensDoPedido[nI]:PRCVEND
			
		if Len(aCabPed) == 0
	
			//————————————————————————————————————————————————————————————————————————————
			// Array Cabeçalho do Pedido
			//————————————————————————————————————————————————————————————————————————————
			aCabPed	:= {		{"C5_TIPO",		"N",			NIL},;
								{"C5_X_ORIG" ,	"3",				NIL},;
								{"C5_CLIENTE",	cCliente,		NIL},;
								{"C5_LOJACLI",	cLoja,			NIL},;
								{"C5_CLIENT",	cCliente,		NIL},;
								{"C5_LOJAENT",	cLoja,			NIL},;
								{"C5_VEND1" ,	cVend,			NIL},;
								{"C5_EMISSAO",	Date(),			NIL},;
								{"C5_X_DTPRE",	Date(),			NIL},;
								{"C5_CONDPAG",	cCondPag,		NIL},;
								{"C5_TRANSP",	cTransp,			NIL},;
								{"C5_VOLUME1",	1,					NIL},;
								{"C5_ESPECI1",	"CAIXA",			NIL},;
								{"C5_TABELA",	cTabela,			NIL},;
								{"C5_PEDCLI",	cPedCli,			NIL},;
								{"C5_MENNOT1",	cMsgNotaPV,		NIL},;
								{"C5_XECTTRA",	cECTEntrega,	NIL},;
								{"C5_XECTCAR",	cEctCart,		NIL},;
								{"C5_TPFRETE",	"C",		  		NIL},;
								{"C5_FRETE",	::VALFRETE,		NIL}}
		endif
			
		if SB1->(!dbSeek(xFilial("SB1") + cProduto))
			cMsgOcor += "O produto " + cProduto + " não está cadastrado" + chr(13) + chr(10)
			lRet		:= .F.
		endif

		if nPrcLista <= 0 .or. nPrcVenda <= 0
			cMsgOcor += "O produto " + cProduto + " sem preço de lista ou venda" + chr(13) + chr(10)
			lRet		:= .F.
		endif

		//————————————————————————————————————————————————————————————————————————————
		// Adiciono o item no array de itens para o MsExecAuto
		//————————————————————————————————————————————————————————————————————————————
		cOper := iif(::tAddPedido:tzItensDoPedido[nI]:OPERACAO == "B", "03", "02")
		if nPrcVenda < nPrcLista
			nDesc := (nQtde*nPrcLista) - (nQtde*nPrcVenda)
		else
			nDesc := 0
		endif

		aAdd(aItePed, {	{"C6_ITEM",		cItem, 					NIL},;
								{"C6_PRODUTO",	cProduto,		NIL},;
								{"C6_OPER",		cOper,			NIL},;
								{"C6_LOCAL",	"75", 			NIL},;
								{"C6_QTDVEN",  	nQtde,			NIL},;
								{"C6_QTDLIB",	nQtde,			NIL},;
								{"C6_PRUNIT",	nPrcLista,		NIL},;
								{"C6_PRCVEN",	nPrcLista,		NIL},;
								{"C6_VALDESC",	nDesc,			NIL},;
								{"C6_PEDCLI",	cPedCli,		NIL}})
	
	//substituir o C6_TES pela linha abaixo. Necessário configurar TES inteligente para as vendas pelo site
	//							{"C6_TES",	   cTESVen,													 NIL},;
		cItem	:= Soma1(cItem)

		//————————————————————————————————————————————————————————————————————————————
		// Se encontrado erro no item, abandona a inclusao do pedido
		//————————————————————————————————————————————————————————————————————————————
		if !lRet
			exit
		endif
									
	Next

	//————————————————————————————————————————————————————————————————————————————
	// Verifico se o pedido será gravado
	//————————————————————————————————————————————————————————————————————————————
	if lRet .and. Len(aCabPed) > 0 .and. Len(aItePed) > 0
	
		Begin Transaction
			
			MsExecAuto({ |x, y, z| MATA410(x, y, z) }, aCabPed, aItePed, 3)
					
			if lMsErroAuto
				DisarmTransaction()
				cMsgOcor := "Falha na Inclusao! (Empresa/Filial: "+SM0->(M0_CODIGO+"/"+M0_CODFIL)+") " + MostraErro()
				lRet 		:= .F.
			else
	   		cMsgOcor := "SUCESSO na inclusão do pedido " + SC5->C5_NUM
			endif
					
		End Transaction
	
	endif

endif

//————————————————————————————————————————————————————————————————————————————
// Retorno do resultado do processamento
//————————————————————————————————————————————————————————————————————————————
if lRet

	//————————————————————————————————————————————————————————————————————————————
	// Envio de e-mail sobre a operação realizada
	//————————————————————————————————————————————————————————————————————————————
	if !Empty(cDestinat)
		U_GISendMail(cDestinat,, "Integração Website GA.MA Store x Protheus - PED - Pedido de venda: " + ::NUMPEDIDO, cMsgOcor)
	endif
	
	::StructReturn:COD 	:= "1" 
	::StructReturn:MSG 	:= cMsgOcor
	::StructReturn:NumeroDoPedido := SC5->C5_NUM

else

	::StructReturn:COD := "2" 
	::StructReturn:MSG := cMsgOcor
	::StructReturn:NumeroDoPedido := " "
	SetSoapFault("2", cMsgOcor)

endif


Return(lRet)