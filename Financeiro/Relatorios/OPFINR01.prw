#include "Protheus.ch"
#include "rwMake.ch"
/*________________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+--------+-------------------+¦¦
¦¦¦ Programa  ¦ OPFINR01   ¦ Autor ¦ Romualdo Neto / Ronaldo Gomes ¦ Data ¦ 12/08/2013 ¦¦¦
¦¦+-----------+------------+-------+----------------------+--------+-------------------+¦¦
¦¦¦ Descriçäo ¦ Relatório de Ordem de Pagamento Financeiro                             ¦¦¦
¦¦+-----------+------------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function OPFINR01()
 Local   cPerg    := PADR("OPFINR01", Len(SX1->X1_GRUPO))
 Local   cTitulo  := "Ordem de Pagamento"
 Private aExc     := {}
 Private oFormIni := Nil     
 Private lFirstTm := .T.
 Private nItens   := 0                         

	ValidPerg(cPerg)	
	Pergunte(cPerg, .F.)   
	
	@96,042 TO 323,505 DIALOG oFormIni TITLE "ORDEM DE PAGAMENTO"
		@08,010 TO 84,222
		@23,014 SAY "Esta rotina tem a finalidade de emitir relatório de Ordem de Pagamento "
		@33,014 SAY "conforme os parâmetros informados. "
	
		@91, 111 BUTTON "Parâmetros"	SIZE 40, 15 ACTION Pergunte(cPerg, .T.)
		@91, 152 BUTTON "OK" 		 	SIZE 30, 15 ACTION (Processa({|| RunProc(), "Selecionando dados...", cTitulo, .T. }), Close(oFormIni))
		@91, 183 BUTTON "Cancelar"		SIZE 40, 15 ACTION Close(oFormIni)	
	ACTIVATE DIALOG oFormIni CENTERED
	
Return Nil

Static Function RunProc()
	Private oEstVnd                                           
	Private hMin, hMax, wMin, wMax, tLinha
	Private nLin, nTotPag, lEntrou, nPrint                   
	Private lRoda   := .F.	
	Private aTotGer :=  {0,0,0,0,0}
	Private   nPagin  := 0
	Private cNf :=""                             
	Private cNfCC  :=""                   
    Private cNfCC2 :=""
    Private cProduto:=""
    
    fTabTmp()
	
	If (TRA->(EOF()))
		MsgStop("Não há dados a serem exibidos com os parâmetros informados!")
		TRA->(dbCloseArea())
		Return Nil
	Endif

	oEstVnd:= TMSPrinter():New("ORDEM DE PAGAMENTO")
	oEstVnd:SetPortrait() // ou SetLandscape()          
	
	hMin := 50
	hMax := 3100
	wMin := 50
	wMax := 3200                          
	
	DEFINE FONT oFontItem   NAME "Calibri"      SIZE 0,06 OF oEstVnd
	DEFINE FONT oFontItem2  NAME "Calibri" BOLD SIZE 0,06 OF oEstVnd
	DEFINE FONT oFontCab  	NAME "Arial"   BOLD SIZE 0,09 OF oEstVnd
	DEFINE FONT oFontCab2  	NAME "Arial"   BOLD SIZE 0,07 OF oEstVnd
	DEFINE FONT oFontCab3  	NAME "Arial"        SIZE 0,07 OF oEstVnd
	DEFINE FONT oFontCab4  	NAME "Arial"        SIZE 0,06 OF oEstVnd
	DEFINE FONT oFontCab5  	NAME "Arial"        SIZE 0,09 OF oEstVnd
	DEFINE FONT oFontTit    NAME "Arial"   BOLD SIZE 0,12 OF oEstVnd       
	DEFINE FONT oFontTit2   NAME "Arial"        SIZE 0,11 OF oEstVnd
	DEFINE FONT oFontTit3   NAME "Arial"   BOLD SIZE 0,06 OF oEstVnd
	DEFINE FONT oFontTit4   NAME "Arial"        SIZE 0,12 OF oEstVnd
	
	//ExecReport()                        
	
	
oEstVnd:StartPage() 
 WHILE !TRA->(EOF()) 

nLin:= 100  //linha Inicial,coluna Inicial,Linha Final,Coluna Final
oEstVnd:Box(85, 15, 185 , 2380 )//1º 
oEstVnd:Say(85 + 5,15+600,"PEDIDO DE EMISSÃO DE CHEQUE / ORDEM DE PAGAMENTO ", oFontTit,,,2) 
oEstVnd:Box(185, 15 , 285 , 2380 )//2°

oEstVnd:Box(185, 1400 , 285 ,2380 ) //DEPARTAMENTO
oEstVnd:Say(185 + 5,1400+5,"Departamento", oFontCab2,,,2)  

oEstVnd:Box(285, 15 , 1325,1400 ) //PAGAMENTO
oEstVnd:Say(285 + 5,20,"Pagamento em : ", oFontCab2,,,2)  
oEstVnd:Say(285 + 5,450,"Empresa : " +SM0->M0_NOMECOM, oFontCab5,,,2)  // CEMP
// INFORMAR EMPRESA
oEstVnd:Box(350, 130 , 380 ,180 ) //BOX CHEQUE
oEstVnd:Say(350,200,"CHEQUE", oFontCab2,,,2)  // CHEQUE
oEstVnd:Box(400, 130 , 430 ,180 ) //BOX ORDEM DE PAGTO
oEstVnd:Say(400,200,"ORDEM DE PAGTO / BOLETO", oFontCab2,,,2)  // ORDEM DE PAGTO
oEstVnd:Box(450, 130 , 480 ,180 ) //BOX DINHEIRO
oEstVnd:Say(450,200,"DINHEIRO / CAIXA", oFontCab2,,,2)  // DINHEIRO
oEstVnd:Box(500, 130 , 530 ,180 ) //BOX DEPOSITO/FORNECEDOR
oEstVnd:Say(500,200,"DEPOSITO/FORNECEDOR", oFontCab2,,,2)  // DEPOSITO/FORNECEDOR

	DO CASE
		CASE MV_PAR17 = 1
		oEstVnd:Say(350,155,"X", oFontCab2,,,2)
		CASE MV_PAR17 = 2
		oEstVnd:Say(400,155,"X", oFontCab2,,,2)
		CASE MV_PAR17 = 3
		oEstVnd:Say(450,155,"X", oFontCab2,,,2)
		OTHERWISE
		oEstVnd:Say(500,155,"X", oFontCab2,,,2)
	ENDCASE
 
oEstVnd:Say(650,20,"Valor R$", oFontTit4,,,2)  // VALOR 
nValor := TRA->E2_VALOR + TRA->E2_ACRESC - TRA->E2_DECRESC  //ALETRADO 11/02/15  CALCULAR ACRESCIMO E DECRESCIMO SOLICITADO POR REINALDO LOPES FINANCEIRO
   //-(TRA->E2_PIS+TRA->E2_COFINS+TRA->E2_CSLL) alterado para nao reter os impostos 25/09/2014 claudio

//oEstVnd:Say(650,300,Transform(TRA->E2_VALOR, "@E 999,999.99"),oFontTit4,,,2) //VALOR
IF EMPTY(TRA->E2_PARCELA)
 oEstVnd:Say(650,300,Transform(nValor, "@E 999,999.99"),oFontTit4,,,2) //VALOR
Endif
/*_______________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦¦ Autor ¦ Ronaldo Gomes - Totvs  ¦ Data: 28/10/2013 ¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

IF MV_PAR17 <> 4
oEstVnd:Say(800,20,"Depositar Banco: ", oFontCab2,,,2)  // Depositar Banco
oEstVnd:Say(1200,20,"Ag.", oFontCab2,,,2)  // Agencia
oEstVnd:Say(1200,300,"Conta Corrente", oFontCab2,,,2)  // Conta Corrente

ELSE

oEstVnd:Say(800,20,"Depositar Banco: ", oFontCab2,,,2)  // Depositar Banco
oEstVnd:Say(840,300,POSICIONE("SA6",1,XFILIAL("SA6")+ALLTRIM(TRA->A2_BANCO),"A6_NOME"), oFontTit2,,,2)  // Depositar Banco
oEstVnd:Say(1200,20,"Ag.", oFontCab2,,,2)  // Agencia
oEstVnd:Say(1240,80,TRA->A2_AGENCIA+" - "+TRA->A2_DVAGE, oFontTit2,,,2)
oEstVnd:Say(1200,300,"Conta Corrente", oFontCab2,,,2)  // Conta Corrente
oEstVnd:Say(1240,550,TRA->A2_NUMCON+" - "+TRA->A2_DVCTA, oFontTit2,,,2)  // Conta Corrente

ENDIF

/*
IF !EMPTY(TRA->A2_BANCO) 
oEstVnd:Say(840,300,POSICIONE("SA6",1,XFILIAL("SA6")+ALLTRIM(TRA->A2_BANCO),"A6_NOME"), oFontTit2,,,2)  // Depositar Banco
ENDIF
*/


