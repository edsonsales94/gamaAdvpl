#include 'protheus.ch'
#include "rwmake.ch"
#include 'parmtype.ch'

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		F050ROT                                                      /@
@date			11/12/2019                                                   /@
@type			Ponto de entrada
@description	Acrescenta novo item ao menu do contas a pagar               /@
@author			                                                             /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function F050ROT              
Local aRotina := ParamIxb

aAdd(aRotina, {"ｮ Recibo Gama", {||U_GmWord01()}, 0, 8,, .F.}) //alterado 11/12/19 (problemas fun鋏es contas a Pagar( Jorge))
aAdd(aRotina, {"ｮ Anexos", 		{||U_FINATTACH()}, 0, 8,, .F.})

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
@function		GenAttach                                                    /@
@type			User Function                                                /@
@date			28/12/2020                                                   /@
@description	Fun鈬o gen駻ica para adiciona arquivos aos processos de 
				solicita鈬o de compras (SC), cota鋏es (CO), contratos (CT),
				pedidos de compras (PC), notas fiscais (NF), t?tulos a pagar
				(CP) e Boletos (BO). Refer麩cia do diretorio \ANEXOS         /@
@author			Adalberto Moreno Batista (Op鈬o Um Tecnologia da Informa鈬o) /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
USER Function FINATTACH()
Local aExclui 		:= {}
Local oDlg
Local cDirAnexos	:= GetMV("BR_ANEXOPC")
Local cTipo			:= "PC" //Left(cParTipo, 2)
Local lEdit := .F.
Private cPathFile, nTamFiles
Private aCols 		:= {}
Private aHeader 	:= {}
Private n			:= 1

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Ordenando tabelas
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
SF1->(dbSetOrder(1))		//F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO
SD1->(dbSetOrder(1))		//D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM
SC7->(dbSetOrder(1))		//C7_FILIAL, C7_NUM, C7_ITEM, C7_SEQUEN
SC1->(dbSetOrder(1))		//C1_FILIAL, C1_NUM, C1_ITEM, C1_ITEMGRD


//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Criando as pastas de ANEXOS
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
MakeDir(cDirAnexos)	//"\ANEXOS")

if cTipo == "CT" .or. cTipo == "ME"
	aPermissao	:= CN300VldUsr()
	//lPermissao	:= aPermissao[1] .or. aPermissao[7][aScan(aPermissao[7],{|x| x[1] == '047'})][2]
    cContrato	:= aChave[1]
	aCols		:= {}
	aHeader		:= {}
	n			:= 1

	MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt + "\CT")
	MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt + "\CT\" + cContrato)
	MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt + "\CT\" + cContrato + "\MEDICAO")

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Definindo o caminho dos anexos
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	cPathFile	:= cDirAnexos + "\" + cEmpAnt + cFilAnt + "\CT\" + cContrato + "\"
	if cTipo == "ME"
		cPathFile	+= "MEDICAO\"
		cTipo		:= "CT"
	endif

elseif cTipo == "CP"
    cAno			:= aChave[1]
    cMes			:= aChave[2]
//	aCols			:= {}
//	aHeader			:= {}
//	n				:= 1
    cPathFile		:= cDirAnexos + "\" + cTipo + "\" + cAno + "\mes_" + cMes + "\"
	//lPermissao		:= (AllTrim(SE2->E2_ORIGEM)=="FINA050")

    MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt + "\" + cTipo + "\" + cAno)
    MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt + "\" + cTipo + "\" + cAno + "\mes_" + cMes)

else

    cMes			:= StrZero(Month(SC7->C7_EMISSAO),2)
	cAno			:= StrZero(Year(SC7->C7_EMISSAO),4)
//		aBkpaCols		:= aCols
//		aBkpaHeader	    := aHeader
//	    nBkp			:= n
	if lEdit
    	cPathFile	:= cDirAnexos + "\" + cEmpAnt + cFilAnt + "\" + cTipo + "\temp\"
	else
		cPathFile	:= cDirAnexos + "\" + cEmpAnt + cFilAnt + "\" + cTipo + "\" + cAno + "\mes_" + cMes + "\"
	endif

    MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt + "\" + cTipo + "\temp")
    MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt + "\" + cTipo + "\" + cAno)
    MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt + "\" + cTipo + "\" + cAno + "\mes_" + cMes)
    
endif


//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Carregando os anexos
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
U_GetAttachs()


Define MsDialog oDlg Title OemtoAnsi("Arquivos vinculados ao processo ") From 005, 005 To 350, 780 Pixel			//"Arquivos vinculados ao processo "
@ 010, 010 To 150, 380 MultiLine
IF funname() <> 'FINA050'
	cNumControle	:= SF1->(AllTrim(F1_DOC) + "_" + AllTrim(F1_SERIE) + "_" + AllTrim(F1_FORNECE) + "_" + AllTrim(F1_LOJA))
	lEdit:= .T.
	@ 155,010 Button OemtoAnsi("+ Adiciona") Size 037,012 When lEdit Pixel Of oDlg Action U_AddFile(cNumControle)		//"+ Adiciona"
	@ 155,060 Button OemtoAnsi("- Remove") Size 037,012 When lEdit Pixel Of oDlg Action U_EraseFile(cNumControle)		//"- Remove"
ENDIF
@ 155,110 /*110*/ Button OemtoAnsi("Abre") Size 037,012 PIXEL OF oDlg Action Open(@aExclui)									//"Abre"
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
	User Function GetAttachs()
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
	IF funname() == 'FINA050'
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
	ELSE
		
		if SD1->(dbSeek(xFilial("SD1") + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)))
			SF1->(dbSeek(xFilial("SF1") + SD1->(D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA)))
		do while SD1->(!eof() .and. D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA == xFilial("SD1") + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA))
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
	ENDIF
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


