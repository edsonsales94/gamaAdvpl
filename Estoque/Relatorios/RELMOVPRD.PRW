#Include "Protheus.ch" 
#include "rwmake.ch"                                            
#Include "TbiConn.ch"
#Include 'TOTVS.ch'


/*/
+-------------------------------------------------------------------------------+
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Programa  ¦ RELMOVPRD  ¦ Autor ¦Orismar Silva         ¦ Data ¦ 21/09/2022 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ DESCRIÇÃO ¦ Relatorio de movimentação de produto.                         ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦ TABELAS   ¦                                                               ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
+-------------------------------------------------------------------------------+
/*/


User Function RELMOVPRD()    

	Private oReport, oSection1
	Private cPerg    := PADR("RELMOVPRD",Len(SX1->X1_GRUPO))

	oReport := ReportDef()
	If !Empty(oReport:uParam)
		Pergunte(oReport:uParam,.F.)
	EndIf
	oReport:PrintDialog()

Return



/*/
+-------------------------------------------------------------------------------+
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Programa  ¦ ReportDef  ¦ Autor ¦Orismar Silva         ¦ Data ¦ 21/09/2022 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ DESCRIÇÃO ¦ Montar estrutura do relatório.                                ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦ TABELAS   ¦                                                               ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
+-------------------------------------------------------------------------------+
/*/

Static Function ReportDef()
	Private cTitulo := 'Entrada de Notas Fiscais'

	// Cria as perguntas no SX1                                            
	CriaSx1()
	Pergunte(cPerg,.F.)


    oReport := TReport():New("RELMOVPRD", cTitulo, cPerg , {|oReport| PrintReport(oReport)},"Emitirá Relatório de Entrada de Notas Fiscais")

	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()

	oSection1 := TRSection():New(oReport,"Entrada de Notas Fiscais",{""})
	oSection1:SetTotalInLine(.F.)

 	TRCell():new(oSection1, "C_COD"  	  , "", "CÓDIGO"                  ,,10)
    TRCell():new(oSection1, "C_DESC"  	  , "", "DESCRIÇÃO"               ,,10)
	TRCell():new(oSection1, "C_GRP"  	  , "", "GRUPO"                   ,,10)	
	TRCell():new(oSection1, "C_ARM"  	  , "", "ARMAZÉM"                 ,,10)
	TRCell():new(oSection1, "C_SLD"       , "", "SALDO"                   ,,15)
	TRCell():new(oSection1, "C_QTDI"      , "", "QTDE. ENTRADAS INTERNA"  ,,10)
	TRCell():new(oSection1, "C_QTDE"      , "", "QTDE. ENTRADAS NF"       ,,10)
	TRCell():new(oSection1, "C_QTDS"      , "", "QTDE. SAIDAS INTERNA"    ,,10)
	TRCell():new(oSection1, "C_QTDF"      , "", "QTDE. SAIDAS NF"         ,,10)
	TRCell():new(oSection1, "C_DTS"       , "", "DATA ULTIMA SAÍDA"       ,,10)


return (oReport)