oEstVnd:Say(950,20,"Titular da Conta : ", oFontCab2,,,2)  // Titular da Conta
oEstVnd:Say(990,300,SUBSTR(TRA->A2_XFAVORE,1,25), oFontTit2,,,2)
oEstVnd:Say(1030,300,SUBSTR(TRA->A2_XFAVORE,26,15), oFontTit2,,,2) 

oEstVnd:Say(1100,20,"CPF/CNPJ do Titular da Conta: ", oFontCab2,,,2)  // CPF/CNPJ do Titular da Conta

// INFORMAR CPF/CNPJ do Titular da Conta
//A2_AGENCIA,A2_BANCO,A2_NUMCON 
if len(alltrim(TRA->A2_CGC))>12
 oEstVnd:Say(1140,520,TRANSFORM(TRA->A2_CGC,"@R 99.999.999/9999-99"), oFontTit2,,,2)
else
 oEstVnd:Say(1140,520,TRANSFORM(TRA->A2_CGC,"@R 999.999.999-99"), oFontTit2,,,2)
endif 

// INFORMAR Conta Corrente
/*
oEstVnd:Say(1200,20,"Ag.", oFontCab2,,,2)  // Agencia
oEstVnd:Say(1240,80,TRA->A2_AGENCIA, oFontTit2,,,2)
oEstVnd:Say(1200,300,"Conta Corrente", oFontCab2,,,2)  // Conta Corrente
oEstVnd:Say(1240,550,TRA->A2_NUMCON, oFontTit2,,,2)  // Conta Corrente
*/



