#include "rwmake.ch"
#include "protheus.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		SF1100I                                                      /@
@date			24/08/2009                                                   /@
@type			Ponto de entrada
@description	Ponto de entrada acionado apos a gravacao da NFE             /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um                                                     /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function SF1100I()
Local aArea		:= GetArea()
Local lGAMANFE	:= (!AllTrim(FunName()) $ "U_BRAJOB19 # U_BRAMNT01 # U_JOB15DESP # MATA920")

if lGAMANFE

	//———————————————————————————————————————————————————————————————————————————————
	// Inclusão de PV para a geração de notas fiscais de remessa simbólica de 
	// produtos devolvidos para o depósito, a partir da nota fiscal de entrada de 
	// devolução (D) ou troca (N)
	//                                                                                
	// Por: SI8401 - Adalberto Moreno Batista em 06/10/10                             
	//———————————————————————————————————————————————————————————————————————————————
	/*if SM0->M0_CODIGO = "01" .AND. SM0->M0_CODFIL = "03"
		if FunName() = "MATA103" .and. SF1->F1_TIPO $ "NDB"
		
			if MsgBox( "Deseja gerar pré-nota de remessa simbólica (pedido de venda) à filial 05?", "Atenção", "YESNO" )
		
				A_SF1100I()
		
			endif
		
		endif
	endif*/
	//fim
	
	
	//———————————————————————————————————————————————————————————————————————————————
	// Quando formulario proprio, informa mensagens adicionais na NFe e dados 
	// referentes a nota de importação, quando a UF for EX       
	//                                                                  
	// Por: SI8401 Adalberto Moreno Batista em 11/12/10                 
	//———————————————————————————————————————————————————————————————————————————————
	if SF1->F1_FORMUL == 'S'
	
		B_SF1100I()
	
	endif
	
	//———————————————————————————————————————————————————————————————————————————————
	// Gravar informações sobre VPC a partir de indicações no pedido de vendas
	// por SI8401 Adalberto Moreno Batista em 07/01/12
	//———————————————————————————————————————————————————————————————————————————————
	if SF1->F1_TIPO == "D" .and. SC5->(FieldPos("C5_X_CTVPC")) > 0 .and. SC5->(FieldPos("C5_X_VPCAV")) > 0
	
		C_SF1100I()
	
	endif

endif    

//———————————————————————————————————————————————————————————————————————————————
// Grava marca de origem por pedido de compras nos titulos a pagar, quando for
// houver pedido de compras vinculado no documento de entrada
// por Adalberto Moreno Batista em 03/08/21
//———————————————————————————————————————————————————————————————————————————————
if !SF1->F1_TIPO $ "DB" .and. SE2->(FieldPos("E2_XORIGPC")) > 0 .and. !Empty(SF1->F1_DUPL)

	D_SF1100I()

endif

//———————————————————————————————————————————————————————————————————————————————
// Movimenta os arquivos vinculados do TEMP para a pasta definitiva
// por Adalberto Moreno Batista em 03/08/21
//———————————————————————————————————————————————————————————————————————————————
E_SF1100I()
	
RestArea(aArea)
Return
                         

