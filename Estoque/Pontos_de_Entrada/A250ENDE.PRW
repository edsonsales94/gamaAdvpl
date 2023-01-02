#include 'protheus.ch'                   
#include 'parmtype.ch'

User Function A250ENDE()
Local nRegSD4 := ParamIXB   //-- Numero do Registro da tabela SD4 que esta sendo atualizada
Local aAreaSB1:=  SB1->(GetArea())
Local aAreaSD4:=  SD4->(GetArea())
Local aAreaSC2:=  SC2->(GetArea())
Local aAreaSB2:=  SB2->(GetArea())
Local _cProces:=GETMV("MV_LOCPROC") 
Local cEnd,cEndereca,cApropri, cKanbam   
DBSELECTAREA("SD4")
DBGOTO(nRegSD4)
cEnd:=POSICIONE("SC2",1,XFILIAL("SC2")+SD4->D4_OP,"C2_XEND")
dbselectarea("SB1")
DBSEEK(XFILIAL("SB1")+SD4->D4_COD)
dbselectarea("SB2")
if DBSEEK(XFILIAL("SB2")+SD4->D4_COD+_cProces)
	cEndereca:=SB1->B1_LOCALIZ
	cApropri :=SB1->B1_APROPRI
	cKanbam  :=SB1->B1_XKANBAN
	IF ALLTRIM(cEndereca)<>"S" .OR. ALLTRIM(cApropri)<>"I" .OR. cKanbam=="S" .OR. ALLTRIM(cEnd)=="RETRABALHO"
	    cEnd := ""  
	ELSE
		if !(ExistCpo("SBE", _cProces+cEnd))
			ALERT("ENDERECO "+cEnd+" NAO CADASTRADO , CORRIJA A OP!")
		endif
	ENDIF
else
IF cApropri == "I"
	cEnd := ""
ENDIF
endif
RestArea(aAreaSB2)
RestArea(aAreaSB1)
RestArea(aAreaSD4)
RestArea(aAreaSC2)
//-- Customizações do Cliente
Return cEnd 