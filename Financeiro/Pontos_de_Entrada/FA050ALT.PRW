#include "rwmake.ch"
#include "protheus.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		FA050ALT                                                     /@
@type			Ponto de entrada                                             /@
@date			27/05/2011                                                   /@
@description	Ponto de entrada para valida鈬o de altera鈬o de um t?tulo a 
				pagar.                                                       /@
@author			Luiz Fernando C Nogueira                                     /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function FA050ALT()
Local lRet	:= .T.
Local aArea	:= GetArea()

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Valida鈬o do preenchimento do centro de custo de acordo com a conta cont畸il.
// Por: Luiz Fernando C Nogueira em 27/05/2011
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
lRet := A_FA050ALT()

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// A partir da forma de pagamento registrado no fornecedor, verifico se as 
// informa鋏es obrigat?rias para os tipos "Boleto" ou "Dep?sito em conta" est縊
// registradas. 
// Por: Adalberto Moreno Batista em 23/09/2020
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if lRet
	lRet := B_FA050ALT()	
endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// N縊 permitir altera鋏es de t?tulos que estiverem pendentes de retorno do banco
// Por: Adalberto Moreno Batista em 23/09/2020
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if lRet .and. SE2->(FieldPos("E2_XCNAB"))>0
	lRet := C_FA050ALT()	
endif

RestArea(aArea)
Return(lRet)


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		A_FA050ALT                                                   /@
@type			Static function                                              /@
@date			27/05/2011                                                   /@
@description	Fun鈬o chamada pela user function FA050ALT. 
				Valida鈬o do preenchimento do centro de custo de acordo com
				a conta cont畸il.                                            /@
@author			Luiz Fernando C Nogueira                                     /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function A_FA050ALT()
Local lRet			:= .T.
Local cNatureza		:= M->E2_NATUREZ
Local cCCusto		:= M->E2_CCD 
Local cContaNat		:= Posicione("SED", 1, xFilial("SED") + cNatureza, "ED_CONTA") 

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Tratamento para n縊 apresentar tela na altera鈬o de titulo quando este for
// proveniente de um processo de msexecauto. Utilizo altera鈬o de titulo no 
// controle VPC
// Por: Adalberto Moreno Batista em 13/11/13
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if !lF050Auto
	if Empty(cContaNat)
		lRet := .F.
		MsgBox( "Conta Contabil n縊 cadastrada na Natureza escolhida.Favor solicitar o cadastro ao Departamento respons疱el", "ATENﾇﾃO! (FA050ALT)", "ERRO" )
	ElseIf Left(cContaNat,1) == '4' .and. Empty(cCCusto)
		//lRet := .F.  Alterado Felipe Varella 18.05.2015
		MsgBox( "Natureza faz parte do grupo de Despesas. Portanto ? obrigat?rio preencher o campo Centro de Custo.", "ATENﾇﾃO! (FA050ALT)", "ERRO" )
	endif
endif

Return(lRet)


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		B_FA050ALT                                                   /@
@type			Static function                                              /@
@date			23/09/2020                                                   /@
@description	Fun鈬o chamada pela user function FA050ALT.
				A partir da forma de pagamento registrado no fornecedor, 
				verifico se as informa鋏es obrigat?rias para os tipos 
				"Boleto" ou "Dep?sito em conta" est縊 registradas.           /@
@author			Adalberto Moreno Batista                                     /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function B_FA050ALT()
Local lRet		:= .T.
Local lBoleto	:= .F.
Local lDeposito	:= .F.
Local cMsg		:= ""

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Pesquiso a forma de pagamento do t?tulo / configura鈬o do fornecedor
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
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
	
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Verifico qual foi a forma de pagamento e verifico os campos correspondentes
// foram preenchidos
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*
if lDeposito
	if 	(Empty(SA2->A2_BANCO) .or.;
		Empty(SA2->A2_AGENCIA) .or.;
		Empty(SA2->A2_NUMCON))
	
		cMsg := "A forma de pagamento, indicada no pedido de compras ou no cadastro do fornecedor, utilizado nesta nota, informa que trata-se de um dep?sito em conta, por駑 as informa鋏es de banco/ag麩cia/conta do cadastro de fornecedor est縊 incompletas. Corrija o cadastro do fornecedor para poder incluir a nota fiscal."

	// Atualiza鈬o dos dados no t?tulo, caso necess疵io
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

	cMsg := "A forma de pagamento indicada no t?tulo ou cadastro do fornecedor informa que trata-se de um dep?sito em conta, por駑 as informa鋏es de banco/ag麩cia/conta do cadastro de fornecedor est縊 incompletas. Corrija o cadastro do fornecedor para poder incluir o t?tulo."

elseif lBoleto .and. Empty(M->E2_CODBAR)

	cMsg := "A forma de pagamento indicada no t?tulo ou cadastro de fornecedor informa que trata-se de pagamento de boletos, por駑 o c?digo de barras n縊 foi informado no t?tulo."

endif


//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Verifica鈬o do retorno
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if !Empty(cMsg)
	if !IsBlind()
		Help(,, "ATENﾇﾃO",, cMsg + chr(13) + chr(10) + "(FA050ALT - Espec?fico Brasitech)", 1)
	else
		ConOut(cMsg + "(FA050ALT - Espec?fico Brasitech)")
	endif
	lRet := .F.
endif

Return(lRet)


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		C_FA050ALT                                                   /@
@type			Static function                                              /@
@date			22/02/2022                                                   /@
@description	Fun鈬o chamada pela user function FA050ALT.
				N縊 permitir altera鋏es de t?tulos que estiverem pendentes 
				de retorno do banco                                          /@
@author			Adalberto Moreno Batista                                     /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function C_FA050ALT()
Local lRet		:= .T.
Local cMsg		:= ""

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Verifico se a altera鈬o ? em rela鈬o ? valor, codigo de barras, dados 
// bancarios ou vencimento e se tiver com pendencia de retorno do banco, n縊 
// permito
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
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
	cMsg := "T?tulo com pendencia de retorno do banco, portanto alguns campos n縊 poder縊 ser alterados."

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Verifica鈬o do retorno
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	if !Empty(cMsg)
		if !IsBlind()
			Help(,, "ATENﾇﾃO",, cMsg + chr(13) + chr(10) + "(FA050ALT - Espec?fico Brasitech)", 1)
		else
			ConOut(cMsg + "(FA050ALT - Espec?fico Brasitech)")
		endif
	endif

endif

Return(lRet)
