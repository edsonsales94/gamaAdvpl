#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//Variáveis Estáticas
Static cTitulo := "Regras de Modelos Borderôs e Tipos de Pagamentos"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		BRAMNT05                                                     /@
@type	  		User Function                                                /@
@date			10/05/2022                                                   /@
@description	Cadastramento de regras de Modelos Borderôs e Tipos de 
                Pagamentos						                             /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
                Opção Um Tecnologia da Informação (www.opcaoum.com.br)       /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function BRAMNT05()
Local aArea   := GetArea()
Local oBrowse

if SX2->(dbSeek("ZZR")) .and. ZZR->(FieldPos("ZZR_BANCO")) > 0
    //Cria um browse para a ZZR
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("ZZR")
    oBrowse:SetDescription(cTitulo)
    oBrowse:Activate()
else
    Help(,, "Funcionalidade Inválida",, "Esta funcionalidade não é válida para esta empresa!", 1, 0,,,,,, {"Selecione a empresa que possua a configuração de regras de modelos de borderôs de pagamentos"})
endif

RestArea(aArea)
Return Nil
 
/*/
———————————————————————————————————————————————————————————————————————————————
@function		MENUDEF                                                      /@
@type			Static Function                                              /@
@date			10/05/2022                                                   /@
@description	Criação do menu MVC                                          /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                  /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function MenuDef()
Local aRot := {}

//———————————————————————————————————————————————————————————————————————————————    
// Adicionando opções
//———————————————————————————————————————————————————————————————————————————————
ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.BRAMNT05' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.BRAMNT05' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.BRAMNT05' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.BRAMNT05' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
Return aRot


/*/
———————————————————————————————————————————————————————————————————————————————
@function		MODELDEF                                                     /@
@type			Static Function                                              /@
@date			10/05/2022                                                   /@
@description	Criação do modelo de dados MVC                               /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function ModelDef()
Local oModel        := NIL
Local oStruCab      := FWFormStruct(1, 'ZZR', {|cCampo| AllTRim(cCampo) $ "ZZR_BANCO/ZZR_LAYOUT"})
Local oStruGrid     := fModStruct()
Local bPosValid     := {|oModel| fValidGrid(oModel)}
Local bValidLine    := {|| fValidLine(oModel)}

//———————————————————————————————————————————————————————————————————————————————
// Monta o modelo de dados, e na Pós Validação, informa a função fValidGrid
//———————————————————————————————————————————————————————————————————————————————
oModel := MPFormModel():New('BMNT05M', /*bPreValid*/, bPosValid, /*bCommit*/, /*bCancel*/ )

//———————————————————————————————————————————————————————————————————————————————
// Define no modelo de dados, que terá um Cabeçalho e uma Grid apontando para 
// estruturas acima
//———————————————————————————————————————————————————————————————————————————————
oModel:AddFields('MdFieldZZR', NIL, oStruCab)
oModel:AddGrid('MdGridZZR', 'MdFieldZZR', oStruGrid, , )

//———————————————————————————————————————————————————————————————————————————————
// Monta o relacionamento entre Grid e Cabeçalho, as expressões da esquerda 
// representam o campo da Grid e da direita do Cabeçalho
//———————————————————————————————————————————————————————————————————————————————
oModel:SetRelation('MdGridZZR', {;
                                {'ZZR_FILIAL', 'xFilial("ZZR")'},;
                                {"ZZR_BANCO",  "ZZR_BANCO"};
                                }, ZZR->(IndexKey(1)))

//———————————————————————————————————————————————————————————————————————————————   
// Definindo outras informações do Modelo e da Grid
//———————————————————————————————————————————————————————————————————————————————
oModel:GetModel("MdGridZZR"):SetMaxLine(9999)
oModel:SetDescription(cTitulo)
oModel:SetPrimaryKey({"ZZR_FILIAL", "ZZR_BANCO", "ZZR_MODELO"})
oModel:GetModel('MdGridZZR'):SetLPost(bValidLine)

oStruCab:SetProperty('ZZR_BANCO',  MODEL_FIELD_OBRIGAT, .T.)
//validação SA6

Return oModel


