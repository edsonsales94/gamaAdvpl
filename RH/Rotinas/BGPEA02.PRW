#include "rwmake.ch"
#include "protheus.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		BGPEA02                                                       /@
@type				User function                                                 /@
@date				14/07/2016                                                    /@
@description	Rotina para exportação de informações referentes ao resultado
					da importação do MOVIMENTO.
					Arquivo RETORNO integração empresa ZETRA                      /@
@author			Adalberto Moreno Batista (Opção Um Consultoria)               /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function BGPEA02()
Local aSay			:= {}
Local aButton		:= {}
Local nOpc			:= 0
Local cCadastro	:= "Arquivo MOVIMENTO - Integração Zetra"
Local aArea			:= GetArea()
Local cArquivo

//———————————————————————————————————————————————————————————————————————————————
// Criacao da Interface
//———————————————————————————————————————————————————————————————————————————————
aAdd(aSay, "Importação do arquivo MOVIMENTO da empresa Zetra")
aAdd(aSay, "Verifica conteúdo do MV_FOLMES.")
aAdd(aSay, "Informar o drive e caminho para a gravação do arquivo.")

aAdd(aButton, {1, .T., {|| nOpc := 1,	FechaBatch()	}})
aAdd(aButton, {2, .T., {|| FechaBatch()					}})

FormBatch(cCadastro, aSay, aButton)

if nOpc == 1

	cArquivo	:= cGetFile("Arquivos Texto|*.TXT|Todos os Arquivos|*.*", OemToAnsi("Selecione o arquivo"))
	
	//———————————————————————————————————————————————————————————————————————————————
	// Verificando se o processo ira ser continuado                                 
	//———————————————————————————————————————————————————————————————————————————————
	if !File(cArquivo)
	
		Help(,, "ATENÇÃO",, "O arquivo texto não foi localizado. O PROCESSO NÃO SERÁ INICIADO." + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Brasitech)", 1)

	else
   
		ProcRegua(2) // Numero de processos/sub-processos
		
		IncProc("Importando registros do arquivo MOVIMENTO...")

		Processa({|lEnd| ImpZetra(cArquivo)}, "Integração Protheus x Zetra", "Importando registros do arquivo MOVIMENTO...", .T.)
	
		IncProc("Finalizando processo...")

	endif
	
endif   

//———————————————————————————————————————————————————————————————————————————————
// Restaura a posicao original das areas de trabalho
//———————————————————————————————————————————————————————————————————————————————
RestArea(aArea)
Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		ImpZetra                                                      /@
@type				Static function                                               /@
@date				14/07/2016                                                    /@
@description	Gera arquivo texto com informações do layout MARGEM.          /@
@author			Adalberto Moreno Batista (Opção Um Consultoria)               /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function ImpZetra(cArquivo)
Local cArqLog 	:= "C:\TEMP\" + CriaTrab(,.F.) + ".LOG"
Local cDtFolha	:= AllTrim(GetMV("MV_FOLMES"))
Local lCompart	:= .F.					 							//Caso verdadeiro, indica que a tabela deve ser aberta em modo compartilhado, isto é, outros processos também poderão abrir esta tabela.
Local lLeitura	:= .F.												//Caso verdadeiro, indica que este alias será usado apenas para leitura de dados. Caso contrário, estas operações serão permitidas.
Local cLog		:= ""
Local cEol		:= chr(13) + chr(10)
Local cMask		:= "Arquivos Texto" + "(*.TXT)|*.txt|"
Local cTrab, cMatric, cFilMov, cVerba, nValor, nRef, cPeriodo, cMotivo, cNome, cString, cFile

MakeDir("C:\TEMP")

//———————————————————————————————————————————————————————————————————————————————
// Cria estrutura temporária
//———————————————————————————————————————————————————————————————————————————————
cTrab 	:= CriaTrab({{"LINHA", "C", 200, 0}}, .T.)
dbUseArea(.T., __LocalDriver, cTrab, "TRAB", lCompart, lLeitura)

SRA->(dbSetOrder(1))		//RA_FILIAL, RA_MAT
SRC->(dbSetOrder(1))		//RC_FILIAL, RC_MAT, RC_PD, RC_CC, RC_SEMANA, RC_SEQ
//RGB->(dbSetOrder(1))		//RGB_FILIAL, RGB_MAT, RGB_PD, RGB_PERIOD, RGB_SEMANA, RGB_SEQ
ZZ4->(dbSetOrder(1))		//ZZ4_FILIAL, ZZ4_PERIOD, ZZ4_MAT, ZZ4_PD

