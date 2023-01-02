#INCLUDE "MATR255.CH"
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MATR255   ³ Autor ³Felipe Nunes Toledo    ³ Data ³ 07/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Posi‡„o Detalhada do Estoque por Endereco.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß           
*/
User Function MATR255()
Local oReport

If FindFunction("TRepInUse") .And. TRepInUse()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:= ReportDef()
	oReport:PrintDialog()
Else
	MATR255R3()
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³Felipe Nunes Toledo    ³ Data ³07/07/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATR255			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()
Local oReport
Local oSection1
Local oSection2
Local oSection3
Local cTitle    := OemToAnsi(STR0001) //"Posicao Detalhada do Estoque por Endereco"
Local aOrdem    := {STR0005,STR0006}  //" Armazem + Grupo + Produto "###" Produto + Armazem "
Local cAliasSBF := "SBF"
Local nTamSX1   := Len(SX1->X1_GRUPO)
#IFDEF TOP
	cAliasSBF := GetNextAlias()
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:= TReport():New("MATR255",cTitle,"MTR255", {|oReport| ReportPrint(oReport,cAliasSBF)},OemToAnsi(STR0002)+" "+OemToAnsi(STR0003)+" "+OemToAnsi(STR0004)) //##"Neste relat¢rio ‚ possivel obter uma posi‡„o de quantidade por"##"produto/lote/endereco/status, o que permite o mapeamento perfeito"##"de cada Endereco."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta grupo de perguntas (MTR255)                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX1")
If dbSeek(PADR("MTR255",nTamSX1)+"06") .And. X1_GSC == "C"
	Reclock("SX1",.f.)
	dbDelete()
	MsUnlock()
EndIf	
If dbSeek(PADR("MTR255",nTamSX1)+"07") .And. X1_GSC == "C"
	Reclock("SX1",.f.)
	dbDelete()
	MsUnlock()
EndIf
If dbSeek(PADR("MTR255",nTamSX1)+"08") .And. X1_GSC == "C"
	Reclock("SX1",.f.)
	dbDelete()
	MsUnlock()
EndIf
If dbSeek(PADR("MTR255",nTamSX1)+"09") .And. X1_GSC == "C"
	Reclock("SX1",.f.)
	dbDelete()
	MsUnlock()
EndIf
PutSx1("MTR255","06","Do Armazem         ?","+De Deposito       ?","From Warehouse     ?","mv_ch6","C",02,0,0,"G","","","","","mv_par06","","","","  ","","","","","","","","","","","","",{"Armazem inicial a ser considerado na"    ,"filtragem do cadastro de Produtos." },{"Inicial Warehouse to consider when"   ,"filtering th Product file."},{"Deposito inicial a ser considerada"	    ,"en el filtro del archivo de Producto."})
PutSx1("MTR255","07","Ate o Armazem      ?","+Ate o Deposito    ?","To Warehouse       ?","mv_ch7","C",02,0,0,"G","","","","","mv_par07","","","","ZZ","","","","","","","","","","","","",{"Armazem final a ser considerado na"      ,"filtragem do cadastro de Produtos." },{"Final Warehouse to consider when"     ,"filtering th Product file."},{"Deposito final a ser considerada"       ,"en el filtro del archivo de Producto."})
PutSx1("MTR255","08","Do Endereco        ?","+De Localizacion   ?","From Localization  ?","mv_ch8","C",15,0,0,"G","","","","","mv_par08","","","","","","","","","","","","","","","","",  {"Endereco inicial a ser considerado na","filtragem do cadastro de Produtos." },{"Inicial Localization to consider when","filtering th Product file."},{"Localizacion inicial a ser considerada"	,"en el filtro del archivo de Producto."})
PutSx1("MTR255","09","Ate o Endereco     ?","+Ate Localizacion  ?","To Localization    ?","mv_ch9","C",15,0,0,"G","","","","","mv_par09","","","","","","","","","","","","","","","","",  {"Endereco final a ser considerado na"  ,"filtragem do cadastro de Produtos." },{"Final Localization to consider when"  ,"filtering th Product file."},{"Localizacion final a ser considerada"	,"en el filtro del archivo de Producto."})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas (MTR255)                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01     // Produto 	de                               ³
//³ mv_par02     // Produto 	ate                              ³
//³ mv_par03     // Situacao 	de                               ³
//³ mv_par04     // Situacao	ate                              ³
//³ mv_par05     // Imprimir  Normal/Ambos                       ³
//³ mv_par06     // Do Armazem                                   ³
//³ mv_par07     // Ate o Armazem                                ³
//³ mv_par08     // Da Localizacao                               ³
//³ mv_par09     // Ate a Localizacao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(oReport:GetParam(),.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao das secoes utilizadas pelo relatorio                            ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Section1                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1 := TRSection():New(oReport,STR0025,{"SBF","SB1"},aOrdem) //"Posicao Detalhada do Estoque por Endereco"
oSection1:SetHeaderPage()

TRCell():New(oSection1,'BF_LOCAL'	,'SBF',/*Titulo*/,/*Picture*/,iif(tamsx3('BF_LOCAL')[1] < 12,12,tamsx3('BF_LOCAL')[1]),/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'B1_TPGAMA' 	,'SB1',/*Titulo*/,/*Picture*/,iif(tamsx3('B1_TPGAMA')[1] < 12,12,tamsx3('B1_TPGAMA')[1]),/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'BM_DESC'   	,'SBM',/*Titulo*/,/*Picture*/,iif(tamsx3('BM_DESC')[1] < 12,12,tamsx3('BM_DESC')[1]),/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'BF_PRODUTO'	,'SBF',/*Titulo*/,/*Picture*/,iif(tamsx3('BF_PRODUTO')[1] < 12,12,tamsx3('BF_PRODUTO')[1]),/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'B1_DESC' 	,'SB1',/*Titulo*/,/*Picture*/,iif(tamsx3('B1_DESC')[1] < 12,12,tamsx3('B1_DESC')[1]),/*lPixel*/,/*{|| code-block de impressao }*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ oSection2                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection2 := TRSection():New(oSection1,STR0026,{"SBF","SB1","SB8"},/*Ordem*/) //"Posicao Detalhada do Estoque por Endereco"
oSection2:SetHeaderPage()

