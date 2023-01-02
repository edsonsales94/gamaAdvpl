#include "protheus.ch"
#include "ap5mail.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		BRAJOB05                                                     /@
@type			User function                                                /@
@date			06/09/2014                                                   /@
@description	Rotina para uso em schedule. 								 
				Job para importacao de notas de faturas de cobrança de frete		
				partir de arquivo texto gerado pelo software GKO.						
				Será importado para a tabela de títulos a pagar do Protheus, a 	
				partir de arquivo texto () gerado pelo software GKO,		
				conforme layout INTFAT - EXPORTAÇÃO DE FATURAS
				Automatização da rotina BGKO04               		         /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function BRAJOB05()
Local aFiles	:= {"SA2", "SED", "SE2", "SE4"}
Local cLocDir	:= "edi01\gko\"
Local aStruLog	:= {{"LINHA",		"C", 200, 0}}
Local aStruTrb	:= {{"DETALHE",		"C", 180, 0}}
Local aBkpFile	:= {}
Local aEmp		:= {{"01", "01"}, {"01", "03"}, {"01", "09"}}
Local nK, nX, cTLOG, cTAUX, cTMPFAT, aArquivos, cArquivo, aCNPJFile, cArqSai

__LOCALDRIVER := "DBFCDX"

MakeDir("edi01")
MakeDir("edi01\gko")
MakeDir("edi01\gko\ok")
MakeDir("edi01\gko\log")

//———————————————————————————————————————————————————————————————————————————————
// Apaga arquivos não utilizados no processo de importação de faturas. O GKO cria
// arquivos FRFA e FRCON, mas utilizamos somente os FRFA.
//———————————————————————————————————————————————————————————————————————————————
aArquivos	:= Directory(cLocDir + "FRCON*.TXT")
for nK := 1 to Len(aArquivos)
	cArquivo := cLocDir + aArquivos[nK,1]
	fErase(cArquivo)
next

//———————————————————————————————————————————————————————————————————————————————
// Trata os arquivos de faturas e regrava-os de acordo com o CNPJ gravado 
// internamente.
//———————————————————————————————————————————————————————————————————————————————
aArquivos	:= Directory(cLocDir + "")
aCNPJFile	:= {}

if Len(aArquivos) > 0

	//———————————————————————————————————————————————————————————————————————————————
	// Crio tabela temporário e appendo as informações dos arquivos originais GKO
	//———————————————————————————————————————————————————————————————————————————————
	cTMPFAT := CriaTrab(aStruTRB, .T.)
	dbUseArea(.T.,"DBFCDX", cTMPFAT, "TMPFAT", .T.)
	dbSelectArea("TMPFAT")
	
	for nK := 1 to Len(aArquivos)
		cArquivo := cLocDir + aArquivos[nK, 1]
		Append From &cArquivo SDF								// copio os dados do arquivo texto para o temporario
		aAdd(aBkpFile, cLocDir + "_" + aArquivos[nK,1])
		__CopyFile(cArquivo, cLocDir + "_" + aArquivos[nK,1])
		fErase(cArquivo)										// apago o arquivo texto original FRFA
	next

	//———————————————————————————————————————————————————————————————————————————————
	// Busco quais foram os CNPJ's gravados na tabela temporária
	//———————————————————————————————————————————————————————————————————————————————
	TMPFAT->(dbGoTop())
	do while TMPFAT->(!eof())
		if aScan(aCNPJFile, Substr(TMPFAT->DETALHE, 98, 14)) == 0
			aAdd(aCNPJFile, Substr(TMPFAT->DETALHE, 98, 14))
		endif
		TMPFAT->(dbSkip())
	enddo
	
	//———————————————————————————————————————————————————————————————————————————————
	// Gravo novos arquivos texto para importação de faturas, por CNPJ
	//———————————————————————————————————————————————————————————————————————————————
	for nK := 1 to Len(aCNPJFile)
		cArqSai	:= cLocDir + "FAT_" + AllTrim(aCNPJFile[nK]) + "_" + dTOs(Date()) + "_" + StrTran(Time(), ":", "") + ".TXT"
		copy to &cArqSai SDF for Substr(TMPFAT->DETALHE, 98, 14) == Left(aCNPJFile[nK], 14)
	next
	
	//———————————————————————————————————————————————————————————————————————————————
	// Apago os arquivos backup
	//———————————————————————————————————————————————————————————————————————————————
	for nK := 1 to Len(aBkpFile)
		fErase(aBkpFile[nK])
	next

	//———————————————————————————————————————————————————————————————————————————————
	// Fecho o arquivo temporario e o excluo
	//———————————————————————————————————————————————————————————————————————————————
	if Select("TMPFAT") > 0
		TMPFAT->(dbCloseArea())
	endif
	fErase(cTMPFAT + OrdBagExt())

endif

