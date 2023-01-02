#Include "protheus.ch"     
#include "rwmake.ch"

/*/
�������������������������������������������������������������������������������
@function		MA020TDOK                                                     /@
@type				Ponto de entrada                                              /@
@date				23/06/2010                                                    /@
@description	Valida informa��es na inclus�o ou altera��o do cadastro de 
					fornecedores.                                                 /@
@author			Luiz Fernando                                                 /@
@use				Especifico Brasitech                                          /@
�������������������������������������������������������������������������������
/*/
User Function MA020TDOK() 
Local lRet 		:= .T.
Local lIRRF		


//�������������������������������������������������������������������������������
// Valida o preenchimento do CNPJ do fornecedor, verificando se � um fornecedor 
// interno, obrigando ter o CNPJ ou de importa��o obrigando n�o preencher o CNPJ
// Por: Luiz Fernando em 23/06/2010
//�������������������������������������������������������������������������������
if M->A2_EST <> 'EX' .and. Empty(M->A2_CGC)
	Help(,, "ATEN��O",, "O preenchimento do CNPJ/CPF � obrigat�rio." + chr(13) + chr(10) + chr(13) + chr(10) + "(Espec�fico Brasitech)", 1)
	lRet := .F.
elseif M->A2_EST == 'EX' .and. !Empty(M->A2_CGC)
	Help(,, "ATEN��O",, "Para cadastro de fornecedores estrangeiros, o CNPJ n�o deve ser preenchido." + chr(13) + chr(10) + chr(13) + chr(10) + "(Espec�fico Brasitech)", 1)
	lRet := .F.
endif 
	
//�������������������������������������������������������������������������������
// Valida o preenchimento do c�digo da Receita para o IRRF, de acordo com a 
// natureza padr�o informada para o fornecedor.
// Valida��o realizada somente para as empresas onde o campo especifico 
// A2_X_CDRET existir. 
// Por: Adalberto Moreno Batista em 24/03/2016
//�������������������������������������������������������������������������������
if SA2->(FieldPos("A2_X_CDRET")) > 0 .and. !Empty(M->A2_NATUREZ)
	lIRRF	:= GetAdvFVal("SED","ED_CALCIRF", xFilial("SED") + M->A2_NATUREZ, 1) == "S"
	if empty(M->A2_X_CDRET) .and. lIRRF
		Help(,, "ATEN��O",, "A natureza informada para este fornecedor ret�m Imposto de renda, portanto � obrigat�rio o preenchimento do c�digo de reten��o do imposto junto � Receita Federal." + chr(13) + chr(10) + chr(13) + chr(10) + "(Espec�fico Brasitech)", 1)
		lRet := .F.
	elseif !empty(M->A2_X_CDRET) .and. !lIRRF
		Help(,, "ATEN��O",, "A natureza informada para este fornecedor n�o ret�m Imposto de renda, portanto o c�digo de reten��o do imposto junto � Receita Federal n�o dever� ser preenchido." + chr(13) + chr(10) + chr(13) + chr(10) + "(Espec�fico Brasitech)", 1)
		lRet := .F.
	endif
endif

return(lRet)