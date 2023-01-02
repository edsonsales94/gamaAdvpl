/*
------------------------------------------------------------------------------
Desenvolvedor: Reginaldo Silva - 01/03/2014
Solicitante..: Fabio Pinheiro  (Supervisor de almoxarifado)
Objetivo.....: Efetuar pagto de MP automatico para producao, de acordo com 
			   Ordem de Producao.
------------------------------------------------------------------------------
Alteracao....: Reginaldo Silva - 21/11/2014                                                           
Solicitante..: Valdison Moraes (Supervisor de almoxarifado)
Motivo.......: Incluir enderecamento nas baixas.
------------------------------------------------------------------------------               
Alteracao:  Claudio Almeida	
Data:  02/03/2015
Solicitante: Sra. Cleonice 
Motivo: Ativar o controle de lotes para validacao de validade de produtos e controle FIFO
------------------------------------------------------------------------------               
*/
#include "rwmake.ch"                        
#include "TOPCONN.CH"         
#include "Colors.ch"      
#INCLUDE "TBICONN.CH"  
#include "vkey.ch"
#include 'protheus.ch'
#include 'parmtype.ch'


                 
User Function BaixaMM2() 		
Local aArea := GetArea()
Private cCadastro := "Requisicao Automatica de Materiais"
Private cString   := "SCP"                                                    
Private pOpc

dbSelectArea(cString)
SCP->(dbSetorder(4))


aRotina   := {{"Pesquisar" ,"AXPESQUI"       ,0,1},; 			//  {"Visualizar","U_CPCONS1()"    ,0,2},;
			  {"Baixar",   "U_Pedido2MM('B')"    ,0,3},;
			  {"Gerar S.A", "Processa( {|| U_Gerar2SA() } ,'Processa SAs')"  ,0,3},; 
			  {"Estornar", "U_Pedido2MM('E')"   ,0,4},; 
			  {"Excluir" , "U_Pedido2MM('D')"   ,0,4},; 			  
			  {"Legenda" ,	"U_Baixa2LEG()"   ,0,5}}

aCores 	:= {{'CP_STATUS $ " I" .AND. EMPTY(CP_QUJE).AND.LEFT(CP_NUM,1)<>"D" ','ENABLE' },;  // Cores padroes do semaforo
			{'CP_STATUS $ "E"','DISABLE' },;                     
			{'CP_STATUS $ " I" .AND. LEFT(CP_NUM,1)=="D" ','BR_AMARELO' },;
			{'CP_STATUS $ " I" .AND. CP_QUJE > 0'   ,'BR_AZUL'} }
                                                     

mBrowse(06,01,22,75,cString,,,,,,aCores)
RestArea(aArea)
RETURN NIL





USER FUNCTION Pedido2MM(pOpc)
Local   aArea     := GetArea() 
Local   oFont     := TFont():New("Courier New",,-14,.T.,.T.)  
Local   oFont20   := TFont():New("Arial",,-20,.T.,.T.)
Local   oFont16   := TFont():New("Arial", 0 , - 20 ,, .T. , 0 ,, 700 , .F. , .F. ,,,,,,)
Local bOk := {|| Baixa2MMb() }
Local bCancel:= {|| Fechatela() }
Local aButtons := {} 
Private cNum      := SCP->CP_NUM
Private cLocalDestino:=space(15)
PRIVATE cDocSD3   
Private cCC       := SCP->CP_CC
Private cOP			
Private cSolicit  := SCP->CP_SOLICIT 
Private dEmissao  := SCP->CP_EMISSAO
Private aCols,aHeader 
aSize := MsAdvSize(.F.)
PRIVATE cTitulo := IIF( pOpc=="B" , "PAGTO-" , IIF( pOpc=="E" ,"ESTORNO ", "EXCLUIR ") )
Private bValid:=IIF(pOpc$"BD" , "{|| LEN(ALLTRIM(CP_STATUS))==0 .AND. ALLTRIM(SCP->CP_XDOCSD3)==cCtrlDoc}", "{||CP_STATUS=='E' .AND. ALLTRIM(SCP->CP_XDOCSD3)==cCtrlDoc}"  )

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


if !Empty(SCP->CP_OP) 
 cOP:=SCP->CP_OP
 dbselectarea("SC2")               
  DBSETORDER(1)
  If (dbseek(xFilial("SC2")+LEFT(cOp,6), .T.))
   cLocalDestino:= Posicione("SC2",1,xFilial("SC2")+cOp,"C2_XEND") 
  else
	cLocalDestino:="PRODUCAO"  
	Alert("Não foi cadastrada a OP !")
  EndIF 
 else
 	cLocalDestino:="PRODUCAO"  
	Alert("Não foi cadastrada a OP !")
