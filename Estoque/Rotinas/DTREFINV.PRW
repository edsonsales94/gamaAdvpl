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

 // Op寤es do MessageBox
  #define MB_OK                       0
  #define MB_OKCANCEL                 1
  #define MB_YESNO                    4
  #define MB_ICONHAND                 16
  #define MB_ICONQUESTION             32
  #define MB_ICONEXCLAMATION          48
  #define MB_ICONASTERISK             64

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//? Ajustar perguntas do SX1									 ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

_ValidPerg()

if !Pergunte(cPerg,.t.)
	Return
endif

@ 200,1 TO 380,380 DIALOG oDlg TITLE OemToAnsi("Libera豫o do Invent?rio")
@ 02,10 TO 080,190
@ 10,018 Say " Esse programa tem finalidade liberar as contagens de invent?rio"
@ 18,018 Say " de acordo com os par?metros defini?oes pelo usu?rio"

@ 60,088 BMPBUTTON TYPE 05 ACTION Pergunte("INV001",.T.)
@ 60,118 BMPBUTTON TYPE 01 ACTION (LibInv01(),oDlg:End())
@ 60,148 BMPBUTTON TYPE 02 ACTION (oDlg:End())
Activate Dialog oDlg Centered

Return

Static Function LibInv01()
//Atualiza par?metro do invent?rio

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
	// Libera豫o por Lista
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
	// Libera豫o por Lista
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
			
//			IncProc("Processando Local ... " + SZU->ZU_LOCPAD + "  " + "Endere?o..." +SZU->ZU_LOCALIZ + If(!Empty(MV_PAR08),"Lista..."+SZU->ZU_NUMDOC," ")
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
		MsgBox("N?o exite registros para os par?metros selecionados...","Fim Processo")
	Endif
	
	Return
	
Endif

Static Function ATUINVRF()
IF MSGYESNO('A 1a. contagem deve ser executada apenas no inicio do invent?rio. Esta ? a primeira libera豫o? ','ALERTA')
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
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
굇?袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿣ALIDPERG 튍utor  쿝aquel Ramalho      ? Data ?  10/12/08   볍?
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽?
굇튒esc.     ? Inclusao de perguntas no SX1                               볍?
굇?          ?                                                            볍?
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽?
굇튧so       ? OmniLink                                                   볍?
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽?
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
AAdd(aHelpPor,"Informe data de libera豫o ")
AAdd(aHelpPor,"a ser Processado")
PutSx1(cPerg,"02","Data do Invent?rio","Data do Invent?rio","Data do Invent?rio","mv_ch2","D",08,0,0,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

AAdd(aHelpPor,"Informe Produto Inicial")
AAdd(aHelpPor,"a ser Processado")
PutSx1(cPerg,"03","Produto Inicial","Produto Inicial","Produto Inicial","mv_ch3","C",25,0,0,"G","","","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

aHelpPor :={}
AAdd(aHelpPor,"Informe Produto Final")
AAdd(aHelpPor,"a ser Processado")
PutSx1(cPerg,"04","Produto Final","Produto Final","Produto Final","mv_ch4","C",25,0,0,"G","","","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

aHelpPor :={}
AAdd(aHelpPor,"Endere?o Inicial")
AAdd(aHelpPor,"a ser Processado")
PutSx1(cPerg,"05","Endere?o Inicial","Endere?o Inicial","Endere?o Inicial","mv_ch5","C",15,0,0,"G","","","","","MV_PAR05","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

aHelpPor :={}
AAdd(aHelpPor,"Endere?o Final")
AAdd(aHelpPor,"a ser Processado")
PutSx1(cPerg,"06","Endere?o Endere?o Final","Endere?o Final","Endere?o Final","mv_ch6","C",15,0,0,"G","","","","","MV_PAR06","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)


aHelpPor :={}
AAdd(aHelpPor,"Local")
AAdd(aHelpPor,"a ser Processado")
PutSx1(cPerg,"07","Local","Local","Local","mv_ch7","C",02,0,0,"G","","","","","MV_PAR07","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

aHelpPor :={}
AAdd(aHelpPor,"Lista")
AAdd(aHelpPor,"a ser Processado")
PutSx1(cPerg,"08","Lista","Lista","Lista","mv_ch8","C",06,0,0,"G","","","","","MV_PAR08","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

Return