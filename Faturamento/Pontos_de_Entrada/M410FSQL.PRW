#include "protheus.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		M410FSQL                                                     /@
@date			12/09/2022                                                   /@
@type			Ponto de entrada                                             /@
@description	Permite filtrar os pedidos de venda exibidos na mBrowse, 
				em que deve ser informada uma em ADVPL (versão 12).          /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Tecnologia da Informação                            /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function M410FSQL() 
Local cRet		:= ""
Local cUsersSAC	:= GetMV("BR_SACUSER", .F., "")

if Upper(cUserName) $ Upper(cUsersSAC)
	cRet	:= "C5_VEND1=='1379  ' "
endif

Return(cRet)


/*/
User Function M410FSQL () 
Local cTipo		:= "0 - Todos Pedidos"
Local aTipo		:= {"0 - Sem Filtro", "1 - Em Aberto", "2 - Liberados", "3 - Finalizados"}
Local oTipo, cRet
Private oDlg
Define MsDialog oDlg Title OemtoAnsi("Informe quais pedidos de venda deseja visualizar no browse") From C(100),C(100) TO C(250), C(420) Pixel
@ 04, 007 Say "Mostrar os pedidos..." 			Size 70,08 COLOR CLR_BLUE 	Pixel of oDlg
@ 10, 007 ComboBox oTipo Var cTipo Items aTipo 	Size 70,15 					Pixel of oDlg
@ 50, 050 Button OemToAnsi("Confirmar")	Size 35,012 Action (cRet := BrasFiltro(Left(cTipo, 1)))	Pixel of oDlg
@ 50, 100 Button OemToAnsi("Cancelar")	Size 35,012 Action (oDlg:End())							Pixel of oDlg
Activate MsDialog oDlg Centered
Return(cRet)

———————————————————————————————————————————————————————————————————————————————
@function		BrasFiltro                                                   /@
@type			Static Function                                              /@
@description	Permite filtrar os pedidos de venda exibidos na mBrowse, 
				em que deve ser informada uma expressão ADVPL (versão 12).   /@
———————————————————————————————————————————————————————————————————————————————
Static Function BrasFiltro(cOpc)
Local cFiltro
if cOpc == "1"			//"1 - Pedidos em Aberto
	cFiltro := "C5_LIBEROK = '' .and. C5_NOTA='' .and. C5_BLQ='' "
elseif cOpc == "2"	//"2 - Pedidos Liberados
	cFiltro := "C5_LIBEROK != '' .and. C5_NOTA='' .and. C5_BLQ='' "
elseif cOpc == "3"	//"3 - Pedidos Finalizados 
	cFiltro := "(C5_NOTA != '' .or. C5_LIBEROK='E') .and. C5_BLQ='' "
endif
Close(oDlg)
Return(cFiltro)
/*/
