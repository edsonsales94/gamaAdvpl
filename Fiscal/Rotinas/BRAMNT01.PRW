#include "rwmake.ch"
#include "protheus.ch" 
#include "tbiconn.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		BRAMNT01                                                     /@
@type			User function                                                /@
@date			26/05/2019                                                   /@
@description	Manutenção e integração de XML Infracommerce em notas de 
				entrada ou saída, atraves de rotina do fiscal. 
				Inclusão de titulos a pagar ou receber e movimentação de 
				estoque                                                      /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Tecnologia                                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
———————————————————————————————————————————————————————————————————————————————
MsAdvSize(ExpL1,ExpL2,ExpN1)
———————————————————————————————————————————————————————————————————————————————
Parametros
——————————
ExpL1 -> Enchoicebar .T. ou .F.
ExpL2 -> Retorna janela padrao siga .T. ou .F.
ExpN1 -> Tamanho minimo ( altura )

Retorno
———————
ExpA1 -> Dimensoes da janela e area de trabalho
         1 -> Linha inicial area trabalho
         2 -> Coluna inicial area trabalho
         3 -> Linha final area trabalho
         4 -> Coluna final area trabalho
         5 -> Coluna final dialog
         6 -> Linha final dialog
         7 -> Linha inicial dialog
———————————————————————————————————————————————————————————————————————————————
———————————————————————————————————————————————————————————————————————————————
MsObjSize(ExpA1,ExpA2,lExp1,lExp2)
———————————————————————————————————————————————————————————————————————————————
Parametros
——————————
ExpA2 -> Area de trabalho
ExpA3 -> Definicoes de objetos 1-Tamanho X
                               2-Tamanho Y
                               3-Dimensiona X
                               4-Dimensiona Y
                               5-Retorna dimensoes X e Y ao inves de linha / coluna final
ExpL2 -> Indica calculo de objetos horizontais
ExpL1 -> Mantem a proporcao dos objetos

Retorno
———————
ExpA1 -> Array com as posicoes de cada objeto
         1 -> Linha inicial
         2 -> Coluna inicial
         3 -> Linha final
         4 -> Coluna final Ou caso seja passado o elemento 5 de cada
              definicao de objetos como .T. o retorno sera: 3 -> Tamanho da dimensao X
                                                            4 -> Tamanho da dimensao Y
———————————————————————————————————————————————————————————————————————————————
———————————————————————————————————————————————————————————————————————————————
MsObjGetPos(ExpN1,ExpN2,ExpA1)
———————————————————————————————————————————————————————————————————————————————
Parametros
----------
nSizeAtu -> Linha final area trabalho menos Linha inicial area trabalho
nSizeDef -> Tamanho do espaço definido para distribuição
aPosDef --> Colunas que serão apresentadas em tela o SAY e GET

