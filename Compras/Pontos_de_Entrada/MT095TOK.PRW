#include "rwmake.ch"
#include "protheus.ch"

/*/
�������������������������������������������������������������������������������
@function		MT095TOK                                                      /@
@date				03/05/2017                                                    /@
@type				Ponto de entrada
@description	Valida o cadastro de aprovadores de compras.                  /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Op��o Um Consultoria                                          /@
@use				Espec�fico Brasitech                                          /@
�������������������������������������������������������������������������������
/*/
User Function MT095TOK()
Local lRet			:= .T.
Local aArea			:= GetArea()
Local aAreaSAK		:= SAK->(GetArea())
//Local cNomeAprov	:= AllTrim(M->AK_NOME)
Local cTexto		:= ""
Local aAviso		:= {}
Local aCritica		:= {}
Local aSubst		:= {}
Local cCRLF			:= chr(13) + chr(10)
Local lCompart		:= .F.	//Caso verdadeiro, indica que a tabela deve ser aberta em modo compartilhado, isto �, outros processos tamb�m poder�o abrir esta tabela.
Local lLeitura		:= .F.	//Caso verdadeiro, indica que este alias ser� usado apenas para leitura de dados. Caso contr�rio, estas opera��es ser�o permitidas.
Local cQuery, cFileLog, oMemo, oDlg, nPos

SAK->(dbSetOrder(1))		//AK_FILIAL, AK_COD
	
//�������������������������������������������������������������������������
// Verifico o intervalo de bloqueio
//�������������������������������������������������������������������������
if M->AK_XBLQDE > M->AK_XBLQATE

	lRet := .F.
	Help(" ", 1, "� ATEN��O",, "A data de bloqueio inicial deve ser menor ou igual do que a data de bloqueio final." + chr(13) + chr(10) + chr(13) + chr(10) + "(Espec�fico Brasitech)", 1)
	
