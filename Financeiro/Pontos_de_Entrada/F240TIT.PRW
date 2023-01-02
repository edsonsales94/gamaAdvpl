#include "rwmake.ch"
#include "protheus.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		F240TIT                                                      /@
@date			24/11/2014                                                   /@
@type			Ponto de entrada
@description	Valida a marcação de um título no borderô à pagar. Aguarda o 
				retorno .T. ou .F.                                           /@
@author			Adalberto Moreno Batista (Opção Um Consultoria)              /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function F240TIT()
Local lMarcado		:= !PARAMIXB
Local lRet			:= .T.
Local cEol			:= chr(13) + chr(10)
Local cMvCnpjMtz	:= GetMV("BR_CNPJMTZ", .F., "NULO")	//Inicio a variavel de retorno com o CNPJ da Matriz (regra)
Local cMvCnpjFil	:= GetMV("BR_CNPJFIL", .F., "NULO")	//Armazena os codigos de retencao que obrigam o preenchimento do CNPJ da empresa que estaja realizando o pagamento
Local cMvCnpjFor	:= GetMV("BR_CNPJFOR", .F., "NULO")	//Armazena os codigos de retencao que obrigam o preenchimento do CNPJ do fornecedor para quem será realizado o pagamento

if cEmpAnt $ "01/09"	//Brasitech e Gama Italy

	if lMarcado

		//—————————————————————————————————————————————————————————————————————————
		// Pagamento de boletos
		//—————————————————————————————————————————————————————————————————————————
		if cModPgto $ "30/31" .and. Empty(SE2->E2_CODBAR)
			Help(" ", 1, "ATENÇÃO",, "Para pagamento de boletos, é necessário que o código de barras tenha sido informado. Verifique!" + cEol + cEol + "F240TIT - Específico " + AllTrim(SM0->M0_NOME), 1)
			lRet := .F.
		
		//—————————————————————————————————————————————————————————————————————————
		// Depósito em conta
		//—————————————————————————————————————————————————————————————————————————
		elseif cModPgto $ "01/02/03/05/06/10/41/43" .and. (Empty(SE2->E2_FORBCO) .or. Empty(SE2->E2_FORAGE) .or. Empty(SE2->E2_FORCTA) .or. Empty(SE2->E2_FCTADV))
			Help(" ", 1, "ATENÇÃO",, "Para crédito em conta é necessário que que os campos de banco, agência, conta e DV da conta tenham sido preenchidos. Verifique!" + cEol + cEol + "F240TIT - Específico " + AllTrim(SM0->M0_NOME), 1)
			lRet := .F.
		
		//—————————————————————————————————————————————————————————————————————————
		// Tributo e concessionárias com codigo de barras
		//—————————————————————————————————————————————————————————————————————————
		elseif cModPgto $ "13/19/35/91" .and. Empty(SE2->E2_CODBAR)
			Help(" ", 1, "ATENÇÃO",, "Para pagamento de tributos ou concessionárias, é necessário que o código de barras tenha sido informado. Verifique!" + cEol + cEol + "F240TIT - Específico " + AllTrim(SM0->M0_NOME), 1)
			lRet := .F.
		
			
		//—————————————————————————————————————————————————————————————————————————
		// DARF comum (preto) / GPS / GARE-SP
		//—————————————————————————————————————————————————————————————————————————
		elseif cModPgto $ "16/17/22" .and. (Empty(SE2->E2_CODRET) .or. Empty(SE2->E2_X_PAPU))
			Help(" ", 1, "ATENÇÃO",, "Para pagamento de DARF comum, GPS e GARE-SP, é necessário que o código da receita e período de apuração tenham sido informados. Verifique!" + cEol + cEol + "F240TIT - Específico " + AllTrim(SM0->M0_NOME), 1)
			lRet := .F.
		
		//—————————————————————————————————————————————————————————————————————————
		// DARF simples (verde)
		//—————————————————————————————————————————————————————————————————————————
		elseif cModPgto $ "18" .and. (Empty(SE2->E2_CODRET) .or. Empty(SE2->E2_X_PAPU) .or. Empty(SE2->E2_X_RECAC) .or. Empty(SE2->E2_X_PDARF))
			Help(" ", 1, "ATENÇÃO",, "Para pagamento de DARF simples, é necessário que o código da receita, período de apuração, receita acumulada e % DARF tenham sido informados. Verifique!" + cEol + cEol + "F240TIT - Específico " + AllTrim(SM0->M0_NOME), 1)
			lRet := .F.

		//—————————————————————————————————————————————————————————————————————————
		// Verifico se os parametros BR_CNPJMTZ, BR_CNPJFIL e BR_CNPJFOR foram 
		// configurados
		//—————————————————————————————————————————————————————————————————————————
		elseif cModPgto $ "16/17/18/19/21/22/35/91" .and. (cMvCnpjMtz == "NULO" .or. cMvCnpjFil == "NULO" .or. cMvCnpjFor == "NULO")
			Help(" ", 1, "ATENÇÃO",, "Para pagamento de tributos, é necessário que os parametros BR_CNPJMTZ, BR_CNPJFIL, BR_CNPJFOR estejam devidamente configurados. Solicite configuração destes parâmetros à equipe de TI!" + cEol + cEol + "F240TIT - Específico " + AllTrim(SM0->M0_NOME), 1)
			lRet := .F.

		//—————————————————————————————————————————————————————————————————————————
		// IPVA ou DPVAT
		//—————————————————————————————————————————————————————————————————————————
		elseif cModPgto $ "25/27"
			if SE2->(FieldPos("E2_XEXERC"))>0 .and. SE2->(FieldPos("E2_XRENAV"))>0 .and. SE2->(FieldPos("E2_XUF"))>0 .and. SE2->(FieldPos("E2_XCODMUN"))>0 .and. SE2->(FieldPos("E2_XPLACA"))>0 .and. SE2->(FieldPos("E2_XOPCPGT"))>0
				if Empty(E2_XEXERC) .or. Empty(E2_XRENAV) .or. Empty(E2_XUF) .or. Empty(E2_XCODMUN) .or. Empty(E2_XPLACA) .or. Empty(E2_XOPCPGT)
					Help(" ", 1, "ATENÇÃO",, "Para pagamento de IPVA ou DPVAT, necessário preencher dos campos: Exercicio, RENAVAM, UF Renav, Munic Renav, Placa e Op.Pag Renav." + cEol + cEol + "F240TIT - Específico " + AllTrim(SM0->M0_NOME), 1)
					lRet := .F.
				endif
			else
				Help(" ", 1, "ATENÇÃO",, "Para pagamento de IPVA ou DPVAT, necessário criar os campos 'E2_XEXERC', 'E2_XRENAV', 'E2_XUF', 'E2_XCODMUN', 'E2_XPLACA' e 'E2_XOPCPGT'. Informe ao depto de TI." + cEol + cEol + "F240TIT - Específico " + AllTrim(SM0->M0_NOME), 1)
				lRet := .F.
			endif

		endif
	endif

endif

Return(lRet)
