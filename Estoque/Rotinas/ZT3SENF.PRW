//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "TOTVS.ch"
#Include "TBICONN.ch"

//Variáveis Estáticas
Static cTitulo := "SENF ELETRONICA (Mod.1)"

/*/{Protheus.doc} zMVCMd1
Função para Cadastro de SENF Eletronica, exemplo de Modelo 1 em MVC
@author Ricky Moraes	
@since 16/06/20
@version 1.0
	@return Nil, Função não tem retorno
	@example
	u_ZT3SENF()
	@obs Não se pode executar função MVC dentro do fórmulas
/*/
User Function ZT3SENF()
    Local aArea   := GetArea()
    Local oBrowse
    Local cFunBkp:=FunName()
    Public nVrlFinal :=0

    setFunName("ZT3SENF")
    //Instânciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMBrowse():New()

    //Setando a tabela de cadastro de Autor/Interprete
    oBrowse:SetAlias("ZT3")
    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)

    //Legendas
    oBrowse:AddLegend( "EMPTY(ZT3->ZT3_STATUS) .OR.(ZT3->ZT3_STATUS)=='1' ", "BR_BRANCO",	"Pendente" )
    oBrowse:AddLegend( "(ZT3->ZT3_STATUS)=='2'", "BR_AMARELO",	"Setor Expedic" )
    oBrowse:AddLegend( "(ZT3->ZT3_STATUS)=='3'", "BR_LARANJA",	"Setor Fiscal" )
    oBrowse:AddLegend( "(ZT3->ZT3_STATUS)=='4'", "BR_VERDE",	"Faturado" )
    oBrowse:AddLegend( "(ZT3->ZT3_STATUS)=='5'", "BR_PRETO",	"Cancelado/Reprovado" )

   

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
******************************************************************************************************************************************************
Static Function MenuDef()
******************************************************************************************************************************************************
	Local aRot := {}
	
	//Adicionando opções
	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.ZT3SENF' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Legenda'    ACTION 'u_ZT3Leg'     	OPERATION 6                	     ACCESS 0 //OPERATION X
	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.ZT3SENF' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.ZT3SENF' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	//ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.zMVCMd1' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
    
    ADD OPTION aRot TITLE "Separar Mat.(Exp)"    ACTION "U_fSepMat()"    OPERATION 6 ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Liberar Fat.(Exp)'    ACTION "U_fAlmoxExp()"      OPERATION 6            ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'ReEnviarEmail'        ACTION "U_ReEmailSenf('')"  OPERATION 6            ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Gerar PV'             ACTION "U_fGeraPv()"        OPERATION 6            ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Excluir / Reprovar'             ACTION "U_fRepSenf()"        OPERATION 6            ACCESS 0 //OPERATION 3

Return aRot
/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Ricky Moraes                                                 |
 | Data:  19/06/2020                                                   |
 | Desc:  Criação do modelo de dados MVC                               |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
