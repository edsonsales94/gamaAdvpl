#include "rwmake.ch"
#include "TOPCONN.CH"         
#include "Colors.ch"      
#INCLUDE "TBICONN.CH"

User Function BaixaMM() 		
Local aArea := GetArea()
Private cString
Private cCadastro
Private cCadastro := "Requisicao Automatica de Materiais"
Private cString   := "SCP"                                                    
Private pOpc

dbSelectArea(cString)
SCP->(dbSetorder(4))


aRotina   := {{"Pesquisar" ,"AXPESQUI"       ,0,1},;
			  {"Visualizar","U_CPCONS1()"    ,0,2},;
			  {"Baixar",   "U_PedidoMM('B')"    ,0,3},;
			  {"Gerar S.A", "Processa( {|| U_GerarSA() } ,'Processa SAs')"  ,0,3},; 
			  {"Estornar", "U_PedidoMM('E')"   ,0,4},; 
			  {"Excluir" , "U_PedidoMM('D')"   ,0,4},; 			  
			  {"Legenda" ,	"U_BaixaLEG()"   ,0,5}}

aCores 	:= {{'CP_STATUS $ " I" .AND. EMPTY(CP_QUJE).AND.LEFT(CP_NUM,1)<>"D" ','ENABLE' },;  // Cores padroes do semaforo
			{'CP_STATUS $ "E"','DISABLE' },;                     
			{'CP_STATUS $ " I" .AND. LEFT(CP_NUM,1)=="D" ','BR_AMARELO' },;
			{'CP_STATUS $ " I" .AND. CP_QUJE > 0'   ,'BR_AZUL'} }
                                                     

mBrowse(06,01,22,75,cString,,,,,,aCores)
RestArea(aArea)
RETURN NIL





USER FUNCTION PedidoMM(pOpc)
Local aArea := GetArea() 
Local oFont := TFont():New("Courier New",,-14,.T.,.T.)  
Local oFont20 := TFont():New("Arial",,-20,.T.,.T.)
Private cNum   := SCP->CP_NUM
PRIVATE cDocSD3   
Private cCC       := SCP->CP_CC
Private cSolicit  := SCP->CP_SOLICIT 
Private dEmissao  := SCP->CP_EMISSAO

PRIVATE cTitulo := IIF( pOpc=="B" , "PAGTO-" , IIF( pOpc=="E" ,"ESTORNO ", "EXCLUIR ") )
Private bValid:=IIF(pOpc$"BD" , "{|| CP_STATUS $ ' ' .AND. ALLTRIM(SCP->CP_XDOCSD3)==cCtrlDoc}", "{||CP_STATUS=='E' .AND. ALLTRIM(SCP->CP_XDOCSD3)==cCtrlDoc}"  )

IF pOpc=="B"
   cDocSD3:= IIF( EMPTY(SCP->CP_XDOCSD3), CheckSD3( ALLTRIM(cNum) ) , IIF( LEN(ALLTRIM(SCP->CP_XDOCSD3))>8, CheckSD3(LEFT(ALLTRIM(SCP->CP_XDOCSD3),8)), CheckSD3(ALLTRIM(SCP->CP_XDOCSD3))  )  )
ELSEIF pOpc$"ED" //Estornar ou Deletar
   //cDocSD3:= IIF( EMPTY(SCP->CP_XDOCSD3), cNum , IIF( LEN(ALLTRIM(SCP->CP_XDOCSD3))>8, CheckSD3(LEFT(ALLTRIM(SCP->CP_XDOCSD3),8)), ALLTRIM(SCP->CP_XDOCSD3)  )  )
    cDocSD3:=ALLTRIM(SCP->CP_XDOCSD3)
ENDIF

cAlias := "SCP"
DbSelectArea( cAlias )
DbSetOrder(1)
cTabela := SCP->CP_NUM
cCtrlDoc:= ALLTRIM(SCP->CP_XDOCSD3)

aHeader := {}            


