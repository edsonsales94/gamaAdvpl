#include "protheus.ch"
#include "Ap5Mail.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		BRAJOB14                                                     /@
@type			User function                                                /@
@date			06/10/2016                                                   /@
@description	Job para leitura e processamento de arquivos do GKO para
				atualização das datas de entrega, vencimento do título, e
				histórico do vencimento.                                     /@
@author			Adalberto Moreno Batista (Opção Um Consultoria)
				amoreno@opcaoum.com.br                                       /@
@use			Brasitech                                                    /@
@Ajustes
06/01/21 -	Alterado para gravar a data de entrega na nota, independente do
			ajuste de vencimento do título. Antes, a informação era atualizada
			somente qdo havia a necessidade de ajuste do vencto do titulo
		 -	Conforme solicitação por email enviado por Jorge Job, retirada a
		 	atualização da data de vencimento E1_VENCTO
		 -	Alterada a forma de gravação do log de operações, de arquivo txt
		 	para registros na ZZ9. Alterado também para envio de emails
			somente com os problemas encontrados.
		 -	Incluida mensagens para qdo arquivo vazio ou não possuir ocorrencias
		 	de entrega ou qdo atualizar data de entrega na nota ou qdo o cliente
		 	não possuir configuração para ajuste da data de vencimento.
19/01/21 -	Ajuste para consideração do historico do tipo de pagamento e para 
			isto passarei a olhar E1_XTPVCTO ao inves do A1_XTPVCTO
