#include "RWMAKE.CH"
#include "PROTHEUS.CH"
#include "TOTVS.CH"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		BCOMR01                                                      /@
@type			Relatório                                                    /@
@date			25/10/2015                                                   /@
@description	Impressão de relatório gráfico de pedido de compras          /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Consultoria                                         /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function BCOMR01()
Local aRegs		:= {}
Local cPerg		:= PadR("BCOMR01", Len(SX1->X1_GRUPO))
Local aCabSX1	:= {"X1_GRUPO", "X1_ORDEM", "X1_PERGUNT", "X1_VARIAVL", "X1_TIPO", "X1_TAMANHO", "X1_DECIMAL", "X1_GSC", "X1_VAR01", "X1_DEF01", "X1_DEF02"}

//parametros para o processamento
aAdd(aRegs, {cPerg, "01", "Do Pedido?       ", "mv_ch1", "C", 06, 0, "G", "mv_par01", "", ""})
aAdd(aRegs, {cPerg, "02", "Ate Pedido?      ", "mv_ch2", "C", 06, 0, "G", "mv_par02", "", ""})
aAdd(aRegs, {cPerg, "03", "Da Emissão?      ", "mv_ch3", "D", 08, 0, "G", "mv_par03", "", ""})
aAdd(aRegs, {cPerg, "04", "Ate Emissão?     ", "mv_ch4", "D", 08, 0, "G", "mv_par04", "", ""})
aAdd(aRegs, {cPerg, "05", "Quanto à filial ?", "mv_ch5", "N", 01, 0, "C", "mv_par05", "1-Corrente", "2-Todas"})
//aAdd(aRegs,{cPerg,"06","Descricao Produto","mv_ch6","N",01,0,"G","mv_par05","Produto","Pedido","Compl.Prod."})

U_BRASX1(aRegs,aCabSX1)

if Pergunte(cPerg, .T.)
	U_IMPCOMR01(.T.)
endif
Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		IMPCOMR01                                                    /@
@type			Relatório                                                    /@
@date			25/10/2015                                                   /@
@description	Chamado pela user function BCOMR01 ou pelo parametro 
				MV_PCOMPRA imprime o pedido de compras de acordo com 
				parâmetros informados                                        /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Consultoria                                         /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function IMPCOMR01(lPedCom)
//Local aFormPag 	:= {"Boleto", "Depósito em Conta", "Não Definida"}
Local aArea			:= GetArea()
Local aAreaSM0		:= SM0->(GetArea())
Local cPedIni, cPedFim, dEmiIni, dEmiFim, nK, nQ, nRowI, cQuery, cFilSA2, cFilSA5, cFilSB1, cFilSB5, cFilSE4, cFilSM4, cAprov, cTipoSC7
Private cLogo		:= GetMV("ES_LOGO", .F., "\SYSTEM\BRASITECH.BMP")
Private nPag 		:= 1
Private nLin		:= 0
Private oPC
// Cria os objetos de fontes que serao utilizadas na impressao do relatorio
Private oFont7		:= TFont():New("Arial", 9, 7 , .T., .F., 5, .T., 5, .T., .F.)		// titulos de campos e itens do pedido
Private oFont8		:= TFont():New("Arial", 9, 7.5, .T., .F., 5, .T., 5, .T., .F.)		// fornecedor         
Private oFont9		:= TFont():New("Arial", 9, 9, .T., .F., 5, .T., 5, .T., .F.)		// cabecalho e rodapes
Private oFont9n		:= TFont():New("Arial", 9, 10, .T., .T., 5, .T., 5, .T., .F.)		// cabecalho e rodapes Bold
Private oFont10		:= TFont():New("Arial", 9, 10, .T., .F., 5, .T., 5, .T., .F.)		// pedido de compra
Private oFont16		:= TFont():New("Arial", 9, 20, .T., .T., 5, .T., 5, .T., .F.)		// mumero do pedido de compras
Private aFiliais	:= {}
Private cFormPag, cCondPag, cBcoFor, cSituacao, cComprador, cSolicitante, cMailCom, cMailSol, aAprovador, nTaxa, cSimb

if lPedCom == NIL

	cPedIni 	:= cPedFim := SC7->C7_NUM
	dEmiIni		:= dEmiFim := SC7->C7_EMISSAO
	lCorrente 	:= .T.
	
	SM0->(aAdd(aFiliais, {M0_CODFIL, M0_NOMECOM, M0_ENDCOB, M0_BAIRCOB, M0_CEPCOB, M0_CIDCOB, M0_ESTCOB, M0_CGC, M0_INSC, M0_TEL, M0_FAX}))
	
