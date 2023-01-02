#include "Rwmake.ch"
#include "Topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºProgra103FIM  º Autor ³ Ronaldo Gomes	  º Data ³ 21/08/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Grava o Log da Nota Fiscal de Entrada                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasitech                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MT103FIM() 

Local aArea		:= GetArea()
Local aAreaSF1	:= SF1->( GetArea() )
Local cDoc		:= SF1->F1_DOC
Local cSerie	:= SF1->F1_SERIE
Local cFornec	:= SF1->F1_FORNECE
Local cLoja		:= SF1->F1_LOJA
Local cTipo		:= SF1->F1_TIPO  
Local dData		:= DATE() //Adicionado pelo Ronaldo
Local cTime		:= TIME() //Adicionado pelo Ronaldo
                                                                
If Inclui
	DbSelectArea("SF1")
	dbSetOrder(1)


		If dbSeek(xFilial("SF1")+cDoc+cSerie+cFornec+cLoja+cTipo)

			While SF1->(!Eof()) .And. F1_FILIAL == xFilial("SF1") .And. F1_DOC == cDoc .And. F1_SERIE == cSerie .And. F1_FORNECE == cFornec .And. F1_LOJA == cLoja
                        


				If SF1->( RecLock("SF1",.F.) )

				//Cabeçalho da NF
				SF1->F1_XDATA	:= dData
				SF1->F1_XHORA	:= cTime
				SF1->F1_XUSUAR	:= SubStr(cUsuario,7,15)//Nome do Usuario
				SF1->( MsUnlock() )

				EndIf                       

		   		SF1->(dbSkip(1))


			EndDo

		EndIf
		//Function Utilizado para Endereçamento da Filial 03 - SP	
    	If xFilial("SF1") = "03"
            dbSelectArea("SD1")
            SD1->(DbSetOrder(1))
            SD1->(DbSeek(xFilial("SD1")+cDoc+cSerie+cFornec+cLoja))
			B_(cDoc,cSerie,cFornec,cLoja)
		Endif	
EndIf

//SF1->(dbGoTo())
RestArea(aArea)
RestArea(aAreaSF1)

//// Function utilizada pelo importador "Conexao NFe"
A_()

Return()                                                  


/* ####################################################################### *\
|| #  É EXECUTADO DEPOIS QUE A NOTA É EXCLUÍDA PARA FAZER O XML VOLTAR   # ||
|| #                  PARA A TELA INICIAL DO IMPORTADOR                  # ||
\* ####################################################################### */

Static Function A_()
U_GTPE002()
Return

//*****************************
/*/{Protheus.doc} B_
Utiliza a opção de endereçar produto do MATA265 padrão.
@author Ronaldo Silva
@since 14/09/2021
@version 1.0
@type function
/*/
//*****************************
Static Function B_(cDoc,cSerie,cFornec,cLoja)

Local aCabSDA := {}
Local aItSDB := {}
Local aItensSDB := {}
Local nCount := 0
Local cQuery := " "

Private lMsErroAuto := .F.


cQuery +=" SELECT                                     "
cQuery +=" SD1.D1_COD, SDA.DA_NUMSEQ, SDA.DA_LOCAL,   "
cQuery +=" SD1.D1_QUANT, SDA.DA_SALDO, SBE.BE_LOCALIZ "
cQuery +=" FROM                                       "
cQuery +=" SD1010 SD1                                 "
cQuery +=" INNER JOIN SDA010 SDA ON                   "
cQuery +=" SDA.DA_FILIAL = SD1.D1_FILIAL              "
cQuery +=" AND SDA.DA_DOC = SD1.D1_DOC                "
cQuery +=" AND SDA.DA_SERIE = SD1.D1_SERIE            "
cQuery +=" AND SDA.DA_CLIFOR = SD1.D1_FORNECE         "
cQuery +=" AND SDA.DA_LOJA = SD1.D1_LOJA              "
cQuery +=" AND SDA.DA_LOCAL = SD1.D1_LOCAL            "
cQuery +=" AND SDA.DA_ORIGEM = 'SD1'                  "
cQuery +=" AND SDA.DA_SALDO > 0                       "
cQuery +=" AND SDA.D_E_L_E_T_ <>'*'                   "
cQuery +=" INNER JOIN SBE010 SBE ON                   "
cQuery +=" SBE.BE_FILIAL = SD1.D1_FILIAL              "
cQuery +=" AND SBE.BE_LOCAL = SD1.D1_LOCAL            "
cQuery +=" AND SBE.D_E_L_E_T_ <>'*'                   "
cQuery +=" WHERE                                      "
cQuery +=" SD1.D1_FILIAL = '" + xFilial("SF1") + "'   "
cQuery +=" AND SD1.D1_DOC = '"+cDOC + "'              "
cQuery +=" AND SD1.D1_SERIE = '"+cSERIE + "'          "
cQuery +=" AND SD1.D1_FORNECE = '"+cFORNEC + "'       "
cQuery +=" AND SD1.D1_LOJA = '"+cLOJA + "'            "
cQuery +=" AND SD1.D_E_L_E_T_ <>'*'                   "
cQuery +="							                  "

MEMOWRITE('LOG1QRY.SQL',cQuery)

IF SELECT("cAlias") > 0
	DBSELECTAREA("cAlias")
	TBHWC->(DBCLOSEAREA())
ENDIF  

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), "cAlias", .F., .T. )

cAlias->(dbEval( { || nCount++ } ))
cAlias->(DbGoTop())

if nCount == 0
    conout("Sem Produtos a Endereçar!")
else
    dbSelectArea("SDA")
    SDA->(dbSetOrder(1))

    ProcRegua( nCount )
    processMessage()

    while !cAlias->(EOF())
        incProc("Produto: " + allTrim(cAlias->D1_COD) + " Sequencial: " + cAlias->DA_NUMSEQ )
        processMessage()

        SDA->(dbGoTop()) // posiciona o cabeçalho
        if SDA->(dbSeek( xfilial("SDA") + cAlias->D1_COD + cAlias->DA_LOCAL + cAlias->DA_NUMSEQ + cDOC + cSERIE + cFORNEC + cLOJA ))
            if SDA->DA_SALDO > 0
                lMsErroAuto := .F.
                aCabSDA := {}
                aAdd( aCabSDA, {"DA_PRODUTO" ,SDA->DA_PRODUTO, Nil} )
                aAdd( aCabSDA, {"DA_NUMSEQ" ,SDA->DA_NUMSEQ , Nil} )

                aItSDB := {}
                aAdd( aItSDB, {"DB_ITEM" , '0001' , Nil} )
                aAdd( aItSDB, {"DB_ESTORNO", " " , Nil} )
                aAdd( aItSDB, {"DB_LOCALIZ", cAlias->BE_LOCALIZ, Nil} )
                aAdd( aItSDB, {"DB_DATA" , dDataBase , Nil} )
                aAdd( aItSDB, {"DB_QUANT" , SDA->DA_SALDO , Nil} )

                aItensSDB := {}
                aadd( aItensSDB, aitSDB )
                MATA265( aCabSDA, aItensSDB, 3)
            endif
        endif
        cAlias->(dbSkip())
    enddo
endif
cAlias->(dbCloseArea())

Return()
