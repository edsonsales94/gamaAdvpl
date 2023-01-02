
#include "protheus.ch" 

/*/

———————————————————————————————————————————————————————————————————————————————
@function		BFATA09                                                      /@
@date			28/11/2014                                                   /@
@description	User function para cadastramento de Metas de Vendas          /@
@author			Felipe Varella - GamaItaly                                   /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————

/*/
User Function BFATA09()
Local aAreaSX3		:= SX3->(GetArea())
Local lContinua
Private aRotina   := { { "Pesquisar",	"AxPesqui"      , 0, 1},;
		               { "Visualizar",	"U_MANFT09('V')", 0, 2},;
		               { "Incluir",		"U_MANFT09('I')", 0, 3},;
		               { "Alterar",		"U_MANFT09('A')", 0, 4},;
		               { "Excluir",		"U_MANFT09('E')", 0, 5},;
		               { "Log",			"U_LOGFT09()"   , 0, 2} }
Private lInclui, lAltera, lExclui
  
SX3->(dbSetOrder(2))
lContinua := SX3->(dbSeek("ZC_CODREP"))
RestArea(aAreaSX3)

if lContinua
	dbSelectArea("SZC")
	mBrowse(,,,,"SZC")

else
	Help(" ", 1, "ATENÇÃO", , "Esta empresa não possui configuração para uso de Metas." + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Brasitech). ", 1)

endif

Return()


/*/

———————————————————————————————————————————————————————————————————————————————
@function		MANFT09                                                      /@
@date			28/11/2014                                                   /@
@description	User function para Cadastramento de Metas                    /@
@author			Felipe Varella - GamaItaly						             /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————

/*/
User Function MANFT09(cOpcao) 
Local nOpcE		:= 2
Local nOpcG		:= 2
Local nUsado	:= 0
Local nSaldo 	:= 0
Local cEol		:= chr(13) + chr(10)
Local nI, nK, nItem, nPosNegoc, cLog, nPosMix, nPosmes, nPosAno, nPosVal

Private aHeader	:={}
Private aCols	:={}

lInclui	:= (cOpcao == "I")
lAltera	:= (cOpcao == "A")
lExclui	:= (cOpcao == "E")

if lInclui .or. lAltera
	nOpcE	:= 3
	nOpcG	:= 3
endif

SZC->(dbSetOrder(1))
SZY->(dbSetOrder(1))

//montagem das variáveis de memória do cabeçalho
RegToMemory("SZC", lInclui)

//montagem do aHeader dos ítens
SX3->(dbSetOrder(1))
SX3->(dbSeek("SZY"))
do while SX3->(!eof() .and. X3_ARQUIVO == "SZY")
	if !AllTrim(SX3->X3_CAMPO) $ "ZY_FILIAL.ZY_CODREP.ZY_USERLGI.ZY_USERLGA" .and. X3Uso(SX3->X3_USADO) .and. SX3->X3_NIVEL < cNivel
		nUsado++
		SX3->(aAdd(aHeader, {	Trim(X3_TITULO), X3_CAMPO, X3_PICTURE,	X3_TAMANHO, X3_DECIMAL, "AllwaysTrue()",;
								X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT} ))
	endif

	SX3->(dbSkip())
enddo



nPosNegoc	:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "ZY_XNEGOCI"})
nPosMix		:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "ZY_MIX"})
nPosmes		:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "ZY_MES"})
nPosAno		:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "ZY_ANO"})
nPosVal		:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "ZY_VALOR"})


dbSelectArea("SZY")
dbSetOrder(2)


if SZY->(dbSeek(xFilial("SZY") + M->ZC_CODREP))

	do while SZY->(!eof() .and. ZY_FILIAL == xFilial("SZY") .and. ZY_CODREP == M->ZC_CODREP)
		aAdd(aCols, Array(nUsado + 1))
		for nI := 1 to nUsado
			aCols[Len(aCols),nI]	:= SZY->(FieldGet(FieldPos(aHeader[nI,2])))
		next
		aCols[Len(aCols), nUsado + 1]	:= .F.
		SZY->(dbSkip())
	enddo
 
