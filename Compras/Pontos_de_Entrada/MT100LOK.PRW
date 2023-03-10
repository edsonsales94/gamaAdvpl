#include "rwmake.ch"
#include "protheus.ch"

/*
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		MT100LOK                                         /@
@type			Ponto de entrada                                 /@
@date			10/12/2010                                       /@
@description	Valida linha de uma nota fiscal de entrada
				Retorna .T. ou .F.                               /@
@author			                                                 /@
@use			Especifico Brasitech                             /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
*/
User Function MT100LOK()

Local _nPosConta	:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "D1_CONTA"})
Local _nPosCC		:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "D1_CC"})
Local _lRet			:= .T.

//if Type("l103Auto") != "L"
//	l103Auto := .F.
//endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Analisa se o CFOP esta correto em relacao a origem e destino,
// inicio com 1, 2 ou 3. Incluido para validacao de falha no padrao.
// Por: SI8401 - Adalberto Moreno Batista em 14/03/11
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
_lRet := B_MT100LOK()


//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Identifica se eh uma nota de importacao e obriga a informar a 
// adicao, sequencia da adicao e fabricantes.
// Por: SI8401 - Adalberto Moreno Batista em 10/12/10
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*
Retirada a validacao em 31/10/11 em razao da TOTVS ter incluido as referidas informacoes
no padrao do Protheus. Estas informacoes deverao ser cadastradas na tabela CD5
if cFormul = 'S' .and. cTipo $ 'NCIP'

	if SA2->A2_EST = 'EX' .and. SD1->( FieldPos( "D1_X_ADIC" ) ) > 0

		_lRet := A_MT100LOK()

	endif

endif
*/

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Verifica se a conta contabil faz parte do grupo de Despesas, o 
// qual inicia pelo digito 4 e valida se o campo centro de custo esta
// digitado.
// Por: Luiz Fernando C Nogueira em 27/05/11
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// verificando se a linha nao esta excluida
if !aCols[N,Len(aHeader)+1]
	
	If Funname() == "MATA103" .and. !IsBlind()
		if	(SUBSTR(aCols[N,_nPosConta],1,1) == '4') .AND. Empty(AllTrim(aCols[N,_nPosCC]))
			_lRet := .F.
			MsgBox("Conta cont畸il faz parte do grupo de Despesas. Portanto ? obrigat?rio preencher o centro de custo.", "ATENﾇﾃO... (MT100LOK)", "ERRO")
		endif
	endif
endif
	

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Verifica se o custo especifico GAMA foi informado para situacoes 
// onde o CFOP da operacao esteja cadastrado no parametro especifico
// BR_CFOPCUS. 
// Por: Adalberto Moreno Batista em 08/04/13
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if !aCols[N,Len(aHeader)+1] .and. _lRet		//verifica se eh uma linha nao excluida

	if SD1->( FieldPos( "D1_CUSGAMA" ) ) > 0
	
		_lRet := C_MT100LOK()
		
	endif

endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Preenche automaticamente o codigo da classificacao fiscal da 
// operacao para os itens nao excluidos
// Por: Adalberto Moreno Batista em 25/06/13
// Em 23/07/13 inclui as funcoes MaFisLoad e MaFisLF
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if !aCols[n, Len(aHeader) + 1]
	D_MT100LOK()
endif

// Function utilizada pelo importador "Conexao NFe"
E_MT100LOK()


//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Se nota de servico e possuir INSS, valida se cadastro de produtos
// est? adequado. 
// Motivo: integra鈬o com o TAF para o REINF
// Por: Adalberto Moreno Batista em 15/10/18
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if !aCols[n, Len(aHeader) + 1] .and. _lRet
	_lRet := F_MT100LOK()
endif

Return(_lRet)


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		A_MT100LOK                                                   /@
@type			Static function                                              /@
@date			10/12/2010                                                   /@
@description	Identifica se ? uma nota de importacao e obriga a informar a 
				adicao, sequencia da adicao e fabricantes.
				Retorna .T. ou .F.                                           /@
