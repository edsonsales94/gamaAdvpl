/*
Função     : FICINV
Autor      : Romualdo Neto / Ronaldo Gomes
Data       :
Descrição  : Emissao de Ficha de Inventário em modo grafico
Uso espec. :
*/


#include "rwmake.ch"
#include "topconn.ch"
#include "colors.ch"
#include "Protheus.Ch"
#include "Font.ch"



User Function FICINV

Private cPerg := "FICINV"
Private oPrn := Nil
CriaSx1()
Pergunte(cPerg,.T.)



_aLista  := {} // Cria lista de controle de entrega

//_cQry := "SELECT B1_GRUPO,B1_TIPO,B1_LOCPAD,B1_COD,B1_UM,B1_DESC,B2_COD,B2_LOCAL,B2_QATU,ROW_NUMBER() OVER (ORDER BY B1_GRUPO,B1_COD,B1_LOCPAD) AS PAGI, A.R_E_C_N_O_ AS CHAVE "
_cQry := "SELECT B1_LOCPAD,B1_TIPO,B1_GRUPO,B1_COD,B2_LOCAL,B1_UM,B1_DESC,B1_CC,B2_QATU, A.R_E_C_N_O_ AS CHAVE "
_cQry += "FROM " + RetSqlName("SB1") + " A ," + RetSqlName("SB2") + " B "
_cQry += " WHERE A.D_E_L_E_T_ = '' AND B.D_E_L_E_T_ = '' "
_cQry += 	"AND B1_MSBLQL = '2' "
_cQry +=	"AND B1_COD = B2_COD "
_cQry +=	"AND B1_LOCPAD = B2_LOCAL "
_cQry +=	"AND B2_QATU <> 0 "
_cQry +=	"AND B1_GRUPO <> '' "
_cQry +=	"AND B1_LOCPAD IN ('01','11','80','98') AND B1_FILIAL = '"+XFILIAL("SB1")+"'"
_cQry +=	"AND B1_TIPO >= '"+MV_PAR05+"' AND B1_TIPO <= '"+MV_PAR06+"' "
_cQry +=	"AND B1_LOCPAD >= '"+MV_PAR01+"' AND B1_LOCPAD <= '"+MV_PAR02+"' "
_cQry +=	"AND B1_COD >= '"+MV_PAR03+"' AND B1_COD <= '"+MV_PAR04+"' "
_cQry += "  ORDER BY  B1_LOCPAD,B2_COD,B1_GRUPO,CHAVE "

dbUseArea( .T., "TOPCONN", TcGenQry(,,CHANGEQUERY(_cQry)), "FIC", .T., .F. )

dbSelectArea("FIC")
dbGotop()

If Eof()
	
	dbCloseArea()
	Return
	
Endif

Processa({|| RReport(),"Processando Dados"})

Return Nil



Static FUNCTION RReport()

oPrn := TMSPrinter():New("Ficha de Inventário")

DEFINE FONT oFont1  NAME "Courier New" SIZE 0,14 OF oPrn
DEFINE FONT oFont2  NAME "Courier New" SIZE 0,28 OF oPrn
DEFINE FONT oFont3  NAME "Courier New" SIZE 0,32 OF oPrn
DEFINE FONT oFont4  NAME "Courier New" SIZE 0,12 OF oPrn

oPrn:SetPortrait()				// Coloca a página em modo fotografia

aFontes:={oFont1,oFont2,oFont3,oFont4}

Processa({|X| lEnd := X, RPrint() })

oPrn:Preview()

oFont1:End()
oFont2:End()
oFont3:End()
oFont4:End()

dbSelectArea("FIC")
dbCloseArea()

Return .T.

/////////////////////////

Static Function RPrint()

RCabec()

RETURN

////////////////////////

Static Function RCabec()
Local i
IF  EMPTY(MV_PAR01)
	
	MV_PAR01 := "01"
	
ENDIF

Public nColFim:=2400
Public nLinFim := 4100, nLinha := 4500
//Public nLarg:=480, nAlt:=200
Public nLarg:=430, nAlt:=150
Public nLine, lImpr := .F., nPag := 1
Public nitens := 0

