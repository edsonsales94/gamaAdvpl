#Include "RWMAKE.CH"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		M410LIOK                                                      /@
@type				Ponto de entrada                                              /@
@date				19/02/2009                                                    /@
@description	Valida鈬o da linha do pedido de vendas                        /@
@author			Cristiano Figueiroa                                           /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function M410LIOK()
Local lRet          := .T.
Local aArea			:= GetArea()
Local aAreaSB1		:= SB1->(GetArea())
Local aAreaSF4		:= SF4->(GetArea())
//Local nPosDesconto  := aScan(aHeader, {|x| Upper( Alltrim( x[2] ) ) == "C6_DESCONT" })
Local nPosPRODUTO   := aScan(aHeader, {|x| Upper( Alltrim( x[2] ) ) == "C6_PRODUTO" })
Local nPosArmazem   := aScan(aHeader, {|x| Upper( Alltrim( x[2] ) ) == "C6_LOCAL"   })
Local nPosTES       := aScan(aHeader, {|x| Upper( Alltrim( x[2] ) ) == "C6_TES"     })
Local nPosCLASFIS	:= aScan(aHeader, {|x| Upper( Alltrim( x[2] ) ) == "C6_CLASFIS" })
//Local cProduto      := aCols[n,nPosProduto]
Local cTes          := aCols[n,nPosTes]
Local cArmazem      := aCols[n,nPosArmazem]
//Local y

//ﾚﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄｿ
//ｳ Realiza validacao somente se a linha do pedido nao estiver deletada ｳ
//ﾀﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾙ
if !aCols[n , Len(aHeader) + 1]

	//ﾚﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄｿ
	//ｳ Preenche a classificacao tributaria do item. O campo C6_CLASFIS possui 3 digitos     ｳ
	//ｳ preenchidos, sendo o primeiro a origem do produto e os dois posteriores a situacao   ｳ
	//ｳ tributaria do ICMS                                                                   ｳ
	//ｳ Por: Adalberto Moreno Batista - 02/04/13                                             ｳ
	//ﾀﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾙ
	if lRet
		SB1->( dbSetOrder(1) )
		SB1->( msSeek(xFilial("SB1") + aCols[n, nPosPRODUTO]) )
		SF4->( dbSetOrder(1) )		
		SF4->( msSeek(xFilial("SF4") + aCols[n, nPosTES]) )
	
		aCols[n, nPosCLASFIS] := SB1->B1_ORIGEM + SF4->F4_SITTRIB
		
		if Len( AllTrim(aCols[n, nPosCLASFIS]) ) != 3
			lRet := .F.
			if !l410Auto
				MsgBox("A classifica鈬o tribut疵ia (CST) deste item est? inv疝ida. Ela ? composta da origem do produto (c?d. de 0 ? 7) mais a situa鈬o tribut疵ia do ICMS no TES (dois digitos num駻icos). Antes de continuar, verifique os campos 'Origem' (cadastro de produto) e/ou 'Sit.Trib.ICM' (cadastro de TES).", "Aten鈬o", "ERRO")
			else
				ConOut("M410LIOK - A classifica鈬o tribut疵ia (CST) deste item est? inv疝ida. Ela ? composta da origem do produto (c?d. de 0 ? 7) mais a situa鈬o tribut疵ia do ICMS no TES (dois digitos num駻icos). Antes de continuar, verifique os campos 'Origem' (cadastro de produto) e/ou 'Sit.Trib.ICM' (cadastro de TES).")
			endif
		endif		
    endif

	//ﾚﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄｿ
	//ｳ Caso a linha ainda esteja valida , valida o armazem e o TES         ｳ
	//ﾀﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾙ
	if lRet
	   lRet := u_VldArmTes ( cArmazem , cTes ) 
	endif   
	
	//ﾚﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄｿ
	//ｳ Valida politica comercial somente se for pedido INTERNO (C5_X_ORIG=1) e ｳ
	//ｳ tipo NORMAL (C5_TIPO=N) e para casos de INCLUSAO ou ALTERACAO e chamado ｳ
	//ｳ pelas rotinas de Pedido de Venda (MATA410) ou Orcamento (MATA416)       ｳ
	//ｳ Por: Adalberto Moreno Batista em 15/05/13                               ｳ
	//ﾀﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾙ
	/*
	retirado em 03/06/13, pois a critica devera ocorrer somente na finalizacao do pedido
	if	lRet .and.;
		M->C5_X_ORIG == "1" .and.;
		M->C5_TIPO == "N" .and.;
		(INCLUI .or. ALTERA) .and.;
		(Funname() $ ("MATA410-MATA416")) .and.;
		aCols[n, nPosDesconto] != 0

		nDescPV	:= aCols[n, nPosDesconto]
		lRet	:= U_VerDesCon( M->C5_CLIENTE , M->C5_CONDPAG , nDescPV )
	endif
	*/
	
	/*
	* retirada a verificacao de produto por pedido, para novo conceito de inclusao de pedidos.
	* em um mesmo pedido, havera itens de venda e bonificacao para facilitar a aprovacao de
	  credito
	//ﾚﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄｿ
	//ｳ Bloqueia o lancamento de um mesmo item mais de uma vez. Tal bloqueioｳ
	//ｳ se fez necessario devido aos Kits Promocionais.                     ｳ 
	//ﾀﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾙ
	If lRet .and. !SM0->M0_CODIGO $ "02-05"	// Bloqueia a digita鈬o de mais de um item no Pedido
		For y := 1 to Len( aCols )
	
			If !( y == n ) .and. cProduto == aCols[y][nPosProduto] .And. !aCols[ y , Len( aHeader ) + 1 ] .And. !aCols[ n , Len( aHeader ) + 1 ]
				lRet := .F.
				if !l410Auto
					Aviso( "Politica Comercial !" , "Aten鈬o ! O Produto : " + Alltrim( cProduto ) + " j? foi informado anteriormente nesse Pedido de Vendas ! N縊 ? permitida a inclus縊 de um mesmo ?tem em mais de uma linha no Pedido de Vendas !" , {"Ok"} , 1 , "Produto j? Existente ! " )
				else
					ConOut("M410LIOK - Aten鈬o ! O Produto : " + Alltrim( cProduto ) + " j? foi informado anteriormente nesse Pedido de Vendas ! N縊 ? permitida a inclus縊 de um mesmo ?tem em mais de uma linha no Pedido de Vendas !")
				endif
			Endif
		Next y
	Endif   
	*/
	
