#include "rwmake.ch"
#include "topconn.ch"

User Function SD3250I() // Verifica e Atualiza Status da OP após apontamento de produção
Local cAlias,cOrdem,cRecno
LOCAL aRet
Local cBlta  := space(10)
Local cOP    := space(13)
Local cParam := space(01)
Local cAlias2 := space(06)
Local cDoc   := space(06)
Local dDta
Local cArq
Local vCampos := {}


_cOP     := AllTrim(SD3->D3_OP)
_cDoc    := AllTrim(SD3->D3_DOC)
_cNumSeq := Alltrim(SD3->D3_NUMSEQ)
_dEmissao:= SD3->D3_EMISSAO

cAlias2:=alias()
cOrdem:=dbSetOrder()
cRecno:=recno()

U_ACD025DA(_cOP) 



//Processa({|| U_ChkStat4PO() },"Processando Chk Stat 4 OP...")

/***/
If ALLTRIM(SM0->M0_CODIGO) $ "04"  //TECHIT
	Incproc("Atualizando requisições de industrialização ...")
	If !Empty(GetMV("MV_TIPOBEN"))
		Begin Transaction
		cQuery := " UPDATE "+RetSqlName("SD3")+" SET D3_CF='RE9', D3_CHAVE='E9', D3_CUSTO1 = 0 "
		cQuery += " FROM "+RetSqlName("SD3")+" SD3 INNER JOIN "+RetSqlName("SB1")+" SB1 ON D3_COD=B1_COD "
		cQuery += " WHERE SD3.D_E_L_E_T_ <> '*' "
		cQuery += "   AND SB1.D_E_L_E_T_ <> '*' "
		cQuery += "   AND D3_FILIAL = '"+xFilial("SD3")+"' "
		cQuery += "   AND B1_FILIAL = '"+xFilial("SB1")+"' "
		cQuery += "   AND B1_TIPO = 'BE' "
		//cQuery += "   AND RIGHT(RTRIM(D3_COD),2) = '-X' "
		cQuery += "   AND D3_OP = '"+_cOP+"' "
		cQuery += "   AND D3_DOC = '"+_cDoc+"' "
		cQuery += "   AND D3_NUMSEQ = '"+_cNumSeq+"' "
		cQuery += "   AND D3_CF = 'RE2' "
		//MSGINFO(CQUERY)
		nErro := TCSQLExec(cQuery)
		If nErro <> 0
			DisarmTransaction()
			Break
			lReturn  := .F.
			MsgInfo("Erro na atualização dos itens da OP de industrialização! Favor acionar depto de TI.","SD3250I")
		Endif
		End Transaction
	Else
		msgstop("O parametro MV_TIPOBEN está vazio, isto gerará incosistência no custo da OP!")
	Endif
Endif


dbSelectArea(cAlias2)
dbSetOrder(cOrdem)
dbGoto(cRecno)
Return


//	Função:			Permite validar algo digitado da necessidade do usuário. Ele valida a tela toda.
//	Criação: 		João Fábio				  Data:	31/08/2007
//  Alteerado:      Reginaldo Silva(RMH INFO) Data: 27/03/2014
//	Uso:			Estoque/Custos

User Function Mt250TOk()
Local lRet := .T.
Local lMod := .T. //Verifica sem tem mod no Apontamento.
LOCAL nRaizOP
LOCAL cTipo,x
Local cDCRe := ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+M->D3_COD,"B1_DCRE"))
Local cTp   := ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+M->D3_COD,"B1_TIPO"))
Local cEol  := CHR(13)+CHR(10)

cKanban := ALLTRIM( POSICIONE("SB1",1,XFILIAL("SB1")+M->D3_COD,"B1_XKANBAN") )
cTipo2  := POSICIONE("SB1",1,xFilial("SB1")+M->D3_COD,"B1_TIPO")
nRaizOP := LEFT(M->D3_OP,6)             
QtdeProd := POSICIONE("SC2",1,xFilial("SC2")+M->D3_OP,"C2_QUJE")
cTpAponta:= POSICIONE("SC2",1,xFilial("SC2")+M->D3_OP,"C2_XTPAPON")
cLocal  := ALLTRIM( POSICIONE("SB1",1,XFILIAL("SB1")+M->D3_COD,"B1_LOCPAD") )
nQtde :=  M->D3_QUANT 
//nQtde :=  M->D3_QUANT //+ QtdeProd modificado RICKY 29/04/21
SCP->(DbSetOrder(1))
_cProces:=GETMV("MV_LOCPROC")

lMod := pesqMOD(M->D3_OP)

// Verifica se existe definição de qual TM usar no apontamento
If cTpAponta <> M->D3_TM .and. !Empty(cTpAponta) 
	Alert('O Apontamento está divergente do definido na OP !'+Chr(13)+Chr(10)+'Favor apontar com o código : ' + cTpAponta )
	lRet:=.F.
	Return lRet   
Endif

// VERIFICA SE EMPENHO POSSUI MOD
IF !lMod
	
	lRet:=.F.
	//MsgBox("Apontamento inválido, sem MOD !")
	MSGALERT( 'Apontamento inválido, não existe MOD no empenho !', 'AVISO' )

