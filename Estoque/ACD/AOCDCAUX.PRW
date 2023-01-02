/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦  AOCDCAUX  ¦ Autor ¦ Edson P. S. Sales    ¦ Data ¦ 25/07/2022 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦  Rotina para cria Pick-List de produtos - antes de gerar SENF  ¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

#INCLUDE 'RWMAKE.CH'    
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APVT100.CH'   

/*/{Protheus.doc} User Function AOCDCAUX
Função Documento Auxiliar / via ACD
@author Edson  --  since 13/07/2022
/*/

******************************************************************************************************************************************************
User Function AOCDCAUX()
******************************************************************************************************************************************************
   Local nOpc
   PRIVATE lNovo:=.T.

    CHKFILE('ZT8')
    CHKFILE('ZT9')   

	VTCLear()
	@ 0,6 VTSay PadR('---SENF AUXILIAR---' , VTMaxCol())
	@ 1,0 VTSay PadR('Selecione Tipo de Operacao' , VTMaxCol())
	nOpc:=VTaChoice(2,0,4,VTMaxCol(),{'Novo','Alterar','Consultar'})
	VtClearBuffer()

    If nOpc == 1
        lNovo:=.T.
        fNovoDoc()
    elseif nOpc == 2
        lNovo:=.F.
        fAlteDoc()
    elseif nOpc == 3
        fConsDoc()
    EndIf
    
Return 

/*/{Protheus.doc} User Function fNovoDoc
Função para criar um novo documento via ACD
@author Edson  --  since 13/07/2022
/*/

******************************************************************************************************************************************************
Static Function fNovoDoc()
******************************************************************************************************************************************************
    Local cCodSerie
    Local aTela
    local cNumDoc := GetSXENum("ZT8", "ZT8_DOC")
    Private lNovoDoc := lNovo
    

    While !VTLastkey() == 27 // enquanto não apertar (ESC) ficar na tela para bipar
        cCodSerie := Space(15)

        VTClear()
        VTSave Screen To aTela

        @ 00,04 VTSay PadR('---NOVO DOCUMENTO---' , VTMaxCol())
        @ 01,00 VTSay PadR('Doc.: ', VTMaxCol())
        @ 01,07 VTSay cNumDoc  Pict '@!'
        @ 02,00 VTSay PadR('Cod.: ' , VTMaxCol())
        @ 02,07 VTGet cCodSerie  Pict '@!' VALID !Empty(cCodSerie) .and. fGravDoc(cCodSerie,cNumDoc)
        
        VTRead
        VTRestore Screen FROM aTela
    endDo

Return 

/*/{Protheus.doc} Static Function fvalida
Validar o codigo se existe e se não conta em algum documento.
@author Edson  --  since 13/07/2022
/*/

