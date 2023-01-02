/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³PrograCESTM04  ³ Por: Adalberto Moreno Batista ³ Data ³11.03.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina para a exclusao do ultimo fechamento do estoque     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Uso       ³ Especifico PDV Brasil                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
#include "rwmake.ch"

User Function CESTM04()
Local _aSays		:= {}
Local _aButtons	:= {}
Local _nOpcao		:= 0
Local _dUlMes		:= GetMV("MV_ULMES")
Local _dPenult		:= Ctod("31/12/01")
Local _cQuery
Private cTitulo	:= "Cancelamento do último fechamento do estoque"

aAdd(_aSays, "Rotina para o cancelamento do fechamento do estoque realizado em " + dTOc(_dUlMes))
aAdd(_aSays, "ATENÇÃO: A exclusão do fechamento do estoque gera impacto em outros processos que")
aAdd(_aSays, "por ventura já tenham sido realizados no sistema, tais como o")
aAdd(_aSays, "Fechamento contábil")
aAdd(_aSays, "Antes de excluir verifique como proceder em cada situação.")
aAdd(_aButtons, { 01, .T., {|o| _nOpcao:=1, o:oWnd:End()}})		//Ok 01
aAdd(_aButtons, { 02, .T., {|o| _nOpcao:=0, o:oWnd:End()}})		//Cancela 02
do while .t.
	FormBatch(cTitulo, _aSays, _aButtons)
	Exit
enddo

if _nOpcao = 1 .and. MsgBox("Confirma a exclusão do fechamento de estoque em " + dTOc(_dUlMes) + "?", "Pergunta", "YESNO")

	_cQuery := "UPDATE " + RetSqlName("SB9") + " SET D_E_L_E_T_='*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE D_E_L_E_T_ = ' ' AND B9_FILIAL='" + xFilial("SB9") + "' AND B9_DATA='" + dTOs(_dUlMes) + "'"
	TCSqlExec(_cQuery)

	_cQuery := "UPDATE " + RetSqlName("SBJ") + " SET D_E_L_E_T_='*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE D_E_L_E_T_ = ' ' AND BJ_FILIAL='" + xFilial("SBJ") + "' AND BJ_DATA='" + dTOs(_dUlMes) + "'"
	TCSqlExec(_cQuery)

	_cQuery := "UPDATE " + RetSqlName("SBK") + " SET D_E_L_E_T_='*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE D_E_L_E_T_ = ' ' AND BK_FILIAL='" + xFilial("SBK") + "' AND BK_DATA='" + dTOs(_dUlMes) + "'"
	TCSqlExec(_cQuery)
	
	_cQuery := "SELECT DISTINCT(B9_DATA) B9_DATA FROM " + RetSqlName("SB9") + " "
	_cQuery += "WHERE B9_FILIAL='" + xFilial("SB9") + "' AND D_E_L_E_T_ = ' ' "
	_cQuery += "ORDER BY B9_DATA DESC"

	
	//Verifica se a view esta aberta
	if Select("TRB") > 0
		dbSelectArea("TRB")
		dbCloseArea("TRB")
	endif
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"TRB",.T.,.F.)
	tcSetField("TRB","B9_DATA","D")
	
	dbSelectArea("TRB")
	dbGoTop()
	if !eof()
		_dPenult := TRB->B9_DATA
	endif
	dbCloseArea("TRB")
	
	PutMV("MV_ULMES",_dPenult)
	
	MsgBox("O fechamento do estoque em " + dTOc(_dUlMes) + " foi excluído. O último fechamento de estoque vigente é em " + dTOc(_dPenult) + ".", "Informação", "INFO")
endif

Return()
