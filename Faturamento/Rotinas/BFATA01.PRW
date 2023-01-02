/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ BFATA01  ³ Por: Adalberto Moreno Batista ³ Data ³21.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preenche dados de expedição em notas fiscais               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Brasitech                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
#include "rwmake.ch"

User Function BFATA01()
Local _cFiltro, _cIndex, _cKey, _nIndex
Local aArea 		:= GetArea()
Private cCadastro 	:= "Informações de Expedição"
Private aRotina 	:={	{ "Pesquisa",	"AxPesqui",			0,1},;
						{ "Inclui",		"U_FTA01_Inclui()",	0,3}}
Private aIndSF2   	:= {}
Private bFiltraBrw 	:= {|| Nil}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executo a rotina somente se os campos existirem                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if SF2->( FieldPos("F2_XDTEXPE") ) > 0 .and. SF2->( FieldPos("F2_XHREXPE") ) > 0 .and. SF2->( FieldPos("F2_XTRESPE") ) > 0

	dbSelectArea("SF2")

	if MsgBox("Deseja visualizar somente as notas não preenchidas?","Pergunta","YESNO")
	
		cCondicao := "F2_FILIAL=='"+xFilial("SF2")+"' .and. Empty(F2_XDTEXPE) .and. F2_TIPO='N' "
		bFiltraBrw := {|| FilBrowse("SF2",@aIndSF2,@cCondicao) }
		Eval(bFiltraBrw)
		mBrowse(,,,,"SF2")
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Restaura a integridade da rotina                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SF2")
		RetIndex("SF2")
		dbClearFilter()
		aEval(aIndSF2,{|x| Ferase(x[1]+OrdBagExt())})
		
	else

		mBrowse(,,,,"SF2")
	
	endif
		
else

	MsgBox("Os campos de informações sobre expedição não existem. Entre em contato com o depto de TI.","Informação","INFO")

endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaurando a area                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aArea)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ FTA01_Inclui ³ Por: Adalberto Moreno Batista       ³ Data ³ 21/04/11 ³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function FTA01_Inclui()
Local _cPerg	:= PadR("FTA01I",Len(SX1->X1_GRUPO))
Local _aCabSX1	:= {"X1_GRUPO","X1_ORDEM","X1_PERGUNT","X1_VARIAVL","X1_TIPO","X1_TAMANHO","X1_DECIMAL","X1_GSC","X1_VAR01","X1_DEF01","X1_DEF02"}
Local _aHlp01	:= {"Informe a data de emissao inicial","da nota fiscal",""}
Local _aHlp02	:= {"Informe a data de emissao final","da nota fiscal",""}
Local _aRegs	:= {	{_cPerg,"01","Da Emissao         ?","mv_ch1","D",08,0,"G","mv_par01","",""},;
						{_cPerg,"02","Ate a Emissao      ?","mv_ch2","D",08,0,"G","mv_par02","",""}}
Local cQuery
Local dDtExped	:= cTOd("")
Local cHrExped	:= space(5)
Local cTransp   := space(6)
Local cNomeTra	:= space(30)
Local _aArqTMP	:= {{"TB_MARCA"  ,"C",02,00},;
					{"TB_DOC"    ,"C",09,00},;
					{"TB_SERIE"  ,"C",03,00},;
					{"TB_EMISSAO","D",08,00},;
					{"TB_CLIENTE","C",06,00},;
					{"TB_LOJA"   ,"C",02,00},;
					{"TB_NOMECLI","C",30,00},;
					{"TB_XDTEXPE","D",08,00},;
					{"TB_XHREXPE","C",05,00},;
					{"TB_XTRESPE","C",30,00},;
					{"TB_EST"    ,"C",02,00},;
					{"TB_VALBRUT","N",12,02},;
					{"TB_TRANSP" ,"C",06,00},;
					{"TB_NOMETRA","C",30,00},;
					{"TB_RECNO"  ,"N",10,00}}

Local _cDBFTMP	:= CriaTrab (_aArqTMP , .t.)

Private cMarca	:= GetMark()
Private aCampos	:= {{"TB_MARCA"		,"","  "},;
					{"TB_DOC"		,"","Nota Fiscal"},;
					{"TB_SERIE"		,"","Serie"},;
					{"TB_EMISSAO"	,"","Dt.Emissao"},;
					{"TB_CLIENTE"	,"","Cliente"},;
					{"TB_LOJA"		,"","Loja"},;
					{"TB_NOMECLI"	,"","Nome Cliente"},;
					{"TB_XDTEXPE"	,"","Data Exped."},;
					{"TB_XHREXPE"	,"","Hora Exped."},;
					{"TB_XTRESPE"	,"","Transp.Exped."},;
					{"TB_EST"		,"","Estado"},;
					{"TB_VALBRUT"	,"","Valor Nota","@E 999,999,999.99"},;					
					{"TB_TRANSP"	,"","Transportadora"},;
					{"TB_NOMETRA"	,"","Nome Transportadora"}}
Private oExp, oMark

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montando o grupo de perguntas                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
U_BRASX1(_aRegs,_aCabSX1)	//Funcao contida dentro do BCFGA01.prw
PutSX1Help("P."+_cPerg+"01.",_aHlp01,_aHlp01,_aHlp01)
PutSX1Help("P."+_cPerg+"02.",_aHlp02,_aHlp02,_aHlp02)

