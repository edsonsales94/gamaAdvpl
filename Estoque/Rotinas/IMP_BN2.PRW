#Include "Rwmake.ch"
#include "topconn.ch"

User Function IMP_BN2() //Entrada na BRASITECH
LOCAL lUtiInd   := GetMv("MV_UTIIND")
Local CF_Serv   := ALLTRIM(GetMv("MV_CFOPIND"))//CFOP de Serviço de Industrialização  - 1124 - RETORNO DE SERVICOS DE  - WIP
LOCAL nRec
LOCAL cChvPesq
Local cQry:="UPDATE SB2010 SET B2_QFIM=0,B2_QATU=0,B2_VFIM1=0,B2_CM1=0,B2_VATU1=0,B2_QEMP=0,B2_CMFIM1=0 WHERE B2_COD like ('MOD%')"
Private nUsado,aHeader,aCols
Private cCadastro := "Ajuste NF-SERVICO Beneficiamento"
Private cAlias    := "SD1"
Private nCnt := 0 
Private cNomeTxt := "\data\tlog\emp"+cNumEmp+"-calc-retBN"+"-"+dTos(dDatabase)+strtran(time(),":","")+".LOG"



IF lUtiInd
	
	IF !Pergunte("IMPBN2", .T.) 
		Return Nil
	ENDIF
	If MV_PAR04>1
	 If (TCSQLExec(cQry) < 0)
      Return MsgStop("TCSQLError() " + TCSQLError())
     Else
      alert("MOD FORAM ZERADAS!!!")
      if MV_PAR04==2
       RETURN NIL
      EndIf
     EndIf
    EndIf 
	
	
	dData1 := MV_PAR01
	dData2 := MV_PAR02
	cNomeTxt := MV_PAR03
	
	cSelect := "* "
	cFrom   := RetSqlName('SD1') + ' '
	cWhere  := RetSqlName('SD1') + '.D_E_L_E_T_ <> ' + CHR(39) + '*' + CHR(39) + ' AND '+;
	"D1_FILIAL  = '" + xFilial('SD1') + "' AND D1_CF IN  ('"+SUBSTR(CF_Serv,1,4)+"' , '"+SUBSTR(CF_Serv,6,4)+"') "    //INCLUSO PARA 2 CFOP'S EM 29/07/14 POR CLAUDIO
	cWhere  += "    AND D1_DTDIGIT BETWEEN  '"+DTOS(dData1)+"'  AND    '"+DTOS(dData2)+"' "
	
	cQuery  :=	' SELECT '   + cSELECT + ;
	' FROM '     + cFROM   + ;
	' WHERE '    + cWHERE  + ;
	' ORDER BY D1_FILIAL,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_COD,D1_XNFORI,D1_XSERIOR  '
	//' ORDER BY D1_FILIAL,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_COD,D1_ITEM '
	
	//' ORDER BY D1_EMISSAO '
	//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
	
	TcQuery cQuery New Alias 'TRA'
	
	IF ! Used()
		MsgBox(cQuery+'. Query errada','Erro!!!','STOP')
	ENDIF
	
	DbSelectArea('TRA')
	TRA->(DbGoTop())
	Count to nCnt
	
	If Empty(nCnt)
		MsgBox("Nao existem NF neste periodo" )
		TRA->(dbCloseArea())	
		Return Nil
	Endif
	u_GeraLog("***********************************************************************************************************"                            , cNomeTxt)                     
	U_GeraLog("Recalcula custo nf entrada- beneficiamento "+Alltrim(CUSERNAME)                                     , cNomeTxt)
	U_GeraLog("DATA "+Transform(dDatabase,"99/99/9999") +" HORA:"+Time()                                     , cNomeTxt)
	u_GeraLog("***********************************************************************************************************"                            , cNomeTxt)
	SD1->(dbSetOrder(1))
	
	aTotNFSer := TotNFServ()
	Processa({|| geraServ()})
ENDIF
TRA->(dbCloseArea())	
Return

