#include 'protheus.ch'
#include "rwmake.ch"
#include 'parmtype.ch'

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		F240BTN                                                      /@
@date			02/08/2020                                                   /@
@type			Ponto de entrada
@description	Acrescenta novo item ao menu do contas a pagar               /@
@author			Adalberto Moreno Batista (Op鈬o Um Tecnologia da Informa鈬o) /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function F240BTN()              
Local aRotina := ParamIxb

aAdd(aRotina, {"CONTAINR", 		{||FINATTACH()}, "", 	"ｮ Anexos"})
aAdd(aRotina, {"CONTAINR", 		{||FINAPROVPC()}, "",	"ｮ Aprov. PC"})

Return(aRotina)

/*
//montar tela para consulta de anexos
//documento de entrada
//pedido de compras
//solicita鈬o de compras

adaptar a fun鈬o genAttach do BRAXFUN
aAdd(aBotoes, {"CONTAINR", {|| U_GenAttach(cA110Num, "SC", (INCLUI .or. ALTERA), {cAno, cMes})}, "ｮ Anexos"})

Permitir somente uma visualiza鈬o do processo.
funcao FinAttach, por exemplo
*/

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		FINATTACH                                                    /@
@type			Static Function                                              /@
@date			28/12/2020                                                   /@
@description	Fun鈬o gen駻ica para adiciona arquivos aos processos de 
				solicita鈬o de compras (SC), cota鋏es (CO), contratos (CT),
				pedidos de compras (PC), notas fiscais (NF), t?tulos a pagar
				(CP) e Boletos (BO). Refer麩cia do diretorio \ANEXOS         /@
@author			Adalberto Moreno Batista (Op鈬o Um Tecnologia da Informa鈬o) /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function FINATTACH()
Local aExclui 		:= {}
Local cChave        := E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA
Local oDlg
Private cPathFile, nTamFiles
Private aCols 		:= {}
Private aHeader 	:= {}
Private n			:= 1

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Ordenando tabelas
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
SE2->(dbSetOrder(1))		//E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA
SF1->(dbSetOrder(1))		//F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO
SD1->(dbSetOrder(1))		//D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM
SC7->(dbSetOrder(1))		//C7_FILIAL, C7_NUM, C7_ITEM, C7_SEQUEN
SC1->(dbSetOrder(1))		//C1_FILIAL, C1_NUM, C1_ITEM, C1_ITEMGRD

SE2->(dbSeek(cChave))

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Carregando os anexos
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
GetAttachs()

Define MsDialog oDlg Title OemtoAnsi("Arquivos vinculados ao processo ") From 005, 005 To 350, 780 Pixel			//"Arquivos vinculados ao processo "
@ 010, 010 To 150, 380 MultiLine
//@ 155,010 Button OemtoAnsi("+ Adiciona") Size 037,012 When lEdit Pixel Of oDlg Action AddFile(cNumControle)		//"+ Adiciona"
//@ 155,060 Button OemtoAnsi("- Remove") Size 037,012 When lEdit Pixel Of oDlg Action EraseFile(cNumControle)		//"- Remove"
@ 155,010 /*110*/ Button OemtoAnsi("Abre") Size 037,012 PIXEL OF oDlg Action Open(@aExclui)									//"Abre"
@ 155,340 Button OemtoAnsi("Encerra") Size 037,012 Pixel Of oDlg Action Close(oDlg)									//"Encerra"
Activate MsDialog oDlg Centered

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Exclui os temporarios
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if !Empty(aExclui)
	MsDocExclui(aExclui, .F.)
endif 			

