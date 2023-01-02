#include "rwmake.ch"
#include "protheus.ch"
#include "totvs.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		F040BUT                                                      /@
@type			Ponto de entrada                                             /@
@date			30/09/2016                                                   /@
@description	Adiciona botões na funcao de titulos a receber FINA040.      /@
@author			Adalberto Moreno Batista (Opção Um Consultoria)              /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function F040BUT() 
Local aButtons := {} 

//———————————————————————————————————————————————————————————————————————————————
// Adiciona botão para consulta de histórico de alterações de datas de vencimento
// Por: Adalberto Moreno Batista (Opção Um Consultoria) em 30/09/2016
//———————————————————————————————————————————————————————————————————————————————
if SE1->(FieldPos("E1_XVCTORI")) > 0 .and. SX2->(dbSeek("ZZ2")) .and. !INCLUI
	aAdd(aButtons, {"S4WB005N", {||U_A_F040()}, "® Hist.Dt.Vcto"})
	aAdd(aButtons, {"S4WB005N", {||U_B_F040()}, "® Solicit Autoriz"})
endif

Return(aButtons)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		A_F040                                                       /@
@type			User function                                                /@
@date			30/09/2016                                                   /@
@description	Acionada pela user function F040BUT e FI040ROT.
				Monta tela de consulta com histórico das alterações de datas
				de vencimento de títulos a receber.                          /@
@author			Adalberto Moreno Batista                                     /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function A_F040()
Local aArea	 		:= GetArea()
Local aAreaSX3		:= SX3->(GetArea())
Local aC  			:= {}
Local aCGD			:= {135,1,190,300}
Local cTitulo		:= "Consulta de histórico de alterações de vencimento"
Local aSize 		:= MsAdvSize()
Local nK, nUsado, cMacroSubst
Private aCols		:= {}
Private aHeader		:= {}

//———————————————————————————————————————————————————————————————————————
// Pesquisando dados do historico
//———————————————————————————————————————————————————————————————————————
ZZ2->(dbSetOrder(1))		//ZZ2_FILIAL, ZZ2_PREFIX, ZZ2_NUM, ZZ2_PARCEL, ZZ2_TIPO, ZZ2_CLIENT, ZZ2_LOJA, ZZ2_DTMOV, ZZ2_HRMOV
if ZZ2->(dbSeek(xFilial("ZZ2") + SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA)))

	//———————————————————————————————————————————————————————————————————————
	// Monta array aHeader
	//———————————————————————————————————————————————————————————————————————
	SX3->(dbSetOrder(1))
	SX3->(dbSeek("ZZ2"))
	do while SX3->(!eof() .and. X3_ARQUIVO == "ZZ2")
		if AllTrim(SX3->X3_CAMPO) $ "ZZ2_DTMOV/ZZ2_HRMOV/ZZ2_USUMOV/ZZ2_VENORI/ZZ2_VENCTO/ZZ2_VENREA/ZZ2_MOTIVO/ZZ2_DESMOT"
			SX3->(aAdd(aHeader, {	AllTrim(X3_TITULO),;
									X3_CAMPO,;
									X3_PICTURE,;
									X3_TAMANHO,;
									X3_DECIMAL,;
									X3_VLDUSER,;
									X3_USADO,;
									X3_TIPO,;
									X3_ARQUIVO,;
									X3_CONTEXT,;
									X3_RELACAO} ))
		endif
		SX3->(dbSkip())
	enddo
	
	nUsado := Len(aHeader)
	
	//———————————————————————————————————————————————————————————————————————
	// Alimenta o aCols para a apresentação das informações
	//———————————————————————————————————————————————————————————————————————
	do while ZZ2->(!eof() .and. ZZ2_FILIAL + ZZ2_PREFIX + ZZ2_NUM + ZZ2_PARCEL + ZZ2_TIPO + ZZ2_CLIENT + ZZ2_LOJA == xFilial("ZZ2") + SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA))
		aAdd(aCols, Array(nUsado + 1))
		For nK := 1 to nUsado
			if aHeader[nK,10] == "V"	//Virtual
				cMacroSubst				:= AllTrim(aHeader[nK,11])
				aCols[Len(aCols),nK]	:= &cMacroSubst
			else
				aCols[Len(aCols),nK]	:= ZZ2->(FieldGet(FieldPos(aHeader[nK,2])))
			endif
		Next
		aCols[Len(aCols), nUsado + 1]	:= .F.
	
		ZZ2->(dbSkip())
	enddo

	Modelo2(cTitulo, aC, {}, aCGD, 2,,,,,,, {aSize[7], 0, aSize[6] -50, aSize[5] - 500})
	
