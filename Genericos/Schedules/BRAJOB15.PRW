#include "protheus.ch"
#include "rwmake.ch"
#include "ap5mail.ch"

//———————————————————————————————————————————————————————————————————————————————
// Variável para uso de homologação de ambiente. Informar o(s) endereço(s) de
// email dos destinatários.
// Para producão		DESTINATHOMOLOG ""
// Para homologação 	DESTINATHOMOLOG "seuemail@gamaitaly.com.br"
//———————————————————————————————————————————————————————————————————————————————
#define DESTINATHOMOLOG ""

/*/
———————————————————————————————————————————————————————————————————————————————
@function		BRAJOB15	                                                 /@
@type			User function                                                /@
@date			09/01/2017                                                   /@
@description	Job de workflow de envio de email para aprovação ou rejeição
				de pedidos de compras.                                       /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Tecnologia da Informação                            /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function BRAJOB15()
Local aFiles	:= {"SA2", "SB1", "SC7", "SCR", "SAL"}
Local aEmp		:= {{"01", "01"}, {"01", "03"}, {"01", "09"}}
Local nE, nK

for nE := 1 to Len(aEmp)

	//———————————————————————————————————————————————————————————————————————————————
	// Abertura do ambiente
	//———————————————————————————————————————————————————————————————————————————————
	WfPrepEnv(aEmp[nE,1], aEmp[nE,2], "U_BRAJOB15",, "COM")
	
	for nK := 1 to Len(aFiles)
	
		if Empty(Select(aFiles[nK]))
			ChkFile(aFiles[nK])
		endif
		
	next

	//———————————————————————————————————————————————————————————————————————————————
	// Selecao de pedidos bloqueados
	//———————————————————————————————————————————————————————————————————————————————
	A15_BRAJOB()

	//———————————————————————————————————————————————————————————————————————————————
	// Encerramento do ambiente
	//———————————————————————————————————————————————————————————————————————————————
	RpcClearEnv()

next

ConOut(dTOc(Date()) + " - " + Time() + " BRAJOB15 - Processo de aprovacao de pedidos de compras")

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		A15_BRAJOB	                                                 /@
@type			Static function                                              /@
@date			09/01/2017                                                   /@
@description	Job de workflow de envio de email para aprovação ou rejeição
				de pedidos de compras.                                       /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function A15_BRAJOB()
//CR_STATUS com nivel 02 indica proxima que recebe e-mail
//CR_WF diferente de 1, indica que o e-mail não foi enviado
Local cQuery	:=	"SELECT R_E_C_N_O_ REGISTRO, CR_NUM " +;
					"FROM " + RetSqlName("SCR") + " SCR " +;
					"WHERE SCR.CR_FILIAL = '" + xFilial("SCR") + "' " +;
						"AND SCR.CR_STATUS = '02' " +;
						"AND SCR.CR_WF = ' ' " +;
						"AND SCR.CR_TIPO IN ('PC','AE') " +;
						"AND SCR.D_E_L_E_T_= ' ' " +;
					"ORDER BY CR_NUM"
Local cMailId

//———————————————————————————————————————————————————————————————————————————————
// Verificando a existencia da area Temporaria
//———————————————————————————————————————————————————————————————————————————————
if Select("TSCR") > 0
	TSCR->(dbCloseArea())
endif

//———————————————————————————————————————————————————————————————————————————————
// Criando a tabela temporaria
//———————————————————————————————————————————————————————————————————————————————
dbUseArea( .T., "TOPCONN", TcGenQRY(,,cQuery), "TSCR", .F., .T.)

SA2->(dbSetOrder(1))		//A2_FILIAL, A2_COD, A2_LOJA
SB1->(dbSetOrder(1))		//B1_FILIAL, B1_COD
SC7->(dbSetOrder(1))		//C7_FILIAL, C7_NUM, C7_ITEM, C7_SEQUEN
SCR->(dbSetOrder(1))		//CR_FILIAL, CR_TIPO, CR_NUM, CR_NIVEL
SCS->(dbSetOrder(2))    	//CS_FILIAL, CS_APROV, CS_DATA
SE4->(dbSetOrder(1))		//E4_FILIAL, E4_CODIGO
CN9->(dbSetOrder(1))		//CN9_FILIAL, CN9_NUMERO
SAL->(dbSetOrder(3))		//AL_FILIAL, AL_COD, AL_APROV
ZZH->(DbSetOrder(1))		//ZZH_FILIAL, ZZH_CNPJTR, ZZH_FATURA, ZZH_PREFIX, ZZH_SEQCAN
ZZF->(DbSetOrder(1))		//ZZF_FILIAL, ZZF_CNPJTR, ZZF_FATURA, ZZF_PREFIX, ZZF_SEQCAN, ZZF_NCF, ZZF_NCFSER, ZZF_NFBR, ZZF_SERBR

dbSelectArea("TSCR")
TSCR->(dbGoTop())
do while TSCR->(!eof())
	
	SCR->(dbGoTo(TSCR->REGISTRO))
	
	if SC7->(dbSeek(xFilial("SC7") + Left(SCR->CR_NUM, Len(SC7->C7_NUM)))) .and. SC7->C7_CONAPRO == "B"
	
		cMailId := A15_EnvAprov_BRAJOB()
		
		SCR->(WFSalvaID("SCR", "SCR->CR_WF", 	    "1"))
		SCR->(WFSalvaID("SCR", "SCR->CR_XLINK", 	cMailId))
		SCR->(WFSalvaID("SCR", "SCR->CR_XSENDDT",   Date()))
		SCR->(WFSalvaID("SCR", "SCR->CR_XSENDHR",   Time()))

	endif
	
	TSCR->(dbSkip())

enddo

if Select("TSCR") > 0
	TSCR->(dbCloseArea())
endif

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		A15_ENVAPROV_BRAJOB                                          /@
@type			Static function                                              /@
@date			09/01/2017                                                   /@
@description	Monta o processo de envio do link e montagem da página de 
				aprovação do pedido de compras.                              /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function A15_EnvAprov_BRAJOB()
Local cWFDir		:= "\workflow\emp" + cEmpAnt + "\html"
Local cEndServ		:= GetMV("MV_WFDHTTP", .F.,"http://200.233.165.157:8082/workflow") //(:8181 teste) e (:8182 producao)
Local cLinkLogo	    := AllTrim(GetMV("BR_LNKLOGO", .F., "https://sweb.gamaitaly.com.br/images/LogoGamaPeq.jpg"))
Local nMercad		:= 0
Local nIPI			:= 0
Local nICMS			:= 0
Local nDescont		:= 0
Local nFrete		:= 0
Local nSeguro		:= 0
Local nDespesa		:= 0
Local nTotGer		:= 0
Local aItens		:= {}
Local cNumSC		:= SC7->C7_NUMSC
Local cDirAnexos	:= GetMV("BR_ANEXOPC")
Local cAmbiente	    := Lower(GetEnvServer())
Local lContrato		:= !Empty(SC7->C7_CONTRA)
Local aTpVigenc		:= {"Dias", "Meses", "Anos", "Indeterminada"}
Local aFiles		:= {}
Local cCodAprov		:= SCR->CR_APROV
Local cUserAprov	:= SCR->CR_USER
Local cCodResp		:= iif(!Empty(SCR->CR_XRESP), SCR->CR_XRESP, SCR->CR_APROV)
Local cUserResp		:= iif(!Empty(SCR->CR_XRESPUS), SCR->CR_XRESPUS, SCR->CR_USER)
Local cNomeAprovador:= AllTrim(UsrFullName(cUserResp))
Local cMailAprovador:= AllTrim(UsrRetMail(cUserResp))
Local cUserCompr	:= SC7->C7_USER
Local cNum			:= SC7->C7_NUM
Local dEmissao		:= SC7->C7_EMISSAO
Local cStrComprador	:= AllTrim(UsrFullName(SC7->C7_USER)) + "      (" + UsrRetMail(SC7->C7_USER) + ")"
Local cFormPag		:= iif(SC7->C7_X_FORPG == "1", "Boleto",;
							iif(SC7->C7_X_FORPG == "2", "Depósito em conta",;
							iif(SC7->C7_X_FORPG == "3", "Dinheiro",;
							iif(SC7->C7_X_FORPG == "4", "Cheque",;
							"Não identificada"))))
Local cObsGer		:= AllTrim(SC7->C7_X_OBSGE)
Local cTipo			:= SC7->C7_TIPO
Local nTaxa			:= SC7->C7_TXMOEDA
Local cSimb			:= AllTrim(GetMV("MV_SIMB" + AllTrim(Str(SC7->C7_MOEDA)), .F., "")) + " "
Local cMoeda		:= AllTrim(GetMV("MV_MOEDA" + AllTrim(Str(SC7->C7_MOEDA)), .F., ""))
Local cCategoria	:= SC7->C7_XCATEG
Local cMotAlt		:= SC7->C7_XMOTALT
Local cStrApr		:= StrTran(SC7->C7_XHISAPR, ";", Chr(13) + Chr(10))
Local cNewStrApr	:= ""
Local cPrefixo		:= SC7->C7_XGKOPRE
Local cFatura		:= SC7->C7_XGKOFAT
Local nSomaNF		:= 0
Local nIndReal		:= 0
Local nSomFrtPrev	:= 0
//Local nIndFret		:= 0
//Local nIndPrev		:= 0
Local nX, cFornecedor, cCondicao, cIdioma, aLimite, cContrato, cVigencia, dInicio, dFim, dAssinat,;
	  cTipoCtr, nVlContrato, cObjeto, cCnpj, aFilesApoio, cPathApoio, cAssunto, cIdCli, cParte,;
	  nPos, nEnvio, cTitulo, cFormulario, cEvento, cVencimento, cChvPart1, cChvPart2
Private oHTML, cMailID

//———————————————————————————————————————————————————————————————————————————————
// Alimentando aFiles para os anexos das aprovações (Pedido de Compra e medição)
//———————————————————————————————————————————————————————————————————————————————
cPathApoio	:= cDirAnexos + "\" + cEmpAnt + cFilAnt + "\PC\" + StrZero(Year(SC7->C7_EMISSAO), 4) + "\" + "mes_" + StrZero(Month(SC7->C7_EMISSAO), 2) + "\"
aFilesApoio	:= Directory(cPathApoio + AllTrim(cFilAnt)+ "_" + AllTrim(SC7->C7_NUM) + "_" + "*.*")
for nX:=1 to Len(aFilesApoio)
	aAdd(aFiles, { cPathApoio, aFilesApoio[nX,1], aFilesApoio[nX,2]})
next

//———————————————————————————————————————————————————————————————————————————————
// Alimentando aFiles para os anexos das aprovações (Contrato)
//E:\Totvs\TM_DEV\Protheus_data\EDI01\cotacoes\0103\ct\000000000000241
//———————————————————————————————————————————————————————————————————————————————
cPathApoio	:= cDirAnexos + "\" + cEmpAnt + cFilAnt + "\CT\" + AllTrim(SC7->C7_CONTRA) + "\"
aFilesApoio	:= Directory(cPathApoio + "*.*")
for nX:=1 to Len(aFilesApoio)
	aAdd(aFiles, { cPathApoio, aFilesApoio[nX,1], aFilesApoio[nX,2]})
next

//———————————————————————————————————————————————————————————————————————————————
// Identificando anexos na solicitação de compras
//———————————————————————————————————————————————————————————————————————————————
SC1->(dbSetOrder(1))		//C1_FILIAL, C1_NUM, C1_ITEM, C1_ITEMGRD
if SC1->(dbSeek(xFilial("SC1") + cNumSC))
	cPathApoio	:= cDirAnexos + "\" + cEmpAnt + cFilAnt + "\SC\" + StrZero(Year(SC1->C1_EMISSAO), 4) + "\" + "mes_" + StrZero(Month(SC1->C1_EMISSAO), 2) + "\"
	aFilesApoio	:= Directory(cPathApoio + AllTrim(cFilAnt)+ "_" + AllTrim(cNumSC) + "_" + "*.*")
	for nX:=1 to Len(aFilesApoio)
		aAdd(aFiles, { cPathApoio, aFilesApoio[nX,1], aFilesApoio[nX,2]})
	next
endif

SA2->(dbSeek(xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA))
SAK->(dbSeek(xFilial("SAK") + cCodResp))
SE4->(dbSeek(xFilial("SE4") + SC7->C7_COND))
SAL->(dbSeek(xFilial("SAL") + SCR->CR_GRUPO + cCodAprov))

	//———————————————————————————————————————————————————————————————————————————————
	// Atualiza variável de controle de envio, que será gravada no campo C7_XHISAPR
	// e define o título do assunto
	//———————————————————————————————————————————————————————————————————————————————
	for nX := 1 to MlCount(cStrApr)
		cParte 	:= AllTrim(MemoLine(cStrApr,, nX))
		nPos 	:= At("=", cParte)
			
		if Left(cParte, nPos - 1) == SCR->CR_USER
			nEnvio		:= Val(Substr(cParte, nPos + 1)) + 1
			cNewStrApr 	+= Left(cParte, nPos - 1) + "=" + AllTrim(Str(nEnvio)) + ";"
		elseif !empty(cParte)
			cNewStrApr 	+= StrTran(cParte, Chr(13) + Chr(10), "") + ";"
		endif
	next
		
	SC7->(dbSeek(xFilial("SC7") + Alltrim(cNum)))
	do while SC7->(!eof() .and. C7_FILIAL == xFilial("SC7") .and. C7_NUM == cNum)		//TSC7->C7_NUM
		if SC7->(RecLock("SC7",.F.))
			SC7->C7_XHISAPR	:= cNewStrApr
			SC7->(MsUnlock())
		endif
		SC7->(dbSkip())
	enddo
	SC7->(dbSeek(xFilial("SC7") + Alltrim(cNum)))


//———————————————————————————————————————————————————————————————————————————————
// Posicionando tabelas e alimentando variáveis, quando contrato
//———————————————————————————————————————————————————————————————————————————————
if lContrato
	CN9->(dbSeek(xFilial("CN9") + Left(SC7->C7_CONTRA, Len(CNE->CNE_CONTRA))))
	CN1->(dbSeek(xFilial("CN1") + CN9->CN9_TPCTO))

	cContrato	:= CN9->CN9_NUMERO
	cVigencia	:= aTpVigenc[Val(CN9->CN9_UNVIGE)]
	dInicio		:= CN9->CN9_DTINIC
	dFim		:= CN9->CN9_DTFIM
	dAssinat	:= CN9->CN9_DTASSI
	cTipoCtr	:= CN9->CN9_TPCTO + " - " + CN1->CN1_DESCRI
	nVlContrato	:= CN9->CN9_VLINI
	cObjeto		:= MSMM(CN9->CN9_CODOBJ)
endif

//———————————————————————————————————————————————————————————————————————————————
// Verificação se integração GKO / Logistica
//———————————————————————————————————————————————————————————————————————————————
if !Empty(cFatura)

	cStrComprador	:= "Processo automático"
	ZZH->(dbSeek(xFilial("ZZH") + SA2->A2_CGC + SC7->C7_XGKOFAT + SC7->C7_XGKOPRE + "   "))
	cVencimento		:= dTOc(ZZH->ZZH_VENCTO)
	cChvPart1		:= xFilial("ZZF") + ZZH->(ZZH_CNPJTR + ZZH_FATURA + ZZH_PREFIX + ZZH_SEQCAN)

	ZZF->(dbSeek(cChvPart1))
	cEvento 		:= ZZF->ZZF_EVENTO

	do while ZZF->(!Eof() .and. ZZF_FILIAL+ZZF_CNPJTR+ZZF_FATURA+ZZF_PREFIX+ZZF_SEQCAN == cChvPart1)
		cChvPart2	:= ZZF->(ZZF_NCF + ZZF_NCFSER)

		do while ZZF->(!Eof() .and. ZZF_FILIAL+ZZF_CNPJTR+ZZF_FATURA+ZZF_PREFIX+ZZF_SEQCAN+ZZF_NCF+ZZF_NCFSER==cChvPart1 + cChvPart2)
			nSomaNF		+= ZZF->ZZF_VALBR
			//nSomFrtReal	+= ZZF->ZZF_NCFVRE
			nSomFrtPrev	+= ZZF->ZZF_NCFVPR

			ZZF->(dbSkip())
		enddo

	enddo
	//nIndReal	:= nSomFrtReal / nSomaNF
	//nIndPrev	:= 0
endif

//———————————————————————————————————————————————————————————————————————————————
// Verificação se reembolso de consumidor final
//———————————————————————————————————————————————————————————————————————————————
if !Empty(SC7->C7_XCONSUM)
	cIdCli	:= iif(Len(AllTrim(SC7->C7_XCPF)) > 11,;
					", CNPJ: " + Transform(SC7->C7_XCPF, "@R 99.999.999/9999-99"),;
					", CPF: " + Transform(SC7->C7_XCPF, "@R 999.999.999-99"))
	cObsGer += "<br><br>Reembolso consumidor final para " + AllTrim(SC7->C7_XCONSUM) +;
				cIdCli +;
				"<br> Banco " + AllTrim(SC7->C7_XBANCO) +;
				", Agência " + AllTrim(SC7->C7_XAGENC) + iif(!Empty(SC7->C7_XDVAGE), "-" + AllTrim(SC7->C7_XDVAGE), "") +;
				", Conta " + AllTrim(SC7->C7_XCONTA) + iif(!Empty(SC7->C7_XDVCTA), "-" + AllTrim(SC7->C7_XDVCTA), "")
endif

cCondicao	    := SC7->C7_COND + " - " + AllTrim(SE4->E4_DESCRI)
cIdioma		    := SAK->AK_XIDIOMA
cFornecedor	    := SA2->A2_NOME + "  (" + SC7->C7_FORNECE + "/" + SC7->C7_LOJA + ")"
cCNPJ			:= Transform(SA2->A2_CGC, "@R 99.999.999/9999-99")
aLimite			:= GetLimite((SAL->AL_LIBAPR == "A"))

do while SC7->(!eof() .and. C7_FILIAL == xFilial("SC7") .and. C7_NUM == cNum)
	SB1->(dbSeek(xFilial("SB1") + SC7->C7_PRODUTO))
	CTT->(dbSeek(xFilial("CTT") + SC7->C7_CC))
	cNumSc      := IIF(LEN(ALLTRIM(SC7->C7_NUMSC))>0,ALLTRIM(SC7->C7_NUMSC),"S/SC") 
	nMercad	    += SC7->C7_TOTAL
	nIPI		+= SC7->C7_VALIPI
	nICMS		+= SC7->C7_VALICM
	nDescont	+= SC7->C7_VLDESC
	nFrete	    += SC7->C7_VALFRE
	nSeguro	    += SC7->C7_SEGURO
	nDespesa	+= SC7->C7_DESPESA
	nTotGer	    += SC7->(C7_TOTAL + C7_VALIPI + C7_VALFRE + C7_SEGURO + C7_DESPESA - C7_VLDESC)
	aAdd(aItens, {	SC7->C7_ITEM,;
					SC7->C7_PRODUTO,;
					AllTrim(SC7->C7_DESCRI) + iif(!empty(SC7->C7_OBS), " - " + AllTrim(SC7->C7_OBS), ""),;
					SC7->C7_UM,;
					SC7->C7_QUANT,;
					SC7->C7_PRECO,;
					SC7->C7_TOTAL,;
					SC7->C7_IPI,;
					SC7->C7_DATPRF,;
					AllTrim(SC7->C7_CC) + " / " + Left(CTT->CTT_DESC01, 20),;
				 	cNumSc })
	
	SC7->(dbSkip())      
	
enddo

nIndReal	:= NoRound(nTotGer / nSomaNF, 4) * 100

//———————————————————————————————————————————————————————————————————————————————
//———————————————————————————————————————————————————————————————————————————————
// Monta processo para aprovação de PEDIDO DE COMPRA - formulario APROVAÇÃO
//———————————————————————————————————————————————————————————————————————————————
//———————————————————————————————————————————————————————————————————————————————
oProcess 			:= TWFProcess():New("BRJB15", "Pedido de compra")
oProcess:cTo 		:= "JOB15_APROV"
oProcess:NewTask("000015", iif(cIdioma == "2", "\workflow\BRAJOB15_Aprov_SPA.htm", "\workflow\BRAJOB15_Aprov.htm"))

if !lContrato

	//———————————————————————————————————————————————————————————————————————————————
	// Despesa Financeira / Recursos Humanos
	//———————————————————————————————————————————————————————————————————————————————
	if cCategoria $ "DP"
		cTitulo		:= iif(cIdioma=="2", "Análisis de gasto financiero", "Análise de despesa financeira")
		cAssunto	:= cTitulo + " Nr. " + cNum
		cFormulario	:= iif(cIdioma == "2", "\workflow\BRAJOB15_LinkDES_SPA.htm", "\workflow\BRAJOB15_LinkDES.htm")

	elseif cCategoria $ "RH"
		cTitulo		:= iif(cIdioma=="2", "Análisis de gasto Recursos Humanos", "Análise de despesa Recursos Humanos")
		cAssunto	:= cTitulo + " Nr. " + cNum
		cFormulario	:= iif(cIdioma == "2", "\workflow\BRAJOB15_LinkDES_SPA.htm", "\workflow\BRAJOB15_LinkDES.htm")

	//———————————————————————————————————————————————————————————————————————————————
	// Despesas com Logistica (Frete GKO)
	//———————————————————————————————————————————————————————————————————————————————
	elseif cCategoria $ "LG"
		cTitulo		:= iif(cIdioma=="2", "Autorización de pago de envío", "Autorização de pagamento de frete")
		cAssunto	:= cTitulo + " Nr. " + cNum
		cFormulario	:= iif(cIdioma == "2", "\workflow\BRAJOB15_LinkLOG_SPA.htm", "\workflow\BRAJOB15_LinkLOG.htm")

	//———————————————————————————————————————————————————————————————————————————————
	// Pedidos de Compras
	//———————————————————————————————————————————————————————————————————————————————
	else
		cTitulo		:= iif(cIdioma=="2", "Análisis de la orden de compra", "Análise do pedido de compra")
		cAssunto	:= cTitulo + " Nr. " + cNum
		cFormulario	:= iif(cIdioma == "2", "\workflow\BRAJOB15_Link_SPA.htm", "\workflow\BRAJOB15_Link.htm")

	endif

else

	//———————————————————————————————————————————————————————————————————————————————
	// Medição de contrato
	//———————————————————————————————————————————————————————————————————————————————
	cTitulo		:= iif(cIdioma=="2", "Aprobación de la medición del contrato", "Aprovação de medição de contrato")
	cAssunto	:= cTitulo + iif(cIdioma=="2", ", Orden de Compra Nr. ", ", Pedido de Compra Nr. ") + cNum
	cFormulario	:= iif(cIdioma == "2", "\workflow\BRAJOB15_LinkCTR_SPA.htm", "\workflow\BRAJOB15_LinkCTR.htm")

endif

oProcess:cSubject := cAssunto + iif(nEnvio > 1, " - " + AllTrim(Str(nEnvio)) + "° envio", "")	//considera o numero do envio, caso seja maior que 1
oProcess:bReturn  := "U_A15Ret_BRAJOB()"
oProcess:UserSiga := "JOB15"
oProcess:NewVersion(.T.)

oHTML   				:= oProcess:oHTML

//———————————————————————————————————————————————————————————————————————————————
// Campos de controle para o retorno da página da aprovação
//———————————————————————————————————————————————————————————————————————————————
oHTML:ValByName("NUMERO",			cNum)
oHTML:ValByName("TIPO",				cTipo)
oHTML:ValByName("USERCOMPR",		cUserCompr)
oHTML:ValByName("APROVADOR",		cUserAprov)
//oHTML:ValByName("RESPONSAVEL",		cUserResp)

//———————————————————————————————————————————————————————————————————————————————
// Cabeçalho / Rodapé
//———————————————————————————————————————————————————————————————————————————————
oHTML:ValByName("C_LINKLOGO",		cLinkLogo)
oHTML:ValByName("C_TITULO",			Upper(cTitulo))
oHTML:ValByName("C_FILIAL",		    Upper(SM0->M0_FILIAL))
oHTML:ValByName("C_NUM",			cNum)
oHTML:ValByName("C_EMISSAO",		dTOc(dEmissao))
//oHTML:ValByName("C_COMPRADOR",	    cStrComprador)
oHTML:ValByName("C_FORNECEDOR",	    cFornecedor)
oHTML:ValByName("C_CNPJ",	 		cCNPJ)
//	oHTML:ValByName("C_CONDPAG",		cCondicao)
//	oHTML:ValByName("C_FORMAPAG",		cFormPag)
oHTML:ValByName("C_OBS",	  		cObsGer)

oHTML:ValByName("R_TOTAL",			cSimb + AllTrim(Transform(nTotGer, 			"@E 999,999,999.99")))
oHTML:ValByName("C_MOEDA",			iif(cCategoria=="RH", "", cMoeda))
oHTML:ValByName("C_TAXA",	  		iif(cCategoria=="RH", "", Transform(nTaxa, "@E 999,999.9999")))
oHTML:ValByName("R_TOTCONV",		iif(cCategoria=="RH", "", "R$ " + AllTrim(Transform(nTotGer*nTaxa, 	"@E 999,999,999.99"))))


//———————————————————————————————————————————————————————————————————————————————
//———————————————————————————————————————————————————————————————————————————————
// Monta processo para aprovação de PEDIDO DE COMPRA - formulario LINK eMail
//———————————————————————————————————————————————————————————————————————————————
//———————————————————————————————————————————————————————————————————————————————
cMailID 				:= oProcess:Start(cWFDir,.T.)
//oHTML:ValByName("R_MAILID",		cMailId)
//oHTML:ValByName("R_AMBIENTE",	cAmbiente)

//—————————————————————————————————————————————————————————————————————————————
// LINK - identificando o formulário a ser utilizado
//—————————————————————————————————————————————————————————————————————————————
oProcess:NewTask(cAssunto + iif(nEnvio > 1, " - " + AllTrim(Str(nEnvio)) + "° envio", ""), cFormulario)
	
//———————————————————————————————————————————————————————————————————————————————
// Anexos
//———————————————————————————————————————————————————————————————————————————————
for nX := 1 to Len(aFiles)
	oProcess:AttachFile(aFiles[nX,1] + aFiles[nX,2])
next

oProcess:cSubject   := cAssunto + iif(nEnvio > 1, " - " + AllTrim(Str(nEnvio)) + "° envio", "")	//considera o numero do envio, caso seja maior que 1
if !Empty(DESTINATHOMOLOG)
	oProcess:cTo		:= DESTINATHOMOLOG	// Informe o endereço eletrônico do destinatário.
	ConOut(">>> SC7 DESTINATHOMOLOG " + DESTINATHOMOLOG + "  oProcess:cTO " + oProcess:cTo)
else
	oProcess:cTo		:= cMailAprovador	// Informe o endereço eletrônico do destinatário.
endif
oHTML   	 		:= oProcess:oHTML

ConOut("(BEGIN|WFLINK)Process Id: " + oProcess:fProcessID + " - Task: " + oProcess:fTaskID)


//———————————————————————————————————————————————————————————————————————————————
// Seção de pedidos de compras ou aprovação de despesas que não são contratos
//———————————————————————————————————————————————————————————————————————————————
if !lContrato
	//———————————————————————————————————————————————————————————————————————————————
	// Cabeçalho / Rodapé
	//———————————————————————————————————————————————————————————————————————————————
	if nEnvio > 1
		oHTML:ValByName("C_TEXTOMOTALT", 	"Motivo da alteração: ")
		oHTML:ValByName("C_MOTALT", 		cMotAlt)
	endif
	oHTML:ValByName("C_NOMEAPROV", 		cNomeAprovador)
	oHTML:ValByName("C_LINKLOGO",		cLinkLogo)
	oHTML:ValByName("C_NUM",			cNum)
	oHTML:ValByName("C_FILIAL",		    Upper(SM0->M0_FILIAL))
	oHTML:ValByName("C_EMISSAO",		dTOc(dEmissao))
	oHTML:ValByName("C_FORNECEDOR",	    cFornecedor)
	oHTML:ValByName("C_CNPJ",	 		cCNPJ)
	oHTML:ValByName("C_FORMAPAG",		cFormPag)
	oHTML:ValByName("C_OBS",	  		cObsGer)

	if cCategoria == "LG"
		oHTML:ValByName("C_FATURA",	    cFatura)
		oHTML:ValByName("C_PREFIXO",	cPrefixo)
		oHTML:ValByName("C_EVENTO",		cEvento)
		oHTML:ValByName("C_VENCIMENTO",	cVencimento)
	else
		oHTML:ValByName("C_CONDPAG",		cCondicao)		
		oHTML:ValByName("C_COMPRADOR",	    cStrComprador)
		oHTML:ValByName("C_MOEDA",		iif(cCategoria=="RH", "", cMoeda))
		oHTML:ValByName("C_TAXA",	  	iif(cCategoria=="RH", "", Transform(nTaxa, "@E 999,999.9999")))
		oHTML:ValByName("R_TOTCONV",	iif(cCategoria=="RH", "", "R$ " + AllTrim(Transform(nTotGer*nTaxa,    "@E 999,999,999.99"))))
	endif

	if !cCategoria $ "DP/RH/LG"
		oHTML:ValByName("R_FRETE",		cSimb + AllTrim(Transform(nFrete, 	        "@E 999,999,999.99")))
		oHTML:ValByName("R_DESPESA",	cSimb + AllTrim(Transform(nDespesa,         "@E 999,999,999.99")))
		oHTML:ValByName("R_SEGURO",	    cSimb + AllTrim(Transform(nSeguro, 	        "@E 999,999,999.99")))
		oHTML:ValByName("R_DESCONTO",	cSimb + AllTrim(Transform(nDescont,         "@E 999,999,999.99")))
		oHTML:ValByName("R_IPI",		cSimb + AllTrim(Transform(nIPI, 	        "@E 999,999,999.99")))
		oHTML:ValByName("R_ICMS",		cSimb + AllTrim(Transform(nICMS, 	        "@E 999,999,999.99")))
		oHTML:ValByName("R_MERCAD",	    cSimb + AllTrim(Transform(nMercad, 	        "@E 999,999,999.99")))
	endif
	oHTML:ValByName("R_TOTAL",		cSimb + AllTrim(Transform(nTotGer,      	"@E 999,999,999.99")))

	//———————————————————————————————————————————————————————————————————————————————
	// Itens
	//———————————————————————————————————————————————————————————————————————————————
	for nX := 1 to Len(aItens)

		aAdd((oHTML:ValByName("I.PRODUTO")),	aItens[nX,2])
		aAdd((oHTML:ValByName("I.DESCR")),		aItens[nX,3])
		aAdd((oHTML:ValByName("I.CCUSTO")),		aItens[nX,10])

		if cCategoria == "LG"
			aAdd((oHTML:ValByName("I.VALNF")),		Transform(nSomaNF , "@E 999,999,999.99"))
			aAdd((oHTML:ValByName("I.FRETEREAL")),	Transform(nTotGer, "@E 999,999,999.99"))
			aAdd((oHTML:ValByName("I.INDREAL")),	Transform(nIndReal, "@E 999,999,999.99"))
		else
			aAdd((oHTML:ValByName("I.ITEM")),		aItens[nX,1])
			aAdd((oHTML:ValByName("I.QTDE")),		Transform(aItens[nX,5], "@E 999,999,999.99"))	
			aAdd((oHTML:ValByName("I.UNIT")),		Transform(aItens[nX,6], "@E 999,999,999.99"))
			aAdd((oHTML:ValByName("I.TOTAL")),		Transform(aItens[nX,7], "@E 999,999,999.99"))

			if !cCategoria $ "DP/RH"
				aAdd((oHTML:ValByName("I.UM")),			aItens[nX,4])
				aAdd((oHTML:ValByName("I.IPI")),		Transform(aItens[nX,8], "@E 999.9 %"))
				aAdd((oHTML:ValByName("I.ENTREGA")),	dTOc(aItens[nX,9]))
				aAdd((oHTML:ValByName("I.CSOLIC")),		aItens[nX,11])
			endif
		endif

	next

//———————————————————————————————————————————————————————————————————————————————
//———————————————————————————————————————————————————————————————————————————————
// Seção de medição de contrato
//———————————————————————————————————————————————————————————————————————————————
else

	//———————————————————————————————————————————————————————————————————————————————
	// Cabeçalho medição de contrato
	//———————————————————————————————————————————————————————————————————————————————
	oHTML:ValByName("C_LINKLOGO",		cLinkLogo)
	oHTML:ValByName("C_FILIAL",		    Upper(SM0->M0_FILIAL))
	oHTML:ValByName("C_APROVADOR", 		cNomeAprovador)
	
	oHTML:ValByName("C_CONTRATO",		cContrato)
	oHTML:ValByName("C_VIGENCIA",		cVigencia)
	oHTML:ValByName("C_INICIO",			dTOc(dInicio))
	oHTML:ValByName("C_FIM",			dTOc(dFim))
	oHTML:ValByName("C_ASSINATURA",		dTOc(dAssinat))

	oHTML:ValByName("C_TIPOCTR",		cTipoCtr)
	oHTML:ValByName("C_CONDPAG",		cCondicao)
	oHTML:ValByName("C_VALORCTR",		Transform(nVlContrato, "@E 999,999,999.99"))
	
	oHTML:ValByName("C_FORNECEDOR",		cFornecedor)
	oHTML:ValByName("C_CNPJ",			cCNPJ)

	oHTML:ValByName("C_NUM",			cNum)

	oHTML:ValByName("C_OBJETO",			cObjeto)


	//———————————————————————————————————————————————————————————————————————————————
	// Itens medição de contrato
	//———————————————————————————————————————————————————————————————————————————————
	for nX := 1 to Len(aItens)
		aAdd((oHTML:ValByName("I.ITEM")),		aItens[nX,1])
		aAdd((oHTML:ValByName("I.PRODUTO")),	aItens[nX,2])
		aAdd((oHTML:ValByName("I.DESCR")),		aItens[nX,3])
		aAdd((oHTML:ValByName("I.QTDE")),		Transform(aItens[nX,5], "@E 999,999,999.99"))	
		aAdd((oHTML:ValByName("I.UNIT")),		Transform(aItens[nX,6], "@E 999,999,999.99"))
		aAdd((oHTML:ValByName("I.TOTAL")),		Transform(aItens[nX,7], "@E 999,999,999.99"))
		aAdd((oHTML:ValByName("I.CCUSTO")),		aItens[nX,10])
		aAdd((oHTML:ValByName("I.CSOLIC")),		aItens[nX,11])
	next

	//———————————————————————————————————————————————————————————————————————————————
	// Rodapé medição de contrato
	//———————————————————————————————————————————————————————————————————————————————
	oHTML:ValByName("R_TOTAL",		cSimb + AllTrim(Transform(nTotGer, 			"@E 999,999,999.99")))
	oHTML:ValByName("R_TOTCONV",	"R$ " + AllTrim(Transform(nTotGer*nTaxa, 	"@E 999,999,999.99")))

endif



//———————————————————————————————————————————————————————————————————————————————
// Seção de limite de aprovador
//———————————————————————————————————————————————————————————————————————————————
oHTML:ValByName("R_LIMITE",		iif(cCategoria=="RH", "", "R$ " + AllTrim(Transform(aLimite[1],		"@E 999,999,999.99"))))
oHTML:ValByName("R_SALDO",	    iif(cCategoria=="RH", "", "R$ " + AllTrim(Transform(aLimite[2],		"@E 999,999,999.99"))))
oHTML:ValByName("R_NOTA",		iif(cCategoria=="RH", "", aLimite[3]))

oHTML:ValByName("R_MAILID",	    cMailId)
oHTML:ValByName("R_AMBIENTE",	cAmbiente)

oProcess:oHTML:ValByName("proc_link", cEndServ + "/emp" + cEmpAnt + "/html/" + cMailID + ".htm")	//"proc_link" é o nome que está definido no html brajob15_link
oProcess:Start()

Return(cMailId)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		A15RET_BRAJOB                                                /@
@type			Static function                                              /@
@date			09/01/2017                                                   /@
@description	Retorno reposta da aprovação/rejeição do pedido de compras.  /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function A15Ret_BRAJOB(oProcess)
Local cNumPC	:= Left(oProcess:oHtml:RetByName("NUMERO"),6)
Local cCodAprov	:= AllTrim(oProcess:oHtml:RetByName("APROVADOR"))
Local cOpcao	:= AllTrim(oProcess:oHtml:RetByName("OPC"))
Local cObs		:= AllTrim(oProcess:oHtml:RetByName("JUSTIFICATIVA"))
Local cMailId	:= Substr(AllTrim(oProcess:oHtml:RetByName("WFMAILID")), 3)		//campo alimentado com a string 'WF' + o código do processo
Local cTipo		:= iif(AllTrim(oProcess:oHtml:RetByName("TIPO")) == "1", "PC", "AE")
Local cEmlContr	:= GetMV("BR_DESPEML", .F., "")
Local cDirApoio	:= ""
Local lLiberou	:= .F.
Local cQuery	:= ""
Local cNomeSol	:= ""
Local cMailSol	:= ""
Local cCorpo, nContador, cAssunto, cDestinat, lBlqProxNivel, cCategoria, lConsumidor	//, cMsg, cDestAprov

oProcess:Finish()           // FINALIZA O PROCESSO

SC1->(dbSetOrder(1))		//C1_FILIAL, C1_NUM, C1_ITEM
SC7->(dbSetOrder(1))		//C7_FILIAL, C7_NUM, C7_ITEM
SCR->(dbSetOrder(2))		//CR_FILIAL, CR_TIPO, CR_NUM, CR_USER

SC7->(dbSeek(xFilial("SC7") + cNumPC))
if !Empty(SC7->C7_NUMSC) .and. !Empty(SC7->C7_ITEMSC)
	SC1->(dbSeek(xFilial("SC1") + SC7->C7_NUMSC + SC7->C7_ITEMSC))
	cNomeSol	:= AllTrim(UsrFullName(SC1->C1_USER))
	cMailSol	:= Alltrim(UsrRetMail(SC1->C1_USER))
endif

cCategoria	:= SC7->C7_XCATEG
lConsumidor	:= !Empty(SC7->C7_XCONSUM)

if SCR->(dbSeek(xFilial("SCR") + cTipo + PadR(cNumPC, Len(SCR->CR_NUM)) + cCodAprov))

	//Verifica se o e-mail respondido, refere-se ao link ativo (quando há alteração no pedido, novos emails são enviados, com uma nova numeração de controle)
	if cMailId == SCR->CR_XLINK

		if SCR->CR_STATUS == "05"
			
			cDestinat	:= Alltrim(UsrRetMail(iif(!Empty(SCR->CR_XRESP), SCR->CR_XRESP, SCR->CR_USER)))
			cAssunto	:= "Pedido de Compra nr. " + SC7->C7_NUM + iif(SC7->C7_CONAPRO == "L", " APROVADO", " REPROVADO") + " anteriormente"
			cCorpo		:= '<html><body>' +;
							'<font size="3" face="Calibri">Prezado(a) ' + AllTrim(UsrFullName(iif(!Empty(SCR->CR_XRESP), SCR->CR_XRESP, SCR->CR_USER))) + ',</font><br><br>' +;
							'<font size="3" face="Calibri">O Pedido de Compra nr. ' + SC7->C7_NUM + ' foi ' + iif(SC7->C7_CONAPRO == "L", "aprovado", "reprovado") + ' anteriormente por alguém com o mesmo nível de alçada que o seu, portanto sua ação neste pedido não foi aceita.</font><br><br><br>' +;
							'<font size="1" face="Calibri"><i>E-mail automático enviado pelo processo de workflow, Favor não respondê-lo.</i></font><br><br>' +;
							'</body></html>'

		else
	
			SCR->(dbSetOrder(1))		//CR_FILIAL, CR_TIPO, CR_NUM, CR_NIVEL
			
			cNivel		:= SCR->CR_NIVEL
			cDestinat 	:= Alltrim(UsrRetMail(SC7->C7_USER))
			if !Empty(cMailSol)
				cDestinat += "; " + cMailSol
			endif
	
			/*
			MaAlcDoc(ExpA1,ExpD1,ExpN1,ExpC1,ExpL1)
			Parametros:		ExpA1 = Array com informacoes do documento
										[1] Numero do documento
										[2] Tipo de Documento
										[3] Valor do Documento
										[4] Codigo do Aprovador
										[5] Codigo do Usuario
										[6] Grupo do Aprovador
										[7] Aprovador Superior
										[8] Moeda do Documento
										[9] Taxa da Moeda
										[10] Data de Emissao do Documento
										[11] Observacao
										[12] Aprovador Original
								ExpD1 = Data de referencia para o saldo
								ExpN1 = Operacao a ser executada
										1 = Inclusao do documento
										2 = Transferencia para Superior
										3 = Exclusao do documento
										4 = Aprovacao do documento
										5 = Estorno da Aprovacao
										6 = Bloqueio Manual da Aprovacao
								ExpC1 = Chave(Alternativa) do SF1 para exclusao SCR
								ExpL1 = Eliminacao de Residuos
			*/
			if cOpcao == "APROVAR"
				lLiberou := MaAlcDoc({	SCR->CR_NUM			/*[1] Numero do documento*/,;
										SCR->CR_TIPO		/*[2] Tipo de Documento*/,;
										SCR->CR_TOTAL		/*[3] Valor do Documento*/,;
										SCR->CR_APROV		/*[4] Codigo do Aprovador*/,;
										SCR->CR_USER		/*[5] Codigo do Usuario*/,;
										SCR->CR_GRUPO		/*[6] SC7->C7_APROV Grupo do Aprovador*/,;
												/*SCR->CR_APROV [7] Aprovador Superior*/,;
										SC7->C7_MOEDA		/*[8] Moeda do Documento*/,;
										SC7->C7_TXMOEDA		/*[9] Taxa da Moeda*/,;
										SC7->C7_EMISSAO		/*[10] Data de Emissao do Documento*/,;
										cObs				/*[11] Observação*/,;
															/*[12] Aprovador Original*/},;
										Date(), 4)

			else

				SAK->(dbSetOrder(2))
				SAK->(dbSeek(xFilial("SAK") + SCR->CR_USER))
				lLiberou := OpUMaAlcDoc({	SCR->CR_NUM, SCR->CR_TIPO,, SCR->CR_APROV,, SCR->CR_GRUPO,,,, Date(), cObs},;
											Date(),;
											7,;
											xFilial("SC7") + Left(SCR->CR_NUM, Len(SC7->C7_NUM)))

			endif

			//—————————————————————————————————————————————————————————————————————————————
			// Bloco para corrigir desbloqueio indevido no próximo nível, enquanto o nível
			// atual não for totalmente respondido
			//—————————————————————————————————————————————————————————————————————————————
			lBlqProxNivel := .F.
			SCR->(dbSeek(xFilial("SCR") + cTipo + PadR(cNumPC, Len(SCR->CR_NUM)) + cNivel))
			do while SCR->(!eof() .and. CR_FILIAL + CR_TIPO + CR_NUM  == xFilial("SCR") + cTipo + PadR(cNumPC, Len(SCR->CR_NUM)) .and. CR_NIVEL == cNivel)
				if SCR->CR_STATUS == "02"
					lBlqProxNivel := .T.
				endif
				SCR->(dbSkip())
			enddo
			if lBlqProxNivel
				do while SCR->(!eof() .and. CR_FILIAL + CR_TIPO + CR_NUM  == xFilial("SCR") + cTipo + PadR(cNumPC, Len(SCR->CR_NUM)) .and. CR_NIVEL > cNivel)
					if SCR->CR_STATUS == "02"
						SCR->(RecLock("SCR",.F.))
						SCR->CR_STATUS := "01"
						SCR->(MsUnLock())
					endif
					SCR->(dbSkip())
				enddo
			endif
			// Fim
	
			if cOpcao == "APROVAR"
				
				if Select("TSCR") > 0
					TSCR->(dbCloseArea())
				endif

				// verifica se o pedido foi totalmente liberado
				cQuery := "SELECT COUNT(*) CONTADOR FROM " + RetSqlName("SCR") + " " +;
							 "WHERE D_E_L_E_T_ = ' ' AND CR_FILIAL = '" + xFilial("SCR") + "' AND CR_NUM = '" + cNumPC + "' AND CR_STATUS NOT IN ('03','05') AND CR_TIPO = 'PC'"
		
				dbUseArea(.T., "TOPCONN", TCGenQry(,, cQuery), "TSCR", .T., .T.)
		
				nContador	:= TSCR->CONTADOR

				if Select("TSCR") > 0
					TSCR->(dbCloseArea())
				endif
				
				if nContador > 0

					A15_BRAJOB()	// envia e-mail para o proximo aprovador
					
				else

					//—————————————————————————————————————————————————————————————————————————————
					// Para pedidos aprovados, enviar comunicado também para a controladoria 
					//—————————————————————————————————————————————————————————————————————————————
					SC7->(dbSeek(xFilial("SC7") + cNumPC))
					if SC7->C7_XCATEG == "DP" .and. !Empty(cEmlContr)
						cDestinat += "; " + cEmlContr
					endif

					cAssunto	:= "Pedido de Compra nr. " + cNumPC + " APROVADO"
					cCorpo	    := A15MontaEmail(.T., cTipo, cNumPC, cNomeSol)
		
					do while SC7->(!eof() .and. C7_FILIAL == xFilial("SC7") .and. C7_NUM == cNumPC)
						SC7->(RecLock("SC7", .F.))
						SC7->C7_CONAPRO	:= "L"
						SC7->(MsUnlock())
						SC7->(dbSkip())
					endDo

					//—————————————————————————————————————————————————————————————————————————————
					//—————————————————————————————————————————————————————————————————————————————
					// Criação automática de documentos de entrada a partir da aprovação do PC
					//—————————————————————————————————————————————————————————————————————————————
					//—————————————————————————————————————————————————————————————————————————————
					//CONOUT("Categoria " + cCategoria + "  - U_JOB15FRETE - cEmpAnt " + cEmpAnt + " - cFilAnt " +  cFilAnt + " - " + cNumPC)
					//Reembolso de consumidor final
					if cCategoria == "DP" .and. lConsumidor		//despesas
						StartJob("U_JOB15DESP", "SCHEDULE", .F., cEmpAnt, cFilAnt, cNumPC, cDestinat)

					//Fatura conhecimento de frete
					elseif cCategoria == "LG"
						StartJob("U_JOB15FRETE", "SCHEDULE", .F., cEmpAnt, cFilAnt, cNumPC)

					endif

				endif	
				
			else
		
				cAssunto	:= "Pedido de Compra nr. " + cNumPC + " REPROVADO"
				cCorpo	    := A15MontaEmail(.F., cTipo, cNumPC, cNomeSol)
			
			endif
			
		endif

	else

		cFornecedor	:= GetAdvFVal("SA2", "A2_NOME", xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA, 1, "")
		cDestinat 	:= Alltrim(UsrRetMail(iif(!Empty(SCR->CR_XRESP), SCR->CR_XRESP, SCR->CR_USER)))
		cAssunto	:= "Aviso sobre link inativo referente ao pedido de compras " + SC7->C7_NUM
		cCorpo		:= '<html><body>' +;
						'<font size="3" face="Calibri">Prezado(a)' + AllTrim(UsrFullName(iif(!Empty(SCR->CR_XRESP), SCR->CR_XRESP, SCR->CR_USER))) + ',</font><br><br>' +;
						'<font size="3" face="Calibri">O link respondido, referente ao pedido de compra descrito abaixo, está cancelado em razão ou da alteração ou exclusão do mesmo. Aguarde novo envio de e-mail para aprovação ou entre em contato com o comprador para esclarecimentos.</font><br><br><br>' +;
						'<font size="3" face="Calibri">Pedido de Compras ' + SC7->C7_NUM + '  -  ' + cFornecedor + '</font><br><br><br>' +;
						'<font size="1" face="Calibri"><i>E-mail automático enviado pelo processo de workflow, Favor não respondê-lo.</i></font><br><br>' +;
						'</body></html>'

	endif
	
