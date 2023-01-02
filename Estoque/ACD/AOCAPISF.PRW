/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦  AOCSEPA   ¦ Autor ¦ Edson P. S. Sales    ¦ Data ¦ 28/06/2022 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Rotina para Consumir Api SFC Caixa Master e Lacre dos Produto ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

// BIBLIOTECAS NECESSÁRIAS
#Include "TOTVS.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"
#include "restful.ch"

// FUNÇÃO PARA CONSUMO DO SERVIÇO REST
User Function AOCAPISF(idEmbalagem)
    Local cServer   := "usa"                                                                        // URL (IP) DO SERVIDOR
    Local cPort     := "9000"                                                                       // PORTA DO SERVIÇO REST
    Local cURI      := "http://" + cServer + ":" + (cPort)                                          // URI DO SERVIÇO REST
    Local cId       := ALLTRIM(idEmbalagem)                                                         // ID DO REGISTRO A SER ALTERADO
    Local cResource := IIF(SubStr(cId, 1,2) == 'CX',"/api/sfc/Embalagem/","/api/SFC/Peca/")         // RECURSO A SER CONSUMIDO
    Local oRest     := FwRest():New(cURI)                                                           // CLIENTE PARA CONSUMO REST
    Local aHeader   := {}                                                                           // CABEÇALHO DA REQUISIÇÃO
    Local cResult
 

    // PREENCHE CABEÇALHO DA REQUISIÇÃO
    AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
    AAdd(aHeader, "Accept: application/json")
    AAdd(aHeader, "User-Agent: Chrome/65.0 (compatible; Protheus " + GetBuild() + ")")

    // INFORMA O RECURSO
    if Len(cId)==12 .and.  SubStr(cId, 1,2) == 'CX'  // caixa master
        oRest:SetPath(cResource + cId + "/WithPeca")
    else
         oRest:SetPath(cResource + cId)
    EndIf

    //
    If (oRest:Get(aHeader))
        ConOut("GET: " + oRest:GetResult())
    Else
        ConOut("GET: " + oRest:GetLastError())
    EndIf

    cResult := oRest:GetResult()
    

Return cResult