DbSelectArea("SX2")
DbSeek(cAlias)
DbSelectArea("SX3")  
DBSETORDER(1)
DbSeek(cAlias)
nUsado := 0
While !EOF() .And. X3_ARQUIVO == cAlias
	IF ! (x3_ordem $ "01_02_05_07_08_09_11_12_13_14_15_16_17_19_20_21_22_23_24_25_26_27_28_29_30_31_32_33_34_35_37_38")  // Desconsidera campo Z3_FILIAL
		If 	x3_usado != " " .And. cNivel >= X3_NIVEL
			nUsado := nUsado + 1
			/*
			AADD(aHeader,{ TRIM(X3_TITULO), X3_CAMPO, X3_PICTURE,;
			X3_TAMANHO, X3_DECIMAL,IF(X3_ORDEM$"10_18",".T.",".F."),;
			X3_USADO, X3_TIPO, X3_ARQUIVO } )
			*/                               
			AADD(aHeader,{ TRIM(X3_TITULO), X3_CAMPO, X3_PICTURE,;
			X3_TAMANHO, X3_DECIMAL,".F.",;
			X3_USADO, X3_TIPO, X3_ARQUIVO } )
		EndIf
	Endif
	dbSkip()
EndDo

DbSelectArea( cAlias )
DbSetOrder(1)
DbSeek(xFilial()+cTabela)

nCnt := 0
While !EOF() .And. CP_FILIAL+CP_NUM == xFilial()+cTabela
	IF eVal( &(bValid) )
		nCnt := nCnt+1
	ENDIF
	(cAlias)->( dbSkip() )
EndDo
aCOLS := Array(nCnt,nUsado+1) 
     


DbSelectArea( cAlias )
DbSetOrder(1)
DbSeek(xFilial()+cTabela)          
nCnt := 0
DO While !(cAlias)->(EOF()) .And. CP_FILIAL+CP_NUM == xFilial()+cTabela

	IF  eVal( &(bValid) )
		nCnt := nCnt+1
		nUsado:=0
		DbSelectArea("SX3")
		DBSETORDER(1)
		DbSeek(cAlias)
		DO WHILE !EOF() .And. X3_ARQUIVO == cAlias
			IF 	! (x3_ordem $ "01_02_05_07_08_09_11_12_13_14_15_16_17_19_20_21_22_23_24_25_26_27_28_29_30_31_32_33_34_35_37_38")  // Desconsidera campos
				If x3_usado != " " .And. cNivel >= X3_NIVEL
					nUsado := nUsado+1
					IF X3_ORDEM=="18"
					   aCOLS[nCnt][nUsado] := &(cAlias+"->"+"CP_QUANT")
					ELSE
					   aCOLS[nCnt][nUsado] := &(cAlias+"->"+X3_CAMPO) 
					ENDIF
				ENDIF
			ENDIF
			dbSkip()
		EndDo
		aCOLS[nCnt][nUsado+1] := .f. //Flag de Delecao
	ENDIF
	DbSelectArea( cAlias )
	DbSetOrder(1)
	//Skip
	(cAlias)->( dbSkip() )
EndDo   
    


Lim := nCnt       
IF EMPTY( nCnt )
   MsgBox( AllTrim(cUserName)+". Nao existem itens a serem "+ALLTRIM(cTitulo)+"S ! ")
   RestArea(aArea)
   RETURN NIL
ENDIF                            

DO CASE
   CASE (cTPBX:=LEFT(cNUM,1))=="P"
        cTitulo+="PERDA" 
   CASE (cTPBX:=LEFT(cNUM,1))=="S"
   		cTitulo+="SCRAP"
   CASE (cTPBX:=LEFT(cNUM,1))=="D"     
   		cTitulo:="DEVOLUCAO MP"
   OTHERWISE
   		cTPBX:="T"
ENDCASE



// Desenha a tela
@ 000,000 to 550,900 DIALOG oDlgSolicitacao TITLE cTitulo+"- Movimentacao Processo"
  

@ 008,010 SAY "Requisicao : " + cNUM +" Doc.: "+cDocSD3 OBJECT ocBox1 
 ocBox1:oFont    := oFont20

