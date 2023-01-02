#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#Include "Rwmake.ch"
#include "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณXAUTOEND บAutor  ณRicky Moraes 18/07/2022                   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Endere็ar automaticamente atraves de schedule              บฑฑ
ฑฑบ          ณ baseado nos parametros BR_ENDPAD e BR_LOCAUTO              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico Ga.Ma Italy                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function XAUTOEND()
	default aParam := {"01","01"} // caso nao receba nenhum parametro Empresa, Filial
	Private cCodEmp    := aParam[1]
	Private cCodFil    := aParam[2]


//If (IsBlind())
//Abre tabelas necessarias
	If !(Type("oMainWnd")=="O")

		WfPrepEnv(cCodEmp, cCodFil, "U_XAUTOEND",, "SIGAEST")
		sfDistSDA()
		RpcClearEnv()
	Else
		sfDistSDA()
        MsgAlert("Processo Concluido", "Enderecamento Automatico")
	EndIf

	ConOut(dTOc(Date()) + " as " + Time() + ". Fim enderecamento automatico ")

return


// ------------------------------------------------------------------------------------------
// Ricky Moraes - 16/06/21 - 16:10
// Controle de Filiais
// ----------------------------------------------------------------------------------------

Static Function sfDistSDA()
	Local lAutoDist := GetMV("BR_AUTOLOC")

	IF ! lAutoDist
		ConOut(dTOc(Date()) + " as " + Time() + ". Parametro DESABILITADO BR_AUTOLOC")
	ELSE
		ConOut("Iniciar Enderecamento na Filial " + cCodFil)
		sfSaldoSDA()

	ENDIF

Return

// ------------------------------------------------------------------------------------------
// Ricky Moraes - 18/07/2022 - 08:00
// Verifica se existe saldo no armazem da filial 
// TABELA SDA
// ----------------------------------------------------------------------------------------

Static Function sfSaldoSDA()
	Local nRecSDA:=0
	Local cArmz := FormatIn( GetMV("BR_LOCAUTO"),",")
	Local cEnd :=  GetMV("BR_ENDPAD")
//Local cAliasSDA:= GetNextAlias()
	Local cQuery := ""

	cQuery := " SELECT DA_PRODUTO, DA_NUMSEQ, DA_LOCAL, DA_QTDORI, DA_SALDO  "
	cQuery += " FROM "+Retsqlname("SDA")+" SDA "
	cQuery += " WHERE SDA.D_E_L_E_T_ <> '*' "
	cQuery += " AND DA_FILIAL='"+xFilial("SDA")+"' "
	cQuery += " AND DA_SALDO > 0 "
	cQuery += " AND DA_LOCAL IN  " + cArmz
   	cQuery += " ORDER BY 2  " 


	cQuery := ChangeQuery(cQuery)

	If Select("TMPSDA") <> 0
		dbSelectArea("TMPSDA")
		TMPSDA->(DbCloseArea())
	Endif
	DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMPSDA",.F.,.T.)
	dbSelectArea("TMPSDA")
	Count to nRecSDA

	TMPSDA->(dbGoTop()) // posiciona o cabe็alho

	if nRecSDA == 0
		ConOut('Sem itens para o endere็amento!')
	else
		ConOut("Disponiveis para o endere็amento  : "+  CVALTOCHAR(nRecSDA) )

		while !TMPSDA->(EOF())
			sfExSDA(TMPSDA->DA_PRODUTO,TMPSDA->DA_NUMSEQ,TMPSDA->DA_SALDO,cEnd,3)
			TMPSDA->(dbSkip())
		enddo

		TMPSDA->(dbCloseArea())
	ENDIF
Return

// ------------------------------------------------------------------------------------------
// Ricky Moraes - 18/07/22 - 16:50
// AutoExec Rotina Enderecamento
//  _cOPC = 3 - Endere็a | 4 - Estorna
// ----------------------------------------------------------------------------------------

Static Function sfExSDA(_cProd,_cNumSeq,_nQtd,_End,_cOpc)
	Local aCabSDA       := {}
	Local aItSDB        := {}
	Local aItensSDB    := {}
	Local cEstorno := iif(_cOpc==4,'S',' ' )
	Local cErro
	Private lMsErroAuto := .F.


	aCabSDA := {}
	aAdd( aCabSDA, {'DA_PRODUTO' ,_cProd, Nil} )
	aAdd( aCabSDA, {'DA_NUMSEQ' ,_cNumSeq , Nil} )

	aItSDB := {}
	aAdd( aItSDB, {'DB_ITEM' , '0001' , Nil} )
	aAdd( aItSDB, {'DB_ESTORNO', cEstorno , Nil} )
	aAdd( aItSDB, {'DB_LOCALIZ', _End , Nil} )
	aAdd( aItSDB, {'DB_DATA' , dDataBase , Nil} )
	aAdd( aItSDB, {'DB_QUANT' , _nQtd , Nil} )

	aItensSDB := {}
	aadd( aItensSDB, aitSDB )
    MSExecAuto({|X,Y,Z|MATA265(X,Y,Z)},aCabSDA, aItensSDB,_cOpc)
	
	If lMsErroAuto
		cErro:= MostraErro()
		ConOut(cErro)
	Else
	    ConOut('Produto: ' + TMPSDA->DA_PRODUTO + ' . Sequencial: ' + TMPSDA->DA_NUMSEQ  + ' . Endereco ' +_End)	
	Endif

RETURN


