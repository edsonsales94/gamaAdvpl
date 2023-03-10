#include "protheus.ch"
#include "rwmake.ch"
#include "ap5mail.ch"

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Vari疱el para uso de homologa鈬o de ambiente. Informar o(s) endere輟(s) de
// email dos destinat疵ios.
// Para produc縊		DESTINATHOMOLOG ""
// Para homologa鈬o 	DESTINATHOMOLOG "amoreno@opcaoum.com.br"
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
#define DESTINATHOMOLOG ""

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		BRAJOB20	                                                 /@
@type			User function                                                /@
@date			21/09/2020                                                   /@
@description	Job de  de envio de email para aprova鈬o ou rejei鈬o
				de solicita鈬o de compras.                                   /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Op鈬o Um Tecnologia da Informa鈬o                            /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function BRAJOB20()
Local aFiles	:= {"SA2", "SB1", "SC7", "SCI", "CTT"}
Local cEmp		:= "01"
Local aFil		:= {"01", "03", "08", "09"}
Local nE, nK

for nE := 1 to Len(aFil)

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Abertura do ambiente
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	WfPrepEnv(cEmp, aFil[nE], "U_BRAJOB20",, "COM")
	
	for nK := 1 to Len(aFiles)
	
		if Empty(Select(aFiles[nK]))
			ChkFile(aFiles[nK])
		endif
		
	next
	
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Selecao de solicita鋏es bloqueadas
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	A20_BRAJOB()
	
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Encerramento do ambiente
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	RpcClearEnv()

next

ConOut(dTOc(Date()) + " - " + Time() + " BRAJOB20 - Processo de libera鈬o de solicita鈬o de compras")

Return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		A20_BRAJOB	                                                 /@
@type			Static function                                              /@
@date			21/09/2020                                                   /@
@description	Job de  de envio de email para aprova鈬o ou rejei鈬o
				de solicita鈬o de compras.                                   /@
@author			Adalberto Moreno Batista (Op鈬o Um)                          /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function A20_BRAJOB()
Local cQuery	:=	"SELECT C1_NUM " +;
						"FROM " + RetSqlName("SC1") + " SC1 " +;
						"WHERE SC1.C1_FILIAL = '" + xFilial("SC1") + "' " +;
							"AND SC1.C1_APROV = 'B' " +;
							"AND SC1.C1_XLINK = ' ' " +;
							"AND SC1.C1_RESIDUO = '' " +;
							"AND SC1.D_E_L_E_T_= ' ' " +;
						"GROUP BY C1_NUM " +;
						"ORDER BY C1_NUM"
Local cMailId

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Verificando a existencia da area Temporaria
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if Select("TSC1") > 0
	TSC1->(dbCloseArea())
endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Criando a tabela temporaria
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
dbUseArea( .T., "TOPCONN", TcGenQRY(,,cQuery), "TSC1", .F., .T.)

SA2->(dbSetOrder(1))		//A2_FILIAL, A2_COD, A2_LOJA
SB1->(dbSetOrder(1))		//B1_FILIAL, B1_COD
SC1->(dbSetOrder(1))		//C1_FILIAL, C1_NUM, C1_ITEM, C1_ITEMGRD

dbSelectArea("TSC1")
TSC1->(dbGoTop())
do while TSC1->(!eof())
	
	if SC1->(dbSeek(xFilial("SC1") + TSC1->C1_NUM)) .and. SC1->C1_APROV == "B"
	
		cMailId := A20_EnvAprov_BRAJOB()
		
		SC1->(dbSeek(xFilial("SC1") + TSC1->C1_NUM))
		do while SC1->(!eof() .and. C1_FILIAL == xFilial("SC1") .and. C1_NUM == TSC1->C1_NUM)
			SC1->(WFSalvaID("SC1", "SC1->C1_XLINK", 	cMailId))