@author			Adalberto Moreno Batista                                     /@
@use			Espec?fico Brasitech                                         /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function A_MT100LOK()
Local _lRet		:= .T.
Local _nPosX_ADIC	:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "D1_X_ADIC"})
Local _nPosX_SQADI	:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "D1_X_SQADI"})
Local _nPosX_FABR	:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "D1_X_FABR"})

// verificando se a linha nao esta excluida
if !aCols[N,Len(aHeader)+1]
	
	if	Empty(AllTrim(aCols[N,_nPosX_ADIC])) .or.;
		Empty(AllTrim(aCols[N,_nPosX_SQADI])) .or.;
		Empty(AllTrim(aCols[N,_nPosX_FABR]))

		_lRet := .F.
		if !IsBlind()	//!l103Auto
			MsgBox( "A 'adi鈬o da importa鈬o', 'sequ麩cia' e 'fabricante' s縊 obrigat?rios para notas de importa鈬o e n縊 foram preenchidos.", "ATENﾇﾃO... (MT100LOK)", "ERRO" )
		else
			Conout("MT100LOK - Aten鈬o: A 'adi鈬o da importa鈬o', 'sequ麩cia' e 'fabricante' s縊 obrigat?rios para notas de importa鈬o e n縊 foram preenchidos.")
		endif
		
	endif
		
endif

Return(_lRet)


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		B_MT100LOK                                                   /@
@type			Static function                                              /@
@date			14/03/2011                                                   /@
@description	Analisa se o CFOP esta correto em relacao a origem e destino,
				inicio com 1, 2 ou 3. Incluido para validacao de falha no 
				padrao.
				Retorna .T. ou .F.                                           /@
@author			Adalberto Moreno Batista                                     /@
@use			Espec?fico Brasitech                                         /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function B_MT100LOK()
Local _lRet		:= .T.
Local _nPosCF	:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "D1_CF"})
Local _cCFOP

// verificando se a linha nao esta excluida
if !aCols[N,Len(aHeader)+1]
	
	If Funname() == "MATA103"
	
	if !empty(CUFORIG) .AND. !(aCols[N,_nPosCF]) == '000  '

		if	(CUFORIG == 'EX' .and. Left(aCols[N,_nPosCF],1) != '3') .or.;
			(CUFORIG == SM0->M0_ESTCOB .and. Left(aCols[N,_nPosCF],1) != '1') .or.;
			(CUFORIG != 'EX' .and. CUFORIG != SM0->M0_ESTCOB .and. Left(aCols[N,_nPosCF],1) != '2')
	
			_lRet := .F.
			
			if	CUFORIG == 'EX'
				_cCFOP := '3' + Substr( aCols[N,_nPosCF], 2, 3)
			elseif CUFORIG == SM0->M0_ESTCOB
				_cCFOP := '1' + Substr( aCols[N,_nPosCF], 2, 3)
			elseif CUFORIG != SM0->M0_ESTCOB
				_cCFOP := '2' + Substr( aCols[N,_nPosCF], 2, 3)
			endif
			
			if !IsBlind()	//!l103Auto
				MsgBox( "CFOP inv疝ido considerando a UF do emitente e a UF do destinat疵io. O CFOP correto ? " + _cCFOP, "ATENﾇﾃO... (MT100LOK)", "ERRO" )
			else
				Conout("MT100LOK - CFOP inv疝ido considerando a UF do emitente e a UF do destinat疵io.")
			endif
			
		endif

	endif
	
	endif	
endif

Return(_lRet)


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		C_MT100LOK                                                   /@
@type			Static function                                              /@
@date			08/04/2013                                                   /@
@description	Verifica se o custo especifico GAMA foi informado para 
				situacoes onde o CFOP da operacao esteja cadastrado no 
				parametro especifico BR_CFOPCUS.
				Retorna .T. ou .F.                                           /@