/*/
———————————————————————————————————————————————————————————————————————————————
@function		A_SF1100I                                                    /@
@date			06/10/2010                                                   /@
@type			Static Function
@description	Inclusão de PV para a geração de notas fiscais de remessa 
				simbólica de produtos devolvidos para o depósito, a partir da
				nota fiscal de entrada de devolução (D) ou troca (N)Ponto de 
				entrada acionado apos a gravacao da NFE                      /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————

Static Function A_SF1100I()
Local _aAreaSA1	:= SA1->( GetArea() )
Local _aAreaSB1	:= SB1->( GetArea() )
Local _aAreaSE4	:= SE4->( GetArea() )
Local _aLinha, _cCliente, _cLoja, _cCond, nK, _aSC5, _aSC6, _cTes, _cItem
Local _cInfRem	:= GetMV("ES_REMESSA",.F.,"        ;  ;   ;   ;   ;   ")

Private lMsErroAuto	:= .F.

//———————————————————————————————————————————————————————————————————————————————
//Informacoes sobre a remessa. Parametro ES_REMESSA possui as informacoes:
// * Codigo do cliente (filial da Brasitech)                              
// * Codigo da loja                                                       
// * Codigo da condicao de pagamento                                      
// * codigo do tipo de saida para produtos nacionais                      
// * codigo do tipo de saida para produtos importados                     
// * codigo do tipo de saida para produtos nacionalizados                 
//
// Parametro ES_REMESSA                                                   
// Preencher os codigos de: cliente;loja;cond.pagto;TES nacionais, TES produtos 
// importados; TES produtos nacionalizados separados por ponto e virgula
//———————————————————————————————————————————————————————————————————————————————

_cInfRem	:= StrTran(_cInfRem,";",chr(13)+chr(10))

For nK := 1 to MLCount(_cInfRem)
	if nK = 1
		_cCliente 	:= 	PadR( AllTrim( StrTran( MemoLine( _cInfRem,,nK ), Chr(13) + Chr(10), "")) , Len(SA1->A1_COD) )

	elseif nK = 2
		_cLoja 		:= 	PadR( AllTrim( StrTran( MemoLine( _cInfRem,,nK ), Chr(13) + Chr(10), "")) , Len(SA1->A1_LOJA) )

	elseif nK = 3
		_cCond 		:= 	PadR( AllTrim( StrTran( MemoLine( _cInfRem,,nK ), Chr(13) + Chr(10), "")) ,3)

	elseif nK = 4
		_cTSNac		:= 	PadR( AllTrim( StrTran( MemoLine( _cInfRem,,nK ), Chr(13) + Chr(10), "")) ,3)

	elseif nK = 5
		_cTSImp		:= 	PadR( AllTrim( StrTran( MemoLine( _cInfRem,,nK ), Chr(13) + Chr(10), "")) ,3)

	elseif nK = 6             
		_cTSINa		:= 	PadR( AllTrim( StrTran( MemoLine( _cInfRem,,nK ), Chr(13) + Chr(10), "")) ,3)

	endif
next

//———————————————————————————————————————————————————————————————————————————————
// Ordenando as tabelas
//———————————————————————————————————————————————————————————————————————————————
SA1->( dbSetOrder(1) )
SB1->( dbSetOrder(1) )
SC5->( dbSetOrder(1) )
SC6->( dbSetOrder(1) )
SE4->( dbSetOrder(1) )

//———————————————————————————————————————————————————————————————————————————————
// Posicionando os registros
//———————————————————————————————————————————————————————————————————————————————
SA1->( dbSeek( xFilial("SA1") + _cCliente + _cLoja ) )
SE4->( dbSeek( xFilial("SE4") + _cCond ) )
SC5->( dbSeek( xFilial("SC5") ) )
SC6->( dbSeek( xFilial("SC6") ) )

//———————————————————————————————————————————————————————————————————————————————
// Montando o array para o pedido de venda
//———————————————————————————————————————————————————————————————————————————————
_aSC5 := {}
_aSC6 := {}
_cItem := "01"

aAdd(_aSC5, {'C5_FILIAL',	xFilial("SC5"),		NIL})
aAdd(_aSC5, {'C5_TIPO', 	'N', 				NIL})
aAdd(_aSC5, {'C5_ATVREC',	'A', 				NIL})
aAdd(_aSC5, {'C5_CLIENTE', 	_cCliente, 			NIL})
aAdd(_aSC5, {'C5_LOJACLI', 	_cLoja, 			NIL})
aAdd(_aSC5, {'C5_CONDPAG', 	_cCond, 			NIL})
aAdd(_aSC5, {'C5_X_DTPRE', 	dDataBase, 			NIL})
aAdd(_aSC5, {'C5_PRENF', 	'1', 				NIL})
aAdd(_aSC5, {'C5_CODFIL', 	'05', 				NIL})
aAdd(_aSC5, {'C5_CODEMP', 	'01', 				NIL})
aAdd(_aSC5, {'C5_XTIPONF', 	'N', 				NIL})

SD1->(dbSeek(xFilial("SD1") + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)))
do while SD1->( !eof() .and. D1_FILIAL = xFilial("SD1") .and. D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA = SF1->( F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA ) )
	
	_cTes 	:= "   "
	if SB1->( dbSeek( xFilial("SB1") + SD1->D1_COD ) )
        
		if SB1->B1_ORIGAMA = "03"	//campo especifico Brasitech - produto nacional
			_cTes := _cTSNac

		elseif SB1->B1_ORIGAMA = "01"	//campo especifico Brasitech - produto importado
			_cTes := _cTSImp
			
		elseif SB1->B1_ORIGAMA = "02"	//campo especifico Brasitech - produto nacionalizado
			_cTes := _cTSINa 
			
		elseif SB1->B1_ORIGAMA = "04"	//campo especifico Brasitech - produto importado
			_cTes := _cTSImp	
			
        endif

	endif

	_aLinha := {}
	aAdd( _aLinha, { 'C6_FILIAL', 	xFilial("SC6"), 	NIL } )
	aAdd( _aLinha, { 'C6_ITEM', 	_cItem,	 			NIL } )
	aAdd( _aLinha, { 'C6_PRODUTO', 	SD1->D1_COD, 		NIL } )
	aAdd( _aLinha, { 'C6_TES', 		_cTes, 				NIL } )
	aAdd( _aLinha, { 'C6_QTDVEN', 	SD1->D1_QUANT, 		NIL } )
	aAdd( _aLinha, { 'C6_QTDLIB', 	SD1->D1_QUANT, 		NIL } )
	aAdd( _aLinha, { 'C6_LOCAL', 	SD1->D1_LOCAL, 		NIL } )

	aAdd( _aSC6, _aLinha )
	_cItem	:= Soma1( _cItem )
	
	SD1->( dbSkip() )
	
enddo

//———————————————————————————————————————————————————————————————————————————————
// Chamada da rotina automatica
//———————————————————————————————————————————————————————————————————————————————
MsExecAuto( { |x, y, z| Mata410( x, y, z ) }, _aSC5, _aSC6, 3 )

//———————————————————————————————————————————————————————————————————————————————
// Verifica se houve algum erro
//———————————————————————————————————————————————————————————————————————————————
if lmsErroAuto

	if !IsBlind()
		MsgBox("Foram encontrados problemas na geraçao do pedido de remessa simbólica pois um ou mais campos obrigatórios não foram preenchidos. Visualize o log de erros e informe ao depto de TI.", "Atenção", "ERRO")
		MostraErro()
	else
		ConOut(" - Foram encontrados problemas na geraçao do pedido de remessa simbólica pois um ou mais campos obrigatórios não foram preenchidos. Visualize o log de erros e informe ao depto de TI.")
	endif

else

	if !IsBlind()
		MsgBox("Pedido de remessa simbólica número '" + SC5->C5_NUM + "' foi criado com sucesso.", "Informação", "INFO")
	else
		ConOut(" - Pedido de remessa simbólica número '" + SC5->C5_NUM + "' foi criado com sucesso.")
	endif

endif

SA1->(RestArea(_aAreaSA1))
SB1->(RestArea(_aAreaSB1))
SE4->(RestArea(_aAreaSE4))

Return()
/*/

