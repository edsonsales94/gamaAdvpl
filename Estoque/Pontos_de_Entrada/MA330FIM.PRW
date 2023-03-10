#include "rwmake.ch"
#include "protheus.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		MA330FIM                                                      /@
@date				09/12/2019                                                    /@
@type				Ponto de entrada
@description	Function MA330Process - Fun鈬o de processamento da rotina de 
					recalculo do custo medio.
					Executada ap?s todo o processamento do recalculo do custo 
					m馘io para que se possa realizar customiza鋏es no final da 
					rotina.                                                       /@
@author			Adalberto Moreno Batista (Op鈬o Um)                           /@
@use				Brasitech                                                     /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function MA330FIM()
Local cQuery, dUltMes

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Somente para filial Embu das Artes - Brasitech (Infracommerce)
// Grava o D2_CUSTO1, com base no B2_CM1 calculado para o armazem (somente quando
// TES atualizar estoque e origem da nota for igual ? 'LF', incluida pela rotina
// MATA920 (Livros Fiscais)
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
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