/*/
+-------------------------------------------------------------------------------+
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Programa  ¦ PrintReport¦ Autor ¦Orismar Silva         ¦ Data ¦ 21/09/2022 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ DESCRIÇÃO ¦ Gerar o relatório.                                            ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦ TABELAS   ¦                                                               ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
+-------------------------------------------------------------------------------+
/*/
Static Function PrintReport(oReport)
  	Local nReg
    Local cQry        := ""


	oSection1 := oReport:Section(1)

	oSection1:Init()
	oSection1:SetHeaderSection(.T.)     

	//Query para acumular quantidade de produtos
    cSB2 := " SELECT B2_COD, SUM(B2_QATU) AS B2_QATU,B2_LOCAL,B2_CM1 "
    cSB2 += " FROM "+RetSQLName("SB2")+" "
    cSB2 += " WHERE D_E_L_E_T_<>'*' AND B2_QATU <> 0 "
    cSB2 += " AND B2_FILIAL = '"+SB2->(XFILIAL("SB2"))+"'"
    cSB2 += " AND B2_LOCAL BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' " 
    cSB2 += " GROUP BY B2_COD,B2_LOCAL,B2_CM1"

    // Query para cálculo das entradas do produto
    cSD1 := " SELECT D1_COD, SUM(D1_QUANT) AS D1_QUANT, MAX(D1_DTDIGIT) AS D1_DTDIGIT "
    cSD1 += " FROM "+RetsQLName("SD1")+" SD1 "
    cSD1 += " INNER JOIN "+RetsQLName("SF4")+" SF4 ON SF4.D_E_L_E_T_ = ' ' AND D1_TES = F4_CODIGO "
    If mv_par11 == 1   // Se gera duplicata
	   cSD1 += " AND F4_ESTOQUE = 'S' "
    ElseIf mv_par11 == 2   // Se não gera duplicata
	   cSD1 += " AND F4_ESTOQUE = 'N' "
    Endif
    cSD1 += " WHERE SD1.D_E_L_E_T_ = ' ' AND D1_FILIAL = '"+SD1->(XFILIAL("SD1"))+"'"
    cSD1 += " AND D1_DTDIGIT BETWEEN '"+Dtos(mv_par01)+"' AND '"+Dtos(mv_par02)+"'"
    cSD1 += " AND D1_LOCAL BETWEEN '"+mv_par03+"' AND '"+mv_par04+"'"
    cSD1 += " AND D1_COD BETWEEN '"+mv_par05+"' AND '"+mv_par06+"'"
    cSD1 += " GROUP BY D1_COD"

    // Query para cálculo das saídas do produto
    cSD2 := " SELECT D2_COD, SUM(D2_QUANT) AS D2_QUANT, MAX(D2_EMISSAO) AS D2_EMISSAO "
    cSD2 += " FROM "+RetsQLName("SD2")+" SD2 "
    cSD2 += " INNER JOIN "+RetsQLName("SF4")+" SF4 ON SF4.D_E_L_E_T_ = ' ' AND D2_TES = F4_CODIGO "
    If mv_par11 == 1   // Se gera duplicata
	   cSD2 += " AND F4_ESTOQUE = 'S' "
    ElseIf mv_par11 == 2   // Se não gera duplicata
	   cSD2 += " AND F4_ESTOQUE = 'N' "
    Endif
    cSD2 += " WHERE SD2.D_E_L_E_T_ = ' ' AND D2_FILIAL = '"+SD2->(XFILIAL("SD2"))+"'"
    cSD2 += " AND D2_EMISSAO BETWEEN '"+Dtos(mv_par01)+"' AND '"+Dtos(mv_par02)+"'"
    cSD2 += " AND D2_LOCAL BETWEEN '"+mv_par03+"' AND '"+mv_par04+"'"
    cSD2 += " AND D2_COD BETWEEN '"+mv_par05+"' AND '"+mv_par06+"'"
    cSD2 += " GROUP BY D2_COD"

    // Query para cálculo dos movimentos de entradas do produto
    cED3 := " SELECT D3_COD AS D3_CODE, SUM(D3_QUANT) AS D3_ENTRA, MAX(D3_EMISSAO) AS D3_ENTMOV "
    cED3 += " FROM "+RetsQLName("SD3")+" SD3 "
    cED3 += " WHERE SD3.D_E_L_E_T_ = ' ' AND D3_FILIAL = '"+SD3->(XFILIAL("SD3"))+"'"
    cED3 += " AND D3_EMISSAO BETWEEN '"+Dtos(mv_par01)+"' AND '"+Dtos(mv_par02)+"'"
    cED3 += " AND D3_LOCAL BETWEEN '"+mv_par03+"' AND '"+mv_par04+"'"
	cED3 += " AND NOT EXISTS (SELECT SD3_.D3_NUMSEQ FROM SD3010 SD3_ WHERE  SD3_.D_E_L_E_T_ = ' ' AND SD3_.D3_FILIAL = SD3.D3_FILIAL AND SD3_.D3_EMISSAO = SD3.D3_EMISSAO AND SD3_.D3_LOCAL = SD3.D3_LOCAL  AND SD3_.D3_COD = SD3.D3_COD  AND SD3_.D3_NUMSEQ = SD3.D3_NUMSEQ AND SD3_.D3_ESTORNO = '' AND SD3_.D3_TM = '999' AND SD3_.D3_CF = 'RE4') "
    cED3 += " AND D3_COD BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' AND D3_ESTORNO = ' ' AND D3_TM <= '500' "
    cED3 += " GROUP BY D3_COD"

    // Query para cálculo dos movimentos de inventario
    cID3 := " SELECT D3_COD AS D3_CODI, SUM(D3_QUANT) AS D3_SAINV, MAX(D3_EMISSAO) AS D3_SAIINV "
    cID3 += " FROM "+RetsQLName("SD3")+" SD3 "
    cID3 += " WHERE SD3.D_E_L_E_T_ = ' ' AND D3_FILIAL = '"+SD3->(XFILIAL("SD3"))+"'"
    cID3 += " AND D3_EMISSAO BETWEEN '"+Dtos(mv_par01)+"' AND '"+Dtos(mv_par02)+"'"
    cID3 += " AND D3_LOCAL BETWEEN '"+mv_par03+"' AND '"+mv_par04+"'"
	cID3 += " AND NOT EXISTS (SELECT SD3_.D3_NUMSEQ FROM "+RetsQLName("SD3")+" SD3_ WHERE  SD3_.D_E_L_E_T_ = ' ' AND SD3_.D3_FILIAL = SD3.D3_FILIAL AND SD3_.D3_EMISSAO = SD3.D3_EMISSAO AND SD3_.D3_LOCAL = SD3.D3_LOCAL  AND SD3_.D3_COD = SD3.D3_COD  AND SD3_.D3_NUMSEQ = SD3.D3_NUMSEQ AND SD3_.D3_ESTORNO = '' AND SD3_.D3_TM = '499' AND SD3_.D3_CF = 'DE4') "
    cID3 += " AND D3_COD BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' AND D3_ESTORNO = ' ' AND D3_TM = '999' AND D3_CF = 'RE4' "
    cID3 += " GROUP BY D3_COD"


    // Query para cálculo dos movimentos de saídas do produto
    cSD3 := " SELECT D3_COD AS D3_CODS, SUM(D3_QUANT) AS D3_SAIDA, MAX(D3_EMISSAO) AS D3_SAIMOV "
    cSD3 += " FROM "+RetsQLName("SD3")+" SD3 "
    cSD3 += " WHERE SD3.D_E_L_E_T_ = ' ' AND D3_FILIAL = '"+SD3->(XFILIAL("SD3"))+"'"
    cSD3 += " AND D3_EMISSAO BETWEEN '"+Dtos(mv_par01)+"' AND '"+Dtos(mv_par02)+"'"
    cSD3 += " AND D3_LOCAL BETWEEN '"+mv_par03+"' AND '"+mv_par04+"'"
    cSD3 += " AND D3_COD BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' AND D3_ESTORNO = ' ' AND D3_TM > '500' AND D3_TM <> '999'"
    cSD3 += " GROUP BY D3_COD"

    // Query com as tabelas de movimentos já calculadas relacionadas ao produto
    cQry := " SELECT B1_COD, B1_DESC, B1_GRUPO, B1_ATIVO, BM_DESC,ISNULL(B2_LOCAL,'') AS B2_LOCAL, ISNULL(B2_QATU,0) AS B2_QATU, ISNULL(B2_CM1,0) AS B2_CM1,ISNULL(D1_QUANT,0) D1_QUANT, ISNULL(D3_ENTRA,0) AS D3_ENTRA, "
    cQry += " ISNULL(D1_DTDIGIT,'') AS D1_DTDIGIT,ISNULL(D2_QUANT,0) D2_QUANT, (ISNULL(D3_SAIDA,0)+ISNULL(D3_SAINV,0)) AS D3_QUANT, ISNULL(D2_EMISSAO,'') AS D2_EMISSAO "
    cQry += " FROM "+RetSqlName("SB1")+" SB1"
    cQry += " LEFT OUTER JOIN ("+cSB2+") SB2 ON B1_COD = B2_COD"
    cQry += " LEFT OUTER JOIN ("+cSD1+") SD1 ON B1_COD = D1_COD"
    cQry += " LEFT OUTER JOIN ("+cSD2+") SD2 ON B1_COD = D2_COD"
    cQry += " LEFT OUTER JOIN ("+cED3+") SD3E ON B1_COD = D3_CODE"
    cQry += " LEFT OUTER JOIN ("+cSD3+") SD3S ON B1_COD = D3_CODS"
    cQry += " LEFT OUTER JOIN ("+cID3+") SD3I ON B1_COD = D3_CODI"
    cQry += " LEFT OUTER JOIN "+RetSqlName("SBM")+" SBM ON B1_GRUPO = BM_GRUPO "
    cQry += " WHERE SB1.D_E_L_E_T_ = ' ' AND SBM.D_E_L_E_T_ = ' ' "
    cQry += " AND B1_COD BETWEEN '"+mv_par05+"' AND '"+mv_par06+"'"
    cQry += " AND B1_TIPO BETWEEN '"+mv_par07+"' AND '"+mv_par08+"'"
    cQry += " AND B1_GRUPO BETWEEN '"+mv_par09+"' AND '"+mv_par10+"'"
    cQry += " AND B1_MSBLQL <> '1' "
	cQry += " AND B2_LOCAL <> '' "
    cQry += " ORDER BY B1_GRUPO, B2_LOCAL, B1_COD"
   
   
    cQry := ChangeQuery(cQry)


	MEMOWRITE('RELMOVPRD.SQL',cQry)

    dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),"XXX", .T., .F.)

    TCSETFIELD("XXX","D1_DTDIGIT","D",8,0)
    TCSETFIELD("XXX","D2_EMISSAO","D",8,0)


    If !USED() 
       MsgBox(cQuery+'. Query errada','Erro!!!','STOP')
	EndIf

	count to nReg

    dbSelectArea("XXX")
	dbGoTop()

	oReport:SetMeter(nReg)

              
    While !(XXX->(EoF()))

    	  If oReport:Cancel()
		     Exit
		  EndIf

          oSection1:Cell("C_COD"):SetValue(XXX->B1_COD)
          oSection1:Cell("C_DESC"):SetValue(XXX->B1_DESC)
		  oSection1:Cell("C_GRP"):SetValue(XXX->B1_GRUPO)
          oSection1:Cell("C_ARM"):SetValue(XXX->B2_LOCAL)
          oSection1:Cell("C_SLD"):SetValue(XXX->B2_QATU)
		  oSection1:Cell("C_QTDI"):SetValue(XXX->D3_ENTRA)
          oSection1:Cell("C_QTDE"):SetValue(XXX->D1_QUANT)
		  oSection1:Cell("C_QTDS"):SetValue(XXX->D3_QUANT)
		  oSection1:Cell("C_QTDF"):SetValue(XXX->D2_QUANT)
	      oSection1:Cell("C_DTS"):SetValue(XXX->D2_EMISSAO)
          oReport:IncMeter()
          oReport:SkipLine()
          oSection1:PrintLine()
            
          XXX->(DbSkip())
    EndDo       
 
    XXX->(DbCloseArea())
    oSection1:Finish()
   
