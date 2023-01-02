#include "protheus.ch"
#include "ap5mail.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		BRAJOB06                                                     	/@
@type			User function                                                		/@
@date			06/12/2014                                                   		/@
@description	Rotina para uso em schedule. 
				Job para importacao de notas de notas do operador logistico
				FM, a partir de arquivo texto.                               		/@
@author			Adalberto Moreno Batista - Opção Um Consultoria              	/@
@use			Específico Brasitech                                         		/@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function BRAJOB06()
Local aFiles	:= {"SA1", "SB1", "SD2", "SF2", "SZW"}
Local aStruLog	:= {{"LINHA",		"C", 200, 0}}
Local aStruTrb	:= {{"DETALHE",		"C", 250, 0}}
Local nK, cTLOG, cTAUX, aArquivos, cArquivo
Private aEmpresas := {}
Private cLocDir	:= "edi01\nfoplog"

MakeDir("edi01")
MakeDir("edi01\nfoplog")
MakeDir("edi01\nfoplog\ok")
MakeDir("edi01\nfoplog\log")

//———————————————————————————————————————————————————————————————————————————————
// Abertura do Sigamat.emp
//———————————————————————————————————————————————————————————————————————————————
for nK := 1 to 20
	dbUseArea(.T.,, "SIGAMAT.EMP", "SM0", .T., .F.)

	if !Empty(Select("SM0"))
		dbSetIndex("SIGAMAT.IND")
		dbSelectArea("SM0")
		dbSeek("01")
		do while SM0->(!eof() .and. M0_CODIGO == "01")
			aAdd(aEmpresas, {SM0->M0_CODFIL, SM0->M0_CGC})
			SM0->(dbSkip())
		enddo
		SM0->(dbCloseArea())
		Exit
	endif

	Sleep(500)
next

if Len(aEmpresas) == 0

	ConOut(dTOc(Date()) + " as " + Time() + " - BRAJOB06 - Não foi possível abrir o arquivo de empresas. Processo cancelado.")

