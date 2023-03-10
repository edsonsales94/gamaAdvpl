#include "protheus.ch"     
#include "rwmake.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		MA110BUT                                                     /@
@type			Ponto de entrada                                             /@
@date			13/10/2020                                                   /@
@description	Adiciona fun鈬o no menu (aRotina) de solicita鈬o de compras  /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Op鈬o Um Consultoria                                         /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function MA110BUT()
Local aBotoes 			:= {}
Local cDirAnexos		:= GetMV("BR_ANEXOPC")
Local nX, aFiles, cPathTemp, cPathOrig, cAno, cMes
Private cNumControle    := cA110Num

if INCLUI .or. ALTERA
	cAno				:= StrZero(Year(dA110Data), 4)
	cMes				:= StrZero(Month(dA110Data), 2)
else
	cAno				:= StrZero(Year(SC1->C1_EMISSAO), 4)
	cMes				:= StrZero(Month(SC1->C1_EMISSAO), 2)
endif

MakeDir(cDirAnexos)
MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt)
MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt + "\SC")
MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt + "\SC\temp")
MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt + "\SC\" + cAno)
MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt + "\SC\" + cAno + "\mes_" + cMes)

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Gravando os anexos no diretorio temp e definindo o caminho de trabalho dos 
// arquivos anexos
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if ALTERA
	
	cPathTemp	:= cDirAnexos + "\" + cEmpAnt + cFilAnt + "\SC\temp\"
	cPathOrig	:= cDirAnexos + "\" + cEmpAnt + cFilAnt + "\SC\" + cAno + "\mes_" + cMes + "\"

	aFiles		:= Directory(cPathOrig + cFilAnt + "_" + AllTrim(cNumControle) + "_" + "*.*")
		
	if Len(aFiles) > 0
		for nX := 1 to Len(aFiles)
			__CopyFile(cPathOrig + aFiles[nX,1], cPathTemp + aFiles[nX,1])
		next
	endif
	
endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Adiciona item no aRotina para funcionalidade de vincula鈬o de arquivos ? uma 
// solicita鈬o de compra. Os arquivos ser縊 gravados em diretorio dentro do
// rootpath e os usu疵ios n縊 poder縊 ter acesso ? ele.
// Por: Adalberto Moreno Batista (Op鈬o Um) em 13/10/2020
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
aAdd(aBotoes, {"CONTAINR", {|| U_GenAttach(cA110Num, "SC", (INCLUI .or. ALTERA), {cAno, cMes})}, "ｮ Anexos"})

Return(aBotoes)
