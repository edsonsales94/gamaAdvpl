#INCLUDE 'RWMAKE.CH'
#INCLUDE 'APVT100.CH'    

//transferencia CQ, LIBERACAO
User Function AOCLIBCQ()         

//Local cBarras      := Space(28)
Private _cDoc     := Space(09)
Private _cEndOri  := SPACE(15)
Private _cEndDest := SPACE(15)
Private _cLote	  := Space(10)
Private _cProduto := Space(15)
Private _cDocPa := Space(9)
Private _cLocDe	  := Space(2)
Private _cLocAt	  := "98"
Private _nQuant	  := 0
Private _cStatus    :=Space(15)
Private cObs:=""
Private cAviso:=""   
Private nSaldoEnd :=0

//Private cCliInd   :=IIF(SM0->M0_CODIGO="21",SubStr(GetMv("MV_CLIEENV"),1,6),"") 
//Private cLojaInd  :=IIF(SM0->M0_CODIGO="21",SubStr(GetMv("MV_CLIEENV"),7,2),"")
_cEndOri :="QUALIDADE"	

VTClearBuffer() 
DLVTCabec("Liberação de CQ " ,.F.,.F.,.T.)
@ 01, 00 VTSay PadR('Origem : 98 - QUALIDADE' , VTMaxCol())
//@ 01, 00 VTSay PadR('Origem  : 14 - Transito ' , VTMaxCol()) 
@ 03, 00 VTSay 'Cod.Prod: ' VTGet _cProduto  Pict '@!' 	VALID !Empty(_cProduto) .AND. fVldBarras(_cProduto) 
VTREAD
@ 04, 00 VTSay 'Quant...:' VTGet _nQuant   Pict '@R 999999.99' VALID !Empty(_nQuant) .AND. _nQuant>0 .AND. SaldSBF(_cLocAt,_cEndOri )
VTREAD  
@ 06, 00 VTSay 'Local Dest: ' VTGet _cLocDe  Pict '@!A'	VALID !Empty(_cLocDe) .AND. fValArmz(_cLocDe)
IF fVldLocaliz(_cProduto) 
	@ 07, 00 VTSay 'End. Dest: '	VTGet _cEndDest Pict '@!A' 	VALID !Empty(_cEndDest) .AND. ValEnd(_cLocDe,_cEndDest) .AND. !Empty(_nQuant)  .AND. _nQuant!=0
ELSE
   _cEndOri :=Space(15)
ENDIF
VTREAD
	
	If (VTLastKey()==27)
		If (lRet:=DLVTAviso('SIGAWMS - AVISO', 'Deseja encerrar  ?', {'Sim', 'Nao'})==1)
			return
		EndIf
	EndIf   
      
      cAviso+=_cProduto + ' Quant.: '+ LTRIM(Transform(_nQuant, "@R 999999.99")) +' Origem : '+_cLocAt
      IIF(fVldLocaliz(_cProduto),cAviso+=' -'+ _cEndOri, ) 
      cAviso+= ' Destino : '+ _cLocDe 
      IIF(fVldLocaliz(_cProduto),cAviso+=' - '+ _cEndDest,)               
		If (lRet:=DLVTAviso('SIGAWMS - AVISO', 'Concluir a Liberacao Produto: '+ cAviso , {'Sim', 'Nao'})==1)
      _cDoc:=sfDocSd3()			
		VTMSG("Aguarde...")
		Begin Transaction 
 	  	Tranf_AocWms(_cProduto,_cLocAt,_cEndOri,_cLocDe,_cEndDest,_cLote,_cLote,_nQuant)	
		End Transaction
		VTCLEAR  
		EndIf 

Return(.T.)


Static Function SaldSBF(Locde,cEndO)  //saldo no SBF E SB2
 Local nDoc:=0
 Local cObs:=""
 
IF fVldLocaliz(_cProduto)
	cAliasSBF:= GetNextAlias()
	 BeginSql Alias cAliasSBF  
	  SELECT isnull(SUM(BF_QUANT),0) AS BF_QUANT FROM %Table:SBF% WHERE BF_FILIAL='01' 
	  AND BF_PRODUTO=%exp:_cProduto%  AND BF_LOCAL=%exp:Locde% AND BF_LOCALIZ=%exp:cEndO% 
	  AND D_E_L_E_T_='' 
	 EndSql 
	dbSelectArea(cAliasSBF)  
	dbgotop()
	nDoc+=(cAliasSBF)->BF_QUANT
	dbSelectArea(cAliasSBF) 
	dbclosearea()
