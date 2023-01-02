#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#include "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

//Variáveis Estáticas
Static cTitulo := "Automatização de processos de pagamentos"

/*/
{Protheus.doc} BRAMNT06
Rotina para geração automática de borderôs de pagamento, de	acordo com regras pré-definidas.
Uso Brasitech
@type User Function
@author Processo definido por Ricky Elenita
@since 24/05/2022
@return
/*/
User Function BRAMNT06()
Local aArea   := GetArea()
Local oBrowse

if SX2->(dbSeek("ZZP")) .and. ZZP->(FieldPos("ZZP_PROC")) > 0
    //Cria um browse para a ZZP
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("ZZP")
    oBrowse:SetDescription(cTitulo)
    oBrowse:Activate()
else
    Help(,, "Funcionalidade Inválida",, "Esta funcionalidade não é válida para esta empresa!", 1, 0,,,,,, {"Selecione a empresa que possua a configuração de automatização de pagamentos"})
endif

RestArea(aArea)
Return Nil


/*/
{Protheus.doc} MENUDEF
Criação do menu MVC
Uso Brasitech
@type User Function
@author Processo definida por Ricky Elenita
@since 24/05/2022
@return
/*/
Static Function MenuDef()
Local aRot := {}

//———————————————————————————————————————————————————————————————————————————————    
// Adicionando opções
//———————————————————————————————————————————————————————————————————————————————
ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.BRAMNT06' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
ADD OPTION aRot TITLE 'Borderos'   ACTION 'U_MNT06BOR' 		 OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
Return aRot


/*/
{Protheus.doc} MODELDEF
Criação do modelo de dados MVC
Uso Brasitech
@type User Function
@author Processo definida por Ricky Elenita
@since 24/05/2022
@return
/*/
Static Function ModelDef()
Local oModel as object
Local oStrctZZP	:= FwFormStruct(1, "ZZP")
Local oStrctSEA	:= FwFormStruct(1, "SEA")

oModel	:= MPFormModel():New("MdlZZP")
oModel:AddFields("M01ZZP",, oStrctZZP)
oModel:AddGrid("M02SEA", "M01ZZP" , oStrctSEA)

oModel:SetPrimaryKey({"EA_FILIAL", "EA_NUMBOR", "EA_CART", "EA_PREFIXO", "EA_NUM", "EA_PARCELA", "EA_TIPO", "EA_FORNECE", "EA_LOJA"})
oModel:SetRelation("M02SEA", {{ "EA_FILIAL" , xFilial("SEA")} , {"EA_NUMBOR" , "ZZP_BORD"}}, SEA->(IndexKey(2)))

return oModel


///*/
//{Protheus.doc} VIEWDEF
//Criação da visão MVC
//Uso Brasitech
//@type User Function
//@author Processo definida por Ricky Elenita
//@since 24/05/2022
//@return
///*/
static function ViewDef()
Local oModel as object
Local oView as object
Local oStrctZZP as object
Local oStrctSEA as object

oModel    := FwLoadModel("BRAMNT06")
oView     := FwFormView():New() 
oStrctZZP := FwFormStruct(2, "ZZP")
oStrctSEA := FwFormStruct(2, "SEA")

oView:SetModel(oModel)
oView:AddField("V01ZZP", oStrctZZP, "M01ZZP")
oView:AddGrid("V02SEA", oStrctSEA, "M02SEA")
oView:CreateHorizontalBox("VwZZP", 30)
oView:CreateHorizontalBox("VwSEA", 70)
oView:SetOwnerView("V01ZZP", "VwZZP")
oView:SetOwnerView("V02SEA", "VwSEA")

return oView
 

/*/
{Protheus.doc} fModStruct
Monta o modelo de dados da Grid
Uso Brasitech
@type User Function
@author Processo definido por Ricky Elenita
@since 24/05/2022
@return
/*/
Static Function fModStruct()
Local oStruct
oStruct := FWFormStruct(1, 'ZZP')
Return oStruct


/*/
{Protheus.doc} fModStruct
Monta a visualização de dados da Grid
Uso Brasitech
@type User Function
@author Processo definido por Ricky Elenita
@since 24/05/2022
@return
/*/
Static Function fViewStruct()
Local oStruct

//———————————————————————————————————————————————————————————————————————————————
// Irá filtrar, e trazer todos os campos, menos "ZZP_BANCO;"
//———————————————————————————————————————————————————————————————————————————————
oStruct := FWFormStruct(2, "ZZP", {|cCampo| !(Alltrim(cCampo) $ "ZZP_BANCO;ZZP_LAYOUT")})
Return oStruct