/*/
———————————————————————————————————————————————————————————————————————————————
@function		VIEWDEF                                                      /@
@type			Static Function                                              /@
@date			10/05/2022                                                   /@
@description	Criação da visão MVC                                         /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/ 
Static Function ViewDef()
//———————————————————————————————————————————————————————————————————————————————
// Na montagem da estrutura da visualização de dados, vamos chamar o modelo 
// criado anteriormente, no cabeçalho vamos mostrar somente 1 campo, e na grid
// vamos carregar conforme a função fViewStruct
//———————————————————————————————————————————————————————————————————————————————
Local oView     := NIL
Local oModel    := FWLoadModel('BRAMNT05')
Local oStruCab  := FWFormStruct(2, "ZZR", {|cCampo| AllTRim(cCampo) $ "ZZR_BANCO/ZZR_LAYOUT"})
Local oStruGRID := fViewStruct()

//———————————————————————————————————————————————————————————————————————————————
// Define que no cabeçalho não terá separação de abas (SXA)
//———————————————————————————————————————————————————————————————————————————————
oStruCab:SetNoFolder()

//———————————————————————————————————————————————————————————————————————————————
// Cria o View
//———————————————————————————————————————————————————————————————————————————————
oView:= FWFormView():New() 
oView:SetModel(oModel)              

//———————————————————————————————————————————————————————————————————————————————
// Cria uma área de Field vinculando a estrutura do cabeçalho com MDFieldZZR, e 
// uma Grid vinculando com MdGridZZR
//———————————————————————————————————————————————————————————————————————————————
oView:AddField('VIEW_ZZR', oStruCab, 'MdFieldZZR')
oView:AddGrid ('GRID_ZZR', oStruGRID, 'MdGridZZR' )

//———————————————————————————————————————————————————————————————————————————————
// O cabeçalho (MAIN) terá 25% de tamanho, e o restante de 75% irá para a GRID
//———————————————————————————————————————————————————————————————————————————————
oView:CreateHorizontalBox("MAIN", 15)
oView:CreateHorizontalBox("GRID", 85)

//———————————————————————————————————————————————————————————————————————————————
// Vincula o MAIN com a VIEW_ZZR e a GRID com a GRID_ZZR
//———————————————————————————————————————————————————————————————————————————————
oView:SetOwnerView('VIEW_ZZR', 'MAIN')
oView:SetOwnerView('GRID_ZZR', 'GRID')
oView:EnableControlBar(.T.)

//Define o campo incremental da grid como o ZZR_ITEM
//oView:AddIncrementField('GRID_ZZR', 'ZZR_ITEM')

Return oView
 
/*/
———————————————————————————————————————————————————————————————————————————————
@function		fModStruct                                                   /@
@type			Static Function                                              /@
@date			10/05/2022                                                   /@
@description	Monta o modelo de dados da Grid                              /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function fModStruct()
Local oStruct
oStruct := FWFormStruct(1, 'ZZR')
Return oStruct

/*/
———————————————————————————————————————————————————————————————————————————————
@function		fModStruct                                                   /@
@type			Static Function                                              /@
@date			10/05/2022                                                   /@
@description	Monta a visualização de dados da Grid                        /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function fViewStruct()
Local oStruct

//———————————————————————————————————————————————————————————————————————————————
// Irá filtrar, e trazer todos os campos, menos "ZZR_BANCO;"
//———————————————————————————————————————————————————————————————————————————————
oStruct := FWFormStruct(2, "ZZR", {|cCampo| !(Alltrim(cCampo) $ "ZZR_BANCO;ZZR_LAYOUT")})
Return oStruct

/*/
———————————————————————————————————————————————————————————————————————————————
@function		fValidGrid                                                   /@
@type			Static Function                                              /@
@date			10/05/2022                                                   /@
@description	Valida a Grid no momento da confirmação (tudook)             /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function fValidGrid(oModel)
Local lRet          := .T.
Local nDeletados    := 0
Local nLinAtivo     := 0
Local oModelGRID    := oModel:GetModel('MdGridZZR')

//———————————————————————————————————————————————————————————————————————————————
// Percorre todos os itens da grid
//———————————————————————————————————————————————————————————————————————————————
For nLinAtivo := 1 To oModelGRID:Length()
    //———————————————————————————————————————————————————————————————————————————————
    // Posiciona na linha
    //———————————————————————————————————————————————————————————————————————————————
    oModelGRID:GoLine(nLinAtivo) 
    
    //———————————————————————————————————————————————————————————————————————————————
    // Se a linha for excluida, incrementa a variável de deletados, senão irá 
    // incrementar o valor digitado em um campo na grid
    //———————————————————————————————————————————————————————————————————————————————
    If oModelGRID:IsDeleted()
        nDeletados++
    EndIf
Next nLinAtivo

//———————————————————————————————————————————————————————————————————————————————
// Se o tamanho da Grid for igual ao número de itens deletados, acusa uma falha
//———————————————————————————————————————————————————————————————————————————————
If oModelGRID:Length()==nDeletados
    lRet :=.F.
    Help(,,"Dados Inválidos",, "A grid precisa ter pelo menos uma linha sem ser excluida!", 1, 0,,,,,, {"Inclua uma linha válida!"})