Endif


DbSelectArea("SX2")
DbSeek(cAlias)
DbSelectArea("SX3")  
DBSETORDER(1)
DbSeek(cAlias)
nUsado := 0
While !EOF() .And. X3_ARQUIVO == cAlias
	IF ! (x3_ordem $ "01_02_05_07_08_09_11_12_13_14_15_16_17_19_20_21_22_23_24_25_26_27_28_29_30_31_32_33_34_35_37")  // Desconsidera campo Z3_FILIAL
//   IF ! (x3_ordem $ "01_02_05_07_08_09_11_13_14_15_16_17_19_20_21_22_23_24_25_26_27_28_29_30_31_32_33_34_35_37_40_41_42_43_44_45_46")  // Desconsidera campo Z3_FILIAL
		If 	x3_usado != " " .And. cNivel >= X3_NIVEL
			nUsado := nUsado + 1
			AADD(aHeader,{ TRIM(X3_TITULO), X3_CAMPO, X3_PICTURE,;
			X3_TAMANHO, X3_DECIMAL,IF(ALLTRIM(X3_CAMPO)$"CP_XLOCALI/CP_XLOTECT",".T.",".F."),;
			X3_USADO, X3_TIPO, X3_ARQUIVO } )         
		EndIf
	Endif
	dbSkip()
EndDo


DbSelectArea(cAlias)
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
     
nCol_Cod      := U_Posicao("CP_PRODUTO")
nCol_LocDe    := U_Posicao("CP_LOCAL") 
nCol_Locali   := U_Posicao("CP_XLOCALI") 
nCol_Lote     := U_Posicao("CP_XLOTECT") 
nCol_QTDe     := U_Posicao("CP_QUANT") 
nCol_Item     := U_Posicao("CP_ITEM") 

/*
nCol_LocAt    := U_Posicao("ZB_LOCALAT") 
nCol_QtdBx    := U_Posicao("ZM1_QTDPAG")  
nCol_2QtdBx   := U_Posicao("ZM1_QTDREC") 
nCol_Saldo    := U_Posicao("ZB_SALDO") 
nCol_QTDORI   := U_Posicao("ZB_QTDORI") 

nCol_Localiz  := U_Posicao("ZB_LOCALIZ")
nCol_Kit      := U_Posicao("ZB_KIT")
*/




DbSelectArea( cAlias )
DbSetOrder(1)
DbSeek(xFilial()+cTabela)          
nCnt := 0
DO While !(cAlias)->(EOF()) .And. CP_FILIAL+CP_NUM == xFilial()+cTabela
    //If SCP->CP_STATUS=='E'   //criado em 29/01/15 para gerar requisicao de perda somente de scrap nao pagos podendo fracionar o pagamento de scrap em um documento so por op
    //    DbSkip()
    //    Loop
    //Endif                                            ?
	IF  eVal( &(bValid) )
		nCnt := nCnt+1
		nUsado:=0
		DbSelectArea("SX3")
		DBSETORDER(1)
		DbSeek(cAlias)
		DO WHILE !EOF() .And. X3_ARQUIVO == cAlias
			IF 	! (x3_ordem $ "01_02_05_07_08_09_11_12_13_14_15_16_17_19_20_21_22_23_24_25_26_27_28_29_30_31_32_33_34_35_37")  // Desconsidera campos
//		   IF ! (x3_ordem $ "01_02_05_07_08_09_11_13_14_15_16_17_19_20_21_22_23_24_25_26_27_28_29_30_31_32_33_34_35_37_40_41_42_43_44_45_46")  // Desconsidera campo Z3_FILIAL
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


//Define MsDialog oDlgSolicitacao TITLE cTitulo+"- Movimentacao Processo" STYLE DS_MODALFRAME From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL

DEFINE MSDIALOG oDlgSolicitaca TITLE cTitulo+"- Movimentacao Processo" From 0,0 TO 800,100 Pixel STYLE nOR( WS_VISIBLE, WS_POPUP )
oDlgSolicitacao:lMaximized := .T. //Maximizar a janela


//@ 000,000 to 550,900 DIALOG oDlgSolicitacao TITLE cTitulo+"- Movimentacao Processo"
  


@ 001+34,010 SAY "Requisicao : " + cNUM +" Doc.: "+cDocSD3 OBJECT ocBox1 
 ocBox1:oFont    := oFont20