/*/
{Protheus.doc} MNT06BOR
Rotina para geração automática de borderôs de pagamento, de	acordo com regras pré-definidas.
Uso Brasitech
@type User Function
@author Processo definido por Ricky Elenita
@since 24/05/2022
@return
/*/
User Function MNT06BOR()
Local oDlg, oFiltro
Local cProcesso     := GetSXENum("ZZP","ZZP_PROC") //GetSx8Num("ZZP","ZZP_PROC")
Local cBanco 		:= Space(3)
Local cAgencia      := Space(5)
Local cConta 		:= Space(10)
Local cNomeBco      := Space(30)
Local dVctoIni		:= dDataBase
Local dVctoFim		:= dDataBase
Local aCombo	 	:= {"Normais","Adiantamentos","Ambos"}
Local cCombo		:= "Ambos"

do while ZZP->(dbSeek(xFilial("ZZP") + cProcesso))
	cProcesso := Soma1(cProcesso)
enddo

Define MsDialog oDlg Title OemtoAnsi("Processo de automatização de pagamentos") From C(310),C(310) to C(545),C(850) Pixel

// Cria as Quadro de agrupamento
@ C(005),C(004) TO C(095),C(270) Label "Parâmetros" Pixel of oDlg

// Cria Componentes da tela
@ C(018),C(010) Say "Processo:" Size C(020),C(008) COLOR CLR_BLUE Pixel of oDlg
@ C(015),C(050) MsGet oFiltro Var cProcesso When .f. Size C(025),C(009) COLOR CLR_BLUE Pixel of oDlg

@ C(033),C(010) Say "Do vencimento:" Size C(050),C(008) COLOR CLR_BLUE Pixel of oDlg
@ C(033),C(155) Say "Até o vencimento:" Size C(050),C(008) COLOR CLR_BLUE Pixel of oDlg
@ C(030),C(050) MsGet oFiltro Var dVctoIni Size C(035),C(009) COLOR CLR_BLACK Pixel of oDlg
@ C(030),C(195) MsGet oFiltro Var dVctoFim Size C(035),C(009) COLOR CLR_BLACK Pixel of oDlg

@ C(048),C(010) Say "Banco:" Size C(017),C(008) COLOR CLR_BLUE Pixel of oDlg
@ C(048),C(100) Say "Agencia:" Size C(017),C(008) COLOR CLR_BLUE Pixel of oDlg
@ C(048),C(175) Say "Conta:" Size C(017),C(008) COLOR CLR_BLUE Pixel of oDlg
@ C(045),C(050) MsGet oFiltro Var cBanco F3 "SA6" Valid VldBanco(cBanco, cAgencia, cConta, @cNomeBco) Size C(15),C(009) COLOR CLR_BLACK Pixel of oDlg
@ C(045),C(120) MsGet oFiltro Var cAgencia Size C(025),C(009) COLOR CLR_BLACK Pixel of oDlg
@ C(045),C(195) MsGet oFiltro Var cConta Size C(035),C(009) COLOR CLR_BLACK Pixel of oDlg

@ C(063),C(010) Say "Nome:" Size C(017),C(008) COLOR CLR_BLACK Pixel of oDlg
@ C(060),C(050) MsGet oFiltro Var cNomeBco When .F. Size C(130),C(009) COLOR CLR_BLACK Pixel of oDlg

@ C(078),C(010) Say "Considera Títulos" Size C(050),C(008) COLOR CLR_BLUE Pixel of oDlg
@ C(075),C(050) ComboBox cCombo Items aCombo Size C(065),C(010) COLOR CLR_BLACK Pixel of oDlg

@ C(100),C(180) Button OemtoAnsi("Confirma") Size C(037),C(012) Pixel of oDlg Action (Processa({|| BordAutom(cProcesso, cBanco, cAgencia, cConta, dVctoIni, dVctoFim, cCombo)}, "Pesquisando títulos..."), oDlg:End())
@ C(100),C(230) Button OemtoAnsi("Cancelar") Size C(037),C(012) Pixel of oDlg Action(RollBackSX8(), oDlg:End())

Activate MsDialog oDlg Centered 

Return(.T.)


