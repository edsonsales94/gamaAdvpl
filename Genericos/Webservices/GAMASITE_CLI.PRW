#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

#DEFINE STR0001 "Brasitech - Servi輟 de inclus縊 de clientes com informa鋏es provenientes do website Gama Italy Store1"
#DEFINE STR0002 "M騁odo de inclus縊 de clientes do website Gama Italy Store1"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		GAMASITE_CLI                                                  /@
@type				Webservice                                                    /@
@date				09/01/2017                                                    /@
@description	Webservice de integra鈬o Protheus x GA.MA Store para 
					cadastramento de cliente.                                     /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Op鈬o Um Consultoria                                          /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Definicao da estruturas utilizadas                                      
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
WSSTRUCT STRWSGICLI
	WSDATA COD					AS String
	WSDATA MSG					AS String
	WSDATA CLI_CODIGO			AS String
ENDWSSTRUCT

WSSTRUCT STRCLI
	WSDATA CPFCNPJ				AS String
   WSDATA NOME					AS String
   WSDATA RG					AS String
   WSDATA EMAIL				AS String
   WSDATA CEP					AS String
   WSDATA LOGRADOURO			AS String
   WSDATA NUMERO				AS String
   WSDATA COMPLEMENTO		AS String
   WSDATA BAIRRO				AS String
   WSDATA UF					AS String
   WSDATA DDD					AS String 
   WSDATA TELEFONE1			AS String
   WSDATA TELEFONE2			AS String
   WSDATA CODMUN				AS String 
   WSDATA INSCREST			AS String 
   WSDATA INSCRMUN			AS String
   WSDATA CONTATO 			AS String 
	WSDATA MKTPLACE 			AS String 
ENDWSSTRUCT

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Definicao do Web Service                                                 
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
WSSERVICE GAMASITE_CLI    DESCRIPTION STR0001     
	 
	WSDATA StructREC		     As STRCLI	
	WSDATA StructRET		     As STRWSGICLI
	
	WSMETHOD CLI			DESCRIPTION STR0002	

ENDWSSERVICE

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// METODO CLI 
// ENVIA OS DADOS PARA CADASTRO DE CLIENTE E RETORNA O CODIGO
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
WSMETHOD CLI  WSRECEIVE StructREC WSSEND StructRET WSSERVICE GAMASITE_CLI

Local lReturn, cTipo, aSA1, cCodIBGE, cUF, cInscrEst, cCNPJ, cEnder, cParteCod,;
		cLojaBase, cMensagem, cTexto, cTLOG, cEol, aArea, aAreaSX3, lObrFilled,;
		cMensObr, aApoio, cDestinat, lEnviaEml, cCod, cLoja, lSA1Exist,;
		nX, cTabela, cMktPlace, cConta, error

PRIVATE lMsErroAuto

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Inicializando ambiente
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
//WfPrepEnv("01", "08", "GAMASITE_CLI",, "FAT")

lReturn	  	:= .F.
cTipo			:= iif(Len(AllTrim(::StructREC:CPFCNPJ)) > 11, "J", "F")
aSA1	 		:= {}
cCodIBGE		:= Substr(::StructREC:CODMUN, 3, 5)
cUF			:= FwNoAccent(Upper(Alltrim(::StructREC:UF)))
cInscrEst	:= iif(Empty(::StructREC:INSCREST), "ISENTO", ::StructREC:INSCREST)
cCNPJ			:= AllTrim(::StructREC:CPFCNPJ)
cEnder		:= ""
cParteCod	:= "A"
cLojaBase	:= "A1"
cMensagem	:= ""
cTexto		:= ""
cTLOG 		:= CriaTrab({{"LINHA", "C", 250, 0}}, .T.)
cEol			:= chr(13) + chr(10)
aArea			:= GetArea()
aAreaSX3		:= SX3->(GetArea())
lObrFilled	:= .T.
error := 0
cMensObr		:= ""
cTabela		:= GetMV("BR_X_TPRLJ", .F., "109")	//Codigo da tabela padrao para a loja. Utilizada no PE - LJ1146EX
cMktPlace	:= AllTrim(::StructREC:MKTPLACE)
cConta		:= Iif(cMktPlace == "1","1120101005",Iif(cMktPlace == "2","1120101004","1120101006")) //1120101004 = Contas a Receber Ecommerce / 1120101005 = Contas a Receber B2W / 1120101006 = Contas a Receber WalMart
aApoio 		:= {	{"A1_END    ", ::StructREC:LOGRADOURO},;
						{"A1_COMPLEM",	::StructREC:COMPLEMENTO},;
						{"A1_EST    ",	cUF},;
						{"A1_COD_MUN",	cCodIBGE},;
						{"A1_BAIRRO ",	::StructREC:BAIRRO},;
						{"A1_CEP    ",	::StructREC:CEP},;
						{"A1_PFISICA",	::StructREC:RG},;
						{"A1_DDD    ",	::StructREC:DDD},;
						{"A1_TEL    ",	::StructREC:TELEFONE1},;
						{"A1_DDD1   ",	::StructREC:DDD},;
						{"A1_TEL1   ",	::StructREC:TELEFONE1},;
						{"A1_EMAIL  ",	::StructREC:EMAIL},;
						{"A1_CONTATO",	::StructREC:CONTATO}}
