#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//Variαveis Estαticas
Static cTitulo := "Regras de Modelos Borderτs e Tipos de Pagamentos"

/*/

@function		BRAMNT05                                                     /@
@type	  		User Function                                                /@
@date			10/05/2022                                                   /@
@description	Cadastramento de regras de Modelos Borderτs e Tipos de 
                Pagamentos						                             /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
                Opηγo Um Tecnologia da Informaηγo (www.opcaoum.com.br)       /@
@use			Brasitech                                                    /@

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
    Help(,, "Funcionalidade Invαlida",, "Esta funcionalidade nγo ι vαlida para esta empresa!", 1, 0,,,,,, {"Selecione a empresa que possua a configuraηγo de regras de modelos de borderτs de pagamentos"})
endif

RestArea(aArea)
Return Nil
 
/*/

@function		MENUDEF                                                      /@
@type			Static Function                                              /@
@date			10/05/2022                                                   /@
@description	Criaηγo do menu MVC                                          /@
@author			Adalberto Moreno Batista (Opηγo Um)                          /@
@use			Brasitech                                                  /@

/*/
Static Function MenuDef()
Local aRot := {}

//    
// Adicionando opηυes
//
ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.BRAMNT05' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.BRAMNT05' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.BRAMNT05' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.BRAMNT05' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
Return aRot


/*/

@function		MODELDEF                                                     /@
@type			Static Function                                              /@
@date			10/05/2022                                                   /@
@description	Criaηγo do modelo de dados MVC                               /@
@author			Adalberto Moreno Batista (Opηγo Um)                          /@
@use			Brasitech                                                    /@

/*/
Static Function ModelDef()
Local oModel        := NIL
Local oStruCab      := FWFormStruct(1, 'ZZR', {|cCampo| AllTRim(cCampo) $ "ZZR_BANCO/ZZR_LAYOUT"})
Local oStruGrid     := fModStruct()
Local bPosValid     := {|oModel| fValidGrid(oModel)}
Local bValidLine    := {|| fValidLine(oModel)}

//
// Monta o modelo de dados, e na Pσs Validaηγo, informa a funηγo fValidGrid
//
oModel := MPFormModel():New('BMNT05M', /*bPreValid*/, bPosValid, /*bCommit*/, /*bCancel*/ )

//
// Define no modelo de dados, que terα um Cabeηalho e uma Grid apontando para 
// estruturas acima
//
oModel:AddFields('MdFieldZZR', NIL, oStruCab)
oModel:AddGrid('MdGridZZR', 'MdFieldZZR', oStruGrid, , )

//
// Monta o relacionamento entre Grid e Cabeηalho, as expressυes da esquerda 
// representam o campo da Grid e da direita do Cabeηalho
//
oModel:SetRelation('MdGridZZR', {;
                                {'ZZR_FILIAL', 'xFilial("ZZR")'},;
                                {"ZZR_BANCO",  "ZZR_BANCO"};
                                }, ZZR->(IndexKey(1)))

//   
// Definindo outras informaηυes do Modelo e da Grid
//
oModel:GetModel("MdGridZZR"):SetMaxLine(9999)
oModel:SetDescription(cTitulo)
oModel:SetPrimaryKey({"ZZR_FILIAL", "ZZR_BANCO", "ZZR_MODELO"})
oModel:GetModel('MdGridZZR'):SetLPost(bValidLine)

oStruCab:SetProperty('ZZR_BANCO',  MODEL_FIELD_OBRIGAT, .T.)
//validaηγo SA6

Return oModel


/*/

@function		VIEWDEF                                                      /@
@type			Static Function                                              /@
@date			10/05/2022                                                   /@
@description	Criaηγo da visγo MVC                                         /@
@author			Adalberto Moreno Batista (Opηγo Um)                          /@
@use			Brasitech                                                    /@

/*/ 
Static Function ViewDef()
//
// Na montagem da estrutura da visualizaηγo de dados, vamos chamar o modelo 
// criado anteriormente, no cabeηalho vamos mostrar somente 1 campo, e na grid
// vamos carregar conforme a funηγo fViewStruct
//
Local oView     := NIL
Local oModel    := FWLoadModel('BRAMNT05')
Local oStruCab  := FWFormStruct(2, "ZZR", {|cCampo| AllTRim(cCampo) $ "ZZR_BANCO/ZZR_LAYOUT"})
Local oStruGRID := fViewStruct()

//
// Define que no cabeηalho nγo terα separaηγo de abas (SXA)
//
oStruCab:SetNoFolder()

//
// Cria o View
//
oView:= FWFormView():New() 
oView:SetModel(oModel)              

//
// Cria uma αrea de Field vinculando a estrutura do cabeηalho com MDFieldZZR, e 
// uma Grid vinculando com MdGridZZR
//
oView:AddField('VIEW_ZZR', oStruCab, 'MdFieldZZR')
oView:AddGrid ('GRID_ZZR', oStruGRID, 'MdGridZZR' )

//
// O cabeηalho (MAIN) terα 25% de tamanho, e o restante de 75% irα para a GRID
//
oView:CreateHorizontalBox("MAIN", 15)
oView:CreateHorizontalBox("GRID", 85)

