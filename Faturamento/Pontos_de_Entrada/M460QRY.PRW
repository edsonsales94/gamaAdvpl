#include "rwmake.ch"
#include "protheus.ch"
/*/
———————————————————————————————————————————————————————————————————————————————
@function		M460QRY                                                       /@
@date				                                                              /@
@type				Ponto de entrada                                              /@
@description	Permite filtrar os itens na preparação de nota fiscal         /@
@author			Luiz Fernando Nogueira Cardoso                                /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function M460QRY()
Local cQuery  := ParamIXB[1]

if mv_par03 == 1	//considera parametros abaixo = SIM
	cQuery += " AND SC9.C9_LOCAL BETWEEN '" + MV_PAR17 + "' AND '" + MV_PAR18 + "'"  //Intervalo de parametros armazém de/até
endif

Return(cQuery)