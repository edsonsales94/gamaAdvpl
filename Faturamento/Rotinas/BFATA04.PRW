#include "rwmake.ch" 
#include "protheus.ch" 

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		BFATA04                                                       /@
@date				27/09/2013                                                    /@
@description	User function para cadastramento de contratos VPC             /@
@author			Adalberto Moreno Batista - Op鈬o Um Consultoria               /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function BFATA04()
Local aAreaSX3		:= SX3->(GetArea())
Local lContinua
Private aRotina   := { 	{"Pesquisar",	"AxPesqui", 			0, 1},;
			               {"Visualizar",	"U_MANUTFT04('V')", 	0, 2},;
			               {"Incluir",		"U_MANUTFT04('I')", 	0, 3},;
			               {"Alterar",		"U_MANUTFT04('A')", 	0, 4},;
			               {"Excluir",		"U_MANUTFT04('E')", 	0, 5},;
			               {"Log",			"U_LOGFT04()", 		0, 2} }
Private lInclui, lAltera, lExclui

SX3->(dbSetOrder(2))
lContinua := SX3->(dbSeek("ZJ_CONTRAT"))
RestArea(aAreaSX3)

if lContinua
	dbSelectArea("SZJ")
	mBrowse(,,,,"SZJ")

else
	Help(" ", 1, "ATENﾇﾃO", , "Esta empresa n縊 possui configura鈬o para uso de controle VPC." + chr(13) + chr(10) + chr(13) + chr(10) + "(Espec?fico Brasitech). ", 1)

endif

Return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		MANUTFT04                                                     /@
@date				27/09/2013                                                    /@
@description	User function para cadastramento de contratos VPC             /@
@author			Adalberto Moreno Batista - Op鈬o Um Consultoria               /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function MANUTFT04(cOpcao)
Local nOpcE		:= 2
Local nOpcG		:= 2
Local nUsado	:= 0
Local nSaldo 	:= 0
Local cEol		:= chr(13) + chr(10)
Local lNewCtr	:= .F.
Local nI, nK, nItem, nPosItem, cLog, nPosTpVPC, nPosPerc, nPosNCC, nPosPag, nPosPed
Private aHeader	:={}
Private aCols	:={}

lInclui	:= (cOpcao == "I")
lAltera	:= (cOpcao == "A")
lExclui	:= (cOpcao == "E")

if lInclui .or. lAltera
	nOpcE	:= 3
	nOpcG	:= 3
endif

SZI->(dbSetOrder(1))
SZJ->(dbSetOrder(1))
SZP->(dbSetOrder(2))	//ZP_FILIAL+ZP_CONTRAT+ZP_ITEM

//montagem das vari疱eis de mem?ria do cabe軋lho
RegToMemory("SZJ", lInclui)

//montagem do aHeader dos ?tens
SX3->(dbSetOrder(1))
SX3->(dbSeek("SZP"))
do while SX3->(!eof() .and. X3_ARQUIVO == "SZP")
	if !AllTrim(SX3->X3_CAMPO) $ "ZP_FILIAL.ZP_CONTRAT" .and. X3Uso(SX3->X3_USADO) .and. SX3->X3_NIVEL < cNivel
		nUsado++
		SX3->(aAdd(aHeader, {	Trim(X3_TITULO), X3_CAMPO, X3_PICTURE,	X3_TAMANHO, X3_DECIMAL, "AllwaysTrue()",;
										X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT} ))
	endif

	SX3->(dbSkip())
enddo

nPosItem		:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "ZP_ITEM"})
nPosTpVPC	:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "ZP_TPVPC"})
nPosPerc		:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "ZP_PERC"})
nPosNCC		:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "ZP_USANCC"})
nPosPag		:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "ZP_USAPAG"})
nPosPed		:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "ZP_USAPED"})
cLog			:= SZJ->ZJ_LOG

if SZP->(dbSeek(xFilial("SZP") + M->ZJ_CONTRAT))

	do while SZP->(!eof() .and. ZP_FILIAL + ZP_CONTRAT == xFilial("SZP") + M->ZJ_CONTRAT)
		cItem := SZP->ZP_ITEM
		aAdd(aCols, Array(nUsado + 1))
		for nI := 1 to nUsado
			if AllTrim(aHeader[nI,2]) == "ZP_DESCTP"
				aCols[Len(aCols),nI]	:= GetAdvFVal("SZI", "ZI_DESCR", xFilial("SZI") + SZP->ZP_TPVPC, 1)
			else
				aCols[Len(aCols),nI]	:= SZP->(FieldGet(FieldPos(aHeader[nI,2])))
			endif
		next
		aCols[Len(aCols), nUsado + 1]	:= .F.
		SZP->(dbSkip())
	enddo