@ 008,200 SAY "Solicitante : " + alltrim(cSOLICIT) OBJECT ocBox1 
 ocBox1:oFont    := oFont20     
 
@ 019,010  SAY "Atividade: "+cTitulo OBJECT ocBox1 
 ocBox1:oFont    := oFont20   
 ocBox1:nClrText := IIF( pOPc=="B" , CLR_HBLUE ,   CLR_HRED ) 
 
 
 
IF !(pOpc$"ED")
 
 @ 019,200  SAY "TM: " OBJECT ocBox1 
 ocBox1:oFont    := oFont20   
 //ocBox1:nClrText := IIF( pOPc=="B" , CLR_HBLUE ,   CLR_HRED ) 
 
 cD3_TM := SPACE(3)
 @ 019,220  GET  cD3_TM PICTURE "999" VALID (U_VldTM( cD3_TM ).AND. VLDTM2(cD3_TM,cTPBX,pOPc)) F3 "SF5" OBJECT ocBox1 
 ocBox1:oFont    := oFont20     
 //ocBox1:nClrText := CLR_HRED
 
ENDIF
 

@ 019,335 SAY  " Emissao: " + DTOC(dEmissao) OBJECT oEmissao
oEmissao:oFont    := oFont20
oEmissao:nClrText := CLR_HBLUE


@ 034,010 To 245,430 MULTILINE MODIFY VALID LineOk(pOpc)

@ 250,010 BUTTON cTitulo+"Ordem Producao"  ACTION BaixaMM2(cNum,pOpc)
@ 250,270 BMPBUTTON TYPE 2      ACTION Fechatela()

ACTIVATE DIALOG oDlgSolicitacao CENTERED

RestArea(aArea)
Return(.T.)
                   





Static Function LineOk(pOpc)
LOCAL lRet := .T. 
Local nSaldo

IF pOpc=="B"
	SB2->(DbSeek(Xfilial("SB2")+aCols[ n,2 ]+aCols[ n,4 ]))
	IF aCols[n,5] > SB2->( (nSaldo :=SaldoSB2()) ) 
   		MsgBox("Qtde Atendida Maior que Saldo disponivel: "+Transform(nSaldo , "999,999.9999") ,"Validando o Item...")
		lRet := .F.
	ENDIF      
ENDIF

RETURN(lRet)



Static Function Fechatela()
DbSelectArea("SCP")
Close(oDlgSolicitacao)
Return




User Function BaixaLEG()
BrwLegenda(cCadastro,"Legenda",{	{"ENABLE","Em Aberto"},;
									{"BR_AMARELO","Devolucao Aberto"},;
									{"DISABLE","M.M. Baixada"},;
									{"BR_AZUL","ITEM Baixa Parcial"};
									 })
Return .T.




Static Function BaixaMM2(cNum,pOpc)
Local aArea2 := GetArea()  
Local aCab  :={}
Local _aItem := {} 
LOCAL _atotitem := {}  
LOCAL lShowMSM:=.T.
Local i
Private nNumSeq := 0
Private nQuant  := 0
Private lMsHelpAuto := .T.
Private lAutoErrNoFile := .F.
Private _CC:=""

SB1->(DbSetOrder(1))
SB2->(DbSetOrder(1))    

DbSelectArea("SD3")
SD3->(dbsetorder(2))


IF (!GetMv("MV_ULMES") > dDataBase) .AND. pOpc =="D" // Opcao de deletar Requsicao que ainda nao foi paga.
    
    SC2->(DbSetOrder(1))
    SCP->(DbSetOrder(2))
    FOR I:=1 TO LEN(aCols)
	
		IF SCP->( dbSeek( xFilial("SCP")+aCols[I,2]+cTabela+aCols[ I,1 ] ) )
			RecLock("SCP",.F.)
			SCP->(dbDelete())    
			SCP->(MsUnLock())
		ENDIF
	
	NEXT I   
	
	IF SC2->( dbSeek( xFilial("SC2")+cDocSD3 ) )
	   RecLock("SC2",.F.)
	   SC2->C2_XSA := " "
	   SC2->(MsUnLock())
	ENDIF
	
	

