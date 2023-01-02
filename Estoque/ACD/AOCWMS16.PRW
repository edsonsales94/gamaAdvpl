#INCLUDE 'RWMAKE.CH'
#INCLUDE 'APVT100.CH'

User Function AOCWMS16()      
Private _OP  := Space(13)
Private _cProduto := Space(15)
Private _cLocal := "11"
Private _dFec:=GetMV("MV_ULMES")
Private nPos:=1 

//@ 01, 00 VTSay  PadR('Armazem : ' , VTMaxCol())
//@ 01, 13 VTGet _cLocal  Pict '@!' 	  VALID !Empty(_cLocal)


		
While .T.
	
	 DLVTCabec("Consulta Empenhos:",.F.,.F.,.T.)
  	 //@ 01, 00 VTSay PadR('Prod..:' , VTMaxCol()) 	 
//	 @ 03, 00 VTSay PadR('O.Pro.:' , VTMaxCol())     
@ 01, 00 VTSay 'Produto :'
@ 02, 00 VTGet _cProduto Pict '@!' 	VALID fVldBarras(_cProduto)
@ 03, 00 VTSay PadR('Ordem Produção :' , VTMaxCol())     
@ 04, 00 VTGet _OP   Pict '@!' VALID ( ValOP() )
	   

	VTREAD
	If (VTLastKey()==27)
		If (lRet:=DLVTAviso('', 'Deseja encerrar a Consulta ?', {'Sim', 'Nao'})==1)
			_OP	  := Space(13)
			_cProduto := Space(15)
        	Exit
		EndIf
	EndIf       
	
	IF !Empty(_cProduto) .or. !Empty(_OP) 
		If EndProcesso()  //fc que endereca o saldo do processo
		   _OP:= Space(13)
		   _cProduto := Space(15)
		Endif
		_OP	  := Space(13)
		_cProduto := Space(15)
	Endif
	
EndDo
Return(.T.)



Static Function ValOP()
Local lRet:=.T.
IF !Empty(_OP)
   dbselectarea("SC2")
   dbsetorder(1)
   dbseek(xfilial("SC2")+alltrim(_OP))
   if !SC2->(eof()) 
     IF len(alltrim(DTOS(SC2->C2_DATRF)))>0
      DLVTAviso('SIGAWMS',"Ordem de Produção Encerrada !!! Tente novamente.")
      lRet:=.F.
      _OP:=space(13)
     ENDIF 
   Else  
     DLVTAviso('SIGAWMS',"Ordem de Produção Invalida !!! Tente novamente."+_OP)
     lRet:=.T.
   Endif
ENDIF   
Return lRet



*************************************************************************************************************************************************
Static Function EndProcesso()
*************************************************************************************************************************************************
Local aCbEnd   := {}  //cabec da chamada da rotina aut
Local aItEnd   := {}  //itens da chamada da rotina aut
Local nItem    := 1

VtClearBuffer()
//If ! VTYesNo("Confirma Consulta: OP " +_OP +  " Prod.:" + _cProduto , .T.)
//	If IsTelnet() .and. VtModelo() == "RF"
//		VTKeyBoard(chr(20))
//	EndIf
//	Return .F.
//EndIf

VTMSG("Aguarde...")
vBaixaReg  := 0 
vBaixaAcum := 0 

Begin Transaction
Consulta()	
End Transaction
VTKeyBoard(chr(20))
Return (.T.)



*************************************************************************************************************************************************
Static Function Consulta()	
*************************************************************************************************************************************************

VtClear    
If !Empty(_cProduto).and.!Empty(_OP)
   DLVTAviso('SIGAWMS',"Favor preencher um dos campos!!! Tente novamente.") 
   vtclear()             
   Return
Endif 
aItens:={}
cCond:="D4_FILIAL=xFilial('SD4') "
cCond+=if(!Empty(_cProduto),".and. D4_COD = _cProduto ","")
cCond+=if(!Empty(_OP)   ,".and. D4_OP =_OP "    ,"")  
cCond+=" .and. D4_QUANT>0  .and. LEFT(D4_COD,3)<>'MOD'  "  

