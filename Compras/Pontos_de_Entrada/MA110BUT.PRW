#include "protheus.ch"     
#include "rwmake.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		MA110BUT                                                     /@
@type			Ponto de entrada                                             /@
@date			13/10/2020                                                   /@
@description	Adiciona função no menu (aRotina) de solicitação de compras  /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Consultoria                                         /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
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

//———————————————————————————————————————————————————————————————————————————————
// Gravando os anexos no diretorio temp e definindo o caminho de trabalho dos 
// arquivos anexos
//———————————————————————————————————————————————————————————————————————————————
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

//———————————————————————————————————————————————————————————————————————————————
// Adiciona item no aRotina para funcionalidade de vinculação de arquivos à uma 
// solicitação de compra. Os arquivos serão gravados em diretorio dentro do
// rootpath e os usuários não poderão ter acesso à ele.
// Por: Adalberto Moreno Batista (Opção Um) em 13/10/2020
//———————————————————————————————————————————————————————————————————————————————
aAdd(aBotoes, {"CONTAINR", {|| U_GenAttach(cA110Num, "SC", (INCLUI .or. ALTERA), {cAno, cMes})}, "® Anexos"})

Return(aBotoes)