//			SCR->(WFSalvaID("SCR", "SCR->CR_XSENDDT",   Date()))
//			SCR->(WFSalvaID("SCR", "SCR->CR_XSENDHR",   Time()))
			SC1->(dbSkip())
		enddo

	endif
	
	TSC1->(dbSkip())

enddo

if Select("TSC1") > 0
	TSC1->(dbCloseArea())
endif

Return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		A20_ENVAPROV_BRAJOB                                          /@
@type			Static function                                              /@
@date			21/09/2020                                                   /@
@description	Monta o processo de envio do link e montagem da p疊ina de 
				aprova鈬o da solicita鈬o de compras.                         /@
@author			Adalberto Moreno Batista (Op鈬o Um)                          /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function A20_EnvAprov_BRAJOB()
Local cAssunto		:= "Aprova鈬o da Solicita鈬o de Compras Nr. " + SC1->C1_NUM
Local cWFDir		:= "\workflow\emp" + cEmpAnt + "\html_sc"
Local cEndServ		:= GetMV("MV_WFDHTTP", .F., "http://200.233.165.157:8082/")
Local cLinkLogo	    := AllTrim(GetMV("BR_LNKLOGO", .F., "https://sweb.gamaitaly.com.br/images/LogoGamaPeq.jpg"))
Local aItens		:= {}             
Local cAmbiente	    := Lower(GetEnvServer())
Local cFornecedor	:= ""
Local cNum			:= SC1->C1_NUM
Local dEmissao		:= SC1->C1_EMISSAO
Local cSolicitante  := SC1->C1_USER
Local cLiberador	:= FindLiber(cNum)
Local nTotal		:= 0
Local aFiles		:= {}
Local cDirAnexos	:= GetMV("BR_ANEXOPC",.F.,"\EDI01\COTACOES")
Local nX, cPathApoio, aFilesApoio
Private oHTML, cMailID

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Alimentando aFiles para os anexos das aprova鋏es (Solicita鈬o de Compras)
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
cPathApoio	:= cDirAnexos + "\" + cEmpAnt + cFilAnt + "\SC\" + StrZero(Year(SC1->C1_EMISSAO), 4) + "\" + "mes_" + StrZero(Month(SC1->C1_EMISSAO), 2) + "\"
aFilesApoio	:= Directory(cPathApoio + AllTrim(cFilAnt)+ "_" + AllTrim(SC1->C1_NUM) + "_" + "*.*")
for nX:=1 to Len(aFilesApoio)
	aAdd(aFiles, { cPathApoio, aFilesApoio[nX,1], aFilesApoio[nX,2]})
next

CTT->(dbSetOrder(1))
SA2->(dbSetOrder(1))
SB1->(dbSetOrder(1))

if !Empty(SC1->C1_FORNECE + SC1->C1_LOJA)
	SA2->(dbSeek(xFilial("SA2") + SC1->C1_FORNECE + SC1->C1_LOJA))
	cFornecedor	    := SA2->A2_NOME + "  (" + SC1->C1_FORNECE + "/" + SC1->C1_LOJA + ")"
endif

do while SC1->(!eof() .and. C1_FILIAL == xFilial("SC1") .and. C1_NUM == cNum)

	SB1->(dbSeek(xFilial("SB1") + SC1->C1_PRODUTO))
	CTT->(dbSeek(xFilial("CTT") + SC1->C1_CC))

	aAdd(aItens, {	SC1->C1_ITEM,;
					SC1->C1_PRODUTO,;
					AllTrim(SC1->C1_DESCRI) + iif(!empty(SC1->C1_OBS), " - " + AllTrim(SC1->C1_OBS), ""),;
					SC1->C1_UM,;
					SC1->C1_QUANT,;
					SC1->C1_DATPRF,;
					AllTrim(SC1->C1_CC) + " / " + Left(CTT->CTT_DESC01, 20),;
					SC1->C1_VUNIT})

	nTotal += (SC1->C1_QUANT * SC1->C1_VUNIT)
	SC1->(dbSkip())
	
enddo


