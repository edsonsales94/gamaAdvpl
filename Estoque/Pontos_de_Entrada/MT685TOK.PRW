
#include "rwmake.ch"
#include "topconn.ch"

// Ponto de Entrada: para validacao de Apontamento de Perda (OP)

User Function  MT685TOK()
Local aArea := GetArea()
Local lInc := PARAMIXB[1]
Local lRet := .T. // retorno .T. ou .F. para validar o apontamento de perda.
LOCAL cOpPerd := SC2->(C2_NUM+C2_ITEM+C2_SEQUEN)        	
LOCAL lCont := .T.
Local itens := {}
Local nI, x

SC2->(dbSetOrder(6))
SCP->(dbSetOrder(2))  // Arquivo de requisicao ao Almoxarifado
SBC->(dbSetOrder(1)) //Arquivo Apontamento de perda

lCont:= ChkBaixa(cOpPerd)   
nLin :=len(aHeader)+1 
cCodi   := aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "BC_PRODUTO"    })
nQuant  := aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "BC_QUANT"    }) 
cLocaliz:= aScan( aHeader , { |x| Upper( Alltrim( x[2] ) ) == "BC_LOCALIZ"    })
If !lCont 
  FOR nI:=1 TO LEN(aCols)   
   Kanbam :=ALLTRIM(Posicione("SB1",1,XFILIAL("SB1")+aCols[nI,cCodi],"B1_XKANBAN"))
   Fantasm:=ALLTRIM(Posicione("SB1",1,XFILIAL("SB1")+aCols[nI,cCodi],"B1_FANTASM") )    
   cDireto:= ALLTRIM( POSICIONE("SB1",1,XFILIAL("SB1")+aCols[nI,cCodi],"B1_APROPRI") )
   lCont:=EmpAlmox(cOpPerd,aCols[nI,cCodi]) 
   if !lCont .AND. Kanbam<>"S" .AND. Fantasm<>"S"  .and. cDireto=="I"
    aadd(itens,{aCols[nI,cCodi],aCols[nI,nQuant]} )
   endif 
  NEXT  
  If len(itens)>0 
   lCont:=.F. 
  Else
   lCont:=.T. 
  Endif 
Endif 
IF lCont
	                      
	If lInc    // --- Validação na inclusao do Apontamento de Perda
		
		FOR nI:=1 TO LEN(aCols)
			
			nCont   := 1
			cNum    := "P"+SUBSTR(cOpPerd,2,5)  
			cProd   := aCols[nI,cCodi]     
			lAtCP   := .F.
			DBSELECTAREA("SCP")
			SCP->( dbSetorder(1) ) 
			SCP->( dbSeek(xFilial("SCP")+cNum ))
			if !eof()                          
			 Do While ALLTRIM(cNum)==ALLTRIM(SCP->CP_NUM)
			  If alltrim(cProd)==ALLTRIM(SCP->CP_PRODUTO)
			    lAtCP:=.T.
			    RecLock("SCP", .F.)
			    SCP->CP_QUANT  := SCP->CP_QUANT + aCols[nI,nQuant]
			    SCP->CP_STATUS  := "I"  
			    SCP->CP_PREREQU  := ""  
			    SCP->CP_OBS     := "501-Requis.Ref.Apont.Perda"     
			    MsUnlock()
			    Exit
			  Endif
			  nCont:=VAL(SCP->CP_ITEM)+1
			  dbskip()
			 Enddo			
			Endif
			If !lAtCP
			 cApropri := ALLTRIM( POSICIONE("SB1",1,XFILIAL("SB1")+aCols[nI,cCodi],"B1_APROPRI") )
			 cFantasm := ALLTRIM( POSICIONE("SB1",1,XFILIAL("SB1")+aCols[nI,cCodi],"B1_FANTASM") )
			 cKanban  := ALLTRIM( POSICIONE("SB1",1,XFILIAL("SB1")+aCols[nI,cCodi],"B1_XKANBAN") )
			
			 IF (cApropri == "I" .AND. cFantasm<>"S" .AND. cKanban<>"S") .AND. !aCols[nI,nLin]
				
				///cCont:=strzero(nCont,2)      //U_CkNumSCP(cNum) 
				cTipo:=POSICIONE("SB1",1,XFILIAL("SB1")+aCols[nI,cCodi],"B1_TIPO")
				RecLock("SCP", .T.)
				SCP->CP_FILIAL := xFilial("SCP")
				SCP->CP_NUM    := cNum
				SCP->CP_ITEM   := strzero(nCont,2)
				SCP->CP_PRODUTO:= aCols[nI,cCodi]
				SCP->CP_UM     := POSICIONE("SB1",1,XFILIAL("SB1")+aCols[nI,cCodi],"B1_UM")
				SCP->CP_QUANT  := aCols[nI,nQuant]
				SCP->CP_DATPRF := dDatabase
				SCP->CP_EMISSAO:= dDatabase
				SCP->CP_LOCAL  := IIF(cTipo=='PI',"11",POSICIONE("SB1",1,XFILIAL("SB1")+aCols[nI,cCodi],"B1_LOCPAD"))
				SCP->CP_CONTA  := POSICIONE("SB1",1,XFILIAL("SB1")+aCols[nI,cCodi],"B1_CONTA")
				SCP->CP_DESCRI := POSICIONE("SB1",1,XFILIAL("SB1")+aCols[nI,cCodi],"B1_DESC")
				SCP->CP_SOLICIT := AllTrim(cUserName)
				SCP->CP_XDOCSD3 := LEFT( cOpPerd,8)
				SCP->CP_OBS     := "501-Requis.Ref.Apont.Perda"
				SCP->CP_OP 		:= cOpPerd
				SCP->CP_XLOCALI := aCols[nI,cLocaliz] 
				SCP->CP_NUMSEQ  := "501"+SUBSTR(cOpPerd,9,3) //inserido campo para manter historico do tm e item da op por claudio em 14/07/2014
				//SCP->CP_PREREQU := "S"
				aCols[nI,21]:=cNum+strzero(nCont,2)
				MsUnlock()
				lGera:=.T.
				
			 ENDIF
			Endif 
		NEXT nI
		
	ELSE    // --- Validação na exclusao do Apontamento de Perda
		
		
		FOR nI:=1 TO LEN(aCols)
			
			//nCont   := 1
			cNum    := aCols[nI,22]
			cEstor  := aCols[nI,1]
			cCodi   := aCols[nI,2]
			
			IF cEstor=="S" .AND. !aCols[nI,nLin]
				
				IF SCP->(dbSeek(xFilial("SCP")+cCodi+cNum))
					
					IF (SCP->CP_STATUS $ ' ')           
					  RecLock("SCP",.F.)                   
					  SCP->(dbDelete())
					  SCP->(MsUnLock())
					ELSE
					  IF SCP->(CP_QUANT-CP_QUJE)>=aCols[nI,nQuant]  
					   RecLock("SCP",.F.)                   
						SCP->CP_QUANT  := SCP->CP_QUANT - aCols[nI,nQuant]
					   SCP->(MsUnLock())
					  ELSE 
					   SCP->(MsUnLock())
				    	lRet:=.F.
						Alert( "Ordem nao pode ser excluida. Almoxarifado ja efetuou a baixa da reposicao do material (requisicao) ")  
					  Endif	
					ENDIF
					
				ENDIF
				
			ENDIF
			
		NEXT nI
		
		
	EndIf
	
