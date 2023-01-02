User Function A710SQL()
Local cAliasAtu := paramixb[1]
Local cQuery    := paramixb[2]   


//: O ponto de entrada 'A710SQL' é utilizando no ambiente TopConnect para substituir 
//o ponto de entrada A710FIL. O PE é executado na montagem das query´s 
//dos alias SB1, SC1, SC2, SC6, SC7 e SD4, permitindo alterar o conteúdo da query que será executada.
//06-05-2017 alterado para nao entrar pedidos com itens ti BP e PI conforme solicitação Itamar
/* solicitado por itamar em 17/05/2018 para considerar as SC conforme padrao do sistema
If cAliasAtu == 'SC1' 
  // COM ESTA LINHA NENHUMA SOLICITACAO DE COMPRA VAI ENTRAR NO MRP- SOLICITADO POR CLEONICE 09/03/2015
  cQuery    := "SELECT SC1.*,SC1.R_E_C_N_O_ C1REC FROM SC1010 SC1 WHERE C1_PRODUTO=' '"     
  cQuery   := ChangeQuery(cQuery)      
  ConOut(cQuery) 
EndIf            
*/
//If cAliasAtu == 'SD4' 
  // COM ESTA LINHA NENHUM EMPENHO  VAI ENTRAR NO MRP- SOLICITADO POR LUZIVARO 13/04/2015
//  cQuery    := "SELECT SD4.*,SD4.R_E_C_N_O_ D4REC FROM SD4010 SD4 WHERE D4_COD=' '"     
//  cQuery   := ChangeQuery(cQuery)      
// ConOut(cQuery) 
//EndIf   
If cAliasAtu == 'SC7'
  // COM ESTA LINHA NENHUM pedido de compra de PI´s e SA´s será considerado - solicitado Cleonice 24-08-2016 AND C7_LOCAL='11'
  cQuery    := "SELECT SC7.*,SC7.R_E_C_N_O_ C7REC FROM SC7010 SC7 WHERE  C7_FILIAL='01'  AND  "
  cQuery    += " (SELECT DISTINCT B1_TIPO FROM SB1010 WHERE B1_COD = C7_PRODUTO AND SB1010.D_E_L_E_T_ <>'*') NOT IN ('PI','BN')"
  cQuery    += " AND C7_QUANT>C7_QUJE AND C7_RESIDUO=''  AND SC7.D_E_L_E_T_<>'*' "     
  cQuery   := ChangeQuery(cQuery)      
  ConOut(cQuery) 
EndIf
Return(cQuery) 
