#include "protheus.ch"
#include "topconn.ch"  
#include "vkey.ch"


User Function ZT0REG()    

	//Trabalho/apoio
	local aCampos := {}
	//local cCampo := ""
	local aCores := {}

	//Indica a permissão ou não para a operação (pode-se utilizar 'ExecBlock')
	private cDelFunc := ".F." // Operacao: EXCLUSAO
	private cCadastro := "RNC - Materiais" //Título das operações
	private aRotina := {} //Opçoes de operações

	//-- procedimentos ---------------------------------------------------------------------
	aAdd(aRotina, {"Pesquisar", "AxPesqui", 0, 1 })
	aAdd(aRotina, {"Visualizar", "U_EXP0923A(2)", 0, 2 })
	aAdd(aRotina, {"Incluir", "U_EXP0923A(3)", 0, 3 })
	aAdd(aRotina, {"Baixar/Reprov", "U_EXP0923A(4)", 0, 4 })
	aAdd(aRotina, {"Excluir", "U_EXP0923A(5)", 0, 5 })
	aAdd(aRotina, {"Auditar", "U_AuditDados()", 0, 5 })
	aAdd(aRotina, {"ReEnviarEmail", "U_RenviarEmailRNC()", 0, 5 })
	
//	aAdd(aRotina, {"Imprimir", "U_IMPRNC()", 0, 5 })
	aAdd(aRotina, { "Legenda" ,"u_BLegenda" ,0 , 3})

	aAdd(aCores, {"EMPTY(ZT0->ZT0_STATUS) .OR.(ZT0->ZT0_STATUS)=='P' ", "BR_AMARELO" })
	aAdd(aCores, {"(ZT0->ZT0_STATUS)=='B'", "BR_VERDE" })
	aAdd(aCores, {"(ZT0->ZT0_STATUS)=='R'", "BR_PRETO" })
	aAdd(aCores, {"(ZT0->ZT0_STATUS)=='A'", "BR_LARANJA" })


	aAdd(aCampos, {"Data", "ZT0_DATA"})
	aAdd(aCampos, {"No Registro", "ZT0_DOC"})   
	


	chkFile("ZT0")
	ChkFile("ZT2",.F.)
	dbSelectArea("ZT0")
	ZT0->(dbSetOrder(1))

	mBrowse(6,1,22,75,"ZT0",aCampos,,,,,aCores)

return

user function BLegenda()
	local aLegenda := {}

	aAdd(aLegenda, {"BR_AMARELO", "Pendente" })
	aAdd(aLegenda, {"BR_VERDE", "Atendido" })
	aAdd(aLegenda, {"BR_PRETO", "Reprovado" })
	aAdd(aLegenda, {"BR_LARANJA", "Auditado" })

	brwLegenda("Semafaro", "Legenda", aLegenda)

return nil


