#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "TBICONN.CH"
#include "TOTVS.CH"

#define MB_ICONEXCLAMATION          48
#define MB_YESNO                    4
#define MB_OK                       0

/*/
———————————————————————————————————————————————————————————————————————————————
@function		BRAMNT07                                                     /@
@type			User function                                                /@
@date			06/10/2022                                                   /@
@description	Importação de notas de retorno de armazenagem do operador
				logistico.                                                   /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Tecnologia da Informação                            /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function BRAMNT07()
Local cFornece		:= PadR(GetMV("MV_XFOREDI", .F., "-"), 8)
Local cLoja			:= PadR(GetMV("MV_XLOJEDI", .F., "-"), 2)
Local cDiretorio	:= Getmv("MV_X_PATED", .F., "NAO-ENCONTRADO")
Local cTES			:= Getmv("MV_X_TESED", .F., "NAO-ENCONTRADO")
Local cEol			:= Chr(13) + Chr(10) + Chr(13) + Chr(10)
Local oFontAlert	:= TFont():New("Arial",,020,,.T.,,,,,.F.,.F.)
Local oFontText		:= TFont():New("Calibri",,016,,.F.,,,,,.F.,.F.)
Local nOpcao		:= 0
Local oDlg, oPainel, oGroup, oButton1, oButton2, cCNPJOper, cTexto

SA2->(dbSetOrder(1))
if SA2->(dbSeek(xFilial("SA2") + cFornece + cLoja)) .and. SA2->A2_MSBLQL != "1"
	cCNPJOper	:= SA2->A2_CGC
else
	Help(" ", 1, "ATENÇÃO",, "Fornecedor parametrizado em MV_XFOREDI e MV_XLOJEDI não encontrado no cadastro de fornecedores ou bloqueado." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
	Return()
endif

cTexto		:= "Importação das notas de retorno de armazenagem do operador logistico FM Logistics." + cEol +;
				"Os dados serão lidos a partir do XML disponibilizado no diretório pré-definido no parâmetro MV_X_PATED que possui o conteúdo '" + cDiretorio + "' e importados com o TES '" + cTES + "', definidos no parametro MV_X_TESED. " + cEol +;
				"Será avaliado o CNPJ do emissor do XML considerando a chave " + Transform(cCNPJOper, "@R 99.999.999/9999-99") + " e o CNPJ da Filial Brasitech." + cEol +;
				"Caso o diretório de pesquisa dos XMLs, CNPJ do emissor ou TES estejam incorretos, solicitar ao depto de TI corrigi-los através do preenchimento dos parâmetros BR_CNPJOPE e/ou MV_X_PATED e/ou MV_X_TESED."

Define Msdialog oDlg Title "Brasitech" From 000,000 to 350,600 Pixel
		
oPainel	:= TPanel():New(5, 5,, oDlg,,,,,, 300, 800+000, .F., .F.)
		
@ 003, 003 Group oGroup To 135, 288 of oPainel Pixel
@ 010, 010 Say "Filial " + AllTrim(SM0->M0_NOME) Size 220,011 Of oPainel Font oFontAlert Pixel Color CLR_BLUE
@ 035, 010 Say cTexto Size 280,100 Of oPainel FONT oFontText Pixel

@ 150, 210 Button oButton1 Prompt "Processar" 	Size 035,012 Pixel Of oPainel Action (nOpcao := 1, oDlg:End())
@ 150, 255 Button oButton2 Prompt "Cancelar"  	Size 035,012 Pixel Of oPainel Action (nOpcao := 0, oDlg:End())
		
Activate MsDialog oDlg Centered
		
if nOpcao == 1

	Processa({|lEnd| BeginProcess(cCNPJOper, cFornece, cLoja)}, "Importando os dados...", "", .T.)

else

	MessageBox("Processo cancelado!", "Alerta", MB_ICONEXCLAMATION)

endif

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		BEGINPROCESS                                                 /@
@type			Static function                                              /@
@date			06/10/2022                                                   /@
@description	Lê os arquivos XML's e importa as informações                /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Tecnologia da Informação                            /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function BeginProcess(cCNPJOper, cFornece, cLoja)
Local cDirNImp	:= AllTrim(Getmv("MV_X_PATED"))
Local cDirImp   := cDirNImp +"IMPORTADOS\"
Local cDirProbl := cDirNImp +"INCONSISTENCIA\"
Local aFiles	:= Directory(cDirNImp + "*.XML", "D")
Local aOcor		:= {}
Local cDoc		:= ""
Local cSerie	:= ""
Local cProblema	:= ""
Local nFilesVld	:= 0
Local nY, nHdl, nTamFile, cBuffer, oNFe, cDestinat

MakeDir(cDirNImp)
MakeDir(cDirImp)
MakeDir(cDirProbl)

if Len(aFiles) > 0

	For nY := 1 to Len(aFiles)

		if aFiles[nY][2] > 0	//Somente se o tamanho do arquivo for maior que zero
			
			nHdl 	:= fOpen(cDirNImp + aFiles[nY][1], 0)

			if nHdl == -1
				Loop
			else

				nTamFile	:= fSeek(nHdl,0,2)
				fSeek(nHdl,0,0)
				cBuffer	:= Space(nTamFile)		 //Variavel para criacao da linha do registro para leitura
				fRead(nHdl, @cBuffer, nTamFile)  //Leitura do arquivo XML
				fClose(nHdl)

				//———————————————————————————————————————————————————————————————————————————————
				// Checagem CNPJ do operador logistico, retorna:
				//		.T. Se CNPJ emitente for igual ao BR_CNPJOPE
				//		.F. Se CNPJ emitente for diferente BR_CNPJOPE
				// abre o cBuffer com o xmlparse
				//———————————————————————————————————————————————————————————————————————————————
				if CheckCNPJ(cBuffer, @oNFe, cCNPJOper)
					
					nFilesVld++

					if ProcRegistro(oNFe, @cDoc, @cSerie, cFornece, cLoja, @cProblema)
						aAdd(aOcor, {cDoc + "/" + cSerie, "Importada"})
						cDestinat := cDirImp

					else

						aAdd(aOcor, {cDoc + "/" + cSerie, "Rejeitada - " + cProblema})
						cDestinat := cDirProbl

					endif

					// movimentando o arquivo lido
					if File(cDirNImp + aFiles[nY,1])
						Copy File (cDirNImp + aFiles[nY,1]) To (cDestinat + aFiles[nY,1])
						FErase(cDirNImp + aFiles[nY,1])
					endif
				
				endif


			endif

		endif

	Next

	if Len(aOcor) > 0
		MostraLog(aOcor)
	endif

	if Empty(nFilesVld)
		Help(" ", 1, "ATENÇÃO",, "Não foram encontrados arquivos XML para a respectiva filial." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
	endif

else

	Help(" ", 1, "ATENÇÃO",, "Não foram encontrados arquivos XML para importação de notas de retorno de armazenagem." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)

endif

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		CHECKCNPJ                                                    /@
@type			Static function                                              /@
@date			06/10/2022                                                   /@
@description	Lê os arquivos XML's e importa as informações                /@
@parameters		Recebe string, objeto e CNPJ do operador logistico. Retorna
				o XML lido e .T./.F. para o processamento do registro        /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Tecnologia da Informação                            /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function CheckCNPJ(cBuffer, oNFe, cCNPJOper)
Local lRet		:= .F.
Local cAviso	:= ""
Local cErro		:= ""
Local oNFeDetail, cIdEmit, cIdDest

if "http://www.portalfiscal.inf.br/nfe" $ cBuffer 	//?xml version="1.0" encoding="UTF-8"?

	oNFe	:= XmlParser(cBuffer, "_", @cAviso, @cErro)

	//———————————————————————————————————————————————————————————————————————————————
	// Verifica se é uma nota fiscal válida
	//———————————————————————————————————————————————————————————————————————————————
	if (XmlChildEx(oNFe,"_NFE") <> NIL .and. XmlChildEx(oNFe:_NFe, "_INFNFE") <> NIL) .or.;
		(XmlChildEx(oNFe,"_NFEPROC") <> NIL .and. XmlChildEx(oNFe:_NFEPROC,"_NFE") <> NIL .and. XmlChildEx(oNFe:_NFEPROC:_NFe, "_INFNFE") <> NIL)

		if XmlChildEx(oNFe,"_NFE") <> NIL
			oNFeDetail	:= oNFe:_NFe:_InfNFe
		else
			oNFeDetail	:= oNFe:_NFeProc:_NFe:_InfNFe
		endif

		cIdEmit		:= AllTrim(oNFeDetail:_EMIT:_CNPJ:TEXT)				//14 - CNPJ Emissor
		if XmlChildEx(oNFeDetail:_DEST,"_CPF") != NIL
			cIdDest		:= AllTrim(oNFeDetail:_DEST:_CPF:TEXT)			//14,0 - CPF
		elseif XmlChildEx(oNFeDetail:_DEST,"_CNPJ") != NIL
			cIdDest		:= AllTrim(oNFeDetail:_DEST:_CNPJ:TEXT)			//14,0 - CNPJ
		endif

		lRet 	:= (cIdEmit == cCNPJOper .and. cIdDest == SM0->M0_CGC)

	endif

endif

Return(lRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		PROCREGISTRO                                                 /@
@type			Static function                                              /@
@date			13/10/2022                                                   /@
@description	Processa o XML e importa a nota de retorno de armazenagem    /@
@parameters		Recebe o objeto XML para leitura                             /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Tecnologia da Informação                            /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function ProcRegistro(oNFe, cDoc, cSerie, cFornece, cLoja, cProblema)
Local cTesEDI			:= GetMV("MV_X_TESED", .F., "-")
Local lRet				:= .F.
Local aItensNF			:= {}
Local cIdEmit, cIdNF, dDtEmis, cTpNF, nX

SA3->(dbSetOrder(3))		//A3_FILIAL, A3_CGC
SA4->(dbSetOrder(3))		//A3_FILIAL, A3_CGC
SB1->(dbSetOrder(1))		//B1_FILIAL, B1_COD
SF1->(dbSetOrder(1))		//F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO
SF4->(dbSetOrder(1))		//F4_FILIAL, F4_CODIGO

//———————————————————————————————————————————————————————————————————————————————
// Define objeto oNFeDetail
//———————————————————————————————————————————————————————————————————————————————
if XmlChildEx(oNFe,"_NFE") <> NIL
	oNFeDetail	:= oNFe:_NFe:_InfNFe
else
	oNFeDetail	:= oNFe:_NFeProc:_NFe:_InfNFe
endif

cIdEmit		:= oNFeDetail:_EMIT:_CNPJ:TEXT				//14 - CNPJ Emissor
//———————————————————————————————————————————————————————————————————————————————
// Alimenta variáveis referentes a chave do documento de entrada
//———————————————————————————————————————————————————————————————————————————————
cDoc   		:= StrZero(Val(oNFeDetail:_IDE:_NNF:TEXT),9)								//09,0 - Nota Fiscal
cSerie 		:= Padr(AllTrim(Str(Val(oNFeDetail:_IDE:_SERIE:TEXT),3)),3)					//03,0 - Serie

if XmlChildEx(oNFeDetail:_DEST,"_CPF") != NIL
	cIdOrDe		:= oNFeDetail:_DEST:_CPF:TEXT									  		//14,0 - CPF
elseif XmlChildEx(oNFeDetail:_DEST,"_CNPJ") != NIL
	cIdOrDe		:= oNFeDetail:_DEST:_CNPJ:TEXT											//14,0 - CNPJ
endif

//———————————————————————————————————————————————————————————————————————————————
// Valida se o CNPJ do fornecedor é o mesmo do XML
//———————————————————————————————————————————————————————————————————————————————
if SA2->A2_CGC == cIdEmit  
	lRet := .T.
else
	cProblema := "CNPJ do fornecedor parametrizado em MV_XFOREDI e MV_XLOJEDI é diferente do lido no XML."
	Return(lRet)
endif

//———————————————————————————————————————————————————————————————————————————————
// Verifica se a nota já está gravada
//———————————————————————————————————————————————————————————————————————————————
if SF1->(dbSeek(xFilial("SF1") + cDoc + cSerie + cFornece + cLoja))
	cProblema := "Documento e série já cadastrado."
	Return(lRet)
endif

//———————————————————————————————————————————————————————————————————————————————
// Continua com a leitura dos dados do XML
//———————————————————————————————————————————————————————————————————————————————
cIdNF  		:= Substring(oNFeDetail:_ID:TEXT,4,44)														//47,0 - Ident. NFe
cIdEmit		:= oNFeDetail:_EMIT:_CNPJ:TEXT												//14,0 - CNPJ Emissor
dDtEmis		:= StrTran(Left(oNFeDetail:_IDE:_DHEMI:TEXT,10),"-","")
dDtEmis		:= cTOd(Right(dDtEmis,2) + "/" +;
				Substr(dDtEmis,5,2) + "/" +;
				Substr(dDtEmis,3,2))													//não usar a função sTOd			08,0 - Data Emissao
cTpNF  		:= oNFeDetail:_IDE:_TPNF:TEXT												//01,0 - Tipo Operac

//———————————————————————————————————————————————————————————————————————————————
// Itens da nota
//———————————————————————————————————————————————————————————————————————————————
if Type("oNFeDetail:_DET") == "A"
	//Mais de um item
	For nX:=1 To Len(oNFeDetail:_DET)

		cProduto	:= PadR(Substring(oNFeDetail:_DET[nX]:_PROD:_CPROD:TEXT, 1, 15), 15)
		cDocOri		:= "00000" + Substring(oNFeDetail:_DET[nX]:_INFADPROD:TEXT, 6, 4)
		cSerieOri	:= PadR(Substring(oNFeDetail:_DET[nX]:_INFADPROD:TEXT, 19, 1), 3)
		aOrigem		:= GetTerceiros(cProduto, cDocOri, cSerieOri, cFornece, cLoja)
		cTipoNF		:= iif(aOrigem[5]=="F", "N", "B")

		aAdd(aItensNF, { 	{"D1_ITEM",		StrZero(Val(oNFeDetail:_DET[nX]:_NITEM:TEXT),4),	Nil},;
							{"D1_COD",		cProduto,											Nil},;
							{"D1_UM",		oNFeDetail:_DET[nX]:_PROD:_UCOM:TEXT,				Nil},;
							{"D1_LOCAL",	aOrigem[3],											Nil},;
							{"D1_QUANT",	Val(oNFeDetail:_DET[nX]:_PROD:_QCOM:TEXT),			Nil},;
							{"D1_VUNIT",	Val(oNFeDetail:_DET[nX]:_PROD:_VUNCOM:TEXT),		Nil},;
							{"D1_TOTAL",	Val(oNFeDetail:_DET[nX]:_PROD:_VPROD:TEXT),			Nil},;
							{"D1_TES",		cTesEDI,											Nil},;
							{"D1_EMISSAO",	dDtEmis,											Nil},;
							{"D1_NFORI",	cDocOri,											Nil},;
							{"D1_SERIORI",	cSerieOri,											Nil},;
							{"D1_ITEMORI",	aOrigem[1],											Nil},;
							{"D1_IDENTB6",	aOrigem[2],											Nil}	})

	Next

else

	cProduto	:= PadR(Substring(oNFeDetail:_DET:_PROD:_CPROD:TEXT, 1, 15), 15)
	cDocOri		:= "00000" + Substring(oNFeDetail:_DET:_INFADPROD:TEXT, 6, 4)
	cSerieOri	:= PadR(Substring(oNFeDetail:_DET:_INFADPROD:TEXT, 19, 1), 3)
	aOrigem		:= GetTerceiros(cProduto, cDocOri, cSerieOri, cFornece, cLoja)
	aAdd(aItensNF, {	{"D1_ITEM",		StrZero(Val(oNFeDetail:_DET:_NITEM:TEXT),4),		Nil},;
						{"D1_COD",		cProduto,											Nil},;
						{"D1_UM",		oNFeDetail:_DET:_PROD:_UCOM:TEXT,					Nil},;
						{"D1_LOCAL",	aOrigem[3],											Nil},;
						{"D1_QUANT",	Val(oNFeDetail:_DET:_PROD:_QCOM:TEXT),				Nil},;
						{"D1_VUNIT",	Val(oNFeDetail:_DET:_PROD:_VUNCOM:TEXT),			Nil},;
						{"D1_TOTAL",	Val(oNFeDetail:_DET:_PROD:_VPROD:TEXT),				Nil},;
						{"D1_TES",		cTesEDI,											Nil},;
						{"D1_EMISSAO",	dDtEmis,											Nil},;
						{"D1_NFORI",	cDocOri,											Nil},;
						{"D1_SERIORI",	cSerieOri,											Nil},;
						{"D1_ITEMORI",	aOrigem[1],											Nil},;
						{"D1_IDENTB6",	aOrigem[2],											Nil}	})

endif

if Len(aItensNF) > 0	//If _nTotItem == _nTotNf
	aCabNF	:= {	{"F1_TIPO",		cTipoNF,	Nil},;
					{"F1_FORMUL",	"N",		Nil},;
					{"F1_DOC",		cDoc,		Nil},;
					{"F1_SERIE",	cSerie,		Nil},;
					{"F1_EMISSAO",	dDtEmis,	Nil},;
					{"F1_FORNECE",	cFornece,	Nil},;
					{"F1_LOJA",		cLoja,		Nil},;
					{"F1_ESPECIE",	"SPED",		Nil},;
					{"F1_CHVNFE",	cIdNF,	Nil}	}


	Begin Transaction

		lMsErroAuto := .F.
		MsgRun("Incluindo NF retorno armazenagem  " + cDoc + "/" + cSerie, "Aguarde...",{|| MSExecAuto({|x,y,z| MATA103(x,y,z)}, aCabNF, aItensNF, 3)})
		
		If lMsErroAuto
			DisarmTransaction()
			cProblema := "Erro na automatização da inclusão da NF."
			lRet := .F.
		Else
			lRet := .T.
		Endif

	End Transaction

endif

Return(lRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		GETTERCEIROS                                                 /@
@type			Static function                                              /@
@date			24/02/2009                                                   /@
@description	Busca dados de poder em terceiros.                           /@
@author			Wilson Cruz - Totvs                                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function GetTerceiros(cProduto, cDocOri, cSerieOri, cFornece, cLoja)
Local aRet		:= {"", "", "", 0, ""}
Local cFilSD2	:= SD2->(xFilial("SD2"))

BeginSQL Alias "RETARMAZ"
	Select D2_DOC, D2_SERIE, D2_ITEM, D2_IDENTB6, B6_SALDO, B6_LOCAL, B6_TPCF
	From %table:SD2% SD2 Inner Join %table:SB6% SB6
		On B6_DOC=D2_DOC
		and B6_SERIE=D2_SERIE
		and B6_PRODUTO=D2_COD
		and B6_CLIFOR=D2_CLIENTE
		and B6_LOJA=D2_LOJA
		and B6_IDENT=D2_IDENTB6
	Where D2_FILIAL=%Exp:cFilSD2%
		and D2_DOC=%Exp:cDocOri%
		and D2_SERIE=%Exp:cSerieOri%
		and D2_COD=%Exp:cProduto%
		and D2_CLIENTE=%Exp:cFornece%
		and D2_LOJA=%Exp:cLoja%
		and SD2.%notDel%
		and B6_SALDO>0
		and SB6.%notDel%
EndSql

if RETARMAZ->(!eof())
	aRet := {RETARMAZ->D2_ITEM, RETARMAZ->D2_IDENTB6, RETARMAZ->B6_LOCAL, RETARMAZ->B6_SALDO, RETARMAZ->B6_TPCF}
//	do While RETARMAZ->(!eof())
//		RETARMAZ->(aAdd(aRet, D2_ITEM, D2_IDENTB6, B6_LOCAL, B6_SALDO, B6_TPCF))
//		RETARMAZ->(dbSkip())
//	enddo
endif

if Select("RETARMAZ") > 0
	RETARMAZ->(dbCloseArea())
endif

Return(aRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		MostraLog                                                    /@
@type			Static function                                              /@
@date			25/02/2009                                                   /@
@description	Apresenta arquivo log de processamento                       /@
@author			Wilson Cruz - Totvs                                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function MostraLog(aOcor)
Local cFileLog := NomeAutoLog()
Local cPath := ""
Local nI

AutoGrLog("Importacao Notas Entrada")
AutoGrLog("-----------------------------")
AutoGrLog("Documento            Status")

For nI := 1 To Len(aOcor)
	AutoGrLog(aOcor[nI,1] + Space(10) + aOcor[nI,2])
Next

AutoGrLog("")
AutoGrLog("Para maiores detalhes das notas")
AutoGrLog("rejeitadas, consulte arquivo de Log.")

if !Empty(cFileLog)
	MostraErro(cPath, cFileLog)
	fErase(cPath + cFileLog)
endif

Return()