@author			Adalberto Moreno Batista                                     /@
@use			Espec?fico Brasitech                                         /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function C_MT100LOK()
Local _lRet	 		:= .T.
Local _cCFOPcusto	:= GetMV("BR_CFOPCUS", .F., "")
Local _nPosCUSGAMA	:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "D1_CUSGAMA"})
Local _nPosCOD		:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "D1_COD"})
Local _nPosCF		:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "D1_CF"})
Local _nPosTES		:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "D1_TES"})
Local _nPosQUANT	:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "D1_QUANT"})
Local _aArea		:= GetArea()
Local _aAreaSF4		:= SF4->( GetArea() )
Local nDecimal		:= TamSX3("D1_CUSGAMA")[2]
Local cEol			:= chr(13) + chr(10)

SF4->( dbSetOrder(1) )
if SF4->( dbSeek(xFilial("SF4") + aCols[n, _nPosTES]) )

	//Verifico se o TES controle estoque, se o CFOP exige custo diferenciado e o custo Gama esta zerado
	if SF4->F4_ESTOQUE == "S" .and. AllTrim(aCols[n, _nPosCF]) $ _cCFOPcusto .and. Empty(aCols[n, _nPosCUSGAMA])

		aCols[n, _nPosCUSGAMA] := Round(C_FindCusto(aCols[n, _nPosCOD]) * aCols[n, _nPosQUANT], nDecimal)
		
		//apresento mensagem, se o custo retornar zero
		if Empty(aCols[n, _nPosCUSGAMA])
			_lRet := .F.
			if !IsBlind()	//!l103Auto
				Help(" ", 1, "ATENﾇﾃO",, "O CFOP, utilizado para nesta opera鈬o, obriga que o campo CUSTO GAMA seja preenchido. Emita um kardex do produto para identificar o custo que ser? informado ou contate o respons疱el pela 疵ea para mais esclarecimentos." + cEol + cEol + "(Espec?fico Gama Italy)," + cEol + "ponto de entrada MT100LOK," + cEol + "par穃etro BR_CFOPCUS.", 1)
			else
				Conout("MT100LOK - O CFOP, utilizado para nesta opera鈬o, obriga que o campo CUSTO GAMA seja preenchido. (MT100LOK), par穃etro BR_CFOPCUS")
			endif
		endif
		
	endif
	
endif
		