User Function EXP0923A(cOpc)
	Local aArea := GetArea()
	//Local nCntFor := 0
	Local aRegistro := {}
	Local aAlGetDad := {}
	Local lVirtual	:= .T.
	Local nFreeze	:= 0
	Local nLinhas	:= 50
	Local nSizeHeader := 320
	Local aButtons	:= {}
	//Local aCordW	:= {}
	Local cStatus:= ""
	Local _cCampos:= "ZT2_ITEM,ZT2_COD,ZT2_DESCRI,ZT2_OENDER,ZT2_DENDER,ZT2_QUANT,ZT2_OBS"	
	Local _ni, nUsado
	Private aCols := {}
	Private aHeader := {}    
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria variaveis M->????? da Enchoice	e Getdados						  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cOpcGr := iif(cOpc==3,3,2)
	RegToMemory("ZT0",(cOpc==3))
	RegToMemory("ZT2",(cOpc==3))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montando aHeader                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("Sx3")
	dbSetOrder(1)
	dbSeek("ZT2")
	nUsado:=0
	aHeader:={}             
	

	While !Eof() .And. (x3_arquivo == "ZT2")
		If AllTrim(X3_CAMPO)=="ZT2_FILIAL" .Or. AllTrim(X3_CAMPO)=="ZT2_DOC"
			dbSkip()
			Loop
		Endif
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel .AND. Alltrim(X3_CAMPO)$ Alltrim(_cCampos)
			nUsado:=nUsado+1
			cNome := AllTrim(X3_CAMPO)
			AADD(aHeader,{ TRIM(x3_titulo), AllTrim(x3_campo), x3_picture,;
			x3_tamanho, x3_decimal,"AllwaysTrue()", x3_usado, x3_tipo, x3_arquivo, x3_context } )
		Endif
		dbSkip()
	End
	

	If cOpc==3    
	 aCols:={Array(nUsado+1)}
	  aCols[1,nUsado+1]:=.F.
	For _ni:=1to nUsado
	 aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
	Next
	
	Else

		aCols     := {}
		aRegistro := {}
		DBSelectArea("ZT2")
		DBSetOrder(1)                     
		
		DBSeek(xFilial("ZT2")+ ZT0->ZT0_DOC )
		
		While !Eof() .and. ZT2->ZT2_FILIAL == xFilial("ZT2") .AND.  ZT2->ZT2_DOC == ZT0->ZT0_DOC
			AADD(aCols,Array(nUsado+1))
			AADD(aRegistro,ZT2->(RECNO()))
			For _ni:=1 to nUsado
				aCols[Len(aCols),_ni] := FieldGet(FieldPos(aHeader[_ni,2]))
			Next
				aCols[Len(aCols),nUsado+1] := .F.
			dbSkip()
		EndDO
		
	
		
		

	Endif

	cTitulo    := "Registro de não conformidades - Pagamentos/Devoluções"
	cAliasGetD := "ZT2"
	cAliasEnchoice := "ZT0"
	cLinOk     := "AllwaysTrue()"
	cTudOk     := "AllwaysTrue()"
	cFieldOk   := "AllwaysTrue()"
  	aCpoEnchoice   := {"ZT0_DOC","ZT0_DATA","ZT0_STATUS","ZT0_NOMESO","ZT0_NOMERE","ZT0_TIPO"} //{"Z00_NUM","Z00_TITULO","Z00_GRUPO","Z00_DTINI","Z00_DTFIM","Z00_RESPON"}
	aAlGetDad	:= {"ZT2_ITEM,ZT2_COD,ZT2_DESC,ZT2_QUANT,ZT2_OBS"} //{"ZT2_ITEM,ZT2_COD,ZT2_DESC,ZT2_OENDER,ZT2_DENDER,ZT2_QUANT,ZT2_OBS"} //{"Z01_CLIENT","Z01_LOJA","Z01_CONTAT","Z01_UF"}


	If cOpc==3 
		aAltEnchoice := {"ZT0_RESPON","ZT0_OBSG","ZT0_OP","ZT0_TIPO"}//{"ZT0_DOC","ZT0_DATA","ZT0_STATUS"} //{"Z00_TITULO","Z00_GRUPO","Z00_DTINI","Z00_DTFIM","Z00_RESPON"}     
	Else
		aAltEnchoice := {"ZT0_STATUS","ZT0_OBSG"}//{"ZT0_STATUS"}//{"Z00_TITULO","Z00_DTFIM"}     
	Endif

	//_lRet := Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,cOpc,cOpcGr,cFieldOk,lVirtual,nLinhas,aAltEnchoice,nFreeze,aButtons,,nSizeHeader,aAlGetDad)
	_lRet := Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,cOpc,cOpcGr,cFieldOk,lVirtual,nLinhas,aAltEnchoice,nFreeze,aButtons,,nSizeHeader)
  
			  //	Modelo3(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk,cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnchoice,nFreeze, aButtons, aCordW, nSizeHeader)

	If _lRet   
		//Se opção for Inclusao
		If cOpc==3
		  Processa({||Grvdados()},cCadastro,"Gravando os dados, aguarde...")
 
 		//Se opção for Alteracao
		ElseIf cOpc==4
		IF ZT0->ZT0_STATUS ='P'	
		   cStatus:=M->ZT0_STATUS
		   DO CASE
		    CASE cStatus=='R'
		      cStatus:='REPROVADO'
		    CASE cStatus=='B'     
  		      cStatus:='ATENDIDO'
  		   CASE cStatus=='P'     
  		      cStatus:='PENDENTE'
		   CASE cStatus=='A'     
  		      Alert("Favor utilizar a rotina de Auditar")
  		    return
  		  ENDCASE      
  		    
		   If cStatus!='PENDENTE' .AND. MsgYesNo("Alterar STATUS para <b>" + cStatus+"</b>" , "Atenção" )  		      
		      Processa({||Altdados()},cCadastro,"Gerando confirmação, aguarde...")
		   EndIf 
         

		Else
		  Alert ("Não foi possível realizar Baixa. <br>Documento Já <b> Atendido / Reprovado </b>" )  
		End


	   //Se opção for exclusão          
      ElseIf cOpc == 5
          If MsgYesNo("Confirma exclusão dos dados ?", cCadastro)
            //   Processa({||Excluidados()},cCadastro,"Excluindo os dados, aguarde...") 
            Alert ("Não foi possível excluir o Documento." ) 
          EndIf  
          
      Endif
	Endif

	RestArea(aArea)