Return



/*/
+-------------------------------------------------------------------------------+
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Programa  ¦ CriaSx1    ¦ Autor ¦Orismar Silva         ¦ Data ¦ 21/09/2022 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ DESCRIÇÃO ¦ Criar as perguntas do relatório.                              ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦ TABELAS   ¦                                                               ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
+-------------------------------------------------------------------------------+
/*/
Static Function CriaSx1()

    PutSX1(cPerg,"01",PADR("Do Período  ",29)+"?","","","mv_ch1","D",08,0,0,"G","",""   ,"","",mv_par01)
    PutSX1(cPerg,"02",PADR("Ate Período ",29)+"?","","","mv_ch2","D",08,0,0,"G","",""   ,"","",mv_par02)
    PutSX1(cPerg,"03",PADR("Do Armazem  ",29)+"?","","","mv_ch3","C",02,0,0,"G","","NNR","","",mv_par03)
    PutSX1(cPerg,"04",PADR("Ate Armazem ",29)+"?","","","mv_ch4","C",02,0,0,"G","","NNR","","",mv_par04)
    PutSX1(cPerg,"05",PADR("Do Produto  ",29)+"?","","","mv_ch5","C",15,0,0,"G","","SB1","","",mv_par05)
    PutSX1(cPerg,"06",PADR("Ate Produto ",29)+"?","","","mv_ch6","C",15,0,0,"G","","SB1","","",mv_par06)
    PutSX1(cPerg,"07",PADR("Do Tipo     ",29)+"?","","","mv_ch7","C",02,0,0,"G","","02" ,"","",mv_par07)
    PutSX1(cPerg,"08",PADR("Ate Tipo    ",29)+"?","","","mv_ch8","C",02,0,0,"G","","02" ,"","",mv_par08)
    PutSX1(cPerg,"09",PADR("Do Grupo    ",29)+"?","","","mv_ch9","C",04,0,0,"G","","SBM1","","",mv_par09)
    PutSX1(cPerg,"10",PADR("Ate Grupo   ",29)+"?","","","mv_ch10","C",04,0,0,"G","","SBM1","","",mv_par10)
    PutSX1(cPerg,"11",PADR("Gera Financeiro ",29)+"?","","","mv_ch11","N",01,0,0,"C","","","","",mv_par11,"SIM","","","","NÃO","","","TODOS","","","","")
