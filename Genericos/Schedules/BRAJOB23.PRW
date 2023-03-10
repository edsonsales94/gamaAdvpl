#include "protheus.ch"
#include "rwmake.ch"
#include "ap5mail.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		BRAJOB23	                                                 /@
@type			User function                                                /@
@date			24/08/2020                                                   /@
@description	Job de workflow de envio de email para aprova鈬o ou rejei鈬o
				de altera鈬o vencimento t?tulos ? receber.                   /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Op鈬o Um Tecnologia da Informa鈬o                            /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?

User Function BRAJOB23()
Local aFiles	:= {"SA1", "SE1", "ZZ2"}
Local cEmp		:= "01"
Local aFil		:= {"01"}
Local nE, nK

for nE := 1 to Len(aFil)

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Abertura do ambiente
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	WfPrepEnv(cEmp, aFil[nE], "U_BRAJOB23",, "FIN")
	
	for nK := 1 to Len(aFiles)
	
		if Empty(Select(aFiles[nK]))
			ChkFile(aFiles[nK])
		endif
		
	next
	
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Selecao de pedidos bloqueados
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	U_A23_BRAJOB()
	
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Encerramento do ambiente
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	RpcClearEnv()

next

ConOut(dTOc(Date()) + " - " + Time() + " BRAJOB23- Altera鈬o vencimento t?tulos ? receber")