ELSEIF (!GetMv("MV_ULMES") > dDataBase) .AND. (pOpc $"BE" ) // Opcao de Baixa ou Estorno            
    
	FOR I:=1 TO LEN(aCols)  
	
    	//SB1->(DbSeek(Xfilial("SB1")+aCols[I,2]))
    	_cFantas  := POSICIONE("SB1",1,XFILIAL("SB1")+aCols[I,2],"B1_FANTASM")
    	SB1->(DbSeek(Xfilial("SB1")+aCols[I,2])) 
    	
        /*
    	IF pOpc $ "E" .AND. _cFantas =="S" .AND. cTPBX$"PST"
    	   cD3_TM := "502"
    	ENDIF
    	*/
   	
    	
	    IF I == 1
				
			IF pOpc=="B" 
			    //ALTERACAO EM 29/08/2014 PARA ACRESCENTAR O CENTRO DE CUSTO NO MOVIMENTO
			    SCP->(DbSetOrder(2))
			    IF SCP->( dbSeek( xFilial("SCP")+aCols[I,2]+cTabela+aCols[ I,1 ] ) )
				  _CC:=SCP->CP_CC
				ENDIF  
				aCab := { {"D3_DOC"	    ,cDocSD3	,NIL}, {"D3_TM"   ,cD3_TM  ,NIL}, ;
			           {"D3_CC"    	    ,_CC  	   	,NIL}, {"D3_EMISSAO"	,dDataBase      ,Nil} } 
     	 	ELSEIF pOpc == "E"
			    aCab := { {"D3_DOC" , cDocSD3 , Nil} , {"D3_EMISSAO" ,ddatabase, NIL} }      
			ENDIF          
			
	    ENDIF
	
	
		IF !aCols[I,len(aCols[I])] .AND. aCols[I,5] > 0 
		
		  			            
			IF pOpc == "B"
				_aitem:={{"D3_COD"		,aCols[I,2]	 ,NIL} , {"D3_UM"	    ,SB1->B1_UM     ,NIL}, {"D3_QUANT"	, aCols[I,5]      ,NIL} ,;
			            {"D3_LOCAL"	    ,aCols[ I,4 ]    ,NIL}, {"D3_GRUPO"	    ,SB1->B1_GRUPO   ,NIL}, {"D3_LOCALIZ"	,""        ,NIL} }  
			                       
			ELSEIF pOpc == "E"
			   
				_aitem:={ {"D3_COD"		,aCols[I,2]	 ,NIL},{"D3_UM"	    ,SB1->B1_UM     ,NIL}, {"D3_QUANT"	, aCols[I,5]      ,NIL} ,;
			            {"D3_LOCAL"	    ,aCols[ I,4 ]    ,NIL},  {"D3_ESTORNO"	,"S"        ,NIL} }             
			ENDIF            
					                                                 
					                                        
			aadd(_atotitem,_aitem)
					
		ENDIF
		   
   	NEXT I
   	

 
    // MSExecAuto({|x,y,z| MATA241(x,y,z)},_aCab,{_aItem},6) //Usado para Gerar  Estorno
	BeginTran()
	lMsErroAuto := .F. 
    Pergunte( "MTA240" , .T. )

	IF pOpc == "B"     
       MSExecAuto({|x,y,z| MATA241(x,y,z)},aCab,_atotitem,3)  //Usado para Gerar movimentos Intermos.
	ELSEIF pOpc == "E"  
	   SD3->(dbSeek(xFilial("SD3")+cDocSD3) )

	   
	   MSExecAuto({|x,y,z| MATA241(x,y,z)},aCab,_atotitem,6) //Usado para Gerar  Estorno
	ENDIF   
		
	//Forca documento igual a da Nota
	IF lMsErroAuto  
	   lShowMSM:=.F.
	   Mostraerro()
	   DisarmTransaction()
    ELSE                  
    	
    	SCP->(DbSetOrder(2))
    	FOR I:=1 TO LEN(aCols)
	
			IF SCP->( dbSeek( xFilial("SCP")+aCols[I,2]+cTabela+aCols[ I,1 ] ) )
				RecLock("SCP",.F.)
				IF pOpc == "B"
					SCP->CP_XDOCSD3  := cDocSD3
					SCP->CP_QUJE   += aCols[I,5]
					SCP->CP_STATUS := IIF( SCP->CP_QUJE < SCP->CP_QUANT, "I","E")
					SCP->CP_PREREQU:= "S"  
					SCP->CP_OBS := "BX:"+Transform(dDatabase,"99/99/99")+"-"+TIME()+"-"+Alltrim(CUSERNAME)// Utilizado para da data do pagto da OP pelo almoxarifado
				ELSEIF pOpc == "E"
					SCP->CP_QUJE   -= aCols[I,5]
					SCP->CP_STATUS := " "
					SCP->CP_XDOCSD3  := LEFT(cDocSD3,8)
					SCP->CP_OBS := "ES:"+Transform(dDatabase,"99/99/99")+"-"+TIME()+"-"+Alltrim(CUSERNAME)
				ENDIF
				SCP->(MsUnLock())
			ENDIF
	
	    NEXT I

	ENDIF
	EndTran()
    MsUnlockAll()
		
   IF lShowMSM
      MsgBox(cTitulo+" da Ordem Producao: "+cNum+" foi realizada com sucesso. Doc: "+cDocSD3 )
   ELSE
      MsgBox("Alguns itens da Ordem Producao No. "+cNum+" nao foram "+cTitulo+". Favor analisar! ")
   ENDIF   
	