IF MV_PAR07 > 0
	
	nitens := MV_PAR07 - 1
	
ENDIF


While B1_LOCPAD < mv_par01
	
	dbSkip()
	
End

//If B1_LOCPAD != mv_par01

//	MsgBox("ARMAZEM NÃO ENCONTRADO. AS FICHAS NÃO SERÃO IMPRESSAS.","BUSCA ARMAZEM","ALERT")
//	Return

//EndIf

While B1_LOCPAD >= mv_par01 .And. B1_LOCPAD <= mv_par02
	
	If B1_COD >= mv_par03 .And. B1_COD <= mv_par04
		nitens++
		nLine:=40
		//oPrn:SayBitmap(nLine+010,100,"\SYSTEM\Gama_OLD.bmp", nLarg,nAlt)
		oPrn:Say(nLine+10,100,SM0->M0_NOMECOM, aFontes[1],,,,3)
		nLine+=40
		oPrn:Say(nLine,820,"3ª CONTAGEM", aFontes[2],,,,3)
		oPrn:Say(nLine,1870,"QTD.", aFontes[4],,,,3)
		oPrn:Box(nLine,1850,nLine+150,nColFim)
		nLine+=100
		oPrn:Say(nLine, 605,"Nº da Ficha:" + cvaltochar(nitens),aFontes[1],,,,3)
		oPrn:Say(nLine,1250,"Código: " + B1_COD, aFontes[4],,,,3)
		nLine+=60
		oPrn:Say(nLine,55,Replica("-",130), aFontes[4],,,,3)
		nLine+=40
		//oPrn:SayBitmap(nLine+010,100,"\SYSTEM\Gama_OLD.bmp", nLarg,nAlt)
		oPrn:Say(nLine+10,100,SM0->M0_NOMECOM, aFontes[1],,,,3)
		nLine+=40
		oPrn:Say(nLine,820,"3ª CONTAGEM", aFontes[2],,,,3)
		oPrn:Say(nLine,1700,cvaltochar(nitens),aFontes[2],,,,3)
		nLine+=140
		oPrn:Box(nLine ,55,nLine+700,nColFim)
		
		CorpoFic()
		
		nLine+=240
		oPrn:Say(nLine,55,Replica("-",130), aFontes[4],,,,3)
		nLine+=40
		//oPrn:SayBitmap(nLine+010,100,"\SYSTEM\Gama_OLD.bmp", nLarg,nAlt)
		oPrn:Say(nLine+10,100,SM0->M0_NOMECOM, aFontes[1],,,,3)
		nLine+=40
		oPrn:Say(nLine,820,"2ª CONTAGEM", aFontes[2],,,,3)
		oPrn:Say(nLine,1700,cvaltochar(nitens) ,aFontes[2],,,,3)
		nLine+=140
		oPrn:Box(nLine ,55,nLine+700,nColFim)
		
		CorpoFic()
		
		nLine+=240
		oPrn:Say(nLine,55,Replica("-",130), aFontes[4],,,,3)
		nLine+=40
		//oPrn:SayBitmap(nLine+010,100,"\SYSTEM\Gama_OLD.bmp", nLarg,nAlt)
		oPrn:Say(nLine+10,100,SM0->M0_NOMECOM, aFontes[1],,,,3)
		nLine+=40
		oPrn:Say(nLine,820,"1ª CONTAGEM", aFontes[2],,,,3)
		oPrn:Say(nLine,1700,cvaltochar(nitens) ,aFontes[2],,,,3)
		nLine+=140
		oPrn:Box(nLine ,55,nLine+700,nColFim)
		
		CorpoFic()
		
		aAdd( _aLista, {cvaltochar(nitens),B1_COD,B1_GRUPO,B1_LOCPAD,B1_DESC})
		
		lImpr := .T.
		
	EndIf
	
	dbSkip()
	
	If lImpr == .T.
		
		oPrn:EndPage()
		oPrn:StartPage()
		lImpr := .F.
		
	EndIf
	
