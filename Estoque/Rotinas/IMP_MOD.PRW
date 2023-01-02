#Include "Rwmake.ch"
#include "topconn.ch"

User Function AJU_MOD() //Entrada na BRASITECH
Private cCadastro := "Ajuste MODs errados no apontamento da OP - SD3"
Private cAlias    := "SD3"

SD3->(dbSetOrder(2))
SG1->(dbSetOrder(1))


IF !Pergunte("IMPBN2", .T.)
	Return Nil
ENDIF

Private cNomeTxt := "\data\tlog\emp"+cNumEmp+"-aju-mod"+"-"+dTos(dDatabase)+strtran(time(),":","")+".LOG"
dData1 := MV_PAR01
dData2 := MV_PAR02


cSelect := "* "
cFrom   := RetSqlName('SD3')  
cWhere  := RetSqlName(cAlias) + '.D_E_L_E_T_ <> ' + CHR(39) + '*' + CHR(39) + ' AND '+"D3_FILIAL  = '" + xFilial(cAlias)+"' "
cWhere  += " AND (D3_TM =  '200' OR D3_TM = '999' )"
cWhere  += " AND D3_EMISSAO BETWEEN  '"+DTOS(dData1)+"'  AND    '"+DTOS(dData2)+"' "
cOrder  := " D3_DOC,D3_OP,D3_TM,D3_COD "

cQuery  :=	' SELECT '   + cSELECT + ;
' FROM '     + cFROM   + ;
' WHERE '    + cWHERE  + ;
' ORDER BY '+cOrder

TcQuery cQuery New Alias 'TRA'

IF ! Used()
	MsgBox(cQuery+'. Query errada','Erro!!!','STOP')
ENDIF

DbSelectArea('TRA')
TRA->(LastRec())
nCnt := TRA->(Recno())

ProcRegua(nCnt)

TRA->(DbGoTop())

If Empty(nCnt)
	MsgBox("Nao existem NF neste periodo" )
	Return Nil
Endif

u_GeraLog("*****************************************************************"                            , cNomeTxt)
U_GeraLog("Ajuste MOD "+Alltrim(CUSERNAME)                                     , cNomeTxt)
U_GeraLog("DATA "+Transform(dDatabase,"99/99/9999") +" HORA:"+Time()                                     , cNomeTxt)



DO WHILE !TRA->(Eof())
	
	cDoc   :=TRA->D3_DOC
	cOp    :=TRA->D3_OP
	cCodPai:= ""
	
	
	DO WHILE !TRA->(EOF()) .AND. TRA->D3_DOC == cDoc .AND. TRA->D3_OP == cOp
		
		IF ALLTRIM(TRA->D3_TM) == '200'
			cCodPai := TRA->D3_COD
			nQuant  := TRA->D3_QUANT
		ENDIF
		
		IF LEFT(TRA->D3_COD,3) == 'MOD' .AND. TRA->D3_DOC == cDoc .AND. TRA->D3_OP == cOp
			
			nQtdBOM := Posicione( "SG1" , 1 , xFilial("SG1")+cCodPai+TRA->D3_COD , "G1_QUANT" )
			nNecQtde:= ( nQtdBOM * nQuant )
			IF nNecQtde > 0
				
				SD3->( dbSeek( xFilial("SD3")+cDoc+TRA->D3_COD  ) )
				RecLock("SD3",.F.)
				SD3->D3_QUANT := nNecQtde
				msunlock("SD3")
			ELSE
				
				u_GeraLog(" Codigo Pai: "+cCodPai+" Componete: "+TRA->D3_COD+" OP: "+cOp+" Doc: "+cDoc+" Necessidade: "+Transform(nNecQtde, "@E 999,999.99") , cNomeTxt)
				
			ENDIF
			
		ENDIF
		
		TRA->( dbSkip() )
		
	ENDDO
	
ENDDO    

TRA->(dbClosearea())
dbselectarea("SB2")       
DBSETORDER(1)
DBSEEK(XFILIAL("SB2")+"MOD") 
DO WHILE !EOF() .and. LEFT(SB2->B2_COD,3)=="MOD"
 IF LEFT(SB2->B2_COD,3)=="MOD"
  Reclock("SB2",.F.)
  SB2->B2_QATU:=0
  SB2->B2_VFIM1:=0
  SB2->B2_CM1:=0
  SB2->B2_QEMP:=0
  SB2->B2_CMFIM1:=0 
  SB2->(Msunlock())
 ENDIF
 DBSKIP()
ENDDO

RETURN NIL





