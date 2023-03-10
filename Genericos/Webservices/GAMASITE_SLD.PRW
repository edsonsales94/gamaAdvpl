#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		GAMASITE_SLD                                                  /@
@type				Webservice                                                    /@
@date				01/03/2015                                                    /@
@description	Webservice de integra鈬o Protheus x site de venda GA.MA Store
					para consulta de saldo de produtos.                           /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Op鈬o Um Consultoria                                          /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/

#Define STR0001 "Brasitech - Servi輟 de consulta de saldo de produtos para o Site GA.MA Store"
#Define STR0002 "M騁odo de consulta de saldo de produtos Site GA.MA Store"

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Definicao da estruturas utilizadas
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
WSStruct STRSALDO
	WSData CODMATERIAL			As String
	WSData QTDT						As Integer
EndWSStruct
    
WSStruct STRENTRADA
	WSData  STRCODMAT				As Array Of STRSENDMAT
EndWSStruct

WSStruct STRSENDMAT  
	WSData CODMATERIAL			As String
EndWSStruct

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Definicao do Web Service
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
WSService GAMASITE_SLD DESCRIPTION STR0001

	WSData StructMat				As STRENTRADA
	WSData StructSALDO			As Array Of STRSALDO
	
	WSMethod SALDO DESCRIPTION STR0002

EndWSService 

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// METODO SALDO 
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
WSMethod SALDO  WSReceive StructMat WSSend StructSALDO WSService GAMASITE_SLD


Local lRetorno, cQuery, cProduto, nQtdDisp, nK, nI

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Inicializando ambiente
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
//WfPrepEnv("01", "08", "GAMASITE_SLD",, "EST")

lRetorno := .F.
cQuery   := ""
cProduto	:= ""

SB1->(dbSetOrder(1))

For nI := 1 to Len(::StructMat:STRCODMAT) 
	
	cProduto := Alltrim(::StructMat:STRCODMAT[nI]:CODMATERIAL)
      
	if !Empty(cProduto) .and. SB1->(dbSeek(xFilial("SB1") + cProduto))
	
		cQuery  := "SELECT B2_COD, SUM(CONVERT(DECIMAL(12,0), (B2_QATU-B2_QEMP-B2_RESERVA))) AS QTD_DISP "
		cQuery  += "FROM " + RetSqlName("SB2") + " "
		cQuery  += "WHERE " + RetSqlName("SB2") + ".D_E_L_E_T_ = '' AND B2_FILIAL = '08' "
		cQuery  += "AND B2_COD ='" + cProduto + "' "
		cQuery  += "AND B2_LOCAL = '75' "
		cQuery  += "GROUP BY B2_COD "
		cQuery  += "ORDER BY B2_COD "
		
		if Select("WSSTA") > 0
			WSSTA->(dbCloseArea())
		Endif

		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "WSSTA", .T., .T.)
      dbGoTop()
      
		nQtdDisp	:= iif(WSSTA->(!eof()), WSSTA->QTD_DISP, 0)
		
		//Preenche o array		
		aAdd(::StructSALDO, WsClassNew("STRSALDO"))
		nK := Len(::StructSALDO)
		::StructSALDO[nK]:CODMATERIAL 	:= cProduto
		::StructSALDO[nK]:QTDT				:= nQtdDisp
		lRetorno := .T.

		if Select("WSSTA") > 0
			WSSTA->(dbCloseArea())
		Endif
		
	Endif		

Next nI

if !(lRetorno)
  	SetSoapFault("2", "Erro-Nenhum Registro encontrado!!")
Endif

Return lRetorno 
