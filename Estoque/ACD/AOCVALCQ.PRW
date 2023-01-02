#INCLUDE 'RWMAKE.CH'
#INCLUDE 'APVT100.CH'    


//--------------------------------------------------------------
/*

@Rotina Validação do CQ                         
@return xRet Return Description                                 
@author Ricky Moraes - ricky.moraes@gamaitaly.com.br
@since 08/07/2019
/*/                                                             
//--------------------------------------------------------------


User Function AOCVALCQ()    
     
Private _cDocPa     := Space(09)
Private _cProduto := Space(15)
Private _cDescricao := Space(40)
Private _cUsername:= SUBSTR (UsrFullName(__cUserID),1,15)
Private _nQuant:=0
Private _cStatus:="" 
Private _cCodCausa:=space(4) 
Private _cHoraPA:=""
Private _cOperador:=""
Private _cLocaliz:=""
Private _cObs:=""
Private _cTurno:=""
Private _dDataPa:=AVCTOD("  /  /  ") 
Private _cDescCausa:=""



VTClearBuffer() 
//DLVTAviso(chkFile("ZTQ"))

DLVTCabec("Controle de Material C.Q. " ,.F.,.F.,.T.)
@ 01, 00 VTSay 'Num.Pa :' VTGet _cDocPa  Pict '@!A'  	VALID !Empty(_cDocPa) .AND. fVldDocPa(_cDocPa) 
VTREAD
	
@ 02, 00 VTSay 'Cod.Prod: '  + _cProduto  
@ 03, 00 VTSay 'Descri. : '  + _cDescricao 
@ 04, 00 VTSay 'Quant.  : ' + Transform(_nQuant, "@R 999999.99") 
VTPAUSE      
VTREAD
     
@ 06, 00 VTSay 'Status  : ' + _cStatus 
VTREAD  
VTPAUSE  


 	If (VTLastKey()==27)
		If (lRet:=DLVTAviso('SIGAWMS - AVISO', 'Deseja encerrar  ?', {'Sim', 'Nao'})==1)
			return
		EndIf
	EndIf  
  
If (lRet:=DLVTAviso('SIGAWMS - AVISO', 'Controle de Material', {'Aprovar', 'Reprovar'})==1)
	_cStatus:="Aprovado"
else
	_cStatus:="Reprovado"
EndIf    
@ 06, 00 VTSay PadR('                        ' , VTMaxCol())
@ 06, 00 VTSay 'Status  : ' + _cStatus   
	VTREAD 

IF _cStatus == "Reprovado"
   @ 07, 00 VTSay 'Cod.Causa/Defeito : ' VTGet  _cCodCausa Pict '@!A'  VALID !Empty(_cCodCausa) .AND. fValCodCQ(_cCodCausa)
	VTREAD  
ENDIF
IF _cStatus == "Aprovado" .AND. fVerLogCQ(_cDocPa)
   @ 07, 00 VTSay 'Cod.Aprovacao : ' VTGet  _cCodCausa Pict '@!A'  VALID !Empty(_cCodCausa) .AND. fValCodCQ(_cCodCausa)
	VTREAD  
ENDIF



If (lRet:=DLVTAviso('SIGAWMS - AVISO', 'Salvar alteração ?', {'Sim', 'Não'})==1)
	//Salvar movimento
	fUpdSd3Cq(_cDocPa,_cStatus,_cCodCausa,_cUsername)
EndIf  
    

return
         
******************************************************************************************************************************************************
Static Function fVldDocPa(cDocPa)
******************************************************************************************************************************************************
Local lResp:=.f.
Local cObs:=""
Local nTotal:=0

Local cAliasSD3ckPa:= GetNextAlias()

 BeginSql Alias cAliasSD3ckPa    

  SELECT SD3.D3_COD,SD3.D3_DOC,SD3.D3_QUANT, SD3.D3_TM,SD3.D3_NUMSEQ,SD3.D3_IDENT,SD3.D3_USUARIO,SD3.D3_XHORA,SD3.D3_OBSERVA,D3_XCQ,D3_XCODCQ,D3_XUSERCQ,
  SD3.D3_EMISSAO,SD3.D3_LOCALIZ,
    IIF(SD3.D3_XHORA>='17:48','2o. TURNO','1o. TURNO') TURNO 
  
  FROM %Table:SD3% SD3 WHERE SD3.D3_FILIAL='01' 
  AND SD3.D_E_L_E_T_='' AND SD3.D3_CF IN ('PR0','PR1') AND SD3.D3_ESTORNO='' AND SD3.D3_DOC=%exp:cDocPa%
 
EndSql 
dbSelectArea(cAliasSD3ckPa) 
Count To nTotal 
dbgotop()