else

	cPedIni 	:= mv_par01
	cPedFim 	:= mv_par02
	dEmiIni		:= mv_par03
	dEmiFim		:= mv_par04
	lCorrente 	:= (mv_par05 == 1)
	
	SM0->(dbSeek(cEmpAnt))
	do while SM0->(!eof() .and. M0_CODIGO == cEmpAnt)
		SM0->(aAdd(aFiliais, {M0_CODFIL, M0_NOMECOM, M0_ENDCOB, M0_BAIRCOB, M0_CEPCOB, M0_CIDCOB, M0_ESTCOB, M0_CGC, M0_INSC, M0_TEL, M0_FAX}))
		SM0->(dbSkip())
	enddo
	RestArea(aAreaSM0)
	RestArea(aArea)
	
endif

//———————————————————————————————————————————————————————————————————————————————
// Seta as ordens de pesquisa das tabelas
//———————————————————————————————————————————————————————————————————————————————
SA2->(dbSetOrder(1))
SA5->(dbSetOrder(1))
SAJ->(dbSetOrder(1))
//SAH->(dbSetOrder(1))
SB1->(dbSetOrder(1))
SB5->(dbSetOrder(1))
SC1->(dbSetOrder(1))
SC7->(dbSetOrder(1))
SC8->(dbSetOrder(1))
SCR->(dbSetOrder(1))
SE4->(dbSetOrder(1))

dbSelectArea("SC7")

oPC := TMSPrinter():New()
oPC:SetPortrait()
oPC:Setup()
oPC := ReturnPrtObj()
//oPC := TMSPrinter():SetPaperSize(9)		// A4 210 x 297 mm

//———————————————————————————————————————————————————————————————————————————————
// Query para selecionar os pedidos de compra
//———————————————————————————————————————————————————————————————————————————————
cQuery := "SELECT DISTINCT(C7_FILIAL+C7_NUM) PEDIDO "
cQuery += "FROM " + RetSqlName("SC7") + " SC7 "
cQuery += "WHERE D_E_L_E_T_=' ' "
if lCorrente
	cQuery +=   "AND C7_FILIAL = '" + xFilial("SC7") + "' "
endif
cQuery +=       "AND C7_NUM BETWEEN '" + cPedIni + "' AND '" + cPedFim + "' "
cQuery +=       "AND C7_EMISSAO BETWEEN '" + dTOs(dEmiIni) + "' AND '" + dTOs(dEmiFim) + "' "
cQuery +=       "AND C7_TIPO = '1' "
cQuery += "GROUP BY C7_FILIAL+C7_NUM"

if Select("TRB") > 0
	TRB->( dbCloseArea() )
endif

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TRB", .F., .T.)
dbSelectArea("TRB")
dbGoTop()