else

	cItem 	:= "00"
	aCols		:= {Array(nUsado+1)}
	aCols[1, nUsado + 1]	:= .F.	
	for nI := 1 to nUsado
		aCols[1, nI]	:= CriaVar(aHeader[nI, 2])
	next
	
endif

if Len(aCols) > 0

	//Modelo3(	cTitulo, cAlias, cAlias2, [ aMyEncho ], [ cLinhaOk ], [ cTudoOk ], [ nOpcE ], [ nOpcG ], [ cFieldOk ],;
	//			[ lVirtual ], [ nLinhas ], [ aAltEnchoice ], [ nFreeze ] [ aButtons ] [ aCordW ] [ nSizeHeader ] ) --> lRet
	if Modelo3("Contratos VPC", "SZJ", "SZP",, "U_FTA04LiOK()", "U_FTA04TudOK()", nOpcE, nOpcG, "AllwaysTrue()",,,,,,,250)
  
		dbSelectArea("SZJ")
		dbSetOrder(1)	//ZJ_FILIAL+ZJ_CONTRAT+ZJ_CLIENTE+ZJ_LOJA
		
		//覧覧覧覧覧覧覧覧覧覧覧?
		// Inclus縊 de contratos
		//覧覧覧覧覧覧覧覧覧覧覧?
		if lInclui 
		
			cLog += "Contrato inclu?do em " + dTOc(Date()) + " 灣 " + Time() + ", por " + AllTrim(cUserName) + cEol
			cLog += "Considera IPI na base? " + iif(M->ZJ_IPI=="S", "SIM", "NﾃO") + cEol
			
			do while dbSeek(xFilial("SZJ") + M->ZJ_CONTRAT)
				ConfirmSX8()
				M->ZJ_CONTRAT := GetSXENum("SZJ")
				lNewCtr	:= .T.
			enddo

			if !dbSeek(xFilial("SZJ") + M->ZJ_CONTRAT)
				
				if SZJ->(RecLock("SZJ", .T.))
				
					M->ZJ_LOJA := iif(SA1->A1_X_MDVPC=="C", " ", M->ZJ_LOJA)
					
					for nI := 1 to FCount()
						cCampo	:= FieldName(nI)
						xVar	:= M->&cCampo
						FieldPut(FieldPos(cCampo), xVar)
					next
               
					for nI := 1 To Len(aCols)

					    if !aCols[nI, Len(aHeader) + 1]
							
								cItem := Soma1(cItem)
								SZP->(RecLock("SZP",.T.))
								SZP->ZP_FILIAL	:= xFilial("SZP")
								SZP->ZP_CONTRAT	:= SZJ->ZJ_CONTRAT
								SZP->ZP_ITEM	:= cItem

								for nK := 1 to Len(aHeader)
									if !AllTrim(aHeader[nK,2]) $ "ZP_FILIAL.ZP_CONTRAT.ZP_ITEM" .and. SZP->(FieldPos(aHeader[nK,2])) > 0
										SZP->(FieldPut(FieldPos(aHeader[nK,2]), aCols[nI,nK]))
									endif
								next

								SZP->(MsUnLock())
        
								cLog += 	"Item: " + SZP->ZP_ITEM + cEol +;
											"         Tipo VPC: " + SZP->ZP_TPVPC + " - " +;
											GetAdvFVal("SZI", "ZI_DESCR", xFilial("SZI") + SZP->ZP_TPVPC, 1) + ", " +;
											Transform(SZP->ZP_PERC, "@E 99.99%") +;
											", Gera NCC: " + SZP->ZP_USANCC +;
											", Gera Cta.Pag: " + SZP->ZP_USAPAG +;
											", Gera Pedido: " + SZP->ZP_USAPED + cEol
								        
						endif
    
					next

					cLog += Repl("-", 111) + cEol
					SZJ->ZJ_LOG		:= cLog
					SZJ->(MsUnlock())
					
					if lNewCtr
						MsgBox("O contrato foi gravado com o n?mero '" + M->ZJ_CONTRAT + "', pois o visualizado na tela de inclus縊 j? existia na base de dados.", "Informa鈬o", "INFO" )
					endif
					
				else
				
					Help(" ", 1, "ATENﾇﾃO",, "O registro n縊 poder? ser gravado. Tente novamente." + cEol + cEol + "(Espec?fico Brasitech). ", 1)
					
				endif
			
			else
			
				Help(" ", 1, "ATENﾇﾃO",, "Este n?mero de contrato j? existe na base de dados. Escolha um outro n?mero." + cEol + cEol + "(Espec?fico Brasitech). ", 1)
				
			endif
				

		//覧覧覧覧覧覧覧覧覧覧覧覧
		// Altera鈬o de contratos
		//覧覧覧覧覧覧覧覧覧覧覧覧
		elseif lAltera

			if SZJ->(RecLock("SZJ", .F.))
				cLog += "Contrato alterado em " + dTOc(Date()) + " 灣 " + Time() + ", por " + AllTrim(cUserName) + cEol
				cLog += iif(M->ZJ_IPI != SZJ->ZJ_IPI, "Considera IPI na base? de: " + iif(SZJ->ZJ_IPI=="S", "SIM", "NﾃO") + " para: " + iif(M->ZJ_IPI=="S", "SIM", "NﾃO") + cEol, "")

				for nI := 1 to FCount()
					cCampo	:= FieldName(nI)
					xVar	:= M->&cCampo
					FieldPut(FieldPos(cCampo), xVar)
				next

				for nI := 1 To Len(aCols)

					if !aCols[nI, Len(aHeader) + 1] .and. Empty(aCols[nI, nPosItem])	//Altera鈬o de contratos - inclus縊 de item

						cItem := Soma1(cItem)
						SZP->(RecLock("SZP",.T.))
						SZP->ZP_FILIAL	:= xFilial("SZP")
						SZP->ZP_CONTRAT	:= SZJ->ZJ_CONTRAT
						SZP->ZP_ITEM	:= cItem
						for nK := 1 to Len(aHeader)
							if !AllTrim(aHeader[nK,2]) $ "ZP_FILIAL.ZP_CONTRAT.ZP_ITEM" .and. SZP->(FieldPos(AllTrim(aHeader[nK,2]))) > 0
								SZP->(FieldPut(FieldPos(AllTrim(aHeader[nK,2])), aCols[nI,nK]))
							endif
						next
						SZP->(MsUnLock())
						cLog += 	"Inclus縊  do item: " + SZP->ZP_ITEM + cEol +;
						     		"         Tipo VPC: " + SZP->ZP_TPVPC + " - " +;
						     		GetAdvFVal("SZI", "ZI_DESCR", xFilial("SZI") + SZP->ZP_TPVPC, 1) + ", " +;
						     		Transform(SZP->ZP_PERC, "@E 99.99%") +;
						     		", Gera NCC: " + SZP->ZP_USANCC +;
						     		", Gera Cta.Pag: " + SZP->ZP_USAPAG +;
						     		", Gera Pedido: " + SZP->ZP_USAPED + cEol
				        
					elseif !aCols[nI, Len(aHeader) + 1] .and. !Empty(aCols[nI, nPosItem])	//Altera鈬o de contratos - altera鈬o de item

						if SZP->(dbSeek(xFilial("SZP") + SZJ->ZJ_CONTRAT + aCols[nI, nPosItem]))
						
							if aCols[nI, nPosTpVPC] != SZP->ZP_TPVPC .or.;
								aCols[nI, nPosPerc] != SZP->ZP_PERC .or.;
								aCols[nI, nPosNCC] != SZP->ZP_USANCC .or.;
								aCols[nI, nPosPag] != SZP->ZP_USAPAG .or.;
								aCols[nI, nPosPed] != SZP->ZP_USAPED
								
								cLog += 	"Altera鈬o do item: " + SZP->ZP_ITEM + cEol +;
							        		"  De->   Tipo VPC: " + SZP->ZP_TPVPC + " - " + GetAdvFVal("SZI", "ZI_DESCR", xFilial("SZI") + SZP->ZP_TPVPC, 1) + ", " +;
							        		Transform(SZP->ZP_PERC, "@E 99.99%") +;
							        		", Gera NCC: " + SZP->ZP_USANCC +;
							        		", Gera Cta.Pag: " + SZP->ZP_USAPAG +;
							        		", Gera Pedido: " + SZP->ZP_USAPED + cEol +;
							        		"  Para-> Tipo VPC: " + aCols[nI, nPosTPVPC] + " - " + GetAdvFVal("SZI", "ZI_DESCR", xFilial("SZI") + aCols[nI, nPosTPVPC], 1) + ", " +;
							        		Transform(aCols[nI, nPosPerc], "@E 99.99%") +;
							        		", Gera NCC: " + aCols[nI, nPosNCC] +;
							        		", Gera Cta.Pag: " + aCols[nI, nPosPag] +;
							        		", Gera Pedido: " + aCols[nI, nPosPed] + cEol
							endif

							SZP->(RecLock("SZP",.F.))
							for nK := 1 to Len(aHeader)
								if !AllTrim(aHeader[nK,2]) $ "ZP_FILIAL.ZP_CONTRAT.ZP_ITEM" .and. SZP->(FieldPos(AllTrim(aHeader[nK,2]))) > 0
									SZP->(FieldPut(FieldPos(AllTrim(aHeader[nK,2])), aCols[nI,nK]))
								endif
							next
					      SZP->(MsUnLock())
					        
					 	endif

					elseif aCols[nI, Len(aHeader) + 1] .and. !Empty(aCols[nI, nPosItem])	//Altera鈬o de contratos - exclus縊 de item

						if SZP->(dbSeek(xFilial("SZP") + SZJ->ZJ_CONTRAT + aCols[nI, nPosItem]))
					        cLog += "Exclus縊 do item:  " + SZP->ZP_ITEM + cEol +;
					        		"         Tipo VPC: " + SZP->ZP_TPVPC + " - " +;
					        		GetAdvFVal("SZI", "ZI_DESCR", xFilial("SZI") + SZP->ZP_TPVPC, 1) + ", " +;
					        		Transform(SZP->ZP_PERC, "@E 99.99%") +;
					        		", Gera NCC: " + SZP->ZP_USANCC +;
					        		", Gera Cta.Pag: " + SZP->ZP_USAPAG +;
					        		", Gera Pedido: " + SZP->ZP_USAPED + cEol

					        SZP->(RecLock("SZP",.F.))
							SZP->(dbDelete())
					        SZP->(MsUnLock())
					 	endif

					endif
					    
				next

				cLog += Repl("-", 111) + cEol
				SZJ->ZJ_LOG		:= cLog
				SZJ->(MsUnlock())
				
			else
				
				Help(" ", 1, "ATENﾇﾃO",, "O registro n縊 poder? ser gravado. Tente novamente." + cEol + cEol + "(Espec?fico Brasitech). ", 1)
				
			endif
		
		//覧覧覧覧覧覧覧覧覧覧覧覧
		// Exclus縊 de contratos
		//覧覧覧覧覧覧覧覧覧覧覧覧
		elseif lExclui
		    
			//Busca saldo de 1-NCC
			U_VPCCalcSld(SZJ->ZJ_CLIENTE, SZJ->ZJ_LOJA, "1", @nSaldo)

			//Busca saldo de 2-Cta Pagar
			U_VPCCalcSld(SZJ->ZJ_CLIENTE, SZJ->ZJ_LOJA, "2", @nSaldo)
				
			//Busca saldo de 3-Ped. Bonif
			U_VPCCalcSld(SZJ->ZJ_CLIENTE, SZJ->ZJ_LOJA, "3", @nSaldo)
			
			if nSaldo == 0
			
				if SZJ->(RecLock("SZJ", .F.))
					cLog += "Contrato exclu?do em " + dTOc(Date()) + " 灣 " + Time() + ", por " + AllTrim(cUserName) + cEol
					SZJ->ZJ_LOG		:= cLog
					SZJ->(dbDelete())
					SZJ->(MsUnlock())
	
					SZP->(dbSeek(xFilial("SZP") + SZJ->ZJ_CONTRAT))
					do while SZP->(!eof() .and. ZP_FILIAL + ZP_CONTRAT == xFilial("SZP") + SZJ->ZJ_CONTRAT)
						SZP->(RecLock("SZP", .F.))
						SZP->(dbDelete())
						SZP->(MsUnlock())
						SZP->(dbSkip())
					enddo
				endif
	
			else

				Help(" ", 1, "Aten鈬o",, "Este contrato n縊 poder? ser exclu?do pois h? saldo VPC para o cliente. Zere o saldo com movimentos manuais e volte a excluir o contrato." + cEol + cEol + cEol + "(Espec?fico Gama Italy)," + cEol + cEol + "BFATA04", 1)

			endif
		endif
	
	else
	
		RollBackSX8()
	
	endif
	
