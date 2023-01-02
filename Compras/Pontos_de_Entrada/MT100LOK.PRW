#include "rwmake.ch"
#include "protheus.ch"

/*
�������������������������������������������������������������������
@function		MT100LOK                                         /@
@type			Ponto de entrada                                 /@
@date			10/12/2010                                       /@
@description	Valida linha de uma nota fiscal de entrada
				Retorna .T. ou .F.                               /@
@author			                                                 /@
@use			Especifico Brasitech                             /@
�������������������������������������������������������������������
*/
User Function MT100LOK()

Local _nPosConta	:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "D1_CONTA"})
Local _nPosCC		:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "D1_CC"})
Local _lRet			:= .T.

//if Type("l103Auto") != "L"
//	l103Auto := .F.
//endif

//�������������������������������������������������������������������
// Analisa se o CFOP esta correto em relacao a origem e destino,
// inicio com 1, 2 ou 3. Incluido para validacao de falha no padrao.
// Por: SI8401 - Adalberto Moreno Batista em 14/03/11
//�������������������������������������������������������������������
_lRet := B_MT100LOK()


//�������������������������������������������������������������������
// Identifica se eh uma nota de importacao e obriga a informar a 
// adicao, sequencia da adicao e fabricantes.
// Por: SI8401 - Adalberto Moreno Batista em 10/12/10
//�������������������������������������������������������������������
/*
Retirada a validacao em 31/10/11 em razao da TOTVS ter incluido as referidas informacoes
no padrao do Protheus. Estas informacoes deverao ser cadastradas na tabela CD5
if cFormul = 'S' .and. cTipo $ 'NCIP'

	if SA2->A2_EST = 'EX' .and. SD1->( FieldPos( "D1_X_ADIC" ) ) > 0

		_lRet := A_MT100LOK()

	endif

endif
*/

//�������������������������������������������������������������������
// Verifica se a conta contabil faz parte do grupo de Despesas, o 
// qual inicia pelo digito 4 e valida se o campo centro de custo esta
// digitado.
// Por: Luiz Fernando C Nogueira em 27/05/11
//�������������������������������������������������������������������
// verificando se a linha nao esta excluida
if !aCols[N,Len(aHeader)+1]
	
	If Funname() == "MATA103" .and. !IsBlind()
		if	(SUBSTR(aCols[N,_nPosConta],1,1) == '4') .AND. Empty(AllTrim(aCols[N,_nPosCC]))
			_lRet := .F.
			MsgBox("Conta cont�bil faz parte do grupo de Despesas. Portanto � obrigat�rio preencher o centro de custo.", "ATEN��O... (MT100LOK)", "ERRO")
		endif
	endif
endif
	

//�������������������������������������������������������������������
// Verifica se o custo especifico GAMA foi informado para situacoes 
// onde o CFOP da operacao esteja cadastrado no parametro especifico
// BR_CFOPCUS. 
// Por: Adalberto Moreno Batista em 08/04/13
//�������������������������������������������������������������������
if !aCols[N,Len(aHeader)+1] .and. _lRet		//verifica se eh uma linha nao excluida

	if SD1->( FieldPos( "D1_CUSGAMA" ) ) > 0
	
		_lRet := C_MT100LOK()
		
	endif

endif

//�������������������������������������������������������������������
// Preenche automaticamente o codigo da classificacao fiscal da 
// operacao para os itens nao excluidos
// Por: Adalberto Moreno Batista em 25/06/13
// Em 23/07/13 inclui as funcoes MaFisLoad e MaFisLF
//�������������������������������������������������������������������
if !aCols[n, Len(aHeader) + 1]
	D_MT100LOK()
endif

// Function utilizada pelo importador "Conexao NFe"
E_MT100LOK()


//�������������������������������������������������������������������
// Se nota de servico e possuir INSS, valida se cadastro de produtos
// est� adequado. 
// Motivo: integra��o com o TAF para o REINF
// Por: Adalberto Moreno Batista em 15/10/18
//�������������������������������������������������������������������
if !aCols[n, Len(aHeader) + 1] .and. _lRet
	_lRet := F_MT100LOK()
endif

Return(_lRet)


