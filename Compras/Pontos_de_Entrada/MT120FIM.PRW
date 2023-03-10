#include "protheus.ch"     
#include "rwmake.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		MA120FIM                                                     /@
@type			Ponto de entrada                                             /@
@date			26/09/2019                                                   /@
@description	Ap?s a restaura鈬o do filtro da FilBrowse depois de fechar a 
				opera鈬o realizada no pedido de compras, ? a ultima instru鈬o
				da fun鈬o A120Pedido. Adiciona fun鈬o no menu (aRotina) de 
				pedidos de compras.                                          /@
@author			Adalberto Moreno Batista (Op鈬o Um Tecnologia)               /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function MT120FIM()
Local aArea			:= GetArea()
Local aAreaSCR		:= SCR->(GetArea())
Local nFuncao		:= ParamIxb[1]
Local cNum			:= ParamIxb[2]
Local nOpc			:= ParamIxb[3]
Local cAno			:= StrZero(Year(dA120Emis), 4)
Local cMes			:= StrZero(Month(dA120Emis), 2)
Local cDirAnexos	:= GetMV("BR_ANEXOPC")		// "\\MARROCOS\COTACOES"
Local cDirEmp		:= "\" + cEmpAnt + cFilAnt
Local aAprov		:= {}
Local aHistAprov	:= {}
Local nX, aFiles, cPathTemp, cPathReal, cStrAprov, nPos, cParte

cPathTemp	:= cDirAnexos + cDirEmp + "\PC\temp\"
cPathReal	:= cDirAnexos + cDirEmp + "\PC\" + cAno + "\mes_" + cMes + "\"