RestArea(_aAreaSF4)
RestArea(_aArea)
Return(_lRet)

	/*/
	覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	@function		C_FINDCUSTO                                                  /@
	@type			Static function                                              /@
	@date			06/05/2013                                                   /@
	@description	P/ notas, cujo CFOP esteja cadastrado no parametro BR_CFOPCUS,
					o valor de custo devera ser o considerado o medio e nao o 
					valor da nota.
					As situacoes previstas serao para casos de notas de assist. 
					tecnica pois o valor da nota de entrada normalmente ﾉ um valor
					alto, o que acaba distorcendo o custo medio do produto.
					1o) Verifico o custo medio do ultimo fechamento do estoque;
					2o) Caso nao encontre ou seja zero, verifico o custo utilizado
						 na NFS anterior ao ultimo fechamento;
					3o) Caso nao encontre ou seja zero, busco o custo medio atual
					    vigente.                                                 /@
	@author			Adalberto Moreno Batista                                     /@
	@use			Espec?fico Brasitech                                         /@
	覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	/*/
	Static Function C_FindCusto(cProd)
	Local nRet 		:= 0
	Local aArea		:= GetArea()
	Local aAreaSB2	:= SB2->(GetArea())
	Local nDecimal	:= TamSX3("B2_CM1")[2]
	Local cQuery
	Local cDtLimite	:= dTOs(dDataBase)
	
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Fecha area de trabalho TRBa
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	if Select("TRBa") > 0
		TRBa->(dbCloseArea())
	endif
	
	
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// 1o) Verifico o custo medio do ultimo fechamento do estoque
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	cQuery 	:= 	"SELECT TOP 1 SUM(SB9.B9_VINI1) B9_VINI1, SUM(SB9.B9_QINI) B9_QINI, SB9.B9_DATA " +;
				"FROM " + RetSQLName("SB9") + " SB9 " +;
				"WHERE SB9.B9_FILIAL = '" + xFilial("SB9") + "' " +;
						"AND SB9.B9_COD = '" + cProd + "' " +;
						"AND SB9.D_E_L_E_T_ <> '*' " +;
				"GROUP BY SB9.B9_DATA " +;
				"ORDER BY SB9.B9_DATA DESC"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRBa", .F., .T.)
	
	TRBa->(dbGoTop())
	if TRBa->(!eof())
		nRet		:= Round(TRBa->B9_VINI1 / TRBa->B9_QINI, nDecimal)
		cDtLimite	:= TRBa->B9_DATA
	endif
	
	if Select("TRBa") > 0
		TRBa->(dbCloseArea())
	endif
	
	
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	//ｳ 2o) Caso nao encontre ou seja zero, verifico o custo utilizado na
	//      NFS anterior ao ultimo fechamento
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	if nRet == 0
	
		cQuery 	:= 	"SELECT TOP 1 SD2.D2_CUSTO1, SD2.D2_QUANT, SD2.D2_EMISSAO " +;
					"FROM " + RetSQLName("SD2") + " SD2, " + RetSQLName("SF4") +  " SF4 " +;
					"WHERE SD2.D2_FILIAL = '" + xFilial("SD2") + "' " +;
							"AND SD2.D2_COD = '" + cProd + "' " +;
			 				"AND SD2.D2_EMISSAO <= '" + cDtLimite + "' " +;
							"AND SD2.D_E_L_E_T_ <> '*' " +;
							"AND SF4.F4_FILIAL = '" + xFilial("SF4") + "' " +;
							"AND SD2.D2_TES = SF4.F4_CODIGO " +;
							"AND SF4.F4_ESTOQUE = 'S' " +;
							"AND SF4.F4_PODER3 = 'N' " +;
							"AND SF4.D_E_L_E_T_ <> '*' " +;
					"ORDER BY SD2.D2_EMISSAO DESC"
	
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRBa", .F., .T.)
	
		TRBa->(dbGoTop())
		if TRBa->(!eof())
			nRet := Round(TRBa->D2_CUSTO1 / TRBa->D2_QUANT, nDecimal)
		endif
	endif
	
	if Select("TRBa") > 0
		TRBa->(dbCloseArea())
	endif
	
	
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// 3o) Caso nao encontre ou seja zero, busco o custo medio atual 
	//     vigente
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	if nRet == 0
		SB2->( dbSetOrder(1) )
		if SB2->( dbSeek( xFilial("SB2") + cProd ) )
			nRet := SB2->B2_CM1		//campo com o custo medio unitario
		endif
	endif
	
	RestArea(aAreaSB2)
	RestArea(aArea)
	Return(nRet)


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		D_MT100LOK                                                   /@
@type			Static function                                              /@
@date			29/07/2013                                                   /@
@description	Preenche automaticamente o codigo da classificacao fiscal da 
				operacao para os itens nao excluidos
				Em 23/07/13 inclui as funcoes MaFisLoad e MaFisLF            /@
@author			Adalberto Moreno Batista                                     /@
@use			Espec?fico Brasitech                                         /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function D_MT100LOK()
Local nPosCOD		:= aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "D1_COD"})
Local nPosTES		:= aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "D1_TES"})
Local nPosCLASFIS	:= aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "D1_CLASFIS"})
Local aArea			:= GetArea()
Local aAreaSB1		:= SB1->(GetArea())
Local aAreaSF4		:= SF4->(GetArea())

