#include "protheus.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		MT120QRY                                                     /@
@date			01/03/2021                                                   /@
@type			Ponto de entrada
@description	Filtra pedidos de compras no browse em ambiente Top Connect.
                Executado somente se n縊 existir o MT120FIL. Localizado na
                fun鈬o MATA120                                               /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br) Op鈬o Um   /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
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

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Filtra pedido de compras, sendo:
// 1) Para usu疵ios pertencentes ? grupos do RH, definidos no cadastro de 
//    compradores (Y1_XCATEG) visualiza somente pedidos de fornecedores de 
//    sal疵ios, cadastrados no parametro BR_RHFORCD.
// 2) Para usu疵ios de outros grupos da empressa, n縊 visualizar pedidos de 
//    compras de fornecedores de sal疵ios
// obs: Para usu疵io admin n縊 h? filtro
// UTILIZADO EM CONJUNTO COM O PONTO DE ENTRADA MT120PCOK
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if !Empty(cStrForCod) .and. __cUserId != "000000"

    //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
    // Identificando se comprador possui categoria "Recursos Humanos"
    //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
    SY1->(dbSetOrder(3))    //Y1_FILIAL, Y1_USER
    if SY1->(dbSeek(XFILIAL("SY1") + __cUserId)) .and. SY1->Y1_XCATEG == "RH"
        //if __cUserId $ cStrGrpRH
        lFilIN  := .T.
    endif

    cStrForCod := StrTran(cStrForCod, "#", cEol)

    for nX := 1 to MlCount(cStrForCod)
        cRet += iif(!Empty(cRet), ",","") +"'" + AllTrim(StrTran(MemoLine(cStrForCod,,nX), cEol, "")) + "'"
    next

    //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
    // Definindo o filtro para visualiza鈬o de pedidos de compras
    //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
    if lFilIN
        cRet    := "C7_FORNECE IN (" + cRet + ")"
    else
        cRet    := "C7_FORNECE NOT IN (" + cRet + ")"
    endif

endif

RestArea(aAreaSY1)
RestArea(aArea)

Return(cRet)
