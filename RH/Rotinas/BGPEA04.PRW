#include "protheus.ch"
#include "rwmake.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		BGPEA04                                                       /@
@date				03/07/2017                                                    /@
@description	Manutenção dos movimentos Zetra                               /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Opção Um Consultoria                                          /@
@use			   Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function BGPEA04()
Local aAreaSX2		:= SX2->(GetArea())
Local lContinua

SX3->(dbSetOrder(1))
lContinua := SX3->(dbSeek("ZZ4"))
RestArea(aAreaSX2)

if lContinua

	AxCadastro("ZZ4", "Movimentos Zetra", "U_ExcMovZetra()", "U_AltMovZetra()")

else

	Help(" ", 1, "ATENÇÃO", , "Esta empresa não possui configuração para integração com a Zetra." + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Brasitech)", 1)

endif

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		ExcMovZetra                                                   /@
@date				27/09/2013                                                    /@
@description	Não permite a exclusão de um movimento.                       /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Opção Um Consultoria                                          /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function ExcMovZetra()

Help(" ", 1, "ATENÇÃO",, "Não é permitido exclusão de movimentos da Zetra." + Chr(13) + Chr(10) + Chr(13) + Chr(10) + "(Específico Brasitech)", 1)

Return(.F.)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		AltMovZetra                                                   /@
@date				27/09/2013                                                    /@
@description	Permite alterar somente registros movimentos do mês do 
					fechamento da folha.                                          /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Opção Um Consultoria                                          /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function AltMovZetra()
Local lRet		:= .T.
Local cDParFol	:= AllTrim(GetMV("MV_FOLMES"))
Local cDtFolha := Right(cDParFol,2) + Left(cDParFol,4)		//Formato MMAAAA

if ZZ4->ZZ4_PERIOD != cDtFolha
	lRet	:= .F.
	Help(" ", 1, "ATENÇÃO",, "Não é permitida a alteração em registros cujo período seja diferente da data de fechamento da folha." + Chr(13) + Chr(10) + Chr(13) + Chr(10) + "(Específico Brasitech)", 1)
endif

Return(lRet)
