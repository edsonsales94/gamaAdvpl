#include 'protheus.ch'
#include 'parmtype.ch'
#include "topconn.ch"
//---------------------------------------------------------------------------------
//Data: 30/10/2015
//Objetivo: Priorizar os endereços do empenho
//Solicitado: Fabio Producao
//Motivo: Os empenhos nao estavam sendo baixados  do endereço da ordem
//--------------------------------------------------------------------------------
user function MA650EMP()
	Local aArea := GetArea()
	Local cAliasQry:=GetNextAlias()
	Local cRet := SC2->C2_PRODUTO 
	cOp:=SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN
	cEnd:= SC2->C2_XEND
	/*
	BeginSql Alias cAliasQry
	SELECT DC_LOCAL,DC_PRODUTO,DC_QTDORIG,DC_LOCALIZ,DC_NUMSERI,DC_LOTECTL,DC_NUMLOTE,R_E_C_N_O_ REG FROM %Table:SDC% SDC
	WHERE DC_FILIAL =%xFilial:SDC% AND DC_OP=%Exp:cOp%  AND DC_ORIGEM='SC2'
	AND SDC.%NotDel%
	EndSql
	DBSELECTAREA(cAliasQry)
	DBGOTOP()
	IF !EOF()
		do while !eof()
			//if LEFT((cAliasQry)->DC_LOCALIZ,1)=='L'
			//AJUSTA O EMPENHO DO ENDERECO ANTERIOR
			DBSELECTAREA("SBF")
			DBSETORDER(1)
			DBSEEK(XFILIAL("SBF")+(cAliasQry)->(DC_LOCAL+DC_LOCALIZ+DC_PRODUTO+DC_NUMSERI+DC_LOTECTL+DC_NUMLOTE))
			IF !eof()
				SBF->(RecLock("SBF",.F.))
				SBF->BF_EMPENHO:=SBF->BF_EMPENHO-(cAliasQry)->DC_QTDORIG
				SBF->(MsUnlock())
			Endif
			//AJUSTA O ENDERECO DO EMPENHO
			DBSELECTAREA("SDC")
			DBGOTO((cAliasQry)->REG)
			SDC->(RecLock("SDC",.F.))
			SDC->DC_LOCALIZ:=cEnd
			SDC->(MsUnlock())
			//AJUSTA O EMPENHO DO ENDERECO
			DBSELECTAREA("SBF")
			DBSETORDER(1)
			DBSEEK(XFILIAL("SBF")+(cAliasQry)->DC_LOCAL+SDC->DC_LOCALIZ+(cAliasQry)->(DC_PRODUTO+DC_NUMSERI+DC_LOTECTL+DC_NUMLOTE))
			IF !eof()
				SBF->(RecLock("SBF",.F.))
				SBF->BF_EMPENHO:=SBF->BF_EMPENHO+(cAliasQry)->DC_QTDORIG
				SBF->(MsUnlock())
			Endif
			//endif
			DBSELECTAREA(cAliasQry)
			dbskip()
		enddo
		dbSelectArea(cAliasQry)
		dbCloseArea()
	ELSE
	    dbSelectArea(cAliasQry)
	    dbCloseArea()   
		BeginSql Alias cAliasQry
		  SELECT B1_LOCALIZ,SD4.* FROM SD4010 SD4 ,SB1010 SB1  WHERE D4_FILIAL=%xFilial:SD4% AND 
		  D4_OP=%Exp:cOp%  AND SD4.%NotDel% AND B1_COD=D4_COD AND  B1_LOCALIZ='S' AND SB1.%NotDel%
		EndSql
		DBSELECTAREA(cAliasQry)
		DBGOTOP()
		do while !eof()
		  	SDC->(RecLock("SDC",.T.))
		  	SDC->DC_FILIAL :=XFILIAL("SDC")
		  	SDC->DC_ORIGEM :="SC2"
		  	SDC->DC_PRODUTO:=(cAliasQry)->D4_COD
		  	SDC->DC_LOCAL  :=(cAliasQry)->D4_LOCAL
		  	SDC->DC_LOCALIZ:=cEnd
		  	SDC->DC_QUANT  :=(cAliasQry)->D4_QTDEORI
		  	SDC->DC_QTDORIG:=(cAliasQry)->D4_QTDEORI
		  	SDC->DC_OP     :=(cAliasQry)->D4_OP
		  	SDC->DC_TRT    :=(cAliasQry)->D4_TRT
		  	SDC->(MsUnlock())
		  	//AJUSTA O EMPENHO DO ENDERECO
			DBSELECTAREA("SBF")
			DBSETORDER(1)
			PESQ:=XFILIAL("SBF")+(cAliasQry)->D4_LOCAL+cEnd
			PESQ+=(cAliasQry)->D4_COD+SDC->(DC_NUMSERI)
			PESQ+=(cAliasQry)->(D4_LOTECTL+D4_NUMLOTE)
			DBSEEK(PESQ)
			IF !eof()
				SBF->(RecLock("SBF",.F.))
				SBF->BF_EMPENHO:=SBF->BF_EMPENHO+(cAliasQry)->D4_QTDEORI
				SBF->(MsUnlock())
			ELSE 
			    SBF->(RecLock("SBF",.T.))
			    SBF->BF_FILIAL  :=XFILIAL("SBF")
			    SBF->BF_PRODUTO :=(cAliasQry)->D4_COD
			    SBF->BF_LOCAL   :=(cAliasQry)->D4_LOCAL
			    SBF->BF_LOCALIZ := cEnd
			    SBF->BF_QUANT   := 0
			    SBF->BF_EMPENHO  :=(cAliasQry)->D4_QTDEORI
				SBF->(MsUnlock())	
			Endif
		  	DBSELECTAREA(cAliasQry)
		  	DBSKIP()
		Enddo
        dbSelectArea(cAliasQry)
	    dbCloseArea()   
	ENDIF
	*/
	If SC2->C2_XEND="RETRABALHO"
	 cAliasQry:=GetNextAlias()
	 BeginSql Alias cAliasQry
	 SELECT B1_LOCALIZ,SD4.R_E_C_N_O_ REGSD4,SD4.* FROM SD4010 SD4 ,SB1010 SB1  WHERE D4_FILIAL=%xFilial:SD4% AND 
	  D4_OP=%Exp:cOp%  AND SD4.%NotDel% AND B1_COD=D4_COD AND  B1_LOCALIZ='S' AND SB1.%NotDel%
	 EndSql
	 DBSELECTAREA(cAliasQry)
	 DBGOTOP()
	 IF !eof()
	   dbSelectArea("SD4")
	   DBGOTO((cAliasQry)->REGSD4)
	   RecLock("SD4",.T.)
	   SD4->D4_FILIAL:=XFILIAL("SD4")
	   SD4->D4_LOCAL:="17"  // LOCAL DE RETRABALHO
	   SD4->D4_OP := cOp
	   SD4->D4_COD:=cRet
	   SD4->D4_QTDEORI:=SC2->C2_QUANT
	   SD4->D4_QUANT:=SC2->C2_QUANT
	   SD4->D4_DATA:=SC2->C2_EMISSAO
	   SD4->(MsUnlock())
	   dbSelectArea("SB2")
	   IF DBSEEK(XFILIAL("SB2")+cRet+"17")
	    RecLock("SB2",.F.)
	    SB2->B2_QEMP :=  SB2->B2_QEMP + SC2->C2_QUANT
	    SB2->(MsUnlock())
	   ELSE
	     RecLock("SB2",.T.)
	     SB2->B2_COD  := cRet
	     SB2->B2_LOCAL="17"
	     SB2->B2_QEMP := SC2->C2_QUANT
	     SB2->(MsUnlock()) 
	   ENDIF
	 Endif
	 dbSelectArea(cAliasQry)
	 dbCloseArea()
	ENDIF    
	RestArea(aArea)
Return