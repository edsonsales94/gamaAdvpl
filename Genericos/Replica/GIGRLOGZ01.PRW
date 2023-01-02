#include "protheus.ch"
#DEFINE  ARQLOG "\AUTOCOM\TEF" + cEmpAnt + cFilAnt + "\GIGRLOGZ01.LOG"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GIGRLOGZ01 ºAutor  ³Denis Polastri      º Data ³  28/01/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava log de envio e recebimento na tabela Z01. Esta tabela  º±±
±±º          ³e a base para o e-mail de "status report" da replica.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Gama Italy                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function GIGRLOGZ01(cCab)

Local _cModo := AllTrim(GetMv("MV_WFMODMF"))
Local xArea  := GetArea()
Local aCab   := Separa(cCab,";")
Local cIndZ01:= ""

If aCab[1] == "CAB"
	DbSelectArea("Z01")
	Reclock("Z01",.T.)
	Z01->Z01_FILIAL := 	xFilial("Z01")
	Z01->Z01_ARQUIV := SubStr(aCab[4],1,10)
	Z01->Z01_DTENVI := CtoD(aCab[2])
	Z01->Z01_HRENVI := aCab[3]
	If _cModo == SubStr(aCab[5],1,1)
		Z01->Z01_OPERAC := "E"
		LjWriteLog( ARQLOG, "Arquivo "+SubStr(aCab[4],1,10)+" [E]nviado para "+aCab[6] )
	Else
		Z01->Z01_OPERAC := "R"
		LjWriteLog( ARQLOG, "Arquivo "+SubStr(aCab[4],1,10)+" [R]ecebido da "+aCab[5] )
	EndIf
	Z01->Z01_ORIGEM := aCab[5]
	Z01->Z01_DESTIN := aCab[6]
	Z01->Z01_STATUS := .F.
	MsUnlock()
ElseIf aCab[1] == "TKT"
	DbSelectArea("Z01")
	DbSetOrder(1)
	DbGoTop()
	If DbSeek( xFilial("Z01") + PadR(aCab[4],12) + "E" )
		LjWriteLog( ARQLOG, "Alterando o status do arquivo "+SubStr(aCab[4],1,10)+" de [E]nviado para [R]ecebido " )
		Reclock("Z01",.F.)
		Z01->Z01_DTCONF := CtoD(aCab[2])
		Z01->Z01_HRCONF := aCab[3]
		Z01->Z01_OPERAC := "R"
		Z01->Z01_STATUS := .T.
		MsUnlock()
	Else
		LjWriteLog( ARQLOG, "Registro de log não encontrado na tabela Z01." )
		U_GIENVIACAB( 4,"", "Registro de log não encontrado na tabela Z01." )
	EndIf
EndIf

RestArea(xArea)

Return