//———————————————————————————————————————————————————————————————————————————————
// Abertura do ambiente
//———————————————————————————————————————————————————————————————————————————————
for nX := 1 to Len(aEmp)

	WfPrepEnv(aEmp[nX, 1], aEmp[nX, 2], "U_BRAJOB05",, "FIN")            //incluido aEmp[nX, 3] para funcionamento da filial 09

	//———————————————————————————————————————————————————————————————————————————————
	// Leio os arquivos da respectiva filial
	//———————————————————————————————————————————————————————————————————————————————
	aArquivos	:= Directory(cLocDir + "FAT_" + AllTrim(SM0->M0_CGC) + "*.TXT")

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

			BRAJOB05A(aArquivos[nK,1])
				
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
		BRAJOB05B()

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
	
	ConOut(dTOc(Date()) + " as " + Time() + " - BRAJOB05 - Conclusao do processo de importação de faturas (GKO) - Empresa / Filial " + aEmp[nX, 1] + "/" + aEmp[nX, 2]) // incluido aEmp[nX, 3]

	Sleep(15000)		//Aguarda 15 segundos antes de iniciar a próxima empresa
	
next
	
Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		BRAJOB05A                                                    /@
@type			Static function                                              /@
@date			06/09/2014                                                   /@
@description	Função chamada pela user function BRAJOB05. Processa os 
				registros dos arquivos gerados pelo GKO e importa p/ titulos
				a pagar.                                                     /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function BRAJOB05A(cArqGKO)
Local aTitulo, cCNPJ, cFatura, cPrefixo, cParcela, cTipo, dEmissao, nValor, dVencto,;
	  nDesconto, cInfLog, cCodBar, cAuxCB, nX, cMsgErro, nVlCodBar, dDtVctoBar, lGrvCB
Private lMsErroAuto	:= .F.

GrvLog("Movimento de faturas referente ao arquivo " + cArqGKO + ", disponibilizado pelo GKO")

dbSelectArea("TAUX")
dbGoTop()
do while TAUX->(!eof())

	cCNPJ		:= Substr(TAUX->DETALHE, 18, 14)
	cFatura		:= Substr(TAUX->DETALHE, 33, 09)
	cPrefixo	:= Substr(TAUX->DETALHE, 44, 03)
	cParcela	:= PadR(" ", Len(SE2->E2_PARCELA))
	cTipo		:= PadR("FT ", Len(SE2->E2_TIPO))
	dEmissao	:= cTOd(Substr(TAUX->DETALHE, 47, 10))
	nValor		:= Val(Substr(TAUX->DETALHE, 57, 15)) / 100
	nDesconto	:= Val(Substr(TAUX->DETALHE, 72, 15)) / 100
	dVencto		:= cTOd(Substr(TAUX->DETALHE, 87, 10))
	cAuxCB		:= Substr(TAUX->DETALHE, 112, 54)

	//———————————————————————————————————————————————————————————————————————————————
	// Montagem do código de barras do título
	//———————————————————————————————————————————————————————————————————————————————
	cCodBar	 := ""
	for nX := 1 to Len(AllTrim(cAuxCB))
		cCodBar += iif(IsDigit(Substr(cAuxCB, nX, 1)), Substr(cAuxCB, nX, 1), "")
	next

	//———————————————————————————————————————————————————————————————————————————————
	// 1-Verifico se o código de barras é válido, comparando 47 e 44 posições.
	// 2-Função VLCODBAR encontrada no fonte PAGFOR.PRW
	// 3-Analiso o valor do código de barras e comparo com o valor da fatura e caso 
	//   estes valores não baterem, não gravo o codigo de barras
	//———————————————————————————————————————————————————————————————————————————————
	if !Empty(cCodBar)
	
		cCodBar	:= Left(cCodBar, 47)
		cCodBar	:= PadR(cCodBar, 47)
		lGrvCB	:= .T.	//Gravo o codigo de barras

		if !U_VLCODBAR(Left(cCodBar,47), .F., @cMsgErro)
			if !U_VLCODBAR(Left(cCodBar,44), .F., @cMsgErro)
				lGrvCB := .F.
			endif
		endif
	
		if lGrvCB
			nVlCodBar 	:= 0
			dDtVctoBar 	:= cTOd("")
			if Len(AllTrim(cCodBar)) == 44					//codigo de barras lido pelo leitor
				nVlCodBar	:= Val(Substr(cCodBar, 10, 10)) / 100
				dDtVctoBar	:= cTOd("07/10/97") + Val(Substr(cCodBar, 06, 04))
			//elseif Len(AllTrim(SE2->E2_CODBAR)) == 47		
			elseif Len(AllTrim(cCodBar)) == 47	//linha digitavel para boletos registrados
				nVlCodBar	:= Val(Substr(cCodBar, 38, 10)) / 100
				dDtVctoBar 	:= cTOd("07/10/97") + Val(Substr(cCodBar, 34, 04))
			endif

			if nVlCodBar != nValor .or. dDtVctoBar != dVencto
				lGrvCB 	:= .F.
				cMsgErro := "O código de barras não será gravado, pois o valor do título ou a data de vencimento não batem com o valor e data de vencimento encontrado no código de barras."
			endif
		endif
	
		if !lGrvCB
			cCodBar := ""
		endif
		
	endif
			
	cInfLog	:= "Fatura " + cFatura + ", série " + cPrefixo + " do CNPJ " + Transf(cCNPJ,"@R 99.999.999/9999-99")+" "
    
	SA2->(dbSetOrder(3))
	if SA2->(dbSeek(xFilial("SA2") + cCNPJ))

		dbSelectArea("SE2")
		dbSetOrder(1)

		if !dbSeek(xFilial("SE2") + cPrefixo + cFatura + cParcela + cTipo + SA2->A2_COD + SA2->A2_LOJA)

			aTitulo 	:= {	{"E2_PREFIXO",	cPrefixo,				Nil},;
								{"E2_NUM",		cFatura,			 	Nil},;
								{"E2_PARCELA",	cParcela,				Nil},;
								{"E2_TIPO",		cTipo,					Nil},;
								{"E2_FORNECE",	SA2->A2_COD,			Nil},;
								{"E2_LOJA",		SA2->A2_LOJA,			Nil},;
								{"E2_NOMFOR" ,	SA2->A2_NREDUZ, 		Nil},;
								{"E2_NATUREZ",	SA2->A2_NATUREZ,		Nil},;
								{"E2_EMISSAO",	dEmissao,				Nil},;
								{"E2_VENCTO",	dVencto,			   	Nil},;
								{"E2_VENCREA",	DataValida(dVencto),	Nil},;
								{"E2_VALOR",	nValor,					Nil},;
								{"E2_DECRESC",	nDesconto,				Nil},;
								{"E2_HIST",		"Fatura GKO",			Nil},;
								{"E2_CODBAR",	cCodBar,				Nil}}
		
			SA2->(dbSetOrder(1))
			lMsErroAuto	:= .F.
			
			MsExecAuto({ |x,y,z| FINA050(x,y,z) }, aTitulo,, 3)
					
			if lMsErroAuto
				
				//DisarmTransaction()
				GrvLog(cInfLog + "não será importado. Motivo: Ocorrência de erro no msexecauto. Verifique!", NomeAutoLog())
				
			else
			
				GrvLog(cInfLog + "IMPORTADO COM SUCESSO. Localizador no contas a pagar (Prefixo/Numero/Parcela/Tipo/Fornecedor/Loja) '" +;
						  SE2->(E2_PREFIXO + "/" + E2_NUM + "/" + E2_PARCELA + "/" + E2_TIPO + "/" + E2_FORNECE + "/" + E2_LOJA) +;
						  iif(!Empty(cMsgErro), "' O código de barras não foi gravado. Motivo: " + cMsgErro, "'"))
					
			endif
			
		else
		
			/*GrvLog(cInfLog + "não será importado. Motivo: Título (Prefixo/Numero/Parcela/Tipo/Fornecedor/Loja) '" +;
					SE2->(E2_PREFIXO + "/" + E2_NUM + "/" + E2_PARCELA + "/" + E2_TIPO + "/" + E2_FORNECE + "/" + E2_LOJA) +;
					"' já cadastrado. Verifique!")*/
			
		endif
		
    else
    
	    GrvLog(cInfLog + "não será importado. Motivo: Não encontrado fornecedor para o respectivo CNPJ. Verifique!")
	    
    endif

	TAUX->(dbSkip())
			