//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Monta o HTML para aprova鈬o e verificar o tipo do aprovador
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
oProcess 			:= TWFProcess():New("BRAJOB20", "Solicita鈬o de compras")
oProcess:cTo 		:= "JOB20_APROV"

oProcess:NewTask("000020", "\workflow\BRAJOB20_Aprov.htm")
oProcess:cSubject	:= cAssunto
oProcess:bReturn	:= "U_A20Ret_BRAJOB()"
oProcess:UserSiga	:= "JOB20"
oProcess:NewVersion(.T.)

for nX := 1 to Len(aFiles)
	oProcess:AttachFile(aFiles[nX,1] + aFiles[nX,2])
next

oHTML   			:= oProcess:oHTML

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Campos de controle para o retorno da p疊ina da aprova鈬o
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
oHTML:ValByName("NUMERO",			cNum)
oHTML:ValByName("SOLICITANTE",		cSolicitante)
oHTML:ValByName("APROVADOR",		cLiberador)

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Cabe軋lho
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
oHTML:ValByName("C_LINKLOGO",		cLinkLogo)
oHTML:ValByName("C_NUM",			cNum)
oHTML:ValByName("C_FILIAL",		    Upper(SM0->M0_FILIAL))
oHTML:ValByName("C_EMISSAO",		dTOc(dEmissao))
oHTML:ValByName("C_FORNECEDOR",	    cFornecedor)
oHTML:ValByName("C_SOLICITANTE",    AllTrim(UsrFullName(cSolicitante)) + "      (" + UsrRetMail(cSolicitante) + ")")

for nX := 1 to Len(aItens)
	aAdd((oHTML:ValByName("I.ITEM")),		aItens[nX,1])
	aAdd((oHTML:ValByName("I.PRODUTO")),	aItens[nX,2])
	aAdd((oHTML:ValByName("I.DESCR")),		aItens[nX,3])
	aAdd((oHTML:ValByName("I.UM")),			aItens[nX,4])
	aAdd((oHTML:ValByName("I.QTDE")),		Transform(aItens[nX,5], "@E 999,999,999"))
	aAdd((oHTML:ValByName("I.VUNIT")),		Transform(aItens[nX,8], "@E 999,999,999.99"))
	aAdd((oHTML:ValByName("I.TOTAL")),		Transform(aItens[nX,5]*aItens[nX,8], "@E 999,999,999.99"))
	aAdd((oHTML:ValByName("I.ENTREGA")),	dTOc(aItens[nX,6]))
	aAdd((oHTML:ValByName("I.CCUSTO")),		aItens[nX,7])
next

oHTML:ValByName("R_TOTAL",		Transform(nTotal, "@E 999,999,999.99"))

cMailID 				:= oProcess:Start(cWFDir,.T.)

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// In?cio da definicao do email do Link
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
oProcess:NewTask(cAssunto, "\workflow\BRAJOB20_Link.htm")
 
oProcess:cSubject   := cAssunto
if !Empty(DESTINATHOMOLOG)
	oProcess:cTo		:= DESTINATHOMOLOG	// Informe o endere輟 eletr?nico do destinat疵io.
	ConOut(">>> SC1 DESTINATHOMOLOG " + DESTINATHOMOLOG + "  oProcess:cTO " + oProcess:cTo)
else
	oProcess:cTo		:= Alltrim(UsrRetMail(cLiberador))	// Informe o endere輟 eletr?nico do destinat疵io.
endif
oHTML   	 		:= oProcess:oHTML

ConOut("(BEGIN|WFLINK)Process Id: " + oProcess:fProcessID + " - Task: " + oProcess:fTaskID)

oHTML:ValByName("C_LINKLOGO",		cLinkLogo)
oHTML:ValByName("C_NUM",			cNum)
oHTML:ValByName("C_FILIAL",		    Upper(SM0->M0_FILIAL))
oHTML:ValByName("C_EMISSAO",		dTOc(dEmissao))
oHTML:ValByName("C_FORNECEDOR",	    cFornecedor)
oHTML:ValByName("C_SOLICITANTE",    AllTrim(UsrFullName(cSolicitante)) + "      (" + UsrRetMail(cSolicitante) + ")")