/*/
{Protheus.doc} BORDAUTOM
Rotina para geração automática de borderôs de pagamento, de	acordo com regras pré-definidas.
Uso Brasitech
@type Static Function
@author Processo definido por Ricky Elenita
@since 31/05/2022
@return
/*/
Static Function BordAutom(cProcesso, cBanco, cAgencia, cConta, dVctoIni, dVctoFim, cCombo)
Local cQuery, cFiltro, cModBor, cTipBor
Local lMarca		:= .F.
Local nTotProc		:= 0
Local nTotGeral		:= 0
Local aArqTrab		:= {	{"T_MARCA",		"C", 02, 0},;
							{"T_XORIGPC", 	"C", 03, 0},;
							{"T_MODBOR ", 	"C", 02, 0},;
							{"T_TIPBOR ", 	"C", 02, 0},;
							{"T_NUM    ", 	"C", 09, 0},;
							{"T_FORNECE", 	"C", 08, 0},;
							{"T_LOJA   ", 	"C", 02, 0},;
							{"T_NOMFOR ", 	"C", 20, 0},;
							{"T_VENCREA", 	"D", 08, 0},;
							{"T_VALOR  ", 	"N", 12, 2},;
							{"T_XFORPAG", 	"C", 03, 0},;
							{"T_CODBAR ", 	"C", 48, 0},;
							{"T_FORBCO ", 	"C", 03, 0},;
							{"T_FORAGE ", 	"C", 05, 0},;
							{"T_FAGEDV ", 	"C", 02, 0},;
							{"T_FORCTA ", 	"C", 10, 0},;
							{"T_FCTADV ", 	"C", 02, 0},;
							{"T_PREFIXO", 	"C", 03, 0},;
							{"T_PARCELA", 	"C", 01, 0},;
							{"T_TIPO", 		"C", 03, 0},;
							{"T_CRITICA", 	"C", 50, 0},;
							{"T_REGISTRO", 	"N", 10, 0}}
Local aCores		:= {{"Empty(T_MODBOR)", "BR_VERMELHO"},;
						{"!Empty(T_MODBOR)","BR_VERDE"}}
Private cMarca		:= GetMark()
Private aCampos		:= {	{"T_MARCA",		, ""},;
							{"T_XORIGPC", 	, "Orig PC Apr"},;
							{"T_NUM    ", 	, "Numero"},;
							{"T_MODBOR ", 	, "Modelo Bord"},;
							{"T_TIPBOR ", 	, "Tipo Bord"},;
							{"T_FORNECE", 	, "Fornecedor"},;
							{"T_LOJA   ", 	, "Loja"},;
							{"T_NOMFOR ", 	, "Nome Fornec"},;
							{"T_VENCREA", 	, "Vencto Real"},;
							{"T_VALOR  ", 	, "Valor",		"@E 999,999,999.99"},;
							{"T_XFORPAG", 	, "Forma Pagto"},;
							{"T_CODBAR ", 	, "Codigo Barras"},;
							{"T_FORBCO ", 	, "Banco"},;
							{"T_FORAGE ", 	, "Agencia"},;
							{"T_FAGEDV ", 	, "DV Agencia"},;
							{"T_FORCTA ", 	, "Conta"},;
							{"T_FCTADV ", 	, "DV Conta"},;
							{"T_PREFIXO", 	, "Prefixo"},;
							{"T_PARCELA", 	, "Parcela"},;
							{"T_TIPO", 		, "Tipo"},;
							{"T_CRITICA", 	, "Critica"}}
Private oEC, oMark, oDisplay

//———————————————————————————————————————————————————————————————————————————————
// Tratamento dos conteúdos dos parâmetros
//———————————————————————————————————————————————————————————————————————————————
if Empty(cBanco) .or. Empty(cAgencia) .or. Empty(cConta)
	Help("", 1, "Dados bancários inválidos",, "Preencha as informações de banco, agência e conta corrente." + chr(13) + chr(10) + "(Específico " + AllTrim(SM0->M0_NOME) + ")", 1)
	Return()
elseif dVctoIni > dVctoFim
	Help("", 1, "Intervalo inválido",, "No intervalo do período de vencimento, a data inicial deverá ser menor ou igual à data final." + chr(13) + chr(10) + "(Específico " + AllTrim(SM0->M0_NOME) + ")", 1)
	Return()
endif

//———————————————————————————————————————————————————————————————————————————————
// Ordenação das tabelas
//———————————————————————————————————————————————————————————————————————————————
SA2->(dbSetOrder(1))	//A2_FILIAL, A2_COD, A2_LOJA
SE2->(dbSetOrder(1))	//E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA
ZZR->(dbSetOrder(1))	//ZZR_FILIAL, ZZR_BANCO, ZZR_MODELO, ZZR_TIPO

//———————————————————————————————————————————————————————————————————————————————
// Criando o filtro para os titulos
//———————————————————————————————————————————————————————————————————————————————
cFiltro := "E2_TIPO NOT IN " + FormatIn(MVPROVIS + "|" + MV_CPNEG + "|PRE|" + MVABATIM, "|")  + " AND "

