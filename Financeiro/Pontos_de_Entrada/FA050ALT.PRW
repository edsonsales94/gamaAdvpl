#include "rwmake.ch"
#include "protheus.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		FA050ALT                                                     /@
@type			Ponto de entrada                                             /@
@date			27/05/2011                                                   /@
@description	Ponto de entrada para validação de alteração de um título a 
				pagar.                                                       /@
@author			Luiz Fernando C Nogueira                                     /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function FA050ALT()
Local lRet	:= .T.
Local aArea	:= GetArea()

//———————————————————————————————————————————————————————————————————————————————
// Validação do preenchimento do centro de custo de acordo com a conta contábil.
// Por: Luiz Fernando C Nogueira em 27/05/2011
//———————————————————————————————————————————————————————————————————————————————
lRet := A_FA050ALT()

//———————————————————————————————————————————————————————————————————————————————
// A partir da forma de pagamento registrado no fornecedor, verifico se as 
// informações obrigatórias para os tipos "Boleto" ou "Depósito em conta" estão
// registradas. 
// Por: Adalberto Moreno Batista em 23/09/2020
//———————————————————————————————————————————————————————————————————————————————
if lRet
	lRet := B_FA050ALT()	
endif

//———————————————————————————————————————————————————————————————————————————————
// Não permitir alterações de títulos que estiverem pendentes de retorno do banco
// Por: Adalberto Moreno Batista em 23/09/2020
//———————————————————————————————————————————————————————————————————————————————
if lRet .and. SE2->(FieldPos("E2_XCNAB"))>0
	lRet := C_FA050ALT()	
endif

RestArea(aArea)
Return(lRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		A_FA050ALT                                                   /@
@type			Static function                                              /@
@date			27/05/2011                                                   /@
@description	Função chamada pela user function FA050ALT. 
				Validação do preenchimento do centro de custo de acordo com
				a conta contábil.                                            /@
@author			Luiz Fernando C Nogueira                                     /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function A_FA050ALT()
Local lRet			:= .T.
Local cNatureza		:= M->E2_NATUREZ
Local cCCusto		:= M->E2_CCD 
Local cContaNat		:= Posicione("SED", 1, xFilial("SED") + cNatureza, "ED_CONTA") 

//———————————————————————————————————————————————————————————————————————————————
// Tratamento para não apresentar tela na alteração de titulo quando este for
// proveniente de um processo de msexecauto. Utilizo alteração de titulo no 
// controle VPC
// Por: Adalberto Moreno Batista em 13/11/13
//———————————————————————————————————————————————————————————————————————————————
if !lF050Auto
	if Empty(cContaNat)
		lRet := .F.
		MsgBox( "Conta Contabil não cadastrada na Natureza escolhida.Favor solicitar o cadastro ao Departamento responsável", "ATENÇÃO! (FA050ALT)", "ERRO" )
	ElseIf Left(cContaNat,1) == '4' .and. Empty(cCCusto)
		//lRet := .F.  Alterado Felipe Varella 18.05.2015
		MsgBox( "Natureza faz parte do grupo de Despesas. Portanto é obrigatório preencher o campo Centro de Custo.", "ATENÇÃO! (FA050ALT)", "ERRO" )
	endif
endif

Return(lRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		B_FA050ALT                                                   /@
@type			Static function                                              /@
@date			23/09/2020                                                   /@
@description	Função chamada pela user function FA050ALT.
				A partir da forma de pagamento registrado no fornecedor, 
				verifico se as informações obrigatórias para os tipos 
				"Boleto" ou "Depósito em conta" estão registradas.           /@
@author			Adalberto Moreno Batista                                     /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function B_FA050ALT()
Local lRet		:= .T.
Local lBoleto	:= .F.
Local lDeposito	:= .F.
Local cMsg		:= ""

//———————————————————————————————————————————————————————————————————————————————
// Pesquiso a forma de pagamento do título / configuração do fornecedor
//———————————————————————————————————————————————————————————————————————————————
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
	
//———————————————————————————————————————————————————————————————————————————————
// Verifico qual foi a forma de pagamento e verifico os campos correspondentes
// foram preenchidos
//———————————————————————————————————————————————————————————————————————————————
/*
if lDeposito
	if 	(Empty(SA2->A2_BANCO) .or.;
		Empty(SA2->A2_AGENCIA) .or.;
		Empty(SA2->A2_NUMCON))
	
		cMsg := "A forma de pagamento, indicada no pedido de compras ou no cadastro do fornecedor, utilizado nesta nota, informa que trata-se de um depósito em conta, porém as informações de banco/agência/conta do cadastro de fornecedor estão incompletas. Corrija o cadastro do fornecedor para poder incluir a nota fiscal."

	// Atualização dos dados no título, caso necessário
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

	cMsg := "A forma de pagamento indicada no título ou cadastro do fornecedor informa que trata-se de um depósito em conta, porém as informações de banco/agência/conta do cadastro de fornecedor estão incompletas. Corrija o cadastro do fornecedor para poder incluir o título."

elseif lBoleto .and. Empty(M->E2_CODBAR)

	cMsg := "A forma de pagamento indicada no título ou cadastro de fornecedor informa que trata-se de pagamento de boletos, porém o código de barras não foi informado no título."

endif


//———————————————————————————————————————————————————————————————————————————————
// Verificação do retorno
//———————————————————————————————————————————————————————————————————————————————
if !Empty(cMsg)
	if !IsBlind()
		Help(,, "ATENÇÃO",, cMsg + chr(13) + chr(10) + "(FA050ALT - Específico Brasitech)", 1)
	else
		ConOut(cMsg + "(FA050ALT - Específico Brasitech)")
	endif
	lRet := .F.
endif

Return(lRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		C_FA050ALT                                                   /@
@type			Static function                                              /@
@date			22/02/2022                                                   /@
@description	Função chamada pela user function FA050ALT.
				Não permitir alterações de títulos que estiverem pendentes 
				de retorno do banco                                          /@
@author			Adalberto Moreno Batista                                     /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function C_FA050ALT()
Local lRet		:= .T.
Local cMsg		:= ""

//———————————————————————————————————————————————————————————————————————————————
// Verifico se a alteração é em relação à valor, codigo de barras, dados 
// bancarios ou vencimento e se tiver com pendencia de retorno do banco, não 
// permito
//———————————————————————————————————————————————————————————————————————————————
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
	cMsg := "Título com pendencia de retorno do banco, portanto alguns campos não poderão ser alterados."

	//———————————————————————————————————————————————————————————————————————————————
	// Verificação do retorno
	//———————————————————————————————————————————————————————————————————————————————
	if !Empty(cMsg)
		if !IsBlind()
			Help(,, "ATENÇÃO",, cMsg + chr(13) + chr(10) + "(FA050ALT - Específico Brasitech)", 1)
		else
			ConOut(cMsg + "(FA050ALT - Específico Brasitech)")
		endif
	endif

endif

Return(lRet)
