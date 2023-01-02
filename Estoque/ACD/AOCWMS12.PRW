#INCLUDE 'RWMAKE.CH'
#INCLUDE 'APVT100.CH'

User Function AOCWMS12()      
Local cBarras      := Space(28)
Private _cEndOri  := Space(15)
Private _cLote	  := Space(11)
Private _cProduto := Space(15)
Private _cLocal	  := Space(2)
Private aEnd      := {}
Private cInd_Cod  :=" "
Private _cProd_Ind:= Space(25)
//DLVTCabec("Consulta de Endereco: " ,.F.,.F.,.T.)
//@ 01, 00 VTSay  PadR('Armazem : ' , VTMaxCol())
//@ 01, 13 VTGet _cLocal  Pict '@!' 	  VALID !Empty(_cLocal)

VTREAD


// DBSelectArea('SX5')
// DBSetOrder(1)
// IF !DBSeek(xFilial('SX5')+ "74" + _cLocal )
// 	DLVTAviso('SIGAWMS', 'O Armazem '+Alltrim(_cLocal)+' nao existe.')
// 	Return (.F.)
// Endif       
		
While .T.
	
	DLVTCabec("Consulta Endereco/Armaz",.F.,.F.,.T.)
  	   @ 01, 00 VTSay PadR('Produto :' , VTMaxCol()) 	 
	   @ 03, 00 VTSay PadR('Endereco :' , VTMaxCol())
	   @ 05, 00 VTSay PadR('Armazem.:' , VTMaxCol())	

  	  //@ 01, 07 VTGet _cProduto  Pict '@!' 	//VALID !Empty(_cProduto) .AND. !Empty(Posicione("SB1",1,xFilial("SB1")+_cProduto,"B1_COD"))
      @ 02, 00 VTGet cBarras    Pict '@!' 	VALID fVldBarras(cBarras)
	   @ 04, 00 VTGet _cEndOri   Pict '@!'   
	   @ 05, 09 VTGet _cLocal	  Pict '@!' VALID  sfValarmz(_cLocal)
	VTREAD

	If (VTLastKey()==27)
		If (lRet:=DLVTAviso('', 'Deseja encerrar a Consulta ?', {'Sim', 'Nao'})==1)
			_cLote	  := Space(11)
			_cProduto := Space(15)
            _cEndOri  := Space(15)	
            cBarras   := Space(28)
            _cLocal :=	Space(2)		
			Exit
		EndIf
	EndIf       
	
	IF !Empty(_cProduto) .or. !Empty(_cLote) .or. !Empty(_cEndOri)
		If EndProcesso()  //fc que endereca o saldo do processo
			_cLote	 := Space(11)
			_cProduto := Space(15)
         _cEndOri  := Space(15)			
         cBarras   := Space(28)
         _cLocal   := Space(2)
		Endif
         _cLote	 := Space(11)
         _cProduto := Space(15)
         _cEndOri  := Space(15)		 
         cBarras   := Space(28)	
	Endif
	
EndDo
Return(.T.)

*************************************************************************************************************************************************
Static Function EndProcesso()
*************************************************************************************************************************************************
// Local aCbEnd   := {}  //cabec da chamada da rotina aut
// Local aItEnd   := {}  //itens da chamada da rotina aut
// Local nItem    := 1

If !Empty(_cEndOri) 
   Sbe->(DbSetOrder(01))
   IF !Empty(_cLocal) .AND.  !Sbe->(DBSeek(xFilial('SBE') + _cLocal + _cEndOri))
     DLVTAviso('SIGAWMS', 'O endereco Ori.'+Alltrim(_cEndOri)+' no Armz'+ _cLocal+' nao existe.!')   
     Return (.F.)
    ELSE   
      If Found().and. SBE->BE_STATUS == '3'//STATUS=3 ->BLOQUEADO	 
         DLVTAviso('SIGAWMS', 'O endereco '+Alltrim(_cEndOri)+' Bloqueado.!')   		
      Endif 
   Endif
Endif 

If !Empty(_cProduto)
   Sb1->(DbSetOrder(01))
   IF !Sb1->(DBSeek(xFilial('SB1') + _cProduto))
     DLVTAviso('SIGAWMS', 'O Prod.:'+Alltrim(_cProduto)+' nao existe.!')   
     Return (.F.)
   Endif
Endif 

