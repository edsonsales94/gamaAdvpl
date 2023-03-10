#include "rwmake.ch"
#include "protheus.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		MTALCALT                                                     /@
@date			25/04/2017                                                   /@
@type			Ponto de entrada                                             /@
@description	Utilizado para alterar registros SCR, ap?s sua grava鈬o.     /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Op鈬o Um Consultoria                                         /@
@use			Espec?fico Brasitech                                         /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
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

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Somente para pedidos de compras
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if cTipo $ "PC/AE"

	//SAL->(dbSetOrder(3))		//AL_FILIAL, AL_COD, AL_APROV
	SCR->(dbSetOrder(1))		//CR_FILIAL, CR_TIPO, CR_NUM, CR_NIVEL

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Executado para VISTORES
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	if SAL->AL_LIBAPR == "V"

		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		// Se o aprovador estiver bloqueado, verifico se h? um substituto.
		// Se houver, troco o codigo, sen縊 apago o registro de aprova鈬o
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
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

					//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
					// Verifico se o aprovador substituto ? de mais de um aprovador, no mesmo 
					// n?vel. Considero somente um deles.
					//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
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

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Executado para APROVADORES
	// identificando o respons疱eis pelos departamentos
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	else

		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		// Verificando se a linha possui um aprovador respons疱el
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		if !Empty(SAL->AL_XRESPON)
			cRespon     := SAL->AL_XRESPON
		endif

		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		// Verificando se respons疱el est? bloqueado temporariamente, mas somente
		// se houver aprovador substituto informado
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		SAK->(dbSetOrder(1))		//AK_FILIAL, AK_COD
		if SAK->(dbSeek(xFilial("SAK") + cRespon))
			if dDataBase >= SAK->AK_XBLQDE .and. dDataBase <= SAK->AK_XBLQATE .and. !Empty(SAK->AK_XSUBST)
				cRespon := SAK->AK_XSUBST
			endif
		endif

		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		// Posicionando o cadastro do aprovador com o codigo do respons疱el
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		SAK->(MsSeek(xFilial("SAK") + cRespon))

		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		// Atualizando os c?digos de aprovador e usu疵io do respons疱el pelo
		// departamento
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
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
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		GETAPRUSER                                                   /@
@date			03/05/2017                                                   /@
@type			Static Function                                              /@
@description	Retorna o c?digo de usu疵io de um aprovador de compras.      /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Op鈬o Um Consultoria                                         /@
@use			Espec?fico Brasitech                                         /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
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
