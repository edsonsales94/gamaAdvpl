#Include "protheus.ch"     
#include "rwmake.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		MA020TDOK                                                     /@
@type				Ponto de entrada                                              /@
@date				23/06/2010                                                    /@
@description	Valida informações na inclusão ou alteração do cadastro de 
					fornecedores.                                                 /@
@author			Luiz Fernando                                                 /@
@use				Especifico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MA020TDOK() 
Local lRet 		:= .T.
Local lIRRF		


//———————————————————————————————————————————————————————————————————————————————
// Valida o preenchimento do CNPJ do fornecedor, verificando se é um fornecedor 
// interno, obrigando ter o CNPJ ou de importação obrigando não preencher o CNPJ
// Por: Luiz Fernando em 23/06/2010
//———————————————————————————————————————————————————————————————————————————————
if M->A2_EST <> 'EX' .and. Empty(M->A2_CGC)
	Help(,, "ATENÇÃO",, "O preenchimento do CNPJ/CPF é obrigatório." + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Brasitech)", 1)
	lRet := .F.
elseif M->A2_EST == 'EX' .and. !Empty(M->A2_CGC)
	Help(,, "ATENÇÃO",, "Para cadastro de fornecedores estrangeiros, o CNPJ não deve ser preenchido." + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Brasitech)", 1)
	lRet := .F.
endif 
	
//———————————————————————————————————————————————————————————————————————————————
// Valida o preenchimento do código da Receita para o IRRF, de acordo com a 
// natureza padrão informada para o fornecedor.
// Validação realizada somente para as empresas onde o campo especifico 
// A2_X_CDRET existir. 
// Por: Adalberto Moreno Batista em 24/03/2016
//———————————————————————————————————————————————————————————————————————————————
if SA2->(FieldPos("A2_X_CDRET")) > 0 .and. !Empty(M->A2_NATUREZ)
	lIRRF	:= GetAdvFVal("SED","ED_CALCIRF", xFilial("SED") + M->A2_NATUREZ, 1) == "S"
	if empty(M->A2_X_CDRET) .and. lIRRF
		Help(,, "ATENÇÃO",, "A natureza informada para este fornecedor retém Imposto de renda, portanto é obrigatório o preenchimento do código de retenção do imposto junto à Receita Federal." + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Brasitech)", 1)
		lRet := .F.
	elseif !empty(M->A2_X_CDRET) .and. !lIRRF
		Help(,, "ATENÇÃO",, "A natureza informada para este fornecedor não retém Imposto de renda, portanto o código de retenção do imposto junto à Receita Federal não deverá ser preenchido." + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Brasitech)", 1)
		lRet := .F.
	endif
endif

return(lRet)
