#include "protheus.ch"
#include "rwmake.ch"
#include "Ap5Mail.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		BRAJOB22                                                     /@
@type			User function                                                /@
@date			10/02/2020                                                   /@
@description	Verifica intervalos de notas no processo de importação 
				INFRACOMMERCE e avisa os interessados para verificare se 
				trata-se de notas canceladas/inutilizadas ou não importadas.
				Verifica também notas não integradas                         /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Tecnologia da Informação                            /@
@use			Brasitech, filial 11-Embú das Artes                          /@
———————————————————————————————————————————————————————————————————————————————
01/02/21 - Ajustes (acordado com Cleber)
	- Verificação de notas faltantes somente série 3 e desconsiderando notas 
	  com numeração inferior à 000014513, pois há notas canceladas que não 
	  puderam ter o XML de cancelamento.
	- Criação de grupo de notas emitidas com série diferente de 3 e emissor
	  07.293.118/0008-70
	- Inclusão de valores na estatística de notas
/*/
User Function BRAJOB22()
Local aFiles	:= {"ZZ7"}
Local cEmp		:= "01"
Local cFil		:= "11"
Local nK

//———————————————————————————————————————————————————————————————————————————————
// Abertura do ambiente                                         
//———————————————————————————————————————————————————————————————————————————————
WfPrepEnv(cEmp, cFil, "U_BRAJOB22",, "FIS")

for nK := 1 to Len(aFiles)

	if Select(aFiles[nK]) = 0
		ChkFile(aFiles[nK])
	endif
	
next

//———————————————————————————————————————————————————————————————————————————————
// Executa analise de registros, de segunda a sexta feira
//———————————————————————————————————————————————————————————————————————————————
if Dow(Date()) >= 2 .and. Dow(Date()) <= 6
	A22BRAJOB()
endif

//———————————————————————————————————————————————————————————————————————————————
// Encerramento do ambiente                                     
//———————————————————————————————————————————————————————————————————————————————
RpcClearEnv()

ConOut(dTOc(Date()) + " - " + Time() + " BRAJOB22 - Brasitech - Pesquisa de intervalos de notas ou notas não integradas INFRACOMMERCE" )
Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		A22BRAJOB                                                    /@
@type			Static function                                              /@
@date			10/02/2020                                                   /@
@description	Seleciona lotes a vencer em um ano e envia e-mail com relação/@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function A22BRAJOB()
Local cQuery, nNF, nX, cHtml
Local cDestinat		:= GetMV("BR_DEST22", .F., "equipe.ti@gamaitaly.com.br")
Local cLinkLogo		:= AllTrim(GetMV("BR_LNKLOGO", .F., "https://sweb.gamaitaly.com.br/images/LogoGamaPeq.jpg"))
Local cSubject		:= "Brasitech - Relação de notas não recebidas e/ou não integradas INFRACOMMERCE - " + dTOc(Date())
Local aNaoRegistr	:= {}
Local aNaoIntegr	:= {}
Local aSldNegativo	:= {}
Local aOutraSerie	:= {}
Local aEstatistica  := {0, 0, 0, 0}    //qtde e valor notas saidas, qtde e valor notas devolucao do mês corrente
Local lCompart		:= .F.	//Caso verdadeiro, indica que a tabela deve ser aberta em modo compartilhado, isto é, outros processos também poderão abrir esta tabela.
Local lLeitura		:= .F.	//Caso verdadeiro, indica que este alias será usado apenas para leitura de dados. Caso contrário, estas operações serão permitidas.
//Local dInicial		:= cTOd("01/05/20")	//cTOd("01/" + Substr(dTOc(Date()-1), 4, 5))
Local dFinal		:= Date()

//—————————————————————————————————————————————————————————————————————————————————
// Pesquisa existência de intervalo de numeração de notas série 3 em pré-nota (ZZ7)
//—————————————————————————————————————————————————————————————————————————————————
/*cQuery	:= "SELECT MIN(ZZ7_NNF) PRIMEIRA, MAX(ZZ7_NNF) ULTIMA " +;
			"FROM " + RetSqlName("ZZ7") + " ZZ7 " +;
			"WHERE ZZ7_FILIAL = '11' " +;
				"AND ZZ7_DTEMIS BETWEEN '" + dTOs(dInicial) + "' AND '" + dTOs(dFinal) + "' " +;
				"AND ZZ7.D_E_L_E_T_= ' ' "*/