//———————————————————————————————————————————————————————————————————————————————
// Alimentacao das variaveis de impressao
//———————————————————————————————————————————————————————————————————————————————
do while TRB->(!eof())

	if SC7->(dbSeek(TRB->PEDIDO))
	
		cFilSA2 		:= iif(!Empty(xFilial("SA2")), Left(TRB->PEDIDO, 2), "  ")
		cFilSA5 		:= iif(!Empty(xFilial("SA5")), Left(TRB->PEDIDO, 2), "  ")
		cFilSB1 		:= iif(!Empty(xFilial("SB1")), Left(TRB->PEDIDO, 2), "  ")
		cFilSB5 		:= iif(!Empty(xFilial("SB5")), Left(TRB->PEDIDO, 2), "  ")
		cFilSE4 		:= iif(!Empty(xFilial("SE4")), Left(TRB->PEDIDO, 2), "  ")
		cFilSM4 		:= iif(!Empty(xFilial("SM4")), Left(TRB->PEDIDO, 2), "  ")

		SA2->(dbSeek(cFilSA2 + SC7->C7_FORNECE + SC7->C7_LOJA))
		cLin1For 		:= AllTrim(SA2->A2_NOME) + space(15) + "(" + SC7->C7_FORNECE + " / " + SC7->C7_LOJA +")"
		cLin2For		:= AllTrim(SA2->A2_END) + Space(15) + " - " + AllTrim(SA2->A2_BAIRRO)
		cLin3For		:= "CEP: " + Transform(SA2->A2_CEP, "@R 99999-999") + Space(15) + AllTrim(SA2->A2_MUN) + " - " + SA2->A2_EST
		cLin4For		:= "CNPJ: " + Transform(AllTrim(SA2->A2_CGC), "@R 99.999.999/9999-99") + space(25) + "IE: " + AllTrim(SA2->A2_INSCR)
		cLin5For		:= AllTrim(SC7->C7_CONTATO)
		cLin6For		:= AllTrim(SA2->A2_EMAIL)
		cLin7For		:= AllTrim(SA2->A2_TEL)
		cLin8For		:= AllTrim(SA2->A2_FAX)
	
		nReemissao		:= SC7->C7_QTDREEM + 1
		cPedCom			:= SC7->C7_NUM
		aItSC7			:= {}
		nValDesc 		:= 0
		cReajuste		:= ""
		cCondPag		:= ""
		cBcoFor			:= ""
		cFormPag		:= "Não identificada"
		cSituacao		:= SC7->C7_CONAPRO
		aAprovador		:= {}
		nTaxa			:= SC7->C7_TXMOEDA
		cSimb			:= AllTrim(GetMV("MV_SIMB" + AllTrim(Str(SC7->C7_MOEDA)), .F., "")) + " "
		
		if SC7->(FieldPos("C7_X_FORPG")) > 0
			cFormPag	:= iif(SC7->C7_X_FORPG == "1", "Boleto",;
							iif(SC7->C7_X_FORPG == "2", "Depósito em conta",;
							iif(SC7->C7_X_FORPG == "3", "Dinheiro",;
							iif(SC7->C7_X_FORPG == "4", "Cheque",;
							"Não identificada"))))
			if SC7->C7_X_FORPG == "2"
				if Empty(SA2->A2_BANCO) .or. Empty(SA2->A2_AGENCIA) .or. Empty(SA2->A2_NUMCON) .or. Empty(SA2->A2_DVCTA)
					cBcoFor := "DADOS BANCÁRIOS INCOMPLETOS"
				else
					cBcoFor := "Banco: " + SA2->A2_BANCO + Space(7) +;
								  "Agência: " + AllTrim(SA2->A2_AGENCIA) + iif(!Empty(SA2->A2_DVAGE), "-" + SA2->A2_DVAGE, "") + Space(7) +;
								  "Conta: " + AllTrim(SA2->A2_NUMCON) + "-" + SA2->A2_DVCTA
				endif
			endif
		endif
		
		if SE4->(dbSeek(cFilSE4 + SC7->C7_COND))
			cCondPag		:= AllTrim(SC7->C7_COND) + " - " + AllTrim(SE4->E4_DESCRI)
		endif
		if SM4->(dbSeek(cFilSM4 + SC7->C7_REAJUST))
			cReajuste	:= SM4->M4_DESCR
		endif
		cFrete		:= iif(SC7->C7_TPFRETE == "F", "FOB", iif(SC7->C7_TPFRETE == "C", "CIF", ""))
		cObsRodap	:= iif(SC7->(FieldPos("C7_X_OBSGE")) > 0, AllTrim(SC7->C7_X_OBSGE) + chr(13) + chr(10), "") 	//+ "NOTA: Só aceitaremos a mercadoria se em sua nota fiscal constar o número do nosso pedido de compras."
	
		MaFisEnd()
		MaFisIni(SC7->C7_FORNECE, SC7->C7_LOJA, "F", "N", "R", {})
		R110FIniPC(SC7->C7_NUM,,, "")
	
		nTotIpi	  	:= MaFisRet(,"NF_VALIPI")
		nTotIcms  	:= MaFisRet(,"NF_VALICM")
		nTotDesp  	:= MaFisRet(,"NF_DESPESA")
		nTotFrete 	:= MaFisRet(,"NF_FRETE")
		nTotSeguro	:= MaFisRet(,"NF_SEGURO")
		nTotalNF  	:= MaFisRet(,"NF_TOTAL")
		nPag		:= 1
		cComprador	:= ""
		cMailCom	:= ""
		cSolicitante:= ""
		cMailSol	:= ""
		cAprov		:= ""
		aAprovador	:= {}

		//———————————————————————————————————————————————————————————————————————————————
		// Alçadas
		//———————————————————————————————————————————————————————————————————————————————
		if !Empty(SC7->C7_APROV)
			
			cComprador 	:= Alltrim(UsrFullName(SC7->C7_USER))
			cMailCom	:= Alltrim(UsrRetMail(SC7->C7_USER))
			cTipoSC7	:= iif((SC7->C7_TIPO == 1 .or. SC7->C7_TIPO == 3), "PC", "AE")
			
			SCR->(dbSeek(xFilial("SCR") + cTipoSC7 + SC7->C7_NUM))
			do while SCR->(!eof() .and. CR_FILIAL == xFilial("SCR") .and. Alltrim(CR_NUM) == Alltrim(SC7->C7_NUM) .and. CR_TIPO == cTipoSC7)
				if SCR->CR_STATUS == "03" 		//OK  - Liberado
					cAprov := "Ok, aprovado"
				elseif SCR->CR_STATUS == "04" //BLQ - Bloqueado
					cAprov := "Bloqueado"
				elseif SCR->CR_STATUS == "05" //##  - Nivel Liberado
					cAprov := "Nível liberado por outro aprovador"
				else				               //??  - Aguar.Lib
					cAprov := "Aguardando liberação"
				endif
			
				aAdd(aAprovador, {UsrFullName(SCR->CR_USER), cAprov, SCR->CR_DATALIB})
					
				SCR->(dbSkip())
			enddo
			
		endif

		//———————————————————————————————————————————————————————————————————————————————
		// Itens pedido de compras
		//———————————————————————————————————————————————————————————————————————————————
		do while SC7->(!eof() .and. C7_FILIAL+C7_NUM == TRB->PEDIDO)
	
			SB1->(dbSeek(cFilSB1 + SC7->C7_PRODUTO))	//SB1->B1_DESC
			SB5->(dbSeek(cFilSB5 + SC7->C7_PRODUTO))	//SB5->B5_CEME
			if SC1->(dbSeek(xFilial("SC1") + SC7->C7_NUMSC + SC7->C7_ITEMSC)) .and. (Empty(cSolicitante) .or. Empty(cMailSol))
				cSolicitante	:= Alltrim(UsrFullName(SC1->C1_USER))
				cMailSol		:= Alltrim(UsrRetMail(SC1->C1_USER))
			endif
			
			cDescr := AllTrim(SC7->C7_DESCRI) + " - " + AllTrim(SC7->C7_OBS)
			
			//Codigo de produto do fornecedor
			if SA5->(dbSeek(cFilSA5 + SC7->C7_FORNECE + SC7->C7_LOJA + SC7->C7_PRODUTO)) .and. !empty(SA5->A5_CODPRF)
				cDescr += " ("+AllTrim(SA5->A5_CODPRF)+")"
			endif
	
			cUM := AllTrim(SC7->C7_UM)
	
			//Calculo de descontos
			If SC7->C7_DESC1 != 0 .or. SC7->C7_DESC2 != 0 .or. SC7->C7_DESC3 != 0
				nValDesc	+= CalcDesc(SC7->C7_TOTAL, SC7->C7_DESC1, SC7->C7_DESC2, SC7->C7_DESC3)
			Else
				nValDesc	+= SC7->C7_VLDESC
			Endif
	
			aAdd(aItSC7, {	SC7->C7_ITEM,;
							SC7->C7_PRODUTO,;
							cDescr,;
							cUM,;
							SC7->C7_QUANT,;
							SC7->C7_PRECO,;
							SC7->C7_TOTAL,;
							SC7->C7_IPI,;
							SC7->C7_DATPRF,;
							SC7->C7_CONTA,;
							SC7->C7_CC,;
							SC7->C7_NUMSC,;
							SC7->C7_ITEMSC,;
							SC7->(recno())})
	
			SC7->(dbSkip())
	
		enddo
	
		_nRegistro := SC7->(Recno())
		MaFisEnd()
		
		for nK := 1 to Len(aItSC7)
			SC7->(dbGoto(aItSC7[nK, 14]))
			SC7->(RecLock("SC7",.F.))		  //Atualizacao do flag de Impressao
			SC7->C7_QTDREEM	:= nReemissao
			SC7->C7_EMITIDO	:= "S"
			SC7->(MsUnLock())
		next
		SC7->(dbGoto(_nRegistro))
	
		//———————————————————————————————————————————————————————————————————————————————
		// Cria o objeto de impressao
		//———————————————————————————————————————————————————————————————————————————————
		if len(aItSC7) > 0
		
			Imp_Cabec()
		
			oPC:Box(nLin + 000, 0010, nLin + 230, 2370)
			oPC:Say(nLin + 020, 0040, "Dados do Fornecedor", oFont7,		100)
			oPC:Say(nLin + 060, 0040, cLin1For, 				 oFont10,	100)
			oPC:Say(nLin + 100, 0040, cLin2For, 				 oFont10,	100)
			oPC:Say(nLin + 140, 0040, cLin3For, 				 oFont10,	100)
			oPC:Say(nLin + 180, 0040, cLin4For, 				 oFont10,	100)
			oPC:Say(nLin + 060, 1390, "Contato:", 				 oFont9,		100)
			oPC:Say(nLin + 100, 1390, "E-mail:", 				 oFont9,		100)
			oPC:Say(nLin + 140, 1390, "Telefone:", 			 oFont9,		100)
			oPC:Say(nLin + 180, 1390, "Fax:",	 				 oFont9,		100)
			oPC:Say(nLin + 060, 1540, cLin5For, 				 oFont10,	100)
			oPC:Say(nLin + 100, 1540, cLin6For, 				 oFont10,	100)
			oPC:Say(nLin + 140, 1540, cLin7For, 				 oFont10,	100)
			oPC:Say(nLin + 180, 1540, cLin8For, 				 oFont10,	100)
	
			nLin += 230
		
			Imp_CabItem()
			
			//———————————————————————————————————————————————————————————————————————————————
			// Imprimindo os itens
			//———————————————————————————————————————————————————————————————————————————————
			for nK := 1 to Len(aItSC7)
			
				if nLin > 2200
					nPag++
					Imp_Rodape(.T.)
					Imp_Cabec()
					Imp_CabItem()
				endif
	
				nRowI 	:= nLin
				cDescr 	:= aItSC7[nK, 3]

				oPC:Say(nLin + 010, 0020, Transform(aItSC7[nK, 1], PesqPict("SC7", "C7_ITEM")), 			oFont8, 100)
				oPC:Say(nLin + 010, 0100, Transform(aItSC7[nK, 2], PesqPict("SC7", "C7_PRODUTO")), 			oFont8, 100)
				oPC:Say(nLin + 010, 0400, MemoLine(cDescr, 47, 1), 											oFont8, 100)
				oPC:Say(nLin + 010, 1130, aItSC7[nK, 4], 													oFont8, 100)
				oPC:Say(nLin + 010, 1182, Transform(aItSC7[nK, 5], PesqPict("SC7", "C7_QUANT")), 			oFont8, 100)
				oPC:Say(nLin + 010, 1390, Transform(aItSC7[nK, 6], PesqPict("SC7", "C7_PRECO")), 			oFont8, 100)
				oPC:Say(nLin + 010, 1608, Transform(aItSC7[nK, 7], PesqPict("SC7", "C7_TOTAL")), 			oFont8, 100)
				oPC:Say(nLin + 010, 1826, Transform(aItSC7[nK, 8], PesqPict("SC7", "C7_IPI")), 				oFont8, 100)
				oPC:Say(nLin + 010, 1911, dTOc(aItSC7[nK, 9]), 												oFont8, 100)
				oPC:Say(nLin + 010, 2035, aItSC7[nK, 10], 													oFont8, 100)
				oPC:Say(nLin + 010, 2201, aItSC7[nK, 11], 													oFont8, 100)
				oPC:Say(nLin + 010, 2270, aItSC7[nK, 12], 													oFont8, 100)

				nLin += 10
				for nQ := 2 to MlCount(cDescr, 47)
					nLin += 27
					oPC:Say(nLin, 0400, MemoLine(cDescr, 47, nQ), 												oFont8, 100)
				next
	
				oPC:Box(nRowI, 0010, nLin + 045, 0090)
				oPC:Box(nRowI, 0090, nLin + 045, 0386)
				oPC:Box(nRowI, 0386, nLin + 045, 1120)
				oPC:Box(nRowI, 1120, nLin + 045, 1180)
				oPC:Box(nRowI, 1180, nLin + 045, 1375)
				oPC:Box(nRowI, 1375, nLin + 045, 1596)
				oPC:Box(nRowI, 1596, nLin + 045, 1816)
				oPC:Box(nRowI, 1816, nLin + 045, 1901)
				oPC:Box(nRowI, 1901, nLin + 045, 2025)
				oPC:Box(nRowI, 2025, nLin + 045, 2195)
				oPC:Box(nRowI, 2195, nLin + 045, 2262)
				oPC:Box(nRowI, 2262, nLin + 045, 2370)

				nLin += 45
				
			next
		
			nLin += 30
			nLin := Imp_Rodape(.F.)
			
		else
	
			Help(" ", 1, "® ATENÇÃO",, "Não há dados a emitir." + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Brasitech)", 1)
	
		endif
	
	endif

	TRB->(dbSkip())
	
