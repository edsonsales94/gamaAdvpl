// #########################################################################################
// Projeto: GAMA_DIA
// Modulo : SIGAEST
// Fonte  : GAMA_SB5.prw
// -----------+-------------------+---------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+---------------------------------------------------------
// 14/02/2017 | claudio.almeida   | Gerado com auxνlio do Assistente de Cσdigo do TDS.
// -----------+-------------------+---------------------------------------------------------

#include "protheus.ch"
#include "vkey.ch"

#include "apwebsrv.ch"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GAMA_SB5
Manutenηγo de dados, via serviηo web em SB5-Dados Adicionais do Produto.
@author    claudio.almeida
@version   11.3.3.201609231349
@since     14/02/2017
@obs       observation
/*/
//------------------------------------------------------------------------------------------

//-- estruturas ----------------------------------------------------------------------------
wsStruct strcSB5 
	wsData B5_COD as string // "Codigo do Produto"
	wsData B5_CEME as string // "Descricao cientifica"
	wsData B5_CODZON as string // "Zona Armaz."
	wsData B5_UMIND as string // "Un. de Medida Industrial"
	wsData B5_AMMULTO as float // "Multiplicador AM Outros"
	wsData B5_AMMULTS as float // "Multiplicador AM S/SE"
	wsData B5_ZFMULTO as float // "Multiplicador ZF Outros"
	wsData B5_ZFMULTS as float // "Multiplicador ZF S/SE"
	wsData B5_AM4PORC as float // "Multiplicador AM 4%"
	wsData B5_ZF4PORC as float // "Multiplicador ZF 4%"
endwsstruct

wsStruct strcInSB5
	wsdata  m_strcSB5 as strcSB5
endwsstruct

wsstruct strcOutSB5
	wsdata m_strcSB5 as strcSB5 optional
	wsdata cod_message as string
	wsdata message as string
endwsstruct

//-- definiηγo do serviηo ------------------------------------------------------------------
wsService ws_SB5 description "Manutenηγo de dados na tabela SB5-Dados Adicionais do Produto."

	//proriedades do ws
	wsData username     as string
	wsData password     as string
	wsData token        as string

	wsdata strc_in		as strcInSB5
	wsdata strc_out  	as strcOutSB5

   

	//mιtodos do ws
	wsmethod login description "Efetua a identificaηγo do usuαrio."

	wsmethod select_SB5 description "Seleciona um registro na tabela"
	wsmethod insert_SB5 description "Insere um novo registro na tabela"
	wsmethod update_SB5 description "Atualiza os dados de um registro na tabela"

endWsService

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} login_SB5
Efetua a identificaηγo do usuαrio
@author    claudio.almeida
@version   11.3.3.201609231349
@since     14/02/2017
@param     username, login
@param     token
/*/
wsMethod login wsReceive username, password wsSend token wsService ws_SB5
	local lRet := .t.

	if !(::username == "ws" .and. ::password == "ws")
		isValidToken(nil) //forηa erro de credencial
		lRet := .f.
	else
		::token := md5(::username + ::password,2)
	endif

return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} insert_SB5
Efetua a inclusγo de dados na tabela SB5.
@author    claudio.almeida
@version   11.3.3.201609231349
@since     14/02/2017
@param     token, strc_in
@param     strc_out
@obs
/*/
wsMethod insert_SB5 wsReceive token, strc_in wsSend strc_out wsService ws_SB5
	local lRet := .t.
    local Produto := ::strc_in:m_strcSB5:B5_COD
	//valida a credencial
	if !isValidToken(::token)
		return .f.
	endif

	//inicializaηγo
	::strc_out := wsClassNew( "strcOutSB5" )
     //
    // Inicializando ambiente
    //
    WfPrepEnv("01", "01", "GAMA_SB5",, "EST")
     
 
	//indice
	DBSELECTAREA("SB5")
	SB5->(dbSetOrder(1))

	//valida a existκncia do item
	if !SB5->(dbSeek(xfilial("SB5")+padr(Produto,15)))
		recLock("SB5",.T.)

		SB5->B5_COD := ::strc_in:m_strcSB5:B5_COD
		SB5->B5_CEME := POSICIONE("SB1",1,XFILIAL("SB1")+padr(Produto,15),"B1_DESC")
		SB5->B5_CODTRAM := ::strc_in:m_strcSB5:B5_CODZON
		SB5->B5_UMIND := POSICIONE("SB1",1,XFILIAL("SB1")+padr(Produto,15),"B1_TIPO")
		SB5->B5_AMMULTO := ::strc_in:m_strcSB5:B5_AMMULTO
		SB5->B5_AMMULTS := ::strc_in:m_strcSB5:B5_AMMULTS
		SB5->B5_ZFMULTO := ::strc_in:m_strcSB5:B5_ZFMULTO
		SB5->B5_ZFMULTS := ::strc_in:m_strcSB5:B5_ZFMULTS
		SB5->B5_AM4PORC := ::strc_in:m_strcSB5:B5_AM4PORC
		SB5->B5_ZF4PORC := ::strc_in:m_strcSB5:B5_ZF4PORC

		SB5->(MsUnLock())
		::strc_out:cod_message := "I000"
		::strc_out:message := "MV_WSINS" // getMV("MV_WSINS")
	else
		::strc_out:cod_message := "E000"
		::strc_out:message := "MV_EXITEM" // getMV("MV_EXITEM")
	endif

return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} update_SB5
Efetua a alteraηγo de dados na tabela SB5.
@author    claudio.almeida
@version   11.3.3.201609231349
@since     14/02/2017
@param     strc_in
@param     strc_out
@obs
/*/
wsMethod update_SB5 wsReceive token, strc_in wsSend strc_out wsService ws_SB5
	local lRet := .t.
    local Produto := ::strc_in:m_strcSB5:B5_COD
	//valida a credencial
	if !isValidToken(::token)
		return .f.
	endif

	//inicializaηγo
	::strc_out := wsClassNew( "strcOutSB5" )
    //
    // Inicializando ambiente
    //
    WfPrepEnv("01", "01", "GAMA_SB5",, "EST")
    

	//indice
	DBSELECTAREA("SB5")
	SB5->(dbSetOrder(1))

	//valida a existκncia do item
	if SB5->(dbSeek(xfilial("SB5")+padr(Produto,15)))
		recLock("SB5",.F.)

		SB5->B5_COD := ::strc_in:m_strcSB5:B5_COD
		SB5->B5_CEME := POSICIONE("SB1",1,XFILIAL("SB1")+padr(Produto,15),"B1_DESC")
		SB5->B5_CODTRAM := ::strc_in:m_strcSB5:B5_CODZON
		SB5->B5_UMIND := POSICIONE("SB1",1,XFILIAL("SB1")+padr(Produto,15),"B1_TIPO")
		SB5->B5_AMMULTO := ::strc_in:m_strcSB5:B5_AMMULTO
		SB5->B5_AMMULTS := ::strc_in:m_strcSB5:B5_AMMULTS
		SB5->B5_ZFMULTO := ::strc_in:m_strcSB5:B5_ZFMULTO
		SB5->B5_ZFMULTS := ::strc_in:m_strcSB5:B5_ZFMULTS
		SB5->B5_AM4PORC := ::strc_in:m_strcSB5:B5_AM4PORC
		SB5->B5_ZF4PORC := ::strc_in:m_strcSB5:B5_ZF4PORC

		SB5->(MsUnLock())
		::strc_out:cod_message := "I000"
		::strc_out:message := "MV_WSALT" // getMV("MV_WSALT")
	else
		::strc_out:cod_message := "E000"
		::strc_out:message := "MV_NOFOUND" // getMV("MV_NOFOUND")
	endif