ELSE
                                            
		IF SCP->(DbSeek(xFilial("SCP")+nRaizOP ))
			
			DO WHILE !SCP->(EOF()) .AND. SCP->CP_NUM == nRaizOP
				cTipo := POSICIONE("SB1",1,xFilial("SB1")+SCP->CP_PRODUTO,"B1_TIPO")
				IF (LEFT(SCP->CP_XDOCSD3,8)==LEFT(M->D3_OP,8) .AND. EMPTY(SCP->CP_STATUS) ) .AND. (SM0->M0_CODIGO <> "04" .AND. cTipo<>"SA" )
					lRet := .F. 
				   // verifica se houve baixa avulsa  LEAN II
		      	If EmpAlmox(nRaizOP,SCP->CP_PRODUTO,"RE3")>0
		          lRet := .T.
		         Endif
				ENDIF
				SCP->(DbSkip())
			ENDDO  
			
		Else	
		  DBSELECTAREA("SG1")         //criado por claudio em 13/02/15 para percorrer a estrutura pra verificar se precisa de SA solicitado por fabio
		  DBSETORDER(5)        
		  DBSEEK(XFILIAL("SG1")+M->D3_COD)     
		  itens := {}
		  DO WHILE !SG1->(EOF()) .AND. SG1->G1_COD=M->D3_COD     
		     comp:=SG1->G1_COMP
		     Qtdeutil := SG1->G1_QUANT    
		     empenho:=pesqSD4(M->D3_OP,comp)         
		     DBSELECTAREA("SG1") 
		     If SG1->G1_FIM<dDataBase  .OR. !empenho                               
		      SG1->(DbSkip()) 
		      loop
		     Endif
		     cCKanban := ALLTRIM( POSICIONE("SB1",1,XFILIAL("SB1")+comp,"B1_XKANBAN") )
		     cFantasm := ALLTRIM( POSICIONE("SB1",1,XFILIAL("SB1")+comp,"B1_FANTASM") )
		     cDireto  := ALLTRIM( POSICIONE("SB1",1,XFILIAL("SB1")+comp,"B1_APROPRI") )

		     IF  cCKanban<>"S" .and.  left(comp,3)<>'MOD' .and. cFantasm<>"S" .and. cDireto=="I"  
		      	lRet := .F.    
		      	pago := EmpAlmox(nRaizOP,comp,"RE3")
		      	// verifica se houve baixa avulsa  LEAN II
		      	If pago<(nQtde*Qtdeutil)
		      	 aadd(itens,{comp,pago} )
		         Endif
		     ENDIF  
		     DBSELECTAREA("SG1")                                                               
		     SG1->(DbSkip())  
		  ENDDO                  
		  IF LEN(itens)>0
		     for x:=1 to len(itens)
		       if itens[x,2]==0 
		 	     alert("Item : "+itens[x,1]+" Não Foi Pago !! ")
		 	    else                                                                
		 	     alert("Item : "+itens[x,1]+" Foi Pago apenas "+str(itens[x,2],10,2))
		 	    endif 
			  next 
		  ELSE
		     lRet := .T.	  
		     
		  ENDIF 
		  If cTipo2$"SA" .OR. cKanban=='S'  .or. (cLocal=="20" .and. cTipo2=="PI")     //cTipo2$"SA/PI" .or.    
		    lRet := .T.
		  Endif                                 
		Endif  
		 If !lRet
		     	MsgBox("Apontamento inválido. Aguarde a baixa do material do estoque para esta OP e aponte novamente")
		 Endif
	endif


    if EMPTY(cDCRe) .AND. cTp = "PA" .and. RTRIM(SM0->M0_CODFIL) = '01'
       MsgStop("O produto "+LTRIM(M->D3_COD)+", não possui DCRE informado."+cEol+"Favor procurar o setor do PCP !")
       lRet := .F. 
    endif
		
RETURN lRet   


Static Function pesqSD4(cOP,cCod)
 cAliasSD4:= GetNextAlias()
 BeginSql Alias cAliasSD4 
  SELECT isnull(COUNT(D4_COD),0) AS D4_COD FROM %Table:SD4% WHERE D4_FILIAL='01' 
  AND D4_OP=%exp:cOP% AND D4_COD=%exp:left(alltrim(cCod),15)% AND D4_LOCAL=%exp:_cProces%
  AND D_E_L_E_T_=''
  AND D4_PRDORG=''   
 EndSql
 dbSelectArea(cAliasSD4)  
 dbgotop()
 lRet:=iif((cAliasSD4)->D4_COD==0,.f.,.t.)
 dbSelectArea(cAliasSD4) 
 dbclosearea()
Return(lRet)           

Static Function pesqMOD(cOP)
 cAliasSD4MOD:= GetNextAlias()
 BeginSql Alias cAliasSD4MOD
  SELECT isnull(COUNT(D4_COD),0) AS D4_COD FROM %Table:SD4% WHERE D4_FILIAL='01' 
  AND D4_OP=%exp:cOP% AND  SUBSTRING(D4_COD,1,3)='MOD'
  AND D_E_L_E_T_=''   
 EndSql                                                                                     
 dbSelectArea(cAliasSD4MOD)  
 dbgotop()
 lMod:=iif((cAliasSD4MOD)->D4_COD==0,.f.,.t.)
 dbSelectArea(cAliasSD4MOD) 
 dbclosearea()
Return(lMod)           



//RETORNA A QUANTIDADE DE REQUISIÇÕES PAGAS PARA ORDEM DE PRODUÇÃO
Static Function EmpAlmox(cOP,cCod,cRF)
Local lRet:=0

cAliasSD4:= GetNextAlias()
BeginSql Alias cAliasSD4 
 SELECT isnull(COUNT(D4_COD),0) AS D4_COD FROM %Table:SD4% WHERE D4_FILIAL='01' 
 AND LEFT(D4_OP,6)=%exp:cOP% AND D4_COD=%exp:left(alltrim(cCod),15)%
 AND D_E_L_E_T_=''   
EndSql
dbSelectArea(cAliasSD4)  
dbgotop()
lRet:=iif((cAliasSD4)->D4_COD==0,1,0)
dbSelectArea(cAliasSD4) 
dbclosearea()
IF lRet==0
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
Endif 
Return(lRet)
