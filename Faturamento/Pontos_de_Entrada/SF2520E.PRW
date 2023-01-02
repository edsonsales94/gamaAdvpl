#Include "RwMake.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		SF2520E                                                       /@
@type			Ponto de entrada                                              /@
@date			12/12/2010                                                    /@
@description	Executado após a confirmação da exclusão da nota e antes da
				exclusão dos registros.                                      /@
@author			Adalberto Moreno Batista                                     /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function SF2520E()
Local cCliArm 	:= getmv("MV_XFOREDI")
Local cLojArm 	:= getmv("MV_XLOJEDI")

//———————————————————————————————————————————————————————————————————————————————
// Exclui informacoes sobre exportacoes na tabela CDL para o preenchimento da TAG
// referente a exportacoes na SPED NFe..
// por SI8401 Adalberto Moreno em 12/12/10
//———————————————————————————————————————————————————————————————————————————————
if SF2->F2_EST = "EX"
	A_SF2520E()
endif

//———————————————————————————————————————————————————————————————————————————————
// Grava data, hora e nome e id do usuario nas tabelas SF2 e SD2 com dados do 
// usuario que efetuou a exclusao da nota                               
// por Ronaldo Gomes em 28/11/11                                        
//———————————————————————————————————————————————————————————————————————————————
B_SF2520E()

//———————————————————————————————————————————————————————————————————————————————
// Exclui informacoes de VPC, caso existam
// por SI8401 Adalberto Moreno em 07/01/12
//———————————————————————————————————————————————————————————————————————————————
if SC5->(FieldPos("C5_X_CTVPC")) > 0 .and. SC5->(FieldPos("C5_X_VPCAV")) > 0
	C_SF2520E()
endif

//———————————————————————————————————————————————————————————————————————————————
// Atualiza flag da tabela de pre-pedidos web (SZL)
// por Adalberto Moreno Batista em 22/07/13        
//———————————————————————————————————————————————————————————————————————————————
if cEmpAnt == "01" .and. SD2->(FieldPos("D2_X_NUMZL")) > 0
	D_SF2520E()
endif


//—————————————————————————————————————————————————————————————————————————————————————
// Efetua estorno das transferência entre armazem de notas de remessa de armazenagem
// MV_XFOREDI / MV_XLOJEDI -> Parâmetros com codigo e loja do Operador Logistico
// CFOP de remessa de armazenagem = 6905 
// por Luiz Fernando em 29/08/14
//—————————————————————————————————————————————————————————————————————————————————————
if	SD2->D2_TIPO = "B" .and. SD2->D2_CF = "6905" .and. Posicione("SF4",1,xFilial("SF4")+SD2->D2_TES,"F4_ESTOQUE") = "N"
	if SD2->D2_CLIENTE = cCliArm .and. SD2->D2_LOJA = cLojArm
		E_SF2520E()
	endif
endif


//———————————————————————————————————————————————————————————————————————————————
// Exclui registros históricos de datas de vencimento de títulos a receber
// por Adalberto Moreno Batista em 15/07/13                                 
//———————————————————————————————————————————————————————————————————————————————
if	!empty(SF2->F2_DUPL)
	F_SF2460I()
endif

Return()

