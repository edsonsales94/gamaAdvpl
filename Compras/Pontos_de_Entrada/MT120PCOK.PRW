#include "rwmake.ch"
#include "protheus.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		MT120PCOK                                                    /@
@date			15.10.2014                                                   /@
@type			Ponto de entrada
@description	Acionado pelo fonte MATA120 permite validar a inclus縊 ou 
				altera鈬o do pedido de compra e antes da valida鈬o de bloqueio
				do m?dulo SIGAPCO.                                           /@
@return			.T./.F.                                                      /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br) Op鈬o Um   /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function MT120PCOK()
Local lRet 			:= .T.
Local aArea         := GetArea()
Local aAreaSY1      := SY1->(GetArea())
Local cStrForCod    := GetMV("BR_RHFORCD", .F., "")
Local lFilIN        := .F.

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Valida somente se inclus縊 manual, ou seja, n縊 por MSEXECAUTO
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if !l120Auto

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// As vari疱eis cGI120ForPag, cGI120ObsGer, cGI120Bco, cGI120Age, cGI120DVAGE,
	// cGI120Cta e cGI120DVCta s縊 p?blicas e foram definidas nos pontos de entrada 
	// MT120TEL e MT120FOL
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Realizando valida鋏es no preenchimento do pedido de compras
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	if SC7->(FieldPos("C7_X_FORPG")) > 0

		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		// Validando o preenchimento da forma de pagamento
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		if Empty(cGI120ForPag)

			lRet := .F.
			Help(" ", 1, "ATENﾇﾃO",, "O campo Forma de Pagamento ? de preenchimento obrigat?rio." + chr(13) + chr(10) + "Espec?fico " + AllTrim(SM0->M0_NOME), 1)

		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		// Para reembolso de consumidor final, a forma de pagamento deve ser deposito em
		// conta
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		elseif lGI120CF .and. Left(cGI120ForPag, 1) != "2"

			lRet := .F.
			Help(" ", 1, "ATENﾇﾃO",, "Para reembolso de consumidor final, a Forma de Pagamento deve ser 2-Dep?sito em conta." + chr(13) + chr(10) + "Espec?fico " + AllTrim(SM0->M0_NOME), 1)

		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		// Para dep?sito em conta, dados de banco, agencia e conta devem ser preenchidos
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		elseif Left(cGI120ForPag,1) == "2"

			if Empty(cGI120Bco) .or. Empty(cGI120Age) .or. Empty(cGI120Cta) .or. Empty(cGI120DVCta)
				lRet := .F.
				Help(" ", 1, "ATENﾇﾃO",, "Para dep?sito em conta, obrigat?rio o preenchimento dos dados banc疵ios (banco, ag麩cia, conta e dv conta)." + chr(13) + chr(10) + "Espec?fico " + AllTrim(SM0->M0_NOME), 1)

			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			// Para reembolso de consumidor final, obrigat?rio o preenchimento do Nome e CPF
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			elseif lGI120CF .and. (Empty(cGI120CPF) .or. Empty(cGI120Consum))
				lRet := .F.
				Help(" ", 1, "ATENﾇﾃO",, "Para reembolso de consumidor final, obrigat?rio o preenchimento do nome e CPF do consumidor." + chr(13) + chr(10) + "Espec?fico " + AllTrim(SM0->M0_NOME), 1)

			endif

		endif

	endif

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Valida preenchimento do motivo da altera鈬o do pedido
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	if ALTERA .and. SC7->(FieldPos("C7_XMOTALT")) > 0 .and. Empty(cGI120MotAlt)

		lRet := .F.
		Help(" ", 1, "ATENﾇﾃO",, "Obrigat?rio preencher o motivo da altera鈬o do pedido de compras." + chr(13) + chr(10) + "Espec?fico " + AllTrim(SM0->M0_NOME), 1)

	endif

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Filtra pedido de compras, sendo:
	// 1) Para usu疵ios pertencentes ? grupos do RH, definidos no cadastro de 
	//    compradores (Y1_XCATEG) visualiza somente pedidos de fornecedores de 
	//    sal疵ios, cadastrados no parametro BR_RHFORCD.
	// 2) Para usu疵ios de outros grupos da empressa, n縊 visualizar pedidos de 
	//    compras de fornecedores de sal疵ios
	// obs: Para usu疵io admin n縊 h? filtro
	// UTILIZADO EM CONJUNTO COM O PONTO DE ENTRADA MT120QRY
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	if !Empty(cStrForCod) .and. __cUserId != "000000"

		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		// Identificando se comprador possui categoria "Recursos Humanos"
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		SY1->(dbSetOrder(3))    //Y1_FILIAL, Y1_USER
		if SY1->(dbSeek(XFILIAL("SY1") + __cUserId)) .and. SY1->Y1_XCATEG == "RH"
		// Identificando usu疵io do RH
		//if __cUserId $ cStrGrpRH
    	    lFilIN  := .T.
	    endif

		// Valida fornecedor
		if lFilIN .and. !cA120Forn $ cStrForCod
			Help(" ", 1, "ATENﾇﾃO",, "Voc? poder? incluir pedidos de compras somente com fornecedores especiais RH. Para outros, solicite a inclus縊 pelo comprador." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
			lRet := .F.
		elseif !lFilIN .and. cA120Forn $ cStrForCod
			Help(" ", 1, "ATENﾇﾃO",, "Voc? n縊 poder? incluir pedidos de compras com fornecedores especiais RH. Para isto, solicite ao departamento de RH." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
			lRet := .F.
		endif

	endif

endif

RestArea(aAreaSY1)
RestArea(aArea)

Return(lRet)
