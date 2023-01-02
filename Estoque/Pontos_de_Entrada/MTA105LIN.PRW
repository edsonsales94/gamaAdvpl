#Include 'Protheus.ch'

User Function MTA105LIN()
  Local lRet := .T. 
  Local _area := getarea()   
  Local mQb2:=0   
  Local cCod  := aCols[n,aScan(aHeader,{|x| Alltrim(x[2])="CP_PRODUTO"})]  
  Local cQuant:= aCols[n,aScan(aHeader,{|x| Alltrim(x[2])="CP_QUANT"})]                                                     
  Local cAlmox:= iif(LEFT(CA105NUM,1)=="D",GETMV("MV_LOCPROC"),aCols[n,aScan(aHeader,{|x| Alltrim(x[2])="CP_LOCAL"})])  //ALTERADO POR CLAUDIO 16/0/15 PARA AVALIAR LOCAL DE PRODUCAO PARA DEVOLUCAO                                                    
  Local cCC := aCols[n,aScan(aHeader,{|x| Alltrim(x[2])="CP_CC"})] 
  Local cJustif := aCols[n,aScan(aHeader,{|x| Alltrim(x[2])="CP_OBS"})]       
  If !(ALLTRIM(cJustif)$"TM-501") .and. len(alltrim(cCC))=0
      Alert("O campo centro de custo nao foi preenchido!")
       lRet := .F.
  Endif       
  mQb2 := Posicione("SB2",1,XFILIAL("SB2")+cCod+cAlmox,"B2_QATU")
  If mQb2 < cQuant   
      Alert("Saldo solicitado maior que o saldo no armazem!  Saldo atual :"+str(mQb2,10,3))
      lRet := .F.
  Endif
  RestArea(_area) 
Return( lRet)