End

If Len( _aLista ) == 0
	
	MsgBox("CÓDIGO NÃO ENCONTRADO. AS FICHAS NÃO SERÃO IMPRESSAS.","BUSCA CÓDIGO DE PRODUTO","ALERT")
	Return
	
EndIf

Cabec()

For i:= 1 To Len( _aLista )
	
	oPrn:Say(nLinha,  55,_aLista[ i, 01], aFontes[4],,,,3)
	oPrn:Say(nLinha, 300,ALLTRIM(_aLista[ i, 02])+SPACE(3)+ALLTRIM(SUBSTR((_aLista[ i, 05]),1,30)), aFontes[4],,,,3)
	//oPrn:Say(nLinha, 800,_aLista[ i, 03], aFontes[4],,,,3)
	oPrn:Say(nLinha,1150,_aLista[ i, 04], aFontes[4],,,,3)
	oPrn:Say(nLinha,1300,"________", aFontes[4],,,,3)
	oPrn:Say(nLinha,1600,"________", aFontes[4],,,,3)
	oPrn:Say(nLinha,1900,"________", aFontes[4],,,,3)
	
	nLinha += 50
	
	If nLinha > (nLinFim-850)
		
		oPrn:EndPage()
		oPrn:StartPage()
		Cabec()
		
	EndIf
	
Next

If nLinha > (nLinFim-850)
	
	oPrn:EndPage()
	oPrn:StartPage()
	Cabec()
	
EndIf

nLinha += 180
oPrn:Say(nLinha, 100,"___________________________", aFontes[4],,,,3)
//oPrn:Say(nLinha,1100,"___________________________", aFontes[4],,,,3)
nLinha += 80
oPrn:Say(nLinha, 100,"Recebido em ____/____/____", aFontes[4],,,,3)
//oPrn:Say(nLinha,1100,"Entregue em ____/____/____", aFontes[4],,,,3)

Return

/********************************************************************************************************/
//
//  .-----------------------------------------.
// |     Imprime Cor?po da Ficha de Inventário  |
//  '-----------------------------------------'
//

Static Function CorpoFic()


nLine+=20
oPrn:Say(nLine,  80,"Nº da Ficha: " + cvaltochar(nitens) ,aFontes[1],,,,3)
oPrn:Say(nLine,1050,"Grupo: " + B1_GRUPO, aFontes[1],,,,3)
nLine+=60
oPrn:Say(nLine,  80,"Tipo: " + B1_TIPO, aFontes[1],,,,3)
oPrn:Say(nLine,1050,"Armazém: " + B1_LOCPAD, aFontes[1],,,,3)
oPrn:Say(nLine,1600,"Centro de Custo: "  + B1_CC, aFontes[1],,,,3)
nLine+=60
oPrn:Say(nLine,  80,"Código: " + B1_COD, aFontes[1],,,,3)
oPrn:Say(nLine,1050,"Unidade: " + B1_UM, aFontes[1],,,,3)
nLine+=60
oPrn:Say(nLine,  80,"Descrição: " + SUBS(B1_DESC,1,80), aFontes[4],,,,3)
nLine+=60
oPrn:Line(nLine,55,nLine,nColFim)
nLine+=40

oPrn:Say(nLine,100 ,"Data ___/___/___",aFontes[1],,,,3)
//oPrn:Say(nLine,700 ,"Data ___/___/___",aFontes[1],,,,3)
//oPrn:Say(nLine,1300,"Data ___/___/___",aFontes[1],,,,3)
//oPrn:Say(nLine,1900,"Data ___/___/___",aFontes[1],,,,3)
nLine+=60
oPrn:Box(nLine ,100 ,nLine+150,500)

