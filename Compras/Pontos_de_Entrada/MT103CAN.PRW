#include "rwmake.ch"
#include "protheus.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		MT103CAN                                                     /@
@date			25/04/2017                                                   /@
@type			Ponto de entrada                                             /@
@description	Utilizado para alterar registros SCR, ap?s sua grava鈬o.     /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Op鈬o Um Consultoria                                         /@
@use			Espec?fico Brasitech                                         /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function MT103CAN()
Local cDirAnexos	:= GetMV("BR_ANEXOPC")
Local cPathTemp		:= cDirAnexos + "\" + cEmpAnt + cFilAnt + "\NF\temp\"
Local cNumControle	:= AllTrim(cNFiscal) + "_" + AllTrim(cSerie) + "_" + AllTrim(cA100For) + "_" + AllTrim(cLoja)
Local nX, aFiles

//Excluo os anexos do diretorio TEMP, para efeito de limpeza do ambiente
aFiles		:= Directory( cPathTemp + cFilAnt + "_" + AllTrim(cNumControle) + "_" + "*.*")
if Len(aFiles) > 0
	for nX := 1 to Len(aFiles)
		fErase(cPathTemp + aFiles[nX,1])
	next
endif

Return()