else

	aCols	:= {Array(nUsado+1)}
	aCols[1, nUsado + 1]	:= .F.	
	for nI := 1 to nUsado
		aCols[1, nI]	:= CriaVar(aHeader[nI, 2])
	next
	
endif

if Len(aCols) > 0
	//"U_FTA09LiOK()", "U_FTA04TudOK()"
	//Modelo3(	cTitulo, cAlias, cAlias2, [ aMyEncho ], [ cLinhaOk ], [ cTudoOk ], [ nOpcE ], [ nOpcG ], [ cFieldOk ],;
	//			[ lVirtual ], [ nLinhas ], [ aAltEnchoice ], [ nFreeze ] [ aButtons ] [ aCordW ] [ nSizeHeader ] ) --> lRet
	if Modelo3("Metas de Vendas", "SZC", "SZY",, "U_FTA09LiOk()", "U_FTA09LiOk()", nOpcE, nOpcG, "AllwaysTrue()",,,,,,,250)
  
		dbSelectArea("SZC")
		dbSetOrder(1)	//ZJ_FILIAL+ZJ_CONTRAT+ZJ_CLIENTE+ZJ_LOJA
		
		//———————————————————————
		// Inclusão de metas
		//———————————————————————
		if lInclui 
						
			if !dbSeek(xFilial("SZC") + M->ZC_CODREP)
				
				if SZC->(RecLock("SZC", .T.))
				
					for nI := 1 to FCount()
						cCampo	:= FieldName(nI)
						xVar	:= M->&cCampo
						FieldPut(FieldPos(cCampo), xVar)
					next
               
					for nI := 1 To Len(aCols)

					    if !aCols[nI, Len(aHeader) + 1]
							
							SZY->(RecLock("SZY",.T.))
					        SZY->ZY_FILIAL	:= xFilial("SZY")
					        SZY->ZY_CODREP	:= SZC->ZC_CODREP
							
							for nK := 1 to Len(aHeader)
								if !AllTrim(aHeader[nK,2]) $ "ZY_FILIAL.ZY_CODREP.ZY_USERLGI.ZY_USERLGA" .and. SZY->(FieldPos(aHeader[nK,2])) > 0
									SZY->(FieldPut(FieldPos(aHeader[nK,2]), aCols[nI,nK]))
								endif
							next
							
					        SZY->(MsUnLock())
					        
					    endif
					    
					next
					SZC->(MsUnLock())
				else
				
					Help(" ", 1, "ATENÇÃO",, "O registro não poderá ser gravado. Tente novamente." + cEol + cEol + "(Específico Brasitech). ", 1)
					
				endif
			
			else
			
				Help(" ", 1, "ATENÇÃO",, "Este Representante já possui metas na base de dados." + cEol + cEol + "(Específico Brasitech). ", 1)
				
			endif
				

		//————————————————————————
		// Alteração de metas
		//————————————————————————
  		elseif lAltera

			if SZC->(RecLock("SZC", .F.))
				
				for nI := 1 to FCount()
					cCampo	:= FieldName(nI)
					xVar	:= M->&cCampo
					FieldPut(FieldPos(cCampo), xVar)
				next

				for nI := 1 To Len(aCols)
					dbselectArea("SZY")
					dbSetOrder(1)					
				  	// Alteração - Alteração de item existente
					if !aCols[nI, Len(aHeader) + 1] .and. dbSeek(xFilial("SZY") + M->ZC_CODREP + aCols[nI, nPosNegoc] + aCols[nI, nPosMix] + aCols[nI, nPosMes] + aCols[nI, nPosAno])
						RecLock("SZY",.F.)
				      	SZY->ZY_FILIAL	:= xFilial("SZY")
				        SZY->ZY_CODREP	:= SZC->ZC_CODREP
						for nK := 1 to Len(aHeader)
							if !AllTrim(aHeader[nK,2]) $ "ZY_FILIAL.ZY_CODREP.ZY_USERLGI.ZY_USERLGA" .and. SZY->(FieldPos(AllTrim(aHeader[nK,2]))) > 0
								SZY->(FieldPut(FieldPos(AllTrim(aHeader[nK,2])), aCols[nI,nK]))
							endif
						next
				        SZY->(MsUnLock())
				  	// Alteração - Inclusão de Item novo
					elseif !aCols[nI, Len(aHeader) + 1] .and. !dbSeek(xFilial("SZY") + M->ZC_CODREP + aCols[nI, nPosNegoc] + aCols[nI, nPosMix] + aCols[nI, nPosMes] + aCols[nI, nPosAno])
						RecLock("SZY",.T.)
			      		SZY->ZY_FILIAL	:= xFilial("SZY")
			        	SZY->ZY_CODREP	:= SZC->ZC_CODREP
						for nK := 1 to Len(aHeader)
							if !AllTrim(aHeader[nK,2]) $ "ZY_FILIAL.ZY_CODREP.ZY_USERLGI.ZY_USERLGA" .and. SZY->(FieldPos(AllTrim(aHeader[nK,2]))) > 0
								SZY->(FieldPut(FieldPos(AllTrim(aHeader[nK,2])), aCols[nI,nK]))
							endif
						next
			        	SZY->(MsUnLock())
			   		// Alteração - Exclusão de Item
					elseif aCols[nI, Len(aHeader) + 1] .and. dbSeek(xFilial("SZY") + M->ZC_CODREP + aCols[nI, nPosNegoc] + aCols[nI, nPosMix] + aCols[nI, nPosMes] + aCols[nI, nPosAno])
						RecLock("SZY",.F.)
						SZY->(dbDelete())
				    	SZY->(MsUnLock())
				    endif    
				next
				SZC->(MsUnlock())
			else
				Help(" ", 1, "ATENÇÃO",, "O registro não poderá ser gravado. Tente novamente." + cEol + cEol + "(Específico Brasitech). ", 1)
			endif
		
		//————————————————————————
		// Exclusão de metas
		//————————————————————————
		elseif lExclui
		    
		
			if SZC->(RecLock("SZC", .F.))
				SZC->(dbDelete())
				SZC->(MsUnlock())
				SZY->(dbSeek(xFilial("SZY") + SZC->ZC_CODREP))
				do while SZY->(!eof() .and. ZY_FILIAL + ZY_CODREP == xFilial("SZY") + SZC->ZC_CODREP)
					SZY->(RecLock("SZY", .F.))
					SZY->(dbDelete())
					SZY->(MsUnlock())
					SZY->(dbSkip())
				enddo
			endif
	
		endif
	
	endif
	
