#include "rwmake.ch"        // incluido pelo assistente de conversao do AP6 IDE em 25/07/02

User Function Bzinv06()     


SET CENTURY ON

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Define Variaveis                                             �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
tamanho  := "G"
titulo   := "TRANSFERENCIA PARA SB7"
cDesc1   := ""
cDesc2   := " "
cDesc3   := " "
cPerg    := "BZINV6"
limite   := 220
aReturn  := { "Branco", 1,"Generico", 1, 2, 1, "",1 }
nomeprog := "BZINV06"
nLastKey := 0
lContinua:= .T.
m_pag    := 1
li       := 100
wnrel    := "BZINV06"
cString  := "SZU"
cPerg := "ATUSB7" 

Pergunte("ATUSB7",.F.)

If !pergunte(cPerg,.t.)
   Return NIL
EndIf

RptStatus({|| Transfere()})// Substituido pelo assistente de conversao do AP6 IDE em 25/07/02 ==> RptStatus({|| Execute(RptDetail)})

Return

// --------------------------------------------------------------------------
// -----------------> Corpo do Programa
Static Function transfere()
ALERT("CLAUDIO")
IF !MSGYESNO('Confirma Transferencia para SB7 ?','ALERTA')
   RETURN(.F.)
else
   DbSelectArea("SZU") 
   SZU->(dbSetOrder(1))
   SZU->(dbgotop())
   //SZU->( dbSeek( xFilial(MV_PAR05) ) )
   
   Do while ! SZU->(eof()) //.AND. SZU->ZU_FILIAL == MV_PAR05

       IF ALLTRIM(SZU->ZU_FILIAL) <> ALLTRIM(MV_PAR05)
          SZU->(dbskip())
          loop
       endif
          
   
       IF EMPTY(SZU->ZU_COD)   //if SZU->ZU_COD == Space(25)
          SZU->(dbskip())
          loop
       endif
       
       IF SZU->ZU_ultcont == 0   
          SZU->(dbskip())
          LOOP
       ENDIF

	   if SZU->ZU_LOCPAD < mv_par01 .or. SZU->ZU_LOCPAD > mv_par02
          SZU->(dbskip())
          loop
       endif   
	   
	   if !empty(AllTrim(mv_par03))
          if SZU->ZU_LOCPAD $ Alltrim(mv_par03)
             SZU->(dbskip())
             loop
          endif   
       endif   
	   
	   dbselectarea("sb7")
	   reclock("SB7",.t.)  
      SB7->B7_FILIAL  := ALLTRIM(SZU->ZU_FILIAL)//xFilial("SB7")    		
	   SB7->b7_cod     := SZU->ZU_COD
	   SB7->b7_local   := SZU->ZU_LOCPAD
	   SB7->b7_tipo    := SZU->ZU_TIPO
	   SB7->b7_doc     := SZU->ZU_NUMETQ
	   SB7->b7_data    := mv_par04          //SZU->ZU_DATA
	   SB7->b7_dtvalid := SZU->ZU_DATA
	   SB7->b7_localiz := SZU->ZU_localiz 
	   SB7->b7_lotectl := SZU->ZU_lotectl
	      
	   If SZU->ZU_ultcont == 1
	       SB7->b7_quant :=  SZU->ZU_cont1 
	   elseif SZU->ZU_ultcont == 2   
	       SB7->b7_quant :=  SZU->ZU_CONT2
	   else
	       SB7->b7_quant :=  SZU->ZU_CONT3
	   endif
       MsUnlock()
   
	   DbSelectArea("SZU")       
	   SZU->(DbSkip())
   EndDo 
   
Endif	

MsgStop("Transferencia Efetuada com Sucesso !!!")

Return NIL