Return


/*/
+-------------------------------------------------------------------------------+
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Programa  ¦ PutSx1     ¦ Autor ¦Orismar Silva         ¦ Data ¦ 21/09/2022 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ DESCRIÇÃO ¦ Cria as perguntas na tabela SX1 usando rotina padrão.         ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦ TABELAS   ¦                                                               ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
+-------------------------------------------------------------------------------+
/*/
Static Function PutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,;
	cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,;
	cF3, cGrpSxg,cPyme,;
	cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,;
	cDef02,cDefSpa2,cDefEng2,;
	cDef03,cDefSpa3,cDefEng3,;
	cDef04,cDefSpa4,cDefEng4,;
	cDef05,cDefSpa5,cDefEng5,;
	aHelpPor,aHelpEng,aHelpSpa,cHelp)

LOCAL aArea := GetArea()
Local cKey  := "P."+AllTrim(cGrupo)+AllTrim(cOrdem)+"."
Local lPort := .f.
Local lSpa  := .f.
Local lIngl := .f. 

cPyme    := Iif(cPyme == Nil, " " , cPyme )
cF3      := Iif(cF3 == NIl, " ", cF3 )
cGrpSxg  := Iif(cGrpSxg == Nil, " " , cGrpSxg )
cCnt01   := Iif(cCnt01 == Nil, "",cCnt01 )
cHelp	 := If(cHelp==Nil,"",cHelp)