endif

return()

/*/

———————————————————————————————————————————————————————————————————————————————
@function		FTA09LiOK                                                    /@
@date			28/11/2014                                                   /@
@description	User function para validação da linha dos itens das Metas    /@
@author			Felipe Varella - Gama Italy                                  /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————

/*/
User Function FTA09LiOk()

Local lRet		:= .T.
Local nPosNegoc	:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "ZY_XNEGOCI"})
Local nPosMix	:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "ZY_MIX"})
Local nPosmes	:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "ZY_MES"})
Local nPosAno	:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "ZY_ANO"})
Local nPosVal	:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "ZY_VALOR"})
Local cEol		:= chr(13) + chr(10) + chr(13) + chr(10)
Local nK


// Verifica se já existe meta cadastrada


if !aCols[n, Len(aHeader) + 1]

	for nK := 1 to Len(aCols)
		if nk != n
			if aCols[nk,nPosNegoc] = aCols[n,nPosNegoc] .and. aCols[nk,nPosMix] = aCols[n,nPosMix] .and. ;
			   aCols[nk,nPosmes] = aCols[n,nPosmes] .and. aCols[nk,nPosAno] = aCols[n,nPosAno]
				Help(" ", 1, "ATENÇÃO",, "Meta de Vendas já existe cadastrada." + cEol + "(Específico Brasitech). ", 1)
				lRet := .F.
				exit
			Endif
		endif
	next
Endif

Return(lRet)
