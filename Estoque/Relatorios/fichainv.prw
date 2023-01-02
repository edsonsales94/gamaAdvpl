#include "rwmake.ch"
#Include "Winapi.ch"
#Include "vkey.ch"
#Include "colors.ch"
#include "topconn.ch"                
#include "Protheus.Ch"
#include "Font.ch"

#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF
// Gerar etiqueta 
User Function FichaInv()  
Private nLinaCol //Linha do acols na Alteração 
Private dDTREFINV := CTOD(GetMv("MV_DTINVRF"))
Private lGeraPick := .T.
Private cCadastro := "Geração/impressão de Ficha de Inventário"
Private aRotina := { {"Pesquisar"       ,"AxPesqui"       , 0, 1} }
   AAdd(aRotina ,    {"Geração"         ,"u_Ficha_Gera()" , 0, 3} )  
   AAdd(aRotina ,    {"Impressão"       ,"u_Ficha_Imp()" , 0, 7} )    
Private   aCores := {{'LEFT(ZU_TIME,3)=="IMP"','ENABLE' } ,{'EMPTY(ZU_TIME)','BR_AZUL'},{'LEFT(ZU_TIME,1)=="C"','BR_VERMELHO'}}

dbSelectArea("SZU")
dbSetOrder(1)
mBrowse( 6,1,22,75,"SZU",,,,,,aCores)
dbSelectArea("SZU")
SET FILTER TO
Return
********************************************************************************************************************
User Function Ficha_Imp()
********************************************************************************************************************
SetPrvt("CBTXT,TITULO,CDESC1,CDESC2,CDESC3,CBCONT")
SetPrvt("WNREL,TAMANHO,LIMITE,CSTRING,ARETURN,NOMEPROG")
SetPrvt("ALINHA,NLASTKEY,CPERG,CTABTES,AREGISTROS,I")
SetPrvt("J,LCONTINUA,LCAB,CX,ADRIVER,NTIPO")
SetPrvt("LI,M_PAG,CABEC1,CABEC2,WTOT_PREN,WTOT_INJE")

