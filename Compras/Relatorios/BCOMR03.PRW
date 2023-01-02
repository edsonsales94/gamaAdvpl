#Include "Protheus.ch" 
#include "rwmake.ch"                                            
#Include "TbiConn.ch"
#Include 'TOTVS.ch'
#include "topconn.ch"


/*/
+-------------------------------------------------------------------------------+
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Programa  ¦ BCOMR03    ¦ Autor ¦Orismar Silva         ¦ Data ¦ 21/10/2022 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ DESCRIÇÃO ¦ Relatorio de Solicitação de Compras  - MRP                    ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
+-------------------------------------------------------------------------------+
/*/


User Function BCOMR03()    

	Private oReport, oSection1
	Private cPerg    := PADR("BCOMR03",Len(SX1->X1_GRUPO))

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
¦¦¦ Programa  ¦ ReportDef  ¦ Autor ¦Orismar Silva         ¦ Data ¦ 21/10/2022 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ DESCRIÇÃO ¦ Montar estrutura do relatório.                                ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦ TABELAS   ¦                                                               ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
+-------------------------------------------------------------------------------+
/*/

Static Function ReportDef()
	Private cTitulo := 'Relação de Solicitacao'

	// Cria as perguntas no SX1                                            
	CriaSx1()
	Pergunte(cPerg,.F.)


    oReport := TReport():New("BCOMR03", cTitulo, cPerg , {|oReport| PrintReport(oReport)},"Emitirá Relação de Solicitacao")

	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()

	oSection1 := TRSection():New(oReport,"Relação de Solicitacao",{""})
	oSection1:SetTotalInLine(.F.)	
	TRCell():new(oSection1, "C_NSC"       , "", "NUMERO SC"             ,,10)
	TRCell():new(oSection1, "C_IT"        , "", "ITEM"                  ,,10)
	TRCell():new(oSection1, "C_PROD"      , "", "PRODUTO"               ,,10)
	TRCell():new(oSection1, "C_DESC"      , "", "DESCRICAO"             ,,25)
	TRCell():new(oSection1, "C_TP"        , "", "TIPO"                  ,,10)
	TRCell():new(oSection1, "C_GRP"       , "", "GRUPO"                 ,,10)
	TRCell():new(oSection1, "C_QTD"       , "", "QUANTIDADE"            ,,10)  
    TRCell():new(oSection1, "C_UM"        , "", "UM"                    ,,10)  	
    TRCell():new(oSection1, "C_CC"        , "", "C.CUSTO"               ,,10)  	    
    TRCell():new(oSection1, "C_DTEMIS"    , "", "DATA DE EMISSÃO"       ,,15)  	        
   	TRCell():new(oSection1, "C_DTENT"     , "", "ENTREGA SC"            ,,10)	
	TRCell():new(oSection1, "C_SOLIC"     , "", "SOLICITANTE"           ,,15)	    	
	TRCell():new(oSection1, "C_DTLIM"     , "", "DATA LIMITE DE COMPRA" ,,22)
	TRCell():new(oSection1, "C_SALSC"     , "", "SALDO SC"              ,,10)   
	TRCell():new(oSection1, "C_PRC"       , "", "PREÇO COMPRA"          ,,10)
	TRCell():new(oSection1, "C_FORN"      , "", "FORNECEDOR"            ,,25)	
	TRCell():new(oSection1, "C_SEQ"       , "", "SEQ. MRP"              ,,10)
			


return (oReport)




/*/
+-------------------------------------------------------------------------------+
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Programa  ¦ PrintReport¦ Autor ¦Orismar Silva         ¦ Data ¦ 21/10/2022 ¦¦¦
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
    Local cQry    := ""
	Local cOrigem := "PCPA144"
	Local cFil    := "01"
    

	oSection1 := oReport:Section(1)

	oSection1:Init()
	oSection1:SetHeaderSection(.T.)    

	//
  //SC1 - Solicitações de Compra
  //
  cQryAux := " EXEC sp_TEMPSCMRP "
  cQryAux += " '"+cOrigem+ "' "       // ORIGEM
  cQryAux += ",'"+cFil+"' "           // FILIAL
  cQryAux += ",'"+DTOS(mv_par04)+"' " // DATA INICIAL
  cQryAux += ",'"+DTOS(mv_par05)+"' " // DATA FINAL

  //Executando consulta e setando o total da régua
   TCQuery cQryAux New Alias "QRY_MPR"
 
    While QRY_MPR->(!Eof())
        //Percorre todos os registros gerados no processamento
        if !EMPTY(QRY_MPR->FORNECEDOR)
	            Begin Transaction                           
                    cQry :=" UPDATE "+RetSqlName("SC1")+" SET C1_XPRCCOM = "+StrTran(Transform( QRY_MPR->PRCCOMPRA,PesqPict("SC1","C1_XPRCCOM")),",",".")+", C1_XFORNEC = '"+ QRY_MPR->FORNECEDOR+"'" 
					cQry += " WHERE C1_ORIGEM = '"+cOrigem+"' AND C1_NUM ='"+QRY_MPR->C1_NUM+"'  AND C1_FILIAL ='"+XFILIAL("SC1")+"' AND D_E_L_E_T_='' AND C1_PRODUTO='"+QRY_MPR->C1_PRODUTO+"' AND C1_ITEM='"+QRY_MPR->C1_ITEM+"'"
                    TCSQLExec(cQry)
                End Transaction 
        endif

        QRY_MPR->(dbSkip())
    End
    QRY_MPR->(dbCloseArea())


    cQry :=" SELECT C1_FILIAL, C1_NUM, C1_ITEM, C1_PRODUTO,C1_DESCRI,B1_TIPO,B1_GRUPO, C1_QUANT,C1_UM,C1_CC,C1_EMISSAO,C1_DATPRF,C1_SOLICIT,(C1_QUANT-C1_QUJE) C1_QUJE,C1_XFORNEC,C1_XPRCCOM,C1_SEQMRP "
	cQry +=" FROM " + RetSqlName("SC1") + " SC1 (NOLOCK), " + RetSqlName("SB1") + " SB1 (NOLOCK)
	cQry +=" WHERE SC1.D_E_L_E_T_ = ''  AND SB1.D_E_L_E_T_ = '' 
	cQry +=" AND C1_PRODUTO = B1_COD
	cQry +=" AND C1_FILIAL = '"+XFILIAL("SC1")+"'
	cQry +=" AND C1_NUM BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
	if !EMPTY(mv_par03)
	   cQry +="	AND C1_SEQMRP = '"+mv_par03+"'" 
	endif
	cQry +=" AND C1_EMISSAO BETWEEN '"+DTOS(mv_par04)+"' AND '"+DTOS(mv_par05)+"' "    
   
    cQry := ChangeQuery(cQry)
    dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),"QRY_SC", .T., .F.)

    TCSETFIELD("QRY_SC","C1_EMISSAO","D",8,0)
    TCSETFIELD("QRY_SC","C1_DATPRF","D",8,0)

    If !USED() 
       MsgBox(cQuery+'. Query errada','Erro!!!','STOP')
	EndIf

	count to nReg

    dbSelectArea("QRY_SC")
	dbGoTop()

	oReport:SetMeter(nReg)

              
    While !(QRY_SC->(EoF()))

    	  If oReport:Cancel()
		     Exit
		  EndIf

          oSection1:Cell("C_NSC"):SetValue(QRY_SC->C1_NUM)
          oSection1:Cell("C_IT"):SetValue(QRY_SC->C1_ITEM)
          oSection1:Cell("C_PROD"):SetValue(QRY_SC->C1_PRODUTO)
          oSection1:Cell("C_DESC"):SetValue(QRY_SC->C1_DESCRI)
          oSection1:Cell("C_TP"):SetValue(QRY_SC->B1_TIPO)
		  oSection1:Cell("C_GRP"):SetValue(QRY_SC->B1_GRUPO)
          oSection1:Cell("C_QTD"):SetValue(QRY_SC->C1_QUANT)
          oSection1:Cell("C_UM"):SetValue(QRY_SC->C1_UM)
          oSection1:Cell("C_CC"):SetValue(QRY_SC->C1_CC)
          oSection1:Cell("C_DTEMIS"):SetValue(QRY_SC->C1_EMISSAO)
		  oSection1:Cell("C_DTENT"):SetValue(QRY_SC->C1_DATPRF)
          oSection1:Cell("C_SOLIC"):SetValue(QRY_SC->C1_SOLICIT)
          oSection1:Cell("C_DTLIM"):SetValue(QRY_SC->C1_DATPRF)
          oSection1:Cell("C_SALSC"):SetValue(QRY_SC->C1_QUJE)
          oSection1:Cell("C_PRC"):SetValue(QRY_SC->C1_XPRCCOM)
		  oSection1:Cell("C_FORN"):SetValue(QRY_SC->C1_XFORNEC)
          oSection1:Cell("C_SEQ"):SetValue(QRY_SC->C1_SEQMRP)
          oReport:IncMeter()
          oReport:SkipLine()
          oSection1:PrintLine()
            
          QRY_SC->(DbSkip())
    EndDo       
 
    QRY_SC->(DbCloseArea())
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


	PutSX1(cPerg, "01", PADR("Da SC              ",29)+"?","","", "mv_ch1" , "C", 06, 0, 0, "G", "",       "   ", "", "", "mv_par01")
	PutSX1(cPerg, "02", PADR("Ate SC             ",29)+"?","","", "mv_ch2" , "C", 06, 0, 0, "G", "",       "   ", "", "", "mv_par02")
	PutSX1(cPerg, "03", PADR("Ticket             ",29)+"?","","", "mv_ch3" , "C", 06, 0, 0, "G", "",       "   ", "", "", "mv_par03")
	PutSX1(cPerg, "04", PADR("Da Data Emissao    ",29)+"?","","", "mv_ch4" , "D", 08, 0, 0, "G", "",       "   ", "", "", "mv_par04")
	PutSX1(cPerg, "05", PADR("Ate Data Emissao   ",29)+"?","","", "mv_ch5" , "D", 08, 0, 0, "G", "",       "   ", "", "", "mv_par05")

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

