#include "rwmake.ch"
#include "protheus.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		MT120F                                                       /@
@date			15/10/2014                                                   /@
@type			Ponto de entrada
@description	Após a gravação dos itens do pedido de compras, no final da 
				função A120GRAVA, pode ser usado para manipular os dados 
				gravados do pedido de compras na tabela SC7, recebe como 
				parametro a filial e numero do pedido.                       /@
@parameters		PARAMIXB- Caracter, filial mais o numero do pedido de compras/@
@return			Nil                                                          /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Tecnologia da Informação                            /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MT120F()
Local cFilNumPed := PARAMIXB
      
//———————————————————————————————————————————————————————————————————————————————
// As variáveis cGI120ForPag, cGI120ObsGer, cGI120Bco, cGI120Age, cGI120DVAGE,
// cGI120Cta e cGI120DVCta são públicas e foram definidas nos pontos de entrada 
// MT120TEL e MT120FOL
//———————————————————————————————————————————————————————————————————————————————
if SC7->(FieldPos("C7_X_FORPG")) > 0 .and. SC7->(FieldPos("C7_X_OBSGE")) > 0

	SC7->(dbSetOrder(1))
	SC7->(dbSeek(cFilNumPed))
	
	do while SC7->(!eof() .and. C7_FILIAL + C7_NUM == cFilNumPed)

		SC7->(RecLock("SC7",.F.))
	
		if SC7->(FieldPos("C7_X_FORPG")) > 0 .and. Type("cGI120ForPag") != "U"
			SC7->C7_X_FORPG := Left(cGI120ForPag, 1)
		endif
		if SC7->(FieldPos("C7_X_OBSGE")) > 0 .and. Type("cGI120ObsGer") != "U"
			SC7->C7_X_OBSGE := cGI120ObsGer
		endif

		if SC7->(FieldPos("C7_XCONSUM")) > 0 .and. Type("cGI120Consum") != "U"
			SC7->C7_XCONSUM := cGI120Consum
		endif

		if SC7->(FieldPos("C7_XCPF")) > 0 .and. Type("cGI120CPF") != "U"
			SC7->C7_XCPF := cGI120CPF
		endif

		if SC7->(FieldPos("C7_XBANCO")) > 0 .and. Type("cGI120Bco") != "U"
			SC7->C7_XBANCO := cGI120Bco
		endif

		if SC7->(FieldPos("C7_XAGENC")) > 0 .and. Type("cGI120Age") != "U"
			SC7->C7_XAGENC := cGI120Age
		endif

		if SC7->(FieldPos("C7_XDVAGE")) > 0 .and. Type("cGI120DVAge") != "U"
			SC7->C7_XDVAGE := cGI120DVAge
		endif

		if SC7->(FieldPos("C7_XCONTA")) > 0 .and. Type("cGI120Cta") != "U"
			SC7->C7_XCONTA := cGI120Cta
		endif

		if SC7->(FieldPos("C7_XDVCTA")) > 0 .and. Type("cGI120DVCta") != "U"
			SC7->C7_XDVCTA := cGI120DVCta
		endif

		if SC7->(FieldPos("C7_XMOTALT")) > 0 .and. Type("cGI120MotAlt") != "U"
			SC7->C7_XMOTALT := cGI120MotAlt
		endif

		SC7->(MsUnlock())
		SC7->(dbSkip())
	enddo

	//———————————————————————————————————————————————————————————————————————————————
	// Após a gravação dos registros, limpo o conteúdo das variáves públicas
	//———————————————————————————————————————————————————————————————————————————————
	cGI120ForPag	:= Space(Len(SC7->C7_X_FORPG))
	cGI120ObsGer 	:= Space(Len(SC7->C7_X_OBSGE))
	cGI120Consum	:= Space(Len(SC7->C7_XCONSUM))
	cGI120CPF		:= Space(Len(SC7->C7_XCPF))
	cGI120Bco	 	:= Space(Len(SC7->C7_XBANCO))
	cGI120Age	 	:= Space(Len(SC7->C7_XAGENC))
	cGI120DVAge	 	:= Space(Len(SC7->C7_XDVAGE))
	cGI120Cta	 	:= Space(Len(SC7->C7_XCONTA))
	cGI120DVCta	 	:= Space(Len(SC7->C7_XDVCTA))
	if SC7->(FieldPos("C7_XMOTALT")) > 0
		cGI120MotAlt 	:= Space(Len(SC7->C7_XMOTALT))
	endif

endif

Return()
