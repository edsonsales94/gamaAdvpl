#Include "Rwmake.ch"
#Include  "Protheus.ch"     

/*/
———————————————————————————————————————————————————————————————————————————————
@function		MA030TOK                                                     /@
@type			Ponto de entrada                                             /@
@date			23/06/2010                                                   /@
@description	Ponto de Entrada para validação na inclusão e alteração de
				clientes                                                     /@
@author			Luiz Fernando                                                /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MA030TOK() 
Local lRet 		:= .T.
Local aAreaAtu	:= GetArea()             

//———————————————————————————————————————————————————————————————————————————————
// Valida CNPJ para clientes nacionais e estrangeiros
//———————————————————————————————————————————————————————————————————————————————
lRet := A_MA030TOK()

//———————————————————————————————————————————————————————————————————————————————
// Verifica carga media se cliente é do MT
//———————————————————————————————————————————————————————————————————————————————
/* Retirado em 06/07/20, por solicitação Cleber e Julio
if lRet .and. !(M->A1_TIPO == "F") .and. AllTrim(M->A1_EST) == 'MT'
	lRet := B_MA030TOK()
endif */

//———————————————————————————————————————————————————————————————————————————————
// Valida campo A1_XCADCLI se cadastro é principal sim ou não
//———————————————————————————————————————————————————————————————————————————————
if lRet .and. SA1->(FieldPos("A1_XCADCLI")) > 0
	lRet := C_MA030TOK()
endif

//———————————————————————————————————————————————————————————————————————————————
// Valida informação referente ao campo Tipo Vencimento (A1_XTPVCTO), para grupo
// de cliente, obrigando a manter a mesma informação das outras lojas.
// Por Adalberto Moreno Batista em 18/01/21
//———————————————————————————————————————————————————————————————————————————————
if lRet .and. M->A1_EST != "EX" .and. M->A1_PESSOA == "J" .and. !Empty(M->A1_CGC) .and. SA1->(FieldPos("A1_XTPVCTO")) > 0
	lRet := D_MA030TOK()
endif

//———————————————————————————————————————————————————————————————————————————————
// Valida informações referentes a avaliação de crédito para grupo de cliente, 
// obrigando a manter a mesma informação das outras lojas.
// Por Adalberto Moreno Batista em 10/02/21
//———————————————————————————————————————————————————————————————————————————————
if lRet .and. M->A1_EST != "EX" .and. M->A1_PESSOA == "J" .and. !Empty(M->A1_CGC) .and. nModulo == 6
	lRet := E_MA030TOK()
endif

