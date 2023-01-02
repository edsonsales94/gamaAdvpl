#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TBICONN.CH"
#INCLUDE "APWEBSRV.CH"  

#DEFINE STR0001 "Brasitech - Servi&ccedil;o de inclus�o de NF de Entrada com informa��es provenientes do sistema Assist"
#DEFINE STR0002 "M&eacute;todo de Inclus&atilde;o da NF de Entrada"

/*/

�������������������������������������������������������������������������������
@function		GAMA_PRENF                                                    /@
@type				Webservice                                                    /@
@date				01/04/2015                                                    /@
@description	Webservice de integra��o Protheus x Assist para inclus�o de
					pr�-nota de entrada.                                          /@
@author			Felippe Rainho                                                /@
@use				Espec�fico Brasitech                                          /@
�������������������������������������������������������������������������������
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

          
//�������������������������������������������������������������������������������
// Servi�o de inclus�o de Nota Fiscal de Entrada
//�������������������������������������������������������������������������������
WSSERVICE GAMA_PRENF DESCRIPTION STR0001 

	WSDATA StructREC		      As STRCADNFE
	WSDATA StructRET		      As STRRETNFE
	
	WSMETHOD PRENF	 DESCRIPTION STR0002

ENDWSSERVICE


//�������������������������������������������������������������������������������
// M�todo para inclus�o de Nota Fiscal de Entrada
//�������������������������������������������������������������������������������
WSMETHOD PRENF WSRECEIVE StructREC WSSEND StructRET WSSERVICE GAMA_PRENF           

//�������������������������������������������������������������������������������
// Variaveis
//�������������������������������������������������������������������������������
Local lRet,aSF1,aSD1,dEmissao,cProdNFE,cTESNFE,cDestinat,cMsgOcor,cChvSF1
Private lMsErroAuto
                   
//�������������������������������������������������������������������������������
// Inicializando ambiente
//�������������������������������������������������������������������������������
//WfPrepEnv("01", "0", "GAMA_PRENF",, "COM")

lRet			:= .F.
aSF1			:= {}
aSD1			:= {}
dEmissao		:= cTOd(Transform(::StructREC:DATANOTAFISCAL,"@R 99/99/9999"))
cProdNFE		:= GetMV("BR_WSPRNFE", .F., "")	//C�digo de produto para a inclusao de nota fiscal de entrada na integracao por webservice com o sistema Assist
cTESNFE		:= GetMV("BR_WSTESNF", .F., "")	//Codigo do TES para notas de entrada. Utilizado na integracao por webservice com o sistema Assist
cDestinat	:= GetMV("BR_WSEMLNF", .F., "")	//Enderecos de emails p/ recebimento de ocorrencias no processamento de pr� notas de entrada pela integracao com o webservice do Assist
cMsgOcor		:= ""

lMsErroAuto := .F.

//����������������������������������������������������������������������������
// Ordem das tabelas 
//����������������������������������������������������������������������������
SA2->(dbSetOrder(3))	//A2_FILIAL, A2_CGC
SF1->(dbSetOrder(1))	//F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO

if SA2->(dbSeek(xFilial("SA2") + ::StructREC:CODFORNEC))
   
   cChvSF1 := PadR(::StructREC:NUMNOTAFISCAL, 9) + PadR(::StructREC:SERIENF, 3) + SA2->(A2_COD + A2_LOJA)
   
	if SF1->(!dbSeek(xFilial("SF1") + cChvSF1))
		//����������������������������������������������������������������������������
		// Cabecalho da NF 
		//����������������������������������������������������������������������������
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
	
		//����������������������������������������������������������������������������
		// Item da NF(somente um item)
		//����������������������������������������������������������������������������
		aAdd(aSD1, {{"D1_ITEM", 		"0001",						Nil},;
						{"D1_COD", 			cProdNFE,					Nil},;
						{"D1_QUANT", 		1,								Nil},;
						{"D1_VUNIT", 		::StructREC:VALOR,		Nil},;
						{"D1_TOTAL", 		::StructREC:VALOR,		Nil}})
	//					{"D1_TES", 			cTESNFE,						Nil},;
	
		Begin Transaction
	    
			//MSExecAuto({|x,y,z| MATA103(x,y,z)}, aSF1, aSD1, 3)
			MsExecAuto({|x,y,z| MATA140(x,y,z)}, aSF1, aSD1, 3)			   //Para incluir pr�-nota, utilizar MATA140, por�m n�o permite inclus�o se MV_PCNFE=T 
			
			if lMsErroAuto
				DisarmTransaction()
				cMsgOcor := "Falha na inclus�o "
				SetSoapFault("2", cMsgOcor + MostraErro())

			else
				//����������������������������������������������������������������������������
				// Retorna Parametros de inclus�o
			   //����������������������������������������������������������������������������
  				cMsgOcor 		 := "SUCESSO na inclus�o da nota fiscal " + ::StructREC:NUMNOTAFISCAL
				::StructRET:COD := "1" 
				::StructRET:MSG := cMsgOcor
				lRet 				 := .T.

			endif
			
		End Transaction

	else

		cMsgOcor 		 := "ERRO - Nota fiscal j� cadastrada no sistema. Chave de pesquisa (Documento, Serie, Fornecedor e Loja): " + cChvSF1
		::StructRET:COD := "2" 
		::StructRET:MSG := cMsgOcor
	
	endif

else

	cMsgOcor 		 := "ERRO - Fornecedor CNPJ " + ::StructREC:CODFORNEC + " n�o cadastrado!"
	::StructRET:COD := "2" 
	::StructRET:MSG := cMsgOcor
	
endif

//����������������������������������������������������������������������������
// Envio de e-mail sobre a opera��o realizada
//����������������������������������������������������������������������������
if !Empty(cMsgOcor) .and. !Empty(cDestinat)
	U_GISendMail(cDestinat,, "Integra��o Assist x Protheus - PRENF - NF " + ::StructREC:NUMNOTAFISCAL, cMsgOcor)
endif

Return(lRet) 