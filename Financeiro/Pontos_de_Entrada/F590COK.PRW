#include "protheus.ch"
#include "totvs.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		F590COK                                                      /@
@type			Ponto de entrada                                             /@
@date			18/07/2022                                                   /@
@description	Manuten鈬o de border?, Ponto de entrada que valida o 
                cancelamento/retirada de um determinado t?tulo de um border? /@
@parameters     cTipo   - Define se ser? bordero "P" Carteira a pagar ou
                        - "R" - Carteira a Receber.
                cNumBor	- N?mero do border? selecionado.                     /@
@return         .T. / .F.
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
                Op鈬o Um Tecnologia da Informa鈬o (www.opcaoum.com.br)       /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function F590COK()
Local lRet      := .T.
Local aParam    := PARAMIXB
Local cUserPerm := AllTrim(GetMV("BR_USRPERM", .F., "Deivison Cocuzza"))

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Se border? a pagar e tiver gerado arquivo CNAB, n縊 permito cancelar o t?tulo,
// a n縊 ser que se trate de um usu疵io/senha autorizado
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if SE2->(FieldPos("E2_XCNAB"))>0 .and. FunName()!="FINA430"
    if !Upper(cUserName) $ Upper(cUserPerm)
        if aParam[1]=="P" .and. SEA->EA_TRANSF=="S" .and. !Empty(SE2->E2_XCNAB)
            lRet    := .F.
            Help(,, "ATENﾇﾃO",, "N縊 ? poss?vel cancelar este t?tulo, pois ainda n縊 houve retorno do banco." + chr(13) + chr(10) + "F590COK (Espec?fico " + AllTrim(SM0->M0_NOME) + ")", 1)
        endif
    else
        Help(,, "ATENﾇﾃO",, "T?tulo n縊 possui retorno do banco, por駑 o usu疵io/senha ? autorizado a realizar o proccesso." + chr(13) + chr(10) + "F590COK (Espec?fico " + AllTrim(SM0->M0_NOME) + ")", 1)
    endif
endif

Return(lRet)
