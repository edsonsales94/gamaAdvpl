#Include "Protheus.Ch"
#Include "FONT.CH"
#include "rwmake.ch"
#include "topconn.ch"


User Function FORCECT3()
Private cPerg:= "INV001"
Private oDlg
//Private _DatRef:=ctod(GetMv("MV_DTINVRF"))    //dDataBase
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

@ 200,1 TO 380,380 DIALOG oDlg TITLE OemToAnsi("Forcar nova 3a. contagem do Inventário")
@ 02,10 TO 080,190
@ 10,018 Say " Esse programa tem finalidade FORCA novas contagens de inventário"
@ 18,018 Say " de acordo com os parâmetros definiçoes pelo usuário"

@ 60,088 BMPBUTTON TYPE 05 ACTION Pergunte("INV001",.T.)
@ 60,118 BMPBUTTON TYPE 01 ACTION (ForceInv01(),oDlg:End())
@ 60,148 BMPBUTTON TYPE 02 ACTION (oDlg:End())
Activate Dialog oDlg Centered

Return

Static Function ForceInv01()

Local aArea:= GetArea() 
Local TRB:=GetNextAlias()
//Atualiza parâmetro do inventário

	// CONTA REGISTROS A SEREM PROCESSADOS
	cQuery := "SELECT COUNT(ZU_NUMETQ) REGFIM FROM "+RetSqlName("SZU")+" SZU  "
	cQuery += " WHERE SZU.D_E_L_E_T_  <> '*'"
	cQuery += " AND SZU.ZU_ULTCONT= 3 "
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
	
	
	TCQUERY cQuery NEW ALIAS TMP
	dbSelectArea("TMP")

	_nRegFim:=TMP->REGFIM

	If Select("TMP") > 0
		TMP->(DbCloseArea())
	EndIf   
	


	
	// SELECIONA REGISTROS PARA PROCESSAMENTO
	
	cQuery := "SELECT * FROM "+RetSqlName("SZU")+" SZU  "
	cQuery += " WHERE SZU.D_E_L_E_T_  <> '*'"
	cQuery += " AND SZU.ZU_ULTCONT= 3"
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

	cQuery := ChangeQuery(cQuery)
	
	TCQUERY cQuery NEW ALIAS TRB
	
   //dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.T.,.T.)

	ProcRegua(_nRegFim)
	
	dbSelectArea("TRB")
	
	TRB->(dbGoTop())
	
	Do While !TRB->(Eof())
		
		_Etiqueta:=TRB->ZU_NUMETQ
		DBSelectArea("SZU")
  		SZU->(DBSetOrder(1))
		IF DBSeek(xFilial('SZU') + _Etiqueta)
			If SZU->ZU_ULTCONT==3
				Reclock("SZU",.F.)
				//REPLACE ZU_DTINV3 WITH dDataBase
				REPLACE ZU_STATUS WITH "AG3"
				REPLACE ZU_ULTCONT WITH 2
				_Valid:=.T.
			   MsUnlock()
			  	LimpaZR0(TRB->ZU_COD, TRB->ZU_LOCPAD, TRB->ZU_LOCALIZ, 3 )  
			Endif
			
	
      ENDIF
     	DbCloseArea()
		//IncProc()
		DBSelectArea("TRB")
  		TRB->(dbSkip())

	Enddo
//	   dbSelectArea("TRB") 	

	
	IF _Valid
		MessageBox("Arquivo atualizado com Sucesso... " + cValToChar(_nRegFim),"Fim Processo",MB_ICONEXCLAMATION)
	Else
		MessageBox("Não exite registros para os parâmetros selecionados...","Fim Processo",MB_ICONASTERISK)
	Endif

	TRB->(DbCloseArea())

RestArea(aArea)
Return


Static Function LimpaZR0(_cCod,_cLocal,_cEnd,_nContagem)
/*
DbSelectArea("Z0R")
Z0R->(DbSetOrder(1))
IF DbSeek(xFilial("Z0R")+_cLocal +Transform(_nContagem,'@R 9')+ (SubStr(_cEnd,1,15))+ _cCod)
	Do	While "Z0R"->(DbSeek(xFilial("Z0R")+_cLocal +Transform(_nContagem,'@R 9')+ (SubStr(_cEnd,1,15))+ _cCod))
		Z0R->(RecLock("Z0R",.F.))
		Z0R->(DbDelete())
		Z0R->(MsUnLock())
	EndDo
EndIf    
*/


DbSelectArea("Z0R")
Z0R->(DbSetOrder(1)) //Filial+Ordem Producao
if Z0R->(DbSeek(xFilial("Z0R")+_cLocal +Transform(_nContagem,'@R 9')+ (SubStr(_cEnd,1,15))+ _cCod))
	While Z0R->(DbSeek(xFilial("Z0R")+_cLocal +Transform(_nContagem,'@R 9')+ (SubStr(_cEnd,1,15))+ _cCod))
	Z0R->(RecLock("Z0R",.F.))
	Z0R->(DbDelete())
	Z0R->(MsUnLock())
	EndDo
EndIf
	DbCloseArea()
  



//Local cQuery2 :=""
/*  	
cQuery2 := "DELETE "+RetSQLname("Z0R") 
cQuery2 += " WHERE Z0R_COD = '" + _cCod +"'"
cQuery2 += " AND Z0R_LOCAL ='"+ _cLocal+"'"   
cQuery2 += " AND Z0R_LOZALI ='"+ _cEnd +"'"    
cQuery2 += " AND Z0R_CONTAG = 3" //+ _nContagem

TCLink()
nStatus := 	TcSqlExec(cQuery2) //("DELETE Z0R010 WHERE Z0R_COD = '" + cCod + "' AND Z0R_LOCAL ='"+cLocal+"' AND  Z0R_LOZALI ='"+ cEnd +"'  AND Z0R_CONTAG = " + nContagem   )
 
  if (nStatus < 0)
    conout("TCSQLError() " + TCSQLError())
  endif
   
  TCUnlink()
 */
 
 
 
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