// #########################################################################################
// Projeto:
// Modulo :
// Fonte  : GAMA_CADCT2.prw
// -----------+-------------------+---------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+---------------------------------------------------------
// 27/09/2016 | claudio.almeida   | SERVIÇO DE WEBSERVICE PARA ENVIAR LISTA DE NOTAS PARA DIA
// -----------+-------------------+---------------------------------------------------------

#include "protheus.ch"
#include "vkey.ch"
#include "apwebsrv.ch"

#DEFINE STR0001 "Brasitech - Serviço de consulto de produtos para DIA"
#DEFINE STR0002 "Declaração de Notas de Entrada no Amazonas DIA "

//———————————————————————————————————————————————————————————————————————————————
// Definicao da estruturas utilizadas
//———————————————————————————————————————————————————————————————————————————————
WSSTRUCT STRANOMES
	WSDATA ANO AS String
	WSDATA MES AS String
ENDWSSTRUCT

WSSTRUCT STRPROD
	WSDATA COD AS String
	WSDATA DESC AS String
	WSDATA TRIBUTO AS String
	WSDATA TIPO AS String
ENDWSSTRUCT

WSSTRUCT STRPRODS
	WSDATA PRODUTOS AS Array OF STRPROD
ENDWSSTRUCT

//———————————————————————————————————————————————————————————————————————————————
// Definicao do Web Service
//———————————————————————————————————————————————————————————————————————————————
WSSERVICE GAMA_DIA DESCRIPTION STR0001

	WSDATA StructPer	AS STRANOMES
	WSDATA StructProd   AS STRPRODS

	WSMETHOD DIA DESCRIPTION STR0002

ENDWSSERVICE

//———————————————————————————————————————————————————————————————————————————————
// METODO DIA
//———————————————————————————————————————————————————————————————————————————————
WSMETHOD DIA  WSRECEIVE StructPer  WSSEND StructProd  WSSERVICE GAMA_DIA
	Local lRetorno := .F.
	
	Local ano :=ALLTRIM(::StructPer:ANO)
	Local mes :=ALLTRIM(::StructPer:MES)
	
	 //———————————————————————————————————————————————————————————————————————————————
    // Inicializando ambiente
    //———————————————————————————————————————————————————————————————————————————————
    WfPrepEnv("01", "01", "GAMA_DIA",, "EST")
     
    
    beginSQL Alias "WSDIACAB"
    
    select DISTINCT D1_COD,B1_DESC,ISNULL(B5_CODTRAM,'') B5_CODTRAM,B1_TIPO 
	from SD1010 SD1  
	LEFT OUTER JOIN %Table:SB1% SB1 ON B1_COD=D1_COD AND SB1.%NotDel%
	LEFT OUTER JOIN %Table:SB5% SB5  ON B5_COD=D1_COD AND SB5.%NotDel%
	LEFT OUTER JOIN %Table:SF1% SF1 ON F1_DOC=D1_DOC AND F1_SERIE=D1_SERIE AND F1_FORNECE=D1_FORNECE 
	AND F1_LOJA=D1_LOJA  AND SF1.%NotDel%
	WHERE D1_FILIAL='01' AND SUBSTRING(D1_DTDIGIT,1,6)=%Exp:ano+mes%
	AND LEFT(F1_CHVNFE,2)<>'13' AND SD1.%NotDel% ORDER BY D1_COD 
    
	endSQL
	//inicialização
	::StructProd := wsClassNew("STRPRODS")
	::StructProd:PRODUTOS:={} 
	DBSELECTAREA( "WSDIACAB")              
	DBGOTOP()
	while (!EOF())
	  aAdd(::StructProd:PRODUTOS , WsClassNew("STRPROD"))
	  nK2 := Len(::StructProd:PRODUTOS)
      ::StructProd:PRODUTOS[nK2]:COD     := D1_COD
      ::StructProd:PRODUTOS[nK2]:DESC    := B1_DESC
      ::StructProd:PRODUTOS[nK2]:TRIBUTO := B5_CODTRAM
      ::StructProd:PRODUTOS[nK2]:TIPO    := B1_TIPO 
	  
	  lRetorno := .T.
	  DBSELECTAREA("WSDIACAB")
	  dbskip() 
	Enddo
	
	if Select("WSDIACAB") > 0
	  WSDIACAB->(dbCloseArea())
	endif
	if !(lRetorno)
		SetSoapFault("2","Erro-Nenhum Registro encontrado!!")
	EndIf
Return lRetorno
