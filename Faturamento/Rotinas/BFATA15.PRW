//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
 
//Variáveis Estáticas
Static cTitulo := "Percentuais VPC - Marketing"
 
/*/
———————————————————————————————————————————————————————————————————————————————
@function		BFATA15                                                      /@
@type			User function                                                /@
@date			11/06/2021                                                   /@
@description	Rotina para cadastramento de percentuais VPC de marketing    /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function BFATA15()
Local aArea   := GetArea()
Local oBrowse
Local cFunBkp := FunName()
    
SetFunName("BFATA15")
    
//Instânciando FWMBrowse - Somente com dicionário de dados
oBrowse := FWMBrowse():New()
    
//Setando a tabela de cadastro de Autor/Interprete
oBrowse:SetAlias("ZZC")

//Setando a descrição da rotina
oBrowse:SetDescription(cTitulo)
    
//Legendas
oBrowse:AddLegend("dDataBase >= ZZC->ZZC_DTDE .and. dDataBase <= ZZC->ZZC_DTATE",   "GREEN",   "Ativo")
oBrowse:AddLegend("dDataBase < ZZC->ZZC_DTDE .or. dDataBase > ZZC->ZZC_DTATE",      "RED",     "Inativo")
    
//Filtrando
//oBrowse:SetFilterDefault("ZZC->ZV_COD >= '000000' .And. ZZC->ZV_COD <= 'ZZZZZZ'")
    
//Ativa a Browse
oBrowse:Activate()
    
SetFunName(cFunBkp)
RestArea(aArea)

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		MENUDEF                                                      /@
@type			Static function                                              /@
@date			11/06/2021                                                   /@
@description	Criação de menu em MVC                                       /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function MenuDef()
Local aRot := {}
    
//Adicionando opções
ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.BFATA15' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
ADD OPTION aRot TITLE 'Legenda'    ACTION 'U_FAT15Leg'      OPERATION 6                      ACCESS 0 //OPERATION X
ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.BFATA15' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.BFATA15' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.BFATA15' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
 
Return(aRot)
 

/*/
———————————————————————————————————————————————————————————————————————————————
@function		MODELDEF                                                     /@
@type			Static function                                              /@
@date			11/06/2021                                                   /@
@description	Criação do modelo de dados MVC                               /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function ModelDef()
    //Criação do objeto do modelo de dados
    Local oModel := Nil
     
    //Criação da estrutura de dados utilizada na interface
    Local oStZZC := FWFormStruct(1, "ZZC")
     
    //Editando características do dicionário
    oStZZC:SetProperty('ZZC_VPCPER',    MODEL_FIELD_VALID,      FwBuildFeature(STRUCT_FEATURE_VALID,   'M->ZZC_VPCPER >= 0 .and. M->ZZC_DTATE >= M->ZZC_DTDE'))          //Validação de Campo
    oStZZC:SetProperty('ZZC_VPCPER',    MODEL_FIELD_WHEN,       FwBuildFeature(STRUCT_FEATURE_WHEN,    'INCLUI .and. M->ZZC_DTATE >= M->ZZC_DTDE'))                      //Modo de Edição
    
    oStZZC:SetProperty('ZZC_DTDE',      MODEL_FIELD_WHEN,       FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                         //Modo de Edição
    oStZZC:SetProperty('ZZC_DTDE',      MODEL_FIELD_INIT,       FwBuildFeature(STRUCT_FEATURE_INIPAD,  'U_GetDataIni()'))              //Ini Padrão

    oStZZC:SetProperty('ZZC_DTATE',     MODEL_FIELD_INIT,       FwBuildFeature(STRUCT_FEATURE_INIPAD,  'cTOd("31/12/49")'))            //Ini Padrão
    oStZZC:SetProperty('ZZC_DTATE',     MODEL_FIELD_OBRIGAT,    .T.)                                                                   //Campo Obrigatório
    oStZZC:SetProperty('ZZC_DTATE',     MODEL_FIELD_WHEN,       FwBuildFeature(STRUCT_FEATURE_WHEN,    'ALTERA'))                      //Modo de Edição
    oStZZC:SetProperty('ZZC_DTATE',     MODEL_FIELD_VALID,      FwBuildFeature(STRUCT_FEATURE_VALID,   'M->ZZC_DTATE >= M->ZZC_DTDE'))          //Validação de Campo

    //Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("fat15M",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
     
    //Atribuindo formulários para o modelo
    oModel:AddFields("FORMZZC",/*cOwner*/,oStZZC)
     
    //Setando a chave primária da rotina
    oModel:SetPrimaryKey({'ZV_FILIAL','dTOs(ZZC_DTDE)+dTOs(ZZC_DTATE)'})
     
    //Adicionando descrição ao modelo
    oModel:SetDescription("Percentuais de VPC de Marketing")
     
    //Setando a descrição do formulário
    oModel:GetModel("FORMZZC"):SetDescription(cTitulo)
Return oModel
 

/*/
———————————————————————————————————————————————————————————————————————————————
@function		MODELDEF                                                     /@
@type			Static function                                              /@
@date			11/06/2021                                                   /@
@description	Criação da visão MVC                                         /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function ViewDef()
//Local aStruZZC    := ZZC->(DbStruct())
    
//Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
Local oModel := FWLoadModel("BFATA15")
    
//Criação da estrutura de dados utilizada na interface do cadastro de Autor
Local oStZZC := FWFormStruct(2, "ZZC")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'ZZC_NOME|ZZC_DTAFAL|'}
    
//Criando oView como nulo
Local oView := Nil

//Criando a view que será o retorno da função e setando o modelo da rotina
oView := FWFormView():New()
oView:SetModel(oModel)
    
//Atribuindo formulários para interface
oView:AddField("VIEW_ZZC", oStZZC, "FORMZZC")
    
//Criando um container com nome tela com 100%
oView:CreateHorizontalBox("TELA",100)
    
//Colocando título do formulário
oView:EnableTitleView('VIEW_ZZC', 'Dados - '+cTitulo )  
    
//Força o fechamento da janela na confirmação
oView:SetCloseOnOk({||.T.})
    
//O formulário da interface será colocado dentro do container
oView:SetOwnerView("VIEW_ZZC","TELA")
    
Return(oView)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		FAT15LEG                                                     /@
@type			User function                                                /@
@date			11/06/2021                                                   /@
@description	Legenda                                                      /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function FAT15Leg()
Local aLegenda := { {"BR_VERDE",      "Ativas"},;
                    {"BR_VERMELHO",   "Inativas"}}
    
BrwLegenda("Alíquotas VPC", "Status", aLegenda)
Return


/*/
———————————————————————————————————————————————————————————————————————————————
@function		GETDATAINI                                                   /@
@type			User function                                                /@
@date			11/06/2021                                                   /@
@description	Função para identificar a data inicial                       /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function GetDataIni()
Local dDtRef    := dDataBase
Local aArea     := GetArea()

ZZC->(dbSetOrder(1))
ZZC->(dbSeek(xFilial("ZZC")))
do while ZZC->(!eof() .and. ZZC_FILIAL==xFilial("ZZC"))
    dDtRef := ZZC->ZZC_DTATE + 1
    ZZC->(dbSkip())
enddo

RestArea(aArea)
Return(dDtRef)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		GETVPCMKT_FT15                                               /@
@type			User function                                                /@
@date			11/06/2021                                                   /@
@description	Função para buscar o perdentual VPC do periodo vigente       /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function GetVPCMkt_FT15(dDtRef)
Local nPerc     := 0
Local aArea     := GetArea()
Local aAreaZZC  := ZZC->(GetArea())

ZZC->(dbSetOrder(1))
ZZC->(dbSeek(xFilial("ZZC")))
do while ZZC->(!eof() .and. ZZC_FILIAL==xFilial("ZZC"))
    if dDtRef >= ZZC->ZZC_DTDE .and. dDtRef <= ZZC->ZZC_DTATE
        nPerc := ZZC->ZZC_VPCPER
        exit
    endif
    ZZC->(dbSkip())
enddo

RestArea(aAreaZZC)
RestArea(aArea)

Return(nPerc)