for nX := 1 to Len(aItens)
	aAdd((oHTML:ValByName("I.ITEM")),		aItens[nX,1])
	aAdd((oHTML:ValByName("I.PRODUTO")),	aItens[nX,2])
	aAdd((oHTML:ValByName("I.DESCR")),		aItens[nX,3])
	aAdd((oHTML:ValByName("I.UM")),			aItens[nX,4])
	aAdd((oHTML:ValByName("I.QTDE")),		Transform(aItens[nX,5], "@E 999,999,999.99"))
	aAdd((oHTML:ValByName("I.VUNIT")),		Transform(aItens[nX,8], "@E 999,999,999.99"))
	aAdd((oHTML:ValByName("I.TOTAL")),		Transform(aItens[nX,5]*aItens[nX,8], "@E 999,999,999.99"))
	aAdd((oHTML:ValByName("I.ENTREGA")),	dTOc(aItens[nX,6]))
	aAdd((oHTML:ValByName("I.CCUSTO")),		aItens[nX,7])
next

oHTML:ValByName("R_TOTAL",		Transform(nTotal, "@E 999,999,999.99"))

oHTML:ValByName("R_MAILID",	    cMailId)
oHTML:ValByName("R_AMBIENTE",	cAmbiente)

oProcess:oHTML:ValByName("proc_link", cEndServ + "/emp" + cEmpAnt + "/html/" + cMailID + ".htm")	//"proc_link" ? o nome que est? definido no html brajob15_link
oProcess:Start()

Return(cMailId)


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		A20RET_BRAJOB                                                /@
@type			Static function                                              /@
@date			21/09/2020                                                   /@
@description	Retorno reposta da aprov./rejei鈬o da solicita鈬o de compras /@
@author			Adalberto Moreno Batista (Op鈬o Um)                          /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function A20Ret_BRAJOB(oProcess)
Local cNum		:= Left(oProcess:oHtml:RetByName("NUMERO"),6)
Local cSolicit	:= AllTrim(oProcess:oHtml:RetByName("SOLICITANTE"))
Local cAprov	:= AllTrim(oProcess:oHtml:RetByName("APROVADOR"))
Local cOpcao	:= AllTrim(oProcess:oHtml:RetByName("OPC"))
Local cObs		:= AllTrim(oProcess:oHtml:RetByName("JUSTIFICATIVA"))
Local cMailId	:= Substr(AllTrim(oProcess:oHtml:RetByName("WFMAILID")), 3)		//campo alimentado com a string 'WF' + o c?digo do processo
Local cCorpo, cAssunto, cDestinat

oProcess:Finish()           // FINALIZA O PROCESSO

SC1->(dbSetOrder(1))		//C1_FILIAL, C1_NUM

