#Include "protheus.ch"
#Include "rwmake.ch"

/*/

覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		MA410DEL                                                     /@
@type			Ponto de entrada                                             /@
@date			05/06/2013                                                   /@
@description	P.E. na chamada da funcao de exclus縊 dos registros no SC5 
				(Pedidos de vendas). Apos excluir o registro no SC5.         /@
@author			Adalberto Moreno Batista - Op鈬o Um Consultoria              /@
@use			Espec?fico Brasitech                                         /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?

/*/
User Function MA410DEL()
Local aArea 	:= GetArea()
Local aAreaSX3	:= SX3->(GetArea())

SX3->(dbSetOrder(2))

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Caso seja um pedido de origem web (C5_X_ORIG=2), atualizo as seguintes 
// informacoes na tabela de pre-pedido                      
// * ZL_OBS2   - com o numero do pedido cancelado, mantendo eventuais informacoes 
//               anteriores.
// * ZL_GRVPED - que eh o flag do pre-pedido com a informacao de pre-pedido 
//               bloqueado.
//				 Status do or軋mento de vendas web ZL_GRVPED.
//				 ' '-Pendente de integra鈬o com o pedido de venda
//				 'A'-Pedido alterado na WEB. Pendente de nova integra鈬o com o
//				     pedido de venda.
//				 'E'-Identifica erro na tentativa de integra鈬o com o pedido 
//				     de vendas.
//				 'S'-Informa que o pr?-pedido foi integrado com o pedido de 
//				     vendas.
//				 'N'-Informa que o pedido de venda foi exclu?do.
//				 'F'-Informa que o or軋mento foi totalmente faturado.
//				 'P'-Indica que o or軋mento foi parcialmente faturado.
//				 'R'-Informa que houve elimina鈬o de res?duos no pedido de 
//				     vendas.                                                
// * ZL_PEDIDO - limpo o numero do pedido cancelado.                  
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if SX3->(dbSeek("ZL_GRVPED"))
	if M->C5_X_ORIG == "2"	
		SZL->(dbSetOrder(2))	//ZL_FILIAL+ZL_PEDIDO
		SZL->(dbSeek(xFilial("SZL") + SC5->C5_NUM))
		do while SZL->(dbSeek(xFilial("SZL") + SC5->C5_NUM))
			SZL->(RecLock("SZL", .F.))
			SZL->ZL_OBS2	:= AllTrim(SZL->ZL_OBS2) + iif(Empty(SZL->ZL_OBS2), "", ", ") + M->C5_NUM
			SZL->ZL_GRVPED	:= "R"
			SZL->ZL_PEDIDO	:= ""
			SZL->(MsUnlock())
		enddo
	endif
endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Apago movimentos VPC, caso existam
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if SX3->(dbSeek("ZK_CHAVE"))
	U_VPCApaga_FT03("2", SC5->(C5_FILIAL + C5_NUM))
endif

RestArea(aAreaSX3)
RestArea(aArea)
Return()