cDestinat	:= GetMV("BR_STOEML2", .F., "cassio.olimpio@gamaitaly.com.br")
lEnviaEml	:= .T.
lMsErroAuto := .F.

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
// Cria鈬o da estrutura tempor疵ia para LOG da opera鈬o
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
if Select("TLOG") > 0
	dbSelectArea("TLOG") 
	dbCloseArea()
endif

dbUseArea(.T.,, cTLOG, "TLOG", .T.)

cTexto += "Informa鈬o Site GA.MA Store: " + iif(cTipo == "J", Transform(::StructREC:CPFCNPJ, "@R 99.999.999/9999-99"), Transform(::StructREC:CPFCNPJ, "@R 999.999.999-99")) + " - " + ::StructREC:NOME
cTexto += cEol + cEol

if !Empty(::StructREC:LOGRADOURO + ::StructREC:NUMERO)
	cEnder := AllTrim(::StructREC:LOGRADOURO) + Iif(!empty(AllTrim(::StructREC:NUMERO)),", " + AllTrim(::StructREC:NUMERO),"")
endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Setar a ordem das tabelas
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
SA1->(dbSetOrder(3))
lSA1Exist := .F.
if SA1->(dbSeek(xFilial("SA1") + ::StructREC:CPFCNPJ))
	lSA1Exist	:= .T.
	cCod 			:= SA1->A1_COD
	cLoja			:= SA1->A1_LOJA
endif

SA1->(dbSetOrder(1))
CC2->(dbSetOrder(1))
SX3->(dbSetOrder(2))

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Validando se os campos obrigat?rios foram preenchidos
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if Empty(::StructREC:CPFCNPJ)
	lObrFilled	:= .F.
	cMensObr		+= "CNPJ ou CPF, "
endif

if Empty(::StructREC:NOME)
	lObrFilled	:= .F.
	cMensObr		+= "Nome, "
endif

for nX := 1 to Len(aApoio)
	if SX3->(dbSeek(aApoio[nX,1]))
		if !Empty(SX3->X3_OBRIGAT) .and. Empty(aApoio[nX,2])
			lObrFilled	:= .F.
			cMensObr		+= AllTrim(SX3->X3_TITULO) + ", "
		endif
	endif
next

RestArea(aAreaSX3)
RestArea(aArea)

if lObrFilled

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Pesquisa o codigo do municipio
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	if CC2->(dbSeek(xFilial("CC2") + cUF + cCodIBGE))

		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		// Array para o cadastro de clientes
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		if lSA1Exist
			SA1->(dbSeek(xFilial("SA1") + cCod + cLoja))
			//conout(SA1->A1_COD + "/" + SA1->A1_LOJA + " - " +SA1->A1_NOME)
			
			if AllTrim(SA1->A1_END) == AllTrim(Upper(cEnder)) .and.;
				AllTrim(SA1->A1_COMPLEM) == AllTrim(Upper(::StructREC:COMPLEMENTO)) .and.;
				AllTrim(SA1->A1_EST) == AllTrim(Upper(cUF)) .and.;
				AllTrim(SA1->A1_COD_MUN) == AllTrim(cCodIBGE) .and.;
				AllTrim(SA1->A1_BAIRRO) == AllTrim(Upper(::StructREC:BAIRRO)) .and.;
				AllTrim(SA1->A1_CEP) == AllTrim(::StructREC:CEP)

				lEnviaEml := .F.
				
			endif		
		
			aAdd(aSA1, {"A1_COD",			SA1->A1_COD,					Nil})
			aAdd(aSA1, {"A1_LOJA",			SA1->A1_LOJA,					Nil})
			
		else
		
			aAdd(aSA1, {"A1_TIPO",			"F",						  		Nil})
			aAdd(aSA1, {"A1_CGC",			Upper(::StructREC:CPFCNPJ),Nil})
			aAdd(aSA1, {"A1_PAIS",			"105",							Nil})
			aAdd(aSA1, {"A1_CONTA",			cconta,							Nil})
