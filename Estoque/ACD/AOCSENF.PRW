/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦  SENFAUX   ¦ Autor ¦ Edson P. S. Sales    ¦ Data ¦ 20/07/2022 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦     Rotina para Gerar documento SENF pós Doc-Aux  picklist    ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#INCLUDE 'RWMAKE.CH'    
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APVT100.CH'   

/*/{Protheus.doc} User Function nomeFunction/*/
User Function AOCSENF()

    Local aTela 
    Local cDoc

    While !VTLastkey() == 27 // enquanto não apertar (ESC) ficar na tela para bipar
        cDoc := Space(6)
        VTClear()
        VTSave Screen To aTela

        @ 00,02 VTSay PadR('---GERAR SENF AUXILIAR---' , VTMaxCol())
        @ 01,00 VTSay PadR('Doc.: ', VTMaxCol())
        @ 01,07 VTGET cDoc  Pict '@!' VALID !EMPTY(cDoc) .and. fValDoc(cDoc)

        VTRead
        VTRestore Screen FROM aTela
    endDo
    
Return 

/* Validar se o documento existe */

******************************************************************************************************************************************************
Static Function fValDoc(cNumDoc)
*********************************************************************************************************************************************************************************************************************
    Local   cAliasDoc  := GetNextAlias()
    Local   lDoc :=.F.
         
    Local   cQry  := "SELECT ZT9.ZT9_DOCAUX DOC FROM " + RetSqlName('ZT9') + " ZT9  (NOLOCK) "
            cQry  += " WHERE  ZT9_DOCAUX = '" + cNumDoc +"' AND D_E_L_E_T_=''"

    cQry := ChangeQuery(cQry)
    dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasDoc, .T., .F.)

    dbSelectArea(cAliasDoc)

    DbSelectArea('ZT8')
    ZT8->(MsSeek(FWFilial('ZT8') + cNumDoc ))

    if Empty((cAliasDoc)->DOC)

        VTAlert('Documento informado nao existe!!!',"Atencao",.T.)  //  

    elseif  ZT8_STATUS=='1' // documento ja processado/Senf Gerada

        VTAlert('Documento informado já foi Processado!!!',"Atencao",.T.)

    else
        fgerar((cAliasDoc)->DOC)
        lDoc := .T.
    endif

   (cAliasDoc)->(dbCloseArea())
   dbSelectArea('ZT8')

Return 

/*/ {Protheus.doc} User Function nomeFunction /*/
Static Function fgerar(cNumDoc)
Local   cCorpo
Local cQry1     :=''
Local  lResp := .F.
Local cAliasQry1 :=GetNextAlias()
local cNumSf := GetSXENum("ZT3", "ZT3_NUM")
Local nItem := 1
Local cEndDest :="EXPEDICAO" // DESTINO DO VOLUME APOS GERAR SENF


cQry1 +="  SELECT   COUNT(*) QUANT,  "
cQry1 +="           SB1.B1_UM UNIDADE,  "
cQry1 +="           SBF.BF_LOCAL ARMAZEM,   "
cQry1 +="           SBF.BF_LOCALIZ ENDERECO,    "
cQry1 +="           SBF.BF_LOTECTL LOTE,    "
cQry1 +="           SB1.B1_DESC DESCRICAO,  "
cQry1 +="           ZT9.ZT9_CODPRO PRODUTO ,  "
cQry1 +="           DA1_PRCVEN PRC_UNIT,   "
cQry1 +="           DA1_PRCVEN *  COUNT(*) AS PRC_TOTAL     " 
cQry1 +="  FROM " +RetSQLName('ZT9') +" ZT9  (NOLOCK) "
cQry1 +="       INNER JOIN " +RetSQLName('DA1') +" DA1 (NOLOCK) ON DA1.D_E_L_E_T_='' AND DA1.DA1_CODPRO = ZT9.ZT9_CODPRO AND DA1.DA1_CODTAB ='079'    "
cQry1 +="       INNER JOIN  " +RetSQLName('SB1') +" SB1 (NOLOCK) ON SB1.D_E_L_E_T_='' AND SB1.B1_COD = ZT9.ZT9_CODPRO  "
cQry1 +="       INNER JOIN  " +RetSQLName('SBF') +" SBF (NOLOCK) on SBF.D_E_L_E_T_='' AND SBF.BF_PRODUTO = ZT9.ZT9_CODPRO AND SBF.BF_LOCALIZ='SEPARACAO'  "
cQry1 +="  WHERE   ZT9.D_E_L_E_T_=''  and ZT9.ZT9_DOCAUX='" + cNumDoc +"'"
cQry1 +="  GROUP BY ZT9.ZT9_CODPRO,DA1_PRCVEN,SB1.B1_UM,SB1.B1_DESC,SBF.BF_LOCAL,SBF.BF_LOCALIZ,SBF.BF_LOTECTL  "
 
