#INCLUDE 'RWMAKE.CH'
#INCLUDE 'APVT100.CH'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAOCWMS09  บAutor  ณ Aparecido Jane     บ Data ณ  22/07/2008 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Leitura para Inventario - 3 Contagem                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Envision Ind de prods eletronicos - Filial Jundiai         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
******************************************************************************************************************************************************
User Function AOCWMS09()
******************************************************************************************************************************************************
Local Barras      := Space(28)
Private _aQTotal  := {'','','',0,0}//Produto,Local,Endere็o,volume,total
Private _cEnd     := Space(56)
Private _cProduto := Space(28)
Private _cLocal   := Space(02)
Private _cLote    := Space(10)
Private _cNome := Space(28)
Private _nQuant	  := 0
Private _nTot     := 0 
Private _cAudit   := Space(28)
Private _nContagem:=0
//Private _cMat     :=Space(06)
Private aEnd      := {}
Private dDTREFINV := ctod(GetMv("MV_DTINVRF")) 
Private lRastro   := .F.



If PswSeek(__cUserID,.t.)
	_aUser     := PswRet()
	_cCodUser  := Alltrim( _aUser[1] [1])
	_cNomUsu   := cUserName //Alltrim( _aUser[1] [4])
	_cCargUsu  := Alltrim( _aUser[1] [13])
	_cDeptUsu  := Alltrim( _aUser[1] [12])
	_cEmailUsu := Alltrim( _aUser[1] [14])
Else
	_cCodUser  := " "
	_cNomUsu   := " "
	_cCargUsu  := " "
	_cDeptUsu  := " "
	_cEmailUsu := " "
Endif

if empty(dDTREFINV)
	DLVTAviso('SIGAWMS', 'Inf. Dta Inic.Inventario MV_DTINVRF.')
	Return (.F.)
endif

	DLVTCabec("Inventario: " + GetMv("MV_DTINVRF") ,.F.,.F.,.T.)
	@ 01, 00 VTSay PadR('Armazem : ' , VTMaxCol())
	@ 01, 13 VTGet _cLocal  Pict '@!' 	  VALID !Empty(_cLocal)
	@ 02, 00 VTSay PadR('Contagem: ' , VTMaxCol())
	@ 02, 13 VTGet _nContagem  Pict '9' 	  VALID !Empty(_nContagem).and. _nContagem>0 .and. _nContagem<4 
	VTREAD

DBSelectArea('SX5')
DBSetOrder(1)
IF !DBSeek(xFilial('SX5')+ "74" + _cLocal )
	DLVTAviso('SIGAWMS', 'O Armazem '+Alltrim(_cLocal)+' nao existe.')
	Return (.F.)
Endif
_nQuant	  := 0
While .T.
    lRet:= 0
    Barras := Space(28)
 	_nTot := 0
	_aQTotal  := {'','','',0,0}//Produto,Local,Endere็o,volume,total
	_cEnd     := Space(28)
	_cProduto := Space(28)
	_cNome := Space(28)
	_cAudit:=SPACE(28)
//    _cLOTE:=Space(10)
    _nQtd:=0 
    _nQuant++              
    
   
  	DLVTCabec("Inventario",.F.,.F.,.T.)
	@ 01, 00 VTSay PadR('Armazem   : ' , VTMaxCol())
	@ 01, 11 VTGet _cLocal  Pict '@!' 	 when .f.
	@ 02, 00 VTSay PadR('Contagem  : ' , VTMaxCol())
	@ 02, 11 VTGet _nContagem  Pict '9' 	  when.f.
 	@ 03, 00 VTSay PadR('Resp.Cont.: ' , VTMaxCol())  
	@ 03, 11 VTGet _cNome Pict '@!'      
	@ 04, 00 VTSay PadR('Cod   :' , VTMaxCol())
	@ 04, 08 VTGet _cProduto Pict '@!' 	VALID fVldBarras(_cProduto,_cLocal,_cEnd)    
	VTREAD

	IF  lRastro  
	@ 05, 00 VTSay PadR('End   : ' , VTMaxCol())
	@ 05, 08 VTGet _cEnd     Pict '@!' 	  VALID  fvldEnd2(_cLocal,_cEnd,_cProduto)
	ELSE
	_cEnd:=Space(28)
   ENDIF 
   