//			aAdd(aSA1, {"A1_VEND",			"15488 ",						Nil})
//			aAdd(aSA1, {"A1_XVENALT",		"15488 ",						Nil})
//			aAdd(aSA1, {"A1_SATIV1",		"4400",							Nil})
//			aAdd(aSA1, {"A1_XMCANAL",		"CONSUMIDOR FINAL",			Nil})
//			aAdd(aSA1, {"A1_REGIAO",		"993",							Nil})
//			aAdd(aSA1, {"A1_TPFRET",		"C",								Nil})
			aAdd(aSA1, {"A1_CODPAIS",		"01058",							Nil})
			aAdd(aSA1, {"A1_POSTO",			"2",								Nil})
			aAdd(aSA1, {"A1_NATUREZ",		"30100101  ",					Nil})
			aAdd(aSA1, {"A1_X_AGEND",		"N",								Nil})
			aAdd(aSA1, {"A1_X_MDVPC",		"C",								Nil})
//			aAdd(aSA1, {"A1_RISCO",			"A",								Nil})
//			aAdd(aSA1, {"A1_NOME",			Upper(::StructREC:NOME),	Nil})
//			aAdd(aSA1, {"A1_NREDUZ",		Upper(::StructREC:NOME),	Nil})
			aAdd(aSA1, {"A1_XCADCLI",		"1",								Nil})
			aAdd(aSA1, {"A1_CONTRIB",		"2",								Nil})

		endif
		
		aAdd(aSA1, {"A1_NOME",				Upper(::StructREC:NOME),			Nil})
		aAdd(aSA1, {"A1_NREDUZ",			Upper(::StructREC:NOME),			Nil})
		aAdd(aSA1, {"A1_END", 				Upper(cEnder),						Nil})
		aAdd(aSA1, {"A1_COMPLEM",			Upper(::StructREC:COMPLEMENTO),		Nil})
		aAdd(aSA1, {"A1_EST",				Upper(cUF),							Nil})
		aAdd(aSA1, {"A1_COD_MUN",			cCodIBGE,							Nil})
		aAdd(aSA1, {"A1_BAIRRO",			Upper(::StructREC:BAIRRO),			Nil})
		aAdd(aSA1, {"A1_CEP",				::StructREC:CEP,					Nil})
		aAdd(aSA1, {"A1_INSCR",				cInscrEst,							Nil})
		aAdd(aSA1, {"A1_PFISICA",			::StructREC:RG,						Nil})
		aAdd(aSA1, {"A1_DDD",				::StructREC:DDD,					Nil})
		aAdd(aSA1, {"A1_TEL",				::StructREC:TELEFONE1,				Nil})
		aAdd(aSA1, {"A1_DDD1",				::StructREC:DDD,					Nil})
		aAdd(aSA1, {"A1_TEL1",				::StructREC:TELEFONE1,				Nil})
		aAdd(aSA1, {"A1_DDD2",				::StructREC:DDD,					Nil})
		aAdd(aSA1, {"A1_TEL2",				::StructREC:TELEFONE2,				Nil})
		aAdd(aSA1, {"A1_EMAIL",				::StructREC:EMAIL,					Nil})
		aAdd(aSA1, {"A1_CONTATO",			Upper(::StructREC:CONTATO),			Nil})
		aAdd(aSA1, {"A1_PESSOA",			cTipo,								Nil})	
		aAdd(aSA1, {"A1_TABELA",			cTabela,			  				Nil})
		aAdd(aSA1, {"A1_XTABPAD",			cTabela,							Nil})
		aAdd(aSA1, {"A1_VEND",			"15488 ",						Nil})
		aAdd(aSA1, {"A1_XVENALT",		"15488 ",						Nil})
		aAdd(aSA1, {"A1_SATIV1",		"4400",							Nil})
		aAdd(aSA1, {"A1_XMCANAL",		"CONSUMIDOR FINAL",			Nil})
		aAdd(aSA1, {"A1_REGIAO",		"993",							Nil})
		aAdd(aSA1, {"A1_TPFRET",		"C",								Nil})
		

		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		// Msexecauto para o cadastro de clientes
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		lMsErroAuto := .F.
		MSExecAuto({|x, y| Mata030(x, y)}, aSA1, iif(lSA1Exist, 4, 3))			//3- Inclus縊, 4- Altera鈬o, 5- Exclus縊
			
		if lMsErroAuto

			cTexto += "Erro ao " + iif(lSA1Exist, "alterar", "incluir") + " o cadastro do CLIENTE"
			GrvLog("Log de erro:", NomeAutoLog())
			error := 1
