/*/{Protheus.doc} User Function XWF677D
    ( Rotina responsavel pelo Reenvio do WF-RDV)
    @type User Function
    @author AOliveira
    @since 07/04/2022
    @version 1.0
/*/
User Function XWF677D()

Local aArea := GetArea()

MsAguarde({|| XPROCESS() },"Processando","Aguarde...")    

RestArea(aArea)

Return


/*/{Protheus.doc} xProcess
    (Executa o processamento)
    @type  Static Function
    @author AOliveira
    @since 07/04/2022
    @version 1.0
/*/
Static Function xProcess()
    
/*
	oBrowse:AddLegend( "FLF_STATUS == '1'", "GREEN"		, STR0002 ) //"Em aberto"
	oBrowse:AddLegend( "FLF_STATUS == '2'", "YELLOW"	, STR0003 ) //"Em conferência sem bloqueio"
	oBrowse:AddLegend( "FLF_STATUS == '3'", "ORANGE"	, STR0004 ) //"Em conferência com bloqueio"
	oBrowse:AddLegend( "FLF_STATUS == '4'", "PINK"		, STR0005 ) //"Em avaliação do gestor"
	oBrowse:AddLegend( "FLF_STATUS == '5'", "BLACK"		, STR0006 ) //"Reprovada"
	oBrowse:AddLegend( "FLF_STATUS == '6'", "BLUE"		, STR0007 ) //"Aprovada"
	oBrowse:AddLegend( "FLF_STATUS == '7'", "RED"		, STR0008 ) //"Em avaliação do financeiro"
	oBrowse:AddLegend( "FLF_STATUS == '8'", "BROWN"		, STR0009 ) //"Finalizada"
	oBrowse:AddLegend( "FLF_STATUS == '9'", "WHITE"		, STR0010 ) //"Faturada"
*/

//Reenvio processo A
If Alltrim(FLF->FLF_STATUS) $ '2|3'

    cLike := Alltrim(FLF->(FLF_FILIAL+FLF_TIPO+FLF_PRESTA))+"%"
    cOrig := 'XWF677A'

    BeginSql Alias "ZZGA"
        SELECT *
        FROM %Table:ZZG%
        WHERE ZZG_FILIAL = %xFilial:ZZG%
        AND ZZG_ORIG = %exp:cOrig%
        AND ZZG_CHAVE LIKE  %exp:cLike%
        AND %NotDel%
    EndSql

    DbSelectArea("ZZG")
    ZZG->( DbSetOrder(1) ) //ZZG_FILIAL+ZZG_CODIGO
    if ZZG->( DbSeek( ZZGA->(ZZG_FILIAL+ZZG_CODIGO) ) )
        RecLock("ZZG",.F.)	
        ZZG->(DbDelete())
        ZZG->(MsUnlock())
    endif

    ZZGA->(DbCloseArea())

    //Verifica se tem processo B e delete 
    cLike := Alltrim(FLF->(FLF_FILIAL+FLF_TIPO+FLF_PRESTA))+"%"
    cOrig := 'XWF677B'

    BeginSql Alias "ZZGB"
        SELECT *
        FROM %Table:ZZG%
        WHERE ZZG_FILIAL = %xFilial:ZZG%
        AND ZZG_ORIG = %exp:cOrig%
        AND ZZG_CHAVE LIKE  %exp:cLike%
        AND %NotDel%
    EndSql

    DbSelectArea("ZZG")
    ZZG->( DbSetOrder(1) ) //ZZG_FILIAL+ZZG_CODIGO
    if ZZG->( DbSeek( ZZGB->(ZZG_FILIAL+ZZG_CODIGO) ) )
        RecLock("ZZG",.F.)	
        ZZG->(DbDelete())
        ZZG->(MsUnlock())
    endif

    ZZGB->(DbCloseArea())    

    //Verifica se tem processo C e Deleta
    cLike := Alltrim(FLF->(FLF_FILIAL+FLF_TIPO+FLF_PRESTA))+"%"
    cOrig := 'XWF677C'

    BeginSql Alias "ZZGC"
        SELECT *
        FROM %Table:ZZG%
        WHERE ZZG_FILIAL = %xFilial:ZZG%
        AND ZZG_ORIG = %exp:cOrig%
        AND ZZG_CHAVE LIKE  %exp:cLike%
        AND %NotDel%
    EndSql

    DbSelectArea("ZZG")
    ZZG->( DbSetOrder(1) ) //ZZG_FILIAL+ZZG_CODIGO
    if ZZG->( DbSeek( ZZGC->(ZZG_FILIAL+ZZG_CODIGO) ) )
        RecLock("ZZG",.F.)	
        ZZG->(DbDelete())
        ZZG->(MsUnlock())
    endif

    ZZGC->(DbCloseArea())    