/*/
�������������������������������������������������������������������������������
@function		A_MT100LOK                                                   /@
@type			Static function                                              /@
@date			10/12/2010                                                   /@
@description	Identifica se � uma nota de importacao e obriga a informar a 
				adicao, sequencia da adicao e fabricantes.
				Retorna .T. ou .F.                                           /@
@author			Adalberto Moreno Batista                                     /@
@use			Espec�fico Brasitech                                         /@
�������������������������������������������������������������������������������
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
			MsgBox( "A 'adi��o da importa��o', 'sequ�ncia' e 'fabricante' s�o obrigat�rios para notas de importa��o e n�o foram preenchidos.", "ATEN��O... (MT100LOK)", "ERRO" )
		else
			Conout("MT100LOK - Aten��o: A 'adi��o da importa��o', 'sequ�ncia' e 'fabricante' s�o obrigat�rios para notas de importa��o e n�o foram preenchidos.")
		endif
		
	endif
		
endif

Return(_lRet)


/*/
�������������������������������������������������������������������������������
@function		B_MT100LOK                                                   /@
@type			Static function                                              /@
@date			14/03/2011                                                   /@
@description	Analisa se o CFOP esta correto em relacao a origem e destino,
				inicio com 1, 2 ou 3. Incluido para validacao de falha no 
				padrao.
				Retorna .T. ou .F.                                           /@
@author			Adalberto Moreno Batista                                     /@
@use			Espec�fico Brasitech                                         /@
�������������������������������������������������������������������������������
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
				MsgBox( "CFOP inv�lido considerando a UF do emitente e a UF do destinat�rio. O CFOP correto � " + _cCFOP, "ATEN��O... (MT100LOK)", "ERRO" )
			else
				Conout("MT100LOK - CFOP inv�lido considerando a UF do emitente e a UF do destinat�rio.")
			endif
			
		endif

	endif
	
	endif	
endif

Return(_lRet)


/*/
�������������������������������������������������������������������������������
@function		C_MT100LOK                                                   /@
@type			Static function                                              /@
@date			08/04/2013                                                   /@
@description	Verifica se o custo especifico GAMA foi informado para 
				situacoes onde o CFOP da operacao esteja cadastrado no 
				parametro especifico BR_CFOPCUS.
				Retorna .T. ou .F.                                           /@
@author			Adalberto Moreno Batista                                     /@
@use			Espec�fico Brasitech                                         /@
�������������������������������������������������������������������������������
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
				Help(" ", 1, "ATEN��O",, "O CFOP, utilizado para nesta opera��o, obriga que o campo CUSTO GAMA seja preenchido. Emita um kardex do produto para identificar o custo que ser� informado ou contate o respons�vel pela �rea para mais esclarecimentos." + cEol + cEol + "(Espec�fico Gama Italy)," + cEol + "ponto de entrada MT100LOK," + cEol + "par�metro BR_CFOPCUS.", 1)
			else
				Conout("MT100LOK - O CFOP, utilizado para nesta opera��o, obriga que o campo CUSTO GAMA seja preenchido. (MT100LOK), par�metro BR_CFOPCUS")
			endif
		endif
		
	endif
	
endif
		
RestArea(_aAreaSF4)
RestArea(_aArea)
Return(_lRet)

	/*/
	�������������������������������������������������������������������������������
	@function		C_FINDCUSTO                                                  /@
	@type			Static function                                              /@
	@date			06/05/2013                                                   /@
	@description	P/ notas, cujo CFOP esteja cadastrado no parametro BR_CFOPCUS,
					o valor de custo devera ser o considerado o medio e nao o 
					valor da nota.
					As situacoes previstas serao para casos de notas de assist. 
					tecnica pois o valor da nota de entrada normalmente � um valor
					alto, o que acaba distorcendo o custo medio do produto.
					1o) Verifico o custo medio do ultimo fechamento do estoque;
					2o) Caso nao encontre ou seja zero, verifico o custo utilizado
						 na NFS anterior ao ultimo fechamento;
					3o) Caso nao encontre ou seja zero, busco o custo medio atual
					    vigente.                                                 /@
	@author			Adalberto Moreno Batista                                     /@
	@use			Espec�fico Brasitech                                         /@
	�������������������������������������������������������������������������������
	/*/
	Static Function C_FindCusto(cProd)
	Local nRet 		:= 0
	Local aArea		:= GetArea()
	Local aAreaSB2	:= SB2->(GetArea())
	Local nDecimal	:= TamSX3("B2_CM1")[2]
	Local cQuery
	Local cDtLimite	:= dTOs(dDataBase)
	
	//�������������������������������������������������������������������
	// Fecha area de trabalho TRBa
	//�������������������������������������������������������������������
	if Select("TRBa") > 0
		TRBa->(dbCloseArea())
	endif
	
	
	//�������������������������������������������������������������������
	// 1o) Verifico o custo medio do ultimo fechamento do estoque
	//�������������������������������������������������������������������
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
	
	
	//�������������������������������������������������������������������
	//� 2o) Caso nao encontre ou seja zero, verifico o custo utilizado na
	//      NFS anterior ao ultimo fechamento
	//�������������������������������������������������������������������
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
	
	
	//�������������������������������������������������������������������
	// 3o) Caso nao encontre ou seja zero, busco o custo medio atual 
	//     vigente
	//�������������������������������������������������������������������
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
�������������������������������������������������������������������������������
@function		D_MT100LOK                                                   /@
@type			Static function                                              /@
@date			29/07/2013                                                   /@
@description	Preenche automaticamente o codigo da classificacao fiscal da 
				operacao para os itens nao excluidos
				Em 23/07/13 inclui as funcoes MaFisLoad e MaFisLF            /@
@author			Adalberto Moreno Batista                                     /@
@use			Espec�fico Brasitech                                         /@
�������������������������������������������������������������������������������
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
|| #    FOR�A A TES INFORMADA NO IMPORTADOR, PARA N�O SER SUBSTITU�DA    # ||
|| #          PELA INFORMADA NO PEDIDO DE COMPRA OU NO PRODUTO           # ||
\* ####################################################################### */