cQry1 := ChangeQuery(cQry1)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry1),cAliasQry1, .T., .F.)
dbSelectArea(cAliasQry1)

if MsgYesNo('Tem Certeza que quer gerar SENF Auxiliar ?', 'Atencao!!!')
    DbSelectArea('ZT3')
        
    VTMSG("Aguarde...")
	vBaixaReg  := 0
	vBaixaAcum := 0

    Begin Transaction

        //DbSetOrder(1)
        RecLock('ZT3',.T.)
            ZT3_FILIAL := FWFILIAL('ZT3')
            ZT3_NUM    := cNumSf
            ZT3_TPSENF := 'Rem.Armz.'
            ZT3_TIPO   := 'B'
            ZT3_DATA   := DATE()
            ZT3_CODCF  := '02462805'
            ZT3_LOJA   := '07'
            ZT3_NOME   := 'FM LOGISTIC'
            ZT3_END    := 'VIA ANHAGUERA, SN KM 26 421'
            ZT3_MOVEST := "S"
            ZT3_SOL    := USRRETNAME(RETCODUSR())                                                                                                         
            ZT3_SETOR  := 'Supply Chain'
            ZT3_TES    := '635'
            ZT3_CONDPA := '141'
            ZT3_EMAIL  := USRRETMAIL(RETCODUSR())
            ZT3_PEDIDO := ''                                                                                                         
            ZT3_STATUS := '1'
            ZT3_CODTAB := '079'
            ZT3_TRANSP := '041474'

        MsUnlock()
        ConfirmSX8()
    // Mudar o status na ZT8
        DbSelectArea('ZT8')
        
        if ZT8->(MsSeek(FWFilial('ZT8') + cNumDoc ))
            RecLock('ZT8', .F.)
               ZT8_STATUS  := '1'      // 1 = Senf gerada
               ZT8_SENF    := cNumSf
            MsUnlock()
        EndIf
        
        DbSelectArea('ZT4')
        While !(cAliasQry1)->(EoF())
            
            RecLock('ZT4', .T.)
                ZT4_FILIAL := FWFILIAL('ZT4')
                ZT4_NUMSF  := cNumSf
                ZT4_ITEM   := StrZero(nItem++,3)
                ZT4_COD    := (cAliasQry1)->PRODUTO
                ZT4_UM     := 'UN'       // IIF(!INCLUI,POSICIONE("SB1",1,XFILIAL("SB1")+ZT4->ZT4_COD,"B1_UM"),"")
                ZT4_DESC   := (cAliasQry1)->DESCRICAO
                ZT4_UM     := (cAliasQry1)->UNIDADE
                ZT4_QTDSOL := (cAliasQry1)->QUANT
                ZT4_QTDATE := (cAliasQry1)->QUANT
                ZT4_PRCVEN := (cAliasQry1)->PRC_UNIT
                ZT4_PRCUNI := (cAliasQry1)->PRC_UNIT
                ZT4_VALOR  := (cAliasQry1)->PRC_TOTAL 
                ZT4_DTLIB  := DATE()
                ZT4_USLIB  := USRRETNAME(RETCODUSR()) 

                //PARAMETROS//  COD-Produto, Arm Origem, end Origem , Arm destino , End testino, quantidade, lote
                lResp := Tranf_End((cAliasQry1)->PRODUTO,(cAliasQry1)->ARMAZEM,(cAliasQry1)->ENDERECO,(cAliasQry1)->ARMAZEM,cEndDest,(cAliasQry1)->LOTE,(cAliasQry1)->LOTE,(cAliasQry1)->QUANT)     
                // tranferir de SEPARACAO p/ EXPEDICAO.                                            
                iF !lResp
                    VTAlert('Saldo no Endereco SEPARACAO é menor que a quantidade contida no Documento','NAO FOI POSSIVEL GERAR SENF',.T.)
                    DisarmTransaction()
                    RETURN lResp
                EndIf 
            MsUnlock()
            (cAliasQry1)->(dbSkip())
        EndDo
    End Transaction

    ZT4->(dbCloseArea())
    ZT3->(dbCloseArea())
    ZT8->(dbCloseArea())
    (cAliasQry1)->(dbCloseArea())
    
    VTAlert('SENF auxiliar Gerada1 - Num:'+cNumSf, 'Sucesso!!!',.T.)
    
    cCorpo := fGeraRel(cNumDoc,cNumSf)

    fSenfEmail(cCorpo)
   
