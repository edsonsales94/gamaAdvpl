#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/*/

———————————————————————————————————————————————————————————————————————————————
@function		GAMA_CSLD                                                     /@
@type				Webservice                                                    /@
@date				01/03/2015                                                    /@
@description	Webservice de integração Protheus x Assist para consulta de 
					saldo de produtos.                                            /@
@author			Felippe Rainho                                                /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————

/*/

#DEFINE STR0001 "Brasitech - Servi&ccedil;o de consulta de saldo de produtos"
#DEFINE STR0002 "M&eacute;todo de consulta de saldo de produtos Brasitech"

//———————————————————————————————————————————————————————————————————————————————
// Definicao da estruturas utilizadas
//———————————————————————————————————————————————————————————————————————————————
WSSTRUCT STRCSLD
	WSDATA CODMATERIAL         	AS String
	WSDATA QTDT 		        AS integer
	WSDATA QTDE 		        AS integer	
ENDWSSTRUCT
    
WSSTRUCT STRCENTR
	WSDATA  STRCODMAT      	   As Array OF STRSNDMAT
ENDWSSTRUCT

WSSTRUCT STRSNDMAT  
	WSDATA CODMATERIAL      	AS String
	WSDATA ARMZ      			AS String
ENDWSSTRUCT

//———————————————————————————————————————————————————————————————————————————————
// Definicao do Web Service
//———————————————————————————————————————————————————————————————————————————————
WSSERVICE GAMA_CSLD DESCRIPTION STR0001

	//WSDATA CODMATERIAL            AS String
	WSDATA StructMat       		AS STRCENTR
	WSDATA StructCSLD		    As Array OF STRCSLD
	
	WSMETHOD CSLD DESCRIPTION STR0002


ENDWSSERVICE 

//———————————————————————————————————————————————————————————————————————————————
// METODO CSLD 
//———————————————————————————————————————————————————————————————————————————————
WSMETHOD CSLD  WSRECEIVE StructMat WSSEND StructCSLD WSSERVICE GAMA_CSLD

//———————————————————————————————————————————————————————————————————————————————
//VARIAEIS
//———————————————————————————————————————————————————————————————————————————————
Local nI,lRetorno,cQuery,cProduto,nQtdEmp, nQtdDisp, nK, cArmz

//———————————————————————————————————————————————————————————————————————————————
// Inicializando ambiente
//———————————————————————————————————————————————————————————————————————————————
//WfPrepEnv("01", "03", "GAMA_CSLD",, "EST")

lRetorno := .F.
cQuery   := ""
cProduto	:= ""

SB1->(dbSetOrder(1))

For nI := 1 to Len(::StructMat:STRCODMAT) 
	
	cProduto 	:= Alltrim(::StructMat:STRCODMAT[nI]:CODMATERIAL)
	cArmz		:= Alltrim(::StructMat:STRCODMAT[nI]:ARMZ)
      
	if !Empty(cProduto) .and. SB1->(dbSeek(xFilial("SB1") + cProduto))
		
		cQuery  := "SELECT B2_COD, SUM(CONVERT(DECIMAL(12,0), (B2_QEMP+B2_RESERVA))) AS QTD_EMP, SUM(CONVERT(DECIMAL(12,0), (B2_QATU-B2_QEMP-B2_RESERVA))) AS QTD_DISP "
		cQuery  += "FROM " + RetSqlName("SB2") + " "
		cQuery  += "WHERE " + RetSqlName("SB2") + ".D_E_L_E_T_ = '' AND B2_FILIAL = '" + xFilial("SB2") + " '
		cQuery  += "AND B2_COD ='" + cProduto + "' "
		cQuery  += "AND B2_LOCAL = '"+ cArmz + "' "
		cQuery  += "GROUP BY B2_COD "
		cQuery  += "ORDER BY B2_COD "
		
		if Select("WSSTA") > 0
			WSSTA->(dbCloseArea())
		endif
		
		cQuery := ChangeQuery(cQuery)
		Memowrite("gama_csld.sql" , cQuery )
				
		dbUseArea(.T., 'TOPCONN', TCGENQRY(,, cQuery), "WSSTA", .T., .T.)
      	dbGoTop()
      
		nQtdEmp		:= iif(WSSTA->(!eof()), WSSTA->QTD_DISP, 0)
		nQtdDisp	:= iif(WSSTA->(!eof()), WSSTA->QTD_EMP, 0)
		
		//Preenche o array		
		aAdd(::StructCSLD, WsClassNew("STRCSLD"))
		nK := Len(::StructCSLD)
		::StructCSLD[nK]:CODMATERIAL 	:= cProduto
		::StructCSLD[nK]:QTDT			:= nQtdEmp
		::StructCSLD[nK]:QTDE			:= nQtdDisp
		
		if WSSTA->(!eof())
			lRetorno := .T.
		Endif
		
		if Select("WSSTA") > 0	
			WSSTA->(dbCloseArea())
		endif
	endif		

Next nI

if !(lRetorno)
  	SetSoapFault("2","Erro-Nenhum Registro encontrado!!")
EndIf
Return lRetorno 

