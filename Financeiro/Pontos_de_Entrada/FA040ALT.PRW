#include "protheus.ch"     
#include "rwmake.ch"

/*/
�������������������������������������������������������������������������������
@function		FA040ALT                                                     /@
@type			Ponto de entrada                                             /@
@date			30/09/2016                                                   /@
@description	Utilizado na valida��o do TudoOk, na altera��o do contas a 
				receber.                                                     /@
@author			Adalberto Moreno Batista (Op��o Um Consultoria)              /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
07/12/20 - solicitado por Jorge Job
Para ajustarmos o processo junto a GKO , teremos que desfazer o desbloqueio dos DDE e bloquear por motivo �05�  novamente  at� que a solu��o seja ajustada.
Como falamos atualmente n�o � gerado todo o arquivo pela GKO corretamente. Assim que for definido o ajuste e seja gerado o arquivo corretamente , efetuaremos o Bloqueio.
/*/
User Function FA040ALT()
Local lRet		:= .T.
Local aArea		:= GetArea()
Local aAreaSA1	:= SA1->(GetArea())
Local aAreaSF2	:= SF2->(GetArea())
Local cTpTit	:= GetMV("BR_HISTVCT", .F., "")
Local l1aAlt	:= .T.
Local cPrefixo, cNum, cParcela, cTipo, cCliente, cLoja, dVctOri, dVct, dVctRea, cMotivo, cJustific, cUsuarAlt, cSitua,cNumBor 
Local cCtrLdt	:= M->E1_XCTRLDT

//�������������������������������������������������������������������������������
// Execu��o manual
//�������������������������������������������������������������������������������
if !IsBlind()
	cPrefixo	:= M->E1_PREFIXO
	cNum		:= M->E1_NUM
	cParcela	:= M->E1_PARCELA
	cTipo		:= M->E1_TIPO
	cCliente	:= M->E1_CLIENTE
	cLoja		:= M->E1_LOJA
	dVctOri		:= M->E1_XVCTORI
	dVct		:= M->E1_VENCTO
	dVctRea		:= M->E1_VENCREA
	cMotivo		:= M->E1_XMOTALT
	cCtrLdt		:= M->E1_XCTRLDT
	cJustific	:= ""
	cUsuarAlt	:= cUserName
	cSitua      := M->E1_SITUACA
	cNumBor     := M->E1_NUMBOR

//�������������������������������������������������������������������������������
// Execu��o schedule
//�������������������������������������������������������������������������������
else
	cPrefixo	:= SE1->E1_PREFIXO
	cNum		:= SE1->E1_NUM
	cParcela	:= SE1->E1_PARCELA
	cTipo		:= SE1->E1_TIPO
	cCliente	:= SE1->E1_CLIENTE
	cLoja		:= SE1->E1_LOJA
	dVctOri		:= SE1->E1_XVCTORI
	dVct		:= SE1->E1_VENCTO
	dVctRea		:= dBRAVctSol
	cMotivo		:= cBRAMotivo
	cCtrLdt		:= dTOs(SE1->E1_VENCTO) + dTOs(SE1->E1_VENCREA)
	cJustific	:= cBRAJustSol
	cUsuarAlt	:= AllTrim(UsrRetName(cBRASolicit))
	cSitua      := SE1->E1_SITUACA
	cNumBor     := SE1->E1_NUMBOR
endif