RestArea(aAreaAtu)	
return(lRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		A_MA030TOK                                                   /@
@type			Static Function                                              /@
@date			23/06/2010                                                   /@
@description	Valida CNPJ para clientes nacionais e estrangeiros: Para 
				Nacionais será obrigatorio o preenchimento do campo CNPJ e 
				para Estrangeiros será obrigatorio deixar o campo CNPJ em 
				branco                                                       /@
@author			Luiz Fernando                                                /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function A_MA030TOK()
Local lRet 		:= .T.
Local cCgc     := allTrim(M->A1_CGC)
Local cEstado  := allTrim(M->A1_EST)

//———————————————————————————————————————————————————————————————————————————————
// Verifica se o Estado é diferente de "EX" (ESTRANGEIRO) e o CGC for igual a 
// Branco nao deixa prosseguir³
//———————————————————————————————————————————————————————————————————————————————
If cEstado <> 'EX'
	if Empty(cCgc)
		lRet := .F.
		Help(" ", 1, "ATENÇÃO",, "O campo CNPJ/CPF é de preenchimento obrigatório para clientes nacionais." + chr(13) + chr(10) + "(Específico " + AllTrim(SM0->M0_NOME) + ") - MA030TOK", 1)
	else
		if INCLUI
			SA1->(dbSetOrder(3))
			if SA1->(dbSeek(xFilial("SA1") + cCGC))
				lRet := .F.
				Help(" ", 1, "ATENÇÃO",, "Este CNPJ/CPF já foi incluido no sistema." + chr(13) + chr(10) + "(Específico " + AllTrim(SM0->M0_NOME) + ") - MA030TOK", 1)
			endif
		endif
	endif 

//———————————————————————————————————————————————————————————————————————————————
// Verifica se o Estado é igual a "EX" (ESTRANGEIRO) e o CGC não for igual a 
// Branco nao deixa prosseguir
//———————————————————————————————————————————————————————————————————————————————
ElseIf cEstado== 'EX' .and. cCgc <> ''
	lRet := .F.
	Help(" ", 1, "ATENÇÃO",, "O campo CNPJ não deve ser preenchido para clientes estrangeiros (UF = EX)." + chr(13) + chr(10) + "(Específico " + AllTrim(SM0->M0_NOME) + ") - MA030TOK", 1)
endif

Return(lRet)	

/*/
———————————————————————————————————————————————————————————————————————————————
@function		B_MA030TOK                                                   /@
@type			Static Function                                              /@
@date			                                                             /@
@description	Verifica carga media se cliente é do MT.
				preenchimento dos campos RG.SIMP.MT e P.CARGA MED            /@
@author			Luiz Fernando                                                /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
Static Function B_MA030TOK()
Local lRet 		:= .T.
Local nPercMt	:= M->A1_PERCATM		
Local cRegMt   := M->A1_REGESIM		

If cRegMt == '' .and. nPercMt == 0
	lRet := .F.
	//ALERT("Para cadastros de clientes no estado do Mato Grosso o campo (Rg. Simp. MT) tem que estar preenchido como SIM na aba Fiscais")
	Help(" ", 1, "ATENÇÃO",, "Para cadastros de clientes no estado do Mato Grosso o campo (Rg. Simp. MT) tem que estar preenchido como SIM na aba Fiscais." + chr(13) + chr(10) + "(Específico " + AllTrim(SM0->M0_NOME) + ") - MA030TOK", 1)
ElseIf	cRegMt <> '1' 
	lRet := .F.
	//ALERT("Para cadastros de clientes no estado do Mato Grosso o campo (Rg. Simp. MT) tem que estar preenchido como SIM na aba Fiscais")
	Help(" ", 1, "ATENÇÃO",, "Para cadastros de clientes no estado do Mato Grosso o campo (Rg. Simp. MT) tem que estar preenchido como SIM na aba Fiscais." + chr(13) + chr(10) + "(Específico " + AllTrim(SM0->M0_NOME) + ") - MA030TOK", 1)
Elseif	cRegMt == '1' .and. !cValToChar(nPercMt) == "7" .and. !cValToChar(nPercMt)== "10" .and. !cValToChar(nPercMt) == "13" .and. !cValToChar(nPercMt) == "15" .and. !cValToChar(nPercMt) == "16" .and. !cValToChar(nPercMt) == "17" .and. !cValToChar(nPercMt) == "18" .and. !cValToChar(nPercMt) == "19" .and. !cValToChar(nPercMt) == "20" 
	lRet := .F.
	//ALERT("Percentual de Carga Média de Mato Grosso deve ser 7%, 13%, 15%, 16%, 19% ou 20%")
	Help(" ", 1, "ATENÇÃO",, "Percentual de Carga Média de Mato Grosso deve ser 7%, 10%, 13%, 15%, 16%, 17, 18%, 19% ou 20%." + chr(13) + chr(10) + "(Específico " + AllTrim(SM0->M0_NOME) + ") - MA030TOK", 1)
Endif
         
Return(lRet)
*/

/*/
———————————————————————————————————————————————————————————————————————————————
@function		C_MA030TOK                                                   /@
@type			Static Function                                              /@
@date			                                                             /@
@description	Verifica se o campo A1_XCADCLI está preenchido corretamente:
				se não houver outra loja cadastrada do mesmo cloiente o campo
				deve ser preenchido com 1 = Sim. Não pode permitir mais do 
				que um cadastro do mesmo grupo com o campo igual a 1 = Sim.  /@
@author			Luiz Fernando                                                /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function C_MA030TOK()
Local lRet 		:= .T.
Local lExist	:= .F.
Local cCod		:= allTrim(M->A1_COD)
lOCAL cCadCli	:= M->A1_XCADCLI

SA1->(dbSetOrder(1))
if SA1->(dbSeek(xFilial("SA1") + substring(allTrim(cCOD),1,8)))
	do while SA1->A1_COD == cCod                        
	
		if cCadCli == "1" .and. SA1->A1_XCADCLI == "1" .and. SA1->(A1_COD+A1_LOJA) != M->(A1_COD+A1_LOJA)
			lRet := .F.
			Help(" ", 1, "ATENÇÃO",, "O campo Cadastro Principal, na Aba 'Vendas', não pode ser preenchido como 'Sim' pois já existe outra filial " +; 
			"deste cliente cadastrada como Principal:"+ SA1->(A1_COD+"-"+A1_LOJA)+ chr(13) + chr(10) + "(Específico " + AllTrim(SM0->M0_NOME) + ") - MA030TOK", 1)
		endif 
		if SA1->A1_XCADCLI == "1" .and. SA1->(A1_COD+A1_LOJA) != M->(A1_COD+A1_LOJA)
			lExist := .T.
		endif
		SA1->(dbSkip())
	enddo
	if cCadCli != "1"  .and. !lExist
		lRet := .F.
		Help(" ", 1, "ATENÇÃO",, "O campo Cadastro Principal, na Aba 'Vendas', não pode ser preenchido como 'Não' pois já existem outras filiais " +; 
		"do cliente cadastradas e nenhuma está sinalizada como Principal."+ chr(13) + chr(10) + "(Específico " + AllTrim(SM0->M0_NOME) + ") - MA030TOK", 1)
	endif
else 
	if cCadCli != "1"
		lRet := .F.
		Help(" ", 1, "ATENÇÃO",, "O campo Cadastro Principal, na Aba 'Vendas', não pode ser preenchido como 'Não' para primeiro cadastro da filial " +; 
		"do cliente."+ chr(13) + chr(10) + "(Específico " + AllTrim(SM0->M0_NOME) + ") - MA030TOK", 1)
	endif
endif

Return(lRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		D_MA030TOK                                                   /@
@type			Static Function                                              /@
@date			18/01/2021                                                   /@
@description	Acionada pela user function MA030TOK.
				Valida informação referente ao campo Tipo Vencimento 
				(A1_XTPVCTO), para grupo de cliente, obrigando a manter a 
				mesma informação das outras filiais.                         /@
@author			Adalberto Moreno Batista                                     /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function D_MA030TOK()
Local lRet			:= .T.
Local aAreaSA1		:= SA1->(GetArea())
Local cTpVencto		:= M->A1_XTPVCTO
Local cCNPJ			:= M->A1_CGC
Local aTpVcto     := {"1-Faturamento", "2-Entrega"}
Local cVctAtual


SA1->(dbSetOrder(3))		//A1_FILIAL, A1_CGC
SA1->(dbSeek(xFilial("SA1") + Left(cCNPJ,8)))
do While SA1->(!eof() .and. A1_FILIAL == xFilial("SA1") .and. Left(A1_CGC, 8) == Left(cCNPJ, 8))
	if SA1->A1_PESSOA == "J"
		if SA1->A1_XTPVCTO != cTpVencto .and. SA1->A1_COD + SA1->A1_LOJA != M->A1_COD + M->A1_LOJA
			cVctAtual   := iif(SA1->A1_XTPVCTO $ "1/2", aTpVcto[Val(SA1->A1_XTPVCTO)], "Nao Identificado")
			lRet := .F.
			Help(" ", 1, "ATENÇÃO",, "O campo Tipo Vencto, na Aba 'Cadastrais', deste cliente deve estar configurado como '" + cVctAtual + "', assim como os outros cadastros de clientes do mesmo grupo corporativo." + chr(13) + chr(10) + "(Específico " + AllTrim(SM0->M0_NOME) + ") - MA030TOK", 1)
			Exit
		endif
	endif
	SA1->(dbSkip())
enddo

RestArea(aAreaSA1)
Return(lRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		E_MA030TOK                                                   /@
@type			Static Function                                              /@
@date			10/02/2021                                                   /@
@description	Acionada pela user function MA030TOK.
				Valida informações referentes a avaliação de crédito para 
				grupo de cliente, obrigando a manter a mesma informação das
				outras lojas.                                                /@
@author			Adalberto Moreno Batista                                     /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function E_MA030TOK()
Local lRet			:= .T.
Local aAreaSA1		:= SA1->(GetArea())
Local cCNPJ			:= M->A1_CGC
Local cRisco		:= M->A1_RISCO
Local nLC			:= M->A1_LC
Local dVencLC		:= M->A1_VENCLC
Local nMoedaLC		:= M->A1_MOEDALC

SA1->(dbSetOrder(3))		//A1_FILIAL, A1_CGC
SA1->(dbSeek(xFilial("SA1") + Left(cCNPJ,8)))
do While SA1->(!eof() .and. A1_FILIAL == xFilial("SA1") .and. Left(A1_CGC, 8) == Left(cCNPJ, 8))
	if SA1->A1_PESSOA == "J" .and. SA1->A1_COD + SA1->A1_LOJA != M->A1_COD + M->A1_LOJA .and.;
		(SA1->A1_RISCO != cRisco .or. SA1->A1_LC != nLC .or. SA1->A1_VENCLC != dVencLC .or. SA1->A1_MOEDALC != nMoedaLC)

			lRet := .F.
			Help(" ", 1, "ATENÇÃO",, "Os campos Risco, Lim Credito, Venc Lim Cred e Moeda do LC, na Aba 'Adm.Fin.', devem estar configurados respectivamente como 'Risco " + cRisco + "', '" + AllTrim(Transf(nLC,"@E 999,999,999.99")) + "', '" + dTOc(dVencLC) + "' e '" + AllTrim(Str(nMoedaLC)) + "', de acordo com os outros registros do mesmo grupo de clientes." + chr(13) + chr(10) + "(Específico " + AllTrim(SM0->M0_NOME) + ") - MA030TOK", 1)
			Exit
	endif

	SA1->(dbSkip())

enddo

RestArea(aAreaSA1)
Return(lRet)