enddo

oPC:Preview()     // Visualiza antes de imprimir	

if Select("TRB") > 0
	TRB->(dbCloseArea())
endif

return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		IMPCABEC                                                     /@
@type			Relatório                                                    /@
@date			25/10/2015                                                   /@
@description	Chamado pela static function IMPCOMR01, imprime o cabeçalho 
				do pedido de compras.                                        /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Consultoria                                         /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function Imp_Cabec()
Local nLargura	:= 300
Local nPosSM0	:= aScan(aFiliais, {|x| x[1] == Left(TRB->PEDIDO, 2)})
Local cTexto, cCor

if cSituacao == "L"
	cTexto 	:= "Aprovado"
	cCor		:= CLR_GREEN
else
	if cSituacao == "B"
		cTexto 	:= "Bloqueado"
	else
		cTexto 	:= "Reprovado"
	endif
	cCor		:= CLR_HRED
endif	


//aFiliais, {M0_CODFIL, M0_NOMECOM, M0_ENDCOB, M0_BAIRCOB, M0_CEPCOB, M0_CIDCOB, M0_ESTCOB, M0_CGC, M0_INSC, M0_TEL, M0_FAX}))

oPC:StartPage()

nLin := 200

oPC:Box(0070, 0010, nLin + 210, 1340)
oPC:SayBitmap(0075, 0015, cLogo, nLargura, nLargura * 0.4)
oPC:Say(nLin + 000, 0040, aFiliais[nPosSM0, 2], 																									oFont9n,	100)
oPC:Say(nLin + 040, 0040, AllTrim(aFiliais[nPosSM0, 3]) + " - " +;
						  aFiliais[nPosSM0, 4], 																											oFont9,	100)
