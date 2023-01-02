#include "rwmake.ch"
#include "protheus.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		BFATM02                                                       /@
@type				User Function                                                 /@
@date				19/11/2012                                                    /@
@description	Atualiza  campo de bloqueio para geracao de arquivo de 
					separacao de produtos, pelo operador logistico                /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Opção Um Consultoria                                          /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function BFATM02()
Local cPerg		 	:= PadR("BFATM02", Len(SX1->X1_GRUPO))
Local aRegs     	:= {}
Local aCabSX1	 	:= {"X1_GRUPO", "X1_ORDEM", "X1_PERGUNT", "X1_VARIAVL", "X1_TIPO", "X1_TAMANHO", "X1_DECIMAL", "X1_GSC", "X1_VAR01", "X1_F3", "X1_DEF01", "X1_DEF02", "X1_DEF03"}
//                    "xxxxxxxxxxXXXXXXXXXXxxxxxxxxxxXXXXXXXXXX", "xxxxxxxxxxXXXXXXXXXXxxxxxxxxxxXXXXXXXXXX", "xxxxxxxxxxXXXXXXXXXXxxxxxxxxxxXXXXXXXXXX", 
Local aHlp01	 	:= {"Informe qual o filtro que será realizado ", "na apresentação das notas fiscais", "com controle de envio EDI para FM"}
Local aHlp02		:= {"Data inicial da emissão da nota fiscal.  ", "Preenchimento obrigatório."}
Local aHlp03		:= {"Data final da emissão da nota fiscal.    ", "Preenchimento obrigatório."}
Local aHlp04		:= {"Código inicial do produto, para a        ", "pesquisa do movimento."}
Local aHlp05		:= {"Código final do produto, para a pesquisa ", "do movimento."}
Local aHlp06		:= {"Código inicial do cliente ou fornecedor  ", "para a pesquisa do movimento."}
Local aHlp07		:= {"Código final do cliente ou fornecedor    ", "para a pesquisa do movimento."}
Local aHlp08		:= {"Número NF inicial, para a pesquisa do    ", "movimento."}
Local aHlp09		:= {"Número NF final, para a pesquisa do      ", "movimento."}
Local aHlp10		:= {"Série NF inicial, para a pesquisa do     ", "movimento."}
Local aHlp11		:= {"Série NF final, para a pesquisa do       ", "movimento."}
Local nOpcao		:= 0
Local aSays			:= {}
Local aButtons		:= {}

//———————————————————————————————————————————————————————————————————————————————
// F2_X_OPLOG = XX
//              |+-> indica bloqueios diversos pelo pedido (S/N)
//              +--> indica bloqueio por agendamento (S/N)
//———————————————————————————————————————————————————————————————————————————————

//———————————————————————————————————————————————————————————————————————————————
// Verificando se a empresa possui o campo especifico do tratamento EDI
//———————————————————————————————————————————————————————————————————————————————
if SF2->( FieldPos("F2_X_OPLOG") ) = 0 .or.;
  	SA1->( FieldPos("A1_X_AGEND") ) = 0 .or.;
	SC5->( FieldPos("C5_X_BLARQ") ) = 0

	Help(" ", 1, "ATENÇÃO", , "Opção inválida para esta empresa" + chr(13) + chr(10) + "(Específico Brasitech)", 1)
	Return()

endif

//———————————————————————————————————————————————————————————————————————————————
// parametros para o processamento
//———————————————————————————————————————————————————————————————————————————————
//									"xxxxxxxxxxXXXXXXXXXXxxxxxxxxxx"
aAdd(aRegs, {cPerg, "01", "Bloqueios ?         ", "mv_ch1", "N", 01, 0, "C", "mv_par01", "", 	 "1-Agendamento", "2-Pedido Venda", "3-Todos"})
aAdd(aRegs, {cPerg, "02", "Da emissão ?        ", "mv_ch2", "D", 01, 0, "G", "mv_par02", "", 	 "",					"",					""})
aAdd(aRegs, {cPerg, "03", "Até a emissão ?     ", "mv_ch3", "D", 01, 0, "G", "mv_par03", "", 	 "",					"",					""})
aAdd(aRegs, {cPerg, "04", "Do Cliente ?        ", "mv_ch4", "C", 08, 0, "G", "mv_par04", "SA1",  "",					"",					""})
aAdd(aRegs, {cPerg, "05", "Da Loja ?           ", "mv_ch5", "C", 02, 0, "G", "mv_par05", "", 	 "",					"",					""})
aAdd(aRegs, {cPerg, "06", "Até o Cliente ?     ", "mv_ch6", "C", 08, 0, "G", "mv_par06", "SA1",  "",					"",					""})
aAdd(aRegs, {cPerg, "07", "Até a Loja ?        ", "mv_ch7", "C", 02, 0, "G", "mv_par07", "", 	 "",					"",					""})
aAdd(aRegs, {cPerg, "08", "Do número da NF ?   ", "mv_ch8", "C", 09, 0, "G", "mv_par08", "",  	 "",					"",					""})
aAdd(aRegs, {cPerg, "09", "Até o número da NF ?", "mv_ch9", "C", 09, 0, "G", "mv_par09", "",  	 "",					"",					""})
aAdd(aRegs, {cPerg, "10", "Da série da NF ?    ", "mv_cha", "C", 03, 0, "G", "mv_par10", "",  	 "",					"",					""})
aAdd(aRegs, {cPerg, "11", "Até a série da NF ? ", "mv_chb", "C", 03, 0, "G", "mv_par11", "",  	 "",					"",					""})

