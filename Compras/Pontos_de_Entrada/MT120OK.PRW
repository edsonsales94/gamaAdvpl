#include "rwmake.ch"
#include "protheus.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		MT120OK                                                      /@
@date			15/08/2021                                                   /@
@type			Ponto de entrada
@description	Localizado no final da fun鈬o A120TudOk(), ? respons疱el pela
				valida鈬o geral do pedido de compras / autoriza鈬o de entrega.
				Disparado ap?s a confirma鈬o dos itens da getdados e antes do 
				rodap? da dialog do PC.                                      /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Op鈬o Um Tecnologia da Informa鈬o                            /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function MT120OK()
Local lRet			:= .T.
Local cDirAnexos	:= GetMV("BR_ANEXOPC", .F., "")
Local cPathFile		:= cDirAnexos + "\" + cEmpAnt + cFilAnt + "\PC\temp\" + cFilAnt + "_" + AllTrim(ca120Num) + "_" + "*.*"
Local aFiles		:= Directory(cPathFile)

cA120NXPA := cA120Num	//corre鈬o de bug

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Analisa se h? anexo vinculado ao pedido de compras. Para o processo, ao menos 
// um arquivo dever? ser anexado. (N縊 executar a valida鈬o se o processo for
// autom疸ico)
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if !IsBlind()

	if Empty(Len(aFiles))
		
		lRet := .F.
		Help(,, "ｮ ATENﾇﾃO",, "Obrigat?rio anexar ao menos um documento ao pedido de compras ou despesa financeira.", 1)
			
	endif

endif

Return(lRet)