TRCell():New(oSection2,'BF_LOTECTL'	,'SBF',/*Titulo*/,/*Picture*/,iif(tamsx3('BF_LOTECTL')[1] < 10,10,tamsx3('BF_LOTECTL')[1]),/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oSection2,'BF_NUMLOTE'	,'SBF',/*Titulo*/,/*Picture*/,iif(tamsx3('BF_NUMLOTE')[1] < 6,6,tamsx3('BF_NUMLOTE')[1]),/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oSection2,'B8_DTVALID'	,'SB8',/*Titulo*/,PesqPict('SB8','B8_DTVALID'),12,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oSection2,'BF_LOCALIZ'	,'SBF',/*Titulo*/,/*Picture*/,iif(tamsx3('BF_LOCALIZ')[1] < 12,12,tamsx3('BF_LOCALIZ')[1]),/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oSection2,'BF_NUMSERI'	,'SBF',/*Titulo*/,/*Picture*/,iif(tamsx3('BF_NUMSERI')[1] < 12,12,tamsx3('BF_NUMSERI')[1]),/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oSection2,'DD_MOTIVO' 	,'SDD',/*Titulo*/,/*Picture*/,iif(tamsx3('DD_MOTIVO')[1] < 2,2,tamsx3('DD_MOTIVO')[1]),/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.T.)
TRCell():New(oSection2,'DescSitua' 	,'SX5', STR0021  , ''        , 16        ,/*lPixel*/,  {|| '' }                      ,,,,,,.T.)
TRCell():New(oSection2,'DD_OBSERVA'	,'SDD',/*Titulo*/,/*Picture*/,iif(tamsx3('DD_OBSERVA')[1] < 12,12,tamsx3('DD_OBSERVA')[1]),/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.T.)
TRCell():New(oSection2,'B1_UM'  	,'SB1',/*Titulo*/,/*Picture*/,iif(tamsx3('B1_UM')[1] < 12,12,tamsx3('B1_UM')[1]),/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.T.)
TRCell():New(oSection2,'BF_QUANT'	,'SBF',/*Titulo*/,/*Picture*/,18,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oSection2,'C_UNIT'	,'SBF',/*Titulo*/,/*Picture*/,18,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oSection2,'C_TOTAL'	,'SBF',/*Titulo*/,/*Picture*/,18,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oSection2,'BF_EMPENHO'	,'SBF',/*Titulo*/,/*Picture*/,18,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oSection2,'DC_QUANT'	,'SDC', STR0022  ,/*Picture*/,18,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oSection2,'Disponivel','SBF', STR0023  ,PesqPict("SBF","BF_QUANT"),18,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT",,,.F.)
TRCell():New(oSection2,'BF_LOCAL' 	,'SBF',/*Titulo*/,/*Picture*/,18,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.T.)
TRCell():New(oSection2,'B1_GRUPO' 	,'SB1',/*Titulo*/,/*Picture*/,18,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ oSection3                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection3 := TRSection():New(oSection2,STR0027,{"SBF","SB1","SB8"},/*Ordem*/) //"Posicao Detalhada do Estoque por Endereco"
oSection3:SetHeaderPage(.F.)
oSection3:SetHeaderSection(.F.)

TRCell():New(oSection3,'BF_LOTECTL'	,'SBF',/*Titulo*/,/*Picture*/,iif(tamsx3('BF_LOTECTL')[1] < 12,12,tamsx3('BF_LOTECTL')[1]),/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,'BF_NUMLOTE'	,'SBF',/*Titulo*/,/*Picture*/,iif(tamsx3('BF_NUMLOTE')[1] < 12,12,tamsx3('BF_NUMLOTE')[1]),/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,'B8_DTVALID'	,'SB8',/*Titulo*/,/*Picture*/,16,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,'BF_LOCALIZ'	,'SBF',/*Titulo*/,/*Picture*/,iif(tamsx3('BF_LOCALIZ')[1] < 12,12,tamsx3('BF_LOCALIZ')[1]),/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,'BF_NUMSERI'	,'SBF',/*Titulo*/,/*Picture*/,iif(tamsx3('BF_NUMSERI')[1] < 12,12,tamsx3('BF_NUMSERI')[1]),/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oSection3,'DD_MOTIVO' 	,'SDD',/*Titulo*/,/*Picture*/,iif(tamsx3('DD_MOTIVO')[1] < 12,12,tamsx3('DD_MOTIVO')[1]),/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,'DescSitua' 	,'SX5', STR0021  , ''        , 16        ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,'DD_OBSERVA'	,'SDD',/*Titulo*/,/*Picture*/,iif(tamsx3('DD_OBSERVA')[1] < 12,12,tamsx3('DD_OBSERVA')[1]),/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,'B1_UM'  	,'SB1',/*Titulo*/,/*Picture*/,iif(tamsx3('B1_UM')[1] < 12,12,tamsx3('B1_UM')[1]),/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,'BF_QUANT'	,'SBF',/*Titulo*/,/*Picture*/, 18,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,'C_UNIT'	,'SBF',/*Titulo*/,/*Picture*/, 18,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,'C_TOTAL'	,'SBF',/*Titulo*/,/*Picture*/, 18,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,'BF_EMPENHO'	,'SBF',/*Titulo*/,/*Picture*/, 18,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,'DC_QUANT'	,'SDC',/*Titulo*/,/*Picture*/, 18,/*lPixel*/,/*{|| code-block de impressao }*/)

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint ³ Autor ³Felipe Nunes Toledo  ³ Data ³07/07/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportPrint devera ser criada para todos  ³±±
±±³          ³os relatorios que poderao ser agendados pelo usuario.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatorio                           ³±±
±±³          ³ExpC1: String contendo o Alias Principal                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATR255			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport, cAliasSBF)
Local oSection1  := oReport:Section(1)
Local oSection2  := oReport:Section(1):Section(1)
Local oSection3  := oReport:Section(1):Section(1):Section(1)
Local nOrdem     := oSection1:GetOrder()
Local l300SalNeg := GetMv('MV_MT300NG', .F., .F.) // Indica se permite saldo negativo (DEFAULT = .F.)
Local lImpBlock  := (mv_par05==2)
Local lQuery     := .F.
Local cDescBloq, nBloqueio
Local oBreak
Local oFunction
Local cWhere
Local cOrderBy
Local cFilter, cIndex, cIndexDD
Local cProdAnt
Local cJoin
Local nTotBlock
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Prepara Arquivo de Trabalho p/Impressao                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cFileTRB   := ""
Local aCampos    := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definindo a Quebra³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBreak := TRBreak():New(oSection1,oSection1:Cell('BF_PRODUTO'),STR0028,.F.) //"Total do Produto"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Defindo os totalizadores do relatorio³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oFunction := TRFunction():New(oSection2:Cell('BF_QUANT'  ),NIL,"SUM",oBreak,NIL,/*Picture*/,/*uFormula*/,.F.,.F.)
oFunction := TRFunction():New(oSection2:Cell('C_TOTAL'  ),NIL,"SUM",oBreak,NIL,/*Picture*/,/*uFormula*/,.F.,.F.)
oFunction := TRFunction():New(oSection2:Cell('BF_EMPENHO'),NIL,"SUM",oBreak,NIL,/*Picture*/,/*uFormula*/,.F.,.F.)
oFunction := TRFunction():New(oSection2:Cell('Disponivel'),NIL,"SUM",oBreak,NIL,/*Picture*/,/*uFormula*/,.F.,.F.)
oFunction := TRFunction():New(oSection2:Cell('DC_QUANT'  ),NIL,"SUM",oBreak,NIL,/*Picture*/,/*uFormula*/,.F.,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Determinando o titulo do Relatorio³            		
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOrdem == 1
	oReport:SetTitle(oReport:Title()+" ("+STR0005+")") //"Posicao Detalhada do Estoque por Endereco"##"Armazem + Grupo + Produto"
ElseIf nOrdem == 2
	oReport:SetTitle(oReport:Title()+" ("+STR0006+")") //"Posicao Detalhada do Estoque por Endereco"##"Produto + Armazem"
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtragem do relatorio                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF TOP

	lQuery := .T.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Transforma parametros Range em expressao SQL                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MakeSqlExpr(oReport:GetParam())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query do relatorio                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    
    cWhere := "%"
 	If l300SalNeg //-- Considera registros no SBF com saldo negativo
	 	cWhere += "SBF.BF_QUANT <> 0"
	Else //-- Considera somente registros no SBF que possuirem quantidade maior que zero
		cWhere += "SBF.BF_QUANT > 0"
	EndIf
 	cWhere += "%"
 	
 	cJoin := "% BF_NUMLOTE = Case When BF_NUMLOTE <> '" + CriaVar("BF_NUMLOTE",.F.) +"' Then SB8.B8_NUMLOTE Else '" + CriaVar("BF_NUMLOTE",.F.) +"' END %"

	cOrderBy := "%" 	
 	If nOrdem == 1
		cOrderBy += "SBF.BF_FILIAL, SBF.BF_LOCAL, SB1.B1_TPGAMA, SBF.BF_PRODUTO, SBF.BF_LOTECTL, SBF.BF_NUMLOTE"
	ElseIf nOrdem == 2
		cOrderBy += "SBF.BF_FILIAL, SBF.BF_PRODUTO, SBF.BF_LOCAL, SBF.BF_LOTECTL, SBF.BF_NUMLOTE"
	Endif	 
	cOrderBy += "%"
	 	
 	BEGIN REPORT QUERY oSection1
 	BeginSql Alias cAliasSBF

		SELECT SBF.BF_FILIAL, SBF.BF_LOCAL, SBF.BF_PRODUTO, SB1.B1_DESC, SB1.B1_GRUPO, SB1.B1_TPGAMA, SBF.BF_LOCALIZ,
		SBF.BF_NUMSERI, SBF.BF_LOTECTL, SBF.BF_NUMLOTE, SB1.B1_UM, SUM(SBF.BF_QUANT) BF_QUANT,
		B2_CMFIM1 C_UNIT, (SUM(SBF.BF_QUANT) * B2_CMFIM1) C_TOTAL,
		SUM(SBF.BF_EMPENHO) BF_EMPENHO
	       
		FROM %table:SBF% SBF
		
		JOIN %table:SB1% SB1 ON 
		SB1.B1_FILIAL = %xFilial:SB1% AND 
		SB1.%NotDel%                  AND 
		SB1.B1_COD    = BF_PRODUTO
		
		INNER JOIN %table:SB2% SB2 ON 
		SB2.%NotDel%  
		AND B2_FILIAL=BF_FILIAL
		AND B2_COD=BF_PRODUTO
		AND B2_LOCAL=BF_LOCAL

		
		
		LEFT JOIN %table:SB8% SB8 ON 
		SB8.B8_FILIAL = %xFilial:SB8% AND
		SB8.%NotDel% AND
		SB8.B8_PRODUTO = BF_PRODUTO AND
		SB8.B8_LOCAL   = BF_LOCAL AND
	   	SB8.B8_NUMLOTE = BF_NUMLOTE AND
		SB8.B8_LOTECTL = BF_LOTECTL AND
		SB8.B8_SALDO <> 0
		
		WHERE 
		SBF.BF_FILIAL = %xFilial:SBF% AND
  		SBF.BF_PRODUTO BETWEEN %Exp:mv_par01% AND %Exp:mv_par02% AND
  		SBF.BF_LOCAL BETWEEN %Exp:mv_par06% AND %Exp:mv_par07% AND
  		SBF.BF_LOCALIZ BETWEEN %Exp:mv_par08% AND%Exp:mv_par09% AND
 		%Exp:cWhere% AND
		SBF.%NotDel% AND
		%Exp:cJoin%
		
		GROUP BY SBF.BF_FILIAL, SBF.BF_LOCAL, SBF.BF_PRODUTO, SB1.B1_DESC, SB1.B1_GRUPO, SB1.B1_TPGAMA, SBF.BF_LOCALIZ,
		SBF.BF_NUMSERI, SBF.BF_LOTECTL , SBF.BF_NUMLOTE, SB1.B1_UM,B2_CMFIM1

		ORDER BY %Exp:cOrderBy%

	EndSql 
	END REPORT QUERY oSection1
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria Indice de trabalho para o SDD                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea('SDD')
	dbSetOrder(1)
	cIndexDD  := 'DD_FILIAL + DD_LOCAL + DD_PRODUTO + DD_LOTECTL + DD_NUMLOTE + DD_LOCALIZ + DD_NUMSERI'
	cArqTmpDD := CriaTrab(NIL,.F.)
	IndRegua('SDD', cArqTmpDD, cIndexDD,,,STR0010) //"Selecionando Registros ..."
	nIndexDD  := RetIndex('SDD')
	dbSetOrder(nIndexDD+1)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posicionamento das tabelas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TRPosition():New(oSection1,"SX5",1,{|| xFilial("SX5") +"IC"+(cAliasSBF)->B1_TPGAMA}) 

#ELSE
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Transforma parametros Range em expressao ADVPL                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MakeAdvplExpr(oReport:GetParam())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria Indice de Trabalho                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOrdem == 1
		cIndex  := "BF_LOCAL+BF_PRODUTO+BF_LOTECTL+BF_NUMLOTE"
	ElseIf nOrdem ==2
		cIndex  := "BF_PRODUTO+BF_LOCAL+BF_LOTECTL+BF_NUMLOTE"
    EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Condicao de Filtragem do SBF                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	cFilter := 'BF_FILIAL == "'+xFilial("SBF")+'".And. BF_PRODUTO >= "'+mv_par01+'" .And.'
	cFilter += 'BF_PRODUTO <= "'+mv_par02+'" .And. BF_LOCAL >= "'+mv_par06+'" .And.'
	cFilter += 'BF_LOCAL <= "'+mv_par07+'" .And. BF_LOCALIZ >= "'+mv_par08+'" .And. BF_LOCALIZ <= "'+mv_par09+'"'

	oSection1:SetFilter(cFilter,cIndex)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria Indice de trabalho para o SDD                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea('SDD')
	dbSetOrder(1)
	cIndexDD  :="DD_FILIAL + DD_LOCAL + DD_PRODUTO + DD_LOTECTL + DD_NUMLOTE"
	cArqTmpDD := CriaTrab(NIL,.F.)
	IndRegua( "SDD", cArqTmpDD, cIndexDD, , ,STR0010)	//"Selecionando Registros ..."
	nIndexDD  := RetIndex( "SDD" )
	dbSetIndex(cArqTmpDD+OrdBagExt())
	dbSetOrder(nIndexDD+1) 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posicionamento das tabelas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	TRPosition():New(oSection1,"SB1",1,{|| xFilial("SB1") + (cAliasSBF)->BF_PRODUTO })
	TRPosition():New(oSection1,"SX5",1,{|| xFilial("SX5") +"IC"+ SB1->B1_TPGAMA})

#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definindo as secoes filhas para utilizarem a query da secao pai³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection2:SetParentQuery()
oSection3:SetParentQuery()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inibindo celulas para impressao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection2:Cell('DD_MOTIVO' ):Hide()
oSection2:Cell('DescSitua' ):Hide()
oSection2:Cell('DD_OBSERVA'):Hide()
If nOrdem == 1
	oSection2:Cell('BF_LOCAL'):Hide()
	oSection2:Cell('BF_LOCAL'):HideHeader()
	oSection2:Cell('B1_GRUPO'):Hide()
	oSection2:Cell('B1_GRUPO'):HideHeader()
ElseIf nOrdem ==2
	oSection1:Cell('BF_LOCAL'):Hide()
	oSection1:Cell('BF_LOCAL'):HideHeader()
	oSection1:Cell('B1_GRUPO'):Hide()
	oSection1:Cell('B1_GRUPO'):HideHeader()	
	oSection1:Cell('BM_DESC' ):Hide()
	oSection1:Cell('BM_DESC' ):HideHeader()	
EndIf
oSection3:Cell('BF_NUMLOTE'):Hide()
oSection3:Cell('BF_QUANT'  ):Hide()
oSection3:Cell('C_UNIT'  ):Hide()
oSection3:Cell('C_TOTAL'  ):Hide()
oSection3:Cell('BF_EMPENHO'):Hide()
oSection3:Cell('BF_EMPENHO'):Hide()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicio da impressao do fluxo do relatorio                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:SetMeter( SBF->(LastRec()) )
oSection1:Init()
While !oReport:Cancel() .And. !(cAliasSBF)->(Eof())
	oReport:SkipLine()
	dbSelectArea('SX5')
	dbSetOrder(1)
	If dbSeek(xFilial('SX5')+'IC'+(cAliasSBF)->B1_TPGAMA, .F.)
	  cDescBloq := X5Descri()
	EndIf
    oSection1:Cell('BM_DESC'):SetValue(cDescBloq)
    oSection1:PrintLine() // Impressao da secao 1
    oReport:SkipLine()    
    cProdAnt := xFilial('SBF')+(cAliasSBF)->BF_LOCAL +(cAliasSBF)->BF_PRODUTO 
    While !(cAliasSBF)->(Eof()) .And. xFilial('SBF')+(cAliasSBF)->BF_LOCAL +(cAliasSBF)->BF_PRODUTO == cProdAnt
	    If lImpBlock // Se mv_par04 == 2
	    	nTotBlock := 0
	    	If dbSeek(cSeekSDD:=xFilial('SDD')+(cAliasSBF)->BF_LOCAL+(cAliasSBF)->BF_PRODUTO+(cAliasSBF)->BF_LOTECTL+(cAliasSBF)->BF_NUMLOTE+(cAliasSBF)->BF_LOCALIZ+(cAliasSBF)->BF_NUMSERI, .F.)
	 	   		Do While !SDD->(Eof()) .And. cSeekSDD == SDD->DD_FILIAL+SDD->DD_LOCAL+SDD->DD_PRODUTO+SDD->DD_LOTECTL+SDD->DD_NUMLOTE+SDD->DD_LOCALIZ+SDD->DD_NUMSERI
					If SDD->DD_MOTIVO < mv_par03 .Or. SDD->DD_MOTIVO > mv_par04
						SDD->(dbSkip())
						Loop
					EndIf
		    		nTotBlock += SDD->DD_SALDO
		    		SDD->(dbSkip())
		   		EndDo
		   	EndIf

			oSection2:Init()
        	SB8->(dbSetOrder(3))
        	SB8->( dbSeek( xFilial("SB8")+(cAliasSBF)->(BF_PRODUTO + BF_LOCAL + BF_LOTECTL + If(Rastro((cAliasSBF)->BF_PRODUTO, 'S'),(cAliasSBF)->BF_NUMLOTE,''))) )
        	oSection2:Cell('B8_DTVALID'):SetValue(SB8->B8_DTVALID)
	    	oSection2:Cell('BF_QUANT'):SetValue((cAliasSBF)->BF_QUANT)
	    	oSection2:Cell('C_UNIT'):SetValue((cAliasSBF)->C_UNIT)
	    	oSection2:Cell('C_TOTAL'):SetValue((cAliasSBF)->C_TOTAL)
	    	oSection2:Cell('BF_EMPENHO'):SetValue((cAliasSBF)->BF_EMPENHO - nTotBlock)
	  	    oSection2:Cell('DC_QUANT'):SetValue( nTotBlock )
   			oSection2:Cell('Disponivel'):SetValue( oSection2:Cell('BF_QUANT'):GetValue() - oSection2:Cell('BF_EMPENHO'):GetValue() - oSection2:Cell('DC_QUANT'):GetValue()   )
	    Else
	    	oSection2:Init()
        	SB8->(dbSetOrder(3))
        	SB8->( dbSeek( xFilial("SB8")+(cAliasSBF)->(BF_PRODUTO + BF_LOCAL + BF_LOTECTL + If(Rastro((cAliasSBF)->BF_PRODUTO, 'S'),(cAliasSBF)->BF_NUMLOTE,''))) )
        	oSection2:Cell('B8_DTVALID'):SetValue(SB8->B8_DTVALID)
	        oSection2:Cell('BF_QUANT'):SetValue((cAliasSBF)->BF_QUANT)
	        	        oSection2:Cell('C_UNIT'):SetValue((cAliasSBF)->C_UNIT)
  	        	        oSection2:Cell('C_TOTAL'):SetValue((cAliasSBF)->C_TOTAL)
   	    	oSection2:Cell('BF_EMPENHO'):SetValue((cAliasSBF)->BF_EMPENHO)
	   	    oSection2:Cell('DC_QUANT'):SetValue(0)
   			oSection2:Cell('Disponivel'):SetValue( oSection2:Cell('BF_QUANT'):GetValue() - oSection2:Cell('BF_EMPENHO'):GetValue() - oSection2:Cell('DC_QUANT'):GetValue()   )
   		EndIf	    
   
	    oReport:IncMeter()
	    oSection2:PrintLine() // Impressao da secao 2
		If lImpBlock // Se mv_par04 == 2
			dbSelectArea('SDD')
			If dbSeek(cSeekSDD:=xFilial('SDD')+(cAliasSBF)->BF_LOCAL+(cAliasSBF)->BF_PRODUTO+(cAliasSBF)->BF_LOTECTL+(cAliasSBF)->BF_NUMLOTE+(cAliasSBF)->BF_LOCALIZ+(cAliasSBF)->BF_NUMSERI, .F.)
				oReport:ThinLine()
				Do While !SDD->(Eof()) .And. cSeekSDD == SDD->DD_FILIAL+SDD->DD_LOCAL+SDD->DD_PRODUTO+SDD->DD_LOTECTL+SDD->DD_NUMLOTE+SDD->DD_LOCALIZ+SDD->DD_NUMSERI
					If SDD->DD_MOTIVO < mv_par03 .Or. SDD->DD_MOTIVO > mv_par04
						dbSelectArea('SDD')
						dbSkip()
						Loop
					EndIf
					cDescBloq := ''
					nBloqueio := 0
					dbSelectArea('SX5')
					dbSetOrder(1)
					If dbSeek(xFilial('SX5')+'E1'+SDD->DD_MOTIVO, .F.)
						cDescBloq := X5Descri()
					EndIf
					dbSelectArea('SDC')
					dbSetOrder(1) //-- DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI
					If dbSeek(cSeekSDC:=xFilial('SDC')+SDD->DD_PRODUTO+SDD->DD_LOCAL+'SDD'+SDD->DD_DOC+'    '+SDD->DD_LOTECTL+SDD->DD_NUMLOTE+SDD->DD_LOCALIZ+SDD->DD_NUMSERI, .F.)
						Do While !SDC->(Eof()) .And. cSeekSDC == DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI
							nBloqueio := SDC->DC_QUANT
							dbSelectArea('SDC')
							dbSkip()
						EndDo
					EndIf
					oSection3:Init()
					oSection3:Cell('BF_LOTECTL'):SetValue( STR0024         )
					oSection3:Cell('B8_DTVALID'):SetValue( SDD->DD_DTVALID )
					oSection3:Cell('DD_MOTIVO' ):SetValue( SDD->DD_MOTIVO  )
					oSection3:Cell('DescSitua' ):SetValue( cDescBloq       )
					oSection3:Cell('DD_OBSERVA'):SetValue( SDD->DD_OBSERVA )
					oSection3:Cell('DC_QUANT'  ):SetValue( nBloqueio       )
					
					oSection3:PrintLine() // Impressao da secao 3
					oSection3:Finish()
					SDD->(dbSkip())
				EndDo
				oReport:SkipLine()
			EndIf
		EndIf
		(cAliasSBF)->(dbSkip())
    EndDo
    oSection2:Finish()
EndDo
oSection1:Finish()
(cAliasSBF)->(DbCloseArea()) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga indice de trabalho SDD                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea('SDD')
RetIndex('SDD')
Set Filter To
fErase(cArqTmpDD+OrdBagExt())
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MATR255  ³ Autor ³ Alex Egydio           ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Posi‡„o Detalhada do Estoque por Endereco                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Revis„o  ³ Alex Egydio                              ³ Data ³ 24.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³FernandoJoly³03/11/98³XXXXXX³Ajuste para o ano 2000.                   ³±±
±±³Fernando J. ³09/12/98³18638A³Imprimir Prod. sem Contrl. de Lote/S.Lote.³±±
±±³Wagner      ³30/03/99³20633A³Indregua com SQL                          ³±±
±±³Cesar       ³30/03/99³XXXXXX³Manutencao na SetPrint()                  ³±±
±±³Fernando J. ³05/05/98³WAGNER³RevisÆo geral no programa.                ³±±
±±³CesarValadao³13/07/99³20169A³Acerto Para N Pular Pagina Qdo Muda Almox.³±±
±±³Patricia Sal³24/05/00³XXXXXX³Alt. da Tabela "03" ("SX5") para "SBM".   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User FUNCTION MATR255R3()

LOCAL Tamanho  := "G"
LOCAL titulo   := STR0001	//"Posicao Detalhada do Estoque por Endereco"
LOCAL cDesc1   := STR0002	//"Neste relat¢rio ‚ possivel obter uma posi‡„o de quantidade por       "
LOCAL cDesc2   := STR0003	//"produto/lote/endereco/status, o que permite o mapeamento perfeito "
LOCAL cDesc3   := STR0004	//"de cada Endereco."
LOCAL cString  := "SB2"
LOCAL aOrd     := {STR0005,STR0006}	//" Armazem + Grupo + Produto "###" Produto + Armazem "
LOCAL wnrel    := "MATR255"
Local nTamSX1  := Len(SX1->X1_GRUPO)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis tipo Private padrao de todos os relatorios         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aReturn    := {STR0007,1,STR0008, 2, 2, 1, "",1 }	//"Zebrado"###"Administracao"
PRIVATE nLastKey   := 0 ,cPerg := "MTR255"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01     // Produto 	de                               ³
//³ mv_par02     // Produto 	ate                              ³
//³ mv_par03     // Situacao 	de                               ³
//³ mv_par04     // Situacao	ate                              ³
//³ mv_par05     // Imprimir  Normal/Ambos                       ³
//³ mv_par06     // Do Armazem                                   ³
//³ mv_par07     // Ate o Armazem                                ³
//³ mv_par08     // Da Localizacao                               ³
//³ mv_par09     // Ate a Localizacao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX1")
If dbSeek(PADR("MTR255",nTamSX1)+"06") .And. X1_GSC == "C"
	Reclock("SX1",.F.)
	dbDelete()
	MsUnlock()
EndIf	
If dbSeek(PADR("MTR255",nTamSX1)+"07") .And. X1_GSC == "C"
	Reclock("SX1",.F.)
	dbDelete()
	MsUnlock()
EndIf
If dbSeek(PADR("MTR255",nTamSX1)+"08") .And. X1_GSC == "C"
	Reclock("SX1",.F.)
	dbDelete()
	MsUnlock()
EndIf
If dbSeek(PADR("MTR255",nTamSX1)+"09") .And. X1_GSC == "C"
	Reclock("SX1",.F.)
	dbDelete()
	MsUnlock()
EndIf
PutSx1("MTR255","06","Do Armazem         ?","+De Deposito       ?","From Warehouse     ?","mv_ch6","C",02,0,0,"G","","","","","mv_par06","","","","  ","","","","","","","","","","","","",{"Armazem inicial a ser considerado na"    ,"filtragem do cadastro de Produtos." },{"Inicial Warehouse to consider when"   ,"filtering th Product file."},{"Deposito inicial a ser considerada"	    ,"en el filtro del archivo de Producto."})
PutSx1("MTR255","07","Ate o Armazem      ?","+Ate o Deposito    ?","To Warehouse       ?","mv_ch7","C",02,0,0,"G","","","","","mv_par07","","","","ZZ","","","","","","","","","","","","",{"Armazem final a ser considerado na"      ,"filtragem do cadastro de Produtos." },{"Final Warehouse to consider when"     ,"filtering th Product file."},{"Deposito final a ser considerada"       ,"en el filtro del archivo de Producto."})
PutSx1("MTR255","08","Do Endereco        ?","+De Localizacion   ?","From Localization  ?","mv_ch8","C",15,0,0,"G","","","","","mv_par08","","","","","","","","","","","","","","","","",  {"Endereco inicial a ser considerado na","filtragem do cadastro de Produtos." },{"Inicial Localization to consider when","filtering th Product file."},{"Localizacion inicial a ser considerada"	,"en el filtro del archivo de Producto."})
PutSx1("MTR255","09","Ate o Endereco     ?","+Ate Localizacion  ?","To Localization    ?","mv_ch9","C",15,0,0,"G","","","","","mv_par09","","","","","","","","","","","","","","","","",  {"Endereco final a ser considerado na"  ,"filtragem do cadastro de Produtos." },{"Final Localization to consider when"  ,"filtering th Product file."},{"Localizacion final a ser considerada"	,"en el filtro del archivo de Producto."})
Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho)

If nLastKey == 27
	Set Filter to
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Set Filter to
	Return
Endif

RptStatus({|lEnd| R255IMP(aOrd,@lEnd,wnRel,titulo,Tamanho)},titulo)

RETURN NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ R255IMP  ³ Autor ³ Alex Egydio           ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime Posi‡„o Detalhada do Estoque                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR255                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Revis„o  ³ Alex Egydio                              ³ Data ³ 24.11.97 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function R255IMP(aOrd,lEnd,WnRel,titulo,Tamanho)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Especificas deste relatorio                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cAlmox     := " "
LOCAL cGrupo     := " "
LOCAL cProduto   := " "
LOCAL nTotProd   := 0 
LOCAL nTotEmp    := 0
LOCAL nTotProdBl := 0
LOCAL nTotGrup   := 0
LOCAL nTotGrupBl := 0
LOCAL cCodBloq   := ""
LOCAL cDescBloq  := ""
LOCAL cIndexDD   := ""
LOCAL cArqTmpDD  := ""
LOCAL aTam       := {}
LOCAL lImpTot    := .f.
Local l300SalNeg := GetMv('MV_MT300NG', .F., .F.) // Indica se permite saldo negativo (DEFAULT = .F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nTipo      := If(aReturn[4]==1,15,18)
LOCAL NomeProg   := "MATR255"
LOCAL Cbtxt      := Space( 10 )
LOCAL cChave     := ""
LOCAL cChaveB8   := ""
LOCAL cChaveB2   := ""
LOCAL cChaveBF   := ""
LOCAL lImpBlock  := (mv_par05==2)
LOCAL lImpNorm   := .T.
LOCAL cLoteCtlAnt
LOCAL bCompara
LOCAL nQuantBloq
LOCAL cTipoLote  := ''
LOCAL lAdiciona  := .T.
LOCAL dDtValid   := CtoD('  /  /  ')
LOCAL lEmpPrev   := If(SuperGetMV("MV_QTDPREV")== "S",.T.,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Prepara Arquivo de Trabalho p/Impressao                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cFileTRB   := ""
LOCAL aCampos    := {}
LOCAL cIndex     := " "
LOCAL nIndex     := 0
LOCAL cArqTmp    := " "
LOCAL nTBloq     := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais utilizadas na montagem das Querys           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cQuery     := ''
LOCAL lQueryTOP  := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Private utilizadas na montagem das Querys          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cAliasTOP  := ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Contadores de linha e pagina                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE li         := 80
PRIVATE m_pag      := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo de Trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd( aCampos, {"TR_LOCAL"  ,"C",02,0} ) // Almoxarifado B2_LOCAL
Aadd( aCampos, {"TR_GRUPO"  ,"C",04,0} ) // Grupo        B1_GRUPO
Aadd( aCampos, {"TR_NGRUPO" ,"C",55,0} ) // Desc.Grupo
Aadd( aCampos, {"TR_COD"    ,"C",15,0} ) // Produto      B2_COD
Aadd( aCampos, {"TR_DESC"   ,"C",30,0} ) // Descricao    B1_DESC
Aadd( aCampos, {"TR_LOTECTL","C",10,0} ) // Lote         B8_LOTECTL
Aadd( aCampos, {"TR_NUMLOTE","C",06,0} ) // SubLote      B8_NUMLOTE
Aadd( aCampos, {"TR_DATA"   ,"D",08,0} ) // Validade     B8_DTVALID
Aadd( aCampos, {"TR_LOCALIZ","C",15,0} ) // Localizacao  BF_LOCALIZ
Aadd( aCampos, {"TR_NUMSERI","C",20,0} ) // Numero Serie BF_NUMSERI
Aadd( aCampos, {"TR_SITUA"  ,"C",02,0} ) // Codigo da Situacao. Tabela de Situacao SX5
Aadd( aCampos, {"TR_SITDESC","C",55,0} ) // Descricao da Situacao SX5
Aadd( aCampos, {"TR_UM"     ,"C",02,0} ) // UN           B1_UM

aTam:=TamSX3("BF_QUANT")
Aadd( aCampos, {"TR_QUANT"  ,"N",aTam[1]+1,aTam[2]} ) // Quantidade   BF_QUANT

aTam:=TamSX3("C_UNIT")
Aadd( aCampos, {"TR_CUNIT"  ,"N",aTam[1]+1,aTam[2]} ) // Quantidade   BF_QUANT

aTam:=TamSX3("C_TOTAL")
Aadd( aCampos, {"TR_CTOTAL"  ,"N",aTam[1]+1,aTam[2]} ) // Quantidade   BF_QUANT


aTam:=TamSX3("BF_EMPENHO")
Aadd( aCampos, {"TR_EMPENHO","N",aTam[1]+1,aTam[2]} ) // Quantidade   Empenhada

aTam:=TamSX3("BF_EMPENHO")
Aadd( aCampos, {"TR_BLOQ","N",aTam[1]+1,aTam[2]} ) // Quantidade   BLOQUEADA

Aadd( aCampos, {"TR_OBSERVA","C",30,0} ) // Observacao   BLOQ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Indice de Trabalho e muda o titulo conforme a ordem selecionada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	(aReturn[ 8 ]==1)
	titulo := Alltrim(Titulo+" ("+Alltrim(aOrd[1])+")")
	cIndex := "TR_LOCAL + TR_GRUPO + TR_COD"
Else
	titulo := Alltrim(Titulo+" ("+Alltrim(aOrd[2])+")")
	cIndex := "TR_COD + TR_LOCAL"
Endif
cIndex += "+ TR_LOTECTL + TR_NUMLOTE + TR_SITUA"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se a chave for por produto, realiza quebra por grupo ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lQueGrup := (aReturn[8]==1)
cFileTRB := CriaTrab(aCampos,.T.)
dbUseArea(.T.,,cFileTRB,"TRB",.T.,.F.)
IndRegua( "TRB", cFileTRB, cIndex,,,STR0009)	//"Criando Indice ..."

#IFDEF TOP
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria Query para o SBF e SB1                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lQueryTOP := .T.
	cAliasTOP := CriaTrab(Nil, .F.)
	cQuery := "SELECT SBF.BF_FILIAL TP_FILIAL, SBF.BF_LOCAL TP_LOCAL, SBF.BF_PRODUTO TP_COD, SB1.B1_DESC TP_DESC, SB1.B1_GRUPO TP_GRUPO, SBF.BF_LOCALIZ TP_LOCALIZ, SBF.BF_NUMSERI TP_NUMSERI, SBF.BF_LOTECTL TP_LOTECTL, SBF.BF_NUMLOTE TP_NUMLOTE, SB1.B1_UM TP_UM, SUM(SBF.BF_QUANT) TP_BFQUANT, SUM(SBF.BF_EMPENHO) TP_BFEMPENHO "
	cQuery += ",B2_CMFIM1 C_UNIT, (SUM(SBF.BF_QUANT) * B2_CMFIM1) C_TOTAL"	
	cQuery += "FROM "+RetSqlName('SBF')+" SBF, "+RetSqlName('SB1')+" SB1, " +RetSqlName('SB2')+" SB2 "	

	cQuery += "WHERE SBF.BF_FILIAL='"+xFilial('SBF')+"' AND "
	cQuery += "SBF.BF_PRODUTO>='"+mv_par01+"' AND SBF.BF_PRODUTO<='"+mv_par02+"' AND "
	cQuery += "SBF.BF_LOCAL>='"+mv_par06+"' AND SBF.BF_LOCAL<='"+mv_par07+"' AND "
	cQuery += "SBF.BF_LOCALIZ>='"+mv_par08+"' AND SBF.BF_LOCALIZ<='"+mv_par09+"' AND "
	If l300SalNeg //-- Considera registros no SBF com saldo negativo
		cQuery += "SBF.BF_QUANT<>0 AND "
	Else //-- Considera somente registros no SBF que possuirem quantidade maior que zero
		cQuery += "SBF.BF_QUANT>0 AND "
	EndIf	
	cQuery += If(!Empty(xFilial("SB1")), "SB1.B1_FILIAL=SBF.BF_FILIAL AND ", "") + "SB1.B1_COD=SBF.BF_PRODUTO AND "
	cQuery += "SBF.D_E_L_E_T_=' ' AND SB1.D_E_L_E_T_=' ' "  
	cQuery += "AND SB2.D_E_L_E_T_=' '	AND B2_FILIAL=BF_FILIAL	AND B2_COD=BF_PRODUTO "	
	cQuery += "GROUP BY SBF.BF_FILIAL, SBF.BF_LOCAL, SBF.BF_PRODUTO, SB1.B1_DESC, SB1.B1_GRUPO, SBF.BF_LOCALIZ , SBF.BF_NUMSERI, SBF.BF_LOTECTL , SBF.BF_NUMLOTE, SB1.B1_UM,B2_CMFIM1 "
	cQuery += "ORDER BY 1,2,3,4,5,6,7,8,9,10 "
	cQuery := ChangeQuery(cQuery)
	MsAguarde({|| dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), cAliasTOP,.F.,.T.)}, STR0010) //"Selecionando Registros ..."
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria Indice de trabalho para o SDD                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea('SDD')
	dbSetOrder(1)
	cIndexDD  := 'DD_FILIAL + DD_LOCAL + DD_PRODUTO + DD_LOTECTL + DD_NUMLOTE + DD_LOCALIZ + DD_NUMSERI'
	cArqTmpDD := CriaTrab(NIL,.F.)
	IndRegua('SDD', cArqTmpDD, cIndexDD,,,STR0010) //"Selecionando Registros ..."
	nIndexDD  := RetIndex('SDD')
	dbSetOrder(nIndexDD+1)
