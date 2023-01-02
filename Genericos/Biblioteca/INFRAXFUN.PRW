#include "rwmake.ch"
#include "protheus.ch"
#include "apwizard.ch"
#include "fileio.ch"
#include "rptdef.ch"  
#include "fwprintsetup.ch"
#include "totvs.ch"
#include "Ap5Mail.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
———————————————————————————————————————————————————————————————————————————————
@function		INFRAXFUN                                                    /@
@type			Biblioteca de funções                                        /@
@date			10/09/2018                                                   /@
@description	Biblioteca de funções utilizadas em rotinas ou validações
				específicas no ambiente do grupo Gama Italy integração com 
				INFRACOMMERCE                                                /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br) 
               	Opção Um Tecnologia da Informação                            /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
———————————————————————————————————————————————————————————————————————————————
/*/

/*/
———————————————————————————————————————————————————————————————————————————————
@function		TPEMISNF                                                     /@
@type			User Function                                                /@
@date			10/09/2018                                                   /@
@description	Monta listbox do campo ZZ5_TPEMIS, com o tipo de emissão de
				notas fiscais. Tag tpEmis                                    /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech (Grupo Gama Italy)                                 /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function TpEmisNF()
Local cRet	:= "1=Emissão normal;" +;
					"2=Contingência FS-IA;" +;
					"3=Contingência SCAN;" +;
					"4=Contingência DPEC;" +;
					"5=Contingência FS-DA;" +;
					"6=Contingência SVC-AN;" +;
					"7=Contingência SVC-RS;" +;
					"9=Contingência off-line"
					
Return(cRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		INTPRESNF                                                    /@
@type			User Function                                                /@
@date			07/11/2018                                                   /@
@description	Monta listbox do campo ZZ5_INDPRE, com o indicador de presença
				da NF. Tag indPres                                           /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech (Grupo Gama Italy)                                 /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function IndPresNF()
Local cRet := 	"0=Não se aplica;" +;
					"1=Operação presencial;" +;
					"2=Operação não presencial, pela Internet;" +;
					"3=Operação não presencial, Teleatendimento;" +;
					"4=NFC-e em operação com entrega a domicílio;" +;
					"9=Operação não presencial"
					
Return(cRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		GravaLog                                                     /@
@type			User Function                                                /@
@date			10/07/2019                                                   /@
@description	Grava log de operação de processos especificos Brasitech     /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech (Grupo Gama Italy)                                 /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function GravaLog(cProcess, cKey, cProblemInd, cText, cFileErr)
Local cBuffer	:= ""
Local nHdl, nTamFile

//———————————————————————————————————————————————————————————————————————————————
// Verificando se há arquivo de erro msexecauto e o abro para extrair o conteúdo
//———————————————————————————————————————————————————————————————————————————————
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

//———————————————————————————————————————————————————————————————————————————————
// Grava o log de processamento
//———————————————————————————————————————————————————————————————————————————————
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
———————————————————————————————————————————————————————————————————————————————
@function		GrvLogIC                                                     /@
@type			User Function                                                /@
@date			10/07/2019                                                   /@
@description	Grava log de operação de processos especificos Brasitech     /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech (Grupo Gama Italy)                                 /@
———————————————————————————————————————————————————————————————————————————————
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

//———————————————————————————————————————————————————————————————————————————————
// Verificando se há arquivo de erro msexecauto e o abro para extrair o conteúdo
//———————————————————————————————————————————————————————————————————————————————
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

//———————————————————————————————————————————————————————————————————————————————
// Iniciando a variável cConteudo
//———————————————————————————————————————————————————————————————————————————————
if File(cLogFile)
	cConteudo := MemoRead(cLogFile) + cEol
endif

//———————————————————————————————————————————————————————————————————————————————
// Adicionando informações
//———————————————————————————————————————————————————————————————————————————————
cConteudo += "Processo: " + cProcess + cEol +;
			 "Em " + dTOc(Date()) + " às " + Time() + iif(!Empty(cUserName), " por " + cUserName, "") + cEol +;
			 AllTrim(cProblemInd) + " -> " + cText +;
			 iif(!Empty(cBuffer), cEol + cBuffer, "") + cEol +;
			 cTraco

//———————————————————————————————————————————————————————————————————————————————
// Grava o log de processamento
//———————————————————————————————————————————————————————————————————————————————
MemoWrite(cLogFile, cConteudo)

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		CommitLog                                                    /@
@type			User Function                                                /@
@date			05/03/2020                                                   /@
@description	Descarrega o conteúdo do arquivo de log no campo ZZ7_LOG e
				exclui o arquivo físico do diretorio de logs                 
				Utilizo este conceito para conseguir buscar os logs de 
				operações em que não foram bem sucedidas.
				Nestes casos o log era perdido pois estava dentro do controle
				de transação (begin transact)                                /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech (Grupo Gama Italy)                                 /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function CommitLog(cIdNFe)
Local cLogFile	:= "\edi01\infracommerce\xml\log\" + cIdNFe + ".log"
Local cEol		:= Chr(13) + Chr(10)
Local cConteudo

//———————————————————————————————————————————————————————————————————————————————
// Verificando a existencia do arquivo de log
//———————————————————————————————————————————————————————————————————————————————
if File(cLogFile)

	cConteudo := MemoRead(cLogFile)

	//———————————————————————————————————————————————————————————————————————————————
	// Grava o log de processamento
	//———————————————————————————————————————————————————————————————————————————————
	ZZ7->(RecLock("ZZ7", .F.))
	ZZ7->ZZ7_LOG	:= ZZ7->ZZ7_LOG + cEol + cConteudo
	ZZ7->(MsUnlock())

	//do while !fErase(cLogFile);Enddo
	fErase(cLogFile)

endif

Return()
