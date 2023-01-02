#Include "Rwmake.ch" 
#Include "Protheus.ch" 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PESQAR2   ³ Autor ³ Luiz Fernando/ Roanldo ³ Data ³ 07.12.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa para gatilhar exeutivo e canal do cliente no A.R.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Brasitech                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Data      ³ Programador   ³ Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³																		   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


User Function PESQAR2()


Local aArea	   		:= GetArea()
Local aAreaSA1 		:= SA1->(GetArea())
Local aAreaSA3		:= SA3->(GetArea())
Local aAreaSZB		:= SZB->(GetArea())
Local cCliente 		:= SA1->A1_COD
Local cLoja 	 	:= SA1->A1_LOJA	
Local cCliszg := cCliente
Local cLojaszg := cLoja
Local cRepres  		:= ""
Local cExec    		:= ""
Local cCanal   		:= ""
Local cNomeExec   	:= ""
Local cNomeCanal   	:= ""



dbSelectArea("SA1")
if dbSeek(xFilial("SA1")+cCliszg+cLojaszg) 
	cRepres  := SA1->A1_VEND
Endif 

dbSelectArea("SA3")
if dbSeek(xFilial("SA3")+cRepres) 
	cExec    := SA3->A3_XEXECUT
Endif

dbSelectArea("SA3")
if dbSeek(xFilial("SA3")+cRepres) 
	cCanal   := SA3->A3_XCANAL
Endif 

dbSelectArea("SZB")
if dbSeek(xFilial("SZB")+cExec) 
	cNomeExec := SZB->ZB_NOME	
Endif 

if dbSeek(xFilial("SZB")+cCanal) 
	cNomeCanal := SZB->ZB_NOME	
Endif             

RestArea(aArea)
RestArea(aAreaSA1)
RestArea(aAreaSA3)
RestArea(aAreaSZB)

Return (cNomeExec)