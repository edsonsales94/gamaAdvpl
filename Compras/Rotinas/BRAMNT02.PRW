#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//Variáveis Estáticas
Static cTitulo := "Orçamentos de compras por departamento"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		BRAMNT02                                                     /@
@type	  		User Function                                                /@
@date			21/10/2021                                                   /@
@description	Cadastramento de limites de compras de aprovadores por mês
				de acordo com budget anual.
				Atualização do cadastro de aprovador (SAK) será realizada de
				forma automática pela rotina schedule BRAJOB?? todo dia 1o 
				as 0h 							                             /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
                Opção Um Tecnologia da Informação (www.opcaoum.com.br)       /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
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
———————————————————————————————————————————————————————————————————————————————
@function		MENUDEF                                                      /@
@type			Static Function                                              /@
@date			21/10/2021                                                   /@
@description	Criação do menu MVC                                          /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function MenuDef()
Local aRot := {}

//———————————————————————————————————————————————————————————————————————————————    
// Adicionando opções
//———————————————————————————————————————————————————————————————————————————————
ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.BRAMNT02' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.BRAMNT02' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.BRAMNT02' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.BRAMNT02' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
Return aRot

/*/
———————————————————————————————————————————————————————————————————————————————
@function		MODELDEF                                                     /@
@type			Static Function                                              /@
@date			21/10/2021                                                   /@
@description	Criação do modelo de dados MVC                               /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function ModelDef()
Local oModel    := NIL
Local oStruCab  := FWFormStruct(1, 'ZZB', {|cCampo| AllTRim(cCampo) $ "ZZB_ANO"})
Local oStruGrid := fModStruct()
Local bPosValid     := {|oModel| fValidGrid(oModel)}
Local bValidLine    := {|| fValidLine(oModel)}

//———————————————————————————————————————————————————————————————————————————————
// Monta o modelo de dados, e na Pós Validação, informa a função fValidGrid
//———————————————————————————————————————————————————————————————————————————————
oModel := MPFormModel():New('BRMNT02M', /*bPreValid*/, bPosValid, /*bCommit*/, /*bCancel*/ )

//———————————————————————————————————————————————————————————————————————————————
// Define no modelo de dados, que terá um Cabeçalho e uma Grid apontando para 
// estruturas acima
//———————————————————————————————————————————————————————————————————————————————
oModel:AddFields('MdFieldZZB', NIL, oStruCab)
oModel:AddGrid('MdGridZZB', 'MdFieldZZB', oStruGrid, , )

//———————————————————————————————————————————————————————————————————————————————
// Monta o relacionamento entre Grid e Cabeçalho, as expressões da esquerda 
// representam o campo da Grid e da direita do Cabeçalho
//———————————————————————————————————————————————————————————————————————————————
oModel:SetRelation('MdGridZZB', {;
                                {'ZZB_FILIAL', 'xFilial("ZZB")'},;
                                {"ZZB_ANO",  "ZZB_ANO"};
                                }, ZZB->(IndexKey(1)))

//———————————————————————————————————————————————————————————————————————————————   
// Definindo outras informações do Modelo e da Grid
//———————————————————————————————————————————————————————————————————————————————
oModel:GetModel("MdGridZZB"):SetMaxLine(9999)
oModel:SetDescription(cTitulo)
oModel:SetPrimaryKey({"ZZB_FILIAL", "ZZB_ANO", "ZZB_APROV"})
oModel:GetModel('MdGridZZB'):SetLPost(bValidLine)

oStruCab:SetProperty('ZZB_ANO',  MODEL_FIELD_OBRIGAT, .T.)

Return oModel


