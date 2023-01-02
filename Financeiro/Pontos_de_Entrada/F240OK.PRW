#include "protheus.ch"
#include "totvs.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		F240OK                                                       /@
@type			Ponto de entrada                                             /@
@date			12/07/2022                                                   /@
@description	Faz um controle de cancelamento de borderô permitindo ou não
                cancela-lo.                                                  /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
                Opção Um Tecnologia da Informação (www.opcaoum.com.br)       /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function F240OK()
Local lRet      := .T.
Local aArea     := GetArea()
Local aAreaSE2  := SE2->(GetArea())
Local aAreaSEA  := SEA->(GetArea())
Local cLoja, cChave

//———————————————————————————————————————————————————————————————————————————————
// Permito o cancelamento do borderô, se os titulos estiverem liberados, E2_XCNAB
// não preenchidos. Isto ocorrerá quando o borderô não tiver criado arquivo
// CNAB ou houver retorno do banco.
//———————————————————————————————————————————————————————————————————————————————
if SE2->(FieldPos("E2_XCNAB")) > 0 .and. SEA->EA_TRANSF=="S"
    SE2->(dbSetOrder(1))
    do while SEA->(!Eof() .and. EA_FILIAL==xFilial("SEA") .and. EA_NUMBOR==mv_par01 .and. EA_CART=="P")

        cLoja   := iif(Empty(SEA->EA_LOJA), "", SEA->EA_LOJA)               
        //Borderos gerados em versao anterior
        //if Empty(SEA->EA_FILORIG)
        //    cChave := xFilial("SE2") + SEA->EA_PREFIXO + SEA->EA_NUM + SEA->EA_PARCELA + SEA->EA_TIPO + SEA->EA_FORNECE + cLoja
        //else //Borderos gerados a partir da versao 7.10
        cChave  := xFilial("SE2", SEA->EA_FILORIG) + SEA->EA_PREFIXO + SEA->EA_NUM + SEA->EA_PARCELA + SEA->EA_TIPO + SEA->EA_FORNECE + cLoja
        //endif
                
        if SE2->(MsSeek(cChave)) .and. !Empty(SE2->E2_XCNAB)
            lRet := .F.
            Exit
        endif

        SEA->(dbSkip())
    enddo
endif

if !lRet
    Help(,, "ATENÇÃO",, "Este borderô não poderá ser cancelado pois há um ou mais títulos com pendencia de retorno bancário." + chr(13) + chr(10) + "F240OK (Específico " + AllTrim(SM0->M0_NOME) + ")", 1)
endif

RestArea(aAreaSE2)
RestArea(aAreaSEA)
RestArea(aArea)
Return(lRet)