ELSE
	MsgBox(AllTrim(cUserName)+", não é permitido "+cTitulo+" Ordem Producao com data menor que a do fechamento!")
ENDIF


Close(oDlgSolicitacao)
DbSelectArea("SCP")   
SCP->(dbSetOrder(1))
RestArea(aArea2)   


RETURN NIL




Static Function CheckSD3(cDoc)
Local aArea := GetArea()
SD3->( dbSetorder(2) ) 
cDoc2:=cDoc           
nCont := 65
DO WHILE SD3->(dbSeek(xFilial("SD3")+cDoc) )
  cDoc := cDoc2+CHR(nCont)
  nCont++
ENDDO
RestArea(aArea)
Return( cDoc )     





USER FUNCTION GerarSA()
Local aArea := GetArea()
LOCAL nCont
Local cOP1, cOP2
LOCAL cCont
Local lGera := .F.

SC2->(dbSetOrder(6))
SD4->(dbSetOrder(1))
SCP->(dbSetOrder(1))


IF !Pergunte("MMBAIXA", .T.)
	Return Nil
ENDIF  

cOP1:=MV_PAR01    
cOP2:=MV_PAR02       
cCampos:= "D4_COD,D4_OP,D4_QTDEORI,D4_QUANT,D4_LOCAL,C2_QUANT,C2_QUJE, C2_NUM,C2_ITEM,C2_SEQUEN,C2_PRODUTO,C2_EMISSAO,C2_XSA"

cQuery := " SELECT  COUNT(*) SOMA "
		cQuery += " FROM "+RetSqlName("SC2")+" SC2 INNER JOIN "+RetSqlName("SD4")+" SD4 ON (C2_FILIAL+C2_NUM+C2_ITEM=D4_FILIAL+LEFT(D4_OP,8)) "
		cQuery += " WHERE SC2.D_E_L_E_T_ <> '*' AND SD4.D_E_L_E_T_ <> '*' "
		cQuery += "   AND C2_FILIAL = '"+xFilial("SC2")+"' "
		cQuery += "   AND D4_FILIAL = '"+xFilial("SD4")+"' "
		cQuery += "   AND C2_QUANT<>C2_QUJE "
		cQuery += "   AND C2_NUM+C2_ITEM BETWEEN '"+cOP1+"'  AND    '"+cOp2+"' "
		cQuery += "   AND C2_XSA<> 'S' "
		//cQuery += "   ORDER BY C2_NUM,C2_ITEM,C2_SEQUEN,C2_PRODUTO,D4_COD "              
		
