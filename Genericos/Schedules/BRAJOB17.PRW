#include "protheus.ch"
#include "rwmake.ch"
#include "ap5mail.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		BRAJOB17                                                      /@
@type				User function                                                 /@
@date				28/03/2017                                                    /@
@description	Seleciona pedidos pendentes de aprovação para cobrar os
					respectivos aprovadores.                                      /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Opção Um Consultoria                                          /@
@use				Especifico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function BRAJOB17()
Local aFiles	:= {"SA2", "SC7", "SCR", "SY1"}
Local cEmp		:= "01"
Local cFil		:= "01"
Local nK

//———————————————————————————————————————————————————————————————————————————————
// Abertura do ambiente                                         
//———————————————————————————————————————————————————————————————————————————————
WfPrepEnv(cEmp, cFil, "U_BRAJOB17",, "COM")

for nK := 1 to Len(aFiles)

	if Select(aFiles[nK]) = 0
		ChkFile(aFiles[nK])
	endif
	
next

//———————————————————————————————————————————————————————————————————————————————
// Verifica os registros
//———————————————————————————————————————————————————————————————————————————————
A17BRAJOB()

//———————————————————————————————————————————————————————————————————————————————
// Encerramento do ambiente                                     
//———————————————————————————————————————————————————————————————————————————————
RpcClearEnv()

ConOut(dTOc(Date()) + " - " + Time() + " BRAJOB17 - Brasitech - Envio de pedidos de compras com pendencia de análise" )
Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		A17BRAJOB                                                     /@
@type				Static function                                               /@
@date				28/03/2017                                                    /@
@description	Seleciona pedidos pendentes de aprovação para cobrar os
					respectivos aprovadores.                                      /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Opção Um Consultoria                                          /@
@use				Especifico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function A17BRAJOB()
Local cQuery, cMsg, cAprov, cAprovEml, cAprovNom, cComprEml
Local cSubject	:= "GA.MA Italy - Relação de pedidos de compra pendentes de análise em " + dTOc(Date())
Local lCompart	:= .F.	//Caso verdadeiro, indica que a tabela deve ser aberta em modo compartilhado, is'to é, outros processos também poderão abrir esta tabela.
Local lLeitura	:= .F.	//Caso verdadeiro, indica que este alias será usado apenas para leitura de dados. Caso contrário, estas operações serão permitidas.

//———————————————————————————————————————————————————————————————————————————————
// Apaga a tabela temporária, se existir
//———————————————————————————————————————————————————————————————————————————————
TcSQLExec("DROP TABLE TMP_BRAJOB17")

//———————————————————————————————————————————————————————————————————————————————
// Montagem da query para a criação de tabela temporária
//———————————————————————————————————————————————————————————————————————————————
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

//———————————————————————————————————————————————————————————————————————————————
// Cria a tabela temporária TMP_BRAJOB17 no banco de dados
//———————————————————————————————————————————————————————————————————————————————
TcSQLExec(cQuery)

//———————————————————————————————————————————————————————————————————————————————
// Lê os registros restantes, para a emissão do relatório
//———————————————————————————————————————————————————————————————————————————————
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

	//———————————————————————————————————————————————————————————————————————————————
	// Cria texto no formato HTML para envio do e-mail
	//———————————————————————————————————————————————————————————————————————————————
	cMsg := '<html>'
	cMsg += '<body><img src="http://emkt.gamaitaly.com.br/gama-assinatura/gama.jpg"><br><br>'
	cMsg += '<font size="3" face="Calibri">Prezado(a), ' + cAprovNom + ',</font><br><br>'		//
	cMsg += '<font size="3" face="Calibri">Segue listagem com pedidos de compras pendentes de análise. Verifique seu e-mail ou utilize a rotina de liberar documentos no Protheus.</font><br><br>'

	cMsg += '<table width="100%" border="1" cellspacing="0" cellpadding="1">'
	
	cMsg += '<tr>'
	cMsg += '<td width="04%" align="left"><font size="3" face="Calibri"><b>Filial</b></font></td>'
	cMsg += '<td width="07%" align="left"><font size="3" face="Calibri"><b>Pedido</b></font></td>'
	cMsg += '<td width="07%" align="left"><font size="3" face="Calibri"><b>Emissão</b></font></td>'
	cMsg += '<td width="24%" align="left"><font size="3" face="Calibri"><b>Fornecedor</b></font></td>'
	cMsg += '<td width="18%" align="left"><font size="3" face="Calibri"><b>Comprador</b></font></td>'
	cMsg += '<td width="10%" align="right"><font size="3" face="Calibri"><b>Total</b></font></td>'
	cMsg += '<td width="30%" align="left"><font size="3" face="Calibri"><b>Observação Geral</b></font></td>'
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
		
	cMsg += '<font size="1" face="Calibri"><i>E-mail automático enviado pelo processo de workflow, Favor não respondê-lo.</i></font><br><br>'
	cMsg += '</body>'
	cMsg += '</html>'
	
	//———————————————————————————————————————————————————————————————————————————————
	// Envia o e-mail com os registros selecionados
	//———————————————————————————————————————————————————————————————————————————————
	U_GISendMail(cAprovEml,, cSubject, cMsg)
	
enddo

//———————————————————————————————————————————————————————————————————————————————
// Apaga a tabela temporária criada
//———————————————————————————————————————————————————————————————————————————————
TcSQLExec("DROP TABLE TMP_BRAJOB17")

Return()