//	@ 05, 00 VTSay PadR('Lote. : ' , VTMaxCol())
//	@ 05, 06 VTGet _cLote    Pict '@!' VALID  IIF(POSICIONE("SB1",1,XFILIAL("SB1")+_cProduto ,"B1_RASTRO")=="L" .AND. EMPTY(_cLote) , .F.,.T.)

	@ 06, 00 VTSay 'Qtde. : '
	@ 06, 06 VTGet _nQtd    Pict '@E 9999999.9999'  VALID Vld2x(_cLocal,_cEnd,_cProduto)
	VTREAD    
	
	_cNome:=SubStr(_cNome,1,15)
	

	If (VTLastKey()==27) 
	_cLocal:=SPACE(2)
		  Exit
    	EndIf	
	
	lRet:= 0  


	IF  VldCtInv(_cLocal,_cEnd,_cProduto,_nContagem,_cLote) .AND.  !Empty(_cProduto) .AND. _nQtd >= 0 .and. fvldEnd(_cLocal,_cEnd)  //.AND. !Empty(_cLote) .AND. _nQuant >= 0
	    _nTot:=_nTot+_nQtd
		If ContaInv()  //fc que endereca o saldo do processo
			_cLOTE:=Space(10)
			_nQtd	  := 0
			_aQTotal  := {'','','',0,0}//Produto,Local,Endere็o,volume,total
		Endif
	Endif
	//EndDo	
	_cEnd     := Space(28)	
	
		If (VTLastKey()==27) 
		  Exit
    	EndIf
	
  
EndDo
Return(.T.)
******************************************************************************************************************************************************
Static Function fVldBarras(cBarras,cLocal,Endere)
******************************************************************************************************************************************************
Local lResp:=.f.
Local cProd:=SubStr(cBarras,1,15) 
Local cObs:=""

IF ALLTRIM(Posicione("SB1",1,xFilial("SB1")+cProd,"B1_LOCALIZ"))="S"
 lRastro   := .T.
ELSE             
 lRastro   := .F.
ENDIF

if !Empty(cBarras) .and. Posicione("SB1",1,xFilial("SB1")+cProd,"B1_COD")==cProd
  	lResp:=.t.    
	_cProduto := cProd
 Else 
	    cObs+=" Produto Invalido!"
        DLVTAviso('SIGAWMS', cObs)		    	    
Endif 

Return(lResp) 



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEndProcessoบAutor  ณAparecido Jane     บ Data ณ  22/07/2008 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบUso       ณ WMS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
******************************************************************************************************************************************************
Static Function ContaInv()
******************************************************************************************************************************************************
Local _TudoOk := .F.
Local _cEtiq  := ""
Local cNum    := Space(06)

cEoL := CHR(13)+CHR(10) // quebra de linha

If dDataBase  <  dDTREFINV
	DLVTAviso('SIGAWMS', 'Inventario nใo liberado! Solicite libera็ใo .')
	Return (.F.)
Endif

SBE->(DBSetOrder(1))
_cEnd := STRTRAN(_cEnd , " " , "") 
_cEnd := _cEnd + SPACE(15 - LEN(_cEnd))

VtClearBuffer()
aVet:=fbuscalidos(_cProduto,_cLocal,_cEnd,_cLote,_nContagem)
cAvisoInv :=""
cAvisoInv +="Cod.: " + SubStr(_cProduto,1,15)+cEoL
cAvisoInv +="Qtd.Digit.: "+Transform(aVet[5]+_nQtd,"@E9999,999.99")+cEoL
IF lRastro
cAvisoInv +="Endereco: "+ SubStr(_cEnd,1,15) 
ELSE
cAvisoInv += " "+cEoL
ENDIF       

cAvisoInv += "Confirma ? " + cEoL


//lresp:=DLVTAviso("Informa็๕es Inventario " , "Produto    :" + _cProduto+ cEoL+ "N.Entradas : "+Transform(aVet[4]+1,"@E9999")+cEoL +"Qtd.Conta. : "+Transform(aVet[5]+_nQtd,"@E9999,999.99")+ cEoL+"Endereco  : "+_cEnd + cEoL + "Confirma ?" , {'Sim', 'Nao'})==1
lresp:=DLVTAviso("Informa็๕es Inventario " , cAvisoInv , {'Sim', 'Nao'})==1
If  !lresp 
	If IsTelnet() .and. VtModelo() == "RF" 
		VTKeyBoard(chr(20)) 
	EndIf
	Return (.F.)
EndIf