oPrn:Say(nLine,105,"Qtd Contada",aFontes[4],,,,3)
//oPrn:Say(nLine,600,"+",aFontes[3],,,,3)
//oPrn:Box(nLine,700,nLine+150,1100)
oPrn:Say(nLine,705,"Visto Funcionário",aFontes[4],,,,3)
//oPrn:Say(nLine,1200,"+",aFontes[3],,,,3)
//oPrn:Box(nLine,1300,nLine+150,1700)
oPrn:Say(nLine,1305,"Visto Conferente",aFontes[4],,,,3)
//oPrn:Say(nLine,1800,"=",aFontes[3],,,,3)
//oPrn:Box(nLine,1900,nLine+150,2300)
//oPrn:Say(nLine,1905,"Qtd Final Geral",aFontes[4],,,,3)
nLine+=150
oPrn:Box(nLine ,100,nLine+150,500)
oPrn:Say(nLine,105,"Contado por:",aFontes[4],,,,3)
// oPrn:Box(nLine,700,nLine+150,1100)
oPrn:Say(nLine,705,"___________________",aFontes[4],,,,3)
//oPrn:Box(nLine,1300,nLine+150,1700)
oPrn:Say(nLine,1305,"__________________",aFontes[4],,,,3)
//oPrn:Box(nLine,1900,nLine+150,2300)
//oPrn:Say(nLine,1905,"Responsável:",aFontes[4],,,,3)

Return

/********************************************************************************************************/

Static Function Cabec

nLinha := 40
//oPrn:SayBitmap(nLinha+010,100,"\SYSTEM\Gama_OLD.bmp", nLarg,nAlt)
oPrn:Say(nLinha,820,SM0->M0_NOMECOM, aFontes[1],,,,3)
nLinha += 40
oPrn:Say(nLinha,820,"Relação de Fichas Entregues"+Space(15)+"Pag.: "+StrZero(nPag,3), aFontes[1],,,,3)
nLinha += 180
oPrn:Say(nLinha,  55,"No.Ficha", aFontes[4],,,,3)
oPrn:Say(nLinha, 300,"Cod. Prod. Descrição", aFontes[4],,,,3)
//oPrn:Say(nLinha, 800,"Grupo", aFontes[4],,,,3)
oPrn:Say(nLinha,1150,"Local", aFontes[4],,,,3)
oPrn:Say(nLinha,1300,"1ª.Cont.", aFontes[4],,,,3)
oPrn:Say(nLinha,1600,"2ª.Cont.", aFontes[4],,,,3)
oPrn:Say(nLinha,1900,"3ª.Cont.", aFontes[4],,,,3)
nLinha += 50
oPrn:Line(nLinha,55,nLinha,nColFim)
nLinha += 50
nPag++

Return

/********************************************************************************************************/
//
//  .--------------------------------------.
// |     Cria grupo de perguntas no SX1     |
//  '--------------------------------------'
//

Static Function CriaSx1()

PutSX1(cPerg,"01","Do Armazem      ","Do Armazem      ","Do Armazem      ","mv_ch1","C", 2,0,0,"G","","","","","mv_par01")
PutSX1(cPerg,"02","Até o Armazem   ","Até o Armazem   ","Até o Armazem   ","mv_ch2","C", 2,0,0,"G","","","","","mv_par02")
PutSX1(cPerg,"03","Do Produto      ","Do Produto      ","Do Produto      ","mv_ch3","C",15,0,0,"G","","SB1","","","mv_par03")
PutSX1(cPerg,"04","Até o Produto   ","Até o Produto   ","Até o Produto   ","mv_ch4","C",15,0,0,"G","","SB1","","","mv_par04")
PutSX1(cPerg,"05","Do Tipo      ","Do Tipo      ","Do Tipo      ","mv_ch5","C",2,0,0,"G","","","","","mv_par05")
PutSX1(cPerg,"06","Até o Tipo   ","Até o Tipo   ","Até o Tipo   ","mv_ch6","C",2,0,0,"G","","","","","mv_par06")
PutSX1(cPerg,"07","Ini. Ficha Em?   ","Ini. Ficha Em?   ","Ini. Ficha Em?   ","mv_ch7","N",6,0,0,"G","","","","","mv_par07")

Return Nil

/**********************************************************************************************************/
