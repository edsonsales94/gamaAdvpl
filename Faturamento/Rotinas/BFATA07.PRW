/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ BFATA07  ³ Por: Adalberto Moreno Batista ³ Data ³08.12.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza pesos liquido e bruto, volume e especie da NF     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Brasitech                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
#include "rwmake.ch"

User Function BFATA07()
Local aArea			:= GetArea()
Local cPerg			:= PadR("BFATA07", Len(SX1->X1_GRUPO))
Local aCabSX1		:= {"X1_GRUPO", "X1_ORDEM", "X1_PERGUNT", "X1_VARIAVL", "X1_TIPO", "X1_TAMANHO", "X1_DECIMAL", "X1_GSC", "X1_VAR01", "X1_DEF01", "X1_DEF02"}
Local aHlp01		:= {"Informe a série da Nota Fiscal", "", ""}
Local aRegs			:= {{cPerg,"01","Série         ?","mv_ch1","C",03,0,"G","mv_par01","",""}}
Local cCondicao
Private cCadastro	:= "Atualização de pesos líquido e bruto, volume e espécie"
Private aRotina 	:= {	{ "Pesquisa",	"AxPesqui",					0,1},;
								{ "Visualiza",	"U_FTA07_Atual(.f.)",	0,2},;
								{ "Atualiza",	"U_FTA07_Atual(.t.)",	0,3}}
Private aIndSF2	:= {}
Private bFiltraBrw:= {|| Nil}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montando o grupo de perguntas                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
U_BRASX1(aRegs, aCabSX1)
PutSX1Help("P." + cPerg + "01.", aHlp01, aHlp01, aHlp01)

if !Pergunte(cPerg, .T.)
	Return()
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criando filtro                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SF2")
cCondicao	:= "F2_FILIAL='" + xFilial("SF2") + "' .and. AllTrim(F2_SERIE)='" + AllTrim(mv_par01) + "' .and. F2_FIMP=' '"
bFiltraBrw	:= {|| FilBrowse("SF2", @aIndSF2, @cCondicao) }
Eval(bFiltraBrw)
mBrowse(,,,,"SF2")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a integridade da rotina                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SF2")
RetIndex("SF2")
dbClearFilter()
aEval(aIndSF2,{|x| Ferase(x[1] + OrdBagExt())})
RestArea(aArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ FTA07_Atual  ³ Por: Adalberto Moreno Batista       ³ Data ³08.12.2012³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function FTA07_Atual(lFaz)
Local nPesoL	:= SF2->F2_PLIQUI
Local nPesoB	:= SF2->F2_PBRUTO
Local nVolume	:= SF2->F2_VOLUME1
Local cEspecie	:= SF2->F2_ESPECI1
Local cCliente	:= SF2->F2_CLIENTE + " / " + SF2->F2_LOJA + " - "
Local cTpOrigem
Private oTela

if SF2->F2_TIPO $ 'DB'
	cCliente  += GetAdvFVal("SA2", "A2_NOME", xFilial("SA2") + SF2->F2_CLIENTE + SF2->F2_LOJA, 1)
	cTpOrigem := 'Fornecedor'
else
	cCliente  += GetAdvFVal("SA1", "A1_NOME", xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA, 1)
	cTpOrigem := 'Cliente'
endif

@ 132,16 To 440,566 Dialog oTela Title OemToAnsi("Informações da Nota Fiscal")

@ 10,010 Say OemToAnsi("Nota Fiscal") Size 40,8
@ 10,120 Say OemToAnsi("Série") Size 16,8
@ 10,195 Say OemToAnsi("Emissão") Size 25,8
@ 25,010 Say OemToAnsi(cTpOrigem) Size 40,8
@ 45,010 Say OemToAnsi("Peso Bruto") Size 40,8
@ 60,010 Say OemToAnsi("Peso Líquido") Size 40,8
@ 75,010 Say OemToAnsi("Volume") Size 40,8
@ 90,010 Say OemToAnsi("Espécie") Size 40,8

@ 09,055 Get SF2->F2_DOC Size 40,10 when .F.
@ 09,140 Get SF2->F2_SERIE Size 25,10 when .F.
@ 09,225 Get SF2->F2_EMISSAO Size 35,10 when .F.
@ 24,055 Get cCliente Size 205,10 when .F.
@ 44,055 Get nPesoB picture "@E 999,999.99" Size 60,10 when lFaz
@ 59,055 Get nPesoL picture "@E 999,999.99" Size 60,10 when lFaz
@ 74,055 Get nVolume picture "@E 999,999" Size 60,10 when lFaz
@ 89,055 Get cEspecie picture "@!" Size 100,10 when lFaz

@ 130,182 BmpButton Type 1 Action GravaInf(lFaz, nPesoB, nPesoL, nVolume, cEspecie)
@ 130,227 BmpButton Type 2 Action (oTela:End())

Activate Dialog oTela Centered

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ GravaInf     ³ Por: Adalberto Moreno Batista       ³ Data ³08.12.2012³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GravaInf(lFaz, nPesoB, nPesoL, nVolume1, cEspeci1)
if lFaz
	SF2->( RecLock("SF2",.F.) )
	SF2->F2_PBRUTO		:= nPesoB
	SF2->F2_PLIQUI		:= nPesoL
	SF2->F2_ESPECI1	:= cEspeci1
	SF2->F2_VOLUME1	:= nVolume1
	SF2->( MsUnlock() )
endif
Close(oTela)
Return()
