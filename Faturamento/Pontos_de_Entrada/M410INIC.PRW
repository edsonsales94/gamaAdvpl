#include "rwmake.ch"

/*/

覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		M410INIC                                                     /@
@type			Ponto de entrada                                             /@
@date			06/01/2012                                                   /@
@description	ponto de entrada acionado antes da montagem da tela de inclu-
				s縊 de pedido de vendas                                      /@
@author			Adalberto Moreno Batista - Op鈬o Um Consultoria              /@
@use			Espec?fico Brasitech                                         /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?

/*/
User Function M410INIC()

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Inicializa a variavel C5_X_VPC no pedido de vendas, quando pedido for    
// incluido pela rotina BFATA03                                             
// por SI8401 Adalberto Moreno em 06/01/12                                  
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if SC5->(FieldPos("C5_X_VPC")) > 0 .and. FunName() == "BFATA03"

	M->C5_X_VPC := "S"
		
endif

Return()