oPC:Say(nLin + 080, 0040, "CEP: " + Transform(aFiliais[nPosSM0, 5], "@R 99999-999") +;
						  " - " + AllTrim(aFiliais[nPosSM0, 6]) + " - " +;
						  aFiliais[nPosSM0, 7], 																											oFont9,	100)
oPC:Say(nLin + 120, 0040, "CNPJ: " + Transform(AllTrim(aFiliais[nPosSM0, 8]), "@R 99.999.999/9999-99") +;
						  Space(15) + "IE: " + AllTrim(aFiliais[nPosSM0, 9]), 																	oFont9,	100)
oPC:Say(nLin + 160, 0040, "TEL: " +;
						  Transform(AllTrim(aFiliais[nPosSM0, 10]), iif(Len(aFiliais[nPosSM0, 10]) == 12, "@R 99(99) 9999-9999", "@R (99) 9999-9999")) +;
						  Space(15) +;
						  "FAX: " +;
						  Transform(AllTrim(aFiliais[nPosSM0, 11]), iif(Len(aFiliais[nPosSM0, 11]) == 12, "@R 99(99) 9999-9999", "@R (99) 9999-9999")),		oFont9,	100)

oPC:Box(0070, 1340, nLin + 210, 1900)
oPC:Say(nLin - 0075, 1390, "Data de emissão:",																										oFont7,	100)
oPC:Say(nLin - 0080, 1630, dtoc(dDataBase),																											oFont9n,	100)
oPC:Say(nLin + 0100, 1390, AllTrim(Str(nReemissao)) + "a. Emissão", 																			oFont9,	100)
oPC:Say(nLin + 0150, 1390, "Página: " + AllTrim(Str(nPag)),		 																				oFont7,	100)