Static Function geraServ() 	
	DbSelectArea('TRA')
	TRA->( dbGotop() )
	ProcRegua(nCnt)
	//cChvPesq:= ""
	DO WHILE !TRA->(Eof())
		IncProc()
		IF !EMPTY(TRA->D1_XNFORI)
			u_GeraLog(" NF SERVICO :"+TRA->D1_DOC+"- NF.Retorno "+TRA->D1_XNFORI+" Itm/Codigo :"+TRA->D1_ITEM+" / "+TRA->D1_COD, cNomeTxt)
			//nRec := TRA->( recno() )
			nServ  := (TRA->D1_TOTAL-TRA->D1_VALICM)
			nVlrCst:= U_VlrServ(TRA->D1_XNFORI ,TRA->D1_XSERIOR,TRA->D1_QUANT,TRA->D1_FORNECE,TRA->D1_LOJA)
			//alterado por claudio em 31/07/14 ate esta data o sistema so estava acumulando a qtde por item , solicitado acumlar toda
			//a nota para poder fazeo rateio por proporcao
		   //	cChvPesq := TRA->D1_FILIAL+TRA->D1_DOC+TRA->D1_SERIE+TRA->D1_FORNECE+TRA->D1_LOJA+TRA->D1_COD+TRA->D1_XNFORI+TRA->D1_XSERIOR
		   // ALTERADO PARA PEGAR TODAS AS NOTAS DE ORIGEM TRA->D1_FILIAL+TRA->D1_DOC+TRA->D1_SERIE+TRA->D1_FORNECE+TRA->D1_LOJA+
			cChvPesq := TRA->D1_XNFORI+TRA->D1_XSERIOR
			IF ( nI := aScan(aTotNFSer , {|x| x[1]== cChvPesq} ) ) == 0
				//aadd(aComp, {cChvPesq , 0 } )
				//nI := len( aComp )
				nQtAcum:=TRA->D1_QUANT
			ELSE	
			
				nQtAcum := aTotNFSer[nI,2] 
				
			ENDIF
			
			//alert( cChvPesq+" - "+transform((nQtAcum), "999,999.99") )
			//alert( TRA->D1_DOC+" - "+transform((nVlrCst/nQtAcum)*TRA->D1_QUANT, "999,999.99") )
			
			nCusto := (nServ + ((nVlrCst/nQtAcum)*TRA->D1_QUANT) )
			
			IF SD1->( dbSeek(TRA->D1_FILIAL+TRA->D1_DOC+TRA->D1_SERIE+TRA->D1_FORNECE+TRA->D1_LOJA+TRA->D1_COD+TRA->D1_ITEM ) )
				Reclock("SD1",.F.)
				SD1->D1_CUSTO := nCusto
				msunlock("SD1")
				u_GeraLog(" Resumo do Item/Codigo "+TRA->D1_ITEM+" / "+TRA->D1_COD, cNomeTxt)
				u_GeraLog("((Custo Ret/Qtd Serv)*Qtd_It.Serv)+Vl.Serv: (("+transform(nVlrCst, "@E 999,999.999")+"/"+transform(nQtAcum, "@E 999,999.999")+")*"+transform(TRA->D1_QUANT, "@E 999,999.999")+")+"+transform(nServ, "@E 999,999.99")+" = "+transform(nCusto, "@E 999,999.999"), cNomeTxt)
				u_GeraLog("************************************************************************************************************", cNomeTxt)
			ELSE
				u_GeraLog(" NAO ATUALIZOU NF SERVICO :"+TRA->D1_DOC+" Vlr:"+transform(nServ, "@E 999,999.99")+"- NF.Retorno Comp: "+TRA->D1_XNFORI+transform(nVlrCst, "@E 999,999.99")        , cNomeTxt)
				
			ENDIF
					
		ELSE
					
			u_GeraLog(" NF SERVICO :"+TRA->D1_DOC+" sem NF de retorno "       , cNomeTxt)
			
		ENDIF
		
		TRA->( DbSkip() )
		
	ENDDO
	
RETURN NIL





STATIC FUNCTION TotNFServ()
LOCAL aComp := {}       
LOCAL nI
LOCAL cChvPesq:= ""
LOCAL nQtAcum
TRA->( dbGotop() )

DO WHILE !TRA->(Eof())
	
	IF !EMPTY(TRA->D1_XNFORI)
		 //ALTERADO EM 20/08/14 CLAUDIO ATENDO AO CRITERIO DE PODE EXISTIR MAIS DE UMA NOTA DE SERVICO PARA UMA UNICA NOTA DE REMESSA                                                                                                                  
		//cChvPesq != TRA->D1_FILIAL+TRA->D1_DOC+TRA->D1_SERIE+TRA->D1_FORNECE+TRA->D1_LOJA+TRA->D1_XNFORI+TRA->D1_XSERIOR
		IF cChvPesq != D1_XNFORI+TRA->D1_XSERIOR
			
			cChvPesq := TRA->D1_XNFORI+TRA->D1_XSERIOR
			nQtAcum := 0
			
			DO WHILE !TRA->(Eof()) .AND. cChvPesq ==TRA->D1_XNFORI+TRA->D1_XSERIOR
						
				nQtAcum += TRA->D1_QUANT
				
				TRA->( DbSkip() )
				
			ENDDO
			
			IF ( nI := aScan(aComp , {|x| x[1]== cChvPesq} ) ) == 0
				aadd(aComp, {cChvPesq , 0 } )
				nI := len( aComp )
			ENDIF
			aComp[nI,2] += nQtAcum 
		ELSE
		  TRA->( DbSkip() )			
		ENDIF
						
	ENDIF

ENDDO


RETURN( aComp )