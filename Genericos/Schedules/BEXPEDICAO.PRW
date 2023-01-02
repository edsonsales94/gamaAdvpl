#include "Protheus.ch"
#include "Rwmake.ch"
#include "Topconn.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		BEXPEDICAO                                                    /@
@type				User function                                                 /@
@date				14/03/2012                                                    /@
@description	Programa para importacao de informacoes de data da expedicao  /@
@author			Luiz Fernando Nogueira                                        /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function BEXPEDICAO() 
Local aTabelas	:= {"SF2"}
Local cEmp		:= "01"
Local aFil		:= {"03"}	//{"01", "03", "08"}
Local nK, nY, nF, cPrefixo, cDirOrig, cDirDest, aFiles

//———————————————————————————————————————————————————————————————————————————————
// Abertura do ambiente
//———————————————————————————————————————————————————————————————————————————————
For nF := 1 to Len(aFil)

	WfPrepEnv(cEmp, aFil[nF], "U_BEXPEDICAO",, "FAT")
	
	for nK := 1 to Len(aTabelas)
	
		if Select(aTabelas[nK]) == 0
			ChkFile(aTabelas[nK])
		endif
		
	next
	
	cPrefixo := "GIS"		//""
/*	if aFil[nF] == "01"
		cPrefixo := "GIM"			//GIS = GAMA ITALY MANAUS 
	elseif aFil[nF] == "03"
		cPrefixo := "GIS"			//GIM = GAMA ITALY SAO PAULO
	elseif aFil[nF] == "08"
		cPrefixo := "GIE"			//GIE = GAMA ITALY E-COMMERCE
	endif*/

	//———————————————————————————————————————————————————————————————————————————————	
	// Obtem o diretorios onde estao localizados os arquivos
	//———————————————————————————————————————————————————————————————————————————————
	cDirOrig		:= Getmv("MB_XDIRFTP")
	cDirDest		:= cDirOrig + "IMPORTADOS\"
	
	//———————————————————————————————————————————————————————————————————————————————
	// Obtem todos os arquivo a serem importados
	//———————————————————————————————————————————————————————————————————————————————
	aFiles := Directory(Alltrim(cDirOrig) + cPrefixo + "CONFSEP*.TXT")
	
	For nY := 1 to Len(aFiles)
		//———————————————————————————————————————————————————————————————————————————————
		// Obtem o proximo arquivo a ser importado.
		// Se o tamanho do arquivo for maior que zero importa,
		// caso contrario somente transfere do diretorio de arquivos
		// a importar para o diretorio de arquivos ja importados.
		//———————————————————————————————————————————————————————————————————————————————
		If aFiles[nY,2] > 0
			B_EXPEDICAO(aFiles[nY,1], cDirOrig)
		Endif
		//———————————————————————————————————————————————————————————————————————————————
		// Transfere o arquivo para o diretorio de arquivo
		// importados e importa o proximo se existir.
		//———————————————————————————————————————————————————————————————————————————————
		If File(cDirOrig + aFiles[nY,1])
			Copy File (cDirOrig + aFiles[nY,1]) To (cDirDest + aFiles[nY,1])
			FErase(cDirOrig + aFiles[nY,1])   
		EndIf
	Next nY
	
	//———————————————————————————————————————————————————————————————————————————————
	// Para excluir os arquivos CAN....
	//———————————————————————————————————————————————————————————————————————————————
	aFiles := Directory(Alltrim(cDirOrig) + "CAN*.TXT")
	For nY := 1 to Len(aFiles)
		FErase(cDirOrig + aFiles[nY,1])
	Next nY

	//———————————————————————————————————————————————————————————————————————————————
	// Encerramento do ambiente
	//———————————————————————————————————————————————————————————————————————————————
	RpcClearEnv()
	Sleep(5000)
	
	ConOut(dTOc(Date()) + " as " + Time() + " - BEXPEDICAO - Conclusao do processo de leitura dos arquivos de expedicao FM Logistica")
		
next

Return


/*/
———————————————————————————————————————————————————————————————————————————————
@function		BCOLETA_B                                                     /@
@type				Static function                                               /@
@date				24/02/2009                                                    /@
@description	Le as notas dos selecionados a serem importados               /@
@author			Luiz Fernando Nogueira                                        /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function B_EXPEDICAO(cArq, cDirOrig)
Local aArea		:= GetArea()
Local cBuffer, cDoc, cSerie, dExped, hExped, cGAMAFil, cCNPJ
Local aDoc		:= {}

//———————————————————————————————————————————————————————————————————————————————
// Abre arquivo com documentos de entrada a serem importados
//———————————————————————————————————————————————————————————————————————————————
ft_fuse(cDirOrig + cArq)
ft_fgotop()
While !ft_feof()

	cBuffer  := ft_freadln()
	cDoc   	:= StrZero(Val(Substr(cBuffer, 001, 009)),9)
	dExped 	:= Substr(cBuffer, 010, 008)
	hExped 	:= Substr(cBuffer, 018, 004)
	cSerie 	:= strZero(val(Substr(cBuffer, 022, 003)), 1)
	cCNPJ := Substr(cBuffer, 025, 014)

	cGAMAFil := "NI"
	If cCNPJ == "07293118000102"
		cGAMAFil := "01"
	ElseIf cCNPJ == "07293118000285"
		cGAMAFil := "03"
	ElseIf cCNPJ == "07293118000609"
		cGAMAFil := "08"
	EndIf
	
	if cDoc != "000000000" .and. aScan(aDoc, cGAMAFil+cDoc+cSerie) == 0

		aAdd(aDoc, cGAMAFil+cDoc+cSerie)

		dbSelectArea("SF2")
		dbSetOrder(1)
		If DbSeek(cGAMAFil + cDoc + cSerie)
			Reclock("SF2" , .F.)
			SF2->F2_X_EXPED	:= stod(dExped)
			SF2->F2_XHEXPED 	:= Substr(hExped,1,2) + ':' + Substr(hExped,3,2) 
			MsUnlock()
		Else
			ConOut("NF não encontrada. BEXPEDICAO - " + cGAMAFil + " - " + cDoc + " - " + cSerie + " - " + cArq)
		EndIf
		
	endif

	ft_fskip()
	Loop
	
End

ft_fuse()

RestArea(aArea)
Return
