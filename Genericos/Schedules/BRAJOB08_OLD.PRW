#include "protheus.ch"
#include "ap5mail.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		BRAJOB08                                                      /@
@type				User function                                                 /@
@date				04/05/2015                                                    /@
@description	Rotina para uso em schedule.
					Job para importacao de informa鋏esGNRE. Cria t?tulo a
					pagar e o baixa em banco/agencia/conta parametrizado.         /@
@author			Adalberto Moreno Batista - Op鈬o Um Consultoria               /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
Nome do arquivo:	ST-99999999999999-aammdd-???.txt
ST-				String fixa
99999999999999	Numero do CNPJ da empresa Brasitech
-					String fixa
aammdd			Ano, m黌 e dia do arquivo
-					String fixa
???				String para diferencia鈬o dos arquivos dentro do mesmo dia. Pode 
					ser um n?mero sequencial ou hora da gera鈬o do arquivo
.txt				Extens縊 do arquivo texto

Campo					Tam	Inicio
Nro Nota Fiscal	9		1	N?mero da nota fiscal
S駻ie Nota Fiscal	3		10	S駻ie da nota fiscal
Valor					12		13	Valor do imposto a ser pago. Este campo dever? 
									considerar duas casas decimais. Exemplo: Para a 
									representa鈬o do valor R$ 1.000,00, enviar a 
									string "000000100000".
Data da baixa		8		25	Data da baixa no formato AAAAMMDD
Valor pago			12,2	33	Valor da baixa. Este campo dever? considerar duas 
									casas decimais. Exemplo: Para a representa鈬o do 
									valor R$ 1.000,00, enviar a string "000000100000".
Banco					3		45	N?mero do banco onde o pagamento foi efetuado
Agencia				5		48	N?mero da ag麩cia onde o pagamento foi efetuado
Conta					10		53	N?mero da conta corrente onde o pagamento foi efetuado
DV conta				1		63	Digito verificador da conta corrente onde o pagamento 
								foi efetuado
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function BRAJOB08()
Local aFiles	:= {"SA2", "SA6", "SED", "SE2", "SE5", "SF2"}
Local cEmp		:= "01"					//Brasitech
Local aFil		:= {"03", "08"}		//Filiais 03-S縊 Paulo e 08-Loja
Local cLocDir	:= "edi01\finnet\"
Local aStruLog	:= {{"LINHA",		"C", 200, 0}}
Local aStruTrb	:= {{"DETALHE",	"C", 100, 0}}
Local nK, nX, cTLOG, cTAUX, aArquivos, cArquivo

//__LOCALDRIVER := "DBFCDX"

