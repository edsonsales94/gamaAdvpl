#include "rwmake.ch"
#include "protheus.ch"
#include "apwizard.ch"
#include "fileio.ch"
#include "rptdef.ch"  
#include "fwprintsetup.ch"
#include "totvs.ch"
#include "Ap5Mail.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		INFRAXFUN                                                    /@
@type			Biblioteca de fun鋏es                                        /@
@date			10/09/2018                                                   /@
@description	Biblioteca de fun鋏es utilizadas em rotinas ou valida鋏es
				espec?ficas no ambiente do grupo Gama Italy integra鈬o com 
				INFRACOMMERCE                                                /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br) 
               	Op鈬o Um Tecnologia da Informa鈬o                            /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		TPEMISNF                                                     /@
@type			User Function                                                /@
@date			10/09/2018                                                   /@
@description	Monta listbox do campo ZZ5_TPEMIS, com o tipo de emiss縊 de
				notas fiscais. Tag tpEmis                                    /@
@author			Adalberto Moreno Batista (Op鈬o Um)                          /@
@use			Brasitech (Grupo Gama Italy)                                 /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function TpEmisNF()
Local cRet	:= "1=Emiss縊 normal;" +;
					"2=Conting麩cia FS-IA;" +;
					"3=Conting麩cia SCAN;" +;
					"4=Conting麩cia DPEC;" +;
					"5=Conting麩cia FS-DA;" +;
					"6=Conting麩cia SVC-AN;" +;
					"7=Conting麩cia SVC-RS;" +;
					"9=Conting麩cia off-line"
					
Return(cRet)


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		INTPRESNF                                                    /@
@type			User Function                                                /@
@date			07/11/2018                                                   /@
@description	Monta listbox do campo ZZ5_INDPRE, com o indicador de presen軋
				da NF. Tag indPres                                           /@
@author			Adalberto Moreno Batista (Op鈬o Um)                          /@
@use			Brasitech (Grupo Gama Italy)                                 /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function IndPresNF()
Local cRet := 	"0=N縊 se aplica;" +;
					"1=Opera鈬o presencial;" +;
					"2=Opera鈬o n縊 presencial, pela Internet;" +;
					"3=Opera鈬o n縊 presencial, Teleatendimento;" +;
					"4=NFC-e em opera鈬o com entrega a domic?lio;" +;
					"9=Opera鈬o n縊 presencial"
					
Return(cRet)


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		GravaLog                                                     /@
@type			User Function                                                /@
@date			10/07/2019                                                   /@
@description	Grava log de opera鈬o de processos especificos Brasitech     /@
@author			Adalberto Moreno Batista (Op鈬o Um)                          /@
@use			Brasitech (Grupo Gama Italy)                                 /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function GravaLog(cProcess, cKey, cProblemInd, cText, cFileErr)
Local cBuffer	:= ""
Local nHdl, nTamFile

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Verificando se h? arquivo de erro msexecauto e o abro para extrair o conte?do
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if cFileErr != Nil .and. File("\SYSTEM\" + cFileErr)

	nHdl	:= fOpen(cFileErr)

	if nHdl != -1
	
		nTamFile		:= fSeek(nHdl,0,2)
		fSeek(nHdl,0,0)
		cBuffer 		:= Space(nTamFile)
		fRead(nHdl,@cBuffer,nTamFile)
		fClose(nHdl)
	endif
	
endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Grava o log de processamento
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
ZZ9->(RecLock("ZZ9",.T.))
ZZ9->ZZ9_FILIAL	:= xFilial("ZZ9")
ZZ9->ZZ9_ROTINA	:= FunName()
ZZ9->ZZ9_PROC		:= cProcess
ZZ9->ZZ9_CHAVE		:= cKey
ZZ9->ZZ9_INDPRO	:= cProblemInd
ZZ9->ZZ9_DATA		:= Date()
ZZ9->ZZ9_HORA		:= Time()
ZZ9->ZZ9_RESUMO	:= cText
ZZ9->ZZ9_LOG		:= cText + Chr(13) + Chr(10) + cBuffer
ZZ9->(MsUnlock())
Return()

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		GrvLogIC                                                     /@
@type			User Function                                                /@
@date			10/07/2019                                                   /@
@description	Grava log de opera鈬o de processos especificos Brasitech     /@
@author			Adalberto Moreno Batista (Op鈬o Um)                          /@
@use			Brasitech (Grupo Gama Italy)                                 /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function GrvLogIC(cProcess, cKey, cProblemInd, cText, cFileErr)
Local cBuffer	:= ""
Local cConteudo	:= ""
Local cEol		:= Chr(13) + Chr(10)
//Local cLogFile	:= "\edi01\mmerce\xml\log\" + cKey + ".log"
Local cTraco	:= Repl("=",100)
Local nHdl, nTamFile, cLogFile
Default cKey	:= "SEMCHAVE"

cLogFile	:= "\edi01\mmerce\xml\log\" + cKey + ".log"

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Verificando se h? arquivo de erro msexecauto e o abro para extrair o conte?do
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if cFileErr != Nil .and. File("\SYSTEM\" + cFileErr)
	nHdl	:= fOpen(cFileErr)
	if nHdl != -1
		nTamFile		:= fSeek(nHdl,0,2)
		fSeek(nHdl,0,0)
		cBuffer 		:= Space(nTamFile)
		fRead(nHdl,@cBuffer,nTamFile)
		fClose(nHdl)
	endif
endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Iniciando a vari疱el cConteudo
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if File(cLogFile)
	cConteudo := MemoRead(cLogFile) + cEol
endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Adicionando informa鋏es
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
cConteudo += "Processo: " + cProcess + cEol +;
			 "Em " + dTOc(Date()) + " 灣 " + Time() + iif(!Empty(cUserName), " por " + cUserName, "") + cEol +;
			 AllTrim(cProblemInd) + " -> " + cText +;
			 iif(!Empty(cBuffer), cEol + cBuffer, "") + cEol +;
			 cTraco

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Grava o log de processamento
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
MemoWrite(cLogFile, cConteudo)

Return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		CommitLog                                                    /@
@type			User Function                                                /@
@date			05/03/2020                                                   /@
@description	Descarrega o conte?do do arquivo de log no campo ZZ7_LOG e
				exclui o arquivo f?sico do diretorio de logs                 
				Utilizo este conceito para conseguir buscar os logs de 
				opera鋏es em que n縊 foram bem sucedidas.
				Nestes casos o log era perdido pois estava dentro do controle
				de transa鈬o (begin transact)                                /@
@author			Adalberto Moreno Batista (Op鈬o Um)                          /@
@use			Brasitech (Grupo Gama Italy)                                 /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function CommitLog(cIdNFe)
Local cLogFile	:= "\edi01\infracommerce\xml\log\" + cIdNFe + ".log"
Local cEol		:= Chr(13) + Chr(10)
Local cConteudo

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Verificando a existencia do arquivo de log
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if File(cLogFile)

	cConteudo := MemoRead(cLogFile)

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Grava o log de processamento
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	ZZ7->(RecLock("ZZ7", .F.))
	ZZ7->ZZ7_LOG	:= ZZ7->ZZ7_LOG + cEol + cConteudo
	ZZ7->(MsUnlock())

	//do while !fErase(cLogFile);Enddo
	fErase(cLogFile)

endif

Return()