elseif !empty(M->AK_XBLQATE)
   
	//�������������������������������������������������������������������������������
	// Query para selecionar os grupos de aprova��o
	//�������������������������������������������������������������������������������
	cQuery	:= "SELECT * " +;
					"FROM " + RetSqlName("SAL") + " SAL " +;
					"WHERE SAL.AL_FILIAL = '" + xFilial("SAL") + "' " +;
							"AND (SAL.AL_APROV = '" + M->AK_COD + "' OR AL_XAPRSUB = '" + M->AK_COD + "')" +;
							"AND SAL.D_E_L_E_T_ = ' ' " +;
					"ORDER BY AL_COD, AL_APROV, AL_XAPRSUB"

	if Select("TEMP") > 0
		TEMP->(dbCloseArea())
	endif
	
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TEMP", lCompart, lLeitura)

	//�������������������������������������������������������������������������������
	// Valida as datas informadas
	//�������������������������������������������������������������������������������
	do while TEMP->(!eof())
	
		if TEMP->AL_APROV == M->AK_COD
			if empty(TEMP->AL_XAPRSUB)
				
				aAdd(aAviso, {TEMP->AL_COD, TEMP->AL_DESC})
				
			else
			
				if SAK->(dbSeek(xFilial("SAL") + TEMP->AL_XAPRSUB))
					if (SAK->AK_XBLQDE >= M->AK_XBLQDE .and. SAK->AK_XBLQDE <= M->AK_XBLQATE) .or.;
						(SAK->AK_XBLQATE >= M->AK_XBLQDE .and. SAK->AK_XBLQATE <= M->AK_XBLQATE) .or.;
						(M->AK_XBLQDE >= SAK->AK_XBLQDE .and. M->AK_XBLQDE <= SAK->AK_XBLQATE) .or.;
						(M->AK_XBLQATE >= SAK->AK_XBLQDE .and. M->AK_XBLQATE <= SAK->AK_XBLQATE)
						
						lRet :=.F.
						aAdd(aCritica, {TEMP->AL_COD, TEMP->AL_DESC, TEMP->AL_XAPRSUB, SAK->AK_NOME, .T.})
					
					else
					
						aAdd(aSubst, {TEMP->AL_COD, TEMP->AL_DESC, TEMP->AL_XAPRSUB, SAK->AK_NOME, .T.})
						
					endif
					
				endif
				
			endif
			
		elseif TEMP->AL_XAPRSUB == M->AK_COD
		
			if SAK->(dbSeek(xFilial("SAK") + TEMP->AL_APROV))
				if (SAK->AK_XBLQDE >= M->AK_XBLQDE .and. SAK->AK_XBLQDE <= M->AK_XBLQATE) .or.;
					(SAK->AK_XBLQATE >= M->AK_XBLQDE .and. SAK->AK_XBLQATE <= M->AK_XBLQATE) .or.;
					(M->AK_XBLQDE >= SAK->AK_XBLQDE .and. M->AK_XBLQDE <= SAK->AK_XBLQATE) .or.;
					(M->AK_XBLQATE >= SAK->AK_XBLQDE .and. M->AK_XBLQATE <= SAK->AK_XBLQATE)
						
					lRet :=.F.
					aAdd(aCritica, {TEMP->AL_COD, TEMP->AL_DESC, TEMP->AL_APROV, SAK->AK_NOME, .F.})

				else
					
					aAdd(aSubst, {TEMP->AL_COD, TEMP->AL_DESC, TEMP->AL_XAPRSUB, SAK->AK_NOME, .F.})
						
				endif
			endif
		
		endif
		
	   TEMP->(dbSkip())
	enddo

	//�������������������������������������������������������������������������������
	// Monta as mensagens a serem apresentadas
	//�������������������������������������������������������������������������������
	if Len(aAviso) > 0
		cTexto += "INFORMA��O: O aprovador " + AllTrim(M->AK_NOME) + " n�o possui um substituto nos grupos de aprova��o listados abaixo e por este motivo n�o haver� aprova��o para o respectivo n�vel/aprovador. O registro ser� gravado, por�m verifique se esta configura��o est� correta." + cCRLF
		for nPos := 1 to Len(aAviso)
			cTexto += aAviso[nPos,1] + " - " + AllTrim(aAviso[nPos,2]) + cCRLF
		next
		cTexto += Replicate("-", 128) + cCRLF
	endif

	for nPos := 1 to Len(aCritica)
		cTexto += "CR�TICA: A faixa de bloqueio informada, sobrep�e a faixa de bloqueio do aprovador " + iif(aCritica[nPos,5], "substituto ", "substituido ") +;
					 aCritica[nPos,3] + " - " + AllTrim(aCritica[nPos,4]) + ", no grupo de aprova��o " + aCritica[nPos,1] + " - " + AllTrim(aCritica[nPos,2]) +;
					 ". Processo n�o ser� conclu�do." + cCRLF
		cTexto += Replicate("-", 128) + cCRLF
	next

	for nPos := 1 to Len(aSubst)
		cTexto += "INFORMA��O: O aprovador � substituto e/ou substituido nos grupos de aprova��o listados abaixo. Verifique se est�o corretos." + cCRLF +;
					 "Grupo " + aSubst[nPos,1] + " - " + AllTrim(aSubst[nPos,2]) + " " + iif(aSubst[nPos,5], "substituido por ", "substituto de ")+;
					 aSubst[nPos,3] + " - " + AllTrim(aSubst[nPos,4]) + cCRLF
		cTexto += Replicate("-", 128) + cCRLF
	next

	
	//�������������������������������������������������������������������������������
	// Apresenta as mensagens
	//�������������������������������������������������������������������������������
	if !empty(cTexto)

		cFileLog := CriaTrab( ,.F.) + ".log"
		MemoWrite(cFileLog, cTexto)

		Define Font oFont Name "Arial" Size 5, 12	//Mono AS

		Define MsDialog oDlg Title "Rela��o de cr�ticas" From 3, 0 to 340, 417 Pixel

		@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
		oMemo:bRClicked := { || AllwaysTrue() }
		oMemo:oFont     := oFont
		Define SButton From 153, 175 Type  1 Action (oDlg:End()) Enable Of oDlg Pixel

		Activate MsDialog oDlg Center
		fErase(cFileLog)
   endif


endif

RestArea(aAreaSAK)
RestArea(aArea)
Return(lRet)

