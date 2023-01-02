#include "protheus.ch"
#include "ap5mail.ch"

/*/

�������������������������������������������������������������������������������
@function		BRAJOB02                                                     /@
@type			User function                                                /@
@date			13/08/2014                                                   /@
@description	Rotina para exclus�o de arquivos tempor�rios no diret�rio
				system.                                                      /@
@author			Adalberto Moreno Batista - Op��o Um Consultoria              /@
@use			Espec�fico Brasitech                                         /@
�������������������������������������������������������������������������������

/*/
User Function BRAJOB02()
Local cLocDir	:= "system\"
Local aExtensoes:= {"sc*.log", "sc*.dbf", "sc*.fpt", "sc*.idx", "sc*.mem", "sc*.txt", "sc*.001", "*.sql", "nf*.log"}
Local aFiles, nE, nF

//�������������������������������������������������������������������������������
// Apaga arquivos tempor�rios
//�������������������������������������������������������������������������������
for nE := 1 to Len(aExtensoes)
	
	aFiles := Directory(cLocDir + aExtensoes[nE])
	
	for nF := 1 to Len(aFiles)
		fErase(cLocDir + aFiles[nF,1])
    next
    
next
ConOut(dTOc(Date()) + " as " + Time() + " - BraJOB02 - Conclus�o da limpeza de arquivos tempor�rios.")

Return()