Return()


	/*/
	覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	@function		GetAttachs()                                                 /@
	@type			Static Function                                              /@
	@date			28/12/2020                                                   /@
	@description	Pesquisa os arquivos anexos ao pedido de compras no diretorio
					COTACOES                                                     /@
	@author			Adalberto Moreno Batista (Op鈬o Um Consultoria)              /@
	@use			Brasitech                                                    /@
	覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	/*/
	Static Function GetAttachs()
	Local aFiles		:= {}
	Local aPedCom		:= {}
	Local aContrato		:= {}
	Local aSolCom		:= {}
	Local cRootDir		:= GetMV("BR_ANEXOPC")
	Local nX, nO, cPathFile, cNumControle, cMes, cAno

	n 				:= 1
	aCols			:= {}
	aHeader			:= {{"Origem",	"AA4_CODCLI", "", 002,0, ".F.",, "C",},;
						{"Arquivo", "AA4_CODCLI", "", 095,0, ".F.",, "C",},;
						{"Caminho", "AA4_CODCLI", "", 050,0, ".F.",, "C",}}		//o campo escolhido serve somente para aproveitar o when do dicionario de dados
	nTamFiles 		:= 0

	// Pesquisando os pedidos
	if SD1->(dbSeek(xFilial("SD1") + SE2->(E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA)))
		SF1->(dbSeek(xFilial("SF1") + SD1->(D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA)))
		do while SD1->(!eof() .and. D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA == xFilial("SD1") + SE2->(E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA))

			//Pedidos de compras
			if !Empty(SD1->D1_PEDIDO) .and. SC7->(dbSeek(xFilial("SC7") + SD1->D1_PEDIDO)) .and. Empty(aScan(aPedCom, SD1->D1_PEDIDO))

				aAdd(aPedCom, {SD1->D1_PEDIDO, Left(dTOs(SC7->C7_EMISSAO),6)})

				//Solicita鋏es de compras
				if !Empty(SC7->C7_NUMSC) .and. SC1->(dbSeek(xFilial("SC1") + SC7->C7_NUMSC)) .and. Empty(aScan(aSolCom, SC7->C7_NUMSC))
					aAdd(aSolCom, {SC7->C7_NUMSC, Left(dTOs(SC1->C1_EMISSAO),6)})
				endif

				//Contrato
				if !Empty(SC7->C7_CONTRA) .and. Empty(aScan(aContrato, SC7->C7_CONTRA))
					aAdd(aContrato, SC7->C7_CONTRA)
				endif

			endif

			SD1->(dbSkip())
		enddo
	endif

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Notas Fiscais
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	cMes			:= StrZero(Month(SF1->F1_EMISSAO),2)
	cAno			:= StrZero(Year(SF1->F1_EMISSAO),4)
	cPathFile		:= cRootDir + "\" + cEmpAnt + cFilAnt + "\NF\" + cAno + "\mes_" + cMes + "\"
	cNumControle	:= SF1->(AllTrim(F1_DOC) + "_" + AllTrim(F1_SERIE) + "_" + AllTrim(F1_FORNECE) + "_" + AllTrim(F1_LOJA))
	aFiles			:= Directory(cPathFile + cFilAnt + "_" + AllTrim(cNumControle) + "_" + "*.*")
	if Len(aFiles) > 0
		for nX := 1 to Len(aFiles)
			aAdd(aCols, {"NF", aFiles[nX,1], cPathFile, .F.})
			nTamFiles += aFiles[nX,2]
		next
	endif
	
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Pedido de Compras
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	for nO := 1 to Len(aPedCom)
		cMes			:= Substr(aPedCom[nO,2], 5, 2)
		cAno			:= Left(aPedCom[nO,2], 4)
		cPathFile		:= cRootDir + "\" + cEmpAnt + cFilAnt + "\PC\" + cAno + "\mes_" + cMes + "\"
		aFiles			:= Directory(cPathFile + cFilAnt + "_" + AllTrim(aPedCom[nO,1]) + "_" + "*.*")
		if Len(aFiles) > 0
			for nX := 1 to Len(aFiles)
				aAdd(aCols, {"PC", aFiles[nX,1], cPathFile, .F.})
				nTamFiles += aFiles[nX,2]
			next
		endif
	next

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Contrato
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	for nO := 1 to Len(aContrato)
		cPathFile		:= cRootDir + "\" + cEmpAnt + cFilAnt + "\CT\"
		aFiles			:= Directory(cPathFile + cFilAnt + "\" + aContrato[nO] + "\*.*")
		if Len(aFiles) > 0
			for nX := 1 to Len(aFiles)
				aAdd(aCols, {"CT", aFiles[nX,1], cPathFile, .F.})
				nTamFiles += aFiles[nX,2]
			next
		endif
	next

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Solicita鈬o de Compras
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	for nO := 1 to Len(aSolCom)
		cMes			:= Substr(aSolCom[nO,2], 5, 2)
		cAno			:= Left(aSolCom[nO,2], 4)
		cPathFile		:= cRootDir + "\" + cEmpAnt + cFilAnt + "\SC\" + cAno + "\mes_" + cMes + "\"
		aFiles			:= Directory(cPathFile + cFilAnt + "_" + AllTrim(aSolCom[nO,1]) + "_" + "*.*")
		if Len(aFiles) > 0
			for nX := 1 to Len(aFiles)
				aAdd(aCols, {"SC", aFiles[nX,1], cPathFile, .F.})
				nTamFiles += aFiles[nX,2]
			next
		endif
	next

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Redefinindo aCols
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	if Len(aCols) == 0
		aCols	:= {{Space(2), Space(95), Space(50), .F.}}
	endif

	Return()


	/*/
	覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	@function		Open()                                                       /@
	@type			Static Function                                              /@
	@date			28/12/2020                                                   /@
	@description	Abre arquivos vinculados ao pedido de compras no diretorio
					ANEXOS_PC                                                    /@
	@author			Adalberto Moreno Batista (Op鈬o Um Consultoria)              /@
	@use			Brasitech                                                    /@
	覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	/*/
	Static Function Open(aExclui)
	Local cFile			:= AllTrim(aCols[n,2])
	Local cPathFile		:= Lower(AllTrim(aCols[n,3]) + cFile)
	Local cPathTerm		:= Lower(GetTempPath() + cFile)
	Local cAcao			:= "open"												//"print", "explore"
	Local cParLinha		:= ""
	Local cDir			:= ""
	Local lCopied

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Transfere o arquivo para o diretorio de trabalho do Windows
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	Processa({|| lCopied := __CopyFile(cPathFile, cPathTerm)}, "Transferindo objeto", "Aguarde...", .F.)		//"Transferindo objeto", "Aguarde..."

	if lCopied .or. File(cPathTerm)
		if ShellExecute(cAcao, cPathTerm, cParLinha, cDir, 1) <= 32
			Help(,, "ｮ ATENﾇﾃO",, "N縊 foi poss?vel efetuar a transfer麩cia do arquivo para a 疵ea de trabalho!" + " (" + cFile + ")", 1)						//"ｮ ATENﾇﾃO"#"N縊 foi poss?vel efetuar a transfer麩cia do arquivo '"#"' para a 疵ea de trabalho !"
		EndIf			
	endif

	if Empty(AScan(aExclui, cPathTerm))
		aAdd(aExclui, cPathTerm)
	endif

	Return(.T.)

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		FINAPROVPC                                                   /@
@type			Static Function                                              /@
@date			02/08/2021                                                   /@
@description	Fun鈬o para mostrar aprova鋏es do pedido de compras, caso 
				exista.                                                      /@
@author			Adalberto Moreno Batista (Op鈬o Um Tecnologia da Informa鈬o) /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function FINAPROVPC()
Local cChave        := E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA
Local aPedidos		:= {}
Local cEol			:= chr(13) + chr(10)
Local cTexto		:= ""
Local nLimite		:= 80
Local cTipoSC7, cStatus, cLogFile, nX

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Ordenando tabelas
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
SE2->(dbSetOrder(1))		//E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA
//SF1->(dbSetOrder(1))		//F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO
SD1->(dbSetOrder(1))		//D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM
SC7->(dbSetOrder(1))		//C7_FILIAL, C7_NUM, C7_ITEM, C7_SEQUEN
SC1->(dbSetOrder(1))		//C1_FILIAL, C1_NUM, C1_ITEM, C1_ITEMGRD

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Localizando os pedidos vinculados ao titulo
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if SE2->(dbSeek(cChave))
	if SD1->(dbSeek(xFilial("SD1") + SE2->(E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA)))
//		SF1->(dbSeek(xFilial("SF1") + SD1->(D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA)))
		do while SD1->(!eof() .and. D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA == xFilial("SD1") + SE2->(E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA))
			//Pedidos de compras
			if !Empty(SD1->D1_PEDIDO) .and. SC7->(dbSeek(xFilial("SC7") + SD1->D1_PEDIDO)) .and. Empty(aScan(aPedidos, SD1->D1_PEDIDO))
				aAdd(aPedidos, SD1->D1_PEDIDO)
			endif
			SD1->(dbSkip())
		enddo
	endif
endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Buscando as aprova鋏es dos pedidos
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if Len(aPedidos) > 0

	for nX := 1 to Len(aPedidos)

		if SC7->(dbSeek(xFilial("SC7") + aPedidos[nX]))

			cTexto	+= Replicate("_", nLimite) + cEol
			cTexto	+= "Aprova鋏es do Pedido de Compras " + aPedidos[nX] + cEol
			cTexto	+= "Comprador " + Alltrim(UsrFullName(SC7->C7_USER)) + cEol
			cTexto	+= Replicate("_", nLimite) + cEol
			
			cTipoSC7	:= iif((SC7->C7_TIPO == 1 .or. SC7->C7_TIPO == 3), "PC", "AE")
						
			SCR->(dbSeek(xFilial("SCR") + cTipoSC7 + SC7->C7_NUM))
			do while SCR->(!eof() .and. CR_FILIAL == xFilial("SCR") .and. Alltrim(CR_NUM) == Alltrim(SC7->C7_NUM) .and. CR_TIPO == cTipoSC7)
				if SCR->CR_STATUS == "03" 			//OK  - Liberado
					cStatus := "APROVADO"
				elseif SCR->CR_STATUS == "04" 		//BLQ - Bloqueado
					cStatus := "BLOQUEADO"
				elseif SCR->CR_STATUS == "05" 		//##  - Nivel Liberado
					cStatus := "NﾍVEL LIBERADO POR OUTRO APROVADOR"
				else				               	//??  - Aguar.Lib
					cStatus := "AGUARDANDO LIBERAﾇﾃO"
				endif

				cTexto	+= "   " + PadR(UsrFullName(SCR->CR_USER),25) + " em " + dTOc(SCR->CR_DATALIB) + " - " + cStatus + cEol
	
				SCR->(dbSkip())
			enddo
			cTexto	+= Replicate(" ", nLimite) + cEol
			cTexto	+= Replicate("_", nLimite) + cEol
		endif

	next

endif

if Empty(cTexto)
	cTexto += "N縊 foram encontrados pedidos de despesas ou de compras para este processo financeiro"
endif

cLogFile := MemoWrite(CriaTrab(, .F.) + ".log", cTexto)

Define Font oFont Name "Mono AS" Size 6.5, 15.5
Define MsDialog oDlg Title "Consulta de aprovadores" From 0, 0 to 350, 500 Pixel

@ 5, 3 Get oMemo Var cTexto Memo Size 250, 147 Of oDlg Pixel
oMemo:bRClicked := { || AllwaysTrue() }
oMemo:oFont     := oFont

Define SButton From 160, 200 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga

Activate MsDialog oDlg Center

Return()