EndIf

Return lRet


/*/
———————————————————————————————————————————————————————————————————————————————
@function		fValidLine                                                   /@
@type			Static Function                                              /@
@date			10/05/2022                                                   /@
@description	Valida a linha do Grid (linok)                               /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function fValidLine(oModel)
Local lRet          := .T.
Local nLinAtivo     := 0
Local oModelGRID    := oModel:GetModel('MdGridZZR')
Local cModelo       := oModelGRID:GetValue("ZZR_MODELO")
Local nLine 		:= oModelGrid:GetLine()

For nLinAtivo := 1 To oModelGRID:Length()       //Percorrendo todos os itens da grid
    
    oModelGRID:GoLine(nLinAtivo)    //Posiciona na linha

    if !oModelGRID:IsDeleted() .and. nLinAtivo != nLine .and. oModelGRID:GetValue("ZZR_MODELO") == cModelo
        Help(,,"Modelo Inválido",, "Modelo de borderô de pagamentos já cadastrado.", 1, 0,,,,,, {"Informe outro modelo!"})
        lRet := .F.
    endif
        
Next nLinAtivo

oModelGRID:GoLine(nLine)        //restaura linha posicionada no grid
Return lRet


/*/
———————————————————————————————————————————————————————————————————————————————
@function		MNT05_Banco                                                  /@
@type			Static Function                                              /@
@date			10/05/2022                                                   /@
@description	Valida o codigo do banco                                     /@
@author			Adalberto Moreno Batista
                Opção Um Tecnologia - www.opcaoum.com.br                     /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MNT05_Banco()
Local lRet          := .T.
Local oModel        := FWModelActive()
Local oModelMain    := oModel:GetModel('MdFieldZZR')
Local cBanco        := oModelMain:GetValue("ZZR_BANCO")

// considera a data de referencia como ultimo dia do mês
//cBanco := LastDate(cBanco)
//oModelMain:LoadValue("ZZR_BANCO", cBanco)

ZZR->(dbSetOrder(1))    //ZZR_FILIAL, ZZR_BANCO, ZZR_MODELO
if ZZR->(dbSeek(xFilial("ZZR") + cBanco))
    lRet := .F.
    Help(,, "® ATENÇÃO",, "O banco informado já está cadastrado!" + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
endif

Return(lRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		MNT05_Regra                                                  /@
@type			Static Function                                              /@
@date			10/05/2022                                                   /@
@description	Valida a regra digitada                                      /@
@author			Adaptado da regra de formula por Adalberto Moreno Batista
                Opção Um Tecnologia - www.opcaoum.com.br                     /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MNT05_Regra()
Local aArea     := GetArea()
Local cForm     := &(ReadVar())
Local aAlias    := {}
Local lErro     := .F.
Local lRet      := .T.
Local bBlock    := ErrorBlock()
Local bErro     := ErrorBlock({|e| ChkErro(e, @lErro)})
Local cStrForm := Upper(cForm)
Local nPos, cAlias, nI

For nI:= 1 to Len(cStrForm)
	nPos := At("_",cStrForm)
	If nPos == 0
		Exit
	EndIf
	If Substr(cStrForm,nPos-3,1)$(">()-+*/[]{}'"+'"')
		cAlias := "S"+Subs(cStrForm, nPos-2, 2)
	Else
		cAlias := Subs(cStrForm, nPos-3, 2)
	EndIf
	If Select(cAlias) == 0 .and. aScan(aAlias, cAlias) == 0
		aAdd(aAlias, cAlias)
	EndIf
	cStrForm := Substr(cStrForm, nPos+1, Len(cStrForm))
Next

lRet := MPExpChk(cForm) // Verifica se a express? pode ser executada
	
If lErro
	lRet := .F.
	Help("", 1, "BRAMNT05",, "invalid macro source:" + cForm + chr(13) + chr(10) + "(Especifico " + AllTrim(SM0->M0_NOME) + ")", 1)
Endif

RestArea(aArea)
ErrorBlock(bBlock)
Return lRet

/*/
———————————————————————————————————————————————————————————————————————————————
@function		ChkErro                                                      /@
@type			Static Function                                              /@
@date			10/05/2022                                                   /@
@description	Valida o codigo do banco                                     /@
@author			Adaptado da regra de formula por Adalberto Moreno Batista
                Opção Um Tecnologia - www.opcaoum.com.br                     /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function ChkErro(e,lErro)
lErro := e:gencode > 0
Break
Return()
