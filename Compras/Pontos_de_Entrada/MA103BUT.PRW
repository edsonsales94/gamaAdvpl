#include "protheus.ch"     
#include "rwmake.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		MA103BUT                                                     /@
@type			Ponto de entrada                                             /@
@date			10/05/2021                                                   /@
@description	Adiciona fun鈬o no menu (aRotina) em documento de entrada    /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Op鈬o Um Tecnologia da Informa鈬o                            /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function MA103BUT()
Local aBotoes 			:= {}
Local cDirAnexos		:= GetMV("BR_ANEXOPC")
Local cAno				:= StrZero(Year(dDEmissao), 4)
Local cMes				:= StrZero(Month(dDEmissao), 2)
Private cNumControle    := AllTrim(cNFiscal) + "_" + AllTrim(cSerie) + "_" + AllTrim(cA100For) + "_" + AllTrim(cLoja)

MakeDir(cDirAnexos)
MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt)
MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt + "\PC")
MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt + "\PC\temp")
MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt + "\PC\" + cAno)
MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt + "\PC\" + cAno + "\mes_" + cMes)

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Adiciona item no aRotina para funcionalidade de vincula鈬o de arquivos ? uma 
// nota fiscal. Os arquivos ser縊 gravados em diretorio dentro do rootpath.
// Por: Adalberto Moreno Batista (Op鈬o Um) em 15/05/2021
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
//aAdd(aBotoes, {"CONTAINR", {|| U_GenAttach(AllTrim(cNFiscal) + "_" + AllTrim(cSerie) + "_" + AllTrim(cA100For) + "_" + AllTrim(cLoja), "CP", INCLUI, {cAno, cMes})}, "ｮ Anexos"})
aAdd(aBotoes, {"CONTAINR", {|| U_GetAttachs, INCLUI, {cAno, cMes}}, "ｮ Anexos"})

Return(aBotoes)