If FwIsInCallStack("FINA245") // considera somente titulos normais 
	cFiltro += "E2_TIPO <> '" + MVPAGANT + "' AND "
Else
	// Verifica MV_PAR01 -> 1 - Normais / 2 - Adiantamento
	If Upper(cCombo)=="NORMAIS"		//MV_PAR01 == 1  // 1 -> Titulos Normais   2-> Adiantamentos
		cFiltro += "E2_TIPO <> '" + MVPAGANT + "' AND "
	ElseIf  Upper(cCombo)=="ADIANTAMENTOS"		// MV_PAR01 == 2
		cFiltro += "E2_TIPO = '" + MVPAGANT + "' AND E2_NUMBCO = '" +  Space(TamSX3("E2_NUMBCO")[1]) + "' AND "
	Else  //Ambos
		cFiltro += "(E2_TIPO <> '" + MVPAGANT + "' OR E2_NUMBCO = '" +  Space(TamSX3("E2_NUMBCO")[1]) + "') AND "
	EndIf
EndIf

//Ignora os títulos que possuem cheques emitidos.
cFiltro += " E2_IMPCHEQ <> 'S' AND "

If SE2->(FieldPos("E2_NUMSOL")) > 0
	cFiltro += " E2_NUMSOL = '" + Space(Len(SE2->E2_NUMSOL)) + "' AND "
EndIf

//	If !IsInCallStack("FINA245")
//		cFiltro += "E2_MOEDA = 1 AND "
//	EndIf

cFIltro += "(E2_SALDO>0 AND E2_NUMBOR = '" + Space(TAMSX3("E2_NUMBOR")[1]) + "')"

// Verifica se pode baixar sem aprovação
If GetMv("MV_CTLIPAG")
	cFiltro += " AND (E2_DATALIB <> ' '"
	cFiltro += " OR (E2_SALDO + E2_SDACRES - E2_SDDECRE <= " + AllTrim(Str(GetMv("MV_VLMINPG"), 17, 2)) + "))"
EndIf

//	If !IsInCallStack("FINA245") .And. !(Empty(c240FilBT))
//		cFiltro := "(" + cFiltro + ") AND (" + c240FilBT + ")"
//	EndIf


//———————————————————————————————————————————————————————————————————————————————
// Query para seleção de registros
//———————————————————————————————————————————————————————————————————————————————
cQuery	:= "SELECT *, SE2.R_E_C_N_O_ NUM_REG"
//"E2_FILIAL"	, "E2_PREFIXO",	"E2_NUM"	, "E2_PARCELA",	"E2_TIPO"  , "E2_NATUREZ", "E2_PORTADO", "E2_FORNECE", "E2_LOJA", "E2_NOMFOR"	, "E2_VENCREA",	"E2_NUMBCO"	, "E2_SALDO"  ,	"E2_MOEDA" , "E2_NUMBOR" , "E2_FATPREF", "E2_FATURA" , "E2_ORDPAGO", "E2_ANOBASE", "E2_MESBASE",	"E2_SDACRES", "E2_SDDECRE",	"E2_PLLOTE", "E2_IDCNAB" , "E2_FILORIG", "E2_CODBAR" , "E2_PLOPELT", "E2_NODIA", "E2_EMIS1", "E2_ARQRAT"
cQuery += "E2_OK, SE2.R_E_C_N_O_ NUM_REG "
cQuery += "FROM " + RetSqlName("SE2") + " SE2 "

//Local lIntPFS    := SuperGetMv("MV_JURXFIN", .T., .F.) // Integração SIGAPFS x SIGAFIN
//	If lIntPFS .And. FWAliasInDic("OHF") // Integração SIGAPFS x SIGAFIN
//		cQuery += "INNER JOIN " + RetSqlName("SA2") + " SA2 "
//		cQuery +=    "ON SA2.A2_FILIAL = '" + xFilial("SA2") + "' "
//		cQuery +=   "AND SA2.A2_COD = SE2.E2_FORNECE "
//		cQuery +=   "AND SA2.A2_LOJA = SE2.E2_LOJA "
//		cQuery +=   "AND SA2.D_E_L_E_T_ = ' ' "
//		cQuery += "INNER JOIN " + RetSqlName("FK7") + " FK7 "
//		cQuery +=    "ON FK7.FK7_FILIAL = SE2.E2_FILIAL "
//		cQuery +=   "AND FK7.FK7_CHAVE = E2_FILIAL ||'|'|| E2_PREFIXO ||'|'|| E2_NUM  ||'|'|| E2_PARCELA ||'|'|| E2_TIPO ||'|'|| E2_FORNECE ||'|'|| E2_LOJA "
//		cQuery +=   "AND FK7.D_E_L_E_T_ = ' ' "
//		cQuery +=   "AND SE2.E2_BASEIRF = (SELECT SUM(OHF.OHF_VALOR) "
//		cQuery +=                           "FROM" + RetSqlName("OHF") + " OHF "
//		cQuery +=                          "WHERE OHF_FILIAL = '" + xFilial("OHF") + "' "
//		cQuery +=                            "AND OHF.OHF_IDDOC = FK7.FK7_IDDOC "
//		cQuery +=                            "AND OHF.D_E_L_E_T_ = ' ' "
//		cQuery +=                          "GROUP BY OHF.OHF_IDDOC)
//	EndIf

