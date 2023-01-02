#include "protheus.ch"     
#include "rwmake.ch"


/*/
———————————————————————————————————————————————————————————————————————————————
@function		CN121ESD                                                     /@
@type			Ponto de entrada                                             /@
@date			18/10/2021                                                   /@
@description	Movimenta os anexos da medição de contrato para o pedido de
				compras, no momento da baixa da medição.                     /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Tecnologia                                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function CN121ESD()
Local cContrato     := AllTrim(CND->CND_CONTRA)
Local cMedicao		:= AllTrim(CND->CND_NUMMED)
Local cDirAnexos	:= GetMV("BR_ANEXOPC")
Local cAno			:= StrZero(Year(SC7->C7_EMISSAO), 4)
Local cMes			:= StrZero(Month(SC7->C7_EMISSAO), 2)
Local cPathOrig		:= cDirAnexos + "\" + cEmpAnt + cFilAnt + "\ct\" + cContrato + "\medicao\"
Local cPathDest		:= cDirAnexos + "\" + cEmpAnt + cFilAnt + "\pc\" + cAno + "\mes_" + cMes + "\"
Local aAnexos		:= Directory(cPathOrig + cMedicao + "_*.*")
Local nX

For nX:=1 to Len(aAnexos)
	__CopyFile(cPathOrig + aAnexos[nX,1], cPathDest + cFilAnt + "_" + SC7->C7_NUM + "_" + aAnexos[nX,1])
	if file(cPathDest + cFilAnt + "_" + SC7->C7_NUM + "_" + aAnexos[nX,1])
		fErase(cPathOrig + aAnexos[nX,1])
	endif
Next

Return()