endif

return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		FTA04LiOK                                                     /@
@date		 		07/10/2013                                                    /@
@description	User function para valida鈬o da linha dos itens do contrato   /@
@author			Adalberto Moreno Batista - Op鈬o Um Consultoria               /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function FTA04LiOk()
Local lRet		:= .T.
Local nPosTPVPC := aScan(aHeader,{|x| Upper(alltrim(x[2])) == "ZP_TPVPC"})
Local nPosPERC	:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "ZP_PERC"})
Local nPosNCC	:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "ZP_USANCC"})
Local nPosPAG	:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "ZP_USAPAG"})
Local nPosPED	:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "ZP_USAPED"})
Local cEol		:= chr(13) + chr(10) + chr(13) + chr(10)
Local nK

if !aCols[n, Len(aHeader) + 1]

	//n縊 permitir c?digo tipo VPC vazio
	if lRet
		if Empty(aCols[n, nPosTPVPC])
			lRet := .F.
			Help(" ", 1, "ATENﾇﾃO",, "C?digo do tipo VPC ? obrigat?rio." + cEol + "(Espec?fico Brasitech). ", 1)
		endif
	endif
	
	//n縊 permitir percentual VPC menor que zero
	if lRet
		if aCols[n, nPosPERC] < 0
			lRet := .F.
			Help(" ", 1, "ATENﾇﾃO",, "Percentual obrigatoriamente dever? ser maior ou igual ? zero." + cEol + "(Espec?fico Brasitech). ", 1)
		endif
	endif
	
	//n縊 permitir c?digo tipo VPC repetido
	if lRet
		for nK := 1 to Len(aCols)
			if !aCols[nK, Len(aHeader) + 1] .and. n != nK .and. aCols[n, nPosTPVPC] == aCols[nK, nPosTPVPC]
				lRet := .F.
				Help(" ", 1, "ATENﾇﾃO",, "C?digo do tipo VPC j? informado." + cEol + "(Espec?fico Brasitech). ", 1)
			endif
		next
	endif
	
	//verificacao do uso VPC
	if lRet
		if aCols[n, nPosNCC] == "N" .and. aCols[n, nPosPAG] == "N" .and. aCols[n, nPosPED] == "N"
			lRet := .F.
			Help(" ", 1, "ATENﾇﾃO",, "Responder 'SIM' para o uso da VPC em ao menos um dos itens 'Gera NCC' ou 'Gera Cta.Pag' ou 'Gera Pedido'." + cEol + "(Espec?fico Brasitech). ", 1)
		endif
	endif
	
