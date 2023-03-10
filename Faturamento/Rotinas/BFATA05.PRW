/*/
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????Ŀ??
???Programa  ? BFATA05  ? Por: Adalberto Moreno Batista ? Data ?02.07.2012???
?????????????????????????????????????????????????????????????????????????Ĵ??
???Descricao ? Registra ocorrencias de clientes                           ???
?????????????????????????????????????????????????????????????????????????Ĵ??
???Uso       ? Especifico Brasitech (Grupo Gama Italy)                    ???
??????????????????????????????????????????????????????????????????????????ٱ?
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
/*/
#include "protheus.ch"
#include "rwmake.ch"
#include "ap5mail.ch"

User Function BFATA05()
Local aCores		:= {	{ "ZM_STATUS = '1'",	"BR_VERDE" },;
							{ "ZM_STATUS = '2'",	"BR_AMARELO" },;
							{ "ZM_STATUS = '3'",	"BR_AZUL" },;
							{ "ZM_STATUS = '9'",	"BR_VERMELHO" } }

Private cCadastro	:= "Registro de ocorr?ncias de clientes"

Private aRotina		:= {	{ "Pesquisar",	"AxPesqui",	0,1 },;
							{ "Visualizar",	"U_FATA05(2)",	0,2 },;
							{ "Incluir",	"U_FATA05(3)",	0,3 },;
							{ "Tratativa",	"U_FATA05(4)",	0,4 },;
							{ "Excluir",	"U_FATA05(5)",	0,5 },;
							{ "Legenda",	"U_FT05Legend()",	0,6 }}

Private aIndex		:= {}
Private nOpcoes 	:= 5

dbSelectArea("SZM")
mBrowse(,,,,"SZM",,,,,,aCores)

//?????????????????????????????????????????????????????????????????Ŀ
//? Finaliza o uso da funcao FilBrowse e retorna os indices padroes ?
//???????????????????????????????????????????????????????????????????
if Len(aIndex) > 0
	EndFilBrw("SZM", aIndex)
endif

Return(.T.)

/*
???????????????????????????????????????????????????????????????????????????????????
???????????????????????????????????????????????????????????????????????????????????
???????????????????????????????????????????????????????????????????????????????Ŀ??
???Funcao? FATA05       ? Por: Adalberto Moreno Batista       ? Data ?02/07/2012???
????????????????????????????????????????????????????????????????????????????????ٱ?
???????????????????????????????????????????????????????????????????????????????????
???????????????????????????????????????????????????????????????????????????????????
*/
User Function FATA05( nOpcE )
Local nI
Local nUsoInc	:= 0	// variavel auxiliar contador de campos na inclusao
Local nOrdem 	:= SZM->( IndexOrd() )
Local nUsado
Local aC  :={}   	// Array com descricao dos campos do Cabecalho do Modelo 2, para rodape utilizar o mesmo conceito
					// aC[n,1] = Nome da Variavel Ex.:"cCliente"
					// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
					// aC[n,3] = Titulo do Campo
					// aC[n,4] = Picture
					// aC[n,5] = Validacao
					// aC[n,6] = F3
					// aC[n,7] = Se campo e' editavel .t. se nao .f.
Local aCGD		:= {080,1,200,317}		//Array com coordenadas da GetDados no modelo2
Local lRet		:= .f.
Local aSize 	:= MsAdvSize()
					//1 -> Linha inicial ?rea trabalho.
					//2 -> Coluna inicial ?rea trabalho.
					//3 -> Linha final ?rea trabalho.
					//4 -> Coluna final ?rea trabalho.
					//5 -> Coluna final dialog (janela).
					//6 -> Linha final dialog (janela).
					//7 -> Linha inicial dialog (janela).
Local nOpcG		:= nOpcE
Local cItem		:= "01"
Private aCols	:= {}
Private aHeader	:= {}
Private INCLUIFT05	:= (nOpcE == 3)
Private ALTERAFT05	:= (nOpcE == 4)
Private EXCLUIFT05	:= (nOpcE == 5)