return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} select_SB5
Efetua uma consulta de dados na tabela ${alias}.
@author    claudio.almeida
@version   11.3.3.201609231349
@since     14/02/2017
@param     strc_in
@param     strc_out
@obs
/*/
wsMethod select_SB5 wsReceive token, strc_in wsSend strc_out wsService ws_SB5
	local lRet := .t.
    local Produto := ::strc_in:m_strcSB5:B5_COD


	//valida a credencial
	if !isValidToken(::token)
		return .f.
	endif

	//inicializaηγo
	::strc_out := wsClassNew("strcOutSB5")
  
  //
  // Inicializando ambiente
  //
    WfPrepEnv("01", "01", "GAMA_SB5",, "EST")

	//indice
	DBSELECTAREA("SB5")
	SB5->(dbSetOrder(1))

	//valida a existκncia do item
	if SB5->(dbSeek(xfilial("SB5")+padr(Produto,15)))
		::strc_out:m_strcSB5 := wsClassNew("strcSB5")

		::strc_out:m_strcSB5:B5_COD := SB5->B5_COD
		::strc_out:m_strcSB5:B5_CEME := SB5->B5_CEME
		::strc_out:m_strcSB5:B5_CODZON := SB5->B5_CODTRAM
		::strc_out:m_strcSB5:B5_UMIND := POSICIONE("SB1",1,XFILIAL("SB1")+padr(Produto,15),"B1_TIPO")
		::strc_out:m_strcSB5:B5_AMMULTO := SB5->B5_AMMULTO
		::strc_out:m_strcSB5:B5_AMMULTS := SB5->B5_AMMULTS
		::strc_out:m_strcSB5:B5_ZFMULTO := SB5->B5_ZFMULTO
		::strc_out:m_strcSB5:B5_ZFMULTS := SB5->B5_ZFMULTS
		::strc_out:m_strcSB5:B5_AM4PORC := SB5->B5_AM4PORC
		::strc_out:m_strcSB5:B5_ZF4PORC := SB5->B5_ZF4PORC

		::strc_out:cod_message := "I000"
		::strc_out:message := ""
	else
		::strc_out:cod_message := "E000"
		::strc_out:message := xfilial("SB5")+padr(Produto,15)
		//::strc_out:message := "MV_NOFOUND" // getMV("MV_NOFOUND")
	endif

return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} isValidToken
Valida o token.
@author    claudio.almeida
@version   11.3.3.201609231349
@since     14/02/2017
@param     acToken, caracter, Token a ser validado.
@return    logico, .T. ou .F. inidcando a validado ou nγo do token.
@obs       Caso o token nγo seja vαlido, alιm de retornar .F., serα indicado erro SOAP.
O mιtodo SOAP que invocou o teste, deverα finalizar a sua execuηγo retornando .F..
Se o parβmetro acToken for nulo (nil), este serα considerado invαlido.
/*/
//------------------------------------------------------------------------------------------
static function isValidToken(acToken)
	local lRet := .t.

	if acToken == nil .or. acToken != md5("wsws",2)
		setSoapFault("E001", "Credenciais invαlidas.")
		lRet := .f.
	endif

return lRet
//-------------------------------------------------------------------------------------------
// Gerado pelo assistente de cσdigo do TDS tds_version em 14/02/2017 as 13:57:11
//-- fim de arquivo--------------------------------------------------------------------------