else

	Help(" ", 1, "ATENÇÃO",, "Não foram encontrados históricos para este título." + chr(13) + chr(10) + "Específico " + AllTrim(SM0->M0_NOME), 1)
	
endif

//———————————————————————————————————————————————————————————————————————
// Restaura ambiente
//———————————————————————————————————————————————————————————————————————
RestArea(aAreaSX3)
RestArea(aArea)
Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		B_F040                                                       /@
@type			User function                                                /@
@date			20/08/2020                                                   /@
@description	Acionada pela user function F040BUT.
				Cria tela para solicitação da autorização da alteração da
				data de vencimento do titulo a receber.                      /@
@author			Adalberto Moreno Batista                                     /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
07/12/20 - solicitado por Jorge Job
Para ajustarmos o processo junto a GKO , teremos que desfazer o desbloqueio dos DDE e bloquear por motivo “05”  novamente  até que a solução seja ajustada.
Como falamos atualmente não é gerado todo o arquivo pela GKO corretamente. Assim que for definido o ajuste e seja gerado o arquivo corretamente , efetuaremos o Bloqueio.
/*/
User Function B_F040()
Local aArea			:= GetArea()
Local aAreaSA1		:= SA1->(GetArea())
Local aAreaSF2		:= SF2->(GetArea())
Local cTitulo		:= SE1->(E1_PREFIXO + "-" + E1_NUM + "-" + E1_PARCELA + "-" + E1_TIPO)
Local cCliente		:= SE1->("("+E1_CLIENTE + "/" + E1_LOJA + ") " + E1_NOMCLI)
Local dVctEmi		:= SE1->E1_EMISSAO
Local dVctOri		:= iif(Empty(SE1->E1_XVCTORI), SE1->E1_VENCTO, SE1->E1_XVCTORI)
Local dVencto		:= M->E1_VENCTO
Local dVctAtu		:= SE1->E1_VENCREA
Local dVctSol		:= M->E1_VENCREA
Local cMotivo		:= M->E1_XMOTALT
Local cDescMot		:= Left(Tabela("Z5", cMotivo, .F.), 30)
Local cJustSolic	:= ""
Local cGestor		:= GetMV("BR_VCTOSE1", .F., "SEM")
Local cOcorrencia	:= "  "
Local oTitulo, oCliente, oVctEmi, oVctOri, oVctAtu, oVctSol, oMotivo, oJustSolic, oCNAB
Private oDlg

if SE1->(FieldPos("E1_XLINK")) == 0 .or. ZZ2->(FieldPos("ZZ2_JUSTIF")) == 0 .or. cGestor == "SEM"
	Alert("Necessário criar os campos E1_XLINK (C20), ZZ2_JUSTIF (M10) e parametro BR_VCTOSE1 para utilizar esta funcionalidade.")
	Return()
endif

//———————————————————————————————————————————————————————————————————————————————
// Não permite acionar a solicitação de alteração de vencimento para titulos
// gerados pelo faturamento, cujo cliente tiver configuração DDE e não houver 
// registro de data de entrega
//———————————————————————————————————————————————————————————————————————————————
SF2->(dbSetOrder(1))		//F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, F2_TIPO
SA1->(dbSetOrder(1))		//A1_FILIAL, A1_COD, A1_LOJA
//retirada critica por solicitacao do Jorge em 07/12/20
/*if AllTrim(SE1->E1_ORIGEM) == "MATA460" .and.;
	SE1->E1_TIPO == "NF " .and.;
	!Empty(SE1->E1_SERIE) .and.;
	SF2->(dbSeek(xFilial("SF2") + SE1->(E1_NUM + E1_SERIE + E1_CLIENTE + E1_LOJA))) .and.;
	Empty(SF2->F2_DTENTR) .and.;
	SA1->(dbSeek(xFilial("SA1") + SE1->(E1_CLIENTE + E1_LOJA))) .and.;
	SA1->A1_XTPVCTO == "2"

	Help("", 1, "ATENÇÃO",, "Não é permitida solicitação de alteração de vencimento para titulos cujo cliente seja DDE e a data de entrega da nota fiscal não tiver sido preenchida." + chr(13) + chr(10) + SM0->M0_NOME, 1)

else*/

	Define MsDialog oDlg Title OemtoAnsi("Informações do Título") FROM C(227),C(195) TO C(597-47),C(731-6) PIXEL

		// Cria Componentes Padroes do Sistema
		@ C(005),C(005) Say "Titulo" Size C(015),C(008) Color CLR_BLACK Pixel Of oDlg
		@ C(005),C(082) Say "Cliente" Size C(018),C(008) Color CLR_BLACK Pixel Of oDlg
		@ C(012),C(005) MsGet oTitulo Var cTitulo When .F. Size C(072),C(009) Color CLR_BLACK Pixel Of oDlg
		@ C(012),C(082) MsGet oCliente Var cCliente When .F. Size C(180),C(009) Color CLR_BLACK Pixel Of oDlg
		@ C(030),C(005) Say "Emissão" Size C(021),C(008) Color CLR_BLACK Pixel Of oDlg
		@ C(030),C(050) Say "Vencto Original" Size C(038),C(008) Color CLR_BLACK Pixel Of oDlg
		@ C(030),C(095) Say "Vencto Atual" Size C(032),C(008) Color CLR_BLACK Pixel Of oDlg
		@ C(030),C(140) Say "Vencto Solicitado" Size C(043),C(008) Color CLR_BLUE Pixel Of oDlg
		@ C(037),C(005) MsGet oVctEmi Var dVctEmi When .F. Size C(036),C(009) Color CLR_BLACK Pixel Of oDlg
		@ C(037),C(050) MsGet oVctOri Var dVctOri When .F. Size C(036),C(009) Color CLR_BLACK Pixel Of oDlg
		@ C(037),C(095) MsGet oVctAtu Var dVctAtu When .F. Size C(036),C(009) Color CLR_BLACK Pixel Of oDlg
		@ C(037),C(140) MsGet oVctSol Var dVctSol Valid VlVctBF040(@dVctSol) Size C(036),C(009) Color CLR_BLUE Pixel Of oDlg
		@ C(055),C(005) Say "Motivo" Size C(018),C(008) Color CLR_BLUE Pixel Of oDlg
		@ C(062),C(005) MsGet oMotivo Var cMotivo F3 "Z5" Valid VlMotBF040(cMotivo, @cDescMot) Size C(016),C(009) Color CLR_BLUE Pixel Of oDlg
		@ C(062),C(025) MsGet oDescMot Var cDescMot When .F. Size C(150),C(009) Color CLR_BLUE Pixel Of oDlg
		@ C(055),C(190) Say "Ocorrência CNAB" Size C(038),C(008) Color CLR_BLUE Pixel Of oDlg
		@ C(062),C(190) MsGet oCNAB Var cOcorrencia When !Empty(SE1->E1_NUMBOR) F3 "SEB" Valid ExistCpo("SEB", SE1->E1_PORTADO + Pad(cOcorrencia, Len(SEB->EB_REFBAN)) + "E") Size C(016),C(009) Color CLR_BLUE Pixel Of oDlg
		@ C(080),C(005) Say "Informações adicionais" Size C(056),C(008) Color CLR_BLUE Pixel Of oDlg
		@ C(087),C(005) Get oJustSolic Var cJustSolic MEMO Size C(254),C(044) Color CLR_BLUE Pixel Of oDlg
		@ C(140),C(200) Button OemtoAnsi("Solicita aprovação") Size C(055),C(012) Pixel Of oDlg Action(VldTdOk(dVctSol, cMotivo, cJustSolic, !Empty(SE1->E1_NUMBOR), cOcorrencia, dVencto))

	Activate MsDialog oDlg Centered 

