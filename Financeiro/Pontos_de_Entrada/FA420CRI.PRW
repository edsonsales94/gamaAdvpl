#include "protheus.ch"
#include "totvs.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		FA420CRI                                                     /@
@type			Ponto de entrada                                             /@
@date			18/07/2022                                                   /@
@description	Trata da utilização ou não do borderô enviado anteriormente
                na geração do arquivo bancário.
                (Rotina FINA420)
                Retorno: .T./.F.                                             /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
                Opção Um Tecnologia da Informação (www.opcaoum.com.br)       /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function FA420CRI()
Local lRet      := .T.

//———————————————————————————————————————————————————————————————————————————————
// Não permitir gerar arquivo texto CNAB, caso já tenha sido gerado (somente se
// houver tratamento de CNAB existencia do campo E2_XCNAB)
//———————————————————————————————————————————————————————————————————————————————
if SE2->(FieldPos("E2_XCNAB")) > 0 .and. SEA->EA_TRANSF=="S"
    lRet := .F.
    Help(,, "ATENÇÃO",, "Borderô já gerou arquivo CNAB. Não é possível gerá-lo novamente." + chr(13) + chr(10) + "F420CHK (Específico " + AllTrim(SM0->M0_NOME) + ")", 1)
endif

Return(lRet)