SZU->(DBSetOrder(4))
if SZU->(DBSeek(xFilial('SZU') + _cLocal+ SubStr(_cEnd,1,15)+_cProduto+_cLote))    ///ZU_FILIAL, ZU_LOCPAD, ZU_LOCALIZ, ZU_COD, ZU_LOTECTL, R_E_C_N_O_, D_E_L_E_T_

	if  _nContagem=3 .and. SZU->ZU_ULTCONT ==2 
		_cAudit:=SPACE(28)
		DLVTCabec("Informe Auditor:",.F.,.F.,.T.)
		@ 01, 00 VTGet _cAudit  Pict '@!' 	  VALID !Empty(_cAudit)
		VTREAD
    endif
Endif 
  
VTMSG("Aguarde...") 
Begin Transaction
    //_TudoOK:=GrvDados(_cMat,_cLocal,_cEnd,_cLote,_cProduto,_nContagem,_nQtd)	
    
    
    _TudoOK:=GrvDados(_cCodUser,_cLocal,_cEnd,_cLote,_cProduto,_nContagem,_nQtd)	    
   
End Transaction 
If !_TudoOK  
	DLVTAviso('SIGAWMS-ERRO', 'Nao Foi Possivel Gravar Inventario!')
else
	DLVTAviso('SIGAWMS-SUCESSO', 'Item registrado no Inventario!')
Endif
VTKeyBoard(chr(20))
Return (.T.)
****************************************************************************************************************************************************
Static Function GrvDados(pMat,pLocal,pLocaliza,pLote,pProduto,pCtagem,pQuant,pNome)
****************************************************************************************************************************************************
Local _aQTotal:=0
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
         _aQTotal  := fbuscalidos(Z0R->Z0R_COD,Z0R->Z0R_LOCAL,Z0R->Z0R_LOZALI,Z0R->Z0R_LOTECT,pCtagem)
        lTudoOK:=GrvSZU(pLocal,pLocaliza,pLote,pProduto,_aQTotal[5],pCtagem,pNome)
	    If !lTudoOK
	     DisarmTransaction()
	    Endif 
End Transaction 
Return(lTudoOK)                     
******************************************************************************************************************************************************
Static Function GrvSZU(_cLocal,_cEnd,_cLote,_cProduto,_nQuant,_Ctagem,pNome)
******************************************************************************************************************************************************
Local _TudoOk := .F.
Local _cEtiq  := ""
Local cNum    := Space(06)
Local lAchou:=.F.

rRastro:=POSICIONE("SB1",1,xfilial("SB1")+_cProduto,"B1_LOCALIZ")
nQtEnd := 0

//if rRastro=="N"
// _cEnd :=  ALLTRIM(_cEnd)
// _cLote:=ALLTRIM(_cLoted)
//endif 
_cEnd :=  Left(Padr(_cEnd,15," "),15)
_cLote:=  Left(Padr(_cLote,15," "),15) 
SZU->(DBSetOrder(4))
If !SZU->(DBSeek(xFilial('SZU') + _cLocal+ SubStr(_cEnd,1,15)+_cProduto+_cLote))    ///ZU_FILIAL, ZU_LOCPAD, ZU_LOCALIZ, ZU_COD, ZU_LOTECTL, R_E_C_N_O_, D_E_L_E_T_
    lAchou:=.F.
  Else 
   lAchou:=.T.
Endif 
 

IF rRastro <> "S"

   Sb2->(DBSetOrder(1))
   Sb2->(DBSeek(xFilial('SB2')+_cProduto + _cLocal))
   nQtEnd := ( nQtEnd + Sb2->B2_QATU)
   /*
   DO WHILE Sb2->(!EOF()).AND. Sb2->B2_FILIAL==xFilial("SB2") .AND. Sb2->B2_LOCAL==_cLocal .AND. Sb2->B2_COD==_cProduto
     nQtEnd := ( nQtEnd + Sb2->B2_QATU)
      Sb2->(dbSkip())
   EndDo   
   */
ELSE  
   Sbf->(DBSetOrder(1))
   IF Sbf->(DBSeek(xFilial('SBF') + _cLocal+SubStr(_cEnd,1,15)+_cProduto)) 
   nQtEnd := ( nQtEnd + Sbf->BF_QUANT )
   ENDIF
 /*
   DO WHILE Sbf->(!EOF()).AND.Sbf->BF_FILIAL==xFilial("SBF").AND. ALLTRIM(Sbf->BF_LOCAL)==ALLTRIM(_cLocal).AND. ALLTRIM(Sbf->BF_LOCALIZ)==ALLTRIM(_cEnd) .AND. ALLTRIM(Sbf->BF_PRODUTO)==ALLTRIM(_cProduto)
     IF ALLTRIM(SBF->BF_LOTECTL)=ALLTRIM(_cLote)
 
     ENDIF 
     SbF->(dbSkip())
   EndDo
   
 */
