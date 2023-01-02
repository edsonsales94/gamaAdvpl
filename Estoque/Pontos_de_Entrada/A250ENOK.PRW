#include "rwmake.ch"
#Include "PROTHEUS.CH"    
#include "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A250ENOK  ºAutor  ³                     º Data ³  23/05/14  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AOC                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function A250ENOK()

Local aArea   := GetArea()
Local cOP 	  := SD3->D3_OP
Local lRet	  := .T.
Local cCod,nQtdDev, nCont, nI,nProduzido,nQtdRE3     
Local cCusto  
Private  _nTamB1  := TamSX3("B1_COD")[1]

SBC->(dbSetOrder(1))
SD4->(dbSetOrder(2))
dbSelectArea("SD4")

nCont   := 0
SD4->(dbSeek( xFilial("SD4")+cOP ))  
//alert( cOP )
Do While !SD4->(Eof()) .AND. SD4->D4_OP == cOP .AND. xFilial("SD4")==SD4->D4_FILIAL
		
	cCod  := SD4->D4_COD         
	cLocal:= ALLTRIM( POSICIONE("SB1",1,XFILIAL("SB1")+cCod,"B1_LOCPAD") )  //SD4->D4_LOCAL ALTERADO POR CLAUDIO 10072014
	cTipo := ALLTRIM( POSICIONE("SB1",1,XFILIAL("SB1")+cCod,"B1_TIPO") )
	IF cTipo == "MO"     
	   SD4->( dbSkip() )
	   LOOP
	ENDIF   

    //SD4->(dbSeek( xFilial("SD4")+cOP ))
	nQtdDev := 0
	nProduzido := 0 
	nQtdRE3 := EmpAlmox(cOP,cCod)  //VERIFICA QUANTO JA FOI PAGO DA OP POR COLETOR 28/12/2016 POR CLAUDIO SOLICITADO POR FABIO                  
	
	Do While xFilial("SD4")==SD4->D4_FILIAL .AND. !SD4->(Eof()) .AND. SD4->D4_OP == cOP .AND. SD4->D4_COD==cCod
		nProduzido += SD4->(D4_QTDEORI-D4_QUANT)
		SD4->( dbSkip() )
	EndDo
	
	nQtdScrap := 0
	SBC->(dbSeek( xFilial("SBC")+cOP ))
	aTotCC:={}   
	iniop:= SUBSTR(cOP,1,6)+SUBSTR(cOP,10,2)+"%"       //   SUBSTR(SBC->BC_OP,1,8)
	fimop:="501"+SUBSTR(SBC->BC_OP,9,3)
	Do While xFilial("SBC")==SBC->BC_FILIAL .AND. !SBC->(Eof()) .AND. SBC->BC_OP == cOP 
	   IF ( nI := aScan(aTotCC , {|x| x[1]== SBC->BC_PRODUTO } ) ) == 0
		  aadd(aTotCC, { SBC->BC_PRODUTO , 0 , 0 } )
		  nI := LEN( aTotCC )
		  //--- PROCURA REQUISICOES DE REPOSICAO 14/07/2014 POR CLAUDIO
		  BeginSql Alias "TRB"
		   Select ISNULL(SUM(CP_QUANT),0) REQ
		   From %Table:SCP% 
		   Where CP_FILIAL = %xFilial:SCP%
		   And CP_PRODUTO= %Exp:SBC->BC_PRODUTO% AND CP_XDOCSD3 LIKE (%Exp:iniop%)  
		   And CP_NUMSEQ=%Exp:fimop% And CP_STATUS='E'  And %notdel%                   
		  Endsql         
		  DBSELECTAREA("TRB")
		  DBGOTOP()
		  If !TRB->(Eof())
		   aTotCC[nI,2] := aTotCC[nI,2] - TRB->REQ
		  Endif 
		  TRB->(dbCloseArea()) 
		  //----------------------------------------------------------------
		  DBSELECTAREA("SBC")
       ENDIF
	   aTotCC[nI,2] += SBC->BC_QUANT
  	   SBC->( dbSkip() )
	ENDDO
	
	IF ( nI := aScan(aTotCC , {|x| x[1]== cCod } ) ) == 0
		nQtdScrap := 0
	ELSE
		nQtdScrap :=aTotCC[nI,2]
	ENDIF	                    
		
	
	//CORREÇÃO DA QUANTIDADE REAL A DEVOLVER CONSIDERANDO O PAGAMENTO POR RE3
	
	nQtdDev := (nQtdRE3-nProduzido)-nQtdScrap
	
	IF nQtdDev > 0
		
		cNum    := "D"+SUBSTR(cOP,2,5)
		
		cApropri := ALLTRIM( POSICIONE("SB1",1,XFILIAL("SB1")+cCod,"B1_APROPRI") )
		cFantasm := ALLTRIM( POSICIONE("SB1",1,XFILIAL("SB1")+cCod,"B1_FANTASM") )    
		cKanban  := ALLTRIM( POSICIONE("SB1",1,XFILIAL("SB1")+cCod,"B1_XKANBAN") )         
		
		IF (cApropri == "I" .AND. cFantasm<>"S" .AND. cKanban<>"S") ///.AND. !aCols[nI,24] ALTERACAO 12/08/14 PARA VERIFICAR CADASTRO
			
			cCont:=U_CkNumSCP(cNum)
			nCont++
			RecLock("SCP", .T.)
			SCP->CP_FILIAL := xFilial("SCP")
			SCP->CP_NUM    := cNum
			SCP->CP_ITEM   := cCont
			SCP->CP_PRODUTO:= cCod
			SCP->CP_UM     := POSICIONE("SB1",1,XFILIAL("SB1")+cCod,"B1_UM")
			SCP->CP_QUANT  := nQtdDev
			SCP->CP_DATPRF := dDatabase
			SCP->CP_EMISSAO:= dDatabase
			SCP->CP_LOCAL  := cLocal
			SCP->CP_CONTA  := POSICIONE("SB1",1,XFILIAL("SB1")+cCod,"B1_CONTA")
			SCP->CP_DESCRI := POSICIONE("SB1",1,XFILIAL("SB1")+cCod,"B1_DESC")
			SCP->CP_SOLICIT := AllTrim(cUserName)
			SCP->CP_XDOCSD3 := SUBSTR(cOP,1,6)+SUBSTR(cOP,10,2)
			SCP->CP_OBS     := "Devolucao MP da Producao" 
			SCP->CP_NUMSEQ  := "501"+SUBSTR( cOP,9,3)  //MANTER HISTORICO DO MOV DE SCRAP POR CLAUDIO 14/0702014         
			SCP->CP_CC      := "1212"
			//SCP->CP_PREREQU := "S"
			
			SCP->(MsUnLock())
			
		ENDIF
	
	ENDIF            