Else 
    RollBackSX8()
    VtAlert('Nenhuma Senf foi gerada','Aviso!!!',.T.)
EndIf

Return

***************************************************************************************************************************************
Static Function Tranf_End(cProduto,cArmOri,cEndOri,cArmDest,cEndDest,cLoteOri,cLoteDest,nQtd)	//Função de transferencia de endereços
***************************************************************************************************************************************
	
    Local _cDoc :=u_SD3_DOC()
    Local lResp := .T.
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
         lResp :=.F.
		Return  lResp
		//Endif
	Endif

Return lResp


Static Function fGeraRel(cNumDoc,cNumSf)
   
    Local _cHTML :=''

    Private   _cSTATUS   :=    'Setor Exp.'
    Private   _cDATA     :=    DTOC(dDataBase)
    Private   _cHoraAtu  :=    time()
    Private   _cNUM      :=    cNumDoc
    Private   _cSETOR    :=    'Supply Chain'
    Private   _cTPSENF   :=    'Rem.Armz.' 
    Private   _cSOL      :=    USRRETNAME(RETCODUSR())
    Private   _cMovEst   :=    "Mov. Estoque: SIM"
    Private _nTotValor   :=    0
    Private _nTotalQtd   :=    0
    Private  _cTotalQtd  :=    ''
    Private  _cTotValor  :=    ''