Retorno
-------
Vetor com as colunas que serão apresentado o SAY e o GET
———————————————————————————————————————————————————————————————————————————————
/*/
User Function BRAMNT01()
//Local aArea 		:= GetArea()
Local aCores		:= {	{"ZZ7_TPNF == '0' .and. ZZ7_STATUS == '0'",	"F12_VERD"},;
							{"ZZ7_TPNF == '0' .and. ZZ7_STATUS == '1'",	"F12_VERM"},;
							{"ZZ7_TPNF == '0' .and. ZZ7_STATUS == '2'",	"F12_PRET"},;
							{"ZZ7_TPNF == '0' .and. ZZ7_STATUS == '3'",	"F12_LARA"},;
							{"ZZ7_TPNF == '1' .and. ZZ7_STATUS == '0'",	"F5_VERD"},;
							{"ZZ7_TPNF == '1' .and. ZZ7_STATUS == '1'",	"F5_VERM"},;
							{"ZZ7_TPNF == '1' .and. ZZ7_STATUS == '2'",	"F5_PRET"},;
							{"ZZ7_TPNF == '1' .and. ZZ7_STATUS == '3'",	"F5_LARA"},;
							{"ZZ7_STATUS == '4'",	"BR_CANCEL"}}
Local lEstNeg		:= GetMV("MV_ESTNEG") //== "S"
Local cTMNFS		:= GetMV("BR_TMNFS",.F.,"")
Local cLocInfra		:= GetMV("BR_LOCINFR",.F.,"")
Local lContinua		:= .T.
Private cCadastro	:= "Gerenciamento de XML´s integração com Infracommerce"
Private aRotina   	:= {	{"Pesquisa",	"AxPesqui",												0, 1},;
							{"Visualiza",	"U_MNT01XML",											0, 2},;
							{"Altera",		"U_MNT01XML",											0, 4},;
							{"Exclui",		"U_MNT01XML",											0, 5},;
							{"Integra",		"Processa({|| U_MNT01Integra(.T.)}, 'Integrando XML')",	0, 6},;
							{"Exporta XML",	"U_MNT01Exp",											0, 6},;
							{"Consulta Log","U_MNT01Log",											0, 6},;
							{"Legenda",		"U_MNT01Legenda",										0, 7}}
Private aSize		:= MsAdvSize()
Private aObjects	:= {	{100, 100, .T., .T.},;
							{100, 100, .T., .T.},;
							{100, 015, .T., .F.}}
Private aInfo		:= {aSize[1], aSize[2], aSize[3], aSize[4], 3, 3}
Private aPosObj		:= MsObjSize(aInfo, aObjects)
//Private aPosGet	:= MsObjGetPos((aSize[3] - aSize[1]), 315, {{004, 024, 240, 270}})

if lEstNeg = "N"
	lContinua := .F.
	MsgBox("O parâmetro MV_ESTNEG deve ser configurado para permitir estoque negativo." + chr(13) + chr(10) + "(Específico Brasitech)", "ATENÇÃO", "INFO")
endif

if Empty(cTMNFS)
	lContinua := .F.
	MsgBox("Necessário configurar o parametro BR_TMNFS para indicar o código de movimentação de requisição para a criação automática das baixas de estoque na geração da NFS." + chr(13) + chr(10) + "(Específico Brasitech)", "ATENÇÃO", "INFO")
endif

if Empty(cLocInfra)
	lContinua := .F.
	MsgBox("Necessário configurar o parametro BR_LOCINFR para indicar o código do local padrão para a criação automática das baixas de estoque na geração da NFS." + chr(13) + chr(10) + "(Específico Brasitech)", "ATENÇÃO", "INFO")
endif

if lContinua

	dbSelectArea("ZZ7")
	dbSetOrder(1)
	dbSeek(xFilial("ZZ7"))
	mBrowse(,,,, "ZZ7",,,,,, aCores)

endif

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		MNT01Legenda                                                 /@
@type			User function                                                /@
@date			26/05/2019                                                   /@
@description	Exibe a legenda na XML´s importados                          /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MNT01Legenda()
Local aLegenda := {	{"F12_VERM", 	"NF Entrada - Integrada"},;					//folder azul		1=Integrado
					{"F12_VERD", 	"NF Entrada - Pendente"},;					//folder azul		0=Pendente
					{"F12_PRET", 	"NF Entrada - Inconsistência"},;			//folder azul		2=Erro integração
					{"F12_LARA", 	"NF Entrada - Duplicada"},;					//folder azul		3=Duplicada
					{"F5_VERM", 	"NF Saída - Integrada"},;					//folder amarelo	1=Integrado
					{"F5_VERD", 	"NF Saída - Pendente"},;					//folder amarelo	0=Pendente
					{"F5_PRET", 	"NF Saída - Inconsitência"},;				//folder amarelo	2=Erro integração
					{"F5_LARA", 	"NF Saída - Duplicada"},;					//folder amarelo	3=duplicada
					{"BR_CANCEL", 	"NF cancelada ou número inutilizado"}}		//                  4=cancelada

BrwLegenda(cCadastro, OemToAnsi("Legendas"), aLegenda)

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		MNT01XML                                                     /@
@type			User function                                                /@
@date			26/05/2019                                                   /@
@description	Exibe a legenda na XML´s importados                          /@
@author			Adalberto Moreno Batista (Opção Um Consultoria)              /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MNT01XML(cAlias, nRecNo, nOpc)
//Local aArea			:= GetArea()
Local bCampo		:= {|nField| FieldName(nField) }
Local nUsado		:= 0
Local nCols			:= 0
Local aAltera		:= {}
Local nX, oDlg, oMainWnd, oGet, nOpcA, nPosMPPROD, nPosMPTES, nPosNFORI, nPosSERORI, nPosITORI, lItemOk
Private aHeader		:= {}
Private aCols		:= {}

//———————————————————————————————————————————————————————————————————————————————
// Permito a alteracao somente se a XML não tiver sido integrado
//———————————————————————————————————————————————————————————————————————————————
if ZZ7->ZZ7_STATUS == "1" .and. (nOpc == 3 .or. nOpc == 4)
	Help(,, "ATENÇÃO",, "O XML não poderá ser alterado ou excluído, pois já foi integrado." + chr(13) + chr(10) + "(Específico Brasitech)", 1)
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
if SX3->(dbSeek("ZZ8"))
	do while SX3->(!eof() .and. X3_ARQUIVO == "ZZ8")
		if X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL .and. !AllTrim(SX3->X3_CAMPO) $ "ZZ8_IDNF#"
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
dbSelectArea("ZZ8")
ZZ8->(dbSetOrder(1))
ZZ8->(dbSeek(xFilial("ZZ8") + ZZ7->ZZ7_IDNF))
do while ZZ8->(!eof() .and. ZZ8_FILIAL == xFilial("ZZ8") .and. ZZ8_IDNF == ZZ7->ZZ7_IDNF)
	aAdd(aCols, Array(nUsado + 1))
	nCols++
	
	for nX := 1 To nUsado
		if aHeader[nX,10] != "V"
			aCols[nCols][nX] := ZZ8->(FieldGet(FieldPos(aHeader[nX,2])))
		else
			aCols[nCols][nX] := ZZ8->(CriaVar(aHeader[nX,2], .T.))
		endif
	next
	
	aCols[nCols, nUsado + 1] := .F.

	aAdd(aAltera, ZZ8->(RecNo()))
	
	ZZ8->(dbSkip())
enddo

nPosMPPROD	:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ8_MPPROD"})
nPosMPTES  	:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ8_MPTES"})
nPosNFORI  	:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ8_NFORI"})
nPosSERORI  := aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ8_SERORI"})
nPosITORI  	:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ8_ITORI"})

//———————————————————————————————————————————————————————————————————————————————
// Envia para processamento dos Gets
//———————————————————————————————————————————————————————————————————————————————
Define MsDialog oDlg Title OemToAnsi(cCadastro) From aSize[7], aSize[1] to aSize[6], aSize[5] Of oMainWnd Pixel
EnChoice(cAlias, nRecNo, nOpc,,,,, aPosObj[1],, 3)
oGet := MSGetdados():New(aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4], nOpc, "U_MNT01LinOk",,, iif(nOpc==3, .T., .F.))
//Activate MsDialog oDlg On Init EnchoiceBar(oDlg, {|| nOpcA:=1, oDlg:End()}, {||nOpcA := 0, oDlg:End()})
Activate MsDialog oDlg On Init EnchoiceBar(oDlg, {|| nOpcA:=1, iif(U_MNT01AllOk(), oDlg:End(), nOpcA:=0)}, {||nOpcA := 0, oDlg:End()})

if nOpcA == 1 .and. (nOpc == 3 .or. nOpc == 4)

	Begin TransaCtion

		if nOpc == 3
		
			lItemOk := .T.
			for nX := 1 to Len(aAltera)
				if Empty(aCols[nX, nPosMPPROD]) .or. Empty(aCols[nX, nPosMPTES])
					lItemOk := .F.
				endif
				ZZ8->(dbGoTo(aAltera[nX]))
				ZZ8->(RecLock("ZZ8", .F.))
				ZZ8->ZZ8_MPPROD		:= aCols[nX, nPosMPPROD]
				ZZ8->ZZ8_MPTES		:= aCols[nX, nPosMPTES]
				ZZ8->ZZ8_NFORI		:= aCols[nX, nPosNFORI]
				ZZ8->ZZ8_SERORI		:= aCols[nX, nPosSERORI]
				ZZ8->ZZ8_ITORI		:= aCols[nX, nPosITORI]
				ZZ8->(MsUnLock())
			next

			ZZ7->(RecLock("ZZ7", .F.))
			ZZ7->ZZ7_TPDEST	:= M->ZZ7_TPDEST
			ZZ7->ZZ7_CLIENT	:= M->ZZ7_CLIENT
			ZZ7->ZZ7_LOJCLI	:= M->ZZ7_LOJCLI
			ZZ7->ZZ7_FORNEC	:= M->ZZ7_FORNEC
			ZZ7->ZZ7_LOJFOR	:= M->ZZ7_LOJFOR
			if ((M->ZZ7_TPDEST == "C" .and. !empty(M->ZZ7_CLIENT + M->ZZ7_LOJCLI)) .or.;
				(M->ZZ7_TPDEST == "F" .and. !empty(M->ZZ7_FORNEC + M->ZZ7_LOJFOR))) .and. lItemOk
				ZZ7->ZZ7_STATUS	:= "0"
			endif
			ZZ7->(MsUnLock())
			
		elseif nOpc == 4	
		
			ZZ7->(RecLock("ZZ7", .F.))
			ZZ7->(dbDelete())
			ZZ7->(MsUnLock())

			for nX := 1 to Len(aAltera)
				ZZ8->(dbGoTo(aAltera[nX]))
				ZZ8->(RecLock("ZZ8", .F.))
				ZZ8->(dbDelete())
				ZZ8->(MsUnLock())
			next
		
		endif

	End Transaction

endif

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		MNT01LinOk                                                   /@
@type			User function                                                /@
@date			24/06/2019                                                   /@
@description	Valida digitação da nota origem                              /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MNT01LinOk()
Local lRet			:= .T.
Local nPosMPProd	:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ8_MPPROD"})
Local nPosNFOri		:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ8_NFORI"})
Local nPosSerOri	:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ8_SERORI"})
Local nPosItemOri	:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ8_ITORI"})
Local cMsg			:= "Número da NF ou série origem não encontrada na base de notas de saída ou cliente, loja, produto ou item original não pertence à nota original."
Local cItemOri

SD2->(dbSetOrder(3))		//D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM
if ZZ7->ZZ7_FINNFE == "4"		//Nota de devolucao

	lRet := .F.

	if ReadVar() == "M->ZZ8_ITORI"
		cItemOri := M->ZZ8_ITORI
	else
		cItemOri := AllTrim(aCols[n,nPosItemOri])
	endif
	
	if SD2->(dbSeek(xFilial("SD2") + aCols[n,nPosNFOri] + aCols[n,nPosSerOri] + ZZ7->ZZ7_CLIENT + ZZ7->ZZ7_LOJCLI + aCols[n,nPosMPProd]))
		do while SD2->(!eof() .and.;
						D2_FILIAL == xFilial("SD2") .and.;
						D2_DOC == aCols[n,nPosNFOri] .and.;
						D2_SERIE == aCols[n,nPosSerOri] .and.;
						D2_CLIENTE == ZZ7->ZZ7_CLIENT .and.;
						D2_LOJA == ZZ7->ZZ7_LOJCLI .and.;
						D2_COD == aCols[n,nPosMPProd])
							
			if AllTrim(SD2->D2_ITEM) == cItemOri
				//verificar 
				lRet := .T.
				Exit
			endif
			SD2->(dbSkip())
		enddo
		
	endif
	
	if !lRet
		if !IsBlind()
			Help(,, "ATENÇÃO",,  cMsg + chr(13) + chr(10) + "(Específico Brasitech)", 1)
		else
			ConOut("ATENÇÃO - " + cMsg + " NF " + ZZ7->ZZ7_NNF)
		endif
	endif

endif

Return(lRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		MNT01AllOk                                                   /@
@type			User function                                                /@
@date			26/05/2019                                                   /@
@description	Exibe a legenda na XML´s importados                          /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MNT01AllOk()
Local lRet 			:= .T.
Local lDevolucao	:= (ZZ7->ZZ7_FINNFE == "4")
Local nPosMPProd	:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ8_MPPROD"})
Local nPosMPTES		:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ8_MPTES"})
Local nPosNFOri		:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ8_NFORI"})
Local nPosSerOri	:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ8_SERORI"})
Local nPosItemOri	:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ8_ITORI"})
Local nX

if ALTERA

	SB1->(dbSetOrder(1))
	SF4->(dbSetOrder(1))
	ZZ8->(dbSetOrder(1))
	
	For nX:=1 to Len(aCols)
	
		lRet := U_MNT01LinOk()
		
		if lRet
		
			if (Empty(aCols[nX, nPosMPProd]) .or. SB1->(!dbSeek(xFilial("SB1") + aCols[nX, nPosMPProd])) .or. SB1->B1_MSBLQL == '1')
				lRet := .F.
				Help(,, "ATENÇÃO",, "Para integrar, é necessário informar o produto Protheus e ele não poderá estar bloqueado." + chr(13) + chr(10) + "(Específico Brasitech)", 1)
				
			elseif (Empty(aCols[nX, nPosMPTES]) .or. SF4->(!dbSeek(xFilial("SF4") + aCols[nX, nPosMPTES])) .or. SF4->F4_MSBLQL == '1')
				lRet := .F.
				Help(,, "ATENÇÃO",, "Para integrar, é necessário informar o TES e ele não poderá estar bloqueado." + chr(13) + chr(10) + "(Específico Brasitech)", 1)
		
			elseif lDevolucao .and. (Empty(aCols[nX, nPosNFOri]) .or. Empty(aCols[nX, nPosSerOri]) .or. Empty(aCols[nX, nPosItemOri]))
				lRet := .F.
				Help(,, "ATENÇÃO",, "Para notas de devolução é necessário informar a NOTA, SERIE e ITEM da nota origem" + chr(13) + chr(10) + "(Específico Brasitech)", 1)
		
			endif
			
		endif
		
		if !lRet
			Exit
		endif
	
	Next

endif

Return(lRet)

/*/
———————————————————————————————————————————————————————————————————————————————
@function		MNT01Integra                                                 /@
@type			User function                                                /@
@date			26/05/2019                                                   /@
@description	Integra a nota                                               /@
@author			Adalberto Moreno Batista (Opção Um Consultoria)              /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MNT01Integra(lManual)
Local lCadCliFor	:= .T.
Private cFormul		:= "S"
Default lManual		:= .T.