endif

Return(lRet)


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		FTA04TudOK                                                    /@
@date				07/10/2013                                                    /@
@description	User function para valida鈬o da cadastramento do contrato     /@
@author			Adalberto Moreno Batista - Op鈬o Um Consultoria               /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function FTA04TudOk()
Local lRet		:= .F.
Local aArea		:= GetArea()
Local cEol		:= chr(13) + chr(10) + chr(13) + chr(10)
Local nK, cQuery, cModo

//n縊 permitir c?digo tipo VPC repetido
for nK := 1 to Len(aCols)
	if !aCols[nk, Len(aHeader) + 1]
		lRet := .T.
		exit
	endif
next

if !lRet

	Help(" ", 1, "ATENﾇﾃO",, "ﾉ necess疵io incluir ao menos uma linha de percentual VPC." + cEol + "(Espec?fico Brasitech). ", 1)

endif

if lRet .and. lInclui 
	lRet := U_FTA04VlCli(M->ZJ_CLIENTE, M->ZJ_LOJA)
endif

if lRet .and. lInclui
	SZJ->(dbSetOrder(2))	//ZJ_FILIAL+ZJ_CLIENTE+ZJ_LOJA+ZJ_CONTRAT
	if SZJ->(dbSeek(xFilial("SZJ") + M->ZJ_CLIENTE + M->ZJ_LOJA))
		lRet := .F.
		Help(" ", 1, "ATENﾇﾃO",, "J? existe um contrato para este cliente e loja. Contrato (" + SZJ->ZJ_CONTRAT + ")." + cEol + "(Espec?fico Brasitech). ", 1)
	endif