_cHTML+='<!DOCTYPE html>																				                        '                            
_cHTML+='<html>																				                                    '                
_cHTML+='																				                                        '            
_cHTML+='<head>																				                                    '                
_cHTML+='    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">									        '											                                            
_cHTML+='    <title>SENF-ELETRONICA</title>																				        '                                            
_cHTML+='    <style>																				                            '                        
_cHTML+='        .page {																				                        '                            
_cHTML+='            width: 19cm;																				                '                                    
_cHTML+='            min-height: 29.7cm;																				        '                                            
_cHTML+='            padding: 1cm;																				                '                                    
_cHTML+='            margin: 1cm auto;																				            '                                        
_cHTML+='            font-size: 14pt;																				            '                                        
_cHTML+='            /*  border: 1px #D3D3D3 solid; */																	        '			                                            
_cHTML+='            /*  border-radius: 5px; */																			        '	                                            
_cHTML+='            /*  background: white; */																			        '	                                            
_cHTML+='            /*  box-shadow: 0 0 5px rgba(0, 0, 0, 0.1); */														        '						                                            
_cHTML+='        }																				                                '                    
_cHTML+='																				                                        '            
_cHTML+='        @page {																				                        '                            
_cHTML+='            size: A4;																				                    '                                
_cHTML+='            margin: 0;																				                    '                                
_cHTML+='        }																				                                '                    
_cHTML+='																				                                        '            
_cHTML+='        @media print {																				                    '                                
_cHTML+='            .page {																				                    '                                
_cHTML+='                margin: 0;																				                '                                    
_cHTML+='                border: initial;																				        '                                            
_cHTML+='                border-radius: initial;																		        '		                                            
_cHTML+='                width: initial;																				        '                                            
_cHTML+='                min-height: initial;																			        '	                                            
_cHTML+='                box-shadow: initial;																			        '	                                            
_cHTML+='                background: initial;																			        '	                                            
_cHTML+='                page-break-after: always;																		        '		                                            
_cHTML+='                																				                        '                            
_cHTML+='            }																				                            '                        
_cHTML+='        }																				                                '                    
_cHTML+='																				                                        '            
_cHTML+='        h1 {																				                            '                        
_cHTML+='            font-size: 24pt;																				            '                                        
_cHTML+='            text-align: center;																				        '                                            
_cHTML+='        }																				                                '                    
_cHTML+='																				                                        '            
_cHTML+='        h2 {																				                            '                        
_cHTML+='            font-size: 18pt;																				            '                                        
_cHTML+='            text-align: center;																				        '                                            
_cHTML+='        }																				                                '                    
_cHTML+='																				                                        '            
_cHTML+='        h3 {																				                            '                        
_cHTML+='            font-size: 14pt;																				            '                                        
_cHTML+='            text-align: center;																				        '                                            
_cHTML+='        }																				                                '                    
_cHTML+='																				                                        '            
_cHTML+='        #demo-table {																				                    '                                
_cHTML+='            border-collapse: collapse;																			        '	                                            
_cHTML+='            width: 100%;																				                '                                    
_cHTML+='        }																				                                '                    
_cHTML+='        #pg-table {																				                    '                                
//_cHTML+='            border-collapse: collapse;																		        '		                                            
_cHTML+='            width: 100%;																				                '                                    
_cHTML+='        }																				                                '                    
_cHTML+='																				                                        '            
_cHTML+='        /* basic shared rules */																				        '                                            
_cHTML+='        #demo-table th,																				                '                                    
_cHTML+='        #demo-table td {																				                '                                    
_cHTML+='            padding: 0.25rem;																				            '                                        
_cHTML+='            text-align: left;																				            '                                        
_cHTML+='																				                                        '            
_cHTML+='        }																				                                '                    
_cHTML+='																				                                        '            
_cHTML+='        #demo-table td.direita {																				        '                                            
_cHTML+='            padding: 0.25rem;																				            '                                        
_cHTML+='            text-align: right;																				            '                                        
_cHTML+='																				                                        '            
_cHTML+='        }																				                                '                    
_cHTML+='																				                                        '            
_cHTML+='        #demo-table td.centro {																				        '                                            
_cHTML+='            padding: 0.25rem;																				            '                                        
_cHTML+='            text-align: center;																				        '                                            
_cHTML+='																				                                        '            
_cHTML+='        }																				                                '                    
_cHTML+='																				                                        '            
_cHTML+='        #demo-table th {																				                '                                    
_cHTML+='            font-weight: bold;																				            '                                        
_cHTML+='            padding-left: .5em;																				        '                                            
_cHTML+='        }																				                                '                    
_cHTML+='																				                                        '            
_cHTML+='																				                                        '            
_cHTML+='        /* header */																				                    '                                
_cHTML+='        #demo-table thead {																				            '                                        
_cHTML+='            text-align: center;																				        '                                            
_cHTML+='            color: white;																				                '                                    
_cHTML+='            background-color: black;																			        '	                                            
_cHTML+='            font-size: 10pt;																				            '                                        
// _cHTML+='            margin-bottom: 30px;  																			        '	                                            
_cHTML+='		}																	                                            '        
_cHTML+='																				                                        '            
_cHTML+='        /* fix size of superscript */																			        '	                                            
_cHTML+='        #demo-table sup {																				                '                                    
_cHTML+='            font-size: 55%;																				            '                                        
_cHTML+='        }																				                                '                    
_cHTML+='																				                                        '            
_cHTML+='        /* body */																				                        '                            
_cHTML+='        #demo-table td {																				                '                                    
_cHTML+='            padding: 0.25rem;																				            '                                        
_cHTML+='            text-align: left;																				            '                                        
_cHTML+='            border: 1px solid #696969; 																		        '		                                            
_cHTML+='            font-size: 7pt;																				            '                                        
//_cHTML+='            border-style: solid;																				        '                                            
_cHTML+='            border-width: thin;																				        '                                            
_cHTML+='        }
_cHTML+='        .space {																				                        '
_cHTML+='            padding: 10px;     																				        '                                        
_cHTML+='         }						                    														            '                                                            
_cHTML+='    </style>																				                            '                        
_cHTML+='																				                                        '            
_cHTML+='</head>																				                                '                    
_cHTML+='																				                                        '            
_cHTML+='<body>																				                                    '                
_cHTML+='    <div class="page">																				                    '                                
_cHTML+='        <table id="pg-table" >																				            '                                        
_cHTML+='            <tbody>																				                    '                                
_cHTML+='                <!-- Top Page -->																				        '                                            
_cHTML+='                <tr>																				                    '                                
_cHTML+='                    <hr>																				                '                                    
_cHTML+='                </tr>																				                    '                                
_cHTML+='                <tr>																				                    '                                
_cHTML+='                    <table id="pg-table">																		        '		                                            
_cHTML+='                        																				                '                                    
_cHTML+='                        <tr>																				            '                                        
_cHTML+='                          																				                '
_cHTML+='                            <td width="25%" style="text-align: center;">												'
_cHTML+='                                <img src="https://gamaitaly.vteximg.com.br/arquivos/logo.png" alt="Gama">				'
_cHTML+='                            </td>																				        '
_cHTML+='                            <td>																				        '
_cHTML+='                                <h2>DOCUMENTO AUXILIAR P/ GERACAO DA SENF</h2>										    '
_cHTML+='                                <h3>REGISTRO DE EMBARQUE - NUM.SERIES</h3>												'
_cHTML+='                            </td>																				        '
_cHTML+='                            <td width="25%">																			'
_cHTML+='                                <table>																				'
_cHTML+='                                    <tr>																				'
_cHTML+='                                        <td style="text-align: left;">Status :</td>									'
_cHTML+='                                        <td style="text-align: left;" bgcolor="#F7CF46">								'
_cHTML+='                                            <font color="#000000"><strong>'+_cStatus+'</strong></font>					'
_cHTML+='                                        </td>														                    '
_cHTML+='                                    </tr>															                    '
_cHTML+='                                    <tr>															                    '
_cHTML+='                                        <td style="text-align: left;">Emissao </td>				                    '
_cHTML+='                                        <td>'+ _cData +'											                    '
_cHTML+='                                        </td>														                    '
_cHTML+='                                    </tr>											    			                    '
_cHTML+='                                    <tr>															                    '
_cHTML+='                                        <td style="text-align: left;">Hora </td>					                    '
_cHTML+='                                        <td>'+_cHoraAtu+'</td>										                    '
_cHTML+='                                    </tr>															                    '
_cHTML+='																				                                        '
_cHTML+='                                </table>															                    '
_cHTML+='																				                                        '
_cHTML+='                        </tr>																		                    '
_cHTML+='                    </table>																		                    '
_cHTML+='                </tr>																				                    '
_cHTML+='                <tr>																				                    '
_cHTML+='																				                                        '
_cHTML+='                    <!-- Cabeçalho -->																                    '
_cHTML+='                    <table id="demo-table">														                    '
_cHTML+='                        <tbody>																	                    '
_cHTML+='                            <tr>																	                    '
_cHTML+='                                <td width="25px" style="font-size: 12px; margin-left:8px;" >Doc.Auxiliar  </td>								                    '
_cHTML+='                                <td style="font-size: 12px; margin-left:8px;"><b >'+_cNum+'</b> </td>											                    '
_cHTML+='                                <td style="font-size: 12px; margin-left:8px;" colspan="2"> Setor : <b>'+_cSetor+'</b></td>					                    '
_cHTML+='                                <td style="font-size: 12px; margin-left:8px;" colspan="2">Tp. Senf : <b>'+_cTPSENF+' </b></td>				                    '
_cHTML+='                            </tr>																	                    '
_cHTML+='                            <tr>																	                    '
_cHTML+='                                <td style="font-size: 12px; margin-left:8px;" width="25px">Emitido por:</td>								                    '
_cHTML+='                                <td style="font-size: 12px; margin-left:8px;" colspan="3">'+ _cSol + ' </td>                                                     '
_cHTML+='                                <td style="font-size: 12px; margin-left:8px;" colspan="2">'+ _cMovEst +' </td>                                                   '																				'
_cHTML+='                            </tr>																	                    '
_cHTML+='                            <tr>																	                    '
_cHTML+='                                <td style="font-size: 12px; margin-left:8px;" width="25px" >Destinatário </td>								                    '
_cHTML+='                                <td style="font-size: 12px; margin-left:8px;" colspan="5"> 02462805/07 - FM LOGISTIC </td>					                    '
_cHTML+='                            </tr>																	                    '
_cHTML+='                            <tr>																	                    '
_cHTML+='                                <td style="font-size: 12px; margin-left:8px;" width="25px">Endereco </td>									                    '
_cHTML+='                                <td style="font-size: 12px; margin-left:8px;" colspan="5"> VIA ANHAGUERA, SN KM 26 421 </td>					                    '
_cHTML+='                            </tr>                                                                                      '
_cHTML+='                        </tbody>																	                    '
_cHTML+='                    </table>																	                        '
_cHTML+='																				                                        '
_cHTML+='                </tr>																				                    '
_cHTML+='                <!-- Itens -->																		                    '
_cHTML+='                <tr>																				                    '
_cHTML+='                   <td class="space"></td>			    											                    '
_cHTML+='                </tr>																				                    '
_cHTML+='                    <table id="demo-table">							                        	                    '
_cHTML+='                        <thead>																	                    '
_cHTML+='                            <tr>																	                    '
_cHTML+='                                <th >No. </th>												            '
_cHTML+='                                <th >Codigo</th>													        '
_cHTML+='                                <th >Tipo</th>														    '
_cHTML+='                                <th >Und.</th>													        '
_cHTML+='                                <th >Descricao</th>												        '
_cHTML+='                                <th >Quantidade</th>										                '
_cHTML+='                                <th >Valor R$</th>													    '
_cHTML+='                            </tr>																                        '
_cHTML+='                        </thead>																	                    '
_cHTML+='                        <tbody>                                                                                        '
// _cHTML+='                           //;carregar os itens                 
_cHTML+=                             RetItencSenf(cNumSf)                   
_cHTML+='                          <tr>    														    		                    '
_cHTML+='                              <td style="font-size: 12px; margin-left:8px;" ></td>                                                                 '
_cHTML+='                              <td style="font-size: 12px; margin-left:8px;" ><Strong>Totais -></Strong></td>                                       '
_cHTML+='                              <td style="font-size: 12px; margin-left:8px;" ></td>                                                                 '
_cHTML+='                              <td style="font-size: 12px; margin-left:8px;" ></td>                                                                 '
_cHTML+='                              <td style="font-size: 12px; margin-left:8px;" ></td>                                                                 '
_cHTML+='                              <td style="font-size: 12px; margin-left:8px;" >'+ _cTotalQtd + '</td>											                    '
_cHTML+='                              <td style="font-size: 12px; margin-left:8px;" >' + _cTotValor+'</td>											                    '
_cHTML+='			    			</tr>													                                    '
_cHTML+='                        </tbody>                                                                                       '
_cHTML+='                    </table>                                                                                           '
_cHTML+='                <tr>																				                    '
_cHTML+='                   <td class="space"></td>			    											                    '
_cHTML+='                </tr>																				                    '
_cHTML+='                <tr>																				                    '
_cHTML+='                    <table id="demo-table" >								                                            '
_cHTML+='                        <thead>																	                    '
_cHTML+='                            <tr>																	                    '
_cHTML+='                                <th >Codigo</th>													        '
_cHTML+='                                <th >QRCode</th>													        '
_cHTML+='                                <th >Lacre</th>														    '
_cHTML+='                                <th >Nº Serie</th>													    '
_cHTML+='                                <th >Nº OP</th>												            '
_cHTML+='                                <th >Quant.</th>												            '
_cHTML+='                            </tr>																	                    '
_cHTML+='                        </thead>																	                    '
// _cHTML+='                           //;carregar os itens                 
_cHTML+='                        <tbody>                                                                                        '
_cHTML +=                           retItensDocaux(cNumDoc,cNumSf)                  
_cHTML+='                        </tbody>                                                                                       '
_cHTML+='                    </table>                                                                                           '
_cHTML+='        <!-- Rodape -->																			                    '
_cHTML+='        <tr>																				                            '
_cHTML+='            <td style="text-align: center;">														                    '
_cHTML+='                Aviso / Sistema : Este documento é para uso interno,								                    '
_cHTML+='                utilizado para geração/liberacao de documentos fiscais,						                        '
_cHTML+='                portanto sem valor Fiscal.															                    '
_cHTML+='            </td>																			    	                    '
_cHTML+='        </tr>																				                            '
_cHTML+='																				                                        '
_cHTML+='        </tbody>																			       	                    '
_cHTML+='        </table>																				                        '
_cHTML+='    </div>																				                                '
_cHTML+='</body>																				                                '
_cHTML+='																				                                        '
_cHTML+='</html>																				                                '


