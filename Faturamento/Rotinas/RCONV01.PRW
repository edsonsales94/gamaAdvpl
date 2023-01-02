#include "rwmake.ch"
#include "topconn.ch"

User Function RCONV01()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RCONV01   ºAutor  ³Osmil Leite         º Data ³  25/02/2008 º±±
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

@ 96,42 TO 323,505 DIALOG oDlg TITLE "Conversao do Cadastro de Politica Comercial"
@ 05,10 TO 86,222
@ 91,165 BMPBUTTON TYPE 1 ACTION Procp1()
@ 91,195 BMPBUTTON TYPE 2 ACTION Close(oDlg)
@ 13,25 SAY "Este programa coverte a Politica Comercial"

ACTIVATE DIALOG oDlg CENTERED

Return nil

Static function procp1()
processa({|| procp1a(),"Atualizando Arquivo"})
return nil

Static Function PROCP1a()

dbSelectArea("SA1")
dbgotop()

ProcRegua(LastRec())

While !Eof()
	
	IncProc('Atualizando Politica Comercial')
	
		dbSelectArea("SZ1")
		RecLock("SZ1",.T.)
		
		SZ1->Z1_FILIAL	:=	xFilial("SZ1")
		SZ1->Z1_SEQ		:=	"001"
		SZ1->Z1_CLIENTE	:=	SA1->A1_COD
		SZ1->Z1_LOJA	:=	SA1->A1_LOJA
		SZ1->Z1_NOME	:=	SA1->A1_NOME
		SZ1->Z1_DATADE	:=	CTOD("25/02/2009")
		SZ1->Z1_DATAATE	:= 	CTOD("03/03/2010")
		SZ1->Z1_VLRMIN	:=	500
		SZ1->Z1_PRAZO	:=	42
		SZ1->Z1_PRAZOE	:=	0
		SZ1->Z1_NUMPAR	:= 	3
		SZ1->Z1_NUMPARE	:=	0
		SZ1->Z1_DATA	:=  dDatabase
		SZ1->Z1_DESCON	:=	12
		SZ1->Z1_DESCONE	:=	0
		SZ1->Z1_DESCDIS	:=	0
		SZ1->Z1_DESCANT	:=	0
		SZ1->Z1_DESCAV7	:=	0.10
		SZ1->Z1_USRINC	:=	"Administrador"
		SZ1->Z1_USERLGI	:=	"rnA aid dsmaoti•r"
		
		MSUNLOCK()
	
	dbSelectArea("SA1")
	dbSkip()
	
EndDo

Return(.T.)

