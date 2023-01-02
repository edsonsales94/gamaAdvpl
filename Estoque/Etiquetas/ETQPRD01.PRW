#include 'totvs.ch'

User Function EtqPrd01()

   Private oBtn1 := Nil
   Private oBtn2 := Nil
   private oGet1 := nil
   Private oDlg 
   private cCod:=space(11)       
   

   DEFINE MSDIALOG oDlg FROM 3,1 TO 250,600 PIXEL TITLE "Etiquetagem de Lotes Produto Acabado" OF OMAINWND
  oDlg:lEscClose  := .F. // Desabilita a Tecla <Esc>
  oFont1 := TFont():New("AriaL",,-15,,.T.) // Definicao do Objeto da Fonte
  oFont2 := TFont():New("AriaL",,-30,,.T.) // Definicao do Objeto da Fonte
  oSay1 := tSay() :New(020,010 ,{||"O.de Producao"}  ,oDlg,,oFont1 ,,,,.T.)
  oSay2 := tSay() :New(040,010 ,{||space(40)}        ,oDlg,,oFont2 ,,,,.T.) 
  oSay3 := tSay() :New(060,010 ,{||space(40)}        ,oDlg,,oFont2 ,,,,.T.)   
  
  @ 010, 70 MSGET  oGet1 VAR cCod F3 "SC2" of oDlg PIXEL PICTURE  "@!"   SIZE 60,20  valid iif(BuscaOp(),.T.,.F.)  FONT oFont1

  @ 100, 010 BUTTON oBtn1 PROMPT "_Imprimir"    OF oDlg PIXEL     SIZE 060,020   ACTION Mat_etq1()
  @ 100, 240 BUTTON oBtn2 PROMPT "_Sair"  OF oDlg PIXEL  SIZE 060,020   ACTION oDlg:end()

  ACTIVATE MSDIALOG oDlg CENTERED
 

Return



static function BuscaOp()
  dbselectarea("SC2")               
  DBSETORDER(1)
  If !(dbseek(xFilial("SC2")+LEFT(cCod,11)))
     alert("Ordem de Produção Nao Encontrado!!!")
     oSay3:cCaption:=SPACE(40)
     oSay3:Refresh()
     Return .f.        
  Endif                                
  oSay2:cCaption:=left(Posicione("SB1",1,XFILIAL("SB1")+SC2->C2_PRODUTO,"B1_DESC"),40)
  oSay3:cCaption:= "Inicio.: "+dtoc(SC2->C2_DATPRI)+" Qtde : " +ALLTRIM(str(SC2->C2_QUANT)) 
  oSay2:nClrText:= 255 ; oSay2:Refresh() ; oSay3:Refresh() 
  
Return .t.




static function Mat_etq1()
 _cPorta :="LPT1"   /// IIf(left(Getmv("MV_PORTETQ"),3)=="COM",alltrim(Getmv("MV_PORTETQ"))+":9600,n,7,2","LPT1")  // Default 
 MSCBPRINTER("S600",_cPorta)      //,,151.87)
 MSCBCHKStatus(.F.)              // STATUS DA IMPRESSORA
     
 MSCBBEGIN(1, 4)      //Inicio da Imagem da Etiqueta 
    MSCBWRITE("^XA")  
       
                                
    /*CONTEUDO DOS TITULOS*/ 
    MSCBWRITE("^APR,80,60^FO0200,180")
	MSCBWRITE("^FWB^FD"+oSay2:cCaption+"^FS")           
	     
    MSCBWRITE("^FO0285,380^APR,110,90")
    MSCBWRITE("^FWB^FD Nr. O.P : "+ALLTRIM(cCod)+"^FS") 

    MSCBWRITE("^FO0400,730^APR,80,60")
    MSCBWRITE("^FWB^FDQTY ^FS") 

    MSCBWRITE("^FO0400,650^APR,80,60")
    MSCBWRITE("^FWB^FD NR. LOTE: XXXX  TURNO : COMERCIAL ^FS") 

                
    /************** CODIGOS DE BARRAS 39**************************/
    cCont1 :="^FD"+cCod+"^FS"    
    MSCBWRITE("^FO0490,400^BCB,150,N,N,N")
    MSCBWRITE(cCont1)
          
    MSCBWRITE("^FD^FS") 
    MSCBWRITE("^XZ")   
    MSCBEND() //Fim da Imagem da Etiqueta     

   
 MSCBCLOSEPRINTER()        // FECHA IMPRESSORA

Return