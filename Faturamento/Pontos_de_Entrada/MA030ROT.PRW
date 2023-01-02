#Include "Rwmake.ch"
#Include "Protheus.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function       MA030ROT                                                     /@
@type           Ponto de entrada                                             /@
@date           20/02/2009                                                   /@
@description    Adiciona Botoes no Cadastro de Clientes                      /@
@author         Cristiano Figueiroa                                          /@
@use            Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MA030ROT()
Local aRotEsp   :=  {}

//———————————————————————————————————————————————————————————————————————————————
// Monta o Array com as Rotinas Adicionadas ao MBrowse
//———————————————————————————————————————————————————————————————————————————————
aAdd(aRotEsp, {"® Po&litica Comercial", "u_ListPolCom", 0, 2})
//aAdd( aRotEsp , { "Altera Vendedor" , "u_BFATM07", 0 , 2 } )
//———————————————————————————————————————————————————————————————————————————————
// somente módulo financeiro
//———————————————————————————————————————————————————————————————————————————————
if nModulo == 6
    aAdd(aRotEsp, {"® Altera Tipo Vencto",  "U_A_MA030ROT", 0, 2})
    aAdd(aRotEsp, {"® Altera Lim Credito",  "U_B_MA030ROT", 0, 2})
endif

Return(aRotEsp)


