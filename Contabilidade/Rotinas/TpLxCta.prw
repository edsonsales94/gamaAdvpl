#include "protheus.ch"
/*/
=============================================================================
{Protheus.doc} TpLxCta   
Verifica o tipo do lançamento (D,C e Partida Dobrada) e critica a digitação 
da conta contábil 

@description
Critica a digitação da conta contábil conforme o tipo do lançamento   

@author Cosme Nunes
@since 10/09/2020
@type User Function

@table 
    CT2 - Lançamento Contábil

@param
    Não se aplica

@return
    _lRet - T=Ok / F=Não permitido

@menu
    Não se aplica

@history 
    10/09/2020 - Confecção - Cosme Nunes
/*/   

User Function TpLxCta()

Local cVar  := READVAR() // Obtém o nome da variável
//Local cCont := &(READVAR()) // Obtém o conteúdo da variável
Local lRet  := .F.
Local _cCta := ""

If Alltrim(Upper(FunName()))=="CTBA102"

    //If cVar $ "M->CT2_DEBITO_CDEBITO" .And. (CT2_DC == "1" .Or. CT2_DC == "3")
    If cVar $ "M->CT2_DEBITO" .And. (CT2_DC == "1" .Or. CT2_DC == "3")
            lRet := .T.

    //ElseIf cVar $ "M->CT2_CREDIT_CCREDIT" .And. (CT2_DC == "2" .Or. CT2_DC == "3")
    ElseIf cVar $ "M->CT2_CREDIT" .And. (CT2_DC == "2" .Or. CT2_DC == "3")
            lRet := .T.

    Else
            //MsgAlert("Campo: " + cVar + " / Conteudo: " + cCont + " nao pode ser preenchido." )
            If  cVar $ "M->CT2_DEBITO" .And. !(CT2_DC == "1" .Or. CT2_DC == "3")
                _cCta := "debito"
            EndIf
            If cVar $ "M->CT2_CREDIT" .And. !(CT2_DC == "2" .Or. CT2_DC == "3")
                _cCta := "credito"
            EndIf
            MsgAlert("Conta " + _cCta + " permitida apenas para lancamento de "+ _cCta +" ou partida dobrada.")
            
    EndIf

Else

    lRet := .T.

EndIf

Return(lRet)
