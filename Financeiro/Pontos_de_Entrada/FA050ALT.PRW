#include "rwmake.ch"
#include "protheus.ch"

/*/
�������������������������������������������������������������������������������
@function		FA050ALT                                                     /@
@type			Ponto de entrada                                             /@
@date			27/05/2011                                                   /@
@description	Ponto de entrada para valida��o de altera��o de um t�tulo a 
				pagar.                                                       /@
@author			Luiz Fernando C Nogueira                                     /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
/*/
User Function FA050ALT()
Local lRet	:= .T.
Local aArea	:= GetArea()

//�������������������������������������������������������������������������������
// Valida��o do preenchimento do centro de custo de acordo com a conta cont�bil.
// Por: Luiz Fernando C Nogueira em 27/05/2011
//�������������������������������������������������������������������������������
lRet := A_FA050ALT()

//�������������������������������������������������������������������������������
// A partir da forma de pagamento registrado no fornecedor, verifico se as 
// informa��es obrigat�rias para os tipos "Boleto" ou "Dep�sito em conta" est�o
// registradas. 
// Por: Adalberto Moreno Batista em 23/09/2020
//�������������������������������������������������������������������������������
if lRet
	lRet := B_FA050ALT()	
endif

//�������������������������������������������������������������������������������
// N�o permitir altera��es de t�tulos que estiverem pendentes de retorno do banco
// Por: Adalberto Moreno Batista em 23/09/2020
//�������������������������������������������������������������������������������
if lRet .and. SE2->(FieldPos("E2_XCNAB"))>0
	lRet := C_FA050ALT()	
endif

RestArea(aArea)
Return(lRet)


/*/
�������������������������������������������������������������������������������
@function		A_FA050ALT                                                   /@
@type			Static function                                              /@
@date			27/05/2011                                                   /@
@description	Fun��o chamada pela user function FA050ALT. 
				Valida��o do preenchimento do centro de custo de acordo com
				a conta cont�bil.                                            /@
@author			Luiz Fernando C Nogueira                                     /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
/*/
Static Function A_FA050ALT()
Local lRet			:= .T.
Local cNatureza		:= M->E2_NATUREZ
Local cCCusto		:= M->E2_CCD 
Local cContaNat		:= Posicione("SED", 1, xFilial("SED") + cNatureza, "ED_CONTA") 

//�������������������������������������������������������������������������������
// Tratamento para n�o apresentar tela na altera��o de titulo quando este for
// proveniente de um processo de msexecauto. Utilizo altera��o de titulo no 
// controle VPC
// Por: Adalberto Moreno Batista em 13/11/13
//�������������������������������������������������������������������������������
if !lF050Auto
	if Empty(cContaNat)
		lRet := .F.
		MsgBox( "Conta Contabil n�o cadastrada na Natureza escolhida.Favor solicitar o cadastro ao Departamento respons�vel", "ATEN��O! (FA050ALT)", "ERRO" )
	ElseIf Left(cContaNat,1) == '4' .and. Empty(cCCusto)
		//lRet := .F.  Alterado Felipe Varella 18.05.2015
		MsgBox( "Natureza faz parte do grupo de Despesas. Portanto � obrigat�rio preencher o campo Centro de Custo.", "ATEN��O! (FA050ALT)", "ERRO" )
	endif
endif

Return(lRet)


/*/
�������������������������������������������������������������������������������
@function		B_FA050ALT                                                   /@
@type			Static function                                              /@
@date			23/09/2020                                                   /@
@description	Fun��o chamada pela user function FA050ALT.
				A partir da forma de pagamento registrado no fornecedor, 
				verifico se as informa��es obrigat�rias para os tipos 
				"Boleto" ou "Dep�sito em conta" est�o registradas.           /@
@author			Adalberto Moreno Batista                                     /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
/*/
Static Function B_FA050ALT()
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
		Help(,, "ATEN��O",, cMsg + chr(13) + chr(10) + "(FA050ALT - Espec�fico Brasitech)", 1)
	else
		ConOut(cMsg + "(FA050ALT - Espec�fico Brasitech)")
	endif
	lRet := .F.
endif

Return(lRet)


/*/
�������������������������������������������������������������������������������
@function		C_FA050ALT                                                   /@
@type			Static function                                              /@
@date			22/02/2022                                                   /@
@description	Fun��o chamada pela user function FA050ALT.
				N�o permitir altera��es de t�tulos que estiverem pendentes 
				de retorno do banco                                          /@
@author			Adalberto Moreno Batista                                     /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
/*/
Static Function C_FA050ALT()
Local lRet		:= .T.
Local cMsg		:= ""

//�������������������������������������������������������������������������������
// Verifico se a altera��o � em rela��o � valor, codigo de barras, dados 
// bancarios ou vencimento e se tiver com pendencia de retorno do banco, n�o 
// permito
//�������������������������������������������������������������������������������
if !Empty(SE2->E2_XCNAB) .and.;
	M->E2_VALOR != SE2->E2_VALOR .and.;
	M->E2_XFORPAG != SE2->E2_XFORPAG .and.;
	M->E2_EMISSAO != SE2->E2_EMISSAO .and.;
	M->E2_VENCTO != SE2->E2_VENCTO .and.;
	M->E2_VENCREA != SE2->E2_VENCREA .and.;
	M->E2_CODBAR != SE2->E2_CODBAR .and.;
	M->E2_FORBCO != SE2->E2_FORBCO .and.;
	M->E2_FORAGE != SE2->E2_FORAGE .and.;
	M->E2_FAGEDV != SE2->E2_FAGEDV .and.;
	M->E2_FORCTA != SE2->E2_FORCTA .and.;
	M->E2_FCTADV != SE2->E2_FCTADV .and.;
	M->E2_ACRESC != SE2->E2_ACRESC .and.;
	M->E2_DECRESC !=SE2->E2_DECRESC

	lRet := .F.
	cMsg := "T�tulo com pendencia de retorno do banco, portanto alguns campos n�o poder�o ser alterados."

	//�������������������������������������������������������������������������������
	// Verifica��o do retorno
	//�������������������������������������������������������������������������������
	if !Empty(cMsg)
		if !IsBlind()
			Help(,, "ATEN��O",, cMsg + chr(13) + chr(10) + "(FA050ALT - Espec�fico Brasitech)", 1)
		else
			ConOut(cMsg + "(FA050ALT - Espec�fico Brasitech)")
		endif
	endif

endif

Return(lRet)