@ 001+34,200 SAY "Solicitante : " + alltrim(cSOLICIT)  SIZE 170, 30 OBJECT ocBox1 
 ocBox1:oFont    := oFont16     

//@ 001+34,450 SAY "End.Destino :" + alltrim(cLocalDestino) SIZE 55, 07 OF oDlgSolicitaca PIXEL
 
@ 001+34,450 SAY "Destino : " + alltrim(cLocalDestino) SIZE 170, 30 OBJECT ocBox1 
 ocBox1:oFont    := oFont16     

 
@ 019+34,010  SAY "Atividade: "+cTitulo  SIZE 170, 30 OBJECT ocBox1 
 ocBox1:oFont    := oFont20   
 ocBox1:nClrText := IIF( pOPc=="B" , CLR_HBLUE ,   CLR_HRED ) 
 
 
IF !(pOpc$"ED")
 
 @ 018+34,200  SAY "TM: " OBJECT ocBox1 
 ocBox1:oFont    := oFont16   
 //ocBox1:nClrText := IIF( pOPc=="B" , CLR_HBLUE ,   CLR_HRED ) 
 
 cD3_TM := SPACE(3)
 @ 018+34,220  GET  cD3_TM PICTURE "999" VALID (U_VldTM( cD3_TM ).AND. VLDTM2(cD3_TM,cTPBX,pOPc)) SIZE 40, 40 F3 "SF5" OBJECT ocBox1 
 ocBox1:oFont    := oFont16     
 //ocBox1:nClrText := CLR_HRED   
 
/*
 cLocali := SPACE(15)           
 @ 019,220  GET  cLocali PICTURE "@!" VALID ExistCPO('SBE', Acols[1,nCol_LocDe]+cLocali,1)  F3 "SBE" OBJECT ocBox1 
 ocBox1:oFont    := oFont20  
 
 aEval(aCols, {|x| x[nCol_Locali] := cLocali} )   
 */
  
 
ENDIF
 

@ 019+34,450 SAY  "Emissao: " + DTOC(dEmissao) OBJECT oEmissao
oEmissao:oFont    := oFont16
//oEmissao:nClrText := CLR_HBLUE

SetKey( VK_F5, { || f_Tc_F5() })


@ 034+34,010 To 345,700 MULTILINE MODIFY VALID LineOk(pOpc)

//@ 250,010 BUTTON cTitulo+" - Ordem Producao"  ACTION Baixa2MMb()
//@ 250,270 BMPBUTTON TYPE 2 ACTION Fechatela()


ACTIVATE MSDIALOG oDlgSolicitacao ON INIT (EnchoiceBar(oDlgSolicitacao,{|| Baixa2MMb(cNum,pOpc) } , bCancel ,,)) CENTERED 

SetKey( VK_F5, Nil ) // Desabilita a tecla de atalho

RestArea(aArea)
Return(.T.)
                   





Static Function LineOk(pOpc)
LOCAL lRet := .T. 
Local nSaldo

IF pOpc=="B"
	SB2->(DbSeek(Xfilial("SB2")+aCols[ n,nCol_Cod ]+aCols[ n,nCol_LocDe ]))
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




User Function Baixa2LEG()
BrwLegenda(cCadastro,"Legenda",{	{"ENABLE","Em Aberto"},;
									{"BR_AMARELO","Devolucao Aberto"},;
									{"DISABLE","M.M. Baixada"},;
									{"BR_AZUL","ITEM Baixa Parcial"};
									 })
Return .T.




Static Function Baixa2MMb(cNum,pOpc)
Local aArea2 := GetArea()  
Local aCab  :={}
Local _aItem := {} 
Local _atotitem := {}  
Local lShowMSM:=.T.
Local _cFantas, i
Private nNumSeq := 0
Private nQuant  := 0
Private lMsHelpAuto := .T.
Private lAutoErrNoFile := .F.

SB1->(DbSetOrder(1))
SB2->(DbSetOrder(1))    
DbSelectArea("SD3")
SD3->(dbsetorder(2))