enddo
		
Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		BRAJOB05B                                                    /@
@type			Static function                                              /@
@date			05/09/2014                                                   /@
@description	Função chamada pela user function BRAJOB0B. Envia o log de
				processamento para e-mails previamente cadastrados no parame-
				tro BR_MAILGKO                                               /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function BRAJOB05B()
Local cAnexo, cMensagem
Local nSeq		:= 0
Local cEol		:= Chr(13) + Chr(10)
Local cDestinat	:= AllTrim(GetMV("BR_MAILGKO", .F., "cassio.olimpio@gamaitaly.com.br"))
Local cAssunto	:= "Brasitech - Log de importação de faturas referente ao CNPJ " + Transform(SM0->M0_CGC, "@R 99.999.999/9999-99")

//————————————————————————————————————————————————————————————————————————————
// Identificando um nome válido para o arquivo de log de processamento
//————————————————————————————————————————————————————————————————————————————
do while .T.
	cAnexo := "edi01\gko\log\IFAT_" + AllTrim(SM0->M0_CGC) + "_" +dTOs(date()) + "_" + StrZero(++nSeq, 3) + ".LOG"
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
cMensagem += '<font size="2" face="Arial">Informações de ocorrências na importação de faturas em' + dTOc(dDataBase) + ' às ' + Time() + ', disponilizados pelo software GKO, para o ERP Microsiga Protheus estão no arquivo anexo.</font>' + cEol + cEol + cEol
cMensagem += '<font size="1" face="Calibri">E-mail automático enviado pelo sistema Microsiga Protheus. Favor não respondê-lo.</font>' + cEol	
cMensagem += '</body>' + cEol
cMensagem += '</html>' + cEol

U_GISendMail(cDestinat,, cAssunto, cMensagem, cAnexo)

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		GRVLOG                                                       /@
@type			Static function                                              /@
@date			06/09/2014                                                   /@
@description	Função chamada pela static function BRAJOB04A. Grava log de
				processamento na tabela temporária de log                    /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Específico Brasitech                                         /@
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