RETURN(_cHTML)



// FUNÇÃO: RETORNA OS ITENS EM HTML
STATIC Function RetItencSenf(cNum) // RECEBE O NÚMERO REGISTRO
    Local cItens :=""               // Retornaos Itens em TXT/HTML
    Local aArea := ZT4->(GetArea()) // ARMAZENA A ÁREA PARA RESTAURAR APÓS OPERAÇÕES

    ZT4->(DbGoTop())                          // MOVE O CURSOR PARA O TOPO DA TABELA
    ZT4->(DbSetOrder(1))                      // ALTERA PARA O ÍNDICE 1: ZT2_FILIAL + ZT2_DOC + (...)
    ZT4->(MsSeek(FwXFilial("ZT4") + cNum )) // USA O NÚMERO  PARA PESQUISAR

    // ENTÃO O NÚMERO  NÚMERO CORRENTE NA
    // TABELA ZT2, ADICIONE O VALOR TOTAL DO ITEM A VARIAVEL NTOTAL
    While (ZT4->ZT4_NUMSF == cNum)
       
        cItens+='<tr>'								
        cItens+='<td style="font-size: 12px; margin-left:8px;" >' 
        cItens+=ZT4->ZT4_ITEM 							
        cItens+='</td>'

        cItens+='<td style="font-size: 12px; margin-left:8px;" >'								
        cItens+=ZT4->ZT4_COD							
        cItens+='</td>'								

        cItens+='<td style="font-size: 12px; margin-left:8px;" >'						
        cItens+=POSICIONE("SB1",1,xFilial("SB1")+ZT4->ZT4_COD,"B1_TIPO")	
        cItens+='</td>'	

        cItens+='<td style="font-size: 12px; margin-left:8px;" >'						
        cItens+=ZT4->ZT4_UM							
        cItens+='</td>'								

        cItens+='<td style="font-size: 12px; margin-left:8px;" >'								
        cItens+=ZT4->ZT4_DESC							
        cItens+='</td>'								

        cItens+='<td style="font-size: 12px; margin-left:8px;" >'								
        cItens+=Transform((ZT4-> ZT4_QTDSOL), "@E 99,999.99") 			
        cItens+='</td>'								

        // cItens+='<td>'								
        // cItens+=IIF(ZT4->ZT4_BLOCK=="S","BLOQUEADO",Transform((ZT4-> ZT4_QTDATE), "@E 99,999.99")) 			
        // cItens+='</td>'	
        cItens+='<td style="font-size: 12px; margin-left:8px;" >'								
        cItens+=Transform((ZT4->ZT4_VALOR), "@E 99,999,999,999.99") 				
        cItens+='</td>'	
        cItens+='</tr>'
        _nTotValor := _nTotValor + ZT4->ZT4_VALOR
        _nTotalQtd := _nTotalQtd + ZT4-> ZT4_QTDSOL
        ZT4->(DbSkip())
    End
     _cTotValor:=Transform((_nTotValor), "@E 99,999,999,999.99")
     _cTotalQtd :=Transform((_nTotalQtd), "@E 99,999,999,999.99")
    // RESTAURA A ÁREA ORIGINAL (EVITA ERROS DE POSICIONAMENTO)
    RestArea(aArea)
