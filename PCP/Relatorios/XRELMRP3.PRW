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
ฑฑบ          ณ baseado nas tabelas do novo MRP                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico Ga.Ma Italy                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

user function XRELMRP3()
	Local cPerg := 'XRELMRP3'

//Local cQryAux:= GetNextAlias() //Declarei meu ALIAS

	Private aCabec    := {} //ARRAY DO CABEวALHO
	Private aDados    := {} //ARRAY QUE ARMAZENARม OS DADOS
	Private aRegistro := {} //ARRAY QUE ARMAZENARม OS DADOS



	VALPERG(cPerg)
	IF pergunte(cPerg,.T.)
		MsgRun("Atualizando os Registros , Aguarde...","Ticket "+ (MV_PAR01) ,{||  fQuery() } )
//	DlgToExcel()	
	ENDIF

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfQuery()บAutor  ณRicky Moraes             	Data Abril/22 บฑฑ
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
	Local nTotal,nCol,i,nX:=0
	Local cCampo
	Local cQryAux
	Local oFWMsExcel
	Local cPath := "C:\mrp\"//   "\system\senf.xls"
 	Local cNomArq := "mrp.xls"
	Local cArquivo := cPath + cNomArq


	MAKEDIR(cPath)
	
	If file(cArquivo)
	   fErase(cArquivo)
	EndIf

	//Montando consulta de dados
	cQryAux := ""
	cQryAux += "EXEC sp_TEMP_RELMPR3 '"  + (MV_PAR01) + "'"

	nTotal:=0
	IF SELECT('QRY_AUX') > 0
		DBSELECTAREA("QRY_AUX")
		QRY_AUX->(DBCLOSEAREA())
	ENDIF


	//Executando consulta e setando o total da r้gua
	TCQuery cQryAux New Alias "QRY_AUX"

   
	TCSetField("QRY_AUX", "DATAFECHAMENTO", "D")
	TCSetField("QRY_AUX", "DTENTRADA", "D")

	//Contando os registros e voltando ao topo da query
	Count To nTotal

	nCol:= QRY_AUX->(FCount())
	QRY_AUX->(DbGoTop())

	oFWMsExcel := FwMsExcelEx():New()     
    oFWMsExcel:AddworkSheet("MRP") //Nใo utilizar n๚mero junto com sinal de menos. Ex.: 1-
    //Criando a Tabela
    oFWMsExcel:AddTable("MRP","MRP - Rela็ใo")
    //Criando Colunas
	for i := 1 to nCol
		// exibe o nome do campo
		cCampo := QRY_AUX->(Field(i))
		aAdd(aCabec,{sfMudaCab(cCampo), VALTYPE(QRY_AUX->(FieldGet(i))) } )
		oFWMsExcel:AddColumn("MRP","MRP - Rela็ใo",sfMudaCab(cCampo),1,1) 
	next i

	QRY_AUX->(DbGoTop())

	While QRY_AUX->(!EOF())
		aItem := Array(Len(aCabec))		
		For nX := 1 to Len(aCabec)
			aItem[nX] := QRY_AUX->(FieldGet(nX))
		Next nX
        oFWMsExcel:AddRow("MRP","MRP - Rela็ใo",aItem)
		QRY_AUX->(dbSkip())
	End

    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cArquivo)
    //Abrindo o excel e abrindo o arquivo xml
    oExcel := MsExcel():New()                //Abre uma nova conexใo com Excel
    oExcel:WorkBooks:Open(cArquivo)          //Abre uma planilha
   // FWAlertSuccess("Caso a Planilha nใo abra automaticamente,a mesma poderแ ser encontrada em " + cPath ,"ATENวรO")
    oExcel:SetVisible(.T.)                   //Visualiza a planilha           
    oExcel:Destroy()


	QRY_AUX->(dbClosearea())



RETURN


Static Function sfMudaCab(cCampo1)
Local cCabNovo :=''

	IF SubStr(cCampo1, 1, 3)='PER'
		cCabNovo :=SubStr(cCampo1, 6, 3)+'|'+SubStr(cCampo1, 11, 2)+'|'+SubStr(cCampo1, 13, 3)
	ELSE
		cCabNovo :=cCampo1
	ENDIF

Return cCabNovo


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVALPERG     บAutor  ณRONALDO SILVA          Data Agosto/21  บฑฑ
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
		AADD(aRegs,{cPerg,"01","Ticket:" ,"","" ,"mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","HW3Z",""})
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
