#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
/*/
=============================================================================
{Protheus.doc} GMIFIN00 
Regra do programa FA050UPD - 
GMIFIN00 - Gatilho do cod.rec. da guia de recolhimento do ICMS

@description
Gatilhar o campo cód rec da guia de recolhimento no contas a pagar
Rotina de Apuração do ICMS (origem) - Alteração do Contas a Pagar (destino)

@author Cosme Nunes
@since 19/08/2020
@type User Function

@table 
    SE2 - Título a pagar

@param
    Não se aplica

@return
    lRet - Se retornar .F., a inclusão, alteração e exclusão não terá prosseguimento.

@menu
    Não se aplica

@history 
    19/08/2020 - Confecção - Gatilho do cod.rec. da guia de recolhimento - Cosme Nunes
/*/   
User Function GMIFIN00()

Local _aArea    := GetArea()
Local _lRet     := .T. //ATENÇÃO: Retorno lógico invertido /exclusivo do ponto FA050UPD()
Local _lGFIN000 := SuperGetMV("GMI_FIN000",.T.,.F.) //Habilita a execução do programa GMIFIN00 
Local _aRotExc	:= STRTOKARR(SuperGetMV("GMI_FIN001",.F.,''),";") //Rotinas que não passarão pela validação
Local _nCnt     := 0
Local _cCRSF6   := ""

//|||||||||||||||||||||||||||||||
//Verifica exceções desse programa
//|||||||||||||||||||||||||||||||
//Verifica se é ExecAuto e aborta execução do programa
/*If lAuto
    Return(.F.)//ATENÇÃO: Retorno lógico invertido /exclusivo para não executar o ponto FA050UPD()
EndIf */

//Verifica se a execução do programa está habilitada
If !_lGFIN000
    Return(.T.)//ATENÇÃO: Retorno lógico invertido /exclusivo do ponto FA050UPD()
EndIf

//Verifica se há rotinas exceção (que não devem executar esse programa) na pilha de chamada. Se estiver, sai da função. 
For _nCnt := 1 To Len(_aRotExc)
    If IsInCallStack(Alltrim(_aRotExc[_nCnt]))
        Return(.T.)//ATENÇÃO: Retorno lógico invertido /exclusivo do ponto FA050UPD()
    EndIf
Next

//|||||||||||||||||||||||||||||||
//Condições
//|||||||||||||||||||||||||||||||
//Verifica se é contas a pagar gerado pela rotina MATA953
If SE2->E2_ORIGEM == "MATA953 " 

//    SE2->E2_DIRF      := "1"//1=Sim              -- alteraçao ref erro log Update error - lock required - File: SE2010 in file D:\bamboo-agent-5.7.2\xml-data\build-dir\TP11-TECX17V3-TECXWIN64\advpl\advplfile.cpp at line 77
// on U_GMIFIN00(GMIFIN00.PRW) 04/09/2020 17:29:00 line : 67

    //Carrega cod reC da guia de recolhimento 
    _cCRSF6 := SF6->F6_CODREC //Posicione("SF6",1,xFilial("SF6")+M->E2_FORNECE+M->E2_LOJA,"F6_CODREC")

    If !Empty(_cCRSF6)
        SE2->E2_CODRET    := _cCRSF6
    //Else 
        //_lRet := .F.
        //ApMsgStop("O código de retenção deve ser informado.")
    EndIf

    _lRet := .T. //ATENÇÃO: Retorno lógico invertido /exclusivo do ponto FA050UPD() 

EndIf

RestArea(_aArea)

Return(_lRet)