cQuery += "WHERE "

cQuery += "E2_FILIAL = '" + xFilial("SE2") + "' AND "

//	If MV_PAR09 == 1 //Considera Forma de Pgto?
//		cQuery += "E2_FORMPAG = '" + cModPgto + "' AND "
//	Endif

//	Local lPergDtAg  := Type("mv_par11") == "D" .and. Type("mv_par12") == "D" .and. mv_par10 == 1
//	If lPergDtAg .and. mv_par10 == 1 .and. !Empty(mv_par12) // Considera Agendamento
//		cQuery += "E2_DATAAGE <> ' ' AND "
//		cQuery += "E2_DATAAGE BETWEEN '" + DTOS(mv_par11) + "' AND '" + DTOS(mv_par12) + "' AND "
//	EndIf

cQuery += "E2_VENCREA BETWEEN '" + DtoS(dVctoIni) + "' AND '" + DtoS(dVctoFim) + "' AND "

cQuery += "SE2.D_E_L_E_T_ = ' ' AND "
cQuery += cFiltro + " "
cQuery += "ORDER BY E2_FILIAL, E2_VENCREA"
cQuery := ChangeQuery(cQuery)

if Select("QRYTMP") > 0
	QRYTMP->(dbCloseArea())
endif

if Select("TRAB") > 0
	TRAB->(dbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "QRYTMP", .F., .T.)
tcSetField("QRYTMP", "E2_VENCREA", "D")

//———————————————————————————————————————————————————————————————————————————————
// Gravando em tabela temporaria
//———————————————————————————————————————————————————————————————————————————————
dbSelectArea("QRYTMP")
dbGoTop()
if !eof()

	oTempTrb := FWTemporaryTable():New("TRAB", aArqTrab)
	oTempTrb:AddIndex("IND1", {"T_MODBOR","T_VENCREA", "T_NUM"})
	oTempTrb:Create()								//Utilizamos o método Create para criar a tabela temporária, ela será criada e aberta

	do while QRYTMP->(!eof())

		GetModelo(cBanco, @cModBor, @cTipBor)

		TRAB->(RecLock("TRAB", .T.))
		TRAB->T_MARCA		:= iif(!Empty(cModBor), cMarca, "")
		TRAB->T_XORIGPC		:= QRYTMP->E2_XORIGPC
		TRAB->T_MODBOR 		:= cModBor
		TRAB->T_TIPBOR		:= cTipBor
		TRAB->T_NUM    		:= QRYTMP->E2_NUM
		TRAB->T_FORNECE		:= QRYTMP->E2_FORNECE
		TRAB->T_LOJA   		:= QRYTMP->E2_LOJA
		TRAB->T_NOMFOR 		:= QRYTMP->E2_NOMFOR
		TRAB->T_VENCREA		:= QRYTMP->E2_VENCREA
		TRAB->T_VALOR  		:= QRYTMP->E2_VALOR
		TRAB->T_XFORPAG		:= QRYTMP->E2_XFORPAG
		TRAB->T_CODBAR 		:= QRYTMP->E2_CODBAR
		TRAB->T_FORBCO 		:= QRYTMP->E2_FORBCO
		TRAB->T_FORAGE 		:= QRYTMP->E2_FORAGE
		TRAB->T_FAGEDV 		:= QRYTMP->E2_FAGEDV
		TRAB->T_FORCTA 		:= QRYTMP->E2_FORCTA
		TRAB->T_FCTADV 		:= QRYTMP->E2_FCTADV
		TRAB->T_PREFIXO		:= QRYTMP->E2_PREFIXO
		TRAB->T_PARCELA		:= QRYTMP->E2_PARCELA
		TRAB->T_TIPO 		:= QRYTMP->E2_TIPO
		TRAB->T_CRITICA		:= iif(Empty(cModBor), "Não identificado modelo de borderô. Verifique as regras", "")
		TRAB->T_REGISTRO	:= QRYTMP->NUM_REG
		TRAB->(MsUnlock())

		nTotProc 	+= iif(!Empty(cModBor), QRYTMP->E2_VALOR, 0)
		nTotGeral	+= QRYTMP->E2_VALOR
		
		QRYTMP->(dbSkip())

	enddo	

	dbSelectArea("TRAB")
	dbGoTop()

	@ 050,001 TO 600,1300 Dialog oEC Title OemToAnsi("Títulos para processo de pagamento - " + cProcesso)

	@ 07,05 Say OemtoAnsi("Banco " + cBanco + "  -  Agência " + cAgencia + "  -  Conta Corrente " + cConta) Size 200,8 COLOR CLR_BLUE Pixel Of oEC

	@ 20,05 Say OemtoAnsi("Total Geral") Size 60,8 Pixel Of oEC
	@ 17,50 MsGet oDisplay Var nTotGeral Picture "@E 999,999,999.99" When .F. Size C(50),C(008) COLOR CLR_BLUE Pixel of oEC

	@ 20,145 Say OemtoAnsi("Selecionados:") Size 60,8 Pixel Of oEC
	@ 17,190 MsGet oDisplay Var nTotProc Picture "@E 999,999,999.99" When .F. Size C(50),C(008) COLOR CLR_BLUE Pixel of oEC

	oMark	:= MsSelect():New("TRAB", "T_MARCA" , "", aCampos, .F., @cMarca, {035,002,240,650},,,,,aCores)
	oMark:bMark := {|| SelectReg(@nTotProc), oMark:oBrowse:Refresh()} 

	@ 250, 010 Button OemtoAnsi("Marca/Desmarca todos") Size 60,12 Pixel of oEC Action MarcaTodos(@nTotProc, @lMarca)
	@ 250, 080 Button OemtoAnsi("Inverte seleção") Size 60,12 Pixel of oEC Action InverteMarca(@nTotProc)
	@ 250, 510 Button OemtoAnsi("Gera Borderôs") Size 60,12 Pixel of oEC Action (Processa({|| GeraBordero(cProcesso, cBanco, cAgencia, cConta)}, "Gerando borderôs de pagamentos..."), oEC:End())
	@ 250, 580 Button OemtoAnsi("Cancela operação") Size 60,12 Pixel of oEC Action (oEC:End())

	Activate Dialog oEC Centered

	oTempTrb:Delete()

