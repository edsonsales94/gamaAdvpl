#INCLUDE 'RWMAKE.CH'    
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APVT100.CH'   

/*/{Protheus.doc} User Function A
    /*/
User Function CONSENF()

Local   cQry  := "SELECT MAX(ZT9.ZT9_DOCAUX) DOC FROM " + RetSqlName('ZT9') + " ZT9  (NOLOCK) "
        cQry  += " WHERE  ZT9_DOCAUX = '" + cNumDoc +"' AND D_E_L_E_T_=''"

    While !VTLastkey() == 27 // enquanto não apertar (ESC) ficar na tela para bipar
        cCodSerie := Space(15)

        VTClear()
        VTSave Screen To aTela

        @ 00,04 VTSay PadR('---BUSCAR DOCUMENTO---' , VTMaxCol())
        @ 01,00 VTSay PadR('Doc.: ', VTMaxCol())
        @ 01,07 VTSay cNumDoc  Pict '@!'
        @ 02,00 VTSay PadR('Cod.: ' , VTMaxCol())
        @ 02,07 VTGet cCodSerie  Pict '@!' VALID !Empty(cCodSerie) .and. fGravDoc(cCodSerie,cNumDoc)
        
        VTRead
        VTRestore Screen FROM aTela
    endDo

    VtAlert(VtAlert('consultar o documento.', 'Atencao',.T.))
    
Return 
