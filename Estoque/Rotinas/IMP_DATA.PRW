#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH" 

/*
Programa para importar DADOS de txt
Development: Reginaldo Souza
Date:  21/12/2005
*/


User Function IMP_DATA()
Private oGeraTxt
Private cString  := ""

cDir := "\DATA\table2.prn"

FileTmp()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da tela de processamento.                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cForne:=SPACE(8)
CLoja :=SPACE(2)

@ 200,1 TO 380,380 DIALOG oGeraTxt TITLE OemToAnsi("Importa dados de TXT")
@ 02,10 TO 080,190
@ 10,018 Say " Este programa ira gerar uma NF de retorno de beneficiamento, conforme os parame- "
@ 18,018 Say " tros definidos  pelo usuario,  com os registros do arquivo de "
@ 20,018 SAY "FORNECEDOR: "
@ 30,030 GET cForne PICTURE "@!" F3 "SA2" VALID !EMPTY(cForne)
@ 40,030 Get cLoja  Picture "@!" Valid ExistCpo("SA2",cForne+cLoja) 

@ 70,128 BMPBUTTON TYPE 01 ACTION OkGeraTxt()
@ 70,158 BMPBUTTON TYPE 02 ACTION Close(oGeraTxt)

Activate Dialog oGeraTxt Centered

Return




Static Function OkGeraTxt

Close(oGeraTxt)
Processa({|| RunCont() },"Processando...")

Return Nil




Static Function RunCont()

SD1->(dbSetorder(1))

ProcRegua(tmp->(lastrec()))

TMP->(dbGoTop())

Do while !TMP->(eof())
	
	cDoc  := ALLTRIM( SUBSTR(TMP->LINE,1,10) )
	cSer  := ALLTRIM( SUBSTR(TMP->LINE,12,1) )+SPAC(2)
	cCod  := ALLTRIM( SUBSTR(TMP->LINE,17,7) )+SPAC(8)
	cItem := ALLTRIM( SUBSTR(TMP->LINE,14,2) )+SPAC(2)
		
	nVlr := VAL( SUBSTR(TMP->LINE,25,10) )
	
	IncProc()
	
	//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM                                
	IF SD1->(dbSeek( xFilial("SD1")+cDoc+cSer+cForne+cLoja+cCod+cItem) )  .AND. ALLTRIM(SD1->D1_CF)=="1124"
		
		RecLock("SD1",.F.)
		SD1->D1_CUSTO := (SD1->D1_TOTAL-SD1->D1_VALICM) + nVlr
		msUnLock("SD1") 
		
	ELSE
	  Alert( "nao encontrou nf "+	cDoc )
	

		`
	ENDIF
	
	TMP->(dbSkip())
	
EndDo

TMP->( dbCloseArea() )

Return Nil




STATIC FUNCTION FileTmp()
Local aStru :={}
Local cCampo

aAdd(aStru,{"LINE" , "C" , 400 , 0} )
cArq := CriaTrab(aStru, .T.)
Use (cArq) Alias TMP Exclusive New
APPEND FROM  (cDir) SDF

RETURN NIL