Return()
/*/


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		A23_ENVAPROV_BRAJOB                                          /@
@type			Static function                                              /@
@date			09/01/2017                                                   /@
@description	Job de workflow de envio de email para aprova鈬o ou rejei鈬o
				de altera鈬o vencimento t?tulos ? receber.                   /@
@author			Adalberto Moreno Batista (Op鈬o Um)                          /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function A23_EnvAprov_BRAJOB(dVctSol, cMotivo, cJustSolic, cUserSolic, lCNAB, cOcorrencia, dVencto)
Local cAssunto		:= "Solicita鈬o de altera鈬o de vencimento do t?tulo a receber " + SE1->(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO)
Local cWFDir		:= "\workflow\emp" + cEmpAnt + "\html"
Local cEndServ		:= GetMV("MV_WFDHTTP", .F.,"http://189.56.10.34:8082/workflow") // (producao)
Local cLinkLogo	    := AllTrim(GetMV("BR_LNKLOGO", .F., "https://sweb.gamaitaly.com.br/images/LogoGamaPeq.jpg"))
Local cAmbiente	    := Lower(GetEnvServer())
Local cAprovador	:= GetMV("BR_VCTOSE1", .F., "000000")
Local aItens		:= {}
Local dDtRefOri		:= iif(Empty(SE1->E1_XVCTORI), SE1->E1_VENCTO, SE1->E1_XVCTORI)
Local nX
Private oHTML, cMailID

SA1->(dbSetOrder(1))		//A1_FILIAL, A1_COD, A1_LOJA
ZZ2->(dbSetOrder(1))		//ZZ2_FILIAL, ZZ2_PREFIX, ZZ2_NUM, ZZ2_PARCEL, ZZ2_TIPO, ZZ2_CLIENT, ZZ2_LOJA, ZZ2_DTMOV, ZZ2_HRMOV

SA1->(dbSeek(xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA))
ZZ2->(dbSeek(xFilial("ZZ2") + SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA)))

do while ZZ2->(!eof() .and. ZZ2_FILIAL + ZZ2_PREFIX + ZZ2_NUM + ZZ2_PARCEL + ZZ2_TIPO + ZZ2_CLIENT + ZZ2_LOJA == xFilial("ZZ2") + SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA))
	aAdd(aItens, {	ZZ2->ZZ2_DTMOV,;
					ZZ2->ZZ2_USUMOV,;
					ZZ2->ZZ2_VENORI,;
					ZZ2->ZZ2_VENCTO,;
					ZZ2->ZZ2_VENREA,;
					ZZ2->ZZ2_MOTIVO	+ " - " + Tabela("Z5", ZZ2->ZZ2_MOTIVO, .F. )})
	ZZ2->(dbSkip())
enddo


//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Monta o HTML para aprova鈬o e verificar o tipo do aprovador
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
oProcess 			:= TWFProcess():New("BRAJOB23", "Vencimento t?tulo ? receber")
oProcess:cTo		:= "JOB23_APROV"

oProcess:NewTask("000023", "\workflow\BRAJOB23_Aprov.htm")
oProcess:cSubject	:= cAssunto
oProcess:bReturn	:= "U_A23Ret_BRAJOB()"
oProcess:UserSiga	:= "JOB23"
oProcess:NewVersion(.T.)

oHTML   			:= oProcess:oHTML

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Campos de controle para o retorno da p疊ina da aprova鈬o
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
oHTML:ValByName("FILIAL",       SE1->E1_FILIAL)
oHTML:ValByName("PREFIXO",      SE1->E1_PREFIXO)
oHTML:ValByName("NUMERO",       SE1->E1_NUM)
oHTML:ValByName("PARCELA",      SE1->E1_PARCELA)
oHTML:ValByName("TIPO",         SE1->E1_TIPO)
oHTML:ValByName("VCTSOL",       dTOc(dVctSol))
oHTML:ValByName("VENCTO",       dTOc(dVencto))
oHTML:ValByName("MOTIVO",		cMotivo)
oHTML:ValByName("OCORRENCIA",	iif(lCNAB, cOcorrencia, ""))
oHTML:ValByName("JUSTIFSOLIC",  cJustSolic)
oHTML:ValByName("SOLICITANTE",  cUserSolic)
oHTML:ValByName("APROVADOR",    cAprovador)

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Cabe軋lho
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
oHTML:ValByName("C_LINKLOGO",		cLinkLogo)

oHTML:ValByName("M_FILIAL",			SM0->M0_FILIAL)
oHTML:ValByName("M_TITULO",		    SE1->(E1_FILIAL + "-" + E1_PREFIXO + "-" + E1_NUM + "-" + E1_PARCELA + "-" + E1_TIPO))
oHTML:ValByName("M_VALOR",		    Transform(SE1->E1_VALOR, "@E 999,999,999.99"))
oHTML:ValByName("M_VCTATU",		    dTOc(SE1->E1_VENCREA))
oHTML:ValByName("M_VCTSOL",		    dTOc(dVctSol))
oHTML:ValByName("M_OBS",		    iif(dDtRefOri < Date(), "VENCIDO", ""))
oHTML:ValByName("M_CLIENTE",		SE1->E1_CLIENTE + "/" + SE1->E1_LOJA + " - " + SA1->A1_NOME)
oHTML:ValByName("M_SOLICITANTE",	AllTrim(UsrFullName(cUserName)))
oHTML:ValByName("M_MOTIVO",		    cMotivo + " - " + Tabela("Z5", cMotivo, .F.))
oHTML:ValByName("M_INFADIC",		cJustSolic)

for nX := 1 to Len(aItens)
	aAdd((oHTML:ValByName("H.DATA")),		aItens[nX,1])
	aAdd((oHTML:ValByName("H.USUARIO")),	aItens[nX,2])
	aAdd((oHTML:ValByName("H.VCTORI")),		dTOc(aItens[nX,3]))
	aAdd((oHTML:ValByName("H.VCT")),		dTOc(aItens[nX,4]))
	aAdd((oHTML:ValByName("H.VCTREA")),		dTOc(aItens[nX,5]))
	aAdd((oHTML:ValByName("H.MOTIVO")),		aItens[nX,6])
//	aAdd((oHTML:ValByName("H_JUSTIFIC")),	aItens[nX,7])
next

cMailID 			:= oProcess:Start(cWFDir,.T.)

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// In?cio da definicao do email do Link
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
oProcess:NewTask(cAssunto, "\workflow\BRAJOB23_Link.htm")
oProcess:cSubject   := cAssunto
oProcess:cTo 		:= Alltrim(UsrRetMail(cAprovador))
oHTML   	 		:= oProcess:oHTML

ConOut("(BEGIN|WFLINK)Process Id: " + oProcess:fProcessID + " - Task: " + oProcess:fTaskID)

//oHTML:ValByName("nome_aprovador", AllTrim(UsrFullName(SCR->CR_USER)))
oHTML:ValByName("C_LINKLOGO",		cLinkLogo)

oHTML:ValByName("M_FILIAL",			"Filial " + Upper(SM0->M0_FILIAL))
oHTML:ValByName("M_TITULO",		    SE1->(E1_PREFIXO + "-" + E1_NUM + "-" + E1_PARCELA + "-" + E1_TIPO))
oHTML:ValByName("M_VALOR",		    Transform(SE1->E1_VALOR, "@E 999,999,999.99"))
oHTML:ValByName("M_VCTATU",		    dTOc(SE1->E1_VENCREA))
oHTML:ValByName("M_VCTSOL",		    dTOc(dVctSol))
oHTML:ValByName("M_OBS",		    iif(dDtRefOri < Date(), "VENCIDO", ""))
oHTML:ValByName("M_CLIENTE",		SE1->E1_CLIENTE + "/" + SE1->E1_LOJA + " - " + SA1->A1_NOME)
oHTML:ValByName("M_SOLICITANTE",	AllTrim(UsrFullName(cUserName)))
oHTML:ValByName("M_MOTIVO",		    cMotivo + " - " + Tabela("Z5", cMotivo, .F.))
oHTML:ValByName("M_INFADIC",		cJustSolic)

for nX := 1 to Len(aItens)
	aAdd((oHTML:ValByName("H.DATA")),		aItens[nX,1])
	aAdd((oHTML:ValByName("H.USUARIO")),	aItens[nX,2])
	aAdd((oHTML:ValByName("H.VCTORI")),		dTOc(aItens[nX,3]))
	aAdd((oHTML:ValByName("H.VCT")),		dTOc(aItens[nX,4]))
	aAdd((oHTML:ValByName("H.VCTREA")),		dTOc(aItens[nX,5]))
	aAdd((oHTML:ValByName("H.MOTIVO")),		aItens[nX,6])
//	aAdd((oHTML:ValByName("H_JUSTIFIC")),	aItens[nX,7])
next

oHTML:ValByName("R_MAILID",	    cMailId)
oHTML:ValByName("R_AMBIENTE",	cAmbiente)

oProcess:oHTML:ValByName("proc_link", cEndServ + "/emp" + cEmpAnt + "/html/" + cMailID + ".htm")	//"proc_link" ? o nome que est? definido no html brajob15_link
oProcess:Start()

SE1->(WFSalvaID("SE1", "SE1->E1_XLINK", 	cMailId))

Return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		A23RET_BRAJOB                                                /@
@type			Static function                                              /@
@date			27/08/2020                                                   /@
@description	Retorno reposta da aprova鈬o/rejei鈬o da altera鈬o do vencto
				do t?tulo a receber.                                         /@
@author			Adalberto Moreno Batista (Op鈬o Um)                          /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function A23Ret_BRAJOB(oProcess)
Local cOpcao		:= AllTrim(oProcess:oHtml:RetByName("OPC"))
Local cFilGAMA		:= oProcess:oHtml:RetByName("FILIAL")
Local cPrefixo		:= oProcess:oHtml:RetByName("PREFIXO")
Local cNumero		:= oProcess:oHtml:RetByName("NUMERO")
Local cParcela		:= oProcess:oHtml:RetByName("PARCELA")
Local cTipo			:= oProcess:oHtml:RetByName("TIPO")
Local cAprovador	:= oProcess:oHtml:RetByName("APROVADOR")
Local cMailId		:= Substr(AllTrim(oProcess:oHtml:RetByName("WFMAILID")), 3)		//campo alimentado com a string 'WF' + o c?digo do processo
Local cDestinat, cNomeSolic, cNomeAprov, cCorpo, cAssunto, cTitulo, cAnexo, dVctAnt, dXVctOri
Private lMsErroAuto
Private dBRAVctSol	:= cTOd(oProcess:oHtml:RetByName("VCTSOL"))
Private dBRAVencto	:= cTOd(oProcess:oHtml:RetByName("VENCTO"))
Private cBRASolicit	:= oProcess:oHtml:RetByName("SOLICITANTE")
Private cBRAJustSol	:= oProcess:oHtml:RetByName("JUSTIFSOLIC")
Private cBRAMotivo	:= oProcess:oHtml:RetByName("MOTIVO")
Private cBRAJustApr	:= oProcess:oHtml:RetByName("JUSTIFICATIVA")
Private cBRAOcorren	:= oProcess:oHtml:RetByName("OCORRENCIA")

oProcess:Finish()           // FINALIZA O PROCESSO

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Preenchimento variaveis de destinatarios
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
cDestinat 	:= Alltrim(UsrRetMail(cBRASolicit))
cNomeSolic	:= Alltrim(UsrRetName(cBRASolicit))
cNomeAprov	:= AllTrim(UsrRetName(cAprovador))

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Inicio do processo
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
SM0->(dbSetOrder(1))
SM0->(dbSeek("01" + cFilGAMA))
SE1->(dbSetOrder(1))
if SE1->(dbSeek(cFilGAMA + cPrefixo + cNumero + cParcela + cTipo))

	cTitulo := SE1->(E1_PREFIXO + "-" + E1_NUM + "-" + E1_PARCELA + "-" + E1_TIPO) 

	//Verifica se o e-mail respondido, refere-se ao link ativo (quando h? nova solicita鈬o, emails s縊 enviados com uma nova codifica鈬o de controle)
	if SE1->E1_XLINK == cMailId

		if cOpcao == "APROVAR"

			dVctAnt		:= SE1->E1_VENCREA		//Informa鈬o para gravar no campo FI2_VALANT
			dXVctOri	:= iif(Empty(SE1->E1_XVCTORI), SE1->E1_VENCTO, SE1->E1_XVCTORI)
			aTitulo 	:= {	{"E1_PREFIXO",	SE1->E1_PREFIXO,			Nil},;
								{"E1_NUM",		SE1->E1_NUM,				Nil},;
								{"E1_PARCELA",	SE1->E1_PARCELA,			Nil},;
								{"E1_TIPO",		SE1->E1_TIPO,				Nil},;
								{"E1_CLIENTE",	SE1->E1_CLIENTE,			Nil},;
								{"E1_LOJA",		SE1->E1_LOJA,				Nil},;
								{"E1_XVCTORI",	dXVctOri,					Nil},;
								{"E1_VENCTO",	dBRAVencto,					Nil},;
								{"E1_VENCREA",	DataValida(dBRAVctSol),		Nil}}
			
			MsExecAuto({ |x,y| FINA040(x,y) }, aTitulo, 4)

			if lMsErroAuto

				cAssunto	:= "Ocorreu um erro ao alterar a o t?tulo " + cTitulo + " / " + AllTrim(SE1->E1_NOMCLI)
				cAnexo		:= "system\" + NomeAutoLog()
				cCorpo		:= A23GetMailBody("Necess疵io realizar nova solicita鈬o", cNomeSolic)
			
			else

				//Gravando ocorrencia banc疵ia na FI2
				if !Empty(cBRAOcorren)

					FI2->(DbSetOrder(1))	//FI2_FILIAL, FI2_CARTEI, FI2_NUMBOR, FI2_PREFIX, FI2_TITULO, FI2_PARCEL, FI2_TIPO, FI2_CODCLI, FI2_LOJCLI, FI2_OCORR, FI2_GERADO
					cChave	:=	xFilial("FI2") + "1" + SE1->(E1_NUMBOR + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA) + cBRAOcorren + "2"
					
					FI2->(RecLock('FI2', FI2->(!dbSeek(cChave))))
					FI2->FI2_FILIAL		:= xFilial("FI2")
					FI2->FI2_OCORR 		:= cBRAOcorren
					FI2->FI2_DESCOC		:= Posicione("SEB", 1, xFilial("SEB") + SE1->E1_PORTADO + Pad(FI2->FI2_OCORR, Len(SEB->EB_REFBAN)) + "E", "SEB->EB_DESCRI")
					FI2->FI2_PREFIX		:= SE1->E1_PREFIXO
					FI2->FI2_TITULO		:= SE1->E1_NUM
					FI2->FI2_PARCEL		:= SE1->E1_PARCELA
					FI2->FI2_TIPO  		:= SE1->E1_TIPO
					FI2->FI2_CODCLI		:= SE1->E1_CLIENTE
					FI2->FI2_LOJCLI		:= SE1->E1_LOJA
					FI2->FI2_GERADO		:= "2"
					FI2->FI2_NUMBOR		:= SE1->E1_NUMBOR
					FI2->FI2_CARTEI		:= "1"
					FI2->FI2_DTOCOR		:= dDataBase
					//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
					// Fixo o campo E1_VENCREA, pois ? ele quem ? alterado no processo de solicita鈬o
					// de altera鈬o de data de vencimento
					//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
					FI2->FI2_VALANT		:= dTOs(dVctAnt)
					FI2->FI2_VALNOV		:= dTOs(SE1->E1_VENCREA)
					FI2->FI2_CAMPO 		:= "E1_VENCREA"
					FI2->FI2_TIPCPO		:= "D"
					FI2->(MsUnLock())

				endif

				SE1->(WFSalvaID("SE1", "SE1->E1_XLINK", ""))
				cAssunto	:= "Altera鈬o vencimento do t?tulo " + cTitulo + " / " + AllTrim(SE1->E1_NOMCLI)
				cCorpo		:= A23GetMailBody("A data de vencimento do t?tulo " + cTitulo + " do cliente " + AllTrim(SE1->E1_NOMCLI) + " foi alterada para " + dTOc(SE1->E1_VENCREA), cNomeSolic)

			endif
			
		else

			SE1->(WFSalvaID("SE1", "SE1->E1_XLINK", ""))
			cAssunto	:= "Reprova鈬o da altera鈬o do vencimento do t?tulo " + cTitulo + " / " + AllTrim(SE1->E1_NOMCLI) 
			cCorpo		:= A23GetMailBody("A solicita鈬o para altera鈬o da data de vencimento do t?tulo " + cTitulo + " do cliente " + AllTrim(SE1->E1_NOMCLI) + " foi rejeitada.", cNomeSolic)

		endif

	else

		cDestinat 	:= Alltrim(UsrRetMail(cAprovador))
		cAssunto	:= "Aviso sobre link inativo referente ? solicita鈬o de altera鈬o de vencimento do t?tulo " + cTitulo
		cCorpo	    := A23GetMailBody("O link respondido, referente  ? solicita鈬o de altera鈬o de vencimento do t?tulo, foi inativado em raz縊 de uma nova solicita鈬o. Aguarde novo envio de e-mail para aprova鈬o.", cNomeAprov)

	endif
	
else

	cAssunto	:= "Altera鈬o de vencimento - T?tulo " + cTitulo + " n縊 encontrado. Contate o departamento de TI"
	cCorpo	    := A23GetMailBody("O t?tulo " + cTitulo + " n縊 foi localizado na base de dados. Informe o departamente de TI.", cNomeSolic)

endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Envio do e-mail de comunica鈬o
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if cCorpo <> Nil

	U_GISendMail(cDestinat,, cFilGAMA + " Filial " + AllTrim(Upper(SM0->M0_FILIAL)) + " - " + cAssunto, cCorpo, cAnexo)

endif

Return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		A23GetMailBody                                               /@
@type			Static function                                              /@
@date			31/08/2020                                                   /@
@description	Monta o corpo de e-mail para comunica鈬o com o comprador.    /@
@author			Adalberto Moreno Batista (Op鈬o Um)                          /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function A23GetMailBody(cTexto, cAlguem)
Local cMsg	:= ""

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Cria texto no formato HTML para envio do e-mail
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
cMsg += '<html>'
cMsg += '<body>'
cMsg += '<font size="3" face="Calibri">Prezado(a) ' + cAlguem + ',</font><br><br>'
cMsg += '<font size="3" face="Calibri">' + cTexto + '</font><br><br>'
if !empty(cBRAJustApr)
	cMsg += '<font size="3" face="Calibri">Justificativa: ' + cBRAJustApr + '</font><br>'
endif
cMsg += '<br><br><br>'
cMsg += '<font size="1" face="Calibri"><i>E-mail autom疸ico enviado pelo processo de workflow, Favor n縊 respond?-lo.</i></font><br><br>'
cMsg += '</body>'
cMsg += '</html>'

Return(cMsg)