Static Function fGravDoc(cCodSerie,cNumDoc)
Local lGrava:=.T.
Local lErro:=.F.
Local lExcluiu := .F.
Local cResult  := u_AOCAPISF(cCodSerie)
Local nNumItem 
Local nX,nY,nZ
Local  oResCod,oEmbalag,oItens 
Local cCodPro,cCodCxMst,cItem,cQryPro
Local cTmp:= GetNextAlias()
Local cQueryAlias :=""
Local cProd:= GetNextAlias()
Local aCodEtiq  := {}
Local aLacre    := {}
Local aEtiqueta := {}


    oResult := JSonObject():New()
    oResult:fromJson(cResult)

    cErr   := oResult:GetJSonObject('errors')
    
    If !empty(cErr)
        cErro := cErr[1]:GetJSonObject('description')
        MsgStop(cErro,"ATENCAO!!!!!!")
        lErro:=.T.
        Return lErro
    Endif

    // if Len(alltrim(cCodSerie)) == 10 .or. Len(alltrim(cCodSerie)) == 12

    If Len(alltrim(cCodSerie)) == 12 .and. SubStr(cCodSerie, 1,2) == 'CX' // se for caixa master, trazer todas as etiquetas vinculadas
        oResCod     := oResult:GetJSonObject('result')
        oItens      := oResCod:GetJSonObject('itens')

        cCodPro     := oResCod:GetJSonObject('codProduto')
        cNumOP      := SUBSTR(oResCod:GetJSonObject('numOP'),4,11)

        for nY := 1 to LEN(oItens)
            oPeca :=oItens[nY]:GetJSonObject('peca')
            oFilho := oPeca:GetJSonObject('filhos')

            AAdd(aLacre , oFilho[1]:GetJSonObject('etiqueta'))

            AAdd(aCodEtiq, oItens[nY]:GetJSonObject('etiqueta'))

        next nY

    else   // se for serie unitaria 
        oResCod     := oResult:GetJSonObject('result')
        oFilho      := oResCod:GetJSonObject('filhos')
        oEmbalag    := oResCod:GetJSonObject('embalagem')
        cNumOP      := SUBSTR(oResCod:GetJSonObject('numOP'),4,11)

        AADD(aEtiqueta, oResCod:GetJSonObject('etiqueta'))
        //AADD(aCodPai  , oFilho[1]:GetJSonObject('codPai'))
        AADD(aLacre   , oFilho[1]:GetJSonObject('etiqueta'))
        
        
        //if Empty(aCodPai[1]) 
        AAdd(aCodEtiq,aEtiqueta[1])
        //Else
         //  AAdd(aCodEtiq,aLacre[1])
        //EndIf

        cCodPro     := oResCod:GetJSonObject('codProduto')
        cCodCxMst   := oEmbalag:GetJSonObject('numero')

    EndIf
        //verifica se exite saldo no endereço
        cQryPro := " SELECT  ISNULL(COUNT(*),0) saldo from " +RETSQLNAME('SBF') + " SBF  (NOLOCK) "
        cQryPro += " WHERE BF_QUANT >0 AND BF_LOCAL='01' AND BF_PRODUTO='"+cCodPro+"'"
        cQryPro += " AND D_E_L_E_T_='' "

        cQryPro := ChangeQuery(cQryPro)
        dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQryPro),cProd, .T., .F.)

        DbSelectArea(cProd)

        DbSelectArea('ZT9')
        DbSetOrder(1)
       // ZT9->(MsSeek(FWFilial('ZT9') + cNumDoc ))
        
        for nZ := 1 to lEN(aCodEtiq)
            
            //consulta o produto na zt9, pra ver se ja consta em algum documento ou ate mesmo se ja foi bipado no atual.
            cQueryAlias+="    SELECT ISNULL(COUNT(*),0) CODZT9, ZT9_DOCAUX FROM " + RETSQLNAME('ZT9')+  " ZT9 (NOLOCK) "
            cQueryAlias+="    WHERE D_E_L_E_T_='' AND ZT9_QRCODE = '" + aCodEtiq[Nz] + "'"
            cQueryAlias+="    GROUP BY ZT9_DOCAUX "

            cQueryAlias:= ChangeQuery(cQueryAlias)
            dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryAlias),cTmp, .T., .F.)

            
            if (cProd)->saldo > 0 // se maior que zero tem saldo endereco separacao
                                          //while !ZT9->(EOF())         // PECORRER A ZT9 E PROCURAR ESSE PRODUTO EM ALGUM DOCUMENTO.
                DbSelectArea(cTmp)

                If (cTmp)->(CODZT9) > 0     //aCodEtiq[nZ] == ALLTRIM(ZT9->ZT9_QRCODE) // Se encontrar cancela a operação com ROLLBACK().
                    
                    If lNovoDoc                                     // Se for um novo documento sai e não grava.
                        VtAlert('O código '+ aCodEtiq[nZ] +', já existe no documento '+(cTmp)->ZT9_DOCAUX, 'ATENCAO!!!', .T.)
                        //RollBackSX8()
                        lGrava:=.F.
                        Return
                        exit
                    Else                                             // Se é uma alteração pergunta se quer excluir.
                        if cNumDoc == (cTmp)->ZT9_DOCAUX
                            VtAlert('O código '+ aCodEtiq[nZ] +', já existe neste documento: '+(cTmp)->ZT9_DOCAUX, 'ATENCAO!!!', .T.)
                            lExcluiu := fExcluir(cCodSerie,cNumDoc)
                            If lExcluiu
                                VTAlert('Item excluido com sucesso',"EXCLUIDO!!!",.T.)
                                lGrava:=.F.
                                Return 
                            else
                                VTAlert("Nenhuma alteração foi feita ","AVISO!!!",.T.)
                                Return 
                                exit
                            EndIf
                        else
                            VtAlert('O código '+ aCodEtiq[nZ] +', já existe em outro DOC: '+(cTmp)->ZT9_DOCAUX, 'ATENCAO!!!', .T.)
                        EndIf
                        exit
                    EndIf
                EndIf

                lGrava:=.T. // segui para gravar o registro
                        //ZT9->(dbSkip())
                   // Enddo
                //EndIf
                //ZT9->( dbGoTop() )
            else
                VTAlert('Esse produto não tem saldo no endereco SEPARACAO.','ATENCAO!!!',.T.)
                Return .F.
            EndIf
           
        (cTmp)->(dbCloseArea())
        Next nZ
        (cProd)->(DBCLOSEAREA())
        ZT9->(DBCLOSEAREA())
        Begin Transaction
            If lGrava 
                
                //Perguntando se deseja confirmar esse código, para confirmar e atualizar as tabelas SXE / SXF
                If .T.//MsgYesNo("Deseja confirmar o código "+cCodSerie+" para o Doc "+cNumDoc +" ?", "Atenção")
                    
                    DbSelectArea('ZT8')

                    If lNovo
                        RecLock('ZT8',.T.)
                            ZT8->ZT8_FILIAL := FWFILIAL('ZT8')
                            ZT8->ZT8_DOC     := cNumDoc
                            ZT8->ZT8_SENF    := ''
                            ZT8->ZT8_DATA    := DATE() 
                            ZT8->ZT8_NFISC   := ''
                            ZT8->ZT8_SERIE   := ''
                            ZT8->ZT8_OBS     := ""
                            ZT8->ZT8_STATUS  := ""//  1- Gerado senf  >> (criar rotina de retorno e mudar o status para 2)

                        MsUnlock()

                        ConfirmSX8()
                        lNovo:=.F.

                    EndIf
                    ZT8->(DBCLOSEAREA())
                    
                    DbSelectArea('ZT9')

                    cItem       :=fAdItem(cNumDoc) //Retorna o ultimo item do documento ou vazio.
                    nNumItem    :=IIF(alltrim(cItem)=='',1,VAL(cItem)+1) // se vazio inicia em 1, se retorna ultimo + 1.

                    for nX := 1 to lEN(aCodEtiq)
                        
                        RecLock('ZT9', .T.)
                            ZT9->ZT9_FILIAL      := FWFILIAL('ZT9')
                            ZT9->ZT9_DOCAUX      := cNumDoc
                            ZT9->ZT9_ITEM        := StrZero(nNumItem++,6)  // Soma o ultimo item + 1.
                            ZT9->ZT9_DATA        := DDATABASE //DTOS(DATE()) //oficial
                            //ZT9->ZT9_DATA        := DATE()  //TM_VAL
                            ZT9->ZT9_QRCODE      := aCodEtiq[nX]
                            ZT9_LACRE            := aLacre[nx]    
                            ZT9->ZT9_CXCOLE      := IIF(SubStr(cCodSerie, 1,2)=='CX',cCodSerie,cCodCxMst) 
                            ZT9->ZT9_CODPRO      := cCodPro // Codigo do produto
                            ZT9->ZT9_USUARIO     := UsrRetName(__cUserID)//UsrRetName()
                            ZT9->ZT9_NUMOP       := cNumOP

                        MsUnlock()

                    next nX

                    ZT9->(DBCLOSEAREA())
                    VTbeep(1)

                    //VtAlert('Codigo '+cCodSerie+' Gravado com sucesso no Documento '+cNumDoc,'Sucesso',.T.,2000)

                    //Senão, volta a numeração onde estava    
                Else
                    RollBackSX8()
                    VtAlert('Nenhum documento foi Gerado','ATENCAO!!!',.T.)
                EndIf
            Else
                RollBackSX8()
            EndIf

        End Transaction
 
    // else
    //     VtAlert('Código Inválido !!!','Atenção',.T.)
    // endIf