if SC1->(dbSeek(xFilial("SC1") + cNum))

	//Verifica se o e-mail respondido, refere-se ao link ativo (quando h? altera鈬o no pedido, novos emails s縊 enviados, com uma nova numera鈬o de controle)
	if SC1->C1_XLINK == cMailId

		if SC1->C1_APROV == "R"
			
			cDestinat 	:= Alltrim(UsrRetMail(cLiberador))
			cAssunto	:= "Solicita鈬o de Compra nr. " + SC1->C1_NUM + " rejeitada anteriormente"
			cCorpo 		:= '<html><body>'
			cCorpo 		+= '<font size="3" face="Calibri">Prezado(a) ' + AllTrim(UsrFullName(SC1->C1_USER)) + ',</font><br><br>'
			cCorpo 		+= '<font size="3" face="Calibri">A Solicita鈬o de Compra nr. ' + SC1->C1_NUM + ' foi rejeitada anteriormente, portanto sua a鈬o nesta solicita鈬o n縊 foi aceita.</font><br><br><br>'
			cCorpo 		+= '<font size="1" face="Calibri"><i>E-mail autom疸ico enviado pelo processo dow, Favor n縊 respond?-lo.</i></font><br><br>'
			cCorpo 		+= '</body></html>'
	
		else
	
			cDestinat 	:= Alltrim(UsrRetMail(cSolicit))	//SC1->C1_USER

			if cOpcao == "APROVAR"

				cAssunto	:= "Solicita鈬o de Compra nr. " + cNum + " APROVADA"
				cCorpo	    := A20MontaEmail(.T., cObs)

				do while SC1->(!eof() .and. C1_FILIAL == xFilial("SC1") .and. C1_NUM == cNum)
					if 	SC1->C1_APROV $ " ,B,R" .and.;
						SC1->C1_QUJE == 0 .And.;
					    Empty(SC1->C1_COTACAO) .And.;
						Empty(SC1->C1_RESIDUO)

						SC1->(RecLock("SC1", .F.))
						SC1->C1_APROV 	:= "L"
						SC1->C1_NOMAPRO := UsrFullName(cAprov)
						SC1->(MsUnlock())

					endif
					SC1->(dbSkip())
				enddo

			else
		
				cAssunto	:= "Solicita鈬o de Compra nr. " + cNum + " REPROVADA"
				cCorpo	    := A20MontaEmail(.F., cObs)

				do while SC1->(!eof() .and. C1_FILIAL == xFilial("SC1") .and. C1_NUM == cNum)
					if 	SC1->C1_APROV $ " ,B,L" .and.;
						SC1->C1_QUJE == 0 .And.;
					    Empty(SC1->C1_COTACAO) .And.;
						Empty(SC1->C1_RESIDUO)

						SC1->(RecLock("SC1", .F.))
						SC1->C1_APROV 	:= "R"
						SC1->C1_NOMAPRO := UsrFullName(cAprov)
						SC1->(MsUnlock())

					endif
					SC1->(dbSkip())
				enddo

			endif
			
		endif

	else

		cFornecedor	:= GetAdvFVal("SA2", "A2_NOME", xFilial("SA2") + SC1->C1_FORNECE + SC1->C1_LOJA, 1, "")
		cDestinat 	:= Alltrim(UsrRetMail(cLiberador))
		cAssunto	:= "Aviso sobre link inativo referente ? solicita鈬o de compras " + SC1->C1_NUM
		cCorpo		:= '<html><body>' +;
						'<font size="3" face="Calibri">Prezado(a)' + AllTrim(cLiberador) + ',</font><br><br>' +;
						'<font size="3" face="Calibri">O link respondido, referente ? solicita鈬o de compra descrita abaixo, est? cancelado em raz縊 ou da altera鈬o ou exclus縊 da mesma. Aguarde novo envio de e-mail para aprova鈬o.</font><br><br><br>' +;
						'<font size="3" face="Calibri">Solicita鈬o de Compras ' + SC1->C1_NUM + '  -  ' + cFornecedor + '</font><br><br><br>' +;
						'<font size="1" face="Calibri"><i>E-mail autom疸ico enviado pelo processo dow, Favor n縊 respond?-lo.</i></font><br><br>' +;
						'</body></html>'

	endif
	
endif

if cCorpo <> Nil

	if !empty(DESTINATHOMOLOG)
		cDestinat	:= DESTINATHOMOLOG
		cAssunto	:= "HOMOLOGAﾇﾃO " + cAssunto
	endif

	U_GISendMail(cDestinat,, cAssunto, cCorpo)

endif