SB1->(dbSetOrder(1))
SB1->(dbSeek(xFilial("SB1") + aCols[n,nPosCOD]))
SF4->(dbSetOrder(1))
SF4->(dbSeek(xFilial("SF4") + aCols[n,nPosTES]))

aCols[n,nPosCLASFIS] := SB1->B1_ORIGEM + SF4->F4_SITTRIB
MaFisRef("IT_CLASFIS","MT100",SB1->B1_ORIGEM + SF4->F4_SITTRIB)

RestArea(aAreaSB1)
RestArea(aAreaSF4)
RestArea(aArea)

Return()

/* ####################################################################### *\
|| #    FORﾇA A TES INFORMADA NO IMPORTADOR, PARA NﾃO SER SUBSTITUﾍDA    # ||
|| #          PELA INFORMADA NO PEDIDO DE COMPRA OU NO PRODUTO           # ||
\* ####################################################################### */

Static Function E_MT100LOK()
U_GTPE004()
Return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		F_MT100LOK                                                   /@
@type			Static function                                              /@
@date			15/10/2018                                                   /@
@description	Valida linha da nota, quando houver valores de INSS, em raz縊
				da integra鈬o com o TAF para o REINF.
				Quando h? INSS, s縊 realizadas as seguintes verifica鋏es:
				* Produto deve ter c?digo de ISS
				* Codigo do ISS deve estar configurado na tabela 60, estar
				  configurado na CDN com c?digo LST e tipo de servi輟
				* Os campos de aliquota e base do INSS devem estar preenchidos
				* O TES deve gerar livro ISS                                 /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Op鈬o Um Consultoria                                         /@