dbSelectArea("SX1")
dbSetOrder(1)

If !(dbSeek(cGrupo + cOrdem ))

   cPergunt := If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt)
	cPerSpa	:= If(! "?" $ cPerSpa  .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa)
	cPerEng	:= If(! "?" $ cPerEng  .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng)

	Reclock("SX1" , .T. )
	Replace X1_GRUPO   With cGrupo
	Replace X1_ORDEM   With cOrdem
	Replace X1_PERGUNT With cPergunt
	Replace X1_PERSPA  With cPerSpa
	Replace X1_PERENG  With cPerEng
	Replace X1_VARIAVL With cVar
	Replace X1_TIPO    With cTipo
	Replace X1_TAMANHO With nTamanho
	Replace X1_DECIMAL With nDecimal
	Replace X1_PRESEL  With nPresel
	Replace X1_GSC     With cGSC
	Replace X1_VALID   With cValid

	Replace X1_VAR01   With cVar01

	Replace X1_F3      With cF3
	Replace X1_GRPSXG  With cGrpSxg

	If Fieldpos("X1_PYME") > 0
		If cPyme != Nil
			Replace X1_PYME With cPyme
		Endif
	Endif

	Replace X1_CNT01   With cCnt01
	If cGSC == "C"			// Mult Escolha
		Replace X1_DEF01   With cDef01
		Replace X1_DEFSPA1 With cDefSpa1
		Replace X1_DEFENG1 With cDefEng1

		Replace X1_DEF02   With cDef02
		Replace X1_DEFSPA2 With cDefSpa2
		Replace X1_DEFENG2 With cDefEng2

		Replace X1_DEF03   With cDef03
		Replace X1_DEFSPA3 With cDefSpa3
		Replace X1_DEFENG3 With cDefEng3

		Replace X1_DEF04   With cDef04
		Replace X1_DEFSPA4 With cDefSpa4
		Replace X1_DEFENG4 With cDefEng4

		Replace X1_DEF05   With cDef05
		Replace X1_DEFSPA5 With cDefSpa5
		Replace X1_DEFENG5 With cDefEng5
	Endif

	Replace X1_HELP  With cHelp

	PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

	MsUnlock()
Else

   lPort := ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT)
   lSpa  := ! "?" $ X1_PERSPA  .And. ! Empty(SX1->X1_PERSPA)
   lIngl := ! "?" $ X1_PERENG  .And. ! Empty(SX1->X1_PERENG)

   If lPort .Or. lSpa .Or. lIngl
		RecLock("SX1",.F.)
		If lPort 
         SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?"
		EndIf
		If lSpa 
			SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?"
		EndIf
		If lIngl
			SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?"
		EndIf
		SX1->(MsUnLock())
	EndIf
Endif

RestArea( aArea )

Return