VtClearBuffer()
//If ! VTYesNo("Confirma Consulta:Ori." +_cEndOri+" Lt:"+_cLote+ " ?"  , "Prod.:" + _cProduto , .T.)
//If ! VTYesNo("Consulta do Prod.:" + _cProduto ,"End.:" +_cEndOri,.T.)
	If IsTelnet() .and. VtModelo() == "RF"
		VTKeyBoard(chr(20))
	EndIf
  //	Return .F.
//EndIf

VTMSG("Aguarde...")
vBaixaReg  := 0 
vBaixaAcum := 0 

Begin Transaction
Consulta(_cLocal,_cEndOri,_cProduto,_cLocal)	
End Transaction
VTKeyBoard(chr(20))
Return (.T.)
*************************************************************************************************************************************************
Static Function Consulta(_cLocal,_cEndOri,_cProduto,_cLocal)	
*************************************************************************************************************************************************
VtClear    
If (!Empty(_cProduto).and.Empty(_cLocal).and.Empty(_cEndOri)).or.(!Empty(_cProduto).and.!Empty(_cLocal).and.Empty(_cEndOri))
   // aFields := {"BF_LOCALIZ","BF_QUANT","BF_LOTECTL","BF_PRODUTO"}
   // aHeader := {'Endereço','Quant.','Lote',"Produto"}       
   //aSize   := {10,8,11,9}          
	aHeader := {'Endereço',"Armaz",'Quant.'}       
   aFields := {"BF_LOCALIZ","BF_LOCAL","BF_QUANT"}
	aSize   := {10,3,9}       
   ElseIf Empty(_cProduto).and.!Empty(_cLocal).and.Empty(_cEndOri)
    aFields := {"BF_LOCALIZ","BF_QUANT","BF_LOCAL","BF_PRODUTO"}
    aHeader := {'Endereço','Quant.','Armaz','Produto'}           
	aSize   := {9,8,9,11}          
   ElseIf (Empty(_cProduto).and.Empty(_cLocal).and.!Empty(_cEndOri)).or.(Empty(_cProduto).and.!Empty(_cLocal).and.!Empty(_cEndOri))
    aFields := {"BF_PRODUTO","BF_LOCAL","BF_QUANT"}
    aHeader := {'Codigo','Armaz','Quant.'}
    aSize   := {15,3,9}          
   ElseIf !Empty(_cProduto).and.Empty(_cLocal).and.Empty(_cEndOri)
	// aSize   := {15,9,9}          
      //aFields := {"BF_QUANT","BF_PRODUTO","BF_LOCALIZ","BF_LOTECTL"}
	  // aHeader := {'Quant.','Produto',"Endereço",'Lote'}               
    // aSize   := {8,9,9,11}          
	aHeader := {'Endereço','Armaz','Quant.'}       
   aFields := {"BF_LOCALIZ","BF_LOCAL","BF_QUANT"}
	aSize   := {10,3,9}          
    
   Else
    aFields := {"BF_PRODUTO","BF_QUANT","BF_LOCALIZ","BF_LOTECTL"}
    aHeader := {'Produto','Quant.',"Endereço",'Lote'}           
	aSize   := {8,8,9,11}          
Endif 



//_cProduto
//_cLote  
//_cEndOri
DbSelectArea("SBF")
DbSetOrder(01)
cCond:="BF_FILIAL=xFilial('SBF') "
cCond+=if(!Empty(_cLocal),".and. BF_LOCAL=_cLocal ","")
cCond+=if(!Empty(_cProduto),".and. BF_PRODUTO = _cProduto ","")
// cCond+=if(!Empty(_cLote)   ,".and. BF_LOTECTL =_cLote "    ,"") 
cCond+=if(!Empty(_cEndOri) ,".and. BF_LOCALIZ =_cEndOri "  ,"")
SET FILTER TO &cCond
DBGOTOP()
nRecno := VTDBBrowse(0,0,15,25,"SBF",aHeader,aFields,aSize,"U_conctrl")
//nRecno := VTDBBrowse(0,0,7,15,"SBF",aHeader,aFields,aSize,'U_testectrl')
SET FILTER TO 
vtclear()             
Return 
*************************************************************************************************************************************************
User Function conctrl(modo,nElem,nElemW)
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
Endif 

Return(lResp) 

Static Function sfValarmz(_cArmazen)
	Local lRet:=.T.
	DBSelectArea('SBE')
	DBSetOrder(1)
   If !Empty(_cArmazen)
      IF !DBSeek(xFilial('SBE')+_cArmazen)
         DLVTAviso('SIGAWMS', 'Esse Armazen '+Alltrim(_cArmazen)+' nao existe.!')
         Return (.F.)
      ENDIF
   EndIf
Return(lRet)