ENDIF

cUnd := POSICIONE("SB1",1,xfilial("SB1")+_cProduto,"B1_UM")
//cTipo:= POSICIONE("SB1",1,xfilial("SB1")+_cProduto,"B1_TIPO")
cTipo:= POSICIONE("SB1",1,xfilial("SB1")+padr(_cProduto,15),"B1_TIPO")

cFormula:="  "
lTolerancia:=.F.
nSldEst=ABS(_nQuant-nQtEnd)
cFormula:= IIF((ALLTRIM(cUnd)=="PC" .OR. ALLTRIM(cUnd)=="UN"),"10","2%")

//CALCULAR AS TOLERANCIAS MAXIMAS
IF cFormula == "10"
   lTolerancia:=IIF( nSldEst>10,.F.,.T.)
// 	DLVTAviso('SIGAWMS',cFormula+ " " + cValToChar(lTolerancia)  )
 
ELSE
   lTolerancia:=IIF(   ABS((((_nQuant-nQtEnd)/nQtEnd)*100))   >2 ,.F.,.T.)       
  // DLVTAviso('SIGAWMS', cFormula+ " " + cValToChar(lTolerancia) )

ENDIF

lTol:=.F.
cStatus :=SPACE(5)
//cStatus :=IIF(_Ctagem==1,"AG2",IIF(_Ctagem==2,"AG3",IIF(_Ctagem==3,"AG4", "FOK")))

/* 1a. REGRA PA  e 1a. CONTAGEM*/
IF _Ctagem==1 .AND. cTipo=="PA"
 cStatus :=IIF(_nQuant==nQtEnd,"FOK","AG2") // 100% PA
ELSE // REGRAS 2a e 3a Contagem
 IF _Ctagem==1
   Do Case
	Case nSldEst == 0
		cStatus :="FOK"
	Case lTolerancia 
		cStatus :=IIF(_nQuant>nQtEnd,"FOKG","FOKP" )	
	Otherwise
	// Otherwise ้ nenhuma das opcoes
		cStatus :="AG2"
	EndCase
 
 ELSE //SE FOR DA 2a CONTAGEM EM DIANTE
      /* REGRAS*/
      /* SE 2a CONTAGEM BATER COM O SISTEMA OU COM A 1 CONTAGEM TODOS OS PRODUTOS */
      /* SE 2a CONTAGEM NAO BATER COM O SISTEMA NEM COM A 1 CONTAGEM, VERIFICA SE ENTRA NA TOLERANCIA */
      
   Do Case
	Case lAchou .AND. _Ctagem==2
	 if  SZU->ZU_CONT1==_nQuant  .OR. _nQuant=nQtEnd
	  cStatus :=iif((_nQuant-nQtEnd)>0,"FOK2G",iif((_nQuant-nQtEnd)<0,"FOK2P","FOK")) 
	 ELSE 
	  cStatus :="AG3"
	 endif
 	Case lAchou .AND. _Ctagem==3
     IF  SZU->ZU_CONT2==_nQuant  .OR. _nQuant=nQtEnd
	  cStatus :=iif((_nQuant-nQtEnd)>0,"FOK3G",iif((_nQuant-nQtEnd)<0,"FOK3P","FOK")) 
   endif  
		Otherwise
	// Otherwise ้ nenhuma das opcoes
		cStatus :="ER2"
	EndCase
	


 END


ENDIF




