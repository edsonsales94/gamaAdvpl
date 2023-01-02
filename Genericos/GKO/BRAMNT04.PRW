#include "rwmake.ch"
#include "protheus.ch" 
#include "tbiconn.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		BRAMNT04                                                     /@
@type			User function                                                /@
@date			29/11/2021                                                   /@
@description	Manutenção e integração de XML Infracommerce em notas de 
				entrada ou saída, atraves de rotina do fiscal. 
				Inclusão de titulos a pagar ou receber e movimentação de 
				estoque                                                      /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Tecnologia                                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function BRAMNT04()
//Local aArea 		:= GetArea()
Local aCores		:= {	{"ZZH_STATUS == '0'",	"BR_VERDE"},;
							{"ZZH_STATUS == '1'",	"BR_AMARELO"},;
							{"ZZH_STATUS == '2'",	"BR_VERMELHO"},;
							{"ZZH_STATUS == '8'",	"BR_PRETO"},;
							{"ZZH_STATUS == '9'",	"BR_CANCEL"}}
Local lContinua		:= .T.
Private cCadastro	:= "Gerenciamento de Faturas GKO"
Private aRotina   	:= {	{"Pesquisa",	"AxPesqui",														0, 1},;
							{"Visualiza",	"U_MNT04GKO",													0, 2},;
							{"Exclui",		"U_MNT04GKO",													0, 3},;
							{"Integra",		"Processa({|| U_MNT04Integra(.T.)}, 'Integrando Fatura GKO')",	0, 6},;
							{"Cod.Barras",	"U_MNT04Barras",												0, 6},;
							{"Cancela",		"Processa({|| U_MNT04Cancela()}, 'Cancelando processo')",		0, 6},;
							{"Consulta Log","U_MNT04Log",													0, 6},;
							{"Legenda",		"U_MNT04Legenda",												0, 7}}
Private aSize		:= MsAdvSize()
Private aObjects	:= {	{100, 100, .T., .T.},;
							{100, 100, .T., .T.},;
							{100, 015, .T., .F.}}
Private aInfo		:= {aSize[1], aSize[2], aSize[3], aSize[4], 3, 3}
Private aPosObj		:= MsObjSize(aInfo, aObjects)
//Private aPosGet	:= MsObjGetPos((aSize[3] - aSize[1]), 315, {{004, 024, 240, 270}})

if lContinua

	dbSelectArea("ZZH")
	dbSetOrder(1)
	dbSeek(xFilial("ZZH"))
	mBrowse(,,,, "ZZH",,,,,, aCores)

endif

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		MNT04Legenda                                                 /@
@type			User function                                                /@
@date			29/11/2021                                                   /@
@description	Exibe a legenda Faturas importados                           /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MNT04Legenda()
Local aLegenda := {	{"BR_VERDE", 	"Fatura pendente de integração"},;
					{"BR_AMARELO", 	"Fatura em aprovação (PC)"},;
					{"BR_VERMELHO", "Fatura integrada NF entrada"},;
					{"BR_PRETO", 	"Fatura com inconsitência"},;
					{"BR_CANCEL", 	"Processo cancelado"}}

BrwLegenda(cCadastro, OemToAnsi("Legendas"), aLegenda)

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		MNT04GKO                                                     /@
@type			User function                                                /@
@date			29/11/2021                                                   /@
@description	Rotina manutenção Faturas GKO                                /@
@author			Adalberto Moreno Batista (Opção Um Consultoria)              /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MNT04GKO(cAlias, nRecNo, nOpc)
//Local aArea			:= GetArea()
Local bCampo		:= {|nField| FieldName(nField) }
Local nUsado		:= 0
Local nCols			:= 0
Local aAltera		:= {}
Local nX, oDlg, oMainWnd, oGet, nOpcA
Private aHeader		:= {}
Private aCols		:= {}

