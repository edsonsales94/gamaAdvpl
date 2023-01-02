#include "protheus.ch"     
#include "rwmake.ch"

/*/
�������������������������������������������������������������������������������
@function		MA103BUT                                                     /@
@type			Ponto de entrada                                             /@
@date			10/05/2021                                                   /@
@description	Adiciona fun��o no menu (aRotina) em documento de entrada    /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Op��o Um Tecnologia da Informa��o                            /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
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

//�������������������������������������������������������������������������������
// Adiciona item no aRotina para funcionalidade de vincula��o de arquivos � uma 
// nota fiscal. Os arquivos ser�o gravados em diretorio dentro do rootpath.
// Por: Adalberto Moreno Batista (Op��o Um) em 15/05/2021
//�������������������������������������������������������������������������������
//aAdd(aBotoes, {"CONTAINR", {|| U_GenAttach(AllTrim(cNFiscal) + "_" + AllTrim(cSerie) + "_" + AllTrim(cA100For) + "_" + AllTrim(cLoja), "CP", INCLUI, {cAno, cMes})}, "� Anexos"})
aAdd(aBotoes, {"CONTAINR", {|| U_GetAttachs, INCLUI, {cAno, cMes}}, "� Anexos"})

Return(aBotoes)