else

	cDestinat	:= "equipe.ti@gamaitaly.com.br"
	cAssunto	:= "Problema de alçada no Pedido de Compra nr. " + cNumPC + ". Contate o departamento de TI"
	cCorpo		:= "Encontrado problema no controle de alçadas Pedido de Compra nr. " + cNumPC + ". Informe o departamente de TI."

endif

//—————————————————————————————————————————————————————————————————————————————
// Envio de e-Mail com o resultado da operação
//—————————————————————————————————————————————————————————————————————————————
if cCorpo <> Nil
	
	if !empty(DESTINATHOMOLOG)
		cAssunto	:= "HOMOLOGAÇÃO " + cAssunto + " / " + cDestinat
		cDestinat	:= DESTINATHOMOLOG
	endif

	if !Empty(cDirApoio)
		U_GISendMail(cDestinat,, "HOMOLOGAÇÃO " + cAssunto, cCorpo, cDirApoio)		//mudar aqui retirar HOMOLOGAÇÃO
	else
		U_GISendMail(cDestinat,, cAssunto, cCorpo)
	endif

endif

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		A15MontaEmail                                                /@
@type			Static function                                              /@
@date			13/02/2017                                                   /@
@description	Monta o corpo de e-mail para comunicação com o comprador.    /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function A15MontaEmail(lAprov, cTipo, cNumPC, cNomeSol)
Local aArea			:= GetArea()
Local aAreaSCR		:= SCR->(GetArea())
Local aAprov		:= {}
Local cLinkLogo		:= AllTrim(GetMV("BR_LNKLOGO", .F., "https://sweb.gamaitaly.com.br/images/LogoGamaPeq.jpg"))
Local cAmbiente		:= Lower(GetEnvServer())
Local cObsGer		:= AllTrim(SC7->C7_X_OBSGE)
Local nTotal		:= 0
Local cMsg, nX, cTexto, cFormPag

