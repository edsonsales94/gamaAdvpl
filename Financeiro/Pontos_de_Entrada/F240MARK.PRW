#Include "Rwmake.ch"
#Include "Protheus.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function       F240MARK                                                     /@
@type           Ponto de entrada                                             /@
@date           23/06/2021                                                   /@
@description    Adiciona Botoes no Cadastro de Clientes                      /@
@author         Adalberto Moreno Batista (Op鈬o Um) amoreno@opcaoum.com.br   /@
@use            Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function F240MARK()
Local aCampos   :=  PARAMIXB
Local aArea     := GetArea()
Local aAreaSX3  := SX3->(GetArea())
Local aRet      := {}
Local aCposInic := {"E2_FILIAL ", "E2_XORIGPC", "E2_NUM    ", "E2_FORNECE", "E2_LOJA   ",;
                    "E2_NOMFOR ", "E2_VENCREA", "E2_VALOR  ", "E2_XFORPAG", "E2_CODBAR ",;
                    "E2_FORBCO ", "E2_FORAGE ", "E2_FAGEDV ", "E2_FORCTA ", "E2_FCTADV "}
Local nX

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Iniciando a montagem do array com os campos principais
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
SX3->(dbSetOrder(2))    //X3_CAMPO
For nX:=1 to Len(aCposInic)
    if SX3->(dbSeek(aCposInic[nX]))
        aAdd(aRet, {SX3->X3_CAMPO, "", X3Titulo(), AllTrim(SX3->X3_PICTURE)})
    endif
Next

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Adicionando os campos restantes
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
for nX:= 1 to Len(aCampos)
    if aScan(aRet, {|x| AllTrim(Upper(x[1])) == AllTrim(aCampos[nX,1])}) == 0
        aAdd(aRet, aCampos[nX])
    endif
next

RestArea(aAreaSX3)
RestArea(aArea)

Return(aRet)