//———————————————————————————————————————————————————————————————————————————————
// Verifico se o CNPJ emitente é o mesmo da filial posicionada
//———————————————————————————————————————————————————————————————————————————————
if ZZ7->ZZ7_IDEMIT == SM0->M0_CGC		// .OR. EMPTY(SM0->M0_CGC)

	//———————————————————————————————————————————————————————————————————————————————
	// Verifico se o a nota ainda não foi integrada
	//———————————————————————————————————————————————————————————————————————————————
	if ZZ7->ZZ7_STATUS == "0"

		//———————————————————————————————————————————————————————————————————————————————
		// Caso nao possua cliente ou fornecedor, tento incluir antes da integração
		//———————————————————————————————————————————————————————————————————————————————
		if ZZ7->ZZ7_TPDEST == "C" .and. (Empty(ZZ7->ZZ7_CLIENT) .or. Empty(ZZ7->ZZ7_LOJCLI))
		
			lCadCliFor := U_MNT01CliCad(	{	ZZ7->ZZ7_IDORDE,;
												ZZ7->ZZ7_XNOME,;
												ZZ7->ZZ7_CMUN,;
												ZZ7->ZZ7_UF,;
												ZZ7->ZZ7_XLGR,;
												ZZ7->ZZ7_NRO,;
												ZZ7->ZZ7_IE,;
												ZZ7->ZZ7_XCPL,;
												ZZ7->ZZ7_XBAIRR,;
												ZZ7->ZZ7_CEP,;
												ZZ7->ZZ7_FONE,;
												ZZ7->ZZ7_EMAIL	},;
												ZZ7->ZZ7_IDNF)
			
			if lCadCliFor
				ZZ7->(RecLock("ZZ7", .F.))
				ZZ7->ZZ7_CLIENT		:= SA1->A1_COD
				ZZ7->ZZ7_LOJCLI		:= SA1->A1_LOJA
				ZZ7->(MsUnLock())
			endif

		elseif ZZ7->ZZ7_TPDEST == "F" .and. (Empty(ZZ7->ZZ7_FORNEC) .or. Empty(ZZ7->ZZ7_LOJFOR))
		
			lCadCliFor := MNT01ForCad(	{	ZZ7->ZZ7_IDORDE,;
											ZZ7->ZZ7_XNOME,;
											ZZ7->ZZ7_CMUN,;
											ZZ7->ZZ7_UF,;
											ZZ7->ZZ7_XLGR,;
											ZZ7->ZZ7_NRO,;
											ZZ7->ZZ7_IE,;
											ZZ7->ZZ7_XCPL,;
											ZZ7->ZZ7_XBAIRR,;
											ZZ7->ZZ7_CEP,;
											ZZ7->ZZ7_FONE,;
											ZZ7->ZZ7_EMAIL	},;
											ZZ7->ZZ7_IDNF)
			
			if lCadCliFor
				ZZ7->(RecLock("ZZ7", .F.))
				ZZ7->ZZ7_FORNECE	:= SA2->A2_COD
				ZZ7->ZZ7_LOJFOR		:= SA2->A2_LOJA
				ZZ7->(MsUnLock())
			endif

		endif

		//———————————————————————————————————————————————————————————————————————————————
		// Continuo, quando houver retorno positivo para o cadastramento/alteração do
		// cadastro de cliente ou fornecedor
		//———————————————————————————————————————————————————————————————————————————————
		if lCadCliFor

			//———————————————————————————————————————————————————————————————————————————————
			// Continuo, quando a verificação dos itens retornar OK
			//———————————————————————————————————————————————————————————————————————————————
			if MNT01VerItens()
			
				//———————————————————————————————————————————————————————————————————————————————
				// Integro NF saida
				//———————————————————————————————————————————————————————————————————————————————
				if ZZ7->ZZ7_TPNF == "1"
					SF2->(dbSetOrder(1))		//F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, F2_TIPO
					if SF2->(!dbSeek(xFilial("SF2") + ZZ7->ZZ7_NNF + ZZ7->ZZ7_SERIE + ZZ7->ZZ7_CLIENT + ZZ7->ZZ7_LOJCLI))
						U_MNT01NFSaida()
					else
						ZZ7->(RecLock("ZZ7", .F.))
						ZZ7->ZZ7_STATUS	:= "3"
						ZZ7->(MsUnLock())
						Help(,, "ATENÇÃO",, "Dados não poderão ser integrados, pois Nota, série, cliente e loja já cadastrados na base fiscal." + chr(13) + chr(10) + "(Específico Brasitech)", 1)
					endif

				//———————————————————————————————————————————————————————————————————————————————
				// Integro NF entrada
				//———————————————————————————————————————————————————————————————————————————————
				elseif ZZ7->ZZ7_TPNF == "0"
					SF1->(dbSetOrder(1))		//F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO
					if SF1->(!dbSeek(xFilial("SF1") + ZZ7->ZZ7_NNF + ZZ7->ZZ7_SERIE + ZZ7->ZZ7_FORNEC + ZZ7->ZZ7_LOJFOR))
						U_MNT01NFEntrada()
					else
						ZZ7->(RecLock("ZZ7", .F.))
						ZZ7->ZZ7_STATUS	:= "3"
						ZZ7->(MsUnLock())
						Help(,, "ATENÇÃO",, "Dados não poderão ser integrados, pois Nota, série, fornecedor e loja já cadastrados na base fiscal." + chr(13) + chr(10) + "(Específico Brasitech)", 1)
					endif

				endif
			
			else
			
				Help(,, "ATENÇÃO",, "Foram encontradas inconsistências nos itens da nota fiscal. Produto ou TES não encontrado/bloqueado ou sem referencia da origem em caso de devolução. Verifique o log da operação." + chr(13) + chr(10) + "(Específico Brasitech)", 1)
				U_GrvLogIC("Análise de itens", ZZ7->ZZ7_IDNF, "Produto, TES ou NF Origem", "Foram encontradas inconsistências nos itens da nota fiscal. Produto ou TES não encontrado/bloqueado ou sem referencia da origem em caso de devolução.")

			endif

		else

			U_GrvLogIC("Atualização cadastral", ZZ7->ZZ7_IDNF, "Cliente ou Fornecedor", "Problema na atualização cadastral.")
					
		endif
	
	elseif ZZ7->ZZ7_STATUS $ "1/3/4"
	   
		Help(,, "ATENÇÃO",, "XML já integrado." + chr(13) + chr(10) + "(Específico Brasitech)", 1)

	elseif ZZ7->ZZ7_STATUS == "2"

		Help(,, "ATENÇÃO",, "Registro com problemas. Verificar as informações incorretas antes de integrar." + chr(13) + chr(10) + "(Específico Brasitech)", 1)

	endif

else

	if lManual
		Help(,, "ATENÇÃO",, "Filial posicionada não corresponde ao CNPJ emitente da nota. Posicione na filial correta" + chr(13) + chr(10) + "(Específico Brasitech)", 1)
	else
		U_GrvLogIC("CNPJ Emissor", ZZ7->ZZ7_IDNF, "CNPJ Emissor", "Filial posicionada não corresponde ao CNPJ emitente da nota")
	endif
	
endif

//———————————————————————————————————————————————————————————————————————————————
// Para integrações manuais, faço o tratamento de log
//———————————————————————————————————————————————————————————————————————————————
if lManual
	U_CommitLog(ZZ7->ZZ7_IDNF)
endif

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		MNT01CliCad                                                  /@
@type			User function                                                /@
@date			16/06/2019                                                   /@
@description	Inclui cadastro de cliente, a partir dos dados do XML da NF  
					aDados := {	ZZ7->ZZ7_IDORDE,;
								ZZ7->ZZ7_XNOME,;
								ZZ7->ZZ7_CMUN,;
								ZZ7->ZZ7_UF,;
								ZZ7->ZZ7_XLGR,;
								ZZ7->ZZ7_NRO,;
								ZZ7->ZZ7_IE,;
								ZZ7->ZZ7_XCPL,;
								ZZ7->ZZ7_XBAIRR,;
								ZZ7->ZZ7_CEP}                                /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MNT01CliCad(aDados, cIdNF)
Local lRet			:= .T.
Local cTabela		:= GetMV("BR_X_TPRLJ", .F., "109")
Local cPessoa		:= iif(Len(AllTrim(aDados[1])) > 11, "J", "F")
Local cEnder		:= ""
Local lObrFilled	:= .T.
Local aSA1			:= {}
Local cIE, cCodMun	//, cEnder

//———————————————————————————————————————————————————————————————————————————————
// Setar a ordem das tabelas
//———————————————————————————————————————————————————————————————————————————————
SA1->(dbSetOrder(3))
lSA1Exist := .F.
if SA1->(dbSeek(xFilial("SA1") + aDados[1]))		//ZZ7_IDORDE
	lSA1Exist	:= .T.
	cCod 			:= SA1->A1_COD
	cLoja			:= SA1->A1_LOJA
endif

SA1->(dbSetOrder(1))
CC2->(dbSetOrder(1))
//SX3->(dbSetOrder(2))

//———————————————————————————————————————————————————————————————————————————————
// Validando se os campos obrigatórios foram preenchidos
//———————————————————————————————————————————————————————————————————————————————
if Empty(aDados[1])		//ZZ7_IDORDE
	lObrFilled	:= .F.
	cMensObr		+= "CNPJ ou CPF, "
endif

if Empty(aDados[2])		//ZZ7_XNOME
	lObrFilled	:= .F.
	cMensObr		+= "Nome, "
endif

