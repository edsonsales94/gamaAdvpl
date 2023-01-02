#include "rwmake.ch"
#include "Colors.ch"
#include "topconn.ch"
#Include "Winapi.ch"
#Include "vkey.ch"

User Function bzinv01()

SetPrvt("WCONTINUA,DDTA_LIM,CDOC,DDT_TR,CCODIGO,CCODCLI")
SetPrvt("NQUANT,CLOCAL,CDESc,INCLUI,CNUMSEQ,CNXTNUM")
SetPrvt("CPRXNUM,VCOD,VCOD1,VCCLI,VDESC,VBOX,vTipo,vUm,Doc,vLote" )
Private cDoc,oDlg3,oDlg1
wcontinua:=.t.


While wcontinua
    
    cDoc := space(6)
   
   @ 3,1 TO 350,480 DIALOG oDlg3 TITLE "Digitacao Inventario-1a.Contagem"
   @ 010, 10 Say "Etiqueta"      SIZE 040,060
   @ 010, 65 get  cDoc    Pict "999999"   valid iif(cdoc<>space(6),disp_etiq(),Finaliza()) OBJECT oDoc SIZE 40,050

   @ 140, 040 BUTTON "_Ok"       SIZE 040,015   ACTION disp_etiq() 
   @ 140, 100 BUTTON "_Sair"     SIZE 040,015   ACTION finaliza()
	
	ACTIVATE DIALOG oDlg3 CENTERED

end

Return      


                           



Static function disp_etiq()
Private tEnder
cdoc := strzero(val(cdoc),6)
oDlg1 := Nil
dbselectarea('SZU')
dbseek(xFilial("SZU")+cdoc)

IF LEFT(SZU->ZU_TIME,3)!="IMP"
	MSGSTOP('ETIQUETA NAO FOI IMPRESSA','ERRO')
	RETURN(.F.)
ENDIF


IF SZU->(eof())
	MSGSTOP('ETIQUETA NAO CADASTRADA','ERRO')
	RETURN(.F.)
ELSE
	IF ZU_ultcont == 0
		doc    := SZU->ZU_numetq
		ddt_tr := ddatabase
		vCod   := SZU->ZU_cod
		vCod1  := SZU->ZU_cod
		ccodcli:= SZU->ZU_codcli
		cdesc  := SZU->ZU_desc
		nquant := 0
		clocal := SZU->ZU_locpad
		vBox   := SZU->ZU_LOCALIZ
		vLote  := SZU->ZU_LOTECTL      
		cUM    := SZU->ZU_UM    
		oDlg1 := MSDialog():New(3,1 ,350,480,"Digitacao Inventario-1a.Contagem" ,,,,,CLR_BLACK,CLR_WHITE,,,.T.)
	  //	Define MsDialog oDlg1 TITLE "Digitacao Inventario-1a.Contagem" From 3,1 TO 350,480 Pixel
		//@ 3,1 TO 350,480 DIALOG oDlg1 TITLE "Digitacao Inventario-1a.Contagem"
		
		@ 010, 10 Say "Etiqueta: "   SIZE 080,100
		@ 010, 65 Say  Doc           SIZE 40,100
		
		@ 010,125 Say "Data: "       SIZE 080,100
		@ 010,180 Say dtoc(ddt_tr)   SIZE 040,100
		
		IF EMPTY(SZU->ZU_Cod)
			@ 025, 10 Say "Codigo: " SIZE 080,100
			@ 025, 65 Get vCod       Picture "@!"    F3 "SB1" Valid ChkProd() SIZE 060,200
						
			if SZU->ZU_locpad == space(2)
				@ 025,125 Say "Local: " SIZE 080,100
    			@ 025,180 Get clocal    SIZE 020,100  //Valid NaoVazio() Pixel
			else
				@ 025,125 Say "Local: " SIZE 080,100                          
				@ 025,180 Say clocal    SIZE 020,100
			Endif
			
					
			//@ 040, 10 Say "Endereco: "  SIZE 080,100
			@ 040, 10 Say "UN.MEDIDA: "  SIZE 080,100
			@ 040, 65 SAY cUM  SIZE 150,040 //WHEN tEnder			
			
			@ 045, 125 Say "Endereco: "  SIZE 080,100
			@ 045, 180 GET vBox Valid ChkEnd(cLocal,vBox) OBJECT oBox SIZE 50,200 //WHEN tEnder
			
			
			
			/*
			If !Empty(vCod)
				@ 040, 10 Say "Endereco: "  SIZE 080,100
				@ 040, 65 GET vBox Valid ChkEnd(cLocal,vBox)OBJECT oBox SIZE 50,200 WHEN tEnder
			Else
				@ 040, 10 Say "Endereco: "  SIZE 080,100
				@ 040, 65 GET vBox Valid ChkEnd(cLocal,vBox)OBJECT oBox SIZE 50,200 WHEN tEnder
			EndIf
			*/
			
			@ 055, 10 Say "Descricao"          SIZE 080,100 
			@ 055, 65 SAY cdesc                SIZE 150,040
			
			// Lote
			@ 070, 10 Say "Lote: "  SIZE 080,100
			@ 070, 65 GET vLote Valid !Empty(vLote) When U_vldRastro(vCod) OBJECT oBox SIZE 62,200
			
		ELSE
			
			@ 025, 10 Say "Codigo: "  SIZE 080,100
			@ 025, 65 Say  vCod       SIZE 040,200
			
			if SZU->ZU_locpad == space(2)
				@ 025,125 Say "Local: "  SIZE 080,100
				@ 025,180 Get clocal     SIZE 020,100  Valid NaoVazio()
			else
				@ 025,125 Say "Local: " SIZE 080,100
				@ 025,180 Say clocal    SIZE 020,100
				
			Endif
			
			//@ 040, 10 Say "Endereco: "  SIZE 080,100
			//@ 040, 65 Say vBox          SIZE 40,100   
			
			@ 040, 10 Say "UN.MEDIDA: "  SIZE 080,100
			@ 040, 65 SAY cUM  SIZE 50,200 //WHEN tEnder			
			
			@ 045, 125 Say "Endereco: "  SIZE 080,100     
			@ 045, 180 GET vBox Valid ChkEnd(cLocal,vBox) OBJECT oBox SIZE 50,200
						
			
			@ 055, 10 Say "Descricao"          SIZE 080,100 
			@ 055, 65 SAY cdesc                SIZE 150,040
			
			
			@ 070, 10 Say "Lote: "  	SIZE 080,100
			@ 070, 65 Say vLote 		SIZE 65,100
			
		endif      
		
		
		
		@ 095, 10 Say "Quantidade: "  SIZE 080,100
		@ 095, 65 Get nquant Pict "@E 999,999.9999"   SIZE 080,100  Valid Nquant >= 0
		
		@ 140, 040 BUTTON "_Ok"       SIZE 040,015   ACTION grav_Dads()
		@ 140, 100 BUTTON "_Sair"     SIZE 040,015   ACTION Fecha()
		
		ACTIVATE DIALOG oDlg1 CENTERED
	ELSE
		MSGSTOP('PRIMEIRA CONTAGEM JA EFETUADA','ERRO')
		RETURN(.F.)
	ENDIF