//??????????????????????????????????????????????????????????????Ŀ
//? Analisa se o chamado esta encerrado e nao permite manutencao ?
//????????????????????????????????????????????????????????????????
if (ALTERAFT05 .or. EXCLUIFT05) .and. SZM->ZM_STATUS = "9"
	Help(" ", 1, "ATENCAO", , "Este chamado est? encerrado, portanto n?o poder? ser alterado ou excluido. " + chr(13) + chr(10) + "(Espec?fico Brasitech). ", 1)
	Return()
endif

//?????????????????????????????????????????Ŀ
//? Criando variaveis M->ZM_??? da enchoice ?
//???????????????????????????????????????????
RegToMemory("SZM", INCLUI)

//????????????????????Ŀ
//? Montando o aHeader ?
//??????????????????????                   `
SX3->(dbSetOrder(1))
SX3->(dbSeek("SZN"))
do while SX3->( !eof() .and. X3_ARQUIVO = "SZN" )
	
	if x3Uso(SX3->X3_USADO) .and.;
		cNivel >= SX3->X3_NIVEL .and.;
		!AllTrim(SX3->X3_CAMPO) $ "ZN_FILIAL/ZN_NUM"
		
		SX3->( aAdd( aHeader, {	AllTrim(X3_TITULO),;
								X3_CAMPO,;
								X3_PICTURE,;
								X3_TAMANHO,;
								X3_DECIMAL,;
								X3_VLDUSER,;
								X3_USADO,;
								X3_TIPO,;
								X3_ARQUIVO,;
								X3_CONTEXT } ) )
	endif
	
	SX3->( dbSkip() )
enddo

nUsado := Len(aHeader)

//????????????????????????????Ŀ
//? Montando aCols da getdados ?
//??????????????????????????????
dbSelectArea("SZN")
dbSetOrder(1)
if INCLUI

	aCols 				:= {Array( nUsado+1 )}
	aCols[1, nUsado+1]	:= .F.
	for nI:=1 to nUsado
		aCols[1, nI]	:= CriaVar( aHeader[nI, 2] )
	next

	M->ZM_STATUS		:= "1"
	M->ZM_CODACAO		:= "1"

else

	aCols	:= {}
	SZN->( dbSetOrder(1) )
	SZN->( dbSeek( xFilial("SZN") + M->ZM_NUM ) )
	do while SZN->( !eof() .and. ZN_NUM = M->ZM_NUM )
		aAdd( aCols, Array( nUsado + 1 ) )
		for nI := 1 to nUsado
			aCols[Len(aCols), nI] 	:= SZN->( FieldGet( FieldPos( aHeader[nI,2] ) ) )
		next
		aCols[Len(aCols), nUsado + 1]	:=.F.
		cItem := SZN->ZN_ITEM
		SZN->( dbSkip() )
	enddo

endif