SET CENTURY ON
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CbTxt     := ""
titulo    := "Etiquetas de Inventario"
cDesc1    := "Este relatorio ira emitir a etiquetas de Itens "
cDesc2    := "de Estoque a serem inventariados"
cDesc3    := ""
wnrel     := "Rst007PA"
tamanho   := "M"
limite    := 80
cString   := "SBF"
aReturn   := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
nomeprog  := "FichaInv"
aLinha    := { }
nLastKey  := 0
EtqPro    := {}
CbCont    := 0
lContinua := lCab := .T.
cX        := " "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao do cabecalho e tipo de impressao do relatorio      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aDriver   := ReadDriver()
nTipo     := IIF(aReturn[4]==1,15,18)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt     := SPACE(10)
cbcont    := 0
li        := 80
m_pag     := 1
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cPerg:="FInvIP"
aRegs:={}
aAdd(aRegs,{cPerg,'01' ,'Codigo de Produto ... ?',''				 ,''			 ,'mv_ch1','C'  ,15     ,0      ,0     ,'G','                                ','mv_par01','         '  ,''		 ,''	 ,'                ','      '   ,'        	   ',''    	 ,''  	  ,''	 ,'            '   ,'            ' ,''   	 ,''      ,''	 ,''	,'           ',''  		 ,''  	  ,''	 ,''	,''			,'' 	   ,''		 ,''	,'SB1',''})
aAdd(aRegs,{cPerg,'02' ,'... Codigo de Produto ?',''				 ,''			 ,'mv_ch2','C'  ,15     ,0      ,0     ,'G','naovazio                        ','mv_par02','         '  ,''		 ,''	 ,'                ','      '   ,'        	   ',''    	 ,''  	  ,''	 ,'            '   ,'            ' ,''   	 ,''      ,''	 ,''	,'           ',''  		 ,''  	  ,''	 ,''	,''			,'' 	   ,''		 ,''	,'SB1',''})
aAdd(aRegs,{cPerg,'03' ,'Local                 ?',''				 ,''			 ,'mv_ch3','C'  ,02     ,0      ,0     ,'G','naovazio                        ','mv_par03','         '  ,''		 ,''	 ,'                ','      '   ,'        	   ',''    	 ,''  	  ,''	 ,'            '   ,'            ' ,''   	 ,''      ,''	 ,''	,'           ',''  		 ,''  	  ,''	 ,''	,''			,'' 	   ,''		 ,''	,'74' ,''})
aAdd(aRegs,{cPerg,'04' ,'Endereço ...          ?',''				 ,''			 ,'mv_ch4','C'  ,15     ,0      ,0     ,'G','                                ','mv_par04','         '  ,''		 ,''	 ,'                ','      '   ,'        	   ',''    	 ,''  	  ,''	 ,'            '   ,'            ' ,''   	 ,''      ,''	 ,''	,'           ',''  		 ,''  	  ,''	 ,''	,''			,'' 	   ,''		 ,''	,'SBE',''})
aAdd(aRegs,{cPerg,'05' ,'... Endereço          ?',''				 ,''			 ,'mv_ch5','C'  ,15     ,0      ,0     ,'G','naovazio                        ','mv_par05','         '  ,''		 ,''	 ,'                ','      '   ,'        	   ',''    	 ,''  	  ,''	 ,'            '   ,'            ' ,''   	 ,''      ,''	 ,''	,'           ',''  		 ,''  	  ,''	 ,''	,''			,'' 	   ,''		 ,''	,'SBE',''})
aAdd(aRegs,{cPerg,'06' ,'Grupo    ...          ?',''				 ,''			 ,'mv_ch6','C'  ,04     ,0      ,0     ,'G','                                ','mv_par06','         '  ,''		 ,''	 ,'                ','      '   ,'        	   ',''    	 ,''  	  ,''	 ,'            '   ,'            ' ,''   	 ,''      ,''	 ,''	,'           ',''  		 ,''  	  ,''	 ,''	,''			,'' 	   ,''		 ,''	,'   ',''})
aAdd(aRegs,{cPerg,'07' ,'... Grupo             ?',''				 ,''			 ,'mv_ch7','C'  ,04     ,0      ,0     ,'G','naovazio                        ','mv_par07','         '  ,''		 ,''	 ,'                ','      '   ,'        	   ',''    	 ,''  	  ,''	 ,'            '   ,'            ' ,''   	 ,''      ,''	 ,''	,'           ',''  		 ,''  	  ,''	 ,''	,''			,'' 	   ,''		 ,''	,'   ',''})
aAdd(aRegs,{cPerg,'08' ,'Tipo     ...          ?',''				 ,''			 ,'mv_ch8','C'  ,02     ,0      ,0     ,'G','                                ','mv_par08','         '  ,''		 ,''	 ,'                ','      '   ,'        	   ',''    	 ,''  	  ,''	 ,'            '   ,'            ' ,''   	 ,''      ,''	 ,''	,'           ',''  		 ,''  	  ,''	 ,''	,''			,'' 	   ,''		 ,''	,'   ',''})
aAdd(aRegs,{cPerg,'09' ,'... Tipo              ?',''				 ,''			 ,'mv_ch9','C'  ,02     ,0      ,0     ,'G','naovazio                        ','mv_par09','         '  ,''		 ,''	 ,'                ','      '   ,'        	   ',''    	 ,''  	  ,''	 ,'            '   ,'            ' ,''   	 ,''      ,''	 ,''	,'           ',''  		 ,''  	  ,''	 ,''	,''			,'' 	   ,''		 ,''	,'   ',''})
aAdd(aRegs,{cPerg,'10' ,'Etiqueta Inicial      ?',''				 ,''			 ,'mv_cha','C'  ,06     ,0      ,0     ,'G','                                ','mv_par10','         '  ,''		 ,''	 ,'                ','      '   ,'        	   ',''    	 ,''  	  ,''	 ,'            '   ,'            ' ,''   	 ,''      ,''	 ,''	,'           ',''  		 ,''  	  ,''	 ,''	,''			,'' 	   ,''		 ,''	,'   ',''})
aAdd(aRegs,{cPerg,'11' ,'Etiqueta Final        ?',''				 ,''			 ,'mv_chb','C'  ,06     ,0      ,0     ,'G','                                ','mv_par11','         '  ,''		 ,''	 ,'                ','      '   ,'        	   ',''    	 ,''  	  ,''	 ,'            '   ,'            ' ,''   	 ,''      ,''	 ,''	,'           ',''  		 ,''  	  ,''	 ,''	,''			,'' 	   ,''		 ,''	,'   ',''})

//ValidPerg(aRegs,cPerg)
Pergunte(cPerg,.T.)

/*
wnrel := "inv001"            //Nome Default do relatorio em Disco
wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"")
If nLastKey == 27
	Set filter to
	Return
Endif
SetDefault(aReturn,cString)
If nLastKey == 27
   Set Filter to
   Return
Endif
RptStatus({|| f_Imp_Fich()},Titulo)
*/     
Processa({|| f_Imp_Fich(),"Processando Dados"})

Return

********************************************************************************************************************
Static Function f_Imp_Fich()
********************************************************************************************************************
Local cCampos,cQuery
Private oPrn := Nil
_aLista  := {} // Cria lista de controle de entrega                                     
cCampos:="ZU_FILIAL,ZU_COD,ZU_NUMETQ,ZU_DESC,ZU_UM,ZU_TIPO,ZU_LOCPAD,ZU_DATA,ZU_TIME,ZU_LOCALIZ,ZU_LOTECTL,ZU_GRUPO,R_E_C_N_O_,ZU_RUA"
cQuery  :=" SELECT COUNT(*) SOMA "
cQuery  +=" FROM "+RetSqlName("SZU")+" A "
cQuery  +=" WHERE A.D_E_L_E_T_ <> '*' AND "
cQuery  +=" ZU_FILIAL='"+xFilial("SZU")+"' AND "
cQuery  +=" ZU_LOCPAD = '"+Mv_Par03+"' AND "
cQuery  +=" ZU_NUMETQ  BETWEEN  '"+Mv_Par10+"' AND '"+Mv_Par11+"' AND"
cQuery  +=" ZU_COD     BETWEEN  '"+Mv_Par01+"' AND '"+Mv_Par02+"' AND"
cQuery  +=" ZU_LOCALIZ BETWEEN  '"+Mv_Par04+"' AND '"+Mv_Par05+"' AND"
cQuery  +=" ZU_GRUPO   BETWEEN  '"+Mv_Par06+"' AND '"+Mv_Par07+"' AND"
cQuery  +=" ZU_TIME  <>  'IMP'  AND"
cQuery  +=" ZU_TIPO    BETWEEN  '"+Mv_Par08+"' AND '"+Mv_Par09+"' "
cOrdem:="ZU_NUMETQ,ZU_LOCALIZ,ZU_COD"

