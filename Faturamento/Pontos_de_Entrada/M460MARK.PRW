#include "rwmake.ch"
#include "protheus.ch" 

/*/

覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		M460MARK                                                     /@
@type			Ponto de entrada                                             /@
@date			24/07/2014                                                   /@
@description	Permite ou n縊 a gera鈬o de uma NF ? partir dos ?tens 
				marcados. Espera o retorno .T. ou .F.                        /@
@author			                                                             /@
@use			Especifico Gama Italy                                        /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?

/*/
User Function M460MARK()
Local cMarca		:= PARAMIXB[1]
Local lInverte		:= PARAMIXB[2]
Local lMarcado ,lVerifA,lVerifB
Local cPedido		:= ""			
Local aArea			:= GetArea()
Local aAreaSC9		:= SC9->(GetArea())
Local aAreaSC5		:= SC5->(GetArea())
Local aAreaSC6		:= SC6->(GetArea())
Local oBrowse		:= GetMBrowse()
Local cFilNativ		:= oBrowse:oData:cFilterNative
Local aRegistros	:= {}		//armazena os recnos do SC9 de todos os registros marcados
Local aCritPed		:= {}		//utilizado para nao repetir mensagem, no mesmo pedido, sobre criticas no pedido de vendas
Local cMsgBoxA 		:= ""
Local cMsgBoxB		:= ""
Local cEol			:= chr(13) + chr(10)
Local cCliArm 		:= getmv("MV_XFOREDI")
Local cLojArm 		:= getmv("MV_XLOJEDI")
Local nX, nK

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Setando as ordens de tabelas        
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
SC5->(dbSetOrder(1))
SC6->(dbSetOrder(1))
SC9->(dbSetOrder(1))

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Selecionando registros marcados no SC9       
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
cQuery1 := "SELECT C9_PEDIDO, C9_OK, R_E_C_N_O_ REGISTRO "
cQuery1 += "FROM " + RetSQLName("SC9") + " SC9 "
cQuery1 += "WHERE "
if lInverte
	cQuery1 +=	"SC9.C9_OK != '" + cMarca + "' "
else
	cQuery1 +=	"SC9.C9_OK = '" + cMarca + "' "
endif
cQuery1 +=		"AND SC9.C9_NFISCAL = '         ' "
cQuery1 +=		"AND SC9.C9_BLEST = '  ' "
cQuery1 +=		"AND SC9.C9_BLCRED = '  ' "
cQuery1 +=		"AND SC9.D_E_L_E_T_ = ' ' "
cQuery1 += "ORDER BY C9_PEDIDO "

if Select("TRAB") > 0
	TRAB->(dbCloseArea())
endif

cQuery1 := ChangeQuery(cQuery1)
dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery1),"TRAB", .F., .T.)

TRAB->(dbGoTop())
dbSelectArea("SC9")