//			SD4->( dbSkip() )
	
EndDo 
if nCont>0
 Aviso( "Solicitacao Devolucao-SD!" , "Numero da SD Gerado -> "+cNum , {"Ok"} , 1 , "Producao "  )
endif 

RestArea(aArea)
Return(lRet)      


//RETORNA A QUANTIDADE DE REQUISIÇÕES PAGAS PARA ORDEM DE PRODUÇÃO
Static Function EmpAlmox(cOP,cCod)
 Local lRet:=0
 cAliasSD3:= GetNextAlias()
 BeginSql Alias cAliasSD3 
  SELECT isnull(SUM(D3_QUANT),0) AS D3_QUANT FROM %Table:SD3% WHERE D3_FILIAL='01' 
  AND LEFT(D3_DOC,6)=%exp:left(alltrim(cOP),6)% AND D3_COD=%exp:left(alltrim(cCod),15)%
  AND D_E_L_E_T_='' AND D3_CF IN ('RE3','RE4') AND D3_ESTORNO='' AND LEFT(D3_OBSERVA,5)='RQ/OP'   
 EndSql
 dbSelectArea(cAliasSD3)  
 dbgotop()
 lRet:=(cAliasSD3)->D3_QUANT
 dbSelectArea(cAliasSD3) 
 dbclosearea()
Return(lRet)