nRegis  := U_ContaQ(@cQuery,"COUNT(*) SOMA",cCampos,cOrdem)
//TCQUERY cQuery ALIAS TRX New
TCQUERY cQuery ALIAS FIC New
//SetRegua(nRegis )

Processa({|| RReport(),"Processando Dados"})

DbSelectArea("FIC")
DbCloseArea()
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
/*
IF  EMPTY(MV_PAR01)
	MV_PAR01 := "01"
ENDIF
*/
Public nColFim:=2400
Public nLinFim := 4100, nLinha := 4500
//Public nLarg:=480, nAlt:=200
Public nLarg:=430, nAlt:=150
Public nLine, lImpr := .F., nPag := 1
Public nitens := 0

/*
IF MV_PAR07 > 0
	nitens := MV_PAR07 - 1
ENDIF
While B1_LOCPAD < mv_par01
	dbSkip()
End
*/

//If B1_LOCPAD != mv_par01

//	MsgBox("ARMAZEM NÃO ENCONTRADO. AS FICHAS NÃO SERÃO IMPRESSAS.","BUSCA ARMAZEM","ALERT")
//	Return

//EndIf

DO While !FIC->(EOF()) //B1_LOCPAD >= mv_par01 .And. B1_LOCPAD <= mv_par02
	
	//If B1_COD >= mv_par03 .And. B1_COD <= mv_par04
		nitens++
		nLine:=30
		//oPrn:SayBitmap(nLine+010,100,"\SYSTEM\Gama_OLD.bmp", nLarg,nAlt)
		oPrn:Say(nLine+10,100,SM0->M0_NOMECOM+iif(FIC->ZU_FILIAL=="01"," - INDUSTRIA"," - COMERCIO"), aFontes[1],,,,3)
		nLine+=40 
		msBar3( 'CODE128', 1.0,1.5 ,FIC->ZU_NUMETQ, oPrn, .F., , .T., 0.025, 0.6, .F., 'TAHOMA', 'B', .F. )
		oPrn:Say(nLine,820,"3ª CONTAGEM", aFontes[2],,,,3)
		oPrn:Say(nLine,1870,"QTD.", aFontes[4],,,,3)
		oPrn:Box(nLine,1850,nLine+150,nColFim)
		nLine+=100
		oPrn:Say(nLine, 605,"Nº da Ficha:" + cvaltochar(FIC->ZU_NUMETQ),aFontes[1],,,,3)
		oPrn:Say(nLine,1250,"Código: " + FIC->ZU_COD, aFontes[4],,,,3)
		nLine+=60
		oPrn:Say(nLine,55,Replica("-",130), aFontes[4],,,,3)
		nLine+=40
		//oPrn:SayBitmap(nLine+010,100,"\SYSTEM\Gama_OLD.bmp", nLarg,nAlt)
		oPrn:Say(nLine+10,100,SM0->M0_NOMECOM+iif(FIC->ZU_FILIAL=="01"," - INDUSTRIA"," - COMERCIO"), aFontes[1],,,,3)
		nLine+=40
		msBar3( 'CODE128', 2.8,1.5 ,FIC->ZU_NUMETQ, oPrn, .F., , .T., 0.025, 0.6, .F., 'TAHOMA', 'B', .F. )
		oPrn:Say(nLine,820,"3ª CONTAGEM", aFontes[2],,,,3)
		oPrn:Say(nLine,1700,cvaltochar(FIC->ZU_NUMETQ),aFontes[2],,,,3)
		nLine+=140
		oPrn:Box(nLine ,55,nLine+698,nColFim)
		
		CorpoFic()
		
		nLine+=238
		oPrn:Say(nLine,55,Replica("-",130), aFontes[4],,,,3)
		nLine+=40
		//oPrn:SayBitmap(nLine+010,100,"\SYSTEM\Gama_OLD.bmp", nLarg,nAlt)
		oPrn:Say(nLine+10,100,SM0->M0_NOMECOM+iif(FIC->ZU_FILIAL=="01"," - INDUSTRIA"," - COMERCIO"), aFontes[1],,,,3)
		nLine+=40
		msBar3( 'CODE128', 11.0,1.5 ,FIC->ZU_NUMETQ, oPrn, .F., , .T., 0.025, 0.6, .F., 'TAHOMA', 'B', .F. )
		oPrn:Say(nLine,820,"2ª CONTAGEM", aFontes[2],,,,3)
		oPrn:Say(nLine,1700,cvaltochar(FIC->ZU_NUMETQ) ,aFontes[2],,,,3)
		nLine+=140
		oPrn:Box(nLine ,55,nLine+700,nColFim)
		
		CorpoFic()
		 
		nLine+=242
		oPrn:Say(nLine,55,Replica("-",130), aFontes[4],,,,3)
		nLine+=40
		//oPrn:SayBitmap(nLine+010,100,"\SYSTEM\Gama_OLD.bmp", nLarg,nAlt)
		oPrn:Say(nLine+10,100,SM0->M0_NOMECOM+iif(FIC->ZU_FILIAL=="01"," - INDUSTRIA"," - COMERCIO"), aFontes[1],,,,3)
		nLine+=40
		msBar3( 'CODE128', 19.3,1.5 ,FIC->ZU_NUMETQ, oPrn, .F., , .T., 0.025, 0.6, .F., 'TAHOMA', 'B', .F. )
		oPrn:Say(nLine,820,"1ª CONTAGEM", aFontes[2],,,,3)
		oPrn:Say(nLine,1700,cvaltochar(FIC->ZU_NUMETQ) ,aFontes[2],,,,3)
		nLine+=140
		oPrn:Box(nLine ,55,nLine+700,nColFim)
		
		CorpoFic()
		
		aAdd( _aLista, {cvaltochar(FIC->ZU_NUMETQ),FIC->ZU_COD,FIC->ZU_GRUPO,FIC->ZU_LOCPAD,FIC->ZU_DESC})
		
		lImpr := .T.
		
	//EndIf
	
	
	SZU->(DbGoto(FIC->R_E_C_N_O_))
	
 	RecLock("SZU",.f.)
    SZU->ZU_TIME    := "IMP"
	MsUnLock()
	
	FIC->(dbSkip())
	
	IF lImpr == .T.
		oPrn:EndPage()
		oPrn:StartPage()
		lImpr := .F.
	ENDIF
	
