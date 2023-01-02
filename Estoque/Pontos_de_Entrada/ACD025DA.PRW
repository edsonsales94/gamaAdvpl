#Include "PROTHEUS.CH"    
#include "TOPCONN.CH"

User Function ACD025DA(NOP)          
LOCAL aAreaAnt := GETAREA()
cOp      := NOP
cOperacao:=""
cRecurso :=""
cOperador:=""
nQtd     :=1
cTransac :=""  

//alert("entrando no ponto de entrada ACD025GR")
BeginSql Alias "TRB"
	SELECT D3_COD,D3_LOCAL,D3_NUMSEQ,D3_DOC,D3_XENDER 
	FROM %Table:SD3% SD3 WHERE D3_FILIAL=%xFilial:SD3% AND D3_OP=%Exp:cOp%  AND LEFT(D3_CF,2)='PR' And SD3.%notdel%
	AND (SELECT DA_SALDO 
	FROM %Table:SDA% SDA
	WHERE DA_FILIAL=%xFilial:SDA%  AND DA_PRODUTO=D3_COD AND DA_LOCAL=D3_LOCAL AND DA_NUMSEQ=D3_NUMSEQ AND DA_SALDO=DA_QTDORI And SDA.%notdel%)>0
Endsql    
lMsHelpAuto := .T.  // se .t. direciona as mensagens de help
     
DBSELECTAREA("TRB")
DBGOTOP()
DO WHILE !TRB->(Eof())
  If Posicione("SB1",1, xFilial("SB1")+TRB->D3_COD, "B1_LOCALIZ") <> "S"
   DBSELECTAREA("TRB")
   dbCloseArea() 
   RESTAREA(aAreaAnt)   // Retorna o ambiente anterior   
   Return 
  Endif  
  _cLocPad := ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+TRB->D3_COD,"B1_LOCPAD"))   
  _cLocDes := _cLocPad  
  _cEndDes := IIF(_cLocPad==GETMV("MV_LOCPROC") ,IIF(LEN(ALLTRIM(TRB->D3_XENDER))==0,"PRODUCAO",TRB->D3_XENDER),"TRANSITO")        
  //-- Rotina de customização do usuário
   //ALTERDAO em 29/04/15 por CLAUDIO para endereçar a producao pelo apontamento atravez do campo customizado D3_XENDER
  lMsErroAuto := .F.
  dbSelectArea("SDA") // Seleciona Saldo a Endereçar
  DBSETORDER(1)  // DA_FILIAL + DA_COD + DA_LOCAL + DA_NUMSEQ
  If DbSeek(xFilial("SDA")+TRB->D3_COD+TRB->D3_LOCAL+TRB->D3_NUMSEQ+TRB->D3_DOC ) 
    	_aCab := {}
		_aItem:= {}

		Aadd(_acab, {"DA_FILIAL"	, xFilial("SDA") 	,NIL})
		Aadd(_acab, {"DA_PRODUTO"	, SDA->DA_Produto	,NIL})
		Aadd(_acab, {"DA_LOCAL"		, SDA->DA_LOCAL		,NIL})
		Aadd(_acab, {"DA_NUMSEQ"	, SDA->DA_NUMSEQ     ,NIL})						
		Aadd(_acab, {"DA_DOC"		, SDA->DA_DOC		,NIL})
		Aadd(_acab, {"DA_SERIE"		, SDA->DA_SERIE		,NIL})
		Aadd(_acab, {"DA_CLIFOR"	, SDA->DA_CLIFOR	,NIL})
		Aadd(_acab, {"DA_LOJA"		, SDA->DA_LOJA		,NIL})
		
		Aadd(_aitem,{"DB_ITEM"		, "0001"			,NIL})
  		Aadd(_aitem,{"DB_LOCALIZ"	, _cEndDes			,NIL})								
		Aadd(_aitem,{"DB_DATA"		, ddatabase			,NIL})								
		Aadd(_aitem,{"DB_QUANT"	 	, SDA->DA_SALDO		,NIL})
		
		//Endereçamento
    	MSExecAuto({|X,Y,Z|MATA265(X,Y,Z)},_acab,{_aitem},3) 
		If lMsErroAuto
			Mostraerro()
		endif
  ENDIF 
  DBSELECTAREA("TRB")
  TRB->(dbskip()) 
Enddo                
DBSELECTAREA("TRB")
dbCloseArea()
RESTAREA(aAreaAnt)   // Retorna o ambiente anterior  
Return