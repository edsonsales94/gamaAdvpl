#include "rwmake.ch"
#include "topconn.ch"
#include "colors.ch"
#include "Protheus.Ch"
#include "Font.ch"

/*
Função     : FICAVU
Autor      : Romualdo Neto / Ronaldo Gomes
Data       : 
Descrição  : Emissao de Ficha de Inventário em modo grafico
Uso espec. : 
*/
                                                                                                     
User Function FICAVU()

Private cPerg := "FICAVU"
Private oPrn := Nil
CriaSx1()
Pergunte(cPerg,.T.)
_aLista  := {} // Cria lista de controle de entrega

If mv_par01 == Space(15)

	mv_par01 := "000000000000000"
	
EndIf	

If mv_par02 == Space(15)

	mv_par02 := "ZZZZZZZZZZZZZZZ"
	
EndIf

/*
_cQry := "SELECT B1_GRUPO,B1_TIPO,B1_LOCPAD,B1_COD,B1_UM,B1_DESC,B2_COD,B2_LOCAL,B2_QATU,A.R_E_C_N_O_ AS CHAVE "
_cQry += "FROM " + RetSqlName("SB1") + " A ," + RetSqlName("SB2") + " B "
_cQry += " WHERE A.D_E_L_E_T_ = '' AND B.D_E_L_E_T_ = '' "
_cQry += 	"AND B1_MSBLQL = '2' "
_cQry +=	"AND B1_COD = B2_COD "
_cQry +=	"AND B1_LOCPAD = B2_LOCAL "
_cQry +=	"AND B1_COD >= '" + mv_par01 + "' AND  B1_COD <= '" + mv_par02+ "' "
_cQry +=	"AND B1_LOCPAD NOT IN ('90','95','99') "
_cQry += "ORDER BY B1_COD"
*/

_cQry := "SELECT B1_GRUPO,B1_TIPO,B1_COD,B1_UM,B1_DESC,B1_CC,B2_COD,B2_LOCAL,B2_QATU, A.R_E_C_N_O_ AS CHAVE "
_cQry += "FROM " + RetSqlName("SB1") + " A ," + RetSqlName("SB2") + " B "
_cQry += " WHERE A.D_E_L_E_T_ = '' AND B.D_E_L_E_T_ = '' "
_cQry += 	"AND B1_MSBLQL = '2' "
_cQry +=	"AND B1_COD = B2_COD "
//_cQry +=	"AND B1_LOCPAD = B2_LOCAL "
_cQry +=	"AND B1_COD = '" + mv_par01 + "' "
_cQry +=	"AND B2_LOCAL NOT IN ('90','95','99') "
_cQry += "ORDER BY B2_COD,B2_LOCAL"

dbUseArea( .T., "TOPCONN", TcGenQry(,,CHANGEQUERY(_cQry)), "AVU", .T., .F. )

dbSelectArea("AVU")
dbGotop()

Processa({|| RReport(),"Processando Dados"})

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

  dbSelectArea("AVU")
  dbCloseArea()

Return .T.
      
/////////////////////////

Static Function RPrint()

RCabec()

RETURN
      
////////////////////////

Static Function RCabec()
Local i
Public nColFim:=2400
Public nLinFim := 4100, nLinha := 4500
Public nLarg:=480, nAlt:=200
Public nLine, lImpr := .F.

