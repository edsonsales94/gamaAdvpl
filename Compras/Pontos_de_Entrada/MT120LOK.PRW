#include "rwmake.ch"
#include "protheus.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		MT120LOK                                                      /@
@date				30/01/2017                                                    /@
@type				Ponto de entrada
@description	Valida linha do pedido de compras.                            /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Opção Um Consultoria                                          /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MT120LOK()
Local lRet := .T.

//———————————————————————————————————————————————————————————————————————————————
// Verifica se o grupo de aprovação vinculado ao centro de custo é igual à todos
// os C.C informados no pedido
// Por: Adalberto Moreno Batista (Opção Um Consultoria) em 30/01/2017
//———————————————————————————————————————————————————————————————————————————————
if lRet
	lRet := A_MT120LOK()
endif

Return(lRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		A_MT120LOK                                                    /@
@type				Static Function                                               /@
@date				31/01/2017                                                    /@
@description	Permite a inclusão de centros de custo somente se pertencerem
					à um mesmo grupo de aprovação de compras                      /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Opção Um Consultoria                                          /@
@use				Especifico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
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

	//———————————————————————————————————————————————————————————————————————————————
	// 1o) Se o comprador possuir um grupo de aprovação vinculado ao seu cadastro,
	//     permite incluir itens para vários departamentos.
	// 2o) Se o grupo de aprovação do comprador estiver vazio, localiza o grupo aprov
	//     no cadastro de centros de custo.
	//———————————————————————————————————————————————————————————————————————————————
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
						Help(,, "® ATENÇÃO",, "Informe um centro de custo com mesmo grupo de aprovação dos outros itens já registrados neste pedido de compras." + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Brasitech)", 1)
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