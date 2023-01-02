#include "rwmake.ch"
#include "protheus.ch"
#include "totvs.ch"
//#include "dialog.ch"
//#include "font.ch"
//#include "colors.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		BFATA03                                                      /@
@type			User function                                                /@
@date			26/12/2011                                                   /@
@description	Função para o gerenciamento de movimentos VPC                /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
——————————————————————————————————————————————————————————————————————————————————————————————————————————
Em 06/06/19
- Eliminada a função de "consulta saldo", pois há movimentos que estão registrados somente
  no sistema web e prejudicam o resultado final do saldo.
- Na criacao de movimentos financeiros, o sistema traz todos os processos válidos para uso
  e apresenta ao usuário para que escolha e na confirmacao, cria os titulos CP ou CR NCC de
  acordo com o que já está previamente cadastrado na ZZV
Em 19/08/19
- Eliminação de todas as verificações de saldo VPC, pois o saldo é verificado no sitema WEB 
  (partes do código foram comentados)
/*/
User Function BFATA03()
Local aAreaSX3		:= SX3->(GetArea())
Local aCores 		:= {	{"ZK_TIPO = 'CR'",		"BR_VERDE" 		},;
							{"ZK_TIPO = 'DB'",		"BR_VERMELHO"	}}
Local lContinua
Private cCadastro	:= "Movimentações VPC"
Private aRotina 	:= {	{"Pesquisar",			"AxPesqui",			0, 1},;
							{"Visualizar",			"AxVisual",			0, 2},;
							{"Movim. Manual",		"U_IncMov_FT03",	0, 3},;
							{"Movim. Ped. Bonif.",	"U_PedVen_FT03",	0, 3},;
							{"Movim. Financeiro",	"U_UsaCrd_FT03",	0, 3},;
							{"Exclui Movimento",	"U_CanMov_FT03",	0, 5},;
							{"Exclui Mov.Financ",	"U_CanFin_FT03",	0, 5},;
							{"Legenda",				"U_Legend_FT03",	0, 6} }
//{"Consulta Saldo",		"U_ConSld_FT03",	0, 5},;

SX3->(dbSetOrder(2))
lContinua := SX3->(dbSeek("ZK_CHAVE"))
RestArea(aAreaSX3)

if lContinua

	dbSelectArea("SZK")
	mBrowse(,,,, "SZK",,,,,, aCores)

else

	Help(" ", 1, "ATENÇÃO",, "Esta empresa não possui configuração para uso de controle VPC." + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Brasitech)", 1)

endif

Return()


/*
———————————————————————————————————————————————————————————————————————————————
@function		Legend_FT03                                                  /@
@type			User function                                                /@
@date			26/12/2011                                                   /@
@description	Função para apresentação da legenda                          /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
*/
User Function Legend_FT03()
Local aCores 	:= {	{"BR_VERDE",		"Valores de créditos"  	},;
						{"BR_VERMELHO", 	"Valores de débitos" 	} }

BrwLegenda(cCadastro, 'Legenda', aCores)

Return()


/*
———————————————————————————————————————————————————————————————————————————————
@function		IncMov_FT03                                                  /@
@type			User function                                                /@
@date		  	02/06/2014                                                   /@
@description	Função para inclusão de movimentos manuais                   /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
*/
User Function IncMov_FT03()
Local nReg	:= SZK->(RecNo())

AxInclui("SZK", nReg, 3,,,,"U_VldInc_FT03()",,,,,,.T.)

Return()

/*
———————————————————————————————————————————————————————————————————————————————
@function		VldInc_FT03                                                  /@
@type		 	User function                                                /@
@date			02/06/2014                                                   /@
@description	Função para validação da inclusão de movimentos manuais      /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
*/
User Function VldInc_FT03()
Local lRet		:= .F.
Local cEol		:= Chr(13) + Chr(10) + Chr(13) + Chr(10)
Local cMens 	:= "Código de cliente não encontrado ou bloqueado para uso ou verifique a obrigatoriedade de informar a loja do cliente."
//Local nSldVPC, nK

SA1->(dbSetOrder(1))
if empty(M->ZK_LOJA)

	SA1->(dbSeek(xFilial("SA1") + M->ZK_CLIENTE))
	do while SA1->(!eof() .and. A1_FILIAL + A1_COD == xFilial("SA1") + M->ZK_CLIENTE)
		if SA1->A1_MSBLQL != '1' .and. SA1->A1_X_MDVPC == "C"
			lRet := .T.
			exit
		endif
		SA1->(dbSkip())
	enddo

else
    
	if SA1->(dbSeek(xFilial("SA1") + M->ZK_CLIENTE + M->ZK_LOJA))
		if SA1->A1_MSBLQL != '1'
			lRet := .T.
			M->ZK_LOJA := iif(SA1->A1_X_MDVPC == "C", "  ", M->ZK_LOJA)
		endif
	endif

endif

if !lRet
    
	Help(" ", 1, "ATENÇÃO",, cMens + cEol + "(Específico Brasitech). ", 1)

endif

//———————————————————————————————————————————————————————————————————————————————
// Se movimento de débito, verificar se há saldo disponível
// retirado em 19/08/19, por Adalberto pois o saldo é verificado no sistema WEB
//———————————————————————————————————————————————————————————————————————————————
/*
if M->ZK_TIPO == "DB" .and. lRet
	for nK := 1 to 3
		if Substr(M->ZK_USO, nK, 1) == "S"
			nSldVPC := 0
			U_VPCCalcSld( M->ZK_CLIENTE, M->ZK_LOJA, AllTrim(Str(nK)), @nSldVPC, dDataBase)
			if nSldVPC < M->ZK_VALOR
				lRet := .F.
				Help(" ", 1, "ATENÇÃO",, "O cliente não possui saldo VPC disponível para este débito." + chr(13) + chr(10) + "(Específico Brasitech)", 1)
				exit
			endif
		endif
   next
endif
*/

Return(lRet)


/*
———————————————————————————————————————————————————————————————————————————————
@function		VPCGrava_FT03                                                /@
@type			User function                                                /@
@date			18/10/2013                                                   /@
@description	Função para gravação dos movimentos VPC

                Tipos de chave VPC
                ZK_TPCHV = "1" -> credito/debito por nota fiscal de saida
                ZK_TPCHV = "2" -> debito/credito por pedido de bonificacao
                ZK_TPCHV = "3" -> debito por NCC
                ZK_TPCHV = "4" -> debito/credito por devolucoes
                ZK_TPCHV = "5" -> debito/credito por transferencia
                ZK_TPCHV = " " -> debito/credito avulsos

                cTipo		 - Tipo do movimento "CR" para crédito e "DB" 
                               para débito
                cCliente	 - Código do cliente
                cLoja	  	 - Loja do cliente, qdo o contrato exigir. 
                               Somente para situações com contrato VPC
                cContrato	 - Codigo do contrato VPC
                cTpVPC		 - Tipo do percentual VPC
                nBase		 - Valor da base de cálculo
                nValor		 - Valor do débito ou crédito do movimento
                cHistorico	 - Campo descritivo com o histórico do 
                               lançamento 
                cTpChv		 - Origem do lançamento ZK_TPCHV
                cChave		 - Chave do registro que originou o lançamento
                cUso	  	 - Uso da VPC onde deve ser respondido S/N para
                               as situações: NCC / CtaPag / Ped.Bonificados
                dDtMov		 - Data do movimento
                nPerc        - Percentual VPC
                cSolicitacao - Numero da solicitacao (ZZV), cadastrada no 
                               sistema web.
                aNF          - Array com {Número NF, Série NF} da NF que 
                               gerou o movimento.                            /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use		  	Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
*/
User Function VPCGrava_FT03(cTipo, cCliente, cLoja, cContrato, cTpVPC, nBase, nValor,;
                            cHistorico, cTpChv, cChave, cUso, dDtMov, nPerc, cSolicitacao,;
							aNF, aDocEnt)
Default nPerc 		 	:= 0		//iif(nPerc == NIL, 0, nPerc)
Default cSolicitacao 	:= ""		//iif(cSolicitacao == NIL, "", cSolicitacao)
Default aNF          	:= {}		//iif(aNF == NIL, {}, aNF)
Default aDocEnt			:= {}

if nValor > 0
	SZK->(RecLock("SZK", .T.))
	SZK->ZK_FILIAL		:= xFilial("SZK")
	SZK->ZK_TIPO		:= cTipo
	SZK->ZK_CLIENTE		:= cCliente
	SZK->ZK_LOJA		:= cLoja
	SZK->ZK_CONTRAT		:= cContrato
	SZK->ZK_TPVPC		:= cTpVPC
	SZK->ZK_DATA		:= dDtMov
	SZK->ZK_BASCALC		:= nBase
	SZK->ZK_VALOR		:= nValor
	SZK->ZK_HISTOR		:= cHistorico
	SZK->ZK_TPCHV		:= cTpChv
	SZK->ZK_CHAVE		:= cChave
	SZK->ZK_USO			:= cUso
	SZK->ZK_FILORI		:= SM0->M0_CODFIL
	SZK->ZK_PERC		:= nPerc
	SZK->ZK_SOLICIT		:= cSolicitacao
    if Len(aNF) > 0	//SZK->(FieldPos("ZK_NF")) > 0 .and. SZK->(FieldPos("ZK_SERIE")) > 0
        SZK->ZK_NF		:= aNF[1]
        SZK->ZK_SERIE	:= aNF[2]
    endif
    if Len(aDocEnt) == 4 .and. SZK->(FieldPos("ZK_DOCENT")) > 0
        SZK->ZK_DOCENT	:= aDocEnt[1]
        SZK->ZK_SERENT	:= aDocEnt[2]
		SZK->ZK_FORENT	:= aDocEnt[3]
		SZK->ZK_LOJENT	:= aDocEnt[4]
    endif

    SZK->(MsUnlock())
endif

Return()


