#Include "Protheus.ch" 
#include "rwmake.ch"                                            
#Include "TbiConn.ch"
#Include 'TOTVS.ch'


/*/
+-------------------------------------------------------------------------------+
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Programa  ¦ XRELENTR   ¦ Autor ¦Orismar Silva         ¦ Data ¦ 21/09/2022 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ DESCRIÇÃO ¦ Relatorio de entrada de notas fiscais                         ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦ TABELAS   ¦ Considerando as CFOP 1101, 2101, 3101, 1124.                  ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
+-------------------------------------------------------------------------------+
/*/


User Function XRELENTR()    

	Private oReport, oSection1
	Private cPerg    := PADR("XRELENTR",Len(SX1->X1_GRUPO))

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


    oReport := TReport():New("XRELENTR", cTitulo, cPerg , {|oReport| PrintReport(oReport)},"Emitirá Relatório de Entrada de Notas Fiscais")

	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()

	oSection1 := TRSection():New(oReport,"Entrada de Notas Fiscais",{""})
	oSection1:SetTotalInLine(.F.)

 	TRCell():new(oSection1, "C_FIL"  	  , "", "FILIAL"                ,,10)
    TRCell():new(oSection1, "C_ITEM"  	  , "", "ITEM NF"               ,,10)	
	TRCell():new(oSection1, "C_PRD"       , "", "PRODUTO"               ,,15)
	TRCell():new(oSection1, "C_UN"        , "", "UNIDADE"               ,,10)
	TRCell():new(oSection1, "C_ARM"       , "", "ARMAZÉM"               ,,10)
	TRCell():new(oSection1, "C_QTD"       , "", "QUANTIDADE"            ,,10)
	TRCell():new(oSection1, "C_VLRU"      , "", "VALOR UNITARIO"        ,,15)
	TRCell():new(oSection1, "C_VLRT"      , "", "VALOR TOTAL"           ,,15)
	TRCell():new(oSection1, "C_TP"        , "", "TIPO ENTRADA"          ,,15)  
    TRCell():new(oSection1, "C_FORN"      , "", "FORNECEDOR"            ,,10)  	
    TRCell():new(oSection1, "C_NOME"      , "", "NOME FORNECEDOR"       ,,25)  	    
    TRCell():new(oSection1, "C_DOC"       , "", "DOCUMENTO"             ,,10)  	        
   	TRCell():new(oSection1, "C_DTEMIS"    , "", "DATA EMISSÃO"          ,,10)	
	TRCell():new(oSection1, "C_PO"        , "", "NÚMERO PO"             ,,10)	    	
	TRCell():new(oSection1, "C_DTDIG"     , "", "DATA DIGITAÇÃO"        ,,10)
	TRCell():new(oSection1, "C_ITPED"     , "", "ITEM PEDIDO"           ,,15)   
	TRCell():new(oSection1, "C_CODF"      , "", "CÓDIGO FISCAL"         ,,15)	
			


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
    Local cQry := ""


	oSection1 := oReport:Section(1)

	oSection1:Init()
	oSection1:SetHeaderSection(.T.)     
    
     cQry :="   SELECT D1_FILIAL,D1_ITEM,D1_COD,D1_UM,D1_LOCAL,	D1_QUANT,D1_VUNIT,D1_TOTAL,D1_TES,D1_FORNECE,A2_NOME,D1_DOC,D1_EMISSAO,D1_PEDIDO,D1_DTDIGIT, D1_ITEMPC,D1_CF "
	 cQry +="	FROM SD1010 SD1 (NOLOCK)    "
	 cQry +="	INNER JOIN SA2010 SA2 (NOLOCK) ON SA2.D_E_L_E_T_ = '' AND D1_FORNECE = A2_COD AND D1_LOJA = A2_LOJA "
	 cQry +="	WHERE SD1.D_E_L_E_T_ = ''
     cQry +="	AND D1_CF IN ('1101','2101','3101','1124')   "
     cQry +="	AND D1_DTDIGIT  BETWEEN '"+DTOS(mv_par01)+"' AND '"+DTOS(mv_par02)+"' "
     cQry +="	AND D1_COD BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
     cQry +="	AND D1_FORNECE BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' "
	 cQry +="	ORDER BY D1_DTDIGIT DESC    "
    
   
     cQry := ChangeQuery(cQry)
     dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),"QRY_ENT", .T., .F.)

     TCSETFIELD("QRY_ENT","D1_DTDIGIT","D",8,0)
     TCSETFIELD("QRY_ENT","D1_EMISSAO","D",8,0)


    If !USED() 
       MsgBox(cQuery+'. Query errada','Erro!!!','STOP')
	EndIf

	count to nReg

    dbSelectArea("QRY_ENT")
	dbGoTop()

	oReport:SetMeter(nReg)

              
    While !(QRY_ENT->(EoF()))

    	  If oReport:Cancel()
		     Exit
		  EndIf

          oSection1:Cell("C_FIL"):SetValue(QRY_ENT->D1_FILIAL)
          oSection1:Cell("C_ITEM"):SetValue(QRY_ENT->D1_ITEM)
          oSection1:Cell("C_PRD"):SetValue(QRY_ENT->D1_COD)
          oSection1:Cell("C_UN"):SetValue(QRY_ENT->D1_UM)
          oSection1:Cell("C_ARM"):SetValue(QRY_ENT->D1_LOCAL)
		  oSection1:Cell("C_QTD"):SetValue(QRY_ENT->D1_QUANT)
          oSection1:Cell("C_VLRU"):SetValue(QRY_ENT->D1_VUNIT)
          oSection1:Cell("C_VLRT"):SetValue(QRY_ENT->D1_TOTAL)
          oSection1:Cell("C_TP"):SetValue(QRY_ENT->D1_TES)
          oSection1:Cell("C_FORN"):SetValue(QRY_ENT->D1_FORNECE)
		  oSection1:Cell("C_NOME"):SetValue(QRY_ENT->A2_NOME)
          oSection1:Cell("C_DOC"):SetValue(QRY_ENT->D1_DOC)
          oSection1:Cell("C_DTEMIS"):SetValue(QRY_ENT->D1_EMISSAO)
          oSection1:Cell("C_PO"):SetValue(QRY_ENT->D1_PEDIDO)
          oSection1:Cell("C_DTDIG"):SetValue(QRY_ENT->D1_DTDIGIT)
		  oSection1:Cell("C_ITPED"):SetValue(QRY_ENT->D1_ITEMPC)
          oSection1:Cell("C_CODF"):SetValue(QRY_ENT->D1_CF)
          oReport:IncMeter()
          oReport:SkipLine()
          oSection1:PrintLine()
            
          QRY_ENT->(DbSkip())
    EndDo       
 
    QRY_ENT->(DbCloseArea())
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


	PutSX1(cPerg, "01", PADR("Da Data Digitação   ",29)+"?","","", "mv_ch1" , "D", 08, 0, 0, "G", "",       "   ", "", "", "mv_par01")
	PutSX1(cPerg, "02", PADR("Ate Data Digitação  ",29)+"?","","", "mv_ch2" , "D", 08, 0, 0, "G", "",       "   ", "", "", "mv_par02")
	PutSX1(cPerg, "03", PADR("Do Produto          ",29)+"?","","", "mv_ch3" , "C", 15, 0, 0, "G", "",       "SB1", "", "", "mv_par03")
	PutSX1(cPerg, "04", PADR("Ate Produto         ",29)+"?","","", "mv_ch4" , "C", 15, 0, 0, "G", "",       "SB1", "", "", "mv_par04")
	PutSX1(cPerg, "05", PADR("Do Fornecedor       ",29)+"?","","", "mv_ch5" , "C", 06, 0, 0, "G", "",       "SA2", "", "", "mv_par05")
	PutSX1(cPerg, "06", PADR("Ate Fornecedor      ",29)+"?","","", "mv_ch6" , "C", 06, 0, 0, "G", "",       "SA2", "", "", "mv_par06")

Return Nil


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