oEstVnd:Box(285, 1400 , 485 ,2380 ) //VENCIMENTO
oEstVnd:Say(285+5,1400+5,"Vencimento: ", oFontCab2,,,2)  // Vencimento
oEstVnd:Say(330,1720,DTOC(STOD(TRA->E2_VENCREA)), oFontTit4,,,2)

oEstVnd:Box(485, 1400 , 1325,2380 ) //CNPJ OU CPF
oEstVnd:Say(485+5,1400+5,"CNPJ OU CPF: ", oFontCab2,,,2)  // CNPJ OU CPF
oEstVnd:Say(540,1720,TRANSFORM(TRA->A2_CGC,iif(len(alltrim(TRA->A2_CGC))>12,"@R 99.999.999/9999-99","@R 999.999.999-99")), oFontTit2,,,2)  // CNPJ OU CPF
oEstVnd:Say(850,1400+5,"FAVORECIDO: ", oFontCab2,,,2)  // FAVORECIDO
oEstVnd:Say(900,1640,SUBSTRING(TRA->A2_NOME,1,25), oFontTit2,,,2)  // FAVORECIDO
oEstVnd:Say(940,1640,SUBSTRING(TRA->A2_NOME,26,15), oFontTit2,,,2)  // FAVORECIDO
//oEstVnd:Say(980,1640,SUBSTRING(TRA->A2_NOME,31,10), oFontTit2,,,2)  // FAVORECIDO



oEstVnd:Box(1325, 15 , 2086,1400 ) //DETALHES DO PAGAMENTO
oEstVnd:Say(1325+5,15+5,"Detalhes do Pagamento ", oFontCab2,,,2)  // Detalhes do Pagamento
//INFORMAR DETALHES DO PAGAMENTO
//linha Inicial,coluna Inicial,Linha Final,Coluna Final
oEstVnd:Box(1325, 1400 , 1370 ,1890 )//CANAIS DESC
oEstVnd:Say(1325+5,1600,"CANAIS ", oFontCab2,,,2)  //CANAIS

