#include "rwmake.ch"
#include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ BRASX1         ³ Por: Adalberto Moreno Batista     ³ Data ³21.04.2011³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRASX1(aRegs,aCampo)
Local nI, nJ, cGrupo, cOrdem, lNovo

SX1->(dbSetOrder(1))
For nI := 01 to Len(aRegs)
	cGrupo 	:= PadR(aRegs[nI,1], Len(SX1->X1_GRUPO))
	cOrdem 	:= PadR(aRegs[nI,2], Len(SX1->X1_ORDEM))
	lNovo	:= SX1->(!dbSeek(cGrupo+cOrdem))
	
	SX1->(RecLock("SX1", lNovo))
	For nJ := 1 to len(aCampo)
    	SX1->(FieldPut(FieldPos(aCampo[nJ]), aRegs[nI,nJ]))
	Next
	SX1->(MsUnlock())
Next

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ BRCARAC        ³ Por: Adalberto Moreno Batista     ³ Data ³13.06.2011³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRCARAC(cBrVar)
Local lRet 		:= .T.
Local cBrParam 	:= AllTrim( GetMV("BR_CARACT",.F.,"~`!@#$%^&*()+={}[] :;<>,.?/|\") )
Local cAspSimp	:= "'"
Local cAspDupl	:= '"'
Local nK

For nK := 1 to Len( AllTrim(cBrVar) )

	//validacao para evitar que o campo tenha aspas simples ou duplas ou os caracteres especiais do parametro BR_CARACT
	if 	Substr( AllTrim(cBrVar), nK, 1 ) == cAspSimp .or.;
		Substr( AllTrim(cBrVar), nK, 1 ) == cAspDupl .or.;
		Substr( AllTrim(cBrVar), nK, 1 ) $ cBrParam
		
		lRet := .F.
		exit

	endif
	
Next

if !lRet
	MsgBox('Não é permitido aspas (simples ou duplas) ou os caracteres especiais ' + cBrParam,"Atenção! Específico Brasitech","ERRO")
endif

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ BRAZSOCNF      ³ Por: Adalberto Moreno Batista     ³ Data ³26.12.2012³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRAZSOCNF()
Local cRet

if SF2->F2_TIPO $ "DB"
	cRet := GetAdvFVal("SA2", "A2_NOME", xFilial("SA2") + SF2->(F2_CLIENTE + F2_LOJA), 1)

else
	cRet := GetAdvFVal("SA1", "A1_NOME", xFilial("SA1") + SF2->(F2_CLIENTE + F2_LOJA), 1)   

endif

Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ BLEGBLOQ       ³ Por: Adalberto Moreno Batista     ³ Data ³26.12.2012³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BLEGBLOQ(nTipo)
Local cRet

nTipo := iif(nTipo = NIL, 1, nTipo)

if Substr(SF2->F2_X_OPLOG, nTipo, 1) = "S"
	cRet := "Bloqueado"

elseif Substr(SF2->F2_X_OPLOG, nTipo, 1) = "N"
	cRet := "Liberado"

else
	cRet := "N/ Controla"

endif

Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ criaSB2       ³ Por: Luiz Fernando      			  ³ Data ³28.07.2014³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function XcriaSB2

Local aArmazem 	:= {}
Local aProdutos := {}
Local nCount	:= 0 
Local aArea 	:= getArea()
Local aAreaSB1 	:= SB1->(getArea())
Local aAreaSB2 	:= SB2->(getArea())
Local nx, ny

if cFilAnt == "01"
	aArmazem := {"60","61","62","68","69","70"}
elseif cFilAnt == "03"
	aArmazem := {"63","64","65","66","67"}
endif	

dbSelectArea("SB1")
dbSetOrder(1)                                
SB1->(dbSeek(xFilial("SB1") + "A")) 
do while SB1->(!eof() .and. B1_FILIAL = xFilial("SB1") .and. substr(B1_COD,1,1) = "A")
	if SB1->( (substr(B1_COD,1,3) $ "ADM/AED/AMC/APP/ASS" .or. substr(B1_COD,1,2) = "AB") .and. RIGHT(Alltrim(B1_COD),1)!= "N" ) 
		aadd(aProdutos ,SB1->B1_COD)
	endif
	SB1->(dbSkip())
enddo

dbSelectArea("SB2")
dbSetOrder(1)      

For nx=1 to Len(aProdutos)
	For ny=1 to Len(aArmazem)
		if(SB2->(!dbseek(xFilial("SB2")+aProdutos[nx]+aArmazem[ny])))
			criaSB2(aProdutos[nx],aArmazem[ny])
			nCount ++
		endif
	next
next

Alert(cvaltochar(nCount))

restArea(aAreaSB1)
restArea(aAreaSB2)
restArea(aArea)
return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³  trocSA1	      ³ Por: Luiz Fernando     			  ³ Data ³29.01.2015³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±Gatilho para alternar os vendedores do cadastro do cliente entre o principal e ±±
±±o alternativo. Altera também o modo de atendimento do cliente(A1_XATTCLI) 	 ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function trocSA1
Local cTitulo 	:= "Alternar vendedores"
Local cVend
Local cAttCli	:= Iif(alltrim(M->A1_XATTCLI) == "NORMAL","TVENDAS-N","NORMAL")

If MsgBox("Confirma alternação de vendedores?", cTitulo, "YESNO" )
	cVend 			:= M->A1_VEND
	M->A1_VEND 		:= M->A1_XVENALT
	M->A1_XVENALT 	:= cVend
	M->A1_XATTCLI	:= cAttCli
endif

MsgAlert("Vendedores alternados entre principal e alternativo","Alternar vendedores")

return 
