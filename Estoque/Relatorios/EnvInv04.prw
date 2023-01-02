#include "protheus.ch"
#Include "rwmake.ch" 

#DEFINE LINHAS 999

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AOCWMS03  ºAutor  ³ Aparecido Jane     º Data ³  09/07/2008 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressao de Etiqueta Para Enderecamento MP                º±±
±±º          ³ Especifico para Armazem Spare-Part                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ENVINV04() //ETQINVEN()
    Private cTipoEtq
	Private cCadastro := OemToAnsi("Impressão de Etiqueta P/ Inventário")
	
	PRIVATE aRotina := {	{"Pesquisar"			,"AxPesqui"  	, 0 , 1}	,;
							{"Imprimir Etiqueta"	,"U_LBLINVEN"	, 0 , 3}	}
	
	dbSelectArea("SB1")
	dbSetOrder(1)
	//set filter to B8_LOCAL = "02" .AND. B8_SALDO > 0
    cPerg:="ETQFIFO"
    If !Pergunte(cPerg,.T.)   
       MsgBox("Informe o tipo da etiqueta")
       Return 
    Endif 
    cTipoEtq:=Mv_Par01	
	mBrowse( 6, 1,22,75,"SB1",,,,,,)
Return Nil

/****************************************/
User Function LBLINVEN(nOpc)
	Local oDlg, oButton
	Private nQtdEtq := 0
	Private nQtdIn  := 0

	DEFINE MSDIALOG oDlg FROM 0,0 TO 150,270 PIXEL TITLE "Informar Volumes e Qtd/Volume"
	@ 23,10 SAY OemToAnsi("Qtd Volumes: ") SIZE 60,07 OF oDlg PIXEL	                                              
	@ 23,65 MSGET nQtdEtq Picture "@E 999,999.999" VALID (nQtdEtq > 0 ) SIZE 60,07 OF oDlg PIXEL COLOR CLR_HBLUE

	@ 38,10 SAY OemToAnsi("Qtd Por Volume: :") SIZE 60,07 OF oDlg PIXEL
	@ 38,65 MSGET nQtdIn Picture "@E 999,999.999" VALID (nQtdIn > 0 ) SIZE 60,07 OF oDlg PIXEL COLOR CLR_HBLUE
    
    //@ 23,10 SAY OemToAnsi("Qtd Por Volume: :") SIZE 60,07 OF oDlg PIXEL
	//@ 23,65 MSGET nQtdIn Picture "@E 999,999.999" VALID (nQtdIn > 0 ) SIZE 60,07 OF oDlg PIXEL COLOR CLR_HBLUE                                                                                                            

	DEFINE SBUTTON FROM 55,30 TYPE 1 ENABLE OF oDlg	ACTION (LBLPRINT(nQtdEtq,nQtdIn),oDlg:End())
	DEFINE SBUTTON FROM 55,80 TYPE 2 ENABLE OF oDlg	ACTION (oDlg:End())

	ACTIVATE MSDIALOG oDlg CENTERED

Return 


