#include "rwmake.ch"
#include "protheus.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		MT120BRW                                                      /@
@type				Ponto de entrada                                              /@
@date				07/03/2017                                                    /@
@description	Adiciona botões no array aRotina após a montagem do filtro da
					tabela SC7 e antes da execução da Mbrowse do PC.              /@
@author			Irina Sanches Pires (irina@opcaoum.com.br)
					Opção Um Consultoria                                          /@
@use				Especifico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MT120BRW()

//———————————————————————————————————————————————————————————————————————————————
// Adiciona botão aRotina
//———————————————————————————————————————————————————————————————————————————————
aAdd(aRotina, {"® Atualizações Gama", "U_A_MT120BRW" , 0, 4, 0, Nil})

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		A_MT120BRW                                                    /@
@type				User function                                                 /@
@date				07/03/2017                                                    /@
@description	Acionado pelo ponto de entrada MT120BRW, monta a tela para 
					atualização da data de entrega do pedido de compras.          /@
@author			Irina Sanches Pires (irina@opcaoum.com.br)
					Opção Um Consultoria                                          /@
@use				Especifico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function A_MT120BRW()
Local aCampos	:= {"C7_ITEM", "C7_PRODUTO", "C7_DESCRI", "C7_QUANT", "C7_PRECO", "C7_TOTAL", "C7_QUJE", "C7_DATPRF","C7_X_CRITI","C7_XPI","C7_XINVOIC","C7_DINICOM"}
Local aAltera	:= {"C7_DATPRF","C7_X_CRITI","C7_XPI","C7_XINVOIC"}
Local aStruct 	:= {}
Local nUsado 	:= 0
Local aSize 	:= MsAdvSize()
Local cFilSC7	:= SC7->C7_FILIAL
Local cPedido	:= SC7->C7_NUM
Local dEmissao	:= SC7->C7_EMISSAO
Local cFornec	:= SC7->C7_FORNECE
Local cLoja		:= SC7->C7_LOJA
Local nTaxa		:= SC7->C7_TXMOEDA
Local cNomeFor	:= GetAdvFVal("SA2", "A2_NOME", xFilial("SA2") + cFornec + cLoja, 1)
Local nX, oDlg, oGetDB, nOpcA
Private aHeader := {}

//———————————————————————————————————————————————————————————————————————————————
// Ordena as areas de trabalho
//———————————————————————————————————————————————————————————————————————————————
SX3->(dbSetOrder(2))
SC7->(dbSetOrder(1))

//———————————————————————————————————————————————————————————————————————————————
// Cria aHeader para a montagem da edição das ocorrências, aStruct para a criação
// de tabela temporária e aAltera para a definição dos campos que poderão ser 
// alterados no aCols
//———————————————————————————————————————————————————————————————————————————————
for nX := 1 to Len(aCampos)
	SX3->(dbSeek(aCampos[nX]))
	nUsado++
	aAdd(aHeader, { Trim(X3Titulo()),;
						 SX3->X3_CAMPO,;
						 SX3->X3_PICTURE,;
						 SX3->X3_TAMANHO,;
						 SX3->X3_DECIMAL,;
						 SX3->X3_VALID,;
						 "",;
						 SX3->X3_TIPO,;
						 "",;
						 "" })
	aAdd(aStruct, { SX3->X3_CAMPO,;
						 SX3->X3_TIPO,;
						 SX3->X3_TAMANHO,;
						 SX3->X3_DECIMAL })
							
next
aAdd(aHeader, {"Controle",	"REGSC7", "", 10, 0, "", "", "N", "", ""})
aAdd(aStruct, {"REGSC7", "N", 10, 0})
aAdd(aStruct, {"FLAG", 	 "L", 01, 0})

//———————————————————————————————————————————————————————————————————————————————
// Cria arquivo de trabalho (substituição do aCols)
//———————————————————————————————————————————————————————————————————————————————
cCriaTrab := CriaTrab(aStruct, .T.)
DbUseArea(.T., __LocalDriver, cCriaTrab, "TRAB", .F., .F.)

//———————————————————————————————————————————————————————————————————————————————
// Seleciona registros para alimentar tabela de trabalho
//———————————————————————————————————————————————————————————————————————————————
SC7->(dbSeek(cFilSC7 + cPedido))

do while SC7->(!eof() .and. C7_FILIAL == cFilSC7 .and. C7_NUM == cPedido)

	if SC7->C7_QUJE < SC7->C7_QUANT .and. SC7->C7_ENCER != "E"
	
		TRAB->(RecLock("TRAB", .T.))
		TRAB->C7_ITEM		:= SC7->C7_ITEM
		TRAB->C7_PRODUTO	:= SC7->C7_PRODUTO
		TRAB->C7_DESCRI		:= SC7->C7_DESCRI
		TRAB->C7_QUANT		:= SC7->C7_QUANT
		TRAB->C7_PRECO		:= SC7->C7_PRECO
		TRAB->C7_TOTAL		:= SC7->C7_TOTAL
		TRAB->C7_QUJE		:= SC7->C7_QUJE
		TRAB->C7_DATPRF		:= SC7->C7_DATPRF
		TRAB->C7_X_CRITI    := SC7->C7_X_CRITI
		TRAB->C7_XPI  		:= SC7->C7_XPI
		TRAB->C7_XINVOIC	:= SC7->C7_XINVOIC
		TRAB->REGSC7		:= SC7->(RecNo())
		TRAB->(MsUnlock())
	
	endif
		
	SC7->(dbSkip())

