#include "protheus.ch"
#include "ap5mail.ch"

/*/

———————————————————————————————————————————————————————————————————————————————
@function		BRAJOB02                                                     /@
@type			User function                                                /@
@date			13/08/2014                                                   /@
@description	Rotina para exclusão de arquivos temporários no diretório
				system.                                                      /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————

/*/
User Function BRAJOB02()
Local cLocDir	:= "system\"
Local aExtensoes:= {"sc*.log", "sc*.dbf", "sc*.fpt", "sc*.idx", "sc*.mem", "sc*.txt", "sc*.001", "*.sql", "nf*.log"}
Local aFiles, nE, nF

//———————————————————————————————————————————————————————————————————————————————
// Apaga arquivos temporários
//———————————————————————————————————————————————————————————————————————————————
for nE := 1 to Len(aExtensoes)
	
	aFiles := Directory(cLocDir + aExtensoes[nE])
	
	for nF := 1 to Len(aFiles)
		fErase(cLocDir + aFiles[nF,1])
    next
    
next
ConOut(dTOc(Date()) + " as " + Time() + " - BraJOB02 - Conclusão da limpeza de arquivos temporários.")

Return()
