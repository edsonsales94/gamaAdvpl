#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'APVT100.CH'

user function AOCWMS17()
Local x
Private _cProduto := Space(15)
Private _cEnd   := SPACE(15) 
Private _cLocal := SPACE(2)
Private _cLote  := SPACE(10)
Private _nQtde   :=0
Private _nSald 
Private nPos:=1 
Private aHeader := {'Doc',"Saldo" ,'Cod','Local','Numseq','Ser','Clifor','loja'}      
Private aSize   := {9    ,8       ,15   ,2      ,6       ,3    ,8       ,2}    
Private aItens   

DLVTCabec("Endereçar Produtos:",.F.,.F.,.T.)
@ 01, 00 VTSay PadR('Local..:' , VTMaxCol())
@ 01, 07 VTGet _cLocal  Pict '@!' Valid (Vazio())

VTREAD 

DBSelectArea('SX5')
DBSetOrder(1)
IF !DBSeek(xFilial('SX5')+ "74" + _cLocal )
	DLVTAviso('SIGAWMS', 'O Armazem '+Alltrim(_cLocal)+' nao existe.')
	Return .f. 
Endif       

While .T.
	 aItens  :={}
	 _nSald := 0
	 DLVTCabec("Endereçar Produtos:",.F.,.F.,.T.)
  	 @ 01, 00 VTSay PadR('Prod..:' , VTMaxCol()) 	 
	 @ 02, 00 VTSay PadR('End...:' , VTMaxCol())	
	 @ 03, 00 VTSay PadR('Lote..:' , VTMaxCol())
     @ 04, 00 VTSay PadR('Qtde..:' , VTMaxCol())

  	 @ 01, 07 VTGet _cProduto Pict '@!' VALID fVldBarras(_cProduto)
	 @ 02, 07 VTGet _cEnd  Pict '@!' VALID (ValEnd(_cLocal,_cEnd))
	 @ 03, 07 VTGet _cLote  Pict '@!' 
	 @ 04, 07 VTGet _nQtde  Pict '@R 999999.99' VALID(_nQtde>0 .and. Consulta() ) 
     
     
//	VTREAD

		If (lRet:=DLVTAviso('', 'Confirma o Enderecamento ?', {'Sim', 'Nao'})==1) .and. _nQtde>0  
		  FOR X:=1 TO LEN(aItens)
		    IF aItens[X,2]<_nQtde
		      lRet2:=U_fSd3265I(3 ,_cProduto , aItens[X,5] , aItens[X,1] , _cLocal , _cEnd,_cLote,aItens[X,6] ,aItens[X,7] ,aItens[X,8] ,aItens[X,2])
		      if lRet2 
               DLVTAviso('Enderecamento', 'Produto nao foi enderecado !!')
               X:=LEN(aItens)+1
             ENDIF  
		      _nQtde:=_nQtde-aItens[X,2]
		    ELSE  
		      lRet2:=U_fSd3265I(3 ,_cProduto , aItens[X,5] , aItens[X,1] , _cLocal , _cEnd,_cLote,aItens[X,6] ,aItens[X,7] ,aItens[X,8] , _nQtde)
		      if !lRet2 
               DLVTAviso('Enderecamento', 'Produto enderecado com sucesso!!')
            ELSE
               DLVTAviso('Enderecamento', 'Produto nao foi enderecado !!')
            ENDIF 
		      X:=LEN(aItens)+1
		    ENDIF
		  NEXT
		else
		  Exit
		EndIf
	    
	
	_cProduto := Space(15)
	_cEnd  := SPACE(15)
	_cLote  := SPACE(10)
	_nQtde  :=0 
EndDo
return
 

*************************************************************************************************************************************************
User Function conDActrl(modo,nElem,nElemW)
*************************************************************************************************************************************************
 
If VTLastkey() == 27
    //VtAlert('sair')
    VTBeep(3)  
    return 0       
 elseIf VTLastkey() == 13 
    VtBeep(1)  
    return 1       
EndIf     
Return 2


