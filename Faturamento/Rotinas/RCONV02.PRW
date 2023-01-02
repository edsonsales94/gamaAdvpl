#include "rwmake.ch"
#include "topconn.ch"

User Function RCONV02()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RCONV02   ºAutor  ³Osmil Leite         º Data ³  25/02/2008 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa para converter o cadastro de politica comercial   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP10 - GAMA ITALY                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("ODLG,CINDDQT,CCLI,CCOD,CMSG")

oDlg    := ""
cString := " "
cRetorno:= .T.
cLojConv:= "01"

@ 96,42 TO 323,505 DIALOG oDlg TITLE "Atualizacao da Politica Comercial"
@ 05,10 TO 86,222
@ 91,165 BMPBUTTON TYPE 1 ACTION Procp1()
@ 91,195 BMPBUTTON TYPE 2 ACTION Close(oDlg)
@ 13,25 SAY "Atualizacao da Politica Comercial"

ACTIVATE DIALOG oDlg CENTERED

Return nil

Static function procp1()
processa({|| procp1a(),"Atualizando Arquivo"})
return nil

Static Function PROCP1a()

dbSelectArea("SZ1")
dbgotop()

ProcRegua(LastRec())

While !Eof()
	
	IncProc('Atualizando Politica Comercial')
	
		dbSelectArea("SA1")
		dbSetOrder(2)
		dbSeek(xFilial("SA1")+SZ1->Z1_NOME)
		
		If Found()

		RecLock("SZ1",.F.)
		
		SZ1->Z1_MSRESP	:= 	'*'		
		SZ1->Z1_CLIENTE	:=	SA1->A1_COD
		SZ1->Z1_LOJA	:= 	SA1->A1_LOJA
		
		MSUNLOCK()
		
		EndIf
	
	dbSelectArea("SZ1")
	dbSkip()
	
EndDo

Return(.T.)