//Reenvio processo B
ELseIf Alltrim(FLF->FLF_STATUS) $ '4|6'

    cLike := Alltrim(FLF->(FLF_FILIAL+FLF_TIPO+FLF_PRESTA))+"%"
    cOrig := 'XWF677B'

    BeginSql Alias "ZZGB"
        SELECT *
        FROM %Table:ZZG%
        WHERE ZZG_FILIAL = %xFilial:ZZG%
        AND ZZG_ORIG = %exp:cOrig%
        AND ZZG_CHAVE LIKE  %exp:cLike%
        AND %NotDel%
    EndSql

    DbSelectArea("ZZG")
    ZZG->( DbSetOrder(1) ) //ZZG_FILIAL+ZZG_CODIGO
    if ZZG->( DbSeek( ZZGB->(ZZG_FILIAL+ZZG_CODIGO) ) )
        RecLock("ZZG",.F.)	
        ZZG->(DbDelete())
        ZZG->(MsUnlock())
    endif

    ZZGB->(DbCloseArea())

    //Verifica se tem processo C e Deleta
    cLike := Alltrim(FLF->(FLF_FILIAL+FLF_TIPO+FLF_PRESTA))+"%"
    cOrig := 'XWF677C'

    BeginSql Alias "ZZGC"
        SELECT *
        FROM %Table:ZZG%
        WHERE ZZG_FILIAL = %xFilial:ZZG%
        AND ZZG_ORIG = %exp:cOrig%
        AND ZZG_CHAVE LIKE  %exp:cLike%
        AND %NotDel%
    EndSql

    DbSelectArea("ZZG")
    ZZG->( DbSetOrder(1) ) //ZZG_FILIAL+ZZG_CODIGO
    if ZZG->( DbSeek( ZZGC->(ZZG_FILIAL+ZZG_CODIGO) ) )
        RecLock("ZZG",.F.)	
        ZZG->(DbDelete())
        ZZG->(MsUnlock())
    endif

    ZZGC->(DbCloseArea())    

//Reenvio processo C
ELseIf !(Alltrim(FLF->FLF_STATUS) $ '7|8|9')

    cLike := Alltrim(FLF->(FLF_FILIAL+FLF_TIPO+FLF_PRESTA))+"%"
    cOrig := 'XWF677C'

    BeginSql Alias "ZZGC"
        SELECT *
        FROM %Table:ZZG%
        WHERE ZZG_FILIAL = %xFilial:ZZG%
        AND ZZG_ORIG = %exp:cOrig%
        AND ZZG_CHAVE LIKE  %exp:cLike%
        AND %NotDel%
    EndSql

    DbSelectArea("ZZG")
    ZZG->( DbSetOrder(1) ) //ZZG_FILIAL+ZZG_CODIGO
    if ZZG->( DbSeek( ZZGC->(ZZG_FILIAL+ZZG_CODIGO) ) )
        RecLock("ZZG",.F.)	
        ZZG->(DbDelete())
        ZZG->(MsUnlock())
    endif

    ZZGC->(DbCloseArea())

EndIf


Return 