While B1_COD = mv_par01

 If B2_LOCAL >= mv_par02 .And. B2_LOCAL <= mv_par03
 
  nLine:=40
  oPrn:SayBitmap(nLine+010,100,"\SYSTEM\Gama_OLD.bmp", nLarg,nAlt) 
  nLine+=40
  oPrn:Say(nLine,820,"3ª CONTAGEM", aFontes[2],,,,3)
  oPrn:Say(nLine,1870,"QTD.", aFontes[4],,,,3)
  oPrn:Box(nLine,1850,nLine+150,nColFim)
  nLine+=100  
  oPrn:Say(nLine, 605,"Avulsa nº.: " + StrZero(CHAVE,6) + B2_LOCAL ,aFontes[1],,,,3)
  oPrn:Say(nLine,1250,"Código: " + B1_COD, aFontes[4],,,,3)
  nLine+=60
  oPrn:Say(nLine,55,Replica("-",130), aFontes[4],,,,3)
  nLine+=40
  oPrn:SayBitmap(nLine+010,100,"\SYSTEM\Gama_OLD.bmp", nLarg,nAlt) 
  nLine+=40
  oPrn:Say(nLine,820,"3ª CONTAGEM", aFontes[2],,,,3)
  oPrn:Say(nLine,1600,"FA " + StrZero(CHAVE,6) + B2_LOCAL ,aFontes[2],,,,3)
  nLine+=140
  oPrn:Box(nLine ,55,nLine+700,nColFim)

  CorpoFic()

  nLine+=240
  oPrn:Say(nLine,55,Replica("-",130), aFontes[4],,,,3)
  nLine+=40
  oPrn:SayBitmap(nLine+010,100,"\SYSTEM\Gama_OLD.bmp", nLarg,nAlt) 
  nLine+=40
  oPrn:Say(nLine,820,"2ª CONTAGEM", aFontes[2],,,,3)
  oPrn:Say(nLine,1600,"FA " + StrZero(CHAVE,6) + B2_LOCAL ,aFontes[2],,,,3)
  nLine+=140
  oPrn:Box(nLine ,55,nLine+700,nColFim)

  CorpoFic()

  nLine+=240
  oPrn:Say(nLine,55,Replica("-",130), aFontes[4],,,,3)
  nLine+=40
  oPrn:SayBitmap(nLine+010,100,"\SYSTEM\Gama_OLD.bmp", nLarg,nAlt) 
  nLine+=40
  oPrn:Say(nLine,820,"1ª CONTAGEM", aFontes[2],,,,3)
  oPrn:Say(nLine,1600,"FA " + StrZero(CHAVE,6) + B2_LOCAL ,aFontes[2],,,,3)
  nLine+=140
  oPrn:Box(nLine ,55,nLine+700,nColFim)
    
  CorpoFic()

  aAdd( _aLista, {StrZero(CHAVE,6) + B2_LOCAL,B1_COD,B1_GRUPO,B2_LOCAL})

  lImpr := .T.


 EndIf

  dbSkip()

  If lImpr == .T.

	oPrn:EndPage()
	oPrn:StartPage()
	lImpr := .F.
 
  EndIf

End

Cabec()

For i:= 1 To Len( _aLista )

    oPrn:Say(nLinha,  55,_aLista[ i, 01], aFontes[4],,,,3)
    oPrn:Say(nLinha, 300,_aLista[ i, 02], aFontes[4],,,,3)    
    oPrn:Say(nLinha, 800,_aLista[ i, 03], aFontes[4],,,,3)    
	oPrn:Say(nLinha,1000,_aLista[ i, 04], aFontes[4],,,,3) 
	oPrn:Say(nLinha,1300,"________", aFontes[4],,,,3)
	oPrn:Say(nLinha,1600,"________", aFontes[4],,,,3)	
	oPrn:Say(nLinha,1900,"________", aFontes[4],,,,3)	
		
	nLinha += 50
	
	If nLinha >= (nLinFim-850)

		oPrn:EndPage()
		oPrn:StartPage()
		Cabec()
		
	EndIf

Next

If nLinha >= (nLinFim-850)

	oPrn:EndPage()
	oPrn:StartPage()
	Cabec()
		
EndIf

nLinha += 180
oPrn:Say(nLinha, 100,"___________________________", aFontes[4],,,,3)

nLinha += 80
oPrn:Say(nLinha, 100,"Recebido em ____/____/____", aFontes[4],,,,3)

Return

/********************************************************************************************************/
//
//  .-----------------------------------------.
// |     Imprime Corpo da Ficha de Inventário  |
//  '-----------------------------------------'
//