———————————————————————————————————————————————————————————————————————————————
/*/
User Function BRAJOB14()
Local aFiles		:= {"SA1", "SE1", "SF2", "ZZ2"}
Local cEmp			:= "01"
Local aFil			:= {"01", "03", "09"}
Local _cQuery	
Local cAliasQry :=GetNextAlias()
Local nJ, nK
Private dDtProc	:= Date()
Private cHrProc	:= Time()
Private cQualArq


// MakeDir("edi01")
// MakeDir("edi01\gko")
// MakeDir("edi01\gko\ok")

for nJ := 1 to Len(aFil)

	//———————————————————————————————————————————————————————————————————————————————
	// Abertura do ambiente                                         
	//———————————————————————————————————————————————————————————————————————————————
	WfPrepEnv(cEmp, aFil[nJ], "U_BRAJOB14",, "FAT")
	
	for nK := 1 to Len(aFiles)
	
		if Select(aFiles[nK]) = 0
		
			ChkFile(aFiles[nK])
			
		endif
		
	next

	_cQuery:="	SELECT DISTINCT				"
	_cQuery+="		MNOTA.CDNOTA,				"
	_cQuery+="		CDSERIE,		"
	_cQuery+="		SE1.E1_PARCELA  PARCELA,	"
	_cQuery+="		DTOCORRENCIA,				"
	_cQuery+="		MOCORRENCIA.DTREGISTRO,			"
	_cQuery+="		CDPROCEDA,				"
	_cQuery+="		DSTIPOOCORRENCIA,				"
	_cQuery+="		CPARCEIROCOMERCIAL.NMPARCEIROCOMERCIAL, 				"
	_cQuery+="		MOCORRENCIA.IDTIPOOCORRENCIA				"
	_cQuery+="		FROM [172.16.10.248].[GKOSCF_P].[GKOSCF].[FMNOTA] MNOTA				"
	_cQuery+="		LEFT JOIN [172.16.10.248].[GKOSCF_P].[GKOSCF].[FMOCORRE] MOCORRENCIA  (NOLOCK) ON MOCORRENCIA.IDMOVIMENTO = MNOTA.IDNOTA AND MOCORRENCIA.IDTRANSPORTADORA = MNOTA.IDTRANSPORTADORA 			"
	_cQuery+="		LEFT JOIN [172.16.10.248].[GKOSCF_P].[GKOSCF].[FCTPOOCO] CTIPOOCORRENCIA  (NOLOCK) ON CTIPOOCORRENCIA.IDTIPOOCORRENCIA = MOCORRENCIA.IDTIPOOCORRENCIA 				"
	_cQuery+="		LEFT JOIN [172.16.10.248].[GKOSCF_P].[GKOSCF].[FCPARCOM] CPARCEIROCOMERCIAL  (NOLOCK) ON CPARCEIROCOMERCIAL.IDPARCEIROCOMERCIAL = MNOTA.IDPARDESTREMET			 				"
	_cQuery+="		LEFT JOIN  "+RetSQLName("SE1")+" SE1  (NOLOCK) ON SE1.E1_NUM = MNOTA.CDNOTA AND SE1.E1_SERIE = CDSERIE AND SE1.E1_EMISSAO = MNOTA.DTEMISSAO AND SE1.E1_XALTVEN =''		"
	_cQuery+="		WHERE 				"
	_cQuery+="		(1=1						"
	_cQuery+="		AND  SE1.D_E_L_E_T_=''				"
	_cQuery+="		AND  SE1.E1_EMISSAO > '20220101')			"
	//_cQuery+="		AND MNOTA.CDNOTA in ('000153473')			"
	_cQuery+="		AND SE1.E1_TIPO ='NF' "
	_cQuery+="		AND SE1.E1_XALTVEN='' "
	_cQuery+="		AND MOCORRENCIA.IDTIPOOCORRENCIA IN ('819','822')	"
	//_cQuery+="		AND MOCORRENCIA.DTREGISTRO = '20220926'	"
	_cQuery+="		AND MOCORRENCIA.DTREGISTRO = CAST(GETDATE()AS DATE)    "
	_cQuery+="		Order by CDNOTA		"

	_cQuery:= ChangeQuery(_cQuery)
   	dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(_cQuery)),cAliasQry,.T.,.F.)

	//———————————————————————————————————————————————————————————————————————————————
	// Lê e processa arquivos de entrega
	//———————————————————————————————————————————————————————————————————————————————
	While (cAliasQry)->(!EoF())
		A14_BRAJOB(cAliasQry)
	(cAliasQry)->(DbSkip())
	EndDo

	// B14_BRAJOB()

	//———————————————————————————————————————————————————————————————————————————————
	// Encerramento do ambiente                                     
	//———————————————————————————————————————————————————————————————————————————————
	RpcClearEnv()
   
	ConOut(dTOc(Date()) + " - " + Time() + " BRAJOB14 - Conclusão da atualização de entregas/datas de vencimento. Empresa " + cEmp + " Filial " + aFil[nJ])
	
next

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		A14_BRAJOB                                                   /@
@type			Static function                                              /@
@date			11/10/2016                                                   /@
@description	Processa os arquivos lidos no diretorio EDI01\entrega        /@
@author			Adalberto Moreno Batista (Opção Um Consultoria)              /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function A14_BRAJOB(cAliasQry)
Local lRet		:= .T.
Local lOcorEntr	:= .F.
Local cSerie, cNota, cCdOcor, dDtEntr,cParcela

//———————————————————————————————————————————————————————————————————————————————
// Seta ordem de tabelas              
//———————————————————————————————————————————————————————————————————————————————
SA1->(dbSetOrder(1))		//A1_FILIAL+A1_COD+A1_LOJA
SF2->(dbSetOrder(1))		//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO

	cSerie		:= (cAliasQry)->CDSERIE
	cNota		:= (cAliasQry)->CDNOTA
	cCdOcor		:= (cAliasQry)->CDPROCEDA
	cParcela	:= (cAliasQry)->PARCELA
	
    SE1->(dbSetOrder(2))
	
	if (cCdOcor == "00001" .or. cCdOcor == "00002")  		//001-Entrega normal ou 002-Entrega fora da dt. programada
		
		lOcorEntr	:= .T.
		dDtEntr		:= (cAliasQry)->DTOCORRENCIA
		
		if SF2->(dbSeek(xFilial("SF2") + ALLTRIM(cNota) + (cSerie)))

			// if SF2->F2_DTENTR != dDtEntr  
				SF2->(RecLock("SF2", .F.))
					SF2->F2_DTENTR	:= dDtEntr
				SF2->(MsUnlock())

				//  ("", A ,B ou C)
				If SE1->(dbSeek(xFilial("SE1") + SF2->(F2_CLIENTE + F2_LOJA + F2_PREFIXO + F2_DOC)+cParcela))

					SE1->(RecLock("SE1", .F.))
						SE1->E1_XALTVEN		:= "1"
					SE1->(MsUnlock())

				EndIf

			// endif

			GrvLog("0", "NF [" + SF2->(F2_DOC + "/" + F2_SERIE) + "]", "Atualizada a data de entrega da nota fiscal [" + SF2->(F2_DOC + "/" + F2_SERIE) + "]." )
			
			if SA1->(dbSeek(xFilial("SA1") + SF2->(F2_CLIENTE + F2_LOJA)))

				if SE1->E1_XTPVCTO == "2" .or. (Empty(SE1->E1_XTPVCTO) .and. SA1->A1_XTPVCTO == "2") //vencimento pela entrega
					AltDtEntr(dDtEntr)
				else
					GrvLog("1", "CLIENTE [" + SF2->(F2_CLIENTE + "/" + F2_LOJA) + "]", "Não possui configuração para alterção de vencimento por data de entrega [" + SF2->(F2_CLIENTE + "/" + F2_LOJA) + "].  ")
				endif

			else

				GrvLog("2", "CLIENTE [" + SF2->(F2_CLIENTE + "/" + F2_LOJA) + "]", "Não localizado o cadastro de cliente [" + SF2->(F2_CLIENTE + "/" + F2_LOJA) + "]. " )

			endif	

		else

			GrvLog("2", "NF [" + cNota + "/" + cSerie + "]", "Não localizada a nota fiscal [" + cNota + "/" + cSerie + "].  ")

		endif
		
	endif

if lRet
	//———————————————————————————————————————————————————————————————————————————————
	// Se arquivo sem ocorrencias de entrega, gravo log de alerta
	//———————————————————————————————————————————————————————————————————————————————
	if !lOcorEntr
		GrvLog("1", "", "Arquivo "/* + "*/+" sem ocorrencias de entrega 001 ou 002")
	endif
