#include "protheus.ch"
#include "ap5mail.ch"

/*/

覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		BRAJOB02                                                     /@
@type			User function                                                /@
@date			13/08/2014                                                   /@
@description	Rotina para exclus縊 de arquivos tempor疵ios no diret?rio
				system.                                                      /@
@author			Adalberto Moreno Batista - Op鈬o Um Consultoria              /@
@use			Espec?fico Brasitech                                         /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?

/*/
User Function BRAJOB02()
Local cLocDir	:= "system\"
Local aExtensoes:= {"sc*.log", "sc*.dbf", "sc*.fpt", "sc*.idx", "sc*.mem", "sc*.txt", "sc*.001", "*.sql", "nf*.log"}
Local aFiles, nE, nF

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Apaga arquivos tempor疵ios
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
for nE := 1 to Len(aExtensoes)
	
	aFiles := Directory(cLocDir + aExtensoes[nE])
	
	for nF := 1 to Len(aFiles)
		fErase(cLocDir + aFiles[nF,1])
    next
    
next
ConOut(dTOc(Date()) + " as " + Time() + " - BraJOB02 - Conclus縊 da limpeza de arquivos tempor疵ios.")

Return()
