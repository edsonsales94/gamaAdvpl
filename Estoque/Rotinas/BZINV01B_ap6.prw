#include "rwmake.ch"        // incluido pelo assistente de conversao do AP6 IDE em 16/07/02

User Function bzinv01b()        // incluido pelo assistente de conversao do AP6 IDE em 16/07/02

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP6 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


SetPrvt("WCONTINUA,DDTA_LIM,CDOC,DDT_TR,CCODIGO,CCODCLI")
SetPrvt("NQUANT,CLOCAL,CDESc,INCLUI,CNUMSEQ,CNXTNUM")
SetPrvt("CPRXNUM,VCOD,VCOD1,VCCLI,VDESC,VBOX,vTipo,vUm,Doc")

wcontinua:=.t.


While wcontinua
   cDoc := SZU->ZU_NUMETQ
   
   @ 3,1 TO 350,480 DIALOG oDlg3 TITLE "Digitacao 3a Contagem-Inventario"
   @ 010, 10 Say "Etiqueta"      SIZE 080,100
   @ 010, 65 get  cDoc           Pict "@!"     valid iif(cdoc<>space(6),disp_etiq(),Finaliza()) Object oDoc SIZE 40,100

   @ 140, 040 BUTTON "_Ok"       SIZE 040,015   ACTION disp_etiq() 
   @ 140, 100 BUTTON "_Sair"     SIZE 040,015   ACTION finaliza()

   ACTIVATE DIALOG oDlg3 CENTERED
   
   if LastKey() == 27
      wcontinua := .f.
      oDlg3:Close()
   Endif
end

Return

*********************************************************
Static function disp_etiq()

//cdoc := strzero(val(cdoc),6)
//cdoc := strzero(val(cdoc),6)

dbselectarea('SZU')      
dbsetorder(1)      
SZU->(dbseek(xFilial("SZU")+cdoc) )
IF EOF()
   MSGSTOP('ETIQUETA NAO CADASTRADA','ERRO')
   RETURN(.F.)
else           

//Verifica se contagem esta liberada.
   IF !U_ChkCont() 
      RETURN(.F.)
   ENDIF   
   IF ZU_ultcont == 2  
	   doc    := ZU_numetq
	   ddt_tr := ddatabase
	   vCod   := ZU_cod     
	   vCod1  := ZU_cod
	   ccodcli:= ZU_codcli
	   cdesc  := ZU_desc
	   nquant := 0
	   clocal := ZU_locpad
	   vBox   := ZU_localiz

	   @ 3,1 TO 350,480 DIALOG oDlg1 TITLE "Digitacao do Inventario"

	   @ 010, 10 Say "Etiqueta"           SIZE 080,100
	   @ 010, 65 Say  Doc                 SIZE 40,100

	   @ 010,125 Say "Data  "             SIZE 080,100
	   @ 010,180 Say dtoc(ddt_tr)         SIZE 040,100 
   
	   if SZU->ZU_Cod == space(15)
		   @ 025, 10 Say "Codigo"         SIZE 080,100
		   @ 025, 65 Get vCod             Pict "@!"  SIZE 040,100   Valid ChkProd()

	       if SZU->ZU_locpad == space(2)
	          @ 025,125 Say "Local"          SIZE 080,100
	          @ 025,180 Get clocal           SIZE 020,100  Valid NaoVazio()
	       else   
	          @ 025,125 Say "Local"          SIZE 080,100
	          @ 025,180 Say clocal           SIZE 020,100
           Endif
	   else
		   @ 025, 10 Say "Codigo"         SIZE 080,100
		   @ 025, 65 Say  vCod            SIZE 040,100

	       if SZU->ZU_locpad == space(2)
	          @ 025,125 Say "Local"          SIZE 080,100
	          @ 025,180 Get clocal           SIZE 020,100  Valid NaoVazio()
	       else   
	          @ 025,125 Say "Local"          SIZE 080,100
	          @ 025,180 Say clocal           SIZE 020,100
           Endif
	   endif
   
	   @ 040, 10 Say "Codigo do cliente"  SIZE 080,100
	   @ 040, 65 Say ccodcli              SIZE 100,100

	   @ 055, 10 Say "Descricao"          SIZE 080,100
	   @ 055, 65 SAY cdesc                SIZE 150,040
   
	   @ 070, 10 Say "Endereco"                SIZE 080,100
	   @ 070, 65 Say vBox                 SIZE 040,100
  
	   @ 085, 10 Say "Quantidade"         SIZE 080,100
	   @ 085, 65 Get nquant               Pict "@E 999,999.9999"   SIZE 080,100   Valid Nquant >= 0
   
	   @ 140, 040 BUTTON "_Ok"       SIZE 040,015   ACTION grav_Dads() 
	   @ 140, 100 BUTTON "_Sair"     SIZE 040,015   ACTION Fecha()

	   ACTIVATE DIALOG oDlg1 CENTERED
   Else
   	   if ZU_ultcont == 3 
   	      MSGSTOP('TERCEIRA CONTAGEM JA EFETUADA','ERRO')
          RETURN(.F.)
       else	   
   	   	  MSGSTOP('EFETUAR SEGUNDA CONTAGEM','ERRO')
          RETURN(.F.)
       endif   
   endif
endif
oDoc:SetFocus()
Return(.t.)

****************************************************
Static function Finaliza()
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
   replace ZU_cont3   with nquant    
   replace ZU_ultcont with 3
   replace ZU_localiz with vBox  
   replace SZU->ZU_CONT3	with nQuant
   replace SZU->ZU_ULTCONT with 3
   replace SZU->ZU_DATACT3	with dDataBase
   replace SZU->ZU_TIME03	with TIME()
   replace SZU->ZU_USUCT3   with UPPER(ALLTRIM(cUserName)) //Substr(cUsuario,7,8)
   replace SZU->ZU_DIF03	with SZU->ZU_CONT3-SZU->ZU_SLD03
   replace SZU->ZU_STATUS	with iif(SZU->ZU_DIF03>0,"FOK3G",iif(SZU->ZU_DIF03<0,"FOK3P","FOK3"))
   
   //replace SZU->ZU_AUDMAT3  with _cAudit
   //replace SZU->ZU_AUDNOM3  with substr(SRA->RA_NOME,1,40)
   //replace SZU->ZU_AUDDAT3  with dDataBase
   //replace SZU->ZU_AUDTIM3  with TIME()

   //repla ZU_data    with ddt_tr
   if vCod1 == space(15)
       replace ZU_cod    with vCod
       if AllTrim(ZU_codcli) == ""
          repla ZU_codcli with ccodcli
       endif   
       replace ZU_desc   with cdesc
       replace ZU_um     with sb1->b1_Um
       replace ZU_tipo   with sb1->b1_tipo
       replace ZU_locpad with clocal 
       replace ZU_Grupo  with sb1->b1_Grupo
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

if SB1->(dbseek(xFilial()+vCod))
   ccodcli := sb1->b1_codcli 
   cdesc   := sb1->b1_desc

   If sb1->b1_fantasm == "S"
      MSGSTOP('PRODUTO FANTASMA NAO AUTORIZADO','ERRO')
      RETURN(.F.)
   Endif   

   @ 040, 10 Say "Codigo do cliente"  SIZE 080,100
   @ 040, 65 Say ccodcli              SIZE 100,100

   @ 055, 10 Say "Descricao"          SIZE 080,100
   @ 055, 65 SAY  cdesc               SIZE 200,040
else
   MSGSTOP('PRODUTO NAO CADASTRADO','ERRO')
   RETURN(.F.)
endif   

Return(.t.)