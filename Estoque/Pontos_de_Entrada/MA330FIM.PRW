#include "rwmake.ch"
#include "protheus.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		MA330FIM                                                      /@
@date				09/12/2019                                                    /@
@type				Ponto de entrada
@description	Function MA330Process - Função de processamento da rotina de 
					recalculo do custo medio.
					Executada após todo o processamento do recalculo do custo 
					médio para que se possa realizar customizações no final da 
					rotina.                                                       /@
@author			Adalberto Moreno Batista (Opção Um)                           /@
@use				Brasitech                                                     /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MA330FIM()
Local cQuery, dUltMes

//———————————————————————————————————————————————————————————————————————————————
// Somente para filial Embu das Artes - Brasitech (Infracommerce)
// Grava o D2_CUSTO1, com base no B2_CM1 calculado para o armazem (somente quando
// TES atualizar estoque e origem da nota for igual à 'LF', incluida pela rotina
// MATA920 (Livros Fiscais)
//———————————————————————————————————————————————————————————————————————————————
if cEmpAnt == "01" .and. cFilAnt == "11"

	dUltMes	:= GetMV("MV_ULMES")

	cQuery 	:= "UPDATE " + RetSQLName("SD2") + " SET D2_CUSTO1=B2_CM1*D2_QUANT " +;
					"FROM " + RetSQLName("SF4") + " SF4, " + RetSQLName("SB2") + " SB2 " +;
					"WHERE D2_FILIAL='" + xFilial("SD2") + "' " +;
							"AND D2_ORIGLAN='LF' " +;
							"AND D2_EMISSAO>'" + dTOs(dUltMes) + "' " +;
							"AND " + RetSQLName("SD2") + ".D_E_L_E_T_='' " +;
							"AND F4_FILIAL='" + xFilial("SF4") + "' " +;
							"AND F4_CODIGO=D2_TES " +;
							"AND F4_ESTOQUE='S' " +;
							"AND SF4.D_E_L_E_T_='' " +;
							"AND B2_FILIAL='" + xFilial("SB2") + "' " +;
							"AND B2_COD=D2_COD " +;
							"AND B2_LOCAL=D2_LOCAL " +;
							"AND SB2.D_E_L_E_T_=''"
							
	TCSqlExec(cQuery)
	
endif
					
Return()