/*/
———————————————————————————————————————————————————————————————————————————————
@function		A_SF2520E                                                    /@
@type			Static function                                              /@
@date			12/12/2010                                                   /@
@description	Função chamada pela user function SF2520E. 
				Exclui informacoes sobre exportacoes na tabela CDL para o 
				preenchimento da TAG referente a exportacoes na SPED NFe.    /@
@author			Adalberto Moreno Batista                                     /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function A_SF2520E()
Local _aAreaCDL := CDL->(GetArea())

CDL->(dbSetOrder(1))
CDL->(dbSeek(xFilial("CDL") + SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA)))
do while CDL->(!eof() .and. CDL_FILIAL = xFilial("CDL") .and. CDL_DOC + CDL_SERIE + CDL_CLIENT + CDL_LOJA = SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA))
	CDL->(RecLock("CDL",.F.))
	CDL->(dbDelete())
	CDL->(msUnlock())
	CDL->(dbSkip())
enddo

RestArea(_aAreaCDL)
Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		B_SF2520E                                                    /@
@type			Static function                                              /@
@date			28/08/2011                                                   /@
@description	Função chamada pela user function SF2520E. 
				Grava data, hora e nome e id do usuario nas tabelas SF2 e SD2
				com dados do usuario que efetuou a exclusao da nota          /@
@author			Ronaldo Gomes                                                /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function B_SF2520E()
Local aArea		:= GetArea()
Local aAreaSD2	:= SD2->( GetArea() )
Local dData		:= DATE() //Adicionado pelo Ronaldo
Local cTime		:= TIME() //Adicionado pelo Ronaldo

If SF2->( RecLock("SF2",.F.) )
	//Cabeçalho da NF
	SF2->F2_X_DATA	:= dData
	SF2->F2_X_HORA	:= cTime
	SF2->F2_X_USUAR	:= SubStr(cUsuario,7,15)//Nome do Usuario
	SF2->F2_X_ID	:= __cUserID 
	SF2->( MsUnlock() )
EndIf

SD2->( dbSetOrder(3) )	//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
SD2->( dbSeek( xFilial("SD2") + SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA) ) )
do while SD2->( !eof() .and. D2_FILIAL = xFilial("SD2") .and. D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA = SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA) )

	If SD2->( RecLock("SD2",.F.) )
		//Itens da NF
		SD2->D2_X_DATA	:= dData
		SD2->D2_X_HORA	:= cTime
		SD2->D2_X_USUAR	:= SubStr(cUsuario,7,15) // Nome do Usuario
		SD2->D2_X_ID	:= __cUserID
		SD2->( MsUnlock() )
	EndIf                                                     

	SD2->(dbSkip())

enddo

RestArea(aAreaSD2)
RestArea(aArea)
Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		C_SF2520E                                                    /@
@type			Static function                                              /@
@date			07/01/2012                                                   /@
@description	Função chamada pela user function SF2520E. 
				Exclui informacoes de VPC.                                   /@
@author			Adalberto Moreno Batista                                     /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function C_SF2520E()
Local aArea		:= GetArea()

//exclusao do movimento de credito
U_VPCApaga_FT03("1", SF2->(F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA))

RestArea(aArea)
Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		D_SF2520E                                                    /@
@type			Static function                                              /@
@date			22/07/2013                                                   /@
@description	Função chamada pela user function SF2520E.                  
				Atualiza informações na tabela de orçamento web. (SZL)       /@
@author			Adalberto Moreno Batista                                     /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function D_SF2520E()
Local aArea		:= GetArea()
Local aAreaSD2	:= SD2->(GetArea())
Local aAreaSA1 	:= SA1->(getArea())
Local aAreaSZL 	:= SZL->(getArea())
Local dUltCom	:= CTOD("  /  /  ")
Local lTpvenda := .F.
Local lTpacess := .F.
Local cQuery,cVend

SZL->(dbSetOrder(1))
SD2->(dbSetOrder(3))	//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
SD2->(dbSeek(xFilial("SD2") + SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA)))
do while SD2->(!eof() .and. D2_FILIAL = xFilial("SD2") .and. D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA = SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA))
	
	if SZL->(dbSeek(xFilial("SZL") + SD2->(D2_X_NUMZL + D2_X_ITEZL)))
		SZL->(RecLock("SZL", .F.))
		SZL->ZL_NF		:= StrTran(SZL->ZL_NF, SD2->D2_SERIE + SD2->D2_DOC + "#", "")
		SZL->ZL_QTDFAT	:= SZL->ZL_QTDFAT - SD2->D2_QUANT
		SZL->ZL_GRVPED	:= iif(SZL->ZL_QTDFAT == 0, "S", "P") 
		SZL->ZL_CATEGT2	:= ""
		SZL->ZL_CATMGT2	:= 0
		SZL->ZL_MGPDVT2	:= 0
		SZL->ZL_MGNEGT2	:= 0
		SZL->ZL_NTPEDT2	:= ""
		SZL->(MsUnlock())
		ltpvenda := iif(alltrim(SZL->ZL_ATTCLI) == "NORMAL",.T.,.F.)
		lTpacess := iif(alltrim(SZL->ZL_TPACESS) == "TVEND",.T.,.F.)
	endif

	SD2->(dbSkip())

enddo
if lTpvenda .and. lTpacess
	
	cQuery := "SELECT MAX(F2_EMISSAO) ULTEMISSAO FROM "+retsqlname("SF2")+" SF2 LEFT JOIN "+retsqlname("SZL")+" SZL ON "
	cQuery += "F2_FILIAL = ZL_FILIAL AND F2_CLIENTE = ZL_CLIENTE AND F2_LOJA = ZL_LOJA "
	cQuery += "WHERE ZL_GRVPED IN ('F','P') AND SF2.D_E_L_E_T_ = ' ' AND SZL.D_E_L_E_T_ = ' ' AND "
	cQuery += "ZL_CLIENTE+ZL_LOJA = '"+SF2->(F2_CLIENTE+F2_LOJA)+"' AND F2_DOC+F2_SERIE <> '"+SF2->(F2_DOC+F2_SERIE)+"' "
	
	if Select("TRAB") > 0
		dbSelectArea("TRAB") 
		dbCloseArea()
	endif

	//———————————————————————————————————————————————————————————————————————————————
	// Criando a tabela temporaria
	//———————————————————————————————————————————————————————————————————————————————
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRAB", .F., .T.)                
		
 	if !empty(TRAB->ULTEMISSAO)
		dUltCom := stod(TRAB->ULTEMISSAO)
	endif
	
	
	if	SA1->(dbseek(xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA)))
		if AllTrim(SA1->A1_XATTCLI) == "TVENDAS-N"			//.and. SF2->F2_EMISSAO - dUltCom > 180 - alterado em 13/05/19 para nao considerar mais tempo (Cassio)
			cVend := SA1->A1_XVENALT
			if SA1->(reclock("SA1",.F.))
				SA1->A1_XVENALT := SA1->A1_VEND
				SA1->A1_VEND 	:= cVend
				SA1->A1_XATTCLI := "NORMAL"
				SA1->A1_XRADIX 	:= "A"
				msunlock("SA1")
			endif
		endif
	endif
endif

restArea(aAreaSA1)
RestArea(aAreaSD2)
RestArea(aAreaSZL)
RestArea(aArea)
Return()


/*
———————————————————————————————————————————————————————————————————————————————
@function		E_SF2520E                                                    /@
@date			29/08/2014                                                   /@
@description	Função chamada pela user function SF2520E. 
				Estorno de Transferencia entre armazem					     /@
@author			Luiz Fernando									             /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
*/
Static Function E_SF2520E()
Local aArea, aAreaSD3, dDataFec, dEmissao, aSeqSD3

