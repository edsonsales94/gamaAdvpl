#include "rwmake.ch"
#include "Protheus.ch"

/*

———————————————————————————————————————————————————————————————————————————————
@function		A460TESN3                                                    /@
@type			Ponto de entrada                                             /@
@date			28/12/2012                                                   /@
@description	Considera saldo poder terc. p/ TES que não atualiza estoque 
				no relatorio de registro de inventário P7 (MATR460)
				Retorna .T. ou .F.                                           /@
@author			Romualdo                                                     /@
@use			Especifico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————

*/
User Function A460TESN3()
Local lRet      := .F. 
//———————————————————————————————————————————————————————————————————————————————
// Para empresa 01, filiais 01 ou 04 e para empresa 04 e para empresa 11
// considero o saldo em terceiros e que não atualiza estoque no movimento do 
// relatorio de inventário 
// Originalmente este ponto de entrada existia somente no ambiente de Manaus
// e no projeto de unificação de ambientes, ajustei para funcionar nas filiais
// utilizadas em Manaus.
// Por: Adalberto Moreno Batista em 25/04/14
//———————————————————————————————————————————————————————————————————————————————
if (cEmpAnt == "01" .and. cFilAnt $ "01.04") .or. cEmpAnt == "04" .or. cEmpAnt == "11"
	lRet := .T.
   nSumQtTer:=0 
endif

Return(lRet)