ENDDO

If Len( _aLista ) == 0
	
	MsgBox("CÓDIGO NÃO ENCONTRADO. AS FICHAS NÃO SERÃO IMPRESSAS.","BUSCA CÓDIGO DE PRODUTO","ALERT")
	Return
	
EndIf

Cabec()

For i:= 1 To Len( _aLista )
	
	oPrn:Say(nLinha,  55,_aLista[ i, 01], aFontes[4],,,,3)
//	oPrn:Say(nLinha, 300,ALLTRIM(_aLista[ i, 02])+SPACE(3)+ALLTRIM(SUBSTR((_aLista[ i, 05]),1,30)), aFontes[4],,,,3)
	oPrn:Say(nLinha, 300,ALLTRIM(_aLista[ i, 02])+SPACE(3)+ALLTRIM(SUBSTR((_aLista[ i, 05]),1,22)), aFontes[4],,,,3)
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
oPrn:Say(nLine,  80,"Nº da Ficha: " + cvaltochar(FIC->ZU_NUMETQ) ,aFontes[1],,,,3)
oPrn:Say(nLine,1050,"Grupo: " + FIC->ZU_GRUPO, aFontes[1],,,,3)
nLine+=60
oPrn:Say(nLine,  80,"Tipo: " + FIC->ZU_TIPO, aFontes[1],,,,3)
oPrn:Say(nLine,1050,"Armazém: " + FIC->ZU_LOCPAD, aFontes[1],,,,3)
//oPrn:Say(nLine,1600,"Centro de Custo: "  + FIC->B1_CC, aFontes[1],,,,3)
oPrn:Say(nLine,1600,"Centro de Custo: " , aFontes[1],,,,3)
nLine+=60
oPrn:Say(nLine,  80,"Código: " + FIC->ZU_COD, aFontes[1],,,,3)
oPrn:Say(nLine,1050,"Unidade: " + FIC->ZU_UM, aFontes[1],,,,3)
oPrn:Say(nLine,1600,"Localizacao: " + IIF(LEN(ALLTRIM(FIC->ZU_LOCALIZ))>0,FIC->ZU_LOCALIZ,"______________"), aFontes[1],,,,3)
nLine+=60
oPrn:Say(nLine,  80,"Descrição: " + SUBS(FIC->ZU_DESC,1,80), aFontes[4],,,,3)
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












