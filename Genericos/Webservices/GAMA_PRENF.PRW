#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TBICONN.CH"
#INCLUDE "APWEBSRV.CH"  

#DEFINE STR0001 "Brasitech - Servi&ccedil;o de inclus縊 de NF de Entrada com informa鋏es provenientes do sistema Assist"
#DEFINE STR0002 "M&eacute;todo de Inclus&atilde;o da NF de Entrada"

/*/

覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		GAMA_PRENF                                                    /@
@type				Webservice                                                    /@
@date				01/04/2015                                                    /@
@description	Webservice de integra鈬o Protheus x Assist para inclus縊 de
					pr?-nota de entrada.                                          /@
@author			Felippe Rainho                                                /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?

/*/
WSSTRUCT STRCADNFE
	WSDATA CODFORNEC          	As String
	WSDATA NUMNOTAFISCAL			As String 
	WSDATA SERIENF  				As String
	WSDATA DATANOTAFISCAL		As String  
	WSDATA VALOR					As Float
ENDWSSTRUCT

WSSTRUCT STRRETNFE
	WSDATA COD						As String
	WSDATA MSG						As String
ENDWSSTRUCT

          
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Servi輟 de inclus縊 de Nota Fiscal de Entrada
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
WSSERVICE GAMA_PRENF DESCRIPTION STR0001 

	WSDATA StructREC		      As STRCADNFE
	WSDATA StructRET		      As STRRETNFE
	
	WSMETHOD PRENF	 DESCRIPTION STR0002

ENDWSSERVICE


//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// M騁odo para inclus縊 de Nota Fiscal de Entrada
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
WSMETHOD PRENF WSRECEIVE StructREC WSSEND StructRET WSSERVICE GAMA_PRENF           

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Variaveis
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
Local lRet,aSF1,aSD1,dEmissao,cProdNFE,cTESNFE,cDestinat,cMsgOcor,cChvSF1
Private lMsErroAuto
                   
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Inicializando ambiente
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
//WfPrepEnv("01", "0", "GAMA_PRENF",, "COM")

lRet			:= .F.
aSF1			:= {}
aSD1			:= {}
dEmissao		:= cTOd(Transform(::StructREC:DATANOTAFISCAL,"@R 99/99/9999"))
cProdNFE		:= GetMV("BR_WSPRNFE", .F., "")	//C?digo de produto para a inclusao de nota fiscal de entrada na integracao por webservice com o sistema Assist
cTESNFE		:= GetMV("BR_WSTESNF", .F., "")	//Codigo do TES para notas de entrada. Utilizado na integracao por webservice com o sistema Assist
cDestinat	:= GetMV("BR_WSEMLNF", .F., "")	//Enderecos de emails p/ recebimento de ocorrencias no processamento de pr? notas de entrada pela integracao com o webservice do Assist
cMsgOcor		:= ""

lMsErroAuto := .F.

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
// Ordem das tabelas 
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
SA2->(dbSetOrder(3))	//A2_FILIAL, A2_CGC
SF1->(dbSetOrder(1))	//F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO

if SA2->(dbSeek(xFilial("SA2") + ::StructREC:CODFORNEC))
   
   cChvSF1 := PadR(::StructREC:NUMNOTAFISCAL, 9) + PadR(::StructREC:SERIENF, 3) + SA2->(A2_COD + A2_LOJA)
   
	if SF1->(!dbSeek(xFilial("SF1") + cChvSF1))
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
		// Cabecalho da NF 
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
		aAdd(aSF1, {"F1_TIPO",		"N",								 Nil})
		aAdd(aSF1, {"F1_FORMUL",	"N",								 Nil})
		aAdd(aSF1, {"F1_DOC",		::StructREC:NUMNOTAFISCAL,	 Nil})
		aAdd(aSF1, {"F1_SERIE",		::StructREC:SERIENF,			 Nil})
		aAdd(aSF1, {"F1_EMISSAO",	dEmissao,						 Nil})
		aadd(aSF1, {"F1_DTDIGIT",	dDataBase,						 Nil})
		aAdd(aSF1, {"F1_FORNECE",	SA2->A2_COD,					 Nil})
		aAdd(aSF1, {"F1_LOJA",		SA2->A2_LOJA,					 Nil})	
		aAdd(aSF1, {"F1_EST",		SA2->A2_EST,					 Nil})
		aAdd(aSF1, {"F1_ESPECIE",	"NFE",							 Nil})
		aAdd(aSF1, {"F1_MOEDA",		1,									 Nil})
	//	aadd(aSF1, {"F1_RECBMTO",	dDataBase,						 Nil})
	
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
		// Item da NF(somente um item)
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
		aAdd(aSD1, {{"D1_ITEM", 		"0001",						Nil},;
						{"D1_COD", 			cProdNFE,					Nil},;
						{"D1_QUANT", 		1,								Nil},;
						{"D1_VUNIT", 		::StructREC:VALOR,		Nil},;
						{"D1_TOTAL", 		::StructREC:VALOR,		Nil}})
	//					{"D1_TES", 			cTESNFE,						Nil},;
	
		Begin Transaction
	    
			//MSExecAuto({|x,y,z| MATA103(x,y,z)}, aSF1, aSD1, 3)
			MsExecAuto({|x,y,z| MATA140(x,y,z)}, aSF1, aSD1, 3)			   //Para incluir pr?-nota, utilizar MATA140, por駑 n縊 permite inclus縊 se MV_PCNFE=T 
			
			if lMsErroAuto
				DisarmTransaction()
				cMsgOcor := "Falha na inclus縊 "
				SetSoapFault("2", cMsgOcor + MostraErro())

			else
				//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
				// Retorna Parametros de inclus縊
			   //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
  				cMsgOcor 		 := "SUCESSO na inclus縊 da nota fiscal " + ::StructREC:NUMNOTAFISCAL
				::StructRET:COD := "1" 
				::StructRET:MSG := cMsgOcor
				lRet 				 := .T.

			endif
			
		End Transaction

	else

		cMsgOcor 		 := "ERRO - Nota fiscal j? cadastrada no sistema. Chave de pesquisa (Documento, Serie, Fornecedor e Loja): " + cChvSF1
		::StructRET:COD := "2" 
		::StructRET:MSG := cMsgOcor
	
	endif

else

	cMsgOcor 		 := "ERRO - Fornecedor CNPJ " + ::StructREC:CODFORNEC + " n縊 cadastrado!"
	::StructRET:COD := "2" 
	::StructRET:MSG := cMsgOcor
	
endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
// Envio de e-mail sobre a opera鈬o realizada
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
if !Empty(cMsgOcor) .and. !Empty(cDestinat)
	U_GISendMail(cDestinat,, "Integra鈬o Assist x Protheus - PRENF - NF " + ::StructREC:NUMNOTAFISCAL, cMsgOcor)
endif

Return(lRet) 