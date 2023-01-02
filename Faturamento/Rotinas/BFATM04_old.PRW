/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa ³ BFATM04  ³ Por: Luiz Fernando C Nogueira ³ Data ³29.08.2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Efetua a transferencia de estoque de acordo com array con- ³±±
±±³          ³ tendo a estrutura do produto e numero do documento         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Ga.ma Italy                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
#include "rwmake.ch"

User Function BFATM04(_aEstrut,cDocto)
Local _aTransfer 	:= {{cDocto,dDataBase}}		//Criacao da 1a. linha do array com o documento e data
Local i 
Local cCod, cDescri, cUM, nQtde, dData, cProximo, cAlmOri, cObserv
Local cAlmDest := getMv("BR_LOCTRAN")
Private lmsErroAuto := .F.

for i := 1 to Len(_aEstrut)
    
	cCod		:= _aEstrut[i,1]
	cAlmOri		:= _aEstrut[i,3]
	
	//Posicionando o SB1 do produto 
	SB1->(MsSeek(xFilial("SB1")+cCod))
	cDescri		:= SB1->B1_DESC
	cUM			:= SB1->B1_UM
	nQtde		:= _aEstrut[i,2]
	nQtde2		:= ConvUM(cCod,nQtde,0,2)
	dData		:= dDataBase
	cProximo	:= ProxNum()
	cObserv		:= "Transferencia automatica Ref. NF: "+ _aEstrut[i,4]+"-"+_aEstrut[i,5]
	
	// Alimento o array com os itens a serem transferidos
	aAdd(_aTransfer,{	cCod,;
						cDescri,;
						cUM,;
						cAlmOri,;
						Space(15),;
						cCod,;
						cDescri,;
						cUM,;
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
						cObserv,;
						""	})
next

// executo a rotina automatica somente quando o tamanho do array for maior que 1
if Len(_aTransfer) > 1 
	MsExecAuto({|x,y| mata261(x,y)},_aTransfer,3)
endif

//-- Verifica se houve algum erro
If lmsErroAuto
	if Aviso("Pergunta","Transferencia nao gerada. Deseja visualizar o log?",{"Sim","Nao"},1,"Atencao")=1
		MostraErro()
	endif
EndIf

Return()