if lObrFilled

	//———————————————————————————————————————————————————————————————————————————————
	// Pesquisa o codigo do municipio
	//———————————————————————————————————————————————————————————————————————————————
	cCodMun := Substr(aDados[3],3,5)		//ZZ7_CMUN
	if CC2->(dbSeek(xFilial("CC2") + aDados[4] + cCodMun))	//ZZ7_UF

		if !Empty(AllTrim(aDados[5]) + AllTrim(aDados[6]))		//ZZ7_XLGR, ZZ7_NRO
			cEnder := AllTrim(aDados[5]) + ", " + AllTrim(aDados[6])
		endif
		cIE	:= iif(Empty(aDados[7]), "ISENTO", aDados[7])

		//———————————————————————————————————————————————————————————————————————————————
		// Array para o cadastro de clientes
		//———————————————————————————————————————————————————————————————————————————————
		if lSA1Exist
			SA1->(dbSeek(xFilial("SA1") + cCod + cLoja))
			//conout(SA1->A1_COD + "/" + SA1->A1_LOJA + " - " +SA1->A1_NOME)
			
			if AllTrim(SA1->A1_END) == cEnder .and.;
				AllTrim(SA1->A1_COMPLEM) == AllTrim(aDados[8]) .and.;
				AllTrim(SA1->A1_EST) == aDados[4] .and.;
				AllTrim(SA1->A1_COD_MUN) == AllTrim(Substr(aDados[3],3,5)) .and.;
				AllTrim(SA1->A1_BAIRRO) == AllTrim(aDados[9]) .and.;
				AllTrim(SA1->A1_CEP) == AllTrim(aDados[10])

				lEnviaEml := .F.
				
			endif		
		
			aAdd(aSA1, {"A1_COD",			SA1->A1_COD,					Nil})
			aAdd(aSA1, {"A1_LOJA",			SA1->A1_LOJA,					Nil})
			
		else

			aAdd(aSA1, {"A1_TIPO",			"F",							Nil})
			aAdd(aSA1, {"A1_CGC",			aDados[1],						Nil})		//ZZ7_IDORDE
			aAdd(aSA1, {"A1_PAIS",			"105",							Nil})
			aAdd(aSA1, {"A1_CONTA",			"1120101008",					Nil})		//1120101008 = Contas a Receber INFRACOMMERCE
			aAdd(aSA1, {"A1_CODPAIS",		"01058",						Nil})
			aAdd(aSA1, {"A1_POSTO",			"2",							Nil})
			aAdd(aSA1, {"A1_NATUREZ",		"30100101  ",					Nil})
			aAdd(aSA1, {"A1_X_AGEND",		"N",							Nil})
			aAdd(aSA1, {"A1_X_MDVPC",		"C",							Nil})
			aAdd(aSA1, {"A1_XCADCLI",		"1",							Nil})
			aAdd(aSA1, {"A1_CONTRIB",		"2",							Nil})

		endif

		aAdd(aSA1, {"A1_NOME",			Upper(aDados[2]),				Nil})		//ZZ7_XNOME
		aAdd(aSA1, {"A1_NREDUZ",		Upper(aDados[2]),				Nil})		//ZZ7_XNOME
		aAdd(aSA1, {"A1_END", 			Upper(cEnder),					Nil})
		aAdd(aSA1, {"A1_COMPLEM",		Upper(aDados[8]),				Nil})		//ZZ7_XCPL
		aAdd(aSA1, {"A1_EST",			Upper(aDados[4]),				Nil})		//ZZ7_UF
		aAdd(aSA1, {"A1_COD_MUN",		Substr(aDados[3],3,5),			Nil})		//ZZ7_CMUN
		aAdd(aSA1, {"A1_BAIRRO",		Upper(aDados[9]),				Nil})		//ZZ7_BAIRR
		aAdd(aSA1, {"A1_CEP",			aDados[10],						Nil})		//ZZ7_CEP
		aAdd(aSA1, {"A1_INSCR",			cIE,							Nil})
		aAdd(aSA1, {"A1_DDD",			Left(aDados[11],2),				Nil})		//ZZ7_FONE
		aAdd(aSA1, {"A1_TEL",			Substr(aDados[11],3),			Nil})		//ZZ7_FONE
		aAdd(aSA1, {"A1_EMAIL",			aDados[12],						Nil})		//ZZ7_EMAIL
		aAdd(aSA1, {"A1_CONTATO",		Upper(aDados[2]),				Nil})		//ZZ7_XNOME
		aAdd(aSA1, {"A1_PESSOA",		cPessoa,						Nil})	
		aAdd(aSA1, {"A1_TABELA",		cTabela,			  			Nil})
		aAdd(aSA1, {"A1_XTABPAD",		cTabela,						Nil})
		aAdd(aSA1, {"A1_VEND",			"15488 ",						Nil})
		aAdd(aSA1, {"A1_XVENALT",		"15488 ",						Nil})
		aAdd(aSA1, {"A1_SATIV1",		"4400",							Nil})
		aAdd(aSA1, {"A1_XMCANAL",		"CONSUMIDOR FINAL",				Nil})
		aAdd(aSA1, {"A1_REGIAO",		"993",							Nil})
		aAdd(aSA1, {"A1_TPFRET",		"C",							Nil})
		
		//———————————————————————————————————————————————————————————————————————————————
		// Msexecauto para o cadastro de clientes
		//———————————————————————————————————————————————————————————————————————————————
		lMsErroAuto := .F.
		MSExecAuto({|x, y| MATA030(x, y)}, aSA1, iif(lSA1Exist, 4, 3))			//3- Inclusão, 4- Alteração, 5- Exclusão
			
		if lMsErroAuto
			if !lSA1Exist
				lRet := .F.
			endif
			DisarmTransaction()
			U_GrvLogIC("ExecAuto MATA030", cIdNF, aDados[1], "Cliente não pôde ser integrado. " + iif(lRet, "Processo será concluído, porém sem atualização do cadastro do cliente", "Processo não será concluído"), NomeAutoLog())
			
		else

			U_GrvLogIC("ExecAuto MATA030", cIdNF, aDados[1], "Cliente " + iif(lSA1Exist, "ALTERADO", "INCLUIDO") + " com SUCESSO com o Código " + SA1->A1_COD + " Loja " + SA1->A1_LOJA)

		endif
	
	else

		lRet := .F.
		U_GrvLogIC("ExecAuto MATA030", cIdNF, aDados[4] + "-" + cCodMun, "Cliente não integrado, pois não foi possível encontrar o código IBGE no cadastro de municípios. [" + aDados[1] + "].")

	endif
	
else

	lRet	:= .F.
	U_GrvLogIC("ExecAuto MATA030", cIdNF, aDados[1], "Um ou mais campos obrigatórios, não foram enviados pela integração. Cliente não pôde ser integrado.")

endif

SA1->(dbSetOrder(1))