U_BRASX1(aRegs, aCabSX1)

PutSX1Help("P." + AllTrim(cPerg) + "01.", aHlp01, aHlp01, aHlp01)
PutSX1Help("P." + AllTrim(cPerg) + "02.", aHlp02, aHlp02, aHlp02)
PutSX1Help("P." + AllTrim(cPerg) + "03.", aHlp03, aHlp03, aHlp03)
PutSX1Help("P." + AllTrim(cPerg) + "04.", aHlp04, aHlp04, aHlp04)
PutSX1Help("P." + AllTrim(cPerg) + "05.", aHlp05, aHlp05, aHlp05)
PutSX1Help("P." + AllTrim(cPerg) + "06.", aHlp06, aHlp06, aHlp06)
PutSX1Help("P." + AllTrim(cPerg) + "07.", aHlp07, aHlp07, aHlp07)
PutSX1Help("P." + AllTrim(cPerg) + "08.", aHlp08, aHlp08, aHlp08)
PutSX1Help("P." + AllTrim(cPerg) + "09.", aHlp09, aHlp09, aHlp09)
PutSX1Help("P." + AllTrim(cPerg) + "10.", aHlp10, aHlp10, aHlp10)
PutSX1Help("P." + AllTrim(cPerg) + "11.", aHlp11, aHlp11, aHlp11)

if Pergunte(cPerg,.T.)

	aAdd(aSays, "Função para liberação de notas fiscais para a integração com o operador ")
	aAdd(aSays, "logístico FM.")
	aAdd(aSays, "")
	aAdd(aSays, "")
	aAdd(aSays, "Rotina específica Brasitech")
	
	aAdd(aButtons, {01, .T., {|o| nOpcao := 1, o:oWnd:End()}})	//01 - Ok
	aAdd(aButtons, {02, .T., {|o| nOpcao := 0, o:oWnd:End()}})	//02 - Cancela
	aAdd(aButtons, {05, .T., {|o| nOpcao := 2, o:oWnd:End()}})	//05 - Parâmetros
	
	//——————————————————————————————————————————————————————————————————————————
	// Apresenta tela inicial
	//——————————————————————————————————————————————————————————————————————————
	do while .T.
	
		FormBatch("Liberação de notas fiscais para integração com a FM", aSays, aButtons)
		
		if nOpcao == 1
			
			if Empty(mv_par03) .or. mv_par02 > mv_par03
				Help(" ", 1, "ATENÇÃO",, "A data final deverá ser maior que a data inicial." + chr(13) + chr(10) + "(Específico Brasitech)", 1)
				Loop
			endif
	
			if Empty(mv_par06) .or. Empty(mv_par07) .or. mv_par04 + mv_par05 > mv_par06 + mv_par07
				Help(" ", 1, "ATENÇÃO",, "O cliente e loja final não poderá estar em branco e deverá ser maior do que o cliente e loja inicial." + chr(13) + chr(10) + "(Específico Brasitech)", 1)
				Loop
			endif

			if Empty(mv_par09) .or. mv_par08 > mv_par09
				Help(" ", 1, "ATENÇÃO",, "O número da NF final deverá ser maior que o número da NF inicial." + chr(13) + chr(10) + "(Específico Brasitech)", 1)
				Loop
			endif

			if Empty(mv_par11) .or. mv_par10 > mv_par11
				Help(" ", 1, "ATENÇÃO",, "A série da NF final deverá ser maior que a série da NF inicial." + chr(13) + chr(10) + "(Específico Brasitech)", 1)
				Loop
			endif
	
			if mv_par01 == 3 .and. Upper(AllTrim(cUserName)) != "ADMIN"
				Help(" ", 1, "ATENÇÃO",, "Esta opção somente poderá ser utilizada pelo ADMIN. Escolha as opções de desbloqueio 1-Agendamento ou 2-Pedido Vendas." + chr(13) + chr(10) + "(Específico Brasitech)", 1)	
			   Loop
			 endif
	
		elseif nOpcao == 2
		
			if Pergunte(cPerg, .T.)
				nOpcao := 1
			endif
			Loop
	
		elseif nOpcao == 0
		
			exit
			
		endif
	
		if nOpcao == 1
			Processa( { || PesqMovim() }, "Filtrando os registros..." )
		endif

	enddo
	