numOp:=""
IF (!GetMv("MV_ULMES") > dDataBase) .AND. pOpc =="D" // Opcao de deletar Requsicao que ainda nao foi paga.
    
    SC2->(DbSetOrder(9))
    SCP->(DbSetOrder(2))
    FOR I:=1 TO LEN(aCols)
	
		IF SCP->( dbSeek( xFilial("SCP")+aCols[I,nCol_Cod]+cTabela+aCols[ I,nCol_Item ] ) )
		 IF alltrim(SCP->CP_XDOCSD3)==alltrim(cDocSD3)
			RecLock("SCP",.F.)
			SCP->(dbDelete())    
			SCP->(MsUnLock())
			numOp:=SCP->CP_OP 
	     ENDIF
		ENDIF
	
	 NEXT I   
    SC2->( dbSeek( xFilial("SC2")+SubStr(numOp,1,8) ) ) 
    Do while SC2->(!eof()) .and. SC2->C2_NUM+SC2->C2_ITEM==SubStr(numOp,1,8) 
     IF SUBSTR(SC2->C2_SEQUEN,2,2)==SubStr(numOp,10,2)
	   RecLock("SC2",.F.)
	   SC2->C2_XSA := " "
	   SC2->(MsUnLock())
	  ENDIF 
	  SC2->(DBSKIP())
	 ENDDO