endif

/*
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Valida鈬o executada quando inclus縊 de pedido for utilizado pela rotina de 
// uso de cr馘ito VPC, na BFATA03.                                     
// Utiliza a vari疱el privada 'VPCVALCRED' que cont駑 o cr馘ito dispon?vel para 
// uso no pedido, n縊 deixando ultrapassar este valor.                        
// O tipo de opera鈬o obrigatoriamente dever? ser bonifica鈬o                 
// Por: Adalberto Moreno Batista - 24/07/13                                   
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?

N縊 h? necessidade de realizar esta valida鈬o, pois ? feita no sistema WEB.
Retirado em 19/08/19, por Adalberto

if lRet .and. !aCols[n,Len(aHeader)+1] .and. FunName()=="BFATA03" .and. SC5->(FieldPos("C5_X_CTVPC")) > 0
	lRet := A_M410LIOK()
endif
*/

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Valida鈬o o tipo do pedido de venda, de acordo com CFOP. Utilizado para 
// evitar que notas de remessa para armazenagem sejam enviadas para um "cliente"
// Por: Adalberto Moreno Batista - 21/03/2019                                   
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if lRet .and. !aCols[n,Len(aHeader)+1]
	lRet := B_M410LIOK()
endif


RestArea(aAreaSB1)
RestArea(aAreaSF4)
RestArea(aArea)

Return(lRet)


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		A_M410LIOK                                                    /@
@type				Static function                                               /@
@date				24/07/2013                                                    /@
@description	Valida鈬o executada quando inclus縊 de pedido for utilizado 
					pela rotina de uso de cr馘ito VPC, na BFATA03. 
					Utiliza a vari疱el privada 'VPCVALCRED' que cont駑 o cr馘ito 
					dispon?vel para uso no pedido, n縊 deixando ultrapassar este 
					valor.
					O tipo de opera鈬o obrigatoriamente dever? ser bonifica鈬o  
					excluir um determinado pedido de venda                        /@
@author			Adalberto Moreno Batista                                      /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?

Static Function A_M410LIOK()
Local lRet		:= .T.
Local aArea		:= GetArea()
Local aAreaSB1	:= SB1->(GetArea())
Local aAreaSF4	:= SF4->(GetArea())
Local nPosOPER	:= aScan(aHeader, {|x| Upper(Alltrim(x[2])) == "C6_OPER"})
Local nPosVALOR	:= aScan(aHeader, {|x| Upper(Alltrim(x[2])) == "C6_VALOR"})
Local nPosTES	:= aScan(aHeader, {|x| Upper(Alltrim(x[2])) == "C6_TES"})
Local nPosPROD	:= aScan(aHeader, {|x| Upper(Alltrim(x[2])) == "C6_PRODUTO"})
Local nSoma		:= 0
Local cEol		:= chr(13) + chr(10)
Local nX, nValIPI, lIPI