//nRegis  := U_ContaQ(@cQuery," COUNT(*) SOMA " , cCampos, "C2_NUM,C2_ITEM,C2_SEQUEN,C2_PRODUTO,D4_COD" )
nRegis  := U_ContaQ(@cQuery," COUNT(*) SOMA " , cCampos, "C2_NUM,C2_ITEM,C2_SEQUEN,C2_PRODUTO,D4_COD" )



If nRegis == 0
	MsgBox("Nao existem OPs ou Solicitacao Armazem ja efetuada!" )  
	RestArea(aArea)
	Return Nil
Endif         

cQuery := " SELECT  D4_COD,D4_OP,D4_QTDEORI,D4_QUANT,D4_LOCAL,C2_QUANT,C2_QUJE, C2_NUM,C2_ITEM,C2_SEQUEN,C2_PRODUTO,C2_EMISSAO,C2_XSA "
		cQuery += " FROM "+RetSqlName("SC2")+" SC2 INNER JOIN "+RetSqlName("SD4")+" SD4 ON "
		cQuery += " D4_FILIAL=C2_FILIAL AND D4_OP=C2_NUM+C2_ITEM+C2_SEQUEN AND SD4.D_E_L_E_T_=SC2.D_E_L_E_T_"
		cQuery += " WHERE C2_FILIAL = '"+xFilial("SC2")+"' " 
		cQuery += " AND C2_NUM+C2_ITEM BETWEEN '"+cOP1+"'  AND    '"+cOp2+"' "
		cQuery += " AND SC2.D_E_L_E_T_ <> '*' AND C2_QUANT<>C2_QUJE " "
		cQuery += " AND C2_XSA<> 'S' "
		cQuery += " ORDER BY C2_NUM,C2_ITEM,C2_SEQUEN,C2_PRODUTO,D4_COD "              

TcQuery cQuery New Alias 'TRA'

IF ! Used()
	MsgBox(cQuery+'. Query errada','Erro!!!','STOP')
ENDIF

DbSelectArea('TRA')

TRA->(DbGoTop())

		                                                                                 
ProcRegua(nRegis)

DO WHILE !TRA->(EOF())

   IncProc("Gerando Solicitaca Armazem " + TRA->C2_NUM+TRA->C2_ITEM )
   nCont := 1
   cNum := TRA->C2_NUM
  //nCont := CkNumSCP(TRA->C2_NUM) 
   
   DO WHILE !TRA->(EOF()) .AND. TRA->C2_NUM == cNum   
   
 		cApropri := ALLTRIM( POSICIONE("SB1",1,XFILIAL("SB1")+TRA->D4_COD,"B1_APROPRI") )
 		cFantasm := ALLTRIM( POSICIONE("SB1",1,XFILIAL("SB1")+TRA->D4_COD,"B1_FANTASM") )
 		cKanban  := ALLTRIM( POSICIONE("SB1",1,XFILIAL("SB1")+TRA->D4_COD,"B1_XKANBAN") )
   		
   		IF (cApropri == "I" .AND. cFantasm<>"S" .AND. cKanban<>"S")
 		

   			//IF !SCP->( dbSeek(xFilial("SCP")+TRA->C2_NUM+TRA->D4_COD+DTOS(dDatabase) ) )
   		    //IF !SCP->( dbSeek(xFilial("SCP")+TRA->C2_NUM+STRZERO(nCont,2)+DTOS(dDatabase) ) )
   			  
      			cCont:=U_CkNum2SCP(TRA->C2_NUM)
      		    cTipo:=POSICIONE("SB1",1,XFILIAL("SB1")+TRA->D4_COD,"B1_TIPO")
      			RecLock("SCP", .T.)
      			SCP->CP_FILIAL := xFilial("SCP")
      			SCP->CP_NUM    := TRA->C2_NUM
      			SCP->CP_ITEM   := cCont
      			SCP->CP_PRODUTO:= TRA->D4_COD
      			SCP->CP_UM     := POSICIONE("SB1",1,XFILIAL("SB1")+TRA->D4_COD,"B1_UM")
				SCP->CP_QUANT  := TRA->D4_QUANT
			    SCP->CP_DATPRF := dDatabase
			    SCP->CP_EMISSAO:= dDatabase
			    SCP->CP_LOCAL  := IIF(cTipo=="PI","11",POSICIONE("SB1",1,XFILIAL("SB1")+TRA->D4_COD,"B1_LOCPAD"))     
			    //SCP->CP_LOCAL  := "11" 
			    SCP->CP_CONTA  := POSICIONE("SB1",1,XFILIAL("SB1")+TRA->D4_COD,"B1_CONTA")   
			    SCP->CP_DESCRI := POSICIONE("SB1",1,XFILIAL("SB1")+TRA->D4_COD,"B1_DESC")   
			    SCP->CP_SOLICIT := AllTrim(cUserName)
			    SCP->CP_XDOCSD3  := TRA->C2_NUM+TRA->C2_ITEM
			    SCP->CP_PREREQU:= "S" 
			    lGera:=.T.
			      
			    cXSA:= ALLTRIM( POSICIONE("SC2",6,xFilial("SC2")+TRA->C2_NUM+TRA->C2_ITEM+TRA->C2_SEQUEN+TRA->C2_PRODUTO,"C2_XSA") )
			    
			    IF EMPTY(cXSA) 
			         RecLock("SC2", .F.)
			         SC2->C2_XSA := "S"
			         SC2->(msUnLock())
			    ENDIF   
			      
      			//nCont++
   			//ELSE
    
   			//ENDIF
   
   		ENDIF
   
   		TRA->(dbSkip())
   ENDDO