endif

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		PESQMOVIM                                                     /@
@type				Static function                                               /@
@date				18/04/2015                                                    /@
@description	Marca todos os itens selecionados.                            /@
@author			Adalberto Moreno Batista                                      /@
@use				Especifico Opção Um Consultoria                               /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function PesqMovim()
Local cQuery, cNome, cAgenda, cSuframa, cTitulo, cBotao, cMens
Local lCompart		:= .F.		//Caso verdadeiro, indica que a tabela deve ser aberta em modo compartilhado, isto é, outros processos também poderão abrir esta tabela.
Local lLeitura		:= .F.		//Caso verdadeiro, indica que este alias será usado apenas para leitura de dados. Caso contrário, estas operações serão permitidas.
Local lMarca		:= .T.
Local aArqTrab		:= {	{"T_MARCA",		"C", 02, 00},;
								{"T_DOC",		"C", 09,	00},;
								{"T_SERIE",		"C", 03,	00},;
								{"T_TIPO",		"C", 01,	00},;
								{"T_CLIENTE",	"C", 08,	00},;
								{"T_LOJA",		"C", 02,	00},;
								{"T_X_RAZAO",	"C", 40,	00},;
								{"T_AGENDA",	"C", 01,	00},;
								{"T_EMISSAO",	"D", 08,	00},;
								{"T_EST",		"C", 02,	00},;
								{"T_VALMERC",	"N", 14,	02},;
								{"T_VALBRUT",	"N", 14,	02},;
								{"T_VALICM",	"N", 14,	02},;
								{"T_BASEICM",	"N", 14,	02},;
								{"T_VALIPI",	"N", 14,	02},;
								{"T_BASEIPI",	"N", 14,	02},;
								{"T_ICMSRET",	"N", 14,	02},;
								{"T_DIFAL",		"N", 14,	02},;
								{"T_ESPECI1",	"C", 10,	00},;
								{"T_VOLUME1",	"N", 06,	00},;
								{"T_PLIQUI",	"N", 11,	04},;
								{"T_PBRUTO",	"N", 11,	04},;
								{"T_SUFRAMA",	"C", 12,	00},;
								{"T_REGISTRO",	"N", 10,	00}}
Local cDBFTrab		:= CriaTrab(aArqTrab, .T.)
Private cMarca		:= GetMark()
Private aCampos	:= {	{"T_MARCA",		"", "  ",					},;
								{"T_DOC",		"", "Numero",			"@!"},;
								{"T_SERIE",		"", "Serie Docto.",	"@!"},;
								{"T_TIPO",		"", "Tipo da nota",	"@!"},;
								{"T_CLIENTE",	"", "Cliente",			"@!"},;
								{"T_LOJA",		"", "Loja",				"@!"},;
								{"T_X_RAZAO",	"", "Razao Social",		},;
								{"T_AGENDA",	"", "Agendamento",		},;
								{"T_EMISSAO",	"", "DT Emissao",			},;
								{"T_EST",		"", "Estado",			"@!"},;
								{"T_VALMERC",	"", "Vlr.Mercad",		"@E 999,999,999.99"},;
								{"T_VALBRUT",	"", "Vlr.Bruto",		"@E 999,999,999.99"},;
								{"T_VALICM",	"", "Vlr.ICMS",		"@E 999,999,999.99"},;
								{"T_BASEICM",	"", "Base p/ICMS",	"@E 999,999,999.99"},;
								{"T_VALIPI",	"", "Vlr.IPI",			"@E 999,999,999.99"},;
								{"T_BASEIPI",	"", "Base p/IPI",		"@E 999,999,999.99"},;
								{"T_ICMSRET",	"", "ICMS Retido",	"@E 999,999,999.99"},;
								{"T_DIFAL",		"", "Difal",			"@E 999,999,999.99"},;
								{"T_ESPECI1",	"", "Especie 1",		"@!"},;
								{"T_VOLUME1",	"", "Volume 1",		"999999"},;
								{"T_PLIQUI",	"", "Peso Liquido",	"@E 999999.9999"},;
								{"T_PBRUTO",	"", "Peso Bruto",		"@E 999999.9999"},;
								{"T_SUFRAMA",	"", "Suframa",				}}
