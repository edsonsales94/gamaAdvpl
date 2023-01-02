#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//Vari�veis Est�ticas
Static cTitulo := "Or�amentos de compras por departamento"

/*/
�������������������������������������������������������������������������������
@function		BRAMNT02                                                     /@
@type	  		User Function                                                /@
@date			21/10/2021                                                   /@
@description	Cadastramento de limites de compras de aprovadores por m�s
				de acordo com budget anual.
				Atualiza��o do cadastro de aprovador (SAK) ser� realizada de
				forma autom�tica pela rotina schedule BRAJOB?? todo dia 1o 
				as 0h 							                             /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
                Op��o Um Tecnologia da Informa��o (www.opcaoum.com.br)       /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
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
�������������������������������������������������������������������������������
@function		MENUDEF                                                      /@
@type			Static Function                                              /@
@date			21/10/2021                                                   /@
@description	Cria��o do menu MVC                                          /@
@author			Adalberto Moreno Batista (Op��o Um)                          /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRot := {}

//�������������������������������������������������������������������������������    
// Adicionando op��es
//�������������������������������������������������������������������������������
ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.BRAMNT02' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.BRAMNT02' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.BRAMNT02' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.BRAMNT02' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
Return aRot

/*/
�������������������������������������������������������������������������������
@function		MODELDEF                                                     /@
@type			Static Function                                              /@
@date			21/10/2021                                                   /@
@description	Cria��o do modelo de dados MVC                               /@
@author			Adalberto Moreno Batista (Op��o Um)                          /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
/*/
Static Function ModelDef()
Local oModel    := NIL
Local oStruCab  := FWFormStruct(1, 'ZZB', {|cCampo| AllTRim(cCampo) $ "ZZB_ANO"})
Local oStruGrid := fModStruct()
Local bPosValid     := {|oModel| fValidGrid(oModel)}
Local bValidLine    := {|| fValidLine(oModel)}

//�������������������������������������������������������������������������������
// Monta o modelo de dados, e na P�s Valida��o, informa a fun��o fValidGrid
//�������������������������������������������������������������������������������
oModel := MPFormModel():New('BRMNT02M', /*bPreValid*/, bPosValid, /*bCommit*/, /*bCancel*/ )

//�������������������������������������������������������������������������������
// Define no modelo de dados, que ter� um Cabe�alho e uma Grid apontando para 
// estruturas acima
//�������������������������������������������������������������������������������
oModel:AddFields('MdFieldZZB', NIL, oStruCab)
oModel:AddGrid('MdGridZZB', 'MdFieldZZB', oStruGrid, , )

//�������������������������������������������������������������������������������
// Monta o relacionamento entre Grid e Cabe�alho, as express�es da esquerda 
// representam o campo da Grid e da direita do Cabe�alho
//�������������������������������������������������������������������������������
oModel:SetRelation('MdGridZZB', {;
                                {'ZZB_FILIAL', 'xFilial("ZZB")'},;
                                {"ZZB_ANO",  "ZZB_ANO"};
                                }, ZZB->(IndexKey(1)))

//�������������������������������������������������������������������������������   
// Definindo outras informa��es do Modelo e da Grid
//�������������������������������������������������������������������������������
oModel:GetModel("MdGridZZB"):SetMaxLine(9999)
oModel:SetDescription(cTitulo)
oModel:SetPrimaryKey({"ZZB_FILIAL", "ZZB_ANO", "ZZB_APROV"})
oModel:GetModel('MdGridZZB'):SetLPost(bValidLine)

oStruCab:SetProperty('ZZB_ANO',  MODEL_FIELD_OBRIGAT, .T.)

Return oModel


/*/
�������������������������������������������������������������������������������
@function		VIEWDEF                                                      /@
@type			Static Function                                              /@
@date			21/10/2021                                                   /@
@description	Cria��o da vis�o MVC                                         /@
@author			Adalberto Moreno Batista (Op��o Um)                          /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
/*/ 
Static Function ViewDef()
//�������������������������������������������������������������������������������
// Na montagem da estrutura da visualiza��o de dados, vamos chamar o modelo 
// criado anteriormente, no cabe�alho vamos mostrar somente 1 campo, e na grid
// vamos carregar conforme a fun��o fViewStruct
//�������������������������������������������������������������������������������
Local oView        := NIL
Local oModel    := FWLoadModel('BRAMNT02')
Local oStruCab  := FWFormStruct(2, "ZZB", {|cCampo| AllTRim(cCampo) $ "ZZB_ANO"})
Local oStruGRID := fViewStruct()

//�������������������������������������������������������������������������������
// Define que no cabe�alho n�o ter� separa��o de abas (SXA)
//�������������������������������������������������������������������������������
oStruCab:SetNoFolder()

//�������������������������������������������������������������������������������
// Cria o View
//�������������������������������������������������������������������������������
oView:= FWFormView():New() 
oView:SetModel(oModel)              

//�������������������������������������������������������������������������������
// Cria uma �rea de Field vinculando a estrutura do cabe�alho com MDFieldZZB, e 
// uma Grid vinculando com MdGridZZB
//�������������������������������������������������������������������������������
oView:AddField('VIEW_ZZB', oStruCab, 'MdFieldZZB')
oView:AddGrid ('GRID_ZZB', oStruGRID, 'MdGridZZB' )