//———————————————————————————————————————————————————————————————————————————————
// Importacao arquivo texto em tabela auxiliar                            
//———————————————————————————————————————————————————————————————————————————————
dbSelectArea("TRAB")
Append From &cArquivo SDF
dbGoTop()

if eof()
	Help(,, "ATENÇÃO",, "O arquivo " + AllTrim(cArquivo) + " está vazio!" + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Brasitech)", 1)
else

   do while TRAB->(!eof())
      cMatric	:= AllTrim(Substr(TRAB->LINHA,5,6))
      cFilMov	:= AllTrim(Substr(TRAB->LINHA,75,2))
      cVerba	:= AllTrim(Substr(TRAB->LINHA,77,3))
      nValor	:= Val(Substr(TRAB->LINHA,81,10))
		cPeriodo	:= Substr(TRAB->LINHA,98,4) + Substr(TRAB->LINHA,96,2)
     	nRef		:= Val(Substr(TRAB->LINHA,91,3)) + (Val(Substr(TRAB->LINHA,94,3)) / 1000)
    	cNome		:= Substr(TRAB->LINHA,22,50)
		cMotivo	:= ""
		lImporta := .F.
		cString	:= "Filial: " + cFilMov + " - Período: " + cPeriodo + " - Matrícula: " + cMatric + " - Nome: " + cNome + " - Verba: " + cVerba + " || "

		//———————————————————————————————————————————————————————————————————————————————
		// Verifico se o movimento importado, refere-se ao movimento do fechamento da 
		// folha
		//———————————————————————————————————————————————————————————————————————————————
		if cDtFolha == cPeriodo

			//———————————————————————————————————————————————————————————————————————————————
			// Verifico se o movimento já foi importado
			//———————————————————————————————————————————————————————————————————————————————
			if ZZ4->(!dbSeek(cFilMov + cPeriodo + cMatric + cVerba))

				//———————————————————————————————————————————————————————————————————————————————
				// Verifico se a verba existe
				//———————————————————————————————————————————————————————————————————————————————
				if SRV->(dbSeek(cFilMov + cVerba))
				
					//———————————————————————————————————————————————————————————————————————————————
					// Verifico situação do funcionário.
					//———————————————————————————————————————————————————————————————————————————————
					if SRA->(dbSeek(cFilMov + cMatric))
						if SRA->RA_SITFOLH == " " .or.;
							SRA->RA_SITFOLH == "F" .or.;
							(SRA->RA_SITFOLH == "A" .and. SRA->RA_AFASFGT $ "6.7.B.Q.Y") .or.;
							(SRA->RA_SITFOLH == "A" .and. SRA->RA_AFASFGT $ "O.P" .and. DiasAfast(@cMotivo) <= 15)
							
							lImporta := .T.
							
/*
							//Versão 11
							if SRC->(dbSeek(cFilMov + cMatric + cVerba + SRA->RA_CC))
								SRC->(RecLock("SRC", .F.))
							else
								SRC->(RecLock("SRC", .T.))		//chave unica RC_FILIAL+RC_PROCES+RC_MAT+RC_PERIODO+RC_SEMANA+RC_ROTEIR+RC_PD+RC_CC+RC_ITEM+RC_CLVL+RC_SEQ+DTOS(RC_DTREF)
								SRC->RC_FILIAL		:= cFilMov
								SRC->RC_MAT			:= cMatric
								SRC->RC_PD			:= cVerba
								SRC->RC_TIPO1		:= "V"
								SRC->RC_CC			:= SRA->RA_CC
								SRC->RC_TIPO2		:= "I"
							endif
							SRC->RC_VALOR		:= nValor
							SRC->(MsUnlock())
*/
  							//versão 12
							if RGB->(dbSeek(cFilMov + cMatric + cVerba + cPeriodo + "01"))		//RGB_FILIAL, RGB_MAT, RGB_PD, RGB_PERIOD, RGB_SEMANA, RGB_SEQ
								RGB->(RecLock("RGB", .F.))
							else
								RGB->(RecLock("RGB", .T.))		//chave unica 
								RGB->RGB_FILIAL		:= cFilMov
								RGB->RGB_PROCES		:= "00001"
								RGB->RGB_PERIOD		:= cPeriodo 
								RGB->RGB_SEMANA		:= "01"
								RGB->RGB_ROTEIR		:= "FOL"
								RGB->RGB_MAT			:= cMatric
								RGB->RGB_PD		  		:= cVerba
								RGB->RGB_TIPO1			:= "V"
								RGB->RGB_CC				:= SRA->RA_CC
								RGB->RGB_TIPO2			:= "I"
							endif
							RGB->RGB_VALOR		:= nValor
							RGB->(MsUnlock())

						endif
						
						ZZ4->(RecLock("ZZ4", .T.))
						ZZ4->ZZ4_FILIAL	:= cFilMov
						ZZ4->ZZ4_PERIOD	:= cPeriodo
						ZZ4->ZZ4_MAT		:= cMatric
						ZZ4->ZZ4_PD			:= cVerba
						ZZ4->ZZ4_VALOR		:= nValor
						ZZ4->ZZ4_VLREAL	:= iif(lImporta, nValor, 0)
						ZZ4->ZZ4_HORAS		:= ""
						ZZ4->ZZ4_SITUAC	:= iif(lImporta, "T", "R")
						ZZ4->ZZ4_MOTIVO	:= cMotivo
						ZZ4->(MsUnlock())

					else

						cLog += cString + "Matrícula não encontrada." + cEol

					endif		
	
				else

					cLog += cString + "Verba não encontrada." + cEol

				endif
	
			else

				cLog += cString + "Movimento não importado pois já existe no arquivo de movimentos (ZZ4)" + cEol

			endif
		
		else

			cLog += "Data do movimento do arquivo " + cArquivo + " (" + cPeriodo + ") não condiz com o periodo processado no Protheus (" + cDtFolha + ")." + cEol
			Exit

		endif
		
		TRAB->(dbSkip())
	enddo