Return

Static Function GrvDados()
Local nCntFor
 			For nCntFor:=1 To Len(aCols)		
				If (!aCols[nCntFor][Len(aHeader)+1]) .AND. (!Empty(aCols[nCntFor][1]))
					RecLock("ZT2",.T.) 
					ZT2->ZT2_FILIAL  := xFilial("ZT2")
					ZT2->ZT2_DOC  := M->ZT0_DOC
					ZT2->ZT2_ITEM    := aCols[nCntFor][1]
					ZT2->ZT2_COD := aCols[nCntFor][2]
					ZT2->ZT2_DESCRI := aCols[nCntFor][3]
					ZT2->ZT2_OENDER := ConsultaEnd(aCols[nCntFor][2])
					//ZT2->ZT2_DENDER  := aCols[nCntFor][5]
					ZT2->ZT2_QUANT  := aCols[nCntFor][4]                        
					ZT2->ZT2_OBS  := aCols[nCntFor][5]
					MsUnLock()					
				Endif
			Next

			RecLock("ZT0",.T.) 
			ZT0->ZT0_FILIAL	:= XFILIAL("ZT0")
			ZT0->ZT0_DOC 	:= M->ZT0_DOC
			ZT0->ZT0_DATA 	:= M->ZT0_DATA    
			ZT0->ZT0_TIPO := M->ZT0_TIPO
			ZT0->ZT0_STATUS:=M->ZT0_STATUS
			ZT0->ZT0_SOLICI:=M->ZT0_SOLICI
			ZT0->ZT0_NOMESO:=M->ZT0_NOMESO
			ZT0->ZT0_EMAILS:=M->ZT0_EMAILS
			ZT0->ZT0_RESPON:=M->ZT0_RESPON
			ZT0->ZT0_NOMERE:=M->ZT0_NOMERE
			ZT0->ZT0_EMAILR:=M->ZT0_EMAILR
			ZT0->ZT0_OBSG:=M->ZT0_OBSG
			ZT0->ZT0_OP:=M->ZT0_OP
			MsUnLock() 
			confirmSx8()
			
			

		   cStatus:=M->ZT0_STATUS
		   DO CASE
		    CASE cStatus=='R'
		      cStatus:='Reprovado'
		    CASE cStatus=='B'     
  		      cStatus:='Atendido'
		    CASE cStatus=='P'     
  		      cStatus:='Pendente'
  		  ENDCASE      
		 			
	    lEmail:=U_fAvisoRNC(ZT0_DOC,Dtoc(DATE()),TIME(),ZT0_NOMESO,ZT0_EMAILS,ZT0_NOMERE,ZT0_EMAILR,cStatus,ZT0_OBSG,' ',' ',ZT0_OP,UPPER(ZT0_TIPO) )
	    // lEmail:=U_fAvisoRNC(M->ZT0_DOC,Dtoc(M->ZT0_DATA),M->ZT0_HORA,M->ZT0_NOMESO,M->ZT0_EMAILS,M->ZT0_NOMERE,M->ZT0_EMAILR,cStatus,ZT0_OBSG,RETCODUSR(),Dtoc(DATE()),M->ZT0_OP )
     IF lEmail
       MSGINFO( 'E-mail enviado com Sucesso.', cCadastro )    
     ELSE
	     ALERT('Erro ao enviar o E-mail')
  	  ENDIF
				

Return



