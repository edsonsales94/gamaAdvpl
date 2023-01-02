#include "Protheus.ch"
#include "Rwmake.ch"
#include "Topconn.ch"
#include "totvs.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		BRAJOB21 antiga BCOLETA                                       /@
@type				User function                                                 /@
@date				14/03/2012                                                    /@
@description	Rotina p/ uso em schedule. Job para importacao de informacoes
					de data de coleta, do sistema GKO                             /@
@author			Luiz Fernando Nogueira                                        /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function BRAJOB21() 
Local aFiles	:= {"SF2"}
Local cEmp		:= "01"
Local cFil		:= "03"
Local nK, cDirFiles, aFilesGKO

//———————————————————————————————————————————————————————————————————————————————
// Abertura do ambiente
//———————————————————————————————————————————————————————————————————————————————
WfPrepEnv(cEmp, cFil, "U_BRAJOB21",, "FAT")

for nK := 1 to Len(aFiles)
	if Select(aFiles[nK]) == 0
		ChkFile(aFiles[nK])
	endif
next

//———————————————————————————————————————————————————————————————————————————————
// Carrega os arquivos a serem importados
//———————————————————————————————————————————————————————————————————————————————
cDirFiles	:= GetMV("MB_XDIRFTP")
aFilesGKO 	:= Directory(Alltrim(cDirFiles) + "GIEXPEDICAO*")

For nK := 1 to Len(aFilesGKO)

	//———————————————————————————————————————————————————————————————————————————————
	// Importa somente se o tamanho do arquivo for maior que zero
	//———————————————————————————————————————————————————————————————————————————————
	If aFilesGKO[nK,2] > 0
		A21_BRAJOB(cDirFiles + aFilesGKO[nK,1])
	Endif

	//———————————————————————————————————————————————————————————————————————————————
	// Transfere o arquivo para o diretorio de arquivos importados
	//———————————————————————————————————————————————————————————————————————————————
	If File(cDirFiles + aFilesGKO[nK,1])
		Copy File (cDirFiles + aFilesGKO[nK,1]) To (cDirFiles + "IMPORTADOS\" + aFilesGKO[nK,1])
		FErase(cDirFiles + aFilesGKO[nK,1])
	Endif

Next

//———————————————————————————————————————————————————————————————————————————————
// Exclui os arquivos CAN....
//———————————————————————————————————————————————————————————————————————————————
aFilesGKO := Directory(Alltrim(cDirFiles) + "CAN*.TXT")
For nK := 1 to Len(aFilesGKO)
	FErase(cDirFiles + aFilesGKO[nK,1])
Next

//———————————————————————————————————————————————————————————————————————————————
// Encerramento do ambiente
//———————————————————————————————————————————————————————————————————————————————
RpcClearEnv()

ConOut(dTOc(Date()) + " as " + Time() + " - BRAJOB21 - Conclusão do processo de atualização de data e hora de coleta")

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		BCOLETA_A                                                     /@
@type				Static function                                               /@
@date				14/03/2012                                                    /@
@description	Leitura das informações e gravação na tabela de notas de saida/@
@author			Luiz Fernando Nogueira                                        /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function A21_BRAJOB(cArquivo)
Local cBuffer, cCNPJ, cFilialGama, cDoc, cSerie, dColet, hColet

dbSelectArea("SF2")
dbSetOrder(1)			//F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, F2_TIPO

//———————————————————————————————————————————————————————————————————————————————
// Abre o arquivo texto e o lê do início ao fim
//———————————————————————————————————————————————————————————————————————————————
Ft_fUse(cArquivo)
Ft_fGotop()
do While !Ft_fEof()

	cBuffer  := Ft_fReadln()
	if Len(cBuffer) > 3
		cCNPJ		:= Substr(cBuffer, 025, 014)
		cDoc		:= StrZero(Val(Substr(cBuffer, 001, 009)),9)
		cSerie	:= PadR(AllTrim(Str(Val(Substr(cBuffer, 022, 003)))),3)
		dColet	:= StoD(Substr(cBuffer, 010, 008))
		hColet	:= Substr(cBuffer,018,002) + ":" + Substr(cBuffer,020,002)
		if cCNPJ == "07293118000102"
			cFilialGama	:= "01"
		elseif cCNPJ == "07293118000790"
			cFilialGama	:= "09"
		elseif cCNPJ == "07293118000285"
			cFilialGama	:= "03"
		else
			cFilialGama	:= "  "
		endif			

		//———————————————————————————————————————————————————————————————————————————————
		// Quando não for nota GAMA, o arquivo vem com letras
		//———————————————————————————————————————————————————————————————————————————————
		if cDoc != "000000000" .and. !Empty(cFilialGama)

			//———————————————————————————————————————————————————————————————————————————————
			// Pesquisa a nota fiscal para a gravação da data de coleta
			//———————————————————————————————————————————————————————————————————————————————
			if SF2->(dbSeek(cFilialGama + cDoc + cSerie))
				SF2->(Reclock("SF2", .F.))
				SF2->F2_X_COLET	:= dColet
				SF2->F2_XHCOLET 	:= hColet
				//SF2->F2_X_EXPGK	:= ""
				SF2->(MsUnlock())
			else
				ConOut("BRAJOB21 - Inconsistência: Nota não localizada! [filial, nota, série] - [" + cFilialGama + "], [" + cDoc + "], [" + cSerie + "]. " + cArquivo)
			endif

		else
		
			if Empty(cFilialGama) .and. cDoc != "000000000"
				ConOut("BRAJOB21 - Inconsistência: Filial não configurada. CNPJ " + cCNPJ + ". " + cArquivo)
			endif

		endif
		
	endif
	
	Ft_fSkip()
	
Enddo
Ft_fUse()

Return()