if !Pergunte(_cPerg,.T.)
	Return()
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Selecionando registros                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT F2_DOC F2_DOC, F2_SERIE, F2_EMISSAO, F2_CLIENTE, F2_LOJA, F2_TRANSP, F2_EST, F2_VALBRUT, F2_XDTEXPE, F2_XHREXPE, F2_XTRESPE, SF2.R_E_C_N_O_ REGISTRO " 
cQuery += "FROM "+RetSQLName("SF2")+" SF2 "
cQuery += "WHERE SF2.F2_FILIAL='"+xFilial("SF2")+"' AND SF2.F2_EMISSAO BETWEEN '"+dtos(mv_par01)+"' AND '"+dtos(mv_par02)+"' AND SF2.F2_XDTEXPE=' ' AND SF2.F2_TIPO='N' AND SF2.D_E_L_E_T_=' ' "	//SF2.F2_FIMP='S' AND 
cQuery += "ORDER BY F2_SERIE,F2_DOC"
//memowrite("c:\bfata01.sql",cQuery)

if Select("TRB") > 0
	dbSelectArea("TRB")
	dbCloseArea()
endif
	
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRB", .F., .T.)
tcSetField("TRB", "F2_EMISSAO", "D")
tcSetField("TRB", "F2_XDTEXPE", "D")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montanto tabela temporaria                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if Select("TMP") > 0
	dbSelectArea("TMP") 
	dbCloseArea()
endif
dbUseArea(.T.,,_cDBFTMP,"TMP",.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravando em tabela temporaria                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TRB")
dbGoTop()
if !eof()
	dbSelectArea("TRB")
	do while !eof()
		TMP->(RecLock("TMP",.T.))
		TMP->TB_DOC		:= TRB->F2_DOC
		TMP->TB_SERIE	:= TRB->F2_SERIE
		TMP->TB_EMISSAO	:= TRB->F2_EMISSAO
		TMP->TB_CLIENTE	:= TRB->F2_CLIENTE
		TMP->TB_LOJA	:= TRB->F2_LOJA
		TMP->TB_NOMECLI	:= GetAdvFVal("SA1","A1_NOME",xFilial("SA1")+TRB->F2_CLIENTE+TRB->F2_LOJA,1)
		TMP->TB_TRANSP	:= TRB->F2_TRANSP
		TMP->TB_NOMETRA	:= GetAdvFVal("SA4","A4_NOME",xFilial("SA4")+TRB->F2_TRANSP,1)
		TMP->TB_EST		:= TRB->F2_EST
		TMP->TB_VALBRUT	:= TRB->F2_VALBRUT
		TMP->TB_XDTEXPE	:= TRB->F2_XDTEXPE
		TMP->TB_XHREXPE	:= TRB->F2_XHREXPE
		TMP->TB_XTRESPE	:= TRB->F2_XTRESPE
	
		TMP->TB_RECNO	:= TRB->REGISTRO
		TMP->(MsUnlock())

		dbSkip()
	enddo	
endif

if Select("TRB") > 0
	dbSelectArea("TRB")
	dbCloseArea()
endif

dbSelectArea("TMP")
dbGoTop()
if !eof()

	@ 060, 001 TO 590, 850 Dialog oExp Title OemToAnsi("Selecao de Notas Fiscais")
	@ 05,05 Say OemToAnsi("Data Exped") Size 35,8
	@ 05,45 Get dDtExped Size 40,10 Valid !empty(dDtExped)
	@ 18,05 Say OemToAnsi("Hora Exped") Size 35,8
	@ 18,45 Get cHrExped Picture "99:99" Size 30,10 Valid !empty(cHrExped)
	@ 31,05 Say OemToAnsi("Transp. Exped") Size 35,8
	@ 31,45 Get cNomeTra Picture "@!" Size 185,10 Valid !Empty(cNomeTra)

	oMark	:= MsSelect():New("TMP","TB_MARCA","",aCampos,.F.,@cMarca,{044,002,247,425})
	@ 250, 320 BmpButton Type 1 Action GravaExp(dDtExped, cHrExped, cNomeTra)
	@ 250, 370 BmpButton Type 2 Action (oExp:End())
	Activate Dialog oExp Centered

else

	MsgBox("Notas não localizadas no período informado."+chr(13)+"Possíveis causas: Não existem NFs no período informado ou já tiveram as informações de expedição preenchidas.","Atenção","INFO")

endif

if Select("TMP") > 0
	dbSelectArea("TMP")
	dbCloseArea()
endif
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ GravaExp     ³ Por: Adalberto Moreno Batista       ³ Data ³ 21/04/11 ³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GravaExp(dDtExped, cHrExped, cTransp)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravando informacoes sobre a expedicao                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TMP->(dbGoTop())
do while TMP->(!eof())
	if TMP->(Marked("TB_MARCA"))
		SF2->(dbGoTo(TMP->TB_RECNO))
		SF2->(RecLock("SF2",.F.))
		SF2->F2_XDTEXPE := dDtExped
		SF2->F2_XHREXPE := cHrExped
		SF2->F2_XTRESPE := cTransp
		SF2->(MsUnlock())
	endif
	TMP->(dbSkip())
enddo

MsgBox("As informações sobre a expedição foram gravadas com sucesso!","Atenção","INFO")

Close(oExp)
Return()