/*
//Regras de Tolerancia de inventario 2% para KG e 10 pcs para Pe็as
cStatus :=IIF(_Ctagem==1,"AG2",IIF(_Ctagem==2,"AG3","FOK"))
//DLVTAviso('SIGAWMS', ALLTRIM(cTipo)+"-"+STR(_nQuant-nQtEnd))
cTipo:= POSICIONE("SB1",1,xfilial("SB1")+padr(_cProduto,15),"B1_TIPO")
//gerar status com tolerancia 
//DLVTAviso('SIGAWMS', ALLTRIM(cTipo)+" - "+STR(_nQuant)+ " = "+STR(nQtEnd))
if (_nQuant==nQtEnd).and. cTipo =="PA" .and. _Ctagem==1                   
//	 DLVTAviso('SIGAWMS', "OK")
	 cStatus :="FOK"
elseif (_nQuant-nQtEnd)>=0 .and. (_nQuant-nQtEnd)<10 .and. nQtEnd>0 .and. (ALLTRIM(cUnd)=="PC" .OR. ALLTRIM(cUnd)=="UN") .and. cTipo <>"PA"
  cStatus :=IIF(_Ctagem == 1,"FOK1G",IIF(_Ctagem == 2,"FOK2G","FOK3G"))
elseif (_nQuant-nQtEnd)<0 .and. (_nQuant-nQtEnd)>-10 .and. nQtEnd>0 .and. (ALLTRIM(cUnd)=="PC" .OR. ALLTRIM(cUnd)=="UN") .and. cTipo <>"PA"
  cStatus :=IIF(_Ctagem == 1,"FOK1P",IIF(_Ctagem == 2,"FOK2P","FOK3P"))

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
  */


      
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
	replace SZU->ZU_LOCALIZ with IIF(rRastro=="S",SubStr(_cEnd,1,15),"")  
	replace SZU->ZU_AUDNOM1	with _cNome
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
	replace SZU->ZU_AUDNOM1	with _cNome
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
	replace SZU->ZU_AUDNOM1	with _cNome
	_TudoOk := .T.
  Endif 	 

  If _Ctagem == 2 .and. (SZU->ZU_ULTCONT == 1 .or.  SZU->ZU_ULTCONT == 2)
  		If SZU->ZU_ULTCONT = 1 
				replace SZU->ZU_SLD02    with nQtEnd   
				replace SZU->ZU_ULTCONT  with 2
            replace SZU->ZU_TIME    with TIME() 
		    	replace SZU->ZU_AUDNOM2	with _cNome
		Endif 		
		replace SZU->ZU_CONT2      with _nQuant
		replace SZU->ZU_DIF02	   with SZU->ZU_CONT2-SZU->ZU_SLD02
      replace SZU->ZU_STATUS	with cStatus				
    	replace SZU->ZU_DATACT2	 with dDataBase
		replace SZU->ZU_TIME02	 with TIME()
		replace SZU->ZU_USUCT2   with UPPER(ALLTRIM(cUserName))
   	replace SZU->ZU_AUDNOM2	with _cNome 
		_TudoOk := .T. 
   Endif 

   If _Ctagem == 3 .and. (SZU->ZU_ULTCONT == 3 .or.  SZU->ZU_ULTCONT == 2)
		If SZU->ZU_ULTCONT = 2  
				replace SZU->ZU_SLD03   with nQtEnd   
				replace SZU->ZU_ULTCONT with 3
				replace SZU->ZU_AUDMAT3 with SUBSTR(_cAudit,1,6)
				replace SZU->ZU_AUDNOM3 with _cNome
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
		replace SZU->ZU_AUDMAT3 with SUBSTR(_cAudit,1,6)
		replace SZU->ZU_AUDNOM3 with _cNome
		_TudoOk := .T.
   Endif  
Endif
//ConfirmSX8()  
SZU->(MsUnlock())

If !_TudoOK
	  cObs:='Nao Foi Possivel Gravar Inventario!'
	Else 
	  cObs:='GRAVADO COM SUCESSO !!!!!!'
Endif

Return (_TudoOK)
  
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
Static Function cNumSZU(pNum)
********************************************************************************************************************************************************
Local cAlias
Local cOrdem
calias:=alias()
cOrdem:=dbSetOrder()

DbSelectArea("SZU")
DbSetOrder(01)
If !DbSeek(xFilial("SZU")+pNum)
  dbSelectArea("SZU")
  dbSetOrder(cOrdem)
  Return(pNum)
Endif  

While .T.
 pNum:= StrZero(Val(pNum)+1,6)
 If !DbSeek(xFilial("SZU")+pNum) 
   dbSelectArea("SZU")
   dbSetOrder(cOrdem)
   Return(pNum)
 Endif 
 If pNum="999999"
   Exit 
 Endif 
End     
dbSelectArea("SZU")
dbSetOrder(cOrdem)
Return(pNum) 
******************************************************************************************************************************************************
Static Function VldCtInv(_cLocal,_cEnd,_cProd,pContagem,_cLote)
******************************************************************************************************************************************************
Local _aAreaAtu := GetArea()
Local cEnd
Local rRastro

rRastro:=POSICIONE("SB1",1,xfilial("SB1")+_cProduto,"B1_LOCALIZ")

