#Include "Protheus.ch"


/*/
+-------------------------------------------------------------------------------+
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Programa  ¦ FISVALNFE  ¦ Autor ¦Orismar Silva         ¦ Data ¦ 27/09/2022 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ DESCRIÇÃO ¦ Ponto de entrada para validação na transmissão da nota fiscal.¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
+-------------------------------------------------------------------------------+
/*/



User Function FISVALNFE()

Local _ldTra		:=.T.	

Local cTipo		  :=PARAMIXB[1]	
Local cEspec	  :=PARAMIXB[8]	
Local cFormul	  :=PARAMIXB[9]	
Local cCfop       := GetMV("MV_XCFAMOS")
Local cEmissao	  :=PARAMIXB[3]	
Private _xdDoc	  :=PARAMIXB[4]  
Private _xdSerie  :=PARAMIXB[5]  
Private _xdCliente:=PARAMIXB[6]  
Private _xdLoja   :=PARAMIXB[7]	
Private _xdFilial :=PARAMIXB[2]	




_xAls  := MontaCons()
ldShow := .F.
lCfop  := .T.
_xdMsg := " O(s) produto(s) : ( "

		
While !(_xAls)->(Eof())   	
    If EMPTY(ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+(_xAls)->D2_COD,"B1_DCRE"))) .and. ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+(_xAls)->D2_COD,"B1_TIPO")) = "PA"
	      _xdMsg += iIf(ldShow,",","") + (_xAls)->D2_COD
           ldShow := .T.
    EndIf	  
    
    if (RTRIM((_xAls)->D2_CF) $ cCfop)
       lCfop := .F.
    endif
    (_xAls)->(dbSkip())
EndDo


_xdMsg += " ), não possui DCRE informado." +Chr(13) + Chr(10)
_xdMsg += "Favor procurar o setor de Gestão do PCP!"
           

If ldShow .and. RTRIM(SM0->M0_CODFIL) = '01' .and. lCfop	   
   MsgStop(_xdMsg)
   _ldTra := .F.
EndIf
	
Return _ldTra



Static Function MontaCons()

Local cQry := ""

cQry := " SELECT DISTINCT D2_DOC,D2_SERIE,D2_PEDIDO,D2_COD, D2_CLIENTE,D2_LOJA,D2_TES,D2_CF "
cQry += " FROM " + RetSqlName('SD2') + " D2 "
cQry += " WHERE D2.D_E_L_E_T_ = '' "
cQry += " And D2_DOC = '" + _xdDoc + "'"
cQry += " And D2_SERIE = '" + _xdSerie + "'"
cQry += " And D2_CLIENTE = '" + _xdCliente + "'"
cQry += " And D2_LOJA    = '" + _xdLoja + "'"
cQry += " And D2_FILIAL  = '" + _xdFilial + "'"

cAls := MpSysOpenQuery(cQry)

Return cAls