//�������������������������������������������������������������������������������
// O cabe�alho (MAIN) ter� 25% de tamanho, e o restante de 75% ir� para a GRID
//�������������������������������������������������������������������������������
oView:CreateHorizontalBox("MAIN", 15)
oView:CreateHorizontalBox("GRID", 85)

//�������������������������������������������������������������������������������
// Vincula o MAIN com a VIEW_ZZB e a GRID com a GRID_ZZB
//�������������������������������������������������������������������������������
oView:SetOwnerView('VIEW_ZZB', 'MAIN')
oView:SetOwnerView('GRID_ZZB', 'GRID')
oView:EnableControlBar(.T.)

//Define o campo incremental da grid como o ZZB_ITEM
//oView:AddIncrementField('GRID_ZZB', 'ZZB_ITEM')

Return oView
 
/*/
�������������������������������������������������������������������������������
@function		fModStruct                                                   /@
@type			Static Function                                              /@
@date			21/10/2021                                                   /@
@description	Monta o modelo de dados da Grid                              /@
@author			Adalberto Moreno Batista (Op��o Um)                          /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
/*/
Static Function fModStruct()
Local oStruct
oStruct := FWFormStruct(1, 'ZZB')
Return oStruct

/*/
�������������������������������������������������������������������������������
@function		fModStruct                                                   /@
@type			Static Function                                              /@
@date			21/10/2021                                                   /@
@description	Monta a visualiza��o de dados da Grid                        /@
@author			Adalberto Moreno Batista (Op��o Um)                          /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
/*/
Static Function fViewStruct()
Local oStruct

//�������������������������������������������������������������������������������
// Ir� filtrar, e trazer todos os campos, menos "ZZB_ANO;"
//�������������������������������������������������������������������������������
oStruct := FWFormStruct(2, "ZZB", {|cCampo| !(Alltrim(cCampo) $ "ZZB_ANO;")})
Return oStruct

/*/
�������������������������������������������������������������������������������
@function		fValidGrid                                                   /@
@type			Static Function                                              /@
@date			21/10/2021                                                   /@
@description	Valida a Grid no momento da confirma��o (tudook)             /@
@author			Adalberto Moreno Batista (Op��o Um)                          /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
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
    Help(,, "� ATEN��O",, "O ano deve estar compreendido entre 2020 e 2049!" + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
endif 

//�������������������������������������������������������������������������������
// Percorre todos os itens da grid
//�������������������������������������������������������������������������������
For nLinAtivo := 1 To oModelGRID:Length()
    //�������������������������������������������������������������������������������
    // Posiciona na linha
    //�������������������������������������������������������������������������������
    oModelGRID:GoLine(nLinAtivo) 
    
    //�������������������������������������������������������������������������������
    // Se a linha for excluida, incrementa a vari�vel de deletados, sen�o ir� 
    // incrementar o valor digitado em um campo na grid
    //�������������������������������������������������������������������������������
    If oModelGRID:IsDeleted()
        nDeletados++
    EndIf
Next nLinAtivo

//�������������������������������������������������������������������������������
// Se o tamanho da Grid for igual ao n�mero de itens deletados, acusa uma falha
//�������������������������������������������������������������������������������
If oModelGRID:Length()==nDeletados
    lRet :=.F.
    Help(,,"Dados Inv�lidos",, "A grid precisa ter pelo menos uma linha sem ser excluida!", 1, 0,,,,,, {"Inclua uma linha v�lida!"})
EndIf

Return lRet


/*/
�������������������������������������������������������������������������������
@function		fValidLine                                                   /@
@type			Static Function                                              /@
@date			30/11/2021                                                   /@
@description	Valida a linha do Grid (linok)                               /@
@author			Adalberto Moreno Batista (Op��o Um)                          /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
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
        Help(,,"Aprovador Inv�lido",, "O aprovador desta linha, j� foi informado em outra linha e n�o pode haver dois aprovadores iguais em um mesmo ano.", 1, 0,,,,,, {"Informe outro aprovador!"})
        lRet := .F.
    endif
        
Next nLinAtivo

oModelGRID:GoLine(nLine)        //restaura linha posicionada no grid
Return lRet


/*/
�������������������������������������������������������������������������������
@function		MNT02Repl                                                    /@
@type	  		User function                                                /@
@date			21/10/2021                                                   /@
@description	Fun��o para replica��o dos dados para as pr�ximas c�lulas.
				Deve ser ativado por gatilho.                                /@
@author			Adalberto Moreno Batista (Op��o Um)                          /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
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

if MsgYesNo("Deseja replicar este valor para os pr�ximos meses?", "Pergunta")
	For nX := nCont + 1 to 12
        //�������������������������������������������������������������������������������
    	// :LoadValue nao executa validacao e nem gatilhos
        // :Setvalue executa valida��o padr�o e gatilhos, podendo retornar .T. ou .F.
        //�������������������������������������������������������������������������������
        oModelGRID:LoadValue("ZZB_LIMM" + StrZero(nX,2), nRet)
	Next
endif

Return(nRet)


/*/
�������������������������������������������������������������������������������
@function		MNT02Edit                                                    /@
@type			Static Function                                              /@
@date			13/12/2021                                                   /@
@description	Valida se o campo de valor mensal poder� ser alterado.
                Permitido somente para meses/ano maiores que o mes/ano atual /@
@author			Adalberto Moreno Batista (Op��o Um)                          /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
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