cEnd :=  Left(Padr(_cEnd,15," "),15)
_cLote:= Left(Padr(_cLote,10," "),10)
If Localiza(_cProduto) .and. alltrim(cEnd)<>"Z" .AND. alltrim(cEnd)<>"z"
 SBE->(DBSetOrder(1))
 If SBE->(!DBSeek(xFilial('SBE')+_cLocal+cEnd)) 
	  cObs:='O endereco '+cEnd+' nao existe este Armazem.'
      DLVTAviso('SIGAWMS', cObs)
	  Barras:=Space(28)
	  _cProduto:=space(15)
	  _nQtd:=0
	  Return (.F.)
 Endif
 if alltrim(cEnd)<>"Z" .AND. alltrim(cEnd)<>"z"
  IF !vldBlqLocaliz(_cLocal,cEnd) 
	  cObs:='O endereco '+Alltrim(cEnd)+' bloqueado neste Armazem.'
      DLVTAviso('SIGAWMS', cObs)
	  Barras:=Space(28)
	  _cProduto:=space(15)
	  _nQtd:=0
 	Return (.F.)
  Endif
 endif
Endif
SZU->(DBSetOrder(4))

if SZU->(!DBSeek(xFilial('SZU') + _cLocal+cEnd+_cProduto+_cLote))    ///ZU_FILIAL, ZU_LOCPAD, ZU_LOCALIZ, ZU_COD, ZU_LOTECTL, R_E_C_N_O_, D_E_L_E_T_
  If pContagem > 1
      cObs:='Produto/Endere็o nใo tem 1บ Contagem'
      DLVTAviso('SIGAWMS', cObs)
      _cProduto:=space(15)
      _nQtd:=0
     Return(.f.)
   Else  
     Return(.t.)
  Endif    
Endif 

If pContagem = 2 .and. Empty(SZU->ZU_DTINV2) .and. SZU->ZU_ULTCONT = 1 //Sarkis
		  cObs:='2a.Contagem nใo liberada!'
	  	  Barras:=Space(28)
	      DLVTAviso('SIGAWMS', cObs)
	      _cProduto:=space(15)
	      _nQtd:=0
		  Return (.F.)
elseif pContagem = 3 .and. Empty(SZU->ZU_DTINV3) .and. SZU->ZU_ULTCONT = 2 
		  cObs:='3a.Contagem nใo liberada!'
	      DLVTAviso('SIGAWMS', cObs)
	  	  Barras:=Space(28)
	  	  _cProduto:=space(15)
	  	  _nQtd:=0
  		  Return (.F.) 
Endif


IF SZU->(!EOF()).AND.SZU->ZU_FILIAL==xFilial("SZU").AND.SZU->ZU_COD==_cProduto.AND.SZU->ZU_LOCALIZ==_cEnd

	  
	  If (pContagem == 1 .AND. SZU->ZU_ULTCONT >= 1) .OR. left(SZU->ZU_STATUS,3)="FOK" //ricky

		   cObs:="Produto jแ fez a "+Transform(SZU->ZU_ULTCONT,'@R 9')+"บ Contagem "
	  	   IIF(left(SZU->ZU_STATUS,3)="FOK",cObs+="OK!",cObs+=", Aguardando Proxima.  ")
	      DLVTAviso('SIGAWMS-INVENTARIO', cObs)
	      _cProduto:=space(15)
	      _nQtd:=0
	      
	      // aqui limpa
	      //VTKeyBoard(chr(20))
			//VTCLEARBUFFER() 
	     Return(.F.)

	  Elseif pContagem == 2
  		  IF SZU->ZU_ULTCONT >= 2
		   cObs:="Produto jแ fez a "+Transform(SZU->ZU_ULTCONT,'@R 9')+"บ Contagem "
   	   IIF(left(SZU->ZU_STATUS,3)="FOK",cObs+="OK!",cObs+=", Aguardando Proxima.  ")
	      DLVTAviso('SIGAWMS-INVENTARIO', cObs)
	      _cProduto:=space(15)
	      _nQtd:=0
	     Return(.F.)
 		  
  		  ENDIF

		 // IF SZU->ZU_USUCT1 == UPPER(ALLTRIM(cUserName))  .and. Empty(SZU->ZU_USUCT2)
		 IF UPPER(ALLTRIM(SZU->ZU_AUDNOM1))= UPPER(ALLTRIM(_cNome)) .and. Empty(SZU->ZU_AUDNOM2)
		      cObs:="Resp.Contagem da 1o nao pode realizar a 2o."
		      DLVTAviso('SIGAWMS', cObs)
		      _cProduto:=space(15)
		      _nQtd:=0 
		      Return(.F.)
		  Endif 

	  Elseif pContagem == 3
		  If  SZU->ZU_ULTCONT >= 3 
		      cObs:=IIf(SZU->ZU_ULTCONT<2,"Produto sem  "+Transform(SZU->ZU_ULTCONT+1,'@R 9')+"บ Contagem ","Produto jแ fez "+Transform(SZU->ZU_ULTCONT,'@R 9')+"บ Contagem ") 
      	   IIF(left(SZU->ZU_STATUS,3)="FOK",cObs+="OK!",cObs+=", Aguardando Proxima.  ")
		      DLVTAviso('SIGAWMS', cObs)
		      _cProduto:=space(15)
		      _nQtd:=0
		     Return(.F.)
		  Endif 
