#include "protheus.ch"
#include "ap5mail.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		BRAJOB08                                                      /@
@type				User function                                                 /@
@date				04/05/2015                                                    /@
@description	Rotina para uso em schedule.
					Job para importacao de informaçõesGNRE. Cria título a
					pagar e o baixa em banco/agencia/conta parametrizado.         /@
@author			Adalberto Moreno Batista - Opção Um Consultoria               /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
Nome do arquivo:	ST-99999999999999-aammdd-???.txt
ST-				String fixa
99999999999999	Numero do CNPJ da empresa Brasitech
-					String fixa
aammdd			Ano, mês e dia do arquivo
-					String fixa
???				String para diferenciação dos arquivos dentro do mesmo dia. Pode 
					ser um número sequencial ou hora da geração do arquivo
.txt				Extensão do arquivo texto

Campo					Tam	Inicio
Nro Nota Fiscal	9		1	Número da nota fiscal
Série Nota Fiscal	3		10	Série da nota fiscal
Valor					12		13	Valor do imposto a ser pago. Este campo deverá 
									considerar duas casas decimais. Exemplo: Para a 
									representação do valor R$ 1.000,00, enviar a 
									string "000000100000".
Data da baixa		8		25	Data da baixa no formato AAAAMMDD
Valor pago			12,2	33	Valor da baixa. Este campo deverá considerar duas 
									casas decimais. Exemplo: Para a representação do 
									valor R$ 1.000,00, enviar a string "000000100000".
Banco					3		45	Número do banco onde o pagamento foi efetuado
Agencia				5		48	Número da agência onde o pagamento foi efetuado
Conta					10		53	Número da conta corrente onde o pagamento foi efetuado
DV conta				1		63	Digito verificador da conta corrente onde o pagamento 
								foi efetuado
———————————————————————————————————————————————————————————————————————————————
/*/
User Function BRAJOB08()
Local aFiles	:= {"SA2", "SA6", "SED", "SE2", "SE5", "SF2"}
Local cEmp		:= "01"					//Brasitech
Local aFil		:= {"03", "08"}		//Filiais 03-São Paulo e 08-Loja
Local cLocDir	:= "edi01\finnet\"
Local aStruLog	:= {{"LINHA",		"C", 200, 0}}
Local aStruTrb	:= {{"DETALHE",	"C", 100, 0}}
Local nK, nX, cTLOG, cTAUX, aArquivos, cArquivo

//__LOCALDRIVER := "DBFCDX"

MakeDir("edi01")
MakeDir("edi01\finnet")
MakeDir("edi01\finnet\ok")
MakeDir("edi01\finnet\log")

//———————————————————————————————————————————————————————————————————————————————
// Abertura do ambiente
//———————————————————————————————————————————————————————————————————————————————
for nX := 1 to Len(aFil)

	//———————————————————————————————————————————————————————————————————————————————
	// Abertura do ambiente
	//———————————————————————————————————————————————————————————————————————————————
	WfPrepEnv(cEmp, aFil[nX], "U_BRAJOB08",, "FIN")
	
//———————————————————————————————————————————————————————————————————————————————
// Leio os arquivos da respectiva filial
//———————————————————————————————————————————————————————————————————————————————
	aArquivos	:= Directory(cLocDir + "ST-" + AllTrim(SM0->M0_CGC) + "*.TXT")
	
	//———————————————————————————————————————————————————————————————————————————————
	// Inicia a abertura do ambiente somente se houver arquivos a serem processados
	//———————————————————————————————————————————————————————————————————————————————
	if Len(aArquivos) > 0
		
		for nK := 1 to Len(aFiles)
			
			if Select(aFiles[nK]) == 0
				ChkFile(aFiles[nK])
			endif
			
		next
		
		//———————————————————————————————————————————————————————————————————————————————
		// Inicia o tratamento dos arquivos encontrados
		//———————————————————————————————————————————————————————————————————————————————
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
	
	//———————————————————————————————————————————————————————————————————————————————
	// Encerramento do ambiente
	//———————————————————————————————————————————————————————————————————————————————
	RpcClearEnv()
	
	ConOut(dTOc(Date()) + " as " + Time() + " - BRAJOB08 - Importação de registrosGNRE, enviados pela FINNET. Inclusão e baixa de título - Empresa "+cEmp+" / Filial "+aFil[nX])
	
next	
	
Return()
	

/*/
———————————————————————————————————————————————————————————————————————————————
@function		BRAJOB08A                                                     /@
@type				Static function                                               /@
@date				04/05/2015                                                    /@
@description	Função chamada pela user function BRAJOB08. Processa os
					registros de  e importa para titulos a pagar.             /@
@author			Adalberto Moreno Batista - Opção Um Consultoria               /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function BRAJOB08A()
Local cDoc, cSerie, nValor, dDtBaixa, nVlPago, cInfLog, aTitulo, aBaixa, nK,;
		cFornec, cLoja, cBanco, cAgencia, cConta, nValDifal, cNatureza,;
		cCCusto, cHist, cSerie1, cSerie2
