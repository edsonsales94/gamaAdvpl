#include "rwmake.ch"
#include "protheus.ch"

/*/
�������������������������������������������������������������������������������
@function		FA050INC                                                     /@
@type			Ponto de entrada                                             /@
@date			27/05/2011                                                   /@
@description	Ponto de entrada para valida��o de inclus�o de um t�tulo a 
				pagar.                                                       /@
@author			Luiz Fernando C Nogueira                                     /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
/*/
User Function FA050INC()
Local lRet	:= .T.
Local aArea	:= GetArea()

//�������������������������������������������������������������������������������
// Valida��o do preenchimento do centro de custo de acordo com a conta cont�bil.
// Por: Luiz Fernando C Nogueira em 27/05/2011
//�������������������������������������������������������������������������������
lRet := A_FA050INC()

//�������������������������������������������������������������������������������
// A partir da forma de pagamento registrado no fornecedor, verifico se as 
// informa��es obrigat�rias para os tipos "Boleto" ou "Dep�sito em conta" est�o
// registradas. 
// Por: Adalberto Moreno Batista em 23/09/2020
//�������������������������������������������������������������������������������
if lRet
	lRet := B_FA050INC()	
endif

//�������������������������������������������������������������������������������
// Verifica��o se h� titulos do tipo "PA ou OP ou TX" do mesmo fornecedor, loja
// vencimento (E2_VENCTO) e valor.
//�������������������������������������������������������������������������������
if lRet .and. M->E2_TIPO $ "PA #OP #TX "
	lRet := C_FA050INC()	
endif

RestArea(aArea)
Return(lRet)


/*/
�������������������������������������������������������������������������������
@function		A_FA050INC                                                   /@
@type			Static function                                              /@
@date			27/05/2011                                                   /@
@description	Fun��o chamada pela user function FA050INC. 
				Valida��o do preenchimento do centro de custo de acordo com
				a conta cont�bil.                                            /@
@author			Luiz Fernando C Nogueira                                     /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
/*/
Static Function A_FA050INC()
Local lRet			:= .T.
Local cNatureza		:= M->E2_NATUREZ
Local cCCusto		:= M->E2_CCD 
Local cContaNat		:= Posicione("SED", 1, xFilial("SED") + cNatureza, "ED_CONTA") 

//�������������������������������������������������������������������������������
// Tratamento para n�o apresentar tela na inclus�o de titulo quando este for
// proveniente de um processo de msexecauto. Utilizo inclus�o de titulo no 
// controle VPC
// Por: Adalberto Moreno Batista em 13/11/13
//�������������������������������������������������������������������������������
if !lF050Auto
	if Empty(cContaNat)
		lRet := .F.
		MsgBox( "Conta Contabil n�o cadastrada na Natureza escolhida.Favor solicitar o cadastro ao Departamento respons�vel", "ATEN��O! (FA050INC)", "ERRO" )
	ElseIf Left(cContaNat,1) == '4' .and. Empty(cCCusto)
		//lRet := .F.  Alterado Felipe Varella 18.05.2015
		MsgBox( "Natureza faz parte do grupo de Despesas. Portanto � obrigat�rio preencher o campo Centro de Custo.", "ATEN��O! (FA050INC)", "ERRO" )
	endif
endif

Return(lRet)


/*/
�������������������������������������������������������������������������������
@function		B_FA050INC                                                   /@
@type			Static function                                              /@
@date			23/09/2020                                                   /@
@description	Fun��o chamada pela user function FA050INC.
				A partir da forma de pagamento registrado no fornecedor, 
				verifico se as informa��es obrigat�rias para os tipos 
				"Boleto" ou "Dep�sito em conta" est�o registradas.           /@
@author			Adalberto Moreno Batista                                     /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
/*/
Static Function B_FA050INC()
Local lRet		:= .T.
Local lBoleto	:= .F.
Local lDeposito	:= .F.
Local cMsg		:= ""

//�������������������������������������������������������������������������������
// Pesquiso a forma de pagamento do t�tulo / configura��o do fornecedor
//�������������������������������������������������������������������������������
if !Empty(M->E2_XFORPAG)
	if M->E2_XFORPAG == "BOL"
		lBoleto 	:= .T.
	elseif M->E2_XFORPAG == "DEP"
		lDeposito	:= .T.
	endif
else
	if SA2->A2_X_FGTO == "2"
		lBoleto 	:= .T.
	elseif SA2->A2_X_FGTO == "4"
		lDeposito	:= .T.
	endif
endif	