oPC:Box(0070, 1900, nLin + 210, 2370)
oPC:Say(nLin - 0100, 1950, "PEDIDO DE COMPRAS",					 																					oFont10,	100)
oPC:Say(nLin + 0000, 2020, cPedCom,								 																						oFont16,	100)
oPC:Say(nLin + 0100, 1970, cTexto,					 																									oFont16,	100, cCor)
nLin := 410

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		IMP_CABITEM                                                  /@
@type			Relatório                                                    /@
@date			25/10/2015                                                   /@
@description	Chamado pela static function IMPCOMR01, imprime o cabeçalho 
				do pedido de compras.                                        /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Consultoria                                         /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function Imp_CabItem()

oPC:Box(nLin, 0010, nLin + 050, 0090)
oPC:Box(nLin, 0090, nLin + 050, 0386)
oPC:Box(nLin, 0386, nLin + 050, 1120)
oPC:Box(nLin, 1120, nLin + 050, 1180)
oPC:Box(nLin, 1180, nLin + 050, 1375)
oPC:Box(nLin, 1375, nLin + 050, 1596)
oPC:Box(nLin, 1596, nLin + 050, 1816)
oPC:Box(nLin, 1816, nLin + 050, 1901)
oPC:Box(nLin, 1901, nLin + 050, 2025)
oPC:Box(nLin, 2025, nLin + 050, 2195)
oPC:Box(nLin, 2195, nLin + 050, 2262)
oPC:Box(nLin, 2262, nLin + 050, 2370)

oPC:Say(nLin + 010, 0020, 'Item', 				oFont8, 100)
oPC:Say(nLin + 010, 0100, 'Produto', 			oFont8, 100)
oPC:Say(nLin + 010, 0400, 'Descrição', 			oFont8, 100)
oPC:Say(nLin + 010, 1130, 'UM', 				oFont8, 100)
oPC:Say(nLin + 010, 1190, 'Quantidade', 		oFont8, 100)
oPC:Say(nLin + 010, 1390, 'Vlr. Unitário', 		oFont8, 100)
oPC:Say(nLin + 010, 1620, 'Vlr. Total', 		oFont8, 100)
oPC:Say(nLin + 010, 1830, 'IPI', 				oFont8, 100)
oPC:Say(nLin + 010, 1911, 'Entrega', 			oFont8, 100)
oPC:Say(nLin + 010, 2045, 'Cta.Contabil', 		oFont8, 100)
oPC:Say(nLin + 010, 2201, 'C.C.', 				oFont8, 100)
oPC:Say(nLin + 010, 2270, 'Solicit', 			oFont8, 100)

