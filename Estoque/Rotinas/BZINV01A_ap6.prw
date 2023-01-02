#include "rwmake.ch"        // incluido pelo assistente de conversao do AP6 IDE em 16/07/02

User Function bzinv01a()        // incluido pelo assistente de conversao do AP6 IDE em 16/07/02

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP6 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


SetPrvt("WCONTINUA,DDTA_LIM,CDOC,DDT_TR,CCODIGO,CCODCLI")
SetPrvt("NQUANT,CLOCAL,CDESc,INCLUI,CNUMSEQ,CNXTNUM")
SetPrvt("CPRXNUM,VCOD,VCOD1,VCCLI,VDESC,VBOX,vTipo,vUm,Doc,vLote")
Private cdoc 
wcontinua:=.t.



While wcontinua
cDoc := SZU->ZU_NUMETQ
   
   @ 3,1 TO 350,480 DIALOG oDlg3 TITLE "Digitacao Inventario-2a.Contagem"
   @ 010, 10 Say "Etiqueta"      SIZE 080,100
   @ 010, 65 get  cDoc           Pict "@!"    valid iif(cdoc<>space(6),disp_etiq(),Finaliza()) Object oDoc  SIZE 40,100

   @ 140, 040 BUTTON "_Ok"       SIZE 040,015   ACTION disp_etiq() 
   @ 140, 100 BUTTON "_Sair"     SIZE 040,015   ACTION finaliza()

   ACTIVATE DIALOG oDlg3 CENTERED
end

Return


Static function disp_etiq()
Private tEnder
cdoc := STRZERO(VAL(cDoc),6)

dbselectarea('SZU')
SZU->( DBSETORDER(1) )

if !SZU->( dbseek(xFilial("SZU")+cdoc) )
   MSGSTOP('ETIQUETA NAO CADASTRADA','ERRO')
   RETURN(.F.)