#ELSE
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria Indice de trabalho para SBF                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea('SBF')
	dbSetOrder(1)
	cIndex  :="BF_FILIAL+BF_LOCAL+BF_PRODUTO+BF_LOTECTL+BF_NUMLOTE+BF_PRIOR+BF_LOCALIZ+BF_NUMSERI"
	cArqTmp := CriaTrab(NIL,.F.)
	IndRegua("SBF", cArqTmp, cIndex,,,STR0010)	//"Selecionando Registros ..."
	nIndex := RetIndex("SBF")
	dbSetIndex(cArqTmp+OrdBagExt())
	dbSetOrder(nIndex+1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria Indice de trabalho para o SDD                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea('SDD')
	dbSetOrder(1)
	cIndexDD  :="DD_FILIAL + DD_LOCAL + DD_PRODUTO + DD_LOTECTL + DD_NUMLOTE"
	cArqTmpDD := CriaTrab(NIL,.F.)
	IndRegua( "SDD", cArqTmpDD, cIndexDD, , ,STR0010)	//"Selecionando Registros ..."
	nIndexDD  := RetIndex( "SDD" )
	dbSetIndex(cArqTmpDD+OrdBagExt())
	dbSetOrder(nIndexDD+1)
#ENDIF	

#IFDEF TOP
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Percorre o arquivo montado para TOP                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea('SB2')
	dbSetOrder(1)
	dbSelectArea(cAliasTOP)
	SetRegua(SBF->(RecCount())) //-- em bases TOP Utilizar o arquivo de Saldos por Endereco na Regua
	Do While !(cAliasTOP)->(Eof())
		IncRegua()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Validacao do filtro do usuario (SB2)	                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If ! SB2->(dbSeek(xFilial('SB2')+(cAliasTOP)->TP_COD+(cAliasTOP)->TP_LOCAL,.F.));
			.Or. If( Empty( aReturn[7]),.F., ! SB2->( &(aReturn[7]) ) )
			dbSkip()
			Loop
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Procura a descricao do Grupo                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea('SBM')
		dbSetOrder(1)
		cGrupo := If(dbSeek(xFilial('SBM')+(cAliasTOP)->TP_GRUPO, .F.), BM_DESC, Space(Len(BM_DESC)))
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Procura por Saldos Bloqueados por Endereco                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nTBloq   := 0
		dDtValid := CtoD('  /  /  ')
		If lImpBlock
			dbSelectArea('SDD')
			If dbSeek(cSeekSDD:=xFilial('SDD')+(cAliasTOP)->TP_LOCAL+(cAliasTOP)->TP_COD+(cAliasTOP)->TP_LOTECTL+(cAliasTOP)->TP_NUMLOTE+(cAliasTOP)->TP_LOCALIZ+(cAliasTOP)->TP_NUMSERI, .F.)
				Do While !SDD->(Eof()) .And. cSeekSDD == SDD->DD_FILIAL+SDD->DD_LOCAL+SDD->DD_PRODUTO+SDD->DD_LOTECTL+SDD->DD_NUMLOTE+SDD->DD_LOCALIZ+SDD->DD_NUMSERI
					If SDD->DD_MOTIVO<mv_par03 .Or. SDD->DD_MOTIVO>mv_par04
						dbSelectArea('SDD')
						dbSkip()
						Loop
					EndIf
					cCodBloq  := SDD->DD_MOTIVO
					cDescBloq := ''
					cObserva  := SDD->DD_OBSERVA
					dDtValid  := SDD->DD_DTVALID
					dbSelectArea('SX5')
					dbSetOrder(1)
					If dbSeek(xFilial('SX5')+'E1'+SDD->DD_MOTIVO, .F.)
						cDescBloq := X5Descri()
					EndIf
					dbSelectArea('SDC')
					dbSetOrder(1) //-- DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI
					If dbSeek(cSeekSDC:=xFilial('SDC')+SDD->DD_PRODUTO+SDD->DD_LOCAL+'SDD'+SDD->DD_DOC+'    '+SDD->DD_LOTECTL+SDD->DD_NUMLOTE+SDD->DD_LOCALIZ+SDD->DD_NUMSERI, .F.)
						Do While !SDC->(Eof()) .And. cSeekSDC == DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI
							RecLock('TRB', .T.)
							Replace TR_LOCAL   With (cAliasTOP)->TP_LOCAL
							Replace TR_GRUPO   With (cAliasTOP)->TP_GRUPO
							Replace TR_NGRUPO  With cGrupo
							Replace TR_COD     With (cAliasTOP)->TP_COD
							Replace TR_DESC    With (cAliasTOP)->TP_DESC
							Replace TR_LOTECTL With (cAliasTOP)->TP_LOTECTL
							Replace TR_NUMLOTE With (cAliasTOP)->TP_NUMLOTE
							Replace TR_DATA    With SDD->DD_DTVALID
							Replace TR_LOCALIZ With (cAliasTOP)->TP_LOCALIZ
							Replace TR_NUMSERI With (cAliasTOP)->TP_NUMSERI
							Replace TR_SITUA   With cCodBloq
							Replace TR_SITDESC With cDescBloq
							Replace TR_OBSERVA With cObserva
							Replace TR_UM      With (cAliasTOP)->TP_UM
							Replace TR_BLOQ    With SDC->DC_QUANT
							MsUnlock()
							nTBloq += SDC->DC_QUANT
							dbSelectArea('SDC')
							dbSkip()
						EndDo
					EndIf
					dbSelectArea('SDD')
					dbSkip()
				EndDo
			EndIf
		EndIf
		
		If Empty(dDtValid) .And. !Empty((cAliasTOP)->TP_LOTECTL+(cAliasTOP)->TP_NUMLOTE)
			SB8->(dbSetOrder(3)) //-- B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
			If SB8->(dbSeek(xFilial('SB8')+(cAliasTOP)->TP_COD+(cAliasTOP)->TP_LOCAL+(cAliasTOP)->TP_LOTECTL+If(Rastro((cAliasTOP)->TP_COD, 'S'),(cAliasTOP)->TP_NUMLOTE,''), .F.))
				dDtValid := SB8->B8_DTVALID
			EndIf
		EndIf
		
		RecLock('TRB', .T.)
		Replace TR_LOCAL    With (cAliasTOP)->TP_LOCAL
		Replace TR_GRUPO    With (cAliasTOP)->TP_GRUPO
		Replace TR_NGRUPO   With cGrupo
		Replace TR_COD      With (cAliasTOP)->TP_COD
		Replace TR_DESC     With (cAliasTOP)->TP_DESC
		Replace TR_LOTECTL  With (cAliasTOP)->TP_LOTECTL
		Replace TR_NUMLOTE  With (cAliasTOP)->TP_NUMLOTE
		Replace TR_DATA     With dDtValid
		Replace TR_LOCALIZ  With (cAliasTOP)->TP_LOCALIZ
		Replace TR_NUMSERI  With (cAliasTOP)->TP_NUMSERI
		Replace TR_UM       With (cAliasTOP)->TP_UM
		Replace TR_QUANT    With (cAliasTOP)->TP_BFQUANT
				Replace TR_CUNIT    With (cAliasTOP)->C_UNIT
				Replace TR_CTOTAL   With (cAliasTOP)->C_TOTAL
		
		Replace TR_EMPENHO  With (cAliasTOP)->TP_BFEMPENHO - nTBloq
		Replace TR_BLOQ 	  With nTBloq
		MsUnlock()
		
		dbSelectArea(cAliasTOP)
		dbSkip()
	EndDo
#ELSE
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Percorre o arq. de Saldo Fisico e Financeiro                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SB2")
	dbSetOrder(1)
	dbSeek(xFilial() + mv_par01, .T.)
	
	SetRegua(RecCount())
	
	Do While !Eof() .And. SB2->B2_FILIAL == xFilial() .And. SB2->B2_COD <= mv_par02
		
		IncRegua()
		
		dbSelectArea("SB1")
		dbSetOrder(1)
		If	Empty(SB2->B2_COD) .Or. !dbSeek(xFilial() + SB2->B2_COD)
			dbSelectArea("SB2")
			dbSkip()
			Loop
		Endif
		
		If SB2->B2_LOCAL < mv_par06 .Or. SB2->B2_LOCAL > mv_par07
			dbSelectArea("SB2")
			dbSkip()
			Loop
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Validacao do filtro do usuario (SB2)	                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If !Empty(aReturn[7]) .And. ! SB2->( &(aReturn[7]) )
			dbSelectArea('SB2')
			dbSkip()
			Loop
		EndIf
		
		dbSelectArea("SBM")
		If dbSeek(xFilial() + SB1->B1_GRUPO, .F.)
			cGrupo := SBM->BM_DESC
		Else
			cGrupo := Space(Len(SBM->BM_DESC))
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Percorre o arq. de Saldos por Lote                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SB8")
		dbSetOrder(1)
		If dbSeek(xFilial() + SB2->B2_COD + SB2->B2_LOCAL, .F.)
			
			cLoteCtlAnt := "&&&&&&&&&&&&&&&&"
			
			Do While !Eof() .And. ;
					SB8->B8_FILIAL+SB8->B8_PRODUTO+SB8->B8_LOCAL == xFilial()+SB2->B2_COD+SB2->B2_LOCAL
	
				
				If Rastro( SB8->B8_PRODUTO, "L" ) .And. ;
						cLoteCtlAnt == SB8->B8_LOTECTL
					dbSkip()
					Loop
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se o produto controlar Localizacao ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Localiza( SB8->B8_PRODUTO )
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Posiciona o arq. de Saldo por Localizacao Fisica ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("SBF")
					
					cChaveB8 := xFilial()+SB8->B8_LOCAL+SB8->B8_PRODUTO+SB8->B8_LOTECTL+If(Rastro( SB8->B8_PRODUTO, "S" ), SB8->B8_NUMLOTE, '')
					
					dbSeek( cChaveB8 )
					
					cChaveBF := BF_FILIAL+BF_LOCAL+BF_PRODUTO+BF_LOTECTL+If(Rastro( SB8->B8_PRODUTO, "S" ), BF_NUMLOTE, '')
					nTBloq := 0	
					Do While !Eof() .And. cChaveBF == cChaveB8
						
						If BF_LOCALIZ < mv_par08 .Or. BF_LOCALIZ > mv_par09
							dbSkip()
							cChaveBF := BF_FILIAL+BF_LOCAL+BF_PRODUTO+BF_LOTECTL+If(Rastro( SB8->B8_PRODUTO, "S" ), BF_NUMLOTE, '')
							Loop
						EndIf
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Pesquisa para checar se existe bloqueio para este lote  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cChaveDD := xFilial( "SDD" ) + SBF->BF_LOCAL + ;
							SBF->BF_PRODUTO + SBF->BF_LOTECTL + SBF->BF_NUMLOTE
						
						lBloq := .F.
						
						If SDD->(dbSeek(cChaveDD, .F.))
							
							Do While !SDD->(Eof()) .And. ;
									SDD->DD_FILIAL + SDD->DD_LOCAL + SDD->DD_PRODUTO + ;
									SDD->DD_LOTECTL + SDD->DD_NUMLOTE == cChaveDD
								
								If SDD->DD_MOTIVO < mv_par03 .Or. SDD->DD_MOTIVO > mv_par04
									SDD->(dbSkip())
									Loop
								EndIf
								
								If SDD->DD_LOCALIZ < mv_par08 .Or. SDD->DD_LOCALIZ > mv_par09
									SDD->(dbSkip())
									Loop
								EndIf
								
								cCodBloq := SDD->DD_MOTIVO
								cObserva := SDD->DD_OBSERVA
								If SX5->( dbSeek( xFilial( "SX5" ) + "E1" + SDD->DD_MOTIVO ) )
									cDescBloq := X5Descri()
								EndIf
								
								cChave := xFilial("SDC") + SDD->DD_PRODUTO + SDD->DD_LOCAL + ;
									"SDD" + SDD->DD_DOC + "    " + SDD->DD_LOTECTL + ;
									SDD->DD_NUMLOTE + SBF->BF_LOCALIZ + SDD->DD_NUMSERI
								
								SDC->(dbSetOrder(1))
								
								If SDC->(dbSeek(cChave, .F.))
									
									lBloq := .T.
									
									If lImpBlock
										
										//-- Se utilizar LOTE, impede duplicidade de registros no SBF referentes aos sublotes no SB8
										cTipoLote := If(Rastro(SBF->BF_PRODUTO),If(Rastro(SBF->BF_PRODUTO,'S'),'S','L'),'N')
										lAdiciona := .T.
										If cTipoLote == 'L'
											dbSelectArea('TRB')
											dbSetOrder(1)
											If dbSeek(SBF->BF_LOCAL+SB1->B1_GRUPO+SBF->BF_PRODUTO+SBF->BF_LOTECTL, .F.)
												Do While !Eof() .And. SBF->BF_LOCAL+SB1->B1_GRUPO+SBF->BF_PRODUTO+SBF->BF_LOTECTL == TR_LOCAL + TR_GRUPO + TR_COD+ TR_LOTECTL
													If SBF->BF_LOCALIZ+SBF->BF_NUMSERI == TR_LOCALIZ+TR_NUMSERI
														lAdiciona := .F.
														Exit
													EndIf
													dbSkip()
												EndDo
											EndIf
										EndIf	
										If lAdiciona
											RecLock("TRB",.T.)
											Replace TR_LOCAL    With SBF->BF_LOCAL
											Replace TR_GRUPO    With SB1->B1_GRUPO
											Replace TR_NGRUPO   With cGrupo
											Replace TR_COD      With SBF->BF_PRODUTO
											Replace TR_DESC     With SB1->B1_DESC
											Replace TR_LOTECTL  With SBF->BF_LOTECTL
											Replace TR_NUMLOTE  With SBF->BF_NUMLOTE
											Replace TR_DATA     With SDD->DD_DTVALID
											Replace TR_LOCALIZ  With SBF->BF_LOCALIZ
											Replace TR_NUMSERI  With SBF->BF_NUMSERI
											Replace TR_SITUA    With cCodBloq
											Replace TR_SITDESC  With cDescBloq
											Replace TR_OBSERVA  With cObserva
											Replace TR_UM       With SB1->B1_UM
											Replace TR_BLOQ     With SDC->DC_QUANT
											MsUnlock()
										EndIf	
									EndIf
								EndIf
								nTBloq += SDC->DC_QUANT
								SDD->( dbSkip() )
								
							EndDo
							
						EndIf
						
						If ( !lBloq .Or. SBF->BF_QUANT - SBF->BF_EMPENHO <> 0 ) .And. ;
								lImpNorm
							
							//-- Se utilizar LOTE, impede duplicidade de registros no SBF referentes aos sublotes no SB8
							cTipoLote := If(Rastro(SBF->BF_PRODUTO),If(Rastro(SBF->BF_PRODUTO,'S'),'S','L'),'N')
							lAdiciona := .T.
							If cTipoLote == 'L'
								dbSelectArea('TRB')
								dbSetOrder(1)
								Do While !Eof() .And. SBF->BF_LOCAL+SB1->B1_GRUPO+SBF->BF_PRODUTO+SBF->BF_LOTECTL == TR_LOCAL + TR_GRUPO + TR_COD+ TR_LOTECTL
									If SBF->BF_LOCALIZ+SBF->BF_NUMSERI == TR_LOCALIZ+TR_NUMSERI
										lAdiciona := .F.
										Exit
									EndIf
									dbSkip()
								EndDo
							EndIf	
							If lAdiciona
								RecLock("TRB",.T.)
								Replace TR_LOCAL    With SBF->BF_LOCAL
								Replace TR_GRUPO    With SB1->B1_GRUPO
								Replace TR_NGRUPO   With cGrupo
								Replace TR_COD      With SBF->BF_PRODUTO
								Replace TR_DESC     With SB1->B1_DESC
								Replace TR_LOTECTL  With SBF->BF_LOTECTL
								Replace TR_NUMLOTE  With SBF->BF_NUMLOTE
								Replace TR_DATA     With SB8->B8_DTVALID
								Replace TR_LOCALIZ  With SBF->BF_LOCALIZ
								Replace TR_NUMSERI  With SBF->BF_NUMSERI
								Replace TR_UM       With SB1->B1_UM
								Replace TR_QUANT    With SBF->BF_QUANT
		
								If !lBloq
									Replace TR_EMPENHO  With SBF->BF_EMPENHO
								Else
									Replace TR_EMPENHO  With SBF->BF_EMPENHO - nTBloq
									Replace TR_BLOQ 	With nTBloq
								EndIf
								
								MsUnlock()
							EndIf	
							
						EndIf
						
						dbSelectArea("SBF")
						dbSkip()
						cChaveBF := BF_FILIAL+BF_LOCAL+BF_PRODUTO+BF_LOTECTL+If(Rastro( SB8->B8_PRODUTO, "S" ), BF_NUMLOTE, '')
	
					Enddo
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Nao utilizando controle de Localizacao ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Else
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Pesquisa para checar se existe bloqueio para este lote  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Rastro( SB8->B8_PRODUTO, "S" )
						cChaveDD := xFilial( "SDD" ) + SB8->B8_LOCAL + SB8->B8_PRODUTO + ;
							SB8->B8_LOTECTL + SB8->B8_NUMLOTE
						bCompara := { || cChaveDD == SDD->DD_FILIAL + SDD->DD_LOCAL + ;
							SDD->DD_PRODUTO + SDD->DD_LOTECTL + SDD->DD_NUMLOTE }
					Else
						cChaveDD := xFilial( "SDD" ) + SB8->B8_LOCAL + SB8->B8_PRODUTO + ;
							SB8->B8_LOTECTL
						bCompara := { || cChaveDD == SDD->DD_FILIAL + SDD->DD_LOCAL + ;
							SDD->DD_PRODUTO + SDD->DD_LOTECTL }
					EndIf
					
					lBloq := .F.
		            nTBloq := 0				
					If SDD->(dbSeek(cChaveDD, .F.))
						
						Do While !SDD->(Eof()) .And. Eval(bCompara)
							
							If SDD->DD_MOTIVO < mv_par03 .Or. SDD->DD_MOTIVO > mv_par04
								SDD->( dbSkip() )
								Loop
							EndIf
							
							If SDD->DD_LOCALIZ < mv_par08 .Or. SDD->DD_LOCALIZ > mv_par09
								SDD->(dbSkip())
								Loop
							EndIf
							
							cCodBloq := SDD->DD_MOTIVO
							If SX5->(dbSeek( xFilial( "SX5" ) + "E1" + SDD->DD_MOTIVO, .F.))
								cDescBloq := X5Descri()
							Else
								cDescBloq := Space(Len(X5Descri()))
							EndIf
							
							lBloq := .T.
							
							If lImpBlock
								
								RecLock("TRB",.T.)
								Replace TR_LOCAL    With SB8->B8_LOCAL
								Replace TR_GRUPO    With SB1->B1_GRUPO
								Replace TR_NGRUPO   With cGrupo
								Replace TR_COD      With SB8->B8_PRODUTO
								Replace TR_DESC     With SB1->B1_DESC
								Replace TR_LOTECTL  With SB8->B8_LOTECTL
								Replace TR_NUMLOTE  With SB8->B8_NUMLOTE
								Replace TR_DATA     With SB8->B8_DTVALID
								Replace TR_SITUA    With cCodBloq
								Replace TR_SITDESC  With cDescBloq
								Replace TR_UM       With SB1->B1_UM
								Replace TR_BLOQ     With SDD->DD_QUANT
								MsUnlock()
								
							EndIf
							
							nQuantBloq := SDD->DD_QUANT
							nTBloq += SDD->DD_QUANT
							SDD->( dbSkip() )
							
						EndDo
						
					EndIf
					
					If (!lBloq .Or. (SB8SALDO(,,,,,lEmpPrev,,,.T.) - SB8SALDO(.T.,,,,,lEmpPrev,,,.T.) + nTBloq) # 0) .And. lImpNorm
						
						RecLock("TRB",.T.)
						Replace TR_LOCAL    With SB8->B8_LOCAL
						Replace TR_GRUPO    With SB1->B1_GRUPO
						Replace TR_NGRUPO   With cGrupo
						Replace TR_COD      With SB8->B8_PRODUTO
						Replace TR_DESC     With SB1->B1_DESC
						Replace TR_LOTECTL  With SB8->B8_LOTECTL
						Replace TR_NUMLOTE  With SB8->B8_NUMLOTE
						Replace TR_DATA     With SB8->B8_DTVALID
						Replace TR_UM       With SB1->B1_UM
						Replace TR_QUANT    With SB8SALDO(,,,,,lEmpPrev,,,.T.)					
	
						If !lBloq                            
							Replace TR_EMPENHO  With SB8SALDO(.T.,,,,,lEmpPrev,,,.T.)						
						Else
							Replace TR_EMPENHO  With SB8SALDO(.T.,,,,,lEmpPrev,,,.T.) - nTBloq
							Replace TR_BLOQ 	With nTBloq
						EndIf
						
						MsUnlock()
						
					EndIf
					
				EndIf
				
				dbSelectArea("SB8")
				cLoteCtlAnt := SB8->B8_LOTECTL
				dbSkip()
				
			Enddo
			
			//-- O Produto Controla Localiza‡„o e n„o controla Lote/Sub-Lote
		ElseIf Localiza( SB2->B2_COD )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona o arq. de Saldo por Localizacao Fisica ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SBF")
			
			cChaveB2 := xFilial()+SB2->B2_LOCAL+SB2->B2_COD
			dbSeek(cChaveB2, .F.)
			
			Do While !Eof() .And. BF_FILIAL + BF_LOCAL + BF_PRODUTO == cChaveB2
	
				If SBF->BF_LOCALIZ < mv_par08 .Or. SBF->BF_LOCALIZ > mv_par09
					dbSkip()
					Loop
				EndIf
	
				If (SBF->BF_QUANT - SBF->BF_EMPENHO) # 0 .And. lImpNorm
					RecLock("TRB",.T.)
					Replace TR_LOCAL    With SBF->BF_LOCAL
					Replace TR_GRUPO    With SB1->B1_GRUPO
					Replace TR_NGRUPO   With cGrupo
					Replace TR_COD      With SBF->BF_PRODUTO
					Replace TR_DESC     With SB1->B1_DESC
					Replace TR_LOCALIZ  With SBF->BF_LOCALIZ
					Replace TR_NUMSERI  With SBF->BF_NUMSERI
					Replace TR_UM       With SB1->B1_UM
					Replace TR_QUANT    With SBF->BF_QUANT
					Replace TR_EMPENHO  With SBF->BF_EMPENHO
					MsUnlock()
				EndIf
				dbSelectArea("SBF")
				dbSkip()
			Enddo
		EndIf
		
		dbSelectArea("SB2")
		dbSkip()
	EndDo
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para impressao do cabecalho e rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Cabec1 :=     STR0017 // "                          DATA DA                                                   SITUACAO"
If !lQueGrup
	Cabec2 := STR0011 // "LOTE        SUB-LOTE    EXPIRACAO   LOCALIZACAO      NUMERO DE SERIE       DA    LOCALIZACAO          OBSERVACAO                     UM      QUANTIDADE       EMPENHADO       BLOQUEADO      DISPONIVEL    LC  GRUPO"
Else
	Cabec2 := STR0012 // "LOTE        SUB-LOTE    EXPIRACAO   LOCALIZACAO      NUMERO DE SERIE       DA    LOCALIZACAO          OBSERVACAO                     UM      QUANTIDADE       EMPENHADO       BLOQUEADO      DISPONIVEL    LC"
EndIf
//                        1234567890  1234567890  12/12/1234  123456789012345  12345678901234567890  12 -  1234567890123456789  123456789012345678901234567890  12  12345678901234  12345678901234  12345678901234  12345678901234   12  1234
//                                  1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
//                        0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012

cbCont      := 0
Limite      := 132
lAbortPrint := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio da impressao do arquivo temporario                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea('TRB')
dbSetOrder(1)
dbGoTop()
SetRegua(RecCount())

cGrupAnt := "*"
cLocAnt  := "*"
cProdAnt := "*"
cLoteAnt := "*"

Do While !TRB->(Eof()) .And. !lAbortPrint
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o usuario interrompeu o relatorio                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAbortPrint
		@ Prow()+1, 001 PSAY STR0013 // "CANCELADO PELO OPERADOR"
		Exit
	Endif
	
	If	li > 55
		Cabec(Titulo,Cabec1,Cabec2,Nomeprog,Tamanho,nTipo)
	EndIf
	
	If !(cAlmox==TRB->TR_LOCAL) .Or. If(lQueGrup,!(cGrupAnt==TRB->TR_GRUPO), .F. )
		cLocAnt  := cAlmox
		cAlmox   := TRB->TR_LOCAL
		cGrupAnt := TRB->TR_GRUPO
		If !(cLocAnt==TRB->TR_LOCAL) .Or. !(cGrupAnt==TRB->TR_GRUPO)
			nTotProd   := 0
			nTotEmp    := 0
			nTotProdBl := 0
		EndIf
		
		If lQueGrup
			@ li,00 PSay STR0014	//"ALMOXARIFADO:"
			@ li,14 PSay TRB->TR_LOCAL+" - "
			@ li,19 PSay If(Empty(TRB->TR_GRUPO), STR0015, AllTrim(TRB->TR_GRUPO) + " - " + TRB->TR_NGRUPO) // "Nao classificados"
			li++
		EndIf
		
	Endif

	If	cProdAnt = TRB->TR_COD
		If cAlmox # TRB->TR_LOCAL .Or. If(lQueGrup,cGrupAnt # TRB->TR_GRUPO, .F. )
			li++
			@ li,00 Psay STR0018	//"Produto:"
			@ li,10 PSay TRB->TR_COD
			@ li,30 PSay STR0019   //"Descricao:"
			@ li,42 PSay TRB->TR_DESC
			li += 2
		EndIf
	Else
		li++
		@ li,00 Psay STR0018	//"Produto:"
		@ li,10 PSay TRB->TR_COD
		@ li,30 PSay STR0019   //"Descricao:"
		@ li,42 PSay TRB->TR_DESC
		nTotProd   := 0 
		nTotEmp    := 0
		nTotProdBl := 0
		li += 2
	Endif
	
	@ li, 000 PSay If(Empty(TRB->TR_SITUA),TRB->TR_LOTECTL," ")
	@ li, 012 PSay If(Empty(TRB->TR_SITUA),If(Rastro(TRB->TR_COD, "S"), TRB->TR_NUMLOTE, " ")," ")      // Não trocar por ""
	If !Empty(TRB->TR_DATA)
		@ li, 024 PSay TRB->TR_DATA
	EndIf	
	@ li, 036 PSay Left(TRB->TR_LOCALIZ,15)
	@ li, 051 PSay TRB->TR_NUMSERI
	@ li, 075 PSay TRB->TR_SITUA
	@ li, 079 pSay If(!Empty(TRB->TR_SITUA),'-',Space(1))
	@ li, 081 PSay Left(TRB->TR_SITDESC,16)
	@ li, 102 PSay TRB->TR_OBSERVA
	@ li, 134 PSay TRB->TR_UM
	If !(TRB->TR_QUANT==0)
		@ li, 137 PSay TRB->TR_QUANT   Picture PesqPict("SBF","BF_QUANT",14)
	EndIf
	If !(TRB->TR_EMPENHO==0)
		@ li, 153 PSay TRB->TR_EMPENHO Picture PesqPict("SBF","BF_QUANT",14)
	EndIf	
	If !(TRB->TR_BLOQ==0)
		@ li, 169 PSay TRB->TR_BLOQ    Picture PesqPict("SBF","BF_QUANT",14)
	EndIf	
	If !(TRB->TR_QUANT==0)
		@ li, 185 PSay TRB->TR_QUANT-TRB->TR_EMPENHO-TRB->TR_BLOQ Picture PesqPict("SBF","BF_QUANT",14) //DISPONIVEL
	EndIf
	
	If !lQueGrup
		If !(cLocAnt=TRB->TR_LOCAL)
			@ li, 203 PSay TRB->TR_LOCAL
			cLocAnt := TRB->TR_LOCAL
		EndIf
		If !(cProdAnt==TRB->TR_COD)
			@ li, 207 PSay TRB->TR_GRUPO
		EndIf
	EndIf
	li ++
	
	nTotProd   += TRB->TR_QUANT
	nTotEmp    += TRB->TR_EMPENHO
	cProdAnt   := TRB->TR_COD
 	cLoteAnt   := TRB->TR_LOTECTL+TRB->TR_NUMLOTE
    
    If Empty(TRB->TR_SITUA)
    	nTotProdBl += TRB->TR_BLOQ
    	lImpTot := .T.
    EndIf
	
	dbSelectArea('TRB')
	IncRegua()
	dbSkip()
	
    If lImpTot .And. !Empty(TRB->TR_SITUA) .And. !Empty(TRB->TR_LOTECTL)
		@ li, 00 PSay __PrtThinLine()
		li ++	        
        @ li, 00 PSay STR0020  //"Lotes Bloqueados "
    	lImpTot := .F.
    EndIf

 	If !(cLoteAnt==TRB->TR_LOTECTL+TRB->TR_NUMLOTE) .And. cProdAnt == TRB->TR_COD .And. mv_par05 == 2
 	   li ++
	EndIf                              
	
	If	!(cProdAnt==TRB->TR_COD) .Or. !(cAlmox==TRB->TR_LOCAL) .Or. !(cGrupAnt==TRB->TR_GRUPO)
		@ li,118 PSay STR0016	//"TOTAL DO PRODUTO :"
		@ li,137 PSay nTotProd   Picture PesqPict("SBF","BF_QUANT",14)
		@ li,153 PSay nTotEmp    Picture PesqPict("SBF","BF_QUANT",14)
		@ li,169 PSay nTotProdBl Picture PesqPict("SBF","BF_QUANT",14)
		@ li,185 PSay IF(nTotProd>0,nTotProd-nTotEmp-nTotProdBl,0) Picture PesqPict("SBF","BF_QUANT",14)
		li ++
	Endif
	
EndDo

If	!(li==80)
	Roda(cbcont,cbtxt,Tamanho)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga arquivo de trabalho                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea('TRB')
dbCloseArea()
Ferase( cFileTRB+GetDBExtension() )
Ferase( cFileTRB+OrdBagExt() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga indice de trabalho SBF                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQueryTOP
	dbSelectArea(cAliasTOP)	
	dbCloseArea()
Else
	dbSelectArea('SBF')
	RetIndex('SBF')
	Set Filter To
	fErase(cArqTmp+OrdBagExt())
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga indice de trabalho SDD                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea('SDD')
RetIndex('SDD')
Set Filter To
fErase(cArqTmpDD+OrdBagExt())

If aReturn[5] == 1
	Set Printer TO
	dbcommitAll()
	ourspool(wnRel)
Endif

MS_FLUSH()

Return Nil