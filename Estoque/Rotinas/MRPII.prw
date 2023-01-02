#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 25/02/02
#INCLUDE "TOPCONN.CH"

#include "TOPCONN.CH"
User Function MRPII()        // incluido pelo assistente de conversao do AP5 IDE em 25/02/02

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cQuery
SetPrvt("NOPCA,ODLG,CMENS,CGRV,CGRVF1,CGRVD1")
SetPrvt("CTYPE,CARQUIVO,ACPO,CTRB,CSTRING,CDESC1")
SetPrvt("CDESC2,CDESC3,TAMANHO,ARETURN,NOMEPROG,LCONTINUA")
SetPrvt("ALINHA,NLASTKEY,LEND,TITULO,CABEC1,CABEC2")
SetPrvt("CCANCEL,LI,M_PAG,WNREL,TVALPAG,TVALCOB")
SetPrvt("TVALOUT,XTITPAG,XTITCOB,XTITOUT,NTIPO,XVALDOC")
SetPrvt("XVALPAG,")                                          



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MRPII    ³ Autor ³IVAN PENA              ³ Data ³ 05.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ :.Importacao de arquivo de MRP                             ³±±
±±³          ³ alimentando o sistema com os dados para emissao de Relator.³±±
±±³          ³                                                             ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
*/

Private cAlias1 :="\01\SHA010.dtc"
nOpca  := 0
oDlg   := ""
cMens  := ""
cGrv   := ""
cGrvF1 := ""
cGrvD1 := ""
cGrv   := ""

@ 96,13 To 310,592 DIALOG oDlg TITLE "Importacao de arquivo de MRP"
@ 18, 6 To 66, 287
@ 29, 15 SAY OemToAnsi("Este programa tem como objetivo Exportar dados dos arquivos de MRP.")
@ 80, 160 BUTTON "Exportar MRP"  SIZE 34, 11 ACTION OkProc()// Substituido pelo assistente de conversao do AP5 IDE em 25/02/02 ==> @ 80, 160 BUTTON "Importar"  SIZE 34, 11 ACTION Execute(A010I)
@ 80, 220 BMPBUTTON TYPE 2 ACTION A010Fim()            // Substituido pelo assistente de conversao do AP5 IDE em 25/02/02 ==> @ 80, 220 BMPBUTTON TYPE 2 ACTION Execute(A010Fim)
ACTIVATE DIALOG oDlg
Return 


Static Function OkProc()
Close(oDlg)
Processa( {|| A010I() }, "Processando registros ...." )
Return




Static Function A010I()

ProcRegua(0)
nOpca    := 0
cType    := "IMPORTACAO MRP | *.dtc"
cArquivo :="\01\SHA010.dtc"


cQuery := " DROP TABLE SHAMRP "
nErro := TCSQLExec(cQuery)
If nErro > 0
	msgstop("Nao foi possivel realizar a limpeza da tabela! Chame o Administrador! ","Erro ...")
Endif
cQuery := " DROP TABLE SH5MRP "
nErro := TCSQLExec(cQuery)

If nErro > 0
	msgstop("Nao foi possivel realizar a limpeza da tabela! Chame o Administrador! ","Erro ...")
Endif


IncProc("Processando ... ")
//
//
dbUseArea(.T. ,"CTREECDX" ,"\01\SHA010.dtc" ,"SHADTC" ,.T. , .T.)
dbSelectArea("SHADTC")
COPY TO SHAMRP VIA  "TOPCONN"

 
dbUseArea(.T. ,"CTREECDX" ,"\01\SH5010.dtc" ,"SH5DTC" ,.T. , .T.)
dbSelectArea("SH5DTC")
COPY TO SH5MRP VIA  "TOPCONN"
dbclosearea()

dbSelectArea("SHADTC")
dbGotop()
cod=""
While !Eof()
	IncProc("Processando ... ")
	cTipo:=POSICIONE("SB1",1,XFILIAL("SB1")+HA_PRODUTO,"B1_TIPO")
	if cTipo<>"MO" 
	   cQuery := " Execute sp_codpai '"+HA_PRODUTO+"',1,'001','"+HA_PRODUTO+"' "
       nErro := TCSQLExec(cQuery)
	endif                         
	cod=HA_PRODUTO
	dbskip()
enddo
dbSelectArea("SHADTC")
dbclosearea()        


//cQuery := " DELETE SHAMRP WHERE (SELECT B1_TIPO FROM SB1010 WHERE B1_FILIAL='01' AND B1_COD=HA_PRODUTO AND SB1010.D_E_L_E_T_<>'*') IN ('SA','PI') "
//nErro := TCSQLExec(cQuery)
//
APMSGINFO("MRP Importado com Sucesso ")	
//
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcImp  ³ Autor ³FCC DO BRASIL          ³ Data ³ 13/02.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processamento de Importacao dos Dados                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 25/02/02 ==> Function ProcImp
Static Function ProcImp()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo de Trabalho.                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

 cQuery := "DELETE SHA_MRP"
 TCSQLExec(cQuery)
 USE SHA_MRP VIA "TOPCONN"
 Append From  "\01\SHA010.dtc"
                                   
  
   MsgAlert("Arquivo do MRP Atualizado com Sucesso ")
Close(oDlg)
Return

**********************************
Static Function A010Fim()
**********************************
Close(oDlg)
Return