/*_______________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+------------------+¦¦
¦¦¦ Autor     ¦ Ronaldo Gomes      ¦ Data: 17/09/2013 ¦¦¦
¦¦+-----------+------------+-------+------------------+¦¦
¦¦¦ Descriçäo ¦ Chamada do RCCD01           		   ¦¦
¦¦+-----------+---------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
   //ACRESCENTADO EM 25/07/14 POR CLAUDIO PARA PEGAR A SERIE CORRETA DA NOTA
    cSerie:=POSICIONE("SF1",2,XFILIAL("SF1")+TRA->E2_FORNECE+TRA->E2_LOJA+TRA->E2_NUM,"F1_SERIE")
                                                                                     
	cNfCC:= POSICIONE("SD1",3,XFILIAL("SD1")+ALLTRIM(TRA->E2_EMISSAO)+TRA->E2_NUM+cSerie+ALLTRIM(TRA->E2_FORNECE)+ALLTRIM(TRA->E2_LOJA),"D1_RATEIO") 
	
	IF cNfCC =="2"
	cNfCC2:=POSICIONE("SD1",3,XFILIAL("SD1")+ALLTRIM(TRA->E2_EMISSAO)+TRA->E2_NUM+cSerie+ALLTRIM(TRA->E2_FORNECE)+ALLTRIM(TRA->E2_LOJA),"D1_CC")
	ENDIF

IF ( EMPTY(cNfCC2) .AND. cNfCC =="2" ) .OR. LEFT(TRA->E2_ORIGEM,3)=="FIN"
	cNfCC2 :=TRA->E2_CCD 
ENDIF 
 
 IF cNfCC =="1"
  //FONTE
  	  RCCD1(TRA->E2_FILIAL,TRA->E2_NUM,cSerie,TRA->E2_FORNECE,TRA->E2_LOJA)          
 ELSE
	
	oEstVnd:Say(1390,1440,SUBSTR(POSICIONE("CTT",1,XFILIAL("CTT")+cNfCC2,"CTT_DESC01"),1,12), oFontCab2,,,2)  // CANAIS
	oEstVnd:Say(225,1410,POSICIONE("CTT",1,XFILIAL("CTT")+cNfCC2,"CTT_DESC01"), oFontCab2,,,2) //DEPARTAMENTO
 ENDIF

linObs:=1400
oEstVnd:Say(1400,20,SUBSTR(TRA->E2_XOBS,1,40), oFontCab2,,,2) //OBS PEDIDO
oEstVnd:Say(1430,20,SUBSTR(TRA->E2_XOBS,41,40), oFontCab2,,,2) 
oEstVnd:Say(1460,20,SUBSTR(TRA->E2_XOBS,81,40), oFontCab2,,,2)
oEstVnd:Say(1490,20,SUBSTR(TRA->E2_XOBS,121,40), oFontCab2,,,2)
oEstVnd:Say(1520,20,SUBSTR(TRA->E2_XOBS,161,40), oFontCab2,,,2)
oEstVnd:Say(1550,20,SUBSTR(TRA->E2_XOBS,201,40), oFontCab2,,,2)
oEstVnd:Say(1580,20,SUBSTR(TRA->E2_XOBS,241,40), oFontCab2,,,2)
oEstVnd:Say(1610,20,SUBSTR(TRA->E2_XOBS,281,40), oFontCab2,,,2)
oEstVnd:Say(1640,20,SUBSTR(TRA->E2_XOBS,321,40), oFontCab2,,,2)
oEstVnd:Say(1670,20,SUBSTR(TRA->E2_XOBS,361,40), oFontCab2,,,2)
oEstVnd:Say(1700,20,SUBSTR(TRA->E2_XOBS,401,40), oFontCab2,,,2)
oEstVnd:Say(1730,20,SUBSTR(TRA->E2_XOBS,441,40), oFontCab2,,,2)
oEstVnd:Say(1760,20,SUBSTR(TRA->E2_XOBS,481,20), oFontCab2,,,2)

/*_______________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦¦ Autor ¦ Ronaldo Gomes - Totvs  ¦ Data: 25/10/2013 ¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
 TamObs := len(ALLTRIM(TRA->E2_XOBS))
 linObs := linObs + (30 * (iif( round(TamObs/40,0)==0 ,1, int(TamObs/40)+ iif(mod(TamObs,40)<>0,1,0) )  ) ) 
 
 oEstVnd:Say(linObs,20,SUBSTR(MV_PAR15,1,80), oFontCab2,,,2) ; linObs+= 30
 oEstVnd:Say(linObs,20,SUBSTR(MV_PAR18,1,80), oFontCab2,,,2) ; linObs+= 30
 oEstVnd:Say(linObs,20,SUBSTR(MV_PAR19,1,80), oFontCab2,,,2)

oEstVnd:Box(1325, 1400 , 1370 ,2380 )//VALOR DESC
oEstVnd:Say(1325+5,2090,"VALOR ", oFontCab2,,,2)

IF cNfCC =="1"
  //FONTE
  RCCD1(TRA->E2_FILIAL,TRA->E2_NUM,TRA->E2_PREFIXO,TRA->E2_FORNECE,TRA->E2_LOJA) 
ELSE
//oEstVnd:Say(1380,2080,Transform(TRA->E2_VALOR, "@E 999,999.99"), oFontCab2,,,2)  // VALOR
 IF EMPTY(TRA->E2_PARCELA)
   oEstVnd:Say(1380,2080,Transform(nValor, "@E 999,999.99"), oFontCab2,,,2)  // VALOR
 Endif  
//oEstVnd:Say(1380,2110,Transform(TRA->E2_VALOR, "999,999.99"), oFontTit4,,,2)  // VALOR
ENDIF    

oEstVnd:Box(1370, 1400 , 2021 ,1890 )//CANAIS
oEstVnd:Box(1370, 1400 , 2021 ,2380 )//VALOR


//linha Inicial,coluna Inicial,Linha Final,Coluna Final
oEstVnd:Box(2021, 1400 , 2086 ,1890 )//TOTAL
oEstVnd:Say(2033+5,1400+5,"TOTAL", oFontTit4,,,2) // TOTAL
//oEstVnd:Say(2021+5,1400+5,"TOTAL", oFontCab2,,,2)  // TOTAL
oEstVnd:Box(2021, 1400 , 2086 ,2380 )//TOTAL VALOR                             
//oEstVnd:Say(2038,2080,Transform(TRA->E2_VALOR, "@E 999,999,999.99"), oFontTit4,,,2)
 IF EMPTY(TRA->E2_PARCELA) 
   oEstVnd:Say(2038,2080,Transform(nValor, "@E 999,999,999.99"), oFontTit4,,,2) 
 Endif
//oEstVnd:Say(2046,2060,Transform(TRA->E2_VALOR, "999,999.99"), oFontCab2,,,2) 

//INFORMAR TOTAL

oEstVnd:Box(2086, 15 , 2156,580 ) //NF/DUPL DESC  
oEstVnd:Say(2086+5,250,"NF / DUPL", oFontCab2,,,2)  // NF / DUPL
oEstVnd:Say(2180,180,TRA->E2_NUM+" / "+TRA->E2_PARCELA, oFontCab2,,,2)  // NF / DUPL

oEstVnd:Box(2086, 580 , 2156,780 ) //VALOR DESC
oEstVnd:Say(2086+5,650,"VALOR", oFontCab2,,,2)  // VALOR
oEstVnd:Say(2180,630,Transform(TRA->E2_VALOR + TRA->E2_ACRESC - TRA->E2_DECRESC, "@E 999,999.99"), oFontCab2,,,2)  //atualizado por claudio 01/08/14 valor vindo sem as deducoes
// RETIRADO A RETENCAO EM 25/092014 -(TRA->E2_PIS+TRA->E2_COFINS+TRA->E2_CSL
oEstVnd:Box(2086, 780 , 2156,1400 ) //DATA DE VENCIMENTO DESC
oEstVnd:Say(2086+5,880,"DATA DE VENCIMENTO", oFontCab2,,,2)  //DATA DE VENCIMENTO
oEstVnd:Say(2180,1000,DTOC(STOD(TRA->E2_VENCREA)), oFontCab2,,,2)
oEstVnd:Box(2086, 1400 , 2156,2380 ) //HISTORICO DESC
oEstVnd:Say(2086+5,1405,"HISTÓRICO - quando for pagamento parcelado dividir os valores e as parcelas por vencimentos", oFontCab4,,,2)  //HISTÓRICO DESC

oEstVnd:Box(2156, 15 , 2498,580 ) //NF/DUPL
oEstVnd:Box(2156, 580 , 2498,780 ) //VALOR
oEstVnd:Box(2156, 780 , 2498,1400 ) //DATA DE VENCIMENTO
oEstVnd:Box(2156, 1400 , 2498,2380 ) //HISTORICO


oEstVnd:Box(2498, 15 , 2568,580 ) //VALOR TOTAL:
oEstVnd:Say(2498+5,15+5,"Valor Total:", oFontCab2,,,2)
oEstVnd:Box(2498, 580 , 2568,780 ) //VALOR R$
oEstVnd:Box(2498, 780 , 2568,1400 ) //VALOR LIVRE
oEstVnd:Box(2498, 1400 , 2568,2380 ) //VALOR LIVRE

oEstVnd:Box(2568, 15 , 2668,780 ) //EMITIDO POR: 
oEstVnd:Say(2568+5,15+5,"Emitida Por:", oFontCab2,,,2) 
oEstVnd:Say(2568+40,20,MV_PAR16, oFontCab2,,,2) 
oEstVnd:Box(2568, 780 , 2668,2380 ) //VISTO GERÊNCIA DAS ÁREAS
oEstVnd:Say(2568+5,1450,"Visto Gerência das Áreas", oFontCab2,,,2) 

oEstVnd:Box(2668, 15 , 2968,780 ) //VISTO DO EMISSOR 
oEstVnd:Box(2668, 780 , 2968,2380 ) //VISTO DAS GERÊNCIAS

oEstVnd:Box(2968, 15 , 3268,780 ) //APROVAÇÃO FINANCEIRA  1-PRESIDENTE,2-DIRETOR COMERCIAL/RH,3-CONTROLLER 
oEstVnd:Say(2968+5,15+10,"Aprovações Financeira", oFontCab2,,,2) 
oEstVnd:Say(3003,15+5,"1 - Presidente", oFontCab2,,,2) 
oEstVnd:Say(3033+5,15+5,"2 - Diretor Comercial/RH", oFontCab2,,,2) 
oEstVnd:Say(3063+5,15+5,"3 - Controller", oFontCab2,,,2) 
oEstVnd:Box(2968, 780 , 3268,2380 ) //VISTO DAS GERÊNCIAS
   
IF !EMPTY(TRA->E2_PARCELA)
	RPARCEL(TRA->E2_FILIAL,TRA->E2_PREFIXO,TRA->E2_NUM,TRA->E2_PARCELA,TRA->E2_TIPO,TRA->E2_NATUREZ,TRA->E2_FORNECE,TRA->E2_LOJA,TRA->E2_EMISSAO,TRA->E2_VENCREA,TRA->E2_VALOR+TRA->E2_ACRESC-TRA->E2_DECRESC)
ELSE
	oEstVnd:Say(2498+5,630,Transform(TRA->E2_VALOR+TRA->E2_ACRESC-TRA->E2_DECRESC, "@E 999,999.99"), oFontCab2,,,2)  
ENDIF
// FILIAL
oEstVnd:EndPage()
TRA->(DBSKIP())
	
ENDDO

oEstVnd:Preview()
	
TRA->(dbCloseArea())	
Return Nil


Static Function FTabTmp()	
Local cQry	:= ""
   	
    cQry := " SELECT E2_NUM,E2_TIPO,E2_FORNECE,E2_LOJA,E2_EMISSAO,E2_VENCREA,E2_VALOR,E2_HIST,E2_XOBS,A2_NOME,E2_PARCELA,A2_XFAVORE,E2_ACRESC,E2_DECRESC,E2_ORIGEM, " 
    cQry += " A2_AGENCIA,A2_DVAGE,A2_BANCO,A2_DVCTA,A2_NUMCON,A2_CGC,E2_CCD,E2_PREFIXO,E2_FILIAL,E2_NATUREZ,E2_PIS,E2_COFINS,E2_CSLL FROM "+RetSQLName("SE2") + " AS SE2 "
	cQry += " INNER JOIN " +RetSQLName("SA2") + " AS SA2 ON E2_FORNECE = A2_COD AND E2_LOJA = A2_LOJA "
	cQry += " AND SE2.D_E_L_E_T_ = '' AND SA2.D_E_L_E_T_ = '' AND E2_NUM >= '"+ALLTRIM(MV_PAR01)+"'AND E2_NUM <='"+ALLTRIM(MV_PAR02)+"' "
	cQry += " AND E2_PREFIXO >='"+ALLTRIM(MV_PAR03)+"' AND E2_PREFIXO < ='"+ALLTRIM(MV_PAR04)+"'" 
	cQry += " AND E2_FORNECE >='"+ALLTRIM(MV_PAR05)+"' AND E2_FORNECE < ='"+ALLTRIM(MV_PAR06)+"'" 
	cQry += " AND E2_LOJA >='"+ALLTRIM(MV_PAR07)+"' AND E2_LOJA  < ='"+ALLTRIM(MV_PAR08)+"'" 
	cQry += " AND E2_EMISSAO >='"+DTOS(MV_PAR09)+"' AND E2_EMISSAO  < ='"+DTOS(MV_PAR10)+"'"
	cQry += " AND E2_VENCREA >='"+DTOS(MV_PAR11)+"' AND E2_VENCREA  < ='"+DTOS(MV_PAR12)+"'"
	cQry += " AND E2_PARCELA >='"+ALLTRIM(MV_PAR13)+"' AND E2_PARCELA  < ='"+ALLTRIM(MV_PAR14)+"'" 
    cQry += " AND E2_FILIAL = '"+XFILIAL("SE2")+"' AND A2_FILIAL = '"+XFILIAL("SE2")+"' AND E2_SALDO > 0"   
    cQry +=" ORDER BY E2_VENCREA,E2_FORNECE "
	dbUseArea( .T., "TOPCONN", TcGenQry(,,CHANGEQUERY(cQry)), "TRA", .T., .F.)
	memowrite("Romualdo",cQry) 


Return Nil	

Static Function Rparcel(Rfil,Rpref,Rnum,Rparc,Rtipo,Rnatu,Rforn,Rloja,Remiss,Rvenre,Rvalor)	
Local cQry2	:= ""
Local _Nlinr:=2250
Local Ntot:= 0
//RPARCEL(TRA->E2_FILIAL,TRA->E2_PREFIXO,TRA->E2_NUM,TRA->E2_PARCELA,TRA->E2_TIPO,TRA->E2_NATUREZ,TRA->E2_FORNECE,TRA->E2_LOJA,TRA->E2_EMISSAO,TRA->E2_VENCREA)

	cQry2 := " SELECT E2_NUM,E2_TIPO,E2_FORNECE,E2_LOJA,E2_EMISSAO,E2_VENCREA,E2_VALOR,E2_HIST,E2_XOBS,A2_NOME,E2_PARCELA,A2_XFAVORE,E2_ACRESC,E2_DECRESC, " 
    cQry2 += " A2_AGENCIA,A2_DVAGE,A2_BANCO,A2_DVCTA,A2_NUMCON,A2_CGC,E2_CCD,E2_PREFIXO,E2_FILIAL,E2_NATUREZ FROM "+RetSQLName("SE2") + " AS SE2 "
	cQry2 += " INNER JOIN " +RetSQLName("SA2") + " AS SA2 ON E2_FORNECE = A2_COD AND E2_LOJA = A2_LOJA "
	cQry2 += " AND SE2.D_E_L_E_T_ = '' AND SA2.D_E_L_E_T_ = '' "
	cQry2 += " AND E2_FILIAL = '"+RFIL+"' "
	cQry2 += " AND A2_FILIAL = '"+RFIL+"' "
	cQry2 += " AND E2_PREFIXO = '"+RPREF+"' "
	cQry2 += " AND E2_NUM = '"+RNUM+"' "
	cQry2 += " AND E2_PARCELA > '"+RPARC+"' "
	cQry2 += " AND E2_TIPO = '"+RTIPO+"' "
	cQry2 += " AND E2_NATUREZ = '"+RNATU+"' "
	cQry2 += " AND E2_FORNECE = '"+RFORN+"' "
	cQry2 += " AND E2_LOJA = '"+RLOJA+"' "
	cQry2 += " AND E2_EMISSAO = '"+REMISS+"' "
	cQry2 += " AND E2_VENCREA >= '"+RVENRE+"' "
	cQry2 += " AND E2_SALDO > 0"
	cQry2 += " ORDER BY E2_VENCREA "
	dbUseArea( .T., "TOPCONN", TcGenQry(,,CHANGEQUERY(cQry2)), "TRB", .T., .F.)
	memowrite("Romualdo2",cQry2) 
	 
	 	WHILE !TRB->(EOF()) 
		oEstVnd:Say(_Nlinr,180,TRB->E2_NUM+" / "+TRB->E2_PARCELA, oFontCab2,,,2)
		oEstVnd:Say(_Nlinr,630,Transform(TRB->E2_VALOR+TRB->E2_ACRESC-TRB->E2_DECRESC, "@E 999,999.99"), oFontCab2,,,2) 
		oEstVnd:Say(_Nlinr,1000,DTOC(STOD(TRB->E2_VENCREA)), oFontCab2,,,2)
		_Nlinr:=_Nlinr+40   //ALTERADO PARA ALOCAR ATE 7 PARCELAS por claudio 23/01/14
		Ntot:=Ntot+TRB->E2_VALOR+TRB->E2_ACRESC-TRB->E2_DECRESC
		IF _Nlinr >2450
		Rvalor:=Rvalor+Ntot
		oEstVnd:Say(2498+5,630,Transform(Rvalor, "@E 999,999.99"), oFontCab2,,,2)  
		TRB->(dbCloseArea())
		Return Nil
		ENDIF
		TRB->(DBSKIP())
		ENDDO
		Rvalor:=Rvalor+Ntot
		oEstVnd:Say(2498+5,630,Transform(Rvalor, "@E 999,999.99"), oFontCab2,,,2)  
        oEstVnd:Say(650,300,Transform(Rvalor, "@E 999,999.99"),oFontTit4,,,2) // 07/07/2014 alterado por claudio 
        oEstVnd:Say(1380,2080,Transform(Rvalor, "@E 999,999.99"), oFontCab2,,,2)  // 07/07/2014 alterado por claudio para atender valor total de titulos parcelados
        oEstVnd:Say(2038,2080,Transform(Rvalor, "@E 999,999,999.99"), oFontTit4,,,2) // 07/07/2014 alterado por claudio
        
		TRB->(dbCloseArea())

Return Nil   
             
/*_______________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+------------------+¦¦
¦¦¦ Autor     ¦ Ronaldo Gomes      ¦ Data: 17/09/2013 ¦¦¦
¦¦+-----------+------------+-------+------------------+¦¦
¦¦¦ Descriçäo ¦ Query referente a Rateio 	     	   ¦¦
¦¦+-----------+---------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

Static Function RCCD1(ZFIL,ZNUM,ZSERIE,ZFORN,ZLOJA)	
//RCCD1(TRA->E2_FILIAL,TRA->E2_NUM,TRA->E2_PREFIXO,TRA->E2_FORNECE,TRA->E2_LOJA)
Local cQry3	:= ""
Local _Nlin:=1390
LOCAL aTotCC := {}
LOCAL nI

	cQry3 += " SELECT DE_FILIAL,DE_DOC,DE_SERIE,DE_FORNECE,DE_LOJA,DE_ITEMNF,DE_ITEM,DE_CC,CTT_DESC01,DE_CUSTO1 " 
	cQry3 += " FROM " +RetSQLName("SDE")+ " AS SDE INNER JOIN " +RetSQLName("CTT")+ " AS CTT ON DE_CC = CTT_CUSTO "
	cQry3 += " AND SDE.D_E_L_E_T_ = '' AND CTT.D_E_L_E_T_ = '' "
	cQry3 += " AND DE_FILIAL = '01' "
	//cQry3 += " AND CTT_FILIAL = '01' "
	cQry3 += " AND DE_DOC = '"+ZNUM+"' "
	cQry3 += " AND DE_SERIE = '"+ZSERIE+"' "
	cQry3 += " AND DE_FORNECE = '"+ZFORN+"' "
	cQry3 += " AND DE_LOJA = '"+ZLOJA+"' "
	cQry3 += " ORDER BY DE_CC "	
	dbUseArea( .T., "TOPCONN", TcGenQry(,,CHANGEQUERY(cQry3)), "TRC", .T., .F.)
	memowrite("Ronaldo",cQry3) 
	
	TRC->( dbGotop() )    
	DO WHILE !TRC->(EOF()) 
		IF ( nI := aScan(aTotCC , {|x| x[1]== TRC->DE_CC} ) ) == 0
			aadd(aTotCC, {TRC->DE_CC , SUBSTR(TRC->CTT_DESC01,1,12) , 0 } )
			nI := LEN( aTotCC )
	     ENDIF
		aTotCC[nI,3] += TRC->DE_CUSTO1 
		
		TRC->(DBSKIP())
	ENDDO	   
	
	FOR nI:=1 TO LEN(aTotCC)
	
		oEstVnd:Say(_Nlin,1440,(aTotCC[nI,1])+"-"+aTotCC[nI,2], oFontCab2,,,2)  // CANAIS
	    oEstVnd:Say(_Nlin,2080,Transform(aTotCC[nI,3], "@E 999,999,999.99"), oFontCab2,,,2)  // VALOR

	    _Nlin:=_Nlin+30
		
		IF _Nlin =1870
			TRC->(dbCloseArea())
			Return Nil
		ENDIF
		
	NEXT nI
		
		/*
		WHILE !TRC->(EOF()) 

        oEstVnd:Say(_Nlin,1440,(TRC->DE_CC)+"-"+SUBSTR(TRC->CTT_DESC01,1,12), oFontCab2,,,2)  // CANAIS
	    oEstVnd:Say(_Nlin,2080,Transform(TRC->DE_CUSTO1, "999,999,999.99"), oFontCab2,,,2)  // VALOR

	    _Nlin:=_Nlin+30
		
			IF _Nlin =1870
			TRC->(dbCloseArea())
			Return Nil
			ENDIF
		TRC->(DBSKIP())
		ENDDO
		*/

	oEstVnd:Say(225,1410,"DIVERSOS", oFontCab2,,,2) //DEPARTAMENTO
	TRC->(dbCloseArea())