SC7->(dbSeek(xFilial("SC7") + cNumPC))
SE4->(dbSeek(xFilial("SE4") + SC7->C7_COND))
SA2->(dbSeek(xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA))

if Empty(cNomeSol)
	cNomeSol := AllTrim(UsrFullName(SC7->C7_USER))
endif

if SC7->C7_XCATEG == "RH"
	cTexto	:= "Despesa RH"
elseif SC7->C7_XCATEG == "DP"
	if !Empty(SC7->C7_XCONSUM)
		cTexto	:= "Reembolso de Consumidor Final"
		cIdCli	:= iif(Len(AllTrim(SC7->C7_XCPF)) > 11,;
						", CNPJ: " + Transform(SC7->C7_XCPF, "@R 99.999.999/9999-99"),;
						", CPF: " + Transform(SC7->C7_XCPF, "@R 999.999.999-99"))
		cObsGer += iif(!Empty(cObsGer), "<br><br>", "") + "Reembolso consumidor final para " + AllTrim(SC7->C7_XCONSUM) +;
						cIdCli +;
						"<br> Banco " + AllTrim(SC7->C7_XBANCO) +;
						", Agência " + AllTrim(SC7->C7_XAGENC) + iif(!Empty(SC7->C7_XDVAGE), "-" + AllTrim(SC7->C7_XDVAGE), "") +;
						", Conta " + AllTrim(SC7->C7_XCONTA) + iif(!Empty(SC7->C7_XDVCTA), "-" + AllTrim(SC7->C7_XDVCTA), "")
	else
		cTexto	:= "Despesa Financeira"
	endif
