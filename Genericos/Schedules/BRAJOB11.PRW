#include "protheus.ch"
#include "ap5mail.ch"       

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		                                                       /@
@type			User function                                                  /@
@date			20/08/2015                                                     /@
@description	Rotina para uso em schedule.
				Job para importacao de lan軋mentos cont畸eis para provis縊
				de frete partir de arquivo texto gerado pelo software GKO.
				Importa鈬o para a tabela de lan軋mentos cont畸eis do Protheus,
				a partir de arquivo texto (FRPFAP*.TXT) gerado pelo
				software GKO, conforme layout
				Automatiza鈬o da rotina BGKO03                                 /@
@author			Luiz Fernando                                                  /@
@use			Espec?fico Brasitech                                           /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function BRAJOB11()
Local aFiles		:= {"CTT", "CT1", "CT2"}
Local aStruTRB		:= {	{"TPREGISTRO",	"C", 003, 0},;
							{"CBUFFER",		"C", 180, 0}}
Local aEmp			:= {{"01", "01"}, {"01", "03"}, {"01", "09"}}
Local cLocDir		:= "\edi01\gko\" 
Local lRet 			:= .T. 
//Local cEol			:= chr(13) + chr(10)
Local nSeq			:= 0
Local nK, nX, nY, cTAUX, aArquivos, cArquivo	// , cMsgErro, lImport,
Private GKOFile, cAnexo

MakeDir("edi01")
MakeDir("edi01\gko")
MakeDir("edi01\gko\ok")
MakeDir("edi01\gko\log")

