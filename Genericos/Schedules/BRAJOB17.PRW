#include "protheus.ch"
#include "rwmake.ch"
#include "ap5mail.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		BRAJOB17                                                      /@
@type				User function                                                 /@
@date				28/03/2017                                                    /@
@description	Seleciona pedidos pendentes de aprova鈬o para cobrar os
					respectivos aprovadores.                                      /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Op鈬o Um Consultoria                                          /@
@use				Especifico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function BRAJOB17()
Local aFiles	:= {"SA2", "SC7", "SCR", "SY1"}
Local cEmp		:= "01"
Local cFil		:= "01"
Local nK

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Abertura do ambiente                                         
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
WfPrepEnv(cEmp, cFil, "U_BRAJOB17",, "COM")

for nK := 1 to Len(aFiles)

	if Select(aFiles[nK]) = 0
		ChkFile(aFiles[nK])
	endif
	
next

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Verifica os registros
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
A17BRAJOB()

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Encerramento do ambiente                                     
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
RpcClearEnv()

ConOut(dTOc(Date()) + " - " + Time() + " BRAJOB17 - Brasitech - Envio de pedidos de compras com pendencia de an疝ise" )
Return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		A17BRAJOB                                                     /@
@type				Static function                                               /@
@date				28/03/2017                                                    /@
@description	Seleciona pedidos pendentes de aprova鈬o para cobrar os
					respectivos aprovadores.                                      /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Op鈬o Um Consultoria                                          /@
@use				Especifico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function A17BRAJOB()
Local cQuery, cMsg, cAprov, cAprovEml, cAprovNom, cComprEml
Local cSubject	:= "GA.MA Italy - Rela鈬o de pedidos de compra pendentes de an疝ise em " + dTOc(Date())
Local lCompart	:= .F.	//Caso verdadeiro, indica que a tabela deve ser aberta em modo compartilhado, is'to ?, outros processos tamb駑 poder縊 abrir esta tabela.
Local lLeitura	:= .F.	//Caso verdadeiro, indica que este alias ser? usado apenas para leitura de dados. Caso contr疵io, estas opera鋏es ser縊 permitidas.

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Apaga a tabela tempor疵ia, se existir
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
TcSQLExec("DROP TABLE TMP_BRAJOB17")

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Montagem da query para a cria鈬o de tabela tempor疵ia
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
cQuery	:= "SELECT CR_FILIAL, CR_USER, LEFT(CR_NUM,6) CR_NUM, A2_NOME, C7_USER, C7_X_OBSGE, C7_EMISSAO, SUM(C7_TOTAL) C7_TOTAL INTO TMP_BRAJOB17 " +;
				"FROM " + RetSqlName("SCR") + " SCR, " + RetSqlName("SC7") + " SC7, " + RetSqlName("SA2") + " SA2 " +;
				"WHERE SCR.CR_STATUS = '02' " +;
						"AND SCR.CR_WF = '1' " +;
						"AND SCR.CR_TIPO = 'PC' " +;
						"AND SCR.D_E_L_E_T_ = ' ' " +;
						"AND SC7.C7_FILIAL = SCR.CR_FILIAL " +;
						"AND SC7.C7_NUM = LEFT(SCR.CR_NUM,6) " +;
						"AND SC7.D_E_L_E_T_ = ' ' " +;
						"AND SA2.A2_FILIAL = '" + xFilial("SA2") + "' " +;
						"AND SA2.A2_COD = SC7.C7_FORNECE " +;
						"AND SA2.A2_LOJA = SC7.C7_LOJA " +;
						"AND SA2.D_E_L_E_T_ = ' ' " +;
				"GROUP BY CR_FILIAL, CR_USER, CR_NUM, A2_NOME, C7_USER, C7_X_OBSGE, C7_EMISSAO " +;
				"ORDER BY CR_USER, CR_FILIAL, CR_NUM"

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Cria a tabela tempor疵ia TMP_BRAJOB17 no banco de dados
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
TcSQLExec(cQuery)

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// L? os registros restantes, para a emiss縊 do relat?rio
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
cQuery	:= "SELECT * FROM TMP_BRAJOB17 ORDER BY CR_USER, CR_FILIAL, CR_NUM "

