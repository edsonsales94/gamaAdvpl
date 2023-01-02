/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦  AOCSEPA   ¦ Autor ¦ Edson P. S. Sales    ¦ Data ¦ 28/06/2022 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦   Rotina para Separação de produto para Expedição - picklist  ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

/*/ {Protheus.doc} User Function /*/
#INCLUDE 'RWMAKE.CH'    
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APVT100.CH' 

******************************************************************************************************************************************************
User Function AOCSEPA()
******************************************************************************************************************************************************
   Local nOpc
 
   
	VTCLear()
	@ 0,2 VTSay PadR('---SEPARACAO-PICK---' , VTMaxCol())
	@ 1,0 VTSay PadR('Selecione Operacao' , VTMaxCol())
	nOpc:=VTaChoice(2,0,3,VTMaxCol(),{'Separar','Consultar-Sep'})
	VtClearBuffer()

    If nOpc == 1
        fSepara()
    elseif nOpc == 2
        fConsulta()
    EndIf
    
Return 

Static Function fSepara()
    Local cProduto,cLoc,cEndOri,nQtd,cEndDest,lRet,cLote

    Private cDoc 

    While !VTLastkey() == 27 // enquanto não apertar (ESC) ficar na tela para bipar    // matr105  -- posição das saas  

        cProduto    := Space(15)
        cLoc    := '01'
        cLote := Space(10)
        cEndOri := Space(15)
        nQtd    := 0
        cEndDest   := 'SEPARACAO'
        

        VTClear()
        VTSave Screen To aTela
        @ 00,02 VTSay PadR('---SEPARACAO---' , VTMaxCol())
        @ 01,00 VTSay PadR('Local...: '      , VTMaxCol())
        @ 02,00 VTSay PadR('E.Orig..: '      , VTMaxCol())
        @ 03,00 VTSay PadR('Codigo..: '      , VTMaxCol())
        @ 04,00 VTSay PadR('Qtda....: '      , VTMaxCol())
        @ 05,00 VTSay PadR('E.Dest..: '      , VTMaxCol())

        
        @ 01,08 VTSay cLoc  Pict '@!' 
        @ 02,08 VTGet cEndOri  Pict '@!' VALID !Empty(cEndOri) .and. ValEnd(cLoc,cEndOri)
        @ 03,08 VTGet cProduto     Pict '@!' VALID !Empty(cProduto) .and. ValCod(cProduto)
        @ 04,08 VTGet nQtd     Pict '@R 999999.99' VALID !Empty(nQtd) .and. (SaldSBF(nQtd,cLoc,cEndOri,cProduto,cLote))
        @ 05,08 VTSay cEndDest    Pict '@!' //VALID !Empty(cEndDest) .and. ValEnd(cLoc,cEndDest)
            
        VTRead
        VTRestore Screen FROM aTela

        If (VTLastKey()==27)
			If (lRet:=DLVTAviso('', 'Deseja cancelar a separação ?', {'Sim', 'Nao'})==1)
				Exit
			EndIf
        else
            _cDoc:=u_SD3_DOC()
            IniTrans(cProduto,cLoc,cEndOri,cEndDest,nQtd,cLote)
		EndIf
               
    EndDo
Return 

/*/ {Protheus.doc} fConsulta()  /*/
Static Function fConsulta()
	Local cQryS :=''
	Local nPi :=2

	Local cSaldo :=GetNextAlias()

	cQryS += " SELECT BF_PRODUTO PROD,BF_QUANT QUANT FROM  SBF010  "
    cQryS += " LEFT JOIN  SDB010  ON DB_PRODUTO = BF_PRODUTO  "
	cQryS += " WHERE  BF_LOCALIZ ='SEPARACAO' AND BF_QUANT >0 AND BF_LOCAL='01' "
	cQryS += " GROUP BY BF_PRODUTO,BF_QUANT  "

	cQryS := ChangeQuery(cQryS)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQryS),cSaldo, .T., .F.)
	
	DbSelectArea(cSaldo)
	VTClear()
	@ 00,02 VTSay PadR('---SALDO SEPARACAO---' , VTMaxCol())
    @ 01,00 VTSay "CODIGO" 
    @ 01,16 VTSay "|" 
    @ 01,18 VTSay  'QUANT'
	@ 02,00 VTSay '---------------------------'

	while !(cSaldo)->(EoF())
		nPi++
        @ nPi,00 VTSay (cSaldo)->(PROD) Pict "@9999.99"
		@ nPi,16 VTSay "|"
        @ nPi,18 VTSay (cSaldo)->(QUANT) Pict "@9999.99"
		
		(cSaldo)->(dbSkip())
		
	endDo
	VTPause

	(cSaldo)->(dbCloseArea())