Return(lRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		MNT01ForCad                                                  /@
@type			User function                                                /@
@date			27/06/2019                                                   /@
@description	Inclui fornecedor, a partir dos dados do XML da NF  
				aDados := {	ZZ7->ZZ7_IDORDE,;
							ZZ7->ZZ7_XNOME,;
							ZZ7->ZZ7_CMUN,;
							ZZ7->ZZ7_UF,;
							ZZ7->ZZ7_XLGR,;
							ZZ7->ZZ7_NRO,;
							ZZ7->ZZ7_IE,;
							ZZ7->ZZ7_XCPL,;
							ZZ7->ZZ7_XBAIRR,;
							ZZ7->ZZ7_CEP}                                    /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MNT01ForCad(aDados, cIdNF)
Local lRet			:= .T.
Local cTipo			:= iif(Len(AllTrim(aDados[1])) > 11, "J", "F")
Local cEnder		:= ""
Local lObrFilled	:= .T.
Local aSA2			:= {}
Local cIE, cCodMun, cLojaBase, cLoja		//, cEnder

//———————————————————————————————————————————————————————————————————————————————
// Definindo codigo e loja do fornecedor
//———————————————————————————————————————————————————————————————————————————————
SA2->(dbSetOrder(3))
lSA2Exist := .F.
if SA2->(dbSeek(xFilial("SA2") + aDados[1]))		//ZZ7_IDORDE

	lSA2Exist	:= .T.
	cCod 			:= SA2->A1_COD
	cLoja			:= SA2->A1_LOJA
	
else

	cCod		:= Left(aDados[1], 8)
	if Val(Substr(aDados[1], 9, 4)) < 100 .and. !SA2->(dbSeek(xFilial("SA2") + cCod + Substr(aDados[1], 11, 2)))
		cLoja	:= Substr(aDados[1], 11, 2)
	else
		cLojaBase := "A1"
		do while SA2->(dbSeek(xFilial("SA2") + cCod + cLojaBase))
			cLojaBase := Soma1(cLojaBase)
		enddo
		cLoja	:= cLojaBase
	endif

endif

//———————————————————————————————————————————————————————————————————————————————
// Setar a ordem das tabelas
//———————————————————————————————————————————————————————————————————————————————
SA2->(dbSetOrder(1))
CC2->(dbSetOrder(1))

//———————————————————————————————————————————————————————————————————————————————
// Validando se os campos obrigatórios foram preenchidos
//———————————————————————————————————————————————————————————————————————————————
if Empty(aDados[1])		//ZZ7_IDORDE
	lObrFilled	:= .F.
	cMensObr		+= "CNPJ ou CPF, "
endif

if Empty(aDados[2])		//ZZ7_XNOME
	lObrFilled	:= .F.
	cMensObr		+= "Nome, "
endif

if lObrFilled

	//———————————————————————————————————————————————————————————————————————————————
	// Pesquisa o codigo do municipio
	//———————————————————————————————————————————————————————————————————————————————
	cCodMun := Substr(aDados[3],3,5)		//ZZ7_CMUN
	if CC2->(dbSeek(xFilial("CC2") + aDados[4] + cCodMun))	//ZZ7_UF

		if !Empty(AllTrim(aDados[5]) + AllTrim(aDados[6]))		//ZZ7_XLGR, ZZ7_NRO
			cEnder := AllTrim(aDados[5]) + ", " + AllTrim(aDados[6])
		endif
		cIE	:= iif(Empty(aDados[7]), "ISENTO", aDados[7])

		//———————————————————————————————————————————————————————————————————————————————
		// Array para o cadastro de clientes
		//———————————————————————————————————————————————————————————————————————————————
		if lSA2Exist
			SA2->(dbSeek(xFilial("SA2") + cCod + cLoja))
			
			if AllTrim(SA2->A2_END) == cEnder .and.;
				AllTrim(SA2->A2_COMPLEM) == AllTrim(aDados[8]) .and.;
				AllTrim(SA2->A2_EST) == aDados[4] .and.;
				AllTrim(SA2->A2_COD_MUN) == AllTrim(Substr(aDados[3],3,5)) .and.;
				AllTrim(SA2->A2_BAIRRO) == AllTrim(aDados[9]) .and.;
				AllTrim(SA2->A2_CEP) == AllTrim(aDados[10])

				lEnviaEml := .F.
				
			endif		
		
			aAdd(aSA1, {"A2_COD",			SA2->A2_COD,					Nil})
			aAdd(aSA1, {"A2_LOJA",			SA2->A2_LOJA,					Nil})
			
		else

			aAdd(aSA2, {"A2_CGC",			aDados[1],						Nil})		//ZZ7_IDORDE
			aAdd(aSA2, {"A2_COND",			"010",							Nil})
			aAdd(aSA2, {"A2_POSTO",			"1",							Nil})
			aAdd(aSA2, {"A2_NATUREZ",		"40200471",						Nil})
			aAdd(aSA2, {"A2_X_FGTO",		"4",							Nil})
			aAdd(aSA2, {"A2_CONTA",			"2110201003",					Nil})

		endif

		aAdd(aSA2, {"A2_TIPO", 			cTipo,							Nil})
		aAdd(aSA2, {"A2_NOME",			Upper(aDados[2]),				Nil})		//ZZ7_XNOME
		aAdd(aSA2, {"A2_NREDUZ",		Upper(aDados[2]),				Nil})		//ZZ7_XNOME
		aAdd(aSA2, {"A2_INSCR",			cIE,							Nil})
		aAdd(aSA2, {"A2_END", 			Upper(cEnder),					Nil})
		aAdd(aSA2, {"A2_COMPLEM",		Upper(aDados[8]),				Nil})		//ZZ7_XCPL
		aAdd(aSA2, {"A2_EST",			Upper(aDados[4]),				Nil})		//ZZ7_UF
		aAdd(aSA2, {"A2_COD_MUN",		Substr(aDados[3],3,5),			Nil})		//ZZ7_CMUN
		aAdd(aSA2, {"A2_BAIRRO",		Upper(aDados[9]),				Nil})		//ZZ7_BAIRR
		aAdd(aSA2, {"A2_CEP",			aDados[10],						Nil})		//ZZ7_CEP
		aAdd(aSA2, {"A2_DDD",			Left(aDados[11],2),				Nil})		//ZZ7_FONE
		aAdd(aSA2, {"A2_TEL",			Substr(aDados[11],3),			Nil})		//ZZ7_FONE
		aAdd(aSA2, {"A2_EMAIL",			aDados[12],						Nil})		//ZZ7_EMAIL

		//———————————————————————————————————————————————————————————————————————————————
		// Msexecauto para o cadastro de fornecedores
	 	//———————————————————————————————————————————————————————————————————————————————
		lMsErroAuto := .F.
		MSExecAuto({|x, y| MATA020(x, y)}, aSA2, iif(lSA2Exist, 4, 3))			//3- Inclusão, 4- Alteração, 5- Exclusão
			
		if lMsErroAuto
			lRet := .F.
			DisarmTransaction()
			U_GrvLogIC("ExecAuto MATA020", cIdNF, aDados[1], "Fornecedor não pôde ser integrado. " + iif(lRet, "Processo será concluído, porém sem atualização do cadastro do cliente", "Processo não será concluído"), NomeAutoLog())
			
		else

			U_GrvLogIC("ExecAuto MATA020", cIdNF, aDados[1], "Fornecedor " + iif(lSA2Exist, "ALTERADO", "INCLUIDO") + " com SUCESSO com o Código " + SA2->A1_COD + " Loja " + SA2->A1_LOJA)

		endif
	
	else

		lRet := .F.
		U_GrvLogIC("ExecAuto MATA020", cIdNF, aDados[4] + "-" + cCodMun, "Fornecedor não integrado, pois não foi possível encontrar o código IBGE no cadastro de municípios. [" + aDados[1] + "].")

	endif
	
else

	lRet	:= .F.
	U_GrvLogIC("ExecAuto MATA020", cIdNF, aDados[1], "Um ou mais campos obrigatórios, não foram enviados pela integração. Fornecedor não pôde ser integrado.")

endif

SA2->(dbSetOrder(1))

Return(lRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		MNT01NFSaida                                                 /@
@type			User function                                                /@
@date			17/06/2019                                                   /@
@description	Integra o XML para nota fiscal de saida pela rotina fiscal
				MATA920. Inclui titulos (FINA030) e movimentação de estoque
				MATA241                                                      /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MNT01NFSaida()
Local lRet			:= .T.
Local aCab			:= {}
Local aItens		:= {}
Local aMovEst		:= {}
Local cLocal		:= GetMV("BR_LOCINFR", .F., "01")
Local dBaseBkp		:= dDataBase
Local cTpFrete		:= iif(ZZ7->ZZ7_MODFRE == "0", "C", "F")
Local lMovFin		:= .F.
Local cChave		:= ZZ7->ZZ7_NNF + "-" + ZZ7->ZZ7_SERIE
Local cBkpFuncao	:= FunName()
Local cCliente, cLoja, cTpNF, lAtualiza, cItem
Private lMsErroAuto	:= .F.

if ZZ7->ZZ7_TPDEST == "C"

	cTpNF		:= "N"
	cCliente	:= ZZ7->ZZ7_CLIENT
	cLoja		:= ZZ7->ZZ7_LOJCLI

else

	cTpNF		:= "B"
	cCliente	:= ZZ7->ZZ7_FORNEC
	cLoja		:= ZZ7->ZZ7_LOJFOR

endif

aCab := {	{"F2_TIPO",			cTpNF,						NIL},;
			{"F2_DOC",			ZZ7->ZZ7_NNF,				NIL},;
			{"F2_SERIE",		ZZ7->ZZ7_SERIE,				NIL},;
			{"F2_EMISSAO",		ZZ7->ZZ7_DTEMIS,			NIL},;
			{"F2_CLIENTE",		cCliente,					NIL},;
			{"F2_LOJA",			cLoja,						NIL},;
			{"F2_ESPECIE",		"SPED",						NIL},;
			{"F2_CHVNFE",		Substr(ZZ7->ZZ7_IDNF,4),	NIL},;
			{"F2_TPFRETE",		cTpFrete,					NIL},;
			{"F2_DESCONT",		ZZ7->ZZ7_VDESC,				NIL},;
			{"F2_FRETE",		ZZ7->ZZ7_VFRETE,			NIL},;
			{"F2_DESPESA",		ZZ7->ZZ7_VOUTRO,			NIL},;
			{"F2_SEGURO",		ZZ7->ZZ7_VSEG,				NIL},;
			{"F2_PLIQUI",		ZZ7->ZZ7_PESOL,				NIL},;
			{"F2_PBRUTO",		ZZ7->ZZ7_PESOB,				NIL},;
			{"F2_VOLUME1",		ZZ7->ZZ7_QVOL,	 			NIL},;
			{"F2_ESPECI1",		ZZ7->ZZ7_ESP,				NIL},;
			{"F2_TIPOCLI",		"F",						NIL},;
			{"F2_HORA",			ZZ7->ZZ7_HREMIS,			NIL},;
			{"F2_DAUTNFE",		ZZ7->ZZ7_DTEMIS,			NIL},;
			{"F2_HAUTNFE",		ZZ7->ZZ7_HREMIS,			NIL}}
                    
SB2->(dbSetOrder(1))		//B2_FILIAL, B2_COD, B2_LOCAL
SD2->(dbSetOrder(3))		//D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM
SF2->(dbSetOrder(1))		//F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, F2_TIPO
SF4->(dbSetOrder(1))		//F4_FILIAL, F4_CODIGO
ZZ8->(dbSetOrder(1))
ZZ8->(dbSeek(xFilial("ZZ8") + ZZ7->ZZ7_IDNF))
cItem := "00"
do while ZZ8->(!eof() .and. ZZ8_FILIAL == xFilial("ZZ8") .and. ZZ8_IDNF == ZZ7->ZZ7_IDNF)

	cItem		:= Soma1(cItem)
	cClasFis	:= ZZ8->ZZ8_ORIGEM + ZZ8->ZZ8_CSTICM
	SF4->(dbSeek(xFilial("SF4") + ZZ8->ZZ8_MPTES))
	
	lMovFin		:= iif(SF4->F4_DUPLIC == "S", .T., lMovFin)
	
	dbSelectArea("ZZ8")
	aAdd(aItens,{	{"D2_ITEM", 	cItem,					NIL},;
					{"D2_COD",		ZZ8->ZZ8_MPPROD,		NIL},;
					{"D2_QUANT",	ZZ8->ZZ8_QCOM,			NIL},;
					{"D2_PRCVEN",	ZZ8->ZZ8_VUNCOM, 		NIL},;
					{"D2_TOTAL",	ZZ8->ZZ8_VPROD,			NIL},;
					{"D2_LOCAL",	cLocal,					NIL},;
					{"D2_PRUNIT",	ZZ8->ZZ8_VUNCOM,		NIL},;
					{"D2_TES",		ZZ8->ZZ8_MPTES,			NIL},;
					{"D2_CF",		ZZ8->ZZ8_CFOP,			NIL},;
					{"D2_BASEICM",	ZZ8->ZZ8_VBCICM,		NIL},;
					{"D2_VALICM",	ZZ8->ZZ8_VICMS,			NIL},;
					{"D2_PICM",		ZZ8->ZZ8_PICMS,			NIL},;
					{"D2_BASEIPI",	ZZ8->ZZ8_VBCIPI,		NIL},;
					{"D2_VALIPI",	ZZ8->ZZ8_VIPI,			NIL},;
					{"D2_IPI",		ZZ8->ZZ8_PIPI,			NIL},;
					{"D2_CLASFIS",	cClasFis,				NIL}})
//						{"D2_XDIFAL",	ZZ8->ZZ8_DIFAL,			NIL}})
//						{"D2_PDORI",	0,						NIL},;
//						{"D2_PDDES",	100,					NIL},;
   
	if SF4->F4_ESTOQUE == "S"
		aAdd(aMovEst, {ZZ8->ZZ8_MPPROD, cLocal, ZZ8->ZZ8_QCOM})
	endif
	ZZ8->(dbSkip())

enddo

dDataBase := ZZ7->ZZ7_DTEMIS

Begin Transaction
	lMsErroAuto := .F.
	lAtualiza	:= .F.
	
	//———————————————————————————————————————————————————————————————————————————————
	// Alteração do nome da função, pois a rotina MATA920 chama o ponto de entrada
	// MT100TOK (que é de nota de entrada).
	// Há um tratamento neste ponto de entrada para não acionar funções quando a 
	// chamada for pela função MATA920.
	// Criei também a variável cFormul:="S" no inicio da função MNT01Integra(), que 
	// é a acionadora da MNT01NFSaida()
	//———————————————————————————————————————————————————————————————————————————————
	SetFunName("MATA920")
	MsExecAuto({|x,y,z| MATA920(x,y,z)}, aCab, aItens, 3)
	SetFunName(cBkpFuncao)
	
	if lMsErroAuto
	
		U_GrvLogIC("ExecAuto MATA920", ZZ7->ZZ7_IDNF, cChave, "NF saída não integrada. Erro no MsExecAuto", NomeAutoLog())
		
		ZZ7->(RecLock("ZZ7", .F.))
		ZZ7->ZZ7_STATUS	:= "0"
		ZZ7->(MsUnLock())

	else
       
		lAtualiza := .T.
		
		//———————————————————————————————————————————————————————————————————————————————
		// Movimentação e estoque
		//———————————————————————————————————————————————————————————————————————————————
		if Len(aMovEst) > 0
			lRet := MNT01MovEst(aMovEst)
		endif

		//———————————————————————————————————————————————————————————————————————————————
		// Movimentação financeira
		//———————————————————————————————————————————————————————————————————————————————
		if lMovFin
			//lRet := MNT01MovFin()
		endif

		if lRet
			ZZ7->(RecLock("ZZ7", .F.))
			ZZ7->ZZ7_STATUS	:= "1"
			ZZ7->(MsUnLock())

			U_GrvLogIC("ExecAuto MATA920", ZZ7->ZZ7_IDNF, cChave, "NF saída integrada com SUCESSO")

		else

			U_GrvLogIC("Problema Processo", ZZ7->ZZ7_IDNF, cChave, "Ocorreu um problema no processo de integração.")
			DisarmTransaction()
			Break

		endif
			
	endif

End Transaction

//———————————————————————————————————————————————————————————————————————————————
// Atualizando campos não gravados pela MATA920, mas utilizados em processos do
// BI. Executado fora do controle de transação
//———————————————————————————————————————————————————————————————————————————————
if lAtualiza

	SB2->(dbSetOrder(1))		//B2_FILIAL, B2_COD, B2_LOCAL
	SD2->(dbSetOrder(3))		//D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM
	SF2->(dbSetOrder(1))		//F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, F2_TIPO
	SF4->(dbSetOrder(1))		//F4_FILIAL, F4_CODIGO

   if SF2->(dbSeek(xFilial("SF2") + ZZ7->ZZ7_NNF + ZZ7->ZZ7_SERIE + cCliente + cLoja))

		SF2->(RecLock("SF2", .F.))
		SF2->F2_COND	:= "999"
		SF2->(MsUnLock())
	
		SD2->(dbSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA))
		do while SD2->(!eof() .and. D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA == xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA)

			if SB2->(dbSeek(xFilial("SB2") + SD2->D2_COD + SD2->D2_LOCAL)) .and.;
				SF4->(dbSeek(xFilial("SF4") + SD2->D2_TES)) .and.;
				SF4->F4_ESTOQUE == "S"

				SD2->(RecLock("SD2", .F.))
				SD2->D2_CUSTO1	:= (SB2->B2_CM1 * SD2->D2_QUANT)
				SD2->(MsUnLock())
				
			endif

			SD2->(dbSkip())

		enddo
		
	endif

endif

dDataBase := dBaseBkp
Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		MNT01NFEntrada                                               /@
@type			User function                                                /@
@date			27/06/2019                                                   /@
@description	Integra o XML para nota fiscal de entrada pela rotina compras
				MATA103, com isto os titulos e movimentações de estoque são
				realizadas integralmente.                                    /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MNT01NFEntrada()
Local lRet		:= .T.
Local aCab		:= {}
Local aItens	:= {}
Local cLocal	:= "01"
Local dBaseBkp	:= dDataBase
//Local cTpFrete	:= iif(ZZ7->ZZ7_MODFRE == "0", "C", "F")
Local cChave	:= ZZ7->ZZ7_NNF + "-" + ZZ7->ZZ7_SERIE
Local cFornece, cLoja, cTpNF
Private lMsErroAuto	:= .F.
//Private lGAMANFE		:= .F.

SA1->(dbSetOrder(1))		//A1_FILIAL, A1_COD, A1_LOJA
SA2->(dbSetOrder(1))		//A2_FILIAL, A2_COD, A2_LOJA
SB1->(dbSetOrder(1))		//B1_FILIAL, B1_COD
SF1->(dbSetOrder(1))		//F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO
SD1->(dbSetOrder(1))		//D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM
SF4->(dbSetOrder(1))		//F4_FILIAL, F4_CODIGO

if ZZ7->ZZ7_TPDEST == "F"

	cTpNF		:= "N"
	cFornece	:= ZZ7->ZZ7_FORNEC
	cLoja		:= ZZ7->ZZ7_LOJFOR

else

	cTpNF		:= "D"
	cFornece	:= ZZ7->ZZ7_CLIENT
	cLoja		:= ZZ7->ZZ7_LOJCLI

endif

dbSelectArea("SF1")

aCab := {	{"F1_TIPO",			cTpNF,						Nil},;
			{"F1_FORMUL",		"S",			 			Nil},;
			{"F1_DOC",			ZZ7->ZZ7_NNF,	 			Nil},;
			{"F1_SERIE",		ZZ7->ZZ7_SERIE,				Nil},;
			{"F1_EMISSAO",		ZZ7->ZZ7_DTEMIS,			Nil},;
			{"F1_FORNECE",		cFornece,  					Nil},;
			{"F1_LOJA",			cLoja,	 					Nil},;
			{"F1_ESPECIE",		"SPED",						Nil}}
//	{"F1_CHVNFE",	Substr(ZZ7->ZZ7_IDNF,4),	Nil}}

SF4->(dbSetOrder(1))
ZZ8->(dbSetOrder(1))
ZZ8->(dbSeek(xFilial("ZZ8") + ZZ7->ZZ7_IDNF))
do while ZZ8->(!eof() .and. ZZ8_FILIAL == xFilial("ZZ8") .and. ZZ8_IDNF == ZZ7->ZZ7_IDNF)
	cClasFis := ZZ8->ZZ8_ORIGEM + ZZ8->ZZ8_CSTICM
	SF4->(dbSeek(xFilial("SF4") + ZZ8->ZZ8_MPTES))
	
	dbSelectArea("ZZ8")
		
	aAdd(aItens,{	{"D1_ITEM", 	ZZ8->ZZ8_ITEM,	  		Nil},;
					{"D1_COD",		ZZ8->ZZ8_MPPROD,		Nil},;
					{"D1_TES",		ZZ8->ZZ8_MPTES,			Nil},;
					{"D1_QUANT",	ZZ8->ZZ8_QCOM,			Nil},;
					{"D1_LOCAL",	cLocal,					Nil},;
					{"D1_NFORI",	ZZ8->ZZ8_NFORI, 		Nil},;
					{"D1_SERIORI",	ZZ8->ZZ8_SERORI, 		Nil},;
					{"D1_ITEMORI",	ZZ8->ZZ8_ITORI, 		Nil},;
					{"D1_VUNIT",	ZZ8->ZZ8_VUNCOM, 		Nil},;
					{"D1_TOTAL",	ZZ8->ZZ8_VPROD,			Nil},;
					{"D1_CF",		ZZ8->ZZ8_CFOP,			Nil},;
					{"D1_BASEICM",	ZZ8->ZZ8_VBCICM,		Nil},;
					{"D1_VALICM",	ZZ8->ZZ8_VICMS,			Nil},;
					{"D1_PICM",		ZZ8->ZZ8_PICMS,			Nil},;
					{"D1_BASEIPI",	ZZ8->ZZ8_VBCIPI,		Nil},;
					{"D1_VALIPI",	ZZ8->ZZ8_VIPI,			Nil},;
					{"D1_IPI",		ZZ8->ZZ8_PIPI,			Nil},;
					{"D1_CLASFIS",	cClasFis,				Nil}})
   
	ZZ8->(dbSkip())
enddo

dDataBase := ZZ7->ZZ7_DTEMIS

//Begin Transaction
	lMsErroAuto := .F.
	dbSelectArea("SF1")
	MsExecAuto({|x, y, z| MATA103(x, y, z)}, aCab, aItens, 3)
	
	if lMsErroAuto
		
		U_GrvLogIC("ExecAuto MATA103", ZZ7->ZZ7_IDNF, cChave, "NF entrada não integrada. Erro no MsExecAuto", NomeAutoLog())
		
		ZZ7->(RecLock("ZZ7", .F.))
		ZZ7->ZZ7_STATUS	:= "0"
		ZZ7->(MsUnLock())

	else
		
		SF1->(RecLock("SF1", .F.))
		SF1->F1_CHVNFE	:= Substr(ZZ7->ZZ7_IDNF,4)
		SF1->(MsUnLock())
		
		ZZ7->(RecLock("ZZ7", .F.))
		ZZ7->ZZ7_STATUS	:= "1"
		ZZ7->(MsUnLock())
		U_GrvLogIC("ExecAuto MATA103", ZZ7->ZZ7_IDNF, cChave, "NF de entrada integrada com SUCESSO")
			
	endif
	
//End Transaction

dDataBase := dBaseBkp

Return(lRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		MNT01VerItens                                                /@
@type			User function                                                /@
@date			21/06/2019                                                   /@
@description	Valida TES digitado, considerando o CFOP, entrada ou saida e
				se não está bloqueado                                        /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function MNT01VerItens()
Local lRet 			:= .T.
Local lDevolucao	:= (ZZ7->ZZ7_FINNFE == "4")

SB1->(dbSetOrder(1))
SF4->(dbSetOrder(1))
ZZ8->(dbSetOrder(1))
ZZ8->(dbSeek(xFilial("ZZ8") + ZZ7->ZZ7_IDNF))
do while ZZ8->(!eof() .and. ZZ8_FILIAL == xFilial("ZZ8") .and. ZZ8_IDNF == ZZ7->ZZ7_IDNF)

	if (Empty(ZZ8->ZZ8_MPPROD) .or. SB1->(!dbSeek(xFilial("SB1") + ZZ8->ZZ8_MPPROD)) .or. SB1->B1_MSBLQL == '1') .or.;
		(Empty(ZZ8->ZZ8_MPTES) .or. SF4->(!dbSeek(xFilial("SF4") + ZZ8->ZZ8_MPTES)) .or. SF4->F4_MSBLQL == '1')
		lRet := .F.
	elseif lDevolucao .and. (Empty(ZZ8->ZZ8_NFORI) .or. Empty(ZZ8->ZZ8_SERORI) .or. Empty(ZZ8->ZZ8_ITORI))
		lRet := .F.
	endif
	
	if !lRet
		Exit
	endif
	ZZ8->(dbSkip())
enddo

Return(lRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		MNT01TESOK                                                   /@
@type			User function                                                /@
@date			21/06/2019                                                   /@
@description	Valida TES digitado, considerando o CFOP, entrada ou saida e
				se não está bloqueado                                        /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MNT01TESOK()
Local lRet		:= .T.
Local nPosCFOP	:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ8_CFOP"})
Local cCFOPnf	:= Substr(aCols[n,nPosCFOP],2,3)
Local cTipoTES	:= iif(Left(aCols[n,nPosCFOP],1)<"4","E","S")

SF4->(dbSetOrder(1))
if SF4->(dbSeek(xFilial("SF4") + M->ZZ8_MPTES))
	if SF4->F4_PODER3 != "N"
		lRet := .f.
		Help(,, "ATENÇÃO",, "O TES escolhido não poderá controlar poder DE/EM TERCEIROS. Selecione outro TES" + chr(13) + chr(10) + "(Específico Brasitech)", 1)
	else	
		if Substr(SF4->F4_CF,2,3) == cCFOPnf .and. SF4->F4_MSBLQL<>"1" .and. SF4->F4_TIPO == cTipoTES
		else
			lRet := .f.
			Help(,, "ATENÇÃO",, "O TES escolhido não possui o CFOP informado na nota ou está bloqueado para uso." + chr(13) + chr(10) + "(Específico Brasitech)", 1)	
		endif
	endif
else
	lRet := .f.
	Help(,, "ATENÇÃO",, "TES não encontrado." + chr(13) + chr(10) + "(Específico Brasitech)", 1)	
endif

Return(lRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		FilTESMNT01                                                  /@
@type			User function                                                /@
@date			24/06/2019                                                   /@
@description	Filtra TES por CFOP na consulta padrão                       /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function FilTESMNT01()
Local nPosCFOP	:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ8_CFOP"})
Local cCFOPnf	:= Substr(aCols[n,nPosCFOP],2,3)
Local cTipoTES	:= iif(Left(aCols[n,nPosCFOP],1)<"4", "E", "S")
Local lRet		:= (Substr(SF4->F4_CF,2,3) == cCFOPnf .and. SF4->F4_MSBLQL<>"1" .and. SF4->F4_TIPO == cTipoTES)
Return(lRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		FilItMNT01                                                   /@
@type			User function                                                /@
@date			05/08/2019                                                   /@
@description	Filtra itens origem para TES para NF devolução               /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function FilItMNT01()
Local nPosDOC		:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ8_NFORI"})
Local nPosSERIE		:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ8_SERORI"})
Local nPosCOD		:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ8_MPPROD"})
Local cRet			:= xFilial("SD2") + aCols[n,nPosDOC] + aCols[n,nPosSERIE] + M->ZZ7_CLIENT + M->ZZ7_LOJCLI + aCols[n,nPosCOD]
Return(cRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		MNT01MovEst                                                  /@
@type			User function                                                /@
@date			24/06/2019                                                   /@
@description	Movimenta Estoque                                            /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function MNT01MovEst(aMovEst)
Local lRet		:= .T.
Local cTM		:= GetMV("BR_TMNFS", .F., "502")
Local aCab		:= {}
Local aItem		:= {}
Local cChave	:= ZZ7->ZZ7_NNF + "/" + ZZ7->ZZ7_SERIE
Local nX, aVetor
Private lMsErroAuto

//———————————————————————————————————————————————————————————————————————————————
// Verificando se produto possui registro de saldo incial (SB2)/(SB9)
//———————————————————————————————————————————————————————————————————————————————
SB2->(dbSetOrder(1))		//B2_FILIAL, B2_COD, B2_LOCAL
For nX:=1 to Len(aMovEst)
	if SB2->(!dbSeek(xFilial("SB2") + aMovEst[nX,1] + aMovEst[nX,2]))
		aVetor :=	{;
						{"B9_FILIAL", xFilial("SB9"),	Nil},;
						{"B9_COD",    aMovEst[nX,1],		Nil},;
						{"B9_LOCAL",  aMovEst[nX,2],		Nil};
					}
		lMsErroAuto := .F.
		MSExecAuto({|x, y| MATA220(x, y)}, aVetor, 3)
  
 		//Se houve erro, mostra mensagem
		If lMsErroAuto
			lRet := .F.
			U_GrvLogIC("ExecAuto MATA220", ZZ7->ZZ7_IDNF, cChave, "O saldo inicial de estoque não pôde ser gravado. Erro no MsExecAuto", NomeAutoLog())
		EndIf
	endif
Next

//———————————————————————————————————————————————————————————————————————————————
// Criando o movimento interno
//———————————————————————————————————————————————————————————————————————————————
if lRet

	aCab	:= {	{"D3_DOC",		ZZ7->ZZ7_NNF, 		NIL},;
					{"D3_TM",		cTM,		 	 	NIL},;
					{"D3_EMISSAO",	ZZ7->ZZ7_DTEMIS,	NIL}}
	
	For nX:=1 to Len(aMovEst)
		aAdd(aItem, {	{"D3_COD",			aMovEst[nX,1],		NIL},;
						{"D3_LOCAL",		aMovEst[nX,2],		NIL},;
						{"D3_QUANT",		aMovEst[nX,3],		NIL},;
						{"D3_XCHVNFE",		ZZ7->ZZ7_IDNF,		NIL}})
	Next
	
	lMsErroAuto := .F.
	MSExecAuto({|x,y,z| MATA241(x,y,z)}, aCab, aItem, 3)
	
	if lMsErroAuto
		lRet := .F.
		U_GrvLogIC("ExecAuto MATA241", ZZ7->ZZ7_IDNF, cChave, "Movimento de estoque não pôde ser gravado. Erro no MsExecAuto", NomeAutoLog())
	else
		U_GrvLogIC("ExecAuto MATA241", ZZ7->ZZ7_IDNF, ZZ7->ZZ7_NNF, "Movimento interno gravado com SUCESSO.")
	endif
	
endif

Return(lRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		MNT01Log                                                     /@
@type			User function                                                /@
@date			24/06/2019                                                   /@
@description	Consulta o log de operações referente ao registro ZZ7        /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MNT01Log()
Local cTexto := ZZ7->ZZ7_LOG

Define Font oFont Name "Mono AS" Size 6,14

Define MsDialog oDlg Title "Log de operações notas InfraCommerce" From 3, 0 to 530, 650 Pixel

@ 5, 5 Get oMemo Var cTexto Memo Size 320, 225 Of oDlg Pixel
oMemo:bRClicked := { || AllwaysTrue() }
oMemo:oFont     := oFont

Define SButton From 240, 240+20 Type 1 Action oDlg:End() Enable Of oDlg Pixel

Activate MsDialog oDlg Center

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		MNT01Exp                                                     /@
@type			User function                                                /@
@date			20/07/2020                                                   /@
@description	Exporta Arquivos XML                                         /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MNT01Exp()
Local cPerg		    := PadR("BRMNT01EXP", Len(SX1->X1_GRUPO))
Local aRegs    	    := {}
Local aCabSX1		:= {"X1_GRUPO", "X1_ORDEM", "X1_PERGUNT", "X1_VARIAVL", "X1_TIPO", "X1_TAMANHO", "X1_DECIMAL", "X1_GSC", "X1_VAR01"}
Local aSay			:= {}
Local aButton		:= {}
Local nOpc			:= 0
Local cCadastro		:= "Exportação de XML - Processo Infracommerce"
Local aArea			:= GetArea()

//parametros para o processamento
aAdd(aRegs, {cPerg,"01", "Diretório de destino     ", "mv_ch1", "C", 40, 0, "G", "mv_par01"})
aAdd(aRegs, {cPerg,"02", "Da Série da nota fiscal  ", "mv_ch2", "C", 03, 0, "G", "mv_par02"})
aAdd(aRegs, {cPerg,"03", "Da número da Nota Fiscal ", "mv_ch3", "C", 09, 0, "G", "mv_par03"})
aAdd(aRegs, {cPerg,"04", "Até a Nota Fiscal        ", "mv_ch4", "C", 09, 0, "G", "mv_par04"})
aAdd(aRegs, {cPerg,"05", "Da data de Emissão       ", "mv_ch5", "D", 08, 0, "G", "mv_par05"})
aAdd(aRegs, {cPerg,"06", "Até a data de Emissão    ", "mv_ch6", "D", 08, 0, "G", "mv_par06"})
aAdd(aRegs, {cPerg,"07", "Do CNPJ/CPF              ", "mv_ch7", "C", 14, 0, "G", "mv_par07"})
aAdd(aRegs, {cPerg,"08", "Até o CNPJ/CPF           ", "mv_ch8", "C", 14, 0, "G", "mv_par08"})

U_BRASX1(aRegs, aCabSX1)

Pergunte(cPerg, .F.)

//———————————————————————————————————————————————————————————————————————————————
// Criacao da Interface
//———————————————————————————————————————————————————————————————————————————————
aAdd(aSay, "Geração de arquivos XML com filtros pré-estabelecidos.")
aAdd(aSay, "Informar o drive e caminho para a gravação dos arquivos e ranges de filtros.")

aAdd(aButton, {1, .T., {|| nOpc := 1,	FechaBatch()	}})
aAdd(aButton, {2, .T., {|| FechaBatch()					}})
aAdd(aButton, {5, .T., {|| Pergunte(cPerg, .T.)		    }})

FormBatch(cCadastro, aSay, aButton)

If nOpc == 1

	ProcRegua(2) // Numero de processos/sub-processos

	IncProc("Exportando XML´s para o diretório destino...")		//1o.

	Processa({|lEnd| ExportXML()} , "Processo Infracommerce" , "Exportando XML´s para o diretório destino..." , .T. )

	IncProc("Finalizando processo...")	//2o.
	
Endif   

//———————————————————————————————————————————————————————————————————————————————
// Restaura a posicao original das areas de trabalho
//———————————————————————————————————————————————————————————————————————————————
RestArea(aArea)
Return()

	/*/
	———————————————————————————————————————————————————————————————————————————————
	@function		ExportXML                                                    /@
	@type			User function                                                /@
	@date			20/07/2020                                                   /@
	@description	Gera os arquivos XML de acordo com parametrização informada  /@
	@author			Adalberto Moreno Batista (Opção Um)                          /@
	@use			Brasitech                                                    /@
	———————————————————————————————————————————————————————————————————————————————
	/*/
	Static Function ExportXML()
	Local cQuery	:= "SELECT R_E_C_N_O_ REGISTRO " +;
						"FROM " + RetSQLName("ZZ7") + " ZZ7 " +;
						"WHERE ZZ7.ZZ7_FILIAL = '" + xFilial("ZZ7") + "' " +;
							"AND ZZ7.ZZ7_STATUS != '4' " +;
							"AND ZZ7.ZZ7_SERIE = '" + mv_par02 + "' " +;
							"AND ZZ7_NNF BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' " +;
							"AND ZZ7.ZZ7_DTEMIS BETWEEN '" + dTOs(mv_par05) + "' AND '" + dTOs(mv_par06) + "' " +;
							"AND ZZ7.ZZ7_IDORDE BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "' " +;
							"AND ZZ7.D_E_L_E_T_ = ' ' " +;
						"ORDER BY ZZ7_NNF "
	Local cDestino	:= AllTrim(mv_par01) + iif(Right(AllTrim(mv_par01), 1) == "\", "", "\")
	Local cFile

	if Select("TRAB") > 0
		TRAB->(dbCloseArea())
	endif
	
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "TRAB", .F., .T.)

	if !TRAB->(Eof())

		do while TRAB->(!eof())
			ZZ7->(dbGoTo(TRAB->REGISTRO))
			cFile	:= "NFe" + ZZ7->ZZ7_IDEMIT + ZZ7->ZZ7_NNF + StrZero(Val(ZZ7->ZZ7_SERIE),3) + ".xml"
			MemoWrite(cDestino + cFile, ZZ7->ZZ7_XML)
			TRAB->(dbSkip())
		enddo

		MsgBox("XML(s) gerados com sucesso!", "Geração XML", "INFO")

	else

		MsgBox("Não encontrado registros no intervalo parametrizado!", "Geração XML", "ERRO")
		
	endif

	if Select("TRAB") > 0
		TRAB->(dbCloseArea())
	endif

	Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		MNT01MovFin                                                  /@
@type			User function                                                /@
@date			24/06/2019                                                   /@
@description	Movimenta Estoque                                            /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————

Static Function MNT01MovFin()
Local lRet			:= .T.
Local cChave		:= ZZ7->ZZ7_NNF + "-" + ZZ7->ZZ7_SERIE
Local cEol			:= chr(13) + chr(10)
Local cString		:= StrTran(ZZ7->ZZ7_TITULO, "#", cEol)
Local aDuplic		:= {}
Local cPrefixo		:= ZZ7->ZZ7_SERIE		//GetMV("MV_1DUPREF")
Local cNatureza	:= GetMV("MV_1DUPNAT")
Local cParcela		:= GetMV("MV_1DUP")
Local nX, cApoio, aTitulo, aBaixa
Private lMsErroAuto := .F. //necessario a criacao

cNatureza := &cNatureza

// Identificando as parcelas
For nX:=1 to MlCount(cString)
	cApoio	:= StrTran(MemoLine(cString,, nX), ";", cEol)
	aAdd(aDuplic, {cParcela, sTOd(MemoLine(cApoio,, 1)), Val(MemoLine(cApoio,, 2))})
	cParcela := Chr(Asc(cParcela) + 1)
Next

SE1->(dbSetOrder(1))
For nX:=1 To Len(aDuplic)

	if SE1->(!dbSeek(xFilial("SE1") + cPrefixo + ZZ7->ZZ7_NNF + aDuplic[nX,1] + "NF "))

		aTitulo 	:= {	{"E1_PREFIXO",	cPrefixo,								Nil},;
							{"E1_NUM",		ZZ7->ZZ7_NNF,							Nil},;
							{"E1_PARCELA",	aDuplic[nX,1],							Nil},;
							{"E1_TIPO",		"NF ",									Nil},;
							{"E1_CLIENTE",	ZZ7->ZZ7_CLIENT,						Nil},;
							{"E1_LOJA",		ZZ7->ZZ7_LOJCLI,						Nil},;
							{"E1_NATUREZ",	cNatureza,								Nil},;
							{"E1_HIST",		"INTEGRACAO INFRACOMMERCE",				Nil},;
							{"E1_EMISSAO",	ZZ7->ZZ7_DTEMIS,						Nil},;
							{"E1_VENCTO",	aDuplic[nX,2],							Nil},;
							{"E1_VENCREA",	DataValida(aDuplic[nX,2]),				Nil},;
							{"E1_VALOR",	aDuplic[nX,3],							Nil},;
							{"E1_XCHVNFE",	ZZ7->ZZ7_IDNF,							Nil}}
		MsExecAuto({|x,y| FINA040(x,y)}, aTitulo, 3)

		if lMsErroAuto
		
			lRet := .F.
			U_GrvLogIC("ExecAuto FINA040", ZZ7->ZZ7_IDNF, cChave, "Movimento financeiro não pôde ser gravado. Erro no MsExecAuto", NomeAutoLog())
			
		else
		
			U_GrvLogIC("ExecAuto FINA040", ZZ7->ZZ7_IDNF, cChave, "Movimento financeiro gravado com SUCESSO")

			aBaixa := {	{"E1_PREFIXO",			cPrefixo,									Nil},;
							{"E1_NUM", 			ZZ7->ZZ7_NNF,								Nil},;
							{"E1_PARCELA", 		aDuplic[nX,1],								Nil},;
							{"E1_TIPO", 		"NF ",										Nil},;
							{"AUTMOTBX",		"NOR",										Nil},;
							{"AUTDTBAIXA",		ZZ7->ZZ7_DTEMIS,							Nil},;
							{"AUTDTCREDITO",	ZZ7->ZZ7_DTEMIS,							Nil},;
							{"AUTBANCO",		"CX1",										Nil},;
							{"AUTAGENCIA",		"00001",									Nil},;
							{"AUTCONTA",		"0000000001",								Nil},;
							{"AUTHIST",			'Baixa automatica INFRACOMMERCE',			Nil},;
							{"AUTJUROS",		0,											Nil, .T.},;
							{"AUTVALREC",		aDuplic[nX,3],								Nil }}
			MSExecAuto({|x,y| FINA070(x,y)}, aBaixa, 3)
			
			if lMsErroAuto
							
				//DisarmTransaction()
				U_GrvLogIC("ExecAuto FINA070", ZZ7->ZZ7_IDNF, cChave, "Baixa financeira não realizada. Erro no MsExecAuto", NomeAutoLog())
							
			else
	
				U_GrvLogIC("ExecAuto FINA070", ZZ7->ZZ7_IDNF, cChave, "Baixa realizada com SUCESSO")
							
			endif

		endif
		
	else
	
		U_GrvLogIC("ExecAuto FINA040", ZZ7->ZZ7_IDNF, cChave, "Título não gravado pois já existe na base de dados")
	
	endif
	
Next

Return(lRet)
/*/