@use			Espec?fico Brasitech                                         /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function F_MT100LOK()
Local lRet			:= .T.
Local nPosCOD		:= aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "D1_COD"})
Local nPosTES		:= aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "D1_TES"})
Local nPosVLINSS	:= aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "D1_VALINS"})
Local nPosBSINSS	:= aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "D1_BASEINS"})
Local nPosALINSS	:= aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "D1_ALIQINS"})
Local aArea			:= GetArea()
Local aAreaSB1		:= SB1->(GetArea())
Local aAreaSF4		:= SF4->(GetArea())
Local aAreaCDN		:= CDN->(GetArea())
Local cEol			:= chr(13) + chr(10)
Local lExecuta		:= GetMV("BR_VLDINSS", .F., .T.)
Local cKeyUsers	:= Upper(GetMV("BR_KEYUSER", .F., "Administrador"))
Local cMsg

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Verifico se esta valida鈬o deve ser executada e se possui valor do INSS 
// preenchido
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if lExecuta .and. aCols[n,nPosVLINSS] > 0

	SB1->(dbSetOrder(1))		//B1_FILIAL, B1_COD
	SF4->(dbSetOrder(1))		//F4_FILIAL, F4_CODIGO
	CDN->(dbSetOrder(1))		//CDN_FILIAL, CDN_CODISS, CDN_PROD

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Valido data de emiss縊 x data de digita鈬o e se o fornecedor ret駑 INSS
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	if Left(dTOs(dDataBase),6) > Left(dTOs(dDEmissao),6) .and. !Upper(cUserName) $ cKeyUsers
	
		lRet := .F.
		cMsg := "Data de digita鈬o da nota fiscal fora da data do fechamento. Esta nota poder? ser incluida somente por pessoas autorizadas no par穃etro BR_KEYUSER. Comunique o departamento fiscal sobre esta ocorr麩cia." + cEol + cEol + "(Espec?fico Gama Italy - P.E. MT100LOK)"

	elseif SA2->A2_RECINSS != "S"
		
		lRet := .F.
		cMsg := "Corrija o cadastro de fornecedor para calcular INSS, campo Calc.INSS pasta Fiscais." + cEol + cEol + "(Espec?fico Gama Italy)"

	else

		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		// Valido informa鋏es pertinentes ao produto
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		if SB1->(dbSeek(xFilial("SB1") + aCols[n,nPosCOD]))

			if SB1->B1_INSS != "S"
	
				lRet := .F.
				cMsg := "Corrija o cadastro de produto para calcular INSS, campo Calcula INSS pasta Impostos." + cEol + cEol + "(Espec?fico Gama Italy)"
						
			elseif Empty(SB1->B1_CODISS) .or. SX5->(!dbSeek(xFilial("SX5") + "60" + SB1->B1_CODISS))
	
				lRet := .F.
				cMsg := "O c?digo de ISS vinculado ao produto n縊 ? v疝ido (tabela 60) ou n縊 foi preenchido. Corrija-o ou escolha outro produto." + cEol + cEol + "(Espec?fico Gama Italy)"
	
	
			elseif aCols[n,nPosALINSS] == 0 .or. aCols[n,nPosBSINSS] == 0
			
				lRet := .F.
				cMsg := "Preencha a al?quota e/ou base de c疝culo do INSS." + cEol + cEol + "(Espec?fico Gama Italy)"
			
			elseif aCols[n,nPosALINSS] != 11
							
				lRet := .F.
				cMsg := "A al?quota do INSS ? diferente de 11%." + cEol + cEol + "(Espec?fico Gama Italy)"
								
			elseif Round(aCols[n,nPosBSINSS] * (aCols[n,nPosALINSS] / 100), 2) != aCols[n,nPosVLINSS]
								
				lRet := .F.
				cMsg := "A base do INSS multiplicado pela al?quota, n縊 bate com o valor informado do INSS." + cEol + cEol + "(Espec?fico Gama Italy)"

			else
			
				if CDN->(dbSeek(xFilial("CDN") + SB1->B1_CODISS + aCols[n,nPosCOD])) .or.;
					CDN->(dbSeek(xFilial("CDN") + SB1->B1_CODISS))
						
					if Empty(CDN->CDN_CODLST) .or. Empty(CDN->CDN_TPSERV)
	
						lRet := .F.
						cMsg := "A configura鈬o do c?digo de servi輟 est? incompleta. Verifique o c?dito LST e o tipo de servi輟 na rela鈬o de c?digos de servi輟." + cEol + cEol + "(Espec?fico Gama Italy)"
	
					else

						//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
						// Valido informa鋏es pertinentes ao TES
						//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
						if SF4->(dbSeek(xFilial("SF4") + aCols[n,nPosTES]))
					
							if SF4->F4_LFICM != "N" .or. SF4->F4_LFIPI != "N" .or. SF4->F4_LFISS == "N"
				
								lRet := .F.
								cMsg := "O TES utilizado n縊 deve gerar livro para o ICMS e IPI e para o livro do ISS deve estar configurado para tributado, isentou ou outros." + cEol + cEol + "(Espec?fico Gama Italy)"
									
							endif
									
						else
							
							lRet := .F.
							cMsg := "TES n縊 localizado. Utilize um TES v疝ido." + cEol + cEol + "(Espec?fico Gama Italy)"
				
						endif

					endif
												
				else
	
					lRet := .F.
					cMsg := "N縊 foi localizado a o c?digo de ISS vinculado a rela鈬o de c?digos de servi輟." + cEol + cEol + "(Espec?fico Gama Italy)"
						
				endif

			endif
			
		else
		
			lRet := .F.
			cMsg := "Produto n縊 localizado. Utilize um produto v疝ido." + cEol + cEol + "(Espec?fico Gama Italy)"

		endif		
			
	endif
		
	RestArea(aAreaSB1)
	RestArea(aAreaSF4)
	RestArea(aAreaCDN)
	RestArea(aArea)

endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Caso tenha encontrado alguma inconsistencia, apresenta mensagem com help ou,
// se executado por msexecauto, no console.log
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if !lRet
	if !IsBlind()	//!l103Auto
		Help("", 1, "ATENﾇﾃO",, cMsg, 1)
	else
		ConOut("MT100LOK - " + cMsg)
	endif
endif

Return(lRet)