//???????????????????????????????????????????????????????????????????????????????????????Ŀ
//? Modelo3(cTitulo, cAliasEnchoice, cAliasGetD,, cLinOk, cTudOk, nOpcE, nOpcG, cFieldOk) ?
//? Parametros:                                                                           ?
//? NOME			TIPO   		DESCRICAO   									          ?
//? cTitulo			Caracter   	Titulo da janela (Obrigatorio)                            ?
//? cAlias   		Caracter   	Alias da Enchoice (Obrigatorio)      		       	      ?
//? cAlias2   		Caracter   	Alias da Getdados (Obrigatorio)      			          ?
//? aMyEncho   		Vetor   	Array com campos da enchoice                              ?
//? cLinhaOk   		Caracter   	Funcao para validacao da linha                            ?
//? cTudoOk   		Caracter   	Funcao para validacao na confirmacao                      ?
//? nOpcE   		Numerico   	nOpc da Enchoice                                          ?
//? nOpcG   		Numerico   	nOpc da Getdados                                          ?
//? cFieldOk   		Caracter   	Validacao para todos os campos da GetDados                ?
//? lVirtual   		Logico   	Permite visualizar campos virtuais na enchoice            ?
//? nLinhas   		Num?rico   	Numero maximo de linhas na getdados                       ?
//? aAltEnchoice   	Vetor   	Array com campos alteraveis da Enchoice                   ?
//? nFreeze   		Numerico   	Congelamento das colunas.                                 ?
//? aButtons   		Vetor   	Array com botoes de usuario na enchoicebar                ?
//? aCordW   		Vetor   	Coordenadas da janela                                     ?
//? nSizeHeader   	Numerico   	Altura da enchoice                                        ?
//?????????????????????????????????????????????????????????????????????????????????????????
//do while .T.

	if Modelo3(cCadastro, "SZM", "SZN",, "U_LiOKFT05()", "U_TdOKFT05()", nOpcE, nOpcG, "AllwaysTrue()", .T.,,, 1,,, 300)

	    //???????????????????????????????????????????????????????????????????Ŀ
		//? Tratamento do STATUS de acordo com as tratativas e codigo de acao ?
		//?????????????????????????????????????????????????????????????????????
		if nOpcE = 4
			cItem := Soma1(cItem,2)
						
			if M->ZM_CODACAO = "9"			//encerramento chamado
				M->ZM_STATUS := "4"
					
			elseif M->ZM_CODACAO = "3"		//interage com cliente
				M->ZM_STATUS := "3"

			elseif M->ZM_CODACAO = "4"		//retorno do cliente
				M->ZM_STATUS := "2"

			elseif M->ZM_CODACAO = "2" .or. SZM->ZM_STATUS = "1"	//transfere responsabilidade ou status esta em aberto 
				M->ZM_STATUS := "2"
			
			endif
	    			
		endif
		
		//???????????????????????????????Ŀ
		//? Gravacao de cabecalho         ?
		//?????????????????????????????????
		if nOpcE = 3
			SZM->( RecLock("SZM", .T.) )
			SZM->ZM_FILIAL	:= xFilial("SZM")
			SZM->ZM_NUM		:= M->ZM_NUM
			SZM->ZM_EMISSAO	:= M->ZM_EMISSAO
			SZM->ZM_CLIENTE	:= M->ZM_CLIENTE
			SZM->ZM_LOJA	:= M->ZM_LOJA
			SZM->ZM_NOMCLI	:= M->ZM_NOMCLI
			SZM->ZM_CONTATO	:= M->ZM_CONTATO
			SZM->ZM_EMAIL	:= M->ZM_EMAIL
			SZM->ZM_DDD		:= M->ZM_DDD
			SZM->ZM_TEL		:= M->ZM_TEL
			SZM->ZM_CODASS	:= M->ZM_CODASS
			SZM->ZM_ASSUNTO	:= M->ZM_ASSUNTO
			SZM->ZM_CODRESP	:= M->ZM_CODRESP
			SZM->ZM_NOMRESP	:= M->ZM_NOMRESP
			SZM->ZM_CODACAO	:= M->ZM_CODACAO
			SZM->ZM_STATUS	:= "1"
			SZM->( MsUnLock() )
		endif

		//???????????????????????????????Ŀ
		//? Gravacao de itens             ?
		//?????????????????????????????????
		if nOpcE = 3 .or. nOpcE = 4
		
			//Alteracao de Status
			if nOpcE = 4
				SZM->( RecLock("SZM", .F.) )
				SZM->ZM_STATUS	:= M->ZM_STATUS
				SZM->ZM_CODRESP	:= M->ZM_CODRESP
				SZM->ZM_NOMRESP	:= M->ZM_NOMRESP
				SZM->( MsUnLock() )
			endif
		
			SZN->( RecLock("SZN", .T.) )
			SZN->ZN_FILIAL	:= xFilial("SZN")
			SZN->ZN_NUM		:= M->ZM_NUM
			SZN->ZN_ITEM	:= cItem
			SZN->ZN_USUARIO	:= Substr(cUsuario, 7, 15)
			SZN->ZN_DATALOG	:= MsDate()
			SZN->ZN_HORALOG	:= Time()
			SZN->ZN_RESUMO	:= Left(M->ZM_COMENTA, Len(SZN->ZN_RESUMO))
			SZN->ZN_COMENTA	:= M->ZM_COMENTA						//Preenche na getdados, o conteudo informado na enchoice
			SZN->ZN_CODRESP	:= M->ZM_CODRESP
			SZN->ZN_NOMRESP	:= M->ZM_NOMRESP
			SZN->ZN_CODACAO	:= M->ZM_CODACAO
			SZN->( MsUnLock() )
		endif

		//?????????????????????????????????????????????????????Ŀ
		//? Envia e-mail a todos os cadastrados no departamento ?
		//???????????????????????????????????????????????????????
		Processa( {|| eMailFT05() }, "Preparando envio de e-mail..." )
	