aArquivos	:= Directory(cLocDir + "FRPFAP*.TXT")

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Inicia a abertura do ambiente somente se houver arquivos a serem processados
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if Len(aArquivos) > 0

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	// Cria鈬o do arquivo de log (1 por processamento)
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	do while .T.
		cAnexo := "edi01\gko\log\FRPFAP_" + dTOs(date()) + "_" + StrZero(++nSeq, 3) + ".LOG"
		if !File(cAnexo)
			exit
		endif
	enddo
	MemoWrite(cAnexo,"")
		
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Inicia o tratamento dos arquivos encontrados
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	for nK := 1 to Len(aArquivos)

		GKOFile	:= aArquivos[nK,1]
		cArquivo := cLocDir + aArquivos[nK,1]

		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
		// Processamento das empresas e filiais
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
		for nX := 1 to Len(aEmp)
				
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
			// Abertura do ambiente
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
			WfPrepEnv(aEmp[nX, 1], aEmp[nX, 2], "U_",, "CTB")

			for nY := 1 to Len(aFiles)
				if Select(aFiles[nY]) = 0
					ChkFile(aFiles[nY])
				endif
			next

			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
			//Cria tabela auxiliar para importacao        
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
			cTAUX 	:= CriaTrab(aStruTRB, .T.)
			dbUseArea(.T.,"DBFCDX", cTAUX, "TAUX", .T.)

			dbSelectArea("TAUX")
			Append From &cArquivo SDF
			TAUX->(dbGoTop())
			if eof()
				fErase(cArquivo)
			else
				lRet := A()
				
				//Fecho o arquivo de trabalho e o excluo
				if Select("TAUX") > 0
					TAUX->(dbCloseArea())
				endif
				fErase(cTAUX + OrdBagExt())
				
				//Envia e-mail com o resultado do processamento
				B(aArquivos[nK,1])
						
				//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
				// Encerramento do ambiente                                                     
				//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
				RpcClearEnv()

				ConOut(dTOc(Date()) + " as " + Time() + " -  - Conclus縊 do processo de provis縊 de frete (GKO) - Empresa / Filial " + aEmp[nX, 1] + "/" + aEmp[nX, 2])
	
				Sleep(5000)		//Aguarda 5 segundos				
				
			Endif
			
		Next
		
		//Caso retorne .F., mantenho o arquivo para o proximo processamento
		If lRet
			//Copia tabela processada no diretorio OK
			__CopyFile(cArquivo, cLocDir + "ok\" + aArquivos[nK,1])
			fErase(cArquivo)
		Endif

	Next

endif
		
Return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		A                                                    /@
@type			Static function                                              /@
@date			05/09/2014                                                   /@
@description	Fun鈬o chamada pela user functOB11. Processa os 
				registros dos arquivos gerados pelo GKO e importa para notas
				de entrada.                                                  /@
@author			Adalberto Moreno Batista - Op鈬o Um Consultoria              /@
@use			Espec?fico Brasitech                                         /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function A()
Local lRet				:= .T.
Local _aItens, nI, _lProv, _cIdDOC, _cCNPJ, _cDocProv, _lOk, aCab, aDet, _cInfLog,;
	  _cConta, _cDC, _nValor, _cCusto, _cHist, _cNF, _cSerie, cOrigem, _cCNPJC,;
	  _cChvGKO
Private lMsErroAuto		:= .F.
Private lAutoErrNoFile	:= .T.

//Setando a ordem das tabelas
CT1->(dbSetOrder(1))
CTT->(dbSetOrder(1))

dbSelectArea("TAUX")
dbGoTop()
do While TAUX->(!eof())

	//somente para provisoes(1) e cancelamentos de provisoes(3) e para a Filial
	if TAUX->TPREGISTRO == "070" .and. Substr(TAUX->CBUFFER,17,1) $ "1.3" .and. StrZero(Val(Substr(TAUX->CBUFFER, 48, 14)),14) == SM0->M0_CGC
	
		_lProv		:= (Substr(TAUX->CBUFFER,17,1) == "1")
		_cIdDOC		:= AllTrim(Str(Val(Substr(TAUX->CBUFFER,1,16))))
		_cCNPJ		:= AllTrim(Substr(TAUX->CBUFFER,18,14))
	 	_cDocProv	:= Substr(TAUX->CBUFFER,32,16)
		_dDataLcto	:= ctod(Substr(TAUX->CBUFFER,63,10))
	 	_dDataEmis	:= ctod(Substr(TAUX->CBUFFER,83,10))
		_lOk		:= .T.
		aCab 		:= {}
		aDet 		:= {}
		_aItens		:= {}
		_cInfLog	:= ""
	
		TAUX->(dbSkip())
		
		do while TAUX->(!eof() .and. TPREGISTRO == "075")
	
			_cConta		:= PadR(Substr(TAUX->cBuffer,1,10), 20)
			_cDC		:= Substr(TAUX->cBuffer,41,1)
			_nValor		:= Val(Substr(TAUX->cBuffer,42,10))/100
			_cCusto		:= Iif(!Empty(AllTrim(Substr(TAUX->cBuffer,31,10))), AllTrim(Substr(TAUX->cBuffer,31,10)), iif(Substr(_cConta,1,1) == "4", "1051", ""))
			_cNF		:= Substr(TAUX->cBuffer,53,9)
			_cSerie		:=  PadR(Substr(TAUX->cBuffer,64,1), 3)
			_cHist		:= iif(_lProv, "", "CANCEL.") + "PROV.FRETE REF.NF ORI:" + AllTrim(_cNF) + "-" + AllTrim(_cSerie)
			_cTpDoc		:= Substr(TAUX->cBuffer,100,1) // 1= Entrada 2= Saida
			_cCNPJC     := AllTrim(Substr(TAUX->CBUFFER,102,14))
			_cChvGKO    := _cCNPJC + "#" + _cSerie + "#" + _cNF + "#" + _cDC + "#" + _cConta		//AllTrim(_cCnpjc) + AllTrim(_cSerie) + AllTrim(_cNF)  //chave(Id) Cnpjcliente Gko Nota + Serie + Cnpjcliente
			_cInfLog	:= AllTrim(SM0->M0_FILIAL) + ", arquivo " + GKOFile + ", NF ORI: " + AllTrim(_cNF) + "-" + AllTrim(_cSerie) + " transp cod. " + _cCNPJ + " "

			aAdd(_aItens, {_cConta, _cDC, _nValor, _cCusto, _cHist, _cChvGKO})

			TAUX->(dbSkip())
			
    	enddo
    
	    
		//Identificando a existencia de lancamentos contabeis
		if Len(_aItens) > 0

			CT2->(dbOrderNickname("CHVGKO"))	//CT2_FILIAL + CT2_XNGKO

			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			// Validando as informacoes dos lancamentos contabeis
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			for nI:=1 to Len(_aItens)
			
				//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
				// Validando a existencia da conta contabil
				//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		 		if CT1->(!dbSeek(xFilial("CT1") + _aItens[nI,1]))
					_lOk := .F.
					GKOGrvLog(_cInfLog+ " n縊 foi importado. Motivo: A Conta "+AllTrim(_aItens[nI,1])+" n縊 foi encontrada no sistema.")
					Loop
		 		endif
		 		
				//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
				// Validando a existencia do centro de custo
				//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		 		if CTT->(!dbSeek(xFilial("CTT") + _aItens[nI,4]))
					_lOk := .F.
					GKOGrvLog(_cInfLog + "n縊 foi importado. Motivo: O centro de custo "+AllTrim(_aItens[nI,4])+" n縊 foi encontrada no sistema.")
					Loop
		 		endif
		 		
				//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
				// Verifica se o lan軋mento j? existe na base de dados
				//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		 		if CT2->(dbSeek(xFilial("CT2") + _aItens[nI,6]))	// .and. CT2->CT2_VALOR == _aItens[nI,3]
					_lOk := .F.
					GKOGrvLog(_cInfLog + "n縊 foi importado. Motivo: lan軋mento j? registrado na contabilidade: (CNPJ#SERIE#NF#DC#CONTA): " + AllTrim(_aItens[nI,6]))
					Loop
		 		endif
				
				cOrigem	:= " - em " + dTOc(Date()) + " as " + Time()
				
				aAdd(aDet,	{	{"CT2_FILIAL"	,xFilial("CT2"),								NIL},;
								{"CT2_LINHA"	,StrZero(nI,3),									NIL},;
								{"CT2_MOEDLC"	,"01",											NIL},;
								{"CT2_DC"		,iif(_aItens[nI,2] = "D","1","2"),				NIL},;
								{"CT2_DEBITO"	,iif(_aItens[nI,2] = "D",_aItens[nI,1],""),		NIL},;
								{"CT2_CREDIT"	,iif(_aItens[nI,2] = "C",_aItens[nI,1],""),		NIL},;
								{"CT2_VALOR"	,_aItens[nI,3],									NIL},;
								{"CT2_ORIGEM"	,cOrigem,										NIL},;
								{"CT2_HP"		,"",											NIL},;
								{"CT2_CCD"		,iif(_aItens[nI,2] = "D",_aItens[nI,4],""),		NIL},;
								{"CT2_CCC"		,iif(_aItens[nI,2] = "C",_aItens[nI,4],""),		NIL},;
								{"CT2_XNGKO"	,_aItens[nI,6],									NIL},;
								{"CT2_HIST"		,_aItens[nI,5],									NIL}})

			next

			if _lOk

				aCab	:= {	{"dDataLanc", 	iif(_cTpDoc == "1", _dDataLcto, _dDataEmis),	NIL},;
								{"cLote",		"005000",										NIL},;
								{"cSubLote",	"001",											NIL}}
				
				lMsErroAuto 	:= .F.
				lAutoErrNoFile	:= .T.

				CT2->(dbSetOrder(1))

				Begin Transaction
					//-- Chamada da rotina automatica     
					MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)}, aCab, aDet, 3)

					//-- Verifica se houve algum erro
					If lMsErroAuto
									 
						DisarmTransaction()
						GKOGrvLog(_cInfLog + "n縊 foi importado. Falha na importa鈬o da provis縊 da contabilza鈬o.", GetAutoGRLog())
						lRet := .F.
						
					else
		
						GKOGrvLog(_cInfLog + "IMPORTADO COM SUCESSO. DOCTO: " + CT2->(CT2_LOTE + "/" + CT2_SBLOTE + "/" + CT2_DOC + " em " + dtoc(CT2_DATA)))
						
					endif

				End Transaction

			endif
	        
		else
		
			_lOk := .F.
			//GKOGrvLog(_cInfLog + "nao foi importado. Motivo: Nao foram identicados lancamentos para este documento, registros tipo 075 conforme layout GKO")
			
		endif
	
	else
	
		TAUX->(dbSkip())
	
	endif

