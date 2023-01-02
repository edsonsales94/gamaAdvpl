#INCLUDE "PROTHEUS.CH"
#INCLUDE "FIVEWIN.CH"
#INCLUDE "PONR100.CH"
#INCLUDE "REPORT.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PONR100    ³ Autor ³ Eduardo Ju                 ³ Data ³ 29/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatorio de Banco de Horas                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PONR100(void)                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ FNC/CH   ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Tania	   ³12/10/2006³    100331³Diversos ajustes para adequacao do relato- ³±±
±±³      	   ³          ³          ³rio a ferramenta de personalizacao do R4.  ³±±
±±³Luiz Gustavo³05/02/2007³          ³Retiradas funcoes de ajuste de dicionario. ³±±
±±³Pedro Eloy  ³14/11/2007³    135213³Feito o tratamento para a quebra C.Custo.  ³±±
±±³Marcelo     ³10/06/2008³    146399³Acerto p/ aplicar corretamente a ordem de  ³±±
±±³      	   ³          ³          ³impressao conforme definicao do usuario.   ³±±
±±³Rogerio R.  ³29/07/2009³08267/2009³Compatibilizacao dos fontes para aumento do³±±
±±³            ³          ³          ³campo filial e gestão corporativa.         ³±±
±±³Leandro Dr. ³28/09/2009³22616/2009³Ajuste para correta impressao dos saldos   ³±±
±±³            ³          ³  		 ³no relatorio personalizavel.               ³±±
±±³Bianca CL   |12/05/2010|05716/2010|Ajuste para impressão correta de saldo     ³±±
±±³Gustavo M.  |21/05/2012|10597/2012|Ajuste para imprimir o relat via planilha  ³±±
±±³Fabio G.    ³26/03/2013³    TGVGZ0³Ajuste para correta impressao dos saldos   ³±±
±±³            ³          ³  		 ³no relatorio nao personalizavel.           ³±±
±±³Gustavo M.  |16/05/2013|	   THBGXA|Ajuste para contabilizar o saldo anterior. ³±±
±±³Renan Borges|20/03/2014|	   TIIGK9|Criada a pergunta para a impressão do rela-³±±
±±³            ³          ³          ³tório no formato de horas sexagesimal      ³±±
±±³            ³          ³          ³ou centesimal								 ³±±
±±³Luis Artuso |17/06/2014|	   TPQKFC|Ajuste para correta impressao dos saldos   ³±±
±±³            ³          ³          ³no relatorio personalizavel,atraves da fun-³±±
±±³            ³          ³          ³cao: fTotR100.							 ³±±
±±³Luis Artuso ³31/03/2015³	   TRMUSZ³Ajuste em fTotR100 para 'zerar' as celulas ³±±
±±³            ³          ³          ³FUNCDEB e FUNCCRED para calcular a totaliza³±±
±±³            ³          ³          ³cao de debito/credito entre funcionarios.	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function UPONR100()

	Local oReport
	Local aArea 		:= GetArea()

	Private nSaldo	  	:= 0
	Private nSaldoAnt 	:= 0
	Private nSaldoAntv 	:= 0
	Private nSaldoEmp   := 0
	Private dDataAux  	:= Ctod('') 	//-- Variavel auxiliar para armazenar a ultima data
	Static nResult		:= 0
	Static nResultv		:= 0
	Static lTotaliza	:= .F.
	Static nAcuAnt		:= 0
	Static nAcuAntv		:= 0

	Static nTotal		:= 0
	Static nTotalv		:= 0

	//-- considerada no calculo do Saldo Anterior
	//If FindFunction("TRepInUse") .And. TRepInUse()	//Verifica se relatorio personalizal esta disponivel
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AjustaPN100RSx1()
	Pergunte("PN100R",.F.)
	oReport := ReportDef()
	oReport:PrintDialog()
	//EndIf

	RestArea( aArea )

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ReportDef() ³ Autor ³ Eduardo Ju          ³ Data ³ 29.08.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Definicao do Componente de Impressao do Relatorio           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()

	Local oReport
	Local oSection1
	Local oSection2
	Local aOrdem    := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao do componente de impressao                                      ³
	//³TReport():New                                                           ³
	//³ExpC1 : Nome do relatorio                                               ³
	//³ExpC2 : Titulo                                                          ³
	//³ExpC3 : Pergunte                                                        ³
	//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
	//³ExpC5 : Descricao                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:=TReport():New("PONR100",OemToAnsi(STR0001),"PN100R",{|oReport| PrintReport(oReport)},OemToAnsi(STR0033)+" - "+OemToAnsi(STR0002))
	//"Relatorio de Banco de Horas"###"Emite relatorio de Banco de Horas."###"Será impresso de acordo com os parametros solicitados pelo usuario"
	oReport:SetTotalInLine(.F.)
	Pergunte("PN100R",.F.)

	Aadd( aOrdem, STR0003)	// "Matricula"
	Aadd( aOrdem, STR0004)	// "Centro de Custo"
	Aadd( aOrdem, STR0005)	// "Nome"
	Aadd( aOrdem, STR0016)	// "C.Custo+Nome"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao da celulas da secao do relatorio                                ³
	//³TRCell():New                                                            ³
	//³ExpO1 : Objeto TSection que a secao pertence                            ³
	//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
	//³ExpC3 : Nome da tabela de referencia da celula                          ³
	//³ExpC4 : Titulo da celula                                                ³
	//³        Default : X3Titulo()                                            ³
	//³ExpC5 : Picture                                                         ³
	//³        Default : X3_PICTURE                                            ³
	//³ExpC6 : Tamanho                                                         ³
	//³        Default : X3_TAMANHO                                            ³
	//³ExpL7 : Informe se o tamanho esta em pixel                              ³
	//³        Default : False                                                 ³
	//³ExpB8 : Bloco de código para impressao.                                 ³
	//³        Default : ExpC2                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Criacao da Primeira Secao: Funcionarios ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection1 := TRSection():New(oReport,STR0019,{"SRA"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/)
	oSection1:SetTotalInLine(.F.)
	oSection1:SetHeaderBreak(.T.)

	TRCell():New(oSection1,"RA_FILIAL","SRA")	//Filial
	TRCell():New(oSection1,"RA_MAT","SRA")		//Matricula do Funcionario
	TRCell():New(oSection1,"RA_NOME","SRA")	   	//Nome do Funcionario
	TRCell():New(oSection1,"SALDOANT","   ","Sld.Ant.Hrs","@E 99999999.99",12)	//Saldo Anterior
	TRCell():New(oSection1,"SALDOANTV","   ","Sld.Ant.Vlr" ,"@E 99999999.99",12)	//Saldo Anterior

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Criacao da Segunda Secao: Banco de Horas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection2 := TRSection():New(oSection1,STR0021,{"SRA","SPI","SP9"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	//Avaliados
	oSection2:SetTotalInLine(.F.)
	oSection2:SetHeaderBreak(.T.)
	oSection2:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
	oSection2:SetHeaderPage(.T.)	//Exibe Cabecalho da Secao
	oSection2:SetLeftMargin(2)	//Identacao da Secao
	//oSection2:SetAutoSize()

	TRCell():New(oSection2,"PI_DATA",	"SPI"									)	//Data da Marcacao do Evento
	TRCell():New(oSection2,"PI_PD",		"SPI",	STR0022							)	//Codigo do Evento
	TRCell():New(oSection2,"P9_DESC",	"SP9",	""								)	//Descricao do Evento
	TRCell():New(oSection2,"DEBITO"	,	"   ",	"Deb.Hrs",	"@E 99999999.99",12	)	//Debito
	TRCell():New(oSection2,"DEBITOV"	,	"   ","Deb.Vlr",	"@E 99999999.99",12	)	//Debito
	TRCell():New(oSection2,"CREDITO",	"   ",	"Crd.Hrs",	"@E 99999999.99",12	)	//Credito
	TRCell():New(oSection2,"CREDITOV",	"   ",	"Crd.Vlr",	"@E 99999999.99",12	)	//Credito
	TRCell():New(oSection2,"SALDO",		"   ",	"Sld.Hrs",	"@E 99999999.99",12	)	//Saldo
	TRCell():New(oSection2,"SALDOV",	"   ",	"Sld.Valor",	"@E 99999999.99",12	)	//Saldo
	TRCell():New(oSection2,"STATUS"	,	"   ",	STR0026,					,15	)	//Status
	TRCell():New(oSection2,"SALDO2",	"   ",	'',			"@E 99999999.99",12	)	//Saldo Anterior (Nao sera visualizado no relatorio)
	TRCell():New(oSection2,"SALDO2V",	"   ",	'',			"@E 99999999.99",12	)	//Saldo Anterior (Nao sera visualizado no relatorio)
	TRCell():New(oSection2,"SALDO3",	"   ",	'',			"@E 99999999.99",12	)	//Saldo Anterior (Nao sera visualizado no relatorio)
	TRCell():New(oSection2,"SALDO3V",	"   ",	'',			"@E 99999999.99",12	)	//Saldo Anterior (Nao sera visualizado no relatorio)

	TRPosition():New(oSection2,"SPI",1,{|| xFilial("SPI") + SRA->RA_MAT })
	TRPosition():New(oSection2,"SP9",1,{|| xFilial("SP9") + SPI->PI_PD})

Return oReport

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ReportDef() ³ Autor ³ Eduardo Ju          ³ Data ³ 29.08.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do Relatorio                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PrintReport(oReport)

	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(1):Section(1)
	Local nOrdem  	:= osection1:GetOrder()
	Local cTit
	Local cTitCC	:= ""
	Local cTitle	:= ""
	Local cTitFil	:= ""
	Local cTitEmp	:= ""
	Local cMat 		:= ""
	Local cFiltroSRA:= ""
	Local nConta	:= 0
	Local nBcFlCrTt	:= 0
	Local nBcFlDbTt	:= 0
	Local nBcFlCrTtv:= 0
	Local nBcFlDbTtv:= 0
	LOcal nFuEmCrTt := 0
	Local nFuEmDbTt := 0
	Local nSdFilAnt	:= 0
	Local nSdFilAntv	:= 0
	Local cAcessaSRA:= &("{ || " + ChkRH("PONR100","SRA","2") + "}")

	Local aLanca    := {}
	Local aLancav    := {}
	Local nValor	:= 0 //-- Variavel auxiliar para calculo do Saldo Anterior
	Local nValorv	:= 0 //-- Variavel auxiliar para calculo do Saldo Anterior Valorizado

	Local nSaldComp := 0 //-- Variavel auxiliar para comparacao de saldo
	Local nSaldCompv := 0 //-- Variavel auxiliar para comparacao de saldo Valorizado

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Centralizacao das Celulas do Relatorio ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection2:Cell("DEBITO"):SetHeaderAlign("RIGHT")
	oSection2:Cell("CREDITO"):SetHeaderAlign("RIGHT")
	oSection2:Cell("SALDO"):SetHeaderAlign("RIGHT")

	oSection2:Cell("DEBITOV"):SetHeaderAlign("RIGHT")
	oSection2:Cell("CREDITOV"):SetHeaderAlign("RIGHT")
	oSection2:Cell("SALDOV"):SetHeaderAlign("RIGHT")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                                          ³
	//³ MV_PAR01        //  Filial?                                                   ³
	//³ MV_PAR02        //  Centro de Custo?                                          ³
	//³ MV_PAR03        //  Matricula?                                                ³
	//³ MV_PAR04        //  Nome?                                                     ³
	//³ MV_PAR05        //  Turno?                                                    ³
	//³ MV_PAR06        //  Regra Apontamento?                                        ³
	//³ MV_PAR07        //  Situacao do Funcionario?                                  ³
	//³ MV_PAR08        //  Categoria do Funcionario?                                 ³
	//³ MV_PAR09        //  CC em outra Pagina? 1-Sim 2-Nao                           ³
	//³ MV_PAR10        //  Funcionario em outra Pagina? 1-Sim 2-Nao                  ³
	//³ MV_PAR11        //  Impressao? 1-Analitico 2-Sintetico                        ³
	//³ MV_PAR12        //  Imprime Total por Filial? 1-Sim 2-Nao                     ³
	//³ MV_PAR13        //  Imprime Total por Empresa? 1-Sim 2-Nao                    ³
	//³ MV_PAR14        //  Imprime Eventos? 1-Proventos 2-Descontos 3-Ambos          ³
	//³ MV_PAR15        //  Periodo De?                                               ³
	//³ MV_PAR16        //  Periodo Ate?                                              ³
	//³ MV_PAR17        //  Horas? 1-Normais 2-Valorizadas                            ³
	//³ MV_PAR18        //  Imprimir com Saldo? 1-Resultado 2-Credor 3-Devedor        ³
	//³ MV_PAR19        //  Eventos? 1-Autorizados 2-Nao Autorizados 3-Ambos          ³
	//³ MV_PAR20        //  Identifica Funcionario? 1-Sim 2-Nao                       ³
	//³ MV_PAR21        //  Identifica tipo de horas? 1-Sexagesimal 2-Centesimal      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lSalta   := ( MV_PAR09 == 1 )	//Imprime C.C em outra Pagina
	lFuncS   := ( MV_PAR10 == 1 )	//Func. Outra Pagina
	lSint    := ( MV_PAR11 == 1 )	//Sintetico ou Analitico
	lImpFil  := ( MV_PAR12 == 1 )	//Imprime Total Filial
	lImpEmp  := ( MV_PAR13 == 1 )	//Imprime Total Empresa
	nImpRel	 := MV_PAR14			//Impr. Eventos (Proventos/Descontos/Ambos) 1-Proventos	2-Descontos	3-Ambos
	dPerIni	 := MV_PAR15			//Periodo De
	dPerFim	 := MV_PAR16			//Periodo Ate
	nHoras	 := 1  //MV_PAR17	 Horas Normais/Valorizadas 1-Normais 	2-Valorizadas
	nSalBH	 := MV_PAR18			// Imprimir com Saldo (Resultado/Credor/Devedor) 1-Resultado	2-Credor 3-Devedor
	nTpEvento:= MV_PAR19			// Imprimir Eventos (Autorizados/N.Autorizados/Ambos) 1-Autorizado	2-N.Autorizado 3-Ambos
	lIdentFu := Iif(MV_PAR20==1,.T.,.F.)	// Imprime somente os totais, ou também as linhas detalhe
	lSexaCent  := .T. //  Iif(MV_PAR21==1,.T.,.F.)		//Horas em  (Sexagesimal/Centesimal)
	cFunction := If(lSexaCent,"TIMESUM","SUM")
	lTotaliza	:= .F.
	nTotal		:= 0
	nTotalv		:= 0
	nAcuAnt		:= 0
	nAcuAntv	:= 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Altera o Titulo do Relatorio conforme o parametro selecionado   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTit 	:= OemToansi(STR0008) + " - " + " ( "+DTOC(MV_PAR15)+" a "+DTOC(MV_PAR16)+" )"
	cTitle 	:= If(AllTrim(oReport:Title())==AllTrim(cTitle),cTit,oReport:Title())
	oReport:SetTitle(cTitle)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Relatorio Sintetico: Totalizacao por Funcionario   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lIdentFu
		If lSexaCent
			DEFINE FUNCTION oFuncDeb   NAME "FUNCDEB"   FROM oSection2:Cell("DEBITO")  	FUNCTION TIMESUM TITLE OemToAnsi(STR0023) 	OF oSection2 PICTURE "@E 99999999.99"; 	//"Debito
			WHEN {||(oSection2:Cell("STATUS"):GetValue()<>"B")}

			DEFINE FUNCTION oFuncDebv   NAME "FUNCDEBV"   FROM oSection2:Cell("DEBITOV")  	FUNCTION TIMESUM TITLE OemToAnsi(STR0023) 	OF oSection2 PICTURE "@E 99999999.99"; 	//"Debito
			WHEN {||(oSection2:Cell("STATUS"):GetValue()<>"B")}

			DEFINE FUNCTION oFuncCred  NAME "FUNCCRED"  FROM oSection2:Cell("CREDITO") 	FUNCTION TIMESUM TITLE OemToAnsi(STR0024)	OF oSection2 PICTURE "@E 99999999.99"; 	//"Credito
			WHEN {||(oSection2:Cell("STATUS"):GetValue()<>"B")}
			DEFINE FUNCTION oFuncCredv  NAME "FUNCCREDV"  FROM oSection2:Cell("CREDITOV") 	FUNCTION TIMESUM TITLE OemToAnsi(STR0024)	OF oSection2 PICTURE "@E 99999999.99"; 	//"Credito
			WHEN {||(oSection2:Cell("STATUS"):GetValue()<>"B")}

			DEFINE FUNCTION oFuncSal2  NAME "FUNCSAL2"  FROM oSection2:Cell("SALDO2") 	FUNCTION TIMESUM TITLE "" 					OF oSection2 PICTURE "@E 99999999.99"	//"Saldo Anterior - NAO SERA IMPRESSO
			DEFINE FUNCTION oFuncSal2v  NAME "FUNCSAL2V"  FROM oSection2:Cell("SALDO2V") 	FUNCTION TIMESUM TITLE "" 					OF oSection2 PICTURE "@E 99999999.99"	//"Saldo Anterior - NAO SERA IMPRESSO

			DEFINE FUNCTION oFuncSal   NAME "FUNCSAL"   FROM oSection2:Cell("SALDO")   FUNCTION ONPRINT TITLE OemToAnsi(STR0036) OF oSection2;								//"Saldo Funcionario
			FORMULA {|| nResult := fTotR100(oSection1,oSection2,lTotaliza,1)	}
			DEFINE FUNCTION oFuncSalv   NAME "FUNCSALV"   FROM oSection2:Cell("SALDOV")   FUNCTION ONPRINT TITLE OemToAnsi(STR0036) OF oSection2;								//"Saldo Funcionario
			FORMULA {|| nResultv := fTotR100(oSection1,oSection2,lTotaliza,2)	}

			oSection2:SetTotalText(OemToAnsi(STR0032))	//"Total por Funcionário"
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³O saldo anterior foi adicionado a uma celula da Section2 no ultimo lancamento do³
			³do funcionario. No entanto, esta celula nao sera impressa.                      ³
			³Isso foi necessario devido a impressao do Total Geral que nao estava saindo     ³
			³correto porque o saldo de cada funcionario esta sendo calculado por funcao.     ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			oSection2:Cell("SALDO2"):Hide(.T.)
			oSection2:Cell("SALDO2V"):Hide(.T.)
			oSection2:Cell("SALDO3"):Hide(.T.)
			oSection2:Cell("SALDO3V"):Hide(.T.)
			oSection2:GetFunction("FUNCSAL2"):Hide(.T.)
			oSection2:GetFunction("FUNCSAL2V"):Hide(.T.)

			If lSint
				//Imprime Somente Totais
				oSection2:Cell("PI_DATA"):SetTitle("")
				oSection2:Cell("PI_PD"):SetTitle("")
				oSection2:Cell("STATUS"):SetTitle("")
			EndIf
		Else
			DEFINE FUNCTION oFuncDeb   NAME "FUNCDEB"   FROM oSection2:Cell("DEBITO")  	FUNCTION SUM TITLE OemToAnsi(STR0023) 	OF oSection2 PICTURE "@E 99999999.99"; 	//"Debito
			WHEN {||(oSection2:Cell("STATUS"):GetValue()<>"B")}
			DEFINE FUNCTION oFuncDebv   NAME "FUNCDEBV"   FROM oSection2:Cell("DEBITOV")  	FUNCTION SUM TITLE OemToAnsi(STR0023) 	OF oSection2 PICTURE "@E 99999999.99"; 	//"Debito
			WHEN {||(oSection2:Cell("STATUS"):GetValue()<>"B")}

			DEFINE FUNCTION oFuncCred  NAME "FUNCCRED"  FROM oSection2:Cell("CREDITO") 	FUNCTION SUM TITLE OemToAnsi(STR0024)	OF oSection2 PICTURE "@E 99999999.99"; 	//"Credito
			WHEN {||(oSection2:Cell("STATUS"):GetValue()<>"B")}
			DEFINE FUNCTION oFuncCredv  NAME "FUNCCREDV"  FROM oSection2:Cell("CREDITOV") 	FUNCTION SUM TITLE OemToAnsi(STR0024)	OF oSection2 PICTURE "@E 99999999.99"; 	//"Credito
			WHEN {||(oSection2:Cell("STATUS"):GetValue()<>"B")}

			DEFINE FUNCTION oFuncSal2  NAME "FUNCSAL2"  FROM oSection2:Cell("SALDO2") 	FUNCTION SUM TITLE "" 					OF oSection2 PICTURE "@E 99999999.99"	//"Saldo Anterior - NAO SERA IMPRESSO
			DEFINE FUNCTION oFuncSal2v  NAME "FUNCSAL2V"  FROM oSection2:Cell("SALDO2V") 	FUNCTION SUM TITLE "" 					OF oSection2 PICTURE "@E 99999999.99"	//"Saldo Anterior - NAO SERA IMPRESSO

			DEFINE FUNCTION oFuncSal   NAME "FUNCSAL"   FROM oSection2:Cell("SALDO")   FUNCTION ONPRINT TITLE OemToAnsi(STR0036) OF oSection2;								//"Saldo Funcionario
			FORMULA {|| nResult := fTotR100(oSection1,oSection2,lTotaliza,1)	}
			DEFINE FUNCTION oFuncSalv   NAME "FUNCSALV"   FROM oSection2:Cell("SALDOV")   FUNCTION ONPRINT TITLE OemToAnsi(STR0036) OF oSection2;								//"Saldo Funcionario
			FORMULA {|| nResultv := fTotR100(oSection1,oSection2,lTotaliza,2)	}

			oSection2:SetTotalText(OemToAnsi(STR0032))	//"Total por Funcionário"
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³O saldo anterior foi adicionado a uma celula da Section2 no ultimo lancamento do³
			³do funcionario. No entanto, esta celula nao sera impressa.                      ³
			³Isso foi necessario devido a impressao do Total Geral que nao estava saindo     ³
			³correto porque o saldo de cada funcionario esta sendo calculado por funcao.     ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			oSection2:Cell("SALDO2"):Hide(.T.)
			oSection2:Cell("SALDO2V"):Hide(.T.)
			oSection2:Cell("SALDO3"):Hide(.T.)
			oSection2:Cell("SALDO3V"):Hide(.T.)
			oSection2:GetFunction("FUNCSAL2"):Hide(.T.)
			oSection2:GetFunction("FUNCSAL2V"):Hide(.T.)

			If lSint
				//Imprime Somente Totais
				oSection2:Cell("PI_DATA"):SetTitle("")
				oSection2:Cell("PI_PD"):SetTitle("")
				oSection2:Cell("STATUS"):SetTitle("")
			EndIf
		EndIf
	EndIf

	If lImpFil
		If lSexaCent
			oBreakFil := TRBreak():New(oReport,{|| SRA->RA_FILIAL },{|| STR0027 + " : " +SRA->RA_FILIAL } )	//"Total por Filial"

			DEFINE FUNCTION oBcFilDeb   NAME "BCFILDEB"   FROM oSection2:Cell("DEBITO")		FUNCTION TIMESUM	BREAK oBreakFil TITLE OemToAnsi(STR0023)	OF oSection2 PICTURE "@E 99999999.99"	NO END SECTION NO END REPORT ;	//"Debito
			WHEN {||(oSection2:Cell("STATUS"):GetValue()<>"B")}
			DEFINE FUNCTION oBcFilDebv   NAME "BCFILDEBV"   FROM oSection2:Cell("DEBITOV")		FUNCTION TIMESUM	BREAK oBreakFil TITLE OemToAnsi(STR0023)	OF oSection2 PICTURE "@E 99999999.99"	NO END SECTION NO END REPORT ;	//"Debito
			WHEN {||(oSection2:Cell("STATUS"):GetValue()<>"B")}

			DEFINE FUNCTION oBcFilCred  NAME "BCFILCRED"  FROM oSection2:Cell("CREDITO")	FUNCTION TIMESUM	BREAK oBreakFil	TITLE OemToAnsi(STR0024)	OF oSection2 PICTURE "@E 99999999.99"	NO END SECTION NO END REPORT ;	//"Credito
			WHEN {||(oSection2:Cell("STATUS"):GetValue()<>"B")}
			DEFINE FUNCTION oBcFilCredv  NAME "BCFILCREDV"  FROM oSection2:Cell("CREDITOV")	FUNCTION TIMESUM	BREAK oBreakFil	TITLE OemToAnsi(STR0024)	OF oSection2 PICTURE "@E 99999999.99"	NO END SECTION NO END REPORT ;	//"Credito
			WHEN {||(oSection2:Cell("STATUS"):GetValue()<>"B")}

			DEFINE FUNCTION oBcFilSal2  NAME "BCFILSAL2"  FROM oSection2:Cell("SALDO2") 	FUNCTION TIMESUM	BREAK oBreakFil	TITLE ""					OF oSection2 PICTURE "@E 99999999.99"	NO END SECTION NO END REPORT 	//"Saldo Anterior (NAO SERA IMPRESSO)
			DEFINE FUNCTION oBcFilSal2v  NAME "BCFILSAL2V"  FROM oSection2:Cell("SALDO2V") 	FUNCTION TIMESUM	BREAK oBreakFil	TITLE ""					OF oSection2 PICTURE "@E 99999999.99"	NO END SECTION NO END REPORT 	//"Saldo Anterior (NAO SERA IMPRESSO)

			DEFINE FUNCTION oBcFilSal   NAME "BCFILSAL"   FROM oSection2:Cell("SALDO")   	FUNCTION ONPRINT	BREAK oBreakFil	TITLE OemToAnsi(STR0034)	OF oSection2							NO END SECTION NO END REPORT  ;	//"Saldo Filial
			FORMULA {|lSection,lReport,lPage| 	nBcFlCrTt := Iif(!Empty(oSection2:GetFunction("BCFILCRED"):GetLastValue()),oSection2:GetFunction("BCFILCRED"):GetLastValue(),0), ;
			nBcFlDbTt := Iif(!Empty(oSection2:GetFunction("BCFILDEB" ):GetLastValue()),oSection2:GetFunction("BCFILDEB" ):GetLastValue(),0), ;
			nSdFilAnt := Iif(!Empty(oSection2:Cell("SALDO2"):GetValue()),oSection2:Cell("SALDO3"):GetValue(),0), ;
			If( !Empty(nSdFilAnt), __TimeSum(nSdFilAnt,__TimeSub(nBcFlCrTt,nBcFlDbTt)),__TimeSub(nBcFlCrTt,nBcFlDbTt)) }

			DEFINE FUNCTION oBcFilSalv   NAME "BCFILSALV"   FROM oSection2:Cell("SALDOV")   	FUNCTION ONPRINT	BREAK oBreakFil	TITLE OemToAnsi(STR0034)	OF oSection2						NO END SECTION NO END REPORT  ;	//"Saldo Filial
			FORMULA {|lSection,lReport,lPage| 	nBcFlCrTtv := Iif(!Empty(oSection2:GetFunction("BCFILCREDV"):GetLastValue()),oSection2:GetFunction("BCFILCREDV"):GetLastValue(),0), ;
			nBcFlDbTtv := Iif(!Empty(oSection2:GetFunction("BCFILDEBV" ):GetLastValue()),oSection2:GetFunction("BCFILDEBV" ):GetLastValue(),0), ;
			nSdFilAntv := Iif(!Empty(oSection2:Cell("SALDO2V"):GetValue()),oSection2:Cell("SALDO3V"):GetValue(),0), ;
			If( !Empty(nSdFilAntv), __TimeSum(nSdFilAntv,__TimeSub(nBcFlCrTtv,nBcFlDbTtv)),__TimeSub(nBcFlCrTtv,nBcFlDbTtv)) }

			oSection2:Cell("SALDO2"):Hide(.T.)
			oSection2:Cell("SALDO2V"):Hide(.T.)
			oSection2:Cell("SALDO3"):Hide(.T.)
			oSection2:Cell("SALDO3V"):Hide(.T.)
			oSection2:GetFunction("BCFILSAL2"):Hide(.T.)
			oSection2:GetFunction("BCFILSAL2V"):Hide(.T.)

			oBreakFil:OnBreak({|x,y|cTitFil:=OemToAnsi(STR0011)+x,oReport:ThinLine()})	//"TOTAL FILIAL  "
			oBreakFil:SetTotalText({||cTitFil})
		Else
			oBreakFil := TRBreak():New(oReport,{|| SRA->RA_FILIAL },{|| STR0027 + " : " +SRA->RA_FILIAL } )	//"Total por Filial"

			DEFINE FUNCTION oBcFilDeb   NAME "BCFILDEB"   FROM oSection2:Cell("DEBITO")		FUNCTION SUM	BREAK oBreakFil TITLE OemToAnsi(STR0023)	OF oSection2 PICTURE "@E 99999999.99"	NO END SECTION NO END REPORT ;	//"Debito
			WHEN {||(oSection2:Cell("STATUS"):GetValue()<>"B")}
			DEFINE FUNCTION oBcFilDebv   NAME "BCFILDEBV"   FROM oSection2:Cell("DEBITOV")		FUNCTION SUM	BREAK oBreakFil TITLE OemToAnsi(STR0023)	OF oSection2 PICTURE "@E 99999999.99"	NO END SECTION NO END REPORT ;	//"Debito
			WHEN {||(oSection2:Cell("STATUS"):GetValue()<>"B")}

			DEFINE FUNCTION oBcFilCred  NAME "BCFILCRED"  FROM oSection2:Cell("CREDITO")	FUNCTION SUM	BREAK oBreakFil	TITLE OemToAnsi(STR0024)	OF oSection2 PICTURE "@E 99999999.99"	NO END SECTION NO END REPORT ;	//"Credito
			WHEN {||(oSection2:Cell("STATUS"):GetValue()<>"B")}
			DEFINE FUNCTION oBcFilCredv  NAME "BCFILCREDV"  FROM oSection2:Cell("CREDITOV")	FUNCTION SUM	BREAK oBreakFil	TITLE OemToAnsi(STR0024)	OF oSection2 PICTURE "@E 99999999.99"	NO END SECTION NO END REPORT ;	//"Credito
			WHEN {||(oSection2:Cell("STATUS"):GetValue()<>"B")}

			DEFINE FUNCTION oBcFilSal2  NAME "BCFILSAL2"  FROM oSection2:Cell("SALDO2") 	FUNCTION SUM	BREAK oBreakFil	TITLE ""					OF oSection2 PICTURE "@E 99999999.99"	NO END SECTION NO END REPORT 	//"Saldo Anterior (NAO SERA IMPRESSO)
			DEFINE FUNCTION oBcFilSal2v  NAME "BCFILSAL2V"  FROM oSection2:Cell("SALDO2V") 	FUNCTION SUM	BREAK oBreakFil	TITLE ""					OF oSection2 PICTURE "@E 99999999.99"	NO END SECTION NO END REPORT 	//"Saldo Anterior (NAO SERA IMPRESSO)

			DEFINE FUNCTION oBcFilSal   NAME "BCFILSAL"   FROM oSection2:Cell("SALDO")   	FUNCTION ONPRINT	BREAK oBreakFil	TITLE OemToAnsi(STR0034)	OF oSection2							NO END SECTION NO END REPORT  ;	//"Saldo Filial
			FORMULA {|lSection,lReport,lPage| 	nBcFlCrTt := Iif(!Empty(oSection2:GetFunction("BCFILCRED"):GetLastValue()),oSection2:GetFunction("BCFILCRED"):GetLastValue(),0), ;
			nBcFlDbTt := Iif(!Empty(oSection2:GetFunction("BCFILDEB" ):GetLastValue()),oSection2:GetFunction("BCFILDEB" ):GetLastValue(),0), ;
			nSdFilAnt := Iif(!Empty(oSection2:Cell("SALDO2"):GetValue()),oSection2:Cell("SALDO3"):GetValue(),0), ;
			If( !Empty(nSdFilAnt),((nSdFilAnt)+(nBcFlCrTt-nBcFlDbTt)),(nBcFlCrTt-nBcFlDbTt)) }

			DEFINE FUNCTION oBcFilSalv   NAME "BCFILSALV"   FROM oSection2:Cell("SALDOV")   	FUNCTION ONPRINT	BREAK oBreakFil	TITLE OemToAnsi(STR0034)	OF oSection2							NO END SECTION NO END REPORT  ;	//"Saldo Filial
			FORMULA {|lSection,lReport,lPage| 	nBcFlCrTtv := Iif(!Empty(oSection2:GetFunction("BCFILCREDV"):GetLastValue()),oSection2:GetFunction("BCFILCREDV"):GetLastValue(),0), ;
			nBcFlDbTtv := Iif(!Empty(oSection2:GetFunction("BCFILDEBV" ):GetLastValue()),oSection2:GetFunction("BCFILDEBV" ):GetLastValue(),0), ;
			nSdFilAntv := Iif(!Empty(oSection2:Cell("SALDO2V"):GetValue()),oSection2:Cell("SALDO3V"):GetValue(),0), ;
			If( !Empty(nSdFilAntv),((nSdFilAntv)+(nBcFlCrTtv-nBcFlDbTtv)),(nBcFlCrTtv-nBcFlDbTtv)) }

			oSection2:Cell("SALDO2"):Hide(.T.)
			oSection2:Cell("SALDO2V"):Hide(.T.)
			oSection2:Cell("SALDO3"):Hide(.T.)
			oSection2:Cell("SALDO3V"):Hide(.T.)
			oSection2:GetFunction("BCFILSAL2"):Hide(.T.)
			oSection2:GetFunction("BCFILSAL2V"):Hide(.T.)

			oBreakFil:OnBreak({|x,y|cTitFil:=OemToAnsi(STR0011)+x,oReport:ThinLine()})	//"TOTAL FILIAL  "
			oBreakFil:SetTotalText({||cTitFil})
		EndIf

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Transforma parametros Range em expressao (intervalo) ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MakeAdvplExpr("PN100R")

	If !Empty(MV_PAR01)	//RA_FILIAL
		cFiltroSRA:= MV_PAR01
	EndIf

	If !Empty(MV_PAR02)	//RA_CC
		cFiltroSRA += Iif(!Empty(cFiltroSRA)," .AND. ","")
		cFiltroSRA += MV_PAR02
	EndIf

	If !Empty(MV_PAR03) //RA_MAT
		cFiltroSRA += Iif(!Empty(cFiltroSRA)," .AND. ","")
		cFiltroSRA += MV_PAR03
	EndIf

	If !Empty(MV_PAR04) //RA_NOME
		cFiltroSRA += Iif(!Empty(cFiltroSRA)," .AND. ","")
		cFiltroSRA += MV_PAR04
	EndIf

	If !Empty(MV_PAR05) //RA_TNOTRAB
		cFiltroSRA += Iif(!Empty(cFiltroSRA)," .AND. ","")
		cFiltroSRA += MV_PAR05
	EndIf

	If !Empty(MV_PAR06) //RA_REGRA
		cFiltroSRA += Iif(!Empty(cFiltroSRA)," .AND. ","")
		cFiltroSRA += MV_PAR06
	EndIf

	If !Empty(MV_PAR07)
		cFiltroSRA += Iif(!Empty(cFiltroSRA)," .AND. ","")
		cFiltroSRA += 'RA_SITFOLH $ "' + MV_PAR07 + '"'  //Situacao do Funcionario
	EndIf

	If !Empty(MV_PAR08)
		cFiltroSRA += Iif(!Empty(cFiltroSRA)," .And. ","")
		cFiltroSRA += 'RA_CATFUNC $ "' + MV_PAR08 + '"'	//Categoria do Funcionario
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtro para a Tabela Principal da Secao Pai  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection1:SetFilter(cFiltroSRA)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ordem do Relatorio   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOrdem == 1
		oSection1:SetIdxOrder(1)	//Matricula
	ElseIf nOrdem == 2
		oSection1:SetIdxOrder(2)	//Centro de Custo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Totalizacao por Centro de Custo ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oBreakCC := TRBreak():New(oReport,{|| SRA->RA_CC },,.f.,,.f.)	//"Total por Centro de Custo"
		oBreakCC:OnBreak({|x,y|cTitCC:=OemToAnsi(STR0029)+" - "+fCarrCentro(x) })	//"Total por Centro de Custo - CC"
		oBreakCC:SetTotalText({||cTitCC})

		TRFunction():New(oSection2:Cell("DEBITO" ),"DEBITO",cFunction,oBreakCC,/*cTitle*/,/*cPicture*/, {||(oSection2:Cell("STATUS"):GetValue()<>"B")} /*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
		TRFunction():New(oSection2:Cell("DEBITOV" ),"DEBITOV",cFunction,oBreakCC,/*cTitle*/,/*cPicture*/, {||(oSection2:Cell("STATUS"):GetValue()<>"B")} /*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
		TRFunction():New(oSection2:Cell("CREDITO"),"CREDITO",cFunction,oBreakCC,/*cTitle*/,/*cPicture*/,{||(oSection2:Cell("STATUS"):GetValue()<>"B")} /*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
		TRFunction():New(oSection2:Cell("CREDITOV"),"CREDITOV",cFunction,oBreakCC,/*cTitle*/,/*cPicture*/,{||(oSection2:Cell("STATUS"):GetValue()<>"B")} /*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)

		TRFunction():New(oSection2:Cell("SALDO"  ),/*cId*/,"ONPRINT",oBreakCC,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
		TRFunction():New(oSection2:Cell("SALDOV"  ),/*cId*/,"ONPRINT",oBreakCC,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)

		If lSalta
			oBreakCC:SetPageBreak(.T.) //Salta Pagina  
		EndIf
	ElseIf nOrdem == 3
		oSection1:SetIdxOrder(3)	//Nome
	ElseIf nOrdem == 4
		oSection1:SetIdxOrder(8)	//Centro de Custo + Nome
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Totalizacao por Centro de Custo ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oBreakCC := TRBreak():New(oReport,{|| SRA->RA_CC },,.f.,,.f. )	//"Total por Centro de Custo"
		TRFunction():New(oSection2:Cell("DEBITO" ),"DEBITO" ,cFunction,oBreakCC,/*cTitle*/,/*cPicture*/, {||(oSection2:Cell("STATUS"):GetValue()<>"B")} /*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
		TRFunction():New(oSection2:Cell("DEBITOV" ),"DEBITOV" ,cFunction,oBreakCC,/*cTitle*/,/*cPicture*/, {||(oSection2:Cell("STATUS"):GetValue()<>"B")} /*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
		TRFunction():New(oSection2:Cell("CREDITO"),"CREDITO",cFunction,oBreakCC,/*cTitle*/,/*cPicture*/, {||(oSection2:Cell("STATUS"):GetValue()<>"B")}/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
		TRFunction():New(oSection2:Cell("CREDITOV"),"CREDITOV",cFunction,oBreakCC,/*cTitle*/,/*cPicture*/, {||(oSection2:Cell("STATUS"):GetValue()<>"B")}/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
		TRFunction():New(oSection2:Cell("SALDO"  ),/*cId*/,"ONPRINT",oBreakCC,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
		TRFunction():New(oSection2:Cell("SALDOV"  ),/*cId*/,"ONPRINT",oBreakCC,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)

		If lSalta
			oBreakCC:SetPageBreak(.T.) //Salta Pagina
		EndIf

		oBreakCC:OnBreak({|x,y|cTitCC:=OemToAnsi(STR0029)+" - "+fCarrCentro(x),oReport:ThinLine()})	//"Total por Centro de Custo - CC"
		oBreakCC:SetTotalText({||cTitCC})
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime Funcionario em Outra Pagina ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lFuncS .And. lIdentFu
		oBreakFunc := TRBreak():New(oReport,{|| SRA->RA_MAT },{|| STR0019 + " "+ SRA->RA_MAT } )
		oBreakFunc:SetPageBreak(.T.) //Salta Pagina
	EndIf

	dbSetOrder(oSection1:nIdxOrder)

	dbSelectArea( "SRA" )
	dbGoTop()

	While !EOF()

		oReport:IncMeter()

		If oReport:Cancel()
			Exit
		EndIf

		// Totalizador do Saldo
		nSaldo    := 0
		nSaldov    := 0
		nSaldoAnt := 0
		nSaldoAntv := 0
		lPrimeira := .T.
		aLanca    := {}
		aLancav    := {}
		nValor	  := 0
		nValorv   := 0
		dDataAux  := CTOD(SPACE(8))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica lancamentos no Banco de Horas                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea( "SPI" )
		dbSetOrder(2)
		dbSeek( SRA->RA_FILIAL + SRA->RA_MAT )
		While SPI->( !Eof() .and. PI_FILIAL+PI_MAT == SRA->( RA_FILIAL+RA_MAT ) )

			//-- Verifica tipo de Evento quando for diferente de Ambos
			If nTpEvento <> 3
				If !fBscEven(SPI->PI_PD,2,nTpEvento)
					SPI->(dbSkip())
					Loop
				EndIf
			Else
				PosSP9(SPI->PI_PD,SRA->RA_FILIAL,"P9_TIPOCOD")
			Endif

			// Totaliza Saldo Anterior
			If SPI->PI_DATA < dPerIni
				If SP9->P9_TIPOCOD $  "1*3"
					If nImpRel == 1 .Or. nImpRel == 3
						nValor:=If(SPI->PI_STATUS=="B",0,If(nHoras=1,SPI->PI_QUANT,SPI->PI_QUANTV))
						nValorv:=If(SPI->PI_STATUS=="B",0,SPI->PI_QUANTV)
						//-- Para valor nao nulo considera a Data para Referencia do Saldo
						dDataAux:=If(Empty(nValor),dDataAux,SPI->PI_DATA)
						If lSexaCent
							nSaldoAnt:=__TimeSum(nSaldoAnt,nValor)
							nSaldoAntv:=__TimeSum(nSaldoAntv,nValorv)
						Else
							nSaldoAnt:=nSaldoAnt + nValor
							nSaldoAntv:=nSaldoAntv + nValorv
						EndIf
					Endif
				Else
					If nImpRel == 2 .Or. nImpRel == 3
						nValor:=If(SPI->PI_STATUS=="B",0,If(nHoras=1,SPI->PI_QUANT,SPI->PI_QUANTV))
						nValorv:=If(SPI->PI_STATUS=="B",0,SPI->PI_QUANTV)
						//-- Para valor nao nulo considera a Data para Referencia do Saldo
						dDataAux:=If(Empty(nValor),dDataAux,SPI->PI_DATA)
						If lSexaCent
							nSaldoAnt:=__TimeSub(nSaldoAnt,nValor)
							nSaldoAntv:=__TimeSub(nSaldoAntv,nValorv)
						Else
							nSaldoAnt:=nSaldoAnt - nValor
							nSaldoAntv:=nSaldoAntv - nValorv
						EndIf
					Endif
				Endif
				nSaldo   := nSaldoAnt
				nSaldov   := nSaldoAntv
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica os Lancamentos a imprimir                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If	SPI->PI_DATA < dPerIni .Or. SPI->PI_DATA > dPerFim
				nAcuAnt	 +=	nSaldo
				nAcuAntv +=	nSaldov
				dbSkip()
				Loop
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Acumula os lancamentos de Proventos/Desconto em Array        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			FSomaR4(@aLanca,@aLancav,1)	// Funcionario

			dbSelectArea( "SPI" )
			dbSkip()

		Enddo

		dbSelectArea( "SRA" )

		//-- Se nao houve movimento no periodo sera comparado o tipo de saldo (credito ou debito
		//-- com o saldo anterior
		//-- Senao sera comparado o resultado do mes
		If	Len(aLanca) == 0
			nSaldComp:= nSaldoAnt
			nSaldCompv:= nSaldoAntv
		Else
			nSaldComp:= aLanca[Len(aLanca),5]
			nSaldCompv:= aLancav[Len(aLancav),5]
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime Funcionarios                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( nSalBH == 1  .Or. (nSalBH == 2 .And. nSaldComp >= 0) .Or. (nSalBH == 3 .And. nSaldComp < 0))
			fImpFunR4(@aLanca,@aLancav,oReport,.F.)
		Endif

		dbSelectArea( "SRA" )
		dbSkip()

	Enddo
	lTotaliza	:= .T.

	dbSetOrder(1)
	Return Nil

	*---------------------------------*
Static Function FSomaR4(aLanca,aLancav,nTipo)      		// Acumula Lancamentos
	*---------------------------------*
	Private nPos:=0
	DEFAULT lSexaCent := .T.

	IF SP9->( P9_TIPOCOD $ "1*3" .and. nImpRel == 2 .or. P9_TIPOCOD == "2" .and. nImpRel == 1  )
		Return( NIL )
	EndIF

	If nTipo > 1 .And. (nPos:=aScan(aLanca,{ |x| x[2] == SPI->PI_PD })) > 0
		If SPI->PI_STATUS <> "B"
			If SP9->P9_TIPOCOD $ "1*3"
				If lSexaCent
					aLanca[nPos,4] := __TimeSum(aLanca[nPos,4],If(nHoras==1,SPI->PI_QUANT,SPI->PI_QUANTV))
					aLancav[nPos,4] := __TimeSum(aLancav[nPos,4],SPI->PI_QUANTV)
				Else
					aLanca[nPos,4]  := (aLanca[nPos,4])  + (If(nHoras==1,SPI->PI_QUANT,SPI->PI_QUANTV))
					aLancav[nPos,4] := (aLancav[nPos,4]) + (SPI->PI_QUANTV)
				EndIf
			Else
				If lSexaCent
					aLanca[nPos,3]  := __TimeSum(aLanca[nPos,3] ,If(nHoras==1,SPI->PI_QUANT,SPI->PI_QUANTV))
					aLancav[nPos,3] := __TimeSum(aLancav[nPos,3],SPI->PI_QUANTV)
				Else
					aLanca[nPos,3] := fConvHr((aLanca[nPos,3]) + (If(nHoras==1,SPI->PI_QUANT,SPI->PI_QUANTV)),'D',,3)
					aLancav[nPos,3] := fConvHr((aLancav[nPos,3]) + (SPI->PI_QUANTV),'D',,3)
				EndIf
			Endif
		Endif
	Else
		aAdd(aLanca ,{})
		aAdd(aLanca[Len(aLanca)],SPI->PI_DATA)
		aAdd(aLanca[Len(aLanca)],SPI->PI_PD)

		aAdd(aLancav ,{})
		aAdd(aLancav[Len(aLancav)],SPI->PI_DATA)
		aAdd(aLancav[Len(aLancav)],SPI->PI_PD)
		If SP9->P9_TIPOCOD $ "1*3"
			If nTipo == 1
				If lSexaCent
					nSaldo := __TimeSum(nSaldo ,If(SPI->PI_STATUS=="B",0,If(nHoras==1,SPI->PI_QUANT,SPI->PI_QUANTV)))
					nSaldov:= __TimeSum(nSaldov,If(SPI->PI_STATUS=="B",0,SPI->PI_QUANTV))
				Else
					nSaldo := (nSaldo) + (If(SPI->PI_STATUS=="B",0,fConvHr(If(nHoras==1,SPI->PI_QUANT,SPI->PI_QUANTV),'D',,3)))
					nSaldov:= (nSaldov) + (If(SPI->PI_STATUS=="B",0,fConvHr(SPI->PI_QUANTV,'D',,3)))
				EndIf
			Endif
			aAdd(aLanca[Len(aLanca)],0.00)
			aAdd(aLancav[Len(aLancav)],0.00)

			If nTipo > 1 .And. SPI->PI_STATUS == "B"
				aAdd(aLanca[Len(aLanca)],0.00)
				aAdd(aLancav[Len(aLancav)],0.00)
			Else
				If (lSexaCent != .T.)
					aAdd(aLanca[Len(aLanca)],fConvHr(If(nHoras==1,SPI->PI_QUANT,SPI->PI_QUANTV),'D',,3))
					aAdd(aLancav[Len(aLancav)],fConvHr(SPI->PI_QUANTV,'D',,3))
				Else
					aAdd(aLanca[Len(aLanca)],If(nHoras==1,SPI->PI_QUANT,SPI->PI_QUANTV))
					aAdd(aLancav[Len(aLancav)],SPI->PI_QUANTV)
				EndIf
			Endif

			aAdd(aLanca[Len(aLanca)],nSaldo)
			aAdd(aLancav[Len(aLancav)],nSaldov)
		Else
			If nTipo == 1
				If lSexaCent
					nSaldo:=__TimeSub(nSaldo,If(SPI->PI_STATUS=="B",0,If(nHoras==1,SPI->PI_QUANT,SPI->PI_QUANTV)))
					nSaldov:=__TimeSub(nSaldov,If(SPI->PI_STATUS=="B",0,SPI->PI_QUANTV))
				Else
					nSaldo :=(nSaldo)  - (If(SPI->PI_STATUS=="B",0,fConvHr(If(nHoras==1,SPI->PI_QUANT,SPI->PI_QUANTV),'D',,3)))
					nSaldov:=(nSaldov) - (If(SPI->PI_STATUS=="B",0,fConvHr(SPI->PI_QUANTV,'D',,3)))
				EndIf
			Endif

			If nTipo > 1 .And. SPI->PI_STATUS == "B"
				aAdd(aLanca[Len(aLanca)],0.00)
				aAdd(aLancav[Len(aLancav)],0.00)
			Else
				If lSexaCent
					aAdd(aLanca[Len(aLanca)],If(nHoras==1,SPI->PI_QUANT,SPI->PI_QUANTV))
					aAdd(aLancav[Len(aLancav)],SPI->PI_QUANTV)
				Else
					aAdd(aLanca[Len(aLanca)],fConvHr(If(nHoras==1,SPI->PI_QUANT,SPI->PI_QUANTV),'D',,3))
					aAdd(aLancav[Len(aLancav)],fConvHr(SPI->PI_QUANTV,'D',,3))
				EndIf
			Endif

			aAdd(aLanca[Len(aLanca)],0.00)
			aAdd(aLancav[Len(aLancav)],0.00)
			aAdd(aLanca[Len(aLanca)],nSaldo)
			aAdd(aLancav[Len(aLancav)],nSaldov)
		Endif
		aAdd(aLanca[Len(aLanca)],If(nTipo==1,SPI->PI_STATUS," "))	//
		aAdd(aLancav[Len(aLancav)],If(nTipo==1,SPI->PI_STATUS," "))	//
	Endif

	Return Nil

	*-----------------------------*
Static Function fImpFunR4(aLanca,aLancav,oReport)            // Imprime um Funcionario
	*-----------------------------*
	If	Len(aLanca) == 0 .AND. EMPTY(nSaldoAnt)
		Return Nil
	Endif

	fImprimeR4(aLanca,aLancav,oReport)

	aLanca := {}
	aLancav := {}

	Return Nil

	*-----------------------------------------------*
Static Function fImprimeR4(aLanca,aLancav,oReport)
	*-----------------------------------------------*
	// nTipo: 1- Funcionario
	//        2- Centro de Custo
	//        3- Filial
	//        4- Empresa

	Local nConta := 0
	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(1):Section(1)
	Local nQtdLanc  := 0

	oSection1:Init()
	oSection1:Cell("SALDOANT"):SetValue(nSaldoAnt)
	oSection1:Init()
	oSection1:Cell("SALDOANTV"):SetValue(nSaldoAntv)

	If !lIdentFu
		oSection2:SetHeaderBreak(.F.)
		oSection1:SetHeaderBreak(.F.)
		oSection1:Cell("RA_FILIAL"):Disable(.T.)
		oSection1:Cell("RA_MAT"):Disable(.T.)
		oSection1:Cell("RA_NOME"):Disable(.T.)
		oSection1:Cell("SALDOANT"):Disable(.T.)
		oSection1:Cell("SALDOANTV"):Disable(.T.)
	EndIf

	oSection1:PrintLine()

	oSection1:Finish()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime identificacao do Funcionario ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lIdentFu //Nao imprime detalhe do Funcionario ou Sintetico
		oSection2:Hide()
		oSection2:Cell("PI_DATA"):SetTitle("")
		oSection2:Cell("PI_PD"):SetTitle("")
		oSection2:Cell("STATUS"):SetTitle("")
		oSection2:SetHeaderBreak(.T.)
	EndIf

	oSection2:Init()

	nQtdLanc := Len(aLanca)

	For nConta :=1 TO nQtdLanc
		oSection2:Cell("PI_DATA"	):SetValue(aLanca[nConta,1])
		oSection2:Cell("PI_DATA"	):SetTitle("")
		oSection2:Cell("PI_PD"		):SetValue(aLanca[nConta,2])
		oSection2:Cell("PI_PD"		):SetTitle("")
		oSection2:Cell("P9_DESC"	):SetValue(Left(DescPdPon(aLanca[nConta,2],SRA->RA_FILIAL),20))
		oSection2:Cell("P9_DESC"	):SetTitle("")
		oSection2:Cell("DEBITO"		):SetValue(aLanca[nConta,3])
		oSection2:Cell("DEBITOV"	):SetValue(aLancav[nConta,3])
		oSection2:Cell("CREDITO"	):SetValue(aLanca[nConta,4])
		oSection2:Cell("CREDITOV"	):SetValue(aLancav[nConta,4])
		oSection2:Cell("SALDO"		):SetValue(aLanca[nConta,5])
		oSection2:Cell("SALDOV"		):SetValue(aLancav[nConta,5])
		oSection2:Cell("STATUS"		):SetValue(If(aLanca[nConta,6]=="B",STR0030,STR0031)) //"Baixado"#"Pendente"
		oSection2:Cell("STATUS"		):SetTitle("")

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³O saldo anterior foi adicionado ao ultimo lancamento do funcionario.            ³
		³Isso foi necessario devido para que a impressao do Total Geral saia correta     ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

		If nQtdLanc == nConta
			oSection2:Cell("SALDO2"	):SetValue(nSaldoAnt)
			oSection2:Cell("SALDO2V"):SetValue(nSaldoAntv)
		Else
			oSection2:Cell("SALDO2"):SetValue(0)
			oSection2:Cell("SALDO2V"):SetValue(0)
		EndIf

		oSection2:Cell("SALDO3"	):SetValue( IF(!Empty(oSection2:Cell("SALDO3"	):GetValue()),oSection2:Cell("SALDO3"	):GetValue() + oSection2:Cell("SALDO2"	):GetValue(),oSection2:Cell("SALDO2"	):GetValue()))
		oSection2:Cell("SALDO3V"):SetValue( IF(!Empty(oSection2:Cell("SALDO3V"	):GetValue()),oSection2:Cell("SALDO3V"	):GetValue() + oSection2:Cell("SALDO2V"	):GetValue(),oSection2:Cell("SALDO2V"	):GetValue()))

		IF lSint
			oSection2:Hide()
		Endif
		oSection2:PrintLine()
	Next nConta

	oSection2:Finish()

Return Nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄT¿
//³Funcao para retornar a descricao do centro de custo na quebra da pagina.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄTÙ
Static Function fCarrCentro(cCodCCusto)

Return( cCodCCusto + " "+Left(DescCC(cCodCCusto),20) )

/*
PROGRAMA FONTE ORIGINAL ABAIXO
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PONR100R3³ Autor ³ Aldo Marini Junior      ³ Data ³ 09.12.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Banco de Horas                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PONR100R3(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aldo	  	   ³ 30/03/99 ³------³ Passagem de nTamanho para SetPrint().    ³±±
±±³Aldo	  	   ³ 10/09/99 ³05622A³ Incluido ordem de C.Custo+Nome           ³±±
±±³Aldo	  	   ³ 18/10/99 ³------³ Inclusao de pergunta para selecao de     ³±±
±±³   	  	   ³          ³------³ eventos autorizados/N.autorizados/Ambos  ³±±
±±³Alexsandro  ³ 09/05/00 ³------³ Remocao do codigo DOS.                   ³±±
±±³Alexsandro  ³ 03/08/00 ³------³ Remocao da validperg().                  ³±±
±±³Alexsandro  ³ 03/08/00 ³------³ Implementacao controle de acesso.        ³±±
±±³Marinaldo   ³ 29/08/00 ³------³ Inclusao de PosSP9 p/ verif. Tipo do Eve.³±±
±±³Marinaldo   ³ 23/08/01 ³------³ Substituicao da Funcao SomaHoras() e  Sub³±±
±±³            ³ -------- ³------³ Horas() em AdvPl pelas suas  corresponden³±±
±±³            ³ -------- ³------³ tes em C++ __TimeSum() e __TimeSub().    ³±±
±±³Mauricio MR ³ 05/09/01 ³------³ Correcao Impressao de Saldo mesmo se o   ³±±
±±³            ³          ³      ³ funcionario nao possuir movimento nos mes³±±
±±³            ³          ³      ³ e inclusao da data do saldo anterior.    ³±±
±±³Mauricio MR ³ 17/12/01 ³Acerto³ Correcao erro ao tentar imprimir func.sem³±±
±±³            ³          ³      ³ movimento no periodo e tipo saldo diferen³±±
±±³            ³          ³      ³ te de resultado. Agora, se nao houver mo-³±±
±±³            ³          ³      ³ vimentacao no periodo, sera comparado o  ³±±
±±³            ³          ³      ³ saldo anterior com o tipo escolhido.     ³±±
±±³Mauricio MR ³ 14/03/02 ³Acerto³ Correcao Calculo do Saldo em SomaSaldo.  ³±±
±±³            ³          ³      ³ Verificava-se o Tipo do Evento de acordo ³±±
±±³            ³          ³      ³ com o especificado pelo registro do SP9. ³±±
±±³            ³          ³      ³ No entanto, nao era preciso, alem de nao ³±±
±±³            ³          ³      ³ estar posicionado corretamente no SP9 de ³±±
±±³            ³          ³      ³ acordo com o codigo do aArray lido.      ³±±
±±³ Priscila R.³ 28/05/02 ³------³Ajuste no relatorio para que seja impresso³±±
±±³            ³ -------- ³------³corretamente o C.C no tamanho 20.         ³±±
±±³Tania       ³24/08/2005³084626³ Incluida condicao de impressao do relato-³±±
±±³            ³ -------- ³------³ rio somente com os totais, sem a impres- ³±±
±±³            ³ -------- ³------³ sao da linha detalhe com o funcionario.  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PNR100Imp³ Autor ³ R.H. - Ze Maria       ³ Data ³ 03.03.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Banco de Horas                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ PNR100Imp(lEnd,wnRel,cString)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd        - A‡Æo do Codelock                             ³±±
±±³          ³ wnRel       - T¡tulo do relat¢rio                          ³±±
±±³Parametros³ cString     - Mensagem                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PNR100Imp(lEnd,WnRel,cString)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis Locais (Basicas)                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aLancaE   := {}
	Local aLancaF   := {}
	Local aLancaC   := {}
	Local aSomaE    := {}
	Local aSomaF    := {}
	Local aSomaC    := {}
	Local aLanca    := {}
	Local cAcessaSRA:= &("{ || " + ChkRH("PONR100","SRA","2") + "}")
	Local nValor	:=	0 //-- Variavel auxiliar para calculo do Saldo Anterior
	Local nSaldComp := 0  //-- Variavel auxiliar para comparacao de saldo

	Private nSaldo	  := 0
	Private nSaldoAnt := 0
	Private nSaldoAC  := 0
	Private nSaldoAF  := 0
	Private nSaldoAE  := 0
	Private lRoda	  := .F.
	Private dDataAux  := Ctod('') 	//-- Variavel auxiliar para armazenar a ultima data
	//-- considerada no calculo do Saldo Anterior

	dbSelectArea( "SRA" )
	dbGoTop()

	If nOrdem == 1
		dbSetOrder( 1 )
		dbSeek(cFilDe + cMatDe,.T.)
		cInicio  := "SRA->RA_FILIAL + SRA->RA_MAT"
		cFim     := cFilAte + cMatAte
	ElseIf nOrdem == 2
		dbSetOrder( 2 )
		dbSeek(cFilDe + cCcDe + cMatDe,.T.)
		cInicio  := "SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT"
		cFim     := cFilAte + cCcAte + cMatAte
	ElseIf nOrdem == 3
		dbSetOrder( 3 )
		dbSeek(cFilDe + cNomDe + cMatDe,.T.)
		cInicio  := "SRA->RA_FILIAL + SRA->RA_NOME + SRA->RA_MAT"
		cFim     := cFilAte + cNomAte + cMatAte
	ElseIf nOrdem == 4
		dbSetOrder(8)
		dbSeek(cFilDe + cCcDe + cNomDe,.T.)
		cInicio  := 'SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_NOME'
		cFim     := cFilAte + cCcAte + cNomAte
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega Regua de Processamento                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetRegua(SRA->(RecCount()))

	cFilAnterior := Space(FWGETTAMFILIAL)
	cCcAnt  	 := Space(GetSx3Cache("RA_CC", "X3_TAMANHO"))

	While !EOF() .And. &cInicio <= cFim
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Movimenta Regua de Processamento                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IncRegua()

		If lEnd
			@Prow()+1,0 PSAY STR0014	// "** CANCELADO PELO OPERADOR **"
			Exit
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica Quebra de Filial                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SRA->RA_FILIAL != cFilAnterior
			If !fInfo(@aInfo,Sra->ra_FILIAL)
				Exit
			Endif
			If !Empty(cFilAnterior)
				fImpFil(@aLancaF)    // Totaliza Filial
			Endif
			cFilAnterior := SRA->RA_FILIAL
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Consiste controle de acessos e filiais validas               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  SRA->( !(RA_FILIAL $ fValidFil()) .Or. !Eval(cAcessaSRA) )
			fTestaTotal(@aLanca,@aLancaC,@aLancaF,@aLancaE,)
			Loop
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Consiste Parametrizacao do Intervalo de Impressao            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( SRA->RA_CC   < cCcDe )   .Or. ( SRA->RA_CC > cCcAte ) .Or. ;
		( SRA->RA_NOME < cNomDe )  .Or. ( SRA->RA_NOME > cNomAte ) .Or. ;
		( SRA->RA_MAT < cMatDe )   .Or. ( SRA->RA_MAT > cMatAte ) .Or. ;
		( SRA->RA_TNOTRAB < cTurDe).Or. ( SRA->RA_TNOTRAB > cTurAte) .Or. ;
		( SRA->RA_REGRA < cRegDe) 	.Or. ( SRA->RA_REGRA > cRegAte)
			fTestaTotal(@aLanca,@aLancaC,@aLancaF,@aLancaE,)
			Loop
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica Situacao e Categoria do Funcionario                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	!(SRA->RA_SITFOLH $ cSit) .Or. !(SRA->RA_CATFUNC $ cCat)
			fTestaTotal(@aLanca,@aLancaC,@aLancaF,@aLancaE,)
			Loop
		Endif

		// Totalizador do Saldo
		nSaldo    := 0
		nSaldoAnt := 0
		nSaldoAntv:= 0
		lPrimeira := .T.
		aLanca    := {}
		nValor	  := 0
		dDataAux  := CTOD(SPACE(8))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica lancamentos no Banco de Horas                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea( "SPI" )
		dbSetOrder(2)
		dbSeek( SRA->RA_FILIAL + SRA->RA_MAT )
		While SPI->( !Eof() .and. PI_FILIAL+PI_MAT == SRA->( RA_FILIAL+RA_MAT ) )

			//-- Verifica tipo de Evento quando for diferente de Ambos
			If nTpEvento <> 3
				If !fBscEven(SPI->PI_PD,2,nTpEvento)
					SPI->(dbSkip())
					Loop
				EndIf
			Else
				PosSP9(SPI->PI_PD,SRA->RA_FILIAL,"P9_TIPOCOD")
			Endif

			// Totaliza Saldo Anterior
			If SPI->PI_DATA < dPerIni
				If SP9->P9_TIPOCOD $  "1*3"
					If nImpRel == 1 .Or. nImpRel == 3
						nValor:=If(SPI->PI_STATUS=="B",0,If(nHoras=1,SPI->PI_QUANT,SPI->PI_QUANTV))
						//-- Para valor nao nulo considera a Data para Referencia do Saldo
						dDataAux:=If(Empty(nValor),dDataAux,SPI->PI_DATA)
						nSaldoAnt:=__TimeSum(nSaldoAnt,nValor)
					Endif
				Else
					If nImpRel == 2 .Or. nImpRel == 3
						nValor:=If(SPI->PI_STATUS=="B",0,If(nHoras=1,SPI->PI_QUANT,SPI->PI_QUANTV))
						//-- Para valor nao nulo considera a Data para Referencia do Saldo
						dDataAux:=If(Empty(nValor),dDataAux,SPI->PI_DATA)
						nSaldoAnt:=__TimeSub(nSaldoAnt,nValor)
					Endif
				Endif
				nSaldo   := nSaldoAnt
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica os Lancamentos a imprimir                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If	SPI->PI_DATA < dPerIni .Or. SPI->PI_DATA > dPerFim
				dbSkip()
				Loop
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Acumula os lancamentos de Proventos/Desconto em Array        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			FSoma(@aLanca,1)	// Funcionario
			FSoma(@aSomaC,2)	// Centro de Custo
			FSoma(@aSomaF,3)	// Filial
			FSoma(@aSomaE,4)	// Empresa

			dbSelectArea( "SPI" )
			dbSkip()

		Enddo

		dbSelectArea( "SRA" )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Testa total de lancamentos						             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	Len(aLanca) == 0 .AND. EMPTY(nSaldoAnt)
			fTestaTotal(@aLanca,@aLancaC,@aLancaF,@aLancaE,)
			Loop
		Endif
		//-- Se nao houve movimento no periodo sera comparado o tipo de saldo (credito ou debito
		//-- com o saldo anterior
		//-- Senao sera comparado o resultado do mes
		If	Len(aLanca) == 0
			nSaldComp:= nSaldoAnt
			nSaldCompv:= nSaldoAntv
		Else
			nSaldComp:= aLanca[Len(aLanca),5]
			nSaldCompv:= aLancav[Len(aLancav),5]
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime Funcionarios                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( nSalBH == 1  .Or. (nSalBH == 2 .And. nSaldComp >= 0) .Or.;
		(nSalBH == 3 .And. nSaldComp < 0))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Imprime Funcionarios                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nSaldoAC := __TimeSum(nSaldoAC,nSaldoAnt)
			If !Empty( nSaldoAnt )
				nSaldoAF := __TimeSum(nSaldoAF,nSaldoAnt)
				nSaldoAE := __TimeSum(nSaldoAE,nSaldoAnt)
			Endif
			fSomaSaldo(@aLancaC,@aSomaC)
			fSomaSaldo(@aLancaF,@aSomaF)
			fSomaSaldo(@aLancaE,@aSomaE)
			If lIdentFu
				fImpFun(@aLanca)
			EndIf
		Else
			aSomaC := {}
			aSomaF := {}
			aSomaE := {}
		Endif

		fTestaTotal(@aLanca,@aLancaC,@aLancaF,@aLancaE)

	Enddo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime o RodaPe                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF lRoda
		IF LI != 58
			Li := 58
		EndIF
		Impr("","F")
	EndIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Termino do relatorio                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	dbSelectArea("SPI")
	dbSetOrder(1)
	dbSelectArea("SRA")
	dbSetOrder(1)
	Set Device To Screen
	If aReturn[5] = 1
		Set Printer To
		Commit
		ourspool(wnrel)
	Endif
	MS_FLUSH()

//*----------------------------------------------------------*
// Executa Quebras
//*----------------------------------------------------------*
Static Function fTestaTotal(aLanca,aLancaC,aLancaF,aLancaE)
	cFilAnterior := SRA->RA_FILIAL
	cCcAnt := SRA->RA_CC
	dbSelectArea( "SRA" )
	dbSkip()

	If Eof() .Or. &cInicio > cFim
		fImpCc(@aLancaC)
		fImpFil(@aLancaF)
		fImpEmp(@aLancaE)
	Elseif cFilAnterior != SRA->RA_FILIAL
		fImpCc(@aLancaC)
		fImpFil(@aLancaF)
	Elseif cCcAnt != SRA->RA_CC .And. !Eof()
		fImpCc(@aLancaC)
	Endif

	dbSelectArea("SRA")
Return

//*---------------------------------*
// Acumula Lancamentos
//*---------------------------------*
Static Function fSoma(aLanca,nTipo)

	Private nPos:=0

	IF SP9->( P9_TIPOCOD $ "1*3" .and. nImpRel == 2 .or. P9_TIPOCOD == "2" .and. nImpRel == 1  )
		Return( NIL )
	EndIF

	If nTipo > 1 .And. (nPos:=aScan(aLanca,{ |x| x[2] == SPI->PI_PD })) > 0
		If SPI->PI_STATUS <> "B"
			If SP9->P9_TIPOCOD $ "1*3"
				aLanca[nPos,4] := __TimeSum(aLanca[nPos,4],If(nHoras==1,SPI->PI_QUANT,SPI->PI_QUANTV))
			Else
				aLanca[nPos,3] := __TimeSum(aLanca[nPos,3],If(nHoras==1,SPI->PI_QUANT,SPI->PI_QUANTV))
			Endif
		Endif
	Else
		aAdd(aLanca ,{})
		aAdd(aLanca[Len(aLanca)],SPI->PI_DATA)
		aAdd(aLanca[Len(aLanca)],SPI->PI_PD)
		If SP9->P9_TIPOCOD $ "1*3"
			If nTipo == 1
				nSaldo:=__TimeSum(nSaldo,If(SPI->PI_STATUS=="B",0,If(nHoras==1,SPI->PI_QUANT,SPI->PI_QUANTV)))
			Endif
			aAdd(aLanca[Len(aLanca)],0.00)

			If nTipo > 1 .And. SPI->PI_STATUS == "B"
				aAdd(aLanca[Len(aLanca)],0.00)
			Else
				aAdd(aLanca[Len(aLanca)],If(nHoras==1,SPI->PI_QUANT,SPI->PI_QUANTV))
			Endif

			aAdd(aLanca[Len(aLanca)],nSaldo)
		Else
			If nTipo == 1
				nSaldo:=__TimeSub(nSaldo,If(SPI->PI_STATUS=="B",0,If(nHoras==1,SPI->PI_QUANT,SPI->PI_QUANTV)))
			Endif

			If nTipo > 1 .And. SPI->PI_STATUS == "B"
				aAdd(aLanca[Len(aLanca)],0.00)
			Else
				aAdd(aLanca[Len(aLanca)],If(nHoras==1,SPI->PI_QUANT,SPI->PI_QUANTV))
			Endif

			aAdd(aLanca[Len(aLanca)],0.00)
			aAdd(aLanca[Len(aLanca)],nSaldo)
		Endif
		aAdd(aLanca[Len(aLanca)],If(nTipo==1,SPI->PI_STATUS," "))	//
	Endif

	Return Nil

	*-------------------------------------*
Static Function fSomaSaldo(aLanca,aSoma) // Acumula Lancamentos
	*-------------------------------------*
	Local nQ := 0

	For nQ:=1 to Len(aSoma)
		// Totaliza as colunas do Funcionario Lido com as de  outro funcionario
		If (nPos:=aScan(aLanca,{ |x| x[2] == aSoma[nQ,2] })) > 0
			//-- Soma Coluna Credito
			aLanca[nPos,4] := __TimeSum(aLanca[nPos,4],aSoma[nQ,4])
			//-- Soma Coluna Debito
			aLanca[nPos,3] := __TimeSum(aLanca[nPos,3],aSoma[nQ,3])

		Else
			aAdd(aLanca ,{})
			aAdd(aLanca[Len(aLanca)],aSoma[nQ,1] )
			aAdd(aLanca[Len(aLanca)],aSoma[nQ,2] )
			aAdd(aLanca[Len(aLanca)],aSoma[nQ,3] )
			aAdd(aLanca[Len(aLanca)],aSoma[nQ,4] )
			aAdd(aLanca[Len(aLanca)],aSoma[nQ,5] )
			aAdd(aLanca[Len(aLanca)],aSoma[nQ,6] )

		Endif
	Next

	aSoma := {}

	Return Nil

	*-----------------------------*
Static Function fImpFun(aLanca)            // Imprime um Funcionario
	*-----------------------------*
	If	Len(aLanca) == 0 .AND. EMPTY(nSaldoAnt)
		Return Nil
	Endif

	fImprime(aLanca,1)

	aLanca := {}

	Return Nil

	*-----------------------------*
Static Function fImpCc(aLancaC)             // Imprime Centro de Custo
	*-----------------------------*
	If Len(aLancaC) == 0 .AND. EMPTY(nSaldoAC)
		Return Nil
	Endif

	If nOrdem == 2 .Or. nOrdem == 4
		fImprime(aLancaC,2) // Imprime
	Endif

	aLancaC := {}
	nSaldoAC := 0

	Return Nil

	*-------------------------------*
Static Function fImpFil(aLancaF)            // Imprime Filial
	*-------------------------------*
	If	Len(aLancaF) == 0 .AND. EMPTY(nSaldoAF)
		Return Nil
	Endif

	If	lImpFil
		fImprime(aLancaF,3)
	Endif

	aLancaF := {}
	nSaldoAF := 0

	Return Nil

	*-------------------------------*
Static Function fImpEmp(aLancaE)            // Imprime Empresa
	*-------------------------------*
	If Len(aLancaE) == 0 .AND. EMPTY(nSaldoAE)
		Return Nil
	Endif

	If lImpEmp
		fImprime(aLancaE,4)
	Endif

	aLancaE := {}
	nSaldoAE := 0

	Return Nil

	*-----------------------------------------------*
Static Function fImprime(aLanca,nTipo)
	*-----------------------------------------------*
	// nTipo: 1- Funcionario
	//        2- Centro de Custo
	//        3- Filial
	//        4- Empresa

	Local nConta := 0
	Local nTVP := nTVD := nLIQ := 0   // Totais dos Valores

	If nTipo == 1
		If lPrimeira
			Det:= PADR(SRA->RA_FILIAL+"  "+SRA->RA_MAT+" "+Left(SRA->RA_NOME,30),52)
			If !lSint
				cDataAux:=Iif(Empty(dDataAux),SPACE(11),PADR(DTOC(dDataAux),12))
				Det:= PADR(Det+cDataAux+STR0009,110)+TransForm(nSaldoAnt,"@e 99999999.99")	//"Saldo Anterior"
			Endif
			If !lSint
				IMPR(DET,"C")
			Endif
		Endif
		If !lSint
			Det := Space(52)
		Endif
	Elseif nTipo == 2
		DET:= PADR(STR0010+cCcAnt+"-"+Left(DescCc(cCcAnt),30),120)	//"TOTAL C.CUSTO "
	Elseif nTipo == 3
		DET:= PADR(STR0011+cFilAnterior+"-"+aInfo[1],86)	//"TOTAL FILIAL  "
	Elseif nTipo == 4
		DET:= PADR(STR0012+aInfo[3],86)	//"TOTAL EMPRESA "
	Endif

	If nTipo > 1 .Or. (lSint .And. nTipo == 1) //-- Sintetico ou Totais
		Det := PADR(Det,77)
		For nConta :=1 TO Len(aLanca)
			IF aLanca[nConta,6] <> "B"
				nTVD := __TimeSum(nTVD,aLanca[nConta,3])
				nTVP := __TimeSum(nTVP,aLanca[nConta,4])
			Endif
		Next
		nVal :=IF(nTipo==1,nSaldoAnt,IF(nTipo==2,nSaldoAC,IF(nTipo==3,nSaldoAF,nSaldoAE)))

		If lSint
			Det += Transform(nVal,"@e 9999999.99")+" "
		Else
			Det += SPACE(11)
		Endif
		Det += Transform(nTVD,"@e 9999999.99")+" "
		Det += Transform(nTVP,"@e 9999999.99")+" "
		Det += Transform(__TimeSum(nVal,__TimeSub(nTVP,nTVD)),"@e 99999999.99")

		If nTipo >  1
			IMPR(REPLICATE("-",132) ,"C")
		Endif

		Impr(Det,"C")

		IMPR(REPLICATE("-",132) ,"C")
	Else

		If	Li == 60
			Det:= PADR(SRA->RA_FILIAL+"  "+SRA->RA_MAT+" "+Left(SRA->RA_NOME,30),52)
		Endif

		For nConta :=1 TO Len(aLanca)
			Det:= PADR(Det,52)
			Det+= PADR(DTOC(aLanca[nConta,1]),10)+" "+aLanca[nConta,2]+"-"+;
			Left(DescPdPon(aLanca[nConta,2],SRA->RA_FILIAL),20)+" "+;
			Transform(aLanca[nConta,3],'@E 9999999.99')+" "+;
			Transform(aLanca[nConta,4],'@E 9999999.99')+" "+;
			Transform(aLanca[nConta,5],'@E 99999999.99')+"  "+;
			IF(aLanca[nConta,6]=="B","Baixado","Pendente")
			IF lIdentFu
				Impr(Det,"C")
			EndIF
			If	Li == 60
				Det:= PADR(SRA->RA_FILIAL+"  "+SRA->RA_MAT+" "+Left(SRA->RA_NOME,30),52)
			Else
				Det := " "
			Endif
		Next

	Endif

	If	nTipo == 1
		If	lFuncS
			Impr("","P")            // Salta Pagina a cada funcionario
		Else
			If !lSint
				Impr("","C")
			Endif
		Endif
	Elseif nTipo == 2
		If lSalta
			Impr("","P")
		Else
			Impr("","C")
		Endif
	Else
		Impr("","P")
	Endif

	lPrimeira := .F.
	lRoda	  := .T.

Return Nil
/*
***********************************************************************************************************************************
*MICROSIGA SOFTWARE S/A                                    																		  Folha:      00001*
*S.I.G.A. / PONR060        Relatorio de Banco de Horas      																	  DT.Ref.: 99/99/99*
*Hora...: 14:45:40                                           																	  Emissao: 09/12/98*
***********************************************************************************************************************************
Fil C.Custo   Matr.  Funcionario                      Data     Evento                       Debito    Credito       Saldo  Status
Fil C.Custo   Matr.  Funcionario                      Data               Saldo Anterior     Debito    Credito       Saldo  Status
***********************************************************************************************************************************
Saldo Anterior 999999.99       0,00       0,00 99999999,99
99  999999999 999999 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 99/99/9999 999-XXXXXXXXXXXXXXXXXXXX 9999999,99 9999999,99 99999999,99  Baixado
99/99/9999 999-XXXXXXXXXXXXXXXXXXXX 9999999,99 9999999,99 99999999,99  Pendente
99/99/9999 999-XXXXXXXXXXXXXXXXXXXX 9999999,99 9999999,99 99999999,99  Baixado
99/99/9999                999999.99 9999999,99 9999999,99 99999999,99  Baixado

-----------------------------------------------------------------------------------------------------------------------------------
Saldo Anterior                 0,00       0,00 99999999,99
99  999999999 999999 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 99/99/9999 999-XXXXXXXXXXXXXXXXXXXX 9999999,99 9999999,99 99999999,99  Baixado
99/99/9999 999-XXXXXXXXXXXXXXXXXXXX 9999999,99 9999999,99 99999999,99  Pendente
99/99/9999 999-XXXXXXXXXXXXXXXXXXXX 9999999,99 9999999,99 99999999,99  Baixado
99/99/9999 999-XXXXXXXXXXXXXXXXXXXX 9999999,99 9999999,99 99999999,99  Baixado
-----------------------------------------------------------------------------------------------------------------------------------

TOTAL C.CUSTO 999999999-XXXXXXXXXXXXXXXXXXXX                                            9999999,99 9999999,99 99999999,99
TOTAL FILIAL  99-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX                                         9999999,99 9999999,99 99999999,99
TOTAL EMPRESA 99-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX                                         9999999,99 9999999,99 99999999,99
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³DescCC    ºAutor  ³Ricardo Berti       º Data ³  16/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna a Descricao do Centro de Custo                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PONR100                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DescCC(cCC, nMoeda)

	Local aAreaAnt   := GetArea()
	Local aAreaCC    := {}
	Local cRet       := Replicate('*', Len(SI3->I3_DESC))
	Local cSeekCC    := ''
	Local cAliasCC   := If(CtbInUse(),'CTT','SI3')

	Default cCC        := ''
	Default nMoeda     := 1

	dbSelectArea(cAliasCC)
	aAreaCC := GetArea()
	dbSetOrder(1)
	If MsSeek(cSeekCC:=xFilial(cAliasCC)+cCC, .F.)
		If cAliasCC == 'CTT'
			cRet := Left(&('CTT_DESC'+StrZero(nMoeda, 2)), Len(SI3->I3_DESC)) //-- Do mesmo tamanho do I3_DESC, para manter a compatibilidade
		ElseIf cAliasCC == 'SI3'
			Do While !Eof() .And. cSeekCC==I3_FILIAL+I3_CUSTO
				If I3_MOEDA$' ú0' //-- " " ou "0" indica registro de CADASTRO no arquivo SI3
					cRet := I3_DESC
					Exit
				EndIf
				dbSkip()
			EndDo
		EndIf
	EndIf
	RestArea(aAreaCC)
	RestArea(aAreaAnt)

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PONR100   ºAutor  ³Renan S. A. Borges  º Data ³  03/19/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function AjustaPN100RSx1()
	Local aRegs	    := {}
	Local aHelp		:= {}
	Local aHelpE	:= {}
	Local aHelpI	:= {}
	Local cHelp		:= ""

	aHelp	:= {"Informe qual o formato que deseja      ",;
	"adotar para a impressão das horas no   ",;
	"relatório: Sexagesimal ou Decimal.     ",;
	"Se escolhida a opção Sexagesimal,      ",;
	"os minutos serão apresentados na       ",;
	"quantidade real, se a escolha for a    ",;
	"opção Centesimal, a quantidade de      ",;
	"minutos será convertida para centésimos",;
	"de hora.                               "}

	aHelpE	:= {"Informe cual es el formato que desea   ",;
	"adoptar para la impresion de las horas ",;
	"en el informe: Sexagesimal o Decimal.  ",;
	"Si se elige la opcion Sexagesimal, los ",;
	"minutos se presentaran en la cantidad  ",;
	"real, si se elige la opcion Centesimal,",;
	"ultrapassam em 3 linhas o limite da    ",;
	"la cantidad de minutos se convertira   ",;
	"para centesimos de hora.               "}

	aHelpI	:= {"Enter the format to adopt for printing ",;
	"hours in the report: Sexagesimal or    ",;
	"Decimal.                               ",;
	"If selecting Sexagesimal, minutes are  ",;
	"displayed in the real amount.          ",;
	"If Centesimal, the amount of minutes is",;
	"converted into a hundredth of an hour. "}

	cHelp := ".PO090R14."
	PutSX1Help("P"+cHelp,aHelp,aHelpI,aHelpE)

	//          "X1_GRUPO"	,"X1_ORDEM"	,"X1_PERGUNT"		,"X1_PERSPA"	,"X1_PERENG"					,"X1_VARIAVL"	,"X1_TIPO"	,"X1_TAMANHO"	,"X1_DECIMAL"	,"X1_PRESEL"	,"X1_GSC"	,"X1_VALID"					,"X1_VAR01"	,"X1_DEF01"			,"X1_DEFSPA1"				,"X1_DEFENG1"				,"X1_CNT01"	,"X1_VAR02"	,"X1_DEF02"			,"X1_DEFSPA2"		,"X1_DEFENG2"   ,"X1_CNT02"	,"X1_VAR03" ,"X1_DEF03"			,"X1_DEFSPA3"		,"X1_DEFENG3"		,"X1_CNT03"	,"X1_VAR04"	,"X1_DEF04"	,"X1_DEFSPA4"	,"X1_DEFENG4"	,"X1_CNT04"	,"X1_VAR05"	,"X1_DEF05"	,"X1_DEFSPA5"	,"X1_DEFENG5"	,"X1_CNT05"	,"X1_F3"	,"X1_GRPSXG"	,"X1_PYME"	,AHELPPOR	,AHELPENG	,AHELPSPA	,"X1_HELP" }
	aAdd(aRegs,{"PN100R" 		,"21"		,"Horas em ?  "	,"¿Horas?  "	,"Hours in?  "  				,"MV_CHE"		,"N"		,1				,0				,1				,"C"		,"NaoVazio()"					,"mv_par21"	,"Sexagesimal"		,"Sexagesimal"			,"Sexagesimal"			,""    		,""	      		,"Centesimal"			,"Centesimal"		,"Centesimal"	  ,""			,""			 ,""					,""					,""					,""				,""				,""				,""				,""				,""				,""				,""				,""				,""				,""			,""				,""				,"S"		,aHelp		,aHelpI	,aHelpE	,cHelp	})

	ValidPerg(aRegs,"PN100R",.T.)

Return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fTotR100  ºAutor  ³Luis Artuso         º Data ³  06/18/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Totaliza o saldo de horas.                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function fTotR100(oSection1,oSection2,lTotaliza,tp)

	Local nFuncCrTt	:= 0
	Local nFuncDbTt	:= 0
	Local nSdFunAnt	:= 0
	Local nRet		:= 0

	If ( lTotaliza )
		nSdFunAnt := iif(tp==1,nAcuAnt,nAcuAntv)
	Else
		nSdFunAnt := oSection1:Cell(iif(tp==1,"SALDOANT","SALDOANTV")):GetValue()
	EndIf

	if !(Empty(oSection2:GetFunction(iif(tp==1,"FUNCCRED","FUNCCREDV")):GetLastValue()))
		nFuncCrTt	:= oSection2:GetFunction(iif(tp==1,"FUNCCRED","FUNCCREDV")):GetLastValue()
	EndIF

	if !(Empty(oSection2:GetFunction(iif(tp==1,"FUNCDEB","FUNCDEBV") ):GetLastValue()))
		nFuncDbTt	:= oSection2:GetFunction(iif(tp==1,"FUNCDEB","FUNCDEBV")):GetLastValue()
	EndIf

	If !( Empty(nSdFunAnt) )
		nRet	:= __TimeSum(nSdFunAnt,__TimeSub(nFuncCrTt,nFuncDbTt))
	Else
		nRet	:= __TimeSub(nFuncCrTt,nFuncDbTt)
	EndIf

	oSection2:GetFunction(iif(tp==1,"FUNCDEB","FUNCDEBV")):SetValue(0)
	oSection2:GetFunction(iif(tp==1,"FUNCCRED","FUNCCREDV") ):SetValue(0)

	If ( lTotaliza )
		if tp==1
			Return nTotal
		else
			Return nTotalv
		endif
	Else
		if tp==1
			nTotal += nRet
		else
			nTotalv+= nRet
		endif
		Return nRet
	EndIf

