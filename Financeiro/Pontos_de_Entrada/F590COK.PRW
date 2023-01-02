#include "protheus.ch"
#include "totvs.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		F590COK                                                      /@
@type			Ponto de entrada                                             /@
@date			18/07/2022                                                   /@
@description	Manutenção de borderô, Ponto de entrada que valida o 
                cancelamento/retirada de um determinado título de um borderô /@
@parameters     cTipo   - Define se será bordero "P" Carteira a pagar ou
                        - "R" - Carteira a Receber.
                cNumBor	- Número do borderô selecionado.                     /@
@return         .T. / .F.
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
                Opção Um Tecnologia da Informação (www.opcaoum.com.br)       /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function F590COK()
Local lRet      := .T.
Local aParam    := PARAMIXB
Local cUserPerm := AllTrim(GetMV("BR_USRPERM", .F., "Deivison Cocuzza"))

//———————————————————————————————————————————————————————————————————————————————
// Se borderô a pagar e tiver gerado arquivo CNAB, não permito cancelar o título,
// a não ser que se trate de um usuário/senha autorizado
//———————————————————————————————————————————————————————————————————————————————
if SE2->(FieldPos("E2_XCNAB"))>0 .and. FunName()!="FINA430"
    if !Upper(cUserName) $ Upper(cUserPerm)
        if aParam[1]=="P" .and. SEA->EA_TRANSF=="S" .and. !Empty(SE2->E2_XCNAB)
            lRet    := .F.
            Help(,, "ATENÇÃO",, "Não é possível cancelar este título, pois ainda não houve retorno do banco." + chr(13) + chr(10) + "F590COK (Específico " + AllTrim(SM0->M0_NOME) + ")", 1)
        endif
    else
        Help(,, "ATENÇÃO",, "Título não possui retorno do banco, porém o usuário/senha é autorizado a realizar o proccesso." + chr(13) + chr(10) + "F590COK (Específico " + AllTrim(SM0->M0_NOME) + ")", 1)
    endif
endif

Return(lRet)