nLin += 50

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		IMP_RODAPE                                                   /@
@type			Relatório                                                    /@
@date			25/10/2015                                                   /@
@description	Chamado pela static function IMPCOMR01, imprime o cabeçalho 
				do pedido de compras.                                        /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Consultoria                                         /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function Imp_Rodape(lContinua)
Local nX, nLiObs, nCont, nCol

if lContinua
	oPC:Say(nLin+10, 1140, "...CONTINUA...",															oFont8,	100)
	nLin += 40
endif

oPC:Box(nLin + 000, 0010, nLin + 120, 1040)			//condicao de pagamento
oPC:Say(nLin + 010, 0020, "Condição de Pagamento",													oFont8,	100)
oPC:Say(nLin + 050, 0020, cCondPag,																		oFont10,	100)

oPC:Box(nLin + 120, 0010, nLin + 280, 1040)	//forma de pagamento
oPC:Say(nLin + 130, 0020, "Forma de Pagamento",														oFont8,	100)
oPC:Say(nLin + 170, 0020, cFormPag,																		oFont10,	100)
oPC:Say(nLin + 210, 0020, cBcoFor,																		oFont10,	100)

oPC:Box(nLin + 280, 0010, nLin + 400, 1040)	//descontos
oPC:Say(nLin + 280, 0020, "Frete",																		oFont8,	100)
oPC:Say(nLin + 320, 0020, cFrete,																		oFont10,	100)

oPC:Box(nLin, 1040, nLin + 400, 1565)	//despesas acessorias
oPC:Say(nLin + 010, 1050, "Despesas Acessórias / Desconto",										oFont8,	100)
oPC:Say(nLin + 080, 1050, "(+) Vlr Frete:",															oFont8,	100)
oPC:Say(nLin + 077, 1224, cSimb + Transform(nTotFrete,"@E 999,999,999.99"),				oFont10,	100)
oPC:Say(nLin + 150, 1050, "(+) Despesas:",															oFont8,	100)
oPC:Say(nLin + 147, 1224, cSimb + Transform(nTotDesp,"@E 999,999,999.99"),					oFont10,	100)
oPC:Say(nLin + 220, 1050, "(+) Seguro:",																oFont8,	100)
oPC:Say(nLin + 217, 1224, cSimb + Transform(nTotSeguro,"@E 999,999,999.99"),				oFont10,	100)
oPC:Say(nLin + 290, 1050, "(-) Desconto:",															oFont8,	100)
oPC:Say(nLin + 287, 1224, cSimb + Transform(nValDesc,"@E 999,999,999.99"),					oFont10,	100)

oPC:Box(nLin, 1565, nLin + 400, 2090)	//impostos
oPC:Say(nLin + 010, 1575, "Impostos",																	oFont8,	100)
oPC:Say(nLin + 080, 1575, "Valor IPI:",							  									oFont8,	100)
oPC:Say(nLin + 077, 1759, cSimb + Transform(nTotIPI,"@E 999,999,999.99"),					oFont10,	100)
oPC:Say(nLin + 150, 1575, "Valor ICMS:",																oFont8,	100)
oPC:Say(nLin + 147, 1759, cSimb + Transform(nTotICMS,"@E 999,999,999.99"),					oFont10,	100)
oPC:Say(nLin + 220, 1575, "** ICMS DESONERADO **",																oFont8,	100)

oPC:Box(nLin, 2090, nLin + 400, 2370)	//totais
oPC:Say(nLin + 010, 2100, "TOTAL GERAL",																oFont9,	100)
oPC:Say(nLin + 070, 2100, cSimb + Transform(nTotalNF,"@E 999,999,999.99"),					oFont9n,	100)
if AllTrim(cSimb) != "R$"
	oPC:Say(nLin + 170, 2100, "R$ " + Transform(nTotalNF*nTaxa,"@E 999,999,999.99"),		oFont10,	100)
endif

nLin += 400

oPC:Box(nLin, 0010, nLin + 200, 2370)	//observacoes
oPC:Say(nLin+010, 0020, "Observações",												oFont8,	100)