Static Function ConsultaEnd(cCod)
Local Endereco:=space(20)
cAliasSBF:= GetNextAlias()
// saldos dos enderecos
BeginSql Alias cAliasSBF
  select BF_LOCALIZ,BF_PRODUTO,BF_QUANT from %Table:SBF% SBF
  WHERE BF_FILIAL=%exp:XFILIAL("SBF")% AND BF_PRODUTO=%exp:cCod% 
  AND SBF.%NotDel%  AND BF_LOCAL="11" ORDER BY BF_QUANT	DESC
EndSql
dbSelectArea(cAliasSBF)  
dbgotop()
 Endereco:=(cAliasSBF)->BF_LOCALIZ 
dbSelectArea(cAliasSBF) 
dbclosearea()
Return(Endereco)




Static Function AltDados()

			RecLock("ZT0",.F.) 
			ZT0->ZT0_FILIAL	:= XFILIAL("ZT0")
			ZT0->ZT0_STATUS:=M->ZT0_STATUS
			ZT0->ZT0_DTBAIXA:=DATE()
			ZT0->ZT0_HORABA:=TIME()
			ZT0->ZT0_NOMEBA:=UsrRetName(RETCODUSR()) 
			ZT0->ZT0_OBSG:=M->ZT0_OBSG			
			MsUnLock() 
			

		   cStatus:=M->ZT0_STATUS
		   DO CASE
		    CASE cStatus=='R'
		      cStatus:='Reprovado'
		    CASE cStatus=='B'     
  		      cStatus:='Atendido'
		    CASE cStatus=='P'     
  		      cStatus:='Pendente'
  		  ENDCASE     			
			
			
	  lEmail:=U_fAvisoRNC(M->ZT0_DOC,Dtoc(M->ZT0_DATA),M->ZT0_HORA,M->ZT0_NOMESO,M->ZT0_EMAILS,M->ZT0_NOMERE,M->ZT0_EMAILR,cStatus,ZT0_OBSG,RETCODUSR(),Dtoc(DATE()),M->ZT0_OP,UPPER(M->ZT0_TIPO) )
     IF lEmail
       MSGINFO( 'E-mail enviado com Sucesso.', cCadastro )    
     ELSE
	     ALERT('Erro ao enviar o E-mail')
  	  ENDIF
		
	
return

User Function AuditDados()
IF ZT0_STATUS="B" 
	
	If MsgYesNo("Confirma Registro " +ZT0_DOC + ", já foi auditado ?", cCadastro)
	          	RecLock("ZT0",.F.) 
					ZT0->ZT0_STATUS:='A'
	 				MsUnLock()  
	            MSGINFO( 'Sucesso, registro auditado !', cCadastro )
	EndIf  
Else
 ALERT('Verifique o Status do Registro, não foi Atendido/Aprovado')
EndIf
return
User Function RenviarEmailRNC()
IF ZT0_STATUS="B" 
	 ALERT('Solicitação já foi Atendida') 
EndIf

		   cStatus:=ZT0_STATUS
		   DO CASE
		    CASE cStatus=='R'
		      cStatus:='Reprovado'
		    CASE cStatus=='B'     
  		      cStatus:='Atendido'
		    CASE cStatus=='P'     
  		      cStatus:='Pendente'
  		  ENDCASE    
	            

	 lEmail:=U_fAvisoRNC(ZT0_DOC,Dtoc(DATE()),TIME(),ZT0_NOMESO,ZT0_EMAILS,ZT0_NOMERE,ZT0_EMAILR,cStatus,ZT0_OBSG,' ',' ',ZT0_OP,UPPER(ZT0_TIPO) ) 
	 
	    // lEmail:=U_fAvisoRNC(M->ZT0_DOC,Dtoc(M->ZT0_DATA),M->ZT0_HORA,M->ZT0_NOMESO,M->ZT0_EMAILS,M->ZT0_NOMERE,M->ZT0_EMAILR,cStatus,ZT0_OBSG,RETCODUSR(),Dtoc(DATE()),M->ZT0_OP )
     IF lEmail
       MSGINFO( 'E-mail enviado com Sucesso.', cCadastro )    
     ELSE
	     ALERT('Erro ao enviar o E-mail')
  	  ENDIF

return