/*/
———————————————————————————————————————————————————————————————————————————————
@function		B_SF1100I                                                    /@
@date			11/12/2010                                                   /@
@type			Static Function
@description	Quando formulario proprio, informa mensagens adicionais na NFe
				e dados referentes a nota de importação, quando a UF for EX  /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Consultoria                                         /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function B_SF1100I()
Local cObs1			:= Space(Len(SF1->F1_XMENSG1))
Local cObs2			:= Space(Len(SF1->F1_XMENSG2))
Local cObs3			:= Space(Len(SF1->F1_XMENSG3))
Local cObs4			:= Space(Len(SF1->F1_XMENSG4))
Local cObs5			:= Space(Len(SF1->F1_XMENSG5))
Local aColsPte		:= {}
Local nMax			:= 0
Local aColsBkp, aHeaderBKP, nK
Private aHeaderDI 	:= {}
Private aColsDI   	:= {}
Private oB_SF1100I, _oGetDI

//———————————————————————————————————————————————————————————————————————————————
// Salvando a posicao do aHeader e aCols para posterior restauracao
//———————————————————————————————————————————————————————————————————————————————
aColsBkp 	:= aCols
aHeaderBkp	:= aHeader

//———————————————————————————————————————————————————————————————————————————————
// Monta a tela para alimentar a observacao e os dados da importacao
//———————————————————————————————————————————————————————————————————————————————
@ 114,22 To 469,914 Dialog oB_SF1100I Title OemToAnsi( "Informacoes Complementares" )
@ 10,10 Say OemToAnsi( "Mensagem da NF:" ) Size 57,8  Pixel of oB_SF1100I
@ 07,60 Get cObs1 Size 260,10 Pixel of oB_SF1100I
@ 19,60 Get cObs2 Size 260,10 Pixel of oB_SF1100I
@ 31,60 Get cObs3 Size 260,10 Pixel of oB_SF1100I
@ 43,60 Get cObs4 Size 260,10 Pixel of oB_SF1100I
@ 55,60 Get cObs5 Size 260,10 Pixel of oB_SF1100I

if SF1->F1_EST == 'EX'

	//———————————————————————————————————————————————————————————————————————————————
	// Montando array aCols, com dados do CD5
	//———————————————————————————————————————————————————————————————————————————————
	SX3->(dbSetOrder(1))
	SX3->(dbSeek("CD5"))
	do while SX3->(!eof() .and. X3_ARQUIVO == "CD5")
		if Left(SX3->X3_CAMPO,10) == "CD5_ITEM" .or. (X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL .and. SX3->X3_CONTEXT != "V" .and. !Left(SX3->X3_CAMPO,10) $ "CD5_FILIAL/CD5_DOC   /CD5_SERIE /CD5_ESPEC /CD5_FORNEC/CD5_LOJA  ")
			SX3->(aAdd(aHeaderDI, {X3_TITULO, X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL,,, X3_TIPO,}))
		endif
	   SX3->(dbSkip())
	enddo
	 
	//———————————————————————————————————————————————————————————————————————————————
	// Iniciando os elementos do aCols de acordo com o tipo de campo
	//———————————————————————————————————————————————————————————————————————————————
	SD1->(dbSetOrder(1))
	SD1->(dbSeek(xFilial("SD1") + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)))
	do while SD1->(!eof() .and. D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA == xFilial("SD1") + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA))
		nMax++
		
		aColsPte := {}
		for nK := 1 to Len(aHeaderDI)
			if aHeaderDI[nK,2] == "CD5_ITEM  "
				aAdd(aColsPte, SD1->D1_ITEM)
			elseif aHeaderDI[nK,2] == "CD5_CODEXP"
				aAdd(aColsPte, SD1->(D1_FORNECE + D1_LOJA))
			elseif aHeaderDI[nK,2] == "CD5_VLRII "
				aAdd(aColsPte, SD1->D1_II)
			else
				aAdd(aColsPte, CriaVar(aHeaderDI[nK,2], .T.))
			endif
		next
		aAdd(aColsPte, .F.)
		aAdd(aColsDI, aColsPte)
	
		SD1->(dbSkip())
	enddo
	
	@ 70,10 To 140,425 Title OemToAnsi( "SPED NFe - Complemento de nota de importacao (DI)" )
	_oGetDI		:= MsNewGetDados():New(80, 15, 135, 420, 3,,,,,, nMax,,,, oB_SF1100I, aHeaderDI, aColsDI)
	
endif

@ 150,360 Button OemToAnsi("_Gravar Complemento") Size 60,16 Action B1_SF1100I({cObs1, cObs2, cObs3, cObs4, cObs5}, aColsBkp, aHeaderBkp) Pixel of oB_SF1100I

Activate Dialog oB_SF1100I Centered

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		B1_SF1100I                                                   /@
@date			11/12/2010                                                   /@
@type			Static Function
@description	Acionado pela static function B_, valida informações de
				complemento de importação                                    /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function B1_SF1100I(aObs, aColsBkp, aHeaderBkp)
Local _lGrava 	:= .T.
Local cMens		:= ""
Local aAreaSD1	:= SD1->(GetArea())
Local nX, nY, nPosITEM, nPosTPIMP, nPosNDI, nPosDTDI, nPosLOCDES, nPosUFDES,;
		nPosDTDES, nPosCODEXP,	nPosNADIC, nPosSQADIC, nPosCODFAB, nPosBCIMP,;
		nPosDSPAD, nPosVLRII, nPosINTERM, nPosVTRANS

if SF1->F1_EST == 'EX'
	aColsDI		:= _oGetDI:aCols
	aHeaderDI	:= _oGetDI:aHeader
else
	aColsDI		:= {}
	aHeaderDI	:= {}
endif

nPosITEM	:= aScan(aHeaderDI, {|x|, AllTrim(x[2]) == "CD5_ITEM"})
nPosTPIMP	:= aScan(aHeaderDI, {|x|, AllTrim(x[2]) == "CD5_TPIMP"})
nPosNDI		:= aScan(aHeaderDI, {|x|, AllTrim(x[2]) == "CD5_NDI"})
nPosDTDI	:= aScan(aHeaderDI, {|x|, AllTrim(x[2]) == "CD5_DTDI"})
nPosLOCDES	:= aScan(aHeaderDI, {|x|, AllTrim(x[2]) == "CD5_LOCDES"})
nPosUFDES	:= aScan(aHeaderDI, {|x|, AllTrim(x[2]) == "CD5_UFDES"})
nPosDTDES	:= aScan(aHeaderDI, {|x|, AllTrim(x[2]) == "CD5_DTDES"})
nPosCODEXP	:= aScan(aHeaderDI, {|x|, AllTrim(x[2]) == "CD5_CODEXP"})
nPosNADIC	:= aScan(aHeaderDI, {|x|, AllTrim(x[2]) == "CD5_NADIC"})
nPosSQADIC	:= aScan(aHeaderDI, {|x|, AllTrim(x[2]) == "CD5_SQADIC"})
nPosCODFAB	:= aScan(aHeaderDI, {|x|, AllTrim(x[2]) == "CD5_CODFAB"})
nPosBCIMP	:= aScan(aHeaderDI, {|x|, AllTrim(x[2]) == "CD5_BCIMP"})
nPosDSPAD	:= aScan(aHeaderDI, {|x|, AllTrim(x[2]) == "CD5_DSPAD"})
nPosVLRII	:= aScan(aHeaderDI, {|x|, AllTrim(x[2]) == "CD5_VLRII"})
nPosINTERM	:= aScan(aHeaderDI, {|x|, AllTrim(x[2]) == "CD5_INTERM"}) 
nPosVTRANS	:= aScan(aHeaderDI, {|x|, AllTrim(x[2]) == "CD5_VTRANS"}) 

//———————————————————————————————————————————————————————————————————————————————
// Valida as informacoes obrigatorias do aColsDI, caso seja nota de importacao
//———————————————————————————————————————————————————————————————————————————————
if Len(aColsDI) > 0

	for nX := 1 to Len(aColsDI)

		if aColsDI[nX, Len(aHeaderDI) + 1] 		//testando se o array esta apagado
			
			lGrava := .F.
			if !IsBlind()
				Help(" ", 1, "ATENÇÃO", , "O item complementar da importação não poderá ser excluído." + chr(13) + chr(10) + "Específico Brasitech", 1)
			else
				ConOut(" - O item complementar da importação não poderá ser excluído.")
			endif
			
		else

			if Empty(aColsDI[nX,nPosTPIMP]) .and. !"Tipo documento importação, " $ cMens		//CD5_TPIMP
				cMens += "Tipo documento importação, "
			endif

			if Empty(aColsDI[nX,nPosNDI]) .and. !"Nro. da DI/DA, " $ cMens							//CD5_NDI
				cMens += "Nro. da DI/DA, "
			endif

			if Empty(aColsDI[nX,nPosDTDI]) .and. !"Registro DI, " $ cMens							//CD5_DTDI
				cMens += "Registro DI, "
			endif

			if Empty(aColsDI[nX,nPosLOCDES]) .and. !"Descr.Local, " $ cMens						//CD5_LOCDES
				cMens += "Descr.Local, "
			endif

			if Empty(aColsDI[nX,nPosUFDES]) .and. !"UF do Desembar, " $ cMens	 					//CD5_UFDES
				cMens += "UF do Desembar, "
			endif

			if Empty(aColsDI[nX,nPosDTDES]) .and. !"Dt do Desembar, " $ cMens	  					//CD5_DTDES
				cMens += "Dt do Desembar, "
			endif

			if Empty(aColsDI[nX,nPosCODEXP]) .and. !"Exportador, " $ cMens							//CD5_CODEXP
				cMens += "Exportador, "
			endif

			if Empty(aColsDI[nX,nPosNADIC]) .and. !"Adição, " $ cMens								//CD5_NADIC
				cMens += "Adição, "
			endif

			if Empty(aColsDI[nX,nPosSQADIC]) .and. !"Sequencia da adição, " $ cMens	 			//CD5_SQADIC
				cMens += "Sequencia da Adição, "
			endif

			if Empty(aColsDI[nX,nPosCODFAB]) .and. !"Fabricante, " $ cMens							//CD5_CODFAB
				cMens += "Fabricante, "
			endif

			if Empty(aColsDI[nX,nPosBCIMP]) .and. !"Valor BC importação, " $ cMens	 			//CD5_BCIMP
				cMens += "Valor BC Importação, "
			endif

			if Empty(aColsDI[nX,nPosDSPAD]) .and. !"Valor desp. aduaneira, " $ cMens			//CD5_DSPAD
				cMens += "Valor Desp. Aduaneira, "
			endif

			if Empty(aColsDI[nX,nPosVLRII]) .and. !"Valor imposto de importação, " $ cMens	//CD5_VLRII
				cMens += "Valor Imposto de Importação, "
			endif

			if Empty(aColsDI[nX,nPosINTERM]) .and. !"Forma importação, " $ cMens	//CD5_VLRII
				cMens += "Forma importação, "
			endif

			if Empty(aColsDI[nX,nPosVTRANS]) .and. !"Via de transporte na DI, " $ cMens	//CD5_VLRII
				cMens += "Via de transporte na DI, "
			endif

		endif
		
	Next


	If !empty(cMens)
		cMens += "não foi(ram) informado(s)." + chr(13)
		cMens += "Inclusão das informações complementares não poderá ser confirmada."
		if !IsBlind()
			Help(" ", 1, "ATENÇÃO - ", , cMens + chr(13) + chr(10) + "(Específico Brasitech). ", 1)
		else
			ConOut(" " + cMens)
		endif
		_lGrava := .F.
	endif
  
endif


//———————————————————————————————————————————————————————————————————————————————
// Grava as informacoes da DI                                              
//———————————————————————————————————————————————————————————————————————————————
if _lGrava

	//———————————————————————————————————————————————————————————————————————————————
	// Grava a observacao no cabecalho da nota fiscal
	//———————————————————————————————————————————————————————————————————————————————
	SF1->(RecLock("SF1", .F.))
	SF1->F1_XMENSG1	:= aObs[1]
	SF1->F1_XMENSG2	:= aObs[2]
	SF1->F1_XMENSG3	:= aObs[3]
	SF1->F1_XMENSG4	:= aObs[4]
	SF1->F1_XMENSG5	:= aObs[5]
	SF1->(MsUnlock())

	if Len(aColsDI) > 0

		CD5->(dbSetOrder(4))		//CD5_FILIAL, CD5_DOC, CD5_SERIE, CD5_FORNEC, CD5_LOJA, CD5_ITEM

		For nX := 1 to Len(aColsDI)

			if CD5->(!dbSeek(xFilial("CD5") + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA) + aColsDI[nX,nPosItem]))

				CD5->(Reclock("CD5", .T.))
				CD5->CD5_FILIAL		:= xFilial("CD5")
				CD5->CD5_DOC		:= SF1->F1_DOC
				CD5->CD5_SERIE		:= SF1->F1_SERIE
				CD5->CD5_FORNEC		:= SF1->F1_FORNECE
				CD5->CD5_LOJA		:= SF1->F1_LOJA
				CD5->CD5_ITEM		:= aColsDI[nX,nPosItem]
				CD5->CD5_ESPEC		:= SF1->F1_ESPECIE

			else

				CD5->(Reclock("CD5", .F.))

			endif
				
			for nY := 1 to Len(aHeaderDI)
				if AllTrim(aHeaderDI[nY,2]) != "CD5_ITEM"
					CD5->(FieldPut(FieldPos(aHeaderDI[nY,2]), aColsDI[nX, nY]))
				endif
			next			

			CD5->(MsUnlock())
			
		Next

	endif

	//———————————————————————————————————————————————————————————————————————————————
	// Restaurando a posicao do aHeader e aCols
	//———————————————————————————————————————————————————————————————————————————————
	aCols		:= aColsBkp
	aHeader		:= aHeaderBkp

	Close(oB_SF1100I)
	
endif

RestArea(aAreaSD1)
Return(_lGrava)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		C_SF1100I                                                    /@
@date			07/01/2012                                                   /@
@type			Static Function
@description	Gravar informações sobre VPC a partir de indicações no pedido
				de vendas                                                    /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function C_SF1100I()
Local aArea			:= GetArea()
Local aAreaSC5		:= SC5->(GetArea())
Local aAreaSC6		:= SC6->(GetArea())
Local aAreaSD1		:= SD1->(GetArea())
Local aAreaSD2		:= SD2->(GetArea())
Local aAreaSF4		:= SF4->(GetArea())
Local aDevVenda		:= {}
Local aDevBonif		:= {}
Local lLoja			:= (SA1->A1_X_MDVPC == "L")
Local cVPCAvulsa	:= "AVU"		//troca de codigo do avulso de "000" para "AVU"
Local cVPCMarket	:= "MKT"
Local nPercVPCMkt
Local nK, nBase, nValor, lIPI

//———————————————————————————————————————————————————————————————————————————————
// aDev???[1] - Contrato
// aDev???[2] - Tipo do percentual VPC
// aDev???[3] - Valor da Credito de cálculo
// aDev???[4] - Valor do crédito VPC
// aDev???[5] - Usado em NCC/CTAPAG/PEDBONIF
//———————————————————————————————————————————————————————————————————————————————

SC5->(dbSetOrder(1))
SC6->(dbSetOrder(1))
SD1->(dbSetOrder(1))
SD2->(dbSetOrder(3))
SF4->(dbSetOrder(1))
SZI->(dbSetOrder(1))	//ZI_FILIAL+ZI_COD
SZJ->(dbSetOrder(1))	//ZJ_FILIAL+ZJ_CONTRAT+ZJ_CLIENTE+ZJ_LOJA
SZK->(dbSetOrder(2))

//———————————————————————————————————————————————————————————————————————————————
// Tratamento para consideracao de calculo de debitos quando da devolucao   
// de uma nota de saida (venda ou bonificacao)                                                    
// Por: Adalberto Moreno Batista em 22/07/13                                
//———————————————————————————————————————————————————————————————————————————————
SD1->(dbSeek(xFilial("SD1") + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)))
do while SD1->(!eof() .and. D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA == xFilial("SD1") + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA))
	
	//———————————————————————————————————————————————————————————————————————————————
	// Somente gero controle VPC quando a devolução não for uma troca, campo 
	// F4_X_TROCA <> S. Pesquiso o TES de entrada
	// Solicitado por Luiz Fernando em 31/03/14
	//———————————————————————————————————————————————————————————————————————————————
	SF4->(dbSeek(xFilial("SF4") + SD1->D1_TES))
	if SF4->F4_X_TROCA <> "S"
      
		if SD2->(dbSeek(xFilial("SD2") + SD1->(D1_NFORI + D1_SERIORI + D1_FORNECE + D1_LOJA + D1_COD + D1_ITEMORI)))

			nPercVPCMkt	:= U_GetVPCMkt_FT15(SD2->D2_EMISSAO)

			if SC5->(dbSeek(xFilial("SC5") + SD2->D2_PEDIDO))

				//———————————————————————————————————————————————————————————————————————————————
				// Posiciona o item de pedido de venda para identificar se foi um item bonificado
				// e o TES da saída para saber se gerou ou não duplicatas
				//———————————————————————————————————————————————————————————————————————————————
				SC6->(dbSeek(xFilial("SC6") + SD2->(D2_PEDIDO + D2_ITEMPV)))
				SF4->(dbSeek(xFilial("SF4") + SD2->D2_TES))
	
				//———————————————————————————————————————————————————————————————————————————————
				// Quando gera duplicata na devolucao, indica que é DEVOLUCAO DE VENDAS, portanto
				// devo gerar DEBITO
				//———————————————————————————————————————————————————————————————————————————————
				if SF4->F4_DUPLIC == "S"

					nBase 	:= SD1->(D1_TOTAL + D1_VALIPI)
					//———————————————————————————————————————————————————————————————————————————————
					// Percentuais avulsos
					// Credito de Cálculo: mercadoria + IPI, sem filial exclusiva
					//———————————————————————————————————————————————————————————————————————————————
					if SC5->C5_X_VPCAV > 0
						nValor		:= Round(nBase * (SC5->C5_X_VPCAV / 100), 2)
						nK 			:= aScan(aDevVenda, {|x| empty(x[1]) .and. x[2] == cVPCAvulsa .and. x[5] == "SSS"})
						if nK == 0
							aAdd(aDevVenda,{"",;
											cVPCAvulsa,;
											nBase,;
											nValor,;
											"SSS",;
											SC5->C5_X_VPCAV} )
						else
							aDevVenda[nK, 3] += nBase
							aDevVenda[nK, 4] += nValor
						endif
					endif
				
					//———————————————————————————————————————————————————————————————————————————————
					// Percentuais com contrato, buscar percentual de cálculo, tipos VPC e uso dos 
					// valores (NCC, Cta pagar e Pedidos bonificados) na tabela SZP
					// A incidencia de IPI na tabela SZJ
					//———————————————————————————————————————————————————————————————————————————————
					if !empty(SC5->C5_X_CTVPC)
						if SZJ->(dbSeek(xFilial("SZJ") + SC5->C5_X_CTVPC))
						
							SZP->(dbSeek(xFilial("SZP") + SC5->C5_X_CTVPC))
							do while SZP->(!eof() .and. ZP_FILIAL == xFilial("SZP") .and. ZP_CONTRAT == SC5->C5_X_CTVPC)
							
								if SF4->F4_DUPLIC == "S"	//considero uma devolução de venda, tenho que gerar um DEBITO
									nBase		:= SD1->D1_TOTAL + iif(SZJ->ZJ_IPI == "S", SD1->D1_VALIPI, 0)
									nValor		:= Round(nBase * (SZP->ZP_PERC / 100), 2)
									nK 			:=	aScan(aDevVenda, {|x| x[1] == SC5->C5_X_CTVPC .and. x[2] == SZP->ZP_TPVPC .and. x[5] == SZP->(ZP_USANCC + ZP_USAPAG + ZP_USAPED)})
									if nK == 0
										aAdd(aDevVenda,{SC5->C5_X_CTVPC,;
														SZP->ZP_TPVPC,;
														nBase,;
														nValor,;
														SZP->(ZP_USANCC + ZP_USAPAG + ZP_USAPED),;
														SZP->ZP_PERC } )
									else
										aDevVenda[nK, 3] += nBase
										aDevVenda[nK, 4] += nValor
									endif
		
								endif
								
								SZP->(dbSkip())
					        enddo
					        
						endif
	                endif

					//———————————————————————————————————————————————————————————————————————————————
					// Percentual para credito de VPC MKT (Marketing). Uso especifico para campanhas
					// de Marketing (mercadoria + IPI)
					// Gerado somente se houver VPC de contrato ou avulso
					//———————————————————————————————————————————————————————————————————————————————
					if nPercVPCMkt > 0 .and. Len(aDevVenda) > 0
						nValor	:= Round(nBase * (nPercVPCMkt / 100), 2)
						nK := aScan(aDevVenda, {|x| empty(x[1]) .and. x[2] == cVPCMarket .and. x[5] == "SSS"})
						if nK == 0
							aAdd(aDevVenda, {	"",;
												cVPCMarket,;
												nBase,;
												nValor,;
												"SSS",;
												nPercVPCMkt})
						else
							aDevVenda[nK, 3] += nBase
							aDevVenda[nK, 4] += nValor
						endif
						
					endif

				//———————————————————————————————————————————————————————————————————————————————
				// Quando NAO gera duplicata na devolucao, indica que é DEVOLUCAO DE BONIFICAÇÃO,
				// portanto devo gerar CREDITO para casos onde houve geracao de débitos na saida.
				// Credito de Cálculo: se houver contrato pesquiso incidencia do IPI na base,
				// caso contrário assumo que deve ser considerado o IPI. (sem filial exclusiva)
				// O crédito é gerado somente com o tipo AVU-AVULSO, com uso geral (SSS)
				//———————————————————————————————————————————————————————————————————————————————
				elseif SF4->F4_DUPLIC == "N" .and. (SC5->C5_X_VPC == "S" .or. SC6->C6_X_VPCIT == "S")
					lIPI := .T.
					if !empty(SC5->C5_X_CTVPC)
						if SZJ->(dbSeek(xFilial("SZJ") + SC5->C5_X_CTVPC))
							lIPI := (SZJ->ZJ_IPI == "S")
						endif
					endif
					nBase 	:= SD1->D1_TOTAL + iif(lIPI, SD1->D1_VALIPI, 0)
					nValor	:= SD1->D1_TOTAL + iif(lIPI, SD1->D1_VALIPI, 0)
					nK 		:= aScan(aDevBonif, {|x| empty(x[1]) .and. x[2] == cVPCAvulsa .and. x[5] == "SSS"})
					if nK == 0
						aAdd(aDevBonif,	{	SC5->C5_X_CTVPC,;
											cVPCAvulsa,;
											nBase,;
											nValor,;
											"SSS",;
											0} )
					else
						aDevBonif[nK, 3] += nBase
						aDevBonif[nK, 4] += nValor
					endif
					
				endif
	            
			endif
			
		endif

	endif
 
	SD1->(dbSkip())
      
enddo


//———————————————————————————————————————————————————————————————————————————————
// Gravação de débitos provenientes da devolução de vendas
//———————————————————————————————————————————————————————————————————————————————
if Len(aDevVenda) > 0

	for nK := 1 to Len(aDevVenda)
		SZI->(dbSeek(xFilial("SZI") + aDevVenda[nK,2]))
		cHistorico := 	"Debito Devolucao Venda, NF: " + SF1->(F1_DOC + "/" + AllTrim(F1_SERIE)) +;
						", TpVPC: " + aDevVenda[nK,2] + "-" + AllTrim(SZI->ZI_DESCR) +;
						iif(!empty(aDevVenda[nK,1]), ", Contrato: " + AllTrim(aDevVenda[nK,1]), "")

		//———————————————————————————————————————————————————————————————————————————————
		// Atualizando a tabela SZK - movimentos VPC
		// Função do fonte BFATA03.PRW
		// Parâmetros da função U_VPCGrava_FT03
		//	[1]- Tipo do movimento "CR" para crédito e "DB" para débito
		//	[2]- Código do cliente
		//	[3]- Loja do cliente, qdo o contrato exigir. Somente p/ situações com contrato VPC
		//	[4]- Codigo do contrato VPC
		//	[5]- Tipo do percentual VPC
		//	[6]- Valor da base de cálculo
		//	[7]- Valor do débito ou crédito do movimento
		//	[8]- Campo descritivo com o histórico do lançamento 
		//	[9]- Origem do lançamento
		//	[10]- Chave do registro que originou o lançamento
		//	[11]- Uso da VPC S/N para: NCC / CtaPag / Ped.Bonificados
		//	[12]- Data do movimento
		//	[13]- Percentual
		//	[14]- Número da solicitação do sistema WEB (tabela ZZV)
		//	[15]- Array {Número NF, Série NF}
		//———————————————————————————————————————————————————————————————————————————————
		U_VPCGrava_FT03(	"DB",;
							SF1->F1_FORNECE,;
							iif(lLoja, SF1->F1_LOJA, ""),;
							aDevVenda[nK,1],;
							aDevVenda[nK,2],;
							aDevVenda[nK,3],;
							aDevVenda[nK,4],;
							cHistorico,;
							"4",;
							SF1->(F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA),;
							aDevVenda[nK,5],;
							SF1->F1_DTDIGIT,;
							aDevVenda[nK,6],;
							,;
							{SF1->F1_DOC, SF1->F1_SERIE}		)

	next
	
endif

//———————————————————————————————————————————————————————————————————————————————
// Gravação de créditos provenientes da devolução de bonificação
//———————————————————————————————————————————————————————————————————————————————
if Len(aDevBonif) > 0

	for nK := 1 to Len(aDevbonif)
		SZI->(dbSeek(xFilial("SZI") + aDevBonif[nK,2]))
		cHistorico := 	"Credito Devolucao Bonific, NF: " + SF1->(F1_DOC + "/" + AllTrim(F1_SERIE)) +;
						", TpVPC: " + aDevBonif[nK,2] + "-" + AllTrim(SZI->ZI_DESCR) +;
						iif(!empty(aDevBonif[nK,1]), ", Contrato: " + AllTrim(aDevBonif[nK,1]), "")

		U_VPCGrava_FT03(	"CR",;
							SF1->F1_FORNECE,;
							iif(lLoja, SF1->F1_LOJA, ""),;
							aDevBonif[nK,1],;
							aDevBonif[nK,2],;
							aDevBonif[nK,3],;
							aDevBonif[nK,4],;
							cHistorico,;
							"4",;
							SF1->(F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA),;
							aDevBonif[nK,5],;
							SF1->F1_DTDIGIT,;
							aDevBonif[nK,6],;
							,;
							{SF1->F1_DOC, SF1->F1_SERIE}		)
	next
	
endif

RestArea(aAreaSC5)
RestArea(aAreaSC6)
RestArea(aAreaSD1)
RestArea(aAreaSD2)
RestArea(aAreaSF4)
RestArea(aArea)
Return()       


/*/
———————————————————————————————————————————————————————————————————————————————
@function		D_SF1100I                                                    /@
@date			03/08/2021                                                   /@
@type			Static Function
@description	Grava marca de origem por pedido de compras nos titulos a 
				pagar, quando for houver pedido de compras vinculado no 
				documento de entrada.                                        /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function D_SF1100I()
