#include 'protheus.ch'
#include 'parmtype.ch'

user function MA020ALT()
 	Local lExecuta := .T.
	IF XFILIAL("SA2")=='01' .AND. LEN(ALLTRIM(M->A2_COND))==0
	   lExecuta := .F.
      alert( "Nao ? permitido cadastro de fornecedor sem condi??o de pagamento para esta Filial. " )
	ENDIF
return(lExecuta)