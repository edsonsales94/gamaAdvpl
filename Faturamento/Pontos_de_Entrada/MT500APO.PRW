#include "totvs.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		MT500APO                                                      /@
@type				Ponto de entrada                                              /@
@date				02/08/2013                                                    /@
@description	Executado após a eliminação de resíduo por registro do SC6    /@
@author			Adalberto Moreno Batista - Opção Um Consultoria               /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MT500APO()
Local lResiduo	:= PARAMIXB[1]
Local aArea		:= GetArea()
Local aAreaSX3	:= SX3->(GetArea())

SX3->(dbSetOrder(2))

//———————————————————————————————————————————————————————————————————————————————
// Para pedidos bonificados VPC, na eliminação de resíduos o sistema gerará
// CREDITOS VPC. Os registros serão criados por item do pedido de vendas 
// por: Adalberto Moreno Batista em 02/08/13                                
//———————————————————————————————————————————————————————————————————————————————
if lResiduo .and. SC5->(FieldPos("C5_X_VPC")) > 0 .and. SC6->(FieldPos("C6_X_VPCIT")) > 0
	A_MT500APO()
endif

//———————————————————————————————————————————————————————————————————————————————
// Atualização de informações na tabela de pré-pedido SZL, informando a 
// quantidade residual eliminada e atualizando o status do registro.
// por: Adalberto Moreno Batista em 07/02/14
//———————————————————————————————————————————————————————————————————————————————
//if lResiduo .and. SX3->(dbSeek("ZL_QTDRES")) .and. SC5->C5_X_ORIG == "2"
//	B_MT500APO()
//endif

RestArea(aAreaSX3)
RestArea(aArea)
Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		A_MT500APO                                                    /@
@type				Static function                                               /@
@date				02/08/2013                                                    /@
@description	Acionado pela user function MT500APO. Para pedidos bonifica-
					dos VPC, na eliminação de resíduos o sistema gerará CREDITOS
					VPC. Os registros serão criados por item do pedido de vendas  /@
@author			Adalberto Moreno Batista - Opção Um Consultoria               /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function A_MT500APO()
Local nValCred		:= SC6->((C6_QTDVEN - C6_QTDENT) * C6_PRCVEN)
Local nValIPI		:= 0
Local cVPCAvulsa	:= "AVU"		//"000" - troca de codigo do avulso de "000" para "AVU"
Local lIPI, cHistorico, lLoja
Local aAreaSA1	:= SA1->(GetArea())
Local aAreaSB1	:= SB1->(GetArea())
Local aAreaSF4	:= SF4->(GetArea())

if nValCred > 0 .and. SC5->C5_TIPO $ "NCIP" .and. (SC5->C5_X_VPC == "S" .or. SC6->C6_X_VPCIT == "S")
	
	SA1->(dbSetOrder(1))
	SB1->(dbSetOrder(1))
	SF4->(dbSetOrder(1))
	SZI->(dbSetOrder(1))	//ZI_FILIAL+ZI_COD
	SZJ->(dbSetOrder(1))	//ZJ_FILIAL+ZJ_CONTRAT+ZJ_CLIENTE+ZJ_LOJA

	SA1->(dbSeek(xFilial("SA1") + SC5->(C5_CLIENTE + C5_LOJACLI)))
	SB1->(dbSeek(xFilial("SB1") + SC6->C6_PRODUTO))
	SF4->(dbSeek(xFilial("SF4") + SC6->C6_TES))

	lIPI := .T.
	if !empty(SC5->C5_X_CTVPC)
		if SZJ->(dbSeek(xFilial("SZJ") + SC5->C5_X_CTVPC))
			lIPI := (SZJ->ZJ_IPI == "S")
		endif
	endif
	
	lLoja := (SA1->A1_X_MDVPC == "L")
	
	if SF4->F4_IPI == "S" .and. lIPI
		nValIPI := nValCred * (SB1->B1_IPI / 100)
	endif

	SZI->(dbSeek(xFilial("SZI") + cVPCAvulsa))
	cHistorico := 	"Credito por eliminacao residuo Pedido/Item: " + SC6->(C6_NUM + "/" + C6_ITEM) +;
					", TpVPC: 999-" + AllTrim(SZI->ZI_DESCR) +;
					iif(!empty(SC5->C5_X_CTVPC), ", Contrato: " + AllTrim(SC5->C5_X_CTVPC), "")

	//———————————————————————————————————————————————————————————————————————————————
	// Atualizando a tabela SZK - movimentos VPC
	// Função do fonte BFATA03.PRW
	// Parâmetros da função U_VPCGrava_FT03
	//	[1]- Tipo do movimento "CR" para crédito e "DB" para débito
	//	[2]- Código do cliente
	//	[3]- Loja do cliente, qdo o contrato exigir. Somente p/ situações com contrato VPC
	//	[4]- Codigo do contrato VPC
	//	[5]- Tipo do percentual VPC
	//	[6]- Valor da base de cálculo
	//	[7]- Valor do débito ou crédito do movimento
	//	[8]- Campo descritivo com o histórico do lançamento 
	//	[9]- Origem do lançamento
	//	[10]- Chave do registro que originou o lançamento
	//	[11]- Uso da VPC S/N para: NCC / CtaPag / Ped.Bonificados
	//	[12]- Data do movimento
	//	[13]- Percentual
	//———————————————————————————————————————————————————————————————————————————————
	U_VPCGrava_FT03("CR",;
					SC5->C5_CLIENTE,;
					iif(lLoja, SC5->C5_LOJACLI, ""),;
					SC5->C5_X_CTVPC,;
					cVPCAvulsa,;
					nValCred + nValIPI,;
					nValCred + nValIPI,;
					cHistorico,;
					"2",;
					SC6->(C6_FILIAL + C6_NUM + C6_ITEM),;
					"SSS",;
					dDataBase,;
					0 )

	RestArea(aAreaSA1)
	RestArea(aAreaSB1)
	RestArea(aAreaSF4)

endif

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		B_MT500APO                                                    /@
@type				Static function                                               /@
@date				07/02/2014                                                    /@
@description	Acionado pela user function MT500APO. Atualização de infor-
					mações na tabela de pré-pedido SZL, informando a quantidade 
					residual eliminada e atualizando o status do registro.
					Status do orçamento de vendas web ZL_GRVPED.
					' '-Pendente de integração com o pedido de venda
					'A'-Pedido alterado na WEB. Pendente de nova integração com o
					    pedido de venda.
					'E'-Identifica erro na tentativa de integração com o pedido 
					    de vendas.
					'S'-Informa que o pré-pedido foi integrado com o pedido de 
					    vendas.
					'N'-Informa que o pedido de venda foi excluído.
					'F'-Informa que o orçamento foi totalmente faturado.
					'P'-Indica que o orçamento foi parcialmente faturado.
					'R'-Informa que houve eliminação de resíduos no pedido de 
				    vendas.                                                      /@
@author			Adalberto Moreno Batista - Opção Um Consultoria               /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function B_MT500APO()

SZL->(dbSetOrder(1))	//ZL_FILIAL + ZL_NUM + ZL_ITEM
if SZL->(dbSeek(xFilial("SZL") + SC6->(C6_X_NUMZL + C6_X_ITEZL)))
	SZL->(RecLock("SZL", .F.))
	SZL->ZL_GRVPED 	:= "R"
	SZL->ZL_QTDRES	:= SC6->(C6_QTDVEN - C6_QTDENT)
	SZL->(MsUnlock())
endif
	
Return()