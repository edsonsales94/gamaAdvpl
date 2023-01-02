#include "protheus.ch"
#include "ap5mail.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		BRAJOB25                                                     /@
@type			User function                                                /@
@date			06/11/2021                                                   /@
@description	Rotina para uso em schedule. 								 
				Job para importacao de notas de faturas de cobrança de frete		
				partir de arquivo texto gerado pelo software GKO.						
				Será importado para a tabela de títulos a pagar do Protheus, a 	
				partir de arquivo texto (FRFA*.TXT) gerado pelo software GKO,		
				conforme layout INTFAT - EXPORTAÇÃO DE FATURAS
				Automatização da rotina BGKO04               		         /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
https://tdn.totvs.com/display/framework/FWLogMsg
https://tdn.totvs.com/display/framework/FWTemporaryTable
/*/
User Function BRAJOB25()
Local aFiles	:= {"ZZH", "ZZF"}
Local cLocDir	:= "edi01\gko\"
Local aFilGama	:= {}
Local nK, nF, nA, aFileFat, aApoio

MakeDir("edi01")
MakeDir("edi01\gko")

//———————————————————————————————————————————————————————————————————————————————
// Trata os arquivos de faturas e regrava-os de acordo com o CNPJ gravado 
// internamente.
//———————————————————————————————————————————————————————————————————————————————
aEmpresas 	:= BRAOpenSM0()
aFileFat	:= Directory(cLocDir + "FRCON*.TXT")

if Len(aEmpresas) > 0 .and. Len(aFileFat) > 0

	//———————————————————————————————————————————————————————————————————————————————
	// Abertura do ambiente
	//———————————————————————————————————————————————————————————————————————————————
	WfPrepEnv(aEmpresas[1, 1], aEmpresas[1, 2], "U_BRAJOB25",, "COM")

	for nF := 1 to Len(aFiles)
		if Select(aFiles[nF]) == 0
			ChkFile(aFiles[nF])
		endif
	next


	for nK := 1 to Len(aFileFat)

		aApoio := A_BRAJOB25(cLocDir, aFileFat[nK,1], aEmpresas)

		for nA:=1 to Len(aApoio)
			if Empty(aScan(aFilGama, aApoio[nA]))
				aAdd(aFilGama, aApoio[nA])
			endif
		next

	next

endif

//———————————————————————————————————————————————————————————————————————————————
// Encerramento do ambiente processamento arquivo texto
//———————————————————————————————————————————————————————————————————————————————
RpcClearEnv()


//———————————————————————————————————————————————————————————————————————————————
// Processamento por filial Abertura por filiais identificadas
//———————————————————————————————————————————————————————————————————————————————
for nK := 1 to Len(aFilGama)

	WfPrepEnv("01", aFilGama[nK], "U_BRAJOB25",, "COM")

	for nF := 1 to Len(aFiles)
		if Select(aFiles[nF]) == 0
			ChkFile(aFiles[nF])
		endif
	next

	B_BRAJOB25(aFilGama[nK])

	RpcClearEnv()

next

ConOut(dTOc(Date()) + " - " + Time() + " BRAJOB25 - Processo de importação de faturas (GKO)")
//FwLogMsg("INFO", /*cTransactionId*/, "SCHEDULE", FunName(), "", "01", dTOc(Date()) + " as " + Time() + " - BRAJOB25 - Processo de importação de faturas (GKO)", 0,0, {})

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		A_BRAJOB25                                                   /@
@type			Static function                                              /@
@date			20/12/2021                                                   /@
@description	Importa faturas de arquivo texto para tabelas de controle
				ZZH e ZZF                                                    /@
@author			Adalberto Moreno Batista (www.opcaoum.com.br)                /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function A_BRAJOB25(cLocDir, cFile, aEmpresas)
Local aRet		:= {}
Local cSeqCan	:= "   "
Local cLinha, cTipo, cCNPJ, cFatura, cPrefixo, dEmissao, nValor, cSerie, nDesconto,;
	  dVencto, cAuxCB, cMsgErro, cCodBar, lGrvCB, nX, cIdFilGama, nPos

