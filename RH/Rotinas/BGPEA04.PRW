#include "protheus.ch"
#include "rwmake.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		BGPEA04                                                       /@
@date				03/07/2017                                                    /@
@description	Manuten鈬o dos movimentos Zetra                               /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Op鈬o Um Consultoria                                          /@
@use			   Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
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

	Help(" ", 1, "ATENﾇﾃO", , "Esta empresa n縊 possui configura鈬o para integra鈬o com a Zetra." + chr(13) + chr(10) + chr(13) + chr(10) + "(Espec?fico Brasitech)", 1)

endif

Return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		ExcMovZetra                                                   /@
@date				27/09/2013                                                    /@
@description	N縊 permite a exclus縊 de um movimento.                       /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Op鈬o Um Consultoria                                          /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function ExcMovZetra()

Help(" ", 1, "ATENﾇﾃO",, "N縊 ? permitido exclus縊 de movimentos da Zetra." + Chr(13) + Chr(10) + Chr(13) + Chr(10) + "(Espec?fico Brasitech)", 1)

Return(.F.)


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		AltMovZetra                                                   /@
@date				27/09/2013                                                    /@
@description	Permite alterar somente registros movimentos do m黌 do 
					fechamento da folha.                                          /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Op鈬o Um Consultoria                                          /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function AltMovZetra()
Local lRet		:= .T.
Local cDParFol	:= AllTrim(GetMV("MV_FOLMES"))
Local cDtFolha := Right(cDParFol,2) + Left(cDParFol,4)		//Formato MMAAAA

if ZZ4->ZZ4_PERIOD != cDtFolha
	lRet	:= .F.
	Help(" ", 1, "ATENﾇﾃO",, "N縊 ? permitida a altera鈬o em registros cujo per?odo seja diferente da data de fechamento da folha." + Chr(13) + Chr(10) + Chr(13) + Chr(10) + "(Espec?fico Brasitech)", 1)
endif

Return(lRet)
