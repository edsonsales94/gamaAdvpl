#include "rwmake.ch"
#include "protheus.ch"

/*/
�������������������������������������������������������������������������������
@function		MT110LOK                                                     /@
@date			28/09/2020                                                   /@
@type			Ponto de entrada
@description	Valida linha do pedido de compras.                           /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Op��o Um Tecnologia da Informa��o                            /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
/*/
User Function MT110LOK()
Local lRet := .T.

//�������������������������������������������������������������������������������
// Bloco j� existente, por�m sem documenta��o
//�������������������������������������������������������������������������������
if lRet
	lRet := A_MT110LOK()
endif

//�������������������������������������������������������������������������������
// Verifica se o grupo de aprova��o vinculado ao centro de custo � igual � todos
// os C.C informados na solicita��o
// Por: Adalberto Moreno Batista em 28/09/2020
//�������������������������������������������������������������������������������
if lRet
	lRet := B_MT110LOK()
endif

Return(lRet)


/*/
�������������������������������������������������������������������������������
@function		A_MT110LOK                                                   /@
@type			Static Function                                              /@
@date			??/??/????                                                   /@
@description	Sequencia j� existente, mas n�o documentada. Transformada em
				subfun��o para melhor organiza��o do fonte.
				Valida��o de preenchimento de centro de custo                /@
@author			                                                             /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
/*/
Static Function A_MT110LOK()
Local nPosPrd    := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_RATEIO'})
Local nPosCc     := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_CC'})
Local nPosMrp    := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_SEQMRP'})
Local lValido := .T.

If ALLTRIM(aCols[n][nPosPrd])=='2' .AND. LEN(ALLTRIM(aCols[n][nPosCc]))==0 .AND. LEN(ALLTRIM(aCols[n][nPosMrp]))==0    //incluido para nao atrapalhar criacao de sc no mrp
	Help(,, "� ATEN��O",, "O preenchimento do centro de custo � obrigat�rio." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
	lValido := .F.
EndIf

Return(lValido) 


/*/
�������������������������������������������������������������������������������
@function		B_MT110LOK                                                   /@
@type			Static Function                                              /@
@date			28/09/2020                                                   /@
@description	Permite a inclus�o de centros de custo somente se pertencerem
				� um mesmo grupo de aprova��o de compras                     /@
@author			Adalberto Moreno Batista - Op��o Um Tecnologia da Informa��o /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
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

	//�������������������������������������������������������������������������������
	// 1o) Se o comprador possuir um grupo de aprova��o vinculado ao seu cadastro,
	//     permite incluir itens para v�rios departamentos.
	// 2o) Se o grupo de aprova��o do comprador estiver vazio, localiza o grupo aprov
	//     no cadastro de centros de custo.
	//�������������������������������������������������������������������������������
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
						Help(,, "� ATEN��O",, "Informe um centro de custo com mesmo grupo de aprova��o dos outros itens j� registrados nesta solicita��o de compras." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
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