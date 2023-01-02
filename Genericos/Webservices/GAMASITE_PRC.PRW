#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		GAMASITE_PRC                                                  /@
@type				Webservice                                                    /@
@date				12/12/2016                                                    /@
@description	Webservice de integração Protheus x site de venda GA.MA Store
					para consulta de preço de venda de produtos.                  /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Opção Um Consultoria                                          /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/

#Define STR0001 "Brasitech - Serviço de consulta de preços de venda de produtos para o Site GA.MA Store"
#Define STR0002 "Método de preços de venda de produtos Site GA.MA Store"

//———————————————————————————————————————————————————————————————————————————————
// Definicao da estruturas utilizadas
//———————————————————————————————————————————————————————————————————————————————
WSStruct STRPRECO
	WSData CODMATERIAL			As String
	WSData PRECO					As float
EndWSStruct
    
WSStruct STRENTPRC
	WSData  STRCODMAT				As Array Of STRSENDPRC
EndWSStruct

WSStruct STRSENDPRC  
	WSData CODMATERIAL			As String
EndWSStruct

//———————————————————————————————————————————————————————————————————————————————
// Definicao do Web Service
//———————————————————————————————————————————————————————————————————————————————
WSService GAMASITE_PRC DESCRIPTION STR0001

	WSData StructMat				As STRENTPRC
	WSData StructPRECO			As Array Of STRPRECO
	
	WSMethod PRECO DESCRIPTION STR0002

EndWSService 

//———————————————————————————————————————————————————————————————————————————————
// METODO PRECO 
//———————————————————————————————————————————————————————————————————————————————
WSMethod PRECO  WSReceive StructMat WSSend StructPRECO WSService GAMASITE_PRC

Local lRetorno, cQuery, cProduto, cTabPrc, nPreco, nK, nI

//———————————————————————————————————————————————————————————————————————————————
// Inicializando ambiente
//———————————————————————————————————————————————————————————————————————————————
//WfPrepEnv("01", "08", "GAMASITE_PRC",, "FAT")

lRetorno := .F.
cQuery   := ""
cProduto	:= ""
cTabPrc	:= AllTrim(GetMV("BR_X_TPRLJ", .F., "109"))

SB1->(dbSetOrder(1))

For nI := 1 to Len(::StructMat:STRCODMAT) 
	
	cProduto := Alltrim(::StructMat:STRCODMAT[nI]:CODMATERIAL)
      
	if !Empty(cProduto) .and. SB1->(dbSeek(xFilial("SB1") + cProduto))
	
		cQuery 		:= "SELECT SB1.B1_COD, SB1.B1_DESC, SB1.B1_TIPO, SB1.B1_MSBLQL, DA1.DA1_PRCVEN, DA1.R_E_C_N_O_ REGISTRO " +;
							"FROM " + RetSqlName("DA1") + " DA1, " + RetSqlName("SB1") + " SB1 " +;
							"WHERE DA1.DA1_FILIAL = '" + xFilial("DA1") + "' " +;
									 "AND DA1.DA1_CODPRO = '" + cProduto + "' " +;
									 "AND DA1.DA1_ATIVO = '1' " +;
 							 		 "AND DA1.DA1_DATVIG < '" + dTOs(dDataBase) + "' " +;
 							 		 "AND DA1.DA1_CODTAB = '" + cTabPrc + "' " +;
							 		 "AND DA1.D_E_L_E_T_ = '' " +;
							 		 "AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' " +;
							 		 "AND SB1.B1_COD = DA1.DA1_CODPRO " +;
							 		 "AND SB1.D_E_L_E_T_ = '' " +;
					 		"ORDER BY SB1.B1_COD "
//							 		 "AND SB1.B1_MSBLQL != '1' " +;


		if Select("WSPRC") > 0
			WSSTA->(dbCloseArea())
		Endif

		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "WSPRC", .T., .T.)
      dbGoTop()
      
		nPreco	:= iif(WSPRC->(!eof()), WSPRC->DA1_PRCVEN, 0)
		
		//Preenche o array		
		aAdd(::StructPRECO, WsClassNew("STRPRECO"))
		nK 										:= Len(::StructPRECO)
		::StructPRECO[nK]:CODMATERIAL 	:= cProduto
		::StructPRECO[nK]:PRECO				:= nPreco
		lRetorno 								:= .T.

		if Select("WSPRC") > 0
			WSPRC->(dbCloseArea())
		endif
		
	endif		

Next nI

if !(lRetorno)
  	SetSoapFault("2", "Erro-Nenhum Registro encontrado!!")
Endif

Return lRetorno 