//endif

RestArea(aAreaSA1)
RestArea(aAreaSF2)
RestArea(aArea)
Return()


	/*/
	———————————————————————————————————————————————————————————————————————————————
	@function		VLVCTBF040                                                   /@
	@type			Static function                                              /@
	@date			20/08/2020                                                   /@
	@description	Validação da data de vencimento.                             /@
	@author			Adalberto Moreno Batista                                     /@
	@use			Brasitech                                                    /@
	———————————————————————————————————————————————————————————————————————————————
	/*/
	Static Function VlVctBF040(dVctSol)
	Local lRet		:= .T.
	Local l1aAlt	:= .T.

	dVctSol := DataValida(dVctSol, .T.)

	ZZ2->(dbSetOrder(1))		//ZZ2_FILIAL, ZZ2_PREFIX, ZZ2_NUM, ZZ2_PARCEL, ZZ2_TIPO, ZZ2_CLIENT, ZZ2_LOJA, ZZ2_DTMOV, ZZ2_HRMOV
	ZZ2->(dbSeek(xFilial("ZZ2") + SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA)))
	do while ZZ2->(!eof() .and. ZZ2_FILIAL + ZZ2_PREFIX + ZZ2_NUM + ZZ2_PARCEL + ZZ2_TIPO + ZZ2_CLIENT + ZZ2_LOJA == xFilial("ZZ2") + SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA))
		if ZZ2->ZZ2_MOTIVO != "10"	//inclusão do titulo
			l1aAlt	:= .F.
			Exit
		endif
		ZZ2->(dbSkip())
	enddo

	if dVctSol < SE1->E1_EMISSAO .or. dVctSol < Date()
		lRet := .F.
		Help("", 1, "ATENÇÃO",, "Data de vencimento deve ser maior que a data de emissão e não pode ser menor que a data atual." + chr(13) + chr(10) + "Específico " + AllTrim(SM0->M0_NOME), 1)

	//———————————————————————————————————————————————————————————————————————————————
	// Título vencido: o analista pode prorrogar o vencimento para o prazo máximo de
	//      10 dias e uma única vez. Para prazo maior, deve ir uow para o 
	//      responsável liberar o prazo. Na liberaçãkflow o título deve ser
	//      alterado. Portanto, o título não deve retornar ao analista;
	// Título vencido e já prorrogado: Para esse caso, deve irflow para o 
	//       responsável liberar essa prorrogação. Na liberaçrkflow o título
	//       já deve ser alterado. Portanto, o título não deve retornar ao analista
	//———————————————————————————————————————————————————————————————————————————————
	elseif SE1->E1_VENCREA > Date()
		if 	l1aAlt .and. DataValida(dVctSol - 1, .F.) <= DataValida(SE1->E1_VENCREA + 10, .T.)
			lRet := .F.
			Help("", 1, "ATENÇÃO",, "Não há necessidade de solicitar autorização. Título vencido com ajuste permitido de até à 7 dias do vencimento real." + chr(13) + chr(10) + "Específico " + AllTrim(SM0->M0_NOME), 1)
		endif

	//———————————————————————————————————————————————————————————————————————————————
	// Título não vencido: o analista pode prorrogar o vencimento para o prazo máximo
	//      de 30 dias e uma única vez;
	// Título não vencido e já prorrogado: Para esse caso, deve rkflow para o
	//      responsável liberar essa prorrogação. Na liberaçrkflow o título
	//      já deve ser alterado. Portanto, o título não precisa retornar ao analista
	//———————————————————————————————————————————————————————————————————————————————
	elseif SE1->E1_VENCREA <= Date()
		if 	l1aAlt .and. DataValida(dVctSol - 1, .F.) <= DataValida(SE1->E1_VENCREA + 30, .T.)
			lRet := .F.
			Help("", 1, "ATENÇÃO",, "Não há necessidade de solicitar autorização. Título com ajuste permitido de até 30 dias do vencimento real." + chr(13) + chr(10) + "Específico " + AllTrim(SM0->M0_NOME), 1)
		endif
	endif

	Return(lRet)


	/*/
	———————————————————————————————————————————————————————————————————————————————
	@function		VLMOTBF040                                                   /@
	@type			Static function                                              /@
	@date			20/08/2020                                                   /@
	@description	Validação do motivo da alteração do vencimento.              /@
	@author			Adalberto Moreno Batista                                     /@
	@use			Brasitech                                                    /@
	———————————————————————————————————————————————————————————————————————————————
	/*/
	Static Function VlMotBF040(cMotivo, cDescMot)
	Local lRet		:= .T.
	SX5->(dbSetOrder(1))
	if SX5->(dbSeek(xFilial("SX5") + "Z5" + cMotivo))
		if cMotivo == '01'
			lRet := .F.
			Help("", 1, "ATENÇÃO",, "Motivo não permitido!" + chr(13) + chr(10) + "Específico " + AllTrim(SM0->M0_NOME), 1)
		else
			cDescMot := SX5->X5_DESCRI
		endif
	else
		lRet := .F.
		Help("", 1, "ATENÇÃO",, "Motivo não encontrado!" + chr(13) + chr(10) + "Específico " + AllTrim(SM0->M0_NOME), 1)
	endif
	Return(lRet)


	/*/
	———————————————————————————————————————————————————————————————————————————————
	@function		VLDTDOK                                                      /@
	@type			Static function                                              /@
	@date			20/08/2020                                                   /@
	@description	Valida o fechamento da tela e envia a solicitação.           /@
	@author			Adalberto Moreno Batista                                     /@
	@use			Brasitech                                                    /@
	———————————————————————————————————————————————————————————————————————————————
	/*/
	Static Function VldTdOk(dVctSol, cMotivo, cJustSolic, lCNAB, cOcorrencia, dVencto)
	Local lRet		:= .T.
	Local lEnvia	:= .T.

	if Empty(cMotivo) .or. Empty(dVctSol)
		lRet := .F.
		Help("", 1, "ATENÇÃO",, "Obrigatório o preenchimento da data de vencimento e do motivo!" + chr(13) + chr(10) + "Específico " + AllTrim(SM0->M0_NOME), 1)
	elseif (lCNAB .and. Empty(cOcorrencia))
		lRet := .F.
		Help("", 1, "ATENÇÃO",, "Título encontra-se em um Borderô, portanto será necessário preencher a OCORRENCIA CNAB!" + chr(13) + chr(10) + "Específico " + AllTrim(SM0->M0_NOME), 1)
	else
		if !Empty(SE1->E1_XLINK)
			if !MsgBox("Há um e-mail já enviado e pendente de resposta. Ao enviar outra solicitação, o anterior é anulado prevalecendo esta nova solicitação. Deseja enviar nova solicitação?", "Pergunta", "YESNO")
				lEnvia := .F.
				MsgBox("Processo interrompido, portanto a solicitação não será enviada", "Alerta", "ERRO")
			endif
		endif
		
		if lEnvia
			U_A23_EnvAprov_BRAJOB(dVctSol, cMotivo, cJustSolic, RetCodUsr(), lCNAB, cOcorrencia, dVencto)
			MsgBox("Enviada solicitação para aprovação da alteração do título. Aguarde o retorno.", "Informação", "INFO")
		endif
	endif

	if lRet
		Close(oDlg)
	endif
	Return(lRet)


	/*/
	———————————————————————————————————————————————————————————————————————————————
	@function		C                                                            /@
	@type			Static function                                              /@
	@date			20/08/2020                                                   /@
	@description	Funcao responsavel por manter o Layout independente da 
					resolução horizontal do Monitor do Usuario.                  /@
	@author			                                                             /@
	@use			Brasitech                                                    /@
	———————————————————————————————————————————————————————————————————————————————
	/*/
	Static Function C(nTam)                                                         
	Local nHRes	:=	oMainWnd:nClientWidth	//Resolucao horizontal do monitor      
	Do Case                                                                         
		Case nHRes == 640	//Resolucao 640x480                                         
			nTam *= 0.8                                                                
		Case nHRes == 800	//Resolucao 800x600                                         
			nTam *= 1                                                                  
		OtherWise			//Resolucao 1024x768 e acima                                
			nTam *= 1.28                                                               
	EndCase

	Return Int(nTam)
