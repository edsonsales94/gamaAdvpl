#include "rwmake.ch" 
#include "protheus.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		BFATA13                                                       /@
@type				User function                                                 /@
@date				02/12/2015                                                    /@
@description	User function para cadastramento de campanhas de vendas       /@
@author			Adalberto Moreno Batista - Op鈬o Um Consultoria               /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function BFATA13()
Private cCadastro := "Cadastro de campanhas de vendas"
Private aRotina   := {	{"Pesquisar",		"AxPesqui", 		 	0, 1},;
								{"Visualizar",		"U_FTA13_Manut(2)",	0, 2},;
								{"Incluir",			"U_FTA13_Manut(3)",	0, 3},;
								{"Alterar",			"U_FTA13_Manut(4)",	0, 4},;
								{"Excluir",			"U_FTA13_Manut(5)",	0, 5},;
								{"Legenda",			"U_FTA13_Legenda()", 0, 6} }
Private aCores		:= {	{"dTOs(SZX->ZX_VALINIC) > dTOs(dDataBase) .or. dTOs(SZX->ZX_VALFIM) < dTOs(dDataBase)", 		"BR_VERMELHO"},;
								{"dTOs(SZX->ZX_VALINIC) <= dTOs(dDataBase) .and. dTOs(SZX->ZX_VALFIM) >= dTOs(dDataBase)",	"BR_VERDE"}}

mBrowse(,,,,"SZX",,,,,,aCores)

Return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		FTA13_LEGENDA                                                 /@
@type				User function                                                 /@
@date				02/12/2015                                                    /@
@description	User function para acesso a legenda dos registros             /@
@author			Adalberto Moreno Batista - Op鈬o Um Consultoria               /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function FTA13_Legenda()
Local aLegenda := {	{"BR_VERDE", 	 "Registros Ativos"},;
							{"BR_VERMELHO", "Registros Inativos"}}
							
BrwLegenda(cCadastro, "Legenda", aLegenda)

Return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		FTA13_MANUT                                                   /@
@type				User function                                                 /@
@date				02/12/2015                                                    /@
@description	User function para manuten鈬o ou visualiza鈬o dos registros 
					de campanhas de vendas. 
					A vari疱el recebuda 'nOpc' controla a a鈬o no Modelo2 onde 3 
					ou 4 permitem alterar getdados e incluir linhas 6 somente 
					permite alterar getdados e n縊 incluir linhas. Qualquer outro 
					valor somente visualiza.                                      /@
@author			Adalberto Moreno Batista - Op鈬o Um Consultoria               /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function FTA13_Manut(nOpc)
Local nUsoInc		:= 0		// variavel auxiliar contador de campos na inclusao
Local nOrdem		:= SZX->(IndexOrd())
Local aSize 		:= MsAdvSize()
Local nI, nK, nPosProd, nPosDescr
Private nUsado		:= 0
Private aC			:= {}	// Array com descricao dos campos do Cabecalho do Modelo 2
							// aC[n,1] = Nome da Variavel Ex.:"cCliente"
							// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
							// aC[n,3] = Titulo do Campo
							// aC[n,4] = Picture
							// aC[n,5] = Validacao
							// aC[n,6] = F3
							// aC[n,7] = Se campo e' editavel .t. se nao .f.
Private nLinGetD	:= 0			// Variavel do Rodape do Modelo 2
Private aCGD		:= {60, 1, 200, 320}		//Array com coordenadas da GetDados no modelo2
Private aHeader	:= {}
Private aCols		:= {}
Private dDataAte	:= iif(nOpc == 3, LastDay(dDataBase), SZX->ZX_VALFIM)

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Avaliando se poder? utilizar a fun鈬o incluir
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if nOpc == 3
	dbSelectArea("SZX")
	if SZX->(dbSeek(xFilial("SZX")))
		Help(" ", 1, "ATENﾇﾃO",, "A inclus縊 de movimentos ? utilizada somente para quando n縊 h? nenhum produto incluido. Caso exista algum produto cadastrado, use a op鈬o 'Alterar'." + chr(13) + chr(10) + chr(13) + chr(10) + "(Espec?fico Brasitech).", 1)	
		Return()
	endif		
endif


//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Montando aHeader e vari疱el de cabe軋lho
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
SX3->(dbSetOrder(1))
SX3->(dbSeek("SZX"))
do while SX3->(!Eof() .and. X3_ARQUIVO == "SZX")
   
	//aHeader
	if X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL .and. !SX3->X3_CAMPO $ "ZX_FILIAL /ZX_CAMPAN /ZX_OBS    /ZX_ACAO   /ZX_VALFIM /ZX_GRATPRD/"
	
		SX3->(aAdd(aHeader, {AllTrim(X3_TITULO), X3_CAMPO, X3_PICTURE,	X3_TAMANHO, X3_DECIMAL, X3_VLDUSER, X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT}))

	elseif AllTrim(SX3->X3_CAMPO) == "ZX_VALFIM"
	
		SX3->(aAdd(aC, {"dDataAte", {20, 5}, X3_TITULO, X3_PICTURE, X3_VLDUSER, X3_F3, .T.}))

	endif

	SX3->(dbSkip())

