#include 'protheus.ch'                   
#include 'parmtype.ch'

User Function A250SPRC()   
Local cDocSeqPA,cDocSeqMP

cOP := PARAMIXB[1]
dDtRef := PARAMIXB[2] 



cDocSeqPA:=pesqSD3(cOP,'P')
cDocSeqMP:=pesqSD3(cOP,'R')

IF cDocSeqPA >= cDocSeqMP 
	//ALERT("PA")
	lRet := .T.//Customiza??esReturn lRet
ELSE
  Alert('<b>Aten??o</b><br>N?o ? poss?vel encerrar OP.<br><br><font color="#FF0000">?ltimo lan?amento deve ser de Produ??o.</font>')                                                                                                                                     
  	lRet := .F.//Customiza??esReturn lRet
ENDIF

Return (lRet)

Static Function pesqSD3(cOP,cTipo)
 cAliasSD3:= GetNextAlias()
 BeginSql Alias cAliasSD3 
 
 SELECT MAX(D3_NUMSEQ) DOCSEQ FROM %Table:SD3% WHERE   D3_FILIAL='01'

 
	 AND D3_OP=%exp:cOP% AND SUBSTRING(D3_CF,1,1)=%exp:cTipo%
 
 AND D_E_L_E_T_='' AND D3_ESTORNO <>'S'    
      

 EndSql
 dbSelectArea(cAliasSD3)  
 dbgotop()
 cDocSeq:=(cAliasSD3)->DOCSEQ
 dbSelectArea(cAliasSD3) 
 dbclosearea()
Return(cDocSeq)      