DbSelectArea("SD4")
DbSetOrder(01)
SET FILTER TO &cCond
DBGOTOP() 
Do While !eof()                     
 cKanban:=POSICIONE("SB1",1,xfilial("SB1")+SD4->D4_COD,"B1_XKANBAN")
 nSld:=SD4->D4_QTDEORI - EmpAlmox(SD4->D4_OP,SD4->D4_COD) //EMPENHOS PAGOS DO ITEM
 DbSelectArea("SD4") 
 IF nSld>0 // .and. cKanban<>"S"
  If (!Empty(_cProduto) .and. Empty(_OP))
   aHeader := {'OP','A Pagar','Empenho','Saldo Emp','Codigo','Local'}       
   AADD(aItens,{D4_OP ,nSld,D4_QTDEORI,D4_QUANT,D4_COD,D4_LOCAL})
   aSize   := {9,8,8,8,15,2}          
  ElseIf Empty(_cProduto).and.!Empty(_OP)
   aHeader := {'Codigo','A Pagar','Empenho','Saldo Emp','OP','Local'}           
   AADD(aItens,{D4_COD,nSld,D4_QTDEORI,D4_QUANT,D4_OP,D4_LOCAL})
   aSize   :={15,8,8,8,9,2}          
  endif 
 ENDIF
 DBSKIP()
enddo 
if len(aItens)>0
 nPos := VTaBrowse(0,0,VTMaxRow(),VTMaxCol(),aHeader,aItens,aSize,"U_conOPctrl",nPos) 
else
 DLVTAviso('SIGAWMS',"Todos os itens da Ordem de produçao Baixados!!") 
endif
SET FILTER TO 
vtclear()             
Return 



Static Function EmpAlmox(cOP,cCod)
Local lRet:=0
cAliasSD3:= GetNextAlias()
BeginSql Alias cAliasSD3 
 SELECT isnull(SUM(D3_QUANT),0) AS D3_QUANT FROM %Table:SD3% WHERE D3_FILIAL='01' 
 AND LEFT(D3_DOC,6)=%exp:left(alltrim(cOP),6)% AND D3_COD=%exp:left(alltrim(cCod),15)%
 AND D_E_L_E_T_='' AND D3_CF IN ('RE3','RE4') AND LEFT(D3_OBSERVA,5)='RQ/OP' AND D3_ESTORNO=''
EndSql 
dbSelectArea(cAliasSD3)  
dbgotop()
lRet:=(cAliasSD3)->D3_QUANT
dbSelectArea(cAliasSD3) 
dbclosearea() 
cAliasSD3:= GetNextAlias()
// PEGA OS SCRAPS DA OP PARA LIBERAR PAGAMENTO DO ITEM 
BeginSql Alias cAliasSD3 
 SELECT isnull(SUM(D3_QUANT),0) AS D3_QUANT FROM %Table:SD3% WHERE D3_FILIAL='01' 
 AND LEFT(D3_OP,11)=%exp:left(alltrim(cOP),11)% AND D3_COD=%exp:left(alltrim(cCod),15)%
 AND D_E_L_E_T_='' AND D3_CF='RE1' AND D3_ESTORNO=''
EndSql 
dbSelectArea(cAliasSD3)  
dbgotop() 
lRet:=lRet - (cAliasSD3)->D3_QUANT
dbSelectArea(cAliasSD3) 
dbclosearea()
Return(lRet) 





*************************************************************************************************************************************************
User Function conOPctrl(modo,nElem,nElemW)
*************************************************************************************************************************************************
/*
If modo == 1 
     VtAlert('Top')
   ElseIf Modo == 2 
     VtAlert('Bottom')
Endif 
*/     
If VTLastkey() == 27
    //VtAlert('sair')
    VTBeep(3)
    return 0       
 elseIf VTLastkey() == 13      
    //VtAlert(SBF->BF_PRODUTO)
    VtBeep(1)
    return 2          
EndIf     
Return 2


******************************************************************************************************************************************************
Static Function fVldBarras(cBarras)
******************************************************************************************************************************************************
Local lResp:=.f.
Local cProd:=SubStr(cBarras,1,15) 
Local nquant:=SubStr(cBarras,16,15)
Local cObs:=""

If Empty(cBarras)     
 _cProduto := Space(15)
 Return(.t.)
Endif 


if  Posicione("SB1",1,xFilial("SB1")+cProd,"B1_COD")==cProd
  	lResp:=.t.    
	_cProduto := cProd
 Else 
   cObs+=" Codigo Invalido !"
   DLVTAviso('SIGAWMS', cObs)		    	    
   _cProduto := Space(15)
Endif 

Return(lResp) 