Return 

/*/{Protheus.doc} Validação de Endereco /*/
Static Function ValEnd(cLocal,cEndereco)
    Local lRet:=.T.

    DbSelectArea('SBE')
    DbSetOrder(1)
    if !dbSeek(FWFilial('SBE')+cLocal+cEndereco)
        DLVTAviso('SIGAWMS', 'O endereco '+Alltrim(cEndereco)+' nao existe.!') 
        Return .F.
    EndIf
    //VTAlert('endereço valido', 'se liga',.T.)
Return lRet

/*/{Protheus.doc} Validoção de codigo de produto/*/

Static Function ValCod(cProduto)
    Local lRet:=.F.

    DbSelectArea('SB1')
    DbSetOrder(1)
    if dbSeek(FWFilial('SB1')+cProduto)
        lRet:=.T.
    EndIf
Return lRet

/*/ {Protheus.doc} Valida saldo no endereço de origem /*/

Static Function SaldSBF(nQtd,cLoc,cEndOri,cProduto,cLote)
    Local cAliasSBF:= GetNextAlias()

    BeginSql Alias cAliasSBF  
        SELECT isnull(SUM(BF_QUANT),0) AS BF_QUANT FROM %Table:SBF% WHERE BF_FILIAL='01' 
            AND BF_PRODUTO=%exp:cProduto%  AND BF_LOCAL=%exp:cLoc% AND BF_LOCALIZ=%exp:cEndOri% 
            AND D_E_L_E_T_='' 
        EndSql 

        dbSelectArea(cAliasSBF) 
        dbgotop()

       (cAliasSBF)->BF_QUANT  

        IF nQtd > (cAliasSBF)->BF_QUANT
            DLVTAviso('SIGAWMS',"Saldo no Endereço menor que o solicitado! Saldo: "+alltrim(str((cAliasSBF)->BF_QUANT,12,5)) )
            nQTd:=0       
            Return .F. 
        ENDIF

        dbclosearea()

Return(.T.)

/*/{Protheus.docnescription)  Inicia Transferencia entre endereços  /*/

Static Function  IniTrans(cProduto,cLoc,cEndOri,cEndDest,nQtd,cLote)
    VtClearBuffer()
	If ! VTYesNo("Confirma Transf.:Ori." +cEndOri+" Desct."+cEndDest+"  Qtd.:"+Transform(nQtd,"@E 9,999,999.99")+" ?"  , "Produto: " + cProduto  , .T.)
		If IsTelnet() .and. VtModelo() == "RF"
			VTKeyBoard(chr(20))
		EndIf
		Return .F.
	EndIf

	VTMSG("Aguarde...")
	vBaixaReg  := 0
	vBaixaAcum := 0

	Begin Transaction
		Tranf_End(cProduto,cLoc,cEndOri,cLoc,cEndDest,cLote,cLote,nQtd)
	End Transaction
	VTKeyBoard(chr(20))

Return

/*/{Protheus.docnescription)  Transferencia entre endereços  /*/