******************************************************************************************************************************************************
Static Function ModelDef()
******************************************************************************************************************************************************	
	Local oModel         := Nil
    Local oStPai         := FWFormStruct(1, 'ZT3')
    Local oStFilho     := FWFormStruct(1, 'ZT4')

    
    oStPai:SetProperty('ZT3_STATUS',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.')) 
    oStPai:SetProperty('ZT3_ESPECI',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.')) 
    oStPai:SetProperty('ZT3_PLIQUI',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.')) 
    oStPai:SetProperty('ZT3_PBRUTO',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.')) 
    oStPai:SetProperty('ZT3_PEDIDO',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.')) 
 
    oStFilho:SetProperty('ZT4_ITEM',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                                                       //Campo Obrigatório
    oStFilho:SetProperty('ZT4_ITEM', MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'u_zIniMus()'))                         //Ini Padrão

    //Criando o modelo e os relacionamentos
    oModel := MPFormModel():New('zMVCZT3',   /*bPre*/, /*bPost*/, { |oModel|fSave(oModel)}/*bCommit*/, /*bCancel*/)

    oModel:AddFields('ZT3MASTER',/*cOwner*/,oStPai)
    oModel:AddGrid('ZT4DETAIL','ZT3MASTER',oStFilho,/*bLinePre*/,{|oGrid| fLinOK(oGrid)},/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence
        
    //oModel:AddCalc("COMP022CALC1", "Z09MASTER", "Z10DETAIL", "Z10_VALOR", "Z09_TOTAL", "SUM", , , "Total:" )

	oModel:SetRelation( 'ZT4DETAIL', { { 'ZT4_FILIAL', 'xFilial( "ZT4" )' }, { 'ZT4_NUMSF', 'ZT3_NUM' } }, ZT4->( IndexKey( 1 ) ) )

    
    //Adicionando totalizadores
    oModel:AddCalc('TOT_SALDO', 'ZT3MASTER', 'ZT4DETAIL', 'ZT4_COD',    'XX_TOTAL',  'COUNT', , ,  "Produtos" )
    oModel:AddCalc('TOT_SALDO', 'ZT3MASTER', 'ZT4DETAIL', 'ZT4_QTDSOL', 'XX_TOTAL2', 'SUM', , ,    "Qtd. Total" )
    oModel:AddCalc('TOT_SALDO', 'ZT3MASTER', 'ZT4DETAIL', 'ZT4_VALOR',  'XX_TOTAL3', 'SUM', , ,    "Valor Total R$" )

  
    oModel:SetPrimaryKey({})
    //Setando as descrições
    oModel:SetDescription("SENF")
    //oModel:GetModel('ZT3MASTER'):SetDescription('Cabecalho')
    oModel:GetModel('ZT4DETAIL'):SetDescription('Itens')
    
    //oModel:GetModel('ZT4DETAIL'):SetUseOldGrid( .T. )

 SetKey(VK_F4, { || U_fSaldoProd()  })

Return oModel
 
/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  03/09/2016                                                   |
 | Desc:  Criação da visão MVC                                         |
 *---------------------------------------------------------------------*/
 
Static Function ViewDef()
    Local oView        := Nil
    Local oModel        := FWLoadModel('ZT3SENF')
    Local oStPai        := FWFormStruct(2, 'ZT3')
    Local oStFilho    := FWFormStruct(2, 'ZT4')
	Local nAtual,cCampoAux
    Local aStFilho    := ZT4->(DbStruct())
    Local oStr3:= FWCalcStruct( oModel:GetModel('TOT_SALDO') )

  

    //Criando a View
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Adicionando os campos do cabeçalho e o grid dos filhos
    oView:AddField('VIEW_ZT3',oStPai,'ZT3MASTER')
    oView:AddGrid('VIEW_ZT4',oStFilho,'ZT4DETAIL')
    
    oView:AddField('VW_DETAILAUX', oStr3,'TOT_SALDO')
     
    //Setando o dimensionamento de tamanho
    oView:CreateHorizontalBox('CABEC',40)
    oView:CreateHorizontalBox('GRID',45)
    oView:CreateHorizontalBox('BOX_INFERIOR',15)
    
     
    //Amarrando a view com as box
    oView:SetOwnerView('VIEW_ZT3','CABEC')
    oView:SetOwnerView('VIEW_ZT4','GRID')
    oView:SetOwnerView('VW_DETAILAUX','BOX_INFERIOR')
     
    //Habilitando título
    oView:EnableTitleView('VIEW_ZT3','Cabeçalho')
    oView:EnableTitleView('VIEW_ZT4','Itens')
     oView:EnableTitleView('VW_DETAILAUX','Totais')
     
    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})

	//criando botao
	oView:AddUserButton( 'Inclui por BOM', 'CLIPS', {|oView| sfCarregaBom(oModel,oView)} )
        
    //Remove os campos de Código do Artista e CD
    //oStFilho:RemoveField('ZT4_NUMSF')
    //oStFilho:RemoveField('ZZ3_CODCD')

	_cCamposFilho:= "ZT4_ITEM,ZT4_COD,ZT4_UM,ZT4_DESC,ZT4_QTDSOL,ZT4_QTDATE, ZT4_PRCUNI, ZT4_VALOR "

    
    //Tratativa para remover campos da visualização
    For nAtual := 1 To Len(aStFilho)
        cCampoAux:= Alltrim(aStFilho[nAtual][01])
         
        
        //Se o campo atual não estiver nos que forem considerados
        If !Alltrim(cCampoAux) $ Alltrim(_cCamposFilho)
            oStFilho:RemoveField(cCampoAux)
        EndIf
        

    Next
    /*
  	_cCamposPai:= "ZT3_TES,ZT3_CONDPA,ZT3_PLIQUI,ZT3_PBRUTO,ZT3_VOLUME,ZT3_ESPECI,ZT3_CODTAB,ZT3_TRANSP"
    //Tratativa para remover campos da visualização se for inclusao
    IF oModel:nOperation == 3
        For nAtual := 1 To Len(aStPai)
            cCampoAux2 := Alltrim(aStPai[nAtual][01])
            
            //Se o campo atual não estiver nos que forem considerados
            If Alltrim(cCampoAux2) $ Alltrim(_cCamposPai)
                oStPai:RemoveField(cCampoAux2)
            EndIf
        Next
    ENDIF
    */

Return oView


//Iniciar automaticamente numero item
******************************************************************************************************************************************************
User Function zIniMus()
******************************************************************************************************************************************************
    Local aArea := GetArea()
    Local cCod  //:= StrTran(Space(TamSX3('ZT4_ITEM')[1]), ' ', '0')
    Local oModelPad  := FWModelActive()
    Local oModelGrid := oModelPad:GetModel('ZT4DETAIL')
    //   Local nOperacao  := oModelPad:nOperation
    Local nLinAtu    := oModelGrid:nLine+1
//    Local nPosCod    := aScan(oModelGrid:aHeader, {|x| AllTrim(x[2]) == AllTrim("ZT4_ITEM")})

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


******************************************************************************************************************************************************
User Function fGeraPv()
******************************************************************************************************************************************************

	IF ZT3->ZT3_STATUS == "3"
		u_fCargaSenf(ZT3->ZT3_NUM)
	ELSE
	 Alert("Verifique o Status" + " Necessaria a Liberação da Expedicão !")
	ENDIF
	

RETURN

******************************************************************************************************************************************************
User Function fSaldoProd()
******************************************************************************************************************************************************
Local oModel:= FwModelActive()
Local oGrid := oModel:GetModel("ZT4DETAIL")
oGrid:GoLine(oGrid:nLine)
    
    If !Empty(oGrid:GetValue('ZT4_COD'))
      MaViewSB2(oGrid:GetValue('ZT4_COD'))      
    Endif
RETURN



******************************************************************************************************************************************************
User Function ReEmailSENF(cCall)
******************************************************************************************************************************************************
Local cTexto:=" "

		cTexto:=ZT3->ZT3_STATUS
		DO CASE
		CASE cTexto == "1"
		cTexto := "Pendente"
		CASE cTexto == "2"
		cTexto:= "Setor Expedic."
		CASE cTexto == "3"
		cTexto := "Setor Fiscal"
		CASE cTexto == "4"
		cTexto := "Faturado"
		CASE cTexto == "5"
		cTexto := "*Cancelada/Bloqueada*"
		OTHERWISE
		cTexto := "*Standby*"
		ENDCASE
		
			
		lEmail:=U_fEmailSenf(ZT3->ZT3_NUM,cTexto +' ' +cCall)

		IF lEmail
			MSGINFO( 'E-mail enviado com Sucesso.', "SENF - Eletronica" )    
		ELSE
			ALERT('Erro ao enviar o E-mail')
		ENDIF

return



******************************************************************************************************************************************************
User Function ZT3Leg()
******************************************************************************************************************************************************
    Local aLegenda := {}

    aAdd(aLegenda, {"BR_BRANCO", "Solicitação" })
    aAdd(aLegenda, {"BR_AMARELO", "Setor Exp." })
    aAdd(aLegenda, {"BR_LARANJA", "Setor Fiscal" })
    aAdd(aLegenda, {"BR_VERDE", "Faturado/Em Pedido" })
    aAdd(aLegenda, {"BR_PRETO", "Reprovado" })

    brwLegenda("Semafaro", "Legenda", aLegenda)
Return


// FUNÇÃO PRINCIPAL explode BOM
******************************************************************************************************************************************************
Static Function sfVldEstrut(cPai,nQtd)
******************************************************************************************************************************************************
    Local aBOM:={}
    Local _cLocal


            IF !EMPTY(cPai) .and. !EMPTY(nQtd)

                BeginSql Alias "SG1T"
                SELECT  COD_COMP,QTD FROM VW_SG1
                    WHERE CODIGO=%Exp:cPai%  // "SPP0067"
                    AND TIPO_COMP <>'MO'
                    //AND FTM_COD=' '

                EndSql
                dbSelectArea("SG1T")
                Count To nTotal
                DbGoTop()


                IF nTotal > 0
                    //alert(SG1T->COD_COMP)
                    while  !Eof()
                        _cLocal:=POSICIONE("SB1",1,XFILIAL("SB1")+SG1T->COD_COMP,"B1_LOCPAD")
                        Preco:= ROUND(POSICIONE("SB2",1,XFILIAL("SB2")+SG1T->COD_COMP+ _cLocal,"B2_CM1"),2)
                        AAdd(aBOM,{SG1T->COD_COMP,(SG1T->QTD*nQtd),iif(Preco>0,Preco,0.01)})
                        DBSkip()
                    Enddo

                EndIf


                dbSelectArea("SG1T")
                dbcloseArea()
            else
                Alert("Estrutura não encontrada !")
            ENDIF

Return (aBOM)

******************************************************************************************************************************************************
Static Function sfCarregaBom(oModel,oView)
******************************************************************************************************************************************************
local oModelGrid := nil
Local nx
Local aLista := {}
Local _aProd:={}
Local nOpc := oModel:GetOperation()

    IF (nOpc == MODEL_OPERATION_UPDATE) .OR. (nOpc == MODEL_OPERATION_INSERT)

    oModelGrid := oModel:GetModel( "ZT4DETAIL" ) // obtener el modelo del grid
    /* para apagar linhas
    for nX := 1 to oModelGrid:Length()
    oModelGrid:GoLine(nX)
    oModelGrid:DeleteLine()
    next

    oView:Refresh()
    */

    // Carrega a Tela de Selecao
    _aProd:=u_fBOM()
    IF LEN(_aProd)>0
        aLista:=sfVldEstrut(_aProd[1,1],_aProd[1,2])
        IF len(aLista)>0
            for nX := 1 to len(aLista)
             
                oModelGrid:AddLine()
                oModelGrid:SetValue("ZT4_COD", aLista[nX,1] )
                IF aLista[nX,2]>0.01
                    oModelGrid:SetValue("ZT4_QTDSOL",aLista[nX,2])
                else
                    oModelGrid:SetValue("ZT4_QTDSOL",0.01)
                endif
                    
                oModelGrid:SetValue("ZT4_PRCUNI",aLista[nX,3])
            next

            oModelGrid:SetLine(1)
            oView:Refresh()
            MSGINFO( _aProd[1,1] + " Lista importada !"   )

        ENDIF
    ELSE 
     Alert("Arquivo Vazio / Sem Estrutura! ")
    ENDIF
    ELSE
        Alert("Modo : Somente Leitura !")
    END

RETURN




******************************************************************************************************************************************************
User Function fSaldoZT4(_cCod,_nQtd)
******************************************************************************************************************************************************
    Local lRet:=.F.
    Local nSaldo:= 0

    
    IF Posicione("SB1",1,xfilial("SB1")+ _cCod,"B1_TIPO") $ "MC-SV"
        lRet:=.T.
    ELSE
/*
        DbSelectArea("SB2")
        SB2->(DbSetOrder(1))
        If SB2->( MsSeek(xFilial("SB2") + _cCod))
            WHILE  SB2->B2_LOCAL $ "01-05-11-14-17" .AND. !SB2->(eof())
                IF SB2->B2_QATU>0
                    nSaldo += (SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QEMP)
                END
                SB2->(DBSKIP())
            ENDDO

*/
/* saldo disponivel */
//SELECT isnull(SUM(B2_QATU - B2_RESERVA-B2_QEMP),0) AS SALDO_DISP FROM %Table:SB2% WHERE B2_FILIAL='01' 
            cAliasSB2:= GetNextAlias()
            BeginSql Alias cAliasSB2  
            SELECT isnull(SUM(B2_QATU - B2_RESERVA),0) AS SALDO_DISP FROM %Table:SB2% WHERE B2_FILIAL='01' 
            AND B2_COD=%exp:_cCod%  AND B2_LOCAL IN ('01','05','11','14','17','89')
            AND D_E_L_E_T_='' 
            EndSql 
            dbSelectArea(cAliasSB2)  
            dbgotop()
            nSaldo+=(cAliasSB2)->SALDO_DISP
            dbSelectArea(cAliasSB2) 
            dbclosearea()

        IF nSaldo == 0 
            Alert("Dados inválidos" + " Produto não localizado/Sem Saldo.")
            RETURN(.F.)
        ELSEIF nSaldo>= _nQtd
            lRet:=.T.
        ELSE
            Alert(_cCod + " com saldo insuficiente "+  " Qtd. Disponivel :" + Transform(nSaldo, "@R 999999.99") )
        ENDIF
    ENDIF

RETURN(lRet)

******************************************************************************************************************************************************
USER FUNCTION fNRDZ(_nOpc)
******************************************************************************************************************************************************
    Local _cRetorno:=" "
    IF  _nOpc==0

        IF ALLTRIM(ZT3->ZT3_TIPO)=="N"
            _cRetorno := Posicione("SA1",1,xFilial("SA1")+ZT3->ZT3_CODCF+ZT3->ZT3_LOJA,"SA1->A1_NOME")
        Else
            _cRetorno := Posicione("SA2",1,xFilial("SA2")+ZT3->ZT3_CODCF+ZT3->ZT3_LOJA,"SA2->A2_NREDUZ")
        ENDIF
    ELSE
        IF     ALLTRIM(M->ZT3_TIPO)=="N"
            If _nOpc==1
                _cRetorno := Posicione("SA1",1,xFilial("SA1")+M->ZT3_CODCF+M->ZT3_LOJA,"SA1->A1_NREDUZ")
            Else
                _cRetorno := Posicione("SA1",1,xFilial("SA1")+M->ZT3_CODCF+M->ZT3_LOJA,"SA1->A1_END")
            ENDIF
        Else
            If _nOpc==1
                _cRetorno := Posicione("SA2",1,xFilial("SA2")+M->ZT3_CODCF+M->ZT3_LOJA,"SA2->A2_NREDUZ")
            Else
                _cRetorno := Posicione("SA2",1,xFilial("SA2")+M->ZT3_CODCF+M->ZT3_LOJA,"SA2->A2_END")
            ENDIF

        Endif
    ENDIF

//ALERT(_cRetorno)

Return _cRetorno




******************************************************************************************************************************************************
Static Function fSave(oModel)
******************************************************************************************************************************************************
Local lRet := .T.
Local nOpc := oModel:GetOperation()
Local lEmail:=.F.
Local oGrid := oModel:GetModel("ZT4DETAIL")
Local cAliasZT4:= GetNextAlias()

   
     lRet := FWFormCommit( oModel /**/,;
                                /*[ bBefore ]*/,;
                                /*[ bAfter ]*/,;
                                /*[ bAfterSTTS ]*/,;
                                /**/,;
                                /*[ bABeforeTTS ]*/,;
                                /* */ )
    If(lRet)
       
        If(nOpc == MODEL_OPERATION_UPDATE)
        
        If MsgYesNo("Deseja Enviar o E-mail ?")
            lEmail:=U_fEmailSenf(M->ZT3_NUM,"*Alteração*")
        EndIf

           
            IF lEmail
                MSGINFO( 'E-mail enviado com Sucesso.', "SENF - Eletronica" )    
            ELSE
                ALERT('Erro ao enviar o E-mail')
            ENDIF         
        Endif

        If(nOpc == MODEL_OPERATION_INSERT) 
         
            //MUDAR STATUS SE TIVER PA/PI/MP/EM

            If(!fMovEst(oGrid) .and. M->ZT3_STATUS=='1' ) 
               RecLock('ZT3',.F.)
               ZT3->ZT3_STATUS := '3'
               //ATUALIZAR PESO E VOLUME
                     cAliasZT4:= GetNextAlias()
                    BeginSql Alias cAliasZT4 
                        SELECT 
                        SUM(ZT4_QTDSOL*B1_PESBRU) PBRUTO,
                        SUM(ZT4_QTDSOL*B1_PESO) PLIQUID,
                        SUM(CEILING(ZT4_QTDSOL/IIF(ISNULL(B1_QE,0)=0,ZT4_QTDSOL,B1_QE))) TVOLUME 
                        
                        FROM ZT4010 ZT4
                        INNER JOIN SB1010 SB1
                        ON B1_COD=ZT4_COD
                        WHERE 
                        ZT4_NUMSF=%exp:M->ZT3_NUM%  
                        AND ZT4.D_E_L_E_T_='' 
                        EndSql 
                    dbSelectArea(cAliasZT4)  
                    dbgotop()
                    ZT3->ZT3_PBRUTO:=(cAliasZT4)->PBRUTO
                    ZT3->ZT3_PLIQUI:=(cAliasZT4)->PLIQUID
                    ZT3->ZT3_VOLUME:=(cAliasZT4)->TVOLUME
                    dbSelectArea(cAliasZT4) 
                    dbclosearea()
               ZT3->(MsUnlock())
               
            ELSE
                IF M->ZT3_STATUS=='1'
                     MSGINFO( 'Produto movimenta estoque, A liberação ocorrerá pela expedição !', 'SENF - Controle de Estoque' )   
                    //ATUALIZAR PESO E VOLUME
                    cAliasZT4:= GetNextAlias()
                    BeginSql Alias cAliasZT4 
                        SELECT 
                        SUM(ZT4_QTDSOL*B1_PESBRU) PBRUTO,
                        SUM(ZT4_QTDSOL*B1_PESO) PLIQUID,
                        SUM(CEILING(ZT4_QTDSOL/IIF(ISNULL(B1_QE,0)=0,ZT4_QTDSOL,B1_QE))) TVOLUME 
                        
                        FROM ZT4010 ZT4
                        INNER JOIN SB1010 SB1
                        ON B1_COD=ZT4_COD
                        WHERE 
                        ZT4_NUMSF=%exp:M->ZT3_NUM%  
                        AND ZT4.D_E_L_E_T_='' 
                        EndSql 
                    dbSelectArea(cAliasZT4)  
                    dbgotop()
                    RecLock('ZT3',.F.)
                    ZT3->ZT3_PBRUTO:=(cAliasZT4)->PBRUTO
                    ZT3->ZT3_PLIQUI:=(cAliasZT4)->PLIQUID
                    ZT3->ZT3_VOLUME:=(cAliasZT4)->TVOLUME
                    ZT3->(MsUnlock())
                   
                    dbSelectArea(cAliasZT4) 
                    dbclosearea()

                ENDIF
            Endif

  
            //If MsgYesNo("Deseja Enviar o E-mail ?")
		     lEmail:=U_fEmailSenf(M->ZT3_NUM,"*Solicitação*")
            //EndIf

            IF lEmail
                MSGINFO( 'E-mail enviado com Sucesso.', "SENF - Eletronica" )    
            ELSE
                ALERT('Erro ao enviar o E-mail')
            ENDIF
			     
        Endif
    else
      Alert("Registro não foi Salvo")  
    Endif
      



Return(lRet)



******************************************************************************************************************************************************
User Function fCONSCF()
******************************************************************************************************************************************************
Local _lRet := .F.
static c_CODCLI,c_LOJACLI  

If M->ZT3_TIPO <> "N"
     _lRet := ConPad1(,,,"SA2","A2_COD",,.F. )
              
    If _lRet
        c_CODCLI := ALLTRIM(SA2->A2_COD)    
        c_LOJACLI := SA2->A2_LOJA 
         
    EndiF              
Else
     _lRet := ConPad1(,,,"SA1","A1_COD",,.F. )
              
    If _lRet
         c_CODCLI := ALLTRIM(SA1->A1_COD)
         c_LOJACLI := SA1->A1_LOJA
         
    EndiF    
EndIf
Return _lRet

******************************************************************************************************************************************************
Static Function fLinOK(oGrid)
******************************************************************************************************************************************************
//Local nX
Local oModel      := FwModelActive()
Local _cProd,_codTab
Local nSol,nQE,nVrlTot  :=0
Local _cMovEst:= oModel:GetValue('ZT3MASTER','ZT3_MOVEST')

    oGrid:GoLine(oGrid:nLine)

    If Empty(oGrid:GetValue('ZT4_DESC'))
        Help(,,'Descrição em Branco',,'',1,0,,,,,,{'Por favor, Preencher o campo corretamente.'})
        Return .F.
    Endif

    _cProd:=oGrid:GetValue('ZT4_COD')
    nSol:=oGrid:GetValue('ZT4_QTDSOL')
    nVrlTot:=oGrid:GetValue('ZT4_VALOR')
    //cTipo:=alltrim(POSICIONE("SB1",1,XFILIAL("SB1")+cProd,"B1_TIPO"))
      

    If _cMovEst<>'N'
        IF !U_fSaldoZT4(_cProd,nSol) 
            Help(,,'Não é permitida inclusão do Produto, sem Saldo.',,'',1,0,,,,,,{'Por favor, Verifique o Saldo Disponivel.'})
            Return .F.
        ENDIF
    Endif

	if alltrim(POSICIONE("SB1",1,XFILIAL("SB1")+_cProd,"B1_TIPO")) =='PA'
	        nQE:= POSICIONE("SB1",1,XFILIAL("SB1")+ _cProd,'B1_QE')
		   	IF nSol % nQE <>0
                MSGINFO( "Quantidade por Embalagem fora do Padrão, Qtd/Embalagem ( "+Transform(nQE, "@ 999999.99")+" )" , "Atenção - Aviso" )				
			endif

    Endif

   //nVrlFinal    := nVrlFinal + nVrlTot
   //ALERT(STR(nVrlFinal ))
  //CARREGAR VOLUME
  //oModel:SetValue('ZT3MASTER','ZT3_VOLUME',oModel:GetValue('ZT3MASTER','ZT3_VOLUME') + nVolTot)   
/*

    oModel:SetValue('ZT3MASTER','ZT3_VOLUME',nValTot)
    oModel:SetValue('ModelHead','ZKA_SALATU',oModel:GetValue('ModelHead','ZKA_SALANT') + nValTot)
*/
Return .T.

******************************************************************************************************************************************************
Static Function fMovEst(oGrid)
******************************************************************************************************************************************************
Local nX
Local oModel      := FwModelActive()
Local cProd,cTipo
Local lMovest :=.F.
Local _cMovEst:= oModel:GetValue('ZT3MASTER','ZT3_MOVEST')

If _cMovEst<>'N'    
    For nX := 1 To oGrid:GetQtdLine()

        oGrid:GoLine(nX)

        cProd:=oGrid:GetValue('ZT4_COD')
        cTipo:=POSICIONE("SB1",1,XFILIAL("SB1")+cProd,"B1_TIPO")

        If(!oGrid:IsDeleted())
            If  cTipo $ "PA-PI-MP-EM"
		       lMovest :=.T.
	        ENDIF
        Endif

    Next
ENDIF
    

Return lMovest



******************************************************************************************************************************************************
User Function fSepMat()
******************************************************************************************************************************************************

	If MsgYesNo("Confirma Separação de materiais?", "SENF - Eletronica" )
				Processa({||AltStatus("2")},"SENF - Eletronica" ,"Processando Documento, aguarde...")
			ENDIF	
Return(.T.)		
******************************************************************************************************************************************************
User Function fRepSenf()
******************************************************************************************************************************************************
Local oError := ErrorBlock({|e|ChecErro(e)}) //Para exibir um erro mais amigável
Local cRetorno := ""
IF !ZT3->ZT3_STATUS $ ("4-5")


	If MsgYesNo("Excluir / Reprovar documento ?", "SENF - Eletronica" )
        cRetorno := FWInputBox("Informe o Motivo", "")
        ErrorBlock(oError)
	    Processa({||AltStatus("5",cRetorno)},"SENF - Eletronica" ,"Processando Documento, aguarde...")
	ENDIF	
ELSE
  ALERT("Não é possível reprovar/cancelar documento já processado !")
ENDIF
Return(.T.)		




******************************************************************************************************************************************************
Static Function AltStatus(cStatus,cRetorno)
******************************************************************************************************************************************************
	IF cStatus="5"
				RecLock("ZT3",.F.) 
					ZT3->ZT3_STATUS :="5"
					ZT3->ZT3_OBS :="Rep. por " + UsrRetName(RetCodUsr())+ ", Motivo : " + cRetorno
				MsUnLock() 
                If MsgYesNo("Deseja Enviar o E-mail ?")
				    lEmail:=U_fEmailSenf(ZT3->ZT3_NUM,"*Reprovado/Cancelado*")
                
					IF lEmail
					MSGINFO( 'E-mail enviado com Sucesso.', "SENF - Eletronica" )    
					ELSE
						ALERT('Erro ao enviar o E-mail')											
					ENDIF                       
                endif
		
		
	elseif  cStatus="2"
					RecLock("ZT3",.F.) 
					 ZT3->ZT3_STATUS :="2"
					MsUnLock() 

				lEmail:=U_fEmailSenf(ZT3->ZT3_NUM,"*Proc.Expedicao*")
					IF lEmail
						MSGINFO( 'E-mail enviado com Sucesso.',"SENF - Eletronica")    
					ELSE
						ALERT('Erro ao enviar o E-mail')											
					ENDIF        
	else
		
		
		ALERT('Verifique o Status do Registro, não foi Atendido/Aprovado')
	EndIf
return