Return Nil   

/*______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Rotina    ¦ ValidPerg  ¦ Autor ¦ Romualdo Neto        ¦ Data ¦ 12/08/2013 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Tem a finalidade de montar as perguntas (SX1) do relatório    ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg(cPerg)
	PutSX1(cPerg,"01","Titulo De", "", "", "mv_ch1", "C", 09,00,00,"G","","   ","","","mv_par01")   	
  	PutSX1(cPerg,"02","Titulo Ate?", "", "", "mv_ch2", "C", 09,00,00,"G","","   ","","","mv_par02")   	
  	PutSX1(cPerg,"03","Prefixo De?", "", "", "mv_ch3", "C", 03,00,00,"G","","   ","","","mv_par03")   
	PutSX1(cPerg,"04","Prefixo Ate?", "", "", "mv_ch4", "C", 03,00,00,"G","","   ","","","mv_par04")   
	PutSX1(cPerg,"05","Fornece De?", "", "", "mv_ch5", "C", 08,00,00,"G","","SA2","","","mv_par05")   	
    PutSX1(cPerg,"06","Fornece Ate?", "", "", "mv_ch6", "C", 08,00,00,"G","","SA2","","","mv_par06")   	
    PutSX1(cPerg,"07","Loja De?", "", "", "mv_ch7", "C", 02,00,00,"G","","","","","mv_par07")     
	PutSX1(cPerg,"08","Loja Ate?", "", "", "mv_ch8", "C", 02,00,00,"G","","","","","mv_par08")     
	PutSX1(cPerg,"09","Emissao De?", "", "", "mv_ch9", "D", 08,00,00,"G","","   ","","","mv_par09")
	PutSX1(cPerg,"10","Emissao Ate?", "", "", "mv_cha", "D", 08,00,00,"G","","   ","","","mv_par10")
	PutSX1(cPerg,"11","Vencimento Real De?", "", "", "mv_chb", "D", 08,00,00,"G","","   ","","","mv_par11")
	PutSX1(cPerg,"12","Vencimento Real Ate?", "", "", "mv_chc", "D", 08,00,00,"G","","   ","","","mv_par12")
	PutSX1(cPerg,"13","Parcela De?", "", "", "mv_chd", "C", 03,00,00,"G","","","","","mv_par13")   
	PutSX1(cPerg,"14","Parcela Ate?", "", "", "mv_che", "C", 03,00,00,"G","","","","","mv_par14")   
	
	PutSX1(cPerg,"15","Detalhes", "", "", "mv_chf", "C", 80,00,00,"G","","   ","","","mv_par15") 
	PutSX1(cPerg,"16","Emitido Por?", "", "", "mv_chg", "C", 20,00,00,"G","","   ","","","mv_par16")
	PutSX1(cPerg,"17","Tipo Pagamento ?", "", "", "mv_chh", "N", 01,00,00,"C","","   ","","","mv_par17", "CHEQUE", "", "", "", "ORDEM DE PAGTO/BOLETO", "", "","DINHEIRO/CAIXA", "", "","DEPOSITO/FORNECEDOR","","")
    PutSX1(cPerg,"18","Detalhes Continuacao ", "", "", "mv_chf", "C", 80,00,00,"G","","   ","","","mv_par18") 
    PutSX1(cPerg,"19","Detalhes Continuacao ", "", "", "mv_chf", "C", 80,00,00,"G","","   ","","","mv_par19") 
	
Return Nil 
