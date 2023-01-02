/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa ³ BFATM05  ³ Por: Luiz Fernando C Nogueira ³ Data ³29.08.2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Efetua o estorno de transferencia de estoque de acordo com ³±±
±±³          ³ array contendo o NumSeq do Movimento e o numero do documento±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Ga.ma Italy                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
#include "rwmake.ch"

User Function BFATM05(_aNumSeq,_cDoc,_dEmissao,Doc,Serie)
Local _aTransfer := {{_cDoc,_dEmissao}} 		//Criacao da 1a. linha do array com o documento e data
Local i 
Local cCodOri, cAlmOri, cDescrOri, cUmOri, nQtde, dData, nQtde2, cCodDest, cAlmDest, cDescDest, cUmDest, cProximo
Private lmsErroAuto := .F.

for i := 1 to Len(_aNumSeq)

	cProximo	:= _aNumSeq[i]
	    
	dbSelectArea("SD3")
	dbSetOrder(4)
	dbSeek(xFilial("SD3")+cProximo)

	cCodOri 	:= SD3->D3_COD
	cUmOri		:= SD3->D3_UM
	cAlmOri 	:= SD3->D3_LOCAL
	cDescrOri	:= Space(15)

	dbSkip()

	cCodDest  		:= SD3->D3_COD
	cUmDest   		:= SD3->D3_UM
	cLocDest  		:= SD3->D3_LOCAL
	cDescrDest		:= Space(15)
	nQtde	 		:= SD3->D3_QUANT
	nQtde2	 		:= SD3->D3_QTSEGUM	
	
	dbSetOrder(1)

	// Alimento o array com os itens a serem transferidos
	aAdd(_aTransfer,{	cCodOri,;
						cDescrOri,;
						cUmOri,;
						cAlmOri,;
						Space(15),;
						cCodDest,;
						cDescrDest,;
						cUmDest,;
						cAlmDest,;
						Space(15),;
						Space(20),;
						Space(10),;
						Space(6),;
						ctod(''),;
						0,;
						nQtde,;
						nQtde2,;
						Space(1),;
						cProximo,;
						Space(10),;
						ctod(''),;
						Space(3),;
						"",;
						""})

next

// executo a rotina automatica somente quando o tamanho do array for maior que 1
if Len(_aTransfer) > 1
	MsExecAuto({|x,y| mata261(x,y)},_aTransfer,6)
endif
      
//-- Verifica se houve algum erro
If lmsErroAuto
	if Aviso("Pergunta","Transferencia nao gerada. Deseja visualizar o log?",{"Sim","Nao"},1,"Atencao")=1
		MostraErro()
	endif
EndIf    
Return()