#include "rwmake.ch"
#include "protheus.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		MT120TEL                                                     /@
@date			13/10/2014                                                   /@
@type			Ponto de entrada
@description	Acionado pelo fonte MATA120 permite adicionar campos no 
				cabecalho e pastas no rodapé do pedidos de vendas            /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Consultoria                                         /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MT120TEL()
Local oBrDialog		:= PARAMIXB[1]
Local aPosGet		:= PARAMIXB[2]
//Local aObj		:= PARAMIXB[3]
Local nOpc			:= PARAMIXB[4]
//Local nReg		:= PARAMIXB[5]
Local aFormPag 		:= {"1-Boleto", "2-Depósito em Conta", "3-Dinheiro", "4-Cheque", "5-Debito em Conta", "N-Não Definido", ""}
Local lEdit			:= (nOpc != 2)	// .and. !Empty(cA120Forn) .and. !Empty(cA120Loj))
Local oFormPag, nFormPag
Public cGI120ForPag

//—————————————————————————————————————————————————————————————————————————
// Cria campo para forma de pagamento no cabeçalho e pasta especifica no rodapé
//—————————————————————————————————————————————————————————————————————————
if SC7->(FieldPos("C7_X_FORPG")) > 0 .and. SC7->(FieldPos("C7_X_OBSGE")) > 0 .and. nOpc != 1

	aAdd(aTitles, "® Brasitech")

	cGI120ForPag := Space(Len(SC7->C7_X_FORPG))
	if nOpc != 3
		if SC7->C7_X_FORPG == "1"
			nFormPag := 1
		elseif SC7->C7_X_FORPG == "2"
			nFormPag := 2
		elseif SC7->C7_X_FORPG == "3"
			nFormPag := 3
		elseif SC7->C7_X_FORPG == "4"
			nFormPag := 4
		elseif SC7->C7_X_FORPG == "N"
			nFormPag := 5
		else
			nFormPag := 0
		endif
		if nFormPag > 0
			cGI120ForPag	:= aFormPag[nFormPag]
		endif
	endif

//	@ 062, aPosGet[1,1]+408 Say "Forma do Pagto"  of oBrDialog Pixel Size 50,10
//	@ 061, aPosGet[1,2]+404 MsComboBox oFormPag Var cGI120ForPag Items aFormPag When lEdit Size 080,08 Valid U_VldFP_MT120TEL() Of oBrDialog Pixel Size 083,009
	@ aPosGet[1,1]+38, aPosGet[2,5]-12 Say "Forma do Pagto"  of oBrDialog Pixel Size 50,10
	@ aPosGet[1,1]+37, aPosGet[2,6]-25 MsComboBox oFormPag Var cGI120ForPag Items aFormPag When lEdit Size 080,08 Valid U_VldFP_MT120TEL() Of oBrDialog Pixel Size 083,009
	
endif

Return()

/*/
———————————————————————————————————————————————————————————————————————————————
@function		VldFP_MT120TEL                                               /@
@date			22/10/2014                                                   /@
@type			User function
@description	Acionado na validação da digitação da forma de pagamento,
				informado no ponto de entrada MT120TEL.                      /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Consultoria)                                        /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function VldFP_MT120TEL()
Local lRet := .T.

if Left(cGI120ForPag, 1) == "2"

	//if Empty(cGI120Bco) .or. Empty(cGI120Age) .or. Empty(cGI120Cta) .or. Empty(cGI120DVCta)
	if !lGI120CF .and.;
		(Empty(SA2->A2_BANCO) .or.;
		Empty(SA2->A2_AGENCIA) .or.;
		Empty(SA2->A2_NUMCON) .or.;
		Empty(SA2->A2_DVCTA))
	
		Help(" ", 1, "ATENÇÃO", , "Para forma de pagamento 'depósito em conta', é necessário informar o banco, agencia, conta e DV da conta do fornecedor. Verifique estas informações no cadastro do fornecedor." + chr(13) + chr(10) + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
	
		lRet := .F.

	else

//		Help(" ", 1, "ATENÇÃO", , "Você escolheu 'depósito em conta' como forma de pagamento. Confira na pasta do rodapé ® Brasitech se as informações de banco, agencia, conta do fornecedor estão corretas." + chr(13) + chr(10) + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)

	endif

endif


//———————————————————————————————————————————————————————————————————————————————
// Assunto tratado com Jorge Job em 10/06/21
// Validar a forma de pagamento do pedido, conforme o configurado no cadastro de
// fornecedor, onde:
// 1) no PC, não permitir o uso da forma 3-Dinheiro ou 4-Fatura
// 2) no PC, permitir somente o uso de 1-Boleto ou 2-Depósito em conta quando o
//    configurado no cadastro de fornecedor for boleto ou deposito
// 3) no PC, permitir o uso das formas 1-boleto, 2-deposito ou N-Não definido
// 	  comente quando estiver configurado 1-Normal no fornecedor
//———————————————————————————————————————————————————————————————————————————————
if lRet
	if Left(cGI120ForPag, 1) $ "3/4" .or. (Left(cGI120ForPag, 1) $ "N" .and. SA2->A2_X_FGTO != "1")
		lRet := .F.
		Help(" ", 1, "ATENÇÃO", , "Esta Forma de Pagamento não poderá ser utilizada neste pedido." + chr(13) + chr(10) + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
	endif
endif

Return(lRet)
