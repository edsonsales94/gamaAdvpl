#include "protheus.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		MT120QRY                                                     /@
@date			01/03/2021                                                   /@
@type			Ponto de entrada
@description	Filtra pedidos de compras no browse em ambiente Top Connect.
                Executado somente se não existir o MT120FIL. Localizado na
                função MATA120                                               /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br) Opção Um   /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MT120QRY()
Local cRet          := ""
Local aArea         := GetArea()
Local aAreaSY1      := SY1->(GetArea())
Local cStrForCod    := GetMV("BR_RHFORCD", .F., "")
//Local cStrGrpRH     := GetMV("BR_RHGRUPO", .F., "")
Local cEol          := chr(13) + chr(10)
Local lFilIN        := .F.
Local nX

//———————————————————————————————————————————————————————————————————————————————
// Filtra pedido de compras, sendo:
// 1) Para usuários pertencentes à grupos do RH, definidos no cadastro de 
//    compradores (Y1_XCATEG) visualiza somente pedidos de fornecedores de 
//    salários, cadastrados no parametro BR_RHFORCD.
// 2) Para usuários de outros grupos da empressa, não visualizar pedidos de 
//    compras de fornecedores de salários
// obs: Para usuário admin não há filtro
// UTILIZADO EM CONJUNTO COM O PONTO DE ENTRADA MT120PCOK
//———————————————————————————————————————————————————————————————————————————————
if !Empty(cStrForCod) .and. __cUserId != "000000"

    //———————————————————————————————————————————————————————————————————————————————
    // Identificando se comprador possui categoria "Recursos Humanos"
    //———————————————————————————————————————————————————————————————————————————————
    SY1->(dbSetOrder(3))    //Y1_FILIAL, Y1_USER
    if SY1->(dbSeek(XFILIAL("SY1") + __cUserId)) .and. SY1->Y1_XCATEG == "RH"
        //if __cUserId $ cStrGrpRH
        lFilIN  := .T.
    endif

    cStrForCod := StrTran(cStrForCod, "#", cEol)

    for nX := 1 to MlCount(cStrForCod)
        cRet += iif(!Empty(cRet), ",","") +"'" + AllTrim(StrTran(MemoLine(cStrForCod,,nX), cEol, "")) + "'"
    next

    //———————————————————————————————————————————————————————————————————————————————
    // Definindo o filtro para visualização de pedidos de compras
    //———————————————————————————————————————————————————————————————————————————————
    if lFilIN
        cRet    := "C7_FORNECE IN (" + cRet + ")"
    else
        cRet    := "C7_FORNECE NOT IN (" + cRet + ")"
    endif

endif

RestArea(aAreaSY1)
RestArea(aArea)

Return(cRet)
