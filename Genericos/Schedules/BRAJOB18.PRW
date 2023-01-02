#include "protheus.ch"
#include "rwmake.ch"
#include "ap5mail.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		BRAJOB18                                                      /@
@type				User function                                                 /@
@date				07/12/2017                                                    /@
@description	Atualiza os AR´s incluidos com a data de solicitação de coleta
					e preenche com a transportadora vinculada ao cliente.
					Em seguida envia e-mail para as transportadoras               /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Opção Um Consultoria                                          /@
@use				Especifico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function BRAJOB18()
Local aFiles	:= {"SA1", "SA4", "SZG", "SZD"}
Local cEmp		:= "01"
Local cFil		:= "03"
Local nK

//———————————————————————————————————————————————————————————————————————————————
// Abertura do ambiente                                         
//———————————————————————————————————————————————————————————————————————————————
WfPrepEnv(cEmp, cFil, "U_BRAJOB18",, "FAT")

for nK := 1 to Len(aFiles)

	if Select(aFiles[nK]) = 0
		ChkFile(aFiles[nK])
	endif
	
next

//———————————————————————————————————————————————————————————————————————————————
// Verifica os registros
//———————————————————————————————————————————————————————————————————————————————
A18BRAJOB()

//———————————————————————————————————————————————————————————————————————————————
// Encerramento do ambiente                                     
//———————————————————————————————————————————————————————————————————————————————
RpcClearEnv()

ConOut(dTOc(Date()) + " - " + Time() + " BRAJOB18 - Brasitech - Solicitação automática de coleta AR")
Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		A18BRAJOB                                                     /@
@type				Static function                                               /@
@date				07/12/2017                                                    /@
@description	Seleciona pedidos pendentes de aprovação para cobrar os
					respectivos aprovadores.                                      /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Opção Um Consultoria                                          /@
@use				Especifico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function A18BRAJOB()
Local cQuery, cTransp, cNTransp, cMsg
Local cSubject	:= "GA.MA Italy - Relação de notas fiscais para coleta em " + dTOc(Date())
Local cEmCopia	:= GetMV("BR_JOB18", .F., "")		//E-mails para recebimento em copia da listagem de notas a serem coletadas, alem do email do transportador
Local cCorreio	:= GetMV("BR_CODECT", .F., "")	//Código de transportadora registrado para os Correios
Local lCompart	:= .F.	//.T. abre em modo compartilhado.
Local lLeitura	:= .F.	//.T. apenas para leitura de dados. .F. permite gravação.

//———————————————————————————————————————————————————————————————————————————————
// Apaga a tabela temporária, se existir
//———————————————————————————————————————————————————————————————————————————————
TcSQLExec("DROP TABLE TMP_BRAJOB18")

//———————————————————————————————————————————————————————————————————————————————
// Montagem da query para a criação de tabela temporária
//———————————————————————————————————————————————————————————————————————————————

cQuery:='EXEC SP_BRAJOB18R'

TcSQLExec(cQuery)

//———————————————————————————————————————————————————————————————————————————————
// Lê os registros restantes, para a emissão do relatório
//———————————————————————————————————————————————————————————————————————————————
cQuery	:=  " SELECT * FROM TMP_BRAJOB18 "


