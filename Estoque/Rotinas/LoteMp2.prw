#Include 'Protheus.ch'

User Function LoteMp2()
 Local cLot:=""
 Local cont:=1                   
 Local cProd:=SD1->D1_COD
 Local cLoc :=POSICIONE("SB1",1,XFILIAL("SB1")+SD1->D1_COD,"B1_LOCPAD")
 dbselectarea("SB8")
 DBSETORDER(03)
 dbseek(xfilial("SB8")+cProd+cLoc+Subs(DtoS(dDataBase),3,4)+strzero(cont,6))
 do while !SB8->(eof()) .and. SB8->(B8_FILIAL+B8_PRODUTO+B8_LOCAL+substr(B8_LOTECTL,1,4))==xfilial("SB8")+cProd+cLoc+Subs(DtoS(dDataBase),3,4)
     cont++
     SB8->(DBSKIP())
 enddo
 cLot:=Subs(DtoS(dDataBase),3,4)+strzero(cont,6)
Return(cLot)


