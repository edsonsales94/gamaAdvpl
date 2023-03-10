#include "totvs.ch"
#include "xmlxfun.ch"
#include "ap5mail.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		BRAJOB13                                                      /@
@type				User function                                                 /@
@date				16/05/2016                                                    /@
@description	Job para envio de arquivo csv com informa鋏es do produto para 
					codifica鈬o na matriz Argentina.                              /@
@author			Adalberto Moreno Batista (Op鈬o Um Consultoria)               /@
@use				Especifico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function BRAJOB13()
Local aFiles	:= {"SB1", "ZR2"}
Local cEmp		:= "01"
Local cFil		:= "01"
Local nK, cTRAB

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Abertura do ambiente                                         
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
WfPrepEnv(cEmp, cFil, "U_BRAJOB13",, "FAT")

for nK := 1 to Len(aFiles)

	if Select(aFiles[nK]) = 0
	
		ChkFile(aFiles[nK])
		
	endif
	
next

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Cria subdiretorios                                                    
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
MakeDir("EDI01")
MakeDir("EDI01\ARGENTINA")
MakeDir("EDI01\ARGENTINA\OK")

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
// Seta ordem das tabelas a serem pesquisadas
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
SB1->(dbSetOrder(1))		//B1_FILIAL, B1_COD
ZR2->(dbSetOrder(2))		//ZR2_FILIAL, ZR2_ORDEN, ZR2_CODEMP
SX3->(dbSetOrder(2))		//X3_CAMPO

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Cria tabela temporaria para armazenamento dos itens a serem processados e
// de log de erros no processamento
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if A13BRAJOB(@cTRAB)

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Grava informa鋏es na tabela de trabalho
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	B13BRAJOB()
	
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Gera arquivo csv e envia e-mail com os produtos aos usuarios que os cadastraram
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	C13BRAJOB()
	
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	// Fecha tabela tempor疵ia e exclui arquivo de trabalho
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	if Select("TRAB") > 0
		TRAB->(dbCloseArea())
		fErase(cTRAB + GetDbExtension())
	endif

endif	
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Encerramento do ambiente                                     
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
RpcClearEnv()

ConOut(dTOc(Date()) + " - " + Time() + " BRAJOB13 - integra鈬o Protheus Brasil x Protheus Argentina - Arquivo de produtos.")
Return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		A13BRAJOB                                                     /@
@type				Static function                                               /@
@date				16/05/2016                                                    /@
@description	Acionado pela fun鈬o principal BRAJOB13, cria tabela 
					tempor疵ia para informa鋏es do produto.                       /@
