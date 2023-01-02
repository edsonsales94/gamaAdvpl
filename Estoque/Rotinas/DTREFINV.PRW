#Include "Protheus.Ch"
#Include "FONT.CH"
#include "rwmake.ch"
#include "topconn.ch"

User Function DTREFINV()
Private cPerg:= "INV001"
Private oDlg
Private _DatRef:=ctod(GetMv("MV_DTINVRF"))    //dDataBase
Private _Etiqueta:=" "
Private _Valid:=.F.

 // Opções do MessageBox
  #define MB_OK                       0
  #define MB_OKCANCEL                 1
  #define MB_YESNO                    4
  #define MB_ICONHAND                 16
  #define MB_ICONQUESTION             32
  #define MB_ICONEXCLAMATION          48
  #define MB_ICONASTERISK             64

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajustar perguntas do SX1									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

_ValidPerg()

if !Pergunte(cPerg,.t.)
	Return
endif

@ 200,1 TO 380,380 DIALOG oDlg TITLE OemToAnsi("Liberação do Inventário")
@ 02,10 TO 080,190
@ 10,018 Say " Esse programa tem finalidade liberar as contagens de inventário"
@ 18,018 Say " de acordo com os parâmetros definiçoes pelo usuário"

@ 60,088 BMPBUTTON TYPE 05 ACTION Pergunte("INV001",.T.)
@ 60,118 BMPBUTTON TYPE 01 ACTION (LibInv01(),oDlg:End())
@ 60,148 BMPBUTTON TYPE 02 ACTION (oDlg:End())
Activate Dialog oDlg Centered

Return

Static Function LibInv01()
//Atualiza parâmetro do inventário

If  MV_PAR01==1
	ATUINVRF()
Else
	DbSelectArea("SX6")
	DbSetOrder(1)
	If DbSeek(xFilial("SX6")+"MV_DTINVRF",.F.)
		_DatRef:=CTOD(SX6->X6_CONTEUD)
	Endif
	
	// CONTA REGISTROS A SEREM PROCESSADOS
	cQuery := "SELECT COUNT(ZU_NUMETQ) REGFIM FROM "+RetSqlName("SZU")+" SZU  "
	cQuery += " WHERE SZU.D_E_L_E_T_  <> '*'"
	cQuery += " AND SZU.ZU_ULTCONT='"+STR((MV_PAR01-1),1)+"'"
	cQuery += " AND SZU.ZU_DATACT1>='"+DTOS(MV_PAR02)+"'" //DTOS(_DatRef)
	cQuery += " AND SZU.ZU_COD>='"+MV_PAR03+"'"
	cQuery += " AND SZU.ZU_COD<='" +MV_PAR04+"'"
	cQuery += " AND SZU.ZU_LOCALIZ>='"+MV_PAR05+"'"
	cQuery += " AND SZU.ZU_LOCALIZ<='" +MV_PAR06+"'"
	cQuery += " AND SZU.ZU_LOCPAD='" +MV_PAR07+"'"
	cQuery += " AND SZU.ZU_FILIAL='"+XFILIAL("SZU")+"'"  
	cQuery += " AND SZU.D_E_L_E_T_ <> '*' AND LEFT(SZU.ZU_STATUS,3)<>'FOK'"
	// Liberação por Lista
	If !Empty(MV_PAR08)
		cQuery += " AND SZU.ZU_NUMDOC='" +MV_PAR08+"'"
	EndIf
	
	If Select("TMP") > 0
		TMP->(DbCloseArea())
	EndIf
	
	TCQUERY cQuery NEW ALIAS TMP
	dbSelectArea("TMP")
	_nRegFim:=TMP->REGFIM
	
	
	// SELECIONA REGISTROS PARA PROCESSAMENTO
	
	cQuery := "SELECT * FROM "+RetSqlName("SZU")+" SZU  "
	cQuery += " WHERE SZU.D_E_L_E_T_  <> '*'"
	cQuery += " AND SZU.ZU_ULTCONT='"+STR((MV_PAR01-1),1)+"'"
	cQuery += " AND SZU.ZU_DATACT1>='"+DTOS(MV_PAR02)+"'" //DTOS(_DatRef)
	cQuery += " AND SZU.ZU_COD>='"+MV_PAR03+"'"
	cQuery += " AND SZU.ZU_COD<='" +MV_PAR04+"'"
	cQuery += " AND SZU.ZU_LOCALIZ>='"+MV_PAR05+"'"
	cQuery += " AND SZU.ZU_LOCALIZ<='" +MV_PAR06+"'"
	cQuery += " AND SZU.ZU_LOCPAD='" +MV_PAR07+"'"
	cQuery += " AND SZU.ZU_FILIAL='"+XFILIAL("SZU")+"'"
	cQuery += " AND SZU.D_E_L_E_T_ <> '*' "
	// Liberação por Lista
	If !Empty(MV_PAR08)
		cQuery += " AND SZU.ZU_NUMDOC='" +MV_PAR08+"'"
	EndIf
	
	If Select("TMP") > 0
		TMP->(DbCloseArea())
	EndIf
	
	TCQUERY cQuery NEW ALIAS TMP
	
	dbSelectArea("TMP")
	
	ProcRegua(_nRegFim)
	dbGoTop()
	
	Do While ! Eof()
		
		_Etiqueta:=TMP->ZU_NUMETQ
		
		DBSelectArea("SZU")
		DBSetOrder(1)
		IF DBSeek(xFilial('SZU') + _Etiqueta)
			
			Reclock("SZU",.F.)
			If SZU->ZU_ULTCONT==1
				REPLACE ZU_DTINV2 WITH dDataBase
				_Valid:=.T.
			ElseIf SZU->ZU_ULTCONT==2
				REPLACE ZU_DTINV3 WITH dDataBase
				_Valid:=.T.
			Endif
			MsUnlock()
			
