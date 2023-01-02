#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "TbiConn.ch"
#Include "TbiCode.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ GIWFSTREP ³ Autor ³ Denis Polastri        ³ Data ³05/02/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cliente   ³ Gama Italy        ³Contato ³ Cassio: 5593-7420              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Workflow que envia e-mail automatico com log da replica     ³±±
±±³          ³ da base de dados                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Gama Italy - Replica de dados                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function GIWFSTREP( aParam )

	Local lWorkflow := .F.
	Local lQuery    := .F.
	Local nReg      := 0
	Local cFileHtml	:= ""
	Local cModo     := ""
	Local cCtaWF    := ""
	Local cSubject  := ""
	Local cMailTo   := ""
	Local cArq1     := "\workflow\WFStatRep.htm"
	Local cArq2     := "\workflow\WFStatBranco.htm"
	Local oProcess, oHtml
	
	If ValType(aParam) == "A"
		lWorkflow := .T.
	 	Prepare Environment Empresa aParam[1] Filial aParam[2]
	EndIf

	If !File(cArq1) .And. !File(cArq2)
		ConOut(DtoC(dDataBase)+" - "+Time()+" - [WorkFlow Email Replica Dados] - O(s) arquivo(s) HTML nao estao na pasta ou nao existem!")
		If !lWorkflow
			Alert("O(s) arquivo(s) HTML nao estao na pasta ou nao existem!")
		EndIf
		Return()
	EndIf

	cModo   := AllTrim(GetMv("MV_WFMODMF",,"M"))
	cCtaWF  := AllTrim(GetMv("MV_WFRPCBS",,"WF_REPLICA_BASE_M"))
	cMailTo := AllTrim(GetMv("MV_GIADMSY",,"denis.polastri@symm.com.br"))
	
	cSubject := "Replica Base - "+AllTrim(SM0->M0_NOME)+" - "+If( cModo=="M","São Paulo","Manaus" )+" - Status de Envio e Recebimento."

	If cModo == "M"
		cOrigem := "MTZ"
	Else
		cOrigem := "LJ"+cFilAnt	
	EndIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Verifica se existem dados para a dataBase  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lQuery := QueryZ01("D")
	If !lQuery
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Cria o objeto oHTML para receber as informacoes do banco  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cFileHtml := "\workflow\WFStatBranco.htm"
		oProcess:=TWFProcess():New( cCtaWF , cSubject )
		oProcess:NewTask( cSubject , cFileHtml )
		oHtml:=oProcess:oHTML
		oProcess:NewVersion(.T.)
		oProcess:cSubject:=cSubject
		oProcess:cTo:=cMailTo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Inclui a filial - Sao Paulo ou Manaus  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oHtml:ValByName( "cModo" , If( cModo=="M","São Paulo","Manaus" ) )
	Else 
		TMP->( DbCloseArea() )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Cria o objeto oHTML para receber as informacoes do banco  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cFileHtml:= "\workflow\WFStatRep.htm"
		oProcess:=TWFProcess():New( cCtaWF , cSubject )
		oProcess:NewTask( cSubject , cFileHtml )
		oHtml:=oProcess:oHTML
		oProcess:NewVersion(.T.)
		oProcess:cSubject:=cSubject
		oProcess:cTo:=cMailTo	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Inclui a filial - Sao Paulo ou Manaus  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oHtml:ValByName( "cModo" , If( cModo=="M","São Paulo","Manaus" ) )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Lista os e-mails enviados  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lQuery := QueryZ01("E",cOrigem)
		If lQuery
			While TMP->( !Eof() )
				GetItemHtm("1",oHtml,lQuery)
				TMP->( DbSkip() )
			End
			TMP->( DbCloseArea() )
		Else
			GetItemHtm("1",oHtml,lQuery)
		EndIF
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
		//³  Lista os e-mails recebidos  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lQuery := QueryZ01("R",cOrigem)
		If lQuery
			While TMP->( !Eof() )
				GetItemHtm("2",oHtml,lQuery)
				TMP->( DbSkip() )
			End
			TMP->( DbCloseArea() )
		Else
			GetItemHtm("2",oHtml,lQuery)
		EndIf
	EndIf
	oProcess:Start()
	oProcess:Finish()
	If lWorkflow
		Reset Environment
	Else
		MsgInfo("Email enviado com sucesso!")
	EndIf