else     
   //Verifica se contagem esta liberada.
   IF !U_ChkCont() 
      RETURN(.F.)
   ENDIF      
   
   IF ZU_ultcont == 1
	   doc    := SZU->ZU_numetq
	   ddt_tr := DDATABASE
	   vCod   := SZU->ZU_cod     
	   vCod1  := SZU->ZU_cod
	   ccodcli:= SZU->ZU_codcli
	   cdesc  := SZU->ZU_desc
	   nquant := 0
	   clocal := SZU->ZU_locpad
	   vBox   := SZU->ZU_localiz
	   cTipo  := SZU->ZU_TIPO
	   vLote  := SZU->ZU_LOTECTL
	   cUM    := SZU->ZU_UM

	   @ 3,1 TO 350,480 DIALOG oDlg1 TITLE "Digitacao Inventario-2a.Contagem"

	   @ 010, 10 Say "Etiqueta: "         SIZE 080,100
	   @ 010, 65 Say  Doc                 SIZE 40,100

	   @ 010,125 Say "Data: "             SIZE 080,100
	   @ 010,180 Say dtoc(ddt_tr)         SIZE 040,100 
   
	   IF EMPTY(SZU->ZU_Cod) //== space(25)
		   @ 025, 10 Say "Codigo: "       SIZE 080,100
		   @ 025, 65 Get vCod             Pict "@!"  SIZE 040,100   Valid ChkProd()

	       if SZU->ZU_locpad == space(2)
	          @ 025,125 Say "Local: "     SIZE 080,100
	          @ 025,180 Get clocal        SIZE 020,100  Valid NaoVazio()
	       else   
	          @ 025,125 Say "Local: "     SIZE 080,100
	          @ 025,180 Say clocal        SIZE 020,100
           Endif
           
 			If !Empty(vCod)
				@ 040, 10 Say "Endereco: "  SIZE 080,100
				@ 040, 65 GET vBox Valid ChkEnd(cLocal,vBox)OBJECT oBox SIZE 50,200 //WHEN 

			Else
				@ 040, 10 Say "Endereco: "  SIZE 080,100
				@ 040, 65 GET vBox Valid ChkEnd(cLocal,vBox)OBJECT oBox SIZE 50,200 //WHEN tEnder
			EndIf
			
			@ 055, 10 Say "Descricao"          SIZE 080,100
			
			// Lote
			@ 070, 10 Say "Lote: "  SIZE 080,100
			@ 070, 65 GET vLote Valid !Empty(vLote) When U_vldRastro(vCod) OBJECT oBox SIZE 62,200 
			//@ 070, 65 GET vLote Valid !Empty(vLote)	OBJECT oBox SIZE 62,200 When U_vldRastro(vCod)
			
	   ELSE
		   @ 025, 10 Say "Codigo: "       SIZE 080,100
		   @ 025, 65 Say  vCod            SIZE 040,100

	       if SZU->ZU_locpad == space(2)
	          @ 025,125 Say "Local: "     SIZE 080,100
	          @ 025,180 Get clocal        SIZE 020,100  Valid NaoVazio()
	       else   
	          @ 025,125 Say "Local: "     SIZE 080,100
	          @ 025,180 Say clocal        SIZE 020,100
           Endif                
           	@ 040, 125 Say "Endereco: "  SIZE 080,100
			@ 040, 180 GET vBox Valid ChkEnd(cLocal,vBox)OBJECT oBox SIZE 50,200 //WHEN tEnder
           // Lote
           //@ 040, 10 Say "Lote: "  	SIZE 080,100
		   //@ 040, 65 Say vLote 		SIZE 40,100
		   
		   @ 040, 10 Say "UN.MEDIDA: "  SIZE 080,100
		   @ 040, 65 SAY cUM  SIZE 50,200 //WHEN tEnder			
           
	   ENDIF       

	   @ 055, 10 Say "Descricao: "        SIZE 080,100
	   @ 055, 65 SAY cdesc                SIZE 150,040
       
     
	   @ 085, 10 Say "Quantidade: "       SIZE 080,100
	   @ 085, 65 Get nquant               Pict "@E 999,999.9999"   SIZE 080,100   Valid Nquant >= 0
   
	   @ 140, 040 BUTTON "_Ok"       SIZE 040,015   ACTION GrvDados("",clocal,vBox,vLote,vCod,2,nquant)  //grav_Dads() 
	   @ 140, 100 BUTTON "_Sair"     SIZE 040,015   ACTION Fecha()

	   ACTIVATE DIALOG oDlg1 CENTERED
   else
   	   If ZU_ultcont == 2
     	   MSGSTOP('SEGUNDA CONTAGEM JA EFETUADA','ERRO')   	   
     	   RETURN(.F.)
   	   ELSEIF SZU->ZU_ultcont == 3
     	   MSGSTOP('INVENTARIO JA ENCERRADO PARA ESTA ETIQUETA','ERRO')
           RETURN(.F.)
       ELSE           
           MSGSTOP('EFETUAR PRIMEIRA CONTAGEM','ERRO')
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
   replace SZU->ZU_cont2    with nquant    
   replace SZU->ZU_ultcont  with 2
   replace SZU->ZU_localiz  with vBox
   replace SZU->ZU_DATACT2	with dDataBase
   replace SZU->ZU_TIME02	with TIME()
   replace SZU->ZU_USUCT2   with UPPER(ALLTRIM(cUserName)) //Substr(cUsuario,7,8)
   replace SZU->ZU_LOTECTL  with vLote
   
   //replace SZU->ZU_AUDMAT2  with ""
   //replace SZU->ZU_AUDNOM2  with //substr(SRA->RA_NOME,1,40)
   //replace SZU->ZU_AUDDAT2  with dDataBase
   //replace SZU->ZU_AUDTIM2  with TIME()
   
   //repla ZU_data    with ddt_tr
   if EMPTY(vCod1) // == space(25)
       replace SZU->ZU_cod    with vCod
       if AllTrim(ZU_codcli) == ""
          replace SZU->ZU_codcli with ccodcli
       endif   
       replace SZU->ZU_desc   with cdesc
       replace SZU->ZU_um     with sb1->b1_Um
       replace SZU->ZU_tipo   with sb1->b1_tipo
       replace SZU->ZU_locpad with clocal 
       replace SZU->ZU_Grupo  with sb1->b1_Grupo
   endif
   SZU->(MsUnlock())
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
************************************************************************************
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
	MSGSTOP('Este endereco nao pertencem ao Armazem digitado','ERRO')
	RETURN(.F.)
endif

Return(.t.)

USER FUNCTION Chkcont()
If Empty(SZU->ZU_DTINV2) .and. SZU->ZU_ULTCONT == 1
		MSGSTOP('2a.Contagem não liberada!')
		Return (.F.)
elseif Empty(SZU->ZU_DTINV3) .and. SZU->ZU_ULTCONT == 2 
		MSGSTOP('3a.Contagem não liberada!')
		Return (.F.)
	Endif

if SZU->ZU_ULTCONT = 3
		MSGSTOP('Este PN / LOTE / ENDEREÇO já foi inventariado 3X!')
		Return (.F.)
endif       
           
Return (.T.)
                                                 