//			IncProc("Processando Local ... " + SZU->ZU_LOCPAD + "  " + "Endereço..." +SZU->ZU_LOCALIZ + If(!Empty(MV_PAR08),"Lista..."+SZU->ZU_NUMDOC," ")
			IncProc()
			
		Endif
		
		dbSelectArea("TMP")
		If Eof()
			Exit
		Else
			DbSkip()
			Loop
		Endif
		
	Enddo
	
	IF _Valid
		MessageBox("Arquivo atualizado com Sucesso... " + cValToChar(_nRegFim),"Fim Processo",MB_ICONEXCLAMATION)
	Else
		MsgBox("Não exite registros para os parâmetros selecionados...","Fim Processo")
	Endif
	
	Return
	
Endif

Static Function ATUINVRF()
IF MSGYESNO('A 1a. contagem deve ser executada apenas no inicio do inventário. Esta é a primeira liberação? ','ALERTA')
	DbSelectArea("SX6")
	DbSetOrder(1)
	If DbSeek(xFilial("SX6")+"MV_DTINVRF",.F.)
		RecLock("SX6",.F.)
		SX6->X6_CONTEUD := DTOC(MV_PAR02)
		msUnlock()
		ALERT("Data Gravada!!!")
	Endif
Endif
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VALIDPERG ºAutor  ³Raquel Ramalho      º Data ³  10/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inclusao de perguntas no SX1                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ OmniLink                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function _VALIDPERG()
Local aHelpPor := {}
Local aHelpEng := {}
Local aHelpSpa := {}
cPerg          := PADR(cPerg,len(sx1->x1_grupo))


aHelpPor :={}
AAdd(aHelpPor,"Informe Contagem")
AAdd(aHelpPor,"1-Primeira ; 2-Segunda; 3-Terceira ")
PutSx1(cPerg,"01","Contagem","Contagem","Contagem","mv_ch1","N",1,0,0,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

aHelpPor :={}
AAdd(aHelpPor,"Informe data de liberação ")
AAdd(aHelpPor,"a ser Processado")
PutSx1(cPerg,"02","Data do Inventário","Data do Inventário","Data do Inventário","mv_ch2","D",08,0,0,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

AAdd(aHelpPor,"Informe Produto Inicial")
AAdd(aHelpPor,"a ser Processado")
PutSx1(cPerg,"03","Produto Inicial","Produto Inicial","Produto Inicial","mv_ch3","C",25,0,0,"G","","","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

aHelpPor :={}
AAdd(aHelpPor,"Informe Produto Final")
AAdd(aHelpPor,"a ser Processado")
PutSx1(cPerg,"04","Produto Final","Produto Final","Produto Final","mv_ch4","C",25,0,0,"G","","","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

aHelpPor :={}
AAdd(aHelpPor,"Endereço Inicial")
AAdd(aHelpPor,"a ser Processado")
PutSx1(cPerg,"05","Endereço Inicial","Endereço Inicial","Endereço Inicial","mv_ch5","C",15,0,0,"G","","","","","MV_PAR05","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

aHelpPor :={}
AAdd(aHelpPor,"Endereço Final")
AAdd(aHelpPor,"a ser Processado")
PutSx1(cPerg,"06","Endereço Endereço Final","Endereço Final","Endereço Final","mv_ch6","C",15,0,0,"G","","","","","MV_PAR06","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)


aHelpPor :={}
AAdd(aHelpPor,"Local")
AAdd(aHelpPor,"a ser Processado")
PutSx1(cPerg,"07","Local","Local","Local","mv_ch7","C",02,0,0,"G","","","","","MV_PAR07","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

aHelpPor :={}
AAdd(aHelpPor,"Lista")
AAdd(aHelpPor,"a ser Processado")
PutSx1(cPerg,"08","Lista","Lista","Lista","mv_ch8","C",06,0,0,"G","","","","","MV_PAR08","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

Return