ELSEIF (!GetMv("MV_ULMES") > dDataBase) .AND. (pOpc $"BE" ) // Opcao de Baixa ou Estorno
	
	FOR I:=1 TO LEN(aCols)  
	
    	//SB1->(DbSeek(Xfilial("SB1")+aCols[I,2]))
    	
    	_cFantas  := POSICIONE("SB1",1,XFILIAL("SB1")+aCols[I,2],"B1_FANTASM")
    	SB1->(DbSeek(Xfilial("SB1")+aCols[I,2])) 
    	
 	
    	
	    IF I == 1   
	        //ALTERACAO EM 29/08/2014 PARA ACRESCENTAR O CENTRO DE CUSTO NO MOVIMENTO
			SCP->(DbSetOrder(2))
			IF SCP->( dbSeek( xFilial("SCP")+aCols[I,nCol_Cod]+cTabela+aCols[ I,nCol_Item ] ) )
			  _CC:=SCP->CP_CC
			ENDIF  
			IF pOpc=="B"
			    aCab := { {"D3_DOC"	    ,cDocSD3	,NIL}, {"D3_TM"   ,cD3_TM  ,NIL}, ;
			           {"D3_CC"    	    ,_CC 	   	,NIL}, {"D3_EMISSAO"	,dDataBase      ,Nil} }
     	 	ELSEIF pOpc == "E" 
     	 	   aCab := { {"D3_DOC" , cDocSD3 , Nil} , {"D3_EMISSAO" ,ddatabase, NIL} }      
			ENDIF          
			
	    ENDIF
	
	
		IF !aCols[I,len(aCols[I])] .AND. aCols[I,5] > 0 
		
		  			            
			IF pOpc == "B"
				_aitem:={{"D3_COD"		,aCols[I,nCol_Cod]	 ,NIL} , {"D3_UM"	    ,SB1->B1_UM     ,NIL}, {"D3_QUANT"	, aCols[I,nCol_QTDe]      ,NIL} ,;
			            {"D3_LOCAL"	    ,aCols[ I,nCol_LocDe ]    ,NIL}, {"D3_CONTA"	    ,SB1->B1_CONTA   ,NIL},{"D3_GRUPO"	    ,SB1->B1_GRUPO   ,NIL},;
			            {"D3_LOCALIZ"	,aCols[ I,nCol_Locali ]        ,NIL} ,{"D3_LOTECTL"	,aCols[ I,nCol_Lote  ]        ,NIL}}  
			                       
			ELSEIF pOpc == "E"
			   
				_aitem:={ {"D3_COD"		,aCols[I,2]	 ,NIL},{"D3_UM"	    ,SB1->B1_UM     ,NIL}, {"D3_QUANT"	, aCols[I,nCol_QTDe]      ,NIL} ,;
			            {"D3_LOCAL"	    ,aCols[ I,nCol_LocDe ] ,NIL},  {"D3_LOCALIZ"	,"",NIL},{"D3_LOTECTL"	,""        ,NIL}, {"D3_ESTORNO"	,"S"        ,NIL} }             
			ENDIF            
					                                                 
					                                        
			aadd(_atotitem,_aitem)
					
		ENDIF
		   
   NEXT I
   	

	BeginTran()
	lMsErroAuto := .F. 
   Pergunte( "MTA240" , .T. )

   IF pOpc == "B"     
       MSExecAuto({|x,y,z| MATA241(x,y,z)},aCab,_atotitem,3)  //Usado para Gerar movimentos Intermos.
   ELSEIF pOpc == "E"  
	    // Estornar Distribuicao 
	   SD3->(dbSetOrder(2))     //Filial + D3_DOC + D3_COD 
	   FOR I:=1 TO LEN(aCols)
	    IF SD3->( dbSeek( xFilial("SD3")+PADR(ALLTRIM(cDocSD3),9)+aCols[I,nCol_Cod] ) ) 
	      _cAprop  := ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+aCols[I,nCol_Cod],"B1_APROPRI")) 
	      _cLocPad := ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+aCols[I,nCol_Cod],"B1_LOCPAD"))
	      _cLocDes := IIF( _cAprop=="I" , GETMV("MV_LOCPROC") , _cLocPad ) 
	      _cEndDes := IIF( _cAprop=="I" , cLocalDestino , "VERIFICAR" )  //PRECISA SER TESTADO
	      u_fSd3265(IIF(pOpc=="B",3,4) , SD3->D3_COD , SD3->D3_NUMSEQ , SD3->D3_DOC , _cLocDes , _cEndDes )
	    ENDIF
	   NEXT I
	   SD3->(dbSeek(xFilial("SD3")+cDocSD3) )
	   cD3_TM := SD3->D3_TM
	   MSExecAuto({|x,y,z| MATA241(x,y,z)},aCab,_atotitem,6) //Usado para Gerar  Estorno
	ENDIF   
		
   IF lMsErroAuto  
	   lShowMSM:=.F.
	   Mostraerro()
	   DisarmTransaction()
   ELSE                  
    	
    	SCP->(DbSetOrder(2))
    	FOR I:=1 TO LEN(aCols)
	
			IF SCP->( dbSeek( xFilial("SCP")+aCols[I,nCol_Cod]+cTabela+aCols[ I,nCol_ITEM ] ) )
				RecLock("SCP",.F.)
				IF pOpc == "B" //Baixa: pagto para producao
					SCP->CP_XDOCSD3  := cDocSD3
					SCP->CP_QUJE   += aCols[I,nCol_QTDe]
					SCP->CP_STATUS := IIF( SCP->CP_QUJE < SCP->CP_QUANT, "I","E")
					SCP->CP_PREREQU:= "S"  
					SCP->CP_OBS := "BX:"+Transform(dDatabase,"99/99/99")+"-"+TIME()+"-"+Alltrim(CUSERNAME)// Utilizado para da data do pagto da OP pelo almoxarifado
				ELSEIF pOpc == "E" // Estorno da producao
					SCP->CP_QUJE   -= aCols[I,nCol_QTDe]
					SCP->CP_STATUS := " "
					SCP->CP_XDOCSD3  := LEFT(cDocSD3,8)
					SCP->CP_OBS := "ES:"+Transform(dDatabase,"99/99/99")+"-"+TIME()+"-"+Alltrim(CUSERNAME)
				ENDIF
				SCP->(MsUnLock())
			ENDIF  
			
		    // Enderecar na Producao  
		    IF (cD3_TM == "501" )
		    	SD3->(dbSetOrder(2))     //Filial + D3_DOC + D3_COD
			    IF SD3->( dbSeek( xFilial("SD3")+PADR(ALLTRIM(cDocSD3),9)+aCols[I,nCol_Cod] ) ) 
			    
			       _cAprop  := ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+aCols[I,nCol_Cod],"B1_APROPRI")) 
			       _cLocPad := ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+aCols[I,nCol_Cod],"B1_LOCPAD"))
			       _cLocDes := IIF( _cAprop=="I" , GETMV("MV_LOCPROC") , _cLocPad ) 
			       //_cEndDes := IIF( _cAprop=="I" , aCols[I,nCol_Locali], "VERIFICAR" )  //PRECISA SER TESTADO alterado 30/04/2015 para enderecar no destino do acols
			       _cEndDes := IIF( _cAprop=="I" ,cLocalDestino, "VERIFICAR" )  
			       u_fSd3265(IIF(pOpc=="B",3,4) , SD3->D3_COD , SD3->D3_NUMSEQ , SD3->D3_DOC , _cLocDes , _cEndDes )
				
			    ENDIF             
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





