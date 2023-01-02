#INCLUDE 'RWMAKE.CH'    
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APVT100.CH'   


/*
  Descrição:  Endereçar produtos por 3 metodos diferentes
  Uso:  Modulo ACD para endereçar produtos
  Desenvolvedor: Ricky Moraes
  Data: 10/03/2020
*/
******************************************************************************************************************************************************
User Function AOCEND()                                                                                                                                
******************************************************************************************************************************************************
Local nOpc

	VTCLear()
	@ 0,0 VTSay PadR('Selecione:' , VTMaxCol())  
	nOpc:=VTaChoice(1,0,3,VTMaxCol(),{'Endereçar Produto','Sld a Enderecar','Distr. Auto'}) 
	VtClearBuffer()
	If nOpc == 1
	   AOCEND1()// Endereçar Produto Simples e por Documento
	ElseIf nOpc == 2
  		AOCEND2()  //Cons. Sld Enderecar
	ElseIf nOpc == 3
  		AOCEND3() //Distr. Automaticamente
	EndIf

Return NIL


******************************************************************************************************************************************************
Static Function AOCEND3()                                                                                                                             
******************************************************************************************************************************************************
Local nReg,Z :=0
Private cLocal	  := "11" 
Private cEnd  := Space(15)
Private aSaldoItens:={}


acab :={"Codigo","Documento","Saldo"}
aSize   := {15,9,10}                                  
aSaldoItens :={}

	VTCLear()
	VtClearBuffer()

	DLVTAviso('SIGAWMS - AVISO','Serão endereçados somente o ARMZ 11, Por meio do Endereçamento Automatico. ')
	nReg:= fConsSDA(cLocal)

	if nReg>0
	
	DLVTCabec("Enderecamento AUTO..",.F.,.F.,.T.)   
	 @ 01, 00 VTSay PadR('Local.:' + cLocal , VTMaxCol()) 	 	
  	 @ 02, 00 VTSay PadR('End...:' , VTMaxCol())
	 @ 02, 08 VTGet cEnd  Pict '@!' VALID fValEnd(cLocal,cEnd).and. !Empty(cEnd)
	 
	VTRead  



	If VTYesNo("Foram encontados  " + str(nReg,10,2) + ' registros.    '+' Endereco: ' +cEnd   ,"Confirma Enderecamento ?")	 	
	  	//npos := VTaBrowse(2,0,,,aCab,aSaldoItens,aSize,'u_uBrowsectrl',nPos) 
	VTMsg("Aguarde...") //'Aguarde...'
	  	FOR Z:=1 TO nReg 
	  		sfMATA265(aSaldoItens[Z,1] , cLocal , aSaldoItens[Z,6] , aSaldoItens[Z,2] , aSaldoItens[Z,3],cEnd,.F. ) //DA_PRODUTO, DA_LOCAL, DA_NUMSEQ, DA_DOC, SALDO  , destino
         //*campos da array *///DA_PRODUTO, DA_DOC,DA_SALDO,DA_LOCAL,DA_NUMSEQ   

	  	NEXT 
	  	DLVTAviso('SIGAWMS - AUTO','Todos os produtos do ARMZ ' + cLocal + ' foram Endereçados com SUCESSO!')
	else
	 return
	endif

	else
	  DLVTAviso('SIGAWMS - AUTO','Não existe produtos com Saldos a Endereçar neste ARMZ.')
	endif
	 

return

******************************************************************************************************************************************************
Static Function AOCEND2()       // consulta saldo por lista                                                                                           
******************************************************************************************************************************************************
Private cLocal	  := "11" 
Private aSaldoItens:={}
Private cEnd  := Space(15) 
Private nQtde	:=0 

