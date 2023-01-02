#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "TOTVS.ch"
#Include "TBICONN.ch"


//Variáveis Estáticas
Static cTitulo := "Documento p/Inventário Cíclico"

/*
Função para Cadastro Documento de Inventário
@author Ricky Moraes
@since 16/06/20
@version 1.0
	u_ZTICICLI()
*/
User Function ZTICICLI()
	Local aArea   := GetArea()
	Local oBrowse
	Local cFunBkp:=FunName()

	setFunName("ZTICICLI")


	//Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()

	//Setando a tabela de cadastro de Autor/Interprete
	oBrowse:SetAlias("ZTI")
	//Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)

	//Legendas
	oBrowse:AddLegend( "EMPTY(ZTI->ZTI_STATUS) .OR.(ZTI->ZTI_STATUS)=='0' ", "BR_BRANCO",	"Pendente" )
	oBrowse:AddLegend( "(ZTI->ZTI_STATUS)=='1'", "BR_AMARELO",	"Processando" )
	oBrowse:AddLegend( "(ZTI->ZTI_STATUS)=='2'", "BR_AZUL",	"Finalizada" )
	oBrowse:AddLegend( "(ZTI->ZTI_STATUS)=='3'", "BR_PRETO",	"Cancelado/Reprovado" )

	//Ativa a Browse
	oBrowse:Activate()

	setFunName(cFunBkp)
	RestArea(aArea)
Return Nil
/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Ricky Moraes                                                 |
 | Data:  15/06/20                                                     |
 | Desc:  Criação do menu MVC                                          |
 | Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function MenuDef()
	
	Local aRot := {}

	//Adicionando opções
	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.ZTICICLI' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Legenda'    ACTION 'u_ZTILeg'     	OPERATION 6                	     ACCESS 0 //OPERATION X
	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.ZTICICLI' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.ZTICICLI' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	//ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.zMVCMd1' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
	ADD OPTION aRot TITLE "Gerar Doc.Auto"    		ACTION "U_fListArmzEnd()"    OPERATION 6 ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE "Imprimir Lista Doc."   	ACTION "U_XRELCICL()"    OPERATION 6 ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE "Imprimir Status Inv."    ACTION "U_XRCICLI2()"    OPERATION 6 ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE "Imprimir Acuracy"    ACTION "U_XRELINDICA()"    OPERATION 6 ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE "Imprimir SLOW"   		ACTION "U_XRELSLOW()"    OPERATION 6 ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE "Imprimir ABC"   		ACTION "U_XRELABC()"    OPERATION 6 ACCESS 0 //OPERATION 3
	
	 
	