//
// Vincula o MAIN com a VIEW_ZZR e a GRID com a GRID_ZZR
//
oView:SetOwnerView('VIEW_ZZR', 'MAIN')
oView:SetOwnerView('GRID_ZZR', 'GRID')
oView:EnableControlBar(.T.)

//Define o campo incremental da grid como o ZZR_ITEM
//oView:AddIncrementField('GRID_ZZR', 'ZZR_ITEM')

Return oView
 
/*/

@function		fModStruct                                                   /@
@type			Static Function                                              /@
@date			10/05/2022                                                   /@
@description	Monta o modelo de dados da Grid                              /@
@author			Adalberto Moreno Batista (Opηγo Um)                          /@
@use			Brasitech                                                    /@

/*/
Static Function fModStruct()
Local oStruct
oStruct := FWFormStruct(1, 'ZZR')
Return oStruct

/*/

@function		fModStruct                                                   /@
@type			Static Function                                              /@
@date			10/05/2022                                                   /@
@description	Monta a visualizaηγo de dados da Grid                        /@
@author			Adalberto Moreno Batista (Opηγo Um)                          /@
@use			Brasitech                                                    /@

/*/
Static Function fViewStruct()
Local oStruct

//
// Irα filtrar, e trazer todos os campos, menos "ZZR_BANCO;"
//
oStruct := FWFormStruct(2, "ZZR", {|cCampo| !(Alltrim(cCampo) $ "ZZR_BANCO;ZZR_LAYOUT")})
Return oStruct

/*/

@function		fValidGrid                                                   /@
@type			Static Function                                              /@
@date			10/05/2022                                                   /@
@description	Valida a Grid no momento da confirmaηγo (tudook)             /@
@author			Adalberto Moreno Batista (Opηγo Um)                          /@
@use			Brasitech                                                    /@

/*/
Static Function fValidGrid(oModel)
Local lRet          := .T.
Local nDeletados    := 0
Local nLinAtivo     := 0
Local oModelGRID    := oModel:GetModel('MdGridZZR')

//
// Percorre todos os itens da grid
//
For nLinAtivo := 1 To oModelGRID:Length()
    //
    // Posiciona na linha
    //
    oModelGRID:GoLine(nLinAtivo) 
    
    //
    // Se a linha for excluida, incrementa a variαvel de deletados, senγo irα 
    // incrementar o valor digitado em um campo na grid
    //
    If oModelGRID:IsDeleted()
        nDeletados++
    EndIf
Next nLinAtivo

//
// Se o tamanho da Grid for igual ao nϊmero de itens deletados, acusa uma falha
//
If oModelGRID:Length()==nDeletados
    lRet :=.F.
    Help(,,"Dados Invαlidos",, "A grid precisa ter pelo menos uma linha sem ser excluida!", 1, 0,,,,,, {"Inclua uma linha vαlida!"})
EndIf

Return lRet


/*/

@function		fValidLine                                                   /@
@type			Static Function                                              /@
@date			10/05/2022                                                   /@
@description	Valida a linha do Grid (linok)                               /@
@author			Adalberto Moreno Batista (Opηγo Um)                          /@
@use			Brasitech                                                    /@

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
        Help(,,"Modelo Invαlido",, "Modelo de borderτ de pagamentos jα cadastrado.", 1, 0,,,,,, {"Informe outro modelo!"})
        lRet := .F.
    endif
        
Next nLinAtivo

oModelGRID:GoLine(nLine)        //restaura linha posicionada no grid
Return lRet


/*/

@function		MNT05_Banco                                                  /@
@type			Static Function                                              /@
@date			10/05/2022                                                   /@
@description	Valida o codigo do banco                                     /@
@author			Adalberto Moreno Batista
                Opηγo Um Tecnologia - www.opcaoum.com.br                     /@
@use			Brasitech                                                    /@

/*/
User Function MNT05_Banco()
Local lRet          := .T.
Local oModel        := FWModelActive()
Local oModelMain    := oModel:GetModel('MdFieldZZR')
Local cBanco        := oModelMain:GetValue("ZZR_BANCO")

// considera a data de referencia como ultimo dia do mκs
//cBanco := LastDate(cBanco)
//oModelMain:LoadValue("ZZR_BANCO", cBanco)

ZZR->(dbSetOrder(1))    //ZZR_FILIAL, ZZR_BANCO, ZZR_MODELO
if ZZR->(dbSeek(xFilial("ZZR") + cBanco))
    lRet := .F.
    Help(,, "? ATENΗΓO",, "O banco informado jα estα cadastrado!" + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
endif

Return(lRet)


/*/

@function		MNT05_Regra                                                  /@
@type			Static Function                                              /@
@date			10/05/2022                                                   /@
@description	Valida a regra digitada                                      /@
@author			Adaptado da regra de formula por Adalberto Moreno Batista
                Opηγo Um Tecnologia - www.opcaoum.com.br                     /@
@use			Brasitech                                                    /@

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

@function		ChkErro                                                      /@
@type			Static Function                                              /@
@date			10/05/2022                                                   /@
@description	Valida o codigo do banco                                     /@
@author			Adaptado da regra de formula por Adalberto Moreno Batista
                Opηγo Um Tecnologia - www.opcaoum.com.br                     /@
@use			Brasitech                                                    /@

/*/
Static Function ChkErro(e,lErro)
lErro := e:gencode > 0
Break
Return()