//———————————————————————————————————————————————————————————————————————————————
// Permito a alteracao somente se a XML não tiver sido integrado
//———————————————————————————————————————————————————————————————————————————————
if ZZH->ZZH_STATUS $ "1.2" .and. nOpc == 3
	Help(,, "ATENÇÃO",, "A Fatura não poderá ser alterada ou excluída, pois já foi integrado para um pedido de compras." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
	Return()
endif

//———————————————————————————————————————————————————————————————————————————————
// Inicia as variáveis para enchoice
//———————————————————————————————————————————————————————————————————————————————
for nX := 1 to fCount()
	M->&(Eval(bCampo, nX)) := FieldGet(nX)			//iif(nOpc==3, CriaVar(FieldName(nX),.T.), FieldGet(nX))
next

//———————————————————————————————————————————————————————————————————————————————
// Cria aHeader
//———————————————————————————————————————————————————————————————————————————————
dbSelectArea("SX3")
SX3->(dbSetOrder(1))
if SX3->(dbSeek("ZZF"))
	do while SX3->(!eof() .and. X3_ARQUIVO == "ZZF")
		if X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL .and. !AllTrim(SX3->X3_CAMPO) $ "ZZF_FILIAL#ZZF_CNPJTR#ZZF_FATURA#ZZF_PREFIX"
			aAdd(aHeader, {	Trim(X3Titulo()),;
							SX3->X3_CAMPO,;
							SX3->X3_PICTURE,;
							SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,;
							SX3->X3_VALID,;
							SX3->X3_USADO,;
							SX3->X3_TIPO,;
							SX3->X3_ARQUIVO,;
							SX3->X3_CONTEXT})
			nUsado++
		endif
		SX3->(dbSkip())
	enddo
endif

//———————————————————————————————————————————————————————————————————————————————
// Cria aCols
//———————————————————————————————————————————————————————————————————————————————
dbSelectArea("ZZF")
ZZF->(dbSetOrder(1))	//ZZF_FILIAL, ZZF_CNPJTR, ZZF_FATURA, ZZF_PREFIX, ZZF_NCF, ZZF_NCFSER, ZZF_NFBR, ZZF_SERBR
ZZF->(dbSeek(xFilial("ZZF") + ZZH->ZZH_CNPJTR + ZZH->ZZH_FATURA + ZZH->ZZH_PREFIX + ZZH->ZZH_SEQCAN))
do while ZZF->(!eof() .and. ZZF_FILIAL + ZZF_CNPJTR + ZZF_FATURA + ZZF_PREFIX + ZZF_SEQCAN == xFilial("ZZF") + ZZH->ZZH_CNPJTR + ZZH->ZZH_FATURA + ZZH->ZZH_PREFIX + ZZH->ZZH_SEQCAN)
	aAdd(aCols, Array(nUsado + 1))
	nCols++
	
	for nX := 1 To nUsado
		if aHeader[nX,10] != "V"
			aCols[nCols][nX] := ZZF->(FieldGet(FieldPos(aHeader[nX,2])))
		else
			aCols[nCols][nX] := ZZF->(CriaVar(aHeader[nX,2], .T.))
		endif
	next
	
	aCols[nCols, nUsado + 1] := .F.

	aAdd(aAltera, ZZF->(RecNo()))
	
	ZZF->(dbSkip())
enddo

//———————————————————————————————————————————————————————————————————————————————
// Envia para processamento dos Gets
//———————————————————————————————————————————————————————————————————————————————
Define MsDialog oDlg Title OemToAnsi(cCadastro) From aSize[7], aSize[1] to aSize[6], aSize[5] Of oMainWnd Pixel
EnChoice(cAlias, nRecNo, nOpc,,,,, aPosObj[1],, 3)
oGet := MSGetdados():New(aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4], nOpc, ".T.",,, iif(nOpc==3, .T., .F.))
Activate MsDialog oDlg On Init EnchoiceBar(oDlg, {|| nOpcA:=1, oDlg:End()}, {||nOpcA := 0, oDlg:End()})

if nOpcA == 1 .and. nOpc == 3

	Begin Transaction

		ZZH->(RecLock("ZZH", .F.))
		ZZH->(dbDelete())
		ZZH->(MsUnLock())

		for nX := 1 to Len(aAltera)
			ZZF->(dbGoTo(aAltera[nX]))
			ZZF->(RecLock("ZZF", .F.))
			ZZF->(dbDelete())
			ZZF->(MsUnLock())
		next
		
	End Transaction

	nOpcA := 0
	
endif

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		MNT04Integra                                                 /@
@type			User function                                                /@
@date			29/11/2021                                                   /@
@description	Integra a fatura no pedido de compras para submeter a uma 
				aprovação.                                                   /@
@author			Adalberto Moreno Batista (Opção Um Consultoria)              /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MNT04Integra(lManual)
Local cProduto	:= GetMV("BR_GKOFTPR", .F., "SVIVS0000000514")
Local cTES		:= GetMV("BR_GKOFTTE", .F., "451")
Local cCusto    := GetMV("BR_GKOFTCC", .F., "1051")
Local cUserCP   := GetMV("BR_GKOFTUS", .F., "001211")
Local cCondPag	:= GetMV("BR_GKOCP", .F., " ")
Local cDestinat := GetMV("BR_GKOMAIL", .F., "equipe.ti@gamaitaly.com.br")
Local cStrFixo	:= "FATURA GKO " + ZZH->ZZH_FATURA + "/" + ZZH->ZZH_PREFIX + " CNPJ " + Transform(ZZH->ZZH_CNPJTR,"@R 99.999.999/9999-99") + " arquivo " + AllTrim(ZZH->ZZH_ARQUIVO)
Local cStrErro	:= ""
Local aCabPC, aItemPC, nValor, cObs, cLog, cNum
Private lMsErroAuto		:= .F.
Public cGI120ForPag		:= "1"	//Boleto no PC
Public cGI120Bco		:= Space(Len(SC7->C7_XBANCO))
Public cGI120Age		:= Space(Len(SC7->C7_XAGENC))
Public cGI120DVAge		:= Space(Len(SC7->C7_XDVAGE))
Public cGI120Cta		:= Space(Len(SC7->C7_XCONTA))
Public cGI120DVCta		:= Space(Len(SC7->C7_XDVCTA))

//———————————————————————————————————————————————————————————————————————————————
// Verifico se a fatura já foi integrada
//———————————————————————————————————————————————————————————————————————————————
if ZZH->ZZH_STATUS != "0"
	
	Help(,, "ATENÇÃO",, "Fatura já integrada." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)

