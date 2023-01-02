#include "protheus.ch"
#include "ap5mail.ch"

/*/
—————————————————————————————————————————————————————————————————————————————
@function  		                                                   /@
@type			User function                                              /@
@date			05/09/2014                                                 /@
@description	Rotina para uso em schedule.
				Job para importacao de notas de conhecimento de transporte
				a partir de arquivo texto gerado pelo software GKO.
				Importação de informações do Conhecimento de transporte
				(NC) para a tabela de notas fiscais de entrada do Protheus,
				a partir de arquivo texto (FRNC*.TXT) gerado pelo software
				GKO, conforme layout INTNC 5.71a.
				Automatização da rotina BGKO02                             /@
@author			Adalberto Moreno Batista - Opção Um Tecnologia             /@
@use			Brasitech                                                  /@
—————————————————————————————————————————————————————————————————————————————
16/12/20 - Tratamento para verificar se cadastro de fornecedor está com lock
montagem do log em tabela ZZ9, ao invés de arquivos
/*/
User Function BRAJOB04()
Local aFiles	:= {"SA2", "SB1", "SD1", "SF1", "SF2", "SF4", "SE4"}
Local cLocDir	:= "edi01\gko\"							//MV_X_PATED
Local aStruTrb	:= {	{"TPREGISTRO",	"C", 003, 0},;
						{"IDNC",		"C", 015, 0},;
						{"DETALHE",		"C", 230, 0}}
Local aEmp		:= {{"01", "01"}, {"01", "03"}, {"01", "09"}}
//Local nSeq		:= 0
Local nK, nX, cTAUX, aArquivos, cArquivo
Private dDtProc	:= Date()
Private cHrProc	:= Time()
Private cEol	:= Chr(13) + Chr(10)
Private cQualEmp, cQualArq

MakeDir("edi01")
MakeDir("edi01\gko")
MakeDir("edi01\gko\ok")
MakeDir("edi01\gko\log")