dbSelectArea("ZZH")
dbSelectArea("ZZF")
//dbSelectArea("SF2")
//SF2->(dbSetOrder(1))	//F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, F2_TIPO

if FT_FUse(cLocDir + cFile) != -1
	
	FT_FGoTop()
	
	do while !FT_FEof()
	
		cLinha		:= FT_FReadLn()
		cTipo		:= Substr(cLinha, 1, 3)
		aNFDet	:= {}
				
		//———————————————————————————————————————————————————————————————————————————————
		// Dados da Fatura
		//———————————————————————————————————————————————————————————————————————————————
		if cTipo == "000"

			cCNPJGama	:= Substr(cLinha, 98, 14)
			cCNPJ		:= Substr(cLinha, 18, 14)
			cFatura		:= Substr(cLinha, 33, 09)
			cPrefixo	:= Substr(cLinha, 44, 03)
			dEmissao	:= cTOd(Substr(cLinha, 47, 10))
			nValor		:= Val(Substr(cLinha, 57, 15)) / 100
			nDesconto	:= Val(Substr(cLinha, 72, 15)) / 100
			dVencto		:= cTOd(Substr(cLinha, 87, 10))
			cAuxCB		:= AllTrim(Substr(cLinha, 112, 54))
			cMsgErro	:= ""
			aNFDet		:= {}
			cIdFilGama	:= ""

			nPos		:= aScan(aEmpresas, {|x| Upper(alltrim(x[3])) == cCNPJGama})
			if nPos > 0
				cIdFilGama	:= aEmpresas[nPos,2]

				nPos		:= aScan(aRet, {|x| x == cIdFilGama})
				if nPos == 0
					aAdd(aRet, cIdFilGama)
				endif
			endif

			//———————————————————————————————————————————————————————————————————————————————
			// Montagem do código de barras do título
			//———————————————————————————————————————————————————————————————————————————————
			cCodBar	 := ""
			for nX := 1 to Len(cAuxCB)
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
					elseif Len(AllTrim(cCodBar)) == 47	//linha digitavel para boletos registrados
						nVlCodBar	:= Val(Substr(cCodBar, 38, 10)) / 100
						dDtVctoBar 	:= cTOd("07/10/97") + Val(Substr(cCodBar, 34, 04))
					endif

					if nVlCodBar != (nValor-nDesconto) .or. dDtVctoBar != dVencto
						lGrvCB 	:= .F.
						cMsgErro := "O código de barras não será gravado, pois o valor do título ou a data de vencimento não batem com o valor e data de vencimento encontrado no código de barras."
					endif
				endif
			
				if !lGrvCB
					cCodBar := ""
				endif
				
			endif
		endif

		FT_FSkip()
		do while !FT_FEof() .and. Left(FT_FReadLn(),3) == "500"
			
			cLinha		:= FT_FReadLn()
			cTipo		:= Substr(cLinha, 1, 3)
			aConhec		:= {}

			//———————————————————————————————————————————————————————————————————————————————
			// Dados do conhecimento de frete
			//———————————————————————————————————————————————————————————————————————————————
			if cTipo == "500"

				aAdd(aConhec, Substring(cLinha,19,12))					//CDNC
				aAdd(aConhec, Substring(cLinha,31,3))					//CDSERIENC
				aAdd(aConhec, cTOd(Substring(cLinha,36,10)))			//DTEMISSAONC
				aAdd(aConhec, (Val(Substring(cLinha,46,15)) / 100))		//VRAPAGARCOBRADONC
				aAdd(aConhec, (Val(Substring(cLinha,121,12)) / 100))	//Valor previsto
				aAdd(aConhec, Substring(cLinha,133,20))					//IDUSURESPONSAVEL

			endif

			if Empty(Len(aConhec))
				aConhec := {"", "", dTOc(""), 0, 0, ""}
			endif

			FT_FSkip()
			do while !FT_FEof() .and. Left(FT_FReadLn(),3) == "550"

				cLinha		:= FT_FReadLn()
				cTipo		:= Substr(cLinha, 1, 3)

				//———————————————————————————————————————————————————————————————————————————————
				// Dados dos documentos de entrada
				//———————————————————————————————————————————————————————————————————————————————
				if cTipo == "550"
					//{CDNC,CDSERIENC,DTEMISSAONC,VRAPAGARCOBRADONC,IDUSURESPONSAVEL},
					//CDNOTA, SERIENF, DTEMISSAONF, EVENTO, VLRNF
					aAdd(aNFDet, { aConhec,;
								   Substring(cLinha,45,9),;
								   Substring(cLinha,57,3),;
								   cTOd(Substring(cLinha,35,10)),;
								   Substring(cLinha,75,15),;
								   Val(Substring(cLinha,90,16))/100})
				endif

				FT_FSkip()
			enddo

		enddo

		//Gravo somente quando tenho fatura e dados do conhecimento
		if Len(aNFDet) > 0

			if ZZH->(!dbSeek(cIdFilGama + cCNPJ + cFatura + cPrefixo + cSeqCan))

				ZZH->(RecLock("ZZH", .T.))
				ZZH->ZZH_FILIAL		:= cIdFilGama
				ZZH->ZZH_CNPJTR		:= cCNPJ
				ZZH->ZZH_FATURA		:= cFatura
				ZZH->ZZH_PREFIX		:= cPrefixo
				ZZH->ZZH_EMIS		:= dEmissao
				ZZH->ZZH_VALOR		:= nValor
				ZZH->ZZH_DESCON		:= nDesconto
				ZZH->ZZH_VENCTO		:= dVencto
				ZZH->ZZH_CODBAR		:= cCodBar
				ZZH->ZZH_ARQUIV		:= cFile
				ZZH->ZZH_LOG		:= "Importado em " + dTOc(Date()) + " as " + Time() + Chr(13) + Chr(10) + Repl("=",62) + Chr(13) + Chr(10)
				ZZH->ZZH_STATUS		:= "0"
				ZZH->(MsUnlock())

				for nX := 1 to Len(aNFDet)

					cSerie := aNFDet[nX,3]		//iif(Empty(aNFDet[nX,3]), "3", aNFDet[nX,3])

					ZZF->(RecLock("ZZF", .T.))
					ZZF->ZZF_FILIAL		:= cIdFilGama
					ZZF->ZZF_CNPJTR		:= cCNPJ
					ZZF->ZZF_FATURA		:= cFatura
					ZZF->ZZF_PREFIX		:= cPrefixo
					ZZF->ZZF_NCF		:= aNFDet[nX,1,1]
					ZZF->ZZF_NCFSER		:= aNFDet[nX,1,2]
					ZZF->ZZF_NCFEMI		:= aNFDet[nX,1,3]
					ZZF->ZZF_NCFVRE		:= aNFDet[nX,1,4]
					ZZF->ZZF_NCFVPR		:= aNFDet[nX,1,5]
					ZZF->ZZF_RESPLI		:= aNFDet[nX,1,6]
					ZZF->ZZF_NFBR		:= aNFDet[nX,2]
					ZZF->ZZF_SERBR		:= cSerie
					ZZF->ZZF_EMISBR		:= aNFDet[nX,4]
					ZZF->ZZF_EVENTO		:= aNFDet[nX,5]
					ZZF->ZZF_VALBR		:= aNFDet[nX,6]
					//if SF2->(dbSeek(cIdFilGama + aNFDet[nX,2] + cSerie))
					//	ZZF->ZZF_VALBR	:= SF2->F2_VALBRUT
					//endif
					ZZF->(MsUnlock())

				next

			else
				//gravalog - fatura já gravado no monitor
			endif
		else
			//gravalogerro - sem dados do grupo (cabecalho e rodapé) ou falha em um deles
		endif

		aNFDet := {}

	enddo

