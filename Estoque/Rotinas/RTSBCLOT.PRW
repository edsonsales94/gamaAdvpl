#Include 'Protheus.ch'

User Function RTSBCLOT()
LOCAL aAreaAnt := GETAREA()
LOCAL mLote:= ""          
Local xRastro:=POSICIONE("SB1",1,xfilial("SB1")+Acols[n][1],"B1_RASTRO")
IF xRastro=='N'
 Return(mLote)
ENDIF
BeginSql Alias "TRB"
	SELECT MAX(D5_LOTECTL) AS NUMLOTE
	FROM %Table:SD5% WHERE D5_FILIAL=%xFilial:SD5% AND D5_OP=%Exp:SC2->(C2_NUM+C2_ITEM+C2_SEQUEN)% And %notdel%   
Endsql         
DBSELECTAREA("TRB")
DBGOTOP()
If !TRB->(Eof())
  mLote := TRB->NUMLOTE
Endif                
DBSELECTAREA("TRB")
dbCloseArea()
RESTAREA(aAreaAnt)   // Retorna o ambiente anterior   

Return(mLote)