Return lGrava

/*
Consultar qual o Ultimo item gerado no documento
*/
******************************************************************************************************************************************************
Static Function fAdItem(cNumDoc)
*********************************************************************************************************************************************************************************************************************
    Local   cItem  := GetNextAlias()
    Local   cNumItem
    Local   cQry  := "SELECT MAX(ZT9_ITEM) ITEM FROM " + RetSqlName('ZT9') + " ZT9  (NOLOCK) "
            cQry  += " WHERE  ZT9_DOCAUX = '" + cNumDoc +"' AND D_E_L_E_T_='' "

    cQry := ChangeQuery(cQry)
    dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cItem, .T., .F.)
    dbSelectArea(cItem)
    if Empty((cItem)->ITEM)
        return (cItem)->ITEM  // se for o 1° item de um novo documento retorna vazio. 
    else
        cNumItem := (cItem)->ITEM
        Return cNumItem  // se o documento ja tiver iniciado retona o ultimo item gravado
    endif
    (cItem)->(dbCloseArea())
Return 

/*/{Protheus.doc} User Function AOCDOCAUX
Função Para altera um documento ou excluir incluir / via ACD
@author Edson  --  since 13/07/2022
/*/

******************************************************************************************************************************************************
Static Function fAlteDoc()
******************************************************************************************************************************************************
    Local cNumDoc   := Space(6)     
    Local cCodSerie     
    Local aTela
    
    While !VTLastkey() == 27 // enquanto não apertar (ESC) ficar na tela para bipar    // matr105  -- posição das saas  
        cCodSerie     := Space(12)
        lNovo := .F.
        lNovoDoc := lNovo
        VTClear()
        VTSave Screen To aTela
        @ 00,02 VTSay PadR('---ALTERAR DOCUMENTO---' , VTMaxCol())
        @ 01,00 VTSay PadR('Doc.: ', VTMaxCol())
        @ 02,00 VTSay PadR('Cod.: ' , VTMaxCol())
        if Empty(cNumDoc)
            @ 01,07 VTGet cNumDoc  Pict '@!' VALID !Empty(cNumDoc) .and. fValDoc(cNumDoc)
        else
            @ 01,07 VTSay cNumDoc  Pict '@!' //VALID !Empty(cNumDoc) .and. fValDoc(cNumDoc)
        EndIf
        @ 02,07 VTGet cCodSerie  Pict '@!' VALID !Empty(cCodSerie) .and. fGravDoc(cCodSerie,cNumDoc)
            
        VTRead
        VTRestore Screen FROM aTela
        
    EndDo
    