USER FUNCTION Gerar2SA()
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
		cQuery += "   AND C2_NUM+C2_ITEM+C2_SEQUEN BETWEEN '"+cOP1+"'  AND    '"+cOp2+"' "
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
		cQuery += " FROM "+RetSqlName("SC2")+" SC2 INNER JOIN "+RetSqlName("SD4")+" SD4 ON (C2_FILIAL+C2_NUM+C2_ITEM=D4_FILIAL+LEFT(D4_OP,8)) "
		cQuery += " WHERE SC2.D_E_L_E_T_ <> '*' AND SD4.D_E_L_E_T_ <> '*' "
		cQuery += "   AND C2_FILIAL = '"+xFilial("SC2")+"' "
		cQuery += "   AND D4_FILIAL = '"+xFilial("SD4")+"' "
		cQuery += "   AND C2_QUANT<>C2_QUJE "
		cQuery += "   AND C2_NUM+C2_ITEM+C2_SEQUEN  BETWEEN '"+cOP1+"'  AND    '"+cOp2+"' "
		cQuery += "   AND C2_XSA<> 'S' "
		cQuery += "   ORDER BY C2_NUM,C2_ITEM,C2_SEQUEN,C2_PRODUTO,D4_COD "              

TcQuery cQuery New Alias 'TRA'

IF ! Used()
	MsgBox(cQuery+'. Query errada','Erro!!!','STOP')
ENDIF

DbSelectArea('TRA')

TRA->(DbGoTop())

		                                                                                 
ProcRegua(nRegis)

DO WHILE !TRA->(EOF())

   IncProc("Gerando Solicitaca Armazem " + TRA->C2_NUM+TRA->C2_SEQUEN )
   nCont := 1
   cNum := TRA->C2_NUM
  //nCont := CkNumSCP(TRA->C2_NUM) 
   
   DO WHILE !TRA->(EOF()) .AND. TRA->C2_NUM == cNum   
      cLocProc := ALLTRIM(GETMV("MV_LOCPROC"))
 		cApropri := ALLTRIM( POSICIONE("SB1",1,XFILIAL("SB1")+TRA->D4_COD,"B1_APROPRI") )
 		cFantasm := ALLTRIM( POSICIONE("SB1",1,XFILIAL("SB1")+TRA->D4_COD,"B1_FANTASM") )
 		cKanban  := ALLTRIM( POSICIONE("SB1",1,XFILIAL("SB1")+TRA->D4_COD,"B1_XKANBAN") )
   	cLocPad	:= ALLTRIM( POSICIONE("SB1",1,XFILIAL("SB1")+TRA->D4_COD,"B1_LOCPAD") )
   		IF (cApropri == "I" .AND. cFantasm<>"S" .AND. cKanban<>"S" .and. cLocPad<> cLocProc )
 		

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
			    SCP->CP_CONTA  := POSICIONE("SB1",1,XFILIAL("SB1")+TRA->D4_COD,"B1_CONTA")   
			    SCP->CP_DESCRI := POSICIONE("SB1",1,XFILIAL("SB1")+TRA->D4_COD,"B1_DESC")   
			    SCP->CP_SOLICIT := AllTrim(cUserName)
			    SCP->CP_XDOCSD3  := TRA->C2_NUM+SubStr(TRA->C2_SEQUEN,2,2) 
			    SCP->CP_PREREQU:= "S" 
			    SCP->CP_XLOCALI:= MV_PAR03 
			    SCP->CP_OP     :=TRA->C2_NUM+TRA->C2_ITEM+TRA->C2_SEQUEN  
			    lGera:=.T.
			      
			    //cXSA:= ALLTRIM( POSICIONE("SC2",6,xFilial("SC2")+TRA->C2_NUM+TRA->C2_ITEM+TRA->C2_SEQUEN+TRA->C2_PRODUTO,"C2_XSA") )
			     DbSelectArea("SC2") 
                 DbSetOrder(09)
			    IF DBSEEK(xFilial("SC2")+TRA->C2_NUM+TRA->C2_ITEM+TRA->C2_PRODUTO) 
			         RecLock("SC2", .F.)
			         SC2->C2_XSA := "S"
			         SC2->(msUnLock())
			    ENDIF   
			      
      			//nCont++
   			//ELSE
                                       
   			//ENDIF
   
   		ENDIF
        DbSelectArea("TRA")   
   		TRA->(dbSkip())
   ENDDO

ENDDO

IF !lGera
   MsgBox("Nao existem itens a serem pagos nestas OPs. MPs sao Diretos, Fantasmas ou Kanban!" )  
ENDIF

TRA->( dbCloseArea() )

Return Nil


//Static Function CkNumSCP(cDocSCP)
USER Function CkNum2SCP(cDocSCP)
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




STATIC FUNCTION f_tc_f5()
Local oFont := TFont():New("Courier New",,-14,.T.,.T.)  
Local oFont20 := TFont():New("Arial",,-20,.T.,.T.)
Local cAlias:=alias()                       
Local cRecno:=recno()