//Local cInfTit 		:= GetMV("BR_FIN", .F., "ESTADO#00#237#33928#2601-8")
Local cInfTit 		:= GetMV("BR_FIN", .F., "ESTADO#00#001#33472#201000-3") //Alterado Evandro - 16/08/2022
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

//———————————————————————————————————————————————————————————————————————————————
// Seta as tabelas na ordem necessaria para o processamento
//———————————————————————————————————————————————————————————————————————————————
SA2->(dbSetOrder(1))		//A2_FILIAL, A2_COD, A2_LOJA
SA6->(dbSetOrder(1))		//A6_FILIAL, A6_COD, A6_AGENCIA, A6_NUMCON

if SA2->(!dbSeek(xFilial("SA2") + cFornec + cLoja))
	GrvLog("O processo não será iniciado, pois o fornecedor não está cadastrado. Solicite que o depto de TI verifique o param BR_GNREINF.")
	lContinua := .F.
endif

if SA6->(!dbSeek(xFilial("SA6") + cBanco + cAgencia + cConta))
	GrvLog("O processo não será iniciado, pois o banco, agencia e conta não estão cadastrados. Solicite que o depto de TI verifique o param BR_GNREINF.")
	lContinua := .F.
endif

if lContinua
	
	dbSelectArea("TAUX")
	dbGoTop()
	do while TAUX->(!eof())
		
		//———————————————————————————————————————————————————————————————————————————————
		// Busca dados na linha lida
		//———————————————————————————————————————————————————————————————————————————————
		cDoc		:= Substr(TAUX->DETALHE, 1, 9)											//Nro Nota Fiscal	9		1	Número da nota fiscal
		cSerie1	:= PadR(AllTrim(Str(Val(Substr(TAUX->DETALHE, 10, 3)))), 3)		//Série Nota Fiscal	3		10	Série da nota fiscal - sem zeros a esquerda
		cSerie2	:= StrZero(Val(Substr(TAUX->DETALHE, 10, 3)), 3)					//Série Nota Fiscal	3		10	Série da nota fiscal - com zeros a esquerda
		nValor	:= Val(Substr(TAUX->DETALHE, 13, 12)) / 100							//valor					12		13	Valor do imposto a ser pago. Este campo deverá considerar duas casas decimais. Exemplo: Para a representação do valor R$ 1.000,00, enviar a string "000000100000".
		dDtBaixa	:= sTOd(Substr(TAUX->DETALHE, 25, 8))									//Data da baixa		8		25	Data da baixa no formato AAAAMMDD
		nVlPago	:= Val(Substr(TAUX->DETALHE, 33, 14)) / 100							//Valor pago			12,2	33	Valor da baixa. Este campo deverá considerar duas casas decimais. Exemplo: Para a representação do valor R$ 1.000,00, enviar a string "000000100000".
		cCodRec	:= Substr(TAUX->DETALHE, 66, 6)											/*Códigos dos impostos: 000004 - ST (RJ)
																																		000059 - DIFAL (RJ)
																																		100099 - ST
																																		100102 - DIFAL*/
		/*	
		cBanco	:= Substr(TAUX->DETALHE, 47, 3)											//Banco					3		45	Número do banco onde o pagamento foi efetuado
		cAgencia	:= Substr(TAUX->DETALHE, 50, 5)											//Agencia				5		48	Número da agência onde o pagamento foi efetuado
		cConta	:= Substr(TAUX->DETALHE, 55, 10)											//Conta					10		53	Número da conta corrente onde o pagamento foi efetuado
		cDV		:= Substr(TAUX->DETALHE, 65, 1)											//DV conta				1		63	Digito verificador da conta corrente onde o pagamento foi efetuado
		*/
		
		//———————————————————————————————————————————————————————————————————————————————
		// Seta as tabelas na ordem necessaria para o processamento
		//———————————————————————————————————————————————————————————————————————————————
		SA2->(dbSetOrder(1))		//A2_FILIAL, A2_COD, A2_LOJA
		SA6->(dbSetOrder(1))		//A6_FILIAL, A6_COD, A6_AGENCIA, A6_NUMCON
		SE2->(dbSetOrder(1))		//E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA
		SF2->(dbSetOrder(1))		//F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, F2_TIPO
		CD2->(dbSetorder(1))    //CD2_FILIAL, CD2_TPMOV, CD2_SERIE, CD2_DOC, CD2_CODCLI, CD2_LOJCLI, CD2_ITEM, CD2_CODPRO, CD2_IMP
		
		SA2->(dbSeek(xFilial("SA2") + cFornec + cLoja))
		SA6->(dbSeek(xFilial("SA6") + cBanco + cAgencia + cConta))
		
		//———————————————————————————————————————————————————————————————————————————————
		// Localiza a NF. Tentativa sem e com zeros à esquerda
		//———————————————————————————————————————————————————————————————————————————————
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
		
		cInfLog		:= "Documento " + cDoc + ", série " + cSerie + " "
		//———————————————————————————————————————————————————————————————————————————————
		// Continua se localizada a NF
		//———————————————————————————————————————————————————————————————————————————————
		if lContinua
				
			//———————————————————————————————————————————————————————————————————————————————
			// Verifica o tipo do imposto, se ST ou DIFAL      
			// adicionado 000005 21/08 chamado 9884
			//———————————————————————————————————————————————————————————————————————————————
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
				///lContinua 	:= (nValDifal == nValor)
				lContinua 	:= nValor
				
	
			else		//ST
			
				cNatureza 	:= "402007101"
				cCCusto	 	:= ""
				cHist			:= "FINNET INTEGRACAO  - ICMS-ST"
				//lContinua 	:= (SF2->F2_ICMSRET == nValor)
				lContinua 	:= nValor
			
			endif

			//———————————————————————————————————————————————————————————————————————————————
			// Verifica se continua o processo
			//———————————————————————————————————————————————————————————————————————————————
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
						GrvLog(cInfLog + "não será importado. Motivo: Ocorrência de erro no msexecauto. Verifique!", NomeAutoLog())
						
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
							GrvLog(cInfLog + "não baixado. Motivo: Ocorrência de erro no msexecauto. Verifique!", NomeAutoLog())
							
						else
							
							GrvLog("BAIXADO COM SUCESSO no Banco/Agencia/Conta: " + cBanco + "/" + cAgencia + "/" + cConta)
							
							//———————————————————————————————————————————————————————————————————————————————
							// Grava flag para desbloqueio de pagto 
							//———————————————————————————————————————————————————————————————————————————————
							/*
							SF2->(RecLock("SF2", .F.))
							SF2->F2_X_OPLOG	:= Left(SF2->F2_X_OPLOG,2) + "N"
							SF2->F2_X_DBLQ3	:= dTOs(Date()) + " " + Time() + " " + cUserName
							SF2->(MsUnlock())
							*/
						endif
						
					endif
					
				else
					
					GrvLog(	cInfLog + "não será importado. Motivo: Título (Prefixo/Numero/Parcela/Tipo/Fornecedor/Loja) '" +;
								SE2->(E2_PREFIXO + "/" + E2_NUM + "/" + E2_PARCELA + "/" + E2_TIPO + "/" + E2_FORNECE + "/" + E2_LOJA) +;
								"' já cadastrado. Verifique!")
					
				endif
			
			else
				
				GrvLog(cInfLog + "não será importado. Motivo: Valor da guia não corresponde ao valor do imposto na nota fiscal!")
				
			endif
			
		else
			
			GrvLog(cInfLog + "não será importado. Motivo: Nota fiscal não encontrada!")
			
		endif

		GrvLog("")
		
		TAUX->(dbSkip())
		
	enddo
	