ELSE 
	cAliasSB2:= GetNextAlias()
	 BeginSql Alias cAliasSB2  
	  SELECT isnull(SUM(B2_QATU),0) AS B2_QATU FROM %Table:SB2% WHERE B2_FILIAL='01' 
	  AND B2_COD=%exp:_cProduto%  AND B2_LOCAL=%exp:Locde%
	  AND D_E_L_E_T_='' 
	 EndSql 
	dbSelectArea(cAliasSB2)  
	dbgotop()
	nDoc+=(cAliasSB2)->B2_QATU
	dbSelectArea(cAliasSB2) 
	dbclosearea()

ENDIF  

IF _nQuant>nDoc .AND. _nQuant>=1
  cObs+="Armz: "+ Locde+ " - " + cEndO +" Saldo : "+ ltrim(Transform(nDoc, "@R 999999.99")) + " Menor que Solicitada : " + LTRIM(Transform(_nQuant, "@R 999999.99"))
	VTAlert(cObs,"SIGAWMS - AVISO",.t.,3000) 
  Return .F. 
ENDIF

Return(.T.)

Static function fVerCQ(cDocPa)
Local lRet:=.F.    
Local cAliasSD3Cq := GetNextAlias()
Local cXCQ:=""  
Local nTotal:=0

 BeginSql Alias cAliasSD3Cq    

  SELECT SD3.D3_COD,SD3.D3_DOC,SD3.D3_QUANT, SD3.D3_TM,SD3.D3_XCQ,SD3.D3_XCODCQ
  
  FROM %Table:SD3% SD3 WHERE SD3.D3_FILIAL='01' 
  AND SD3.D_E_L_E_T_='' AND SD3.D3_CF IN ('PR0','PR1') AND SD3.D3_ESTORNO='' AND SD3.D3_DOC=%exp:cDocPa% 
EndSql 
dbSelectArea(cAliasSD3Cq) 
Count To nTotal
DBGOTOP()
cXCQ:= (cAliasSD3Cq)->D3_XCQ

 if nTotal=0
  //DLVTAviso('SIGAWMS - AVISO','Num.Pa Não Econtrada !')
  VTAlert("Num.Pa Não Econtrada !","SIGAWMS - AVISO",.t.,3000)
  _cStatus:=Space(15)
 Else
   DO CASE
		CASE cXCQ== "A" 	// aprovado
			lRet:=.F. // PRODUTO APROVADO NAO PODE SER BLOQUEADO
			VTAlert("***********************"+"  Documento Aprovado, Não faz bloqueio de Saldo !!!   "+"*************************","SIGAWMS - AVISO",.t.,4000) 
			_cStatus:="Aprovado"
		CASE cXCQ== "R"
	     	_cStatus:="Reprovado"
	     	lRet:=.T.
	     	
		OTHERWISE
	     VTAlert("***********************"+"  Aguardando Inspeção CQ.     " +"************************* ","___SIGAWMS - AVISO___",.t.,4000) 
     	  _cStatus:="Aguardando CQ"
	ENDCASE

 Endif 
dbclosearea() 
Return(lRet) 

******************************************************************************************************************************************************
Static Function fVldBarras(cBarras)
******************************************************************************************************************************************************
Local lResp:=.f.
Local cProd:=SubStr(cBarras,1,15) 
Local nquant:=SubStr(cBarras,16,15)
Local cObs:=""


if  Posicione("SB1",1,xFilial("SB1")+cProd,"B1_COD")==cProd
  	lResp:=.t.    
	_cProduto := cProd
 Else 
	    cObs+=" Codigo Invalido!"
        DLVTAviso('SIGAWMS - AVISO', cObs)		    	    
Endif 

Return(lResp)    



*************************************************************************************************************************************************************
Static Function fValArmz(cLocal)
*************************************************************************************************************************************************************
Local lRet:=.F.     
Local cObs:=""
DBSelectArea('SX5')
DBSetOrder(1)
IF !DBSeek(xFilial('SX5')+ "74" + cLocal )
	DLVTAviso('SIGAWMS - AVISO', 'O Armazem '+Alltrim(cLocal)+' nao existe.')
	lRet:=.F.
