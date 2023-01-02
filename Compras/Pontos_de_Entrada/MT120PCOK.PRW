#include "rwmake.ch"
#include "protheus.ch"

/*/
�������������������������������������������������������������������������������
@function		MT120PCOK                                                    /@
@date			15.10.2014                                                   /@
@type			Ponto de entrada
@description	Acionado pelo fonte MATA120 permite validar a inclus�o ou 
				altera��o do pedido de compra e antes da valida��o de bloqueio
				do m�dulo SIGAPCO.                                           /@
@return			.T./.F.                                                      /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br) Op��o Um   /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
/*/
User Function MT120PCOK()
Local lRet 			:= .T.
Local aArea         := GetArea()
Local aAreaSY1      := SY1->(GetArea())
Local cStrForCod    := GetMV("BR_RHFORCD", .F., "")
Local lFilIN        := .F.

//�������������������������������������������������������������������������������
// Valida somente se inclus�o manual, ou seja, n�o por MSEXECAUTO
//�������������������������������������������������������������������������������
if !l120Auto

	//�������������������������������������������������������������������������������
	// As vari�veis cGI120ForPag, cGI120ObsGer, cGI120Bco, cGI120Age, cGI120DVAGE,
	// cGI120Cta e cGI120DVCta s�o p�blicas e foram definidas nos pontos de entrada 
	// MT120TEL e MT120FOL
	//�������������������������������������������������������������������������������

	//�������������������������������������������������������������������������������
	// Realizando valida��es no preenchimento do pedido de compras
	//�������������������������������������������������������������������������������
	if SC7->(FieldPos("C7_X_FORPG")) > 0

		//�������������������������������������������������������������������������������
		// Validando o preenchimento da forma de pagamento
		//�������������������������������������������������������������������������������
		if Empty(cGI120ForPag)

			lRet := .F.
			Help(" ", 1, "ATEN��O",, "O campo Forma de Pagamento � de preenchimento obrigat�rio." + chr(13) + chr(10) + "Espec�fico " + AllTrim(SM0->M0_NOME), 1)

		//�������������������������������������������������������������������������������
		// Para reembolso de consumidor final, a forma de pagamento deve ser deposito em
		// conta
		//�������������������������������������������������������������������������������
		elseif lGI120CF .and. Left(cGI120ForPag, 1) != "2"

			lRet := .F.
			Help(" ", 1, "ATEN��O",, "Para reembolso de consumidor final, a Forma de Pagamento deve ser 2-Dep�sito em conta." + chr(13) + chr(10) + "Espec�fico " + AllTrim(SM0->M0_NOME), 1)

		//�������������������������������������������������������������������������������
		// Para dep�sito em conta, dados de banco, agencia e conta devem ser preenchidos
		//�������������������������������������������������������������������������������
		elseif Left(cGI120ForPag,1) == "2"

			if Empty(cGI120Bco) .or. Empty(cGI120Age) .or. Empty(cGI120Cta) .or. Empty(cGI120DVCta)
				lRet := .F.
				Help(" ", 1, "ATEN��O",, "Para dep�sito em conta, obrigat�rio o preenchimento dos dados banc�rios (banco, ag�ncia, conta e dv conta)." + chr(13) + chr(10) + "Espec�fico " + AllTrim(SM0->M0_NOME), 1)

			//�������������������������������������������������������������������������������
			// Para reembolso de consumidor final, obrigat�rio o preenchimento do Nome e CPF
			//�������������������������������������������������������������������������������
			elseif lGI120CF .and. (Empty(cGI120CPF) .or. Empty(cGI120Consum))
				lRet := .F.
				Help(" ", 1, "ATEN��O",, "Para reembolso de consumidor final, obrigat�rio o preenchimento do nome e CPF do consumidor." + chr(13) + chr(10) + "Espec�fico " + AllTrim(SM0->M0_NOME), 1)

			endif

		endif

	endif

	//�������������������������������������������������������������������������������
	// Valida preenchimento do motivo da altera��o do pedido
	//�������������������������������������������������������������������������������
	if ALTERA .and. SC7->(FieldPos("C7_XMOTALT")) > 0 .and. Empty(cGI120MotAlt)

		lRet := .F.
		Help(" ", 1, "ATEN��O",, "Obrigat�rio preencher o motivo da altera��o do pedido de compras." + chr(13) + chr(10) + "Espec�fico " + AllTrim(SM0->M0_NOME), 1)

	endif

	//�������������������������������������������������������������������������������
	// Filtra pedido de compras, sendo:
	// 1) Para usu�rios pertencentes � grupos do RH, definidos no cadastro de 
	//    compradores (Y1_XCATEG) visualiza somente pedidos de fornecedores de 
	//    sal�rios, cadastrados no parametro BR_RHFORCD.
	// 2) Para usu�rios de outros grupos da empressa, n�o visualizar pedidos de 
	//    compras de fornecedores de sal�rios
	// obs: Para usu�rio admin n�o h� filtro
	// UTILIZADO EM CONJUNTO COM O PONTO DE ENTRADA MT120QRY
	//�������������������������������������������������������������������������������
	if !Empty(cStrForCod) .and. __cUserId != "000000"

		//�������������������������������������������������������������������������������
		// Identificando se comprador possui categoria "Recursos Humanos"
		//�������������������������������������������������������������������������������
		SY1->(dbSetOrder(3))    //Y1_FILIAL, Y1_USER
		if SY1->(dbSeek(XFILIAL("SY1") + __cUserId)) .and. SY1->Y1_XCATEG == "RH"
		// Identificando usu�rio do RH
		//if __cUserId $ cStrGrpRH
    	    lFilIN  := .T.
	    endif

		// Valida fornecedor
		if lFilIN .and. !cA120Forn $ cStrForCod
			Help(" ", 1, "ATEN��O",, "Voc� poder� incluir pedidos de compras somente com fornecedores especiais RH. Para outros, solicite a inclus�o pelo comprador." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
			lRet := .F.
		elseif !lFilIN .and. cA120Forn $ cStrForCod
			Help(" ", 1, "ATEN��O",, "Voc� n�o poder� incluir pedidos de compras com fornecedores especiais RH. Para isto, solicite ao departamento de RH." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
			lRet := .F.
		endif

	endif

endif

RestArea(aAreaSY1)
RestArea(aArea)

Return(lRet)