*****************************************************************************************************************
User Function fSd3265I(pMov,pProd,pNumSeq,pDoc,pLocal,pLocaliz,pLote,pSerie,pClifor,pLoja,nQuant)
*****************************************************************************************************************
 Local nModAux	:= nModulo
 If Posicione("SB1",1, xFilial("SB1")+pProd, "B1_LOCALIZ") <> "S"
   Return 
 Endif 
 lMsHelpAuto := .T.  // se .t. direciona as mensagens de help
 lMsErroAuto := .F.
 nModulo := 4 
		// Rotina Automatica de Endereçamento
		_aCab := {} 
		_aItem:= {}
        _aItensSDB:= {} 
        //Cabeçalho com a informação do item e NumSeq que sera endereçado.
        _aCab := {{"DA_PRODUTO" ,pProd,Nil},;	   
            {"DA_NUMSEQ"  ,pNumSeq,Nil}}
        //Dados do item que será endereçado
        _aItem := {{"DB_ITEM"	  ,"0001"	      ,Nil},;                  
           {"DB_ESTORNO"  ," "	      ,Nil},;                  
           {"DB_LOCALIZ"  ,_cEnd    ,Nil},; 
           {"DB_DATA"	  ,dDataBase    ,Nil},;                  
           {"DB_QUANT"  ,nQuant                  ,Nil}}       
        aadd(_aItensSDB,_aItem)
        //Executa o endereçamento do item

        MSExecAuto({|X,Y,Z|MATA265(X,Y,Z)}, _aCab, _aItensSDB, 3)  
         
         
		
	  x_Area  := Alias()
	  x_Rec   := Recno()
	  x_Ind   := Indexord()
		  DbSelectArea(x_Area)
	  DbSetOrder(x_Ind)
	  DbGoto(x_Rec) 
	  If lMsErroAuto
		Mostraerro()
	  endif

 nModulo := nModAux
Return(lMsErroAuto)	   




Static Function ValEnd(_cLocal,_cEnd)
Local lRet:=.T.
DBSelectArea('SBE')
DBSetOrder(1)
IF !DBSeek(xFilial('SBE')+_cLocal+_cEnd) 
   DLVTAviso('SIGAWMS', 'O endereco '+Alltrim(_cEnd)+' nao existe.!')   
   Return (.F.)  
ENDIF
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
   DLVTAviso('SIGAWMS', " Codigo Invalido !")		    	    
Endif 

Return(lResp) 

*************************************************************************************************************************************************
Static Function Consulta()	
*************************************************************************************************************************************************
//PREENCHER OS SALDOS A ENDEREÇAR DO PRODUTO
cAliasSDA:= GetNextAlias()
BeginSql Alias cAliasSDA 
  SELECT DA_FILIAL, DA_PRODUTO, DA_LOCAL, DA_NUMSEQ, DA_DOC, DA_SERIE, DA_CLIFOR, DA_LOJA,DA_SALDO 
  FROM %Table:SDA%  SDA WHERE DA_FILIAL=%xFilial:SDA% 
  AND DA_PRODUTO=%exp:_cProduto% AND DA_SALDO>0 AND DA_LOCAL=%exp:_cLocal% AND DA_LOTECTL=%exp:_cLote%
  AND SDA.%NotDel% 
EndSql 
IF POSICIONE("SB1",1,XFILIAL("SB1")+_cProduto ,"B1_RASTRO")=="L"   
  if  alltrim(len(_cLote))==0   
   DLVTAviso('SIGAACD', 'Produto Utiliza lote!!') 
   Return(.F.)
  endif
ENDIF
dbSelectArea(cAliasSDA)  
dbgotop()
do While !eof()
  aadd(aItens,{DA_DOC,DA_SALDO,DA_PRODUTO, DA_LOCAL, DA_NUMSEQ,  DA_SERIE, DA_CLIFOR, DA_LOJA})
  _nSald += DA_SALDO 
  dbskip()
Enddo
dbSelectArea(cAliasSDA) 
dbclosearea()
If LEN(aItens)=0 .or. _nSald<_nQtde
  DLVTAviso('SIGAACD', iif(_nSald<_nQtde,'Quantidade maior que o saldo a distribuir!! Saldo: '+str(_nSald,10,3),'Produto sem Saldos a Endereçar!!'))
  _nQtde:=0
  Return(.F.)
Endif
Return(.T.) 