else

	//———————————————————————————————————————————————————————————————————————————————
	// Leitura dos arquivos para importação NFCONTAEORD_GI_20141215172214_01_06_2014_131.TXT
	//———————————————————————————————————————————————————————————————————————————————
	aArquivos	:= Directory(cLocDir + "\GICONTAORDEM_*.TXT") //aArquivos	:= Directory(cLocDir + "\NFCONTAEORD_GI_*.TXT")
	
	//———————————————————————————————————————————————————————————————————————————————
	// Inicia a abertura do ambiente somente se houver arquivos a serem processados
	//———————————————————————————————————————————————————————————————————————————————
	if Len(aArquivos) > 0
	
		//———————————————————————————————————————————————————————————————————————————————
		// Abertura do ambiente
		//———————————————————————————————————————————————————————————————————————————————
		WfPrepEnv("01", "01", "U_BRAJOB06",, "FAT")
			
		for nK := 1 to Len(aFiles)
			
			if Select(aFiles[nK]) = 0
				ChkFile(aFiles[nK])
			endif
				
		next
				
		//———————————————————————————————————————————————————————————————————————————————
		// Inicia o tratamento dos arquivos encontrados
		//———————————————————————————————————————————————————————————————————————————————
		//Cria tabela de log
		cTLOG := CriaTrab(aStruLOG, .T.)
		dbUseArea(.T.,__localdriver, cTLOG, "TLOG", .T.)

		for nK := 1 to Len(aArquivos)
	
			cArquivo := cLocDir + "\" + aArquivos[nK,1]

			//Cria tabela auxiliar para importacao
			cTAUX := CriaTrab(aStruTRB, .T.)
			dbUseArea(.T.,, cTAUX, "TAUX", .T.)
	
			dbSelectArea("TAUX")
			Append From &cArquivo SDF
			dbGoTop()

			GrvLog(Repl("—" , Len(TLOG->LINHA)))
			GrvLog("Arquivo " + cArquivo)
			GrvLog(Repl("—" , Len(TLOG->LINHA)))
			
			BRAJOB06A()
			
			//Copia tabela processada no diretorio OK
			__CopyFile(cArquivo, cLocDir + "\ok\" + aArquivos[nK,1])
			fErase(cArquivo)
		
			//Fecho o arquivo de trabalho e o excluo
			if Select("TAUX") > 0
				TAUX->(dbCloseArea())
			endif
			fErase(cTAUX + OrdBagExt())

			GrvLog(" ")
		next

		dbSelectArea("TLOG")
		TLOG->(dbGoTop())
		if TLOG->(!eof())
			//Envia e-mail com o resultado do processamento
			//BRAJOB06B()
		endif
		//Fecho o arquivo de log e o excluo
		if Select("TLOG") > 0
			TLOG->(dbCloseArea())
		endif
		fErase(cTLOG + OrdBagExt())

		//———————————————————————————————————————————————————————————————————————————————
		// Encerramento do ambiente                                                     
		//———————————————————————————————————————————————————————————————————————————————
		RpcClearEnv()
	
		ConOut(dTOc(Date()) + " as " + Time() + " - BRAJOB06 - Importação de informações das notas fiscais emitidas pelo operador logístico FM")
		
	endif
	
endif	
	
Return()


/*/

———————————————————————————————————————————————————————————————————————————————
@function		BRAJOB06A                                                    /@
@type			Static function                                              /@
@date			10/12/2014                                                   /@
@description	Função chamada pela user function BRAJOB06.                  /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————

/*/
Static Function BRAJOB06A()
Local lContinua	:= .F.
Local cCabCNPJGama, cCabSerie, cCabNF, dCabEmissao, nCabTotNF, cCabChvNFE, cCabCNPJDest,;
	  nCabTotMerc, nCabFrete, nCabSeguro, nCabDesconto, nCabAcessor, nCabVolume,;
	  cCabEspecie, nCabPesoBru, nCabPesoLiq, cDetItem, cDetProd, nDetQtd, nDetVlUnit,;
	  cDetNFGama, cDetSerGama, cDetNCM, cDetCST, cDetCFOP, nDetBCICMS, nDetVlICMS,;
	  nDetAlICMS, nDetVlIPI, nDetAlIPI, nDetBCST, nDetVlST, cCodFil, cCodCli, cLoja,;
	  nPos, cLinha

SA1->(dbSetOrder(3))	//A1_FILIAL+A1_CGC
SB1->(dbSetOrder(1))	//B1_FILIAL+B1_COD
SD2->(dbSetOrder(3))	//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM

do while TAUX->(!eof())

	cLinha := StrTran(TAUX->DETALHE,"ï»¿","")

	if Left(StrTran(cLinha,"ï»¿",""), 1) == "N"
		lContinua	 := .F.
		cCodCli		 := ""
		cLoja		 := ""
		
		GrvLog("")
		cCabCNPJGama := Substr(cLinha, 2, 14)
		cCabSerie	 := Substr(cLinha, 16, 3)
		cCabNF		 := Substr(cLinha, 19, 9)
		dCabEmissao	 := cTOd(Substr(cLinha, 28, 2) + "/" + Substr(cLinha, 30, 2) + "/" + Substr(cLinha, 32, 4))
		nCabTotNF	 := Val(Substr(cLinha, 36, 11))
		cCabChvNFE	 := Substr(cLinha, 47, 44)
		cCabCNPJDest := Substr(cLinha, 91, 14)
		nCabTotMerc	 := Val(Substr(cLinha, 105, 11))
		nCabFrete	 := Val(Substr(cLinha, 116, 11))
		nCabSeguro	 := Val(Substr(cLinha, 127, 11))
		nCabDesconto := Val(Substr(cLinha, 138, 11))
		nCabAcessor	 := Val(Substr(cLinha, 149, 11))
		nCabVolume	 := Val(Substr(cLinha, 160, 6))
		cCabEspecie	 := Substr(cLinha, 166, 15)
		nCabPesoBru	 := Val(Substr(cLinha, 181, 11))
		nCabPesoLiq	 := Val(Substr(cLinha, 192, 11))

		nPos 	:= aScan(aEmpresas, {|x| AllTrim(x[2]) == AllTrim(cCabCNPJGama) })
		cCodFil	:= iif(nPos > 0, aEmpresas[nPos, 1], "")
	
		if SA1->(dbSeek("  " + cCabCNPJDest))
			cCodCli 	:= SA1->A1_COD
			cLoja		:= SA1->A1_LOJA
			lContinua	:= .T.
		endif
		
	elseif Left(TAUX->DETALHE, 1) == "I"
		cDetItem	 := Substr(TAUX->DETALHE, 14, 4)
		cDetProd	 := Substr(TAUX->DETALHE, 18, 15)
		nDetQtd		 := Val(Substr(TAUX->DETALHE, 43, 9))
		nDetVlUnit	 := Val(Substr(TAUX->DETALHE, 52, 11))
		cDetNFGama	 := Substr(TAUX->DETALHE, 63, 9)
		cDetSerGama	 := Substr(TAUX->DETALHE, 72, 3)
		cDetNCM		 := Substr(TAUX->DETALHE, 75, 8)
		cDetCST		 := Substr(TAUX->DETALHE, 83, 3)
		cDetCFOP	 := Substr(TAUX->DETALHE, 86, 4)
		nDetBCICMS	 := Val(Substr(TAUX->DETALHE, 90, 11))
		nDetVlICMS	 := Val(Substr(TAUX->DETALHE, 101, 11))
		nDetAlICMS	 := Val(Substr(TAUX->DETALHE, 112, 5))
		nDetVlIPI	 := Val(Substr(TAUX->DETALHE, 117, 11))
		nDetAlIPI	 := Val(Substr(TAUX->DETALHE, 128, 5))
		nDetBCST	 := Val(Substr(TAUX->DETALHE, 133, 11))
		nDetVlST	 := Val(Substr(TAUX->DETALHE, 144, 11))

		if !Empty(cCodFil)

			if lContinua

				if SD2->(dbSeek(cCodFil + cDetNFGama + cDetSerGama + cCodCli + cLoja + cDetProd))

					if SZW->(!dbSeek(cCodFil + cCabNF + cCabSerie + cDetItem))

						GrvLog("Incluído Filial/NF/Serie/Item: " + cCodFil + "/" + cCabNF + "/" + cCabSerie + "/" + cDetItem)
						SZW->(RecLock("SZW", .T.))
						SZW->ZW_FILIAL	 := cCodFil
						SZW->ZW_DOC		 := cCabNF
						SZW->ZW_SERIE	 := cCabSerie
						SZW->ZW_ITEM	 := cDetItem				

					else

						GrvLog("Alterado Filial/NF/Serie/Item: " + cCodFil + "/" + cCabNF + "/" + cCabSerie + "/" + cDetItem)
						SZW->(RecLock("SZW", .T.))

					endif
					
					SZW->ZW_CNPJGAM	 := cCabCNPJGama
					SZW->ZW_EMISSAO	 := dCabEmissao
					SZW->ZW_TOTNF	 := nCabTotNF
					SZW->ZW_CHVNFE	 := cCabChvNFE
					SZW->ZW_CNPJCLI	 := cCabCNPJDest
					SZW->ZW_TOTMERC	 := nCabTotMerc
					SZW->ZW_TOTFRET	 := nCabFrete
					SZW->ZW_TOTSEG	 := nCabSeguro
					SZW->ZW_TOTDESC	 := nCabDesconto
					SZW->ZW_TOTDESP	 := nCabAcessor
					SZW->ZW_VOLUME	 := nCabVolume
					SZW->ZW_ESPECIE	 := cCabEspecie
					SZW->ZW_PESOBRU	 := nCabPesoBru
					SZW->ZW_PESOLIQ	 := nCabPesoLiq
					SZW->ZW_PRODUTO	 := cDetProd
					SZW->ZW_QUANT	 := nDetQtd
					SZW->ZW_VLUNIT	 := nDetVlUnit
					SZW->ZW_DOCGAMA	 := cDetNFGama
					SZW->ZW_SERGAMA	 := cDetSerGama
					SZW->ZW_NCM		 := cDetNCM
					SZW->ZW_CST		 := cDetCST
					SZW->ZW_CFOP	 := cDetCFOP
					SZW->ZW_BCICMS	 := nDetBCICMS
					SZW->ZW_VLICMS	 := nDetVlICMS
					SZW->ZW_ALICMS	 := nDetAlICMS
					SZW->ZW_VLIPI	 := nDetVlIPI
					SZW->ZW_ALIPI	 := nDetAlIPI
					SZW->ZW_BCST	 := nDetBCST
					SZW->ZW_VLST	 := nDetVlST
				
					SZW->(MsUnlock())

				else
	
					GrvLog("Problema. Filial/NF/Serie/Item: " + cCodFil + "/" + cCabNF + "/" + cCabSerie + "/" + cDetItem + " não será gravada, pois não encontramos vínculo com a nota da Brasitech: " + cCodFil + "/" + cDetNFGama + "/" + cDetSerGama + "/" + cCodCli + "/" + cLoja + "/" + cDetProd)
									
				endif
			
			else

				GrvLog("Problema. Filial/NF/Serie/Item: " + cCodFil + "/" + cCabNF + "/" + cCabSerie + "/" + cDetItem + " não será gravada, pois o cliente de CNPJ " + cCabCNPJDest + " não foi localizado.")
								
			endif

		else

			GrvLog("Problema. Filial/NF/Serie/Item: " + cCodFil + "/" + cCabNF + "/" + cCabSerie + "/" + cDetItem + " não será gravada, pois não identificamos a filial para o CNPJ da Brasitech " + cCabCNPJGama + ".")
			
		endif
		
	endif
	
	TAUX->(dbSkip())
	
enddo
Return()


/*/

———————————————————————————————————————————————————————————————————————————————
@function		BRAJOB06B                                                    /@
@type			Static function                                              /@
@date			10/12/2014                                                   /@
@description	Função chamada pela user function BRAJOB04. Envia o log de
				processamento para e-mails previamente cadastrados no parame-
				tro BR_MAILGKO                                               /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————

/*/
Static Function BRAJOB06B()
Local cAnexo, cMensagem
Local nSeq		:= 0
Local cEol		:= Chr(13) + Chr(10)
Local cDestinat	:= AllTrim(GetMV("BR_EMLJB06", .F., "cassio.olimpio@gamaitaly.com.br"))
Local cAssunto	:= "Brasitech - Log da importação de notas do operador logístico FM"

//————————————————————————————————————————————————————————————————————————————
// Identificando um nome válido para o arquivo de log de processamento
//————————————————————————————————————————————————————————————————————————————
do while .T.
	cAnexo := cLocDir + "\log\PROCNFCO_" + dTOs(date()) + "_" + StrZero(++nSeq, 3) + ".LOG"
	if !File(cAnexo)
		exit
	endif
enddo

dbSelectArea("TLOG")
Copy to &cAnexo SDF

//————————————————————————————————————————————————————————————————————————————
// e-mail no formato html
//————————————————————————————————————————————————————————————————————————————
cMensagem := '<html>' + cEol
cMensagem += '<font size="2" face="Arial">Informações de ocorrências na importação de informações de notas fiscais do operador logistico FM em' + dTOc(dDataBase) + ' às ' + Time() + '.' + cEol + 'Para detalhes das ocorrências, abra o arquivo anexo.</font>' + cEol + cEol + cEol
cMensagem += '<font size="1" face="Calibri">E-mail automático enviado pelo sistema Microsiga Protheus. Favor não respondê-lo.</font>' + cEol	
cMensagem += '</body>' + cEol
cMensagem += '</html>' + cEol

U_GISendMail(cDestinat,, cAssunto, cMensagem, cAnexo)

Return()


/*/

———————————————————————————————————————————————————————————————————————————————
@function		GRVLOG                                                       /@
@type			Static function                                              /@
@date			06/09/2014                                                   /@
@description	Função chamada pela static function BRAJOB04A. Grava log de
				processamento na tabela temporária de log                    /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————

/*/
Static Function GrvLog(cTexto)
Local aArea	:= GetArea()

dbSelectArea("TLOG")
TLOG->(RecLock("TLOG",.T.))
TLOG->LINHA	:= cTexto
TLOG->(MsUnlock())

RestArea(aArea)

Return()
