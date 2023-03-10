#INCLUDE "rwmake.ch"
#include "TOPCONN.CH"

/*/

覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		MT103SE2                                                     /@
@type			ExecBlock                                                    /@
@date			18/12/2013                                                   /@
@description	Fun鈬o utilizada para valida鈬o de usu疵io no campo D3_OP
				Retorno - .T. / .F.                                          /@
@author			Ronaldo Gomes                                                /@
@use			Especifico Brasitech                                         /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?

/*/
User Function VALEMP1()
Local cXVALEMP := GetMV("MV_XVALEMP",.f.,"N")
Local lRet := .T.

if FunName() <> "MATA250" .Or. !Inclui .OR. cXVALEMP !="S"

else
	BeginSql Alias "TD4"
		Select *
		From %Table:SD4% SD4
		Where %notdel%
		And D4_FILIAL = %xFilial:SD4%
		And D4_OP = %Exp:M->D3_OP%
		And D4_QUANT > 0
	EndSql
	
	If TD4->(Eof())
		Alert("OP " + M->D3_OP + "N縊 possui Empenho. Favor verifique o Ajuste de Empenhos ou Estrutura do Produto.", "ATENﾇﾃO!!!")
		lRet := .F.
	EndIf
	
	TD4->(dbCloseArea())
endif

Return(lRet)