***************************************************************************************************************************************
Static Function Tranf_End(cProduto,cArmOri,cEndOri,cArmDest,cEndDest,cLoteOri,cLoteDest,nQtd)	//Função de transferencia de endereços
***************************************************************************************************************************************
	Local cCodOri	:= 	cProduto												//	Produto Origem	(Codigo)
	Local cDescrOri	:= 	Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")    //	Produto Origem	(Descricao)
	Local cUmOri	:=	Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_UM")	    //	Produto Origem	(Unid Medida)
	Local cAlmOri	:= 	cArmOri												    //	Produto Origem	(Almoxarifado)
	Local cCodDest	:=	cProduto												//	Produto Destino	(Codigo)
	Local cDescrDest:=	Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")	//	Produto Destino	(Descricao)
	Local cUmDest	:=	Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_UM")	    //	Produto Destino	(Unid Medida)
	Local cAlmDest	:=	cArmDest												//	Produto Destino	(Almoxarifado

	Local cNumSerie	:= 	""							                            //	Produto	(Numero de Serie)
	Local cLote		:= 	cLoteOri							                    //	Produto	(Lote)
	Local cSLote	:= 	Space(06)								                //	Produto	(Sub Lote)
	Local cValLote	:= 	ctod('')								                //	Produto	(Validade do Lote)
	Local nPotenc	:= 	0										                //  Potencia
	Local nQtde		:= 	nQtd									                //	Produto	(Quantidade do movimento)
	Local nQtde2	:=	nQtd                                                    //	Produto	(Quantidade do movimento na Segunda Unidade Medida)
	Local cEstorn	:= 	"N"								                        //	Produto	(Se igual a S = Indica estorno)
	Local cSeq      := 	ProxNum()								                //	Produto	(Sequencia utilizada pelo sistema)
	//Local cLoteDest	:=	cLoteDest							                //	Produto	(Lote Destino)
	Local cValLtDest:=	ctod('')								                //  Produto (Validade Destino)

	Local aSepa  := {{_cDoc,dDataBase}}	                                        //Criacao da 1a. linha do array com o documento e data
	
	lmsErroAuto	:= .F.

	aAdd(aSepa,{	cCodOri		,;	                                            //	Produto Origem	(Codigo)
	cDescrOri	,;	                                                            //	Produto Origem	(Descricao)
	cUmOri		,;	                                                            //	Produto Origem	(Unid Medida)
	cAlmOri		,;	                                                            //	Produto Origem	(Almoxarifado)
	cEndOri		,;	                                                            //	Produto Origem	(Endereco)
	cCodDest	,;	                                                            //	Produto Destino	(Codigo)
	cDescrDest	,;	                                                            //	Produto Destino	(Descricao)
	cUmDest		,;	                                                            //	Produto Destino	(Unid Medida)
	cAlmDest	,;	                                                            //	Produto Destino	(Almoxarifado)
	cEndDest	,;	                                                            //	Produto Destino	(Endereco)
	cNumSerie	,;	                                                            //	Produto	(Numero de Serie)
	cLote		,;	                                                            //	Produto	(Lote)
	cSLote		,;	                                                            //	Produto	(Sub Lote)
	cValLote	,;	                                                            //	Produto	(Validade do Lote)
	nPotenc		,;                                                              //	Produto (Potencia)
	nQtde		,;	                                                            //	Produto	(Quantidade do movimento)
	nQtde2		,;	                                                            //	Produto	(Quantidade do movimento na Segunda Unidade Medida)
	cEstorn		,;	                                                            //	Produto	(Se igual a S = Indica estorno)
	cSeq		,;	                                                            //	Produto	(Sequencia)
	cLoteDest	,;	                                                            //	Produto	(Lote Destino)
	cValLtDest	,;                                                              //  Produto (Validade Lote Destino)
	Space(03)   ,;                                                              //  Item Grade
	Space(128)   ,;                                                             //  OBSERVA
	"Transf. entre Enderecos"})	

    /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Chamada da Rotina automatica para gravacao de dados	³
	|de transferencia modelo II - [tabela SD3] 				|
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

	If Len(aSepa) > 1
		x_Area  := Alias()
		x_Rec   := Recno()
		x_Ind   := Indexord()

		MsExecAuto({|x,y| mata261(x,y)},aSepa,3)

		DbSelectArea(x_Area)
		DbSetOrder(x_Ind)
		DbGoto(x_Rec)
	EndIf

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Verifica se houve algum tipo de erro retornado pela	³
	|rotina automatica.										|
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

	If  lmsErroAuto
		DLVTAviso('SIGAWMS', '!!!! ERRO DE Transferência !!!!')
		Return
		//Endif
	Endif

Return



 