ENDDO

IF !lGera
   MsgBox("Nao existem itens a serem pagos nestas OPs. MPs sao Diretos, Fantasmas ou Kanban!" )  
ENDIF

TRA->( dbCloseArea() )

Return Nil


//Static Function CkNumSCP(cDocSCP)
USER Function CkNumSCP(cDocSCP)
Local aArea := GetArea()  
LOCAL lEnt:=.T.
SCP->( dbSetorder(1) ) 
nL := 48
cL := CHR(nL)
nCont2:=1        
cCont:= aLLTRIM(CHR(nL))+aLLTRIM(CVALTOCHAR(nCont2))
//alert( cDocSCP )
//	alert( cCont )
//DO WHILE SCP->( dbSeek(xFilial("SCP")+cDocSCP+cCont+DTOS(dDatabase) ) )
DO WHILE SCP->( dbSeek(xFilial("SCP")+cDocSCP+cCont ) )

  nCont2++
  IF nCont2>9
      nL++
      IF nL>57 .AND. lEnt            
        nL:=nL+7
        lEnt:=.F.
     ENDIF
     nCont2:=0
   ENDIF  
   //cCont:= CHR(nL)+CVALTOCHAR(nCont2)     
   cCont:= aLLTRIM(CHR(nL))+aLLTRIM(CVALTOCHAR(nCont2))
   
ENDDO   
//alert( cDocSCP+cCont )

RestArea(aArea)
Return( cCont )     

   

STATIC FUNCTION VLDTM2(pTM,cTPBX,pOPc)
LOCAL lRet:=.F.
LOCAL cTM_Tipo
   
cTM_Tipo := POSICIONE("SF5",1,XFILIAL("SF5")+pTM,"F5_TIPO")   

IF pOpc $ "B" .AND. cTPBX $ "PST" .AND. cTM_Tipo=="R" 
      lRet:=.T.
ELSEIF pOpc$"B" .AND. cTPBX $ "D" .AND. cTM_Tipo=="D"
  	   lRet:=.T.
ENDIF

IF !lRet
    Aviso( "Regra de Movimentacao!" , "Este tipo de Movimentacao "+pTM+", nao e valido para este documento! " , {"Ok"} , 1 , cTitulo+" x "+cTM_Tipo )
Endif
RETURN lRet