/*
———————————————————————————————————————————————————————————————————————————————
@function		VPCApaga_FT03                                                /@
@type			User function                                                /@
@date			12/07/2013                                                   /@
@description	Função para exclusão de movimentos VPC
				cChave		- Chave para a pesquisa                          /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
*/
User Function VPCApaga_FT03(cTpChave, cChave)
Local nTotalCtb := 0
Local cLP		 := "411"
Local cLote		 := "VPC001"
Local cArqCtb	 := ""
Local nHdlPrv	 := 0
Local lVisual	 := .F.
Local lAglutina := .F.

//———————————————————————————————————————————————————————————————————————————————
// Inicializa o arquivo de contabilizacao 
//———————————————————————————————————————————————————————————————————————————————
nHdlPrv := HeadProva(cLote, "BCTBA01", Substr(cUsuario,7,6), @cArqCtb)

ZZV->(dbSetOrder(1))
SZK->(dbSetOrder(2))
do while .T.

	if SZK->(dbSeek(xFilial("SZK") + cTpChave + cChave))

		//———————————————————————————————————————————————————————————————————————————————
		// Registra o lançamento
		//———————————————————————————————————————————————————————————————————————————————
		if VerPadrao(cLP) .and. !empty(SZK->ZK_DTCTB) .and. nHdlPrv > 0
			nTotalCtb  += DetProva(nHdlPrv, cLP, "BCTBA01", cLote)
		endif

		//———————————————————————————————————————————————————————————————————————————————
		// Retorno flag da autorizacao VPC registrada no sistema web (ZZK)
		//———————————————————————————————————————————————————————————————————————————————
		if !empty(SZK->ZK_SOLICIT)
			ZZV->(dbSeek(xFilial("ZZV") + SZK->ZK_SOLICIT + SZK->ZK_TPVPC))
			do while ZZV->(!eof() .and. ZZV_FILIAL == xFilial("ZZV") .and. ZZV_NUM == SZK->ZK_SOLICIT .and. ZZV_TPVPC == SZK->ZK_TPVPC)
				ZZV->(RecLock("ZZV",.F.))
				ZZV->ZZV_STATUS := "A"	//retorno o status anterior
				ZZV->(MsUnlock())
				ZZV->(dbSkip())
			enddo
		endif

		//———————————————————————————————————————————————————————————————————————————————
		// Apaga o lançamento
		//———————————————————————————————————————————————————————————————————————————————
		SZK->(RecLock("SZK",.F.))
		SZK->(dbDelete())
		SZK->(MsUnlock())
		
	else

		exit

	endif
	
enddo

//———————————————————————————————————————————————————————————————————————————————
// Gera a contabilização
//———————————————————————————————————————————————————————————————————————————————
if nHdlPrv > 0 .and. nTotalCtb > 0

	RodaProva(nHdlPrv, nTotalCtb)
	cA100Incl(cArqCtb, nHdlPrv, 1, cLote, lVisual, lAglutina)

endif

SZK->(dbSeek(xFilial("SZK")))
Return()


/*
———————————————————————————————————————————————————————————————————————————————
@function		VPCFindCt_FT03                                               /@
@type		 	User function                                                /@
@date			18/10/2013                                                   /@
@description	Função para busca do código do contrato VPC do cliente       /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
*/
User Function VPCFindCt_FT03(cCliente, cLoja)
Local cRet		:= ""
Local aArea		:= GetArea()
Local aAreaSA1	:= SA1->(GetArea())
Local cChvSZJ	:= cCliente + Space(Len(SZJ->ZJ_LOJA))

//———————————————————————————————————————————————————————————————————————————————
// Ordeno as tabelas
//———————————————————————————————————————————————————————————————————————————————
SA1->(dbSetOrder(1))		//A1_FILIAL+A1_COD+A1_LOJA
SZJ->(dbSetOrder(2))		//ZJ_FILIAL+ZJ_CLIENTE+ZJ_LOJA+ZJ_CONTRAT

//———————————————————————————————————————————————————————————————————————————————
// Verifico se o cliente possui o controle consolidado ou por loja
//———————————————————————————————————————————————————————————————————————————————
if SA1->(dbSeek(xFilial("SA1") + cCliente + cLoja))
	if SA1->A1_X_MDVPC == "L"
		cChvSZJ := cCliente + cLoja
	endif
endif

//———————————————————————————————————————————————————————————————————————————————
// Pesquiso o contrato
//———————————————————————————————————————————————————————————————————————————————
if SZJ->(dbSeek(xFilial("SZJ") + cChvSZJ))
	cRet := SZJ->ZJ_CONTRAT
endif

RestArea(aAreaSA1)
RestArea(aArea)
Return(cRet)


/*
———————————————————————————————————————————————————————————————————————————————
@function		VPCCalcSld                                                   /@
@type		 	User function                                                /@
@date			06/01/2012                                                   /@
@description	Função para calcular o saldo disponivel VPC
				cCliente - 	Código do cliente o qual deseja saber o saldo
				cLoja - 	Código da loja do cliente para casos onde se 
							deseja saber o saldo de um cliente individual. 
							Caso não tenha esta necessidade este parametro 
							deverá receber ""
				cQual -		Indica qual será o uso do saldo:
							1-NCC
							2-Contas a pagar
							3-Pedidos bonificados	                         
				nSaldo -	Variável enviada como referência (@variável), que
							receberá o saldo total disponível
				dDtFim - 	Parâmetro para informar até qual data se deseja 
							saber o saldo                                    /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
retirado em 19/08/19 por Adalberto
saldo é verificado no sistema WEB

User Function VPCCalcSld(cCliente, cLoja, cQual, nSaldo, dDtFim)
Local aRet		:= {}
Local aRetTmp	:= {}
Local aArea		:= GetArea()
Local cQuery, nPos, nCred, nDeb

cQuery	:= "SELECT ZK_TPVPC, ZK_USO, SUM(ZK_VALOR) CREDITO, 0 DEBITO "
cQuery	+=	"FROM " + RetSqlName("SZK") + " SZK "
cQuery	+= "WHERE ZK_FILIAL = '" + xFilial("SZK") + "' "
cQuery	+=	      "AND ZK_CLIENTE = '" + cCliente + "' "
cQuery	+=	      "AND ZK_LOJA = '" + cLoja + "' "
cQuery	+=       "AND ZK_TIPO = 'CR' "
cQuery	+= 	   "AND SUBSTRING(ZK_USO, " + cQual + ", 1) = 'S' "
if dDtFim != NIL
	cQuery	+=    "AND ZK_DATA <= '" + dTOs(dDtFim) + "' "
endif
cQuery	+= 	   "AND SZK.D_E_L_E_T_ = ' ' "
cQuery	+= 	   "GROUP BY ZK_TPVPC, ZK_USO "
cQuery	+= "UNION "
cQuery	+= "SELECT ZK_TPVPC, ZK_USO, 0 CREDITO, SUM(ZK_VALOR) DEBITO "
cQuery	+= "FROM " + RetSqlName("SZK") + " SZK "
cQuery	+= "WHERE ZK_FILIAL = '" + xFilial("SZK") + "' "
cQuery	+= 		  "AND ZK_CLIENTE = '" + cCliente + "' "
cQuery	+=	        "AND ZK_LOJA = '" + cLoja + "' "
cQuery	+=		     "AND ZK_TIPO = 'DB' "
cQuery	+= 		  "AND SUBSTRING(ZK_USO, " + cQual + ", 1) = 'S' "
if dDtFim != NIL
	cQuery	+=	     "AND ZK_DATA <= '" + dTOs(dDtFim) + "' "
endif
cQuery	+= 		  "AND SZK.D_E_L_E_T_ = ' ' "
cQuery	+= "GROUP BY ZK_TPVPC, ZK_USO "

if Select("SLDVPC") > 0
	SLDVPC->(dbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TCGENQRY(,,ChangeQuery(cQuery)), "SLDVPC", .F., .T.)

dbSelectArea("SLDVPC")
do while !eof()
	nCred	:= iif(CREDITO != NIL, CREDITO, 0)
	nDeb	:= iif(DEBITO != NIL, DEBITO, 0)
	nPos	:= aScan(aRetTmp, { |x| x[1] == SLDVPC->ZK_TPVPC .and. x[3] == SLDVPC->ZK_USO })
	
	if (nCred - nDeb) != 0
		if nPos == 0
			aAdd(aRetTmp, { SLDVPC->ZK_TPVPC, (nCred - nDeb), SLDVPC->ZK_USO })
		else
			aRetTmp[nPos, 2] += (nCred - nDeb)
		endif
		
		nSaldo += (nCred - nDeb)
	endif
	
	dbSkip()

enddo

//Eliminando os elementos com saldo zero
for nPos := 1 to Len(aRetTmp)
	if aRetTmp[nPos,2] != 0
		aAdd(aRet, {aRetTmp[nPos,1], aRetTmp[nPos,2], aRetTmp[nPos,3]})
	endif
next

if Select("SLDVPC") > 0
	SLDVPC->(dbCloseArea())
endif

RestArea(aArea)
Return(aRet)
*/

/*
———————————————————————————————————————————————————————————————————————————————
@function		UsaCrd_FT03                                                  /@
@type	 		User function                                                /@
@date			23/10/2013                                                   /@
@description	Função para listar as aprovações de VPC para a criação de 
				título à receber (NCC) ou título à pagar.                    /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
em 10/06/19 - ajuste para buscar as aprovacoes realizadas
*/
User Function UsaCrd_FT03()
Local aArea			:= GetArea()
Local oDlg			:= NIL
Local oLbx			:= NIL
Local cAprVPC		:= ""
Local aAprovacoes	:= {}
Local nCol1			:= 600		//325
Local nCol2			:= Round(nCol1 * 2.03, 0)
Local cQuery		:= "SELECT ZZV_NUM, SUM(ZZV_VALOR) SOMATORIA " +;
							"FROM " + RetSqlName("ZZV") + " ZZV " +;
							"WHERE ZZV_FILIAL = '" + xFilial("ZZV") + "' AND ZZV_STATUS = 'A' AND ZZV.D_E_L_E_T_ = ' ' " +;
							"GROUP BY ZZV_NUM " +;
							"ORDER BY ZZV_NUM"
Local cNomeCli, cNomeFor