else
	cTexto	:= "Pedido de Compras"
endif

cCondicao	    := SC7->C7_COND + " - " + AllTrim(SE4->E4_DESCRI)
cFornecedor	    := SA2->A2_NOME + "  (" + SC7->C7_FORNECE + "/" + SC7->C7_LOJA + ")"
cCNPJ			:= Transform(SA2->A2_CGC, "@R 99.999.999/9999-99")
cFormPag		:= iif(SC7->C7_X_FORPG == "1", "Boleto",;
						iif(SC7->C7_X_FORPG == "2", "Depósito em conta",;
						iif(SC7->C7_X_FORPG == "3", "Dinheiro",;
						iif(SC7->C7_X_FORPG == "4", "Cheque",;
						"Não identificada"))))


//———————————————————————————————————————————————————————————————————————————————
// Busca as ocorrencias por aprovador
//———————————————————————————————————————————————————————————————————————————————
SCR->(dbSetOrder(1))		//CR_FILIAL, CR_TIPO, CR_NUM, CR_NIVEL
SCR->(dbSeek(xFilial("SCR") + cTipo + PadR(cNumPC, Len(CR_NUM))))
do while SCR->(!eof() .and. CR_FILIAL == xFilial("SCR") .and. CR_NUM == PadR(cNumPC, Len(CR_NUM)))
	nTotal	:= SCR->CR_TOTAL
	aAdd(aAprov, {AllTrim(UsrFullName(iif(!Empty(SCR->CR_XRESPUS), SCR->CR_XRESPUS, SCR->CR_USER))),;
				  AllTrim(UsrRetMail(iif(!Empty(SCR->CR_XRESPUS), SCR->CR_XRESPUS, SCR->CR_USER))),;
				  AllTrim(SCR->CR_OBS),;
				  AllTrim(UsrFullName(SCR->CR_USER)),;
				  AllTrim(UsrRetMail(SCR->CR_USER))})
	SCR->(dbSkip())