ELSE 
 IF cLocal<>"20"
   lRet:=.T.
 ELSE
  	DLVTAviso('SIGAWMS - AVISO', 'Armazem de Processo, Usar rotina de pagamento !')
 Endif   
endif
Return(lRet)


Static Function ValEnd(_cLocal,_cEnd)
Local lRet:=.T.    
Local cObs:=""
DBSelectArea('SBE')
DBSetOrder(1)
IF !DBSeek(xFilial('SBE')+_cLocal+_cEnd) 
  	
   	cObs+='O endereco '+Alltrim(_cEnd)+' nao existe.!'
      VTAlert(cObs,"SIGAWMS - AVISO",.t.,3000)
     
   Return (.F.)  
ENDIF
Return(lRet) 


Static Function sfDocSd3()
 Local nDoc:=1
 Local cDocs
 cAliasSD3:= GetNextAlias()
 BeginSql Alias cAliasSD3 
  SELECT isnull(MAX(D3_DOC),'000000000') AS D3_DOC FROM %Table:SD3% WHERE D3_FILIAL='01' 
  AND D_E_L_E_T_='' AND D3_CF IN ('DE4') AND LEFT(D3_DOC,3)='TR-' AND D3_ESTORNO=''
 EndSql 
dbSelectArea(cAliasSD3)  
dbgotop()
nDoc+=VAL(SUBSTR((cAliasSD3)->D3_DOC,4,5))
dbSelectArea(cAliasSD3) 
dbclosearea() 
cDocs:="TR-"+STRZERO(nDoc,5) 
Return(cDocs)


******************************************************************************************************************************************************
Static Function fSaldoSB2(cProduto,cLocal)
******************************************************************************************************************************************************
Local lResp:=.f.
Local cObs:=""
Local nSldDisp:=0


	if SB2->(dbSeek(xFilial("SB2") + cProduto + cLocal ))
		nSldDisp	:= SB2->(SaldoSb2())
		if (nSldDisp >= _nQuant )
			lret := .T.
		else
			cObs+=" Não existe saldo Disponivel no Armz.: "+cLocal
	      //DLVTAviso('SIGAWMS - AVISO', cDocPa + cObs,{'OK'})		    	    
	      VTAlert(cObs,"SIGAWMS - AVISO",.t.,3000)
		endif
	else
		lret := .F.
			cObs+=" Produto não esta no Armz.: "+cLocal
	      //DLVTAviso('SIGAWMS - AVISO', cDocPa + cObs,{'OK'})		    	    
	      VTAlert(cObs,"SIGAWMS - AVISO",.t.,3000)
	endif

return(lret)

***************************************************************************************************************************************
Static Function fVldLocaliz(cProd)
***************************************************************************************************************************************

Local lResp:=.f. 
//Local cObs:=""
//Local nquant:=SubStr(cBarras,16,15)
if  Posicione("SB1",1,xFilial("SB1")+cProd,"B1_LOCALIZ")=="S"
  	lResp:=.T.    
// Else 
//	     cObs :="Produto nao controla endereco !"
//        DLVTAviso('SIGAWMS - AVISO', cObs)		    	    
Endif 

Return(lResp) 