Return aRot
/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Ricky Moraes                                                 |
 | Data:  19/06/2020                                                   |
 | Desc:  Criação do modelo de dados MVC                               |
 | Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function ModelDef()
	
	Local oModel         := Nil
	Local oStPai         := FWFormStruct(1, 'ZTI')
	Local oStFilho     := FWFormStruct(1, 'ZTF')
	Local bLinePre := {|oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| linePreGrid(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)}
	//Local bPre := {|oFieldModel, cAction, cIDField, xValue| validPre(oFieldModel, cAction, cIDField, xValue)}
	

	oStFilho:SetProperty('ZTF_ITEM',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                                                       //Campo Obrigatório
	oStFilho:SetProperty('ZTF_ITEM', MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'u_zIniZTF()'))                         //Ini Padrão

	//Criando o modelo e os relacionamentos
	oModel := MPFormModel():New('zMVCZTI',  /*bPre*/, /*bPost*/, { |oModel|fSave(oModel)}/*bCommit*/, /*bCancel*/)

	oModel:AddFields('ZTIMASTER',/*cOwner*/,oStPai)
	oModel:AddGrid('ZTFDETAIL','ZTIMASTER',oStFilho, bLinePre/*bLinePre*/,{|oGrid| fLinOK(oGrid)},/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence


	oModel:SetRelation( 'ZTFDETAIL', { { 'ZTF_FILIAL', 'xFilial( "ZTF" )' }, { 'ZTF_DOC', 'ZTI_DOC' } }, ZTF->( IndexKey( 1 ) ) )

	oModel:SetPrimaryKey({})

	//Setando as descrições
	oModel:SetDescription("Cadastro manual de itens p/ Inventário")
	//oModel:GetModel('ZTIMASTER'):SetDescription('Cabecalho')
	oModel:GetModel('ZTFDETAIL'):SetDescription('Itens')

	//oModel:GetModel('ZTFDETAIL'):SetUseOldGrid( .T. )

	//SetKey(VK_F4, { || U_fSaldoProd()  })

Return oModel

/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Ricky Moraes                                                 |
 | Data:  07/01/2021                                                   |
 | Desc:  Criação da visão MVC                                         |
*---------------------------------------------------------------------*/

Static Function ViewDef()
	Local oView        := Nil
	Local oModel        := FWLoadModel('ZTICICLI')
	Local oStPai        := FWFormStruct(2, 'ZTI')
	Local oStFilho    	:= FWFormStruct(2, 'ZTF')
	Local nAtual,cCampoAux
	Local aStFilho    := ZTF->(DbStruct())


	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField('VIEW_ZTI',oStPai,'ZTIMASTER')
	oView:AddGrid('VIEW_ZTF',oStFilho,'ZTFDETAIL')

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC',30)
	oView:CreateHorizontalBox('GRID',70)

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_ZTI','CABEC')
	oView:SetOwnerView('VIEW_ZTF','GRID')

	//Habilitando título
	oView:EnableTitleView('VIEW_ZTI','Cabeçalho')
	oView:EnableTitleView('VIEW_ZTF','Itens')

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

	//criando botao
	//oView:AddUserButton( 'Inclui por BOM', 'CLIPS', {|oView| sfCarregaBom(oModel,oView)} )



	//Remove os campos 
	//oStFilho:RemoveField('ZTF_NUMSF')
	//oStFilho:RemoveField('ZZ3_CODCD')

	_cCamposFilho:= "ZTF_ITEM,ZTF_COD,ZTF_UM,ZTF_DESCRI,ZTF_LOCAL,ZTF_LOCALI,ZTF_QUANT,ZTF_STATUS  "


	//Tratativa para remover campos da visualização
	For nAtual := 1 To Len(aStFilho)
		cCampoAux:= Alltrim(aStFilho[nAtual][01])


		//Se o campo atual não estiver nos que forem considerados
		If !Alltrim(cCampoAux) $ Alltrim(_cCamposFilho)
			oStFilho:RemoveField(cCampoAux)
		EndIf
	Next
	
Return oView


//Iniciar automaticamente numero item
User Function zIniZTF()

	Local aArea := GetArea()
	Local cCod  //:= StrTran(Space(TamSX3('ZTF_ITEM')[1]), ' ', '0')
	Local oModelPad  := FWModelActive()
	Local oModelGrid := oModelPad:GetModel('ZTFDETAIL')
	// Local nOperacao  := oModelPad:nOperation
	Local nLinAtu    := oModelGrid:nLine+1
	// Local nPosCod    := aScan(oModelGrid:aHeader, {|x| AllTrim(x[2]) == AllTrim("ZTF_ITEM")})

	//Se for a primeira linha
	If nLinAtu < 1
		//cCod := Soma1(cCod)
		cCod := STRZERO(nLinAtu,3)
		//Senão, pega o valor da última linha
	Else
		//cCod := oModelGrid:aCols[nLinAtu][nPosCod]
		//cCod := Soma1(cCod)
		cCod := STRZERO(nLinAtu,3)

	EndIf

	RestArea(aArea)
Return cCod

//Legenda
User Function ZTILeg()

	Local aLegenda := {}

	aAdd(aLegenda, {"BR_BRANCO", "Aguardando" })
	aAdd(aLegenda, {"BR_AMARELO", "Processado" })
	aAdd(aLegenda, {"BR_AZUL", "Finalizado" })

	aAdd(aLegenda, {"BR_PRETO", "Inutilizado" })

	brwLegenda("Status", "Legenda", aLegenda)
Return

// Salvar formulario
Static Function fSave(oModel)

	Local lRet := .T.
	Local nOpc := oModel:GetOperation()
	Local oGrid := oModel:GetModel("ZTFDETAIL")

	lRet := FWFormCommit( oModel /**/,;
		/*[ bBefore ]*/,;
		/*[ bAfter ]*/,;
		/*[ bAfterSTTS ]*/,;
		/**/,;
		/*[ bABeforeTTS ]*/,;
		/* */ )

Return(lRet)


Static Function linePreGrid(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)
Local oModel := FwModelActive()
Local cEnd,cLocal
Local lRet := .T.
Local cLocaliz
 	
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		cStatus :=oGridModel:GetValue("ZTF_STATUS")
		IF cStatus<>'0'
			lRet := .F.
 			Help(NIL, NIL, "Contagem", NIL, "Já esta Processada !", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Alteração,bloqueada para itens já processados!"})			
		ENDIF
		
	endif

	
	If cAction == "SETVALUE" .and. lRet
	cLocaliz := Posicione("SB1",1,XFILIAL("SB1")+oGridModel:GetValue("ZTF_COD"),"B1_LOCALIZ")
    cEnd := oGridModel:GetValue("ZTF_LOCALI")
    cLocal:= oGridModel:GetValue("ZTF_LOCAL")
		if cLocaliz=="S"
			If  Posicione("SBE",1,XFILIAL("SBE")+cLocal+cEnd,"BE_LOCALIZ")<>cEnd
			Help(NIL, NIL, "Endereço", NIL, "Endereço não encontrado !", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o Local e Endereço."})			
		    lRet := .F.        
			EndIf
		else
			oGridModel:LoadValue('ZTF_LOCALI', ' ' )			
		EndIf
	Endif
	
Return lRet


Static Function fLinOK(oGrid)

	Local lRet :=.T.
	Local oModel := FwModelActive()
	Local cEnd,cLocal
	Local cLocaliz
	Local cStatus

	oGrid:GoLine(oGrid:nLine)

	cLocaliz := Posicione("SB1",1,XFILIAL("SB1")+oGrid:GetValue("ZTF_COD"),"B1_LOCALIZ")
	cEnd := oGrid:GetValue("ZTF_LOCALI")
	cLocal:= oGrid:GetValue("ZTF_LOCAL")


	If cLocaliz=="S"		
		If  Posicione("SBE",1,XFILIAL("SBE")+cLocal+cEnd,"BE_LOCALIZ")<>cEnd  .or. Empty(cEnd)
			lRet := .F.
			oGrid:GetModel():SetErrorMessage('ZTFDETAIL', 'ZTF_LOCALI' , 'ZTFDETAIL' , 'ZTF_LOCALI' , 'Erro', 'Endereço : '+ cEnd+ 'não localizado no Armazém : '+cLocal , '')
		EndIf
	else
		IF !EMPTY(cEnd )
		 lRet:=.F.
		 oGrid:GetModel():SetErrorMessage('ZTFDETAIL', 'ZTF_LOCALI' , 'ZTFDETAIL' , 'ZTF_LOCALI' , 'Erro', 'Produto não controla Endereço!' , 'Limpar campo Endereço')
		Endif		 
	EndIf


	//Local _cMovEst:= oModel:GetValue('ZTIMASTER','ZTI_MOVEST')

	/*
	If Empty(oGrid:GetValue('ZTF_DESC'))
        Help(,,'Descrição em Branco',,'',1,0,,,,,,{'Por favor, Preencher o campo corretamente.'})
        Return .F.
	Endif
	*/
Return lRet


Static Function fRepZTI()

	Local oError := ErrorBlock({|e|ChecErro(e)}) //Para exibir um erro mais amigável
	Local cRetorno := ""
	IF !ZTI->ZTI_STATUS $ ("4-5")

		If MsgYesNo("Excluir / Reprovar documento ?", "Inventário Ciclíco" )
			cRetorno := FWInputBox("Informe o Motivo", "")
			ErrorBlock(oError)
			//	Processa({||AltStatus("5",cRetorno)},"Inventário Ciclíco" ,"Processando Documento, aguarde...")
		ENDIF
	ELSE
		ALERT("Não é possível reprovar/cancelar documento já processado !")
	ENDIF
Return(.T.)




User Function fVldPrdEnd(cProd)

	Local lResp:=.F.
	Local oModel,oGrid
	if !empty(cProd)
		if  Posicione("SB1",1,xFilial("SB1")+cProd,"B1_LOCALIZ")=="S"
			lResp:=.T.
		Endif
	else
		if FunName() == "ZTICICLI"
			oModel := FwModelActive()
			oGrid := oModel:GetModel("ZTFDETAIL")
			oGrid:GoLine(oGrid:nLine)
			cProd:=oGrid:GetValue("ZTF_COD")		
		Else
			cProd:=SB1->B1_COD
		ENDIF
		if  Posicione("SB1",1,xFilial("SB1")+cProd,"B1_LOCALIZ")=="S"
			lResp:=.T.
		Endif
	endif

Return(lResp)


User Function fListArmzEnd()

	Local cArmz:=Space(2)
	Local cEndIni:=Space(15)
	Local cEndFim:=Space(15)
	Local cTipoIni:=space(2)
	Local cTipoFim:=space(2)
	Local cUltDias :='120'
	Local aRet 		:= {}
	Local aParamBox	:= {}
	Local cProdDe	:= space(15)
	Local cProdAte	:= space(15)
	//Local aCombo := {"Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}
	Local aABC := {"Todos","A","B","C"}
	Local aNivel := {"Todos","A","B","C","D","E"}
	Local aMoving := {"Todos","Hight","Slow"}
	Local aOrder := {"Endereco","Rua","Nivel","Codigo","Classe","Moving"}
	//Local i := 0
	Private cCadastro := "Contagem Cíclica"

	cProdDe := space(TamSX3("B1_COD")[1])
	cProdAte:= REPLICATE("Z",TAMSX3("B1_COD")[1])
	cEndIni := space(TamSX3("BF_LOCALIZ")[1])
	cEndFim:= REPLICATE("Z",TAMSX3("BF_LOCALIZ")[1])
	cTipoIni := space(TamSX3("B1_UM")[1])
	cTipoFim:= REPLICATE("Z",TAMSX3("B1_UM")[1])


	aAdd(aParamBox,{01,"Armazem"	            ,cArmz		,"@E 99"    ,"","NNR"	,"", 30,.T.})	// MV_PAR01
	aAdd(aParamBox,{01,"Produto de"	  			,cProdDe 	,""		    ,"","SB1"	,"", 80,.F.})	// MV_PAR02
	aAdd(aParamBox,{01,"Produto ate"	   		,cProdAte	,""		    ,"","SB1"	,"", 80,.T.})	// MV_PAR03
	aAdd(aParamBox,{01,"Tipo de"	            ,cTipoini	,"@!"       ,"","02"	,"", 30,.F.})	// MV_PAR04
	aAdd(aParamBox,{01,"Tipo ate"	            ,cTipofim	,"@!"       ,"","02"	,"", 30,.T.})	// MV_PAR05
	aAdd(aParamBox,{01,"Endereco de"	        ,cEndIni	,"@!"	    ,"","SBE"	,"", 80,.F.})	// MV_PAR06
	aAdd(aParamBox,{01,"Endereco ate"	        ,cEndFim	,"@!"       ,"","SBE"	,"", 80,.T.})	// MV_PAR07
	aAdd(aParamBox,{01,"Ñ.dias Invent."	   		,cUltDias	,"@E 999"   ,"",""  	,"", 30,.T.})	// MV_PAR08
	aAdd(aParamBox,{02,"Classe ABC"	 			,0,aABC	,60,"",.T.})	// MV_PAR09
	aAdd(aParamBox,{02,"Moving"	   				,0,aMoving,60,"",.T.})	// MV_PAR10
	aAdd(aParamBox,{02,"Ordenar por"   				,0,aOrder,60,"",.T.})	// MV_PAR11
	aAdd(aParamBox,{02,"Nivel"	 			,0,aNivel	,60,"",.T.})	// MV_PAR12


	// Parametros da função Parambox()
	//http://www.blacktdn.com.br/2012/05/para-quem-precisar-desenvolver-uma.html
	// -------------------------------
	// 1 - < aParametros > - Vetor com as configurações
	// 2 - < cTitle >      - Título da janela
	// 3 - < aRet >        - Vetor passador por referencia que contém o retorno dos parâmetros
	// 4 - < bOk >         - Code block para validar o botão Ok
	// 5 - < aButtons >    - Vetor com mais botões além dos botões de Ok e Cancel
	// 6 - < lCentered >   - Centralizar a janela
	// 7 - < nPosX >       - Se não centralizar janela coordenada X para início
	// 8 - < nPosY >       - Se não centralizar janela coordenada Y para início
	// 9 - < oDlgWizard >  - Utiliza o objeto da janela ativa
	//10 - < cLoad >       - Nome do perfil se caso for carregar
	//11 - < lCanSave >    - Salvar os dados informados nos parâmetros por perfil
	//12 - < lUserSave >   - Configuração por usuário

	// Caso alguns parâmetros para a função não seja passada será considerado DEFAULT as seguintes abaixo:
	// DEFAULT bOk   := {|| (.T.)}
	// DEFAULT aButtons := {}
	// DEFAULT lCentered := .T.
	// DEFAULT nPosX  := 0
	// DEFAULT nPosY  := 0
	// DEFAULT cLoad     := ProcName(1)
	// DEFAULT lCanSave := .T.
	// DEFAULT lUserSave := .F.

	// IF ParamBox(aParamBox,"Gerar Lista Cíclica ( Armzem/Endereço )",@aRet/*aRet*/,/*bOk*/,/*aButtons*/,.T.,,,,FUNNAME(),.T.,.F.)
	If ParamBox(aParamBox,"Lista por ( Armazém/Endereço )",@aRet)
		Processa({||Seleclista()},"Inventário Ciclíco" ,"Carregando lista, aguarde...")
	Endif



Return


Static Function Seleclista()
	Local _stru:={}
	Local aCpoBro := {}
	Local oDlgLocal
	Local oPanel
	Local aCores := {}
	Local aArea   := GetArea()
	Local cQuery    := ''
	Local cAliasQry := GetNextAlias()
	Local nRecCount:=0
	Local nTamBtn := 60
	Local cOrder :=',ENDERECO,RUA,NIVEL,CLASSE,CODIGO,MOVING'

	cOrder := StrTran( cOrder,','+UPPER(MV_PAR11) )
	cOrder := ALLTRIM(UPPER(MV_PAR11)+','+ cOrder)
	cOrder :=StrTran( cOrder,',,', ',' )

	//Tamanho da janela
	Private nJanLarg := 1100
	Private nJanAltu := 0500


	Private lInverte := .F.
	Private cMark   := GetMark()
	Private oMark //Cria um arquivo de Apoio

	AADD(_stru,{"OK"     	,"C"	,2		,0		})
	AADD(_stru,{"CODIGO"    ,"C"	,15		,0		})
	AADD(_stru,{"DESCRICAO" ,"C"	,60		,0		})
	AADD(_stru,{"UM"   		,"C"	,2		,0		})
	AADD(_stru,{"TIPO"   	,"C"	,2		,0		})
	AADD(_stru,{"ARMZ"		,"C"	,2		,2		})
	AADD(_stru,{"RUA"  		,"C"	,5		,0		})
	AADD(_stru,{"NIVEL"  	,"C"	,5		,0		})
	AADD(_stru,{"ENDERECO"  ,"C"	,15		,0		})
	AADD(_stru,{"SALDOBF" 	,"N"	,15		,4		})
	AADD(_stru,{"UDTCICLI" 	,"D"	,10		,0		})
	AADD(_stru,{"DIAS" 		,"N"	,10		,0		})
	AADD(_stru,{"CLASSE"   	,"C"	,2		,0		})
	AADD(_stru,{"MOVING"   	,"C"	,5		,0		})
	AADD(_stru,{"STATUS"  	,"C"  	,2      ,0          })

	cArq:=Criatrab(_stru,.T.)

	DBUSEAREA(.t.,,carq,"TTRB")//Alimenta o arquivo de apoio com os registros temporarios

	cQuery	:= "SELECT  	*  FROM	( "
	cQuery  += "SELECT "
	cQuery	+= "	 B1_COD CODIGO, "
	cQuery	+= "	 B1_XDESCNF DESCRICAO, 	"
	cQuery  += " 	 B1_TIPO TIPO, 		"
	cQuery	+= " 	 B1_UM UM, 		"
	cQuery	+= " 	 B2_LOCAL ARMZ, 	"
	cQuery  += " 	 IIF(B1_LOCALIZ='S',	"
	cQuery	+= " 	 ISNULL(BF_LOCALIZ,''),'') AS ENDERECO,	"
	cQuery	+= " 	 IIF(B2_QATU>0 AND B1_LOCALIZ='S',	"
	cQuery  += " 	 ISNULL(BF_QUANT,0) , B2_QATU) AS SALDOBF, 	"
	cQuery	+= " 	 ISNULL(ULTDAT,'20191231') AS UDTCICLI,		"
	cQuery  += " 	 DATEDIFF(day, ISNULL(ULTDAT,'20191231'),GETDATE() ) AS DIAS,	"
	cQuery  += " 	 CLASSE,MOVING,	"
	cQuery  += " 	 	"

cQuery  += "	CASE  WHEN ISNUMERIC(SUBSTRING(BF_LOCALIZ,3,2)) <> 0"
	cQuery  += "		THEN SUBSTRING(BF_LOCALIZ,1,1)"
	cQuery  += "		WHEN SUBSTRING(BF_LOCALIZ,1,5) ='PRATG'"
	cQuery  += "		THEN 'A' WHEN SUBSTRING(BF_LOCALIZ,1,4) ='PRAT'" 
	cQuery  += "		THEN SUBSTRING(BF_LOCALIZ,5,1)"
	cQuery  += "		ELSE"
	cQuery  += "		BF_LOCALIZ"
	cQuery  += "		END AS RUA,		"

	cQuery  += "		CASE  WHEN ISNUMERIC(SUBSTRING(BF_LOCALIZ,3,2)) <> 0"
	cQuery  += "		THEN SUBSTRING(BF_LOCALIZ,5,1)"
	cQuery  += "		ELSE  "
	cQuery  += "		'' "
	cQuery  += "		END AS NIVEL		"
	
	cQuery	+= "FROM SB1010 SB1 	"
	cQuery  += " 	 INNER JOIN SB2010 SB2 ON B2_COD=B1_COD 	"
	cQuery	+= " 		AND B2_FILIAL='01' 			"
	cQuery	+= " 		AND SB2.D_E_L_E_T_=''			"
	cQuery  += " 		AND B2_QATU>0				"
	cQuery	+= " 		AND SB1.D_E_L_E_T_='' 			"
	cQuery	+= " 		AND B1_MSBLQL='2' 			"
	cQuery  += " 	 LEFT JOIN SBF010 SBF ON B1_COD=BF_PRODUTO	"
	cQuery	+= " 		 AND SBF.D_E_L_E_T_='' 			"
	cQuery	+= " 		 AND BF_FILIAL=B2_FILIAL AND BF_LOCAL=B2_LOCAL	"
	cQuery  += " 	LEFT JOIN (					"
	cQuery	+= " 	SELECT MAX(ZTF_DATA) ULTDAT,ZTF_FILIAL,ZTF_COD,ZTF_LOCAL,ZTF_LOCALI FROM ZTF010 ZTF	"
	cQuery	+= " 	WHERE ZTF.D_E_L_E_T_='' 								"
	cQuery  += " 	GROUP BY ZTF_FILIAL,ZTF_COD,ZTF_LOCAL,ZTF_LOCALI					"
	cQuery	+= " 	) ZTF ON ZTF_FILIAL=B2_FILIAL 								"
	cQuery	+= " 			AND ZTF_COD=B1_COD							"
	cQuery  += " 			AND ZTF_LOCAL=B2_LOCAL							"
	cQuery	+= " 			AND ZTF_LOCALI = ISNULL(BF_LOCALIZ,'')					"
	cQuery	+= "	LEFT JOIN										 "
	cQuery	+= "	 (SELECT B1_COD CODABC,CLASSE FROM TEMP_ABC)ABC ON CODABC=B1_COD			 "
	cQuery	+= "	LEFT JOIN 										"
	cQuery	+= "	 (SELECT B1_COD CODSLOW,POSICAO,MOVING FROM TEMP_SLOW)SLOW ON CODSLOW=B1_COD		 "
	cQuery	+= "  WHERE 											"
	cQuery  += " 	B2_LOCAL ='"+MV_PAR01+"'"
	cQuery	+= " 	AND B1_COD  BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"'"
	cQuery	+= " 	AND B1_TIPO BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"'"
	cQuery  += " 	)TEMP											"
	cQuery	+= "  WHERE 											"
	cQuery	+= " 	ENDERECO BETWEEN '"+MV_PAR06+"' AND '"+MV_PAR07+"'"
	cQuery  += " 	AND DIAS >= "+MV_PAR08
	IF UPPER(MV_PAR09)<>'TODOS'
		cQuery 	+= "	AND CLASSE = '"+UPPER(alltrim(MV_PAR09))+"'"
	endif
	IF UPPER(MV_PAR10)<>'TODOS'
		cQuery 	+= "	AND MOVING = '"+UPPER(alltrim(MV_PAR10))+"'"
	endif
	IF UPPER(MV_PAR12)<>'TODOS'
		cQuery 	+= "	AND NIVEL = '"+UPPER(alltrim(MV_PAR12))+"'"
	endif
	cQuery	+= " ORDER BY " + cOrder

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .T., .F.)

	TCSetField(cAliasQry,'UDTCICLI','D',8,0)


	dbSelectArea(cAliasQry)
	//Conta total e registros
	Count To nRecCount

	ProcRegua(nRecCount)
	IF nRecCount>0
		dbGotop()
		While !(cAliasQry)->(EoF())
			IncProc()
			DbSelectArea("TTRB")
			RecLock("TTRB",.T.)
			TTRB->OK     	:=  "OK"
			TTRB->CODIGO     	:=  (cAliasQry)->CODIGO
			TTRB->DESCRICAO	:=  (cAliasQry)->DESCRICAO
			TTRB->UM    	:=  (cAliasQry)->UM
			TTRB->TIPO    	:=  (cAliasQry)->TIPO
			TTRB->ARMZ 	    :=  (cAliasQry)->ARMZ
			TTRB->RUA 	    :=  (cAliasQry)->RUA
			TTRB->NIVEL	    :=  (cAliasQry)->NIVEL
			TTRB->ENDERECO	:=  (cAliasQry)->ENDERECO
			TTRB->SALDOBF	:=  (cAliasQry)->SALDOBF
			//TTRB->UDTCICLI	:=  (cAliasQry)->UDTCICLI
			TTRB->DIAS		:=  (cAliasQry)->DIAS
			TTRB->CLASSE	:=  (cAliasQry)->CLASSE
			TTRB->MOVING	:=  (cAliasQry)->MOVING
			TTRB->STATUS  := "0"    //Verde
			MsunLock()

			(cAliasQry)->(DbSkip())

		Enddo
	ELSE
		Alert("Não foi encontrado nenhum registro !")
	endif

	(cAliasQry)->(dbCloseArea())

	RestArea(aArea)

	//Define as cores dos itens de legenda.
	aCores := {}
	aAdd(aCores,{"TTRB->STATUS == '0'","BR_VERDE"	})
	aAdd(aCores,{"TTRB->STATUS == '1'","BR_AMARELO"	})
	aAdd(aCores,{"TTRB->STATUS == '2'","BR_VERMELHO"})

	//Define quais colunas (campos da TTRB) serao exibidas na
	aCpoBro	:=  {{ "OK"	,, "Mark"           ,"@!"},;
		{ "CODIGO"			,, "Codigo"         ,"@!"},;
		{ "DESCRICAO"	,, "Descrição"           ,"@!"},;
		{ "UM"			,, "Und."           ,"@!"},;
		{ "TIPO"		,, "Tipo"           ,"@!"},;
		{ "ARMZ"		,, "Armz."   ,"@!"},;
		{ "RUA"		,, "Rua"   ,"@!"},;
		{ "NIVEL"		,, "Nivel"   ,"@!"},;
		{ "ENDERECO"	,, "Endereco"       ,"@!"},;
		{ "SALDOBF"		,, "Saldo"   ,"@E 999,999,999.99"},;
		{ "CLASSE"		,, "Classe"           ,"@!"},;
		{ "MOVING"		,, "Moving"           ,"@!"},;
		{ "DIAS"		,, "Ult.Cicli"   ,"@E 99999"}}


	//Cria uma Dialog
	DEFINE MSDIALOG oDlg TITLE "Produtos p/ Inventário" FROM 000,000 TO nJanAltu, nJanLarg  PIXEL //COLORS 0, 16777215
	//Ações
	@ 003, 003 GROUP oGrpAcoes TO 030, (nJanLarg/2)-2  PROMPT "Ações: "	OF oDlg COLOR 0, 16777215 PIXEL
	@ 010, (nJanLarg/2)-((nTamBtn*9)+03) BUTTON oBtnConf PROMPT "Marcar" SIZE nTamBtn, 015 OF oDlg ACTION(fMarcar())     PIXEL
	@ 010, (nJanLarg/2)-((nTamBtn*8)) BUTTON oBtnConf PROMPT "Desmarcar" SIZE nTamBtn, 015 OF oDlg ACTION(fDesmarcar())     PIXEL
	@ 010, (nJanLarg/2)-((nTamBtn*7)-4) BUTTON oBtnConf PROMPT "Exp. Excel" SIZE nTamBtn, 015 OF oDlg ACTION(fExpExc())     PIXEL
	//@ (nJanAltu/2)-19, (nJanLarg/2)-((nTamBtn*3)+12) BUTTON oBtnCanc PROMPT "Cancelar" SIZE nTamBtn, 013 OF oDlg ACTION(fCancela())     PIXEL
	@ 010, (nJanLarg/2)-((nTamBtn*2)+09) BUTTON oBtnLimp PROMPT "Cancelar" SIZE nTamBtn, 015 OF oDlg ACTION(oDlg:End())     PIXEL
	@ 010, (nJanLarg/2)-((nTamBtn*1)+06) BUTTON oBtnConf PROMPT "Confirmar" SIZE nTamBtn, 015 OF oDlg ACTION(fGerLista())     PIXEL


	//Dados
	@ 035, 003 GROUP oGrpDados TO (nJanAltu/2)-10, (nJanLarg/2)-3 PROMPT "Dados p/ o documento"	OF oDlg COLOR 0, 16777215 PIXEL
	//Cria  aMsSelect
	oMark := MsSelect():New("TTRB","OK"," ",aCpoBro,@lInverte,@cMark,{ 45, 006, (nJanAltu/2)-15, (nJanLarg/2)-6 } ,,, )


	oMark:bMark := {| | Disp() }

	DbSelectArea("TTRB")
	DbGotop()

	//Exibe aDialog
	ACTIVATE MSDIALOG oDlg CENTERED

	//Fecha a Area e elimina os arquivos de apoio criados em disco.
	TTRB->(DbCloseArea())
	Iif(File(cArq + GetDBExtension()),FErase(cArq  + GetDBExtension()) ,Nil)


Return

//Funcao executada ao Marcar/Desmarcar um registro.
Static Function Disp()

	RecLock("TTRB",.F.)
	If Marked("OK")
		TTRB->OK := cMark
		//     MSGALERT(cMark, "teste")
	Else
		TTRB->OK := " "
	Endif

	MSUNLOCK()
	oMark:oBrowse:Refresh()
Return()

Static Function fMarcar()
	dbSelectArea( "TTRB" )
	dbGotop()
	Do While !EoF()
		If RecLock( "TTRB", .F. )
			TTRB->OK          := cMark
			msUnLock()
		EndIf
		dbSelectArea( "TTRB" )
		dbSkip()
	EndDo
	dbGotop()
Return

Static Function fDesmarcar()
	dbSelectArea( "TTRB" )
	dbGotop()

	Do While !EoF()
		If RecLock( "TTRB", .F. )
			TTRB->OK          := " "
			msUnLock()
		EndIf
		dbSelectArea( "TTRB" )
		dbSkip()
	EndDo
	dbGotop()
Return

/*/ Export para Excel/*/
Static Function fExpExc()
	Local lExistDir
	Local nHd
	Local oFWMsExcel
	Local cDir := "C:\Inventario"
    Local cArquivo := cDir+"\inv_ciclico.xls"  //"+SUBSTRING(Dtos(date()),5,4)+"

	lExistDir := ExistDir(cDir)

	If lExistDir 
		If file(cArquivo)
			fErase(cArquivo)
		EndIf
	else
		nHd := MAKEDIR(cDir)
		If nHd <> 0
			MsgAlert("Não foi possível criar o diretório. Erro: " + cValToChar( FError() ) , 'Alerta !')
		EndIf 
	EndIf 

	

	dbSelectArea( "TTRB" )
	dbGotop()
	
		//Criando o objeto que irá gerar o conteúdo do Excel
	oFWMsExcel := FwMsExcelEx():New()
	
	oFWMsExcel:AddworkSheet("Ciclico") //Não utilizar número junto com sinal de menos. Ex.: 1-
		//Criando a Tabela
		oFWMsExcel:AddTable("Ciclico","Documento p/ Inventario Ciclico")
		//Criando Colunas
		oFWMsExcel:AddColumn("Ciclico","Documento p/ Inventario Ciclico","Codigo",1,1) 
		oFWMsExcel:AddColumn("Ciclico","Documento p/ Inventario Ciclico","Descricao",1,1)
		oFWMsExcel:AddColumn("Ciclico","Documento p/ Inventario Ciclico","Un Medida",1,1)
		oFWMsExcel:AddColumn("Ciclico","Documento p/ Inventario Ciclico","Tipo",1,1)
		oFWMsExcel:AddColumn("Ciclico","Documento p/ Inventario Ciclico","Armazen",1,1)
		oFWMsExcel:AddColumn("Ciclico","Documento p/ Inventario Ciclico","Rua",1,1)
		oFWMsExcel:AddColumn("Ciclico","Documento p/ Inventario Ciclico","Nivel",1,1)
		oFWMsExcel:AddColumn("Ciclico","Documento p/ Inventario Ciclico","Endereco",1,1)
		oFWMsExcel:AddColumn("Ciclico","Documento p/ Inventario Ciclico","Saldo",1,1)
		oFWMsExcel:AddColumn("Ciclico","Documento p/ Inventario Ciclico","Dia",1,1)
		oFWMsExcel:AddColumn("Ciclico","Documento p/ Inventario Ciclico","Classe",1,1)
		oFWMsExcel:AddColumn("Ciclico","Documento p/ Inventario Ciclico","Mov",1,1)
		oFWMsExcel:AddColumn("Ciclico","Documento p/ Inventario Ciclico","Status",1,1)
				//Criando as Linhas
		Do While !EoF()
			if TTRB->OK == cMark
				oFWMsExcel:AddRow("Ciclico","Documento p/ Inventario Ciclico",{;
					TTRB->CODIGO,;
					TTRB->DESCRICAO,;
					TTRB->UM,;
					TTRB->TIPO,;
					TTRB->ARMZ,;
					TTRB->RUA,;
					TTRB->NIVEL,;
					TTRB->ENDERECO,;
					TTRB->SALDOBF,;
					TTRB->DIAS,;
					TTRB->CLASSE,;
					TTRB->MOVING,;
					TTRB->STATUS;
				})  
			endif
			dbSelectArea( "TTRB" )
			dbSkip()
		EndDo

	oFWMsExcel:Activate()
	oFWMsExcel:GetXMLFile(cArquivo)
         
    //Abrindo o excel e abrindo o arquivo xml
   oExcel := MsExcel():New()                //Abre uma nova conexão com Excel
   oExcel:WorkBooks:Open(cArquivo)          //Abre uma planilha
   oExcel:SetVisible(.T.)                   //Visualiza a planilha                 
   oExcel:Destroy()

	// If lAchou
	// 	MsgAlert('Exportando para Excel', 'oK')
	// EndIf

Return

Static Function fGerLista()
	Local lAchou :=.F.
	Local cDoc := space(6)
	Local nItem:=0


	dbSelectArea( "TTRB" )
	dbGotop()
	Do While !EoF()
		if TTRB->OK == cMark
			//  ALERT("ACHOU")
			lAchou:=.T.
		endif
		dbSelectArea( "TTRB" )
		dbSkip()
	EndDo

	if lAchou
		DbSelectArea("ZTI")
		cDoc:=GetSx8Num("ZTI","ZTI_DOC")

		if RecLock("ZTI", .T.)
			ZTI->ZTI_FILIAL := xFilial("ZTI")
			ZTI->ZTI_DOC    := cDoc
			ZTI->ZTI_TIPO   := "A"
			ZTI->ZTI_BASE   := "A" //A = Armazem, C = Curva ABC, R = Rotacao, L = Livre
			ZTI->ZTI_DATA   := DataValida(dDataBase,.T.) //DDATABASE
			ZTI->ZTI_USUARI := SUBSTR(USRFULLNAME(__CUSERID),1,30)
			ZTI-> ZTI_STATUS:= "0"
			ZTI->(msUnlock())
			ZTI->(dbclosearea())
			ConfirmSx8()
			dbSelectArea( "TTRB" )
			dbGotop()
			Do While !EoF()
				if TTRB->OK == cMark
					IF RecLock("ZTF", .T.)
						nItem:= nItem+1
						ZTF->ZTF_FILIAL :=xFilial("ZTF")
						ZTF->ZTF_DOC    := cDoc
						ZTF->ZTF_ITEM   := StrZero((nItem),3)
						ZTF->ZTF_COD    := TTRB->CODIGO
						ZTF->ZTF_DESCRI := TTRB->DESCRICAO
						ZTF->ZTF_UM     := TTRB->UM
						ZTF->ZTF_QUANT  :=0
						ZTF->ZTF_LOCAL  :=TTRB->ARMZ
						ZTF->ZTF_LOCALI := TTRB->ENDERECO
						ZTF->ZTF_SLDSBF := TTRB->SALDOBF
						ZTF->ZTF_USUARI :=SUBSTR(USRFULLNAME(__CUSERID),1,30)
						ZTF->ZTF_DATA   := DDATABASE
						ZTF->ZTF_HORA   :=TIME()
						ZTF->ZTF_STATUS := "0" //0=Aguardando_Contagem;1=Processado;2=Ajustado;3=Desconsiderar;
							ZTF->(msUnlock())
						ZTF->(dbclosearea())
					ENDIF

				endif
				dbSelectArea( "TTRB" )
				dbSkip()
			EndDo
			//MsgInfo("Documento criado com sucesso ! Doc : "+cDoc ,"Inventário Cíclico")
			U_MsgTimer ("Inventário Cíclico, Documento : " + cDoc + " foi criado com sucesso.")
		endif
	ENDIF


	oDlg:End()
Return