endif

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		BRAJOB08B                                                     /@
@type				Static function                                               /@
@date				28/08/2015                                                    /@
@description	Função chamada pela user function BRAJOB08. Envia o log de
					processamento para e-mails previamente cadastrados no parametro
					BR_MAILGNR                                                    /@
@author			Adalberto Moreno Batista - Opção Um Consultoria               /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function BRAJOB08B()
Local cAnexo, cMensagem
Local nSeq		:= 0
Local cEol		:= Chr(13) + Chr(10)
Local cDestinat	:= AllTrim(GetMV("BR_MAILGNR", .F., "cassio.olimpio@gamaitaly.com.br"))
Local cAssunto	:= "Brasitech - Log de importação de tís GNRE, integrados pela FINNET - referente ao CNPJ " + Transform(SM0->M0_CGC, "@R 99.999.999/9999-99")

//————————————————————————————————————————————————————————————————————————————
// Identificando um nome válido para o arquivo de log de processamento
//————————————————————————————————————————————————————————————————————————————
do while .T.
	cAnexo := "edi01\finnet\log\_" + AllTrim(SM0->M0_CGC) + "_" +dTOs(date()) + "_" + StrZero(++nSeq, 3) + ".LOG"
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
cMensagem += '<font size="2" face="Arial">Informações de ocorrências na importação dtulos GNRE em' + dTOc(dDataBase) + ' às ' + Time() + ', disponilizados pelo FINNET, para o ERP Microsiga Protheus estão no arquivo anexo.</font>' + cEol + cEol + cEol
cMensagem += '<font size="1" face="Calibri">E-mail automático enviado pelo sistema Microsiga Protheus. Favor não respondê-lo.</font>' + cEol
cMensagem += '</body>' + cEol
cMensagem += '</html>' + cEol

U_GISendMail(cDestinat,, cAssunto, cMensagem, cAnexo)

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		GRVLOG                                                        /@
@type				Static function                                               /@
@date				06/09/2014                                                    /@
@description	Função chamada pela static function BRAJOB04A. Grava log de
					processamento na tabela temporária de log                     /@
@author			Adalberto Moreno Batista - Opção Um Consultoria               /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
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