********************************************************************************************************************
User Function Ficha_Gera()
********************************************************************************************************************
Private aEtiq:={"",""}
cPerg:="LinvGE"
aRegs:={}
aAdd(aRegs,{cPerg,'01' ,'Codigo de Produto ... ?',''				 ,''			 ,'mv_ch1','C'  ,15     ,0      ,0     ,'G','                                ','mv_par01','         '  ,''		 ,''	 ,'                ','      '   ,'        	   ',''    	 ,''  	  ,''	 ,'            '   ,'            ' ,''   	 ,''      ,''	 ,''	,'           ',''  		 ,''  	  ,''	 ,''	,''			,'' 	   ,''		 ,''	,'SB1',''})
aAdd(aRegs,{cPerg,'02' ,'... Codigo de Produto ?',''				 ,''			 ,'mv_ch2','C'  ,15     ,0      ,0     ,'G','naovazio                        ','mv_par02','         '  ,''		 ,''	 ,'                ','      '   ,'        	   ',''    	 ,''  	  ,''	 ,'            '   ,'            ' ,''   	 ,''      ,''	 ,''	,'           ',''  		 ,''  	  ,''	 ,''	,''			,'' 	   ,''		 ,''	,'SB1',''})
aAdd(aRegs,{cPerg,'03' ,'Local                 ?',''				 ,''			 ,'mv_ch3','C'  ,02     ,0      ,0     ,'G','naovazio                        ','mv_par03','         '  ,''		 ,''	 ,'                ','      '   ,'        	   ',''    	 ,''  	  ,''	 ,'            '   ,'            ' ,''   	 ,''      ,''	 ,''	,'           ',''  		 ,''  	  ,''	 ,''	,''			,'' 	   ,''		 ,''	,'Z1' ,''}) 
aAdd(aRegs,{cPerg,'04' ,'Endereço ...          ?',''				 ,''			 ,'mv_ch4','C'  ,15     ,0      ,0     ,'G','                                ','mv_par04','         '  ,''		 ,''	 ,'                ','      '   ,'        	   ',''    	 ,''  	  ,''	 ,'            '   ,'            ' ,''   	 ,''      ,''	 ,''	,'           ',''  		 ,''  	  ,''	 ,''	,''			,'' 	   ,''		 ,''	,'SBE',''})
aAdd(aRegs,{cPerg,'05' ,'... Endereço          ?',''				 ,''			 ,'mv_ch5','C'  ,15     ,0      ,0     ,'G','naovazio                        ','mv_par05','         '  ,''		 ,''	 ,'                ','      '   ,'        	   ',''    	 ,''  	  ,''	 ,'            '   ,'            ' ,''   	 ,''      ,''	 ,''	,'           ',''  		 ,''  	  ,''	 ,''	,''			,'' 	   ,''		 ,''	,'SBE',''})
aAdd(aRegs,{cPerg,'06' ,'Grupo    ...          ?',''				 ,''			 ,'mv_ch6','C'  ,04     ,0      ,0     ,'G','                                ','mv_par06','         '  ,''		 ,''	 ,'                ','      '   ,'        	   ',''    	 ,''  	  ,''	 ,'            '   ,'            ' ,''   	 ,''      ,''	 ,''	,'           ',''  		 ,''  	  ,''	 ,''	,''			,'' 	   ,''		 ,''	,'   ',''})
aAdd(aRegs,{cPerg,'07' ,'... Grupo             ?',''				 ,''			 ,'mv_ch7','C'  ,04     ,0      ,0     ,'G','naovazio                        ','mv_par07','         '  ,''		 ,''	 ,'                ','      '   ,'        	   ',''    	 ,''  	  ,''	 ,'            '   ,'            ' ,''   	 ,''      ,''	 ,''	,'           ',''  		 ,''  	  ,''	 ,''	,''			,'' 	   ,''		 ,''	,'   ',''})
aAdd(aRegs,{cPerg,'08' ,'Tipo     ...          ?',''				 ,''			 ,'mv_ch8','C'  ,02     ,0      ,0     ,'G','                                ','mv_par08','         '  ,''		 ,''	 ,'                ','      '   ,'        	   ',''    	 ,''  	  ,''	 ,'            '   ,'            ' ,''   	 ,''      ,''	 ,''	,'           ',''  		 ,''  	  ,''	 ,''	,''			,'' 	   ,''		 ,''	,'   ',''})
aAdd(aRegs,{cPerg,'09' ,'... Tipo              ?',''				 ,''			 ,'mv_ch9','C'  ,02     ,0      ,0     ,'G','naovazio                        ','mv_par09','         '  ,''		 ,''	 ,'                ','      '   ,'        	   ',''    	 ,''  	  ,''	 ,'            '   ,'            ' ,''   	 ,''      ,''	 ,''	,'           ',''  		 ,''  	  ,''	 ,''	,''			,'' 	   ,''		 ,''	,'   ',''})
aAdd(aRegs,{cPerg,'10' ,'Etiqueta Inicial      ?',''				 ,''			 ,'mv_cha','C'  ,06     ,0      ,0     ,'G','                                ','mv_par10','         '  ,''		 ,''	 ,'                ','      '   ,'        	   ',''    	 ,''  	  ,''	 ,'            '   ,'            ' ,''   	 ,''      ,''	 ,''	,'           ',''  		 ,''  	  ,''	 ,''	,''			,'' 	   ,''		 ,''	,'   ',''})
aAdd(aRegs,{cPerg,'11' ,'Gera    Obsoletos     ?',''				 ,''			 ,'mv_chb','N'  ,01     ,0      ,0     ,'C','naovazio                        ','mv_par11','Sim      '  ,''		 ,''	 ,'                ','      '   ,'Nao     	   ',''    	 ,''  	  ,''	 ,'            '   ,'Apenas Obsol' ,''   	 ,''      ,''	 ,''	,'           ',''  		 ,''  	  ,''	 ,''	,''			,'' 	   ,''		 ,''	,'   ',''})
aAdd(aRegs,{cPerg,'12' ,'Gera    Etiquetas     ?',''				 ,''			 ,'mv_chc','N'  ,01     ,0      ,0     ,'C','naovazio                        ','mv_par12','Endereco '  ,''		 ,''	 ,'                ','      '   ,'Brancas 	   ',''    	 ,''  	  ,''	 ,'            '   ,'Estoque     ' ,''   	 ,''      ,''	 ,''	,'           ',''  		 ,''  	  ,''	 ,''	,''			,'' 	   ,''		 ,''	,'   ',''})
aAdd(aRegs,{cPerg,'13' ,'Quant. Etiq. Brancas  ?',''				 ,''			 ,'mv_chd','N'  ,05     ,0      ,0     ,'G','naovazio                        ','mv_par13','         '  ,''		 ,''	 ,'                ','      '   ,'        	   ',''    	 ,''  	  ,''	 ,'            '   ,'            ' ,''   	 ,''      ,''	 ,''	,'           ',''  		 ,''  	  ,''	 ,''	,''			,'' 	   ,''		 ,''	,'   ',''})
aAdd(aRegs,{cPerg,'14' ,'nao Gera os Endereços ?',''				 ,''			 ,'mv_che','C'  ,80     ,0      ,0     ,'G','                                ','mv_par14','         '  ,''		 ,''	 ,'                ','      '   ,'        	   ',''    	 ,''  	  ,''	 ,'            '   ,'            ' ,''   	 ,''      ,''	 ,''	,'           ',''  		 ,''  	  ,''	 ,''	,''			,'' 	   ,''		 ,''	,'   ',''}) 
aAdd(aRegs,{cPerg,'15' ,'Qual Rua              ?',''				 ,''			 ,'mv_chf','C'  ,02     ,0      ,0     ,'G','                                ','mv_par15','         '  ,''		 ,''	 ,'                ','      '   ,'        	   ',''    	 ,''  	  ,''	 ,'            '   ,'            ' ,''   	 ,''      ,''	 ,''	,'           ',''  		 ,''  	  ,''	 ,''	,''			,'' 	   ,''		 ,''	,'   ',''})
//ValidPerg(aRegs,cPerg)
Pergunte(cPerg,.F.)
IF !Pergunte(cPerg,.T.)
   Return