nLiObs := nLin + 040
for nX := 1 to MlCount(cObsRodap, 130)
	oPC:Say(nLiObs, 0020, MemoLine(cObsRodap, 130, nX),	 					oFont10,	100)
	nLiObs += 40
next

nLin += 200

oPC:Box(nLin, 0010, nLin + 320, 0580+110)												// Solicitante
oPC:Say(nLin + 010, 0020, "Solicitante",												oFont8,	100)
oPC:Say(nLin + 180, 0020, "Comprador",													oFont8,	100)
oPC:Box(nLin, 0580+110, nLin + 320, 2370)												// Aprovadores
oPC:Say(nLin + 10, 0590+110, "Autorizações",											oFont8,	100)

nLin		+= 50

oPC:Say(nLin+05, 0020, cSolicitante, 													oFont9n, 100)
oPC:Say(nLin+40, 0020, cMailSol,	 													oFont9,	 100)
oPC:Say(nLin+175, 0020, cComprador, 													oFont9n, 100)
oPC:Say(nLin+210, 0020, cMailCom,	 													oFont9,	 100)

nCol		:= 590+110
nCont		:= 1

oPC:Say(nLin+280, 0020, "Prezado fornecedor, informar em sua nota fiscal o número do nosso pedido de compras.",		oFont9n, 100, CLR_HRED)
oPC:Say(nLin+330, 0020, "Enviar a nota fiscal para os emails do Comprador e do Solicitante.",		oFont9n, 100, CLR_HRED)

if Len(aAprovador) > 0

	for nX := 1 to Len(aAprovador)
	
		oPC:Say(nLin + 10, nCol,	Left(aAprovador[nX,1], 20),				oFont9n, 100)
		oPC:Say(nLin + 50, nCol, 	aAprovador[nX,2],						oFont9,	 100)
		oPC:Say(nLin + 90, nCol, 	"em " + dTOc(aAprovador[nX,3]),			oFont8,	 100)

		nCont++
		nCol	+= 590-200
		
		if nCont > 3
			nCont := 1
			nLin 	+= 130
			nCol	:= 590+110
		endif

	next

endif

oPC:EndPage()
Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		R110FINIPC                                                   /@
@type			Static Function                                              /@
@date			20/05/2000                                                   /@
@description	Inicializa as funcoes Fiscais com o Pedido de Compras.       /@
@author			Edson Maricate                                               /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function R110FIniPC(cPedido,cItem,cSequen,cFiltro)
Local aArea			:= GetArea()
Local aAreaSC7		:= SC7->(GetArea())
Local cValid		:= ""
Local nPosRef		:= 0
Local nItem			:= 0
Local cItemDe		:= IIf(cItem==Nil,'',cItem)
Local cItemAte		:= IIf(cItem==Nil,Repl('Z',Len(SC7->C7_ITEM)),cItem)
Local cRefCols		:= ''
DEFAULT cSequen	:= ""
DEFAULT cFiltro	:= ""

dbSelectArea("SC7")
dbSetOrder(1)
If dbSeek(xFilial("SC7")+cPedido+cItemDe+Alltrim(cSequen))
	MaFisEnd()
	MaFisIni(SC7->C7_FORNECE,SC7->C7_LOJA,"F","N","R",{})
	While !Eof() .AND. SC7->C7_FILIAL+SC7->C7_NUM == xFilial("SC7")+cPedido .AND. ;
			SC7->C7_ITEM <= cItemAte .AND. (Empty(cSequen) .OR. cSequen == SC7->C7_SEQUEN)

		// Nao processar os Impostos se o item possuir residuo eliminado  
		If &cFiltro
			dbSelectArea('SC7')
			dbSkip()
			Loop
		EndIf
            
		// Inicia a Carga do item nas funcoes MATXFIS  
		nItem++
		MaFisIniLoad(nItem)
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek('SC7')
		While !EOF() .AND. (X3_ARQUIVO == 'SC7')
			if SX3->X3_CONTEXT != "V"
				cValid	:= StrTran(UPPER(SX3->X3_VALID)," ","")
				cValid	:= StrTran(cValid,"'",'"')
				If "MAFISREF" $ cValid
					nPosRef  := AT('MAFISREF("',cValid) + 10
					cRefCols := Substr(cValid,nPosRef,AT('","MT120",',cValid)-nPosRef )
					// Carrega os valores direto do SC7.           
					MaFisLoad(cRefCols,&("SC7->"+ SX3->X3_CAMPO),nItem)
				EndIf
			endif
			dbSkip()
		End
		MaFisEndLoad(nItem,2)
		dbSelectArea('SC7')
		dbSkip()
	End
EndIf

RestArea(aAreaSC7)
RestArea(aArea)

Return .T.