Return (cItens) 


Static Function retItensDocaux(cNumDoc,cNumSf)
Local cItens :=""
Local cQuery :=''
cAliasQry2 :=GetNextAlias()

cQuery+= "    "
cQuery+= " SELECT DISTINCT         "
cQuery+= "      ZT4.ZT4_DESC,           "
cQuery+= "      ZT4.ZT4_COD ,           "
cQuery+= "      ZT4.ZT4_NUMSF,          "
cQuery+= "      ZT9.ZT9_CXCOLE,         "
cQuery+= "      ZT9.ZT9_LACRE,          "
cQuery+= "      ZT9.ZT9_QRCODE,         "
cQuery+= "      ZT9.ZT9_NUMOP           "
cQuery+= "  FROM "+ RetSQLName('ZT4') + " ZT4 (NOLOCK)   "
cQuery+= "  INNER JOIN " + RetSQLName('ZT8') + " ZT8 (NOLOCK) ON ZT8.D_E_L_E_T_='' AND   ZT8_DOC ='"+ cNumDoc + "'  AND ZT8.ZT8_SENF = ZT4.ZT4_NUMSF "
cQuery+= "  INNER JOIN " + RetSQLName('ZT9') + " ZT9 (NOLOCK) ON ZT9.D_E_L_E_T_='' AND  ZT9.ZT9_DOCAUX = ZT8.ZT8_DOC  and ZT4.ZT4_COD = ZT9.ZT9_CODPRO  "
cQuery+= "  WHERE   ZT4.D_E_L_E_T_=''  AND ZT4.ZT4_NUMSF = '"+ cNumSf + "'"
//cQuery+= "  GROUP BY ZT4.ZT4_COD,ZT4.ZT4_DESC,ZT4.ZT4_NUMSF, ZT4.ZT4_QTDATE,ZT4.ZT4_ITEM,ZT9.ZT9_CXCOLE,ZT9.ZT9_LACRE,ZT9.ZT9_QRCODE,ZT9.ZT9_NUMOP

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",tcGenQry(,,cQuery),"cAliasQry2",.F.,.F.)