//———————————————————————————————————————————————————————————————————————————————
// Cria Consulta
//———————————————————————————————————————————————————————————————————————————————
SA1->(dbSetOrder(1))	//A1_FILIAL, A1_COD, A1_LOJA
SA2->(dbSetOrder(1))	//A2_FILIAL, A2_COD, A2_LOJA
ZZV->(dbSetOrder(1))	//ZZV_FILIAL, ZZV_NUM, ZZV_TPVPC

if Select("TEMP") > 0
	TEMP->(dbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TEMP", .F., .T.)

dbSelectArea("TEMP")
dbGoTop()
do while !eof()

	cNomeCli := ""
	cNomeFor	:= ""
	if ZZV->(dbSeek(xFilial("ZZV") + TEMP->ZZV_NUM)) .and. ZZV->ZZV_STATUS == "A"
	
		if SA1->(dbSeek(xFilial("SA1") + ZZV->ZZV_CLIENT + ZZV->ZZV_LOJA))
			cNomeCli := SA1->A1_NOME
		endif
		
		if !Empty(ZZV->ZZV_FORCOD)
			if SA2->(dbSeek(xFilial("SA2") + ZZV->ZZV_FORCOD + ZZV->ZZV_FORLOJ))
				cNomeCli := SA2->A2_NOME
			else
				cNomeFor	:= "NÃO ENCONTRADO! Cadastrá-lo antes de utilizar este valor."
			endif
		endif

		aAdd(aAprovacoes, {	TEMP->ZZV_NUM,;
							ZZV->ZZV_DATA,;
							ZZV->ZZV_CLIENT,;
							ZZV->ZZV_LOJA,;
							cNomeCli,;
							TEMP->SOMATORIA,;
							ZZV->ZZV_OBS,;
							ZZV->ZZV_ACAO,;
							ZZV->ZZV_TIPO,;
							ZZV->ZZV_FPAG,;
							ZZV->ZZV_DTNEG,;
							ZZV->ZZV_FORCOD,;
							ZZV->ZZV_FORLOJ,;
							cNomeFor	})

	endif
	
	dbSkip()
	
enddo

if Select("TEMP") > 0
	TEMP->(dbCloseArea())
endif

RestArea(aArea)

//———————————————————————————————————————————————————————————————————————————————
// Monta tela
//———————————————————————————————————————————————————————————————————————————————
if Len(aAprovacoes) > 0

	Define MSDialog oDlg Title "" From 0, 0 To 500, nCol2 Pixel
	oDlg:cTitle := "Selecione a aprovação VPC"
	@ 05, 05 Listbox oLbx Var cAprVPC Fields Header "Solicitação", "Data", "Cliente", "Loja Cliente", "Nome Cliente", "Valor", "Obs Usuário", "Ação", "Avulso/Contrato", "Desc.CR/C.Pagar", "Data Negociação", "Fornecedor", "Loja Fornec", "Nome Fornecedor" Size nCol1, 220 Of oDlg Pixel
	oLbx:SetArray(aAprovacoes)
	oLbx:bLine 		:= {|| {	aAprovacoes[oLbx:nAt,01],;
								aAprovacoes[oLbx:nAt,02],;
								aAprovacoes[oLbx:nAt,03],;
								aAprovacoes[oLbx:nAt,04],;
								aAprovacoes[oLbx:nAt,05],;
								Transform(aAprovacoes[oLbx:nAt,06], "@E 999,999,999.99"),;
								aAprovacoes[oLbx:nAt,07],;
								aAprovacoes[oLbx:nAt,08],;
								aAprovacoes[oLbx:nAt,09],;
								aAprovacoes[oLbx:nAt,10],;
								aAprovacoes[oLbx:nAt,11],;
								aAprovacoes[oLbx:nAt,12],;
								aAprovacoes[oLbx:nAt,13],;
								aAprovacoes[oLbx:nAt,14] }}
	oLbx:cToolTip   := oDlg:cTitle
	oLbx:lHScroll   := .F. // NoScroll 

	Define SButton From 230, 460 Type 1 Action (ProcTitulos(aAprovacoes[oLbx:nAt,01], aAprovacoes[oLbx:nAt,06]), oDlg:End()) OnStop "Seleciona" Enable Of oDlg
	Define SButton From 230, 520 Type 2 Action oDlg:End() OnStop "Abandona" Enable Of oDlg
	Activate MsDialog oDlg Center
	
else

	Help("", 1, "Sem aprovações",, "Não foram encontradas aprovações VPC." + chr(13) + chr(10) + "(Especifico Brasitech)", 1)
	
endif

Return()


/*
———————————————————————————————————————————————————————————————————————————————
@function		ProcTitulos                                                  /@
@type			Static function                                              /@
@date			23/10/2013                                                   /@
@description	Função para a verificação de saldo VPC por uso e apresentação
				de tela para informar o valor do crédito que será utilizado  /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
*/
Static Function ProcTitulos(cSolicitacao, nValor)		//cCliente, cLoja, nOpcao)
Local cBarras		:= Space(Len(SE2->E2_CODBAR))
Local dVencto		:= dDataBase
Local lLoja, cCliente, cLoja, nOpcao, cCodFor, cLojFor, cNomFor, cBanco, cAgenc,;
	  cConta, cDVA, cDVC, cHistor, nLin, cNumDoc, cSerDoc, cForDoc, cLojDoc
Private nUsoSld		:= nValor
Private aHeader		:= {}
Private aCols		:= {}

aAdd(aHeader, {"Tp.VPC", 	 "AA4_CODCLI", "@!", 					03, 0, ".F.",, "C", })   //AA4_CODCLI campo escolhido serve somente para aproveitar o when do dicionario de dados
aAdd(aHeader, {"Descrição",	 "AA4_CODCLI", "@!", 					30, 0, ".F.",, "C", })
aAdd(aHeader, {"Saldo",		 "AA4_CODCLI", "@E 999,999,999.99", 	12, 2, ".F.",, "N", })
aAdd(aHeader, {"Creditar",	 "AA4_CODCLI",	"@E 999,999,999.99", 	12, 2, ".F.",, "N", })
aAdd(aHeader, {"Uso", 		 "AA4_CODCLI", "@!", 				 	03, 0, ".F.",, "C", })

//———————————————————————————————————————————————————————————————————————————————
// Posiciono tabelas para montagem da tela
//———————————————————————————————————————————————————————————————————————————————
SA1->(dbSetOrder(1))	//A1_FILIAL, A1_COD
SA2->(dbSetOrder(1))	//A2_FILIAL, A2_COD
SZI->(dbSetOrder(1))	//ZI_FILIAL+ZI_COD
ZZV->(dbSetOrder(1))	//ZZV_FILIAL, ZZV_NUM, ZZV_TPVPC

ZZV->(dbSeek(xFilial("ZZV") + cSolicitacao))
cCliente	:= ZZV->ZZV_CLIENTE
cLoja		:= ZZV->ZZV_LOJA
nOpcao		:= iif(ZZV->ZZV_FPAG == "CR", 1, 2)
cCodFor		:= ZZV->ZZV_FORCOD
cLojFor		:= ZZV->ZZV_FORLOJ

cHistor		:= Space(Len(iif(nOpcao == 1, SE1->E1_HIST, SE2->E2_HIST)))
nLin		:= iif(nOpcao == 1, 55, 130)

cNumDoc		:= Space(9)
cSerDoc		:= Space(3)
cForDoc		:= Space(8)
cLojDoc		:= Space(2)

do while ZZV->(!eof() .and. ZZV_NUM == cSolicitacao)
	SZI->(dbSeek(xFilial("SZI") + ZZV->ZZV_TPVPC))
	aAdd(aCols, {ZZV->ZZV_TPVPC, SZI->ZI_DESCR, ZZV->ZZV_VALOR, ZZV->ZZV_VALOR, "SSS", .F.})
	ZZV->(dbSkip())
enddo

SA1->(dbSeek(xFilial("SA1") + cCliente + cLoja))
lLoja 	:= (SA1->A1_X_MDVPC == "L")
cNomCli	:= SA1->A1_NOME

if nOpcao == 2

	if SA2->(dbSeek(xFilial("SA2") + cCodFor + cLojFor))

		if SA2->(FieldPos("A2_MSBLQL")) > 0 .and. SA2->A2_MSBLQL != "1"

			cLojFor	:= SA2->A2_LOJA
			cNomFor	:= SA2->A2_NOME
			cNomFor	:= SA2->A2_NOME
			cBanco	:= SA2->A2_BANCO
			cAgenc	:= SA2->A2_AGENCIA
			cConta	:= SA2->A2_NUMCON
			cDVA	:= SA2->A2_DVAGE
			cDVC	:= SA2->A2_DVCTA

			//———————————————————————————————————————————————————————————————————————————————
			// Se fornecedor está configurado como depósito em conta, os dados bancários 
			// devem estar devidamente preenchidos
			//———————————————————————————————————————————————————————————————————————————————
			if SA2->A2_X_FGTO == "4" .and. (Empty(SA2->A2_BANCO) .or. Empty(SA2->A2_AGENCIA) .or. Empty(SA2->A2_NUMCON))
				Help(" ", 1, "ATENÇÃO",, "A forma de pagamento, indicada no cadastro do fornecedor informa que trata-se de um depósito em conta, porém as informações de banco/agência/conta estão incompletas. Corrija o cadastro do fornecedor para prosseguir com a operação." + chr(13) + chr(10) + "(Específico Brasitech). ", 1)
				Return()
			endif

		else

			Help(" ", 1, "ATENÇÃO", , "Fornecedor bloqueado para uso." + chr(13) + chr(10) + "(Específico Brasitech). ", 1)
			Return()

		endif

	else
	
		Help(" ", 1, "ATENÇÃO", , "Fornecedor não encontrado." + chr(13) + chr(10) + "(Específico Brasitech). ", 1)
		Return()
	
	endif

endif

@ 006,005 to 465,630 Dialog oListaSld Title "Baixa VPC com criação de título à " + iif(nOpcao == 1, "receber (NCC)", "pagar")

@ 010,010 Say OemToAnsi("Cliente:") Size 30,8 Pixel
@ 009,045 Get cCliente Size 045,10 when .F. Pixel
@ 009,095 Get cLoja Size 015,10 when .F. Pixel
@ 009,115 Get cNomCli Size 180,10 when .F. Pixel

@ 025,010 Say OemToAnsi("Usar Valor:") Size 50,8 Pixel
@ 024,045 Get nValor Size 050,10 Picture "@E 999,999,999.99" When .F. Pixel
@ 025,180 Say OemToAnsi("Dt. Vencto:") Size 40,8 Pixel
@ 024,220 Get dVencto Size 50,10 Valid dVencto >= dDataBase Pixel

@ 040,010 Say OemToAnsi("Histórico:") Size 25,8 Pixel
@ 039,045 Get cHistor Size 230,10 Pixel

//———————————————————————————————————————————————————————————————————————————————
// Necessário informar o código do fornecedor para criar o titulo à pagar
//———————————————————————————————————————————————————————————————————————————————
if nOpcao == 2

	@ 070,010 Say OemToAnsi("N.Fiscal:") Size 30,8 Pixel
	@ 069,045 Get cNumDoc Size 045,10 Picture "@!" F3 "SF1"	Valid VldNF(cNumDoc,@cSerDoc,@cForDoc,@cLojDoc,@cBarras,@cBanco, @cAgenc,@cDVA,@cConta,@cDVC)
	@ 069,095 Get cSerDoc Size 020,10 when .f. Pixel	//Picture "@!" Valid Empty(cLojFor) .or. VldForTit(cCodFor, @cLojFor, @cNomFor, cCliente, cLoja)
	@ 069,120 Get cForDoc Size 040,10 when .F. Pixel
	@ 069,165 Get cLojDoc Size 015,10 when .F. Pixel

	@ 085,010 Say OemToAnsi("Fornecedor:") Size 30,8 Pixel
	@ 084,045 Get cCodFor Size 045,10 when .f. Pixel	//Picture "@!" F3 "SA2" Valid Empty(cCodFor) .or. VldForTit(cCodFor, @cLojFor, @cNomFor, cCliente, cLoja)
	@ 084,095 Get cLojFor Size 015,10 when .f. Pixel	//Picture "@!" Valid Empty(cLojFor) .or. VldForTit(cCodFor, @cLojFor, @cNomFor, cCliente, cLoja)
	@ 084,115 Get cNomFor Size 180,10 when .F. Pixel

	@ 100,010 Say OemToAnsi("Cód.Barras:") Size 30,8 Pixel
	@ 099,045 Get cBarras Size 180,10 Picture "@!" when Empty(cNumDoc) Pixel Valid Empty(cBarras) .or. (VldCodBar(cBarras) .and. U_ChkCodBar(cBarras) .and. U_VlCodBar(cBarras))

	@ 115,010 Say OemToAnsi("Banco:") Size 20,8 Pixel
	@ 114,045 Get cBanco Size 20,10 Picture "999" when Empty(cNumDoc) Pixel
	@ 115,080 Say OemToAnsi("Agência:") Size 25,8 Pixel
	@ 114,110 Get cAgenc Size 30,10 Picture "@!" when Empty(cNumDoc) Pixel
	@ 114,145 Get cDVA Size 12,10 Picture "@!" when Empty(cNumDoc) Pixel
	@ 115,175 Say OemToAnsi("Conta Corrente:") Size 40,8 Pixel
	@ 114,220 Get cConta Size 50,10 Picture "@!" when Empty(cNumDoc) Pixel
	@ 114,275 Get cDVC Size 12,10 Picture "@!" when Empty(cNumDoc) Pixel

endif

@ nLin,005 to 205,310 MultiLine Modify //Delete //FREEZE 1

@ 210,210 Button OemToAnsi("Gravar") Size 36,14 Pixel Action Processa({|| GravaTitulo( cCliente,;
																						cLoja,;
																						cCodFor,;
																						cLojFor,;
																						cHistor,;
																						nOpcao,;
																						aCols,;
																						nUsoSld,;
																						lLoja,;
																						dVencto,;
																						{cBarras, cBanco, cAgenc, cDVA, cConta, cDVC},;
																						cSolicitacao,;
																						{cNumDoc, cSerDoc, cForDoc, cLojDoc})}, "Registrando o título...")
@ 210,260 Button OemToAnsi("Cancelar") Size 36,14 Pixel Action Close(oListaSld)

Activate Dialog oListaSld Centered

	
Return()

/*
———————————————————————————————————————————————————————————————————————————————
@function		GravaTitulo                                                  /@
@type			Static function                                              /@
@date			23/10/2013                                                   /@
@description	Função para criar um titulo NCC (SE1) ou a pagar (SE2), e os
				respectivos movimentos de DEBITO na tabela SZK               /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
*/
Static Function GravaTitulo(cCliente, cLojaCli, cFornecedor, cLojaFor, cHist, nOpcao, aCols, nUsoSld, lLoja, dVencto, aInfBanco, cSolicitacao, aDocEnt)
Local cNum, aTitulo, nK
Private lMsErroAuto := .F.

ZZV->(dbSetOrder(1))	//ZZV_FILIAL, ZZV_NUM, ZZV_TPVPC

//———————————————————————————————————————————————————————————————————————————————
// Analisando se algum valor foi informado para para uso
//———————————————————————————————————————————————————————————————————————————————
if nUsoSld > 0

	//———————————————————————————————————————————————————————————————————————————————
	// Grava o titulo NCC - SE1
	//———————————————————————————————————————————————————————————————————————————————
	if nOpcao == 1
	
		SA1->(dbSetOrder(1))
		
		if Empty(cCliente) .or. Empty(cLojaCli)

			Help(" ", 1, "ATENÇÃO",, "O código do cliente ou da loja do cliente, para a criação da NCC, não foi informado. O processo não será concluído." + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Brasitech)", 1)
		
    	elseif !SA1->(dbSeek(xFilial("SA1") + cCliente + cLojaCli))
    	
			Help(" ", 1, "ATENÇÃO",, "Cliente não encontrado. O processo não será finalizado." + chr(13) + chr(10) + "(Específico Brasitech)", 1)

		else
		
			SE1->(dbSetOrder(1))
			
			cNum		:= GetMV("BR_VPCNUM", .F.)
			do while SE1->(dbSeek(xFilial("SE1") + "VPC" + cNum))
				cNum	:= Soma1(cNum)
			enddo
			PutMV("BR_VPCNUM", cNum)
			
			aTitulo 	:= {	{"E1_PREFIXO",	"VPC",								Nil},;
								{"E1_NUM",		cNum,								Nil},;
								{"E1_PARCELA",	"",									Nil},;
								{"E1_TIPO",		"NCC",								Nil},;
								{"E1_NATUREZ",	GetMV("BR_VPCNATR", .F., ""),		Nil},;
								{"E1_CLIENTE",	cCliente,							Nil},;
								{"E1_LOJA",		cLojaCli,							Nil},;
								{"E1_NOMCLI" ,	Posicione("SA1", 1, xFilial("SA1") + cCliente + cLojaCli, "A1_NOME"), 	Nil},;
								{"E1_EMISSAO",	dDataBase,							Nil},;
								{"E1_VENCTO",	dVencto,							Nil},;
								{"E1_VENCREA",	DataValida(dVencto),				Nil},;
								{"E1_HIST",		cHist,								Nil},;
								{"E1_VALOR",	nUsoSld,							Nil},;
								{"E1_X_VPC",	"S",								Nil}	}
			
			MsExecAuto({ |x,y| FINA040(x,y) }, aTitulo, 3)
			
			if lMsErroAuto
			
				MostraErro()
				DisarmTransaction()
				Help(" ", 1, "ATENÇÃO",, "Ocorreu um problema na criação do título e o processo nao será concluído." + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Brasitech)", 1)
			
			else
			
				if Len(aCols) > 0
				
					for nK := 1 to Len(aCols)
						SZI->(dbSeek(xFilial("SZI") + aCols[nK,1]))
						cHistorico := 	"Debito por criacao NCC: " + SE1->(E1_PREFIXO + "/" + E1_NUM) +;
											", TpVPC: " + aCols[nK,1] + "-" + AllTrim(SZI->ZI_DESCR)
						//———————————————————————————————————————————————————————————————————————————————
						// Atualizando a tabela SZK - movimentos VPC
						// Função do fonte BFATA03.PRW
						// Parâmetros da função U_VPCGrava_FT03
						//	[1]- Tipo do movimento "CR" para crédito e "DB" para débito
						//	[2]- Código do cliente
						//	[3]- Loja do cliente, qdo o contrato exigir. Somente p/ situações com contrato VPC
						//	[4]- Codigo do contrato VPC
						//	[5]- Tipo do percentual VPC
						//	[6]- Valor da base de cálculo
						//	[7]- Valor do débito ou crédito do movimento
						//	[8]- Campo descritivo com o histórico do lançamento 
						//	[9]- Origem do lançamento
						//	[10]- Chave do registro que originou o lançamento
						//	[11]- Uso da VPC S/N para: NCC / CtaPag / Ped.Bonificados
						//	[12]- Data do movimento
						//———————————————————————————————————————————————————————————————————————————————
						U_VPCGrava_FT03("DB",;
										cCliente,;
										iif(lLoja, cLojaCli, ""),;
										"",;
										aCols[nK,1],;
										aCols[nK,4],;
										aCols[nK,4],;
										cHistorico,;
										"3",;
										SE1->(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO),;
										aCols[nK,5],;
										dDataBase,;
										0,;
										cSolicitacao)

						ZZV->(dbSeek(xFilial("ZZV") + cSolicitacao + aCols[nK,1]))
						do while ZZV->(!eof() .and. ZZV_FILIAL == xFilial("ZZV") .and. ZZV_NUM == cSolicitacao .and. ZZV_TPVPC == aCols[nK,1])
							ZZV->(RecLock("ZZV",.F.))
							ZZV->ZZV_STATUS := "P"	//Processado
							ZZV->(MsUnlock())
							ZZV->(dbSkip())
						enddo
						
					next
					
				endif

				MsgBox("Foi gerado o título: " + SE1->("FILIAL, PREFIXO-NÚMERO-PARCELA-TIPO: " + chr(13) + chr(10) + E1_FILIAL + ", " + E1_PREFIXO + "-" + E1_NUM + "-" + E1_PARCELA + "-" + E1_TIPO + ", com vencimento em " + dTOc(E1_VENCTO)), "Título", "INFO")
				
			endif

			Close(oListaSld)
			
        endif
        

	//———————————————————————————————————————————————————————————————————————————————
	// Grava o titulo a pagar - SE2
	//———————————————————————————————————————————————————————————————————————————————
    elseif nOpcao == 2
    
		//———————————————————————————————————————————————————————————————————————————————
		// Verifico se há vinculo de nota fiscal e não gero titulo a pagar
		//———————————————————————————————————————————————————————————————————————————————
		if !Empty(aDocEnt[1]) .and. Len(aCols) > 0
					
			for nK := 1 to Len(aCols)
				SZI->(dbSeek(xFilial("SZI") + aCols[nK,1]))
				cHistorico := 	"Debito CP - vinculado ao docto entrada: " + aDocEnt[1] + "/" + aDocEnt[2] + "/" + aDocEnt[3] + "/" + aDocEnt[4] +;
									", TpVPC: " + aCols[nK,1] + "-" + AllTrim(SZI->ZI_DESCR)
				//———————————————————————————————————————————————————————————————————————————————
				// Atualizando a tabela SZK - movimentos VPC
				// Função do fonte BFATA03.PRW
				// Parâmetros da função U_VPCGrava_FT03
				//	[1]- Tipo do movimento "CR" para crédito e "DB" para débito
				//	[2]- Código do cliente
				//	[3]- Loja do cliente, qdo o contrato exigir. Somente p/ situações com contrato VPC
				//	[4]- Codigo do contrato VPC
				//	[5]- Tipo do percentual VPC
				//	[6]- Valor da base de cálculo
				//	[7]- Valor do débito ou crédito do movimento
				//	[8]- Campo descritivo com o histórico do lançamento 
				//	[9]- Origem do lançamento
				//	[10]- Chave do registro que originou o lançamento
				//	[11]- Uso da VPC S/N para: NCC / CtaPag / Ped.Bonificados
				//	[12]- Data do movimento
				//———————————————————————————————————————————————————————————————————————————————
				U_VPCGrava_FT03("DB",;
								cCliente,;
								iif(lLoja, cLojaCli, ""),;
								"",;
								aCols[nK,1],;
								aCols[nK,4],;
								aCols[nK,4],;
								cHistorico,;
								"7",;
								cSolicitacao,;
								aCols[nK,5],;
								dDataBase,;
								0,;
								cSolicitacao,;
								Nil,;
								aDocEnt)

				ZZV->(dbSeek(xFilial("ZZV") + cSolicitacao + aCols[nK,1]))
				do while ZZV->(!eof() .and. ZZV_FILIAL == xFilial("ZZV") .and. ZZV_NUM == cSolicitacao .and. ZZV_TPVPC == aCols[nK,1])
					ZZV->(RecLock("ZZV",.F.))
					ZZV->ZZV_STATUS := "P"	//Processado
					ZZV->(MsUnlock())
					ZZV->(dbSkip())
				enddo

			next

			Close(oListaSld)

		else
			SA2->(dbSetOrder(1))
			
			if Empty(cFornecedor) .or. Empty(cLojaFor)

				Help(" ", 1, "ATENÇÃO", , "O código do fornecedor ou da loja do fornecedor, para a criação do título, não foi informado. O processo não será finalizado." + chr(13) + chr(10) + "(Específico Brasitech)", 1)
				
			elseif !SA2->(dbSeek(xFilial("SA2") + cFornecedor + cLojaFor))
			
				Help(" ", 1, "ATENÇÃO", , "Fornecedor não encontrado. O processo não será finalizado." + chr(13) + chr(10) + "(Específico Brasitech)", 1)
				
			elseif !U_SE2DtVcVlr(nUsoSld, dVencto, AllTrim(aInfBanco[1]), .F.)

				Help(" ", 1, "ATENÇÃO",, "A data de vencimento e/ou o valor do título não correspondem ao informado neste código de barras." + chr(13) + chr(10) + "(Específico Brasitech)", 1)

			else
			
				SE2->(dbSetOrder(1))
				
				cNum	  	:= GetMV("BR_VPCNUM", .F.)
				do while SE2->(dbSeek(xFilial("SE2") + "VPC" + cNum))
					cNum	:= Soma1(cNum)
				enddo
				PutMV("BR_VPCNUM", cNum)
				
				aTitulo 	:= {	{"E2_PREFIXO",	"VPC",										Nil} ,;
									{"E2_NUM",		cNum,										Nil} ,;
									{"E2_PARCELA",	" ",										Nil} ,;
									{"E2_TIPO",		"NF ",										Nil} ,;
									{"E2_FORNECE",	cFornecedor,								Nil} ,;
									{"E2_LOJA",		cLojaFor,									Nil} ,;
									{"E2_NOMFOR" ,	Posicione("SA2", 1, xFilial("SA2") + cFornecedor + cLojaFor, "A2_NOME"), 	Nil},;
									{"E2_NATUREZ",	GetMV("BR_VPCNATP", .F., ""),				Nil} ,;
									{"E2_EMISSAO",	dDataBase,									Nil} ,;
									{"E2_VENCTO",	dVencto,			   						Nil} ,;
									{"E2_VENCREA",	DataValida(dVencto),						Nil} ,;
									{"E2_HIST",		cHist,										Nil} ,;
									{"E2_VALOR",	nUsoSld,									Nil} ,;
									{"E2_CODBAR",	aInfBanco[1],								Nil} ,;
									{"E2_FORBCO",	iif(Empty(aInfBanco[1]),aInfBanco[2],""),	Nil} ,;
									{"E2_FORAGE",	iif(Empty(aInfBanco[1]),aInfBanco[3],""),	Nil} ,;
									{"E2_FAGEDV",	iif(Empty(aInfBanco[1]),aInfBanco[4],""),	Nil} ,;
									{"E2_FORCTA",	iif(Empty(aInfBanco[1]),aInfBanco[5],""),	Nil} ,;
									{"E2_FCTADV",	iif(Empty(aInfBanco[1]),aInfBanco[6],""),	Nil} ,;
									{"E2_X_VPC",	"S",										Nil}	}

				MsExecAuto({ |x,y,z| FINA050(x,y,z) }, aTitulo,, 3)
				
				if lMsErroAuto
				
					MostraErro()
					DisarmTransaction()
					Help(" ", 1, "ATENÇÃO",, "Ocorreu um problema na criação do título e o processo nao será concluído." + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Brasitech)", 1)
				
				else
				
					if Len(aCols) > 0
					
						for nK := 1 to Len(aCols)
							SZI->(dbSeek(xFilial("SZI") + aCols[nK,1]))
							cHistorico := 	"Debito por criacao Cta.Pagar: " + SE2->(E2_PREFIXO + "/" + E2_NUM + "/" + E2_PARCELA + "/" + E2_TIPO + "/" + E2_FORNECE + "/" + E2_LOJA) +;
												", TpVPC: " + aCols[nK,1] + "-" + AllTrim(SZI->ZI_DESCR)
							//———————————————————————————————————————————————————————————————————————————————
							// Atualizando a tabela SZK - movimentos VPC
							// Função do fonte BFATA03.PRW
							// Parâmetros da função U_VPCGrava_FT03
							//	[1]- Tipo do movimento "CR" para crédito e "DB" para débito
							//	[2]- Código do cliente
							//	[3]- Loja do cliente, qdo o contrato exigir. Somente p/ situações com contrato VPC
							//	[4]- Codigo do contrato VPC
							//	[5]- Tipo do percentual VPC
							//	[6]- Valor da base de cálculo
							//	[7]- Valor do débito ou crédito do movimento
							//	[8]- Campo descritivo com o histórico do lançamento 
							//	[9]- Origem do lançamento
							//	[10]- Chave do registro que originou o lançamento
							//	[11]- Uso da VPC S/N para: NCC / CtaPag / Ped.Bonificados
							//	[12]- Data do movimento
							//———————————————————————————————————————————————————————————————————————————————
							U_VPCGrava_FT03("DB",;
											cCliente,;
											iif(lLoja, cLojaCli, ""),;
											"",;
											aCols[nK,1],;
											aCols[nK,4],;
											aCols[nK,4],;
											cHistorico,;
											"6",;
											SE2->(E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA),;
											aCols[nK,5],;
											dDataBase,;
											0,;
											cSolicitacao)

							ZZV->(dbSeek(xFilial("ZZV") + cSolicitacao + aCols[nK,1]))
							do while ZZV->(!eof() .and. ZZV_FILIAL == xFilial("ZZV") .and. ZZV_NUM == cSolicitacao .and. ZZV_TPVPC == aCols[nK,1])
								ZZV->(RecLock("ZZV",.F.))
								ZZV->ZZV_STATUS := "P"	//Processado
								ZZV->(MsUnlock())
								ZZV->(dbSkip())
							enddo

						next
						
					endif
					
					MsgBox("Foi gerado o título: " + SE2->("FILIAL, PREFIXO-NÚMERO-PARCELA-TIPO: " + chr(13) + chr(10) + E2_FILIAL + ", " + E2_PREFIXO + "-" + E2_NUM + "-" + E2_PARCELA + "-" + E2_TIPO + ", com vencimento em " + dTOc(E2_VENCTO) + " e fornecedor: " + E2_FORNECE + "/" + E2_LOJA), "Título", "INFO")
					
				endif
				
				Close(oListaSld)
				
			endif
		endif
	
	endif
    
else

	Help(" ", 1, "ATENÇÃO",, "Nenhum valor foi informado para uso. Verifique e volte a confirmar." + chr(13) + chr(10) + "(Específico Brasitech)", 1)

endif	

Return()


/*
———————————————————————————————————————————————————————————————————————————————
@function		PedVen_FT03                                                  /@
@type		  	User function                                                /@
@date			26/11/2011                                                   /@
@description	Função para incluir pedidos bonificados                      /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
*/
User Function PedVen_FT03()
Local nUsoVPC   	:= 0
Local nValIPI	 	:= 0
Local lIPI		 	:= .T.
Local cVPCAvulsa	:= "AVU"
Local lLoja, cContrato	//, nValDeb

Private L410AUTO := .F.
//Private VPCVALCRED		//Variavel será alimentada na rotina VPCCRED_FT03() acionada pela validação do
								//campo C5_CLIENTE e utilizada como comparacao no ponto de entrada M410LIOK
								//X3_VLDUSER do campo C5_CLIENTE: U_VPCCRED_FT03()
//Private VPCSLDVETOR		//Variavel será alimentada na rotina VPCCRED_FT03() acionada pela validação do
								//campo C5_CLIENTE e utilizada como comparacao no ponto de entrada M410LIOK
								//X3_VLDUSER do campo C5_CLIENTE: U_VPCCRED_FT03()

if A410Inclui("SC5",SC5->(Recno()),3,,,,,,,) == 1

	lLoja	  		:= (SA1->A1_X_MDVPC == "L")
	cContrato 	:= iif(!Empty(SC5->C5_X_CTVPC), SC5->C5_X_CTVPC, U_VPCFindCt_FT03(SC5->C5_CLIENTE, SC5->C5_LOJACLI))
	
	SB1->(dbSetOrder(1))
	SC6->(dbSetOrder(1))
	SF4->(dbSetOrder(1))
	SZJ->(dbSetOrder(1))	//1 - ZJ_FILIAL+ZJ_CONTRAT+ZJ_CLIENTE+ZJ_LOJA

	//Localizo o contrato e verifico qual é a base de cálculo
	if SZJ->(dbSeek(xFilial("SZJ") + cContrato))
		lIPI := (SZJ->ZJ_IPI=="S")
	endif
	
	SC6->(dbSeek(xFilial("SC6") + SC5->C5_NUM))
	do while SC6->(!eof() .and. C6_FILIAL = xFilial("SC6") .and. C6_NUM = SC5->C5_NUM)
		SB1->(dbSeek(xFilial("SB1") + SC6->C6_PRODUTO))
		SF4->(dbSeek(xFilial("SF4") + SC6->C6_TES))
		
		if SF4->F4_DUPLIC == "N"
			if SF4->F4_IPI == "S" .and. lIPI
				nValIPI := SC6->C6_VALOR * (SB1->B1_IPI / 100)
			else
				nValIPI := 0
			endif

			nUsoVPC += (SC6->C6_VALOR + nValIPI)
		endif
		SC6->(dbSkip())
	enddo
	
	//atualizando a tabela SZK - movimentos VPC, abatendo automaticamente dos
	//créditos por tipo VPC (constante no vetor VPCSLDVETOR), até zerá-lo.
	if nUsoVPC > 0
	
	/*
		
		Retirada gravação de uso VPC por tipo de saldo existente. 
		Atualizar sempre com o uso de VPC avulsa e com o valor total.
		Validação do valor que poderá ser utilizado feita no sistema WEB.
		Alterado por Adalberto em 19/08/19
		
	
		for nK := 1 to Len(VPCSLDVETOR)
		    
			if nUsoVPC == 0
				exit
			elseif nUsoVPC >= VPCSLDVETOR[nK,2]
				nValDeb := VPCSLDVETOR[nK,2]
				nUsoVPC -= VPCSLDVETOR[nK,2]
			else
				nValDeb := nUsoVPC
				nUsoVPC := 0
			endif

			SZI->(dbSeek(xFilial("SZI") + VPCSLDVETOR[nK,1]))
			cHistorico := 	"Debito pedido bonificado: " + SC5->C5_NUM +;
								", TpVPC: " + VPCSLDVETOR[nK,1] + "-" + AllTrim(SZI->ZI_DESCR)

			U_VPCGrava_FT03(	"DB",;
									SC5->C5_CLIENTE,;
									iif(lLoja, SC5->C5_LOJACLI, ""),;
									cContrato,;
									VPCSLDVETOR[nK,1],;
									0,;
									nValDeb,;
									cHistorico,;
									"2",;
									SC5->(C5_FILIAL + C5_NUM),;
									VPCSLDVETOR[nK,3],;
									dDataBase	)
		next
*/

		SZI->(dbSeek(xFilial("SZI") + cVPCAvulsa))
		cHistorico := 	"Debito pedido bonificado: " + SC5->C5_NUM +;
							", TpVPC: " + cVPCAvulsa + "-" + AllTrim(SZI->ZI_DESCR)
		//———————————————————————————————————————————————————————————————————————————————
		// Atualizando a tabela SZK - movimentos VPC
		// Função do fonte BFATA03.PRW
		// Parâmetros da função U_VPCGrava_FT03
		//	[1]- Tipo do movimento "CR" para crédito e "DB" para débito
		//	[2]- Código do cliente
		//	[3]- Loja do cliente, qdo o contrato exigir. Somente p/ situações com contrato VPC
		//	[4]- Codigo do contrato VPC
		//	[5]- Tipo do percentual VPC
		//	[6]- Valor da base de cálculo
		//	[7]- Valor do débito ou crédito do movimento
		//	[8]- Campo descritivo com o histórico do lançamento 
		//	[9]- Origem do lançamento
		//	[10]- Chave do registro que originou o lançamento
		//	[11]- Uso da VPC S/N para: NCC / CtaPag / Ped.Bonificados
		//	[12]- Data do movimento
		//———————————————————————————————————————————————————————————————————————————————
		U_VPCGrava_FT03(	"DB",;
								SC5->C5_CLIENTE,;
								iif(lLoja, SC5->C5_LOJACLI, ""),;
								cContrato,;
								cVPCAvulsa,;
								0,;
								nUsoVPC,;
								cHistorico,;
								"2",;
								SC5->(C5_FILIAL + C5_NUM),;
								"SSS",;
								dDataBase	)


		
	endif

endif

Return()


/*
———————————————————————————————————————————————————————————————————————————————
@function		CanMov_FT03                                                  /@
@type			User function                                                /@
@date			23/12/2013                                                   /@
@description	Função para excluir movimentos VPC, manuais ou pedidos de 
				bonificação                                                  /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
*/
User Function CanMov_FT03()
Local aPedido, lExcMov, nSaldo
Local aItemPV 			:= {}
Local cChave 			:= SZK->ZK_CHAVE
Local nTotalCtb 		:= 0
Local cLP		 		:= "411"
Local cLote				:= "VPC001"
Local cArqCtb			:= ""
Local nHdlPrv			:= 0
Local lVisual			:= .F.
Local lAglutina			:= .F.

Private lMsErroAuto 	:= .F.

if Empty(SZK->ZK_TPCHV)

	if MsgBox("Deseja apagar o movimento manual selecionado?", "Pergunta", "YESNO")
	
		lExcMov := .T.
		if SZK->ZK_TIPO == "CR"
			
			//———————————————————————————————————————————————————————————————————————————————
			// Pesquisando o saldo do tipo VPC que será excluído (saldo NCC)
			//———————————————————————————————————————————————————————————————————————————————
			nSaldo := 0
			
			/*
			if Substring(SZK->ZK_USO,1,1) == "S" .and. lExcMov
				aSaldos := U_VPCCalcSld( SZK->ZK_CLIENTE,;
												 SZK->ZK_LOJA,;
												 "1",;
												 @nSaldo,;
												 dDataBase)
				nSaldo := 0
				for nK := 1 to Len(aSaldos)
					if aSaldos[nK,1] == SZK->ZK_TPVPC
						nSaldo += aSaldos[nK,2]
					endif
				next
				if nSaldo - SZK->ZK_VALOR < 0
					lExcMov := .F.
				endif
			endif
			
			//———————————————————————————————————————————————————————————————————————————————
			// Pesquisando o saldo do tipo VPC que será excluído (saldo contas a pagar)
			//———————————————————————————————————————————————————————————————————————————————
			nSaldo := 0
			if Substring(SZK->ZK_USO,1,1) == "S" .and. lExcMov
				aSaldos := U_VPCCalcSld( SZK->ZK_CLIENTE,;
												 SZK->ZK_LOJA,;
												 "2",;
												 @nSaldo,;
												 dDataBase)
				nSaldo := 0
				for nK := 1 to Len(aSaldos)
					if aSaldos[nK,1] == SZK->ZK_TPVPC
						nSaldo += aSaldos[nK,2]
					endif
				next
				if nSaldo - SZK->ZK_VALOR < 0
					lExcMov := .F.
				endif
			endif
		
			//———————————————————————————————————————————————————————————————————————————————
			// Pesquisando o saldo do tipo VPC que será excluído (saldo pedido bonificado)
			//———————————————————————————————————————————————————————————————————————————————
			nSaldo := 0
			if Substring(SZK->ZK_USO,1,1) == "S" .and. lExcMov

				aSaldos := U_VPCCalcSld( SZK->ZK_CLIENTE,;
												 SZK->ZK_LOJA,;
												 "3",;
												 @nSaldo,;
												 dDataBase)
				nSaldo := 0
				for nK := 1 to Len(aSaldos)
					if aSaldos[nK,1] == SZK->ZK_TPVPC
						nSaldo += aSaldos[nK,2]
					endif
				next
				if nSaldo - SZK->ZK_VALOR < 0
					lExcMov := .F.
				endif
			endif
      */
		endif

		//———————————————————————————————————————————————————————————————————————————————
		// Verifico se o saldo poderá ser excluido
		//———————————————————————————————————————————————————————————————————————————————
		if lExcMov
		
			//———————————————————————————————————————————————————————————————————————————————
			// Inicializa o arquivo de contabilizacao 
			//———————————————————————————————————————————————————————————————————————————————
			if VerPadrao(cLP) .and. !empty(SZK->ZK_DTCTB)
			
				nHdlPrv := HeadProva(cLote, "BCTBA01", Substr(cUsuario,7,6), @cArqCtb)
		
				//———————————————————————————————————————————————————————————————————————————————
				// Registra o lançamento contábil
				//———————————————————————————————————————————————————————————————————————————————
			   if nHdlPrv > 0
					nTotalCtb  += DetProva(nHdlPrv, cLP, "BCTBA01", cLote)
				endif
		
			endif
			
			//———————————————————————————————————————————————————————————————————————————————
			// Exclui o movimento
			//———————————————————————————————————————————————————————————————————————————————
			SZK->(RecLock("SZK", .F.))
			SZK->(dbDelete())
			SZK->(MsUnlock())

			//———————————————————————————————————————————————————————————————————————————————
			// Gera a contabilização
			//———————————————————————————————————————————————————————————————————————————————
			if nHdlPrv > 0 .and. nTotalCtb > 0
			
				RodaProva(nHdlPrv, nTotalCtb)
				cA100Incl(cArqCtb, nHdlPrv, 1, cLote, lVisual, lAglutina)
			
			endif
			
//		else
		
//			Help(" ", 1, "ATENÇÃO",, "O movimento de crédito manual não poderá ser excluído, pois o saldo ficará negativo." + chr(13) + chr(10) + "(Específico Brasitech)", 1)
		
		endif
	endif

elseif SZK->ZK_TPCHV == "1"	//credito por nota fiscal de saida
	Help(" ", 1, "ATENÇÃO",, "Para cancelamentos de créditos/débitos, exclua a nota fiscal de saida através da rotina apropriada." + chr(13) + chr(10) + "(Específico Brasitech)", 1)

elseif SZK->ZK_TPCHV == "2"
	if MsgBox("Atenção, este é um movimento gerado a partir do uso de créditos VPC e da criação de um pedido bonificado. Ao excluí-lo o pedido bonificado e todos os movimentos vinculados à ele serão exluídos. Confirma a operação?", "Pergunta", "YESNO")
		SC5->(dbSetOrder(1))
		SC6->(dbSetOrder(1))
		
		if SC5->(dbSeek(AllTrim(cChave)))
	
			aPedido 	:= {	{"C5_NUM",		SC5->C5_NUM,		Nil} ,;
			   				{"C5_CLIENTE",	SC5->C5_CLIENTE,	Nil} ,;
								{"C5_LOJACLI",	SC5->C5_LOJACLI,	Nil} }
								
			SC6->(dbSeek(xFilial("SC6") + Substr(SZK->ZK_CHAVE, 1, 6)))
			do while SC6->(!eof() .and. C6_FILIAL = xFilial("SC6") .and. C6_NUM = Substr(SZK->ZK_CHAVE, 1, 6))
				aAdd( aItemPV,{	{"C6_NUM",		SC6->C6_NUM,		Nil} ,;
										{"C6_ITEM",		SC6->C6_ITEM,		Nil} ,;
										{"C6_PRODUTO",	SC6->C6_PRODUTO,	Nil} ,;
										{"C6_QTDVEN",	SC6->C6_QTDVEN,	Nil} ,;
										{"C6_PRUNIT",	SC6->C6_PRUNIT,	Nil} ,;
										{"C6_PRCVEN",	SC6->C6_PRCVEN,	Nil} ,;
										{"C6_VALOR",	SC6->C6_VALOR,		Nil} ,;
										{"C6_UM",		SC6->C6_UM,			Nil} ,;
										{"C6_TES",		SC6->C6_TES,		Nil} ,;
										{"C6_LOCAL",	SC6->C6_TES,		Nil} ,;
										{"C6_CLI",		SC6->C6_CLI,		Nil} ,;
										{"C6_LOJA",		SC6->C6_LOJA,		Nil} } )
				SC6->(dbSkip())
			enddo
			
			Begin Transaction
			
				MSExecAuto({ |x,y,z| MATA410(x,y,z) }, aPedido, aItemPV, 5)
		
				if lMsErroAuto
				
					MostraErro()
					DisarmTransaction()
					Help(" ", 1, "ATENÇÃO",, "O pedido não foi excluído, portanto os movimentos VPC também não serão!" + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Brasitech)", 1)
					
				else
					
					U_VPCApaga_FT03("2", cChave)
					MsgBox("Pedido de vendas bonificado excluído com sucesso.")
					
				endif
				
			End Transaction
			
		else
		
			Help(" ", 1, "ATENÇÃO",, "Pedido não encontrado!" + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Brasitech)", 1)
		
		endif
		
	endif

elseif SZK->ZK_TPCHV == "3"
	Help(" ", 1, "ATENÇÃO",, "Para cancelamento de movimentos financeiros, utilize a função Exclui Mov.Financ." + chr(13) + chr(10) + "(Específico Brasitech)", 1)

elseif SZK->ZK_TPCHV == "4"
	Help(" ", 1, "ATENÇÃO",, "Para cancelamentos de débitos por devoluções, exclua a nota fiscal de entrada através da rotina apropriada." + chr(13) + chr(10) + "(Específico Brasitech)", 1)

elseif SZK->ZK_TPCHV == "5"
	Help(" ", 1, "ATENÇÃO",, "Transferências não são excluídas. Para cancelar uma transferência faça um nov lançamento de transferência invertendo o de/para." + chr(13) + chr(10) + "(Específico Brasitech)", 1)
	
elseif SZK->ZK_TPCHV == "6" .or. SZK->ZK_TPCHV == "7"
	Help(" ", 1, "ATENÇÃO",, "Para cancelamento de movimentos financeiros, utilize a função Exclui Mov.Financ." + chr(13) + chr(10) + "(Específico Brasitech)", 1)

else
	Help(" ", 1, "ATENÇÃO",, "Tipo não indentificado. Contate o departamento de T.I. e comunique esta ocorrência." + chr(13) + chr(10) + "(Específico Brasitech)", 1)
	
endif
Return()


/*
———————————————————————————————————————————————————————————————————————————————
@function		CanFin_FT03                                                  /@
@type			User function                                                /@
@date			23/12/2103                                                   /@
@description	Função para excluir ss movimentos VPC, referentes ao uso dos
				créditos VPC que podem ser um título à receber NCC (SE1)
				ou titulo à pagar.                                           /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
*/
User Function CanFin_FT03()
Local aTitulo
Local cChave 			:= SZK->ZK_CHAVE
Private lMsErroAuto 	:= .F.

if Empty(SZK->ZK_TPCHV)
	Help(" ", 1, "ATENÇÃO", , "Para cancelamento de movimentos manuais, utilize a função Exclui Movimentos." + chr(13) + chr(10) + "(Específico Brasitech). ", 1)

elseif SZK->ZK_TPCHV == "1"	//credito por nota fiscal de saida
	Help(" ", 1, "ATENÇÃO", , "Para cancelamentos de créditos/débitos, exclua a nota fiscal de saida através da rotina apropriada." + chr(13) + chr(10) + "(Específico Brasitech). ", 1)

elseif SZK->ZK_TPCHV == "2"
	Help(" ", 1, "ATENÇÃO", , "Para cancelamento de movimentos de pedidos bonificados, utilize a função Exclui Movimentos." + chr(13) + chr(10) + "(Específico Brasitech). ", 1)

elseif SZK->ZK_TPCHV == "3"
	if MsgBox("Atenção, este é um movimento gerado a partir do uso de créditos VPC e da criação de um título NCC. Ao excluí-lo o título NCC e todos os movimentos vinculados à ele serão exluídos. Confirma a operação?", "Pergunta", "YESNO")

		SE1->(dbSetOrder(1))
		if SE1->(dbSeek(AllTrim(cChave)))
	
			aTitulo 	:= {	{"E1_PREFIXO",	SE1->E1_PREFIXO,	Nil} ,;
								{"E1_NUM",		SE1->E1_NUM,		Nil} ,;
								{"E1_PARCELA",	SE1->E1_PARCELA,	Nil} ,;
								{"E1_TIPO",		SE1->E1_TIPO,		Nil} ,;
								{"E1_CLIENTE",	SE1->E1_CLIENTE,	Nil} ,;
								{"E1_LOJA",		SE1->E1_LOJA,		Nil} }
	
			Begin Transaction
				MsExecAuto({ |x,y| FINA040(x,y) }, aTitulo, 5)
		
				if lMsErroAuto
				
					MostraErro()
					DisarmTransaction()
					Help(" ", 1, "ATENÇÃO",, "O título NCC não foi excluído, portanto os movimentos VPC também não serão!" + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Brasitech)", 1)
				
				else
				
					//atualizando a tabela SZK - movimentos VPC
					U_VPCApaga_FT03("3", cChave)
					MsgBox("Título NCC e movimentos VPC excluídos com sucesso.")
				
				endif
				
			End Transaction
			
		else
			
			Help(" ", 1, "ATENÇÃO",, "Título não encontrado!" + chr(13) + chr(10) + "(Específico Brasitech)", 1)
			
		endif
		
	endif

elseif SZK->ZK_TPCHV == "4"
	Help(" ", 1, "ATENÇÃO",, "Para cancelamentos de débitos por devoluções, exclua a nota fiscal de entrada através da rotina apropriada." + chr(13) + chr(10) + "(Específico Brasitech)", 1)

elseif SZK->ZK_TPCHV == "5"
	Help(" ", 1, "ATENÇÃO",, "Transferências não são excluídas. Para cancelar uma transferência faça um nov lançamento de transferência invertendo o de/para." + chr(13) + chr(10) + "(Específico Brasitech)", 1)
	
elseif SZK->ZK_TPCHV == "6"
	if MsgBox("Atenção, este é um movimento gerado a partir do uso de créditos VPC e da criação de um título a pagar. Ao excluí-lo o título a pagar e todos os movimentos vinculados à ele serão exluídos. Confirma a operação?", "Pergunta", "YESNO")
	
		SE2->(dbSetOrder(1))	//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
		if SE2->(dbSeek(AllTrim(cChave)))
	
			aTitulo 	:= {	{"E2_PREFIXO",	SE2->E2_PREFIXO,	Nil},;
								{"E2_NUM",		SE2->E2_NUM,		Nil},;
								{"E2_PARCELA",	SE2->E2_PARCELA,	Nil},;
								{"E2_FORNECE",	SE2->E2_FORNECE,	Nil},;
								{"E2_LOJA",		SE2->E2_LOJA,		Nil},;
								{"E2_TIPO",		SE2->E2_TIPO,		Nil} ,;
								{"E2_NATUREZ",	SE2->E2_NATUREZ,	Nil} }

			Begin Transaction
				
				MsExecAuto({ |x,y,z| FINA050(x,y,z) }, aTitulo,, 5)
		
				if lMsErroAuto
				
					MostraErro()
					DisarmTransaction()
				    Help(" ", 1, "ATENÇÃO",, "O título a pagar não foi excluído, portanto os movimentos VPC também não serão!" + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Brasitech)", 1)
				    
				else

					//atualizando a tabela SZK - movimentos VPC
					U_VPCApaga_FT03("6", cChave)
					MsgBox("Título à pagar e movimentos VPC excluídos com sucesso.")

					if SE2->(dbSeek(AllTrim(cChave)))
						alert("Titulo não excluído. não excluido. Entrar em contato com o departamento de TI e informar a chave: " + cChave)
					endif

				endif
			End Transaction
			
		else
			
			Help(" ", 1, "ATENÇÃO",, "Título não encontrado!" + chr(13) + chr(10) + "(Específico Brasitech)", 1)
			
		endif
		
	endif

elseif SZK->ZK_TPCHV == "7"
	if MsgBox("Confirma a operação?", "Pergunta", "YESNO")
		//atualizando a tabela SZK - movimentos VPC
		U_VPCApaga_FT03("7", cChave)
		MsgBox("Movimentos VPC vinculado a um documento fiscal excluídos com sucesso.")
	endif

else
	
	Help(" ", 1, "ATENÇÃO",, "Tipo não indentificado. Contate o departamento de T.I. e comunique esta ocorrência." + chr(13) + chr(10) + "(Específico Brasitech)", 1)
	
endif 

//aqui RETORNAR O FLAG DE ABERTO, CASO O MOVIMENTO FINANCEIRO SEJA CANCELADO
Return()


/*
———————————————————————————————————————————————————————————————————————————————
@function		VPCCred_FT03                                                 /@
@type			User function                                                /@
@date			29/07/2013                                                   /@
@description	Função acionada na validação do cliente no pedido de vendas
				para cálculo do saldo VPC disponível para uso.
				Alimentar as variáveis privadas VPCVALCRED e VPCSLDVETOR     /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
*/
User Function VPCCred_FT03(cCliente, cLoja)
Local lRet	:= .T.
//Local lLoja	:= (SA1->A1_X_MDVPC == "L")
//Local cEol	:= chr(13) + chr(10)

/*
retirado em 19/08/19 por Adalberto
Saldos VPC são analisados no sistema WEB
//funcao VPCCRED acionada na validacao de usuario do campo C5_CLIENTE
if FunName() == "BFATA03"

	//Variavel privada VPCVALCRED e VPCSLDVETOR criada na funcao PV_FT03(), fonte BFATA03
	//Será utilizada em comparacao de valores no ponto de entrada M410LIOK
	VPCVALCRED	:= 0
	VPCSLDVETOR	:= U_VPCCalcSld(cCliente, iif(lLoja, cLoja, "  "), "3", @VPCVALCRED, dDataBase)
		
	if VPCVALCRED <= 0

		lRet := .F.
		Help(" ", 1, "Atenção",, "Este cliente não possui saldo disponível para uso em pedidos VPC." + cEol + "Crédito disponível R$ " + AllTrim(Transf(VPCVALCRED,"@E 999,999,999.99")) + cEol + cEol + "(Específico Gama Italy)," + cEol + "validação campo C5_CLIENTE em MATA410.", 1)

	else

		M->C5_X_CTVPC := U_VPCFindCt_FT03(cCliente, cLoja)
		MsgBox("Este cliente possui um saldo de créditos VPC de R$ " + AllTrim(Transf(VPCVALCRED,"@E 999,999,999.99")) + " para uso em pedidos bonificados." + cEol + cEol + "(Específico Gama Italy)", "Atenção", "INFO")

	endif

endif
*/

Return(lRet)


/*
———————————————————————————————————————————————————————————————————————————————
@function		VldMdVPC_FT03                                                /@
@type			User function                                                /@
@date			26/10/2013                                                   /@
@description	Função para validar a alteração do modo de controle VPC, 
				(C) codigo cliente ou (L) codigo + loja. 
				De "L" para "C"
				O saldo do cliente + loja deve ser igual à zero.
				De "C" ou " " para "L"
				Há duas considerações. Se for um único cliente para o mesmo 
				código, o saldo deverá ser igual à zero. Se houver outro 
				cliente com mesmo código e somente incremento de loja, a 
				alteração será permitida.                                    /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
*/
User Function VldMdVPC_FT03(cModo)
//Local aArea		:= GetArea()
Local lRet		:= .T.
Local cMdAtual	:= iif(Empty(SA1->A1_X_MDVPC), "C", SA1->A1_X_MDVPC)
//Local nSaldo	:= 0
//Local cEol		:= chr(13) + chr(10) + chr(13) + chr(10)
//Local cCliente	//, nCont

if !cMdAtual $ "CL"
	lRet := .F.

/*
retirado em 19/08/19 por Adalberto
Saldo VPC é analisado no sistema WEB
else
	SA1->(dbSetOrder(1))
	cCliente := SA1->A1_COD
	
	if cMdAtual == "L"
		//Busca saldo de 1-NCC
		U_VPCCalcSld(SA1->A1_COD, SA1->A1_LOJA, "1", @nSaldo)
	
		//Busca saldo de 1-Cta pagar
		U_VPCCalcSld(SA1->A1_COD, SA1->A1_LOJA, "2", @nSaldo)
		
		//Busca saldo de 3-Ped. Bonif
		U_VPCCalcSld(SA1->A1_COD, SA1->A1_LOJA, "3", @nSaldo)
		
		if nSaldo != 0
			lRet := .F.
			Help(" ", 1, "Atenção",, "Esta troca de modo de controle VPC não poderá ser realizada, pois este cliente e loja possui saldo VPC pendente. Zere o saldo com movimentos manuais e volte antes de tentar trocar o modo de controle." + cEol + cEol + "(Específico Gama Italy)," + cEol + "função VldMdVPC_FT03", 1)
		endif
		
	else
		//procurar se o cliente possui mais de uma loja para o mesmo codigo
		SA1->(dbSeek(xFilial("SA1") + cCliente))
		nCont := 0
		do while SA1->(!eof() .and. A1_FILIAL + A1_COD == xFilial("SA1") + cCliente)
			nCont++
			SA1->(dbSkip())
		enddo
		RestArea(aArea)
		
		//se houver mais de um cliente para o mesmo codigo, o procedimento será identico à troca de "L" para "C"
		if nCont > 1
			//Busca saldo de 1-NCC
			U_VPCCalcSld(SA1->A1_COD, "  ", "1", @nSaldo)
		
			//Busca saldo de 1-Cta pagar
			U_VPCCalcSld(SA1->A1_COD, "  ", "2", @nSaldo)
			
			//Busca saldo de 3-Ped. Bonif
			U_VPCCalcSld(SA1->A1_COD, "  ", "3", @nSaldo)
			
			if nSaldo != 0
				lRet := .F.
				Help(" ", 1, "Atenção",, "Esta troca de modo de controle VPC não poderá ser realizada, pois este cliente possui mais de uma loja cadastrada e também possui saldo VPC pendente. Zere o saldo com movimentos manuais e volte antes de tentar trocar o modo de controle." + cEol + "(Específico Gama Italy)," + cEol + "função VldMdVPC_FT03", 1)
			endif
		endif
		
	endif
	RestArea(aArea)
*/

endif

Return(lRet)


/*
———————————————————————————————————————————————————————————————————————————————
@function		GetMdVPC_FT03                                                /@
@type	 		User function                                                /@
@date			26/10/2013                                                   /@
@description	Função para buscar o modo de controle VPC, se por código de
				cliente ou por codigo de cliente + loja                      /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
*/
User Function GetMdVPC_FT03(cCliente, cLoja)
Local aArea		:= GetArea()
Local aAreaSA1	:= GetArea()
Local cRet		:= ""

SA1->(dbSetOrder(1))
if SA1->(dbSeek(xFilial() + cCliente + cLoja))
	cRet := iif(Empty(SA1->A1_X_MDVPC), "C", SA1->A1_X_MDVPC)
endif

RestArea(aAreaSA1)
RestArea(aArea)

Return(cRet)

/*
———————————————————————————————————————————————————————————————————————————————
@function		VldNF                                                        /@
@type	 		User function                                                /@
@date			27/08/2022                                                   /@
@description	Valida informações NF. Ao preencher a NF, não será gerado
				título a pagar                                               /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
*/
Static Function VldNF(cNumDoc,cSerDoc,cForDoc,cLojDoc,cBarras,cBanco,cAgenc,cDVA,cConta,cDVC)
Local lRet := .T.

if Empty(cNumDoc)

	cSerDoc		:= Space(Len(cSerDoc))
	cForDoc		:= Space(Len(cForDoc))
	cLojDoc		:= Space(Len(cLojDoc))

else
	SF1->(dbSetOrder(1))		//F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO
	if SF1->(dbSeek(xFilial("SF1") + cNumDoc + cSerDoc + cForDoc + cLojDoc))

		if !Empty(SF1->F1_DUPL)
			if MsgYesNo("Ao vincular o processo de pagamento VPC à um documento de entrada, o sistema não irá gerar um título a pagar. Confirma a operação?", "ATENÇÃO")

				cBarras		:= Space(Len(cBarras))
				cBanco		:= Space(Len(cBanco))
				cAgenc		:= Space(Len(cAgenc))
				cDVA		:= Space(Len(cDVA))
				cConta		:= Space(Len(cConta))
				cDVC		:= Space(Len(cDVC))

			else

				lRet	:= .F.

			endif
			
		else

			lRet	:= .F.
			Help(" ", 1, "ATENÇÃO",, "Este documento de entrada não gerou títulos a pagar, portanto não poderá ser vinculado a um processo VPC." + chr(13) + chr(10) + "(Específico " + AllTrim(SM0->M0_NOME) + ")", 1)

		endif
	else
		
		lRet	:= .F.
		Help(" ", 1, "ATENÇÃO",, "O documento de entrada vinculado ao processo VPC não foi encontrado." + chr(13) + chr(10) + "(Específico " + AllTrim(SM0->M0_NOME) + ")", 1)

	endif

endif

Return(lRet)
