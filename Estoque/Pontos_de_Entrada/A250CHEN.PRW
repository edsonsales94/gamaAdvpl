#include 'protheus.ch'
#include 'parmtype.ch'

user function A250CHEN()
Local aSD4   := ParamIXB[1]   //-- Informações do Empenho SD4
Local nItem  := ParamIXB[2]   //-- Posição do Registro processado
Local nCampo := ParamIXB[3]   //-- Posição do Item Processado
Local cEnd   := SC2->C2_XEND   //'Endereço a ser forçado para verificação de saldos'
Local aAreaSB1		:=  SB1->(GetArea())
Local _cProces:=GETMV("MV_LOCPROC") 
dbselectarea("SB1")
DBSEEK(XFILIAL("SB1")+SB2->B2_COD)
cEndereca:=SB1->B1_LOCALIZ
cApropri:=SB1->B1_APROPRI
cKanbam :=SB1->B1_XKANBAN 
IF ALLTRIM(cEndereca)<>"S" .OR. ALLTRIM(cApropri)<>"I" .OR. cKanbam=="S"
    cEnd := ""  
 ELSE
  IF !(ExistCpo("SBE", _cProces+cEnd))
    ALERT("ENDERECO "+cEnd+" NAO CADASTRADO , CORRIJA A O!P")
  ENDIF
Endif         
RestArea(aAreaSB1)
Return cEnd  //-- Retorna um endereço valida para verificação de saldo.	
