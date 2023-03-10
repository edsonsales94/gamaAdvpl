#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//Vari疱eis Est疸icas
Static cTitulo := "Or軋mentos de compras por departamento"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		BRAMNT02                                                     /@
@type	  		User Function                                                /@
@date			21/10/2021                                                   /@
@description	Cadastramento de limites de compras de aprovadores por m黌
				de acordo com budget anual.
				Atualiza鈬o do cadastro de aprovador (SAK) ser? realizada de
				forma autom疸ica pela rotina schedule BRAJOB?? todo dia 1o 
				as 0h 							                             /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
                Op鈬o Um Tecnologia da Informa鈬o (www.opcaoum.com.br)       /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
//WHEN (Left(dTOs(Date()),6) < M->ZZB_ANO + "01")  
//X3_RELACAO GetAdvFVal("SAK", "AK_NOME", xFilial("SAK") + ZZB->ZZB_APROV, 1)
//                              AK_TIPO
//                              AK_MOEDA

User Function BRAMNT02()
Local aArea   := GetArea()
Local oBrowse
    
//Cria um browse para a ZZB
oBrowse := FWMBrowse():New()
oBrowse:SetAlias("ZZB")
oBrowse:SetDescription(cTitulo)
oBrowse:Activate()
    
RestArea(aArea)
Return Nil
 
/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		MENUDEF                                                      /@
@type			Static Function                                              /@
@date			21/10/2021                                                   /@
@description	Cria鈬o do menu MVC                                          /@
@author			Adalberto Moreno Batista (Op鈬o Um)                          /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function MenuDef()
Local aRot := {}

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?    
// Adicionando op鋏es
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.BRAMNT02' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.BRAMNT02' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.BRAMNT02' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.BRAMNT02' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
Return aRot

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		MODELDEF                                                     /@
@type			Static Function                                              /@
@date			21/10/2021                                                   /@
@description	Cria鈬o do modelo de dados MVC                               /@
@author			Adalberto Moreno Batista (Op鈬o Um)                          /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function ModelDef()
Local oModel    := NIL
Local oStruCab  := FWFormStruct(1, 'ZZB', {|cCampo| AllTRim(cCampo) $ "ZZB_ANO"})
Local oStruGrid := fModStruct()
Local bPosValid     := {|oModel| fValidGrid(oModel)}
Local bValidLine    := {|| fValidLine(oModel)}

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Monta o modelo de dados, e na P?s Valida鈬o, informa a fun鈬o fValidGrid
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
oModel := MPFormModel():New('BRMNT02M', /*bPreValid*/, bPosValid, /*bCommit*/, /*bCancel*/ )

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Define no modelo de dados, que ter? um Cabe軋lho e uma Grid apontando para 
// estruturas acima
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
oModel:AddFields('MdFieldZZB', NIL, oStruCab)
oModel:AddGrid('MdGridZZB', 'MdFieldZZB', oStruGrid, , )

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Monta o relacionamento entre Grid e Cabe軋lho, as express?es da esquerda 
// representam o campo da Grid e da direita do Cabe軋lho
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
oModel:SetRelation('MdGridZZB', {;
                                {'ZZB_FILIAL', 'xFilial("ZZB")'},;
                                {"ZZB_ANO",  "ZZB_ANO"};
                                }, ZZB->(IndexKey(1)))

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?   
// Definindo outras informa鋏es do Modelo e da Grid
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
oModel:GetModel("MdGridZZB"):SetMaxLine(9999)
oModel:SetDescription(cTitulo)
oModel:SetPrimaryKey({"ZZB_FILIAL", "ZZB_ANO", "ZZB_APROV"})
oModel:GetModel('MdGridZZB'):SetLPost(bValidLine)

oStruCab:SetProperty('ZZB_ANO',  MODEL_FIELD_OBRIGAT, .T.)