aCampos:={}
aadd(aCampos,{"OK"       ,"C",02,0})
aadd(aCampos,{"COD"      ,"C",25,0})  
aadd(aCampos,{"LOCPAD"   ,"C",02,0})   
aadd(aCampos,{"LOCALIZ"  ,"C",10,0})   
aadd(aCampos,{"QUANT"    ,"N",12,4})  

cArqTm1 := CriaTrab( aCampos, .T. ) 
Use &cArqTm1 Alias TMPAUX Exclusive New
cInd1 := CriaTrab( NIL , .F. )  
IndRegua("TMPAUX",cInd1,"COD+LOCPAD")

cCampos :="BF_LOCAL,BF_LOCALIZ,BF_QUANT"
cQuery  :=" SELECT COUNT(*) SOMA"                     
cQuery  +=" FROM "+RetSqlName("SBF")
cQuery  +=" WHERE  D_E_L_E_T_<>'*' AND "           
cQuery  +=" BF_FILIAL = '"+xFilial("SB2")+" ' AND " 
cQuery  +=" BF_PRODUTO = '"+aCols[n,nCol_Cod]+"' AND "
cQuery  +=" BF_LOCAL   = '"+aCols[n,nCol_LocDe]+"' AND "
cQuery  +=" BF_QUANT   > 0 "
cOrdem  :=" BF_LOCALIZ"
nRegis  := U_ContaQ(@cQuery,"COUNT(*) SOMA",cCampos,cOrdem)
TCQUERY cQuery NEW ALIAS TMQ
dbSelectArea("TMQ")
DbGotop()
While ! Eof() 
      IncProc()
      DbSelectArea("TMPAUX") 
      DbSetOrder(01)
      RecLock("TMPAUX",.t.)
            TMPAUX->OK       :=Space(02)
            TMPAUX->LOCPAD   :=Tmq->BF_Local
            TMPAUX->LOCALIZ  :=Tmq->BF_Localiz
            TMPAUX->QUANT    :=Tmq->BF_Quant
      MsUnLock()      
      DbSelectArea("TMQ")
      DbSkip()
Enddo  
DbSelectArea("TMQ")   
DbCloseArea() // Fecha consulta 
DbSelectArea("TMPAUX")    
DbGotop()

@ 100,1 TO 550,650 DIALOG oDlg2 TITLE " Consulta Endereçamento"

  @ 013,005 TO 069,155 TITLE "Dados do Produto"
  @ 020,010 SAY  "Deposito :" OBJECT ocBox1 
   ocBox1:oFont    := oFont
  @ 020,060 SAY aCols[n,nCol_LocDe] OBJECT oLocal SIZE 30,10 PICTURE "@!" 
  oLocal:oFont    := oFont
  oLocal:nClrText := CLR_HBLUE

  /*
  @ 030,010 SAY  "Endereço:" OBJECT ocBox2 
  ocBox2:oFont    := oFont
  @ 030,060 SAY aCols[n,nCol_Localiz] OBJECT oProd SIZE 80,10 PICTURE "@!" 
  oProd:oFont     := oFont
  oProd:nClrText  := CLR_HBLUE
  */
      
  @ 040,010 SAY  "Produto:" OBJECT ocBox2 
  ocBox2:oFont    := oFont
  @ 040,060 SAY aCols[n,nCol_Cod] OBJECT oProd SIZE 90,10 PICTURE "@!" 
  oProd:oFont     := oFont
  oProd:nClrText  := CLR_HBLUE

// Para Utilizacao de um arquivo qualquer sem o SX3 em um browse padrao
aCampos := {}                         
//AADD(aCampos,{"C6_OK"     ,"OK"        ,"@!X"})            
AADD(aCampos,{"LOCPAD"  ,"Local"     ,"@!"})  
AADD(aCampos,{"LOCALIZ" ,"Endereco"  ,"@!"}) 
AADD(aCampos,{"QUANT"   ,"Quant."    ,"@e 9,999,999.9999"})   

@ 50,5 TO 200,320 BROWSE "TMPAUX" FIELDS aCampos ENABLE "OK" MARK "OK" 
//@ 230,010 SAY  " - Selecione os itens "                 
@ 207,280 BUTTON "_cancel"    SIZE 30,10 ACTION Close(oDlg2)

ACTIVATE DIALOG oDlg2 CENTERED
DbSelectArea("TMPAUX")   
DbCloseArea("TMPAUX") 

dbSelectArea(cAlias)
dbGoto(cRecno)
Return
              