if SF2->(FieldPos("F2_X_DOCD3")) > 0
	if !empty(SF2->F2_X_DOCD3)

		aArea	 := GetArea()
		aAreaSD3 := SD3->(GetArea())
		aSeqSD3	 := {}
		dDataFec := GetMV("MV_ULMES")

		SD3->(dbSetOrder(2))        
        SD3->(dbSeek(xFilial("SD3") + SF2->F2_X_DOCD3))
		do while SD3->(!eof() .and. D3_FILIAL == xFilial("SD3") .and. D3_DOC == SF2->F2_X_DOCD3)
		
			//———————————————————————————————————————————————————————————————————————————————
			// verificando se o item foi estornado e a data do ultimo fechamento em SX6.
			//———————————————————————————————————————————————————————————————————————————————
			if SD3->D3_ESTORNO <> "S" .and.;
				aScan(aSeqSD3, SD3->D3_NUMSEQ) == 0 .and.;
				(dDataFec <= dDataBase .Or. dDataFec <= SD3->D3_EMISSAO)
               
				dEmissao := SD3->D3_EMISSAO
				aAdd(aSeqSD3,SD3->D3_NUMSEQ)
							
			endif
			SD3->(dbSkip())
		enddo
		
		//———————————————————————————————————————————————————————————————————————————————
		// Estorno as movimentacoes de transferencia, caso estejam dentro dos parametros
		// verificados acima
		//———————————————————————————————————————————————————————————————————————————————
		if Len(aSeqSD3) > 0
			U_BFATM05(aSeqSD3, SF2->F2_X_DOCD3,dEmissao,SF2->F2_DOC,SF2->F2_SERIE) //para rotinas automaticas
		endif

		SD3->(RestArea(aAreaSD3))
		RestArea(aArea)
	
	endif

endif

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		F_SF2460I                                                    /@
@type			Static function                                              /@
@date			22/09/2016                                                   /@
@description	Função chamada pela user function SF2460I. 
				Exclui registros na tabela de historico de alteracoes de 
				vencimento de titulos a receber (ZZ2).                       /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function F_SF2460I()
Local aAreaSX2 := SX2->(GetArea())
Local aAreaSE1 := SE1->(GetArea())

if SX2->(dbSeek("ZZ2"))

	ZZ2->(dbSetOrder(1))		//ZZ2_FILIAL, ZZ2_PREFIX, ZZ2_NUM, ZZ2_PARCEL, ZZ2_TIPO, ZZ2_CLIENT, ZZ2_LOJA, ZZ2_DTMOV, ZZ2_HRMOV
	SE1->(dbSetOrder(2))		//E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
	
	SE1->(dbSeek(xFilial("SE1") + SF2->(F2_CLIENTE + F2_LOJA + F2_PREFIXO + F2_DOC)))
	do while SE1->(!eof() .and. E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM == xFilial("SE1") + SF2->(F2_CLIENTE + F2_LOJA + F2_PREFIXO + F2_DOC))

		ZZ2->(dbSeek(xFilial("ZZ2") + SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA)))
		do while ZZ2->(!eof() .and. ZZ2_FILIAL + ZZ2_PREFIX + ZZ2_NUM + ZZ2_PARCEL + ZZ2_TIPO + ZZ2_CLIENT + ZZ2_LOJA == xFilial("ZZ2") + SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA))
			ZZ2->(RecLock("ZZ2", .F.))
			ZZ2->(dbDelete())
			ZZ2->(MsUnlock())
			ZZ2->(dbSkip())
		enddo
		
		SE1->(dbSkip())
	enddo
	
endif

RestArea(aAreaSX2)
RestArea(aAreaSE1)
Return()
