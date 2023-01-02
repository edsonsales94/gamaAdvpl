#include "Rwmake.ch"
#include "Topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MT140SAI  º Autor ³ Rodrigo Ramos  	  º Data ³ 21/08/2012   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Grava o Log da Nota Fiscal de Entrada                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasitech                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MT140SAI()    

Local aArea		:= GetArea()
Local aAreaSF1	:= SF1->( GetArea() )
Local cDoc		:= SF1->F1_DOC
Local cSerie	:= SF1->F1_SERIE
Local cFornec	:= SF1->F1_FORNECE
Local cLoja		:= SF1->F1_LOJA
Local cTipo		:= SF1->F1_TIPO  
Local dData		:= DATE() //Adicionado pelo Ronaldo
Local cTime		:= TIME() //Adicionado pelo Ronaldo
                                                                
If Inclui

	DbSelectArea("SF1")
	dbSetOrder(1)


		If dbSeek(xFilial("SF1")+cDoc+cSerie+cFornec+cLoja+cTipo)

			While SF1->(!Eof()) .And. F1_FILIAL == xFilial("SF1") .And. F1_DOC == cDoc .And. F1_SERIE == cSerie .And. F1_FORNECE == cFornec .And. F1_LOJA == cLoja
                        


				If SF1->( RecLock("SF1",.F.) )

				//Cabeçalho da NF
				SF1->F1_XDATA	:= dData
				SF1->F1_XHORA	:= cTime
				SF1->F1_XUSUAR	:= SubStr(cUsuario,7,15)//Nome do Usuario
				SF1->( MsUnlock() )

				EndIf                       

		   		SF1->(dbSkip(1))


			EndDo

		EndIf
         
EndIf

//SF1->(dbGoTo())
RestArea(aArea)
RestArea(aAreaSF1)


Return()                                                  
