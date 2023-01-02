#INCLUDE 'RWMAKE.CH'    
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APVT100.CH'   


/*
  Descrição:  Pagamento OP para Processo
  Uso:  Modulo ACD baixa de requisições (OP) para Producao
  Desenvolvedor: Ricky Moraes
  Data: 10/03/2020
*/

******************************************************************************************************************************************************
User Function AOCBAIXAOP()                                                                                                                                
******************************************************************************************************************************************************
Private cLocal	  := "11" 
Private cOP	  := space(12)
Private aItens:={}
Private cEnd  := Space(15) 
Private nQtde	:=0 
Private cEndF:=''  
Private cMat:='' 
Private lMult := .T.
Private nOpc:=0 //0 - Incio, 1 - Com Saldos em Aberto, 2 - Tudo 
	//aItens,{D4_COD,B1_TIPO, D4_QTDEORI,  BAIXADAS,POSICAO ,B1_XDESCNF,D4_OP})
aCab :={"Codigo","UM","A Pagar","Qtd.Orig.","Baixadas","Posicao - Qtd","|"}
aSize   := {15,3,9,9,9,26,1}                                  
nPos := 1
aItens :={}



	VTCLear()
	VtClearBuffer()
	IF nOpc = 0
		VTCLear()
  		@ 0,0 VTSay PadR('Selecione:' , VTMaxCol())  
		nOpc:=VTaChoice(1,0,3,VTMaxCol(),{'Com Saldo a Pagar','Lista Completa'}) 
		VtClearBuffer()
	EndIf
	
	VTCLear()
	VtClearBuffer()
	
	DLVTCabec("Baixa Req. Processo",.F.,.F.,.T.)   
	@ 01, 00 VTSay PadR('Num.OP:', VTMaxCol()) 
   @ 01, 08 VTGet cOP Pict '@!' VALID !Empty(cOP) .and. sfValOP(cOP) 
  
	VTRead
	
	While lMult  
	
	/*consultas  no SD4*/	
	
	if sfConsSD4(cOP)>0
		
	  	npos := VTaBrowse(2,0,,,aCab,aItens,aSize,'u_uBrowsectrl',1)
	  	
	  	If npos==0
			lMult:=.F.
   	elseIF nPos>0
      /* Fazer pagamento apartir da consulta*/  
		//aItens,{D4_COD,B1_TIPO, D4_QTDEORI, POSICAO , BAIXADAS,B1_XDESCNF,D4_OP})       

      DLVTAviso('SIGAWMS - SALDOS',' '+aItens[nPos,6])
      
      
      nQtde:=aItens[nPos,3]
      cEnd  := Space(15) 
		VTCLear()
		VtClearBuffer()


		DLVTCabec("Baixar OP|Produto",.F.,.F.,.T.)
		 @ 01, 00 VTSay PadR('Local.:', VTMaxCol()) 	 	
 		 @ 02, 00 VTSay PadR('OP....:', VTMaxCol()) 	 	
	  	 @ 03, 00 VTSay PadR('Prod..:' , VTMaxCol()) 	 
	    @ 04, 00 VTSay PadR('Qtde..:' , VTMaxCol())
		 @ 05, 00 VTSay PadR('End...:' , VTMaxCol())	    

		 @ 01, 08 VTSay cLocal    Pict '@!'  
	  	 @ 02, 08 VTSay aItens[nPos,8] Pict '@!' 
 	  	 @ 03, 08 VTSay aItens[nPos,1] Pict '@!'
		 @ 04, 08 VTGet nQtde  Pict '@R 999999.9999' VALID nQtde>0 .and. sfValidSaldoCons()
		 @ 05, 08 VTGet cEnd  Pict '@!' VALID sfValEnd(cLocal,cEnd).and. !Empty(cEnd) .and. SaldSBF(cLocal,cEnd,aItens[nPos,1]) 

	 	VTRead
	 	  IF VTLastkey() != 27 
			If VTYesNo("Produto : " + aItens[nPos,1] + "  Quant. : " + Transform(nQtde,"@R 999999.999") + "  Endereco: " + cEnd ,"Confirma Baixa ?")		
				Baixa3MMb() 				
			Else
			 lMult:=.F.			  
			Endif
	     endif
	  endif 
	else
	  DLVTAviso('SIGAWMS - AVISO','Nao existem produtos Empenhados ou Saldos   para essa OP.') 
	  //cOP:=space(12)
	  lMult:=.F.	
	endif
 
 EndDo

return  

******************************************************************************************************************************************************
Static Function sfConsSD4(_cOp)                                                                                                                                
******************************************************************************************************************************************************  
Local cQuery := '' 
Local cAliasQry := GetNextAlias()
Local nRecCount:=0
Local cPosicao:=''