else

    SA2->(dbSetOrder(3))        //A2_FILIAL, A2_COD, A2_LOJA
    if SA2->(dbSeek(xFilial("SA2") + ZZH->ZZH_CNPJTR))

		//———————————————————————————————————————————————————————————————————————————————
		// Determinando a forma de pagamento do PC, conforme configurado no Fornecedor
		//———————————————————————————————————————————————————————————————————————————————
		if SA2->A2_X_FGTO == "2" .or. SA2->A2_X_FGTO == "1"	//Boleto ou Normal
			cGI120ForPag	:= "1"

		elseif SA2->A2_X_FGTO == "4"	//Deposito em Conta
			cGI120ForPag	:= "2"
			cGI120Bco		:= SA2->A2_BANCO
			cGI120Age		:= SA2->A2_AGENCIA
			cGI120DVAge		:= SA2->A2_DVAGE
			cGI120Cta		:= SA2->A2_NUMCON
			cGI120DVCta		:= SA2->A2_DVCTA

		elseif SA2->A2_X_FGTO == "3"	//Dinheiro
			cGI120ForPag	:= "3"

		endif

		dbSelectArea("SC7")
		dbSetOrder(1)

        cDoc := GetSXENum("SC7","C7_NUM")
        While SC7->(dbSeek(xFilial("SC7")+cDoc))
			ConfirmSX8()
			cDoc := GetSXENum("SC7","C7_NUM")
        EndDo
		nValor		:= ZZH->ZZH_VALOR - ZZH->ZZH_DESCON
		cObs		:= "FATURA GKO " + ZZH->ZZH_FATURA + "/" + ZZH->ZZH_PREFIX
		cCondPag	:= iif(Empty(SA2->A2_COND), cCondPag, SA2->A2_COND)

		aCabPC  := {    {"C7_NUM",      cDoc,					Nil},;
                        {"C7_EMISSAO",  dDataBase,				Nil},;
                        {"C7_FORNECE",  SA2->A2_COD,			Nil},;
                        {"C7_LOJA",     SA2->A2_LOJA,			Nil},;
                        {"C7_COND",     cCondPag,				Nil},;
                        {"C7_CONTATO",  "EVENTO GKO",			Nil},;
						{"C7_USER",  	cUserCP, 	       		Nil},;
                        {"C7_FILENT",   cFilAnt,				Nil}}

        aItemPC  := {{  {"C7_PRODUTO",  cProduto,      			Nil},;
                        {"C7_QUANT",    1,             			Nil},;
                        {"C7_PRECO",    nValor,					Nil},;
                        {"C7_TOTAL",    nValor,					Nil},;
                        {"C7_TES",      cTES,       			Nil},;
                        {"C7_CC",       cCusto,     			Nil},;
						{"C7_OBS",  	cObs, 					Nil},;
						{"C7_XCATEG",  	"LG",					Nil},;
						{"C7_X_FORPG",  cGI120ForPag,      		Nil},;
                        {"C7_XGKOFAT",  ZZH->ZZH_FATURA,		Nil},;
						{"C7_XGKOPRE",  ZZH->ZZH_PREFIX,		Nil}}}
		
		lMsErroAuto	:= .F.
        MSExecAuto({|a,b,c,d,e| MATA120(a,b,c,d,e)}, 1, aCabPC, aItemPC, 3)
					
    	if lMsErroAuto

			if lManual
				Help(,, "ATENÇÃO",, "Não foi possivel gerar o pedido de compras." + chr(13) + chr(10) + GetAutoGRLog() + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
			else
				cStrErro := "Não foi possivel gerar o pedido de compras." + chr(13) + chr(10) + GetAutoGRLog()
			endif

		else

			cNum	:= SC7->C7_NUM

			cLog	:= ZZH->ZZH_LOG	+ "Integração com pedido de compra " + SC7->C7_NUM + " em " + dTOc(Date()) + " as " + Time() + Chr(13) + Chr(10) + Repl("=",62) + Chr(13) + Chr(10)
			ZZH->(RecLock("ZZH", .F.))
			ZZH->ZZH_STATUS	:= "1"
			ZZH->ZZH_PEDCOM	:= SC7->C7_NUM
			ZZH->ZZH_LOG	:= cLog
			ZZH->(MsUnLock())

			SC7->(dbSeek(xFilial("SC7") + cNum))
			do while SC7->(!eof() .and. C7_FILIAL==xFilial("SC7") .and. C7_NUM==cNum)
				SC7->(RecLock("SC7", .F.))
				SC7->C7_XGKOFAT	:= ZZH->ZZH_FATURA
				SC7->C7_XGKOPRE	:= ZZH->ZZH_PREFIX
				SC7->(dbSkip())
			enddo
			SC7->(dbSeek(xFilial("SC7") + cNum))

			GeraAnexoPed()

		endif
			
	else

		cStrErro := "Transportadora não cadastrada."
		
	endif

endif

// Envio de erro
if !empty(cStrErro)
	if lManual
		Help(,, "ATENÇÃO",, cStrErro + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
	else
		GISendMail(cDestinat,,, cStrFixo, cStrFixo + chr(13) + chr(10) + cStrErro)
	endif
endif
Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		MNT04Cancela                                                 /@
@type			User function                                                /@
@date			07/02/2022                                                   /@
@description	Cancela uma operação GKO integrada, cancelando o pedido e 
				nota, caso tenha sido aprovado                               /@
@author			Adalberto Moreno Batista (Opção Um Consultoria)              /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MNT04Cancela()
Local aCabPC, aItemPC, cLog, nRegZZH, cSeqCan
Private lMsErroAuto	:= .F.

//———————————————————————————————————————————————————————————————————————————————
// Verifico o status da fatura
//———————————————————————————————————————————————————————————————————————————————
if ZZH->ZZH_STATUS == "1"

	if MsgYesNo("Deseja cancelar o processo?", "Pergunta")
	
		ZZH->(dbSetOrder(1))		//ZZH_FILIAL, ZZH_CNPJTR, ZZH_FATURA, ZZH_PREFIX, ZZH_SEQCAN
		dbSelectArea("SC7")
		dbSetOrder(1)

		if SC7->(dbSeek(xFilial("SC7") + ZZH->ZZH_PEDCOM))

			aCabPC  := {    {"C7_NUM",      SC7->C7_NUM,			Nil},;
							{"C7_EMISSAO",  SC7->C7_EMISSAO,		Nil},;
							{"C7_FORNECE",  SC7->C7_FORNECE,		Nil},;
							{"C7_LOJA",     SC7->C7_LOJA,			Nil},;
							{"C7_COND",     SC7->C7_COND,			Nil},;
							{"C7_FILENT",   SC7->C7_FILENT,			Nil}}

			aItemPC  := {{  {"C7_PRODUTO",  SC7->C7_PRODUTO,      	Nil},;
							{"C7_QUANT",    SC7->C7_QUANT,          Nil},;
							{"C7_PRECO",    SC7->C7_PRECO,			Nil},;
							{"C7_TOTAL",    SC7->C7_TOTAL,			Nil},;
							{"C7_TES",      SC7->C7_TES,       		Nil},;
							{"C7_CC",       SC7->C7_CC,     		Nil}}}
				
			lMsErroAuto	:= .F.
			MSExecAuto({|a,b,c,d,e| MATA120(a,b,c,d,e)}, 1, aCabPC, aItemPC, 5)
							
			if lMsErroAuto

				Help(,, "ATENÇÃO",, "Ocorreu um erro no cancelamento do processo (exclusão do pedido de compras). Informar o problema no departamento de TI." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
				MostraErro()
						
			else

				nRegZZH 	:= ZZH->(Recno())
				cSeqCan		:= "001"
				cChave		:= ZZH->(ZZH_FILIAL + ZZH_CNPJTR + ZZH_FATURA + ZZH_PREFIX)

				do while ZZH->(dbSeek(cChave + cSeqCan))
					cSeqCan := StrZero(Val(cSeqCan) + 1, 3)
				enddo

				ZZH->(dbGoTo(nRegZZH))

				cLog	:= ZZH->ZZH_LOG	+ "Pedido de compra " + ZZH->ZZH_PEDCOM + " excluido e processo Fatura GKO cancelado em " + dTOc(Date()) + " as " + Time() + ", por " + cUserName + Chr(13) + Chr(10) + Repl("=",62) + Chr(13) + Chr(10)
				ZZH->(RecLock("ZZH", .F.))
				ZZH->ZZH_STATUS	:= "9"
				ZZH->ZZH_SEQCAN	:= cSeqCan
				ZZH->ZZH_LOG	:= cLog
				ZZH->(MsUnLock())

				ZZF->(dbSetOrder(1))	//ZZF_FILIAL, ZZF_CNPJTR, ZZF_FATURA, ZZF_PREFIX, ZZF_NCF, ZZF_NCFSER, ZZF_NFBR, ZZF_SERBR
				do while ZZF->(dbSeek(xFilial("ZZF") + ZZH->ZZH_CNPJTR + ZZH->ZZH_FATURA + ZZH->ZZH_PREFIX + "   "))
					ZZF->(RecLock("ZZF", .F.))
					ZZF->ZZF_SEQCAN	:= cSeqCan
					ZZF->(MsUnLock())
				enddo

			endif

		else
			Help(,, "ATENÇÃO",, "Pedido de compras " + ZZH->ZZH_PEDCOM + " não encontrado. Informar o problema no departamento de TI." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)

		endif

	endif

elseif ZZH->ZZH_STATUS == "0"
	Help(,, "ATENÇÃO",, "Fatura não foi integrada, portanto o registro poderá ser excluido." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)

else
	Help(,, "ATENÇÃO",, "Este processo não poderá ser cancelado pois está INTEGRADO, COM INCONSISTÊNCIA ou CANCELADO." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)

endif

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		MNT04Log                                                     /@
@type			User function                                                /@
@date			29/11/2021                                                   /@
@description	Consulta o log de operações referente ao registro ZZH        /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MNT04Log()
Local cTexto := ZZH->ZZH_LOG

Define Font oFont Name "Mono AS" Size 6,14

Define MsDialog oDlg Title "Log de operações faturas GKO" From 3, 0 to 530, 650 Pixel

@ 5, 5 Get oMemo Var cTexto Memo when .F. Size 320, 225 Of oDlg Pixel
oMemo:bRClicked := { || AllwaysTrue() }
oMemo:oFont     := oFont

Define SButton From 240, 280 Type 1 Action oDlg:End() Enable Of oDlg Pixel

Activate MsDialog oDlg Center

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		GeraAnexoPed                                                 /@
@type			User function                                                /@
@date			31/01/2022                                                   /@
@description	Gera anexos do pedido de faturas GKO                         /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function GeraAnexoPed()
Local cHtml 		:= ""
Local cLinkLogo	    := AllTrim(GetMV("BR_LNKLOGO", .F., "https://sweb.gamaitaly.com.br/images/LogoGamaPeq.jpg"))
Local cDirAnexos	:= GetMV("BR_ANEXOPC")
Local cAno			:= StrZero(Year(SC7->C7_EMISSAO), 4)
Local cMes			:= StrZero(Month(SC7->C7_EMISSAO), 2)
Local cArqDest 		:= cDirAnexos + "\" + cEmpAnt + cFilAnt + "\pc\" + cAno + "\mes_" + cMes + "\" + cFilAnt + "_" + SC7->C7_NUM + "_GKOConfFat.html"

Local cVencto 		:= ""
Local cEvento 		:= ""
Local cFormPag		:= iif(SC7->C7_X_FORPG == "1", "Boleto",;
							iif(SC7->C7_X_FORPG == "2", "Depósito em conta",;
							iif(SC7->C7_X_FORPG == "3", "Dinheiro",;
							iif(SC7->C7_X_FORPG == "4", "Cheque",;
							"Não identificada"))))
Local cFornecedor	:= ""
Local cCNPJ			:= ""
Local cStrNotas		:= ""
Local nTotFretReal	:= nTotFretPrev := nTotSomaNF := 0
Local nIndPrev, nIndReal, nDifer, cChvZZF, cNCF, cNCFSer

SA2->(DbSetOrder(1))
ZZH->(DbSetOrder(1))	//ZZH_FILIAL, ZZH_CNPJTR, ZZH_FATURA, ZZH_PREFIX, ZZH_SEQCAN
ZZF->(DbSetOrder(1))	//ZZF_FILIAL, ZZF_CNPJTR, ZZF_FATURA, ZZF_PREFIX, ZZF_SEQCAN, ZZF_NCF, ZZF_NCFSER, ZZF_NFBR, ZZF_SERBR

SA2->(dbSeek(xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA))
cFornecedor	:= AllTrim(SA2->A2_NOME)
cCNPJ		:= Transform(SA2->A2_CGC, "@R 99.999.999/9999-99")

//ZZH->(dbSeek(xFilial("ZZH") + SA2->A2_CGC + SC7->C7_XGKOFAT + SC7->C7_XGKOPRE + cSeqCan))
cVencto		:= dTOc(ZZH->ZZH_VENCTO)
cChvZZF		:= xFilial("ZZF") + ZZH->(ZZH_CNPJTR + ZZH_FATURA + ZZH_PREFIX + ZZH_SEQCAN)

ZZF->(dbSeek(cChvZZF))
cEvento 	:= ZZF->ZZF_EVENTO

cHtml += "<html>
cHtml += '<head>'
cHtml += '<title></title>'
cHtml += '<style type="text/css">'
cHtml += '.FormTitulo {'
cHtml += '	text-align: center;'
cHtml += '	font-family: Arial, Helvetica, sans-serif;'
cHtml += '	font-size: 16pt;'
cHtml += '	color: #FFFFFF;'
cHtml += '	background-color: #626262'
cHtml += '}'
cHtml += '.HeaderItens {'
cHtml += '	font-family: Arial, Helvetica, sans-serif;'
cHtml += '	font-size: x-small;'
cHtml += '	background-color: #E5E5E1;'
cHtml += '}'
cHtml += '.HeaderItensNumber {'
cHtml += '	font-family: Arial, Helvetica, sans-serif;'
cHtml += '	font-size: x-small;'
cHtml += '	background-color: #E5E5E1;'
cHtml += '	text-align: left;'
cHtml += '}'
cHtml += '.DetailItens {'
cHtml += '	font-family: Arial, Helvetica, sans-serif;'
cHtml += '	font-size: x-small;'
cHtml += '	background-color: #FFFFFF;'
cHtml += '	text-align: left;'
cHtml += '}'
cHtml += '.DetailItensNumber {'
cHtml += '	font-family: Arial, Helvetica, sans-serif;'
cHtml += '	font-size: x-small;'
cHtml += '	background-color: #FFFFFF;'
cHtml += '	text-align: right;'
cHtml += '}'
cHtml += '.FormHeader {'
cHtml += '	font-size: x-small;'
cHtml += '	font-family: Arial, Helvetica, sans-serif;'
cHtml += '	background-color: #D6D6D6;'
cHtml += '}'
cHtml += '.NFDetail {'
cHtml += '	font-size: x-small;'
cHtml += '	font-family: Arial, Helvetica, sans-serif;'
cHtml += '	text-align: left;'
cHtml += '	background-color: #D6D6D6;'
cHtml += '}'
cHtml += '.FormDetail {'
cHtml += '	margin-top: 5px;'
cHtml += '	margin-bottom: 5px;'
cHtml += '	font-size: x-small;'
cHtml += '	color: #000000;'
cHtml += '	font-family: Arial, Helvetica, sans-serif;'
cHtml += '}'
cHtml += '.Destaque {'
cHtml += '	font-size: small;'
cHtml += '	font-family: Arial, Helvetica, sans-serif;'
cHtml += '	color: #000080;'
cHtml += '}'
cHtml += '</style>'
cHtml += '</head>'
cHtml += ''
cHtml += '<body>'
cHtml += '<table border="0" width="100%"><tr>'
cHtml += '	<td style="font-size: 6pt; color: #D6D6D6; height: 38; width: 11%;"><img src=' + cLinkLogo + '</td>'
cHtml += '	<td width="92%" style="font-size: 6pt; color: #D6D6D6; height: 38px;" class="FormTitulo"><align="center"<font face="Arial" size="1" color="#FFFFFF">'
cHtml += '	<align="center"<font face="Arial" size="1" color="#FFFFFF"><p align="right" style="margin-top: 0; margin-bottom: 0">&nbsp;<align="center"<font face="Arial" size="1" color="#FFFFFF"><div class="FormTitulo"><strong>Relatório de Conferência de Faturas</strong></div>'
cHtml += '	<align="center"<font face="Arial" size="1" color="#FFFFFF">'
cHtml += '	<p align="right" style="margin-top: 0; margin-bottom: 0"></td>'
cHtml += '</tr></table>'
cHtml += '	<p class="FormDetail"></p>'
cHtml += '	<p class="FormDetail">'
cHtml += '	<font size="4"><font size="2" face="Arial" class="FormDetail">Filial: <strong>' + SM0->M0_FILIAL + '</strong></font></font></p>'
cHtml += '	<p class="FormDetail"></p>'
cHtml += '	<table style="width: 100%">'
cHtml += '		<tr>'
cHtml += '			<td class="FormHeader" style="width: 175px">Número Despesa</td>'
cHtml += '			<td class="FormHeader" style="width: 135px">Fatura</td>'
cHtml += '			<td class="FormHeader" style="width: 91px">Prefixo</td>'
cHtml += '			<td class="FormHeader" style="width: 360px">Evento</td>'
cHtml += '			<td class="FormHeader">Emissão</td>'
cHtml += '		</tr>'
cHtml += '		<tr>'
cHtml += '			<td class="Destaque" style="height: 21px; width: 175px"><strong>' + SC7->C7_NUM + '</strong></td>'
cHtml += '			<td class="FormDetail" style="height: 21px; width: 135px"><strong>' + SC7->C7_XGKOFAT + '</strong></td>'
cHtml += '			<td class="FormDetail" style="height: 21px; width: 91px;"><strong>' + SC7->C7_XGKOPRE + '</strong></td>'
cHtml += '			<td class="FormDetail" style="height: 21px; width: 360px;"><strong>' + cEvento + '</strong></td>'
cHtml += '			<td class="FormDetail" style="height: 21px"><strong>' + dTOc(SC7->C7_EMISSAO) + '</strong></td>'
cHtml += '		</tr>'
cHtml += '	</table>'
cHtml += '	<table style="width: 100%">'
cHtml += '		<tr>'
cHtml += '			<td class="FormHeader" style="width: 169px">Forma de Pagamento</td>'
cHtml += '			<td class="FormHeader" style="width: 213px">Vencimento</td>'
cHtml += '		</tr>'
cHtml += '		<tr>'
cHtml += '			<td class="FormDetail" style="height: 21px; width: 169px"><strong>'+ cFormPag + '</strong></td>'
cHtml += '			<td class="FormDetail" style="height: 21px; width: 213px"><strong>'+ cVencto + '</strong></td>'
cHtml += '		</tr>'
cHtml += '	</table>'
cHtml += '	<table style="width: 100%">'
cHtml += '		<tr>'
cHtml += '			<td class="FormHeader" style="width: 495px">Transportadora</td>'
cHtml += '			<td class="FormHeader" style="width: 213px">CNPJ</td>'
cHtml += '		</tr>'
cHtml += '		<tr>'
cHtml += '			<td class="FormDetail" style="height: 21px; width: 495px"><strong>' + cFornecedor + '</strong></td>'
cHtml += '			<td class="FormDetail" style="height: 21px; width: 213px"><strong>' + cCNPJ + '</strong></td>'
cHtml += '		</tr>'
cHtml += '		</table>'
cHtml += '		<br>'
//cHtml += '	<font size="4">'
//cHtml += '	<font size="2">'
cHtml += '	<table style="width: 100%">'
cHtml += '		<tr>'
cHtml += '			<td class="HeaderItens" style="width: 12.5%; height: 19px;">Conhecimento</td>'
cHtml += '			<td class="HeaderItens" style="width: 12.5%; height: 19px;">Emissão</td>'
cHtml += '			<td class="HeaderItens" style="width: 12.5%; height: 19px;">Vlr. Total Nota Fiscal</td>'
cHtml += '			<td class="HeaderItens" style="width: 12.5%; height: 19px;">Vlr. Cobrado Frete</td>'
cHtml += '			<td class="HeaderItens" style="width: 12.5%; height: 19px;">Indice Realizado</td>'
cHtml += '			<td class="HeaderItens" style="width: 12.5%; height: 19px;">Vlr. Previsto Frete</td>'
cHtml += '			<td class="HeaderItens" style="width: 12.5%; height: 19px;">Indice Previsto</td>'
cHtml += '			<td class="HeaderItens" style="width: 12.5%; height: 19px;">Vlr. Diferença</td>'
cHtml += '		</tr>'
cHtml += '	</table>'

do while ZZF->(!Eof() .and. ZZF_FILIAL+ZZF_CNPJTR+ZZF_FATURA+ZZF_PREFIXO+ZZF_SEQCAN == cChvZZF)
	
	cNCF			:= ZZF->ZZF_NCF
	cNCFSer			:= ZZF->ZZF_NCFSER
	dNCFEmis		:= ZZF->ZZF_NCFEMIS
	nFreteReal		:= ZZF->ZZF_NCFVRE
	nFretePrev		:= ZZF->ZZF_NCFVPR
	cStrNotas		:= ""
	nSomaNF			:= 0

	do while ZZF->(!Eof() .and. ZZF_FILIAL+ZZF_CNPJTR+ZZF_FATURA+ZZF_PREFIXO+ZZF_SEQCAN+ZZF_NCF+ZZF_NCFSER == cChvZZF+cNCF+cNCFSer)
		cStrNotas		+= AllTrim(ZZF->ZZF_NFBR) + "/" + AllTrim(ZZF->ZZF_SERBR) + ", "	//" de " + dTOc(ZZF->ZZF_EMISBR) +
		nSomaNF			+= ZZF->ZZF_VALBR
		ZZF->(dbSkip())
	enddo

	nTotFretReal	+= nFreteReal
	nTotFretPrev	+= nFretePrev
	nTotSomaNF		+= nSomaNF

	nIndReal		:= (nFreteReal / nSomaNF) * 100
	nIndPrev		:= (nFretePrev / nSomaNF) * 100
	nDifer			:= nFreteReal - nFretePrev

	cHtml += '	<table style="width: 100%">'
	cHtml += '		<tr>'
	cHtml += '			<td class="DetailItens" style="width: 12.5%">' + cNCF + '</td>'
	cHtml += '			<td class="DetailItens" style="width: 12.5%">' + dTOc(dNCFEmis) + '</td>'
	cHtml += '			<td class="DetailItensNumber" style="width: 12.5%">' + Transf(nSomaNF, "@E 999,999,999.99") + '</td>'
	cHtml += '			<td class="DetailItensNumber" style="width: 12.5%">' + Transf(nFreteReal, "@E 999,999,999.99") + '</td>'
	cHtml += '			<td class="DetailItensNumber" style="width: 12.5%">' + Transf(nIndReal, "@E 999.99 %") + '</td>'
	cHtml += '			<td class="DetailItensNumber" style="width: 12.5%">' + Transf(nFretePrev, "@E 999,999,999.99") + '</td>'
	cHtml += '			<td class="DetailItensNumber" style="width: 12.5%">' + Transf(nIndPrev, "@E 999.99 %") + '</td>'
	cHtml += '			<td class="DetailItensNumber" style="width: 12.5%">' + Transf(nDifer, "@E 999,999,999.99") + '</td>'
	cHtml += '		</tr>'
	cHtml += '	</table>'

	cHtml += '	<table style="width: 100%">'
	cHtml += '		<tr>'
	cHtml += '			<td class="NFDetail"><strong>Nota(s) Fiscal(is) Brasitech atendida(s): ' + cStrNotas + '</strong></td>'
	cHtml += '		</tr>'
	cHtml += '	</table>'
	cHtml += '	<br>'

enddo

nDifer		:= nTotFretReal	- nTotFretPrev
nIndReal	:= (nTotFretReal / nTotSomaNF) * 100
nIndPrev	:= (nTotFretPrev / nTotSomaNF) * 100

//cHtml += '    </font>'
cHtml += '	<br>'
cHtml += '	<font size="2">'
cHtml += '	<table style="width: 100%">'
cHtml += '		<tr>'
cHtml += '			<td class="DetailItens" style="width: 12.5%"></td>'
cHtml += '			<td class="DetailItens" style="width: 12.5%">Total Geral</td>'
cHtml += '			<td class="DetailItensNumber" style="width: 12.5%">' + Transf(nTotSomaNF, "@E 999,999,999.99") + '</td>'
cHtml += '			<td class="DetailItensNumber" style="width: 12.5%">' + Transf(nTotFretReal, "@E 999,999,999.99") + '</td>'
cHtml += '			<td class="DetailItensNumber" style="width: 12.5%">' + Transf(nIndReal, "@E 999,999.99 %") + '</td>'
cHtml += '			<td class="DetailItensNumber" style="width: 12.5%">' + Transf(nTotFretPrev, "@E 999,999,999.99") + '</td>'
cHtml += '			<td class="DetailItensNumber" style="width: 12.5%">' + Transf(nIndPrev, "@E 999,999.99 %") + '</td>'
cHtml += '			<td class="DetailItensNumber" style="width: 12.5%">' + Transf(nDifer, "@E 999,999,999.99") + '</td>'
cHtml += '		</tr>'
cHtml += '	</table>'
//cHtml += '  </font>'
cHtml += '	</body>'
cHtml += '</html>'

MemoWrite(cArqDest, cHtml)

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		MNT04Barras                                                  /@
@type			User function                                                /@
@date			21/02/2022                                                   /@
@description	Permite o ajuste do código de barras nos títulos gerados pela
				integração do documento de entrada da fatura.                /@
@author			Adalberto Moreno Batista (Opção Um Consultoria)              /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MNT04Barras()
Local nValFat	:= ZZH->(ZZH_VALOR-ZZH_DESCON)
Local cCodBar	:= ZZH->ZZH_CODBAR
Local dVencOri	:= dVencto := ZZH->ZZH_VENCTO
Local oCodBar, oDlg

if ZZH->ZZH_STATUS $ "0.1.2"

	Define MsDialog oDlg Title OemtoAnsi("Codigo de barras e data de vencimento") From 355,330 To 625,1060 Pixel

	// Cria Group do tela
	@ 005,009 TO 090,355 Pixel Of oDlg

	// Cria Componentes do Group
	@ 015,016 Say "Valor da fatura" Size 70,10 COLOR CLR_BLACK Pixel Of oDlg
	@ 025,016 MsGet oCodBar Var nValFat Picture "@E 999,999,999.99" When .F. Size 70,11 COLOR CLR_BLACK Pixel Of oDlg

	@ 015,246 Say "Vencimento" Size 70,10 COLOR CLR_BLACK Pixel Of oDlg
	@ 025,246 MsGet oCodBar Var dVencOri When .F. Size 70,11 COLOR CLR_BLACK Pixel Of oDlg

	@ 055,016 Say "Código de barras" Size 70,10 COLOR CLR_BLUE Pixel Of oDlg
	@ 065,016 MsGet oCodBar Var cCodBar Valid MNT04VldCodBar(cCodBar, nValFat, @dVencto) Size 170,11 COLOR CLR_BLACK Pixel Of oDlg

	@ 055,246 Say "Novo Vencimento" Size 70,10 COLOR CLR_BLUE Pixel Of oDlg
	@ 065,246 MsGet oCodBar Var dVencto When .F. Size 70,11 COLOR CLR_BLACK Pixel Of oDlg

	@ 105,243 Button OemtoAnsi("Gravar") Size 47,15 Pixel Of oDlg Action(oDlg:End(), MNT04GrvNewBarra(cCodBar, dVencto))
	@ 105,305 Button OemtoAnsi("Cancelar") Size 47,15 Pixel Of oDlg Action(oDlg:End())

	Activate MsDialog oDlg Centered

else
	Help(,, "ATENÇÃO",, "Fatura pendente de integração ou Fatura em aprovação (PC) ou Fatura integrada NF entrada." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)

endif

Return(.T.)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		MNT04VldCodBar                                               /@
@type			Static Function                                              /@
@date			21/02/2022                                                   /@
@description	Grava novo codigo de barras nos registros do processo        /@
@author			Adalberto Moreno Batista (Opção Um Consultoria)              /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function MNT04VldCodBar(cCodBar, nValFat, dVencto)
Local lRet			:= .T.
Local nVlCodBar		:= 0
Local dDtVctoBar	:= cTOd("")

if !Empty(cCodBar)
	if  VldCodBar(cCodBar)
		if Len(AllTrim(cCodBar)) == 44					//codigo de barras lido pelo leitor
			nVlCodBar	:= Val(Substr(cCodBar, 10, 10)) / 100
			dDtVctoBar	:= cTOd("07/10/97") + Val(Substr(cCodBar, 06, 04))
		elseif Len(AllTrim(cCodBar)) == 47	//linha digitavel para boletos registrados
			nVlCodBar	:= Val(Substr(cCodBar, 38, 10)) / 100
			dDtVctoBar 	:= cTOd("07/10/97") + Val(Substr(cCodBar, 34, 04))
		endif

		if nVlCodBar != nValFat
			lRet	:= .F.
			Help(,, "ATENÇÃO",, "O valor do código de barras é diferente do valor apresentado na fatura." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
		elseif dDtVctoBar < Date()
			lRet	:= .F.
			Help(,, "ATENÇÃO",, "O vencimento do código de barras (" + dTOc(dDtVctoBar) + ") é menor que a data atual e não poderá ser usado." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
		else
			dVencto := dDtVctoBar
		endif

	endif
endif

Return(lRet)

/*/
———————————————————————————————————————————————————————————————————————————————
@function		MNT04GrvNewBarra                                             /@
@type			Static Function                                              /@
@date			21/02/2022                                                   /@
@description	Grava novo codigo de barras nos registros do processo        /@
@author			Adalberto Moreno Batista (Opção Um Consultoria)              /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function MNT04GrvNewBarra(cCodBar, dVencto)
Local cLog			:= ZZH->ZZH_LOG
Local lContinua		:= .T.

if ZZH->ZZH_STATUS == "2"

	SC7->(dbSetOrder(1))	//C7_FILIAL, C7_NUM, C7_ITEM, C7_SEQUEN
	SF1->(dbSetOrder(1))	//F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO
	SE2->(dbSetOrder(6))	//E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO
	
	lContinua		:= .F.
	
	if SC7->(dbSeek(xFilial("SC7") + ZZH->ZZH_PEDCOM))
		if SF1->(dbSeek(xFilial("SF1") + SC7->(C7_XGKOFAT + C7_XGKOPRE + C7_FORNECE + C7_LOJA)))
			if SE2->(dbSeek(xFilial("SE2") + SF1->(F1_FORNECE + F1_LOJA + F1_PREFIXO + F1_DOC)))
				do while SE2->(!eof() .and. E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM == xFilial("SE2") + SF1->(F1_FORNECE + F1_LOJA + F1_PREFIXO + F1_DOC))

					if SE2->E2_TIPO == "NF " .and. Empty(SE2->E2_BAIXA)
						lContinua := .T.
						SE2->(RecLock("SE2", .F.))
						SE2->E2_VENCTO	:= dVencto
						SE2->E2_VENCREA	:= DataValida(dVencto, .T.)
						SE2->E2_LINDIG	:= iif(Len(AllTrim(cCodBar))==44, FinCbLd(cCodBar), cCodBar)
						SE2->E2_CODBAR	:= iif(Len(AllTrim(cCodBar))==44, cCodBar, FinLdCb(cCodBar))
						SE2->(MsUnLock())
					endif

					SE2->(dbSkip())
				enddo

				if !lContinua
					Help(,, "ATENÇÃO",, "Não encontrado o titulo (" + AllTrim(SC7->C7_XGKOPRE) + "/" + AllTrim(SC7->C7_XGKOFAT) + " para o fornecedor " + SC7->C7_FORNECE + "/" + SC7->C7_LOJA + " ou título encontra-se baixado." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
				endif

			else
				Help(,, "ATENÇÃO",, "Não encontrado o titulo (" + AllTrim(SC7->C7_XGKOPRE) + "/" + AllTrim(SC7->C7_XGKOFAT) + " para o fornecedor " + SC7->C7_FORNECE + "/" + SC7->C7_LOJA + ". Informe o departamente de TI." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
			endif

		else
			Help(,, "ATENÇÃO",, "Não encontrado o documento de entrada (" + AllTrim(SC7->C7_XGKOFAT) + "/" + AllTrim(SC7->C7_XGKOPRE) + " para o fornecedor " + SC7->C7_FORNECE + "/" + SC7->C7_LOJA + ". Informe o departamente de TI." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
		endif

	else
		Help(,, "ATENÇÃO",, "Não encontrado o pedido de compra (" + ZZH->ZZH_PEDCOM + "). Informe o departamente de TI." + chr(13) + chr(10) + AllTrim(SM0->M0_NOME), 1)
	endif

endif

if lContinua
	cLog	:= ZZH->ZZH_LOG	+ "Alterado codigo de barras e vencimento da fatura em " + dTOc(Date()) + " as " + Time() + ", por " + cUserName + Chr(13) + Chr(10) + Repl("=",62) + Chr(13) + Chr(10)
	ZZH->(RecLock("ZZH", .F.))
	ZZH->ZZH_CODBAR	:= cCodBar
	ZZH->ZZH_VENCTO	:= dVencto
	ZZH->ZZH_LOG	:= cLog
	ZZH->(MsUnLock())
endif

Return()