Endif
If Mv_Par12 = 1
   Processa( {|| f_Ger_End()} )
ElseIf Mv_Par12 = 2
   Processa( {|| f_Ger_Brc()} )
ElseIf Mv_Par12 = 3
   Processa( {|| f_Ger_Sal()} )
ElseIf Mv_Par12 = 4
   Processa( {|| f_Ger_Etique()} )
Endif
MsgBox("Etiquetas : "+aEtiq[1]+" - "+aEtiq[2])
Return




********************************************************************************************************************
Static FuncTion f_Ger_Etique()
********************************************************************************************************************
Local cQuery
Local cCampos
cCampos:="ZI2_COD,ZI2_DESC,ZI2_TIPO,ZI2_LOCAL,ZI2_LOCALI,ZI2_LOTE,ZI2_GRUPO,ZI2_UM"
cQuery  :=" SELECT COUNT(*) SOMA "
cQuery  +=" FROM "+RetSqlName("ZI2")+" A "
cQuery  +=" WHERE  A.D_E_L_E_T_ <> '*' AND "
cQuery  +=" ZI2_FILIAL='"+xFilial("ZI2")+"' AND "
cQuery  +=" ZI2_LOCAL = '"+Mv_Par03+"' AND "
cQuery  +=" ZI2_COD BETWEEN  '"+Mv_Par01+"' AND '"+Mv_Par02+"' AND"
cQuery  +=" ZI2_LOCALI BETWEEN  '"+Mv_Par04+"' AND '"+Mv_Par05+"' AND"
cQuery  +=" ZI2_GRUPO   BETWEEN  '"+Mv_Par06+"' AND '"+Mv_Par07+"' AND"
cQuery  +=" ZI2_TIPO    BETWEEN  '"+Mv_Par08+"' AND '"+Mv_Par09+"' "
cOrdem  :="ZI2_LOCALI,ZI2_COD"

nRegis  := U_ContaQ(@cQuery,"COUNT(*) SOMA",cCampos,cOrdem)
TCQUERY cQuery ALIAS TRX New

DbSelectArea("TRX")
DbGoTop()
ProcRegua(nRegis )
nNumEtq   :=f_NumEtq(mv_par10)
aEtiq[1]   :=nNumEtq //Primeira lista Gerada
While !Trx->(eof())
	IncProc()
	IF AllTrim(Trx->ZI2_Locali) $ Mv_Par14
	   Trx->(dbSkip())
	   LOOP
	ENDIF
	nNumEtq:=f_NumEtq(nNumEtq)
	aEtiq[2]:=nNumEtq //Segunda lista Gerada
    RecLock("SZU",.T.)
          SZU->ZU_FILIAL  := xFilial("SZU")
          SZU->ZU_NUMETQ  := nNumEtq
          SZU->ZU_COD     := Trx->ZI2_COD
          SZU->ZU_DESC    := LEFT(Trx->ZI2_DESC,30)
          SZU->ZU_UM      := Trx->ZI2_UM
          SZU->ZU_TIPO    := Trx->ZI2_TIPO
          SZU->ZU_LOCPAD  := Trx->ZI2_LOCAL
          SZU->ZU_DATA    := dDTREFINV
          SZU->ZU_Grupo   := Trx->ZI2_Grupo
          SZU->ZU_LOCALIZ := Trx->ZI2_LOCALI
          SZU->ZU_RUA     := SubStr(Trx->ZI2_LOCALI,3,2)
          SZU->ZU_ORIGEM  := "S"
          SZU->ZU_TIME    := Time()
          SZU->ZU_LOTECTL := Trx->ZI2_LOTE
    msUnLock("SZU")
    nNumEtq++
    DbSelectArea("TRX")
	Trx->(DBSKIP())
End
DbSelectArea("TRX")
DbCloseArea()

Return Nil