//		if nOpcE=3
//			exit
//		endif
		
//	else
	
//		exit
		
	endif

/*
	aCols	:= {}
	SZN->( dbSetOrder(1) )
	SZN->( dbSeek( xFilial("SZN") + M->ZM_NUM ) )
	do while SZN->( !eof() .and. ZN_NUM = M->ZM_NUM )
		aAdd( aCols, Array( nUsado + 1 ) )
		for nI := 1 to nUsado
			aCols[Len(aCols), nI] 	:= SZN->( FieldGet( FieldPos( aHeader[nI,2] ) ) )
		next
		aCols[Len(aCols), nUsado + 1]	:=.F.
		SZN->( dbSkip() )
	enddo
*/
//enddo

dbSelectArea("SZM")
dbSetOrder(nOrdem)
Return()

/*
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????Ŀ??
???Funcao? FT05Legend   ? Por: Adalberto Moreno Batista ? Data ?02.07.2012???
??????????????????????????????????????????????????????????????????????????ٱ?
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
*/
User Function FT05Legend()
Local aCores	:= {	{"BR_VERDE",	"Ocorr?ncia em aberto" },;
						{"BR_AMARELO",	"Ocorr?ncia pendente internamente" },;
						{"BR_AZUL",		"Ocorr?ncia pendente no cliente" },;
						{"BR_VERMELHO",	"Ocorr?ncia finalizada" } }

BrwLegenda(cCadastro, "Legenda", aCores)

Return()


/*
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????Ŀ??
???Funcao? TdOKFT05     ? Por: Adalberto Moreno Batista ? Data ?23.07.2012???
??????????????????????????????????????????????????????????????????????????ٱ?
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
*/
User Function TdOKFT05()
Local lRet	:= .T.
Local cEol	:= Chr(13) + Chr(10)