if Select("TEMP") > 0
	TEMP->(dbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TEMP", lCompart, lLeitura)
TcSetField("TEMP", "C7_EMISSAO", "D")

SY1->(dbSetOrder(3))

dbSelectArea("TEMP")
do while TEMP->(!eof())

	cAprov 		:= TEMP->CR_USER
	cAprovEml	:= UsrRetMail(cAprov)
	cAprovNom	:= UsrFullName(cAprov)

	//TEMPORARIO
	if empty(cAprovEml)   
		if SY1->(dbSeek(xFilial("SY1") + cAprov))
			cAprovEml	:= AllTrim(SY1->Y1_EMAIL)
			cAprovNom	:= AllTrim(SY1->Y1_NOME)
		endif
	endif
	
/*
	if empty(cAprovEml)
		PswOrder(1)
		if PswSeek(TEMP->CR_USER)
			cAprovEml	:= PswRet(1)[1][14]
			cAprovNom	:= PswRet(1)[1][2]
		endif
	endif*/

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Cria texto no formato HTML para envio do e-mail
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	cMsg := '<html>'
	cMsg += '<body><img src="http://emkt.gamaitaly.com.br/gama-assinatura/gama.jpg"><br><br>'
	cMsg += '<font size="3" face="Calibri">Prezado(a), ' + cAprovNom + ',</font><br><br>'		//
	cMsg += '<font size="3" face="Calibri">Segue listagem com pedidos de compras pendentes de an疝ise. Verifique seu e-mail ou utilize a rotina de liberar documentos no Protheus.</font><br><br>'

	cMsg += '<table width="100%" border="1" cellspacing="0" cellpadding="1">'
	
	cMsg += '<tr>'
	cMsg += '<td width="04%" align="left"><font size="3" face="Calibri"><b>Filial</b></font></td>'
	cMsg += '<td width="07%" align="left"><font size="3" face="Calibri"><b>Pedido</b></font></td>'
	cMsg += '<td width="07%" align="left"><font size="3" face="Calibri"><b>Emiss縊</b></font></td>'
	cMsg += '<td width="24%" align="left"><font size="3" face="Calibri"><b>Fornecedor</b></font></td>'
	cMsg += '<td width="18%" align="left"><font size="3" face="Calibri"><b>Comprador</b></font></td>'
	cMsg += '<td width="10%" align="right"><font size="3" face="Calibri"><b>Total</b></font></td>'
	cMsg += '<td width="30%" align="left"><font size="3" face="Calibri"><b>Observa鈬o Geral</b></font></td>'
	cMsg += '</tr>'
		
	do while TEMP->(!eof() .and. CR_USER == cAprov)
	
	//temporario
	cComprEml	:= UsrRetMail(TEMP->C7_USER)
	if empty(cComprEml)
		if SY1->(dbSeek(xFilial("SY1") + TEMP->C7_USER))
			cComprEml	:= AllTrim(SY1->Y1_EMAIL)
		endif
	endif
		
		cMsg += '<tr>'
		cMsg += '<td width="04%" align="left"><font size="3" face="Calibri">' + TEMP->CR_FILIAL + '</font></td>'
		cMsg += '<td width="07%" align="left"><font size="3" face="Calibri">' + TEMP->CR_NUM + '</font></td>'
		cMsg += '<td width="07%" align="left"><font size="3" face="Calibri">' + dTOc(TEMP->C7_EMISSAO) + '</font></td>'
		cMsg += '<td width="24%" align="left"><font size="3" face="Calibri">' + AllTrim(TEMP->A2_NOME) + '</font></td>'
		cMsg += '<td width="18%" align="left"><font size="3" face="Calibri">' + cComprEml + '</font></td>'
		cMsg += '<td width="10%" align="right"><font size="3" face="Calibri">' + Transform(TEMP->C7_TOTAL, "@E 999,999,999.99") + '</font></td>'
		cMsg += '<td width="30%" align="left"><font size="3" face="Calibri">' + AllTrim(TEMP->C7_X_OBSGE) + '</font></td>'
		cMsg += '</tr>'
	ccompreml:=""
		TEMP->(dbSkip())
			
	enddo
		
	cMsg += '</table><br><br><br>'
		
	cMsg += '<font size="1" face="Calibri"><i>E-mail autom疸ico enviado pelo processo de workflow, Favor n縊 respond?-lo.</i></font><br><br>'
	cMsg += '</body>'
	cMsg += '</html>'
	
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Envia o e-mail com os registros selecionados
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	U_GISendMail(cAprovEml,, cSubject, cMsg)
	
enddo

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Apaga a tabela tempor疵ia criada
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
TcSQLExec("DROP TABLE TMP_BRAJOB17")

Return()