ENDIF      
//oDlg1:End()
oDoc:SetFocus()
Return(.t.)
****************************************************
Static Function Finaliza()
wcontinua := .F.
oDlg3:End()
return
***************************************************
Static Function Fecha()           
oDlg1:End()
oDlg3:End()
Return                            
                                
*******************************************
// *************************************
// Grava dados
// *************************************
Static FUNCTION GRAV_DADS()

IF !MSGYESNO('Confirma Lancamento ???? ','ALERTA')
	RETURN(.F.)
else
	dbselectarea('SZU')
	reclock("SZU",.f.)
	SZU->ZU_cont1   := nquant
	SZU->ZU_ultcont := 1
	SZU->ZU_localiz := vBox
	SZU->ZU_DATACT1	:= dDataBase
	SZU->ZU_TIME01	:= TIME()
	SZU->ZU_LOTECTL := ""
	SZU->ZU_USUCT1  := UPPER(ALLTRIM(cUserName)) //Substr(cUsuario,7,8)//Substr(cUsuario,7,6)
	SZU->ZU_LOTECTL := vLote
		
	//repla ZU_data    with ddt_tr
	if vCod1 == space(15)
		SZU->ZU_cod    := vCod
		if AllTrim(ZU_codcli) == ""
			SZU->ZU_codcli := ccodcli
		endif
		SZU->ZU_desc   := cdesc
		SZU->ZU_um     := cUM //sb1->b1_Um
		SZU->ZU_tipo   := sb1->b1_tipo
		SZU->ZU_locpad := clocal 
		SZU->ZU_GRUPO  := Sb1->B1_Grupo
	endif
	MsUnlock()
endif
oDlg1:End()
cdoc   :=space(6)
oDoc:SetFocus()

RETURN(.T.)


************************************************************************************
Static Function ChkProd()
if LastKey() == 27
	oDlg1:End()
	oDlg3:End()
	Return
Endif

IF SB1->(dbseek(xFilial("SB1")+vCod))
	ccodcli := " " //sb1->b1_codcli
	cdesc   := sb1->b1_desc
	cTipo   := SB1->B1_TIPO   
	cUM     := SB1->B1_UM
	
	/**
	If sb1->b1_fantasm == "S"
	MSGSTOP('PRODUTO FANTASMA NAO AUTORIZADO','ERRO')
	RETURN(.F.)
	Endif
	*/
	
	//@ 040, 10 Say "Codigo do cliente"  SIZE 080,100
	//@ 040, 65 Say ccodcli              SIZE 100,100
	
	//@ 055, 10 Say "Descricao"          SIZE 080,100
	@ 040, 65 SAY cUM                  SIZE 200,040 //WHEN tEnder			
	@ 055, 65 SAY  cdesc               SIZE 200,040
	
	tEnder := fTemEnd(vCod)
	
	oBox:SetFocus()
else
	MSGSTOP('PRODUTO NAO CADASTRADO','ERRO')
	RETURN(.F.)
endif

Return(.t.)
************************************************************************************
Static Function fTemEnd(pCod)
Local cTipo := space(2)
Local tRet  := .F.

if LastKey() == 27
	oDlg1:End()
	oDlg3:End()
	Return
Endif

cTipo := Posicione("SB1",1,xFilial("SB1")+pCod,"B1_TIPO")

If !Empty(vCod)
	Do Case
		Case cTipo $ "PA.PL"
			tRet := .F.
		OtherWise
			tRet := .T.
	EndCase
EndIf
Return(tRet)           


Static Function ChkEnd(cArm,cEnd)
cTipo := Posicione("SB1",1,xFilial("SB1")+vCod ,"B1_TIPO")
if cTipo$"PA/PI/SA"
   Return(.t.)
endif
if LastKey() == 27
	oDlg1:End()
	oDlg3:End()
	Return
Endif
//If !Empty(SZU->ZU_Rua).and. SubStr(cEnd,1,Len(SZU->ZU_Rua))<>SZU->ZU_Rua 
//  Return(.F.)
//Endif 
SBE->( dbSetorder(1) )
if ! SBE->( dbseek(xFilial("SBE")+cArm+cEnd))
	MSGSTOP('Este endereco nao pertence ao Armazem digitado','ERRO')
	RETURN(.F.)
endif  

Return(.t.)