Return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		A20MontaEmail                                                /@
@type			Static function                                              /@
@date			28/09/2020                                                   /@
@description	Monta o corpo de e-mail para comunica鈬o com o solicitante.  /@
@author			Adalberto Moreno Batista (Op鈬o Um)                          /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function A20MontaEmail(lAprov, cObs)
Local cMsg

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Cria texto no formato HTML para envio do e-mail
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
cMsg := '<html>'
cMsg += '<body>'
cMsg += '<font size="3" face="Calibri">Prezado(a) ' + AllTrim(UsrFullName(SC1->C1_USER)) + ',</font><br><br>'
cMsg += '<font size="3" face="Calibri">Informamos que sua Solicita鈬o de Compras Nr. ' + SC1->C1_NUM + ' foi ' + iif(lAprov, 'liberada', 'reprovada') + '.</font><br>'
cMsg += '<font size="3" face="Calibri">Motivo: ' + cObs + '</font><br>'
cMsg += '<br><br><br>'
cMsg += '<font size="1" face="Calibri"><i>E-mail autom疸ico enviado pelo processo dow, Favor n縊 respond?-lo.</i></font><br><br>'
cMsg += '</body>'
cMsg += '</html>'

Return(cMsg)


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		FindLiber                                                    /@
@type			Static function                                              /@
@date			28/09/2020                                                   /@
@description	Busca o c?digo do respons疱el por liberar solicita鋏es de 
				compras considerando o grupo de al軋das de compras definido. /@
@author			Adalberto Moreno Batista (Op鈬o Um)                          /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function FindLiber(cNum)
Local aArea         := GetArea()
Local aAreaSAL      := SAL->(GetArea())
Local aAreaSC1      := SC1->(GetArea())
Local aAreaCTT	    := CTT->(GetArea())
Local cGrupo        := ""
Local cFirstLib     := ""
Local cLiberador    := ""

SAL->(dbSetOrder(2))		//AL_FILIAL, AL_COD, AL_NIVEL
SC1->(dbSetOrder(1))		//C1_FILIAL, C1_NUM, C1_ITEM, C1_ITEMGRD
CTT->(dbSetOrder(1))		//CTT_FILIAL, CTT_CCUSTO

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Identifica o grupo de aprova鈬o, de acordo com o definido no centro de custo
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
SC1->(dbSeek(xFilial("SC1") + cNum))
do While SC1->(!eof() .and. C1_FILIAL == xFilial("SC1") .and. C1_NUM == cNum)
    if !Empty(SC1->C1_CC) .and. CTT->(dbSeek(xFilial("CTT") + SC1->C1_CC))
        cGrupo 		:= CTT->CTT_XAPVPC
		if CTT->(FieldPos("CTT_XGEST")) > 0
			cLiberador	:= CTT->CTT_XGEST	//c?digo usu疵io
		endif
        Exit
	endif
    SC1->(dbSkip())
enddo

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// A partir do grupo de aprova鈬o, busco o primeiro registro cujo elemento for
// identificado como um APROVADOR. Vistadores ser縊 ignorados, a n縊 ser que n縊
// exista uma aprovador definido. Neste caso pego considero o primeiro registro
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if Empty(cLiberador)
	if !Empty(cGrupo) .and. SAL->(dbSeek(xFilial("SAL") + cGrupo))
		do While SAL->(!eof() .and. AL_FILIAL == xFilial("SAL") .and. AL_COD == cGrupo)

			if Empty(cFirstLib) .and. SAL->AL_MSBLQL != "1"
				cFirstLib := iif(Empty(SAL->A1_XGEST1N), SAL->AL_USER, SAL->A1_XGEST1N)
			endif

			if SAL->AL_LIBAPR == "A" .and. SAL->AL_MSBLQL != "1"
				cLiberador := iif(Empty(SAL->A1_XGEST1N), SAL->AL_USER, SAL->A1_XGEST1N)
				Exit
			endif

			SAL->(dbSkip())
			
		enddo

		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		// Caso n縊 encontre um APROVADOR, considero o primeiro registro da al軋da
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		if Empty(cLiberador)
			cLiberador := cFirstLib
		endif
	endif
endif

RestArea(aAreaCTT)
RestArea(aAreaSAL)
RestArea(aAreaSC1)
RestArea(aArea)

Return(cLiberador)