enddo

//———————————————————————————————————————————————————————————————————————————————
// Verifico se o proccesso pode ser manipulado
//———————————————————————————————————————————————————————————————————————————————
TRAB->(dbGoTop())
if TRAB->(eof())
	Help("", 1, "® Pedido atendido",, "Todos os itens deste pedido já focebidos. Selecione outro pedido." + chr(13) + chr(10) + "Específico Brasitech", 1)
	if TRAB->(Select()) > 0
		TRAB->(dbCloseArea())
		fErase(cCriaTrab + GetDBExtension())
	endif
	Return()
endif

//———————————————————————————————————————————————————————————————————————————————
// Monta tela de diálogo (cabeçalho e ítens)
//———————————————————————————————————————————————————————————————————————————————
Define MsDialog oDlg Title OemtoAnsi("Ajuste em data de entrega") From C(100),C(100) TO C(580),C(1050) Pixel

@ C(004), C(007) Say "Pedido" Size C(018),C(008) Color CLR_BLACK Pixel of oDlg
@ C(004), C(070) Say "Emissão" Size C(021),C(008) Color CLR_BLACK Pixel of oDlg
@ C(004), C(130) Say "Fornecedor" Size C(018),C(008) Color CLR_BLACK Pixel of oDlg

@ C(010), C(007) MsGet oPedido Var cPedido When .F. Size C(025),C(009) COLOR CLR_BLACK Pixel of oDlg
@ C(010), C(070) MsGet oEmissao Var dEmissao When .F. Size C(030),C(009) COLOR CLR_BLACK Pixel of oDlg
@ C(010), C(130) MsGet oFornec Var cFornec When .F. Size C(025),C(009) COLOR CLR_BLACK Pixel of oDlg
@ C(010), C(160) MsGet oLoja Var cLoja When .F. Size C(010),C(009) COLOR CLR_BLACK Pixel of oDlg
@ C(010), C(180) MsGet oNomeFor Var cNomeFor When .F. Size C(180),C(009) COLOR CLR_BLACK Pixel of oDlg

@ C(024), C(007) Say "Taxa" Size C(018),C(008) Color CLR_BLACK Pixel of oDlg
@ C(030), C(007) MsGet oTaxa Var nTaxa Picture "@E 999,999.9999" Size C(047),C(009) COLOR CLR_BLACK Pixel of oDlg

//MsGetDB():New( < nTop>, < nLeft>, < nBottom>, < nRight>, < nOpc>, [ cLinhaOk], [ cTudoOk], [ cIniCpos], [ lDelete], [ aAlter], [ nFreeze], [ lEmpty], [ uPar1], < cTRB>, [ cFieldOk], [ uPar2], [ lAppend], [ oWnd], [ lDisparos], [ uPar3], [ cDelOk], [ cSuperDel] ) --> oObj
oGetDB := MsGetDB():New(aSize[7]+60, aSize[2]+3, aSize[6]-300, aSize[3], 4,,,, .F., aAltera, 0, .F.,, "TRAB")
Activate MsDialog oDlg On Init EnchoiceBar(	oDlg,;
															{||nOpcA:=1, oDlg:End()},;
															{||nOpcA:=2, oDlg:End()}) Valid nOpcA != 0
											
//———————————————————————————————————————————————————————————————————————————————
// Grava dados
//———————————————————————————————————————————————————————————————————————————————
if nOpcA == 1

	Processa({|| GrvPedido(nTaxa)}, "Gravando alterações no pedido...")
 	
endif

if TRAB->(Select()) > 0
	TRAB->(dbCloseArea())
	fErase(cCriaTrab + GetDBExtension())
endif

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		GRVPEDIDO                                                     /@
@type				Static function                                               /@
@date				07/03/2017                                                    /@
@description	Grava as datas de entrega do pedido de compras                /@
@author			Irina Sanches Pires (irina@opcaoum.com.br)
					Opção Um Consultoria                                          /@
@use				Especifico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function GrvPedido(nTaxa)

dbSelectArea("TRAB")
dbGoTop()
do while !eof()
	SC7->(dbGoTo(TRAB->REGSC7))
	if SC7->C7_DATPRF <> TRAB->C7_DATPRF .or. SC7->C7_TXMOEDA <> nTaxa .OR. TRAB->C7_X_CRITI <> SC7->C7_X_CRITI .OR. TRAB->C7_XPI <> SC7->C7_XPI;
		.OR. TRAB->C7_XINVOIC <> SC7->C7_XINVOIC
		SC7->(RecLock("SC7", .F.))
		SC7->C7_DATPRF	 	:= TRAB->C7_DATPRF
		SC7->C7_TXMOEDA 	:= nTaxa
		SC7->C7_X_CRITI      := TRAB->C7_X_CRITI
		SC7->C7_XPI			:= TRAB->C7_XPI
		SC7->C7_XINVOIC		:= TRAB->C7_XINVOIC
		SC7->(MsUnlock())
	endif
	TRAB->(dbSkip())
enddo		

Return()