IF nTotal>0

		_cProduto := (cAliasSD3ckPa)->D3_COD
		_nQuant := (cAliasSD3ckPa)->D3_QUANT
		_cDescricao := left(Posicione("SB1",1,XFILIAL("SB1")+SC2->C2_PRODUTO,"B1_XDESCNF"),40)   
		_dDataPa:=STOD((cAliasSD3ckPa)->D3_EMISSAO)
		_cHoraPA:=(cAliasSD3ckPa)->D3_XHORA
		_cOperador:=(cAliasSD3ckPa)->D3_USUARIO
		_cLocaliz:=(cAliasSD3ckPa)->D3_LOCALIZ
		_cObs:=(cAliasSD3ckPa)->D3_OBSERVA
		_cTurno:=(cAliasSD3ckPa)->TURNO
	
		

	
	   
	 DO CASE
		CASE (cAliasSD3ckPa)->D3_XCQ=="A"
		_cStatus :="Aprovado"
		CASE (cAliasSD3ckPa)->D3_XCQ=="R"
		_cStatus :="Reprovado"
	OTHERWISE
		_cStatus :="Aguardando"
	ENDCASE
  
	  	lResp:=.t.    			

ELSE 
	    cObs+=" Num.PA nao Encontrado !!!"
       DLVTAviso('SIGAWMS - AVISO', cDocPa + cObs,{'OK'})
      _cProduto := ""
		_nQuant := 0
		_cDescricao := ""	    	    
		_cStatus:=""
ENDIF 
dbclosearea()
	
Return(lResp)




*****************************************************************************************************************************************************
Static Function fUpdSd3CQ(cDocPa,cStatus,cCodCausa,cUsername)
******************************************************************************************************************************************************
LOCAL lMsErroAuto := .F. 
LOCAL cQuery := ""
Local cObs,cAviso:=""
Local nTotal:=0
Local nStatus:=0 
Local lEmail:=.F.




Begin Transaction  


cQuery := "UPDATE SD3010 SET D3_XCQ ='"+ SUBSTR(cStatus,1,1)+"' " + ", D3_XCODCQ='"+(cCodCausa)+"' ,D3_XUSERCQ='"+ cUsername+"'"                        
cQuery += " WHERE D3_DOC ='"+ALLTRIM(cDocPa)+"'  AND D3_FILIAL ='01' AND D_E_L_E_T_='' AND D3_CF IN ('PR0','PR1') AND D3_ESTORNO=''"

nStatus := TCSQLExec(cQuery) 
  
fGravaZTQ(_cProduto,SUBSTR(cStatus,1,1),cDocPa,_nQuant,_cCodCausa)

End Transaction 

  If nStatus < 0
   DLVTAviso("TCSQLError() " + TCSQLError())
  Else
 IF SUBSTR(cStatus,1,1)=="R"
 
     lEmail:=U_fAvisoRepCq(cStatus,Dtoc(DATE()),_cDescricao,_cProduto,DTOC(_dDataPA),cDocPa,_cDescCausa,_cTurno,_cHoraPa,_cOperador,_cLocaliz,_cObs,cUsername,cValToChar(_nQuant))
     IF lEmail
      VTAlert("Email Enviado para CQ","SIGAWMS - AVISO",.t.,3000)
     Endif
   ELSE
	  DLVTAviso("SIGAWMS - AVISO", "Salvo com Sucesso !" ) 
  	ENDIF
   
  endif

	
Return() 

Static Function fGravaZTQ(cCod,cCQ,cNumDoc,nQtd,cCodCQ)        
    Local aArea := GetArea()
    
    if cCodCQ==space(4)
    cCodCQ:='0000'
    end
     
    //Abrindo a tabela de produtos e setando o índice
    DbSelectArea('ZTQ')
    ZTQ->(DbSetOrder(1)) //ZTQ_FILIAL, ZTQ_DATA, ZTQ_HORA
    ZTQ->(DbGoTop())
     
    //Iniciando a transação, tudo dentro da transação
    Begin Transaction
        // Inclusão ZTQ
			DbSelectArea("ZTQ")
			RecLock("ZTQ", .T.)	
			ZTQ->ZTQ_FILIAL:= xFilial("ZTQ")	
			ZTQ->ZTQ_DATA:=DDATABASE
			ZTQ->ZTQ_HORA:=TIME()
			ZTQ->ZTQ_COD:=cCod
			ZTQ->ZTQ_CQ:=cCQ
			ZTQ->ZTQ_DOC:=cNumDoc
			ZTQ->ZTQ_QUANT:=nQtd
			ZTQ->ZTQ_CODCQ:=cCodCQ
			ZTQ->ZTQ_USERCQ:=_cUsername
			MsUnLock() // Confirma e finaliza a operação
    End Transaction
    RestArea(aArea)
Return       

Static Function fValCodCQ(cCodCausa)
Local lRet:=.F.
Local cAviso:=""
DBSelectArea('ZTC')
DBSetOrder(1)
IF !DBSeek(xFilial('ZTC')+cCodCausa) 
   
   	cAviso+='Codigo de Causa/Aprovacao : '+Alltrim(cCodCausa)+' não cadastrado!'
  		_cDescCausa:=""
      VTAlert(cAviso,"SIGAWMS - AVISO",.t.,3000)
else  
   lRet:=.T. 
  	_cDescCausa:= cCodCausa + ' - ' + ZTC->ZTC_DESC
ENDIF
Return(lRet) 

Static Function fVerLogCQ(cDocPA)
Local lRet:=.F.
Local cAviso:=""
DBSelectArea('ZTQ')
DBSetOrder(2)
IF DBSeek(xFilial('ZTQ')+cDocPA) 
    lRet:=.T.  //existe log cadastado  	
ENDIF
Return(lRet) 

    