cQuery	:= "SELECT MIN(ZZ7_NNF) PRIMEIRA, MAX(ZZ7_NNF) ULTIMA " +;
			"FROM " + RetSqlName("ZZ7") + " ZZ7 " +;
			"WHERE ZZ7_FILIAL = '11' " +;
				"AND ZZ7_SERIE = '3  ' " +;
				"AND ZZ7_NNF > '000014512' " +;
				"AND ZZ7.D_E_L_E_T_= ' ' "

if Select("TEMP") > 0
	TEMP->(dbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TEMP", lCompart, lLeitura)

if TEMP->(!eof())

	nNF		:= Val(TEMP->PRIMEIRA) + 1
	ZZ7->(dbSetOrder(1))		//ZZ7_FILIAL, ZZ7_NNF, ZZ7_SERIE

	do while nNF <= Val(TEMP->ULTIMA)

		if !ZZ7->(dbSeek(xFilial("ZZ7") + StrZero(nNF,9)))
			aAdd(aNaoRegistr, StrZero(nNF,9))
        elseif Month(Date()-4) == Month(ZZ7->ZZ7_DTEMIS) .and. Year(Date()-4) == Year(ZZ7->ZZ7_DTEMIS)
            aEstatistica[1] += iif(ZZ7->ZZ7_TPNF == "1", 1, 0)  //Qtde NF saida
			aEstatistica[2] += iif(ZZ7->ZZ7_TPNF == "1", ZZ7->ZZ7_VNF, 0)  //Valor NF saida
            aEstatistica[3] += iif(ZZ7->ZZ7_TPNF == "0", 1, 0)  //Qtde NF entrada
			aEstatistica[4] += iif(ZZ7->ZZ7_TPNF == "0", ZZ7->ZZ7_VNF, 0)  //Valor NF entrada
		endif

		nNF++

	enddo

endif


//———————————————————————————————————————————————————————————————————————————————
// Pesquisa notas não integradas em pré-nota (ZZ7)
//———————————————————————————————————————————————————————————————————————————————
cQuery	:= "SELECT ZZ7_NNF, ZZ7_SERIE, ZZ7_NATOP, ZZ7_DTEMIS, ZZ7_XNOME " +;
			"FROM " + RetSqlName("ZZ7") + " ZZ7 " +;
			"WHERE ZZ7_FILIAL = '11' " +;
				"AND ZZ7_STATUS IN ('0','2') " +;
				"AND ZZ7.D_E_L_E_T_= ' ' " +;
			"ORDER BY ZZ7_NNF"

if Select("TEMP") > 0
	TEMP->(dbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TEMP", lCompart, lLeitura)
tcSetField("TEMP", "ZZ7_DTEMIS", "D")

do while TEMP->(!eof())
	aAdd(aNaoIntegr, {TEMP->ZZ7_NNF, TEMP->ZZ7_SERIE, TEMP->ZZ7_DTEMIS, TEMP->ZZ7_NATOP, TEMP->ZZ7_XNOME})
	TEMP->(dbSkip())
enddo


//———————————————————————————————————————————————————————————————————————————————
// Produtos com saldo atual negativo (SB2)
//———————————————————————————————————————————————————————————————————————————————
cQuery	:= "SELECT B2_COD, B1_DESC, B2_LOCAL, B2_QATU " +;
			"FROM " + RetSqlName("SB2") + " SB2, " + RetSqlName("SB1") + " SB1 " +;
			"WHERE SB2.B2_FILIAL = '11' " +;
				"AND SB2.B2_QATU < 0 " +;
				"AND SB2.D_E_L_E_T_= ' ' " +;
				"AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' " +;
				"AND SB1.B1_COD = SB2.B2_COD " +;
				"AND SB1.D_E_L_E_T_= ' ' " +;
			"ORDER BY B2_COD"

if Select("TEMP") > 0
	TEMP->(dbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TEMP", lCompart, lLeitura)

do while TEMP->(!eof())
	aAdd(aSldNegativo, {TEMP->B2_COD, TEMP->B1_DESC, TEMP->B2_LOCAL, TEMP->B2_QATU})
	TEMP->(dbSkip())
enddo

//—————————————————————————————————————————————————————————————————————————————————
// Pesquisa existência de notas com série diferente de 3
//—————————————————————————————————————————————————————————————————————————————————
cQuery	:= "SELECT ZZ7_NNF, ZZ7_SERIE, ZZ7_NATOP, ZZ7_DTEMIS, ZZ7_XNOME " +;
			"FROM " + RetSqlName("ZZ7") + " ZZ7 " +;
			"WHERE ZZ7_FILIAL = '11' " +;
				"AND ZZ7_SERIE != '3  ' " +;
				"AND ZZ7_IDEMIT = '07293118000870' " +;
				"AND ZZ7.D_E_L_E_T_= ' ' " +;
			"ORDER BY ZZ7_DTEMIS, ZZ7_SERIE, ZZ7_NNF"
			
if Select("TEMP") > 0
	TEMP->(dbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TEMP", lCompart, lLeitura)
tcSetField("TEMP", "ZZ7_DTEMIS", "D")

do while TEMP->(!eof())
	aAdd(aOutraSerie, {TEMP->ZZ7_DTEMIS, TEMP->ZZ7_SERIE, TEMP->ZZ7_NNF, TEMP->ZZ7_NATOP, TEMP->ZZ7_XNOME})
	TEMP->(dbSkip())
enddo

if Select("TEMP") > 0
	TEMP->(dbCloseArea())
endif

//———————————————————————————————————————————————————————————————————————————————
// Monta formulário com as observações
//———————————————————————————————————————————————————————————————————————————————
if Len(aNaoRegistr) > 0 .or. Len(aNaoIntegr) > 0 .or. Len(aSldNegativo) > 0 .or. Len(aOutraSerie) > 0 .or. aEstatistica[1] + aEstatistica[2] > 0

	//———————————————————————————————————————————————————————————————————————————————
	// Cria texto no formato HTML para envio do e-mail
	//———————————————————————————————————————————————————————————————————————————————
	cHtml := '<html>'
	cHtml += '<body><img src="' + cLinkLogo + '"><br><br>'

	//———————————————————————————————————————————————————————————————————————————————
	// Listagem de notas não recebidas
	//———————————————————————————————————————————————————————————————————————————————
	if Len(aNaoRegistr)

		//cHtml += '<font size="4" face="Calibri">Relação de notas não recebidas de 01/05/20 à ' + dTOc(dFinal) + '. Verificar XML com a INFRACOMMERCE.</font><br><br>'
		cHtml += '<font size="4" face="Calibri">Relação de notas não recebidas até ' + dTOc(dFinal) + '. Verificar XML com a INFRACOMMERCE.</font><br><br>'
			
		cHtml += '<table width="40%" border="1" cellspacing="0" cellpadding="1">'
		
		cHtml += '<tr>'
		cHtml += '<td width="40%" align="left"><font size="3" face="Calibri"><b>Notas Fiscais não recebidas</b></font></td>'
		cHtml += '</tr>'
	
		for nX := 1 to Len(aNaoRegistr)
			cHtml += '<tr>'
			cHtml += '<td width="40%" align="left"><font size="3" face="Calibri">' + aNaoRegistr[nX] + '</font></td>'
			cHtml += '</tr>'
		next

		cHtml += '</table><br><br>'
					
	endif
	
	//———————————————————————————————————————————————————————————————————————————————
	// Listagem de notas não integradas
	//———————————————————————————————————————————————————————————————————————————————
	if Len(aNaoIntegr)

		cHtml += '<font size="4" face="Calibri">Relação de notas não integradas até ' + dTOc(Date()) + '. Preencher as informações faltantes e integrá-las manualmente.</font><br><br>'
		cHtml += '<table width="100%" border="1" cellspacing="0" cellpadding="1">'
		cHtml += '<tr>'

		cHtml += '<td width="11%" align="left"><font size="3" face="Calibri"><b>Nota</b></font></td>'
		cHtml += '<td width="7%" align="left"><font size="3" face="Calibri"><b>Série</b></font></td>'
		cHtml += '<td width="10%" align="left"><font size="3" face="Calibri"><b>Emissão</b></font></td>'
		cHtml += '<td width="24%" align="left"><font size="3" face="Calibri"><b>Nat. Operação</b></font></td>'
		cHtml += '<td width="48%" align="left"><font size="3" face="Calibri"><b>Nome</b></font></td>'
		cHtml += '</tr>'

		for nX := 1 to Len(aNaoIntegr)
	
			cHtml += '<tr>'
			cHtml += '<td width="11%" align="left"><font size="3" face="Calibri">' + aNaoIntegr[nX,1] + '</font></td>'
			cHtml += '<td width="7%" align="left"><font size="3" face="Calibri">' + aNaoIntegr[nX,2] + '</font></td>'
			cHtml += '<td width="10%" align="left"><font size="3" face="Calibri">' + dTOc(aNaoIntegr[nX,3]) + '</font></td>'
			cHtml += '<td width="24%" align="left"><font size="3" face="Calibri">' + aNaoIntegr[nX,4] + '</font></td>'
			cHtml += '<td width="48%" align="left"><font size="3" face="Calibri">' + aNaoIntegr[nX,5] + '</font></td>'
			cHtml += '</tr>'
	
		next
				
		cHtml += '</table><br><br>'
	
	endif


	//———————————————————————————————————————————————————————————————————————————————
	// Listagem de notas com série diferente de 3
	//———————————————————————————————————————————————————————————————————————————————
	if Len(aOutraSerie)

		cHtml += '<font size="4" face="Calibri">Relação de notas emitidas com outras séries.</font><br><br>'
		cHtml += '<table width="100%" border="1" cellspacing="0" cellpadding="1">'
		cHtml += '<tr>'

		cHtml += '<td width="10%" align="left"><font size="3" face="Calibri"><b>Emissão</b></font></td>'
		cHtml += '<td width="7%" align="left"><font size="3" face="Calibri"><b>Série</b></font></td>'
		cHtml += '<td width="11%" align="left"><font size="3" face="Calibri"><b>Nota</b></font></td>'
		cHtml += '<td width="24%" align="left"><font size="3" face="Calibri"><b>Nat. Operação</b></font></td>'
		cHtml += '<td width="48%" align="left"><font size="3" face="Calibri"><b>Nome</b></font></td>'
		cHtml += '</tr>'

		for nX := 1 to Len(aOutraSerie)
	
			cHtml += '<tr>'
			cHtml += '<td width="10%" align="left"><font size="3" face="Calibri">' + dTOc(aOutraSerie[nX,1]) + '</font></td>'
			cHtml += '<td width="7%" align="left"><font size="3" face="Calibri">' + aOutraSerie[nX,2] + '</font></td>'
			cHtml += '<td width="11%" align="left"><font size="3" face="Calibri">' + aOutraSerie[nX,3] + '</font></td>'
			cHtml += '<td width="24%" align="left"><font size="3" face="Calibri">' + aOutraSerie[nX,4] + '</font></td>'
			cHtml += '<td width="48%" align="left"><font size="3" face="Calibri">' + aOutraSerie[nX,5] + '</font></td>'
			cHtml += '</tr>'
	
		next
				
		cHtml += '</table><br><br>'
	
	endif


	//———————————————————————————————————————————————————————————————————————————————
	// Listagem de produtos com saldo atual negativo
	//———————————————————————————————————————————————————————————————————————————————
	if Len(aSldNegativo)

		cHtml += '<font size="4" face="Calibri">Relação de produtos com saldo atual negativo.</font><br><br>'
		cHtml += '<table width="100%" border="1" cellspacing="0" cellpadding="1">'
		cHtml += '<tr>'

		cHtml += '<td width="20%" align="left"><font size="3" face="Calibri"><b>Produto</b></font></td>'
		cHtml += '<td width="60%" align="left"><font size="3" face="Calibri"><b>Descrição</b></font></td>'
		cHtml += '<td width="10%" align="left"><font size="3" face="Calibri"><b>Armazém</b></font></td>'
		cHtml += '<td width="10%" align="right"><font size="3" face="Calibri"><b>Quantidade</b></font></td>'
		cHtml += '</tr>'

		for nX := 1 to Len(aSldNegativo)
	
			cHtml += '<tr>'
			cHtml += '<td width="20%" align="left"><font size="3" face="Calibri">' + aSldNegativo[nX,1] + '</font></td>'
			cHtml += '<td width="60%" align="left"><font size="3" face="Calibri">' + aSldNegativo[nX,2] + '</font></td>'
			cHtml += '<td width="10%" align="left"><font size="3" face="Calibri">' + aSldNegativo[nX,3] + '</font></td>'
			cHtml += '<td width="10%" align="right"><font size="3" face="Calibri">' + Transform(aSldNegativo[nX,4], "@E 999,999,999") + '</font></td>'
			cHtml += '</tr>'
	
		next
				
		cHtml += '</table><br><br>'
	
	endif

	//———————————————————————————————————————————————————————————————————————————————
	// Estatisticas - notas de entrada e saida do mês corrente
	//———————————————————————————————————————————————————————————————————————————————
	if aEstatistica[1] + aEstatistica[2] > 0

		cHtml += '<font size="4" face="Calibri">Estatística de notas emitidas em ' + AllTrim(StrZero(Month(Date()-4),2)) + '/' + AllTrim(StrZero(Year(Date()-4),4)) + '</font><br><br>'
		cHtml += '<table width="36%" border="1" cellspacing="0" cellpadding="1">'
		cHtml += '<tr>'

		cHtml += '<td width="10%" align="right"><font size="3" face="Calibri"><b>Qtd NFs Saídas</b></font></td>'
		cHtml += '<td width="18%" align="right"><font size="3" face="Calibri"><b>Vlr NFs Saídas</b></font></td>'
		cHtml += '<td width="10%" align="right"><font size="3" face="Calibri"><b>Qtd NFs Entradas</b></font></td>'
		cHtml += '<td width="18%" align="right"><font size="3" face="Calibri"><b>Vlr NFs Entradas</b></font></td>'
		cHtml += '</tr>'

		cHtml += '<tr>'
		cHtml += '<td width="10%" align="right"><font size="3" face="Calibri">' + Transform(aEstatistica[1], "@E 999,999") + '</font></td>'
		cHtml += '<td width="18%" align="right"><font size="3" face="Calibri">' + Transform(aEstatistica[2], "@E 999,999,999.99") + '</font></td>'
		cHtml += '<td width="10%" align="right"><font size="3" face="Calibri">' + Transform(aEstatistica[3], "@E 999,999") + '</font></td>'
		cHtml += '<td width="18%" align="right"><font size="3" face="Calibri">' + Transform(aEstatistica[4], "@E 999,999,999.99") + '</font></td>'
		cHtml += '</tr>'
				
		cHtml += '</table><br><br>'

	endif

	cHtml += '<font size="1" face="Calibri"><i>E-mail automático enviado pelo processo de workflow, Favor não respondê-lo.</i></font><br><br>'
	cHtml += '</body>'
	cHtml += '</html>'

	//———————————————————————————————————————————————————————————————————————————————
	// Envia o e-mail com os registros selecionados
	//———————————————————————————————————————————————————————————————————————————————
	U_GISendMail(cDestinat,, cSubject, cHtml)

endif

Return()