Static Function E_MT100LOK()
U_GTPE004()
Return()


/*/
�������������������������������������������������������������������������������
@function		F_MT100LOK                                                   /@
@type			Static function                                              /@
@date			15/10/2018                                                   /@
@description	Valida linha da nota, quando houver valores de INSS, em raz�o
				da integra��o com o TAF para o REINF.
				Quando h� INSS, s�o realizadas as seguintes verifica��es:
				* Produto deve ter c�digo de ISS
				* Codigo do ISS deve estar configurado na tabela 60, estar
				  configurado na CDN com c�digo LST e tipo de servi�o
				* Os campos de aliquota e base do INSS devem estar preenchidos
				* O TES deve gerar livro ISS                                 /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Op��o Um Consultoria                                         /@
@use			Espec�fico Brasitech                                         /@
�������������������������������������������������������������������������������
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

//�������������������������������������������������������������������������������
// Verifico se esta valida��o deve ser executada e se possui valor do INSS 
// preenchido
//�������������������������������������������������������������������������������
if lExecuta .and. aCols[n,nPosVLINSS] > 0

	SB1->(dbSetOrder(1))		//B1_FILIAL, B1_COD
	SF4->(dbSetOrder(1))		//F4_FILIAL, F4_CODIGO
	CDN->(dbSetOrder(1))		//CDN_FILIAL, CDN_CODISS, CDN_PROD

	//�������������������������������������������������������������������������������
	// Valido data de emiss�o x data de digita��o e se o fornecedor ret�m INSS
	//�������������������������������������������������������������������������������
	if Left(dTOs(dDataBase),6) > Left(dTOs(dDEmissao),6) .and. !Upper(cUserName) $ cKeyUsers
	
		lRet := .F.
		cMsg := "Data de digita��o da nota fiscal fora da data do fechamento. Esta nota poder� ser incluida somente por pessoas autorizadas no par�metro BR_KEYUSER. Comunique o departamento fiscal sobre esta ocorr�ncia." + cEol + cEol + "(Espec�fico Gama Italy - P.E. MT100LOK)"

	elseif SA2->A2_RECINSS != "S"
		
		lRet := .F.
		cMsg := "Corrija o cadastro de fornecedor para calcular INSS, campo Calc.INSS pasta Fiscais." + cEol + cEol + "(Espec�fico Gama Italy)"

	else

		//�������������������������������������������������������������������������������
		// Valido informa��es pertinentes ao produto
		//�������������������������������������������������������������������������������
		if SB1->(dbSeek(xFilial("SB1") + aCols[n,nPosCOD]))

			if SB1->B1_INSS != "S"
	
				lRet := .F.
				cMsg := "Corrija o cadastro de produto para calcular INSS, campo Calcula INSS pasta Impostos." + cEol + cEol + "(Espec�fico Gama Italy)"
						
			elseif Empty(SB1->B1_CODISS) .or. SX5->(!dbSeek(xFilial("SX5") + "60" + SB1->B1_CODISS))
	
				lRet := .F.
				cMsg := "O c�digo de ISS vinculado ao produto n�o � v�lido (tabela 60) ou n�o foi preenchido. Corrija-o ou escolha outro produto." + cEol + cEol + "(Espec�fico Gama Italy)"
	
	
			elseif aCols[n,nPosALINSS] == 0 .or. aCols[n,nPosBSINSS] == 0
			
				lRet := .F.
				cMsg := "Preencha a al�quota e/ou base de c�lculo do INSS." + cEol + cEol + "(Espec�fico Gama Italy)"
			
			elseif aCols[n,nPosALINSS] != 11
							
				lRet := .F.
				cMsg := "A al�quota do INSS � diferente de 11%." + cEol + cEol + "(Espec�fico Gama Italy)"
								
			elseif Round(aCols[n,nPosBSINSS] * (aCols[n,nPosALINSS] / 100), 2) != aCols[n,nPosVLINSS]
								
				lRet := .F.
				cMsg := "A base do INSS multiplicado pela al�quota, n�o bate com o valor informado do INSS." + cEol + cEol + "(Espec�fico Gama Italy)"

			else
			
				if CDN->(dbSeek(xFilial("CDN") + SB1->B1_CODISS + aCols[n,nPosCOD])) .or.;
					CDN->(dbSeek(xFilial("CDN") + SB1->B1_CODISS))
						
					if Empty(CDN->CDN_CODLST) .or. Empty(CDN->CDN_TPSERV)
	
						lRet := .F.
						cMsg := "A configura��o do c�digo de servi�o est� incompleta. Verifique o c�dito LST e o tipo de servi�o na rela��o de c�digos de servi�o." + cEol + cEol + "(Espec�fico Gama Italy)"
	
					else

						//�������������������������������������������������������������������������������
						// Valido informa��es pertinentes ao TES
						//�������������������������������������������������������������������������������
						if SF4->(dbSeek(xFilial("SF4") + aCols[n,nPosTES]))
					
							if SF4->F4_LFICM != "N" .or. SF4->F4_LFIPI != "N" .or. SF4->F4_LFISS == "N"
				
								lRet := .F.
								cMsg := "O TES utilizado n�o deve gerar livro para o ICMS e IPI e para o livro do ISS deve estar configurado para tributado, isentou ou outros." + cEol + cEol + "(Espec�fico Gama Italy)"
									
							endif
									
						else
							
							lRet := .F.
							cMsg := "TES n�o localizado. Utilize um TES v�lido." + cEol + cEol + "(Espec�fico Gama Italy)"
				
						endif

					endif
												
				else
	
					lRet := .F.
					cMsg := "N�o foi localizado a o c�digo de ISS vinculado a rela��o de c�digos de servi�o." + cEol + cEol + "(Espec�fico Gama Italy)"
						
				endif

			endif
			
		else
		
			lRet := .F.
			cMsg := "Produto n�o localizado. Utilize um produto v�lido." + cEol + cEol + "(Espec�fico Gama Italy)"

		endif		
			
	endif
		
	RestArea(aAreaSB1)
	RestArea(aAreaSF4)
	RestArea(aAreaCDN)
	RestArea(aArea)

endif

//�������������������������������������������������������������������������������
// Caso tenha encontrado alguma inconsistencia, apresenta mensagem com help ou,
// se executado por msexecauto, no console.log
//�������������������������������������������������������������������������������
if !lRet
	if !IsBlind()	//!l103Auto
		Help("", 1, "ATEN��O",, cMsg, 1)
	else
		ConOut("MT100LOK - " + cMsg)
	endif
endif

Return(lRet)