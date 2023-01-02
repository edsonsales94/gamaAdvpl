#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
/*/
=============================================================================
{Protheus.doc} GMIFIN00 
Regra do programa FA050UPD - 
GMIFIN00 - Gatilho do cod.rec. da guia de recolhimento do ICMS

@description
Gatilhar o campo c�d rec da guia de recolhimento no contas a pagar
Rotina de Apura��o do ICMS (origem) - Altera��o do Contas a Pagar (destino)

@author Cosme Nunes
@since 19/08/2020
@type User Function

@table 
    SE2 - T�tulo a pagar

@param
    N�o se aplica

@return
    lRet - Se retornar .F., a inclus�o, altera��o e exclus�o n�o ter� prosseguimento.

@menu
    N�o se aplica

@history 
    19/08/2020 - Confec��o - Gatilho do cod.rec. da guia de recolhimento - Cosme Nunes
/*/   
User Function GMIFIN00()

Local _aArea    := GetArea()
Local _lRet     := .T. //ATEN��O: Retorno l�gico invertido /exclusivo do ponto FA050UPD()
Local _lGFIN000 := SuperGetMV("GMI_FIN000",.T.,.F.) //Habilita a execu��o do programa GMIFIN00 
Local _aRotExc	:= STRTOKARR(SuperGetMV("GMI_FIN001",.F.,''),";") //Rotinas que n�o passar�o pela valida��o
Local _nCnt     := 0
Local _cCRSF6   := ""

//|||||||||||||||||||||||||||||||
//Verifica exce��es desse programa
//|||||||||||||||||||||||||||||||
//Verifica se � ExecAuto e aborta execu��o do programa
/*If lAuto
    Return(.F.)//ATEN��O: Retorno l�gico invertido /exclusivo para n�o executar o ponto FA050UPD()
EndIf */

//Verifica se a execu��o do programa est� habilitada
If !_lGFIN000
    Return(.T.)//ATEN��O: Retorno l�gico invertido /exclusivo do ponto FA050UPD()
EndIf

//Verifica se h� rotinas exce��o (que n�o devem executar esse programa) na pilha de chamada. Se estiver, sai da fun��o. 
For _nCnt := 1 To Len(_aRotExc)
    If IsInCallStack(Alltrim(_aRotExc[_nCnt]))
        Return(.T.)//ATEN��O: Retorno l�gico invertido /exclusivo do ponto FA050UPD()
    EndIf
Next

//|||||||||||||||||||||||||||||||
//Condi��es
//|||||||||||||||||||||||||||||||
//Verifica se � contas a pagar gerado pela rotina MATA953
If SE2->E2_ORIGEM == "MATA953 " 

//    SE2->E2_DIRF      := "1"//1=Sim              -- altera�ao ref erro log Update error - lock required - File: SE2010 in file D:\bamboo-agent-5.7.2\xml-data\build-dir\TP11-TECX17V3-TECXWIN64\advpl\advplfile.cpp at line 77
// on U_GMIFIN00(GMIFIN00.PRW) 04/09/2020 17:29:00 line : 67

    //Carrega cod reC da guia de recolhimento 
    _cCRSF6 := SF6->F6_CODREC //Posicione("SF6",1,xFilial("SF6")+M->E2_FORNECE+M->E2_LOJA,"F6_CODREC")

    If !Empty(_cCRSF6)
        SE2->E2_CODRET    := _cCRSF6
    //Else 
        //_lRet := .F.
        //ApMsgStop("O c�digo de reten��o deve ser informado.")
    EndIf

    _lRet := .T. //ATEN��O: Retorno l�gico invertido /exclusivo do ponto FA050UPD() 

EndIf

RestArea(_aArea)

Return(_lRet)