Return oModel


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		VIEWDEF                                                      /@
@type			Static Function                                              /@
@date			21/10/2021                                                   /@
@description	Cria鈬o da vis縊 MVC                                         /@
@author			Adalberto Moreno Batista (Op鈬o Um)                          /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/ 
Static Function ViewDef()
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Na montagem da estrutura da visualiza鈬o de dados, vamos chamar o modelo 
// criado anteriormente, no cabe軋lho vamos mostrar somente 1 campo, e na grid
// vamos carregar conforme a fun鈬o fViewStruct
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
Local oView        := NIL
Local oModel    := FWLoadModel('BRAMNT02')
Local oStruCab  := FWFormStruct(2, "ZZB", {|cCampo| AllTRim(cCampo) $ "ZZB_ANO"})
Local oStruGRID := fViewStruct()

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Define que no cabe軋lho n縊 ter? separa鈬o de abas (SXA)
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
oStruCab:SetNoFolder()

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Cria o View
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
oView:= FWFormView():New() 
oView:SetModel(oModel)              

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Cria uma 疵ea de Field vinculando a estrutura do cabe軋lho com MDFieldZZB, e 
// uma Grid vinculando com MdGridZZB
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
oView:AddField('VIEW_ZZB', oStruCab, 'MdFieldZZB')
oView:AddGrid ('GRID_ZZB', oStruGRID, 'MdGridZZB' )

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// O cabe軋lho (MAIN) ter? 25% de tamanho, e o restante de 75% ir? para a GRID
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
oView:CreateHorizontalBox("MAIN", 15)
oView:CreateHorizontalBox("GRID", 85)

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Vincula o MAIN com a VIEW_ZZB e a GRID com a GRID_ZZB
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
oView:SetOwnerView('VIEW_ZZB', 'MAIN')
oView:SetOwnerView('GRID_ZZB', 'GRID')
oView:EnableControlBar(.T.)

//Define o campo incremental da grid como o ZZB_ITEM
//oView:AddIncrementField('GRID_ZZB', 'ZZB_ITEM')

Return oView
 
/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		fModStruct                                                   /@
@type			Static Function                                              /@
@date			21/10/2021                                                   /@
@description	Monta o modelo de dados da Grid                              /@
@author			Adalberto Moreno Batista (Op鈬o Um)                          /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function fModStruct()
Local oStruct
oStruct := FWFormStruct(1, 'ZZB')
Return oStruct

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		fModStruct                                                   /@
@type			Static Function                                              /@
@date			21/10/2021                                                   /@
@description	Monta a visualiza鈬o de dados da Grid                        /@
@author			Adalberto Moreno Batista (Op鈬o Um)                          /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function fViewStruct()
Local oStruct

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Ir? filtrar, e trazer todos os campos, menos "ZZB_ANO;"
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
oStruct := FWFormStruct(2, "ZZB", {|cCampo| !(Alltrim(cCampo) $ "ZZB_ANO;")})
Return oStruct

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		fValidGrid                                                   /@
@type			Static Function                                              /@
@date			21/10/2021                                                   /@
@description	Valida a Grid no momento da confirma鈬o (tudook)             /@
@author			Adalberto Moreno Batista (Op鈬o Um)                          /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function fValidGrid(oModel)
Local lRet          := .T.
Local nDeletados    := 0
Local nLinAtivo     := 0
Local oModelGRID    := oModel:GetModel('MdGridZZB')
Local oModelMain    := oModel:GetModel('MdFieldZZB')
Local cAno          := oModelMain:GetValue("ZZB_ANO")

