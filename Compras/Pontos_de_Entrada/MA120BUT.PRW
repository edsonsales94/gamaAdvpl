#Include "protheus.ch"     
#include "rwmake.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		MA120BUT                                                     /@
@type			Ponto de entrada                                             /@
@date			20/02/2017                                                   /@
@description	Adiciona função no menu (aRotina) de pedidos de compras      /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Consultoria                                         /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MA120BUT()
Local aBotoes 		:= {}
Local cAno			:= StrZero(Year(dA120Emis), 4)
Local cMes			:= StrZero(Month(dA120Emis), 2)
Local cDirAnexos	:= GetMV("BR_ANEXOPC")		// "\\MARROCOS\COTACOES"
Local cPathTemp, cPathOrig, nX

MakeDir(cDirAnexos)
MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt)
MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt + "\PC")
MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt + "\PC\temp")
MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt + "\PC\" + cAno)
MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt + "\PC" + cAno + "\mes_" + cMes)

//———————————————————————————————————————————————————————————————————————————————
// Gravando os anexos no diretorio temp e definindo o caminho de trabalho dos 
// arquivos anexos
//———————————————————————————————————————————————————————————————————————————————
if ALTERA
	
	cPathTemp	:= cDirAnexos + "\" + cEmpAnt + cFilAnt + "\PC\temp\"
	cPathOrig	:= cDirAnexos + "\" + cEmpAnt + cFilAnt + "\PC\" + cAno + "\mes_" + cMes + "\"
		
	aFiles	:= Directory(cPathOrig + cFilAnt + "_" + AllTrim(ca120Num) + "_" + "*.*")

	if Len(aFiles) > 0
		for nX := 1 to Len(aFiles)
			__CopyFile(cPathOrig + aFiles[nX,1], cPathTemp + aFiles[nX,1])
		next
	endif
	
endif

//———————————————————————————————————————————————————————————————————————————————
// Adiciona item no aRotina para funcionalidade de vinculação de arquivos à um 
// pedido de compra. Os arquivos serão gravados em diretorio dentro do rootpath
// e os usuários não poderão ter acesso à ele.
// Por: Adalberto Moreno Batista (Opção Um Consultoria) em 20/03/2017
//———————————————————————————————————————————————————————————————————————————————
aAdd(aBotoes, {"CONTAINR", {|| U_GenAttach(cA120Num, "PC", (INCLUI .or. ALTERA .or. lCop), {cAno, cMes})}, "® Anexos"})

Return(aBotoes)
