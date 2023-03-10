#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

#DEFINE STR0001 "Brasitech - Servi&ccedil;o de inclus縊 de clientes e fornecedores com informa鋏es provenientes do sistema Assist"
#DEFINE STR0002 "M&eacute;todo de Inclus&atilde;o de Clientes Gama"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		GAMA_CADCLI                                                   /@
@type				Webservice                                                    /@
@date				01/04/2015                                                    /@
@description	Webservice de integra鈬o Protheus x Assist para cadastramento
					de cliente e fornecedor.                                      /@
@author			Felippe Rainho                                                /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Definicao da estruturas utilizadas                                      
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
WSSTRUCT STRRETCLI
	WSDATA COD					AS String
	WSDATA MSG					AS String
	WSDATA CLI_CODIGO			AS String
ENDWSSTRUCT

WSSTRUCT STRCADCLI
	WSDATA CPFCNPJ				AS String
   WSDATA NOME					AS String
   WSDATA RG					AS String
   WSDATA EMAIL				AS String
   WSDATA CEP					AS String
   WSDATA LOGRADOURO			AS String
   WSDATA NUMERO				AS String
   WSDATA COMPLEMENTO		AS String
   WSDATA BAIRRO				AS String
//   WSDATA CIDADE				AS String
   WSDATA UF					AS String
   WSDATA DDD					AS String 
   WSDATA TELEFONE1			AS String
   WSDATA TELEFONE2			AS String
   WSDATA CODMUN				AS String 
   WSDATA INSCREST			AS String 
   WSDATA INSCRMUN			AS String
   WSDATA CONTATO 			AS String 
ENDWSSTRUCT

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Definicao do Web Service                                                 
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
WSSERVICE GAMA_CADCLI    DESCRIPTION STR0001     
	 
	WSDATA StructREC		     As STRCADCLI	
	WSDATA StructRET		     As STRRETCLI
	
	WSMETHOD CADCLI			DESCRIPTION STR0002	

ENDWSSERVICE

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// METODO CADCLI 
// ENVIA OS DADOS PARA CADASTRO DE CLIENTE E RETORNA O CODIGO
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
WSMETHOD CADCLI  WSRECEIVE StructREC WSSEND StructRET WSSERVICE GAMA_CADCLI

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
//VARIAVEIS
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
Local 	lReturn,cTipo,aSA1,aSA2,cCodIBGE,cUF,cInscrEst,cCNPJ,cEnder,cParteCod,cLojaBase,cMensagem,cTexto,cTLOG,cEol,;
		aArea,aAreaSX3,lObrFilled,cMensObr,aApoio,cCod, cLoja, lSA1Exist, lSA2Exist, cDestinat, nX

PRIVATE lMsErroAuto := .F.

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Inicializando ambiente
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
//WfPrepEnv("01", "03", "GAMA_CADCLI",, "FAT")

lReturn	  	:= .F.
cTipo			:= iif(Len(AllTrim(::StructREC:CPFCNPJ)) > 11, "J", "F")
aSA1	 		:= {}
aSA2	 		:= {}
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
cMensObr		:= ""
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
								{"A1_DDD2   ",	::StructREC:DDD},;
								{"A1_TEL2   ",	::StructREC:TELEFONE2},;
								{"A1_EMAIL  ",	::StructREC:EMAIL},;
								{"A1_CONTATO",	::StructREC:CONTATO},;
								{"A2_INSCRM ",	::StructREC:INSCRMUN}}

lMsErroAuto := .F.

if (cTipo == "J")
	cDestinat	:= GetMV("BR_WSEMCLA", .F., "")	//Enderecos de emails p/ recebimento de ocorrencias no processamento de clientes assistencia tecnica pela integracao com o webservice do Assist
else
	cDestinat	:= GetMV("BR_WSEMCLC", .F., "")	//Enderecos de emails p/ recebimento de ocorrencias no processamento de clientes consumidor final pela integracao com o webservice do Assist
endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
// Cria鈬o da estrutura tempor疵ia para LOG da opera鈬o
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
if Select("TLOG") > 0
	dbSelectArea("TLOG") 
	dbCloseArea()
endif

dbUseArea(.T.,, cTLOG, "TLOG", .T.)

cTexto += "Informa鈬o Assist: " + iif(cTipo == "J", Transform(::StructREC:CPFCNPJ, "@R 99.999.999/9999-99"), Transform(::StructREC:CPFCNPJ, "@R 999.999.999-99")) + " - " + ::StructREC:NOME
cTexto += cEol + cEol

if !Empty(::StructREC:LOGRADOURO + ::StructREC:NUMERO)
	cEnder := AllTrim(::StructREC:LOGRADOURO) + Iif(!empty(AllTrim(::StructREC:NUMERO)),", " + AllTrim(::StructREC:NUMERO),"")
endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Setar a ordem das tabelas
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
SA1->(dbSetOrder(3))
lSA1Exist := SA1->(dbSeek(xFilial("SA1") + ::StructREC:CPFCNPJ))

SA2->(dbSetOrder(3))
lSA2Exist := SA2->(dbSeek(xFilial("SA2") + ::StructREC:CPFCNPJ))

CC2->(dbSetOrder(1))
SA1->(dbSetOrder(1))
SA2->(dbSetOrder(1))
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
	if (cTipo == "J" .and. Left(aApoio[nX,1],3) == "A2_") .or. Left(aApoio[nX,1],3) != "A2_"
		if SX3->(dbSeek(aApoio[nX,1]))
			if !Empty(SX3->X3_OBRIGAT) .and. Empty(aApoio[nX,2])
				lObrFilled	:= .F.
				cMensObr		+= AllTrim(SX3->X3_TITULO) + ", "
			endif
		endif
	endif
next

RestArea(aAreaSX3)
RestArea(aArea)

if lObrFilled
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Buscando o codigo e loja v疝ido para fornecedor e monta array para a inclus縊
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	if (cTipo == "J")
	
		if !lSA2Exist
		
			cCod		:= Left(cCNPJ, 8)
			
			if Val(Substr(cCNPJ, 9, 4)) < 100 .and. !SA2->(dbSeek(xFilial("SA2") + cCod + Substr(cCNPJ, 11, 2)))
				cLoja	:= Substr(cCNPJ, 11, 2)
			else
				cLojaBase := "A1"
				do while SA2->(dbSeek(xFilial("SA2") + cCod + cLojaBase))
					cLojaBase := Soma1(cLojaBase)
				enddo
				cLoja	:= cLojaBase
			endif
		
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			// Array para o cadastro de fornecedores
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			aSA2 := {	{"A2_COD",				cCod,										Nil},;
							{"A2_LOJA",				cLoja,									Nil},;
							{"A2_EST",				cUF,										Nil},;
							{"A2_TIPO", 			cTipo,									Nil},;
							{"A2_NOME",				::StructREC:NOME,						Nil},;
							{"A2_NREDUZ",			Substr(::StructREC:NOME,1,20),	Nil},;
							{"A2_CGC",				::StructREC:CPFCNPJ,					Nil},;
							{"A2_PFISICA",			::StructREC:RG,						Nil},;
							{"A2_INSCR",			cInscrEst, 								Nil},;
							{"A2_INSCRM",			::StructREC:INSCRMUN,				Nil},;
							{"A2_END", 				cEnder,									Nil},;
							{"A2_COMPLEM",			::StructREC:COMPLEMENTO,			Nil},;
							{"A2_COD_MUN",			cCodIBGE,								Nil},;
							{"A2_BAIRRO",			::StructREC:BAIRRO,					Nil},;
							{"A2_CEP",				::StructREC:CEP,						Nil},;
							{"A2_DDD",				::StructREC:DDD,						Nil},;
							{"A2_TEL",				::StructREC:TELEFONE1,				Nil},;
							{"A2_FAX",				::StructREC:TELEFONE2,				Nil},;
							{"A2_EMAIL",			::StructREC:EMAIL,					Nil},;
							{"A2_COND",				"010",									Nil},;
							{"A2_POSTO",			"1",										Nil},;
							{"A2_NATUREZ",			"40200471",								Nil},;
							{"A2_X_FGTO",			"4",										Nil},;
							{"A2_CONTA",			"2110201003",							Nil}}
						
	   else
	   
			cTexto += "No Protheus, o registro j? est? gravado como fornecedor com o C?digo: " + SA2->A2_COD + " Loja " + SA2->A2_LOJA
			
	   endif
	endif
	
	
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Verifica se o registro j? existe no Protheus
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	if !lSA1Exist
	
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		// Pesquisa o codigo do municipio
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		if CC2->(dbSeek(xFilial("CC2") + cUF + cCodIBGE))
  
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			// Array para o cadastro de clientes
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			aSA1 := {	{"A1_TIPO",			"F",						  				Nil},;
							{"A1_CGC",			Upper(::StructREC:CPFCNPJ),		Nil},;
							{"A1_PAIS",			"105",									Nil},;
							{"A1_CONTA",		"1120101001",							Nil},;
							{"A1_CODPAIS",		"01058",									Nil},;
							{"A1_POSTO",		"1",										Nil},;
							{"A1_NATUREZ",		"30100101  ",							Nil},;
							{"A1_X_AGEND",		"N",										Nil},;
							{"A1_X_MDVPC",		"C",										Nil},;
							{"A1_RISCO",		"E",										Nil},;
							{"A1_XCADCLI",		"1",										Nil},;
							{"A1_NOME",			Upper(::StructREC:NOME),			Nil},;
							{"A1_NREDUZ",		Upper(::StructREC:NOME),			Nil},;
							{"A1_END", 			Upper(cEnder),							Nil},;
							{"A1_COMPLEM",		Upper(::StructREC:COMPLEMENTO),	Nil},;
							{"A1_EST",			Upper(cUF),								Nil},;
							{"A1_COD_MUN",		cCodIBGE,								Nil},;
							{"A1_BAIRRO",		Upper(::StructREC:BAIRRO),			Nil},;
							{"A1_CEP",			::StructREC:CEP,						Nil},;
							{"A1_INSCR",		cInscrEst,								Nil},;
							{"A1_PFISICA",		::StructREC:RG,						Nil},;
							{"A1_DDD",			::StructREC:DDD,						Nil},;
							{"A1_TEL",			::StructREC:TELEFONE1,				Nil},;
							{"A1_DDD1",			::StructREC:DDD,						Nil},;
							{"A1_TEL1",			::StructREC:TELEFONE1,				Nil},;
							{"A1_DDD2",			::StructREC:DDD,						Nil},;
							{"A1_TEL2",			::StructREC:TELEFONE2,				Nil},;
							{"A1_EMAIL",		::StructREC:EMAIL,					Nil},;
							{"A1_CONTATO",		Upper(::StructREC:CONTATO),		Nil},;
							{"A1_PESSOA",		cTipo,									Nil},;
							{"A1_TABELA",		"119",					  				Nil},;
							{"A1_XTABPAD",		"119",									Nil},;
							{"A1_VEND",			"1379",									Nil},;
							{"A1_XVENALT",		"1379",									Nil},;
							{"A1_SATIV1",		"1112",									Nil},;
							{"A1_XMCANAL",		"ASSIST. TECNICA",					Nil},;
							{"A1_REGIAO",		"997",									Nil},;
							{"A1_TPFRET",		"C",										Nil}}

			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			// Msexecauto para o cadastro de clientes
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			lMsErroAuto := .F.
			MSExecAuto({|x, y| Mata030(x, y)}, aSA1, 3)			//3- Inclus縊, 4- Altera鈬o, 5- Exclus縊
				
			if lMsErroAuto
	
				cTexto += "Erro ao incluir o cadastro do CLIENTE"
				GrvLog("Log de erro:", NomeAutoLog())
				
	//			DisarmTransaction()
							
			else
		
				cTexto += "Cliente inclu?do com sucesso com o C?digo " + SA1->A1_COD + " Loja " + SA1->A1_LOJA
				lReturn	:= .T.
		
			endif
		
		
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			// Msexecauto para o cadastro de fornecedores
		 	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		 	if (cTipo == "J")
				lMsErroAuto := .F.
				MSExecAuto({|x, y| Mata020(x, y)}, aSA2, 3)			//3- Inclus縊, 4- Altera鈬o, 5- Exclus縊
		
				if lMsErroAuto
	
					cTexto += "Erro ao incluir o cadastro do FORNECEDOR"
					GrvLog("Log de erro:", NomeAutoLog())
	//				DisarmTransaction()
					
				else
		
					cTexto += "Fornecedor inclu?do com sucesso com o C?digo " + SA2->A2_COD + " Loja " + SA2->A2_LOJA
		
				endif
		
			endif
		
		else
	
			cTexto += "N縊 foi poss?vel integrar o cadastro com o Protheus, pois n縊 foi poss?vel encontrar o c?digo IBGE no cadastro de munic?pios. UF " + Alltrim(::StructREC:UF) + ", Codigo IBGE " + Alltrim(::StructREC:CODMUN) + "."
			
		endif
	
	else
	
		cTexto += "No Protheus, o registro j? est? gravado como cliente com o C?digo: " + SA1->A1_COD + " Loja " + SA1->A1_LOJA
			
	endif

else

	lReturn	:= .F.
	cMensObr := "Um ou mais campos obrigat?rios n縊 foram preenchidos. " + cMensObr
	cTexto += cMensObr

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
	
if !empty(cDestinat)
	U_GISendMail(cDestinat,, "CADCLI - Integra鈬o Protheus x Assist", cMensagem)
endif

TLOG->(dbCloseArea())
fErase(cTLOG)

if lReturn
	::StructRET:COD			:= "1"
	::StructRET:MSG 			:= "Sucesso na inclus縊 do cadastro."
	::StructRET:CLI_CODIGO 	:= SA1->(A1_COD + "/" + A1_LOJA)
else
	::StructRET:COD			:= "2"
	::StructRET:MSG 			:= "Falha na Inclus縊 do cadastro. " + cMensObr
	::StructRET:CLI_CODIGO 	:= " "
	SetSoapFault("2", "Falha na Inclus縊 do cadastro. " + cMensObr)
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
