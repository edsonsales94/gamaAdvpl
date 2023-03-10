#include "rwmake.ch"
#include "protheus.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		MT120LOK                                                      /@
@date				30/01/2017                                                    /@
@type				Ponto de entrada
@description	Valida linha do pedido de compras.                            /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Op鈬o Um Consultoria                                          /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function MT120LOK()
Local lRet := .T.

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Verifica se o grupo de aprova鈬o vinculado ao centro de custo ? igual ? todos
// os C.C informados no pedido
// Por: Adalberto Moreno Batista (Op鈬o Um Consultoria) em 30/01/2017
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if lRet
	lRet := A_MT120LOK()
endif

Return(lRet)


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		A_MT120LOK                                                    /@
@type				Static Function                                               /@
@date				31/01/2017                                                    /@
@description	Permite a inclus縊 de centros de custo somente se pertencerem
					? um mesmo grupo de aprova鈬o de compras                      /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Op鈬o Um Consultoria                                          /@
@use				Especifico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function A_MT120LOK()
Local aArea	 		:= GetArea()
Local aAreaCTT		:= CTT->(GetArea())
Local aAreaSY1		:= SY1->(GetArea())
Local nPosCC		:= aScan(aHeader, {|x| AllTrim(x[2]) == "C7_CC"})
Local lRet			:= .T.
Local cComprador	:= __cUserId  ///RetCodUsr()
Local cGrupo, nK

//Buscando o grupo do item posicionado
if !(aCols[ n,Len(aHeader)+1])

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// 1o) Se o comprador possuir um grupo de aprova鈬o vinculado ao seu cadastro,
	//     permite incluir itens para v疵ios departamentos.
	// 2o) Se o grupo de aprova鈬o do comprador estiver vazio, localiza o grupo aprov
	//     no cadastro de centros de custo.
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	SY1->(dbSetOrder(3))		//Y1_FILIAL, Y1_USER
	CTT->(dbSetOrder(1))		//CTT_FILIAL, CTT_CCUSTO

	SY1->(dbSeek(xFilial("SY1") + cComprador))
	if Empty(SY1->Y1_GRAPROV)

 		if !Empty(aCols[n, nPosCC])
			cGrupo	:= GetAdvFVal("CTT", "CTT_XAPVPC", xFilial("CTT") + aCols[n, nPosCC])
		endif

		for nK := 1 to Len(aCols)
			if !(aCols[ n,Len(aHeader)+1])
				if CTT->(dbSeek(xFilial("CTT") + aCols[nK, nPosCC]))
					if CTT->CTT_XAPVPC != cGrupo
						lRet := .F.
						Help(,, "ｮ ATENﾇﾃO",, "Informe um centro de custo com mesmo grupo de aprova鈬o dos outros itens j? registrados neste pedido de compras." + chr(13) + chr(10) + chr(13) + chr(10) + "(Espec?fico Brasitech)", 1)
					endif
				endif
			endif
		next

	else
	    
		cGrupo := SY1->Y1_GRAPROV
		
	endif

endif

RestArea(aAreaSY1)
RestArea(aAreaCTT)
RestArea(aArea)

Return(lRet)