enddo

//———————————————————————————————————————————————————————————————————————————————
// Cria texto no formato HTML para envio do e-mail
//———————————————————————————————————————————————————————————————————————————————
cMsg := '<html>'
cMsg += '<head>'
cMsg += '<style type="text/css">'
cMsg += '.baseboard {'
cMsg += '	color: #000000;'
cMsg += '	font-family: Arial, Helvetica, sans-serif;'
cMsg += '	font-style: italic;'
cMsg += '	font-size: 8.5pt'
cMsg += '}'
cMsg += '.header-fields {'
cMsg += '	font-size: x-small;'
cMsg += '	font-family: Arial, Helvetica, sans-serif;'
cMsg += '	background-color: #D6D6D6;'
cMsg += '}'
cMsg += '.detail-fields {'
cMsg += '	font-size: x-small;'
cMsg += '	font-family: Arial, Helvetica, sans-serif;'
cMsg += '}'
cMsg += '.highlight-detail {'
cMsg += '	font-size: small;'
cMsg += '	font-family: Arial, Helvetica, sans-serif;'
cMsg += '	color: #000080;'
cMsg += '}'
cMsg += '.status-reprovado {'
cMsg += '	margin-bottom: 5px;'
cMsg += '	color: #7B0E00;'
cMsg += '	font-family: Arial, Helvetica, sans-serif;'
cMsg += '	font-size: large;'
cMsg += '}'
cMsg += '.status-aprovado {'
cMsg += '	margin-bottom: 5px;'
cMsg += '	color: #127B00;'
cMsg += '	font-family: Arial, Helvetica, sans-serif;'
cMsg += '	font-size: large;'
cMsg += '}'
cMsg += '</style>'
cMsg += '</head>'

cMsg += '<body>'
cMsg += '<table border="0" width="100%"><tr>'
cMsg += '	<td style="font-size: 6pt; color: #D6D6D6; height: 38; width: 11%;"><img src=' + cLinkLogo + '></td>'
cMsg += '</tr></table>'

if lAprov
	cMsg += '	<p class="status-aprovado"><strong>APROVADO</strong></p>'
else
	cMsg += '	<p class="status-reprovado"><strong>REPROVADO</strong></p>'
endif

cMsg += '	<br>'
cMsg += '	<table style="width: 100%">'
cMsg += '		<tr>'
cMsg += '			<td class="header-fields" style="width: 20%">Número ' + cTexto + '</td>'
cMsg += '			<td class="header-fields" style="width: 15%">Emissão</td>'
cMsg += '			<td class="header-fields" style="width: 40%">Solicitante</td>'
cMsg += '			<td class="header-fields" style="width: 25%">Filial</td>'
cMsg += '		</tr>'

cMsg += '		<tr>'
cMsg += '			<td class="highlight-detail" style="height: 30px; width: 20%"><strong>' + SC7->C7_NUM + '</strong></td>'
cMsg += '			<td class="detail-fields" style="height: 30px; width: 15%"><strong>' + dTOc(SC7->C7_EMISSAO) +'</strong></td>'
cMsg += '			<td class="detail-fields" style="height: 30px; width: 40%"><strong>' + cNomeSol + '</strong></td>'
cMsg += '			<td class="detail-fields" style="height: 30px; width: 25%"><strong>' + SM0->M0_CODFIL+ " - " + SM0->M0_FILIAL + '</strong></td>'
cMsg += '		</tr>'

cMsg += '	</table>'
cMsg += '	<table style="width: 100%">'
cMsg += '		<tr>'
cMsg += '			<td class="header-fields" style="width: 45%">Forma de Pagamento</td>'
cMsg += '			<td class="header-fields" style="width: 55%">Condição de pagamento</td>'
cMsg += '		</tr>'
cMsg += '		<tr>'
cMsg += '			<td class="detail-fields" style="width: 45%"><strong>' + cFormPag + '</strong></td>'
cMsg += '			<td class="detail-fields" style="width: 55%"><strong>' + cCondicao +'</strong></td>'
cMsg += '		</tr>'
cMsg += '	</table>'
cMsg += '	<table style="width: 100%">'
cMsg += '		<tr>'
cMsg += '			<td class="header-fields" style="width: 70%">Fornecedor</td>'
cMsg += '			<td class="header-fields" style="width: 30%">CNPJ</td>'
cMsg += '		</tr>'
cMsg += '		<tr>'
cMsg += '			<td class="detail-fields" style="width: 70%"><strong>' + cFornecedor + '</strong></td>'
cMsg += '			<td class="detail-fields" style="width: 30%"><strong>' + cCNPJ + '</strong></td>'
cMsg += '		</tr>'
cMsg += '		</table>'
cMsg += '	<table style="width: 100%">'
cMsg += '		<tr>'
cMsg += '			<td class="header-fields">Observação</td>'
cMsg += '		</tr>'
cMsg += '		<tr>'
cMsg += '			<td class="detail-fields"><strong>' + cObsGer +'</strong></td>'
cMsg += '		</tr>'
cMsg += '	</table>'
cMsg += '	<table style="width: 50%">'
cMsg += '		<tr>'
cMsg += '			<td class="header-fields">Total</td>'
cMsg += '		</tr>'
cMsg += '		<tr>'
cMsg += '			<td class="highlight-detail" style="height: 30px; width: 50%"><strong>' + Transf(nTotal, "@E 999,999,999.99") + '</strong></td>'
cMsg += '		</tr>'
cMsg += '	</table>'
cMsg += '	<br>'
cMsg += '	<br>'
cMsg += '	<table style="width: 100%">'
cMsg += '		<tr>'
cMsg += '			<td class="header-fields" style="width: 25%">Aprovador</td>'
cMsg += '			<td class="header-fields" style="width: 75%">Observação</td>'
cMsg += '		</tr>'

for nX := 1 to Len(aAprov)
	cMsg += '		<tr>'
	cMsg += '			<td class="detail-fields" style="width: 25%;height: 30px">' + aAprov[nX,1] + chr(13) + chr(10) + aAprov[nX,2] + '</td>'
	cMsg += '			<td class="detail-fields" style="width: 75%;height: 30px">' + aAprov[nX,3] + '</td>'
	cMsg += '		</tr>'
next

cMsg += '	</table>'
cMsg += '	<p><span class="baseboard"><i>E-mail automático enviado pelo processo de workflow, ambiente ' + cAmbiente + '. Favor não respondê-lo.</i></span></p>'
cMsg += '</body>'
cMsg += '</html>'

RestArea(aAreaSCR)
RestArea(aArea)
Return(cMsg)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		GetLimite                                                    /@
@type			Static function                                              /@
@date			23/11/2020                                                   /@
@description	Retorna informações de limite, saldo e nota explicativa do
				aprovador do processo.                                       /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function GetLimite(lAprovador)
Local aRet			:= {0, 0, ""}
Local aArea			:= GetArea()
Local aAreaSAK		:= SAK->(GetArea())
Local aAreaSAL		:= SAL->(GetArea())
Local aAreaSCR		:= SCR->(GetArea())
Local aAreaSCS		:= SCS->(GetArea())
Local cDocto		:= SCR->CR_NUM
Local cTipo			:= SCR->CR_TIPO
Local nSaldo		:= 0
Local cDtRef		:= Left(dTOs(Date()),6) + "01"
Default lAprovador	:= .F.

//—————————————————————————————————————————————————————————————————————————
// Ordenando tabelas
//—————————————————————————————————————————————————————————————————————————
SAK->(dbSetOrder(1))	//AK_FILIAL, AK_COD
SAL->(dbSetOrder(3))	//AL_FILIAL, AL_COD, AL_APROV
SCR->(dbSetOrder(1))	//CR_FILIAL, CR_TIPO, CR_NUM, CR_NIVEL
SCS->(dbSetOrder(2))    //CS_FILIAL, CS_APROV, CS_DATA

//—————————————————————————————————————————————————————————————————————————
// Leitura dos registros de alçada
//—————————————————————————————————————————————————————————————————————————
SCR->(dbSeek(xFilial("SCR") + cTipo + cDocto))
do while SCR->(!eof() .and. CR_TIPO == cTipo .and. CR_NUM == cDocto)

	//—————————————————————————————————————————————————————————————————————————
	// Identificando o aprovador
	//—————————————————————————————————————————————————————————————————————————
	if SAL->(dbSeek(xFilial("SAL") + SCR->CR_GRUPO + SCR->CR_APROV)) .and.;
		SAL->AL_LIBAPR == "A" .and.;
		SAK->(dbSeek(xFilial("SAK") + SAL->AL_APROV))

		//—————————————————————————————————————————————————————————————————————————
		// Busca limite do aprovador e analisa o saldo
		//—————————————————————————————————————————————————————————————————————————
		aRet[1]		:= SAK->AK_LIMITE
		
	    if SCS->(dbSeek(xFilial("SCS") + SAL->AL_APROV + cDtRef)) .and. SCS->CS_APROV == SAL->AL_APROV
			aRet[2]	:= SCS->CS_SALDO
			nSaldo	:= SCS->CS_SALDO - iif(lAprovador, SCR->CR_TOTAL, 0)	//CONTRARIO
    	endif

		if nSaldo <= Round(SAK->AK_LIMITE * 0.05, 2)
			aRet[3]		:= iif(SAK->AK_XIDIOMA == "1",;
								AllTrim(SAK->AK_NOME) + iif(lAprovador, " atingirá", " atingiu") + " 95% de seu limite",;
								AllTrim(SAK->AK_NOME) + iif(lAprovador, " atingirá", " alcanzó") + " el 95% de su límite")

		elseif nSaldo <= Round(SAK->AK_LIMITE * 0.1, 2)
			aRet[3]		:= iif(SAK->AK_XIDIOMA == "1",;
								AllTrim(SAK->AK_NOME) + iif(lAprovador, " atingirá", " atingiu") + " 90% de seu limite",;
								AllTrim(SAK->AK_NOME) + iif(lAprovador, " atingirá", " alcanzó") + " el 90% de su límite")
		endif
		exit
	endif

	SCR->(dbSkip())
enddo

//—————————————————————————————————————————————————————————————————————————
// Restaura posição original
//—————————————————————————————————————————————————————————————————————————
RestArea(aAreaSAK)
RestArea(aAreaSAL)
RestArea(aAreaSCR)
RestArea(aAreaSCS)
RestArea(aArea)

Return(aRet)

