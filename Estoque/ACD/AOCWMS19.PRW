#INCLUDE 'RWMAKE.CH'
#INCLUDE 'APVT100.CH'

//CONFERENCIA DE APONTAMENTO
user function AOCWMS19()
	
Private _cProduto := Space(20)


 VTClearBuffer() 
	
While .T.
	DLVTCabec("Conferencia : "       ,.F.,.F.,.T.)               
	   //@ 01, 00 VTSay PadR('Doc. :' , VTMaxCol())
	   @ 01, 00 VTSay PadR('Etiqueta :' , VTMaxCol())
	   
  	   @ 01, 06 VTGet _cProduto Pict '@!' 	VALID !Empty(_cProduto) .AND. fVldBarras(ALLTRIM(_cProduto))
	   
	VTREAD
	
	If (VTLastKey()==27)
		If (lRet:=DLVTAviso('', 'Deseja encerrar a conferencia ?', {'Sim', 'Nao'})==1)
			Exit
		EndIf
	EndIf
	
EndDo
Return(.T.)

Static Function fVldBarras(_cProduto)  //saldo no endereço
 Local cAliasZ04:= GetNextAlias()
 BeginSql Alias cAliasZ04
  select  R_E_C_N_O_  REG from CB0010 WHERE CB0_CODETI=%exp:_cProduto% 
 EndSql 
dbSelectArea(cAliasZ04)  
dbgotop()
IF !EOF()
 dbSelectArea("Z04")
 Z04->(DBGOTO((cAliasZ04)->REG ))
 Z04->(RecLock("Z04",.F.))
 Z04->Z04_STATUS:='1'
 Z04->(MsUnlock())
 dbSelectArea(cAliasZ04)
ELSE
  DLVTAviso('SIGAWMS',"ETIQUETA NAO EXISTE !!")
ENDIF 
dbSelectArea(cAliasZ04) 
dbclosearea()  
Return(.T.)