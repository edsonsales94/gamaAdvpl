#INCLUDE "PRTOPDEF.CH"
#INCLUDE "TOTVS.CH"
#include "rwmake.ch"
#include "topconn.ch"
#include "ap5mail.ch"
#Include "Protheus.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณXRELMRP3 บAutor  ณRicky Moraes              Data Abril/2022บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Emissใo de relatorio em formato de tabela,                 บฑฑ
ฑฑบ          ณ com dados procedures sistema SFC                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico Ga.Ma Italy                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

user function XRELTEC()
	Local cPerg := 'XRELTEC'
	Private aCabec := {} //ARRAY DO CABEวALHO
	Private aDados := {} //ARRAY QUE ARMAZENARม OS DADOS

	VALPERG(cPerg)
	IF pergunte(cPerg,.T.)
		MsgRun("Atualizando os Registros , Aguarde..." + Dtoc(MV_PAR01) + ' at้ ' + Dtoc(MV_PAR02),"Atualizando Base de dados"  	  ,{||  fQuery() } )
	ENDIF

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfQuery()บAutor  ณRicky Moraes                Data Abril/22  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

STATIC FUNCTION fQuery()
	Local nTotal,nCol,i,nX :=0
	Local cCampo
	Local cQryAux

	//Montando consulta de dados
	cQryAux := ""
	//cQryAux += "EXEC sp_TEMP_RELMPR3 '"  + (MV_PAR01) + "'"
    cQryAux := "EXEC spRelPostoTecnicoGama '"+ Dtos(MV_PAR01) + "','" + Dtos(MV_PAR02) + "'"
	nTotal:=0
	IF SELECT('QRY_AUX') > 0
		DBSELECTAREA("QRY_AUX")
		QRY_AUX->(DBCLOSEAREA())
	ENDIF

	//Executando consulta e setando o total da r้gua
	TCQuery cQryAux New Alias "QRY_AUX"

	TCSetField("QRY_AUX", "DATADEF", "D")
	
	//Contando os registros e voltando ao topo da query
	Count To nTotal

	nCol:= QRY_AUX->(FCount())
	QRY_AUX->(DbGoTop())

	for i := 1 to nCol
		// exibe o nome do campo
		cCampo := QRY_AUX->(Field(i))
		//alert( cCampo )
		aAdd(aCabec,{cCampo, VALTYPE(QRY_AUX->(FieldGet(i))) } )

		// exibe o conte๚do do campo
		// 1a forma
		// alert( QRY_AUX->(FieldGet(i)) )

		// 2a forma
		//alert( QRY_AUX->&(cCampo) )

	next i


	QRY_AUX->(DbGoTop())

	While QRY_AUX->(!EOF())
		aItem := Array(Len(aCabec)+1)
		For nX := 1 to Len(aCabec)
			aItem[nX] := QRY_AUX->(FieldGet(nX))
		Next nX
		aItem[Len(aCabec)+1] := CHR(160)+'FP'

		AADD(aDados,aItem)
		aItem := {}
		QRY_AUX->(dbSkip())
	End
	aAdd(aCabec,{'Fim','C'} )

	//JOGO TODO CONTEฺDO DO ARRAY PARA O EXCEL
	//DlgtoExcel({{"ARRAY","Relat๓rio ", aCabec, aDados}})

	MsgRun("Exportando os Registros para o Excel...", "Aguarde",;
		{||DlgToExcel({{"GETDADOS",;
		"REL Posto Tecnico",;
		aCabec,aDados}})})

	QRY_AUX->(dbClosearea())

RETURN



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVALPERG     บAutor  ณRicky Moraes            Data Abril/22  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVALIDA A PERGUNTA                                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function VALPERG(cPerg)
	Local i,j
	cPerg := PADR(cPerg,10)
	aRegs := {}
    

	dbSelectArea("SX1")
	dbSetOrder(1)


	if !dbSeek(cPerg)
		AADD(aRegs,{cPerg,"01","Data Inicio:" ,"","" ,"mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
        AADD(aRegs,{cPerg,"02","Data Fim:" ,"","" ,"mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})

	Endif

	For i := 1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j := 1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

Return