while !(cAliasQry2->(EoF()))
        cItens+='<tr>'								
        cItens+='<td style="font-size: 12px; margin-left:8px;" >' 
        cItens+= cAliasQry2->ZT4_COD							
        cItens+='</td>'

        cItens+='<td style="font-size: 12px; margin-left:8px;" >'								
        cItens+=cAliasQry2->ZT9_QRCODE							
        cItens+='</td>'								

        cItens+='<td style="font-size: 12px; margin-left:8px;" >'						
        cItens+=cAliasQry2->ZT9_LACRE						
        cItens+='</td>'								

        cItens+='<td style="font-size: 12px; margin-left:8px;" >'								
        cItens+= cAliasQry2->ZT9_CXCOLE							
        cItens+='</td>'								

        cItens+='<td style="font-size: 12px; margin-left:8px;" >'								
        cItens+=cAliasQry2->ZT9_NUMOP 			
        cItens+='</td>'								

        cItens+='<td style="font-size: 12px; margin-left:8px;" >'								
        cItens+= '1'	
        cItens+='</td>'	
								
        cAliasQry2->(DbSkip())

    EndDo 
    
Return cItens


Static Function fSenfEmail(cCorpo)

    
    Local cEmailRH := AllTrim(GetMV("BR_PICKLIS"))   //     richardsom.silva@gamaitaly.com.br;edson.sales@gamaitaly.com.br;higor.nogueira@gamaitaly.com.br;orismar.silva@gamaitaly.com.br;       
	Local cAssunto := 'Pick-list Auxiliar (SENF) '

    Private cAnexo  :='' 
    Private aAnexos :={}
    Private cPath       := "\system\"
    Private cArquivo    := "senfdoc.html"

    If file(cPath+cArquivo)
        fErase(cPath+cArquivo)
        cAnexo := cPath+cArquivo
    EndIf
	
    aadd(aAnexos,cAnexo)

    Private cMailConta	:= NIL
	Private cMailServer	:= NIL 
	Private cMailSenha	:= NIL
	
    MemoWrite(cPath + cArquivo, cCorpo)
    
    cCorpo := ""

    cCorpo+='<body>																				                                    '                
    cCorpo+='    <div class="page">																				                    '                                
    cCorpo+='        <table id="pg-table" >																				            '                                        
    cCorpo+='            <tbody>																				                    '                                
    cCorpo+='               <tr>																				            '                                        
    cCorpo+='                 <td width="25%" style="text-align: center;">												'
    cCorpo+='                     <img src="https://gamaitaly.vteximg.com.br/arquivos/logo.png" alt="Gama">				'
    cCorpo+='                 </td>																				        '
    cCorpo+='                 <td>																				        '
    cCorpo+='                     <h3 style="width:100%">DOCUMENTO AUXILIAR P/ GERACAO DA SENF</h3>										    '
    cCorpo+='                     <h3>REGISTRO DE EMBARQUE - NUM.SERIES</h3>												'
    cCorpo+='                 </td>																				        '														                    '
    cCorpo+='                 <tr>																	                    '
    cCorpo+='                     <td style="font-size: 12px; margin-left:8px;" width="25px" >Destinatário </td>								                    '
    cCorpo+='                     <td style="font-size: 12px; margin-left:8px;" colspan="5"> 02462805/07 - FM LOGISTIC </td>					                    '
    cCorpo+='                 </tr>																	                    '
    cCorpo+='                <tr>																	                    '
    cCorpo+='                    <td style="font-size: 12px; margin-left:8px;" width="25px">Endereco </td>									                    '
    cCorpo+='                    <td style="font-size: 12px; margin-left:8px;" colspan="5"> VIA ANHAGUERA, SN KM 26 421 </td>					                    '
    cCorpo+='                </tr>                                                                                      '
    cCorpo+='            </tbody>																	                    '
    cCorpo+='        </table>																				                        '
    cCorpo+='    </div>																				                                '
    cCorpo+='</body>																				                                '
	
	Default aArquivos := {}
 
	GPEMail(cAssunto, cCorpo, cEmailRH,aAnexos )

	 
return