****************************************************************************************************************************************************
Static Function GrvDados(pMat,pLocal,pLocaliza,pLote,pProduto,pCtagem,pQuant)
****************************************************************************************************************************************************
Local _aQTotal
Local lTudoOK:=.f.
Begin Transaction 
//Z0R->(DbSetorder(01))//Z0R_FILIAL, Z0R_LOCAL, Z0R_CONTAG, Z0R_LOZALI, Z0R_COD,Z0_LOTECT, R_E_C_N_O_, D_E_L_E_T_

        Z0R->(RecLock( "Z0R",.t.))
		Z0R->Z0R_Filial:=xFilial("Z0R")
		Z0R->Z0R_COD   :=pProduto 
		Z0R->Z0R_LOCAL :=pLocal
		Z0R->Z0R_LOZALI:=pLocaliza
		Z0R->Z0R_LOTECT :=pLote
		Z0R->Z0R_QUANT :=pQuant
		Z0R->Z0R_CONTAG:=Transform(pCtagem,'@R 9')
		Z0R->Z0R_HORA  :=Time()      
		Z0R->Z0R_MAT   :=pMat
        Z0R->(MsUnLock("Z0R"))
       _aQTotal  := pQuant  //fbuscalidos(Z0R->Z0R_COD,Z0R->Z0R_LOCAL,Z0R->Z0R_LOZALI,Z0R->Z0R_LOTECT,pCtagem)
        lTudoOK:=GrvSZU(pLocal,pLocaliza,pLote,pProduto,_aQTotal,pCtagem)
	    If !lTudoOK
	     DisarmTransaction()
	    endif  
	 End Transaction    
     oDlg1:End()
     oDlg3:End() 

Return

 
****************************************************************************************************************************************************
Static Function fbuscalidos(cProd,cLocal,cEnde,cLote,nContagem)
****************************************************************************************************************************************************
Local ix
Local aVet:={'','','',0,0,''}

Z0R->(DbSetorder(01))//Z0R_FILIAL, Z0R_LOCAL, Z0R_CONTAG, Z0R_LOZALI, Z0R_COD, R_E_C_N_O_, D_E_L_E_T_
Z0r->(DbSeek(xFilial("Z0R")+cLocal+Transform(nContagem,'@R 9')+cEnde+cProd+cLote))
While Z0r->(!Eof()) .and. xFilial("Z0R")+cLocal+Transform(nContagem,'@R 9')+cEnde+cProd==Z0R->(Z0R_FILIAL+Z0R_LOCAL+Z0R_CONTAG+Z0R_LOZALI+Z0R_COD)
		avet[1]:=Z0R->Z0R_COD   
		avet[2]:=Z0R->Z0R_LOCAL 
		avet[3]:=Z0R->Z0R_LOZALI 
		avet[4]+=1
        avet[5]+=Z0R->Z0R_QUANT  
        avet[6]+=Z0R->Z0R_LOTECT
	Z0R->(DbSkip())
End 
Return (avet)                  

 
******************************************************************************************************************************************************
Static Function GrvSZU(_cLocal,_cEnd,_cLote,_cProduto,_nQuant,_Ctagem)
******************************************************************************************************************************************************
Local _TudoOk := .F.
Local _cEtiq  := ""
Local cNum    := Space(06)
Local lAchou:=.F.

rRastro:=POSICIONE("SB1",1,xfilial("SB1")+_cProduto,"B1_LOCALIZ")
//if rRastro=="N"
// _cEnd :=  ALLTRIM(_cEnd)
// _cLote:=ALLTRIM(_cLoted)
//endif 
_cEnd :=  Left(Padr(_cEnd,15," "),15)
_cLote:=  Left(Padr(_cLote,15," "),15) 
SZU->(DBSetOrder(4))
If !SZU->(DBSeek(xFilial('SZU') + _cLocal+_cEnd+_cProduto+_cLote))    ///ZU_FILIAL, ZU_LOCPAD, ZU_LOCALIZ, ZU_COD, ZU_LOTECTL, R_E_C_N_O_, D_E_L_E_T_
    lAchou:=.F.
  Else 
   lAchou:=.T.
Endif 
  
nQtEnd := 0


If Localiza(_cProduto)  
   Sbf->(DBSetOrder(1))
   Sbf->(DBSeek(xFilial('SBF') + _cLocal+_cEnd+_cProduto))
   DO WHILE Sbf->(!EOF()).AND.Sbf->BF_FILIAL==xFilial("SBF").AND.Sbf->BF_LOCAL==_cLocal.AND.Sbf->BF_LOCALIZ==_cEnd.AND.Sbf->BF_PRODUTO==_cProduto
     IF ALLTRIM(SBF->BF_LOTECTL)=ALLTRIM(_cLote)
      nQtEnd := ( nQtEnd + Sbf->BF_QUANT )
     ENDIF 
     SbF->(dbSkip())
   EndDo