Return 

/*/ {Protheus.doc} fConsulta()  Consultar saldo dos produtos no Documentos /*/

Static Function fConsDoc()
	Local cQryD :=''
	Local nPi :=2
    Local cSaldo :=GetNextAlias()
    Local cDoc
    Local aTela

    //While !VTLastkey() == 27 // enquanto não apertar (ESC) ficar na tela para bipar
        cDoc := Space(06)

        VTClear()
        VTSave Screen To aTela

        @ 00,04 VTSay PadR('---CONFERIDO---' , VTMaxCol())
        @ 01,00 VTSay PadR('Doc.: ', VTMaxCol())
        @ 01,07 VTGet cDoc  Pict '@!' VALID !Empty(cDoc) .and. fValDoc(cDoc)

        VTRead
        VTRestore Screen FROM aTela

	If !Empty(cDoc)

        cQryD += " SELECT COUNT(*) QUANT,ZT9.ZT9_CODPRO PROD FROM " + RetSqlName('ZT9') + " ZT9  (NOLOCK) "
        cQryD += "  WHERE ZT9.ZT9_DOCAUX = '" +cDoc+"'" + " AND ZT9.D_E_L_E_T_ ='' "
        cQryD += "  GROUP BY ZT9.ZT9_CODPRO "

        cQryD := ChangeQuery(cQryD)
        dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQryD),cSaldo, .T., .F.)
        
        DbSelectArea(cSaldo)
        VTClear()
        @ 00,04 VTSay PadR('---RESUMO DOC '+cDoc+'---' , VTMaxCol())
        @ 01,00 VTSay "CODIGO" 
        @ 01,16 VTSay "|" 
        @ 01,18 VTSay  'QUANT'
        @ 02,00 VTSay '---------------------------'

        while !(cSaldo)->(EoF())
            nPi++
            @ nPi,00 VTSay (cSaldo)->(PROD) Pict "@9999.99"
            @ nPi,16 VTSay "|"
            @ nPi,18 VTSay (cSaldo)->(QUANT) Pict "@9999.99"
            
            (cSaldo)->(dbSkip())
            
        endDo
        VTPause
	    (cSaldo)->(dbCloseArea())
    EndIf 