Static Function CorpoFic()

  
  nLine+=20
  oPrn:Say(nLine,  80,"Avulsa nº.: "+StrZero(CHAVE,6)+B2_LOCAL ,aFontes[1],,,,3)
  oPrn:Say(nLine,1050,"Grupo: " + B1_GRUPO, aFontes[1],,,,3)
  nLine+=60
  oPrn:Say(nLine,  80,"Tipo: " + B1_TIPO, aFontes[1],,,,3)
  oPrn:Say(nLine,1050,"Armazém: " + B2_LOCAL, aFontes[1],,,,3)
  oPrn:Say(nLine,1600,"Centro de Custo: " + B1_CC, aFontes[1],,,,3)
  nLine+=60
  oPrn:Say(nLine,  80,"Código: " + B1_COD, aFontes[1],,,,3)
  oPrn:Say(nLine,1050,"Unidade: " + B1_UM, aFontes[1],,,,3)
  nLine+=60
  oPrn:Say(nLine,  80,"Descrição: " + SUBS(B1_DESC,1,80), aFontes[4],,,,3)
  nLine+=60
  oPrn:Line(nLine,55,nLine,nColFim)
  nLine+=40
  oPrn:Say(nLine,100 ,"Data ___/___/___",aFontes[1],,,,3)
  oPrn:Say(nLine,700 ,"Data ___/___/___",aFontes[1],,,,3)
  oPrn:Say(nLine,1300,"Data ___/___/___",aFontes[1],,,,3)
  oPrn:Say(nLine,1900,"Data ___/___/___",aFontes[1],,,,3)
  nLine+=60
  oPrn:Box(nLine ,100 ,nLine+150,500)
  oPrn:Say(nLine,105,"Qtd 01",aFontes[4],,,,3)     
  oPrn:Say(nLine,600,"+",aFontes[3],,,,3)
  oPrn:Box(nLine,700,nLine+150,1100)
  oPrn:Say(nLine,705,"Qtd 02",aFontes[4],,,,3)   
  oPrn:Say(nLine,1200,"+",aFontes[3],,,,3)
  oPrn:Box(nLine,1300,nLine+150,1700)
  oPrn:Say(nLine,1305,"Qtd 03",aFontes[4],,,,3)   
  oPrn:Say(nLine,1800,"=",aFontes[3],,,,3)
  oPrn:Box(nLine,1900,nLine+150,2300)
  oPrn:Say(nLine,1905,"Qtd Final",aFontes[4],,,,3)      
  nLine+=150
  oPrn:Box(nLine ,100,nLine+150,500)
  oPrn:Say(nLine,105,"Contado por:",aFontes[4],,,,3)        
  oPrn:Box(nLine,700,nLine+150,1100)
  oPrn:Say(nLine,705,"Contado por:",aFontes[4],,,,3)    
  oPrn:Box(nLine,1300,nLine+150,1700)
  oPrn:Say(nLine,1305,"Contado por:",aFontes[4],,,,3)    
  oPrn:Box(nLine,1900,nLine+150,2300)
  oPrn:Say(nLine,1905,"Responsável:",aFontes[4],,,,3)        

Return

/********************************************************************************************************/

Static Function Cabec

nLinha := 40
oPrn:SayBitmap(nLinha+010,100,"\SYSTEM\Gama_OLD.bmp", nLarg,nAlt) 
nLinha += 40
oPrn:Say(nLinha,820,"Relação de Fichas Avulsas Entregues", aFontes[1],,,,3)
nLinha += 180
oPrn:Say(nLinha,  55,"No.Ficha", aFontes[4],,,,3)
oPrn:Say(nLinha, 300,"Cod. Prod.", aFontes[4],,,,3)    
oPrn:Say(nLinha, 800,"Grupo", aFontes[4],,,,3)    
oPrn:Say(nLinha,1000,"Local", aFontes[4],,,,3)
oPrn:Say(nLinha,1300,"1ª.Cont.", aFontes[4],,,,3)
oPrn:Say(nLinha,1600,"2ª.Cont.", aFontes[4],,,,3)
oPrn:Say(nLinha,1900,"3ª.Cont.", aFontes[4],,,,3)
nLinha += 50    		
oPrn:Line(nLinha,55,nLinha,nColFim)
nLinha += 50

Return

/********************************************************************************************************/
//
//  .--------------------------------------.
// |     Cria grupo de perguntas no SX1     |
//  '--------------------------------------'
//

Static Function CriaSx1()

PutSX1(cPerg,"01","Do Produto  ","Do Produto  ","Do Produto  ","mv_ch1","C",15,0,0,"G","","SB1","","","mv_par01")
PutSX1(cPerg,"02","Do Local    ","Do Local    ","Do Local    ","mv_ch2","C",02,0,0,"G","","AL" ,"","","mv_par02")
PutSX1(cPerg,"03","Até o Local ","Até o Local ","Até o Local ","mv_ch3","C",02,0,0,"G","","AL" ,"","","mv_par03")

Return Nil
                                                                                                          
/**********************************************************************************************************/