endif

Return(lRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		B14_BRAJOB                                                   /@
@type			Static function                                              /@
@date			13/10/2016                                                   /@
@description	Envia log de processamento.                                  /@
@author			Adalberto Moreno Batista (Opção Um Consultoria)              /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function B14_BRAJOB()
Local cLinkLogo	:= AllTrim(GetMV("BR_LNKLOGO", .F., "https://sweb.gamaitaly.com.br/images/LogoGamaPeq.jpg"))
Local cDestinat	:= AllTrim(GetMV("BR_EMJOB14", .F., "edson.sales@gamaitaly.com.br")) //equipe.ti@gamaitaly.com.br
Local cAssunto	:= "Brasitech/" + Lower(AllTrim(SM0->M0_FILIAL)) + " - Log de importação de datas de entrega (GKO) " + dTOc(dDtProc) + " às " + cHrProc
Local cQuery	:=	"SELECT R_E_C_N_O_ REGISTRO " +;
						"FROM " + RetSqlName("ZZ9") + " ZZ9 " +;
						"WHERE ZZ9.ZZ9_FILIAL = '" + xFilial("ZZ9") + "' " +;
								"AND ZZ9.ZZ9_TIPO = '2' " +;
								"AND ZZ9.ZZ9_DATA = '" + dTOs(dDtProc) + "' " +;
								"AND ZZ9_PROC = 'GKO-OCO' " +;
								"AND ZZ9.D_E_L_E_T_= ' ' " +;
						"ORDER BY ZZ9_INDPRO "
//"AND ZZ9.ZZ9_HORA = '" + cHrProc + "' " +;
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

	cHtml += 'Inconsistências no processo da atualização de datas de entrega de produtos conforme arquivo disponibilizado pelo software GKO. Processo GKO-OCO executado pela rotina DKTJOB14. <br>Filial '+AllTrim(SM0->M0_FILIAL)+'.<br>Leitura de arquivos "edi0\OCO*.TXT".</p>'
		
	cHtml += '<table style="width: 100%">'
	cHtml += '	<tr>'
	cHtml += '		<td class="style4" style="width: 20%">Chave</td>'
	cHtml += '		<td class="style4" style="width: 20%">Arquivo</td>'
	cHtml += '		<td class="style4" style="width: 60%">Inconsistência</td>'
	cHtml += '	</tr>'
	
	lInverte := .T.

	do while TMPLOG->(!eof())
		
		ZZ9->(dbGoTo(TMPLOG->REGISTRO))

		lInverte := !lInverte
			
		cHtml += '	<tr>'
		cHtml += '		<td class="' + iif(lInverte, 'style3', 'style2') + '" style="width: 20%">' + AllTrim(ZZ9->ZZ9_CHAVE) + '</td>'
		cHtml += '		<td class="' + iif(lInverte, 'style3', 'style2') + '" style="width: 20%">' + AllTrim(ZZ9->ZZ9_INDPRO) + '</td>'
		cHtml += '		<td class="' + iif(lInverte, 'style3', 'style2') + '" style="width: 60%">' + ZZ9->ZZ9_LOG + '</td>'
		cHtml += '	</tr>'

		TMPLOG->(dbSkip())

	enddo

	cHtml += '</table>'
	
else

	cHtml += 'Não foram encontradas inconsistências no processo de atualização de datas de entrega, processo GKO-OCO executado pela rotina DKTJOB14.<br>Filial '+AllTrim(SM0->M0_FILIAL)+'.<br>Leitura de arquivos "edko\OCO*.TXT".</p>'

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
@function		AltDtEntr                                                    /@
@type		 	Static function                                              /@
@date			13/10/2016                                                   /@
@description	Preenche a data de entrega da mercadoria na nota e atualiza a
				data de vencimento dos titulos quando o tipo de vencimento do
				cliente for a partir da entrega (A1_XTPVCTO=="2")            /@
@author			Adalberto Moreno Batista (Opção Um Consultoria)              /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function AltDtEntr(dDtEntr)
Local aArea			:= GetArea()
//Local cTipoTit		:= MVNOTAFIS
Local dBkpDtBase	:= dDataBase
Local aVencto		:= {}
Local nK, dDtAnter

SE1->(dbSetOrder(2))			//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
if AliasInDic("FI2")
	FI2->(DbSetOrder(1))		//FI2_FILIAL, FI2_CARTEI, FI2_NUMBOR, FI2_PREFIX, FI2_TITULO, FI2_PARCEL, FI2_TIPO, FI2_CODCLI, FI2_LOJCLI, FI2_OCORR, FI2_GERADO
endif

dDataBase	:= dDtEntr
aVencto 	:= Condicao(SF2->F2_VALBRUT, SF2->F2_COND)
dDataBase	:= dBkpDtBase
cParcela	:= Space(Len(SE1->E1_PARCELA))
	
if Len(aVencto) > 1
	cParcela := SuperGetMv("MV_1DUP")
endif
if ExistBlock("M4601DUP")
	cParcela := ExecBlock("M4601DUP",.F.,.F.,{cParcela})
endif

for nK := 1 to Len(aVencto)
	
	if SE1->(dbSeek(xFilial("SE1") + SF2->(F2_CLIENTE + F2_LOJA + F2_PREFIXO + F2_DOC) + cParcela))

		if SE1->E1_SALDO > 0

	      if SE1->E1_VENCREA != DataValida(aVencto[nK,1], .T.)	//SE1->E1_VENCTO != aVencto[nK,1] .or. //retirado em 06/01/21 por solicitação Jorge.

				dDtAnter := SE1->E1_VENCREA
				
				SE1->(RecLock("SE1", .F.))
					//SE1->E1_VENCTO		:= aVencto[nK,1] 	//retirado em 06/01/21 por solicitação Jorge.
					SE1->E1_VENCREA		:= DataValida(aVencto[nK,1], .T.)
				SE1->(MsUnlock())
		
				ZZ2->(RecLock("ZZ2", .T.))
				ZZ2->ZZ2_FILIAL		:= xFilial("ZZ2")
				ZZ2->ZZ2_PREFIX		:= SE1->E1_PREFIXO
				ZZ2->ZZ2_NUM		:= SE1->E1_NUM
				ZZ2->ZZ2_PARCEL		:= SE1->E1_PARCELA
				ZZ2->ZZ2_TIPO		:= SE1->E1_TIPO
				ZZ2->ZZ2_CLIENT		:= SE1->E1_CLIENTE
				ZZ2->ZZ2_LOJA		:= SE1->E1_LOJA
				ZZ2->ZZ2_DTMOV		:= Date()
				ZZ2->ZZ2_HRMOV		:= Time()
				ZZ2->ZZ2_USUMOV		:= FunName()
				ZZ2->ZZ2_VENORI		:= SE1->E1_XVCTORI
				ZZ2->ZZ2_VENCTO		:= SE1->E1_VENCTO
				ZZ2->ZZ2_VENREA		:= SE1->E1_VENCREA
				ZZ2->ZZ2_MOTIVO		:= "02"		//"Confirmacao da entrega"Z
				ZZ2->(MsUnlock())

				if !Empty(SE1->E1_IDCNAB) .and. AliasInDic("FI2")

					if FI2->(dbSeek(xFilial("FI2") + "1" + SE1->(E1_NUMBOR + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA) + "06" + "2"))
						FI2->(RecLock('FI2', .F.))
					else
						FI2->(RecLock('FI2', .T.))
						FI2->FI2_FILIAL	:= xFilial("FI2")
						FI2->FI2_CARTEI	:= "1"
						FI2->FI2_NUMBOR	:= SE1->E1_NUMBOR
						FI2->FI2_PREFIX	:= SE1->E1_PREFIXO
						FI2->FI2_TITULO	:= SE1->E1_NUM
						FI2->FI2_PARCEL	:= SE1->E1_PARCELA
						FI2->FI2_TIPO	:= SE1->E1_TIPO   
						FI2->FI2_CODCLI	:= SE1->E1_CLIENTE
						FI2->FI2_LOJCLI	:= SE1->E1_LOJA
						FI2->FI2_OCORR	:= "06"
						FI2->FI2_GERADO	:= "2"
					endif
					FI2->FI2_DTOCOR	:= dDataBase               
					FI2->FI2_DESCOC	:= Posicione("SEB", 1, xFilial("SEB") + SE1->E1_PORTADO + Pad(FI2->FI2_OCORR, Len(SEB->EB_REFBAN)) + "E", "SEB->EB_DESCRI")
					FI2->FI2_VALANT	:= dTOs(dDtAnter)
					FI2->FI2_VALNOV	:= dTOs(SE1->E1_VENCREA)
					FI2->FI2_CAMPO	:= "E1_VENCREA"
					FI2->FI2_TIPCPO	:= "D"
					FI2->(MsUnLock())     
			
				endif
		
				GrvLog("0", "TIT [" + SE1->E1_PREFIXO + "-" + SE1->E1_NUM + "-" + SE1->E1_PARCELA + "]", "Atualizada data de vencimento no título [" + SE1->E1_PREFIXO + "-" + SE1->E1_NUM + "-" + SE1->E1_PARCELA + "] e gerado registro no histórico de alteração de vencimentos. Linha ")

			endif
		
		else
	
			GrvLog("2", "TIT [" + SE1->E1_PREFIXO + "-" + SE1->E1_NUM + "-" + SE1->E1_PARCELA + "]", "Não alterado vencimento do título [" + SE1->E1_PREFIXO + "-" + SE1->E1_NUM + "-" + SE1->E1_PARCELA + "] pois o mesmo encontra-se totalmente baixado. Linha " )
			
		endif
   
   else

		GrvLog("2", "NF [" + SF2->(F2_DOC + "/" + F2_SERIE) + "]", "Não encontrado títulos referente a Série/Nota [" + SF2->(F2_DOC + "/" + F2_SERIE) + "]. ")
		exit
   
	endif
	
	cParcela := MaParcela(cParcela)
		
next
	
RestArea(aArea)
Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		GRVLOG                                                       /@
@type			Static function                                              /@
@date			10/01/2012                                                   /@
@description	Grava o log do processamento de registros                    /@
@author			Adalberto Moreno Batista (Opção Um Consultoria)              /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function GrvLog(cTipoOcor, cChave, cOcorrencia)

ZZ9->(RecLock("ZZ9",.T.))
ZZ9->ZZ9_FILIAL		:= xFilial("ZZ9")
ZZ9->ZZ9_ROTINA		:= FunName()
ZZ9->ZZ9_PROC		:= "GKO-OCO"
ZZ9->ZZ9_TIPO		:= cTipoOcor
ZZ9->ZZ9_CHAVE		:= cChave
ZZ9->ZZ9_INDPRO		:= ""//Lower(cQualArq)
ZZ9->ZZ9_DATA		:= dDtProc
ZZ9->ZZ9_HORA		:= cHrProc
ZZ9->ZZ9_RESUMO		:= cOcorrencia
ZZ9->ZZ9_LOG		:= cOcorrencia
ZZ9->(MsUnlock())

Return()