acab :={"Codigo","Documento","Saldo","Posicoes - Qtd."}
aSize   := {15,9,10,40}                                  
nPos := 0
aSaldoItens :={}


	VTCLear()
	VtClearBuffer()
	
	DLVTCabec("Produto a Enderecar:",.F.,.F.,.T.)   
	@ 01, 00 VTSay PadR('Local.:', VTMaxCol()) 
   @ 01, 08 VTGet cLocal Pict '@!' VALID !Empty(cLocal) .and. fValLocal(cLocal) 
  
	VTRead  
	if fConsSDA(cLocal)>0
	  //	npos := VTaBrowse(2,0,15,30,aCab,aSaldoItens,aSize,'ftestectrl',nPos) 
	  	npos := VTaBrowse(2,0,,,aCab,aSaldoItens,aSize,'u_uBrowsectrl',1)
	  IF nPos>0
      /* Fazer endereçamento apartir da consulta*/  
      nQtde:=aSaldoItens[nPos,3]
       
		VTCLear()
		VtClearBuffer()

		DLVTCabec("Endereçar Produtos:",.F.,.F.,.T.)
		 @ 01, 00 VTSay PadR('Local.:', VTMaxCol()) 	 	
 		 @ 02, 00 VTSay PadR('Doc...:', VTMaxCol()) 	 	
	  	 @ 03, 00 VTSay PadR('Prod..:' , VTMaxCol()) 	 
	    @ 04, 00 VTSay PadR('Qtde..:' , VTMaxCol())
		 @ 05, 00 VTSay PadR('End...:' , VTMaxCol())	    

		 @ 01, 08 VTSay cLocal Pict '@!'  
	  	 @ 02, 08 VTSay aSaldoItens[nPos,2] Pict '@!' 
 	  	 @ 03, 08 VTSay aSaldoItens[nPos,1] Pict '@!'
		 @ 04, 08 VTGet nQtde  Pict '@R 999999.9999' VALID nQtde>0 .and. sfValidSaldoCons()
		 @ 05, 08 VTGet cEnd  Pict '@!' VALID fValEnd(cLocal,cEnd).and. !Empty(cEnd)  

	 	VTRead
	 	  IF VTLastkey() != 27 
			If VTYesNo("Produto : " + aSaldoItens[nPos,1] + "  Quant. : " + Transform(nQtde,"@R 999999.999") ,"Confirma Enderecamento ?")		
								//1 - DA_PRODUTO,2- DA_LOCAL, 3 - DA_NUMSEQ, 4 - DA_DOC, 5 - SALDO  , 6 - destin , 7 - AVISOS
					sfMATA265(aSaldoItens[nPos,1] ,cLocal , aSaldoItens[nPos,6] , aSaldoItens[nPos,2] ,nQtde, cEnd,.T. ) 
						  
			Endif
	     endif
	  endif 
	else
	  DLVTAviso('SIGAWMS - SALDO','Não existe produtos com Saldos a Endereçar neste ARMZ.')
	endif
	 

return

	
	

******************************************************************************************************************************************************
Static Function AOCEND1()                                                                                                                             
******************************************************************************************************************************************************
Local lContinua := .T. 
Local nRecCount:=0
Local Y:=0
Private cEnd  := Space(15)
Private cProduto := Space(28)
Private cLocal	  := "11" 
Private nQtde	:=0 
Private aItens:={}
Private nSaldo:=0



While lContinua    

	VTCLear()
	VtClearBuffer()


	DLVTCabec("Endereçar Produtos:",.F.,.F.,.T.)
	 @ 01, 00 VTSay PadR('Local.:', VTMaxCol()) 	 	
  	 @ 02, 00 VTSay PadR('Prod..:' , VTMaxCol()) 	 
    @ 03, 00 VTSay PadR('Qtde..:' , VTMaxCol())
	 @ 04, 00 VTSay PadR('End...:' , VTMaxCol())

	 @ 01, 08 VTGet cLocal Pict '@!' VALID !Empty(cLocal) .and. fValLocal(cLocal) 
  	 @ 02, 08 VTGet cProduto Pict '@!' VALID fVldBarras(cProduto)  .and. !Empty(cProduto)
	 @ 03, 08 VTGet nQtde  Pict '@R 999999.9999' VALID (nQtde>0) 
	 @ 04, 08 VTGet cEnd  Pict '@!' VALID fValEnd(cLocal,cEnd).and. !Empty(cEnd)


	VTRead   
	nRecCount:=fVlSaldoSDA()

  
	  If LEN(aItens)=0 .or. nSaldo < nQtde
			  DLVTAviso('SIGAWMS - SALDO', iif(nSaldo < nQtde .and. nSaldo>0 ,'Quantidade maior que o saldo a distribuir!! Saldo: '+str(nSaldo,10,3),'Produto sem Saldos a Endereçar!!'))
			  nQtde:=nSaldo
			  
	  Else
			
		IF nRecCount>1
				 DLVTAviso('SIGAWMS - AVISO','ATENCAO, Multiplos Documentos a Enderecar')   
				 
				 FOR Y:=1 TO LEN(aItens)
	              
				   If VTYesNo("Documento : " + aItens[Y,4] + "  Saldo : " + Transform(aItens[Y,5],"@R 999999.999") ,"Confirma Enderecamento ?")		
				    //DA_PRODUTO, DA_LOCAL, DA_NUMSEQ, DA_DOC, SALDO  , destino	   
					  sfMATA265(aItens[Y,1] , aItens[Y,2] , aItens[Y,3] , aItens[Y,4] , aItens[Y,5],cEnd,.T. ) 
					  nQtde :=aItens[Y,5]
					Endif
					 
				 NEXT 
				 
		
				Elseif nRecCount==1
				 DLVTAviso('SIGAWMS - AVISO','Enderecamento Simples')                      
				 sfMATA265(aItens[1,1] , aItens[1,2] , aItens[1,3] , aItens[1,4] , nQtde,cEnd,.T. )
	  	endif
	 	 fVlSaldoSDA() 
		 IF nSaldo>0
		 	DLVTAviso('SIGAWMS - SALDO','Enderecamento Parcial restante : ' + Transform(nSaldo,"@R 999999.999"))
		 ENDIF 
		  
     EndIF
      
  
		   If VTYesNo("Deseja endereçar outro  Produto ?","SIGAWMS")
	   	lContinua :=.T.  
	   	ELSE
	   	lContinua :=.F.
	   	EndIf
      
 enddo	 