/*/
———————————————————————————————————————————————————————————————————————————————
@function		OpUMaAlcDoc                                                  /@
@type			Static function                                              /@
@date			17/05/2021                                                   /@
@description	Controla a alcada dos documentos (SCS-Saldos/SCR-Bloqueios),
				desenvolvido com base no MaAlcDoc, usa somente a rejeição
				de pedidos de compras.                                       /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function OpUMaAlcDoc(aDocto,dDataRef,nOper,cChaveRej)
Local lRetorno		:= .T.
Local aArea			:= GetArea()
Local aAreaSCS		:= SCS->(GetArea())
Local aAreaSCR		:= SCR->(GetArea())
Local cDocto		:= aDocto[1]
Local cTipoDoc		:= aDocto[2]
Local cCodAprov		:= If(aDocto[4]==Nil, "", aDocto[4])
Local cUsuario		:= If(aDocto[5]==Nil, "", aDocto[5])
Local nMoeDcto		:= If(Len(aDocto)>7, If(aDocto[8]==Nil, 1, aDocto[8]), 1)
Local nTxMoeda		:= If(Len(aDocto)>8, If(aDocto[9]==Nil, 0, aDocto[9]), 0)
Local cObs      	:= If(Len(aDocto)>10, If(aDocto[11]==Nil, "", aDocto[11]), "")
Local cGrupo		:= If(aDocto[6]==Nil, "", aDocto[6])
Local cAuxNivel		:= ""
Local cAprovOri 	:= ""
Local cUserOri  	:= ""
Local cFilSCR		:= IIf(cTipoDoc $ 'IC|CT|IR|RV',CnFilCtr(cDocto),xFilial("SCR"))
Local cDocSF1 		:= cDocto
Local lResiduo 		:= .F.
Local cItGrp		:= ""

cDocto 	:= cDocto + Space(Len(SCR->CR_NUM) - Len(cDocto))
cDocSF1	:= cDocSF1 + Space(Len(SCR->CR_NUM) - Len(cDocSF1))

//———————————————————————————————————————————————————————————————————————————————
// Mantendo compatibilidade com MaAlcDoc
// Chamada ponto de entrada MT097GRV
//———————————————————————————————————————————————————————————————————————————————
If ExistBlock("MT097GRV")
	lRetorno := (Execblock("MT097GRV",.F.,.F.,{aDocto,dDataRef,nOper,cDocSF1,lResiduo}))
	If Valtype( lRetorno ) <> "L"
		lRetorno := .T.
	EndIf
Endif

If lRetorno

	If Empty(cUsuario) .And. (nOper != 1 .And. nOper != 6) //nao e inclusao ou estorno de liberacao
		dbSelectArea("SAK")
		SAK->(dbSetOrder(1))
		SAK->(MsSeek(xFilial("SAK") + cCodAprov))
		cUsuario :=	AK_USER
		SAL->(DbSetOrder(1))
		If SAL->(DbSeek(xFilial("SAL")+cGrupo+cUsuario))
			DHL->(DbSetOrder(1))
			If DHL->(DbSeek(xFilial("DHL") + SAL->AL_PERFIL))
				nMoeDcto := DHL->DHL_MOEDA
			Else
				nMoeDcto :=	AK_MOEDA
			Endif
		Else
			nMoeDcto :=	AK_MOEDA
		EndIf
		nTxMoeda	:=	0
	EndIf
	
	//———————————————————————————————————————————————————————————————————————————————
	// Controle da rejeição do documento
	//———————————————————————————————————————————————————————————————————————————————
	If nOper == 7  //Evento de rejeição do documento
		cAuxNivel	:= SCR->CR_NIVEL
		cAprovOri	:= SCR->CR_APROV
		cUserOri	:= SCR->CR_USER

		//———————————————————————————————————————————————————————————————————————————————
		// Rejeita aprovacoes pendentes do mesmo nivel e niveis superiores, grupo e item
		//———————————————————————————————————————————————————————————————————————————————
		SCR->(dbSetOrder(1))
		SCR->(dbSeek(cFilSCR + cTipoDoc+cDocto))
		While !SCR->(EOF()) .And. SCR->(CR_FILIAL + CR_TIPO + CR_NUM) == cFilSCR + cTipoDoc + cDocto
			If SCR->CR_NIVEL >= cAuxNivel	.And. SCR->CR_STATUS <> "03"
				RecLock("SCR",.F.)
				SCR->CR_DATALIB := dDataBase
				SCR->CR_USERLIB := cUserOri
				SCR->CR_LIBAPRO := cAprovOri
				
				If SCR->CR_APROV == cAprovOri
					SCR->CR_STATUS := "06"
				Else
					SCR->CR_STATUS := "05"
				EndIf
				if SCR->CR_APROV == cCodAprov
					SCR->CR_OBS := cObs
				endif
				SCR->(MsUnLock())
			EndIf
			
			If cTipoDoc $ "PC|ST"
				Do Case
					Case SCR->CR_TIPO == "ST"
						NNS->(dbSetOrder(1))
						If NNS->(MsSeek(cChaveRej))
							RecLock("NNS",.F.)
							NNS->NNS_STATUS := '4'
							NNS->NNS_JUSTIF := cObs		//FwFldGet("CR_OBS")
							NNS->(MsUnlock())
						EndIf
					Case SCR->CR_TIPO == "PC"
						SC7->(dbSetOrder(1))
						SC7->(MsSeek(cChaveRej))
						While !SC7->(EOF()) .And. SC7->(C7_FILIAL+C7_NUM) == cChaveRej
							RecLock("SC7",.F.)
							SC7->C7_CONAPRO := 'R'
							SC7->C7_FLUXO	:= 'N'
							SC7->(MsUnlock())

							SC7->(dbSkip())
						EndDo
				EndCase
			ElseIf cTipoDoc >= "A1" .AND. cTipoDoc <= "A9"
				If FindFunction("OGXUtlOrig") //Identifica que esta utilizando o sigaagr
					If OGXUtlOrig() .and.FindFunction("OGX701AALC")	
						If !AGRXCOM8(SCR->CR_NUM, cTipoDoc, SCR->(RECNO()) )
							DisarmTransaction()
							lRetorno := .F.
						EndIf
					EndIF
				Endif
			Elseif !cTipoDoc $ "CT|IC|RV|IR|MD|IM|PC|ST"
				MaAlcItEC(SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_GRUPO,SCR->CR_ITGRP,SCR->CR_USER,,SCR->CR_USERORI,nOper,SCR->CR_APROV)
			EndIf

			If !Empty(SCR->CR_FLUIG) .And. (SCR->CR_STATUS == "05" .Or. SCR->CR_STATUS == "06")
				CancelProcess(Val(SCR->CR_FLUIG),FWWFUserID(Val(SCR->CR_FLUIG))," cancelado por contingência!",.F.)
			EndIf

			SCR->(dbSkip())
		Enddo
		
		Do Case
			Case SCR->CR_TIPO == "ST"
				NNS->(dbSetOrder(1))
				If NNS->(MsSeek(cChaveRej))
					RecLock("NNS",.F.)
					NNS->NNS_STATUS := '4'
					NNS->NNS_JUSTIF := cObs
					NNS->(MsUnlock())
				EndIf
			Case SCR->CR_TIPO == "PC"
				SC7->(dbSetOrder(1))
				SC7->(MsSeek(cChaveRej))
				While !SC7->(EOF()) .And. SC7->(C7_FILIAL+C7_NUM) == cChaveRej
					RecLock("SC7",.F.)
					SC7->C7_CONAPRO := 'R'
					SC7->C7_FLUXO	:= 'N'
					SC7->(MsUnlock())
					SC7->(dbSkip())
				EndDo
		EndCase

	EndIf
	
	//———————————————————————————————————————————————————————————————————————————————
	// Mantendo compatibilidade com MaAlcDoc
	// Chamada ponto de entrada MTALCDOC
	//———————————————————————————————————————————————————————————————————————————————
	If ExistBlock("MTALCDOC")
		Execblock("MTALCDOC",.F.,.F.,{aDocto,dDataRef,nOper,cItGrp})
	EndIf	 

EndIf

//———————————————————————————————————————————————————————————————————————————————
// Mantendo compatibilidade com MaAlcDoc
// Chamada ponto de entrada MTALCFIM
//———————————————————————————————————————————————————————————————————————————————
If ExistBlock("MTALCFIM")
	lCalculo := Execblock("MTALCFIM",.F.,.F.,{aDocto,dDataRef,nOper,cDocSF1,lResiduo})
	If Valtype( lCalculo ) == "L"
		lRetorno := lCalculo
	EndIf
Endif

RestArea(aAreaSCR)
RestArea(aAreaSCS)
RestArea(aArea)

Return(lRetorno)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		JOB15DESP                                                    /@
@type			User function                                                /@
@date			09/08/2021                                                   /@
@description	Job para inclusão automática de documentos de entrada, 
                partir da aprovação de um pedido de compras / despesa 
                financeira.                                                  /@
@parameters     cEmp    - Codigo da empresa
                cFil    - Codigo da filial
                cNumPC  - Numero do pedido de compras (SC7)
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Tecnologia da Informação                            /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function JOB15DESP(cEmp, cFil, cNumPC, cDestinat)
Local aFiles			:= {"SA2", "SB1", "SC1","SC7", "SCR","SD1", "SF1", "SE4", "SED"}
Local cAssunto			:= ""
Local cObservacao		:= ""
Local cPreAssunt		:= ""
Local aTitulo			:= {}
Local aCabNF, aIteNF, nItem, nK, cDoc, cSerie, cEst, cEspecie, cFornecedor, cLoja, cBody
Private lMsErroAuto 	:= .F.
Private lMsHelpAuto 	:= .F.
Private nModulo 		:= 2 

//———————————————————————————————————————————————————————————————————————————————
// NÃO SCHEDULAR A ROTINA NO CONFIGURADOR
// Verificando se recebeu parametros obrigatórios para a execução da rotina
//———————————————————————————————————————————————————————————————————————————————
if cEmp != Nil .and. cFil != Nil .and. cNumPC != Nil

    //———————————————————————————————————————————————————————————————————————————————
    // Abertura do ambiente
    //———————————————————————————————————————————————————————————————————————————————
    WfPrepEnv(cEmp, cFil, "U_JOB15DESP",, "COM")
        
    for nK := 1 to Len(aFiles)
        if Empty(Select(aFiles[nK]))
            ChkFile(aFiles[nK])
        endif
    next

    //———————————————————————————————————————————————————————————————————————————————
    // Definindo os indices de pesquisa
    //———————————————————————————————————————————————————————————————————————————————
    SA2->(dbSetOrder(1))    //A2_FILIAL, A2_COD, A2_LOJA
    SB1->(dbSetOrder(1))    //B1_FILIAL, B1_COD
    SC7->(dbSetOrder(1))    //C7_FILIAL, C7_NUM, C7_ITEM, C7_SEQUEN
    SF1->(dbSetOrder(1))    //F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO

    //———————————————————————————————————————————————————————————————————————————————
    // Iniciando processo
    //———————————————————————————————————————————————————————————————————————————————
    if SC7->(dbSeek(xFilial("SC7") + cNumPC))

        if SA2->(dbSeek(xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA))

            aIteNF 		:= {}
            nItem		:= 0
            cFornecedor := SC7->C7_FORNECE
            cLoja       := SC7->C7_LOJA

			cSerie		:= "DES"
			cDoc        := PadR(cNumPC,9)
			cEst        := SM0->M0_ESTENT
			cEspecie    := "REC"
			cObservacao	:= "Reembolso consumidor final para " + AllTrim(SC7->C7_XCONSUM) +;
							iif(Len(AllTrim(SC7->C7_XCPF)) > 11, ", CNPJ: " + Transform(SC7->C7_XCPF, "@R 99.999.999/9999-99"), ", CPF: " + Transform(SC7->C7_XCPF, "@R 999.999.999-99")) +;
							"<br> Banco " + AllTrim(SC7->C7_XBANCO) +;
							", Agência " + AllTrim(SC7->C7_XAGENC) + iif(!Empty(SC7->C7_XDVAGE), "-" + AllTrim(SC7->C7_XDVAGE), "") +;
							", Conta " + AllTrim(SC7->C7_XCONTA) + iif(!Empty(SC7->C7_XDVCTA), "-" + AllTrim(SC7->C7_XDVCTA), "")

            if SF1->(!dbSeek(xFilial("SF1") + cDoc + cSerie + cFornecedor + cLoja))
                
                aCabNF := {	{"F1_TIPO",		"N",					Nil},;
                            {"F1_FORMUL",	"N",					Nil},;
                            {"F1_DOC",		PadR(cNumPC,9),			Nil},;
                            {"F1_SERIE",	cSerie,					Nil},;
                            {"F1_EMISSAO",	Date(),					Nil},;
                            {"F1_FORNECE",	cFornecedor,    		Nil},;
                            {"F1_LOJA",		cLoja,      			Nil},;
                            {"F1_COND",		SC7->C7_COND,			Nil},;
                            {"F1_EST",		cEst,					Nil},;
                            {"F1_ESPECIE",	cEspecie,				Nil}}

                do while SC7->(!eof() .and. C7_FILIAL + C7_NUM == xFilial("SC7") + cNumPC)
                    if SB1->(dbSeek(xFilial("SB1") + SC7->C7_PRODUTO))
                        nQtdItem	:= SC7->C7_QUANT - SC7->C7_QUJE

                        aAdd(aIteNF, {	{"D1_ITEM", 	StrZero(++nItem,4),					Nil},;
                                        {"D1_COD",		SC7->C7_PRODUTO,					Nil},;
                                        {"D1_LOCAL",	SC7->C7_LOCAL,						Nil},;
                                        {"D1_QUANT",	nQtdItem,							Nil},;
                                        {"D1_VUNIT",	SC7->C7_PRECO, 						Nil},;
                                        {"D1_TOTAL",	Round(nQtdItem * SC7->C7_PRECO,2),	Nil},;
                                        {"D1_TES",		SC7->C7_TES,						Nil},;
                                        {"D1_CC",		SC7->C7_CC,							Nil},;
                                        {"D1_PEDIDO", 	SC7->C7_NUM,						Nil},;
                                        {"D1_ITEMPC", 	SC7->C7_ITEM,						Nil}})			

                    endif

                    SC7->(dbSkip())
                enddo
            
                if Len(aIteNF) > 0
					dbSelectArea("SF1")
                    MsExecAuto({|x, y, z| MATA103(x, y, z)}, aCabNF, aIteNF, 3)

                    if lMsErroAuto

                        cObservacao	:= MemoRead(NomeAutoLog())
						cBody		:= BodyDocEntr( .F.,;
													cNumPC,;
													Nil,;
													aTitulo,;
													cObservacao)
                        cAssunto 	:= "Documento de entrada não incluido - error.log no processo msexecauto . Pedido de compras " + cNumPC

                    else

						aTitulo := {}
						SE2->(dbSetOrder(6))	//E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO
						SE2->(dbSeek(xFilial("SE2") + SF1->(F1_FORNECE + F1_LOJA + F1_PREFIXO + F1_DOC)))
						do while SE2->(!eof() .and. E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM == xFilial("SE2") + SF1->(F1_FORNECE + F1_LOJA + F1_PREFIXO + F1_DOC))
							aAdd(aTitulo, {SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_VENCREA, SE2->E2_VALOR})
							SE2->(dbSkip())
						enddo

                        cAssunto := "Documento de entrada incluido COM SUCESSO - Pedido de compras " + cNumPC
						cBody	:= BodyDocEntr( .T.,;
												cNumPC,;
												{SF1->F1_DOC, SF1->F1_SERIE, dTOc(SF1->F1_EMISSAO), SF1->F1_FORNECE, SF1->F1_LOJA, SA2->A2_NOME, SF1->F1_VALBRUT},;
												aTitulo,;
												cObservacao)

                    endif
                
                else

                    cAssunto 	:= "Documento de entrada não incluido - Não encontrado itens no Pedido de Compras"
                	cBody		:= BodyDocEntr(	.F.,;
												cNumPC,;
												Nil,;
												aTitulo,;
												cAssunto)


                endif

            else

                cAssunto 	:= "Documento de entrada não incluido - Documento já cadastrado"
               	cBody		:= BodyDocEntr(	.F.,;
											cNumPC,;
											Nil,;
											aTitulo,;
											cAssunto)


            endif
        
        else

            cAssunto 	:= "Documento de entrada não incluido - Fornecedor não encontrado"
        	cBody		:= BodyDocEntr(	.F.,;
										cNumPC,;
										Nil,;
										aTitulo,;
										cAssunto)

        endif

    else

        cAssunto	:= "Documento de entrada não incluido - Pedido não encontrado"
       	cBody		:= BodyDocEntr(	.F.,;
									cNumPC,;
									Nil,;
									aTitulo,;
									cAssunto)

    endif

    if !Empty(cBody)

		if !Empty(DESTINATHOMOLOG)
			cDestinat		:= DESTINATHOMOLOG	// Informe o endereço eletrônico do destinatário.
			cPreAssunt		:= "HOMOLOGAÇÃO "
		endif

        //caso a nota venha a ser excluida, por qualquer motivo, a nota deve ser incluida manualmente.
        cErro := U_GISendMail(cDestinat,, cPreAssunt + cAssunto, cBody)		//mudar aqui retirar HOMOLOGAÇÃO
    endif

    //———————————————————————————————————————————————————————————————————————————————
    // Encerramento do ambiente
    //———————————————————————————————————————————————————————————————————————————————
    RpcClearEnv()

    ConOut(dTOc(Date()) + " - " + Time() + " JOB15DESP - Processo de inclusão do documento de entrada (Empresa, Filial, Doc, Serie, Fornecedor e Loja) " + cEmp + "-" + cFil + "-" + AllTrim(cDoc) + "-" + cSerie + "-" + cFornecedor + "-" + cLoja)

endif

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		JOB15FRETE                                                   /@
@type			User function                                                /@
@date			09/08/2021                                                   /@
@description	Job para inclusão automática de documentos de entrada, 
                partir da aprovação de um pedido de compras do processo de
				integração de faturas de frete  (GKO).                       /@
@parameters     cEmp    - Codigo da empresa
                cFil    - Codigo da filial
                cNumPC  - Numero do pedido de compras (SC7)
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Tecnologia da Informação                            /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function JOB15FRETE(cEmp, cFil, cNumPC)
Local aFiles			:= {"SA2", "SB1", "SC1","SC7", "SCR","SD1", "SF1", "SE4", "SED"}
Local cAssunto			:= ""
Local cObservacao		:= ""
Local cPreAssunt		:= ""
Local aTitulo			:= {}
Local cStatus			:= ""
Local aCabNF, aIteNF, nItem, nK, cDoc, cSerie, cEst, cFornecedor, cLoja, cBody, cCond, cDestinat
Private lMsErroAuto 	:= .F.
Private lMsHelpAuto 	:= .F.
Private nModulo 		:= 2 
Public aGI103Dupl		:= {}

//———————————————————————————————————————————————————————————————————————————————
// NÃO SCHEDULAR A ROTINA NO CONFIGURADOR
// Verificando se recebeu parametros obrigatórios para a execução da rotina
//———————————————————————————————————————————————————————————————————————————————
if cEmp != Nil .and. cFil != Nil .and. cNumPC != Nil

    //———————————————————————————————————————————————————————————————————————————————
    // Abertura do ambiente
    //———————————————————————————————————————————————————————————————————————————————
    WfPrepEnv(cEmp, cFil, "U_JOB15FRETE",, "COM")
        
    for nK := 1 to Len(aFiles)
        if Empty(Select(aFiles[nK]))
            ChkFile(aFiles[nK])
        endif
    next

    //———————————————————————————————————————————————————————————————————————————————
    // Definindo os indices de pesquisa
    //———————————————————————————————————————————————————————————————————————————————
    SA2->(dbSetOrder(1))    //A2_FILIAL, A2_COD, A2_LOJA
    SB1->(dbSetOrder(1))    //B1_FILIAL, B1_COD
    SC7->(dbSetOrder(1))    //C7_FILIAL, C7_NUM, C7_ITEM, C7_SEQUEN
    SF1->(dbSetOrder(1))    //F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO
	ZZH->(dbSetOrder(1))	//ZZH_FILIAL, ZZH_CNPJTR, ZZH_FATURA, ZZH_PREFIX, ZZF_CANCEL

	cCond			:= GetMV("BR_GKOCP", .F., " ")
	cDestinat		:= GetMV("BR_GKOMAIL", .F., "equipe.ti@gamaitaly.com.br")

    //———————————————————————————————————————————————————————————————————————————————
    // Iniciando processo
    //———————————————————————————————————————————————————————————————————————————————
    if SC7->(dbSeek(xFilial("SC7") + cNumPC))

        if SA2->(dbSeek(xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA))

            aIteNF 		:= {}
            nItem		:= 0
            cFornecedor := SC7->C7_FORNECE
            cLoja       := SC7->C7_LOJA
            cDoc        := SC7->C7_XGKOFAT
            cSerie		:= SC7->C7_XGKOPRE
            cEst        := SA2->A2_EST
			cCond		:= SC7->C7_COND
			
            if 	ZZH->(dbSeek(xFilial("ZZH") + SA2->A2_CGC + cDoc + cSerie + "   ")) .and.;
				SF1->(!dbSeek(xFilial("SF1") + cDoc + cSerie + cFornecedor + cLoja))
                
                aCabNF := {	{"F1_TIPO",		"N",					Nil},;
                            {"F1_FORMUL",	"N",					Nil},;
                            {"F1_DOC",		cDoc,					Nil},;
                            {"F1_SERIE",	cSerie,					Nil},;
                            {"F1_EMISSAO",	Date(),					Nil},;
                            {"F1_FORNECE",	cFornecedor,    		Nil},;
                            {"F1_LOJA",		cLoja,      			Nil},;
                            {"F1_COND",		SC7->C7_COND,			Nil},;
                            {"F1_EST",		cEst,					Nil},;
							{"F1_COND",		cCond,					Nil},;
                            {"F1_ESPECIE",	"NF ",					Nil}}

                do while SC7->(!eof() .and. C7_FILIAL + C7_NUM == xFilial("SC7") + cNumPC)
                    if SB1->(dbSeek(xFilial("SB1") + SC7->C7_PRODUTO))
                        nQtdItem	:= SC7->C7_QUANT - SC7->C7_QUJE

                        aAdd(aIteNF, {	{"D1_ITEM", 	StrZero(++nItem,4),					Nil},;
                                        {"D1_COD",		SC7->C7_PRODUTO,					Nil},;
                                        {"D1_LOCAL",	SC7->C7_LOCAL,						Nil},;
                                        {"D1_QUANT",	nQtdItem,							Nil},;
                                        {"D1_VUNIT",	SC7->C7_PRECO, 						Nil},;
                                        {"D1_TOTAL",	Round(nQtdItem * SC7->C7_PRECO,2),	Nil},;
                                        {"D1_TES",		SC7->C7_TES,						Nil},;
                                        {"D1_CC",		SC7->C7_CC,							Nil},;
                                        {"D1_PEDIDO", 	SC7->C7_NUM,						Nil},;
                                        {"D1_ITEMPC", 	SC7->C7_ITEM,						Nil}})			

                    endif

                    SC7->(dbSkip())
                enddo
            
                if Len(aIteNF) > 0
					dbSelectArea("SF1")
                    MsExecAuto({|x, y, z| MATA103(x, y, z)}, aCabNF, aIteNF, 3)

                    if lMsErroAuto

                        cObservacao	:= MemoRead(NomeAutoLog())
						cBody		:= BodyDocEntr( .F.,;
													cNumPC,;
													Nil,;
													aTitulo,;
													cObservacao)
                        cAssunto 	:= "Documento de entrada não incluido - error.log no processo msexecauto . Pedido de compras " + cNumPC
						cStatus		:= "8"
						cLog		:= ZZH->ZZH_LOG	+ "Inconsistencia na integração do documento de entrada em " + dTOc(Date()) + " as " + Time() + Chr(13) + Chr(10) + cAssunto + chr(13) + chr(10) + cObservacao + Chr(13) + Chr(10) +Repl("=",75) + Chr(13) + Chr(10)

                    else

						aTitulo := {}
						SE2->(dbSetOrder(6))	//E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO
						SE2->(dbSeek(xFilial("SE2") + SF1->(F1_FORNECE + F1_LOJA + F1_PREFIXO + F1_DOC)))
						do while SE2->(!eof() .and. E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM == xFilial("SE2") + SF1->(F1_FORNECE + F1_LOJA + F1_PREFIXO + F1_DOC))
						
							if SE2->E2_TIPO == "NF "
								SE2->(RecLock("SE2",.F.))
								SE2->E2_VENCTO	:= ZZH->ZZH_VENCTO
								SE2->E2_VENCREA	:= DataValida(ZZH->ZZH_VENCTO, .T.)
								SE2->E2_LINDIG	:= iif(Len(AllTrim(ZZH->ZZH_CODBAR))==44, FinCbLd(ZZH->ZZH_CODBAR), ZZH->ZZH_CODBAR)
								SE2->E2_CODBAR	:= iif(Len(AllTrim(ZZH->ZZH_CODBAR))==44, ZZH->ZZH_CODBAR, FinLdCb(ZZH->ZZH_CODBAR))
								SE2->E2_HIST	:= "Fatura GKO"
								SE2->(MsUnlock())

								aAdd(aTitulo, {SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_VENCREA, SE2->E2_VALOR})
							endif
							SE2->(dbSkip())
						enddo

						cLog	:= ZZH->ZZH_LOG	+ "Integração do documento de entrada/título financeiro " + SF1->F1_DOC + "/" + SF1->F1_SERIE + " em " + dTOc(Date()) + " as " + Time() + Chr(13) + Chr(10) + Repl("=",75) + Chr(13) + Chr(10)
						ZZH->(RecLock("ZZH",.F.))
						ZZH->ZZH_STATUS	:= "2"
						ZZH->ZZH_LOG	:= cLog
						ZZH->(MsUnLock())

                        cAssunto := "Documento de entrada incluido COM SUCESSO - Pedido de compras " + cNumPC
						cBody	:= BodyDocEntr( .T.,;
												cNumPC,;
												{SF1->F1_DOC, SF1->F1_SERIE, dTOc(SF1->F1_EMISSAO), SF1->F1_FORNECE, SF1->F1_LOJA, SA2->A2_NOME, SF1->F1_VALBRUT},;
												aTitulo,;
												cObservacao)

                    endif
                
                else

                    cAssunto 	:= "Documento de entrada não incluido - Não encontrado itens no Pedido de Compras"
                	cBody		:= BodyDocEntr(	.F.,;
												cNumPC,;
												Nil,;
												aTitulo,;
												cAssunto)

					cLog		:= ZZH->ZZH_LOG	+ "Inconsistencia na integração do documento de entrada em " + dTOc(Date()) + " as " + Time() + Chr(13) + Chr(10) + cAssunto + Chr(13) + Chr(10) +Repl("=",75) + Chr(13) + Chr(10)
					cStatus		:= "8"

                endif

            else

                cAssunto 	:= "Documento de entrada não incluido - Documento já cadastrado"
               	cBody		:= BodyDocEntr(	.F.,;
											cNumPC,;
											Nil,;
											aTitulo,;
											cAssunto)

				cLog		:= ZZH->ZZH_LOG	+ "Inconsistencia na integração do documento de entrada em " + dTOc(Date()) + " as " + Time() + Chr(13) + Chr(10) + cAssunto + Chr(13) + Chr(10) +Repl("=",75) + Chr(13) + Chr(10)
				cStatus		:= "8"


            endif
        
        else

            cAssunto 	:= "Documento de entrada não incluido - Fornecedor não encontrado"
        	cBody		:= BodyDocEntr(	.F.,;
										cNumPC,;
										Nil,;
										aTitulo,;
										cAssunto)

			cLog		:= ZZH->ZZH_LOG	+ "Inconsistencia na integração do documento de entrada em " + dTOc(Date()) + " as " + Time() + Chr(13) + Chr(10) + cAssunto + Chr(13) + Chr(10) +Repl("=",75) + Chr(13) + Chr(10)
			cStatus		:= "8"

        endif

    else

		cStatus		:= "8"
        cAssunto	:= "Documento de entrada não incluido - Pedido não encontrado"
       	cBody		:= BodyDocEntr(	.F.,;
									cNumPC,;
									Nil,;
									aTitulo,;
									cAssunto)

		cLog		:= ZZH->ZZH_LOG	+ "Inconsistencia na integração do documento de entrada em " + dTOc(Date()) + " as " + Time() + Chr(13) + Chr(10) + cAssunto + Chr(13) + Chr(10) +Repl("=",75) + Chr(13) + Chr(10)
		cStatus		:= "8"

    endif

	//Atualizando status ZZH e log, quando retornado erro.
	if cStatus == "8"
		ZZH->(RecLock("ZZH",.F.))
		ZZH->ZZH_STATUS	:= "8"
		ZZH->ZZH_LOG	:= cLog
		ZZH->(MsUnLock())
	endif

    if !Empty(cBody)

		if !Empty(DESTINATHOMOLOG)
			cDestinat		:= DESTINATHOMOLOG	// Informe o endereço eletrônico do destinatário.
			cPreAssunt		:= "HOMOLOGAÇÃO "
		endif

        //caso a nota venha a ser excluida, por qualquer motivo, a nota deve ser incluida manualmente.
        cErro := U_GISendMail(cDestinat,, cPreAssunt + cAssunto, cBody)		//mudar aqui retirar HOMOLOGAÇÃO
    endif

    //———————————————————————————————————————————————————————————————————————————————
    // Encerramento do ambiente
    //———————————————————————————————————————————————————————————————————————————————
    RpcClearEnv()

    ConOut(dTOc(Date()) + " - " + Time() + " JOB15DESP - Processo de inclusão do documento de entrada (Empresa, Filial, Doc, Serie, Fornecedor e Loja) " + cEmp + "-" + cFil + "-" + AllTrim(cDoc) + "-" + cSerie + "-" + cFornecedor + "-" + cLoja)

endif

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		BODYDOCENTR                                                  /@
@type			Static function                                              /@
@date			04/10/2021                                                   /@
@description	Formata html para corpo do email de sucesso ou insucesso na
				gravação do documento de entrada.                            /@
@parameters     lSucesso- Verificação se gravado ou não gravado
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Tecnologia da Informação                            /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function BodyDocEntr(lSucesso, cNumPC, aDoc, aTitulo, cObservacao)
Local cHTML 		:= ""
Local cLinkLogo		:= AllTrim(GetMV("BR_LNKLOGO", .F., "https://sweb.gamaitaly.com.br/images/LogoGamaPeq.jpg"))
Local cAmbiente		:= Lower(GetEnvServer())
Local nX

if aDoc == Nil
	aDoc := {"", "", "", "", "", "", 0}
endif

cHTML	+= '<html>'
cHTML	+= '    <head>'

cHTML	+= '    <style type="text/css">'
cHTML	+= '    .baseboard {'
cHTML	+= '        color: #000000;'
cHTML	+= '        font-family: Arial, Helvetica, sans-serif;'
cHTML	+= '        font-style: italic;'
cHTML	+= '        font-size: 8.5pt'
cHTML	+= '    }'
cHTML	+= '    .header-fields {'
cHTML	+= '        font-size: x-small;'
cHTML	+= '        font-family: Arial, Helvetica, sans-serif;'
cHTML	+= '        background-color: #D6D6D6;'
cHTML	+= '    }'
cHTML	+= '    .detail-fields {'
cHTML	+= '        font-size: x-small;'
cHTML	+= '        font-family: Arial, Helvetica, sans-serif;'
cHTML	+= '    }'
cHTML	+= '    .highlight-detail {'
cHTML	+= '        font-size: small;'
cHTML	+= '        font-family: Arial, Helvetica, sans-serif;'
cHTML	+= '        color: #000080;'
cHTML	+= '    }'
cHTML	+= '    .status-problema {'
cHTML	+= '        margin-bottom: 5px;'
cHTML	+= '        color: #7B0E00;'
cHTML	+= '        font-family: Arial, Helvetica, sans-serif;'
cHTML	+= '        font-size: medium;'
cHTML	+= '    }'
cHTML	+= '    .status-sucesso {'
cHTML	+= '        margin-bottom: 5px;'
cHTML	+= '        color: #127B00;'
cHTML	+= '        font-family: Arial, Helvetica, sans-serif;'
cHTML	+= '        font-size: medium;'
cHTML	+= '    }'
cHTML	+= '    .titulos-pag {'
cHTML	+= '        font-size: medium;'
cHTML	+= '        font-family: Arial, Helvetica, sans-serif;'
cHTML	+= '        background-color: #D6D6D6;'
cHTML	+= '        margin-bottom: 0px;'
cHTML	+= '    }'
cHTML	+= '    </style>'

cHTML	+= '    </head>'
cHTML	+= '    <body>'
cHTML	+= '    <table border="0" width="100%"><tr>'
cHTML	+= '        <td style="font-size: 6pt; color: #D6D6D6; height: 38; width: 11%;"><img src= ' + cLinkLogo + '></td>'
cHTML	+= '    </tr></table>'

if lSucesso
	cHTML	+= '    <p class="status-sucesso"><strong>Documento de entrada incluído com sucesso</strong></p>'
else
	cHTML	+= '    <p class="status-problema"><strong>Documento não foi incluído. Providencie a inclusão manualmente</strong></p>'
endif

cHTML	+= '    <br>'
cHTML	+= '    <table style="width: 100%">'
cHTML	+= '        <tr>'
cHTML	+= '            <td class="header-fields" style="width: 15%">Documento</td>'
cHTML	+= '            <td class="header-fields" style="width: 15%">Série</td>'
cHTML	+= '            <td class="header-fields" style="width: 15%">Emissão</td>'
cHTML	+= '            <td class="header-fields" style="width: 25%">Pedido</td>'
cHTML	+= '            <td class="header-fields" style="width: 30%">Filial</td>'
cHTML	+= '        </tr>'
cHTML	+= '        <tr>'
cHTML	+= '            <td class="detail-fields" style="height: 30px; width: 15%"><strong>' + AllTrim(aDoc[1]) + '</strong></td>'
cHTML	+= '            <td class="detail-fields" style="height: 30px; width: 15%"><strong>' + AllTrim(aDoc[2]) + '</strong></td>'
cHTML	+= '            <td class="detail-fields" style="height: 30px; width: 15%"><strong>' + AllTrim(aDoc[3]) + '</strong></td>'
cHTML	+= '            <td class="detail-fields" style="height: 30px; width: 25%"><strong>' + cNumPC + '</strong></td>'
cHTML	+= '            <td class="detail-fields" style="height: 30px; width: 30%"><strong>' + SM0->M0_CODFIL+ " - " + SM0->M0_FILIAL + '</strong></td>'
cHTML	+= '        </tr>'
cHTML	+= '    </table>'
cHTML	+= '    <table style="width: 100%">'
cHTML	+= '        <tr>'
cHTML	+= '            <td class="header-fields" style="width: 30%">Fornecedor</td>'
cHTML	+= '            <td class="header-fields" style="width: 70%">Nome</td>'
cHTML	+= '        </tr>'
cHTML	+= '        <tr>'
cHTML	+= '            <td class="detail-fields" style="width: 30%"><strong>' + AllTrim(aDoc[4]) + "/" + aDoc[5] + '</strong></td>'
cHTML	+= '            <td class="detail-fields" style="width: 70%"><strong>' + AllTrim(aDoc[6]) + '</strong></td>'
cHTML	+= '        </tr>'
cHTML	+= '    </table>'
cHTML	+= '    </table>'
cHTML	+= '    <table style="width: 100%">'
cHTML	+= '        <tr>'
cHTML	+= '            <td class="header-fields" style="width: 100%">Observação</td>'
cHTML	+= '        </tr>'
cHTML	+= '        <tr>'
cHTML	+= '            <td class="detail-fields" style="width: 100%"><strong>' + cObservacao + '</strong></td>'
cHTML	+= '        </tr>'
cHTML	+= '    </table>'
cHTML	+= '    <table style="width: 30%">'
cHTML	+= '        <tr>'
cHTML	+= '            <td class="header-fields">Total</td>'
cHTML	+= '        </tr>'
cHTML	+= '        <tr>'
cHTML	+= '            <td class="highlight-detail" style="height: 30px; width: 50%"><strong>' + Transf(aDoc[7], "@E 999,999,999.99") + '</strong></td>'
cHTML	+= '        </tr>'
cHTML	+= '    </table>'
cHTML	+= '    <br>'
cHTML	+= '    <br>'

if Len(aTitulo) > 0
	cHTML	+= '    <p class="titulos-pag" style="width: 100%"><strong>Títulos</strong></p>'
	for nX := 1 to Len(aTitulo)
		cHTML	+= '    <table style="width: 100%">'
		cHTML	+= '        <tr>'
		cHTML	+= '            <td class="header-fields" style="width: 16%">Prefixo</td>'
		cHTML	+= '            <td class="header-fields" style="width: 16%">Número</td>'
		cHTML	+= '            <td class="header-fields" style="width: 16%">Parcela</td>'
		cHTML	+= '            <td class="header-fields" style="width: 16%">Tipo</td>'
		cHTML	+= '            <td class="header-fields" style="width: 16%">Vencimento</td>'
		cHTML	+= '            <td class="header-fields" style="width: 20%">Valor</td>'
		cHTML	+= '        </tr>'
		cHTML	+= '        <tr>'
		cHTML	+= '            <td class="detail-fields" style="width: 16%;height: 30px"><strong>' + aTitulo[nX,1] + '</strong></td>'
		cHTML	+= '            <td class="detail-fields" style="width: 16%;height: 30px"><strong>' + aTitulo[nX,2] + '</strong></td>'
		cHTML	+= '            <td class="detail-fields" style="width: 16%;height: 30px"><strong>' + aTitulo[nX,3] + '</strong></td>'
		cHTML	+= '            <td class="detail-fields" style="width: 16%;height: 30px"><strong>' + aTitulo[nX,4] + '</strong></td>'
		cHTML	+= '            <td class="detail-fields" style="width: 16%;height: 30px"><strong>' + dTOc(aTitulo[nX,5]) + '</strong></td>'
		cHTML	+= '            <td class="highlight-detail" style="width: 20%;height: 30px"><strong>' + Transform(aTitulo[nX,6], "@E 999,999,999.99") + '</strong></td>'
		cHTML	+= '        </tr>'
		cHTML	+= '    </table>'

	next
endif

cHTML	+= '    <br>'
cHTML	+= '    <p><span class="baseboard"><i>E-mail automático enviado pelo processo de workflow, ambiente ' + cAmbiente + '. Favor não respondê-lo.</i></span></p>'
cHTML	+= '    </body>'
cHTML	+= '</html>'

Return(cHTML)
