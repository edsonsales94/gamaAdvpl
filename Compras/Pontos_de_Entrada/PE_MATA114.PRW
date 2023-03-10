#Include "Protheus.ch"
 
/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		MATA114                                                      /@
@date			04/11/2020                                                   /@
@type			Ponto de entrada
@description    P.E. em MVC, utilizado para tratamento no cadastro de grupos
                de aprova鈬o de compras.                                     /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br) Op鈬o Um   /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/ 
User Function MATA114()
Local aParam        := PARAMIXB
Local xRet          := .T.
Local cMsg          := ""
Local cGest1N       := ""
Local cGest2N       := ""
Local cNivelApr     := ""
Local cNivGes1N     := ""
Local cNivGes2N     := ""
Local oObj, cIdPonto, cIdModel, nOperation, oMainModel, oModelPad, oModel, nX,;
      nQtdAprov, nQtdLinhas

If aParam <> NIL
      
    oObj       := aParam[1]
    cIdPonto   := aParam[2]
    cIdModel   := aParam[3]
    nOperation := oObj:GetOperation()
    oMainModel := oObj:GetModel("ModelSAL")
      
    If cIdPonto == 'MODELPOS'
        /*
        Na valida鈬o total do modelo.
        1     O        Objeto do formul疵io ou do modelo, conforme o caso
        2     C        ID do local de execu鈬o do ponto de entrada
        3     C        ID do formul疵io
        Retorno:  Requer um retorno l?gico
        */
    ElseIf cIdPonto == 'FORMPOS' .and. cFilAnt == "03"
        //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
        // Na valida鈬o total do formul疵io.
        // 1     O        Objeto do formul疵io ou do modelo, conforme o caso
        // 2     C        ID do local de execu鈬o do ponto de entrada
        // 3     C        ID do formul疵io
        // Retorno: Requer um retorno l?gico
        //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
        if (nOperation == 3 .or. nOperation == 4)
            oModelPad   := FwModelActive()
            oModel      := oModelPad:GetModel("DetailSAL")
            oMainModel  := oModelPad:GetModel("ModelSAL")
            nQtdLinhas  := oModel:GetQtdLine()

            //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
            // Critica aprovadores, obriga o preenchimento de aprovador superior niveis 1 e 2
            // somente para aprovador
            //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
            nQtdAprov := 0
            For nX := 1 to nQtdLinhas
                oModel:SetLine(nX)

                //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
                // Ignora registros bloqueados
                //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
                if oModel:GetValue("AL_MSBLQL") <> "1"
                
                    //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
                    // Identificando a quantidade de integrantes APROVADOR
                    //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
                    if oModel:GetValue("AL_LIBAPR") == "A"

                        nQtdAprov++
                        if Empty(oModel:GetValue("AL_XRESPON")) .or. Empty(oModel:GetValue("AL_XGEST1N")) .or. Empty(oModel:GetValue("AL_XGEST2N"))
                            xRet        := .F.
                            cMsg        := "Necess疵io informar o Respons疱el, Controller e Gestor Local para APROVADORES."
                        endif
                        cNivelApr   := oModel:GetValue("AL_NIVEL")
                        cRespon     := oModel:GetValue("AL_XRESPON")
                        cGest1N     := oModel:GetValue("AL_XGEST1N")
                        cGest2N     := oModel:GetValue("AL_XGEST2N")

                        // Busca faixa de valores em perfil de aprova鈬o (para o funcionamento, necess疵io que o aprovador pertenca a um perfil de 0,00 ? 99999999,99)
                        DHL->(dbSetOrder(1))    //DHL_FILIAL, DHL_COD
                        if DHL->(dbSeek(xFilial("DHL") + oModel:GetValue("AL_PERFIL")))
                            if DHL->DHL_LIMMIN <= 0 .and. DHL->DHL_LIMMAX >= 99999999999
                            else
                                xRet    := .F.
                                cMsg    := "Um aprovador deve pertencer ? um perfil que abranja todas as aprova鋏es, ou seja Limite M?nimo 0,00 e Liminte M痊imo 99.999.999.999,00."
                            endif
                        endif

                    elseif oModel:GetValue("AL_LIBAPR") == "V" .and. (!Empty(oModel:GetValue("AL_XRESPON")) .or. !Empty(oModel:GetValue("AL_XGEST1N")) .or. !Empty(oModel:GetValue("AL_XGEST2N")))

                        xRet    := .F.
                        cMsg    := "Para VISTORES, n縊 informar Respons疱el ou Controller ou Gestor Local."

                    endif

                endif
            Next

            //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
            // O grupo deve ter somente 1 APROVADOR, Filial SP
            //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
            if nQtdAprov <> 1 .and. oModel:GetValue("AL_MSFIL") == "03"
                xRet := .F.
                cMsg := "Obrigatoriamente, o grupo deve possuir um ?nico membro configurado como APROVADOR. Os demais devem ser VISTORES."
            endif

            //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
            // Verifico se os niveis do grupo est縊 configurados adequadamente
            //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
            if xRet

                For nX := 1 to nQtdLinhas
                    oModel:SetLine(nX)

                    //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
                    // Ignora registros bloqueados
                    //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
                    if oModel:GetValue("AL_MSBLQL") <> "1"

                        //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
                        // Identificando o n?vel do gestores 1o n?vel e 2o n?vel
                        //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
                        if oModel:GetValue("AL_APROV") == cGest1N .or. (cGest1N == cRespon .and. Empty(cNivGes1N))
                            cNivGes1N := oModel:GetValue("AL_NIVEL")
                        endif
                        if oModel:GetValue("AL_APROV") == cGest2N .or. (cGest2N == cRespon .and. Empty(cNivGes2N))
                            cNivGes2N := oModel:GetValue("AL_NIVEL")
                        endif

                        //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
                        // O respons疱el n縊 poder? estar elencado no grupo de aprova鈬o, para n縊 gerar
                        // duplicidade nas aprova鋏es
                        //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
                        //if oModel:GetValue("AL_APROV") == cRespon
                        //    xRet := .F.
                        //    cMsg := "O respons疱el, informado na linha do departamento aprovador, n縊 pode estar tamb駑 como um vistor no grupo de aprova鈬o."
                        //endif

                        //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
                        // Analisando n?vel dos integrantes. N縊 poder? existir niveis maiores que 95,
                        // exceto os niveis 96 e 98 que s縊 dos gestores local e corporativo
                        /*覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
                        if oModel:GetValue("AL_NIVEL") >= "96"
                            xRet := .F.
                            cMsg := "Nenhum integrante poder? ter n?vel maior que 95."
                            exit
                        endif*/

                    endif

                Next

                //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
                // 1) Obrigat?rio que os gestores 1o n?vel e 2o n?vel estejam no grupo de 
                //    aprova鈬o. Se um deles estiver como respons疱el, n縊 existe obrigatoriedade
                // 2) O n?vel do aprovador deve ser menor que os n?veis dos gestores 1o n?vel e 
                //    2o n?vel
                // 3) O n?vel do gestor 1o n?vel deve ser menor que o do 2o n?vel
                //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
                if xRet
                    //if (Empty(cNivGes1N) .and. cGest1N != cRespon) .or. (Empty(cNivGes2N) .and. cGest2N != cRespon)
                    if Empty(cNivGes1N) .or. Empty(cNivGes2N)
                        xRet := .F.
                        cMsg := "O Controller e Gestor Local, informados na linha do APROVADOR, obrigatoriamente devem estar cadastrados neste grupo de aprova鈬o."
                    //elseif cNivelApr >= cNivGes1N .or. cNivelApr >= cNivGes2N
                    //    xRet := .F.
                    //    cMsg := "O n?vel do aprovador deve ser sempre menor que os n?veis do Controller e Gestor Local."
                    elseif cNivGes1N >= cNivGes2N
                        xRet := .F.
                        cMsg := "O n?vel do Controller deve ser menor do que o n?vel do Gestor Local."
                    endif
                endif

            endif

            //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
            // Caso o retorno seja falso, apresenta a mensagem
            //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
            if !xRet
                Help(,, "ATENﾇﾃO",, cMsg + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
            endif

        endif

    ElseIf cIdPonto == 'FORMLINEPRE'
        /*
        Antes da altera鈬o da linha do formul疵io FWFORMGRID.
        1     O        Objeto do formul疵io ou do modelo, conforme o caso
        2     C        ID do local de execu鈬o do ponto de entrada
        3     C        ID do formul疵io
        4     N        N?mero da Linha da FWFORMGRID
        5     C        A鈬o da FWFORMGRID
        6     C        Id do campo
        Retorno: Requer um retorno l?gico
        */
    ElseIf cIdPonto == 'FORMLINEPOS'
        //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
        // Na valida鈬o total da linha do formul疵io FWFORMGRID.
        // 1     O        Objeto do formul疵io ou do modelo, conforme o caso
        // 2     C        ID do local de execu鈬o do ponto de entrada
        // 3     C        ID do formul疵io
        // 4     N        N?mero da Linha da FWFORMGRID
        // Retorno: Requer um retorno l?gico
        //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
        if (nOperation == 3 .or. nOperation == 4) .and.;
            SAL->(FieldPos("AL_XGEST2N")) > 0 .and.;
            SAL->(FieldPos("AL_XGEST1N")) > 0

            oModelPad   := FwModelActive()
            oModel      := oModelPad:GetModel("DetailSAL")
            oMainModel  := oModelPad:GetModel("ModelSAL")

            if oModel:GetValue("AL_MSBLQL") <> "1" .and.;
                SAL->(FieldPos("AL_MSFIL")) > 0 .and.;
                oModel:GetValue("AL_MSFIL") == "03"

                //nQtdLinhas  := oModel:GetQtdLine()
                //if oModel:GetValue("AL_LIBAPR") == "A" .and. (Empty(oModel:GetValue("AL_XGEST2N")) .or. Empty(oModel:GetValue("AL_XGEST1N")))
                //    xRet := .F.
                //    Help(,, "ATENﾇﾃO",, "Necess疵io informar os gestores local e corporativo para APROVADORES." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
                if oModel:GetValue("AL_LIBAPR") == "V" .and. (!Empty(oModel:GetValue("AL_XGEST2N")) .or. !Empty(oModel:GetValue("AL_XGEST1N")))
                    xRet := .F.
                    Help(,, "ATENﾇﾃO",, "Para VISTORES, n縊 informar gestores local e corporativo." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
                endif
            endif

        endif
                
    ElseIf cIdPonto == 'MODELCOMMITTTS'
        /*
        Ap?s a grava鈬o total do modelo e dentro da transa鈬o.
        1     O        Objeto do formul疵io ou do modelo, conforme o caso
        2     C        ID do local de execu鈬o do ponto de entrada
        3     C        ID do formul疵io
        Retorno: N縊 espera retorno
        */
    ElseIf cIdPonto == 'MODELCOMMITNTTS'
        /*
        Ap?s a grava鈬o total do modelo e fora da transa鈬o.
        1     O        Objeto do formul疵io ou do modelo, conforme o caso
        2     C        ID do local de execu鈬o do ponto de entrada
        3     C        ID do formul疵io
        Retorno: N縊 espera retorno
        */
    ElseIf cIdPonto == 'FORMCOMMITTTSPRE'
        /*
        Antes da grava鈬o da tabela do formul疵io.
        1     O        Objeto do formul疵io ou do modelo, conforme o caso
        2     C        ID do local de execu鈬o do ponto de entrada
        3     C        ID do formul疵io
        4     L        Se .T. indica novo registro (Inclus縊) se .F. registro j? existente (Altera鈬o / Exclus縊)
        Retorno: N縊 espera retorno
        */
    ElseIf cIdPonto == 'FORMCOMMITTTSPOS'
        /*
        Ap?s a grava鈬o da tabela do formul疵io.
        1     O        Objeto do formul疵io ou do modelo, conforme o caso
        2     C        ID do local de execu鈬o do ponto de entrada
        3     C        ID do formul疵io
        4     L        Se .T. indica novo registro (Inclus縊) se .F. registro j? existente (Altera鈬o / Exclus縊)
        Retorno: N縊 espera retorno
        */
    ElseIf cIdPonto == 'MODELCANCEL'
        /*
        No cancelamento do bot縊.
        1     O        Objeto do formul疵io ou do modelo, conforme o caso
        2     C        ID do local de execu鈬o do ponto de entrada
        3     C        ID do formul疵io
        Retorno: Requer um retorno l?gico
        */
    ElseIf cIdPonto == 'BUTTONBAR'
        /*
        Para a inclus縊 de bot?es na ControlBar.
        Para criar os bot?es deve-se retornar um array bi-dimensional com a seguinte estrutura de cada item:
        1     C        Titulo para o bot縊
        2     C        Nome do Bitmap para exibi鈬o
        3     B        CodeBlock a ser executado
        4     C        ToolTip (Opcional)
        Par穃etros Recebidos:
        1     O        Objeto do formul疵io ou do modelo, conforme o caso
        2     C        ID do local de execu鈬o do ponto de entrada
        3     C        ID do formul疵io
        Retorno: Requer um array de retorno com estrutura pr? definida
        */
    EndIf

EndIf

Return xRet

//User Function VlMT114G(cGestor)
//Local lRet  := .T.
//Return(lRet)