endif

if !empty(cLog)

	//———————————————————————————————————————————————————————————————————————————————
	// Gerando log de ocorrencias da importacao                                     
	//———————————————————————————————————————————————————————————————————————————————
	MemoWrite(cArqLog, cLog)
	
	Define Font oFont Name "Courrier New" Size 7, 14
	Define MsDialog oDlg Title "Importação concluída" From 3, 0 to 530, 1117 Pixel
	@ 5, 5 Get oMemo Var cLog Memo Size 550, 225 Of oDlg Pixel
	oMemo:bRClicked := { || AllwaysTrue() }
	oMemo:oFont     := oFont

	Define SButton From 245, 465 Type 13 Action (cFile := cGetFile(cMask, ""), iif(cFile == "", .T., MemoWrite(cFile, cLog))) Enable Of oDlg Pixel
	Define SButton From 245, 500 Type  2 Action oDlg:End() Enable Of oDlg Pixel // Apaga
	
	Activate MsDialog oDlg Center

endif
	
//———————————————————————————————————————————————————————————————————————————————
// fechando as areas temporarias e excluindo os arquivos de trabalho          
//———————————————————————————————————————————————————————————————————————————————
if Select("TRAB") > 0
	TRAB->(dbCloseArea())
	fErase(cTrab + GetDbExtension())
endif

//if file(cArqLog)
//	fErase(cArqLog)
//endif

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		DIASAFAST                                                     /@
@type				User Function                                                 /@
@date				29/06/2017                                                    /@
@description	Retorna o número de dias de afastamento                       /@
@author			Adalberto Moreno Batista - Opção Um Consultoria               /@
@use				Especifico Brasitech (Grupo Gama Italy)                       /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function DiasAfast(cMotivo)
Local nDiasAfast	:= 0

//———————————————————————————————————————————————————————————————————————————————
// Pesquisa afastamentos
//———————————————————————————————————————————————————————————————————————————————
SR8->(dbSetOrder(2))			//R8_FILIAL, R8_MAT, R8_SEQ, R8_DATA, R8_TIPO
SR8->(dbSeek(xFilial("SR8") + SRA->RA_MAT))
do while SR8->(!eof() .and. R8_FILIAL == xFilial("SR8") .and. R8_MAT == SRA->RA_MAT)

	//———————————————————————————————————————————————————————————————————————————————
	// Processa registros somente se a data final do afastamento estiver preenchida
	//———————————————————————————————————————————————————————————————————————————————
	if !Empty(SR8->R8_DATAFIM)
		nDiasAfast := SR8->(R8_DATAFIM - R8_DATAINI + 1)
		
		if SRA->RA_FILIAL == "03" .and. SRA->RA_SINDICA == "03" .and. SR8->R8_TIPO $ "P"
			cMotivo := "Afastamento por Doenca"
		elseif SR8->R8_TIPO $ "O"
			cMotivo := "Acidente de Trabalho"
		endif
	endif
		
	SR8->(dbSkip())
	
enddo

Return(nDiasAfast)