enddo

nUsado 		:= Len(aHeader)
nPosProd		:= aScan(aHeader, {|x| Upper(alltrim(x[2])) == "ZX_PRODUTO"})
nPosDescr	:= aScan(aHeader, {|x| Upper(alltrim(x[2])) == "ZX_DESCR"})

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Montando aCols
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if nOpc == 3

	aCols	:= Array(1, nUsado + 1)
	SX3->(dbSeek("SZX"))
	do while SX3->(!eof() .and. X3_ARQUIVO = "SZX")
	   if X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL .and. !SX3->X3_CAMPO $ "ZX_FILIAL /ZX_CAMPAN /ZX_OBS    /ZX_ACAO   /ZX_VALFIM /ZX_GRATPRD/"
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
	aCols[1, nUsado + 1]		:= .F.

else

	SZX->(dbSeek(xFilial("SZX")))
	do while SZX->(!eof() .and. ZX_FILIAL == xFilial("SZX"))
	
		aAdd(aCols, Array(nUsado + 1))
		For nI := 1 to nUsado
			aCols[Len(aCols), nI]	:= SZX->(FieldGet(FieldPos(aHeader[nI, 2])))
		Next 
		aCols[Len(aCols), nUsado + 1]:=.F.
		
		// Alimentando o campo virtual ZX_DESCR
		aCols[Len(aCols), nPosDescr]	:= GetAdvFVal("SB1", "B1_DESC", xFilial("SB1") + aCols[Len(aCols), nPosProd], 1)
		
		SZX->(dbSkip())

	enddo

endif	


//incluir um validador de linha

dbSelectArea("SZX")
dbSetOrder(1)
if Modelo2(cCadastro, aC, {}, aCGD, nOpc, "U_Fta13LiOk()",,,,,,{aSize[7], 0, aSize[6] - 10, aSize[5] - 10})

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Inclus縊 de registros
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	if nOpc == 3

		// Gravando os novos registros de acordo com o aCols
		For nI := 1 to Len(aCols)
		
			if !aCols[nI, Len(aHeader) + 1]	// Considerar somente vetores nao excluidos
							
				SZX->(RecLock("SZX",	.T.))
				SZX->ZX_FILIAL		:= xFilial("SZX")
				SZX->ZX_VALFIM		:= dDataAte
				For nK := 1 to Len(aHeader)
			    	SZX->(FieldPut(FieldPos(aHeader[nK, 2]), aCols[nI, nK]))
				Next
				SZX->(MsUnlock())
				
			endif
			
		next
		
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Altera鈬o de registros
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	elseif nOpc == 4

		for nI := 1 to Len(aCols)
			
			if SZX->(dbSeek(xFilial("SZX") + aCols[nI, nPosProd]))
			
				if !aCols[nI,Len(aHeader)+1]	// Considerar somente vetores nao excluidos
				
					SZX->(RecLock("SZX", .F.))
					SZX->ZX_FILIAL		:= xFilial("SZX")
					SZX->ZX_VALFIM		:= dDataAte
					For nK := 1 to Len(aHeader)
				    	SZX->(FieldPut(FieldPos(aHeader[nK, 2]), aCols[nI, nK]))
					Next
					SZX->(MsUnlock())
         
				else
									
					SZX->(RecLock("SZX", .F.))
					SZX->(dbDelete())
					SZX->(MsUnlock())
				
				endif
			
			else
			
				SZX->(RecLock("SZX",	.T.))
				SZX->ZX_FILIAL		:= xFilial("SZX")
				SZX->ZX_VALFIM		:= dDataAte
				For nK := 1 to Len(aHeader)
			    	SZX->(FieldPut(FieldPos(aHeader[nK, 2]), aCols[nI, nK]))
				Next
				SZX->(MsUnlock())
			
			endif
		
		next

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Exclus鈬o de registros
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	elseif nOpc == 5

		for nI := 1 to Len(aCols)
			
			if SZX->(dbSeek(xFilial("SZX") + aCols[nI, nPosProd]))
				SZX->(RecLock("SZX", .F.))
				SZX->(dbDelete())
				SZX->(MsUnlock())
			endif
			
		next
				
	endif

endif

Return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		FTA13LIOK                                                     /@
@type				User function                                                 /@
@date				07/12/2015                                                    /@
@description	User function para valida鈬o da linha digitada                /@
@author			Adalberto Moreno Batista - Op鈬o Um Consultoria               /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function FTA13LIOK()
Local lRet 		:= .T.
Local nPosProd	:= aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "ZX_PRODUTO"})
Local cProduto	:= aCols[n, nPosProd]
Local nI

if !aCols[n, Len(aHeader) + 1]

	for nI := 1 to Len(aCols)
		if n != nI .and.;
			!aCols[nI, Len(aHeader) + 1] .and.;
			aCols[n, nPosProd] == aCols[nI, nPosProd]
			
			Help(" ", 1, "ATENﾇﾃO",, "Produto j? utilizado nesta campanha. Escolha outro produto." + chr(13) + chr(10) + chr(13) + chr(10) + "(Espec?fico Brasitech).", 1)
			lRet := .F.
			
		endif
	next
	
endif		
		
Return(lRet)