else
	//gravalogerro - não abriu arquivo
endif

FT_FUse()
fErase(cLocDir + cFile)

Return(aRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		B_BRAJOB25                                                   /@
@type			Static function                                              /@
@date			14/02/2022                                                   /@
@description	Processa os registros com status 0, por filial               /@
@author			Adalberto Moreno Batista (www.opcaoum.com.br)                /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function B_BRAJOB25(cIdFilGama)
Local cQuery	:=	"SELECT R_E_C_N_O_ REGISTRO, ZZH_CNPJTR, ZZH_FATURA, ZZH_PREFIX " +;
					"FROM " + RetSqlName("ZZH") + " ZZH " +;
					"WHERE ZZH_FILIAL = '" + xFilial("ZZH") + "' " +;
						"AND ZZH_STATUS = '0' " +;
						"AND D_E_L_E_T_= ' ' " +;
					"ORDER BY ZZH_CNPJTR, ZZH_FATURA, ZZH_PREFIX"

//———————————————————————————————————————————————————————————————————————————————
// Verificando a existencia da area Temporaria
//———————————————————————————————————————————————————————————————————————————————
if Select("TZZH") > 0
	TZZH->(dbCloseArea())
endif

//———————————————————————————————————————————————————————————————————————————————
// Criando a tabela temporaria
//———————————————————————————————————————————————————————————————————————————————
dbUseArea( .T., "TOPCONN", TcGenQRY(,,cQuery), "TZZH", .F., .T.)

SA2->(dbSetOrder(1))		//A2_FILIAL, A2_COD, A2_LOJA
ZZH->(dbSetOrder(1))		//ZZH_FILIAL, ZZH_CNPJTR, ZZH_FATURA, ZZH_PREFIX
ZZF->(dbSetOrder(1))		//ZZF_FILIAL, ZZF_CNPJTR, ZZF_FATURA, ZZF_PREFIX, ZZF_NCF, ZZF_NCFSER, ZZF_NFBR, ZZF_SERBR

dbSelectArea("TZZH")
TZZH->(dbGoTop())
do while TZZH->(!eof())
	
	ZZH->(dbGoTo(TZZH->REGISTRO))
	
	//———————————————————————————————————————————————————————————————————————————————
	// Realiza a integração com pedido de compra
	//———————————————————————————————————————————————————————————————————————————————
	U_MNT04Integra(.F.)

	TZZH->(dbSkip())

enddo

if Select("TZZH") > 0
	TZZH->(dbCloseArea())
endif

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		GRVLOG                                                       /@
@type			Static function                                              /@
@date			06/09/2014                                                   /@
@description	Função chamada pela static function BRAJOB04A. Grava log de
				processamento na tabela ZZ9                                  /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————

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
ZZ9->ZZ9_PROC		:= "GKO-FRFA"
ZZ9->ZZ9_TIPO		:= cTipoOcor
ZZ9->ZZ9_CHAVE		:= cChave
ZZ9->ZZ9_INDPRO		:= Lower(cQualArq)
ZZ9->ZZ9_DATA		:= dDtProc
ZZ9->ZZ9_HORA		:= cHrProc
ZZ9->ZZ9_RESUMO		:= cOcorrencia
ZZ9->ZZ9_LOG		:= cLog
ZZ9->(MsUnlock())

Return()


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


/*/
———————————————————————————————————————————————————————————————————————————————
@function		BRAOpenSM0                                                   /@
@type			Static function                                              /@
@date			06/11/2021                                                   /@
@description	Função para abertura da tabela de empresa                    /@
@author			Adalberto Moreno Batista - Opção Um Tecnologia da Informação /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function BRAOpenSM0()
Local lShared	:= .T.
Local aEmpresas	:= {}
Local nLoop := 0

For nLoop := 1 To 20
	dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )

	If !Empty(Select("SM0"))
		lOpen := .T.
		dbSetIndex("SIGAMAT.IND")
		SM0->(dbSeek("01"))
		do while SM0->(!eof() .and. M0_CODIGO == "01")
			if Empty(aScan(aEmpresas, {|x| Upper(alltrim(x[3])) == SM0->M0_CGC}))
				aAdd(aEmpresas, {SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_CGC, .F.})
			endif
			SM0->(dbSkip())
		enddo
		SM0->(dbCloseArea())
		Exit
	EndIf

	Sleep( 500 )
Next nLoop

If !lOpen
	ConOut("Não foi possível a abertura da tabela de empresas (SM0)")
EndIf

Return(aEmpresas)