MakeDir(cDirAnexos)
MakeDir(cDirAnexos + cDirEmp)
MakeDir(cDirAnexos + cDirEmp + "\PC")
MakeDir(cDirAnexos + cDirEmp + "\PC\temp")
MakeDir(cDirAnexos + cDirEmp + "\PC\" + cAno)
MakeDir(cDirAnexos + cDirEmp + "\PC\" + cAno + "\mes_" + cMes)

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Cancelamento da inclus縊 ou altera鈬o
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if (nOpc == 0 .and. (nFuncao == 3 .or. nFuncao == 4))
	//Excluo os anexos do diretorio TEMP, para efeito de limpeza do ambiente
	aFiles		:= Directory( cPathTemp + cFilAnt + "_" + AllTrim(cNum) + "_" + "*.*")
	if Len(aFiles) > 0
		for nX := 1 to Len(aFiles)
			fErase(cPathTemp + aFiles[nX,1])
		next
	endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Confirma鈬o da exclus縊
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
elseif (nOpc == 1 .and. nFuncao == 5)
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Exclui os arquivos vinculados ao pedido de compras, para situa鋏es onde h? o
	// abandono da inclus縊 do PC ou confirma鈬o da exclus縊 do PC
	// H? a refer麩cia do diretorio \ANEXOS_PC\ no ponto de entrada MA120BUT
	// Por: Adalberto Moreno Batista (Op鈬o Um Consultoria) em 16/03/2017
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	//Excluo os anexos do diretorio REAL
	aFiles		:= Directory( cPathReal + cFilAnt + "_" + AllTrim(cNum) + "_" + "*.*")
	if Len(aFiles) > 0
		for nX := 1 to Len(aFiles)
			fErase(cPathReal + aFiles[nX,1])
		next
	endif
   
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Confirma鈬o da inclus縊 ou altera鈬o
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
elseif nOpc == 1 .and. (nFuncao == 3 .or. nFuncao == 4)		

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Ao confirmar a opera鈬o de inclus縊 ou altera鈬o realizo as seguintes a鋏es:
	// 1ｺ) Limpo os anexos remanescentes do diretorio REAL
	// 2ｺ) Copio os anexos do diret?rio TEMP para o diretorio REAL
	// 3ｺ) Limpo os anexos do diret?rio TEMP
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	aFiles		:= Directory( cPathReal + cFilAnt + "_" + AllTrim(cNum) + "_" + "*.*")
	if Len(aFiles) > 0
		for nX := 1 to Len(aFiles)
			fErase(cPathReal + aFiles[nX,1])
		next
	endif

	aFiles		:= Directory( cPathTemp + cFilAnt + "_" + AllTrim(cNum) + "_" + "*.*")
	if Len(aFiles) > 0
		for nX := 1 to Len(aFiles)
			__CopyFile(cPathTemp + aFiles[nX,1], cPathReal + aFiles[nX,1])
			fErase(cPathTemp + aFiles[nX,1])
		next
	endif


	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Identifico a estrutura de aprova鈬o, gravada para o pedido de compras. Ser? 
	// utilizada para a grava鈬o do hist?rico de reemiss?es (altera鋏es) de pedidos
	// Por: Adalberto Moreno Batista (Op鈬o Um Consultoria) em 02/05/2018
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	SCR->(dbSetOrder(1))		//CR_FILIAL, CR_TIPO, CR_NUM, CR_NIVEL
	SCR->(dbSeek(xFilial("SCR") + "PC" + SC7->C7_NUM))
	do while SCR->(!eof() .and. CR_FILIAL + CR_TIPO + Left(CR_NUM,6) == xFilial("SCR") + "PC" + SC7->C7_NUM)
		aAdd(aAprov, {SCR->CR_USER, 0})
		SCR->(dbSkip())
	enddo
	RestArea(aAreaSCR)
	RestArea(aArea)

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Posiciona no primeiro item do pedido de compras
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	SC7->(dbSetOrder(1))
	if SC7->(dbSeek(xFilial("SC7") + cNum))

		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		// Verifico se pedido ? proveniente de um contrato e movimento os anexos da 
		// medi鈬o para o pedido de compra
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		if !empty(SC7->C7_CONTRA) .and. nFuncao == 3

			cContrato	:= AllTrim(SC7->C7_CONTRA)
			cPathContr	:= cDirAnexos + cDirEmp + "\CT\" + cContrato + "\medicao\"
			
			MakeDir(cDirAnexos + cDirEmp + "\CT")
			MakeDir(cDirAnexos + cDirEmp + "\CT\temp")
			MakeDir(cDirAnexos + cDirEmp + "\CT\" + cContrato)
			MakeDir(cDirAnexos + cDirEmp + "\CT\" + cContrato + "\MEDICAO")

			// Movendo anexos das medi鋏es para o pedido de compras
			aFiles		:= Directory(cPathContr + cFilAnt + "_" + cContrato + "_*.*")
			For nX:=1 to Len(aFiles)
				cRenAttach	:= StrTran(Lower(aFiles[nX,1]), cFilAnt + "_" + cContrato + "_", "")
				__CopyFile(cPathContr + aFiles[nX,1], cPathReal + cFilAnt + "_" + SC7->C7_NUM + "_" + cRenAttach)
				if file(cPathReal + cFilAnt + "_" + SC7->C7_NUM + "_" + cRenAttach)
					fErase(cPathContr + aFiles[nX,1])
				endif
			Next

		endif


		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		// Tratando a quantidade de aprova鋏es por aprovador com a string de controle de
		// reemiss?es de pedidos (C7_XHISAPR)
		// Por: Adalberto Moreno Batista (Op鈬o Um Tecnologia da Informa鈬o)
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?

			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			// Identificando a lista hist?rica de aprovadores, gravados no pedido de compra
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			cStrAprov 	:= iif(SC7->(FieldPos("C7_XHISAPR")) > 0, AllTrim(SC7->C7_XHISAPR), "")
			cStrAprov	:= StrTran(cStrAprov, ";", Chr(13) + Chr(10))
			for nX := 1 to MlCount(cStrAprov)
				cParte 	:= AllTrim(MemoLine(cStrAprov,, nX))
				nPos 	:= At("=", cParte)
				if nPos > 0
					aAdd(aHistAprov, {Left(cParte, nPos - 1), Val(Substr(cParte, nPos + 1))})
				endif
			next
			
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			// Ajusto a qtde de reemiss縊 ao hist?rico
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			for nX := 1 to Len(aAprov)
				nPos := aScan(aHistAprov, {|x| x[1] == aAprov[nX,1]})
				if nPos > 0
					aAprov[nX,2] := aHistAprov[nPos, 2]
				endif
			next
		
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			// Se a estrutura de aprovadores tiver sido alterada, fa輟 um join para manter 
			// o hist?rico de todos os aprovadores.
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			for nX := 1 to Len(aHistAprov)
				if aScan(aAprov, {|x| x[1] == aHistAprov[nX,1]}) == 0
					aAdd(aAprov, {aHistAprov[nX, 1], aHistAprov[nX, 2]})
				endif
			next
		
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			// Monto a string para grava鈬o no campo de hist?rico do pedido de compra
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			cStrAprov := ""
			for nX := 1 to Len(aAprov)
				cStrAprov += AllTrim(aAprov[nX,1]) + "=" + AllTrim(Str(aAprov[nX,2])) + ";"
			next

			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			// Gravo o campo de hist?rico de aprova鋏es
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			if SC7->(FieldPos("C7_XHISAPR")) > 0
				do while SC7->(!eof() .and. C7_FILIAL == xFilial("SC7") .and. C7_NUM == cNum)
					SC7->(RecLock("SC7",.F.))
					SC7->C7_XHISAPR	:= cStrAprov
					//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
					//Ronaldo Silva - 18/04/2022 
					// Adiciono campos especificos do pedido de compras, buscando informa鋏es 
					// banc疵ias do fornecedor para forma de pagamento definido nos itens da planilha 
					// do contrato.
					//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
					If SC7->C7_X_FORPG == "2" // Deposito em conta
						DbSelectArea("SA2")
						DbSetOrder(1)
						IF SA2->(DbSeek(xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA))
							SC7->C7_XBANCO:=SA2->A2_BANCO
							SC7->C7_XAGENC:=SA2->A2_AGENCIA
							SC7->C7_XCONTA:=SA2->A2_NUMCON
							SC7->C7_XDVCTA:=SA2->A2_DVCTA
						ENDIF
					ENDIF	
					SC7->(MsUnlock())
					SC7->(dbSkip())
				enddo
			endif

		// Fim tratamento historico de altera鋏es

	endif

endif

//temporario para acionar o job de pedido de compras	
//StartJob("U_DKTJOB15", GetEnvServer(), .F.)
Return()
