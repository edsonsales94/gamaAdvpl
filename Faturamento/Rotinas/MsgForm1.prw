#Include 'Protheus.ch'

User Function MsgForm1()
Local Msg1        
Local aArea		:= GetArea()
Local aAreaSD2		:=  SD2->(GetArea())
Local aAreaSB1		:=  SB1->(GetArea())
Msg1:=""
Msg2:=""
rec1:=SD2->(RECNO())                                            
dbselectarea("SD2")
dbsetorder(3)
DBSEEK(xfilial("SF2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
While !eof() .and. ALLTRIM(SD2->(D2_DOC+D2_SERIE))==ALLTRIM(SF2->F2_DOC+SF2->F2_SERIE)
   Msg2:=""
   If SM0->M0_CODIGO=='01' .AND. SM0->M0_CODFIL=='01' 
      If alltrim(SD2->D2_CF)$("5101/6101/5151/6151/5905/6905/5105/6105")             
        Msg2:= " Base Legal: Art. 13 VIII, c/c Art.16, III, do Regulamento aprovado pelo Decreto No. 23.994/03" 
        Msg2+= " Laudo Técnico de Inspeção - LTI - "
        tpuso:=POSICIONE("SB1",1,XFILIAL("SB1")+SD2->D2_COD,"B1_X_USO")
        If Left(SD2->D2_COD,3)=="APP"
         Msg2+= "Prancha: N. 00340/2021 - Validade 31/08/2023."
        Elseif Left(SD2->D2_COD,3)=="ASS"  
         Msg2+="Secador:  N. 00341/2021 - Validade 31/08/2023."
         //iif(tpuso==2," N. 1123/2015, válido até 31/08/2016."," N. 00338/2016, válido até 01/02/2017.")   
        Endif
        If !(alltrim(Msg2)$Msg1)
         Msg1+=Msg2                              
        Endif 
      EndIf   
   Endif
   SD2->(DBSKIP())
ENDDO
SD2->(DBGOTO(rec1))
RestArea(aAreaSD2)
RestArea(aAreaSB1)
RestArea(aArea)
Return(Msg1)