MakeDir("edi01")
MakeDir("edi01\finnet")
MakeDir("edi01\finnet\ok")
MakeDir("edi01\finnet\log")

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Abertura do ambiente
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
for nX := 1 to Len(aFil)

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Abertura do ambiente
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	WfPrepEnv(cEmp, aFil[nX], "U_BRAJOB08",, "FIN")
	
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Leio os arquivos da respectiva filial
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	aArquivos	:= Directory(cLocDir + "ST-" + AllTrim(SM0->M0_CGC) + "*.TXT")
	
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Inicia a abertura do ambiente somente se houver arquivos a serem processados
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	if Len(aArquivos) > 0
		
		for nK := 1 to Len(aFiles)
			
			if Select(aFiles[nK]) == 0
				ChkFile(aFiles[nK])
			endif
			
		next
		
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		// Inicia o tratamento dos arquivos encontrados
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		//Cria tabela de log
		cTLOG := CriaTrab(aStruLOG, .T.)
		dbUseArea(.T.,"DBFCDX", cTLOG, "TLOG", .T.)
		
		for nK := 1 to Len(aArquivos)
			
			cArquivo := cLocDir + aArquivos[nK, 1]
			
			//Cria tabela auxiliar para importacao
			cTAUX := CriaTrab(aStruTRB, .T.)
			dbUseArea(.T.,"DBFCDX", cTAUX, "TAUX", .T.)
			
			dbSelectArea("TAUX")
			Append From &cArquivo SDF
			dbGoTop()
			
			GrvLog("'s referente ao arquivo " + aArquivos[nK,1] + ", disponibilizado pela FINNET")
			GrvLog("")
			
			BRAJOB08A()
			
			//Copia tabela processada no diretorio OK
			__CopyFile(cArquivo, cLocDir + "ok\" + aArquivos[nK,1])
			fErase(cArquivo)
			
			//Fecho o arquivo de trabalho e o excluo
			if Select("TAUX") > 0
				TAUX->(dbCloseArea())
			endif
			fErase(cTAUX + OrdBagExt())
			
		next
		
		//Envia e-mail com o resultado do processamento
		BRAJOB08B()
		
		//Fecho o arquivo de log e o excluo
		if Select("TLOG") > 0
			TLOG->(dbCloseArea())
		endif
		fErase(cTLOG + OrdBagExt())
		
	endif
	
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Encerramento do ambiente
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	RpcClearEnv()
	
	ConOut(dTOc(Date()) + " as " + Time() + " - BRAJOB08 - Importa鈬o de registrosGNRE, enviados pela FINNET. Inclus縊 e baixa de t?tulo - Empresa "+cEmp+" / Filial "+aFil[nX])
	
next	
	
Return()
	

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		BRAJOB08A                                                     /@
@type				Static function                                               /@
@date				04/05/2015                                                    /@
@description	Fun鈬o chamada pela user function BRAJOB08. Processa os
					registros de  e importa para titulos a pagar.             /@
@author			Adalberto Moreno Batista - Op鈬o Um Consultoria               /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function BRAJOB08A()
Local cDoc, cSerie, nValor, dDtBaixa, nVlPago, cInfLog, aTitulo, aBaixa, nK,;
		cFornec, cLoja, cBanco, cAgencia, cConta, nValDifal, cNatureza,;
		cCCusto, cHist, cSerie1, cSerie2
Local cInfTit 		:= GetMV("BR_FIN", .F., "ESTADO#00#237#33928#2601-8")
Local lContinua	:= .T.
Private lMsErroAuto	:= .F.

cInfTit := StrTran(cInfTit, "#", chr(13) + chr(10))
for nK := 1 to MlCount(cInfTit)
	if nK ==  1
		cFornec	:= PadR(MemoLine(cInfTit,, 1), 8)
	elseif nK == 2
		cLoja		:= PadR(MemoLine(cInfTit,, 2), 2)
	elseif nK == 3
		cBanco	:= PadR(MemoLine(cInfTit,, 3), 3)
	elseif nK == 4
		cAgencia	:= PadR(MemoLine(cInfTit,, 4), 5)
	elseif nK == 5
		cConta	:= PadR(MemoLine(cInfTit,, 5), 10)
	endif
next

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Seta as tabelas na ordem necessaria para o processamento
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
SA2->(dbSetOrder(1))		//A2_FILIAL, A2_COD, A2_LOJA
SA6->(dbSetOrder(1))		//A6_FILIAL, A6_COD, A6_AGENCIA, A6_NUMCON

if SA2->(!dbSeek(xFilial("SA2") + cFornec + cLoja))
	GrvLog("O processo n縊 ser? iniciado, pois o fornecedor n縊 est? cadastrado. Solicite que o depto de TI verifique o param BR_GNREINF.")
	lContinua := .F.
endif

if SA6->(!dbSeek(xFilial("SA6") + cBanco + cAgencia + cConta))
	GrvLog("O processo n縊 ser? iniciado, pois o banco, agencia e conta n縊 est縊 cadastrados. Solicite que o depto de TI verifique o param BR_GNREINF.")
	lContinua := .F.
endif

if lContinua
	
	dbSelectArea("TAUX")
	dbGoTop()
	do while TAUX->(!eof())
		
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		// Busca dados na linha lida
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		cDoc		:= Substr(TAUX->DETALHE, 1, 9)											//Nro Nota Fiscal	9		1	N?mero da nota fiscal
		cSerie1	:= PadR(AllTrim(Str(Val(Substr(TAUX->DETALHE, 10, 3)))), 3)		//S駻ie Nota Fiscal	3		10	S駻ie da nota fiscal - sem zeros a esquerda
		cSerie2	:= StrZero(Val(Substr(TAUX->DETALHE, 10, 3)), 3)					//S駻ie Nota Fiscal	3		10	S駻ie da nota fiscal - com zeros a esquerda
		nValor	:= Val(Substr(TAUX->DETALHE, 13, 12)) / 100							//valor					12		13	Valor do imposto a ser pago. Este campo dever? considerar duas casas decimais. Exemplo: Para a representa鈬o do valor R$ 1.000,00, enviar a string "000000100000".
		dDtBaixa	:= sTOd(Substr(TAUX->DETALHE, 25, 8))									//Data da baixa		8		25	Data da baixa no formato AAAAMMDD
		nVlPago	:= Val(Substr(TAUX->DETALHE, 33, 14)) / 100							//Valor pago			12,2	33	Valor da baixa. Este campo dever? considerar duas casas decimais. Exemplo: Para a representa鈬o do valor R$ 1.000,00, enviar a string "000000100000".
		cCodRec	:= Substr(TAUX->DETALHE, 66, 6)											/*C?digos dos impostos: 000004 - ST (RJ)
																																		000059 - DIFAL (RJ)
																																		100099 - ST
																																		100102 - DIFAL*/
		/*	
		cBanco	:= Substr(TAUX->DETALHE, 47, 3)											//Banco					3		45	N?mero do banco onde o pagamento foi efetuado
		cAgencia	:= Substr(TAUX->DETALHE, 50, 5)											//Agencia				5		48	N?mero da ag麩cia onde o pagamento foi efetuado
		cConta	:= Substr(TAUX->DETALHE, 55, 10)											//Conta					10		53	N?mero da conta corrente onde o pagamento foi efetuado
		cDV		:= Substr(TAUX->DETALHE, 65, 1)											//DV conta				1		63	Digito verificador da conta corrente onde o pagamento foi efetuado
		*/
		
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		// Seta as tabelas na ordem necessaria para o processamento
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		SA2->(dbSetOrder(1))		//A2_FILIAL, A2_COD, A2_LOJA
		SA6->(dbSetOrder(1))		//A6_FILIAL, A6_COD, A6_AGENCIA, A6_NUMCON
		SE2->(dbSetOrder(1))		//E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA
		SF2->(dbSetOrder(1))		//F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, F2_TIPO
		CD2->(dbSetorder(1))    //CD2_FILIAL, CD2_TPMOV, CD2_SERIE, CD2_DOC, CD2_CODCLI, CD2_LOJCLI, CD2_ITEM, CD2_CODPRO, CD2_IMP
		
		SA2->(dbSeek(xFilial("SA2") + cFornec + cLoja))
		SA6->(dbSeek(xFilial("SA6") + cBanco + cAgencia + cConta))
		
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		// Localiza a NF. Tentativa sem e com zeros ? esquerda
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		cSerie := ""
		if SF2->(dbSeek(xFilial("SF2") + cDoc + cSerie1))
			lContinua 	:= .T.
			cSerie		:= cSerie1
		elseif SF2->(dbSeek(xFilial("SF2") + cDoc + cSerie2))
			lContinua 	:= .T.
			cSerie		:= cSerie2
		else
			lContinua	:= .F.
		endif
		
		cInfLog		:= "Documento " + cDoc + ", s駻ie " + cSerie + " "
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		// Continua se localizada a NF
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		if lContinua
				
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			// Verifica o tipo do imposto, se ST ou DIFAL      
			// adicionado 000005 21/08 chamado 9884
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			if cCodRec $ "000059/100102/000005/003867/100099"		//DIFAL
	
				nValDifal := 0
				CD2->(dbSeek(xFilial("CD2") + "S" + cSerie + cDoc))
				do while CD2->(!eof() .and. CD2_FILIAL + CD2_TPMOV + CD2_SERIE + CD2_DOC == xFilial("CD2")+ "S" + cSerie + cDoc)
					if CD2->CD2_IMP == "CMP   "
						nValDifal += CD2->(CD2_VDDES + CD2_VFCP)
					endif
					CD2->(dbSkip())
				enddo
            
				cNatureza 	:= "402007113"
				cCCusto	 	:= "1071"
				cHist			:= "FINNET INTEGRACAO  - DIFAL"
				lContinua 	:= (nValDifal == nValor)
				
	
			else		//ST
			
				cNatureza 	:= "402007101"
				cCCusto	 	:= ""
				cHist			:= "FINNET INTEGRACAO  - ICMS-ST"
				lContinua 	:= (SF2->F2_ICMSRET == nValor)
			
			endif

			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			// Verifica se continua o processo
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			if lContinua
				
				if SE2->(!dbSeek(xFilial("SE2") + SF2->F2_SERIE + SF2->F2_DOC + " ICM" + SA2->A2_COD + SA2->A2_LOJA))
					
					aTitulo 	:= {	{"E2_PREFIXO",	cSerie,							Nil},;
										{"E2_NUM",		cDoc,								Nil},;
										{"E2_PARCELA",	"",								Nil},;
										{"E2_TIPO",		"ICM",							Nil},;
										{"E2_FORNECE",	SA2->A2_COD,					Nil},;
										{"E2_LOJA",		SA2->A2_LOJA,	  				Nil},;
										{"E2_NOMFOR" ,	SA2->A2_NREDUZ, 				Nil},;
										{"E2_NATUREZ",	cNatureza,						Nil},;
										{"E2_EMISSAO",	dDtBaixa,						Nil},;
										{"E2_VENCTO",	dDtBaixa,			   		Nil},;
										{"E2_VENCREA",	DataValida(dDtBaixa),		Nil},;
										{"E2_VALOR",	nValor,							Nil},;
										{"E2_DIRF", 	"2",								Nil},;
										{"E2_CCD", 		cCCusto,							Nil},;
										{"E2_HIST",		cHist,							Nil}}
					
					lMsErroAuto	:= .F.
					
					MsExecAuto({ |x,y,z| FINA050(x,y,z) }, aTitulo,, 3)
					
					if lMsErroAuto
						
						DisarmTransaction()
						GrvLog(cInfLog + "n縊 ser? importado. Motivo: Ocorr麩cia de erro no msexecauto. Verifique!", NomeAutoLog())
						
					else

						GrvLog(cInfLog + "Localizador no contas a pagar (Filial+Prefixo/Numero/Parcela/Tipo/Fornecedor/Loja) '" + SE2->(E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA) + "'")
						GrvLog("IMPORTADO COM SUCESSO com o valor de R$ " + AllTrim(Transform(SE2->E2_VALOR, "@E 999,999,999.99")) + " referente " + cHist)
						
						//				realizar a baixa do titulo
						aBaixa	:= {	{"E2_FILIAL", 		SE2->E2_FILIAL,					  Nil},;
											{"E2_PREFIXO", 	SE2->E2_PREFIXO,					  Nil},;
											{"E2_NUM", 			SE2->E2_NUM,						  Nil},;
											{"E2_PARCELA", 	SE2->E2_PARCELA,					  Nil},;
											{"E2_TIPO", 		SE2->E2_TIPO,						  Nil},;
											{"E2_FORNECE", 	SE2->E2_FORNECE,					  Nil},;
											{"E2_LOJA", 		SE2->E2_LOJA,						  Nil},;
											{"AUTMOTBX", 		"DEBITO CC",						  Nil},;
											{"AUTBANCO", 		cBanco,								  Nil},;
											{"AUTAGENCIA", 	cAgencia,							  Nil},;
											{"AUTCONTA", 		cConta,								  Nil},;
											{"AUTDTBAIXA", 	dDtBaixa,							  Nil},;
											{"AUTDTCREDITO",	dDtBaixa,							  Nil},;
											{"AUTHIST", 		"Baixa automatica titulo ", Nil},;
											{"AUTVLRPG", 		SE2->E2_SALDO,						  Nil}}
						
						AcessaPerg("FIN080", .F.)
						MsExecAuto({ |x,y| FINA080(x,y)}, aBaixa, 3)
						
						if lMsErroAuto
							
							DisarmTransaction()
							GrvLog(cInfLog + "n縊 baixado. Motivo: Ocorr麩cia de erro no msexecauto. Verifique!", NomeAutoLog())
							
						else
							
							GrvLog("BAIXADO COM SUCESSO no Banco/Agencia/Conta: " + cBanco + "/" + cAgencia + "/" + cConta)
							
							//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
							// Grava flag para desbloqueio de pagto 
							//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
							/*
							SF2->(RecLock("SF2", .F.))
							SF2->F2_X_OPLOG	:= Left(SF2->F2_X_OPLOG,2) + "N"
							SF2->F2_X_DBLQ3	:= dTOs(Date()) + " " + Time() + " " + cUserName
							SF2->(MsUnlock())
							*/
						endif
						
					endif
					
				else
					
					GrvLog(	cInfLog + "n縊 ser? importado. Motivo: T?tulo (Prefixo/Numero/Parcela/Tipo/Fornecedor/Loja) '" +;
								SE2->(E2_PREFIXO + "/" + E2_NUM + "/" + E2_PARCELA + "/" + E2_TIPO + "/" + E2_FORNECE + "/" + E2_LOJA) +;
								"' j? cadastrado. Verifique!")
					
				endif
			
			else
				
				GrvLog(cInfLog + "n縊 ser? importado. Motivo: Valor da guia n縊 corresponde ao valor do imposto na nota fiscal!")
				
			endif
			
		else
			
			GrvLog(cInfLog + "n縊 ser? importado. Motivo: Nota fiscal n縊 encontrada!")
			
		endif

		GrvLog("")
		
		TAUX->(dbSkip())
		
	enddo
	
endif

Return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		BRAJOB08B                                                     /@
@type				Static function                                               /@
@date				28/08/2015                                                    /@
@description	Fun鈬o chamada pela user function BRAJOB08. Envia o log de
					processamento para e-mails previamente cadastrados no parametro
					BR_MAILGNR                                                    /@
@author			Adalberto Moreno Batista - Op鈬o Um Consultoria               /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function BRAJOB08B()
Local cAnexo, cMensagem
Local nSeq		:= 0
Local cEol		:= Chr(13) + Chr(10)
Local cDestinat	:= AllTrim(GetMV("BR_MAILGNR", .F., "cassio.olimpio@gamaitaly.com.br"))
Local cAssunto	:= "Brasitech - Log de importa鈬o de t?s GNRE, integrados pela FINNET - referente ao CNPJ " + Transform(SM0->M0_CGC, "@R 99.999.999/9999-99")

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
// Identificando um nome v疝ido para o arquivo de log de processamento
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
do while .T.
	cAnexo := "edi01\finnet\log\_" + AllTrim(SM0->M0_CGC) + "_" +dTOs(date()) + "_" + StrZero(++nSeq, 3) + ".LOG"
	if !File(cAnexo)
		exit
	endif
enddo

dbSelectArea("TLOG")
Copy to &cAnexo SDF

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
// e-mail no formato html
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
cMensagem := '<html>' + cEol
cMensagem += '<font size="2" face="Arial">Informa鋏es de ocorr麩cias na importa鈬o dtulos GNRE em' + dTOc(dDataBase) + ' 灣 ' + Time() + ', disponilizados pelo FINNET, para o ERP Microsiga Protheus est縊 no arquivo anexo.</font>' + cEol + cEol + cEol
cMensagem += '<font size="1" face="Calibri">E-mail autom疸ico enviado pelo sistema Microsiga Protheus. Favor n縊 respond?-lo.</font>' + cEol
cMensagem += '</body>' + cEol
cMensagem += '</html>' + cEol

U_GISendMail(cDestinat,, cAssunto, cMensagem, cAnexo)

Return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		GRVLOG                                                        /@
@type				Static function                                               /@
@date				06/09/2014                                                    /@
@description	Fun鈬o chamada pela static function BRAJOB04A. Grava log de
					processamento na tabela tempor疵ia de log                     /@
@author			Adalberto Moreno Batista - Op鈬o Um Consultoria               /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function GrvLog(cErro, cArqErro)
Local aArea	:= GetArea()

dbSelectArea("TLOG")
TLOG->(RecLock("TLOG",.T.))
TLOG->LINHA	:= cErro
TLOG->(MsUnlock())

if cArqErro <> NIL
	Append From &cArqErro SDF
	fErase(cArqErro)
endif

RestArea(aArea)

Return()
