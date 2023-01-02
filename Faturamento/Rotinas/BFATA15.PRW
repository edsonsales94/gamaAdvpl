//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
 
//Vari�veis Est�ticas
Static cTitulo := "Percentuais VPC - Marketing"
 
/*/
�������������������������������������������������������������������������������
@function		BFATA15                                                      /@
@type			User function                                                /@
@date			11/06/2021                                                   /@
@description	Rotina para cadastramento de percentuais VPC de marketing    /@
@author			Adalberto Moreno Batista (Op��o Um)                          /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
/*/
User Function BFATA15()
Local aArea   := GetArea()
Local oBrowse
Local cFunBkp := FunName()
    
SetFunName("BFATA15")
    
//Inst�nciando FWMBrowse - Somente com dicion�rio de dados
oBrowse := FWMBrowse():New()
    
//Setando a tabela de cadastro de Autor/Interprete
oBrowse:SetAlias("ZZC")

//Setando a descri��o da rotina
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
�������������������������������������������������������������������������������
@function		MENUDEF                                                      /@
@type			Static function                                              /@
@date			11/06/2021                                                   /@
@description	Cria��o de menu em MVC                                       /@
@author			Adalberto Moreno Batista (Op��o Um)                          /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRot := {}
    
//Adicionando op��es
ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.BFATA15' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
ADD OPTION aRot TITLE 'Legenda'    ACTION 'U_FAT15Leg'      OPERATION 6                      ACCESS 0 //OPERATION X
ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.BFATA15' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.BFATA15' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.BFATA15' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
 
Return(aRot)
 

/*/
�������������������������������������������������������������������������������
@function		MODELDEF                                                     /@
@type			Static function                                              /@
@date			11/06/2021                                                   /@
@description	Cria��o do modelo de dados MVC                               /@
@author			Adalberto Moreno Batista (Op��o Um)                          /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
/*/
Static Function ModelDef()
    //Cria��o do objeto do modelo de dados
    Local oModel := Nil
     
    //Cria��o da estrutura de dados utilizada na interface
    Local oStZZC := FWFormStruct(1, "ZZC")
     
    //Editando caracter�sticas do dicion�rio
    oStZZC:SetProperty('ZZC_VPCPER',    MODEL_FIELD_VALID,      FwBuildFeature(STRUCT_FEATURE_VALID,   'M->ZZC_VPCPER >= 0 .and. M->ZZC_DTATE >= M->ZZC_DTDE'))          //Valida��o de Campo
    oStZZC:SetProperty('ZZC_VPCPER',    MODEL_FIELD_WHEN,       FwBuildFeature(STRUCT_FEATURE_WHEN,    'INCLUI .and. M->ZZC_DTATE >= M->ZZC_DTDE'))                      //Modo de Edi��o
    
    oStZZC:SetProperty('ZZC_DTDE',      MODEL_FIELD_WHEN,       FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                         //Modo de Edi��o
    oStZZC:SetProperty('ZZC_DTDE',      MODEL_FIELD_INIT,       FwBuildFeature(STRUCT_FEATURE_INIPAD,  'U_GetDataIni()'))              //Ini Padr�o

    oStZZC:SetProperty('ZZC_DTATE',     MODEL_FIELD_INIT,       FwBuildFeature(STRUCT_FEATURE_INIPAD,  'cTOd("31/12/49")'))            //Ini Padr�o
    oStZZC:SetProperty('ZZC_DTATE',     MODEL_FIELD_OBRIGAT,    .T.)                                                                   //Campo Obrigat�rio
    oStZZC:SetProperty('ZZC_DTATE',     MODEL_FIELD_WHEN,       FwBuildFeature(STRUCT_FEATURE_WHEN,    'ALTERA'))                      //Modo de Edi��o
    oStZZC:SetProperty('ZZC_DTATE',     MODEL_FIELD_VALID,      FwBuildFeature(STRUCT_FEATURE_VALID,   'M->ZZC_DTATE >= M->ZZC_DTDE'))          //Valida��o de Campo

    //Instanciando o modelo, n�o � recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("fat15M",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
     
    //Atribuindo formul�rios para o modelo
    oModel:AddFields("FORMZZC",/*cOwner*/,oStZZC)
     
    //Setando a chave prim�ria da rotina
    oModel:SetPrimaryKey({'ZV_FILIAL','dTOs(ZZC_DTDE)+dTOs(ZZC_DTATE)'})
     
    //Adicionando descri��o ao modelo
    oModel:SetDescription("Percentuais de VPC de Marketing")
     
    //Setando a descri��o do formul�rio
    oModel:GetModel("FORMZZC"):SetDescription(cTitulo)
Return oModel
 

/*/
�������������������������������������������������������������������������������
@function		MODELDEF                                                     /@
@type			Static function                                              /@
@date			11/06/2021                                                   /@
@description	Cria��o da vis�o MVC                                         /@
@author			Adalberto Moreno Batista (Op��o Um)                          /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
/*/
Static Function ViewDef()
//Local aStruZZC    := ZZC->(DbStruct())
    
//Cria��o do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
Local oModel := FWLoadModel("BFATA15")
    
//Cria��o da estrutura de dados utilizada na interface do cadastro de Autor
Local oStZZC := FWFormStruct(2, "ZZC")  //pode se usar um terceiro par�metro para filtrar os campos exibidos { |cCampo| cCampo $ 'ZZC_NOME|ZZC_DTAFAL|'}
    
//Criando oView como nulo
Local oView := Nil

//Criando a view que ser� o retorno da fun��o e setando o modelo da rotina
oView := FWFormView():New()
oView:SetModel(oModel)
    
//Atribuindo formul�rios para interface
oView:AddField("VIEW_ZZC", oStZZC, "FORMZZC")
    
//Criando um container com nome tela com 100%
oView:CreateHorizontalBox("TELA",100)
    
//Colocando t�tulo do formul�rio
oView:EnableTitleView('VIEW_ZZC', 'Dados - '+cTitulo )  
    
//For�a o fechamento da janela na confirma��o
oView:SetCloseOnOk({||.T.})
    
//O formul�rio da interface ser� colocado dentro do container
oView:SetOwnerView("VIEW_ZZC","TELA")
    
Return(oView)


/*/
�������������������������������������������������������������������������������
@function		FAT15LEG                                                     /@
@type			User function                                                /@
@date			11/06/2021                                                   /@
@description	Legenda                                                      /@
@author			Adalberto Moreno Batista (Op��o Um)                          /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
/*/
User Function FAT15Leg()
Local aLegenda := { {"BR_VERDE",      "Ativas"},;
                    {"BR_VERMELHO",   "Inativas"}}
    
BrwLegenda("Al�quotas VPC", "Status", aLegenda)
Return


/*/
�������������������������������������������������������������������������������
@function		GETDATAINI                                                   /@
@type			User function                                                /@
@date			11/06/2021                                                   /@
@description	Fun��o para identificar a data inicial                       /@
@author			Adalberto Moreno Batista (Op��o Um)                          /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
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
�������������������������������������������������������������������������������
@function		GETVPCMKT_FT15                                               /@
@type			User function                                                /@
@date			11/06/2021                                                   /@
@description	Fun��o para buscar o perdentual VPC do periodo vigente       /@
@author			Adalberto Moreno Batista (Op��o Um)                          /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
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