/*/
———————————————————————————————————————————————————————————————————————————————
@function       A_MA030ROT                                                   /@
@type           User Function                                                /@
@date           18/01/2021                                                   /@
@description    Altera tipo de vencimento para todos os clientes do grupo    /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function A_MA030ROT()
Local cDescr      := "Esta funcionalidade altera o tipo de vencimento para todos os cadastros que estiverem no mesmo grupo de clientes."
Local aTpVcto     := {"1-Faturamento", "2-Entrega"}
Local cTpVcto     := iif(SA1->A1_XTPVCTO == "1", "2-Entrega", "1-Faturamento")
Local cGrupoCli   := SA1->A1_NOME
Local cVctAtual   := iif(SA1->A1_XTPVCTO $ "1/2", aTpVcto[Val(SA1->A1_XTPVCTO)], "Nao Identificado")
Local oDescr, oGrupoCli, oVctAtual
Private oDlg

//Somente para clientes não exportação, pessoa juridica e que tenta o CNPJ preenchido
if SA1->A1_EST != "EX" .and. SA1->A1_PESSOA == "J" .and. !Empty(SA1->A1_CGC)

    Define MsDialog oDlg Title OemtoAnsi("Manutenção em tipo de vencimento") From 240,230 To 540,760 Pixel

    // Cria Componentes Padroes do Sistema
    @ 002,010 Get oDescr Var cDescr MEMO When .F. Size 250,020 Pixel Of oDlg

    @ 030,010 Say "Grupo" Size 020,008 COLOR CLR_BLACK Pixel Of oDlg
    @ 040,010 MsGet oGrupoCli Var cGrupoCli When .F. Size 250,009 COLOR CLR_BLACK Pixel Of oDlg

    @ 060,010 Say "Do Tipo Vencimento" Size 070,008 COLOR CLR_BLACK Pixel Of oDlg
    @ 060,125 Say "Para o Tipo de Vencimento" Size 070,008 COLOR CLR_RED Pixel Of oDlg
    @ 070,010 MsGet oVctAtual Var cVctAtual When .F. Size 069,009 COLOR CLR_BLACK Pixel Of oDlg
    @ 070,125 ComboBox cTpVcto Items aTpVcto Size 087,010 COLOR CLR_RED Pixel Of oDlg

    @ 120,160 Button OemtoAnsi("Gravar") Size 037,012 Pixel Of oDlg Action(SaveTpVct(.T., SA1->A1_CGC, cTpVcto), oDlg:End())
    @ 120,220 Button OemtoAnsi("Cancelar") Size 037,012 Pixel Of oDlg Action(SaveTpVct(.F.), oDlg:End())

    Activate MsDialog oDlg Centered

else

    Help(" ", 1, "ATENÇÃO",, "Funcionalidade ativa somente para PESSOAS JURIDICAS que não sejam do EXTERIOR e que possuam CNPJ preenchido." + chr(13) + chr(10) + "(Específico " + AllTrim(SM0->M0_NOME) + ") - MA030ROT", 1)

endif

Return()

    /*/
    ———————————————————————————————————————————————————————————————————————————————
    @function       SAVETPVCT                                                    /@
    @type           Static Function                                              /@
    @date           18/01/2021                                                   /@
    @description    Acionado pela função A_MA030ROT, efetua a gravação do tipo
                    de vencimento para todos os clientes de um mesmo grupo       /@
    @author			Adalberto Moreno Batista (Opção Um)                          /@
    @use			Brasitech                                                    /@
    ———————————————————————————————————————————————————————————————————————————————
    /*/
    Static Function SaveTpVct(lContinua, cCNPJ, cTpVcto)
    Local aArea   := GetArea()

    if lContinua

        if MsgYesNo("Confirma a alteração do tipo de vencimento para o grupo de clientes " + AllTrim(SA1->A1_NOME) + "?", "Pergunta")

            SA1->(dbSetOrder(3))            //A1_FILIAL, A1_CGC
            SA1->(dbSeek(xFilial("SA1") + Left(cCNPJ,8)))

            do While SA1->(!Eof() .and. A1_FILIAL == xFilial("SA1") .and. Left(A1_CGC,8) == Left(cCNPJ,8))

                if SA1->A1_PESSOA == "J"
                    SA1->(RecLock("SA1", .F.))
                    SA1->A1_XTPVCTO   := cTpVcto
                    SA1->(MsUnLock())
                    SA1->(dbSkip())
                endif

            enddo

            MsgBox("Tipo de vencimento foi alterado com sucesso para todos os clientes do grupo.", "Informação", "INFO")

        else

            MsgBox("Processo cancelado. Tipo de vencimento não foi alterado.", "Informação", "INFO")

        endif

    endif

    RestArea(aArea)
    Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function       B_MA030ROT                                                   /@
@type           User Function                                                /@
@date           10/02/2021                                                   /@
@description    Altera tipo de vencimento para todos os clientes do grupo    /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function B_MA030ROT()
Local cDescr        := "Esta funcionalidade altera informações de limite de crédito para todos os cadastros que estiverem no mesmo grupo de clientes."
Local cGrupoCli     := SA1->A1_NOME
Local aListaRisco   := {"A", "B", "C", "D", "E", " "}
Local cRisco        := SA1->A1_RISCO
Local aCombo        := {}
Local nLC			:= SA1->A1_LC
Local dVencLC		:= SA1->A1_VENCLC
Local nMoedaLC		:= SA1->A1_MOEDALC
Local oObjLim, nX
Private oDlg

aAdd(aCombo, iif(!Empty(cRisco), cRisco + "-Risco " + cRisco, " "))
for nX := 1 to Len(aListaRisco)
    if cRisco != aListaRisco[nX]
        aAdd(aCombo, iif(!Empty(aListaRisco[nX]), aListaRisco[nX] + "-Risco " + aListaRisco[nX], " "))
    endif
next
 
//Somente para clientes não exportação, pessoa juridica e que tenta o CNPJ preenchido
if SA1->A1_EST != "EX" .and. SA1->A1_PESSOA == "J" .and. !Empty(SA1->A1_CGC)

    Define MsDialog oDlg Title OemtoAnsi("Informações de limite de crédito") From 240,230 To 540,760 Pixel

    // Cria Componentes Padroes do Sistema
    @ 002,010 Get oObjLim Var cDescr MEMO When .F. Size 250,020 Pixel Of oDlg

    @ 030,010 Say "Grupo" Size 020,008 COLOR CLR_BLACK Pixel Of oDlg
    @ 040,010 MsGet oObjLim Var cGrupoCli When .F. Size 250,009 COLOR CLR_BLACK Pixel Of oDlg

    @ 060,010 Say "Risco" Size 030,008 COLOR CLR_BLACK Pixel Of oDlg
    @ 070,010 ComboBox cRisco Items aCombo Valid !empty(cRisco) Size 050,010 COLOR CLR_BLACK Pixel Of oDlg

    @ 060,070+10 Say "Limite Credito" Size 040,008 COLOR CLR_BLACK Pixel Of oDlg
    @ 070,070+10 MsGet oObjLim Var nLC Picture "@E 999,999,999.99" Size 060,010 COLOR CLR_BLACK Pixel Of oDlg

    @ 060,140+20 Say "Vencto Limite" Size 040,008 COLOR CLR_BLACK Pixel Of oDlg
    @ 070,140+20 MsGet oObjLim Var dVencLC Size 040,009 COLOR CLR_BLACK Pixel Of oDlg

    @ 060,190+30 Say "Moeda LC" Size 030,008 COLOR CLR_BLACK Pixel Of oDlg
    @ 070,190+30 MsGet oObjLim Var nMoedaLC Picture "9" Size 030,010 COLOR CLR_BLACK Pixel Of oDlg

    @ 120,160 Button OemtoAnsi("Gravar") Size 037,012 Pixel Of oDlg Action(SaveLimite(.T., SA1->A1_CGC, {cRisco,nLC,dVencLC,nMoedaLC}), oDlg:End())
    @ 120,220 Button OemtoAnsi("Cancelar") Size 037,012 Pixel Of oDlg Action(SaveLimite(.F.), oDlg:End())

    Activate MsDialog oDlg Centered

else

    Help(" ", 1, "ATENÇÃO",, "Funcionalidade ativa somente para PESSOAS JURIDICAS que não sejam do EXTERIOR e que possuam CNPJ preenchido." + chr(13) + chr(10) + "(Específico " + AllTrim(SM0->M0_NOME) + ") - MA030ROT", 1)

endif

Return()

    /*/
    ———————————————————————————————————————————————————————————————————————————————
    @function       SAVELIMITE                                                   /@
    @type           Static Function                                              /@
    @date           18/01/2021                                                   /@
    @description    Acionado pela função A_MA030ROT, efetua a gravação do tipo
                    de vencimento para todos os clientes de um mesmo grupo       /@
    @author			Adalberto Moreno Batista (Opção Um)                          /@
    @use			Brasitech                                                    /@
    ———————————————————————————————————————————————————————————————————————————————
    /*/
    Static Function SaveLimite(lContinua, cCNPJ, aDados)
    Local aArea   := GetArea()

    if lContinua

        if MsgYesNo("Confirma a alteração das informações de limite de crédito para o grupo de clientes " + AllTrim(SA1->A1_NOME) + "?", "Pergunta")

            SA1->(dbSetOrder(3))            //A1_FILIAL, A1_CGC
            SA1->(dbSeek(xFilial("SA1") + Left(cCNPJ,8)))

            do While SA1->(!Eof() .and. A1_FILIAL == xFilial("SA1") .and. Left(A1_CGC,8) == Left(cCNPJ,8))

                if SA1->A1_PESSOA == "J"
                    SA1->(RecLock("SA1", .F.))
                    SA1->A1_RISCO       := aDados[1]
                    SA1->A1_LC          := aDados[2]
                    SA1->A1_VENCLC      := aDados[3]
                    SA1->A1_MOEDALC     := aDados[4]
                    SA1->(MsUnLock())
                    SA1->(dbSkip())
                endif

            enddo

            MsgBox("As informações de limite de crédito foram alteradas com sucesso para todos os clientes do grupo.", "Informação", "INFO")

        else

            MsgBox("Processo cancelado. Informações de limite de crédito não foram alteradas.", "Informação", "INFO")

        endif

    endif

    RestArea(aArea)
    Return()