Return 

/*
    Validar se o documento existe
*/
******************************************************************************************************************************************************
Static Function fValDoc(cNumDoc)
*********************************************************************************************************************************************************************************************************************
    Local   cAliasDoc  := GetNextAlias()
    Local   lDoc :=.F.
    Local   cQry  := "SELECT ZT9.ZT9_DOCAUX DOC FROM " + RetSqlName('ZT9') + " ZT9  (NOLOCK) "
            cQry  += " WHERE  ZT9_DOCAUX = '" + cNumDoc +"' AND D_E_L_E_T_=''"

    cQry := ChangeQuery(cQry)
    dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasDoc, .T., .F.)
    dbSelectArea(cAliasDoc)

    DbSelectArea('ZT8')
    ZT8->(MsSeek(FWFilial('ZT8') + cNumDoc ))

    if Empty((cAliasDoc)->DOC)

        VTAlert('Documento informado nao existe!!!',"ATENCAO!!!",.T.)  

    elseif  ZT8_STATUS=='1' // 1 = documento ja processado/Senf Gerada

        VTAlert('Documento informado já foi Processado!!!',"ATENCAO!!!",.T.)

    else
        lDoc := .T.
    endif
   (cAliasDoc)->(dbCloseArea())
   ZT8->(dbCloseArea())
Return lDoc

/*/
{Protheus.doc} Excluir um item da TABELA ZT9
/*/
Static Function  fExcluir(cCodSerie,cNumDoc)

    //Local   cAliasDoc  := GetNextAlias()
    Local lExclui   :=.F.
    Local lRet      := .F.

    If (lRet:=DLVTAviso('', 'Deseja Excluir item do documento ?', {'Sim', 'Nao'})==1)//MsgYesNo('Deseja Excluir ?', "ATENCAO!!!!!!")
    
        DbSelectArea('ZT9')
        DbSetOrder(2)
        If ZT9->(MsSeek(FWFilial('ZT9') + cNumDoc + cCodSerie))
        //If ZT9->(MsSeek(FWFilial('ZT9') + cNumDoc ))
            while !ZT9->(EOF()) .and. ZT9->(ZT9_FILIAL+ ZT9_DOCAUX+ALLTRIM(ZT9_CXCOLE))== FWFILIAL('ZT9')+cNumDoc+ALLTRIM(cCodSerie)
            //while !ZT9->(EOF()) .and. ZT9->(ZT9_FILIAL+ZT9_DOCAUX)== FWFILIAL('ZT9')+cNumDoc .and. ALLTRIM(ZT9_CXCOLE)==cCodSerie
                RecLock('ZT9', lExclui)
                    dbDelete()
                MsUnlock() 
                lRet := .T.
            ZT9->(dbSkip())
            EndDo 
        EndIf
    EndIf
    ZT9->(dbCloseArea())
Return  lRet