if INCLUIFT05 .or. ALTERAFT05 .or. EXCLUIFT05

	if lRet .and. (ALTERAFT05 .or. EXCLUIFT05) .and. SZM->ZM_STATUS = "9"
		lRet := .F.
		Help(" ", 1, "ATEN??O", , "Este chamado est? encerrado, portanto n?o poder? ser alterado ou excluido. " + cEol + "(Espec?fico Brasitech). ", 1)
	endif
	
	if lRet .and. ALTERAFT05 .and. M->ZM_CODACAO = "1" .and. M->ZM_CODRESP != SZM->ZM_CODRESP
		lRet := .F.
		Help(" ", 1, "ATEN??O", , "Ao manter o status atual, o c?digo do departamento respons?vel n?o poder? ser alterado. " + cEol + "(Espec?fico Brasitech). ", 1)
	endif
		
	if lRet .and. ALTERAFT05 .and. M->ZM_CODACAO = "2" .and. M->ZM_CODRESP = SZM->ZM_CODRESP
		lRet := .F.
		Help(" ", 1, "ATEN??O", , "Ao transferir responsabilidade, o c?digo do departamento respons?vel dever? ser alterado. " + cEol + "(Espec?fico Brasitech). ", 1)
	endif
		
	if lRet .and. ALTERAFT05 .and. M->ZM_CODACAO = "3" .and. M->ZM_CODRESP != SZM->ZM_CODRESP
		lRet := .F.
		Help(" ", 1, "ATEN??O", , "Ao realizar uma intera??o com o cliente, o c?digo do departamento respons?vel n?o poder? ser alterado. " + cEol + "(Espec?fico Brasitech). ", 1)
	endif
	
	if lRet .and. ALTERAFT05 .and. M->ZM_CODACAO = "4" .and. SZM->ZM_STATUS != "3"
		lRet := .F.
		Help(" ", 1, "ATEN??O", , "Para haver um retorno do cliente ? necess?rio que o chamado esteja pendente com o cliente." + cEol + "(Espec?fico Brasitech). ", 1)
	endif
	
	if lRet .and. ALTERAFT05 .and. M->ZM_CODACAO = "4" .and. SZM->ZM_STATUS = "3" .and. M->ZM_CODRESP != SZM->ZM_CODRESP
		lRet := .F.
		Help(" ", 1, "ATEN??O", , "Para registro do retorno do cliente, o c?digo do departamento respons?vel n?o poder? ser alterado." + cEol + "(Espec?fico Brasitech). ", 1)
	endif

endif

Return(lRet)

/*
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????Ŀ??
???Funcao? LiOKFT05     ? Por: Adalberto Moreno Batista ? Data ?14.08.2012???
??????????????????????????????????????????????????????????????????????????ٱ?
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
*/
User Function LiOKFT05()
Local lRet	:= .T.

//????????????????????????????????????????????????????????Ŀ
//? Controle para nunca nao deixar linha do aCols deletada ?
//? O efeito eh somente estetico, uma vez que sempre gravo ?
//? o aCols nas tratativas e nunca as excluo ou altero.    ?
//??????????????????????????????????????????????????????????
if aCols[n, Len(aHeader) + 1]
	aCols[n, Len(aHeader) + 1] := .F.
endif

Return(.T.)

/*
???????????????????????????????????????????????????????????????????????????????????
???????????????????????????????????????????????????????????????????????????????????
???????????????????????????????????????????????????????????????????????????????Ŀ??
???Funcao? eMailFT05      ? Por: Adalberto Moreno Batista     ? Data ?23.07.2012???
????????????????????????????????????????????????????????????????????????????????ٱ?
???????????????????????????????????????????????????????????????????????????????????
???????????????????????????????????????????????????????????????????????????????????
*/
Static Function eMailFT05()
Local cAnexo, cErro, cMensagem, cAcao, nPos
Local nSeq		:= 0
Local cEol		:= Chr(13) + Chr(10)
Local aArea		:= GetArea()
Local cServer	:= AllTrim( GetMV('MV_RELSERV') )
Local cEnvia	:= AllTrim( GetMv('MV_RELACNT') )
Local cRecebe	:= DestFT05()
Local cPassword	:= AllTrim( GetMV('MV_RELPSW') )
Local cRelaUsr	:= AllTrim( GetMV("MV_RELAUSR",.F.,"") )
Local cRelaPsw	:= AllTrim( GetMV("MV_RELAPSW",.F.,"") )
Local cAccount	:= cEnvia
Local lRelAuth	:= GetMV("MV_RELAUTH",.F.,.F.)
Local cAssunto	:= "Brasitech - Registros de chamados de clientes nro " + SZM->ZM_NUM
Local aAcao		:= {	{"1", "Mantem Status"},;
						{"2", "Transfere responsabilidade"},;
						{"3", "Interage com cliente"},;
						{"4", "Retorno cliente"},;
						{"9", "Encerra chamado"} }
CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResultado

if lRelAuth

	MailAuth( cRelaUsr, cPassword )
	
endif