Private oEC, oMark

//———————————————————————————————————————————————————————————————————————————————
// Cria tabela de trabalho
//———————————————————————————————————————————————————————————————————————————————
if Select("TRAB") > 0
	TRAB->(dbCloseArea())
endif
dbUseArea(.T., __LocalDriver, cDBFTrab, "TRAB", lCompart, lLeitura)

//———————————————————————————————————————————————————————————————————————————————
// Selecionando registros
//———————————————————————————————————————————————————————————————————————————————
cQuery := 	"SELECT F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_EMISSAO, F2_EST, F2_VALBRUT, F2_VALICM, F2_BASEICM, "
cQuery +=	  		 "F2_VALIPI, F2_BASEIPI, F2_VALMERC, F2_TIPO, F2_ESPECI1, F2_VOLUME1, F2_ICMSRET, F2_PLIQUI, "
cQuery +=	  		 "F2_PBRUTO, SUM(D2_DIFAL) D2_DIFAL, SF2.R_E_C_N_O_ REGISTRO "
cQuery += 	"FROM " + RetSQLName("SF2") + " SF2, " + RetSQLName("SD2") + " SD2 "
cQuery += 	"WHERE F2_FILIAL = '" + xFilial("SF2") + "' "
cQuery += 			"AND SF2.F2_EMISSAO BETWEEN '" + dTOs(mv_par02) + "'  AND '" + dTOs(mv_par03) + "' "
cQuery += 			"AND SF2.F2_CLIENTE+SF2.F2_LOJA BETWEEN '" + mv_par04 + mv_par05 + "'  AND '" + mv_par06 + mv_par07 + "' "
cQuery += 			"AND SF2.F2_DOC BETWEEN '" + mv_par08 + "'  AND '" + mv_par09 + "' "
cQuery += 			"AND SF2.F2_SERIE BETWEEN '" + mv_par10 + "'  AND '" + mv_par11 + "' "
if mv_par01 == 1
	cQuery += 		"AND SF2.F2_X_OPLOG = 'SN' "
elseif mv_par01 == 2
	cQuery += 		"AND SUBSTRING(SF2.F2_X_OPLOG, 2, 1) = 'S' "
elseif mv_par01 == 3
	cQuery += 		"AND SF2.F2_X_OPLOG LIKE '%S%' "
endif
cQuery += 			"AND SF2.D_E_L_E_T_=' ' "
cQuery += 			"AND SD2.D2_FILIAL = '" + xFilial("SD2") + "' "
cQuery += 			"AND SD2.D2_DOC = SF2.F2_DOC "
cQuery += 			"AND SD2.D2_SERIE = SF2.F2_SERIE "
cQuery += 			"AND SD2.D2_CLIENTE = SF2.F2_CLIENTE "
cQuery += 			"AND SD2.D2_LOJA = SF2.F2_LOJA "
cQuery += 			"AND SD2.D_E_L_E_T_=' ' "

cQuery += 	"GROUP BY F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_EMISSAO, F2_EST, F2_VALBRUT, F2_VALICM, F2_BASEICM, "
cQuery +=	  		 "F2_VALIPI, F2_BASEIPI, F2_VALMERC, F2_TIPO, F2_ESPECI1, F2_VOLUME1, F2_ICMSRET, F2_PLIQUI, "
cQuery +=	  		 "F2_PBRUTO, SF2.R_E_C_N_O_ "

cQuery += 	"ORDER BY F2_DOC, F2_SERIE "