ELSE
	If len(itens)>0 
	  for x:=1 to len(itens)
	    alert("Item : "+itens[x,1]+" - Qtd: "+str(itens[x,2],10)+" Nao possui baixa de MP para PRodução!!")
	  next 
	Else
    Alert( "Perda NAO pode ser apontada. Ainda nao foram efetuadas baixas de MP para esta OP pelo Almoxarifado! ")
   Endif 
 	lRet:=.F.
	
ENDIF
RestArea(aArea)

Return lRet


//RETORNA A QUANTIDADE DE REQUISIÇÕES PAGAS PARA ORDEM DE PRODUÇÃO
Static Function EmpAlmox(cOP,cCod)
Local lRet:=.T.
cAliasSD3:= GetNextAlias()
BeginSql Alias cAliasSD3 
 SELECT isnull(SUM(D3_QUANT),0) AS D3_QUANT FROM %Table:SD3% WHERE D3_FILIAL='01' 
 AND LEFT(D3_DOC,6)=%exp:left(alltrim(cOP),6)% AND D3_COD=%exp:left(alltrim(cCod),15)%
 AND D_E_L_E_T_='' AND D3_CF IN ('RE3','RE4') AND D3_ESTORNO='' AND LEFT(D3_OBSERVA,5)='RQ/OP' 
EndSql
dbSelectArea(cAliasSD3)  
dbgotop()
lRet:=iif((cAliasSD3)->D3_QUANT==0,.F.,.T.)
dbSelectArea(cAliasSD3) 
dbclosearea()
Return(lRet)





STATIC FUNCTION ChkBaixa(cOrdProd)
Local lRet := .T.
LOCAL nRaizOP
LOCAL cTipo

//cTipo2 := POSICIONE("SB1",1,xFilial("SB1")+M->D3_COD,"B1_TIPO")
nRaizOP := LEFT(cOrdProd,6)


SD4->(DbSetOrder(2))
SCP->(DbSetOrder(1))
IF SCP->(DbSeek(xFilial("SCP")+nRaizOP ))
	
	DO WHILE !SCP->(EOF()) .AND. SCP->CP_NUM == nRaizOP
		//cTipo := POSICIONE("SB1",1,xFilial("SB1")+SCP->/CP_PRODUTO,"B1_TIPO")
		IF (LEFT(SCP->CP_XDOCSD3,8)==LEFT(cOrdProd,8) .AND. EMPTY(SCP->CP_STATUS) ) //.AND. (SM0->M0_CODIGO <> "04" .AND. cTipo<>"SA" )
			lRet := .F.
		ENDIF
		SCP->(DbSkip())
	ENDDO
	     
ELSE     
         
	// Se ainda nao gerou Solicitacao ao Armazem 11 (Numero de SA) verifica no empenho se tem materia-prima que precisa ser baixada.
	SD4->( DbSeek(xFilial("SD4")+LEFT(cOrdProd,8) ) )
	DO WHILE !SD4->(EOF()) .AND. LEFT(SD4->D4_OP,8) == LEFT(cOrdProd,8)
	    cKanban  := ALLTRIM( POSICIONE("SB1",1,XFILIAL("SB1")+SD4->D4_COD,"B1_XKANBAN") )
		cTipo := POSICIONE("SB1",1,xFilial("SB1")+SD4->D4_COD,"B1_TIPO")
		IF (SM0->M0_CODIGO <> "04" .AND. !(cTipo$"SA/MO/PI") )
			lRet := .F.
		ENDIF
		IF cKanban=="S"
		  lRet := .T.
		ENDIF
		SD4->(DbSkip())
	ENDDO
	
ENDIF

RETURN lRet


  