/*/
———————————————————————————————————————————————————————————————————————————————
@function		VIEWDEF                                                      /@
@type			Static Function                                              /@
@date			21/10/2021                                                   /@
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
Local oView        := NIL
Local oModel    := FWLoadModel('BRAMNT02')
Local oStruCab  := FWFormStruct(2, "ZZB", {|cCampo| AllTRim(cCampo) $ "ZZB_ANO"})
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
// Cria uma área de Field vinculando a estrutura do cabeçalho com MDFieldZZB, e 
// uma Grid vinculando com MdGridZZB
//———————————————————————————————————————————————————————————————————————————————
oView:AddField('VIEW_ZZB', oStruCab, 'MdFieldZZB')
oView:AddGrid ('GRID_ZZB', oStruGRID, 'MdGridZZB' )

//———————————————————————————————————————————————————————————————————————————————
// O cabeçalho (MAIN) terá 25% de tamanho, e o restante de 75% irá para a GRID
//———————————————————————————————————————————————————————————————————————————————
oView:CreateHorizontalBox("MAIN", 15)
oView:CreateHorizontalBox("GRID", 85)

//———————————————————————————————————————————————————————————————————————————————
// Vincula o MAIN com a VIEW_ZZB e a GRID com a GRID_ZZB
//———————————————————————————————————————————————————————————————————————————————
oView:SetOwnerView('VIEW_ZZB', 'MAIN')
oView:SetOwnerView('GRID_ZZB', 'GRID')
oView:EnableControlBar(.T.)

//Define o campo incremental da grid como o ZZB_ITEM
//oView:AddIncrementField('GRID_ZZB', 'ZZB_ITEM')

Return oView
 
/*/
———————————————————————————————————————————————————————————————————————————————
@function		fModStruct                                                   /@
@type			Static Function                                              /@
@date			21/10/2021                                                   /@
@description	Monta o modelo de dados da Grid                              /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function fModStruct()
Local oStruct
oStruct := FWFormStruct(1, 'ZZB')
Return oStruct

/*/
———————————————————————————————————————————————————————————————————————————————
@function		fModStruct                                                   /@
@type			Static Function                                              /@
@date			21/10/2021                                                   /@
@description	Monta a visualização de dados da Grid                        /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function fViewStruct()
Local oStruct

//———————————————————————————————————————————————————————————————————————————————
// Irá filtrar, e trazer todos os campos, menos "ZZB_ANO;"
//———————————————————————————————————————————————————————————————————————————————
oStruct := FWFormStruct(2, "ZZB", {|cCampo| !(Alltrim(cCampo) $ "ZZB_ANO;")})
Return oStruct

/*/
———————————————————————————————————————————————————————————————————————————————
@function		fValidGrid                                                   /@
@type			Static Function                                              /@
@date			21/10/2021                                                   /@
@description	Valida a Grid no momento da confirmação (tudook)             /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
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
    Help(,, "® ATENÇÃO",, "O ano deve estar compreendido entre 2020 e 2049!" + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
endif 

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
@date			30/11/2021                                                   /@
@description	Valida a linha do Grid (linok)                               /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
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
        Help(,,"Aprovador Inválido",, "O aprovador desta linha, já foi informado em outra linha e não pode haver dois aprovadores iguais em um mesmo ano.", 1, 0,,,,,, {"Informe outro aprovador!"})
        lRet := .F.
    endif
        
Next nLinAtivo

oModelGRID:GoLine(nLine)        //restaura linha posicionada no grid
Return lRet


/*/
———————————————————————————————————————————————————————————————————————————————
@function		MNT02Repl                                                    /@
@type	  		User function                                                /@
@date			21/10/2021                                                   /@
@description	Função para replicação dos dados para as próximas células.
				Deve ser ativado por gatilho.                                /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
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

if MsgYesNo("Deseja replicar este valor para os próximos meses?", "Pergunta")
	For nX := nCont + 1 to 12
        //———————————————————————————————————————————————————————————————————————————————
    	// :LoadValue nao executa validacao e nem gatilhos
        // :Setvalue executa validação padrão e gatilhos, podendo retornar .T. ou .F.
        //———————————————————————————————————————————————————————————————————————————————
        oModelGRID:LoadValue("ZZB_LIMM" + StrZero(nX,2), nRet)
	Next
endif

Return(nRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		MNT02Edit                                                    /@
@type			Static Function                                              /@
@date			13/12/2021                                                   /@
@description	Valida se o campo de valor mensal poderá ser alterado.
                Permitido somente para meses/ano maiores que o mes/ano atual /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
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