//			DisarmTransaction()
						
		else
	
			cTexto += "Cliente " + iif(lSA1Exist, "alterado", "incluido") + " com sucesso com o C?digo " + SA1->A1_COD + " Loja " + SA1->A1_LOJA
			lReturn	:= .T.
	
		endif
	
	else

		cTexto += "N縊 foi poss?vel integrar o cadastro com o Protheus, pois n縊 foi poss?vel encontrar o c?digo IBGE no cadastro de munic?pios. UF " + Alltrim(::StructREC:UF) + ", Codigo IBGE " + Alltrim(::StructREC:CODMUN) + "."
		error := 1
	endif
	
else

	lReturn	:= .F.
	cMensObr := "Um ou mais campos obrigat?rios n縊 foram preenchidos. " + cMensObr
	cTexto += cMensObr
	error := 1
endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Monta mensagem para o envio do e-mail com o resultado do cadastramento
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
TLOG->(dbGoTop())
do while TLOG->(!eof())
	cTexto += AllTrim(TLOG->LINHA) + chr(13) + chr(10)
	TLOG->(dbSkip())
enddo

cMensagem := '<html>'
cMensagem += '<font size="2" face="Calibri">' + cTexto + '</font><br><br><br>'
cMensagem += '<font size="1" face="Calibri">E-mail autom疸ico enviado pelo sistema Microsiga Protheus. Favor n縊 respond?-lo.</font>'
cMensagem += '</body>'
cMensagem += '</html>'
	
if !empty(cDestinat) .and. lEnviaEml
	
	//verifico se existe o erro 
		if error >= 1
		U_GISendMail(cDestinat,, "Error na Integra鈬o Website GA.MA Store x Protheus - CLI - Cadastro de cliente", cMensagem)
		endif
	
	
endif

TLOG->(dbCloseArea())
fErase(cTLOG)

if lReturn
	::StructRET:COD			:= "1"
	::StructRET:MSG 			:= "Sucesso na " + iif(lSA1Exist, "altera鈬o", "inclus縊") + " do cadastro."
	::StructRET:CLI_CODIGO 	:= SA1->(A1_COD + "/" + A1_LOJA)
else
	::StructRET:COD			:= "2"
	::StructRET:MSG 			:= "Falha na " + iif(lSA1Exist, "altera鈬o", "inclus縊") + " do cadastro. " + cTexto
	::StructRET:CLI_CODIGO 	:= " "
	SetSoapFault("2", "Falha na " + iif(lSA1Exist, "altera鈬o", "inclus縊") + " do cadastro. " + cTexto)
endif

Return lReturn


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		GRVLOG                                                        /@
@type				Static function                                               /@
@date				30/04/2012                                                    /@
@description	Fun鈬o p/grava鈬o de log de processamento em tabela tempor疵ia/@
@author			Adalberto Moreno Batista - Op鈬o Um Consultoria               /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function GrvLog(cErro, cArqErro)
Local aArea		:= GetArea()

dbSelectArea("TLOG")
TLOG->(RecLock("TLOG",.T.))
TLOG->LINHA	:= cErro
TLOG->(MsUnlock())

if cArqErro<>NIL
	Append From &cArqErro SDF
	fErase(cArqErro)
endif

RestArea(aArea)

Return()