***************************************************************************************************************************************
Static Function Tranf_AocWms(cProduto,cArmOri,cEndOri,cArmDest,cEndDest,cLoteOri,cLoteDest,nVlr)	//Função de transferencia de endereços
***************************************************************************************************************************************
	Local cCodOri	:= 	cProduto												//	Produto Origem	(Codigo)
   Local cDescrOri	:= 	Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC") //	Produto Origem	(Descricao)
	Local cUmOri	:=	Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_UM")	//	Produto Origem	(Unid Medida)
	Local cAlmOri	:= 	cArmOri												//	Produto Origem	(Almoxarifado)
	Local cEndOri	:= 	cEndOri												//	Produto Origem	(Endereco)
	
	Local cCodDest	:=	cProduto												//	Produto Destino	(Codigo)
	Local cDescrDest:=	Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")	//	Produto Destino	(Descricao)
	Local cUmDest	:=	Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_UM")	//	Produto Destino	(Unid Medida)
	Local cAlmDest	:=	cArmDest												//	Produto Destino	(Almoxarifado)
	Local cEndDest	:= cEndDest												//	Produto Destino	(Endereco)
	
	Local cNumSerie	:= 	""							//	Produto	(Numero de Serie)
	Local cLote		:= 	cLoteOri							//	Produto	(Lote)
	Local cSLote	:= 	Space(06)								//	Produto	(Sub Lote)
	Local cValLote	:= 	ctod('')								//	Produto	(Validade do Lote)       
	Local nPotenc	:= 	0										//  Potencia
	Local nQtde		:= 	nVlr									//	Produto	(Quantidade do movimento)
	Local nQtde2	:=	0                                    //	Produto	(Quantidade do movimento na Segunda Unidade Medida)
	Local cEstorn	:= 	"N"								        //	Produto	(Se igual a S = Indica estorno)
	Local cSeq      := 	ProxNum()								//	Produto	(Sequencia utilizada pelo sistema)
	Local cLoteDest	:=	cLoteDest							//	Produto	(Lote Destino)
	Local cValLtDest:=	ctod('')								//  Produto (Validade Destino)
	Local cObserva:= 'Liberado CQ'	    


   
	Local aSepa  := {{_cDoc,dDataBase}}	//Criacao da 1a. linha do array com o documento e data
	Local cTexto := ""   
	Local cItemGrd:=""
	
	// Alimenta o array para execução do MsExecAuto 

	    
	IF !SB2->(DBSEEK(xFilial("SB2") + cCodOri + cArmDest ))      
	               CriaSB2( cProduto, cArmDest)
	ENDIF     
	
	
	lmsErroAuto	:= .F. 

    aAdd(aSepa,{	cCodOri		,;	//	Produto Origem	(Codigo)
			         cDescrOri	,;	//	Produto Origem	(Descricao)
						cUmOri		,;	//	Produto Origem	(Unid Medida)
						cAlmOri		,;	//	Produto Origem	(Almoxarifado)
						cEndOri		,;	//	Produto Origem	(Endereco)
						cCodDest	,;	//	Produto Destino	(Codigo)
						cDescrDest	,;	//	Produto Destino	(Descricao)
						cUmDest		,;	//	Produto Destino	(Unid Medida)
						cAlmDest	,;	//	Produto Destino	(Almoxarifado)
						cEndDest	,;	//	Produto Destino	(Endereco)
						cNumSerie	,;	//	Produto	(Numero de Serie)
						cLote		,;	//	Produto	(Lote)
						cSLote		,;	//	Produto	(Sub Lote)
						cValLote	,;	//	Produto	(Validade do Lote)       
						nPotenc		,;  //	Produto (Potencia)
						nQtde		,;	//	Produto	(Quantidade do movimento)
						nQtde2		,;	//	Produto	(Quantidade do movimento na Segunda Unidade Medida)
						cEstorn		,;	//	Produto	(Se igual a S = Indica estorno)
						cSeq		,;	//	Produto	(Sequencia)
						cLoteDest	,;	//	Produto	(Lote Destino)
						cValLtDest	,;  //  Produto (Validade Lote Destino) 
                  Space(03)   ,;  //  Item Grade
						cObserva   ,;  //OBSERVA Space(128)
					    "Liberado CQ"})		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Chamada da Rotina automatica para gravacao de dados	³
		|de transferencia modelo II - [tabela SD3] 				|
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		*/
		
		If Len(aSepa) > 1
			x_Area  := Alias()
			x_Rec   := Recno()
			x_Ind   := Indexord()
			
			MsExecAuto({|x,y| mata261(x,y)},aSepa,3)
			
			DbSelectArea(x_Area)
			DbSetOrder(x_Ind)
			DbGoto(x_Rec)
		EndIf
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Verifica se houve algum tipo de erro retornado pela	³
	|rotina automatica.										|
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	
	If  lmsErroAuto
     	DLVTAviso('SIGAWMS - ERRO', '!!! ERRO no Desbloqueio do Material !!!!')
      DisarmTransaction()  
		Return
	else
   	DLVTAviso('SIGAWMS', 'Concluido com sucesso !')	
	Endif              




