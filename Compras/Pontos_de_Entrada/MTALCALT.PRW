#include "rwmake.ch"
#include "protheus.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		MTALCALT                                                     /@
@date			25/04/2017                                                   /@
@type			Ponto de entrada                                             /@
@description	Utilizado para alterar registros SCR, após sua gravação.     /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Consultoria                                         /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MTALCALT()
Local aArea			:= GetArea()
Local aAreaSCR		:= SCR->(GetArea())
Local aAreaSAK		:= SAK->(GetArea())
//Local aAreaSAL		:= SAL->(GetArea())
//Local cNivel		:= SCR->CR_NIVEL
Local cPedido		:= SCR->CR_NUM
Local cTipo			:= SCR->CR_TIPO
Local cRespon		:= SCR->CR_APROV
//Local cGrupo		:= SAL->AL_COD
Local cUserSubs	:= ""
Local aExcSubs		:= {}

//—————————————————————————————————————————————————————————————————————————
// Somente para pedidos de compras
//—————————————————————————————————————————————————————————————————————————
if cTipo $ "PC/AE"

	//SAL->(dbSetOrder(3))		//AL_FILIAL, AL_COD, AL_APROV
	SCR->(dbSetOrder(1))		//CR_FILIAL, CR_TIPO, CR_NUM, CR_NIVEL

	//—————————————————————————————————————————————————————————————————————————
	// Executado para VISTORES
	//—————————————————————————————————————————————————————————————————————————
	if SAL->AL_LIBAPR == "V"

		//—————————————————————————————————————————————————————————————————————————
		// Se o aprovador estiver bloqueado, verifico se há um substituto.
		// Se houver, troco o codigo, senão apago o registro de aprovação
		//—————————————————————————————————————————————————————————————————————————
		SAK->(dbSetOrder(2))		//AK_FILIAL, AK_USER
		if SAK->(dbSeek(xFilial("SAK") + SCR->CR_USER))

			if (dDataBase >= SAK->AK_XBLQDE .and. dDataBase <= SAK->AK_XBLQATE)
			
				if empty(SAK->AK_XSUBST)
				
					SCR->(RecLock("SCR", .F.))
					SCR->(dbDelete())
					SCR->(MsUnLock())
					
				else
				
					cUserSubs	:= GetAprUser(SAK->AK_XSUBST)
					SCR->(RecLock("SCR", .F.))
					SCR->CR_USERORI		:= SCR->CR_USER
					SCR->CR_APRORI		:= SCR->CR_APROV
					SCR->CR_APROV		:= SAK->AK_XSUBST
					SCR->CR_USER		:= cUserSubs
					SCR->(MsUnLock())				
					
				endif
				
			endif

					//—————————————————————————————————————————————————————————————————————————
					// Verifico se o aprovador substituto é de mais de um aprovador, no mesmo 
					// nível. Considero somente um deles.
					//—————————————————————————————————————————————————————————————————————————
					//SCR->(dbSeek(xFilial("SCR") + cTipo + cPedido + cNivel))
					//do while SCR->(!eof() .and. CR_FILIAL + CR_TIPO + CR_NUM + CR_NIVEL == xFilial("SCR") + cTipo + cPedido + cNivel)
					SCR->(dbSeek(xFilial("SCR") + cTipo + cPedido))
					do while SCR->(!eof() .and. CR_FILIAL + CR_TIPO + CR_NUM == xFilial("SCR") + cTipo + cPedido)

						//if Empty(aScan(aExcSubs, SCR->CR_USER))
						if (Empty(SCR->CR_XRESPUS) .and. Empty(aScan(aExcSubs, SCR->CR_USER))) .or.;
							(!Empty(SCR->CR_XRESPUS) .and. Empty(aScan(aExcSubs, SCR->CR_XRESPUS)))

							aAdd(aExcSubs, iif(Empty(SCR->CR_XRESPUS), SCR->CR_USER, SCR->CR_XRESPUS))
						else
							SCR->(RecLock("SCR", .F.))
							SCR->(dbDelete())
							SCR->(MsUnLock())
						endif
						SCR->(dbSkip())
					enddo


		endif

	//—————————————————————————————————————————————————————————————————————————
	// Executado para APROVADORES
	// identificando o responsáveis pelos departamentos
	//—————————————————————————————————————————————————————————————————————————
	else

		//—————————————————————————————————————————————————————————————————————————
		// Verificando se a linha possui um aprovador responsável
		//—————————————————————————————————————————————————————————————————————————
		if !Empty(SAL->AL_XRESPON)
			cRespon     := SAL->AL_XRESPON
		endif

		//—————————————————————————————————————————————————————————————————————————
		// Verificando se responsável está bloqueado temporariamente, mas somente
		// se houver aprovador substituto informado
		//—————————————————————————————————————————————————————————————————————————
		SAK->(dbSetOrder(1))		//AK_FILIAL, AK_COD
		if SAK->(dbSeek(xFilial("SAK") + cRespon))
			if dDataBase >= SAK->AK_XBLQDE .and. dDataBase <= SAK->AK_XBLQATE .and. !Empty(SAK->AK_XSUBST)
				cRespon := SAK->AK_XSUBST
			endif
		endif

		//—————————————————————————————————————————————————————————————————————————
		// Posicionando o cadastro do aprovador com o codigo do responsável
		//—————————————————————————————————————————————————————————————————————————
		SAK->(MsSeek(xFilial("SAK") + cRespon))

		//—————————————————————————————————————————————————————————————————————————
		// Atualizando os códigos de aprovador e usuário do responsável pelo
		// departamento
		//—————————————————————————————————————————————————————————————————————————
		SCR->(RecLock("SCR", .F.))
		SCR->CR_XRESP	:= cRespon
		SCR->CR_XRESPUS	:= SAK->AK_USER
		SCR->CR_XNOMRES	:= SAK->AK_NOME
		SCR->(MsUnLock())

	endif

endif

RestArea(aAreaSCR)
RestArea(aAreaSAK)
//RestArea(aAreaSAL)
RestArea(aArea)
Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		GETAPRUSER                                                   /@
@date			03/05/2017                                                   /@
@type			Static Function                                              /@
@description	Retorna o código de usuário de um aprovador de compras.      /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Consultoria                                         /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function GetAprUser(cCodigo)
Local cRet		:= ""
Local aArea		:= GetArea()
Local aAreaSAK	:= SAK->(GetArea())

SAK->(dbSetOrder(1))		//AK_FILIAL, AK_COD
if SAK->(dbSeek(xFilial("SAK") + cCodigo))
	cRet := SAK->AK_USER
endif

RestArea(aAreaSAK)
RestArea(aArea)
Return(cRet)
