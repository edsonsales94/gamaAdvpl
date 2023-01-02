#include "rwmake.ch"
#include "protheus.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		MT120FOL                                                     /@
@date			13/10/2014                                                   /@
@type			Ponto de entrada
@description	Acionado pelo fonte MATA120 permite adicionar campos no 
				cabecalho e pastas no rodapé do pedidos de compras           /@
@parameters		PARAMIXB[1] - Numérico, Opção Selecionada no Pedido de Compras
				(inclusão, alteração, exclusão, etc ...)
				PARAMIXB[2]	- Vetor, Array contendo a posição dos gets do 
				pedido de compras                                            /@
@return			Nil
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Consultoria                                         /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MT120FOL()
Local nOpc				:= PARAMIXB[1]
Local aPosGet			:= PARAMIXB[2]
Local cCodReembCF		:= GetMV("BR_CDLJRCF", .F., "9999999901")
Public lGI120CF			:= (cCodReembCF==cA120Forn+cA120Loj)
Public cGI120CPF, cGI120Consum, cGI120Bco, cGI120Age, cGI120DVAge, cGI120Cta,;
	   cGI120DVCta, cGI120ObsGer, cGI120MotAlt

//—————————————————————————————————————————————————————————————————————————
// Cria pasta especifica no rodapé
//—————————————————————————————————————————————————————————————————————————
if nOpc != 1 .and.;
	SC7->(FieldPos("C7_X_FORPG")) > 0 .and.;
	SC7->(FieldPos("C7_X_OBSGE")) > 0 .and.;
	SC7->(FieldPos("C7_XCONSUM")) > 0

	cGI120CPF		:= iif(nOpc == 3, Space(Len(SC7->C7_XCPF)), SC7->C7_XCPF)
	cGI120Consum	:= iif(nOpc == 3, Space(Len(SC7->C7_XCONSUM)), SC7->C7_XCONSUM)
	cGI120Bco	 	:= iif(nOpc == 3, Space(Len(SC7->C7_XBANCO)), SC7->C7_XBANCO)
	cGI120Age	 	:= iif(nOpc == 3, Space(Len(SC7->C7_XAGENC)), SC7->C7_XAGENC)
	cGI120DVAge	 	:= iif(nOpc == 3, Space(Len(SC7->C7_XDVAGE)), SC7->C7_XDVAGE)
	cGI120Cta	 	:= iif(nOpc == 3, Space(Len(SC7->C7_XCONTA)), SC7->C7_XCONTA)
	cGI120DVCta	 	:= iif(nOpc == 3, Space(Len(SC7->C7_XDVCTA)), SC7->C7_XDVCTA)
	cGI120ObsGer	:= iif(nOpc == 3, Space(Len(SC7->C7_X_OBSGE)), SC7->C7_X_OBSGE)
	cGI120MotAlt	:= iif(nOpc == 4, Space(Len(SC7->C7_XMOTALT)), SC7->C7_XMOTALT)

	@ 008, aPosGet[3,1] Say OemToAnsi("Observação Geral") of oFolder:aDialogs[7] Pixel Size 050,009
	@ 005, aPosGet[3,1]+50 MsGet cGI120ObsGer of oFolder:aDialogs[7] Pixel Size 275,009 HASBUTTON
	
	// Motivo da alteração
	if nOpc == 4
		@ 008, aPosGet[3,1]+340 Say OemToAnsi("Motivo da Alteração") of oFolder:aDialogs[7] Pixel Size 050,009
		@ 005, aPosGet[3,1]+395 MsGet cGI120MotAlt of oFolder:aDialogs[7] Pixel Size 260,009
	endif

	@ 022, aPosGet[3,1] Say OemToAnsi("Informações bancárias do Fornecedor ou Consumidor Final") of oFolder:aDialogs[7] Pixel Size 180,10

	@ 035, aPosGet[3,1] Say OemToAnsi("Consumidor para reembolso") of oFolder:aDialogs[7] Pixel Size 80,010
	@ 035, aPosGet[3,1]+330 Say OemToAnsi("CPF") of oFolder:aDialogs[7] Pixel Size 30,010

	@ 032, aPosGet[3,1]+080 MsGet cGI120Consum 	Picture "@!"				When lGI120CF of oFolder:aDialogs[7] Pixel Size 215,009
	@ 032, aPosGet[3,1]+345 MsGet cGI120CPF	Picture "@R 999.999.999-99999" 	When lGI120CF Valid CGC(cGI120CPF) of oFolder:aDialogs[7] Pixel Size 060,009	

	@ 050, aPosGet[3,1]+050 Say OemToAnsi("Banco") 			of oFolder:aDialogs[7] Pixel Size 20,010
	@ 050, aPosGet[3,1]+150 Say OemToAnsi("Agência") 		of oFolder:aDialogs[7] Pixel Size 20,010
	@ 050, aPosGet[3,1]+230 Say OemToAnsi("DV") 			of oFolder:aDialogs[7] Pixel Size 20,010
	@ 050, aPosGet[3,1]+330 Say OemToAnsi("Conta Corrente") of oFolder:aDialogs[7] Pixel Size 40,010
	@ 050, aPosGet[3,1]+440 Say OemToAnsi("DV") 			of oFolder:aDialogs[7] Pixel Size 20,010

	@ 047, aPosGet[3,1]+080 MsGet cGI120Bco 	Picture "999" 		 When lGI120CF of oFolder:aDialogs[7] Pixel Size 020,009
	@ 047, aPosGet[3,1]+180 MsGet cGI120Age		Picture "99999" 	 When lGI120CF of oFolder:aDialogs[7] Pixel Size 030,009	
	@ 047, aPosGet[3,1]+240 MsGet cGI120DVAge 	Picture "@!" 		 When lGI120CF of oFolder:aDialogs[7] Pixel Size 010,009
	@ 047, aPosGet[3,1]+375 MsGet cGI120Cta 	Picture "9999999999" When lGI120CF of oFolder:aDialogs[7] Pixel Size 045,009	
	@ 047, aPosGet[3,1]+450 MsGet cGI120DVCta 	Picture "@!" 		 When lGI120CF of oFolder:aDialogs[7] Pixel Size 017,009

endif

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		VldBAC_MT120FOL                                              /@
@date			04/02/2015                                                   /@
@type			User function
@description	Acionado na validação da digitação do código do fornecedor e
				loja no pedido de compras para alimentar as variáveis de
				banco, agência e conta.                                      /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Consultoria                                         /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function VldBAC_MT120FOL()
Local cCodReembCF		:= GetMV("BR_CDLJRCF", .F., "9999999901")
Public lGI120CF			:= (cCodReembCF==cA120Forn+cA120Loj)

//———————————————————————————————————————————————————————————————————————————————
// Quando processo realizado para Reembolso de Consumidor Final, não inicializo
// os dados bancários com o cadastrado no fornecedor, pois neste caso será unico 
//———————————————————————————————————————————————————————————————————————————————
if !lGI120CF
	cGI120Bco	:= SA2->A2_BANCO
	cGI120Age	:= SA2->A2_AGENCIA
	cGI120DVAge	:= SA2->A2_DVAGE
	cGI120Cta	:= SA2->A2_NUMCON
	cGI120DVCta	:= SA2->A2_DVCTA
endif

Return(.T.)
