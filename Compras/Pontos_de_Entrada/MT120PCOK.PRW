#include "rwmake.ch"
#include "protheus.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		MT120PCOK                                                    /@
@date			15.10.2014                                                   /@
@type			Ponto de entrada
@description	Acionado pelo fonte MATA120 permite validar a inclusão ou 
				alteração do pedido de compra e antes da validação de bloqueio
				do módulo SIGAPCO.                                           /@
@return			.T./.F.                                                      /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br) Opção Um   /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MT120PCOK()
Local lRet 			:= .T.
Local aArea         := GetArea()
Local aAreaSY1      := SY1->(GetArea())
Local cStrForCod    := GetMV("BR_RHFORCD", .F., "")
Local lFilIN        := .F.

//———————————————————————————————————————————————————————————————————————————————
// Valida somente se inclusão manual, ou seja, não por MSEXECAUTO
//———————————————————————————————————————————————————————————————————————————————
if !l120Auto

	//———————————————————————————————————————————————————————————————————————————————
	// As variáveis cGI120ForPag, cGI120ObsGer, cGI120Bco, cGI120Age, cGI120DVAGE,
	// cGI120Cta e cGI120DVCta são públicas e foram definidas nos pontos de entrada 
	// MT120TEL e MT120FOL
	//———————————————————————————————————————————————————————————————————————————————

	//———————————————————————————————————————————————————————————————————————————————
	// Realizando validações no preenchimento do pedido de compras
	//———————————————————————————————————————————————————————————————————————————————
	if SC7->(FieldPos("C7_X_FORPG")) > 0

		//———————————————————————————————————————————————————————————————————————————————
		// Validando o preenchimento da forma de pagamento
		//———————————————————————————————————————————————————————————————————————————————
		if Empty(cGI120ForPag)

			lRet := .F.
			Help(" ", 1, "ATENÇÃO",, "O campo Forma de Pagamento é de preenchimento obrigatório." + chr(13) + chr(10) + "Específico " + AllTrim(SM0->M0_NOME), 1)

		//———————————————————————————————————————————————————————————————————————————————
		// Para reembolso de consumidor final, a forma de pagamento deve ser deposito em
		// conta
		//———————————————————————————————————————————————————————————————————————————————
		elseif lGI120CF .and. Left(cGI120ForPag, 1) != "2"

			lRet := .F.
			Help(" ", 1, "ATENÇÃO",, "Para reembolso de consumidor final, a Forma de Pagamento deve ser 2-Depósito em conta." + chr(13) + chr(10) + "Específico " + AllTrim(SM0->M0_NOME), 1)

		//———————————————————————————————————————————————————————————————————————————————
		// Para depósito em conta, dados de banco, agencia e conta devem ser preenchidos
		//———————————————————————————————————————————————————————————————————————————————
		elseif Left(cGI120ForPag,1) == "2"

			if Empty(cGI120Bco) .or. Empty(cGI120Age) .or. Empty(cGI120Cta) .or. Empty(cGI120DVCta)
				lRet := .F.
				Help(" ", 1, "ATENÇÃO",, "Para depósito em conta, obrigatório o preenchimento dos dados bancários (banco, agência, conta e dv conta)." + chr(13) + chr(10) + "Específico " + AllTrim(SM0->M0_NOME), 1)

			//———————————————————————————————————————————————————————————————————————————————
			// Para reembolso de consumidor final, obrigatório o preenchimento do Nome e CPF
			//———————————————————————————————————————————————————————————————————————————————
			elseif lGI120CF .and. (Empty(cGI120CPF) .or. Empty(cGI120Consum))
				lRet := .F.
				Help(" ", 1, "ATENÇÃO",, "Para reembolso de consumidor final, obrigatório o preenchimento do nome e CPF do consumidor." + chr(13) + chr(10) + "Específico " + AllTrim(SM0->M0_NOME), 1)

			endif

		endif

	endif

	//———————————————————————————————————————————————————————————————————————————————
	// Valida preenchimento do motivo da alteração do pedido
	//———————————————————————————————————————————————————————————————————————————————
	if ALTERA .and. SC7->(FieldPos("C7_XMOTALT")) > 0 .and. Empty(cGI120MotAlt)

		lRet := .F.
		Help(" ", 1, "ATENÇÃO",, "Obrigatório preencher o motivo da alteração do pedido de compras." + chr(13) + chr(10) + "Específico " + AllTrim(SM0->M0_NOME), 1)

	endif

	//———————————————————————————————————————————————————————————————————————————————
	// Filtra pedido de compras, sendo:
	// 1) Para usuários pertencentes à grupos do RH, definidos no cadastro de 
	//    compradores (Y1_XCATEG) visualiza somente pedidos de fornecedores de 
	//    salários, cadastrados no parametro BR_RHFORCD.
	// 2) Para usuários de outros grupos da empressa, não visualizar pedidos de 
	//    compras de fornecedores de salários
	// obs: Para usuário admin não há filtro
	// UTILIZADO EM CONJUNTO COM O PONTO DE ENTRADA MT120QRY
	//———————————————————————————————————————————————————————————————————————————————
	if !Empty(cStrForCod) .and. __cUserId != "000000"

		//———————————————————————————————————————————————————————————————————————————————
		// Identificando se comprador possui categoria "Recursos Humanos"
		//———————————————————————————————————————————————————————————————————————————————
		SY1->(dbSetOrder(3))    //Y1_FILIAL, Y1_USER
		if SY1->(dbSeek(XFILIAL("SY1") + __cUserId)) .and. SY1->Y1_XCATEG == "RH"
		// Identificando usuário do RH
		//if __cUserId $ cStrGrpRH
    	    lFilIN  := .T.
	    endif

		// Valida fornecedor
		if lFilIN .and. !cA120Forn $ cStrForCod
			Help(" ", 1, "ATENÇÃO",, "Você poderá incluir pedidos de compras somente com fornecedores especiais RH. Para outros, solicite a inclusão pelo comprador." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
			lRet := .F.
		elseif !lFilIN .and. cA120Forn $ cStrForCod
			Help(" ", 1, "ATENÇÃO",, "Você não poderá incluir pedidos de compras com fornecedores especiais RH. Para isto, solicite ao departamento de RH." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
			lRet := .F.
		endif

	endif

endif

RestArea(aAreaSY1)
RestArea(aArea)

Return(lRet)