if lResultado
	
	cMensagem := '<html>'
	cMensagem += '<body>'
	
	cMensagem += '<p><b><font face="Calibri" color="#808080">BRASITECH IND?STRIA E COM?RCIO DE APARELHOS PARA BELEZA LTDA</font></b></p>'
	cMensagem += '<p style="margin-top: 0; margin-bottom: 0">&nbsp;</p>'
	cMensagem += '<table border="1" width="52%" cellspacing="0">'
	cMensagem += '	<tr>'
	cMensagem += '		<td width="90" align="right"><font face="Verdana" size="2">Chamado:</font></td>'
	cMensagem += '		<td><font face="Verdana" size="2">' + SZM->ZM_NUM + '</font></td>'
	cMensagem += '	</tr>'
	cMensagem += '	<tr>'
	cMensagem += '		<td width="90" align="right"><font face="Verdana" size="2">Emiss?o:</font></td>'
	cMensagem += '		<td><font face="Verdana" size="2">' + dTOc(SZM->ZM_EMISSAO) + '</font></td>'
	cMensagem += '	</tr>'
	cMensagem += '	<tr>'
	cMensagem += '		<td width="90" align="right"><font face="Verdana" size="2">Cliente:</font></td>'
	cMensagem += '		<td><font face="Verdana" size="2">' + SZM->ZM_CLIENTE + '/' + SZM->ZM_LOJA + ' - ' + SZM->ZM_NOMCLI + '</font></td>'
	cMensagem += '	</tr>'
	cMensagem += '	<tr>'
	cMensagem += '		<td width="90" align="right"><font face="Verdana" size="2">Contato:</font></td>'
	cMensagem += '		<td><font face="Verdana" size="2">' + SZM->ZM_CONTATO + '</font></td>'
	cMensagem += '	</tr>'
	cMensagem += '	<tr>'
	cMensagem += '		<td width="90" align="right"><font face="Verdana" size="2">e-mail:</font></td><td><font face="Verdana" size="2">'
	cMensagem += '		<a href="mailto:' + SZM->ZM_EMAIL + '">' + SZM->ZM_EMAIL + '</a></font></td>'
	cMensagem += '	</tr>'
	cMensagem += '	<tr>'
	cMensagem += '		<td width="90" align="right"><font face="Verdana" size="2">Telefone:</font></td>'
	cMensagem += '		<td><font face="Verdana" size="2">(' + SZM->ZM_DDD + ') ' + SZM->ZM_TEL + '</font></td>'
	cMensagem += '	</tr>'
	cMensagem += '	<tr>'
	cMensagem += '		<td width="90" align="right"><font face="Verdana" size="2">Assunto:</font></td>'
	cMensagem += '		<td><font face="Verdana" size="2">' + SZM->ZM_ASSUNTO + '</font></td>'
	cMensagem += '	</tr>'
	cMensagem += '</table>'
	
	cMensagem += '<p style="margin-top: 0; margin-bottom: 0">&nbsp;</p>'
	cMensagem += '<table border="1" width="73%" cellspacing="0">'
	cMensagem += '	<tr>'
	cMensagem += '		<td width="55%" bgcolor="#336699"><font face="Calibri" size="2" color="#FFFFFF">Descri??o</font></td>'
	cMensagem += '		<td width="10%" bgcolor="#336699"><font face="Calibri" size="2" color="#FFFFFF">Data / Hora Ocorr?ncia</font></td>'
	cMensagem += '		<td width="15%" bgcolor="#336699"><font face="Calibri" size="2" color="#FFFFFF">Registrado por</font></td>'
	cMensagem += '		<td width="20%" bgcolor="#336699"><font face="Calibri" size="2" color="#FFFFFF">A??o</font></td>'
	cMensagem += '	</tr>'
	
	SZN->( dbSetOrder(1) )
	SZN->( dbSeek(xFilial("SZN") + SZM->ZM_NUM) )
	do while SZN->( !eof() .and. ZN_FILIAL = xFilial("SZN") .and. ZN_NUM = SZM->ZM_NUM )
		nPos := aScan(aAcao, {|x| x[1]=SZN->ZN_CODACAO})
		cAcao := iif( nPos > 0, aAcao[nPos,2], "")
		
		cMensagem += '	<tr>'
		cMensagem += '		<td width="55%"><p style="margin-top: 0; margin-bottom: 0"><font face="Calibri" size="2">' + SZN->ZN_COMENTA + '</font></td>'
		cMensagem += '		<td width="10%"><p style="margin-top: 0; margin-bottom: 0"><font face="Calibri" size="2">' + dTOc(SZN->ZN_DATALOG) + ' ' + SZN->ZN_HORALOG + '</font></td>'
		cMensagem += '		<td width="15%"><p style="margin-top: 0; margin-bottom: 0"><font face="Calibri" size="2">' + SZN->(AllTrim(ZN_NOMRESP) + chr(13) + chr(10) + " (" + AllTrim(ZN_USUARIO)) + ")" + '</font></td>'
		cMensagem += '		<td width="20%"><p style="margin-top: 0; margin-bottom: 0"><font face="Calibri" size="2">' + cAcao + '</font></td>'
		cMensagem += '	</tr>
		
		SZN->( dbSkip() )
	enddo
	
	cMensagem += '</table>'
	cMensagem += '<p><i><font size="1" face="Verdana">E-mail autom?tico enviado pelo sistema Microsiga Protheus. Favor n?o respond?-lo.</font></i></p>'
	cMensagem += '</body>'
	cMensagem += '</html>'
	
	//cMensagem += '<tr>'
	//cMensagem += '<td width="16%" align="left"><font size="2.5" face="Calibri"><b>ATIVOS</b></font></td>'
	//for nK := 1 to len(aTabela)
	//	cMensagem += '<td width="7%" align="right"><font size="2" face="Calibri"><b>' + Transf(aTabela[nK,2],"@E 999,999") + '</b></font></td>'
	//next
	//cMensagem += '</tr>'
	
	SEND MAIL FROM cAccount TO cRecebe SUBJECT cAssunto BODY cMensagem RESULT lEnviado
	
	GET MAIL ERROR cErro
	ConOut("Falha no envio do e-mail. Verifique se o e-mail destino ? valido ou se o tempo de resposta do servidor e e-mails foi superior ao configurado no parametro MV_RELTIME " + cErro)
	