if Select("TEMP") > 0
	TEMP->(dbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TEMP", lCompart, lLeitura)

SZG->(dbSetOrder(1))		//ZG_FILIAL, ZG_NUMERO, ZG_EMISSAO, ZG_CLIENTE, ZG_LOJACLI

dbSelectArea("TEMP")
do while TEMP->(!eof())

	cTransp		:= ""
	cTransp		:= iif(TEMP->ZG_TPCOLET == "2",;
								cCorreio,;
								U_FindTraUF(TEMP->ZG_CLIENTE, TEMP->ZG_LOJACLI, TEMP->ZG_CMUNCOL, TEMP->ZG_ESTCOLE))

	if !empty(cTransp)
		cNTransp := GetAdvFVal("SA4", "A4_NOME", xFilial("SA4") + cTransp, 1)

		//———————————————————————————————————————————————————————————————————————————————
		// Grava transportadora na tabela temporária
		//———————————————————————————————————————————————————————————————————————————————
		cQuery	:= " UPDATE TMP_BRAJOB18 SET ZG_TRANSP='" + cTransp + "', ZG_NOMETRP='" + cNTransp + "', ZG_DTSOLIC='" + dTOc(Date()) + "' " +;
						"WHERE ZG_FILIAL = '" + TEMP->ZG_FILIAL + "' AND ZG_NUMERO = '" + TEMP->ZG_NUMERO + "'"
		TcSQLExec(cQuery)
	
	endif

	TEMP->(dbSkip())
	
enddo

cQuery	:= " SELECT TMP_BRAJOB18.*, SA4.A4_XLOGREV FROM TMP_BRAJOB18, " + RetSqlName("SA4") + " SA4 " +;
				"WHERE TMP_BRAJOB18.ZG_TRANSP = SA4.A4_COD " +;
				"AND SA4.D_E_L_E_T_ = ' ' " +;
				"ORDER BY ZG_TRANSP, ZG_FILIAL, ZG_NOMECLI, ZG_CLIENTE"

if Select("TEMP") > 0
	TEMP->(dbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TEMP", lCompart, lLeitura)
tcSetField("TEMP", "DTEMISSAODEV", "D")

SZG->(dbSetOrder(1))		//ZG_FILIAL, ZG_NUMERO, ZG_EMISSAO, ZG_CLIENTE, ZG_LOJACLI

dbSelectArea("TEMP")
do while TEMP->(!eof())

	cTransp		:= TEMP->ZG_TRANSP
	cNTransp		:= AllTrim(TEMP->ZG_NOMETRP)
	cDestinat	:= AllTrim(TEMP->A4_XLOGREV)
	cChaveNfDev := Alltrim(TEMP->CHAVENFDEV)
	cDtEmissaoDev:= DToC(TEMP->DTEMISSAODEV)

	//———————————————————————————————————————————————————————————————————————————————
	// Cria texto no formato HTML para envio do e-mail
	//———————————————————————————————————————————————————————————————————————————————
	cMsg := '<html>'
	//cMsg += '<body><img src="https://gamaitaly.vteximg.com.br/arquivos/logo.png"><br><br>'
	cMsg += '<body><img src="https://gamaitaly.vteximg.com.br/arquivos/logo.png"><br><br>'
	cMsg += '<font size="3" face="Calibri">À Transportadora, ' + cNTransp + ',</font><br><br>'
	cMsg += '<font size="3" face="Calibri">Segue relação de notas fiscais para coleta.</font><br>'
	cMsg += '<font size="3" face="Calibri">Em caso de dúvidas, envie e-mail para logistica.reversa@gamaitaly.com.br</font><br><br>'
	cMsg += '<table width="100%" border="1" cellspacing="0" cellpadding="1">'
	cMsg += '<tr>'
	cMsg += '<td width="07.6%" align="left"><font size="2" face="Calibri"><b>CNPJ Origem GAMA</b></font></td>'
	cMsg += '<td width="07.6%" align="left"><font size="2" face="Calibri"><b>Dt. Emissão Dev.</b></font></td>'
	cMsg += '<td width="05.5%" align="left"><font size="2" face="Calibri"><b>NF/Série Devolução</b></font></td>'
	cMsg += '<td width="05.5%" align="left"><font size="2" face="Calibri"><b>Chave Devolução</b></font></td>'
	cMsg += '<td width="05.5%" align="left"><font size="2" face="Calibri"><b>NF Manaus Devolução</b></font></td>'
	cMsg += '<td width="19.0%" align="left"><font size="2" face="Calibri"><b>Nome Cliente</b></font></td>'
	cMsg += '<td width="05.2%" align="right"><font size="2" face="Calibri"><b>Valor Total</b></font></td>'
	cMsg += '<td width="04.0%" align="right"><font size="2" face="Calibri"><b>Volume</b></font></td>'
	cMsg += '<td width="06.0%" align="right"><font size="2" face="Calibri"><b>Peso Bruto</b></font></td>'
	cMsg += '<td width="17.5.0%" align="left"><font size="2" face="Calibri"><b>Endereço Coleta</b></font></td>'
	cMsg += '<td width="07.0%" align="left"><font size="2" face="Calibri"><b>Município</b></font></td>'
	cMsg += '<td width="02.5%" align="left"><font size="2" face="Calibri"><b>UF</b></font></td>'
	cMsg += '<td width="05.2%" align="left"><font size="2" face="Calibri"><b>CEP</b></font></td>'
	cMsg += '<td width="07.2%" align="left"><font size="2" face="Calibri"><b>Telefone</b></font></td>'
	cMsg += '<td width="07.8.5%" align="left"><font size="2" face="Calibri"><b>CNPJ Emitente</b></font></td>'
	cMsg += '</tr>'

	do while TEMP->(!eof() .and. ZG_TRANSP == cTransp)
		SM0->(dbSeek("01" + TEMP->ZG_FILIAL))
	
		cMsg += '<tr>'
		cMsg += '<td width="07.6%" align="left"><font size="2" face="Calibri">' + Transform(SM0->M0_CGC, "@R 99.999.999/9999-99") + '</font></td>'
		cMsg += '<td width="07.6%" align="left"><font size="2" face="Calibri">' + cDtEmissaoDev + '</font></td>'
		cMsg += '<td width="05.5%" align="left"><font size="2" face="Calibri">' + AllTrim(TEMP->ZG_NFDEVOL) + " / " + AllTrim(TEMP->ZG_SERIENF) + '</font></td>'
		cMsg += '<td width="05.5%" align="left"><font size="2" face="Calibri">' + AllTrim(TEMP->CHAVENFDEV) + '</font></td>'
		cMsg += '<td width="05.5%" align="left"><font size="2" face="Calibri">' + AllTrim(TEMP->ZG_NFFMDEV) + '</font></td>'
		cMsg += '<td width="19.0%" align="left"><font size="2" face="Calibri">' + AllTrim(TEMP->ZG_NOMECLI) + '</font></td>'
		cMsg += '<td width="05.2%" align="right"><font size="2" face="Calibri">' + Transform(TEMP->ZG_VALOR, "@E 999,999,999.99") + '</font></td>'
		cMsg += '<td width="04.0%" align="right"><font size="2" face="Calibri">' + Transform(TEMP->ZG_QUANTID, "@E 999,999") + '</font></td>'
		cMsg += '<td width="06.0%" align="right"><font size="2" face="Calibri">' + Transform(TEMP->PESOBRU, "@E 99,999.999") + '</font></td>'
		cMsg += '<td width="17.5%" align="left"><font size="2" face="Calibri">' + AllTrim(TEMP->ZG_ENDCOLE) + '</font></td>'
		cMsg += '<td width="07.0%" align="left"><font size="2" face="Calibri">' + AllTrim(TEMP->ZG_MUNCOLE) + '</font></td>'
		cMsg += '<td width="02.5%" align="left"><font size="2" face="Calibri">' + TEMP->ZG_ESTCOLE + '</font></td>'
		cMsg += '<td width="05.2%" align="left"><font size="2" face="Calibri">' + Transform(TEMP->ZG_CEPCOLE, "@R 99999-999") + '</font></td>'
		cMsg += '<td width="07.2%" align="left"><font size="2" face="Calibri">(' + AllTrim(TEMP->ZG_DDDCLI) + ") " + AllTrim(TEMP->ZG_TELCLI) + '</font></td>'
		cMsg += '<td width="07.8%" align="left"><font size="2" face="Calibri">' + Transform(TEMP->ZG_CGC, "@R 99.999.999/9999-99") + '</font></td>'
		cMsg += '</tr>'

		TEMP->(dbSkip())
			
	enddo
		
	cMsg += '</table><br><br><br>'
		
	cMsg += '<font size="1" face="Calibri"><i>E-mail automático enviado pelo processo de workflow, Favor não respondê-lo.</i></font><br><br>'
	cMsg += '</body>'
	cMsg += '</html>'
	
	//———————————————————————————————————————————————————————————————————————————————
	// Envia o e-mail com os registros selecionados
	//———————————————————————————————————————————————————————————————————————————————
	
	U_GISendMail(cDestinat + iif(!Empty(cEmCopia), "; " + cEmCopia, ""),, cSubject, cMsg)
	
	//U_GISendMail("ricky.moraes@gamaitaly.com.br;rodrigo.ramos@gamaitaly.com.br" ,, cSubject, cMsg)
	
enddo

//———————————————————————————————————————————————————————————————————————————————
// Atualiza tabela AR
//———————————————————————————————————————————————————————————————————————————————


cQuery	:= "UPDATE " + RetSQLName("SZG") + " SET ZG_TRANSP=TMP_BRAJOB18.ZG_TRANSP, " +;
																 "ZG_NOMETRP=TMP_BRAJOB18.ZG_NOMETRP, " +;
																 "ZG_DTSOLIC='" + dTOs(Date()) + "', " +;
																 "ZG_CHVNFE= TMP_BRAJOB18.CHAVENFDEV, " +;
																 "ZG_STATUS='AR - Solicitada' " +;																 
				"FROM TMP_BRAJOB18 " +;
				"WHERE R_E_C_N_O_=TMP_BRAJOB18.RECSZG"
TcSQLExec(cQuery)

//"ZG_STATUS=TMP_BRAJOB18.DTEMISSAODEV " +;
//———————————————————————————————————————————————————————————————————————————————
// Apaga a tabela temporária criada
//———————————————————————————————————————————————————————————————————————————————
if Select("TEMP") > 0
	TEMP->(dbCloseArea())
endif
TcSQLExec("DROP TABLE TMP_BRAJOB18")

Return()