//�������������������������������������������������������������������������������
// N�o permite altera��o de vencimento de titulos gerados pelo faturamento, cujo
// cliente tiver configura��o DDE e n�o houver registro de data de entrega
//�������������������������������������������������������������������������������
SF2->(dbSetOrder(1))		//F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, F2_TIPO
SA1->(dbSetOrder(1))		//A1_FILIAL, A1_COD, A1_LOJA
//critica retirada por solicitacao do Jorge em 07/12/20
/*if AllTrim(SE1->E1_ORIGEM) == "MATA460" .and.;
	SE1->E1_TIPO == "NF " .and.;
	!Empty(SE1->E1_SERIE) .and.;
	cCtrLdt != dTOs(M->E1_VENCTO) + dTOs(M->E1_VENCREA) .and.;
	SF2->(dbSeek(xFilial("SF2") + SE1->(E1_NUM + E1_SERIE + E1_CLIENTE + E1_LOJA))) .and.;
	Empty(SF2->F2_DTENTR) .and.;
	SA1->(dbSeek(xFilial("SA1") + SE1->(E1_CLIENTE + E1_LOJA))) .and.;
	SA1->A1_XTPVCTO == "2"

	lRet := .F.
	if !IsBlind()
		Help("", 1, "ATEN��O",, "O vencimento do t�tulo n�o poder� ser alterado pois cliente � DDE e a data de entrega da nota fiscal n�o foi preenchida." + chr(13) + chr(10) + SM0->M0_NOME, 1)
	else
		conout("O vencimento do t�tulo n�o poder� ser alterado pois cliente � DDE e a data de entrega da nota fiscal n�o foi preenchida. T�tulo: " + SE1->(E1_PREFIXO + "#" + E1_NUM + "#" + E1_PARCELA + "#" + E1_TIPO + "#" + E1_CLIENTE + "#" + E1_LOJA))
	endif
endif	
*/
//�������������������������������������������������������������������������������
// Caso a valida��o anterior seja verdadeira e seja uma altera��o de vencimento,
// analiso o motivo e dias de prorroga��o, de acordo com a situa��o do t�tulo
//�������������������������������������������������������������������������������
if lRet .and.;
	SE1->(FieldPos("E1_XVCTORI")) > 0 .and.;
	SX2->(dbSeek("ZZ2")) .and.;
	cTipo $ cTpTit .and.;
	cCtrLdt != dTOs(M->E1_VENCTO) + dTOs(M->E1_VENCREA)

	if Empty(cMotivo)
	
		lRet := .F.
		if !IsBlind()
			Help("", 1, "ATEN��O",, "� necess�rio preencher o motivo da altera��o de data quando h� altera��o dos campos de 'Vencimento' ou 'Vencto Real'." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
		else
			conout("� necess�rio preencher o motivo da altera��o de data quando h� altera��o dos campos de 'Vencimento' ou 'Vencto Real'.")
		endif
	
	else

		//verificando se executado por msexecauto ou n�o
		//Jorge solicitou em 26/11/20 para recolocar esta condi��o e n�o executar o processo quando motivo for logistica 05
		//Jorge solicitou em 07/12/20 para retirar o filtro de motivo 05
		//Jorge solicitou em 07/12/20 para incluir filtro motivo 05
		if !IsBlind() .and. cMotivo != "05"

			ZZ2->(dbSetOrder(1))			//ZZ2_FILIAL, ZZ2_PREFIX, ZZ2_NUM, ZZ2_PARCEL, ZZ2_TIPO, ZZ2_CLIENT, ZZ2_LOJA, ZZ2_DTMOV, ZZ2_HRMOV
			ZZ2->(dbSeek(xFilial("ZZ2") + SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA)))
			do while ZZ2->(!eof() .and. ZZ2_FILIAL + ZZ2_PREFIX + ZZ2_NUM + ZZ2_PARCEL + ZZ2_TIPO + ZZ2_CLIENT + ZZ2_LOJA == xFilial("ZZ2") + SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA))
				if ZZ2->ZZ2_MOTIVO != "01"	//inclus�o do titulo
					l1aAlt	:= .F.
					Exit
				endif
				ZZ2->(dbSkip())
			enddo

			//�	T�tulo vencido: o analista pode prorrogar o vencimento para o prazo m�ximo de 10 dias e uma �nica vez. Para prazo maior, deve ir um workflow para o respons�vel liberar o prazo. Na libera��o do workflow o t�tulo deve ser alterado. Portanto, o t�tulo n�o deve retornar ao analista;
			//�	T�tulo vencido e j� prorrogado: Para esse caso, deve ir um workflow para o respons�vel liberar essa prorroga��o. Na libera��o do workflow o t�tulo j� deve ser alterado. Portanto, o t�tulo n�o deve retornar ao analista;
			if Date() > SE1->E1_VENCREA
				if 	l1aAlt .and. DataValida(M->E1_VENCREA - 1, .F.) > DataValida(SE1->E1_VENCREA + 10 - 1, .T.)
					lRet := .F.
					Help("", 1, "ATEN��O",, "T�tulo vencido com ajuste superior � 10 dias do �ltimo vencimento. Solicitar autoriza��o para ajuste do vencimento." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
				elseif !l1aAlt
					lRet := .F.
					Help("", 1, "ATEN��O",, "T�tulo j� teve prorroga��o de vencimento, portanto � necess�rio solicitar apara nova altera��o." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
				endif

			//�	T�tulo n�o vencido: o analista pode prorrogar o vencimento para o prazo m�ximo de 30 dias e uma �nica vez;
			//�	T�tulo n�o vencido e j� prorrogado: Para esse caso, deve ir um workflow para o respons�vel liberar essa prorroga��o. Na libera��o do workflow o t�tulo j� deve ser alterado. Portanto, o t�tulo n�o precisa retornar ao analista.
			else

				if 	l1aAlt .and. DataValida(M->E1_VENCREA - 1, .F.) > DataValida(SE1->E1_VENCREA + 30, .T.)
					lRet := .F.
					Help("", 1, "ATEN��O",, "T�tulo com ajuste superior � 30 dias do �ltimo vencimento. Solicitar autoriza��o para ajuste do vencimento." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
				elseif !l1aAlt
					lRet := .F.
					Help("", 1, "ATEN��O",, "T�tulo j� teve prorroga��o de vencimento, portanto � necess�rio solicitar apara nova altera��o." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
				endif
			endif

		endif
				
		//Grava historico
		if lRet
			ZZ2->(RecLock("ZZ2", .T.))
			ZZ2->ZZ2_FILIAL		:= xFilial("ZZ2")
			ZZ2->ZZ2_PREFIX		:= cPrefixo
			ZZ2->ZZ2_NUM		:= cNum
			ZZ2->ZZ2_PARCEL		:= cParcela
			ZZ2->ZZ2_TIPO		:= cTipo
			ZZ2->ZZ2_CLIENT		:= cCliente
			ZZ2->ZZ2_LOJA		:= cLoja
			ZZ2->ZZ2_DTMOV		:= Date()
			ZZ2->ZZ2_HRMOV		:= Time()
			ZZ2->ZZ2_USUMOV		:= cUsuarAlt
			ZZ2->ZZ2_VENORI		:= dVctOri
			ZZ2->ZZ2_VENCTO		:= dVct
			ZZ2->ZZ2_VENREA		:= dVctRea
			ZZ2->ZZ2_MOTIVO		:= cMotivo
			ZZ2->ZZ2_JUSTIF		:= cJustific
			ZZ2->(MsUnlock())
			
			
			    	
		endif
		//Grava ocorrencia CNAB no Contas a Receber com base na Altera��o Financeira 
		//Alterador por Ronaldo Silva - 28/09/2021 - Jorge solicitou
		DbSelectArea("FI2")
	   	DbSetOrder(1)
		IF DbSeeK(XFILIAL("FI2")+cSitua+cNumBor+cPrefixo+cNum+cParcela+cTipo+cCliente+cLoja)
		   SE1->(RecLock("SE1", .F.))
		   SE1->E1_OCORREN:= FI2->FI2_OCORR
		   SE1->(MsUnlock())
		ENDIF   
	endif
		
endif

RestArea(aAreaSA1)
RestArea(aAreaSF2)
RestArea(aArea)
return(lRet)


/*/
�������������������������������������������������������������������������������
@function		MotFA040ALT                                                  /@
@type			Ponto de entrada                                             /@
@date			06/10/2016                                                   /@
@description	Validador do campo virtual E1_XMOTALT, utilizado na altera��o
				de datas de vencimento do t�tulo a receber (X3_VLDUSER)      /@
@author			Adalberto Moreno Batista (Op��o Um Consultoria)              /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
/*/
User Function MotFA040ALT()
Local lRet := .T.

if !empty(M->E1_XMOTALT)
	if M->E1_XMOTALT == "01"
		lRet := .F.
		Help("", 1, "ATEN��O",, "N�o permitido o uso do motivo '01' em altera��es de data de vencimento." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
	
	elseif SX5->(!dbSeek(xFilial("SX5") + "Z5" + M->E1_XMOTALT))
		lRet := .F.
		Help("", 1, "ATEN��O",, "Motivo de altera��o de data de vencimento n�o encontrado." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
   
	endif
endif

Return(lRet)