//		  if SZU->ZU_USUCT2 == UPPER(ALLTRIM(cUserName)) .and. Empty(SZU->ZU_USUCT3)
				IF UPPER(ALLTRIM(SZU->ZU_AUDNOM2))= UPPER(ALLTRIM(_cNome)) .and. Empty(SZU->ZU_AUDNOM3)
		      cObs:="Resp.Contagem da 2o nao pode realizar a 3o."
 		      DLVTAviso('SIGAWMS', cObs)
		      _cProduto:=space(15)
		      _nQtd:=0
		      Return(.f.)
		  Endif 
	  Endif 	     	    

endif
RestArea(_aAreaAtu)
Return (.t.)
********************************************************************************************************************
Static Function vldBlqLocaliz(_cLocal,_cEndereco)//Verifica se o endere็os esta Bloqueado ou nใo
********************************************************************************************************************
Local lResp:=.T.            
Local _aAreaAtu := GetArea()
cBlq:=Posicione("SBE",1,xFilial("SBE")+_cLocal+_cEndereco,"BE_STATUS")
If cBlq = '3'
  lResp:=.F.            
Endif 
RestArea(_aAreaAtu)
Return(lResp)
********************************************************************************************************************
Static Function fGravEnd(_cLocal,_cEnd,_nContagem)//Encerra o endere็o para leitura 
********************************************************************************************************************
SZU->(DbSetOrder(04))//ZU_FILIAL, ZU_LOCPAD, ZU_LOCALIZ, ZU_COD, ZU_LOTECTL, R_E_C_N_O_, D_E_L_E_T_
SZU->(DbSeek(xFilial("SZU")+_cLocal+_cEnd),.t.)

While SZU->(!Eof()).and. SZU->(ZU_FILIAL+ZU_LOCPAD+ZU_LOCALIZ)==xFilial("SZU")+_cLocal+_cEnd

	    SZU->(RecLock("SZU",.F.))	
	      if _nContagem=1      
		      SZU->ZU_TIME:=""
	       elseif _nContagem=2.AND.SZU->ZU_ULTCONT=2 
   		      SZU->ZU_TIME:=""
	       elseif _nContagem=3.AND.SZU->ZU_ULTCONT=3 
			  SZU->ZU_TIME:=""	       	       
	      Endif 
		SZU->(MsUnLock("SZU"))
		SZU->(DbSkip())

End 
Return 
********************************************************************************************************************
Static Function fvldEnd(_cLocal,_cEnd)//Valida o Endere็o
********************************************************************************************************************
SBE->(DBSetOrder(1)) 
_cEnd := alltrim(_cEnd)   // STRTRAN(_cEnd , " " , "")
_cEnd := _cEnd + SPACE(15 - LEN(_cEnd))

If alltrim(_cLocal)=="01" .OR. !lRastro
   Return (.T.)   //valida local do PAดs por nao possuirem endere็o
Endif
IF SBE->(!DBSeek(xFilial('SBE')+_cLocal+_cEnd)) .AND. ALLTRIM(_cEnd)<>'Z' .AND. ALLTRIM(_cEnd)<>'z'
	DLVTAviso('SIGAWMS', 'O endereco '+Alltrim(_cEnd)+' nao existe neste Armazem.')
	Return (.F.)
Endif

//IF !u_vldBlqLocaliz(_cLocal,_cEnd,.t.)
//	DLVTAviso('SIGAWMS', 'O endereco '+Alltrim(_cEnd)+' bloqueado neste Armazem.')
//	Return (.F.)
//Endif 
Return (.t.)



