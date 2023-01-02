User Function RPSCRAP()
	//ROMUALDO 27/05/13 - TOTVS-AM
	//VALIDAÇÃO DE PERDAS JUNTO A ESTRUTURA DE PRODUTO
	Local _CODEST := ""
	Local lRet := .T.
	Local cOP:= SC2->(C2_NUM+C2_ITEM+C2_SEQUEN)
   BeginSql Alias "TRB"
     SELECT COUNT(D4_COD) REG FROM SD4010 SD4
     WHERE D4_FILIAL=%xFilial:SD4% AND D4_OP=%Exp:cOP% AND D4_COD=%Exp:M->BC_PRODUTO% 
     AND SD4.%NotDel% 
   EndSql
	dbSelectArea("TRB")  
	DbGoTop()
	
	IF TRB->REG==0
		MSGALERT("ATENÇÃO!ESSE PRODUTO NÃO PERTENCE A ESTRUTURA DO PRODUTO PAI DA OP")
		lRet := .F.
	EndIf
	dbSelectArea("TRB") 
   dbcloseArea("TRB")
Return lRet