do while TRAB->(!eof())
    
	cPedido := TRAB->C9_PEDIDO
	aCritPed	:= {}		//utilizado para nao repetir mensagem, no mesmo pedido, sobre criticas no pedido de vendas
	aRegistros	:= {}
	lVerifA	 	:= .T.
	lVerifB 	:= .T.
	do while TRAB->(!eof() .and. C9_PEDIDO == cPedido)

		SC9->(dbGoTo(TRAB->REGISTRO))
		
		if &cFilNativ
	
			lMarcado	:= iif( lInverte, SC9->C9_OK != cMarca .and. !A460AVALIA(), SC9->C9_OK == cMarca)
			
			if lMarcado
			
				//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
				// Posicionamento de tabelas
				//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
				SC5->(dbSeek(xFilial("SC5") + SC9->C9_PEDIDO))
				SC6->(dbSeek(xFilial("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM + SC9->C9_PRODUTO))
				
				if SC6->(FieldPos("C6_X_NUMZL")) > 0 
					if SC6->(!empty(C6_X_NUMZL) .and. C6_XOPER = "03")
						lVerifA := A_M460MARK()
						if !lverifA
							aAdd(aRegistros, {TRAB->REGISTRO, lVerifA })
						endif
					endif
				endif
				if aScan(aRegistros,{|x| x[1] == TRAB->REGISTRO}) == 0
					if	SC5->C5_TIPO = "B" .and. SC6->C6_CF = "6905" .and. Posicione("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_ESTOQUE") = "N" .AND.;
					SC6->C6_CLI = cCliArm .and. SC6->C6_LOJA = cLojArm
						lVerifB := B_M460MARK(C9_PRODUTO,C9_LOCAL,C9_QTDLIB)
						if !lverifB
							aReg := C_M460MARK(cPedido,lverifB)
							for nx := 1 to len(aReg)
								aAdd(aRegistros, {aReg[nx][1],aReg[nx][2]} )
							next
						endif  
					endif
				endif
			endif
		endif
		TRAB->(dbSkip())
	enddo

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Caso retorne falso na marca鈬o do registro, desmarco na tabela para nao gerar
	// a nota fiscal
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	for nK := 1 to Len(aRegistros)
		if !aRegistros[nK,2]
			SC9->(dbGoTo(aRegistros[nK,1]))
			SC9->(RecLock("SC9",.F.))
			SC9->C9_OK	:= iif(lInverte, cMarca, "")
			SC9->(MsUnlock())
			if Empty(aScan(aCritPed, SC9->C9_PEDIDO)) .and. !lVerifA 
				aAdd(aCritPed, SC9->C9_PEDIDO)
				cMsgBoxA += "Pedido:"+SC9->C9_PEDIDO+"." + cEol				
			elseif Empty(aScan(aCritPed, SC9->C9_PEDIDO)) .and. !lVerifB
				aAdd(aCritPed, SC9->C9_PEDIDO)
				cMsgBoxB += "Pedido:"+SC9->C9_PEDIDO+"." + cEol 
			endif
		endif
	next
enddo
	
if Select("TRAB") > 0
	TRAB->(dbCloseArea())
endif

if len(cMsgBoxA) > 0
	MsgBox("Alguns itens bonificados n縊 foram faturados e "+cEol+"s? ser縊 faturados ap?s os itens de venda."+cEol+cMsgBoxA, "ATENﾇﾃO!" , "ERRO")
endif

if len(cMsgBoxB) > 0
		MsgBox("N縊 h? saldo para um ou mais itens do(s) pedido(s) "+cEol+"de remessa de armazenagem CFOP=6905."+cEol+cMsgBoxB, "ATENﾇﾃO!" , "ERRO")
endif

RestArea(aAreaSC5)
RestArea(aAreaSC6)
RestArea(aAreaSC9)
RestArea(aArea)
Return(.T.)


/*/

覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		A_M460MARK                                                    /@
@type			Static Function                                               /@
@date			                                                              /@
@description	Critica item do pedido de vendas que possui Tes de bonifica鈬o/@
				caso no mesmo pedido contenha itens de venda que n縊 foram    /@
				faturados													  /@
				A mensagem nao ? repetida para o mesmo pedido. Retorno T/F    /@
@author			Luiz Fernando                                                 /@
@use			Especifico Gama Italy                                         /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?

/*/
Static Function A_M460MARK()
Local lRet		:= .T.
Local aAreaSC9	:= SC9->(GetArea())

cQuery := "select C6_NOTA,C6_SERIE,C6_DATFAT "
cQuery += "from "+RetSQLName("SC6")+" WHERE C6_X_NUMZL = '"+SC6->C6_X_NUMZL+"' "
cQuery += "AND D_E_L_E_T_ = '' AND C6_XOPER = '01' "
	
if Select("TRL") > 0
	TRL->(dbCloseArea())
endif

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),"TRL", .F., .T.)

TRL->(dbGoTop())

do while TRL->(!eof())
	if TRL->(empty(C6_NOTA+C6_SERIE+C6_DATFAT))
		lRet	:= .F.
	endif
	TRL->(dbSkip())
Enddo

if Select("TRL") > 0
	TRL->(dbCloseArea())
endif

RestArea(aAreaSC9)

Return(lRet)

/*/

覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		B_M460MARK                                                   /@
@type			Static Function                                              /@
@date			                                                             /@
@description	Critica item do pedido em opera鈬o de remessa de armazenagem /@
				caso n縊 possua saldo, pois a TES n縊 movimenta estoque.     /@
				A mensagem nao ? repetida para o mesmo pedido. Retorno T/F   /@
@author			Luiz Fernando                                                /@
@use			Especifico Gama Italy                                        /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?

/*/
Static Function B_M460MARK(cProduto,cLocal,nQtdlib)
Local lRet		:= .T.

If alltrim(cLocal)=="01"
	if SB2->(dbSeek(xFilial("SB2") + cProduto + cLocal ))
		nSldDisp	:= SB2->(SaldoSb2())
		if !(nSldDisp >= nQtdlib )
			lret := .F.
		endif
	else
		lret := .F.
	endif
endif
	
Return (lret)

/*/

覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		C_M460MARK                                                   /@
@type			Static Function                                              /@
@date			                                                             /@
@description	Critica item do pedido em opera鈬o de remessa de armazenagem /@
				caso n縊 possua saldo, pois a TES n縊 movimenta estoque.     /@
				A mensagem nao ? repetida para o mesmo pedido. Retorno T/F   /@
@author			Luiz Fernando                                                /@
@use			Especifico Gama Italy                                        /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?

/*/
Static Function C_M460MARK(cPedido,lverifB)

Local cQuery := "" 
Local aReg 	 := {}
Local aAreaSC9	:= SC9->(GetArea())

cQuery := "SELECT C9_PEDIDO, C9_OK, R_E_C_N_O_ REGISTRO "
cQuery += "FROM " + RetSQLName("SC9") + " SC9 "
cQuery += "WHERE C9_PEDIDO = '"+cPedido+"' "
cQuery += "AND SC9.D_E_L_E_T_ = ' ' "
cQuery += "AND C9_FILIAL = '"+xFilial("SC9")+"' "
     
if Select("TRD") > 0
	TRD->(dbCloseArea())
endif

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),"TRD", .F., .T.)

TRD->(dbGoTop())
do while TRD->(!eof())
	aadd(aReg, {TRD->REGISTRO,lverifB})
	TRD->(dbSkip())
Enddo
if Select("TRD") > 0
	TRD->(dbCloseArea())
endif

RestArea(aAreaSC9)

return aReg