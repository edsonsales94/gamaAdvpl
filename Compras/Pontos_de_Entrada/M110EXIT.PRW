#include "rwmake.ch"
#include "protheus.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		M110EXIT                                                     /@
@date			09/10/2020                                                   /@
@type			Ponto de entrada
@description	Executado ao abandonar a tela da solicita鈬o de compras.     /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Op鈬o Um Tecnologia da Informa鈬o                            /@
@use			DKT do Brasil                                                /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function M110EXIT()
Local lRet          := .T.
Local cDirAnexos	:= GetMV("BR_ANEXOPC")
Local cPathTemp		:= cDirAnexos + "\" + cEmpAnt + cFilAnt + "\SC\temp\"
Local nX, aFiles

MakeDir(cDirAnexos)
MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt)
MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt + "\SC")
MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt + "\SC\temp")

aFiles	:= Directory(cPathTemp + cFilAnt + "_" + AllTrim(cA110Num) + "_" + "*.*")

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Exclus縊 dos anexos da solicita鈬o de compras
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if Len(aFiles) > 0
	for nX := 1 to Len(aFiles)
		fErase(cPathTemp + aFiles[nX,1])
	next
endif

Return(lRet)