else

	ConOut("Nao foi possivel conectar o servidor de e-mails. Verifique se o tempo de resposta do servidor e e-mails foi superior ao configurado no parametro MV_RELTIME")
	
endif
	
DISCONNECT SMTP SERVER RESULT lResultado

//???????????????????????????Ŀ
//| Restaura area de trabalho |
//?????????????????????????????
RestArea(aArea)

Return()

/*
???????????????????????????????????????????????????????????????????????????????????
???????????????????????????????????????????????????????????????????????????????????
???????????????????????????????????????????????????????????????????????????????Ŀ??
???Funcao? DestFT05       ? Por: Adalberto Moreno Batista     ? Data ?13.08.2012???
????????????????????????????????????????????????????????????????????????????????ٱ?
???????????????????????????????????????????????????????????????????????????????????
???????????????????????????????????????????????????????????????????????????????????
*/
Static Function DestFT05()
Local cRet := ""

SZO->( dbSetOrder(1) )
SZO->( dbSeek( xFilial("SZO") + SZM->ZM_CODRESP ) )
do while SZO->( !eof() .and. ZO_FILIAL = xFilial("SZO") .and. ZO_CODRESP = SZM->ZM_CODRESP )
	cRet += iif( !empty(cRet), "; ", "") + AllTrim(SZO->ZO_EMAIL)
	SZO->( dbSkip() )
enddo

if empty(cRet)
	Help(" ", 1, "ATEN??O", , "N?o foi poss?vel montar lista de e-mails para este departamento. Verifique o cadastro de departamentos x usu?rios." + cEol + "(Espec?fico Brasitech). ", 1)
endif

Return(cRet)