if Select("TEMP") > 0
	TEMP->(dbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TEMP", .F., .T.)
tcSetField("TEMP", "F2_EMISSAO", "D")

//———————————————————————————————————————————————————————————————————————————————
// Gravando em tabela Temporária
//———————————————————————————————————————————————————————————————————————————————
SA1->(dbSetOrder(1))
SA2->(dbSetOrder(1))

dbSelectArea("TEMP")
TEMP->(dbGoTop())
if TEMP->(!eof())
	do while TEMP->(!eof())
	
		if !TEMP->F2_TIPO $ "BD"
			SA1->(dbSeek(xFilial("SA1") + TEMP->(F2_CLIENTE+F2_LOJA)))
			cNome 	:= SA1->A1_NOME
			cAgenda	:= SA1->A1_X_AGEND
			cSuframa	:= SA1->A1_SUFRAMA
		else
			SA2->(dbSeek(xFilial("SA2") + TEMP->(F2_CLIENTE+F2_LOJA)))
			cNome 	:= SA2->A2_NOME
			cAgenda	:= ""
			cSuframa	:= ""
		endif
				
		TRAB->(RecLock("TRAB", .T.))
		TRAB->T_DOC			:= TEMP->F2_DOC
		TRAB->T_SERIE		:= TEMP->F2_SERIE
		TRAB->T_TIPO		:= TEMP->F2_TIPO
		TRAB->T_CLIENTE	:= TEMP->F2_CLIENTE
		TRAB->T_LOJA		:= TEMP->F2_LOJA
		TRAB->T_X_RAZAO	:= cNome
		TRAB->T_AGENDA		:= cAgenda
		TRAB->T_SUFRAMA	:= cSuframa
		TRAB->T_EMISSAO	:= TEMP->F2_EMISSAO
		TRAB->T_EST			:= TEMP->F2_EST
		TRAB->T_VALMERC	:= TEMP->F2_VALMERC
		TRAB->T_VALBRUT	:= TEMP->F2_VALBRUT
		TRAB->T_VALICM		:= TEMP->F2_VALICM
		TRAB->T_BASEICM	:= TEMP->F2_BASEICM
		TRAB->T_VALIPI		:= TEMP->F2_VALIPI
		TRAB->T_BASEIPI	:= TEMP->F2_BASEIPI
		TRAB->T_ICMSRET	:= TEMP->F2_ICMSRET
		TRAB->T_ESPECI1	:= TEMP->F2_ESPECI1
		TRAB->T_VOLUME1	:= TEMP->F2_VOLUME1
		TRAB->T_PLIQUI		:= TEMP->F2_PLIQUI
		TRAB->T_PBRUTO		:= TEMP->F2_PBRUTO
		TRAB->T_DIFAL		:= TEMP->D2_DIFAL
		TRAB->T_REGISTRO	:= TEMP->REGISTRO
		TRAB->(MsUnlock())
		TEMP->(dbSkip())
			
	enddo

endif

if Select("TEMP") > 0
	TEMP->(dbCloseArea())
endif

dbSelectArea("TRAB")
dbGoTop()
if !eof()

	if mv_par01 == 1
		cTitulo	:= "Desbloqueio de notas para expedição de mercadoria"
		cBotao	:= "Lib.p/Expedição"
		cMens		:= "Aguarde... Liberando as NF´s para envio à FM."

	elseif mv_par01 == 2
		cTitulo	:= "Desbloqueio de notas para agendamento de entrega"
		cBotao	:= "Lib.p/Agendamento"
		cMens		:= "Aguarde... Liberando as NF´s para agendamento de entrega."

	elseif mv_par01 == 3
		cTitulo	:= "Desbloqueio de notas para agendamento de entrega"
		cBotao	:= "Lib.p/Expedição"
		cMens		:= "Aguarde... Liberando as NF´s para agendamento de entrega."
		MsgBox("Esta opção irá liberar, ao mesmo tempo, todos os bloqueios existentes para a respectiva nota fiscal", "Atenção", "INFO")

	endif

	@ 060,001 TO 590,1100 Dialog oEC Title OemToAnsi(cTitulo)

	oMark	:= MsSelect():New("TRAB", "T_MARCA", , aCampos, .F., @cMarca, {005,002,247,550})	//,,,,,aCores)

	@ 250, 010 Button OemtoAnsi("Marca/Desmarca todos") 	Size 60,12 Pixel of oEC Action MarcaTodos(@lMarca, @oEC)
	@ 250, 080 Button OemtoAnsi("Inverte seleção") 			Size 60,12 Pixel of oEC Action InverteMarca(@oEC)
	@ 250, 340 Button OemtoAnsi(cBotao) 						Size 60,12 Pixel of oEC Action Processa({|| AtualInform(.T.)}, cMens)
	@ 250, 410 Button OemtoAnsi("Elimina Pendencia") 		Size 60,12 Pixel of oEC Action Processa({|| AtualInform(.F.)}, "Aguarde... Eliminando pendências de bloqueio.")
	@ 250, 480 Button OemtoAnsi("Cancelar") 					Size 60,12 Pixel of oEC Action (oEC:End())

	Activate Dialog oEC Centered

else

	Help("", 1, "Sem registros",, "Registros não localizados no período informado." + chr(13) + chr(10) + "(Especifico Brasitech)", 1)

endif

if Select("TRAB") > 0
	TRAB->(dbCloseArea())
	fErase(cDBFTrab + GetDbExtension())
endif
Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		ATUALINFORM                                                   /@
@type				Static function                                               /@
@date				15/05/2017                                                    /@
@description	Atualiza flag referente ao envio de informações para o operador
					logístico.                                                    /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Opção Um Consultoria                                          /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function AtualInform(lLibera)
Local aNFExped		:= {}
Local aNFAgend		:= {}
Local aNFElim		:= {}
Local aNFGNRE		:= {}
Local cEmlMsg		:= ""
Local cSubject		:= ""
Local cBody			:= ""
Local cSubTrib		:= GetMV("MV_SUBTRIB", .F., "")
Local cDestAge		:= GetMV("BR_FTM02AG", .F., "amoreno@opcaoum.com.br")
Local cDestExp		:= GetMV("BR_FTM02EX", .F., "amoreno@opcaoum.com.br")
Local cDestST		:= GetMV("BR_FTM02ST", .F., "amoreno@opcaoum.com.br")
Local cDestElim	:= GetMV("BR_FTM02EL", .F., "amoreno@opcaoum.com.br")
Local cOpLog1, cOpLog2, aApoio, cExpGko

if !lLibera
	MsgBox("Esta operação eliminará o controle de envio de informações para o operador logistico.", "Atenção", "ERRO")
endif

if MsgBox(iif(lLibera, "Deseja desbloquear as NF´s marcadas?", "Deseja cancelar a pendência das NF´s marcadas?"), "Pergunta", "YESNO")
			 
	TRAB->(dbGoTop())
	do while TRAB->(!eof())

		if TRAB->(Marked("T_MARCA"))

			//———————————————————————————————————————————————————————————————————————————————
			// Atualiza flag de liberação da nota fiscal
			//———————————————————————————————————————————————————————————————————————————————
			SF2->(dbGoTo(TRAB->T_REGISTRO))
			
			if lLibera
				cOpLog1	:= Substr(SF2->F2_X_OPLOG, 1, 1)
				cOpLog2	:= Substr(SF2->F2_X_OPLOG, 2, 1)
				cExpGko  := ""
				if mv_par01 == 3
					cOpLog1 			:= "N"
					cOpLog2 			:= "N"
				elseif mv_par01 == 1
					cOpLog1			:= "N"
				elseif mv_par01 == 2
					cOpLog2 			:= "N"
				endif
			else
				cOpLog1 	:= " "
				cOpLog2 	:= " "
				cExpGko	:= "N"
			endif
			
			SF2->(RecLock("SF2", .F.))
			SF2->F2_X_OPLOG		:= cOpLog1 + cOpLog2
			SF2->F2_X_EXPGK 		:= cExpGko
			if mv_par01 == 1 .or. mv_par01 == 3
				SF2->F2_X_DBLQ1	:= dTOs(Date()) + " " + Time() + " " + cUserName
			endif
			if mv_par01 == 2 .or. mv_par01 == 3
				SF2->F2_X_DBLQ2	:= dTOs(Date()) + " " + Time() + " " + cUserName
			endif
			SF2->(MsUnlock())

			//———————————————————————————————————————————————————————————————————————————————
			// Monta array de apoio com dados da NF
			//———————————————————————————————————————————————————————————————————————————————
			aApoio := TRAB->({T_DOC, T_SERIE, T_EMISSAO, T_CLIENTE, T_LOJA, T_X_RAZAO, T_EST, T_VALBRUT, T_ICMSRET, T_DIFAL, T_SUFRAMA})

			//———————————————————————————————————————————————————————————————————————————————
			// Lista de NF´s com eliminação de pendência
			//———————————————————————————————————————————————————————————————————————————————
			if Empty(SF2->F2_X_OPLOG)
				aAdd(aNFElim, aApoio)
			endif

			//———————————————————————————————————————————————————————————————————————————————
			// Preparando NF´s liberadas pelo departamento comercial para agendamento
			//———————————————————————————————————————————————————————————————————————————————
			if Substr(SF2->F2_X_OPLOG,2,1) == "N" .and. !Substr(SF2->F2_X_OPLOG,1,1) $ "ON"
				aAdd(aNFAgend, aApoio)
			endif
			
			//———————————————————————————————————————————————————————————————————————————————
			// Preparando NF´s liberadas do agendamento para expedição (envio ao operador logistico FM)
			//———————————————————————————————————————————————————————————————————————————————
			if SF2->F2_X_OPLOG $ "NN/ON"
				aAdd(aNFExped, aApoio)
			endif

			//———————————————————————————————————————————————————————————————————————————————
			// Preparando NF´s que necessitam do pagamento de GNRE ou liberação de PIN
			//———————————————————————————————————————————————————————————————————————————————
         if mv_par01 == 2 .and. ((!TRAB->T_EST $ cSubTrib .and. TRAB->(T_ICMSRET + T_DIFAL) > 0) .or. !empty(TRAB->T_SUFRAMA))
	         aAdd(aNFGNRE, aApoio)
         endif
			
		endif
		
		TRAB->(dbSkip())
		
	enddo

	//———————————————————————————————————————————————————————————————————————————————
	// Envio de e-mail com NF´s com eliminação de pendência
	//———————————————————————————————————————————————————————————————————————————————
	if Len(aNFElim) > 0
		cSubject		:= "GAMA Italy: Relação de NF´s com eliminação de pendência."
		cBody			:= "Segue a relação de NF´s que tiveram eliminadas a pendência de envio para expedição."
		cEmlMsg		:= MontaEmail(aNFElim, cBody)
		U_GISendMail(cDestElim,, cSubject, cEmlMsg)
	endif

	//———————————————————————————————————————————————————————————————————————————————
	// Envio de e-mail com NF´s liberadas pelo departamento comercial
	//———————————————————————————————————————————————————————————————————————————————
	if Len(aNFAgend) > 0
		cSubject			:= "GAMA Italy: Relação de NF´s com desbloqueio comercial."
		cBody				:= "Segue a relação de NF´s com desbloqueio comercial, para providências de agendamento de entrega."
		cEmlMsg := MontaEmail(aNFAgend, cBody)
		U_GISendMail(cDestAge,, cSubject, cEmlMsg)
	endif

	//———————————————————————————————————————————————————————————————————————————————
	// Envio de e-mail com NF´s liberadas para envio ao operador logístico FM
	//———————————————————————————————————————————————————————————————————————————————
	if Len(aNFExped) > 0
		cSubject		:= "GAMA Italy: Relação de NF´s disponíveis para o envio de ordem de separação."
		cBody			:= "Segue relação de NF´s disponíveis para o envio de ordem de separação na a FM Logistic."
		cEmlMsg := MontaEmail(aNFExped, cBody)
		U_GISendMail(cDestExp,, cSubject, cEmlMsg)
	endif

	//———————————————————————————————————————————————————————————————————————————————
	// Envio de e-mail com NF´s que necessitam do pagamento de GNRE ou liberação PIN
	//———————————————————————————————————————————————————————————————————————————————
	if Len(aNFGNRE) > 0
		cSubject		:= "GAMA Italy: Relação de NF´s com GNRE ou operação com ZFM"                                                     
		cBody			:= "Segue a relação de NF´s com valores de substituição tributária ou diferencial de alíquota a serem pagos com GNRE ou que tenham operação com Zona Franca de Manaus."
		cEmlMsg := MontaEmail(aNFGNRE, cBody)
		U_GISendMail(cDestST,, cSubject, cEmlMsg)
	endif

	MsgBox("Notas fiscais atualizadas com sucesso!", "Informação", "INFO")
	Close(oEC)

else

	MsgBox("Operação cancelada!", "Informação", "INFO")

endif
Close(oEC)
Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		MARCATODOS                                                    /@
@type				Static function                                               /@
@date				18/04/2015                                                    /@
@description	Marca todos os itens selecionados.                            /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Opção Um Consultoria                                          /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function MarcaTodos(lMarca, oEC)
Local nRec		:= TRAB->(Recno())

TRAB->(dbGoTop())
do while TRAB->(!eof())
	TRAB->(RecLock("TRAB",.F.))
	TRAB->T_MARCA := iif(lMarca, cMarca, "  ")
	TRAB->(MsUnlock())
	TRAB->(dbSkip())
enddo

TRAB->(dbGoTo(nRec))

oEC:Refresh()
lMarca := iif(lMarca, .F., .T.)
Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		INVERTEMARCA                                                  /@
@type				Static function                                               /@
@date				18/04/2015                                                    /@
@description	Inverte a marcaa dos registros selecionados.                  /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Opção Um Consultoria                                          /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function InverteMarca(oEC)
Local nRec	:= TRAB->(Recno())

TRAB->(dbGoTop())
do while TRAB->(!eof())
	TRAB->(RecLock("TRAB",.F.))
	TRAB->T_MARCA := iif(TRAB->T_MARCA == cMarca, "'  ", cMarca)
	TRAB->(MsUnlock())
	TRAB->(dbSkip())
enddo
TRAB->(dbGoTo(nRec))

oEC:Refresh()

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		C                                                             /@
@type				Static function                                               /@
@date				10/052/2005                                                   /@
@description	Manter o Layout independente da resolução horizontal do Monitor
					do Usuario.                                                   /@
@author			Norbert Waage Junior                                          /@
@use				Especifico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
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
If "MP11" $ oApp:cVersion
  // Tratamento para tema "Flat"
  If (Alltrim(GetTheme()) == "FLAT").Or. SetMdiChild()
		nTam *= 0.90
  EndIf
EndIf
Return Int(nTam)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		ENVIAEMAIL                                                    /@
@type				Static function                                               /@
@date				18/05/2017                                                    /@
@description	Envia email à controladoria sobre as notas liberadas para 
					separação.                                                    /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Opção Um Consultoria                                          /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function MontaEmail(aNFLista, cAssunto)
Local cMsg, nK

cMsg := '<html>'
cMsg += '<body><img src="http://emkt.gamaitaly.com.br/gama-assinatura/gama.jpg"><br><br>'
cMsg += '<font size="3" face="Calibri">Homologação do processo de liberação de notas para expedição.</font><br><br>'
cMsg += '<font size="3" face="Calibri">' + cAssunto + '</font><br><br>'
	
cMsg += '<table width="100%" border="1" cellspacing="0" cellpadding="1">'

cMsg += '<tr>'
cMsg += '<td width="11.5%" align="left"><font size="3" face="Calibri"><b>Docto/Série</b></font></td>'
cMsg += '<td width="6.5%" align="center"><font size="3" face="Calibri"><b>Emissão</b></font></td>'
cMsg += '<td width="10%" align="left"><font size="3" face="Calibri"><b>Código/Loja</b></font></td>'
cMsg += '<td width="29%" align="left"><font size="3" face="Calibri"><b>Razão Social</b></font></td>'
cMsg += '<td width="5%" align="left"><font size="3" face="Calibri"><b>Estado</b></font></td>'
cMsg += '<td width="11%" align="right"><font size="3" face="Calibri"><b>Valor NF</b></font></td>'
cMsg += '<td width="9%" align="right"><font size="3" face="Calibri"><b>ICMS Substituto</b></font></td>'
cMsg += '<td width="9%" align="right"><font size="3" face="Calibri"><b>Dif.Aliquota</b></font></td>'
cMsg += '<td width="9%" align="left"><font size="3" face="Calibri"><b>Suframa</b></font></td>'
cMsg += '</tr>'

for nK := 1 to Len(aNFLista)

	cMsg += '<tr>'
	cMsg += '<td width="11.5%" align="left"><font size="3" face="Calibri">' + aNFLista[nK,1] + " / " + aNFLista[nK,2] + '</font></td>'
	cMsg += '<td width="6.5%" align="center"><font size="3" face="Calibri">' + dTOc(aNFLista[nK,3]) + '</font></td>'
	cMsg += '<td width="10%" align="left"><font size="3" face="Calibri">' + aNFLista[nK,4] + " / " + aNFLista[nK,5] + '</font></td>'
	cMsg += '<td width="29%" align="left"><font size="3" face="Calibri">' + aNFLista[nK,6] + '</font></td>'
	cMsg += '<td width="5%" align="left"><font size="3" face="Calibri">' + aNFLista[nK,7] + '</font></td>'
	cMsg += '<td width="11%" align="right"><font size="3" face="Calibri">' + Transf(aNFLista[nK,8], "@E 999,999,999.99") + '</font></td>'
	cMsg += '<td width="9%" align="right"><font size="3" face="Calibri">' + Transf(aNFLista[nK,9], "@E 999,999,999.99") + '</font></td>'
	cMsg += '<td width="9%" align="right"><font size="3" face="Calibri">' + Transf(aNFLista[nK,10], "@E 999,999,999.99") + '</font></td>'
	cMsg += '<td width="9%" align="left"><font size="3" face="Calibri">' + aNFLista[nK,11] + '</font></td>'
	cMsg += '</tr>'
			
next
	
cMsg += '</table><br><br><br>'
cMsg += '<font size="1" face="Calibri"><i>E-mail automático enviado pelo processo dow, Favor não respondê-lo.</i></font><br><br>'
cMsg += '</body>'
cMsg += '</html>'

Return(cMsg)