ENDIF
IF rRastro=="N"
   Sb2->(DBSetOrder(1))
   Sb2->(DBSeek(xFilial('SB2') + _cLocal+_cProduto))
   DO WHILE Sb2->(!EOF()).AND.Sb2->B2_FILIAL==xFilial("SB2").AND.Sb2->B2_LOCAL==_cLocal.AND.Sb2->B2_COD==_cProduto
      nQtEnd := ( nQtEnd + Sb2->B2_QATU)
      Sb2->(dbSkip())
   EndDo
Endif    
cUnd := POSICIONE("SB1",1,xfilial("SB1")+_cProduto,"B1_UM")
cTipo:= POSICIONE("SB1",1,xfilial("SB1")+_cProduto,"B1_TIPO")

lTol:=.F.

//Regras de Tolerancia de inventario 2% para KG e 10 pcs para Peças
cStatus :=IIF(_Ctagem==1,"AG2",IIF(_Ctagem==2,"AG3","FOK"))
cTipo:= POSICIONE("SB1",1,xfilial("SB1")+_cProduto,"B1_TIPO")
//gerar status com tolerancia 
if (_nQuant-nQtEnd)>=0 .and. (_nQuant-nQtEnd)<10 .and. nQtEnd>0 .and. (ALLTRIM(cUnd)=="PC" .OR. ALLTRIM(cUnd)=="UN") .and. cTipo<>"PA"
  cStatus :=IIF(_Ctagem == 1,"FOK1G",IIF(_Ctagem == 2,"FOK2G","FOK3G"))
elseif (_nQuant-nQtEnd)<0 .and. (_nQuant-nQtEnd)>-10 .and. nQtEnd>0 .and. (ALLTRIM(cUnd)=="PC" .OR. ALLTRIM(cUnd)=="UN") .and. cTipo<>"PA"
  cStatus :=cIIF(_Ctagem == 1,"FOK1P",IIF(_Ctagem == 2,"FOK2P","FOK3P"))
elseif (((_nQuant-nQtEnd)/nQtEnd)*100)<0 .and. (((_nQuant-nQtEnd)/nQtEnd)*100)>-2 .and. nQtEnd>0 .and. cUnd$"KG/RL/LT/MT/ML/L/G/PL"
  cStatus :=IIF(_Ctagem == 1,"FOK1P",IIF(_Ctagem == 2,"FOK2P","FOK3P"))
elseif (((_nQuant-nQtEnd)/nQtEnd)*100)>0 .and. (((_nQuant-nQtEnd)/nQtEnd)*100)<2 .and. nQtEnd>0 .and. cUnd$"KG/RL/LT/MT/ML/L/G/PL"
 cStatus :=IIF(_Ctagem == 1,"FOK1G",IIF(_Ctagem == 2,"FOK2G","FOK3G"))
elseif (_nQuant==nQtEnd)
 cStatus :="FOK"
elseif lAchou .and. _Ctagem==2
 if  SZU->ZU_CONT1==_nQuant
  cStatus :=iif((_nQuant-nQtEnd)>0,"FOK2G",iif((_nQuant-nQtEnd)<0,"FOK2P","FOK")) 
 endif
endif
      