else

	Help("", 1, "Sem registros",, "Registros não encontrados." + chr(13) + chr(10) + "(Específico " + AllTrim(SM0->M0_NOME) + ")", 1)

endif

if Select("QRYTMP") > 0
	QRYTMP->(dbCloseArea())
endif

Return()


/*/
{Protheus.doc} SELECTREG
Função para seleção dos registros (markbrowse).	
Desenvolvida de forma a não permitir que o usuário marque ou desmarque registros.
Uso Brasitech
@type Static Function
@since 31/05/2022
@return
/*/
Static Function SelectReg(nTotProc)
Local lPermite	:= !Empty(TRAB->T_MODBOR)

TRAB->(RecLock("TRAB",.F.))
if lPermite
	TRAB->T_MARCA := iif(TRAB->T_MARCA!=cMarca, "", cMarca)
else
	TRAB->T_MARCA := iif(TRAB->T_MARCA==cMarca, "", cMarca)
endif
TRAB->(MsUnlock())

if lPermite
	if Empty(TRAB->T_MARCA)
		nTotProc -= TRAB->T_VALOR
	else
		nTotProc += TRAB->T_VALOR
	endif
endif
oMark:oBrowse:Refresh()
oDisplay:Refresh()

Return() 


/*/
{Protheus.doc} MARCATODOS
Marca todos os itens selecionados
Uso Brasitech
@type Static Function
@since 31/05/2022
@return
/*/
Static Function MarcaTodos(nTotProc, lMarca)
Local nRec		:= TRAB->(Recno())

TRAB->(dbGoTop())
do while TRAB->(!eof())

	if !Empty(TRAB->T_MODBOR)

		if lMarca .and. TRAB->T_MARCA!=cMarca
			TRAB->(RecLock("TRAB",.F.))
			TRAB->T_MARCA := cMarca
			TRAB->(MsUnlock())
			nTotProc += TRAB->T_VALOR
		elseif !lMarca .and. TRAB->T_MARCA==cMarca
			TRAB->(RecLock("TRAB",.F.))
			TRAB->T_MARCA := ""
			TRAB->(MsUnlock())
			nTotProc -= TRAB->T_VALOR
		endif

	endif

	TRAB->(dbSkip())

enddo

TRAB->(dbGoTo(nRec))

oMark:oBrowse:Refresh()
oDisplay:Refresh()

