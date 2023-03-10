#include "Protheus.ch"
#include "Rwmake.ch"
#include "Topconn.ch"
#include "totvs.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		BRAJOB21 antiga BCOLETA                                       /@
@type				User function                                                 /@
@date				14/03/2012                                                    /@
@description	Rotina p/ uso em schedule. Job para importacao de informacoes
					de data de coleta, do sistema GKO                             /@
@author			Luiz Fernando Nogueira                                        /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function BRAJOB21() 
Local aFiles	:= {"SF2"}
Local cEmp		:= "01"
Local cFil		:= "03"
Local nK, cDirFiles, aFilesGKO

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Abertura do ambiente
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
WfPrepEnv(cEmp, cFil, "U_BRAJOB21",, "FAT")

for nK := 1 to Len(aFiles)
	if Select(aFiles[nK]) == 0
		ChkFile(aFiles[nK])
	endif
next

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Carrega os arquivos a serem importados
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
cDirFiles	:= GetMV("MB_XDIRFTP")
aFilesGKO 	:= Directory(Alltrim(cDirFiles) + "GIEXPEDICAO*")

For nK := 1 to Len(aFilesGKO)

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Importa somente se o tamanho do arquivo for maior que zero
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	If aFilesGKO[nK,2] > 0
		A21_BRAJOB(cDirFiles + aFilesGKO[nK,1])
	Endif

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Transfere o arquivo para o diretorio de arquivos importados
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	If File(cDirFiles + aFilesGKO[nK,1])
		Copy File (cDirFiles + aFilesGKO[nK,1]) To (cDirFiles + "IMPORTADOS\" + aFilesGKO[nK,1])
		FErase(cDirFiles + aFilesGKO[nK,1])
	Endif

Next

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Exclui os arquivos CAN....
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
aFilesGKO := Directory(Alltrim(cDirFiles) + "CAN*.TXT")
For nK := 1 to Len(aFilesGKO)
	FErase(cDirFiles + aFilesGKO[nK,1])
Next

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Encerramento do ambiente
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
RpcClearEnv()

ConOut(dTOc(Date()) + " as " + Time() + " - BRAJOB21 - Conclus縊 do processo de atualiza鈬o de data e hora de coleta")

Return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		BCOLETA_A                                                     /@
@type				Static function                                               /@
@date				14/03/2012                                                    /@
@description	Leitura das informa鋏es e grava鈬o na tabela de notas de saida/@
@author			Luiz Fernando Nogueira                                        /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function A21_BRAJOB(cArquivo)
Local cBuffer, cCNPJ, cFilialGama, cDoc, cSerie, dColet, hColet

dbSelectArea("SF2")
dbSetOrder(1)			//F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, F2_TIPO

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Abre o arquivo texto e o l? do in?cio ao fim
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
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

		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		// Quando n縊 for nota GAMA, o arquivo vem com letras
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		if cDoc != "000000000" .and. !Empty(cFilialGama)

			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			// Pesquisa a nota fiscal para a grava鈬o da data de coleta
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			if SF2->(dbSeek(cFilialGama + cDoc + cSerie))
				SF2->(Reclock("SF2", .F.))
				SF2->F2_X_COLET	:= dColet
				SF2->F2_XHCOLET 	:= hColet
				//SF2->F2_X_EXPGK	:= ""
				SF2->(MsUnlock())
			else
				ConOut("BRAJOB21 - Inconsist麩cia: Nota n縊 localizada! [filial, nota, s駻ie] - [" + cFilialGama + "], [" + cDoc + "], [" + cSerie + "]. " + cArquivo)
			endif

		else
		
			if Empty(cFilialGama) .and. cDoc != "000000000"
				ConOut("BRAJOB21 - Inconsist麩cia: Filial n縊 configurada. CNPJ " + cCNPJ + ". " + cArquivo)
			endif

		endif
		
	endif
	
	Ft_fSkip()
	
Enddo
Ft_fUse()

Return()