Local cMarca	:= ""
Local aArea		:= GetArea()
Local aAreaSD1	:= SD1->(GetArea())
Local aAreaSE2	:= SE2->(GetArea())

SC7->(dbSetOrder(1))	//C7_FILIAL, C7_NUM, C7_ITEM, C7_SEQUEN
SD1->(dbSetOrder(1))	//D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM
SE2->(dbSetOrder(6))	//E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO

if SE2->(dbSeek(xFilial("SE2") + SF1->(F1_FORNECE + F1_LOJA + F1_PREFIXO + F1_DOC)))

	// Localizando informação sobre pedido de compra
	if SD1->(dbSeek(xFilial("SD1") + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)))

		do while SD1->(!eof() .and. D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA == xFilial("SD1") + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA))
			if !Empty(SD1->D1_PEDIDO) .and. SC7->(dbSeek(xFilial("SC7") + SD1->D1_PEDIDO))
				cMarca	:= "Apr"
				Exit
			endif
			SD1->(dbSkip())
		enddo
	endif

	do while SE2->(!eof() .and. E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM == xFilial("SE2") + SF1->(F1_FORNECE + F1_LOJA + F1_PREFIXO + F1_DOC))
		SE2->(RecLock("SE2", .F.))
		SE2->E2_XORIGPC	:= cMarca
		SE2->(MsUnlock())
		SE2->(dbSkip())
	enddo