********************************************************************************************************************
Static FuncTion f_Ger_End()
********************************************************************************************************************
Local cQuery 
Local cCampos
cCampos:="BF_PRODUTO,BF_LOCAL,BF_LOCALIZ,B1_DESC,B1_UM,B1_TIPO,B1_GRUPO"
cQuery  :=" SELECT COUNT(*) SOMA "
cQuery  +=" FROM "+RetSqlName("SB1")+" A, "+RetSqlName("SBF")+" B "
cQuery  +=" WHERE A.B1_FILIAL='"+XFILIAL("SB1")+"' AND A.D_E_L_E_T_ <> '*' AND B.D_E_L_E_T_ <> '*' AND "
If Mv_Par11 = 2
   cQuery  +=" B1_SITPROD <>'OB' AND "
   ElseIf Mv_Par11 = 3
   cQuery  +=" B1_SITPROD ='OB' AND "
Endif
cQuery  +=" B1_COD=BF_PRODUTO AND "
cQuery  +=" B1_FILIAL='"+xFilial("SB1")+"' AND "
cQuery  +=" BF_FILIAL='"+xFilial("SBF")+"' AND "
cQuery  +=" BF_LOCAL = '"+Mv_Par03+"' AND "
cQuery  +=" BF_QUANT > 0 AND "
cQuery  +=" BF_PRODUTO BETWEEN  '"+Mv_Par01+"' AND '"+Mv_Par02+"' AND"
cQuery  +=" BF_LOCALIZ BETWEEN  '"+Mv_Par04+"' AND '"+Mv_Par05+"' AND"
cQuery  +=" B1_GRUPO   BETWEEN  '"+Mv_Par06+"' AND '"+Mv_Par07+"' AND"
cQuery  +=" B1_TIPO    BETWEEN  '"+Mv_Par08+"' AND '"+Mv_Par09+"' "
cQuery  +=" GROUP BY BF_PRODUTO,BF_LOCAL,BF_LOCALIZ,B1_DESC,B1_UM,B1_TIPO,B1_GRUPO "
cOrdem  :="BF_LOCALIZ,BF_PRODUTO"

nRegis  := U_ContaQ(@cQuery,"COUNT(*) SOMA",cCampos,cOrdem)
TCQUERY cQuery ALIAS TRX New

DbSelectArea("TRX")
DbGoTop()
ProcRegua(nRegis )
nNumEtq   :=f_NumEtq(mv_par10)
aEtiq[1]   :=nNumEtq //Primeira lista Gerada 
While !Trx->(eof())
	IncProc()    
	IF AllTrim(Trx->bf_Localiz) $ Mv_Par14
	   Trx->(dbSkip())
	   LOOP
	ENDIF                                     
	nNumEtq:=f_NumEtq(nNumEtq)
	aEtiq[2]:=nNumEtq //Segunda lista Gerada 
    RecLock("SZU",.T.)
          SZU->ZU_FILIAL  := xFilial("SZU")
          SZU->ZU_NUMETQ  := nNumEtq
          SZU->ZU_COD     := Trx->BF_PRODUTO
          SZU->ZU_DESC    := LEFT(Trx->B1_DESC,30)
          SZU->ZU_UM      := Trx->B1_UM 
          SZU->ZU_TIPO    := Trx->B1_TIPO
          SZU->ZU_LOCPAD  := Trx->BF_LOCAL 
          SZU->ZU_DATA    := dDTREFINV
          SZU->ZU_Grupo   := Trx->B1_Grupo
          SZU->ZU_LOCALIZ := Trx->BF_LOCALIZ 
          SZU->ZU_RUA     := SubStr(Trx->BF_LOCALIZ,1,2)
          SZU->ZU_ORIGEM  := "S" 
          SZU->ZU_TIME    := Time()
    msUnLock("SZU")
    nNumEtq++
    DbSelectArea("TRX")
	Trx->(DBSKIP())
End
DbSelectArea("TRX")
DbCloseArea()

Return Nil
********************************************************************************************************************
Static FuncTion f_Ger_Brc()
********************************************************************************************************************
Local nNumEtq, ix
nNumEtq:=f_NumEtq(Mv_Par10)
aEtiq[1]   :=nNumEtq //Primeira lista Gerada 
ProcRegua(Mv_Par13)
For ix:=1 to Mv_Par13
	IncProc()                             
	nNumEtq:=f_NumEtq(nNumEtq)
	aEtiq[2]:=nNumEtq //Segunda lista Gerada 	
	DbSelectArea("SZU")
    RecLock("SZU",.T.)
      SZU->ZU_FILIAL  := xFilial("SZU")
      SZU->ZU_NUMETQ  := nNumEtq
      SZU->ZU_LOCPAD  := Mv_par03
      SZU->ZU_DATA    := dDTREFINV
      SZU->ZU_RUA     := if(Empty(Mv_Par15),"",Mv_Par15)
      SZU->ZU_ORIGEM  := "B"
      SZU->ZU_TIME    :=TIME()
    MsUnLock("SZU")
    nNumEtq++