//_nOPc= 2 entao lista tudo
//_nOpc = 1 somente com Saldo
	
	cQuery	:= "	SELECT   			 			 			"
	cQuery	+= "	D4_COD,B1_TIPO,D4_QTDEORI 	 			"
	cQuery	+= "	,ISNULL(SUM(D3_QUANT),0) BAIXADAS	"
	cQuery	+= "	,B1_XDESCNF,D4_OP		  					"
	cQuery	+= "	,B1_APROPRI,D4_LOCAL						"
	cQuery	+= "	,B1_CONTA,B1_GRUPO,B1_UM				"  
	cQuery	+= "	FROM SD4010 SD4  		 					"
	cQuery	+= "	INNER JOIN SB1010 SB1 ON D4_COD=B1_COD	"
	cQuery	+= "	 AND B1_TIPO <> 'MO'			  			"
	cQuery	+= "	 AND B1_XKANBAN<>'S'						"
	cQuery	+= "	 AND B1_FANTASM<>'S'	 					"
	cQuery	+= "	 AND SD4.D_E_L_E_T_=' '	 				"
	cQuery	+= "	 AND SB1.D_E_L_E_T_=' '					"
//	cQuery	+= "	 AND D4_QUANT>0 		 					"
	cQuery	+= "	 AND D4_FILIAL='"+xFilial("SD4")+"' "
	cQuery	+= "	 AND B1_APROPRI='I'						"
	cQuery	+= "	 AND D4_OP='"+ _cOP +"'	 				"
	cQuery	+= "	LEFT JOIN SD3010 SD3 ON D3_COD=D4_COD	"
	cQuery	+= "	 AND SD3.D_E_L_E_T_=' '		 			"
	cQuery	+= "	 AND D3_FILIAL=D4_FILIAL	 			"
	cQuery	+= "	 AND D3_CF IN ('RE3','RE4')  			"
	cQuery	+= "	 AND D3_ESTORNO<>'S'		  				"
 //	cQuery	+= "	 AND D3_EMISSAO>=D4_DATA  				"
	cQuery	+= "	 AND SUBSTRING(D3_OBSERVA,7,12) =D4_OP	"
	cQuery	+= " "
	cQuery	+= " GROUP BY D4_DATA,D4_COD,B1_TIPO		"
	cQuery	+= " ,B1_APROPRI,B1_XDESCNF,D4_OP	  		"
	cQuery	+= " ,SUBSTRING(D3_OBSERVA,7,12)	 			"
	cQuery	+= " ,D4_QTDEORI,D4_LOCAL						"
	cQuery	+= " ,B1_CONTA,B1_GRUPO,B1_UM			 		"  
   IF nOpc =1
		cQuery	+= " HAVING D4_QTDEORI> ISNULL(SUM(D3_QUANT),0)"
	Endif	
   

	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .T., .F.)
   
	aItens:={}

	dbSelectArea(cAliasQry)	 
	//Conta total e registros     
	Count To nRecCount	
	
	dbGotop()
	While !(cAliasQry)->(EoF()) //Enquando não for fim de arquivo
	      
	       	//RESULTADO DA CONSULTA
	        	cPosicao:=sfLocEnd((cAliasQry)->D4_COD,cLocal)
	        	aAdd(aItens,{ 	(cAliasQry)->D4_COD,;
	        					 	(cAliasQry)->B1_TIPO,;
        					 		((cAliasQry)->D4_QTDEORI - (cAliasQry)->BAIXADAS),;
	        					 	(cAliasQry)->D4_QTDEORI,;
	        					 	(cAliasQry)->BAIXADAS,;
	        						cPosicao,;
	        						'|',;
	        						(cAliasQry)->D4_OP,;
	        						(cAliasQry)->B1_CONTA,;
	        						(cAliasQry)->B1_GRUPO,;
	        						(cAliasQry)->B1_UM}) 

		  	       
	       (cAliasQry)->(dbSkip()) //Anda 1 registro pra frente
	EndDo
	 
	(cAliasQry)->(dbCloseArea()) //Fecha a área de trabalho
	 


return(nRecCount)






******************************************************************************************************************************************************
Static Function sfValOP(_cOP)                                                                                                                                
******************************************************************************************************************************************************  
Local lRet:=.F.

	dbselectarea("SC2")
   dbsetorder(1)
   dbseek(xfilial("SC2")+alltrim(_cOP))
   if !SC2->(eof()) 
     IF len(alltrim(DTOS(SC2->C2_DATRF)))>0
       DLVTAviso('SIGAWMS - AVISO',"Ordem de Produção Encerrada !!! Tente novamente.")
       cOP:=SPACE(12) 
     ELSE
      lRet:=.T.     
      cEndF:=C2_XEND
      cOP:=C2_NUM+C2_ITEM+C2_SEQUEN
      if len(alltrim(C2_CC))>0
        cMat:=C2_CC
      endif
     ENDIF 
   Else  
     DLVTAviso('SIGAWMS - AVISO',"Ordem de Produção Invalida !!! Tente novamente."+cOP)
     cOP:=SPACE(12) 
   Endif

