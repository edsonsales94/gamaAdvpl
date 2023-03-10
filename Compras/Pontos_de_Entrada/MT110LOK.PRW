#include "rwmake.ch"
#include "protheus.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		MT110LOK                                                     /@
@date			28/09/2020                                                   /@
@type			Ponto de entrada
@description	Valida linha do pedido de compras.                           /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Op鈬o Um Tecnologia da Informa鈬o                            /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function MT110LOK()
Local lRet := .T.

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Bloco j? existente, por駑 sem documenta鈬o
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if lRet
	lRet := A_MT110LOK()
endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Verifica se o grupo de aprova鈬o vinculado ao centro de custo ? igual ? todos
// os C.C informados na solicita鈬o
// Por: Adalberto Moreno Batista em 28/09/2020
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if lRet
	lRet := B_MT110LOK()
endif

Return(lRet)


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		A_MT110LOK                                                   /@
@type			Static Function                                              /@
@date			??/??/????                                                   /@
@description	Sequencia j? existente, mas n縊 documentada. Transformada em
				subfun鈬o para melhor organiza鈬o do fonte.
				Valida鈬o de preenchimento de centro de custo                /@
@author			                                                             /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function A_MT110LOK()
Local nPosPrd    := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_RATEIO'})
Local nPosCc     := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_CC'})
Local nPosMrp    := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_SEQMRP'})
Local lValido := .T.

If ALLTRIM(aCols[n][nPosPrd])=='2' .AND. LEN(ALLTRIM(aCols[n][nPosCc]))==0 .AND. LEN(ALLTRIM(aCols[n][nPosMrp]))==0    //incluido para nao atrapalhar criacao de sc no mrp
	Help(,, "ｮ ATENﾇﾃO",, "O preenchimento do centro de custo ? obrigat?rio." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
	lValido := .F.
EndIf

Return(lValido) 


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		B_MT110LOK                                                   /@
@type			Static Function                                              /@
@date			28/09/2020                                                   /@
@description	Permite a inclus縊 de centros de custo somente se pertencerem
				? um mesmo grupo de aprova鈬o de compras                     /@
@author			Adalberto Moreno Batista - Op鈬o Um Tecnologia da Informa鈬o /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function B_MT110LOK()
Local aArea	 		:= GetArea()
Local aAreaCTT		:= CTT->(GetArea())
//Local aAreaSY1		:= SY1->(GetArea())
Local nPosCC		:= aScan(aHeader, {|x| AllTrim(x[2]) == "C1_CC"})
Local lRet			:= .T.
//Local cComprador	:= __cUserId  ///RetCodUsr()
Local cGrupo, nK

//Buscando o grupo do item posicionado
if !(aCols[ n,Len(aHeader)+1])

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// 1o) Se o comprador possuir um grupo de aprova鈬o vinculado ao seu cadastro,
	//     permite incluir itens para v疵ios departamentos.
	// 2o) Se o grupo de aprova鈬o do comprador estiver vazio, localiza o grupo aprov
	//     no cadastro de centros de custo.
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
//	SY1->(dbSetOrder(3))		//Y1_FILIAL, Y1_USER
	CTT->(dbSetOrder(1))		//CTT_FILIAL, CTT_CCUSTO

//	SY1->(dbSeek(xFilial("SY1") + cComprador))
//	if Empty(SY1->Y1_GRAPROV)

 		if !Empty(aCols[n, nPosCC])
			cGrupo	:= GetAdvFVal("CTT", "CTT_XAPVPC", xFilial("CTT") + aCols[n, nPosCC])
		endif

		for nK := 1 to Len(aCols)
			if !(aCols[ n,Len(aHeader)+1])
				if CTT->(dbSeek(xFilial("CTT") + aCols[nK, nPosCC]))
					if CTT->CTT_XAPVPC != cGrupo
						lRet := .F.
						Help(,, "ｮ ATENﾇﾃO",, "Informe um centro de custo com mesmo grupo de aprova鈬o dos outros itens j? registrados nesta solicita鈬o de compras." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
					endif
				endif
			endif
		next

//	else
	    
//		cGrupo := SY1->Y1_GRAPROV
		
//	endif

endif

//RestArea(aAreaSY1)
RestArea(aAreaCTT)
RestArea(aArea)

Return(lRet)
