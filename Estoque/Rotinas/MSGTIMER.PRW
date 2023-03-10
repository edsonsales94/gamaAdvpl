#Include "Protheus.ch"

// Definições de Tipos de mensagem
#Define MT_TDEFAULT 0 // Adiciona somente o botão default "Fechar"
#Define MT_TYESNO   1 // Adiciona os botões "Sim" e "Não", focando no "Sim"
#Define MT_TNOYES   2 // Adiciona os botões "Não" e "Sim", focando no "Não"

// Definições de Ýcones da mensagem
#Define MT_ISUCCES  "FWSKIN_SUCCES_ICO.PNG" // Ýcone Default Sucesso
#Define MT_IALERT   "FWSKIN_ALERT_ICO.PNG"  // Ýcone Default Alerta
#Define MT_IERROR   "FWSKIN_ERROR_ICO.PNG"  // Ýcone Default Erro
#Define MT_IINFO    "FWSKIN_INFO_ICO.PNG"   // Ýcone Default Informação

/*/{Protheus.doc} MsgTimer
Função para exibição de mensagens com Timer para fechamento automático.
@author Gabriel Alencar
@since 02/01/2020
@return return, return_description
@param nSeconds, numeric, Tempo em segundos que a mensagem será exibida antes de ser fechada.
@param cMensagem, characters, Descrição da mensagem [TEXT or HTML Formats].
@param cTitulo, characters, Título da mensagem [TEXT or HTML Formats].
@param cIcone, characters, Ýcone formato MT_I[ICON OF MESSAGE] ou RESOURCE compilados.
@param nTipo, numeric, Tipo de mensagem formato MT_T[TYPE OF MESSAGE].
@see https://github.com/AlencarGabriel/advpl-MsgTimer
@obs Uso de HTML no Título e/ou Mensagem pode ocasionar problemas de dimensionamento nas mensagens.
/*/
User Function MsgTimer(cMensagem, cTitulo,_nSeconds)
	Local xRet := Nil
	Local nCountEnter := 0
	Local cTipo := ""
	Local cDesIcone := ""
	Local cTimeIni := ""
	Local oTFont := TFont():New('Arial Black',,-16,,.T.)
	Local oTFont2 := TFont():New('Arial',,-12,,.F.)
	Private cTimeLeft := ""
	Private lClosedByTimer := .F. // Define que a mensagem foi fechada pelo Timer.
	Default nSeconds := 5
	Default nTipo := MT_TDEFAULT
	Default cIcone := MT_ISUCCES //MT_IINFO
	Default cTitulo := ""
	Default cMensagem := ""

	nSeconds := iif( !Empty(_nSeconds),_nSeconds,5)
	// Caso esteja executando sem interface, não constroi os diálogos.
	If IsBlind()
		// Trata a descrição dos tipos de mensagem (botões)
		Do Case
			Case nTipo == MT_TDEFAULT
				cTipo := "DEFAULT"
			Case nTipo == MT_TNOYES
				cTipo := "NOYES"
			Case nTipo == MT_TYESNO
				cTipo := "YESNO"
		EndCase
		// Trata a descrição dos ícones das mensagens
		Do Case
			Case cIcone == MT_ISUCCES
				cDesIcone := "Success"
			Case cIcone == MT_IALERT
				cDesIcone := "Alert"
			Case cIcone == MT_IERROR
				cDesIcone := "Error"
			Case cIcone == MT_IINFO
				cDesIcone := "Info"
		EndCase
		// Mostra a mensagem no console
		ConOut(DToC(Date()) + " - " + Time() + " - MsgTimer | " + cDesIcone + " | " + cTipo + " -> " + AllTrim(cMensagem))
		// Trata os retornos em caso de modo Blind, para não deixar a Thread travada esperando uma resposta
		Do Case
			// Botão default ("Fechar")
			Case nTipo == MT_TDEFAULT
				Return Nil
			// Botão "NÃO" e "SIM" (Focado no Não)
			Case nTipo == MT_TNOYES
				Return .F.
			// Botão "SIM" e "NÃO" (Focado no Sim)
			Case nTipo == MT_TYESNO
				Return .T.
			// Botão default ("Fechar")
			Otherwise
				Return Nil
		EndCase
	EndIf

    //nSeconds:=5
	// Só calcula e apresenta o contador caso os segundos tenham sido informados
	If nSeconds > 0
		// Acrescenta os segundos informados no tempo atual para que o tempo seja contado de forma decrescente
		cTimeIni := IncTime(Time(), 0, 0, nSeconds)
		cTimeLeft := ElapTime(Time(), cTimeIni)
	EndIf
	// ---------------------------------------------------------------------------------------------------------
	// Calcula a altura estimada para as mensagens, relativo a quantidade de caracteres.
	// Obs.: Este cálculo não é preciso, portanto dependendo da quantidade de quebras ou se for usado
	//  HTML, algumas partes do texto podem ser cortadas.
	// ---------------------------------------------------------------------------------------------------------
	nTextWidth := Int(GetTextWidth(0, cTitulo))
	nHeightTit := ((IIF(nTextWidth <= 0, 200, nTextWidth) / 200) * 012) + 012
	nCountEnter:= Len(Strtokarr2(cTitulo, Chr(13), .F.)) -1
	nCountEnter+= Len(Strtokarr2(cTitulo, "<br>", .F.)) -1
	nHeightTit += (nCountEnter * 012)
	nTextWidth := Int(GetTextWidth(0, cMensagem))
	nHeightMsg := ((IIF(nTextWidth <= 0, 200, nTextWidth) / 200) * 006) + 006
	nCountEnter:= Len(Strtokarr2(cMensagem, Chr(13), .F.))
	nCountEnter+= Len(Strtokarr2(cMensagem, "<br>", .F.))
	nHeightMsg += (nCountEnter * 006)
	// ---------------------------------------------------------------------------------------------------------
	oModal  := FWDialogModal():New()
	oModal:SetEscClose(.F.)    // Não permite fechar com ESC
	oModal:SetCloseButton(.F.) // Não permite fechar a tela com o "X"
	oModal:SetBackground(.T.)  // Escurece o fundo da janela
	// Seta a largura e altura da janela em pixel
	If (nHeightTit + nHeightMsg) <= 57 // Caso a altura das mensagens não corresponda ao tamanho mínimo da janela, seta as dimensões default.
		oModal:setSize(97, 253)
	Else
		oModal:setSize(040 + nHeightTit + nHeightMsg, 253)
	EndIf
	oModal:createDialog()
	// ---------------------------------------------------------------------------------------------------------
	// Adiciona os botões da mensagem conforme parâmetro definido pelo usuário.
	// ---------------------------------------------------------------------------------------------------------
	Do Case
		// Botão default ("Fechar")
		Case nTipo == MT_TDEFAULT
			oModal:addCloseButton(nil, "Fechar")
		// Botão "NÃO" e "SIM" (Focado no Não)
		Case nTipo == MT_TNOYES
			oModal:addNoYesButton()
		// Botão "SIM" e "NÃO" (Focado no Sim)
		Case nTipo == MT_TYESNO
			oModal:addYesNoButton()
		// Botão default ("Fechar")
		Otherwise
			oModal:addCloseButton(nil, "Fechar")
	EndCase
	// ---------------------------------------------------------------------------------------------------------
	// Apresenta o ícone da mensagem (resource compilado no RPO)
	If !Empty(cIcone)
		oIcone := TBitmap():New(10,10,025,025,,cIcone,.T.,oModal:getPanelMain(),{||Nil},,.F.,.F.,,,.F.,,.T.,,.F.)
		oIcone:lAutoSize := .T.
	EndIf
	oTitulo := TSay():New(10, 45, {|| cTitulo }, oModal:getPanelMain(),, oTFont,,,, .T., RGB(105,105,105),/*CLR_BLACK*/, 200, nHeightTit,,,,,, .T.)
	oTitulo:lWordWrap = .T.
	oMensagem := TSay():New(10 + nHeightTit, 45, {|| cMensagem }, oModal:getPanelMain(),, oTFont2,,,, .T., RGB(105,105,105),/*CLR_RED*/, 200, nHeightMsg,,,,,, .T.)
	oMensagem:lWordWrap = .T.
	// Só calcula e apresenta o contador caso os segundos tenham sido informados
	If nSeconds > 0
		// A cada segundo Calcula o tempo decorrido, Atualiza o Say de contador, Verifica se o tempo zerou, caso zere fecha a janela repassando o valor default.
		oModal:SetTimer(1, {|| cTimeLeft := ElapTime(Time(), cTimeIni), oTimeMsg:CtrlRefresh(), IIF(cTimeLeft == "00:00:00", (oModal:oOwner:End(), lClosedByTimer := .T.), Nil) })
		oTimeMsg := TSay():New(04, 10,{|| "Fecha em:" }, oModal:oFormBar:oOwner,, oTFont2,,,, .T., RGB(105,105,105),/*CLR_BLUE*/, 035, 006,,,,,, .T.)
		oTimeMsg:lTransparent = .T.
		oTimeMsg := TSay():New(10, 12, {|| cTimeLeft }, oModal:oFormBar:oOwner,, oTFont2,,,, .T., RGB(105,105,105),/*CLR_BLUE*/, 030, 006,,,,,, .T.)
		oTimeMsg:lTransparent = .T.
	EndIf
	oModal:Activate()
	// ---------------------------------------------------------------------------------------------------------
	// Trata o retorno dos botões
	//	- MT_TNOYES: Caso a mensagem seja fechada pelo Timer, retorna "NÃO" como Default.
	//	- MT_TYESNO: Caso a mensagem seja fechada pelo Timer, retorna "SIM" como Default.
	//	- MT_TYESNO ou MT_TNOYES: Caso a opção tenha sido escolhida pelo usuário retorna o que foi selecionado.
	// ---------------------------------------------------------------------------------------------------------
	If nTipo == MT_TNOYES .OR. nTipo == MT_TYESNO
		If lClosedByTimer
			Do Case
				Case nTipo == MT_TNOYES
					xRet := .F.
				Case nTipo == MT_TYESNO
					xRet := .T.
			EndCase
		Else
			// getButtonSelected() -> 1=Sim, 2=Não
			xRet := IIF(oModal:getButtonSelected() == 1, .T., .F.)
		EndIf
	EndIf
	FwFreeVar(oModal)
Return xRet