IF !lAchou
    dbSelectArea("SZU")
    cNum   := DocSd3()  //Parametro que guarda a ultima sequencia gerada de etiqueta a partir da lista.
    _cEtiq := cNumSZU(cNum)
    SZU->(RecLock("SZU",.t.))
	replace SZU->ZU_FILIAL  with xFilial("SZU")
	replace SZU->ZU_NUMETQ  with _cEtiq 
	replace SZU->ZU_COD		with _cProduto
	replace SZU->ZU_DESC	with POSICIONE("SB1",1,xfilial("SB1")+_cProduto,"B1_DESC")
	replace SZU->ZU_UM		with cUnd
	replace SZU->ZU_TIPO	with cTipo 
	replace SZU->ZU_LOCPAD	with _cLocal
	replace SZU->ZU_FANTASM with POSICIONE("SB1",1,xfilial("SB1")+_cProduto,"B1_FANTASM")
	replace SZU->ZU_GRUPO   with POSICIONE("SB1",1,xfilial("SB1")+_cProduto,"B1_GRUPO")
	replace SZU->ZU_DATA    with dDTREFINV
	replace SZU->ZU_CONT1	with _nQuant
	replace SZU->ZU_ULTCONT with 1
	replace SZU->ZU_DATACT1	with dDataBase
	replace SZU->ZU_LOCALIZ with IIF(rRastro=="S",_cEnd,"")
    replace SZU->ZU_RUA     with  Left(_cEnd,5)
	replace SZU->ZU_TIME01	with TIME()
	replace SZU->ZU_LOTECTL with _cLote
	replace SZU->ZU_USUCT1  with UPPER(ALLTRIM(cUserName)) //_cCodUser
	replace SZU->ZU_NUMDOC	with 'COLETO'//Subs(DtoS(dDataBase),3,6)
	replace SZU->ZU_ORIGEM  with "C"
	replace SZU->ZU_DTINV1	with dDataBase
    replace SZU->ZU_SLD01   with nQtEnd   
	replace SZU->ZU_DIF01   with SZU->ZU_CONT1 - SZU->ZU_SLD01
    replace SZU->ZU_TIME    with TIME()
	replace SZU->ZU_STATUS	with cStatus
	_TudoOk := .T. 
Else
  dbSelectArea("SZU")
  SZU->(RecLock("SZU",.F.))    

  If _Ctagem == 1 .and. SZU->ZU_ULTCONT == 1 

	replace SZU->ZU_TIME01	with TIME()
	//replace SZU->ZU_LOTECTL with _cLOTE
	replace SZU->ZU_USUCT1  with UPPER(ALLTRIM(cUserName)) //_cCodUser
	replace SZU->ZU_DTINV1	with dDataBase
	replace SZU->ZU_CONT1	with _nQuant
	replace SZU->ZU_TIME    with TIME()
	replace SZU->ZU_DIF01   with SZU->ZU_CONT1 - SZU->ZU_SLD01
	replace SZU->ZU_STATUS	with cStatus
	_TudoOk := .T.
  Endif 	 

  If _Ctagem == 2 .and. (SZU->ZU_ULTCONT == 1 .or.  SZU->ZU_ULTCONT == 2)
  		If SZU->ZU_ULTCONT = 1 
				replace SZU->ZU_SLD02    with nQtEnd   
				replace SZU->ZU_ULTCONT  with 2
			    replace SZU->ZU_TIME    with TIME()
		Endif 		
		replace SZU->ZU_CONT2      with _nQuant
		replace SZU->ZU_DIF02	   with SZU->ZU_CONT2-SZU->ZU_SLD02
        replace SZU->ZU_STATUS	with cStatus				
    	replace SZU->ZU_DATACT2	 with dDataBase
		replace SZU->ZU_TIME02	 with TIME()
		replace SZU->ZU_USUCT2   with UPPER(ALLTRIM(cUserName))
	    
		_TudoOk := .T. 
   Endif 

   If _Ctagem == 3 .and. (SZU->ZU_ULTCONT == 3 .or.  SZU->ZU_ULTCONT == 2)
		If SZU->ZU_ULTCONT = 2  
				replace SZU->ZU_SLD03   with nQtEnd   
				replace SZU->ZU_ULTCONT with 3
				replace SZU->ZU_AUDMAT3 with _cAudit
				replace SZU->ZU_AUDNOM3 with Left(Posicione("SRA",1,xFilial("SRA")+SubStr(_cAudit,3,6),"RA_NOME"),40)
				replace SZU->ZU_AUDDAT3 with dDataBase
				replace SZU->ZU_AUDTIM3 with TIME()
			    replace SZU->ZU_TIME    with TIME()
 		Endif
		replace SZU->ZU_CONT3	with _nQuant
		replace SZU->ZU_DIF03	with SZU->ZU_CONT3-SZU->ZU_SLD03
		replace SZU->ZU_STATUS	with iif(SZU->ZU_DIF03>0,"FOK3G",iif(SZU->ZU_DIF03<0,"FOK3P","FOK3"))
        replace SZU->ZU_DATACT3	with dDataBase
		replace SZU->ZU_TIME03	with TIME()
		replace SZU->ZU_USUCT3  with UPPER(ALLTRIM(cUserName)) //_cCodUser
		_TudoOk := .T.
   Endif  
Endif
//ConfirmSX8()  
SZU->(MsUnlock())

If !_TudoOK
	  cObs:='Nao Foi Possivel Gravar Inventario!'
	Else 
	  cObs:='GRAVAÇAO COM SUCESSO !!!!!!'
Endif

Return (_TudoOK)

