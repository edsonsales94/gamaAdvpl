#include "rwmake.ch"

/*/

———————————————————————————————————————————————————————————————————————————————
@function		M410INIC                                                     /@
@type			Ponto de entrada                                             /@
@date			06/01/2012                                                   /@
@description	ponto de entrada acionado antes da montagem da tela de inclu-
				são de pedido de vendas                                      /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————

/*/
User Function M410INIC()

//———————————————————————————————————————————————————————————————————————————————
// Inicializa a variavel C5_X_VPC no pedido de vendas, quando pedido for    
// incluido pela rotina BFATA03                                             
// por SI8401 Adalberto Moreno em 06/01/12                                  
//———————————————————————————————————————————————————————————————————————————————
if SC5->(FieldPos("C5_X_VPC")) > 0 .and. FunName() == "BFATA03"

	M->C5_X_VPC := "S"
		
endif

Return()
