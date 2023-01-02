#include "rwmake.ch"
#include "protheus.ch"
/*/
�������������������������������������������������������������������������������
@function		M460QRY                                                       /@
@date				                                                              /@
@type				Ponto de entrada                                              /@
@description	Permite filtrar os itens na prepara��o de nota fiscal         /@
@author			Luiz Fernando Nogueira Cardoso                                /@
@use				Espec�fico Brasitech                                          /@
�������������������������������������������������������������������������������
/*/
User Function M460QRY()
Local cQuery  := ParamIXB[1]

if mv_par03 == 1	//considera parametros abaixo = SIM
	cQuery += " AND SC9.C9_LOCAL BETWEEN '" + MV_PAR17 + "' AND '" + MV_PAR18 + "'"  //Intervalo de parametros armaz�m de/at�
endif

Return(cQuery)