#include 'protheus.ch'
#include 'parmtype.ch'

User Function MA020TOK()
	Local lExecuta := .T.
	IF XFILIAL("SA2")=='01' .AND. LEN(ALLTRIM(M->A2_COND))==0
	   lExecuta := .F.
      alert( "Nao é permitido cadastro de fornecedor sem condição de pagamento para esta Filial. ")
	ENDIF
Return (lExecuta)