//———————————————————————————————————————————————————————————————————————————————
// Inversão da variável lMarca
//———————————————————————————————————————————————————————————————————————————————
lMarca := !lMarca

Return()


/*/
{Protheus.doc} INVERTEMARCA
Inverte a marca dos registros selecionados
Uso Brasitech
@type Static Function
@since 31/05/2022
@return
/*/
Static Function InverteMarca(nTotProc)
Local nRec		:= TRAB->(Recno())

TRAB->(dbGoTop())
do while TRAB->(!eof())
	if !Empty(TRAB->T_MODBOR)

		TRAB->(RecLock("TRAB",.F.))
		TRAB->T_MARCA := iif(TRAB->T_MARCA==cMarca, "", cMarca)
		TRAB->(MsUnlock())

		if Empty(TRAB->T_MARCA)
			nTotProc -= TRAB->T_VALOR
		else
			nTotProc += TRAB->T_VALOR
		endif

	endif
	TRAB->(dbSkip())
enddo

TRAB->(dbGoTo(nRec))

oMark:oBrowse:Refresh()
oDisplay:Refresh()
Return()


/*/
{Protheus.doc} GETMODELO
Identifica o modelo do borderô, de acordo com a regra definida no cadastro de borderô x Modelo
Uso Brasitech
@type Static Function
@since 31/05/2022
@author Processo definida por Ricky Elenita
@return
/*/
Static Function GetModelo(cBanco, cModBor, cTipBor)
Local cRegra

cModBor		:= "  "
cTipBor		:= "  "

// Somente títulos que não forem débito em conta
if QRYTMP->E2_XFORPAG != "DBC"
	ZZR->(dbSeek(xFilial("ZZR") + cBanco))
	do while ZZR->(!eof() .and. ZZR_FILIAL == xFilial("ZZR") .and. ZZR_BANCO==cBanco)
		cRegra := StrTran(AllTrim(ZZR->ZZR_REGRA), "SE2->", "QRYTMP->")
		if &cRegra
			cModBor		:= ZZR->ZZR_MODELO
			cTipBor		:= ZZR->ZZR_TIPO
			Exit
		endif
		ZZR->(dbSkip())
	enddo
endif

Return()


/*/
{Protheus.doc} GERABORDERO
Grava o registro do bordero de pagamentos (SEA) e atualiza titulos a pagar (SE2)
Gera o registro do processo de pagamento (ZZP)
Uso Brasitech
@type Static Function
@since 31/05/2022
@author Processo definida por Ricky Elenita
@return
/*/
Static Function GeraBordero(cProcesso, cBanco, cAgencia, cConta)
Local lVersao		:= SEA->(ColumnPos("EA_VERSAO")) > 0
Local nTamNroBor    := Len(SE2->E2_NUMBOR)
Local lGravaProc	:= .F.
Local cNumBor, cModelo

Close(oEC)

//———————————————————————————————————————————————————————————————————————————————
// Geração dos borderôs por modelo
//———————————————————————————————————————————————————————————————————————————————
TRAB->(dbGoTop())

