#include "protheus.ch"
#include "totvs.ch"

/*/
�������������������������������������������������������������������������������
@function		FA420CRI                                                     /@
@type			Ponto de entrada                                             /@
@date			18/07/2022                                                   /@
@description	Trata da utiliza��o ou n�o do border� enviado anteriormente
                na gera��o do arquivo banc�rio.
                (Rotina FINA420)
                Retorno: .T./.F.                                             /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
                Op��o Um Tecnologia da Informa��o (www.opcaoum.com.br)       /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
/*/
User Function FA420CRI()
Local lRet      := .T.

//�������������������������������������������������������������������������������
// N�o permitir gerar arquivo texto CNAB, caso j� tenha sido gerado (somente se
// houver tratamento de CNAB existencia do campo E2_XCNAB)
//�������������������������������������������������������������������������������
if SE2->(FieldPos("E2_XCNAB")) > 0 .and. SEA->EA_TRANSF=="S"
    lRet := .F.
    Help(,, "ATEN��O",, "Border� j� gerou arquivo CNAB. N�o � poss�vel ger�-lo novamente." + chr(13) + chr(10) + "F420CHK (Espec�fico " + AllTrim(SM0->M0_NOME) + ")", 1)
endif

Return(lRet)