/*
	Objetivo: Gatilho para atualizar o campo CP_XLOCALI
	          Campo disparador CD1_LOCAL
	
*/
User Function Gat_Locali     
Local nPosLocali   := GdFieldPos("CP_XLOCALI", aHeader)
Local ix , lValid, n, nx

If n == 1 .And. Len(aCols) > 1
	For nx := 2 to Len(aCols)
	    //n:=nx
	    If Posicione("SB1",1, xFilial("SB1")+aCols[nx,nCol_Cod], "B1_LOCALIZ") <> "S"
	    
	       aCols[nx,nPosLocali]   := SPACE(15)
	         
 	    ELSE
  	       aCols[nx,nPosLocali]   := aCols[1,nPosLocali]

	    
	    Endif 

	Next
Endif
//N:=1
Return(aCols[N,nPosLocali])    



 /*

User Function fSd3265(pMov,pProd,pNumSeq,pDoc,pLocal,pLocaliz)
 If Posicione("SB1",1, xFilial("SB1")+pProd, "B1_LOCALIZ") <> "S"
   Return 
 Endif 
 lMsHelpAuto := .T.  // se .t. direciona as mensagens de help
 lMsErroAuto := .F.
 
 dbSelectArea("SDA") // Seleciona Saldo a Endereçar
 DBSETORDER(1)  // DA_FILIAL + DA_DOC + DA_SERIE + DA_CLIFOR + DA_LOJA + DA_PRODUTO
 If DbSeek(xFilial("SDA")+pProd+pLocal+pNumSeq+pDoc) 
		// Rotina Automatica de Endereçamento
		_aCab := {}
		_aItem:= {}

		Aadd(_acab, {"DA_FILIAL"	, xFilial("SDA") 	,NIL})
		Aadd(_acab, {"DA_PRODUTO"	, SDA->DA_Produto	,NIL})
		Aadd(_acab, {"DA_LOCAL"		, SDA->DA_LOCAL		,NIL})
		Aadd(_acab, {"DA_NUMSEQ"	, SDA->DA_NUMSEQ     ,NIL})						
		Aadd(_acab, {"DA_DOC"		, SDA->DA_DOC		,NIL})
		Aadd(_acab, {"DA_SERIE"		, SDA->DA_SERIE		,NIL})
		Aadd(_acab, {"DA_CLIFOR"	, SDA->DA_CLIFOR	,NIL})
		Aadd(_acab, {"DA_LOJA"		, SDA->DA_LOJA		,NIL})
        
        If pMov=4 .AND. SDA->dA_saldo < Sda->Da_QtdOri  //Estorno 
          dbSelectArea("SDB") // Seleciona Saldo a Endereçar
          DBSETORDER(1)  // DA_FILIAL + DA_DOC + DA_SERIE + DA_CLIFOR + DA_LOJA + DA_PRODUTO
          If DbSeek(xFilial("SDB")+pProd+pLocal+pNumSeq+pDoc)
	   	   Aadd(_aitem,{"DB_ITEM"		, SDB->Db_Item 		,NIL})
  		   Aadd(_aitem,{"DB_LOCALIZ"	, SDB->Db_LOCALIZ  	,NIL})								
		   Aadd(_aitem,{"DB_DATA"		, SDB->Db_Data  	,NIL})								
		   Aadd(_aitem,{"DB_QUANT"	 	, SDB->DB_QUANT		,NIL}) 
		   Aadd(_aitem,{"DB_ESTORNO"	, "S"	        	,NIL})
          Endif 
		ElseiF pMov=3 .and. SDA->dA_saldo = Sda->Da_QtdOri  //Distribuição
	   	   Aadd(_aitem,{"DB_ITEM"		, "0001"			,NIL})
  		   Aadd(_aitem,{"DB_LOCALIZ"	, pLocaliz			,NIL})								
		   Aadd(_aitem,{"DB_DATA"		, ddatabase			,NIL})								
		   Aadd(_aitem,{"DB_QUANT"	 	, SDA->DA_SALDO		,NIL})
		Else 
		  Return(.T.)    
	    Endif 
		x_Area  := Alias()
		x_Rec   := Recno()
		x_Ind   := Indexord()
		//Endereçamento
    	MSExecAuto({|X,Y,Z|MATA265(X,Y,Z)},_acab,{_aitem},pMov) 
		DbSelectArea(x_Area)
		DbSetOrder(x_Ind)
		DbGoto(x_Rec)
		If lMsErroAuto
			Mostraerro()
		endif
  Endif
Return(lMsErroAuto)	   

   */