return

******************************************************************************************************************************************************
Static Function fVldBarras(cBarras)
******************************************************************************************************************************************************
Local lResp:=.f.
Local cProd:=SubStr(cBarras,1,15) 


if  Posicione("SB1",1,xFilial("SB1")+cProd,"B1_COD")==cProd
  	lResp:=.t.    
	cProduto := cProd
Else 
   DLVTAviso('SIGAWMS - AVISO', " Codigo Invalido !")		    	    
Endif 

Return(lResp) 

******************************************************************************************************************************************************
Static Function fValEnd(_cLocal,_cEnd)
******************************************************************************************************************************************************
Local lRet:=.T.
DBSelectArea('SBE')
DBSetOrder(1)
IF !DBSeek(xFilial('SBE')+_cLocal+_cEnd) 
   DLVTAviso('SIGAWMS - AVISO', 'O endereco '+Alltrim(_cEnd)+' nao existe.!')   
   lRet:=.F.  
ENDIF
Return(lRet)   


******************************************************************************************************************************************************
Static Function fValLocal(_cLocal)
******************************************************************************************************************************************************
DBSelectArea('SX5')
DBSetOrder(1)
IF !DBSeek(xFilial('SX5')+ "74" + _cLocal )
	DLVTAviso('SIGAWMS - AVISO', 'O Armazem '+Alltrim(_cLocal)+' nao existe.')
	Return .f. 
Endif 
Return .T. 


******************************************************************************************************************************************************
Static Function fVlSaldoSDA(_cProduto,_nQtde,_cArmazem)
******************************************************************************************************************************************************
Local aArea   := SDA->(GetArea())
Local cQuery    := ''
Local cAliasQry := GetNextAlias()
Local nRecCount:=0

nSaldo:=0 

				
				cQuery	:= "  SELECT DA_FILIAL,DA_PRODUTO,DA_LOCAL,DA_NUMSEQ,DA_DOC, "
				cQuery 	+= "  DA_SALDO "
				cQuery	+= "  FROM " +RetSqlName('SDA') + " SDA "
				cQuery	+= "  WHERE SDA.DA_FILIAL  = '"+xFilial("SDA")+"' "
			  	cQuery	+= "  AND SDA.DA_PRODUTO = '"+cProduto+"' "
				cQuery	+= "  AND SDA.DA_LOCAL   = '"+cLocal+"' "
				cQuery	+= "  AND SDA.DA_SALDO >=1 "
				cQuery	+= "  AND SDA.D_E_L_E_T_ = ' ' "
		  		cQuery	+= "  ORDER BY R_E_C_N_O_"
				cQuery := ChangeQuery(cQuery)
		  		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .T., .F.)

		     //	DLVTAviso('',cQuery)  
			
	dbSelectArea(cAliasQry)	 
	//Conta total e registros     
	Count To nRecCount		

		aItens:={}
		dbGotop()
		do While !(cAliasQry)->(EoF())
		  aadd(aItens,{(cAliasQry)->DA_PRODUTO, (cAliasQry)->DA_LOCAL, (cAliasQry)->DA_NUMSEQ, (cAliasQry)->DA_DOC,(cAliasQry)->DA_SALDO})   
		  nSaldo += (cAliasQry)->DA_SALDO            
 			// DLVTAviso('SIGAWMS - AVISO', "Saldo a Endereçar Doc: "+ (cAliasQry)->DA_DOC  +' | ' + Transform(nSaldo,"@R 999999.999") +' | ' )
		  	(cAliasQry)->(DbSkip())
		Enddo
			
		(cAliasQry)->(dbCloseArea())
		