@author			Adalberto Moreno Batista (Op鈬o Um Consultoria)               /@
@use				Especifico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function A13BRAJOB(cTRAB)
Local lRet		:= .F.
Local lCompart	:= .F.		//Caso verdadeiro, indica que a tabela deve ser aberta em modo compartilhado, isto ?, outros processos tamb駑 poder縊 abrir esta tabela.
Local lLeitura	:= .F.		//Caso verdadeiro, indica que este alias ser? usado apenas para leitura de dados. Caso contr疵io, estas opera鋏es ser縊 permitidas.
Local aStrTrb 	:= {}

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
// Busca campos a serem exportados na tabela ZR2
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
if ZR2->(dbSeek(xFilial("ZR2")))
	do while ZR2->(!eof() .and. ZR2_FILIAL == xFilial("ZR2"))
		if SX3->(dbSeek(ZR2->ZR2_CAMPO))
			aAdd(aStrTrb, {ZR2->ZR2_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
		endif
		ZR2->(dbSkip())
	enddo
	aAdd(aStrTrb, {"REGISTRO", "N", 10, 0})
	aAdd(aStrTrb, {"USUARIO", 	"C", 15, 0})
	
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	// Criacao da estrutura temporaria do arquivo de trabalho
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	if Select("TRAB") > 0
		TRAB->(dbCloseArea())
	endif
	
	cTRAB		:= CriaTrab(aStrTrb, .T.)
	dbUseArea(.T., __LocalDriver, cTRAB, "TRAB", lCompart, lLeitura)

	lRet := .T.
endif	

Return(lRet)


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		B13BRAJOB                                                     /@
@type				Static function                                               /@
@date				26/02/2016                                                    /@
@description	Acionado pela fun鈬o principal BRAJOB13, processa os registros
					de produtos que n縊 foram enviados para a Argentina.          /@
@author			Adalberto Moreno Batista (Op鈬o Um Consultoria)               /@
@use				Especifico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function B13BRAJOB()
Local cTpPrd		:= GetMV("BR_TPPRLIB", .F., "")
Local cNotInTipo	:= ""
Local nI

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Identificando as excecoes de pesquisa
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if !Empty(cTpPrd)
	cTpPrd := StrTran(cTpPrd, "#", chr(13) + chr(10))
	for nI := 1 to MlCount(cTpPrd)
		cNotInTipo += "'" + AllTrim(MemoLine(cTpPrd, 2, nI)) + "',"
	next
	cNotInTipo := Left(cNotInTipo, Len(cNotInTipo) - 1)
endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Selecionando registros
//substring(B1_USERLGI, 3, 1) + substring(B1_USERLGI, 7, 1) + 
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
cQuery := 	"SELECT *, R_E_C_N_O_ REGISTRO, "
cQuery += 			 "Substring(B1_USERLGI, 11, 1) + Substring(B1_USERLGI, 15, 1) + Substring(B1_USERLGI, 2, 1) + "
cQuery += 			 "Substring(B1_USERLGI, 6, 1) + Substring(B1_USERLGI, 10, 1) + Substring(B1_USERLGI, 14, 1) + "
cQuery += 			 "Substring(B1_USERLGI, 1, 1) + Substring(B1_USERLGI, 5, 1) + Substring(B1_USERLGI, 9, 1) + "
cQuery += 			 "Substring(B1_USERLGI, 13, 1) + Substring(B1_USERLGI, 17, 1) + Substring(B1_USERLGI, 4, 1) + "
cQuery += 			 "Substring(B1_USERLGI, 8, 1) USUARIO "
cQuery += 	"FROM " + RetSQLName("SB1") + " SB1 "
cQuery += 	"WHERE SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
cQuery += 			"AND SB1.B1_XSITUAC = '1' "
if !Empty(cNotInTipo)
	cQuery += 		"AND SB1.B1_TIPO NOT IN (" + cNotInTipo + ") "
endif
cQuery +=			"AND SB1.D_E_L_E_T_ = ' ' "
cQuery += 	"ORDER BY Substring(B1_USERLGI, 11, 1) + Substring(B1_USERLGI, 15, 1) + Substring(B1_USERLGI, 2, 1) + "
cQuery += 			 	"Substring(B1_USERLGI, 6, 1) + Substring(B1_USERLGI, 10, 1) + Substring(B1_USERLGI, 14, 1) + "
cQuery += 			 	"Substring(B1_USERLGI, 1, 1) + Substring(B1_USERLGI, 5, 1) + Substring(B1_USERLGI, 9, 1) + "
cQuery += 			 	"Substring(B1_USERLGI, 13, 1) + Substring(B1_USERLGI, 17, 1) + Substring(B1_USERLGI, 4, 1) + "
cQuery += 			 	"Substring(B1_USERLGI, 8, 1), "
cQuery += 			 	"B1_COD"

if Select("TEMP") > 0
	TEMP->(dbCloseArea())
endif
	
//cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TEMP", .F., .T.)
for nI := 1 to TRAB->(fCount())
	if Type(TRAB->(Field(nI)))=="D"
		TcSetField("TEMP", TRAB->(Field(nI)), "D")
	endif
next

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Processando sele鈬o de registros
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
dbSelectArea("TEMP")
dbGotop()
do while TEMP->(!eof())
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Grava tabela tempor疵ia
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	TRAB->(RecLock("TRAB", .T.))
	for nI := 1 to TRAB->(fCount())
		TRAB->(FieldPut(nI, TEMP->(FieldGet(FieldPos(TRAB->(Field(nI)))))))
	next
	TRAB->(MsUnlock())
	
	TEMP->(dbSkip())
enddo

if Select("TEMP") > 0
	TEMP->(dbCloseArea())
endif

Return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		C13BRAJOB                                                     /@
@type				Static function                                               /@
@date				16/05/2016                                                    /@
@description	Acionado pela fun鈬o principal BRAJOB13, gera csv para envio
					a Matriz Argentina, para a codifica鈬o do produto.            /@
@author			Adalberto Moreno Batista (Op鈬o Um Consultoria)               /@
@use				Especifico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function C13BRAJOB()
Local cEoLine		:= chr(13) + chr(10)
Local cEoField		:= ";"
Local lOk			:= .T.
Local cDestPadrao	:= GetMV("BR_CODPROD", .F., )
Local cDiretorio	:= "EDI01\ARGENTINA\"
Local cDetalhe, nI, cCampo, cArquivo, nHdl, cUserCad, aSB1, cDestinat, cErro, cAssunto, cMensagem

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Gera arquivo csv
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
dbSelectArea("TRAB")
dbGotop()

if TRAB->(!eof())
	do while TRAB->(!eof()) .and. lOk
	  
		lOk			:= .T.
		cUserCad 	:= TRAB->USUARIO
		cDestinat	:= UsrRetMail(AllTrim(TRAB->USUARIO))
		cArquivo		:= "SB1_" + AllTrim(cUserCad)+ "_" + dTOs(date()) + "_" + StrTran(Time(),":","") + ".CSV"
		nHdl			:= fCreate(cDiretorio + cArquivo)
		aSB1			:= {}

		cMensagem	:= '<html><body>' +;
							'<font size="2" face="Arial"> los registros del archivo adjunto.</font><br>' +;
							'<font size="2" face="Arial">Registrado por ' + UsrFullName(AllTrim(TRAB->USUARIO)) + ', eMail ' + AllTrim(cDestinat) + '.</font><br>' +;
							'<br><br><br><br>' +;
							'<font size="1.5" face="Calibri">Workflow Brasitech. E-mail enviado automaticamente, favor n縊 respond?-lo.<br><br>' +;
							'Esta mensagem pode conter informa鈬o confidencial e/ou privilegiada. Se voc? n縊 for o destinat疵io ou a pessoa '+;
							'autorizada a receber esta mensagem, n縊 pode usar, copiar ou divulgar as informa鋏es nela contidas ou tomar qualquer '+; 
							'a鈬o baseada nessas informa鋏es. Se voc? recebeu esta mensagem por engano, por favor, avise imediatamente o remetente, '+;
							'respondendo o e-mail, e em seguida apague-o. Agradecemos sua coopera鈬o.' +;
							'<br><br>' +;
							'This message may contain confidential and/or privileged information. If you are not the address or authorized to receive '+;
							'this for the address, you must not use, copy, disclose or take any action base on this message or any information herein. '+;
							'If you have received this message in error, please advise the sender immediately by reply e-mail and delete this message. '+;
							'Thank you for your cooperation. '+;
							'</font></body></html>'


		if Empty(cDestinat)
			cDestinat	:= cDestPadrao
		endif
		
		if nHdl == -1
		    ConOut("O arquivo " + cArquivo + " n縊 pode ser criado. Verifique direitos de acesso ao diret?rio")
		    Exit
		endif

		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		// Grava cabe軋lho do registro
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		cDetalhe := ""
		for nI := 1 to TRAB->(fCount())
			cDetalhe += TRAB->(Field(nI)) + cEoField
		next
			
		cDetalhe := StrTran(cDetalhe, ";REGISTRO;USUARIO;", "") + cEoLine

		if fWrite(nHdl, cDetalhe, Len(cDetalhe)) != Len(cDetalhe)
			ConOut("Erro na grava鈬o do cabe軋lho do registro de produtos para codifica鈬o pela matriz Argentina")
			lOk	:= .F.
		endif
		
		do while TRAB->(!eof() .and. USUARIO == cUserCad) .and. lOk

			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			// Grava registros detalhe
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			cDetalhe := ""
			for nI := 1 to TRAB->(fCount())
			
				cCampo := Field(nI)
				SX3->(dbSeek(cCampo))
				
				if !AllTrim(cCampo) $ "REGISTRO#USUARIO"
	
					if SX3->X3_TIPO == "N"
						cDetalhe	+= AllTrim(Str(TRAB->&cCampo)) + cEoField
					elseif SX3->X3_TIPO == "D"
						cDetalhe	+= dTOc(TRAB->&cCampo) + cEoField
					else
						if cCampo == "B1_COD"
							cDetalhe	+= "" + cEoField
						else
							cDetalhe	+= AllTrim(TRAB->&cCampo) + cEoField
						endif
					endif
		
				endif
				
			next
			cDetalhe := Left(cDetalhe, Len(cDetalhe) - 1) + cEoLine
		
			if fWrite(nHdl, cDetalhe, Len(cDetalhe)) != Len(cDetalhe)
				ConOut("Erro na grava鈬o do cabe軋lho do registro de produtos para codifica鈬o pela matriz Argentina")
				lOk	:= .F.
				Exit
			endif
		
			aAdd(aSB1, TRAB->REGISTRO)
		
			TRAB->(dbSkip())
			
		enddo

		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		// Fecha arquivo
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		FClose(nHdl)

		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		// Se processamento OK, inicia o processo de envio e atualiza鈬o de flag
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		if lOk

			cAssunto		:= "Solicitud de alta de producto - <BRASIL>. Archivo " + cArquivo
			cErro 		:= U_GISendMail(cDestinat,, cAssunto, cMensagem, cDiretorio + cArquivo)

			if Empty(cErro)
				__CopyFile(cDiretorio+ cArquivo, cDiretorio + "OK\" + cArquivo)

				//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
				// Se gerado com sucesso, marco a situa鈬o do produto com 2-Enviado
				//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
				For nI:=1 to Len(aSB1)
					SB1->(dbGoTo(aSB1[nI]))
					SB1->(RecLock("SB1",.F.))
					SB1->B1_XSITUAC := "2"
					SB1->(MsUnlock())
				Next

		   else

		   	lOk := .F.
		   	ConOut("BRAJOB13 - Erro no envio email para codificacao de produtos " + cErro)

		   endif

			fErase(cDiretorio + cArquivo)
		
		endif
	
	enddo

endif

Return()