//———————————————————————————————————————————————————————————————————————————————
// Processamento das empresas e filiais
//———————————————————————————————————————————————————————————————————————————————
for nX := 1 to Len(aEmp)

	aArquivos	:= Directory(cLocDir + "FRNC*.TXT")

	//———————————————————————————————————————————————————————————————————————————————
	// Inicia a abertura do ambiente somente se houver arquivos a serem processados
	//———————————————————————————————————————————————————————————————————————————————
	if Len(aArquivos) > 0

		//———————————————————————————————————————————————————————————————————————————————
		// Abertura do ambiente
		//———————————————————————————————————————————————————————————————————————————————
		WfPrepEnv(aEmp[nX, 1], aEmp[nX, 2], "U_",, "COM")

		for nK := 1 to Len(aFiles)
		
			if Select(aFiles[nK]) = 0
				ChkFile(aFiles[nK])
			endif
			
		next

		//———————————————————————————————————————————————————————————————————————————————
		// Criação de arquivo log de processamento
		//———————————————————————————————————————————————————————————————————————————————
		/*do while .T.
			cLogFile := "edi01\gko\log\NCF_" + dTOs(date()) + "_" + StrZero(++nSeq, 4) + ".LOG"
			if !File(cLogFile)
				exit
			endif
		enddo
		nHdl := fCreate(cLogFile)
		if nHdl == -1
			ConOut("Ocorreu um problema ao tentar criar o arquivo " + cLogFile)
		endif
		*/
			
		cQualEmp	:= AllTrim(SM0->M0_NOME) + " / " + AllTrim(SM0->M0_FILIAL)

		//———————————————————————————————————————————————————————————————————————————————
		// Inicia o tratamento dos arquivos encontrados
		//———————————————————————————————————————————————————————————————————————————————
		for nK := 1 to Len(aArquivos)

			cQualArq	:= aArquivos[nK,1]
			cArquivo 	:= cLocDir + aArquivos[nK,1]
			
			//Cria tabela auxiliar para importacao
			cTAUX := CriaTrab(aStruTrb, .T.)
			//dbUseArea(.T.,"DBFCDX", cTAUX, "TAUX", .T.)
			dbUseArea(.T., __LocalDriver, cTAUX, "TAUX", .T.)
			
			dbSelectArea("TAUX")
			Append From &cArquivo SDF
			dbGoTop()

			if eof()
			
				fErase(cArquivo)
				
			elseif Substr(TAUX->DETALHE, 66, 14) == SM0->M0_CGC

				if A(aArquivos[nK,1])
					//Copia tabela processada no diretorio OK
					__CopyFile(cArquivo, cLocDir + "ok\" + aArquivos[nK,1])
					if File(cLocDir + "ok\" + aArquivos[nK,1])
						fErase(cArquivo)
					endif
				endif
				
			endif

			//Fecho o arquivo de trabalho e o excluo
			if Select("TAUX") > 0
				TAUX->(dbCloseArea())
			endif
			fErase(cTAUX + OrdBagExt())

		next

		//———————————————————————————————————————————————————————————————————————————————
		// Fecha o arquivo de log do processamento e o envia por e-mail
		//———————————————————————————————————————————————————————————————————————————————
		//fClose(nHdl)
		
		B()

		//———————————————————————————————————————————————————————————————————————————————
		// Encerramento do ambiente                                                     
		//———————————————————————————————————————————————————————————————————————————————
		RpcClearEnv()
	
		ConOut(dTOc(Date()) + " as " + Time() + " -  - Conclusão do processo de importação de conhecimentos de frete (GKO) - Empresa / Filial " + aEmp[nX, 1] + "/" + aEmp[nX, 2])
		
		Sleep(15000)		//Aguarda 15 segundos
		
	endif
	
next

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		A                                                    /@
@type			Static function                                              /@
@date			05/09/2014                                                   /@
@description	Função chamada pela user functOB04. Processa os 
				registros dos arquivos gerados pelo GKO e importa para notas
				de entrada.                                                  /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function A(cArqGKO)
Local lRetFileOk	:= .T.
Local cProd			:= GetMV("BR_GKOPROD", .F., " ")
Local cCodSrv		:= GetMV("BR_GKOSRV",.F.," ")
Local cCdPagPar		:= GetMV("BR_GKOCP", .F., " ")
Local cCNPJEmp		:= SM0->M0_CGC
Local aCodEst		:= {{'AC','12'}, {'AL','27'}, {'AM','13'}, {'AP','16'}, {'BA','29'},;
						{'CE','23'}, {'DF','53'}, {'ES','32'}, {'GO','52'}, {'MA','21'},;
						{'MG','31'}, {'MS','50'}, {'MT','51'}, {'PA','15'}, {'PB','25'},;
						{'PE','26'}, {'PI','22'}, {'PR','41'}, {'RJ','33'}, {'RN','24'},;
						{'RO','11'}, {'RR','14'}, {'RS','43'}, {'SC','42'}, {'SE','28'},;
						{'SP','35'}, {'TO','17'}}
Local aCab, aDet, cDoc, cSerie, dEmissao, cCNPJ, aCodFor, nPosUF, nBICMS, nVICMS, nAICMS,;
		nBICMSST, nVICMSST, nAICMSST, nValor, cInfLog, nI, cCdPag, cCNPJReg, nBISS, nVISS,;
		nAISS, cProduto, cEspecie, cNaturez, nISS, cChvNfe, cTpCTe, cFatura, cMenNota, cIdGKO,;
		lContinua
Private lMsErroAuto		:= .F.
Private lAutoErrNoFile	:= .T.

//Setando a ordem das tabelas
SB1->(dbSetOrder(1))
SF1->(dbSetOrder(1))
SF2->(dbSetOrder(1))
SF4->(dbSetOrder(1))
SE2->(dbSetOrder(6))		//E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO

dbSelectArea("TAUX")
dbGoTop()
do While TAUX->(!eof())

	//———————————————————————————————————————————————————————————————————————————————
	// Inicializando as variáveis de trabalho
	//———————————————————————————————————————————————————————————————————————————————
	aCab 		:= {}
	aDet 		:= {}
	aCodFor 	:= {}
	aNFS 		:= {}
	cCdPag		:= ""
	cDoc		:= ""
	cSerie 		:= ""
	cFatura 	:= ""
	cMenNota 	:= ""
	cProduto 	:= ""
	cEspecie 	:= ""
	cCNPJ 		:= ""
	cCNPJReg 	:= ""
	cChvNfe 	:= ""
	cTpCTe 		:= ""
	cNaturez 	:= ""
	cInfLog 	:= ""
	nValor		:= 0
	nPosUF 		:= 0
	nBICMS 		:= 0
	nVICMS 		:= 0
	nAICMS 		:= 0
	nVICMSST 	:= 0
	nBICMSST 	:= 0
	nAICMSST 	:= 0
	nBISS 		:= 0
	nVISS 		:= 0
	nAISS 		:= 0
	nISS 		:= 0
	dEmissao	:= cTOd("")
	cIdGKO		:= TAUX->IDNC
	lContinua	:= .T.
	
	do while TAUX->(!eof() .and. IDNC == cIdGKO)

		//———————————————————————————————————————————————————————————————————————————————
		// informacoes do conhecimento (NC), segundo layout GKO exportacao em arquivo
		//———————————————————————————————————————————————————————————————————————————————
		if TAUX->TPREGISTRO == "700"		
			lExist700	:= .T.
			cEspecie	:= IIf((Substr(TAUX->DETALHE, 01, 02) == "07"),"NFS",IIf((Substr(TAUX->DETALHE, 01, 02) == "57"),"CTE","CTRC"))
			cDoc		:= StrZero(Val(Substr(TAUX->DETALHE, 5, 12)), 9)
			cSerie		:= PadR(Substr(TAUX->DETALHE, 17, 5), 3)
			dEmissao	:= cTOd(Substr(TAUX->DETALHE, 90, 10))
			cCNPJ		:= Substr(TAUX->DETALHE, 23, 14)
			nValor		:= Val(Substr(TAUX->DETALHE, 106, 15)) / 100
                        //nISS		:= Val(Substr(TAUX->DETALHE, 121, 15)) / 100
			nISS		:= Val(Substr(TAUX->DETALHE, 168, 16)) / 100 //->Alterado 20/06/22 - Evandro
			cInfLog		:= "NF " +AllTrim(cDoc) + "/" + AllTrim(cSerie) + ", CNPJ " + Transform(cCNPJ, "@R 99.999.999/9999-99")
			cCNPJReg	:= Substr(TAUX->DETALHE, 66, 14)
			cFatura		:= cValtoChar(Val(Substr(TAUX->DETALHE,141,12)))
			cChvNfe		:= Substr(TAUX->DETALHE, 184, 44)
			cTpCTe		:= iif(AllTrim(cEspecie) == "CTE", "N", " ") 
			
			SA2->(dbSetOrder(3))
			if SA2->(dbSeek(xFilial("SA2") + cCNPJ))
				aCodFor	:= {SA2->A2_COD, SA2->A2_LOJA, SA2->A2_COND, SA2->A2_EST}
				nPosUF	:= aScan(aCodEst, {|x|, x[1] = aCodFor[4]})
			endif
			
		//———————————————————————————————————————————————————————————————————————————————
		// informacoes dos impostos (NC), segundo layout GKO exportacao em arquivo
		//———————————————————————————————————————————————————————————————————————————————
		elseif TAUX->TPREGISTRO == "720"

			lExist720	:= .T.
			cProduto 	:= cProd

			//———————————————————————————————————
			// ICMS
			//———————————————————————————————————
			if Substr(TAUX->DETALHE, 1, 3) == "001"
				nBICMS		:= Val(Substr(TAUX->DETALHE, 04, 15)) / 100
				nVICMS		:= Val(Substr(TAUX->DETALHE, 27, 15)) / 100
				nAICMS		:= Val(Substr(TAUX->DETALHE, 19, 8)) / 100

			//———————————————————————————————————
			// ICMS-ST
			//———————————————————————————————————
			elseif Substr(TAUX->DETALHE, 1, 3) == "003"
				nBICMSST	:= Val(Substr(TAUX->DETALHE, 04, 15)) / 100
				nVICMSST	:= Val(Substr(TAUX->DETALHE, 27, 15)) / 100
				nAICMSST	:= Val(Substr(TAUX->DETALHE, 19, 8)) / 100
				if nVICMSST == 0
					nBICMSST := 0
				endif

			//———————————————————————————————————
			// Diferencial de alíquota
			//———————————————————————————————————
			elseif Substr(TAUX->DETALHE, 1, 3) == "004"
				nBICMSST	:= Val(Substr(TAUX->DETALHE, 4, 15)) / 100
				nVICMSST	:= Val(Substr(TAUX->DETALHE, 27, 15)) / 100
				nAICMSST	:= Val(Substr(TAUX->DETALHE, 19, 8)) / 100
			
			//———————————————————————————————————
			// ISS
			//———————————————————————————————————
			elseif Substr(TAUX->DETALHE, 1, 3) == "008"
				cProduto 	:= cCodSrv
				nVISS		:= Val(Substr(TAUX->DETALHE, 27, 15)) / 100
				nBISS		:= Val(Substr(TAUX->DETALHE, 4, 15)) / 100
				nAISS		:= Val(Substr(TAUX->DETALHE, 19, 8)) / 100
				if nVISS == 0
					cNaturez	:= "40100206"
				endif
			endif

			if !SB1->(dbSeek(xFilial("SB1") + cProduto)) .or. Empty(cProduto)
			
				GrvLog("2", cProduto, "Impossível continuar. Produto '" + cProduto + "' cadastrado no parâmetro BR_GKOPROD não encontrado!")
				lContinua := .F.
			
			else
			
				if !SF4->(dbSeek(xFilial("SF4") + SB1->B1_TE)) .or. Empty(SB1->B1_TE)
				
					GrvLog("2", cProduto, "Impossível continuar. O TES de entrada padrão para o produto '" + cProduto + "' não está cadastrado!")
					lContinua := .F.
				
				endif
			
			endif

		elseif TAUX->TPREGISTRO == "740"			//informacoes das NF associadas `a NC, segundo layout GKO exportacao em arquivo
			
			aAdd(aNFS, {strzero(val(AllTrim(Substr(TAUX->DETALHE, 15, 12))), 9), Substr(TAUX->DETALHE, 27, 3)})
			
		endif

		TAUX->(dbSkip())
			
	enddo
   
	//———————————————————————————————————————————————————————————————————————————————
	// para continuar 
	//———————————————————————————————————————————————————————————————————————————————
	if lContinua .and. Len(aCodFor) > 0
		
      //comparo o CNPJ do registro 700 com o CNPJ do sigamat.emp
		if cCNPJEmp == cCNPJReg
	
		   //verificando se encontrou o fornecedor
			if !Empty(aCodFor[1] + aCodFor[2])
				    
			    //Identificando a condicao de pagamento a ser utilizada no conhecimento de frete
				cCdPag 	:= iif(Empty(aCodFor[3]), cCdPagPar, aCodFor[3])

				//Verificando se a nota de conhecimento ou título ja está gravado
				if !SF1->(dbSeek(xFilial("SF1") + cDoc + cSerie + aCodFor[1] + aCodFor[2])) .and.;
					!SE2->(dbSeek(xFilial("SE2") + aCodFor[1] + aCodFor[2] + cEspecie + cDoc))
				
					SA2->(dbSetOrder(1))
					SA2->(dbSeek(xFilial("SA2") + aCodFor[1] + aCodFor[2]))
				
					if Len(aNFS) > 0
		
						// Crio Mensagem para dados adicionas da NFE
						for nI:=1 to Len(aNFS)	
							cMenNota := "NF ORI:" + aNFS[nI][1] + "-" + AllTrim(aNFS[nI,2]) + "/FT:" + cFatura
						Next
						
						//Quando espécie for CTE, deve existir chave da nota e faço algumas verificações
						if cEspecie == "CTE"
												
							//Verifico a composicao da chave
							if Substr(cChvNfe, 3, 4) != Substr(dTOs(dEmissao), 3, 4)
								lContinua	:= .F.
								if !empty(cInfLog)
									GrvLog("2", cInfLog, "Não foi importado. Motivo: Foi encontrada divergência entre o mês e ano de emissão da nota fiscal informada e o encontrada na Chave NFe.")
								endif
									
							elseif Substr(cChvNfe, 7, 14) != cCNPJ
								lContinua	:= .F.
								if !empty(cInfLog)
									GrvLog("2", cInfLog, "Não foi importado. Motivo: Foi encontrada divergência entre o CNPJ do emitente e o encontrado na chave da NFe.")
								endif
					
							elseif Substr(cChvNfe, 21, 2) != AModNot(cEspecie)
								lContinua	:= .F.
								if !empty(cInfLog)
									GrvLog("2", cInfLog, "Não foi importado. Motivo: Foi encontrada divergência entre a espécie/modelo da nota fiscal informada e a encontrada na Chave NFe.")
								endif
						
							elseif Substr(cChvNfe, 23, 3) != StrZero(Val(cSerie), 3)
								lContinua	:= .F.
								if !empty(cInfLog)
									GrvLog("2", cInfLog, "Não foi importado. Motivo: Foi encontrada divergência entre a série da nota fiscal informada e a encontrada na Chave NFe.")
								endif
									
							elseif Substr(cChvNfe, 26, 9) != StrZero(Val(cDoc), 9)
								lContinua	:= .F.
								if !empty(cInfLog)
									GrvLog("2", cInfLog, "Não foi importado. Motivo: Foi encontrada divergência entre o número da nota fiscal informada e a encontrada na Chave NFe.")
								endif
						
							elseif nPosUF > 0 .and. Substr(cChvNfe, 1, 2) != aCodEst[nPosUF,2]
								lContinua	:= .F.
								if !empty(cInfLog)
									GrvLog("2", cInfLog, "Não foi importado. Motivo: Foi encontrada divergência entre o estado da nota fiscal informada e o encontrada na Chave NFe.")
								endif
							endif

						endif
							
						if lContinua
						
							aCab := {	{"F1_TIPO",		"N",	  			NIL},;
										{"F1_FORMUL",	"N",				NIL},;
										{"F1_DOC",		cDoc,				.T.},;
										{"F1_SERIE",	cSerie,	 			NIL},;
										{"F1_EMISSAO",	dEmissao, 			NIL},;
										{"F1_FORNECE",	aCodFor[1],			NIL},;
										{"F1_LOJA",		aCodFor[2],			NIL},;
										{"F1_ESPECIE",	cEspecie, 			NIL},;
										{"F1_EST",		aCodFor[4],			NIL},;
										{"F1_CHVNFE",	cChvNfe,	  		NIL},;
										{"F1_TPCTE",	cTpCTe,	  			NIL},;
										{"F1_COND",		cCdPag,				NIL}}
							
							if !Empty(cNaturez)
								aAdd(aCab, {"E2_NATUREZ",	cNaturez,	 	NIL})
							endif
	
							aAdd(aDet, {{"D1_ITEM",		StrZero(Len(aDet) + 1, 4, 0),			NIL},;
										{"D1_COD",		cProduto,		 						NIL},;
										{"D1_CONTA",	SB1->B1_CONTA,							NIL},;
										{"D1_QUANT",	1,		 		 		 				NIL},;
										{"D1_VUNIT",	nValor+nISS,							NIL},;
										{"D1_TOTAL",	nValor+nISS,							NIL},;
										{"D1_TES",		SB1->B1_TE,								NIL},;
										{"D1_BASEICM",	nBICMS,									NIL},;
										{"D1_PICM",		nAICMS,									NIL},;
										{"D1_VALICM",	nVICMS,									NIL},; 
										{"D1_BASEISS",	Iif(nVISS > 0,0,nBISS),					NIL},;
										{"D1_ALIQISS",	Iif(nVISS > 0,0,nAISS),					NIL},;
										{"D1_VALISS",	Iif(nVISS > 0,0,nISS),					NIL},;
										{"D1_ICMSRET",	nVICMSST,				 				NIL},;
										{"D1_BRICMS",	nBICMSST,								NIL},;
										{'D1_X_MNOT',	cMenNota,								NIL},;
										{"D1_CLASFIS",	SB1->B1_ORIGEM + SF4->F4_SITTRIB,		NIL}})
		
						endif
			         
					else
					
						lContinua	:= .F.
						if !empty(cInfLog)
							GrvLog("2", cInfLog, "Não foi importado. Motivo: Sem registros tipo 740 no arquivo texto, conforme layout GKO")
						endif
						
					endif
			
				else
			
					lContinua 	:= .F.
					if !empty(cInfLog)
						if SF1->(dbSeek(xFilial("SF1") + cDoc + cSerie + aCodFor[1] + aCodFor[2]))
							//GrvLog("ALERTA", cInfLog, "Não foi importado. Motivo: Conhecimento já está gravado no Protheus")
						else
							GrvLog("2", cInfLog, "Não foi importado. Motivo: O já existe um titulo a pagar com a chave da nota")
						endif
					endif
					
				endif
		
			else
			    
				lContinua	:= .F.
				if !empty(cInfLog)
					GrvLog("2", cInfLog, "Não foi importado. Motivo: Fornecedor não esta cadastrado.")
				endif
				
			endif
	
		else

			lContinua	:= .F.

		endif

    	//———————————————————————————————————————————————————————————————————————————————
		// Verifica se tabela de Fornecedor pode ser travada
		//———————————————————————————————————————————————————————————————————————————————
		if lContinua
			nCont := 0

			SA2->(dbSetOrder(1))
			if SA2->(dbSeek(xFilial("SA2") + aCodFor[1] + aCodFor[2]))

				do while nCont++ <= 5
					if SA2->(RecLock("SA2", .F.))
						SA2->(MsUnlock())
						exit
					else
						lContinua := .F.
						Sleep(10000)		//aguarda um 10 segundos
					endif
				enddo
				
				if !lContinua
					lRetFileOk := .F.		//manter o arquivo para proximo processamento
					GrvLog("2", cInfLog, "Não foi importado. Cadastro de fornecedor está sendo utilizado por outro processo.")
				endif
			
			else
				lContinua	:= .F.		//manter o arquivo para proximo processamento
				GrvLog("2", cInfLog, "Fornecedor não encontrado.")

			endif

		endif  

	   	//———————————————————————————————————————————————————————————————————————————————
		// Se lContinua verdadeiro, realiza a inclusão da NC por msexecauto
		//———————————————————————————————————————————————————————————————————————————————
		if lContinua
	
			//Begin Transaction
				
				dbSelectArea("SF1")
				lMsErroAuto		:= .F.
				lAutoErrNoFile	:= .T.
		
				//-- Chamada da rotina automatica
				MsExecAuto({|x, y, z| MATA103(x, y, z)}, aCab, aDet, 3)
		
				//-- Verifica se houve algum erro
				If lMsErroAuto
					lRetFileOk := .F.	//manter o arquivo para proximo processamento
					GrvLog("2", cInfLog, "Não foi importado. Detalhes do erro da importação da nota:", GetAutoGRLog()) // __aErrAuto)
					//DisarmTransaction()
					
				else
	
					/*gravo o numero NC nas notas de saida para posterior validacao
					for nI:=1 to Len(aNFS)
						if SF2->(dbSeek(xFilial("SF2") + aNFS[nI, 1] + aNFS[nI, 2]))
							SF2->(RecLock("SF2", .F.))
							SF2->F2_X_GKONC	:= cDoc
							SF2->F2_X_GKOSR	:= cSerie
							SF2->(MsUnlock())
						endif
					next*/

					//Gravando log de processamento
					GrvLog("0", cInfLog, "IMPORTADO COM SUCESSO")
					
				endif
			
			//End Transaction
			
		endif
	        
	endif

	dbSelectArea("TAUX")

enddo

if !lExist700 .or. !lExist720

	GrvLog("2", cInfLog, "Arquivo sem dados para importação")

endif

Return(lRetFileOk)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		B                                                    /@
@type			Static function                                              /@
@date			05/09/2014                                                   /@
@description	Função chamada pela user functOB04. Envia o log de
				processamento para e-mails previamente cadastrados no parame-
				tro BR_MAILGKO                                               /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function B()
Local cDestinat	:= AllTrim(GetMV("BR_MAILGKO", .F., "equipe.ti@gamaitaly.com.br"))
Local cLinkLogo	:= AllTrim(GetMV("BR_LNKLOGO", .F., "https://sweb.gamaitaly.com.br/images/LogoGamaPeq.jpg"))
Local cAssunto	:= "Brasitech/" + Lower(AllTrim(SM0->M0_FILIAL)) + " - Log de importação de conhecimentos de frete GKO FRNC em " + dTOc(dDtProc) + " às " + cHrProc
Local cQuery	:=	"SELECT R_E_C_N_O_ REGISTRO " +;
						"FROM " + RetSqlName("ZZ9") + " ZZ9 " +;
						"WHERE ZZ9.ZZ9_FILIAL = '" + xFilial("ZZ9") + "' " +;
								"AND ZZ9.ZZ9_TIPO = '2' " +;
								"AND ZZ9.ZZ9_DATA = '" + dTOs(dDtProc) + "' " +;
								"AND ZZ9_PROC = 'GKO-FRNC' " +;
								"AND ZZ9.D_E_L_E_T_= ' ' " +;
						"ORDER BY ZZ9_INDPRO "
//								"AND ZZ9.ZZ9_HORA = '" + cHrProc + "' " +;
Local cHtml, lInverte


//————————————————————————————————————————————————————————————————————————————
// Iniciando a criação do formato html
//————————————————————————————————————————————————————————————————————————————
cHtml := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">' +;
		'<html xmlns="http://www.w3.org/1999/xhtml">' +;
		'<head> ' +;
		'<meta content="en-us" http-equiv="Content-Language" />' +;
		'<meta content="text/html; charset=utf-8" http-equiv="Content-Type" />' +;
		'<style type="text/css">' +;
		'.style1 {' +;
		'	font-family: Calibri;' +;
		'	font-size: small;' +;
		'	color: #050538;' +;
		'}' +;
		'.style2 {' +;
		'	font-size: x-small;' +;
		'	background-color: #E9E9E9;' +;
		'	font-family: Calibri;' +;
		'}' +;
		'.style3 {' +;
		'	font-size: x-small;' +;
		'	font-family: Calibri;' +;
		'}' +;
		'.style4 {' +;
		'	font-size: x-small;' +;
		'	font-family: Calibri;' +;
		'	color: #FFFFFF;' +;
		'	background-color: #5B5B5B;' +;
		'}' +;
		'.style5 {' +;
		'	font-size: x-small;' +;
		'	background-color: #E9E9E9;' +;
		'	font-family: Calibri;' +;
		'	text-align: right;' +;
		'}' +;
		'.style6 {' +;
		'	font-size: x-small;' +;
		'	font-family: Calibri;' +;
		'	text-align: right;' +;
		'}' +;
		'.style7 {' +;
		'	font-size: x-small;' +;
		'	font-family: Calibri;' +;
		'	color: #FFFFFF;' +;
		'	background-color: #5B5B5B;' +;
		'	text-align: right;' +;
		'}' +;
		'.style8 {' +;
		'	font-family: Arial, Helvetica, sans-serif;' +;
		'	font-size: x-small;' +;
		'}' +;
		'</style>' +;
		'</head>' +;
		'<body>' +;
		'<p class="style8">' +;
		'<img src="' + cLinkLogo + '"></p><br>' +;
		'<p class="style1" style="mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin; mso-ansi-language: PT-BR; mso-fareast-language: EN-US; mso-bidi-language: AR-SA">'

//———————————————————————————————————————————————————————————————————————————————
// Verificando a existencia da area Temporaria
//———————————————————————————————————————————————————————————————————————————————
if Select("TMPLOG") > 0
	TMPLOG->(dbCloseArea())
endif

//———————————————————————————————————————————————————————————————————————————————
// Criando a tabela temporaria
//———————————————————————————————————————————————————————————————————————————————
dbUseArea(.T., "TOPCONN", TcGenQRY(,,cQuery), "TMPLOG", .F., .T.)

dbSelectArea("TMPLOG")
TMPLOG->(dbGoTop())
if TMPLOG->(!eof())

	cHtml += 'Inconsistências no processo de importação de conhecimentos de frete, processo GKO-FRNC executado pela rotina DKTJOB04. <br>Filial '+AllTrim(SM0->M0_FILIAL)+'.<br>Leitura de arquivos "edi01\gko\FRNC*.TXT".</p>'
		
	cHtml += '<table style="width: 100%">'
	cHtml += '	<tr>'
	cHtml += '		<td class="style4" style="width: 21%">Chave</td>'
	cHtml += '		<td class="style4" style="width: 14%">Arquivo</td>'
	cHtml += '		<td class="style4" style="width: 65%">Inconsistência</td>'
	cHtml += '	</tr>'
	
	lInverte := .T.

	do while TMPLOG->(!eof())
		
		ZZ9->(dbGoTo(TMPLOG->REGISTRO))

		lInverte := !lInverte
			
		cHtml += '	<tr>'
		cHtml += '		<td class="' + iif(lInverte, 'style3', 'style2') + '" style="width: 21%">' + AllTrim(ZZ9->ZZ9_CHAVE) + '</td>'
		cHtml += '		<td class="' + iif(lInverte, 'style3', 'style2') + '" style="width: 14%">' + AllTrim(ZZ9->ZZ9_INDPRO) + '</td>'
		cHtml += '		<td class="' + iif(lInverte, 'style3', 'style2') + '" style="width: 65%">' + ZZ9->ZZ9_LOG + '</td>'
		cHtml += '	</tr>'

		TMPLOG->(dbSkip())

	enddo

	cHtml += '</table>'
	
else

	cHtml += 'Não foram encontradas inconsistências no processo de importação de conhecimentos de frete, processo GKO-FRNC executado pela rotina DKTJOB04.<br>Filial '+AllTrim(SM0->M0_FILIAL)+'.<br>Leitura de arquivos "edi01\gko\FRNC*.TXT".</p>'

endif

cHtml += '</body>'
cHtml += '</html>'

U_GISendMail(cDestinat,, cAssunto, cHtml)
	
if Select("TMPLOG") > 0
	TMPLOG->(dbCloseArea())
endif

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		GRVLOG                                                       /@
@type			Static function                                              /@
@date			06/09/2014                                                   /@
@description	Função chamada pela static functOB04A. Grava log de
				processamento na tabela ZZ9                                  /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function GrvLog(cTipoOcor, cChave, cOcorrencia, aLogErro)
Local cLog		:= cOcorrencia + cEol
Local nX

if aLogErro != Nil .and. Len(aLogErro) > 0
	for nX := 1 To Len(aLogErro)
		cLog += aLogErro[nX] + cEol
	next
endif

ZZ9->(RecLock("ZZ9",.T.))
ZZ9->ZZ9_FILIAL		:= xFilial("ZZ9")
ZZ9->ZZ9_ROTINA		:= FunName()
ZZ9->ZZ9_PROC		:= "GKO-FRNC"
ZZ9->ZZ9_TIPO		:= cTipoOcor
ZZ9->ZZ9_CHAVE		:= cChave
ZZ9->ZZ9_INDPRO		:= Lower(cQualArq)
ZZ9->ZZ9_DATA		:= dDtProc
ZZ9->ZZ9_HORA		:= cHrProc
ZZ9->ZZ9_RESUMO		:= cOcorrencia
ZZ9->ZZ9_LOG		:= cLog
ZZ9->(MsUnlock())

Return()
