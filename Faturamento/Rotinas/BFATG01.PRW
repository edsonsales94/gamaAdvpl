#include "protheus.ch"
#include "rwmake.ch"

/*/

———————————————————————————————————————————————————————————————————————————————
@function		BFATG01                                                      /@
@date			30/06/2014                                                   /@
@type			Gatilho                                                      /@
@description	User function, gatilho para preenchimento automático de 
				codigo e loja de clientes                                    /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————

/*/
User Function BFATG01(cVar)
Local aArea		:= GetArea()
Local aAreaSA1	:= SA1->(GetArea())
Local lContinua

if INCLUI

	SA1->(dbSetOrder(1))

	if M->A1_PESSOA == "F"
	
		M->A1_TIPO := "F"
		GeraCodCli()
		
	else
	
		if M->A1_TIPO == "X"
	
			M->A1_EST := "EX"
			M->A1_COD_MUN := "99999"
			M->A1_MUN := "ESTRANGEIRO"
			GeraCodCli()
			
		else
		   
			if !empty(M->A1_CGC)
				GeraLojaCli()
			endif
			
		endif
	
	endif

	M->A1_XCODGRU 	:= M->A1_COD
	M->A1_XLOJGRU 	:= M->A1_LOJA

endif

RestArea(aAreaSA1)
RestArea(aArea)
Return(cVar)


/*/

———————————————————————————————————————————————————————————————————————————————
@function		GeraCodCli                                                   /@
@date			30/06/2014                                                   /@
@type			Static Function                                              /@
@description	User function chamada na função BFATG01. Cria código de 
				cliente sequencial para exportação e pessoas físicas.        /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————

/*/
Static Function GeraCodCli()
Local cNovoCod	:= 	Space(Len(M->A1_COD))
Local cParteCod := 	iif(M->A1_PESSOA=="F", "A", "X")
Local cQuery

cQuery 	:= "SELECT MAX(SUBSTRING(A1_COD,1,7)) CODIGOCLI FROM " + RetSQLName("SA1") + " SA1 "
cQuery 	+= "WHERE A1_FILIAL = '" + xFilial("SA1") + "' "
cQuery 	+=       "AND SUBSTRING(A1_COD,8,1) = 'X' "
cQuery 	+=       "AND SA1.D_E_L_E_T_=''"

if cParteCod == "X"

	if Select("CODCLI") > 0
		CODCLI->(dbCloseArea())
	endif
	
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,ChangeQuery(cQuery)), "CODCLI", .F., .T.)
	
	dbSelectArea("CODCLI")
	if !eof()
		M->A1_COD		:= Soma1(CODCLI->CODIGOCLI) + "X"
		M->A1_LOJA		:= "01"
		M->A1_CGC		:= Space(14)
	endif

	if Select("CODCLI") > 0
		CODCLI->(dbCloseArea())
	endif

	
elseif !Empty(M->A1_CGC)
		
	do while SA1->(dbSeek(xFilial("SA1") + Left(M->A1_CGC,7) + cParteCod))
		cParteCod := Soma1(cParteCod)
		if cParteCod == "X"
			cParteCod := Soma1(cParteCod)
		endif
	enddo
	M->A1_COD		:= Left(M->A1_CGC,7) + cParteCod
	M->A1_LOJA		:= "01" 
			
endif

Return()


/*/

———————————————————————————————————————————————————————————————————————————————
@function		GeraLojaCli                                                  /@
@date			30/06/2014                                                   /@
@type			Static Function                                              /@
@description	User function chamada na função BFATG01. Cria loja de 
				cliente sequencial para clientes diferente de pessoas fisicas
				e juridicas exportação.                                      /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————

/*/
Static Function GeraLojaCli()
Local cLojaBase	:= 	"A1"
Local cNovoCod	:= 	Space(Len(M->A1_COD))
Local cParteCod := 	iif(M->A1_PESSOA="F", "F", "X")
Local cQuery

cQuery	:= "SELECT MAX(A1_LOJA) LOJACLI FROM " + RetSQLName("SA1") + " SA1 "
cQuery	+= "WHERE A1_FILIAL = '" + xFilial("SA1") + "' "
cQuery	+=       "AND A1_COD = '" + Left(M->A1_CGC,8) + "' "
cQuery	+=       "AND SA1.D_E_L_E_T_=''"

if Select("CODCLI") > 0
	CODCLI->(dbCloseArea())
endif

dbUseArea( .T., "TOPCONN", TCGENQRY(,,ChangeQuery(cQuery)), "CODCLI", .F., .T.)

dbSelectArea("CODCLI")
if !eof()

	M->A1_COD	:= Left(M->A1_CGC,8)
	if Val(Substr(M->A1_CGC,9,4)) < 100 .and. !SA1->(dbSeek(xFilial("SA1") + Left(M->A1_CGC,8) + Substr(M->A1_CGC,11,2)))
		M->A1_LOJA	:= Substr(M->A1_CGC,11,2)
		
	elseif CODCLI->LOJACLI > cLojaBase
		cLojaBase	:= Soma1(CODCLI->LOJACLI)
		do while SA1->(dbSeek(xFilial("SA1") + Left(M->A1_CGC,8) + cLojaBase))
			cLojaBase := Soma1(cLojaBase)
		enddo
		M->A1_LOJA	:= cLojaBase
		
	else

		do while SA1->(dbSeek(xFilial("SA1") + Left(M->A1_CGC,8) + cLojaBase))
			cLojaBase := Soma1(cLojaBase)
		enddo
		M->A1_LOJA	:= cLojaBase

	endif
	
endif
if Select("CODCLI") > 0
	CODCLI->(dbCloseArea())
endif

Return()