if Empty(cAno) .or. cAno <= "2019" .or. cAno >= "2050"
    lRet := .F.
    Help(,, "ｮ ATENﾇﾃO",, "O ano deve estar compreendido entre 2020 e 2049!" + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
endif 

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Percorre todos os itens da grid
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
For nLinAtivo := 1 To oModelGRID:Length()
    //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
    // Posiciona na linha
    //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
    oModelGRID:GoLine(nLinAtivo) 
    
    //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
    // Se a linha for excluida, incrementa a vari疱el de deletados, sen縊 ir? 
    // incrementar o valor digitado em um campo na grid
    //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
    If oModelGRID:IsDeleted()
        nDeletados++
    EndIf
Next nLinAtivo

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Se o tamanho da Grid for igual ao n?mero de itens deletados, acusa uma falha
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
If oModelGRID:Length()==nDeletados
    lRet :=.F.
    Help(,,"Dados Inv疝idos",, "A grid precisa ter pelo menos uma linha sem ser excluida!", 1, 0,,,,,, {"Inclua uma linha v疝ida!"})
EndIf

Return lRet


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		fValidLine                                                   /@
@type			Static Function                                              /@
@date			30/11/2021                                                   /@
@description	Valida a linha do Grid (linok)                               /@
@author			Adalberto Moreno Batista (Op鈬o Um)                          /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function fValidLine(oModel)
Local lRet          := .T.
Local nLinAtivo     := 0
Local oModelGRID    := oModel:GetModel('MdGridZZB')
Local cAprov        := oModelGRID:GetValue("ZZB_APROV")
Local nLine 		:= oModelGrid:GetLine()

For nLinAtivo := 1 To oModelGRID:Length()       //Percorrendo todos os itens da grid
    
    oModelGRID:GoLine(nLinAtivo)    //Posiciona na linha

    if !oModelGRID:IsDeleted() .and. nLinAtivo != nLine .and. oModelGRID:GetValue("ZZB_APROV") == cAprov
        Help(,,"Aprovador Inv疝ido",, "O aprovador desta linha, j? foi informado em outra linha e n縊 pode haver dois aprovadores iguais em um mesmo ano.", 1, 0,,,,,, {"Informe outro aprovador!"})
        lRet := .F.
    endif
        
Next nLinAtivo

oModelGRID:GoLine(nLine)        //restaura linha posicionada no grid
Return lRet


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		MNT02Repl                                                    /@
@type	  		User function                                                /@
@date			21/10/2021                                                   /@
@description	Fun鈬o para replica鈬o dos dados para as pr?ximas c駘ulas.
				Deve ser ativado por gatilho.                                /@
@author			Adalberto Moreno Batista (Op鈬o Um)                          /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function MNT02Repl()
Local oModel        := FWModelActive()
Local oModelGRID    := oModel:GetModel('MdGridZZB')
Local cVar		    := ReadVar()
Local nRet		    := &(cVar)
Local nCont		    := Val(Right(cVar,2))
Local nX
//Local aHeadAux   := oModelGrid:aHeader
//Local aColsAux   := oModelGrid:aCols

if MsgYesNo("Deseja replicar este valor para os pr?ximos meses?", "Pergunta")
	For nX := nCont + 1 to 12
        //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
    	// :LoadValue nao executa validacao e nem gatilhos
        // :Setvalue executa valida鈬o padr縊 e gatilhos, podendo retornar .T. ou .F.
        //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
        oModelGRID:LoadValue("ZZB_LIMM" + StrZero(nX,2), nRet)
	Next
endif

Return(nRet)


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		MNT02Edit                                                    /@
@type			Static Function                                              /@
@date			13/12/2021                                                   /@
@description	Valida se o campo de valor mensal poder? ser alterado.
                Permitido somente para meses/ano maiores que o mes/ano atual /@
@author			Adalberto Moreno Batista (Op鈬o Um)                          /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function MNT02Edit()
Local lRet          := .T.
Local oModel        := FWModelActive()
Local oModelMain    := oModel:GetModel('MdFieldZZB')
Local cAno          := StrZero(Year(Date()),4)
Local cMes          := StrZero(Month(Date()),2)

if oModelMain:GetValue("ZZB_ANO") == cAno .and. Right(ReadVar(),2) <= cMes
    lRet := .F.
endif
        
Return lRet