do while !TRAB->(Eof())

	if Empty(TRAB->T_MODBOR) .or. TRAB->T_MARCA != cMarca
		TRAB->(dbSkip())
		loop
	endif

	// Verifica numero do ultimo Bordero Gerado	
	If Empty(cNumBor := GetMV("MV_NUMBORP"))
		cNumBor := "000000"
	EndIf
		
	cNumBor := Soma1(Pad(cNumBor, nTamNroBor), nTamNroBor)	 
	SEA->(dbSetOrder(2))
		
	While .T.
		If SEA->(DbSeek(xFilial("SEA") + cNumBor + "P", .T.))
			cNumBor := Soma1(cNumBor)
		Else
			Exit
		Endif
	Enddo

	cModelo := TRAB->T_MODBOR

	do while TRAB->(!Eof() .and. T_MODBOR == cModelo)

		If TRAB->T_MARCA == cMarca
			lGravaProc	:= .T.
			cTipoPag	:= TRAB->T_TIPBOR

			SE2->(MsGoTo(TRAB->T_REGISTRO))

			SEA->(RecLock("SEA", .T.))
			SEA->EA_FILIAL  := xFilial("SEA")
			SEA->EA_PORTADO := cBanco
			SEA->EA_AGEDEP  := cAgencia
			SEA->EA_NUMCON  := cConta
			SEA->EA_NUMBOR  := cNumBor
			SEA->EA_DATABOR := dDataBase
			SEA->EA_PREFIXO := SE2->E2_PREFIXO
			SEA->EA_NUM     := SE2->E2_NUM
			SEA->EA_PARCELA := SE2->E2_PARCELA
			SEA->EA_TIPO    := SE2->E2_TIPO
			SEA->EA_FORNECE := SE2->E2_FORNECE
			SEA->EA_LOJA	:= SE2->E2_LOJA
			SEA->EA_CART    := "P"
			SEA->EA_MODELO  := cModelo
			SEA->EA_TIPOPAG := cTipoPag
			SEA->EA_FILORIG := SE2->E2_FILORIG
			SEA->EA_ORIGEM  := "FINA240"
			If lVersao
				SEA->EA_VERSAO  := "0001"
			Endif
			SEA->(MsUnlock())

			SE2->(RecLock("SE2", .F.))
			SE2->E2_NUMBOR  := cNumBor
			SE2->E2_PORTADO := cBanco
			SE2->E2_DTBORDE := dDataBase
			SE2->(MsUnlock())

			//Abro o SE2 com outro Alias se o mesmo não estiver aberto
			If Select("__SE2") == 0
				ChkFile("SE2",.F.,"__SE2")
			Else
				DbSelectArea("__SE2")
			EndIf

			//Gravo o numero do bordero em todos os titulos de abatimentos
			__SE2->(dbSetOrder(1))
			__SE2->(MsSeek(xFilial("SE2")+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA)))
			While !EOF() .And. __SE2->E2_FILIAL==xFilial("SE2") .And. __SE2->E2_PREFIXO == SE2->E2_PREFIXO .And.;
					__SE2->E2_NUM == SE2->E2_NUM .And. __SE2->E2_PARCELA == SE2->E2_PARCELA
				IF __SE2->E2_TIPO $ MVABATIM .And. __SE2->E2_FORNECE == SE2->E2_FORNECE
					RecLock("__SE2")
					Replace E2_NUMBOR  With cNumBor
					Replace E2_PORTADO With cBanco
					MsUnlock()
					FKCOMMIT()
				Endif
				dbSkip()
			Enddo

			dbSelectArea("SE2")

		Endif

		TRAB->(dbskip())
	
	enddo

	if lGravaProc
		ZZP->(RecLock("ZZP", .T.))
		ZZP->ZZP_FILIAL		:= xFilial("ZZP")
		ZZP->ZZP_PROC		:= cProcesso
		ZZP->ZZP_BORD		:= cNumBor
		ZZP->ZZP_MODELO		:= cModelo
		ZZP->ZZP_TIPO		:= cTipoPag
		ZZP->ZZP_EMISSA		:= dDataBase
		ZZP->ZZP_LOG		:= "Criado em " + dTOc(Date()) + " as " + Time() +" por " + cUserName
		ZZP->(MsUnlock())
	endif

	// Grava o numero do bordero atualizado
	If GetMV("MV_NUMBORP") < cNumbor
		PutMV("MV_NUMBORP", cNumbor)
	Endif	

enddo
			
Return()


/*/
{Protheus.doc} C
Manter o Layout independente da resolução horizontal do Monitor do Usuario.
Uso Brasitech
@type Static Function
@since 31/05/2022
@author Norbert Waage Junior
@return
/*/
Static Function C(nTam)                                                         
Local nHRes	:=	oMainWnd:nClientWidth	//Resolucao horizontal do monitor
Do Case                                                                         
	Case nHRes == 640	//Resolucao 640x480                                         
		nTam *= 0.8                                                                
	Case nHRes == 800	//Resolucao 800x600                                         
		nTam *= 1                                                                  
	OtherWise			//Resolucao 1024x768 e acima                                
		nTam *= 1.28                                                               
EndCase                                                                         
Return Int(nTam)                                                                


/*/
{Protheus.doc} VLDBORDERO
Valida existencia do número do borderô digitado.
Uso Brasitech
@type Static Function
@since 31/05/2022
@author Processo definida por Ricky Elenita
@return
/*/
Static Function VldBanco(cBanco, cAgencia, cConta, cNomeBco)
Local lRet 		:= .T.
Local cChave	:= cBanco

if !Empty(cAgencia)
	cChave += cAgencia
endif
if !Empty(cConta)
	cChave += cConta
endif

SA6->(dbSetOrder(1))		//A6_FILIAL, A6_COD, A6_AGENCIA, A6_NUMCON
if SA6->(dbSeek(xFilial("SA6") + cChave))
	cNomeBco	:= AllTrim(SA6->A6_NOME)
else
	lRet	:= .F.
	Help("", 1, "Banco",, "Banco não encontrado, informe um código válido. " + chr(13) + chr(10) + "(Especifico " + AllTrim(SM0->M0_NOME) + ")", 1)
endif

Return(lRet)