//�������������������������������������������������������������������������������
// Verifico qual foi a forma de pagamento e verifico os campos correspondentes
// foram preenchidos
//�������������������������������������������������������������������������������
/*
if lDeposito
	if 	(Empty(SA2->A2_BANCO) .or.;
		Empty(SA2->A2_AGENCIA) .or.;
		Empty(SA2->A2_NUMCON))
	
		cMsg := "A forma de pagamento, indicada no pedido de compras ou no cadastro do fornecedor, utilizado nesta nota, informa que trata-se de um dep�sito em conta, por�m as informa��es de banco/ag�ncia/conta do cadastro de fornecedor est�o incompletas. Corrija o cadastro do fornecedor para poder incluir a nota fiscal."

	// Atualiza��o dos dados no t�tulo, caso necess�rio
	elseif (Empty(M->E2_FORBCO) .or.;
			Empty(M->E2_FORAGE) .or.;
			Empty(M->E2_FORCTA)) .or.;
			Empty(M->E2_FCTADV))

		M->E2_FORBCO	:= SA2->A2_BANCO
		M->E2_FORAGE	:= SA2->A2_AGENCIA
		M->E2_FAGEDV	:= SA2->A2_DVAGE
		M->E2_FORCTA	:= SA2->A2_NUMCON
		M->E2_FCTADV	:= SA2->A2_DVCTA

	endif
*/
if lDeposito .and. (Empty(M->E2_FORBCO) .or. Empty(M->E2_FORAGE) .or. Empty(M->E2_FORCTA) .or. Empty(M->E2_FCTADV))

	cMsg := "A forma de pagamento indicada no t�tulo ou cadastro do fornecedor informa que trata-se de um dep�sito em conta, por�m as informa��es de banco/ag�ncia/conta do cadastro de fornecedor est�o incompletas. Corrija o cadastro do fornecedor para poder incluir o t�tulo."

elseif lBoleto .and. Empty(M->E2_CODBAR)

	cMsg := "A forma de pagamento indicada no t�tulo ou cadastro de fornecedor informa que trata-se de pagamento de boletos, por�m o c�digo de barras n�o foi informado no t�tulo."

endif

//�������������������������������������������������������������������������������
// Verifica��o do retorno
//�������������������������������������������������������������������������������
if !Empty(cMsg)
	if !IsBlind()
		Help(,, "ATEN��O",, cMsg + chr(13) + chr(10) + "(FA050INC - Espec�fico Brasitech)", 1)
	else
		ConOut(cMsg + "(FA050INC - Espec�fico Brasitech)")
	endif
	lRet := .F.
endif

if lRet .and. lBoleto .and. !Empty(M->E2_CODBAR)
	lRet := U_ChkCodBar(M->E2_CODBAR)
endif

Return(lRet)


/*/
�������������������������������������������������������������������������������
@function		C_FA050INC                                                   /@
@type			Static function                                              /@
@date			22/08/2022                                                   /@
@description	Fun��o chamada pela user function FA050INC.
				Verifica��o se h� titulos do tipo "PA ou OP ou TX" do mesmo
				fornecedor, loja, vencimento (E2_VENCTO) e valor.            /@
@author			Adalberto Moreno Batista                                     /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
/*/
Static Function C_FA050INC()
Local lRet		:= .T.
Local aArea		:= GetArea()
Local cQuery, cMsgErro

cQuery := "SELECT COUNT(*) TITPA "
cQuery += "FROM " + RetSqlName("SE2") + " SE2 "
cQuery += "WHERE E2_FILIAL='" + xFilial("SE2") + "' AND "
cQuery += 		"E2_FORNECE='" + M->E2_FORNECE + "' AND "
cQuery += 		"E2_LOJA='" + M->E2_LOJA + "' AND "
cQuery += 		"E2_TIPO='" + M->E2_TIPO + "' AND "
cQuery += 		"E2_VENCTO='" + dTOs(M->E2_VENCTO) + "' AND "
cQuery += 		"E2_VALOR=" + AllTrim(Str(M->E2_VALOR)) + " AND "
cQuery += 		"E2_CODBAR='" + M->E2_CODBAR + "' AND "
cQuery += 		"SE2.D_E_L_E_T_ = ' ' AND "
cQuery += 		"E2_FORNECE NOT IN ('07872326','10374780', 'D.C.I.') "
if Select("TMPSE2") > 0
	TMPSE2->(dbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TMPSE2", .F., .T.)
dbSelectArea("TMPSE2")
if !eof()
	if TMPSE2->TITPA > 0
		lRet		:= .F.
		cMsgErro 	:= "J� existe um t�tulo '" + AllTrim(M->E2_TIPO) + "' para este fornecedor, loja, vencimento e valor."
		if !IsBlind()
			Help("", 1, "ATEN��O",, cMsgErro + chr(13) + chr(10) + "(Espec�fico " + AllTrim(SM0->M0_NOME) + "-fa050inc)", 1)
		else
			ConOut(cMsgErro + " - (Espec�fico " + AllTrim(SM0->M0_NOME) + "-fa050inc)")
		endif
	endif
endif

if Select("TMPSE2") > 0
	TMPSE2->(dbCloseArea())
endif

RestArea(aArea)

Return(lRet)