Next
Return Nil
********************************************************************************************************************
Static FuncTion f_Ger_Sal()
********************************************************************************************************************
Local cQuery 
Local cCampos
    cCampos:="B2_COD,B2_LOCAL,B1_DESC,B1_UM,B1_TIPO,B1_GRUPO"
    cQuery  :=" SELECT COUNT(*) SOMA "
    cQuery  +=" FROM "+RetSqlName("SB1")+" A, "+RetSqlName("SB2")+" B "
    cQuery  +=" WHERE A.B1_FILIAL='"+XFILIAL("SB1")+"' AND A.D_E_L_E_T_ <> '*' AND B.D_E_L_E_T_ <> '*' AND "
    If Mv_Par11 = 2
       cQuery  +=" B1_SITPROD <>'OB' AND "  
    Endif 
    cQuery  +=" B1_COD=B2_COD AND "     
    cQuery  +=" B1_FILIAL='"+xFilial("SB1")+"' AND " 
    cQuery  +=" B2_FILIAL='"+xFilial("SB2")+"' AND "
    cQuery  +=" B2_LOCAL = '"+Mv_Par03+"' AND "  
    cQuery  +=" B2_QATU > 0 AND " 
    cQuery  +=" B2_COD BETWEEN  '"+Mv_Par01+"' AND '"+Mv_Par02+"' AND" 
    cQuery  +=" B1_GRUPO   BETWEEN  '"+Mv_Par06+"' AND '"+Mv_Par07+"' AND"
    cQuery  +=" B1_TIPO    BETWEEN  '"+Mv_Par08+"' AND '"+Mv_Par09+"' "         
    cOrdem  :="B2_COD"


nRegis  := U_ContaQ(@cQuery,"COUNT(*) SOMA",cCampos,cOrdem)
TCQUERY cQuery ALIAS TRX New
DbSelectArea("TRX")
DbGotop()
ProcRegua(nRegis )
nNumEtq   :=f_NumEtq(mv_par10)
aEtiq[1]   :=nNumEtq //Primeira lista Gerada 
While !Trx->(eof())
	IncProc()                                 
   	    nNumEtq:=f_NumEtq(nNumEtq)
  	    aEtiq[2]:=nNumEtq //Segunda lista Gerada    	    
   	    DbSelectArea("SZU")
        RecLock("SZU",.T.)
          SZU->ZU_FILIAL  := xFilial("SZU")
          SZU->ZU_NUMETQ  := nNumEtq
          SZU->ZU_COD     := Trx->B2_COD
          SZU->ZU_DESC    := LEFT(Trx->B1_DESC,30)
          SZU->ZU_UM      := Trx->B1_UM 
          SZU->ZU_TIPO    := Trx->B1_TIPO
          SZU->ZU_LOCPAD  := Trx->B2_LOCAL 
          SZU->ZU_DATA    := dDTREFINV
          SZU->ZU_Grupo   := Trx->B1_Grupo
          SZU->ZU_RUA     := If(!u_fUsa_End(Trx->B2_COD),"",Mv_Par15)
          SZU->ZU_ORIGEM  := "S" 
          SZU->ZU_TIME    := TIME()
        msUnLock("SZU")
        nNumEtq++
    DbSelectArea("TRX")
	Trx->(DBSKIP())
End
DbSelectArea("TRX")
DbCloseArea()
Return Nil
************************************************************************************************************************************
Static Function ValidPerg()
************************************************************************************************************************************
Local i, j
_sAlias := Alias()
//aRegs := {}
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,6)
// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05       DEF01                                                          DEF02                                                      DEF03
For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next
dbSelectArea(_sAlias)
Return
********************************************************************************************************************
Static Function f_NumEtq(pNum)
********************************************************************************************************************
Local cAlias
Local cOrdem
calias:=alias()
cOrdem:=dbSetOrder()

DbSelectArea("SZU")
DbSetOrder(01)
If !DbSeek(xFilial("SZU")+pNum)
  //Retorna ao Status antes de entra no Sf2460i
  dbSelectArea(calias)
  dbSetOrder(cOrdem)
  //Return(pNum)
  Return( StrZero(Val(pNum),6) )
Endif 
While .T.
 pNum:= StrZero(Val(pNum)+1,6)
 If !DbSeek(xFilial("SZU")+pNum) 
   //Retorna ao Status antes de entra no Sf2460i
   dbSelectArea(calias)
   dbSetOrder(cOrdem)
   Return(pNum)
 Endif 
 If pNum="999999"
   Exit 
 Endif 
End     
//Retorna ao Status antes de entra no Sf2460i
dbSelectArea(calias)
dbSetOrder(cOrdem)
Return(pNum)
********************************************************************************************************************
Static Function MesExtenso(pMes)
********************************************************************************************************************
Local cMes
//
If pMes = 1
   cMes := "JANEIRO"  
 ElseIf pMes = 2
   cMes := "FEVEREIRO"
 ElseIf pMes = 3
   cMes := "MARCO"
 ElseIf pMes = 4
   cMes := "ABRIL"
 ElseIf pMes = 5
   cMes := "MAIO "
 ElseIf pMes = 6
   cMes := "JUNHO"
 ElseIf pMes = 7
   cMes := "JULHO "
 ElseIf pMes = 8
   cMes := "AGOSTO"
 ElseIf pMes = 9
   cMes := "SETEMBRO"
 ElseIf pMes = 10
   cMes := "OUTUBRO"
 ElseIf pMes = 11
   cMes := "NOVEMBRO"
 ElseIf pMes = 12
   cMes := "DEZEMBRO"
Endif 
Return(cMes)    