RestArea(aArea) 

				
return(nRecCount)				          

******************************************************************************************************************************************************
Static Function sfMATA265(_cProd,_cLocal,_cSeq,_cDoc,_nQtde,_cEnd,_lAviso) //DA_PRODUTO, DA_LOCAL, DA_NUMSEQ, DA_DOC, SALDO  , destino, aviso         
******************************************************************************************************************************************************
Local aCabSDA    := {}
Local aItSDB         := {}
Local _aItensSDB := {} 
Local nModAux := nModulo  
Local  MsgRetWMS := ""

Private lMsErroAuto := .F. 

nModulo := 4

Begin Transaction

//Cabeçalho com a informação do item e NumSeq que sera endereçado.
aCabSDA := {{"DA_PRODUTO" ,_cProd,Nil},;
			  {"DA_NUMSEQ"  ,_cSeq,Nil}}
//Dados do item que será endereçado


aItSDB := {{"DB_ITEM"	  ,fItemSDB(_cProd,_cLocal,_cSeq) ,Nil},;
				{"DB_ESTORNO"  ," "	      ,Nil},;
				{"DB_LOCALIZ"  ,_cEnd    ,Nil},;
				{"DB_DATA"	  ,dDataBase    ,Nil},;
				{"DB_QUANT"  ,_nQtde          ,Nil}} 
				aadd(_aItensSDB,aitSDB)

//Executa o endereçamento do item
//MATA265( aCabSDA, _aItensSDB, 3)
MSExecAuto({|X,Y,Z|MATA265(X,Y,Z)},aCabSDA, _aItensSDB, 3)


If lMsErroAuto    
	MsgRetWMS := MostraErro()             
 	DLVTAviso('SIGAWMS-ERRO',MsgRetWMS) 
 	DisarmTransaction()

Else 
 if _lAviso   
	DLVTAviso('SIGAWMS','Endereçado com SUCESSO !')
 endif
  
Endif       

nModulo := nModAux
END TRANSACTION

Return             

Static Function fItemSDB(_cProduto1,_cLocal1,_cSeq1)   
Local cQuery2    := ''
Local cAliasQry2 := GetNextAlias() 
Local cItem	:='0000'
			
				cQuery2	:= "  SELECT ISNULL(MAX(DB_ITEM),'0000') DB_ITEM "
				cQuery2	+= "  FROM " +RetSqlName('SDB') + " SDB "
				cQuery2	+= "  WHERE DB_FILIAL  = '"+xFilial("SDB")+"' "
			  	cQuery2	+= "  AND DB_PRODUTO = '"+_cProduto1+"' "
				cQuery2	+= "  AND DB_LOCAL = '"+_cLocal1+"' "
				cQuery2	+= "  AND DB_NUMSEQ='"+_cSeq1+"' "
				cQuery2	+= "  AND SDB.D_E_L_E_T_ = ' ' "
		  		cQuery2	+= "  "
				cQuery2 := ChangeQuery(cQuery2)
		  		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery2),cAliasQry2, .T., .F.)

		     //	DLVTAviso('',cQuery)  
			
	dbSelectArea(cAliasQry2)	 

cItem:=StrZero(Val((cAliasQry2)->DB_ITEM)+1,4)
(cAliasQry2)->(dbCloseArea())
Return(cItem) 