if !aCols[n, Len(aHeader) + 1]
	SF4->(dbSetOrder(1))
	SB1->(dbSetOrder(1))
	SZJ->(dbSetOrder(1))	//1 - ZJ_FILIAL+ZJ_CONTRAT+ZJ_CLIENTE+ZJ_LOJA
	
	//Localizo o contrato e verifico qual ? a base de c疝culo
	if SZJ->(dbSeek(xFilial("SZJ") + M->C5_X_CTVPC))
		lIPI := (SZJ->ZJ_IPI=="S")
	endif

	SF4->(dbSeek(xFilial("SF4") + aCols[n, nPosTES]))

	if aCols[n,nPosOPER] == "03" .and. SF4->F4_DUPLIC == "N"
		
		for nX := 1 to Len(aCols)
			
			if !aCols[n, Len(aHeader) + 1]
				SB1->(dbSeek(xFilial("SB1") + aCols[nX, nPosPROD]))
				SF4->(dbSeek(xFilial("SF4") + aCols[nX, nPosTES]))
		
				if SF4->F4_IPI == "S" .and. lIPI
					nValIPI := aCols[nX, nPosVALOR] * (SB1->B1_IPI / 100)
				else
					nValIPI	:= 0
				endif
				
				nSoma += aCols[nX, nPosVALOR] + nValIPI
			endif
			
		next
		
		//Variavel privada VPCVALCRED, criada na rotina PV_FT03 (fonte BFATA03) e alimentada na funcao VPCCred (fonte BFATA03)
		if nSoma > VPCVALCRED
			lRet := .F.
			Help(" ", 1, "Aten鈬o",, "Este pedido est? sendo inclu?do pela rotina de uso de cr馘itos VPC, por駑 o valor total do pedido ultrapassa o cr馘ito dispon?vel para este cliente." + cEol + "Cr馘ito dispon?vel R$ " + AllTrim(Transf(VPCVALCRED,"@E 999,999,999.99")) + cEol + cEol + "(Espec?fico Gama Italy)," + cEol + "ponto de entrada M410LIOK.", 1)
		endif
		
	else
		
		lRet := .F.
		Help(" ", 1, "Aten鈬o",, "Este pedido est? sendo inclu?do pela rotina de uso de cr馘itos VPC, portanto a opera鈬o, obrigatoriamente, deve ser uma bonifica鈬o (03) e o TES escolhido n縊 poder? gerar duplicata." + cEol + cEol + "(Espec?fico Gama Italy)," + cEol + "ponto de entrada M410LIOK.", 1)
			
	endif

	RestArea(aAreaSB1)
	RestArea(aAreaSF4)
	RestArea(aArea)

endif

Return(lRet)
/*/

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		B_M410LIOK                                                    /@
@type				Static function                                               /@
@date				21/03/2019                                                    /@
@description	Valida鈬o o tipo do pedido de vendas, de acordo com o CFOP.
					utilizado para definir o tipo B ou D para alguns CFOPｴs, 
					evitando que notas para remessa para armazenagem, sejam 
					enviadas para um cliente                                      /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Op鈬o Um Consultoria                                          /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function B_M410LIOK()
Local lRet			:= .T.
Local cListCFOP	:= AllTrim(GetMV("BR_CFOPFOR", .F., ""))
Local nPosCF		:= aScan(aHeader, {|x| Upper(Alltrim(x[2])) == "C6_CF"})
Local cEol			:= chr(13) + chr(10)
	
if nPosCF > 0 .and. !M->C5_TIPO $ "BD" .and. !Empty(cListCFOP) .and. AllTrim(aCols[n,nPosCF]) $ cListCFOP
	lRet := .F.
	if !l410Auto
		Help(" ", 1, "Aten鈬o",, "Para o CFOP informado, o tipo do pedido dever? ser beneficiamento (B) ou Devolu鈬o (D), pois se trata de uma remessa ? um fornecedor" + cEol + cEol + "(Espec?fico Gama Italy)," + cEol + "ponto de entrada M410LIOK.", 1)
	endif
endif
		
Return(lRet)
