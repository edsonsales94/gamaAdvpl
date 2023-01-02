#Include "Protheus.ch"
 
/*/
———————————————————————————————————————————————————————————————————————————————
@function		MATA114                                                      /@
@date			04/11/2020                                                   /@
@type			Ponto de entrada
@description    P.E. em MVC, utilizado para tratamento no cadastro de grupos
                de aprovação de compras.                                     /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br) Opção Um   /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
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
        Na validação total do modelo.
        1     O        Objeto do formulário ou do modelo, conforme o caso
        2     C        ID do local de execução do ponto de entrada
        3     C        ID do formulário
        Retorno:  Requer um retorno lógico
        */
    ElseIf cIdPonto == 'FORMPOS' .and. cFilAnt == "03"
        //———————————————————————————————————————————————————————————————————————————————
        // Na validação total do formulário.
        // 1     O        Objeto do formulário ou do modelo, conforme o caso
        // 2     C        ID do local de execução do ponto de entrada
        // 3     C        ID do formulário
        // Retorno: Requer um retorno lógico
        //———————————————————————————————————————————————————————————————————————————————
        if (nOperation == 3 .or. nOperation == 4)
            oModelPad   := FwModelActive()
            oModel      := oModelPad:GetModel("DetailSAL")
            oMainModel  := oModelPad:GetModel("ModelSAL")
            nQtdLinhas  := oModel:GetQtdLine()

            //———————————————————————————————————————————————————————————————————————————————
            // Critica aprovadores, obriga o preenchimento de aprovador superior niveis 1 e 2
            // somente para aprovador
            //———————————————————————————————————————————————————————————————————————————————
            nQtdAprov := 0
            For nX := 1 to nQtdLinhas
                oModel:SetLine(nX)

                //———————————————————————————————————————————————————————————————————————————————
                // Ignora registros bloqueados
                //———————————————————————————————————————————————————————————————————————————————
                if oModel:GetValue("AL_MSBLQL") <> "1"
                
                    //———————————————————————————————————————————————————————————————————————————————
                    // Identificando a quantidade de integrantes APROVADOR
                    //———————————————————————————————————————————————————————————————————————————————
                    if oModel:GetValue("AL_LIBAPR") == "A"

                        nQtdAprov++
                        if Empty(oModel:GetValue("AL_XRESPON")) .or. Empty(oModel:GetValue("AL_XGEST1N")) .or. Empty(oModel:GetValue("AL_XGEST2N"))
                            xRet        := .F.
                            cMsg        := "Necessário informar o Responsável, Controller e Gestor Local para APROVADORES."
                        endif
                        cNivelApr   := oModel:GetValue("AL_NIVEL")
                        cRespon     := oModel:GetValue("AL_XRESPON")
                        cGest1N     := oModel:GetValue("AL_XGEST1N")
                        cGest2N     := oModel:GetValue("AL_XGEST2N")

                        // Busca faixa de valores em perfil de aprovação (para o funcionamento, necessário que o aprovador pertenca a um perfil de 0,00 à 99999999,99)
                        DHL->(dbSetOrder(1))    //DHL_FILIAL, DHL_COD
                        if DHL->(dbSeek(xFilial("DHL") + oModel:GetValue("AL_PERFIL")))
                            if DHL->DHL_LIMMIN <= 0 .and. DHL->DHL_LIMMAX >= 99999999999
                            else
                                xRet    := .F.
                                cMsg    := "Um aprovador deve pertencer à um perfil que abranja todas as aprovações, ou seja Limite Mínimo 0,00 e Liminte Máximo 99.999.999.999,00."
                            endif
                        endif

                    elseif oModel:GetValue("AL_LIBAPR") == "V" .and. (!Empty(oModel:GetValue("AL_XRESPON")) .or. !Empty(oModel:GetValue("AL_XGEST1N")) .or. !Empty(oModel:GetValue("AL_XGEST2N")))

                        xRet    := .F.
                        cMsg    := "Para VISTORES, não informar Responsável ou Controller ou Gestor Local."

                    endif

                endif
            Next

            //———————————————————————————————————————————————————————————————————————————————
            // O grupo deve ter somente 1 APROVADOR, Filial SP
            //———————————————————————————————————————————————————————————————————————————————
            if nQtdAprov <> 1 .and. oModel:GetValue("AL_MSFIL") == "03"
                xRet := .F.
                cMsg := "Obrigatoriamente, o grupo deve possuir um único membro configurado como APROVADOR. Os demais devem ser VISTORES."
            endif

            //———————————————————————————————————————————————————————————————————————————————
            // Verifico se os niveis do grupo estão configurados adequadamente
            //———————————————————————————————————————————————————————————————————————————————
            if xRet

                For nX := 1 to nQtdLinhas
                    oModel:SetLine(nX)

                    //———————————————————————————————————————————————————————————————————————————————
                    // Ignora registros bloqueados
                    //———————————————————————————————————————————————————————————————————————————————
                    if oModel:GetValue("AL_MSBLQL") <> "1"

                        //———————————————————————————————————————————————————————————————————————————————
                        // Identificando o nível do gestores 1o nível e 2o nível
                        //———————————————————————————————————————————————————————————————————————————————
                        if oModel:GetValue("AL_APROV") == cGest1N .or. (cGest1N == cRespon .and. Empty(cNivGes1N))
                            cNivGes1N := oModel:GetValue("AL_NIVEL")
                        endif
                        if oModel:GetValue("AL_APROV") == cGest2N .or. (cGest2N == cRespon .and. Empty(cNivGes2N))
                            cNivGes2N := oModel:GetValue("AL_NIVEL")
                        endif

                        //———————————————————————————————————————————————————————————————————————————————
                        // O responsável não poderá estar elencado no grupo de aprovação, para não gerar
                        // duplicidade nas aprovações
                        //———————————————————————————————————————————————————————————————————————————————
                        //if oModel:GetValue("AL_APROV") == cRespon
                        //    xRet := .F.
                        //    cMsg := "O responsável, informado na linha do departamento aprovador, não pode estar também como um vistor no grupo de aprovação."
                        //endif

                        //———————————————————————————————————————————————————————————————————————————————
                        // Analisando nível dos integrantes. Não poderá existir niveis maiores que 95,
                        // exceto os niveis 96 e 98 que são dos gestores local e corporativo
                        /*———————————————————————————————————————————————————————————————————————————————
                        if oModel:GetValue("AL_NIVEL") >= "96"
                            xRet := .F.
                            cMsg := "Nenhum integrante poderá ter nível maior que 95."
                            exit
                        endif*/

                    endif

                Next

                //———————————————————————————————————————————————————————————————————————————————
                // 1) Obrigatório que os gestores 1o nível e 2o nível estejam no grupo de 
                //    aprovação. Se um deles estiver como responsável, não existe obrigatoriedade
                // 2) O nível do aprovador deve ser menor que os níveis dos gestores 1o nível e 
                //    2o nível
                // 3) O nível do gestor 1o nível deve ser menor que o do 2o nível
                //———————————————————————————————————————————————————————————————————————————————
                if xRet
                    //if (Empty(cNivGes1N) .and. cGest1N != cRespon) .or. (Empty(cNivGes2N) .and. cGest2N != cRespon)
                    if Empty(cNivGes1N) .or. Empty(cNivGes2N)
                        xRet := .F.
                        cMsg := "O Controller e Gestor Local, informados na linha do APROVADOR, obrigatoriamente devem estar cadastrados neste grupo de aprovação."
                    //elseif cNivelApr >= cNivGes1N .or. cNivelApr >= cNivGes2N
                    //    xRet := .F.
                    //    cMsg := "O nível do aprovador deve ser sempre menor que os níveis do Controller e Gestor Local."
                    elseif cNivGes1N >= cNivGes2N
                        xRet := .F.
                        cMsg := "O nível do Controller deve ser menor do que o nível do Gestor Local."
                    endif
                endif

            endif

            //———————————————————————————————————————————————————————————————————————————————
            // Caso o retorno seja falso, apresenta a mensagem
            //———————————————————————————————————————————————————————————————————————————————
            if !xRet
                Help(,, "ATENÇÃO",, cMsg + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
            endif

        endif

    ElseIf cIdPonto == 'FORMLINEPRE'
        /*
        Antes da alteração da linha do formulário FWFORMGRID.
        1     O        Objeto do formulário ou do modelo, conforme o caso
        2     C        ID do local de execução do ponto de entrada
        3     C        ID do formulário
        4     N        Número da Linha da FWFORMGRID
        5     C        Ação da FWFORMGRID
        6     C        Id do campo
        Retorno: Requer um retorno lógico
        */
    ElseIf cIdPonto == 'FORMLINEPOS'
        //———————————————————————————————————————————————————————————————————————————————
        // Na validação total da linha do formulário FWFORMGRID.
        // 1     O        Objeto do formulário ou do modelo, conforme o caso
        // 2     C        ID do local de execução do ponto de entrada
        // 3     C        ID do formulário
        // 4     N        Número da Linha da FWFORMGRID
        // Retorno: Requer um retorno lógico
        //———————————————————————————————————————————————————————————————————————————————
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
                //    Help(,, "ATENÇÃO",, "Necessário informar os gestores local e corporativo para APROVADORES." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
                if oModel:GetValue("AL_LIBAPR") == "V" .and. (!Empty(oModel:GetValue("AL_XGEST2N")) .or. !Empty(oModel:GetValue("AL_XGEST1N")))
                    xRet := .F.
                    Help(,, "ATENÇÃO",, "Para VISTORES, não informar gestores local e corporativo." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
                endif
            endif

        endif
                
    ElseIf cIdPonto == 'MODELCOMMITTTS'
        /*
        Após a gravação total do modelo e dentro da transação.
        1     O        Objeto do formulário ou do modelo, conforme o caso
        2     C        ID do local de execução do ponto de entrada
        3     C        ID do formulário
        Retorno: Não espera retorno
        */
    ElseIf cIdPonto == 'MODELCOMMITNTTS'
        /*
        Após a gravação total do modelo e fora da transação.
        1     O        Objeto do formulário ou do modelo, conforme o caso
        2     C        ID do local de execução do ponto de entrada
        3     C        ID do formulário
        Retorno: Não espera retorno
        */
    ElseIf cIdPonto == 'FORMCOMMITTTSPRE'
        /*
        Antes da gravação da tabela do formulário.
        1     O        Objeto do formulário ou do modelo, conforme o caso
        2     C        ID do local de execução do ponto de entrada
        3     C        ID do formulário
        4     L        Se .T. indica novo registro (Inclusão) se .F. registro já existente (Alteração / Exclusão)
        Retorno: Não espera retorno
        */
    ElseIf cIdPonto == 'FORMCOMMITTTSPOS'
        /*
        Após a gravação da tabela do formulário.
        1     O        Objeto do formulário ou do modelo, conforme o caso
        2     C        ID do local de execução do ponto de entrada
        3     C        ID do formulário
        4     L        Se .T. indica novo registro (Inclusão) se .F. registro já existente (Alteração / Exclusão)
        Retorno: Não espera retorno
        */
    ElseIf cIdPonto == 'MODELCANCEL'
        /*
        No cancelamento do botão.
        1     O        Objeto do formulário ou do modelo, conforme o caso
        2     C        ID do local de execução do ponto de entrada
        3     C        ID do formulário
        Retorno: Requer um retorno lógico
        */
    ElseIf cIdPonto == 'BUTTONBAR'
        /*
        Para a inclusão de botões na ControlBar.
        Para criar os botões deve-se retornar um array bi-dimensional com a seguinte estrutura de cada item:
        1     C        Titulo para o botão
        2     C        Nome do Bitmap para exibição
        3     B        CodeBlock a ser executado
        4     C        ToolTip (Opcional)
        Parâmetros Recebidos:
        1     O        Objeto do formulário ou do modelo, conforme o caso
        2     C        ID do local de execução do ponto de entrada
        3     C        ID do formulário
        Retorno: Requer um array de retorno com estrutura pré definida
        */
    EndIf

EndIf

Return xRet

//User Function VlMT114G(cGestor)
//Local lRet  := .T.
//Return(lRet)