Static Function LBLPRINT(nQtdEtq,nQtdIn)

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		Local oFont06,oFont08,oFont09,oFont10,oFont11,oFont12,oFont14,oFont16,oFont18,oFont20,oFont50
		Local cQuery    := Space(1)
		Local cInvoice  := Space(1)
		Local _aArea	:= GetArea()
		Local Titulo	:= ''
		Local _nElem
		_lPri	:= .T.

		_nQtdVol := nQtdEtq
		_nQtdUni := nQtdIn
		_cCodPro := SB8->B8_PRODUTO
		
		DbSelectArea("SB1")
		DbSetOrder(1)
		//DbSeek(xFilial("SB1")+SB8->B8_PRODUTO,.F.)
		_cCodPro := SB1->B1_COD
		
		If Int(_nQtdUni) != _nQtdUni
			_nQtdUni	:= Transform(_nQtdUni,"@E 999999.99")
		Else
			_nQtdUni	:= Transform(_nQtdUni,"@E 999999")	
		Endif

		For _nElem := 1 To _nQtdVol // Qtde de Etiquetas
		    If cTipoEtq = 1
			   MSCBPRINTER("ZM400","LPT1",,,.f.,,,,)
			 Else  
               MSCBPRINTER("Z4M","LPT1",,,.f.,,,,)			  
			Endif 
			MSCBCHKStatus(.f.)

			_cSerial := GetMV("MV_AOCSER")
			DbSelectArea("SX6")
			DbSetOrder(1)
			If DbSeek(xFilial("SX6")+"MV_AOCSER",.F.)
				RecLock("SX6",.F.)
				SX6->X6_CONTEUD := Soma1(_cSerial,6)
				msUnlock()
			Endif
	
	        If cTipoEtq = 1 //Etiqueta de Fifo 100 mm por 130 mm
  			     MSCBBEGIN(1,6,130)        	        
	        	        MSCBBOX(10,10,195,250,02) //coluna 2
	        	        MSCBLineH(10,148,140,02,"B")
	        			MSCBLineV(140,10,250,02,"B")
	        	        MSCBLineV(132,148,250,02,"B")
	        	        MSCBLineV(119,148,250,02,"B")
	        	        MSCBLineV(106,148,250,02,"B")
	        	        MSCBLineV(092,10,250,02,"B")
	        			MSCBLineV(077,148,250,02,"B")
	        	        MSCBLineV(064,148,250,02,"B")
	        	        MSCBLineV(043,10,250,02,"B")
	        	        MSCBLineV(030,10,148,02,"B")   
	                    If Len(RTrim(SB1->B1_COD))>15 //Caso o codigo do produto seja maior de 15 caracteres
	        		      MSCBSAYBAR(160,20,Rtrim(SB1->B1_COD),'R','C',25,.f.,.f.,,,3,2)  
	        		      MSCBSAY(138,20,RTRIM(SB1->B1_COD),"R","0","130,110")		
	        	         Else
	        			  MSCBSAYBAR(160,20,RTRIM(SB1->B1_COD) ,'R','C',30,.f.,.f.,,,5,3)
	        			  MSCBSAY(138,20,RTRIM(SB1->B1_COD),"R","0","130,180")
	        			Endif       
	        			MSCBSAYBAR(110,20,"INV"+StrZero(YEAR(DATE()),4),'R','C',25 ,.f.,.f.,,,5,3)
	        			//MSCBSAY(095,020,"Lote "+SB8->B8_LOTECTL,"R","0","060,060") 
	        			MSCBSAY(095,020,"Lote "+"INV"+StrZero(YEAR(DATE()),4),"R","0","060,060")
	        			MSCBSAY(050,150,"Serial "+_cSerial,"R","0","060,060")
	        			MSCBSAY(130,150,"Fornecedor" ,"R","0","060,050")			
	        			MSCBSAY(117,150,"SPARE PARTS" ,"R","0","070,060")
	        			MSCBSAY(104,150,"Nota Fiscal/Invoice" ,"R","0","060,050")
	           //		MSCBSAY(091,150,SD1->D1_DOC + '/' + cInvoice ,"R","0","070,060")
	        			MSCBSAY(078,150,"Data do Recebimento" ,"R","0","060,050")
	            		MSCBSAY(065,150,DTOC(dDataBase) ,"R","0","070,060")
	        			MSCBSAY(078,015,"Quantidade"    ,"R","0","060,050")
	        			MSCBSAY(078,060, "   "          ,"R","0","060,050")
	        			MSCBSAY(017,160, "   "          ,"R","0","130,100")
	        			MSCBSAYBAR(050,020, " "         ,'R','C',25 ,.f.,.f.,,,5,3)
	        			MSCBSAY(033,015,"Descricao Produto" ," R","0","060,050")
	        			MSCBSAY(017,015,Left(SB1->B1_DESC,26) ,"R","0","070,060")
              Else  //Etiqueta de Fifo 095 mm por 060 mm
             	    	MSCBBEGIN(1,6,40)
		                MSCBBOX(03,03,140,089,05) //coluna 2
        				MSCBLineV(69,22,081,02,"B")
        		        nLin:=05
        		        If Len(RTrim(SB1->B1_COD))>15 //Caso o codigo do produto seja maior de 15 caracteres
        				   MSCBSAYBAR(06,nLin,Rtrim(SB1->B1_COD),'N','C',10,.f.,.f.,,,3,2)  
        				   MSCBSAY(10,nLin+11,RTRIM(SB1->B1_COD),"N","0","60,50")		
        			     Else
        				   MSCBSAYBAR(10,nLin,RTRIM(SB1->B1_COD) ,'N','C',10,.f.,.f.,,,3,2)
        				   MSCBSAY(10,nLin+11,RTRIM(SB1->B1_COD),"N","0","60,50")
        				Endif       

        				MSCBSAYBAR(10,nLin+20,"INV"+StrZero(YEAR(DATE()),4),'N','C',10 ,.f.,.f.,,,3,2)
        				//MSCBSAY(05,nLin+32,"Lote "+SB8->B8_LOTECTL,"N","0","050,040")	 //Trocar xxLoteXXXX por Sd1->D1_LoteCtl
		                MSCBSAY(05,nLin+32,"Lote "+"INV"+StrZero(YEAR(DATE()),4),"N","0","050,040") // Inventario
		
         		        MSCBLineH(05,22,140,05,"B") 
            			MSCBSAY(070,nLin+18,"Fornecedor" ,"N","0","040,030")			
        				MSCBSAY(070,nLin+24,"SPARE PARTS" ,"N","0","060,050")
        		        MSCBLineH(69,36,140,05,"B") 						
        				MSCBSAY(070,nLin+32,"Nota Fiscal/Invoice" ,"N","0","040,030")
        				MSCBSAY(070,nLin+45,"Data do Recebimento" ,"N","0","040,030")
        				MSCBSAY(070,nLin+50,DTOC(dDataBase) ,"N","0","060,050")
        		        MSCBLineH(069,49,140,05,"B") 										
        				MSCBSAY(070,nLin+59,"Serial "+_cSerial,"N","0","060,050")

        		        MSCBLineH(05,43,70,05,"B") 						
        				MSCBSAY(05,nLin+59,"Quantidade:"     ,"N","0","040,030")
        				MSCBSAY(35,nLin+59   ,"    "         ,"N","0","050,040")
        				MSCBSAYBAR(10,nLin+42, " "           ,'N','C',10 ,.f.,.f.,,,3,2)
        				MSCBSAY(090,nLin+68  , "   "         ,"N","0","080,60")
        		        MSCBLineH(05,70,140,05,"B") 						
        				MSCBSAY(05,nLin+68,"Descricao Produto" ,"N","0","060,050")   
        		        MSCBLineH(69,81,140,05,"B") 						
        				MSCBSAY(005,nLin+77,Left(SB1->B1_DESC,40) ,"N","0","040,030")
        	Endif 
			MSCBEND()  
			MSCBCLOSEPRINTER()			
		Next nElem
	
	RestArea(_aArea)
	
Return Nil