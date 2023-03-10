#Include "protheus.ch"     
#include "rwmake.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		MA020TDOK                                                     /@
@type				Ponto de entrada                                              /@
@date				23/06/2010                                                    /@
@description	Valida informa鋏es na inclus縊 ou altera鈬o do cadastro de 
					fornecedores.                                                 /@
@author			Luiz Fernando                                                 /@
@use				Especifico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function MA020TDOK() 
Local lRet 		:= .T.
Local lIRRF		


//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Valida o preenchimento do CNPJ do fornecedor, verificando se ? um fornecedor 
// interno, obrigando ter o CNPJ ou de importa鈬o obrigando n縊 preencher o CNPJ
// Por: Luiz Fernando em 23/06/2010
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if M->A2_EST <> 'EX' .and. Empty(M->A2_CGC)
	Help(,, "ATENﾇﾃO",, "O preenchimento do CNPJ/CPF ? obrigat?rio." + chr(13) + chr(10) + chr(13) + chr(10) + "(Espec?fico Brasitech)", 1)
	lRet := .F.
elseif M->A2_EST == 'EX' .and. !Empty(M->A2_CGC)
	Help(,, "ATENﾇﾃO",, "Para cadastro de fornecedores estrangeiros, o CNPJ n縊 deve ser preenchido." + chr(13) + chr(10) + chr(13) + chr(10) + "(Espec?fico Brasitech)", 1)
	lRet := .F.
endif 
	
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Valida o preenchimento do c?digo da Receita para o IRRF, de acordo com a 
// natureza padr縊 informada para o fornecedor.
// Valida鈬o realizada somente para as empresas onde o campo especifico 
// A2_X_CDRET existir. 
// Por: Adalberto Moreno Batista em 24/03/2016
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if SA2->(FieldPos("A2_X_CDRET")) > 0 .and. !Empty(M->A2_NATUREZ)
	lIRRF	:= GetAdvFVal("SED","ED_CALCIRF", xFilial("SED") + M->A2_NATUREZ, 1) == "S"
	if empty(M->A2_X_CDRET) .and. lIRRF
		Help(,, "ATENﾇﾃO",, "A natureza informada para este fornecedor ret駑 Imposto de renda, portanto ? obrigat?rio o preenchimento do c?digo de reten鈬o do imposto junto ? Receita Federal." + chr(13) + chr(10) + chr(13) + chr(10) + "(Espec?fico Brasitech)", 1)
		lRet := .F.
	elseif !empty(M->A2_X_CDRET) .and. !lIRRF
		Help(,, "ATENﾇﾃO",, "A natureza informada para este fornecedor n縊 ret駑 Imposto de renda, portanto o c?digo de reten鈬o do imposto junto ? Receita Federal n縊 dever? ser preenchido." + chr(13) + chr(10) + chr(13) + chr(10) + "(Espec?fico Brasitech)", 1)
		lRet := .F.
	endif
endif

return(lRet)
