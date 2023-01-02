#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#Include "Rwmake.ch"
#include "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³XDESEND ºAutor  ³Ricky Moraes 18/07/2022                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Estorna o endereçamento na validação documento entrada     º±±
±±º          ³ baseado nos parametros BR_ENDPAD e BR_LOCAUTO              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico Ga.Ma Italy                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function XDESEND()
	default aParam := {"01","01"} // caso nao receba nenhum parametro Empresa, Filial
	Private cCodEmp    := aParam[1]
	Private cCodFil    := aParam[2]

	If !(Type("oMainWnd")=="O")

		WfPrepEnv(cCodEmp, cCodFil, "U_XDESEND",, "SIGAEST")
		sfEstSDA()
		RpcClearEnv()
	Else
		sfEstSDA()
	EndIf

	ConOut(dTOc(Date()) + " as " + Time() + ". Fim Estorno enderecamento ")

return



// ------------------------------------------------------------------------------------------
// Ricky Moraes - 18/07/22 - 16:50
// AutoExec Rotina Enderecamento
//  _cOPC = 3 - Endereça | 4 - Estorna
// ----------------------------------------------------------------------------------------

Static Function sfEstSDA()
	Local cAlias := ''
	Local aCabSDA := {}
	Local aItSDB := {}
	Local aItensSDB := {}
	Local nCount := 0
	Local _lret:= .F.

	Private lMsErroAuto := .F.

	cAlias := getNextAlias()



	BeginSql Alias cAlias
			SELECT
			SD1.D1_COD, SDA.DA_NUMSEQ, SDB.DB_LOCALIZ,
			SDB.DB_QUANT, SDB.DB_ITEM, SDB.DB_NUMSEQ,
			SDA.DA_LOCAL
			FROM
			%TABLE:SD1% SD1
			INNER JOIN %TABLE:SDA% SDA ON
			SDA.DA_FILIAL = SD1.D1_FILIAL
			AND SDA.DA_DOC = SD1.D1_DOC
			AND SDA.DA_SERIE = SD1.D1_SERIE
			AND SDA.DA_CLIFOR = SD1.D1_FORNECE
			AND SDA.DA_LOJA = SD1.D1_LOJA
			AND SDA.DA_LOCAL = SD1.D1_LOCAL
			AND SDA.DA_ORIGEM = %EXP:'SD1'%
			AND SDA.%NOTDEL%
			INNER JOIN %TABLE:SDB% SDB ON
			SDB.DB_FILIAL = SDA.DA_FILIAL
			AND SDB.DB_PRODUTO = SDA.DA_PRODUTO
			AND SDB.DB_DOC = SDA.DA_DOC
			AND SDB.DB_SERIE = SDA.DA_SERIE
			AND SDB.DB_CLIFOR = SDA.DA_CLIFOR
			AND SDB.DB_LOJA = SDA.DA_LOJA
			AND SDB.DB_ESTORNO = %EXP:' '%
			AND SDB.%NOTDEL%
			WHERE
			SD1.D1_FILIAL = %EXP:SF1->F1_FILIAL%
			AND SD1.D1_DOC = %EXP:SF1->F1_DOC%
			AND SD1.D1_SERIE = %EXP:SF1->F1_SERIE%
			AND SD1.D1_FORNECE = %EXP:SF1->F1_FORNECE%
			AND SD1.D1_LOJA = %EXP:SF1->F1_LOJA%
			AND SD1.%NOTDEL%
	EndSQl

	(cAlias)->(dbEval( { || nCount++ } ))
	(cAlias)->(dbGoTop())

	if nCount == 0
		//alert('Sem itens disponíveis para o estorno!')
		_lret:= .T.
	else
		If ApMsgYesNo('Deseja realmente estornar os endereçamentos?', 'Documento de Entrada : ' + SF1->F1_DOC)

			dbSelectArea('SDA')
			SDA->(dbSetOrder(1))

			dbSelectArea('SDB')
			SDB->(dbSetOrder(1))

			ProcRegua( nCount )
			processMessage()

			while !(cAlias)->(EOF())
				incProc('Produto: ' + allTrim((cAlias)->D1_COD) + ' – Sequencia: ' + allTrim( (cAlias)->DA_NUMSEQ ) + ' – Item: ' + allTrim( (cAlias)->DB_ITEM ) )
				processMessage()

				SDA->(dbGoTop()) // posiciona o cabeçalho
				if SDA->(dbSeek( xfilial('SDA') + (cAlias)->D1_COD + (cAlias)->DA_LOCAL + (cAlias)->DA_NUMSEQ + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA ))

					SDB->(dbGoTop()) // posiciona o item
					if SDB->( dbSeek( xfilial('SDB') + (cAlias)->D1_COD + (cAlias)->DA_LOCAL + (cAlias)->DB_NUMSEQ + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA + (cAlias)->DB_ITEM ) )
						lMsErroAuto := .F.

						aCabSDA := {}
						aAdd( aCabSDA, {'DA_PRODUTO' ,(cAlias)->D1_COD , Nil} )
						aAdd( aCabSDA, {'DA_NUMSEQ' ,(cAlias)->DA_NUMSEQ , Nil} )

						aItSDB := {}
						aAdd( aItSDB, {'DB_ITEM' , (cAlias)->DB_ITEM , Nil} )
						aAdd( aItSDB, {'DB_ESTORNO', 'S' , Nil} )
						aAdd( aItSDB, {'DB_LOCALIZ', (cAlias)->DB_LOCALIZ, Nil} )
						aAdd( aItSDB, {'DB_DATA' , dDataBase , Nil} )
						aAdd( aItSDB, {'DB_QUANT' , (cAlias)->DB_QUANT , Nil} )

						aItensSDB := {}
						aadd( aItensSDB, aitSDB )
						MSExecAuto({|X,Y,Z|MATA265(X,Y,Z)},aCabSDA, aItensSDB,4)
					endif
				endif

				(cAlias)->(dbSkip())
			enddo
			_lret:= .T.

		else
			alert('Processo cancelado !')
		endif
	endif
	(cAlias)->(dbCloseArea())
	MsgInfo("Processo Concluido !!!", "Estonar Enderecamento")

Return (_lret)