Return
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Roda query pra trazer os dados de envio e recebimento  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function QueryZ01(cTipo,cOrigem)
Local nReg := 0
	cSQL	:= "SELECT * FROM "+RetSqlName("Z01")
	cSQL    += " WHERE Z01_FILIAL = '"+xFilial("Z01")+"'"
	If cTipo != "D"	
		cSQL    += " AND Z01_ORIGEM = '"+cOrigem+"'"
		cSQL    += " AND Z01_OPERAC = '"+cTipo+"'"
	EndIF
	cSQL    += " AND Z01_DTENVI BETWEEN '"+DtoS(dDataBase-2)+"' AND '"+DtoS(dDataBase)+"'"
	cSQL    += " AND D_E_L_E_T_ = '' ORDER BY Z01_ARQUIV"
	cSQL    := ChangeQuery(cSQL)
	DBUSEAREA( .T.,"TOPCONN",TCGenQry(,,cSQL),'TMP',.F.,.T.)
	Count To nReg
	TMP->( DbGoTop() ) 	
	If nReg == 0
		TMP->( DbCloseArea() )
		Return(.F.)
	EndIf
Return(.T.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Monta itens das tabelas  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function GetItemHtm(cItem,oHtml,lQuery)
	If !lQuery
		AAdd((oHtml:ValByName( "C"+cItem+".1" )) , "" )
		AAdd((oHtml:ValByName( "C"+cItem+".2" )) , "" )
		AAdd((oHtml:ValByName( "C"+cItem+".3" )) , "" )
		AAdd((oHtml:ValByName( "C"+cItem+".4" )) , "" )
		AAdd((oHtml:ValByName( "C"+cItem+".5" )) , "" )
		AAdd((oHtml:ValByName( "C"+cItem+".6" )) , "" )
		AAdd((oHtml:ValByName( "C"+cItem+".7" )) , "" )
		AAdd((oHtml:ValByName( "C"+cItem+".8" )) , "" )
		AAdd((oHtml:ValByName( "C"+cItem+".9" )) , "" )
	Else
		AAdd((oHtml:ValByName( "C"+cItem+".1" )) , TMP->Z01_ARQUIV )
		AAdd((oHtml:ValByName( "C"+cItem+".2" )) , DTOC(STOD(TMP->Z01_DTENVI)) )
		AAdd((oHtml:ValByName( "C"+cItem+".3" )) , TMP->Z01_HRENVI )
		AAdd((oHtml:ValByName( "C"+cItem+".4" )) , DTOC(STOD(TMP->Z01_DTCONF)) )
		AAdd((oHtml:ValByName( "C"+cItem+".5" )) , TMP->Z01_HRCONF )
		AAdd((oHtml:ValByName( "C"+cItem+".6" )) , TMP->Z01_OPERAC )
		AAdd((oHtml:ValByName( "C"+cItem+".7" )) , TMP->Z01_ORIGEM )
		AAdd((oHtml:ValByName( "C"+cItem+".8" )) , TMP->Z01_DESTIN )
		AAdd((oHtml:ValByName( "C"+cItem+".9" )) , GetImage(TMP->Z01_STATUS) )
	EndIf
Return
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Pega conteúdo e preenche no HTML  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function GetImage(cParam)
Local cImagem := ""
Local cDirImg := AllTrim(GetMv("MV_WFDIRIM",,"http://www.gamaitaly.com.br/ti/"))
If cParam == "T"
	cImagem := "<img src='"+cDirImg+"Apply.png'>"
Else
	cImagem := "<img src='"+cDirImg+"Delete.png'>"
EndIf
Return(cImagem)