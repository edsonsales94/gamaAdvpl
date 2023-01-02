#Include "rwmake.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GeraNumBcoº Autor ³ Marcelo M Varella  º Data ³ 26/04/2007  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao que gera Numero bancario para alimentar E1_NUMBCO    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Opus Ltda.                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±*/

User Function GeraNNCnab()

DbSelectArea("SEE")
DbSetOrder(1) 
DbSeek (xFilial("SEE") + SEE->EE_CODIGO + SEE->EE_AGENCIA + SEE->EE_CONTA + SEE->EE_SUBCTA)

DbSelectArea("SE1")
DbSetOrder(1) 

Private cNossoNum 	:= ""
Private cNossoNum1	:= ""
Private cNossoNum2	:= ""
Private cNossoNum3	:= ""
   
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                             Banco do Brasil                                   ³
  ³ Nosso Numero com Registro : Sequencial de 10 caracteres                       ³
  ³                                                                               ³
  ³                             Banco Bradesco                                    ³
  ³ Nosso Numero com Registro : Sequencial de 11 caracteres + digito verificador  ³
  ³                             calculado pelo modulo 11 - base 7                 ³
  ³                                                                               ³
  ³                             Banco Sudameris                                   ³
  ³ Nosso Numero com Registro : Sequencial de 07 digitos + digito verificador     ³
  ³                                                                               ³
  ³                                                                               ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/


If 	Empty(SE1->E1_NUMBCO)

	If SEE->EE_CODIGO == "001"
		cNossoNum  := Soma1(Substr(SEE->EE_FAXATU,1,10))
		RecLock( "SEE" , .F. )
		SEE->EE_FAXATU := cNossoNum
		RecLock( "SE1" , .F. )
		SE1->E1_NUMBCO := cNossoNum
		MsUnlock()
	
	ElseIf SEE->EE_CODIGO == "237"
		cNossoNum1  := Soma1(Substr(SEE->EE_FAXATU,1,11))
		cCart		:= Substr(SEE->EE_SUBCTA,1,2)
		cNossoNum2  := Alltrim(cCart) + Alltrim(cNossoNum1)
		cNossoNum3  := Modulo11A(Alltrim(cNossoNum2))
		cNossoNum	:= Alltrim(cNossoNum1) + Alltrim(cNossoNum3)
		RecLock( "SEE" , .F. )
		SEE->EE_FAXATU := cNossoNum1
		RecLock( "SE1" , .F. )
		SE1->E1_NUMBCO := cNossoNum
		MsUnlock()

	ElseIf SEE->EE_CODIGO == "347"
		cNossoNum  := Soma1(Substr(SEE->EE_FAXATU,1,7))
		RecLock( "SEE" , .F. )
		SEE->EE_FAXATU := cNossoNum
		RecLock( "SE1" , .F. )
		SE1->E1_NUMBCO := cNossoNum
		MsUnlock()

	EndIf

Else

	cNossoNum := SE1->E1_NUMBCO

EndIf  

Return(cNossoNum)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ Modulo11 ³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASER DO ITAU COM CODIGO DE BARRAS     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Modulo11A(cData)
LOCAL L, D, P := 0
L := Len(cdata)
D := 0
D1:= ""
P := 1
While L > 0
	P := P + 1
	D := D + (Val(SubStr(cData, L, 1)) * P)
	If P = 7
		P := 1
	End
	L := L - 1
End

D := 11 - (mod(D,11))

If (D == 10)
	D1:= "P"
ElseIf (D == 11)
	D := 0
ElseIf (D == 0)
	D := 0
ElseIf (D == 1)
	D := 1
End


If 	(D == 10)
	Return(D1)
Else
	Return(str(D))
EndIf