Static Function DocSd3()
 Local nDoc:=0
 Local cDocs
 cAliasSD3:= GetNextAlias()
 BeginSql Alias cAliasSD3 
  SELECT isnull(MAX(ZU_NUMETQ),'000000') AS D3_DOC FROM %Table:SZU% WHERE ZU_FILIAL='01' 
  AND D_E_L_E_T_='' 
 EndSql 
dbSelectArea(cAliasSD3)  
dbgotop()
nDoc+=VAL((cAliasSD3)->D3_DOC)+1
dbSelectArea(cAliasSD3) 
dbclosearea() 
cDocs:=STRZERO(nDoc,6) 
Return(cDocs) 


Static Function ValidEnter()
If (VTLastKey()==13) 
		  Return(.T.)
		  VTPause
ELSE
 RETURN(.F.)
EndIf	
RETURN
   
********************************************************************************************************************
Static Function fvldEnd2(_cLocal,_cEnd,_cProduto)//Valida o Endere็o
********************************************************************************************************************
local lRet:=.F.

SBE->(DBSetOrder(1)) 
_cEnd := alltrim(_cEnd)   // STRTRAN(_cEnd , " " , "")
_cEnd := _cEnd + SPACE(15 - LEN(_cEnd))

cProduto2:=alltrim(_cProduto)
cProduto2:=SUBSTR(alltrim(cProduto2),1,15) 
/*
If alltrim(_cLocal)=="01"
   lRet:=.T.   //valida local do PAดs por nao possuirem endere็o
Endif       
*/
 
IF lRastro 
	IF (SBE->(!DBSeek(xFilial('SBE')+_cLocal+_cEnd)) .AND. ALLTRIM(_cEnd)<>'Z' .AND. ALLTRIM(_cEnd)<>'z') 
		DLVTAviso('SIGAWMS', 'O endereco '+Alltrim(SubStr(_cEnd,1,15))+' nao existe neste Armazem..')
  		_cEnd:=space(28)     
	
		lRet:=.F.
	ELSE
	 	lRet:=.T.	
	ENDIF
  //	VTClearBuffer()
//	return(lRet)
Else
 	lRet:=.T.	

Endif                            

//Obs :=_cLocal +Transform(_nContagem,'@R 9')+ Alltrim(SubStr(_cEnd,1,15))+ cProduto2


//Z0R_FILIAL, Z0R_LOCAL, Z0R_CONTAG, Z0R_LOZALI, Z0R_COD, Z0R_LOTECT, R_E_C_N_O_, D_E_L_E_T_
//DLVTAviso('TESTE',Obs)

DbSelectArea("Z0R")
DbSetOrder( 1 )
IF DbSeek(xFilial("Z0R")+_cLocal +Transform(_nContagem,'@R 9')+ SubStr(_cEnd,1,15)+ cProduto2)
	DLVTAviso('SIGAWMS', 'Produto jแ contado  Contagem :  ' + Transform(_nContagem,'@R 9') +' neste endere็o '+ Alltrim(SubStr(_cEnd,1,15)) )
	_cEnd:=space(28)     
	lRet:=.F.
  Obs := cProduto2
else
 	lRet:=.T.	

End

//IF !u_vldBlqLocaliz(_cLocal,_cEnd,.t.)
//	DLVTAviso('SIGAWMS', 'O endereco '+Alltrim(_cEnd)+' bloqueado neste Armazem.')
//	Return (.F.)
//Endif 
Return (lRet)


Static function Vld2x(_cLocal,_cEnd,cProduto2)
local lRet:=.F.
Local Obs :=""
_cEnd := alltrim(_cEnd)   // STRTRAN(_cEnd , " " , "")
_cEnd := _cEnd + SPACE(15 - LEN(_cEnd))

cProduto2:=alltrim(cProduto2)
cProduto2:=SUBSTR(cProduto2,1,15) 



DbSelectArea("Z0R")
DbSetOrder( 1 )
IF DbSeek(xFilial("Z0R")+_cLocal +Transform(_nContagem,'@R 9')+ (SubStr(_cEnd,1,15))+ cProduto2)
	DLVTAviso('SIGAWMS', 'Produto jแ contado.  Contagem :  ' + Transform(_nContagem,'@R 9') +' neste endere็o '+ Alltrim(SubStr(_cEnd,1,15)) )
	_cEnd:=space(28)     
	lRet:=.F.
	VTClearBuffer()
	lRet:=.F.
else
  lRet:=.T.
//  Obs :=_cLocal +Transform(_nContagem,'@R 9')+(SubStr(_cEnd,1,15))+ cProduto2
//  DLVTAviso('NAO ACHOU',Obs)
End

Return (lRet)