EndDo
Return(lRet)

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		BRAJOB011                                                    /@
@type			Static function                                              /@
@date			05/09/2014                                                   /@
@description	Fun鈬o chamada pela user functOB11. Envia o log de
				processamento para e-mails previamente cadastrados no parame-
				tro BR_MAILGKO                                               /@
@author			Adalberto Moreno Batista - Op鈬o Um Consultoria              /@
@use			Espec?fico Brasitech                                         /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function B(cAnexo)
Local cDataHora		:= 'em ' + dTOc(Date()) + ' 灣 ' + Time()
Local cEol			:= Chr(13) + Chr(10)
Local cAssunto		:= "Brasitech - Log de importa鈬o de provis縊 cont畸il de frete " + cDataHora
Local cConteudo		:= MemoRead(cAnexo)
Local cMensagem, cDestinat

if !Empty(cConteudo)

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	// Abertura do ambiente
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	WfPrepEnv("01", "03", "U_",, "CTB")
	
	cDestinat	:= AllTrim(GetMV("BR_MAILGKO", .F., "equipe.ti@gamaitaly.com.br"))

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	// e-mail no formato html
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	cMensagem := '<html>' + cEol
	cMensagem += '<font size="2" face="Arial">Informa鋏es de ocorr麩cias na importa鈬o de provis縊 cont畸il de frete ' + cDataHora + ', disponilizados pelo software GKO, para o ERP Microsiga Protheus' + cEol + 'Para detalhes do resultado, abra o arquivo anexo.</font>' + cEol + cEol + cEol
	cMensagem += '<font size="1" face="Calibri">E-mail autom疸ico enviado pelo sistema Microsiga Protheus. Favor n縊 respond?-lo.</font>' + cEol	
	cMensagem += '</body>' + cEol
	cMensagem += '</html>' + cEol
	
	U_GISendMail(cDestinat,, cAssunto, cMensagem, cAnexo)

	RpcClearEnv()
	
else

	fErase(cAnexo)
	
endif

Return()

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		GKOGrvLog                                                    /@
@type			Static function                                              /@
@date			05/09/2014                                                   /@
@description	Fun鈬o chamada pela user function BRAJOB04. Envia o log de
				processamento para e-mails previamente cadastrados no parame-
				tro BR_MAILGKO                                               /@
@author			Adalberto Moreno Batista - Op鈬o Um Consultoria              /@
@use			Espec?fico Brasitech                                         /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function GKOGrvLOG(_cLog, aLogErro)
Local cEol			:= Chr(13) + Chr(10)
Local cConteudo 	:= MemoRead(cAnexo) + cEol + _cLog		//Alimentando a vari疱el cConteudo
Local cErro			:= ""
Local nX

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Tratamento de error.log do MsExecauto
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if aLogErro != Nil .and. Len(aLogErro) > 0
	for nX := 1 To Len(aLogErro)
		cErro += aLogErro[nX] + cEol
	next
	cConteudo += cEol + cErro
endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Gravando o log de processamento
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
MemoWrite(cAnexo, cConteudo)

Return()
