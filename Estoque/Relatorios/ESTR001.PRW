#Include "Protheus.ch" 
#include "rwmake.ch"                                            
#Include "TbiConn.ch"
#Include 'TOTVS.ch'


/*/
+-------------------------------------------------------------------------------+
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Programa  ¦ ESTR001    ¦ Autor ¦Orismar Silva         ¦ Data ¦ 17/11/2022 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ DESCRIÇÃO ¦ Relatorio de movimentação de produto.                         ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦ TABELAS   ¦                                                               ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
+-------------------------------------------------------------------------------+
/*/


User Function ESTR001()    

	Private oReport, oSection1
	Private cPerg    := PADR("ESTR001",Len(SX1->X1_GRUPO))

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
¦¦¦ Programa  ¦ ReportDef  ¦ Autor ¦Orismar Silva         ¦ Data ¦ 17/11/2022 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ DESCRIÇÃO ¦ Montar estrutura do relatório.                                ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦ TABELAS   ¦                                                               ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
+-------------------------------------------------------------------------------+
/*/

Static Function ReportDef()
	Private cTitulo := 'Saldo por Endereço x Empenho'

	// Cria as perguntas no SX1                                            
	CriaSx1()
	Pergunte(cPerg,.F.)


    oReport := TReport():New("ESTR001", cTitulo, cPerg , {|oReport| PrintReport(oReport)},"Emitirá Relatório de Saldo por Endereço x Empenho")

	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()

	oSection1 := TRSection():New(oReport,"Saldo por Endereço x Empenho",{""})
	oSection1:SetTotalInLine(.F.)

 	TRCell():new(oSection1, "C_END"  	  , "", "ENDEREÇO"              ,,10)
    TRCell():new(oSection1, "C_COD"  	  , "", "PRODUTO"               ,,15)
	TRCell():new(oSection1, "C_DES"  	  , "", "DESCRIÇÃO"             ,,20)	
	TRCell():new(oSection1, "C_ARM"  	  , "", "ARMAZÉM"               ,,10)
	TRCell():new(oSection1, "C_SLD"       , "", "SALDO ENDEREÇO"        ,,15)
	TRCell():new(oSection1, "C_EMP"       , "", "EMPENHO"               ,,10)



return (oReport)




/*/
+-------------------------------------------------------------------------------+
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Programa  ¦ PrintReport¦ Autor ¦Orismar Silva         ¦ Data ¦ 17/11/2022 ¦¦¦
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

    cQry := " SELECT C2_XEND,D4_COD,B1_DESC,D4_LOCAL,SUM(D4_QUANT) D4_QUANT, ISNULL(BF_QUANT,0) BF_QUANT "
    cQry += " FROM "+RetsQLName("SD4")+" SD4 "
    cQry += " FULL OUTER JOIN (SELECT C2_FILIAL,C2_NUM,C2_ITEM,C2_SEQUEN,C2_XEND  FROM "+RetsQLName("SC2")+" SC2 WHERE SC2.D_E_L_E_T_ = '' ) SC2 ON C2_FILIAL = D4_FILIAL AND D4_OP = C2_NUM+C2_ITEM+C2_SEQUEN "
    cQry += " FULL OUTER JOIN (SELECT BF_FILIAL,BF_PRODUTO,BF_LOCALIZ,BF_QUANT,BF_LOCAL FROM "+RetsQLName("SBF")+" SBF WHERE SBF.D_E_L_E_T_ = '' ) SBF ON BF_FILIAL = D4_FILIAL AND BF_PRODUTO = D4_COD AND C2_XEND = BF_LOCALIZ AND D4_LOCAL = BF_LOCAL "
	cQry += " FULL OUTER JOIN (SELECT B1_COD,B1_DESC  FROM "+RetsQLName("SB1")+" SB1 WHERE SB1.D_E_L_E_T_ = '' ) SB1 ON B1_COD = D4_COD "
    cQry += " WHERE SD4.D_E_L_E_T_ = '' "
    cQry += " AND D4_COD BETWEEN '"+mv_par01+"' AND '"+mv_par02+"'"
	cQry += " AND D4_LOCAL BETWEEN '"+mv_par03+"' AND '"+mv_par04+"'"
    cQry += " AND D4_QUANT > 0 "
    cQry += " AND D4_FILIAL = '"+XFILIAL("SD4")+"'"
    cQry += " GROUP BY C2_XEND,D4_COD,D4_LOCAL,BF_QUANT,B1_DESC "
    cQry += " ORDER BY D4_COD "   
   
    cQry := ChangeQuery(cQry)


	MEMOWRITE('ESTR001.SQL',cQry)

    dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),"XXX", .T., .F.)


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

          oSection1:Cell("C_END"):SetValue(XXX->C2_XEND)
          oSection1:Cell("C_COD"):SetValue(XXX->D4_COD)
		  oSection1:Cell("C_DES"):SetValue(XXX->B1_DESC)
          oSection1:Cell("C_ARM"):SetValue(XXX->D4_LOCAL)
          oSection1:Cell("C_SLD"):SetValue(XXX->BF_QUANT)
		  oSection1:Cell("C_EMP"):SetValue(XXX->D4_QUANT)
 
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
¦¦¦ Programa  ¦ CriaSx1    ¦ Autor ¦Orismar Silva         ¦ Data ¦ 17/11/2022 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ DESCRIÇÃO ¦ Criar as perguntas do relatório.                              ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦ TABELAS   ¦                                                               ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
+-------------------------------------------------------------------------------+
/*/
Static Function CriaSx1()

    PutSX1(cPerg,"01",PADR("Do Produto  ",29)+"?","","","mv_ch1","C",15,0,0,"G","","SB1","","",mv_par01)
    PutSX1(cPerg,"02",PADR("Ate Produto ",29)+"?","","","mv_ch2","C",15,0,0,"G","","SB1","","",mv_par02)
    PutSX1(cPerg,"03",PADR("Do Armazem  ",29)+"?","","","mv_ch3","C",02,0,0,"G","","NNR","","",mv_par03)
    PutSX1(cPerg,"04",PADR("Ate Armazem ",29)+"?","","","mv_ch4","C",02,0,0,"G","","NNR","","",mv_par04)
 
 Return


/*/
+-------------------------------------------------------------------------------+
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Programa  ¦ PutSx1     ¦ Autor ¦Orismar Silva         ¦ Data ¦ 17/11/2022 ¦¦¦
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