endif

RestArea(aAreaSD1)
RestArea(aAreaSE2)
RestArea(aArea)
Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		E_SF1100I                                                    /@
@date			03/08/2021                                                   /@
@type			Static Function
@description	Movimenta os arquivos vinculados do TEMP para a pasta 
				definitiva                                                   /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function E_SF1100I()
Local cDirAnexos	:= GetMV("BR_ANEXOPC")		// "\\MARROCOS\COTACOES"
Local cAno			:= StrZero(Year(SF1->F1_EMISSAO), 4)
Local cMes			:= StrZero(Month(SF1->F1_EMISSAO), 2)
Local cDirEmp		:= "\" + cEmpAnt + cFilAnt
Local cNumControle	:= AllTrim(SF1->F1_DOC) + "_" + AllTrim(SF1->F1_SERIE) + "_" + AllTrim(SF1->F1_FORNECE) + "_" + AllTrim(SF1->F1_LOJA)
Local cPathTemp		:= cDirAnexos + cDirEmp + "\NF\temp\"
Local cPathReal		:= cDirAnexos + cDirEmp + "\NF\" + cAno + "\mes_" + cMes + "\"
Local nX, aFiles

MakeDir(cDirAnexos)
MakeDir(cDirAnexos + cDirEmp)
MakeDir(cDirAnexos + cDirEmp + "\NF")
MakeDir(cDirAnexos + cDirEmp + "\NF\temp")
MakeDir(cDirAnexos + cDirEmp + "\NF\" + cAno)
MakeDir(cDirAnexos + cDirEmp + "\NF\" + cAno + "\mes_" + cMes)

//———————————————————————————————————————————————————————————————————————————————
// Ao final da inclusão do documento de entrada realizo as seguintes ações:
// 1º) Limpo os anexos remanescentes do diretorio REAL
// 2º) Copio os anexos do diretório TEMP para o diretorio REAL
// 3º) Limpo os anexos do diretório TEMP
//———————————————————————————————————————————————————————————————————————————————
aFiles		:= Directory( cPathReal + cFilAnt + "_" + AllTrim(cNumControle) + "_" + "*.*")
if Len(aFiles) > 0
	for nX := 1 to Len(aFiles)
		fErase(cPathReal + aFiles[nX,1])
	next
endif

aFiles		:= Directory( cPathTemp + cFilAnt + "_" + AllTrim(cNumControle) + "_" + "*.*")
if Len(aFiles) > 0
	for nX := 1 to Len(aFiles)
		__CopyFile(cPathTemp + aFiles[nX,1], cPathReal + aFiles[nX,1])
		fErase(cPathTemp + aFiles[nX,1])
	next
endif

Return()
