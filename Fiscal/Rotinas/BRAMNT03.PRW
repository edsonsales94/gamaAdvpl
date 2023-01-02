//#include "rwmake.ch" 
#include "protheus.ch" 

/*/
———————————————————————————————————————————————————————————————————————————————
@function		BRAMNT03                                                     /@
@type           User Function                                                /@
@date			19/07/2021                                                   /@
@description	Cadastramento de configurações de TES por CFOP, no processo
                de  (Infracommerce e Sublimit)                      /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
                Opção Um Tecnologia da Informação                            /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function BRAMNT03()
Local aAreaSX2      := SX2->(GetArea())
Local lContinua
Private aRotina     := { 	{"Pesquisar",	"AxPesqui", 		0, 1},;
                            {"Visualizar",	"U_BRMNT03(2)", 	0, 2},;
                            {"Incluir",		"U_BRMNT03(3)", 	0, 3},;
                            {"Alterar",		"U_BRMNT03(4)", 	0, 4},;
                            {"Excluir",		"U_BRMNT03(5)", 	0, 5} }
Private lInclui, lAltera, lExclui

SX2->(dbSetOrder(1))
lContinua := SX2->(dbSeek("ZZD"))
RestArea(aAreaSX2)

if lContinua
	dbSelectArea("ZZD")
	mBrowse(,,,,"ZZD")

else
	Help(" ", 1, "ATENÇÃO", , "Esta empresa não possui configuração para uso de importação notas eCommerce." + chr(13) + chr(10) + "Específico "+ SM0->M0_NOME, 1)

endif

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		BRMNT03                                                      /@
@type           User Function                                                /@
@date			19/07/2021                                                   /@
@description	Função de manutenção da configuração de TES por CFOP         /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
                Opção Um Tecnologia da Informação                            /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function BRMNT03(nOpc)
Local nUsoInc			:= 0		// variavel auxiliar contador de campos na inclusao
Local aSize 			:= MsAdvSize()
Local nK, nI, nPosPROD, nPosCLIENT, nPosCST, nPosTES, nPosRECNO
Private nUsado			:= 0
Private aC				:= {}	// Array com descricao dos campos do Cabecalho do Modelo 2
							// aC[n,1] = Nome da Variavel Ex.:"cCliente"
							// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
							// aC[n,3] = Titulo do Campo
							// aC[n,4] = Picture
							// aC[n,5] = Validacao
							// aC[n,6] = F3
							// aC[n,7] = Se campo e' editavel .t. se nao .f.
Private nLinGetD		:= 0			// Variavel do Rodape do Modelo 2
Private aCGD			:= {60, 1, 200, 320}		//Array com coordenadas da GetDados no modelo2
Private aHeader			:= {}
Private aCols			:= {}
Private M->ZZD_CFOP   	:= iif(nOpc == 3, Space(5), ZZD->ZZD_CFOP)

//———————————————————————————————————————————————————————————————————————————————
// Montando aHeader e variável de cabeçalho
//———————————————————————————————————————————————————————————————————————————————
SX3->(dbSetOrder(1))
SX3->(dbSeek("ZZD"))
do while SX3->(!Eof() .and. X3_ARQUIVO == "ZZD")
   
	//aHeader
	if X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL .and. !AllTrim(SX3->X3_CAMPO) $ "ZZD_FILIAL#ZZD_CFOP"
	
		SX3->(aAdd(aHeader, {AllTrim(X3_TITULO), X3_CAMPO, X3_PICTURE,	X3_TAMANHO, X3_DECIMAL, X3_VLDUSER, X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT}))

	elseif AllTrim(SX3->X3_CAMPO) == "ZZD_CFOP"
	
		SX3->(aAdd(aC, {"M->ZZD_CFOP", {20, 5}, X3_TITULO, X3_PICTURE, X3_VLDUSER, X3_F3, (nOpc == 3)}))

	endif

	SX3->(dbSkip())

enddo

nUsado 		:= Len(aHeader)
nPosPROD	:= aScan(aHeader, {|x| Upper(alltrim(x[2])) == "ZZD_PROD"})
nPosCLIENT	:= aScan(aHeader, {|x| Upper(alltrim(x[2])) == "ZZD_CLIENT"})
nPosCST	    := aScan(aHeader, {|x| Upper(alltrim(x[2])) == "ZZD_CST"})
nPosTES 	:= aScan(aHeader, {|x| Upper(alltrim(x[2])) == "ZZD_TES"})
nPosRECNO 	:= aScan(aHeader, {|x| Upper(alltrim(x[2])) == "ZZD_RECNO"})

//———————————————————————————————————————————————————————————————————————————————
// Montando aCols
//———————————————————————————————————————————————————————————————————————————————
if nOpc == 3

	aCols	:= Array(1, nUsado + 1)
	SX3->(dbSeek("ZZD"))
	do while SX3->(!eof() .and. X3_ARQUIVO = "ZZD")
	   if X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL .and. !AllTrim(SX3->X3_CAMPO) $ "ZZD_FILIAL#ZZD_CFOP"
	   		nUsoInc++
			if SX3->X3_TIPO == "C"
				aCols[1, nUsoInc] 	:= space(SX3->X3_TAMANHO)
			elseif SX3->X3_TIPO == "N"
				aCols[1, nUsoInc] 	:= 0
			elseif SX3->X3_TIPO == "D"
				aCols[1, nUsoInc] 	:= cTOd("")
			elseif SX3->X3_TIPO == "M"
				aCols[1, nUsoInc] 	:= ""
			else
				aCols[1,nUsoInc]		:= .F.
			endif
		endif
		SX3->(dbSkip())
	enddo
	aCols[1, nUsado + 1]	:= .F.

else

	ZZD->(dbSeek(xFilial("ZZD")+M->ZZD_CFOP))
	do while ZZD->(!eof() .and. ZZD_FILIAL + ZZD_CFOP == xFilial("ZZD") + M->ZZD_CFOP)
	
		aAdd(aCols, Array(nUsado + 1))
		For nK := 1 to nUsado
			if AllTrim(aHeader[nK, 2]) == "ZZD_RECNO"
				aCols[Len(aCols), nK]	:= ZZD->(Recno())	//controle para alteração
			else
				aCols[Len(aCols), nK]	:= ZZD->(FieldGet(FieldPos(aHeader[nK, 2])))
			endif
		Next 
		aCols[Len(aCols), nUsado + 1]	:= .F.				//indicador se registro deletado

		ZZD->(dbSkip())

	enddo

endif	


//incluir um validador de linha
dbSelectArea("ZZD")
dbSetOrder(1)
if Modelo2("Configurações de TES por CFOP", aC, {}, aCGD, nOpc, "U_MNT03LiOk()",,,,,,{aSize[7], 0, aSize[6] - 10, aSize[5] - 10})

	//———————————————————————————————————————————————————————————————————————————————
	// Inclusão de registros
	//———————————————————————————————————————————————————————————————————————————————
	if nOpc == 3

		// Gravando os novos registros de acordo com o aCols
		For nI := 1 to Len(aCols)
			lDel	:= aCols[nI, Len(aHeader) + 2]
			if !lDel	// Considerar somente vetores nao excluidos
							
				ZZD->(RecLock("ZZD", .T.))
				ZZD->ZZD_FILIAL		:= xFilial("ZZD")
				ZZD->ZZD_CFOP   	:= M->ZZD_CFOP
				For nK := 1 to Len(aHeader)
					if aHeader[nK, 2] != "ZZD_RECNO"
			    		ZZD->(FieldPut(FieldPos(aHeader[nK, 2]), aCols[nI, nK]))
					endif
				Next
				ZZD->(MsUnlock())
				
			endif
			
		next
		
	//———————————————————————————————————————————————————————————————————————————————
	// Alteração de registros
	//———————————————————————————————————————————————————————————————————————————————
	elseif nOpc == 4

		for nI := 1 to Len(aCols)
			lDel	:= aCols[nI, Len(aHeader) + 1]
			nRegistro	:= aCols[nI, nPosRECNO]

			if nRegistro > 0

				ZZD->(dbGoTo(nRegistro))
				ZZD->(RecLock('ZZD', .F.))

				if lDel	// Considerar somente vetores nao excluidos
					ZZD->(DbDelete())
				else
					For nK := 1 to Len(aHeader)
						if aHeader[nK, 2] != "ZZD_RECNO"
				    		ZZD->(FieldPut(FieldPos(aHeader[nK, 2]), aCols[nI, nK]))
						endif
					Next
				endif
				ZZD->(MsUnlock())
         
			else

				if !lDel

					ZZD->(RecLock("ZZD", .T.))
					ZZD->ZZD_FILIAL		:= xFilial("ZZD")
					ZZD->ZZD_CFOP   	:= M->ZZD_CFOP
					For nK := 1 to Len(aHeader)
						if aHeader[nK, 2] != "ZZD_RECNO"
							ZZD->(FieldPut(FieldPos(aHeader[nK, 2]), aCols[nI, nK]))
						endif
					Next
					ZZD->(MsUnlock())

				endif
			
			endif
		
		next

	//———————————————————————————————————————————————————————————————————————————————
	// Exclusção de registros
	//———————————————————————————————————————————————————————————————————————————————
	elseif nOpc == 5

        ZZD->(dbSeek(xFilial("ZZD") + M->ZZD_CFOP))
        do while ZZD->(!Eof() .and. ZZD_FILIAL + ZZD_CFOP == xFilial("ZZD") + M->ZZD_CFOP)
            ZZD->(RecLock('ZZD', .F.))
            ZZD->(DbDelete())
            ZZD->(MsUnlock())
            ZZD->(dbSkip())
        enddo

	endif

endif

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		MNT03LIOK                                                     /@
@type			User function                                                 /@
@date			07/12/2015                                                    /@
@description	User function para validação da linha digitada                /@
@author			Adalberto Moreno Batista - Opção Um Consultoria               /@
@use			Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MNT03LiOk()
Local lRet 			:= .T.
Local nPosPROD		:= aScan(aHeader, {|x| Upper(alltrim(x[2])) == "ZZD_PROD"})
Local nPosCLIENT	:= aScan(aHeader, {|x| Upper(alltrim(x[2])) == "ZZD_CLIENT"})
Local nPosCST	    := aScan(aHeader, {|x| Upper(alltrim(x[2])) == "ZZD_CST"})
Local nK

if !aCols[n, Len(aHeader) + 1]	//Linha atual

	for nK := 1 to Len(aCols)

		if nK != n .and. !aCols[nK, Len(aHeader) + 1]

			if aCols[nK, nPosPROD] == aCols[n, nPosPROD] .and.;
				aCols[nK, nPosCLIENT] == aCols[n, nPosCLIENT] .and.;
				aCols[nK, nPosCST] == aCols[n, nPosCST]

				lRet := .F.			
				Help(" ", 1, "ATENÇÃO",, "Configuração com mesmo PRODUTO, CLIENTE e CST já configurado." + chr(13) + chr(10) + "Específico " + AllTrim(SM0->M0_NOME), 1)
			
			endif

		endif

	next
	
endif		

Return(lRet)


User Function VldTESMNT03()
Local lRet 		:= .T.
Local cMsg		:= ""

SF4->(dbSetOrder(1))

if SF4->(dbSeek(xFilial("SF4") + M->ZZD_TES))

	if SF4->(FieldPos("F4_MSBLQL")) > 0 .and. SF4->F4_MSBLQL == "1"
		cMsg	:= "TES bloqueado para uso!"
	elseif Substr(SF4->F4_CF,2,3) != Substr(M->ZZD_CFOP,2,3)
		cMsg	:= "CFOP do TES informado não coincide com o do CFOP da configuração!"
	elseif Left(M->ZZD_CFOP,1) $ "123" .and. SF4->F4_TIPO != "E"
		cMsg	:= "Informe um TES de entrada!"
	elseif Left(M->ZZD_CFOP,1) $ "567" .and. SF4->F4_TIPO != "S"
		cMsg	:= "Informe um TES de saida!"
	endif

else

	cMsg	:= "TES não encontrado!"

endif

if !Empty(cMsg)
	lRet	:= .F.
	Help("", 1, "ATENÇÃO",, cMsg + chr(13) + chr(10) + "(Específico " + AllTrim(SM0->M0_NOME) + ")", 1,,,,,,, {"Selecione <F3> para consultar os códigos permitidos."})
endif

return(lRet)