return(lRet)




	
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

******************************************************************************************************************************************************
Static Function sfValidSaldoCons()
******************************************************************************************************************************************************
 if nQtde<=aItens[nPos,3]
  return .t.
 else
   DLVTAviso('SIGAWMS - AVISO','Quantidade maior que Saldo no OP !') 
 endif
Return .F.

******************************************************************************************************************************************************
Static Function sfValEnd(_cLocal,_cEnd)
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
Static Function SaldSBF(Locde,cEndO,_cPro)  //saldo no SBF E SB2
******************************************************************************************************************************************************
Local _nSaldo:=0
Local cAliasSBF:= GetNextAlias()
Local cAliasSB2:= GetNextAlias()

 IF Posicione("SB1",1,xfilial("SB1")+aItens[nPos,1],"B1_LOCALIZ")=="S"	
	 BeginSql Alias cAliasSBF  
	  SELECT isnull(SUM(BF_QUANT),0) AS BF_QUANT FROM %Table:SBF% WHERE BF_FILIAL='01' 
	  AND BF_PRODUTO=%exp:_cPro%  AND BF_LOCAL=%exp:Locde% AND BF_LOCALIZ=%exp:cEndO% 
	  AND D_E_L_E_T_='' 
	 EndSql 
	dbSelectArea(cAliasSBF)  
	dbgotop()
	_nSaldo+=(cAliasSBF)->BF_QUANT
	dbSelectArea(cAliasSBF) 
	dbclosearea()
ELSE 
	 BeginSql Alias cAliasSB2  
	  SELECT isnull(SUM(B2_QATU),0) AS B2_QATU FROM %Table:SB2% WHERE B2_FILIAL='01' 
	  AND B2_COD=%exp:_cPro%  AND B2_LOCAL=%exp:Locde%
	  AND D_E_L_E_T_='' 
	 EndSql 
	dbSelectArea(cAliasSB2)  
	dbgotop()
	_nSaldo+=(cAliasSB2)->B2_QATU
	dbSelectArea(cAliasSB2) 
	dbclosearea()

ENDIF  

IF _nSaldo<nQtde
  DLVTAviso('SIGAWMS - AVISO',"Saldo no Endereço menor que o solicitado! 	Quant. : "+ Transform(nQtde, "@R 999999.99") +" Saldo: "+ Transform(_nSaldo, "@R 999999.99") ) 
  Return .F. 
ENDIF

Return(.T.)




******************************************************************************************************************************************************
Static Function DocSd3()
******************************************************************************************************************************************************
 Local nDoc:=1
 Local cDocs
 cAliasSD3:= GetNextAlias()
 BeginSql Alias cAliasSD3 
  SELECT isnull(MAX(D3_DOC),'000000000') AS D3_DOC FROM %Table:SD3% WHERE D3_FILIAL='01' 
  AND LEFT(D3_DOC,6)=%exp:left(alltrim(cOP),6)% 
  AND D_E_L_E_T_='' AND D3_CF IN ('RE3','RE4') AND LEFT(D3_OBSERVA,5)='RQ/OP' AND D3_ESTORNO=''
 EndSql 
dbSelectArea(cAliasSD3)  
dbgotop()
nDoc+=VAL(SUBSTR((cAliasSD3)->D3_DOC,7,3))
dbSelectArea(cAliasSD3) 
dbclosearea() 
cDocs:=LEFT(alltrim(cOP),6)+STRZERO(nDoc,3) 
Return(cDocs)



	
******************************************************************************************************************************************************
Static Function Baixa3MMb()
******************************************************************************************************************************************************
Local aArea2 := GetArea()  
Local aCab  :={}
Local _aItem := {} 
LOCAL _atotitem := {}  
LOCAL lShowMSM:=.T.
Local cD3_TM:="501"  
Local cAlmox,cConta,cGrupo,cDoc,_cOP 



Private lAutoErrNoFile := .F.
Private lMsHelpAuto := .t. // se .t. direciona as mensagens de help
Private lMsErroAuto := .f. //necessario a criacao

cDoc:=DocSd3()
cTitulo:= "PAGTO-" 