endif
/*else

	cQuery := "SELECT ZJ_CONTRAT "
	cQuery += "FROM " + RetSQLName("SZJ") + " SZJ "
	cQuery += "WHERE ZJ_FILIAL = '" + xFilial("SZJ") + "' "
	cQuery +=       "AND D_E_L_E_T_ = ' ' "
	cQuery +=       "AND ZJ_CLIENTE = '" + M->ZJ_CLIENTE + "' "
	if !empty(M->ZJ_LOJA)
		cQuery +=   "AND ZJ_LOJA = '" + M->ZJ_LOJA + "' "
	endif
	cQuery +=       "AND ZJ_CONTRAT != '" + M->ZJ_CONTRAT + "' "
//	cQuery +=       "AND (ZJ_DTVIGIN BETWEEN '" + dTOs(M->ZJ_DTVIGIN) + "' AND " + dTOs(M->ZJ_DTVIGFI) + " "
//	cQuery +=            "OR ZJ_DTVIGFI BETWEEN '" + dTOs(M->ZJ_DTVIGIN) + "' AND " + dTOs(M->ZJ_DTVIGFI) + ")"
	
	if Select("TRB") > 0
		TRB->(dbCloseArea())
	endif
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TRB", .F., .T.)
	
	TRB->(dbGoTop())
	if TRB->(!eof())
		lRet	:= .F.
		Help(" ", 1, "ATENﾇﾃO",, "A data de in?cio ou t駻mino de vig麩cia informados est? dentro do intervalo de vig麩cia do contrato " + TRB->ZJ_CONTRAT + "." + cEol + "(Espec?fico Brasitech). ", 1)
	endif

	if lRet
		lRet := FTA04VlCli(M->ZJ_CLIENTE, M->ZJ_LOJA)
	endif

	RestArea(aArea)
endif
*/
Return(lRet)


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		FTA04VlCli                                                    /@
@date				02/09/2013                                                    /@
@description	User function para valida鈬o do codigo de cliente e retorno  
					da raz縊 social                                               /@