******************************************************************************************************************************************************
Static Function fConsSDA(_cArmazem)
******************************************************************************************************************************************************
Local aArea   := SDA->(GetArea())
Local cQuery    := ''
Local cAliasQry := GetNextAlias()
//Local cEndProd:=''
Local nRecCount:=0
				
	  			cQuery	:= "  SELECT DA_FILIAL,DA_PRODUTO,DA_LOCAL,DA_NUMSEQ,DA_DOC, "
				cQuery 	+= "  DA_SALDO "
				cQuery	+= "  FROM " +RetSqlName('SDA') + " SDA "
				cQuery	+= "  WHERE SDA.DA_FILIAL  = '"+xFilial("SDA")+"' "
				cQuery	+= "  AND SDA.DA_LOCAL   = '"+cLocal+"' "
				cQuery	+= "  AND SDA.DA_SALDO >=1 "
				cQuery	+= "  AND SDA.D_E_L_E_T_ = ' ' "
		  		cQuery	+= "  ORDER BY R_E_C_N_O_"
				cQuery := ChangeQuery(cQuery)
		  		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .T., .F.)

		     //	DLVTAviso('',cQuery)  
			
	dbSelectArea(cAliasQry)	 
	//Conta total e registros     
	Count To nRecCount		

		aSaldoItens:={}
		dbGotop()
		do While !(cAliasQry)->(EoF()) 
		
		  aadd(aSaldoItens,{(cAliasQry)->DA_PRODUTO, (cAliasQry)->DA_DOC,(cAliasQry)->DA_SALDO,  sfLocEnd((cAliasQry)->DA_PRODUTO,(cAliasQry)->DA_LOCAL) ,(cAliasQry)->DA_LOCAL,(cAliasQry)->DA_NUMSEQ})   
		 	(cAliasQry)->(DbSkip())
		Enddo
			
		(cAliasQry)->(dbCloseArea())
		
	RestArea(aArea) 

				
return(nRecCount)	

******************************************************************************************************************************************************
Static Function sfValidSaldoCons()
******************************************************************************************************************************************************
 if nQtde<=aSaldoItens[nPos,3]
  return .t.
 else
  VtAlert('Quantidade maior que Saldo no Documento !') 
 endif
Return .F.
			     

******************************************************************************************************************************************************
User Function uBrowsectrl(modo,nElem,nElemW) 
******************************************************************************************************************************************************
If modo == 1 
  VtAlert('Topo Pagina') 
Elseif Modo == 2 
  VtAlert('Fim Pagina') 
Else 
   If VTLastkey() == 27 
      VtAlert('Saindo sem atualizar os dados') 
      VTBeep(3) 
      return 0       
   elseIf VTLastkey() == 13      
      VtBeep(1) 
     return 1          
   Endif      
EndIf     
Return 2 

******************************************************************************************************************************************************
Static Function sfLocEnd(_cProd,_cAlmox)
******************************************************************************************************************************************************
/*retorna lista de enderecos no armz informado */
Local ListEnd:=space(60)
Local cQuery := '' 
Local cAliasQry3 := GetNextAlias()
Local nRecCount

 
  				cQuery	:= "  SELECT ISNULL(BF_LOCALIZ,'VAZIO') BF_LOCALIZ, ISNULL(BF_QUANT,0) BF_QUANT "
				cQuery	+= "  FROM " +RetSqlName('SBF') + " SBF "
				cQuery	+= "  WHERE BF_FILIAL  = '"+xFilial("SBF")+"' "
				cQuery	+= "  AND BF_LOCAL   = '"+_cAlmox+"' "
				cQuery	+= "  AND BF_QUANT >0 AND BF_PRODUTO ='" + _cProd + "' " 
				cQuery	+= "  AND SBF.D_E_L_E_T_ = ' ' "
		  		cQuery	+= "  ORDER BY R_E_C_N_O_"
				cQuery := ChangeQuery(cQuery)
		  		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry3, .T., .F.)


	ListEnd:='' 
	dbSelectArea(cAliasQry3)	 
	//Conta total e registros     
	Count To nRecCount
	
	dbGotop()    
	
	While !(cAliasQry3)->(EoF()) //Enquando não for fim de arquivo
	       ListEnd += PADR(ALLTRIM((cAliasQry3)->BF_LOCALIZ),10," ") + " -" + STR((cAliasQry3)->BF_QUANT,9,2) + IIF(nRecCount>1,"| +","| ")  //RESULTADO DA CONSULTA
	       (cAliasQry3)->(dbSkip()) //Anda 1 registro pra frente  
	       nRecCount:=nRecCount-1
	EndDo
	
	(cAliasQry3)->(dbCloseArea()) //Fecha a área de trabalho
	
	IF ListEnd==''
		 ListEnd:='SEM SALDO NO ESTOQUE'
	EndIf
	
Return(ListEnd)