IF (!GetMv("MV_ULMES") > dDataBase) 
 

    cAlmox:="11"   
    cConta:=aItens[nPos,9]
    cGrupo:=aItens[nPos,10]
    cUm:=aItens[nPos,11]
    _cOP:=cOP
    
   
      cDoc:=DocSd3()
	   aCab := {{"D3_DOC"     ,cDoc      ,NIL}, ;
	            {"D3_TM"      ,cD3_TM    ,NIL}, ; 
	            {"D3_EMISSAO" ,dDataBase ,Nil} }

    _aItem:={{"D3_COD"    ,aItens[nPos,1]   ,NIL},;
             {"D3_UM"     ,cUm           ,NIL},;
             {"D3_QUANT"  ,nQtde   ,NIL},;
			    {"D3_LOCAL"  ,cAlmox        ,NIL},;
			    {"D3_LOTECTL" ,"",NIL},;
			    {"D3_CONTA"  ,cConta        ,NIL},;
			    {"D3_GRUPO"  ,cGrupo        ,NIL},;
			    {"D3_LOCALIZ",cEnd    ,NIL},;
			    {"D3_XENDER",cEndF	,NIL},;
			    {"D3_OBSERVA","RQ/OP "+_cOP+" Hr: "+left(time(),5),NIL},;
			    {"D3_EMISSAO",dDataBase                          ,nil}}  
		     
	aadd(_atotitem,_aitem)

  BeginTran()
	 MSExecAuto({|x,y,z|MATA241(x,y,z)},aCab,_atotitem,3)  //Usado para Gerar movimentos Intermos. 
  EndTran()
  
  MsUnlockAll() 
  
  //verificar se existe saldo a endereçar
  sfSDASD3(cDoc,dDataBase)		
		
				
		If lMsErroAuto    
			MsgRetWMS := MostraErro()             
		 	DLVTAviso('SIGAWMS-ERRO',MsgRetWMS) 
		 	DisarmTransaction()
	      lShowMSM:=.F.
  
		Else 
			DLVTAviso('SIGAWMS - AVISO','Baixa realizada com SUCESSO !') 

  		Endif 
			  
		
ELSE
	DLVTAviso('SIGAWMS - ERRO',"Não é permitido "+cTitulo+" Ordem Producao com data menor que a do fechamento!")
    
Endif 

RestArea(aArea2) 
cOP := _cOP
nOpc:=1                                  



Return




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

******************************************************************************************************************************************************
Static Function fItemSDB(_cProduto1,_cLocal1,_cSeq1)   
******************************************************************************************************************************************************
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
Static Function sfSDASD3(_cDoc,_dDataBase1)		
******************************************************************************************************************************************************
Local cQuery    := ''
Local cAliasQry := GetNextAlias() 
Local nRecCount:=0
			
				cQuery	:= "  SELECT "   
				cQuery	+= "	DA_PRODUTO,DA_LOCAL,DA_NUMSEQ,DA_DOC,DA_SALDO,D3_XENDER"
				cQuery	+= "  FROM " +RetSqlName('SDA') + " SDA"
				cQuery	+= "  INNER JOIN "+ RetSqlName('SD3')+ " SD3 "
				
				cQuery	+= " 		ON  SDA.D_E_L_E_T_=''	"
				cQuery	+= "  	AND SD3.D_E_L_E_T_=''	"
				cQuery	+= "  	AND D3_NUMSEQ=DA_NUMSEQ	"
				cQuery	+= "  	AND D3_COD=DA_PRODUTO	"
				cQuery	+= "  	AND D3_QUANT=DA_QTDORI	"
				cQuery	+= "  	AND D3_FILIAL=DA_FILIAL	"
				cQuery	+= "  	AND D3_ESTORNO=''	"
				cQuery	+= "  	AND DA_SALDO>0		"
				cQuery	+= "  	AND DA_FILIAL='"+xFilial("SDA")+"' "
				cQuery	+= "  	AND D3_DOC='"+ _cDoc +"' "
				cQuery	+= "  	AND D3_EMISSAO='" + DTOS(_dDataBase1) +"' "
				cQuery	+= "  	AND DA_ORIGEM='SD3'	"     
		  		cQuery	+= "  	AND D3_XENDER<>'' "
		  		cQuery	+= "  "
				cQuery := ChangeQuery(cQuery)

		  		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .T., .F.)

		     //	DLVTAviso('',cQuery)  
			
	dbSelectArea(cAliasQry)	 
	//Conta total e registros     
	Count To nRecCount
	dbGotop()    
	If nRecCount>0 
	
		While !(cAliasQry)->(EoF()) //Enquando não for fim de arquivo	

			sfMATA265((cAliasQry)->DA_PRODUTO,(cAliasQry)->DA_LOCAL,(cAliasQry)->DA_NUMSEQ,(cAliasQry)->DA_DOC,(cAliasQry)->DA_SALDO,(cAliasQry)->D3_XENDER,.F. )  //executar enderecamento
			(cAliasQry)->(DbSkip())

		EndDo
	
	EndIF
	
	


(cAliasQry)->(dbCloseArea())

Return 
	