@author			Adalberto Moreno Batista - Op鈬o Um Consultoria               /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function FTA04VlCli(cCliente, cLoja)
Local lRet	:= .F.
Local cEol	:= Chr(13) + Chr(10) + Chr(13) + Chr(10)
Local cMens := "C?digo de cliente n縊 encontrado ou bloqueado para uso."
Local nCont	:= 0

SA1->(dbSetOrder(1))
if cLoja == NIL .or. Empty(cLoja)

	SA1->(dbSeek(xFilial("SA1") + cCliente))
	do while SA1->(!eof() .and. A1_FILIAL + A1_COD == xFilial("SA1") + cCliente)
		if SA1->A1_MSBLQL != '1'
			M->ZJ_NCLIENT := SA1->A1_NOME
			M->ZK_NCLIENT := SA1->A1_NOME
			lRet := .T.
			exit
		endif
		SA1->(dbSkip())
	enddo

elseif !empty(cLoja)

	if SA1->(dbSeek(xFilial("SA1") + cCliente + cLoja))
		if SA1->A1_MSBLQL != '1' .and. SA1->A1_X_MDVPC == "L"
			M->ZJ_NCLIENT := SA1->A1_NOME
			M->ZK_NCLIENT := SA1->A1_NOME
			lRet := .T.
		endif
	endif

endif

if !lRet
    
	Help(" ", 1, "ATENﾇﾃO",, cMens + cEol + "(Espec?fico Brasitech). ", 1)

endif

Return(lRet)


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		LOGFT04                                                       /@
@type				User Function                                                 /@
@date				23/12/2013                                                    /@
@description	Apresenta tela com o log de altera鋏es                        /@
@author			Adalberto Moreno Batista - Op鈬o Um Consultoria               /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function LOGFT04()
Local cTexto := SZJ->ZJ_LOG
Local oDlg, oFont, oMemo

Define Font oFont Name "Courrier New" Size 7, 14
Define MsDialog oDlg Title OemToAnsi("Log de inclus縊 e altera鈬o de informa鋏es no Contrato VPC") From 3, 0 to 460, 840 Pixel		//460,630
	
@ 5, 5 Get oMemo Var cTexto Memo Size 410, 200 Of oDlg Pixel	//310,200
				
oMemo:bRClicked := { || AllwaysTrue() }
oMemo:oFont     := oFont
				
Define SButton From 210, 370 Type 1 Action oDlg:End() Enable Of oDlg Pixel	//210,200
	
Activate MsDialog oDlg Center

Return()